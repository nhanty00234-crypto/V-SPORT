<%-- src/main/webapp/manager/DuyetUngLuong.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <title>Yêu cầu ứng lương | Manager V-SPORT</title>
  <jsp:include page="/manager/common/manager_head.jsp"/>
</head>
<body class="bg-[#fbfaff]">
<jsp:include page="/manager/common/sidebar.jsp"/>
<c:set var="headerTitle" value="Yêu cầu ứng lương" scope="page"/>
<c:set var="headerSubtitle" value="Quyền hạn Quản lý · Cơ sở CS${sessionScope.user.coSoId}" scope="page"/>
<c:set var="headerIcon" value="payments" scope="page"/>
<jsp:include page="/manager/common/header.jsp"/>

<main class="lg:ml-[248px] mt-[64px] p-4 lg:p-6 flex flex-col gap-5">

  <a href="${pageContext.request.contextPath}/manager/luong" class="text-sm text-violet-700 font-bold">← Về quản lý lương</a>

  <%-- Bộ lọc trạng thái. Dùng chuỗi phân tách bằng dấu phẩy + forTokens thay vì EL list
       literal, để tương thích với cách các JSP khác trong dự án đang viết. --%>
  <div class="flex gap-2 flex-wrap">
    <a href="${pageContext.request.contextPath}/manager/luong/ung-luong"
       class="px-3 py-1.5 rounded-lg text-xs font-bold border
              ${empty locTrangThai ? 'bg-violet-600 text-white border-violet-600' : 'bg-white text-slate-600 border-slate-200'}">Tất cả</a>
    <c:forTokens var="tt" items="ChoDuyet,DaDuyet,TuChoi,DaHuy" delims=",">
      <c:choose>
        <c:when test="${tt eq 'ChoDuyet'}"><c:set var="nhan" value="Chờ duyệt"/></c:when>
        <c:when test="${tt eq 'DaDuyet'}"><c:set var="nhan" value="Đã duyệt"/></c:when>
        <c:when test="${tt eq 'TuChoi'}"><c:set var="nhan" value="Từ chối"/></c:when>
        <c:otherwise><c:set var="nhan" value="Đã huỷ"/></c:otherwise>
      </c:choose>
      <a href="${pageContext.request.contextPath}/manager/luong/ung-luong?trangThai=${tt}"
         class="px-3 py-1.5 rounded-lg text-xs font-bold border
                ${locTrangThai eq tt ? 'bg-violet-600 text-white border-violet-600' : 'bg-white text-slate-600 border-slate-200'}">${nhan}</a>
    </c:forTokens>
  </div>

  <section class="bg-white border border-violet-100 rounded-2xl overflow-hidden">
    <div class="overflow-x-auto">
      <table class="w-full text-sm">
        <thead class="bg-violet-50 text-slate-600">
        <tr>
          <th class="text-left px-5 py-3">Nhân viên</th>
          <th class="text-right px-5 py-3">Số tiền</th>
          <th class="text-left px-5 py-3">Lý do</th>
          <th class="text-left px-5 py-3">Ngày gửi</th>
          <th class="text-left px-5 py-3">Trạng thái</th>
          <th class="text-right px-5 py-3">Thao tác</th>
        </tr>
        </thead>
        <tbody>
        <c:forEach var="yc" items="${dsYeuCau}">
          <tr class="border-t border-slate-100" id="row-${yc.yeuCauUngLuongId}">
            <td class="px-5 py-3 font-semibold text-slate-800">${yc.hoTen}</td>
            <td class="px-5 py-3 text-right font-bold">
              <fmt:formatNumber value="${yc.soTienUng}" type="number" maxFractionDigits="0"/> đ
            </td>
            <td class="px-5 py-3 text-slate-600">${yc.lyDo}</td>
            <td class="px-5 py-3 text-slate-500">
              <fmt:formatDate value="${yc.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
            </td>
            <td class="px-5 py-3" id="tt-${yc.yeuCauUngLuongId}">
              <c:choose>
                <c:when test="${yc.trangThai eq 'DaDuyet'}">
                  <span class="px-2 py-1 rounded-full bg-emerald-50 text-emerald-700 text-xs font-bold">Đã duyệt</span>
                </c:when>
                <c:when test="${yc.trangThai eq 'TuChoi'}">
                  <span class="px-2 py-1 rounded-full bg-rose-50 text-rose-700 text-xs font-bold">Từ chối</span>
                </c:when>
                <c:when test="${yc.trangThai eq 'DaHuy'}">
                  <span class="px-2 py-1 rounded-full bg-slate-100 text-slate-500 text-xs font-bold">Đã huỷ</span>
                </c:when>
                <c:otherwise>
                  <span class="px-2 py-1 rounded-full bg-amber-50 text-amber-700 text-xs font-bold">Chờ duyệt</span>
                </c:otherwise>
              </c:choose>
            </td>
            <td class="px-5 py-3 text-right">
              <c:if test="${yc.choDuyet}">
                <div class="flex gap-2 justify-end" id="act-${yc.yeuCauUngLuongId}">
                  <button type="button" onclick="xuLy(${yc.yeuCauUngLuongId}, 'duyet')"
                          class="px-3 py-1.5 rounded-lg bg-emerald-600 text-white text-xs font-bold">Duyệt</button>
                  <button type="button" onclick="xuLy(${yc.yeuCauUngLuongId}, 'tu-choi')"
                          class="px-3 py-1.5 rounded-lg bg-rose-600 text-white text-xs font-bold">Từ chối</button>
                </div>
              </c:if>
            </td>
          </tr>
        </c:forEach>
        <c:if test="${empty dsYeuCau}">
          <tr><td colspan="6" class="px-5 py-8 text-center text-slate-400">Không có yêu cầu nào.</td></tr>
        </c:if>
        </tbody>
      </table>
    </div>
  </section>
</main>

<script>
  var CTX = '${pageContext.request.contextPath}';

  async function xuLy(yeuCauId, hanhDong) {
    var ghiChu = prompt(hanhDong === 'duyet' ? 'Ghi chú khi duyệt (tuỳ chọn):' : 'Lý do từ chối:');
    if (ghiChu === null) return;
    var act = document.getElementById('act-' + yeuCauId);
    act.querySelectorAll('button').forEach(function (b) { b.disabled = true; });
    try {
      var res = await fetch(CTX + '/manager/api/luong/duyet-ung', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({ yeuCauId: String(yeuCauId), hanhDong: hanhDong, ghiChu: ghiChu })
      });
      var data = await res.json();
      if (!data.ok) {
        alert(data.error || 'Không thể xử lý.');
        // Yêu cầu có thể đã bị xử lý ở tab khác — tải lại để thấy trạng thái thật.
        location.reload();
        return;
      }
      var duyet = hanhDong === 'duyet';
      document.getElementById('tt-' + yeuCauId).innerHTML =
        '<span class="px-2 py-1 rounded-full text-xs font-bold ' +
        (duyet ? 'bg-emerald-50 text-emerald-700">Đã duyệt' : 'bg-rose-50 text-rose-700">Từ chối') + '</span>';
      act.remove();
    } catch (e) {
      alert('Lỗi kết nối: ' + e.message);
      location.reload();
    }
  }
</script>
</body>
</html>
