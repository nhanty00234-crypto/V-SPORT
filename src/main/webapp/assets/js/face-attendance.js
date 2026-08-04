'use strict';

window.FaceAttendance = (function () {
    const DETECTION_INTERVAL_MS = 100;  // 10fps
    const REQUIRED_STREAK = 3;          // số frame liên tiếp đạt ngưỡng mới chấp nhận
    const TIMEOUT_MS = 15000;           // quá thời gian này thì dừng và mời thử lại

    let _opts = {};
    let _stream = null;
    let _intervalId = null;
    let _timeoutId = null;
    let _token = null;
    let _capturedDescriptor = null;
    let _capturedSnapshot = null;
    let _modelsLoaded = false;
    let _enrolledSamples = [];       // các mẫu đã đăng ký, để chấm tại chỗ
    let _threshold = 0.6;            // khoảng cách Euclidean tối đa được duyệt
    let _streak = 0;                 // số frame liên tiếp đang đạt
    let _bestDistance = Infinity;    // frame tốt nhất trong chuỗi hiện tại
    let _bestDetection = null;

    // ── Utilities ──────────────────────────────────────────────────────────────

    function setStatus(msg, type) {
        // type: 'info' | 'success' | 'error'
        if (!_opts.statusEl) return;
        const colors = {
            info: 'text-zinc-500',
            success: 'text-green-600 font-bold',
            error: 'text-red-600 font-bold'
        };
        _opts.statusEl.className = colors[type] || 'text-zinc-500';
        _opts.statusEl.textContent = msg;
    }

    /** Khoảng cách Euclidean giữa 2 descriptor 128 chiều. */
    function euclidean(a, b) {
        let sum = 0;
        for (let i = 0; i < a.length; i++) {
            const d = a[i] - b[i];
            sum += d * d;
        }
        return Math.sqrt(sum);
    }

    /** Khoảng cách tới mẫu đã đăng ký gần nhất. Không có mẫu → Infinity. */
    function minDistance(descriptor) {
        let best = Infinity;
        for (let i = 0; i < _enrolledSamples.length; i++) {
            const d = euclidean(_enrolledSamples[i], descriptor);
            if (d < best) best = d;
        }
        return best;
    }

    // ── Main detection loop ────────────────────────────────────────────────────

    async function detectionLoop() {
        if (!_intervalId) return;   // vòng đã bị dừng (timeout/stop/retry) — bỏ qua lần chạy trễ

        const video = _opts.videoEl;
        const detection = await faceapi
            .detectSingleFace(video, new faceapi.TinyFaceDetectorOptions({ inputSize: 320 }))
            .withFaceLandmarks(true)  // true = tiny landmark model
            .withFaceDescriptor();

        if (!_intervalId) return;   // vòng đã bị dừng trong lúc chờ detect — không ghi đè trạng thái

        if (!detection) {
            _streak = 0;
            _bestDistance = Infinity;
            _bestDetection = null;
            setStatus('Đưa khuôn mặt vào giữa khung hình', 'info');
            return;
        }

        const distance = minDistance(detection.descriptor);

        if (distance > _threshold) {
            _streak = 0;
            _bestDistance = Infinity;
            _bestDetection = null;
            setStatus('Đang nhận diện...', 'info');
            return;
        }

        // Frame đạt: giữ frame khớp nhất trong chuỗi để gửi lên server
        _streak++;
        if (distance < _bestDistance) {
            _bestDistance = distance;
            _bestDetection = detection;
        }
        setStatus('Đang nhận diện...', 'info');

        if (_streak >= REQUIRED_STREAK) {
            stopLoop();
            _capturedDescriptor = Array.from(_bestDetection.descriptor);
            _capturedSnapshot = captureSnapshot(video);
            setStatus('Đang gửi...', 'info');
            await submitToServer();
        }
    }

    /** Dừng vòng detect và bộ đếm timeout, nhưng giữ camera đang mở. */
    function stopLoop() {
        if (_intervalId) { clearInterval(_intervalId); _intervalId = null; }
        if (_timeoutId) { clearTimeout(_timeoutId); _timeoutId = null; }
    }

    function onTimeout() {
        stopLoop();
        stopCamera();
        setStatus('Chưa nhận ra bạn. Hãy đứng nơi đủ sáng, bỏ khẩu trang và thử lại.', 'error');
        if (_opts.onTimeout) _opts.onTimeout();
    }

    function captureSnapshot(video) {
        const canvas = document.createElement('canvas');
        canvas.width = video.videoWidth;
        canvas.height = video.videoHeight;
        canvas.getContext('2d').drawImage(video, 0, 0);
        // Nén xuống JPEG quality 0.7 để tiết kiệm bandwidth
        return canvas.toDataURL('image/jpeg', 0.7);
    }

    // ── Server submission ──────────────────────────────────────────────────────

    async function submitToServer() {
        const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content || '';
        const body = {
            token: _token,
            caLamViecId: _opts.caLamViecId,
            action: _opts.action,
            descriptor: _capturedDescriptor,
            snapshot: _capturedSnapshot,
            _csrf: csrfToken
        };

        try {
            const res = await fetch(_opts.contextPath + '/face/checkin', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json', 'X-Requested-With': 'XMLHttpRequest' },
                body: JSON.stringify(body)
            });
            const data = await res.json();
            if (data.success) {
                stopCamera();
                if (_opts.onSuccess) _opts.onSuccess(data);
            } else {
                stopCamera();
                setStatus('Lỗi: ' + (data.error || 'Nhận diện thất bại'), 'error');
                if (_opts.onError) _opts.onError(data.error);
            }
        } catch (e) {
            stopCamera();
            setStatus('Lỗi kết nối. Thử lại.', 'error');
            if (_opts.onError) _opts.onError(e.message);
        }
    }

    // ── Public API ─────────────────────────────────────────────────────────────

    async function init(opts) {
        _opts = opts;

        const modelUrl = (opts.contextPath || '') + '/assets/face-models';
        if (!_modelsLoaded) {
            setStatus('Đang tải model nhận diện...', 'info');
            await Promise.all([
                faceapi.nets.tinyFaceDetector.loadFromUri(modelUrl),
                faceapi.nets.faceLandmark68TinyNet.loadFromUri(modelUrl),
                faceapi.nets.faceRecognitionNet.loadFromUri(modelUrl)
            ]);
            _modelsLoaded = true;
        }

        // Lấy challenge từ server
        setStatus('Đang chuẩn bị...', 'info');
        const res = await fetch(
            opts.contextPath + '/face/challenge?caLamViecId=' + opts.caLamViecId + '&action=' + opts.action
        );
        const data = await res.json();
        _token = data.token;
        _enrolledSamples = data.descriptors || [];
        if (typeof data.threshold === 'number') _threshold = data.threshold;

        if (!_enrolledSamples.length) {
            setStatus('Bạn chưa được đăng ký khuôn mặt. Liên hệ quản lý để đăng ký.', 'error');
            if (_opts.onError) _opts.onError('Chưa đăng ký khuôn mặt');
            return false;
        }
        return true;
    }

    async function start() {
        stopCamera();   // dọn stream + timer của lần chạy trước (vd. bấm "Thử lại") trước khi mở lại

        _streak = 0;
        _bestDistance = Infinity;
        _bestDetection = null;

        try {
            _stream = await navigator.mediaDevices.getUserMedia({
                video: { width: 640, height: 480, facingMode: 'user' }
            });
        } catch (e) {
            setStatus('Không thể mở camera. Kiểm tra quyền truy cập camera và thử lại.', 'error');
            if (_opts.onError) _opts.onError(e.message);
            return;
        }
        _opts.videoEl.srcObject = _stream;
        await new Promise(function (resolve) { _opts.videoEl.onloadedmetadata = resolve; });
        await _opts.videoEl.play();

        setStatus('Đang nhận diện...', 'info');
        _intervalId = setInterval(detectionLoop, DETECTION_INTERVAL_MS);
        _timeoutId = setTimeout(onTimeout, TIMEOUT_MS);
    }

    function stopCamera() {
        stopLoop();
        if (_stream) { _stream.getTracks().forEach(function (t) { t.stop(); }); _stream = null; }
    }

    return { init: init, start: start, stop: stopCamera };
})();
