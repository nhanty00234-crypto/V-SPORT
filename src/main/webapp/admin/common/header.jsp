<%@ page contentType="text/html;charset=UTF-8" %>
<style>
  @keyframes _pulse-dot{0%,100%{box-shadow:0 0 0 0 rgba(34,197,94,.4);}50%{box-shadow:0 0 0 6px rgba(34,197,94,0);}}
  .live-dot{animation:_pulse-dot 1.6s ease-in-out infinite;}
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
    <div class="w-px h-6 bg-zinc-200 mx-1"></div>
    <jsp:include page="/admin/common/profile_dropdown.jsp"/>
  </div>
</header>
