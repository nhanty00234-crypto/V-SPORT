<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<header class="h-[64px] fixed top-0 right-0 left-0 lg:left-[248px] bg-white/80 backdrop-blur-lg border-b border-purple-100 z-20 flex items-center justify-between px-4 lg:px-6">
  <div class="flex items-center gap-3">
    <button id="mobileMenuBtn" class="lg:hidden p-2 rounded-lg hover:bg-purple-50 text-purple-600">
      <span class="material-symbols-outlined text-[20px]">menu</span>
    </button>
    <div>
      <h1 class="text-sm font-bold text-purple-950 tracking-tight">${headerTitle}</h1>
      <p class="text-xs text-purple-500 flex items-center gap-1.5">
        <span class="material-symbols-outlined text-[12px]">${headerIcon}</span>${headerSubtitle}
      </p>
    </div>
  </div>
  <div class="flex items-center gap-1.5">
    <div class="text-xs font-semibold px-3 py-1 bg-purple-50 text-purple-700 rounded-lg">
      Vai trò: Quản lý
    </div>
    <div class="w-px h-6 bg-purple-100 mx-1"></div>
    <jsp:include page="/manager/common/profile_dropdown.jsp" />
  </div>
</header>
