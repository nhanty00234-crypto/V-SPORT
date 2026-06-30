<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!-- Mobile sidebar overlay -->
<div id="sidebarOverlay" class="fixed inset-0 bg-black/40 z-20 hidden"></div>

<!-- Sidebar -->
<aside id="sidebar" class="w-[248px] h-screen fixed left-0 top-0 bg-white border-r border-zinc-200 z-30 flex flex-col transition-transform duration-300 -translate-x-full lg:translate-x-0">
  <div class="px-5 py-4 border-b border-zinc-100 flex items-center gap-3">
    <div class="w-9 h-9 rounded-xl bg-gradient-to-br from-blue-600 to-blue-800 flex items-center justify-center shrink-0 shadow-md shadow-blue-200">
      <span class="material-symbols-outlined text-white text-[18px]">sports_tennis</span>
    </div>
    <div>
      <p class="text-sm font-bold text-zinc-900 leading-tight tracking-tight">V-SPORT</p>
      <p class="text-[10px] text-zinc-400 font-medium uppercase tracking-wider">Manager Portal</p>
    </div>
  </div>
  
  <nav class="flex-1 overflow-y-auto px-3 py-4 flex flex-col gap-1">
    <c:set var="uri" value="${pageContext.request.requestURI}" />
    <p class="text-[10px] font-bold uppercase tracking-widest text-zinc-400 px-3 mb-1.5">Vận hành</p>
    <a href="${pageContext.request.contextPath}/admin/tong-quan" class="nav-link ${uri.contains('/admin/tong-quan') || uri.contains('/TongQuan.jsp') ? 'active' : ''}"><span class="material-symbols-outlined text-[19px]">space_dashboard</span>Tổng quan</a>
    <a href="${pageContext.request.contextPath}/admin/lich-dat-san" class="nav-link ${uri.contains('/admin/lich-dat-san') || uri.contains('/LichDatSan.jsp') ? 'active' : ''}"><span class="material-symbols-outlined text-[19px]">event</span>Lịch đặt sân</a>
    <a href="${pageContext.request.contextPath}/admin/kho-dich-vu" class="nav-link ${uri.contains('/admin/kho-dich-vu') || uri.contains('/KhoDichVu.jsp') ? 'active' : ''}"><span class="material-symbols-outlined text-[19px]">inventory_2</span>Kho & Dịch vụ</a>
    
    <p class="text-[10px] font-bold uppercase tracking-widest text-zinc-400 px-3 mt-5 mb-1.5">Quản lý</p>
    <a href="${pageContext.request.contextPath}/admin/chi-nhanh" class="nav-link ${uri.contains('/admin/chi-nhanh') || uri.contains('/QuanLyChiNhanh.jsp') ? 'active' : ''}"><span class="material-symbols-outlined text-[19px]" style="font-variation-settings:'FILL' 1">location_on</span>Cơ Sở</a>
    <a href="${pageContext.request.contextPath}/admin/nhan-su" class="nav-link ${uri.contains('/admin/nhan-su') || uri.contains('/NhanSu.jsp') ? 'active' : ''}"><span class="material-symbols-outlined text-[19px]">groups</span>Nhân sự</a>
    <a href="${pageContext.request.contextPath}/admin/hoa-don" class="nav-link ${uri.contains('/admin/hoa-don') || uri.contains('/HoaDon.jsp') ? 'active' : ''}"><span class="material-symbols-outlined text-[19px]">receipt_long</span>Hóa đơn</a>
    <a href="${pageContext.request.contextPath}/admin/bao-cao-pos" class="nav-link ${uri.contains('/admin/bao-cao-pos') || uri.contains('/BaoCaoPOS.jsp') ? 'active' : ''}"><span class="material-symbols-outlined text-[19px]">monitoring</span>Báo cáo POS</a>
    <a href="${pageContext.request.contextPath}/admin/khuyen-mai" class="nav-link ${uri.contains('/admin/khuyen-mai') || uri.contains('/KhuyenMai.jsp') ? 'active' : ''}"><span class="material-symbols-outlined text-[19px]">loyalty</span>Khuyến mãi</a>
  </nav>
  
  <div class="px-3 py-3 border-t border-zinc-100">
    <a href="${pageContext.request.contextPath}/logout" class="nav-link text-red-500 hover:bg-red-50 text-xs font-semibold"><span class="material-symbols-outlined text-[16px] text-red-500">logout</span>Đăng xuất</a>
  </div>
</aside>
<script>
(function() {
  function initSidebar() {
    var sidebar = document.getElementById('sidebar');
    var overlay = document.getElementById('sidebarOverlay');
    if (!sidebar || !overlay) return;
    new MutationObserver(function() {
      if (window.innerWidth < 1024) {
        overlay.classList.toggle('hidden', sidebar.classList.contains('-translate-x-full'));
      }
    }).observe(sidebar, { attributes: true, attributeFilter: ['class'] });
    overlay.addEventListener('click', function() { sidebar.classList.add('-translate-x-full'); });
    sidebar.querySelectorAll('a').forEach(function(a) {
      a.addEventListener('click', function() {
        if (window.innerWidth < 1024) sidebar.classList.add('-translate-x-full');
      });
    });
    window.addEventListener('resize', function() {
      if (window.innerWidth >= 1024) overlay.classList.add('hidden');
    });
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', initSidebar);
  else initSidebar();
})();
</script>
