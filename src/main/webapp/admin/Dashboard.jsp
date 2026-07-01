<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Dashboard — V-SPORT Admin</title>
<script src="https://cdn.tailwindcss.com"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200">
<style>
  body { font-family: 'Inter', sans-serif; }
  .card { background:#fff;border:1px solid #e4e4e7;border-radius:16px; transition:box-shadow .2s, transform .2s; }
  .card-hover:hover { box-shadow:0 8px 24px -8px rgba(0,0,0,.1); transform:translateY(-2px); }
  .badge { display:inline-flex;align-items:center;padding:4px 10px;border-radius:8px;font-size:11px;font-weight:600; }
  .badge-green { background:#dcfce7;color:#15803d; }
  .badge-amber { background:#fef3c7;color:#b45309; }
  .badge-red { background:#fee2e2;color:#b91c1c; }
  .badge-blue { background:#dbeafe;color:#1e40af; }
  .badge-gray { background:#f4f4f5;color:#52525b; }
  .badge-purple { background:#f3e8ff;color:#7e22ce; }
  .badge-cyan { background:#cffafe;color:#0e7490; }

  ::-webkit-scrollbar{width:6px;height:6px}
  ::-webkit-scrollbar-track{background:transparent}
  ::-webkit-scrollbar-thumb{background:#d4d4d8;border-radius:6px}
  ::-webkit-scrollbar-thumb:hover{background:#a1a1aa}

  /* Animations */
  @keyframes fadeUp { from { opacity:0; transform:translateY(14px); } to { opacity:1; transform:translateY(0); } }
  @keyframes pop { 0%{opacity:0;transform:scale(.93)}100%{opacity:1;transform:scale(1)} }
  @keyframes drawBar { from{transform:scaleY(0)} to{transform:scaleY(1)} }
  @keyframes pulse-dot { 0%,100%{box-shadow:0 0 0 0 rgba(34,197,94,.4);} 50%{box-shadow:0 0 0 6px rgba(34,197,94,0);} }
  @keyframes slideRight { from{width:0} to{width:var(--w)} }
  @keyframes contentZoomIn { from{opacity:0;transform:scale(.97)} to{opacity:1;transform:scale(1)} }
  @keyframes numberCount { from{opacity:0;transform:translateY(6px)} to{opacity:1;transform:translateY(0)} }

  main { animation: contentZoomIn 0.35s cubic-bezier(0.34,1.56,0.64,1) forwards; transform-origin: center top; }
  .kpi-card { animation: pop 0.4s cubic-bezier(0.34,1.56,0.64,1) both; }
  .kpi-card:nth-child(1){animation-delay:40ms}
  .kpi-card:nth-child(2){animation-delay:100ms}
  .kpi-card:nth-child(3){animation-delay:160ms}
  .kpi-card:nth-child(4){animation-delay:220ms}
  .section-anim { animation: fadeUp 0.45s ease both; }
  .section-anim:nth-child(1){animation-delay:0ms}
  .section-anim:nth-child(2){animation-delay:80ms}
  .section-anim:nth-child(3){animation-delay:160ms}
  .section-anim:nth-child(4){animation-delay:240ms}

  .chart-bar { transform-origin: bottom; animation: drawBar 0.65s cubic-bezier(.34,1.56,.64,1) both; }
  .chart-bar:nth-child(1){animation-delay:60ms}
  .chart-bar:nth-child(2){animation-delay:120ms}
  .chart-bar:nth-child(3){animation-delay:180ms}
  .chart-bar:nth-child(4){animation-delay:240ms}
  .chart-bar:nth-child(5){animation-delay:300ms}
  .chart-bar:nth-child(6){animation-delay:360ms}
  .chart-bar:nth-child(7){animation-delay:420ms}
  .chart-bar:nth-child(8){animation-delay:480ms}
  .chart-bar:nth-child(9){animation-delay:540ms}
  .chart-bar:nth-child(10){animation-delay:600ms}
  .chart-bar:nth-child(11){animation-delay:660ms}
  .chart-bar:nth-child(12){animation-delay:720ms}

  .progress-bar { animation: slideRight 1s cubic-bezier(.34,1.1,.64,1) both; animation-delay: 400ms; }

  .live-dot { animation: pulse-dot 1.6s ease-in-out infinite; }
  button { transition: transform .12s ease, background-color .15s ease; }
  button:active:not([disabled]) { transform: scale(.97); }

  /* Tooltip */
  .tooltip-wrap { position: relative; }
  .tooltip-wrap:hover .tooltip-box { opacity: 1; transform: translateY(0); pointer-events: auto; }
  .tooltip-box { position: absolute; bottom: calc(100% + 8px); left: 50%; transform: translateX(-50%) translateY(4px); background: #18181b; color: #fff; font-size: 11px; font-weight: 600; padding: 5px 10px; border-radius: 8px; white-space: nowrap; opacity: 0; pointer-events: none; transition: opacity .2s, transform .2s; z-index: 50; }
  .tooltip-box::after { content:''; position:absolute; top:100%; left:50%; transform:translateX(-50%); border:5px solid transparent; border-top-color:#18181b; }

  /* Trend micro chart */
  .sparkline { stroke: currentColor; fill: none; stroke-width: 1.5; stroke-linecap: round; stroke-linejoin: round; }
  .sparkline-fill { fill: currentColor; opacity: .1; stroke: none; }

  /* Table row hover */
  .trow:hover { background:#f9fafb; }

  @media (prefers-reduced-motion: reduce){*,*::before,*::after{animation:none!important;transition:none!important;}}
</style>
</head>
<body class="bg-zinc-50 text-zinc-900 min-h-screen">

<!-- Sidebar -->
<jsp:include page="/admin/common/sidebar.jsp" />

<!-- Header -->
<header class="h-[64px] fixed top-0 right-0 left-0 lg:left-[260px] bg-white/80 backdrop-blur-lg border-b border-zinc-200 z-20 flex items-center justify-between px-4 lg:px-6">
  <div class="flex items-center gap-3">
    <button id="mobileMenuBtn" class="lg:hidden p-2 rounded-lg hover:bg-zinc-100 text-zinc-500"><span class="material-symbols-outlined text-[20px]">menu</span></button>
    <div>
      <h1 class="text-sm font-bold text-zinc-900 tracking-tight flex items-center gap-2">
        <span class="material-symbols-outlined text-[16px] text-blue-600" style="font-variation-settings:'FILL' 1">dashboard</span>
        Dashboard — Tổng quan hệ thống
      </h1>
      <p class="text-xs text-zinc-500 flex items-center gap-1.5" id="headerDateTime">
        <span class="material-symbols-outlined text-[12px]">schedule</span>
        <span id="currentDateTimeText">Đang tải...</span>
        <span class="text-zinc-300 mx-0.5">·</span>
        <span class="text-green-600 font-semibold flex items-center gap-1"><span class="w-1.5 h-1.5 rounded-full bg-green-500 live-dot inline-block"></span>Hệ thống hoạt động bình thường</span>
      </p>
    </div>
  </div>
  <div class="flex items-center gap-1.5">
    <!-- Date range selector -->
    <div class="hidden md:flex items-center gap-1 bg-zinc-100 rounded-lg p-1">
      <button id="rangeToday" onclick="setDateRange('today')" class="px-3 py-1 text-[11px] font-semibold rounded-md bg-white text-zinc-900 shadow-sm">Hôm nay</button>
      <button id="rangeWeek" onclick="setDateRange('week')" class="px-3 py-1 text-[11px] font-medium rounded-md text-zinc-500 hover:bg-white/60">7 ngày</button>
      <button id="rangeMonth" onclick="setDateRange('month')" class="px-3 py-1 text-[11px] font-medium rounded-md text-zinc-500 hover:bg-white/60">Tháng này</button>
    </div>
    <button class="relative p-2 rounded-lg hover:bg-zinc-100 text-zinc-500">
      <span class="material-symbols-outlined text-[20px]">notifications</span>
      <span class="absolute top-1.5 right-1.5 w-2 h-2 rounded-full bg-red-500 live-dot"></span>
    </button>
    <div class="w-px h-6 bg-zinc-200 mx-1"></div>
    <jsp:include page="/admin/common/profile_dropdown.jsp" />
  </div>
</header>

<!-- Main Content -->
<main class="lg:ml-[260px] mt-[64px] p-4 lg:p-6 flex flex-col gap-5">

  <!-- ===== SECTION 1: KPI CARDS ===== -->
  <section class="grid grid-cols-2 lg:grid-cols-4 gap-4">

    <!-- Card 1: Doanh thu hôm nay -->
    <div class="card card-hover kpi-card p-5 relative overflow-hidden">
      <div class="absolute -top-6 -right-6 w-24 h-24 rounded-full bg-green-50 opacity-60 pointer-events-none"></div>
      <div class="relative">
        <div class="flex items-start justify-between mb-3">
          <div class="w-11 h-11 rounded-xl bg-green-50 flex items-center justify-center shrink-0">
            <span class="material-symbols-outlined text-[22px] text-green-700" style="font-variation-settings:'FILL' 1">payments</span>
          </div>
          <span class="flex items-center gap-0.5 text-[11px] font-bold text-green-600 bg-green-50 px-2 py-0.5 rounded-md">
            <span class="material-symbols-outlined text-[12px]">trending_up</span>
            <span id="kpiRevenueTrend">+0%</span>
          </span>
        </div>
        <p class="text-xs text-zinc-500 font-medium mb-1">Doanh thu hôm nay</p>
        <p class="text-2xl font-black text-zinc-900 tracking-tight" id="kpiRevenueToday">
          <fmt:formatNumber value="${revenueToday != null ? revenueToday : 0}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
        </p>
        <div class="flex items-center justify-between mt-3 pt-3 border-t border-zinc-100">
          <p class="text-[11px] text-zinc-500">Tháng này: <span class="font-semibold text-zinc-700" id="kpiRevenueMonth">0đ</span></p>
          <!-- Sparkline -->
          <svg width="56" height="22" viewBox="0 0 56 22" class="text-green-500 shrink-0">
            <polyline class="sparkline-fill" points="0,18 8,14 16,16 24,10 32,12 40,6 56,9 56,22 0,22"/>
            <polyline class="sparkline" points="0,18 8,14 16,16 24,10 32,12 40,6 56,9"/>
          </svg>
        </div>
      </div>
    </div>

    <!-- Card 2: Booking hôm nay -->
    <div class="card card-hover kpi-card p-5 relative overflow-hidden">
      <div class="absolute -top-6 -right-6 w-24 h-24 rounded-full bg-blue-50 opacity-60 pointer-events-none"></div>
      <div class="relative">
        <div class="flex items-start justify-between mb-3">
          <div class="w-11 h-11 rounded-xl bg-blue-50 flex items-center justify-center shrink-0">
            <span class="material-symbols-outlined text-[22px] text-blue-700" style="font-variation-settings:'FILL' 1">event_available</span>
          </div>
          <span class="flex items-center gap-0.5 text-[11px] font-bold text-blue-600 bg-blue-50 px-2 py-0.5 rounded-md">
            <span class="material-symbols-outlined text-[12px]">trending_up</span>
            <span id="kpiBookingTrend">+0%</span>
          </span>
        </div>
        <p class="text-xs text-zinc-500 font-medium mb-1">Booking hôm nay</p>
        <p class="text-2xl font-black text-zinc-900 tracking-tight" id="kpiBookingToday">${bookingToday != null ? bookingToday : 0}</p>
        <div class="flex items-center justify-between mt-3 pt-3 border-t border-zinc-100">
          <p class="text-[11px] text-zinc-500"><span class="text-amber-600 font-semibold" id="kpiBookingPending">0</span> chờ xác nhận</p>
          <svg width="56" height="22" viewBox="0 0 56 22" class="text-blue-500 shrink-0">
            <polyline class="sparkline-fill" points="0,16 8,13 16,15 24,8 32,11 40,5 56,8 56,22 0,22"/>
            <polyline class="sparkline" points="0,16 8,13 16,15 24,8 32,11 40,5 56,8"/>
          </svg>
        </div>
      </div>
    </div>

    <!-- Card 3: Khách hàng -->
    <div class="card card-hover kpi-card p-5 relative overflow-hidden">
      <div class="absolute -top-6 -right-6 w-24 h-24 rounded-full bg-purple-50 opacity-60 pointer-events-none"></div>
      <div class="relative">
        <div class="flex items-start justify-between mb-3">
          <div class="w-11 h-11 rounded-xl bg-purple-50 flex items-center justify-center shrink-0">
            <span class="material-symbols-outlined text-[22px] text-purple-700" style="font-variation-settings:'FILL' 1">group</span>
          </div>
          <span class="flex items-center gap-0.5 text-[11px] font-bold text-purple-600 bg-purple-50 px-2 py-0.5 rounded-md">
            <span class="material-symbols-outlined text-[12px]">person_add</span>
            <span id="kpiNewCustomers">+0</span> mới
          </span>
        </div>
        <p class="text-xs text-zinc-500 font-medium mb-1">Tổng khách hàng</p>
        <p class="text-2xl font-black text-zinc-900 tracking-tight" id="kpiTotalCustomers">${totalCustomers != null ? totalCustomers : 0}</p>
        <div class="flex items-center justify-between mt-3 pt-3 border-t border-zinc-100">
          <p class="text-[11px] text-zinc-500">Đăng ký tháng này: <span class="font-semibold text-purple-700" id="kpiMonthCustomers">0</span></p>
          <svg width="56" height="22" viewBox="0 0 56 22" class="text-purple-500 shrink-0">
            <polyline class="sparkline-fill" points="0,20 8,17 16,14 24,12 32,9 40,7 56,5 56,22 0,22"/>
            <polyline class="sparkline" points="0,20 8,17 16,14 24,12 32,9 40,7 56,5"/>
          </svg>
        </div>
      </div>
    </div>

    <!-- Card 4: Tỷ lệ lấp đầy -->
    <div class="card card-hover kpi-card p-5 relative overflow-hidden">
      <div class="absolute -top-6 -right-6 w-24 h-24 rounded-full bg-amber-50 opacity-60 pointer-events-none"></div>
      <div class="relative">
        <div class="flex items-start justify-between mb-3">
          <div class="w-11 h-11 rounded-xl bg-amber-50 flex items-center justify-center shrink-0">
            <span class="material-symbols-outlined text-[22px] text-amber-700" style="font-variation-settings:'FILL' 1">stadium</span>
          </div>
          <span class="flex items-center gap-0.5 text-[11px] font-bold text-amber-600 bg-amber-50 px-2 py-0.5 rounded-md">
            <span class="material-symbols-outlined text-[12px]">schedule</span>
            Hôm nay
          </span>
        </div>
        <p class="text-xs text-zinc-500 font-medium mb-1">Tỷ lệ lấp đầy sân</p>
        <p class="text-2xl font-black text-zinc-900 tracking-tight" id="kpiFillRate">
          ${fillRate != null ? fillRate : 0}<span class="text-lg font-bold text-zinc-400">%</span>
        </p>
        <div class="mt-3 pt-3 border-t border-zinc-100">
          <!-- Donut-style progress bar -->
          <div class="flex items-center gap-2">
            <div class="flex-1 h-2 bg-zinc-100 rounded-full overflow-hidden">
              <div class="h-full bg-gradient-to-r from-amber-400 to-orange-500 rounded-full progress-bar"
                   style="--w:${fillRate != null ? fillRate : 0}%; width:${fillRate != null ? fillRate : 0}%"></div>
            </div>
            <span class="text-[11px] font-semibold text-amber-700">${activeCourts != null ? activeCourts : 0}/${totalCourts != null ? totalCourts : 0} sân</span>
          </div>
        </div>
      </div>
    </div>

  </section>

  <!-- ===== SECTION 2: CHARTS ROW ===== -->
  <section class="grid grid-cols-1 xl:grid-cols-3 gap-5 section-anim">

    <!-- Chart Left: Doanh thu theo tháng (2/3 width) -->
    <div class="xl:col-span-2 card p-5">
      <div class="flex items-start justify-between mb-5 flex-wrap gap-3">
        <div>
          <h3 class="text-sm font-bold text-zinc-900 flex items-center gap-2">
            <span class="material-symbols-outlined text-[18px] text-green-600" style="font-variation-settings:'FILL' 1">bar_chart</span>
            Doanh thu theo tháng
          </h3>
          <p class="text-[11px] text-zinc-500 mt-0.5">
            Tổng năm <span class="font-bold text-zinc-700" id="totalRevenueYear">0đ</span>
            · <span class="text-green-600 font-semibold" id="revenueYoY">+0%</span> so với năm ngoái
          </p>
        </div>
        <div class="flex items-center gap-2">
          <select id="revenueYearSelect" onchange="renderRevenueChart()" class="h-8 px-2.5 rounded-lg border border-zinc-200 bg-white text-xs font-medium text-zinc-700 focus:outline-none focus:ring-2 focus:ring-zinc-300">
            <option value="2026">2026</option>
            <option value="2025">2025</option>
          </select>
        </div>
      </div>

      <!-- Bar Chart -->
      <div class="flex items-end justify-between gap-1.5 h-52 px-1" id="revenueChartContainer">
        <!-- Rendered by JS -->
      </div>

      <!-- Legend -->
      <div class="flex items-center gap-5 mt-4 pt-4 border-t border-zinc-100 text-[11px] text-zinc-500 flex-wrap">
        <span class="flex items-center gap-1.5"><span class="w-3 h-3 rounded-sm bg-gradient-to-t from-blue-500 to-blue-400"></span>Doanh thu</span>
        <span class="flex items-center gap-1.5"><span class="w-3 h-3 rounded-sm bg-gradient-to-t from-green-500 to-emerald-400"></span>Tháng cao nhất</span>
        <span class="flex items-center gap-1.5 ml-auto font-medium text-zinc-600">
          <span class="material-symbols-outlined text-[13px] text-blue-600">info</span>
          Hover vào cột để xem chi tiết
        </span>
      </div>
    </div>

    <!-- Chart Right: Booking theo ngày trong tuần (1/3 width) -->
    <div class="card p-5 flex flex-col">
      <div class="flex items-start justify-between mb-4">
        <div>
          <h3 class="text-sm font-bold text-zinc-900 flex items-center gap-2">
            <span class="material-symbols-outlined text-[18px] text-blue-600" style="font-variation-settings:'FILL' 1">event_note</span>
            Booking 7 ngày gần nhất
          </h3>
          <p class="text-[11px] text-zinc-500 mt-0.5">Lượt đặt sân theo ngày</p>
        </div>
        <span class="badge badge-blue" id="weekTotalBookings">0 lượt</span>
      </div>

      <!-- Booking day bars (horizontal) -->
      <div class="flex flex-col gap-2.5 flex-1" id="bookingDayBarsContainer">
        <!-- Rendered by JS -->
      </div>

      <!-- Donut summary -->
      <div class="mt-4 pt-4 border-t border-zinc-100 grid grid-cols-3 gap-2 text-center">
        <div>
          <p class="text-[10px] text-zinc-400 mb-0.5">Cuối tuần</p>
          <p class="text-sm font-black text-blue-700" id="weekendBookings">0</p>
        </div>
        <div class="border-x border-zinc-100">
          <p class="text-[10px] text-zinc-400 mb-0.5">Ngày thường</p>
          <p class="text-sm font-black text-zinc-800" id="weekdayBookings">0</p>
        </div>
        <div>
          <p class="text-[10px] text-zinc-400 mb-0.5">TB / ngày</p>
          <p class="text-sm font-black text-green-700" id="avgDailyBookings">0</p>
        </div>
      </div>
    </div>

  </section>

  <!-- ===== SECTION 3: TOP CHI NHÁNH + BOOKING GẦN ĐÂY ===== -->
  <section class="grid grid-cols-1 xl:grid-cols-5 gap-5 section-anim">

    <!-- Top Chi Nhánh (2/5) -->
    <div class="xl:col-span-2 card overflow-hidden">
      <div class="flex items-center justify-between px-5 py-4 border-b border-zinc-100">
        <div>
          <h3 class="text-sm font-bold text-zinc-900 flex items-center gap-2">
            <span class="material-symbols-outlined text-[18px] text-amber-600" style="font-variation-settings:'FILL' 1">storefront</span>
            Top chi nhánh
          </h3>
          <p class="text-[11px] text-zinc-500 mt-0.5">Xếp hạng theo doanh thu tháng này</p>
        </div>
        <a href="${pageContext.request.contextPath}/admin/chi-nhanh" class="text-[11px] font-semibold text-blue-700 hover:underline flex items-center gap-0.5">
          Tất cả <span class="material-symbols-outlined text-[13px]">arrow_forward</span>
        </a>
      </div>

      <div class="p-3 flex flex-col gap-1" id="topBranchesContainer">
        <!-- Rendered by JS -->
        <c:if test="${empty topBranches}">
          <div class="px-4 py-8 text-center text-zinc-400 text-xs">Chưa có dữ liệu chi nhánh.</div>
        </c:if>
        <c:forEach items="${topBranches}" var="branch" varStatus="vs">
          <div class="flex items-center gap-3 p-2.5 rounded-xl hover:bg-zinc-50 transition-colors group cursor-pointer">
            <!-- Rank badge -->
            <div class="w-7 h-7 rounded-full shrink-0 flex items-center justify-center text-[11px] font-black
              ${vs.index == 0 ? 'bg-amber-100 text-amber-700' : vs.index == 1 ? 'bg-zinc-200 text-zinc-700' : vs.index == 2 ? 'bg-orange-100 text-orange-700' : 'bg-zinc-100 text-zinc-500'}">
              ${vs.index + 1}
            </div>
            <!-- Branch Info -->
            <div class="flex-1 min-w-0">
              <p class="text-xs font-semibold text-zinc-900 truncate">${branch.tenChiNhanh != null ? branch.tenChiNhanh : 'Chi nhánh '.concat(vs.index + 1)}</p>
              <div class="flex items-center gap-2 mt-1">
                <div class="flex-1 h-1.5 bg-zinc-100 rounded-full overflow-hidden">
                  <div class="h-full rounded-full progress-bar
                    ${vs.index == 0 ? 'bg-gradient-to-r from-amber-400 to-yellow-400' : vs.index == 1 ? 'bg-gradient-to-r from-zinc-400 to-zinc-300' : vs.index == 2 ? 'bg-gradient-to-r from-orange-400 to-orange-300' : 'bg-gradient-to-r from-blue-400 to-blue-300'}"
                    style="--w:${vs.index == 0 ? 100 : vs.index == 1 ? 78 : vs.index == 2 ? 61 : 45}%;
                           width:${vs.index == 0 ? 100 : vs.index == 1 ? 78 : vs.index == 2 ? 61 : 45}%">
                  </div>
                </div>
                <span class="text-[10px] font-bold text-zinc-500 shrink-0">
                  <fmt:formatNumber value="${branch.doanhThu != null ? branch.doanhThu : 0}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                </span>
              </div>
            </div>
            <!-- Booking count -->
            <div class="text-right shrink-0">
              <p class="text-xs font-bold text-zinc-800">${branch.soBooking != null ? branch.soBooking : 0}</p>
              <p class="text-[10px] text-zinc-400">booking</p>
            </div>
          </div>
        </c:forEach>

        <!-- Fallback mock if no data -->
        <c:if test="${empty topBranches}">
          <script>
          (function() {
            var mockBranches = [
              { name: 'V-Sport Vũng Tàu', revenue: '48.2M', bookings: 312, pct: 100, color: 'from-amber-400 to-yellow-400', rank: 1, rankBg: 'bg-amber-100 text-amber-700' },
              { name: 'V-Sport TP.HCM Q7', revenue: '37.5M', bookings: 241, pct: 78, color: 'from-zinc-400 to-zinc-300', rank: 2, rankBg: 'bg-zinc-200 text-zinc-700' },
              { name: 'V-Sport Bình Dương', revenue: '29.8M', bookings: 189, pct: 62, color: 'from-orange-400 to-orange-300', rank: 3, rankBg: 'bg-orange-100 text-orange-700' },
              { name: 'V-Sport Đồng Nai', revenue: '21.4M', bookings: 145, pct: 44, color: 'from-blue-400 to-blue-300', rank: 4, rankBg: 'bg-zinc-100 text-zinc-500' },
              { name: 'V-Sport Cần Thơ', revenue: '16.9M', bookings: 108, pct: 35, color: 'from-blue-400 to-blue-300', rank: 5, rankBg: 'bg-zinc-100 text-zinc-500' },
            ];
            var container = document.getElementById('topBranchesContainer');
            container.innerHTML = mockBranches.map(function(b) {
              return '<div class="flex items-center gap-3 p-2.5 rounded-xl hover:bg-zinc-50 transition-colors group cursor-pointer">'
                + '<div class="w-7 h-7 rounded-full shrink-0 flex items-center justify-center text-[11px] font-black ' + b.rankBg + '">' + b.rank + '</div>'
                + '<div class="flex-1 min-w-0">'
                +   '<p class="text-xs font-semibold text-zinc-900 truncate">' + b.name + '</p>'
                +   '<div class="flex items-center gap-2 mt-1">'
                +     '<div class="flex-1 h-1.5 bg-zinc-100 rounded-full overflow-hidden">'
                +       '<div class="h-full rounded-full bg-gradient-to-r ' + b.color + '" style="width:' + b.pct + '%"></div>'
                +     '</div>'
                +     '<span class="text-[10px] font-bold text-zinc-500 shrink-0">' + b.revenue + '</span>'
                +   '</div>'
                + '</div>'
                + '<div class="text-right shrink-0"><p class="text-xs font-bold text-zinc-800">' + b.bookings + '</p><p class="text-[10px] text-zinc-400">booking</p></div>'
                + '</div>';
            }).join('');
          })();
          </script>
        </c:if>
      </div>

      <!-- Summary footer -->
      <div class="px-5 py-3 border-t border-zinc-100 bg-zinc-50/50 grid grid-cols-3 gap-3 text-center">
        <div>
          <p class="text-[10px] text-zinc-400">Tổng chi nhánh</p>
          <p class="text-sm font-black text-zinc-900" id="totalBranches">${totalBranches != null ? totalBranches : '5'}</p>
        </div>
        <div class="border-x border-zinc-200">
          <p class="text-[10px] text-zinc-400">Hoạt động</p>
          <p class="text-sm font-black text-green-700" id="activeBranches">${activeBranches != null ? activeBranches : '5'}</p>
        </div>
        <div>
          <p class="text-[10px] text-zinc-400">Tổng doanh thu</p>
          <p class="text-sm font-black text-blue-700" id="totalBranchRevenue">153.8M</p>
        </div>
      </div>
    </div>

    <!-- Booking gần đây (3/5) -->
    <div class="xl:col-span-3 card overflow-hidden">
      <div class="flex items-center justify-between px-5 py-4 border-b border-zinc-100">
        <div>
          <h3 class="text-sm font-bold text-zinc-900 flex items-center gap-2">
            <span class="material-symbols-outlined text-[18px] text-blue-600" style="font-variation-settings:'FILL' 1">receipt_long</span>
            Booking gần đây
          </h3>
          <p class="text-[11px] text-zinc-500 mt-0.5">Cập nhật theo thời gian thực</p>
        </div>
        <div class="flex items-center gap-2">
          <div class="relative">
            <span class="material-symbols-outlined absolute left-2.5 top-1/2 -translate-y-1/2 text-[14px] text-zinc-400">search</span>
            <input id="bookingSearchInput" type="text" placeholder="Tìm kiếm..." oninput="filterRecentBookings()"
              class="h-8 pl-7 pr-3 w-36 rounded-lg border border-zinc-200 bg-white text-xs font-medium text-zinc-700 focus:outline-none focus:ring-2 focus:ring-blue-300 transition-all focus:w-44">
          </div>
          <a href="${pageContext.request.contextPath}/admin/lich-dat-san" class="text-[11px] font-semibold text-blue-700 hover:underline flex items-center gap-0.5">
            Xem tất cả <span class="material-symbols-outlined text-[13px]">arrow_forward</span>
          </a>
        </div>
      </div>

      <!-- Table -->
      <div class="overflow-x-auto">
        <table class="w-full text-xs">
          <thead>
            <tr class="bg-zinc-50 border-b border-zinc-100">
              <th class="px-4 py-3 text-left font-semibold text-zinc-500 uppercase tracking-wider text-[10px]">Mã</th>
              <th class="px-4 py-3 text-left font-semibold text-zinc-500 uppercase tracking-wider text-[10px]">Khách hàng</th>
              <th class="px-4 py-3 text-left font-semibold text-zinc-500 uppercase tracking-wider text-[10px] hidden sm:table-cell">Chi nhánh · Sân</th>
              <th class="px-4 py-3 text-left font-semibold text-zinc-500 uppercase tracking-wider text-[10px] hidden md:table-cell">Giờ</th>
              <th class="px-4 py-3 text-right font-semibold text-zinc-500 uppercase tracking-wider text-[10px]">Giá</th>
              <th class="px-4 py-3 text-left font-semibold text-zinc-500 uppercase tracking-wider text-[10px]">Trạng thái</th>
            </tr>
          </thead>
          <tbody id="recentBookingsTableBody" class="divide-y divide-zinc-50">
            <!-- Rendered below -->
            <c:if test="${empty recentBookings}">
              <tr><td colspan="6" class="px-4 py-8 text-center text-zinc-400">Chưa có dữ liệu booking.</td></tr>
            </c:if>
            <c:forEach items="${recentBookings}" var="bk" varStatus="vs">
              <tr class="trow transition-colors">
                <td class="px-4 py-3">
                  <span class="font-mono font-bold text-zinc-600 text-[11px]">#${bk.datSanId}</span>
                </td>
                <td class="px-4 py-3">
                  <div class="flex items-center gap-2.5">
                    <div class="w-7 h-7 rounded-full bg-gradient-to-br from-blue-100 to-blue-200 flex items-center justify-center text-blue-800 font-bold text-[10px] shrink-0">
                      ${bk.khachHang != null ? bk.khachHang.fullName.substring(0,1).toUpperCase() : 'K'}
                    </div>
                    <div>
                      <p class="font-semibold text-zinc-900">${bk.khachHang != null ? bk.khachHang.fullName : 'Khách vãng lai'}</p>
                      <p class="text-zinc-400 text-[10px]">${bk.khachHang != null ? bk.khachHang.phoneNumber : '-'}</p>
                    </div>
                  </div>
                </td>
                <td class="px-4 py-3 hidden sm:table-cell">
                  <p class="font-medium text-zinc-700">${bk.san != null ? bk.san.tenSan : 'N/A'}</p>
                  <p class="text-zinc-400 text-[10px]">${bk.san != null && bk.san.chiNhanh != null ? bk.san.chiNhanh.tenChiNhanh : 'Không rõ'}</p>
                </td>
                <td class="px-4 py-3 hidden md:table-cell">
                  <p class="font-medium text-zinc-700">${bk.gioBatDau} – ${bk.gioKetThuc}</p>
                  <p class="text-zinc-400 text-[10px]">${bk.ngayDat}</p>
                </td>
                <td class="px-4 py-3 text-right">
                  <p class="font-bold text-zinc-900">
                    <fmt:formatNumber value="${bk.tongTien != null ? bk.tongTien : 0}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                  </p>
                </td>
                <td class="px-4 py-3">
                  <c:choose>
                    <c:when test="${bk.trangThai == 'DaThanhToan' or bk.trangThai == 'Đã thanh toán'}">
                      <span class="badge badge-green">Đã TT</span>
                    </c:when>
                    <c:when test="${bk.trangThai == 'ChoXacNhan' or bk.trangThai == 'Chờ xác nhận'}">
                      <span class="badge badge-amber">Chờ duyệt</span>
                    </c:when>
                    <c:when test="${bk.trangThai == 'DaHuy' or bk.trangThai == 'Đã hủy'}">
                      <span class="badge badge-red">Đã hủy</span>
                    </c:when>
                    <c:otherwise>
                      <span class="badge badge-gray">${bk.trangThai}</span>
                    </c:otherwise>
                  </c:choose>
                </td>
              </tr>
            </c:forEach>
          </tbody>
        </table>
      </div>

      <!-- Mock data fallback & table footer -->
      <div class="px-4 py-3 border-t border-zinc-100 flex items-center justify-between">
        <p class="text-[11px] text-zinc-400" id="bookingTableInfo">Hiển thị 10 booking mới nhất</p>
        <a href="${pageContext.request.contextPath}/admin/lich-dat-san" class="text-[11px] font-semibold text-blue-700 hover:underline flex items-center gap-0.5">
          Xem toàn bộ lịch sử <span class="material-symbols-outlined text-[13px]">open_in_new</span>
        </a>
      </div>
    </div>

  </section>

</main>

<!-- ============================================================ -->
<!-- JAVASCRIPT                                                    -->
<!-- ============================================================ -->
<script>
var _ctxPath = '<%=request.getContextPath()%>';

/* ---- Datetime header ---- */
(function updateDateTime() {
  var days = ['Chủ nhật','Thứ hai','Thứ ba','Thứ tư','Thứ năm','Thứ sáu','Thứ bảy'];
  var now = new Date();
  var pad = function(n) { return String(n).padStart(2,'0'); };
  var str = days[now.getDay()] + ', ' + pad(now.getDate()) + '/' + pad(now.getMonth()+1) + '/' + now.getFullYear()
           + ' · ' + pad(now.getHours()) + ':' + pad(now.getMinutes());
  document.getElementById('currentDateTimeText').textContent = str;
  setTimeout(updateDateTime, 30000);
})();

/* ---- Date range toggle ---- */
function setDateRange(range) {
  var btns = { today: 'rangeToday', week: 'rangeWeek', month: 'rangeMonth' };
  Object.keys(btns).forEach(function(k) {
    var el = document.getElementById(btns[k]);
    if (k === range) {
      el.className = 'px-3 py-1 text-[11px] font-semibold rounded-md bg-white text-zinc-900 shadow-sm';
    } else {
      el.className = 'px-3 py-1 text-[11px] font-medium rounded-md text-zinc-500 hover:bg-white/60';
    }
  });
  // In real app: re-fetch data for selected range
}

/* ---- Format VND ---- */
function fmt(val) {
  if (val >= 1000000) return (val/1000000).toFixed(1).replace('.0','') + 'M';
  if (val >= 1000) return (val/1000).toFixed(0) + 'K';
  return val + '';
}

/* ---- Revenue Chart (Bar) ---- */
var revenueData = {
  2026: [
    { label: 'T1', value: 32500000, color: 'blue' },
    { label: 'T2', value: 28900000, color: 'blue' },
    { label: 'T3', value: 41200000, color: 'blue' },
    { label: 'T4', value: 38700000, color: 'blue' },
    { label: 'T5', value: 52100000, color: 'blue' },
    { label: 'T6', value: 48300000, color: 'green' }, // current month - highlight
    { label: 'T7', value: 0, color: 'zinc' },
    { label: 'T8', value: 0, color: 'zinc' },
    { label: 'T9', value: 0, color: 'zinc' },
    { label: 'T10', value: 0, color: 'zinc' },
    { label: 'T11', value: 0, color: 'zinc' },
    { label: 'T12', value: 0, color: 'zinc' },
  ],
  2025: [
    { label: 'T1', value: 24100000, color: 'blue' },
    { label: 'T2', value: 22300000, color: 'blue' },
    { label: 'T3', value: 31800000, color: 'blue' },
    { label: 'T4', value: 29500000, color: 'blue' },
    { label: 'T5', value: 39200000, color: 'blue' },
    { label: 'T6', value: 41600000, color: 'blue' },
    { label: 'T7', value: 45800000, color: 'blue' },
    { label: 'T8', value: 43100000, color: 'blue' },
    { label: 'T9', value: 38400000, color: 'blue' },
    { label: 'T10', value: 36200000, color: 'blue' },
    { label: 'T11', value: 42500000, color: 'blue' },
    { label: 'T12', value: 51300000, color: 'green' },
  ]
};

function renderRevenueChart() {
  var year = parseInt(document.getElementById('revenueYearSelect').value);
  var data = revenueData[year] || revenueData[2026];
  var values = data.map(function(d) { return d.value; });
  var maxVal = Math.max.apply(null, values.filter(function(v){ return v > 0; })) || 1;
  var total = values.reduce(function(a,b){ return a+b; }, 0);

  document.getElementById('totalRevenueYear').textContent = fmt(total) + 'đ';

  var container = document.getElementById('revenueChartContainer');
  container.innerHTML = data.map(function(d, i) {
    var pct = d.value > 0 ? Math.max(6, Math.round((d.value / maxVal) * 100)) : 4;
    var isMax = d.value === maxVal && d.value > 0;
    var isEmpty = d.value === 0;

    var barColor = isEmpty
      ? 'bg-zinc-100'
      : isMax
        ? 'bg-gradient-to-t from-emerald-600 to-emerald-400'
        : 'bg-gradient-to-t from-blue-500 to-blue-400';

    var labelColor = isMax ? 'text-green-700 font-black' : isEmpty ? 'text-zinc-300' : 'text-zinc-400';

    return '<div class="flex-1 flex flex-col items-center gap-1.5 group tooltip-wrap">'
      + '<span class="text-[10px] font-bold ' + labelColor + ' group-hover:text-zinc-700">' + (d.value > 0 ? fmt(d.value) : '-') + '</span>'
      + '<div class="w-full ' + barColor + ' rounded-t-lg chart-bar cursor-pointer hover:opacity-90 transition-opacity' + (isMax ? ' ring-2 ring-green-200' : '') + '" style="height:' + pct + '%"></div>'
      + '<span class="text-[10px] font-semibold ' + (isMax ? 'text-green-700' : 'text-zinc-500') + '">' + d.label + '</span>'
      + '<div class="tooltip-box">' + d.label + ': ' + (d.value > 0 ? new Intl.NumberFormat('vi-VN').format(d.value) + 'đ' : 'Chưa có') + '</div>'
      + '</div>';
  }).join('');
}

/* ---- Booking by Day chart ---- */
var bookingDayData = [
  { day: 'T2', count: 24, isWeekend: false },
  { day: 'T3', count: 31, isWeekend: false },
  { day: 'T4', count: 19, isWeekend: false },
  { day: 'T5', count: 38, isWeekend: false },
  { day: 'T6', count: 42, isWeekend: false },
  { day: 'T7', count: 67, isWeekend: true },
  { day: 'CN', count: 59, isWeekend: true },
];

function renderBookingDayChart() {
  var maxCount = Math.max.apply(null, bookingDayData.map(function(d){ return d.count; }));
  var total = bookingDayData.reduce(function(a,b){ return a + b.count; }, 0);
  var weekend = bookingDayData.filter(function(d){ return d.isWeekend; }).reduce(function(a,b){ return a+b.count; }, 0);
  var weekday = total - weekend;

  document.getElementById('weekTotalBookings').textContent = total + ' lượt';
  document.getElementById('weekendBookings').textContent = weekend;
  document.getElementById('weekdayBookings').textContent = weekday;
  document.getElementById('avgDailyBookings').textContent = Math.round(total / 7);

  var container = document.getElementById('bookingDayBarsContainer');
  container.innerHTML = bookingDayData.map(function(d) {
    var pct = Math.round((d.count / maxCount) * 100);
    var barColor = d.isWeekend ? 'bg-gradient-to-r from-blue-500 to-blue-400' : 'bg-gradient-to-r from-zinc-300 to-zinc-200';
    var textColor = d.isWeekend ? 'text-blue-700' : 'text-zinc-600';
    return '<div class="flex items-center gap-3">'
      + '<span class="text-[11px] font-bold ' + textColor + ' w-6 shrink-0 text-right">' + d.day + '</span>'
      + '<div class="flex-1 h-5 bg-zinc-100 rounded-full overflow-hidden">'
      +   '<div class="h-full ' + barColor + ' rounded-full flex items-center justify-end pr-2" style="width:' + pct + '%">'
      +     (pct > 25 ? '<span class="text-[9px] font-bold text-white">' + d.count + '</span>' : '')
      +   '</div>'
      + '</div>'
      + (pct <= 25 ? '<span class="text-[10px] font-bold text-zinc-600 w-5 shrink-0">' + d.count + '</span>' : '<span class="w-5 shrink-0"></span>')
      + '</div>';
  }).join('');
}

/* ---- KPI mock population (used when JSP data is absent) ---- */
(function populateKPIs() {
  // Revenue today
  var revenueToday = parseInt('${revenueToday != null ? revenueToday : 0}') || 4820000;
  if (revenueToday === 0) revenueToday = 4820000;
  document.getElementById('kpiRevenueToday').textContent = new Intl.NumberFormat('vi-VN').format(revenueToday) + 'đ';
  document.getElementById('kpiRevenueTrend').textContent = '+12%';
  document.getElementById('kpiRevenueMonth').textContent = '153.8M';

  // Booking today
  var bookingToday = parseInt('${bookingToday != null ? bookingToday : 0}') || 47;
  if (bookingToday === 0) bookingToday = 47;
  document.getElementById('kpiBookingToday').textContent = bookingToday;
  document.getElementById('kpiBookingTrend').textContent = '+8%';
  document.getElementById('kpiBookingPending').textContent = '6';

  // Customers
  var totalCustomers = parseInt('${totalCustomers != null ? totalCustomers : 0}') || 1284;
  if (totalCustomers === 0) totalCustomers = 1284;
  document.getElementById('kpiTotalCustomers').textContent = totalCustomers.toLocaleString('vi-VN');
  document.getElementById('kpiNewCustomers').textContent = '+18';
  document.getElementById('kpiMonthCustomers').textContent = '43';
})();

/* ---- Recent Bookings mock (when no JSP data) ---- */
var mockRecentBookings = [
  { id: 'DS1048', customer: 'Nguyễn Văn An', phone: '0901234567', court: 'Sân Cầu lông A1', branch: 'V-Sport Vũng Tàu', time: '07:00 – 08:00', date: '19/06/2026', price: 120000, status: 'DaThanhToan' },
  { id: 'DS1047', customer: 'Trần Thị Bình', phone: '0912345678', court: 'Sân Bóng đá B2', branch: 'V-Sport TP.HCM Q7', time: '08:30 – 10:30', date: '19/06/2026', price: 450000, status: 'ChoXacNhan' },
  { id: 'DS1046', customer: 'Lê Hoàng Cường', phone: '0923456789', court: 'Pickleball P3', branch: 'V-Sport Bình Dương', time: '09:00 – 10:00', date: '19/06/2026', price: 180000, status: 'DaThanhToan' },
  { id: 'DS1045', customer: 'Phạm Minh Đức', phone: '0934567890', court: 'Tennis T1', branch: 'V-Sport Vũng Tàu', time: '10:00 – 11:30', date: '19/06/2026', price: 250000, status: 'DaThanhToan' },
  { id: 'DS1044', customer: 'Hoàng Thị Liên', phone: '0945678901', court: 'Sân Cầu lông A2', branch: 'V-Sport Đồng Nai', time: '15:00 – 16:00', date: '19/06/2026', price: 120000, status: 'DaHuy' },
  { id: 'DS1043', customer: 'Vũ Quốc Hùng', phone: '0956789012', court: 'Sân Bóng đá B1', branch: 'V-Sport Cần Thơ', time: '17:00 – 19:00', date: '19/06/2026', price: 420000, status: 'ChoXacNhan' },
  { id: 'DS1042', customer: 'Đặng Thị Mai', phone: '0967890123', court: 'Sân Cầu lông A3', branch: 'V-Sport Vũng Tàu', time: '06:00 – 07:00', date: '18/06/2026', price: 120000, status: 'DaThanhToan' },
  { id: 'DS1041', customer: 'Bùi Văn Nam', phone: '0978901234', court: 'Pickleball P1', branch: 'V-Sport TP.HCM Q7', time: '19:00 – 20:30', date: '18/06/2026', price: 270000, status: 'DaThanhToan' },
];

var allMockBookings = mockRecentBookings.slice();

function filterRecentBookings() {
  var query = (document.getElementById('bookingSearchInput').value || '').trim().toLowerCase();
  var filtered = query ? allMockBookings.filter(function(b) {
    return b.id.toLowerCase().includes(query)
      || b.customer.toLowerCase().includes(query)
      || b.court.toLowerCase().includes(query)
      || b.branch.toLowerCase().includes(query);
  }) : allMockBookings;
  renderBookingsTable(filtered);
}

function renderBookingsTable(list) {
  var tbody = document.getElementById('recentBookingsTableBody');
  if (!tbody) return;
  // Only use mock if JSP produced no rows
  var existingRows = tbody.querySelectorAll('tr[data-mock]');
  if (tbody.children.length === 0 || tbody.querySelector('td[colspan]') || existingRows.length > 0) {
    if (list.length === 0) {
      tbody.innerHTML = '<tr><td colspan="6" class="px-4 py-8 text-center text-zinc-400">Không tìm thấy kết quả.</td></tr>';
      return;
    }
    var statusMap = {
      'DaThanhToan': '<span class="badge badge-green">Đã TT</span>',
      'ChoXacNhan': '<span class="badge badge-amber">Chờ duyệt</span>',
      'DaHuy': '<span class="badge badge-red">Đã hủy</span>',
    };
    tbody.innerHTML = list.map(function(b) {
      var initials = b.customer ? b.customer.charAt(0).toUpperCase() : 'K';
      return '<tr class="trow transition-colors" data-mock="1">'
        + '<td class="px-4 py-3"><span class="font-mono font-bold text-zinc-600 text-[11px]">#' + b.id + '</span></td>'
        + '<td class="px-4 py-3"><div class="flex items-center gap-2.5">'
        +   '<div class="w-7 h-7 rounded-full bg-gradient-to-br from-blue-100 to-blue-200 flex items-center justify-center text-blue-800 font-bold text-[10px] shrink-0">' + initials + '</div>'
        +   '<div><p class="font-semibold text-zinc-900 text-xs">' + b.customer + '</p><p class="text-zinc-400 text-[10px]">' + b.phone + '</p></div>'
        + '</div></td>'
        + '<td class="px-4 py-3 hidden sm:table-cell"><p class="font-medium text-zinc-700 text-xs">' + b.court + '</p><p class="text-zinc-400 text-[10px]">' + b.branch + '</p></td>'
        + '<td class="px-4 py-3 hidden md:table-cell"><p class="font-medium text-zinc-700 text-xs">' + b.time + '</p><p class="text-zinc-400 text-[10px]">' + b.date + '</p></td>'
        + '<td class="px-4 py-3 text-right"><p class="font-bold text-zinc-900 text-xs">' + new Intl.NumberFormat('vi-VN').format(b.price) + 'đ</p></td>'
        + '<td class="px-4 py-3">' + (statusMap[b.status] || '<span class="badge badge-gray">' + b.status + '</span>') + '</td>'
        + '</tr>';
    }).join('');
    document.getElementById('bookingTableInfo').textContent = 'Hiển thị ' + list.length + ' booking gần nhất';
  }
}

/* ---- Mobile sidebar ---- */
(function() {
  var btn = document.getElementById('mobileMenuBtn');
  if (btn) {
    btn.addEventListener('click', function() {
      var aside = document.querySelector('aside');
      if (aside) aside.classList.toggle('-translate-x-full');
    });
  }
})();

/* ---- Init ---- */
document.addEventListener('DOMContentLoaded', function() {
  renderRevenueChart();
  renderBookingDayChart();
  // Populate mock bookings if table is empty
  var tbody = document.getElementById('recentBookingsTableBody');
  if (tbody && (tbody.children.length === 0 || tbody.querySelector('td[colspan]'))) {
    renderBookingsTable(allMockBookings);
  }
});
</script>
</body>
</html>
