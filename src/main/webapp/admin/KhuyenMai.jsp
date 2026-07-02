<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Khuyến mãi — Cơ Sở</title>
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
  .promo-card { background:#fff; border:1px solid #e4e4e7; border-radius:16px; overflow:hidden; transition:all .2s ease; display:flex; flex-direction:column; position:relative; }
  .promo-card:hover { transform:translateY(-3px); box-shadow:0 12px 24px -10px rgba(0,0,0,.08); border-color:#d4d4d8; }
  ::-webkit-scrollbar{width:6px;height:6px}::-webkit-scrollbar-track{background:transparent}::-webkit-scrollbar-thumb{background:#d4d4d8;border-radius:6px}
  ::-webkit-scrollbar-thumb:hover{background:#a1a1aa}
  
  /* Robust Pure CSS entry transitions (Offline friendly!) */
  @keyframes fadeUp {
    from { opacity: 0; transform: translateY(12px); }
    to { opacity: 1; transform: translateY(0); }
  }
  @keyframes scaleIn {
    from { opacity: 0; transform: scale(0.96); }
    to { opacity: 1; transform: scale(1); }
  }
  @keyframes pulse-dot { 0%,100%{box-shadow:0 0 0 0 rgba(34,197,94,.4);} 50%{box-shadow:0 0 0 6px rgba(34,197,94,0);} }
  
  .animate-fade-up {
    animation: fadeUp 0.4s cubic-bezier(0.16, 1, 0.3, 1) both;
  }
  .animate-scale-in {
    animation: scaleIn 0.22s cubic-bezier(0.16, 1, 0.3, 1) both;
  }
  .live-dot { animation: pulse-dot 1.6s ease-in-out infinite; }
  aside a .material-symbols-outlined { transition: transform .2s ease; }
  aside a:hover .material-symbols-outlined { transform: translateX(2px); }

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
</head>
<body class="bg-zinc-50 text-zinc-900 min-h-screen">

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
    <a href="${pageContext.request.contextPath}/admin/kho-dich-vu" class="nav-link"><span class="material-symbols-outlined text-[19px]">inventory_2</span>Kho & Dịch vụ<span class="ml-auto text-[10px] font-bold bg-amber-100 text-amber-700 px-1.5 py-0.5 rounded-md">3</span></a>
    <p class="text-[10px] font-bold uppercase tracking-widest text-zinc-400 px-3 mt-5 mb-1.5">Quản lý</p>
    <a href="${pageContext.request.contextPath}/admin/chi-nhanh" class="nav-link"><span class="material-symbols-outlined text-[19px]">location_on</span>Cơ Sở</a>
    <a href="${pageContext.request.contextPath}/admin/nhan-su" class="nav-link"><span class="material-symbols-outlined text-[19px]">groups</span>Nhân sự</a>
    <a href="${pageContext.request.contextPath}/admin/hoa-don" class="nav-link"><span class="material-symbols-outlined text-[19px]">receipt_long</span>Hóa đơn</a>
    <a href="${pageContext.request.contextPath}/admin/khuyen-mai" class="nav-link active"><span class="material-symbols-outlined text-[19px]" style="font-variation-settings:'FILL' 1">loyalty</span>Khuyến mãi</a>
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
      <h1 class="text-sm font-bold text-zinc-900 tracking-tight">Khuyến mãi</h1>
      <p class="text-xs text-zinc-555 text-zinc-500 flex items-center gap-1.5"><span class="material-symbols-outlined text-[12px]">database</span>Bảng KhuyenMai lọc theo CoSoID = CS01</p>
    </div>
  </div>
  <div class="flex items-center gap-1.5">
    <button onclick="location.href='HoTro.jsp'" class="hidden sm:flex items-center gap-1.5 h-9 px-3 rounded-lg border border-zinc-200 hover:bg-zinc-50 text-zinc-650 text-xs font-semibold">
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

  <!-- Stats -->
  <div class="grid grid-cols-2 sm:grid-cols-4 gap-3">
    <div class="card p-4 flex items-center gap-3 animate-fade-up" style="animation-delay: 0ms;">
      <div class="w-9 h-9 rounded-lg bg-green-50 flex items-center justify-center shrink-0 border border-green-100/50"><span class="material-symbols-outlined text-[18px] text-green-600">campaign</span></div>
      <div><p class="text-xs text-zinc-500 font-semibold">Đang chạy</p><p id="statActiveCount" class="text-xl font-extrabold text-green-600">0</p></div>
    </div>
    <div class="card p-4 flex items-center gap-3 animate-fade-up" style="animation-delay: 50ms;">
      <div class="w-9 h-9 rounded-lg bg-blue-50 flex items-center justify-center shrink-0 border border-blue-100/50"><span class="material-symbols-outlined text-[18px] text-blue-600">schedule</span></div>
      <div><p class="text-xs text-zinc-500 font-semibold">Sắp diễn ra</p><p id="statUpcomingCount" class="text-xl font-extrabold text-blue-600">0</p></div>
    </div>
    <div class="card p-4 flex items-center gap-3 animate-fade-up" style="animation-delay: 100ms;">
      <div class="w-9 h-9 rounded-lg bg-zinc-100 flex items-center justify-center shrink-0 border border-zinc-200/50"><span class="material-symbols-outlined text-[18px] text-zinc-500">history</span></div>
      <div><p class="text-xs text-zinc-500 font-semibold">Đã kết thúc</p><p id="statExpiredCount" class="text-xl font-extrabold text-zinc-555 text-zinc-600">0</p></div>
    </div>
    <div class="card p-4 flex items-center gap-3 animate-fade-up" style="animation-delay: 150ms;">
      <div class="w-9 h-9 rounded-lg bg-amber-50 flex items-center justify-center shrink-0 border border-amber-100/50"><span class="material-symbols-outlined text-[18px] text-amber-600">savings</span></div>
      <div><p class="text-xs text-zinc-500 font-semibold">Tổng đã giảm</p><p id="statTotalSaved" class="text-xl font-extrabold text-zinc-900">0 đ</p></div>
    </div>
  </div>

  <!-- Toolbar -->
  <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 animate-fade-up" style="animation-delay: 200ms;">
    <div class="flex items-center gap-2 flex-wrap">
      <!-- Status filter tabs -->
      <div class="flex rounded-lg border border-zinc-200 overflow-hidden bg-white text-sm">
        <button id="tabFilterAll" onclick="switchFilterTab('all')" class="promo-tab px-3.5 py-1.5 bg-zinc-900 text-white font-semibold transition-all">Tất cả</button>
        <button id="tabFilterActive" onclick="switchFilterTab('Đang chạy')" class="promo-tab px-3.5 py-1.5 text-zinc-500 hover:bg-zinc-50 transition-all font-medium">Đang chạy</button>
        <button id="tabFilterUpcoming" onclick="switchFilterTab('Sắp diễn ra')" class="promo-tab px-3.5 py-1.5 text-zinc-500 hover:bg-zinc-50 transition-all font-medium">Sắp tới</button>
        <button id="tabFilterExpired" onclick="switchFilterTab('Đã kết thúc')" class="promo-tab px-3.5 py-1.5 text-zinc-500 hover:bg-zinc-50 transition-all font-medium">Đã kết thúc</button>
      </div>
      <div class="relative">
        <span class="absolute left-3 top-1/2 -translate-y-1/2 material-symbols-outlined text-[15px] text-zinc-400 font-bold">search</span>
        <input id="searchPromo" type="text" autocomplete="off" placeholder="Tìm mã, tên khuyến mãi..." class="h-9 pl-8 pr-3 rounded-lg border border-zinc-200 bg-white text-sm focus:outline-none focus:ring-2 focus:ring-zinc-400 w-[220px]">
      </div>
    </div>
    <button onclick="document.getElementById('promoModal').classList.remove('hidden'); document.getElementById('promoModalCard').classList.add('animate-scale-in');" class="flex items-center gap-1.5 h-9 px-4 rounded-lg bg-zinc-900 text-white text-sm font-semibold hover:bg-zinc-800 active:scale-95 transition-all shrink-0 shadow-sm">
      <span class="material-symbols-outlined text-[16px] font-bold">add</span>Tạo khuyến mãi
    </button>
  </div>

  <!-- Promo cards grid -->
  <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4" id="promoGrid">
    <!-- Dynamic Cards Rendered Here -->
  </div>

</main>

<!-- SUCCESS TOAST NOTIFICATION -->
<div id="successToast" class="fixed bottom-6 right-6 bg-zinc-900 text-white rounded-2xl p-4 shadow-2xl border border-zinc-800 z-[9999] flex items-start gap-3 transition-all duration-350 translate-y-12 opacity-0 pointer-events-none w-80">
  <div class="w-8 h-8 rounded-full bg-emerald-500/20 text-emerald-400 flex items-center justify-center shrink-0">
    <span class="material-symbols-outlined text-[18px]">check</span>
  </div>
  <div class="flex-1">
    <p id="toastTitle" class="text-xs font-bold text-white">Thành công</p>
    <p id="toastMessage" class="text-[11px] text-zinc-400 mt-0.5">Yêu cầu đã được thực hiện.</p>
  </div>
</div>

<!-- Create/Edit Promo Modal -->
<div id="promoModal" class="hidden fixed inset-0 z-[80] flex items-center justify-center p-4">
  <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" onclick="closePromoModal()"></div>
  <div id="promoModalCard" class="relative bg-white rounded-2xl shadow-2xl w-full max-w-[500px] max-h-[90vh] overflow-y-auto z-10 border border-zinc-200">
    <div class="flex items-center justify-between px-6 py-4 border-b border-zinc-150">
      <h2 id="modalPromoTitle" class="text-base font-bold text-zinc-900">Tạo khuyến mãi mới</h2>
      <button onclick="closePromoModal()" class="p-1.5 rounded-lg hover:bg-zinc-100 flex items-center justify-center"><span class="material-symbols-outlined text-[18px] text-zinc-500">close</span></button>
    </div>
    <div class="px-6 py-4 flex flex-col gap-4 text-sm">
      <input type="hidden" id="editPromoId">
      
      <div class="grid grid-cols-2 gap-3">
        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-semibold text-zinc-500">Mã khuyến mãi <span class="text-red-500">*</span></label>
          <input type="text" id="promoCode" placeholder="KM008" class="h-9 px-3 rounded-lg border border-zinc-200 focus:outline-none focus:ring-2 focus:ring-zinc-400 uppercase font-mono font-bold">
        </div>
        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-semibold text-zinc-500">Tên chương trình <span class="text-red-500">*</span></label>
          <input type="text" id="promoName" placeholder="VD: Khai trương sân mới" class="h-9 px-3 rounded-lg border border-zinc-200 focus:outline-none focus:ring-2 focus:ring-zinc-400">
        </div>
      </div>
      
      <!-- Discount type -->
      <div class="flex flex-col gap-1.5">
        <label class="text-xs font-semibold text-zinc-500">Loại giảm giá <span class="text-red-500">*</span></label>
        <div class="grid grid-cols-3 gap-2" id="discountTypeGroup">
          <label class="flex flex-col items-center gap-1.5 p-2.5 rounded-xl border border-zinc-200 cursor-pointer hover:bg-zinc-50 has-[:checked]:border-zinc-900 has-[:checked]:bg-zinc-50/50 has-[:checked]:ring-2 has-[:checked]:ring-zinc-900/5 transition-all">
            <input type="radio" name="discountType" value="Phần trăm" checked class="sr-only" onchange="toggleDiscountSymbol('%')">
            <span class="material-symbols-outlined text-[18px] text-zinc-600">percent</span>
            <span class="text-xs font-bold text-zinc-800">Phần trăm</span>
          </label>
          <label class="flex flex-col items-center gap-1.5 p-2.5 rounded-xl border border-zinc-200 cursor-pointer hover:bg-zinc-50 has-[:checked]:border-zinc-900 has-[:checked]:bg-zinc-50/50 has-[:checked]:ring-2 has-[:checked]:ring-zinc-900/5 transition-all">
            <input type="radio" name="discountType" value="Cố định" class="sr-only" onchange="toggleDiscountSymbol('đ')">
            <span class="material-symbols-outlined text-[18px] text-zinc-600">payments</span>
            <span class="text-xs font-bold text-zinc-800">Tiền mặt</span>
          </label>
          <label class="flex flex-col items-center gap-1.5 p-2.5 rounded-xl border border-zinc-200 cursor-pointer hover:bg-zinc-50 has-[:checked]:border-zinc-900 has-[:checked]:bg-zinc-50/50 has-[:checked]:ring-2 has-[:checked]:ring-zinc-900/5 transition-all">
            <input type="radio" name="discountType" value="Tặng kèm" class="sr-only" onchange="toggleDiscountSymbol('giờ')">
            <span class="material-symbols-outlined text-[18px] text-zinc-600">redeem</span>
            <span class="text-xs font-bold text-zinc-800">Tặng kèm</span>
          </label>
        </div>
      </div>
      
      <div class="grid grid-cols-2 gap-3">
        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-semibold text-zinc-500">Giá trị giảm <span class="text-red-500">*</span></label>
          <div class="relative">
            <input type="number" id="promoVal" placeholder="20" class="h-9 w-full pl-3 pr-10 rounded-lg border border-zinc-200 focus:outline-none focus:ring-2 focus:ring-zinc-400 font-bold">
            <span id="promoValSymbol" class="absolute right-3 top-1/2 -translate-y-1/2 text-xs font-bold text-zinc-400">%</span>
          </div>
        </div>
        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-semibold text-zinc-500">Đơn tối thiểu (đ)</label>
          <input type="number" id="promoMinBill" placeholder="100000" class="h-9 px-3 rounded-lg border border-zinc-200 focus:outline-none focus:ring-2 focus:ring-zinc-400">
        </div>
      </div>
      
      <div class="flex flex-col gap-1.5">
        <label class="text-xs font-semibold text-zinc-500">Giảm tối đa (đ) <span class="text-[10px] text-zinc-400 font-normal">(Chừa trống nếu không giới hạn)</span></label>
        <input type="number" id="promoMaxDiscount" placeholder="100000" class="h-9 px-3 rounded-lg border border-zinc-200 focus:outline-none focus:ring-2 focus:ring-zinc-400">
      </div>
      
      <div class="grid grid-cols-2 gap-3">
        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-semibold text-zinc-500">Ngày bắt đầu <span class="text-red-500">*</span></label>
          <input type="date" id="promoStart" class="h-9 px-3 rounded-lg border border-zinc-200 focus:outline-none focus:ring-2 focus:ring-zinc-400">
        </div>
        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-semibold text-zinc-500">Ngày kết thúc <span class="text-red-500">*</span></label>
          <input type="date" id="promoEnd" class="h-9 px-3 rounded-lg border border-zinc-200 focus:outline-none focus:ring-2 focus:ring-zinc-400">
        </div>
      </div>
      
      <div class="grid grid-cols-2 gap-3">
        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-semibold text-zinc-500">Tổng lượt tối đa</label>
          <input type="number" id="promoLimit" placeholder="100" class="h-9 px-3 rounded-lg border border-zinc-200 focus:outline-none focus:ring-2 focus:ring-zinc-400">
        </div>
        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-semibold text-zinc-500">Áp dụng cho bộ môn</label>
          <select id="promoApplyGroup" class="h-9 px-3 rounded-lg border border-zinc-200 focus:outline-none focus:ring-2 focus:ring-zinc-400 text-zinc-700 bg-white font-medium">
            <option value="Tất cả sân">Tất cả bộ môn</option>
            <option value="Cầu lông">Cầu lông</option>
            <option value="Pickleball">Pickleball</option>
            <option value="Bóng đá">Bóng đá</option>
            <option value="Tennis">Tennis</option>
          </select>
        </div>
      </div>
      
      <div class="flex flex-col gap-1.5">
        <label class="text-xs font-semibold text-zinc-500">Mô tả điều kiện áp dụng</label>
        <textarea id="promoDesc" rows="2" placeholder="Ví dụ: Chỉ áp dụng vào khung giờ vàng từ 17h đến 20h cuối tuần..." class="px-3 py-2 rounded-lg border border-zinc-200 text-sm resize-none focus:outline-none focus:ring-2 focus:ring-zinc-400"></textarea>
      </div>
    </div>
    
    <div class="px-6 py-4 border-t border-zinc-150 bg-zinc-50 flex justify-between items-center">
      <span class="text-[10px] text-zinc-450 font-bold font-mono uppercase tracking-wider text-zinc-400">Bảng KhuyenMai</span>
      <div class="flex gap-2">
        <button onclicksibility_off</span></button></div></div>
    </div>
    <div class="px-6 pb-5 flex gap-3 justify-end">
      <button onclick="document.getElementById('changePwModal').classList.add('hidden')" class="h-10 px-5 rounded-lg border border-zinc-200 text-sm font-semibold text-zinc-600 hover:bg-zinc-50 transition-colors">Hủy</button>
      <button onclick="savePassword()" class="h-10 px-5 rounded-lg bg-blue-700 text-white text-sm font-semibold hover:opacity-90 transition-opacity active:scale-95">Đổi mật khẩu</button>
    </div>
  </div>
</div>

<script>
// Mock data aligning with database schema (KhuyenMai table + specific fields)
let mockPromotions = [
  <c:forEach items="${promotions}" var="p" varStatus="status">
  {
    KhuyenMaiID: ${p.khuyenMaiID},
    MaCode: '${p.maCode}',
    TenKM: '${p.moTa != null ? p.moTa.split(" - ")[0].replace("'", "\\'") : ""}',
    MoTa: '${p.moTa != null ? p.moTa.replace("'", "\\'") : ""}',
    LoaiGiam: '${p.loaiGiam}',
    GiaTriGiam: ${p.giaTriGiam},
    NgayBatDau: '${p.ngayBatDau}',
    NgayKetThuc: '${p.ngayKetThuc}',
    SoLanToiDa: ${p.soLanToiDa != null ? p.soLanToiDa : 'null'},
    SoLanDaDung: ${p.soLanDaDung},
    TrangThai: '${p.trangThai}',
    DonToiThieu: 0,
    GiamToiDa: 0,
    ApDung: 'Tất cả sân'
  }${!status.last ? ',' : ''}
  </c:forEach>
];

// Active state
let currentTabFilter = 'all';
const searchInput = document.getElementById('searchPromo');
const promoGrid = document.getElementById('promoGrid');

// Format Cash helper
function formatVND(val) {
  return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(val).replace('₫', 'đ');
}

function formatDate(isoString) {
  if (!isoString) return '-';
  const parts = isoString.split('-');
  return `\${parts[2]}/\${parts[1]}`;
}

// Accent / Diacritics remover utility (Insensitive Vietnamese search helper)
function removeSign(str) {
  return str
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/đ/g, 'd')
    .replace(/Đ/g, 'D');
}

// Success toast
function showToast(title, msg) {
  const toast = document.getElementById('successToast');
  document.getElementById('toastTitle').textContent = title;
  document.getElementById('toastMessage').textContent = msg;
  toast.classList.remove('opacity-0', 'translate-y-12', 'pointer-events-none');
  setTimeout(() => {
    toast.classList.add('opacity-0', 'translate-y-12', 'pointer-events-none');
  }, 4000);
}

// Tab Switching
function switchFilterTab(tab) {
  currentTabFilter = tab;
  document.querySelectorAll('.promo-tab').forEach(btn => {
    btn.className = 'promo-tab px-3.5 py-1.5 text-zinc-500 hover:bg-zinc-50 transition-all font-medium';
  });
  
  if (tab === 'all') {
    document.getElementById('tabFilterAll').className = 'promo-tab px-3.5 py-1.5 bg-zinc-900 text-white font-semibold transition-all';
  } else if (tab === 'Đang chạy') {
    document.getElementById('tabFilterActive').className = 'promo-tab px-3.5 py-1.5 bg-zinc-900 text-white font-semibold transition-all';
  } else if (tab === 'Sắp diễn ra') {
    document.getElementById('tabFilterUpcoming').className = 'promo-tab px-3.5 py-1.5 bg-zinc-900 text-white font-semibold transition-all';
  } else {
    document.getElementById('tabFilterExpired').className = 'promo-tab px-3.5 py-1.5 bg-zinc-900 text-white font-semibold transition-all';
  }
  
  renderGrid();
}

// Dropdown Action toggler
function togglePromoMenu(event, id) {
  event.stopPropagation();
  document.querySelectorAll('[id^="pm"]').forEach(m => {
    if (m.id !== id) m.classList.add('hidden');
  });
  document.getElementById(id).classList.toggle('hidden');
}

// Setup global close actions for menus
document.addEventListener('click', () => {
  document.querySelectorAll('[id^="pm"]').forEach(m => m.classList.add('hidden'));
});

// Render dynamic stats bar
function renderStats() {
  const active = mockPromotions.filter(p => p.TrangThai === 'Đang chạy').length;
  const upcoming = mockPromotions.filter(p => p.TrangThai === 'Sắp diễn ra').length;
  const expired = mockPromotions.filter(p => p.TrangThai === 'Đã kết thúc' || p.TrangThai === 'Đã dừng').length;

  document.getElementById('statActiveCount').textContent = active;
  document.getElementById('statUpcomingCount').textContent = upcoming;
  document.getElementById('statExpiredCount').textContent = expired;

  // Compute actual savings in real-time
  let totalSaved = 0;
  mockPromotions.forEach(p => {
    if (p.LoaiGiam === 'Phần trăm') {
      totalSaved += p.SoLanDaDung * (p.GiaTriGiam * 1000); 
    } else if (p.LoaiGiam === 'Cố định') {
      totalSaved += p.SoLanDaDung * p.GiaTriGiam;
    } else {
      totalSaved += p.SoLanDaDung * 80000; 
    }
  });

  document.getElementById('statTotalSaved').textContent = formatVND(totalSaved);
}

// Render dynamic card grid
function renderGrid() {
  const query = removeSign(searchInput.value.toLowerCase().trim());
  promoGrid.innerHTML = '';

  let filtered = mockPromotions.filter(p => {
    const codeClean = removeSign(p.MaCode.toLowerCase());
    const nameClean = removeSign(p.TenKM.toLowerCase());
    const descClean = removeSign(p.MoTa.toLowerCase());

    const matchesSearch = codeClean.includes(query) || 
      nameClean.includes(query) || 
      descClean.includes(query);

    let matchesTab = true;
    if (currentTabFilter !== 'all') {
      if (currentTabFilter === 'Đã kết thúc') {
        matchesTab = (p.TrangThai === 'Đã kết thúc' || p.TrangThai === 'Đã dừng');
      } else {
        matchesTab = (p.TrangThai === currentTabFilter);
      }
    }

    return matchesSearch && matchesTab;
  });

  if (filtered.length === 0) {
    promoGrid.innerHTML = `
      <div class="col-span-1 md:col-span-2 xl:col-span-3 text-center py-12 text-zinc-400 text-sm font-medium">
        Không tìm thấy chương trình khuyến mãi nào khớp với bộ lọc.
      </div>
    `;
    return;
  }

  filtered.forEach((p, index) => {
    const card = document.createElement('div');
    card.className = `promo-card animate-fade-up \${p.TrangThai === 'Đã kết thúc' || p.TrangThai === 'Đã dừng' ? 'opacity-65' : ''}`;
    card.style.animationDelay = `\${index * 55}ms`;

    let topBorderClass = 'h-2 bg-green-500';
    let badgeClass = 'badge badge-green';
    if (p.TrangThai === 'Sắp diễn ra') {
      topBorderClass = 'h-2 bg-blue-500';
      badgeClass = 'badge badge-blue';
    } else if (p.TrangThai === 'Đã kết thúc' || p.TrangThai === 'Đã dừng') {
      topBorderClass = 'h-2 bg-zinc-300';
      badgeClass = 'badge badge-gray';
    }

    let leftBlock = '';
    if (p.LoaiGiam === 'Phần trăm') {
      leftBlock = `<span class="text-lg font-black text-green-600">\${p.GiaTriGiam}%</span>`;
    } else if (p.LoaiGiam === 'Cố định') {
      leftBlock = `<span class="text-xs font-black text-green-600">-\${p.GiaTriGiam / 1000}k</span>`;
    } else {
      leftBlock = `<span class="material-symbols-outlined text-[20px] text-green-600">redeem</span>`;
    }

    // Limit calculations
    let limitText = 'Không giới hạn';
    let progressPercent = 0;
    if (p.SoLanToiDa) {
      limitText = `\${p.SoLanDaDung} / \${p.SoLanToiDa} lượt`;
      progressPercent = (p.SoLanDaDung / p.SoLanToiDa) * 100;
    }

    // Days calculation
    const today = new Date('2026-05-19');
    const end = new Date(p.NgayKetThuc);
    const start = new Date(p.NgayBatDau);
    let remText = '';
    if (p.TrangThai === 'Đang chạy') {
      const diff = Math.ceil((end - today) / (1000 * 60 * 60 * 24));
      remText = diff >= 0 ? `Còn \${diff} ngày` : 'Liên tục';
    } else if (p.TrangThai === 'Sắp diễn ra') {
      const diff = Math.ceil((start - today) / (1000 * 60 * 60 * 24));
      remText = `Còn \${diff} ngày nữa`;
    } else {
      remText = 'Đã kết thúc';
    }

    // Simulated saved amount
    let sumSaved = 0;
    if (p.LoaiGiam === 'Phần trăm') {
      sumSaved = p.SoLanDaDung * (p.GiaTriGiam * 1000);
    } else if (p.LoaiGiam === 'Cố định') {
      sumSaved = p.SoLanDaDung * p.GiaTriGiam;
    } else {
      sumSaved = p.SoLanDaDung * 80000;
    }

    card.innerHTML = `
      <div class="\${topBorderClass}"></div>
      <div class="p-4 flex-1 flex flex-col justify-between">
        <div>
          <div class="flex items-start justify-between mb-2">
            <div>
              <div class="flex items-center gap-2 mb-1.5">
                <span class="\${badgeClass}">\${p.TrangThai}</span>
                <span class="text-[10px] text-zinc-400 font-mono font-semibold">\${p.MaCode}</span>
              </div>
              <h3 class="text-[14px] font-bold text-zinc-900 leading-tight">\${p.TenKM}</h3>
            </div>
            <div class="relative shrink-0">
              <button onclick="togglePromoMenu(event, 'pm\${p.KhuyenMaiID}')" class="p-1 rounded-lg hover:bg-zinc-100 flex items-center justify-center transition-colors"><span class="material-symbols-outlined text-[16px] text-zinc-400 font-bold">more_vert</span></button>
              <div id="pm\${p.KhuyenMaiID}" class="hidden absolute right-0 top-full mt-1.5 w-[150px] bg-white rounded-xl shadow-xl border border-zinc-200 py-1.5 z-[70] overflow-hidden font-sans">
                <button onclick="openEditPromoModal(\${p.KhuyenMaiID})" class="flex items-center gap-2 w-full px-3 py-1.5 text-xs text-zinc-700 hover:bg-zinc-50 transition-colors text-left"><span class="material-symbols-outlined text-[14px]">edit</span>Chỉnh sửa</button>
                <button onclick="clonePromoAction(\${p.KhuyenMaiID})" class="flex items-center gap-2 w-full px-3 py-1.5 text-xs text-zinc-700 hover:bg-zinc-50 transition-colors text-left"><span class="material-symbols-outlined text-[14px]">content_copy</span>Nhân bản</button>
                <button onclick="togglePromoStatus(\${p.KhuyenMaiID})" class="flex items-center gap-2 w-full px-3 py-1.5 text-xs text-zinc-700 hover:bg-zinc-50 transition-colors text-left font-medium">
                  <span class="material-symbols-outlined text-[14px]">\${p.TrangThai === 'Đang chạy' ? 'stop_circle' : 'play_circle'}</span>
                  <span>\${p.TrangThai === 'Đang chạy' ? 'Tạm dừng' : 'Kích hoạt'}</span>
                </button>
                <div class="border-t border-zinc-100 mt-1 pt-1"><button onclick="deletePromoAction(\${p.KhuyenMaiID})" class="flex items-center gap-2 w-full px-3 py-1.5 text-xs text-red-650 hover:bg-red-50 transition-colors text-left font-medium"><span class="material-symbols-outlined text-[14px]">delete</span>Xóa bỏ</button></div>
              </div>
            </div>
          </div>
          
          <div class="flex items-center gap-3 bg-zinc-50 p-2.5 rounded-xl border border-zinc-200/50 my-3">
            <div class="w-12 h-12 rounded-lg bg-green-50/50 flex items-center justify-center shrink-0 border border-green-100/50">
              \${leftBlock}
            </div>
            <div class="min-w-0 flex-1">
              <p class="text-xs text-zinc-600 font-medium truncate">\${p.MoTa}</p>
              <p class="text-[10px] text-zinc-400 mt-0.5 font-medium">Áp dụng: <span class="font-bold text-zinc-500">\${p.ApDung}</span>\${p.DonToiThieu ? ` · Đơn ≥ \${formatVND(p.DonToiThieu)}` : ''}</p>
            </div>
          </div>
        </div>
        
        <div>
          \${p.SoLanToiDa ? `
            <div class="mb-3">
              <div class="flex justify-between text-[10px] text-zinc-400 font-semibold mb-1">
                <span>Lượt sử dụng</span>
                <span>\${limitText}</span>
              </div>
              <div class="w-full h-1.5 bg-zinc-100 rounded-full overflow-hidden border border-zinc-200/30">
                <div class="h-full bg-emerald-500 rounded-full transition-all" style="width:\${progressPercent}%"></div>
              </div>
            </div>
          ` : ''}
          
          <div class="flex items-center justify-between text-xs text-zinc-400 border-t border-zinc-100 pt-3 mt-1 font-medium">
            <span class="flex items-center gap-1"><span class="material-symbols-outlined text-[13px]">calendar_today</span>\${formatDate(p.NgayBatDau)} – \${formatDate(p.NgayKetThuc)}</span>
            <span class="font-bold \${p.TrangThai === 'Đang chạy' ? 'text-green-600' : p.TrangThai === 'Sắp diễn ra' ? 'text-blue-600' : 'text-zinc-500'}">\${remText}</span>
          </div>
          \${p.SoLanDaDung > 0 ? `
            <div class="flex items-center justify-between text-[10px] text-zinc-400 mt-1.5 font-medium">
              <span>Đã tiết kiệm cho khách:</span>
              <span class="font-semibold text-zinc-650">\${formatVND(sumSaved)}</span>
            </div>
          ` : ''}
        </div>
      </div>
    `;
    promoGrid.appendChild(card);
  });
}

// Modal handling
function toggleDiscountSymbol(sym) {
  document.getElementById('promoValSymbol').textContent = sym;
}

function closePromoModal() {
  document.getElementById('promoModalCard').classList.remove('animate-scale-in');
  document.getElementById('promoModal').classList.add('hidden');
  resetPromoForm();
}

function resetPromoForm() {
  document.getElementById('editPromoId').value = '';
  document.getElementById('promoCode').value = '';
  document.getElementById('promoName').value = '';
  document.getElementById('promoVal').value = '';
  document.getElementById('promoMinBill').value = '';
  document.getElementById('promoMaxDiscount').value = '';
  document.getElementById('promoStart').value = '';
  document.getElementById('promoEnd').value = '';
  document.getElementById('promoLimit').value = '';
  document.getElementById('promoDesc').value = '';
  document.getElementById('promoApplyGroup').value = 'Tất cả sân';
  document.getElementById('modalPromoTitle').textContent = 'Tạo khuyến mãi mới';
  document.getElementById('promoCode').disabled = false;
  
  // Reset radios
  const radios = document.getElementsByName('discountType');
  radios[0].checked = true;
  toggleDiscountSymbol('%');
}

function openEditPromoModal(id) {
  const promo = mockPromotions.find(p => p.KhuyenMaiID === id);
  if (!promo) return;

  document.getElementById('editPromoId').value = promo.KhuyenMaiID;
  document.getElementById('promoCode').value = promo.MaCode;
  document.getElementById('promoCode').disabled = true;
  document.getElementById('promoName').value = promo.TenKM;
  document.getElementById('promoVal').value = promo.GiaTriGiam;
  document.getElementById('promoMinBill').value = promo.DonToiThieu || '';
  document.getElementById('promoMaxDiscount').value = promo.GiamToiDa || '';
  document.getElementById('promoStart').value = promo.NgayBatDau;
  document.getElementById('promoEnd').value = promo.NgayKetThuc;
  document.getElementById('promoLimit').value = promo.SoLanToiDa || '';
  document.getElementById('promoDesc').value = promo.MoTa;
  document.getElementById('promoApplyGroup').value = promo.ApDung;

  const radios = document.getElementsByName('discountType');
  radios.forEach(r => {
    if (r.value === promo.LoaiGiam) {
      r.checked = true;
      const symbols = { 'Phần trăm': '%', 'Cố định': 'đ', 'Tặng kèm': 'giờ' };
      toggleDiscountSymbol(symbols[promo.LoaiGiam]);
    }
  });

  document.getElementById('modalPromoTitle').textContent = 'Chỉnh sửa khuyến mãi';
  document.getElementById('promoModal').classList.remove('hidden');
  document.getElementById('promoModalCard').classList.add('animate-scale-in');
}

function savePromoAction() {
  const idVal = document.getElementById('editPromoId').value;
  const code = document.getElementById('promoCode').value.toUpperCase().trim();
  const name = document.getElementById('promoName').value.trim();
  const val = parseFloat(document.getElementById('promoVal').value);
  const start = document.getElementById('promoStart').value;
  const end = document.getElementById('promoEnd').value;
  const minBill = parseFloat(document.getElementById('promoMinBill').value) || 0;
  const maxDisc = parseFloat(document.getElementById('promoMaxDiscount').value) || 0;
  const limit = parseInt(document.getElementById('promoLimit').value) || null;
  const desc = document.getElementById('promoDesc').value.trim();
  const applyGroup = document.getElementById('promoApplyGroup').value;

  if (!code || !name || isNaN(val) || !start || !end) {
    alert('Vui lòng nhập đầy đủ các trường bắt buộc (*)');
    return;
  }

  const selectedRadio = Array.from(document.getElementsByName('discountType')).find(r => r.checked);
  const discountType = selectedRadio ? selectedRadio.value : 'Phần trăm';

  const form = document.createElement('form');
  form.method = 'POST';
  form.action = '${pageContext.request.contextPath}/admin/khuyen-mai';

  const actionField = document.createElement('input');
  actionField.type = 'hidden';
  actionField.name = 'action';
  actionField.value = idVal ? 'update' : 'add';
  form.appendChild(actionField);

  if (idVal) {
    const idField = document.createElement('input');
    idField.type = 'hidden';
    idField.name = 'promoId';
    idField.value = idVal;
    form.appendChild(idField);
  }

  const fields = {
    promoCode: code,
    promoName: name,
    promoVal: val,
    promoStart: start,
    promoEnd: end,
    promoMinBill: minBill,
    promoMaxDiscount: maxDisc,
    promoLimit: limit || '',
    promoDesc: desc,
    promoApplyGroup: applyGroup,
    discountType: discountType
  };

  for (const [key, value] of Object.entries(fields)) {
    const input = document.createElement('input');
    input.type = 'hidden';
    input.name = key;
    input.value = value;
    form.appendChild(input);
  }

  document.body.appendChild(form);
  form.submit();
}

function clonePromoAction(id) {
  const promo = mockPromotions.find(p => p.KhuyenMaiID === id);
  if (!promo) return;

  const newId = mockPromotions.length > 0 ? Math.max(...mockPromotions.map(p => p.KhuyenMaiID)) + 1 : 1;
  const newCode = `\${promo.MaCode}_CLONE`;
  
  mockPromotions.unshift({
    ...promo,
    KhuyenMaiID: newId,
    MaCode: newCode,
    TenKM: `\${promo.TenKM} - Sao bản`,
    SoLanDaDung: 0
  });

  renderAll();
  showToast('Đã nhân bản', `Đã nhân bản chương trình khuyến mãi thành mã mới: \${newCode}.`);
}

function togglePromoStatus(id) {
  const form = document.createElement('form');
  form.method = 'POST';
  form.action = '${pageContext.request.contextPath}/admin/khuyen-mai';
  
  const actionField = document.createElement('input');
  actionField.type = 'hidden';
  actionField.name = 'action';
  actionField.value = 'stop';
  form.appendChild(actionField);
  
  const idField = document.createElement('input');
  idField.type = 'hidden';
  idField.name = 'promoId';
  idField.value = id;
  form.appendChild(idField);
  
  document.body.appendChild(form);
  form.submit();
}

function deletePromoAction(id) {
  const promo = mockPromotions.find(p => p.KhuyenMaiID === id);
  if (!promo) return;
  
  if (confirm(`Bạn có chắc chắn muốn xóa bỏ chương trình khuyến mãi \${promo.MaCode} khỏi Cơ Sở?`)) {
    const form = document.createElement('form');
    form.method = 'POST';
    form.action = '${pageContext.request.contextPath}/admin/khuyen-mai';
    
    const actionField = document.createElement('input');
    actionField.type = 'hidden';
    actionField.name = 'action';
    actionField.value = 'delete';
    form.appendChild(actionField);
    
    const idField = document.createElement('input');
    idField.type = 'hidden';
    idField.name = 'promoId';
    idField.value = id;
    form.appendChild(idField);
    
    document.body.appendChild(form);
    form.submit();
  }
}

// Global refresh
function renderAll() {
  renderGrid();
  renderStats();
}



// DOM Setup
document.addEventListener('DOMContentLoaded', () => {
  searchInput.addEventListener('input', renderGrid);

  // Mobile sidebar menu toggler
  const mobileMenuBtn = document.getElementById('mobileMenuBtn');
  const sidebar = document.getElementById('sidebar');
  if (mobileMenuBtn && sidebar) {
    mobileMenuBtn.addEventListener('click', (e) => {
      e.stopPropagation();
      sidebar.classList.toggle('-translate-x-full');
    });
    document.addEventListener('click', (e) => {
      if (!sidebar.contains(e.target) && !mobileMenuBtn.contains(e.target)) {
        sidebar.classList.add('-translate-x-full');
      }
    });
  }



  renderAll();

  // Show status toasts from servlet
  <c:if test="${not empty sessionScope.message}">
    showToast('Thành công', '${sessionScope.message}');
    <c:remove var="message" scope="session"/>
  </c:if>
  <c:if test="${not empty sessionScope.error}">
    alert('${sessionScope.error}');
    <c:remove var="error" scope="session"/>
  </c:if>
});
</script>
</body>
</html>
