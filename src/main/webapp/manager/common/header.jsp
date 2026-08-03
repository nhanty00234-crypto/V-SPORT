<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<header class="h-[64px] fixed top-0 right-0 left-0 lg:left-[248px] bg-white/90 backdrop-blur-lg border-b border-purple-100 z-20 flex items-center justify-between px-4 lg:px-6">
  <div class="flex items-center gap-3">
    <button id="mobileMenuBtn" class="lg:hidden p-2 rounded-lg hover:bg-purple-50 text-purple-600">
      <span class="material-symbols-outlined text-[20px]">menu</span>
    </button>
    <div>
      <h1 class="text-sm font-extrabold text-purple-950 tracking-tight">${headerTitle}</h1>
      <p class="text-xs text-purple-600 font-medium flex items-center gap-1.5">
        <span class="material-symbols-outlined text-[13px] text-purple-600">${headerIcon}</span>${headerSubtitle}
      </p>
    </div>
  </div>
  <div class="flex items-center gap-1.5">
    <!-- Notification bell -->
    <div class="relative" id="mgrNotifWrap">
      <button id="mgrNotifBtn" type="button"
              class="relative p-2 rounded-lg hover:bg-purple-50 text-purple-600 transition-colors"
              aria-label="Thông báo" aria-expanded="false">
        <span class="material-symbols-outlined text-[22px]">notifications</span>
        <span id="mgrNotifBadge"
              style="display:none;position:absolute;top:4px;right:4px;min-width:16px;height:16px;padding:0 4px;
                     border-radius:999px;background:#7c3aed;color:#fff;font-size:9.5px;font-weight:800;
                     line-height:16px;text-align:center;pointer-events:none;
                     box-shadow:0 0 0 2px #fff;white-space:nowrap;"></span>
      </button>
      <div id="mgrNotifDropdown"
           style="display:none;position:absolute;top:calc(100% + 8px);right:0;z-index:3000;width:340px;
                  max-width:min(340px,calc(100vw - 16px));background:#fff;border-radius:14px;
                  box-shadow:0 12px 40px rgba(7,26,47,.18),0 2px 8px rgba(7,26,47,.1);
                  border:1px solid #e9d5ff;flex-direction:column;overflow:hidden;
                  animation:mgrNotifIn .16s ease;">
        <div style="display:flex;align-items:center;justify-content:space-between;padding:12px 14px 8px;border-bottom:1px solid #f3e8ff;background:#fff;">
          <span style="font-size:13px;font-weight:800;color:#2e1065;">Thông báo</span>
          <button id="mgrNotifClear" type="button"
                  style="background:none;border:none;font-size:11.5px;font-weight:700;color:#7c3aed;cursor:pointer;padding:3px 7px;border-radius:5px;"
                  onmouseover="this.style.background='#f5f3ff'" onmouseout="this.style.background='none'">Đọc tất cả</button>
        </div>
        <ul id="mgrNotifList" style="list-style:none;margin:0;padding:0;max-height:340px;overflow-y:auto;">
          <li id="mgrNotifEmpty" style="padding:24px 14px;text-align:center;font-size:13px;color:#9ca3af;">Chưa có thông báo mới</li>
        </ul>
        <div style="padding:9px 14px;border-top:1px solid #f3e8ff;text-align:center;background:#faf5ff;">
          <a href="${pageContext.request.contextPath}/manager/dat-san"
             style="font-size:12px;font-weight:700;color:#7c3aed;text-decoration:none;">Xem tất cả →</a>
        </div>
      </div>
    </div>
    <div class="text-xs font-bold px-3 py-1 bg-purple-50 text-purple-800 border border-purple-200 rounded-lg">
      Vai trò: Quản lý
    </div>
    <div class="w-px h-6 bg-purple-100 mx-1"></div>
    <jsp:include page="/manager/common/profile_dropdown.jsp" />
  </div>
</header>

<style>
@keyframes mgrNotifIn{from{opacity:0;transform:translateY(-6px) scale(.97)}to{opacity:1;transform:none}}
.mgr-notif-item{display:flex;align-items:flex-start;gap:10px;padding:10px 14px;border-bottom:1px solid #f3e8ff;cursor:pointer;transition:background .12s;}
.mgr-notif-item:last-child{border-bottom:none;}
.mgr-notif-item:hover{background:#faf5ff;}
.mgr-notif-item.is-unread{background:#f5f3ff;position:relative;}
.mgr-notif-item.is-unread::before{content:'';position:absolute;left:0;top:0;bottom:0;width:3px;background:#7c3aed;border-radius:0 2px 2px 0;}
.mgr-notif-icon{width:34px;height:34px;flex-shrink:0;border-radius:50%;background:#f3e8ff;color:#7c3aed;display:inline-flex;align-items:center;justify-content:center;font-size:15px;}
.mgr-notif-body{min-width:0;flex:1;}
.mgr-notif-title{font-size:12.5px;font-weight:700;color:#1c1917;line-height:1.4;margin:0 0 2px;}
.mgr-notif-desc{font-size:11.5px;color:#6b7280;font-weight:500;margin:0 0 2px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
.mgr-notif-time{font-size:10.5px;color:#9ca3af;font-weight:600;}
</style>

<script>
(function(){
  var ctx = '${pageContext.request.contextPath}';
  var apiUrl = ctx + '/manager/api/notifications';
  var btn = document.getElementById('mgrNotifBtn');
  var wrap = document.getElementById('mgrNotifWrap');
  var dropdown = document.getElementById('mgrNotifDropdown');
  var badge = document.getElementById('mgrNotifBadge');
  var list = document.getElementById('mgrNotifList');
  var clearBtn = document.getElementById('mgrNotifClear');
  var isOpen = false;
  var lastUnread = -1;
  var items = [];

  function relTime(ms){
    if(!ms) return '';
    var d = Math.floor((Date.now()-ms)/1000);
    if(d<60) return 'Vừa xong';
    if(d<3600) return Math.floor(d/60)+' phút trước';
    if(d<86400) return Math.floor(d/3600)+' giờ trước';
    return Math.floor(d/86400)+' ngày trước';
  }
  function iconFor(loai){
    if(!loai) return '🔔';
    if(loai.indexOf('BOOKING')>=0) return '📅';
    if(loai.indexOf('OWNER')>=0) return '🏢';
    if(loai.indexOf('REFUND')>=0) return '↩';
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
      li.className='mgr-notif-item'+(n.daDoc?'':' is-unread');
      li.innerHTML='<div class="mgr-notif-icon">'+iconFor(n.loai)+'</div>'
        +'<div class="mgr-notif-body">'
        +'<p class="mgr-notif-title">'+escH(n.tieuDe)+'</p>'
        +(n.noiDung?'<p class="mgr-notif-desc">'+escH(n.noiDung)+'</p>':'')
        +'<span class="mgr-notif-time">'+relTime(n.thoiGian)+'</span>'
        +'</div>';
      li.addEventListener('click',function(){
        if(!n.daDoc){ n.daDoc=true;
          fetch(apiUrl,{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:'action=markRead&id='+n.id}).catch(function(){});
          renderList(); updateBadge();
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
      +'border:1px solid #e9d5ff;border-left:4px solid #7c3aed;border-radius:10px;'
      +'box-shadow:0 8px 24px rgba(0,0,0,.15);padding:12px 14px;cursor:pointer;'
      +'animation:mgrNotifIn .2s ease;';
    t.innerHTML='<div style="font-size:12px;font-weight:800;color:#2e1065;margin-bottom:3px;">'+escH(tieuDe)+'</div>'
      +(noiDung?'<div style="font-size:11.5px;color:#6b7280;">'+escH(noiDung)+'</div>':'');
    if(duongDan) t.addEventListener('click',function(){window.location.href=ctx+duongDan;});
    document.body.appendChild(t);
    setTimeout(function(){if(t.parentNode)t.parentNode.removeChild(t);},5000);
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
  function open(){isOpen=true;dropdown.style.display='flex';btn.setAttribute('aria-expanded','true');renderList();}
  function close(){isOpen=false;dropdown.style.display='none';btn.setAttribute('aria-expanded','false');}
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
