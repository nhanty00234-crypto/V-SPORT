<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    String ctx = request.getContextPath();
    String formAction = (String) request.getAttribute("formAction");
    boolean isForm = formAction != null;
%>
<!DOCTYPE html>
<html lang="vi">
<head>
<title>Khuyến mãi — Manager</title>
<jsp:include page="/manager/common/manager_head.jsp" />
<style>
body { background-color: #f8fafc !important; }
.badge { display:inline-flex;align-items:center;padding:3px 10px;border-radius:8px;font-size:11px;font-weight:600; }
.badge-green { background:#dcfce7;color:#15803d; }
.badge-amber { background:#fef3c7;color:#b45309; }
.badge-gray  { background:#f4f4f5;color:#52525b; }
.tbl-row { transition:background .12s; }
.tbl-row:hover { background:#faf5ff; }
.form-field label { display:block;font-size:13px;font-weight:600;color:#374151;margin-bottom:4px; }
.form-field input, .form-field select, .form-field textarea {
    width:100%;border:1px solid #e5e7eb;border-radius:8px;padding:8px 12px;
    font-size:14px;color:#111827;outline:none;transition:border-color .15s;
}
.form-field input:focus, .form-field select:focus, .form-field textarea:focus {
    border-color:#2563eb;box-shadow:0 0 0 3px rgba(37,99,235,.1);
}
</style>
</head>
<body class="text-zinc-900 min-h-screen">

<jsp:include page="/manager/common/sidebar.jsp" />

<c:set var="headerTitle"    value="Khuyến mãi" scope="page" />
<c:set var="headerSubtitle" value="Quản lý mã giảm giá của cơ sở" scope="page" />
<c:set var="headerIcon"     value="local_offer" scope="page" />
<jsp:include page="/manager/common/header.jsp" />

<main class="lg:ml-[248px] mt-[64px] p-4 lg:p-6 flex flex-col gap-5">

  <%-- Flash --%>
  <c:if test="${not empty sessionScope.flashSuccess}">
    <div class="rounded-xl px-4 py-3 bg-green-50 border border-green-200 text-green-800 text-sm font-medium">${sessionScope.flashSuccess}</div>
    <% session.removeAttribute("flashSuccess"); %>
  </c:if>
  <c:if test="${not empty sessionScope.flashError}">
    <div class="rounded-xl px-4 py-3 bg-red-50 border border-red-200 text-red-800 text-sm font-medium">${sessionScope.flashError}</div>
    <% session.removeAttribute("flashError"); %>
  </c:if>
  <c:if test="${not empty errors}">
    <div class="rounded-xl px-4 py-3 bg-red-50 border border-red-200 text-red-800 text-sm">
      <ul class="list-disc pl-4 space-y-1">
        <c:forEach var="err" items="${errors}"><li><c:out value="${err}"/></li></c:forEach>
      </ul>
    </div>
  </c:if>

  <%-- ===== FORM (create / update) ===== --%>
  <% if (isForm) { %>
  <div class="bg-white border border-zinc-200 rounded-2xl p-6">
    <div class="flex items-center justify-between mb-6">
      <h2 class="text-lg font-bold">${formAction eq 'create' ? 'Tạo mã khuyến mãi' : 'Cập nhật mã khuyến mãi'}</h2>
      <a href="<%= ctx %>/manager/khuyen-mai" class="text-sm text-zinc-500 hover:text-zinc-900">← Quay lại</a>
    </div>

    <form method="post" action="<%= ctx %>/manager/khuyen-mai?action=${formAction}" class="grid grid-cols-1 md:grid-cols-2 gap-5">
      <c:if test="${not empty km.khuyenMaiID and km.khuyenMaiID > 0}">
        <input type="hidden" name="khuyenMaiId" value="${km.khuyenMaiID}">
      </c:if>

      <div class="form-field">
        <label>Mã code <span class="text-red-500">*</span></label>
        <input type="text" name="maCode" value="<c:out value='${km.maCode}'/>"
               placeholder="VD: SUMMER2025" maxlength="50" required
               style="text-transform:uppercase">
        <p class="text-xs text-zinc-400 mt-1">Tự động chuyển chữ hoa. Tối đa 50 ký tự.</p>
      </div>

      <div class="form-field">
        <label>Mô tả</label>
        <input type="text" name="moTa" value="<c:out value='${km.moTa}'/>" maxlength="255" placeholder="Giảm 20% dịp hè">
      </div>

      <div class="form-field">
        <label>Loại giảm <span class="text-red-500">*</span></label>
        <select name="loaiGiam" required>
          <option value="">-- Chọn loại --</option>
          <option value="PhanTram" ${km.loaiGiam eq 'PhanTram' ? 'selected' : ''}>Phần trăm (%)</option>
          <option value="SoTien"   ${km.loaiGiam eq 'SoTien'   ? 'selected' : ''}>Số tiền (VND)</option>
        </select>
      </div>

      <div class="form-field">
        <label>Giá trị giảm <span class="text-red-500">*</span></label>
        <input type="number" name="giaTriGiam" value="${km.giaTriGiam}"
               step="0.01" min="0" placeholder="20" required>
      </div>

      <div class="form-field">
        <label>Ngày bắt đầu <span class="text-red-500">*</span></label>
        <input type="date" name="ngayBatDau"
               value="${km.ngayBatDau}" required>
      </div>

      <div class="form-field">
        <label>Ngày kết thúc <span class="text-red-500">*</span></label>
        <input type="date" name="ngayKetThuc"
               value="${km.ngayKetThuc}" required>
      </div>

      <div class="form-field">
        <label>Số lần tối đa</label>
        <input type="number" name="soLanToiDa" value="${km.soLanToiDa}"
               min="0" placeholder="Để trống = không giới hạn">
      </div>

      <c:if test="${formAction eq 'update'}">
      <div class="form-field">
        <label>Trạng thái</label>
        <select name="trangThai">
          <option value="Hoạt động" ${km.trangThai eq 'Hoạt động' ? 'selected' : ''}>Hoạt động</option>
          <option value="Ngừng hoạt động" ${km.trangThai eq 'Ngừng hoạt động' ? 'selected' : ''}>Ngừng hoạt động</option>
        </select>
      </div>
      </c:if>

      <div class="md:col-span-2 flex gap-3 pt-2">
        <button type="submit" class="px-5 py-2.5 rounded-xl bg-blue-600 text-white text-sm font-semibold hover:bg-blue-700 transition">
          ${formAction eq 'create' ? 'Tạo mới' : 'Lưu thay đổi'}
        </button>
        <a href="<%= ctx %>/manager/khuyen-mai" class="px-5 py-2.5 rounded-xl border border-zinc-200 text-sm font-medium text-zinc-600 hover:bg-zinc-50 transition">Hủy</a>
      </div>
    </form>
  </div>
  <% } else { %>

  <%-- ===== LIST ===== --%>
  <div class="flex items-center justify-between">
    <div>
      <h1 class="text-xl font-bold">Khuyến mãi</h1>
      <p class="text-sm text-zinc-500 mt-0.5">Tổng ${totalCount} mã</p>
    </div>
    <a href="<%= ctx %>/manager/khuyen-mai?action=form"
       class="px-4 py-2 rounded-xl bg-blue-600 text-white text-sm font-semibold hover:bg-blue-700 transition">
      + Tạo mã mới
    </a>
  </div>

  <div class="bg-white border border-zinc-200 rounded-2xl overflow-hidden">
    <c:choose>
      <c:when test="${empty khuyenMaiList}">
        <div class="text-center py-16 text-zinc-400">
          <span class="material-symbols-outlined text-4xl">local_offer</span>
          <p class="mt-2 text-sm">Chưa có mã khuyến mãi nào.</p>
        </div>
      </c:when>
      <c:otherwise>
        <div class="overflow-x-auto">
          <table class="w-full text-sm">
            <thead class="bg-zinc-50 border-b border-zinc-100 text-xs font-semibold text-zinc-500 uppercase tracking-wide">
              <tr>
                <th class="px-5 py-3 text-left">Mã code</th>
                <th class="px-5 py-3 text-left">Mô tả</th>
                <th class="px-5 py-3 text-left">Loại giảm</th>
                <th class="px-5 py-3 text-right">Giá trị</th>
                <th class="px-5 py-3 text-left">Hiệu lực</th>
                <th class="px-5 py-3 text-right">Đã dùng</th>
                <th class="px-5 py-3 text-left">Trạng thái</th>
                <th class="px-5 py-3 text-center">Thao tác</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-zinc-100">
              <c:forEach var="km" items="${khuyenMaiList}">
                <tr class="tbl-row">
                  <td class="px-5 py-3 font-mono font-semibold text-blue-700"><c:out value="${km.maCode}"/></td>
                  <td class="px-5 py-3 text-zinc-600 max-w-[180px] truncate"><c:out value="${km.moTa != null ? km.moTa : '—'}"/></td>
                  <td class="px-5 py-3">
                    <c:choose>
                      <c:when test="${km.loaiGiam eq 'PhanTram'}">
                        <span class="badge badge-blue">%</span>
                      </c:when>
                      <c:otherwise>
                        <span class="badge badge-amber">VND</span>
                      </c:otherwise>
                    </c:choose>
                  </td>
                  <td class="px-5 py-3 text-right font-medium">
                    <c:choose>
                      <c:when test="${km.loaiGiam eq 'PhanTram'}"><fmt:formatNumber value="${km.giaTriGiam}" maxFractionDigits="1"/>%</c:when>
                      <c:otherwise><fmt:formatNumber value="${km.giaTriGiam}" type="number" maxFractionDigits="0"/> đ</c:otherwise>
                    </c:choose>
                  </td>
                  <td class="px-5 py-3 text-zinc-500 whitespace-nowrap">${km.ngayBatDau} → ${km.ngayKetThuc}</td>
                  <td class="px-5 py-3 text-right">
                    ${km.soLanDaDung}<c:if test="${km.soLanToiDa != null}">/${km.soLanToiDa}</c:if>
                  </td>
                  <td class="px-5 py-3">
                    <c:choose>
                      <c:when test="${km.trangThai eq 'Hoạt động'}"><span class="badge badge-green">Hoạt động</span></c:when>
                      <c:otherwise><span class="badge badge-gray"><c:out value="${km.trangThai}"/></span></c:otherwise>
                    </c:choose>
                  </td>
                  <td class="px-5 py-3 text-center">
                    <div class="flex items-center justify-center gap-2">
                      <a href="<%= ctx %>/manager/khuyen-mai?action=form&id=${km.khuyenMaiID}"
                         class="text-xs text-blue-600 font-medium hover:underline">Sửa</a>
                      <c:if test="${km.soLanDaDung == 0}">
                        <form method="post" action="<%= ctx %>/manager/khuyen-mai?action=delete"
                              onsubmit="return confirm('Xóa mã ${km.maCode}?')" style="display:inline">
                          <input type="hidden" name="khuyenMaiId" value="${km.khuyenMaiID}">
                          <button type="submit" class="text-xs text-red-500 font-medium hover:underline">Xóa</button>
                        </form>
                      </c:if>
                    </div>
                  </td>
                </tr>
              </c:forEach>
            </tbody>
          </table>
        </div>

        <%-- Pagination --%>
        <c:if test="${currentPage > 1 or hasMore}">
          <div class="flex gap-2 p-4 justify-end border-t border-zinc-100">
            <c:if test="${currentPage > 1}">
              <a href="<%= ctx %>/manager/khuyen-mai?page=${currentPage - 1}"
                 class="px-3 py-1.5 text-xs rounded-lg border border-zinc-200 hover:bg-zinc-50">← Trước</a>
            </c:if>
            <span class="px-3 py-1.5 text-xs text-zinc-500">Trang ${currentPage}</span>
            <c:if test="${hasMore}">
              <a href="<%= ctx %>/manager/khuyen-mai?page=${currentPage + 1}"
                 class="px-3 py-1.5 text-xs rounded-lg border border-zinc-200 hover:bg-zinc-50">Tiếp →</a>
            </c:if>
          </div>
        </c:if>
      </c:otherwise>
    </c:choose>
  </div>
  <% } %>

</main>
</body>
</html>
