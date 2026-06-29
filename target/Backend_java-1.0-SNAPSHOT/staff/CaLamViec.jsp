<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Lịch làm việc của tôi — V-SPORT</title>
<script src="https://cdn.tailwindcss.com"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200">
<style>
  body { font-family: 'Inter', sans-serif; }
  .card { background:#fff; border:1px solid #ffedd5; border-radius:16px; transition:box-shadow .2s, transform .2s; }
  .badge { display:inline-flex; align-items:center; padding:4px 10px; border-radius:8px; font-size:11px; font-weight:600; }
  .badge-purple { background:#ffedd5; color:#c2410c; }
  .badge-green { background:#dcfce7; color:#15803d; }
  .badge-blue { background:#dbeafe; color:#1d4ed8; }
  .badge-zinc { background:#f4f4f5; color:#71717a; }
  .badge-red { background:#fee2e2; color:#b91c1c; }
  .badge-yellow { background:#fef3c7; color:#b45309; }
  .live-dot { animation: pulse-dot 1.6s ease-in-out infinite; }
  @keyframes pulse-dot { 0%,100%{box-shadow:0 0 0 0 rgba(249,115,22,.4);} 50%{box-shadow:0 0 0 6px rgba(249,115,22,0);} }
  
  @keyframes contentZoomIn {
    from { opacity: 0; transform: scale(0.97); }
    to { opacity: 1; transform: scale(1); }
  }
  main {
    animation: contentZoomIn 0.35s cubic-bezier(0.34, 1.56, 0.64, 1) forwards;
    transform-origin: center top;
  }
  
  .nav-link-tab {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 8px 16px;
    border-radius: 8px;
    background: #f4f4f5;
    color: #52525b;
    font-size: 13px;
    font-weight: 500;
    border: none;
    cursor: pointer;
    transition: all 0.2s;
  }
  .nav-link-tab:hover {
    background: #e4e4e7;
    color: #18181b;
  }
  .nav-link-tab.active {
    background: #ea580c;
    color: white;
    box-shadow: 0 4px 6px -1px rgba(234, 88, 12, 0.3);
  }
  .nav-link-tab .material-symbols-outlined {
    font-size: 18px;
  }
</style>
</head>
<body class="bg-orange-50/20 text-zinc-900 min-h-screen">

<!-- Sidebar -->
<jsp:include page="/staff/common/sidebar.jsp" />

<!-- Header -->
<header class="h-[64px] fixed top-0 right-0 left-0 lg:left-[248px] bg-white/80 backdrop-blur-lg border-b border-orange-100 z-20 flex items-center justify-between px-4 lg:px-6">
  <div class="flex items-center gap-3">
    <button id="mobileMenuBtn" class="lg:hidden p-2 rounded-lg hover:bg-orange-50 text-orange-700">
      <span class="material-symbols-outlined text-[20px]">menu</span>
    </button>
    <div>
      <h1 class="text-sm font-bold text-orange-900 tracking-tight">Lịch làm việc của tôi</h1>
      <p class="text-xs text-orange-550 flex items-center gap-1.5">
        <span class="material-symbols-outlined text-[12px]">badge</span>Nhân viên · Cơ sở CS${sessionScope.user.coSoId}
      </p>
    </div>
  </div>
  
  <div class="flex items-center gap-1.5">
    <jsp:include page="/manager/common/profile_dropdown.jsp" />
  </div>
</header>

<main class="lg:ml-[248px] mt-[64px] p-4 lg:p-6 flex flex-col gap-5">
  <!-- Sub-navigation Tabs -->
  <div class="flex gap-2 mb-2">
    <button onclick="switchStaffTab('schedule')" id="tab-schedule" class="nav-link-tab active">
      <span class="material-symbols-outlined text-[16px]">calendar_month</span>
      Lịch làm việc
    </button>
    <button onclick="switchStaffTab('swaps')" id="tab-swaps" class="nav-link-tab">
      <span class="material-symbols-outlined text-[16px]">swap_horiz</span>
      Yêu cầu đổi ca
    </button>
  </div>

  <!-- Alert Messages -->
  <c:if test="${not empty sessionScope.error}">
    <div class="p-4 bg-red-50 border border-red-100 rounded-xl text-red-600 text-sm flex items-start gap-3">
      <span class="material-symbols-outlined text-[20px] shrink-0">error</span>
      <div class="flex-1">
        <span class="font-bold block text-red-750">Lỗi thực hiện</span>
        <span class="text-red-600/90 leading-normal block mt-0.5">${sessionScope.error}</span>
      </div>
      <button onclick="this.parentElement.remove()" class="text-red-400 hover:text-red-700"><span class="material-symbols-outlined text-[18px]">close</span></button>
      <% session.removeAttribute("error"); %>
    </div>
  </c:if>
  <c:if test="${not empty sessionScope.message}">
    <div class="p-4 bg-orange-50 border border-orange-100 rounded-xl text-orange-650 text-sm flex items-start gap-3">
      <span class="material-symbols-outlined text-[20px] shrink-0">check_circle</span>
      <div class="flex-1">
        <span class="font-bold block text-orange-750">Thành công</span>
        <span class="text-orange-650/90 leading-normal block mt-0.5">${sessionScope.message}</span>
      </div>
      <button onclick="this.parentElement.remove()" class="text-orange-400 hover:text-orange-700"><span class="material-symbols-outlined text-[18px]">close</span></button>
      <% session.removeAttribute("message"); %>
    </div>
  </c:if>

  <!-- ==================== SECTION 1: LỊCH LÀM VIỆC ==================== -->
  <div id="section-schedule" class="flex flex-col gap-4">
    <!-- Week Navigation -->
    <div class="card p-4 bg-white flex items-center justify-between">
      <button onclick="changeWeek(-1)" class="flex items-center gap-1.5 px-3 py-2 rounded-lg border border-orange-100 hover:bg-orange-50 text-orange-750 transition-colors">
        <span class="material-symbols-outlined text-[18px]">chevron_left</span>
        <span class="text-sm font-medium">Tuần trước</span>
      </button>
      <div class="text-center">
        <h3 class="text-base font-bold text-orange-900" id="weekRangeDisplay">Tuần này</h3>
        <p class="text-[10px] text-orange-400 font-semibold uppercase tracking-wider mt-0.5">Chỉ hiển thị lịch đã công bố</p>
      </div>
      <button onclick="changeWeek(1)" class="flex items-center gap-1.5 px-3 py-2 rounded-lg border border-orange-100 hover:bg-orange-50 text-orange-750 transition-colors">
        <span class="text-sm font-medium">Tuần sau</span>
        <span class="material-symbols-outlined text-[18px]">chevron_right</span>
      </button>
    </div>

    <!-- Calendar Grid -->
    <div class="card overflow-hidden bg-white p-4">
      <div id="calendarGrid" class="grid gap-4">
        <!-- Populated by JS -->
      </div>
    </div>
  </div>



  <!-- ==================== SECTION 3: YÊU CẦU ĐỔI CA ==================== -->
  <div id="section-swaps" class="hidden grid grid-cols-1 lg:grid-cols-3 gap-5">
    <!-- Swap Form -->
    <div class="card p-5 bg-white lg:col-span-1 h-fit">
      <h3 class="text-sm font-bold text-orange-950 flex items-center gap-2 mb-4 pb-2 border-b border-orange-50">
        <span class="material-symbols-outlined text-orange-600">swap_horiz</span>Gửi yêu cầu đổi ca
      </h3>
      <form action="${pageContext.request.contextPath}/staff/ca-lam" method="POST" class="flex flex-col gap-4">
        <input type="hidden" name="action" value="requestSwap">

        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-semibold text-orange-900">Chọn ca của bạn <span class="text-red-500">*</span></label>
          <select name="caLamViecIdGui" id="swapMyShifts" required
                  class="h-10 px-3.5 rounded-xl border border-orange-100 text-sm focus:ring-2 focus:ring-orange-400 focus:outline-none bg-white text-zinc-700 hover:border-orange-200 transition-all shadow-sm">
            <!-- My shifts -->
          </select>
        </div>

        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-semibold text-orange-900">Chọn đồng nghiệp để đổi <span class="text-red-500">*</span></label>
          <select name="accountIdNhan" id="swapCoworkers" required onchange="loadCoworkerShifts()"
                  class="h-10 px-3.5 rounded-xl border border-orange-100 text-sm focus:ring-2 focus:ring-orange-400 focus:outline-none bg-white text-zinc-700 hover:border-orange-200 transition-all shadow-sm">
            <!-- Coworkers list -->
          </select>
        </div>

        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-semibold text-orange-900">Chọn ca của đồng nghiệp <span class="text-gray-400">(Để trống nếu nhờ làm hộ)</span></label>
          <select name="caLamViecIdNhan" id="swapCoworkerShifts"
                  class="h-10 px-3.5 rounded-xl border border-orange-100 text-sm focus:ring-2 focus:ring-orange-400 focus:outline-none bg-white text-zinc-700 hover:border-orange-200 transition-all shadow-sm">
            <option value="">-- Chỉ nhờ làm hộ (Cover request) --</option>
          </select>
        </div>

        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-semibold text-orange-900">Lý do đổi ca <span class="text-red-500">*</span></label>
          <input type="text" name="lyDo" required placeholder="Ví dụ: Có việc bận đột xuất..."
                 class="h-10 px-3.5 rounded-xl border border-orange-100 text-sm focus:ring-2 focus:ring-orange-400 focus:outline-none text-zinc-700 hover:border-orange-200 transition-all shadow-sm">
        </div>

        <button type="submit" class="w-full h-10 rounded-xl bg-orange-600 hover:bg-orange-700 text-white text-sm font-semibold transition-all shadow-md shadow-orange-100">
          Gửi yêu cầu hoán đổi
        </button>
      </form>
    </div>

    <!-- Swap Requests List -->
    <div class="card p-5 bg-white lg:col-span-2 flex flex-col gap-4">
      <div class="flex flex-col sm:flex-row sm:items-center justify-between border-b border-orange-50 pb-3 gap-2">
        <h3 class="text-sm font-bold text-orange-955 flex items-center gap-2">
          <span class="material-symbols-outlined text-orange-600">list_alt</span>Quản lý yêu cầu đổi ca
        </h3>
        <!-- Sub-tabs -->
        <div class="flex gap-1.5" id="swapSubTabs">
          <button onclick="switchSwapSubTab('received')" id="subtab-received" 
                  class="px-3 py-1.5 rounded-lg text-xs font-semibold transition-all cursor-pointer bg-orange-600 text-white shadow-sm flex items-center gap-1">
            Cần xác nhận
            <span id="receivedBadge" class="bg-red-500 text-white text-[9px] font-bold px-1.5 py-0.5 rounded-full hidden">0</span>
          </button>
          <button onclick="switchSwapSubTab('sent')" id="subtab-sent" 
                  class="px-3 py-1.5 rounded-lg text-xs font-semibold transition-all cursor-pointer bg-zinc-100 text-zinc-650 hover:bg-zinc-200 hover:text-zinc-900">
            Tôi đã gửi
          </button>
          <button onclick="switchSwapSubTab('history')" id="subtab-history" 
                  class="px-3 py-1.5 rounded-lg text-xs font-semibold transition-all cursor-pointer bg-zinc-100 text-zinc-650 hover:bg-zinc-200 hover:text-zinc-900">
            Lịch sử
          </button>
        </div>
      </div>

      <!-- Tab 1: Received Requests -->
      <div id="table-received" class="overflow-x-auto">
        <table class="w-full text-sm">
          <thead class="bg-orange-50/50 border-b border-orange-100 text-xs text-orange-900">
            <tr>
              <th class="px-4 py-3 text-left font-semibold">Người gửi</th>
              <th class="px-4 py-3 text-left font-semibold">Ca của người gửi</th>
              <th class="px-4 py-3 text-left font-semibold">Ca muốn đổi</th>
              <th class="px-4 py-3 text-left font-semibold">Lý do</th>
              <th class="px-4 py-3 text-right font-semibold">Thao tác</th>
            </tr>
          </thead>
          <tbody id="receivedSwapListBody" class="divide-y divide-orange-50">
            <!-- Populated by JS -->
          </tbody>
        </table>
      </div>

      <!-- Tab 2: Sent Requests -->
      <div id="table-sent" class="hidden overflow-x-auto">
        <table class="w-full text-sm">
          <thead class="bg-orange-50/50 border-b border-orange-100 text-xs text-orange-900">
            <tr>
              <th class="px-4 py-3 text-left font-semibold">Người nhận</th>
              <th class="px-4 py-3 text-left font-semibold">Ca của tôi</th>
              <th class="px-4 py-3 text-left font-semibold">Ca muốn đổi</th>
              <th class="px-4 py-3 text-left font-semibold">Lý do</th>
              <th class="px-4 py-3 text-left font-semibold">Trạng thái</th>
            </tr>
          </thead>
          <tbody id="sentSwapListBody" class="divide-y divide-orange-50">
            <!-- Populated by JS -->
          </tbody>
        </table>
      </div>

      <!-- Tab 3: History -->
      <div id="table-history" class="hidden overflow-x-auto">
        <table class="w-full text-sm">
          <thead class="bg-orange-50/50 border-b border-orange-100 text-xs text-orange-900">
            <tr>
              <th class="px-4 py-3 text-left font-semibold">Đồng nghiệp</th>
              <th class="px-4 py-3 text-left font-semibold">Vai trò</th>
              <th class="px-4 py-3 text-left font-semibold">Ca của người gửi</th>
              <th class="px-4 py-3 text-left font-semibold">Ca muốn đổi</th>
              <th class="px-4 py-3 text-left font-semibold">Trạng thái</th>
              <th class="px-4 py-3 text-left font-semibold">Phản hồi của QL</th>
            </tr>
          </thead>
          <tbody id="historySwapListBody" class="divide-y divide-orange-50">
            <!-- Populated by JS -->
          </tbody>
        </table>
      </div>
    </div>
  </div>
</main>

<script>
var _ctxPath = '<%=request.getContextPath()%>';
var _currentUserId = ${sessionScope.user.accountId};

// Local state
let shifts = [];
let coworkers = [];
let avails = [];
let swaps = [];

// ==================== NAVIGATION & STATE ====================

let currentSwapSubTab = 'received';

function switchSwapSubTab(tabName) {
  currentSwapSubTab = tabName;
  
  // Highlight tab button
  const buttons = document.querySelectorAll('#swapSubTabs button');
  buttons.forEach(btn => {
    if (btn.id === 'subtab-' + tabName) {
      btn.className = "px-3 py-1.5 rounded-lg text-xs font-semibold transition-all cursor-pointer bg-orange-600 text-white shadow-sm flex items-center gap-1";
    } else {
      btn.className = "px-3 py-1.5 rounded-lg text-xs font-semibold transition-all cursor-pointer bg-zinc-100 text-zinc-650 hover:bg-zinc-200 hover:text-zinc-900";
    }
  });

  // Toggle tables
  const tables = ['received', 'sent', 'history'];
  tables.forEach(t => {
    const el = document.getElementById('table-' + t);
    if (el) {
      if (t === tabName) {
        el.classList.remove('hidden');
      } else {
        el.classList.add('hidden');
      }
    }
  });
}

function switchStaffTab(tabName) {
  document.querySelectorAll('.nav-link-tab').forEach(b => b.classList.remove('active'));
  const tabEl = document.getElementById('tab-' + tabName);
  if (tabEl) tabEl.classList.add('active');

  const scheduleSec = document.getElementById('section-schedule');
  const swapsSec = document.getElementById('section-swaps');

  if (scheduleSec) scheduleSec.classList.add('hidden');
  if (swapsSec) swapsSec.classList.add('hidden');

  const activeSec = document.getElementById('section-' + tabName);
  if (activeSec) activeSec.classList.remove('hidden');
  
  if (tabName === 'swaps') {
    switchSwapSubTab(currentSwapSubTab);
  }
}

// Helpers
function formatTime(str) {
  if (!str) return '';
  const parts = str.split(':');
  if (parts.length < 2) return str;
  return parts[0] + ':' + parts[1];
}

function formatDate(str) {
  if (!str) return '';
  const parts = str.split('-');
  if (parts.length !== 3) return str;
  return parts[2] + '/' + parts[1] + '/' + parts[0];
}

function getMonday(date) {
  const d = new Date(date);
  const day = d.getDay();
  const diff = d.getDate() - day + (day === 0 ? -6 : 1);
  return new Date(d.setDate(diff));
}

let currentWeekStart = getMonday(new Date());

function changeWeek(direction) {
  currentWeekStart.setDate(currentWeekStart.getDate() + (direction * 7));
  renderCalendar();
}

function getShiftStatus(ngayLamStr, batDauStr, ketThucStr) {
  const now = new Date();
  const [y, m, d] = ngayLamStr.split('-').map(Number);
  const [sh, sm] = batDauStr.split(':').map(Number);
  const [eh, em] = ketThucStr.split(':').map(Number);
  const startDateTime = new Date(y, m - 1, d, sh, sm, 0);
  const endDateTime = new Date(y, m - 1, d, eh, em, 0);
  if (endDateTime < startDateTime) {
    endDateTime.setDate(endDateTime.getDate() + 1);
  }
  if (now < startDateTime) {
    return { label: 'Sắp diễn ra', cssClass: 'badge-blue' };
  } else if (now > endDateTime) {
    return { label: 'Đã kết thúc', cssClass: 'badge-zinc' };
  } else {
    return { label: 'Đang diễn ra', cssClass: 'badge-green live-dot' };
  }
}

// ==================== CORE ACTIONS ====================

async function loadData() {
  try {
    const response = await fetch(_ctxPath + '/staff/ca-lam?format=json');
    if (response.ok) {
      const data = await response.json();
      shifts = data.shifts || [];
      coworkers = data.coworkers || [];
      avails = data.avails || [];
      swaps = data.swaps || [];

      renderCalendar();
      renderSwaps();
    } else {
      console.error('Failed to load data.');
    }
  } catch (error) {
    console.error('Error fetching data:', error);
  }
}

// ==================== RENDERING FUNCTIONS ====================

function renderCalendar() {
  const grid = document.getElementById('calendarGrid');
  const weekRangeDisplay = document.getElementById('weekRangeDisplay');
  if (!grid || !weekRangeDisplay) return;

  const weekEnd = new Date(currentWeekStart);
  weekEnd.setDate(weekEnd.getDate() + 6);

  const formatDateVN = (date) => date.getDate() + '/' + (date.getMonth() + 1);
  weekRangeDisplay.textContent = formatDateVN(currentWeekStart) + ' - ' + formatDateVN(weekEnd);

  const days = [];
  for (let i = 0; i < 7; i++) {
    const dayDate = new Date(currentWeekStart);
    dayDate.setDate(dayDate.getDate() + i);
    days.push(dayDate);
  }

  const shiftsByDate = {};
  days.forEach(day => {
    const dateStr = day.toISOString().split('T')[0];
    shiftsByDate[dateStr] = shifts.filter(s => s.ngayLam === dateStr);
  });

  var html = '<div class="grid grid-cols-7 gap-4">';

  days.forEach(day => {
    const dateStr = day.toISOString().split('T')[0];
    const dayShifts = shiftsByDate[dateStr] || [];
    const dayName = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'Chủ nhật'][day.getDay() === 0 ? 6 : day.getDay() - 1];
    const dateNum = day.getDate();
    const isToday = dateStr === new Date().toISOString().split('T')[0];

    html += '<div class="flex flex-col gap-2 min-h-[360px] border border-orange-50 rounded-xl p-3 bg-orange-50/5">'
          + '<div class="text-center pb-2 border-b border-orange-50">'
          + '<p class="text-xs font-semibold text-orange-600 uppercase">' + dayName + '</p>'
          + '<p class="text-lg font-bold ' + (isToday ? 'text-orange-600' : 'text-zinc-800') + '">' + dateNum + '</p>'
          + '</div>'
          + '<div class="flex flex-col gap-2 flex-1">';

    if (dayShifts.length === 0) {
      html += '<div class="text-center text-zinc-400 text-xs italic py-4">Không có ca</div>';
    } else {
      dayShifts.sort((a, b) => a.gioBatDau.localeCompare(b.gioBatDau));

      dayShifts.forEach(s => {
        const isMyShift = (s.accountId === _currentUserId);
        const timeFrame = formatTime(s.gioBatDau) + ' - ' + formatTime(s.gioKetThuc);
        const status = getShiftStatus(s.ngayLam, s.gioBatDau, s.gioKetThuc);

        let bgColor = '';
        let borderColor = '';
        let titleColor = '';
        let borderStyle = 'border';

        if (isMyShift) {
          bgColor = 'bg-gradient-to-br from-orange-50 to-orange-100/40 text-zinc-800 hover:from-orange-100/60 hover:to-orange-100/70';
          borderColor = 'border-orange-300/80 border-l-orange-500';
          titleColor = 'text-orange-700';
          borderStyle = 'border border-l-4';
        } else {
          bgColor = 'bg-zinc-50/50 hover:bg-zinc-100/60 text-zinc-700';
          borderColor = 'border-zinc-200';
          titleColor = 'text-zinc-500';
          borderStyle = 'border';
        }

        let confirmBtnHtml = '';
        const todayStr = new Date().toISOString().split('T')[0];
        if (isMyShift && s.trangThai === 'Published') {
          confirmBtnHtml = '<button onclick="confirmMyShift(' + s.caLamViecId + ')" class="mt-2.5 w-full text-[11px] py-1.5 bg-orange-600 hover:bg-orange-700 text-white font-bold rounded-lg shadow-sm hover:shadow transition-all flex items-center justify-center gap-1 cursor-pointer"><span class="material-symbols-outlined text-[14px]">check</span>Xác nhận ca</button>';
        } else if (isMyShift && s.trangThai === 'Confirmed') {
          if (s.ngayLam === todayStr) {
            confirmBtnHtml = '<button onclick="checkInShift(' + s.caLamViecId + ')" class="mt-2.5 w-full text-[11px] py-1.5 bg-green-600 hover:bg-green-700 text-white font-bold rounded-lg shadow-sm hover:shadow transition-all flex items-center justify-center gap-1 cursor-pointer"><span class="material-symbols-outlined text-[14px]">login</span>Điểm danh vào ca</button>';
          } else {
            confirmBtnHtml = '<div class="mt-2.5 flex items-center justify-center gap-1 text-[10px] text-green-700 bg-green-50 border border-green-200/50 px-2 py-1 rounded-lg w-full font-bold"><span class="material-symbols-outlined text-[13px] text-green-600 font-bold">check_circle</span>Đã xác nhận</div>';
          }
        } else if (isMyShift && s.trangThai === 'CheckedIn') {
          confirmBtnHtml = '<button onclick="checkOutShift(' + s.caLamViecId + ')" class="mt-2.5 w-full text-[11px] py-1.5 bg-red-600 hover:bg-red-700 text-white font-bold rounded-lg shadow-sm hover:shadow transition-all flex items-center justify-center gap-1 cursor-pointer"><span class="material-symbols-outlined text-[14px]">logout</span>Kết thúc ca</button>';
        } else if (isMyShift && s.trangThai === 'CheckedOut') {
          confirmBtnHtml = '<div class="mt-2.5 flex items-center justify-center gap-1 text-[10px] text-zinc-700 bg-zinc-50 border border-zinc-200 px-2 py-1 rounded-lg w-full font-bold"><span class="material-symbols-outlined text-[13px] text-zinc-500 font-bold">task_alt</span>Đã hoàn thành</div>';
        }

        let breakHtml = '';
        if (s.gioNghi > 0) {
          breakHtml = '<div class="text-[9px] font-semibold text-red-500">Nghỉ: ' + s.gioNghi + 'm</div>';
        }

        let shiftInfoHtml = '<div class="text-[9px] font-medium opacity-80 mt-0.5">' + (s.tenCa ? s.tenCa : 'Tùy chỉnh') + (s.viTri ? ' · ' + s.viTri : '') + '</div>';

        html += '<div class="shift-block ' + bgColor + ' ' + borderStyle + ' ' + borderColor + ' rounded-lg p-2.5 transition-all shadow-sm" title="' + (s.ghiChu ? s.ghiChu : 'Không có ghi chú') + '">'
              + '<div class="flex items-center justify-between mb-1.5">'
              + '<span class="text-[10px] font-bold ' + titleColor + '">' + (isMyShift ? 'Ca của tôi' : 'Đồng nghiệp') + '</span>'
              + '<span class="text-[9px] px-1.5 py-0.5 rounded font-semibold ' + status.cssClass + '">' + status.label + '</span>'
              + '</div>'
              + '<p class="text-xs font-bold text-zinc-900">' + timeFrame + '</p>'
              + shiftInfoHtml
              + breakHtml
              + '<div class="text-[10px] text-zinc-500 opacity-90 truncate mt-1">' + (s.ghiChu ? s.ghiChu : 'Trực ca') + '</div>'
              + confirmBtnHtml
              + '</div>';
      });
    }

    html += '</div></div>';
  });

  html += '</div>';
  grid.innerHTML = html;
}

function confirmMyShift(caLamViecId) {
  if (confirm("Xác nhận bạn sẽ tham gia ca làm việc này?")) {
    const form = document.createElement('form');
    form.method = 'POST';
    form.action = _ctxPath + '/staff/ca-lam';
    
    const actionInput = document.createElement('input');
    actionInput.type = 'hidden';
    actionInput.name = 'action';
    actionInput.value = 'confirmShift';
    form.appendChild(actionInput);
    
    const idInput = document.createElement('input');
    idInput.type = 'hidden';
    idInput.name = 'caLamViecId';
    idInput.value = caLamViecId;
    form.appendChild(idInput);
    
    document.body.appendChild(form);
    form.submit();
  }
}

function checkInShift(caLamViecId) {
  if (confirm("Điểm danh vào ca làm việc này?")) {
    const form = document.createElement('form');
    form.method = 'POST';
    form.action = _ctxPath + '/staff/ca-lam';
    
    const actionInput = document.createElement('input');
    actionInput.type = 'hidden';
    actionInput.name = 'action';
    actionInput.value = 'checkIn';
    form.appendChild(actionInput);
    
    const idInput = document.createElement('input');
    idInput.type = 'hidden';
    idInput.name = 'caLamViecId';
    idInput.value = caLamViecId;
    form.appendChild(idInput);
    
    document.body.appendChild(form);
    form.submit();
  }
}

function checkOutShift(caLamViecId) {
  if (confirm("Xác nhận kết thúc ca làm việc?")) {
    const form = document.createElement('form');
    form.method = 'POST';
    form.action = _ctxPath + '/staff/ca-lam';
    
    const actionInput = document.createElement('input');
    actionInput.type = 'hidden';
    actionInput.name = 'action';
    actionInput.value = 'checkOut';
    form.appendChild(actionInput);
    
    const idInput = document.createElement('input');
    idInput.type = 'hidden';
    idInput.name = 'caLamViecId';
    idInput.value = caLamViecId;
    form.appendChild(idInput);
    
    document.body.appendChild(form);
    form.submit();
  }
}

function getStatusBadge(trangThai) {
  let statusClass = 'badge-zinc';
  let statusLabel = trangThai;
  if (trangThai === 'ChoXacNhan') {
    statusClass = 'badge-zinc';
    statusLabel = 'Chờ xác nhận';
  } else if (trangThai === 'ChoQuanLyDuyet') {
    statusClass = 'badge-yellow';
    statusLabel = 'Chờ quản lý duyệt';
  } else if (trangThai === 'DaDuyet') {
    statusClass = 'badge-green';
    statusLabel = 'Đã duyệt';
  } else if (trangThai === 'TuChoi') {
    statusClass = 'badge-red';
    statusLabel = 'Từ chối';
  } else if (trangThai === 'DaHuy') {
    statusClass = 'badge-zinc';
    statusLabel = 'Đã hủy';
  }
  return '<span class="badge ' + statusClass + '">' + statusLabel + '</span>';
}

function renderSwaps() {
  const myShiftsSelect = document.getElementById('swapMyShifts');
  const coworkersSelect = document.getElementById('swapCoworkers');
  if (!myShiftsSelect || !coworkersSelect) return;

  // 1. Populate my shifts select (only future published shifts)
  const todayStr = new Date().toISOString().split('T')[0];
  const myFutureShifts = shifts.filter(s => s.accountId === _currentUserId && s.ngayLam >= todayStr);
  myShiftsSelect.innerHTML = '<option value="">-- Chọn ca làm của bạn --</option>';
  myFutureShifts.forEach(s => {
    const opt = document.createElement('option');
    opt.value = s.caLamViecId;
    opt.textContent = formatDate(s.ngayLam) + ' (' + formatTime(s.gioBatDau) + ' - ' + formatTime(s.gioKetThuc) + ')';
    myShiftsSelect.appendChild(opt);
  });

  // 2. Populate coworkers select
  coworkersSelect.innerHTML = '<option value="">-- Chọn đồng nghiệp --</option>';
  coworkers.forEach(c => {
    const opt = document.createElement('option');
    opt.value = c.accountId;
    opt.textContent = c.fullName + ' (' + c.roleName + ')';
    coworkersSelect.appendChild(opt);
  });

  // Filter lists
  const receivedList = swaps.filter(sw => sw.accountIdNhan === _currentUserId && sw.trangThai === 'ChoXacNhan');
  const sentList = swaps.filter(sw => sw.accountIdGui === _currentUserId && (sw.trangThai === 'ChoXacNhan' || sw.trangThai === 'ChoQuanLyDuyet'));
  const historyList = swaps.filter(sw => 
    (sw.accountIdNhan === _currentUserId && sw.trangThai !== 'ChoXacNhan') ||
    (sw.accountIdGui === _currentUserId && sw.trangThai !== 'ChoXacNhan' && sw.trangThai !== 'ChoQuanLyDuyet')
  );

  // Update badge count
  const receivedBadge = document.getElementById('receivedBadge');
  if (receivedBadge) {
    if (receivedList.length > 0) {
      receivedBadge.textContent = receivedList.length;
      receivedBadge.classList.remove('hidden');
    } else {
      receivedBadge.classList.add('hidden');
    }
  }

  // 3. Render Received Requests
  const receivedBody = document.getElementById('receivedSwapListBody');
  if (receivedBody) {
    if (receivedList.length === 0) {
      receivedBody.innerHTML = '<tr><td colspan="5" class="px-4 py-8 text-center text-zinc-400 italic">Không có yêu cầu nào cần bạn xác nhận</td></tr>';
    } else {
      receivedBody.innerHTML = receivedList.map(function(sw) {
        const caNhan = sw.caNhanInfo ? sw.caNhanInfo : '<span class="text-gray-400 italic">Chỉ làm hộ</span>';
        const actionHtml = '<form action="' + _ctxPath + '/staff/ca-lam" method="POST" style="display:inline; margin-right: 8px;">'
                         + '<input type="hidden" name="action" value="respondSwap">'
                         + '<input type="hidden" name="id" value="' + sw.swapRequestId + '">'
                         + '<input type="hidden" name="accept" value="true">'
                         + '<button type="submit" class="text-xs font-bold px-3 py-1.5 bg-green-50 hover:bg-green-100 text-green-700 rounded-lg border border-green-200 cursor-pointer transition-all shadow-sm">Đồng ý</button>'
                         + '</form>'
                         + '<form action="' + _ctxPath + '/staff/ca-lam" method="POST" style="display:inline;">'
                         + '<input type="hidden" name="action" value="respondSwap">'
                         + '<input type="hidden" name="id" value="' + sw.swapRequestId + '">'
                         + '<input type="hidden" name="accept" value="false">'
                         + '<button type="submit" class="text-xs font-bold px-3 py-1.5 bg-red-50 hover:bg-red-100 text-red-650 rounded-lg border border-red-200 cursor-pointer transition-all shadow-sm">Từ chối</button>'
                         + '</form>';

        return '<tr class="hover:bg-orange-50/20 transition-colors">'
             + '<td class="px-4 py-3 font-semibold text-zinc-800">' + sw.tenNguoiGui + '</td>'
             + '<td class="px-4 py-3 text-xs text-orange-900 font-medium">' + sw.caGuiInfo + '</td>'
             + '<td class="px-4 py-3 text-xs text-blue-900 font-medium">' + caNhan + '</td>'
             + '<td class="px-4 py-3 text-xs text-zinc-500 max-w-[120px] truncate" title="' + (sw.lyDo ? sw.lyDo : '') + '">' + (sw.lyDo ? sw.lyDo : '') + '</td>'
             + '<td class="px-4 py-3 text-right">' + actionHtml + '</td>'
             + '</tr>';
      }).join('');
    }
  }

  // 4. Render Sent Requests
  const sentBody = document.getElementById('sentSwapListBody');
  if (sentBody) {
    if (sentList.length === 0) {
      sentBody.innerHTML = '<tr><td colspan="5" class="px-4 py-8 text-center text-zinc-400 italic">Bạn chưa gửi yêu cầu đổi ca nào đang hoạt động</td></tr>';
    } else {
      sentBody.innerHTML = sentList.map(function(sw) {
        const caNhan = sw.caNhanInfo ? sw.caNhanInfo : '<span class="text-gray-400 italic">Chỉ làm hộ</span>';
        let statusBadge = getStatusBadge(sw.trangThai);
        if (sw.trangThai === 'ChoXacNhan') {
          statusBadge = '<span class="badge badge-zinc">Chờ đồng nghiệp duyệt</span>';
        }
        return '<tr class="hover:bg-orange-50/20 transition-colors">'
             + '<td class="px-4 py-3 font-semibold text-zinc-800">' + sw.tenNguoiNhan + '</td>'
             + '<td class="px-4 py-3 text-xs text-orange-900 font-medium">' + sw.caGuiInfo + '</td>'
             + '<td class="px-4 py-3 text-xs text-blue-900 font-medium">' + caNhan + '</td>'
             + '<td class="px-4 py-3 text-xs text-zinc-500 max-w-[120px] truncate" title="' + (sw.lyDo ? sw.lyDo : '') + '">' + (sw.lyDo ? sw.lyDo : '') + '</td>'
             + '<td class="px-4 py-3">' + statusBadge + '</td>'
             + '</tr>';
      }).join('');
    }
  }

  // 5. Render History
  const historyBody = document.getElementById('historySwapListBody');
  if (historyBody) {
    if (historyList.length === 0) {
      historyBody.innerHTML = '<tr><td colspan="6" class="px-4 py-8 text-center text-zinc-400 italic">Không có lịch sử yêu cầu đổi ca nào</td></tr>';
    } else {
      historyBody.innerHTML = historyList.map(function(sw) {
        const isSender = (sw.accountIdGui === _currentUserId);
        const partnerName = isSender ? sw.tenNguoiNhan : sw.tenNguoiGui;
        const roleText = isSender ? '<span class="text-xs text-orange-700 font-bold">Người gửi</span>' : '<span class="text-xs text-blue-700 font-bold">Người nhận</span>';
        const caNhan = sw.caNhanInfo ? sw.caNhanInfo : '<span class="text-gray-400 italic">Chỉ làm hộ</span>';
        const noteText = sw.ghiChuQuanLy ? sw.ghiChuQuanLy : '<span class="text-gray-400 italic">-</span>';

        return '<tr class="hover:bg-orange-50/20 transition-colors">'
             + '<td class="px-4 py-3 font-semibold text-zinc-800">' + partnerName + '</td>'
             + '<td class="px-4 py-3">' + roleText + '</td>'
             + '<td class="px-4 py-3 text-xs text-orange-900 font-medium">' + sw.caGuiInfo + '</td>'
             + '<td class="px-4 py-3 text-xs text-blue-900 font-medium">' + caNhan + '</td>'
             + '<td class="px-4 py-3">' + getStatusBadge(sw.trangThai) + '</td>'
             + '<td class="px-4 py-3 text-xs text-zinc-550 max-w-[150px] truncate" title="' + (sw.ghiChuQuanLy || '') + '">' + noteText + '</td>'
             + '</tr>';
      }).join('');
    }
  }
}

function loadCoworkerShifts() {
  const coworkerId = document.getElementById('swapCoworkers').value;
  const selectShifts = document.getElementById('swapCoworkerShifts');
  if (!selectShifts) return;

  selectShifts.innerHTML = '<option value="">-- Chỉ nhờ làm hộ (Cover request) --</option>';
  if (!coworkerId) return;

  const todayStr = new Date().toISOString().split('T')[0];
  const coworkerFutureShifts = shifts.filter(s => s.accountId === parseInt(coworkerId) && s.ngayLam >= todayStr);

  coworkerFutureShifts.forEach(s => {
    const opt = document.createElement('option');
    opt.value = s.caLamViecId;
    opt.textContent = formatDate(s.ngayLam) + ' (' + formatTime(s.gioBatDau) + ' - ' + formatTime(s.gioKetThuc) + ')';
    selectShifts.appendChild(opt);
  });
}

// ==================== INITIALIZATION ====================

document.addEventListener('DOMContentLoaded', () => {
  loadData();
  switchSwapSubTab(currentSwapSubTab);

  // Mobile menu toggle
  const mobileMenuBtn = document.getElementById('mobileMenuBtn');
  if (mobileMenuBtn) {
    mobileMenuBtn.addEventListener('click', () => {
      document.getElementById('sidebar').classList.toggle('-translate-x-full');
    });
  }
});
</script>
</body>
</html>
