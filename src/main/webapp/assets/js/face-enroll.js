'use strict';
let _enrollStream = null;
let _enrollDescriptor = null;
let _enrollSnapshot = null;
let _modelsLoaded = false;

async function startEnroll() {
    const statusEl = document.getElementById('enrollStatus');
    const video = document.getElementById('enrollVideo');
    statusEl.textContent = 'Đang tải model nhận diện...';

    if (!_modelsLoaded) {
        await Promise.all([
            faceapi.nets.tinyFaceDetector.loadFromUri(MODEL_URL),
            faceapi.nets.faceLandmark68TinyNet.loadFromUri(MODEL_URL),
            faceapi.nets.faceRecognitionNet.loadFromUri(MODEL_URL)
        ]);
        _modelsLoaded = true;
    }

    _enrollStream = await navigator.mediaDevices.getUserMedia({ video: { width: 640, height: 480, facingMode: 'user' } });
    video.srcObject = _enrollStream;
    await new Promise(r => { video.onloadedmetadata = r; });
    await video.play();

    statusEl.textContent = 'Nhìn thẳng vào camera và giữ yên...';

    // Capture sau 2s (đủ thời gian ổn định)
    setTimeout(async () => {
        statusEl.textContent = 'Đang phân tích khuôn mặt...';
        const detection = await faceapi
            .detectSingleFace(video, new faceapi.TinyFaceDetectorOptions({ inputSize: 320 }))
            .withFaceLandmarks(true)
            .withFaceDescriptor();

        if (!detection) {
            statusEl.textContent = 'Không tìm thấy khuôn mặt. Thử lại với ánh sáng tốt hơn.';
            return;
        }

        _enrollDescriptor = Array.from(detection.descriptor);

        // Capture snapshot
        const canvas = document.getElementById('enrollCanvas');
        canvas.width = video.videoWidth;
        canvas.height = video.videoHeight;
        canvas.getContext('2d').drawImage(video, 0, 0);
        _enrollSnapshot = canvas.toDataURL('image/jpeg', 0.8);

        // Preview
        document.getElementById('enrollPreviewImg').src = _enrollSnapshot;
        document.getElementById('enrollPreview').classList.remove('hidden');

        statusEl.textContent = '✓ Đã nhận diện khuôn mặt. Nhấn "Lưu khuôn mặt" để xác nhận.';
        statusEl.className = 'text-green-600 font-bold text-sm text-center';
        document.getElementById('btnSave').disabled = false;

        // Dừng camera
        if (_enrollStream) { _enrollStream.getTracks().forEach(t => t.stop()); _enrollStream = null; }
    }, 2000);
}

async function saveEnroll() {
    if (!_enrollDescriptor) return;
    const statusEl = document.getElementById('enrollStatus');
    statusEl.textContent = 'Đang lưu...';

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content || '';
    const res = await fetch(CONTEXT_PATH + '/face/enroll', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ descriptor: _enrollDescriptor, photo: _enrollSnapshot, _csrf: csrfToken })
    });
    const data = await res.json();
    if (data.success) {
        statusEl.textContent = '✓ Đăng ký khuôn mặt thành công!';
        statusEl.className = 'text-green-600 font-bold text-sm text-center';
        document.getElementById('btnSave').disabled = true;
    } else {
        statusEl.textContent = 'Lỗi: ' + (data.error || 'Không thể lưu');
        statusEl.className = 'text-red-600 font-bold text-sm text-center';
    }
}
