<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
<title>${pageTitle}</title>
<jsp:include page="/manager/common/manager_head.jsp" />
<style>
  body { background-color: #f8fafc !important; }
  .stat-card {
    background: #fff;
    border: 1px solid #f1f5f9;
    border-radius: 16px;
    padding: 22px;
    box-shadow: 0 1px 3px rgba(0,0,0,.05);
    transition: transform .2s,box-shadow .2s;
  }
  .stat-card:hover { transform: translateY(-2px); box-shadow: 0 8px 24px rgba(0,0,0,.07); }
  .badge-main  { background:#ede9fe; color:#6d28d9; }
  .badge-split { background:#fef3c7; color:#92400e; }
  .badge-paid  { background:#dcfce7; color:#166534; }
  .badge-unpaid{ background:#fee2e2; color:#991b1b; }
  .badge-cancel{ background:#f1f5f9; color:#64748b; }
  .tbl-row { transition: background .12s; }
  .tbl-row:hover { background: #faf5ff; }
</style>
</head>
<body class="text-zinc-900 min-h-screen">

<jsp:include page="/manager/common/sidebar.jsp" />

<c:set var="headerTitle"    value="Quản lý hóa đơn" scope="page" />
<c:set var="headerSubtitle" value="Tất cả hóa đơn cơ sở CS${sessionScope.user.coSoId}" scope="page" />
<c:set var="headerIcon"     value="receipt_long" scope="page" />
<jsp:include page="/manager/common/header.jsp" />

<main class="lg:ml-[248px] mt-[64px] p-4 lg:p-6 flex flex-col gap-5">

  <%-- Toast / alerts --%>
  <c:if test="${not empty errorMsg}">
    <div class="bg-red-50 border border-red-200 text-red-800 rounded-xl px-4 py-3 text-sm font-medium flex gap-2 items-center">
      <span class="material-symbols-outlined text-[18px] text-red-600">error</span>${errorMsg}
    </div>
  </c:if>

  <%-- Stats row --%>
  <section class="grid grid-cols-2 lg:grid-cols-4 gap-4">
    <div class="stat-card">
      <div class="flex items-start justify-between mb-3">
        <div class="w-11 h-11 rounded-xl bg-purple-50 flex items-center justify-center">
          <span class="material-symbols-outlined text-[20px] text-purple-700" style="font-variation-settings:'FILL' 1">receipt_long</span>
        </div>
      </div>
      <p class="text-xs text-zinc-500 font-medium mb-1">Tổng hóa đơn</p>
      <p class="text-2xl font-black text-purple-950">${stats.totalCount != null ? stats.totalCount : 0}</p>
    </div>
    <div class="stat-card">
      <div class="flex items-start justify-between mb-3">
        <div class="w-11 h-11 rounded-xl bg-green-50 flex items-center justify-center">
          <span class="material-symbols-outlined text-[20px] text-green-700" style="font-variation-settings:'FILL' 1">payments</span>
        </div>
      </div>
      <p class="text-xs text-zinc-500 font-medium mb-1">Doanh thu (HĐ sân)</p>
      <p class="text-2xl font-black text-green-700">
        <fmt:formatNumber value="${stats.tongDoanhThu != null ? stats.tongDoanhThu : 0}" type="number" maxFractionDigits="0"/>đ
      </p>
    </div>
    <div class="stat-card">
      <div class="flex items-start justify-between mb-3">
        <div class="w-11 h-11 rounded-xl bg-amber-50 flex items-center justify-center">
          <span class="material-symbols-outlined text-[20px] text-amber-600" style="font-variation-settings:'FILL' 1">pending</span>
        </div>
      </div>
      <p class="text-xs text-zinc-500 font-medium mb-1">HĐ sân chưa TT</p>
      <p class="text-2xl font-black text-amber-700">${stats.mainChuaTT != null ? stats.mainChuaTT : 0}</p>
    </div>
    <div class="stat-card">
      <div class="flex items-start justify-between mb-3">
        <div class="w-11 h-11 rounded-xl bg-orange-50 flex items-center justify-center">
          <span class="material-symbols-outlined text-[20px] text-orange-600" style="font-variation-settings:'FILL' 1">splitscreen</span>
        </div>
      </div>
      <p class="text-xs text-zinc-500 font-medium mb-1">Tách bill chưa TT</p>
      <p class="text-2xl font-black text-orange-700">${stats.splitChuaTT != null ? stats.splitChuaTT : 0}</p>
    </div>
  </section>

  <%-- Filter bar --%>
  <section class="bg-white rounded-2xl border border-slate-100 p-4 shadow-sm">
    <form method="get" action="${pageContext.request.contextPath}/manager/hoa-don"
          class="flex flex-wrap gap-3 items-end">
      <div class="flex flex-col gap-1 min-w-[140px]">
        <label class="text-[10px] font-bold text-zinc-400">Trạng thái</label>
        <select name="filterStatus"
                class="border border-slate-200 rounded-lg px-3 py-2 text-xs text-zinc-700 bg-white focus:outline-none focus:ring-2 focus:ring-purple-200">
          <option value="">Tất cả</option>
          <option value="Chưa thanh toán" ${filterStatus=='Chưa thanh toán'?'selected':''}>Chưa thanh toán</option>
          <option value="Đã thanh toán"   ${filterStatus=='Đã thanh toán'  ?'selected':''}>Đã thanh toán</option>
          <option value="Đã hủy"          ${filterStatus=='Đã hủy'         ?'selected':''}>Đã hủy</option>
        </select>
      </div>
      <div class="flex flex-col gap-1 min-w-[130px]">
        <label class="text-[10px] font-bold text-zinc-400">Loại hóa đơn</label>
        <select name="filterLoai"
                class="border border-slate-200 rounded-lg px-3 py-2 text-xs text-zinc-700 bg-white focus:outline-none focus:ring-2 focus:ring-purple-200">
          <option value="">Tất cả</option>
          <option value="MAIN"  ${filterLoai=='MAIN' ?'selected':''}>HĐ sân (MAIN)</option>
          <option value="SPLIT" ${filterLoai=='SPLIT'?'selected':''}>Tách bill (SPLIT)</option>
        </select>
      </div>
      <div class="flex flex-col gap-1">
        <label class="text-[10px] font-bold text-zinc-400">Từ ngày</label>
        <input type="date" name="filterFrom" value="${filterFrom}"
               class="border border-slate-200 rounded-lg px-3 py-2 text-xs text-zinc-700 bg-white focus:outline-none focus:ring-2 focus:ring-purple-200"/>
      </div>
      <div class="flex flex-col gap-1">
        <label class="text-[10px] font-bold text-zinc-400">Đến ngày</label>
        <input type="date" name="filterTo" value="${filterTo}"
               class="border border-slate-200 rounded-lg px-3 py-2 text-xs text-zinc-700 bg-white focus:outline-none focus:ring-2 focus:ring-purple-200"/>
      </div>
      <div class="flex flex-col gap-1 flex-1 min-w-[180px]">
        <label class="text-[10px] font-bold text-zinc-400">Tìm kiếm</label>
        <input type="text" name="filterSearch" value="${filterSearch}"
               placeholder="Số HĐ, tên khách, tên sân…"
               class="border border-slate-200 rounded-lg px-3 py-2 text-xs text-zinc-700 bg-white focus:outline-none focus:ring-2 focus:ring-purple-200"/>
      </div>
      <button type="submit"
              class="bg-purple-600 hover:bg-purple-700 text-white rounded-lg px-5 py-2 text-xs font-bold transition-all shadow-md shadow-purple-100 flex items-center gap-1">
        <span class="material-symbols-outlined text-[15px]">search</span>Lọc
      </button>
      <a href="${pageContext.request.contextPath}/manager/hoa-don"
         class="bg-slate-100 hover:bg-slate-200 text-slate-600 rounded-lg px-4 py-2 text-xs font-semibold transition-all flex items-center gap-1">
        <span class="material-symbols-outlined text-[15px]">refresh</span>Đặt lại
      </a>
      <button type="button" onclick="openCreateServiceModal()"
              class="bg-emerald-600 hover:bg-emerald-700 text-white rounded-lg px-5 py-2 text-xs font-bold transition-all shadow-md shadow-emerald-100 flex items-center gap-1">
        <span class="material-symbols-outlined text-[15px]">add_shopping_cart</span>Lập HĐ dịch vụ
      </button>
    </form>
  </section>

  <%-- Table --%>
  <section class="bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden">
    <div class="px-5 py-4 border-b border-slate-100 flex items-center justify-between">
      <h2 class="text-sm font-bold text-zinc-800 flex items-center gap-2">
        <span class="material-symbols-outlined text-[18px] text-purple-600">receipt_long</span>
        Danh sách hóa đơn
        <span class="ml-1 text-[11px] font-semibold bg-purple-50 text-purple-700 px-2 py-0.5 rounded-full">${totalCount} kết quả</span>
      </h2>
    </div>
    <div class="overflow-x-auto">
      <table class="w-full text-xs">
        <thead>
          <tr class="bg-slate-50 text-[10px] text-zinc-400 font-bold">
            <th class="px-4 py-3 text-left">Số HĐ</th>
            <th class="px-4 py-3 text-left">Loại</th>
            <th class="px-4 py-3 text-left">Sân / Ngày</th>
            <th class="px-4 py-3 text-left">Khách hàng</th>
            <th class="px-4 py-3 text-right">Tổng tiền</th>
            <th class="px-4 py-3 text-left">PT Thanh toán</th>
            <th class="px-4 py-3 text-left">Trạng thái</th>
            <th class="px-4 py-3 text-left">Ngày lập</th>
            <th class="px-4 py-3 text-center">Thao tác</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-slate-50">
          <c:forEach var="hd" items="${invoices}">
            <tr class="tbl-row">
              <td class="px-4 py-3 font-bold text-purple-700">#${hd.hoaDonId}</td>
              <td class="px-4 py-3">
                <c:choose>
                  <c:when test="${hd.loaiHoaDon == 'SPLIT'}">
                    <span class="badge-split text-[10px] font-bold px-2 py-0.5 rounded-full">SPLIT</span>
                  </c:when>
                  <c:otherwise>
                    <span class="badge-main text-[10px] font-bold px-2 py-0.5 rounded-full">MAIN</span>
                  </c:otherwise>
                </c:choose>
              </td>
              <td class="px-4 py-3">
                <p class="font-semibold text-zinc-800">${hd.tenSan}</p>
                <p class="text-zinc-400">${hd.ngayDat} · ${hd.gioBatDau}–${hd.gioKetThuc}</p>
              </td>
              <td class="px-4 py-3 text-zinc-600">
                <c:choose>
                  <c:when test="${not empty hd.tenKhachHang}">${hd.tenKhachHang}</c:when>
                  <c:otherwise><span class="text-zinc-400 italic">Khách vãng lai</span></c:otherwise>
                </c:choose>
              </td>
              <td class="px-4 py-3 text-right font-bold text-zinc-800">
                <fmt:formatNumber value="${hd.tongThanhToan}" type="number" maxFractionDigits="0"/>đ
              </td>
              <td class="px-4 py-3 text-zinc-500">${not empty hd.phuongThuc ? hd.phuongThuc : '—'}</td>
              <td class="px-4 py-3">
                <c:choose>
                  <c:when test="${hd.trangThai == 'Đã thanh toán'}">
                    <span class="badge-paid text-[10px] font-bold px-2 py-0.5 rounded-full">Đã TT</span>
                  </c:when>
                  <c:when test="${hd.trangThai == 'Chưa thanh toán'}">
                    <span class="badge-unpaid text-[10px] font-bold px-2 py-0.5 rounded-full">Chưa TT</span>
                  </c:when>
                  <c:otherwise>
                    <span class="badge-cancel text-[10px] font-bold px-2 py-0.5 rounded-full">${hd.trangThai}</span>
                  </c:otherwise>
                </c:choose>
              </td>
              <td class="px-4 py-3 text-zinc-400">${hd.ngayLap}</td>
              <td class="px-4 py-3 text-center">
                <div class="flex items-center justify-center gap-1">
                  <button onclick="openDetail(${hd.hoaDonId})"
                          class="p-1.5 rounded-lg hover:bg-purple-50 text-purple-600 transition-all" title="Xem chi tiết">
                    <span class="material-symbols-outlined text-[16px]">visibility</span>
                  </button>
                  <a href="${pageContext.request.contextPath}/staff/hoa-don/in?id=${hd.hoaDonId}" target="_blank"
                     class="p-1.5 rounded-lg hover:bg-zinc-100 text-zinc-600 transition-all" title="In lại hóa đơn">
                    <span class="material-symbols-outlined text-[16px]">print</span>
                  </a>
                </div>
              </td>
            </tr>
          </c:forEach>
          <c:if test="${empty invoices}">
            <tr>
              <td colspan="9" class="px-4 py-12 text-center text-zinc-400">
                <span class="material-symbols-outlined text-[36px] block mb-2">receipt_long</span>
                Không có hóa đơn nào phù hợp với bộ lọc.
              </td>
            </tr>
          </c:if>
        </tbody>
      </table>
    </div>

    <%-- Pagination --%>
    <c:if test="${totalPages > 1}">
      <div class="px-5 py-3 border-t border-slate-100 flex items-center justify-between">
        <p class="text-xs text-zinc-400">Trang ${currentPage} / ${totalPages} · ${totalCount} kết quả</p>
        <div class="flex gap-1">
          <c:if test="${currentPage > 1}">
            <a href="?page=${currentPage-1}&filterStatus=${filterStatus}&filterLoai=${filterLoai}&filterFrom=${filterFrom}&filterTo=${filterTo}&filterSearch=${filterSearch}"
               class="px-3 py-1.5 rounded-lg text-xs border border-slate-200 text-zinc-600 hover:bg-purple-50 hover:text-purple-700 transition-all">‹</a>
          </c:if>
          <c:forEach begin="1" end="${totalPages}" var="p">
            <a href="?page=${p}&filterStatus=${filterStatus}&filterLoai=${filterLoai}&filterFrom=${filterFrom}&filterTo=${filterTo}&filterSearch=${filterSearch}"
               class="px-3 py-1.5 rounded-lg text-xs border transition-all ${p == currentPage ? 'bg-purple-600 text-white border-purple-600' : 'border-slate-200 text-zinc-600 hover:bg-purple-50 hover:text-purple-700'}">${p}</a>
          </c:forEach>
          <c:if test="${currentPage < totalPages}">
            <a href="?page=${currentPage+1}&filterStatus=${filterStatus}&filterLoai=${filterLoai}&filterFrom=${filterFrom}&filterTo=${filterTo}&filterSearch=${filterSearch}"
               class="px-3 py-1.5 rounded-lg text-xs border border-slate-200 text-zinc-600 hover:bg-purple-50 hover:text-purple-700 transition-all">›</a>
          </c:if>
        </div>
      </div>
    </c:if>
  </section>

</main>

<%-- ═══ DETAIL MODAL ═══ --%>
<div id="detailModal" class="fixed inset-0 z-50 hidden flex items-center justify-center p-4">
  <div class="absolute inset-0 bg-black/50 backdrop-blur-sm" onclick="closeDetail()"></div>
  <div class="relative bg-white rounded-2xl shadow-2xl w-full max-w-lg max-h-[90vh] overflow-y-auto border border-purple-100">
    <div class="sticky top-0 bg-white border-b border-slate-100 px-6 py-4 flex items-center justify-between rounded-t-2xl">
      <h3 id="detailTitle" class="font-bold text-sm text-zinc-800">Chi tiết hóa đơn</h3>
      <button onclick="closeDetail()" class="p-1 rounded-lg hover:bg-slate-100 text-zinc-500">
        <span class="material-symbols-outlined text-[18px]">close</span>
      </button>
    </div>
    <div id="detailBody" class="px-6 py-4 text-xs space-y-4">
      <div class="flex items-center justify-center py-8">
        <div class="w-6 h-6 border-2 border-purple-600 border-t-transparent rounded-full animate-spin"></div>
      </div>
    </div>
  </div>
</div>

<%-- ═══ PAY MODAL ═══ --%>
<div id="payModal" class="fixed inset-0 z-50 hidden flex items-center justify-center p-4">
  <div class="absolute inset-0 bg-black/50 backdrop-blur-sm" onclick="closePayModal()"></div>
  <div class="relative bg-white rounded-2xl shadow-2xl w-full max-w-sm border border-purple-100 p-6">
    <h3 class="font-bold text-sm text-zinc-800 mb-4">Thanh toán hóa đơn</h3>
    <p class="text-xs text-zinc-500 mb-4">Chọn phương thức thanh toán cho hóa đơn <span id="payHdLabel" class="font-bold text-purple-700"></span></p>
    <input type="hidden" id="payHoaDonId"/>
    <div class="flex flex-col gap-2 mb-5">
      <label class="flex items-center gap-2 cursor-pointer p-2.5 rounded-xl border border-slate-200 hover:border-purple-300 hover:bg-purple-50 transition-all">
        <input type="radio" name="payMethod" value="Tiền mặt" class="accent-purple-600" checked/>
        <span class="text-xs font-medium text-zinc-700">Tiền mặt</span>
      </label>
      <label class="flex items-center gap-2 cursor-pointer p-2.5 rounded-xl border border-slate-200 hover:border-purple-300 hover:bg-purple-50 transition-all">
        <input type="radio" name="payMethod" value="Chuyển khoản" class="accent-purple-600"/>
        <span class="text-xs font-medium text-zinc-700">Chuyển khoản</span>
      </label>
      <label class="flex items-center gap-2 cursor-pointer p-2.5 rounded-xl border border-slate-200 hover:border-purple-300 hover:bg-purple-50 transition-all">
        <input type="radio" name="payMethod" value="Thẻ" class="accent-purple-600"/>
        <span class="text-xs font-medium text-zinc-700">Thẻ</span>
      </label>
      <label class="flex items-center gap-2 cursor-pointer p-2.5 rounded-xl border border-slate-200 hover:border-purple-300 hover:bg-purple-50 transition-all">
        <input type="radio" name="payMethod" value="Ví điện tử" class="accent-purple-600"/>
        <span class="text-xs font-medium text-zinc-700">Ví điện tử</span>
      </label>
    </div>
    <div class="flex gap-3">
      <button onclick="closePayModal()" class="flex-1 py-2.5 bg-slate-100 hover:bg-slate-200 text-zinc-600 rounded-xl text-xs font-semibold transition-all">Hủy</button>
      <button onclick="submitPay()" class="flex-1 py-2.5 bg-purple-600 hover:bg-purple-700 text-white rounded-xl text-xs font-semibold transition-all shadow-md">Xác nhận</button>
    </div>
  </div>
</div>


<%-- ═══ CREATE SERVICE INVOICE MODAL ═══ --%>
<div id="createServiceModal" class="fixed inset-0 z-50 hidden flex items-center justify-center p-4">
  <div class="absolute inset-0 bg-black/50 backdrop-blur-sm" onclick="closeCreateServiceModal()"></div>
  <div class="relative bg-white rounded-2xl shadow-2xl w-full max-w-3xl max-h-[92vh] overflow-y-auto border border-emerald-100">
    <div class="sticky top-0 bg-white border-b border-slate-100 px-6 py-4 flex items-center justify-between rounded-t-2xl">
      <div>
        <h3 class="font-bold text-sm text-zinc-800">Lập hóa đơn dịch vụ</h3>
        <p class="text-[11px] text-zinc-400 mt-0.5">Chọn đơn đặt sân và dịch vụ cần thu tiền.</p>
      </div>
      <button onclick="closeCreateServiceModal()" class="p-1 rounded-lg hover:bg-slate-100 text-zinc-500">
        <span class="material-symbols-outlined text-[18px]">close</span>
      </button>
    </div>

    <form id="createServiceForm" class="px-6 py-5 space-y-4" onsubmit="submitCreateServiceInvoice(event)">
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">
        <div class="flex flex-col gap-1">
          <label class="text-[10px] font-bold text-zinc-400">Đơn đặt sân</label>
          <select name="datSanId" required class="border border-slate-200 rounded-xl px-3 py-2.5 text-xs text-zinc-700 bg-white focus:outline-none focus:ring-2 focus:ring-emerald-200">
            <option value="">-- Chọn đơn đặt sân --</option>
            <c:forEach var="booking" items="${payableBookings}">
              <option value="${booking.datSanId}">${booking.label}</option>
            </c:forEach>
          </select>
        </div>
        <div class="flex flex-col gap-1">
          <label class="text-[10px] font-bold text-zinc-400">Ghi chú</label>
          <input name="ghiChu" maxlength="255" value="Manager lập hóa đơn dịch vụ"
                 class="border border-slate-200 rounded-xl px-3 py-2.5 text-xs text-zinc-700 bg-white focus:outline-none focus:ring-2 focus:ring-emerald-200"/>
        </div>
      </div>

      <div class="border border-slate-100 rounded-2xl overflow-hidden">
        <div class="px-4 py-3 bg-slate-50 flex items-center justify-between">
          <p class="text-xs font-bold text-zinc-700">Danh sách dịch vụ</p>
          <p class="text-[11px] text-zinc-400">Nhập số lượng cho sản phẩm muốn tính tiền</p>
        </div>
        <div class="max-h-[300px] overflow-y-auto divide-y divide-slate-50">
          <c:forEach var="sp" items="${serviceProducts}">
            <div class="grid grid-cols-[1fr_80px_70px] sm:grid-cols-[1fr_110px_90px] gap-2 sm:gap-3 items-center px-3 sm:px-4 py-3 service-row"
                 data-price="${sp.donGia}">
              <div>
                <input type="hidden" name="productId" value="${sp.sanPhamId}"/>
                <p class="text-xs font-semibold text-zinc-800">${sp.tenSanPham}</p>
                <p class="text-[11px] text-zinc-400">
                  <fmt:formatNumber value="${sp.donGia}" type="number" maxFractionDigits="0"/>đ/${empty sp.donViTinh ? 'sp' : sp.donViTinh} · Tồn: ${sp.soLuongTon}
                </p>
              </div>
              <input name="quantity" type="number" min="0" max="${sp.soLuongTon}" value="0"
                     oninput="updateCreateTotal()"
                     class="border border-slate-200 rounded-lg px-3 py-2 text-xs text-right focus:outline-none focus:ring-2 focus:ring-emerald-200"/>
              <p class="line-total text-xs font-bold text-right text-zinc-700">0đ</p>
            </div>
          </c:forEach>
          <c:if test="${empty serviceProducts}">
            <div class="px-4 py-8 text-center text-xs text-zinc-400">Chưa có dịch vụ/sản phẩm trong kho của cơ sở.</div>
          </c:if>
        </div>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-2 gap-4 items-start">
        <div class="rounded-2xl border border-slate-100 p-4 space-y-2">
          <label class="flex items-center gap-2 text-xs font-semibold text-zinc-700">
            <input id="createPayNow" name="payNow" type="checkbox" value="true" class="accent-emerald-600" checked onchange="toggleCreatePayMethod()"/>
            Thanh toán ngay
          </label>
          <div id="createPayMethodBox" class="grid grid-cols-2 gap-2 pt-2">
            <label class="text-xs flex items-center gap-2"><input type="radio" name="phuongThucThanhToan" value="Tiền mặt" checked class="accent-emerald-600"/>Tiền mặt</label>
            <label class="text-xs flex items-center gap-2"><input type="radio" name="phuongThucThanhToan" value="Chuyển khoản" class="accent-emerald-600"/>Chuyển khoản</label>
            <label class="text-xs flex items-center gap-2"><input type="radio" name="phuongThucThanhToan" value="Thẻ" class="accent-emerald-600"/>Thẻ</label>
            <label class="text-xs flex items-center gap-2"><input type="radio" name="phuongThucThanhToan" value="Ví điện tử" class="accent-emerald-600"/>Ví điện tử</label>
          </div>
        </div>
        <div class="rounded-2xl bg-emerald-50 border border-emerald-100 p-4">
          <p class="text-[11px] text-emerald-700 font-bold">Tổng tiền dịch vụ</p>
          <p id="createServiceTotal" class="text-2xl font-black text-emerald-800 mt-1">0đ</p>
        </div>
      </div>

      <div class="flex justify-end gap-3 pt-2 border-t border-slate-100">
        <button type="button" onclick="closeCreateServiceModal()" class="px-5 py-2.5 bg-slate-100 hover:bg-slate-200 text-zinc-600 rounded-xl text-xs font-semibold transition-all">Hủy</button>
        <button type="submit" class="px-5 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl text-xs font-semibold transition-all shadow-md shadow-emerald-100">Tạo hóa đơn</button>
      </div>
    </form>
  </div>
</div>

<script>
var BASE = '${pageContext.request.contextPath}';

function fmtMoney(v) {
  return new Intl.NumberFormat('vi-VN').format(Math.round(v || 0)) + 'đ';
}

function escapeHtml(value) {
  return String(value == null ? '' : value).replace(/[&<>"']/g, function(ch) {
    return ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'})[ch];
  });
}

function showToast(msg, type) {
  var toast = document.createElement('div');
  var isError = type === 'error';
  toast.className = 'fixed bottom-6 right-6 z-[9999] px-4 py-3 rounded-xl shadow-lg text-sm font-semibold flex items-center gap-2 transition-all ' +
    (isError ? 'bg-red-600 text-white' : 'bg-emerald-600 text-white');
  toast.innerHTML = '<span class="material-symbols-outlined text-[18px]">' + (isError ? 'error' : 'check_circle') + '</span>' + escapeHtml(msg);
  document.body.appendChild(toast);
  setTimeout(function() {
    toast.style.opacity = '0';
    toast.style.transform = 'translateY(8px)';
    setTimeout(function() { toast.remove(); }, 250);
  }, 2400);
}

function showCustomConfirm(message, onOk) {
  if (window.confirm(message)) onOk();
}


function openCreateServiceModal() {
  document.getElementById('createServiceModal').classList.remove('hidden');
  updateCreateTotal();
}
function closeCreateServiceModal() {
  document.getElementById('createServiceModal').classList.add('hidden');
}
function toggleCreatePayMethod() {
  var checked = document.getElementById('createPayNow').checked;
  document.getElementById('createPayMethodBox').style.opacity = checked ? '1' : '.45';
}
function updateCreateTotal() {
  var total = 0;
  document.querySelectorAll('#createServiceModal .service-row').forEach(function(row) {
    var price = Number(row.getAttribute('data-price') || 0);
    var qtyInput = row.querySelector('input[name="quantity"]');
    var qty = Number(qtyInput.value || 0);
    if (qty < 0) { qty = 0; qtyInput.value = 0; }
    var line = price * qty;
    total += line;
    row.querySelector('.line-total').textContent = fmtMoney(line);
  });
  document.getElementById('createServiceTotal').textContent = fmtMoney(total);
}
function submitCreateServiceInvoice(event) {
  event.preventDefault();
  var form = document.getElementById('createServiceForm');
  var totalQty = 0;
  form.querySelectorAll('input[name="quantity"]').forEach(function(input) { totalQty += Number(input.value || 0); });
  if (totalQty <= 0) { showToast('Vui lòng nhập số lượng cho ít nhất một dịch vụ.', 'error'); return; }
  var data = new URLSearchParams(new FormData(form));
  data.set('action', 'createServiceInvoice');
  fetch(BASE + '/manager/hoa-don', { method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, body:data.toString() })
    .then(function(r){ return r.json(); })
    .then(function(d){
      if (d.ok) { closeCreateServiceModal(); showToast(d.msg, 'success'); setTimeout(function(){ location.reload(); }, 1000); }
      else { showToast(d.msg || 'Không thể tạo hóa đơn.', 'error'); }
    })
    .catch(function(){ showToast('Lỗi kết nối.', 'error'); });
}

// ── Detail modal ──
function openDetail(hoaDonId) {
  var modal = document.getElementById('detailModal');
  modal.classList.remove('hidden');
  document.getElementById('detailBody').innerHTML =
    '<div class="flex items-center justify-center py-8"><div class="w-6 h-6 border-2 border-purple-600 border-t-transparent rounded-full animate-spin"></div></div>';
  document.getElementById('detailTitle').textContent = 'Chi tiết hóa đơn #' + hoaDonId;

  fetch(BASE + '/manager/hoa-don?action=detail&hoaDonId=' + hoaDonId)
    .then(function(r) { return r.json(); })
    .then(function(d) {
      if (d.ok === false) {
        document.getElementById('detailBody').innerHTML = '<p class="text-red-500 text-xs">' + escapeHtml(d.msg) + '</p>';
        return;
      }
      var loaiLabel = d.loaiHoaDon === 'SPLIT'
        ? '<span class="badge-split text-[10px] font-bold px-2 py-0.5 rounded-full">SPLIT</span>'
        : '<span class="badge-main text-[10px] font-bold px-2 py-0.5 rounded-full">MAIN</span>';
      var statusClass = d.trangThai === 'Đã thanh toán' ? 'badge-paid' : (d.trangThai === 'Chưa thanh toán' ? 'badge-unpaid' : 'badge-cancel');

      var itemsHtml = '';
      if (d.items && d.items.length > 0) {
        d.items.forEach(function(it) {
          itemsHtml += '<tr class="border-t border-slate-50"><td class="py-1.5">' + escapeHtml(it.tenSanPham) + '</td>' +
            '<td class="py-1.5 text-right">' + it.soLuong + '</td>' +
            '<td class="py-1.5 text-right">' + fmtMoney(it.donGia) + '</td>' +
            '<td class="py-1.5 text-right font-semibold">' + fmtMoney(it.thanhTien) + '</td></tr>';
        });
      } else {
        itemsHtml = '<tr><td colspan="4" class="py-3 text-center text-zinc-400">Không có chi tiết dịch vụ</td></tr>';
      }

      document.getElementById('detailBody').innerHTML =
        '<div class="grid grid-cols-2 gap-x-4 gap-y-2 text-xs">' +
          '<div><p class="text-zinc-400">Số HĐ</p><p class="font-bold text-purple-700">#' + d.hoaDonId + '</p></div>' +
          '<div><p class="text-zinc-400">Loại</p>' + loaiLabel + (d.parentHoaDonId ? ' <span class="text-zinc-400">← #' + d.parentHoaDonId + '</span>' : '') + '</div>' +
          '<div><p class="text-zinc-400">Sân</p><p class="font-semibold">' + escapeHtml(d.tenSan||'—') + '</p></div>' +
          '<div><p class="text-zinc-400">Ngày chơi</p><p>' + escapeHtml(d.ngayDat||'—') + ' · ' + (d.gioBatDau||'') + '–' + (d.gioKetThuc||'') + '</p></div>' +
          '<div><p class="text-zinc-400">Khách hàng</p><p>' + escapeHtml(d.tenKhachHang||'Khách vãng lai') + '</p></div>' +
          '<div><p class="text-zinc-400">Nhân viên</p><p>' + escapeHtml(d.tenNhanVien||'—') + '</p></div>' +
          '<div><p class="text-zinc-400">Ngày lập</p><p>' + escapeHtml(d.ngayLap||'—') + '</p></div>' +
          '<div><p class="text-zinc-400">PT Thanh toán</p><p>' + escapeHtml(d.phuongThuc||'—') + '</p></div>' +
        '</div>' +
        '<hr class="border-slate-100 my-3"/>' +
        '<table class="w-full text-xs">' +
          '<thead><tr class="text-zinc-400 text-[10px]"><th class="text-left pb-1">Sản phẩm/DV</th><th class="text-right pb-1">SL</th><th class="text-right pb-1">Đơn giá</th><th class="text-right pb-1">Thành tiền</th></tr></thead>' +
          '<tbody>' + itemsHtml + '</tbody>' +
        '</table>' +
        '<hr class="border-slate-100 my-3"/>' +
        '<div class="space-y-1.5 text-xs">' +
          '<div class="flex justify-between"><span class="text-zinc-500">Tiền sân</span><span>' + fmtMoney(d.tongTienSan) + '</span></div>' +
          '<div class="flex justify-between"><span class="text-zinc-500">Tiền dịch vụ</span><span>' + fmtMoney(d.tongTienDichVu) + '</span></div>' +
          (d.phiGuiXe > 0 ? '<div class="flex justify-between"><span class="text-zinc-500">Phí gửi xe</span><span>' + fmtMoney(d.phiGuiXe) + '</span></div>' : '') +
          (d.giamGia > 0  ? '<div class="flex justify-between"><span class="text-zinc-500">Giảm giá</span><span class="text-green-600">-' + fmtMoney(d.giamGia) + '</span></div>' : '') +
          '<div class="flex justify-between font-bold text-base pt-1 border-t border-slate-100"><span>Tổng cộng</span><span class="text-purple-700">' + fmtMoney(d.tongThanhToan) + '</span></div>' +
        '</div>' +
        '<div class="mt-3 flex items-center gap-2 pt-3 border-t border-slate-100">' +
          '<span class="text-zinc-400">Trạng thái:</span>' +
          '<span class="' + statusClass + ' text-[10px] font-bold px-2 py-0.5 rounded-full">' + escapeHtml(d.trangThai) + '</span>' +
          (d.ghiChu ? '<span class="text-zinc-400 ml-auto italic">' + escapeHtml(d.ghiChu) + '</span>' : '') +
        '</div>';
    })
    .catch(function(e) {
      document.getElementById('detailBody').innerHTML = '<p class="text-red-500 text-xs">Lỗi tải dữ liệu.</p>';
    });
}

function closeDetail() {
  document.getElementById('detailModal').classList.add('hidden');
}

// ── Pay modal ──
function openPayModal(hoaDonId, loai) {
  document.getElementById('payHoaDonId').value = hoaDonId;
  document.getElementById('payHdLabel').textContent = '#' + hoaDonId + (loai === 'SPLIT' ? ' (Tách bill)' : ' (HĐ sân)');
  document.getElementById('payModal').classList.remove('hidden');
}
function closePayModal() {
  document.getElementById('payModal').classList.add('hidden');
}
function submitPay() {
  var hoaDonId = document.getElementById('payHoaDonId').value;
  var method   = document.querySelector('input[name="payMethod"]:checked');
  if (!method) { showToast('Vui lòng chọn phương thức thanh toán.', 'error'); return; }
  var body = 'action=payInvoice&hoaDonId=' + hoaDonId + '&phuongThucThanhToan=' + encodeURIComponent(method.value);
  fetch(BASE + '/manager/hoa-don', {method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, body: body})
    .then(function(r) { return r.json(); })
    .then(function(d) {
      closePayModal();
      if (d.ok) { showToast(d.msg, 'success'); setTimeout(function(){ location.reload(); }, 1200); }
      else       { showToast(d.msg, 'error'); }
    })
    .catch(function() { showToast('Lỗi kết nối.', 'error'); });
}

// ── Cancel ──
function confirmCancel(hoaDonId) {
  showCustomConfirm('Bạn có chắc muốn hủy hóa đơn #' + hoaDonId + '? Hành động này không thể hoàn tác.', function() {
    var body = 'action=cancelInvoice&hoaDonId=' + hoaDonId;
    fetch(BASE + '/manager/hoa-don', {method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded'}, body: body})
      .then(function(r) { return r.json(); })
      .then(function(d) {
        if (d.ok) { showToast(d.msg, 'success'); setTimeout(function(){ location.reload(); }, 1200); }
        else       { showToast(d.msg, 'error'); }
      })
      .catch(function() { showToast('Lỗi kết nối.', 'error'); });
  });
}
</script>
<script>document.addEventListener('DOMContentLoaded',function(){ vsDatePicker('input[name="filterFrom"],input[name="filterTo"]'); });</script>
</body>
</html>
