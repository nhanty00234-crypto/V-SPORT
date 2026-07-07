<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
<title>${pageTitle}</title>
<jsp:include page="/manager/common/manager_head.jsp" />
<style>
  /* ── Page-specific overrides ── */
  .stat-card { background:#fff; border:1px solid #ede9fe; border-radius:16px; padding:20px; transition:box-shadow .2s,transform .15s; }
  .stat-card:hover { box-shadow:0 8px 24px -8px rgba(124,58,237,.12); transform:translateY(-2px); }
  .stat-icon { width:44px; height:44px; border-radius:12px; display:flex; align-items:center; justify-content:center; flex-shrink:0; }
  .form-input { height:38px; width:100%; padding:0 12px; border-radius:8px; border:1px solid #ede9fe; font-size:13px; color:#18181b; background:#fff; transition:border-color .15s,box-shadow .15s; outline:none; }
  .form-input:focus { border-color:#7c3aed; box-shadow:0 0 0 3px rgba(124,58,237,.1); }
  .form-select { height:38px; padding:0 30px 0 11px; border-radius:8px; border:1px solid #ede9fe; font-size:13px; color:#18181b; background:#fff url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='14' height='14' viewBox='0 0 24 24' fill='none' stroke='%23a1a1aa' stroke-width='2'%3E%3Cpath d='m6 9 6 6 6-6'/%3E%3C/svg%3E") no-repeat right 10px center; appearance:none; outline:none; transition:border-color .15s; cursor:pointer; }
  .form-select:focus { border-color:#7c3aed; }
  .btn-primary { display:inline-flex; align-items:center; gap:6px; height:38px; padding:0 16px; border-radius:9px; background:#7c3aed; color:#fff; font-size:13px; font-weight:700; border:none; cursor:pointer; box-shadow:0 2px 8px -2px rgba(124,58,237,.3); transition:background .15s; }
  .btn-primary:hover { background:#6d28d9; }
  .btn-secondary { display:inline-flex; align-items:center; gap:6px; height:38px; padding:0 14px; border-radius:9px; background:#ede9fe; color:#6d28d9; font-size:13px; font-weight:700; border:1px solid #ddd6fe; cursor:pointer; transition:background .15s; }
  .btn-secondary:hover { background:#ddd6fe; }
  .btn-ghost { display:inline-flex; align-items:center; gap:6px; height:38px; padding:0 14px; border-radius:9px; background:#fff; color:#3f3f46; font-size:13px; font-weight:600; border:1px solid #e4e4e7; cursor:pointer; transition:background .15s; }
  .btn-ghost:hover { background:#f4f4f5; }
  .modal-overlay { position:fixed; inset:0; background:rgba(9,9,11,.5); backdrop-filter:blur(4px); z-index:50; }
  .modal-box { background:#fff; border-radius:20px; box-shadow:0 24px 64px -12px rgba(0,0,0,.18); border:1px solid #e4e4e7; animation:pop .2s ease both; }
  .modal-header { display:flex; align-items:center; justify-content:space-between; padding:20px 24px; border-bottom:1px solid #f4f4f5; }
  .modal-icon { width:40px; height:40px; border-radius:12px; display:flex; align-items:center; justify-content:center; flex-shrink:0; }
  .modal-close { width:32px; height:32px; border-radius:50%; border:none; background:transparent; display:flex; align-items:center; justify-content:center; color:#a1a1aa; cursor:pointer; }
  .modal-close:hover { background:#f4f4f5; color:#52525b; }
  .field-label { display:block; font-size:11.5px; font-weight:700; color:#52525b; margin-bottom:5px; letter-spacing:.01em; }
  .field-req { color:#ef4444; }
  .section-sep { font-size:10.5px; font-weight:800; color:#a1a1aa; text-transform:uppercase; letter-spacing:.07em; padding:4px 0 10px; display:flex; align-items:center; gap:6px; }
  .section-sep::after { content:''; flex:1; height:1px; background:#f4f4f5; }
  tr.row-hover:hover td { background:#faf5ff; }
  .stock-bar { height:3px; border-radius:2px; background:#f4f4f5; overflow:hidden; margin-top:3px; }
  .stock-bar-fill { height:100%; border-radius:2px; transition:width .4s; }
  @keyframes pop { from{opacity:0;transform:scale(.96)} to{opacity:1;transform:scale(1)} }
</style>
</head>
<body class="text-zinc-900 min-h-screen">

<jsp:include page="/manager/common/sidebar.jsp" />

<c:set var="headerTitle" value="Kho & Dịch vụ" scope="page" />
<c:set var="headerSubtitle" value="Chi nhánh CS${sessionScope.user.coSoId}" scope="page" />
<c:set var="headerIcon" value="inventory_2" scope="page" />
<jsp:include page="/manager/common/header.jsp" />

<main class="lg:ml-[248px] mt-[64px] p-4 lg:p-6 flex flex-col gap-5">

  <%-- ── A. STATUS ALERTS ── --%>
  <c:if test="${not empty successMsg}">
    <div class="flex items-center gap-3 p-4 bg-green-50 border border-green-200 text-green-800 rounded-xl animation-fadeUp">
      <span class="material-symbols-outlined text-green-600 text-[18px]" style="font-variation-settings:'FILL' 1">check_circle</span>
      <p class="text-sm font-medium">${successMsg}</p>
    </div>
  </c:if>
  <c:if test="${not empty errorMsg}">
    <div class="flex items-center gap-3 p-4 bg-red-50 border border-red-200 text-red-800 rounded-xl animation-fadeUp">
      <span class="material-symbols-outlined text-red-600 text-[18px]" style="font-variation-settings:'FILL' 1">error</span>
      <p class="text-sm font-medium">${errorMsg}</p>
    </div>
  </c:if>

  <%-- ── B. PAGE HEADER ── --%>
  <section>
    <nav class="flex items-center gap-1.5 text-xs text-zinc-400 mb-3 select-none">
      <span class="material-symbols-outlined text-[12px]">home</span>
      <span class="material-symbols-outlined text-[12px]">chevron_right</span>
      <span>Kinh doanh & Dịch vụ</span>
      <span class="material-symbols-outlined text-[12px]">chevron_right</span>
      <span class="font-semibold text-zinc-700">Kho & Dịch vụ</span>
    </nav>
    <div class="flex items-start justify-between gap-4 flex-wrap">
      <div>
        <h1 class="text-2xl font-bold text-zinc-900 tracking-tight">Kho &amp; Dịch vụ</h1>
        <p class="text-sm text-zinc-500 mt-1">Quản lý mặt hàng, dịch vụ bán tại chi nhánh và theo dõi tồn kho.</p>
      </div>
      <div class="flex items-center gap-1.5 px-3 py-2 bg-green-50 rounded-xl border border-green-100 shrink-0">
        <span class="w-2 h-2 rounded-full bg-green-500 live-dot shrink-0"></span>
        <span class="text-xs font-semibold text-green-700">CS${sessionScope.user.coSoId} — Đang hoạt động</span>
      </div>
    </div>
  </section>

  <%-- ── C. STAT CARDS ── --%>
  <section class="grid grid-cols-2 lg:grid-cols-4 gap-4 stagger">
    <div class="stat-card">
      <div class="flex items-start justify-between mb-4">
        <div class="stat-icon bg-violet-50"><span class="material-symbols-outlined text-violet-600 text-[22px]" style="font-variation-settings:'FILL' 1">inventory_2</span></div>
      </div>
      <p class="text-3xl font-black text-zinc-900 leading-none">${totalItems}</p>
      <p class="text-sm font-semibold text-zinc-600 mt-1.5">Tổng mặt hàng</p>
      <p class="text-xs text-zinc-400 mt-0.5">SKU đang quản lý</p>
    </div>

    <div class="stat-card">
      <div class="flex items-start justify-between mb-4">
        <div class="stat-icon bg-green-50"><span class="material-symbols-outlined text-green-600 text-[22px]" style="font-variation-settings:'FILL' 1">payments</span></div>
      </div>
      <p class="text-3xl font-black text-green-700 leading-none">
        <fmt:formatNumber value="${totalInventoryValue / 1000}" pattern="#,##0"/>K
      </p>
      <p class="text-sm font-semibold text-zinc-600 mt-1.5">Giá trị tồn kho</p>
      <p class="text-xs text-zinc-400 mt-0.5">đồng tổng giá trị</p>
    </div>

    <div class="stat-card">
      <div class="flex items-start justify-between mb-4">
        <div class="stat-icon bg-amber-50"><span class="material-symbols-outlined text-amber-500 text-[22px]" style="font-variation-settings:'FILL' 1">production_quantity_limits</span></div>
        <c:if test="${lowStockCount > 0}"><span class="w-2 h-2 rounded-full bg-amber-400 mt-1 live-dot"></span></c:if>
      </div>
      <p class="text-3xl font-black ${lowStockCount > 0 ? 'text-amber-600' : 'text-zinc-900'} leading-none">${lowStockCount}</p>
      <p class="text-sm font-semibold text-zinc-600 mt-1.5">Sắp hết hàng</p>
      <p class="text-xs text-zinc-400 mt-0.5">${lowStockCount > 0 ? 'Cần bổ sung sớm' : 'Tồn kho ổn định'}</p>
    </div>

    <div class="stat-card">
      <div class="flex items-start justify-between mb-4">
        <div class="stat-icon bg-red-50"><span class="material-symbols-outlined text-red-500 text-[22px]" style="font-variation-settings:'FILL' 1">remove_shopping_cart</span></div>
        <c:if test="${outOfStockCount > 0}"><span class="w-2 h-2 rounded-full bg-red-500 mt-1 live-dot"></span></c:if>
      </div>
      <p class="text-3xl font-black ${outOfStockCount > 0 ? 'text-red-600' : 'text-zinc-900'} leading-none">${outOfStockCount}</p>
      <p class="text-sm font-semibold text-zinc-600 mt-1.5">Đã hết hàng</p>
      <p class="text-xs text-zinc-400 mt-0.5">${outOfStockCount > 0 ? 'Cần nhập ngay' : 'Không có hết hàng'}</p>
    </div>
  </section>

  <%-- ── D. ACTION BAR ── --%>
  <section class="bg-white border border-violet-100 rounded-2xl p-4 shadow-sm">
    <form action="${pageContext.request.contextPath}/manager/kho-dich-vu" method="GET">
      <div class="flex flex-col lg:flex-row items-start lg:items-center gap-3">
        <%-- Left: search + filters --%>
        <div class="flex items-center gap-2.5 flex-wrap flex-1 w-full">
          <div class="relative flex-1 min-w-[200px]">
            <span class="absolute left-3 top-1/2 -translate-y-1/2 material-symbols-outlined text-[16px] text-zinc-400 pointer-events-none">search</span>
            <input type="search" name="search" value="${search}" autocomplete="off"
                   placeholder="Tìm mặt hàng theo tên hoặc mã SKU..."
                   class="form-input pl-9 bg-zinc-50/50">
          </div>
          <select name="category" class="form-select">
            <option value="">Tất cả nhóm dịch vụ</option>
            <c:forEach items="${categories}" var="cat">
              <option value="${cat.danhMucID}" ${selectedCategory == cat.danhMucID ? 'selected' : ''}>${cat.tenDanhMuc}</option>
            </c:forEach>
          </select>
          <select name="status" class="form-select">
            <option value="">Tất cả trạng thái</option>
            <option value="Đang kinh doanh" ${selectedStatus == 'Đang kinh doanh' ? 'selected' : ''}>Đang kinh doanh</option>
            <option value="Tạm hết hàng"    ${selectedStatus == 'Tạm hết hàng'    ? 'selected' : ''}>Tạm hết hàng</option>
            <option value="Ngừng kinh doanh" ${selectedStatus == 'Ngừng kinh doanh'? 'selected' : ''}>Ngừng kinh doanh</option>
          </select>
          <div class="flex items-center gap-2">
            <button type="submit" class="btn-ghost text-sm">
              <span class="material-symbols-outlined text-[16px]">filter_list</span>Lọc
            </button>
            <a href="${pageContext.request.contextPath}/manager/kho-dich-vu" class="btn-ghost text-sm" title="Xóa bộ lọc">
              <span class="material-symbols-outlined text-[16px]">restart_alt</span>
            </a>
          </div>
        </div>
        <%-- Right: action buttons --%>
        <div class="flex items-center gap-2 shrink-0 flex-wrap">
          <button type="button" onclick="openCategoryModal()" class="btn-ghost text-sm">
            <span class="material-symbols-outlined text-[16px]">category</span>
            <span class="hidden sm:inline">Quản lý nhóm dịch vụ</span>
          </button>
          <button type="button" onclick="openPresetModal()" class="btn-secondary text-sm">
            <span class="material-symbols-outlined text-[16px]">bolt</span>
            <span class="hidden sm:inline">Thêm nhanh từ mẫu</span>
          </button>
          <button type="button" onclick="openAddModal()" class="btn-primary text-sm">
            <span class="material-symbols-outlined text-[16px]">add</span>Thêm mặt hàng mới
          </button>
        </div>
      </div>
    </form>

    <%-- Result count + helper strip --%>
    <div class="mt-3.5 pt-3.5 border-t border-violet-50 flex flex-col sm:flex-row sm:items-center justify-between gap-3">
      <p class="text-xs text-zinc-500">Hiển thị <span class="font-bold text-violet-800">${productList.size()}</span> / <span class="font-bold text-zinc-700">${totalItems}</span> mặt hàng</p>
      <div class="flex items-start gap-2 text-[11px] text-zinc-500 flex-wrap">
        <span class="flex items-center gap-1"><span class="material-symbols-outlined text-[12px] text-zinc-400">category</span><strong class="text-zinc-700">Quản lý nhóm:</strong> Sắp xếp theo nhóm (Đồ uống, Thuê dụng cụ...).</span>
        <span class="hidden sm:inline text-zinc-200">·</span>
        <span class="flex items-center gap-1"><span class="material-symbols-outlined text-[12px] text-violet-500">bolt</span><strong class="text-zinc-700">Thêm nhanh:</strong> Tạo từ mẫu thường dùng.</span>
      </div>
    </div>
  </section>

  <%-- ── E. CONTENT ── --%>
  <c:choose>
    <c:when test="${totalItems == 0}">
      <%-- EMPTY STATE --%>
      <section class="bg-white rounded-2xl border border-dashed border-violet-200 py-20 px-8 flex flex-col items-center text-center reveal-on-scroll">
        <div class="w-20 h-20 rounded-2xl bg-violet-50 flex items-center justify-center mb-5">
          <span class="material-symbols-outlined text-violet-400 text-[44px]" style="font-variation-settings:'FILL' 1">inventory_2</span>
        </div>
        <h3 class="text-xl font-bold text-zinc-900 mb-2">Kho dịch vụ chưa có mặt hàng nào</h3>
        <p class="text-sm text-zinc-500 max-w-sm mb-2">Bạn có thể thêm các dịch vụ bán tại sân như nước uống, thuê vợt, thuê bóng hoặc khăn để quản lý doanh thu tiện ích.</p>
        <p class="text-xs text-zinc-400 mb-8 italic">Ví dụ: Nước suối, nước ngọt, thuê vợt, thuê bóng, khăn lạnh.</p>
        <div class="flex items-center gap-3 flex-wrap justify-center">
          <button onclick="openPresetModal()" class="btn-secondary">
            <span class="material-symbols-outlined text-[16px]">bolt</span>Thêm nhanh từ mẫu có sẵn
          </button>
          <button onclick="openAddModal()" class="btn-primary">
            <span class="material-symbols-outlined text-[16px]">add</span>Thêm mặt hàng mới
          </button>
        </div>
        <c:if test="${empty categories}">
          <div class="mt-6 pt-5 border-t border-zinc-100 w-full max-w-xs">
            <p class="text-xs text-amber-600 font-medium flex items-center gap-1.5 justify-center mb-2">
              <span class="material-symbols-outlined text-[14px]">warning</span>
              Nên tạo nhóm dịch vụ trước để phân loại mặt hàng.
            </p>
            <button onclick="openCategoryModal()" class="text-xs font-bold text-violet-700 hover:underline flex items-center gap-1 mx-auto">
              <span class="material-symbols-outlined text-[13px]">category</span>Quản lý nhóm dịch vụ →
            </button>
          </div>
        </c:if>
      </section>
    </c:when>
    <c:when test="${empty productList}">
      <%-- NO FILTER RESULTS --%>
      <section class="bg-white rounded-2xl border border-zinc-200 py-14 flex flex-col items-center text-center">
        <span class="material-symbols-outlined text-[48px] text-zinc-300 mb-3">search_off</span>
        <h3 class="text-sm font-semibold text-zinc-700">Không tìm thấy mặt hàng nào</h3>
        <p class="text-xs text-zinc-400 mt-1">Thử thay đổi từ khóa hoặc bộ lọc của bạn.</p>
        <a href="${pageContext.request.contextPath}/manager/kho-dich-vu" class="mt-4 text-xs text-violet-600 font-semibold underline">Xóa tất cả bộ lọc</a>
      </section>
    </c:when>
    <c:otherwise>
      <%-- PRODUCT TABLE --%>
      <section class="bg-white rounded-2xl border border-violet-100 overflow-hidden shadow-sm reveal-on-scroll">
        <div class="overflow-x-auto">
          <table class="w-full text-left text-xs">
            <thead class="bg-violet-50/60 border-b border-violet-100">
              <tr>
                <th class="px-4 py-3.5 text-[10.5px] font-bold text-zinc-500 uppercase tracking-wide w-24">SKU / Mã</th>
                <th class="px-4 py-3.5 text-[10.5px] font-bold text-zinc-500 uppercase tracking-wide">Tên mặt hàng</th>
                <th class="px-4 py-3.5 text-[10.5px] font-bold text-zinc-500 uppercase tracking-wide hidden sm:table-cell">Nhóm dịch vụ</th>
                <th class="px-4 py-3.5 text-[10.5px] font-bold text-zinc-500 uppercase tracking-wide text-right hidden md:table-cell">Giá nhập</th>
                <th class="px-4 py-3.5 text-[10.5px] font-bold text-zinc-500 uppercase tracking-wide text-right hidden md:table-cell">Giá bán lẻ</th>
                <th class="px-4 py-3.5 text-[10.5px] font-bold text-zinc-500 uppercase tracking-wide text-right">Tồn kho</th>
                <th class="px-4 py-3.5 text-[10.5px] font-bold text-zinc-500 uppercase tracking-wide">Trạng thái</th>
                <th class="px-4 py-3.5 text-[10.5px] font-bold text-zinc-500 uppercase tracking-wide text-right w-28">Thao tác</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-violet-50/80">
              <c:forEach items="${productList}" var="sp">
                <c:set var="isOut" value="${sp.soLuongTon == 0}" />
                <c:set var="isLow" value="${sp.soLuongTon > 0 and sp.soLuongTon <= 5}" />
                <tr class="row-hover transition-colors">
                  <td class="px-4 py-3.5 font-mono text-[11px] text-zinc-500 font-semibold">${sp.skuCode != null ? sp.skuCode : 'N/A'}</td>
                  <td class="px-4 py-3.5">
                    <div class="flex items-center gap-3">
                      <div class="w-10 h-10 rounded-xl overflow-hidden bg-violet-50 border border-violet-100/60 shrink-0 flex items-center justify-center">
                        <c:set var="imgUrl" value="https://images.unsplash.com/photo-1517649763962-0c623066013b?w=80&auto=format&fit=crop&q=60"/>
                        <c:choose>
                          <c:when test="${fn:containsIgnoreCase(sp.tenSanPham, 'Aquafina')}"><c:set var="imgUrl" value="https://images.unsplash.com/photo-1608885898957-a599fb18de3e?w=80&auto=format&fit=crop&q=60"/></c:when>
                          <c:when test="${fn:containsIgnoreCase(sp.tenSanPham, 'Pocari')}"><c:set var="imgUrl" value="https://images.unsplash.com/photo-1548839140-29a749e1cf4d?w=80&auto=format&fit=crop&q=60"/></c:when>
                          <c:when test="${fn:containsIgnoreCase(sp.tenSanPham, 'Revive') or fn:containsIgnoreCase(sp.tenSanPham, 'Redbull') or fn:containsIgnoreCase(sp.tenSanPham, 'Nước')}"><c:set var="imgUrl" value="https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=80&auto=format&fit=crop&q=60"/></c:when>
                          <c:when test="${fn:containsIgnoreCase(sp.tenSanPham, 'Yonex') or fn:containsIgnoreCase(sp.tenSanPham, 'Vợt')}"><c:set var="imgUrl" value="https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=80&auto=format&fit=crop&q=60"/></c:when>
                          <c:when test="${fn:containsIgnoreCase(sp.tenSanPham, 'Giày')}"><c:set var="imgUrl" value="https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=80&auto=format&fit=crop&q=60"/></c:when>
                          <c:when test="${fn:containsIgnoreCase(sp.tenSanPham, 'Tất') or fn:containsIgnoreCase(sp.tenSanPham, 'Vớ')}"><c:set var="imgUrl" value="https://images.unsplash.com/photo-1582966772680-860e372bb558?w=80&auto=format&fit=crop&q=60"/></c:when>
                          <c:when test="${fn:containsIgnoreCase(sp.tenSanPham, 'Cầu lông') or fn:containsIgnoreCase(sp.tenSanPham, 'Quả cầu')}"><c:set var="imgUrl" value="https://images.unsplash.com/photo-1613918431201-496522c04e4e?w=80&auto=format&fit=crop&q=60"/></c:when>
                          <c:when test="${fn:containsIgnoreCase(sp.tenSanPham, 'VS') or fn:containsIgnoreCase(sp.tenSanPham, 'Quấn')}"><c:set var="imgUrl" value="https://images.unsplash.com/photo-1595257841889-ecea6a1d0543?w=80&auto=format&fit=crop&q=60"/></c:when>
                        </c:choose>
                        <img src="${imgUrl}" alt="${sp.tenSanPham}" class="w-full h-full object-cover">
                      </div>
                      <div>
                        <p class="font-semibold text-zinc-800 text-[13px]">${sp.tenSanPham}</p>
                        <c:if test="${not empty sp.moTa}">
                          <p class="text-[10px] text-zinc-400 mt-0.5 max-w-[200px] truncate">${sp.moTa}</p>
                        </c:if>
                      </div>
                    </div>
                  </td>
                  <td class="px-4 py-3.5 hidden sm:table-cell">
                    <c:forEach items="${categories}" var="cat">
                      <c:if test="${cat.danhMucID == sp.danhMucID}">
                        <span class="badge badge-purple text-[10.5px]">${cat.tenDanhMuc}</span>
                      </c:if>
                    </c:forEach>
                  </td>
                  <td class="px-4 py-3.5 text-right text-zinc-500 font-medium hidden md:table-cell">
                    <fmt:formatNumber value="${sp.giaNhap}" pattern="#,##0"/>đ
                  </td>
                  <td class="px-4 py-3.5 text-right font-bold text-zinc-900 hidden md:table-cell">
                    <fmt:formatNumber value="${sp.donGia}" pattern="#,##0"/>đ
                  </td>
                  <td class="px-4 py-3.5 text-right">
                    <p class="font-bold text-[13px] ${isOut ? 'text-red-600' : (isLow ? 'text-amber-600' : 'text-zinc-800')}">${sp.soLuongTon}</p>
                    <p class="text-[10px] text-zinc-400">${sp.donViTinh != null ? sp.donViTinh : 'cái'}</p>
                  </td>
                  <td class="px-4 py-3.5">
                    <span class="badge
                      <c:choose>
                        <c:when test="${sp.trangThai == 'Đang kinh doanh'}">badge-green</c:when>
                        <c:when test="${sp.trangThai == 'Tạm hết hàng'}">badge-amber</c:when>
                        <c:otherwise>badge-gray</c:otherwise>
                      </c:choose>
                    ">${sp.trangThai}</span>
                  </td>
                  <td class="px-4 py-3.5">
                    <div class="flex items-center justify-end gap-1">
                      <button onclick="openStockModal(${sp.sanPhamID}, '${sp.skuCode}', '${sp.tenSanPham}', ${sp.soLuongTon}, '${sp.donViTinh}')"
                              title="Nhập / Xuất kho"
                              class="w-8 h-8 rounded-lg hover:bg-violet-100 text-violet-700 flex items-center justify-center transition-colors">
                        <span class="material-symbols-outlined text-[17px]">inventory</span>
                      </button>
                      <button onclick="openEditModal(${sp.sanPhamID}, '${sp.skuCode}', '${sp.tenSanPham}', ${sp.danhMucID}, ${sp.donGia}, ${sp.giaNhap}, '${sp.donViTinh}', ${sp.soLuongTon}, '${sp.trangThai}', '${sp.moTa}')"
                              title="Chỉnh sửa"
                              class="w-8 h-8 rounded-lg hover:bg-zinc-100 text-zinc-500 flex items-center justify-center transition-colors">
                        <span class="material-symbols-outlined text-[17px]">edit</span>
                      </button>
                      <button onclick="confirmDelete(${sp.sanPhamID}, '${sp.tenSanPham}')"
                              title="Xóa"
                              class="w-8 h-8 rounded-lg hover:bg-red-50 text-red-400 flex items-center justify-center transition-colors">
                        <span class="material-symbols-outlined text-[17px]">delete</span>
                      </button>
                    </div>
                  </td>
                </tr>
              </c:forEach>
            </tbody>
          </table>
        </div>
      </section>
    </c:otherwise>
  </c:choose>

</main>

<%-- ═══════════════════════════════════════════
     MODAL 1: THÊM MẶT HÀNG MỚI
════════════════════════════════════════════ --%>
<div id="addModal" class="modal-overlay hidden z-[80] flex items-start justify-center p-4 pt-10 overflow-y-auto">
  <div class="modal-box relative w-full max-w-[640px] z-10">
    <div class="modal-header">
      <div class="flex items-center gap-3">
        <div class="modal-icon bg-violet-50"><span class="material-symbols-outlined text-violet-600 text-[22px]">inventory_2</span></div>
        <div>
          <h3 class="text-base font-bold text-zinc-900">Thêm mặt hàng mới</h3>
          <p class="text-xs text-zinc-400 mt-0.5">Tạo sản phẩm hoặc dịch vụ bán tại chi nhánh.</p>
        </div>
      </div>
      <button type="button" onclick="closeAddModal()" class="modal-close"><span class="material-symbols-outlined text-[18px]">close</span></button>
    </div>

    <form action="${pageContext.request.contextPath}/manager/kho-dich-vu" method="POST" class="px-6 py-5 flex flex-col gap-5">
      <input type="hidden" name="action" value="add">

      <%-- Group 1: Thông tin cơ bản --%>
      <div>
        <p class="section-sep"><span class="material-symbols-outlined text-[13px]">info</span>Thông tin cơ bản</p>
        <div class="grid grid-cols-2 gap-4">
          <div>
            <label class="field-label">Mã SKU</label>
            <div class="flex gap-2">
              <input type="text" id="addSkuCode" name="skuCode" placeholder="VD: NUOC-LAVIE-500" class="form-input flex-1 font-mono text-sm">
              <button type="button" onclick="regenerateAddSku()" title="Tạo mã ngẫu nhiên" class="h-[38px] w-10 border border-violet-100 rounded-lg hover:bg-violet-50 text-violet-500 flex items-center justify-center shrink-0">
                <span class="material-symbols-outlined text-[16px]">refresh</span>
              </button>
            </div>
          </div>
          <div>
            <label class="field-label">Tên mặt hàng <span class="field-req">*</span></label>
            <input type="text" name="tenSanPham" maxlength="100" required placeholder="Nước suối Lavie 500ml" class="form-input">
          </div>
          <div>
            <label class="field-label">Nhóm dịch vụ <span class="field-req">*</span></label>
            <select name="danhMucID" required class="form-select w-full">
              <option value="">-- Chọn nhóm --</option>
              <c:forEach items="${categories}" var="cat">
                <option value="${cat.danhMucID}">${cat.tenDanhMuc}</option>
              </c:forEach>
            </select>
          </div>
          <div>
            <label class="field-label">Đơn vị tính <span class="field-req">*</span></label>
            <input type="text" name="donViTinh" required placeholder="Chai / Lon / Lượt / Giờ" class="form-input">
          </div>
        </div>
      </div>

      <%-- Group 2: Giá & Tồn kho --%>
      <div>
        <p class="section-sep"><span class="material-symbols-outlined text-[13px]">payments</span>Giá &amp; Tồn kho</p>
        <div class="grid grid-cols-3 gap-4">
          <div>
            <label class="field-label">Giá nhập (đ) <span class="field-req">*</span></label>
            <input type="number" step="any" name="giaNhap" min="0" required placeholder="5000" class="form-input">
          </div>
          <div>
            <label class="field-label">Giá bán lẻ (đ) <span class="field-req">*</span></label>
            <input type="number" step="any" name="donGia" min="0" required placeholder="10000" class="form-input">
          </div>
          <div>
            <label class="field-label">Số lượng ban đầu</label>
            <input type="number" name="soLuongTon" value="0" min="0" class="form-input">
          </div>
        </div>
        <div class="mt-4">
          <label class="field-label">Trạng thái kinh doanh</label>
          <select name="trangThai" class="form-select w-full">
            <option value="Đang kinh doanh">Đang kinh doanh</option>
            <option value="Tạm hết hàng">Tạm hết hàng</option>
            <option value="Ngừng kinh doanh">Ngừng kinh doanh</option>
          </select>
        </div>
      </div>

      <%-- Group 3: Mô tả --%>
      <div>
        <label class="field-label">Mô tả mặt hàng</label>
        <input type="text" name="moTa" placeholder="Thông tin tóm tắt về mặt hàng..." class="form-input">
      </div>

      <div class="flex items-center justify-between pt-2 border-t border-zinc-100">
        <p class="text-xs text-zinc-400"><span class="text-red-400">*</span> Trường bắt buộc</p>
        <div class="flex gap-2.5">
          <button type="button" onclick="closeAddModal()" class="btn-ghost text-sm">Hủy</button>
          <button type="submit" class="btn-primary text-sm"><span class="material-symbols-outlined text-[16px]">save</span>Lưu mặt hàng</button>
        </div>
      </div>
    </form>
  </div>
</div>

<%-- ═══════════════════════════════════════════
     MODAL 2: CHỈNH SỬA MẶT HÀNG
════════════════════════════════════════════ --%>
<div id="editModal" class="modal-overlay hidden z-[80] flex items-start justify-center p-4 pt-10 overflow-y-auto">
  <div class="modal-box relative w-full max-w-[640px] z-10">
    <div class="modal-header">
      <div class="flex items-center gap-3">
        <div class="modal-icon bg-indigo-50"><span class="material-symbols-outlined text-indigo-600 text-[22px]">edit_square</span></div>
        <div>
          <h3 class="text-base font-bold text-zinc-900">Cập nhật mặt hàng</h3>
          <p class="text-xs text-zinc-400 mt-0.5">Chỉnh sửa thông tin mặt hàng trong kho.</p>
        </div>
      </div>
      <button type="button" onclick="closeEditModal()" class="modal-close"><span class="material-symbols-outlined text-[18px]">close</span></button>
    </div>

    <form action="${pageContext.request.contextPath}/manager/kho-dich-vu" method="POST" class="px-6 py-5 flex flex-col gap-5">
      <input type="hidden" name="action" value="update">
      <input type="hidden" id="editSanPhamID" name="sanPhamID">

      <div>
        <p class="section-sep"><span class="material-symbols-outlined text-[13px]">info</span>Thông tin cơ bản</p>
        <div class="grid grid-cols-2 gap-4">
          <div>
            <label class="field-label">Mã SKU <span class="field-req">*</span></label>
            <input type="text" id="editSkuCode" name="skuCode" required class="form-input font-mono text-sm">
          </div>
          <div>
            <label class="field-label">Tên mặt hàng <span class="field-req">*</span></label>
            <input type="text" id="editTenSanPham" name="tenSanPham" maxlength="100" required class="form-input">
          </div>
          <div>
            <label class="field-label">Nhóm dịch vụ <span class="field-req">*</span></label>
            <select id="editDanhMucID" name="danhMucID" required class="form-select w-full">
              <c:forEach items="${categories}" var="cat">
                <option value="${cat.danhMucID}">${cat.tenDanhMuc}</option>
              </c:forEach>
            </select>
          </div>
          <div>
            <label class="field-label">Đơn vị tính <span class="field-req">*</span></label>
            <input type="text" id="editDonViTinh" name="donViTinh" required class="form-input">
          </div>
        </div>
      </div>

      <div>
        <p class="section-sep"><span class="material-symbols-outlined text-[13px]">payments</span>Giá &amp; Tồn kho</p>
        <div class="grid grid-cols-3 gap-4">
          <div>
            <label class="field-label">Giá nhập (đ) <span class="field-req">*</span></label>
            <input type="number" step="any" id="editGiaNhap" name="giaNhap" min="0" required class="form-input">
          </div>
          <div>
            <label class="field-label">Giá bán lẻ (đ) <span class="field-req">*</span></label>
            <input type="number" step="any" id="editDonGia" name="donGia" min="0" required class="form-input">
          </div>
          <div>
            <label class="field-label">Tồn kho <span class="field-req">*</span></label>
            <input type="number" id="editSoLuongTon" name="soLuongTon" min="0" required class="form-input">
          </div>
        </div>
        <div class="mt-4">
          <label class="field-label">Trạng thái kinh doanh</label>
          <select id="editTrangThai" name="trangThai" class="form-select w-full">
            <option value="Đang kinh doanh">Đang kinh doanh</option>
            <option value="Tạm hết hàng">Tạm hết hàng</option>
            <option value="Ngừng kinh doanh">Ngừng kinh doanh</option>
          </select>
        </div>
      </div>

      <div>
        <label class="field-label">Mô tả mặt hàng</label>
        <input type="text" id="editMoTa" name="moTa" class="form-input">
      </div>

      <div class="flex justify-end gap-2.5 pt-2 border-t border-zinc-100">
        <button type="button" onclick="closeEditModal()" class="btn-ghost text-sm">Hủy</button>
        <button type="submit" class="btn-primary text-sm" style="background:#4f46e5"><span class="material-symbols-outlined text-[16px]">save</span>Lưu thay đổi</button>
      </div>
    </form>
  </div>
</div>

<%-- ═══════════════════════════════════════════
     MODAL 3: NHẬP / XUẤT KHO
════════════════════════════════════════════ --%>
<div id="stockModal" class="modal-overlay hidden z-[80] flex items-center justify-center p-4">
  <div class="modal-box relative w-full max-w-[400px] z-10">
    <div class="modal-header">
      <div class="flex items-center gap-3">
        <div class="modal-icon bg-zinc-100"><span class="material-symbols-outlined text-zinc-600 text-[22px]">published_with_changes</span></div>
        <h3 class="text-base font-bold text-zinc-900">Điều chỉnh kho</h3>
      </div>
      <button type="button" onclick="closeStockModal()" class="modal-close"><span class="material-symbols-outlined text-[18px]">close</span></button>
    </div>

    <div class="px-6 py-4 bg-zinc-50 border-b border-zinc-100">
      <p class="text-[10px] font-bold uppercase tracking-wider text-zinc-400 mb-0.5">Mặt hàng được chọn</p>
      <p class="font-bold text-zinc-800 text-sm" id="stockProdName">—</p>
      <div class="flex gap-4 mt-1 text-xs text-zinc-500">
        <span>SKU: <span class="font-mono font-bold text-zinc-700" id="stockProdSku">—</span></span>
        <span>Tồn hiện tại: <span class="font-bold text-violet-700" id="stockProdQty">—</span> <span id="stockProdUnit"></span></span>
      </div>
    </div>

    <div class="px-6 py-5">
      <div class="flex gap-1.5 p-1 bg-zinc-100 rounded-xl mb-5 text-xs font-bold">
        <button onclick="setStockAction('nhap-kho')" id="btnActionNhap" class="flex-1 py-2 text-center rounded-lg bg-white text-zinc-800 shadow-sm border border-zinc-200">Nhập kho (+)</button>
        <button onclick="setStockAction('xuat-kho')" id="btnActionXuat" class="flex-1 py-2 text-center rounded-lg text-zinc-500 hover:bg-white/50">Xuất kho (−)</button>
      </div>

      <form action="${pageContext.request.contextPath}/manager/kho-dich-vu" method="POST" class="flex flex-col gap-4">
        <input type="hidden" name="action" id="stockFormAction" value="nhap-kho">
        <input type="hidden" name="id" id="stockProdId">
        <div>
          <label class="field-label" id="lblStockQty">Số lượng cần nhập thêm <span class="field-req">*</span></label>
          <input type="number" name="amount" min="1" required placeholder="Nhập số lượng..." class="form-input font-bold text-sm">
        </div>
        <div>
          <label class="field-label">Ghi chú điều chỉnh</label>
          <input type="text" name="note" placeholder="Lý do điều chỉnh..." class="form-input">
        </div>
        <div class="flex justify-end gap-2.5 pt-2 border-t border-zinc-100">
          <button type="button" onclick="closeStockModal()" class="btn-ghost text-sm">Hủy</button>
          <button type="submit" id="btnStockSubmit" class="btn-primary text-sm">Xác nhận nhập kho</button>
        </div>
      </form>
    </div>
  </div>
</div>

<%-- ═══════════════════════════════════════════
     MODAL 4: QUẢN LÝ NHÓM DỊCH VỤ
════════════════════════════════════════════ --%>
<div id="categoryModal" class="modal-overlay hidden z-[80] flex items-center justify-center p-4">
  <div class="modal-box relative w-full max-w-[440px] z-10">
    <div class="modal-header">
      <div class="flex items-center gap-3">
        <div class="modal-icon bg-zinc-100"><span class="material-symbols-outlined text-zinc-600 text-[22px]">category</span></div>
        <div>
          <h3 class="text-base font-bold text-zinc-900">Quản lý nhóm dịch vụ</h3>
          <p class="text-xs text-zinc-400 mt-0.5">Tạo nhóm như Đồ uống, Thuê dụng cụ, Đồ ăn.</p>
        </div>
      </div>
      <button onclick="closeCategoryModal()" class="modal-close"><span class="material-symbols-outlined text-[18px]">close</span></button>
    </div>

    <div class="px-6 py-5 flex flex-col gap-4">
      <div>
        <p class="text-xs font-bold text-zinc-500 mb-2.5">Nhóm dịch vụ hiện tại</p>
        <div class="flex flex-col gap-2 max-h-52 overflow-y-auto">
          <c:choose>
            <c:when test="${empty categories}">
              <p class="text-xs text-zinc-400 py-4 text-center">Chưa có nhóm dịch vụ nào.</p>
            </c:when>
            <c:otherwise>
              <c:forEach items="${categories}" var="cat">
                <div class="flex items-center gap-3 px-3 py-2.5 bg-white rounded-xl border border-violet-100/60 hover:border-violet-200 transition-colors">
                  <div class="w-8 h-8 rounded-lg bg-violet-50 flex items-center justify-center shrink-0">
                    <span class="material-symbols-outlined text-[15px] text-violet-600">label</span>
                  </div>
                  <span class="text-sm font-medium text-zinc-800 flex-1">${cat.tenDanhMuc}</span>
                </div>
              </c:forEach>
            </c:otherwise>
          </c:choose>
        </div>
      </div>

      <div class="border-t border-zinc-100 pt-4">
        <p class="text-xs font-bold text-zinc-500 mb-2.5">Thêm nhóm mới</p>
        <form action="${pageContext.request.contextPath}/manager/kho-dich-vu" method="POST" onsubmit="return handleAddCategory(event)" class="flex gap-2">
          <input type="hidden" name="action" value="add-category">
          <input type="text" name="tenDanhMuc" id="newCatName" required placeholder="VD: Đồ uống" class="form-input flex-1">
          <button type="submit" class="btn-secondary text-sm shrink-0"><span class="material-symbols-outlined text-[16px]">add</span>Thêm</button>
        </form>
      </div>
    </div>
  </div>
</div>

<%-- ═══════════════════════════════════════════
     MODAL 5: THÊM NHANH TỪ MẪU CÓ SẴN
════════════════════════════════════════════ --%>
<div id="presetModal" class="modal-overlay hidden z-[80] flex items-start justify-center p-4 pt-8 overflow-y-auto">
  <div class="modal-box relative w-full max-w-[680px] z-10 flex flex-col max-h-[88vh]">
    <div class="modal-header shrink-0">
      <div class="flex items-center gap-3">
        <div class="modal-icon bg-amber-50"><span class="material-symbols-outlined text-amber-600 text-[22px]">bolt</span></div>
        <div>
          <h3 class="text-base font-bold text-zinc-900">Thêm nhanh từ mẫu có sẵn</h3>
          <p class="text-xs text-zinc-400 mt-0.5">Chọn các mặt hàng thường bán tại sân để thêm nhanh vào kho.</p>
        </div>
      </div>
      <button type="button" onclick="closePresetModal()" class="modal-close"><span class="material-symbols-outlined text-[18px]">close</span></button>
    </div>

    <form action="${pageContext.request.contextPath}/manager/kho-dich-vu" method="POST" class="flex flex-col flex-1 min-h-0">
      <input type="hidden" name="action" value="add-presets">

      <div class="flex items-center justify-between px-6 py-2.5 bg-amber-50/60 border-b border-amber-100 shrink-0">
        <p class="text-xs text-amber-700 flex items-center gap-1.5">
          <span class="material-symbols-outlined text-[14px]">info</span>
          Bạn có thể chỉnh lại giá bán và tồn kho sau khi thêm.
        </p>
      </div>

      <div class="overflow-y-auto flex-1 px-6 py-4">
        <table class="w-full text-left text-xs border-collapse">
          <thead>
            <tr class="border-b border-zinc-200">
              <th class="pb-3 text-[10.5px] font-bold text-zinc-500 uppercase tracking-wide w-[50%]">Tên mặt hàng mẫu</th>
              <th class="pb-3 text-[10.5px] font-bold text-zinc-500 uppercase tracking-wide">Nhóm</th>
              <th class="pb-3 text-[10.5px] font-bold text-zinc-500 uppercase tracking-wide">Đơn vị</th>
              <th class="pb-3 text-[10.5px] font-bold text-zinc-500 uppercase tracking-wide text-right">Giá gợi ý</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-zinc-100">
            <%-- Đồ uống --%>
            <tr class="bg-blue-50/40">
              <td colspan="4" class="px-0 py-2.5 text-[10px] font-bold text-blue-800 uppercase tracking-widest">
                <div class="flex items-center gap-1.5"><span class="material-symbols-outlined text-[13px]">local_cafe</span>Đồ uống</div>
              </td>
            </tr>
            <tr class="hover:bg-violet-50/20">
              <td class="py-3"><div class="flex items-center gap-2.5"><input type="checkbox" class="preset-checkbox w-4 h-4 accent-violet-600 rounded" onchange="togglePresetRow(this)"><span class="font-semibold text-zinc-800">Nước tinh khiết Aquafina 500ml</span></div><input type="hidden" name="presetNames" value="Nước tinh khiết Aquafina 500ml"><input type="hidden" name="presetCatNames" value="Nước uống"><input type="hidden" name="presetUnits" value="chai"><input type="hidden" name="presetGiaNhaps" value="5000"><input type="hidden" name="presetDonGias" value="10000"><input type="hidden" name="presetStocks" class="preset-stock-input" value="0"></td>
              <td class="py-3 text-zinc-400">Nước uống</td><td class="py-3 text-zinc-400">chai</td><td class="py-3 text-right font-bold text-zinc-800">10.000đ</td>
            </tr>
            <tr class="hover:bg-violet-50/20">
              <td class="py-3"><div class="flex items-center gap-2.5"><input type="checkbox" class="preset-checkbox w-4 h-4 accent-violet-600 rounded" onchange="togglePresetRow(this)"><span class="font-semibold text-zinc-800">Nước ngọt Coca-Cola lon</span></div><input type="hidden" name="presetNames" value="Nước ngọt Coca-Cola lon"><input type="hidden" name="presetCatNames" value="Nước uống"><input type="hidden" name="presetUnits" value="lon"><input type="hidden" name="presetGiaNhaps" value="8000"><input type="hidden" name="presetDonGias" value="12000"><input type="hidden" name="presetStocks" class="preset-stock-input" value="0"></td>
              <td class="py-3 text-zinc-400">Nước uống</td><td class="py-3 text-zinc-400">lon</td><td class="py-3 text-right font-bold text-zinc-800">12.000đ</td>
            </tr>
            <tr class="hover:bg-violet-50/20">
              <td class="py-3"><div class="flex items-center gap-2.5"><input type="checkbox" class="preset-checkbox w-4 h-4 accent-violet-600 rounded" onchange="togglePresetRow(this)"><span class="font-semibold text-zinc-800">Trà xanh Không Độ chai</span></div><input type="hidden" name="presetNames" value="Trà xanh Không Độ chai"><input type="hidden" name="presetCatNames" value="Nước uống"><input type="hidden" name="presetUnits" value="chai"><input type="hidden" name="presetGiaNhaps" value="8000"><input type="hidden" name="presetDonGias" value="12000"><input type="hidden" name="presetStocks" class="preset-stock-input" value="0"></td>
              <td class="py-3 text-zinc-400">Nước uống</td><td class="py-3 text-zinc-400">chai</td><td class="py-3 text-right font-bold text-zinc-800">12.000đ</td>
            </tr>
            <tr class="hover:bg-violet-50/20">
              <td class="py-3"><div class="flex items-center gap-2.5"><input type="checkbox" class="preset-checkbox w-4 h-4 accent-violet-600 rounded" onchange="togglePresetRow(this)"><span class="font-semibold text-zinc-800">Nước bù khoáng Revive 500ml</span></div><input type="hidden" name="presetNames" value="Nước bù khoáng Revive 500ml"><input type="hidden" name="presetCatNames" value="Nước uống"><input type="hidden" name="presetUnits" value="chai"><input type="hidden" name="presetGiaNhaps" value="8000"><input type="hidden" name="presetDonGias" value="12000"><input type="hidden" name="presetStocks" class="preset-stock-input" value="0"></td>
              <td class="py-3 text-zinc-400">Nước uống</td><td class="py-3 text-zinc-400">chai</td><td class="py-3 text-right font-bold text-zinc-800">12.000đ</td>
            </tr>

            <%-- Thuê dụng cụ --%>
            <tr class="bg-violet-50/40 border-t border-zinc-200">
              <td colspan="4" class="px-0 py-2.5 text-[10px] font-bold text-violet-800 uppercase tracking-widest">
                <div class="flex items-center gap-1.5"><span class="material-symbols-outlined text-[13px]">sports_tennis</span>Thuê dụng cụ</div>
              </td>
            </tr>
            <tr class="hover:bg-violet-50/20">
              <td class="py-3"><div class="flex items-center gap-2.5"><input type="checkbox" class="preset-checkbox w-4 h-4 accent-violet-600 rounded" onchange="togglePresetRow(this)"><span class="font-semibold text-zinc-800">Thuê vợt cầu lông Yonex</span></div><input type="hidden" name="presetNames" value="Thuê vợt cầu lông Yonex"><input type="hidden" name="presetCatNames" value="Thuê dụng cụ"><input type="hidden" name="presetUnits" value="lượt"><input type="hidden" name="presetGiaNhaps" value="0"><input type="hidden" name="presetDonGias" value="30000"><input type="hidden" name="presetStocks" class="preset-stock-input" value="0"></td>
              <td class="py-3 text-zinc-400">Thuê dụng cụ</td><td class="py-3 text-zinc-400">lượt</td><td class="py-3 text-right font-bold text-zinc-800">30.000đ</td>
            </tr>
            <tr class="hover:bg-violet-50/20">
              <td class="py-3"><div class="flex items-center gap-2.5"><input type="checkbox" class="preset-checkbox w-4 h-4 accent-violet-600 rounded" onchange="togglePresetRow(this)"><span class="font-semibold text-zinc-800">Thuê quả bóng đá size 5</span></div><input type="hidden" name="presetNames" value="Thuê quả bóng đá size 5"><input type="hidden" name="presetCatNames" value="Thuê dụng cụ"><input type="hidden" name="presetUnits" value="lượt"><input type="hidden" name="presetGiaNhaps" value="0"><input type="hidden" name="presetDonGias" value="40000"><input type="hidden" name="presetStocks" class="preset-stock-input" value="0"></td>
              <td class="py-3 text-zinc-400">Thuê dụng cụ</td><td class="py-3 text-zinc-400">lượt</td><td class="py-3 text-right font-bold text-zinc-800">40.000đ</td>
            </tr>
            <tr class="hover:bg-violet-50/20">
              <td class="py-3"><div class="flex items-center gap-2.5"><input type="checkbox" class="preset-checkbox w-4 h-4 accent-violet-600 rounded" onchange="togglePresetRow(this)"><span class="font-semibold text-zinc-800">Thuê giày thể thao cơ bản</span></div><input type="hidden" name="presetNames" value="Thuê giày thể thao cơ bản"><input type="hidden" name="presetCatNames" value="Thuê dụng cụ"><input type="hidden" name="presetUnits" value="đôi"><input type="hidden" name="presetGiaNhaps" value="0"><input type="hidden" name="presetDonGias" value="25000"><input type="hidden" name="presetStocks" class="preset-stock-input" value="0"></td>
              <td class="py-3 text-zinc-400">Thuê dụng cụ</td><td class="py-3 text-zinc-400">đôi</td><td class="py-3 text-right font-bold text-zinc-800">25.000đ</td>
            </tr>
            <tr class="hover:bg-violet-50/20">
              <td class="py-3"><div class="flex items-center gap-2.5"><input type="checkbox" class="preset-checkbox w-4 h-4 accent-violet-600 rounded" onchange="togglePresetRow(this)"><span class="font-semibold text-zinc-800">Thuê áo tập / áo bib đấu</span></div><input type="hidden" name="presetNames" value="Thuê áo tập / áo bib đấu"><input type="hidden" name="presetCatNames" value="Thuê dụng cụ"><input type="hidden" name="presetUnits" value="bộ"><input type="hidden" name="presetGiaNhaps" value="0"><input type="hidden" name="presetDonGias" value="10000"><input type="hidden" name="presetStocks" class="preset-stock-input" value="0"></td>
              <td class="py-3 text-zinc-400">Thuê dụng cụ</td><td class="py-3 text-zinc-400">bộ</td><td class="py-3 text-right font-bold text-zinc-800">10.000đ</td>
            </tr>

            <%-- Dịch vụ khác --%>
            <tr class="bg-zinc-50/60 border-t border-zinc-200">
              <td colspan="4" class="px-0 py-2.5 text-[10px] font-bold text-zinc-600 uppercase tracking-widest">
                <div class="flex items-center gap-1.5"><span class="material-symbols-outlined text-[13px]">more_horiz</span>Dịch vụ khác</div>
              </td>
            </tr>
            <tr class="hover:bg-violet-50/20">
              <td class="py-3"><div class="flex items-center gap-2.5"><input type="checkbox" class="preset-checkbox w-4 h-4 accent-violet-600 rounded" onchange="togglePresetRow(this)"><span class="font-semibold text-zinc-800">Khăn lạnh lau mặt</span></div><input type="hidden" name="presetNames" value="Khăn lạnh lau mặt"><input type="hidden" name="presetCatNames" value="Dịch vụ khác"><input type="hidden" name="presetUnits" value="cái"><input type="hidden" name="presetGiaNhaps" value="1500"><input type="hidden" name="presetDonGias" value="5000"><input type="hidden" name="presetStocks" class="preset-stock-input" value="0"></td>
              <td class="py-3 text-zinc-400">Dịch vụ khác</td><td class="py-3 text-zinc-400">cái</td><td class="py-3 text-right font-bold text-zinc-800">5.000đ</td>
            </tr>
            <tr class="hover:bg-violet-50/20">
              <td class="py-3"><div class="flex items-center gap-2.5"><input type="checkbox" class="preset-checkbox w-4 h-4 accent-violet-600 rounded" onchange="togglePresetRow(this)"><span class="font-semibold text-zinc-800">Phí gửi xe máy/ô tô</span></div><input type="hidden" name="presetNames" value="Phí gửi xe máy/ô tô"><input type="hidden" name="presetCatNames" value="Dịch vụ khác"><input type="hidden" name="presetUnits" value="lượt"><input type="hidden" name="presetGiaNhaps" value="0"><input type="hidden" name="presetDonGias" value="5000"><input type="hidden" name="presetStocks" class="preset-stock-input" value="0"></td>
              <td class="py-3 text-zinc-400">Dịch vụ khác</td><td class="py-3 text-zinc-400">lượt</td><td class="py-3 text-right font-bold text-zinc-800">5.000đ</td>
            </tr>
            <tr class="hover:bg-violet-50/20">
              <td class="py-3"><div class="flex items-center gap-2.5"><input type="checkbox" class="preset-checkbox w-4 h-4 accent-violet-600 rounded" onchange="togglePresetRow(this)"><span class="font-semibold text-zinc-800">Phụ thu tiền điện chiếu sáng</span></div><input type="hidden" name="presetNames" value="Phụ thu tiền điện chiếu sáng"><input type="hidden" name="presetCatNames" value="Dịch vụ khác"><input type="hidden" name="presetUnits" value="ca"><input type="hidden" name="presetGiaNhaps" value="0"><input type="hidden" name="presetDonGias" value="50000"><input type="hidden" name="presetStocks" class="preset-stock-input" value="0"></td>
              <td class="py-3 text-zinc-400">Dịch vụ khác</td><td class="py-3 text-zinc-400">ca</td><td class="py-3 text-right font-bold text-zinc-800">50.000đ</td>
            </tr>
          </tbody>
        </table>
      </div>

      <div class="px-6 py-4 bg-zinc-50/60 border-t border-zinc-100 flex justify-end gap-2.5 shrink-0">
        <button type="button" onclick="closePresetModal()" class="btn-ghost text-sm">Hủy</button>
        <button type="submit" id="presetSubmitBtn" disabled class="btn-primary text-sm opacity-50 cursor-not-allowed">
          <span class="material-symbols-outlined text-[16px]">add_circle</span>Thêm các mẫu đã chọn
        </button>
      </div>
    </form>
  </div>
</div>

<script>
  // Mobile menu
  document.getElementById('mobileMenuBtn')?.addEventListener('click', () => {
    document.getElementById('sidebar').classList.toggle('-translate-x-full');
  });

  // SKU generator
  function generateRandomSku() {
    const c = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    let r = '';
    for (let i = 0; i < 6; i++) r += c.charAt(Math.floor(Math.random() * c.length));
    return 'SKU-' + r;
  }
  function regenerateAddSku() { document.getElementById('addSkuCode').value = generateRandomSku(); }

  // ── Add Modal ──
  function openAddModal() {
    document.getElementById('addModal').classList.remove('hidden');
    document.getElementById('addModal').classList.add('flex');
    regenerateAddSku();
  }
  function closeAddModal() {
    document.getElementById('addModal').classList.add('hidden');
    document.getElementById('addModal').classList.remove('flex');
  }

  // ── Edit Modal ──
  function openEditModal(id, sku, name, catId, donGia, giaNhap, unit, stock, status, desc) {
    document.getElementById('editSanPhamID').value = id;
    document.getElementById('editSkuCode').value = sku;
    document.getElementById('editTenSanPham').value = name;
    document.getElementById('editDanhMucID').value = catId;
    document.getElementById('editDonGia').value = donGia;
    document.getElementById('editGiaNhap').value = giaNhap;
    document.getElementById('editDonViTinh').value = unit;
    document.getElementById('editSoLuongTon').value = stock;
    document.getElementById('editTrangThai').value = status;
    document.getElementById('editMoTa').value = desc === 'null' ? '' : desc;
    document.getElementById('editModal').classList.remove('hidden');
    document.getElementById('editModal').classList.add('flex');
  }
  function closeEditModal() {
    document.getElementById('editModal').classList.add('hidden');
    document.getElementById('editModal').classList.remove('flex');
  }

  // ── Stock Modal ──
  function openStockModal(id, sku, name, currentStock, unit) {
    document.getElementById('stockProdId').value = id;
    document.getElementById('stockProdSku').innerText = sku;
    document.getElementById('stockProdName').innerText = name;
    document.getElementById('stockProdQty').innerText = currentStock;
    document.getElementById('stockProdUnit').innerText = unit || 'cái';
    setStockAction('nhap-kho');
    document.getElementById('stockModal').classList.remove('hidden');
    document.getElementById('stockModal').classList.add('flex');
  }
  function closeStockModal() {
    document.getElementById('stockModal').classList.add('hidden');
    document.getElementById('stockModal').classList.remove('flex');
  }
  function setStockAction(action) {
    document.getElementById('stockFormAction').value = action;
    const btnN = document.getElementById('btnActionNhap');
    const btnX = document.getElementById('btnActionXuat');
    const lbl  = document.getElementById('lblStockQty');
    const btnS = document.getElementById('btnStockSubmit');
    if (action === 'nhap-kho') {
      btnN.className = 'flex-1 py-2 text-center rounded-lg bg-white text-zinc-800 shadow-sm border border-zinc-200 font-bold text-xs';
      btnX.className = 'flex-1 py-2 text-center rounded-lg text-zinc-500 hover:bg-white/50 font-bold text-xs';
      lbl.innerHTML  = 'Số lượng cần nhập thêm <span class="field-req">*</span>';
      btnS.textContent = 'Xác nhận nhập kho';
      btnS.style.background = '#7c3aed';
    } else {
      btnX.className = 'flex-1 py-2 text-center rounded-lg bg-white text-zinc-800 shadow-sm border border-zinc-200 font-bold text-xs';
      btnN.className = 'flex-1 py-2 text-center rounded-lg text-zinc-500 hover:bg-white/50 font-bold text-xs';
      lbl.innerHTML  = 'Số lượng cần xuất giảm <span class="field-req">*</span>';
      btnS.textContent = 'Xác nhận xuất kho';
      btnS.style.background = '#18181b';
    }
  }

  // ── Category Modal ──
  const existingCategories = [
    <c:forEach items="${categories}" var="cat" varStatus="loop">
      '${cat.tenDanhMuc.trim().toLowerCase()}'${!loop.last ? ',' : ''}
    </c:forEach>
  ];
  function handleAddCategory(event) {
    const input = event.target.querySelector('input[name="tenDanhMuc"]');
    const catName = input.value.trim().toLowerCase();
    if (existingCategories.includes(catName)) { alert('Nhóm "' + input.value.trim() + '" đã tồn tại!'); return false; }
    return true;
  }
  function openCategoryModal() {
    document.getElementById('categoryModal').classList.remove('hidden');
    document.getElementById('categoryModal').classList.add('flex');
  }
  function closeCategoryModal() {
    document.getElementById('categoryModal').classList.add('hidden');
    document.getElementById('categoryModal').classList.remove('flex');
  }

  // ── Preset Modal ──
  function togglePresetRow(checkbox) {
    const row = checkbox.closest('tr');
    const stockHidden = row.querySelector('.preset-stock-input');
    const name = row.querySelector('input[name="presetNames"]').value;
    if (checkbox.checked) {
      stockHidden.value = name.includes('Phí gửi') || name.includes('Phụ thu') ? '1' : name.includes('Thuê') ? '5' : '10';
      row.classList.add('bg-violet-50/40');
    } else {
      stockHidden.value = '0';
      row.classList.remove('bg-violet-50/40');
    }
    validatePresetSelection();
  }
  function validatePresetSelection() {
    const checkboxes = document.querySelectorAll('.preset-checkbox');
    const submitBtn = document.getElementById('presetSubmitBtn');
    let anyChecked = false;
    checkboxes.forEach(cb => { if (cb.checked) anyChecked = true; });
    submitBtn.disabled = !anyChecked;
    submitBtn.classList.toggle('opacity-50', !anyChecked);
    submitBtn.classList.toggle('cursor-not-allowed', !anyChecked);
    submitBtn.classList.toggle('cursor-pointer', anyChecked);
  }
  function openPresetModal() {
    document.querySelectorAll('.preset-checkbox').forEach(cb => {
      cb.checked = false;
      cb.closest('tr').classList.remove('bg-violet-50/40');
    });
    document.querySelectorAll('.preset-stock-input').forEach(i => i.value = 0);
    validatePresetSelection();
    document.getElementById('presetModal').classList.remove('hidden');
    document.getElementById('presetModal').classList.add('flex');
  }
  function closePresetModal() {
    document.getElementById('presetModal').classList.add('hidden');
    document.getElementById('presetModal').classList.remove('flex');
  }

  // ── Delete ──
  function confirmDelete(id, name) {
    showCustomConfirm("Bạn có chắc chắn muốn xóa sản phẩm/dịch vụ '" + name + "'? Sản phẩm sẽ được chuyển vào Thùng rác.", () => {
      showToast("Đang xóa... Bạn có thể vào Thùng rác để khôi phục.", "success");
      const form = document.createElement('form');
      form.method = 'POST';
      form.action = '${pageContext.request.contextPath}/manager/kho-dich-vu';
      const a = document.createElement('input'); a.type='hidden'; a.name='action'; a.value='delete'; form.appendChild(a);
      const b = document.createElement('input'); b.type='hidden'; b.name='id'; b.value=id; form.appendChild(b);
      document.body.appendChild(form);
      setTimeout(() => form.submit(), 1200);
    });
  }

  // Scroll reveal
  document.addEventListener('DOMContentLoaded', () => {
    const obs = new IntersectionObserver((entries) => {
      entries.forEach((entry, i) => {
        if (entry.isIntersecting) { setTimeout(() => entry.target.classList.add('revealed'), i * 40); obs.unobserve(entry.target); }
      });
    }, { threshold: 0.05, rootMargin: '0px 0px -10px 0px' });
    document.querySelectorAll('.reveal-on-scroll').forEach(el => obs.observe(el));
  });

  // bfcache reload
  window.addEventListener('pageshow', e => { if (e.persisted) window.location.reload(); });
</script>
</body>
</html>
