<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Tổng quan — Quản lý Cơ Sở</title>
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
      <h1 class="text-sm font-bold text-zinc-900 tracking-tight">Tổng quan Cơ Sở</h1>
      <p class="text-xs text-zinc-500 flex items-center gap-1.5"><span class="material-symbols-outlined text-[12px]">schedule</span>Thứ Hai, 17/05/2026 · 09:42</p>
    </div>
  </div>
  <div class="flex items-center gap-1.5">
    <button onclick="toggleAdminChat()" class="hidden sm:flex items-center gap-1.5 h-9 px-3 rounded-lg border border-zinc-200 hover:bg-zinc-50 text-zinc-600 text-xs font-medium">
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
<main class="lg:ml-[248px] mt-[64px] p-4 lg:p-6 flex flex-col gap-5">

  <!-- HERO -->
  <section data-aos="fade-up" class="hero-gradient rounded-2xl border border-zinc-200 overflow-hidden relative">
    <div class="absolute -top-12 -right-12 w-64 h-64 bg-blue-200/20 rounded-full blur-3xl pointer-events-none"></div>
    <div class="absolute -bottom-12 -left-12 w-48 h-48 bg-blue-300/10 rounded-full blur-3xl pointer-events-none"></div>
    <div class="relative p-6 flex flex-col md:flex-row md:items-center md:justify-between gap-4">
      <div class="flex items-center gap-4">
        <img src="https://ui-avatars.com/api/?name=${sessionScope.user.fullName != null ? sessionScope.user.fullName : sessionScope.user.username}&background=2563eb&color=fff&bold=true" class="w-14 h-14 rounded-2xl object-cover shadow-md ring-4 ring-white" alt="Avatar">
        <div>
          <p class="text-[10px] font-bold uppercase tracking-widest text-blue-700 mb-1">Chào buổi sáng 👋</p>
          <h2 class="text-xl font-black text-zinc-900 tracking-tight"><c:out value="${sessionScope.user.fullName != null ? sessionScope.user.fullName : sessionScope.user.username}" /> ơi, hôm nay là ngày tuyệt vời!</h2>
          <div class="flex items-center gap-3 mt-1.5 text-xs text-zinc-500 flex-wrap">
            <span class="flex items-center gap-1"><span class="material-symbols-outlined text-[13px] text-amber-500">wb_sunny</span>32°C · Nắng</span>
            <span class="text-zinc-300">·</span>
            <span class="flex items-center gap-1"><span class="material-symbols-outlined text-[13px]">storefront</span>V-Sport Vũng Tàu</span>
            <span class="text-zinc-300">·</span>
            <span class="flex items-center gap-1 text-green-600 font-semibold"><span class="w-1.5 h-1.5 rounded-full bg-green-500 inline-block live-dot"></span>Đang hoạt động</span>
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- KPI ROW -->
  <section data-aos="fade-up" class="grid grid-cols-2 lg:grid-cols-4 gap-4 stagger">
    <div data-aos="fade-up" class="card card-hover p-5">
      <div class="flex items-start justify-between mb-3">
        <div class="w-11 h-11 rounded-xl bg-blue-50 flex items-center justify-center"><span class="material-symbols-outlined text-[20px] text-blue-700" style="font-variation-settings:'FILL' 1">event</span></div>
        <span class="flex items-center gap-0.5 text-[11px] font-bold text-green-600 bg-green-50 px-2 py-0.5 rounded-md"><span class="material-symbols-outlined text-[12px]">trending_up</span>+18%</span>
      </div>
      <p class="text-xs text-zinc-500 font-medium mb-1">Lịch đặt hôm nay</p>
      <p id="kpiBookingTodayCount" class="text-3xl font-black text-zinc-900 tracking-tight">${ordersToday != null ? ordersToday : 0}</p>
      <div class="flex items-center justify-between mt-3 pt-3 border-t border-zinc-100">
        <p class="text-[11px] text-zinc-500"><span class="text-amber-600 font-semibold">0</span> chờ xác nhận</p>
        <svg width="50" height="20" viewBox="0 0 50 20" class="text-blue-500"><polyline fill="none" stroke="currentColor" stroke-width="1.5" points="0,15 8,12 16,14 24,8 32,10 40,5 50,8"/><polyline fill="rgba(59,130,246,.1)" stroke="none" points="0,15 8,12 16,14 24,8 32,10 40,5 50,8 50,20 0,20"/></svg>
      </div>
    </div>
    <div data-aos="fade-up" class="card card-hover p-5">
      <div class="flex items-start justify-between mb-3">
        <div class="w-11 h-11 rounded-xl bg-green-50 flex items-center justify-center"><span class="material-symbols-outlined text-[20px] text-green-700" style="font-variation-settings:'FILL' 1">payments</span></div>
        <span class="flex items-center gap-0.5 text-[11px] font-bold text-green-600 bg-green-50 px-2 py-0.5 rounded-md"><span class="material-symbols-outlined text-[12px]">trending_up</span>+0%</span>
      </div>
      <p class="text-xs text-zinc-500 font-medium mb-1">Doanh thu hôm nay</p>
      <p class="text-3xl font-black text-zinc-900 tracking-tight">
        <fmt:formatNumber value="${revenueToday != null ? revenueToday : 0}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
      </p>
      <div class="flex items-center justify-between mt-3 pt-3 border-t border-zinc-100">
        <p class="text-[11px] text-zinc-500">Mục tiêu <span class="font-semibold text-zinc-700">10M</span></p>
        <div class="w-12 h-1.5 bg-zinc-100 rounded-full overflow-hidden"><div class="h-full bg-gradient-to-r from-green-400 to-emerald-500 rounded-full" style="width:10%"></div></div>
      </div>
    </div>
    <div data-aos="fade-up" class="card card-hover p-5">
      <div class="flex items-start justify-between mb-3">
        <div class="w-11 h-11 rounded-xl bg-purple-50 flex items-center justify-center"><span class="material-symbols-outlined text-[20px] text-purple-700" style="font-variation-settings:'FILL' 1">stadium</span></div>
        <span class="flex items-center gap-0.5 text-[11px] font-bold text-amber-600 bg-amber-50 px-2 py-0.5 rounded-md"><span class="material-symbols-outlined text-[12px]">build</span>0 bảo trì</span>
      </div>
      <p class="text-xs text-zinc-500 font-medium mb-1">Sân hoạt động</p>
      <p class="text-3xl font-black text-zinc-900 tracking-tight">${activeCourts != null ? activeCourts : 0}<span class="text-lg text-zinc-400">/${totalCourts != null ? totalCourts : 0}</span></p>
      <div class="flex items-center justify-between mt-3 pt-3 border-t border-zinc-100">
        <p class="text-[11px] text-zinc-500"><span class="font-semibold text-purple-700">100%</span> đang sẵn sàng</p>
        <div class="flex gap-0.5"><span class="w-1 h-3 rounded-sm bg-green-400"></span><span class="w-1 h-3 rounded-sm bg-green-400"></span><span class="w-1 h-3 rounded-sm bg-green-400"></span><span class="w-1 h-3 rounded-sm bg-green-400"></span><span class="w-1 h-3 rounded-sm bg-green-400"></span></div>
      </div>
    </div>
    <div data-aos="fade-up" class="card card-hover p-5">
      <div class="flex items-start justify-between mb-3">
        <div class="w-11 h-11 rounded-xl bg-amber-50 flex items-center justify-center"><span class="material-symbols-outlined text-[20px] text-amber-700" style="font-variation-settings:'FILL' 1">groups</span></div>
        <span class="flex items-center gap-0.5 text-[11px] font-bold text-blue-600 bg-blue-50 px-2 py-0.5 rounded-md"><span class="material-symbols-outlined text-[12px]">schedule</span>Ca sáng</span>
      </div>
      <p class="text-xs text-zinc-500 font-medium mb-1">Nhân viên ca này</p>
      <p class="text-3xl font-black text-zinc-900 tracking-tight">${staffCount != null ? staffCount : 0}<span class="text-lg text-zinc-400">/14</span></p>
      <div class="flex items-center justify-between mt-3 pt-3 border-t border-zinc-100">
        <p class="text-[11px] text-zinc-500">Đang làm việc</p>
        <div class="flex -space-x-1.5">
          <c:forEach items="${nonAdminStaff}" var="staff" end="2">
            <div class="w-5 h-5 rounded-full ring-2 ring-white bg-zinc-100 flex items-center justify-center text-[8px] font-bold text-zinc-700">
              ${staff.fullName != null && staff.fullName.length() > 0 ? staff.fullName.substring(0, 1).toUpperCase() : staff.username.substring(0, 1).toUpperCase()}
            </div>
          </c:forEach>
          <c:if test="${staffCount > 3}">
            <span class="w-5 h-5 rounded-full bg-zinc-200 ring-2 ring-white text-[8px] font-bold text-zinc-700 flex items-center justify-center">+${staffCount - 3}</span>
          </c:if>
        </div>
      </div>
    </div>
  </section>

  <!-- MAIN GRID -->
  <section data-aos="fade-up" class="grid grid-cols-1 xl:grid-cols-3 gap-5">

    <!-- LEFT 2/3 -->
    <div class="xl:col-span-2 flex flex-col gap-5">

      <!-- Booking today -->
      <div data-aos="fade-up" class="card overflow-hidden">
        <div class="flex items-center justify-between px-5 py-4 border-b border-zinc-100">
          <div>
            <h3 class="text-sm font-bold text-zinc-900 flex items-center gap-2"><span class="material-symbols-outlined text-[18px] text-blue-700">event_available</span>Lịch đặt hôm nay</h3>
            <p class="text-[11px] text-zinc-500 mt-0.5">Cập nhật lúc 09:42 · Từ bảng LichDatSan</p>
          </div>
          <div class="flex items-center gap-1.5">
            <button class="px-2.5 py-1 text-[11px] font-semibold rounded-md bg-zinc-100 text-zinc-800">Tất cả 18</button>
            <button class="px-2.5 py-1 text-[11px] font-medium rounded-md text-zinc-500 hover:bg-zinc-50 hidden md:block">Đang diễn ra 3</button>
            <button class="px-2.5 py-1 text-[11px] font-medium rounded-md text-zinc-500 hover:bg-zinc-50 hidden md:block">Chờ duyệt 5</button>
            <a href="${pageContext.request.contextPath}/admin/lich-dat-san" class="text-[11px] font-semibold text-blue-700 hover:underline ml-2">Xem tất cả →</a>
          </div>
        </div>
        <div id="bookingsListContainer" class="divide-y divide-zinc-100">
          <c:if test="${empty recentInvoices}">
            <div class="p-6 text-center text-zinc-400 text-sm">Chưa có hóa đơn nào được lập hôm nay.</div>
          </c:if>
          <c:forEach items="${recentInvoices}" var="hd">
            <div class="flex items-center gap-3 px-5 py-3 hover:bg-zinc-50/50 transition-colors">
              <div class="w-10 h-10 rounded-full bg-zinc-100 flex items-center justify-center text-zinc-700 font-bold text-sm shrink-0">
                ${hd.khachHang != null ? hd.khachHang.fullName.substring(0, 1).toUpperCase() : "K"}
              </div>
              <div class="flex-1 min-w-0">
                <div class="flex items-center gap-2">
                  <p class="text-sm font-semibold text-zinc-900 truncate">
                    ${hd.khachHang != null ? hd.khachHang.fullName : "Khách vãng lai"}
                  </p>
                  <span class="badge badge-blue">HD${hd.hoaDonId}</span>
                </div>
                <div class="flex items-center gap-2 text-[11px] text-zinc-500 mt-0.5">
                  <c:choose>
                    <c:when test="${hd.datSan != null}">
                      <span class="flex items-center gap-0.5">
                        <span class="material-symbols-outlined text-[11px]">
                          <c:choose>
                            <c:when test="${hd.datSan.san.tenSan.contains('Bóng')}">sports_soccer</c:when>
                            <c:when test="${hd.datSan.san.tenSan.contains('Pickleball')}">sports_baseball</c:when>
                            <c:otherwise>sports_tennis</c:otherwise>
                          </c:choose>
                        </span>
                        ${hd.datSan.san.tenSan}
                      </span>
                      <span class="text-zinc-300">·</span>
                      <span class="flex items-center gap-0.5">
                        <span class="material-symbols-outlined text-[11px]">schedule</span>
                        ${hd.datSan.gioBatDau} – ${hd.datSan.gioKetThuc}
                      </span>
                    </c:when>
                    <c:otherwise>
                      <span class="flex items-center gap-0.5">
                        <span class="material-symbols-outlined text-[11px]">inventory_2</span>
                        Hóa đơn dịch vụ
                      </span>
                    </c:otherwise>
                  </c:choose>
                </div>
              </div>
              <div class="text-right shrink-0">
                <p class="text-sm font-bold text-zinc-900">
                  <fmt:formatNumber value="${hd.tongThanhToan}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                </p>
                <span class="badge <c:choose><c:when test="${hd.trangThaiThanhToan == 'Đã thanh toán'}">badge-green</c:when><c:when test="${hd.trangThaiThanhToan == 'Chờ thanh toán'}">badge-amber</c:when><c:otherwise>badge-red</c:otherwise></c:choose> mt-0.5">
                  ${hd.trangThaiThanhToan}
                </span>
              </div>
            </div>
          </c:forEach>
        </div>
      </div>

      <!-- Revenue Chart -->
      <div data-aos="fade-up" class="card p-5">
        <div class="flex items-start justify-between mb-5 flex-wrap gap-3">
          <div>
            <h3 class="text-sm font-bold text-zinc-900 flex items-center gap-2"><span class="material-symbols-outlined text-[18px] text-green-700">bar_chart</span>Doanh thu 7 ngày gần nhất</h3>
            <p class="text-[11px] text-zinc-500 mt-0.5">Tổng <span class="font-bold text-zinc-700">232.5M VNĐ</span> · <span class="text-green-600 font-semibold">+15.3%</span> so với tuần trước</p>
          </div>
          <div class="flex items-center gap-1 bg-zinc-100 rounded-lg p-1">
            <button class="px-3 py-1 text-[11px] font-semibold rounded-md bg-white text-zinc-900 shadow-sm">7 ngày</button>
            <button class="px-3 py-1 text-[11px] font-medium rounded-md text-zinc-500">30 ngày</button>
            <button class="px-3 py-1 text-[11px] font-medium rounded-md text-zinc-500">90 ngày</button>
          </div>
        </div>
        <div class="flex items-end justify-between gap-2 h-48 px-2">
          <div class="flex-1 flex flex-col items-center gap-1.5 group">
            <span class="text-[10px] font-bold text-zinc-400 group-hover:text-zinc-700">28.1M</span>
            <div class="w-full bg-gradient-to-t from-blue-400 to-blue-300 rounded-t-md chart-bar cursor-pointer" style="height:60%"></div>
            <span class="text-[10px] font-semibold text-zinc-500">T2</span>
          </div>
          <div class="flex-1 flex flex-col items-center gap-1.5 group">
            <span class="text-[10px] font-bold text-zinc-400 group-hover:text-zinc-700">34.5M</span>
            <div class="w-full bg-gradient-to-t from-blue-400 to-blue-300 rounded-t-md chart-bar cursor-pointer" style="height:74%"></div>
            <span class="text-[10px] font-semibold text-zinc-500">T3</span>
          </div>
          <div class="flex-1 flex flex-col items-center gap-1.5 group">
            <span class="text-[10px] font-bold text-zinc-400 group-hover:text-zinc-700">22.7M</span>
            <div class="w-full bg-gradient-to-t from-blue-400 to-blue-300 rounded-t-md chart-bar cursor-pointer" style="height:48%"></div>
            <span class="text-[10px] font-semibold text-zinc-500">T4</span>
          </div>
          <div class="flex-1 flex flex-col items-center gap-1.5 group">
            <span class="text-[10px] font-bold text-zinc-700">39.2M</span>
            <div class="w-full bg-gradient-to-t from-blue-600 to-blue-500 rounded-t-md chart-bar cursor-pointer ring-2 ring-blue-200" style="height:84%"></div>
            <span class="text-[10px] font-bold text-blue-700">T5</span>
          </div>
          <div class="flex-1 flex flex-col items-center gap-1.5 group">
            <span class="text-[10px] font-bold text-zinc-400 group-hover:text-zinc-700">31.2M</span>
            <div class="w-full bg-gradient-to-t from-blue-400 to-blue-300 rounded-t-md chart-bar cursor-pointer" style="height:67%"></div>
            <span class="text-[10px] font-semibold text-zinc-500">T6</span>
          </div>
          <div class="flex-1 flex flex-col items-center gap-1.5 group">
            <span class="text-[10px] font-bold text-zinc-400 group-hover:text-zinc-700">41.8M</span>
            <div class="w-full bg-gradient-to-t from-blue-400 to-blue-300 rounded-t-md chart-bar cursor-pointer" style="height:90%"></div>
            <span class="text-[10px] font-semibold text-zinc-500">T7</span>
          </div>
          <div class="flex-1 flex flex-col items-center gap-1.5 group">
            <span class="text-[10px] font-bold text-zinc-400 group-hover:text-zinc-700">35.0M</span>
            <div class="w-full bg-gradient-to-t from-zinc-300 to-zinc-200 rounded-t-md chart-bar cursor-pointer relative" style="height:75%">
              <div class="absolute -top-1.5 left-1/2 -translate-x-1/2 w-2 h-2 rounded-full bg-blue-700 ring-2 ring-white"></div>
            </div>
            <span class="text-[10px] font-semibold text-blue-700">CN (now)</span>
          </div>
        </div>
        <div class="flex items-center gap-4 mt-4 pt-4 border-t border-zinc-100 text-[11px] text-zinc-500 flex-wrap">
          <span class="flex items-center gap-1.5"><span class="w-3 h-3 rounded-sm bg-blue-400"></span>Ngày thường</span>
          <span class="flex items-center gap-1.5"><span class="w-3 h-3 rounded-sm bg-blue-600"></span>Cao điểm</span>
          <span class="flex items-center gap-1.5"><span class="w-3 h-3 rounded-sm bg-zinc-300"></span>Hôm nay (đang chạy)</span>
        </div>
      </div>

    </div>

    <!-- RIGHT 1/3 -->
    <div class="flex flex-col gap-5">

      <!-- Court status -->
      <div data-aos="fade-up" class="card overflow-hidden">
        <div class="flex items-center justify-between px-5 py-4 border-b border-zinc-100">
          <div>
            <h3 class="text-sm font-bold text-zinc-900 flex items-center gap-2"><span class="material-symbols-outlined text-[18px] text-purple-700">stadium</span>Tình trạng sân</h3>
            <p class="text-[11px] text-zinc-500 mt-0.5">12 sẵn sàng · 2 bảo trì · 1 đóng</p>
          </div>
          <a href="${pageContext.request.contextPath}/admin/quan-ly-san" class="text-[11px] font-semibold text-blue-700 hover:underline">Quản lý →</a>
        </div>
        <div class="grid grid-cols-3 gap-2 p-3">
          <div class="aspect-square rounded-xl bg-gradient-to-br from-green-50 to-emerald-50 border border-green-200/60 p-2 flex flex-col justify-between hover:shadow-md transition-shadow cursor-pointer">
            <div class="flex items-start justify-between"><span class="material-symbols-outlined text-[14px] text-green-700">sports_tennis</span><span class="w-1.5 h-1.5 rounded-full bg-green-500 mt-1 live-dot"></span></div>
            <div><p class="text-[10px] font-bold text-zinc-900">A1</p><p class="text-[9px] text-green-700 font-semibold">Đang dùng</p></div>
          </div>
          <div class="aspect-square rounded-xl bg-gradient-to-br from-zinc-50 to-white border border-zinc-200 p-2 flex flex-col justify-between hover:shadow-md transition-shadow cursor-pointer">
            <div class="flex items-start justify-between"><span class="material-symbols-outlined text-[14px] text-zinc-500">sports_tennis</span><span class="w-1.5 h-1.5 rounded-full bg-zinc-300 mt-1"></span></div>
            <div><p class="text-[10px] font-bold text-zinc-900">A2</p><p class="text-[9px] text-zinc-500 font-semibold">Sẵn sàng</p></div>
          </div>
          <div class="aspect-square rounded-xl bg-gradient-to-br from-green-50 to-emerald-50 border border-green-200/60 p-2 flex flex-col justify-between hover:shadow-md transition-shadow cursor-pointer">
            <div class="flex items-start justify-between"><span class="material-symbols-outlined text-[14px] text-green-700">sports_soccer</span><span class="w-1.5 h-1.5 rounded-full bg-green-500 mt-1 live-dot"></span></div>
            <div><p class="text-[10px] font-bold text-zinc-900">A3</p><p class="text-[9px] text-green-700 font-semibold">Đang dùng</p></div>
          </div>
          <div class="aspect-square rounded-xl bg-gradient-to-br from-amber-50 to-orange-50 border border-amber-200/60 p-2 flex flex-col justify-between hover:shadow-md transition-shadow cursor-pointer">
            <div class="flex items-start justify-between"><span class="material-symbols-outlined text-[14px] text-amber-700">build</span><span class="w-1.5 h-1.5 rounded-full bg-amber-500 mt-1"></span></div>
            <div><p class="text-[10px] font-bold text-zinc-900">A4</p><p class="text-[9px] text-amber-700 font-semibold">Bảo trì</p></div>
          </div>
          <div class="aspect-square rounded-xl bg-gradient-to-br from-zinc-50 to-white border border-zinc-200 p-2 flex flex-col justify-between hover:shadow-md transition-shadow cursor-pointer">
            <div class="flex items-start justify-between"><span class="material-symbols-outlined text-[14px] text-zinc-500">sports_tennis</span><span class="w-1.5 h-1.5 rounded-full bg-zinc-300 mt-1"></span></div>
            <div><p class="text-[10px] font-bold text-zinc-900">B1</p><p class="text-[9px] text-zinc-500 font-semibold">Sẵn sàng</p></div>
          </div>
          <div class="aspect-square rounded-xl bg-gradient-to-br from-green-50 to-emerald-50 border border-green-200/60 p-2 flex flex-col justify-between hover:shadow-md transition-shadow cursor-pointer">
            <div class="flex items-start justify-between"><span class="material-symbols-outlined text-[14px] text-green-700">sports_tennis</span><span class="w-1.5 h-1.5 rounded-full bg-green-500 mt-1 live-dot"></span></div>
            <div><p class="text-[10px] font-bold text-zinc-900">B3</p><p class="text-[9px] text-green-700 font-semibold">Đang dùng</p></div>
          </div>
          <div class="aspect-square rounded-xl bg-gradient-to-br from-zinc-50 to-white border border-zinc-200 p-2 flex flex-col justify-between hover:shadow-md transition-shadow cursor-pointer">
            <div class="flex items-start justify-between"><span class="material-symbols-outlined text-[14px] text-zinc-500">sports_baseball</span><span class="w-1.5 h-1.5 rounded-full bg-zinc-300 mt-1"></span></div>
            <div><p class="text-[10px] font-bold text-zinc-900">P1</p><p class="text-[9px] text-zinc-500 font-semibold">Sẵn sàng</p></div>
          </div>
          <div class="aspect-square rounded-xl bg-gradient-to-br from-zinc-50 to-white border border-zinc-200 p-2 flex flex-col justify-between hover:shadow-md transition-shadow cursor-pointer">
            <div class="flex items-start justify-between"><span class="material-symbols-outlined text-[14px] text-zinc-500">sports_baseball</span><span class="w-1.5 h-1.5 rounded-full bg-zinc-300 mt-1"></span></div>
            <div><p class="text-[10px] font-bold text-zinc-900">P2</p><p class="text-[9px] text-zinc-500 font-semibold">Sẵn sàng</p></div>
          </div>
          <div class="aspect-square rounded-xl bg-gradient-to-br from-red-50 to-pink-50 border border-red-200/60 p-2 flex flex-col justify-between hover:shadow-md transition-shadow cursor-pointer">
            <div class="flex items-start justify-between"><span class="material-symbols-outlined text-[14px] text-red-700">block</span><span class="w-1.5 h-1.5 rounded-full bg-red-500 mt-1"></span></div>
            <div><p class="text-[10px] font-bold text-zinc-900">T1</p><p class="text-[9px] text-red-700 font-semibold">Tạm đóng</p></div>
          </div>
        </div>
      </div>

      <!-- Activity feed -->
      <div data-aos="fade-up" class="card overflow-hidden">
        <div class="flex items-center justify-between px-5 py-4 border-b border-zinc-100">
          <h3 class="text-sm font-bold text-zinc-900 flex items-center gap-2"><span class="material-symbols-outlined text-[18px] text-blue-700">timeline</span>Hoạt động gần đây</h3>
          <button class="text-[11px] text-zinc-400 hover:text-zinc-700"><span class="material-symbols-outlined text-[14px]">more_horiz</span></button>
        </div>
        <div id="recentActivitiesContainer" class="px-5 py-3 flex flex-col gap-3">
          <div class="flex items-start gap-3">
            <div class="w-7 h-7 rounded-full bg-green-100 flex items-center justify-center shrink-0"><span class="material-symbols-outlined text-[14px] text-green-700">check_circle</span></div>
            <div class="flex-1 min-w-0"><p class="text-xs text-zinc-700"><span class="font-semibold">Lê Thị Hương</span> vừa thanh toán <span class="font-semibold text-green-700">280.000đ</span></p><p class="text-[10px] text-zinc-400">2 phút trước</p></div>
          </div>
          <div class="flex items-start gap-3">
            <div class="w-7 h-7 rounded-full bg-blue-100 flex items-center justify-center shrink-0"><span class="material-symbols-outlined text-[14px] text-blue-700">event</span></div>
            <div class="flex-1 min-w-0"><p class="text-xs text-zinc-700"><span class="font-semibold">Trần Quốc Việt</span> đặt sân <span class="font-semibold">A2 cầu lông</span></p><p class="text-[10px] text-zinc-400">5 phút trước</p></div>
          </div>
          <div class="flex items-start gap-3">
            <div class="w-7 h-7 rounded-full bg-amber-100 flex items-center justify-center shrink-0"><span class="material-symbols-outlined text-[14px] text-amber-700">inventory_2</span></div>
            <div class="flex-1 min-w-0"><p class="text-xs text-zinc-700">Sản phẩm <span class="font-semibold">Redbull</span> sắp hết (còn <span class="font-semibold text-amber-700">8 chai</span>)</p><p class="text-[10px] text-zinc-400">12 phút trước</p></div>
          </div>
          <div class="flex items-start gap-3">
            <div class="w-7 h-7 rounded-full bg-purple-100 flex items-center justify-center shrink-0"><span class="material-symbols-outlined text-[14px] text-purple-700">person_add</span></div>
            <div class="flex-1 min-w-0"><p class="text-xs text-zinc-700"><span class="font-semibold">Phạm Minh Đức</span> vừa check-in ca sáng</p><p class="text-[10px] text-zinc-400">28 phút trước</p></div>
          </div>
          <div class="flex items-start gap-3">
            <div class="w-7 h-7 rounded-full bg-red-100 flex items-center justify-center shrink-0"><span class="material-symbols-outlined text-[14px] text-red-700">cancel</span></div>
            <div class="flex-1 min-w-0"><p class="text-xs text-zinc-700"><span class="font-semibold">Đỗ Thị Mai</span> đã hủy lịch sân T1</p><p class="text-[10px] text-zinc-400">1 giờ trước</p></div>
          </div>
        </div>
      </div>

    </div>
  </section>

  <!-- BOTTOM 3 COLS -->
  <section data-aos="fade-up" class="grid grid-cols-1 lg:grid-cols-3 gap-5">

    <div data-aos="fade-up" class="card overflow-hidden">
      <div class="px-5 py-4 border-b border-zinc-100 flex items-center justify-between">
        <h3 class="text-sm font-bold text-zinc-900 flex items-center gap-2"><span class="material-symbols-outlined text-[18px] text-green-700">trending_up</span>Top dịch vụ bán chạy</h3>
        <span class="text-[10px] text-zinc-400">Hôm nay</span>
      </div>
      <div class="p-3 flex flex-col gap-2">
        <div class="flex items-center gap-3 p-2 rounded-lg hover:bg-zinc-50">
          <div class="w-10 h-10 rounded-lg overflow-hidden bg-blue-50 shrink-0"><img src="https://images.unsplash.com/photo-1564725073220-fa50fdc6b772?w=80&h=80&fit=crop" class="w-full h-full object-cover" alt=""></div>
          <div class="flex-1 min-w-0"><p class="text-xs font-semibold text-zinc-900 truncate">Nước suối Aquafina</p><p class="text-[10px] text-zinc-500">28 đơn · 280K</p></div>
          <div class="w-12 h-1.5 bg-zinc-100 rounded-full overflow-hidden"><div class="h-full bg-blue-500 rounded-full" style="width:95%"></div></div>
        </div>
        <div class="flex items-center gap-3 p-2 rounded-lg hover:bg-zinc-50">
          <div class="w-10 h-10 rounded-lg overflow-hidden bg-purple-50 shrink-0"><img src="https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=80&h=80&fit=crop" class="w-full h-full object-cover" alt=""></div>
          <div class="flex-1 min-w-0"><p class="text-xs font-semibold text-zinc-900 truncate">Thuê vợt cầu lông</p><p class="text-[10px] text-zinc-500">15 đơn · 300K</p></div>
          <div class="w-12 h-1.5 bg-zinc-100 rounded-full overflow-hidden"><div class="h-full bg-purple-500 rounded-full" style="width:75%"></div></div>
        </div>
        <div class="flex items-center gap-3 p-2 rounded-lg hover:bg-zinc-50">
          <div class="w-10 h-10 rounded-lg overflow-hidden bg-amber-50 shrink-0"><img src="https://images.unsplash.com/photo-1593787406536-3676a72d23a8?w=80&h=80&fit=crop" class="w-full h-full object-cover" alt=""></div>
          <div class="flex-1 min-w-0"><p class="text-xs font-semibold text-zinc-900 truncate">Quả cầu lông (lốc)</p><p class="text-[10px] text-zinc-500">12 đơn · 1.02M</p></div>
          <div class="w-12 h-1.5 bg-zinc-100 rounded-full overflow-hidden"><div class="h-full bg-amber-500 rounded-full" style="width:60%"></div></div>
        </div>
        <div class="flex items-center gap-3 p-2 rounded-lg hover:bg-zinc-50">
          <div class="w-10 h-10 rounded-lg overflow-hidden bg-red-50 shrink-0"><img src="https://images.unsplash.com/photo-1622543925917-763c34d1a86e?w=80&h=80&fit=crop" class="w-full h-full object-cover" alt=""></div>
          <div class="flex-1 min-w-0"><p class="text-xs font-semibold text-zinc-900 truncate">Nước tăng lực</p><p class="text-[10px] text-zinc-500">9 đơn · 225K</p></div>
          <div class="w-12 h-1.5 bg-zinc-100 rounded-full overflow-hidden"><div class="h-full bg-red-500 rounded-full" style="width:45%"></div></div>
        </div>
      </div>
    </div>

    <div data-aos="fade-up" class="card overflow-hidden">
      <div class="px-5 py-4 border-b border-zinc-100 flex items-center justify-between">
        <h3 class="text-sm font-bold text-zinc-900 flex items-center gap-2"><span class="material-symbols-outlined text-[18px] text-amber-600" style="font-variation-settings:'FILL' 1">star</span>Khách hàng VIP</h3>
        <span class="text-[10px] text-zinc-400">Tháng này</span>
      </div>
      <div class="p-3 flex flex-col gap-2">
        <div class="flex items-center gap-3 p-2 rounded-lg hover:bg-zinc-50">
          <div class="relative shrink-0"><img src="https://i.pravatar.cc/40?img=58" class="w-10 h-10 rounded-full object-cover ring-2 ring-amber-200" alt=""><span class="absolute -bottom-0.5 -right-0.5 w-4 h-4 rounded-full bg-amber-500 text-white text-[8px] font-black flex items-center justify-center ring-2 ring-white">1</span></div>
          <div class="flex-1 min-w-0"><p class="text-xs font-semibold text-zinc-900 truncate">Phạm Minh Tuấn</p><p class="text-[10px] text-zinc-500">24 lượt · 4.8M VNĐ</p></div>
          <span class="badge badge-amber">VIP Vàng</span>
        </div>
        <div class="flex items-center gap-3 p-2 rounded-lg hover:bg-zinc-50">
          <div class="relative shrink-0"><img src="https://i.pravatar.cc/40?img=25" class="w-10 h-10 rounded-full object-cover ring-2 ring-zinc-200" alt=""><span class="absolute -bottom-0.5 -right-0.5 w-4 h-4 rounded-full bg-zinc-400 text-white text-[8px] font-black flex items-center justify-center ring-2 ring-white">2</span></div>
          <div class="flex-1 min-w-0"><p class="text-xs font-semibold text-zinc-900 truncate">Trần Thị Lan</p><p class="text-[10px] text-zinc-500">18 lượt · 3.2M VNĐ</p></div>
          <span class="badge badge-gray">VIP Bạc</span>
        </div>
        <div class="flex items-center gap-3 p-2 rounded-lg hover:bg-zinc-50">
          <div class="relative shrink-0"><img src="https://i.pravatar.cc/40?img=11" class="w-10 h-10 rounded-full object-cover ring-2 ring-orange-200" alt=""><span class="absolute -bottom-0.5 -right-0.5 w-4 h-4 rounded-full bg-orange-500 text-white text-[8px] font-black flex items-center justify-center ring-2 ring-white">3</span></div>
          <div class="flex-1 min-w-0"><p class="text-xs font-semibold text-zinc-900 truncate">Nguyễn Văn Hùng</p><p class="text-[10px] text-zinc-500">15 lượt · 2.8M VNĐ</p></div>
          <span class="badge badge-amber">VIP Đồng</span>
        </div>
        <div class="flex items-center gap-3 p-2 rounded-lg hover:bg-zinc-50">
          <img src="https://i.pravatar.cc/40?img=32" class="w-10 h-10 rounded-full object-cover ring-2 ring-zinc-100 shrink-0" alt="">
          <div class="flex-1 min-w-0"><p class="text-xs font-semibold text-zinc-900 truncate">Lê Hoàng Việt</p><p class="text-[10px] text-zinc-500">12 lượt · 2.1M VNĐ</p></div>
          <button class="text-[10px] text-zinc-700 font-semibold hover:underline">Xem</button>
        </div>
      </div>
    </div>

    <div data-aos="fade-up" class="card overflow-hidden">
      <div class="px-5 py-4 border-b border-zinc-100 flex items-center justify-between">
        <h3 class="text-sm font-bold text-zinc-900 flex items-center gap-2"><span class="material-symbols-outlined text-[18px] text-red-600">warning</span>Cảnh báo & nhắc việc</h3>
        <span class="badge badge-red">5 mới</span>
      </div>
      <div class="p-3 flex flex-col gap-2">
        <div class="flex items-start gap-3 p-3 rounded-lg bg-red-50/50 border border-red-100">
          <span class="material-symbols-outlined text-[16px] text-red-600 mt-0.5">currency_exchange</span>
          <div class="flex-1 min-w-0"><p class="text-xs font-semibold text-zinc-900">3 yêu cầu hoàn tiền chờ duyệt</p><p class="text-[10px] text-zinc-500 mt-0.5">Tổng 445.000đ · Quá hạn 2 yêu cầu</p><a href="${pageContext.request.contextPath}/admin/hoa-don" class="text-[10px] text-red-700 font-semibold hover:underline mt-1 inline-block">Duyệt ngay →</a></div>
        </div>
        <div class="flex items-start gap-3 p-3 rounded-lg bg-amber-50/50 border border-amber-100">
          <span class="material-symbols-outlined text-[16px] text-amber-600 mt-0.5">inventory_2</span>
          <div class="flex-1 min-w-0"><p class="text-xs font-semibold text-zinc-900">3 sản phẩm sắp hết hàng</p><p class="text-[10px] text-zinc-500 mt-0.5">Redbull (8), Quả cầu lông (5), Khăn (0)</p><a href="${pageContext.request.contextPath}/admin/kho-dich-vu" class="text-[10px] text-amber-700 font-semibold hover:underline mt-1 inline-block">Nhập kho →</a></div>
        </div>
        <div class="flex items-start gap-3 p-3 rounded-lg bg-blue-50/50 border border-blue-100">
          <span class="material-symbols-outlined text-[16px] text-blue-600 mt-0.5">build</span>
          <div class="flex-1 min-w-0"><p class="text-xs font-semibold text-zinc-900">Sân A4 sắp hết hạn bảo trì</p><p class="text-[10px] text-zinc-500 mt-0.5">Dự kiến hoàn thành 20/05/2026</p></div>
        </div>
        <div class="flex items-start gap-3 p-3 rounded-lg bg-purple-50/50 border border-purple-100">
          <span class="material-symbols-outlined text-[16px] text-purple-600 mt-0.5">campaign</span>
          <div class="flex-1 min-w-0">
            <p class="text-xs font-semibold text-zinc-900">Chiến dịch khuyến mãi hè sắp kết thúc</p>
            <p class="text-[10px] text-zinc-500 mt-0.5">Khuyến mãi Hè 2026 sẽ kết thúc sau 3 ngày nữa</p>
            <a href="${pageContext.request.contextPath}/admin/khuyen-mai" class="text-[10px] text-purple-700 font-semibold hover:underline mt-1 inline-block">Xem chi tiết →</a>
          </div>
        </div>
      </div>
    </div>

<!-- Admin Support Chat Drawer -->
<div id="adminChatDrawer" class="fixed inset-y-0 right-0 w-full sm:w-[400px] bg-white border-l border-zinc-200 shadow-2xl z-[150] transform translate-x-full transition-transform duration-300 ease-in-out flex flex-col">
    <!-- Header -->
    <div class="px-5 py-4 border-b border-zinc-100 flex items-center justify-between bg-zinc-50">
        <div class="flex items-center gap-3">
            <div class="relative">
                <img src="https://ui-avatars.com/api/?name=Admin&background=18181b&color=fff&bold=true" class="w-10 h-10 rounded-full ring-2 ring-blue-500/20 object-cover" alt="Admin">
                <span class="absolute bottom-0 right-0 w-3 h-3 bg-green-500 rounded-full border-2 border-white"></span>
            </div>
            <div>
                <h3 class="text-sm font-bold text-zinc-900 leading-tight">Admin Hệ thống</h3>
                <p class="text-[11px] text-green-600 font-medium flex items-center gap-1"><span class="w-1.5 h-1.5 rounded-full bg-green-500 inline-block animate-pulse"></span> Đang trực tuyến</p>
            </div>
        </div>
        <button onclick="toggleAdminChat()" class="w-8 h-8 rounded-full hover:bg-zinc-200 flex items-center justify-center text-zinc-500 transition-colors"><span class="material-symbols-outlined text-[20px]">close</span></button>
    </div>
    
    <!-- Messages Body -->
    <div id="chatMessages" class="flex-1 overflow-y-auto p-5 flex flex-col gap-5 bg-white">
        <div class="text-center mb-2">
            <span class="text-[10px] font-medium text-zinc-500 bg-zinc-100 px-3 py-1 rounded-full">Hôm nay</span>
        </div>
        
        <!-- Admin Msg -->
        <div class="flex items-start gap-2 max-w-[85%]">
            <img src="https://ui-avatars.com/api/?name=Admin&background=18181b&color=fff&bold=true" class="w-8 h-8 rounded-full shadow-sm" alt="Admin">
            <div>
                <div class="bg-zinc-100 px-4 py-2.5 rounded-2xl rounded-tl-sm text-sm text-zinc-800">
                    Chào bạn, Cơ Sở hôm nay hoạt động ổn chứ? Cần hỗ trợ gì cứ nhắn tin nhé!
                </div>
                <p class="text-[10px] text-zinc-400 mt-1 ml-1">08:30</p>
            </div>
        </div>
        
        <!-- User Msg -->
        <div class="flex items-start gap-2 max-w-[85%] self-end flex-row-reverse">
            <img src="https://ui-avatars.com/api/?name=Quan+Ly&background=1d4ed8&color=fff&bold=true" class="w-8 h-8 rounded-full shadow-sm" alt="Quản lý">
            <div>
                <div class="bg-blue-600 text-white px-4 py-2.5 rounded-2xl rounded-tr-sm text-sm shadow-sm shadow-blue-600/20">
                    Dạ Cơ Sở CS01 ổn ạ. Doanh thu đang đạt target tốt.
                </div>
                <p class="text-[10px] text-zinc-400 mt-1 mr-1 text-right">09:15</p>
            </div>
        </div>
    </div>
    
    <!-- Input Area -->
    <div class="p-4 border-t border-zinc-100 bg-white shrink-0">
        <form onsubmit="sendAdminMessage(event)" class="flex items-end gap-2 relative">
            <button type="button" class="p-2 mb-1 text-zinc-400 hover:text-blue-600 transition-colors hover:bg-zinc-100 rounded-full"><span class="material-symbols-outlined text-[20px]">attach_file</span></button>
            <div class="flex-1 bg-zinc-50 border border-zinc-200 rounded-2xl p-1 pr-1.5 flex items-end focus-within:border-blue-500 focus-within:ring-1 focus-within:ring-blue-500 transition-all">
                <textarea id="chatInput" rows="1" placeholder="Nhập tin nhắn..." class="w-full bg-transparent border-none focus:ring-0 text-sm text-zinc-800 px-3 py-2.5 resize-none max-h-24 outline-none leading-snug" onkeydown="if(event.key === 'Enter' && !event.shiftKey) { event.preventDefault(); sendAdminMessage(event); }" oninput="this.style.height = '';this.style.height = this.scrollHeight + 'px'"></textarea>
                <button type="submit" class="w-8 h-8 mb-1 rounded-full bg-blue-600 text-white flex items-center justify-center shrink-0 hover:bg-blue-700 active:scale-95 transition-all"><span class="material-symbols-outlined text-[16px] -ml-0.5">send</span></button>
            </div>
        </form>
    </div>
</div>
<!-- Backdrop for Chat -->
<div id="adminChatBackdrop" onclick="toggleAdminChat()" class="fixed inset-0 bg-black/20 backdrop-blur-[2px] z-[140] hidden opacity-0 transition-opacity duration-300"></div>

<script>
    // Chat Drawer Logic
    window.toggleAdminChat = function() {
        const drawer = document.getElementById('adminChatDrawer');
        const backdrop = document.getElementById('adminChatBackdrop');
        if(drawer.classList.contains('translate-x-full')) {
            drawer.classList.remove('translate-x-full');
            backdrop.classList.remove('hidden');
            // Ensure scroll is at bottom when opening
            const chatBody = document.getElementById('chatMessages');
            chatBody.scrollTop = chatBody.scrollHeight;
            setTimeout(() => backdrop.classList.remove('opacity-0'), 10);
        } else {
            drawer.classList.add('translate-x-full');
            backdrop.classList.add('opacity-0');
            setTimeout(() => backdrop.classList.add('hidden'), 300);
        }
    };

    window.sendAdminMessage = function(e) {
        e.preventDefault();
        const input = document.getElementById('chatInput');
        const msg = input.value.trim();
        if(!msg) return;
        
        const chatBody = document.getElementById('chatMessages');
        const now = new Date();
        const timeStr = String(now.getHours()).padStart(2, '0') + ':' + String(now.getMinutes()).padStart(2, '0');
        
        const msgHTML = `
            <div class="flex items-start gap-2 max-w-[85%] self-end flex-row-reverse animate__animated animate__fadeInUp animate__faster">
                <img src="https://ui-avatars.com/api/?name=Quan+Ly&background=1d4ed8&color=fff&bold=true" class="w-8 h-8 rounded-full shadow-sm" alt="Quản lý">
                <div>
                    <div class="bg-blue-600 text-white px-4 py-2.5 rounded-2xl rounded-tr-sm text-sm shadow-sm shadow-blue-600/20">
                        \${msg.replace(/\n/g, '<br>')}
                    </div>
                    <p class="text-[10px] text-zinc-400 mt-1 mr-1 text-right">\${timeStr}</p>
                </div>
            </div>
        `;
        chatBody.insertAdjacentHTML('beforeend', msgHTML);
        input.value = '';
        input.style.height = 'auto'; // reset height
        chatBody.scrollTop = chatBody.scrollHeight;
        
        // Auto reply demo
        setTimeout(() => {
            const replyTime = new Date();
            const replyTimeStr = String(replyTime.getHours()).padStart(2, '0') + ':' + String(replyTime.getMinutes()).padStart(2, '0');
            const replyHTML = `
                <div class="flex items-start gap-2 max-w-[85%] animate__animated animate__fadeInUp animate__faster">
                    <img src="https://ui-avatars.com/api/?name=Admin&background=18181b&color=fff&bold=true" class="w-8 h-8 rounded-full shadow-sm" alt="Admin">
                    <div>
                        <div class="bg-zinc-100 px-4 py-2.5 rounded-2xl rounded-tl-sm text-sm text-zinc-800">
                            Đã nhận thông tin. Admin sẽ phản hồi trong giây lát nhé!
                        </div>
                        <p class="text-[10px] text-zinc-400 mt-1 ml-1">\${replyTimeStr}</p>
                    </div>
                </div>
            `;
            chatBody.insertAdjacentHTML('beforeend', replyHTML);
            chatBody.scrollTop = chatBody.scrollHeight;
        }, 1200);
    };
</script>
</body>
</html>
