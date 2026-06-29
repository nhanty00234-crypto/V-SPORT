<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Hóa đơn — Cơ Sở</title>
<script src="https://cdn.tailwindcss.com"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
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
  @keyframes fadeUp { from { opacity:0; transform:translateY(12px); } to { opacity:1; transform:translateY(0); } }
  @keyframes scaleIn { from { opacity: 0; transform: scale(0.96); } to { opacity: 1; transform: scale(1); } }
  @keyframes pulse-dot { 0%,100%{box-shadow:0 0 0 0 rgba(34,197,94,.4);} 50%{box-shadow:0 0 0 6px rgba(34,197,94,0);} }
  
  .animate-fade-up { animation: fadeUp 0.4s cubic-bezier(0.16, 1, 0.3, 1) both; }
  .animate-scale-in { animation: scaleIn 0.3s cubic-bezier(0.34, 1.56, 0.64, 1) both; }
  
  .delay-1 { animation-delay: 0ms; }
  .delay-2 { animation-delay: 60ms; }
  .delay-3 { animation-delay: 120ms; }
  .delay-4 { animation-delay: 180ms; }
  .delay-5 { animation-delay: 240ms; }
  
  button { transition: transform .12s ease, opacity .15s ease, background-color .15s ease; }
  button:active:not([disabled]) { transform: scale(.97); }
  .live-dot { animation: pulse-dot 1.6s ease-in-out infinite; }
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
</head>
<body class="bg-zinc-50 text-zinc-900 min-h-screen">

<!-- Sidebar -->
<jsp:include page="/admin/common/sidebar.jsp" />

<!-- Header -->
<header class="h-[64px] fixed top-0 right-0 left-0 lg:left-[248px] bg-white/80 backdrop-blur-lg border-b border-zinc-200 z-20 flex items-center justify-between px-4 lg:px-6">
  <div class="flex items-center gap-3">
    <button id="mobileMenuBtn" class="lg:hidden p-2 rounded-lg hover:bg-zinc-100 text-zinc-500"><span class="material-symbols-outlined text-[20px]">menu</span></button>
    <div>
      <h1 class="text-sm font-bold text-zinc-900 tracking-tight">Hóa đơn & Hoàn tiền</h1>
      <p class="text-xs text-zinc-500 flex items-center gap-1.5"><span class="material-symbols-outlined text-[12px]">database</span>Bảng HoaDon · ChiTietHoaDon · HoanTien</p>
    </div>
  </div>
  <div class="flex items-center gap-1.5">
    <button onclick="location.href='HoTro.html'" class="hidden sm:flex items-center gap-1.5 h-9 px-3 rounded-lg border border-zinc-200 hover:bg-zinc-50 text-zinc-650 text-xs font-medium">
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

  <!-- Stats -->
  <div class="grid grid-cols-2 sm:grid-cols-4 gap-3">
    <div class="card p-4 animate-fade-up delay-1">
      <p class="text-xs text-zinc-500 mb-1">Doanh thu hôm nay</p>
      <p id="statRevenueToday" class="text-xl font-bold text-zinc-900">0 đ</p>
      <p class="text-xs text-green-600 mt-1 flex items-center gap-0.5"><span class="material-symbols-outlined text-[12px]">trending_up</span>+12% so với hôm qua</p>
    </div>
    <div class="card p-4 animate-fade-up delay-2">
      <p class="text-xs text-zinc-500 mb-1">Hóa đơn hôm nay</p>
      <p id="statInvoicesToday" class="text-xl font-bold text-zinc-900">0</p>
      <p id="statInvoicesTotal" class="text-xs text-zinc-400 mt-1">Tổng tháng: 0</p>
    </div>
    <div class="card p-4 animate-fade-up delay-3">
      <p class="text-xs text-zinc-500 mb-1">Chờ thanh toán</p>
      <p id="statPendingPayments" class="text-xl font-bold text-amber-600">0</p>
      <p id="statPendingPaymentsAmount" class="text-xs text-zinc-400 mt-1">Tổng: 0 đ</p>
    </div>
    <div class="card p-4 animate-fade-up delay-4">
      <p class="text-xs text-zinc-500 mb-1">Yêu cầu hoàn tiền</p>
      <p id="statPendingRefunds" class="text-xl font-bold text-red-500">0</p>
      <p class="text-xs text-zinc-400 mt-1">Chờ duyệt</p>
    </div>
  </div>

  <!-- Tabs -->
  <div class="flex items-center gap-1 border-b border-zinc-200">
    <button id="tabInvoice" onclick="switchTab('invoice')" class="px-4 py-2.5 text-sm font-semibold text-zinc-900 border-b-2 border-zinc-900 -mb-px flex items-center gap-1.5">
      <span class="material-symbols-outlined text-[16px]">receipt_long</span>Hóa đơn <span id="tabInvoiceCount" class="text-xs bg-zinc-100 px-1.5 py-0.5 rounded font-medium text-zinc-600">0</span>
    </button>
    <button id="tabRefund" onclick="switchTab('refund')" class="px-4 py-2.5 text-sm font-medium text-zinc-500 hover:text-zinc-700 flex items-center gap-1.5">
      <span class="material-symbols-outlined text-[16px]">currency_exchange</span>Hoàn tiền <span id="tabRefundCount" class="text-xs bg-red-100 px-1.5 py-0.5 rounded font-medium text-red-600">0</span>
    </button>
  </div>

  <!-- Invoice Panel -->
  <div id="panelInvoice">
    <!-- Filters -->
    <div class="flex flex-col sm:flex-row items-start sm:items-center gap-3 mb-4">
      <div class="relative flex-1 max-w-xs">
        <span class="absolute left-3 top-1/2 -translate-y-1/2 material-symbols-outlined text-[16px] text-zinc-400">search</span>
        <input id="filterSearch" type="text" placeholder="Mã hóa đơn, tên khách..." class="h-9 w-full pl-8 pr-3 rounded-lg border border-zinc-200 bg-white text-sm focus:outline-none focus:ring-2 focus:ring-zinc-400">
      </div>
      <input id="filterDate" type="date" class="h-9 px-3 rounded-lg border border-zinc-200 bg-white text-sm focus:outline-none focus:ring-2 focus:ring-zinc-400">
      <select id="filterType" class="h-9 px-3 rounded-lg border border-zinc-200 bg-white text-sm text-zinc-700 focus:outline-none focus:ring-2 focus:ring-zinc-400">
        <option value="all">Tất cả loại</option>
        <option value="sân">Đặt sân</option>
        <option value="dịch vụ">Dịch vụ</option>
      </select>
      <select id="filterStatus" class="h-9 px-3 rounded-lg border border-zinc-200 bg-white text-sm text-zinc-700 focus:outline-none focus:ring-2 focus:ring-zinc-400">
        <option value="all">Tất cả trạng thái</option>
        <option value="Đã thanh toán">Đã thanh toán</option>
        <option value="Chờ thanh toán">Chờ thanh toán</option>
        <option value="Đã hủy">Đã hủy</option>
      </select>
    </div>
    <div class="card overflow-hidden animate-fade-up delay-5">
      <table class="w-full text-sm">
        <thead class="bg-zinc-50 border-b border-zinc-200">
          <tr>
            <th class="px-4 py-3 text-left font-semibold text-zinc-600 text-xs">Mã HĐ</th>
            <th class="px-4 py-3 text-left font-semibold text-zinc-600 text-xs">Khách hàng</th>
            <th class="px-4 py-3 text-left font-semibold text-zinc-600 text-xs hidden sm:table-cell">Loại</th>
            <th class="px-4 py-3 text-left font-semibold text-zinc-600 text-xs hidden md:table-cell">Thời gian</th>
            <th class="px-4 py-3 text-right font-semibold text-zinc-600 text-xs">Tổng tiền</th>
            <th class="px-4 py-3 text-left font-semibold text-zinc-600 text-xs hidden lg:table-cell">Thanh toán</th>
            <th class="px-4 py-3 text-left font-semibold text-zinc-600 text-xs">Trạng thái</th>
            <th class="px-4 py-3 text-right font-semibold text-zinc-600 text-xs">Thao tác</th>
          </tr>
        </thead>
        <tbody id="invoiceTableBody" class="divide-y divide-zinc-100">
          <!-- Dynamic Invoices Rows -->
        </tbody>
      </table>
      <div class="px-4 py-3 border-t border-zinc-100 flex items-center justify-between text-xs text-zinc-500">
        <span>Hiển thị kết quả tìm kiếm theo thời gian thực</span>
        <div class="flex items-center gap-1">
          <button class="px-2 py-1 rounded hover:bg-zinc-100 disabled:opacity-40" disabled><span class="material-symbols-outlined text-[14px]">chevron_left</span></button>
          <button class="px-2.5 py-1 rounded bg-zinc-900 text-white font-medium">1</button>
          <button class="px-2.5 py-1 rounded hover:bg-zinc-100">2</button>
          <button class="px-2.5 py-1 rounded hover:bg-zinc-100">3</button>
          <button class="px-2 py-1 rounded hover:bg-zinc-100"><span class="material-symbols-outlined text-[14px]">chevron_right</span></button>
        </div>
      </div>
    </div>
  </div>

  <!-- Refund Panel -->
  <div id="panelRefund" class="hidden">
    <div class="card overflow-hidden animate-fade-up delay-5">
      <div class="px-4 py-3 bg-red-50 border-b border-red-100 flex items-center gap-2 text-sm text-red-700">
        <span class="material-symbols-outlined text-[16px]">info</span>
        <span>Các yêu cầu hoàn tiền dưới đây cần được xét duyệt. <span class="font-semibold">Bảng HoanTien</span></span>
      </div>
      <table class="w-full text-sm">
        <thead class="bg-zinc-50 border-b border-zinc-200">
          <tr>
            <th class="px-4 py-3 text-left font-semibold text-zinc-600 text-xs">Mã yêu cầu</th>
            <th class="px-4 py-3 text-left font-semibold text-zinc-600 text-xs">Khách hàng</th>
            <th class="px-4 py-3 text-left font-semibold text-zinc-600 text-xs hidden sm:table-cell">Mã HĐ gốc</th>
            <th class="px-4 py-3 text-left font-semibold text-zinc-600 text-xs hidden md:table-cell">Lý do</th>
            <th class="px-4 py-3 text-right font-semibold text-zinc-600 text-xs">Số tiền</th>
            <th class="px-4 py-3 text-left font-semibold text-zinc-600 text-xs">Trạng thái</th>
            <th class="px-4 py-3 text-right font-semibold text-zinc-600 text-xs">Thao tác</th>
          </tr>
        </thead>
        <tbody id="refundTableBody" class="divide-y divide-zinc-100">
          <!-- Dynamic Refunds Rows -->
        </tbody>
      </table>
    </div>
  </div>

</main>

<!-- SUCCESS TOAST NOTIFICATION -->
<div id="successToast" class="fixed bottom-6 right-6 bg-zinc-900 text-white rounded-2xl p-4 shadow-2xl border border-zinc-800 z-[9999] flex items-start gap-3 transition-all duration-300 translate-y-12 opacity-0 pointer-events-none w-80">
  <div class="w-8 h-8 rounded-full bg-emerald-500/20 text-emerald-400 flex items-center justify-center shrink-0">
    <span class="material-symbols-outlined text-[18px]">check</span>
  </div>
  <div class="flex-1">
    <p id="toastTitle" class="text-xs font-semibold text-white">Thành công</p>
    <p id="toastMessage" class="text-[11px] text-zinc-400 mt-0.5">Thao tác đã được thực hiện.</p>
  </div>
</div>

<!-- Invoice Detail Modal -->
<div id="invoiceDetailModal" class="hidden fixed inset-0 z-[80] flex items-center justify-center p-4">
  <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" onclick="closeInvoiceDetail()"></div>
  <div class="relative bg-white rounded-2xl shadow-2xl w-full max-w-[540px] max-h-[90vh] overflow-y-auto z-10 border border-zinc-200 animate-scale-in">
    <div class="flex items-center justify-between px-6 py-4 border-b border-zinc-150">
      <div>
        <h2 class="text-base font-bold text-zinc-900">Chi tiết hóa đơn</h2>
        <p class="text-xs text-zinc-400" id="detailInvoiceCode">-</p>
      </div>
      <div class="flex items-center gap-2">
        <button onclick="printInvoice()" class="w-8 h-8 rounded-full hover:bg-zinc-100 flex items-center justify-center text-zinc-500" title="In hóa đơn"><span class="material-symbols-outlined text-[18px]">print</span></button>
        <button onclick="closeInvoiceDetail()" class="w-8 h-8 rounded-full hover:bg-zinc-100 flex items-center justify-center text-zinc-500"><span class="material-symbols-outlined text-[18px]">close</span></button>
      </div>
    </div>
    
    <!-- Receipt Body -->
    <div class="p-6 flex flex-col gap-5 text-sm" id="invoiceReceiptContent">
      <!-- Status & Header Info -->
      <div class="flex items-start justify-between border-b border-dashed border-zinc-200 pb-4">
        <div>
          <p class="text-xs text-zinc-400">Khách hàng</p>
          <p id="detailCustName" class="font-bold text-zinc-800 mt-0.5">-</p>
          <p id="detailCustPhone" class="text-xs text-zinc-500">-</p>
        </div>
        <div class="text-right">
          <p class="text-xs text-zinc-400">Trạng thái</p>
          <span id="detailStatusBadge" class="inline-block mt-1 font-bold"></span>
        </div>
      </div>

      <!-- Court Booking details (if any) -->
      <div id="detailCourtSection" class="hidden">
        <p class="text-xs font-bold text-zinc-400 uppercase tracking-wider mb-2">Thông tin sân đã đặt</p>
        <div class="bg-zinc-50 rounded-xl p-3 border border-zinc-150 flex flex-col gap-2">
          <div class="flex justify-between">
            <span class="text-zinc-650 font-medium" id="detailCourtName">-</span>
            <span class="font-bold text-zinc-800" id="detailCourtPrice">-</span>
          </div>
          <div class="flex justify-between text-xs text-zinc-500">
            <span>Thời gian đặt: <span id="detailCourtTime">-</span></span>
            <span id="detailCourtDate">-</span>
          </div>
        </div>
      </div>

      <!-- Products & Services list (if any) -->
      <div id="detailServiceSection" class="hidden">
        <p class="text-xs font-bold text-zinc-400 uppercase tracking-wider mb-2">Sản phẩm & Dịch vụ</p>
        <table class="w-full text-xs">
          <thead>
            <tr class="text-zinc-400 border-b border-zinc-150 pb-1">
              <th class="text-left font-semibold pb-1">Tên dịch vụ</th>
              <th class="text-center font-semibold pb-1 w-12">SL</th>
              <th class="text-right font-semibold pb-1 w-20">Đơn giá</th>
              <th class="text-right font-semibold pb-1 w-20">Thành tiền</th>
            </tr>
          </thead>
          <tbody id="detailServiceItems" class="divide-y divide-zinc-100 text-zinc-700">
            <!-- Dynamic rows -->
          </tbody>
        </table>
      </div>

      <!-- Payment Summary -->
      <div class="border-t border-dashed border-zinc-200 pt-4 flex flex-col gap-2.5">
        <div class="flex justify-between text-xs text-zinc-500">
          <span>Tiền sân</span>
          <span id="detailSumCourt">0 đ</span>
        </div>
        <div class="flex justify-between text-xs text-zinc-500">
          <span>Tiền dịch vụ</span>
          <span id="detailSumService">0 đ</span>
        </div>
        <div class="flex justify-between text-xs text-zinc-500">
          <span>Phí gửi xe</span>
          <span id="detailSumParking">0 đ</span>
        </div>
        <div class="flex justify-between text-xs text-zinc-500">
          <span>Giảm giá khuyến mãi</span>
          <span id="detailSumDiscount" class="text-green-600">-0 đ</span>
        </div>
        <div class="flex justify-between items-center border-t border-zinc-200 pt-3 mt-1">
          <span class="font-bold text-zinc-900">Tổng thanh toán</span>
          <span class="text-base font-extrabold text-zinc-950" id="detailSumGrand">0 đ</span>
        </div>
      </div>

      <!-- Footer Info -->
      <div class="border-t border-zinc-100 pt-4 grid grid-cols-2 gap-4 text-xs text-zinc-400">
        <div>
          <p>Phương thức TT: <span class="font-semibold text-zinc-700" id="detailPayMethod">-</span></p>
          <p class="mt-1">Nhân viên lập: <span class="font-semibold text-zinc-700" id="detailCashierName">-</span></p>
        </div>
        <div class="text-right">
          <p>Ngày lập: <span class="font-semibold text-zinc-700" id="detailCreatedDate">-</span></p>
        </div>
      </div>
    </div>
    
    <div class="px-6 py-4 border-t border-zinc-150 bg-zinc-50 flex justify-between items-center">
      <span class="text-[10px] text-zinc-400">V-SPORT · Hệ thống hóa đơn</span>
      <div class="flex gap-2">
        <button id="btnPayInvoice" onclick="payPendingInvoice()" class="hidden h-9 px-4 rounded-lg bg-green-600 text-white hover:bg-green-700 text-xs font-bold transition-all flex items-center gap-1"><span class="material-symbols-outlined text-[14px]">payments</span>Xác nhận thanh toán</button>
        <button onclick="closeInvoiceDetail()" class="h-9 px-4 rounded-lg bg-zinc-200 hover:bg-zinc-300 text-zinc-700 text-xs font-bold transition-all">Đóng</button>
      </div>
    </div>
  </div>
</div>

<!-- Refund Action Modal -->
<div id="refundModal" class="hidden fixed inset-0 z-[80] flex items-center justify-center p-4">
  <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" onclick="closeRefundModal()"></div>
  <div class="relative bg-white rounded-2xl shadow-2xl w-full max-w-[480px] z-10 border border-zinc-200 animate-scale-in">
    <div class="flex items-center justify-between px-6 py-4 border-b border-zinc-200">
      <div class="flex items-center gap-2.5"><span class="material-symbols-outlined text-[20px] text-red-650 text-red-600">currency_exchange</span><h3 class="text-base font-bold text-zinc-900">Xử lý yêu cầu hoàn tiền</h3></div>
      <button onclick="closeRefundModal()" class="w-8 h-8 rounded-full hover:bg-zinc-100 flex items-center justify-center transition-colors"><span class="material-symbols-outlined text-[18px] text-zinc-500">close</span></button>
    </div>
    <div class="px-6 py-5 flex flex-col gap-4">
      <div>
        <p class="text-xs text-zinc-400">Khách hàng</p>
        <p id="refundCustomer" class="text-sm font-semibold text-zinc-800">-</p>
      </div>
      <div class="grid grid-cols-2 gap-4">
        <div>
          <p class="text-xs text-zinc-400">Mã hóa đơn gốc</p>
          <p id="refundInvoiceId" class="text-sm font-semibold text-zinc-800">-</p>
        </div>
        <div>
          <p class="text-xs text-zinc-400">Số tiền hoàn</p>
          <p id="refundAmount" class="text-sm font-semibold text-red-600">-</p>
        </div>
      </div>
      <div>
        <p class="text-xs text-zinc-400">Lý do yêu cầu</p>
        <p id="refundReason" class="text-sm text-zinc-700 bg-zinc-50 p-2.5 rounded-lg border border-zinc-200 mt-1">-</p>
      </div>
      <div>
        <label class="block text-xs font-semibold text-zinc-500 mb-1.5">Ghi chú xử lý (Bắt buộc nếu từ chối)</label>
        <textarea id="refundNotes" rows="2" class="w-full px-3 py-2 bg-white border border-zinc-200 rounded-lg text-xs focus:outline-none focus:ring-2 focus:ring-zinc-400 resize-none" placeholder="Nhập ghi chú xử lý hoàn tiền..."></textarea>
      </div>
    </div>
    <div class="px-6 pb-5 flex gap-3 justify-end">
      <button onclick="processRefundAction('Từ chối')" class="h-9 px-4 rounded-lg bg-red-50 text-red-600 hover:bg-red-100 text-xs font-bold transition-all">Từ chối</button>
      <button onclick="processRefundAction('Đã hoàn tiền')" class="h-9 px-4 rounded-lg bg-green-600 text-white hover:bg-green-700 text-xs font-bold transition-all flex items-center gap-1"><span class="material-symbols-outlined text-[14px]">check_circle</span>Duyệt hoàn tiền</button>
    </div>
  </div>
</div>



<!-- Native animations fully integrated, AOS dependency removed -->
<script>
// Mock data aligning with database schema (QuanLiSport_V4.sql)
const mockAccounts = {
  <c:forEach items="${accounts}" var="a" varStatus="status">
  ${a.accountId}: { FullName: '${a.fullName.replace("'", "\\'")}', PhoneNumber: '${a.phoneNumber}', Email: '${a.email}' }${!status.last ? ',' : ''}
  </c:forEach>
};

const mockKhuyenMai = {
  <c:forEach items="${promotions}" var="k" varStatus="status">
  ${k.khuyenMaiID}: { MaCode: '${k.maCode}', MoTa: '${k.moTa.replace("'", "\\'")}', GiaTriGiam: ${k.giaTriGiam} }${!status.last ? ',' : ''}
  </c:forEach>
};

const mockSanPhamDichVu = {
  <c:forEach items="${products}" var="p" varStatus="status">
  ${p.sanPhamID}: { TenSanPham: '${p.tenSanPham.replace("'", "\\'")}', DonGia: ${p.donGia} }${!status.last ? ',' : ''}
  </c:forEach>
};

const mockSan = {
  <c:forEach items="${courts}" var="s" varStatus="status">
  ${s.sanID}: { TenSan: '${s.tenSan.replace("'", "\\'")}' }${!status.last ? ',' : ''}
  </c:forEach>
};

const mockLichDatSan = {
  <c:forEach items="${bookings}" var="b" varStatus="status">
  ${b.datSanId}: { TenSan: '${b.san != null ? b.san.tenSan.replace("'", "\\'") : "Sân khác"}', NgayDat: '${b.ngayDat}', GioBatDau: '${b.gioBatDau}', GioKetThuc: '${b.gioKetThuc}' }${!status.last ? ',' : ''}
  </c:forEach>
};

let mockInvoices = [
  <c:forEach items="${invoices}" var="h" varStatus="status">
  {
    HoaDonID: ${h.hoaDonId},
    InvoiceCode: 'HD' + ${h.hoaDonId},
    DatSanID: ${h.datSanId != null ? h.datSanId : 'null'},
    AccountID_KhachHang: ${h.accountIdKhachHang != null ? h.accountIdKhachHang : 'null'},
    AccountID_NhanVien: ${h.accountIdNhanVien != null ? h.accountIdNhanVien : 'null'},
    NgayLap: '${h.ngayLap}',
    TongTienSan: ${h.tongTienSan},
    TongTienDichVu: ${h.tongTienDichVu},
    PhiGuiXe: ${h.phiGuiXe},
    KhuyenMaiID: ${h.khuyenMaiId != null ? h.khuyenMaiId : 'null'},
    GiamGia: ${h.giamGia},
    TongThanhToan: ${h.tongThanhToan},
    PhuongThucThanhToan: '${h.phuongThucThanhToan}',
    TrangThaiThanhToan: '${h.trangThaiThanhToan}',
    LoaiHD: '${h.datSanId != null ? "sân" : "dịch vụ"}'
  }${!status.last ? ',' : ''}
  </c:forEach>
];

const mockChiTietHoaDon = [
  <c:forEach items="${invoiceDetails}" var="c" varStatus="status">
  {
    ChiTietID: ${c.chiTietID},
    HoaDonID: ${c.hoaDonID},
    SanPhamID: ${c.sanPhamID},
    SoLuong: ${c.soLuong},
    DonGia: ${c.donGiaTaiThoiDiemBan},
    ThanhTien: ${c.thanhTien}
  }${!status.last ? ',' : ''}
  </c:forEach>
];

let mockRefunds = [
  <c:forEach items="${refunds}" var="r" varStatus="status">
  {
    HoanTienID: ${r.hoanTienId},
    RefundCode: 'HT' + ${r.hoanTienId},
    InvoiceCode: 'HD' + ${r.hoaDonId},
    HoaDonID: ${r.hoaDonId},
    AccountID: ${r.accountId},
    SoTienHoan: ${r.soTienHoan},
    LyDo: '${r.lyDo != null ? r.lyDo.replace("'", "\\'") : ""}',
    TrangThai: '${r.trangThai}',
    ThoiGianYeuCau: '${r.thoiGianYeuCau}',
    ThoiGianHoan: '${r.thoiGianHoan != null ? r.thoiGianHoan : ""}',
    Notes: ''
  }${!status.last ? ',' : ''}
  </c:forEach>
];

// Active items for modals
let selectedInvoice = null;
let selectedRefund = null;

// DOM anchors
const invoiceTableBody = document.getElementById('invoiceTableBody');
const refundTableBody = document.getElementById('refundTableBody');
const searchInput = document.getElementById('filterSearch');
const dateInput = document.getElementById('filterDate');
const typeSelect = document.getElementById('filterType');
const statusSelect = document.getElementById('filterStatus');

// Formatter utilities
function formatVND(val) {
  return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(val).replace('₫', 'đ');
}

function formatDateTime(isoString) {
  if (!isoString) return '-';
  const d = new Date(isoString);
  const pad = (n) => String(n).padStart(2, '0');
  return `\${pad(d.getDate())}/\${pad(d.getMonth() + 1)} · \${pad(d.getHours())}:\${pad(d.getMinutes())}`;
}

// Switches tab
function switchTab(tab) {
  const pi = document.getElementById('panelInvoice');
  const pr = document.getElementById('panelRefund');
  const ti = document.getElementById('tabInvoice');
  const tr = document.getElementById('tabRefund');
  
  if (tab === 'invoice') {
    pi.classList.remove('hidden');
    pr.classList.add('hidden');
    ti.className = 'px-4 py-2.5 text-sm font-semibold text-zinc-900 border-b-2 border-zinc-900 -mb-px flex items-center gap-1.5';
    tr.className = 'px-4 py-2.5 text-sm font-medium text-zinc-500 hover:text-zinc-700 flex items-center gap-1.5';
  } else {
    pr.classList.remove('hidden');
    pi.classList.add('hidden');
    tr.className = 'px-4 py-2.5 text-sm font-semibold text-zinc-900 border-b-2 border-zinc-900 -mb-px flex items-center gap-1.5';
    ti.className = 'px-4 py-2.5 text-sm font-medium text-zinc-500 hover:text-zinc-700 flex items-center gap-1.5';
  }
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

// Invoice Modal operations
function openInvoiceDetail(id) {
  const invoice = mockInvoices.find(i => i.HoaDonID === parseInt(id) || i.InvoiceCode === id);
  if (!invoice) return;
  selectedInvoice = invoice;

  document.getElementById('detailInvoiceCode').textContent = invoice.InvoiceCode;
  
  const customer = mockAccounts[invoice.AccountID_KhachHang];
  document.getElementById('detailCustName').textContent = customer ? customer.FullName : 'Khách vãng lai';
  document.getElementById('detailCustPhone').textContent = customer ? customer.PhoneNumber : '-';
  
  const statusBadge = document.getElementById('detailStatusBadge');
  if (invoice.TrangThaiThanhToan === 'Đã thanh toán') {
    statusBadge.className = 'inline-flex items-center px-2 py-0.5 rounded text-[10px] font-bold bg-green-50 text-green-700 border border-green-200';
    statusBadge.textContent = 'Đã thanh toán';
    document.getElementById('btnPayInvoice').classList.add('hidden');
  } else if (invoice.TrangThaiThanhToan === 'Chờ thanh toán') {
    statusBadge.className = 'inline-flex items-center px-2 py-0.5 rounded text-[10px] font-bold bg-amber-50 text-amber-700 border border-amber-200';
    statusBadge.textContent = 'Chờ thanh toán';
    document.getElementById('btnPayInvoice').classList.remove('hidden');
  } else {
    statusBadge.className = 'inline-flex items-center px-2 py-0.5 rounded text-[10px] font-bold bg-red-50 text-red-700 border border-red-200';
    statusBadge.textContent = 'Đã hủy';
    document.getElementById('btnPayInvoice').classList.add('hidden');
  }

  const courtSection = document.getElementById('detailCourtSection');
  if (invoice.DatSanID) {
    courtSection.classList.remove('hidden');
    const booking = mockLichDatSan[invoice.DatSanID];
    if (booking) {
      document.getElementById('detailCourtName').textContent = booking.TenSan;
      document.getElementById('detailCourtPrice').textContent = formatVND(invoice.TongTienSan);
      document.getElementById('detailCourtTime').textContent = `\${booking.GioBatDau.substring(0, 5)} - \${booking.GioKetThuc.substring(0, 5)}`;
      document.getElementById('detailCourtDate').textContent = formatDateTime(booking.NgayDat).split(' · ')[0];
    }
  } else {
    courtSection.classList.add('hidden');
  }

  const serviceSection = document.getElementById('detailServiceSection');
  const serviceItemsBody = document.getElementById('detailServiceItems');
  serviceItemsBody.innerHTML = '';
  
  const items = mockChiTietHoaDon.filter(item => item.HoaDonID === invoice.HoaDonID);
  if (items.length > 0) {
    serviceSection.classList.remove('hidden');
    items.forEach(item => {
      const prod = mockSanPhamDichVu[item.SanPhamID];
      const tr = document.createElement('tr');
      tr.className = 'text-zinc-700';
      tr.innerHTML = `
        <td class="py-2 pb-1 font-medium text-zinc-800">\${prod ? prod.TenSanPham : 'Sản phẩm ' + item.SanPhamID}</td>
        <td class="py-2 pb-1 text-center w-12">\${item.SoLuong}</td>
        <td class="py-2 pb-1 text-right w-20 text-zinc-500">\${formatVND(item.DonGia)}</td>
        <td class="py-2 pb-1 text-right w-20 font-semibold text-zinc-800">\${formatVND(item.ThanhTien)}</td>
      `;
      serviceItemsBody.appendChild(tr);
    });
  } else {
    serviceSection.classList.add('hidden');
  }

  document.getElementById('detailSumCourt').textContent = formatVND(invoice.TongTienSan);
  document.getElementById('detailSumService').textContent = formatVND(invoice.TongTienDichVu);
  document.getElementById('detailSumParking').textContent = formatVND(invoice.PhiGuiXe);
  document.getElementById('detailSumDiscount').textContent = `-\${formatVND(invoice.GiamGia)}`;
  document.getElementById('detailSumGrand').textContent = formatVND(invoice.TongThanhToan);

  document.getElementById('detailPayMethod').textContent = invoice.PhuongThucThanhToan || 'Chưa chọn';
  const cashier = mockAccounts[invoice.AccountID_NhanVien];
  document.getElementById('detailCashierName').textContent = cashier ? cashier.FullName : 'Không xác định';
  
  const dateParts = invoice.NgayLap.split('T');
  document.getElementById('detailCreatedDate').textContent = `\${dateParts[0].split('-').reverse().join('/')} \${dateParts[1].substring(0, 5)}`;

  document.getElementById('invoiceDetailModal').classList.remove('hidden');
}

function closeInvoiceDetail() {
  document.getElementById('invoiceDetailModal').classList.add('hidden');
  selectedInvoice = null;
}

function printInvoice() {
  if (!selectedInvoice) return;
  const content = document.getElementById('invoiceReceiptContent').innerHTML;
  const printWindow = window.open('', '_blank', 'width=600,height=800');
  printWindow.document.write(`
    \\${'<' + 'html>'}
      \\${'<' + 'head>'}
        <title>In Hóa Đơn - V-SPORT</title>
        <style>
          body { font-family: monospace; padding: 20px; color: #000; }
          .text-center { text-align: center; }
          .text-right { text-align: right; }
          .font-bold { font-weight: bold; }
          .border-b { border-bottom: 1px dashed #000; padding-bottom: 10px; margin-bottom: 10px; }
          .flex { display: flex; justify-content: space-between; }
          table { width: 100%; border-collapse: collapse; margin-top: 10px; }
          th { text-align: left; border-bottom: 1px solid #000; }
          td { padding: 4px 0; }
          .total { font-size: 16px; font-weight: bold; margin-top: 15px; border-top: 1px solid #000; padding-top: 10px; }
        </style>
      \\${'</' + 'head>'}
      \\${'<' + 'body>'}
        <h1 class="text-center">V-SPORT CLUB</h1>
        <p class="text-center font-bold">HÓA ĐƠN GIAO DỊCH</p>
        <div class="border-b"></div>
        \${content}
        <div class="border-b" style="margin-top: 20px;"></div>
        <p class="text-center">CẢM ƠN QUÝ KHÁCH HÀNG & HẸN GẶP LẠI!</p>
      \\${'</' + 'body>'}
    \\${'</' + 'html>'}
  `);
  printWindow.document.write('<script>window.print(); setTimeout(function() { window.close(); }, 1000);<' + '/script>');
  printWindow.document.close();
}

function payPendingInvoice() {
  if (!selectedInvoice) return;
  const form = document.createElement('form');
  form.method = 'POST';
  form.action = '${pageContext.request.contextPath}/admin/hoa-don';
  
  const actionField = document.createElement('input');
  actionField.type = 'hidden';
  actionField.name = 'action';
  actionField.value = 'pay';
  form.appendChild(actionField);
  
  const idField = document.createElement('input');
  idField.type = 'hidden';
  idField.name = 'invoiceId';
  idField.value = selectedInvoice.HoaDonID;
  form.appendChild(idField);
  
  document.body.appendChild(form);
  form.submit();
}

// Refund Process operations
function openRefundModal(id) {
  const refund = mockRefunds.find(r => r.HoanTienID === parseInt(id) || r.RefundCode === id);
  if (!refund) return;
  selectedRefund = refund;

  const customer = mockAccounts[refund.AccountID];
  document.getElementById('refundCustomer').textContent = customer ? `\${customer.FullName} (\${customer.PhoneNumber})` : 'Khách vãng lai';
  
  const origInvoice = mockInvoices.find(i => i.HoaDonID === refund.HoaDonID);
  document.getElementById('refundInvoiceId').textContent = origInvoice ? origInvoice.InvoiceCode : `HD#\${refund.HoaDonID}`;
  document.getElementById('refundAmount').textContent = formatVND(refund.SoTienHoan);
  document.getElementById('refundReason').textContent = refund.LyDo;
  document.getElementById('refundNotes').value = refund.Notes || '';

  document.getElementById('refundModal').classList.remove('hidden');
}

function closeRefundModal() {
  document.getElementById('refundModal').classList.add('hidden');
  selectedRefund = null;
}

function processRefundAction(action) {
  if (!selectedRefund) return;
  const notes = document.getElementById('refundNotes').value.trim();
  if (action === 'Từ chối' && !notes) {
    alert('Vui lòng nhập lý do từ chối.');
    return;
  }

  const form = document.createElement('form');
  form.method = 'POST';
  form.action = '${pageContext.request.contextPath}/admin/hoa-don';
  
  const actionField = document.createElement('input');
  actionField.type = 'hidden';
  actionField.name = 'action';
  actionField.value = 'refund';
  form.appendChild(actionField);
  
  const idField = document.createElement('input');
  idField.type = 'hidden';
  idField.name = 'refundId';
  idField.value = selectedRefund.HoanTienID;
  form.appendChild(idField);
  
  const statusField = document.createElement('input');
  statusField.type = 'hidden';
  statusField.name = 'status';
  statusField.value = action === 'Từ chối' ? 'Từ chối' : 'Đã hoàn tiền';
  form.appendChild(statusField);
  
  const notesField = document.createElement('input');
  notesField.type = 'hidden';
  notesField.name = 'notes';
  notesField.value = notes;
  form.appendChild(notesField);
  
  document.body.appendChild(form);
  form.submit();
}

// Render data lists
function renderInvoices() {
  const query = searchInput.value.toLowerCase().trim();
  const dateVal = dateInput.value;
  const typeVal = typeSelect.value;
  const statusVal = statusSelect.value;

  invoiceTableBody.innerHTML = '';
  
  let filtered = mockInvoices.filter(invoice => {
    const customer = mockAccounts[invoice.AccountID_KhachHang];
    const matchesSearch = invoice.InvoiceCode.toLowerCase().includes(query) || 
      (customer && customer.FullName.toLowerCase().includes(query)) ||
      (customer && customer.PhoneNumber.includes(query));
      
    const invoiceDate = invoice.NgayLap.substring(0, 10);
    const matchesDate = !dateVal || invoiceDate === dateVal;
    const matchesType = typeVal === 'all' || invoice.LoaiHD === typeVal;
    const matchesStatus = statusVal === 'all' || invoice.TrangThaiThanhToan === statusVal;

    return matchesSearch && matchesDate && matchesType && matchesStatus;
  });

  if (filtered.length === 0) {
    invoiceTableBody.innerHTML = `
      <tr>
        <td colspan="8" class="px-4 py-8 text-center text-zinc-400 text-xs">
          Không tìm thấy hóa đơn nào khớp với bộ lọc
        </td>
      </tr>
    `;
    return;
  }

  filtered.forEach(invoice => {
    const customer = mockAccounts[invoice.AccountID_KhachHang];
    const booking = mockLichDatSan[invoice.DatSanID];
    
    const tr = document.createElement('tr');
    tr.className = 'hover:bg-zinc-50 transition-colors';
    
    let statusClass = 'badge badge-green';
    if (invoice.TrangThaiThanhToan === 'Chờ thanh toán') statusClass = 'badge badge-amber';
    else if (invoice.TrangThaiThanhToan === 'Đã hủy') statusClass = 'badge badge-red';

    let typeBadge = `<span class="badge \${invoice.LoaiHD === 'sân' ? 'badge-blue' : 'badge-amber'}">\${invoice.LoaiHD === 'sân' ? 'Đặt sân' : 'Dịch vụ'}</span>`;

    let timeText = '-';
    if (invoice.DatSanID && booking) {
      timeText = `\${booking.NgayDat.substring(8, 10)}/\${booking.NgayDat.substring(5, 7)} · \${booking.GioBatDau.substring(0, 5)}–\${booking.GioKetThuc.substring(0, 5)}`;
    } else {
      timeText = formatDateTime(invoice.NgayLap);
    }

    tr.innerHTML = `
      <td class="px-4 py-3 font-mono text-xs text-zinc-500 font-semibold">\${invoice.InvoiceCode}</td>
      <td class="px-4 py-3">
        <p class="font-bold text-zinc-900">\${customer ? customer.FullName : 'Khách vãng lai'}</p>
        <p class="text-xs text-zinc-400">\${customer ? customer.PhoneNumber : '-'}</p>
      </td>
      <td class="px-4 py-3 hidden sm:table-cell">\${typeBadge}</td>
      <td class="px-4 py-3 text-zinc-500 hidden md:table-cell text-xs">\${timeText}</td>
      <td class="px-4 py-3 text-right font-extrabold text-zinc-900">\${formatVND(invoice.TongThanhToan)}</td>
      <td class="px-4 py-3 hidden lg:table-cell text-xs text-zinc-500">\${invoice.PhuongThucThanhToan || 'Mặc định'}</td>
      <td class="px-4 py-3"><span class="\${statusClass}">\${invoice.TrangThaiThanhToan}</span></td>
      <td class="px-4 py-3 text-right">
        <div class="flex items-center justify-end gap-1.5">
          <button onclick="openInvoiceDetail(\${invoice.HoaDonID})" class="p-1 rounded hover:bg-zinc-100 text-zinc-650" title="Chi tiết"><span class="material-symbols-outlined text-[16px]">visibility</span></button>
          <button onclick="selectedInvoice = mockInvoices.find(i=>i.HoaDonID===\${invoice.HoaDonID}); printInvoice();" class="p-1 rounded hover:bg-zinc-100 text-zinc-650" title="In bill"><span class="material-symbols-outlined text-[16px]">print</span></button>
          \${invoice.TrangThaiThanhToan === 'Chờ thanh toán' ? `
            <button onclick="selectedInvoice = mockInvoices.find(i=>i.HoaDonID===\${invoice.HoaDonID}); payPendingInvoice();" class="p-1 rounded hover:bg-green-50 text-green-600" title="Thu tiền"><span class="material-symbols-outlined text-[16px]">payments</span></button>
          ` : ''}
        </div>
      </td>
    `;
    invoiceTableBody.appendChild(tr);
  });
}

function renderRefunds() {
  const query = searchInput.value.toLowerCase().trim();
  
  refundTableBody.innerHTML = '';
  
  let filtered = mockRefunds.filter(refund => {
    const customer = mockAccounts[refund.AccountID];
    const origInvoice = mockInvoices.find(i => i.HoaDonID === refund.HoaDonID);
    
    const matchesSearch = refund.RefundCode.toLowerCase().includes(query) ||
      (customer && customer.FullName.toLowerCase().includes(query)) ||
      (origInvoice && origInvoice.InvoiceCode.toLowerCase().includes(query));
      
    return matchesSearch;
  });

  if (filtered.length === 0) {
    refundTableBody.innerHTML = `
      <tr>
        <td colspan="7" class="px-4 py-8 text-center text-zinc-400 text-xs">
          Không tìm thấy yêu cầu hoàn tiền nào
        </td>
      </tr>
    `;
    return;
  }

  filtered.forEach(refund => {
    const customer = mockAccounts[refund.AccountID];
    const origInvoice = mockInvoices.find(i => i.HoaDonID === refund.HoaDonID);
    
    const tr = document.createElement('tr');
    tr.className = `hover:bg-zinc-50 transition-colors \${refund.TrangThai === 'Chờ duyệt' ? 'bg-red-50/20 border-l border-red-400' : ''}`;
    
    let statusClass = 'badge badge-green';
    if (refund.TrangThai === 'Chờ duyệt') statusClass = 'badge badge-amber';
    else if (refund.TrangThai === 'Từ chối') statusClass = 'badge badge-red';

    tr.innerHTML = `
      <td class="px-4 py-3 font-mono text-xs text-zinc-500 font-semibold">\${refund.RefundCode}</td>
      <td class="px-4 py-3">
        <p class="font-bold text-zinc-900">\${customer ? customer.FullName : 'Khách lẻ'}</p>
        <p class="text-xs text-zinc-400">\${customer ? customer.PhoneNumber : '-'}</p>
      </td>
      <td class="px-4 py-3 font-mono text-xs text-zinc-500 hidden sm:table-cell">\${origInvoice ? origInvoice.InvoiceCode : '-'}</td>
      <td class="px-4 py-3 text-zinc-550 text-xs hidden md:table-cell max-w-xs truncate" title="\${refund.LyDo}">\${refund.LyDo}</td>
      <td class="px-4 py-3 text-right font-extrabold text-zinc-900">\${formatVND(refund.SoTienHoan)}</td>
      <td class="px-4 py-3"><span class="\${statusClass}">\${refund.TrangThai === 'Chờ duyệt' ? 'Chờ duyệt' : refund.TrangThai}</span></td>
      <td class="px-4 py-3 text-right">
        <div class="flex justify-end gap-1">
          \${refund.TrangThai === 'Chờ duyệt' ? `
            <button onclick="openRefundModal('\${refund.RefundCode}')" class="px-2.5 py-1 rounded-lg bg-green-100 hover:bg-green-200 text-zinc-800 text-xs font-bold transition-all flex items-center gap-0.5"><span class="material-symbols-outlined text-[13px]">currency_exchange</span>Xử lý</button>
          ` : `
            <button onclick="openRefundModal('\${refund.RefundCode}')" class="p-1 rounded hover:bg-zinc-100 text-zinc-400" title="Chi tiết"><span class="material-symbols-outlined text-[16px]">visibility</span></button>
          `}
        </div>
      </td>
    `;
    refundTableBody.appendChild(tr);
  });
}

// Calculate and update KPIs dynamically
function updateStats() {
  const todayDate = '2026-05-17';
  const paidToday = mockInvoices.filter(i => i.NgayLap.startsWith(todayDate) && i.TrangThaiThanhToan === 'Đã thanh toán');
  const revenueToday = paidToday.reduce((sum, i) => sum + i.TongThanhToan, 0);
  document.getElementById('statRevenueToday').textContent = formatVND(revenueToday);

  const invoicesTodayCount = mockInvoices.filter(i => i.NgayLap.startsWith(todayDate)).length;
  document.getElementById('statInvoicesToday').textContent = invoicesTodayCount;
  document.getElementById('statInvoicesTotal').textContent = `Tổng tháng: \${mockInvoices.length}`;

  const pendingInvoices = mockInvoices.filter(i => i.TrangThaiThanhToan === 'Chờ thanh toán');
  const pendingAmount = pendingInvoices.reduce((sum, i) => sum + i.TongThanhToan, 0);
  document.getElementById('statPendingPayments').textContent = pendingInvoices.length;
  document.getElementById('statPendingPaymentsAmount').textContent = `Tổng: \${formatVND(pendingAmount)}`;

  const pendingRefundsCount = mockRefunds.filter(r => r.TrangThai === 'Chờ duyệt').length;
  document.getElementById('statPendingRefunds').textContent = pendingRefundsCount;

  document.getElementById('tabInvoiceCount').textContent = mockInvoices.length;
  document.getElementById('tabRefundCount').textContent = mockRefunds.length;
}

function renderAll() {
  renderInvoices();
  renderRefunds();
  updateStats();
}

// DOM Setup
document.addEventListener('DOMContentLoaded', () => {
  dateInput.value = '2026-05-17';

  searchInput.addEventListener('input', renderAll);
  dateInput.addEventListener('change', renderAll);
  typeSelect.addEventListener('change', renderAll);
  statusSelect.addEventListener('change', renderAll);

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
