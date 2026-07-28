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
  .km-stat { background:#fff; border:1px solid #e9d5ff; border-radius:16px; padding:18px 20px; box-shadow:0 1px 3px rgba(124,58,237,.04); transition: transform .2s ease, box-shadow .2s ease; }
  .km-stat:hover { transform: translateY(-2px); box-shadow:0 6px 18px rgba(124,58,237,.12); }
  .km-stat .num { font-size:24px; font-weight:800; color:#4c1d95; font-family:'Outfit', 'Plus Jakarta Sans', sans-serif; }
  .km-stat .lbl { font-size:12.5px; color:#64748b; font-weight:600; margin-top:3px; }
  
  .badge { display:inline-flex; align-items:center; gap:4px; font-size:11px; font-weight:700; padding:3.5px 10px; border-radius:999px; white-space:nowrap; }
  .badge-green { background:#dcfce7; color:#166534; border: 1px solid rgba(22,101,52,0.15); }
  .badge-blue { background:#e0f2fe; color:#0369a1; border: 1px solid rgba(3,105,161,0.15); }
  .badge-amber { background:#fef3c7; color:#92400e; border: 1px solid rgba(146,64,14,0.15); }
  .badge-zinc { background:#f1f5f9; color:#475569; border: 1px solid rgba(71,85,105,0.15); }
  .badge-rose { background:#fee2e2; color:#991b1b; border: 1px solid rgba(153,27,27,0.15); }
  .badge-purple { background:#f3e8ff; color:#6d28d9; border: 1px solid rgba(124,58,237,0.2); }

  .filter-chip { padding:7px 16px; border-radius:999px; font-size:13px; font-weight:600; color:#475569; background:#fff; border:1px solid #e9d5ff; white-space:nowrap; cursor:pointer; transition: all .15s ease; }
  .filter-chip:hover { background:#f3e8ff; color:#6d28d9; border-color:#7c3aed; }
  .filter-chip.active { background:#4c1d95; color:#ffffff; border-color:#4c1d95; font-weight:700; box-shadow:0 2px 8px rgba(76,29,149,.25); }

  .km-table { width:100%; border-collapse:separate; border-spacing:0; }
  .km-table th { text-align:left; font-size:11px; font-weight:800; color:#5b21b6; text-transform:uppercase; letter-spacing:.05em; padding:12px 14px; border-bottom:1px solid #e9d5ff; background:#faf5ff; white-space:nowrap; }
  .km-table td { padding:14px; border-bottom:1px solid #f3e8ff; font-size:13.5px; color:#0f172a; vertical-align:middle; }
  .km-table tr:hover td { background:#faf5ff; }

  .km-card { background:#fff; border:1px solid #e9d5ff; border-radius:16px; padding:16px 18px; box-shadow:0 1px 3px rgba(124,58,237,.04); }
  
  /* ═══ KM DRAWER — V-SPORT purple brand palette (matches --vs-primary family) ═══ */
  :root {
    --km-navy: #6d28d9;
    --km-navy-soft: #7c3aed;
    --km-green: #7c3aed;
    --km-green-hover: #6d28d9;
    --km-green-soft: #f3e8ff;
    --km-green-text: #6d28d9;
    --km-red: #dc2626;
    --km-red-hover: #b91c1c;
    --km-red-soft: #fee2e2;
    --km-border: #e9d5ff;
    --km-border-soft: #f3e8ff;
    --km-surface: #ffffff;
    --km-surface-muted: #faf5ff;
    --km-text: #1e1b4b;
    --km-text-muted: #64748b;
  }

  .drawer-overlay { position:fixed; inset:0; background:transparent; z-index:60; display:none; opacity:0; transition:opacity .3s ease; }
  .drawer-overlay.open { display:block; opacity:1; }

  .drawer-panel {
    position:fixed; top:0; right:0; height:100dvh;
    width:100vw;
    background:var(--km-surface); z-index:61;
    box-shadow:-20px 0 50px rgba(76,29,149,.18);
    transform:translateX(100%); transition:transform .38s cubic-bezier(.16,1,.3,1);
    display:flex; flex-direction:column; overflow:hidden;
    border-left:1px solid var(--km-border);
  }
  @media (min-width: 640px) {
    .drawer-panel { width:90vw; border-radius: 20px 0 0 20px; }
  }
  @media (min-width: 1024px) {
    .drawer-panel { width:clamp(720px, 68vw, 850px); }
  }
  @media (min-width: 1440px) {
    .drawer-panel { width:clamp(780px, 58vw, 980px); }
  }
  .drawer-panel.open { transform:translateX(0); }

  .drawer-head { flex:0 0 auto; position:sticky; top:0; z-index:2; background:var(--km-surface); border-bottom:1px solid var(--km-border); }
  .drawer-body { flex:1 1 auto; overflow-y:auto; overscroll-behavior:contain; }
  .drawer-foot { flex:0 0 auto; position:sticky; bottom:0; z-index:2; background:var(--km-surface); border-top:1px solid var(--km-border); box-shadow:0 -8px 24px -12px rgba(76,29,149,.12); }
  body.km-drawer-lock { overflow:hidden; }

  /* Nội dung form fade/slide-in nhẹ ngay sau khi panel trượt vào, tạo cảm giác mượt hơn là transform tĩnh */
  .drawer-panel .drawer-head,
  .drawer-panel .drawer-body > *,
  .drawer-panel .drawer-foot {
    opacity:0; transform:translateY(10px);
    transition:opacity .35s ease, transform .35s ease;
  }
  .drawer-panel.open .drawer-head,
  .drawer-panel.open .drawer-body > *,
  .drawer-panel.open .drawer-foot {
    opacity:1; transform:translateY(0);
  }
  .drawer-panel.open .drawer-head { transition-delay:.08s; }
  .drawer-panel.open .drawer-body > *:nth-child(1) { transition-delay:.1s; }
  .drawer-panel.open .drawer-body > *:nth-child(2) { transition-delay:.13s; }
  .drawer-panel.open .drawer-body > *:nth-child(3) { transition-delay:.16s; }
  .drawer-panel.open .drawer-body > *:nth-child(4) { transition-delay:.19s; }
  .drawer-panel.open .drawer-body > *:nth-child(5) { transition-delay:.22s; }
  .drawer-panel.open .drawer-body > *:nth-child(n+6) { transition-delay:.24s; }
  .drawer-panel.open .drawer-foot { transition-delay:.3s; }
  @media (prefers-reduced-motion: reduce) {
    .drawer-panel .drawer-head, .drawer-panel .drawer-body > *, .drawer-panel .drawer-foot { opacity:1 !important; transform:none !important; transition:none !important; }
  }

  .field label { font-size:12px; font-weight:700; color:#334155; margin-bottom:5px; display:block; }
  .field .hint { font-size:11.5px; color:#64748b; margin-top:4px; }
  .field .err { font-size:11.5px; color:var(--km-red-hover); font-weight:700; margin-top:4px; display:none; }
  .field input, .field select, .field textarea {
    width:100%; border:1px solid #cbd5e1; border-radius:12px; padding:9px 12px; font-size:13.5px; outline:none; color:#0f172a; transition: border-color .15s ease, box-shadow .15s ease;
  }
  .field input:focus, .field select:focus, .field textarea:focus { border-color:var(--km-navy-soft); box-shadow: 0 0 0 3px rgba(30,41,59,0.12); }

  .km-form-grid { display:grid; grid-template-columns:1fr; gap:14px; }
  @media (min-width: 1024px) {
    .km-form-grid.cols-2 { grid-template-columns:1fr 1fr; }
    .km-form-grid .span-2 { grid-column:1 / -1; }
  }

  .discount-mode-btn { flex:1; padding:10px 12px; border-radius:12px; border:1.5px solid var(--km-border); font-size:13px; font-weight:600; color:#475569; cursor:pointer; text-align:center; background:#fff; transition: all .15s ease; }
  .discount-mode-btn:hover { background:var(--km-surface-muted); border-color:#94a3b8; }
  .discount-mode-btn.active { border-color:var(--km-navy-soft); background:var(--km-navy); color:#fff; font-weight:700; box-shadow: 0 1px 4px rgba(15,23,42,0.2); }

  @media (max-width: 1024px) { .km-table-wrap { display:none; } }
  @media (min-width: 1025px) { .km-card-list { display:none; } }

  /* ── Upload manager ── */
  .km-upl-count { font-size:12px; font-weight:800; color:var(--km-navy); background:var(--km-surface-muted); border:1px solid var(--km-border); padding:3px 10px; border-radius:999px; white-space:nowrap; }
  .km-upl-count.is-full { color:var(--km-green-text); background:var(--km-green-soft); border-color:#bbf7d0; }

  .km-dropzone {
    border:1.5px dashed #cbd5e1; border-radius:14px; background:var(--km-surface-muted);
    padding:22px 16px; display:flex; flex-direction:column; align-items:center; justify-content:center; gap:8px;
    text-align:center; cursor:pointer; transition: border-color .15s ease, background .15s ease;
  }
  .km-dropzone:hover, .km-dropzone:focus-visible { border-color:var(--km-navy-soft); background:#f1f5f9; }
  .km-dropzone.is-dragover { border-color:var(--km-green); background:var(--km-green-soft); }
  .km-dropzone.is-disabled { cursor:not-allowed; opacity:.6; background:var(--km-surface-muted); border-color:#cbd5e1; }
  .km-dropzone .km-dz-icon { width:40px; height:40px; border-radius:50%; background:#fff; border:1px solid var(--km-border); display:flex; align-items:center; justify-content:center; color:var(--km-navy); }
  .km-dropzone .km-dz-title { font-size:13.5px; font-weight:700; color:var(--km-text); }
  .km-dropzone .km-dz-sub { font-size:11.5px; color:var(--km-text-muted); font-weight:500; }
  .km-dz-browse-btn {
    margin-top:2px; padding:7px 16px; border-radius:9px; border:1px solid var(--km-navy); background:var(--km-navy); color:#fff;
    font-size:12.5px; font-weight:700; cursor:pointer; transition:background .15s ease;
  }
  .km-dz-browse-btn:hover { background:var(--km-navy-soft); }
  .km-dz-browse-btn:disabled { background:#94a3b8; border-color:#94a3b8; cursor:not-allowed; }

  .km-img-grid { display:grid; grid-template-columns:repeat(1, 1fr); gap:10px; }
  @media (min-width: 480px) { .km-img-grid { grid-template-columns:repeat(2, 1fr); } }
  @media (min-width: 1440px) { .km-img-grid { grid-template-columns:repeat(3, 1fr); } }

  .km-img-card { position:relative; border-radius:12px; overflow:hidden; border:1.5px solid var(--km-border); background:#fff; display:flex; flex-direction:column; }
  .km-img-card.is-cover { border-color:var(--km-green); box-shadow:0 0 0 2px rgba(22,163,74,.18); }
  .km-img-card .km-img-thumb-wrap { position:relative; aspect-ratio:16/9; background:var(--km-surface-muted); overflow:hidden; }
  .km-img-card img { width:100%; height:100%; object-fit:cover; display:block; }
  .km-img-card .km-img-skeleton { position:absolute; inset:0; background:linear-gradient(100deg, #eef2f7 30%, #f8fafc 50%, #eef2f7 70%); background-size:200% 100%; animation:km-shimmer 1.3s ease-in-out infinite; }
  @keyframes km-shimmer { 0% { background-position:150% 0; } 100% { background-position:-50% 0; } }
  .km-img-card .km-img-fallback { position:absolute; inset:0; display:flex; flex-direction:column; align-items:center; justify-content:center; gap:4px; color:#94a3b8; background:var(--km-surface-muted); font-size:11px; font-weight:600; }

  .km-img-order-tag { position:absolute; top:6px; left:6px; width:22px; height:22px; border-radius:50%; background:rgba(15,23,42,.78); color:#fff; font-size:11px; font-weight:800; display:flex; align-items:center; justify-content:center; }
  .km-img-cover-tag { position:absolute; top:6px; left:34px; background:var(--km-green); color:#fff; font-size:10px; font-weight:800; padding:3px 8px; border-radius:999px; letter-spacing:.02em; }

  .km-img-del-btn {
    position:absolute; top:6px; right:6px; width:28px; height:28px; border-radius:50%; border:none;
    background:rgba(255,255,255,.95); color:var(--km-red); display:flex; align-items:center; justify-content:center;
    cursor:pointer; transition: background .15s ease, transform .12s ease; box-shadow:0 1px 4px rgba(15,23,42,.18);
  }
  .km-img-del-btn:hover { background:var(--km-red); color:#fff; }
  .km-img-del-btn:active { transform:scale(.94); }
  @media (max-width: 640px) { .km-img-del-btn { width:32px; height:32px; } }

  .km-img-meta { padding:8px 10px 10px; display:flex; flex-direction:column; gap:6px; }
  .km-img-meta .km-img-name { font-size:11.5px; font-weight:700; color:var(--km-text); white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
  .km-img-meta .km-img-size { font-size:10.5px; color:var(--km-text-muted); font-weight:600; }
  .km-img-cover-btn {
    font-size:11px; font-weight:700; color:var(--km-navy); background:#fff; border:1px solid var(--km-border);
    border-radius:8px; padding:5px 8px; cursor:pointer; transition: all .15s ease; text-align:center;
  }
  .km-img-cover-btn:hover { background:var(--km-surface-muted); border-color:#94a3b8; }
  .km-img-cover-btn:disabled { color:var(--km-green-text); background:var(--km-green-soft); border-color:#bbf7d0; cursor:default; }

  .km-img-empty { font-size:12px; color:#94a3b8; font-weight:600; padding:14px 0; text-align:center; grid-column:1/-1; }
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
      <h1 class="text-2xl font-extrabold text-purple-950 tracking-tight">Quản lý mã khuyến mãi</h1>
      <p class="text-[13.5px] text-purple-700/80 font-medium mt-1">Tạo và theo dõi các chương trình ưu đãi tại cơ sở của bạn.</p>
    </div>
    <button onclick="openKmDrawer()" class="px-6 py-2.5 rounded-xl bg-purple-600 hover:bg-purple-700 text-white text-sm font-extrabold inline-flex items-center gap-2 shadow-md shadow-purple-200 transition active:scale-95 whitespace-nowrap shrink-0 cursor-pointer">
      <span class="material-symbols-outlined text-[18px]">add</span>Tạo mã khuyến mãi
    </button>
  </section>

  <section class="grid grid-cols-2 lg:grid-cols-4 gap-3.5">
    <div class="km-stat"><div class="num">${countActive}</div><div class="lbl">Đang hoạt động</div></div>
    <div class="km-stat"><div class="num">${countUpcoming}</div><div class="lbl">Sắp diễn ra</div></div>
    <div class="km-stat"><div class="num">${countExpired}</div><div class="lbl">Đã hết hạn</div></div>
    <div class="km-stat"><div class="num">${totalUsage}</div><div class="lbl">Tổng lượt sử dụng</div></div>
  </section>

  <section class="bg-white border border-purple-100 rounded-2xl p-3.5 shadow-sm flex flex-col lg:flex-row lg:items-center justify-between gap-3">
    <form method="get" action="${pageContext.request.contextPath}/manager/khuyen-mai" class="flex items-center gap-2 w-full lg:w-auto shrink-0">
      <div class="relative w-full sm:w-[300px] lg:w-[340px]">
        <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-purple-400 text-[18px]">search</span>
        <input type="text" name="q" value="${fn:escapeXml(keyword)}" placeholder="Tìm theo mã hoặc tên..."
               class="w-full pl-9 pr-3 py-2 rounded-xl border border-purple-200 text-sm font-medium text-slate-900 placeholder:text-slate-400 focus:outline-none focus:border-purple-600 focus:ring-1 focus:ring-purple-600" />
      </div>
      <input type="hidden" name="status" id="statusHiddenInput" value="${statusFilter}" />
      <button type="submit" class="px-5 py-2 rounded-xl bg-purple-900 hover:bg-purple-950 text-white text-sm font-bold transition shadow-sm shrink-0 whitespace-nowrap cursor-pointer flex items-center justify-center">
        Tìm
      </button>
    </form>
    <div class="flex items-center gap-1.5 overflow-x-auto pb-0.5 lg:pb-0 shrink">
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
        <span class="material-symbols-outlined text-purple-400 text-5xl">loyalty</span>
        <p class="text-purple-950 font-bold text-sm">Chưa có mã khuyến mãi nào phù hợp.</p>
        <p class="text-purple-700/70 text-xs font-medium">Thử thay đổi bộ lọc tìm kiếm hoặc tạo chương trình ưu đãi mới.</p>
      </div>
    </c:when>
    <c:otherwise>
      <%-- Desktop table --%>
      <section class="km-table-wrap bg-white border border-purple-100 rounded-2xl overflow-x-auto shadow-sm">
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
                <td class="font-extrabold text-purple-900 font-mono text-sm">${fn:escapeXml(km.maCode)}</td>
                <td class="max-w-[220px]"><div class="truncate font-semibold text-slate-800">${fn:escapeXml(km.moTa)}</div></td>
                <td class="font-medium text-slate-700">${km.loaiGiam == 'PERCENT' ? 'Phần trăm' : 'Cố định'}</td>
                <td class="font-bold text-purple-900">
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
                    <button type="button" title="Xem / sửa" onclick="openKmDrawer('${km.khuyenMaiID}')" class="w-8 h-8 rounded-lg hover:bg-purple-50 flex items-center justify-center transition" aria-label="Sửa mã ${fn:escapeXml(km.maCode)}">
                      <span class="material-symbols-outlined text-purple-600 text-[18px]">edit</span>
                    </button>
                    <form method="post" action="${pageContext.request.contextPath}/manager/khuyen-mai" onsubmit="return disableSubmit(this)">
                      <input type="hidden" name="action" value="toggle"/>
                      <input type="hidden" name="khuyenMaiId" value="${km.khuyenMaiID}"/>
                      <input type="hidden" name="value" value="${km.trangThai == 'Hoạt động' ? 0 : 1}"/>
                      <button type="submit" title="${km.trangThai == 'Hoạt động' ? 'Tạm khóa' : 'Bật lại'}" class="w-8 h-8 rounded-lg hover:bg-purple-50 flex items-center justify-center transition" aria-label="${km.trangThai == 'Hoạt động' ? 'Tạm khóa mã' : 'Bật lại mã'} ${fn:escapeXml(km.maCode)}">
                        <span class="material-symbols-outlined text-purple-600 text-[18px]">${km.trangThai == 'Hoạt động' ? 'toggle_on' : 'toggle_off'}</span>
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
              <p class="font-extrabold text-purple-900 font-mono text-base">${fn:escapeXml(km.maCode)}</p>
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
            <p class="text-[13px] text-purple-950 font-bold mt-2">
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
              <button type="button" onclick="openKmDrawer('${km.khuyenMaiID}')" class="flex-1 py-2 rounded-xl border border-purple-200 text-sm font-bold text-purple-900 hover:bg-purple-50">Sửa</button>
              <form method="post" action="${pageContext.request.contextPath}/manager/khuyen-mai" onsubmit="return disableSubmit(this)" class="flex-1">
                <input type="hidden" name="action" value="toggle"/>
                <input type="hidden" name="khuyenMaiId" value="${km.khuyenMaiID}"/>
                <input type="hidden" name="value" value="${km.trangThai == 'Hoạt động' ? 0 : 1}"/>
                <button type="submit" class="w-full py-2 rounded-xl border border-purple-200 text-sm font-bold text-purple-900 hover:bg-purple-50">${km.trangThai == 'Hoạt động' ? 'Tạm khóa' : 'Bật lại'}</button>
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
  <form method="post" action="${pageContext.request.contextPath}/manager/khuyen-mai" enctype="multipart/form-data" class="flex flex-col h-full" id="kmForm" onsubmit="return validateKmForm(this)">
    <input type="hidden" name="action" id="kmFormAction" value="create"/>
    <input type="hidden" name="khuyenMaiId" id="kmIdInput" value=""/>

    <div class="drawer-head flex items-center justify-between px-6 py-4">
      <h3 class="font-extrabold text-lg" style="color:var(--km-navy);" id="kmDrawerTitle">Tạo mã khuyến mãi</h3>
      <button type="button" id="kmCloseBtn" onclick="closeKmDrawer()" class="w-9 h-9 rounded-lg hover:bg-slate-100 flex items-center justify-center transition" style="color:var(--km-navy);" aria-label="Đóng">
        <span class="material-symbols-outlined text-[22px]">close</span>
      </button>
    </div>

    <div class="drawer-body px-6 py-5 flex flex-col gap-4">

      <p class="text-xs font-extrabold uppercase tracking-wider" style="color:var(--km-navy);">Thông tin chung</p>
      <div class="km-form-grid cols-2">
        <div class="field span-2">
          <div class="flex items-center justify-between gap-2 mb-1.5">
            <label for="f_maCode" class="!mb-0">Mã khuyến mãi *</label>
            <button type="button" onclick="generateRandomMaCode()" class="text-xs font-extrabold flex items-center gap-1 hover:underline cursor-pointer bg-slate-100 hover:bg-slate-200 px-2 py-0.5 rounded-md border border-slate-200 transition" style="color:var(--km-navy);">
              <span class="material-symbols-outlined text-[14px]">casino</span> Ngẫu nhiên
            </button>
          </div>
          <div class="relative">
            <input type="text" name="maCode" id="f_maCode" maxlength="50" required placeholder="Ví dụ: VSPORT20" oninput="this.value = this.value.toUpperCase().trim();" class="pr-10"/>
            <button type="button" onclick="generateRandomMaCode()" title="Tạo mã ngẫu nhiên" class="absolute right-2 top-1/2 -translate-y-1/2 w-7 h-7 rounded-lg hover:bg-slate-100 flex items-center justify-center transition" style="color:var(--km-navy);" aria-label="Tạo mã ngẫu nhiên">
              <span class="material-symbols-outlined text-[16px]">shuffle</span>
            </button>
          </div>
          <p class="hint">Chỉ gồm chữ in hoa, số, gạch nối (ví dụ: VSPORT20). Không thể trùng mã đã có.</p>
          <p class="err" id="err_maCode">Vui lòng nhập mã khuyến mãi hợp lệ.</p>
        </div>
        <div class="field span-2">
          <label for="f_moTa">Tên chương trình / Mô tả</label>
          <textarea name="moTa" id="f_moTa" rows="2" maxlength="255" placeholder="Mô tả chương trình khuyến mãi..."></textarea>
        </div>
      </div>

      <div class="flex items-center justify-between gap-2 mt-1">
        <p class="text-xs font-extrabold uppercase tracking-wider" style="color:var(--km-navy);">Hình ảnh chương trình</p>
        <span class="km-upl-count" id="kmImgCount">0/5 ảnh</span>
      </div>
      <p class="hint -mt-2">Tải tối đa 5 ảnh cho mỗi chương trình. Mỗi ảnh không vượt quá 5&nbsp;MB. Hỗ trợ JPG, PNG và WEBP. Khuyến nghị tỉ lệ 16:9.</p>

      <input type="file" id="f_images" accept="image/jpeg,image/png,image/webp" multiple class="sr-only" tabindex="-1"/>

      <div class="km-dropzone" id="kmDropzone" tabindex="0" role="button" aria-label="Chọn hoặc kéo thả hình ảnh chương trình">
        <div class="km-dz-icon"><span class="material-symbols-outlined text-[20px]">cloud_upload</span></div>
        <div class="km-dz-title" id="kmDzTitle">Kéo và thả ảnh vào đây</div>
        <div class="km-dz-sub">hoặc nhấn nút bên dưới · JPG, PNG, WEBP · tối đa 5MB/ảnh</div>
        <button type="button" class="km-dz-browse-btn" id="kmDzBrowseBtn">Chọn hình ảnh</button>
      </div>
      <p class="err" id="err_images"></p>

      <div class="km-img-grid" id="kmImageGrid"></div>
      <p class="hint">Ảnh đầu tiên (hoặc ảnh được đánh dấu) sẽ là ảnh bìa. Bấm "Đặt làm ảnh bìa" để đổi. Xóa ảnh có hiệu lực ngay, không cần bấm Lưu.</p>

      <p class="text-xs font-extrabold uppercase tracking-wider mt-1" style="color:var(--km-navy);">Hình thức giảm</p>
      <div class="flex gap-2.5">
        <button type="button" class="discount-mode-btn active" id="modeBtnPercent" onclick="setDiscountMode('PERCENT')">Giảm theo phần trăm</button>
        <button type="button" class="discount-mode-btn" id="modeBtnFixed" onclick="setDiscountMode('FIXED')">Giảm số tiền cố định</button>
      </div>
      <input type="hidden" name="loaiGiam" id="f_loaiGiam" value="PERCENT"/>

      <div id="percentFields" class="km-form-grid cols-2">
        <div class="field">
          <label for="f_giaTriGiamPercent">Phần trăm giảm (%) *</label>
          <input type="number" min="0.01" max="100" step="0.1" id="f_giaTriGiamPercent" placeholder="10"/>
          <p class="err" id="err_giaTriGiamPercent">Phần trăm giảm phải lớn hơn 0 và không vượt quá 100.</p>
        </div>
        <div class="field">
          <label for="f_giamToiDaPercent">Mức giảm tối đa (đ)</label>
          <input type="text" inputmode="numeric" class="km-money-input" id="f_giamToiDaPercent" placeholder="100.000"/>
        </div>
      </div>
      <div id="fixedFields" class="field" style="display:none;">
        <label for="f_giaTriGiamFixed">Số tiền giảm (đ) *</label>
        <input type="text" inputmode="numeric" class="km-money-input" id="f_giaTriGiamFixed" placeholder="50.000"/>
        <p class="err" id="err_giaTriGiamFixed">Vui lòng nhập số tiền giảm hợp lệ.</p>
      </div>
      <input type="hidden" name="giaTriGiam" id="f_giaTriGiam"/>
      <input type="hidden" name="giamToiDa" id="f_giamToiDa"/>

      <p class="text-xs font-extrabold uppercase tracking-wider mt-1" style="color:var(--km-navy);">Điều kiện áp dụng</p>
      <div class="km-form-grid cols-2">
        <div class="field span-2">
          <label for="f_giaTriToiThieu">Giá trị đơn tối thiểu (đ)</label>
          <input type="text" inputmode="numeric" class="km-money-input" id="f_giaTriToiThieu" placeholder="200.000"/>
          <input type="hidden" name="giaTriToiThieu" id="f_giaTriToiThieuRaw"/>
          <p class="err" id="err_giaTriToiThieu">Giá trị đơn tối thiểu không được âm.</p>
        </div>
        <div class="field">
          <label for="f_ngayBatDau">Ngày bắt đầu *</label>
          <input type="date" name="ngayBatDau" id="f_ngayBatDau" required/>
        </div>
        <div class="field">
          <label for="f_ngayKetThuc">Ngày kết thúc *</label>
          <input type="date" name="ngayKetThuc" id="f_ngayKetThuc" required/>
          <p class="err" id="err_ngayKetThuc">Ngày kết thúc phải sau ngày bắt đầu.</p>
        </div>
        <div class="field span-2">
          <label for="f_soLanToiDa">Tổng lượt sử dụng (để trống nếu không giới hạn)</label>
          <input type="number" min="1" step="1" name="soLanToiDa" id="f_soLanToiDa" placeholder="100"/>
          <p class="err" id="err_soLanToiDa">Tổng lượt sử dụng phải lớn hơn 0.</p>
        </div>
      </div>
      <label class="flex items-center gap-2.5 text-sm font-bold text-slate-800 cursor-pointer pt-1">
        <input type="checkbox" name="trangThaiHoatDong" id="f_trangThaiHoatDong" checked class="w-4 h-4 rounded border-slate-300" style="accent-color:var(--km-navy);"/> Đang hoạt động
      </label>
    </div>

    <div class="drawer-foot px-6 py-4 flex gap-3">
      <button type="button" id="kmCancelBtn" onclick="closeKmDrawer()" class="px-5 py-2.5 rounded-xl border border-slate-300 text-sm font-bold hover:bg-slate-100 transition" style="color:var(--km-navy);">Hủy</button>
      <button type="submit" id="kmSubmitBtn" class="flex-1 py-2.5 rounded-xl text-white text-sm font-extrabold transition shadow-md" style="background:var(--km-green); box-shadow:0 4px 14px rgba(22,163,74,.25);" onmouseover="this.style.background='var(--km-green-hover)'" onmouseout="this.style.background='var(--km-green)'">Lưu mã khuyến mãi</button>
    </div>
  </form>
</div>

<script>
var KM_CONTEXT_PATH = '${pageContext.request.contextPath}';
var KM_IMAGE_API = KM_CONTEXT_PATH + '/manager/khuyen-mai/hinh-anh';
var KM_MAX_IMAGES = 5;
var KM_MAX_FILE_MB = 5;

/* ── Image manager state ──
   existingImages: ảnh đã lưu ở backend (khi sửa mã) - mỗi phần tử { hinhAnhId, publicUrl, tenFileGoc, dungLuong, laAnhBia, ... }
   pendingFiles:   ảnh mới vừa chọn, chưa submit - mỗi phần tử { file: File, localId, coverCandidate }
   pendingCoverLocalId: localId của pendingFiles được chọn làm ảnh bìa (chỉ có ý nghĩa khi existingImages rỗng) */
var kmExistingImages = [];
var kmPendingFiles = [];
var kmPendingCoverLocalId = null;
var kmLocalIdSeq = 0;
var kmCurrentKhuyenMaiId = null;

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

/* ── Money inputs: hiển thị dấu chấm phân cách nghìn khi gõ, giữ input là text
   (không phải number) để trình duyệt không tự xoá dấu chấm; giá trị số thật lấy qua
   kmParseMoney() khi validate/submit. ── */
function kmFormatMoney(value) {
  var digits = String(value == null ? '' : value).replace(/[^\d]/g, '');
  if (!digits) return '';
  return digits.replace(/\B(?=(\d{3})+(?!\d))/g, '.');
}
function kmParseMoney(display) {
  var digits = String(display == null ? '' : display).replace(/[^\d]/g, '');
  if (!digits) return null;
  return parseInt(digits, 10);
}
document.addEventListener('input', function (e) {
  if (!e.target.classList || !e.target.classList.contains('km-money-input')) return;
  var input = e.target;
  var caretFromEnd = input.value.length - input.selectionStart;
  input.value = kmFormatMoney(input.value);
  var newPos = input.value.length - caretFromEnd;
  input.setSelectionRange(newPos, newPos);
});

function setDiscountMode(mode) {
  document.getElementById('f_loaiGiam').value = mode;
  document.getElementById('modeBtnPercent').classList.toggle('active', mode === 'PERCENT');
  document.getElementById('modeBtnFixed').classList.toggle('active', mode === 'FIXED');
  document.getElementById('percentFields').style.display = mode === 'PERCENT' ? 'grid' : 'none';
  document.getElementById('fixedFields').style.display = mode === 'FIXED' ? 'block' : 'none';
}

function generateRandomMaCode() {
  var chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  var randomStr = '';
  for (var i = 0; i < 6; i++) {
    randomStr += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  var code = 'VSPORT' + randomStr;
  var input = document.getElementById('f_maCode');
  if (input) {
    input.value = code;
    input.focus();
    clearKmErrors();
  }
}

/* ═══════════════════ IMAGE MANAGER ═══════════════════ */

function kmFormatBytes(bytes) {
  if (bytes == null || isNaN(bytes)) return '';
  if (bytes < 1024) return bytes + ' B';
  if (bytes < 1024 * 1024) return Math.round(bytes / 1024) + ' KB';
  return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
}

function kmTruncateName(name, max) {
  if (!name) return '';
  max = max || 22;
  if (name.length <= max) return name;
  var dot = name.lastIndexOf('.');
  var ext = dot > -1 ? name.slice(dot) : '';
  var base = dot > -1 ? name.slice(0, dot) : name;
  var keep = Math.max(4, max - ext.length - 1);
  return base.slice(0, keep) + '…' + ext;
}

function kmTotalImageCount() {
  return kmExistingImages.length + kmPendingFiles.length;
}

function kmRemainingSlots() {
  return Math.max(0, KM_MAX_IMAGES - kmTotalImageCount());
}

function kmShowImageError(message) {
  var err = document.getElementById('err_images');
  err.textContent = message;
  err.style.display = 'block';
}

function kmClearImageError() {
  var err = document.getElementById('err_images');
  err.style.display = 'none';
  err.textContent = '';
}

function kmIsDuplicateFile(file, list) {
  return list.some(function (p) {
    return p.file.name === file.name && p.file.size === file.size && p.file.lastModified === file.lastModified;
  });
}

/* Input.files là readonly - khi submit multipart trực tiếp, dựng lại FileList từ toàn bộ
   pendingFiles còn được giữ (sau khi đã loại ảnh bị xóa) bằng DataTransfer. */
function kmSyncFileInput() {
  var dt = new DataTransfer();
  kmPendingFiles.forEach(function (p) { dt.items.add(p.file); });
  document.getElementById('f_images').files = dt.files;
}

/* Nhận một FileList/Array mới chọn (từ input hoặc drop) và APPEND vào pendingFiles hiện có -
   không bao giờ gán đè mảng, để ảnh đã chọn trước đó không biến mất. */
function kmAddFiles(fileList) {
  var files = Array.prototype.slice.call(fileList || []);
  if (!files.length) return;
  kmClearImageError();

  var accepted = ['image/jpeg', 'image/png', 'image/webp'];
  var maxBytes = KM_MAX_FILE_MB * 1024 * 1024;
  var toAdd = [];
  var rejectedMsg = null;

  for (var i = 0; i < files.length; i++) {
    var file = files[i];
    if (accepted.indexOf(file.type) === -1) {
      rejectedMsg = 'Định dạng tệp "' + file.name + '" không được hỗ trợ.';
      continue;
    }
    if (file.size > maxBytes) {
      rejectedMsg = 'Ảnh "' + file.name + '" vượt quá dung lượng ' + KM_MAX_FILE_MB + ' MB.';
      continue;
    }
    if (kmIsDuplicateFile(file, kmPendingFiles) || kmIsDuplicateFile(file, toAdd)) {
      continue;
    }
    toAdd.push({ file: file, localId: 'p' + (++kmLocalIdSeq) });
  }

  var remaining = kmRemainingSlots();
  if (toAdd.length > remaining) {
    if (remaining <= 0) {
      kmShowImageError('Bạn đã tải đủ ' + KM_MAX_IMAGES + '/' + KM_MAX_IMAGES + ' ảnh.');
      return;
    }
    rejectedMsg = 'Mỗi chương trình chỉ được tải tối đa ' + KM_MAX_IMAGES + ' ảnh.';
    toAdd = toAdd.slice(0, remaining);
  }

  if (!toAdd.length) {
    if (rejectedMsg) kmShowImageError(rejectedMsg);
    return;
  }

  kmPendingFiles = kmPendingFiles.concat(toAdd);
  if (kmPendingCoverLocalId === null && kmExistingImages.length === 0 && kmPendingFiles.length === toAdd.length) {
    kmPendingCoverLocalId = kmPendingFiles[0].localId;
  }

  kmSyncFileInput();
  if (rejectedMsg) kmShowImageError(rejectedMsg);
  kmRenderImages();
}

function kmRemovePendingFile(localId) {
  kmPendingFiles = kmPendingFiles.filter(function (p) { return p.localId !== localId; });
  if (kmPendingCoverLocalId === localId) {
    kmPendingCoverLocalId = kmPendingFiles.length ? kmPendingFiles[0].localId : null;
  }
  kmSyncFileInput();
  kmClearImageError();
  kmRenderImages();
}

function kmSetPendingCover(localId) {
  kmPendingCoverLocalId = localId;
  kmRenderImages();
}

/* Ảnh hiện có (đã lưu server) dùng endpoint AJAX riêng - có hiệu lực ngay, không cần bấm Lưu. */
function kmLoadExistingImages(khuyenMaiId) {
  kmCurrentKhuyenMaiId = khuyenMaiId || null;
  if (!khuyenMaiId) {
    kmExistingImages = [];
    kmRenderImages();
    return;
  }
  fetch(KM_IMAGE_API + '?khuyenMaiId=' + encodeURIComponent(khuyenMaiId), { credentials: 'same-origin' })
    .then(function (r) { return r.json(); })
    .then(function (data) {
      kmExistingImages = (data && data.success && data.images) ? data.images : [];
      kmRenderImages();
    })
    .catch(function () { kmExistingImages = []; kmRenderImages(); });
}

function kmImagePost(params) {
  var body = new URLSearchParams(params);
  return fetch(KM_IMAGE_API, { method: 'POST', credentials: 'same-origin', body: body })
    .then(function (r) { return r.json(); });
}

function kmSetCoverExisting(hinhAnhId) {
  if (!kmCurrentKhuyenMaiId) return;
  kmImagePost({ action: 'set-cover', khuyenMaiId: kmCurrentKhuyenMaiId, hinhAnhId: hinhAnhId })
    .then(function (res) {
      if (!res.success) { kmShowImageError(res.message || 'Không thể đặt ảnh bìa.'); return; }
      kmLoadExistingImages(kmCurrentKhuyenMaiId);
    });
}

function kmDeleteExistingImage(hinhAnhId) {
  if (!kmCurrentKhuyenMaiId) return;
  kmImagePost({ action: 'delete', khuyenMaiId: kmCurrentKhuyenMaiId, hinhAnhId: hinhAnhId })
    .then(function (res) {
      if (!res.success) { kmShowImageError(res.message || 'Không thể xóa ảnh.'); return; }
      kmLoadExistingImages(kmCurrentKhuyenMaiId);
    });
}

function kmUpdateCounter() {
  var total = kmTotalImageCount();
  var el = document.getElementById('kmImgCount');
  el.textContent = total + '/' + KM_MAX_IMAGES + ' ảnh';
  el.classList.toggle('is-full', total >= KM_MAX_IMAGES);

  var full = total >= KM_MAX_IMAGES;
  var dz = document.getElementById('kmDropzone');
  var browseBtn = document.getElementById('kmDzBrowseBtn');
  var title = document.getElementById('kmDzTitle');
  dz.classList.toggle('is-disabled', full);
  browseBtn.disabled = full;
  title.textContent = full ? 'Bạn đã tải đủ ' + KM_MAX_IMAGES + '/' + KM_MAX_IMAGES + ' ảnh.' : 'Kéo và thả ảnh vào đây';
}

function kmBuildImageCard(opts) {
  /* opts: { key, thumbSrc, name, sizeLabel, order, isCover, onSetCover, canSetCover, onDelete, deleteLabel } */
  var card = document.createElement('div');
  card.className = 'km-img-card' + (opts.isCover ? ' is-cover' : '');

  var thumbWrap = document.createElement('div');
  thumbWrap.className = 'km-img-thumb-wrap';

  var skeleton = document.createElement('div');
  skeleton.className = 'km-img-skeleton';
  thumbWrap.appendChild(skeleton);

  var img = document.createElement('img');
  img.alt = opts.name || 'Ảnh chương trình khuyến mãi';
  img.style.display = 'none';
  img.onload = function () { skeleton.remove(); img.style.display = 'block'; };
  img.onerror = function () {
    skeleton.remove();
    img.remove();
    var fallback = document.createElement('div');
    fallback.className = 'km-img-fallback';
    fallback.innerHTML = '<span class="material-symbols-outlined" style="font-size:22px;">broken_image</span><span>Không tải được ảnh</span>';
    thumbWrap.appendChild(fallback);
  };
  img.src = opts.thumbSrc;
  thumbWrap.appendChild(img);

  var orderTag = document.createElement('span');
  orderTag.className = 'km-img-order-tag';
  orderTag.textContent = String(opts.order);
  thumbWrap.appendChild(orderTag);

  if (opts.isCover) {
    var coverTag = document.createElement('span');
    coverTag.className = 'km-img-cover-tag';
    coverTag.textContent = 'Ảnh bìa';
    thumbWrap.appendChild(coverTag);
  }

  var delBtn = document.createElement('button');
  delBtn.type = 'button';
  delBtn.className = 'km-img-del-btn';
  delBtn.setAttribute('aria-label', opts.deleteLabel || 'Xóa ảnh');
  delBtn.title = 'Xóa ảnh';
  delBtn.innerHTML = '<span class="material-symbols-outlined" style="font-size:16px;">delete</span>';
  delBtn.onclick = opts.onDelete;
  thumbWrap.appendChild(delBtn);

  card.appendChild(thumbWrap);

  var meta = document.createElement('div');
  meta.className = 'km-img-meta';

  var nameEl = document.createElement('div');
  nameEl.className = 'km-img-name';
  nameEl.title = opts.name || '';
  nameEl.textContent = kmTruncateName(opts.name || '');
  meta.appendChild(nameEl);

  var sizeEl = document.createElement('div');
  sizeEl.className = 'km-img-size';
  sizeEl.textContent = opts.sizeLabel || '';
  meta.appendChild(sizeEl);

  var coverBtn = document.createElement('button');
  coverBtn.type = 'button';
  coverBtn.className = 'km-img-cover-btn';
  coverBtn.textContent = opts.isCover ? 'Ảnh bìa hiện tại' : 'Đặt làm ảnh bìa';
  coverBtn.disabled = opts.isCover || !opts.canSetCover;
  coverBtn.onclick = opts.onSetCover;
  meta.appendChild(coverBtn);

  card.appendChild(meta);
  return card;
}

/* Vẽ lại TOÀN BỘ preview: existingImages trước, pendingFiles sau - luôn hiển thị đủ, không
   bao giờ chỉ hiển thị ảnh vừa chọn gần nhất. */
function kmRenderImages() {
  var grid = document.getElementById('kmImageGrid');
  grid.innerHTML = '';
  kmUpdateCounter();

  var total = kmTotalImageCount();
  if (total === 0) {
    var empty = document.createElement('div');
    empty.className = 'km-img-empty';
    empty.textContent = 'Chưa có ảnh nào được chọn.';
    grid.appendChild(empty);
    return;
  }

  var order = 0;
  var hasExistingCover = kmExistingImages.some(function (img) { return img.laAnhBia; });

  /* Không còn ảnh cũ nào làm bìa (vừa xóa ảnh bìa cũ) - tự chọn ảnh mới đầu tiên làm bìa tạm
     thời để trạng thái ảnh bìa không bao giờ rỗng khi vẫn còn ít nhất 1 ảnh. */
  if (!hasExistingCover && kmExistingImages.length === 0 && kmPendingFiles.length &&
      (kmPendingCoverLocalId === null || !kmPendingFiles.some(function (p) { return p.localId === kmPendingCoverLocalId; }))) {
    kmPendingCoverLocalId = kmPendingFiles[0].localId;
  }

  kmExistingImages.forEach(function (img) {
    order++;
    grid.appendChild(kmBuildImageCard({
      key: 'existing-' + img.hinhAnhId,
      thumbSrc: img.publicUrl,
      name: img.tenFileGoc,
      sizeLabel: kmFormatBytes(img.dungLuong),
      order: order,
      isCover: !!img.laAnhBia,
      canSetCover: true,
      onSetCover: function () { kmSetCoverExisting(img.hinhAnhId); },
      onDelete: function () { kmDeleteExistingImage(img.hinhAnhId); },
      deleteLabel: 'Xóa ảnh ' + (img.tenFileGoc || '')
    }));
  });

  kmPendingFiles.forEach(function (p) {
    order++;
    var isCover = !hasExistingCover && kmPendingCoverLocalId === p.localId;
    grid.appendChild(kmBuildImageCard({
      key: 'pending-' + p.localId,
      thumbSrc: URL.createObjectURL(p.file),
      name: p.file.name,
      sizeLabel: kmFormatBytes(p.file.size) + ' · Chưa lưu',
      order: order,
      isCover: isCover,
      canSetCover: !hasExistingCover,
      onSetCover: function () { kmSetPendingCover(p.localId); },
      onDelete: function () { kmRemovePendingFile(p.localId); },
      deleteLabel: 'Xóa ảnh mới ' + p.file.name
    }));
  });
}

function kmInitDropzone() {
  var dz = document.getElementById('kmDropzone');
  var input = document.getElementById('f_images');
  var browseBtn = document.getElementById('kmDzBrowseBtn');

  function openPicker() {
    if (kmRemainingSlots() <= 0) return;
    input.click();
  }

  browseBtn.addEventListener('click', function (e) { e.stopPropagation(); openPicker(); });
  dz.addEventListener('click', openPicker);
  dz.addEventListener('keydown', function (e) {
    if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); openPicker(); }
  });

  input.addEventListener('change', function () {
    kmAddFiles(input.files);
    input.value = '';
  });

  ['dragenter', 'dragover'].forEach(function (evt) {
    dz.addEventListener(evt, function (e) {
      e.preventDefault();
      e.stopPropagation();
      if (kmRemainingSlots() > 0) dz.classList.add('is-dragover');
    });
  });
  ['dragleave', 'drop'].forEach(function (evt) {
    dz.addEventListener(evt, function (e) {
      e.preventDefault();
      e.stopPropagation();
      dz.classList.remove('is-dragover');
    });
  });
  dz.addEventListener('drop', function (e) {
    if (!e.dataTransfer || !e.dataTransfer.files) return;
    kmAddFiles(e.dataTransfer.files);
  });
}

/* ═══════════════════ VALIDATION / SUBMIT ═══════════════════ */

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
    giamToiDaVal = kmParseMoney(document.getElementById('f_giamToiDaPercent').value);
    giamToiDaVal = giamToiDaVal == null ? '' : giamToiDaVal;
  } else {
    var fixedInput = document.getElementById('f_giaTriGiamFixed');
    var fixedVal = kmParseMoney(fixedInput.value);
    if (fixedVal == null || fixedVal <= 0) { showKmError('giaTriGiamFixed', fixedInput); return false; }
    giaTriGiamVal = fixedVal;
  }
  document.getElementById('f_giaTriGiam').value = giaTriGiamVal;
  document.getElementById('f_giamToiDa').value = giamToiDaVal;

  var minOrder = document.getElementById('f_giaTriToiThieu');
  var minOrderVal = kmParseMoney(minOrder.value);
  if (minOrderVal != null && minOrderVal < 0) { showKmError('giaTriToiThieu', minOrder); return false; }
  document.getElementById('f_giaTriToiThieuRaw').value = minOrderVal == null ? '' : minOrderVal;

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

  if (kmTotalImageCount() > KM_MAX_IMAGES) {
    kmShowImageError('Tổng số ảnh vượt quá ' + KM_MAX_IMAGES + '. Vui lòng bớt ảnh mới chọn hoặc xóa bớt ảnh hiện có.');
    document.getElementById('err_images').scrollIntoView({ block: 'center', behavior: 'smooth' });
    return false;
  }

  /* Đảm bảo input.files khớp đúng pendingFiles còn được giữ trước khi submit multipart thật. */
  kmSyncFileInput();

  return disableSubmit(form);
}

function disableSubmit(form) {
  var submitBtn = form.querySelector('button[type="submit"]');
  var cancelBtn = document.getElementById('kmCancelBtn');
  if (submitBtn) {
    if (submitBtn.dataset.submitting === '1') return false;
    submitBtn.dataset.submitting = '1';
    submitBtn.disabled = true;
    submitBtn.textContent = 'Đang lưu...';
  }
  if (cancelBtn) cancelBtn.disabled = true;
  return true;
}

/* Nếu backend redirect kèm errorMsg (validation phía server thất bại), form vẫn còn nguyên
   trên trang mới sau reload - browser back/refresh không áp dụng ở đây vì đây là submit
   POST-redirect-GET chuẩn của servlet; không cần khôi phục thủ công. */

function openKmDrawer(id) {
  clearKmErrors();
  kmClearImageError();
  var form = document.getElementById('kmForm');
  form.reset();
  document.getElementById('f_giaTriGiamPercent').value = '';
  document.getElementById('f_giamToiDaPercent').value = '';
  document.getElementById('f_giaTriGiamFixed').value = '';

  kmPendingFiles = [];
  kmPendingCoverLocalId = null;
  kmSyncFileInput();

  setDiscountMode('PERCENT');
  kmLoadExistingImages(id || null);

  if (id && KM_DATA[id]) {
    var d = KM_DATA[id];
    document.getElementById('kmDrawerTitle').textContent = 'Sửa mã khuyến mãi';
    document.getElementById('kmFormAction').value = 'update';
    document.getElementById('kmIdInput').value = id;
    document.getElementById('f_maCode').value = d.maCode;
    document.getElementById('f_moTa').value = d.moTa;
    document.getElementById('f_giaTriToiThieu').value = d.giaTriToiThieu > 0 ? kmFormatMoney(d.giaTriToiThieu) : '';
    document.getElementById('f_giaTriToiThieuRaw').value = d.giaTriToiThieu > 0 ? d.giaTriToiThieu : '';
    document.getElementById('f_ngayBatDau').value = d.ngayBatDau;
    document.getElementById('f_ngayKetThuc').value = d.ngayKetThuc;
    document.getElementById('f_soLanToiDa').value = d.soLanToiDa != null ? d.soLanToiDa : '';
    document.getElementById('f_trangThaiHoatDong').checked = d.trangThaiHoatDong;
    if (d.loaiGiam === 'PERCENT') {
      setDiscountMode('PERCENT');
      document.getElementById('f_giaTriGiamPercent').value = d.giaTriGiam;
      document.getElementById('f_giamToiDaPercent').value = d.giamToiDa > 0 ? kmFormatMoney(d.giamToiDa) : '';
    } else {
      setDiscountMode('FIXED');
      document.getElementById('f_giaTriGiamFixed').value = kmFormatMoney(d.giaTriGiam);
    }
  } else {
    document.getElementById('kmDrawerTitle').textContent = 'Tạo mã khuyến mãi';
    document.getElementById('kmFormAction').value = 'create';
    document.getElementById('kmIdInput').value = '';
  }

  var submitBtn = document.getElementById('kmSubmitBtn');
  submitBtn.disabled = false;
  submitBtn.dataset.submitting = '0';
  submitBtn.textContent = 'Lưu mã khuyến mãi';
  document.getElementById('kmCancelBtn').disabled = false;

  var overlayEl = document.getElementById('kmOverlay');
  var drawerEl = document.getElementById('kmDrawer');
  overlayEl.classList.add('open');
  drawerEl.classList.remove('open');
  document.body.classList.add('km-drawer-lock');
  /* Cần force reflow + 2 frame trước khi thêm .open để transform/opacity thật sự animate
     (nếu thêm ngay lúc display vừa chuyển sang block, trình duyệt bỏ qua transition). */
  void drawerEl.offsetWidth;
  requestAnimationFrame(function () {
    requestAnimationFrame(function () { drawerEl.classList.add('open'); });
  });
  setTimeout(function () { document.getElementById('f_maCode').focus(); }, 350);
}

function closeKmDrawer() {
  document.getElementById('kmOverlay').classList.remove('open');
  document.getElementById('kmDrawer').classList.remove('open');
  document.body.classList.remove('km-drawer-lock');
}

document.addEventListener('keydown', function (e) {
  if (e.key === 'Escape') closeKmDrawer();
});

kmInitDropzone();
kmRenderImages();

<c:if test="${not empty editing}">
window.addEventListener('DOMContentLoaded', function () { openKmDrawer('${editing.khuyenMaiID}'); });
</c:if>
</script>

</body>
</html>
