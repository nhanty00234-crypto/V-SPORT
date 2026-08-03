<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <title>Điểm danh ca | GUARD V-SPORT</title>
  <jsp:include page="/guard/common/guard_head.jsp"/>
  <script src="https://cdn.jsdelivr.net/npm/face-api.js@0.22.2/dist/face-api.min.js"></script>
  <style>
    /* Cùng bố cục với trang Lễ tân, chỉ đổi màu thương hiệu sang hồng của GUARD */
    .today-card {
      background: linear-gradient(135deg, #e11d48 0%, #9f1239 100%);
      border-radius: 16px; color: white;
      padding: 20px 24px; position: relative; overflow: hidden;
    }
    .today-card::before {
      content: ''; position: absolute; right: -20px; top: -20px;
      width: 120px; height: 120px; background: rgba(255,255,255,.08); border-radius: 50%;
    }
    .today-card::after {
      content: ''; position: absolute; right: 30px; bottom: -30px;
      width: 80px; height: 80px; background: rgba(255,255,255,.05); border-radius: 50%;
    }
    .week-days-row { display: flex; gap: 8px; overflow-x: auto; padding-bottom: 4px; }
    .week-days-row::-webkit-scrollbar { height: 4px; }
    .week-days-row::-webkit-scrollbar-thumb { background: #fecdd3; border-radius: 2px; }
    .week-day-col {
      flex: 1; min-width: 0; border: 1px solid #ffe4e6; border-radius: 12px;
      padding: 10px 8px; background: #fffbfb;
    }
    .week-day-col.today-col {
      border-color: #fecdd3; background: #fff1f2;
      box-shadow: 0 0 0 2px rgba(225,29,72,.12);
    }
    .shift-card {
      background: white; border: 1.5px solid #fecdd3;
      border-left: 4px solid #e11d48; border-radius: 10px;
      padding: 10px 10px 8px; margin-top: 6px; transition: box-shadow .15s;
    }
    .shift-card:hover { box-shadow: 0 2px 8px rgba(225,29,72,.12); }
    .shift-card.status-checkedin  { border-left-color: #d97706; border-color: #fde68a; }
    .shift-card.status-checkedout { border-left-color: #94a3b8; border-color: #e2e8f0; }
    .shift-card.status-cancelled  { border-left-color: #ef4444; border-color: #fee2e2; opacity: .7; }
    .shift-badge {
      display: inline-flex; align-items: center; gap: 4px;
      font-size: 10px; font-weight: 700; padding: 2px 8px; border-radius: 20px; white-space: nowrap;
    }
    .badge-published { background:#dbeafe; color:#1d4ed8; }
    .badge-confirmed { background:#d1fae5; color:#065f46; }
    .badge-checkedin { background:#fef3c7; color:#92400e; }
    .badge-checkedout{ background:#f1f5f9; color:#475569; }
    .badge-cancelled { background:#fee2e2; color:#991b1b; }
    .badge-draft     { background:#f4f4f5; color:#52525b; }
    .quick-action-btn {
      display: flex; flex-direction: column; align-items: center; gap: 6px;
      padding: 16px 12px; border-radius: 12px;
      background: white; border: 1px solid #ffe4e6;
      font-size: 12px; font-weight: 600; color: #be123c;
      cursor: pointer; text-decoration: none; transition: all .15s; text-align: center;
    }
    .quick-action-btn:hover {
      background: #fff1f2; border-color: #fecdd3;
      transform: translateY(-2px); box-shadow: 0 4px 12px rgba(225,29,72,.1);
    }
    .quick-action-btn i { font-size: 22px; }
    .note-box {
      background: #fffbfb; border: 1px solid #fecdd3; border-radius: 10px;
      padding: 12px 14px; font-size: 12px; color: #9f1239; line-height: 1.6;
    }
  </style>
</head>
<body class="text-zinc-900 min-h-screen">

<jsp:include page="/guard/common/sidebar.jsp"/>
<jsp:include page="/guard/common/header.jsp">
  <jsp:param name="pageTitle" value="Điểm danh ca làm việc"/>
  <jsp:param name="pageSubtitle" value="Vào ca / Kết thúc ca hôm nay"/>
</jsp:include>

<main class="lg:ml-[248px] mt-[60px] p-4 lg:p-6 flex flex-col gap-5">

  <!-- Ca hôm nay -->
  <div id="todaySection" class="hidden">
    <div class="today-card">
      <div class="flex items-start justify-between relative z-10">
        <div>
          <p class="text-xs font-bold uppercase tracking-widest opacity-75 mb-1">Ca hôm nay</p>
          <p id="todayShiftTime" class="text-2xl font-extrabold tracking-tight">--:-- – --:--</p>
          <p id="todayShiftName" class="text-sm opacity-85 mt-0.5"></p>
        </div>
        <div id="todayStatusBadge" class="bg-white/20 backdrop-blur-sm px-3 py-1.5 rounded-full text-xs font-bold"></div>
      </div>
      <div id="todayShiftNote" class="mt-3 text-xs opacity-75 relative z-10"></div>
      <div id="todayActionBtns" class="flex gap-2 mt-4 relative z-10 flex-wrap"></div>
    </div>
  </div>

  <div id="todayEmpty" class="hidden p-4 bg-rose-50/60 border border-rose-100 rounded-xl text-sm text-rose-700 flex items-center gap-3">
    <i class="ti ti-calendar-off text-[20px] text-rose-400 shrink-0"></i>
    <span>Hôm nay bạn không có ca làm việc nào được phân công.</span>
  </div>

  <!-- Lối tắt -->
  <div class="grid grid-cols-2 sm:grid-cols-3 gap-3">
    <button onclick="openTodayFaceModal()" class="quick-action-btn">
      <i class="ti ti-face-id"></i>Điểm danh
    </button>
    <a href="${pageContext.request.contextPath}/guard/bao-cao-su-co" class="quick-action-btn">
      <i class="ti ti-alert-triangle"></i>Báo cáo sự cố
    </a>
    <a href="${pageContext.request.contextPath}/guard/lich-su-su-co" class="quick-action-btn">
      <i class="ti ti-history"></i>Lịch sử sự cố
    </a>
  </div>

  <!-- Điều hướng tuần -->
  <div class="bg-white border border-rose-100 rounded-xl p-4 flex items-center justify-between">
    <button onclick="changeWeek(-1)" class="flex items-center gap-1.5 px-3 py-2 rounded-lg border border-rose-100 hover:bg-rose-50 text-rose-700 transition-colors text-sm font-medium">
      <i class="ti ti-chevron-left text-[16px]"></i>Tuần trước
    </button>
    <div class="text-center">
      <p class="text-sm font-bold text-rose-900" id="weekLabel">Tuần này</p>
      <p class="text-[10px] text-rose-400 font-semibold uppercase tracking-wider mt-0.5">Chỉ hiển thị ca của bạn</p>
    </div>
    <button onclick="changeWeek(1)" class="flex items-center gap-1.5 px-3 py-2 rounded-lg border border-rose-100 hover:bg-rose-50 text-rose-700 transition-colors text-sm font-medium">
      Tuần sau<i class="ti ti-chevron-right text-[16px]"></i>
    </button>
  </div>

  <!-- Lưới 7 ngày -->
  <div class="bg-white border border-rose-100 rounded-xl p-4">
    <div id="weekGrid" class="week-days-row"></div>
  </div>

  <!-- Lưu ý -->
  <div class="note-box flex items-start gap-3">
    <i class="ti ti-info-circle text-[18px] shrink-0 mt-0.5"></i>
    <div class="flex flex-col gap-1">
      <span class="font-bold text-rose-800">Lưu ý</span>
      <ul class="list-disc list-inside space-y-0.5 text-rose-700/90">
        <li>Lịch làm được cấu hình bởi quản lý chi nhánh.</li>
        <li>Điểm danh vào ca <b>chỉ bằng khuôn mặt</b>. Xác nhận lịch do quản lý thực hiện.</li>
        <li>Điểm danh vào ca mở <b>trước 15 phút</b> và đóng <b>60 phút</b> sau giờ bắt đầu ca.</li>
        <li>Quá hạn điểm danh hoặc camera gặp sự cố, liên hệ quản lý để được điểm danh hộ.</li>
        <li>Nếu có vấn đề, liên hệ quản lý trực tiếp.</li>
      </ul>
    </div>
  </div>
</main>

<!-- Cảnh báo khung giờ điểm danh -->
<div id="attendanceAlert" class="hidden fixed top-20 left-1/2 -translate-x-1/2 z-[70] max-w-md w-[calc(100%-2rem)]">
  <div class="bg-red-50 border border-red-200 text-red-700 rounded-xl px-4 py-3 shadow-lg flex items-start gap-2.5">
    <i class="ti ti-alert-circle text-[18px] shrink-0 mt-px"></i>
    <span data-alert-text class="text-sm font-semibold leading-snug"></span>
  </div>
</div>

<!-- Modal điểm danh khuôn mặt -->
<div id="faceModal" class="fixed inset-0 bg-black/70 z-[60] hidden items-center justify-center p-4">
  <div class="bg-white rounded-3xl shadow-2xl p-6 w-full max-w-sm flex flex-col items-center gap-4">
    <h3 class="font-black text-rose-900 text-lg" id="faceModalTitle">Điểm danh khuôn mặt</h3>

    <div class="relative w-full aspect-square bg-zinc-900 rounded-2xl overflow-hidden">
      <video id="faceVideo" class="w-full h-full object-cover scale-x-[-1]" autoplay muted playsinline></video>
    </div>

    <p id="faceStatus" class="text-zinc-600 text-sm text-center font-medium min-h-[2.5rem]">
      Đang khởi động camera...
    </p>

    <div class="w-full bg-zinc-100 rounded-full h-2">
      <div id="faceProgress" class="bg-rose-500 h-2 rounded-full transition-all duration-300" style="width:0%"></div>
    </div>

    <button type="button" id="faceRetryBtn" onclick="Attendance.retry()"
            class="w-full bg-rose-500 hover:bg-rose-600 text-white font-bold py-3 rounded-xl text-sm transition hidden">
      Thử lại
    </button>

    <button onclick="Attendance.closeModal()"
            class="w-full bg-zinc-100 hover:bg-zinc-200 text-zinc-700 font-semibold py-3 rounded-xl text-sm transition">
      Hủy
    </button>
  </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/face-attendance.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/attendance-shared.js"></script>
<script>
var _ctx = '${pageContext.request.contextPath}';
var _faceRequired = ${faceConfig != null ? faceConfig.faceRequired : true};
var shifts = [];
var weekOffset = 0;
var todayStr = Attendance.todayStr();

Attendance.initModal({ contextPath: _ctx });

// ── Trạng thái ──
function statusBadge(trangThai) {
  var map = {
    Draft:      { cls: 'badge-draft',      label: 'Chưa công bố' },
    Published:  { cls: 'badge-published',  label: 'Đã phân công' },
    Confirmed:  { cls: 'badge-confirmed',  label: 'Đã xác nhận' },
    CheckedIn:  { cls: 'badge-checkedin',  label: 'Đang làm việc' },
    CheckedOut: { cls: 'badge-checkedout', label: 'Đã kết thúc' },
    Cancelled:  { cls: 'badge-cancelled',  label: 'Đã hủy' }
  };
  var m = map[trangThai] || { cls: 'badge-draft', label: trangThai || '—' };
  return '<span class="shift-badge ' + m.cls + '">' + m.label + '</span>';
}

// ── Nút hành động trên thẻ ca ──
function buildShiftActionBtn(s) {
  if (!s.trangThai || s.trangThai === 'Cancelled' || s.trangThai === 'CheckedOut' || s.trangThai === 'Draft') {
    return '';
  }
  if (_faceRequired === false) {
    return '<div class="mt-2 w-full text-[10px] py-1.5 px-2 bg-amber-50 text-amber-700 font-semibold rounded-lg text-center leading-snug">'
         + 'Điểm danh khuôn mặt đang tắt — liên hệ quản lý</div>';
  }
  if (s.trangThai === 'CheckedIn') {
    return '<button type="button" onclick="Attendance.openModal(\'checkout\', ' + s.caLamViecId + ')"'
         + ' class="mt-2 w-full text-[11px] py-1.5 bg-red-600 hover:bg-red-700 text-white font-bold rounded-lg flex items-center justify-center gap-1">'
         + '<i class="ti ti-logout text-[13px]"></i>Kết thúc ca</button>';
  }
  var ready = Attendance.checkInWindow(s).ok;
  var cls = ready ? 'bg-green-600 hover:bg-green-700 text-white' : 'bg-zinc-100 hover:bg-zinc-200 text-zinc-500';
  return '<button type="button" onclick="tryCheckIn(' + s.caLamViecId + ')"'
       + ' class="mt-2 w-full text-[11px] py-1.5 font-bold rounded-lg flex items-center justify-center gap-1 ' + cls + '">'
       + '<i class="ti ti-face-id text-[13px]"></i>Điểm danh</button>';
}

function tryCheckIn(caId) {
  var s = shifts.find(function (x) { return x.caLamViecId === caId; });
  if (s) Attendance.tryCheckIn(s);
}

// ── Lưới tuần ──
function getMonday(offset) {
  var d = new Date();
  var day = d.getDay() === 0 ? 7 : d.getDay();
  d.setDate(d.getDate() - day + 1 + offset * 7);
  d.setHours(0, 0, 0, 0);
  return d;
}

function ymd(d) {
  return d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0') + '-' + String(d.getDate()).padStart(2, '0');
}

function changeWeek(delta) {
  weekOffset += delta;
  renderWeek();
}

function renderWeek() {
  var monday = getMonday(weekOffset);
  var names = ['THỨ 2', 'THỨ 3', 'THỨ 4', 'THỨ 5', 'THỨ 6', 'THỨ 7', 'CHỦ NHẬT'];
  var html = '';

  for (var i = 0; i < 7; i++) {
    var d = new Date(monday);
    d.setDate(monday.getDate() + i);
    var ds = ymd(d);
    var isToday = ds === todayStr;

    var dayShifts = shifts.filter(function (s) { return s.ngayLam === ds; })
                          .sort(function (a, b) { return (a.gioBatDau || '').localeCompare(b.gioBatDau || ''); });

    html += '<div class="week-day-col' + (isToday ? ' today-col' : '') + '">'
          + '<div class="text-center mb-1">'
          + '<p class="text-[10px] font-bold text-rose-400 tracking-wider">' + names[i] + '</p>'
          + '<p class="text-lg font-extrabold ' + (isToday ? 'text-rose-600' : 'text-zinc-700') + '">' + d.getDate() + '</p>'
          + '</div>';

    if (dayShifts.length === 0) {
      html += '<p class="text-center text-[11px] text-zinc-300 italic py-4">Nghỉ</p>';
    } else {
      dayShifts.forEach(function (s) {
        var statusCls = s.trangThai ? ' status-' + s.trangThai.toLowerCase() : '';
        html += '<div class="shift-card' + statusCls + '">'
              + statusBadge(s.trangThai)
              + '<p class="text-sm font-extrabold text-zinc-800 mt-1.5">'
              + Attendance.fmtTime(s.gioBatDau) + ' – ' + Attendance.fmtTime(s.gioKetThuc) + '</p>'
              + (s.tenCa ? '<p class="text-[11px] text-rose-600 font-semibold">' + s.tenCa + '</p>' : '')
              + (s.viTri ? '<p class="text-[11px] text-zinc-400">' + s.viTri + '</p>' : '')
              + (s.gioNghi ? '<p class="text-[10px] text-rose-400 mt-0.5">Nghỉ: ' + s.gioNghi + ' phút</p>' : '')
              + (s.faceVerified && s.faceConfidence != null
                  ? '<p class="text-[10px] text-green-600 font-bold mt-0.5">👁 ' + Math.round(s.faceConfidence) + '%</p>' : '')
              + buildShiftActionBtn(s)
              + '</div>';
      });
    }
    html += '</div>';
  }

  document.getElementById('weekGrid').innerHTML = html;

  var sunday = new Date(monday);
  sunday.setDate(monday.getDate() + 6);
  document.getElementById('weekLabel').textContent =
    weekOffset === 0 ? 'Tuần này'
      : (monday.getDate() + '/' + (monday.getMonth() + 1) + ' – ' + sunday.getDate() + '/' + (sunday.getMonth() + 1));
}

// ── Thẻ ca hôm nay ──
function renderTodayCard() {
  var todayShifts = shifts.filter(function (s) { return s.ngayLam === todayStr && s.trangThai !== 'Cancelled'; })
                          .sort(function (a, b) { return (a.gioBatDau || '').localeCompare(b.gioBatDau || ''); });

  var sec = document.getElementById('todaySection');
  var empty = document.getElementById('todayEmpty');

  if (todayShifts.length === 0) {
    sec.classList.add('hidden');
    empty.classList.remove('hidden');
    return;
  }
  sec.classList.remove('hidden');
  empty.classList.add('hidden');

  var s = todayShifts[0];
  document.getElementById('todayShiftTime').textContent =
    Attendance.fmtTime(s.gioBatDau) + ' – ' + Attendance.fmtTime(s.gioKetThuc);
  document.getElementById('todayShiftName').textContent =
    (s.tenCa || '') + (s.viTri ? ' · ' + s.viTri : '');
  document.getElementById('todayStatusBadge').innerHTML = statusBadge(s.trangThai);
  document.getElementById('todayShiftNote').textContent = s.ghiChu || '';

  var btns = document.getElementById('todayActionBtns');
  if (_faceRequired === false) {
    btns.innerHTML = '<div class="px-4 py-2 bg-white/20 text-white/90 rounded-lg text-xs font-semibold">'
                   + 'Điểm danh khuôn mặt đang tắt — liên hệ quản lý để điểm danh</div>';
  } else if (s.trangThai === 'CheckedIn') {
    btns.innerHTML = '<button type="button" onclick="Attendance.openModal(\'checkout\', ' + s.caLamViecId + ')"'
                   + ' class="px-4 py-2 bg-white text-red-700 rounded-lg text-xs font-bold hover:bg-red-50 transition-all">Kết thúc ca</button>';
  } else if (s.trangThai === 'CheckedOut') {
    btns.innerHTML = '<div class="px-4 py-2 bg-white/20 text-white/90 rounded-lg text-xs font-semibold">Ca đã hoàn thành</div>';
  } else {
    var ready = Attendance.checkInWindow(s).ok;
    btns.innerHTML = '<button type="button" onclick="tryCheckIn(' + s.caLamViecId + ')"'
                   + ' class="px-4 py-2 rounded-lg text-xs font-bold transition-all '
                   + (ready ? 'bg-white text-green-700 hover:bg-green-50' : 'bg-white/30 text-white/70 hover:bg-white/40')
                   + '">Điểm danh</button>';
  }
}

// ── Lối tắt "Điểm danh" ──
function openTodayFaceModal() {
  if (_faceRequired === false) {
    Attendance.alert('Điểm danh khuôn mặt đang tắt — liên hệ quản lý để được điểm danh hộ.');
    return;
  }
  var todayShifts = shifts.filter(function (s) { return s.ngayLam === todayStr && s.trangThai !== 'Cancelled'; })
                          .sort(function (a, b) { return (a.gioBatDau || '').localeCompare(b.gioBatDau || ''); });
  if (todayShifts.length === 0) {
    Attendance.alert('Hôm nay bạn không có ca làm việc nào được phân công.');
    return;
  }

  var inShift = todayShifts.find(function (s) { return s.trangThai === 'CheckedIn'; });
  if (inShift) { Attendance.openModal('checkout', inShift.caLamViecId); return; }

  var pending = todayShifts.find(function (s) { return s.trangThai !== 'CheckedOut'; });
  if (!pending) { Attendance.alert('Bạn đã hoàn thành tất cả ca hôm nay.'); return; }

  Attendance.tryCheckIn(pending);
}

// ── Nạp dữ liệu ──
async function loadData() {
  try {
    var res = await fetch(_ctx + '/guard/diem-danh?format=json');
    if (!res.ok) throw new Error('HTTP ' + res.status);
    var data = await res.json();
    shifts = data.shifts || [];
  } catch (e) {
    // Không nuốt lỗi: lưới trống vì lỗi tải khác hẳn lưới trống vì không có ca
    shifts = [];
    Attendance.alert('Không tải được lịch làm việc: ' + e.message + '. Thử tải lại trang.');
  }
  renderTodayCard();
  renderWeek();
}

document.addEventListener('DOMContentLoaded', loadData);
</script>

</body>
</html>
