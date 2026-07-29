<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Quản lý nhân sự (Admin) — V-SPORT</title>
<script src="https://cdn.tailwindcss.com"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200">
<style>
body { font-family: 'Inter', sans-serif; }
  .card { background:#fff;border:1px solid #e4e4e7;border-radius:16px; transition:box-shadow .2s, transform .2s; }
  .badge { display:inline-flex;align-items:center;padding:4px 10px;border-radius:8px;font-size:11px;font-weight:600; }
  .badge-green { background:#dcfce7;color:#15803d; }
  .badge-red { background:#fee2e2;color:#b91c1c; }
  .badge-amber { background:#fef3c7;color:#b45309; }
  .live-dot { animation: pulse-dot 1.6s ease-in-out infinite; }
  @keyframes pulse-dot { 0%,100%{box-shadow:0 0 0 0 rgba(34,197,94,.4);} 50%{box-shadow:0 0 0 6px rgba(34,197,94,0);} }

  @keyframes contentZoomIn {
    from {
      opacity: 0;
      transform: scale(0.97);
    }
    to {
      opacity: 1;
      transform: scale(1);
    }
  }
  main {
    animation: contentZoomIn 0.35s cubic-bezier(0.34, 1.56, 0.64, 1) forwards;
    transform-origin: center top;
  }
</style>
</head>
<body class="bg-zinc-50 text-zinc-900 min-h-screen">

<!-- Sidebar -->
<jsp:include page="/admin/common/sidebar.jsp" />

<!-- Header -->
<jsp:include page="/admin/common/header.jsp">
  <jsp:param name="pageTitle" value="Quản lý nhân sự cấp cao"/>
</jsp:include>

<main class="lg:ml-[260px] mt-[64px] p-4 lg:p-6 flex flex-col gap-5">
  <div class="flex items-center justify-between gap-4 mb-2 flex-wrap">
    <h2 class="text-lg font-bold text-zinc-800">
      Danh sách nhân sự
      <span class="text-xs bg-blue-100 text-blue-700 px-1.5 py-0.5 rounded font-semibold ml-1" id="staffCountDisplay">0</span>
    </h2>
    <div class="flex items-center gap-2">
      <div class="relative">
        <span class="absolute left-3 top-1/2 -translate-y-1/2 material-symbols-outlined text-[16px] text-zinc-400">search</span>
        <input type="search" id="adminSearchInput" autocomplete="off" placeholder="Tìm theo tên, email, sđt..."
               class="h-9 w-64 pl-9 pr-3 rounded-xl border border-zinc-200 bg-white text-xs focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-400 transition-all">
      </div>
      <button id="addStaffBtn" onclick="openAddStaff()"
              class="flex items-center gap-1.5 h-9 px-4 rounded-xl bg-blue-600 text-white text-sm font-semibold hover:bg-blue-700 transition-all shadow-md shadow-blue-100">
        <span class="material-symbols-outlined text-[18px]">person_add</span>Thêm nhân sự
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
    <div class="p-4 bg-green-50 border border-green-100 rounded-xl text-green-600 text-sm flex items-start gap-3 animate-fade-in-up">
      <span class="material-symbols-outlined text-[20px] shrink-0">check_circle</span>
      <div>
        <span class="font-bold block text-green-700">Thành công</span>
        <span class="text-green-600/95 leading-normal block mt-0.5">${sessionScope.message}</span>
      </div>
      <% session.removeAttribute("message"); %>
    </div>
  </c:if>

  <!-- Grid nhân sự đang làm việc -->
  <div id="sectionNhanSu" class="w-full flex flex-col gap-4">
    <div id="staffGrid" class="flex flex-col divide-y divide-zinc-100 bg-white border border-zinc-200 rounded-2xl overflow-hidden shadow-sm"></div>
  </div>


</main>

<!-- Modal xác nhận chuyển vào thùng rác -->
<div id="softDeleteModal" class="hidden fixed inset-0 z-[90] flex items-center justify-center p-4">
  <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" onclick="closeSoftDeleteModal()"></div>
  <div class="relative bg-white rounded-2xl shadow-2xl w-full max-w-[400px] p-6">
    <div class="flex flex-col items-center text-center gap-3">
      <div class="w-12 h-12 rounded-full bg-blue-50 flex items-center justify-center">
        <span class="material-symbols-outlined text-[24px] text-blue-600">delete</span>
      </div>
      <h3 class="text-base font-bold text-zinc-900">Chuyển vào Thùng rác?</h3>
      <p class="text-sm text-zinc-500">Tài khoản <span id="softDeleteName" class="font-semibold text-zinc-800"></span> sẽ bị vô hiệu hóa và chuyển vào Thùng rác. Bạn có thể khôi phục sau.</p>
    </div>
    <input type="hidden" id="softDeleteId" value="">
    <div class="flex gap-3 mt-6">
      <button onclick="closeSoftDeleteModal()" class="flex-1 h-10 rounded-xl border border-zinc-200 text-sm font-medium text-zinc-700 hover:bg-zinc-50">Hủy</button>
      <button onclick="confirmSoftDelete()" class="flex-1 h-10 rounded-xl bg-blue-600 text-white text-sm font-semibold hover:bg-blue-700">Chuyển vào thùng rác</button>
    </div>
  </div>
</div>

<!-- Modals -->
<div id="staffModal" class="hidden fixed inset-0 z-[80] flex items-center justify-center p-4">
  <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" onclick="closeStaffModal()"></div>
  <div class="relative bg-white rounded-2xl shadow-2xl w-full max-w-[760px] overflow-hidden flex flex-col md:flex-row min-h-[460px] animate-fade-in-up">
    
    <!-- Left Panel: Live Member Preview (Gorgeous & Interactive) -->
    <div class="hidden md:flex md:w-[260px] bg-gradient-to-br from-blue-600 via-blue-700 to-indigo-900 text-white p-6 flex-col justify-between relative overflow-hidden shrink-0">
      <!-- Background glow effects -->
      <div class="absolute -top-12 -right-12 w-32 h-32 bg-white/10 rounded-full blur-2xl"></div>
      <div class="absolute -bottom-12 -left-12 w-32 h-32 bg-blue-500/20 rounded-full blur-2xl"></div>
      
      <div class="relative z-10 flex flex-col gap-1.5">
        <div class="inline-flex items-center justify-center w-8 h-8 rounded-lg bg-white/10 backdrop-blur-md mb-1">
          <span class="material-symbols-outlined text-[18px] text-white">person_add</span>
        </div>
        <h3 class="text-base font-bold tracking-tight text-white/95">Hồ sơ Nhân sự</h3>
        <p class="text-[11px] text-white/75 leading-relaxed">Xem trước thời gian thực thông tin tài khoản được cập nhật trên hệ thống V-SPORT.</p>
      </div>
      
      <!-- Preview Card -->
      <div class="relative z-10 my-4 p-4 bg-white/10 backdrop-blur-md border border-white/15 rounded-xl shadow-lg flex flex-col gap-3">
        <div class="flex items-center gap-2.5">
          <div id="previewAvatar" class="w-10 h-10 rounded-full bg-white text-blue-700 font-extrabold flex items-center justify-center text-xs shadow-sm transition-all uppercase">VS</div>
          <div class="overflow-hidden">
            <p id="previewName" class="font-extrabold text-white text-xs leading-tight truncate">Họ và Tên</p>
            <p id="previewRole" class="text-[9px] text-blue-200 font-semibold tracking-wide uppercase mt-0.5">Vai trò</p>
          </div>
        </div>
        
        <div class="h-px bg-white/10"></div>
        
        <div class="flex flex-col gap-1.5 text-[10px] text-white/80 font-medium">
          <div class="flex items-center gap-2 truncate">
            <span class="material-symbols-outlined text-[13px] text-white/60 shrink-0">mail</span>
            <span id="previewEmail" class="truncate">email@v-sport.com</span>
          </div>
          <div class="flex items-center gap-2">
            <span class="material-symbols-outlined text-[13px] text-white/60 shrink-0">phone_iphone</span>
            <span id="previewPhone">09xxxxxxx</span>
          </div>
        </div>
      </div>
      
      <div class="relative z-10 text-[9px] text-white/40 font-bold uppercase tracking-wider">
        V-SPORT Suite
      </div>
    </div>
    
    <!-- Right Panel: Form Fields -->
    <div class="flex-1 flex flex-col justify-between">
      <div class="flex items-center justify-between px-6 py-4 border-b border-zinc-100">
        <h2 id="staffModalTitle" class="text-base font-bold text-zinc-800">Thêm nhân sự</h2>
        <button onclick="closeStaffModal()" class="p-1.5 rounded-lg hover:bg-zinc-100"><span class="material-symbols-outlined text-[18px] text-zinc-500">close</span></button>
      </div>
      
      <form id="staffForm" onsubmit="handleStaffSubmit(event)" class="px-6 py-4 flex flex-col gap-3.5">
        <input type="hidden" id="staffEditId" value="">
        
        <!-- Container for staff fields -->
        <div id="staffFieldsContainer" class="flex flex-col gap-3.5">
          <div class="flex flex-col gap-1.5">
            <label class="text-xs font-semibold text-zinc-600">Họ và tên <span class="text-red-500">*</span></label>
            <input type="text" id="staffName" required class="h-9 px-3 rounded-lg border border-zinc-200 text-sm focus:ring-2 focus:ring-blue-400 focus:border-blue-500 focus:outline-none transition-all">
          </div>
          
          <div class="grid grid-cols-2 gap-3">
            <div class="flex flex-col gap-1.5">
              <label class="text-xs font-semibold text-zinc-600">Vai trò <span class="text-red-500">*</span></label>
              <select id="staffRole" required class="h-9 px-3 rounded-lg border border-zinc-200 text-sm focus:ring-2 focus:ring-blue-400 focus:border-blue-500 focus:outline-none transition-all bg-white">
                <option value="2">Quản lý</option>
                <option value="3">Khách hàng</option>
                <option value="4">Lễ tân</option>
                <option value="5">Bảo vệ</option>
              </select>
            </div>
            <div id="staffCoSoContainer" class="flex flex-col gap-1.5 hidden">
              <label class="text-xs font-semibold text-zinc-600">Cơ sở <span class="text-red-500">*</span></label>
              <select id="staffCoSo" name="coSoId" class="h-9 px-3 rounded-lg border border-zinc-200 text-sm focus:ring-2 focus:ring-blue-400 focus:border-blue-500 focus:outline-none transition-all bg-white">
                <c:forEach var="branch" items="${branches}">
                  <option value="${branch.coSoID}">${branch.tenCoSo}</option>
                </c:forEach>
              </select>
            </div>
          </div>
          
          <div class="flex flex-col gap-1.5">
            <label class="text-xs font-semibold text-zinc-600">Email <span class="text-red-500">*</span></label>
            <input type="email" id="staffEmail" required class="h-9 px-3 rounded-lg border border-zinc-200 text-sm focus:ring-2 focus:ring-blue-400 focus:border-blue-500 focus:outline-none transition-all">
          </div>
          
          <div class="grid grid-cols-2 gap-3">
            <div class="flex flex-col gap-1.5">
              <label class="text-xs font-semibold text-zinc-600">Điện thoại</label>
              <input type="tel" id="staffPhone" class="h-9 px-3 rounded-lg border border-zinc-200 text-sm focus:ring-2 focus:ring-blue-400 focus:border-blue-500 focus:outline-none transition-all">
            </div>
            
            <div class="flex flex-col gap-1.5">
              <label id="pwdLabel" class="text-xs font-semibold text-zinc-600">Mật khẩu <span class="text-red-500">*</span></label>
              <div class="relative flex items-center">
                <input type="password" id="staffPassword" placeholder="••••••••" autocomplete="new-password" class="h-9 px-3 rounded-lg border border-zinc-200 text-sm focus:ring-2 focus:ring-blue-400 focus:border-blue-500 focus:outline-none w-full transition-all">
              </div>
              <!-- Strength Indicator -->
              <div id="passwordStrengthContainer" class="hidden flex flex-col gap-1 mt-1">
                <div class="flex h-1 w-full bg-zinc-100 rounded-full overflow-hidden">
                  <div id="strengthBar" class="h-full w-0 transition-all duration-300 rounded-full"></div>
                </div>
                <span id="strengthText" class="text-[9px] font-bold text-zinc-400 uppercase tracking-wider">Yếu</span>
              </div>
            </div>
          </div>
          
          <div class="flex justify-end gap-2 mt-4 pt-4 border-t border-zinc-100">
            <button type="button" onclick="closeStaffModal()" class="h-9 px-4 rounded-lg border border-zinc-200 text-sm font-semibold hover:bg-zinc-50 text-zinc-650 transition-colors">Hủy</button>
            <button type="submit" class="h-9 px-5 rounded-lg bg-blue-600 text-white text-sm font-bold hover:bg-blue-700 shadow-md shadow-blue-100 transition-colors">Lưu thông tin</button>
          </div>
        </div>

        <!-- Container for OTP Verification (Hidden by default) -->
        <div id="otpVerificationSection" class="hidden flex flex-col gap-4 text-center py-4">
            <div class="inline-flex mx-auto items-center justify-center w-12 h-12 rounded-full bg-blue-50 text-blue-600 mb-2">
                <span class="material-symbols-outlined text-[24px]">mark_email_read</span>
            </div>
            <div>
                <h3 class="text-sm font-bold text-zinc-900">Xác thực OTP kích hoạt / đổi Email</h3>
                <p class="text-xs text-zinc-500 mt-1">Một mã xác thực gồm 6 chữ số đã được gửi tới <span class="font-bold text-blue-600" id="otpTargetEmail"></span>.</p>
            </div>
            
            <div class="flex gap-2 justify-center my-3" id="otpBoxesContainer">
                <input type="tel" inputmode="numeric" pattern="[0-9]*" maxlength="1" autocomplete="one-time-code" class="otp-box w-10 h-12 border border-zinc-250 rounded-xl text-center font-bold text-lg text-zinc-900 focus:border-blue-500 focus:ring-4 focus:ring-blue-100 outline-none transition-all">
                <input type="tel" inputmode="numeric" pattern="[0-9]*" maxlength="1" autocomplete="one-time-code" class="otp-box w-10 h-12 border border-zinc-250 rounded-xl text-center font-bold text-lg text-zinc-900 focus:border-blue-500 focus:ring-4 focus:ring-blue-100 outline-none transition-all">
                <input type="tel" inputmode="numeric" pattern="[0-9]*" maxlength="1" autocomplete="one-time-code" class="otp-box w-10 h-12 border border-zinc-250 rounded-xl text-center font-bold text-lg text-zinc-900 focus:border-blue-500 focus:ring-4 focus:ring-blue-100 outline-none transition-all">
                <input type="tel" inputmode="numeric" pattern="[0-9]*" maxlength="1" autocomplete="one-time-code" class="otp-box w-10 h-12 border border-zinc-250 rounded-xl text-center font-bold text-lg text-zinc-900 focus:border-blue-500 focus:ring-4 focus:ring-blue-100 outline-none transition-all">
                <input type="tel" inputmode="numeric" pattern="[0-9]*" maxlength="1" autocomplete="one-time-code" class="otp-box w-10 h-12 border border-zinc-250 rounded-xl text-center font-bold text-lg text-zinc-900 focus:border-blue-500 focus:ring-4 focus:ring-blue-100 outline-none transition-all">
                <input type="tel" inputmode="numeric" pattern="[0-9]*" maxlength="1" autocomplete="one-time-code" class="otp-box w-10 h-12 border border-zinc-250 rounded-xl text-center font-bold text-lg text-zinc-900 focus:border-blue-500 focus:ring-4 focus:ring-blue-100 outline-none transition-all">
            </div>
            
            <div class="text-xs text-blue-600 font-medium">
                Chưa nhận được mã? 
                <button type="button" id="btnResendOtpAdmin" onclick="resendAdminStaffOtp()" class="font-bold text-blue-600 hover:underline disabled:opacity-40 disabled:no-underline cursor-pointer">
                    Gửi lại mã (<span id="resendCountDisplayAdmin">0</span>/5)
                </button>
                <span id="resendTimerDisplayAdmin" class="text-blue-500 font-normal ml-1 hidden">(chờ <span id="timerSecondsAdmin">60</span>s)</span>
            </div>

            <div id="otpNoticeBanner" class="hidden p-2.5 bg-emerald-50 border border-emerald-200 text-emerald-700 text-xs font-semibold rounded-lg flex items-center justify-center gap-1.5 mt-2">
                <span class="material-symbols-outlined text-[16px]">check_circle</span>
                <span id="otpNoticeMsgText"></span>
            </div>

            <div id="otpErrorBanner" class="hidden p-2.5 bg-red-50 border border-red-100 text-red-650 text-xs font-semibold rounded-lg flex items-center justify-center gap-1.5 mt-2">
                <span class="material-symbols-outlined text-[16px]">error</span>
                <span id="otpErrorMsgText">Mã OTP không hợp lệ.</span>
            </div>

            <div class="flex gap-2 justify-end mt-4 pt-4 border-t border-zinc-150">
                <button type="button" onclick="cancelOtpVerification()" class="h-9 px-4 rounded-lg border border-zinc-200 text-sm font-semibold hover:bg-zinc-50 text-zinc-650">Quay lại</button>
                <button type="button" id="otpConfirmBtn" onclick="submitOtpVerification()" class="h-9 px-5 rounded-lg bg-blue-600 text-white text-sm font-semibold hover:bg-blue-700 shadow shadow-blue-100 flex items-center gap-1.5">
                    Xác nhận
                    <span class="material-symbols-outlined text-[16px]">check</span>
                </button>
            </div>
        </div>
      </form>
    </div>
    
  </div>
</div>

<script>
let staffList = [
  <c:forEach items="${accounts}" var="acc" varStatus="loop">
    {
      id: '${acc.accountId}',
      username: '${acc.username}',
      name: '<c:out value="${acc.fullName != null && !acc.fullName.trim().isEmpty() ? acc.fullName : acc.username}" />',
      VaiTro: '<c:choose><c:when test="${acc.roleId == 1}">Quản trị viên</c:when><c:when test="${acc.roleId == 2}">Quản lý</c:when><c:when test="${acc.roleId == 3}">Khách hàng</c:when><c:when test="${acc.roleId == 4}">Lễ tân</c:when><c:when test="${acc.roleId == 5}">Bảo vệ</c:when><c:otherwise>Nhân viên</c:otherwise></c:choose>',
      roleId: ${acc.roleId},
      phone: '${acc.phoneNumber != null ? acc.phoneNumber : "Chưa có"}',
      status: '${acc.isLocked ? "Bị khóa" : "Đang làm"}',
      email: '${acc.email}',
      coSoId: '${acc.coSoId != null ? acc.coSoId : ""}',
      coSoStatus: '<c:forEach items="${branches}" var="b"><c:if test="${b.coSoID eq acc.coSoId}">${b.trangThai}</c:if></c:forEach>',
      initial: '${(acc.fullName != null && acc.fullName.length() > 0) ? acc.fullName.substring(0, 1).toUpperCase() : acc.username.substring(0, 1).toUpperCase()}',
      avatarUrl: '<c:choose><c:when test="${not empty acc.avatarUrl}">${pageContext.request.contextPath}<c:out value="${acc.avatarUrl}" /></c:when><c:otherwise></c:otherwise></c:choose>'
    }${!loop.last ? ',' : ''}
  </c:forEach>
];

let deletedList = [
  <c:forEach items="${deletedAccounts}" var="acc" varStatus="loop">
    {
      id: '${acc.accountId}',
      username: '${acc.username}',
      name: '<c:out value="${acc.fullName != null && !acc.fullName.trim().isEmpty() ? acc.fullName : acc.username}" />',
      VaiTro: '<c:choose><c:when test="${acc.roleId == 1}">Quản trị viên</c:when><c:when test="${acc.roleId == 2}">Quản lý</c:when><c:when test="${acc.roleId == 3}">Khách hàng</c:when><c:when test="${acc.roleId == 4}">Lễ tân</c:when><c:when test="${acc.roleId == 5}">Bảo vệ</c:when><c:otherwise>Nhân viên</c:otherwise></c:choose>',
      email: '${acc.email}',
      initial: '${(acc.fullName != null && acc.fullName.length() > 0) ? acc.fullName.substring(0, 1).toUpperCase() : acc.username.substring(0, 1).toUpperCase()}'
    }${!loop.last ? ',' : ''}
  </c:forEach>
];

let staffCurrentPage = 1;
let trashCurrentPage = 1;
const nhanSuPageSize = 8;

function renderPaginationControls(parentSectionId, controlId, totalItems, currentPage, totalPages, onPageChange) {
  const section = document.getElementById(parentSectionId);
  if (!section) return;

  // Remove existing pagination if any
  const existing = section.querySelector('#' + controlId);
  if (existing) {
    existing.remove();
  }

  if (totalItems === 0 || totalPages <= 1) return;

  const pagDiv = document.createElement('div');
  pagDiv.id = controlId;
  pagDiv.className = 'px-4 py-3 border-t border-zinc-200 flex items-center justify-between text-xs text-zinc-500 bg-zinc-50/50';

  const start = (currentPage - 1) * nhanSuPageSize + 1;
  const end = Math.min(currentPage * nhanSuPageSize, totalItems);

  pagDiv.innerHTML = `
    <span>Hiển thị \${start}-\${end} trong \${totalItems} tài khoản</span>
    <div class="flex items-center gap-1" id="\${controlId}_btns"></div>
  `;

  section.appendChild(pagDiv);

  const btnContainer = document.getElementById(controlId + '_btns');
  if (!btnContainer) return;

  // Left arrow
  const prevBtn = document.createElement('button');
  prevBtn.type = 'button';
  prevBtn.className = 'px-2 py-1 rounded hover:bg-blue-50 hover:text-blue-600 text-slate-400 disabled:opacity-40 flex items-center justify-center transition-colors';
  prevBtn.disabled = currentPage === 1;
  prevBtn.innerHTML = '<span class="material-symbols-outlined text-[14px]">chevron_left</span>';
  prevBtn.onclick = () => onPageChange(currentPage - 1);
  btnContainer.appendChild(prevBtn);

  // Page buttons
  for (let i = 1; i <= totalPages; i++) {
    const btn = document.createElement('button');
    btn.type = 'button';
    btn.innerText = i;
    if (i === currentPage) {
      btn.className = 'px-2.5 py-1 rounded bg-blue-600 text-white font-semibold shadow-sm transition-all';
    } else {
      btn.className = 'px-2.5 py-1 rounded hover:bg-blue-50 hover:text-blue-600 text-slate-600 transition-colors';
    }
    btn.onclick = () => onPageChange(i);
    btnContainer.appendChild(btn);
  }

  // Right arrow
  const nextBtn = document.createElement('button');
  nextBtn.type = 'button';
  nextBtn.className = 'px-2 py-1 rounded hover:bg-blue-50 hover:text-blue-600 text-slate-400 disabled:opacity-40 flex items-center justify-center transition-colors';
  nextBtn.disabled = currentPage === totalPages;
  nextBtn.innerHTML = '<span class="material-symbols-outlined text-[14px]">chevron_right</span>';
  nextBtn.onclick = () => onPageChange(currentPage + 1);
  btnContainer.appendChild(nextBtn);
}

function renderStaff() {
  const staffGrid = document.getElementById('staffGrid');
  if (!staffGrid) return;

  const searchValue = document.getElementById('adminSearchInput') ? document.getElementById('adminSearchInput').value.toLowerCase().trim() : '';
  const filtered = staffList.filter(s => {
    return s.name.toLowerCase().includes(searchValue) || 
           s.username.toLowerCase().includes(searchValue) || 
           (s.email && s.email.toLowerCase().includes(searchValue)) || 
           (s.phone && s.phone.toLowerCase().includes(searchValue)) ||
           s.VaiTro.toLowerCase().includes(searchValue);
  });

  document.getElementById('staffCountDisplay').innerText = filtered.length;

  const totalPages = Math.ceil(filtered.length / nhanSuPageSize);
  if (staffCurrentPage > totalPages && totalPages > 0) staffCurrentPage = totalPages;
  if (staffCurrentPage < 1) staffCurrentPage = 1;

  const pageList = filtered.slice((staffCurrentPage - 1) * nhanSuPageSize, staffCurrentPage * nhanSuPageSize);

  if (pageList.length === 0) {
    staffGrid.innerHTML = `
      <div class="py-14 text-center text-zinc-400">
        <span class="material-symbols-outlined text-4xl mb-2 text-zinc-300">group_off</span>
        <p class="text-xs font-medium mt-1">Không tìm thấy thành viên nào</p>
      </div>
    `;
    const existing = document.getElementById('sectionNhanSu').querySelector('#staffPagination');
    if (existing) existing.remove();
    return;
  }

  staffGrid.innerHTML = pageList.map(s => {
    let badgeClass = s.status === 'Đang làm' ? 'badge-green' : 'badge-red';
    let statusText = s.status;
    let deleteBtn = '';

    if (s.roleId === 2 && s.coSoStatus === 'Chờ duyệt') {
      badgeClass = 'badge-amber';
      statusText = 'Chờ duyệt';
    } else if (s.roleId === 2 && s.coSoStatus === 'Từ chối') {
      badgeClass = 'badge-red';
      statusText = 'Từ chối';
    }

    if (s.roleId !== 1) {
      deleteBtn = `<button onclick="promptSoftDelete('\${s.id}', '\${s.name}')" title="Xóa" class="w-7 h-7 flex items-center justify-center rounded-lg text-red-400 hover:bg-red-50 hover:text-red-600 transition-colors">
        <span class="material-symbols-outlined text-[16px]">person_remove</span>
      </button>`;
    }

    let dept = 'Khác';
    if (s.roleId === 1) dept = 'Admin';
    else if (s.roleId === 2) dept = 'Quản lý';
    else if (s.roleId === 3) dept = 'Khách hàng';
    else if (s.roleId === 4) dept = 'Lễ tân';
    else if (s.roleId === 5) dept = 'Bảo vệ';

    let branchText = s.coSoId ? `CS\${s.coSoId}` : 'Trụ sở';
    let avatarUrl = s.avatarUrl
      ? s.avatarUrl
      : `https://ui-avatars.com/api/?name=\${encodeURIComponent(s.name)}&background=3b82f6&color=fff&size=64&bold=true`;

    return `
      <div class="flex items-center gap-3 px-4 py-2.5 hover:bg-zinc-50 transition-colors">
        <img src="\${avatarUrl}" alt="\${s.name}" class="w-9 h-9 rounded-full border border-zinc-100 shrink-0 object-cover">
        <div class="min-w-0 w-[190px] shrink-0">
          <p class="font-bold text-zinc-900 text-sm leading-tight truncate">\${s.name}</p>
          <p class="text-[11px] text-blue-500 font-semibold truncate">\${s.VaiTro} · \${dept} · \${branchText}</p>
        </div>
        <div class="min-w-0 flex-1 hidden sm:flex items-center gap-5 text-xs text-zinc-500">
          <span class="flex items-center gap-1 truncate" title="\${s.email}">
            <span class="material-symbols-outlined text-[13px] shrink-0 text-zinc-400">mail</span>
            <span class="truncate">\${s.email || '—'}</span>
          </span>
          <span class="flex items-center gap-1 shrink-0">
            <span class="material-symbols-outlined text-[13px] shrink-0 text-zinc-400">phone_iphone</span>
            \${s.phone || '—'}
          </span>
        </div>
        <span class="badge \${badgeClass} shrink-0">\${statusText}</span>
        <div class="flex items-center gap-0.5 shrink-0">
          <button onclick="editStaff('\${s.id}')" title="Sửa" class="w-7 h-7 flex items-center justify-center rounded-lg text-blue-400 hover:bg-blue-50 hover:text-blue-600 transition-colors">
            <span class="material-symbols-outlined text-[16px]">edit</span>
          </button>
          \${deleteBtn}
        </div>
      </div>
    `;
  }).join('');

  renderPaginationControls('sectionNhanSu', 'staffPagination', filtered.length, staffCurrentPage, totalPages, (p) => {
    staffCurrentPage = p;
    renderStaff();
  });
}

// ---- Soft delete (chuyển vào thùng rác) ----
function promptSoftDelete(id, name) {
  document.getElementById('softDeleteId').value = id;
  document.getElementById('softDeleteName').innerText = name;
  document.getElementById('softDeleteModal').classList.remove('hidden');
}
function closeSoftDeleteModal() {
  document.getElementById('softDeleteModal').classList.add('hidden');
}
function confirmSoftDelete() {
  const id = document.getElementById('softDeleteId').value;
  const form = document.createElement('form');
  form.method = 'POST';
  form.action = '${pageContext.request.contextPath}/admin/nhan-su';
  const add = (n, v) => { const i = document.createElement('input'); i.type = 'hidden'; i.name = n; i.value = v; form.appendChild(i); };
  add('action', 'softDelete'); add('id', id);
  document.body.appendChild(form); form.submit();
}

// ---- Khôi phục từ thùng rác ----
function restoreStaff(id) {
  const form = document.createElement('form');
  form.method = 'POST';
  form.action = '${pageContext.request.contextPath}/admin/nhan-su';
  const add = (n, v) => { const i = document.createElement('input'); i.type = 'hidden'; i.name = n; i.value = v; form.appendChild(i); };
  add('action', 'restore'); add('id', id);
  document.body.appendChild(form); form.submit();
}

// ---- Chuyển tab ----
// Chỉ còn tab "Nhân sự" (thùng rác riêng đã bị loại bỏ, dùng /admin/thung-rac chung).
function switchTab(tab) {
  const nhansuSection = document.getElementById('sectionNhanSu');
  const tabNhanSu = document.getElementById('tabNhanSu');
  const addBtn = document.getElementById('addStaffBtn');

  nhansuSection.classList.remove('hidden');
  tabNhanSu.className = 'flex items-center gap-1.5 px-4 py-1.5 rounded-lg text-sm font-semibold bg-blue-600 text-white shadow transition-all';
  tabNhanSu.querySelector('#staffCountDisplay').className = 'text-xs bg-blue-500 text-white px-1.5 py-0.5 rounded font-medium';
  addBtn.classList.remove('hidden');
}


function updateRoleDropdown(isEdit, currentRoleId) {
  const staffRoleSelect = document.getElementById('staffRole');
  const coSoContainer = document.getElementById('staffCoSoContainer');
  const coSoSelect = document.getElementById('staffCoSo');
  if (!staffRoleSelect) return;
  
  staffRoleSelect.innerHTML = '';
  
  if (isEdit && currentRoleId === 1) {
    const opt = document.createElement('option');
    opt.value = 1;
    opt.textContent = 'Quản trị viên';
    staffRoleSelect.appendChild(opt);
    staffRoleSelect.value = 1;
    staffRoleSelect.disabled = true;
  } else {
    const allowedRoles = [
      { id: 2, name: 'Quản lý' },
      { id: 3, name: 'Khách hàng' },
      { id: 4, name: 'Lễ tân' },
      { id: 5, name: 'Bảo vệ' }
    ];
    
    allowedRoles.forEach(role => {
      const opt = document.createElement('option');
      opt.value = role.id;
      opt.textContent = role.name;
      staffRoleSelect.appendChild(opt);
    });
    
    staffRoleSelect.disabled = false;
    if (isEdit && currentRoleId) {
      staffRoleSelect.value = currentRoleId;
    }
  }
  
  // Show/hide branch selector based on selected role
  const toggleBranch = () => {
    if (staffRoleSelect.value == '2') {
      coSoContainer.classList.remove('hidden');
    } else {
      coSoContainer.classList.add('hidden');
      if (coSoSelect) coSoSelect.value = '';
    }
  };
  
  staffRoleSelect.onchange = toggleBranch;
  // Initial call
  toggleBranch();
}

function updateModalLivePreview() {
  const name = document.getElementById('staffName').value.trim() || 'Họ và Tên';
  const email = document.getElementById('staffEmail').value.trim() || 'email@v-sport.com';
  const phone = document.getElementById('staffPhone').value.trim() || '09xxxxxxx';
  
  const roleSelect = document.getElementById('staffRole');
  let roleText = 'Vai trò';
  if (roleSelect && roleSelect.selectedIndex >= 0) {
    roleText = roleSelect.options[roleSelect.selectedIndex].text;
  }
  
  const nameEl = document.getElementById('previewName');
  const emailEl = document.getElementById('previewEmail');
  const phoneEl = document.getElementById('previewPhone');
  const roleEl = document.getElementById('previewRole');
  const avatarEl = document.getElementById('previewAvatar');
  
  if (nameEl) nameEl.innerText = name;
  if (emailEl) emailEl.innerText = email;
  if (phoneEl) phoneEl.innerText = phone;
  if (roleEl) roleEl.innerText = roleText;
  
  let initials = 'VS';
  const nameParts = name.trim().split(/\s+/);
  if (nameParts.length > 0 && nameParts[0] !== 'Họ' && nameParts[0] !== 'và' && nameParts[0] !== 'Tên') {
    initials = nameParts[nameParts.length - 1].substring(0, 2).toUpperCase();
  }
  if (avatarEl) avatarEl.innerText = initials;
}

function openAddStaff() {
  document.getElementById('staffForm').reset();
  document.getElementById('staffModalTitle').innerText = 'Thêm nhân sự mới';
  document.getElementById('staffEditId').value = '';
  // Reset OTP containers
  document.getElementById('staffFieldsContainer').classList.remove('hidden');
  document.getElementById('otpVerificationSection').classList.add('hidden');
  document.querySelectorAll('.otp-box').forEach(b => b.value = '');
  document.getElementById('otpErrorBanner').classList.add('hidden');
  
  // Set password to required and set label
  document.getElementById('pwdLabel').innerHTML = 'Mật khẩu <span class="text-red-500">*</span>';
  const staffPassword = document.getElementById('staffPassword');
  staffPassword.required = true;
  staffPassword.type = 'password';
  staffPassword.disabled = false;
  staffPassword.placeholder = "••••••••";
  document.getElementById('passwordStrengthContainer').classList.add('hidden');
  
  // Reset fields to enabled state
  document.getElementById('staffRole').disabled = false;
  document.getElementById('staffPhone').disabled = false;
  const coSoSelect = document.getElementById('staffCoSo');
  if (coSoSelect) coSoSelect.disabled = false;
  
  updateRoleDropdown(false, null);
  updateModalLivePreview();
  document.getElementById('staffModal').classList.remove('hidden');
}

function editStaff(id) {
  const s = staffList.find(x => x.id == id);
  if (!s) return;
  document.getElementById('staffModalTitle').innerText = 'Chỉnh sửa tài khoản';
  document.getElementById('staffEditId').value = s.id;
  document.getElementById('staffName').value = s.name;
  document.getElementById('staffEmail').value = s.email;
  document.getElementById('staffPhone').value = s.phone;
  document.getElementById('staffPhone').disabled = true; // Khóa số điện thoại khi chỉnh sửa
  
  // Reset OTP containers
  document.getElementById('staffFieldsContainer').classList.remove('hidden');
  document.getElementById('otpVerificationSection').classList.add('hidden');
  document.querySelectorAll('.otp-box').forEach(b => b.value = '');
  document.getElementById('otpErrorBanner').classList.add('hidden');
  
  // Set password to optional and set label
  const pwdLabel = document.getElementById('pwdLabel');
  const staffPassword = document.getElementById('staffPassword');
  pwdLabel.innerHTML = 'Mật khẩu (Được giữ bảo mật)';
  staffPassword.required = false;
  staffPassword.disabled = true; // Khóa mật khẩu khi chỉnh sửa
  staffPassword.placeholder = "Được giữ bảo mật (không thể thay đổi)";
  staffPassword.type = 'password';
  document.getElementById('passwordStrengthContainer').classList.add('hidden');
  
  updateRoleDropdown(true, s.roleId);

  const coSoSelect = document.getElementById('staffCoSo');
  if (coSoSelect && s.coSoId) {
    coSoSelect.value = s.coSoId;
  }

  // Handle locks for all edit staff actions
  const staffRoleSelect = document.getElementById('staffRole');
  staffRoleSelect.disabled = true; // Khóa vai trò khi chỉnh sửa
  if (coSoSelect) coSoSelect.disabled = true; // Khóa chi nhánh khi chỉnh sửa

  updateModalLivePreview();
  document.getElementById('staffModal').classList.remove('hidden');
}

function closeStaffModal() { document.getElementById('staffModal').classList.add('hidden'); }

// Setup input events for 6 OTP boxes
document.addEventListener('DOMContentLoaded', () => {
    const boxes = document.querySelectorAll('.otp-box');
    boxes.forEach((box, idx, arr) => {
        box.addEventListener('input', (e) => {
            const v = e.target.value.replace(/\D/g, '');
            e.target.value = v ? v[0] : '';
            if (v && idx < arr.length - 1) {
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
let resendTimerIntervalAdmin = null;

function startResendCooldownAdmin(seconds) {
    const btn = document.getElementById('btnResendOtpAdmin');
    const timerWrap = document.getElementById('resendTimerDisplayAdmin');
    const timerSec = document.getElementById('timerSecondsAdmin');
    if (!btn || !timerWrap || !timerSec) return;

    btn.disabled = true;
    timerWrap.classList.remove('hidden');
    let left = seconds;
    timerSec.innerText = left;

    if (resendTimerIntervalAdmin) clearInterval(resendTimerIntervalAdmin);
    resendTimerIntervalAdmin = setInterval(() => {
        left--;
        timerSec.innerText = left;
        if (left <= 0) {
            clearInterval(resendTimerIntervalAdmin);
            timerWrap.classList.add('hidden');
            const countStr = document.getElementById('resendCountDisplayAdmin').innerText;
            if (parseInt(countStr) < 5) {
                btn.disabled = false;
            }
        }
    }, 1000);
}

async function resendAdminStaffOtp() {
    const btn = document.getElementById('btnResendOtpAdmin');
    const noticeBanner = document.getElementById('otpNoticeBanner');
    const noticeText = document.getElementById('otpNoticeMsgText');
    const errorBanner = document.getElementById('otpErrorBanner');

    noticeBanner.classList.add('hidden');
    errorBanner.classList.add('hidden');
    btn.disabled = true;

    try {
        const response = await fetch('${pageContext.request.contextPath}/resend-otp', {
            method: 'POST',
            headers: {
                'X-Requested-With': 'XMLHttpRequest'
            }
        });
        const data = await response.json();
        if (data.success) {
            if (data.resendCount !== undefined) {
                document.getElementById('resendCountDisplayAdmin').innerText = data.resendCount;
            }
            noticeText.innerText = data.thongbao || 'Đã gửi lại mã OTP mới!';
            noticeBanner.classList.remove('hidden');
            startResendCooldownAdmin(60);
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

async function handleStaffSubmit(e) {
  e.preventDefault();
  const editId = document.getElementById('staffEditId').value;
  
  const params = new URLSearchParams();
  params.append('action', editId ? 'update' : 'add');
  if (editId) params.append('accountId', editId);
  
  params.append('fullName', document.getElementById('staffName').value);
  params.append('email', document.getElementById('staffEmail').value);
  params.append('phoneNumber', document.getElementById('staffPhone').value);
  params.append('roleId', document.getElementById('staffRole').value);
  if (document.getElementById('staffRole').value == '2') {
    params.append('coSoId', document.getElementById('staffCoSo').value);
  }
  params.append('password', document.getElementById('staffPassword').value);

  try {
      const response = await fetch('${pageContext.request.contextPath}/admin/nhan-su', {
          method: 'POST',
          headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
              'X-Requested-With': 'XMLHttpRequest'
          },
          body: params
      });
      if (!response.ok) {
          const text = await response.text();
          alert(text || 'Đã xảy ra lỗi khi cập nhật thông tin.');
          return;
      }
      const data = await response.json();
      if (data.requiresOtp) {
          // Show inline OTP block smoothly
          document.getElementById('otpTargetEmail').innerText = data.email;
          document.getElementById('staffFieldsContainer').classList.add('hidden');
          document.getElementById('otpVerificationSection').classList.remove('hidden');
          document.getElementById('resendCountDisplayAdmin').innerText = '0';
          document.querySelectorAll('.otp-box').forEach(b => b.value = '');
          document.querySelectorAll('.otp-box')[0].focus();
          pendingStaffParams = params;
      } else if (data.success === false || data.error) {
          alert(data.error || 'Đã xảy ra lỗi. Vui lòng thử lại.');
      } else {
          // Success directly (update action)
          alert(data.message || 'Cập nhật tài khoản thành công!');
          window.location.reload();
      }
  } catch (err) {
      console.error(err);
      alert('Lỗi kết nối máy chủ.');
  }
}

async function submitOtpVerification() {
    const boxes = document.querySelectorAll('.otp-box');
    let otp = '';
    boxes.forEach(b => otp += b.value.trim());
    if (otp.length !== 6 || !/^\d+$/.test(otp)) {
        document.getElementById('otpErrorMsgText').innerText = 'Vui lòng nhập đầy đủ mã OTP 6 chữ số.';
        document.getElementById('otpErrorBanner').classList.remove('hidden');
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
        const response = await fetch('${pageContext.request.contextPath}/nhapma', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'X-Requested-With': 'XMLHttpRequest'
            },
            body: params
        });
        const data = await response.json();
        if (data.success) {
            alert(data.message || 'Thay đổi Email và thông tin thành công!');
            window.location.reload();
        } else {
            if (data.lockedOut) {
                alert(data.loi);
                window.location.reload();
                return;
            }
            if (data.redirect) {
                alert(data.loi || 'Thao tác không thành công.');
                window.location.href = '${pageContext.request.contextPath}' + data.redirect;
                return;
            }
            document.getElementById('otpErrorMsgText').innerText = data.loi || 'Mã OTP không đúng. Vui lòng nhập lại.';
            document.getElementById('otpErrorBanner').classList.remove('hidden');
            boxes.forEach(b => b.value = '');
            boxes[0].focus();
        }
    } catch(err) {
        console.error(err);
        document.getElementById('otpErrorMsgText').innerText = 'Lỗi kết nối máy chủ.';
        document.getElementById('otpErrorBanner').classList.remove('hidden');
    } finally {
        btn.disabled = false;
        btn.innerHTML = oldText;
    }
}

// Scripts run at end of <body>, DOM is already ready — call directly
(function initNhanSu() {
    renderStaff();

    const searchInput = document.getElementById('adminSearchInput');
    if (searchInput) {
        searchInput.addEventListener('input', () => {
            staffCurrentPage = 1;
            renderStaff();
        });
    }


    // Password strength check listener
    const pwdInput = document.getElementById('staffPassword');
    if (pwdInput) {
        pwdInput.addEventListener('input', (e) => {
            const val = e.target.value;
            const container = document.getElementById('passwordStrengthContainer');
            const bar = document.getElementById('strengthBar');
            const txt = document.getElementById('strengthText');
            
            if (!val) {
                container.classList.add('hidden');
                return;
            }
            
            container.classList.remove('hidden');
            
            let score = 0;
            if (val.length >= 6) score++;
            if (val.length >= 10) score++;
            if (/[A-Z]/.test(val)) score++;
            if (/[0-9]/.test(val)) score++;
            if (/[^A-Za-z0-9]/.test(val)) score++;
            
            if (score <= 2) {
                bar.style.width = '33%';
                bar.className = 'h-full bg-red-500 rounded-full transition-all duration-300';
                txt.textContent = 'Yếu';
                txt.className = 'text-[9px] font-bold text-red-500 uppercase tracking-wider block mt-1';
            } else if (score <= 4) {
                bar.style.width = '66%';
                bar.className = 'h-full bg-amber-500 rounded-full transition-all duration-300';
                txt.textContent = 'Trung bình';
                txt.className = 'text-[9px] font-bold text-amber-500 uppercase tracking-wider block mt-1';
            } else {
                bar.style.width = '100%';
                bar.className = 'h-full bg-emerald-500 rounded-full transition-all duration-300';
                txt.textContent = 'Mạnh';
                txt.className = 'text-[9px] font-bold text-emerald-500 uppercase tracking-wider block mt-1';
            }
        });
    }

    // Live preview event listeners
    const fieldsToListen = ['staffName', 'staffEmail', 'staffPhone', 'staffRole'];
    fieldsToListen.forEach(id => {
      const el = document.getElementById(id);
      if (el) {
        el.addEventListener('input', updateModalLivePreview);
        el.addEventListener('change', updateModalLivePreview);
      }
    });
})();

// Bfcache restore (browser back/forward): re-render data
window.addEventListener('pageshow', function(e) {
    if (e.persisted) {
        renderStaff();
    }
});
</script>

</body>
</html>
