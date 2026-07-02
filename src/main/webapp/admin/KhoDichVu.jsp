<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Kho & Dịch vụ — Cơ Sở</title>
<script src="https://cdn.tailwindcss.com"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200">
<style>
body { font-family: 'Inter', sans-serif; }
  .card { background:#fff;border:1px solid #e4e4e7;border-radius:16px; transition:box-shadow .2s, transform .2s; }
  .card-hover:hover { box-shadow:0 8px 24px -8px rgba(0,0,0,.08); transform:translateY(-2px); }
  .badge { display:inline-flex;align-items:center;padding:4px 10px;border-radius:8px;font-size:11px;font-weight:600; }
  .badge-green { background:#dcfce7;color:#15803d; }
  .badge-amber { background:#fef3c7;color:#b45309; }
  .badge-red { background:#fee2e2;color:#b91c1c; }
  .badge-blue { background:#dbeafe;color:#1e40af; }
  .badge-gray { background:#f4f4f5;color:#52525b; }
  .badge-purple { background:#f3e8ff;color:#7e22ce; }
  ::-webkit-scrollbar{width:6px;height:6px}::-webkit-scrollbar-track{background:transparent}::-webkit-scrollbar-thumb{background:#d4d4d8;border-radius:6px}
  ::-webkit-scrollbar-thumb:hover{background:#a1a1aa}
  @keyframes fadeUp { from { opacity:0; transform:translateY(10px); } to { opacity:1; transform:translateY(0); } }
  @keyframes pop { 0% { opacity:0; transform:scale(.94); } 100% { opacity:1; transform:scale(1); } }
  @keyframes pulse-dot { 0%,100%{box-shadow:0 0 0 0 rgba(34,197,94,.4);} 50%{box-shadow:0 0 0 6px rgba(34,197,94,0);} }
  @keyframes drawBar { from { transform: scaleY(0); } to { transform: scaleY(1); } }
  main > section { animation: fadeUp .4s ease both; }
  main > section:nth-child(1) { animation-delay: 0ms; }
  main > section:nth-child(2) { animation-delay: 80ms; }
  main > section:nth-child(3) { animation-delay: 160ms; }
  main > section:nth-child(4) { animation-delay: 240ms; }
  .stagger > *:nth-child(1){animation:pop .35s ease both;animation-delay:50ms}
  .stagger > *:nth-child(2){animation:pop .35s ease both;animation-delay:120ms}
  .stagger > *:nth-child(3){animation:pop .35s ease both;animation-delay:190ms}
  .stagger > *:nth-child(4){animation:pop .35s ease both;animation-delay:260ms}
  button { transition: transform .12s ease, opacity .15s ease, background-color .15s ease; }
  button:active:not([disabled]) { transform: scale(.97); }
  .live-dot { animation: pulse-dot 1.6s ease-in-out infinite; }
  .chart-bar { transform-origin: bottom; animation: drawBar .6s cubic-bezier(.34,1.56,.64,1) both; }
  .chart-bar:nth-child(1){animation-delay:50ms} .chart-bar:nth-child(2){animation-delay:120ms} .chart-bar:nth-child(3){animation-delay:190ms} .chart-bar:nth-child(4){animation-delay:260ms} .chart-bar:nth-child(5){animation-delay:330ms} .chart-bar:nth-child(6){animation-delay:400ms} .chart-bar:nth-child(7){animation-delay:470ms}
  aside a .material-symbols-outlined { transition: transform .2s ease; }
  aside a:hover .material-symbols-outlined { transform: translateX(2px); }
  .hero-gradient { background: linear-gradient(135deg, #fafafa 0%, #f4f4f5 60%, #eff6ff 100%); }
  @media (prefers-reduced-motion: reduce){ *,*::before,*::after{animation:none!important;transition:none!important;} }
  body.no-aos [data-aos] {
    opacity: 1 !important;
    transform: none !important;
    transition: none !important;
  }

  @keyframes contentZoomIn {
    from {
      opacity: 0;
      transform: scale(0.97);
    }
    to {
      opacity: 1;
      transform: scale(1);
    }
  }
  main {
    animation: contentZoomIn 0.35s cubic-bezier(0.34, 1.56, 0.64, 1) forwards;
    transform-origin: center top;
  }
</style>
  <link href="https://unpkg.com/aos@2.3.1/dist/aos.css" rel="stylesheet">
</head>
<body class="bg-zinc-50 text-zinc-900 min-h-screen">

<!-- Mobile sidebar overlay -->
<div id="sidebarOverlay" class="fixed inset-0 bg-black/40 z-20 hidden"></div>

<!-- Sidebar -->
<aside id="sidebar" class="w-[248px] h-screen fixed left-0 top-0 bg-white border-r border-zinc-200 z-30 flex flex-col transition-transform duration-300 -translate-x-full lg:translate-x-0">
  <div class="px-5 py-4 border-b border-zinc-100 flex items-center gap-3">
    <div class="w-9 h-9 rounded-xl bg-gradient-to-br from-blue-600 to-blue-800 flex items-center justify-center shrink-0 shadow-md shadow-blue-200">
      <span class="material-symbols-outlined text-white text-[18px]" >sports_tennis</span>
    </div>
    <div>
      <p class="text-sm font-bold text-zinc-900 leading-tight tracking-tight">V-SPORT</p>
      <p class="text-[10px] text-zinc-400 font-medium uppercase tracking-wider">Manager Portal</p>
    </div>
  </div>
  <div class="px-4 py-3 border-b border-zinc-100">
    <div class="flex items-center gap-2.5 px-3 py-2.5 bg-gradient-to-br from-blue-50 to-zinc-50 rounded-xl border border-blue-100/50">
      <div class="w-7 h-7 rounded-lg bg-white flex items-center justify-center border border-zinc-200">
        <span class="material-symbols-outlined text-[14px] text-blue-700">storefront</span>
      </div>
      <div class="min-w-0 flex-1">
        <p class="text-[11px] font-bold text-zinc-800 truncate">V-Sport Vũng Tàu</p>
        <p class="text-[10px] text-zinc-500 truncate">CS01 · Đang hoạt động</p>
      </div>
      <span class="w-2 h-2 rounded-full bg-green-500 shrink-0 live-dot"></span>
    </div>
  </div>
  <nav class="flex-1 overflow-y-auto px-3 py-4 flex flex-col gap-1">
    <p class="text-[10px] font-bold uppercase tracking-widest text-zinc-400 px-3 mb-1.5">Vận hành</p>
    <a href="${pageContext.request.contextPath}/admin/tong-quan" class="nav-link"><span class="material-symbols-outlined text-[19px]">space_dashboard</span>Tổng quan</a>
    <a href="${pageContext.request.contextPath}/admin/lich-dat-san" class="nav-link"><span class="material-symbols-outlined text-[19px]">event</span>Lịch đặt sân<span class="ml-auto text-[10px] font-bold bg-blue-100 text-blue-700 px-1.5 py-0.5 rounded-md">5</span></a>
    <a href="${pageContext.request.contextPath}/admin/quan-ly-san" class="nav-link"><span class="material-symbols-outlined text-[19px]">stadium</span>Quản lý sân</a>
    <a href="${pageContext.request.contextPath}/admin/kho-dich-vu" class="nav-link active"><span class="material-symbols-outlined text-[19px]" style="font-variation-settings:'FILL' 1">inventory_2</span>Kho & Dịch vụ<span class="ml-auto text-[10px] font-bold bg-amber-100 text-amber-700 px-1.5 py-0.5 rounded-md">3</span></a>
    <p class="text-[10px] font-bold uppercase tracking-widest text-zinc-400 px-3 mt-5 mb-1.5">Quản lý</p>
    <a href="${pageContext.request.contextPath}/admin/chi-nhanh" class="nav-link"><span class="material-symbols-outlined text-[19px]">location_on</span>Cơ Sở</a>
    <a href="${pageContext.request.contextPath}/admin/nhan-su" class="nav-link"><span class="material-symbols-outlined text-[19px]">groups</span>Nhân sự</a>
    <a href="${pageContext.request.contextPath}/admin/hoa-don" class="nav-link"><span class="material-symbols-outlined text-[19px]">receipt_long</span>Hóa đơn</a>
    <a href="${pageContext.request.contextPath}/admin/khuyen-mai" class="nav-link"><span class="material-symbols-outlined text-[19px]">loyalty</span>Khuyến mãi</a>
    <p class="text-[10px] font-bold uppercase tracking-widest text-zinc-400 px-3 mt-5 mb-1.5">Hỗ trợ</p>
    <a href="#" class="nav-link"><span class="material-symbols-outlined text-[19px]">contact_support</span>Hỗ trợ Admin</a>
  </nav>
  <div class="px-3 py-3 border-t border-zinc-100">
    <a href="${pageContext.request.contextPath}/admin/tong-quan" class="nav-link text-zinc-400 text-xs"><span class="material-symbols-outlined text-[16px]">arrow_back_ios</span>Về Admin Portal</a>
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

<!-- Header -->
<header class="h-[64px] fixed top-0 right-0 left-0 lg:left-[260px] bg-white/80 backdrop-blur-lg border-b border-zinc-200 z-20 flex items-center justify-between px-4 lg:px-6">
  <div class="flex items-center gap-3">
    <button id="mobileMenuBtn" class="lg:hidden p-2 rounded-lg hover:bg-zinc-100 text-zinc-500"><span class="material-symbols-outlined text-[20px]">menu</span></button>
    <div>
      <h1 class="text-sm font-bold text-zinc-900 tracking-tight">Kho hàng & Dịch vụ</h1>
      <p class="text-xs text-zinc-500 flex items-center gap-1.5"><span class="material-symbols-outlined text-[12px]">database</span>Bảng SanPham_DichVu  DanhMucSanPham</p>
    </div>
  </div>
  <div class="flex items-center gap-1.5">
    <button onclick="location.href='HoTro.html'" class="hidden sm:flex items-center gap-1.5 h-9 px-3 rounded-lg border border-zinc-200 hover:bg-zinc-50 text-zinc-600 text-xs font-medium">
      <span class="material-symbols-outlined text-[15px]">help</span>Hỗ trợ
    </button>
    <button class="relative p-2 rounded-lg hover:bg-zinc-100 text-zinc-500">
      <span class="material-symbols-outlined text-[20px]">notifications</span>
      <span class="absolute top-1.5 right-1.5 w-2 h-2 rounded-full bg-red-500 live-dot"></span>
    </button>
    <div class="w-px h-6 bg-zinc-200 mx-1"></div>
    <jsp:include page="/admin/common/profile_dropdown.jsp" />
  </div>
</header>

<!-- Main -->
<main class="lg:ml-[260px] mt-[64px] p-4 lg:p-6 flex flex-col gap-5">

  <!-- Alert: sắp hết hàng -->
  <div id="lowStockBanner" class="hidden flex items-center gap-3 px-4 py-3 bg-amber-50 border border-amber-200 rounded-xl text-sm text-amber-800">
    <span class="material-symbols-outlined text-[18px] text-amber-600 shrink-0">warning</span>
    <p><span class="font-semibold">3 sản phẩm</span> sắp hết hàng (tồn kho &lt; 10). <button class="underline font-medium ml-1">Xem ngay</button></p>
  </div>

  <!-- Stats -->
  <div class="grid grid-cols-2 sm:grid-cols-4 gap-3">
    <div data-aos="fade-up" class="card p-4 flex items-center gap-3">
      <div class="w-9 h-9 rounded-lg bg-zinc-100 flex items-center justify-center"><span class="material-symbols-outlined text-[18px] text-zinc-600">inventory_2</span></div>
      <div><p class="text-xs text-zinc-500">Tổng SKU</p><p class="text-xl font-bold text-zinc-900">47</p></div>
    </div>
    <div data-aos="fade-up" class="card p-4 flex items-center gap-3">
      <div class="w-9 h-9 rounded-lg bg-green-50 flex items-center justify-center"><span class="material-symbols-outlined text-[18px] text-green-600">check_circle</span></div>
      <div><p class="text-xs text-zinc-500">Còn hàng</p><p class="text-xl font-bold text-green-600">41</p></div>
    </div>
    <div data-aos="fade-up" class="card p-4 flex items-center gap-3">
      <div class="w-9 h-9 rounded-lg bg-amber-50 flex items-center justify-center"><span class="material-symbols-outlined text-[18px] text-amber-600">production_quantity_limits</span></div>
      <div><p class="text-xs text-zinc-500">Sắp hết</p><p class="text-xl font-bold text-amber-600">3</p></div>
    </div>
    <div data-aos="fade-up" class="card p-4 flex items-center gap-3">
      <div class="w-9 h-9 rounded-lg bg-red-50 flex items-center justify-center"><span class="material-symbols-outlined text-[18px] text-red-500">remove_shopping_cart</span></div>
      <div><p class="text-xs text-zinc-500">Hết hàng</p><p class="text-xl font-bold text-red-500">3</p></div>
    </div>
  </div>

  <!-- Toolbar -->
  <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3">
    <div class="flex items-center gap-2 flex-wrap">
      <div class="relative">
        <span class="absolute left-3 top-1/2 -translate-y-1/2 material-symbols-outlined text-[16px] text-zinc-400">search</span>
        <input type="search" id="searchQuery" autocomplete="off" placeholder="Tìm sản phẩm..." class="h-9 pl-8 pr-3 rounded-lg border border-zinc-200 bg-white text-sm focus:outline-none focus:ring-2 focus:ring-zinc-400 w-[200px]">
      </div>
      <select id="filterCategory" class="h-9 px-3 rounded-lg border border-zinc-200 bg-white text-sm text-zinc-700 focus:outline-none focus:ring-2 focus:ring-zinc-400">
        <option value="">Tất cả danh mục</option>
        <option value="1">Thực phẩm & Đồ uống</option>
        <option value="2">Dụng cụ thể thao</option>
        <option value="3">Cho thuê thiết bị</option>
        <option value="4">Dịch vụ phụ trợ</option>
      </select>
      <select id="filterBranch" class="h-9 px-3 rounded-lg border border-zinc-200 bg-white text-sm text-zinc-700 focus:outline-none focus:ring-2 focus:ring-zinc-400">
        <option value="">Tất cả Cơ Sở</option>
        <option value="1">V-Sport Vũng Tàu</option>
        <option value="2">V-Sport Bà Rịa</option>
      </select>
      <select id="filterStatus" class="h-9 px-3 rounded-lg border border-zinc-200 bg-white text-sm text-zinc-700 focus:outline-none focus:ring-2 focus:ring-zinc-400">
        <option value="">Tất cả trạng thái</option>
        <option value="Còn hàng">Còn hàng</option>
        <option value="Sắp hết">Sắp hết</option>
        <option value="Hết hàng">Hết hàng</option>
        <option value="Ngừng kinh doanh">Ngừng kinh doanh</option>
      </select>
    </div>
    <button onclick="openAddProductModal()" class="flex items-center gap-1.5 h-9 px-4 rounded-lg bg-zinc-900 text-white text-sm font-medium hover:bg-zinc-800 transition-colors shrink-0">
      <span class="material-symbols-outlined text-[16px]">add</span>Thêm sản phẩm
    </button>
  </div>

  <!-- Category tabs -->
  <div class="flex items-center gap-1 overflow-x-auto pb-1" id="catTabs">
    <button onclick="setTab(this,'all')" class="tab-btn flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-sm font-medium whitespace-nowrap bg-zinc-900 text-white">Tất cả <span class="text-xs opacity-70">(47)</span></button>
    <button onclick="setTab(this,'food')" class="tab-btn flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-sm font-medium whitespace-nowrap text-zinc-500 hover:bg-zinc-100">Đồ ăn & Nước <span class="text-xs opacity-70">(18)</span></button>
    <button onclick="setTab(this,'sport')" class="tab-btn flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-sm font-medium whitespace-nowrap text-zinc-500 hover:bg-zinc-100">Dụng cụ thể thao <span class="text-xs opacity-70">(15)</span></button>
    <button onclick="setTab(this,'rent')" class="tab-btn flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-sm font-medium whitespace-nowrap text-zinc-500 hover:bg-zinc-100">Cho thuê <span class="text-xs opacity-70">(9)</span></button>
    <button onclick="setTab(this,'svc')" class="tab-btn flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-sm font-medium whitespace-nowrap text-zinc-500 hover:bg-zinc-100">Dịch vụ phụ trợ <span class="text-xs opacity-70">(5)</span></button>
  </div>

  <!-- View toggle -->
  <div class="flex items-center justify-between">
    <p class="text-xs text-zinc-500">Hiển thị <span class="font-semibold text-zinc-700">6 / 47</span> sản phẩm</p>
    <div class="flex rounded-lg border border-zinc-200 overflow-hidden bg-white">
      <button id="viewGridBtn" onclick="setProductView('grid')" class="px-3 py-1.5 text-sm flex items-center gap-1.5 bg-zinc-900 text-white">
        <span class="material-symbols-outlined text-[15px]">grid_view</span>Lưới
      </button>
      <button id="viewTableBtn" onclick="setProductView('table')" class="px-3 py-1.5 text-sm flex items-center gap-1.5 text-zinc-500 hover:bg-zinc-50">
        <span class="material-symbols-outlined text-[15px]">view_list</span>Bảng
      </button>
    </div>
  </div>

  <!-- Product GRID (default) -->
  <div id="productGrid" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">

    <!-- SP001: Aquafina (còn hàng) -->
    <div data-aos="fade-up" class="group relative card overflow-hidden hover:shadow-xl hover:-translate-y-0.5 transition-all duration-200">
      <div class="absolute top-2 left-2 z-10 flex items-center gap-1.5">
        <span class="text-[10px] font-bold bg-white/95 backdrop-blur px-2 py-0.5 rounded-md text-zinc-700 shadow-sm">SP001</span>
      </div>
      <div class="absolute top-2 right-2 z-10"><span class="badge badge-green shadow-sm">Còn hàng</span></div>
      <div class="relative h-44 bg-gradient-to-br from-blue-50 to-cyan-100 overflow-hidden">
        <img src="https://images.unsplash.com/photo-1564725073220-fa50fdc6b772?w=400&h=400&fit=crop" alt="Aquafina" class="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500" onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
        <div class="hidden absolute inset-0 items-center justify-center"><span class="material-symbols-outlined text-[60px] text-blue-300">local_drink</span></div>
      </div>
      <div class="p-3.5">
        <p class="text-[10px] font-semibold text-zinc-400 uppercase tracking-wider mb-0.5">Đồ uống</p>
        <h3 class="text-sm font-semibold text-zinc-900 truncate mb-2">Nước suối Aquafina 500ml</h3>
        <div class="flex items-end justify-between mb-3">
          <div>
            <p class="text-base font-bold text-zinc-900">10.000<span class="text-xs font-normal text-zinc-500"> đ</span></p>
            <p class="text-[10px] text-zinc-400">/chai</p>
          </div>
          <div class="text-right">
            <p class="text-[10px] text-zinc-400">Tồn kho</p>
            <p class="text-sm font-bold text-green-600">48 <span class="text-[10px] text-zinc-400 font-normal">/ ≥20</span></p>
          </div>
        </div>
        <div class="w-full h-1.5 bg-zinc-100 rounded-full overflow-hidden mb-3">
          <div class="h-full bg-gradient-to-r from-green-400 to-emerald-500 rounded-full" style="width:96%"></div>
        </div>
        <div class="flex items-center gap-1.5">
          <button onclick="openRestockModal('SP001')" class="flex-1 h-8 rounded-lg bg-zinc-900 text-white text-xs font-medium hover:bg-zinc-800 flex items-center justify-center gap-1 transition-colors"><span class="material-symbols-outlined text-[14px]">add_box</span>Nhập</button>
          <button class="h-8 w-8 rounded-lg border border-zinc-200 text-zinc-500 hover:bg-zinc-50 flex items-center justify-center"><span class="material-symbols-outlined text-[14px]">edit</span></button>
          <button class="h-8 w-8 rounded-lg border border-zinc-200 text-red-400 hover:bg-zinc-100 flex items-center justify-center"><span class="material-symbols-outlined text-[14px]">delete</span></button>
        </div>
      </div>
    </div>

    <!-- SP002: Redbull (sắp hết) -->
    <div data-aos="fade-up" class="group relative card overflow-hidden hover:shadow-xl hover:-translate-y-0.5 transition-all duration-200 ring-2 ring-amber-200">
      <div class="absolute top-2 left-2 z-10">
        <span class="text-[10px] font-bold bg-white/95 backdrop-blur px-2 py-0.5 rounded-md text-zinc-700 shadow-sm">SP002</span>
      </div>
      <div class="absolute top-2 right-2 z-10"><span class="badge badge-amber shadow-sm animate-pulse">⚠ Sắp hết</span></div>
      <div class="relative h-44 bg-gradient-to-br from-red-50 to-orange-100 overflow-hidden">
        <img src="https://images.unsplash.com/photo-1622543925917-763c34d1a86e?w=400&h=400&fit=crop" alt="Redbull" class="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500" onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
        <div class="hidden absolute inset-0 items-center justify-center"><span class="material-symbols-outlined text-[60px] text-red-300">bolt</span></div>
      </div>
      <div class="p-3.5">
        <p class="text-[10px] font-semibold text-zinc-400 uppercase tracking-wider mb-0.5">Đồ uống</p>
        <h3 class="text-sm font-semibold text-zinc-900 truncate mb-2">Nước tăng lực Redbull</h3>
        <div class="flex items-end justify-between mb-3">
          <div>
            <p class="text-base font-bold text-zinc-900">25.000<span class="text-xs font-normal text-zinc-500"> đ</span></p>
            <p class="text-[10px] text-zinc-400">/lon</p>
          </div>
          <div class="text-right">
            <p class="text-[10px] text-zinc-400">Tồn kho</p>
            <p class="text-sm font-bold text-amber-600">8 <span class="text-[10px] text-zinc-400 font-normal">/ ≥15</span></p>
          </div>
        </div>
        <div class="w-full h-1.5 bg-zinc-100 rounded-full overflow-hidden mb-3">
          <div class="h-full bg-gradient-to-r from-amber-400 to-orange-500 rounded-full" style="width:32%"></div>
        </div>
        <div class="flex items-center gap-1.5">
          <button onclick="openRestockModal('SP002')" class="flex-1 h-8 rounded-lg bg-zinc-800 text-white text-xs font-medium hover:bg-zinc-800 flex items-center justify-center gap-1 transition-colors"><span class="material-symbols-outlined text-[14px]">add_box</span>Nhập gấp</button>
          <button class="h-8 w-8 rounded-lg border border-zinc-200 text-zinc-500 hover:bg-zinc-50 flex items-center justify-center"><span class="material-symbols-outlined text-[14px]">edit</span></button>
          <button class="h-8 w-8 rounded-lg border border-zinc-200 text-red-400 hover:bg-zinc-100 flex items-center justify-center"><span class="material-symbols-outlined text-[14px]">delete</span></button>
        </div>
      </div>
    </div>

    <!-- SP010: Vợt cầu lông Yonex -->
    <div data-aos="fade-up" class="group relative card overflow-hidden hover:shadow-xl hover:-translate-y-0.5 transition-all duration-200">
      <div class="absolute top-2 left-2 z-10">
        <span class="text-[10px] font-bold bg-white/95 backdrop-blur px-2 py-0.5 rounded-md text-zinc-700 shadow-sm">SP010</span>
      </div>
      <div class="absolute top-2 right-2 z-10 flex flex-col gap-1 items-end">
        <span class="badge badge-green shadow-sm">Còn hàng</span>
        <span class="text-[9px] font-semibold bg-purple-500 text-white px-2 py-0.5 rounded-md shadow-sm">CHO THUÊ</span>
      </div>
      <div class="relative h-44 bg-gradient-to-br from-purple-50 to-pink-100 overflow-hidden">
        <img src="https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=400&h=400&fit=crop" alt="Vợt cầu lông" class="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500" onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
        <div class="hidden absolute inset-0 items-center justify-center"><span class="material-symbols-outlined text-[60px] text-purple-300">sports_tennis</span></div>
      </div>
      <div class="p-3.5">
        <p class="text-[10px] font-semibold text-zinc-400 uppercase tracking-wider mb-0.5">Cho thuê thiết bị</p>
        <h3 class="text-sm font-semibold text-zinc-900 truncate mb-2">Vợt cầu lông Yonex</h3>
        <div class="flex items-end justify-between mb-3">
          <div>
            <p class="text-base font-bold text-zinc-900">20.000<span class="text-xs font-normal text-zinc-500"> đ</span></p>
            <p class="text-[10px] text-zinc-400">/lần thuê</p>
          </div>
          <div class="text-right">
            <p class="text-[10px] text-zinc-400">Sẵn có</p>
            <p class="text-sm font-bold text-green-600">12 <span class="text-[10px] text-zinc-400 font-normal">/ ≥5</span></p>
          </div>
        </div>
        <div class="w-full h-1.5 bg-zinc-100 rounded-full overflow-hidden mb-3">
          <div class="h-full bg-gradient-to-r from-green-400 to-emerald-500 rounded-full" style="width:100%"></div>
        </div>
        <div class="flex items-center gap-1.5">
          <button class="flex-1 h-8 rounded-lg bg-zinc-900 text-white text-xs font-medium hover:bg-zinc-800 flex items-center justify-center gap-1 transition-colors"><span class="material-symbols-outlined text-[14px]">add_box</span>Nhập</button>
          <button class="h-8 w-8 rounded-lg border border-zinc-200 text-zinc-500 hover:bg-zinc-50 flex items-center justify-center"><span class="material-symbols-outlined text-[14px]">edit</span></button>
          <button class="h-8 w-8 rounded-lg border border-zinc-200 text-red-400 hover:bg-zinc-100 flex items-center justify-center"><span class="material-symbols-outlined text-[14px]">delete</span></button>
        </div>
      </div>
    </div>

    <!-- SP015: Quả cầu lông -->
    <div data-aos="fade-up" class="group relative card overflow-hidden hover:shadow-xl hover:-translate-y-0.5 transition-all duration-200 ring-2 ring-amber-200">
      <div class="absolute top-2 left-2 z-10">
        <span class="text-[10px] font-bold bg-white/95 backdrop-blur px-2 py-0.5 rounded-md text-zinc-700 shadow-sm">SP015</span>
      </div>
      <div class="absolute top-2 right-2 z-10"><span class="badge badge-amber shadow-sm animate-pulse">⚠ Sắp hết</span></div>
      <div class="relative h-44 bg-gradient-to-br from-yellow-50 to-amber-100 overflow-hidden">
        <img src="https://images.unsplash.com/photo-1593787406536-3676a72d23a8?w=400&h=400&fit=crop" alt="Quả cầu lông" class="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500" onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
        <div class="hidden absolute inset-0 items-center justify-center"><span class="material-symbols-outlined text-[60px] text-amber-300">sports</span></div>
      </div>
      <div class="p-3.5">
        <p class="text-[10px] font-semibold text-zinc-400 uppercase tracking-wider mb-0.5">Dụng cụ thể thao</p>
        <h3 class="text-sm font-semibold text-zinc-900 truncate mb-2">Quả cầu lông (lốc 12)</h3>
        <div class="flex items-end justify-between mb-3">
          <div>
            <p class="text-base font-bold text-zinc-900">85.000<span class="text-xs font-normal text-zinc-500"> đ</span></p>
            <p class="text-[10px] text-zinc-400">/lốc</p>
          </div>
          <div class="text-right">
            <p class="text-[10px] text-zinc-400">Tồn kho</p>
            <p class="text-sm font-bold text-amber-600">5 <span class="text-[10px] text-zinc-400 font-normal">/ ≥10</span></p>
          </div>
        </div>
        <div class="w-full h-1.5 bg-zinc-100 rounded-full overflow-hidden mb-3">
          <div class="h-full bg-gradient-to-r from-amber-400 to-orange-500 rounded-full" style="width:25%"></div>
        </div>
        <div class="flex items-center gap-1.5">
          <button class="flex-1 h-8 rounded-lg bg-zinc-800 text-white text-xs font-medium hover:bg-zinc-800 flex items-center justify-center gap-1 transition-colors"><span class="material-symbols-outlined text-[14px]">add_box</span>Nhập gấp</button>
          <button class="h-8 w-8 rounded-lg border border-zinc-200 text-zinc-500 hover:bg-zinc-50 flex items-center justify-center"><span class="material-symbols-outlined text-[14px]">edit</span></button>
          <button class="h-8 w-8 rounded-lg border border-zinc-200 text-red-400 hover:bg-zinc-100 flex items-center justify-center"><span class="material-symbols-outlined text-[14px]">delete</span></button>
        </div>
      </div>
    </div>

    <!-- SP022: Khăn lau -->
    <div data-aos="fade-up" class="group relative card overflow-hidden hover:shadow-xl hover:-translate-y-0.5 transition-all duration-200 ring-2 ring-red-200">
      <div class="absolute top-2 left-2 z-10">
        <span class="text-[10px] font-bold bg-white/95 backdrop-blur px-2 py-0.5 rounded-md text-zinc-700 shadow-sm">SP022</span>
      </div>
      <div class="absolute top-2 right-2 z-10"><span class="badge badge-red shadow-sm">✕ Hết hàng</span></div>
      <div class="relative h-44 bg-gradient-to-br from-zinc-50 to-zinc-100 overflow-hidden">
        <img src="https://images.unsplash.com/photo-1583912267550-d44c9c5ee1cb?w=400&h=400&fit=crop" alt="Khăn lau" class="w-full h-full object-cover grayscale group-hover:scale-110 transition-transform duration-500" onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
        <div class="hidden absolute inset-0 items-center justify-center"><span class="material-symbols-outlined text-[60px] text-zinc-300">dry_cleaning</span></div>
        <div class="absolute inset-0 bg-red-500/5"></div>
      </div>
      <div class="p-3.5">
        <p class="text-[10px] font-semibold text-zinc-400 uppercase tracking-wider mb-0.5">Dịch vụ phụ trợ</p>
        <h3 class="text-sm font-semibold text-zinc-900 truncate mb-2">Khăn lau thể thao</h3>
        <div class="flex items-end justify-between mb-3">
          <div>
            <p class="text-base font-bold text-zinc-900">15.000<span class="text-xs font-normal text-zinc-500"> đ</span></p>
            <p class="text-[10px] text-zinc-400">/cái</p>
          </div>
          <div class="text-right">
            <p class="text-[10px] text-zinc-400">Tồn kho</p>
            <p class="text-sm font-bold text-red-500">0 <span class="text-[10px] text-zinc-400 font-normal">/ ≥20</span></p>
          </div>
        </div>
        <div class="w-full h-1.5 bg-zinc-100 rounded-full overflow-hidden mb-3">
          <div class="h-full bg-red-500 rounded-full" style="width:2%"></div>
        </div>
        <div class="flex items-center gap-1.5">
          <button class="flex-1 h-8 rounded-lg bg-zinc-800 text-white text-xs font-medium hover:bg-zinc-800 flex items-center justify-center gap-1 transition-colors"><span class="material-symbols-outlined text-[14px]">add_box</span>Nhập ngay</button>
          <button class="h-8 w-8 rounded-lg border border-zinc-200 text-zinc-500 hover:bg-zinc-50 flex items-center justify-center"><span class="material-symbols-outlined text-[14px]">edit</span></button>
          <button class="h-8 w-8 rounded-lg border border-zinc-200 text-red-400 hover:bg-zinc-100 flex items-center justify-center"><span class="material-symbols-outlined text-[14px]">delete</span></button>
        </div>
      </div>
    </div>

    <!-- SP031: Giày Adidas -->
    <div data-aos="fade-up" class="group relative card overflow-hidden hover:shadow-xl hover:-translate-y-0.5 transition-all duration-200">
      <div class="absolute top-2 left-2 z-10">
        <span class="text-[10px] font-bold bg-white/95 backdrop-blur px-2 py-0.5 rounded-md text-zinc-700 shadow-sm">SP031</span>
      </div>
      <div class="absolute top-2 right-2 z-10 flex flex-col gap-1 items-end">
        <span class="badge badge-green shadow-sm">Còn hàng</span>
        <span class="text-[9px] font-semibold bg-purple-500 text-white px-2 py-0.5 rounded-md shadow-sm">CHO THUÊ</span>
      </div>
      <div class="relative h-44 bg-gradient-to-br from-slate-100 to-zinc-200 overflow-hidden">
        <img src="https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&h=400&fit=crop" alt="Giày Adidas" class="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500" onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
        <div class="hidden absolute inset-0 items-center justify-center"><span class="material-symbols-outlined text-[60px] text-zinc-400">sports_soccer</span></div>
      </div>
      <div class="p-3.5">
        <p class="text-[10px] font-semibold text-zinc-400 uppercase tracking-wider mb-0.5">Cho thuê thiết bị</p>
        <h3 class="text-sm font-semibold text-zinc-900 truncate mb-2">Giày bóng đá Adidas size 40</h3>
        <div class="flex items-end justify-between mb-3">
          <div>
            <p class="text-base font-bold text-zinc-900">30.000<span class="text-xs font-normal text-zinc-500"> đ</span></p>
            <p class="text-[10px] text-zinc-400">/lần thuê</p>
          </div>
          <div class="text-right">
            <p class="text-[10px] text-zinc-400">Sẵn có</p>
            <p class="text-sm font-bold text-green-600">6 <span class="text-[10px] text-zinc-400 font-normal">/ ≥3</span></p>
          </div>
        </div>
        <div class="w-full h-1.5 bg-zinc-100 rounded-full overflow-hidden mb-3">
          <div class="h-full bg-gradient-to-r from-green-400 to-emerald-500 rounded-full" style="width:100%"></div>
        </div>
        <div class="flex items-center gap-1.5">
          <button class="flex-1 h-8 rounded-lg bg-zinc-900 text-white text-xs font-medium hover:bg-zinc-800 flex items-center justify-center gap-1 transition-colors"><span class="material-symbols-outlined text-[14px]">add_box</span>Nhập</button>
          <button class="h-8 w-8 rounded-lg border border-zinc-200 text-zinc-500 hover:bg-zinc-50 flex items-center justify-center"><span class="material-symbols-outlined text-[14px]">edit</span></button>
          <button class="h-8 w-8 rounded-lg border border-zinc-200 text-red-400 hover:bg-zinc-100 flex items-center justify-center"><span class="material-symbols-outlined text-[14px]">delete</span></button>
        </div>
      </div>
    </div>

    <!-- SP005: Cà phê đóng chai -->
    <div data-aos="fade-up" class="group relative card overflow-hidden hover:shadow-xl hover:-translate-y-0.5 transition-all duration-200">
      <div class="absolute top-2 left-2 z-10">
        <span class="text-[10px] font-bold bg-white/95 backdrop-blur px-2 py-0.5 rounded-md text-zinc-700 shadow-sm">SP005</span>
      </div>
      <div class="absolute top-2 right-2 z-10"><span class="badge badge-green shadow-sm">Còn hàng</span></div>
      <div class="relative h-44 bg-gradient-to-br from-amber-50 to-yellow-100 overflow-hidden">
        <img src="https://images.unsplash.com/photo-1497935586351-b67a49e012bf?w=400&h=400&fit=crop" alt="Cà phê" class="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500" onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
        <div class="hidden absolute inset-0 items-center justify-center"><span class="material-symbols-outlined text-[60px] text-amber-300">coffee</span></div>
      </div>
      <div class="p-3.5">
        <p class="text-[10px] font-semibold text-zinc-400 uppercase tracking-wider mb-0.5">Đồ uống</p>
        <h3 class="text-sm font-semibold text-zinc-900 truncate mb-2">Cà phê Highlands đóng chai</h3>
        <div class="flex items-end justify-between mb-3">
          <div>
            <p class="text-base font-bold text-zinc-900">22.000<span class="text-xs font-normal text-zinc-500"> đ</span></p>
            <p class="text-[10px] text-zinc-400">/chai</p>
          </div>
          <div class="text-right">
            <p class="text-[10px] text-zinc-400">Tồn kho</p>
            <p class="text-sm font-bold text-green-600">32 <span class="text-[10px] text-zinc-400 font-normal">/ ≥10</span></p>
          </div>
        </div>
        <div class="w-full h-1.5 bg-zinc-100 rounded-full overflow-hidden mb-3">
          <div class="h-full bg-gradient-to-r from-green-400 to-emerald-500 rounded-full" style="width:85%"></div>
        </div>
        <div class="flex items-center gap-1.5">
          <button class="flex-1 h-8 rounded-lg bg-zinc-900 text-white text-xs font-medium hover:bg-zinc-800 flex items-center justify-center gap-1 transition-colors"><span class="material-symbols-outlined text-[14px]">add_box</span>Nhập</button>
          <button class="h-8 w-8 rounded-lg border border-zinc-200 text-zinc-500 hover:bg-zinc-50 flex items-center justify-center"><span class="material-symbols-outlined text-[14px]">edit</span></button>
          <button class="h-8 w-8 rounded-lg border border-zinc-200 text-red-400 hover:bg-zinc-100 flex items-center justify-center"><span class="material-symbols-outlined text-[14px]">delete</span></button>
        </div>
      </div>
    </div>

    <!-- SP018: Bóng đá thi đấu -->
    <div data-aos="fade-up" class="group relative card overflow-hidden hover:shadow-xl hover:-translate-y-0.5 transition-all duration-200">
      <div class="absolute top-2 left-2 z-10">
        <span class="text-[10px] font-bold bg-white/95 backdrop-blur px-2 py-0.5 rounded-md text-zinc-700 shadow-sm">SP018</span>
      </div>
      <div class="absolute top-2 right-2 z-10"><span class="badge badge-green shadow-sm">Còn hàng</span></div>
      <div class="relative h-44 bg-gradient-to-br from-emerald-50 to-teal-100 overflow-hidden">
        <img src="https://images.unsplash.com/photo-1614632537190-23e4146777db?w=400&h=400&fit=crop" alt="Bóng đá" class="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500" onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
        <div class="hidden absolute inset-0 items-center justify-center"><span class="material-symbols-outlined text-[60px] text-emerald-300">sports_soccer</span></div>
      </div>
      <div class="p-3.5">
        <p class="text-[10px] font-semibold text-zinc-400 uppercase tracking-wider mb-0.5">Dụng cụ thể thao</p>
        <h3 class="text-sm font-semibold text-zinc-900 truncate mb-2">Bóng đá thi đấu FIFA Pro</h3>
        <div class="flex items-end justify-between mb-3">
          <div>
            <p class="text-base font-bold text-zinc-900">450.000<span class="text-xs font-normal text-zinc-500"> đ</span></p>
            <p class="text-[10px] text-zinc-400">/quả</p>
          </div>
          <div class="text-right">
            <p class="text-[10px] text-zinc-400">Tồn kho</p>
            <p class="text-sm font-bold text-green-600">14 <span class="text-[10px] text-zinc-400 font-normal">/ ≥5</span></p>
          </div>
        </div>
        <div class="w-full h-1.5 bg-zinc-100 rounded-full overflow-hidden mb-3">
          <div class="h-full bg-gradient-to-r from-green-400 to-emerald-500 rounded-full" style="width:90%"></div>
        </div>
        <div class="flex items-center gap-1.5">
          <button class="flex-1 h-8 rounded-lg bg-zinc-900 text-white text-xs font-medium hover:bg-zinc-800 flex items-center justify-center gap-1 transition-colors"><span class="material-symbols-outlined text-[14px]">add_box</span>Nhập</button>
          <button class="h-8 w-8 rounded-lg border border-zinc-200 text-zinc-500 hover:bg-zinc-50 flex items-center justify-center"><span class="material-symbols-outlined text-[14px]">edit</span></button>
          <button class="h-8 w-8 rounded-lg border border-zinc-200 text-red-400 hover:bg-zinc-100 flex items-center justify-center"><span class="material-symbols-outlined text-[14px]">delete</span></button>
        </div>
      </div>
    </div>

  </div>

  <!-- Pagination for grid -->
  <div class="flex items-center justify-between text-xs text-zinc-500">
    <span>Hiển thị 8 / 47 sản phẩm</span>
    <div class="flex items-center gap-1">
      <button class="px-2 py-1 rounded hover:bg-zinc-100 disabled:opacity-40" disabled><span class="material-symbols-outlined text-[14px]">chevron_left</span></button>
      <button class="px-2.5 py-1 rounded bg-zinc-900 text-white font-medium">1</button>
      <button class="px-2.5 py-1 rounded hover:bg-zinc-100">2</button>
      <button class="px-2.5 py-1 rounded hover:bg-zinc-100">3</button>
      <button class="px-2.5 py-1 rounded hover:bg-zinc-100">4</button>
      <button class="px-2.5 py-1 rounded hover:bg-zinc-100">5</button>
      <button class="px-2 py-1 rounded hover:bg-zinc-100"><span class="material-symbols-outlined text-[14px]">chevron_right</span></button>
    </div>
  </div>

  <!-- Product TABLE (hidden by default) -->
  <div id="productTable" class="hidden card overflow-hidden" style="animation: fadeUp 0.35s cubic-bezier(0.16, 1, 0.3, 1) both">
    <table class="w-full text-sm">
      <thead class="bg-zinc-50 border-b border-zinc-200">
        <tr>
          <th class="px-4 py-3 text-left font-semibold text-zinc-600 text-xs">Mã SP</th>
          <th class="px-4 py-3 text-left font-semibold text-zinc-600 text-xs">Tên sản phẩm / Dịch vụ</th>
          <th class="px-4 py-3 text-left font-semibold text-zinc-600 text-xs hidden sm:table-cell">Danh mục</th>
          <th class="px-4 py-3 text-right font-semibold text-zinc-600 text-xs hidden md:table-cell">Giá bán</th>
          <th class="px-4 py-3 text-right font-semibold text-zinc-600 text-xs">Tồn kho</th>
          <th class="px-4 py-3 text-left font-semibold text-zinc-600 text-xs hidden lg:table-cell">Cảnh báo</th>
          <th class="px-4 py-3 text-left font-semibold text-zinc-600 text-xs">Trạng thái</th>
          <th class="px-4 py-3 text-right font-semibold text-zinc-600 text-xs">Thao tác</th>
        </tr>
      </thead>
      <tbody id="productTableBody" class="divide-y divide-zinc-100">
        <tr class="hover:bg-zinc-50">
          <td class="px-4 py-3 font-mono text-xs text-zinc-500">SP001</td>
          <td class="px-4 py-3">
            <div class="flex items-center gap-3">
              <div class="w-10 h-10 rounded-lg overflow-hidden bg-blue-50 shrink-0">
                <img src="https://images.unsplash.com/photo-1564725073220-fa50fdc6b772?w=80&h=80&fit=crop" class="w-full h-full object-cover" alt="">
              </div>
              <div>
                <p class="font-medium text-zinc-900">Nước suối Aquafina 500ml</p>
                <p class="text-xs text-zinc-400">Thực phẩm & Đồ uống</p>
              </div>
            </div>
          </td>
          <td class="px-4 py-3 text-zinc-600 hidden sm:table-cell">Đồ uống</td>
          <td class="px-4 py-3 text-right font-medium text-zinc-800 hidden md:table-cell">10.000 đ</td>
          <td class="px-4 py-3 text-right font-semibold text-zinc-900">48</td>
          <td class="px-4 py-3 hidden lg:table-cell"><span class="text-xs text-zinc-400">≥ 20</span></td>
          <td class="px-4 py-3"><span class="badge badge-green">Còn hàng</span></td>
          <td class="px-4 py-3 text-right flex items-center justify-end gap-1">
            <button onclick="openRestockModal('SP001')" class="p-1 rounded hover:bg-zinc-100 text-zinc-500" title="Nhập kho"><span class="material-symbols-outlined text-[16px]">add_box</span></button>
            <button class="p-1 rounded hover:bg-zinc-100 text-zinc-500" title="Chỉnh sửa"><span class="material-symbols-outlined text-[16px]">edit</span></button>
            <button class="p-1 rounded hover:bg-zinc-100 text-red-400" title="Xóa"><span class="material-symbols-outlined text-[16px]">delete</span></button>
          </td>
        </tr>
        <tr class="hover:bg-zinc-50">
          <td class="px-4 py-3 font-mono text-xs text-zinc-500">SP002</td>
          <td class="px-4 py-3">
            <div class="flex items-center gap-3">
              <div class="w-10 h-10 rounded-lg overflow-hidden bg-red-50 shrink-0">
                <img src="https://images.unsplash.com/photo-1622543925917-763c34d1a86e?w=80&h=80&fit=crop" class="w-full h-full object-cover" alt="">
              </div>
              <div>
                <p class="font-medium text-zinc-900">Nước tăng lực Redbull</p>
                <p class="text-xs text-zinc-400">Thực phẩm & Đồ uống</p>
              </div>
            </div>
          </td>
          <td class="px-4 py-3 text-zinc-600 hidden sm:table-cell">Đồ uống</td>
          <td class="px-4 py-3 text-right font-medium text-zinc-800 hidden md:table-cell">25.000 đ</td>
          <td class="px-4 py-3 text-right font-semibold text-amber-600">8</td>
          <td class="px-4 py-3 hidden lg:table-cell"><span class="text-xs text-amber-600">≥ 15 ⚠</span></td>
          <td class="px-4 py-3"><span class="badge badge-amber">Sắp hết</span></td>
          <td class="px-4 py-3 text-right flex items-center justify-end gap-1">
            <button onclick="openRestockModal('SP002')" class="p-1 rounded hover:bg-zinc-100 text-zinc-800" title="Nhập kho"><span class="material-symbols-outlined text-[16px]">add_box</span></button>
            <button class="p-1 rounded hover:bg-zinc-100 text-zinc-500"><span class="material-symbols-outlined text-[16px]">edit</span></button>
            <button class="p-1 rounded hover:bg-zinc-100 text-red-400"><span class="material-symbols-outlined text-[16px]">delete</span></button>
          </td>
        </tr>
        <tr class="hover:bg-zinc-50">
          <td class="px-4 py-3 font-mono text-xs text-zinc-500">SP010</td>
          <td class="px-4 py-3">
            <div class="flex items-center gap-3">
              <div class="w-10 h-10 rounded-lg overflow-hidden bg-purple-50 shrink-0">
                <img src="https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=80&h=80&fit=crop" class="w-full h-full object-cover" alt="">
              </div>
              <div>
                <p class="font-medium text-zinc-900">Vợt cầu lông Yonex (cho thuê)</p>
                <p class="text-xs text-zinc-400">Cho thuê thiết bị</p>
              </div>
            </div>
          </td>
          <td class="px-4 py-3 text-zinc-600 hidden sm:table-cell">Cho thuê</td>
          <td class="px-4 py-3 text-right font-medium text-zinc-800 hidden md:table-cell">20.000 đ/lần</td>
          <td class="px-4 py-3 text-right font-semibold text-zinc-900">12</td>
          <td class="px-4 py-3 hidden lg:table-cell"><span class="text-xs text-zinc-400">≥ 5</span></td>
          <td class="px-4 py-3"><span class="badge badge-green">Còn hàng</span></td>
          <td class="px-4 py-3 text-right flex items-center justify-end gap-1">
            <button class="p-1 rounded hover:bg-zinc-100 text-zinc-500"><span class="material-symbols-outlined text-[16px]">add_box</span></button>
            <button class="p-1 rounded hover:bg-zinc-100 text-zinc-500"><span class="material-symbols-outlined text-[16px]">edit</span></button>
            <button class="p-1 rounded hover:bg-zinc-100 text-red-400"><span class="material-symbols-outlined text-[16px]">delete</span></button>
          </td>
        </tr>
        <tr class="hover:bg-zinc-50">
          <td class="px-4 py-3 font-mono text-xs text-zinc-500">SP015</td>
          <td class="px-4 py-3">
            <div class="flex items-center gap-3">
              <div class="w-10 h-10 rounded-lg overflow-hidden bg-amber-50 shrink-0">
                <img src="https://images.unsplash.com/photo-1593787406536-3676a72d23a8?w=80&h=80&fit=crop" class="w-full h-full object-cover" alt="">
              </div>
              <div>
                <p class="font-medium text-zinc-900">Quả cầu lông (lốc 12)</p>
                <p class="text-xs text-zinc-400">Dụng cụ thể thao</p>
              </div>
            </div>
          </td>
          <td class="px-4 py-3 text-zinc-600 hidden sm:table-cell">Dụng cụ</td>
          <td class="px-4 py-3 text-right font-medium text-zinc-800 hidden md:table-cell">85.000 đ</td>
          <td class="px-4 py-3 text-right font-semibold text-amber-600">5</td>
          <td class="px-4 py-3 hidden lg:table-cell"><span class="text-xs text-amber-600">≥ 10 ⚠</span></td>
          <td class="px-4 py-3"><span class="badge badge-amber">Sắp hết</span></td>
          <td class="px-4 py-3 text-right flex items-center justify-end gap-1">
            <button class="p-1 rounded hover:bg-zinc-100 text-zinc-800"><span class="material-symbols-outlined text-[16px]">add_box</span></button>
            <button class="p-1 rounded hover:bg-zinc-100 text-zinc-500"><span class="material-symbols-outlined text-[16px]">edit</span></button>
            <button class="p-1 rounded hover:bg-zinc-100 text-red-400"><span class="material-symbols-outlined text-[16px]">delete</span></button>
          </td>
        </tr>
        <tr class="hover:bg-zinc-50">
          <td class="px-4 py-3 font-mono text-xs text-zinc-500">SP022</td>
          <td class="px-4 py-3">
            <div class="flex items-center gap-3">
              <div class="w-10 h-10 rounded-lg overflow-hidden bg-zinc-100 shrink-0">
                <img src="https://images.unsplash.com/photo-1583912267550-d44c9c5ee1cb?w=80&h=80&fit=crop" class="w-full h-full object-cover grayscale" alt="">
              </div>
              <div>
                <p class="font-medium text-zinc-900">Khăn lau thể thao</p>
                <p class="text-xs text-zinc-400">Dịch vụ phụ trợ</p>
              </div>
            </div>
          </td>
          <td class="px-4 py-3 text-zinc-600 hidden sm:table-cell">Dịch vụ</td>
          <td class="px-4 py-3 text-right font-medium text-zinc-800 hidden md:table-cell">15.000 đ</td>
          <td class="px-4 py-3 text-right font-semibold text-red-600">0</td>
          <td class="px-4 py-3 hidden lg:table-cell"><span class="text-xs text-red-600">≥ 20 ✕</span></td>
          <td class="px-4 py-3"><span class="badge badge-red">Hết hàng</span></td>
          <td class="px-4 py-3 text-right flex items-center justify-end gap-1">
            <button class="p-1 rounded hover:bg-zinc-100 text-red-500"><span class="material-symbols-outlined text-[16px]">add_box</span></button>
            <button class="p-1 rounded hover:bg-zinc-100 text-zinc-500"><span class="material-symbols-outlined text-[16px]">edit</span></button>
            <button class="p-1 rounded hover:bg-zinc-100 text-red-400"><span class="material-symbols-outlined text-[16px]">delete</span></button>
          </td>
        </tr>
        <tr class="hover:bg-zinc-50">
          <td class="px-4 py-3 font-mono text-xs text-zinc-500">SP031</td>
          <td class="px-4 py-3">
            <div class="flex items-center gap-3">
              <div class="w-10 h-10 rounded-lg overflow-hidden bg-slate-100 shrink-0">
                <img src="https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=80&h=80&fit=crop" class="w-full h-full object-cover" alt="">
              </div>
              <div>
                <p class="font-medium text-zinc-900">Giày bóng đá Adidas size 40</p>
                <p class="text-xs text-zinc-400">Cho thuê thiết bị</p>
              </div>
            </div>
          </td>
          <td class="px-4 py-3 text-zinc-600 hidden sm:table-cell">Cho thuê</td>
          <td class="px-4 py-3 text-right font-medium text-zinc-800 hidden md:table-cell">30.000 đ/lần</td>
          <td class="px-4 py-3 text-right font-semibold text-zinc-900">6</td>
          <td class="px-4 py-3 hidden lg:table-cell"><span class="text-xs text-zinc-400">≥ 3</span></td>
          <td class="px-4 py-3"><span class="badge badge-green">Còn hàng</span></td>
          <td class="px-4 py-3 text-right flex items-center justify-end gap-1">
            <button class="p-1 rounded hover:bg-zinc-100 text-zinc-500"><span class="material-symbols-outlined text-[16px]">add_box</span></button>
            <button class="p-1 rounded hover:bg-zinc-100 text-zinc-500"><span class="material-symbols-outlined text-[16px]">edit</span></button>
            <button class="p-1 rounded hover:bg-zinc-100 text-red-400"><span class="material-symbols-outlined text-[16px]">delete</span></button>
          </td>
        </tr>
      </tbody>
    </table>
  </div>

</main>

<!-- Modal: Tạo lịch đặt mới -->
<div id="bookingModal" class="fixed inset-0 bg-zinc-950/60 backdrop-blur-sm z-50 flex items-center justify-center p-4 transition-all duration-355 opacity-0 pointer-events-none">
  <div id="bookingModalCard" class="bg-white w-full max-w-5xl rounded-3xl shadow-2xl border border-zinc-200 overflow-hidden flex flex-col max-h-[92vh] transform scale-95 transition-all duration-355">
    
    <!-- Modal Header -->
    <div class="px-6 py-4 border-b border-zinc-150 bg-gradient-to-r from-zinc-50 to-white flex items-center justify-between">
      <div class="flex items-center gap-3">
        <div class="w-10 h-10 rounded-xl bg-blue-50 flex items-center justify-center text-blue-700">
          <span class="material-symbols-outlined text-[22px]">add_circle</span>
        </div>
        <div>
          <h3 class="text-base font-bold text-zinc-900 leading-tight">Tạo lịch đặt mới</h3>
          <p class="text-xs text-zinc-500">Đặt sân nhanh, tự động tính toán chi phí & đồng bộ hệ thống</p>
        </div>
      </div>
      <button id="closeBookingModalBtn" class="w-8 h-8 rounded-full hover:bg-zinc-100 flex items-center justify-center text-zinc-400 hover:text-zinc-650 transition-colors">
        <span class="material-symbols-outlined text-[18px]">close</span>
      </button>
    </div>

    <!-- Modal Content -->
    <div class="flex-1 overflow-y-auto p-6 grid grid-cols-1 lg:grid-cols-12 gap-6">
      
      <!-- Left Column: Form Fields (8 cols on desktop) -->
      <div class="lg:col-span-8 flex flex-col gap-5">
        
        <!-- SECTION 1: Khách Hàng -->
        <div class="bg-zinc-50/50 border border-zinc-200/80 rounded-2xl p-4 flex flex-col gap-4">
          <div class="flex items-center justify-between">
            <h4 class="text-xs font-bold text-zinc-500 uppercase tracking-wider flex items-center gap-1.5">
              <span class="material-symbols-outlined text-[15px]">person</span>Thông tin khách hàng
            </h4>
            <!-- Customer Type Toggle -->
            <div class="flex p-0.5 bg-zinc-150 rounded-lg text-[11px] font-semibold border border-zinc-200">
              <button id="btnCustVip" class="px-3 py-1 rounded-md bg-white shadow-sm text-zinc-800 transition-all">Khách quen (VIP/Thành viên)</button>
              <button id="btnCustWalkin" class="px-3 py-1 rounded-md text-zinc-500 hover:text-zinc-850 transition-all">Khách vãng lai</button>
            </div>
          </div>

          <!-- Existing Customer Select / Search -->
          <div id="custVipSection" class="relative">
            <label class="text-[11px] font-bold text-zinc-600 mb-1.5 block">Tìm kiếm khách hàng quen thuộc</label>
            <div class="relative">
              <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-zinc-450 text-[18px]">search</span>
              <input type="text" id="custSearchInput" class="w-full pl-10 pr-4 py-2 bg-white border border-zinc-250 rounded-xl text-xs focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500" placeholder="Nhập tên hoặc số điện thoại khách hàng...">
              <button id="clearCustSearchBtn" class="absolute right-3 top-1/2 -translate-y-1/2 text-zinc-450 hover:text-zinc-600 hidden">
                <span class="material-symbols-outlined text-[15px]">close</span>
              </button>
            </div>
            
            <!-- Autocomplete dropdown -->
            <div id="custSuggestions" class="hidden absolute left-0 right-0 top-[calc(100%+4px)] max-h-[180px] bg-white border border-zinc-200 rounded-xl shadow-xl z-50 overflow-y-auto divide-y divide-zinc-100">
              <!-- Render dynamically -->
            </div>

            <!-- Selected Customer Profile Card -->
            <div id="selectedCustCard" class="hidden mt-3 p-3 bg-blue-50/40 border border-blue-100/50 rounded-xl flex items-center justify-between">
              <div class="flex items-center gap-3">
                <img id="selectedCustAvatar" src="" class="w-10 h-10 rounded-full object-cover ring-2 ring-white shadow-sm">
                <div>
                  <div class="flex items-center gap-2">
                    <span id="selectedCustName" class="text-xs font-bold text-zinc-900"></span>
                    <span id="selectedCustVip" class="badge"></span>
                  </div>
                  <div class="flex items-center gap-3 text-[10px] text-zinc-500 mt-0.5">
                    <span class="flex items-center gap-0.5"><span class="material-symbols-outlined text-[11px]">call</span><span id="selectedCustPhone"></span></span>
                    <span class="flex items-center gap-0.5"><span class="material-symbols-outlined text-[11px] text-amber-500" style="font-variation-settings:'FILL' 1">star</span>ELO: <span id="selectedCustElo" class="font-bold"></span></span>
                  </div>
                </div>
              </div>
              <button id="removeSelectedCustBtn" class="text-[10px] text-red-650 font-bold hover:underline">Thay đổi</button>
            </div>
          </div>

          <!-- Walk-in Customer Fields -->
          <div id="custWalkinSection" class="hidden grid grid-cols-1 md:grid-cols-2 gap-3">
            <div>
              <label class="text-[11px] font-bold text-zinc-600 mb-1 block">Tên khách hàng <span class="text-red-500">*</span></label>
              <input type="text" id="walkinName" class="w-full px-3 py-2 bg-white border border-zinc-250 rounded-xl text-xs focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500" placeholder="Nguyễn Văn A">
            </div>
            <div>
              <label class="text-[11px] font-bold text-zinc-600 mb-1 block">Số điện thoại <span class="text-red-500">*</span></label>
              <input type="text" id="walkinPhone" class="w-full px-3 py-2 bg-white border border-zinc-250 rounded-xl text-xs focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500" placeholder="09xxxxxxxx">
            </div>
          </div>
        </div>

        <!-- SECTION 2: Chọn Sân & Bộ Môn -->
        <div class="bg-zinc-50/50 border border-zinc-200/80 rounded-2xl p-4 flex flex-col gap-4">
          <h4 class="text-xs font-bold text-zinc-500 uppercase tracking-wider flex items-center gap-1.5">
            <span class="material-symbols-outlined text-[15px]">stadium</span>Cấu hình dịch vụ sân
          </h4>

          <div class="grid grid-cols-1 md:grid-cols-3 gap-3">
            <div>
              <label class="text-[11px] font-bold text-zinc-600 mb-1 block">Bộ môn thể thao</label>
              <select id="selectSport" class="w-full px-3 py-2 bg-white border border-zinc-250 rounded-xl text-xs focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500">
                <!-- Dynamically populated -->
              </select>
            </div>
            <div class="md:col-span-2">
              <label class="text-[11px] font-bold text-zinc-600 mb-1 block">Loại hình sân</label>
              <select id="selectLoaiSan" class="w-full px-3 py-2 bg-white border border-zinc-250 rounded-xl text-xs focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500">
                <!-- Dynamically populated -->
              </select>
            </div>
          </div>

          <!-- Court Grid Selection -->
          <div>
            <div class="flex items-center justify-between mb-1.5">
              <label class="text-[11px] font-bold text-zinc-600">Chọn sân thi đấu cụ thể <span class="text-red-500">*</span></label>
              <span class="text-[10px] text-zinc-400 font-medium">Bấm vào sân trống để chọn</span>
            </div>
            
            <div id="courtGrid" class="grid grid-cols-2 sm:grid-cols-4 gap-2.5">
              <!-- Dynamically populated cards -->
            </div>
          </div>

          <!-- Booking Source -->
          <div>
            <label class="text-[11px] font-bold text-zinc-600 mb-2 block">Nguồn đặt sân</label>
            <div id="sourceContainer" class="grid grid-cols-2 sm:grid-cols-4 gap-2">
              <button type="button" data-source="Walk-in" class="source-chip flex items-center justify-center gap-1.5 py-2 px-3 border border-zinc-200 bg-white rounded-xl text-xs font-semibold text-zinc-600 hover:bg-zinc-50 active:scale-95 transition-all">
                <span class="material-symbols-outlined text-[15px]">directions_walk</span>Walk-in
              </button>
              <button type="button" data-source="Zalo" class="source-chip flex items-center justify-center gap-1.5 py-2 px-3 border border-zinc-200 bg-white rounded-xl text-xs font-semibold text-zinc-600 hover:bg-zinc-50 active:scale-95 transition-all">
                <span class="material-symbols-outlined text-[15px]">chat</span>Zalo
              </button>
              <button type="button" data-source="App" class="source-chip flex items-center justify-center gap-1.5 py-2 px-3 border border-zinc-200 bg-white rounded-xl text-xs font-semibold text-zinc-600 hover:bg-zinc-50 active:scale-95 transition-all">
                <span class="material-symbols-outlined text-[15px]">smartphone</span>App
              </button>
              <button type="button" data-source="Call" class="source-chip flex items-center justify-center gap-1.5 py-2 px-3 border border-zinc-200 bg-white rounded-xl text-xs font-semibold text-zinc-600 hover:bg-zinc-50 active:scale-95 transition-all">
                <span class="material-symbols-outlined text-[15px]">call</span>Gọi điện
              </button>
            </div>
          </div>
        </div>

      </div>

      <!-- Right Column: Time, Lighting & Price (4 cols on desktop) -->
      <div class="lg:col-span-4 flex flex-col gap-5 border-l border-zinc-100 lg:pl-6">
        
        <!-- SECTION 3: Thời gian đặt -->
        <div class="flex flex-col gap-4">
          <h4 class="text-xs font-bold text-zinc-500 uppercase tracking-wider flex items-center gap-1.5">
            <span class="material-symbols-outlined text-[15px]">schedule</span>Thời gian & Khung giờ
          </h4>

          <div>
            <label class="text-[11px] font-bold text-zinc-600 mb-1.5 block">Chọn ngày đặt sân</label>
            <div class="relative">
              <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-zinc-400 text-[18px]">calendar_today</span>
              <input type="date" id="bookingDate" class="w-full pl-10 pr-3 py-2 bg-white border border-zinc-250 rounded-xl text-xs focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500">
            </div>
          </div>

          <div class="grid grid-cols-2 gap-3">
            <div>
              <label class="text-[11px] font-bold text-zinc-600 mb-1 block">Giờ bắt đầu</label>
              <input type="time" id="timeStart" class="w-full px-3 py-2 bg-white border border-zinc-250 rounded-xl text-xs focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500" value="08:00">
            </div>
            <div>
              <label class="text-[11px] font-bold text-zinc-600 mb-1 block">Giờ kết thúc</label>
              <input type="time" id="timeEnd" class="w-full px-3 py-2 bg-white border border-zinc-250 rounded-xl text-xs focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500" value="10:00">
            </div>
          </div>

          <!-- Duration Presets -->
          <div class="flex items-center gap-1.5 flex-wrap">
            <span class="text-[10px] text-zinc-400 font-semibold mr-1">Thời lượng:</span>
            <button type="button" data-duration="1.0" class="btn-duration px-2 py-1 bg-zinc-100 hover:bg-zinc-200 text-zinc-700 text-[10px] font-bold rounded-lg transition-colors">1.0h</button>
            <button type="button" data-duration="1.5" class="btn-duration px-2 py-1 bg-zinc-100 hover:bg-zinc-200 text-zinc-700 text-[10px] font-bold rounded-lg transition-colors">1.5h</button>
            <button type="button" data-duration="2.0" class="btn-duration px-2 py-1 bg-blue-50 hover:bg-blue-100 text-blue-700 text-[10px] font-bold rounded-lg transition-colors border border-blue-100">2.0h</button>
            <button type="button" data-duration="3.0" class="btn-duration px-2 py-1 bg-zinc-100 hover:bg-zinc-200 text-zinc-700 text-[10px] font-bold rounded-lg transition-colors">3.0h</button>
          </div>

          <!-- Lighting Fee Surcharge -->
          <div class="p-3 bg-zinc-50 border border-zinc-200 rounded-2xl flex items-center justify-between gap-3">
            <div>
              <p class="text-xs font-bold text-zinc-800 flex items-center gap-1">
                <span class="material-symbols-outlined text-[15px] text-amber-500">wb_incandescent</span>Áp dụng đèn chiếu sáng
              </p>
              <p id="lightInfoText" class="text-[9px] text-zinc-500 mt-0.5">Không phụ thu đèn</p>
            </div>
            <!-- Beautiful Switch -->
            <label class="relative inline-flex items-center cursor-pointer">
              <input type="checkbox" id="toggleLight" class="sr-only peer">
              <div class="w-9 h-5 bg-zinc-200 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-zinc-300 after:border after:rounded-full after:h-4 after:w-4 after:transition-all peer-checked:bg-blue-600"></div>
            </label>
          </div>
        </div>

        <!-- SECTION 4: Ghi chú -->
        <div>
          <label class="text-[11px] font-bold text-zinc-600 mb-1.5 block">Ghi chú đặc biệt</label>
          <textarea id="bookingNotes" rows="2" class="w-full px-3 py-2 bg-white border border-zinc-250 rounded-xl text-xs focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 resize-none" placeholder="Ví dụ: Cần mượn thêm 2 vợt, bóng thi đấu mới..."></textarea>
        </div>

        <!-- SECTION 5: Tóm tắt & Thanh toán -->
        <div class="bg-gradient-to-br from-zinc-900 to-zinc-950 text-white rounded-2xl p-4 shadow-xl flex flex-col gap-3 mt-auto">
          <div class="border-b border-white/10 pb-2.5">
            <h5 class="text-[10px] text-zinc-400 font-bold uppercase tracking-widest">Tóm tắt thanh toán</h5>
          </div>

          <div class="flex flex-col gap-1.5 text-xs text-zinc-300">
            <div class="flex justify-between">
              <span>Sân thi đấu:</span>
              <span id="summaryCourt" class="font-bold text-white">-</span>
            </div>
            <div class="flex justify-between">
              <span>Thời lượng đặt:</span>
              <span id="summaryDuration" class="font-semibold text-white">2.0 giờ</span>
            </div>
            <div class="flex justify-between">
              <span>Đơn giá sân:</span>
              <span id="summaryRate" class="font-semibold text-white">0đ / giờ</span>
            </div>
            <div id="summaryLightRow" class="flex justify-between hidden">
              <span class="flex items-center gap-0.5 text-amber-300"><span class="material-symbols-outlined text-[11px]">wb_incandescent</span>Phụ thu đèn:</span>
              <span id="summaryLightFee" class="font-semibold text-amber-300">+0đ</span>
            </div>
          </div>

          <div class="border-t border-white/10 pt-3 flex items-baseline justify-between mt-1">
            <span class="text-xs text-zinc-400 font-semibold">TỔNG CỘNG:</span>
            <div class="text-right">
              <p id="summaryTotal" class="text-2xl font-black text-emerald-400 leading-none">0đ</p>
              <p class="text-[9px] text-zinc-550 mt-1">Giá dự kiến trước VAT</p>
            </div>
          </div>
        </div>

      </div>

    </div>

    <!-- Modal Footer -->
    <div class="px-6 py-4 border-t border-zinc-150 bg-zinc-50 flex items-center justify-end gap-2.5">
      <button id="cancelBookingBtn" class="h-10 px-5 rounded-xl border border-zinc-250 bg-white hover:bg-zinc-50 text-zinc-650 text-xs font-semibold active:scale-95 transition-all">
        Hủy bỏ
      </button>
      <button id="confirmBookingBtn" class="h-10 px-5 rounded-xl bg-blue-600 hover:bg-blue-700 text-white text-xs font-bold shadow-md shadow-blue-100 flex items-center gap-1.5 active:scale-95 transition-all">
        <span class="material-symbols-outlined text-[16px]">check_circle</span>Xác nhận đặt sân
      </button>
    </div>

  </div>
</div>

<!-- SUCCESS TOAST NOTIFICATION -->
<div id="successToast" class="fixed bottom-6 right-6 bg-zinc-900 text-white rounded-2xl p-4 shadow-2xl border border-zinc-800 z-50 flex items-start gap-3 transition-all duration-300 translate-y-12 opacity-0 pointer-events-none w-80">
  <div class="w-8 h-8 rounded-full bg-emerald-500/20 text-emerald-400 flex items-center justify-center shrink-0">
    <span class="material-symbols-outlined text-[18px]">check</span>
  </div>
  <div class="flex-1 min-w-0">
    <p id="toastTitle" class="text-sm font-semibold text-zinc-100 leading-none">Thành công</p>
    <p id="toastMessage" class="text-xs text-zinc-400 mt-1 leading-normal">Thao tác thành công.</p>
  </div>
</div>

<!-- Add Product Modal -->
<div id="productModal" class="hidden fixed inset-0 z-[80] flex items-center justify-center p-4">
  <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" onclick="closeProductModal()"></div>
  <div class="relative bg-white rounded-2xl shadow-2xl w-full max-w-[480px] max-h-[90vh] overflow-y-auto z-10 border border-zinc-200">
    <div class="flex items-center justify-between px-6 py-4 border-b border-zinc-100">
      <h2 id="modalTitle" class="text-base font-semibold text-zinc-900">Thêm sản phẩm / Dịch vụ</h2>
      <button onclick="closeProductModal()" class="p-1.5 rounded-lg hover:bg-zinc-100"><span class="material-symbols-outlined text-[18px] text-zinc-500">close</span></button>
    </div>
    <div class="px-6 py-4 flex flex-col gap-4">
      <div class="grid grid-cols-2 gap-3">
        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-medium text-zinc-700">Danh mục <span class="text-red-500">*</span> <span class="text-[10px] text-zinc-400 font-normal">· Bảng DanhMuc</span></label>
          <select id="prodDanhMuc" class="h-9 px-3 rounded-lg border border-zinc-200 text-sm focus:outline-none focus:ring-2 focus:ring-zinc-400 bg-white">
            <option value="">-- Chọn danh mục --</option>
            <option value="1">Thực phẩm & Đồ uống</option>
            <option value="2">Dụng cụ thể thao</option>
            <option value="3">Cho thuê thiết bị</option>
            <option value="4">Dịch vụ phụ trợ</option>
          </select>
        </div>
        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-medium text-zinc-700">Cơ Sở <span class="text-red-500">*</span> <span class="text-[10px] text-zinc-400 font-normal">· Bảng CoSo</span></label>
          <select id="prodCoSo" class="h-9 px-3 rounded-lg border border-zinc-200 text-sm focus:outline-none focus:ring-2 focus:ring-zinc-400 bg-white">
            <option value="">-- Chọn Cơ Sở --</option>
            <option value="1">V-Sport Vũng Tàu</option>
            <option value="2">V-Sport Bà Rịa</option>
          </select>
        </div>
      </div>
      <div class="grid grid-cols-2 gap-3">
        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-medium text-zinc-700">Mã sản phẩm <span class="text-red-500">*</span></label>
          <input type="text" id="prodCode" placeholder="VD: SP048" class="h-9 px-3 rounded-lg border border-zinc-200 text-sm focus:outline-none focus:ring-2 focus:ring-zinc-400">
        </div>
        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-medium text-zinc-700">Đơn vị tính <span class="text-red-500">*</span></label>
          <input type="text" id="prodUnit" placeholder="VD: Chai, Cái, Lần" class="h-9 px-3 rounded-lg border border-zinc-200 text-sm focus:outline-none focus:ring-2 focus:ring-zinc-400">
        </div>
      </div>
      <div class="flex flex-col gap-1.5">
        <label class="text-xs font-medium text-zinc-700">Tên sản phẩm <span class="text-red-500">*</span></label>
        <input type="text" id="prodName" placeholder="Nhập tên sản phẩm hoặc dịch vụ" class="h-9 px-3 rounded-lg border border-zinc-200 text-sm focus:outline-none focus:ring-2 focus:ring-zinc-400">
      </div>
      <div class="grid grid-cols-2 gap-3">
        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-medium text-zinc-700">Giá bán (đ) <span class="text-red-500">*</span></label>
          <input type="number" id="prodPrice" placeholder="0" class="h-9 px-3 rounded-lg border border-zinc-200 text-sm focus:outline-none focus:ring-2 focus:ring-zinc-400">
        </div>
        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-medium text-zinc-700">Trạng thái</label>
          <select id="prodStatus" class="h-9 px-3 rounded-lg border border-zinc-200 text-sm focus:outline-none focus:ring-2 focus:ring-zinc-400 bg-white">
            <option value="Còn hàng">Còn hàng</option>
            <option value="Sắp hết">Sắp hết</option>
            <option value="Hết hàng">Hết hàng</option>
            <option value="Ngừng kinh doanh">Ngừng kinh doanh</option>
          </select>
        </div>
      </div>
      <div class="grid grid-cols-2 gap-3">
        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-medium text-zinc-700">Tồn kho ban đầu</label>
          <input type="number" id="prodStock" placeholder="0" class="h-9 px-3 rounded-lg border border-zinc-200 text-sm focus:outline-none focus:ring-2 focus:ring-zinc-400">
        </div>
        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-medium text-zinc-700">Cảnh báo khi ≤ <span class="text-red-500">*</span></label>
          <input type="number" id="prodAlert" placeholder="10" class="h-9 px-3 rounded-lg border border-zinc-200 text-sm focus:outline-none focus:ring-2 focus:ring-zinc-400">
        </div>
      </div>
      <div class="flex flex-col gap-1.5">
        <label class="text-xs font-medium text-zinc-700">Ghi chú</label>
        <textarea id="prodNote" rows="2" class="px-3 py-2 rounded-lg border border-zinc-200 text-sm resize-none focus:outline-none focus:ring-2 focus:ring-zinc-400"></textarea>
      </div>
    </div>
    <div class="px-6 py-4 border-t border-zinc-100 flex justify-end gap-2">
      <button onclick="closeProductModal()" class="h-9 px-4 rounded-lg border border-zinc-200 text-sm text-zinc-700 hover:bg-zinc-50">Hủy</button>
      <button id="btnSubmitProduct" onclick="saveProduct()" class="h-9 px-4 rounded-lg bg-zinc-900 text-white text-sm font-medium hover:bg-zinc-800">Thêm mới</button>
    </div>
  </div>
</div>

<!-- Restock Modal -->
<div id="restockModal" class="hidden fixed inset-0 z-[80] flex items-center justify-center p-4">
  <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" onclick="document.getElementById('restockModal').classList.add('hidden')"></div>
  <div class="relative bg-white rounded-2xl shadow-2xl w-full max-w-[360px]">
    <div class="flex items-center justify-between px-6 py-4 border-b border-zinc-100">
      <h2 class="text-base font-semibold text-zinc-900">Nhập kho</h2>
      <button onclick="document.getElementById('restockModal').classList.add('hidden')" class="p-1.5 rounded-lg hover:bg-zinc-100"><span class="material-symbols-outlined text-[18px] text-zinc-500">close</span></button>
    </div>
    <div class="px-6 py-4 flex flex-col gap-4">
      <div class="px-3 py-2.5 bg-zinc-50 rounded-lg">
        <p class="text-xs text-zinc-500">Sản phẩm</p>
        <p class="text-sm font-semibold text-zinc-900" id="restockName">SP002 — Nước tăng lực Redbull</p>
        <p class="text-xs text-zinc-500 mt-0.5">Tồn kho hiện tại: <span id="restockCurrentStock" class="font-semibold text-amber-600">8 chai</span></p>
      </div>
      <div class="flex flex-col gap-1.5">
        <label class="text-xs font-medium text-zinc-700">Số lượng nhập <span class="text-red-500">*</span></label>
        <input type="number" id="restockQty" min="1" placeholder="Nhập số lượng" class="h-9 px-3 rounded-lg border border-zinc-200 text-sm focus:outline-none focus:ring-2 focus:ring-zinc-400">
      </div>
      <div class="flex flex-col gap-1.5">
        <label class="text-xs font-medium text-zinc-700">Nhà cung cấp</label>
        <input type="text" id="restockSupplier" placeholder="Tên nhà cung cấp" class="h-9 px-3 rounded-lg border border-zinc-200 text-sm focus:outline-none focus:ring-2 focus:ring-zinc-400">
      </div>
      <div class="flex flex-col gap-1.5">
        <label class="text-xs font-medium text-zinc-700">Ghi chú phiếu nhập</label>
        <textarea id="restockNote" rows="2" class="px-3 py-2 rounded-lg border border-zinc-200 text-sm resize-none focus:outline-none focus:ring-2 focus:ring-zinc-400"></textarea>
      </div>
    </div>
    <div class="px-6 py-4 border-t border-zinc-100 flex justify-end gap-2">
      <button onclick="closeRestockModal()" class="h-9 px-4 rounded-lg border border-zinc-200 text-sm text-zinc-700 hover:bg-zinc-50">Hủy</button>
      <button onclick="submitRestock()" class="h-9 px-4 rounded-lg bg-zinc-900 text-white text-sm font-medium hover:bg-zinc-800">Xác nhận nhập</button>
    </div>
  </div>
</div>

<script src="https://unpkg.com/aos@2.3.1/dist/aos.js"></script>
<script>
// State-Driven Inventory Management for V-SPORT CS01 Vũng Tàu & CS02 Bà Rịa
// Mapped directly to CSDL V-Sport V4: SanPham_DichVu & DanhMucSanPham

// 1. Mock Data aligned with CSDL Schema
let products = [
  {
    SanPhamID: 'SP001',
    TenSanPham: 'Nước suối Aquafina 500ml',
    DanhMucID: 1,
    CoSoID: 1,
    DonViTinh: 'Chai',
    DonGia: 10000,
    SoLuongTon: 48,
    CanhBaoTon: 20,
    TrangThai: 'Còn hàng',
    GhiChu: 'Nước uống tinh khiết Aquafina đóng chai tiện lợi',
    AnhSanPham: 'https://images.unsplash.com/photo-1564725073220-fa50fdc6b772?w=400&h=400&fit=crop'
  },
  {
    SanPhamID: 'SP002',
    TenSanPham: 'Nước tăng lực Redbull lon 250ml',
    DanhMucID: 1,
    CoSoID: 1,
    DonViTinh: 'Lon',
    DonGia: 25000,
    SoLuongTon: 8,
    CanhBaoTon: 15,
    TrangThai: 'Sắp hết',
    GhiChu: 'Nước tăng lực bò húc Thái Lan nhập khẩu',
    AnhSanPham: 'https://images.unsplash.com/photo-1622543925917-763c34d1a86e?w=400&h=400&fit=crop'
  },
  {
    SanPhamID: 'SP003',
    TenSanPham: 'Vợt cầu lông Yonex Astrox 88D Play',
    DanhMucID: 3,
    CoSoID: 1,
    DonViTinh: 'Lượt thuê',
    DonGia: 20000,
    SoLuongTon: 12,
    CanhBaoTon: 5,
    TrangThai: 'Còn hàng',
    GhiChu: 'Vợt cầu lông Yonex chính hãng, độ căng cước chuẩn',
    AnhSanPham: 'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=400&h=400&fit=crop'
  },
  {
    SanPhamID: 'SP004',
    TenSanPham: 'Quả cầu lông Yonex 3 đai (Lốc 12 quả)',
    DanhMucID: 2,
    CoSoID: 2,
    DonViTinh: 'Hộp',
    DonGia: 85000,
    SoLuongTon: 5,
    CanhBaoTon: 10,
    TrangThai: 'Sắp hết',
    GhiChu: 'Hộp 12 quả cầu lông Yonex bền bỉ, đường bay chuẩn',
    AnhSanPham: 'https://images.unsplash.com/photo-1593787406536-3676a72d23a8?w=400&h=400&fit=crop'
  },
  {
    SanPhamID: 'SP005',
    TenSanPham: 'Khăn lau mồ hôi thể thao V-Sport',
    DanhMucID: 4,
    CoSoID: 1,
    DonViTinh: 'Cái',
    DonGia: 15000,
    SoLuongTon: 0,
    CanhBaoTon: 20,
    TrangThai: 'Hết hàng',
    GhiChu: 'Khăn cotton 100% siêu thấm hút cho người chơi thể thao',
    AnhSanPham: 'https://images.unsplash.com/photo-1583912267550-d44c9c5ee1cb?w=400&h=400&fit=crop'
  },
  {
    SanPhamID: 'SP006',
    TenSanPham: 'Giày đá bóng Adidas Predator size 40',
    DanhMucID: 3,
    CoSoID: 1,
    DonViTinh: 'Lượt thuê',
    DonGia: 30000,
    SoLuongTon: 6,
    CanhBaoTon: 3,
    TrangThai: 'Còn hàng',
    GhiChu: 'Giày bóng đá cỏ nhân tạo đinh TF ôm chân cực tốt',
    AnhSanPham: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&h=400&fit=crop'
  },
  {
    SanPhamID: 'SP007',
    TenSanPham: 'Bóng đá thi đấu FIFA Pro UHV 2.05',
    DanhMucID: 2,
    CoSoID: 2,
    DonViTinh: 'Quả',
    DonGia: 450000,
    SoLuongTon: 14,
    CanhBaoTon: 5,
    TrangThai: 'Còn hàng',
    GhiChu: 'Bóng Động Lực chính hãng đạt chuẩn thi đấu FIFA Pro',
    AnhSanPham: 'https://images.unsplash.com/photo-1614632537190-23e4146777db?w=400&h=400&fit=crop'
  },
  {
    SanPhamID: 'SP008',
    TenSanPham: 'Nước ngọt Coca-Cola lon 320ml',
    DanhMucID: 1,
    CoSoID: 2,
    DonViTinh: 'Lon',
    DonGia: 12000,
    SoLuongTon: 110,
    CanhBaoTon: 20,
    TrangThai: 'Còn hàng',
    GhiChu: 'Nước ngọt Coca-Cola mát lạnh sảng khoái tức thì',
    AnhSanPham: 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=400&h=400&fit=crop'
  }
];

// Helper maps
const categories = {
  1: { name: 'Đồ ăn & Nước', code: 'food', color: 'from-blue-50 to-cyan-100', icon: 'local_drink' },
  2: { name: 'Dụng cụ thể thao', code: 'sport', color: 'from-emerald-50 to-teal-100', icon: 'sports_soccer' },
  3: { name: 'Cho thuê', code: 'rent', color: 'from-purple-50 to-pink-100', icon: 'sports_tennis' },
  4: { name: 'Dịch vụ phụ trợ', code: 'svc', color: 'from-sky-50 to-blue-100', icon: 'layers' }
};

const branches = {
  1: 'CNH Sport Vũng Tàu',
  2: 'CNH Sport Bà Rịa'
};

// State Variables
let currentView = 'grid';
let activeCategoryCode = 'all';
let searchKeyword = '';
let selectedCategoryFilter = '';
let selectedBranchFilter = '';
let selectedStatusFilter = '';
let editingProductId = null;
let restockProductId = null;

// Initialize
window.addEventListener('DOMContentLoaded', () => {
  try {
    if (typeof AOS !== 'undefined') {
      AOS.init({ duration: 600, once: true });
    } else {
      document.body.classList.add('no-aos');
      console.warn('AOS is not defined, running in fallback mode (no animations).');
    }
  } catch (e) {
    document.body.classList.add('no-aos');
    console.error('Error initializing AOS:', e);
  }
  bindEvents();
  renderAll();
});

function bindEvents() {
  document.getElementById('searchQuery').addEventListener('input', (e) => {
    searchKeyword = e.target.value.trim().toLowerCase();
    renderAll();
  });

  document.getElementById('filterCategory').addEventListener('change', (e) => {
    selectedCategoryFilter = e.target.value;
    renderAll();
  });

  document.getElementById('filterBranch').addEventListener('change', (e) => {
    selectedBranchFilter = e.target.value;
    renderAll();
  });

  document.getElementById('filterStatus').addEventListener('change', (e) => {
    selectedStatusFilter = e.target.value;
    renderAll();
  });
}

// Global Coordinator
function renderAll() {
  const filtered = getFilteredProducts();
  renderStats();
  renderTabs();
  renderProducts(filtered);
  renderLowStockBanner();
  
  try {
    if (typeof AOS !== 'undefined') {
      AOS.refresh();
    }
  } catch (e) {
    console.error('AOS refresh failed:', e);
  }
}

function renderLowStockBanner() {
  const lowStockCount = products.filter(p => p.SoLuongTon <= p.CanhBaoTon && p.TrangThai !== 'Ngừng kinh doanh').length;
  const banner = document.getElementById('lowStockBanner');
  
  if (lowStockCount > 0) {
    banner.classList.remove('hidden');
    banner.querySelector('p').innerHTML = `<span class="font-semibold">\${lowStockCount} sản phẩm</span> sắp hết hàng (tồn kho &le; cảnh báo). <button onclick="quickFilterLowStock()" class="underline font-medium ml-1 text-amber-700 hover:text-amber-900 transition-colors">Xem ngay</button>`;
  } else {
    banner.classList.add('hidden');
  }
}

function getFilteredProducts() {
  return products.filter(p => {
    if (activeCategoryCode !== 'all') {
      const cat = categories[p.DanhMucID];
      if (!cat || cat.code !== activeCategoryCode) return false;
    }
    if (searchKeyword) {
      const nameMatch = p.TenSanPham.toLowerCase().includes(searchKeyword);
      const codeMatch = p.SanPhamID.toLowerCase().includes(searchKeyword);
      if (!nameMatch && !codeMatch) return false;
    }
    if (selectedCategoryFilter) {
      if (p.DanhMucID.toString() !== selectedCategoryFilter) return false;
    }
    if (selectedBranchFilter) {
      if (p.CoSoID.toString() !== selectedBranchFilter) return false;
    }
    if (selectedStatusFilter) {
      if (p.TrangThai !== selectedStatusFilter) return false;
    }
    return true;
  });
}

function renderStats() {
  const totalSku = products.length;
  const activeStock = products.filter(p => p.TrangThai === 'Còn hàng').length;
  const warningStock = products.filter(p => p.TrangThai === 'Sắp hết' || (p.SoLuongTon <= p.CanhBaoTon && p.SoLuongTon > 0 && p.TrangThai !== 'Ngừng kinh doanh')).length;
  const outOfStock = products.filter(p => p.TrangThai === 'Hết hàng' || p.SoLuongTon === 0).length;

  const statsContainer = document.querySelector('.grid.grid-cols-2.sm\\:grid-cols-4.gap-3');
  if (statsContainer) {
    statsContainer.innerHTML = `
      <div class="card p-4 flex items-center gap-3 hover:shadow-md transition-shadow" style="animation: fadeUp 0.3s ease-out both">
        <div class="w-9 h-9 rounded-lg bg-zinc-100 flex items-center justify-center"><span class="material-symbols-outlined text-[18px] text-zinc-600">inventory_2</span></div>
        <div><p class="text-xs text-zinc-500">Tổng SKU</p><p class="text-xl font-bold text-zinc-900">\${totalSku}</p></div>
      </div>
      <div class="card p-4 flex items-center gap-3 hover:shadow-md transition-shadow" style="animation: fadeUp 0.3s ease-out both; animation-delay: 50ms">
        <div class="w-9 h-9 rounded-lg bg-green-50 flex items-center justify-center"><span class="material-symbols-outlined text-[18px] text-green-600">check_circle</span></div>
        <div><p class="text-xs text-zinc-500">Còn hàng</p><p class="text-xl font-bold text-green-600">\${activeStock}</p></div>
      </div>
      <div class="card p-4 flex items-center gap-3 hover:shadow-md transition-shadow" style="animation: fadeUp 0.3s ease-out both; animation-delay: 100ms">
        <div class="w-9 h-9 rounded-lg bg-amber-50 flex items-center justify-center"><span class="material-symbols-outlined text-[18px] text-amber-600">warning</span></div>
        <div><p class="text-xs text-zinc-500">Sắp hết</p><p class="text-xl font-bold text-amber-600">\${warningStock}</p></div>
      </div>
      <div class="card p-4 flex items-center gap-3 hover:shadow-md transition-shadow" style="animation: fadeUp 0.3s ease-out both; animation-delay: 150ms">
        <div class="w-9 h-9 rounded-lg bg-red-50 flex items-center justify-center"><span class="material-symbols-outlined text-[18px] text-red-600">error</span></div>
        <div><p class="text-xs text-zinc-500">Hết hàng</p><p class="text-xl font-bold text-red-500">\${outOfStock}</p></div>
      </div>
    `;
  }
}

function renderTabs() {
  const tabsContainer = document.getElementById('catTabs');
  if (!tabsContainer) return;

  const countForCode = (code) => {
    if (code === 'all') return products.length;
    return products.filter(p => categories[p.DanhMucID] && categories[p.DanhMucID].code === code).length;
  };

  const getTabClass = (code) => {
    const isSelected = activeCategoryCode === code;
    return `tab-btn flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-sm font-medium whitespace-nowrap transition-all duration-150 \${
      isSelected ? 'bg-zinc-900 text-white shadow-sm' : 'text-zinc-500 hover:bg-zinc-100 hover:text-zinc-900'
    }`;
  };

  tabsContainer.innerHTML = `
    <button onclick="setTab(this,'all')" class="\${getTabClass('all')}">Tất cả <span class="text-xs opacity-75">(\${countForCode('all')})</span></button>
    <button onclick="setTab(this,'food')" class="\${getTabClass('food')}">Đồ ăn & Nước <span class="text-xs opacity-75">(\${countForCode('food')})</span></button>
    <button onclick="setTab(this,'sport')" class="\${getTabClass('sport')}">Dụng cụ thể thao <span class="text-xs opacity-75">(\${countForCode('sport')})</span></button>
    <button onclick="setTab(this,'rent')" class="\${getTabClass('rent')}">Cho thuê <span class="text-xs opacity-75">(\${countForCode('rent')})</span></button>
    <button onclick="setTab(this,'svc')" class="\${getTabClass('svc')}">Dịch vụ phụ trợ <span class="text-xs opacity-75">(\${countForCode('svc')})</span></button>
  `;
}

function setTab(btn, code) {
  activeCategoryCode = code;
  renderAll();
}

function setProductView(v) {
  currentView = v;
  const grid = document.getElementById('productGrid');
  const table = document.getElementById('productTable');
  const bg = document.getElementById('viewGridBtn');
  const bt = document.getElementById('viewTableBtn');

  if (v === 'grid') {
    grid.classList.remove('hidden');
    table.classList.add('hidden');
    bg.className = 'px-3 py-1.5 text-sm flex items-center gap-1.5 bg-zinc-900 text-white rounded-lg font-medium';
    bt.className = 'px-3 py-1.5 text-sm flex items-center gap-1.5 text-zinc-500 hover:bg-zinc-100 hover:text-zinc-900 rounded-lg transition-colors';
  } else {
    table.classList.remove('hidden');
    grid.classList.add('hidden');
    bt.className = 'px-3 py-1.5 text-sm flex items-center gap-1.5 bg-zinc-900 text-white rounded-lg font-medium';
    bg.className = 'px-3 py-1.5 text-sm flex items-center gap-1.5 text-zinc-500 hover:bg-zinc-100 hover:text-zinc-900 rounded-lg transition-colors';
  }
}

function renderProducts(list) {
  const grid = document.getElementById('productGrid');
  const tableBody = document.getElementById('productTableBody');
  const viewInfo = document.querySelector('.flex.items-center.justify-between p.text-xs.text-zinc-500');

  if (viewInfo) {
    viewInfo.innerHTML = `Hiển thị <span class="font-semibold text-zinc-700">\${list.length} / \${products.length}</span> sản phẩm`;
  }

  if (list.length === 0) {
    const emptyHtml = `
      <div class="col-span-full py-12 flex flex-col items-center justify-center text-center">
        <span class="material-symbols-outlined text-[48px] text-zinc-300">search_off</span>
        <h3 class="text-sm font-semibold text-zinc-800 mt-2.5">Không tìm thấy sản phẩm</h3>
        <p class="text-xs text-zinc-500 mt-1 max-w-[280px]">Vui lòng thay đổi từ khóa hoặc bộ lọc của bạn để thử lại.</p>
      </div>
    `;
    grid.innerHTML = emptyHtml;
    if (tableBody) tableBody.innerHTML = `<tr><td colspan="8" class="text-center py-10 text-zinc-400 text-xs">Không tìm thấy sản phẩm nào.</td></tr>`;
    return;
  }

  const getBadgeClass = (status) => {
    switch (status) {
      case 'Còn hàng': return 'badge-green';
      case 'Sắp hết': return 'badge-amber';
      case 'Hết hàng': return 'badge-red';
      default: return 'badge-gray';
    }
  };

  grid.innerHTML = list.map(p => {
    const cat = categories[p.DanhMucID] || { name: 'Chưa phân loại', color: 'from-zinc-50 to-zinc-100', icon: 'inventory' };
    const branchName = branches[p.CoSoID] || 'Toàn quốc';
    const isWarning = p.SoLuongTon <= p.CanhBaoTon && p.TrangThai !== 'Ngừng kinh doanh';
    const statusText = isWarning ? (p.SoLuongTon === 0 ? 'Hết hàng' : 'Sắp hết') : p.TrangThai;
    const badgeClass = getBadgeClass(statusText);

    return `
      <div class="group relative card overflow-hidden hover:shadow-xl hover:-translate-y-0.5 transition-all duration-200 \${isWarning ? 'ring-2 ring-amber-300' : ''}" style="animation: fadeUp 0.35s cubic-bezier(0.16, 1, 0.3, 1) both">
        <div class="absolute top-2.5 left-2.5 z-10 flex flex-col gap-1 items-start">
          <span class="text-[9px] font-bold bg-white/95 backdrop-blur px-2 py-0.5 rounded-md text-zinc-700 shadow-sm border border-zinc-200/50">\${p.SanPhamID}</span>
          <span class="text-[8px] font-bold bg-zinc-900/90 backdrop-blur px-1.5 py-0.5 rounded text-white shadow-sm flex items-center gap-0.5"><span class="material-symbols-outlined text-[9px]">domain</span>\${branchName.replace('CNH Sport ', '')}</span>
        </div>
        <div class="absolute top-2.5 right-2.5 z-10"><span class="badge \${badgeClass} shadow-sm">\${isWarning && p.SoLuongTon > 0 ? '⚠ Sắp hết' : statusText}</span></div>
        <div class="relative h-44 bg-gradient-to-br \${cat.color} overflow-hidden flex items-center justify-center border-b border-zinc-100">
          <img src="\${p.AnhSanPham}" alt="\${p.TenSanPham}" class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500" onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
          <div class="hidden absolute inset-0 items-center justify-center"><span class="material-symbols-outlined text-[60px] text-zinc-300">\${cat.icon}</span></div>
        </div>
        <div class="p-3.5 flex flex-col justify-between flex-1">
          <div>
            <p class="text-[9px] font-bold text-zinc-400 uppercase tracking-wider mb-0.5">\${cat.name}</p>
            <h3 class="text-sm font-semibold text-zinc-900 truncate mb-2" title="\${p.TenSanPham}">\${p.TenSanPham}</h3>
            <div class="flex items-end justify-between mb-3">
              <div>
                <p class="text-base font-black text-zinc-900">\${p.DonGia.toLocaleString('vi-VN')}<span class="text-xs font-normal text-zinc-500"> đ</span></p>
                <p class="text-[9px] text-zinc-400">/\${p.DonViTinh}</p>
              </div>
              <div class="text-right">
                <p class="text-[9px] text-zinc-400">Tồn kho</p>
                <p class="text-sm font-black \${isWarning ? 'text-amber-600' : p.SoLuongTon === 0 ? 'text-red-500' : 'text-zinc-800'}">\${p.SoLuongTon} <span class="text-[9px] text-zinc-400 font-normal">/ &ge;\${p.CanhBaoTon}</span></p>
              </div>
            </div>
            <div class="w-full h-1 bg-zinc-100 rounded-full overflow-hidden mb-3">
              <div class="h-full rounded-full \${isWarning ? 'bg-amber-500' : p.SoLuongTon === 0 ? 'bg-red-500' : 'bg-green-500'}" style="width: \${Math.min(100, (p.SoLuongTon / (p.CanhBaoTon * 3)) * 100)}%"></div>
            </div>
          </div>
          <div class="flex items-center gap-1.5 pt-1.5 border-t border-zinc-50">
            <button onclick="openRestockModal('\${p.SanPhamID}')" class="flex-1 h-8 rounded-lg bg-zinc-900 text-white text-xs font-bold hover:bg-zinc-800 flex items-center justify-center gap-1 transition-all active:scale-95"><span class="material-symbols-outlined text-[14px]">add_box</span>Nhập</button>
            <button onclick="openEditProductModal('\${p.SanPhamID}')" class="h-8 w-8 rounded-lg border border-zinc-200 hover:bg-zinc-50 text-zinc-500 flex items-center justify-center transition-colors"><span class="material-symbols-outlined text-[14px]">edit</span></button>
            <button onclick="deleteProduct('\${p.SanPhamID}')" class="h-8 w-8 rounded-lg border border-zinc-200 hover:bg-red-50 hover:border-red-200 text-red-400 flex items-center justify-center transition-colors"><span class="material-symbols-outlined text-[14px]">delete</span></button>
          </div>
        </div>
      </div>
    `;
  }).join('');

  if (tableBody) {
    tableBody.innerHTML = list.map(p => {
      const cat = categories[p.DanhMucID] || { name: 'Chưa phân loại', color: 'from-zinc-50 to-zinc-100', icon: 'inventory' };
      const branchName = branches[p.CoSoID] || 'Toàn quốc';
      const isWarning = p.SoLuongTon <= p.CanhBaoTon && p.TrangThai !== 'Ngừng kinh doanh';
      const statusText = isWarning ? (p.SoLuongTon === 0 ? 'Hết hàng' : 'Sắp hết') : p.TrangThai;
      const badgeClass = getBadgeClass(statusText);

      return `
        <tr class="hover:bg-zinc-50">
          <td class="px-4 py-3 font-mono text-xs text-zinc-500">\${p.SanPhamID}</td>
          <td class="px-4 py-3">
            <div class="flex items-center gap-3">
              <div class="w-10 h-10 rounded-lg overflow-hidden bg-zinc-50 shrink-0 border border-zinc-100 flex items-center justify-center">
                <img src="\${p.AnhSanPham}" class="w-full h-full object-cover" onerror="this.style.display='none';this.nextElementSibling.style.display='flex'">
                <span class="hidden material-symbols-outlined text-[20px] text-zinc-400">\${cat.icon}</span>
              </div>
              <div>
                <p class="font-semibold text-zinc-950">\${p.TenSanPham}</p>
                <p class="text-[10px] text-zinc-400">\${branchName.replace('CNH Sport ', '')}</p>
              </div>
            </div>
          </td>
          <td class="px-4 py-3 text-zinc-650 hidden sm:table-cell text-xs">\${cat.name}</td>
          <td class="px-4 py-3 text-right font-semibold text-zinc-900 hidden md:table-cell text-xs">\${p.DonGia.toLocaleString('vi-VN')} đ</td>
          <td class="px-4 py-3 text-right font-black \${isWarning ? 'text-amber-600' : p.SoLuongTon === 0 ? 'text-red-500' : 'text-zinc-800'} text-xs">\${p.SoLuongTon} <span class="text-[9px] text-zinc-400 font-normal">/ &ge;\${p.CanhBaoTon}</span></td>
          <td class="px-4 py-3 hidden lg:table-cell text-xs">
            <span class="\${isWarning ? 'text-amber-600 font-medium' : 'text-zinc-400'}">
              \${isWarning ? `&ge; ${p.CanhBaoTon} ⚠` : `&ge; \${p.CanhBaoTon}`}
            </span>
          </td>
          <td class="px-4 py-3"><span class="badge \${badgeClass}">\${statusText}</span></td>
          <td class="px-4 py-3 text-right flex items-center justify-end gap-1.5 h-full">
            <button onclick="openRestockModal('\${p.SanPhamID}')" class="p-1 rounded hover:bg-zinc-100 text-zinc-700 transition-colors" title="Nhập kho"><span class="material-symbols-outlined text-[16px]">add_box</span></button>
            <button onclick="openEditProductModal('\${p.SanPhamID}')" class="p-1 rounded hover:bg-zinc-100 text-zinc-700 transition-colors" title="Chỉnh sửa"><span class="material-symbols-outlined text-[16px]">edit</span></button>
            <button onclick="deleteProduct('\${p.SanPhamID}')" class="p-1 rounded hover:bg-red-50 hover:text-red-600 text-red-400 transition-colors" title="Xóa"><span class="material-symbols-outlined text-[16px]">delete</span></button>
          </td>
        </tr>
      `;
    }).join('');
  }
}

function quickFilterLowStock() {
  activeCategoryCode = 'all';
  searchKeyword = '';
  selectedCategoryFilter = '';
  selectedBranchFilter = '';
  selectedStatusFilter = 'Sắp hết';
  
  document.getElementById('searchQuery').value = '';
  document.getElementById('filterCategory').value = '';
  document.getElementById('filterBranch').value = '';
  document.getElementById('filterStatus').value = 'Sắp hết';
  
  renderAll();
}

function triggerToast(title, message) {
  const toast = document.getElementById('successToast');
  document.getElementById('toastTitle').textContent = title;
  document.getElementById('toastMessage').textContent = message;

  toast.classList.remove('opacity-0', 'translate-y-12', 'pointer-events-none');
  toast.classList.add('opacity-100', 'translate-y-0');

  setTimeout(() => {
    toast.classList.add('opacity-0', 'translate-y-12', 'pointer-events-none');
    toast.classList.remove('opacity-100', 'translate-y-0');
  }, 4000);
}

function openAddProductModal() {
  editingProductId = null;
  document.getElementById('modalTitle').textContent = 'Thêm sản phẩm mới';
  document.getElementById('btnSubmitProduct').textContent = 'Thêm mới';
  
  document.getElementById('prodDanhMuc').value = '';
  document.getElementById('prodCoSo').value = '';
  document.getElementById('prodCode').value = '';
  document.getElementById('prodCode').disabled = false;
  document.getElementById('prodUnit').value = '';
  document.getElementById('prodName').value = '';
  document.getElementById('prodPrice').value = '';
  document.getElementById('prodStock').value = '';
  document.getElementById('prodStock').disabled = false;
  document.getElementById('prodAlert').value = '10';
  document.getElementById('prodStatus').value = 'Còn hàng';
  document.getElementById('prodNote').value = '';

  document.getElementById('productModal').classList.remove('hidden');
}

function openEditProductModal(id) {
  const p = products.find(prod => prod.SanPhamID === id);
  if (!p) return;

  editingProductId = id;
  document.getElementById('modalTitle').textContent = `Chỉnh sửa sản phẩm: \${id}`;
  document.getElementById('btnSubmitProduct').textContent = 'Lưu thay đổi';

  document.getElementById('prodDanhMuc').value = p.DanhMucID;
  document.getElementById('prodCoSo').value = p.CoSoID;
  document.getElementById('prodCode').value = p.SanPhamID;
  document.getElementById('prodCode').disabled = true;
  document.getElementById('prodUnit').value = p.DonViTinh;
  document.getElementById('prodName').value = p.TenSanPham;
  document.getElementById('prodPrice').value = p.DonGia;
  document.getElementById('prodStock').value = p.SoLuongTon;
  document.getElementById('prodStock').disabled = true;
  document.getElementById('prodAlert').value = p.CanhBaoTon;
  document.getElementById('prodStatus').value = p.TrangThai;
  document.getElementById('prodNote').value = p.GhiChu || '';

  document.getElementById('productModal').classList.remove('hidden');
}

function closeProductModal() {
  document.getElementById('productModal').classList.add('hidden');
}

function saveProduct() {
  const dId = document.getElementById('prodDanhMuc').value;
  const cId = document.getElementById('prodCoSo').value;
  const code = document.getElementById('prodCode').value.trim().toUpperCase();
  const unit = document.getElementById('prodUnit').value.trim();
  const name = document.getElementById('prodName').value.trim();
  const price = document.getElementById('prodPrice').value;
  const stock = document.getElementById('prodStock').value || 0;
  const alertVal = document.getElementById('prodAlert').value;
  const status = document.getElementById('prodStatus').value;
  const note = document.getElementById('prodNote').value.trim();

  if (!dId || !cId || !code || !unit || !name || !price || !alertVal) {
    alert('Vui lòng điền đầy đủ các thông tin bắt buộc (*)');
    return;
  }

  if (editingProductId) {
    const p = products.find(prod => prod.SanPhamID === editingProductId);
    if (p) {
      p.DanhMucID = parseInt(dId);
      p.CoSoID = parseInt(cId);
      p.DonViTinh = unit;
      p.TenSanPham = name;
      p.DonGia = parseFloat(price);
      p.CanhBaoTon = parseInt(alertVal);
      p.TrangThai = status;
      p.GhiChu = note;
      
      triggerToast('Thành công', `Đã cập nhật sản phẩm \${editingProductId}`);
    }
  } else {
    if (products.some(prod => prod.SanPhamID === code)) {
      alert('Mã sản phẩm đã tồn tại trong kho!');
      return;
    }

    const newProd = {
      SanPhamID: code,
      TenSanPham: name,
      DanhMucID: parseInt(dId),
      CoSoID: parseInt(cId),
      DonViTinh: unit,
      DonGia: parseFloat(price),
      SoLuongTon: parseInt(stock),
      CanhBaoTon: parseInt(alertVal),
      TrangThai: status,
      GhiChu: note,
      AnhSanPham: 'https://images.unsplash.com/photo-1546213290-e1b492ab3eed?w=400&h=400&fit=crop'
    };
    
    products.push(newProd);
    triggerToast('Thành công', `Đã thêm sản phẩm mới \${code}`);
  }

  closeProductModal();
  renderAll();
}

function openRestockModal(id) {
  const p = products.find(prod => prod.SanPhamID === id);
  if (!p) return;

  restockProductId = id;
  document.getElementById('restockName').textContent = `\${p.SanPhamID} — \${p.TenSanPham}`;
  document.getElementById('restockCurrentStock').textContent = `\${p.SoLuongTon} \${p.DonViTinh}`;
  document.getElementById('restockQty').value = '';
  document.getElementById('restockSupplier').value = '';
  document.getElementById('restockNote').value = '';

  document.getElementById('restockModal').classList.remove('hidden');
}

function closeRestockModal() {
  document.getElementById('restockModal').classList.add('hidden');
}

function submitRestock() {
  const qty = document.getElementById('restockQty').value;
  if (!qty || qty <= 0) {
    alert('Vui lòng nhập số lượng nhập thêm hợp lệ (> 0)');
    return;
  }

  const p = products.find(prod => prod.SanPhamID === restockProductId);
  if (p) {
    p.SoLuongTon += parseInt(qty);
    if (p.SoLuongTon > p.CanhBaoTon && p.TrangThai !== 'Ngừng kinh doanh') {
      p.TrangThai = 'Còn hàng';
    }
    triggerToast('Nhập kho thành công', `Đã nhập thêm \${qty} \${p.DonViTinh} vào sản phẩm \${restockProductId}`);
  }

  closeRestockModal();
  renderAll();
}

function deleteProduct(id) {
  const p = products.find(prod => prod.SanPhamID === id);
  if (!p) return;

  if (confirm(`Bạn có chắc chắn muốn xóa sản phẩm/dịch vụ "\${p.TenSanPham}" (\${id}) khỏi cơ sở dữ liệu?`)) {
    products = products.filter(prod => prod.SanPhamID !== id);
    triggerToast('Đã xóa', `Sản phẩm \${id} đã được xóa thành công.`);
    renderAll();
  }
}

document.getElementById('mobileMenuBtn').addEventListener('click', () => {
  document.getElementById('sidebar').classList.toggle('-translate-x-full');
});
</script>


</body>
</html>
