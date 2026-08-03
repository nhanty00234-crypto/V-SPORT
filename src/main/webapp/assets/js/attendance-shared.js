'use strict';
/**
 * Logic điểm danh dùng chung cho Lễ tân (/staff/ca-lam) và Bảo vệ (/guard/diem-danh).
 * Hai trang khác nhau về màu thương hiệu nhưng luật điểm danh phải giống hệt nhau,
 * nên mọi ràng buộc thời gian và luồng camera đều nằm ở đây.
 *
 * Giá trị phải khớp org.example.util.AttendanceWindow — server mới là chốt chặn thật,
 * phần này chỉ để người dùng biết trước vì sao chưa bấm được.
 */
window.Attendance = (function () {

  var OPEN_BEFORE = 15;   // mở điểm danh sớm 15 phút trước giờ vào ca
  var CLOSE_AFTER = 60;   // đóng sau 60 phút kể từ giờ vào ca

  function todayStr() {
    var d = new Date();
    return d.getFullYear() + '-'
      + String(d.getMonth() + 1).padStart(2, '0') + '-'
      + String(d.getDate()).padStart(2, '0');
  }

  function parseMinutes(hhmmss) {
    if (!hhmmss) return -1;
    var p = hhmmss.split(':');
    return parseInt(p[0], 10) * 60 + parseInt(p[1], 10);
  }

  function fmtMin(total) {
    var t = ((total % 1440) + 1440) % 1440;
    return String(Math.floor(t / 60)).padStart(2, '0') + ':' + String(t % 60).padStart(2, '0');
  }

  function fmtTime(hhmmss) {
    return hhmmss ? hhmmss.substring(0, 5) : '--:--';
  }

  /** Ca có đang trong khung giờ điểm danh vào ca không. */
  function checkInWindow(s) {
    if (!s) return { ok: false, reason: 'Không tìm thấy ca làm việc.' };
    if (s.ngayLam !== todayStr()) {
      var d = String(s.ngayLam).split('-');
      return { ok: false, reason: 'Chưa đến ngày làm việc của bạn — ca này vào ngày '
               + d[2] + '/' + d[1] + '/' + d[0] + '.' };
    }
    var startMin = parseMinutes(s.gioBatDau);
    var now = new Date();
    var nowMin = now.getHours() * 60 + now.getMinutes();

    if (nowMin < startMin - OPEN_BEFORE) {
      return { ok: false, reason: 'Chưa đến giờ điểm danh — mở lúc ' + fmtMin(startMin - OPEN_BEFORE)
               + ' (trước giờ vào ca ' + OPEN_BEFORE + ' phút).' };
    }
    if (nowMin > startMin + CLOSE_AFTER) {
      return { ok: false, reason: 'Đã quá giờ điểm danh — hạn cuối là ' + fmtMin(startMin + CLOSE_AFTER)
               + '. Liên hệ quản lý để được điểm danh hộ.' };
    }
    return { ok: true };
  }

  /** Banner đỏ nổi giữa màn hình, tự ẩn sau 4s. Cần một #attendanceAlert trong trang. */
  function alert(msg) {
    var box = document.getElementById('attendanceAlert');
    if (!box) { window.alert(msg); return; }
    box.querySelector('[data-alert-text]').textContent = msg;
    box.classList.remove('hidden');
    clearTimeout(box._t);
    box._t = setTimeout(function () { box.classList.add('hidden'); }, 4000);
  }

  // ── Modal camera ──────────────────────────────────────────────────────────
  var _cfg = null;

  /**
   * @param cfg.contextPath  context path của ứng dụng
   * @param cfg.accent       màu nhấn cho thanh tiến trình (hex)
   */
  function initModal(cfg) { _cfg = cfg; }

  function el(id) { return document.getElementById(id); }

  function resetGauge() {
    if (el('faceProgress')) el('faceProgress').style.width = '0%';
    if (el('faceRetryBtn')) el('faceRetryBtn').classList.add('hidden');
  }

  function showRetry() {
    if (el('faceRetryBtn')) el('faceRetryBtn').classList.remove('hidden');
  }

  var _lastAction = null;
  var _lastCaId = null;

  function openModal(action, caId) {
    var modal = el('faceModal');
    modal.classList.remove('hidden');
    modal.classList.add('flex');
    el('faceModalTitle').textContent =
      action === 'checkin' ? 'Điểm danh VÀO CA' : 'Điểm danh KẾT THÚC CA';
    start(action, caId);
  }

  function closeModal() {
    FaceAttendance.stop();
    var modal = el('faceModal');
    modal.classList.add('hidden');
    modal.classList.remove('flex');
    resetGauge();
  }

  async function start(action, caId) {
    var statusEl = el('faceStatus');
    var progressEl = el('faceProgress');
    resetGauge();
    _lastAction = action;
    _lastCaId = caId;

    var ready = await FaceAttendance.init({
      videoEl: el('faceVideo'),
      statusEl: statusEl,
      contextPath: _cfg.contextPath,
      caLamViecId: caId,
      action: action,
      onSuccess: function (data) {
        progressEl.style.width = '100%';
        statusEl.textContent = '✓ Thành công! Độ khớp: ' + data.confidence.toFixed(1) + '%';
        statusEl.className = 'text-green-600 font-bold text-sm text-center';
        setTimeout(function () { closeModal(); location.reload(); }, 1500);
      },
      onError: function (msg) {
        statusEl.textContent = '✗ ' + (msg || 'Lỗi nhận diện');
        statusEl.className = 'text-red-600 font-bold text-sm text-center';
        showRetry();
      },
      onTimeout: function () {
        showRetry();
      }
    });

    if (ready === false) return;   // chưa đăng ký khuôn mặt — không mở camera
    await FaceAttendance.start();
  }

  /** Chạy lại phiên điểm danh hiện tại sau khi hết giờ hoặc lỗi. */
  function retry() {
    if (_lastAction === null || _lastCaId === null) return;
    start(_lastAction, _lastCaId);
  }

  /** Bấm "Điểm danh" trên một ca: kiểm tra khung giờ rồi mới mở camera. */
  function tryCheckIn(shift) {
    var w = checkInWindow(shift);
    if (!w.ok) { alert(w.reason); return; }
    openModal('checkin', shift.caLamViecId);
  }

  return {
    OPEN_BEFORE: OPEN_BEFORE,
    CLOSE_AFTER: CLOSE_AFTER,
    todayStr: todayStr,
    parseMinutes: parseMinutes,
    fmtMin: fmtMin,
    fmtTime: fmtTime,
    checkInWindow: checkInWindow,
    alert: alert,
    initModal: initModal,
    openModal: openModal,
    closeModal: closeModal,
    tryCheckIn: tryCheckIn,
    retry: retry
  };
})();
