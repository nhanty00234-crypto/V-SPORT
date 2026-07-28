<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<header class="h-[64px] fixed top-0 right-0 left-0 lg:left-[248px] bg-white/90 backdrop-blur-lg border-b border-slate-200 z-20 flex items-center justify-between px-4 lg:px-6">
  <div class="flex items-center gap-3">
    <button id="mobileMenuBtn" class="lg:hidden p-2 rounded-lg hover:bg-slate-100 text-slate-700">
      <span class="material-symbols-outlined text-[20px]">menu</span>
    </button>
    <div>
      <h1 class="text-sm font-extrabold text-[#122d40] tracking-tight">${headerTitle}</h1>
      <p class="text-xs text-slate-500 font-medium flex items-center gap-1.5">
        <span class="material-symbols-outlined text-[13px] text-[#059669]">${headerIcon}</span>${headerSubtitle}
      </p>
    </div>
  </div>
  <div class="flex items-center gap-1.5">
    <div class="text-xs font-bold px-3 py-1 bg-emerald-50 text-emerald-800 border border-emerald-100 rounded-lg">
      Vai trò: Quản lý
    </div>
    <div class="w-px h-6 bg-slate-200 mx-1"></div>
    <jsp:include page="/manager/common/profile_dropdown.jsp" />
  </div>
</header>
