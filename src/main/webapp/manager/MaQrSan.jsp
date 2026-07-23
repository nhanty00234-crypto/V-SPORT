<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
<title>Mã QR sân — V-SPORT</title>
<jsp:include page="/manager/common/manager_head.jsp" />
<style>
  .qr-card { transition: box-shadow .15s, transform .15s; }
  .qr-card:hover { box-shadow: 0 4px 18px rgba(107,33,168,.08); }
  .status-pill { display:inline-flex; align-items:center; gap:5px; padding:3px 10px; border-radius:999px; font-size:11.5px; font-weight:700; }
  .status-active { background:#ecfdf5; color:#047857; }
  .status-disabled { background:#fef3c7; color:#92400e; }
  .status-revoked { background:#fee2e2; color:#b91c1c; }
  .status-none { background:#f4f4f5; color:#71717a; }

  #qrDrawerOverlay { position:fixed; inset:0; background:rgba(24,10,46,.35); z-index:60; opacity:0; pointer-events:none; transition:opacity .18s; }
  #qrDrawerOverlay.open { opacity:1; pointer-events:auto; }
  #qrDrawer {
    position:fixed; top:0; right:0; height:100%; width:420px; max-width:100vw;
    background:#fff; z-index:61; transform:translateX(100%); transition:transform .22s ease;
    display:flex; flex-direction:column; box-shadow:-8px 0 30px rgba(0,0,0,.12);
  }
  #qrDrawer.open { transform:translateX(0); }
  #qrDrawer .drawer-body { flex:1; overflow-y:auto; }
  #qrDrawer .drawer-actions { position:sticky; bottom:0; background:#fff; border-top:1px solid #f0e9fb; }

  @media (max-width: 640px) {
    #qrDrawer { width:100vw; }
    .desktop-table { display:none; }
  }
  @media (min-width: 641px) {
    .mobile-cards { display:none; }
  }

  /* Modal regenerate */
  #regenModalOverlay { position:fixed; inset:0; background:rgba(24,10,46,.45); z-index:70; display:none; align-items:center; justify-content:center; padding:16px; }
  #regenModalOverlay.open { display:flex; }
</style>
</head>
<body class="text-zinc-900 min-h-screen">

<jsp:include page="/manager/common/sidebar.jsp" />

<c:set var="headerTitle" value="Quản lý mã QR sân" scope="page" />
<c:set var="headerSubtitle" value="Cơ sở CS${managerCoSoId}" scope="page" />
<c:set var="headerIcon" value="qr_code_2" scope="page" />
<jsp:include page="/manager/common/header.jsp" />

<main class="lg:ml-[248px] mt-[64px] p-4 lg:p-6 flex flex-col gap-5">

  <section class="flex flex-col sm:flex-row sm:items-start sm:justify-between gap-3">
    <div>
      <h2 class="text-2xl font-black tracking-tight text-purple-950">Mã QR sân</h2>
      <p class="text-sm text-zinc-500 mt-1 max-w-xl">Tạo, quản lý và in mã QR để khách hàng gọi nhân viên, yêu cầu dịch vụ hoặc thanh toán tại từng sân.</p>
    </div>
    <div class="flex items-center gap-2 shrink-0 flex-wrap">
      <a href="${pageContext.request.contextPath}/staff/yeu-cau-qr" class="h-11 px-4 rounded-xl border border-purple-200 bg-white text-purple-700 text-sm font-semibold hover:bg-purple-50 flex items-center gap-1.5">
        <span class="material-symbols-outlined text-[16px]">inbox</span>Yêu cầu từ QR
        <span id="badge-qr-req" class="hidden bg-purple-600 text-white text-[10px] font-extrabold px-1.5 py-0.5 rounded-full leading-none"></span>
      </a>
      <button id="btnBatchPrint" disabled onclick="openBatchPrint()" class="h-11 px-4 rounded-xl border border-purple-200 bg-white text-purple-700 text-sm font-semibold hover:bg-purple-50 disabled:opacity-40 disabled:pointer-events-none">
        In hàng loạt
      </button>
      <button id="btnBatchCreate" onclick="batchCreate()" class="h-11 px-4 rounded-xl bg-purple-600 text-white text-sm font-semibold shadow-md shadow-purple-200 hover:bg-purple-700 flex items-center gap-1.5">
        <span class="material-symbols-outlined text-[16px]">bolt</span>Tạo QR cho các sân chưa có
      </button>
    </div>
  </section>

  <!-- Stat cards -->
  <section class="grid grid-cols-2 lg:grid-cols-4 gap-3">
    <div class="qr-card bg-white border border-purple-100 rounded-2xl p-4">
      <p class="text-[11px] font-bold uppercase text-zinc-400 tracking-wide">Tổng số sân</p>
      <p class="text-2xl font-black text-purple-950 mt-1" id="statTotal">${stats.total}</p>
    </div>
    <div class="qr-card bg-white border border-purple-100 rounded-2xl p-4">
      <p class="text-[11px] font-bold uppercase text-zinc-400 tracking-wide">QR đang hoạt động</p>
      <p class="text-2xl font-black text-emerald-600 mt-1" id="statActive">${stats.active}</p>
    </div>
    <div class="qr-card bg-white border border-purple-100 rounded-2xl p-4">
      <p class="text-[11px] font-bold uppercase text-zinc-400 tracking-wide">QR đang tắt</p>
      <p class="text-2xl font-black text-amber-600 mt-1" id="statDisabled">${stats.disabled}</p>
    </div>
    <div class="qr-card bg-white border border-purple-100 rounded-2xl p-4">
      <p class="text-[11px] font-bold uppercase text-zinc-400 tracking-wide">Sân chưa có QR</p>
      <p class="text-2xl font-black text-zinc-500 mt-1" id="statNone">${stats.none}</p>
    </div>
  </section>

  <!-- Filter bar -->
  <section class="bg-white border border-purple-100 rounded-2xl p-3.5 flex flex-wrap items-center gap-2.5">
    <input id="fSearch" type="text" placeholder="Tìm tên sân..." class="h-10 px-3.5 rounded-xl border border-zinc-200 text-sm flex-1 min-w-[160px]">
    <select id="fQrStatus" class="h-10 px-3 rounded-xl border border-zinc-200 text-sm">
      <option value="ALL">Tất cả trạng thái QR</option>
      <option value="ACTIVE">Đang hoạt động</option>
      <option value="DISABLED">Đang tắt</option>
      <option value="NONE">Chưa tạo</option>
      <option value="REVOKED">Đã vô hiệu hóa</option>
    </select>
    <button onclick="applyFilters()" class="h-10 px-4 rounded-xl bg-purple-600 text-white text-sm font-semibold hover:bg-purple-700">Lọc</button>
    <button onclick="clearFilters()" class="h-10 px-4 rounded-xl border border-zinc-200 text-sm font-semibold text-zinc-600 hover:bg-zinc-50">Xóa lọc</button>
  </section>

  <!-- Desktop table -->
  <section class="desktop-table bg-white border border-purple-100 rounded-2xl overflow-hidden">
    <table class="w-full text-sm">
      <thead class="bg-purple-50/60 text-purple-900">
        <tr class="text-left">
          <th class="p-3 w-10"><input type="checkbox" id="checkAll" onchange="toggleAll(this)"></th>
          <th class="p-3">Tên sân</th>
          <th class="p-3">Môn thể thao</th>
          <th class="p-3">Trạng thái sân</th>
          <th class="p-3">Trạng thái QR</th>
          <th class="p-3">Short code</th>
          <th class="p-3">Cập nhật</th>
          <th class="p-3 text-right">Thao tác</th>
        </tr>
      </thead>
      <tbody id="tbody">
      <c:forEach var="row" items="${dsQr}">
        <tr class="border-t border-purple-50 qr-row" data-san="${row.sanId}">
          <td class="p-3"><c:if test="${row.canPrint}"><input type="checkbox" class="rowCheck" value="${row.sanId}" onchange="onRowCheck()"></c:if></td>
          <td class="p-3 font-semibold">${row.tenSan}</td>
          <td class="p-3 text-zinc-500">${row.tenMonTheThao}</td>
          <td class="p-3 text-zinc-500">${row.trangThaiSan}</td>
          <td class="p-3">
            <span class="status-pill ${row.qrStatus == 'ACTIVE' ? 'status-active' : row.qrStatus == 'DISABLED' ? 'status-disabled' : row.qrStatus == 'REVOKED' ? 'status-revoked' : 'status-none'}">${row.qrStatusLabel}</span>
          </td>
          <td class="p-3 font-mono text-xs text-zinc-500">${row.maskedShortCode}</td>
          <td class="p-3 text-zinc-400 text-xs"><fmt:formatDate value="${row.updatedAt}" pattern="dd/MM/yyyy HH:mm"/></td>
          <td class="p-3 text-right">
            <button onclick="openDrawer(${row.sanId})" class="h-8 px-3 rounded-lg border border-purple-200 text-purple-700 text-xs font-semibold hover:bg-purple-50">Xem QR</button>
          </td>
        </tr>
      </c:forEach>
      </tbody>
    </table>
  </section>

  <!-- Mobile cards -->
  <section class="mobile-cards flex flex-col gap-2.5">
    <c:forEach var="row" items="${dsQr}">
      <div class="qr-card bg-white border border-purple-100 rounded-2xl p-3.5 flex items-center justify-between gap-3">
        <div class="min-w-0">
          <p class="font-semibold truncate">${row.tenSan}</p>
          <p class="text-xs text-zinc-400 truncate">${row.tenMonTheThao}</p>
          <span class="status-pill mt-1 ${row.qrStatus == 'ACTIVE' ? 'status-active' : row.qrStatus == 'DISABLED' ? 'status-disabled' : row.qrStatus == 'REVOKED' ? 'status-revoked' : 'status-none'}">${row.qrStatusLabel}</span>
        </div>
        <button onclick="openDrawer(${row.sanId})" class="h-10 px-3.5 rounded-xl border border-purple-200 text-purple-700 text-xs font-semibold shrink-0">Xem QR</button>
      </div>
    </c:forEach>
  </section>

</main>

<!-- Drawer -->
<div id="qrDrawerOverlay" onclick="closeDrawer()"></div>
<div id="qrDrawer" role="dialog" aria-modal="true" aria-label="Chi tiết mã QR sân">
  <div class="p-4 border-b border-purple-50 flex items-center justify-between">
    <h3 class="font-black text-purple-950">Chi tiết mã QR</h3>
    <button aria-label="Đóng" onclick="closeDrawer()" class="h-11 w-11 rounded-full hover:bg-zinc-100 flex items-center justify-center">
      <span class="material-symbols-outlined text-[20px]">close</span>
    </button>
  </div>
  <div class="drawer-body p-4 flex flex-col gap-4">
    <div class="flex flex-col items-center gap-2">
      <img id="drawerQrImg" src="" alt="Mã QR sân" style="width:220px;height:220px;object-fit:contain;border:1px solid #f0e9fb;border-radius:12px;">
      <p id="drawerFullCode" class="font-mono text-sm text-zinc-600"></p>
    </div>
    <div class="text-sm grid grid-cols-2 gap-y-2">
      <span class="text-zinc-400">Sân</span><span id="drawerTenSan" class="text-right font-semibold"></span>
      <span class="text-zinc-400">Trạng thái QR</span><span id="drawerQrStatus" class="text-right"></span>
      <span class="text-zinc-400">Ngày tạo</span><span id="drawerCreatedAt" class="text-right"></span>
      <span class="text-zinc-400">Số lần tạo lại</span><span id="drawerRegenCount" class="text-right"></span>
    </div>
    <p class="text-xs text-zinc-400 bg-zinc-50 rounded-xl p-3">Khách hàng quét mã hoặc nhập mã ngắn dự phòng để gọi nhân viên, yêu cầu dịch vụ hoặc thanh toán tại sân.</p>
  </div>
  <div class="drawer-actions p-4 flex flex-col gap-2">
    <div id="drawerActionsRow" class="flex gap-2"></div>
  </div>
</div>

<!-- Regenerate confirm modal -->
<div id="regenModalOverlay">
  <div class="bg-white rounded-2xl p-5 max-w-sm w-full" role="dialog" aria-modal="true" aria-labelledby="regenTitle">
    <h4 id="regenTitle" class="font-black text-lg text-red-700 mb-2">Tạo lại mã QR?</h4>
    <p class="text-sm text-zinc-600 mb-4">Mã QR cũ và mã dự phòng cũ sẽ ngừng hoạt động ngay lập tức. Các bản in cũ sẽ không còn sử dụng được. Bạn có chắc muốn tiếp tục?</p>
    <div class="flex justify-end gap-2">
      <button onclick="closeRegenModal()" class="h-10 px-4 rounded-xl border border-zinc-200 text-sm font-semibold">Hủy</button>
      <button id="btnConfirmRegen" onclick="confirmRegenerate()" class="h-10 px-4 rounded-xl bg-red-600 text-white text-sm font-semibold hover:bg-red-700">Tạo lại mã</button>
    </div>
  </div>
</div>

<script>
const CTX = "${pageContext.request.contextPath}";
let currentSanId = null;

(function pollBadge() {
  fetch(CTX + '/api/staff/yeu-cau-qr/count')
    .then(r => r.json())
    .then(res => {
      const el = document.getElementById('badge-qr-req');
      if (el && res.success && res.data.count > 0) {
        el.textContent = res.data.count;
        el.classList.remove('hidden');
      } else if (el) {
        el.classList.add('hidden');
      }
    })
    .catch(() => {})
    .finally(() => setTimeout(pollBadge, 15000));
})();
let currentRowData = null;

function applyFilters() {
  const search = document.getElementById('fSearch').value;
  const qrStatus = document.getElementById('fQrStatus').value;
  const url = new URL(window.location.href.split('?')[0]);
  if (search) url.searchParams.set('search', search);
  if (qrStatus && qrStatus !== 'ALL') url.searchParams.set('qrStatus', qrStatus);
  window.location.href = url.toString();
}
function clearFilters() { window.location.href = CTX + '/manager/ma-qr-san'; }

function toggleAll(cb) {
  document.querySelectorAll('.rowCheck').forEach(c => c.checked = cb.checked);
  onRowCheck();
}
function onRowCheck() {
  const any = document.querySelectorAll('.rowCheck:checked').length > 0;
  document.getElementById('btnBatchPrint').disabled = !any;
}
function openBatchPrint() {
  const ids = Array.from(document.querySelectorAll('.rowCheck:checked')).map(c => c.value);
  if (!ids.length) return;
  const form = document.createElement('form');
  form.method = 'POST';
  form.action = CTX + '/manager/ma-qr-san-in-hang-loat';
  form.target = '_blank';
  ids.forEach(id => {
    const inp = document.createElement('input');
    inp.type = 'hidden'; inp.name = 'sanIds'; inp.value = id;
    form.appendChild(inp);
  });
  document.body.appendChild(form);
  form.submit();
  form.remove();
}

async function batchCreate() {
  const btn = document.getElementById('btnBatchCreate');
  btn.disabled = true;
  try {
    const res = await fetch(CTX + '/manager/ma-qr-san', {
      method: 'POST',
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: 'action=batchCreate'
    });
    const data = await res.json();
    if (data.success) {
      alert('Đã tạo ' + data.created + ' mã QR mới. ' + data.alreadyExisted + ' sân đã có sẵn mã.' + (data.failed ? ' ' + data.failed + ' sân lỗi.' : ''));
      window.location.reload();
    } else {
      alert(data.error || 'Không thể tạo QR hàng loạt.');
    }
  } finally {
    btn.disabled = false;
  }
}

function rowStatusLabel(status) {
  if (status === 'ACTIVE') return 'Đang hoạt động';
  if (status === 'DISABLED') return 'Đang tắt';
  if (status === 'REVOKED') return 'Đã vô hiệu hóa';
  return 'Chưa tạo';
}

function openDrawer(sanId) {
  currentSanId = sanId;
  const row = document.querySelector('.qr-row[data-san="' + sanId + '"]');
  document.getElementById('drawerTenSan').textContent = row ? row.children[1].textContent.trim() : '';
  document.getElementById('drawerQrImg').src = CTX + '/manager/ma-qr-san-anh?sanId=' + sanId + '&mode=preview&t=' + Date.now();
  document.getElementById('qrDrawerOverlay').classList.add('open');
  document.getElementById('qrDrawer').classList.add('open');
  document.body.style.overflow = 'hidden';
  refreshDrawerActions(row);
  document.addEventListener('keydown', escCloseHandler);
}
function escCloseHandler(e) { if (e.key === 'Escape') closeDrawer(); }
function closeDrawer() {
  document.getElementById('qrDrawerOverlay').classList.remove('open');
  document.getElementById('qrDrawer').classList.remove('open');
  document.body.style.overflow = '';
  document.removeEventListener('keydown', escCloseHandler);
}

function refreshDrawerActions(row) {
  const actionsRow = document.getElementById('drawerActionsRow');
  actionsRow.innerHTML = '';
  const statusCell = row ? row.querySelector('.status-pill') : null;
  const statusText = statusCell ? statusCell.textContent.trim() : 'Chưa tạo';
  document.getElementById('drawerQrStatus').textContent = statusText;

  const hasQr = statusText !== 'Chưa tạo';
  if (!hasQr) {
    actionsRow.appendChild(makeBtn('Tạo mã QR', 'bg-purple-600 text-white', () => doAction('create')));
    return;
  }
  if (statusText === 'Đã vô hiệu hóa') {
    actionsRow.innerHTML = '<p class="text-xs text-zinc-400">Mã đã bị vô hiệu hóa vĩnh viễn, chỉ có thể xem lịch sử.</p>';
    return;
  }
  actionsRow.appendChild(makeBtn('Tải PNG', 'border border-purple-200 text-purple-700', downloadPng));
  actionsRow.appendChild(makeBtn('In mã QR', 'border border-purple-200 text-purple-700', () => window.open(CTX + '/manager/ma-qr-san-in?sanId=' + currentSanId, '_blank')));
  if (statusText === 'Đang hoạt động') {
    actionsRow.appendChild(makeBtn('Tạm tắt', 'border border-amber-200 text-amber-700', () => doAction('disable')));
  } else {
    actionsRow.appendChild(makeBtn('Bật lại', 'border border-emerald-200 text-emerald-700', () => doAction('enable')));
  }
  actionsRow.appendChild(makeBtn('Tạo lại mã', 'bg-red-50 text-red-700', openRegenModal));
}
function makeBtn(label, cls, onClick) {
  const b = document.createElement('button');
  b.textContent = label;
  b.className = 'h-10 px-3 rounded-xl text-xs font-semibold ' + cls;
  b.onclick = onClick;
  return b;
}
function downloadPng() {
  window.location.href = CTX + '/manager/ma-qr-san-anh?sanId=' + currentSanId + '&mode=download';
}

let regenBusy = false;
function openRegenModal() { document.getElementById('regenModalOverlay').classList.add('open'); }
function closeRegenModal() { if (!regenBusy) document.getElementById('regenModalOverlay').classList.remove('open'); }
function confirmRegenerate() {
  if (regenBusy) return;
  regenBusy = true;
  document.getElementById('btnConfirmRegen').disabled = true;
  doAction('regenerate').finally(() => {
    regenBusy = false;
    document.getElementById('btnConfirmRegen').disabled = false;
    document.getElementById('regenModalOverlay').classList.remove('open');
  });
}

async function doAction(action) {
  const res = await fetch(CTX + '/manager/ma-qr-san', {
    method: 'POST',
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: 'action=' + encodeURIComponent(action) + '&sanId=' + encodeURIComponent(currentSanId)
  });
  const data = await res.json();
  if (!data.success) {
    alert(data.error || 'Thao tác thất bại.');
    return data;
  }
  window.location.reload();
  return data;
}
</script>

</body>
</html>
