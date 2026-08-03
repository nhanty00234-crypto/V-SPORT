<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<header class="fixed top-0 left-0 right-0 lg:left-[248px] h-[60px] bg-white/90 backdrop-blur border-b border-rose-100 z-10 flex items-center px-4 gap-3">
  <!-- Mobile menu toggle -->
  <button id="sidebarToggle" class="lg:hidden w-9 h-9 rounded-lg bg-rose-50 flex items-center justify-center text-rose-600">
    <i class="ti ti-menu-2 text-[20px]"></i>
  </button>

  <div class="flex-1 min-w-0">
    <p class="text-sm font-bold text-rose-900 truncate">${param.pageTitle}</p>
    <p class="text-[11px] text-rose-400 truncate">${param.pageSubtitle}</p>
  </div>

  <!-- Flash messages -->
  <c:if test="${not empty sessionScope.flashSuccess}">
    <div class="text-xs px-3 py-2 rounded-xl bg-green-50 border border-green-100 text-green-700 font-medium max-w-xs truncate" id="hdr-flash">
      <i class="ti ti-circle-check text-[14px] align-[-1px] mr-1"></i>${sessionScope.flashSuccess}
    </div>
    <c:remove var="flashSuccess" scope="session"/>
  </c:if>
  <c:if test="${not empty sessionScope.flashError}">
    <div class="text-xs px-3 py-2 rounded-xl bg-red-50 border border-red-100 text-red-700 font-medium max-w-xs truncate" id="hdr-flash">
      <i class="ti ti-alert-circle text-[14px] align-[-1px] mr-1"></i>${sessionScope.flashError}
    </div>
    <c:remove var="flashError" scope="session"/>
  </c:if>

  <!-- Clock -->
  <div class="hidden sm:flex items-center gap-1.5 text-xs text-rose-400 font-medium shrink-0">
    <i class="ti ti-clock text-[15px]"></i>
    <span id="gd-clock"></span>
  </div>
</header>
<script>
(function(){
  function tick(){ var el=document.getElementById('gd-clock'); if(el) el.textContent=new Date().toLocaleTimeString('vi-VN',{hour:'2-digit',minute:'2-digit',second:'2-digit'}); }
  tick(); setInterval(tick,1000);
  var f=document.getElementById('hdr-flash');
  if(f) setTimeout(function(){ f.style.opacity='0'; f.style.transition='opacity .4s'; setTimeout(function(){ f.remove(); },400); },4000);
})();
</script>
