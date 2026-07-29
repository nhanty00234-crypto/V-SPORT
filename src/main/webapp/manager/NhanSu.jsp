<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
<title>Quản lý nhân sự cơ sở — V-SPORT</title>
<jsp:include page="/manager/common/manager_head.jsp" />
<style>
  .nav-link { display:flex;align-items:center;gap:11px;padding:10px 14px;border-radius:10px;color:#52525b;font-size:14px;font-weight:500;text-decoration:none;transition:all .15s;white-space:nowrap;position:relative; }
  .nav-link:hover { background:#f4f4f5;color:#18181b; }
  .nav-link.active { background:#f4f4f5;color:#18181b;font-weight:600; }
  .nav-link.active::before { content:''; position:absolute; left:0; top:8px; bottom:8px; width:3px; background:#27272a; border-radius:0 3px 3px 0; }

  /* Sub-navigation Tabs */
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
    background: #7c3aed;
    color: white;
    box-shadow: 0 4px 6px -1px rgba(124, 58, 237, 0.3);
  }
  .nav-link-tab .material-symbols-outlined {
    font-size: 18px;
  }

  /* ==================== Cute animated toast (manager/violet theme) ==================== */
  @keyframes vsToastIn {
    0%   { opacity: 0; transform: translateY(-14px) scale(.92); }
    60%  { opacity: 1; transform: translateY(3px) scale(1.02); }
    100% { opacity: 1; transform: translateY(0) scale(1); }
  }
  @keyframes vsToastOut {
    0%   { opacity: 1; transform: translateY(0) scale(1); max-height: 120px; margin-bottom: 8px; }
    100% { opacity: 0; transform: translateY(-10px) scale(.95); max-height: 0; margin-bottom: 0; }
  }
  @keyframes vsToastPop {
    0%, 100% { transform: scale(1); }
    50% { transform: scale(1.18); }
  }
  @keyframes vsShake {
    10%, 90% { transform: translateX(-1px); }
    20%, 80% { transform: translateX(2px); }
    30%, 50%, 70% { transform: translateX(-5px); }
    40%, 60% { transform: translateX(5px); }
  }
  .vs-toast {
    animation: vsToastIn .38s cubic-bezier(.34,1.56,.64,1) both;
    overflow: hidden;
  }
  .vs-toast.vs-toast-leaving {
    animation: vsToastOut .28s ease forwards;
  }
  .vs-toast .vs-toast-icon {
    animation: vsToastPop .5s cubic-bezier(.34,1.56,.64,1) .1s both;
  }
  .vs-shake {
    animation: vsShake .45s cubic-bezier(.36,.07,.19,.97) both;
  }
  .vs-field-error {
    border-color: #fb7185 !important;
    box-shadow: 0 0 0 3px rgba(244,63,94,.12) !important;
  }
  .vs-field-error-msg {
    color: #e11d48;
    font-size: 11px;
    font-weight: 600;
    margin-top: 2px;
    display: flex;
    align-items: center;
    gap: 3px;
    animation: vsToastIn .3s ease both;
  }
</style>
</head>
<body class="text-zinc-900 min-h-screen">

<!-- Sidebar -->
<jsp:include page="/manager/common/sidebar.jsp" />

<!-- Header -->
<c:set var="headerTitle" value="Quản lý nhân sự cơ sở" scope="page" />
<c:set var="headerSubtitle" value="Quyền hạn Quản lý · Cơ sở CS${sessionScope.user.coSoId}" scope="page" />
<c:set var="headerIcon" value="security" scope="page" />
<jsp:include page="/manager/common/header.jsp" />

<main class="lg:ml-[248px] mt-[64px] p-4 lg:p-6 flex flex-col gap-5">
  <!-- Sub-navigation -->
  <div class="flex gap-2 mb-2">
    <button onclick="switchView('staff')" id="nav-staff" class="nav-link-tab active">
      <span class="material-symbols-outlined text-[16px]">people</span>
      Nhân viên
    </button>
    <button onclick="switchView('leave')" id="nav-leave" class="nav-link-tab">
      <span class="material-symbols-outlined text-[16px]">assignment</span>
      Yêu cầu nghỉ
    </button>
  </div>

  <!-- Staff Section (View 1) -->
  <div id="viewStaffSection">
    <div class="flex items-center justify-between gap-4 mb-2">
      <h2 class="text-lg font-bold text-violet-950">Danh sách nhân viên <span class="text-xs bg-violet-100 px-1.5 py-0.5 rounded font-semibold text-violet-700" id="staffCountDisplay">0</span></h2>
      <div class="flex gap-2">
        <button onclick="openAddStaff()" class="flex items-center justify-center gap-1.5 h-10 px-5 rounded-xl bg-violet-600 text-white text-sm font-semibold hover:bg-violet-700 transition-all shadow-md shadow-violet-100">
          <span class="material-symbols-outlined text-[18px]">person_add</span>Thêm nhân viên
        </button>
      </div>
    </div>

    <!-- Alert Messages -->
    <c:if test="${not empty sessionScope.error}">
      <div class="p-4 bg-red-50 border border-red-100 rounded-xl text-red-600 text-sm flex items-start gap-3 animate-fade-in-up">
        <span class="material-symbols-outlined text-[20px] shrink-0">error</span>
        <div>
          <span class="font-bold block text-red-700">Lỗi thao tác</span>
          <span class="text-red-600/95 leading-normal block mt-0.5">${sessionScope.error}</span>
        </div>
        <% session.removeAttribute("error"); %>
      </div>
    </c:if>
    <c:if test="${not empty sessionScope.message}">
      <div class="p-4 bg-violet-50 border border-violet-100 rounded-xl text-violet-600 text-sm flex items-start gap-3 animate-fade-in-up">
        <span class="material-symbols-outlined text-[20px] shrink-0">check_circle</span>
        <div>
          <span class="font-bold block text-violet-700">Thành công</span>
          <span class="text-violet-600/95 leading-normal block mt-0.5">${sessionScope.message}</span>
        </div>
        <% session.removeAttribute("message"); %>
      </div>
    </c:if>

    <div class="w-full" id="staffGridContainer">
      <div id="staffGrid" class="flex flex-col divide-y divide-violet-50 bg-white border border-violet-100 rounded-2xl overflow-hidden shadow-sm"></div>
    </div>
  </div>

  <!-- ==================== VIEW 3: YÊU CẦU NGHỈ ==================== -->
  <div id="viewLeaveSection" class="hidden">
    <!-- Header -->
    <div class="flex items-center justify-between gap-4 mb-3">
      <div>
        <h2 class="text-lg font-bold text-violet-950">Quản lý yêu cầu nghỉ</h2>
        <p class="text-xs text-zinc-500">Duyệt và quản lý yêu cầu nghỉ phép của nhân viên</p>
      </div>
      <button onclick="switchView('staff')" class="flex items-center justify-center gap-1.5 h-10 px-5 rounded-xl bg-violet-100 text-violet-750 text-sm font-semibold hover:bg-violet-200 transition-all">
        <span class="material-symbols-outlined text-[18px]">arrow_back</span>
        Quay lại nhân viên
      </button>
    </div>

    <!-- Stats Cards -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-5 mb-5">
      <div class="card p-5 bg-white border border-zinc-100 rounded-2xl flex items-center justify-between shadow-sm">
        <div class="flex flex-col gap-1">
          <span class="text-xs font-medium text-zinc-500">Tất cả yêu cầu</span>
          <span class="text-2xl font-extrabold text-zinc-800" id="leaveTotalCount">0</span>
        </div>
        <div class="w-12 h-12 rounded-xl bg-violet-50 text-violet-600 flex items-center justify-center">
          <span class="material-symbols-outlined text-[24px]">assignment</span>
        </div>
      </div>
      <div class="card p-5 bg-white border border-zinc-100 rounded-2xl flex items-center justify-between shadow-sm">
        <div class="flex flex-col gap-1">
          <span class="text-xs font-medium text-zinc-500">Chờ duyệt</span>
          <span class="text-2xl font-extrabold text-amber-600" id="leavePendingCount">0</span>
        </div>
        <div class="w-12 h-12 rounded-xl bg-amber-50 text-amber-600 flex items-center justify-center">
          <span class="material-symbols-outlined text-[24px]">pending_actions</span>
        </div>
      </div>
      <div class="card p-5 bg-white border border-zinc-100 rounded-2xl flex items-center justify-between shadow-sm">
        <div class="flex flex-col gap-1">
          <span class="text-xs font-medium text-zinc-500">Đã duyệt</span>
          <span class="text-2xl font-extrabold text-emerald-600" id="leaveApprovedCount">0</span>
        </div>
        <div class="w-12 h-12 rounded-xl bg-emerald-50 text-emerald-600 flex items-center justify-center">
          <span class="material-symbols-outlined text-[24px]">check_circle</span>
        </div>
      </div>
    </div>

    <!-- Filter -->
    <div class="flex flex-wrap items-center justify-between gap-4 mb-4">
      <div class="flex items-center gap-2 bg-zinc-100 p-1 rounded-xl">
        <button onclick="filterLeaveRequests('all', this)" class="leave-filter-btn px-4 py-2 text-xs font-bold rounded-lg bg-white text-zinc-800 shadow-sm transition-all cursor-pointer">Tất cả</button>
        <button onclick="filterLeaveRequests('ChoDuyet', this)" class="leave-filter-btn px-4 py-2 text-xs font-bold rounded-lg text-zinc-600 hover:text-zinc-900 transition-all cursor-pointer">Chờ duyệt</button>
        <button onclick="filterLeaveRequests('DaDuyet', this)" class="leave-filter-btn px-4 py-2 text-xs font-bold rounded-lg text-zinc-600 hover:text-zinc-900 transition-all cursor-pointer">Đã duyệt</button>
        <button onclick="filterLeaveRequests('TuChoi', this)" class="leave-filter-btn px-4 py-2 text-xs font-bold rounded-lg text-zinc-600 hover:text-zinc-900 transition-all cursor-pointer">Từ chối</button>
      </div>
    </div>

    <!-- Leave Requests Table -->
    <div class="card overflow-hidden">
      <div class="overflow-x-auto">
        <table class="w-full text-left border-collapse text-xs">
          <thead>
            <tr class="bg-violet-50/50 text-violet-950 font-bold border-b border-violet-100">
              <th class="p-4 w-12 text-center">#</th>
              <th class="p-4">Nhân viên</th>
              <th class="p-4">Vai trò</th>
              <th class="p-4">Ngày nghỉ</th>
              <th class="p-4">Loại nghỉ</th>
              <th class="p-4">Lý do</th>
              <th class="p-4">Trạng thái</th>
              <th class="p-4">Ngày gửi</th>
              <th class="p-4 text-right pr-6">Thao tác</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-violet-50" id="leaveRequestBody">
            <!-- Populated by JS -->
          </tbody>
        </table>
      </div>
      <!-- Empty State -->
      <div id="leaveEmptyState" class="hidden flex flex-col items-center justify-center py-12 px-4 text-center">
        <span class="material-symbols-outlined text-[48px] text-violet-200 mb-2">event_busy</span>
        <p class="text-zinc-500 text-sm font-medium">Chưa có yêu cầu nghỉ nào</p>
      </div>
    </div>
  </div>
</main>

<!-- Staff Modal -->
<div id="staffModal" class="hidden fixed inset-0 z-[80] flex items-center justify-center p-4">
  <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" onclick="nudgeStaffModal()"></div>
  <div id="staffModalBox" class="relative bg-white rounded-2xl shadow-2xl w-full max-w-[480px]">
    <div class="flex items-center justify-between px-6 py-4 border-b border-violet-50">
      <h2 id="staffModalTitle" class="text-base font-semibold text-violet-950">Thêm nhân viên</h2>
      <button onclick="closeStaffModal()" class="p-1.5 rounded-lg hover:bg-violet-50"><span class="material-symbols-outlined text-[18px] text-zinc-500">close</span></button>
    </div>
    <form id="staffForm" onsubmit="handleStaffSubmit(event)" class="px-6 py-4 flex flex-col gap-4">
      <input type="hidden" id="staffEditId" value="">
      
      <!-- Container for staff fields -->
      <div id="staffFieldsContainer" class="flex flex-col gap-4">
          <div class="flex flex-col gap-1.5">
            <label class="text-xs font-semibold text-violet-900">Họ và tên <span class="text-red-500">*</span></label>
            <input type="text" id="staffName" required class="h-9 px-3 rounded-lg border border-violet-100 text-sm focus:ring-2 focus:ring-violet-400 focus:outline-none">
          </div>
          <div class="flex flex-col gap-1.5">
            <label class="text-xs font-semibold text-violet-900">Vai trò <span class="text-red-500">*</span></label>
            <select id="staffRole" required class="h-9 px-3 rounded-lg border border-violet-100 text-sm focus:ring-2 focus:ring-violet-400 focus:outline-none">
              <option value="4">Lễ tân</option>
              <option value="5">Bảo vệ</option>
            </select>
          </div>
          <div class="flex flex-col gap-1.5">
            <label class="text-xs font-semibold text-violet-900">Email <span class="text-red-500">*</span></label>
            <input type="email" id="staffEmail" required class="h-9 px-3 rounded-lg border border-violet-100 text-sm focus:ring-2 focus:ring-violet-400 focus:outline-none">
          </div>
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <div class="flex flex-col gap-1.5">
              <label class="text-xs font-semibold text-violet-900">Điện thoại</label>
              <input type="tel" id="staffPhone" class="h-9 px-3 rounded-lg border border-violet-100 text-sm focus:ring-2 focus:ring-violet-400 focus:outline-none">
            </div>
            <div class="flex flex-col gap-1.5">
              <label class="text-xs font-semibold text-violet-900">Mật khẩu <span class="text-red-500">*</span></label>
              <div class="relative flex items-center">
                <input type="password" id="staffPassword" placeholder="••••••••" autocomplete="new-password" required class="h-9 pl-3 pr-10 rounded-lg border border-violet-100 text-sm focus:ring-2 focus:ring-violet-400 focus:outline-none w-full">
                <button type="button" onclick="togglePasswordVisibility()" class="absolute right-3 text-zinc-400 hover:text-zinc-650 focus:outline-none flex items-center">
                  <span id="passwordEyeIcon" class="material-symbols-outlined text-[18px]">visibility</span>
                </button>
              </div>
            </div>
          </div>

          <div class="flex justify-end gap-2 mt-3 pt-4 border-t border-violet-50">
            <button type="button" onclick="closeStaffModal()"
                    class="h-9 px-4 rounded-lg border border-violet-100 text-sm font-semibold hover:bg-violet-50 text-zinc-650 transition-colors">Hủy</button>
            <button type="submit"
                    class="h-9 px-5 rounded-lg bg-violet-600 text-white text-sm font-semibold hover:bg-violet-700 shadow shadow-violet-200 transition-colors">Lưu thông tin</button>
          </div>
      </div>

      <!-- Container for OTP Verification (Hidden by default) -->
      <div id="otpVerificationSection" class="hidden flex flex-col gap-4 text-center py-4">
          <div class="inline-flex mx-auto items-center justify-center w-12 h-12 rounded-full bg-emerald-50 text-emerald-600 mb-2">
              <span class="material-symbols-outlined text-[24px]">mark_email_read</span>
          </div>
          <div>
              <h3 class="text-sm font-bold text-violet-950">Xác thực OTP thay đổi Email</h3>
              <p class="text-xs text-violet-500 mt-1">Một mã xác thực gồm 6 chữ số đã được gửi tới <span class="font-bold text-violet-900" id="otpTargetEmail"></span>.</p>
          </div>
          
          <div class="flex gap-2 justify-center my-3" id="otpBoxesContainer">
              <input type="tel" inputmode="numeric" pattern="[0-9]*" maxlength="1" autocomplete="one-time-code" class="otp-box w-10 h-12 border border-violet-200 rounded-xl text-center font-bold text-lg text-violet-950 focus:border-violet-600 focus:ring-4 focus:ring-violet-100 outline-none transition-all">
              <input type="tel" inputmode="numeric" pattern="[0-9]*" maxlength="1" autocomplete="one-time-code" class="otp-box w-10 h-12 border border-violet-200 rounded-xl text-center font-bold text-lg text-violet-950 focus:border-violet-600 focus:ring-4 focus:ring-violet-100 outline-none transition-all">
              <input type="tel" inputmode="numeric" pattern="[0-9]*" maxlength="1" autocomplete="one-time-code" class="otp-box w-10 h-12 border border-violet-200 rounded-xl text-center font-bold text-lg text-violet-950 focus:border-violet-600 focus:ring-4 focus:ring-violet-100 outline-none transition-all">
              <input type="tel" inputmode="numeric" pattern="[0-9]*" maxlength="1" autocomplete="one-time-code" class="otp-box w-10 h-12 border border-violet-200 rounded-xl text-center font-bold text-lg text-violet-950 focus:border-violet-600 focus:ring-4 focus:ring-violet-100 outline-none transition-all">
              <input type="tel" inputmode="numeric" pattern="[0-9]*" maxlength="1" autocomplete="one-time-code" class="otp-box w-10 h-12 border border-violet-200 rounded-xl text-center font-bold text-lg text-violet-950 focus:border-violet-600 focus:ring-4 focus:ring-violet-100 outline-none transition-all">
              <input type="tel" inputmode="numeric" pattern="[0-9]*" maxlength="1" autocomplete="one-time-code" class="otp-box w-10 h-12 border border-violet-200 rounded-xl text-center font-bold text-lg text-violet-950 focus:border-violet-600 focus:ring-4 focus:ring-violet-100 outline-none transition-all">
          </div>
          
          <div class="text-xs text-violet-600 font-medium">
              Chưa nhận được mã? 
              <button type="button" id="btnResendOtpStaff" onclick="resendStaffOtp()" class="font-bold text-violet-700 hover:underline disabled:opacity-40 disabled:no-underline cursor-pointer">
                  Gửi lại mã (<span id="resendCountDisplay">0</span>/5)
              </button>
              <span id="resendTimerDisplay" class="text-violet-500 font-normal ml-1 hidden">(chờ <span id="timerSeconds">60</span>s)</span>
          </div>

          <div id="otpNoticeBanner" class="hidden p-2.5 bg-emerald-50 border border-emerald-200 text-emerald-700 text-xs font-semibold rounded-lg flex items-center justify-center gap-1.5 mt-2">
              <span class="material-symbols-outlined text-[16px]">check_circle</span>
              <span id="otpNoticeMsgText"></span>
          </div>

          <div id="otpErrorBanner" class="hidden p-2.5 bg-red-50 border border-red-100 text-red-650 text-xs font-semibold rounded-lg flex items-center justify-center gap-1.5 mt-2">
              <span class="material-symbols-outlined text-[16px]">error</span>
              <span id="otpErrorMsgText">Mã OTP không hợp lệ.</span>
          </div>

          <div class="flex gap-2 justify-end mt-4 pt-4 border-t border-violet-50">
              <button type="button" onclick="cancelOtpVerification()" class="h-9 px-4 rounded-lg border border-violet-100 text-sm font-semibold hover:bg-violet-50 text-zinc-650">Quay lại</button>
              <button type="button" id="otpConfirmBtn" onclick="submitOtpVerification()" class="h-9 px-5 rounded-lg bg-violet-600 text-white text-sm font-semibold hover:bg-violet-700 shadow shadow-violet-200 flex items-center gap-1.5">
                  Xác nhận
                  <span class="material-symbols-outlined text-[16px]">check</span>
              </button>
          </div>
      </div>
    </form>
  </div>
</div>



<script>
// Context path initialized server-side (avoids JSP EL conflicts inside JS template literals)
var _ctxPath = '<%=request.getContextPath()%>';

function showNotification(type, message) {
    let container = document.getElementById('toast-container');
    if (!container) {
        container = document.createElement('div');
        container.id = 'toast-container';
        container.className = 'fixed top-4 right-4 z-[100] flex flex-col gap-2 max-w-sm w-full pointer-events-none';
        document.body.appendChild(container);
    }
    
    const toast = document.createElement('div');
    toast.className = `p-4 rounded-xl shadow-lg border text-sm flex items-start gap-3 animate-fade-in-up pointer-events-auto transition-all duration-300 transform translate-x-0`;
    
    let icon = 'info';
    let bgColor = 'bg-white';
    let borderColor = 'border-violet-100';
    let textColor = 'text-violet-900';
    let iconColor = 'text-violet-600';
    
    if (type === 'success') {
        icon = 'check_circle';
        bgColor = 'bg-green-50';
        borderColor = 'border-green-200';
        textColor = 'text-green-900';
        iconColor = 'text-green-600';
    } else if (type === 'error') {
        icon = 'error';
        bgColor = 'bg-red-50';
        borderColor = 'border-red-200';
        textColor = 'text-red-900';
        iconColor = 'text-red-600';
    }
    
    toast.className += ` ${bgColor} ${borderColor} ${textColor}`;
    
    toast.innerHTML = `
        <span class="material-symbols-outlined \${iconColor} shrink-0">\${icon}</span>
        <div class="flex-1">
            <span class="font-bold block">\${type === 'success' ? 'Thành công' : 'Thất bại'}</span>
            <span class="leading-normal block mt-0.5">\${message}</span>
        </div>
        <button onclick="this.parentElement.remove()" class="text-zinc-400 hover:text-zinc-700 shrink-0"><span class="material-symbols-outlined text-[18px]">close</span></button>
    `;
    
    container.appendChild(toast);
    
    setTimeout(() => {
        toast.style.opacity = '0';
        toast.style.transform = 'translateX(100px)';
        setTimeout(() => toast.remove(), 300);
    }, 4000);
}

// Cute, animated toast in the manager (violet) brand color — replaces native alert().
function showVsToast(message, type) {
    type = type || 'info';
    let container = document.getElementById('vs-toast-container');
    if (!container) {
        container = document.createElement('div');
        container.id = 'vs-toast-container';
        container.className = 'fixed top-5 right-5 z-[300] flex flex-col gap-2 max-w-sm w-full pointer-events-none';
        document.body.appendChild(container);
    }

    const presets = {
        success: { bg: 'bg-emerald-50', border: 'border-emerald-200', text: 'text-emerald-900', icon: 'text-emerald-600', emoji: 'check_circle', title: 'Tuyệt vời!' },
        error:   { bg: 'bg-rose-50',    border: 'border-rose-200',    text: 'text-rose-900',    icon: 'text-rose-600',    emoji: 'sentiment_dissatisfied', title: 'Ối, có lỗi rồi' },
        info:    { bg: 'bg-violet-50',  border: 'border-violet-200',  text: 'text-violet-900',  icon: 'text-violet-600',  emoji: 'mark_email_read', title: 'Thông báo' }
    };
    const p = presets[type] || presets.info;

    const toast = document.createElement('div');
    toast.className = `vs-toast pointer-events-auto p-4 rounded-2xl shadow-lg border text-sm flex items-start gap-3 ${p.bg} ${p.border} ${p.text}`;
    toast.innerHTML = `
        <span class="vs-toast-icon material-symbols-outlined ${p.icon} shrink-0" style="font-variation-settings:'FILL' 1">${p.emoji}</span>
        <div class="flex-1 min-w-0">
            <span class="font-bold block">${p.title}</span>
            <span class="leading-normal block mt-0.5 break-words">${message}</span>
        </div>
        <button type="button" class="text-current opacity-40 hover:opacity-80 shrink-0" onclick="dismissVsToast(this.parentElement)"><span class="material-symbols-outlined text-[18px]">close</span></button>
    `;
    container.appendChild(toast);

    const timer = setTimeout(() => dismissVsToast(toast), 4200);
    toast._vsTimer = timer;
}

function dismissVsToast(toast) {
    if (!toast || toast._vsLeaving) return;
    toast._vsLeaving = true;
    if (toast._vsTimer) clearTimeout(toast._vsTimer);
    toast.classList.add('vs-toast-leaving');
    setTimeout(() => toast.remove(), 300);
}

// Gently nudges (shakes) the modal instead of closing it when the user clicks
// the backdrop — prevents accidental loss of in-progress form data.
function nudgeStaffModal() {
    const box = document.getElementById('staffModalBox');
    if (!box) return;
    box.classList.remove('vs-shake');
    void box.offsetWidth; // restart animation
    box.classList.add('vs-shake');
    setTimeout(() => box.classList.remove('vs-shake'), 500);
}

function shakeOtpBoxes() {
    const box = document.getElementById('otpBoxesContainer');
    if (!box) return;
    box.classList.remove('vs-shake');
    void box.offsetWidth;
    box.classList.add('vs-shake');
    setTimeout(() => box.classList.remove('vs-shake'), 500);
}

// Highlights an invalid field with a red ring + inline message + shake, in the manager brand color scheme.
function markFieldInvalid(fieldId, msg) {
    const el = document.getElementById(fieldId);
    if (!el) return;
    el.classList.add('vs-field-error');
    let hint = el.parentElement.querySelector('.vs-field-error-msg');
    if (!hint) {
        hint = document.createElement('span');
        hint.className = 'vs-field-error-msg';
        hint.innerHTML = '<span class="material-symbols-outlined text-[13px]">error</span><span></span>';
        el.insertAdjacentElement('afterend', hint);
    }
    hint.querySelector('span:last-child').textContent = msg;
    el.classList.add('vs-shake');
    setTimeout(() => el.classList.remove('vs-shake'), 500);
    el.focus();
    const clear = () => {
        el.classList.remove('vs-field-error');
        if (hint) hint.remove();
        el.removeEventListener('input', clear);
    };
    el.addEventListener('input', clear);
}

function clearFieldErrors() {
    document.querySelectorAll('.vs-field-error-msg').forEach(h => h.remove());
    document.querySelectorAll('.vs-field-error').forEach(f => f.classList.remove('vs-field-error'));
}

let staffList = [];

// Load staff list on page load
async function loadStaffList() {
    try {
        const response = await fetch(_ctxPath + '/manager/nhan-su?action=list');
        if (response.ok) {
            staffList = await response.json();
            renderStaff();
        } else {
            console.error('Failed to load staff list');
        }
    } catch (error) {
        console.error('Error loading staff:', error);
    }
}

function renderStaff() {
    const staffGrid = document.getElementById('staffGrid');
    if (!staffGrid) return;
    document.getElementById('staffCountDisplay').innerText = staffList.length;

    if (staffList.length === 0) {
        staffGrid.innerHTML = `
            <div class="py-16 text-center text-violet-400">
                <span class="material-symbols-outlined text-4xl mb-2 text-violet-200">group_off</span>
                <p class="text-xs font-medium">Chưa có nhân viên nào tại chi nhánh này</p>
            </div>
        `;
        return;
    }

    staffGrid.innerHTML = staffList.map(s => {
        let badgeClass = s.status === 'Đang làm' ? 'badge-green' : 'badge-red';
        let statusText = s.status;

        let dept = 'Phòng ban';
        if (s.roleId === 4) dept = 'Lễ tân';
        else if (s.roleId === 5) dept = 'Bảo vệ';
        else dept = 'Nhân sự';

        let avatarUrl = s.avatarUrl
            ? (_ctxPath + s.avatarUrl)
            : `https://ui-avatars.com/api/?name=\${encodeURIComponent(s.name)}&background=7c3aed&color=fff&size=128&bold=true`;

        return `
            <div class="flex items-center gap-3 px-4 py-2.5 hover:bg-violet-50/40 transition-colors">
                <img src="\${avatarUrl}" alt="\${s.name}" class="w-9 h-9 rounded-full border border-violet-100 shrink-0">

                <div class="min-w-0 w-[180px] shrink-0">
                    <p class="font-bold text-violet-950 text-sm leading-tight truncate">\${s.name}</p>
                    <p class="text-[11px] text-violet-500 font-semibold truncate">\${s.VaiTro} · \${dept}</p>
                </div>

                <div class="min-w-0 flex-1 hidden sm:flex items-center gap-4 text-xs text-zinc-500">
                    <span class="flex items-center gap-1 truncate" title="\${s.email}">
                        <span class="material-symbols-outlined text-[14px] text-violet-300 shrink-0">mail</span>\${s.email}
                    </span>
                    <span class="flex items-center gap-1 shrink-0">
                        <span class="material-symbols-outlined text-[14px] text-violet-300 shrink-0">phone_iphone</span>\${s.phone}
                    </span>
                </div>

                <span class="badge \${badgeClass} shrink-0">\${statusText}</span>

                <div class="flex items-center gap-1 shrink-0">
                    <button onclick="editStaff('\${s.id}')" title="Sửa thông tin" class="h-7 w-7 rounded-lg border border-violet-200 text-violet-700 hover:bg-violet-50 flex items-center justify-center transition-all">
                        <span class="material-symbols-outlined text-[15px]">edit</span>
                    </button>
                    <button onclick="deleteStaff('\${s.id}')" title="Xóa nhân viên" class="h-7 w-7 rounded-lg border border-red-200 text-red-500 hover:bg-red-50 flex items-center justify-center transition-all">
                        <span class="material-symbols-outlined text-[15px]">person_remove</span>
                    </button>
                </div>
            </div>
        `;
    }).join('');
}



// ==================== Staff CRUD ====================

function openAddStaff() {
    document.getElementById('staffForm').reset();
    document.getElementById('staffModalTitle').innerText = 'Thêm nhân viên mới';
    document.getElementById('staffEditId').value = '';
    document.getElementById('staffPassword').required = true;
    clearFieldErrors();

    // Reset OTP containers
    document.getElementById('staffFieldsContainer').classList.remove('hidden');
    document.getElementById('otpVerificationSection').classList.add('hidden');
    document.querySelectorAll('.otp-box').forEach(b => b.value = '');
    document.getElementById('otpErrorBanner').classList.add('hidden');

    document.getElementById('staffModal').classList.remove('hidden');
}

function editStaff(id) {
    const s = staffList.find(x => x.id == id);
    if (!s) return;
    document.getElementById('staffModalTitle').innerText = 'Chỉnh sửa tài khoản nhân viên';
    document.getElementById('staffEditId').value = s.id;
    document.getElementById('staffName').value = s.name;
    document.getElementById('staffEmail').value = s.email;
    document.getElementById('staffPhone').value = s.phone;
    clearFieldErrors();

    // Reset OTP containers
    document.getElementById('staffFieldsContainer').classList.remove('hidden');
    document.getElementById('otpVerificationSection').classList.add('hidden');
    document.querySelectorAll('.otp-box').forEach(b => b.value = '');
    document.getElementById('otpErrorBanner').classList.add('hidden');

    document.getElementById('staffModal').classList.remove('hidden');
}

function closeStaffModal() { document.getElementById('staffModal').classList.add('hidden'); }

function togglePasswordVisibility() {
    const pwdInput = document.getElementById('staffPassword');
    const eyeIcon = document.getElementById('passwordEyeIcon');
    if (pwdInput && eyeIcon) {
        pwdInput.type = pwdInput.type === 'password' ? 'text' : 'password';
        eyeIcon.textContent = pwdInput.type === 'password' ? 'visibility' : 'visibility_off';
    }
}

// Setup input events for 6 OTP boxes
document.addEventListener('DOMContentLoaded', () => {
    const boxes = document.querySelectorAll('.otp-box');
    boxes.forEach((box, idx, arr) => {
        box.addEventListener('input', (e) => {
            const digits = e.target.value.replace(/\D/g, '');

            if (digits.length > 1) {
                // Browser autofill (SMS/one-time-code) or fast typing delivered
                // multiple characters in a single input event — distribute them
                // across this box and the following ones instead of dropping them.
                for (let i = 0; i < digits.length && idx + i < arr.length; i++) {
                    arr[idx + i].value = digits[i];
                }
                const lastFilledIdx = Math.min(idx + digits.length, arr.length) - 1;
                arr[Math.max(0, Math.min(lastFilledIdx + 1, arr.length - 1))].focus();
                return;
            }

            e.target.value = digits;
            if (digits && idx < arr.length - 1) {
                arr[idx + 1].focus();
            }
        });
        box.addEventListener('keydown', (e) => {
            if (e.key === 'Backspace') {
                if (!e.target.value && idx > 0) {
                    arr[idx - 1].focus();
                    arr[idx - 1].value = '';
                }
            } else if (e.key === 'ArrowLeft' && idx > 0) {
                arr[idx - 1].focus();
            } else if (e.key === 'ArrowRight' && idx < arr.length - 1) {
                arr[idx + 1].focus();
            }
        });
        box.addEventListener('paste', (e) => {
            e.preventDefault();
            const text = (e.clipboardData || window.clipboardData).getData('text').replace(/\D/g, '');
            if (text.length > 0) {
                const digits = text.split('');
                arr.forEach((b, i) => {
                    b.value = digits[i] || '';
                });
                const targetIdx = Math.min(digits.length, arr.length) - 1;
                if (targetIdx >= 0 && targetIdx < arr.length) {
                    arr[targetIdx].focus();
                }
            }
        });
    });
});

let pendingStaffParams = null;
let resendTimerInterval = null;

function startResendCooldown(seconds) {
    const btn = document.getElementById('btnResendOtpStaff');
    const timerWrap = document.getElementById('resendTimerDisplay');
    const timerSec = document.getElementById('timerSeconds');
    if (!btn || !timerWrap || !timerSec) return;

    btn.disabled = true;
    timerWrap.classList.remove('hidden');
    let left = seconds;
    timerSec.innerText = left;

    if (resendTimerInterval) clearInterval(resendTimerInterval);
    resendTimerInterval = setInterval(() => {
        left--;
        timerSec.innerText = left;
        if (left <= 0) {
            clearInterval(resendTimerInterval);
            timerWrap.classList.add('hidden');
            const countStr = document.getElementById('resendCountDisplay').innerText;
            if (parseInt(countStr) < 5) {
                btn.disabled = false;
            }
        }
    }, 1000);
}

async function resendStaffOtp() {
    const btn = document.getElementById('btnResendOtpStaff');
    const noticeBanner = document.getElementById('otpNoticeBanner');
    const noticeText = document.getElementById('otpNoticeMsgText');
    const errorBanner = document.getElementById('otpErrorBanner');

    noticeBanner.classList.add('hidden');
    errorBanner.classList.add('hidden');
    btn.disabled = true;

    try {
        const response = await fetch(_ctxPath + '/resend-otp', {
            method: 'POST',
            headers: {
                'X-Requested-With': 'XMLHttpRequest'
            }
        });
        const data = await response.json();
        if (data.success) {
            if (data.resendCount !== undefined) {
                document.getElementById('resendCountDisplay').innerText = data.resendCount;
            }
            noticeText.innerText = data.thongbao || 'Đã gửi lại mã OTP mới!';
            noticeBanner.classList.remove('hidden');
            startResendCooldown(60);
        } else {
            document.getElementById('otpErrorMsgText').innerText = data.loi || 'Không thể gửi lại mã OTP.';
            errorBanner.classList.remove('hidden');
            btn.disabled = false;
        }
    } catch(e) {
        console.error('Lỗi khi gửi lại OTP:', e);
        document.getElementById('otpErrorMsgText').innerText = 'Lỗi kết nối khi gửi lại OTP.';
        errorBanner.classList.remove('hidden');
        btn.disabled = false;
    }
}

function cancelOtpVerification() {
    document.getElementById('otpVerificationSection').classList.add('hidden');
    document.getElementById('staffFieldsContainer').classList.remove('hidden');
    // Clear boxes
    document.querySelectorAll('.otp-box').forEach(box => box.value = '');
    document.getElementById('otpErrorBanner').classList.add('hidden');
    document.getElementById('otpNoticeBanner').classList.add('hidden');
}

// Maps a server field name (as returned in "field: message" validation errors) to its input id.
const staffFieldMap = {
    fullName: 'staffName',
    email: 'staffEmail',
    phoneNumber: 'staffPhone',
    roleId: 'staffRole',
    password: 'staffPassword'
};

// Parses "field: message; field2: message2" errors from the server and highlights the
// matching inputs inline; falls back to a toast for anything it can't map to a field.
function handleStaffError(rawMsg) {
    if (!rawMsg) {
        showVsToast('Đã xảy ra lỗi khi lưu thông tin.', 'error');
        return;
    }
    clearFieldErrors();
    const parts = rawMsg.split(';').map(s => s.trim()).filter(Boolean);
    let matched = false;
    parts.forEach(part => {
        const idx = part.indexOf(':');
        if (idx > -1) {
            const key = part.substring(0, idx).trim();
            const msg = part.substring(idx + 1).trim();
            if (staffFieldMap[key]) {
                markFieldInvalid(staffFieldMap[key], msg);
                matched = true;
                return;
            }
        }
        showVsToast(part, 'error');
    });
    if (matched) {
        showVsToast('Vui lòng kiểm tra lại các trường được tô đỏ nhé.', 'error');
    }
}

async function handleStaffSubmit(e) {
    e.preventDefault();
    clearFieldErrors();
    const editId = document.getElementById('staffEditId').value;
    const params = new URLSearchParams();
    params.append('action', editId ? 'update' : 'add');
    if (editId) {
        params.append('accountId', editId);
    }
    params.append('fullName', document.getElementById('staffName').value);
    params.append('email', document.getElementById('staffEmail').value);
    params.append('phoneNumber', document.getElementById('staffPhone').value);
    params.append('roleId', document.getElementById('staffRole').value);
    params.append('password', document.getElementById('staffPassword').value);

    try {
        const response = await fetch(_ctxPath + '/manager/nhan-su', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
                'X-Requested-With': 'XMLHttpRequest'
            },
            body: params
        });

        if (response.redirected) {
            window.location.href = response.url;
            return;
        }

        if (!response.ok) {
            const text = await response.text();
            handleStaffError(text);
            return;
        }

        const data = await response.json();
        if (data.loi) {
            handleStaffError(data.loi);
            return;
        }
        if (data.requiresOtp) {
            // Show inline OTP block smoothly
            document.getElementById('otpTargetEmail').innerText = data.email;
            document.getElementById('staffFieldsContainer').classList.add('hidden');
            document.getElementById('otpVerificationSection').classList.remove('hidden');
            document.getElementById('resendCountDisplay').innerText = '0';
            document.querySelectorAll('.otp-box').forEach(b => b.value = '');
            document.querySelectorAll('.otp-box')[0].focus();
            pendingStaffParams = params;
        } else {
            // Success directly
            showVsToast(data.message || 'Cập nhật tài khoản thành công!', 'success');
            setTimeout(() => window.location.reload(), 900);
        }
    } catch (error) {
        console.error('Error submitting staff:', error);
        showVsToast('Lỗi kết nối máy chủ. Vui lòng thử lại.', 'error');
    }
}

async function submitOtpVerification() {
    const boxes = document.querySelectorAll('.otp-box');
    let otp = '';
    boxes.forEach(b => otp += b.value.trim());
    if (otp.length !== 6 || !/^\d+$/.test(otp)) {
        document.getElementById('otpErrorMsgText').innerText = 'Vui lòng nhập đầy đủ mã OTP 6 chữ số.';
        document.getElementById('otpErrorBanner').classList.remove('hidden');
        shakeOtpBoxes();
        return;
    }

    const btn = document.getElementById('otpConfirmBtn');
    const oldText = btn.innerHTML;
    btn.disabled = true;
    btn.innerHTML = 'Đang xác thực...';

    const params = new URLSearchParams();
    params.append('otp', otp);
    params.append('email', document.getElementById('otpTargetEmail').innerText);

    try {
        const response = await fetch(_ctxPath + '/nhapma', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
                'X-Requested-With': 'XMLHttpRequest'
            },
            body: params
        });
        const data = await response.json();
        if (data.success) {
            showVsToast(data.message || 'Thay đổi Email và thông tin thành công!', 'success');
            setTimeout(() => window.location.reload(), 900);
        } else {
            if (data.lockedOut) {
                showVsToast(data.loi, 'error');
                setTimeout(() => window.location.reload(), 1400);
                return;
            }
            document.getElementById('otpErrorMsgText').innerText = data.loi || 'Mã OTP không đúng. Vui lòng nhập lại.';
            document.getElementById('otpErrorBanner').classList.remove('hidden');
            shakeOtpBoxes();
            boxes.forEach(b => b.value = '');
            boxes[0].focus();
        }
    } catch(err) {
        console.error(err);
        document.getElementById('otpErrorMsgText').innerText = 'Lỗi kết nối máy chủ.';
        document.getElementById('otpErrorBanner').classList.remove('hidden');
        shakeOtpBoxes();
    } finally {
        btn.disabled = false;
        btn.innerHTML = oldText;
    }
}

function deleteStaff(id) {
    showCustomConfirm("Bạn có chắc chắn muốn xóa nhân viên này? Nhân viên sẽ được chuyển vào Thùng rác.", async () => {
        showToast("Đang thực hiện xóa... Bạn có thể vào Thùng rác để khôi phục.", "success");
        const params = new URLSearchParams();
        params.append('action', 'delete');
        params.append('id', id);

        try {
            const response = await fetch(_ctxPath + '/manager/nhan-su', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
                },
                body: params
            });
            setTimeout(() => {
                if (response.redirected) {
                    window.location.href = response.url;
                } else {
                    window.location.reload();
                }
            }, 1200);
        } catch (error) {
            console.error('Error deleting staff:', error);
        }
    });
}

// ==================== VIEW MANAGEMENT ====================

let currentView = 'staff';
let staffListFull = [];
let leaveRequests = [];
let currentManagerCoSoId = ${sessionScope.user.coSoId != null ? sessionScope.user.coSoId : 'null'};

function switchView(viewName) {
    currentView = viewName;

    document.querySelectorAll('.nav-link-tab').forEach(btn => {
        btn.classList.remove('active');
    });
    document.getElementById('nav-' + viewName).classList.add('active');

    document.getElementById('viewStaffSection').classList.add('hidden');
    document.getElementById('viewLeaveSection').classList.add('hidden');

    if (viewName === 'staff') {
        document.getElementById('viewStaffSection').classList.remove('hidden');
    } else if (viewName === 'leave') {
        document.getElementById('viewLeaveSection').classList.remove('hidden');
        if (leaveRequests.length === 0) {
            loadLeaveRequests();
        }
    }
}


// ==================== LEAVE VIEW (Yêu cầu nghỉ) ====================

async function loadLeaveRequests() {
    try {
        const response = await fetch('${pageContext.request.contextPath}/manager/yeu-cau-nghi?format=json');
        if (response.ok) {
            const data = await response.json();
            leaveRequests = data;
            renderLeaveTable();
        } else {
            console.error('Failed to load leave requests');
            let errorText = 'Lỗi máy chủ khi tải yêu cầu nghỉ';
            try {
                const errData = await response.json();
                if (errData && errData.error) errorText = errData.error;
            } catch (e) {}
            showNotification('error', errorText);
        }
    } catch (error) {
        console.error('Error loading leave requests:', error);
        showNotification('error', 'Lỗi tải dữ liệu yêu cầu nghỉ.');
    }
}

function renderLeaveTable(filteredList = null) {
    const list = filteredList || leaveRequests;
    const tbody = document.getElementById('leaveRequestBody');
    const emptyState = document.getElementById('leaveEmptyState');
    const totalCountEl = document.getElementById('leaveTotalCount');
    const pendingCountEl = document.getElementById('leavePendingCount');
    const approvedCountEl = document.getElementById('leaveApprovedCount');

    // Stats
    totalCountEl.innerText = list.length;
    const pendingCount = list.filter(r => r.trangThai === 'ChoDuyet').length;
    pendingCountEl.innerText = pendingCount;
    const approvedCount = list.filter(r => r.trangThai === 'DaDuyet').length;
    approvedCountEl.innerText = approvedCount;

    if (list.length === 0) {
        tbody.innerHTML = '';
        emptyState.classList.remove('hidden');
        return;
    }
    emptyState.classList.add('hidden');

    tbody.innerHTML = list.map(function(req, idx) {
        var statusClass = req.trangThai === 'ChoDuyet' ? 'badge-amber' :
                          req.trangThai === 'DaDuyet'  ? 'badge-green'  :
                          req.trangThai === 'TuChoi'   ? 'badge-red'    : 'badge-zinc';
        var statusLabel = req.trangThai === 'ChoDuyet' ? 'Chờ duyệt' :
                          req.trangThai === 'DaDuyet'  ? 'Đã duyệt'  :
                          req.trangThai === 'TuChoi'   ? 'Từ chối'   :
                          req.trangThai === 'DaHuy'    ? 'Đã hủy'    : req.trangThai;
        var dateFormatted   = formatDate(req.ngayNghi);
        var loaiNghiDisplay = req.loaiNghi === 'FullDay'           ? 'Cả ngày'    :
                              req.loaiNghi === 'HalfDay_Morning'   ? 'Buổi sáng'  :
                              req.loaiNghi === 'HalfDay_Afternoon' ? 'Buổi chiều' : req.loaiNghi;
        
        var typeClass = req.loaiNghi === 'FullDay' ? 'bg-indigo-50 text-indigo-700' : 'bg-sky-50 text-sky-700';

        var dateSent = '-';
        if (req.ngayGui) {
            var d = new Date(req.ngayGui);
            dateSent = d.getDate() + '/' + (d.getMonth()+1) + '/' + d.getFullYear()
                     + ' ' + d.getHours().toString().padStart(2,'0')
                     + ':' + d.getMinutes().toString().padStart(2,'0');
        }

        var nameParts = req.tenNhanVien ? req.tenNhanVien.trim().split(' ') : [];
        var initials = nameParts.length > 0 ? nameParts[nameParts.length - 1].substring(0, 2).toUpperCase() : 'NV';

        var actionHtml = '';
        if (req.trangThai === 'ChoDuyet') {
            actionHtml =
                '<button type="button" onclick="approveLeave(' + req.yeuCauNghiID + ')"'
                + ' class="px-3 py-1.5 rounded-lg bg-green-50 border border-green-200 text-green-700 hover:bg-green-100 text-[11px] font-bold transition-all shadow-sm cursor-pointer mr-2">Phê duyệt</button>'
                + '<button type="button" onclick="rejectLeave(' + req.yeuCauNghiID + ')"'
                + ' class="px-3 py-1.5 rounded-lg bg-red-50 border border-red-200 text-red-650 hover:bg-red-100 text-[11px] font-bold transition-all shadow-sm cursor-pointer">Từ chối</button>';
        }

        return '<tr class="hover:bg-violet-50/10 transition-colors reveal-on-scroll">'
            + '<td class="p-4 text-center text-zinc-500 font-medium">' + (idx + 1) + '</td>'
            + '<td class="p-4">'
            +   '<div class="flex items-center gap-3">'
            +     '<div class="w-9 h-9 rounded-full bg-violet-100 text-violet-700 font-bold flex items-center justify-center text-xs shrink-0">' + initials + '</div>'
            +     '<div>'
            +       '<div class="text-sm font-semibold text-zinc-800">' + req.tenNhanVien + '</div>'
            +       '<div class="text-xs text-zinc-400 font-mono mt-0.5">' + req.username + '</div>'
            +     '</div>'
            +   '</div>'
            + '</td>'
            + '<td class="p-4 text-zinc-600 font-medium">' + req.roleName + '</td>'
            + '<td class="p-4 font-semibold text-zinc-700">' + dateFormatted + '</td>'
            + '<td class="p-4"><span class="px-2 py-0.5 rounded text-[11px] font-semibold ' + typeClass + '">' + loaiNghiDisplay + '</span></td>'
            + '<td class="p-4 text-zinc-600 max-w-[200px] truncate" title="' + req.lyDo + '">' + req.lyDo + '</td>'
            + '<td class="p-4"><span class="badge ' + statusClass + '">' + statusLabel + '</span></td>'
            + '<td class="p-4 text-zinc-400 font-mono">' + dateSent + '</td>'
            + '<td class="p-4 text-right pr-6">' + actionHtml + '</td>'
            + '</tr>';
    }).join('');

    if (typeof observer !== 'undefined') {
        document.querySelectorAll("#leaveRequestBody .reveal-on-scroll").forEach(el => {
            observer.observe(el);
        });
    } else {
        document.querySelectorAll("#leaveRequestBody .reveal-on-scroll").forEach(el => {
            el.classList.add("revealed");
        });
    }
}

function filterLeaveRequests(status, btn) {
    document.querySelectorAll('.leave-filter-btn').forEach(b => {
        b.className = 'leave-filter-btn px-4 py-2 text-xs font-bold rounded-lg text-zinc-600 hover:text-zinc-900 transition-all cursor-pointer';
    });
    if (btn) {
        btn.className = 'leave-filter-btn px-4 py-2 text-xs font-bold rounded-lg bg-white text-zinc-800 shadow-sm transition-all cursor-pointer';
    } else {
        const first = document.querySelector('.leave-filter-btn');
        if (first) first.className = 'leave-filter-btn px-4 py-2 text-xs font-bold rounded-lg bg-white text-zinc-800 shadow-sm transition-all cursor-pointer';
    }
    
    if (status === 'all') {
        renderLeaveTable(leaveRequests);
    } else {
        const filtered = leaveRequests.filter(r => r.trangThai === status);
        renderLeaveTable(filtered);
    }
}


async function approveLeave(id) {
    if (!confirm('Phê duyệt yêu cầu nghỉ này?')) return;
    
    const params = new URLSearchParams();
    params.append('action', 'approve');
    params.append('id', id);
    params.append('format', 'json');

    try {
        const response = await fetch(_ctxPath + '/manager/yeu-cau-nghi', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
            },
            body: params
        });

        if (response.ok) {
            const res = await response.json();
            if (res.success) {
                showNotification('success', res.message || 'Đã phê duyệt yêu cầu nghỉ');
                await loadLeaveRequests();
            } else {
                showNotification('error', res.error || 'Lỗi phê duyệt yêu cầu nghỉ.');
            }
        } else {
            showNotification('error', 'Lỗi máy chủ khi phê duyệt.');
        }
    } catch (error) {
        console.error('Error approving leave request:', error);
        showNotification('error', 'Lỗi kết nối mạng.');
    }
}

async function rejectLeave(id) {
    const ghiChu = prompt('Nhập lý do từ chối (tùy chọn):');
    if (ghiChu === null) return; // Cancelled
    
    const params = new URLSearchParams();
    params.append('action', 'reject');
    params.append('id', id);
    params.append('ghiChu', ghiChu);
    params.append('format', 'json');

    try {
        const response = await fetch(_ctxPath + '/manager/yeu-cau-nghi', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
            },
            body: params
        });

        if (response.ok) {
            const res = await response.json();
            if (res.success) {
                showNotification('success', res.message || 'Đã từ chối yêu cầu nghỉ');
                await loadLeaveRequests();
            } else {
                showNotification('error', res.error || 'Lỗi từ chối yêu cầu nghỉ.');
            }
        } else {
            showNotification('error', 'Lỗi máy chủ khi từ chối.');
        }
    } catch (error) {
        console.error('Error rejecting leave request:', error);
        showNotification('error', 'Lỗi kết nối mạng.');
    }
}

// Global observer for scroll animations
let observer;

document.addEventListener('DOMContentLoaded', () => {
    // Initialize observer
    observer = new IntersectionObserver((entries) => {
        entries.forEach((entry, index) => {
            if (entry.isIntersecting) {
                setTimeout(() => {
                    entry.target.classList.add("revealed");
                }, index * 40);
                observer.unobserve(entry.target);
            }
        });
    }, {
        threshold: 0.05,
        rootMargin: "0px 0px -10px 0px"
    });

    loadStaffList();
    
    // Automatically switch to correct tab if tab parameter is specified
    const urlParams = new URLSearchParams(window.location.search);
    const tab = urlParams.get('tab');
    if (tab && ['staff', 'leave'].includes(tab)) {
        switchView(tab);
    }
});

// Reload page when navigated back/forward via bfcache
window.addEventListener('pageshow', function(event) {
    if (event.persisted) {
        window.location.reload();
    }
});
</script>

</body>
</html>
