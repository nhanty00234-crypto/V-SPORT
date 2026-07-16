<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <title>Thùng rác Admin — V-SPORT</title>
  <jsp:include page="/admin/common/admin_head.jsp" />
  <style>
    .card {
      background: #fff;
      border: 1px solid #ede9fe;
      border-radius: 1rem;
      box-shadow: 0 1px 4px 0 rgba(88,28,235,.04);
    }
    .tab-btn {
      cursor: pointer;
      background: none;
      border: none;
      padding: 0;
    }
    .badge {
      display: inline-flex;
      align-items: center;
      font-size: 0.72rem;
      font-weight: 700;
      border-radius: 9999px;
      padding: 2px 10px;
    }
    .badge-green  { background:#f0fdf4; color:#15803d; border:1px solid #bbf7d0; }
    .badge-amber  { background:#fffbeb; color:#b45309; border:1px solid #fde68a; }
    .badge-gray   { background:#f4f4f5; color:#52525b; border:1px solid #e4e4e7; }

    /* filter pills */
    .tab-pill {
      display: inline-flex;
      align-items: center;
      gap: 4px;
      padding: 5px 16px;
      border-radius: 9999px;
      font-size: .8rem;
      font-weight: 600;
      border: 1.5px solid #e0d9fb;
      color: #7c3aed;
      background: #f5f3ff;
      text-decoration: none;
      transition: all .15s;
    }
    .tab-pill:hover { background:#ede9fe; }
    .tab-pill.active { background:#7c3aed; color:#fff; border-color:#7c3aed; }
  </style>
</head>
<body class="text-zinc-900 min-h-screen">

<!-- Sidebar -->
<jsp:include page="/admin/common/sidebar.jsp"/>

<!-- Header -->
<jsp:include page="/admin/common/header.jsp">
  <jsp:param name="pageTitle" value="Thùng rác Admin"/>
</jsp:include>

<main class="lg:ml-[260px] pt-[84px] px-4 lg:px-6 pb-10 flex flex-col gap-5 max-w-7xl">

  <!-- Page heading -->
  <section class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
    <div>
      <h2 class="text-2xl font-black tracking-tight text-purple-950">Thùng rác Admin</h2>
      <p class="text-xs text-purple-500 mt-1">Các dữ liệu đã xóa được lưu tại đây để có thể thu hồi.</p>
    </div>
  </section>

  <!-- Alert Messages -->
  <c:if test="${not empty message}">
    <div class="p-4 bg-green-50 border border-green-100 rounded-xl text-green-650 text-sm flex items-start gap-3 shadow-sm">
      <span class="material-symbols-outlined text-[20px] text-green-600 shrink-0">check_circle</span>
      <div>
        <span class="font-bold block text-green-700">Thành công</span>
        <span class="text-green-700/90 leading-normal block mt-0.5"><c:out value="${message}"/></span>
      </div>
    </div>
  </c:if>
  <c:if test="${not empty error}">
    <div class="p-4 bg-red-50 border border-red-100 rounded-xl text-red-650 text-sm flex items-start gap-3 shadow-sm">
      <span class="material-symbols-outlined text-[20px] text-red-600 shrink-0">error</span>
      <div>
        <span class="font-bold block text-red-700">Lỗi</span>
        <span class="text-red-700/90 leading-normal block mt-0.5"><c:out value="${error}"/></span>
      </div>
    </div>
  </c:if>

  <!-- Filter Pills (URL-based, same logic as before) -->
  <c:set var="curLoai"   value="${empty loai   ? 'all'    : loai}"/>
  <c:set var="curThuHoi" value="${thuhoi}"/>
  <c:set var="curScope"  value="${empty scope  ? 'tatca'  : scope}"/>

  <c:url var="urlLoaiAll"     value="/admin/thung-rac"><c:param name="loai" value="all"/><c:param name="thuhoi" value="${curThuHoi}"/><c:param name="scope" value="${curScope}"/></c:url>
  <c:url var="urlLoaiCoSo"    value="/admin/thung-rac"><c:param name="loai" value="CoSo"/><c:param name="thuhoi" value="${curThuHoi}"/><c:param name="scope" value="${curScope}"/></c:url>
  <c:url var="urlLoaiOwner"   value="/admin/thung-rac"><c:param name="loai" value="OwnerRequest"/><c:param name="thuhoi" value="${curThuHoi}"/><c:param name="scope" value="${curScope}"/></c:url>
  <c:url var="urlLoaiAccount" value="/admin/thung-rac"><c:param name="loai" value="Account"/><c:param name="thuhoi" value="${curThuHoi}"/><c:param name="scope" value="${curScope}"/></c:url>
  <c:url var="urlThuHoiChua"  value="/admin/thung-rac"><c:param name="loai" value="${curLoai}"/><c:param name="thuhoi" value="not_restored"/><c:param name="scope" value="${curScope}"/></c:url>
  <c:url var="urlThuHoiDa"    value="/admin/thung-rac"><c:param name="loai" value="${curLoai}"/><c:param name="thuhoi" value="restored"/><c:param name="scope" value="${curScope}"/></c:url>
  <c:url var="urlScopeCuaToi" value="/admin/thung-rac"><c:param name="loai" value="${curLoai}"/><c:param name="thuhoi" value="${curThuHoi}"/><c:param name="scope" value="cuatoi"/></c:url>
  <c:url var="urlScopeTatCa"  value="/admin/thung-rac"><c:param name="loai" value="${curLoai}"/><c:param name="thuhoi" value="${curThuHoi}"/><c:param name="scope" value="tatca"/></c:url>

  <!-- Filter bar -->
  <section class="flex flex-wrap items-center gap-2">
    <!-- Loại dữ liệu -->
    <a href="${urlLoaiAll}"     class="tab-pill ${curLoai == 'all'          ? 'active' : ''}">
      <span class="material-symbols-outlined text-[15px]">filter_list</span>Tất cả
    </a>
    <a href="${urlLoaiCoSo}"    class="tab-pill ${curLoai == 'CoSo'         ? 'active' : ''}">
      <span class="material-symbols-outlined text-[15px]">store</span>Cơ Sở
    </a>
    <a href="${urlLoaiOwner}"   class="tab-pill ${curLoai == 'OwnerRequest' ? 'active' : ''}">
      <span class="material-symbols-outlined text-[15px]">manage_accounts</span>Owner
    </a>
    <a href="${urlLoaiAccount}" class="tab-pill ${curLoai == 'Account'      ? 'active' : ''}">
      <span class="material-symbols-outlined text-[15px]">person</span>Người dùng
    </a>

    <span class="w-px h-5 bg-purple-200 mx-1"></span>

    <!-- Trạng thái thu hồi -->
    <a href="${urlThuHoiChua}"  class="tab-pill ${curThuHoi == 'not_restored' ? 'active' : ''}">
      <span class="material-symbols-outlined text-[15px]">hourglass_empty</span>Chưa thu hồi
    </a>
    <a href="${urlThuHoiDa}"    class="tab-pill ${curThuHoi == 'restored'     ? 'active' : ''}">
      <span class="material-symbols-outlined text-[15px]">check_circle</span>Đã thu hồi
    </a>

    <span class="w-px h-5 bg-purple-200 mx-1"></span>

    <!-- Phạm vi -->
    <a href="${urlScopeCuaToi}" class="tab-pill ${curScope == 'cuatoi' ? 'active' : ''}">
      <span class="material-symbols-outlined text-[15px]">person_pin</span>Của tôi
    </a>
    <a href="${urlScopeTatCa}"  class="tab-pill ${curScope == 'tatca'  ? 'active' : ''}">
      <span class="material-symbols-outlined text-[15px]">group</span>Tất cả
    </a>
  </section>

  <!-- Data Table -->
  <div class="card overflow-x-auto">
    <table class="w-full text-left text-sm border-collapse">
      <thead>
        <tr class="border-b border-purple-50 text-purple-900 font-bold text-xs uppercase tracking-wider">
          <th class="pb-3 pt-4 pl-5">Loại dữ liệu</th>
          <th class="pb-3 pt-4">Tên dữ liệu</th>
          <th class="pb-3 pt-4">Nguồn</th>
          <th class="pb-3 pt-4">Trạng thái trước khi xóa</th>
          <th class="pb-3 pt-4">Người thao tác</th>
          <th class="pb-3 pt-4">Ngày xóa</th>
          <th class="pb-3 pt-4">Trạng thái thu hồi</th>
          <th class="pb-3 pt-4 pr-5 text-right">Hành động</th>
        </tr>
      </thead>
      <tbody>
        <c:choose>
          <c:when test="${empty items}">
            <tr>
              <td colspan="8" class="py-16 text-center text-zinc-400">
                <span class="material-symbols-outlined text-4xl block mb-2 opacity-30">delete_sweep</span>
                <span class="text-sm font-medium">Thùng rác trống.</span>
              </td>
            </tr>
          </c:when>
          <c:otherwise>
            <c:forEach var="it" items="${items}">
              <tr class="border-b border-purple-50 hover:bg-purple-50/30 transition-colors">
                <td class="py-4 pl-5 font-semibold text-purple-950"><c:out value="${it.entityType}"/></td>
                <td class="py-4 text-zinc-700"><c:out value="${it.displayName}"/></td>
                <td class="py-4 text-zinc-500"><c:out value="${it.sourceTable}"/></td>
                <td class="py-4 text-zinc-500"><c:out value="${it.oldStatus}"/></td>
                <td class="py-4 text-zinc-500"><c:out value="${it.deletedByName}"/></td>
                <td class="py-4 text-zinc-500"><c:out value="${it.deletedAt}"/></td>
                <td class="py-4">
                  <c:choose>
                    <c:when test="${it.restored}">
                      <span class="badge badge-green">Đã thu hồi</span>
                    </c:when>
                    <c:otherwise>
                      <span class="badge badge-amber">Chưa thu hồi</span>
                    </c:otherwise>
                  </c:choose>
                </td>
                <td class="py-4 pr-5 text-right">
                  <c:if test="${!it.restored}">
                    <button type="button"
                            onclick="openRestoreModal(${it.trashId}, '${fn:escapeXml(it.displayName)}', '${it.entityType}')"
                            class="flex items-center gap-1 px-3 py-1.5 bg-green-50 text-green-700 rounded-lg text-xs font-semibold hover:bg-green-100 transition-colors ml-auto">
                      <span class="material-symbols-outlined text-[14px]">settings_backup_restore</span>Thu hồi
                    </button>
                  </c:if>
                </td>
              </tr>
            </c:forEach>
          </c:otherwise>
        </c:choose>
      </tbody>
    </table>
  </div>

</main>

<!-- Modal xác nhận Thu hồi -->
<div id="restoreModal" class="hidden fixed inset-0 z-[90] flex items-center justify-center p-4">
  <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" onclick="closeRestoreModal()"></div>
  <div class="relative bg-white rounded-2xl shadow-xl w-full max-w-sm p-6">
    <span class="material-symbols-outlined text-3xl text-green-600 mb-3 block">settings_backup_restore</span>
    <h3 class="text-base font-bold text-slate-900 mb-1" id="restoreModalTitle">Thu hồi mục này?</h3>
    <p class="text-sm text-slate-500 mb-5" id="restoreModalText"></p>
    <div class="flex justify-end gap-2">
      <button type="button" onclick="closeRestoreModal()"
              class="h-10 px-4 rounded-xl border border-slate-200 text-sm font-bold text-slate-600 hover:bg-slate-50">Hủy</button>
      <button type="button" onclick="submitRestore()"
              class="h-10 px-4 rounded-xl bg-green-600 text-white text-sm font-bold hover:bg-green-700 flex items-center gap-1.5">
        <span class="material-symbols-outlined text-[16px]">settings_backup_restore</span>Thu hồi
      </button>
    </div>
  </div>
</div>

<form id="restoreForm" method="post" action="${pageContext.request.contextPath}/admin/thung-rac" class="hidden">
  <input type="hidden" name="action" value="restore"/>
  <input type="hidden" name="id" id="restoreTrashId"/>
</form>

<script>
  function openRestoreModal(trashId, displayName, entityType) {
    document.getElementById('restoreTrashId').value = trashId;
    var title = document.getElementById('restoreModalTitle');
    var text = document.getElementById('restoreModalText');
    if (entityType === 'CoSo') {
      title.textContent = 'Khôi phục cơ sở?';
      text.textContent = 'Khôi phục "' + displayName + '". Các tài khoản hợp lệ (chưa bị khóa riêng) và dữ liệu vận hành của cơ sở này sẽ có thể truy cập trở lại.';
    } else {
      title.textContent = 'Thu hồi mục này?';
      text.textContent = 'Đưa "' + displayName + '" trở lại trạng thái trước khi xóa.';
    }
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
