<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>Quản lý yêu cầu nghỉ - Quản lý cơ sở</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
</head>
<body class="bg-gray-100 min-h-screen">
<!-- Navigation bar sẽ được include từ common -->

<div class="container mx-auto px-4 py-6">
    <h1 class="text-2xl font-bold text-purple-700 mb-6">Quản lý yêu cầu nghỉ</h1>

    <!-- Hiển thị thông báo -->
    <c:if test="${not empty sessionScope.error}">
        <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
            ${sessionScope.error}
        </div>
        <c:remove var="error" scope="session"/>
    </c:if>
    <c:if test="${not empty sessionScope.success}">
        <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded mb-4">
            ${sessionScope.success}
        </div>
        <c:remove var="success" scope="session"/>
    </c:if>

    <!-- Stats -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
        <div class="card bg-white p-4 rounded-lg shadow">
            <h3 class="text-lg font-semibold text-gray-700">Tất cả yêu cầu</h3>
            <p class="text-3xl font-bold text-blue-600">${requests.size()}</p>
        </div>
        <div class="card bg-white p-4 rounded-lg shadow">
            <h3 class="text-lg font-semibold text-gray-700">Chờ duyệt</h3>
            <p class="text-3xl font-bold text-yellow-600">${pendingCount}</p>
        </div>
        <div class="card bg-white p-4 rounded-lg shadow">
            <h3 class="text-lg font-semibold text-gray-700">Đã duyệt</h3>
            <p class="text-3xl font-bold text-green-600">
                <c:forEach var="r" items="${requests}">
                    <c:if test="${r.trangThai == 'DaDuyet'}">+1</c:if>
                </c:forEach>
            </p>
        </div>
    </div>

    <!-- Filter -->
    <div class="bg-white p-4 rounded-lg shadow mb-6">
        <div class="flex flex-wrap items-center gap-4">
            <label class="font-semibold">Lọc theo trạng thái:</label>
            <a href="${pageContext.request.contextPath}/manager/yeu-cau-nghi" class="px-3 py-1 bg-blue-500 text-white rounded hover:bg-blue-600">Tất cả</a>
            <a href="${pageContext.request.contextPath}/manager/yeu-cau-nghi?status=ChoDuyet" class="px-3 py-1 bg-yellow-500 text-white rounded hover:bg-yellow-600">Chờ duyệt</a>
            <a href="${pageContext.request.contextPath}/manager/yeu-cau-nghi?status=DaDuyet" class="px-3 py-1 bg-green-500 text-white rounded hover:bg-green-600">Đã duyệt</a>
            <a href="${pageContext.request.contextPath}/manager/yeu-cau-nghi?status=TuChoi" class="px-3 py-1 bg-red-500 text-white rounded hover:bg-red-600">Từ chối</a>
        </div>
    </div>

    <!-- Table -->
    <div class="bg-white rounded-lg shadow overflow-hidden">
        <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-purple-600 text-white">
            <tr>
                <th class="px-6 py-3 text-left text-sm font-medium">#</th>
                <th class="px-6 py-3 text-left text-sm font-medium">Nhân viên</th>
                <th class="px-6 py-3 text-left text-sm font-medium">Vai trò</th>
                <th class="px-6 py-3 text-left text-sm font-medium">Ngày nghỉ</th>
                <th class="px-6 py-3 text-left text-sm font-medium">Loại</th>
                <th class="px-6 py-3 text-left text-sm font-medium">Lý do</th>
                <th class="px-6 py-3 text-left text-sm font-medium">Trạng thái</th>
                <th class="px-6 py-3 text-left text-sm font-medium">Ngày gửi</th>
                <th class="px-6 py-3 text-left text-sm font-medium">Thao tác</th>
            </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
            <c:forEach var="req" items="${requests}" varStatus="st">
                <tr class="hover:bg-gray-50">
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">${st.index + 1}</td>
                    <td class="px-6 py-4 whitespace-nowrap">
                        <div class="text-sm font-medium text-gray-900">${req.tenNhanVien}</div>
                        <div class="text-xs text-gray-500">${req.username}</div>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">${req.roleName}</td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                        <fmt:formatDate value="${req.ngayNghi}" pattern="dd/MM/yyyy"/>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        <c:choose>
                            <c:when test="${req.loaiNghi == 'FullDay'}">Cả ngày</c:when>
                            <c:when test="${req.loaiNghi == 'HalfDay_Morning'}">Buổi sáng</c:when>
                            <c:when test="${req.loaiNghi == 'HalfDay_Afternoon'}">Buổi chiều</c:when>
                            <c:otherwise>${req.loaiNghi}</c:otherwise>
                        </c:choose>
                    </td>
                    <td class="px-6 py-4 text-sm text-gray-500 max-w-xs truncate" title="${req.lyDo}">
                        ${req.lyDo}
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap">
                        <span class="px-2 py-0.5 inline-flex text-xs leading-5 font-semibold rounded-lg ${req.trangThaiCSS}">
                            <c:choose>
                                <c:when test="${req.trangThai == 'ChoDuyet'}">Chờ duyệt</c:when>
                                <c:when test="${req.trangThai == 'DaDuyet'}">Đã duyệt</c:when>
                                <c:when test="${req.trangThai == 'TuChoi'}">Từ chối</c:when>
                                <c:when test="${req.trangThai == 'DaHuy'}">Đã hủy</c:when>
                                <c:otherwise>${req.trangThai}</c:otherwise>
                            </c:choose>
                        </span>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        <fmt:formatDate value="${req.ngayGui}" pattern="dd/MM/yyyy HH:mm"/>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm">
                        <c:if test="${req.trangThai == 'ChoDuyet'}">
                            <form id="form-approve-${req.yeuCauNghiID}" method="post" action="${pageContext.request.contextPath}/manager/yeu-cau-nghi" style="display:inline;">
                                <input type="hidden" name="action" value="approve"/>
                                <input type="hidden" name="id" value="${req.yeuCauNghiID}"/>
                                <button type="button" onclick="confirmApprove(${req.yeuCauNghiID})" class="px-2.5 py-1 rounded-lg bg-green-50 border border-green-200 text-green-700 hover:bg-green-100 text-xs font-bold transition-all shadow-sm cursor-pointer mr-2">Phê duyệt</button>
                            </form>
                            <form id="form-reject-${req.yeuCauNghiID}" method="post" action="${pageContext.request.contextPath}/manager/yeu-cau-nghi" style="display:inline;">
                                <input type="hidden" name="action" value="reject"/>
                                <input type="hidden" name="id" value="${req.yeuCauNghiID}"/>
                                <button type="button" onclick="confirmReject(${req.yeuCauNghiID})" class="px-2.5 py-1 rounded-lg bg-red-50 border border-red-200 text-red-650 hover:bg-red-100 text-xs font-bold transition-all shadow-sm cursor-pointer">Từ chối</button>
                            </form>
                        </c:if>
                    </td>
                </tr>
            </c:forEach>
            <c:if test="${empty requests}">
                <tr>
                    <td colspan="9" class="px-6 py-10 text-center text-gray-500">
                        Chưa có yêu cầu nghỉ nào.
                    </td>
                </tr>
            </c:if>
            </tbody>
        </table>
    </div>
</div>

<script>
function confirmApprove(id) {
    if (confirm('Bạn có chắc muốn phê duyệt yêu cầu này?')) {
        document.getElementById('form-approve-' + id).submit();
    }
}
var confirmReject = function(id) {
    if (confirm('Bạn có chắc muốn từ chối yêu cầu này?')) {
        document.getElementById('form-reject-' + id).submit();
    }
}

// Reload page when navigated back/forward via bfcache
window.addEventListener('pageshow', function(event) {
    if (event.persisted) {
        window.location.reload();
    }
});
</script>
</body>
</html>
