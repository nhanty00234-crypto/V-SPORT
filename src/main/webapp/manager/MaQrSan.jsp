<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<!DOCTYPE html>
<html lang="vi">
<head>
<title>Mã QR sân — V-SPORT</title>
<jsp:include page="/manager/common/manager_head.jsp" />
<style>
  /* ── Grid ── */
  .qr-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(256px, 1fr));
    gap: 18px;
  }

  /* ── Card ── */
  .qr-card {
    background: #fff;
    border: 1.5px solid #ede9fe;
    border-radius: 22px;
    padding: 20px 18px 16px;
    display: flex;
    flex-direction: column;
    gap: 12px;
    transition: box-shadow .2s, transform .2s;
  }
  .qr-card:hover {
    box-shadow: 0 10px 36px -8px rgba(109,40,217,.18);
    transform: translateY(-3px);
  }

  /* ── QR frame (status ring) ── */
  .qr-frame {
    width: 100%;
    aspect-ratio: 1 / 1;
    max-width: 192px;
    margin: 0 auto;
    border-radius: 16px;
    display: flex;
    align-items: center;
    justify-content: center;
    overflow: hidden;
    position: relative;
  }
  .qr-frame img {
    width: 100%; height: 100%; object-fit: contain; display: block;
    border-radius: 14px;
  }
  .qr-frame.s-active  { box-shadow: 0 0 0 3px #059669, 0 0 16px 0 rgba(5,150,105,.18); }
  .qr-frame.s-disabled { box-shadow: 0 0 0 3px #d97706, 0 0 14px 0 rgba(217,119,6,.14); }
  .qr-frame.s-revoked  { box-shadow: 0 0 0 3px #dc2626, 0 0 14px 0 rgba(220,38,38,.12); background: #fef2f2; }
  .qr-frame.s-none     { border: 2px dashed #d4d4d8; background: #fafafa; }

  .qr-placeholder {
    display: flex; flex-direction: column; align-items: center; gap: 10px;
    padding: 20px; color: #a1a1aa; text-align: center;
  }
  .qr-placeholder .ph-icon {
    width: 56px; height: 56px; border-radius: 14px;
    background: #f5f3ff;
    display: flex; align-items: center; justify-content: center;
  }
  .qr-placeholder.ph-revoked .ph-icon { background: #fef2f2; }
  .qr-placeholder p { font-size: 12px; font-weight: 600; line-height: 1.4; }

  /* ── Status badge ── */
  .sbadge {
    display: inline-flex; align-items: center; gap: 5px;
    padding: 3px 10px; border-radius: 999px;
    font-size: 11px; font-weight: 700; letter-spacing: .01em;
  }
  .sbadge-dot { width: 6px; height: 6px; border-radius: 50%; flex-shrink: 0; }
  .sb-active   { background: #ecfdf5; color: #047857; }
  .sb-active .sbadge-dot   { background: #059669; }
  .sb-disabled { background: #fef3c7; color: #92400e; }
  .sb-disabled .sbadge-dot { background: #d97706; }
  .sb-revoked  { background: #fee2e2; color: #b91c1c; }
  .sb-revoked .sbadge-dot  { background: #dc2626; }
  .sb-none     { background: #f4f4f5; color: #71717a; }
  .sb-none .sbadge-dot     { background: #a1a1aa; }

  /* ── Action buttons ── */
  .card-actions { display: flex; gap: 6px; flex-wrap: wrap; }
  .cbtn {
    flex: 1; min-width: 0;
    height: 34px; border-radius: 10px;
    font-size: 11.5px; font-weight: 700;
    border: 1.5px solid transparent;
    cursor: pointer; transition: background .13s, transform .1s;
    display: flex; align-items: center; justify-content: center; gap: 3px;
    white-space: nowrap; padding: 0 8px;
  }
  .cbtn:active { transform: scale(.94); }
  .cbtn .material-symbols-outlined { font-size: 15px !important; }

  .cbtn-print  { background: #f5f3ff; border-color: #ddd6fe; color: #6d28d9; }
  .cbtn-print:hover  { background: #ede9fe; }
  .cbtn-dl     { background: #f5f3ff; border-color: #ddd6fe; color: #6d28d9; }
  .cbtn-dl:hover     { background: #ede9fe; }
  .cbtn-create { background: #7c3aed; color: #fff; border-color: #7c3aed; width: 100%; flex: none; }
  .cbtn-create:hover { background: #6d28d9; }

  /* ── More menu (⋯) ── */
  .more-wrap { position: relative; }
  .cbtn-more  { background: #fff; border-color: #e4e4e7; color: #71717a; padding: 0 10px; flex: none; width: 34px; }
  .cbtn-more:hover { background: #f4f4f5; }
  .more-menu {
    display: none; position: absolute; bottom: calc(100% + 6px); right: 0;
    background: #fff; border: 1.5px solid #ede9fe; border-radius: 14px;
    box-shadow: 0 8px 28px -6px rgba(109,40,217,.18);
    min-width: 180px; padding: 6px; z-index: 10;
  }
  .more-menu.open { display: block; }
  .more-item {
    display: flex; align-items: center; gap: 8px;
    padding: 9px 12px; border-radius: 9px;
    font-size: 13px; font-weight: 600; cursor: pointer;
    transition: background .12s; color: #3f3f46; border: none; background: none; width: 100%; text-align: left;
  }
  .more-item:hover { background: #f5f3ff; color: #6d28d9; }
  .more-item.danger { color: #b91c1c; }
  .more-item.danger:hover { background: #fef2f2; }
  .more-item .material-symbols-outlined { font-size: 16px !important; }

  /* ── Regen modal ── */
  #regenOverlay {
    position: fixed; inset: 0; background: rgba(15,5,35,.48);
    z-index: 70; display: none; align-items: center; justify-content: center; padding: 16px;
  }
  #regenOverlay.open { display: flex; }
  #regenConfirmInput {
    width: 100%; border: 1.5px solid #e4e4e7; border-radius: 10px;
    padding: 9px 12px; font-size: 14px; font-weight: 600; outline: none;
    transition: border-color .15s;
  }
  #regenConfirmInput:focus { border-color: #dc2626; }
  #regenConfirmInput.input-ok { border-color: #059669; background: #f0fdf4; }
</style>
</head>
<body class="text-zinc-900 min-h-screen">

<% pageContext.setAttribute("dtFmt", DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")); %>

<jsp:include page="/manager/common/sidebar.jsp" />

<c:set var="headerTitle" value="Mã QR sân" scope="page" />
<c:set var="headerIcon" value="qr_code_2" scope="page" />
<jsp:include page="/manager/common/header.jsp" />

<main class="lg:ml-[248px] mt-[64px] p-4 lg:p-6 flex flex-col gap-5">

  <!-- Page header -->
  <section class="flex flex-col sm:flex-row sm:items-start sm:justify-between gap-3">
    <div>
      <h2 class="text-2xl font-black tracking-tight text-purple-950">Mã QR sân</h2>
      <p class="text-sm text-zinc-500 mt-1 max-w-xl">Tạo, quản lý và in mã QR để khách hàng gọi nhân viên, yêu cầu dịch vụ hoặc thanh toán tại từng sân.</p>
    </div>
    <div class="flex items-center gap-2 shrink-0 flex-wrap">
      <a href="${pageContext.request.contextPath}/staff/yeu-cau-qr"
         class="h-11 px-4 rounded-xl border border-purple-200 bg-white text-purple-700 text-sm font-semibold hover:bg-purple-50 flex items-center gap-1.5 transition-colors">
        <span class="material-symbols-outlined text-[16px]">inbox</span>Yêu cầu từ QR
        <span id="badge-qr-req" class="hidden bg-purple-600 text-white text-[10px] font-extrabold px-1.5 py-0.5 rounded-full leading-none"></span>
      </a>
      <button onclick="batchCreate(this)"
              class="h-11 px-4 rounded-xl bg-purple-600 text-white text-sm font-semibold shadow-md shadow-purple-200 hover:bg-purple-700 flex items-center gap-1.5 transition-colors">
        <span class="material-symbols-outlined text-[16px]">bolt</span>Tạo QR cho sân chưa có
      </button>
    </div>
  </section>

  <!-- Stats -->
  <section class="grid grid-cols-3 gap-3">
    <div class="bg-white border border-purple-100 rounded-2xl p-4">
      <p class="text-[11px] font-bold text-zinc-400">Tổng số sân</p>
      <p class="text-2xl font-black text-purple-950 mt-1">${stats.total}</p>
    </div>
    <div class="bg-white border border-emerald-100 rounded-2xl p-4">
      <p class="text-[11px] font-bold text-zinc-400">QR đang hoạt động</p>
      <p class="text-2xl font-black text-emerald-600 mt-1">${stats.active}</p>
    </div>
    <div class="bg-white border border-zinc-200 rounded-2xl p-4">
      <p class="text-[11px] font-bold text-zinc-400">Sân chưa có QR</p>
      <p class="text-2xl font-black text-zinc-500 mt-1">${stats.none}</p>
    </div>
  </section>

  <!-- Filter bar -->
  <section class="bg-white border border-purple-100 rounded-2xl p-3.5 flex flex-wrap items-center gap-2.5">
    <input id="fSearch" type="text" placeholder="Tìm tên sân..."
           value="${param.search}"
           class="h-10 px-3.5 rounded-xl border border-zinc-200 text-sm flex-1 min-w-[160px] focus:outline-none focus:border-purple-400">
    <select id="fQrStatus" class="h-10 px-3 rounded-xl border border-zinc-200 text-sm focus:outline-none focus:border-purple-400">
      <option value="ALL">Tất cả trạng thái QR</option>
      <option value="ACTIVE"   ${param.qrStatus == 'ACTIVE'   ? 'selected' : ''}>Đang hoạt động</option>
      <option value="NONE"     ${param.qrStatus == 'NONE'     ? 'selected' : ''}>Chưa tạo</option>
      <option value="REVOKED"  ${param.qrStatus == 'REVOKED'  ? 'selected' : ''}>Đã vô hiệu hóa</option>
    </select>
    <button onclick="applyFilters()" class="h-10 px-4 rounded-xl bg-purple-600 text-white text-sm font-semibold hover:bg-purple-700 transition-colors">Lọc</button>
    <button onclick="clearFilters()" class="h-10 px-4 rounded-xl border border-zinc-200 text-sm font-semibold text-zinc-600 hover:bg-zinc-50 transition-colors">Xóa lọc</button>
  </section>

  <!-- Card grid -->
  <section class="qr-grid">

    <c:forEach var="row" items="${dsQr}">

      <%-- Derive CSS classes for frame & badge --%>
      <c:set var="frameCs" value="s-none" />
      <c:set var="badgeCs" value="sb-none" />
      <c:if test="${row.qrStatus == 'ACTIVE'}">
        <c:set var="frameCs" value="s-active" />
        <c:set var="badgeCs" value="sb-active" />
      </c:if>
      <c:if test="${row.qrStatus == 'DISABLED'}">
        <c:set var="frameCs" value="s-disabled" />
        <c:set var="badgeCs" value="sb-disabled" />
      </c:if>
      <c:if test="${row.qrStatus == 'REVOKED'}">
        <c:set var="frameCs" value="s-revoked" />
        <c:set var="badgeCs" value="sb-revoked" />
      </c:if>

      <div class="qr-card">

        <!-- Court name -->
        <div>
          <p class="font-extrabold text-purple-950 text-[15px] leading-snug">${row.tenSan}</p>
          <p class="text-xs text-zinc-400 mt-0.5 truncate">
            <c:choose>
              <c:when test="${not empty row.tenMonTheThao}">${row.tenMonTheThao} · </c:when>
            </c:choose>
            ${row.trangThaiSan}
          </p>
        </div>

        <!-- QR image (signature: colored status ring) -->
        <div class="qr-frame ${frameCs}">
          <c:choose>
            <c:when test="${row.hasQr and row.qrStatus != 'REVOKED'}">
              <img src="${pageContext.request.contextPath}/manager/ma-qr-san-anh?sanId=${row.sanId}&amp;mode=preview&amp;t=${row.sanId}"
                   alt="QR ${row.tenSan}" loading="lazy"
                   onerror="this.closest('.qr-frame').innerHTML='<div class=\'qr-placeholder\'><div class=\'ph-icon\'><span class=\'material-symbols-outlined\' style=\'font-size:28px;color:#a78bfa\'>qr_code_2</span></div><p>Lỗi tải ảnh</p></div>'" />
            </c:when>
            <c:when test="${row.qrStatus == 'REVOKED'}">
              <div class="qr-placeholder ph-revoked">
                <div class="ph-icon">
                  <span class="material-symbols-outlined" style="font-size:28px;color:#f87171">block</span>
                </div>
                <p style="color:#b91c1c">Đã vô hiệu hóa</p>
              </div>
            </c:when>
            <c:otherwise>
              <div class="qr-placeholder">
                <div class="ph-icon">
                  <span class="material-symbols-outlined" style="font-size:28px;color:#8b5cf6">qr_code_2_add</span>
                </div>
                <p>Chưa có mã QR</p>
              </div>
            </c:otherwise>
          </c:choose>
        </div>

        <!-- Short code + status badge -->
        <div class="flex items-center justify-between gap-2">
          <span class="font-mono text-xs text-zinc-500 truncate">
            <c:choose>
              <c:when test="${not empty row.maskedShortCode}">${row.maskedShortCode}</c:when>
              <c:otherwise>—</c:otherwise>
            </c:choose>
          </span>
          <span class="sbadge ${badgeCs} shrink-0">
            <span class="sbadge-dot"></span>${row.qrStatusLabel}
          </span>
        </div>

        <!-- Updated timestamp -->
        <c:if test="${row.updatedAt != null}">
          <p class="text-[11px] text-zinc-400 -mt-1">
            <span class="material-symbols-outlined" style="font-size:11px;vertical-align:middle">schedule</span>
            ${row.updatedAt.format(dtFmt)}
          </p>
        </c:if>

        <!-- Actions -->
        <div class="card-actions">
          <c:choose>

            <c:when test="${!row.hasQr}">
              <button class="cbtn cbtn-create" onclick="doAction(${row.sanId}, 'create')">
                <span class="material-symbols-outlined">add_circle</span>Tạo mã QR
              </button>
            </c:when>

            <c:when test="${row.qrStatus == 'REVOKED'}">
              <p class="text-[11px] text-zinc-400 w-full text-center py-1">Mã bị vô hiệu hóa vĩnh viễn.</p>
            </c:when>

            <c:otherwise>
              <button class="cbtn cbtn-print" onclick="printQR(${row.sanId})" title="In mã QR">
                <span class="material-symbols-outlined">print</span>In
              </button>
              <button class="cbtn cbtn-dl" onclick="downloadQR(${row.sanId})" title="Tải PNG">
                <span class="material-symbols-outlined">download</span>PNG
              </button>
              <%-- Tạo lại nằm trong menu ⋯ — tránh bấm nhầm vì QR cũ sẽ chết vĩnh viễn --%>
              <div class="more-wrap">
                <button class="cbtn cbtn-more" onclick="toggleMoreMenu(this)" title="Thêm">
                  <span class="material-symbols-outlined" style="font-size:18px!important">more_horiz</span>
                </button>
                <div class="more-menu">
                  <button class="more-item danger" onclick="openRegen(${row.sanId}, '${row.tenSan}'); closeAllMenus()">
                    <span class="material-symbols-outlined">refresh</span>Tạo lại mã QR
                  </button>
                  <div style="margin:4px 0;border-top:1px solid #f0e9fb"></div>
                  <p style="font-size:11px;color:#a1a1aa;padding:4px 12px 6px;line-height:1.5">
                    ⚠ QR đã in sẽ không dùng được sau khi tạo lại.
                  </p>
                </div>
              </div>
            </c:otherwise>

          </c:choose>
        </div>

      </div>
    </c:forEach>

    <!-- Empty state -->
    <c:if test="${empty dsQr}">
      <div style="grid-column:1/-1" class="flex flex-col items-center gap-3 py-20 text-zinc-400">
        <span class="material-symbols-outlined" style="font-size:56px;opacity:.4">qr_code_2</span>
        <p class="font-semibold text-sm">Không tìm thấy sân nào phù hợp với bộ lọc.</p>
        <button onclick="clearFilters()" class="mt-1 text-purple-600 text-sm font-semibold hover:underline">Xóa bộ lọc</button>
      </div>
    </c:if>

  </section>

</main>

<!-- Regenerate confirm modal -->
<div id="regenOverlay" onclick="onOverlayClick(event)">
  <div class="bg-white rounded-2xl p-6 max-w-sm w-full shadow-2xl" role="dialog" aria-modal="true">

    <div class="flex items-center gap-3 mb-4">
      <div class="w-11 h-11 rounded-full bg-red-100 flex items-center justify-center shrink-0">
        <span class="material-symbols-outlined text-red-600" style="font-size:22px">warning</span>
      </div>
      <div>
        <h4 class="font-black text-base text-red-700">Tạo lại mã QR?</h4>
        <p id="regenSanName" class="text-xs text-zinc-500 font-semibold mt-0.5"></p>
      </div>
    </div>

    <div class="bg-red-50 border border-red-200 rounded-xl p-3 mb-4 space-y-1.5">
      <p class="text-sm font-bold text-red-800 flex items-center gap-1.5">
        <span class="material-symbols-outlined" style="font-size:15px">qr_code</span>
        Tất cả QR đã in ra sẽ chết vĩnh viễn
      </p>
      <p class="text-xs text-red-700 leading-relaxed">
        Khách hàng quét QR cũ sẽ thấy thông báo <em>"Mã QR đã hết hiệu lực"</em>.
        Bạn phải <strong>in lại và dán lại</strong> tại tất cả vị trí trong sân.
      </p>
    </div>

    <p class="text-xs text-zinc-500 mb-1.5 font-semibold">Gõ tên sân để xác nhận:</p>
    <input id="regenConfirmInput" type="text"
           placeholder="Nhập tên sân..."
           oninput="onRegenInput()"
           autocomplete="off"
           class="mb-4" />

    <div class="flex justify-end gap-2">
      <button onclick="closeRegen()" class="h-10 px-4 rounded-xl border border-zinc-200 text-sm font-semibold hover:bg-zinc-50">Hủy</button>
      <button id="btnConfirmRegen" onclick="confirmRegen()" disabled
              class="h-10 px-5 rounded-xl bg-red-600 text-white text-sm font-semibold transition-colors disabled:opacity-40 disabled:pointer-events-none hover:bg-red-700">
        Tạo lại mã
      </button>
    </div>

  </div>
</div>

<script>
const CTX = "${pageContext.request.contextPath}";
let regenSanId = null, regenSanName = null, regenBusy = false;

/* ── Badge poll ── */
(function pollBadge() {
  fetch(CTX + '/api/staff/yeu-cau-qr/count')
    .then(r => r.json())
    .then(res => {
      const el = document.getElementById('badge-qr-req');
      if (!el) return;
      if (res.success && res.data && res.data.count > 0) {
        el.textContent = res.data.count; el.classList.remove('hidden');
      } else { el.classList.add('hidden'); }
    })
    .catch(() => {})
    .finally(() => setTimeout(pollBadge, 15000));
})();

/* ── Filters ── */
function applyFilters() {
  const search = document.getElementById('fSearch').value.trim();
  const qrStatus = document.getElementById('fQrStatus').value;
  const url = new URL(location.href.split('?')[0]);
  if (search) url.searchParams.set('search', search);
  if (qrStatus && qrStatus !== 'ALL') url.searchParams.set('qrStatus', qrStatus);
  location.href = url.toString();
}
function clearFilters() { location.href = CTX + '/manager/ma-qr-san'; }

document.getElementById('fSearch').addEventListener('keydown', e => { if (e.key === 'Enter') applyFilters(); });

/* ── Print / Download ── */
function printQR(sanId) { window.open(CTX + '/manager/ma-qr-san-in?sanId=' + sanId, '_blank'); }
function downloadQR(sanId) { location.href = CTX + '/manager/ma-qr-san-anh?sanId=' + sanId + '&mode=download'; }

/* ── More menu (⋯) ── */
function toggleMoreMenu(btn) {
  const menu = btn.nextElementSibling;
  const isOpen = menu.classList.contains('open');
  closeAllMenus();
  if (!isOpen) menu.classList.add('open');
}
function closeAllMenus() {
  document.querySelectorAll('.more-menu.open').forEach(m => m.classList.remove('open'));
}
document.addEventListener('click', e => {
  if (!e.target.closest('.more-wrap')) closeAllMenus();
});

/* ── Regen modal ── */
function openRegen(sanId, sanName) {
  regenSanId = sanId;
  regenSanName = (sanName || '').trim();
  document.getElementById('regenSanName').textContent = regenSanName;
  const inp = document.getElementById('regenConfirmInput');
  inp.value = '';
  inp.classList.remove('input-ok');
  document.getElementById('btnConfirmRegen').disabled = true;
  document.getElementById('regenOverlay').classList.add('open');
  setTimeout(() => inp.focus(), 60);
}
function onRegenInput() {
  const inp = document.getElementById('regenConfirmInput');
  const match = inp.value.trim().toLowerCase() === regenSanName.toLowerCase() && regenSanName.length > 0;
  inp.classList.toggle('input-ok', match);
  document.getElementById('btnConfirmRegen').disabled = !match;
}
function closeRegen() {
  if (regenBusy) return;
  document.getElementById('regenOverlay').classList.remove('open');
}
function onOverlayClick(e) { if (e.target === document.getElementById('regenOverlay')) closeRegen(); }
document.addEventListener('keydown', e => { if (e.key === 'Escape') { closeRegen(); closeAllMenus(); } });

async function confirmRegen() {
  if (regenBusy) return;
  const inp = document.getElementById('regenConfirmInput');
  if (inp.value.trim().toLowerCase() !== regenSanName.toLowerCase()) return;
  regenBusy = true;
  const btn = document.getElementById('btnConfirmRegen');
  btn.disabled = true; btn.textContent = 'Đang xử lý…';
  try {
    await doAction(regenSanId, 'regenerate');
  } finally {
    regenBusy = false; btn.disabled = false; btn.textContent = 'Tạo lại mã';
    closeRegen();
  }
}

/* ── Core action ── */
async function doAction(sanId, action) {
  const res = await fetch(CTX + '/manager/ma-qr-san', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: 'action=' + encodeURIComponent(action) + '&sanId=' + encodeURIComponent(sanId)
  });
  const data = await res.json();
  if (!data.success) { alert(data.error || 'Thao tác thất bại.'); return; }
  location.reload();
}

/* ── Batch create ── */
async function batchCreate(btn) {
  btn.disabled = true;
  try {
    const res = await fetch(CTX + '/manager/ma-qr-san', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: 'action=batchCreate'
    });
    const data = await res.json();
    if (data.success) {
      const msg = 'Đã tạo ' + data.created + ' mã QR mới.'
        + (data.alreadyExisted ? ' ' + data.alreadyExisted + ' sân đã có sẵn mã.' : '')
        + (data.failed ? ' ' + data.failed + ' sân lỗi.' : '');
      alert(msg);
      location.reload();
    } else {
      alert(data.error || 'Không thể tạo QR hàng loạt.');
    }
  } finally { btn.disabled = false; }
}
</script>

</body>
</html>
