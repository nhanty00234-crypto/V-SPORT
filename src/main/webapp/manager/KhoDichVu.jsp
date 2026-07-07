<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
<title>${pageTitle}</title>
<jsp:include page="/manager/common/manager_head.jsp" />
</head>
<body class="text-zinc-900 min-h-screen">

<!-- Sidebar Manager -->
<jsp:include page="/manager/common/sidebar.jsp" />

<!-- Header -->
<c:set var="headerTitle" value="Kho Dịch Vụ & Sản Phẩm" scope="page" />
<c:set var="headerSubtitle" value="Chi nhánh cơ sở CS${sessionScope.user.coSoId}" scope="page" />
<c:set var="headerIcon" value="storefront" scope="page" />
<jsp:include page="/manager/common/header.jsp" />

<!-- Main Content -->
<main class="lg:ml-[248px] mt-[64px] p-4 lg:p-6 flex flex-col gap-5">

  <!-- Status Alert Messages -->
  <c:if test="${not empty successMsg}">
    <div class="p-4 bg-green-50 border border-green-200 text-green-800 rounded-xl flex items-center gap-3 shadow-sm animation-fadeUp">
      <span class="material-symbols-outlined text-green-600">check_circle</span>
      <p class="text-sm font-medium">${successMsg}</p>
    </div>
  </c:if>
  <c:if test="${not empty errorMsg}">
    <div class="p-4 bg-red-50 border border-red-200 text-red-800 rounded-xl flex items-center gap-3 shadow-sm animation-fadeUp">
      <span class="material-symbols-outlined text-red-600">error</span>
      <p class="text-sm font-medium">${errorMsg}</p>
    </div>
  </c:if>

  <!-- Overview Stats Row -->
  <section class="grid grid-cols-2 lg:grid-cols-4 gap-4">
    <div class="card p-5 card-hover">
      <div class="flex items-center justify-between mb-2">
        <span class="text-xs text-zinc-500 font-medium">Tổng mặt hàng</span>
        <div class="w-8 h-8 rounded-lg bg-purple-50 flex items-center justify-center text-purple-700"><span class="material-symbols-outlined text-[18px]">inventory_2</span></div>
      </div>
      <p class="text-2xl font-black text-purple-950">${totalItems}</p>
      <p class="text-[10px] text-zinc-400 mt-1">Đang được quản lý tại quầy</p>
    </div>
    
    <div class="card p-5 card-hover">
      <div class="flex items-center justify-between mb-2">
        <span class="text-xs text-zinc-500 font-medium">Tổng giá trị tồn kho</span>
        <div class="w-8 h-8 rounded-lg bg-green-50 flex items-center justify-center text-green-700"><span class="material-symbols-outlined text-[18px]">monetization_on</span></div>
      </div>
      <p class="text-2xl font-black text-purple-950">
        <fmt:formatNumber value="${totalInventoryValue}" pattern="#,##0"/> <span class="text-sm font-semibold">đ</span>
      </p>
      <p class="text-[10px] text-zinc-400 mt-1">Tính theo giá trị nhập kho</p>
    </div>
    
    <div class="card p-5 card-hover">
      <div class="flex items-center justify-between mb-2">
        <span class="text-xs text-zinc-500 font-medium">Cảnh báo sắp hết</span>
        <div class="w-8 h-8 rounded-lg bg-amber-50 flex items-center justify-center text-amber-700"><span class="material-symbols-outlined text-[18px]">warning</span></div>
      </div>
      <p class="text-2xl font-black text-amber-600">${lowStockCount}</p>
      <p class="text-[10px] text-amber-550 font-medium mt-1">Mặt hàng có tồn kho dưới mức cảnh báo</p>
    </div>

    <div class="card p-5 card-hover">
      <div class="flex items-center justify-between mb-2">
        <span class="text-xs text-zinc-500 font-medium">Đã hết hàng</span>
        <div class="w-8 h-8 rounded-lg bg-red-50 flex items-center justify-center text-red-700"><span class="material-symbols-outlined text-[18px]">error_outline</span></div>
      </div>
      <p class="text-2xl font-black text-red-600">${outOfStockCount}</p>
      <p class="text-[10px] text-red-500 font-medium mt-1">Cần nhập thêm để tiếp tục bán</p>
    </div>
  </section>

  <!-- Filter & Actions Section -->
  <section class="card p-4 flex flex-col gap-4">
    <form action="${pageContext.request.contextPath}/manager/kho-dich-vu" method="GET" class="grid grid-cols-1 md:grid-cols-4 gap-3">
      <div class="relative">
        <span class="material-symbols-outlined absolute left-3 top-2.5 text-zinc-400 text-[18px]">search</span>
        <input type="search" name="search" value="${search}" autocomplete="off" placeholder="Tìm mặt hàng theo tên hoặc mã SKU..." class="w-full pl-9 pr-3 py-2 text-xs border border-purple-100 rounded-lg focus:outline-none focus:border-purple-500 bg-zinc-50/50">
      </div>
      
      <div>
        <select name="category" class="w-full px-3 py-2 text-xs border border-purple-100 rounded-lg focus:outline-none focus:border-purple-500 bg-zinc-50/50">
          <option value="">Tất cả nhóm dịch vụ</option>
          <c:forEach items="${categories}" var="cat">
            <option value="${cat.danhMucID}" ${selectedCategory == cat.danhMucID ? 'selected' : ''}>${cat.tenDanhMuc}</option>
          </c:forEach>
        </select>
      </div>

      <div>
        <select name="status" class="w-full px-3 py-2 text-xs border border-purple-100 rounded-lg focus:outline-none focus:border-purple-500 bg-zinc-50/50">
          <option value="">Tất cả trạng thái</option>
          <option value="Đang kinh doanh" ${selectedStatus == 'Đang kinh doanh' ? 'selected' : ''}>Đang kinh doanh</option>
          <option value="Tạm hết hàng" ${selectedStatus == 'Tạm hết hàng' ? 'selected' : ''}>Tạm hết hàng</option>
          <option value="Ngừng kinh doanh" ${selectedStatus == 'Ngừng kinh doanh' ? 'selected' : ''}>Ngừng kinh doanh</option>
        </select>
      </div>

      <div class="flex gap-2">
        <button type="submit" class="flex-1 bg-purple-600 hover:bg-purple-700 text-white font-semibold text-xs py-2 px-4 rounded-lg flex items-center justify-center gap-1.5 shadow-sm">
          <span class="material-symbols-outlined text-[16px]">filter_list</span>Lọc kết quả
        </button>
        <a href="${pageContext.request.contextPath}/manager/kho-dich-vu" class="bg-zinc-100 hover:bg-zinc-200 text-zinc-700 font-semibold text-xs py-2 px-3 rounded-lg flex items-center justify-center">
          <span class="material-symbols-outlined text-[16px]">restart_alt</span>
        </a>
      </div>
    </form>

    <div class="flex flex-col lg:flex-row lg:items-center justify-between gap-3 pt-3 border-t border-purple-50">
      <div class="text-xs text-zinc-500">Hiển thị <span class="font-bold text-purple-900">${productList.size()}</span> mặt hàng</div>
      <div class="flex flex-wrap gap-2">
        <button onclick="openCategoryModal()" class="border border-zinc-200 hover:bg-zinc-50 text-zinc-700 font-bold text-xs py-2 px-3.5 rounded-xl flex items-center gap-1.5 cursor-pointer transition-all active:scale-95" title="Tạo và chỉnh sửa các nhóm như Đồ uống, Thuê dụng cụ, Đồ ăn.">
          <span class="material-symbols-outlined text-[16px]">category</span>Quản lý nhóm dịch vụ
        </button>
        <button onclick="openPresetModal()" class="border border-purple-200 hover:bg-purple-50 text-purple-700 font-bold text-xs py-2 px-3.5 rounded-xl flex items-center gap-1.5 cursor-pointer transition-all active:scale-95" title="Chọn nhanh các mặt hàng thường dùng mẫu của hệ thống để thêm vào kho.">
          <span class="material-symbols-outlined text-[16px]">bolt</span>Thêm nhanh từ mẫu có sẵn
        </button>
        <button onclick="openAddModal()" class="bg-purple-600 hover:bg-purple-700 text-white font-extrabold text-xs py-2 px-4 rounded-xl flex items-center gap-1.5 shadow hover:shadow-md transition-all active:scale-95 cursor-pointer" title="Tự nhập đầy đủ thông tin mặt hàng.">
          <span class="material-symbols-outlined text-[16px]">add_circle</span>Thêm mặt hàng mới
        </button>
      </div>
    </div>

    <!-- Explanatory Helper Bar -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-3 bg-zinc-50 border border-zinc-100 rounded-xl p-3 text-[10px] text-zinc-500">
      <div class="flex items-center gap-1.5">
        <span class="material-symbols-outlined text-[14px] text-zinc-400">category</span>
        <span><strong>Quản lý nhóm dịch vụ:</strong> Sắp xếp mặt hàng theo nhóm (Đồ uống, Thuê dụng cụ...).</span>
      </div>
      <div class="flex items-center gap-1.5">
        <span class="material-symbols-outlined text-[14px] text-purple-500">bolt</span>
        <span><strong>Thêm nhanh từ mẫu có sẵn:</strong> Nhanh chóng thêm các mặt hàng thường gặp.</span>
      </div>
      <div class="flex items-center gap-1.5">
        <span class="material-symbols-outlined text-[14px] text-purple-650">add_circle</span>
        <span><strong>Thêm mặt hàng mới:</strong> Tự nhập đầy đủ thông tin mặt hàng tùy chỉnh.</span>
      </div>
    </div>
  </section>

  <!-- Product Inventory Table -->
  <c:choose>
    <c:when test="${totalItems == 0}">
      <!-- Beautiful premium empty state container -->
      <section class="card p-8 md:p-12 text-center flex flex-col items-center justify-center gap-4 max-w-2xl mx-auto border border-dashed border-purple-200 bg-white rounded-3xl shadow-sm reveal-on-scroll">
        <div class="w-16 h-16 rounded-2xl bg-purple-50 flex items-center justify-center text-purple-600 mb-2">
          <span class="material-symbols-outlined text-[36px]">inventory_2</span>
        </div>
        <div>
          <h3 class="text-base font-extrabold text-zinc-800">Kho dịch vụ chưa có mặt hàng nào</h3>
          <p class="text-xs text-zinc-550 mt-1 max-w-md mx-auto leading-relaxed">
            Bạn có thể thêm các dịch vụ bán tại sân như nước uống, thuê vợt, thuê bóng hoặc khăn để quản lý doanh thu tiện ích tại quầy lễ tân.
          </p>
        </div>
        
        <div class="flex flex-wrap items-center justify-center gap-3 mt-2">
          <button onclick="openPresetModal()" class="bg-purple-50 hover:bg-purple-100 text-purple-700 font-bold text-xs py-2.5 px-4 rounded-xl flex items-center gap-1.5 transition-all active:scale-95 cursor-pointer">
            <span class="material-symbols-outlined text-[16px]">bolt</span>Thêm nhanh từ mẫu có sẵn
          </button>
          <button onclick="openAddModal()" class="bg-purple-600 hover:bg-purple-700 text-white font-extrabold text-xs py-2.5 px-4 rounded-xl flex items-center gap-1.5 shadow-sm shadow-purple-100 transition-all active:scale-95 cursor-pointer">
            <span class="material-symbols-outlined text-[16px]">add_circle</span>Thêm mặt hàng mới
          </button>
        </div>

        <p class="text-[10px] text-zinc-400 mt-1 italic">
          💡 Ví dụ: Nước suối, nước ngọt, thuê vợt, thuê bóng, khăn lạnh.
        </p>

        <c:if test="${empty categories}">
          <div class="mt-4 pt-4 border-t border-zinc-100 w-full flex flex-col items-center">
            <p class="text-[11px] text-amber-600 font-medium flex items-center gap-1.5 justify-center">
              <span class="material-symbols-outlined text-[14px]">warning</span>
              Bạn nên tạo nhóm dịch vụ trước để phân loại hàng hóa, ví dụ: Đồ uống, Thuê dụng cụ.
            </p>
            <button onclick="openCategoryModal()" class="mt-2 text-xs font-bold text-purple-700 hover:underline flex items-center gap-1 cursor-pointer">
              <span class="material-symbols-outlined text-[14px]">category</span>Quản lý nhóm dịch vụ →
            </button>
          </div>
        </c:if>
      </section>
    </c:when>
    <c:otherwise>
      <section class="card overflow-hidden">
        <div class="overflow-x-auto">
          <table class="w-full text-left border-collapse text-xs">
            <thead>
              <tr class="bg-purple-50/50 text-purple-950 font-bold border-b border-purple-100">
                <th class="p-4 w-24">SKU / Mã</th>
                <th class="p-4">Tên sản phẩm / Dịch vụ</th>
                <th class="p-4">Nhóm dịch vụ</th>
                <th class="p-4 text-right">Giá nhập</th>
                <th class="p-4 text-right">Giá bán lẻ</th>
                <th class="p-4 text-center">Tồn kho</th>
                <th class="p-4">Trạng thái</th>
                <th class="p-4 text-center w-36">Thao tác</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-purple-50">
              <c:if test="${empty productList}">
                <tr>
                  <td colspan="8" class="p-8 text-center text-zinc-400">
                    <div class="flex flex-col items-center justify-center gap-1.5 text-zinc-400 py-4">
                      <span class="material-symbols-outlined text-[24px]">search_off</span>
                      <span>Không tìm thấy mặt hàng nào phù hợp với bộ lọc tìm kiếm.</span>
                    </div>
                  </td>
                </tr>
              </c:if>
              <c:forEach items="${productList}" var="sp">
                <tr class="hover:bg-purple-50/10 transition-colors reveal-on-scroll">
                  <td class="p-4 font-mono text-[11px] text-zinc-500">${sp.skuCode != null ? sp.skuCode : 'N/A'}</td>
                  <td class="p-4">
                    <div class="flex items-center gap-3">
                      <div class="w-12 h-12 rounded-xl overflow-hidden bg-zinc-100 border border-purple-50 shadow-sm shrink-0 flex items-center justify-center">
                        <c:set var="imgUrl" value="https://images.unsplash.com/photo-1517649763962-0c623066013b?w=150&auto=format&fit=crop&q=60"/>
                        <c:choose>
                          <c:when test="${fn:containsIgnoreCase(sp.tenSanPham, 'Pocari')}">
                            <c:set var="imgUrl" value="https://images.unsplash.com/photo-1548839140-29a749e1cf4d?w=150&auto=format&fit=crop&q=60"/>
                          </c:when>
                          <c:when test="${fn:containsIgnoreCase(sp.tenSanPham, 'Revive') || fn:containsIgnoreCase(sp.tenSanPham, 'Redbull') || fn:containsIgnoreCase(sp.tenSanPham, 'Nước')}">
                            <c:set var="imgUrl" value="https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=150&auto=format&fit=crop&q=60"/>
                          </c:when>
                          <c:when test="${fn:containsIgnoreCase(sp.tenSanPham, 'Aquafina')}">
                            <c:set var="imgUrl" value="https://images.unsplash.com/photo-1608885898957-a599fb18de3e?w=150&auto=format&fit=crop&q=60"/>
                          </c:when>
                          <c:when test="${fn:containsIgnoreCase(sp.tenSanPham, 'Yonex') || fn:containsIgnoreCase(sp.tenSanPham, 'Vợt')}">
                            <c:set var="imgUrl" value="https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=150&auto=format&fit=crop&q=60"/>
                          </c:when>
                          <c:when test="${fn:containsIgnoreCase(sp.tenSanPham, 'VS') || fn:containsIgnoreCase(sp.tenSanPham, 'Quấn')}">
                            <c:set var="imgUrl" value="https://images.unsplash.com/photo-1595257841889-ecea6a1d0543?w=150&auto=format&fit=crop&q=60"/>
                          </c:when>
                          <c:when test="${fn:containsIgnoreCase(sp.tenSanPham, 'Giày')}">
                            <c:set var="imgUrl" value="https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=150&auto=format&fit=crop&q=60"/>
                          </c:when>
                          <c:when test="${fn:containsIgnoreCase(sp.tenSanPham, 'Tất') || fn:containsIgnoreCase(sp.tenSanPham, 'Vớ')}">
                            <c:set var="imgUrl" value="https://images.unsplash.com/photo-1582966772680-860e372bb558?w=150&auto=format&fit=crop&q=60"/>
                          </c:when>
                          <c:when test="${fn:containsIgnoreCase(sp.tenSanPham, 'Cầu lông') || fn:containsIgnoreCase(sp.tenSanPham, 'Quả cầu')}">
                            <c:set var="imgUrl" value="https://images.unsplash.com/photo-1613918431201-496522c04e4e?w=150&auto=format&fit=crop&q=60"/>
                          </c:when>
                        </c:choose>
                        <img src="${imgUrl}" alt="${sp.tenSanPham}" class="w-full h-full object-cover">
                      </div>
                      <div>
                        <p class="font-bold text-zinc-800">${sp.tenSanPham}</p>
                        <c:if test="${not empty sp.moTa}">
                          <p class="text-[10px] text-zinc-400 mt-0.5 truncate max-w-xs">${sp.moTa}</p>
                        </c:if>
                      </div>
                    </div>
                  </td>
                  <td class="p-4">
                    <c:forEach items="${categories}" var="cat">
                      <c:if test="${cat.danhMucID == sp.danhMucID}">
                        <span class="badge badge-purple">${cat.tenDanhMuc}</span>
                      </c:if>
                    </c:forEach>
                  </td>
                  <td class="p-4 text-right font-semibold text-zinc-600">
                    <fmt:formatNumber value="${sp.giaNhap}" pattern="#,##0"/> đ
                  </td>
                  <td class="p-4 text-right font-bold text-purple-950">
                    <fmt:formatNumber value="${sp.donGia}" pattern="#,##0"/> đ
                  </td>
                  <td class="p-4 text-center">
                    <div class="inline-flex flex-col items-center">
                      <span class="font-bold ${sp.soLuongTon == 0 ? 'text-red-600' : (sp.soLuongTon <= 5 ? 'text-amber-600' : 'text-zinc-800')} text-sm">
                        ${sp.soLuongTon}
                      </span>
                      <span class="text-[9px] text-zinc-400 font-medium">${sp.donViTinh != null ? sp.donViTinh : 'cái'}</span>
                    </div>
                  </td>
                  <td class="p-4">
                    <span class="badge <c:choose><c:when test="${sp.trangThai == 'Đang kinh doanh'}">badge-green</c:when><c:when test="${sp.trangThai == 'Tạm hết hàng'}">badge-amber</c:when><c:otherwise>badge-gray</c:otherwise></c:choose>">
                      ${sp.trangThai}
                    </span>
                  </td>
                  <td class="p-4">
                    <div class="flex items-center justify-center gap-1.5">
                      <!-- Stock Adjustment button -->
                      <button onclick="openStockModal(${sp.sanPhamID}, '${sp.skuCode}', '${sp.tenSanPham}', ${sp.soLuongTon}, '${sp.donViTinh}')" class="p-1.5 rounded-lg hover:bg-purple-100 text-purple-700 transition-colors cursor-pointer" title="Nhập / Xuất kho">
                        <span class="material-symbols-outlined text-[18px]">inventory</span>
                      </button>
                      <!-- Edit button -->
                      <button onclick="openEditModal(${sp.sanPhamID}, '${sp.skuCode}', '${sp.tenSanPham}', ${sp.danhMucID}, ${sp.donGia}, ${sp.giaNhap}, '${sp.donViTinh}', ${sp.soLuongTon}, '${sp.trangThai}', '${sp.moTa}')" class="p-1.5 rounded-lg hover:bg-indigo-100 text-indigo-700 transition-colors cursor-pointer" title="Chỉnh sửa">
                        <span class="material-symbols-outlined text-[18px]">edit</span>
                      </button>
                      <!-- Delete button -->
                      <button onclick="confirmDelete(${sp.sanPhamID}, '${sp.tenSanPham}')" class="p-1.5 rounded-lg hover:bg-red-100 text-red-600 transition-colors cursor-pointer" title="Xóa">
                        <span class="material-symbols-outlined text-[18px]">delete</span>
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

<!-- MODALS -->

<!-- Modal 1: Add Product -->
<div id="addModal" class="fixed inset-0 bg-black/50 hidden z-50 items-center justify-center p-4">
  <div class="bg-white rounded-2xl w-full max-w-lg shadow-xl overflow-hidden animate-fadeUp">
    <div class="bg-gradient-to-r from-purple-600 to-indigo-800 px-5 py-4 text-white flex justify-between items-center">
      <div>
        <h3 class="font-bold text-sm flex items-center gap-1.5"><span class="material-symbols-outlined text-[18px]">add_box</span>Thêm mặt hàng mới</h3>
        <p class="text-[10px] text-purple-100 mt-0.5 font-normal">Tạo sản phẩm hoặc dịch vụ bán tại chi nhánh.</p>
      </div>
      <button type="button" onclick="closeAddModal()" class="text-white/80 hover:text-white cursor-pointer shrink-0"><span class="material-symbols-outlined text-[20px]">close</span></button>
    </div>
    <form action="${pageContext.request.contextPath}/manager/kho-dich-vu" method="POST" class="p-5 flex flex-col gap-4 text-xs">
      <input type="hidden" name="action" value="add">
      
      <div class="grid grid-cols-2 gap-3">
        <div>
          <div class="flex justify-between items-center mb-1">
            <label class="block font-semibold text-zinc-700">Mã SKU</label>
            <button type="button" onclick="regenerateAddSku()" class="text-[10px] text-purple-600 hover:underline flex items-center gap-0.5 cursor-pointer">
              <span class="material-symbols-outlined text-[12px]">refresh</span>Tạo lại mã
            </button>
          </div>
          <input type="text" id="addSkuCode" name="skuCode" placeholder="VD: NUOC-LAVIE-500" class="w-full border border-purple-100 rounded-lg p-2.5 bg-zinc-50 focus:outline-none focus:border-purple-500 font-mono">
        </div>
        <div>
          <label class="block font-semibold text-zinc-700 mb-1">Tên mặt hàng *</label>
          <input type="text" name="tenSanPham" maxlength="100" required placeholder="VD: Nước suối Lavie 500ml" class="w-full border border-purple-100 rounded-lg p-2.5 bg-zinc-50 focus:outline-none focus:border-purple-500">
        </div>
      </div>

      <div class="grid grid-cols-2 gap-3">
        <div>
          <label class="block font-semibold text-zinc-700 mb-1">Nhóm dịch vụ *</label>
          <select name="danhMucID" required class="w-full border border-purple-100 rounded-lg p-2.5 bg-zinc-50 focus:outline-none focus:border-purple-500">
            <c:forEach items="${categories}" var="cat">
              <option value="${cat.danhMucID}">${cat.tenDanhMuc}</option>
            </c:forEach>
          </select>
        </div>
        <div>
          <label class="block font-semibold text-zinc-700 mb-1">Đơn vị tính (UOM) *</label>
          <input type="text" name="donViTinh" required placeholder="VD: Chai, Lon, Lượt, Giờ" class="w-full border border-purple-100 rounded-lg p-2.5 bg-zinc-50 focus:outline-none focus:border-purple-500">
        </div>
      </div>

      <div class="grid grid-cols-3 gap-3">
        <div>
          <label class="block font-semibold text-zinc-700 mb-1">Giá nhập (đ) *</label>
          <input type="number" step="any" name="giaNhap" min="0" required placeholder="Giá vốn" class="w-full border border-purple-100 rounded-lg p-2.5 bg-zinc-50 focus:outline-none focus:border-purple-500">
        </div>
        <div>
          <label class="block font-semibold text-zinc-700 mb-1">Giá bán lẻ (đ) *</label>
          <input type="number" step="any" name="donGia" min="0" required placeholder="Giá bán lẻ" class="w-full border border-purple-100 rounded-lg p-2.5 bg-zinc-50 focus:outline-none focus:border-purple-500">
        </div>
        <div>
          <label class="block font-semibold text-zinc-700 mb-1">Số lượng ban đầu</label>
          <input type="number" name="soLuongTon" value="0" min="0" class="w-full border border-purple-100 rounded-lg p-2.5 bg-zinc-50 focus:outline-none focus:border-purple-500">
        </div>
      </div>

      <div class="grid grid-cols-2 gap-3">
        <div>
          <label class="block font-semibold text-zinc-700 mb-1">Trạng thái kinh doanh</label>
          <select name="trangThai" class="w-full border border-purple-100 rounded-lg p-2.5 bg-zinc-50 focus:outline-none focus:border-purple-500">
            <option value="Đang kinh doanh">Đang kinh doanh</option>
            <option value="Tạm hết hàng">Tạm hết hàng</option>
            <option value="Ngừng kinh doanh">Ngừng kinh doanh</option>
          </select>
        </div>
        <div>
          <label class="block font-semibold text-zinc-700 mb-1">Mô tả mặt hàng</label>
          <input type="text" name="moTa" placeholder="Thông tin tóm tắt mặt hàng" class="w-full border border-purple-100 rounded-lg p-2.5 bg-zinc-50 focus:outline-none focus:border-purple-500">
        </div>
      </div>

      <div class="flex gap-2 justify-end mt-2">
        <button type="button" onclick="closeAddModal()" class="px-4 py-2 border border-purple-100 text-zinc-600 rounded-lg hover:bg-zinc-50 font-semibold cursor-pointer">Hủy</button>
        <button type="submit" class="px-5 py-2 bg-purple-600 hover:bg-purple-700 text-white rounded-lg font-bold shadow-sm shadow-purple-100 cursor-pointer">Lưu mặt hàng</button>
      </div>
    </form>
  </div>
</div>

<!-- Modal 2: Edit Product -->
<div id="editModal" class="fixed inset-0 bg-black/50 hidden z-50 items-center justify-center p-4">
  <div class="bg-white rounded-2xl w-full max-w-lg shadow-xl overflow-hidden animate-fadeUp">
    <div class="bg-gradient-to-r from-indigo-600 to-purple-800 px-5 py-4 text-white flex justify-between items-center">
      <div>
        <h3 class="font-bold text-sm flex items-center gap-1.5"><span class="material-symbols-outlined text-[18px]">edit_square</span>Cập nhật mặt hàng</h3>
        <p class="text-[10px] text-indigo-100 mt-0.5 font-normal">Chỉnh sửa thông tin mặt hàng trong kho.</p>
      </div>
      <button type="button" onclick="closeEditModal()" class="text-white/80 hover:text-white cursor-pointer shrink-0"><span class="material-symbols-outlined text-[20px]">close</span></button>
    </div>
    <form action="${pageContext.request.contextPath}/manager/kho-dich-vu" method="POST" class="p-5 flex flex-col gap-4 text-xs">
      <input type="hidden" name="action" value="update">
      <input type="hidden" id="editSanPhamID" name="sanPhamID">
      
      <div class="grid grid-cols-2 gap-3">
        <div>
          <label class="block font-semibold text-zinc-700 mb-1">Mã SKU *</label>
          <input type="text" id="editSkuCode" name="skuCode" required class="w-full border border-purple-100 rounded-lg p-2.5 bg-zinc-50 focus:outline-none focus:border-purple-500 font-mono">
        </div>
        <div>
          <label class="block font-semibold text-zinc-700 mb-1">Tên mặt hàng *</label>
          <input type="text" id="editTenSanPham" name="tenSanPham" maxlength="100" required class="w-full border border-purple-100 rounded-lg p-2.5 bg-zinc-50 focus:outline-none focus:border-purple-500">
        </div>
      </div>

      <div class="grid grid-cols-2 gap-3">
        <div>
          <label class="block font-semibold text-zinc-700 mb-1">Nhóm dịch vụ *</label>
          <select id="editDanhMucID" name="danhMucID" required class="w-full border border-purple-100 rounded-lg p-2.5 bg-zinc-50 focus:outline-none focus:border-purple-500">
            <c:forEach items="${categories}" var="cat">
              <option value="${cat.danhMucID}">${cat.tenDanhMuc}</option>
            </c:forEach>
          </select>
        </div>
        <div>
          <label class="block font-semibold text-zinc-700 mb-1">Đơn vị tính (UOM) *</label>
          <input type="text" id="editDonViTinh" name="donViTinh" required class="w-full border border-purple-100 rounded-lg p-2.5 bg-zinc-50 focus:outline-none focus:border-purple-500">
        </div>
      </div>

      <div class="grid grid-cols-3 gap-3">
        <div>
          <label class="block font-semibold text-zinc-700 mb-1">Giá nhập (đ) *</label>
          <input type="number" step="any" id="editGiaNhap" name="giaNhap" min="0" required class="w-full border border-purple-100 rounded-lg p-2.5 bg-zinc-50 focus:outline-none focus:border-purple-500">
        </div>
        <div>
          <label class="block font-semibold text-zinc-700 mb-1">Giá bán lẻ (đ) *</label>
          <input type="number" step="any" id="editDonGia" name="donGia" min="0" required class="w-full border border-purple-100 rounded-lg p-2.5 bg-zinc-50 focus:outline-none focus:border-purple-500">
        </div>
        <div>
          <label class="block font-semibold text-zinc-700 mb-1">Số lượng tồn kho</label>
          <input type="number" id="editSoLuongTon" name="soLuongTon" min="0" required class="w-full border border-purple-100 rounded-lg p-2.5 bg-zinc-50 focus:outline-none focus:border-purple-500">
        </div>
      </div>

      <div class="grid grid-cols-2 gap-3">
        <div>
          <label class="block font-semibold text-zinc-700 mb-1">Trạng thái kinh doanh</label>
          <select id="editTrangThai" name="trangThai" class="w-full border border-purple-100 rounded-lg p-2.5 bg-zinc-50 focus:outline-none focus:border-purple-500">
            <option value="Đang kinh doanh">Đang kinh doanh</option>
            <option value="Tạm hết hàng">Tạm hết hàng</option>
            <option value="Ngừng kinh doanh">Ngừng kinh doanh</option>
          </select>
        </div>
        <div>
          <label class="block font-semibold text-zinc-700 mb-1">Mô tả mặt hàng</label>
          <input type="text" id="editMoTa" name="moTa" class="w-full border border-purple-100 rounded-lg p-2.5 bg-zinc-50 focus:outline-none focus:border-purple-500">
        </div>
      </div>

      <div class="flex gap-2 justify-end mt-2">
        <button type="button" onclick="closeEditModal()" class="px-4 py-2 border border-purple-100 text-zinc-600 rounded-lg hover:bg-zinc-50 font-semibold cursor-pointer">Hủy</button>
        <button type="submit" class="px-5 py-2 bg-indigo-600 hover:bg-indigo-700 text-white rounded-lg font-bold shadow-sm shadow-indigo-100 cursor-pointer">Cập nhật mặt hàng</button>
      </div>
    </form>
  </div>
</div>

<!-- Modal 3: Stock In / Out Adjustment -->
<div id="stockModal" class="fixed inset-0 bg-black/50 hidden z-50 items-center justify-center p-4">
  <div class="bg-white rounded-2xl w-full max-w-md shadow-xl overflow-hidden animate-fadeUp">
    <div class="bg-gradient-to-r from-zinc-800 to-zinc-950 px-5 py-4 text-white flex justify-between items-center gap-3">
      <h3 class="font-bold text-sm flex items-center gap-1.5"><span class="material-symbols-outlined text-[18px]">published_with_changes</span>Điều chỉnh kho</h3>
      <button type="button" onclick="closeStockModal()" class="text-white/80 hover:text-white cursor-pointer shrink-0"><span class="material-symbols-outlined text-[20px]">close</span></button>
    </div>
    
    <div class="p-4 bg-zinc-50 border-b border-zinc-200 text-xs">
      <p class="text-[10px] text-zinc-400 uppercase font-bold tracking-wider">THÔNG TIN SẢN PHẨM</p>
      <p class="font-bold text-zinc-800 text-sm mt-0.5" id="stockProdName">Nước khoáng</p>
      <div class="flex gap-4 mt-1.5 text-[11px] text-zinc-500">
        <span>Mã SKU: <span class="font-mono text-zinc-700 font-semibold" id="stockProdSku">SP-01</span></span>
        <span>Số lượng hiện tại: <span class="font-bold text-purple-700" id="stockProdQty">10</span> <span id="stockProdUnit">chai</span></span>
      </div>
    </div>

    <!-- Toggle Action form -->
    <div class="p-5">
      <div class="flex gap-2 p-1 bg-zinc-100 rounded-xl mb-4 text-xs font-semibold">
        <button onclick="setStockAction('nhap-kho')" id="btnActionNhap" class="flex-1 py-2 text-center rounded-lg bg-white text-zinc-800 shadow-sm border border-zinc-200">
          Nhập kho (+)
        </button>
        <button onclick="setStockAction('xuat-kho')" id="btnActionXuat" class="flex-1 py-2 text-center rounded-lg text-zinc-500 hover:bg-white/50">
          Xuất kho (-)
        </button>
      </div>

      <form action="${pageContext.request.contextPath}/manager/kho-dich-vu" method="POST" class="flex flex-col gap-4 text-xs">
        <input type="hidden" name="action" id="stockFormAction" value="nhap-kho">
        <input type="hidden" name="id" id="stockProdId">

        <div>
          <label class="block font-semibold text-zinc-700 mb-1" id="lblStockQty">Số lượng cần nhập thêm *</label>
          <input type="number" name="amount" min="1" required placeholder="Nhập số lượng..." class="w-full border border-purple-100 rounded-lg p-2.5 bg-zinc-50 focus:outline-none focus:border-purple-500 font-bold text-sm">
        </div>

        <div>
          <label class="block font-semibold text-zinc-700 mb-1">Ghi chú điều chỉnh</label>
          <input type="text" name="note" placeholder="Nhập lý do điều chỉnh..." class="w-full border border-purple-100 rounded-lg p-2.5 bg-zinc-50 focus:outline-none focus:border-purple-500">
        </div>

        <div class="flex gap-2 justify-end mt-2">
          <button type="button" onclick="closeStockModal()" class="px-4 py-2 border border-purple-100 text-zinc-600 rounded-lg hover:bg-zinc-50 font-semibold">Hủy</button>
          <button type="submit" id="btnStockSubmit" class="px-5 py-2 bg-zinc-900 hover:bg-zinc-850 text-white rounded-lg font-bold shadow-sm">Xác nhận điều chỉnh</button>
        </div>
      </form>
    </div>
  </div>
</div>

<!-- Modal 4: Manage Categories -->
<div id="categoryModal" class="fixed inset-0 bg-black/50 hidden z-50 items-center justify-center p-4">
  <div class="bg-white rounded-2xl w-full max-w-sm shadow-xl overflow-hidden animate-fadeUp">
    <div class="bg-gradient-to-r from-purple-700 to-indigo-900 px-5 py-4 text-white flex justify-between items-center gap-3">
      <div>
        <h3 class="font-bold text-sm flex items-center gap-1.5"><span class="material-symbols-outlined text-[18px]">category</span>Quản lý nhóm dịch vụ</h3>
        <p class="text-[10px] text-purple-100 mt-0.5 font-normal">Tạo nhóm để phân loại mặt hàng, ví dụ Đồ uống, Thuê dụng cụ, Đồ ăn.</p>
      </div>
      <button onclick="closeCategoryModal()" class="text-white/80 hover:text-white cursor-pointer shrink-0"><span class="material-symbols-outlined text-[20px]">close</span></button>
    </div>
    
    <div class="p-5 flex flex-col gap-4 text-xs">
      <div>
        <p class="font-semibold text-zinc-700 mb-2">Danh sách nhóm dịch vụ hiện tại:</p>
        <div class="max-h-48 overflow-y-auto border border-purple-100 rounded-xl p-3 bg-zinc-50/50 space-y-2">
          <c:forEach items="${categories}" var="cat">
            <div class="flex items-center justify-between p-2.5 rounded-lg bg-white border border-purple-100/40 hover:border-purple-300 hover:shadow-sm transition-all group">
              <div class="flex items-center gap-2">
                <span class="material-symbols-outlined text-[16px] text-purple-650">label</span>
                <span class="font-medium text-zinc-700">${cat.tenDanhMuc}</span>
              </div>
            </div>
          </c:forEach>
        </div>
      </div>

      <div class="border-t border-purple-50 pt-4">
        <form action="${pageContext.request.contextPath}/manager/kho-dich-vu" method="POST" onsubmit="return handleAddCategory(event)" class="flex flex-col gap-3">
          <input type="hidden" name="action" value="add-category">
          <div>
            <label class="block font-semibold text-zinc-700 mb-1">Thêm nhóm dịch vụ mới *</label>
            <input type="text" name="tenDanhMuc" id="newCatName" required placeholder="VD: Đồ uống" class="w-full border border-purple-100 rounded-lg p-2.5 bg-zinc-50 focus:outline-none focus:border-purple-500">
          </div>
          <button type="submit" class="w-full bg-purple-600 hover:bg-purple-700 text-white font-bold py-2.5 rounded-lg shadow-sm transition-colors cursor-pointer">
            Tạo nhóm dịch vụ
          </button>
        </form>
      </div>
    </div>
  </div>
</div>

<!-- Modal 5: Quick Add Preset Products -->
<div id="presetModal" class="fixed inset-0 bg-black/50 hidden z-50 items-center justify-center p-4">
  <div class="bg-white rounded-2xl w-full max-w-2xl shadow-xl overflow-hidden animate-fadeUp flex flex-col max-h-[85vh]">
    <div class="bg-gradient-to-r from-indigo-600 to-purple-800 px-5 py-4 text-white flex justify-between items-center shrink-0">
      <div>
        <h3 class="font-bold text-sm flex items-center gap-1.5"><span class="material-symbols-outlined text-[18px]">bolt</span>Thêm nhanh từ mẫu có sẵn</h3>
        <p class="text-[10px] text-indigo-100 mt-0.5 font-normal">Chọn các mặt hàng thường bán tại sân để thêm nhanh vào kho dịch vụ của chi nhánh.</p>
      </div>
      <button type="button" onclick="closePresetModal()" class="text-white/80 hover:text-white cursor-pointer shrink-0"><span class="material-symbols-outlined text-[20px]">close</span></button>
    </div>
    
    <form action="${pageContext.request.contextPath}/manager/kho-dich-vu" method="POST" class="flex flex-col flex-1 min-h-0">
      <input type="hidden" name="action" value="add-presets">
      
      <div class="p-5 overflow-y-auto flex-1 text-xs">
        <div class="bg-amber-50 border border-amber-200 text-amber-850 p-2.5 rounded-lg mb-3 flex items-center gap-1.5 text-[10px]">
          <span class="material-symbols-outlined text-[14px]">info</span>
          <span>💡 <strong>Lưu ý:</strong> Bạn có thể chỉnh lại giá bán và số lượng tồn kho sau khi thêm trong bảng danh sách.</span>
        </div>

        <table class="w-full text-left border-collapse">
          <thead>
            <tr class="bg-zinc-50 text-zinc-500 font-bold border-b border-zinc-200">
              <th class="p-3 w-[55%]">Tên mặt hàng mẫu</th>
              <th class="p-3">Nhóm dịch vụ</th>
              <th class="p-3">Đơn vị tính</th>
              <th class="p-3 text-right">Giá bán lẻ gợi ý</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-zinc-100">
            <!-- Category: Đồ uống -->
            <tr class="bg-purple-50/30 font-bold text-purple-950 text-[10px] tracking-wider">
              <td colspan="4" class="p-2.5">
                <div class="flex items-center gap-1.5 uppercase">
                  <span class="material-symbols-outlined text-[14px]">local_cafe</span> Đồ uống
                </div>
              </td>
            </tr>
            <tr class="hover:bg-purple-50/10 transition-colors">
              <td class="p-3">
                <div class="flex items-center gap-2.5">
                  <input type="checkbox" class="preset-checkbox w-4 h-4 text-purple-600 rounded border-zinc-300 focus:ring-purple-500 cursor-pointer" onchange="togglePresetRow(this)">
                  <span class="font-bold text-zinc-800">Nước tinh khiết Aquafina 500ml</span>
                </div>
                <input type="hidden" name="presetNames" value="Nước tinh khiết Aquafina 500ml">
                <input type="hidden" name="presetCatNames" value="Nước uống">
                <input type="hidden" name="presetUnits" value="chai">
                <input type="hidden" name="presetGiaNhaps" value="5000">
                <input type="hidden" name="presetDonGias" value="10000">
                <input type="hidden" name="presetStocks" class="preset-stock-input" value="0">
              </td>
              <td class="p-3 text-zinc-500">Nước uống</td>
              <td class="p-3 text-zinc-500">chai</td>
              <td class="p-3 text-right font-bold text-purple-950">10,000 đ</td>
            </tr>
            <tr class="hover:bg-purple-50/10 transition-colors">
              <td class="p-3">
                <div class="flex items-center gap-2.5">
                  <input type="checkbox" class="preset-checkbox w-4 h-4 text-purple-600 rounded border-zinc-300 focus:ring-purple-500 cursor-pointer" onchange="togglePresetRow(this)">
                  <span class="font-bold text-zinc-800">Nước ngọt Coca-Cola lon</span>
                </div>
                <input type="hidden" name="presetNames" value="Nước ngọt Coca-Cola lon">
                <input type="hidden" name="presetCatNames" value="Nước uống">
                <input type="hidden" name="presetUnits" value="lon">
                <input type="hidden" name="presetGiaNhaps" value="8000">
                <input type="hidden" name="presetDonGias" value="12000">
                <input type="hidden" name="presetStocks" class="preset-stock-input" value="0">
              </td>
              <td class="p-3 text-zinc-500">Nước uống</td>
              <td class="p-3 text-zinc-500">lon</td>
              <td class="p-3 text-right font-bold text-purple-950">12,000 đ</td>
            </tr>
            <tr class="hover:bg-purple-50/10 transition-colors">
              <td class="p-3">
                <div class="flex items-center gap-2.5">
                  <input type="checkbox" class="preset-checkbox w-4 h-4 text-purple-600 rounded border-zinc-300 focus:ring-purple-500 cursor-pointer" onchange="togglePresetRow(this)">
                  <span class="font-bold text-zinc-800">Trà xanh Không Độ chai</span>
                </div>
                <input type="hidden" name="presetNames" value="Trà xanh Không Độ chai">
                <input type="hidden" name="presetCatNames" value="Nước uống">
                <input type="hidden" name="presetUnits" value="chai">
                <input type="hidden" name="presetGiaNhaps" value="8000">
                <input type="hidden" name="presetDonGias" value="12000">
                <input type="hidden" name="presetStocks" class="preset-stock-input" value="0">
              </td>
              <td class="p-3 text-zinc-500">Nước uống</td>
              <td class="p-3 text-zinc-500">chai</td>
              <td class="p-3 text-right font-bold text-purple-950">12,000 đ</td>
            </tr>
            <tr class="hover:bg-purple-50/10 transition-colors">
              <td class="p-3">
                <div class="flex items-center gap-2.5">
                  <input type="checkbox" class="preset-checkbox w-4 h-4 text-purple-600 rounded border-zinc-300 focus:ring-purple-500 cursor-pointer" onchange="togglePresetRow(this)">
                  <span class="font-bold text-zinc-800">Nước bù khoáng Revive 500ml</span>
                </div>
                <input type="hidden" name="presetNames" value="Nước bù khoáng Revive 500ml">
                <input type="hidden" name="presetCatNames" value="Nước uống">
                <input type="hidden" name="presetUnits" value="chai">
                <input type="hidden" name="presetGiaNhaps" value="8000">
                <input type="hidden" name="presetDonGias" value="12000">
                <input type="hidden" name="presetStocks" class="preset-stock-input" value="0">
              </td>
              <td class="p-3 text-zinc-500">Nước uống</td>
              <td class="p-3 text-zinc-500">chai</td>
              <td class="p-3 text-right font-bold text-purple-950">12,000 đ</td>
            </tr>

            <!-- Category: Thuê dụng cụ -->
            <tr class="bg-purple-50/30 font-bold text-purple-950 text-[10px] tracking-wider border-t border-zinc-200">
              <td colspan="4" class="p-2.5">
                <div class="flex items-center gap-1.5 uppercase">
                  <span class="material-symbols-outlined text-[14px]">sports_tennis</span> Thuê dụng cụ
                </div>
              </td>
            </tr>
            <tr class="hover:bg-purple-50/10 transition-colors">
              <td class="p-3">
                <div class="flex items-center gap-2.5">
                  <input type="checkbox" class="preset-checkbox w-4 h-4 text-purple-600 rounded border-zinc-300 focus:ring-purple-500 cursor-pointer" onchange="togglePresetRow(this)">
                  <span class="font-bold text-zinc-800">Thuê vợt cầu lông Yonex</span>
                </div>
                <input type="hidden" name="presetNames" value="Thuê vợt cầu lông Yonex">
                <input type="hidden" name="presetCatNames" value="Thuê dụng cụ">
                <input type="hidden" name="presetUnits" value="lượt">
                <input type="hidden" name="presetGiaNhaps" value="0">
                <input type="hidden" name="presetDonGias" value="30000">
                <input type="hidden" name="presetStocks" class="preset-stock-input" value="0">
              </td>
              <td class="p-3 text-zinc-500">Thuê dụng cụ</td>
              <td class="p-3 text-zinc-500">lượt</td>
              <td class="p-3 text-right font-bold text-purple-950">30,000 đ</td>
            </tr>
            <tr class="hover:bg-purple-50/10 transition-colors">
              <td class="p-3">
                <div class="flex items-center gap-2.5">
                  <input type="checkbox" class="preset-checkbox w-4 h-4 text-purple-600 rounded border-zinc-300 focus:ring-purple-500 cursor-pointer" onchange="togglePresetRow(this)">
                  <span class="font-bold text-zinc-800">Thuê quả bóng đá size 5</span>
                </div>
                <input type="hidden" name="presetNames" value="Thuê quả bóng đá size 5">
                <input type="hidden" name="presetCatNames" value="Thuê dụng cụ">
                <input type="hidden" name="presetUnits" value="lượt">
                <input type="hidden" name="presetGiaNhaps" value="0">
                <input type="hidden" name="presetDonGias" value="40000">
                <input type="hidden" name="presetStocks" class="preset-stock-input" value="0">
              </td>
              <td class="p-3 text-zinc-500">Thuê dụng cụ</td>
              <td class="p-3 text-zinc-500">lượt</td>
              <td class="p-3 text-right font-bold text-purple-950">40,000 đ</td>
            </tr>
            <tr class="hover:bg-purple-50/10 transition-colors">
              <td class="p-3">
                <div class="flex items-center gap-2.5">
                  <input type="checkbox" class="preset-checkbox w-4 h-4 text-purple-600 rounded border-zinc-300 focus:ring-purple-500 cursor-pointer" onchange="togglePresetRow(this)">
                  <span class="font-bold text-zinc-800">Thuê giày thể thao cơ bản</span>
                </div>
                <input type="hidden" name="presetNames" value="Thuê giày thể thao cơ bản">
                <input type="hidden" name="presetCatNames" value="Thuê dụng cụ">
                <input type="hidden" name="presetUnits" value="đôi">
                <input type="hidden" name="presetGiaNhaps" value="0">
                <input type="hidden" name="presetDonGias" value="25000">
                <input type="hidden" name="presetStocks" class="preset-stock-input" value="0">
              </td>
              <td class="p-3 text-zinc-500">Thuê dụng cụ</td>
              <td class="p-3 text-zinc-500">đôi</td>
              <td class="p-3 text-right font-bold text-purple-950">25,000 đ</td>
            </tr>
            <tr class="hover:bg-purple-50/10 transition-colors">
              <td class="p-3">
                <div class="flex items-center gap-2.5">
                  <input type="checkbox" class="preset-checkbox w-4 h-4 text-purple-600 rounded border-zinc-300 focus:ring-purple-500 cursor-pointer" onchange="togglePresetRow(this)">
                  <span class="font-bold text-zinc-800">Thuê áo tập / áo bib đấu</span>
                </div>
                <input type="hidden" name="presetNames" value="Thuê áo tập / áo bib đấu">
                <input type="hidden" name="presetCatNames" value="Thuê dụng cụ">
                <input type="hidden" name="presetUnits" value="bộ">
                <input type="hidden" name="presetGiaNhaps" value="0">
                <input type="hidden" name="presetDonGias" value="10000">
                <input type="hidden" name="presetStocks" class="preset-stock-input" value="0">
              </td>
              <td class="p-3 text-zinc-500">Thuê dụng cụ</td>
              <td class="p-3 text-zinc-500">bộ</td>
              <td class="p-3 text-right font-bold text-purple-950">10,000 đ</td>
            </tr>

            <!-- Category: Dịch vụ khác -->
            <tr class="bg-purple-50/30 font-bold text-purple-950 text-[10px] tracking-wider border-t border-zinc-200">
              <td colspan="4" class="p-2.5">
                <div class="flex items-center gap-1.5 uppercase">
                  <span class="material-symbols-outlined text-[14px]">more_horiz</span> Dịch vụ khác
                </div>
              </td>
            </tr>
            <tr class="hover:bg-purple-50/10 transition-colors">
              <td class="p-3">
                <div class="flex items-center gap-2.5">
                  <input type="checkbox" class="preset-checkbox w-4 h-4 text-purple-600 rounded border-zinc-300 focus:ring-purple-500 cursor-pointer" onchange="togglePresetRow(this)">
                  <span class="font-bold text-zinc-800">Khăn lạnh lau mặt</span>
                </div>
                <input type="hidden" name="presetNames" value="Khăn lạnh lau mặt">
                <input type="hidden" name="presetCatNames" value="Dịch vụ khác">
                <input type="hidden" name="presetUnits" value="cái">
                <input type="hidden" name="presetGiaNhaps" value="1500">
                <input type="hidden" name="presetDonGias" value="5000">
                <input type="hidden" name="presetStocks" class="preset-stock-input" value="0">
              </td>
              <td class="p-3 text-zinc-500">Dịch vụ khác</td>
              <td class="p-3 text-zinc-500">cái</td>
              <td class="p-3 text-right font-bold text-purple-950">5,000 đ</td>
            </tr>
            <tr class="hover:bg-purple-50/10 transition-colors">
              <td class="p-3">
                <div class="flex items-center gap-2.5">
                  <input type="checkbox" class="preset-checkbox w-4 h-4 text-purple-600 rounded border-zinc-300 focus:ring-purple-500 cursor-pointer" onchange="togglePresetRow(this)">
                  <span class="font-bold text-zinc-800">Phí gửi xe máy/ô tô</span>
                </div>
                <input type="hidden" name="presetNames" value="Phí gửi xe máy/ô tô">
                <input type="hidden" name="presetCatNames" value="Dịch vụ khác">
                <input type="hidden" name="presetUnits" value="lượt">
                <input type="hidden" name="presetGiaNhaps" value="0">
                <input type="hidden" name="presetDonGias" value="5000">
                <input type="hidden" name="presetStocks" class="preset-stock-input" value="0">
              </td>
              <td class="p-3 text-zinc-500">Dịch vụ khác</td>
              <td class="p-3 text-zinc-500">lượt</td>
              <td class="p-3 text-right font-bold text-purple-950">5,000 đ</td>
            </tr>
            <tr class="hover:bg-purple-50/10 transition-colors">
              <td class="p-3">
                <div class="flex items-center gap-2.5">
                  <input type="checkbox" class="preset-checkbox w-4 h-4 text-purple-600 rounded border-zinc-300 focus:ring-purple-500 cursor-pointer" onchange="togglePresetRow(this)">
                  <span class="font-bold text-zinc-800">Phụ thu tiền điện chiếu sáng</span>
                </div>
                <input type="hidden" name="presetNames" value="Phụ thu tiền điện chiếu sáng">
                <input type="hidden" name="presetCatNames" value="Dịch vụ khác">
                <input type="hidden" name="presetUnits" value="ca">
                <input type="hidden" name="presetGiaNhaps" value="0">
                <input type="hidden" name="presetDonGias" value="50000">
                <input type="hidden" name="presetStocks" class="preset-stock-input" value="0">
              </td>
              <td class="p-3 text-zinc-500">Dịch vụ khác</td>
              <td class="p-3 text-zinc-500">ca</td>
              <td class="p-3 text-right font-bold text-purple-950">50,000 đ</td>
            </tr>
          </tbody>
        </table>
      </div>
      
      <div class="px-5 py-4 bg-zinc-50 border-t border-zinc-200 flex gap-2 justify-end shrink-0">
        <button type="button" onclick="closePresetModal()" class="px-4 py-2 border border-zinc-200 text-zinc-650 rounded-lg hover:bg-zinc-100 font-semibold cursor-pointer">Hủy</button>
        <button type="submit" id="presetSubmitBtn" disabled class="px-5 py-2 bg-indigo-600 hover:bg-indigo-700 text-white rounded-lg font-bold shadow-md shadow-indigo-100 opacity-50 cursor-not-allowed transition-all">Thêm các mẫu đã chọn</button>
      </div>
    </form>
  </div>
</div>

<script>
  // Mobile menu toggle
  document.getElementById('mobileMenuBtn').addEventListener('click', () => {
    document.getElementById('sidebar').classList.toggle('-translate-x-full');
  });

  // Helper to generate a random SKU code suffix
  function generateRandomSku() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    let rand = '';
    for (let i = 0; i < 6; i++) {
      rand += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return 'SKU-' + rand;
  }

  function regenerateAddSku() {
    document.getElementById('addSkuCode').value = generateRandomSku();
  }

  // Modal open/close actions
  function openAddModal() {
    document.getElementById('addModal').classList.remove('hidden');
    document.getElementById('addModal').classList.add('flex');
    // Pre-populate random SKU code
    regenerateAddSku();
  }
  function closeAddModal() {
    document.getElementById('addModal').classList.add('hidden');
    document.getElementById('addModal').classList.remove('flex');
  }

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

  function openStockModal(id, sku, name, currentStock, unit) {
    document.getElementById('stockProdId').value = id;
    document.getElementById('stockProdSku').innerText = sku;
    document.getElementById('stockProdName').innerText = name;
    document.getElementById('stockProdQty').innerText = currentStock;
    document.getElementById('stockProdUnit').innerText = unit ? unit : 'cái';
    
    // Reset modal state to 'nhap-kho'
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
    const btnNhap = document.getElementById('btnActionNhap');
    const btnXuat = document.getElementById('btnActionXuat');
    const lblQty = document.getElementById('lblStockQty');
    const btnSubmit = document.getElementById('btnStockSubmit');

    if (action === 'nhap-kho') {
      btnNhap.className = "flex-1 py-2 text-center rounded-lg bg-white text-zinc-800 shadow-sm border border-zinc-200";
      btnXuat.className = "flex-1 py-2 text-center rounded-lg text-zinc-500 hover:bg-white/50";
      lblQty.innerText = "Số lượng cần nhập thêm *";
      btnSubmit.innerText = "Xác nhận nhập kho";
      btnSubmit.className = "px-5 py-2 bg-purple-600 hover:bg-purple-700 text-white rounded-lg font-bold shadow-sm shadow-purple-100";
    } else {
      btnXuat.className = "flex-1 py-2 text-center rounded-lg bg-white text-zinc-800 shadow-sm border border-zinc-200";
      btnNhap.className = "flex-1 py-2 text-center rounded-lg text-zinc-500 hover:bg-white/50";
      lblQty.innerText = "Số lượng cần xuất giảm *";
      btnSubmit.innerText = "Xác nhận xuất kho";
      btnSubmit.className = "px-5 py-2 bg-zinc-900 hover:bg-zinc-800 text-white rounded-lg font-bold shadow-sm";
    }
  }

  const existingCategories = [
    <c:forEach items="${categories}" var="cat" varStatus="loop">
      '${cat.tenDanhMuc.trim().toLowerCase()}'${!loop.last ? ',' : ''}
    </c:forEach>
  ];

  function handleAddCategory(event) {
    const input = event.target.querySelector('input[name="tenDanhMuc"]');
    const catName = input.value.trim().toLowerCase();
    if (existingCategories.includes(catName)) {
      alert('Danh mục "' + input.value.trim() + '" này đã tồn tại!');
      return false;
    }
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

  function togglePresetRow(checkbox) {
    const row = checkbox.closest('tr');
    const stockHidden = row.querySelector('.preset-stock-input');
    const name = row.querySelector('input[name="presetNames"]').value;
    
    if (checkbox.checked) {
      if (name.includes('Phí gửi') || name.includes('Phụ thu')) {
        stockHidden.value = '1';
      } else if (name.includes('Thuê')) {
        stockHidden.value = '5';
      } else {
        stockHidden.value = '10';
      }
      row.classList.add('bg-purple-50/40');
    } else {
      stockHidden.value = '0';
      row.classList.remove('bg-purple-50/40');
    }
    validatePresetSelection();
  }

  function validatePresetSelection() {
    const checkboxes = document.querySelectorAll('.preset-checkbox');
    const submitBtn = document.getElementById('presetSubmitBtn');
    let anyChecked = false;
    checkboxes.forEach(cb => {
      if (cb.checked) anyChecked = true;
    });
    
    if (anyChecked) {
      submitBtn.disabled = false;
      submitBtn.classList.remove('opacity-50', 'cursor-not-allowed');
      submitBtn.classList.add('cursor-pointer');
    } else {
      submitBtn.disabled = true;
      submitBtn.classList.add('opacity-50', 'cursor-not-allowed');
      submitBtn.classList.remove('cursor-pointer');
    }
  }

  function openPresetModal() {
    const checkboxes = document.querySelectorAll('.preset-checkbox');
    checkboxes.forEach(cb => {
      cb.checked = false;
      const row = cb.closest('tr');
      row.classList.remove('bg-purple-50/40');
    });
    const stocks = document.querySelectorAll('.preset-stock-input');
    stocks.forEach(input => input.value = 0);
    validatePresetSelection();
    
    document.getElementById('presetModal').classList.remove('hidden');
    document.getElementById('presetModal').classList.add('flex');
  }
  function closePresetModal() {
    document.getElementById('presetModal').classList.add('hidden');
    document.getElementById('presetModal').classList.remove('flex');
  }

  function confirmDelete(id, name) {
    showCustomConfirm("Bạn có chắc chắn muốn xóa sản phẩm/dịch vụ '" + name + "'? Sản phẩm sẽ được chuyển vào Thùng rác.", () => {
      showToast("Đang thực hiện xóa... Bạn có thể vào Thùng rác để khôi phục.", "success");
      const form = document.createElement('form');
      form.method = 'POST';
      form.action = '${pageContext.request.contextPath}/manager/kho-dich-vu';
      
      const actionInput = document.createElement('input');
      actionInput.type = 'hidden';
      actionInput.name = 'action';
      actionInput.value = 'delete';
      form.appendChild(actionInput);
      
      const idInput = document.createElement('input');
      idInput.type = 'hidden';
      idInput.name = 'id';
      idInput.value = id;
      form.appendChild(idInput);
      
      document.body.appendChild(form);
      setTimeout(() => {
        form.submit();
      }, 1200);
    });
  }

  // Scroll Animation Observer
  document.addEventListener("DOMContentLoaded", function() {
    const observer = new IntersectionObserver((entries) => {
      entries.forEach((entry, index) => {
        if (entry.isIntersecting) {
          setTimeout(() => {
            entry.target.classList.add("revealed");
          }, index * 40);
          observer.unobserve(entry.target);
        }
      });
    }, {
      threshold: 0.05,
      rootMargin: "0px 0px -10px 0px"
    });

    document.querySelectorAll(".reveal-on-scroll").forEach(el => {
      observer.observe(el);
    });
  });

  // Reload page when navigated back/forward via bfcache
  window.addEventListener('pageshow', function(event) {
    if (event.persisted) {
      window.location.reload();
    }
  });
</script>
</body>
</html>
