<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <title>Thùng rác Admin - V-SPORT</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <script src="https://cdn.tailwindcss.com"></script>
  <link rel="stylesheet" href="https://fonts.googleapis.com/icon?family=Material+Symbols+Outlined"/>
</head>
<body class="bg-slate-50">
<jsp:include page="/admin/common/sidebar.jsp"/>

<div class="lg:ml-[260px]">
  <jsp:include page="/admin/common/header.jsp">
    <jsp:param name="pageTitle" value="Thùng rác Admin"/>
  </jsp:include>

  <main class="pt-[84px] px-4 lg:px-6 pb-10 max-w-6xl mx-auto">

    <c:if test="${not empty message}">
      <div class="mb-4 px-4 py-3 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-700 text-sm font-medium">
        <c:out value="${message}"/>
      </div>
    </c:if>
    <c:if test="${not empty error}">
      <div class="mb-4 px-4 py-3 rounded-xl bg-red-50 border border-red-200 text-red-700 text-sm font-medium">
        <c:out value="${error}"/>
      </div>
    </c:if>

    <div class="mb-5">
      <h1 class="text-lg font-bold text-slate-900">Thùng rác Admin</h1>
      <p class="text-sm text-slate-500 mt-1">Các dữ liệu đã xóa được lưu tại đây để có thể thu hồi.</p>
    </div>

    <!-- Bộ lọc: dùng link (không phải nhiều submit-button chung 1 form) để mỗi lần
         đổi 1 filter vẫn giữ nguyên 2 filter còn lại trên URL. -->
    <c:set var="curLoai" value="${empty loai ? 'all' : loai}"/>
    <c:set var="curThuHoi" value="${thuhoi}"/>
    <c:set var="curScope" value="${empty scope ? 'tatca' : scope}"/>
    <c:url var="urlLoaiAll" value="/admin/thung-rac"><c:param name="loai" value="all"/><c:param name="thuhoi" value="${curThuHoi}"/><c:param name="scope" value="${curScope}"/></c:url>
    <c:url var="urlLoaiCoSo" value="/admin/thung-rac"><c:param name="loai" value="CoSo"/><c:param name="thuhoi" value="${curThuHoi}"/><c:param name="scope" value="${curScope}"/></c:url>
    <c:url var="urlLoaiOwner" value="/admin/thung-rac"><c:param name="loai" value="OwnerRequest"/><c:param name="thuhoi" value="${curThuHoi}"/><c:param name="scope" value="${curScope}"/></c:url>
    <c:url var="urlLoaiAccount" value="/admin/thung-rac"><c:param name="loai" value="Account"/><c:param name="thuhoi" value="${curThuHoi}"/><c:param name="scope" value="${curScope}"/></c:url>
    <c:url var="urlThuHoiChua" value="/admin/thung-rac"><c:param name="loai" value="${curLoai}"/><c:param name="thuhoi" value="not_restored"/><c:param name="scope" value="${curScope}"/></c:url>
    <c:url var="urlThuHoiDa" value="/admin/thung-rac"><c:param name="loai" value="${curLoai}"/><c:param name="thuhoi" value="restored"/><c:param name="scope" value="${curScope}"/></c:url>
    <c:url var="urlScopeCuaToi" value="/admin/thung-rac"><c:param name="loai" value="${curLoai}"/><c:param name="thuhoi" value="${curThuHoi}"/><c:param name="scope" value="cuatoi"/></c:url>
    <c:url var="urlScopeTatCa" value="/admin/thung-rac"><c:param name="loai" value="${curLoai}"/><c:param name="thuhoi" value="${curThuHoi}"/><c:param name="scope" value="tatca"/></c:url>

    <div class="flex flex-wrap items-center gap-2 mb-5">
      <a href="${urlLoaiAll}" class="tab-pill ${curLoai == 'all' ? 'active' : ''}">Tất cả</a>
      <a href="${urlLoaiCoSo}" class="tab-pill ${curLoai == 'CoSo' ? 'active' : ''}">Cơ sở</a>
      <a href="${urlLoaiOwner}" class="tab-pill ${curLoai == 'OwnerRequest' ? 'active' : ''}">Owner</a>
      <a href="${urlLoaiAccount}" class="tab-pill ${curLoai == 'Account' ? 'active' : ''}">Người dùng</a>
      <span class="w-px h-5 bg-slate-200 mx-1"></span>
      <a href="${urlThuHoiChua}" class="tab-pill ${curThuHoi == 'not_restored' ? 'active' : ''}">Chưa thu hồi</a>
      <a href="${urlThuHoiDa}" class="tab-pill ${curThuHoi == 'restored' ? 'active' : ''}">Đã thu hồi</a>
      <span class="w-px h-5 bg-slate-200 mx-1"></span>
      <a href="${urlScopeCuaToi}" class="tab-pill ${curScope == 'cuatoi' ? 'active' : ''}">Của tôi</a>
      <a href="${urlScopeTatCa}" class="tab-pill ${curScope == 'tatca' ? 'active' : ''}">Tất cả</a>
    </div>

    <div class="bg-white border border-slate-200/80 rounded-2xl overflow-x-auto shadow-xs">
      <table class="w-full text-sm">
        <thead>
          <tr class="text-left text-[11px] uppercase tracking-wide text-slate-400 border-b border-slate-100">
            <th class="px-4 py-3">Loại dữ liệu</th>
            <th class="px-4 py-3">Tên dữ liệu</th>
            <th class="px-4 py-3">Nguồn</th>
            <th class="px-4 py-3">Trạng thái trước khi xóa</th>
            <th class="px-4 py-3">Người thao tác</th>
            <th class="px-4 py-3">Ngày xóa</th>
            <th class="px-4 py-3">Trạng thái thu hồi</th>
            <th class="px-4 py-3 text-right">Hành động</th>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="it" items="${items}">
            <tr class="border-b border-slate-50 hover:bg-slate-50/60">
              <td class="px-4 py-3 font-medium text-slate-700"><c:out value="${it.entityType}"/></td>
              <td class="px-4 py-3"><c:out value="${it.displayName}"/></td>
              <td class="px-4 py-3 text-slate-500"><c:out value="${it.sourceTable}"/></td>
              <td class="px-4 py-3 text-slate-500"><c:out value="${it.oldStatus}"/></td>
              <td class="px-4 py-3 text-slate-500"><c:out value="${it.deletedByName}"/></td>
              <td class="px-4 py-3 text-slate-500">
                <c:out value="${it.deletedAt}"/>
              </td>
              <td class="px-4 py-3">
                <c:choose>
                  <c:when test="${it.restored}">
                    <span class="badge badge-green">Đã thu hồi</span>
                  </c:when>
                  <c:otherwise>
                    <span class="badge badge-amber">Chưa thu hồi</span>
                  </c:otherwise>
                </c:choose>
              </td>
              <td class="px-4 py-3 text-right">
                <c:if test="${!it.restored}">
                  <button type="button"
                          onclick="openRestoreModal(${it.trashId}, '${fn:escapeXml(it.displayName)}')"
                          class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-blue-600 text-white text-xs font-semibold hover:bg-blue-700">
                    <i class="ti ti-arrow-back-up"></i> Thu hồi
                  </button>
                </c:if>
              </td>
            </tr>
          </c:forEach>
          <c:if test="${empty items}">
            <tr>
              <td colspan="8" class="py-16 text-center text-slate-400">
                <i class="ti ti-trash-off text-4xl block mb-2 opacity-40"></i>
                <span class="text-sm font-medium">Thùng rác trống.</span>
              </td>
            </tr>
          </c:if>
        </tbody>
      </table>
    </div>
  </main>
</div>

<!-- Modal xác nhận Thu hồi -->
<div id="restoreModal" class="hidden fixed inset-0 z-[90] flex items-center justify-center p-4">
  <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" onclick="closeRestoreModal()"></div>
  <div class="relative bg-white rounded-2xl shadow-xl w-full max-w-sm p-6">
    <h3 class="text-base font-bold text-slate-900 mb-1">Thu hồi mục này?</h3>
    <p class="text-sm text-slate-500 mb-5" id="restoreModalText"></p>
    <div class="flex justify-end gap-2">
      <button type="button" onclick="closeRestoreModal()"
              class="h-10 px-4 rounded-xl border border-slate-200 text-sm font-bold text-slate-600 hover:bg-slate-50">Hủy</button>
      <button type="button" onclick="submitRestore()"
              class="h-10 px-4 rounded-xl bg-blue-600 text-white text-sm font-bold hover:bg-blue-700">Thu hồi</button>
    </div>
  </div>
</div>

<form id="restoreForm" method="post" action="${pageContext.request.contextPath}/admin/thung-rac" class="hidden">
  <input type="hidden" name="action" value="restore"/>
  <input type="hidden" name="id" id="restoreTrashId"/>
</form>

<script>
  function openRestoreModal(trashId, displayName) {
    document.getElementById('restoreTrashId').value = trashId;
    document.getElementById('restoreModalText').textContent = 'Đưa "' + displayName + '" trở lại trạng thái trước khi xóa.';
    document.getElementById('restoreModal').classList.remove('hidden');
  }
  function closeRestoreModal() {
    document.getElementById('restoreModal').classList.add('hidden');
  }
  function submitRestore() {
    document.getElementById('restoreForm').submit();
  }
</script>
</body>
</html>
