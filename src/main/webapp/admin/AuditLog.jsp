<%-- src/main/webapp/admin/AuditLog.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Nhật Ký Thao Tác - Admin</title>
<script src="https://cdn.tailwindcss.com"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200">
<style>
body { font-family: 'Inter', sans-serif; }
.material-symbols-outlined { font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24; }
</style>
</head>
<body class="bg-gray-50">
<jsp:include page="/admin/common/sidebar.jsp"/>
<div class="ml-64 p-8">
    <div class="mb-6">
        <h1 class="text-2xl font-bold text-gray-800">Nhật Ký Thao Tác</h1>
        <p class="text-gray-500 mt-1">Toàn bộ hoạt động của Admin và Manager — <c:out value="${total}"/> bản ghi</p>
    </div>

    <%-- Flash messages --%>
    <c:if test="${not empty sessionScope.message}">
        <div class="mb-4 p-3 bg-green-100 text-green-800 rounded-lg"><c:out value="${sessionScope.message}"/></div>
        <c:remove var="message" scope="session"/>
    </c:if>
    <c:if test="${not empty sessionScope.error}">
        <div class="mb-4 p-3 bg-red-100 text-red-800 rounded-lg"><c:out value="${sessionScope.error}"/></div>
        <c:remove var="error" scope="session"/>
    </c:if>

    <%-- Filter form --%>
    <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-5 mb-6">
        <form method="get" action="${pageContext.request.contextPath}/admin/audit-log"
              class="grid grid-cols-1 md:grid-cols-5 gap-4 items-end">
            <div>
                <label class="block text-xs text-gray-500 mb-1">Loại đối tượng</label>
                <select name="entityType" class="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm">
                    <option value="">-- Tất cả --</option>
                    <option value="TaiKhoan"  <c:if test="${entityType == 'TaiKhoan'}">selected</c:if>>Tài khoản</option>
                    <option value="San"       <c:if test="${entityType == 'San'}">selected</c:if>>Sân</option>
                    <option value="LoaiSan"   <c:if test="${entityType == 'LoaiSan'}">selected</c:if>>Loại sân</option>
                    <option value="SanPham"   <c:if test="${entityType == 'SanPham'}">selected</c:if>>Sản phẩm</option>
                    <option value="CoSo"      <c:if test="${entityType == 'CoSo'}">selected</c:if>>Chi nhánh</option>
                    <option value="CaLamViec" <c:if test="${entityType == 'CaLamViec'}">selected</c:if>>Ca làm việc</option>
                    <option value="YeuCauNghi"<c:if test="${entityType == 'YeuCauNghi'}">selected</c:if>>Yêu cầu nghỉ</option>
                </select>
            </div>
            <div>
                <label class="block text-xs text-gray-500 mb-1">Hành động</label>
                <select name="action" class="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm">
                    <option value="">-- Tất cả --</option>
                    <option value="CREATE"           <c:if test="${action == 'CREATE'}">selected</c:if>>Tạo mới</option>
                    <option value="UPDATE"           <c:if test="${action == 'UPDATE'}">selected</c:if>>Cập nhật</option>
                    <option value="SOFT_DELETE"      <c:if test="${action == 'SOFT_DELETE'}">selected</c:if>>Xóa mềm</option>
                    <option value="RESTORE"          <c:if test="${action == 'RESTORE'}">selected</c:if>>Khôi phục</option>
                    <option value="PERMANENT_DELETE" <c:if test="${action == 'PERMANENT_DELETE'}">selected</c:if>>Xóa vĩnh viễn</option>
                    <option value="ADD_STAFF"        <c:if test="${action == 'ADD_STAFF'}">selected</c:if>>Thêm nhân viên</option>
                    <option value="APPROVE"          <c:if test="${action == 'APPROVE'}">selected</c:if>>Duyệt</option>
                    <option value="REJECT"           <c:if test="${action == 'REJECT'}">selected</c:if>>Từ chối</option>
                </select>
            </div>
            <div>
                <label class="block text-xs text-gray-500 mb-1">Từ ngày</label>
                <input type="date" name="dateFrom" value="<c:out value='${dateFrom}'/>"
                       class="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm">
            </div>
            <div>
                <label class="block text-xs text-gray-500 mb-1">Đến ngày</label>
                <input type="date" name="dateTo" value="<c:out value='${dateTo}'/>"
                       class="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm">
            </div>
            <div class="flex gap-2">
                <button type="submit"
                        class="flex-1 bg-purple-600 text-white rounded-lg px-4 py-2 text-sm font-medium hover:bg-purple-700">
                    Lọc
                </button>
                <a href="${pageContext.request.contextPath}/admin/audit-log"
                   class="flex-1 text-center bg-gray-100 text-gray-700 rounded-lg px-4 py-2 text-sm font-medium hover:bg-gray-200">
                    Xóa lọc
                </a>
            </div>
        </form>
    </div>

    <%-- Table --%>
    <div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full text-sm">
                <thead class="bg-gray-50 border-b border-gray-200">
                    <tr>
                        <th class="text-left px-4 py-3 font-medium text-gray-600">Thời gian</th>
                        <th class="text-left px-4 py-3 font-medium text-gray-600">Người thực hiện</th>
                        <th class="text-left px-4 py-3 font-medium text-gray-600">Hành động</th>
                        <th class="text-left px-4 py-3 font-medium text-gray-600">Đối tượng</th>
                        <th class="text-left px-4 py-3 font-medium text-gray-600">Chi tiết</th>
                        <th class="text-left px-4 py-3 font-medium text-gray-600">IP</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-100">
                    <c:choose>
                        <c:when test="${empty logs}">
                            <tr>
                                <td colspan="6" class="text-center py-12 text-gray-400">
                                    Không có bản ghi nào.
                                </td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="log" items="${logs}">
                                <tr class="hover:bg-gray-50 transition-colors">
                                    <td class="px-4 py-3 text-gray-500 whitespace-nowrap">
                                        ${log.createdAt}
                                    </td>
                                    <td class="px-4 py-3">
                                        <div class="font-medium text-gray-800"><c:out value="${log.actorName}"/></div>
                                        <div class="text-xs text-gray-400">
                                            <c:choose>
                                                <c:when test="${log.actorRole == 1}">Admin</c:when>
                                                <c:when test="${log.actorRole == 2}">Manager</c:when>
                                                <c:otherwise>Role ${log.actorRole}</c:otherwise>
                                            </c:choose>
                                        </div>
                                    </td>
                                    <td class="px-4 py-3">
                                        <span class="inline-block px-2 py-1 rounded-full text-xs font-medium
                                            <c:choose>
                                                <c:when test="${log.action == 'CREATE' || log.action == 'ADD_STAFF'}">bg-green-100 text-green-700</c:when>
                                                <c:when test="${log.action == 'UPDATE' || log.action == 'APPROVE'}">bg-blue-100 text-blue-700</c:when>
                                                <c:when test="${log.action == 'SOFT_DELETE' || log.action == 'REJECT'}">bg-yellow-100 text-yellow-700</c:when>
                                                <c:when test="${log.action == 'PERMANENT_DELETE'}">bg-red-100 text-red-700</c:when>
                                                <c:when test="${log.action == 'RESTORE'}">bg-purple-100 text-purple-700</c:when>
                                                <c:otherwise>bg-gray-100 text-gray-600</c:otherwise>
                                            </c:choose>">
                                            <c:out value="${log.action}"/>
                                        </span>
                                    </td>
                                    <td class="px-4 py-3">
                                        <div class="text-gray-700"><c:out value="${log.entityName}"/></div>
                                        <div class="text-xs text-gray-400"><c:out value="${log.entityType}"/> #${log.entityId}</div>
                                    </td>
                                    <td class="px-4 py-3 text-gray-600 max-w-xs truncate"><c:out value="${log.details}"/></td>
                                    <td class="px-4 py-3 text-gray-400 text-xs"><c:out value="${log.ipAddress}"/></td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>

        <%-- Phân trang --%>
        <c:if test="${totalPages > 1}">
            <div class="px-4 py-3 border-t border-gray-200 flex items-center justify-between">
                <span class="text-sm text-gray-500">Trang ${currentPage} / ${totalPages}</span>
                <div class="flex gap-1">
                    <c:if test="${currentPage > 1}">
                        <c:url var="prevPageUrl" value="">
                            <c:param name="page" value="${currentPage - 1}"/>
                            <c:param name="entityType" value="${entityType}"/>
                            <c:param name="action" value="${action}"/>
                            <c:param name="dateFrom" value="${dateFrom}"/>
                            <c:param name="dateTo" value="${dateTo}"/>
                        </c:url>
                        <a href="${prevPageUrl}"
                           class="px-3 py-1 text-sm border border-gray-300 rounded-lg hover:bg-gray-50">Trước</a>
                    </c:if>
                    <c:forEach begin="1" end="${totalPages}" var="p">
                        <c:if test="${p >= currentPage - 2 && p <= currentPage + 2}">
                            <c:url var="pageUrl" value="">
                                <c:param name="page" value="${p}"/>
                                <c:param name="entityType" value="${entityType}"/>
                                <c:param name="action" value="${action}"/>
                                <c:param name="dateFrom" value="${dateFrom}"/>
                                <c:param name="dateTo" value="${dateTo}"/>
                            </c:url>
                            <a href="${pageUrl}"
                               class="px-3 py-1 text-sm border rounded-lg
                               <c:choose><c:when test="${p == currentPage}">bg-purple-600 text-white border-purple-600</c:when>
                               <c:otherwise>border-gray-300 hover:bg-gray-50</c:otherwise></c:choose>">${p}</a>
                        </c:if>
                    </c:forEach>
                    <c:if test="${currentPage < totalPages}">
                        <c:url var="nextPageUrl" value="">
                            <c:param name="page" value="${currentPage + 1}"/>
                            <c:param name="entityType" value="${entityType}"/>
                            <c:param name="action" value="${action}"/>
                            <c:param name="dateFrom" value="${dateFrom}"/>
                            <c:param name="dateTo" value="${dateTo}"/>
                        </c:url>
                        <a href="${nextPageUrl}"
                           class="px-3 py-1 text-sm border border-gray-300 rounded-lg hover:bg-gray-50">Sau</a>
                    </c:if>
                </div>
            </div>
        </c:if>
    </div>
</div>
</body>
</html>
