<%-- src/main/webapp/manager/CauHinhLuong.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <title>Cấu hình lương | Manager V-SPORT</title>
  <jsp:include page="/manager/common/manager_head.jsp"/>
</head>
<body class="bg-[#fbfaff]">
<jsp:include page="/manager/common/sidebar.jsp"/>
<c:set var="headerTitle" value="Cấu hình lương nhân viên" scope="page"/>
<c:set var="headerSubtitle" value="Quyền hạn Quản lý · Cơ sở CS${sessionScope.user.coSoId}" scope="page"/>
<c:set var="headerIcon" value="payments" scope="page"/>
<jsp:include page="/manager/common/header.jsp"/>

<main class="lg:ml-[248px] mt-[64px] p-4 lg:p-6 flex flex-col gap-5">

  <c:if test="${not empty sessionScope.flashSuccess}">
    <div class="p-4 bg-violet-50 border border-violet-100 rounded-xl text-violet-700 text-sm">${sessionScope.flashSuccess}</div>
    <c:remove var="flashSuccess" scope="session"/>
  </c:if>
  <c:if test="${not empty sessionScope.flashError}">
    <div class="p-4 bg-rose-50 border border-rose-100 rounded-xl text-rose-700 text-sm">${sessionScope.flashError}</div>
    <c:remove var="flashError" scope="session"/>
  </c:if>

  <a href="${pageContext.request.contextPath}/manager/luong" class="text-sm text-violet-700 font-bold">← Về quản lý lương</a>

  <section class="bg-white border border-violet-100 rounded-2xl overflow-hidden">
    <div class="p-5 pb-3">
      <h2 class="font-bold text-slate-800">Lương cơ bản, phụ cấp và hạn mức ứng</h2>
      <p class="text-sm text-slate-500">Nhân viên chưa có lương cơ bản và phụ cấp sẽ không được đưa vào bảng lương khi tính kỳ.</p>
    </div>
    <div class="overflow-x-auto">
      <table class="w-full text-sm">
        <thead class="bg-violet-50 text-slate-600">
        <tr>
          <th class="text-left px-5 py-3">Nhân viên</th>
          <th class="text-left px-5 py-3">Vai trò</th>
          <th class="text-right px-5 py-3">Lương cơ bản (đ)</th>
          <th class="text-right px-5 py-3">Phụ cấp / ca (đ)</th>
          <th class="text-right px-5 py-3">Hạn mức ứng (đ)</th>
          <th class="text-left px-5 py-3">Ghi chú</th>
          <th class="px-5 py-3"></th>
        </tr>
        </thead>
        <tbody>
        <c:forEach var="ch" items="${dsCauHinh}">
          <tr class="border-t border-slate-100">
            <form method="post" action="${pageContext.request.contextPath}/manager/luong/cau-hinh">
              <input type="hidden" name="accountId" value="${ch.accountId}">
              <td class="px-5 py-3 font-semibold text-slate-800">${ch.hoTen}</td>
              <td class="px-5 py-3 text-slate-600">${ch.tenVaiTro}</td>
              <td class="px-5 py-3">
                <input name="luongCoBan" inputmode="numeric"
                       value="<fmt:formatNumber value='${ch.luongCoBan}' type='number' maxFractionDigits='0'/>"
                       class="w-32 h-9 px-2 text-right rounded-lg border border-slate-200">
              </td>
              <td class="px-5 py-3">
                <input name="phuCapMoiCa" inputmode="numeric"
                       value="<fmt:formatNumber value='${ch.phuCapMoiCa}' type='number' maxFractionDigits='0'/>"
                       class="w-28 h-9 px-2 text-right rounded-lg border border-slate-200">
              </td>
              <td class="px-5 py-3">
                <input name="hanMucUng" inputmode="numeric"
                       value="<fmt:formatNumber value='${ch.hanMucUng}' type='number' maxFractionDigits='0'/>"
                       class="w-32 h-9 px-2 text-right rounded-lg border border-slate-200">
              </td>
              <td class="px-5 py-3">
                <input name="ghiChu" value="${ch.ghiChu}" maxlength="500"
                       class="w-48 h-9 px-2 rounded-lg border border-slate-200">
              </td>
              <td class="px-5 py-3 text-right">
                <button class="px-3 py-1.5 rounded-lg bg-violet-600 text-white text-xs font-bold">Lưu</button>
              </td>
            </form>
          </tr>
        </c:forEach>
        <c:if test="${empty dsCauHinh}">
          <tr><td colspan="7" class="px-5 py-8 text-center text-slate-400">Cơ sở chưa có nhân viên lễ tân / bảo vệ.</td></tr>
        </c:if>
        </tbody>
      </table>
    </div>
  </section>
</main>
</body>
</html>
