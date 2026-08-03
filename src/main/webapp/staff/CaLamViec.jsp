<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
<title>Lịch làm của tôi — V-SPORT</title>
<jsp:include page="/staff/common/staff_head.jsp" />
<script src="https://cdn.jsdelivr.net/npm/face-api.js@0.22.2/dist/face-api.min.js"></script>
<style>
  .tab-btn {
    display: flex; align-items: center; gap: 8px;
    padding: 8px 16px; border-radius: 8px;
    background: #f4f4f5; color: #52525b;
    font-size: 13px; font-weight: 500;
    border: none; cursor: pointer; transition: all .2s;
  }
  .tab-btn:hover { background: #e4e4e7; color: #18181b; }
  .tab-btn.active {
    background: #ea580c; color: white;
    box-shadow: 0 4px 6px -1px rgba(234,88,12,.3);
  }

  /* trangThai badge mapping */
  .badge-draft     { background:#f4f4f5; color:#52525b; }
  .badge-published { background:#dbeafe; color:#1d4ed8; }
  .badge-confirmed { background:#d1fae5; color:#065f46; }
  .badge-checkedin { background:#fef3c7; color:#92400e; }
  .badge-checkedout{ background:#f1f5f9; color:#475569; }
  .badge-cancelled { background:#fee2e2; color:#991b1b; }

  .shift-badge {
    display: inline-flex; align-items: center; gap: 4px;
    font-size: 10px; font-weight: 700; padding: 2px 8px;
    border-radius: 20px; white-space: nowrap;
  }

  /* Today card */
  .today-card {
    background: linear-gradient(135deg, #ea580c 0%, #dc2626 100%);
    border-radius: 16px; color: white;
    padding: 20px 24px; position: relative; overflow: hidden;
  }
  .today-card::before {
    content: ''; position: absolute; right: -20px; top: -20px;
    width: 120px; height: 120px;
    background: rgba(255,255,255,.08); border-radius: 50%;
  }
  .today-card::after {
    content: ''; position: absolute; right: 30px; bottom: -30px;
    width: 80px; height: 80px;
    background: rgba(255,255,255,.05); border-radius: 50%;
  }

  .week-day-col {
    flex: 1; min-width: 0;
    border: 1px solid #ffedd5; border-radius: 12px;
    padding: 10px 8px;
    background: #fffbf7;
  }
  .week-day-col.today-col {
    border-color: #fed7aa; background: #fff7ed;
    box-shadow: 0 0 0 2px rgba(234,88,12,.12);
  }
  .week-days-row {
    display: flex; gap: 8px; overflow-x: auto;
    padding-bottom: 4px;
  }
  .week-days-row::-webkit-scrollbar { height: 4px; }
  .week-days-row::-webkit-scrollbar-thumb { background: #fed7aa; border-radius: 2px; }

  .shift-card {
    background: white; border: 1.5px solid #fed7aa;
    border-left: 4px solid #ea580c; border-radius: 10px;
    padding: 10px 10px 8px; margin-top: 6px;
    transition: box-shadow .15s;
  }
  .shift-card:hover { box-shadow: 0 2px 8px rgba(234,88,12,.12); }
  .shift-card.status-checkedin { border-left-color: #d97706; border-color: #fde68a; }
  .shift-card.status-checkedout { border-left-color: #94a3b8; border-color: #e2e8f0; }
  .shift-card.status-cancelled { border-left-color: #ef4444; border-color: #fee2e2; opacity: .7; }

  /* Quick actions */
  .quick-action-btn {
    display: flex; flex-direction: column; align-items: center; gap: 6px;
    padding: 16px 12px; border-radius: 12px;
    background: white; border: 1px solid #ffedd5;
    font-size: 12px; font-weight: 600; color: #c2410c;
    cursor: pointer; text-decoration: none; transition: all .15s;
    text-align: center;
  }
  .quick-action-btn:hover { background: #fff7ed; border-color: #fed7aa; transform: translateY(-2px); box-shadow: 0 4px 12px rgba(234,88,12,.1); }
  .quick-action-btn.disabled { color: #94a3b8; border-color: #e2e8f0; cursor: not-allowed; pointer-events: none; }
  .quick-action-btn i { font-size: 22px; }

  .note-box {
    background: #fffbf7; border: 1px solid #fed7aa;
    border-radius: 10px; padding: 12px 14px;
    font-size: 12px; color: #92400e; line-height: 1.6;
  }
</style>
</head>
<body class="text-zinc-900 min-h-screen">

<jsp:include page="/staff/common/sidebar.jsp" />

<jsp:include page="/staff/common/header.jsp">
  <jsp:param name="pageTitle" value="Lịch làm của tôi"/>
  <jsp:param name="pageSubtitle" value="Nhân viên · Cơ sở CS${sessionScope.user.coSoId}"/>
</jsp:include>

<main class="lg:ml-[248px] mt-[64px] p-4 lg:p-6 flex flex-col gap-5">

  <!-- Alert Messages -->
  <c:if test="${not empty sessionScope.error}">
    <div class="p-4 bg-red-50 border border-red-100 rounded-xl text-red-600 text-sm flex items-start gap-3">
      <i class="ti ti-alert-circle text-[20px] shrink-0 mt-0.5"></i>
      <div class="flex-1"><span class="font-bold block">Lỗi thực hiện</span><span class="text-red-600/90">${sessionScope.error}</span></div>
      <button onclick="this.parentElement.remove()" class="text-red-400 hover:text-red-700"><i class="ti ti-x text-[16px]"></i></button>
    </div>
    <% session.removeAttribute("error"); %>
  </c:if>
  <c:if test="${not empty sessionScope.message}">
    <div class="p-4 bg-orange-50 border border-orange-100 rounded-xl text-orange-700 text-sm flex items-start gap-3">
      <i class="ti ti-circle-check text-[20px] shrink-0 mt-0.5"></i>
      <div class="flex-1"><span class="font-bold block">Thành công</span><span>${sessionScope.message}</span></div>
      <button onclick="this.parentElement.remove()" class="text-orange-400 hover:text-orange-700"><i class="ti ti-x text-[16px]"></i></button>
    </div>
    <% session.removeAttribute("message"); %>
  </c:if>

  <!-- ── Tabs ── -->
  <div class="flex gap-2">
    <button onclick="switchTab('schedule')" id="tab-schedule" class="tab-btn active">
      <i class="ti ti-calendar-week text-[16px]"></i>Lịch làm việc
    </button>
    <button onclick="switchTab('swaps')" id="tab-swaps" class="tab-btn">
      <i class="ti ti-arrows-exchange text-[16px]"></i>Yêu cầu đổi ca
      <span id="swapBadge" class="hidden bg-red-500 text-white text-[9px] font-bold px-1.5 py-0.5 rounded-full">0</span>
    </button>
  </div>

  <!-- ════════════════ TAB: LỊCH LÀM ════════════════ -->
  <div id="section-schedule" class="flex flex-col gap-4">

    <!-- Ca hôm nay -->
    <div id="todaySection" class="hidden">
      <div class="today-card reveal d0">
        <div class="flex items-start justify-between relative z-10">
          <div>
            <p class="text-xs font-bold uppercase tracking-widest opacity-75 mb-1">Ca hôm nay</p>
            <p id="todayShiftTime" class="text-2xl font-extrabold tracking-tight">--:-- – --:--</p>
            <p id="todayShiftName" class="text-sm opacity-85 mt-0.5"></p>
          </div>
          <div id="todayStatusBadge" class="bg-white/20 backdrop-blur-sm px-3 py-1.5 rounded-full text-xs font-bold"></div>
        </div>
        <div id="todayShiftNote" class="mt-3 text-xs opacity-75 relative z-10"></div>
        <div id="todayActionBtns" class="flex gap-2 mt-4 relative z-10"></div>
      </div>
    </div>

    <!-- Empty today -->
    <div id="todayEmpty" class="hidden p-4 bg-orange-50/60 border border-orange-100 rounded-xl text-sm text-orange-700 flex items-center gap-3">
      <i class="ti ti-calendar-off text-[20px] text-orange-400 shrink-0"></i>
      <span>Hôm nay bạn không có ca làm việc nào được phân công.</span>
    </div>

    <!-- Quick actions -->
    <div class="grid grid-cols-2 sm:grid-cols-4 gap-3 reveal d1">
      <a href="${pageContext.request.contextPath}/staff/yeu-cau-nghi" class="quick-action-btn">
        <i class="ti ti-file-time"></i>Đăng ký nghỉ phép
      </a>
      <a href="${pageContext.request.contextPath}/staff/checkin" class="quick-action-btn">
        <i class="ti ti-door-enter"></i>Check-in sân
      </a>
      <button onclick="switchTab('swaps')" class="quick-action-btn">
        <i class="ti ti-arrows-exchange"></i>Yêu cầu đổi ca
      </button>
      <button onclick="openTodayFaceModal()" class="quick-action-btn" id="btnQuickFace">
        <i class="ti ti-face-id"></i>Điểm danh
      </button>
    </div>

    <!-- Week navigation -->
    <div class="bg-white border border-orange-100 rounded-xl p-4 flex items-center justify-between reveal d2">
      <button onclick="changeWeek(-1)" class="flex items-center gap-1.5 px-3 py-2 rounded-lg border border-orange-100 hover:bg-orange-50 text-orange-700 transition-colors text-sm font-medium">
        <i class="ti ti-chevron-left text-[16px]"></i>Tuần trước
      </button>
      <div class="text-center">
        <p class="text-sm font-bold text-orange-900" id="weekLabel">Tuần này</p>
        <p class="text-[10px] text-orange-400 font-semibold uppercase tracking-wider mt-0.5">Chỉ hiển thị ca của bạn</p>
      </div>
      <button onclick="changeWeek(1)" class="flex items-center gap-1.5 px-3 py-2 rounded-lg border border-orange-100 hover:bg-orange-50 text-orange-700 transition-colors text-sm font-medium">
        Tuần sau<i class="ti ti-chevron-right text-[16px]"></i>
      </button>
    </div>

    <!-- Week calendar -->
    <div class="bg-white border border-orange-100 rounded-xl p-4 reveal d3">
      <div id="calendarGrid" class="week-days-row min-h-[320px]">
        <div class="flex items-center justify-center w-full text-zinc-400 text-sm italic">Đang tải lịch...</div>
      </div>
    </div>

    <!-- Notes -->
    <div class="note-box reveal d4 flex gap-3">
      <i class="ti ti-info-circle text-[18px] text-orange-400 shrink-0 mt-0.5"></i>
      <div class="flex flex-col gap-1">
        <span class="font-bold text-orange-800">Lưu ý</span>
        <ul class="list-disc list-inside space-y-0.5 text-orange-700/90">
          <li>Lịch làm được cấu hình bởi quản lý chi nhánh.</li>
          <li>Vui lòng xác nhận lịch làm trước ngày làm việc.</li>
          <li>Điểm danh vào ca trong vòng ±30 phút kể từ giờ bắt đầu ca.</li>
          <li>Để đổi ca, hãy dùng tab <strong>Yêu cầu đổi ca</strong>.</li>
          <li>Nếu có vấn đề, liên hệ quản lý trực tiếp.</li>
        </ul>
      </div>
    </div>
  </div>

  <!-- ════════════════ TAB: ĐỔI CA ════════════════ -->
  <div id="section-swaps" class="hidden grid grid-cols-1 lg:grid-cols-3 gap-5">
    <!-- Form -->
    <div class="bg-white border border-orange-100 rounded-xl p-5 h-fit">
      <h3 class="text-sm font-bold text-orange-950 flex items-center gap-2 mb-4 pb-2 border-b border-orange-50">
        <i class="ti ti-arrows-exchange text-orange-600 text-[18px]"></i>Gửi yêu cầu đổi ca
      </h3>
      <form action="${pageContext.request.contextPath}/staff/ca-lam" method="POST" class="flex flex-col gap-4">
        <input type="hidden" name="action" value="requestSwap">
        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-semibold text-orange-900">Ca của bạn <span class="text-red-500">*</span></label>
          <select name="caLamViecIdGui" id="swapMyShifts" required
                  class="h-10 px-3.5 rounded-xl border border-orange-100 text-sm focus:ring-2 focus:ring-orange-400 focus:outline-none bg-white">
            <option value="">-- Chọn ca của bạn --</option>
          </select>
        </div>
        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-semibold text-orange-900">Đồng nghiệp <span class="text-red-500">*</span></label>
          <select name="accountIdNhan" id="swapCoworkers" required
                  class="h-10 px-3.5 rounded-xl border border-orange-100 text-sm focus:ring-2 focus:ring-orange-400 focus:outline-none bg-white">
            <option value="">-- Chọn đồng nghiệp --</option>
          </select>
        </div>
        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-semibold text-orange-900">Lý do <span class="text-red-500">*</span></label>
          <input type="text" name="lyDo" required placeholder="Có việc bận đột xuất..."
                 class="h-10 px-3.5 rounded-xl border border-orange-100 text-sm focus:ring-2 focus:ring-orange-400 focus:outline-none">
        </div>
        <button type="submit" class="w-full h-10 rounded-xl bg-orange-600 hover:bg-orange-700 text-white text-sm font-semibold transition-all shadow-md shadow-orange-100">
          Gửi yêu cầu
        </button>
      </form>
    </div>

    <!-- List -->
    <div class="bg-white border border-orange-100 rounded-xl p-5 lg:col-span-2 flex flex-col gap-4">
      <div class="flex flex-col sm:flex-row sm:items-center justify-between border-b border-orange-50 pb-3 gap-2">
        <h3 class="text-sm font-bold text-orange-950 flex items-center gap-2">
          <i class="ti ti-list text-orange-600 text-[18px]"></i>Quản lý yêu cầu đổi ca
        </h3>
        <div class="flex gap-1.5" id="swapSubTabs">
          <button onclick="switchSwapTab('received')" id="subtab-received" class="px-3 py-1.5 rounded-lg text-xs font-semibold bg-orange-600 text-white flex items-center gap-1">
            Cần xác nhận<span id="receivedBadge" class="hidden bg-red-500 text-white text-[9px] font-bold px-1.5 py-0.5 rounded-full">0</span>
          </button>
          <button onclick="switchSwapTab('sent')" id="subtab-sent" class="px-3 py-1.5 rounded-lg text-xs font-semibold bg-zinc-100 text-zinc-600 hover:bg-zinc-200">
            Tôi đã gửi
          </button>
          <button onclick="switchSwapTab('history')" id="subtab-history" class="px-3 py-1.5 rounded-lg text-xs font-semibold bg-zinc-100 text-zinc-600 hover:bg-zinc-200">
            Lịch sử
          </button>
        </div>
      </div>

      <div id="table-received" class="overflow-x-auto">
        <table class="w-full text-sm">
          <thead class="bg-orange-50/50 border-b border-orange-100 text-xs text-orange-900">
            <tr>
              <th class="px-4 py-3 text-left font-semibold">Người gửi</th>
              <th class="px-4 py-3 text-left font-semibold">Ca của họ</th>
              <th class="px-4 py-3 text-left font-semibold">Lý do</th>
              <th class="px-4 py-3 text-right font-semibold">Thao tác</th>
            </tr>
          </thead>
          <tbody id="receivedSwapListBody" class="divide-y divide-orange-50"></tbody>
        </table>
      </div>
      <div id="table-sent" class="hidden overflow-x-auto">
        <table class="w-full text-sm">
          <thead class="bg-orange-50/50 border-b border-orange-100 text-xs text-orange-900">
            <tr>
              <th class="px-4 py-3 text-left font-semibold">Người nhận</th>
              <th class="px-4 py-3 text-left font-semibold">Ca của tôi</th>
              <th class="px-4 py-3 text-left font-semibold">Lý do</th>
              <th class="px-4 py-3 text-left font-semibold">Trạng thái</th>
            </tr>
          </thead>
          <tbody id="sentSwapListBody" class="divide-y divide-orange-50"></tbody>
        </table>
      </div>
      <div id="table-history" class="hidden overflow-x-auto">
        <table class="w-full text-sm">
          <thead class="bg-orange-50/50 border-b border-orange-100 text-xs text-orange-900">
            <tr>
              <th class="px-4 py-3 text-left font-semibold">Đồng nghiệp</th>
              <th class="px-4 py-3 text-left font-semibold">Ca của người gửi</th>
              <th class="px-4 py-3 text-left font-semibold">Trạng thái</th>
            </tr>
          </thead>
          <tbody id="historySwapListBody" class="divide-y divide-orange-50"></tbody>
        </table>
      </div>
    </div>
  </div>

</main>

<!-- Face Attendance Modal -->
<div id="faceModal" class="fixed inset-0 bg-black/70 z-50 flex items-center justify-center hidden">
  <div class="bg-white rounded-3xl shadow-2xl p-6 w-full max-w-sm mx-4 flex flex-col items-center gap-4">
    <h3 class="font-black text-orange-900 text-lg" id="faceModalTitle">Điểm danh khuôn mặt</h3>

    <div class="relative w-full aspect-square bg-zinc-900 rounded-2xl overflow-hidden">
      <video id="faceVideo" class="w-full h-full object-cover scale-x-[-1]" autoplay muted playsinline></video>
    </div>

    <%-- Mức độ khớp khuôn mặt theo thời gian thực --%>
    <div class="w-full">
      <div class="flex items-baseline justify-between mb-1.5">
        <span class="text-xs font-semibold text-zinc-500">Độ khớp khuôn mặt</span>
        <span id="faceMatch" class="text-zinc-300 font-black text-lg">--%</span>
      </div>
      <div class="w-full bg-zinc-100 rounded-full h-2.5 overflow-hidden">
        <div id="faceMatchBar" class="h-2.5 rounded-full transition-all duration-200" style="width:0%;background:#f59e0b"></div>
      </div>
      <p id="faceMatchHint" class="text-[11px] text-zinc-400 mt-1">Đưa khuôn mặt vào giữa khung hình</p>
    </div>

    <p id="faceStatus" class="text-zinc-600 text-sm text-center font-medium min-h-[2.5rem]">
      Đang khởi động camera...
    </p>

    <div class="w-full bg-zinc-100 rounded-full h-2">
      <div id="faceProgress" class="bg-orange-500 h-2 rounded-full transition-all duration-300" style="width:0%"></div>
    </div>

    <button onclick="closeFaceModal()"
            class="w-full bg-zinc-100 hover:bg-zinc-200 text-zinc-700 font-semibold py-3 rounded-xl text-sm transition">
      Hủy
    </button>
  </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/face-attendance.js"></script>
<script>
var _ctx = '<%=request.getContextPath()%>';
var _currentCaId = null;
var _currentAction = null;
var _myId = ${sessionScope.user.accountId};
var _faceRequired = ${faceConfig != null ? faceConfig.faceRequired : true};

var shifts = [], coworkers = [], swaps = [];

// ── Status helpers ──
function statusBadge(trangThai) {
  const map = {
    'Draft':      { cls: 'badge-draft',     label: 'Chưa công bố' },
    'Published':  { cls: 'badge-published', label: 'Đã phân công' },
    'Confirmed':  { cls: 'badge-confirmed', label: 'Đã xác nhận' },
    'CheckedIn':  { cls: 'badge-checkedin', label: 'Đang làm việc' },
    'CheckedOut': { cls: 'badge-checkedout',label: 'Đã kết thúc' },
    'Cancelled':  { cls: 'badge-cancelled', label: 'Đã hủy' },
  };
  const s = map[trangThai] || { cls: 'badge-draft', label: trangThai || '' };
  return '<span class="shift-badge ' + s.cls + '">' + s.label + '</span>';
}

function swapStatusBadge(t) {
  const map = {
    'ChoXacNhan':     { cls: 'badge-published', label: 'Chờ xác nhận' },
    'ChoQuanLyDuyet': { cls: 'badge-checkedin', label: 'Chờ quản lý duyệt' },
    'DaDuyet':        { cls: 'badge-confirmed', label: 'Đã duyệt' },
    'TuChoi':         { cls: 'badge-cancelled', label: 'Từ chối' },
    'DaHuy':          { cls: 'badge-draft',     label: 'Đã hủy' },
  };
  const s = map[t] || { cls: 'badge-draft', label: t || '' };
  return '<span class="shift-badge ' + s.cls + '">' + s.label + '</span>';
}

function fmt(str) {
  if (!str) return '';
  return str.substring(0, 5);
}
function fmtDate(str) {
  if (!str) return '';
  var p = str.split('-');
  return p[2] + '/' + p[1] + '/' + p[0];
}

// ── Week navigation ──
function getMonday(d) {
  var c = new Date(d);
  var day = c.getDay();
  c.setDate(c.getDate() - day + (day === 0 ? -6 : 1));
  c.setHours(0,0,0,0);
  return c;
}

var todayStr = new Date().toISOString().split('T')[0];
var weekStart = getMonday(new Date());

function changeWeek(dir) {
  weekStart = new Date(weekStart);
  weekStart.setDate(weekStart.getDate() + dir * 7);
  renderCalendar();
}

function toDateStr(d) {
  return d.getFullYear() + '-' + String(d.getMonth()+1).padStart(2,'0') + '-' + String(d.getDate()).padStart(2,'0');
}

// ── Calendar ──
function renderCalendar() {
  var grid = document.getElementById('calendarGrid');
  var label = document.getElementById('weekLabel');
  if (!grid) return;

  var weekEnd = new Date(weekStart);
  weekEnd.setDate(weekEnd.getDate() + 6);

  var dStr = function(d) { return d.getDate() + '/' + (d.getMonth()+1); };
  label.textContent = dStr(weekStart) + ' – ' + dStr(weekEnd);

  var DAY_NAMES = ['Thứ 2','Thứ 3','Thứ 4','Thứ 5','Thứ 6','Thứ 7','Chủ nhật'];
  var html = '';

  for (var i = 0; i < 7; i++) {
    var d = new Date(weekStart);
    d.setDate(d.getDate() + i);
    var dKey = toDateStr(d);
    var isToday = dKey === todayStr;
    var dayShifts = shifts.filter(function(s){ return s.ngayLam === dKey; });

    html += '<div class="week-day-col' + (isToday ? ' today-col' : '') + '" style="min-width:110px;">';
    html += '<div class="text-center mb-2 pb-2 border-b border-orange-100">';
    html += '<p class="text-[10px] font-bold uppercase text-orange-500">' + DAY_NAMES[i] + '</p>';
    html += '<p class="text-lg font-extrabold ' + (isToday ? 'text-orange-600' : 'text-zinc-700') + '">' + d.getDate() + '</p>';
    html += '</div>';

    if (dayShifts.length === 0) {
      html += '<p class="text-center text-[11px] text-zinc-400 italic py-6">Nghỉ</p>';
    } else {
      dayShifts.sort(function(a,b){ return (a.gioBatDau||'').localeCompare(b.gioBatDau||''); });
      dayShifts.forEach(function(s) {
        var stClass = '';
        if (s.trangThai === 'CheckedIn') stClass = ' status-checkedin';
        else if (s.trangThai === 'CheckedOut') stClass = ' status-checkedout';
        else if (s.trangThai === 'Cancelled') stClass = ' status-cancelled';

        html += '<div class="shift-card' + stClass + '">';
        html += '<div class="flex items-center justify-between mb-1">' + statusBadge(s.trangThai) + '</div>';
        html += '<p class="text-xs font-extrabold text-zinc-900">' + fmt(s.gioBatDau) + ' – ' + fmt(s.gioKetThuc) + '</p>';
        if (s.tenCa) html += '<p class="text-[10px] text-orange-600 font-semibold mt-0.5">' + s.tenCa + '</p>';
        if (s.viTri) html += '<p class="text-[10px] text-zinc-500">' + s.viTri + '</p>';
        if (s.gioNghi > 0) html += '<p class="text-[9px] text-red-500 font-semibold mt-1">Nghỉ: ' + s.gioNghi + ' phút</p>';
        // Action buttons
        html += buildShiftActionBtn(s);
        html += '</div>';
      });
    }
    html += '</div>';
  }

  grid.innerHTML = html;
}

function parseMinutes(hhmmss) {
  if (!hhmmss) return -1;
  var p = hhmmss.split(':');
  return parseInt(p[0], 10) * 60 + parseInt(p[1], 10);
}

function buildShiftActionBtn(s) {
  if (!s.trangThai || s.trangThai === 'Cancelled' || s.trangThai === 'CheckedOut' || s.trangThai === 'Draft') {
    return '';
  }
  if (s.trangThai === 'CheckedIn') {
    var html = '<button type="button" onclick="openFaceModal(\'checkout\', ' + s.caLamViecId + ')"'
         + ' class="mt-2 w-full text-[11px] py-1.5 bg-red-600 hover:bg-red-700 text-white font-bold rounded-lg flex items-center justify-center gap-1">'
         + '<i class="ti ti-logout text-[13px]"></i>Kết thúc ca</button>';
    if (!_faceRequired) {
      html += '<form method="post" action="' + _ctx + '/staff/ca-lam" style="margin-top:6px"'
           + ' onsubmit="return confirm(\'Xác nhận kết thúc ca thủ công?\')">'
           + '<input type="hidden" name="action" value="checkOut">'
           + '<input type="hidden" name="caLamViecId" value="' + s.caLamViecId + '">'
           + '<button type="submit" class="text-xs text-zinc-400 hover:text-zinc-600 underline">Thủ công</button>'
           + '</form>';
    }
    return html;
  }
  if (s.trangThai === 'Published') {
    return '<button onclick="doShiftAction(\'confirmShift\',' + s.caLamViecId + ',\'Xác nhận bạn sẽ tham gia ca làm việc này?\')"'
         + ' class="mt-2 w-full text-[11px] py-1.5 bg-orange-600 hover:bg-orange-700 text-white font-bold rounded-lg flex items-center justify-center gap-1">'
         + '<i class="ti ti-check text-[13px]"></i>Xác nhận lịch</button>';
  }
  if (s.trangThai === 'Confirmed') {
    if (s.ngayLam !== todayStr) {
      return '<div class="mt-2 w-full text-[11px] py-1.5 bg-zinc-100 text-zinc-400 font-semibold rounded-lg flex items-center justify-center gap-1 cursor-not-allowed">'
           + '<i class="ti ti-calendar-off text-[13px]"></i>Chưa đến ngày làm</div>';
    }
    var startMin = parseMinutes(s.gioBatDau);
    var now = new Date();
    var nowMin = now.getHours() * 60 + now.getMinutes();
    if (nowMin < startMin - 30) {
      var oh = Math.floor((startMin - 30) / 60), om = (startMin - 30) % 60;
      var openStr = String(oh).padStart(2, '0') + ':' + String(om).padStart(2, '0');
      return '<div class="mt-2 w-full text-[11px] py-1.5 bg-zinc-100 text-zinc-400 font-semibold rounded-lg flex items-center justify-center gap-1 cursor-not-allowed" title="Điểm danh mở lúc ' + openStr + '">'
           + '<i class="ti ti-clock text-[13px]"></i>Chưa đến giờ điểm danh</div>';
    }
    if (nowMin > startMin + 30) {
      return '<div class="mt-2 w-full text-[11px] py-1.5 bg-red-50 text-red-400 font-semibold rounded-lg flex items-center justify-center gap-1 cursor-not-allowed">'
           + '<i class="ti ti-clock-x text-[13px]"></i>Quá giờ điểm danh</div>';
    }
    var html = '<button type="button" onclick="openFaceModal(\'checkin\', ' + s.caLamViecId + ')"'
         + ' class="mt-2 w-full text-[11px] py-1.5 bg-green-600 hover:bg-green-700 text-white font-bold rounded-lg flex items-center justify-center gap-1">'
         + '<i class="ti ti-login text-[13px]"></i>Điểm danh vào ca</button>';
    if (!_faceRequired) {
      html += '<form method="post" action="' + _ctx + '/staff/ca-lam" style="margin-top:6px"'
           + ' onsubmit="return confirm(\'Xác nhận vào ca thủ công?\')">'
           + '<input type="hidden" name="action" value="checkIn">'
           + '<input type="hidden" name="caLamViecId" value="' + s.caLamViecId + '">'
           + '<button type="submit" class="text-xs text-zinc-400 hover:text-zinc-600 underline">Thủ công</button>'
           + '</form>';
    }
    return html;
  }
  return '';
}

function doShiftAction(action, id, msg) {
  if (!confirm(msg)) return;
  var f = document.createElement('form');
  f.method = 'POST'; f.action = _ctx + '/staff/ca-lam';
  f.innerHTML = '<input name="action" value="' + action + '" type="hidden">'
              + '<input name="caLamViecId" value="' + id + '" type="hidden">';
  document.body.appendChild(f);
  f.submit();
}

// ── Today card ──
function renderTodayCard() {
  var todayShifts = shifts.filter(function(s){ return s.ngayLam === todayStr && s.trangThai !== 'Cancelled'; });
  var todaySec = document.getElementById('todaySection');
  var todayEmpty = document.getElementById('todayEmpty');
  if (!todaySec || !todayEmpty) return;

  if (todayShifts.length === 0) {
    todaySec.classList.add('hidden');
    todayEmpty.classList.remove('hidden');
    return;
  }

  todaySec.classList.remove('hidden');
  todayEmpty.classList.add('hidden');

  // Show the most relevant shift (prefer CheckedIn > Confirmed > Published > others)
  var priority = ['CheckedIn','Confirmed','Published','CheckedOut','Draft'];
  todayShifts.sort(function(a,b){
    return priority.indexOf(a.trangThai) - priority.indexOf(b.trangThai);
  });
  var s = todayShifts[0];

  document.getElementById('todayShiftTime').textContent = fmt(s.gioBatDau) + ' – ' + fmt(s.gioKetThuc);
  document.getElementById('todayShiftName').textContent = (s.tenCa || '') + (s.viTri ? ' · ' + s.viTri : '');
  document.getElementById('todayStatusBadge').textContent = {
    'Draft':'Chưa công bố','Published':'Đã phân công','Confirmed':'Đã xác nhận',
    'CheckedIn':'Đang làm việc','CheckedOut':'Đã kết thúc','Cancelled':'Đã hủy'
  }[s.trangThai] || s.trangThai;

  var note = document.getElementById('todayShiftNote');
  note.textContent = s.ghiChu || '';

  var btns = document.getElementById('todayActionBtns');
  btns.innerHTML = '';
  if (s.trangThai === 'Published') {
    btns.innerHTML = '<button onclick="doShiftAction(\'confirmShift\',' + s.caLamViecId + ',\'Xác nhận ca hôm nay?\')" class="px-4 py-2 bg-white text-orange-700 rounded-lg text-xs font-bold hover:bg-orange-50 transition-all">Xác nhận lịch</button>';
  } else if (s.trangThai === 'Confirmed') {
    var startMin = parseMinutes(s.gioBatDau);
    var now = new Date();
    var nowMin = now.getHours() * 60 + now.getMinutes();
    if (nowMin < startMin - 30) {
      var oh = Math.floor((startMin - 30) / 60), om = (startMin - 30) % 60;
      var openStr = String(oh).padStart(2, '0') + ':' + String(om).padStart(2, '0');
      btns.innerHTML = '<div class="px-4 py-2 bg-white/30 text-white/60 rounded-lg text-xs font-bold cursor-not-allowed" title="Điểm danh mở lúc ' + openStr + '">Chưa đến giờ điểm danh</div>';
    } else if (nowMin > startMin + 30) {
      btns.innerHTML = '<div class="px-4 py-2 bg-white/30 text-white/60 rounded-lg text-xs font-bold cursor-not-allowed">Quá giờ điểm danh</div>';
    } else {
      var html = '<button type="button" onclick="openFaceModal(\'checkin\', ' + s.caLamViecId + ')" class="px-4 py-2 bg-white text-green-700 rounded-lg text-xs font-bold hover:bg-green-50 transition-all">Điểm danh vào ca</button>';
      if (!_faceRequired) {
        html += ' <form method="post" action="' + _ctx + '/staff/ca-lam" style="display:inline-block;margin-left:8px"'
             + ' onsubmit="return confirm(\'Xác nhận vào ca thủ công?\')">'
             + '<input type="hidden" name="action" value="checkIn">'
             + '<input type="hidden" name="caLamViecId" value="' + s.caLamViecId + '">'
             + '<button type="submit" class="text-xs text-zinc-400 hover:text-zinc-600 underline">Thủ công</button>'
             + '</form>';
      }
      btns.innerHTML = html;
    }
  } else if (s.trangThai === 'CheckedIn') {
    var html = '<button type="button" onclick="openFaceModal(\'checkout\', ' + s.caLamViecId + ')" class="px-4 py-2 bg-white text-red-700 rounded-lg text-xs font-bold hover:bg-red-50 transition-all">Kết thúc ca</button>';
    if (!_faceRequired) {
      html += ' <form method="post" action="' + _ctx + '/staff/ca-lam" style="display:inline-block;margin-left:8px"'
           + ' onsubmit="return confirm(\'Xác nhận kết thúc ca thủ công?\')">'
           + '<input type="hidden" name="action" value="checkOut">'
           + '<input type="hidden" name="caLamViecId" value="' + s.caLamViecId + '">'
           + '<button type="submit" class="text-xs text-zinc-400 hover:text-zinc-600 underline">Thủ công</button>'
           + '</form>';
    }
    btns.innerHTML = html;
  }
}

// ── Load ──
async function loadData() {
  try {
    var r = await fetch(_ctx + '/staff/ca-lam?format=json');
    if (!r.ok) throw new Error('HTTP ' + r.status);
    var data = await r.json();
    shifts = data.shifts || [];
    coworkers = data.coworkers || [];
    swaps = data.swaps || [];
    renderTodayCard();
    renderCalendar();
    renderSwapForm();
    renderSwaps();
  } catch(e) {
    document.getElementById('calendarGrid').innerHTML =
      '<div class="text-center text-red-500 text-sm py-8 w-full">Không thể tải lịch làm. Vui lòng thử lại.</div>';
  }
}

// ── Swap form ──
function renderSwapForm() {
  var myShiftsEl = document.getElementById('swapMyShifts');
  var coworkersEl = document.getElementById('swapCoworkers');
  if (!myShiftsEl || !coworkersEl) return;

  var futureShifts = shifts.filter(function(s){ return s.ngayLam >= todayStr; });
  myShiftsEl.innerHTML = '<option value="">-- Chọn ca của bạn --</option>';
  futureShifts.forEach(function(s) {
    var o = document.createElement('option');
    o.value = s.caLamViecId;
    o.textContent = fmtDate(s.ngayLam) + ' (' + fmt(s.gioBatDau) + '–' + fmt(s.gioKetThuc) + ')';
    myShiftsEl.appendChild(o);
  });

  coworkersEl.innerHTML = '<option value="">-- Chọn đồng nghiệp --</option>';
  coworkers.forEach(function(c) {
    var o = document.createElement('option');
    o.value = c.accountId;
    o.textContent = c.fullName + ' (' + (c.roleName || '') + ')';
    coworkersEl.appendChild(o);
  });
}

// ── Swaps list ──
function renderSwaps() {
  var received = swaps.filter(function(sw){ return sw.accountIdNhan === _myId && sw.trangThai === 'ChoXacNhan'; });
  var sent = swaps.filter(function(sw){ return sw.accountIdGui === _myId && (sw.trangThai === 'ChoXacNhan' || sw.trangThai === 'ChoQuanLyDuyet'); });
  var history = swaps.filter(function(sw){
    return (sw.accountIdNhan === _myId && sw.trangThai !== 'ChoXacNhan') ||
           (sw.accountIdGui === _myId && sw.trangThai !== 'ChoXacNhan' && sw.trangThai !== 'ChoQuanLyDuyet');
  });

  // Badge
  var rb = document.getElementById('receivedBadge');
  if (rb) { rb.textContent = received.length; rb.classList.toggle('hidden', received.length === 0); }
  var sb = document.getElementById('swapBadge');
  if (sb) { sb.textContent = received.length; sb.classList.toggle('hidden', received.length === 0); }

  var receivedBody = document.getElementById('receivedSwapListBody');
  if (receivedBody) {
    receivedBody.innerHTML = received.length === 0
      ? '<tr><td colspan="4" class="px-4 py-8 text-center text-zinc-400 italic">Không có yêu cầu nào cần xác nhận</td></tr>'
      : received.map(function(sw) {
          var actions = '<form action="' + _ctx + '/staff/ca-lam" method="POST" style="display:inline;margin-right:6px">'
                      + '<input type="hidden" name="action" value="respondSwap">'
                      + '<input type="hidden" name="id" value="' + sw.swapRequestId + '">'
                      + '<input type="hidden" name="accept" value="true">'
                      + '<button class="text-xs font-bold px-3 py-1.5 bg-green-50 hover:bg-green-100 text-green-700 rounded-lg border border-green-200">Đồng ý</button></form>'
                      + '<form action="' + _ctx + '/staff/ca-lam" method="POST" style="display:inline">'
                      + '<input type="hidden" name="action" value="respondSwap">'
                      + '<input type="hidden" name="id" value="' + sw.swapRequestId + '">'
                      + '<input type="hidden" name="accept" value="false">'
                      + '<button class="text-xs font-bold px-3 py-1.5 bg-red-50 hover:bg-red-100 text-red-700 rounded-lg border border-red-200">Từ chối</button></form>';
          return '<tr class="hover:bg-orange-50/20">'
               + '<td class="px-4 py-3 font-semibold">' + (sw.tenNguoiGui||'-') + '</td>'
               + '<td class="px-4 py-3 text-xs">' + (sw.caGuiInfo||'-') + '</td>'
               + '<td class="px-4 py-3 text-xs text-zinc-500">' + (sw.lyDo||'') + '</td>'
               + '<td class="px-4 py-3 text-right">' + actions + '</td></tr>';
        }).join('');
  }

  var sentBody = document.getElementById('sentSwapListBody');
  if (sentBody) {
    sentBody.innerHTML = sent.length === 0
      ? '<tr><td colspan="4" class="px-4 py-8 text-center text-zinc-400 italic">Không có yêu cầu đang hoạt động</td></tr>'
      : sent.map(function(sw) {
          return '<tr class="hover:bg-orange-50/20">'
               + '<td class="px-4 py-3 font-semibold">' + (sw.tenNguoiNhan||'-') + '</td>'
               + '<td class="px-4 py-3 text-xs">' + (sw.caGuiInfo||'-') + '</td>'
               + '<td class="px-4 py-3 text-xs text-zinc-500">' + (sw.lyDo||'') + '</td>'
               + '<td class="px-4 py-3">' + swapStatusBadge(sw.trangThai === 'ChoXacNhan' ? 'ChoXacNhan' : sw.trangThai) + '</td></tr>';
        }).join('');
  }

  var historyBody = document.getElementById('historySwapListBody');
  if (historyBody) {
    historyBody.innerHTML = history.length === 0
      ? '<tr><td colspan="3" class="px-4 py-8 text-center text-zinc-400 italic">Không có lịch sử</td></tr>'
      : history.map(function(sw) {
          var partner = sw.accountIdGui === _myId ? (sw.tenNguoiNhan||'-') : (sw.tenNguoiGui||'-');
          return '<tr class="hover:bg-orange-50/20">'
               + '<td class="px-4 py-3 font-semibold">' + partner + '</td>'
               + '<td class="px-4 py-3 text-xs">' + (sw.caGuiInfo||'-') + '</td>'
               + '<td class="px-4 py-3">' + swapStatusBadge(sw.trangThai) + '</td></tr>';
        }).join('');
  }
}

// ── Tab switching ──
function switchTab(name) {
  ['schedule','swaps'].forEach(function(t) {
    document.getElementById('section-' + t).classList.toggle('hidden', t !== name);
    var btn = document.getElementById('tab-' + t);
    if (btn) btn.classList.toggle('active', t === name);
  });
}

function switchSwapTab(name) {
  ['received','sent','history'].forEach(function(t) {
    var el = document.getElementById('table-' + t);
    if (el) el.classList.toggle('hidden', t !== name);
    var btn = document.getElementById('subtab-' + t);
    if (btn) {
      btn.className = (t === name)
        ? 'px-3 py-1.5 rounded-lg text-xs font-semibold bg-orange-600 text-white flex items-center gap-1'
        : 'px-3 py-1.5 rounded-lg text-xs font-semibold bg-zinc-100 text-zinc-600 hover:bg-zinc-200';
    }
  });
}

// ── Face Attendance Modal Functions ──
function openFaceModal(action, caId) {
  _currentCaId = caId;
  _currentAction = action;
  document.getElementById('faceModal').classList.remove('hidden');
  document.getElementById('faceModalTitle').textContent =
    action === 'checkin' ? 'Điểm danh VÀO CA' : 'Điểm danh KẾT THÚC CA';
  startFaceAttendance(action, caId);
}

// Quick action: tự chọn ca hôm nay và hành động phù hợp (vào ca / kết thúc ca)
function openTodayFaceModal() {
  var todayStr = new Date().toISOString().slice(0, 10);
  var todayShifts = shifts.filter(function(s) {
    return s.ngayLam === todayStr && s.trangThai !== 'Cancelled';
  });
  if (todayShifts.length === 0) {
    alert('Hôm nay bạn không có ca làm việc nào được phân công.');
    return;
  }
  todayShifts.sort(function(a, b) { return (a.gioBatDau || '').localeCompare(b.gioBatDau || ''); });

  // Ưu tiên ca đang mở: chưa vào ca -> checkin; đã vào chưa ra -> checkout
  var pending = todayShifts.find(function(s) { return !s.gioVaoThuc; });
  if (pending) { openFaceModal('checkin', pending.caLamViecId); return; }

  var inShift = todayShifts.find(function(s) { return s.gioVaoThuc && !s.gioRaThuc; });
  if (inShift) { openFaceModal('checkout', inShift.caLamViecId); return; }

  alert('Bạn đã hoàn thành tất cả ca hôm nay.');
}

function closeFaceModal() {
  FaceAttendance.stop();
  document.getElementById('faceModal').classList.add('hidden');
  resetFaceMatch();
}

function resetFaceMatch() {
  var m = document.getElementById('faceMatch');
  m.textContent = '--%';
  m.className = 'text-zinc-300 font-black text-lg';
  document.getElementById('faceMatchBar').style.width = '0%';
  document.getElementById('faceMatchHint').textContent = 'Đưa khuôn mặt vào giữa khung hình';
  document.getElementById('faceProgress').style.width = '0%';
}

async function startFaceAttendance(action, caId) {
  const statusEl = document.getElementById('faceStatus');
  const progressEl = document.getElementById('faceProgress');
  resetFaceMatch();

  const ready = await FaceAttendance.init({
    videoEl: document.getElementById('faceVideo'),
    statusEl: statusEl,
    matchEl: document.getElementById('faceMatch'),
    matchBarEl: document.getElementById('faceMatchBar'),
    matchHintEl: document.getElementById('faceMatchHint'),
    contextPath: _ctx,
    caLamViecId: caId,
    action: action,
    onSuccess: function(data) {
      progressEl.style.width = '100%';
      statusEl.textContent = '✓ Thành công! Độ khớp: ' + data.confidence.toFixed(1) + '%';
      statusEl.className = 'text-green-600 font-bold text-sm text-center';
      setTimeout(() => { closeFaceModal(); location.reload(); }, 1500);
    },
    onError: function(msg) {
      statusEl.textContent = '✗ ' + (msg || 'Lỗi nhận diện');
      statusEl.className = 'text-red-600 font-bold text-sm text-center';
    }
  });

  if (ready === false) return;   // chưa đăng ký khuôn mặt — không mở camera
  await FaceAttendance.start();
}

// ── Init ──
document.addEventListener('DOMContentLoaded', function() {
  loadData();
  switchSwapTab('received');
  var mb = document.getElementById('mobileMenuBtn');
  if (mb) mb.addEventListener('click', function(){
    document.getElementById('sidebar').classList.toggle('-translate-x-full');
  });
});
</script>
</body>
</html>
