<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="gdName" value="${sessionScope.user.fullName != null ? sessionScope.user.fullName : sessionScope.user.username}"/>
<c:set var="gdAvatar" value="https://ui-avatars.com/api/?name=${gdName}&background=e11d48&color=fff&bold=true"/>
<c:if test="${not empty sessionScope.user.avatarUrl}">
  <c:url value="${sessionScope.user.avatarUrl}" var="gdAvatar"/>
</c:if>

<style>
@keyframes gdDropIn{from{opacity:0;transform:translateY(-8px) scale(.97)}to{opacity:1;transform:none}}
</style>

<!-- Avatar button -->
<div class="relative" id="gdProfileWrap">
  <button id="gdProfileBtn" class="flex items-center gap-2.5 px-2 py-1.5 rounded-lg hover:bg-rose-50 transition-colors">
    <img src="${gdAvatar}" class="gd-avatar-img w-8 h-8 rounded-full object-cover ring-2 ring-white" alt="Avatar">
    <div class="hidden sm:block text-left">
      <p class="text-sm font-semibold text-zinc-900 leading-tight"><c:out value="${gdName}"/></p>
      <p class="text-[10px] text-zinc-500">Bảo vệ · CS<c:out value="${sessionScope.user.coSoId}"/></p>
    </div>
    <i class="ti ti-chevron-down text-[15px] text-zinc-400 hidden sm:block transition-transform duration-150" id="gdChevron"></i>
  </button>

  <!-- Dropdown -->
  <div id="gdProfileDrop" class="hidden absolute top-[calc(100%+8px)] right-0 w-[300px] bg-white rounded-2xl shadow-xl border border-zinc-200 z-50 overflow-hidden">
    <!-- Header -->
    <div class="px-5 py-4 border-b border-zinc-100 bg-gradient-to-br from-rose-50/60 to-transparent">
      <div class="flex items-start gap-3">
        <div class="relative shrink-0">
          <img class="gd-avatar-img w-12 h-12 rounded-full object-cover ring-2 ring-rose-200" src="${gdAvatar}" alt="Avatar">
          <span class="absolute bottom-0 right-0 w-3 h-3 rounded-full bg-emerald-400 border-2 border-white"></span>
        </div>
        <div class="flex-1 min-w-0">
          <p class="font-bold text-[14px] text-zinc-900 leading-tight"><c:out value="${gdName}"/></p>
          <div class="flex items-center gap-1.5 mt-1 flex-wrap">
            <span class="inline-flex items-center gap-1 text-[10px] font-bold text-rose-700 bg-rose-50 px-2 py-0.5 rounded-full">
              <i class="ti ti-shield-lock text-[10px]"></i>Bảo vệ
            </span>
            <span class="inline-flex items-center gap-1 text-[10px] font-medium text-emerald-600 bg-emerald-50 px-2 py-0.5 rounded-full">
              <span class="w-1.5 h-1.5 rounded-full bg-emerald-400 inline-block"></span>Online
            </span>
          </div>
          <p class="text-[11px] text-zinc-400 mt-1">ID: <span class="font-mono font-semibold text-zinc-600">ACC-<c:out value="${sessionScope.user.accountId}"/></span></p>
        </div>
      </div>
    </div>

    <!-- Info -->
    <div class="px-4 py-3 border-b border-zinc-100 flex flex-col gap-2">
      <div class="flex items-center gap-2.5">
        <i class="ti ti-mail text-[15px] text-zinc-400 w-4 shrink-0"></i>
        <p class="text-[12px] text-zinc-600 truncate"><c:out value="${sessionScope.user.email != null ? sessionScope.user.email : 'Chưa cập nhật'}"/></p>
      </div>
      <div class="flex items-center gap-2.5">
        <i class="ti ti-phone text-[15px] text-zinc-400 w-4 shrink-0"></i>
        <p class="text-[12px] text-zinc-600"><c:out value="${sessionScope.user.phoneNumber != null ? sessionScope.user.phoneNumber : 'Chưa cập nhật'}"/></p>
      </div>
      <div class="flex items-center gap-2.5">
        <i class="ti ti-building text-[15px] text-zinc-400 w-4 shrink-0"></i>
        <p class="text-[12px] text-zinc-600">Cơ sở CS<c:out value="${sessionScope.user.coSoId}"/></p>
      </div>
    </div>

    <!-- Actions -->
    <div class="p-2">
      <button onclick="document.getElementById('gdProfileDrop').classList.add('hidden');document.getElementById('gdEditModal').classList.remove('hidden');"
              class="flex items-center gap-3 px-3 py-2 rounded-xl hover:bg-rose-50 transition-colors text-left w-full">
        <i class="ti ti-user-edit text-[16px] text-rose-500"></i>
        <span class="text-[13px] font-medium text-zinc-700">Hồ sơ cá nhân</span>
      </button>
      <button onclick="document.getElementById('gdProfileDrop').classList.add('hidden');document.getElementById('gdChangePwModal').classList.remove('hidden');"
              class="flex items-center gap-3 px-3 py-2 rounded-xl hover:bg-rose-50 transition-colors text-left w-full">
        <i class="ti ti-lock-password text-[16px] text-rose-500"></i>
        <span class="text-[13px] font-medium text-zinc-700">Đổi mật khẩu</span>
      </button>
      <div class="border-t border-zinc-100 mt-1 pt-1">
        <a href="${pageContext.request.contextPath}/dangxuat"
           class="flex items-center gap-3 px-3 py-2 rounded-xl hover:bg-red-50 transition-colors">
          <i class="ti ti-logout text-[16px] text-red-500"></i>
          <span class="text-[13px] font-medium text-red-600">Đăng xuất</span>
        </a>
      </div>
    </div>
  </div>
</div>

<!-- Edit Profile Modal -->
<div id="gdEditModal" class="hidden fixed inset-0 z-[80] flex items-center justify-center p-4">
  <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" onclick="document.getElementById('gdEditModal').classList.add('hidden')"></div>
  <div class="relative bg-white rounded-2xl shadow-2xl w-full max-w-[480px] z-10 border border-zinc-200" style="animation:gdDropIn .2s ease">
    <div class="flex items-center justify-between px-6 py-4 border-b border-zinc-200">
      <div class="flex items-center gap-2"><i class="ti ti-user-edit text-[20px] text-rose-600"></i><h3 class="text-base font-bold text-zinc-900">Hồ sơ cá nhân</h3></div>
      <button onclick="document.getElementById('gdEditModal').classList.add('hidden')" class="w-8 h-8 rounded-full hover:bg-zinc-100 flex items-center justify-center"><i class="ti ti-x text-[17px] text-zinc-500"></i></button>
    </div>

    <!-- Avatar -->
    <div class="flex flex-col items-center gap-2 pt-5 pb-4 border-b border-zinc-100">
      <div class="relative">
        <img id="gdAvatarPreview" class="gd-avatar-img w-20 h-20 rounded-full object-cover ring-2 ring-rose-200" src="${gdAvatar}" alt="Avatar">
        <label for="gdAvatarInput" class="absolute bottom-0 right-0 w-7 h-7 rounded-full bg-rose-600 text-white flex items-center justify-center cursor-pointer shadow hover:bg-rose-700 transition">
          <i class="ti ti-camera text-[14px]"></i>
        </label>
        <input id="gdAvatarInput" type="file" accept="image/*" class="hidden" onchange="gdPreviewAvatar(this)">
      </div>
      <p class="text-xs text-zinc-400">Nhấn biểu tượng máy ảnh để thay ảnh · Tối đa 2MB</p>
      <p id="gdAvatarError" class="hidden text-xs text-red-600 bg-red-50 border border-red-100 rounded-lg px-3 py-1.5 text-center w-full max-w-xs"></p>
    </div>

    <!-- Fields -->
    <div class="px-6 py-5 flex flex-col gap-4">
      <div class="grid grid-cols-2 gap-4">
        <div class="col-span-2 sm:col-span-1">
          <label class="block text-xs font-semibold text-zinc-500 mb-1.5">Họ và tên</label>
          <input type="text" id="gdFullName" value="${sessionScope.user.fullName != null ? sessionScope.user.fullName : ''}"
                 class="w-full h-10 px-3 rounded-lg border border-zinc-200 text-sm text-zinc-800 focus:border-rose-500 focus:outline-none transition-colors">
        </div>
        <div class="col-span-2 sm:col-span-1">
          <label class="block text-xs font-semibold text-zinc-500 mb-1.5">Số điện thoại</label>
          <input type="tel" id="gdPhone" value="${sessionScope.user.phoneNumber != null ? sessionScope.user.phoneNumber : ''}"
                 class="w-full h-10 px-3 rounded-lg border border-zinc-200 text-sm text-zinc-800 focus:border-rose-500 focus:outline-none transition-colors">
        </div>
        <div class="col-span-2">
          <label class="block text-xs font-semibold text-zinc-500 mb-1.5 flex items-center gap-1">
            Email
            <span class="text-[10px] bg-zinc-100 text-zinc-500 px-1.5 py-0.5 rounded font-medium ml-1 flex items-center gap-1">
              <i class="ti ti-lock text-[10px]"></i>Chỉ manager được đổi
            </span>
          </label>
          <input type="email" value="${sessionScope.user.email != null ? sessionScope.user.email : ''}" readonly
                 class="w-full h-10 px-3 rounded-lg border border-zinc-100 bg-zinc-50 text-sm text-zinc-400 cursor-not-allowed focus:outline-none">
        </div>
      </div>
    </div>

    <div class="px-6 pb-5 flex gap-3 justify-end">
      <button onclick="document.getElementById('gdEditModal').classList.add('hidden')" class="h-10 px-5 rounded-lg border border-zinc-200 text-sm font-semibold text-zinc-600 hover:bg-zinc-50 transition-colors">Hủy</button>
      <button onclick="gdSaveProfile()" class="h-10 px-5 rounded-lg bg-rose-600 text-white text-sm font-semibold hover:bg-rose-700 transition-colors active:scale-95">Lưu thay đổi</button>
    </div>
  </div>
</div>

<!-- Change Password Modal -->
<div id="gdChangePwModal" class="hidden fixed inset-0 z-[80] flex items-center justify-center p-4">
  <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" onclick="document.getElementById('gdChangePwModal').classList.add('hidden')"></div>
  <div class="relative bg-white rounded-2xl shadow-2xl w-full max-w-[380px] z-10 border border-zinc-200" style="animation:gdDropIn .2s ease">
    <div class="flex items-center justify-between px-6 py-4 border-b border-zinc-200">
      <div class="flex items-center gap-2"><i class="ti ti-lock-password text-[20px] text-rose-600"></i><h3 class="text-base font-bold text-zinc-900">Đổi mật khẩu</h3></div>
      <button onclick="document.getElementById('gdChangePwModal').classList.add('hidden')" class="w-8 h-8 rounded-full hover:bg-zinc-100 flex items-center justify-center"><i class="ti ti-x text-[17px] text-zinc-500"></i></button>
    </div>
    <div class="px-6 py-5 flex flex-col gap-4">
      <div>
        <label class="block text-xs font-semibold text-zinc-500 mb-1.5">Mật khẩu hiện tại</label>
        <div class="relative">
          <input type="password" id="gdPwCurrent" placeholder="••••••••" autocomplete="new-password"
                 class="w-full h-10 px-3 pr-10 rounded-lg border border-zinc-200 text-sm focus:border-rose-500 focus:outline-none transition-colors">
          <button type="button" onclick="gdTogglePw('gdPwCurrent',this)" class="absolute right-3 top-1/2 -translate-y-1/2 text-zinc-400 hover:text-zinc-600">
            <i class="ti ti-eye-off text-[17px]"></i>
          </button>
        </div>
      </div>
      <div>
        <label class="block text-xs font-semibold text-zinc-500 mb-1.5">Mật khẩu mới</label>
        <div class="relative">
          <input type="password" id="gdPwNew" placeholder="••••••••" autocomplete="new-password" oninput="gdStrength(this)"
                 class="w-full h-10 px-3 pr-10 rounded-lg border border-zinc-200 text-sm focus:border-rose-500 focus:outline-none transition-colors">
          <button type="button" onclick="gdTogglePw('gdPwNew',this)" class="absolute right-3 top-1/2 -translate-y-1/2 text-zinc-400 hover:text-zinc-600">
            <i class="ti ti-eye-off text-[17px]"></i>
          </button>
        </div>
        <div class="flex gap-1 mt-2"><div class="h-1 flex-1 rounded-full bg-zinc-100" id="gds1"></div><div class="h-1 flex-1 rounded-full bg-zinc-100" id="gds2"></div><div class="h-1 flex-1 rounded-full bg-zinc-100" id="gds3"></div><div class="h-1 flex-1 rounded-full bg-zinc-100" id="gds4"></div></div>
        <p id="gdStrLbl" class="text-[11px] text-zinc-400 mt-1"></p>
      </div>
      <div>
        <label class="block text-xs font-semibold text-zinc-500 mb-1.5">Xác nhận mật khẩu mới</label>
        <div class="relative">
          <input type="password" id="gdPwConfirm" placeholder="••••••••" autocomplete="new-password"
                 class="w-full h-10 px-3 pr-10 rounded-lg border border-zinc-200 text-sm focus:border-rose-500 focus:outline-none transition-colors">
          <button type="button" onclick="gdTogglePw('gdPwConfirm',this)" class="absolute right-3 top-1/2 -translate-y-1/2 text-zinc-400 hover:text-zinc-600">
            <i class="ti ti-eye-off text-[17px]"></i>
          </button>
        </div>
      </div>
    </div>
    <div class="px-6 pb-5 flex gap-3 justify-end">
      <button onclick="document.getElementById('gdChangePwModal').classList.add('hidden')" class="h-10 px-5 rounded-lg border border-zinc-200 text-sm font-semibold text-zinc-600 hover:bg-zinc-50 transition-colors">Hủy</button>
      <button onclick="gdSavePassword()" class="h-10 px-5 rounded-lg bg-rose-600 text-white text-sm font-semibold hover:bg-rose-700 transition-colors active:scale-95">Đổi mật khẩu</button>
    </div>
  </div>
</div>

<!-- Toast -->
<div id="gdToast" class="fixed bottom-6 right-6 z-[100] flex items-center gap-3 px-4 py-3 bg-zinc-900 text-white rounded-xl shadow-xl transition-all duration-300 opacity-0 translate-y-12 pointer-events-none">
  <i class="ti ti-circle-check text-emerald-400 text-[20px]"></i>
  <div><p class="text-xs font-bold" id="gdToastTitle">Thành công</p><p class="text-[11px] text-zinc-300" id="gdToastMsg"></p></div>
</div>

<script>
(function(){
  /* ── Dropdown toggle ── */
  var btn = document.getElementById('gdProfileBtn');
  var drop = document.getElementById('gdProfileDrop');
  var chev = document.getElementById('gdChevron');
  function openDrop(){ drop.classList.remove('hidden'); drop.style.cssText='opacity:0;transform:translateY(-8px) scale(.97);transition:opacity .18s,transform .18s'; requestAnimationFrame(function(){ drop.style.opacity='1'; drop.style.transform='translateY(0) scale(1)'; }); if(chev) chev.style.transform='rotate(180deg)'; }
  function closeDrop(){ drop.style.opacity='0'; drop.style.transform='translateY(-8px) scale(.97)'; setTimeout(function(){ drop.classList.add('hidden'); drop.style.cssText=''; },180); if(chev) chev.style.transform=''; }
  btn.addEventListener('click', function(e){ e.stopPropagation(); drop.classList.contains('hidden') ? openDrop() : closeDrop(); });
  document.addEventListener('click', function(e){ if(!drop.classList.contains('hidden') && !btn.contains(e.target) && !drop.contains(e.target)) closeDrop(); });
  document.addEventListener('keydown', function(e){ if(e.key==='Escape') closeDrop(); });

  /* Move modals to body */
  document.addEventListener('DOMContentLoaded', function(){
    ['gdEditModal','gdChangePwModal','gdToast'].forEach(function(id){
      var el = document.getElementById(id);
      if(el && el.parentElement !== document.body) document.body.appendChild(el);
    });
  });
})();

function gdShowToast(title, msg, isErr){
  var t = document.getElementById('gdToast');
  var ic = t.querySelector('i');
  document.getElementById('gdToastTitle').textContent = title;
  document.getElementById('gdToastMsg').textContent = msg;
  if(isErr){ ic.className='ti ti-alert-circle text-red-400 text-[20px]'; }
  else { ic.className='ti ti-circle-check text-emerald-400 text-[20px]'; }
  t.classList.remove('opacity-0','translate-y-12','pointer-events-none');
  setTimeout(function(){ t.classList.add('opacity-0','translate-y-12','pointer-events-none'); },4000);
}

function gdPreviewAvatar(input){
  var err = document.getElementById('gdAvatarError');
  err.classList.add('hidden');
  var file = input.files && input.files[0];
  if(!file) return;
  if(file.size > 2*1024*1024){ err.textContent='Ảnh quá lớn (tối đa 2MB)'; err.classList.remove('hidden'); input.value=''; return; }
  if(!['image/jpeg','image/png','image/webp','image/gif'].includes(file.type)){ err.textContent='Chỉ hỗ trợ JPG, PNG, WEBP, GIF'; err.classList.remove('hidden'); input.value=''; return; }
  var r = new FileReader();
  r.onload = function(e){ document.getElementById('gdAvatarPreview').src = e.target.result; };
  r.readAsDataURL(file);
}

function gdSaveProfile(){
  var name = document.getElementById('gdFullName').value.trim();
  var phone = document.getElementById('gdPhone').value.trim();
  if(!name){ alert('Vui lòng nhập họ và tên!'); return; }

  var saveBtn = document.querySelector('[onclick="gdSaveProfile()"]');
  if(saveBtn){ saveBtn.disabled=true; saveBtn.textContent='Đang lưu...'; }

  var doSave = function(){
    var params = new URLSearchParams();
    params.append('action','updateInfo');
    params.append('fullName', name);
    params.append('phoneNumber', phone);
    /* Không gửi email — role GUARD không được đổi email */

    fetch('${pageContext.request.contextPath}/account/update-profile',{
      method:'POST',
      headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'},
      body: params
    }).then(function(r){ return r.json(); }).then(function(data){
      if(saveBtn){ saveBtn.disabled=false; saveBtn.textContent='Lưu thay đổi'; }
      if(data.success){
        /* sync UI */
        document.querySelectorAll('.gd-avatar-img').forEach(function(img){ if(data.avatarUrl) img.src = data.avatarUrl; });
        document.querySelectorAll('#gdProfileBtn p').forEach(function(el){ if(el.classList.contains('font-semibold')) el.textContent = data.fullName || name; });
        document.getElementById('gdEditModal').classList.add('hidden');
        gdShowToast('Thành công', data.message || 'Đã cập nhật hồ sơ');
      } else {
        gdShowToast('Lỗi', data.message || 'Cập nhật thất bại', true);
      }
    }).catch(function(){ if(saveBtn){ saveBtn.disabled=false; saveBtn.textContent='Lưu thay đổi'; } gdShowToast('Lỗi','Lỗi kết nối, vui lòng thử lại',true); });
  };

  var avatarFile = document.getElementById('gdAvatarInput').files[0];
  if(avatarFile){
    var fd = new FormData();
    fd.append('action','updateAvatar');
    fd.append('avatar', avatarFile);
    fetch('${pageContext.request.contextPath}/account/update-profile',{method:'POST',body:fd})
      .then(function(r){ return r.json(); }).then(function(data){
        if(data.success){ document.querySelectorAll('.gd-avatar-img').forEach(function(img){ img.src=data.avatarUrl; }); document.getElementById('gdAvatarInput').value=''; }
        doSave();
      }).catch(doSave);
  } else { doSave(); }
}

function gdSavePassword(){
  var cur = document.getElementById('gdPwCurrent').value;
  var nw  = document.getElementById('gdPwNew').value;
  var cf  = document.getElementById('gdPwConfirm').value;
  if(!cur){ alert('Vui lòng nhập mật khẩu hiện tại!'); return; }
  if(!nw){ alert('Vui lòng nhập mật khẩu mới!'); return; }
  if(nw !== cf){ document.getElementById('gdPwConfirm').style.borderColor='#ef4444'; setTimeout(function(){ document.getElementById('gdPwConfirm').style.borderColor=''; },1500); return; }

  var params = new URLSearchParams();
  params.append('action','changePassword');
  params.append('currentPassword', cur);
  params.append('newPassword', nw);

  fetch('${pageContext.request.contextPath}/account/update-profile',{
    method:'POST',
    headers:{'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'},
    body: params
  }).then(function(r){ return r.json(); }).then(function(data){
    if(data.success){
      document.getElementById('gdChangePwModal').classList.add('hidden');
      ['gdPwCurrent','gdPwNew','gdPwConfirm'].forEach(function(id){ document.getElementById(id).value=''; });
      [1,2,3,4].forEach(function(i){ var el=document.getElementById('gds'+i); if(el) el.style.backgroundColor=''; });
      document.getElementById('gdStrLbl').textContent='';
      gdShowToast('Thành công', data.message || 'Đã đổi mật khẩu');
    } else { gdShowToast('Lỗi', data.message || 'Đổi mật khẩu thất bại', true); }
  }).catch(function(){ gdShowToast('Lỗi','Lỗi kết nối, vui lòng thử lại',true); });
}

function gdTogglePw(id, btn){
  var inp = document.getElementById(id);
  var ic = btn.querySelector('i');
  if(inp.type==='password'){ inp.type='text'; ic.className='ti ti-eye text-[17px]'; }
  else { inp.type='password'; ic.className='ti ti-eye-off text-[17px]'; }
}

function gdStrength(inp){
  var v=inp.value, s=0;
  if(v.length>=8) s++; if(/[A-Z]/.test(v)) s++; if(/[0-9]/.test(v)) s++; if(/[^A-Za-z0-9]/.test(v)) s++;
  var cols=['#ef4444','#f59e0b','#e11d48','#10b981'];
  var labs=['','Yếu','Trung bình','Mạnh','Rất mạnh'];
  for(var i=1;i<=4;i++){ var el=document.getElementById('gds'+i); if(el) el.style.backgroundColor = i<=s ? cols[s-1] : ''; }
  var lbl=document.getElementById('gdStrLbl'); if(lbl) lbl.textContent = v.length ? labs[s] : '';
}
</script>
