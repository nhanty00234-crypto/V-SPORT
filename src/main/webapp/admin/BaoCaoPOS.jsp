<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Báo cáo POS — Quản trị</title>
<script src="https://cdn.tailwindcss.com"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
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
  ::-webkit-scrollbar{width:6px;height:6px}::-webkit-scrollbar-track{background:transparent}::-webkit-scrollbar-thumb{background:#d4d4d8;border-radius:6px}
  ::-webkit-scrollbar-thumb:hover{background:#a1a1aa}
  @keyframes fadeUp { from { opacity:0; transform:translateY(10px); } to { opacity:1; transform:translateY(0); } }
  main > section { animation: fadeUp .4s ease both; }
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
      <h1 class="text-sm font-bold text-zinc-900 tracking-tight">Báo cáo POS & Doanh thu</h1>
      <p class="text-xs text-zinc-500 flex items-center gap-1.5"><span class="material-symbols-outlined text-[12px]">analytics</span>Thống kê doanh số bán hàng tại quầy</p>
    </div>
  </div>
  <div class="flex items-center gap-1.5">
    <jsp:include page="/admin/common/profile_dropdown.jsp" />
  </div>
</header>

<!-- Main -->
<main class="lg:ml-[260px] mt-[64px] p-4 lg:p-6 flex flex-col gap-5">

  <!-- HERO -->
  <section class="hero-gradient rounded-2xl border border-zinc-200 overflow-hidden relative">
    <div class="absolute -top-12 -right-12 w-64 h-64 bg-blue-200/20 rounded-full blur-3xl pointer-events-none"></div>
    <div class="relative p-6 flex flex-col md:flex-row md:items-center md:justify-between gap-4">
      <div>
        <p class="text-[10px] font-bold uppercase tracking-widest text-blue-700 mb-1">Báo cáo hoạt động</p>
        <h2 class="text-xl font-black text-zinc-900 tracking-tight">Doanh số POS hôm nay</h2>
        <p class="text-xs text-zinc-500 mt-1">Dữ liệu được cập nhật tự động từ hóa đơn giao dịch tại quầy.</p>
      </div>
      <div class="flex gap-2">
        <button onclick="window.print()" class="h-9 px-4 rounded-lg bg-zinc-900 text-white text-xs font-bold hover:bg-zinc-800 transition-all flex items-center gap-1.5"><span class="material-symbols-outlined text-[15px]">print</span>In báo cáo</button>
      </div>
    </div>
  </section>

  <!-- KPI ROW -->
  <section class="grid grid-cols-2 lg:grid-cols-4 gap-4">
    <div class="card card-hover p-5">
      <div class="w-11 h-11 rounded-xl bg-green-50 flex items-center justify-center mb-3"><span class="material-symbols-outlined text-[20px] text-green-700">payments</span></div>
      <p class="text-xs text-zinc-500 font-medium mb-1">Doanh thu hôm nay</p>
      <p class="text-2xl font-black text-zinc-900 tracking-tight">
        <fmt:formatNumber value="${revenueToday}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
      </p>
      <div class="text-[10px] text-zinc-400 mt-2 font-medium">Hóa đơn đã thanh toán hôm nay</div>
    </div>
    
    <div class="card card-hover p-5">
      <div class="w-11 h-11 rounded-xl bg-blue-50 flex items-center justify-center mb-3"><span class="material-symbols-outlined text-[20px] text-blue-700">receipt_long</span></div>
      <p class="text-xs text-zinc-500 font-medium mb-1">Số lượng hóa đơn</p>
      <p class="text-2xl font-black text-zinc-900 tracking-tight">${ordersToday}</p>
      <div class="text-[10px] text-zinc-400 mt-2 font-medium">Giao dịch thành công hôm nay</div>
    </div>

    <div class="card card-hover p-5">
      <div class="w-11 h-11 rounded-xl bg-purple-50 flex items-center justify-center mb-3"><span class="material-symbols-outlined text-[20px] text-purple-700">calculate</span></div>
      <p class="text-xs text-zinc-500 font-medium mb-1">Giá trị trung bình đơn</p>
      <p class="text-2xl font-black text-zinc-900 tracking-tight">
        <fmt:formatNumber value="${ordersToday > 0 ? (revenueToday / ordersToday) : 0}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
      </p>
      <div class="text-[10px] text-zinc-400 mt-2 font-medium">Giá trị trung bình / giao dịch</div>
    </div>

    <div class="card card-hover p-5">
      <div class="w-11 h-11 rounded-xl bg-amber-50 flex items-center justify-center mb-3"><span class="material-symbols-outlined text-[20px] text-amber-700">credit_card</span></div>
      <p class="text-xs text-zinc-500 font-medium mb-1">Doanh thu chuyển khoản</p>
      <p class="text-2xl font-black text-zinc-900 tracking-tight">
        <fmt:formatNumber value="${bankRev}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
      </p>
      <div class="text-[10px] text-zinc-400 mt-2 font-medium">
        Tiền mặt: <fmt:formatNumber value="${cashRev}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
      </div>
    </div>
  </section>

  <!-- REVENUE BREAKDOWN & BEST SELLERS -->
  <section class="grid grid-cols-1 xl:grid-cols-3 gap-5">
    
    <!-- Revenue Breakdown (Pie/List style) -->
    <div class="card p-5 xl:col-span-1 flex flex-col justify-between">
      <div>
        <h3 class="text-sm font-bold text-zinc-900 mb-4 flex items-center gap-2"><span class="material-symbols-outlined text-[18px] text-blue-700">pie_chart</span>Cơ cấu doanh thu</h3>
        <div class="flex flex-col gap-4 my-6">
          <div class="bg-zinc-50 rounded-xl p-4 border border-zinc-100">
            <div class="flex justify-between items-center mb-1">
              <span class="text-xs font-semibold text-zinc-600 flex items-center gap-1.5"><span class="w-2.5 h-2.5 rounded-full bg-blue-500 inline-block"></span>Tiền Sân</span>
              <span class="text-xs font-bold text-zinc-800"><fmt:formatNumber value="${courtRev}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></span>
            </div>
            <div class="w-full bg-zinc-200 h-1.5 rounded-full overflow-hidden">
              <div class="bg-blue-500 h-full rounded-full" style="width: ${revenueToday > 0 ? (courtRev / revenueToday * 100) : 0}%"></div>
            </div>
          </div>

          <div class="bg-zinc-50 rounded-xl p-4 border border-zinc-100">
            <div class="flex justify-between items-center mb-1">
              <span class="text-xs font-semibold text-zinc-600 flex items-center gap-1.5"><span class="w-2.5 h-2.5 rounded-full bg-purple-500 inline-block"></span>Sản phẩm & Dịch vụ</span>
              <span class="text-xs font-bold text-zinc-800"><fmt:formatNumber value="${serviceRev}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></span>
            </div>
            <div class="w-full bg-zinc-200 h-1.5 rounded-full overflow-hidden">
              <div class="bg-purple-500 h-full rounded-full" style="width: ${revenueToday > 0 ? (serviceRev / revenueToday * 100) : 0}%"></div>
            </div>
          </div>
        </div>
      </div>

      <div class="border-t border-zinc-100 pt-4 text-center">
        <p class="text-xs text-zinc-500">
          Chuyển khoản chiếm <span class="font-bold text-blue-700"><fmt:formatNumber value="${revenueToday > 0 ? (bankRev / revenueToday * 100) : 0}" maxFractionDigits="1"/>%</span> tổng doanh số
        </p>
      </div>
    </div>

    <!-- Best Selling Products -->
    <div class="card p-5 xl:col-span-2">
      <h3 class="text-sm font-bold text-zinc-900 mb-4 flex items-center gap-2"><span class="material-symbols-outlined text-[18px] text-green-700">trending_up</span>Dịch vụ & Sản phẩm bán chạy</h3>
      <div class="overflow-x-auto">
        <table class="w-full text-sm">
          <thead class="bg-zinc-50 border-b border-zinc-200">
            <tr>
              <th class="px-4 py-2.5 text-left font-semibold text-zinc-600 text-xs">Tên mặt hàng</th>
              <th class="px-4 py-2.5 text-center font-semibold text-zinc-600 text-xs w-24">Đơn vị</th>
              <th class="px-4 py-2.5 text-center font-semibold text-zinc-600 text-xs w-24">Đã bán</th>
              <th class="px-4 py-2.5 text-right font-semibold text-zinc-600 text-xs w-36">Doanh thu</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-zinc-100">
            <c:if test="${empty productSales}">
              <tr>
                <td colspan="4" class="px-4 py-8 text-center text-zinc-400 text-xs">Chưa có giao dịch bán lẻ sản phẩm/dịch vụ hôm nay.</td>
              </tr>
            </c:if>
            <c:forEach items="${productSales}" var="ps">
              <tr class="hover:bg-zinc-50/50">
                <td class="px-4 py-3 font-semibold text-zinc-800 text-xs">${ps[0]}</td>
                <td class="px-4 py-3 text-center text-zinc-500 text-xs">${ps[1]}</td>
                <td class="px-4 py-3 text-center text-zinc-900 font-bold text-xs">${ps[2]}</td>
                <td class="px-4 py-3 text-right text-zinc-900 font-bold text-xs">
                  <fmt:formatNumber value="${ps[3]}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                </td>
              </tr>
            </c:forEach>
          </tbody>
        </table>
      </div>
    </div>

  </section>

  <!-- RECENT TRANSACTIONS -->
  <section class="card p-5">
    <h3 class="text-sm font-bold text-zinc-900 mb-4 flex items-center gap-2"><span class="material-symbols-outlined text-[18px] text-zinc-700">history</span>Giao dịch POS gần đây</h3>
    <div class="overflow-x-auto">
      <table class="w-full text-sm">
        <thead class="bg-zinc-50 border-b border-zinc-200">
          <tr>
            <th class="px-4 py-2.5 text-left font-semibold text-zinc-600 text-xs">Mã hóa đơn</th>
            <th class="px-4 py-2.5 text-left font-semibold text-zinc-600 text-xs">Khách hàng</th>
            <th class="px-4 py-2.5 text-left font-semibold text-zinc-600 text-xs">Nhân viên quầy</th>
            <th class="px-4 py-2.5 text-center font-semibold text-zinc-600 text-xs">Phương thức</th>
            <th class="px-4 py-2.5 text-right font-semibold text-zinc-600 text-xs">Tổng tiền</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-zinc-100">
          <c:if test="${empty recentPaidInvoices}">
            <tr>
              <td colspan="5" class="px-4 py-8 text-center text-zinc-400 text-xs">Chưa có hóa đơn POS nào được lập.</td>
            </tr>
          </c:if>
          <c:forEach items="${recentPaidInvoices}" var="hd">
            <tr class="hover:bg-zinc-50/50">
              <td class="px-4 py-3 text-xs font-bold text-blue-700">HD${hd.hoaDonId}</td>
              <td class="px-4 py-3 text-xs text-zinc-700">${hd.khachHang != null ? hd.khachHang.fullName : "Khách vãng lai"}</td>
              <td class="px-4 py-3 text-xs text-zinc-700">${hd.nhanVien != null ? hd.nhanVien.fullName : "Hệ thống"}</td>
              <td class="px-4 py-3 text-center text-xs">
                <span class="badge ${hd.phuongThucThanhToan == 'Tiền mặt' ? 'badge-gray' : 'badge-blue'}">
                  ${hd.phuongThucThanhToan}
                </span>
              </td>
              <td class="px-4 py-3 text-right text-xs font-bold text-zinc-950">
                <fmt:formatNumber value="${hd.tongThanhToan}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
              </td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </div>
  </section>

</main>

<script>
  // Mobile sidebar toggler
  document.getElementById('mobileMenuBtn').addEventListener('click', () => {
    document.getElementById('sidebar').classList.toggle('-translate-x-full');
  });
</script>
</body>
</html>
