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
<header class="h-[64px] fixed top-0 right-0 left-0 lg:left-[260px] bg-white/80 backdrop-blur-lg border-b border-zinc-200 z-20 flex items-center justify-between px-4 lg:px-6">
  <div class="flex items-center gap-3">
    <button id="mobileMenuBtn" class="lg:hidden p-2 rounded-lg hover:bg-zinc-100 text-zinc-500"><span class="material-symbols-outlined text-[20px]">menu</span></button>
    <div>
      <h1 class="text-sm font-bold text-zinc-900 tracking-tight">Quản lý nhân sự cấp cao</h1>
      <p class="text-xs text-zinc-500 flex items-center gap-1.5"><span class="material-symbols-outlined text-[12px]">security</span>Quyền hạn Admin</p>
    </div>
  </div>
  
  <div class="flex items-center gap-1.5">
    <button onclick="location.href='${pageContext.request.contextPath}/admin/HoTro.jsp'" class="hidden sm:flex items-center gap-1.5 h-9 px-3 rounded-lg border border-zinc-200 hover:bg-zinc-50 text-zinc-600 text-xs font-medium">
      <span class="material-symbols-outlined text-[15px]">help</span>Hỗ trợ
    </button>
    <button class="relative p-2 rounded-lg hover:bg-zinc-100 text-zinc-500">
      <span class="material-symbols-outlined text-[20px]">notifications</span>
      <span class="absolute top-1.5 right-1.5 w-2 h-2 rounded-full bg-red-500 live-dot"></span>
    </button>
    <div class="w-px h-6 bg-zinc-200 mx-1"></div>
    <jsp:include page="/admin/common/profile_dropdown.jsp" />
  </div>
</header>

<main class="lg:ml-[260px] mt-[64px] p-4 lg:p-6 flex flex-col gap-5">
  <div class="flex items-center justify-between gap-4 mb-2 flex-wrap">
    <div class="flex gap-1 bg-zinc-100 p-1 rounded-xl">
      <button id="tabNhanSu" onclick="switchTab('nhansu')" class="flex items-center gap-1.5 px-4 py-1.5 rounded-lg text-sm font-semibold bg-blue-600 text-white shadow transition-all">
        <span class="material-symbols-outlined text-[16px]">people</span>Nhân sự
        <span class="text-xs bg-blue-500 text-white px-1.5 py-0.5 rounded font-medium" id="staffCountDisplay">0</span>
      </button>
      <button id="tabThungRac" onclick="switchTab('thungrac')" class="flex items-center gap-1.5 px-4 py-1.5 rounded-lg text-sm font-medium text-zinc-500 hover:text-zinc-700 transition-all">
        <span class="material-symbols-outlined text-[16px]">delete</span>Thùng rác
        <span id="trashCountBadge" class="hidden text-xs bg-red-100 text-red-600 px-1.5 py-0.5 rounded font-bold">0</span>
      </button>
    </div>
    <button id="addStaffBtn" onclick="openAddStaff()" class="flex items-center justify-center gap-1.5 h-10 px-5 rounded-xl bg-blue-600 text-white text-sm font-semibold hover:bg-blue-700 transition-all">
      <span class="material-symbols-outlined text-[18px]">person_add</span>Thêm nhân sự
    </button>
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

  <!-- Bảng nhân sự đang làm việc -->
  <div id="sectionNhanSu" class="card overflow-hidden">
    <table class="w-full text-sm">
      <thead class="bg-zinc-50 border-b border-zinc-200">
        <tr>
          <th class="px-4 py-3 text-left font-semibold text-zinc-600 text-xs">Thành viên</th>
          <th class="px-4 py-3 text-left font-semibold text-zinc-600 text-xs">Vai trò</th>
          <th class="px-4 py-3 text-left font-semibold text-zinc-600 text-xs">Điện thoại</th>
          <th class="px-4 py-3 text-left font-semibold text-zinc-600 text-xs">Trạng thái</th>
          <th class="px-4 py-3 text-right font-semibold text-zinc-600 text-xs">Thao tác</th>
        </tr>
      </thead>
      <tbody class="divide-y divide-zinc-100" id="staffBody"></tbody>
    </table>
  </div>

  <!-- Bảng thùng rác (ẩn mặc định) -->
  <div id="sectionThungRac" class="hidden">
    <div class="p-3 bg-red-50 border border-red-100 rounded-xl text-red-600 text-xs font-medium flex items-center gap-2 mb-3">
      <span class="material-symbols-outlined text-[16px]">info</span>
      Các tài khoản trong thùng rác đã bị vô hiệu hóa. Bạn có thể khôi phục hoặc xóa vĩnh viễn.
    </div>
    <div class="card overflow-hidden">
      <table class="w-full text-sm">
        <thead class="bg-red-50 border-b border-red-100">
          <tr>
            <th class="px-4 py-3 text-left font-semibold text-zinc-600 text-xs">Thành viên</th>
            <th class="px-4 py-3 text-left font-semibold text-zinc-600 text-xs">Vai trò</th>
            <th class="px-4 py-3 text-left font-semibold text-zinc-600 text-xs">Email</th>
            <th class="px-4 py-3 text-right font-semibold text-zinc-600 text-xs">Thao tác</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-zinc-100" id="trashBody"></tbody>
      </table>
    </div>
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

<!-- Modal xác nhận xóa vĩnh viễn -->
<div id="permanentDeleteModal" class="hidden fixed inset-0 z-[90] flex items-center justify-center p-4">
  <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" onclick="closePermanentDeleteModal()"></div>
  <div class="relative bg-white rounded-2xl shadow-2xl w-full max-w-[400px] p-6">
    <div class="flex flex-col items-center text-center gap-3">
      <div class="w-12 h-12 rounded-full bg-red-50 flex items-center justify-center">
        <span class="material-symbols-outlined text-[24px] text-red-600">delete_forever</span>
      </div>
      <h3 class="text-base font-bold text-zinc-900">Xóa vĩnh viễn?</h3>
      <p class="text-sm text-zinc-500">Tài khoản <span id="permanentDeleteName" class="font-semibold text-zinc-800"></span> sẽ bị <strong class="text-red-600">xóa vĩnh viễn</strong> khỏi hệ thống. Hành động này <strong class="text-red-600">KHÔNG THỂ hoàn tác</strong>.</p>
    </div>
    <input type="hidden" id="permanentDeleteId" value="">
    <div class="flex gap-3 mt-6">
      <button onclick="closePermanentDeleteModal()" class="flex-1 h-10 rounded-xl border border-zinc-200 text-sm font-medium text-zinc-700 hover:bg-zinc-50">Hủy</button>
      <button onclick="confirmPermanentDelete()" class="flex-1 h-10 rounded-xl bg-red-600 text-white text-sm font-semibold hover:bg-red-700">Xóa vĩnh viễn</button>
    </div>
  </div>
</div>

<!-- Modals -->
<div id="staffModal" class="hidden fixed inset-0 z-[80] flex items-center justify-center p-4">
  <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" onclick="closeStaffModal()"></div>
  <div class="relative bg-white rounded-2xl shadow-2xl w-full max-w-[480px]">
    <div class="flex items-center justify-between px-6 py-4 border-b border-zinc-100">
      <h2 id="staffModalTitle" class="text-base font-semibold text-zinc-900">Thêm nhân sự</h2>
      <button onclick="closeStaffModal()" class="p-1.5 rounded-lg hover:bg-zinc-100"><span class="material-symbols-outlined text-[18px] text-zinc-500">close</span></button>
    </div>
    <form id="staffForm" onsubmit="handleStaffSubmit(event)" class="px-6 py-4 flex flex-col gap-4">
      <input type="hidden" id="staffEditId" value="">
      
      <!-- Container for staff fields -->
      <div id="staffFieldsContainer" class="flex flex-col gap-4">
          <div class="grid grid-cols-2 gap-3">
            <div class="flex flex-col gap-1.5"><label class="text-xs font-medium text-zinc-700">Họ và tên <span class="text-red-500">*</span></label><input type="text" id="staffName" required class="h-9 px-3 rounded-lg border border-zinc-200 text-sm focus:ring-2 focus:ring-zinc-400 focus:outline-none"></div>
            <div class="flex flex-col gap-1.5"><label class="text-xs font-medium text-zinc-700">Tên đăng nhập <span class="text-red-500">*</span></label><input type="text" id="staffUsername" required class="h-9 px-3 rounded-lg border border-zinc-200 text-sm focus:ring-2 focus:ring-zinc-400 focus:outline-none"></div>
          </div>
          <div class="flex flex-col gap-1.5">
            <label class="text-xs font-medium text-zinc-700">Vai trò <span class="text-red-500">*</span></label>
            <select id="staffRole" required class="h-9 px-3 rounded-lg border border-zinc-200 text-sm focus:ring-2 focus:ring-zinc-400 focus:outline-none">
              <option value="2">Quản lý</option>
              <option value="3">Khách hàng</option>
              <option value="4">Lễ tân</option>
              <option value="5">Bảo vệ</option>
            </select>
          </div>
          <div id="staffCoSoContainer" class="flex flex-col gap-1.5 hidden">
            <label class="text-xs font-medium text-zinc-700">Cơ sở <span class="text-red-500">*</span></label>
            <select id="staffCoSo" name="coSoId" class="h-9 px-3 rounded-lg border border-zinc-200 text-sm focus:ring-2 focus:ring-zinc-400 focus:outline-none">
              <c:forEach var="branch" items="${branches}">
                <option value="${branch.coSoID}">${branch.tenCoSo}</option>
              </c:forEach>
            </select>
          </div>
          <div class="flex flex-col gap-1.5"><label class="text-xs font-medium text-zinc-700">Email <span class="text-red-500">*</span></label><input type="email" id="staffEmail" required class="h-9 px-3 rounded-lg border border-zinc-200 text-sm focus:ring-2 focus:ring-zinc-400 focus:outline-none"></div>
          <div class="grid grid-cols-2 gap-3">
            <div class="flex flex-col gap-1.5"><label class="text-xs font-medium text-zinc-700">Điện thoại</label><input type="tel" id="staffPhone" class="h-9 px-3 rounded-lg border border-zinc-200 text-sm focus:ring-2 focus:ring-zinc-400 focus:outline-none"></div>
            
            <div class="flex flex-col gap-1.5">
              <label id="pwdLabel" class="text-xs font-medium text-zinc-700">Mật khẩu <span class="text-red-500">*</span></label>
              <div class="relative flex items-center">
                <input type="password" id="staffPassword" placeholder="••••••••" class="h-9 px-3 rounded-lg border border-zinc-200 text-sm focus:ring-2 focus:ring-zinc-400 focus:outline-none w-full">
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
          <div class="flex justify-end gap-2 mt-2">
            <button type="button" onclick="closeStaffModal()" class="h-9 px-4 rounded-lg border border-zinc-200 text-sm">Hủy</button>
            <button type="submit" class="h-9 px-4 rounded-lg bg-zinc-900 text-white text-sm">Lưu thông tin</button>
          </div>
      </div>

      <!-- Container for OTP Verification (Hidden by default) -->
      <div id="otpVerificationSection" class="hidden flex flex-col gap-4 text-center py-4">
          <div class="inline-flex mx-auto items-center justify-center w-12 h-12 rounded-full bg-emerald-50 text-emerald-600 mb-2">
              <span class="material-symbols-outlined text-[24px]">mark_email_read</span>
          </div>
          <div>
              <h3 class="text-sm font-bold text-zinc-900">Xác thực OTP thay đổi Email</h3>
              <p class="text-xs text-zinc-500 mt-1">Một mã xác thực gồm 6 chữ số đã được gửi tới <span class="font-bold text-zinc-850" id="otpTargetEmail"></span>.</p>
          </div>
          
          <div class="flex gap-2 justify-center my-3" id="otpBoxesContainer">
              <input type="text" maxlength="1" class="otp-box w-10 h-12 border border-zinc-250 rounded-xl text-center font-bold text-lg focus:border-zinc-500 focus:ring-4 focus:ring-zinc-100 outline-none transition-all">
              <input type="text" maxlength="1" class="otp-box w-10 h-12 border border-zinc-250 rounded-xl text-center font-bold text-lg focus:border-zinc-500 focus:ring-4 focus:ring-zinc-100 outline-none transition-all">
              <input type="text" maxlength="1" class="otp-box w-10 h-12 border border-zinc-250 rounded-xl text-center font-bold text-lg focus:border-zinc-500 focus:ring-4 focus:ring-zinc-100 outline-none transition-all">
              <input type="text" maxlength="1" class="otp-box w-10 h-12 border border-zinc-250 rounded-xl text-center font-bold text-lg focus:border-zinc-500 focus:ring-4 focus:ring-zinc-100 outline-none transition-all">
              <input type="text" maxlength="1" class="otp-box w-10 h-12 border border-zinc-250 rounded-xl text-center font-bold text-lg focus:border-zinc-500 focus:ring-4 focus:ring-zinc-100 outline-none transition-all">
              <input type="text" maxlength="1" class="otp-box w-10 h-12 border border-zinc-250 rounded-xl text-center font-bold text-lg focus:border-zinc-500 focus:ring-4 focus:ring-zinc-100 outline-none transition-all">
          </div>
          
          <div id="otpErrorBanner" class="hidden p-2.5 bg-red-50 border border-red-100 text-red-650 text-xs font-semibold rounded-lg flex items-center justify-center gap-1.5">
              <span class="material-symbols-outlined text-[16px]">error</span>
              <span id="otpErrorMsgText">Mã OTP không hợp lệ.</span>
          </div>

          <div class="flex gap-2 justify-end mt-4 pt-4 border-t border-zinc-150">
              <button type="button" onclick="cancelOtpVerification()" class="h-9 px-4 rounded-lg border border-zinc-200 text-sm font-semibold hover:bg-zinc-50 text-zinc-650">Quay lại</button>
              <button type="button" id="otpConfirmBtn" onclick="submitOtpVerification()" class="h-9 px-5 rounded-lg bg-emerald-600 text-white text-sm font-semibold hover:bg-emerald-700 shadow shadow-emerald-100 flex items-center gap-1.5">
                  Xác nhận
                  <span class="material-symbols-outlined text-[16px]">check</span>
              </button>
          </div>
      </div>
    </form>
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
      initial: '${(acc.fullName != null && acc.fullName.length() > 0) ? acc.fullName.substring(0, 1).toUpperCase() : acc.username.substring(0, 1).toUpperCase()}'
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

function renderStaff() {
  const staffBody = document.getElementById('staffBody');
  if (!staffBody) return;
  document.getElementById('staffCountDisplay').innerText = staffList.length;
  staffBody.innerHTML = staffList.map(s => {
    let badgeClass = s.status === 'Đang làm' ? 'badge-green' : 'badge-red';
    let statusText = s.status;
    let actionsHtml = '';

    if (s.roleId === 2 && s.coSoStatus === 'Chờ duyệt') {
      badgeClass = 'badge-amber';
      statusText = 'Chờ duyệt';
    } else if (s.roleId === 2 && s.coSoStatus === 'Từ chối') {
      badgeClass = 'badge-red';
      statusText = 'Từ chối';
    }

    if (s.roleId === 1) {
      actionsHtml = '';
    } else if (s.roleId === 2) {
      // Manager/Owner – chỉ xem, việc duyệt/khóa ở trang Quản lý Owner
      actionsHtml = `
        <button onclick="promptSoftDelete('\${s.id}', '\${s.name}')" title="Chuyển vào thùng rác" class="p-1.5 rounded-lg hover:bg-red-50 text-red-500"><span class="material-symbols-outlined text-[18px]">person_remove</span></button>
      `;
    } else {
      actionsHtml = `
        <button onclick="toggleLock('\${s.id}', \${s.status === 'Đang làm'})" title="\${s.status === 'Đang làm' ? 'Khóa' : 'Mở khóa'}" class="p-1.5 rounded-lg hover:bg-zinc-100 \${s.status === 'Đang làm' ? 'text-amber-600' : 'text-green-600'}"><span class="material-symbols-outlined text-[18px]">\${s.status === 'Đang làm' ? 'lock' : 'lock_open'}</span></button>
        <button onclick="promptSoftDelete('\${s.id}', '\${s.name}')" title="Chuyển vào thùng rác" class="p-1.5 rounded-lg hover:bg-red-50 text-red-500"><span class="material-symbols-outlined text-[18px]">person_remove</span></button>
      `;
    }

    return `
      <tr class="hover:bg-zinc-50 transition-colors">
        <td class="px-4 py-4"><div class="flex items-center gap-3"><div class="w-8 h-8 rounded-full bg-blue-100 text-blue-700 flex items-center justify-center shrink-0 font-bold text-xs">\${s.initial}</div><div><p class="font-bold text-zinc-900">\${s.name}</p><p class="text-[10px] text-zinc-400">\${s.username}</p></div></div></td>
        <td class="px-4 py-4 text-xs font-medium text-zinc-600">\${s.VaiTro}</td>
        <td class="px-4 py-4 text-xs text-zinc-500">\${s.phone}</td>
        <td class="px-4 py-4"><span class="badge \${badgeClass}">\${statusText}</span></td>
        <td class="px-4 py-4 text-right flex items-center justify-end gap-1.5">
          <button onclick="editStaff('\${s.id}')" title="Sửa" class="p-1.5 rounded-lg hover:bg-zinc-100 text-zinc-500"><span class="material-symbols-outlined text-[18px]">edit</span></button>
          \${actionsHtml}
        </td>
      </tr>
    `;
  }).join('');
}

function toggleLock(id, currentlyActive) {
  if (confirm(currentlyActive ? "Khóa tài khoản này?" : "Mở khóa tài khoản?")) {
    const form = document.createElement('form'); form.method = 'POST'; form.action = '${pageContext.request.contextPath}/admin/nhan-su';
    const add = (n, v) => { const i = document.createElement('input'); i.type = 'hidden'; i.name = n; i.value = v; form.appendChild(i); };
    add('action', 'update'); add('accountId', id); add('isLocked', currentlyActive ? 'true' : 'false');
    document.body.appendChild(form); form.submit();
  }
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

// ---- Xóa vĩnh viễn ----
function promptPermanentDelete(id, name) {
  document.getElementById('permanentDeleteId').value = id;
  document.getElementById('permanentDeleteName').innerText = name;
  document.getElementById('permanentDeleteModal').classList.remove('hidden');
}
function closePermanentDeleteModal() {
  document.getElementById('permanentDeleteModal').classList.add('hidden');
}
function confirmPermanentDelete() {
  const id = document.getElementById('permanentDeleteId').value;
  const form = document.createElement('form');
  form.method = 'POST';
  form.action = '${pageContext.request.contextPath}/admin/nhan-su';
  const add = (n, v) => { const i = document.createElement('input'); i.type = 'hidden'; i.name = n; i.value = v; form.appendChild(i); };
  add('action', 'permanentDelete'); add('id', id);
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

// ---- Render thùng rác ----
function renderTrash() {
  const trashBody = document.getElementById('trashBody');
  if (!trashBody) return;
  if (deletedList.length === 0) {
    trashBody.innerHTML = '<tr><td colspan="4" class="px-4 py-8 text-center text-sm text-zinc-400">Thùng rác trống</td></tr>';
    return;
  }
  trashBody.innerHTML = deletedList.map(s => `
    <tr class="hover:bg-zinc-50 transition-colors">
      <td class="px-4 py-4"><div class="flex items-center gap-3"><div class="w-8 h-8 rounded-full bg-zinc-200 text-zinc-500 flex items-center justify-center shrink-0 font-bold text-xs">\${s.initial}</div><div><p class="font-bold text-zinc-500">\${s.name}</p><p class="text-[10px] text-zinc-400">\${s.username}</p></div></div></td>
      <td class="px-4 py-4 text-xs font-medium text-zinc-400">\${s.VaiTro}</td>
      <td class="px-4 py-4 text-xs text-zinc-400">\${s.email}</td>
      <td class="px-4 py-4 text-right flex items-center justify-end gap-1.5">
        <button onclick="restoreStaff('\${s.id}')" title="Khôi phục" class="flex items-center gap-1 px-3 h-8 rounded-lg bg-green-50 text-green-600 text-xs font-semibold hover:bg-green-100"><span class="material-symbols-outlined text-[16px]">restore</span>Khôi phục</button>
        <button onclick="promptPermanentDelete('\${s.id}', '\${s.name}')" title="Xóa vĩnh viễn" class="flex items-center gap-1 px-3 h-8 rounded-lg bg-red-50 text-red-600 text-xs font-semibold hover:bg-red-100"><span class="material-symbols-outlined text-[16px]">delete_forever</span>Xóa vĩnh viễn</button>
      </td>
    </tr>
  `).join('');
}

// ---- Chuyển tab ----
function switchTab(tab) {
  const nhansuSection = document.getElementById('sectionNhanSu');
  const trashSection = document.getElementById('sectionThungRac');
  const tabNhanSu = document.getElementById('tabNhanSu');
  const tabThungRac = document.getElementById('tabThungRac');
  const addBtn = document.getElementById('addStaffBtn');

  if (tab === 'nhansu') {
    nhansuSection.classList.remove('hidden');
    trashSection.classList.add('hidden');
    tabNhanSu.className = 'flex items-center gap-1.5 px-4 py-1.5 rounded-lg text-sm font-semibold bg-blue-600 text-white shadow transition-all';
    tabNhanSu.querySelector('#staffCountDisplay').className = 'text-xs bg-blue-500 text-white px-1.5 py-0.5 rounded font-medium';
    tabThungRac.className = 'flex items-center gap-1.5 px-4 py-1.5 rounded-lg text-sm font-medium text-zinc-500 hover:text-zinc-700 transition-all';
    addBtn.classList.remove('hidden');
  } else {
    nhansuSection.classList.add('hidden');
    trashSection.classList.remove('hidden');
    tabThungRac.className = 'flex items-center gap-1.5 px-4 py-1.5 rounded-lg text-sm font-semibold bg-blue-600 text-white shadow transition-all';
    tabNhanSu.className = 'flex items-center gap-1.5 px-4 py-1.5 rounded-lg text-sm font-medium text-zinc-500 hover:text-zinc-700 transition-all';
    tabNhanSu.querySelector('#staffCountDisplay').className = 'text-xs bg-zinc-100 text-zinc-600 px-1.5 py-0.5 rounded font-medium';
    addBtn.classList.add('hidden');
  }
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

function openAddStaff() {
  document.getElementById('staffForm').reset();
  document.getElementById('staffModalTitle').innerText = 'Thêm nhân sự mới';
  document.getElementById('staffEditId').value = '';
  document.getElementById('staffUsername').disabled = false;
  
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
  const coSoSelect = document.getElementById('staffCoSo');
  if (coSoSelect) coSoSelect.disabled = false;
  
  updateRoleDropdown(false, null);
  document.getElementById('staffModal').classList.remove('hidden');
}

function editStaff(id) {
  const s = staffList.find(x => x.id == id);
  if (!s) return;
  document.getElementById('staffModalTitle').innerText = 'Chỉnh sửa tài khoản';
  document.getElementById('staffEditId').value = s.id;
  document.getElementById('staffName').value = s.name;
  document.getElementById('staffUsername').value = s.username;
  document.getElementById('staffUsername').disabled = true;
  document.getElementById('staffEmail').value = s.email;
  document.getElementById('staffPhone').value = s.phone;
  
  // Reset OTP containers
  document.getElementById('staffFieldsContainer').classList.remove('hidden');
  document.getElementById('otpVerificationSection').classList.add('hidden');
  document.querySelectorAll('.otp-box').forEach(b => b.value = '');
  document.getElementById('otpErrorBanner').classList.add('hidden');
  
  // Set password to optional and set label
  const pwdLabel = document.getElementById('pwdLabel');
  const staffPassword = document.getElementById('staffPassword');
  pwdLabel.innerHTML = 'Mật khẩu (Để trống nếu giữ nguyên)';
  staffPassword.required = false;
  staffPassword.type = 'password';
  document.getElementById('passwordStrengthContainer').classList.add('hidden');
  
  updateRoleDropdown(true, s.roleId);

  const coSoSelect = document.getElementById('staffCoSo');
  if (coSoSelect && s.coSoId) {
    coSoSelect.value = s.coSoId;
  }

  // Handle locks for Manager accounts (roleId === 2)
  const staffRoleSelect = document.getElementById('staffRole');
  if (s.roleId === 2) {
    staffRoleSelect.disabled = true;
    if (coSoSelect) coSoSelect.disabled = true;
  } else {
    staffRoleSelect.disabled = false;
    if (coSoSelect) coSoSelect.disabled = false;
  }

  // Handle password editing restriction for Manager (2), Customer (3), Receptionist (4), and Security (5) roles
  const disablePasswordChange = [2, 3, 4, 5].includes(s.roleId);
  if (disablePasswordChange) {
    staffPassword.disabled = true;
    staffPassword.placeholder = "Được giữ bảo mật (không thể thay đổi)";
    pwdLabel.innerHTML = 'Mật khẩu (Được giữ bảo mật)';
  } else {
    staffPassword.disabled = false;
    staffPassword.placeholder = "••••••••";
  }

  document.getElementById('staffModal').classList.remove('hidden');
}

function closeStaffModal() { document.getElementById('staffModal').classList.add('hidden'); }

// Setup input events for 6 OTP boxes
document.addEventListener('DOMContentLoaded', () => {
    const boxes = document.querySelectorAll('.otp-box');
    boxes.forEach((box, idx, arr) => {
        box.addEventListener('input', (e) => {
            const val = e.target.value;
            // Allow only numbers
            if (val && !/^[0-9]$/.test(val)) {
                e.target.value = '';
                return;
            }
            if (val && idx < arr.length - 1) {
                arr[idx + 1].focus();
            }
        });
        box.addEventListener('keydown', (e) => {
            if (e.key === 'Backspace' && !e.target.value && idx > 0) {
                arr[idx - 1].focus();
            }
        });
        box.addEventListener('paste', (e) => {
            e.preventDefault();
            const text = e.clipboardData.getData('text').trim();
            if (/^\d{6}$/.test(text)) {
                text.split('').forEach((char, i) => {
                    arr[i].value = char;
                });
                arr[5].focus();
            }
        });
    });
});

let pendingStaffParams = null;

function cancelOtpVerification() {
    document.getElementById('otpVerificationSection').classList.add('hidden');
    document.getElementById('staffFieldsContainer').classList.remove('hidden');
    // Clear boxes
    document.querySelectorAll('.otp-box').forEach(box => box.value = '');
    document.getElementById('otpErrorBanner').classList.add('hidden');
}

async function handleStaffSubmit(e) {
  e.preventDefault();
  const editId = document.getElementById('staffEditId').value;
  
  const params = new URLSearchParams();
  params.append('action', editId ? 'update' : 'add');
  if (editId) params.append('accountId', editId);
  else params.append('username', document.getElementById('staffUsername').value);
  
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
          document.querySelectorAll('.otp-box')[0].focus();
          pendingStaffParams = params;
      } else {
          // Success directly
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
            document.getElementById('otpErrorMsgText').innerText = data.loi || 'Mã OTP không đúng. Vui lòng nhập lại.';
            document.getElementById('otpErrorBanner').classList.remove('hidden');
            boxes.forEach(b => b.value = '');
            boxes[0].focus();
        }
    } catch(err) {
        console.error(err);
        document.getElementById('otpErrorMsgText').innerText = 'Lỗi kết nối. Vui lòng thử lại.';
        document.getElementById('otpErrorBanner').classList.remove('hidden');
    } finally {
        btn.disabled = false;
        btn.innerHTML = oldText;
    }
}

// Profile Dropdown Toggle
document.addEventListener('DOMContentLoaded', () => {
    renderStaff();
    renderTrash();
    // Hiện badge thùng rác nếu có
    const badge = document.getElementById('trashCountBadge');
    if (deletedList.length > 0) {
      badge.innerText = deletedList.length;
      badge.classList.remove('hidden');
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
});
</script>

</body>
</html>
