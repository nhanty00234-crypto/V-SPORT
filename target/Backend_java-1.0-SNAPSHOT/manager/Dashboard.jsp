<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>${pageTitle}</title>
<script src="https://cdn.tailwindcss.com"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200">
<style>
  body { font-family: 'Inter', sans-serif; }
  .card { background: #fff; border: 1px solid #f3e8ff; border-radius: 16px; transition: box-shadow .2s, transform .2s; }
  .card-hover:hover { box-shadow: 0 8px 24px -8px rgba(139, 92, 246, 0.12); transform: translateY(-2px); }
  .badge { display: inline-flex; align-items: center; padding: 4px 10px; border-radius: 8px; font-size: 11px; font-weight: 600; }
  .badge-green { background: #dcfce7; color: #15803d; }
  .badge-amber { background: #fef3c7; color: #b45309; }
  .badge-red { background: #fee2e2; color: #b91c1c; }
  .badge-blue { background: #dbeafe; color: #1e40af; }
  .badge-purple { background: #f3e8ff; color: #7e22ce; }
  .badge-gray { background: #f4f4f5; color: #52525b; }
  ::-webkit-scrollbar { width: 6px; height: 6px }
  ::-webkit-scrollbar-track { background: transparent }
  ::-webkit-scrollbar-thumb { background: #ddd6fe; border-radius: 6px }
  ::-webkit-scrollbar-thumb:hover { background: #c084fc; }
  @keyframes fadeUp { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
  @keyframes pop { 0% { opacity: 0; transform: scale(.94); } 100% { opacity: 1; transform: scale(1); } }
  @keyframes pulse-dot { 0%, 100% { box-shadow: 0 0 0 0 rgba(168, 85, 247, 0.4); } 50% { box-shadow: 0 0 0 6px rgba(168, 85, 247, 0); } }
  @keyframes drawBar { from { transform: scaleY(0); } to { transform: scaleY(1); } }
  main > section { animation: fadeUp .4s ease both; }
  main > section:nth-child(1) { animation-delay: 0ms; }
  main > section:nth-child(2) { animation-delay: 80ms; }
  main > section:nth-child(3) { animation-delay: 160ms; }
  main > section:nth-child(4) { animation-delay: 240ms; }
  .stagger > *:nth-child(1) { animation: pop .35s ease both; animation-delay: 50ms }
  .stagger > *:nth-child(2) { animation: pop .35s ease both; animation-delay: 120ms }
  .stagger > *:nth-child(3) { animation: pop .35s ease both; animation-delay: 190ms }
  .stagger > *:nth-child(4) { animation: pop .35s ease both; animation-delay: 260ms }
  button { transition: transform .12s ease, opacity .15s ease, background-color .15s ease; }
  button:active:not([disabled]) { transform: scale(.97); }
  .live-dot { animation: pulse-dot 1.6s ease-in-out infinite; }
  .chart-bar { transform-origin: bottom; animation: drawBar .6s cubic-bezier(.34, 1.56, .64, 1) both; }
  .hero-gradient { background: linear-gradient(135deg, #faf5ff 0%, #f3e8ff 60%, #e0e7ff 100%); }
  
  @keyframes contentZoomIn {
    from {
      opacity: 0;
      transform: scale(0.98);
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
  @media (prefers-reduced-motion: reduce) { *,*::before,*::after { animation: none!important; transition: none!important; } }
</style>
</head>
<body class="bg-zinc-50 text-zinc-900 min-h-screen">

<!-- Sidebar Manager -->
<jsp:include page="/manager/common/sidebar.jsp" />

<!-- Header -->
<header class="h-[64px] fixed top-0 right-0 left-0 lg:left-[248px] bg-white/80 backdrop-blur-lg border-b border-purple-100 z-20 flex items-center justify-between px-4 lg:px-6">
  <div class="flex items-center gap-3">
    <button id="mobileMenuBtn" class="lg:hidden p-2 rounded-lg hover:bg-purple-50 text-purple-600"><span class="material-symbols-outlined text-[20px]">menu</span></button>
    <div>
      <h1 class="text-sm font-bold text-purple-950 tracking-tight">Tổng quan Vận hành</h1>
      <p class="text-xs text-purple-550 flex items-center gap-1.5"><span class="material-symbols-outlined text-[12px]">schedule</span>Chi nhánh cơ sở CS${sessionScope.user.coSoId}</p>
    </div>
  </div>
  <div class="flex items-center gap-1.5">
    <button class="relative p-2 rounded-lg hover:bg-purple-50 text-purple-650">
      <span class="material-symbols-outlined text-[20px]">notifications</span>
      <span class="absolute top-1.5 right-1.5 w-2 h-2 rounded-full bg-purple-650 live-dot"></span>
    </button>
    <div class="w-px h-6 bg-purple-100 mx-1"></div>
    <jsp:include page="/manager/common/profile_dropdown.jsp" />
  </div>
</header>

<!-- Main Content -->
<main class="lg:ml-[248px] mt-[64px] p-4 lg:p-6 flex flex-col gap-5">

  <!-- Welcome banner -->
  <section class="hero-gradient rounded-2xl border border-purple-150 overflow-hidden relative">
    <div class="absolute -top-12 -right-12 w-64 h-64 bg-purple-300/20 rounded-full blur-3xl pointer-events-none"></div>
    <div class="absolute -bottom-12 -left-12 w-48 h-48 bg-indigo-300/10 rounded-full blur-3xl pointer-events-none"></div>
    <div class="relative p-6 flex flex-col md:flex-row md:items-center md:justify-between gap-4">
      <div class="flex items-center gap-4">
        <img src="https://ui-avatars.com/api/?name=${sessionScope.user.fullName != null ? sessionScope.user.fullName : sessionScope.user.username}&background=7c3aed&color=fff&bold=true" class="w-14 h-14 rounded-2xl object-cover shadow-md ring-4 ring-white" alt="Avatar">
        <div>
          <p class="text-[10px] font-bold uppercase tracking-widest text-purple-700 mb-1">CỔNG THÔNG TIN QUẢN LÝ</p>
          <h2 class="text-xl font-black text-purple-950 tracking-tight">Chào mừng trở lại, ${sessionScope.user.fullName != null ? sessionScope.user.fullName : sessionScope.user.username}!</h2>
          <div class="flex items-center gap-3 mt-1.5 text-xs text-purple-600 flex-wrap">
            <span class="flex items-center gap-1"><span class="material-symbols-outlined text-[13px] text-purple-650">storefront</span>Cơ sở CS${sessionScope.user.coSoId}</span>
            <span class="text-purple-200">·</span>
            <span class="flex items-center gap-1 text-purple-700 font-semibold"><span class="w-1.5 h-1.5 rounded-full bg-purple-500 inline-block live-dot"></span>Hệ thống sẵn sàng</span>
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- KPI row -->
  <section class="grid grid-cols-2 lg:grid-cols-4 gap-4 stagger">
    <div class="card card-hover p-5">
      <div class="flex items-start justify-between mb-3">
        <div class="w-11 h-11 rounded-xl bg-purple-50 flex items-center justify-center"><span class="material-symbols-outlined text-[20px] text-purple-700" style="font-variation-settings:'FILL' 1">event</span></div>
        <span class="flex items-center gap-0.5 text-[11px] font-bold text-green-600 bg-green-50 px-2 py-0.5 rounded-md"><span class="material-symbols-outlined text-[12px]">trending_up</span>Hôm nay</span>
      </div>
      <p class="text-xs text-zinc-500 font-medium mb-1">Lịch đặt hôm nay</p>
      <p class="text-3xl font-black text-purple-950 tracking-tight">${dashboardData.bookingsTodayCount}</p>
      <div class="flex items-center justify-between mt-3 pt-3 border-t border-purple-50">
        <p class="text-[11px] text-zinc-500">Chi nhánh CS${sessionScope.user.coSoId}</p>
        <svg width="50" height="20" viewBox="0 0 50 20" class="text-purple-500"><polyline fill="none" stroke="currentColor" stroke-width="1.5" points="0,15 8,12 16,14 24,8 32,10 40,5 50,8"/><polyline fill="rgba(139,92,246,.1)" stroke="none" points="0,15 8,12 16,14 24,8 32,10 40,5 50,8 50,20 0,20"/></svg>
      </div>
    </div>
    <div class="card card-hover p-5">
      <div class="flex items-start justify-between mb-3">
        <div class="w-11 h-11 rounded-xl bg-indigo-50 flex items-center justify-center"><span class="material-symbols-outlined text-[20px] text-indigo-700" style="font-variation-settings:'FILL' 1">payments</span></div>
        <span class="flex items-center gap-0.5 text-[11px] font-bold text-green-600 bg-green-50 px-2 py-0.5 rounded-md"><span class="material-symbols-outlined text-[12px]">trending_up</span>Đã thu</span>
      </div>
      <p class="text-xs text-zinc-500 font-medium mb-1">Doanh thu hôm nay</p>
      <p class="text-3xl font-black text-purple-950 tracking-tight">
        <fmt:formatNumber value="${dashboardData.revenueToday}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
      </p>
      <div class="flex items-center justify-between mt-3 pt-3 border-t border-purple-50">
        <p class="text-[11px] text-zinc-500">Tổng doanh thu cơ sở</p>
        <p class="text-[11px] font-bold text-zinc-700"><fmt:formatNumber value="${dashboardData.totalRevenue}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></p>
      </div>
    </div>
    <div class="card card-hover p-5">
      <div class="flex items-start justify-between mb-3">
        <div class="w-11 h-11 rounded-xl bg-fuchsia-50 flex items-center justify-center"><span class="material-symbols-outlined text-[20px] text-fuchsia-700" style="font-variation-settings:'FILL' 1">stadium</span></div>
        <span class="badge badge-purple">Khả dụng</span>
      </div>
      <p class="text-xs text-zinc-500 font-medium mb-1">Sân hoạt động</p>
      <p class="text-3xl font-black text-purple-950 tracking-tight">${dashboardData.activeFields}<span class="text-lg text-zinc-400">/${dashboardData.totalFields}</span></p>
      <div class="flex items-center justify-between mt-3 pt-3 border-t border-purple-50">
        <p class="text-[11px] text-zinc-500">Tình trạng sẵn sàng</p>
        <div class="flex gap-0.5"><span class="w-1 h-3 rounded-sm bg-purple-400"></span><span class="w-1 h-3 rounded-sm bg-purple-400"></span><span class="w-1 h-3 rounded-sm bg-purple-400"></span><span class="w-1 h-3 rounded-sm bg-purple-400"></span></div>
      </div>
    </div>
    <div class="card card-hover p-5">
      <div class="flex items-start justify-between mb-3">
        <div class="w-11 h-11 rounded-xl bg-violet-50 flex items-center justify-center"><span class="material-symbols-outlined text-[20px] text-violet-700" style="font-variation-settings:'FILL' 1">groups</span></div>
        <span class="badge badge-purple">Nhân sự</span>
      </div>
      <p class="text-xs text-zinc-500 font-medium mb-1">Nhân sự cơ sở</p>
      <p class="text-3xl font-black text-purple-950 tracking-tight">${dashboardData.totalStaff}</p>
      <div class="flex items-center justify-between mt-3 pt-3 border-t border-purple-50">
        <p class="text-[11px] text-zinc-500">Hoạt động tại CS${sessionScope.user.coSoId}</p>
        <span class="w-2.5 h-2.5 rounded-full bg-green-500 inline-block live-dot"></span>
      </div>
    </div>
  </section>

  <!-- Main Grid Layout -->
  <section class="grid grid-cols-1 xl:grid-cols-3 gap-5">
    
    <!-- LEFT 2/3 COLUMN -->
    <div class="xl:col-span-2 flex flex-col gap-5">
      
      <!-- Today Bookings List -->
      <div class="card overflow-hidden">
        <div class="flex items-center justify-between px-5 py-4 border-b border-purple-50">
          <div>
            <h3 class="text-sm font-bold text-purple-950 flex items-center gap-2"><span class="material-symbols-outlined text-[18px] text-purple-700">event_available</span>Lịch đặt sân hôm nay</h3>
            <p class="text-[11px] text-purple-500 mt-0.5">Danh sách lịch hoạt động trong ngày của chi nhánh</p>
          </div>
          <a href="${pageContext.request.contextPath}/manager/quan-ly-san" class="text-[11px] font-semibold text-purple-700 hover:underline">Chi tiết sân →</a>
        </div>
        <div class="divide-y divide-purple-50">
          <c:if test="${empty dashboardData.todayBookingsList}">
            <div class="p-6 text-center text-zinc-400 text-sm">Chưa có lượt đặt sân nào được đăng ký hôm nay.</div>
          </c:if>
          <c:forEach items="${dashboardData.todayBookingsList}" var="lich">
            <div class="flex items-center gap-3 px-5 py-3.5 hover:bg-purple-50/20 transition-colors">
              <div class="w-10 h-10 rounded-full bg-purple-50 text-purple-750 flex items-center justify-center font-bold text-sm shrink-0">
                ${lich.account != null ? lich.account.username.substring(0,1).toUpperCase() : "K"}
              </div>
              <div class="flex-1 min-w-0">
                <div class="flex items-center gap-2">
                  <p class="text-sm font-semibold text-zinc-800 truncate">
                    ${lich.account != null ? (lich.account.fullName != null && lich.account.fullName.length() > 0 ? lich.account.fullName : lich.account.username) : "Khách vãng lai"}
                  </p>
                  <span class="badge badge-purple">${lich.nguonDatSan}</span>
                </div>
                <div class="flex items-center gap-2 text-[11px] text-zinc-500 mt-0.5">
                  <span class="flex items-center gap-0.5 text-purple-700 font-medium">
                    <span class="material-symbols-outlined text-[12px]">stadium</span>
                    ${lich.san != null ? lich.san.tenSan : "Sân thi đấu"}
                  </span>
                  <span>·</span>
                  <span class="flex items-center gap-0.5">
                    <span class="material-symbols-outlined text-[12px]">schedule</span>
                    ${lich.gioBatDau} – ${lich.gioKetThuc}
                  </span>
                </div>
              </div>
              <div class="text-right shrink-0">
                <p class="text-sm font-bold text-zinc-900">
                  <fmt:formatNumber value="${lich.tongTienDuKien}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                </p>
                <span class="badge <c:choose><c:when test="${lich.trangThai == 'Đã thanh toán' || lich.trangThai == 'Success'}">badge-green</c:when><c:when test="${lich.trangThai == 'Chờ thanh toán' || lich.trangThai == 'Pending'}">badge-amber</c:when><c:otherwise>badge-red</c:otherwise></c:choose> mt-1">
                  ${lich.trangThai}
                </span>
              </div>
            </div>
          </c:forEach>
        </div>
      </div>

      <!-- Weekly Revenue Chart Block -->
      <div class="card p-5">
        <div class="flex items-start justify-between mb-5 flex-wrap gap-3">
          <div>
            <h3 class="text-sm font-bold text-purple-950 flex items-center gap-2"><span class="material-symbols-outlined text-[18px] text-purple-700">bar_chart</span>Doanh thu 5 tuần gần nhất</h3>
            <p class="text-[11px] text-purple-500 mt-0.5">Thống kê doanh thu theo các tuần trong tháng của cơ sở</p>
          </div>
          <div class="flex items-center gap-1 bg-purple-50 rounded-lg p-1">
            <button class="px-3 py-1 text-[11px] font-semibold rounded-md bg-white text-purple-900 shadow-sm">Theo Tuần</button>
          </div>
        </div>
        <div class="flex items-end justify-between gap-4 h-48 px-2">
          <div class="flex-1 flex flex-col items-center gap-1.5 group">
            <span class="text-[10px] font-bold text-zinc-400 group-hover:text-purple-700">1.2M</span>
            <div class="w-full bg-gradient-to-t from-purple-400 to-indigo-300 rounded-t-md chart-bar cursor-pointer" style="height:45%"></div>
            <span class="text-[10px] font-semibold text-zinc-500">Tuần 1</span>
          </div>
          <div class="flex-1 flex flex-col items-center gap-1.5 group">
            <span class="text-[10px] font-bold text-zinc-400 group-hover:text-purple-700">1.9M</span>
            <div class="w-full bg-gradient-to-t from-purple-400 to-indigo-300 rounded-t-md chart-bar cursor-pointer" style="height:70%"></div>
            <span class="text-[10px] font-semibold text-zinc-500">Tuần 2</span>
          </div>
          <div class="flex-1 flex flex-col items-center gap-1.5 group">
            <span class="text-[10px] font-bold text-zinc-400 group-hover:text-purple-700">2.2M</span>
            <div class="w-full bg-gradient-to-t from-purple-400 to-indigo-300 rounded-t-md chart-bar cursor-pointer" style="height:80%"></div>
            <span class="text-[10px] font-semibold text-zinc-500">Tuần 3</span>
          </div>
          <div class="flex-1 flex flex-col items-center gap-1.5 group">
            <span class="text-[10px] font-bold text-zinc-400 group-hover:text-purple-700">2.4M</span>
            <div class="w-full bg-gradient-to-t from-purple-400 to-indigo-300 rounded-t-md chart-bar cursor-pointer" style="height:88%"></div>
            <span class="text-[10px] font-semibold text-zinc-500">Tuần 4</span>
          </div>
          <div class="flex-1 flex flex-col items-center gap-1.5 group">
            <span class="text-[10px] font-bold text-purple-900">2.6M</span>
            <div class="w-full bg-gradient-to-t from-purple-650 to-indigo-600 rounded-t-md chart-bar cursor-pointer ring-2 ring-purple-200" style="height:95%"></div>
            <span class="text-[10px] font-bold text-purple-700">Tuần 5</span>
          </div>
        </div>
        <div class="flex items-center gap-4 mt-4 pt-4 border-t border-purple-50 text-[11px] text-zinc-500 flex-wrap">
          <span class="flex items-center gap-1.5"><span class="w-3 h-3 rounded-sm bg-purple-450"></span>Doanh thu đạt chuẩn</span>
          <span class="flex items-center gap-1.5"><span class="w-3 h-3 rounded-sm bg-purple-650"></span>Tuần cao điểm hiện tại</span>
        </div>
      </div>

    </div>

    <!-- RIGHT 1/3 COLUMN -->
    <div class="flex flex-col gap-5">
      
      <!-- Recent Invoices List -->
      <div class="card overflow-hidden">
        <div class="flex items-center justify-between px-5 py-4 border-b border-purple-50">
          <h3 class="text-sm font-bold text-purple-950 flex items-center gap-2"><span class="material-symbols-outlined text-[18px] text-purple-700">receipt_long</span>Hóa đơn gần đây</h3>
          <span class="badge badge-purple">Mới nhất</span>
        </div>
        <div class="divide-y divide-purple-50">
          <c:if test="${empty dashboardData.recentInvoices}">
            <div class="p-6 text-center text-zinc-400 text-sm">Chưa lập hóa đơn nào gần đây.</div>
          </c:if>
          <c:forEach items="${dashboardData.recentInvoices}" var="hd">
            <div class="p-4 hover:bg-purple-50/20 transition-colors flex items-center justify-between gap-3">
              <div>
                <p class="text-xs font-bold text-zinc-800">Mã hóa đơn: HD${hd.hoaDonId}</p>
                <p class="text-[10px] text-zinc-500 mt-0.5">
                  <fmt:formatDate value="${hd.ngayLap}" pattern="dd/MM/yyyy HH:mm"/>
                </p>
                <p class="text-[10px] text-purple-600 font-semibold mt-1">
                  ${hd.khachHang != null ? hd.khachHang.fullName : "Khách vãng lai"}
                </p>
              </div>
              <div class="text-right">
                <p class="text-xs font-bold text-zinc-900">
                  <fmt:formatNumber value="${hd.tongThanhToan}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                </p>
                <span class="badge <c:choose><c:when test="${hd.trangThaiThanhToan == 'Đã thanh toán'}">badge-green</c:when><c:when test="${hd.trangThaiThanhToan == 'Chờ thanh toán'}">badge-amber</c:when><c:otherwise>badge-red</c:otherwise></c:choose> mt-1">
                  ${hd.trangThaiThanhToan}
                </span>
              </div>
            </div>
          </c:forEach>
        </div>
      </div>

      <!-- Quick Warnings & Requests alerts -->
      <div class="card overflow-hidden">
        <div class="px-5 py-4 border-b border-purple-50 flex items-center justify-between">
          <h3 class="text-sm font-bold text-purple-950 flex items-center gap-2"><span class="material-symbols-outlined text-[18px] text-purple-700">warning</span>Cảnh báo & Nhắc việc</h3>
        </div>
        <div class="p-4 flex flex-col gap-3">
          <!-- Pending Leave Requests Alert -->
          <div class="flex items-start gap-3 p-3 rounded-lg bg-amber-50 border border-amber-200/50">
            <span class="material-symbols-outlined text-[18px] text-amber-600 shrink-0 mt-0.5">date_range</span>
            <div class="flex-1 min-w-0">
              <p class="text-xs font-semibold text-zinc-900">Có yêu cầu nghỉ phép đang chờ duyệt</p>
              <p class="text-[10px] text-zinc-500 mt-0.5">Nhân viên gửi yêu cầu xin nghỉ phép phép.</p>
              <a href="${pageContext.request.contextPath}/manager/yeu-cau-nghi" class="text-[10px] text-amber-700 font-bold hover:underline mt-1 inline-block">Duyệt yêu cầu →</a>
            </div>
          </div>
          <!-- Low Inventory alert -->
          <div class="flex items-start gap-3 p-3 rounded-lg bg-purple-50 border border-purple-200/50">
            <span class="material-symbols-outlined text-[18px] text-purple-700 shrink-0 mt-0.5">inventory</span>
            <div class="flex-1 min-w-0">
              <p class="text-xs font-semibold text-zinc-900">Nhắc nhở ca làm việc</p>
              <p class="text-[10px] text-zinc-500 mt-0.5">Kiểm tra lịch phân ca cho tuần tiếp theo.</p>
              <a href="${pageContext.request.contextPath}/manager/ca-lam" class="text-[10px] text-purple-700 font-bold hover:underline mt-1 inline-block">Xem ca làm →</a>
            </div>
          </div>
        </div>
      </div>

    </div>

  </section>

</main>

<script>
  // Mobile menu toggle
  document.getElementById('mobileMenuBtn').addEventListener('click', () => {
    document.getElementById('sidebar').classList.toggle('-translate-x-full');
  });
</script>
</body>
</html>
