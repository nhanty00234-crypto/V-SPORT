<%@ page contentType="text/html;charset=UTF-8" %>
<style>
  @keyframes _pulse-dot{0%,100%{box-shadow:0 0 0 0 rgba(34,197,94,.4);}50%{box-shadow:0 0 0 6px rgba(34,197,94,0);}}
  .live-dot{animation:_pulse-dot 1.6s ease-in-out infinite;}

  :root {
    --admin-control-bg:#f8fafc;
    --admin-control-bg-focus:#ffffff;
    --admin-control-border:#dbe3ef;
    --admin-control-text:#0f172a;
    --admin-control-muted:#64748b;
    --admin-control-ring:rgba(37,99,235,.11);
  }

  main input:not([type="hidden"]):not([type="checkbox"]):not([type="radio"]):not([type="file"]):not(.sr-only):not(.otp-box):not(.adm-otp):not(.audit-control),
  main select:not(.audit-control),
  main textarea:not(#messageInput):not(.audit-control),
  [id$="Modal"] input:not([type="hidden"]):not([type="checkbox"]):not([type="radio"]):not([type="file"]):not(.sr-only):not(.otp-box):not(.adm-otp):not(.audit-control),
  [id$="Modal"] select:not(.audit-control),
  [id$="Modal"] textarea:not(#messageInput):not(.audit-control),
  #profileDrop input:not([type="hidden"]):not([type="checkbox"]):not([type="radio"]):not([type="file"]):not(.sr-only),
  #profileDrop select,
  #profileDrop textarea {
    border-color:var(--admin-control-border) !important;
    border-radius:10px !important;
    background-color:var(--admin-control-bg) !important;
    color:var(--admin-control-text);
    box-shadow:inset 0 1px 0 rgba(255,255,255,.72);
    transition:border-color .16s ease, box-shadow .16s ease, background-color .16s ease, transform .12s ease;
  }

  main select:not(.audit-control),
  [id$="Modal"] select:not(.audit-control),
  #profileDrop select {
    appearance:none;
    -webkit-appearance:none;
    padding-right:2.25rem !important;
    background-image:
      linear-gradient(45deg, transparent 50%, #64748b 50%),
      linear-gradient(135deg, #64748b 50%, transparent 50%);
    background-position:
      calc(100% - 17px) 50%,
      calc(100% - 12px) 50%;
    background-size:5px 5px, 5px 5px;
    background-repeat:no-repeat;
  }

  main input:not([type="hidden"]):not([type="checkbox"]):not([type="radio"]):not([type="file"]):not(.sr-only):not(.otp-box):not(.adm-otp):not(.audit-control):focus,
  main select:not(.audit-control):focus,
  main textarea:not(#messageInput):not(.audit-control):focus,
  [id$="Modal"] input:not([type="hidden"]):not([type="checkbox"]):not([type="radio"]):not([type="file"]):not(.sr-only):not(.otp-box):not(.adm-otp):not(.audit-control):focus,
  [id$="Modal"] select:not(.audit-control):focus,
  [id$="Modal"] textarea:not(#messageInput):not(.audit-control):focus,
  #profileDrop input:not([type="hidden"]):not([type="checkbox"]):not([type="radio"]):not([type="file"]):not(.sr-only):focus,
  #profileDrop select:focus,
  #profileDrop textarea:focus {
    background-color:var(--admin-control-bg-focus) !important;
    border-color:#2563eb !important;
    box-shadow:0 0 0 3px var(--admin-control-ring), inset 0 1px 0 rgba(255,255,255,.85) !important;
    outline:none !important;
  }

  main input:not(.audit-control)::placeholder,
  main textarea:not(#messageInput):not(.audit-control)::placeholder,
  [id$="Modal"] input:not(.audit-control)::placeholder,
  [id$="Modal"] textarea:not(#messageInput):not(.audit-control)::placeholder,
  #profileDrop input::placeholder,
  #profileDrop textarea::placeholder {
    color:#94a3b8;
    font-weight:500;
  }

  main input[type="date"]:not(.audit-control),
  main input[type="time"],
  [id$="Modal"] input[type="date"],
  [id$="Modal"] input[type="time"] {
    color-scheme:light;
  }

  main button,
  main a[class*="bg-"],
  [id$="Modal"] button,
  #profileDrop button,
  #profileDrop a {
    transition:transform .12s ease, background-color .15s ease, border-color .15s ease, box-shadow .15s ease, opacity .15s ease;
  }

  main button:active:not([disabled]),
  main a[class*="bg-"]:active,
  [id$="Modal"] button:active:not([disabled]),
  #profileDrop button:active:not([disabled]),
  #profileDrop a:active {
    transform:scale(.98);
  }
</style>
<header class="h-[64px] fixed top-0 right-0 left-0 lg:left-[260px] bg-white/80 backdrop-blur-lg border-b border-zinc-200 z-20 flex items-center justify-between px-4 lg:px-6">
  <div class="flex items-center gap-3">
    <button id="mobileMenuBtn" class="lg:hidden p-2 rounded-lg hover:bg-zinc-100 text-zinc-500">
      <span class="material-symbols-outlined text-[20px]">menu</span>
    </button>
    <div>
      <h1 class="text-sm font-bold text-zinc-900 tracking-tight">${param.pageTitle}</h1>
      <p class="text-xs text-zinc-500 flex items-center gap-1.5">
        <span class="material-symbols-outlined text-[12px]">security</span>Quyền hạn Admin
      </p>
    </div>
  </div>
  <div class="flex items-center gap-2">
    <div class="hidden sm:flex items-center gap-1.5 px-3 py-1.5 bg-emerald-50 border border-emerald-100 rounded-xl">
      <span class="w-2 h-2 rounded-full bg-emerald-500 live-dot shrink-0"></span>
      <span class="text-xs font-semibold text-emerald-700">Hệ thống hoạt động</span>
    </div>
    <!-- Notification bell -->
    <div class="relative" id="adminNotifWrap">
      <button id="adminNotifBtn" type="button"
              class="relative p-2 rounded-lg hover:bg-zinc-100 text-zinc-600 transition-colors"
              aria-label="Thông báo" aria-expanded="false">
        <span class="material-symbols-outlined text-[22px]">notifications</span>
        <span id="adminNotifBadge"
              style="display:none;position:absolute;top:4px;right:4px;min-width:16px;height:16px;padding:0 4px;
                     border-radius:999px;background:#2563eb;color:#fff;font-size:9.5px;font-weight:800;
                     line-height:16px;text-align:center;pointer-events:none;
                     box-shadow:0 0 0 2px #fff;white-space:nowrap;"></span>
      </button>
      <div id="adminNotifDropdown" hidden
           style="position:absolute;top:calc(100% + 8px);right:0;z-index:3000;width:340px;
                  max-width:min(340px,calc(100vw - 16px));background:#fff;border-radius:14px;
                  box-shadow:0 12px 40px rgba(7,26,47,.18),0 2px 8px rgba(7,26,47,.1);
                  border:1px solid #dbeafe;display:flex;flex-direction:column;overflow:hidden;
                  animation:adminNotifIn .16s ease;">
        <div style="display:flex;align-items:center;justify-content:space-between;padding:12px 14px 8px;border-bottom:1px solid #eff6ff;background:#fff;">
          <span style="font-size:13px;font-weight:800;color:#1e3a5f;">Thông báo Admin</span>
          <button id="adminNotifClear" type="button"
                  style="background:none;border:none;font-size:11.5px;font-weight:700;color:#2563eb;cursor:pointer;padding:3px 7px;border-radius:5px;"
                  onmouseover="this.style.background='#eff6ff'" onmouseout="this.style.background='none'">Đọc tất cả</button>
        </div>
        <ul id="adminNotifList" style="list-style:none;margin:0;padding:0;max-height:340px;overflow-y:auto;">
          <li style="padding:24px 14px;text-align:center;font-size:13px;color:#9ca3af;">Chưa có thông báo mới</li>
        </ul>
        <div style="padding:9px 14px;border-top:1px solid #eff6ff;text-align:center;background:#f8faff;">
          <a href="${pageContext.request.contextPath}/admin/chi-nhanh?tab=pending"
             style="font-size:12px;font-weight:700;color:#2563eb;text-decoration:none;">Xem cơ sở chờ duyệt →</a>
        </div>
      </div>
    </div>
    <div class="w-px h-6 bg-zinc-200 mx-1"></div>
    <jsp:include page="/admin/common/profile_dropdown.jsp"/>
  </div>
</header>

<style>
@keyframes adminNotifIn{from{opacity:0;transform:translateY(-6px) scale(.97)}to{opacity:1;transform:none}}
.admin-notif-item{display:flex;align-items:flex-start;gap:10px;padding:10px 14px;border-bottom:1px solid #eff6ff;cursor:pointer;transition:background .12s;}
.admin-notif-item:last-child{border-bottom:none;}
.admin-notif-item:hover{background:#f8faff;}
.admin-notif-item.is-unread{background:#eff6ff;position:relative;}
.admin-notif-item.is-unread::before{content:'';position:absolute;left:0;top:0;bottom:0;width:3px;background:#2563eb;border-radius:0 2px 2px 0;}
.admin-notif-icon{width:34px;height:34px;flex-shrink:0;border-radius:50%;background:#dbeafe;color:#2563eb;display:inline-flex;align-items:center;justify-content:center;font-size:15px;}
.admin-notif-body{min-width:0;flex:1;}
.admin-notif-title{font-size:12.5px;font-weight:700;color:#1c1917;line-height:1.4;margin:0 0 2px;}
.admin-notif-desc{font-size:11.5px;color:#6b7280;font-weight:500;margin:0 0 2px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
.admin-notif-time{font-size:10.5px;color:#9ca3af;font-weight:600;}
</style>

<script>
(function(){
  var ctx='${pageContext.request.contextPath}';
  var apiUrl=ctx+'/admin/api/notifications';
  var btn=document.getElementById('adminNotifBtn');
  var wrap=document.getElementById('adminNotifWrap');
  var dropdown=document.getElementById('adminNotifDropdown');
  var badge=document.getElementById('adminNotifBadge');
  var list=document.getElementById('adminNotifList');
  var clearBtn=document.getElementById('adminNotifClear');
  var isOpen=false,lastUnread=-1,items=[];

  function relTime(ms){
    if(!ms) return '';
    var d=Math.floor((Date.now()-ms)/1000);
    if(d<60) return 'Vừa xong';
    if(d<3600) return Math.floor(d/60)+' phút trước';
    if(d<86400) return Math.floor(d/3600)+' giờ trước';
    return Math.floor(d/86400)+' ngày trước';
  }
  function iconFor(loai){
    if(!loai) return '🔔';
    if(loai.indexOf('OWNER')>=0) return '🏢';
    if(loai.indexOf('BOOKING')>=0) return '📅';
    return '🔔';
  }
  function renderList(){
    list.innerHTML='';
    if(!items.length){
      var li=document.createElement('li');
      li.style.cssText='padding:24px 14px;text-align:center;font-size:13px;color:#9ca3af;';
      li.textContent='Chưa có thông báo mới'; list.appendChild(li); return;
    }
    items.forEach(function(n){
      var li=document.createElement('li');
      li.className='admin-notif-item'+(n.daDoc?'':' is-unread');
      li.innerHTML='<div class="admin-notif-icon">'+iconFor(n.loai)+'</div>'
        +'<div class="admin-notif-body">'
        +'<p class="admin-notif-title">'+escH(n.tieuDe)+'</p>'
        +(n.noiDung?'<p class="admin-notif-desc">'+escH(n.noiDung)+'</p>':'')
        +'<span class="admin-notif-time">'+relTime(n.thoiGian)+'</span>'
        +'</div>';
      li.addEventListener('click',function(){
        if(!n.daDoc){n.daDoc=true;
          fetch(apiUrl,{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:'action=markRead&id='+n.id}).catch(function(){});
          renderList();updateBadge();
        }
        if(n.duongDan) window.location.href=ctx+n.duongDan;
      });
      list.appendChild(li);
    });
  }
  function updateBadge(){
    var u=items.filter(function(n){return !n.daDoc;}).length;
    if(u>0){badge.textContent=u>99?'99+':u;badge.style.display='inline-block';}
    else{badge.style.display='none';}
  }
  function showToast(tieuDe,noiDung,duongDan){
    var t=document.createElement('div');
    t.style.cssText='position:fixed;bottom:20px;right:20px;z-index:9999;max-width:320px;background:#fff;'
      +'border:1px solid #dbeafe;border-left:4px solid #2563eb;border-radius:10px;'
      +'box-shadow:0 8px 24px rgba(0,0,0,.15);padding:12px 14px;cursor:pointer;'
      +'animation:adminNotifIn .2s ease;';
    t.innerHTML='<div style="font-size:12px;font-weight:800;color:#1e3a5f;margin-bottom:3px;">'+escH(tieuDe)+'</div>'
      +(noiDung?'<div style="font-size:11.5px;color:#6b7280;">'+escH(noiDung)+'</div>':'');
    if(duongDan) t.addEventListener('click',function(){window.location.href=ctx+duongDan;});
    document.body.appendChild(t);
    setTimeout(function(){if(t.parentNode)t.parentNode.removeChild(t);},6000);
  }
  function fetchNotifications(){
    fetch(apiUrl+'?format=json&limit=8',{headers:{'Accept':'application/json'}})
      .then(function(r){return r.json();})
      .then(function(data){
        var newUnread=data.unread||0;
        if(lastUnread>=0&&newUnread>lastUnread&&data.items&&data.items.length){
          var n=data.items[0];
          if(n&&!n.daDoc) showToast(n.tieuDe,n.noiDung,n.duongDan);
        }
        lastUnread=newUnread;
        items=(data.items||[]).map(function(n){return{id:n.id,tieuDe:n.tieuDe,noiDung:n.noiDung,daDoc:n.daDoc,duongDan:n.duongDan,thoiGian:n.thoiGian,loai:n.loai};});
        updateBadge();
        if(isOpen) renderList();
      }).catch(function(){});
  }
  function open(){isOpen=true;dropdown.hidden=false;btn.setAttribute('aria-expanded','true');renderList();}
  function close(){isOpen=false;dropdown.hidden=true;btn.setAttribute('aria-expanded','false');}
  btn.addEventListener('click',function(e){e.stopPropagation();if(isOpen)close();else open();});
  document.addEventListener('click',function(e){if(isOpen&&wrap&&!wrap.contains(e.target))close();});
  document.addEventListener('keydown',function(e){if(e.key==='Escape'&&isOpen)close();});
  if(clearBtn){
    clearBtn.addEventListener('click',function(){
      fetch(apiUrl,{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:'action=markAllRead'})
        .then(function(){items.forEach(function(n){n.daDoc=true;});updateBadge();renderList();}).catch(function(){});
    });
  }
  function escH(s){return(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');}
  fetchNotifications();
  setInterval(fetchNotifications,30000);
})();
</script>
<jsp:include page="/admin/common/admin_toast.jsp"/>
