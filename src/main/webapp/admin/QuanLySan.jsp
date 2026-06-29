<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Quản lý sân — Manager</title>
<script src="https://cdn.tailwindcss.com"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200">
<style>
body { font-family: 'Inter', sans-serif; }
  .nav-link { display:flex;align-items:center;gap:11px;padding:10px 14px;border-radius:10px;color:#52525b;font-size:14px;font-weight:500;text-decoration:none;transition:all .15s;white-space:nowrap;position:relative; }
  .nav-link:hover { background:#f4f4f5;color:#18181b; }
  .nav-link.active { background:#f4f4f5;color:#18181b;font-weight:600; }
  .nav-link.active::before { content:''; position:absolute; left:0; top:8px; bottom:8px; width:3px; background:#27272a; border-radius:0 3px 3px 0; }
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

  @media (prefers-reduced-motion: reduce){ *,*::before,*::after{animation:none!important;transition:none!important;} }
</style>
  <link href="https://unpkg.com/aos@2.3.1/dist/aos.css" rel="stylesheet">
</head>
<body class="bg-zinc-50 text-zinc-900 min-h-screen">

<!-- Sidebar -->
<jsp:include page="/admin/common/sidebar.jsp" />

<!-- Header -->
<header class="h-[64px] fixed top-0 right-0 left-0 lg:left-[248px] bg-white/80 backdrop-blur-lg border-b border-zinc-200 z-20 flex items-center justify-between px-4 lg:px-6">
  <div class="flex items-center gap-3">
    <button id="mobileMenuBtn" class="lg:hidden p-2 rounded-lg hover:bg-zinc-100 text-zinc-500"><span class="material-symbols-outlined text-[20px]">menu</span></button>
    <div>
      <h1 class="text-sm font-bold text-zinc-900 tracking-tight">Quản lý sân</h1>
    </div>
  </div>
  <div class="flex items-center gap-1.5">
    <button onclick="switchTab('types')" class="hidden sm:flex items-center gap-1.5 h-9 px-3 rounded-lg border border-zinc-200 hover:bg-zinc-50 text-zinc-600 text-xs font-medium">
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

<!-- Main Container -->
<main class="lg:ml-[248px] mt-[64px] p-4 lg:p-6 flex flex-col gap-5">

  <!-- Header section -->
  <section data-aos="fade-up" class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
    <div>
      <h2 class="text-2xl font-black tracking-tight text-zinc-900">Quản lý sân thi đấu</h2>
      <p class="text-sm text-zinc-500 mt-0.5">Theo dõi tình trạng và cấu hình toàn bộ sân tại Cơ Sở</p>
    </div>
    <div class="flex items-center gap-2">
      <button onclick="switchTab('types')" class="flex items-center gap-1.5 h-10 px-4 rounded-xl bg-white border border-zinc-200 text-sm font-semibold text-zinc-700 hover:bg-zinc-50">
        <span class="material-symbols-outlined text-[16px]">tune</span>Cấu hình giá
      </button>
      <button id="mainActionBtn" onclick="openCreateModal()" class="flex items-center gap-1.5 h-10 px-4 rounded-xl bg-zinc-800 text-white text-sm font-semibold shadow-md shadow-zinc-300 hover:bg-zinc-700">
        <span class="material-symbols-outlined text-[16px]">add</span>Thêm sân mới
      </button>
    </div>
  </section>

  <!-- Navigation Tabs -->
  <section data-aos="fade-up" class="flex border-b border-zinc-200 gap-6">
    <button id="btnTabCourts" onclick="switchTab('courts')" class="pb-3 text-sm font-bold border-b-2 border-blue-600 text-blue-600 flex items-center gap-2 transition-all">
      <span class="material-symbols-outlined text-[18px]">stadium</span>Danh sách sân thi đấu
    </button>
    <button id="btnTabTypes" onclick="switchTab('types')" class="pb-3 text-sm font-medium border-b-2 border-transparent text-zinc-500 hover:text-zinc-800 flex items-center gap-2 transition-all">
      <span class="material-symbols-outlined text-[18px]">payments</span>Cấu hình loại sân & Bảng giá
    </button>
  </section>

  <!-- Branch Filter Section -->
  <section id="branchFilterSection" data-aos="fade-up" class="card p-4 bg-white border border-zinc-200 shadow-sm rounded-2xl flex flex-col gap-3">
    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
      <div class="flex items-center gap-2">
        <div class="w-8 h-8 rounded-xl bg-blue-50 flex items-center justify-center shrink-0">
          <span class="material-symbols-outlined text-[18px] text-blue-700">storefront</span>
        </div>
        <div>
          <h3 class="text-sm font-bold text-zinc-800">Lọc theo Cơ Sở</h3>
          <p class="text-[10px] text-zinc-400 mt-0.5">Chọn các Cơ Sở để xem danh sách sân</p>
        </div>
      </div>
      
      <!-- Search branch and Actions -->
      <div class="flex items-center gap-3 flex-wrap">
        <div class="relative w-48">
          <span class="absolute left-2.5 top-1/2 -translate-y-1/2 material-symbols-outlined text-[13px] text-zinc-400">search</span>
          <input type="text" id="searchBranchInput" oninput="filterBranchCheckboxes()" placeholder="Tìm nhanh Cơ Sở..." class="h-8 w-full pl-8 pr-2.5 rounded-xl border border-zinc-200 text-xs focus:outline-none focus:ring-2 focus:ring-blue-500/30 focus:border-blue-450">
        </div>
        <button onclick="toggleAllBranches(true)" class="text-xs font-semibold text-blue-600 hover:text-blue-700 transition-colors">Chọn tất cả</button>
        <span class="text-zinc-350 text-xs">·</span>
        <button onclick="toggleAllBranches(false)" class="text-xs font-semibold text-zinc-500 hover:text-zinc-750 transition-colors">Bỏ chọn tất cả</button>
      </div>
    </div>
    <div id="branchCheckboxContainer" class="flex items-center gap-2.5 flex-wrap max-h-24 overflow-y-auto pr-1">
      <!-- Generated Dynamically -->
    </div>
  </section>

  <!-- Stats Grid (Dynamically updated) -->
  <section id="statsSection" data-aos="fade-up" class="grid grid-cols-2 sm:grid-cols-4 gap-3">
    <div class="card p-4 hover:shadow-md transition-shadow">
      <div class="flex items-center gap-3">
        <div class="w-10 h-10 rounded-xl bg-blue-50 flex items-center justify-center"><span class="material-symbols-outlined text-[20px] text-blue-700">stadium</span></div>
        <div>
          <p class="text-[11px] text-zinc-500 font-medium">Tổng số sân</p>
          <p id="statTotal" class="text-2xl font-black text-zinc-900">0</p>
        </div>
      </div>
    </div>
    <div class="card p-4 hover:shadow-md transition-shadow">
      <div class="flex items-center gap-3">
        <div class="w-10 h-10 rounded-xl bg-green-50 flex items-center justify-center"><span class="material-symbols-outlined text-[20px] text-green-700">check_circle</span></div>
        <div>
          <p class="text-[11px] text-zinc-500 font-medium">Đang sẵn sàng</p>
          <p id="statReady" class="text-2xl font-black text-green-650">0</p>
        </div>
      </div>
    </div>
    <div class="card p-4 hover:shadow-md transition-shadow">
      <div class="flex items-center gap-3">
        <div class="w-10 h-10 rounded-xl bg-amber-50 flex items-center justify-center"><span class="material-symbols-outlined text-[20px] text-amber-700">build</span></div>
        <div>
          <p class="text-[11px] text-zinc-500 font-medium">Đang bảo trì</p>
          <p id="statMaintenance" class="text-2xl font-black text-amber-600">0</p>
        </div>
      </div>
    </div>
    <div class="card p-4 hover:shadow-md transition-shadow">
      <div class="flex items-center gap-3">
        <div class="w-10 h-10 rounded-xl bg-red-50 flex items-center justify-center"><span class="material-symbols-outlined text-[20px] text-red-650">block</span></div>
        <div>
          <p class="text-[11px] text-zinc-500 font-medium">Tạm đóng</p>
          <p id="statClosed" class="text-2xl font-black text-red-500">0</p>
        </div>
      </div>
    </div>
  </section>

  <!-- Toolbar Section -->
  <section id="toolbarSection" data-aos="fade-up" class="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-3">
    <div class="flex items-center gap-2 flex-wrap">
      <!-- View mode switch -->
      <div class="flex rounded-xl border border-zinc-200 overflow-hidden bg-white">
        <button id="btnViewGrid" onclick="setViewMode('grid')" class="px-3 py-2 text-sm flex items-center gap-1.5 bg-zinc-800 text-white font-semibold">
          <span class="material-symbols-outlined text-[15px]">grid_view</span>Lưới
        </button>
        <button id="btnViewList" onclick="setViewMode('list')" class="px-3 py-2 text-sm flex items-center gap-1.5 text-zinc-500 hover:bg-zinc-50">
          <span class="material-symbols-outlined text-[15px]">list</span>Danh sách
        </button>
      </div>
      <!-- Type Filter -->
      <select id="filterType" onchange="applyFilters()" class="h-10 pl-3 pr-8 rounded-xl border border-zinc-200 bg-white text-sm text-zinc-700 focus:outline-none focus:ring-2 focus:ring-blue-500/30">
        <option value="all">Tất cả môn thể thao</option>
      </select>
      <!-- Status Filter -->
      <select id="filterStatus" onchange="applyFilters()" class="h-10 pl-3 pr-8 rounded-xl border border-zinc-200 bg-white text-sm text-zinc-700 focus:outline-none focus:ring-2 focus:ring-blue-500/30">
        <option value="all">Tất cả trạng thái</option>
        <option value="Sẵn sàng">Sẵn sàng</option>
        <option value="Đang dùng">Đang dùng</option>
        <option value="Bảo trì">Bảo trì</option>
        <option value="Tạm đóng">Tạm đóng</option>
      </select>
    </div>
    <!-- Search Bar -->
    <div class="relative max-w-xs flex-1">
      <span class="absolute left-3 top-1/2 -translate-y-1/2 material-symbols-outlined text-[16px] text-zinc-400">search</span>
      <input type="text" id="searchInput" oninput="applyFilters()" placeholder="Tìm theo mã sân hoặc tên..." class="h-10 w-full pl-9 pr-3 rounded-xl border border-zinc-200 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500/30 focus:border-blue-400">
    </div>
  </section>

  <!-- Court List & Types Grid Layout Containers -->
  <section class="min-h-[400px]">
    <!-- Court Cards (Grid View) -->
    <div id="mainCourtGrid" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
      <!-- Generated Dynamically -->
    </div>

    <!-- Court Table (List View) - hidden by default -->
    <div id="mainCourtList" class="hidden card overflow-hidden bg-white border border-zinc-200 shadow-sm rounded-2xl">
      <div class="overflow-x-auto">
        <table class="w-full text-left border-collapse">
          <thead>
            <tr class="border-b border-zinc-200 text-xs font-bold text-zinc-500 uppercase tracking-wider bg-zinc-50/50">
              <th class="px-5 py-3.5">Mã sân</th>
              <th class="px-5 py-3.5">Tên sân</th>
              <th class="px-5 py-3.5">Loại sân / Bộ môn</th>
              <th class="px-5 py-3.5">Giá không đèn / Có đèn</th>
              <th class="px-5 py-3.5">Thời gian lên đèn</th>
              <th class="px-5 py-3.5">Trạng thái</th>
              <th class="px-5 py-3.5 text-right">Thao tác</th>
            </tr>
          </thead>
          <tbody id="courtListTableBody" class="divide-y divide-zinc-100 text-xs text-zinc-700">
            <!-- Generated Dynamically -->
          </tbody>
        </table>
      </div>
    </div>

    <!-- Pricing and Court Types View (Tab 2) - hidden by default -->
    <div id="pricingTypesView" class="hidden card overflow-hidden bg-white border border-zinc-200 shadow-sm rounded-2xl">
      <div class="p-4 border-b border-zinc-150 flex items-center justify-between">
        <div>
          <h3 class="text-sm font-bold text-zinc-800">Cấu hình Loại sân & Bảng giá giờ lên đèn</h3>
          <p class="text-[11px] text-zinc-400">Điều chỉnh biểu phí giờ bật đèn riêng cho từng môn thể thao</p>
        </div>
        <button onclick="openCreateTypeModal()" class="flex items-center gap-1.5 h-8 px-3 rounded-lg bg-zinc-850 hover:bg-zinc-750 text-white text-[11px] font-bold transition-all shadow-sm">
          <span class="material-symbols-outlined text-[14px]">add</span>Thêm loại sân mới
        </button>
      </div>
      <div class="overflow-x-auto">
        <table class="w-full text-left border-collapse">
          <thead>
            <tr class="border-b border-zinc-200 text-xs font-bold text-zinc-500 uppercase tracking-wider bg-zinc-50/50">
              <th class="px-5 py-3.5">Mã Loại</th>
              <th class="px-5 py-3.5">Tên Loại Sân</th>
              <th class="px-5 py-3.5">Bộ môn</th>
              <th class="px-5 py-3.5">Cơ Sở</th>
              <th class="px-5 py-3.5">Giá không đèn (Tiêu chuẩn)</th>
              <th class="px-5 py-3.5">Giá có đèn (Tối)</th>
              <th class="px-5 py-3.5">Giờ bắt đầu lên đèn</th>
              <th class="px-5 py-3.5 text-right">Thao tác</th>
            </tr>
          </thead>
          <tbody id="typeListTableBody" class="divide-y divide-zinc-100 text-xs text-zinc-700">
            <!-- Generated Dynamically -->
          </tbody>
        </table>
      </div>
    </div>
  </section>

  <!-- Empty State Placeholder -->
  <section id="emptyState" class="hidden flex-col items-center justify-center p-12 text-center bg-white rounded-3xl border border-dashed border-zinc-200">
    <span class="material-symbols-outlined text-[48px] text-zinc-300">stadium</span>
    <p class="text-sm font-bold text-zinc-800 mt-2">Không tìm thấy sân thi đấu nào</p>
    <p class="text-xs text-zinc-400 mt-0.5">Vui lòng điều chỉnh bộ lọc hoặc tạo thêm sân thi đấu mới.</p>
  </section>

</main>

<!-- Modal: Tạo lịch đặt mới (Liên kết với receptionist dashboard) -->
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

          <!-- Court Grid Selection inside Modal -->
          <div>
            <div class="flex items-center justify-between mb-1.5">
              <label class="text-[11px] font-bold text-zinc-600">Chọn sân thi đấu cụ thể <span class="text-red-500">*</span></label>
              <span class="text-[10px] text-zinc-400 font-medium">Bấm vào sân trống để chọn</span>
            </div>
            
            <div id="modalCourtGrid" class="grid grid-cols-2 sm:grid-cols-4 gap-2.5">
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
<div id="successToast" class="fixed bottom-6 right-6 bg-zinc-900 text-white rounded-2xl p-4 shadow-2xl border border-zinc-800 z-[99] flex items-start gap-3 transition-all duration-300 translate-y-12 opacity-0 pointer-events-none w-80">
  <div class="w-8 h-8 rounded-full bg-emerald-500/20 text-emerald-400 flex items-center justify-center shrink-0">
    <span class="material-symbols-outlined text-[18px]">check</span>
  </div>
  <div class="flex-1">
    <h4 class="text-xs font-bold text-zinc-100">Thành công!</h4>
    <p id="successToastMessage" class="text-[10px] text-zinc-400 mt-0.5">Thao tác được thực hiện thành công.</p>
  </div>
</div>

<!-- Modal 1: Thêm/Sửa sân (`courtModal`) -->
<div id="courtModal" class="hidden fixed inset-0 z-[80] flex items-center justify-center p-4">
  <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" onclick="closeCourtModal()"></div>
  <div class="relative bg-white rounded-3xl shadow-2xl w-full max-w-[480px] max-h-[92vh] overflow-y-auto border border-zinc-200">
    <div class="flex items-center justify-between px-6 py-4 border-b border-zinc-100">
      <div>
        <h2 id="courtModalTitle" class="text-base font-bold text-zinc-900">Thêm sân mới</h2>
        <p class="text-xs text-zinc-500 mt-0.5">Tạo sân thi đấu mới cho Cơ Sở CS01</p>
      </div>
      <button onclick="closeCourtModal()" class="p-1.5 rounded-lg hover:bg-zinc-100"><span class="material-symbols-outlined text-[18px] text-zinc-500">close</span></button>
    </div>
    <div class="px-6 py-4 flex flex-col gap-4">
      <input type="hidden" id="courtEditId">
      <div class="grid grid-cols-2 gap-3">
        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-semibold text-zinc-700">Mã sân *</label>
          <input type="text" id="courtCode" placeholder="VD: SAN016" class="h-10 px-3 rounded-xl border border-zinc-200 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500/30 focus:border-blue-400">
        </div>
        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-semibold text-zinc-700">Tên sân *</label>
          <input type="text" id="courtName" placeholder="Tên hiển thị" class="h-10 px-3 rounded-xl border border-zinc-200 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500/30 focus:border-blue-400">
        </div>
      </div>
      <div class="flex flex-col gap-1.5">
        <label class="text-xs font-semibold text-zinc-700">Cơ Sở *</label>
        <select id="courtBranchSelect" class="h-10 px-3 rounded-xl border border-zinc-200 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500/30 focus:border-blue-400">
          <!-- Populated dynamically -->
        </select>
      </div>
      <div class="flex flex-col gap-1.5">
        <label class="text-xs font-semibold text-zinc-700">Loại sân * <span class="text-zinc-400 font-normal">· LoaiSan Table</span></label>
        <select id="courtTypeSelect" class="h-10 px-3 rounded-xl border border-zinc-200 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500/30 focus:border-blue-400">
          <!-- Populated dynamically -->
        </select>
      </div>
      <div class="flex flex-col gap-1.5">
        <label class="text-xs font-semibold text-zinc-700">Trạng thái *</label>
        <select id="courtStatus" class="h-10 px-3 rounded-xl border border-zinc-200 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500/30 focus:border-blue-400">
          <option value="Sẵn sàng">Sẵn sàng</option>
          <option value="Đang dùng">Đang dùng</option>
          <option value="Bảo trì">Bảo trì</option>
          <option value="Tạm đóng">Tạm đóng</option>
        </select>
      </div>
      <div class="flex flex-col gap-1.5">
        <label class="text-xs font-semibold text-zinc-700">Mô tả chi tiết</label>
        <textarea id="courtDesc" rows="3" placeholder="Sân cỏ chất lượng tốt, đầy đủ ánh sáng..." class="px-3 py-2 rounded-xl border border-zinc-200 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500/30 focus:border-blue-400 resize-none"></textarea>
      </div>
      <div class="flex flex-col gap-1.5">
        <label class="text-xs font-semibold text-zinc-700">Ảnh sân (Để trống để tự động lấy ảnh mẫu theo bộ môn)</label>
        <input type="text" id="courtImage" placeholder="https://unsplash.com/..." class="h-10 px-3 rounded-xl border border-zinc-200 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500/30 focus:border-blue-400">
      </div>
    </div>
    <div class="px-6 py-4 border-t border-zinc-100 flex justify-end gap-2 bg-zinc-50/50">
      <button onclick="closeCourtModal()" class="h-10 px-4 rounded-xl border border-zinc-200 text-sm font-semibold text-zinc-700 hover:bg-zinc-50">Hủy</button>
      <button id="saveCourtBtn" onclick="saveCourt()" class="h-10 px-5 rounded-xl bg-zinc-800 text-white text-sm font-semibold shadow-md shadow-zinc-300 hover:bg-zinc-700">Thêm sân</button>
    </div>
  </div>
</div>

<!-- Modal 2: Thêm/Sửa loại sân & Bảng giá (`typeModal`) -->
<div id="typeModal" class="hidden fixed inset-0 z-[80] flex items-center justify-center p-4">
  <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" onclick="closeTypeModal()"></div>
  <div class="relative bg-white rounded-3xl shadow-2xl w-full max-w-[480px] max-h-[92vh] overflow-y-auto border border-zinc-200">
    <div class="flex items-center justify-between px-6 py-4 border-b border-zinc-100">
      <div>
        <h2 id="typeModalTitle" class="text-base font-bold text-zinc-900">Thêm loại sân mới</h2>
        <p class="text-xs text-zinc-500 mt-0.5">Thiết lập bộ môn, bảng giá và giờ lên đèn</p>
      </div>
      <button onclick="closeTypeModal()" class="p-1.5 rounded-lg hover:bg-zinc-100"><span class="material-symbols-outlined text-[18px] text-zinc-500">close</span></button>
    </div>
    <div class="px-6 py-4 flex flex-col gap-4">
      <input type="hidden" id="typeEditId">
      <div class="flex flex-col gap-1.5">
        <label class="text-xs font-semibold text-zinc-700">Môn thể thao *</label>
        <select id="typeSportSelect" class="h-10 px-3 rounded-xl border border-zinc-200 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500/30 focus:border-blue-400">
          <!-- Will populate based on mockSports -->
        </select>
      </div>
      <div class="flex flex-col gap-1.5">
        <label class="text-xs font-semibold text-zinc-700">Cơ Sở *</label>
        <select id="typeBranchSelect" class="h-10 px-3 rounded-xl border border-zinc-200 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500/30 focus:border-blue-400">
          <!-- Populated dynamically -->
        </select>
      </div>
      <div class="flex flex-col gap-1.5">
        <label class="text-xs font-semibold text-zinc-700">Tên loại sân *</label>
        <input type="text" id="typeName" placeholder="VD: Sân bóng đá 7 người" class="h-10 px-3 rounded-xl border border-zinc-200 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500/30 focus:border-blue-400">
      </div>
      <div class="grid grid-cols-2 gap-3">
        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-semibold text-zinc-700">Giá ngày (Không đèn) *</label>
          <div class="relative">
            <input type="text" id="typePriceNoLight" placeholder="150,000" class="h-10 w-full pl-3 pr-10 rounded-xl border border-zinc-200 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500/30 focus:border-blue-400">
            <span class="absolute right-3 top-1/2 -translate-y-1/2 text-xs font-semibold text-zinc-450">đ</span>
          </div>
        </div>
        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-semibold text-zinc-700">Giá tối (Có đèn phụ thu) *</label>
          <div class="relative">
            <input type="text" id="typePriceWithLight" placeholder="200,000" class="h-10 w-full pl-3 pr-10 rounded-xl border border-zinc-200 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500/30 focus:border-blue-400">
            <span class="absolute right-3 top-1/2 -translate-y-1/2 text-xs font-semibold text-zinc-450">đ</span>
          </div>
        </div>
      </div>
      <div class="flex flex-col gap-1.5">
        <label class="text-xs font-semibold text-zinc-700">Giờ bắt đầu lên đèn *</label>
        <input type="time" id="typeLightStart" value="17:30" class="h-10 px-3 rounded-xl border border-zinc-200 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500/30 focus:border-blue-400">
        <p class="text-[10px] text-zinc-450 mt-1">💡 Đối với loại sân trong nhà như Cầu lông, vui lòng chọn <span class="font-semibold">06:00</span> để đèn bật 100% full ca (Không phụ thu thêm hoặc đã tính thẳng vào giá sân).</p>
      </div>
    </div>
    <div class="px-6 py-4 border-t border-zinc-100 flex justify-end gap-2 bg-zinc-50/50">
      <button onclick="closeTypeModal()" class="h-10 px-4 rounded-xl border border-zinc-200 text-sm font-semibold text-zinc-700 hover:bg-zinc-50">Hủy</button>
      <button id="saveTypeBtn" onclick="saveType()" class="h-10 px-5 rounded-xl bg-zinc-800 text-white text-sm font-semibold shadow-md shadow-zinc-300 hover:bg-zinc-700">Lưu lại</button>
    </div>
  </div>
</div>

<script src="https://unpkg.com/aos@2.3.1/dist/aos.js"></script>
<script>
  AOS.init({ duration: 600, once: true });

  // Sidebar mobile menu toggle
  document.getElementById('mobileMenuBtn').addEventListener('click', () => {
    document.getElementById('sidebar').classList.toggle('-translate-x-full');
  });

  // -------------------------------------------------------------
  // MOCK DATA: Synced perfectly with QuanLiSport_V4 Database schema
  // -------------------------------------------------------------
  
  const mockSports = [
    <c:forEach items="${dsMonTheThao}" var="m" varStatus="loop">
    { id: ${m.monTheThaoID}, name: '${m.tenMon}', icon: '${m.tenMon == "Bóng đá" ? "sports_soccer" : (m.tenMon == "Cầu lông" ? "sports_tennis" : (m.tenMon == "Pickleball" ? "sports_kabaddi" : "sports_tennis"))}' }${!loop.last ? ',' : ''}
    </c:forEach>
  ];

  let mockLoaiSan = [
    <c:forEach items="${dsLoaiSan}" var="l" varStatus="loop">
    { id: ${l.loaiSanID}, sportId: ${l.monTheThaoID}, name: '${l.tenLoai}', priceNoLight: ${l.giaKhongDen}, priceWithLight: ${l.giaCoDen}, lightStart: '${l.gioBatDauLenDen}', coSoId: ${l.coSoID != null ? l.coSoID : 'null'} }${!loop.last ? ',' : ''}
    </c:forEach>
  ];

  let mockSan = [
    <c:forEach items="${dsSan}" var="s" varStatus="loop">
    { id: ${s.sanID}, typeId: ${s.loaiSanID}, coSoId: ${s.coSoID}, code: 'SAN' + ${s.sanID}, name: '${s.tenSan}', status: '${s.trangThai}', desc: '${s.moTa}', image: '${s.hinhAnh}' }${!loop.last ? ',' : ''}
    </c:forEach>
  ];

  const branches = [
    <c:forEach items="${dsCoSo}" var="c" varStatus="loop">
    { id: ${c.coSoID}, name: '${c.tenCoSo}', sports: '${c.loaiHinhKinhDoanh}' }${!loop.last ? ',' : ''}
    </c:forEach>
  ];

  // Presets of Unsplash sports images
  const sportImages = {
    1: 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?w=500&h=300&fit=crop',
    2: 'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=500&h=300&fit=crop',
    3: 'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?w=500&h=300&fit=crop',
    4: 'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?w=500&h=300&fit=crop'
  };

  // State Management
  let currentTab = 'courts'; // 'courts' or 'types'
  let viewMode = 'grid'; // 'grid' or 'list'

  // Smart Real-time Currency Formatter (Retains cursor position)
  function initCurrencyFormatter(inputId) {
    const input = document.getElementById(inputId);
    if (!input) return;
    input.addEventListener('input', (e) => {
      let value = e.target.value.replace(/,/g, '').replace(/[^0-9]/g, '');
      if (value === '') {
        e.target.value = '';
        return;
      }
      let num = parseInt(value, 10);
      let cursorPosition = e.target.selectionStart;
      const originalLength = e.target.value.length;
      const formatted = num.toLocaleString('en-US');
      e.target.value = formatted;
      const newLength = formatted.length;
      cursorPosition = cursorPosition + (newLength - originalLength);
      e.target.setSelectionRange(cursorPosition, cursorPosition);
    });
  }

  // Parse thousands formatted numbers back to pure integers
  function parseFormattedNumber(val) {
    return parseInt(val.replace(/,/g, ''), 10) || 0;
  }

  // Initialize page components
  document.addEventListener('DOMContentLoaded', () => {
    initCurrencyFormatter('typePriceNoLight');
    initCurrencyFormatter('typePriceWithLight');
    populateSportDropdowns();
    
    const branchSelect = document.getElementById('courtBranchSelect');
    if (branchSelect) {
      branchSelect.addEventListener('change', filterCourtTypesByBranch);
    }
    
    renderBranchFilters();
    onBranchFilterChange();
  });

  // Switch tabs
  function switchTab(tab) {
    currentTab = tab;
    const btnTabCourts = document.getElementById('btnTabCourts');
    const btnTabTypes = document.getElementById('btnTabTypes');
    const mainActionBtn = document.getElementById('mainActionBtn');
    
    const toolbar = document.getElementById('toolbarSection');
    const stats = document.getElementById('statsSection');
    const gridContainer = document.getElementById('mainCourtGrid');
    const listContainer = document.getElementById('mainCourtList');
    const pricingView = document.getElementById('pricingTypesView');

    if (tab === 'courts') {
      btnTabCourts.className = 'pb-3 text-sm font-bold border-b-2 border-blue-600 text-blue-600 flex items-center gap-2 transition-all';
      btnTabTypes.className = 'pb-3 text-sm font-medium border-b-2 border-transparent text-zinc-500 hover:text-zinc-800 flex items-center gap-2 transition-all';
      mainActionBtn.innerHTML = `<span class="material-symbols-outlined text-[16px]">add</span>Thêm sân mới`;
      mainActionBtn.setAttribute('onclick', 'openCreateModal()');
      
      toolbar.classList.remove('hidden');
      stats.classList.remove('hidden');
      pricingView.classList.add('hidden');
      setViewMode(viewMode);
    } else {
      btnTabTypes.className = 'pb-3 text-sm font-bold border-b-2 border-blue-600 text-blue-600 flex items-center gap-2 transition-all';
      btnTabCourts.className = 'pb-3 text-sm font-medium border-b-2 border-transparent text-zinc-500 hover:text-zinc-800 flex items-center gap-2 transition-all';
      mainActionBtn.innerHTML = `<span class="material-symbols-outlined text-[16px]">playlist_add</span>Thêm loại sân`;
      mainActionBtn.setAttribute('onclick', 'openCreateTypeModal()');

      toolbar.classList.add('hidden');
      stats.classList.add('hidden');
      gridContainer.classList.add('hidden');
      listContainer.classList.add('hidden');
      pricingView.classList.remove('hidden');
      document.getElementById('emptyState').classList.add('hidden');
      renderTypesList();
    }
  }

  // View Mode toggling
  function setViewMode(mode) {
    viewMode = mode;
    const btnGrid = document.getElementById('btnViewGrid');
    const btnList = document.getElementById('btnViewList');
    const mainCourtGrid = document.getElementById('mainCourtGrid');
    const mainCourtList = document.getElementById('mainCourtList');

    if (currentTab !== 'courts') return;

    if (mode === 'grid') {
      btnGrid.className = 'px-3 py-2 text-sm flex items-center gap-1.5 bg-zinc-800 text-white font-semibold';
      btnList.className = 'px-3 py-2 text-sm flex items-center gap-1.5 text-zinc-500 hover:bg-zinc-50';
      mainCourtGrid.classList.remove('hidden');
      mainCourtList.classList.add('hidden');
    } else {
      btnList.className = 'px-3 py-2 text-sm flex items-center gap-1.5 bg-zinc-800 text-white font-semibold';
      btnGrid.className = 'px-3 py-2 text-sm flex items-center gap-1.5 text-zinc-500 hover:bg-zinc-50';
      mainCourtGrid.classList.add('hidden');
      mainCourtList.classList.remove('hidden');
    }
    renderCourts();
  }

  // Populate dynamic sports & types options
  function populateSportDropdowns() {
    const sportSelect = document.getElementById('typeSportSelect');
    sportSelect.innerHTML = mockSports.map(s => `<option value="${s.id}">${s.name}</option>`).join('');

    const courtTypeSelect = document.getElementById('courtTypeSelect');
    courtTypeSelect.innerHTML = mockLoaiSan.map(l => `<option value="${l.id}">${l.name}</option>`).join('');

    const courtBranchSelect = document.getElementById('courtBranchSelect');
    if (courtBranchSelect) {
      courtBranchSelect.innerHTML = branches.map(b => `<option value="${b.id}">${b.name}</option>`).join('');
    }

    const typeBranchSelect = document.getElementById('typeBranchSelect');
    if (typeBranchSelect) {
      typeBranchSelect.innerHTML = branches.map(b => `<option value="${b.id}">${b.name}</option>`).join('');
    }
  }

  function filterCourtTypesByBranch() {
    const branchSelect = document.getElementById('courtBranchSelect');
    const typeSelect = document.getElementById('courtTypeSelect');
    if (!branchSelect || !typeSelect) return;
    
    const branchId = parseInt(branchSelect.value, 10);
    // Filter types that have either no coSoId (global) or coSoId matching selected branch
    const filteredTypes = mockLoaiSan.filter(l => !l.coSoId || l.coSoId === branchId);
    
    typeSelect.innerHTML = filteredTypes.map(l => `<option value="${l.id}">${l.name}</option>`).join('');
  }

  function filterBranchCheckboxes() {
    const query = document.getElementById('searchBranchInput').value.toLowerCase().trim();
    const labels = document.querySelectorAll('#branchCheckboxContainer label');
    labels.forEach(label => {
      const name = label.querySelector('span').innerText.toLowerCase();
      if (name.includes(query)) {
        label.classList.remove('hidden');
      } else {
        label.classList.add('hidden');
      }
    });
  }

  function renderBranchFilters() {
    const container = document.getElementById('branchCheckboxContainer');
    if (!container) return;
    container.innerHTML = branches.map(b => `
      <label class="flex items-center gap-2 bg-zinc-50 border border-zinc-200 hover:border-zinc-300 hover:bg-zinc-100/50 px-3.5 py-2 rounded-xl text-xs font-semibold text-zinc-700 cursor-pointer select-none transition-all active:scale-98">
        <input type="checkbox" name="filterBranch" value="\${b.id}" checked onchange="onBranchFilterChange()" class="w-4 h-4 rounded text-blue-600 focus:ring-blue-500/30 border-zinc-300">
        <span>\${b.name}</span>
      </label>
    `).join('');
  }

  function updateSportFilters() {
    const checkedBranchCheckboxes = document.querySelectorAll('input[name="filterBranch"]:checked');
    const selectedBranchIds = Array.from(checkedBranchCheckboxes).map(cb => parseInt(cb.value, 10));

    const activeSportNames = new Set();
    checkedBranchCheckboxes.forEach(cb => {
      const branchId = parseInt(cb.value, 10);
      const branch = branches.find(b => b.id === branchId);
      if (branch && branch.sports) {
        branch.sports.split(',').forEach(s => {
          const sportName = s.trim();
          if (sportName) {
            activeSportNames.add(sportName.toLowerCase());
          }
        });
      }
    });

    const filteredSports = mockSports.filter(s => activeSportNames.has(s.name.toLowerCase()));

    const filter = document.getElementById('filterType');
    const currentValue = filter.value;

    filter.innerHTML = `<option value="all">Tất cả môn thể thao</option>` + 
      filteredSports.map(s => `<option value="\${s.id}">\${s.name}</option>`).join('');

    if (filteredSports.some(s => String(s.id) === currentValue)) {
      filter.value = currentValue;
    } else {
      filter.value = 'all';
    }
  }

  function onBranchFilterChange() {
    updateSportFilters();
    renderStats();
    renderCourts();
  }

  function toggleAllBranches(checked) {
    const checkboxes = document.querySelectorAll('input[name="filterBranch"]');
    checkboxes.forEach(cb => cb.checked = checked);
    onBranchFilterChange();
  }

  function renderAll() {
    onBranchFilterChange();
  }

  function renderStats() {
    const checkedBranchCheckboxes = document.querySelectorAll('input[name="filterBranch"]:checked');
    const selectedBranchIds = Array.from(checkedBranchCheckboxes).map(cb => parseInt(cb.value, 10));
    
    const filteredSan = mockSan.filter(s => selectedBranchIds.includes(s.coSoId));

    document.getElementById('statTotal').innerText = filteredSan.length;
    document.getElementById('statReady').innerText = filteredSan.filter(s => s.status === 'Sẵn sàng').length;
    document.getElementById('statMaintenance').innerText = filteredSan.filter(s => s.status === 'Bảo trì').length;
    document.getElementById('statClosed').innerText = filteredSan.filter(s => s.status === 'Tạm đóng').length;
  }

  // Filtering Logic
  function applyFilters() {
    renderCourts();
  }

  function renderCourts() {
    const query = document.getElementById('searchInput').value.toLowerCase().trim();
    const typeIdFilter = document.getElementById('filterType').value;
    const statusFilter = document.getElementById('filterStatus').value;

    const checkedBranchCheckboxes = document.querySelectorAll('input[name="filterBranch"]:checked');
    const selectedBranchIds = Array.from(checkedBranchCheckboxes).map(cb => parseInt(cb.value, 10));

    let filtered = mockSan.map(c => {
      const typeObj = mockLoaiSan.find(l => l.id === c.typeId) || {};
      const sportObj = mockSports.find(s => s.id === typeObj.sportId) || {};
      return { ...c, type: typeObj, sport: sportObj };
    });

    filtered = filtered.filter(c => selectedBranchIds.includes(c.coSoId));

    if (query) {
      filtered = filtered.filter(c => c.code.toLowerCase().includes(query) || c.name.toLowerCase().includes(query) || c.desc.toLowerCase().includes(query));
    }
    if (typeIdFilter !== 'all') {
      filtered = filtered.filter(c => c.sport.id === parseInt(typeIdFilter));
    }
    if (statusFilter !== 'all') {
      filtered = filtered.filter(c => c.status === statusFilter);
    }

    const empty = document.getElementById('emptyState');
    if (filtered.length === 0) {
      document.getElementById('mainCourtGrid').classList.add('hidden');
      document.getElementById('mainCourtList').classList.add('hidden');
      empty.classList.remove('hidden');
      return;
    } else {
      empty.classList.add('hidden');
      if (viewMode === 'grid') {
        document.getElementById('mainCourtGrid').classList.remove('hidden');
      } else {
        document.getElementById('mainCourtList').classList.remove('hidden');
      }
    }

    if (viewMode === 'grid') {
      renderGridView(filtered);
    } else {
      renderListView(filtered);
    }
  }

  function renderGridView(courts) {
    const grid = document.getElementById('mainCourtGrid');
    grid.innerHTML = courts.map(c => {
      const image = c.image || sportImages[c.sport.id] || sportImages[1];
      
      let statusBadge = '';
      let statusBorder = '';
      if (c.status === 'Sẵn sàng') {
        statusBadge = `<span class="badge badge-blue shadow-sm">Sẵn sàng</span>`;
      } else if (c.status === 'Đang dùng') {
        statusBadge = `<span class="badge badge-green flex items-center gap-1 shadow-sm"><span class="w-1.5 h-1.5 rounded-full bg-green-500 live-dot"></span>Đang dùng</span>`;
      } else if (c.status === 'Bảo trì') {
        statusBadge = `<span class="badge badge-amber shadow-sm">⚠ Bảo trì</span>`;
        statusBorder = 'ring-2 ring-amber-200';
      } else {
        statusBadge = `<span class="badge badge-red shadow-sm">⛔ Tạm đóng</span>`;
        statusBorder = 'ring-2 ring-red-200 opacity-90';
      }

      return `
        <div data-aos="fade-up" class="court-card card overflow-hidden \${statusBorder}">
          <div class="relative h-36 overflow-hidden">
            <img src="\${image}" class="court-img w-full h-full object-cover" alt="\${c.name}">
            <div class="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent"></div>
            <div class="absolute top-2 left-2"><span class="text-[10px] font-black bg-white/95 backdrop-blur px-2 py-1 rounded-md text-zinc-800 shadow">\${c.code}</span></div>
            <div class="absolute top-2 right-2">\${statusBadge}</div>
            <div class="absolute bottom-2 left-2 text-white">
              <p class="text-sm font-bold">\${c.name}</p>
              <p class="text-[10px] opacity-90">\${c.type.name} · \${c.sport.name}</p>
            </div>
          </div>
          <div class="p-3">
            <div class="flex items-center justify-between mb-2">
              <div class="flex items-center gap-1">
                <span class="material-symbols-outlined text-[14px] text-zinc-400">schedule</span>
                <span class="text-[10px] text-zinc-500">\${c.type.lightStart === '06:00' ? 'Bật đèn full-time' : 'Đèn lúc ' + c.type.lightStart}</span>
              </div>
              <p class="text-sm font-black text-zinc-900">\${c.type.priceNoLight.toLocaleString('vi-VN')}đ<span class="text-[10px] text-zinc-400 font-normal">/h</span></p>
            </div>
            <p class="text-[10px] text-zinc-500 mb-3 line-clamp-1">\${c.desc || 'Không có mô tả sân.'}</p>
            
            <div class="flex items-center gap-1.5">
              \${c.status === 'Sẵn sàng' ? 
                `<button onclick="openQuickBooking(\${c.id})" class="flex-1 h-8 rounded-lg bg-zinc-800 hover:bg-zinc-700 text-xs font-semibold text-white flex items-center justify-center gap-1"><span class="material-symbols-outlined text-[14px]">event_available</span>Đặt ngay</button>
                 <button onclick="quickUpdateStatus(\${c.id}, 'Tạm đóng')" class="h-8 px-2.5 rounded-lg border border-red-200 text-red-500 hover:bg-red-50 text-xs font-semibold flex items-center justify-center" title="Tạm đóng sân">Tắt</button>` : 
                `<button onclick="quickUpdateStatus(\${c.id}, 'Sẵn sàng')" class="flex-1 h-8 rounded-lg bg-zinc-900 hover:bg-zinc-800 text-xs font-semibold text-white flex items-center justify-center gap-1"><span class="material-symbols-outlined text-[14px]">check_circle</span>Mở lại</button>`
              }
              <button onclick="openEditModal(\${c.id})" class="h-8 w-8 rounded-lg border border-zinc-200 text-zinc-500 hover:bg-zinc-50 flex items-center justify-center" title="Sửa sân"><span class="material-symbols-outlined text-[14px]">edit</span></button>
              <button onclick="deleteCourt(\${c.id})" class="h-8 w-8 rounded-lg border border-red-200 text-red-500 hover:bg-red-50 flex items-center justify-center" title="Xóa sân"><span class="material-symbols-outlined text-[14px]">delete</span></button>
            </div>
          </div>
        </div>
      `;
    }).join('');
  }

  function renderListView(courts) {
    const tbody = document.getElementById('courtListTableBody');
    tbody.innerHTML = courts.map(c => {
      let statusBadge = '';
      if (c.status === 'Sẵn sàng') {
        statusBadge = `<span class="badge badge-blue">Sẵn sàng</span>`;
      } else if (c.status === 'Đang dùng') {
        statusBadge = `<span class="badge badge-green">Đang dùng</span>`;
      } else if (c.status === 'Bảo trì') {
        statusBadge = `<span class="badge badge-amber">Bảo trì</span>`;
      } else {
        statusBadge = `<span class="badge badge-red">Tạm đóng</span>`;
      }

      return `
        <tr class="hover:bg-zinc-50/50 transition-colors">
          <td class="px-5 py-3 font-semibold text-zinc-800">\${c.code}</td>
          <td class="px-5 py-3 font-bold">\${c.name}</td>
          <td class="px-5 py-3">
            <p class="font-semibold text-zinc-800">\${c.type.name}</p>
            <p class="text-[10px] text-zinc-400 mt-0.5">\${c.sport.name}</p>
          </td>
          <td class="px-5 py-3">
            <p class="font-semibold text-zinc-800">\${c.type.priceNoLight.toLocaleString('vi-VN')}đ / giờ</p>
            <p class="text-[10px] text-zinc-450 mt-0.5">Có đèn: \${c.type.priceWithLight.toLocaleString('vi-VN')}đ</p>
          </td>
          <td class="px-5 py-3 text-zinc-500 font-medium">\${c.type.lightStart === '06:00' ? 'Full-time' : 'Từ ' + c.type.lightStart}</td>
          <td class="px-5 py-3">\${statusBadge}</td>
          <td class="px-5 py-3 text-right">
            <div class="flex items-center justify-end gap-1.5">
              <button onclick="openEditModal(\${c.id})" class="h-7 w-7 rounded-lg border border-zinc-200 text-zinc-550 hover:bg-zinc-50 flex items-center justify-center" title="Sửa"><span class="material-symbols-outlined text-[13px]">edit</span></button>
              <button onclick="deleteCourt(\${c.id})" class="h-7 w-7 rounded-lg border border-red-200 text-red-500 hover:bg-red-50 flex items-center justify-center" title="Xóa"><span class="material-symbols-outlined text-[13px]">delete</span></button>
            </div>
          </td>
        </tr>
      `;
    }).join('');
  }

  // -------------------------------------------------------------
  // COURT TYPES & PRICING TAB (LoaiSan CRUD)
  // -------------------------------------------------------------
  
  function renderTypesList() {
    const checkedBranchCheckboxes = document.querySelectorAll('input[name="filterBranch"]:checked');
    const selectedBranchIds = Array.from(checkedBranchCheckboxes).map(cb => parseInt(cb.value, 10));

    const tbody = document.getElementById('typeListTableBody');
    const filteredTypes = mockLoaiSan.filter(l => !l.coSoId || selectedBranchIds.includes(l.coSoId));

    tbody.innerHTML = filteredTypes.map(l => {
      const sport = mockSports.find(s => s.id === l.sportId) || {};
      const branch = branches.find(b => b.id === l.coSoId) || { name: 'Chung' };
      return `
        <tr class="hover:bg-zinc-50/50 transition-colors">
          <td class="px-5 py-3.5 font-bold text-zinc-800">L-0\${l.id}</td>
          <td class="px-5 py-3.5 font-extrabold text-zinc-900">\${l.name}</td>
          <td class="px-5 py-3.5">
            <span class="inline-flex items-center gap-1 font-semibold text-blue-700 bg-blue-50 px-2 py-1 rounded-md text-[10px]">
              <span class="material-symbols-outlined text-[12px]">\${sport.icon || 'sports'}</span>\${sport.name}
            </span>
          </td>
          <td class="px-5 py-3.5 text-zinc-600 font-semibold">\${branch.name}</td>
          <td class="px-5 py-3.5 font-semibold text-zinc-800">\${l.priceNoLight.toLocaleString('vi-VN')}đ / giờ</td>
          <td class="px-5 py-3.5 font-semibold text-amber-700">\${l.priceWithLight.toLocaleString('vi-VN')}đ / giờ</td>
          <td class="px-5 py-3.5">
            <span class="font-medium text-zinc-500">\${l.lightStart === '06:00' ? '💡 Full-time (Trong nhà)' : '💡 Sau ' + l.lightStart}</span>
          </td>
          <td class="px-5 py-3.5 text-right">
            <div class="flex items-center justify-end gap-1.5">
              <button onclick="openEditTypeModal(\${l.id})" class="h-7 w-7 rounded-lg border border-zinc-200 text-zinc-550 hover:bg-zinc-50 flex items-center justify-center" title="Sửa loại sân"><span class="material-symbols-outlined text-[13px]">edit</span></button>
              <button onclick="deleteType(\${l.id})" class="h-7 w-7 rounded-lg border border-red-200 text-red-500 hover:bg-red-50 flex items-center justify-center" title="Xóa loại sân"><span class="material-symbols-outlined text-[13px]">delete</span></button>
            </div>
          </td>
        </tr>
      `;
    }).join('');
  }

  // Toast Helper
  function showToast(message) {
    const toast = document.getElementById('successToast');
    document.getElementById('successToastMessage').innerText = message;
    toast.classList.remove('opacity-0', 'translate-y-12', 'pointer-events-none');
    toast.classList.add('opacity-100', 'translate-y-0');
    setTimeout(() => {
      toast.classList.add('opacity-0', 'translate-y-12', 'pointer-events-none');
      toast.classList.remove('opacity-100', 'translate-y-0');
    }, 3500);
  }

  // -------------------------------------------------------------
  // CRUD ACTIONS FOR COURTS (San)
  // -------------------------------------------------------------
  
  function openCreateModal() {
    document.getElementById('courtModalTitle').innerText = 'Thêm sân thi đấu mới';
    document.getElementById('courtEditId').value = '';
    document.getElementById('courtCode').value = 'Auto';
    document.getElementById('courtCode').disabled = true;
    document.getElementById('courtName').value = '';
    document.getElementById('courtDesc').value = '';
    document.getElementById('courtImage').value = '';
    document.getElementById('courtStatus').value = 'Sẵn sàng';
    document.getElementById('saveCourtBtn').innerText = 'Thêm sân';
    
    populateSportDropdowns();
    filterCourtTypesByBranch();
    document.getElementById('courtModal').classList.remove('hidden');
  }

  function openEditModal(id) {
    const court = mockSan.find(c => c.id === id);
    if (!court) return;

    document.getElementById('courtModalTitle').innerText = 'Chỉnh sửa sân thi đấu';
    document.getElementById('courtEditId').value = court.id;
    document.getElementById('courtCode').value = court.code;
    document.getElementById('courtCode').disabled = true;
    document.getElementById('courtName').value = court.name;
    document.getElementById('courtDesc').value = court.desc || '';
    document.getElementById('courtImage').value = court.image || '';
    document.getElementById('courtStatus').value = court.status;
    document.getElementById('saveCourtBtn').innerText = 'Lưu thay đổi';

    populateSportDropdowns();
    document.getElementById('courtBranchSelect').value = court.coSoId;
    filterCourtTypesByBranch();
    document.getElementById('courtTypeSelect').value = court.typeId;
    document.getElementById('courtModal').classList.remove('hidden');
  }

  function closeCourtModal() {
    document.getElementById('courtModal').classList.add('hidden');
  }

  function saveCourt() {
    const id = document.getElementById('courtEditId').value;
    const name = document.getElementById('courtName').value.trim();
    const typeId = document.getElementById('courtTypeSelect').value;
    const coSoId = document.getElementById('courtBranchSelect').value;
    const status = document.getElementById('courtStatus').value;
    const desc = document.getElementById('courtDesc').value.trim();
    const image = document.getElementById('courtImage').value.trim();

    if (!name) {
      alert('Vui lòng điền đầy đủ các thông tin bắt buộc (*)');
      return;
    }

    const form = document.createElement('form');
    form.method = 'POST';
    form.action = '${pageContext.request.contextPath}/admin/quan-ly-san';

    const add = (n, v) => {
      const i = document.createElement('input');
      i.type = 'hidden';
      i.name = n;
      i.value = v;
      form.appendChild(i);
    };

    add('action', id ? 'update' : 'add');
    if (id) add('sanID', id);
    add('tenSan', name);
    add('loaiSanID', typeId);
    add('coSoID', coSoId);
    add('trangThai', status);
    add('moTa', desc);
    add('hinhAnh', image);

    document.body.appendChild(form);
    form.submit();
  }

  function deleteCourt(id) {
    const court = mockSan.find(c => c.id === id);
    if (!court) return;

    if (confirm(`Bạn có chắc chắn muốn xóa sân \${court.name} (\${court.code}) khỏi cơ sở dữ liệu?`)) {
      const form = document.createElement('form');
      form.method = 'POST';
      form.action = '${pageContext.request.contextPath}/admin/quan-ly-san';

      const add = (n, v) => {
        const i = document.createElement('input');
        i.type = 'hidden';
        i.name = n;
        i.value = v;
        form.appendChild(i);
      };

      add('action', 'delete');
      add('sanID', id);

      document.body.appendChild(form);
      form.submit();
    }
  }

  function quickUpdateStatus(id, newStatus) {
    const court = mockSan.find(c => c.id === id);
    if (court) {
      if (confirm(`Bạn có chắc chắn muốn thay đổi trạng thái sân \${court.name} sang "\${newStatus}"?`)) {
        const form = document.createElement('form');
        form.method = 'POST';
        form.action = '${pageContext.request.contextPath}/admin/quan-ly-san';

        const add = (n, v) => {
          const i = document.createElement('input');
          i.type = 'hidden';
          i.name = n;
          i.value = v;
          form.appendChild(i);
        };

        add('action', 'updateStatus');
        add('sanID', id);
        add('trangThai', newStatus);

        document.body.appendChild(form);
        form.submit();
      }
    }
  }

  // -------------------------------------------------------------
  // CRUD ACTIONS FOR COURT TYPES (LoaiSan)
  // -------------------------------------------------------------
  
  function openCreateTypeModal() {
    document.getElementById('typeModalTitle').innerText = 'Thêm cấu hình loại sân mới';
    document.getElementById('typeEditId').value = '';
    document.getElementById('typeName').value = '';
    document.getElementById('typePriceNoLight').value = '';
    document.getElementById('typePriceWithLight').value = '';
    document.getElementById('typeLightStart').value = '17:30';
    if (document.getElementById('typeBranchSelect') && branches.length > 0) {
      document.getElementById('typeBranchSelect').value = branches[0].id;
    }
    document.getElementById('saveTypeBtn').innerText = 'Thêm cấu hình';
    document.getElementById('typeModal').classList.remove('hidden');
  }

  function openEditTypeModal(id) {
    const typeObj = mockLoaiSan.find(t => t.id === id);
    if (!typeObj) return;

    document.getElementById('typeModalTitle').innerText = 'Chỉnh sửa loại sân & Bảng giá';
    document.getElementById('typeEditId').value = typeObj.id;
    document.getElementById('typeSportSelect').value = typeObj.sportId;
    if (document.getElementById('typeBranchSelect')) {
      document.getElementById('typeBranchSelect').value = typeObj.coSoId || '';
    }
    document.getElementById('typeName').value = typeObj.name;
    document.getElementById('typePriceNoLight').value = typeObj.priceNoLight.toLocaleString('en-US');
    document.getElementById('typePriceWithLight').value = typeObj.priceWithLight.toLocaleString('en-US');
    document.getElementById('typeLightStart').value = typeObj.lightStart;
    document.getElementById('saveTypeBtn').innerText = 'Lưu cấu hình';
    document.getElementById('typeModal').classList.remove('hidden');
  }

  function closeTypeModal() {
    document.getElementById('typeModal').classList.add('hidden');
  }

  function saveType() {
    const id = document.getElementById('typeEditId').value;
    const sportId = parseInt(document.getElementById('typeSportSelect').value);
    const coSoId = document.getElementById('typeBranchSelect').value;
    const name = document.getElementById('typeName').value.trim();
    const priceNoLight = parseFormattedNumber(document.getElementById('typePriceNoLight').value);
    const priceWithLight = parseFormattedNumber(document.getElementById('typePriceWithLight').value);
    const lightStart = document.getElementById('typeLightStart').value;

    if (!name || !priceNoLight || !priceWithLight || !lightStart) {
      alert('Vui lòng điền đầy đủ thông tin loại sân!');
      return;
    }

    const form = document.createElement('form');
    form.method = 'POST';
    form.action = '${pageContext.request.contextPath}/admin/quan-ly-san';

    const add = (n, v) => {
      const i = document.createElement('input');
      i.type = 'hidden';
      i.name = n;
      i.value = v;
      form.appendChild(i);
    };

    add('action', id ? 'updateType' : 'addType');
    if (id) add('loaiSanID', id);
    add('tenLoai', name);
    add('monTheThaoID', sportId);
    if (coSoId) add('coSoID', coSoId);
    add('giaKhongDen', priceNoLight);
    add('giaCoDen', priceWithLight);
    add('gioBatDauLenDen', lightStart);

    document.body.appendChild(form);
    form.submit();
  }

  function deleteType(id) {
    const typeObj = mockLoaiSan.find(t => t.id === id);
    if (!typeObj) return;

    if (confirm(`Bạn có chắc chắn muốn xóa loại sân \${typeObj.name}? Mọi sân liên kết với loại hình này sẽ cần được cấu hình lại.`)) {
      const form = document.createElement('form');
      form.method = 'POST';
      form.action = '${pageContext.request.contextPath}/admin/quan-ly-san';

      const add = (n, v) => {
        const i = document.createElement('input');
        i.type = 'hidden';
        i.name = n;
        i.value = v;
        form.appendChild(i);
      };

      add('action', 'deleteType');
      add('loaiSanID', id);

      document.body.appendChild(form);
      form.submit();
    }
  }

  // -------------------------------------------------------------
  // INTEGRATED BOOKING MODAL LOGIC (Preserving all user functionality)
  // -------------------------------------------------------------

  const bookingModal = document.getElementById('bookingModal');
  const bookingModalCard = document.getElementById('bookingModalCard');
  const closeBookingBtn = document.getElementById('closeBookingModalBtn');
  const cancelBookingBtn = document.getElementById('cancelBookingBtn');
  const confirmBookingBtn = document.getElementById('confirmBookingBtn');

  const btnCustVip = document.getElementById('btnCustVip');
  const btnCustWalkin = document.getElementById('btnCustWalkin');
  const custVipSection = document.getElementById('custVipSection');
  const custWalkinSection = document.getElementById('custWalkinSection');

  const custSearchInput = document.getElementById('custSearchInput');
  const custSuggestions = document.getElementById('custSuggestions');
  const selectedCustCard = document.getElementById('selectedCustCard');
  const removeSelectedCustBtn = document.getElementById('removeSelectedCustBtn');
  const clearSearchBtn = document.getElementById('clearCustSearchBtn');

  const selectSport = document.getElementById('selectSport');
  const selectLoaiSan = document.getElementById('selectLoaiSan');
  const modalCourtGrid = document.getElementById('modalCourtGrid');

  const bookingDate = document.getElementById('bookingDate');
  const timeStart = document.getElementById('timeStart');
  const timeEnd = document.getElementById('timeEnd');
  const toggleLight = document.getElementById('toggleLight');
  const lightInfoText = document.getElementById('lightInfoText');

  const summaryCourt = document.getElementById('summaryCourt');
  const summaryDuration = document.getElementById('summaryDuration');
  const summaryRate = document.getElementById('summaryRate');
  const summaryLightRow = document.getElementById('summaryLightRow');
  const summaryLightFee = document.getElementById('summaryLightFee');
  const summaryTotal = document.getElementById('summaryTotal');

  const mockCustomers = [
    { id: 1, name: 'Nguyễn Văn Hùng', phone: '0909000123', email: 'hung.nv@gmail.com', elo: 1050, vip: 'VIP Đồng', avatar: 'https://i.pravatar.cc/80?img=11' },
    { id: 2, name: 'Trần Thị Lan', phone: '0987654321', email: 'lan.tt@gmail.com', elo: 1120, vip: 'VIP Bạc', avatar: 'https://i.pravatar.cc/80?img=25' },
    { id: 3, name: 'Lê Hoàng Việt', phone: '0912345678', email: 'viet.lh@gmail.com', elo: 980, vip: 'Thành viên', avatar: 'https://i.pravatar.cc/80?img=32' },
    { id: 4, name: 'Phạm Minh Tuấn', phone: '0933344455', email: 'tuan.pm@gmail.com', elo: 1250, vip: 'VIP Vàng', avatar: 'https://i.pravatar.cc/80?img=58' },
    { id: 5, name: 'Đỗ Thị Mai', phone: '0955566677', email: 'mai.dt@gmail.com', elo: 1020, vip: 'Thành viên', avatar: 'https://i.pravatar.cc/80?img=47' }
  ];

  let activeCustomerType = 'VIP';
  let selectedCustomer = null;
  let selectedSportId = 1;
  let selectedLoaiSan = null;
  let selectedCourt = null;
  let selectedSource = 'Walk-in';

  bookingDate.valueAsDate = new Date();

  // Open Quick Booking Modal from Court Card
  function openQuickBooking(courtId) {
    const court = mockSan.find(c => c.id === courtId);
    if (!court) return;

    bookingModal.classList.remove('pointer-events-none', 'opacity-0');
    bookingModalCard.classList.remove('scale-95');
    bookingModalCard.classList.add('scale-100');
    
    initBookingSports();
    
    // Auto-select the sport & loai san of the clicked court
    const typeObj = mockLoaiSan.find(t => t.id === court.typeId);
    if (typeObj) {
      selectSport.value = typeObj.sportId;
      selectedSportId = typeObj.sportId;
      loadBookingLoaiSan(typeObj.sportId);
      selectLoaiSan.value = typeObj.id;
      selectedLoaiSan = typeObj;
      loadBookingCourts(typeObj.id);
      
      // Select the specific court
      setTimeout(() => {
        const card = document.querySelector(`#modalCourtGrid [data-id="\${courtId}"]`);
        if (card) card.click();
      }, 50);
    }
  }

  btnCustVip.addEventListener('click', () => setCustomerType('VIP'));
  btnCustWalkin.addEventListener('click', () => setCustomerType('Walkin'));

  function setCustomerType(type) {
    activeCustomerType = type;
    if(type === 'VIP') {
      btnCustVip.className = 'px-3 py-1 rounded-md bg-white shadow-sm text-zinc-800 transition-all border border-zinc-200';
      btnCustWalkin.className = 'px-3 py-1 rounded-md text-zinc-500 hover:text-zinc-800 transition-all';
      custVipSection.classList.remove('hidden');
      custWalkinSection.classList.add('hidden');
    } else {
      btnCustWalkin.className = 'px-3 py-1 rounded-md bg-white shadow-sm text-zinc-800 transition-all border border-zinc-200';
      btnCustVip.className = 'px-3 py-1 rounded-md text-zinc-500 hover:text-zinc-800 transition-all';
      custWalkinSection.classList.remove('hidden');
      custVipSection.classList.add('hidden');
      selectedCustomer = null;
      updatePriceSummary();
    }
  }

  // VIP Customer Search
  custSearchInput.addEventListener('input', () => {
    const query = custSearchInput.value.toLowerCase().trim();
    if(!query) {
      custSuggestions.classList.add('hidden');
      clearSearchBtn.classList.add('hidden');
      return;
    }
    clearSearchBtn.classList.remove('hidden');

    const filtered = mockCustomers.filter(c => c.name.toLowerCase().includes(query) || c.phone.includes(query));
    
    if(filtered.length === 0) {
      custSuggestions.innerHTML = '<div class="p-3 text-xs text-zinc-400 text-center">Không tìm thấy khách hàng nào</div>';
    } else {
      custSuggestions.innerHTML = filtered.map(c => `
        <div class="cust-suggest-item flex items-center justify-between p-2.5 hover:bg-zinc-50 cursor-pointer transition-colors" data-id="\${c.id}">
          <div class="flex items-center gap-2.5">
            <img src="\${c.avatar}" class="w-8 h-8 rounded-full object-cover">
            <div>
              <div class="flex items-center gap-1.5">
                <span class="text-xs font-semibold text-zinc-800">\${c.name}</span>
                <span class="text-[9px] font-bold px-1.5 py-0.5 rounded-full \${c.vip === 'VIP Vàng' ? 'bg-amber-100 text-amber-700' : c.vip === 'VIP Bạc' ? 'bg-zinc-100 text-zinc-650' : c.vip === 'VIP Đồng' ? 'bg-orange-50 text-orange-700' : 'bg-blue-50 text-blue-700'}">\${c.vip}</span>
              </div>
              <p class="text-[10px] text-zinc-500 mt-0.5">SĐT: \${c.phone} · ELO: \${c.elo}</p>
            </div>
          </div>
        </div>
      `).join('');

      document.querySelectorAll('.cust-suggest-item').forEach(item => {
        item.addEventListener('click', () => {
          const id = parseInt(item.getAttribute('data-id'));
          selectCustomerProfile(id);
        });
      });
    }
    custSuggestions.classList.remove('hidden');
  });

  clearSearchBtn.addEventListener('click', () => {
    custSearchInput.value = '';
    custSuggestions.classList.add('hidden');
    clearSearchBtn.classList.add('hidden');
  });

  function selectCustomerProfile(id) {
    selectedCustomer = mockCustomers.find(c => c.id === id);
    custSearchInput.classList.add('hidden');
    custSuggestions.classList.add('hidden');
    clearSearchBtn.classList.add('hidden');

    document.getElementById('selectedCustAvatar').src = selectedCustomer.avatar;
    document.getElementById('selectedCustName').innerText = selectedCustomer.name;
    document.getElementById('selectedCustPhone').innerText = selectedCustomer.phone;
    document.getElementById('selectedCustElo').innerText = selectedCustomer.elo;
    
    const vipBadge = document.getElementById('selectedCustVip');
    vipBadge.innerText = selectedCustomer.vip;
    vipBadge.className = 'badge text-[9px] ';
    if(selectedCustomer.vip === 'VIP Vàng') vipBadge.classList.add('badge-amber');
    else if(selectedCustomer.vip === 'VIP Bạc') vipBadge.classList.add('badge-gray');
    else if(selectedCustomer.vip === 'VIP Đồng') vipBadge.classList.add('badge-amber');
    else vipBadge.classList.add('badge-blue');

    selectedCustCard.classList.remove('hidden');
    updatePriceSummary();
  }

  removeSelectedCustBtn.addEventListener('click', (e) => {
    e.preventDefault();
    selectedCustomer = null;
    selectedCustCard.classList.add('hidden');
    custSearchInput.value = '';
    custSearchInput.classList.remove('hidden');
    custSearchInput.focus();
    updatePriceSummary();
  });

  document.addEventListener('click', (e) => {
    if(!custSearchInput.contains(e.target) && !custSuggestions.contains(e.target)) {
      custSuggestions.classList.add('hidden');
    }
  });

  // Booking source selectors
  document.querySelectorAll('.source-chip').forEach(chip => {
    if(chip.getAttribute('data-source') === 'Walk-in') {
      chip.classList.add('border-blue-600', 'bg-blue-50/50', 'text-blue-700');
    }
    chip.addEventListener('click', () => {
      document.querySelectorAll('.source-chip').forEach(c => c.classList.remove('border-blue-600', 'bg-blue-50/50', 'text-blue-700'));
      chip.classList.add('border-blue-600', 'bg-blue-50/50', 'text-blue-700');
      selectedSource = chip.getAttribute('data-source');
    });
  });

  function initBookingSports() {
    selectSport.innerHTML = mockSports.map(s => `<option value="\${s.id}">\${s.name}</option>`).join('');
    selectSport.removeEventListener('change', onBookingSportChange);
    selectSport.addEventListener('change', onBookingSportChange);
    loadBookingLoaiSan(1);
  }

  function onBookingSportChange() {
    selectedSportId = parseInt(selectSport.value);
    loadBookingLoaiSan(selectedSportId);
  }

  function loadBookingLoaiSan(sportId) {
    const filtered = mockLoaiSan.filter(l => l.sportId === sportId);
    selectLoaiSan.innerHTML = filtered.map(l => `<option value="\${l.id}">\${l.name}</option>`).join('');
    
    selectLoaiSan.removeEventListener('change', onBookingLoaiSanChange);
    selectLoaiSan.addEventListener('change', onBookingLoaiSanChange);
    onBookingLoaiSanChange();
  }

  function onBookingLoaiSanChange() {
    const loaiSanId = parseInt(selectLoaiSan.value);
    selectedLoaiSan = mockLoaiSan.find(l => l.id === loaiSanId);
    
    if(selectedLoaiSan.lightStart === '06:00') {
      lightInfoText.innerText = `💡 Đèn chiếu sáng bật cố định full-time (Không phụ thu)`;
    } else {
      lightInfoText.innerText = `💡 Hệ thống tự động tính phí đèn từ \${selectedLoaiSan.lightStart}`;
    }

    loadBookingCourts(loaiSanId);
    checkLightingTime();
  }

  function loadBookingCourts(typeId) {
    const filtered = mockSan.filter(s => s.typeId === typeId);
    modalCourtGrid.innerHTML = filtered.map(c => {
      let statusClass = '';
      let disabled = false;
      let badge = '';
      
      if(c.status === 'Bảo trì') {
        statusClass = 'border-amber-100 bg-amber-50/30 text-amber-600 cursor-not-allowed opacity-60';
        disabled = true;
        badge = '<span class="badge badge-amber text-[9px] py-0 px-1 mt-1">Bảo trì</span>';
      } else if(c.status === 'Đang dùng') {
        statusClass = 'border-red-100 bg-red-55/30 text-red-500 cursor-not-allowed opacity-60';
        disabled = true;
        badge = '<span class="badge badge-red text-[9px] py-0 px-1 mt-1">Đang bận</span>';
      } else {
        statusClass = 'border-zinc-200 bg-white hover:border-blue-300 hover:bg-blue-50/10 cursor-pointer';
        badge = '<span class="badge badge-green text-[9px] py-0 px-1 mt-1">Trống</span>';
      }

      return `
        <div class="modal-court-card border rounded-xl p-3 flex flex-col justify-between h-20 transition-all \${statusClass}" data-id="\${c.id}" data-disabled="\${disabled}">
          <div class="flex items-center justify-between">
            <p class="text-xs font-bold text-zinc-800 name-text">\${c.name}</p>
            <span class="material-symbols-outlined text-[16px] text-blue-650 hidden check-icon">check_circle</span>
          </div>
          <div>
            \${badge}
          </div>
        </div>
      `;
    }).join('');

    selectedCourt = null;
    summaryCourt.innerText = '-';

    document.querySelectorAll('.modal-court-card').forEach(card => {
      if(card.getAttribute('data-disabled') === 'true') return;

      card.addEventListener('click', () => {
        document.querySelectorAll('.modal-court-card').forEach(c => {
          c.classList.remove('border-blue-600', 'bg-blue-50/30', 'ring-2', 'ring-blue-500/10');
          c.querySelector('.check-icon').classList.add('hidden');
          c.querySelector('.name-text').classList.remove('text-blue-700');
        });

        card.classList.add('border-blue-600', 'bg-blue-50/30', 'ring-2', 'ring-blue-500/10');
        card.querySelector('.check-icon').classList.remove('hidden');
        card.querySelector('.name-text').classList.add('text-blue-700');

        const id = parseInt(card.getAttribute('data-id'));
        selectedCourt = mockSan.find(s => s.id === id);
        summaryCourt.innerText = selectedCourt.name;
        updatePriceSummary();
      });
    });
    
    updatePriceSummary();
  }

  // Booking duration presets
  document.querySelectorAll('.btn-duration').forEach(btn => {
    btn.addEventListener('click', () => {
      document.querySelectorAll('.btn-duration').forEach(b => {
        b.classList.remove('bg-blue-50', 'text-blue-700', 'border', 'border-blue-100');
        b.classList.add('bg-zinc-100', 'text-zinc-700');
      });
      btn.classList.remove('bg-zinc-100', 'text-zinc-700');
      btn.classList.add('bg-blue-50', 'text-blue-700', 'border', 'border-blue-100');

      const duration = parseFloat(btn.getAttribute('data-duration'));
      calculateEndTimeFromDuration(duration);
    });
  });

  function calculateEndTimeFromDuration(hours) {
    const startVal = timeStart.value;
    if(!startVal) return;

    const [h, m] = startVal.split(':').map(Number);
    let totalMinutes = h * 60 + m + hours * 60;
    
    const endH = Math.floor(totalMinutes / 60) % 24;
    const endM = totalMinutes % 60;
    
    timeEnd.value = `\${String(endH).padStart(2, '0')}:\${String(endM).padStart(2, '0')}`;
    checkLightingTime();
    updatePriceSummary();
  }

  timeStart.addEventListener('change', () => {
    checkLightingTime();
    updatePriceSummary();
  });
  timeEnd.addEventListener('change', () => {
    checkLightingTime();
    updatePriceSummary();
  });
  toggleLight.addEventListener('change', () => {
    updatePriceSummary();
  });

  function checkLightingTime() {
    if(!selectedLoaiSan) return;
    
    const startVal = timeStart.value;
    const endVal = timeEnd.value;
    if(!startVal || !endVal) return;

    if(selectedLoaiSan.lightStart === '06:00') {
      toggleLight.checked = true;
      toggleLight.disabled = true;
      return;
    }
    
    toggleLight.disabled = false;

    const [sh, sm] = startVal.split(':').map(Number);
    const [eh, em] = endVal.split(':').map(Number);
    const [lh, lm] = selectedLoaiSan.lightStart.split(':').map(Number);

    const startMins = sh * 60 + sm;
    const endMins = eh * 60 + em;
    const lightMins = lh * 60 + lm;

    if (endMins > lightMins) {
      toggleLight.checked = true;
      lightInfoText.innerText = `💡 Tự động bật đèn (Sau \${selectedLoaiSan.lightStart})`;
    } else {
      toggleLight.checked = false;
      lightInfoText.innerText = `💡 Không phụ thu đèn (Trước \${selectedLoaiSan.lightStart})`;
    }
  }

  function updatePriceSummary() {
    if(!selectedLoaiSan) return;

    const startVal = timeStart.value;
    const endVal = timeEnd.value;
    if(!startVal || !endVal) return;

    const [sh, sm] = startVal.split(':').map(Number);
    const [eh, em] = endVal.split(':').map(Number);

    let diffMins = (eh * 60 + em) - (sh * 60 + sm);
    if(diffMins < 0) diffMins += 24 * 60;

    const totalHours = diffMins / 60;
    summaryDuration.innerText = `\${totalHours.toFixed(1)} giờ`;

    const isLightApplied = toggleLight.checked;
    let finalPrice = 0;
    
    if(selectedLoaiSan.lightStart === '06:00') {
      finalPrice = totalHours * selectedLoaiSan.priceNoLight;
      summaryRate.innerText = `\${selectedLoaiSan.priceNoLight.toLocaleString('vi-VN')}đ / giờ`;
      summaryLightRow.classList.add('hidden');
    } else {
      const [lh, lm] = selectedLoaiSan.lightStart.split(':').map(Number);
      const startMins = sh * 60 + sm;
      const endMins = eh * 60 + em;
      const lightMins = lh * 60 + lm;

      if(isLightApplied) {
        if(endMins > lightMins) {
          const normalMins = Math.max(0, lightMins - startMins);
          const lightMinsDiff = Math.max(0, endMins - Math.max(startMins, lightMins));

          const normalHours = normalMins / 60;
          const lightHours = lightMinsDiff / 60;

          const normalCost = normalHours * selectedLoaiSan.priceNoLight;
          const lightCost = lightHours * selectedLoaiSan.priceWithLight;

          finalPrice = normalCost + lightCost;
          
          summaryRate.innerText = `\${selectedLoaiSan.priceNoLight.toLocaleString('vi-VN')}đ (Khung thường)`;
          summaryLightRow.classList.remove('hidden');
          summaryLightFee.innerText = `+\${Math.round(lightCost).toLocaleString('vi-VN')}đ (\${lightHours.toFixed(1)}h có đèn)`;
        } else {
          finalPrice = totalHours * selectedLoaiSan.priceWithLight;
          summaryRate.innerText = `\${selectedLoaiSan.priceWithLight.toLocaleString('vi-VN')}đ / giờ`;
          summaryLightRow.classList.add('hidden');
        }
      } else {
        finalPrice = totalHours * selectedLoaiSan.priceNoLight;
        summaryRate.innerText = `\${selectedLoaiSan.priceNoLight.toLocaleString('vi-VN')}đ / giờ`;
        summaryLightRow.classList.add('hidden');
      }
    }

    summaryTotal.innerText = `\${Math.round(finalPrice).toLocaleString('vi-VN')}đ`;
  }

  function closeBookingModal() {
    bookingModal.classList.add('pointer-events-none', 'opacity-0');
    bookingModalCard.classList.remove('scale-100');
    bookingModalCard.classList.add('scale-95');
    resetBookingForm();
  }

  closeBookingBtn.addEventListener('click', closeBookingModal);
  cancelBookingBtn.addEventListener('click', closeBookingModal);
  
  bookingModal.addEventListener('click', (e) => {
    if(e.target === bookingModal) closeBookingModal();
  });

  function resetBookingForm() {
    selectedCustomer = null;
    selectedCourt = null;
    custSearchInput.value = '';
    custSearchInput.classList.remove('hidden');
    selectedCustCard.classList.add('hidden');
    document.getElementById('walkinName').value = '';
    document.getElementById('walkinPhone').value = '';
    document.getElementById('bookingNotes').value = '';
    setCustomerType('VIP');
  }

  confirmBookingBtn.addEventListener('click', () => {
    let custName = '';
    if(activeCustomerType === 'VIP') {
      if(!selectedCustomer) {
        alert('Vui lòng chọn khách hàng thành viên!');
        return;
      }
      custName = selectedCustomer.name;
    } else {
      const walkinName = document.getElementById('walkinName').value.trim();
      const walkinPhone = document.getElementById('walkinPhone').value.trim();
      if(!walkinName || !walkinPhone) {
        alert('Vui lòng nhập tên và số điện thoại khách vãng lai!');
        return;
      }
      custName = walkinName;
    }

    if(!selectedCourt) {
      alert('Vui lòng chọn sân thi đấu cụ thể!');
      return;
    }

    // Booked court status change to Đang dùng
    selectedCourt.status = 'Đang dùng';
    showToast(`Đã đặt sân ${selectedCourt.name} thành công cho khách hàng ${custName}!`);
    closeBookingModal();
    renderAll();
  });
</script>
</body>
</html>
