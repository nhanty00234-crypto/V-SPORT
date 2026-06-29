<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Quản lý sân chi nhánh — V-SPORT</title>
<script src="https://cdn.tailwindcss.com"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200">
<style>
  body { font-family: 'Inter', sans-serif; }
  .card { background:#fff;border:1px solid #f3e8ff;border-radius:16px; transition:box-shadow .2s, transform .2s; }
  .card-hover:hover { box-shadow:0 8px 24px -8px rgba(139,92,246,.12); transform:translateY(-2px); }
  .badge { display:inline-flex;align-items:center;padding:4px 10px;border-radius:8px;font-size:11px;font-weight:600; }
  .badge-green { background:#dcfce7;color:#15803d; }
  .badge-amber { background:#fef3c7;color:#b45309; }
  .badge-red { background:#fee2e2;color:#b91c1c; }
  .badge-purple { background:#f3e8ff;color:#6b21a8; }
  .badge-gray { background:#f4f4f5;color:#52525b; }
  ::-webkit-scrollbar{width:6px;height:6px}::-webkit-scrollbar-track{background:transparent}::-webkit-scrollbar-thumb{background:#ddd6fe;border-radius:6px}
  ::-webkit-scrollbar-thumb:hover{background:#c084fc}
  @keyframes fadeUp { from { opacity:0; transform:translateY(10px); } to { opacity:1; transform:translateY(0); } }
  @keyframes pop { 0% { opacity:0; transform:scale(.94); } 100% { opacity:1; transform:scale(1); } }
  main > section { animation: fadeUp .4s ease both; }

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
<body class="bg-purple-50/20 text-zinc-900 min-h-screen">

<!-- Sidebar -->
<jsp:include page="/manager/common/sidebar.jsp" />

<!-- Header -->
<header class="h-[64px] fixed top-0 right-0 left-0 lg:left-[248px] bg-white/80 backdrop-blur-lg border-b border-purple-100 z-20 flex items-center justify-between px-4 lg:px-6">
  <div class="flex items-center gap-3">
    <button id="mobileMenuBtn" class="lg:hidden p-2 rounded-lg hover:bg-purple-50 text-purple-700"><span class="material-symbols-outlined text-[20px]">menu</span></button>
    <div>
      <h1 class="text-sm font-bold text-purple-900 tracking-tight">Quản lý sân thi đấu</h1>
      <p class="text-xs text-purple-500 flex items-center gap-1.5">
        <span class="material-symbols-outlined text-[12px]">storefront</span>Cơ sở CS${managerCoSoId}
      </p>
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

<main class="lg:ml-[248px] mt-[64px] p-4 lg:p-6 flex flex-col gap-5">

  <!-- Header section -->
  <section class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
    <div>
      <h2 class="text-2xl font-black tracking-tight text-purple-950">Sân thi đấu chi nhánh</h2>
    </div>
    <div class="flex items-center gap-2">
      <button id="mainActionBtn" onclick="openCreateModal()" class="flex items-center gap-1.5 h-10 px-4 rounded-xl bg-purple-600 text-white text-sm font-semibold shadow-md shadow-purple-200 hover:bg-purple-700">
        <span class="material-symbols-outlined text-[16px]">add</span>Thêm sân mới
      </button>
    </div>
  </section>

  <!-- Navigation Tabs -->
  <section class="flex border-b border-purple-100 gap-6">
    <button id="btnTabCourts" onclick="switchTab('courts')" class="pb-3 text-sm font-bold border-b-2 border-purple-600 text-purple-600 flex items-center gap-2 transition-all">
      <span class="material-symbols-outlined text-[18px]">stadium</span>Danh sách sân thi đấu
    </button>
    <button id="btnTabTypes" onclick="switchTab('types')" class="pb-3 text-sm font-medium border-b-2 border-transparent text-purple-500 hover:text-purple-800 flex items-center gap-2 transition-all">
      <span class="material-symbols-outlined text-[18px]">payments</span>Cấu hình loại sân & Bảng giá
    </button>
  </section>

  <!-- Alert Messages -->
  <c:if test="${not empty sessionScope.error}">
    <div class="p-4 bg-red-50 border border-red-100 rounded-xl text-red-650 text-sm flex items-start gap-3 animate-fade-in-up shadow-sm">
      <span class="material-symbols-outlined text-[20px] shrink-0">error</span>
      <div>
        <span class="font-bold block text-red-700">Lỗi thực thi</span>
        <span class="text-red-650/95 leading-normal block mt-0.5">${sessionScope.error}</span>
      </div>
      <% session.removeAttribute("error"); %>
    </div>
  </c:if>
  <c:if test="${not empty sessionScope.message}">
    <div class="p-4 bg-purple-50 border border-purple-100 rounded-xl text-purple-700 text-sm flex items-start gap-3 animate-fade-in-up shadow-sm">
      <span class="material-symbols-outlined text-[20px] shrink-0">check_circle</span>
      <div>
        <span class="font-bold block text-purple-800">Thành công</span>
        <span class="text-purple-700/95 leading-normal block mt-0.5">${sessionScope.message}</span>
      </div>
      <% session.removeAttribute("message"); %>
    </div>
  </c:if>

  <!-- Stats Grid -->
  <section id="statsSection" class="grid grid-cols-2 sm:grid-cols-4 gap-3">
    <div class="card p-4 hover:shadow-md transition-shadow">
      <div class="flex items-center gap-3">
        <div class="w-10 h-10 rounded-xl bg-purple-50 flex items-center justify-center"><span class="material-symbols-outlined text-[20px] text-purple-700">stadium</span></div>
        <div>
          <p class="text-[11px] text-zinc-500 font-medium">Tổng số sân</p>
          <p id="statTotal" class="text-2xl font-black text-purple-950">0</p>
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
        <div class="w-10 h-10 rounded-xl bg-red-50 flex items-center justify-center"><span class="material-symbols-outlined text-[20px] text-red-600">block</span></div>
        <div>
          <p class="text-[11px] text-zinc-500 font-medium">Tạm đóng</p>
          <p id="statClosed" class="text-2xl font-black text-red-500">0</p>
        </div>
      </div>
    </div>
  </section>

  <!-- Toolbar Section -->
  <section id="toolbarSection" class="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-3">
    <div class="flex items-center gap-2 flex-wrap">
      <!-- View mode switch -->
      <div class="flex rounded-xl border border-purple-250 overflow-hidden bg-white">
        <button id="btnViewGrid" onclick="setViewMode('grid')" class="px-3 py-2 text-sm flex items-center gap-1.5 bg-purple-600 text-white font-semibold">
          <span class="material-symbols-outlined text-[15px]">grid_view</span>Lưới
        </button>
        <button id="btnViewList" onclick="setViewMode('list')" class="px-3 py-2 text-sm flex items-center gap-1.5 text-purple-600 hover:bg-purple-50">
          <span class="material-symbols-outlined text-[15px]">list</span>Danh sách
        </button>
      </div>
      <!-- Type Filter -->
      <select id="filterType" onchange="applyFilters()" class="h-10 pl-3 pr-8 rounded-xl border border-purple-200 bg-white text-sm text-purple-850 focus:outline-none focus:ring-2 focus:ring-purple-500/30">
        <option value="all">Tất cả môn thể thao</option>
      </select>
      <!-- Status Filter -->
      <select id="filterStatus" onchange="applyFilters()" class="h-10 pl-3 pr-8 rounded-xl border border-purple-200 bg-white text-sm text-purple-850 focus:outline-none focus:ring-2 focus:ring-purple-500/30">
        <option value="all">Tất cả trạng thái</option>
        <option value="Sẵn sàng">Sẵn sàng</option>
        <option value="Đang dùng">Đang dùng</option>
        <option value="Bảo trì">Bảo trì</option>
        <option value="Tạm đóng">Tạm đóng</option>
      </select>
    </div>
    <!-- Search Bar -->
    <div class="relative max-w-xs flex-1">
      <span class="absolute left-3 top-1/2 -translate-y-1/2 material-symbols-outlined text-[16px] text-purple-400">search</span>
      <input type="text" id="searchInput" oninput="applyFilters()" placeholder="Tìm sân theo tên..." class="h-10 w-full pl-9 pr-3 rounded-xl border border-purple-200 text-sm focus:outline-none focus:ring-2 focus:ring-purple-500/30 focus:border-purple-400">
    </div>
  </section>

  <!-- Court List & Types Grid Layout Containers -->
  <section class="min-h-[400px]">
    <!-- Court Cards (Grid View) -->
    <div id="mainCourtGrid" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
      <!-- Generated Dynamically -->
    </div>

    <!-- Court Table (List View) - hidden by default -->
    <div id="mainCourtList" class="hidden card overflow-hidden bg-white border border-purple-200 shadow-sm rounded-2xl">
      <div class="overflow-x-auto">
        <table class="w-full text-left border-collapse">
          <thead>
            <tr class="border-b border-purple-200 text-xs font-bold text-purple-800 uppercase tracking-wider bg-purple-50/50">
              <th class="px-5 py-3.5">Mã sân</th>
              <th class="px-5 py-3.5">Tên sân</th>
              <th class="px-5 py-3.5">Loại sân / Bộ môn</th>
              <th class="px-5 py-3.5">Giá không đèn / Có đèn</th>
              <th class="px-5 py-3.5">Thời gian lên đèn</th>
              <th class="px-5 py-3.5">Trạng thái</th>
              <th class="px-5 py-3.5 text-right">Thao tác</th>
            </tr>
          </thead>
          <tbody id="courtListTableBody" class="divide-y divide-purple-50 text-xs text-zinc-700">
            <!-- Generated Dynamically -->
          </tbody>
        </table>
      </div>
    </div>

    <!-- Pricing and Court Types View (Tab 2) - hidden by default -->
    <div id="pricingTypesView" class="hidden card overflow-hidden bg-white border border-purple-200 shadow-sm rounded-2xl">
      <div class="p-4 border-b border-purple-150 flex items-center justify-between">
        <div>
          <h3 class="text-sm font-bold text-purple-950 font-sans">Cấu hình Loại sân & Bảng giá giờ lên đèn</h3>
          <p class="text-[11px] text-purple-550">Điều chỉnh biểu phí giờ bật đèn riêng cho từng môn thể thao</p>
        </div>
        <button onclick="openCreateTypeModal()" class="flex items-center gap-1.5 h-8 px-3 rounded-lg bg-purple-600 hover:bg-purple-750 text-white text-[11px] font-bold transition-all shadow-sm">
          <span class="material-symbols-outlined text-[14px]">add</span>Thêm loại sân mới
        </button>
      </div>
      <div class="overflow-x-auto">
        <table class="w-full text-left border-collapse">
          <thead>
            <tr class="border-b border-purple-200 text-xs font-bold text-purple-800 uppercase tracking-wider bg-purple-50/50">
              <th class="px-5 py-3.5">Mã Loại</th>
              <th class="px-5 py-3.5">Tên Loại Sân</th>
              <th class="px-5 py-3.5">Bộ môn</th>
              <th class="px-5 py-3.5">Giá không đèn (Tiêu chuẩn)</th>
              <th class="px-5 py-3.5">Giá tối (Có đèn)</th>
              <th class="px-5 py-3.5">Giờ bắt đầu lên đèn</th>
              <th class="px-5 py-3.5">Giờ kết thúc bật đèn</th>
              <th class="px-5 py-3.5 text-right">Thao tác</th>
            </tr>
          </thead>
          <tbody id="typeListTableBody" class="divide-y divide-purple-50 text-xs text-zinc-700">
            <!-- Generated Dynamically -->
          </tbody>
        </table>
      </div>
    </div>
  </section>

  <!-- Empty State Placeholder -->
  <section id="emptyState" class="hidden flex-col items-center justify-center p-12 text-center bg-white rounded-3xl border border-dashed border-purple-200">
    <span class="material-symbols-outlined text-[48px] text-purple-300">stadium</span>
    <p class="text-sm font-bold text-purple-900 mt-2">Không tìm thấy sân thi đấu nào</p>
    <p class="text-xs text-purple-500 mt-0.5">Vui lòng điều chỉnh bộ lọc hoặc tạo thêm sân thi đấu mới.</p>
  </section>

</main>

<!-- Modal 1: Thêm/Sửa sân (`courtModal`) -->
<div id="courtModal" class="hidden fixed inset-0 z-[80] flex items-center justify-center p-4">
  <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" onclick="closeCourtModal()"></div>
  <div class="relative bg-white rounded-3xl shadow-2xl w-full max-w-[480px] max-h-[92vh] overflow-y-auto border border-purple-100">
    <div class="flex items-center justify-between px-6 py-4 border-b border-purple-50">
      <div>
        <h2 id="courtModalTitle" class="text-base font-bold text-purple-950 font-sans">Thêm sân mới</h2>
        <p class="text-xs text-purple-500 mt-0.5">Tạo sân thi đấu mới cho chi nhánh</p>
      </div>
      <button onclick="closeCourtModal()" class="p-1.5 rounded-lg hover:bg-purple-50"><span class="material-symbols-outlined text-[18px] text-zinc-500">close</span></button>
    </div>
    <form id="courtForm" class="px-6 py-4 flex flex-col gap-4" method="POST" action="${pageContext.request.contextPath}/manager/quan-ly-san">
      <input type="hidden" name="action" id="courtAction" value="add">
      <input type="hidden" name="sanID" id="courtEditId">
      
      <div class="flex flex-col gap-1.5">
        <label class="text-xs font-semibold text-purple-900">Tên sân *</label>
        <input type="text" name="tenSan" id="courtName" required placeholder="Tên hiển thị (VD: Sân Bóng Đá 1)" class="h-10 px-3 rounded-xl border border-purple-200 text-sm focus:outline-none focus:ring-2 focus:ring-purple-500/30 focus:border-purple-400">
      </div>

      <div class="flex flex-col gap-1.5">
        <label class="text-xs font-semibold text-purple-900">Loại cấu hình sân *</label>
        <select name="loaiSanID" id="courtTypeSelect" required class="h-10 px-3 rounded-xl border border-purple-200 text-sm focus:outline-none focus:ring-2 focus:ring-purple-500/30 focus:border-purple-400">
          <!-- Populated dynamically -->
        </select>
      </div>

      <div class="flex flex-col gap-1.5">
        <label class="text-xs font-semibold text-purple-900">Trạng thái sân *</label>
        <select name="trangThai" id="courtStatus" required class="h-10 px-3 rounded-xl border border-purple-200 text-sm focus:outline-none focus:ring-2 focus:ring-purple-500/30 focus:border-purple-400">
          <option value="Sẵn sàng">Sẵn sàng</option>
          <option value="Đang dùng">Đang dùng</option>
          <option value="Bảo trì">Bảo trì</option>
          <option value="Tạm đóng">Tạm đóng</option>
        </select>
      </div>

      <div class="flex flex-col gap-1.5">
        <label class="text-xs font-semibold text-purple-900">Mô tả chi tiết</label>
        <textarea name="moTa" id="courtDesc" rows="3" placeholder="Sân cỏ nhân tạo chất lượng cao, lưới bao đầy đủ..." class="px-3 py-2 rounded-xl border border-purple-200 text-sm focus:outline-none focus:ring-2 focus:ring-purple-500/30 focus:border-purple-400 resize-none"></textarea>
      </div>

      <div class="flex flex-col gap-1.5">
        <label class="text-xs font-semibold text-purple-900">Link ảnh sân (Tùy chọn)</label>
        <input type="text" name="hinhAnh" id="courtImage" placeholder="https://unsplash.com/..." class="h-10 px-3 rounded-xl border border-purple-200 text-sm focus:outline-none focus:ring-2 focus:ring-purple-500/30 focus:border-purple-400">
      </div>
      
      <div class="flex justify-end gap-2 pt-3 border-t border-purple-50">
        <button type="button" onclick="closeCourtModal()" class="h-10 px-4 rounded-xl border border-purple-200 text-sm font-semibold text-purple-700 hover:bg-purple-50">Hủy</button>
        <button type="submit" id="saveCourtBtn" class="h-10 px-5 rounded-xl bg-purple-600 text-white text-sm font-semibold hover:bg-purple-700 shadow shadow-purple-200">Lưu lại</button>
      </div>
    </form>
  </div>
</div>

<!-- Modal 2: Thêm/Sửa loại sân & Bảng giá (`typeModal`) -->
<div id="typeModal" class="hidden fixed inset-0 z-[80] flex items-center justify-center p-4">
  <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" onclick="closeTypeModal()"></div>
  <div class="relative bg-white rounded-3xl shadow-2xl w-full max-w-[480px] max-h-[92vh] overflow-y-auto border border-purple-100">
    <div class="flex items-center justify-between px-6 py-4 border-b border-purple-50">
      <div>
        <h2 id="typeModalTitle" class="text-base font-bold text-purple-950 font-sans">Thêm loại sân mới</h2>
        <p class="text-xs text-purple-500 mt-0.5">Thiết lập bộ môn, bảng giá và giờ lên đèn cho chi nhánh</p>
      </div>
      <button onclick="closeTypeModal()" class="p-1.5 rounded-lg hover:bg-purple-50"><span class="material-symbols-outlined text-[18px] text-zinc-500">close</span></button>
    </div>
    <form id="typeForm" class="px-6 py-4 flex flex-col gap-4" method="POST" action="${pageContext.request.contextPath}/manager/quan-ly-san">
      <input type="hidden" name="action" id="typeAction" value="addType">
      <input type="hidden" name="loaiSanID" id="typeEditId">

      <div class="flex flex-col gap-1.5">
        <label class="text-xs font-semibold text-purple-900">Môn thể thao *</label>
        <select name="monTheThaoID" id="typeSportSelect" required class="h-10 px-3 rounded-xl border border-purple-200 text-sm focus:outline-none focus:ring-2 focus:ring-purple-500/30 focus:border-purple-400">
          <!-- Populated dynamically -->
        </select>
      </div>

      <div class="flex flex-col gap-1.5">
        <label class="text-xs font-semibold text-purple-900">Tên loại hình sân *</label>
        <input type="text" name="tenLoai" id="typeName" required placeholder="VD: Sân cỏ nhân tạo 5 người" class="h-10 px-3 rounded-xl border border-purple-200 text-sm focus:outline-none focus:ring-2 focus:ring-purple-500/30 focus:border-purple-400">
      </div>

      <div class="grid grid-cols-2 gap-3">
        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-semibold text-purple-900">Giá ngày (Không đèn) *</label>
          <div class="relative">
            <input type="text" name="giaKhongDen" id="typePriceNoLight" required placeholder="150,000" class="h-10 w-full pl-3 pr-10 rounded-xl border border-purple-200 text-sm focus:outline-none focus:ring-2 focus:ring-purple-500/30 focus:border-purple-400">
            <span class="absolute right-3 top-1/2 -translate-y-1/2 text-xs font-semibold text-purple-400">đ</span>
          </div>
        </div>
        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-semibold text-purple-900">Giá tối (Có bật đèn) *</label>
          <div class="relative">
            <input type="text" name="giaCoDen" id="typePriceWithLight" required placeholder="200,000" class="h-10 w-full pl-3 pr-10 rounded-xl border border-purple-200 text-sm focus:outline-none focus:ring-2 focus:ring-purple-500/30 focus:border-purple-400">
            <span class="absolute right-3 top-1/2 -translate-y-1/2 text-xs font-semibold text-purple-400">đ</span>
          </div>
        </div>
      </div>

      <div class="grid grid-cols-2 gap-3">
        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-semibold text-purple-900">Giờ bắt đầu bật đèn *</label>
          <input type="time" name="gioBatDauLenDen" id="typeLightStart" required value="17:30" class="h-10 px-3 rounded-xl border border-purple-200 text-sm focus:outline-none focus:ring-2 focus:ring-purple-500/30 focus:border-purple-400">
        </div>
        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-semibold text-purple-900">Giờ kết thúc bật đèn *</label>
          <input type="time" name="gioKetThucLenDen" id="typeLightEnd" required value="22:00" class="h-10 px-3 rounded-xl border border-purple-200 text-sm focus:outline-none focus:ring-2 focus:ring-purple-500/30 focus:border-purple-400">
        </div>
      </div>
      <p class="text-[10px] text-purple-500 mt-1">💡 Mẹo: Đối với loại sân trong nhà như Cầu lông, chọn <span class="font-bold">06:00</span> đến <span class="font-bold">22:00</span> để tính giá phụ thu full ca.</p>

      <div class="flex justify-end gap-2 pt-3 border-t border-purple-50">
        <button type="button" onclick="closeTypeModal()" class="h-10 px-4 rounded-xl border border-purple-200 text-sm font-semibold text-purple-700 hover:bg-purple-50">Hủy</button>
        <button type="submit" id="saveTypeBtn" class="h-10 px-5 rounded-xl bg-purple-600 text-white text-sm font-semibold hover:bg-purple-700 shadow shadow-purple-200">Lưu bảng giá</button>
      </div>
    </form>
  </div>
</div>

<!-- Modal 3: Cấu hình giá cho từng sân (`priceConfigModal`) -->
<div id="priceConfigModal" class="hidden fixed inset-0 z-[80] flex items-center justify-center p-4">
  <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" onclick="closePriceConfigModal()"></div>
  <div class="relative bg-white rounded-3xl shadow-2xl w-full max-w-[480px] max-h-[92vh] overflow-y-auto border border-purple-100">
    <div class="flex items-center justify-between px-6 py-4 border-b border-purple-50">
      <div>
        <h2 id="priceConfigModalTitle" class="text-base font-bold text-purple-950 font-sans">Cấu hình giá sân</h2>
        <p id="priceConfigModalSubtitle" class="text-xs text-purple-500 mt-0.5">Thiết lập đơn giá theo khung giờ lên đèn</p>
      </div>
      <button onclick="closePriceConfigModal()" class="p-1.5 rounded-lg hover:bg-purple-50"><span class="material-symbols-outlined text-[18px] text-zinc-500">close</span></button>
    </div>
    <form id="priceConfigForm" class="px-6 py-4 flex flex-col gap-4" method="POST" action="${pageContext.request.contextPath}/manager/quan-ly-san">
      <input type="hidden" name="action" value="updateType">
      <input type="hidden" name="loaiSanID" id="priceConfigLoaiSanId">
      <input type="hidden" name="monTheThaoID" id="priceConfigSportId">
      <input type="hidden" name="tenLoai" id="priceConfigTypeName">

      <!-- Warning/Notice Banner for Shared Court Types -->
      <div id="sharedCourtsWarning" class="p-3 bg-amber-50 border border-amber-100 rounded-xl text-amber-800 text-[11px] flex items-start gap-2">
        <span class="material-symbols-outlined text-[16px] text-amber-600 shrink-0">warning</span>
        <div>
          <span class="font-bold">Lưu ý:</span> 
          Thay đổi giá sẽ áp dụng cho tất cả các sân thuộc cấu hình loại sân này: 
          <span id="sharedCourtsList" class="font-semibold text-amber-900"></span>.
        </div>
      </div>

      <div class="grid grid-cols-2 gap-3">
        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-semibold text-purple-900">Giá ngày (Không đèn) *</label>
          <div class="relative">
            <input type="text" name="giaKhongDen" id="priceConfigPriceNoLight" required placeholder="150,000" class="h-10 w-full pl-3 pr-10 rounded-xl border border-purple-200 text-sm focus:outline-none focus:ring-2 focus:ring-purple-500/30 focus:border-purple-400">
            <span class="absolute right-3 top-1/2 -translate-y-1/2 text-xs font-semibold text-purple-400">đ</span>
          </div>
        </div>
        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-semibold text-purple-900">Giá tối (Có bật đèn) *</label>
          <div class="relative">
            <input type="text" name="giaCoDen" id="priceConfigPriceWithLight" required placeholder="200,000" class="h-10 w-full pl-3 pr-10 rounded-xl border border-purple-200 text-sm focus:outline-none focus:ring-2 focus:ring-purple-500/30 focus:border-purple-400">
            <span class="absolute right-3 top-1/2 -translate-y-1/2 text-xs font-semibold text-purple-400">đ</span>
          </div>
        </div>
      </div>

      <div class="grid grid-cols-2 gap-3">
        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-semibold text-purple-900">Giờ bắt đầu bật đèn *</label>
          <input type="time" name="gioBatDauLenDen" id="priceConfigLightStart" required class="h-10 px-3 rounded-xl border border-purple-200 text-sm focus:outline-none focus:ring-2 focus:ring-purple-500/30 focus:border-purple-400">
        </div>
        <div class="flex flex-col gap-1.5">
          <label class="text-xs font-semibold text-purple-900">Giờ kết thúc bật đèn *</label>
          <input type="time" name="gioKetThucLenDen" id="priceConfigLightEnd" required class="h-10 px-3 rounded-xl border border-purple-200 text-sm focus:outline-none focus:ring-2 focus:ring-purple-500/30 focus:border-purple-400">
        </div>
      </div>

      <div class="flex justify-end gap-2 pt-3 border-t border-purple-50">
        <button type="button" onclick="closePriceConfigModal()" class="h-10 px-4 rounded-xl border border-purple-200 text-sm font-semibold text-purple-700 hover:bg-purple-50">Hủy</button>
        <button type="submit" class="h-10 px-5 rounded-xl bg-purple-600 text-white text-sm font-semibold hover:bg-purple-700 shadow shadow-purple-200">Cập nhật giá</button>
      </div>
    </form>
  </div>
</div>

<script>
  // Mobile menu toggle
  document.getElementById('mobileMenuBtn').addEventListener('click', () => {
    document.getElementById('sidebar').classList.toggle('-translate-x-full');
  });

  // DATA SERIALIZATION
  const mockSports = [
    <c:forEach items="${dsMonTheThao}" var="m" varStatus="loop">
    { id: ${m.monTheThaoID}, name: '${m.tenMon}', icon: '${m.tenMon == "Bóng đá" ? "sports_soccer" : (m.tenMon == "Cầu lông" ? "sports_tennis" : (m.tenMon == "Pickleball" ? "sports_kabaddi" : "sports_tennis"))}' }${!loop.last ? ',' : ''}
    </c:forEach>
  ];

  let mockLoaiSan = [
    <c:forEach items="${dsLoaiSan}" var="l" varStatus="loop">
    { id: ${l.loaiSanID}, sportId: ${l.monTheThaoID}, name: '${l.tenLoai}', priceNoLight: ${l.giaKhongDen}, priceWithLight: ${l.giaCoDen}, lightStart: '${l.gioBatDauLenDen != null ? l.gioBatDauLenDen : ""}', lightEnd: '${l.gioKetThucLenDen != null ? l.gioKetThucLenDen : ""}', coSoId: ${l.coSoID != null ? l.coSoID : 'null'} }${!loop.last ? ',' : ''}
    </c:forEach>
  ];

  let mockSan = [
    <c:forEach items="${dsSan}" var="s" varStatus="loop">
    { id: ${s.sanID}, typeId: ${s.loaiSanID}, coSoId: ${s.coSoID}, code: 'SAN' + ${s.sanID}, name: '${s.tenSan}', status: '${s.trangThai}', desc: '${s.moTa}', image: '${s.hinhAnh}' }${!loop.last ? ',' : ''}
    </c:forEach>
  ];

  const sportImages = {
    1: 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?w=500&h=300&fit=crop',
    2: 'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=500&h=300&fit=crop',
    3: 'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?w=500&h=300&fit=crop',
    4: 'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?w=500&h=300&fit=crop'
  };

  let currentTab = 'courts';
  let viewMode = 'grid';

  function initCurrencyFormatter(inputId) {
    const input = document.getElementById(inputId);
    if (!input) return;
    input.addEventListener('input', (e) => {
      let value = e.target.value.replace(/,/g, '').replace(/[^0-9]/g, '');
      if (value === '') { e.target.value = ''; return; }
      let num = parseInt(value, 10);
      e.target.value = num.toLocaleString('en-US');
    });
  }

  function formatCurrency(val) {
    return val.toLocaleString('vi-VN') + 'đ';
  }

  // POPULATE DROPDOWNS
  function populateSportDropdowns() {
    const filterType = document.getElementById('filterType');
    const typeSportSelect = document.getElementById('typeSportSelect');
    
    mockSports.forEach(s => {
      const opt1 = document.createElement('option');
      opt1.value = s.id;
      opt1.textContent = s.name;
      filterType.appendChild(opt1);

      const opt2 = document.createElement('option');
      opt2.value = s.id;
      opt2.textContent = s.name;
      typeSportSelect.appendChild(opt2);
    });
  }

  function populateCourtTypeDropdown() {
    const select = document.getElementById('courtTypeSelect');
    if (!select) return;
    select.innerHTML = '';
    mockLoaiSan.forEach(t => {
      const opt = document.createElement('option');
      opt.value = t.id;
      opt.textContent = t.name;
      select.appendChild(opt);
    });
  }

  // TAB SWITCHING
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
      btnTabCourts.className = 'pb-3 text-sm font-bold border-b-2 border-purple-600 text-purple-600 flex items-center gap-2 transition-all';
      btnTabTypes.className = 'pb-3 text-sm font-medium border-b-2 border-transparent text-purple-500 hover:text-purple-800 flex items-center gap-2 transition-all';
      mainActionBtn.innerHTML = `<span class="material-symbols-outlined text-[16px]">add</span>Thêm sân mới`;
      mainActionBtn.setAttribute('onclick', 'openCreateModal()');
      
      toolbar.classList.remove('hidden');
      stats.classList.remove('hidden');
      pricingView.classList.add('hidden');
      setViewMode(viewMode);
    } else {
      btnTabTypes.className = 'pb-3 text-sm font-bold border-b-2 border-purple-600 text-purple-600 flex items-center gap-2 transition-all';
      btnTabCourts.className = 'pb-3 text-sm font-medium border-b-2 border-transparent text-purple-500 hover:text-purple-800 flex items-center gap-2 transition-all';
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

  function setViewMode(mode) {
    viewMode = mode;
    const btnGrid = document.getElementById('btnViewGrid');
    const btnList = document.getElementById('btnViewList');
    const mainCourtGrid = document.getElementById('mainCourtGrid');
    const mainCourtList = document.getElementById('mainCourtList');

    if (currentTab !== 'courts') return;

    if (mode === 'grid') {
      btnGrid.className = 'px-3 py-2 text-sm flex items-center gap-1.5 bg-purple-600 text-white font-semibold';
      btnList.className = 'px-3 py-2 text-sm flex items-center gap-1.5 text-purple-600 hover:bg-purple-50';
      mainCourtGrid.classList.remove('hidden');
      mainCourtList.classList.add('hidden');
    } else {
      btnList.className = 'px-3 py-2 text-sm flex items-center gap-1.5 bg-purple-600 text-white font-semibold';
      btnGrid.className = 'px-3 py-2 text-sm flex items-center gap-1.5 text-purple-600 hover:bg-purple-50';
      mainCourtGrid.classList.add('hidden');
      mainCourtList.classList.remove('hidden');
    }
    applyFilters();
  }

  // RENDER DYNAMIC LISTS
  function renderCourts(courts) {
    const grid = document.getElementById('mainCourtGrid');
    const listBody = document.getElementById('courtListTableBody');
    const emptyState = document.getElementById('emptyState');

    if (courts.length === 0) {
      grid.classList.add('hidden');
      document.getElementById('mainCourtList').classList.add('hidden');
      emptyState.classList.remove('hidden');
      return;
    } else {
      emptyState.classList.add('hidden');
      if (viewMode === 'grid') grid.classList.remove('hidden');
      else document.getElementById('mainCourtList').classList.remove('hidden');
    }

    // Render Grid
    grid.innerHTML = courts.map(c => {
      const type = mockLoaiSan.find(t => t.id === c.typeId) || {};
      const sport = mockSports.find(s => s.id === type.sportId) || {};
      const defaultImg = sportImages[type.sportId] || sportImages[1];
      const img = c.image && c.image.trim() ? c.image : defaultImg;
      
      let badgeColor = 'badge-purple';
      if (c.status === 'Sẵn sàng') badgeColor = 'badge-green';
      else if (c.status === 'Đang dùng') badgeColor = 'badge-blue';
      else if (c.status === 'Bảo trì') badgeColor = 'badge-amber';
      else if (c.status === 'Tạm đóng') badgeColor = 'badge-red';

      return `
        <div class="card card-hover overflow-hidden flex flex-col">
          <div class="relative h-40 bg-zinc-100">
            <img src="\${img}" class="w-full h-full object-cover" alt="\${c.name}">
            <div class="absolute top-3 right-3">
              <span class="badge \${badgeColor}">\${c.status}</span>
            </div>
            <div class="absolute bottom-3 left-3 bg-black/60 backdrop-blur-sm px-2 py-0.5 rounded text-[10px] font-bold text-white flex items-center gap-1 uppercase">
              <span class="material-symbols-outlined text-[12px]">\${sport.icon || 'sports'}</span>\${sport.name || 'Bộ môn'}
            </div>
          </div>
          <div class="p-4 flex-1 flex flex-col gap-3">
            <div>
              <h4 class="font-bold text-purple-950 text-sm tracking-tight">\${c.name}</h4>
              <p class="text-[10px] text-purple-500 font-semibold mt-0.5">\${type.name || 'Loại sân'}</p>
            </div>
            <div class="text-[11px] text-zinc-500 space-y-1 bg-purple-50/30 p-2.5 rounded-xl border border-purple-50/50">
              <div class="flex justify-between"><span>Giá ngày:</span><span class="font-bold text-zinc-800">\${formatCurrency(type.priceNoLight || 0)}</span></div>
              <div class="flex justify-between"><span>Giá tối:</span><span class="font-bold text-purple-700">\${formatCurrency(type.priceWithLight || 0)} (\${type.lightStart || '17:30'} - \${type.lightEnd || '22:00'})</span></div>
            </div>
            <p class="text-xs text-zinc-500 line-clamp-2 mt-1 min-h-[2rem]">\${c.desc || 'Không có mô tả chi tiết cho sân đấu này.'}</p>
            <div class="flex items-center gap-1.5 mt-auto pt-3 border-t border-purple-50">
              <button onclick="openEditModal(\${c.id})" class="flex-1 h-8 text-[11px] font-bold text-purple-700 bg-purple-50 hover:bg-purple-100 rounded-lg flex items-center justify-center gap-1 transition-colors">
                <span class="material-symbols-outlined text-[13px]">edit</span>Sửa
              </button>
              <button onclick="openPriceConfigModal(\${c.id})" class="flex-1 h-8 text-[11px] font-bold text-emerald-700 bg-emerald-50 hover:bg-emerald-100 rounded-lg flex items-center justify-center gap-1 transition-colors">
                <span class="material-symbols-outlined text-[13px]">payments</span>Cấu hình giá
              </button>
              <button onclick="deleteCourt(\${c.id})" class="h-8 w-8 text-red-500 hover:bg-red-50 rounded-lg flex items-center justify-center transition-colors">
                <span class="material-symbols-outlined text-[16px]">delete</span>
              </button>
            </div>
          </div>
        </div>
      `;
    }).join('');

    // Render List
    listBody.innerHTML = courts.map(c => {
      const type = mockLoaiSan.find(t => t.id === c.typeId) || {};
      const sport = mockSports.find(s => s.id === type.sportId) || {};
      
      let badgeColor = 'badge-purple';
      if (c.status === 'Sẵn sàng') badgeColor = 'badge-green';
      else if (c.status === 'Đang dùng') badgeColor = 'badge-blue';
      else if (c.status === 'Bảo trì') badgeColor = 'badge-amber';
      else if (c.status === 'Tạm đóng') badgeColor = 'badge-red';

      return `
        <tr class="hover:bg-purple-50/20 transition-colors">
          <td class="px-5 py-4 font-mono font-bold text-purple-900">\${c.code}</td>
          <td class="px-5 py-4 font-bold text-zinc-800">\${c.name}</td>
          <td class="px-5 py-4">
            <div class="flex flex-col">
              <span class="font-semibold text-zinc-700">\${type.name || 'Loại sân'}</span>
              <span class="text-[10px] text-purple-500 mt-0.5 font-medium flex items-center gap-0.5">
                <span class="material-symbols-outlined text-[11px]">\${sport.icon || 'sports'}</span>\${sport.name || 'Bộ môn'}
              </span>
            </div>
          </td>
          <td class="px-5 py-4 font-medium">
            <span class="text-zinc-700 font-semibold">\${formatCurrency(type.priceNoLight || 0)}</span> / 
            <span class="text-purple-700 font-bold">\${formatCurrency(type.priceWithLight || 0)}</span>
          </td>
          <td class="px-5 py-4 text-zinc-500">\${type.lightStart || '17:30'} - \${type.lightEnd || '22:00'}</td>
          <td class="px-5 py-4"><span class="badge \${badgeColor}">\${c.status}</span></td>
          <td class="px-5 py-4 text-right">
            <div class="flex items-center justify-end gap-1">
              <button onclick="openPriceConfigModal(\${c.id})" class="p-1 hover:bg-emerald-50 text-emerald-700 rounded-lg transition-colors" title="Cấu hình giá"><span class="material-symbols-outlined text-[16px]">payments</span></button>
              <button onclick="openEditModal(\${c.id})" class="p-1 hover:bg-purple-50 text-purple-700 rounded-lg transition-colors" title="Chỉnh sửa"><span class="material-symbols-outlined text-[16px]">edit</span></button>
              <button onclick="deleteCourt(\${c.id})" class="p-1 hover:bg-red-50 text-red-500 rounded-lg transition-colors" title="Xóa"><span class="material-symbols-outlined text-[16px]">delete</span></button>
            </div>
          </td>
        </tr>
      `;
    }).join('');

    // Update stats counters
    document.getElementById('statTotal').textContent = mockSan.length;
    document.getElementById('statReady').textContent = mockSan.filter(s => s.status === 'Sẵn sàng').length;
    document.getElementById('statMaintenance').textContent = mockSan.filter(s => s.status === 'Bảo trì').length;
    document.getElementById('statClosed').textContent = mockSan.filter(s => s.status === 'Tạm đóng').length;
  }

  function renderTypesList() {
    const listBody = document.getElementById('typeListTableBody');
    if (!listBody) return;
    
    listBody.innerHTML = mockLoaiSan.map(t => {
      const sport = mockSports.find(s => s.id === t.sportId) || {};
      return `
        <tr class="hover:bg-purple-50/20 transition-colors">
          <td class="px-5 py-4 font-mono font-bold text-purple-900">TYPE\${t.id}</td>
          <td class="px-5 py-4 font-bold text-zinc-800">\${t.name}</td>
          <td class="px-5 py-4">
            <span class="text-[10px] font-bold text-purple-700 bg-purple-50 px-2 py-0.5 rounded-full inline-flex items-center gap-1">
              <span class="material-symbols-outlined text-[11px]">\${sport.icon || 'sports'}</span>\${sport.name}
            </span>
          </td>
          <td class="px-5 py-4 font-semibold text-zinc-700">\${formatCurrency(t.priceNoLight)}</td>
          <td class="px-5 py-4 font-bold text-purple-700">\${formatCurrency(t.priceWithLight)}</td>
          <td class="px-5 py-4 text-zinc-500 font-semibold">\${t.lightStart}</td>
          <td class="px-5 py-4 text-zinc-500 font-semibold">\${t.lightEnd || 'Chưa thiết lập'}</td>
          <td class="px-5 py-4 text-right">
            <div class="flex items-center justify-end gap-1">
              <button onclick="openEditTypeModal(\${t.id})" class="p-1 hover:bg-purple-50 text-purple-700 rounded-lg transition-colors"><span class="material-symbols-outlined text-[16px]">edit</span></button>
              <button onclick="deleteType(\${t.id})" class="p-1 hover:bg-red-50 text-red-500 rounded-lg transition-colors"><span class="material-symbols-outlined text-[16px]">delete</span></button>
            </div>
          </td>
        </tr>
      `;
    }).join('');
  }

  // FILTERING LOGIC
  function applyFilters() {
    const sportFilter = document.getElementById('filterType').value;
    const statusFilter = document.getElementById('filterStatus').value;
    const searchVal = document.getElementById('searchInput').value.toLowerCase().trim();

    let filtered = mockSan;

    // Filter by sport (via LoaiSan)
    if (sportFilter !== 'all') {
      const allowedTypeIds = mockLoaiSan.filter(t => t.sportId == sportFilter).map(t => t.id);
      filtered = filtered.filter(c => allowedTypeIds.includes(c.typeId));
    }

    // Filter by status
    if (statusFilter !== 'all') {
      filtered = filtered.filter(c => c.status === statusFilter);
    }

    // Filter by search query
    if (searchVal) {
      filtered = filtered.filter(c => c.name.toLowerCase().includes(searchVal));
    }

    renderCourts(filtered);
  }

  // COURT MODAL ACTIONS
  function openCreateModal() {
    document.getElementById('courtForm').reset();
    document.getElementById('courtModalTitle').textContent = 'Thêm sân thi đấu mới';
    document.getElementById('courtAction').value = 'add';
    document.getElementById('courtEditId').value = '';
    populateCourtTypeDropdown();
    document.getElementById('courtModal').classList.remove('hidden');
  }

  function openEditModal(id) {
    const c = mockSan.find(x => x.id === id);
    if (!c) return;

    document.getElementById('courtModalTitle').textContent = 'Chỉnh sửa sân thi đấu';
    document.getElementById('courtAction').value = 'update';
    document.getElementById('courtEditId').value = c.id;
    document.getElementById('courtName').value = c.name;
    document.getElementById('courtStatus').value = c.status;
    document.getElementById('courtDesc').value = c.desc || '';
    document.getElementById('courtImage').value = c.image || '';

    populateCourtTypeDropdown();
    document.getElementById('courtTypeSelect').value = c.typeId;

    document.getElementById('courtModal').classList.remove('hidden');
  }

  function closeCourtModal() {
    document.getElementById('courtModal').classList.add('hidden');
  }

  function deleteCourt(id) {
    if (confirm("Chuyển trạng thái sân này sang Tạm đóng (xóa mềm)?")) {
      const form = document.createElement('form');
      form.method = 'POST';
      form.action = '${pageContext.request.contextPath}/manager/quan-ly-san';
      
      const act = document.createElement('input'); act.type = 'hidden'; act.name = 'action'; act.value = 'delete';
      const sId = document.createElement('input'); sId.type = 'hidden'; sId.name = 'sanID'; sId.value = id;
      
      form.appendChild(act);
      form.appendChild(sId);
      document.body.appendChild(form);
      form.submit();
    }
  }

  // TYPE MODAL ACTIONS
  function openCreateTypeModal() {
    document.getElementById('typeForm').reset();
    document.getElementById('typeModalTitle').textContent = 'Thêm loại cấu hình sân mới';
    document.getElementById('typeAction').value = 'addType';
    document.getElementById('typeEditId').value = '';
    document.getElementById('typeModal').classList.remove('hidden');
  }

  function openEditTypeModal(id) {
    const t = mockLoaiSan.find(x => x.id === id);
    if (!t) return;

    document.getElementById('typeModalTitle').textContent = 'Chỉnh sửa loại cấu hình sân';
    document.getElementById('typeAction').value = 'updateType';
    document.getElementById('typeEditId').value = t.id;
    document.getElementById('typeSportSelect').value = t.sportId;
    document.getElementById('typeName').value = t.name;
    
    // Format values with commas for currency inputs
    document.getElementById('typePriceNoLight').value = t.priceNoLight.toLocaleString('en-US');
    document.getElementById('typePriceWithLight').value = t.priceWithLight.toLocaleString('en-US');
    
    // Set time format
    let timeStr = t.lightStart;
    if (timeStr && timeStr.length > 5) timeStr = timeStr.substring(0, 5); // HH:mm:ss -> HH:mm
    document.getElementById('typeLightStart').value = timeStr;

    let endTimeStr = t.lightEnd;
    if (endTimeStr && endTimeStr.length > 5) endTimeStr = endTimeStr.substring(0, 5);
    document.getElementById('typeLightEnd').value = endTimeStr || '22:00';

    document.getElementById('typeModal').classList.remove('hidden');
  }

  function closeTypeModal() {
    document.getElementById('typeModal').classList.add('hidden');
  }

  function deleteType(id) {
    if (confirm("Xóa cấu hình loại sân này?")) {
      const form = document.createElement('form');
      form.method = 'POST';
      form.action = '${pageContext.request.contextPath}/manager/quan-ly-san';
      
      const act = document.createElement('input'); act.type = 'hidden'; act.name = 'action'; act.value = 'deleteType';
      const tId = document.createElement('input'); tId.type = 'hidden'; tId.name = 'loaiSanID'; sId = id; tId.value = id;
      
      form.appendChild(act);
      form.appendChild(tId);
      document.body.appendChild(form);
      form.submit();
    }
  }

  // Form submit preprocessing to remove commas from currency values
  document.getElementById('typeForm').addEventListener('submit', function() {
    const priceNoLight = document.getElementById('typePriceNoLight');
    const priceWithLight = document.getElementById('typePriceWithLight');
    
    priceNoLight.value = priceNoLight.value.replace(/,/g, '');
    priceWithLight.value = priceWithLight.value.replace(/,/g, '');
  });

  // PRICE CONFIG MODAL ACTIONS
  function openPriceConfigModal(courtId) {
    const c = mockSan.find(x => x.id === courtId);
    if (!c) return;
    const type = mockLoaiSan.find(t => t.id === c.typeId);
    if (!type) return;

    document.getElementById('priceConfigModalTitle').textContent = `Cấu hình giá — \${c.name}`;
    document.getElementById('priceConfigModalSubtitle').textContent = `Thiết lập đơn giá cho loại sân: \${type.name}`;
    
    document.getElementById('priceConfigLoaiSanId').value = type.id;
    document.getElementById('priceConfigSportId').value = type.sportId;
    document.getElementById('priceConfigTypeName').value = type.name;

    // Currency values
    document.getElementById('priceConfigPriceNoLight').value = type.priceNoLight.toLocaleString('en-US');
    document.getElementById('priceConfigPriceWithLight').value = type.priceWithLight.toLocaleString('en-US');

    // Time value
    let timeStr = type.lightStart;
    if (timeStr && timeStr.length > 5) timeStr = timeStr.substring(0, 5);
    document.getElementById('priceConfigLightStart').value = timeStr;

    let endTimeStr = type.lightEnd;
    if (endTimeStr && endTimeStr.length > 5) endTimeStr = endTimeStr.substring(0, 5);
    document.getElementById('priceConfigLightEnd').value = endTimeStr || '22:00';

    // List shared courts
    const sharedCourts = mockSan.filter(x => x.typeId === type.id);
    const sharedNames = sharedCourts.map(x => x.name).join(', ');
    document.getElementById('sharedCourtsList').textContent = sharedNames;

    document.getElementById('priceConfigModal').classList.remove('hidden');
  }

  function closePriceConfigModal() {
    document.getElementById('priceConfigModal').classList.add('hidden');
  }

  // Preprocessing for priceConfigForm submit to strip commas
  document.getElementById('priceConfigForm').addEventListener('submit', function() {
    const priceNoLight = document.getElementById('priceConfigPriceNoLight');
    const priceWithLight = document.getElementById('priceConfigPriceWithLight');
    priceNoLight.value = priceNoLight.value.replace(/,/g, '');
    priceWithLight.value = priceWithLight.value.replace(/,/g, '');
  });

  // INITIALIZATION ON LOAD
  document.addEventListener('DOMContentLoaded', () => {
    initCurrencyFormatter('typePriceNoLight');
    initCurrencyFormatter('typePriceWithLight');
    initCurrencyFormatter('priceConfigPriceNoLight');
    initCurrencyFormatter('priceConfigPriceWithLight');
    populateSportDropdowns();
    switchTab('courts'); // sets default view and triggers rendering
  });
</script>
</body>
</html>
