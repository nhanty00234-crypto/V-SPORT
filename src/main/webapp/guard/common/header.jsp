<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<header class="fixed top-0 left-0 right-0 lg:left-[248px] h-[60px] bg-white/90 backdrop-blur border-b border-rose-100 z-10 flex items-center px-4 gap-3">
  <!-- Mobile menu toggle -->
  <button onclick="document.getElementById('gdSidebar').classList.toggle('-translate-x-full'); document.getElementById('gdSidebarOverlay').style.display='block';"
          class="lg:hidden w-9 h-9 rounded-lg bg-rose-50 flex items-center justify-center text-rose-600">
    <span class="material-symbols-outlined text-[20px]">menu</span>
  </button>

  <div class="flex-1 min-w-0">
    <p class="text-sm font-bold text-rose-900 truncate">${param.pageTitle}</p>
    <p class="text-[11px] text-rose-400 truncate">${param.pageSubtitle}</p>
  </div>

  <!-- Flash messages in header area -->
  <c:if test="${not empty sessionScope.flashSuccess}">
    <div class="flash-success text-xs px-3 py-2 max-w-xs truncate" id="hdr-flash">
      <span class="material-symbols-outlined text-[14px] align-[-2px]">check_circle</span>
      ${sessionScope.flashSuccess}
    </div>
    <c:remove var="flashSuccess" scope="session"/>
  </c:if>
  <c:if test="${not empty sessionScope.flashError}">
    <div class="flash-error text-xs px-3 py-2 max-w-xs truncate" id="hdr-flash">
      <span class="material-symbols-outlined text-[14px] align-[-2px]">error</span>
      ${sessionScope.flashError}
    </div>
    <c:remove var="flashError" scope="session"/>
  </c:if>

  <!-- Time display -->
  <div class="hidden sm:flex items-center gap-1.5 text-xs text-rose-400 font-medium">
    <span class="material-symbols-outlined text-[15px]">schedule</span>
    <span id="gd-clock"></span>
  </div>
</header>
<script>
(function(){
  function tick(){ document.getElementById('gd-clock').textContent = new Date().toLocaleTimeString('vi-VN',{hour:'2-digit',minute:'2-digit',second:'2-digit'}); }
  tick(); setInterval(tick,1000);
  // Auto-hide flash after 4s
  var f = document.getElementById('hdr-flash');
  if(f) setTimeout(function(){ f.style.opacity='0'; f.style.transition='opacity .4s'; setTimeout(function(){ f.remove(); },400); },4000);
})();
</script>
