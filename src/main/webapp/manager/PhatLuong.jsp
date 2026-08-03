<%-- src/main/webapp/manager/PhatLuong.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <title>Phát lương ${ky.tenKy} | Manager V-SPORT</title>
  <jsp:include page="/manager/common/manager_head.jsp"/>
</head>
<body class="bg-[#fbfaff]">
<jsp:include page="/manager/common/sidebar.jsp"/>
<c:set var="headerTitle" value="Phát lương" scope="page"/>
<c:set var="headerSubtitle" value="Kỳ ${ky.tenKy}" scope="page"/>
<c:set var="headerIcon" value="payments" scope="page"/>
<jsp:include page="/manager/common/header.jsp"/>

<main class="lg:ml-[248px] mt-[64px] p-4 lg:p-6 flex flex-col gap-5">

  <a href="${pageContext.request.contextPath}/manager/luong" class="text-sm text-violet-700 font-bold">← Về quản lý lương</a>

  <c:if test="${laNgayPhat}">
    <div class="p-4 rounded-xl bg-amber-50 border border-amber-200 text-amber-900 font-bold">
      Hôm nay (${ky.ngayPhatLuong}) là ngày phát lương của kỳ này.
    </div>
  </c:if>

  <div class="flex items-center justify-between gap-4 flex-wrap">
    <div class="text-sm text-slate-600">
      Kỳ ${ky.ngayBatDau} → ${ky.ngayKetThuc} · Trạng thái:
      <span class="font-bold text-slate-800">
        <c:choose>
          <c:when test="${ky.trangThai eq 'DaPhat'}">Đã phát</c:when>
          <c:when test="${ky.trangThai eq 'DangTinh'}">Đã tính</c:when>
          <c:otherwise>Nháp</c:otherwise>
        </c:choose>
      </span>
    </div>
    <c:if test="${ky.trangThai ne 'DaPhat'}">
      <form method="post" action="${pageContext.request.contextPath}/manager/luong"
            onsubmit="return confirm('Chốt phát lương kỳ này? Sau khi chốt sẽ không tính lại được.');">
        <input type="hidden" name="action" value="chot-phat">
        <input type="hidden" name="kyLuongId" value="${ky.kyLuongId}">
        <button class="px-4 py-2 rounded-lg bg-emerald-600 text-white text-sm font-bold">Chốt phát lương</button>
      </form>
    </c:if>
  </div>

  <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
    <c:forEach var="bl" items="${dsBangLuong}">
      <div id="card-${bl.bangLuongId}"
           class="bg-white border rounded-2xl p-5 flex flex-col gap-3
                  ${bl.daChuyenKhoan ? 'border-emerald-300 bg-emerald-50/40' : 'border-violet-100'}">
        <div class="flex items-center justify-between gap-3">
          <div>
            <div class="font-bold text-slate-800">${bl.hoTen}</div>
            <div class="text-xs text-slate-500">${bl.soCaLamViec} ca làm việc</div>
          </div>
          <span id="badge-${bl.bangLuongId}"
                class="px-2 py-1 rounded-full text-xs font-bold
                       ${bl.daChuyenKhoan ? 'bg-emerald-100 text-emerald-700' : 'bg-slate-100 text-slate-600'}">
            ${bl.daChuyenKhoan ? 'Đã chuyển khoản' : 'Chưa chuyển'}
          </span>
        </div>

        <div class="text-2xl font-extrabold text-violet-700">
          <fmt:formatNumber value="${bl.tongLuongThuc}" type="number" maxFractionDigits="0"/> đ
        </div>
        <div class="text-xs text-slate-500">
          Cơ bản <fmt:formatNumber value="${bl.luongCoBan}" type="number" maxFractionDigits="0"/> đ
          · Phụ cấp <fmt:formatNumber value="${bl.tongPhuCap}" type="number" maxFractionDigits="0"/> đ
          · Đã ứng <fmt:formatNumber value="${bl.tongKhauTru}" type="number" maxFractionDigits="0"/> đ
        </div>

        <div class="flex gap-3 items-start">
          <c:choose>
            <c:when test="${not empty bl.qrDongUrl}">
              <img src="${bl.qrDongUrl}" alt="QR chuyển khoản" class="w-36 h-36 rounded-lg border border-slate-200">
            </c:when>
            <c:otherwise>
              <div class="w-36 h-36 rounded-lg border border-dashed border-rose-300 bg-rose-50 text-rose-600
                          text-xs p-3 flex items-center text-center">
                Nhân viên chưa khai báo tài khoản ngân hàng.
              </div>
            </c:otherwise>
          </c:choose>

          <c:if test="${not empty bl.qrImagePath}">
            <div class="text-center">
              <img src="${pageContext.request.contextPath}/nhan-vien/qr-image?accountId=${bl.accountId}"
                   alt="QR tĩnh của nhân viên" class="w-24 h-24 rounded-lg border border-slate-200">
              <div class="text-[10px] text-slate-400 mt-1">QR nhân viên tải lên</div>
            </div>
          </c:if>
        </div>

        <div class="text-xs text-slate-600">
          <div>Ngân hàng: <span class="font-semibold">${empty bl.maNganHang ? '—' : bl.maNganHang}</span></div>
          <div>Số TK: <span class="font-semibold">${empty bl.soTaiKhoan ? '—' : bl.soTaiKhoan}</span></div>
          <div>Chủ TK: <span class="font-semibold">${bl.hoTen}</span></div>
        </div>

        <c:if test="${not bl.daChuyenKhoan}">
          <button type="button" id="btn-${bl.bangLuongId}"
                  onclick="xacNhan(${bl.bangLuongId})"
                  class="mt-1 h-10 rounded-lg bg-violet-600 text-white text-sm font-bold">Đã chuyển khoản</button>
        </c:if>
      </div>
    </c:forEach>

    <c:if test="${empty dsBangLuong}">
      <div class="col-span-full p-8 text-center text-slate-400 bg-white border border-violet-100 rounded-2xl">
        Kỳ này chưa được tính lương. Về trang quản lý lương và bấm “Tính lương”.
      </div>
    </c:if>
  </div>
</main>

<script>
  var CTX = '${pageContext.request.contextPath}';

  async function xacNhan(bangLuongId) {
    var btn = document.getElementById('btn-' + bangLuongId);
    btn.disabled = true;
    try {
      // header X-CSRF-Token do manager_head.jsp tự gắn cho mọi fetch POST
      var res = await fetch(CTX + '/manager/api/luong/xac-nhan', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({ bangLuongId: String(bangLuongId) })
      });
      var data = await res.json();
      if (!data.ok) {
        alert(data.error || 'Không thể xác nhận.');
        btn.disabled = false;
        return;
      }
      var card = document.getElementById('card-' + bangLuongId);
      card.classList.remove('border-violet-100');
      card.classList.add('border-emerald-300', 'bg-emerald-50/40');
      var badge = document.getElementById('badge-' + bangLuongId);
      badge.className = 'px-2 py-1 rounded-full text-xs font-bold bg-emerald-100 text-emerald-700';
      badge.textContent = 'Đã chuyển khoản';
      btn.remove();
    } catch (e) {
      alert('Lỗi kết nối: ' + e.message);
      btn.disabled = false;
    }
  }
</script>
</body>
</html>
