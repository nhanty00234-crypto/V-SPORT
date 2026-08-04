<%-- src/main/webapp/manager/Luong.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <title>Quản lý lương | Manager V-SPORT</title>
  <jsp:include page="/manager/common/manager_head.jsp"/>
  <style>
    .step-done   { background:#7c3aed; color:#fff; }
    .step-active { background:#fff; color:#7c3aed; border:2px solid #7c3aed; }
    .step-pending{ background:#f1f5f9; color:#94a3b8; }
    .step-line-done   { background:#7c3aed; }
    .step-line-pending{ background:#e2e8f0; }
  </style>
</head>
<body class="bg-[#fbfaff]">
<jsp:include page="/manager/common/sidebar.jsp"/>
<c:set var="headerTitle"    value="Quản lý lương" scope="page"/>
<c:set var="headerSubtitle" value="Quyền hạn Quản lý · Cơ sở CS${sessionScope.user.coSoId}" scope="page"/>
<c:set var="headerIcon"     value="payments" scope="page"/>
<jsp:include page="/manager/common/header.jsp"/>

<main class="lg:ml-[248px] mt-[64px] p-4 lg:p-6 flex flex-col gap-5">

  <%-- Flash messages --%>
  <c:if test="${not empty sessionScope.flashSuccess}">
    <div class="p-4 bg-violet-50 border border-violet-100 rounded-xl text-violet-700 text-sm">${sessionScope.flashSuccess}</div>
    <c:remove var="flashSuccess" scope="session"/>
  </c:if>
  <c:if test="${not empty sessionScope.flashError}">
    <div class="p-4 bg-rose-50 border border-rose-100 rounded-xl text-rose-700 text-sm">${sessionScope.flashError}</div>
    <c:remove var="flashError" scope="session"/>
  </c:if>

  <%-- Banner ngày phát lương --%>
  <c:if test="${not empty kyPhatHomNay}">
    <div class="p-4 rounded-xl bg-amber-50 border-2 border-amber-300 flex items-center justify-between gap-4 flex-wrap">
      <div class="flex items-center gap-3">
        <span class="material-symbols-outlined text-amber-500 text-3xl">notifications_active</span>
        <div>
          <div class="font-bold text-amber-900">Hôm nay là ngày phát lương kỳ "${kyPhatHomNay.tenKy}"</div>
          <div class="text-sm text-amber-700 mt-0.5">Mở trang phát lương để chuyển khoản cho từng nhân viên.</div>
        </div>
      </div>
      <a href="${pageContext.request.contextPath}/manager/luong/phat?kyLuongId=${kyPhatHomNay.kyLuongId}"
         class="shrink-0 px-5 py-2.5 rounded-xl bg-amber-500 hover:bg-amber-600 text-white text-sm font-bold transition-colors flex items-center gap-2">
        <span class="material-symbols-outlined text-base">send_money</span>
        Phát lương ngay
      </a>
    </div>
  </c:if>

  <%-- Tabs điều hướng --%>
  <div class="flex flex-wrap gap-2">
    <a href="${pageContext.request.contextPath}/manager/luong/cau-hinh"
       class="px-4 py-2 rounded-lg bg-white border border-violet-200 text-violet-700 text-sm font-semibold hover:bg-violet-50 transition-colors flex items-center gap-2">
      <span class="material-symbols-outlined text-base">manage_accounts</span>
      Cấu hình lương nhân viên
    </a>
    <a href="${pageContext.request.contextPath}/manager/luong/ung-luong"
       class="px-4 py-2 rounded-lg bg-white border border-violet-200 text-violet-700 text-sm font-semibold hover:bg-violet-50 transition-colors flex items-center gap-2">
      <span class="material-symbols-outlined text-base">request_quote</span>
      Yêu cầu ứng lương
      <c:if test="${soUngChoDuyet > 0}">
        <span class="px-2 py-0.5 rounded-full bg-rose-500 text-white text-xs">${soUngChoDuyet}</span>
      </c:if>
    </a>
  </div>

  <%-- Hướng dẫn quy trình --%>
  <section class="bg-white border border-violet-100 rounded-2xl p-5">
    <p class="text-xs font-semibold text-slate-400 uppercase tracking-wider mb-4">Quy trình phát lương</p>
    <div class="flex items-center gap-0">

      <%-- Bước 1 --%>
      <div class="flex flex-col items-center gap-2 min-w-[120px]">
        <div class="w-10 h-10 rounded-full step-done flex items-center justify-center font-bold text-sm shadow">1</div>
        <span class="text-xs font-semibold text-violet-700 text-center">Tạo kỳ lương</span>
        <span class="text-[11px] text-slate-400 text-center">Xác định khoảng<br>thời gian & ngày phát</span>
      </div>

      <div class="flex-1 h-0.5 step-line-done mb-8"></div>

      <%-- Bước 2 --%>
      <div class="flex flex-col items-center gap-2 min-w-[120px]">
        <div class="w-10 h-10 rounded-full step-active flex items-center justify-center font-bold text-sm shadow">2</div>
        <span class="text-xs font-semibold text-violet-700 text-center">Tính lương</span>
        <span class="text-[11px] text-slate-400 text-center">Hệ thống tự động<br>tổng hợp ca làm việc</span>
      </div>

      <div class="flex-1 h-0.5 step-line-pending mb-8"></div>

      <%-- Bước 3 --%>
      <div class="flex flex-col items-center gap-2 min-w-[120px]">
        <div class="w-10 h-10 rounded-full step-pending flex items-center justify-center font-bold text-sm">3</div>
        <span class="text-xs font-semibold text-slate-400 text-center">Phát lương</span>
        <span class="text-[11px] text-slate-400 text-center">Xác nhận &amp; ghi nhận<br>đã chuyển khoản</span>
      </div>

    </div>
  </section>

  <%-- Nút tạo kỳ lương mới (toggle accordion) --%>
  <div>
    <button id="btnToggleForm"
            onclick="toggleCreateForm()"
            class="flex items-center gap-2 px-5 py-2.5 rounded-xl bg-violet-600 hover:bg-violet-700 text-white text-sm font-bold transition-colors shadow-sm">
      <span class="material-symbols-outlined text-base" id="btnIcon">add</span>
      <span id="btnLabel">Tạo kỳ lương mới</span>
    </button>

    <%-- Panel form (ẩn mặc định) --%>
    <div id="createFormPanel" class="hidden mt-3 bg-white border border-violet-100 rounded-2xl p-5 shadow-sm">
      <h2 class="font-bold text-slate-800 mb-1">Tạo kỳ lương mới</h2>
      <p class="text-sm text-slate-500 mb-5">Điền đầy đủ thông tin bên dưới để tạo một kỳ tính lương mới cho nhân viên.</p>

      <form method="post" action="${pageContext.request.contextPath}/manager/luong">
        <input type="hidden" name="action" value="tao-ky">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-5">

          <label class="flex flex-col gap-1">
            <span class="text-sm font-semibold text-slate-600">Tên kỳ lương <span class="text-rose-500">*</span></span>
            <input name="tenKy" required placeholder="VD: Tháng 8/2026"
                   class="h-11 px-3 rounded-xl border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-violet-300">
            <span class="text-xs text-slate-400">Đặt tên dễ nhận biết, VD: Tháng 8/2026</span>
          </label>

          <label class="flex flex-col gap-1">
            <span class="text-sm font-semibold text-slate-600">Ngày phát lương <span class="text-rose-500">*</span></span>
            <input type="date" name="ngayPhatLuong" required
                   class="h-11 px-3 rounded-xl border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-violet-300">
            <span class="text-xs text-slate-400">Ngày dự kiến chuyển khoản cho nhân viên</span>
          </label>

          <label class="flex flex-col gap-1">
            <span class="text-sm font-semibold text-slate-600">Từ ngày <span class="text-rose-500">*</span></span>
            <input type="date" name="ngayBatDau" required
                   class="h-11 px-3 rounded-xl border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-violet-300">
            <span class="text-xs text-slate-400">Ngày bắt đầu tính ca làm việc</span>
          </label>

          <label class="flex flex-col gap-1">
            <span class="text-sm font-semibold text-slate-600">Đến ngày <span class="text-rose-500">*</span></span>
            <input type="date" name="ngayKetThuc" required
                   class="h-11 px-3 rounded-xl border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-violet-300">
            <span class="text-xs text-slate-400">Ngày kết thúc tính ca làm việc</span>
          </label>

        </div>

        <div class="flex gap-3">
          <button type="submit"
                  class="px-6 py-2.5 rounded-xl bg-violet-600 hover:bg-violet-700 text-white text-sm font-bold transition-colors">
            Tạo kỳ lương
          </button>
          <button type="button" onclick="toggleCreateForm()"
                  class="px-6 py-2.5 rounded-xl border border-slate-200 text-slate-600 text-sm font-semibold hover:bg-slate-50 transition-colors">
            Huỷ
          </button>
        </div>
      </form>
    </div>
  </div>

  <%-- Danh sách kỳ lương --%>
  <section class="bg-white border border-violet-100 rounded-2xl overflow-hidden">
    <div class="px-5 py-4 border-b border-slate-100 flex items-center justify-between">
      <h2 class="font-bold text-slate-800">Các kỳ lương</h2>
      <span class="text-sm text-slate-400">${dsKy.size()} kỳ</span>
    </div>
    <div class="overflow-x-auto">
      <table class="w-full text-sm">
        <thead class="bg-slate-50 text-slate-500 text-xs uppercase tracking-wide">
        <tr>
          <th class="text-left px-5 py-3 font-semibold">Kỳ lương</th>
          <th class="text-left px-5 py-3 font-semibold">Khoảng thời gian</th>
          <th class="text-left px-5 py-3 font-semibold">Ngày phát</th>
          <th class="text-right px-5 py-3 font-semibold">Số NV</th>
          <th class="text-right px-5 py-3 font-semibold">Tổng chi</th>
          <th class="text-center px-5 py-3 font-semibold">Trạng thái</th>
          <th class="text-center px-5 py-3 font-semibold">Bước tiếp theo</th>
        </tr>
        </thead>
        <tbody class="divide-y divide-slate-100">
        <c:forEach var="ky" items="${dsKy}">
          <tr class="hover:bg-slate-50 transition-colors">

            <%-- Tên kỳ --%>
            <td class="px-5 py-4">
              <div class="font-semibold text-slate-800">${ky.tenKy}</div>
            </td>

            <%-- Khoảng thời gian --%>
            <td class="px-5 py-4 text-slate-500">
              <div class="flex items-center gap-1.5">
                <span class="material-symbols-outlined text-slate-300 text-base">date_range</span>
                <fmt:formatDate value="${ky.ngayBatDau}" pattern="dd/MM/yyyy"/> –
                <fmt:formatDate value="${ky.ngayKetThuc}" pattern="dd/MM/yyyy"/>
              </div>
            </td>

            <%-- Ngày phát --%>
            <td class="px-5 py-4 text-slate-500">
              <fmt:formatDate value="${ky.ngayPhatLuong}" pattern="dd/MM/yyyy"/>
            </td>

            <%-- Số NV --%>
            <td class="px-5 py-4 text-right font-medium text-slate-700">${ky.soNhanVien}</td>

            <%-- Tổng chi --%>
            <td class="px-5 py-4 text-right font-bold text-slate-800">
              <c:choose>
                <c:when test="${ky.tongChi > 0}">
                  <fmt:formatNumber value="${ky.tongChi}" type="number" maxFractionDigits="0"/>đ
                </c:when>
                <c:otherwise><span class="text-slate-300">—</span></c:otherwise>
              </c:choose>
            </td>

            <%-- Trạng thái --%>
            <td class="px-5 py-4 text-center">
              <c:choose>
                <c:when test="${ky.trangThai eq 'DaPhat'}">
                  <span class="inline-flex items-center gap-1 px-3 py-1 rounded-full bg-emerald-50 text-emerald-700 text-xs font-bold">
                    <span class="material-symbols-outlined text-xs">check_circle</span> Đã phát
                  </span>
                </c:when>
                <c:when test="${ky.trangThai eq 'DangTinh'}">
                  <span class="inline-flex items-center gap-1 px-3 py-1 rounded-full bg-sky-50 text-sky-700 text-xs font-bold">
                    <span class="material-symbols-outlined text-xs">calculate</span> Đã tính
                  </span>
                </c:when>
                <c:otherwise>
                  <span class="inline-flex items-center gap-1 px-3 py-1 rounded-full bg-slate-100 text-slate-500 text-xs font-bold">
                    <span class="material-symbols-outlined text-xs">draft</span> Nháp
                  </span>
                </c:otherwise>
              </c:choose>
            </td>

            <%-- Bước tiếp theo --%>
            <td class="px-5 py-4">
              <div class="flex items-center justify-center gap-2 flex-wrap">
                <c:choose>
                  <c:when test="${ky.trangThai eq 'DaPhat'}">
                    <%-- Đã xong: chỉ xem --%>
                    <a href="${pageContext.request.contextPath}/manager/luong/phat?kyLuongId=${ky.kyLuongId}"
                       class="inline-flex items-center gap-1 px-3 py-1.5 rounded-lg border border-slate-200 text-slate-500 text-xs font-semibold hover:bg-slate-50 transition-colors">
                      <span class="material-symbols-outlined text-xs">visibility</span> Xem chi tiết
                    </a>
                  </c:when>
                  <c:when test="${ky.trangThai eq 'DangTinh'}">
                    <%-- Đã tính: nút chính là Phát lương --%>
                    <a href="${pageContext.request.contextPath}/manager/luong/phat?kyLuongId=${ky.kyLuongId}"
                       class="inline-flex items-center gap-1 px-4 py-1.5 rounded-lg bg-amber-500 hover:bg-amber-600 text-white text-xs font-bold transition-colors shadow-sm">
                      <span class="material-symbols-outlined text-xs">send_money</span> Phát lương
                    </a>
                    <a href="${pageContext.request.contextPath}/manager/luong/phat?kyLuongId=${ky.kyLuongId}"
                       class="inline-flex items-center gap-1 px-3 py-1.5 rounded-lg border border-slate-200 text-slate-500 text-xs font-semibold hover:bg-slate-50 transition-colors">
                      <span class="material-symbols-outlined text-xs">visibility</span> Xem
                    </a>
                  </c:when>
                  <c:otherwise>
                    <%-- Nháp: nút chính là Tính lương --%>
                    <form method="post" action="${pageContext.request.contextPath}/manager/luong">
                      <input type="hidden" name="action" value="tinh-luong">
                      <input type="hidden" name="kyLuongId" value="${ky.kyLuongId}">
                      <button class="inline-flex items-center gap-1 px-4 py-1.5 rounded-lg bg-violet-600 hover:bg-violet-700 text-white text-xs font-bold transition-colors shadow-sm">
                        <span class="material-symbols-outlined text-xs">calculate</span> Tính lương
                      </button>
                    </form>
                  </c:otherwise>
                </c:choose>
              </div>
            </td>

          </tr>
        </c:forEach>

        <c:if test="${empty dsKy}">
          <tr>
            <td colspan="7" class="px-5 py-16 text-center">
              <div class="flex flex-col items-center gap-3 text-slate-400">
                <span class="material-symbols-outlined text-5xl text-slate-200">payments</span>
                <div class="font-semibold text-slate-500">Chưa có kỳ lương nào</div>
                <div class="text-sm">Bấm <strong class="text-violet-600">Tạo kỳ lương mới</strong> ở trên để bắt đầu.</div>
              </div>
            </td>
          </tr>
        </c:if>
        </tbody>
      </table>
    </div>
  </section>

</main>

<script>
  function toggleCreateForm() {
    const panel = document.getElementById('createFormPanel');
    const icon  = document.getElementById('btnIcon');
    const label = document.getElementById('btnLabel');
    const open  = panel.classList.toggle('hidden');
    icon.textContent  = open ? 'add' : 'close';
    label.textContent = open ? 'Tạo kỳ lương mới' : 'Đóng';
    if (!open) initDatePickers();
  }

  const fpVi = {
    weekdays: {
      shorthand: ['CN','T2','T3','T4','T5','T6','T7'],
      longhand:  ['Chủ nhật','Thứ hai','Thứ ba','Thứ tư','Thứ năm','Thứ sáu','Thứ bảy']
    },
    months: {
      shorthand: ['Th1','Th2','Th3','Th4','Th5','Th6','Th7','Th8','Th9','Th10','Th11','Th12'],
      longhand:  ['Tháng 1','Tháng 2','Tháng 3','Tháng 4','Tháng 5','Tháng 6',
                  'Tháng 7','Tháng 8','Tháng 9','Tháng 10','Tháng 11','Tháng 12']
    },
    firstDayOfWeek: 1,
    rangeSeparator: ' đến ',
    weekAbbreviation: 'Tuần',
    scrollTitle: 'Cuộn để thay đổi',
    toggleTitle: 'Bấm để chuyển',
    amPM: ['SA','CH'],
    yearAriaLabel: 'Năm',
    time_24hr: true
  };

  function initDatePickers() {
    document.querySelectorAll('#createFormPanel input[type="date"]').forEach(function(el) {
      if (el._flatpickr) return;
      flatpickr(el, {
        locale: fpVi,
        dateFormat: 'Y-m-d',
        altInput: true,
        altFormat: 'd/m/Y',
        allowInput: true
      });
    });
  }
</script>
</body>
</html>
