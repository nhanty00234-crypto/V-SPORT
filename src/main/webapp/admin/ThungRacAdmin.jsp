<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
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
      <p class="text-sm text-slate-500 mt-1">Các dữ liệu bạn đã xóa sẽ được lưu tại đây để có thể thu hồi.</p>
    </div>

    <!-- Bộ lọc -->
    <form method="get" action="${pageContext.request.contextPath}/admin/thung-rac"
          class="flex flex-wrap items-center gap-2 mb-5">
      <button type="submit" name="loai" value="all" class="tab-pill ${empty loai || loai == 'all' ? 'active' : ''}">Tất cả</button>
      <button type="submit" name="loai" value="CoSo" class="tab-pill ${loai == 'CoSo' ? 'active' : ''}">Cơ sở</button>
      <button type="submit" name="loai" value="OwnerRequest" class="tab-pill ${loai == 'OwnerRequest' ? 'active' : ''}">Owner</button>
      <button type="submit" name="loai" value="Account" class="tab-pill ${loai == 'Account' ? 'active' : ''}">Người dùng</button>
      <span class="w-px h-5 bg-slate-200 mx-1"></span>
      <button type="submit" name="thuhoi" value="not_restored"
              class="tab-pill ${thuhoi == 'not_restored' ? 'active' : ''}">Chưa thu hồi</button>
      <button type="submit" name="thuhoi" value="restored"
              class="tab-pill ${thuhoi == 'restored' ? 'active' : ''}">Đã thu hồi</button>
      <span class="w-px h-5 bg-slate-200 mx-1"></span>
      <button type="submit" name="scope" value="cuatoi"
              class="tab-pill ${scope == 'cuatoi' ? 'active' : ''}">Của tôi</button>
      <button type="submit" name="scope" value="tatca"
              class="tab-pill ${scope == 'tatca' ? 'active' : ''}">Tất cả</button>
    </form>

    <div class="adm-card overflow-x-auto">
      <table class="w-full text-sm">
        <thead>
          <tr class="text-left text-[11px] uppercase tracking-wide text-slate-400 border-b border-slate-100">
            <th class="px-4 py-3">Loại dữ liệu</th>
            <th class="px-4 py-3">Tên dữ liệu</th>
            <th class="px-4 py-3">Bảng nguồn</th>
            <th class="px-4 py-3">Trạng thái cũ</th>
            <th class="px-4 py-3">Người xóa</th>
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
                  <form method="post" action="${pageContext.request.contextPath}/admin/thung-rac"
                        onsubmit="return confirm('Bạn có chắc muốn thu hồi mục này?');">
                    <input type="hidden" name="action" value="restore"/>
                    <input type="hidden" name="id" value="${it.trashId}"/>
                    <button type="submit"
                            class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-blue-600 text-white text-xs font-semibold hover:bg-blue-700">
                      <i class="ti ti-arrow-back-up"></i> Thu hồi
                    </button>
                  </form>
                </c:if>
              </td>
            </tr>
          </c:forEach>
          <c:if test="${empty items}">
            <tr><td colspan="8" class="px-4 py-10 text-center text-slate-400 text-sm">Thùng rác trống.</td></tr>
          </c:if>
        </tbody>
      </table>
    </div>
  </main>
</div>
</body>
</html>
