<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>
<!-- Settings Overlay -->
<div id="settingsOverlay" class="fixed inset-0 bg-gray-900/20 backdrop-blur-sm z-[90] hidden opacity-0 transition-opacity duration-300"></div>

<!-- Settings Drawer -->
<aside id="settingsDrawer" class="fixed top-0 right-0 h-full w-[400px] max-w-[92vw] bg-white border-l border-gray-100 shadow-2xl z-[100] flex flex-col translate-x-full transition-transform duration-500 cubic-bezier(0.4, 0, 0.2, 1)">
  <div class="flex items-center justify-between px-8 py-6 border-b border-gray-50 shrink-0 bg-gray-50/30">
    <div class="flex items-center gap-3">
      <div class="w-10 h-10 rounded-xl bg-[#d92550]/10 flex items-center justify-center text-[#d92550] border border-[#d92550]/10">
        <span class="material-symbols-outlined text-2xl">settings</span>
      </div>
      <h3 class="text-lg font-bold text-gray-700">Cài đặt <span class="text-[#d92550]">Hệ thống</span></h3>
    </div>
    <button id="closeSettingsBtn" class="w-10 h-10 flex items-center justify-center rounded-full bg-gray-100 text-gray-400 hover:text-gray-600 transition-all">
      <span class="material-symbols-outlined">close</span>
    </button>
  </div>
  
  <div class="flex-1 overflow-y-auto p-8 flex flex-col gap-10">
    <!-- Theme Section -->
    <section class="space-y-6">
      <p class="text-[10px] font-bold uppercase tracking-widest text-gray-400 ml-1">Giao diện cá nhân</p>
      <div class="grid grid-cols-3 gap-3">
        <button id="themeLight" onclick="setTheme('light')" class="theme-opt group flex flex-col items-center gap-3 py-5 rounded-xl border border-gray-100 bg-white hover:bg-gray-50 transition-all">
          <span class="material-symbols-outlined text-2xl text-gray-400 group-hover:text-gray-600">light_mode</span>
          <span class="text-[11px] font-bold uppercase tracking-widest text-gray-400">Sáng</span>
        </button>
        <button id="themeDark" onclick="setTheme('dark')" class="theme-opt group flex flex-col items-center gap-3 py-5 rounded-xl border border-[#d92550]/30 bg-[#d92550]/5 transition-all">
          <span class="material-symbols-outlined text-2xl text-[#d92550]">dark_mode</span>
          <span class="text-[11px] font-bold uppercase tracking-widest text-[#d92550]">Tối</span>
        </button>
        <button id="themeSystem" onclick="setTheme('system')" class="theme-opt group flex flex-col items-center gap-3 py-5 rounded-xl border border-gray-100 bg-white hover:bg-gray-50 transition-all">
          <span class="material-symbols-outlined text-2xl text-gray-400 group-hover:text-gray-600">routine</span>
          <span class="text-[11px] font-bold uppercase tracking-widest text-gray-400">Auto</span>
        </button>
      </div>
    </section>

    <!-- Notification Section -->
    <section class="space-y-6">
      <p class="text-[10px] font-bold uppercase tracking-widest text-gray-400 ml-1">Thông báo & Âm thanh</p>
      <div class="space-y-2">
        <div class="flex items-center justify-between p-4 bg-gray-50 border border-gray-100 rounded-xl">
          <div class="flex items-center gap-4 text-gray-600 font-bold text-sm">
            <span class="material-symbols-outlined text-lg opacity-50">volume_up</span> Âm thanh thông báo
          </div>
          <button onclick="toggleSetting('sound',this)" class="on relative w-11 h-6 rounded-full bg-[#d92550] transition-all">
            <span class="knob absolute top-1 right-1 w-4 h-4 bg-white rounded-full transition-all shadow-sm"></span>
          </button>
        </div>
        <div class="flex items-center justify-between p-4 bg-gray-50 border border-gray-100 rounded-xl">
          <div class="flex items-center gap-4 text-gray-600 font-bold text-sm">
            <span class="material-symbols-outlined text-lg opacity-50">calendar_today</span> Thông báo đặt sân
          </div>
          <button onclick="toggleSetting('booking',this)" class="on relative w-11 h-6 rounded-full bg-[#d92550] transition-all">
            <span class="knob absolute top-1 right-1 w-4 h-4 bg-white rounded-full transition-all shadow-sm"></span>
          </button>
        </div>
      </div>
    </section>

    <!-- App Info -->
    <section class="space-y-6">
      <p class="text-[10px] font-bold uppercase tracking-widest text-gray-400 ml-1">Thông báo phiên bản</p>
      <div class="bg-gray-50 rounded-2xl border border-gray-100 overflow-hidden text-xs font-bold">
        <div class="flex justify-between items-center px-6 py-4 border-b border-gray-100">
          <span class="text-gray-400 uppercase tracking-widest">Phiên bản</span>
          <span class="text-[#d92550] bg-[#d92550]/5 px-3 py-1 rounded-full">v2.5.0-Kero</span>
        </div>
      </div>
    </section>
  </div>

  <div class="shrink-0 px-8 py-6 border-t border-gray-50 flex gap-4 bg-white">
    <button onclick="resetSettings()" class="flex-1 py-3.5 rounded-lg border border-gray-200 text-sm font-bold text-gray-600 hover:bg-gray-50 transition-all">Mặc định</button>
    <button onclick="saveSettings()" class="flex-1 py-3.5 rounded-lg bg-[#d92550] text-white text-sm font-bold hover:bg-[#b21d41] transition-all shadow-lg shadow-[#d92550]/20">Lưu thay đổi</button>
  </div>
</aside>

<!-- Edit Profile Modal -->
<div id="editProfileModal" class="hidden fixed inset-0 z-[200] flex items-center justify-center p-4">
  <div class="absolute inset-0 bg-gray-900/40 backdrop-blur-sm" onclick="document.getElementById('editProfileModal').classList.add('hidden')"></div>
  <div class="relative bg-white rounded-3xl shadow-2xl w-full max-w-[560px] animate__animated animate__zoomIn animate__faster overflow-hidden">
    <div class="px-10 py-8 border-b border-gray-50 bg-gray-50/50 flex items-center justify-between">
      <h3 class="text-xl font-bold text-gray-700">Hồ sơ <span class="text-[#d92550] italic">Cá nhân</span></h3>
      <button onclick="document.getElementById('editProfileModal').classList.add('hidden')" class="w-10 h-10 flex items-center justify-center rounded-full bg-gray-100 text-gray-400 hover:text-gray-600 transition-all">
        <span class="material-symbols-outlined">close</span>
      </button>
    </div>
    
    <div class="p-10">
      <div class="flex flex-col items-center gap-6 mb-10">
        <div class="relative group">
          <img id="editAvatarPreview" class="w-24 h-24 rounded-2xl object-cover border-4 border-white shadow-lg group-hover:scale-105 transition-all" src="https://ui-avatars.com/api/?name=${user.fullName}&background=d92550&color=fff&bold=true" alt="Avatar">
          <label for="avatarUpload" class="absolute -bottom-2 -right-2 w-9 h-9 rounded-xl bg-[#d92550] text-white flex items-center justify-center cursor-pointer shadow-xl hover:scale-110 transition-all border-2 border-white">
            <span class="material-symbols-outlined text-[18px]">photo_camera</span>
          </label>
          <input id="avatarUpload" type="file" accept="image/*" class="hidden" onchange="previewAvatar(this)">
        </div>
        <p class="text-[10px] font-bold text-gray-400 uppercase tracking-widest">Cập nhật ảnh đại diện</p>
      </div>

      <div class="grid grid-cols-2 gap-8">
        <div class="space-y-1.5">
          <label class="text-[11px] font-bold text-gray-400 uppercase tracking-widest ml-1">Họ và tên</label>
          <input type="text" id="editFullName" value="${user.fullName != null ? user.fullName : 'Admin'}" class="w-full bg-gray-50 border border-gray-100 rounded-xl px-4 py-3 text-[#495057] focus:outline-none focus:border-[#d92550]/30 transition-all font-bold">
        </div>
        <div class="space-y-1.5">
          <label class="text-[11px] font-bold text-gray-400 uppercase tracking-widest ml-1">Mã nhân viên</label>
          <input type="text" value="ACC${user.accountId != null ? user.accountId : '001'}" readonly class="w-full bg-gray-100 border border-gray-100 rounded-xl px-4 py-3 text-gray-400 cursor-not-allowed text-[13px]">
        </div>
      </div>
    </div>

    <div class="px-10 py-8 border-t border-gray-50 bg-gray-50/50 flex gap-3 justify-end">
      <button onclick="document.getElementById('editProfileModal').classList.add('hidden')" class="px-6 py-3 rounded-lg border border-gray-200 text-[13px] font-bold text-gray-600 hover:bg-gray-100 transition-all">Hủy</button>
      <button onclick="saveProfileChanges()" class="px-6 py-3 rounded-lg bg-[#d92550] text-white text-[13px] font-bold hover:bg-[#b21d41] transition-all shadow-lg shadow-[#d92550]/20">Lưu thay đổi</button>
    </div>
  </div>
</div>

<script>
  // Theme & Layout Logic
  (function(){ 
    var t = localStorage.getItem('vsport_theme') || 'light'; 
    applyTheme(t); 
  })();

  function applyTheme(t) { 
    var d = t === 'dark'; 
    document.documentElement.classList.toggle('dark', d); 
    syncThemeBtns(t); 
  }

  function syncThemeBtns(t) { 
    ['light', 'dark', 'system'].forEach(function(k) { 
      var b = document.getElementById('theme' + k[0].toUpperCase() + k.slice(1)); 
      if(!b) return; 
      var on = k === t; 
      b.style.borderColor = on ? '#d92550' : ''; 
      b.style.backgroundColor = on ? '#fff5f6' : ''; 
    }); 
  }

  function setTheme(t) { 
    localStorage.setItem('vsport_theme', t); 
    applyTheme(t); 
  }

  function openSettings() { 
    var o = document.getElementById('settingsOverlay'), dr = document.getElementById('settingsDrawer'); 
    o.classList.remove('hidden'); 
    requestAnimationFrame(function() { 
      o.classList.add('opacity-100'); 
      o.classList.remove('opacity-0'); 
      dr.classList.remove('translate-x-full'); 
    }); 
  }

  function closeSettings() { 
    var o = document.getElementById('settingsOverlay'), dr = document.getElementById('settingsDrawer'); 
    o.classList.remove('opacity-100'); 
    o.classList.add('opacity-0'); 
    dr.classList.add('translate-x-full'); 
    setTimeout(function() { o.classList.add('hidden'); }, 300); 
  }

  function toggleSetting(k, btn) { 
    var on = btn.classList.contains('on'), kn = btn.querySelector('.knob'); 
    if(on) { 
      btn.classList.remove('on', 'bg-[#d92550]'); 
      btn.classList.add('bg-gray-200'); 
      kn.classList.remove('right-1'); 
      kn.classList.add('left-1'); 
    } else { 
      btn.classList.add('on', 'bg-[#d92550]'); 
      btn.classList.remove('bg-gray-200'); 
      kn.classList.add('right-1'); 
      kn.classList.remove('left-1'); 
    } 
  }

  function resetSettings() { setTheme('light'); }
  function saveSettings() { closeSettings(); showToast('Đã lưu cài đặt'); }

  function showToast(msg) {
    var t = document.createElement('div');
    t.className = 'fixed bottom-6 left-1/2 -translate-x-1/2 bg-gray-800 text-white px-6 py-3 rounded-full text-[13px] font-bold z-[9999] shadow-2xl flex items-center gap-3 animate__animated animate__fadeInUp animate__faster';
    t.innerHTML = '<span class="material-symbols-outlined text-[#3ac47d]">check_circle</span> ' + msg;
    document.body.appendChild(t);
    setTimeout(function() {
      t.classList.remove('animate__fadeInUp');
      t.classList.add('animate__fadeOutDown');
      setTimeout(function() { t.remove(); }, 500);
    }, 2500);
  }

  function saveProfileChanges() { document.getElementById('editProfileModal').classList.add('hidden'); showToast('Hồ sơ đã được cập nhật'); }
  function previewAvatar(input) {
    if(input.files && input.files[0]) {
      var r = new FileReader();
      r.onload = function(e) { document.getElementById('editAvatarPreview').src = e.target.result; };
      r.readAsDataURL(input.files[0]);
    }
  }

  document.addEventListener('DOMContentLoaded', function() {
    var cb = document.getElementById('closeSettingsBtn'), ov = document.getElementById('settingsOverlay');
    if (cb) cb.addEventListener('click', closeSettings);
    if (ov) ov.addEventListener('click', closeSettings);
  });
</script>