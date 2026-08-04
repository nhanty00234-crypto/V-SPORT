<%-- src/main/webapp/staff/LuongCuaToi.jsp — dùng chung cho lễ tân (/staff/luong) và bảo vệ (/guard/luong) --%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="laBaoVe" value="${sessionScope.user.roleId eq 5}"/>
<c:set var="luongUrl" value="${laBaoVe ? '/guard/luong' : '/staff/luong'}"/>
<%-- Tông màu bám theo từng portal: bảo vệ dùng rose, lễ tân dùng orange (giống các
     trang sẵn có của hai role), nên trang này không lệch khỏi phần còn lại. --%>
<c:set var="acc"      value="${laBaoVe ? 'rose' : 'orange'}"/>
<c:set var="accBorder" value="border-${acc}-100"/>
<c:set var="accText"   value="text-${acc}-700"/>
<c:set var="accBtn"    value="bg-${acc}-600"/>
<c:set var="accHead"   value="bg-${acc}-50"/>
<c:set var="offsetTop" value="${laBaoVe ? 'mt-[60px]' : 'mt-[64px]'}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
  <title>Lương của tôi | V-SPORT</title>
  <c:choose>
    <c:when test="${laBaoVe}"><jsp:include page="/guard/common/guard_head.jsp"/></c:when>
    <c:otherwise><jsp:include page="/staff/common/staff_head.jsp"/></c:otherwise>
  </c:choose>
</head>
<body class="text-zinc-900 min-h-screen">
<c:choose>
  <c:when test="${laBaoVe}"><jsp:include page="/guard/common/sidebar.jsp"/></c:when>
  <c:otherwise><jsp:include page="/staff/common/sidebar.jsp"/></c:otherwise>
</c:choose>
<c:choose>
  <c:when test="${laBaoVe}">
    <jsp:include page="/guard/common/header.jsp">
      <jsp:param name="pageTitle" value="Lương của tôi"/>
      <jsp:param name="pageSubtitle" value="Bảo vệ · Cơ sở CS${sessionScope.user.coSoId}"/>
    </jsp:include>
  </c:when>
  <c:otherwise>
    <jsp:include page="/staff/common/header.jsp">
      <jsp:param name="pageTitle" value="Lương của tôi"/>
      <jsp:param name="pageSubtitle" value="Nhân viên · Cơ sở CS${sessionScope.user.coSoId}"/>
    </jsp:include>
  </c:otherwise>
</c:choose>

<main class="lg:ml-[248px] ${offsetTop} p-4 lg:p-6 flex flex-col gap-5">

  <c:if test="${not empty sessionScope.flashSuccess}">
    <div class="p-4 ${accHead} border ${accBorder} rounded-xl ${accText} text-sm">${sessionScope.flashSuccess}</div>
    <c:remove var="flashSuccess" scope="session"/>
  </c:if>
  <c:if test="${not empty sessionScope.flashError}">
    <div class="p-4 bg-rose-50 border border-rose-100 rounded-xl text-rose-700 text-sm">${sessionScope.flashError}</div>
    <c:remove var="flashError" scope="session"/>
  </c:if>

  <%-- ── Bảng lương theo kỳ ── --%>
  <section class="bg-white border ${accBorder} rounded-2xl overflow-hidden">
    <h2 class="font-bold text-slate-800 p-5 pb-3">Bảng lương</h2>
    <div class="overflow-x-auto">
      <table class="w-full text-sm">
        <thead class="${accHead} text-slate-600">
        <tr>
          <th class="text-left px-5 py-3">Kỳ</th>
          <th class="text-right px-5 py-3">Số ca</th>
          <th class="text-right px-5 py-3">Lương cơ bản</th>
          <th class="text-right px-5 py-3">Phụ cấp</th>
          <th class="text-right px-5 py-3">Đã ứng</th>
          <th class="text-right px-5 py-3">Thực nhận</th>
          <th class="text-left px-5 py-3">Trạng thái</th>
        </tr>
        </thead>
        <tbody>
        <c:forEach var="bl" items="${dsBangLuong}">
          <tr class="border-t border-slate-100">
            <td class="px-5 py-3 font-semibold text-slate-800">${bl.tenKy}</td>
            <td class="px-5 py-3 text-right">${bl.soCaLamViec}</td>
            <td class="px-5 py-3 text-right"><fmt:formatNumber value="${bl.luongCoBan}" type="number" maxFractionDigits="0"/></td>
            <td class="px-5 py-3 text-right"><fmt:formatNumber value="${bl.tongPhuCap}" type="number" maxFractionDigits="0"/></td>
            <td class="px-5 py-3 text-right text-rose-600">−<fmt:formatNumber value="${bl.tongKhauTru}" type="number" maxFractionDigits="0"/></td>
            <td class="px-5 py-3 text-right font-extrabold ${accText}">
              <fmt:formatNumber value="${bl.tongLuongThuc}" type="number" maxFractionDigits="0"/> đ
            </td>
            <td class="px-5 py-3">
              <c:choose>
                <c:when test="${bl.trangThai eq 'XacNhanDaChuyenKhoan'}">
                  <span class="px-2 py-1 rounded-full bg-emerald-50 text-emerald-700 text-xs font-bold">Đã nhận</span>
                </c:when>
                <c:when test="${bl.trangThai eq 'DaPhat'}">
                  <span class="px-2 py-1 rounded-full bg-sky-50 text-sky-700 text-xs font-bold">Đang chuyển</span>
                </c:when>
                <c:otherwise>
                  <span class="px-2 py-1 rounded-full bg-slate-100 text-slate-600 text-xs font-bold">Đã tính</span>
                </c:otherwise>
              </c:choose>
            </td>
          </tr>
        </c:forEach>
        <c:if test="${empty dsBangLuong}">
          <tr><td colspan="7" class="px-5 py-8 text-center text-slate-400">Chưa có kỳ lương nào được tính cho bạn.</td></tr>
        </c:if>
        </tbody>
      </table>
    </div>
  </section>

  <div class="grid grid-cols-1 lg:grid-cols-2 gap-5">

    <%-- ── Tài khoản ngân hàng nhận lương ── --%>
    <section class="bg-white border ${accBorder} rounded-2xl p-5 flex flex-col gap-4">
      <h2 class="font-bold text-slate-800">Tài khoản ngân hàng nhận lương</h2>
      <form method="post" action="${pageContext.request.contextPath}${luongUrl}" class="flex flex-col gap-3">
        <input type="hidden" name="action" value="luu-ngan-hang">
        <label class="text-sm">
          <span class="block text-slate-600 mb-1">Mã ngân hàng (BIN, ví dụ 970436 = Vietcombank)</span>
          <input name="maNganHang" value="${nhanVien.maNganHang}" maxlength="20"
                 class="w-full h-10 px-3 rounded-lg border border-slate-200">
        </label>
        <label class="text-sm">
          <span class="block text-slate-600 mb-1">Số tài khoản</span>
          <input name="soTaiKhoan" value="${nhanVien.soTaiKhoan}" maxlength="30"
                 class="w-full h-10 px-3 rounded-lg border border-slate-200">
        </label>
        <button class="h-10 rounded-lg ${accBtn} text-white text-sm font-bold">Lưu thông tin ngân hàng</button>
      </form>

      <div class="border-t border-slate-100 pt-4">
        <div class="text-sm font-bold text-slate-700 mb-2">Ảnh QR ngân hàng (tuỳ chọn)</div>
        <c:if test="${not empty nhanVien.qrImagePath}">
          <img src="${pageContext.request.contextPath}/nhan-vien/qr-image?accountId=${nhanVien.accountId}"
               alt="QR ngân hàng của tôi" class="w-32 h-32 rounded-lg border border-slate-200 mb-3">
        </c:if>
        <form method="post" action="${pageContext.request.contextPath}${luongUrl}"
              enctype="multipart/form-data" class="flex flex-col gap-2">
          <input type="hidden" name="action" value="upload-qr">
          <input type="file" name="qrImage" accept="image/png,image/jpeg,image/webp" required class="text-sm">
          <p class="text-xs text-slate-400">JPG/PNG/WEBP, tối đa 3MB, tối thiểu 120×120.</p>
          <button class="h-10 rounded-lg bg-white border ${accBorder} ${accText} text-sm font-bold">Tải lên ảnh QR</button>
        </form>
      </div>
    </section>

    <%-- ── Ứng lương ── --%>
    <section class="bg-white border ${accBorder} rounded-2xl p-5 flex flex-col gap-4">
      <div>
        <h2 class="font-bold text-slate-800">Yêu cầu ứng lương</h2>
        <p class="text-sm text-slate-500">
          Hạn mức còn ứng được:
          <span class="font-bold ${accText}">
            <fmt:formatNumber value="${hanMucConLai}" type="number" maxFractionDigits="0"/> đ
          </span>
        </p>
      </div>

      <form method="post" action="${pageContext.request.contextPath}${luongUrl}" class="flex flex-col gap-3">
        <input type="hidden" name="action" value="gui-ung">
        <label class="text-sm">
          <span class="block text-slate-600 mb-1">Số tiền muốn ứng (đ)</span>
          <input name="soTienUng" inputmode="numeric" required
                 class="w-full h-10 px-3 rounded-lg border border-slate-200">
        </label>
        <label class="text-sm">
          <span class="block text-slate-600 mb-1">Lý do</span>
          <textarea name="lyDo" rows="2" maxlength="500"
                    class="w-full px-3 py-2 rounded-lg border border-slate-200"></textarea>
        </label>
        <button class="h-10 rounded-lg ${accBtn} text-white text-sm font-bold">Gửi yêu cầu</button>
      </form>

      <div class="border-t border-slate-100 pt-4">
        <div class="text-sm font-bold text-slate-700 mb-2">Lịch sử yêu cầu</div>
        <div class="flex flex-col gap-2">
          <c:forEach var="yc" items="${dsYeuCau}">
            <div class="flex items-center justify-between gap-3 p-3 rounded-lg bg-slate-50 text-sm">
              <div>
                <div class="font-bold text-slate-800">
                  <fmt:formatNumber value="${yc.soTienUng}" type="number" maxFractionDigits="0"/> đ
                </div>
                <div class="text-xs text-slate-500">
                  ${yc.createdAtFormatted}
                  <c:if test="${not empty yc.lyDo}"> · ${yc.lyDo}</c:if>
                </div>
                <c:if test="${not empty yc.ghiChuQuanLy}">
                  <div class="text-xs text-slate-500">Quản lý: ${yc.ghiChuQuanLy}</div>
                </c:if>
              </div>
              <div class="flex items-center gap-2">
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
                <c:if test="${yc.choDuyet}">
                  <form method="post" action="${pageContext.request.contextPath}${luongUrl}">
                    <input type="hidden" name="action" value="huy-ung">
                    <input type="hidden" name="yeuCauId" value="${yc.yeuCauUngLuongId}">
                    <button class="px-2 py-1 rounded-lg border border-slate-300 text-slate-600 text-xs font-bold">Huỷ</button>
                  </form>
                </c:if>
              </div>
            </div>
          </c:forEach>
          <c:if test="${empty dsYeuCau}">
            <div class="text-sm text-slate-400">Chưa có yêu cầu ứng lương nào.</div>
          </c:if>
        </div>
      </div>
    </section>
  </div>
</main>
</body>
</html>
