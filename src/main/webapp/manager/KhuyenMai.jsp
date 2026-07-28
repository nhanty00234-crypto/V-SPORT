<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
<title>${pageTitle}</title>
<jsp:include page="/manager/common/manager_head.jsp" />
<style>
  body { background-color: #f8fafc !important; color: #0f172a; }
  .km-stat { background:#fff; border:1px solid #e2e8f0; border-radius:16px; padding:18px 20px; box-shadow:0 1px 3px rgba(18,45,64,.04); transition: transform .2s ease, box-shadow .2s ease; }
  .km-stat:hover { transform: translateY(-2px); box-shadow:0 6px 16px rgba(18,45,64,.08); }
  .km-stat .num { font-size:24px; font-weight:800; color:#122d40; font-family:'Outfit', 'Plus Jakarta Sans', sans-serif; }
  .km-stat .lbl { font-size:12.5px; color:#475569; font-weight:600; margin-top:3px; }
  
  .badge { display:inline-flex; align-items:center; gap:4px; font-size:11px; font-weight:700; padding:3.5px 10px; border-radius:999px; white-space:nowrap; }
  .badge-green { background:#dcfce7; color:#166534; border: 1px solid rgba(22,101,52,0.15); }
  .badge-blue { background:#e0f2fe; color:#0369a1; border: 1px solid rgba(3,105,161,0.15); }
  .badge-amber { background:#fef3c7; color:#92400e; border: 1px solid rgba(146,64,14,0.15); }
  .badge-zinc { background:#f1f5f9; color:#475569; border: 1px solid rgba(71,85,105,0.15); }
  .badge-rose { background:#fee2e2; color:#991b1b; border: 1px solid rgba(153,27,27,0.15); }

  .filter-chip { padding:7px 16px; border-radius:999px; font-size:13px; font-weight:600; color:#334155; background:#fff; border:1px solid #cbd5e1; white-space:nowrap; cursor:pointer; transition: all .15s ease; }
  .filter-chip:hover { background:#e6f9f0; color:#065f46; border-color:#01e281; }
  .filter-chip.active { background:#122d40; color:#ffffff; border-color:#122d40; font-weight:700; box-shadow:0 2px 6px rgba(18,45,64,.2); }

  .km-table { width:100%; border-collapse:separate; border-spacing:0; }
  .km-table th { text-align:left; font-size:11px; font-weight:800; color:#475569; text-transform:uppercase; letter-spacing:.05em; padding:12px 14px; border-bottom:1px solid #e2e8f0; background:#f8fafc; white-space:nowrap; }
  .km-table td { padding:14px; border-bottom:1px solid #f1f5f9; font-size:13.5px; color:#0f172a; vertical-align:middle; }
  .km-table tr:hover td { background:#f8fafc; }

  .km-card { background:#fff; border:1px solid #e2e8f0; border-radius:16px; padding:16px 18px; box-shadow:0 1px 3px rgba(18,45,64,.04); }
  
  .drawer-overlay { position:fixed; inset:0; background:rgba(18,45,64,.45); backdrop-filter:blur(3px); z-index:60; display:none; }
  .drawer-panel { position:fixed; top:0; right:0; height:100vh; width:100%; max-width:560px; background:#fff; z-index:61;
    box-shadow:-10px 0 30px rgba(18,45,64,.15); transform:translateX(100%); transition:transform .25s cubic-bezier(.16,1,.3,1); overflow-y:auto; }
  .drawer-panel.open, .drawer-overlay.open { display:block; }
  .drawer-panel.open { transform:translateX(0); }

  .field label { font-size:12px; font-weight:700; color:#334155; margin-bottom:5px; display:block; }
  .field .hint { font-size:11.5px; color:#64748b; margin-top:4px; }
  .field .err { font-size:11.5px; color:#b91c1c; font-weight:700; margin-top:4px; display:none; }
  .field input, .field select, .field textarea {
    width:100%; border:1px solid #cbd5e1; border-radius:12px; padding:9px 12px; font-size:13.5px; outline:none; color:#0f172a; transition: border-color .15s ease, box-shadow .15s ease;
  }
  .field input:focus, .field select:focus, .field textarea:focus { border-color:#01e281; box-shadow: 0 0 0 3px rgba(1,226,129,0.15); }
  
  .discount-mode-btn { flex:1; padding:10px 12px; border-radius:12px; border:1.5px solid #cbd5e1; font-size:13px; font-weight:600; color:#334155; cursor:pointer; text-align:center; background:#fff; transition: all .15s ease; }
  .discount-mode-btn:hover { background:#f8fafc; border-color:#94a3b8; }
  .discount-mode-btn.active { border-color:#059669; background:#e6f9f0; color:#065f46; font-weight:700; box-shadow: 0 1px 3px rgba(5,150,105,0.1); }

  @media (max-width: 1024px) { .km-table-wrap { display:none; } }
  @media (min-width: 1025px) { .km-card-list { display:none; } }
</style>
</head>
<body class="text-slate-900 min-h-screen">

<jsp:include page="/manager/common/sidebar.jsp" />

<c:set var="headerTitle" value="Quản lý mã khuyến mãi" scope="page" />
<c:set var="headerSubtitle" value="Chi nhánh CS${sessionScope.user.coSoId}" scope="page" />
<c:set var="headerIcon" value="sell" scope="page" />
<jsp:include page="/manager/common/header.jsp" />

<main class="lg:ml-[248px] mt-[64px] p-4 lg:p-6 flex flex-col gap-5">
  <%-- Flash Alerts --%>
  <c:if test="${not empty sessionScope.flashSuccess}">
    <div class="rounded-xl px-4 py-3 bg-emerald-50 border border-emerald-200 text-emerald-900 text-sm font-semibold">${sessionScope.flashSuccess}</div>
    <% session.removeAttribute("flashSuccess"); %>
  </c:if>
  <c:if test="${not empty sessionScope.flashError}">
    <div class="rounded-xl px-4 py-3 bg-rose-50 border border-rose-200 text-rose-900 text-sm font-semibold">${sessionScope.flashError}</div>
    <% session.removeAttribute("flashError"); %>
  </c:if>
  <c:if test="${not empty errors}">
    <div class="rounded-xl px-4 py-3 bg-rose-50 border border-rose-200 text-rose-900 text-sm">
      <ul class="list-disc pl-4 space-y-1 font-medium">
        <c:forEach var="err" items="${errors}"><li><c:out value="${err}"/></li></c:forEach>
      </ul>
    </div>
  </c:if>

  <c:if test="${not empty successMsg}">
    <div class="flex items-center gap-3 p-4 bg-emerald-50 border border-emerald-200 text-emerald-900 rounded-2xl shadow-sm" data-flash="success" data-flash-msg="${fn:escapeXml(successMsg)}">
      <span class="material-symbols-outlined text-emerald-600 text-[20px]">check_circle</span>
      <p class="text-sm font-bold">${successMsg}</p>
    </div>
  </c:if>
  <c:if test="${not empty errorMsg}">
    <div class="flex items-center gap-3 p-4 bg-rose-50 border border-rose-200 text-rose-900 rounded-2xl shadow-sm" data-flash="error" data-flash-msg="${fn:escapeXml(errorMsg)}">
      <span class="material-symbols-outlined text-rose-600 text-[20px]">error</span>
      <p class="text-sm font-bold">${errorMsg}</p>
    </div>
  </c:if>

  <section class="flex items-center justify-between gap-4 flex-wrap">
    <div>
      <h1 class="text-2xl font-extrabold text-[#122d40] tracking-tight">Quản lý mã khuyến mãi</h1>
      <p class="text-[13.5px] text-slate-600 font-medium mt-1">Tạo và theo dõi các chương trình ưu đãi tại cơ sở của bạn.</p>
    </div>
    <button onclick="openKmDrawer()" class="px-4.5 py-2.5 rounded-xl bg-[#01e281] hover:bg-[#01c771] text-[#0d2130] text-sm font-extrabold flex items-center gap-2 shadow-sm transition active:scale-95">
      <span class="material-symbols-outlined text-[18px]">add</span>Tạo mã khuyến mãi
    </button>
  </section>

  <section class="grid grid-cols-2 lg:grid-cols-4 gap-3.5">
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
               class="w-full pl-9 pr-3 py-2.5 rounded-xl border border-slate-300 text-sm font-medium text-slate-900 placeholder:text-slate-400 focus:outline-none focus:border-[#01e281] focus:ring-1 focus:ring-[#01e281]" />
      </div>
      <input type="hidden" name="status" id="statusHiddenInput" value="${statusFilter}" />
      <button type="submit" class="px-4.5 py-2.5 rounded-xl bg-[#122d40] hover:bg-[#0d2130] text-white text-sm font-bold transition shadow-sm">Tìm</button>
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
      <div class="km-card text-center py-12 px-4 flex flex-col items-center justify-center gap-2">
        <span class="material-symbols-outlined text-slate-400 text-5xl">loyalty</span>
        <p class="text-slate-700 font-bold text-sm">Chưa có mã khuyến mãi nào phù hợp.</p>
        <p class="text-slate-500 text-xs font-medium">Thử thay đổi bộ lọc tìm kiếm hoặc tạo chương trình ưu đãi mới.</p>
      </div>
    </c:when>
    <c:otherwise>
      <%-- Desktop table --%>
      <section class="km-table-wrap bg-white border border-slate-200 rounded-2xl overflow-x-auto shadow-sm">
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
                <td class="font-extrabold text-[#122d40] font-mono text-sm">${fn:escapeXml(km.maCode)}</td>
                <td class="max-w-[220px]"><div class="truncate font-semibold text-slate-800">${fn:escapeXml(km.moTa)}</div></td>
                <td class="font-medium text-slate-700">${km.loaiGiam == 'PERCENT' ? 'Phần trăm' : 'Cố định'}</td>
                <td class="font-bold text-[#122d40]">
                  <c:choose>
                    <c:when test="${km.loaiGiam == 'PERCENT'}"><fmt:formatNumber value="${km.giaTriGiam}" pattern="#,##0.#"/>%</c:when>
                    <c:otherwise><fmt:formatNumber value="${km.giaTriGiam}" pattern="#,##0"/>đ</c:otherwise>
                  </c:choose>
                </td>
                <td class="font-medium text-slate-700"><c:choose><c:when test="${not empty km.giaTriToiThieu and km.giaTriToiThieu gt 0}"><fmt:formatNumber value="${km.giaTriToiThieu}" pattern="#,##0"/>đ</c:when><c:otherwise>—</c:otherwise></c:choose></td>
                <td class="font-medium text-slate-700"><c:choose><c:when test="${not empty km.giamToiDa and km.giamToiDa gt 0}"><fmt:formatNumber value="${km.giamToiDa}" pattern="#,##0"/>đ</c:when><c:otherwise>—</c:otherwise></c:choose></td>
                <td class="font-medium text-slate-600">${fn:substring(km.ngayBatDau, 8, 10)}/${fn:substring(km.ngayBatDau, 5, 7)}/${fn:substring(km.ngayBatDau, 0, 4)}</td>
                <td class="font-medium text-slate-600">${fn:substring(km.ngayKetThuc, 8, 10)}/${fn:substring(km.ngayKetThuc, 5, 7)}/${fn:substring(km.ngayKetThuc, 0, 4)}</td>
                <td class="font-semibold text-slate-800">${km.soLanDaDung} / <c:choose><c:when test="${not empty km.soLanToiDa}">${km.soLanToiDa}</c:when><c:otherwise>&infin;</c:otherwise></c:choose></td>
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
                    <button type="button" title="Xem / sửa" onclick="openKmDrawer('${km.khuyenMaiID}')" class="w-8 h-8 rounded-lg hover:bg-slate-100 flex items-center justify-center transition" aria-label="Sửa mã ${fn:escapeXml(km.maCode)}">
                      <span class="material-symbols-outlined text-slate-600 text-[18px]">edit</span>
                    </button>
                    <form method="post" action="${pageContext.request.contextPath}/manager/khuyen-mai" onsubmit="return disableSubmit(this)">
                      <input type="hidden" name="action" value="toggle"/>
                      <input type="hidden" name="khuyenMaiId" value="${km.khuyenMaiID}"/>
                      <input type="hidden" name="value" value="${km.trangThai == 'Hoạt động' ? 0 : 1}"/>
                      <button type="submit" title="${km.trangThai == 'Hoạt động' ? 'Tạm khóa' : 'Bật lại'}" class="w-8 h-8 rounded-lg hover:bg-slate-100 flex items-center justify-center transition" aria-label="${km.trangThai == 'Hoạt động' ? 'Tạm khóa mã' : 'Bật lại mã'} ${fn:escapeXml(km.maCode)}">
                        <span class="material-symbols-outlined text-slate-600 text-[18px]">${km.trangThai == 'Hoạt động' ? 'toggle_on' : 'toggle_off'}</span>
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
              <p class="font-extrabold text-[#122d40] font-mono text-base">${fn:escapeXml(km.maCode)}</p>
              <c:set var="st" value="${kmDisplayStatus[km.khuyenMaiID]}" />
              <c:choose>
                <c:when test="${st == 'Đang hoạt động'}"><span class="badge badge-green">Đang hoạt động</span></c:when>
                <c:when test="${st == 'Sắp diễn ra'}"><span class="badge badge-blue">Sắp diễn ra</span></c:when>
                <c:when test="${st == 'Đã hết hạn'}"><span class="badge badge-zinc">Đã hết hạn</span></c:when>
                <c:when test="${st == 'Hết lượt'}"><span class="badge badge-amber">Hết lượt</span></c:when>
                <c:otherwise><span class="badge badge-rose">Tạm khóa</span></c:otherwise>
              </c:choose>
            </div>
            <p class="text-[13px] text-slate-700 font-medium mt-1 truncate">${fn:escapeXml(km.moTa)}</p>
            <p class="text-[13px] text-[#122d40] font-bold mt-2">
              <c:choose>
                <c:when test="${km.loaiGiam == 'PERCENT'}">Giảm <fmt:formatNumber value="${km.giaTriGiam}" pattern="#,##0.#"/>%</c:when>
                <c:otherwise>Giảm <fmt:formatNumber value="${km.giaTriGiam}" pattern="#,##0"/>đ</c:otherwise>
              </c:choose>
              <span class="font-normal text-slate-500">· Dùng ${km.soLanDaDung}/<c:choose><c:when test="${not empty km.soLanToiDa}">${km.soLanToiDa}</c:when><c:otherwise>&infin;</c:otherwise></c:choose></span>
            </p>
            <p class="text-[12px] text-slate-500 font-medium mt-1">
              ${fn:substring(km.ngayBatDau, 8, 10)}/${fn:substring(km.ngayBatDau, 5, 7)}/${fn:substring(km.ngayBatDau, 0, 4)}
              – ${fn:substring(km.ngayKetThuc, 8, 10)}/${fn:substring(km.ngayKetThuc, 5, 7)}/${fn:substring(km.ngayKetThuc, 0, 4)}
            </p>
            <div class="flex items-center gap-2 mt-3">
              <button type="button" onclick="openKmDrawer('${km.khuyenMaiID}')" class="flex-1 py-2 rounded-xl border border-slate-300 text-sm font-bold text-slate-800 hover:bg-slate-50">Sửa</button>
              <form method="post" action="${pageContext.request.contextPath}/manager/khuyen-mai" onsubmit="return disableSubmit(this)" class="flex-1">
                <input type="hidden" name="action" value="toggle"/>
                <input type="hidden" name="khuyenMaiId" value="${km.khuyenMaiID}"/>
                <input type="hidden" name="value" value="${km.trangThai == 'Hoạt động' ? 0 : 1}"/>
                <button type="submit" class="w-full py-2 rounded-xl border border-slate-300 text-sm font-bold text-slate-800 hover:bg-slate-50">${km.trangThai == 'Hoạt động' ? 'Tạm khóa' : 'Bật lại'}</button>
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
    <div class="flex items-center justify-between px-6 py-4 border-b border-slate-200">
      <h3 class="font-extrabold text-lg text-[#122d40]" id="kmDrawerTitle">Tạo mã khuyến mãi</h3>
      <button type="button" onclick="closeKmDrawer()" class="w-8 h-8 rounded-lg hover:bg-slate-100 text-slate-600 flex items-center justify-center" aria-label="Đóng">
        <span class="material-symbols-outlined text-[20px]">close</span>
      </button>
    </div>
    <div class="flex-1 overflow-y-auto px-6 py-5 flex flex-col gap-4">

      <p class="text-xs font-extrabold text-[#059669] uppercase tracking-wider">Thông tin chung</p>
      <div class="field">
        <label for="f_maCode">Mã khuyến mãi *</label>
        <input type="text" name="maCode" id="f_maCode" maxlength="50" required placeholder="Ví dụ: VSPORT20" oninput="this.value = this.value.toUpperCase().trim();"/>
        <p class="hint">Chỉ gồm chữ in hoa, số, gạch nối (ví dụ: VSPORT20). Không thể trùng mã đã có.</p>
        <p class="err" id="err_maCode">Vui lòng nhập mã khuyến mãi hợp lệ.</p>
      </div>
      <div class="field">
        <label for="f_moTa">Tên chương trình / Mô tả</label>
        <textarea name="moTa" id="f_moTa" rows="2" maxlength="255" placeholder="Mô tả chương trình khuyến mãi..."></textarea>
      </div>

      <p class="text-xs font-extrabold text-[#059669] uppercase tracking-wider mt-1">Hình thức giảm</p>
      <div class="flex gap-2.5">
        <button type="button" class="discount-mode-btn active" id="modeBtnPercent" onclick="setDiscountMode('PERCENT')">Giảm theo phần trăm</button>
        <button type="button" class="discount-mode-btn" id="modeBtnFixed" onclick="setDiscountMode('FIXED')">Giảm số tiền cố định</button>
      </div>
      <input type="hidden" name="loaiGiam" id="f_loaiGiam" value="PERCENT"/>

      <div id="percentFields" class="grid grid-cols-1 sm:grid-cols-2 gap-3">
        <div class="field">
          <label for="f_giaTriGiamPercent">Phần trăm giảm (%) *</label>
          <input type="number" min="0.01" max="100" step="0.1" id="f_giaTriGiamPercent" placeholder="10"/>
          <p class="err" id="err_giaTriGiamPercent">Phần trăm giảm phải lớn hơn 0 và không vượt quá 100.</p>
        </div>
        <div class="field">
          <label for="f_giamToiDaPercent">Mức giảm tối đa (đ)</label>
          <input type="number" min="0" step="1000" id="f_giamToiDaPercent" placeholder="100.000"/>
        </div>
      </div>
      <div id="fixedFields" class="field" style="display:none;">
        <label for="f_giaTriGiamFixed">Số tiền giảm (đ) *</label>
        <input type="number" min="0" step="1000" id="f_giaTriGiamFixed" placeholder="50.000"/>
        <p class="err" id="err_giaTriGiamFixed">Vui lòng nhập số tiền giảm hợp lệ.</p>
      </div>
      <input type="hidden" name="giaTriGiam" id="f_giaTriGiam"/>
      <input type="hidden" name="giamToiDa" id="f_giamToiDa"/>

      <p class="text-xs font-extrabold text-[#059669] uppercase tracking-wider mt-1">Điều kiện áp dụng</p>
      <div class="field">
        <label for="f_giaTriToiThieu">Giá trị đơn tối thiểu (đ)</label>
        <input type="number" min="0" step="1000" name="giaTriToiThieu" id="f_giaTriToiThieu" placeholder="200.000"/>
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
        <input type="number" min="1" step="1" name="soLanToiDa" id="f_soLanToiDa" placeholder="100"/>
        <p class="err" id="err_soLanToiDa">Tổng lượt sử dụng phải lớn hơn 0.</p>
      </div>
      <label class="flex items-center gap-2.5 text-sm font-bold text-slate-800 cursor-pointer pt-1">
        <input type="checkbox" name="trangThaiHoatDong" id="f_trangThaiHoatDong" checked class="w-4 h-4 rounded text-emerald-600 focus:ring-emerald-500 border-slate-300"/> Đang hoạt động
      </label>
    </div>
    <div class="px-6 py-4 border-t border-slate-200 flex gap-3 bg-slate-50">
      <button type="button" onclick="closeKmDrawer()" class="px-5 py-2.5 rounded-xl border border-slate-300 text-slate-700 text-sm font-bold hover:bg-slate-100 transition">Hủy</button>
      <button type="submit" id="kmSubmitBtn" class="flex-1 py-2.5 rounded-xl bg-[#01e281] hover:bg-[#01c771] text-[#0d2130] text-sm font-extrabold transition shadow-sm">Lưu mã khuyến mãi</button>
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

</body>
</html>
