<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<<<<<<< HEAD
<%
    String ctx = request.getContextPath();
    String formAction = (String) request.getAttribute("formAction");
    boolean isForm = formAction != null;
%>
<!DOCTYPE html>
<html lang="vi">
<head>
<title>Khuyến mãi — Manager</title>
<jsp:include page="/manager/common/manager_head.jsp" />
<style>
body { background-color: #f8fafc !important; }
.badge { display:inline-flex;align-items:center;padding:3px 10px;border-radius:8px;font-size:11px;font-weight:600; }
.badge-green { background:#dcfce7;color:#15803d; }
.badge-amber { background:#fef3c7;color:#b45309; }
.badge-gray  { background:#f4f4f5;color:#52525b; }
.tbl-row { transition:background .12s; }
.tbl-row:hover { background:#faf5ff; }
.form-field label { display:block;font-size:13px;font-weight:600;color:#374151;margin-bottom:4px; }
.form-field input, .form-field select, .form-field textarea {
    width:100%;border:1px solid #e5e7eb;border-radius:8px;padding:8px 12px;
    font-size:14px;color:#111827;outline:none;transition:border-color .15s;
}
.form-field input:focus, .form-field select:focus, .form-field textarea:focus {
    border-color:#2563eb;box-shadow:0 0 0 3px rgba(37,99,235,.1);
}
=======
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
<title>${pageTitle}</title>
<jsp:include page="/manager/common/manager_head.jsp" />
<style>
  body { background-color: #f8fafc !important; }
  .km-stat { background:#fff; border:1px solid #e2e8f0; border-radius:14px; padding:16px 18px; box-shadow:0 1px 2px rgba(0,0,0,.03); }
  .km-stat .num { font-size:22px; font-weight:800; color:#0f172a; }
  .km-stat .lbl { font-size:12px; color:#64748b; font-weight:600; margin-top:2px; }
  .badge { display:inline-flex; align-items:center; gap:4px; font-size:11px; font-weight:700; padding:3px 9px; border-radius:999px; white-space:nowrap; }
  .badge-green { background:#dcfce7; color:#166534; }
  .badge-blue { background:#dbeafe; color:#1e40af; }
  .badge-amber { background:#fef3c7; color:#92400e; }
  .badge-zinc { background:#f1f5f9; color:#475569; }
  .badge-rose { background:#fee2e2; color:#991b1b; }
  .filter-chip { padding:6px 14px; border-radius:999px; font-size:12.5px; font-weight:700; color:#475569; background:#fff; border:1px solid #e2e8f0; white-space:nowrap; cursor:pointer; }
  .filter-chip.active { background:#0f172a; color:#fff; border-color:#0f172a; }
  .km-table { width:100%; border-collapse:separate; border-spacing:0; }
  .km-table th { text-align:left; font-size:11px; font-weight:800; color:#64748b; text-transform:uppercase; letter-spacing:.04em; padding:10px 12px; border-bottom:1px solid #e2e8f0; white-space:nowrap; }
  .km-table td { padding:12px; border-bottom:1px solid #f1f5f9; font-size:13px; color:#1e293b; vertical-align:top; }
  .km-table tr:hover td { background:#f8fafc; }
  .km-card { background:#fff; border:1px solid #e2e8f0; border-radius:14px; padding:14px 16px; box-shadow:0 1px 2px rgba(0,0,0,.03); }
  .drawer-overlay { position:fixed; inset:0; background:rgba(15,23,42,.45); z-index:60; display:none; }
  .drawer-panel { position:fixed; top:0; right:0; height:100vh; width:100%; max-width:560px; background:#fff; z-index:61;
    box-shadow:-10px 0 30px rgba(0,0,0,.15); transform:translateX(100%); transition:transform .25s ease; overflow-y:auto; }
  .drawer-panel.open, .drawer-overlay.open { display:block; }
  .drawer-panel.open { transform:translateX(0); }
  .field label { font-size:12px; font-weight:700; color:#475569; margin-bottom:4px; display:block; }
  .field .hint { font-size:11px; color:#94a3b8; margin-top:3px; }
  .field .err { font-size:11.5px; color:#b91c1c; font-weight:700; margin-top:4px; display:none; }
  .field input, .field select, .field textarea {
    width:100%; border:1px solid #e2e8f0; border-radius:10px; padding:8px 10px; font-size:13.5px; outline:none;
  }
  .field input:focus, .field select:focus, .field textarea:focus { border-color:#0f766e; }
  .discount-mode-btn { flex:1; padding:9px 10px; border-radius:10px; border:1.5px solid #e2e8f0; font-size:13px; font-weight:700; color:#475569; cursor:pointer; text-align:center; background:#fff; }
  .discount-mode-btn.active { border-color:#0f766e; background:#f0fdfa; color:#0f766e; }
  @media (max-width: 1024px) { .km-table-wrap { display:none; } }
  @media (min-width: 1025px) { .km-card-list { display:none; } }
>>>>>>> fix/teacher-review-remediation
</style>
</head>
<body class="text-zinc-900 min-h-screen">

<jsp:include page="/manager/common/sidebar.jsp" />

<<<<<<< HEAD
<c:set var="headerTitle"    value="Khuyến mãi" scope="page" />
<c:set var="headerSubtitle" value="Quản lý mã giảm giá của cơ sở" scope="page" />
<c:set var="headerIcon"     value="local_offer" scope="page" />
=======
<c:set var="headerTitle" value="Quản lý mã khuyến mãi" scope="page" />
<c:set var="headerSubtitle" value="Chi nhánh CS${sessionScope.user.coSoId}" scope="page" />
<c:set var="headerIcon" value="sell" scope="page" />
>>>>>>> fix/teacher-review-remediation
<jsp:include page="/manager/common/header.jsp" />

<main class="lg:ml-[248px] mt-[64px] p-4 lg:p-6 flex flex-col gap-5">

<<<<<<< HEAD
  <%-- Flash --%>
  <c:if test="${not empty sessionScope.flashSuccess}">
    <div class="rounded-xl px-4 py-3 bg-green-50 border border-green-200 text-green-800 text-sm font-medium">${sessionScope.flashSuccess}</div>
    <% session.removeAttribute("flashSuccess"); %>
  </c:if>
  <c:if test="${not empty sessionScope.flashError}">
    <div class="rounded-xl px-4 py-3 bg-red-50 border border-red-200 text-red-800 text-sm font-medium">${sessionScope.flashError}</div>
    <% session.removeAttribute("flashError"); %>
  </c:if>
  <c:if test="${not empty errors}">
    <div class="rounded-xl px-4 py-3 bg-red-50 border border-red-200 text-red-800 text-sm">
      <ul class="list-disc pl-4 space-y-1">
        <c:forEach var="err" items="${errors}"><li><c:out value="${err}"/></li></c:forEach>
      </ul>
    </div>
  </c:if>

  <%-- ===== FORM (create / update) ===== --%>
  <% if (isForm) { %>
  <div class="bg-white border border-zinc-200 rounded-2xl p-6">
    <div class="flex items-center justify-between mb-6">
      <h2 class="text-lg font-bold">${formAction eq 'create' ? 'Tạo mã khuyến mãi' : 'Cập nhật mã khuyến mãi'}</h2>
      <a href="<%= ctx %>/manager/khuyen-mai" class="text-sm text-zinc-500 hover:text-zinc-900">← Quay lại</a>
    </div>

    <form method="post" action="<%= ctx %>/manager/khuyen-mai?action=${formAction}" class="grid grid-cols-1 md:grid-cols-2 gap-5">
      <c:if test="${not empty km.khuyenMaiID and km.khuyenMaiID > 0}">
        <input type="hidden" name="khuyenMaiId" value="${km.khuyenMaiID}">
      </c:if>

      <div class="form-field">
        <label>Mã code <span class="text-red-500">*</span></label>
        <input type="text" name="maCode" value="<c:out value='${km.maCode}'/>"
               placeholder="VD: SUMMER2025" maxlength="50" required
               style="text-transform:uppercase">
        <p class="text-xs text-zinc-400 mt-1">Tự động chuyển chữ hoa. Tối đa 50 ký tự.</p>
      </div>

      <div class="form-field">
        <label>Mô tả</label>
        <input type="text" name="moTa" value="<c:out value='${km.moTa}'/>" maxlength="255" placeholder="Giảm 20% dịp hè">
      </div>

      <div class="form-field">
        <label>Loại giảm <span class="text-red-500">*</span></label>
        <select name="loaiGiam" required>
          <option value="">-- Chọn loại --</option>
          <option value="PhanTram" ${km.loaiGiam eq 'PhanTram' ? 'selected' : ''}>Phần trăm (%)</option>
          <option value="SoTien"   ${km.loaiGiam eq 'SoTien'   ? 'selected' : ''}>Số tiền (VND)</option>
        </select>
      </div>

      <div class="form-field">
        <label>Giá trị giảm <span class="text-red-500">*</span></label>
        <input type="number" name="giaTriGiam" value="${km.giaTriGiam}"
               step="0.01" min="0" placeholder="20" required>
      </div>

      <div class="form-field">
        <label>Ngày bắt đầu <span class="text-red-500">*</span></label>
        <input type="date" name="ngayBatDau"
               value="${km.ngayBatDau}" required>
      </div>

      <div class="form-field">
        <label>Ngày kết thúc <span class="text-red-500">*</span></label>
        <input type="date" name="ngayKetThuc"
               value="${km.ngayKetThuc}" required>
      </div>

      <div class="form-field">
        <label>Số lần tối đa</label>
        <input type="number" name="soLanToiDa" value="${km.soLanToiDa}"
               min="0" placeholder="Để trống = không giới hạn">
      </div>

      <c:if test="${formAction eq 'update'}">
      <div class="form-field">
        <label>Trạng thái</label>
        <select name="trangThai">
          <option value="Hoạt động" ${km.trangThai eq 'Hoạt động' ? 'selected' : ''}>Hoạt động</option>
          <option value="Ngừng hoạt động" ${km.trangThai eq 'Ngừng hoạt động' ? 'selected' : ''}>Ngừng hoạt động</option>
        </select>
      </div>
      </c:if>

      <div class="md:col-span-2 flex gap-3 pt-2">
        <button type="submit" class="px-5 py-2.5 rounded-xl bg-blue-600 text-white text-sm font-semibold hover:bg-blue-700 transition">
          ${formAction eq 'create' ? 'Tạo mới' : 'Lưu thay đổi'}
        </button>
        <a href="<%= ctx %>/manager/khuyen-mai" class="px-5 py-2.5 rounded-xl border border-zinc-200 text-sm font-medium text-zinc-600 hover:bg-zinc-50 transition">Hủy</a>
      </div>
    </form>
  </div>
  <% } else { %>

  <%-- ===== LIST ===== --%>
  <div class="flex items-center justify-between">
    <div>
      <h1 class="text-xl font-bold">Khuyến mãi</h1>
      <p class="text-sm text-zinc-500 mt-0.5">Tổng ${totalCount} mã</p>
    </div>
    <a href="<%= ctx %>/manager/khuyen-mai?action=form"
       class="px-4 py-2 rounded-xl bg-blue-600 text-white text-sm font-semibold hover:bg-blue-700 transition">
      + Tạo mã mới
    </a>
  </div>

  <div class="bg-white border border-zinc-200 rounded-2xl overflow-hidden">
    <c:choose>
      <c:when test="${empty khuyenMaiList}">
        <div class="text-center py-16 text-zinc-400">
          <span class="material-symbols-outlined text-4xl">local_offer</span>
          <p class="mt-2 text-sm">Chưa có mã khuyến mãi nào.</p>
        </div>
      </c:when>
      <c:otherwise>
        <div class="overflow-x-auto">
          <table class="w-full text-sm">
            <thead class="bg-zinc-50 border-b border-zinc-100 text-xs font-semibold text-zinc-500 uppercase tracking-wide">
              <tr>
                <th class="px-5 py-3 text-left">Mã code</th>
                <th class="px-5 py-3 text-left">Mô tả</th>
                <th class="px-5 py-3 text-left">Loại giảm</th>
                <th class="px-5 py-3 text-right">Giá trị</th>
                <th class="px-5 py-3 text-left">Hiệu lực</th>
                <th class="px-5 py-3 text-right">Đã dùng</th>
                <th class="px-5 py-3 text-left">Trạng thái</th>
                <th class="px-5 py-3 text-center">Thao tác</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-zinc-100">
              <c:forEach var="km" items="${khuyenMaiList}">
                <tr class="tbl-row">
                  <td class="px-5 py-3 font-mono font-semibold text-blue-700"><c:out value="${km.maCode}"/></td>
                  <td class="px-5 py-3 text-zinc-600 max-w-[180px] truncate"><c:out value="${km.moTa != null ? km.moTa : '—'}"/></td>
                  <td class="px-5 py-3">
                    <c:choose>
                      <c:when test="${km.loaiGiam eq 'PhanTram'}">
                        <span class="badge badge-blue">%</span>
                      </c:when>
                      <c:otherwise>
                        <span class="badge badge-amber">VND</span>
                      </c:otherwise>
                    </c:choose>
                  </td>
                  <td class="px-5 py-3 text-right font-medium">
                    <c:choose>
                      <c:when test="${km.loaiGiam eq 'PhanTram'}"><fmt:formatNumber value="${km.giaTriGiam}" maxFractionDigits="1"/>%</c:when>
                      <c:otherwise><fmt:formatNumber value="${km.giaTriGiam}" type="number" maxFractionDigits="0"/> đ</c:otherwise>
                    </c:choose>
                  </td>
                  <td class="px-5 py-3 text-zinc-500 whitespace-nowrap">${km.ngayBatDau} → ${km.ngayKetThuc}</td>
                  <td class="px-5 py-3 text-right">
                    ${km.soLanDaDung}<c:if test="${km.soLanToiDa != null}">/${km.soLanToiDa}</c:if>
                  </td>
                  <td class="px-5 py-3">
                    <c:choose>
                      <c:when test="${km.trangThai eq 'Hoạt động'}"><span class="badge badge-green">Hoạt động</span></c:when>
                      <c:otherwise><span class="badge badge-gray"><c:out value="${km.trangThai}"/></span></c:otherwise>
                    </c:choose>
                  </td>
                  <td class="px-5 py-3 text-center">
                    <div class="flex items-center justify-center gap-2">
                      <a href="<%= ctx %>/manager/khuyen-mai?action=form&id=${km.khuyenMaiID}"
                         class="text-xs text-blue-600 font-medium hover:underline">Sửa</a>
                      <c:if test="${km.soLanDaDung == 0}">
                        <form method="post" action="<%= ctx %>/manager/khuyen-mai?action=delete"
                              onsubmit="return confirm('Xóa mã ${km.maCode}?')" style="display:inline">
                          <input type="hidden" name="khuyenMaiId" value="${km.khuyenMaiID}">
                          <button type="submit" class="text-xs text-red-500 font-medium hover:underline">Xóa</button>
                        </form>
                      </c:if>
                    </div>
                  </td>
                </tr>
              </c:forEach>
            </tbody>
          </table>
        </div>

        <%-- Pagination --%>
        <c:if test="${currentPage > 1 or hasMore}">
          <div class="flex gap-2 p-4 justify-end border-t border-zinc-100">
            <c:if test="${currentPage > 1}">
              <a href="<%= ctx %>/manager/khuyen-mai?page=${currentPage - 1}"
                 class="px-3 py-1.5 text-xs rounded-lg border border-zinc-200 hover:bg-zinc-50">← Trước</a>
            </c:if>
            <span class="px-3 py-1.5 text-xs text-zinc-500">Trang ${currentPage}</span>
            <c:if test="${hasMore}">
              <a href="<%= ctx %>/manager/khuyen-mai?page=${currentPage + 1}"
                 class="px-3 py-1.5 text-xs rounded-lg border border-zinc-200 hover:bg-zinc-50">Tiếp →</a>
            </c:if>
          </div>
        </c:if>
      </c:otherwise>
    </c:choose>
  </div>
  <% } %>

</main>
=======
  <div id="kmToast" aria-live="polite" style="display:none;" class="fixed top-20 right-6 z-[80] max-w-sm"></div>
  <c:if test="${not empty successMsg}">
    <div class="flex items-center gap-3 p-4 bg-emerald-50 border border-emerald-100 text-emerald-800 rounded-2xl shadow-sm" data-flash="success" data-flash-msg="${fn:escapeXml(successMsg)}">
      <span class="material-symbols-outlined text-emerald-600 text-[20px]">check_circle</span>
      <p class="text-sm font-semibold">${successMsg}</p>
    </div>
  </c:if>
  <c:if test="${not empty errorMsg}">
    <div class="flex items-center gap-3 p-4 bg-rose-50 border border-rose-100 text-rose-800 rounded-2xl shadow-sm" data-flash="error" data-flash-msg="${fn:escapeXml(errorMsg)}">
      <span class="material-symbols-outlined text-rose-600 text-[20px]">error</span>
      <p class="text-sm font-semibold">${errorMsg}</p>
    </div>
  </c:if>

  <section class="flex items-center justify-between gap-4 flex-wrap">
    <div>
      <h1 class="text-2xl font-extrabold text-slate-900 tracking-tight">Quản lý mã khuyến mãi</h1>
      <p class="text-[13.5px] text-slate-500 mt-1">Tạo và theo dõi các chương trình ưu đãi tại cơ sở của bạn.</p>
    </div>
    <button onclick="openKmDrawer()" class="px-4 py-2.5 rounded-xl bg-teal-700 text-white text-sm font-bold hover:bg-teal-800 flex items-center gap-2">
      <span class="material-symbols-outlined text-[18px]">add</span>Tạo mã khuyến mãi
    </button>
  </section>

  <section class="grid grid-cols-2 lg:grid-cols-4 gap-3">
    <div class="km-stat"><div class="num">${countActive}</div><div class="lbl">Đang hoạt động</div></div>
    <div class="km-stat"><div class="num">${countUpcoming}</div><div class="lbl">Sắp diễn ra</div></div>
    <div class="km-stat"><div class="num">${countExpired}</div><div class="lbl">Đã hết hạn</div></div>
    <div class="km-stat"><div class="num">${totalUsage}</div><div class="lbl">Tổng lượt sử dụng</div></div>
  </section>

  <section class="flex flex-col gap-3">
    <form method="get" action="${pageContext.request.contextPath}/manager/khuyen-mai" class="flex items-center gap-2 flex-wrap">
      <div class="relative flex-1 min-w-[220px]">
        <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 text-[18px]">search</span>
        <input type="text" name="q" value="${fn:escapeXml(keyword)}" placeholder="Tìm theo mã hoặc tên chương trình..."
               class="w-full pl-9 pr-3 py-2.5 rounded-xl border border-slate-200 text-sm focus:outline-none focus:border-teal-600" />
      </div>
      <input type="hidden" name="status" id="statusHiddenInput" value="${statusFilter}" />
      <button type="submit" class="px-4 py-2.5 rounded-xl bg-slate-900 text-white text-sm font-bold">Tìm</button>
    </form>
    <div class="flex items-center gap-2 overflow-x-auto pb-1">
      <a href="?status=ALL&q=${fn:escapeXml(keyword)}" class="filter-chip ${statusFilter == 'ALL' ? 'active' : ''}">Tất cả</a>
      <a href="?status=ACTIVE&q=${fn:escapeXml(keyword)}" class="filter-chip ${statusFilter == 'ACTIVE' ? 'active' : ''}">Đang hoạt động</a>
      <a href="?status=UPCOMING&q=${fn:escapeXml(keyword)}" class="filter-chip ${statusFilter == 'UPCOMING' ? 'active' : ''}">Sắp diễn ra</a>
      <a href="?status=EXPIRED&q=${fn:escapeXml(keyword)}" class="filter-chip ${statusFilter == 'EXPIRED' ? 'active' : ''}">Đã hết hạn</a>
      <a href="?status=LOCKED&q=${fn:escapeXml(keyword)}" class="filter-chip ${statusFilter == 'LOCKED' ? 'active' : ''}">Tạm khóa</a>
      <a href="?status=EXHAUSTED&q=${fn:escapeXml(keyword)}" class="filter-chip ${statusFilter == 'EXHAUSTED' ? 'active' : ''}">Hết lượt</a>
    </div>
  </section>

  <c:choose>
    <c:when test="${empty promotions}">
      <div class="km-card text-center py-10 text-slate-400 text-sm">Chưa có mã khuyến mãi nào phù hợp.</div>
    </c:when>
    <c:otherwise>
      <%-- Desktop table --%>
      <section class="km-table-wrap bg-white border border-slate-200 rounded-2xl overflow-x-auto">
        <table class="km-table">
          <thead>
            <tr>
              <th>Mã</th><th>Tên / Mô tả</th><th>Loại giảm</th><th>Giá trị</th><th>Đơn tối thiểu</th>
              <th>Giảm tối đa</th><th>Bắt đầu</th><th>Kết thúc</th><th>Lượt dùng</th><th>Trạng thái</th><th>Thao tác</th>
            </tr>
          </thead>
          <tbody>
            <c:forEach var="km" items="${promotions}">
              <tr>
                <td class="font-extrabold text-slate-900">${fn:escapeXml(km.maCode)}</td>
                <td class="max-w-[220px]"><div class="truncate">${fn:escapeXml(km.moTa)}</div></td>
                <td>${km.loaiGiam == 'PERCENT' ? 'Phần trăm' : 'Số tiền cố định'}</td>
                <td>
                  <c:choose>
                    <c:when test="${km.loaiGiam == 'PERCENT'}"><fmt:formatNumber value="${km.giaTriGiam}" pattern="#,##0.#"/>%</c:when>
                    <c:otherwise><fmt:formatNumber value="${km.giaTriGiam}" pattern="#,##0"/>đ</c:otherwise>
                  </c:choose>
                </td>
                <td><c:choose><c:when test="${not empty km.giaTriToiThieu and km.giaTriToiThieu gt 0}"><fmt:formatNumber value="${km.giaTriToiThieu}" pattern="#,##0"/>đ</c:when><c:otherwise>—</c:otherwise></c:choose></td>
                <td><c:choose><c:when test="${not empty km.giamToiDa and km.giamToiDa gt 0}"><fmt:formatNumber value="${km.giamToiDa}" pattern="#,##0"/>đ</c:when><c:otherwise>—</c:otherwise></c:choose></td>
                <td>${fn:substring(km.ngayBatDau, 8, 10)}/${fn:substring(km.ngayBatDau, 5, 7)}/${fn:substring(km.ngayBatDau, 0, 4)}</td>
                <td>${fn:substring(km.ngayKetThuc, 8, 10)}/${fn:substring(km.ngayKetThuc, 5, 7)}/${fn:substring(km.ngayKetThuc, 0, 4)}</td>
                <td>${km.soLanDaDung} / <c:choose><c:when test="${not empty km.soLanToiDa}">${km.soLanToiDa}</c:when><c:otherwise>&infin;</c:otherwise></c:choose></td>
                <td>
                  <c:set var="st" value="${kmDisplayStatus[km.khuyenMaiID]}" />
                  <c:choose>
                    <c:when test="${st == 'Đang hoạt động'}"><span class="badge badge-green"><span class="material-symbols-outlined" style="font-size:12px;">check_circle</span>Đang hoạt động</span></c:when>
                    <c:when test="${st == 'Sắp diễn ra'}"><span class="badge badge-blue"><span class="material-symbols-outlined" style="font-size:12px;">schedule</span>Sắp diễn ra</span></c:when>
                    <c:when test="${st == 'Đã hết hạn'}"><span class="badge badge-zinc"><span class="material-symbols-outlined" style="font-size:12px;">event_busy</span>Đã hết hạn</span></c:when>
                    <c:when test="${st == 'Hết lượt'}"><span class="badge badge-amber"><span class="material-symbols-outlined" style="font-size:12px;">block</span>Hết lượt</span></c:when>
                    <c:otherwise><span class="badge badge-rose"><span class="material-symbols-outlined" style="font-size:12px;">lock</span>Tạm khóa</span></c:otherwise>
                  </c:choose>
                </td>
                <td>
                  <div class="flex items-center gap-1.5">
                    <button type="button" title="Xem / sửa" onclick="openKmDrawer('${km.khuyenMaiID}')" class="w-8 h-8 rounded-lg hover:bg-slate-100 flex items-center justify-center" aria-label="Sửa mã ${fn:escapeXml(km.maCode)}">
                      <span class="material-symbols-outlined text-slate-500 text-[18px]">edit</span>
                    </button>
                    <form method="post" action="${pageContext.request.contextPath}/manager/khuyen-mai" onsubmit="return disableSubmit(this)">
                      <input type="hidden" name="action" value="toggle"/>
                      <input type="hidden" name="khuyenMaiId" value="${km.khuyenMaiID}"/>
                      <input type="hidden" name="value" value="${km.trangThai == 'Hoạt động' ? 0 : 1}"/>
                      <button type="submit" title="${km.trangThai == 'Hoạt động' ? 'Tạm khóa' : 'Bật lại'}" class="w-8 h-8 rounded-lg hover:bg-slate-100 flex items-center justify-center" aria-label="${km.trangThai == 'Hoạt động' ? 'Tạm khóa mã' : 'Bật lại mã'} ${fn:escapeXml(km.maCode)}">
                        <span class="material-symbols-outlined text-slate-500 text-[18px]">${km.trangThai == 'Hoạt động' ? 'toggle_on' : 'toggle_off'}</span>
                      </button>
                    </form>
                  </div>
                </td>
              </tr>
            </c:forEach>
          </tbody>
        </table>
      </section>

      <%-- Mobile card list --%>
      <section class="km-card-list flex flex-col gap-3">
        <c:forEach var="km" items="${promotions}">
          <div class="km-card">
            <div class="flex items-center justify-between gap-2">
              <p class="font-extrabold text-slate-900">${fn:escapeXml(km.maCode)}</p>
              <c:set var="st" value="${kmDisplayStatus[km.khuyenMaiID]}" />
              <c:choose>
                <c:when test="${st == 'Đang hoạt động'}"><span class="badge badge-green">Đang hoạt động</span></c:when>
                <c:when test="${st == 'Sắp diễn ra'}"><span class="badge badge-blue">Sắp diễn ra</span></c:when>
                <c:when test="${st == 'Đã hết hạn'}"><span class="badge badge-zinc">Đã hết hạn</span></c:when>
                <c:when test="${st == 'Hết lượt'}"><span class="badge badge-amber">Hết lượt</span></c:when>
                <c:otherwise><span class="badge badge-rose">Tạm khóa</span></c:otherwise>
              </c:choose>
            </div>
            <p class="text-[12.5px] text-slate-500 mt-1 truncate">${fn:escapeXml(km.moTa)}</p>
            <p class="text-[12.5px] text-slate-600 mt-2">
              <c:choose>
                <c:when test="${km.loaiGiam == 'PERCENT'}">Giảm <fmt:formatNumber value="${km.giaTriGiam}" pattern="#,##0.#"/>%</c:when>
                <c:otherwise>Giảm <fmt:formatNumber value="${km.giaTriGiam}" pattern="#,##0"/>đ</c:otherwise>
              </c:choose>
              · Dùng ${km.soLanDaDung}/<c:choose><c:when test="${not empty km.soLanToiDa}">${km.soLanToiDa}</c:when><c:otherwise>&infin;</c:otherwise></c:choose>
            </p>
            <p class="text-[12px] text-slate-400 mt-1">
              ${fn:substring(km.ngayBatDau, 8, 10)}/${fn:substring(km.ngayBatDau, 5, 7)}/${fn:substring(km.ngayBatDau, 0, 4)}
              – ${fn:substring(km.ngayKetThuc, 8, 10)}/${fn:substring(km.ngayKetThuc, 5, 7)}/${fn:substring(km.ngayKetThuc, 0, 4)}
            </p>
            <div class="flex items-center gap-2 mt-3">
              <button type="button" onclick="openKmDrawer('${km.khuyenMaiID}')" class="flex-1 py-2 rounded-lg border border-slate-200 text-sm font-bold text-slate-700">Sửa</button>
              <form method="post" action="${pageContext.request.contextPath}/manager/khuyen-mai" onsubmit="return disableSubmit(this)" class="flex-1">
                <input type="hidden" name="action" value="toggle"/>
                <input type="hidden" name="khuyenMaiId" value="${km.khuyenMaiID}"/>
                <input type="hidden" name="value" value="${km.trangThai == 'Hoạt động' ? 0 : 1}"/>
                <button type="submit" class="w-full py-2 rounded-lg border border-slate-200 text-sm font-bold text-slate-700">${km.trangThai == 'Hoạt động' ? 'Tạm khóa' : 'Bật lại'}</button>
              </form>
            </div>
          </div>
        </c:forEach>
      </section>
    </c:otherwise>
  </c:choose>
</main>

<%-- ═══ DRAWER: TẠO / SỬA MÃ KHUYẾN MÃI ═══ --%>
<div class="drawer-overlay" id="kmOverlay" onclick="closeKmDrawer()"></div>
<div class="drawer-panel" id="kmDrawer" role="dialog" aria-modal="true" aria-labelledby="kmDrawerTitle">
  <form method="post" action="${pageContext.request.contextPath}/manager/khuyen-mai" class="flex flex-col h-full" id="kmForm" onsubmit="return validateKmForm(this)">
    <input type="hidden" name="action" id="kmFormAction" value="create"/>
    <input type="hidden" name="khuyenMaiId" id="kmIdInput" value=""/>
    <div class="flex items-center justify-between px-5 py-4 border-b border-slate-100">
      <h3 class="font-extrabold text-lg" id="kmDrawerTitle">Tạo mã khuyến mãi</h3>
      <button type="button" onclick="closeKmDrawer()" class="w-8 h-8 rounded-lg hover:bg-slate-100 flex items-center justify-center" aria-label="Đóng">
        <span class="material-symbols-outlined">close</span>
      </button>
    </div>
    <div class="flex-1 overflow-y-auto px-5 py-4 flex flex-col gap-3.5">

      <p class="text-xs font-bold text-teal-700 uppercase tracking-wide">Thông tin chung</p>
      <div class="field">
        <label for="f_maCode">Mã khuyến mãi *</label>
        <input type="text" name="maCode" id="f_maCode" maxlength="50" required placeholder="Ví dụ: VSPORT20" oninput="this.value = this.value.toUpperCase().trim();"/>
        <p class="hint">Chỉ gồm chữ in hoa, số, gạch nối (ví dụ: VSPORT20). Không thể trùng mã đã có.</p>
        <p class="err" id="err_maCode">Vui lòng nhập mã khuyến mãi hợp lệ.</p>
      </div>
      <div class="field">
        <label for="f_moTa">Tên chương trình / Mô tả</label>
        <textarea name="moTa" id="f_moTa" rows="2" maxlength="255"></textarea>
      </div>

      <p class="text-xs font-bold text-teal-700 uppercase tracking-wide mt-1">Hình thức giảm</p>
      <div class="flex gap-2">
        <button type="button" class="discount-mode-btn active" id="modeBtnPercent" onclick="setDiscountMode('PERCENT')">Giảm theo phần trăm</button>
        <button type="button" class="discount-mode-btn" id="modeBtnFixed" onclick="setDiscountMode('FIXED')">Giảm số tiền cố định</button>
      </div>
      <input type="hidden" name="loaiGiam" id="f_loaiGiam" value="PERCENT"/>

      <div id="percentFields" class="grid grid-cols-1 sm:grid-cols-2 gap-3">
        <div class="field">
          <label for="f_giaTriGiamPercent">Phần trăm giảm (%) *</label>
          <input type="number" min="0.01" max="100" step="0.1" id="f_giaTriGiamPercent"/>
          <p class="err" id="err_giaTriGiamPercent">Phần trăm giảm phải lớn hơn 0 và không vượt quá 100.</p>
        </div>
        <div class="field">
          <label for="f_giamToiDaPercent">Mức giảm tối đa (đ)</label>
          <input type="number" min="0" step="1000" id="f_giamToiDaPercent"/>
        </div>
      </div>
      <div id="fixedFields" class="field" style="display:none;">
        <label for="f_giaTriGiamFixed">Số tiền giảm (đ) *</label>
        <input type="number" min="0" step="1000" id="f_giaTriGiamFixed"/>
        <p class="err" id="err_giaTriGiamFixed">Vui lòng nhập số tiền giảm hợp lệ.</p>
      </div>
      <input type="hidden" name="giaTriGiam" id="f_giaTriGiam"/>
      <input type="hidden" name="giamToiDa" id="f_giamToiDa"/>

      <p class="text-xs font-bold text-teal-700 uppercase tracking-wide mt-1">Điều kiện áp dụng</p>
      <div class="field">
        <label for="f_giaTriToiThieu">Giá trị đơn tối thiểu (đ)</label>
        <input type="number" min="0" step="1000" name="giaTriToiThieu" id="f_giaTriToiThieu"/>
        <p class="err" id="err_giaTriToiThieu">Giá trị đơn tối thiểu không được âm.</p>
      </div>
      <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
        <div class="field">
          <label for="f_ngayBatDau">Ngày bắt đầu *</label>
          <input type="date" name="ngayBatDau" id="f_ngayBatDau" required/>
        </div>
        <div class="field">
          <label for="f_ngayKetThuc">Ngày kết thúc *</label>
          <input type="date" name="ngayKetThuc" id="f_ngayKetThuc" required/>
          <p class="err" id="err_ngayKetThuc">Ngày kết thúc phải sau ngày bắt đầu.</p>
        </div>
      </div>
      <div class="field">
        <label for="f_soLanToiDa">Tổng lượt sử dụng (để trống nếu không giới hạn)</label>
        <input type="number" min="1" step="1" name="soLanToiDa" id="f_soLanToiDa"/>
        <p class="err" id="err_soLanToiDa">Tổng lượt sử dụng phải lớn hơn 0.</p>
      </div>
      <label class="flex items-center gap-2 text-sm font-semibold text-slate-700">
        <input type="checkbox" name="trangThaiHoatDong" id="f_trangThaiHoatDong" checked/> Đang hoạt động
      </label>
    </div>
    <div class="px-5 py-4 border-t border-slate-100 flex gap-2">
      <button type="submit" id="kmSubmitBtn" class="flex-1 py-2.5 rounded-xl bg-teal-700 text-white text-sm font-bold hover:bg-teal-800">Lưu mã khuyến mãi</button>
    </div>
  </form>
</div>

<script>
var KM_DATA = {};
<c:forEach var="km" items="${promotions}">
KM_DATA['${km.khuyenMaiID}'] = {
  maCode: '${fn:escapeXml(km.maCode)}',
  moTa: '${fn:escapeXml(km.moTa)}',
  loaiGiam: '${km.loaiGiam}',
  giaTriGiam: ${km.giaTriGiam},
  giaTriToiThieu: ${empty km.giaTriToiThieu ? 0 : km.giaTriToiThieu},
  giamToiDa: ${empty km.giamToiDa ? 0 : km.giamToiDa},
  ngayBatDau: '${km.ngayBatDau}',
  ngayKetThuc: '${km.ngayKetThuc}',
  soLanToiDa: ${empty km.soLanToiDa ? 'null' : km.soLanToiDa},
  trangThaiHoatDong: ${km.trangThai == 'Hoạt động'}
};
</c:forEach>

function setDiscountMode(mode) {
  document.getElementById('f_loaiGiam').value = mode;
  document.getElementById('modeBtnPercent').classList.toggle('active', mode === 'PERCENT');
  document.getElementById('modeBtnFixed').classList.toggle('active', mode === 'FIXED');
  document.getElementById('percentFields').style.display = mode === 'PERCENT' ? 'grid' : 'none';
  document.getElementById('fixedFields').style.display = mode === 'FIXED' ? 'block' : 'none';
}

function clearKmErrors() {
  document.querySelectorAll('#kmForm .err').forEach(function (e) { e.style.display = 'none'; });
}

function showKmError(fieldId, focusEl) {
  var err = document.getElementById('err_' + fieldId);
  if (err) err.style.display = 'block';
  if (focusEl) { focusEl.focus(); focusEl.scrollIntoView({ block: 'center', behavior: 'smooth' }); }
}

function validateKmForm(form) {
  clearKmErrors();
  var mode = document.getElementById('f_loaiGiam').value;
  var maCode = document.getElementById('f_maCode');
  if (!maCode.value || !/^[A-Z0-9_-]{3,50}$/.test(maCode.value)) {
    showKmError('maCode', maCode);
    return false;
  }

  var giaTriGiamVal, giamToiDaVal = '';
  if (mode === 'PERCENT') {
    var pctInput = document.getElementById('f_giaTriGiamPercent');
    var pct = parseFloat(pctInput.value);
    if (isNaN(pct) || pct <= 0 || pct > 100) { showKmError('giaTriGiamPercent', pctInput); return false; }
    giaTriGiamVal = pct;
    giamToiDaVal = document.getElementById('f_giamToiDaPercent').value || '';
  } else {
    var fixedInput = document.getElementById('f_giaTriGiamFixed');
    var fixedVal = parseFloat(fixedInput.value);
    if (isNaN(fixedVal) || fixedVal <= 0) { showKmError('giaTriGiamFixed', fixedInput); return false; }
    giaTriGiamVal = fixedVal;
  }
  document.getElementById('f_giaTriGiam').value = giaTriGiamVal;
  document.getElementById('f_giamToiDa').value = giamToiDaVal;

  var minOrder = document.getElementById('f_giaTriToiThieu');
  if (minOrder.value !== '' && parseFloat(minOrder.value) < 0) { showKmError('giaTriToiThieu', minOrder); return false; }

  var startInput = document.getElementById('f_ngayBatDau');
  var endInput = document.getElementById('f_ngayKetThuc');
  if (!startInput.value || !endInput.value) {
    showKmError('ngayKetThuc', endInput);
    return false;
  }
  if (endInput.value < startInput.value) {
    showKmError('ngayKetThuc', endInput);
    return false;
  }

  var maxUsage = document.getElementById('f_soLanToiDa');
  if (maxUsage.value !== '' && parseInt(maxUsage.value, 10) <= 0) { showKmError('soLanToiDa', maxUsage); return false; }

  return disableSubmit(form);
}

function disableSubmit(form) {
  var btn = form.querySelector('button[type="submit"]');
  if (btn) {
    if (btn.dataset.submitting === '1') return false;
    btn.dataset.submitting = '1';
    btn.disabled = true;
    btn.textContent = 'Đang lưu...';
  }
  return true;
}

function openKmDrawer(id) {
  clearKmErrors();
  var form = document.getElementById('kmForm');
  form.reset();
  document.getElementById('f_giaTriGiamPercent').value = '';
  document.getElementById('f_giamToiDaPercent').value = '';
  document.getElementById('f_giaTriGiamFixed').value = '';
  setDiscountMode('PERCENT');

  if (id && KM_DATA[id]) {
    var d = KM_DATA[id];
    document.getElementById('kmDrawerTitle').textContent = 'Sửa mã khuyến mãi';
    document.getElementById('kmFormAction').value = 'update';
    document.getElementById('kmIdInput').value = id;
    document.getElementById('f_maCode').value = d.maCode;
    document.getElementById('f_moTa').value = d.moTa;
    document.getElementById('f_giaTriToiThieu').value = d.giaTriToiThieu > 0 ? d.giaTriToiThieu : '';
    document.getElementById('f_ngayBatDau').value = d.ngayBatDau;
    document.getElementById('f_ngayKetThuc').value = d.ngayKetThuc;
    document.getElementById('f_soLanToiDa').value = d.soLanToiDa != null ? d.soLanToiDa : '';
    document.getElementById('f_trangThaiHoatDong').checked = d.trangThaiHoatDong;
    if (d.loaiGiam === 'PERCENT') {
      setDiscountMode('PERCENT');
      document.getElementById('f_giaTriGiamPercent').value = d.giaTriGiam;
      document.getElementById('f_giamToiDaPercent').value = d.giamToiDa > 0 ? d.giamToiDa : '';
    } else {
      setDiscountMode('FIXED');
      document.getElementById('f_giaTriGiamFixed').value = d.giaTriGiam;
    }
  } else {
    document.getElementById('kmDrawerTitle').textContent = 'Tạo mã khuyến mãi';
    document.getElementById('kmFormAction').value = 'create';
    document.getElementById('kmIdInput').value = '';
  }

  document.getElementById('kmOverlay').classList.add('open');
  document.getElementById('kmDrawer').classList.add('open');
  setTimeout(function () { document.getElementById('f_maCode').focus(); }, 50);
}

function closeKmDrawer() {
  document.getElementById('kmOverlay').classList.remove('open');
  document.getElementById('kmDrawer').classList.remove('open');
}

document.addEventListener('keydown', function (e) {
  if (e.key === 'Escape') closeKmDrawer();
});

<c:if test="${not empty editing}">
window.addEventListener('DOMContentLoaded', function () { openKmDrawer('${editing.khuyenMaiID}'); });
</c:if>
</script>

>>>>>>> fix/teacher-review-remediation
</body>
</html>
