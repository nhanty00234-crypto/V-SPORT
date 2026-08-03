<%-- src/main/webapp/manager/Luong.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <title>Quản lý lương | Manager V-SPORT</title>
  <jsp:include page="/manager/common/manager_head.jsp"/>
</head>
<body class="bg-[#fbfaff]">
<jsp:include page="/manager/common/sidebar.jsp"/>
<c:set var="headerTitle" value="Quản lý lương" scope="page"/>
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

  <%-- Banner nhắc: hôm nay đúng ngày phát lương của một kỳ --%>
  <c:if test="${not empty kyPhatHomNay}">
    <div class="p-4 rounded-xl bg-amber-50 border border-amber-200 flex items-center justify-between gap-4 flex-wrap">
      <div>
        <div class="font-bold text-amber-900">Hôm nay là ngày phát lương kỳ “${kyPhatHomNay.tenKy}”.</div>
        <div class="text-sm text-amber-800">Mở trang phát lương để chuyển khoản cho từng nhân viên.</div>
      </div>
      <a href="${pageContext.request.contextPath}/manager/luong/phat?kyLuongId=${kyPhatHomNay.kyLuongId}"
         class="px-4 py-2 rounded-lg bg-amber-500 text-white text-sm font-bold">Phát lương ngay</a>
    </div>
  </c:if>

  <div class="flex flex-wrap gap-3">
    <a href="${pageContext.request.contextPath}/manager/luong/cau-hinh"
       class="px-4 py-2 rounded-lg bg-white border border-violet-100 text-violet-700 text-sm font-bold">Cấu hình lương nhân viên</a>
    <a href="${pageContext.request.contextPath}/manager/luong/ung-luong"
       class="px-4 py-2 rounded-lg bg-white border border-violet-100 text-violet-700 text-sm font-bold">
      Yêu cầu ứng lương
      <c:if test="${soUngChoDuyet > 0}">
        <span class="ml-1 px-2 py-0.5 rounded-full bg-rose-500 text-white text-xs">${soUngChoDuyet}</span>
      </c:if>
    </a>
  </div>

  <%-- Tạo kỳ lương mới --%>
  <section class="bg-white border border-violet-100 rounded-2xl p-5">
    <h2 class="font-bold text-slate-800 mb-4">Tạo kỳ lương mới</h2>
    <form method="post" action="${pageContext.request.contextPath}/manager/luong"
          class="grid grid-cols-1 md:grid-cols-5 gap-3 items-end">
      <input type="hidden" name="action" value="tao-ky">
      <label class="text-sm">
        <span class="block text-slate-600 mb-1">Tên kỳ</span>
        <input name="tenKy" required placeholder="Tháng 8/2026"
               class="w-full h-10 px-3 rounded-lg border border-slate-200">
      </label>
      <label class="text-sm">
        <span class="block text-slate-600 mb-1">Từ ngày</span>
        <input type="date" name="ngayBatDau" required class="w-full h-10 px-3 rounded-lg border border-slate-200">
      </label>
      <label class="text-sm">
        <span class="block text-slate-600 mb-1">Đến ngày</span>
        <input type="date" name="ngayKetThuc" required class="w-full h-10 px-3 rounded-lg border border-slate-200">
      </label>
      <label class="text-sm">
        <span class="block text-slate-600 mb-1">Ngày phát lương</span>
        <input type="date" name="ngayPhatLuong" required class="w-full h-10 px-3 rounded-lg border border-slate-200">
      </label>
      <button class="h-10 px-4 rounded-lg bg-violet-600 text-white text-sm font-bold">Tạo kỳ</button>
    </form>
  </section>

  <%-- Danh sách kỳ lương --%>
  <section class="bg-white border border-violet-100 rounded-2xl overflow-hidden">
    <h2 class="font-bold text-slate-800 p-5 pb-3">Các kỳ lương</h2>
    <div class="overflow-x-auto">
      <table class="w-full text-sm">
        <thead class="bg-violet-50 text-slate-600">
        <tr>
          <th class="text-left px-5 py-3">Kỳ</th>
          <th class="text-left px-5 py-3">Khoảng thời gian</th>
          <th class="text-left px-5 py-3">Ngày phát</th>
          <th class="text-right px-5 py-3">Số NV</th>
          <th class="text-right px-5 py-3">Tổng chi</th>
          <th class="text-left px-5 py-3">Trạng thái</th>
          <th class="text-right px-5 py-3">Thao tác</th>
        </tr>
        </thead>
        <tbody>
        <c:forEach var="ky" items="${dsKy}">
          <tr class="border-t border-slate-100">
            <td class="px-5 py-3 font-semibold text-slate-800">${ky.tenKy}</td>
            <td class="px-5 py-3 text-slate-600">${ky.ngayBatDau} → ${ky.ngayKetThuc}</td>
            <td class="px-5 py-3 text-slate-600">${ky.ngayPhatLuong}</td>
            <td class="px-5 py-3 text-right">${ky.soNhanVien}</td>
            <td class="px-5 py-3 text-right font-bold text-slate-800">
              <fmt:formatNumber value="${ky.tongChi}" type="number" maxFractionDigits="0"/> đ
            </td>
            <td class="px-5 py-3">
              <c:choose>
                <c:when test="${ky.trangThai eq 'DaPhat'}">
                  <span class="px-2 py-1 rounded-full bg-emerald-50 text-emerald-700 text-xs font-bold">Đã phát</span>
                </c:when>
                <c:when test="${ky.trangThai eq 'DangTinh'}">
                  <span class="px-2 py-1 rounded-full bg-sky-50 text-sky-700 text-xs font-bold">Đã tính</span>
                </c:when>
                <c:otherwise>
                  <span class="px-2 py-1 rounded-full bg-slate-100 text-slate-600 text-xs font-bold">Nháp</span>
                </c:otherwise>
              </c:choose>
            </td>
            <td class="px-5 py-3">
              <div class="flex gap-2 justify-end">
                <c:if test="${ky.trangThai ne 'DaPhat'}">
                  <form method="post" action="${pageContext.request.contextPath}/manager/luong">
                    <input type="hidden" name="action" value="tinh-luong">
                    <input type="hidden" name="kyLuongId" value="${ky.kyLuongId}">
                    <button class="px-3 py-1.5 rounded-lg bg-violet-600 text-white text-xs font-bold">Tính lương</button>
                  </form>
                </c:if>
                <a href="${pageContext.request.contextPath}/manager/luong/phat?kyLuongId=${ky.kyLuongId}"
                   class="px-3 py-1.5 rounded-lg border border-violet-200 text-violet-700 text-xs font-bold">Xem / Phát</a>
              </div>
            </td>
          </tr>
        </c:forEach>
        <c:if test="${empty dsKy}">
          <tr><td colspan="7" class="px-5 py-8 text-center text-slate-400">Chưa có kỳ lương nào.</td></tr>
        </c:if>
        </tbody>
      </table>
    </div>
  </section>
</main>
</body>
</html>
