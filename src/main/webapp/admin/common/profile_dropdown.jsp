<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<style>
  @keyframes modalScaleIn {
    from { opacity: 0; transform: scale(0.95); }
    to { opacity: 1; transform: scale(1); }
  }
  .modal-animate-scale {
    animation: modalScaleIn 0.2s cubic-bezier(0.16, 1, 0.3, 1) forwards;
  }
</style>

<div class="relative">
  <button id="profileBtn" class="flex items-center gap-2.5 px-2 py-1.5 rounded-lg hover:bg-zinc-100 transition-colors">
    <img src="https://ui-avatars.com/api/?name=${sessionScope.user.fullName != null ? sessionScope.user.fullName : sessionScope.user.username}&background=2563eb&color=fff&bold=true" class="w-8 h-8 rounded-full object-cover ring-2 ring-white" alt="Avatar">
    <div class="hidden sm:block text-left">
      <p class="text-sm font-semibold text-zinc-900 leading-tight">
        <c:out value="${sessionScope.user.fullName != null ? sessionScope.user.fullName : sessionScope.user.username}" />
      </p>
      <p class="text-[10px] text-zinc-500">
        <c:choose>
          <c:when test="${sessionScope.user.roleId == 1}">Quản trị viên</c:when>
          <c:when test="${sessionScope.user.roleId == 2}">Quản lý</c:when>
          <c:when test="${sessionScope.user.roleId == 4}">Lễ tân</c:when>
          <c:when test="${sessionScope.user.roleId == 5}">Bảo vệ</c:when>
          <c:otherwise>Nhân viên</c:otherwise>
        </c:choose>
        <c:if test="${not empty sessionScope.user.coSoId}">
          · CS<c:out value="${sessionScope.user.coSoId}" />
        </c:if>
      </p>
    </div>
    <span id="profileChevron" class="material-symbols-outlined text-[16px] text-zinc-400 hidden sm:block transition-transform duration-150">expand_more</span>
  </button>
  
  <div id="profileDrop" class="hidden absolute top-[calc(100%+8px)] right-0 w-[320px] bg-white rounded-2xl shadow-xl border border-zinc-200 z-50 overflow-hidden font-sans">
    <div class="relative px-5 py-4 border-b border-zinc-100">
      <div class="absolute inset-0 bg-gradient-to-br from-blue-600/[0.04] to-transparent pointer-events-none"></div>
      <div class="flex items-start gap-3.5">
        <div class="relative shrink-0">
          <img class="w-[52px] h-[52px] rounded-full object-cover ring-2 ring-blue-600/30" src="https://ui-avatars.com/api/?name=${sessionScope.user.fullName != null ? sessionScope.user.fullName : sessionScope.user.username}&background=2563eb&color=fff&bold=true" alt="Avatar">
          <span class="absolute bottom-0 right-0 w-3.5 h-3.5 rounded-full bg-[#05cd99] border-2 border-white"></span>
        </div>
        <div class="flex-1 min-w-0">
          <p class="font-bold text-[15px] text-zinc-900 leading-tight">
            <c:out value="${sessionScope.user.fullName != null ? sessionScope.user.fullName : sessionScope.user.username}" />
          </p>
          <div class="flex items-center gap-1.5 mt-1 flex-wrap">
            <span class="inline-flex items-center gap-1 text-[11px] font-bold text-blue-700 bg-blue-50 px-2 py-0.5 rounded-full whitespace-nowrap">
              <span class="material-symbols-outlined text-[11px]" style="font-variation-settings:'FILL' 1">verified_user</span>
              <c:choose>
                <c:when test="${sessionScope.user.roleId == 1}">Quản trị viên</c:when>
                <c:when test="${sessionScope.user.roleId == 2}">Quản lý</c:when>
                <c:when test="${sessionScope.user.roleId == 4}">Lễ tân</c:when>
                <c:when test="${sessionScope.user.roleId == 5}">Bảo vệ</c:when>
                <c:otherwise>Nhân viên</c:otherwise>
              </c:choose>
            </span>
            <span class="inline-flex items-center gap-1 text-[11px] font-medium text-[#05cd99] bg-[#e6fcf5] px-2 py-0.5 rounded-full whitespace-nowrap">
              <span class="w-1.5 h-1.5 rounded-full bg-[#05cd99] inline-block"></span>Online
            </span>
          </div>
          <p class="text-xs text-zinc-500 mt-1.5">ID: <span class="font-semibold text-zinc-800 font-mono">ACC-<c:out value="${sessionScope.user.accountId}" /></span></p>
        </div>
      </div>
    </div>
    
    <div class="px-4 py-3 border-b border-zinc-100 flex flex-col gap-2.5">
      <div class="flex items-center gap-2.5"><span class="material-symbols-outlined text-[16px] text-zinc-400 w-4 shrink-0">mail</span><p class="text-[13px] text-zinc-700 truncate"><c:out value="${sessionScope.user.email != null ? sessionScope.user.email : 'Chưa cập nhật'}" /></p></div>
      <div class="flex items-center gap-2.5"><span class="material-symbols-outlined text-[16px] text-zinc-400 w-4 shrink-0">phone</span><p class="text-[13px] text-zinc-700"><c:out value="${sessionScope.user.phoneNumber != null ? sessionScope.user.phoneNumber : 'Chưa cập nhật'}" /></p></div>
      <c:if test="${not empty sessionScope.user.coSoId}">
        <div class="flex items-center gap-2.5"><span class="material-symbols-outlined text-[16px] text-zinc-400 w-4 shrink-0">domain</span><p class="text-[13px] text-zinc-700">Cơ Sở CS<c:out value="${sessionScope.user.coSoId}" /></p></div>
      </c:if>
    </div>
    
    <div class="p-2">
      <button onclick="document.getElementById('profileDrop').classList.add('hidden');document.getElementById('editProfileModal').classList.remove('hidden');" class="flex items-center gap-3 px-3 py-2 rounded-xl hover:bg-zinc-50 transition-colors text-left w-full"><span class="material-symbols-outlined text-[17px] text-zinc-400">manage_accounts</span><span class="text-[13px] font-medium text-zinc-700 font-sans">Hồ sơ cá nhân</span></button>
      <button onclick="document.getElementById('profileDrop').classList.add('hidden');document.getElementById('changePwModal').classList.remove('hidden');" class="flex items-center gap-3 px-3 py-2 rounded-xl hover:bg-zinc-50 transition-colors text-left w-full"><span class="material-symbols-outlined text-[17px] text-zinc-400">lock_reset</span><span class="text-[13px] font-medium text-zinc-700 font-sans">Đổi mật khẩu</span></button>
      <button onclick="openSettings()" class="flex items-center gap-3 px-3 py-2 rounded-xl hover:bg-zinc-50 transition-colors text-left w-full"><span class="material-symbols-outlined text-[17px] text-zinc-400">settings</span><span class="text-[13px] font-medium text-zinc-700 font-sans">Cài đặt</span></button>
      <div class="border-t border-zinc-100 mt-1 pt-1"><a href="${pageContext.request.contextPath}/logout" class="flex items-center gap-3 px-3 py-2 rounded-xl hover:bg-red-50 transition-colors text-left w-full text-red-600"><span class="material-symbols-outlined text-[17px] text-red-600">logout</span><span class="text-[13px] font-medium">Đăng xuất</span></a></div>
    </div>
  </div>
</div>

<!-- Edit Profile Modal -->
<div id="editProfileModal" class="hidden fixed inset-0 z-[80] flex items-center justify-center p-4">
  <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" onclick="document.getElementById('editProfileModal').classList.add('hidden')"></div>
  <div class="relative bg-white rounded-2xl shadow-2xl w-full max-w-[520px] max-h-[90vh] overflow-y-auto z-10 border border-zinc-200 modal-animate-scale">
    <div class="flex items-center justify-between px-6 py-4 border-b border-zinc-200">
      <div class="flex items-center gap-2.5"><span class="material-symbols-outlined text-[20px] text-blue-700">manage_accounts</span><h3 class="text-base font-bold text-zinc-900 font-sans">Hồ sơ cá nhân</h3></div>
      <button onclick="document.getElementById('editProfileModal').classList.add('hidden')" class="w-8 h-8 rounded-full hover:bg-zinc-100 flex items-center justify-center transition-colors"><span class="material-symbols-outlined text-[18px] text-zinc-500">close</span></button>
    </div>
    <div class="flex flex-col items-center gap-3 pt-6 pb-4 border-b border-zinc-100">
      <div class="relative">
        <img id="editAvatarPreview" class="w-20 h-20 rounded-full object-cover ring-2 ring-blue-600/30" src="https://ui-avatars.com/api/?name=${sessionScope.user.fullName != null ? sessionScope.user.fullName : sessionScope.user.username}&background=2563eb&color=fff&bold=true" alt="Avatar">
        <label for="avatarUpload" class="absolute bottom-0 right-0 w-7 h-7 rounded-full bg-blue-700 text-white flex items-center justify-center cursor-pointer shadow hover:opacity-90 transition-opacity"><span class="material-symbols-outlined text-[14px]">photo_camera</span></label>
        <input id="avatarUpload" type="file" accept="image/*" class="hidden" onchange="previewAvatar(this)">
      </div>
      <p class="text-xs text-zinc-500">Nhấn biểu tượng máy ảnh để thay ảnh đại diện</p>
    </div>
    <div class="px-6 py-5">
      <p class="text-[10px] font-bold uppercase tracking-wider text-zinc-500 mb-4">Thông tin chi tiết — <span class="text-blue-700">Bảng Accounts</span></p>
      <div class="grid grid-cols-2 gap-4">
        <div class="col-span-2 sm:col-span-1"><label class="block text-xs font-semibold text-zinc-500 mb-1.5">Họ và tên</label><input type="text" id="editFullName" value="${sessionScope.user.fullName != null ? sessionScope.user.fullName : ''}" class="w-full h-10 px-3 rounded-lg border border-zinc-200 bg-white text-sm text-zinc-800 focus:border-blue-700 focus:outline-none transition-colors font-medium"></div>
        <div class="col-span-2 sm:col-span-1"><label class="block text-xs font-semibold text-zinc-500 mb-1.5">Mã tài khoản</label><input type="text" value="ACC-${sessionScope.user.accountId}" readonly class="w-full h-10 px-3 rounded-lg border border-zinc-200 bg-zinc-50 text-sm text-zinc-500 cursor-not-allowed focus:outline-none font-medium"></div>
        <div class="col-span-2 sm:col-span-1"><label class="block text-xs font-semibold text-zinc-500 mb-1.5">Email</label><input type="email" id="editEmail" value="${sessionScope.user.email != null ? sessionScope.user.email : ''}" class="w-full h-10 px-3 rounded-lg border border-zinc-200 bg-white text-sm text-zinc-800 focus:border-blue-700 focus:outline-none transition-colors font-medium"></div>
        <div class="col-span-2 sm:col-span-1"><label class="block text-xs font-semibold text-zinc-500 mb-1.5">Số điện thoại</label><input type="tel" id="editPhone" value="${sessionScope.user.phoneNumber != null ? sessionScope.user.phoneNumber : ''}" class="w-full h-10 px-3 rounded-lg border border-zinc-200 bg-white text-sm text-zinc-800 focus:border-blue-700 focus:outline-none transition-colors font-medium"></div>
      </div>
      <p class="text-[11px] text-zinc-500 mt-4 italic">Dữ liệu được đồng bộ từ bảng <code class="font-mono bg-zinc-50 px-1 rounded">Accounts</code> của CSDL V-Sport V4</p>
    </div>
    <div class="px-6 pb-5 flex gap-3 justify-end">
      <button onclick="document.getElementById('editProfileModal').classList.add('hidden')" class="h-10 px-5 rounded-lg border border-zinc-200 text-sm font-semibold text-zinc-600 hover:bg-zinc-50 transition-colors">Hủy</button>
      <button onclick="saveProfileChanges()" class="h-10 px-5 rounded-lg bg-blue-700 text-white text-sm font-semibold hover:opacity-90 transition-opacity active:scale-95">Lưu thay đổi</button>
    </div>
  </div>
</div>

<!-- Change Password Modal -->
<div id="changePwModal" class="hidden fixed inset-0 z-[80] flex items-center justify-center p-4">
  <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" onclick="document.getElementById('changePwModal').classList.add('hidden')"></div>
  <div class="relative bg-white rounded-2xl shadow-2xl w-full max-w-[400px] z-10 border border-zinc-200 modal-animate-scale">
    <div class="flex items-center justify-between px-6 py-4 border-b border-zinc-200">
      <div class="flex items-center gap-2.5"><span class="material-symbols-outlined text-[20px] text-blue-700">lock_reset</span><h3 class="text-base font-bold text-zinc-900 font-sans">Đổi mật khẩu</h3></div>
      <button onclick="document.getElementById('changePwModal').classList.add('hidden')" class="w-8 h-8 rounded-full hover:bg-zinc-100 flex items-center justify-center transition-colors"><span class="material-symbols-outlined text-[18px] text-zinc-500">close</span></button>
    </div>
    <div class="px-6 py-5 flex flex-col gap-4 font-sans">
      <div><label class="block text-xs font-semibold text-zinc-500 mb-1.5">Mật khẩu hiện tại</label><div class="relative"><input type="password" id="pwCurrent" placeholder="••••••••" class="w-full h-10 px-3 pr-10 rounded-lg border border-zinc-200 bg-white text-sm text-zinc-800 focus:border-blue-700 focus:outline-none transition-colors"><button type="button" onclick="togglePw(this)" data-target="pwCurrent" class="absolute right-3 top-1/2 -translate-y-1/2 text-zinc-500 hover:text-zinc-700 transition-colors"><span class="material-symbols-outlined text-[18px]">visibility_off</span></button></div></div>
      <div><label class="block text-xs font-semibold text-zinc-500 mb-1.5">Mật khẩu mới</label><div class="relative"><input type="password" id="pwNew" placeholder="••••••••" oninput="updatePwStrength(this)" class="w-full h-10 px-3 pr-10 rounded-lg border border-zinc-200 bg-white text-sm text-zinc-800 focus:border-blue-700 focus:outline-none transition-colors"><button type="button" onclick="togglePw(this)" data-target="pwNew" class="absolute right-3 top-1/2 -translate-y-1/2 text-zinc-500 hover:text-zinc-700 transition-colors"><span class="material-symbols-outlined text-[18px]">visibility_off</span></button></div><div class="flex gap-1 mt-2"><div class="h-1 flex-1 rounded-full bg-zinc-100" id="str1"></div><div class="h-1 flex-1 rounded-full bg-zinc-100" id="str2"></div><div class="h-1 flex-1 rounded-full bg-zinc-100" id="str3"></div><div class="h-1 flex-1 rounded-full bg-zinc-100" id="str4"></div></div><p id="pwStrengthLabel" class="text-[11px] text-zinc-500 mt-1"></p></div>
      <div><label class="block text-xs font-semibold text-zinc-500 mb-1.5">Xác nhận mật khẩu mới</label><div class="relative"><input type="password" id="pwConfirm" placeholder="••••••••" class="w-full h-10 px-3 pr-10 rounded-lg border border-zinc-200 bg-white text-sm text-zinc-800 focus:border-blue-700 focus:outline-none transition-colors"><button type="button" onclick="togglePw(this)" data-target="pwConfirm" class="absolute right-3 top-1/2 -translate-y-1/2 text-zinc-500 hover:text-zinc-700 transition-colors"><span class="material-symbols-outlined text-[18px]">visibility_off</span></button></div></div>
    </div>
    <div class="px-6 pb-5 flex gap-3 justify-end">
      <button onclick="document.getElementById('changePwModal').classList.add('hidden')" class="h-10 px-5 rounded-lg border border-zinc-200 text-sm font-semibold text-zinc-650 hover:bg-zinc-50 transition-colors">Hủy</button>
      <button onclick="savePassword()" class="h-10 px-5 rounded-lg bg-blue-700 text-white text-sm font-semibold hover:opacity-90 transition-opacity active:scale-95 font-sans">Đổi mật khẩu</button>
    </div>
  </div>
</div>

<!-- Settings Overlay -->
<div id="settingsOverlay" class="fixed inset-0 bg-gray-900/20 backdrop-blur-sm z-[90] hidden opacity-0 transition-opacity duration-300"></div>

<!-- Settings Drawer -->
<aside id="settingsDrawer" class="fixed top-0 right-0 h-full w-[400px] max-w-[92vw] bg-white border-l border-gray-100 shadow-2xl z-[100] flex flex-col translate-x-full transition-transform duration-500 cubic-bezier(0.4, 0, 0.2, 1)">
  <div class="flex items-center justify-between px-8 py-6 border-b border-zinc-100 shrink-0 bg-zinc-50/50">
    <div class="flex items-center gap-3">
      <div class="w-10 h-10 rounded-xl bg-blue-50 flex items-center justify-center text-blue-700 border border-blue-100">
        <span class="material-symbols-outlined text-2xl">settings</span>
      </div>
      <h3 class="text-base font-bold text-zinc-800">Cài đặt <span class="text-blue-700">Hệ thống</span></h3>
    </div>
    <button onclick="closeSettings()" class="w-8 h-8 flex items-center justify-center rounded-full bg-zinc-100 text-zinc-400 hover:text-zinc-600 transition-all">
      <span class="material-symbols-outlined text-[18px]">close</span>
    </button>
  </div>
  
  <div class="flex-1 overflow-y-auto p-6 flex flex-col gap-8">
    <section class="space-y-4">
      <p class="text-[10px] font-bold uppercase tracking-widest text-zinc-400 ml-1">Giao diện cá nhân</p>
      <div class="grid grid-cols-3 gap-2">
        <button id="themeLight" onclick="setTheme('light')" class="theme-opt group flex flex-col items-center gap-2 py-4 rounded-xl border border-zinc-100 bg-white hover:bg-zinc-50 transition-all">
          <span class="material-symbols-outlined text-xl text-zinc-400 group-hover:text-zinc-600">light_mode</span>
          <span class="text-[10px] font-bold uppercase tracking-widest text-zinc-400">Sáng</span>
        </button>
        <button id="themeDark" onclick="setTheme('dark')" class="theme-opt group flex flex-col items-center gap-2 py-4 rounded-xl border border-zinc-100 bg-white hover:bg-zinc-50 transition-all">
          <span class="material-symbols-outlined text-xl text-zinc-400 group-hover:text-zinc-600">dark_mode</span>
          <span class="text-[10px] font-bold uppercase tracking-widest text-zinc-400">Tối</span>
        </button>
        <button id="themeSystem" onclick="setTheme('system')" class="theme-opt group flex flex-col items-center gap-2 py-4 rounded-xl border border-zinc-100 bg-white hover:bg-zinc-50 transition-all">
          <span class="material-symbols-outlined text-xl text-zinc-400 group-hover:text-zinc-600">routine</span>
          <span class="text-[10px] font-bold uppercase tracking-widest text-zinc-400">Tự động</span>
        </button>
      </div>
    </section>

    <section class="space-y-4">
      <p class="text-[10px] font-bold uppercase tracking-widest text-zinc-400 ml-1">Thông báo & Âm thanh</p>
      <div class="space-y-2">
        <div class="flex items-center justify-between p-3.5 bg-zinc-50 border border-zinc-100 rounded-xl">
          <div class="flex items-center gap-3 text-zinc-650 font-bold text-xs">
            <span class="material-symbols-outlined text-lg opacity-60">volume_up</span> Âm thanh hệ thống
          </div>
          <button onclick="toggleSetting('sound',this)" class="on relative w-10 h-5.5 rounded-full bg-blue-600 transition-all">
            <span class="knob absolute top-0.5 right-0.5 w-4.5 h-4.5 bg-white rounded-full transition-all shadow-sm"></span>
          </button>
        </div>
        <div class="flex items-center justify-between p-3.5 bg-zinc-50 border border-zinc-100 rounded-xl">
          <div class="flex items-center gap-3 text-zinc-650 font-bold text-xs">
            <span class="material-symbols-outlined text-lg opacity-60">calendar_today</span> Thông báo đặt sân
          </div>
          <button onclick="toggleSetting('booking',this)" class="on relative w-10 h-5.5 rounded-full bg-blue-600 transition-all">
            <span class="knob absolute top-0.5 right-0.5 w-4.5 h-4.5 bg-white rounded-full transition-all shadow-sm"></span>
          </button>
        </div>
      </div>
    </section>
  </div>

  <div class="shrink-0 p-6 border-t border-zinc-100 flex gap-3 bg-white">
    <button onclick="resetSettings()" class="flex-1 py-2.5 rounded-lg border border-zinc-200 text-xs font-bold text-zinc-650 hover:bg-zinc-50 transition-all">Mặc định</button>
    <button onclick="saveSettings()" class="flex-1 py-2.5 rounded-lg bg-blue-700 text-white text-xs font-bold hover:bg-blue-800 transition-all shadow-md">Lưu thay đổi</button>
  </div>
</aside>

<!-- Success Toast -->
<div id="successToast" class="fixed bottom-6 right-6 z-[100] flex items-center gap-3 px-4 py-3 bg-zinc-900 text-white rounded-xl shadow-xl transition-all duration-300 opacity-0 translate-y-12 pointer-events-none">
  <span class="material-symbols-outlined text-green-400 text-[20px]">check_circle</span>
  <div>
    <p class="text-xs font-bold" id="toastTitle">Thành công</p>
    <p class="text-[11px] text-zinc-300" id="toastMessage">Đã lưu thay đổi.</p>
  </div>
</div>

<script>
  // Profile & settings logic
  document.addEventListener('DOMContentLoaded', () => {
    // Move modals and overlays to body to avoid stacking context / clipping issues
    const elementsToMove = ['editProfileModal', 'changePwModal', 'settingsOverlay', 'settingsDrawer', 'successToast'];
    elementsToMove.forEach(id => {
      const el = document.getElementById(id);
      if (el && el.parentElement !== document.body) {
        document.body.appendChild(el);
      }
    });

    const profileBtn = document.getElementById('profileBtn');
    const profileDrop = document.getElementById('profileDrop');
    const profileChevron = document.getElementById('profileChevron');
    
    if (profileBtn && profileDrop) {
      function openDrop() {
        profileDrop.classList.remove('hidden');
        profileDrop.style.cssText = 'opacity:0;transform:translateY(-8px) scale(0.97);transition:opacity 0.18s ease,transform 0.18s ease';
        requestAnimationFrame(() => {
          profileDrop.style.opacity = '1';
          profileDrop.style.transform = 'translateY(0) scale(1)';
        });
        if (profileChevron) profileChevron.style.transform = 'rotate(180deg)';
      }
      function closeDrop() {
        profileDrop.style.opacity = '0';
        profileDrop.style.transform = 'translateY(-8px) scale(0.97)';
        setTimeout(() => {
          profileDrop.classList.add('hidden');
          profileDrop.style.cssText = '';
        }, 180);
        if (profileChevron) profileChevron.style.transform = '';
      }
      profileBtn.addEventListener('click', e => {
        e.stopPropagation();
        profileDrop.classList.contains('hidden') ? openDrop() : closeDrop();
      });
      document.addEventListener('click', e => {
        if (!profileDrop.classList.contains('hidden') && !profileBtn.contains(e.target) && !profileDrop.contains(e.target)) {
          closeDrop();
        }
      });
    }
  });

  function showToast(title, msg) {
    const toast = document.getElementById('successToast');
    if (!toast) return;
    document.getElementById('toastTitle').textContent = title;
    document.getElementById('toastMessage').textContent = msg;
    toast.classList.remove('opacity-0', 'translate-y-12', 'pointer-events-none');
    setTimeout(() => {
      toast.classList.add('opacity-0', 'translate-y-12', 'pointer-events-none');
    }, 4000);
  }

  function saveProfileChanges() {
    const name = document.getElementById('editFullName').value;
    const email = document.getElementById('editEmail').value;
    const phone = document.getElementById('editPhone').value;
    
    if (!name || !email || !phone) {
      alert("Vui lòng nhập đầy đủ thông tin!");
      return;
    }
    
    const params = new URLSearchParams();
    params.append('action', 'updateInfo');
    params.append('fullName', name);
    params.append('email', email);
    params.append('phoneNumber', phone);
    
    fetch('${pageContext.request.contextPath}/admin/update-profile', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
      },
      body: params
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        // Save to UI
        document.querySelectorAll('#profileBtn p').forEach(el => {
          if (el.classList.contains('text-sm')) el.textContent = name;
        });
        document.querySelectorAll('#profileDrop p').forEach(el => {
          if (el.classList.contains('font-bold') && el.classList.contains('text-[15px]')) el.textContent = name;
        });
        
        document.getElementById('editProfileModal').classList.add('hidden');
        showToast('Thành công', data.message);
      } else {
        alert(data.message);
      }
    })
    .catch(error => {
      console.error('Error:', error);
      alert("Đã xảy ra lỗi khi kết nối tới máy chủ.");
    });
  }

  function savePassword() {
    const pwCurrent = document.getElementById('pwCurrent').value;
    const pw = document.getElementById('pwNew').value;
    const cf = document.getElementById('pwConfirm').value;
    if (!pwCurrent) {
      alert("Vui lòng nhập mật khẩu hiện tại!");
      return;
    }
    if (!pw) {
      alert("Vui lòng nhập mật khẩu mới!");
      return;
    }
    if (pw !== cf) {
      document.getElementById('pwConfirm').style.borderColor = '#ef4444';
      setTimeout(() => { document.getElementById('pwConfirm').style.borderColor = ''; }, 1500);
      return;
    }
    
    const params = new URLSearchParams();
    params.append('action', 'changePassword');
    params.append('currentPassword', pwCurrent);
    params.append('newPassword', pw);
    
    fetch('${pageContext.request.contextPath}/admin/update-profile', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
      },
      body: params
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        document.getElementById('changePwModal').classList.add('hidden');
        document.getElementById('pwCurrent').value = '';
        document.getElementById('pwNew').value = '';
        document.getElementById('pwConfirm').value = '';
        
        for (let i = 1; i <= 4; i++) {
          const el = document.getElementById('str' + i);
          if (el) el.style.backgroundColor = '';
        }
        const lbl = document.getElementById('pwStrengthLabel');
        if (lbl) lbl.textContent = '';
        
        showToast('Thành công', data.message);
      } else {
        alert(data.message);
      }
    })
    .catch(error => {
      console.error('Error:', error);
      alert("Đã xảy ra lỗi khi kết nối tới máy chủ.");
    });
  }

  function togglePw(btn) {
    const inp = document.getElementById(btn.dataset.target);
    const ic = btn.querySelector('.material-symbols-outlined');
    if (inp.type === 'password') {
      inp.type = 'text';
      ic.textContent = 'visibility';
    } else {
      inp.type = 'password';
      ic.textContent = 'visibility_off';
    }
  }

  function updatePwStrength(inp) {
    const v = inp.value;
    let s = 0;
    if (v.length >= 8) s++;
    if (/[A-Z]/.test(v)) s++;
    if (/[0-9]/.test(v)) s++;
    if (/[^A-Za-z0-9]/.test(v)) s++;
    const cols = ['#ef4444', '#f59e0b', '#2563eb', '#10b981'];
    const labs = ['', 'Yếu', 'Trung bình', 'Mạnh', 'Rất mạnh'];
    for (let i = 1; i <= 4; i++) {
      const el = document.getElementById('str' + i);
      if (el) el.style.backgroundColor = i <= s ? cols[s - 1] : '';
    }
    const lbl = document.getElementById('pwStrengthLabel');
    if (lbl) lbl.textContent = v.length ? labs[s] : '';
  }

  function previewAvatar(input) {
    if (input.files && input.files[0]) {
      const r = new FileReader();
      r.onload = function(e) {
        document.getElementById('editAvatarPreview').src = e.target.result;
        // Also update standard avatars
        document.querySelectorAll('#profileBtn img, #profileDrop img').forEach(img => {
          img.src = e.target.result;
        });
      };
      r.readAsDataURL(input.files[0]);
    }
  }

  // Settings drawer logic
  function openSettings() {
    const o = document.getElementById('settingsOverlay');
    const dr = document.getElementById('settingsDrawer');
    o.classList.remove('hidden');
    requestAnimationFrame(() => {
      o.classList.add('opacity-100');
      dr.classList.remove('translate-x-full');
    });
  }

  // settings panel triggers
  function closeSettings() {
    const o = document.getElementById('settingsOverlay');
    const dr = document.getElementById('settingsDrawer');
    o.classList.remove('opacity-100');
    dr.classList.add('translate-x-full');
    setTimeout(() => { o.classList.add('hidden'); }, 300);
  }

  function toggleSetting(k, btn) {
    const on = btn.classList.contains('on');
    const kn = btn.querySelector('.knob');
    if (on) {
      btn.classList.remove('on', 'bg-blue-600');
      btn.classList.add('bg-zinc-200');
      kn.classList.remove('right-0.5');
      kn.classList.add('left-0.5');
    } else {
      btn.classList.add('on', 'bg-blue-600');
      btn.classList.remove('bg-zinc-200');
      kn.classList.add('right-0.5');
      kn.classList.remove('left-0.5');
    }
  }

  function setTheme(t) {
    localStorage.setItem('admin_theme', t);
    // sync buttons UI
    ['light', 'dark', 'system'].forEach(k => {
      const b = document.getElementById('theme' + k.charAt(0).toUpperCase() + k.slice(1));
      if (!b) return;
      if (k === t) {
        b.classList.add('border-blue-600', 'bg-blue-50/20');
        b.classList.remove('border-zinc-150');
      } else {
        b.classList.remove('border-blue-600', 'bg-blue-50/20');
        b.classList.add('border-zinc-150');
      }
    });
    if (t === 'dark') document.documentElement.classList.add('dark');
    else if (t === 'light') document.documentElement.classList.remove('dark');
  }

  function resetSettings() { setTheme('light'); }
  function saveSettings() { closeSettings(); showToast('Thành công', 'Đã lưu cài đặt hệ thống.'); }
</script>
