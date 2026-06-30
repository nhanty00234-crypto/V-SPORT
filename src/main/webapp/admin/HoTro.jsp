<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Hỗ trợ Admin — Cơ Sở</title>
<script src="https://cdn.tailwindcss.com"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200">
<style>
  body { font-family: 'Inter', sans-serif; }
  .nav-link { display:flex;align-items:center;gap:11px;padding:10px 14px;border-radius:10px;color:#52525b;font-size:14px;font-weight:500;text-decoration:none;transition:all .15s;white-space:nowrap;position:relative; }
  .nav-link:hover { background:#f4f4f5;color:#18181b; }
  .nav-link.active { background:#f4f4f5;color:#18181b;font-weight:600; }
  .nav-link.active::before { content:''; position:absolute; left:0; top:8px; bottom:8px; width:3px; background:#27272a; border-radius:0 3px 3px 0; }
  .card { background:#fff;border:1px solid #e4e4e7;border-radius:16px; transition:all .2s; }
  .badge { display:inline-flex;align-items:center;padding:4px 10px;border-radius:8px;font-size:11px;font-weight:600; }
  .badge-green { background:#dcfce7;color:#15803d; }
  .badge-amber { background:#fef3c7;color:#b45309; }
  .badge-red { background:#fee2e2;color:#b91c1c; }
  .badge-gray { background:#f4f4f5;color:#52525b; }
  
  ::-webkit-scrollbar{width:6px;height:6px}::-webkit-scrollbar-track{background:transparent}::-webkit-scrollbar-thumb{background:#d4d4d8;border-radius:6px}
  ::-webkit-scrollbar-thumb:hover{background:#a1a1aa}
  
  @keyframes fadeUp { from { opacity:0; transform:translateY(8px); } to { opacity:1; transform:translateY(0); } }
  @keyframes pop { 0% { opacity:0; transform:scale(.96); } 100% { opacity:1; transform:scale(1); } }
  @keyframes pulse-dot { 0%,100%{box-shadow:0 0 0 0 rgba(34,197,94,.4);} 50%{box-shadow:0 0 0 6px rgba(34,197,94,0);} }
  @keyframes pulse-red-dot { 0%,100%{box-shadow:0 0 0 0 rgba(239,68,68,.4);} 50%{box-shadow:0 0 0 6px rgba(239,68,68,0);} }
  
  .chat-bubble { animation: fadeUp .25s ease both; }
  .live-dot { animation: pulse-dot 1.6s ease-in-out infinite; }
  .urgent-dot { animation: pulse-red-dot 1.2s ease-in-out infinite; }
  
  button { transition: transform .1s ease, opacity .15s ease, background-color .15s ease; }
  button:active:not([disabled]) { transform: scale(.97); }

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
    <a href="${pageContext.request.contextPath}/admin/khuyen-mai" class="nav-link"><span class="material-symbols-outlined text-[19px]">loyalty</span>Khuyến mãi</a>
    <p class="text-[10px] font-bold uppercase tracking-widest text-zinc-400 px-3 mt-5 mb-1.5">Hỗ trợ</p>
    <a href="#" class="nav-link active"><span class="material-symbols-outlined text-[19px]">contact_support</span>Hỗ trợ Admin</a>
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
<header class="h-[64px] fixed top-0 right-0 left-0 lg:left-[248px] bg-white/80 backdrop-blur-lg border-b border-zinc-200 z-20 flex items-center justify-between px-4 lg:px-6">
  <div class="flex items-center gap-3">
    <button id="mobileMenuBtn" class="lg:hidden p-2 rounded-lg hover:bg-zinc-100 text-zinc-500"><span class="material-symbols-outlined text-[20px]">menu</span></button>
    <div>
      <h1 class="text-sm font-bold text-zinc-900 tracking-tight">Hỗ trợ kỹ thuật & Vận hành</h1>
      <p class="text-xs text-zinc-500 flex items-center gap-1.5"><span class="material-symbols-outlined text-[12px]">support_agent</span>Liên hệ trực tiếp Quản trị viên hệ thống</p>
    </div>
  </div>
  <div class="flex items-center gap-1.5">
    <button onclick="location.href='HoTro.html'" class="hidden sm:flex items-center gap-1.5 h-9 px-3 rounded-lg bg-blue-50 text-blue-700 border border-blue-200 hover:bg-blue-100 text-xs font-semibold">
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
<main class="lg:ml-[248px] mt-[64px] p-4 lg:p-6 flex flex-col lg:flex-row gap-5 h-[calc(100vh-64px)] overflow-hidden">
  
  <!-- Left Panel: Support Tickets List -->
  <section class="w-full lg:w-[360px] bg-white border border-zinc-200 rounded-2xl flex flex-col overflow-hidden shrink-0 shadow-sm" data-aos="fade-right">
    <div class="p-4 border-b border-zinc-200 flex items-center justify-between gap-3">
      <div class="relative flex-1">
        <span class="absolute left-3 top-1/2 -translate-y-1/2 material-symbols-outlined text-[18px] text-zinc-400">search</span>
        <input type="text" id="searchTickets" oninput="filterTickets(this.value)" placeholder="Tìm kiếm yêu cầu..." class="w-full h-9 pl-9 pr-3 rounded-lg border border-zinc-200 text-xs text-zinc-800 focus:border-blue-500 focus:outline-none transition-colors">
      </div>
      <button onclick="openNewTicketModal()" class="h-9 px-3.5 rounded-lg bg-gradient-to-r from-blue-600 to-blue-700 text-white text-xs font-bold shadow-md shadow-blue-100 hover:opacity-95 transition-opacity flex items-center gap-1">
        <span class="material-symbols-outlined text-[16px]">add_circle</span>Yêu cầu mới
      </button>
    </div>
    
    <!-- Filter Tabs -->
    <div class="px-4 py-2 border-b border-zinc-100 flex gap-1.5 bg-zinc-50/50">
      <button onclick="switchTab('all')" id="tab-all" class="px-3 py-1 rounded-md text-[11px] font-bold bg-white border border-zinc-200 text-zinc-700 shadow-sm transition-all">Tất cả</button>
      <button onclick="switchTab('open')" id="tab-open" class="px-3 py-1 rounded-md text-[11px] font-semibold text-zinc-500 hover:bg-zinc-100 transition-all flex items-center gap-1"><span class="w-1.5 h-1.5 rounded-full bg-green-500"></span>Đang mở</button>
      <button onclick="switchTab('resolved')" id="tab-resolved" class="px-3 py-1 rounded-md text-[11px] font-semibold text-zinc-500 hover:bg-zinc-100 transition-all">Đã giải quyết</button>
    </div>
    
    <!-- Tickets List -->
    <div class="flex-1 overflow-y-auto p-2.5 flex flex-col gap-2" id="ticketsListContainer">
      <!-- Default Ticket 1 (Active) -->
      <div onclick="selectTicket('TK-4829')" id="card-TK-4829" class="p-3.5 rounded-xl border border-blue-200 bg-blue-50/40 hover:bg-blue-50/70 transition-all cursor-pointer relative group flex items-start gap-3">
        <div class="w-9 h-9 rounded-lg bg-blue-100 text-blue-700 flex items-center justify-center shrink-0">
          <span class="material-symbols-outlined text-[18px]">inventory_2</span>
        </div>
        <div class="flex-1 min-w-0">
          <div class="flex items-center justify-between gap-2 mb-1">
            <span class="text-[10px] font-bold text-blue-700 font-mono tracking-wider">#TK-4829</span>
            <span class="text-[10px] text-zinc-400">14:30</span>
          </div>
          <p class="text-xs font-bold text-zinc-900 truncate group-hover:text-blue-700 transition-colors">Cấp thêm thiết bị POS & Máy in bill</p>
          <p class="text-[11px] text-zinc-500 truncate mt-0.5">Anh Nhân: Đơn hàng sẽ giao vào chiều mai...</p>
          <div class="flex items-center gap-2 mt-2">
            <span class="badge badge-green"><span class="w-1.5 h-1.5 rounded-full bg-green-500 mr-1.5 live-dot"></span>Đang mở</span>
            <span class="text-[9px] font-semibold uppercase tracking-wider text-red-600 bg-red-50 px-1.5 py-0.5 rounded">Ưu tiên cao</span>
          </div>
        </div>
      </div>
      
      <!-- Default Ticket 2 -->
      <div onclick="selectTicket('TK-3920')" id="card-TK-3920" class="p-3.5 rounded-xl border border-zinc-200 bg-white hover:bg-zinc-50 transition-all cursor-pointer relative group flex items-start gap-3">
        <div class="w-9 h-9 rounded-lg bg-amber-100 text-amber-700 flex items-center justify-center shrink-0">
          <span class="material-symbols-outlined text-[18px]">payments</span>
        </div>
        <div class="flex-1 min-w-0">
          <div class="flex items-center justify-between gap-2 mb-1">
            <span class="text-[10px] font-bold text-zinc-500 font-mono tracking-wider">#TK-3920</span>
            <span class="text-[10px] text-zinc-400">01/05</span>
          </div>
          <p class="text-xs font-bold text-zinc-900 truncate group-hover:text-blue-700 transition-colors">Sự cố doanh thu ngày Lễ 30/4</p>
          <p class="text-[11px] text-zinc-500 truncate mt-0.5">Hệ thống: Đang chờ phê duyệt hoàn tiền...</p>
          <div class="flex items-center gap-2 mt-2">
            <span class="badge badge-amber"><span class="w-1.5 h-1.5 rounded-full bg-amber-500 mr-1.5"></span>Chờ Admin</span>
            <span class="text-[9px] font-semibold uppercase tracking-wider text-red-700 bg-red-100 px-1.5 py-0.5 rounded-full urgent-dot">Khẩn cấp</span>
          </div>
        </div>
      </div>
      
      <!-- Default Ticket 3 -->
      <div onclick="selectTicket('TK-1184')" id="card-TK-1184" class="p-3.5 rounded-xl border border-zinc-200 bg-white hover:bg-zinc-50 transition-all cursor-pointer relative group flex items-start gap-3">
        <div class="w-9 h-9 rounded-lg bg-purple-100 text-purple-700 flex items-center justify-center shrink-0">
          <span class="material-symbols-outlined text-[18px]">engineering</span>
        </div>
        <div class="flex-1 min-w-0">
          <div class="flex items-center justify-between gap-2 mb-1">
            <span class="text-[10px] font-bold text-zinc-500 font-mono tracking-wider">#TK-1184</span>
            <span class="text-[10px] text-zinc-400">28/04</span>
          </div>
          <p class="text-xs font-bold text-zinc-900 truncate group-hover:text-blue-700 transition-colors">Lỗi đồng bộ chấm công tháng 4</p>
          <p class="text-[11px] text-zinc-500 truncate mt-0.5">Anh Nhân: Đã fix xong lỗi đồng bộ database...</p>
          <div class="flex items-center gap-2 mt-2">
            <span class="badge badge-gray">Đã giải quyết</span>
            <span class="text-[9px] font-semibold text-zinc-500 bg-zinc-100 px-1.5 py-0.5 rounded">Trung bình</span>
          </div>
        </div>
      </div>
    </div>
  </section>
  
  <!-- Right Panel: Interactive Support Chat Room -->
  <section class="flex-1 bg-white border border-zinc-200 rounded-2xl flex flex-col overflow-hidden shadow-sm" data-aos="fade-left">
    
    <!-- Chat Header -->
    <div class="px-6 py-4 border-b border-zinc-200 flex items-center justify-between bg-white relative">
      <div class="absolute inset-0 bg-gradient-to-br from-blue-600/[0.02] to-transparent pointer-events-none"></div>
      <div class="flex items-center gap-3 relative">
        <div class="relative shrink-0">
          <img class="w-11 h-11 rounded-full object-cover ring-2 ring-blue-600/20" src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80">
          <span class="absolute bottom-0 right-0 w-3 h-3 rounded-full bg-[#05cd99] border-2 border-white"></span>
        </div>
        <div>
          <div class="flex items-center gap-2">
            <h3 class="font-bold text-sm text-zinc-900">Nguyễn Thiện Nhân</h3>
            <span class="inline-flex items-center gap-0.5 text-[9px] font-bold text-blue-700 bg-blue-50 px-1.5 py-0.5 rounded-full"><span class="material-symbols-outlined text-[10px]" style="font-variation-settings:'FILL' 1">shield</span>ADMIN</span>
          </div>
          <div class="flex items-center gap-2 mt-0.5 text-[11px] text-zinc-500">
            <p>Hỗ trợ trực tuyến</p>
            <span class="w-1.5 h-1.5 rounded-full bg-green-500 inline-block"></span>
            <p class="font-mono text-zinc-400 font-semibold" id="activeTicketIdHeader">#TK-4829</p>
          </div>
        </div>
      </div>
      
      <!-- Thread Detail Options -->
      <div class="flex items-center gap-2">
        <button onclick="toggleTicketStatus()" id="closeTicketBtn" class="h-9 px-3 rounded-lg border border-zinc-200 hover:bg-zinc-50 text-xs font-semibold text-zinc-700 flex items-center gap-1.5">
          <span class="material-symbols-outlined text-[16px] text-zinc-500">task_alt</span>Đóng yêu cầu
        </button>
        <button class="w-9 h-9 rounded-lg hover:bg-zinc-50 border border-zinc-200 flex items-center justify-center text-zinc-500"><span class="material-symbols-outlined text-[18px]">more_vert</span></button>
      </div>
    </div>
    
    <!-- Active Ticket Description Banner -->
    <div class="px-6 py-3.5 bg-zinc-50 border-b border-zinc-100 flex items-start gap-3" id="ticketBannerContainer">
      <span class="material-symbols-outlined text-[18px] text-blue-600 mt-0.5">info</span>
      <div class="flex-1">
        <p class="text-xs font-bold text-zinc-800" id="bannerTitle">Yêu cầu cấp thêm thiết bị POS và máy in nhiệt cho CS01</p>
        <p class="text-[11px] text-zinc-500 mt-0.5">
          Danh mục: <span class="font-semibold text-zinc-700" id="bannerCategory">Thiết bị & Vận hành</span> · 
          Mức độ: <span class="font-semibold text-red-600" id="bannerPriority">Cao</span> · 
          Ngày tạo: <span class="text-zinc-600" id="bannerDate">18/05/2026 14:30</span>
        </p>
      </div>
    </div>
    
    <!-- Chat Body (Message Bubble List) -->
    <div class="flex-1 overflow-y-auto px-6 py-5 flex flex-col gap-4 bg-zinc-50/20" id="chatBody">
      <!-- Bubbles will be injected by JavaScript -->
    </div>
    
    <!-- Typing indicator -->
    <div id="typingIndicator" class="hidden px-6 py-2.5 bg-transparent flex items-center gap-2.5 text-zinc-500 text-xs">
      <img class="w-6 h-6 rounded-full object-cover shrink-0" src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80">
      <div class="bg-zinc-100 py-1.5 px-3 rounded-2xl flex items-center gap-1">
        <p class="text-[11px]">Anh Nhân đang nhập</p>
        <div class="flex gap-0.5 items-center justify-center mt-0.5">
          <span class="w-1 h-1 rounded-full bg-zinc-500 animate-bounce" style="animation-delay:0ms"></span>
          <span class="w-1 h-1 rounded-full bg-zinc-500 animate-bounce" style="animation-delay:150ms"></span>
          <span class="w-1 h-1 rounded-full bg-zinc-500 animate-bounce" style="animation-delay:300ms"></span>
        </div>
      </div>
    </div>
    
    <!-- Chat Input Area -->
    <div class="p-4 border-t border-zinc-200 bg-white relative">
      <div class="flex items-center gap-2 mb-2">
        <button onclick="insertTemplate('sự cố')" class="px-2.5 py-1 rounded bg-zinc-50 hover:bg-zinc-100 border border-zinc-200 text-[10px] font-semibold text-zinc-600 transition-colors">⚠️ Sự cố khẩn cấp</button>
        <button onclick="insertTemplate('cảm ơn')" class="px-2.5 py-1 rounded bg-zinc-50 hover:bg-zinc-100 border border-zinc-200 text-[10px] font-semibold text-zinc-600 transition-colors">🙏 Cảm ơn Admin</button>
        <button onclick="insertTemplate('thời gian')" class="px-2.5 py-1 rounded bg-zinc-50 hover:bg-zinc-100 border border-zinc-200 text-[10px] font-semibold text-zinc-600 transition-colors">⏰ Hỏi thời gian xử lý</button>
      </div>
      <div class="flex items-end gap-2.5 bg-zinc-50 border border-zinc-200 rounded-xl p-2 focus-within:border-blue-500 focus-within:bg-white transition-colors relative">
        <button class="p-2 rounded-lg hover:bg-zinc-100 text-zinc-500 shrink-0 flex items-center justify-center"><span class="material-symbols-outlined text-[20px]">add_photo_alternate</span></button>
        <button class="p-2 rounded-lg hover:bg-zinc-100 text-zinc-500 shrink-0 flex items-center justify-center"><span class="material-symbols-outlined text-[20px]">mood</span></button>
        <textarea id="messageInput" rows="1" placeholder="Nhập nội dung tin nhắn hoặc sự cố cần hỗ trợ..." class="flex-1 bg-transparent border-none text-xs text-zinc-800 focus:outline-none resize-none py-1.5 max-h-[100px] overflow-y-auto" onkeydown="handleInputKeydown(event)"></textarea>
        
        <!-- Send Button -->
        <button onclick="sendMessage()" class="h-9 px-4 rounded-lg bg-blue-700 text-white text-xs font-bold hover:opacity-95 transition-opacity flex items-center justify-center gap-1.5 shrink-0 active:scale-95">
          <span>Gửi</span><span class="material-symbols-outlined text-[14px]">send</span>
        </button>
      </div>
      <div class="flex items-center justify-between mt-2.5">
        <p class="text-[10px] text-zinc-400">Ấn <kbd class="px-1 py-0.5 rounded bg-zinc-100 border text-[9px] font-mono">Enter</kbd> để gửi, <kbd class="px-1 py-0.5 rounded bg-zinc-100 border text-[9px] font-mono">Shift+Enter</kbd> xuống hàng.</p>
        <div class="flex items-center gap-2">
          <label class="text-[11px] font-semibold text-zinc-600 select-none cursor-pointer flex items-center gap-1" for="urgentToggle">Sự cố khẩn cấp</label>
          <input type="checkbox" id="urgentToggle" class="w-4 h-4 rounded text-blue-600 focus:ring-blue-500 border-zinc-300">
        </div>
      </div>
    </div>
  </section>
</main>

<!-- Creating New Ticket Modal -->
<div id="newTicketModal" class="hidden fixed inset-0 z-[80] flex items-center justify-center p-4">
  <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" onclick="closeNewTicketModal()"></div>
  <div class="relative bg-white rounded-2xl shadow-2xl w-full max-w-[500px] z-10 border border-zinc-200 animate-fadeUp">
    <div class="flex items-center justify-between px-6 py-4 border-b border-zinc-200">
      <div class="flex items-center gap-2.5"><span class="material-symbols-outlined text-[20px] text-blue-700">contact_support</span><h3 class="text-base font-bold text-zinc-900">Tạo yêu cầu hỗ trợ mới</h3></div>
      <button onclick="closeNewTicketModal()" class="w-8 h-8 rounded-full hover:bg-zinc-100 flex items-center justify-center transition-colors"><span class="material-symbols-outlined text-[18px] text-zinc-500">close</span></button>
    </div>
    <div class="px-6 py-5 flex flex-col gap-4">
      <div>
        <label class="block text-xs font-semibold text-zinc-500 mb-1.5">Tiêu đề yêu cầu</label>
        <input type="text" id="newTicketTitle" placeholder="Ví dụ: Lỗi đồng bộ doanh thu, Sự cố hỏng lưới sân A3..." class="w-full h-10 px-3 rounded-lg border border-zinc-200 bg-white text-xs text-zinc-800 focus:border-blue-600 focus:outline-none transition-colors">
      </div>
      <div class="grid grid-cols-2 gap-4">
        <div>
          <label class="block text-xs font-semibold text-zinc-500 mb-1.5">Danh mục vấn đề</label>
          <select id="newTicketCategory" class="w-full h-10 px-2.5 rounded-lg border border-zinc-200 bg-white text-xs text-zinc-800 focus:border-blue-600 focus:outline-none transition-colors">
            <option value="Thiết bị & Vận hành">Thiết bị & Vận hành</option>
            <option value="Tài chính & Doanh thu">Tài chính & Doanh thu</option>
            <option value="Kỹ thuật & Phần mềm">Kỹ thuật & Hệ thống</option>
            <option value="Sân bãi & Cơ sở vật chất">Sân bãi & Cơ sở vật chất</option>
          </select>
        </div>
        <div>
          <label class="block text-xs font-semibold text-zinc-500 mb-1.5">Mức độ khẩn cấp</label>
          <select id="newTicketPriority" class="w-full h-10 px-2.5 rounded-lg border border-zinc-200 bg-white text-xs text-zinc-800 focus:border-blue-600 focus:outline-none transition-colors">
            <option value="Trung bình">Trung bình</option>
            <option value="Cao">Cao</option>
            <option value="Khẩn cấp">Khẩn cấp 🚨</option>
          </select>
        </div>
      </div>
      <div>
        <label class="block text-xs font-semibold text-zinc-500 mb-1.5">Chi tiết sự cố & vấn đề cần trợ giúp</label>
        <textarea id="newTicketDescription" rows="4" placeholder="Mô tả cụ thể vấn đề của bạn..." class="w-full p-3 rounded-lg border border-zinc-200 bg-white text-xs text-zinc-800 focus:border-blue-600 focus:outline-none transition-colors resize-none"></textarea>
      </div>
      <div>
        <label class="block text-xs font-semibold text-zinc-500 mb-1.5">Đính kèm ảnh minh họa hoặc file báo cáo</label>
        <div class="border border-dashed border-zinc-200 rounded-lg p-4 text-center cursor-pointer hover:bg-zinc-50 transition-colors flex flex-col items-center gap-1">
          <span class="material-symbols-outlined text-[24px] text-zinc-400">cloud_upload</span>
          <p class="text-[11px] text-zinc-600">Kéo thả hoặc click để upload file ảnh/báo cáo</p>
          <p class="text-[9px] text-zinc-400">Chấp nhận JPG, PNG, PDF tối đa 10MB</p>
        </div>
      </div>
    </div>
    <div class="px-6 pb-5 flex gap-3 justify-end">
      <button onclick="closeNewTicketModal()" class="h-10 px-5 rounded-lg border border-zinc-200 text-xs font-semibold text-zinc-600 hover:bg-zinc-50 transition-colors">Hủy</button>
      <button onclick="submitNewTicket()" class="h-10 px-5 rounded-lg bg-blue-700 text-white text-xs font-bold hover:opacity-95 transition-opacity active:scale-95 shadow-md shadow-blue-100">Gửi yêu cầu hỗ trợ</button>
    </div>
  </div>
</div>


<script src="https://unpkg.com/aos@2.3.1/dist/aos.js"></script>
<script>
AOS.init({ duration: 550, once: true });

// Mock Databases for Support Tickets
let activeTicketId = "TK-4829";
let currentFilter = "all";

const ticketsDb = {
  "TK-4829": {
    id: "TK-4829",
    title: "Yêu cầu cấp thêm thiết bị POS và máy in nhiệt cho CS01",
    category: "Thiết bị & Vận hành",
    priority: "Cao",
    status: "Đang mở",
    created: "18/05/2026 14:30",
    icon: "inventory_2",
    iconBg: "bg-blue-100 text-blue-700",
    messages: [
      {
        sender: "manager",
        text: "Chào anh Nhân, hiện tại quầy POS bán hàng tại Cơ Sở CS01 (Vũng Tàu) đang gặp quá tải vào khung giờ cao điểm tối. Máy in hóa đơn cũ thường xuyên bị kẹt giấy và tốc độ in rất chậm. Anh xem xét cấp thêm cho Cơ Sở chúng em:\n- 01 Máy POS cảm ứng đặt tại quầy nước.\n- 02 Máy in hóa đơn nhiệt Xprinter khổ 80mm để in bill nước và bill sân nhanh hơn.\nEm cảm ơn anh!",
        time: "14:30"
      },
      {
        sender: "system",
        text: "Hệ thống: Ticket #TK-4829 đã được tạo thành công và được phân phối tự động đến Admin: Nguyễn Thiện Nhân.",
        time: "14:32"
      },
      {
        sender: "admin",
        text: "Chào Quân, anh đã tiếp nhận yêu cầu từ Cơ Sở CS01. Quầy POS bán hàng ở Vũng Tàu hiện tại doanh thu đang tăng trưởng rất tốt (khoảng +18% so với tháng trước), việc nâng cấp thiết bị là hoàn toàn hợp lý.\nAnh gửi kèm file báo cáo định mức thiết bị đã ký duyệt. Em xem qua file đính kèm này nhé.",
        time: "14:50",
        attachment: {
          name: "Bao_Cao_Dinh_Muc_CS01.pdf",
          size: "2.4 MB"
        }
      },
      {
        sender: "manager",
        text: "Dạ vâng em đã nhận được file rồi ạ. Bản báo cáo thiết bị rất chi tiết. Khi nào thì thiết bị có thể vận chuyển về đến Cơ Sở vậy anh Nhân?",
        time: "15:02"
      },
      {
        sender: "admin",
        text: "Bên đơn vị vận chuyển Viettel Post báo sẽ giao hàng đến Cơ Sở Vũng Tàu vào chiều ngày mai (19/05). Khi nhận hàng, em nhớ kiểm tra kỹ tem niêm phong và báo kỹ thuật viên lắp đặt ngay nhé. Có bất kỳ sự cố nào cứ nhắn trực tiếp trên kênh chat này cho anh!",
        time: "15:15"
      }
    ]
  },
  "TK-3920": {
    id: "TK-3920",
    title: "Sự cố tính sai giờ đặt sân và doanh thu ngày Lễ 30/4",
    category: "Tài chính & Doanh thu",
    priority: "Khẩn cấp",
    status: "Đang mở",
    created: "01/05/2026 09:12",
    icon: "payments",
    iconBg: "bg-amber-100 text-amber-700",
    messages: [
      {
        sender: "manager",
        text: "Chào anh Nhân, trong ngày lễ 30/4 vừa qua, hệ thống tính toán giá sân giờ vàng bị lỗi đối với tài khoản VIP. Tiền sân bị trừ thiếu 120,000đ cho mỗi lịch đặt của khách hàng Trần Thị Lan. Em đã đối soát và phát hiện chênh lệch tổng cộng là 600,000đ.",
        time: "09:12"
      },
      {
        sender: "admin",
        text: "Cảm ơn Quân đã phát hiện kịp thời. Anh đang cho đội ngũ kỹ thuật đối soát lại log database của ngày 30/4. Em gửi giúp anh mã các hóa đơn đặt sân bị lỗi đó nhé.",
        time: "09:40"
      },
      {
        sender: "manager",
        text: "Dạ, các hóa đơn bị lỗi bao gồm: HD-9812, HD-9815, và HD-9820 ạ. Em gửi anh file đối soát Excel chi tiết đính kèm.",
        time: "09:55",
        attachment: {
          name: "Doi_Soat_Le_30_4_CS01.xlsx",
          size: "420 KB"
        }
      },
      {
        sender: "system",
        text: "Hệ thống: Vấn đề đã được chuyển trạng thái sang Chờ phê duyệt hoàn trả tài chính.",
        time: "10:00"
      }
    ]
  },
  "TK-1184": {
    id: "TK-1184",
    title: "Lỗi đồng bộ bảng chấm công nhân sự tháng 4/2026",
    category: "Kỹ thuật & Phần mềm",
    priority: "Trung bình",
    status: "Đã giải quyết",
    created: "28/04/2026 17:45",
    icon: "engineering",
    iconBg: "bg-purple-100 text-purple-700",
    messages: [
      {
        sender: "manager",
        text: "Anh Nhân ơi, bảng công của nhân sự ca tối tại Cơ Sở CS01 không hiển thị đúng số ca làm thực tế trên trang quản lý nhân sự. Hệ thống đang báo thiếu 2 ca của bạn Lê Hoàng Việt.",
        time: "17:45"
      },
      {
        sender: "admin",
        text: "Anh đã kiểm tra, do xung đột đồng bộ giữa bảng chấm công vân tay và bảng Accounts trên Cloud. Anh đã tiến hành đồng bộ thủ công lại cho Cơ Sở em rồi nhé. Em reload lại trang kiểm tra xem đúng chưa.",
        time: "18:20"
      },
      {
        sender: "manager",
        text: "Tuyệt vời quá anh ơi, em vừa tải lại trang và số ca làm của bạn Việt đã hiển thị đầy đủ và chuẩn xác rồi ạ. Em cảm ơn anh nhiều!",
        time: "18:25"
      },
      {
        sender: "admin",
        text: "Đã fix xong lỗi đồng bộ database. Bạn vui lòng reload lại trang Nhân Sự nhé. Anh đóng ticket này nha.",
        time: "18:30"
      },
      {
        sender: "system",
        text: "Hệ thống: Ticket #TK-1184 đã được cập nhật trạng thái: Đã giải quyết.",
        time: "18:30"
      }
    ]
  }
};


// Mobile Menu Toggle
const mobileMenuBtn = document.getElementById('mobileMenuBtn');
const sidebar = document.getElementById('sidebar');
if (mobileMenuBtn && sidebar) {
  mobileMenuBtn.addEventListener('click', () => {
    sidebar.classList.toggle('-translate-x-full');
  });
}

// Toast Notifications Helper
function showToast(msg) {
  let t = document.createElement('div');
  t.className = 'fixed bottom-6 left-1/2 -translate-x-1/2 bg-zinc-900 text-white px-5 py-2.5 rounded-full text-xs font-semibold z-[9999] shadow-lg flex items-center gap-2 border border-zinc-800';
  t.innerHTML = '<span class="material-symbols-outlined text-[16px] text-blue-500" style="font-variation-settings:\'FILL\' 1">check_circle</span> ' + msg;
  document.body.appendChild(t);
  setTimeout(() => {
    t.style.transition = 'opacity 0.3s';
    t.style.opacity = '0';
    setTimeout(() => { t.remove(); }, 350);
  }, 2200);
}

// Active Ticket Rendering
function selectTicket(id) {
  activeTicketId = id;
  
  // Update selected card styling
  document.querySelectorAll('#ticketsListContainer > div').forEach(card => {
    card.classList.remove('border-blue-200', 'bg-blue-50/40');
    card.classList.add('border-zinc-200', 'bg-white');
  });
  const activeCard = document.getElementById(`card-\${id}`);
  if (activeCard) {
    activeCard.classList.remove('border-zinc-200', 'bg-white');
    activeCard.classList.add('border-blue-200', 'bg-blue-50/40');
  }
  
  // Load Banner Info
  const ticket = ticketsDb[id];
  document.getElementById('activeTicketIdHeader').textContent = `#\${ticket.id}`;
  document.getElementById('bannerTitle').textContent = ticket.title;
  document.getElementById('bannerCategory').textContent = ticket.category;
  document.getElementById('bannerPriority').textContent = ticket.priority;
  document.getElementById('bannerDate').textContent = ticket.created;
  
  // Set priority priority color
  const prio = document.getElementById('bannerPriority');
  prio.className = 'font-semibold ';
  if (ticket.priority === 'Khẩn cấp') {
    prio.classList.add('text-red-700', 'bg-red-100', 'px-1.5', 'py-0.5', 'rounded-full', 'urgent-dot');
  } else if (ticket.priority === 'Cao') {
    prio.classList.add('text-red-600', 'bg-red-50', 'px-1.5', 'py-0.5', 'rounded');
  } else {
    prio.classList.add('text-zinc-600');
  }
  
  // Update status button text
  const closeBtn = document.getElementById('closeTicketBtn');
  if (ticket.status === 'Đã giải quyết') {
    closeBtn.innerHTML = '<span class="material-symbols-outlined text-[16px] text-green-600">task_alt</span>Mở lại yêu cầu';
  } else {
    closeBtn.innerHTML = '<span class="material-symbols-outlined text-[16px] text-zinc-500">task_alt</span>Đóng yêu cầu';
  }
  
  renderMessages();
}

function renderMessages() {
  const container = document.getElementById('chatBody');
  container.innerHTML = '';
  const ticket = ticketsDb[activeTicketId];
  
  ticket.messages.forEach(msg => {
    let bubble = document.createElement('div');
    bubble.className = 'flex items-end gap-2.5 max-w-[80%] chat-bubble';
    
    if (msg.sender === 'manager') {
      bubble.classList.add('self-end');
      
      let innerHTML = `
        <div class="flex flex-col items-end">
          <div class="bg-blue-700 text-white text-xs px-4 py-3 rounded-2xl rounded-br-none shadow-sm leading-relaxed whitespace-pre-line">
            \${msg.text}
            \${msg.attachment ? renderAttachmentHtml(msg.attachment) : ''}
          </div>
          <span class="text-[10px] text-zinc-400 mt-1 font-medium">\${msg.time} · Đã gửi</span>
        </div>
        <img class="w-8 h-8 rounded-full object-cover ring-2 ring-white shrink-0 mb-4" src="https://i.pravatar.cc/80?img=68">
      `;
      bubble.innerHTML = innerHTML;
      
    } else if (msg.sender === 'admin') {
      bubble.classList.add('self-start');
      
      let innerHTML = `
        <img class="w-8 h-8 rounded-full object-cover ring-2 ring-white shrink-0 mb-4" src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80">
        <div class="flex flex-col">
          <div class="bg-white border border-zinc-200 text-zinc-800 text-xs px-4 py-3 rounded-2xl rounded-bl-none shadow-sm leading-relaxed whitespace-pre-line relative">
            <div class="absolute inset-0 bg-gradient-to-br from-blue-600/[0.01] to-transparent pointer-events-none rounded-2xl"></div>
            \${msg.text}
            \${msg.attachment ? renderAttachmentHtml(msg.attachment) : ''}
          </div>
          <span class="text-[10px] text-zinc-400 mt-1 font-medium">\${msg.time} · Admin Nhân</span>
        </div>
      `;
      bubble.innerHTML = innerHTML;
      
    } else if (msg.sender === 'system') {
      // System logs styled neutrally
      let log = document.createElement('div');
      log.className = 'w-full text-center py-2 chat-bubble';
      log.innerHTML = `
        <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-zinc-100 text-zinc-500 text-[10px] font-medium font-mono border border-zinc-200/50">
          <span class="material-symbols-outlined text-[12px]">info</span>\${msg.text}
        </span>
      `;
      container.appendChild(log);
      return;
    }
    
    container.appendChild(bubble);
  });
  
  // Scroll to bottom
  container.scrollTop = container.scrollHeight;
}

function renderAttachmentHtml(att) {
  const isExcel = att.name.endsWith('.xlsx');
  const icon = isExcel ? 'description' : 'picture_as_pdf';
  const iconCol = isExcel ? 'text-emerald-600 bg-emerald-50' : 'text-rose-600 bg-rose-50';
  
  return `
    <div class="mt-3 p-2.5 bg-zinc-50 rounded-xl border border-zinc-200 flex items-center justify-between gap-3 text-zinc-800 shadow-sm shrink-0">
      <div class="flex items-center gap-2.5 min-w-0">
        <div class="w-9 h-9 rounded-lg \${iconCol} flex items-center justify-center shrink-0">
          <span class="material-symbols-outlined text-[20px]">\${icon}</span>
        </div>
        <div class="min-w-0 text-left">
          <p class="text-xs font-bold text-zinc-900 truncate">\${att.name}</p>
          <p class="text-[10px] text-zinc-400 mt-0.5">\${att.size}</p>
        </div>
      </div>
      <button class="w-8 h-8 rounded-lg hover:bg-zinc-200 flex items-center justify-center text-zinc-600 shrink-0"><span class="material-symbols-outlined text-[18px]">download</span></button>
    </div>
  `;
}

// Sending a Message
function sendMessage() {
  const inp = document.getElementById('messageInput');
  const txt = inp.value.trim();
  const isUrgent = document.getElementById('urgentToggle').checked;
  if (!txt) return;
  
  const now = new Date();
  const timeStr = `\${String(now.getHours()).padStart(2, '0')}:\${String(now.getMinutes()).padStart(2, '0')}`;
  
  // Append message to db
  ticketsDb[activeTicketId].messages.push({
    sender: "manager",
    text: txt,
    time: timeStr
  });
  
  // Render and clear
  renderMessages();
  inp.value = '';
  inp.style.height = 'auto';
  
  // Trigger auto response
  triggerAdminResponse(txt);
}

function handleInputKeydown(e) {
  if (e.key === 'Enter' && !e.shiftKey) {
    e.preventDefault();
    sendMessage();
  }
}

// Injects support templates
function insertTemplate(type) {
  const inp = document.getElementById('messageInput');
  if (type === 'sự cố') {
    inp.value = "🚨 BÁO CÁO SỰ CỐ KHẨN CẤP:\nCơ Sở chúng em đang bị sự cố...\nAnh Nhân xem xét hỗ trợ gấp giúp em nhé!";
    document.getElementById('urgentToggle').checked = true;
  } else if (type === 'cảm ơn') {
    inp.value = "Em cảm ơn anh Nhân nhiều ạ! Thiết bị hoạt động rất tốt rồi anh.";
  } else if (type === 'thời gian') {
    inp.value = "Anh Nhân ơi, vấn đề này dự kiến khoảng bao lâu thì đội ngũ kỹ thuật xử lý xong vậy anh?";
  }
  inp.focus();
  inp.style.height = 'auto';
  inp.style.height = (inp.scrollHeight) + 'px';
}

// Simulated Admin response logic
function triggerAdminResponse(userMsg) {
  const typing = document.getElementById('typingIndicator');
  
  // Show typing indicator after 800ms
  setTimeout(() => {
    typing.classList.remove('hidden');
    const container = document.getElementById('chatBody');
    container.scrollTop = container.scrollHeight;
    
    // Admin responds after 1.5s
    setTimeout(() => {
      typing.classList.add('hidden');
      
      const now = new Date();
      const timeStr = `\${String(now.getHours()).padStart(2, '0')}:\${String(now.getMinutes()).padStart(2, '0')}`;
      
      let replyText = "Ghi nhận thông tin từ em. Anh đã chuyển yêu cầu cho đội kỹ thuật xử lý ngay, sẽ có kết quả phản hồi sớm nhất cho em!";
      
      const lower = userMsg.toLowerCase();
      if (lower.includes('cảm ơn') || lower.includes('thank')) {
        replyText = "Không có gì đâu Quân, hỗ trợ Cơ Sở là nhiệm vụ của anh mà. Chúc Cơ Sở CS01 hôm nay kinh doanh thuận lợi và đạt KPI nhé!";
      } else if (lower.includes('khi nào') || lower.includes('thời gian') || lower.includes('bao lâu')) {
        replyText = "Anh đang đốc thúc nhân sự xử lý ngay. Đối với các vấn đề kỹ thuật này, dự kiến sẽ hoàn thành trong vòng 1-2 giờ tới em nhé.";
      } else if (lower.includes('sự cố') || lower.includes('hỏng') || lower.includes('lỗi')) {
        replyText = "Em gửi giúp anh hình ảnh thực tế hoặc video quay lại lỗi/sự cố đó qua đây nhé để kỹ thuật viên nắm bắt nhanh nhất nha.";
      }
      
      ticketsDb[activeTicketId].messages.push({
        sender: "admin",
        text: replyText,
        time: timeStr
      });
      
      renderMessages();
      showToast('Có 1 tin nhắn mới từ Admin');
    }, 1500);
    
  }, 800);
}

// Toggle ticket resolved status
function toggleTicketStatus() {
  const ticket = ticketsDb[activeTicketId];
  const now = new Date();
  const timeStr = `\${String(now.getHours()).padStart(2, '0')}:\${String(now.getMinutes()).padStart(2, '0')}`;
  
  if (ticket.status === 'Đã giải quyết') {
    ticket.status = 'Đang mở';
    ticket.messages.push({
      sender: "system",
      text: "Hệ thống: Yêu cầu hỗ trợ đã được mở lại bởi Quản lý.",
      time: timeStr
    });
    showToast('Đã mở lại yêu cầu hỗ trợ');
  } else {
    ticket.status = 'Đã giải quyết';
    ticket.messages.push({
      sender: "system",
      text: "Hệ thống: Ticket đã được đánh dấu là Đã giải quyết bởi Quản lý.",
      time: timeStr
    });
    showToast('Yêu cầu hỗ trợ đã đóng thành công');
  }
  
  // Re-filter and re-render
  selectTicket(activeTicketId);
  renderTicketsList();
}

// New Ticket Modal Controls
function openNewTicketModal() {
  document.getElementById('newTicketModal').classList.remove('hidden');
}

function closeNewTicketModal() {
  document.getElementById('newTicketModal').classList.add('hidden');
  document.getElementById('newTicketTitle').value = '';
  document.getElementById('newTicketDescription').value = '';
}

function submitNewTicket() {
  const title = document.getElementById('newTicketTitle').value.trim();
  const cat = document.getElementById('newTicketCategory').value;
  const prio = document.getElementById('newTicketPriority').value;
  const desc = document.getElementById('newTicketDescription').value.trim();
  
  if (!title || !desc) {
    showToast('Vui lòng điền đầy đủ tiêu đề và nội dung mô tả!');
    return;
  }
  
  const tkId = 'TK-' + Math.floor(1000 + Math.random() * 9000);
  const now = new Date();
  const dateStr = `\${String(now.getDate()).padStart(2, '0')}/\${String(now.getMonth() + 1).padStart(2, '0')}`;
  const timeStr = `\${String(now.getHours()).padStart(2, '0')}:\${String(now.getMinutes()).padStart(2, '0')}`;
  
  // Add to db
  ticketsDb[tkId] = {
    id: tkId,
    title: title,
    category: cat,
    priority: prio,
    status: "Đang mở",
    created: `\${dateStr}/2026 \${timeStr}`,
    icon: cat.includes('Tài chính') ? 'payments' : (cat.includes('Kỹ thuật') ? 'engineering' : (cat.includes('Sân') ? 'stadium' : 'inventory_2')),
    iconBg: cat.includes('Tài chính') ? 'bg-amber-100 text-amber-700' : (cat.includes('Kỹ thuật') ? 'bg-purple-100 text-purple-700' : (cat.includes('Sân') ? 'bg-emerald-100 text-emerald-700' : 'bg-blue-100 text-blue-700')),
    messages: [
      {
        sender: "manager",
        text: desc,
        time: timeStr
      },
      {
        sender: "system",
        text: `Hệ thống: Ticket #\${tkId} đã được tạo thành công và được gửi đến Admin.`,
        time: timeStr
      },
      {
        sender: "admin",
        text: "Hệ thống đã ghi nhận yêu cầu hỗ trợ mới của bạn. Tôi sẽ xem xét và phản hồi trong thời gian sớm nhất!",
        time: timeStr
      }
    ]
  };
  
  closeNewTicketModal();
  showToast('Đã gửi yêu cầu hỗ trợ mới đến Admin');
  
  // Render and select
  renderTicketsList();
  selectTicket(tkId);
}

// Rendering the left side tickets list dynamically with filters and search
function renderTicketsList() {
  const container = document.getElementById('ticketsListContainer');
  container.innerHTML = '';
  const searchVal = document.getElementById('searchTickets').value.toLowerCase();
  
  Object.keys(ticketsDb).forEach(key => {
    const tk = ticketsDb[key];
    
    // Filter status
    if (currentFilter === 'open' && tk.status === 'Đã giải quyết') return;
    if (currentFilter === 'resolved' && tk.status !== 'Đã giải quyết') return;
    
    // Filter search
    if (searchVal && !tk.title.toLowerCase().includes(searchVal) && !tk.id.toLowerCase().includes(searchVal)) return;
    
    const isActive = tk.id === activeTicketId;
    const borderBgClass = isActive ? 'border-blue-200 bg-blue-50/40' : 'border-zinc-200 bg-white';
    
    let priorityBadge = '';
    if (tk.priority === 'Khẩn cấp') {
      priorityBadge = `<span class="text-[9px] font-semibold uppercase tracking-wider text-red-700 bg-red-100 px-1.5 py-0.5 rounded-full urgent-dot">Khẩn cấp</span>`;
    } else if (tk.priority === 'Cao') {
      priorityBadge = `<span class="text-[9px] font-semibold uppercase tracking-wider text-red-600 bg-red-50 px-1.5 py-0.5 rounded">Ưu tiên cao</span>`;
    } else {
      priorityBadge = `<span class="text-[9px] font-semibold text-zinc-500 bg-zinc-100 px-1.5 py-0.5 rounded">Trung bình</span>`;
    }
    
    let statusBadge = '';
    if (tk.status === 'Đã giải quyết') {
      statusBadge = `<span class="badge badge-gray">Đã giải quyết</span>`;
    } else {
      statusBadge = `<span class="badge badge-green"><span class="w-1.5 h-1.5 rounded-full bg-green-500 mr-1.5 live-dot"></span>Đang mở</span>`;
    }
    
    // Get last message snippet
    const lastMsg = tk.messages[tk.messages.length - 1];
    let snippet = lastMsg.text;
    if (lastMsg.sender === 'admin') snippet = 'Anh Nhân: ' + snippet;
    else if (lastMsg.sender === 'manager') snippet = 'Bạn: ' + snippet;
    else snippet = 'Hệ thống: ' + snippet;
    if (snippet.length > 38) snippet = snippet.substring(0, 38) + '...';
    
    let card = document.createElement('div');
    card.onclick = () => selectTicket(tk.id);
    card.id = `card-\${tk.id}`;
    card.className = `p-3.5 rounded-xl border \${borderBgClass} hover:bg-zinc-50 transition-all cursor-pointer relative group flex items-start gap-3`;
    
    card.innerHTML = `
      <div class="w-9 h-9 rounded-lg \${tk.iconBg} flex items-center justify-center shrink-0">
        <span class="material-symbols-outlined text-[18px]">\${tk.icon}</span>
      </div>
      <div class="flex-1 min-w-0">
        <div class="flex items-center justify-between gap-2 mb-1">
          <span class="text-[10px] font-bold text-zinc-500 font-mono tracking-wider">#\${tk.id}</span>
          <span class="text-[10px] text-zinc-400">\${tk.created.substring(0, 5)}</span>
        </div>
        <p class="text-xs font-bold text-zinc-900 truncate group-hover:text-blue-700 transition-colors">\${tk.title}</p>
        <p class="text-[11px] text-zinc-500 truncate mt-0.5">\${snippet}</p>
        <div class="flex items-center gap-2 mt-2">
          \${statusBadge}
          \${priorityBadge}
        </div>
      </div>
    `;
    
    container.appendChild(card);
  });
}

function switchTab(tab) {
  currentFilter = tab;
  document.querySelectorAll('[id^="tab-"]').forEach(btn => {
    btn.classList.remove('bg-white', 'border', 'border-zinc-200', 'text-zinc-700', 'shadow-sm');
    btn.classList.add('text-zinc-500', 'hover:bg-zinc-100');
  });
  const act = document.getElementById(`tab-\${tab}`);
  act.classList.remove('text-zinc-500', 'hover:bg-zinc-100');
  act.classList.add('bg-white', 'border', 'border-zinc-200', 'text-zinc-700', 'shadow-sm');
  
  renderTicketsList();
}

function filterTickets(val) {
  renderTicketsList();
}

// Initial Load
selectTicket("TK-4829");

</script>
</body>
</html>
