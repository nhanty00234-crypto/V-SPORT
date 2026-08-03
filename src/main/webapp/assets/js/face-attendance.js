'use strict';

window.FaceAttendance = (function () {
    const EAR_THRESHOLD = 0.25;   // Eye Aspect Ratio để detect chớp mắt
    const BLINK_FRAMES = 2;        // Số frame liên tiếp EAR < threshold = chớp mắt
    const TURN_RATIO = 0.20;       // Nose dịch > 20% face width = quay đầu
    const TURN_FRAMES = 3;
    const SMILE_MOUTH_RATIO = 0.45; // mouth_width / face_width để detect cười
    const DETECTION_INTERVAL_MS = 100; // 10fps

    let _opts = {};
    let _stream = null;
    let _intervalId = null;
    let _token = null;
    let _challenges = [];
    let _currentChallengeIdx = 0;
    let _challengePassedFrames = 0;
    let _capturedDescriptor = null;
    let _capturedSnapshot = null;
    let _modelsLoaded = false;
    let _enrolledDescriptor = null;  // descriptor đã đăng ký, để tính % khớp tại chỗ
    let _threshold = 0.6;            // khoảng cách Euclidean tối đa được duyệt
    let _maxDistance = 0.8;
    let _requiredPercent = 25;

    // ── Utilities ──────────────────────────────────────────────────────────────

    function dist(p1, p2) {
        return Math.sqrt(Math.pow(p1.x - p2.x, 2) + Math.pow(p1.y - p2.y, 2));
    }

    function eyeAspectRatio(eyePts) {
        // eyePts: 6 điểm [p0..p5], p0=góc trái, p3=góc phải
        const vertical1 = dist(eyePts[1], eyePts[5]);
        const vertical2 = dist(eyePts[2], eyePts[4]);
        const horizontal = dist(eyePts[0], eyePts[3]);
        return (vertical1 + vertical2) / (2.0 * horizontal);
    }

    function setStatus(msg, type) {
        // type: 'info' | 'success' | 'error' | 'challenge'
        if (!_opts.statusEl) return;
        const colors = {
            info: 'text-zinc-500',
            success: 'text-green-600 font-bold',
            error: 'text-red-600 font-bold',
            challenge: 'text-rose-700 font-bold text-lg'
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

    function toPercent(distance) {
        const pct = (1 - distance / _maxDistance) * 100;
        return Math.round(Math.max(0, Math.min(100, pct)));
    }

    /** Cập nhật thanh % khớp; trả về true nếu khuôn mặt đạt ngưỡng của cơ sở. */
    function updateMatch(descriptor) {
        if (!_enrolledDescriptor) return true;   // chưa đăng ký -> để server quyết định
        const distance = euclidean(_enrolledDescriptor, descriptor);
        const percent = toPercent(distance);
        const ok = distance <= _threshold;

        if (_opts.matchEl) {
            _opts.matchEl.textContent = percent + '%';
            _opts.matchEl.className = ok
                ? 'text-green-600 font-black text-lg'
                : 'text-amber-500 font-black text-lg';
        }
        if (_opts.matchBarEl) {
            _opts.matchBarEl.style.width = percent + '%';
            _opts.matchBarEl.style.background = ok ? '#16a34a' : '#f59e0b';
        }
        if (_opts.matchHintEl) {
            _opts.matchHintEl.textContent = ok
                ? 'Đã khớp (cần ≥ ' + _requiredPercent + '%)'
                : 'Chưa đủ khớp — cần ≥ ' + _requiredPercent + '%';
        }
        return ok;
    }

    const CHALLENGE_LABELS = {
        blink: '👁 CHỚP MẮT',
        turn_left: '← QUAY ĐẦU TRÁI',
        turn_right: 'QUAY ĐẦU PHẢI →',
        smile: '😊 MỈM CƯỜI'
    };

    // ── Challenge detection ────────────────────────────────────────────────────

    function detectChallenge(challenge, landmarks, box) {
        const leftEye = landmarks.getLeftEye();
        const rightEye = landmarks.getRightEye();
        const nose = landmarks.getNose();
        const mouth = landmarks.getMouth();

        switch (challenge) {
            case 'blink': {
                const earLeft = eyeAspectRatio(leftEye);
                const earRight = eyeAspectRatio(rightEye);
                return (earLeft + earRight) / 2 < EAR_THRESHOLD;
            }
            case 'turn_left': {
                const noseTip = nose[3]; // điểm 30 trong 68-landmark
                const faceCenter = { x: box.x + box.width / 2, y: box.y + box.height / 2 };
                const shift = (faceCenter.x - noseTip.x) / box.width;
                return shift > TURN_RATIO;
            }
            case 'turn_right': {
                const noseTip = nose[3];
                const faceCenter = { x: box.x + box.width / 2, y: box.y + box.height / 2 };
                const shift = (noseTip.x - faceCenter.x) / box.width;
                return shift > TURN_RATIO;
            }
            case 'smile': {
                const mouthLeft = mouth[0];
                const mouthRight = mouth[6];
                const mouthWidth = dist(mouthLeft, mouthRight);
                return mouthWidth / box.width > SMILE_MOUTH_RATIO;
            }
            default:
                return false;
        }
    }

    // ── Main detection loop ────────────────────────────────────────────────────

    async function detectionLoop() {
        const video = _opts.videoEl;
        const detection = await faceapi
            .detectSingleFace(video, new faceapi.TinyFaceDetectorOptions({ inputSize: 320 }))
            .withFaceLandmarks(true)  // true = tiny landmark model
            .withFaceDescriptor();

        if (!detection) {
            setStatus('Không tìm thấy khuôn mặt. Hãy nhìn thẳng vào camera.', 'info');
            _challengePassedFrames = 0;
            if (_opts.matchEl) _opts.matchEl.textContent = '--%';
            if (_opts.matchBarEl) _opts.matchBarEl.style.width = '0%';
            return;
        }

        const box = detection.detection.box;
        const landmarks = detection.landmarks;
        const matched = updateMatch(detection.descriptor);
        const currentChallenge = _challenges[_currentChallengeIdx];
        const passed = matched && detectChallenge(currentChallenge, landmarks, box);

        if (passed) {
            _challengePassedFrames++;
            const required = currentChallenge === 'blink' ? BLINK_FRAMES : TURN_FRAMES;
            if (_challengePassedFrames >= required) {
                _challengePassedFrames = 0;
                _currentChallengeIdx++;

                if (_currentChallengeIdx >= _challenges.length) {
                    // Tất cả challenge passed — capture descriptor + snapshot
                    clearInterval(_intervalId);
                    _intervalId = null;
                    _capturedDescriptor = Array.from(detection.descriptor);
                    _capturedSnapshot = captureSnapshot(video);
                    setStatus('✓ Xác minh thành công! Đang gửi...', 'success');
                    await submitToServer();
                } else {
                    setStatus(CHALLENGE_LABELS[_challenges[_currentChallengeIdx]], 'challenge');
                }
            }
        } else {
            _challengePassedFrames = 0;
            setStatus(matched
                ? CHALLENGE_LABELS[currentChallenge]
                : 'Chưa nhận ra bạn — đưa mặt vào giữa khung, đủ sáng', matched ? 'challenge' : 'info');
        }
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
                setStatus('Lỗi: ' + (data.error || 'Nhận diện thất bại'), 'error');
                if (_opts.onError) _opts.onError(data.error);
            }
        } catch (e) {
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
        _challenges = data.challenges;
        _currentChallengeIdx = 0;
        _challengePassedFrames = 0;
        _enrolledDescriptor = data.descriptor || null;
        if (typeof data.threshold === 'number') _threshold = data.threshold;
        if (typeof data.maxDistance === 'number') _maxDistance = data.maxDistance;
        if (typeof data.requiredPercent === 'number') _requiredPercent = data.requiredPercent;

        if (!_enrolledDescriptor) {
            setStatus('Bạn chưa được đăng ký khuôn mặt. Liên hệ quản lý để đăng ký.', 'error');
            if (_opts.onError) _opts.onError('Chưa đăng ký khuôn mặt');
            return false;
        }
        return true;
    }

    async function start() {
        // Bật camera
        _stream = await navigator.mediaDevices.getUserMedia({
            video: { width: 640, height: 480, facingMode: 'user' }
        });
        _opts.videoEl.srcObject = _stream;
        await new Promise(function (resolve) { _opts.videoEl.onloadedmetadata = resolve; });
        await _opts.videoEl.play();

        setStatus(CHALLENGE_LABELS[_challenges[0]], 'challenge');
        _intervalId = setInterval(detectionLoop, DETECTION_INTERVAL_MS);
    }

    function stopCamera() {
        if (_intervalId) { clearInterval(_intervalId); _intervalId = null; }
        if (_stream) { _stream.getTracks().forEach(function (t) { t.stop(); }); _stream = null; }
    }

    return { init: init, start: start, stop: stopCamera };
})();
