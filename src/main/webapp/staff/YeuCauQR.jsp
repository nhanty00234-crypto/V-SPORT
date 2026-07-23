<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
<title>Yêu cầu từ QR — V-SPORT</title>
<jsp:include page="/staff/common/staff_head.jsp" />
<style>
  .req-card {
    background: #fff;
    border: 1px solid #ffedd5;
    border-radius: 18px;
    padding: 18px 20px;
    transition: box-shadow .18s, transform .18s;
    animation: fadeUp .3s ease both;
  }
  .req-card:hover { box-shadow: 0 6px 24px -6px rgba(234,88,12,.13); transform: translateY(-2px); }
  .req-card.card-new    { border-left: 4px solid #3b82f6; }
  .req-card.card-progress { border-left: 4px solid #f59e0b; }
  .req-card.card-done   { border-left: 4px solid #16a34a; }
  .req-card.card-cancel { border-left: 4px solid #dc2626; }

  .type-icon {
    width: 44px; height: 44px; border-radius: 14px;
    display: flex; align-items: center; justify-content: center;
    flex-shrink: 0;
    font-size: 22px;
  }
  .type-icon.call   { background: #eff6ff; color: #2563eb; }
  .type-icon.order  { background: #fff7ed; color: #ea580c; }
  .type-icon.service { background: #f0fdf4; color: #16a34a; }

  .tab-pill {
    display: inline-flex; align-items: center; gap: 6px;
    padding: 8px 16px; border-radius: 12px; border: 1.5px solid #e4e4e7;
    background: #fff; cursor: pointer; font-size: 13px; font-weight: 600;
    color: #71717a; transition: all .15s;
  }
  .tab-pill:hover { border-color: #f97316; color: #ea580c; background: #fff7ed; }
  .tab-pill.active { border-color: #ea580c; color: #ea580c; background: #fff7ed; }
  .tab-pill .cnt {
    background: #ea580c; color: #fff; font-size: 10px; font-weight: 800;
    padding: 2px 6px; border-radius: 999px; line-height: 1;
    display: none;
  }
  .tab-pill.active .cnt { display: inline; }
  .tab-pill.has-count .cnt { display: inline; }

  .action-btn {
    padding: 7px 14px; border: none; border-radius: 10px;
    font-weight: 700; font-size: 12px; cursor: pointer; transition: all .15s;
  }
  .action-btn:active { transform: scale(.96); }
  .btn-start    { background: #eff6ff; color: #1d4ed8; }
  .btn-start:hover { background: #dbeafe; }
  .btn-complete { background: #f0fdf4; color: #15803d; }
  .btn-complete:hover { background: #dcfce7; }
  .btn-cancel   { background: #fef2f2; color: #b91c1c; }
  .btn-cancel:hover { background: #fee2e2; }

  #emptyState { text-align: center; padding: 60px 20px; color: #a1a1aa; }
  #emptyState .icon { font-size: 52px; margin-bottom: 12px; opacity: .5; }
  #emptyState p { font-size: 14px; font-weight: 600; }

  .items-chip {
    display: inline-flex; align-items: center; gap: 5px;
    background: #fff7ed; border: 1px solid #fed7aa;
    border-radius: 8px; padding: 3px 9px; font-size: 12px; font-weight: 600; color: #9a3412;
  }

  .time-label { font-size: 11.5px; color: #a1a1aa; font-weight: 500; }
</style>
</head>
<body class="text-zinc-900 min-h-screen">

<jsp:include page="/staff/common/sidebar.jsp" />

<header class="h-[64px] fixed top-0 right-0 left-0 lg:left-[248px] bg-white/80 backdrop-blur-lg border-b border-orange-100 z-20 flex items-center justify-between px-4 lg:px-6">
  <div class="flex items-center gap-3">
    <button id="mobileMenuBtn" class="lg:hidden p-2 rounded-lg hover:bg-orange-50 text-orange-650">
      <span class="material-symbols-outlined text-[20px]">menu</span>
    </button>
    <div>
      <h1 class="text-sm font-bold text-orange-950 tracking-tight">Yêu cầu từ QR sân</h1>
      <p class="text-xs text-orange-550 flex items-center gap-1">
        <span class="material-symbols-outlined text-[12px]">qr_code_scanner</span>
        Khách gọi nhân viên, gọi món, yêu cầu dịch vụ
      </p>
    </div>
  </div>
  <div class="flex items-center gap-1.5">
    <span id="liveDot" class="w-2 h-2 rounded-full bg-orange-400 live-dot"></span>
    <span class="text-xs text-orange-550 font-medium">Tự cập nhật</span>
    <div class="w-px h-6 border-l border-orange-100 mx-2"></div>
    <div class="text-xs font-semibold px-3 py-1 bg-orange-50 text-orange-700 rounded-lg">
      Vai trò: Lễ tân trực ca
    </div>
    <div class="w-px h-6 border-l border-orange-100 mx-1"></div>
    <jsp:include page="/manager/common/profile_dropdown.jsp" />
  </div>
</header>

<main class="lg:ml-[248px] mt-[64px] p-4 lg:p-6 flex flex-col gap-5">

  <!-- Stat summary row -->
  <section class="grid grid-cols-2 sm:grid-cols-4 gap-3">
    <div class="bg-white border border-blue-100 rounded-2xl p-4">
      <p class="text-[11px] font-bold uppercase text-zinc-400 tracking-wide">Mới</p>
      <p class="text-2xl font-black text-blue-600 mt-1" id="statNew">—</p>
    </div>
    <div class="bg-white border border-amber-100 rounded-2xl p-4">
      <p class="text-[11px] font-bold uppercase text-zinc-400 tracking-wide">Đang xử lý</p>
      <p class="text-2xl font-black text-amber-600 mt-1" id="statProgress">—</p>
    </div>
    <div class="bg-white border border-green-100 rounded-2xl p-4">
      <p class="text-[11px] font-bold uppercase text-zinc-400 tracking-wide">Hoàn thành</p>
      <p class="text-2xl font-black text-green-600 mt-1" id="statDone">—</p>
    </div>
    <div class="bg-white border border-red-100 rounded-2xl p-4">
      <p class="text-[11px] font-bold uppercase text-zinc-400 tracking-wide">Đã huỷ</p>
      <p class="text-2xl font-black text-red-500 mt-1" id="statCancel">—</p>
    </div>
  </section>

  <!-- Tabs -->
  <section class="flex flex-wrap gap-2">
    <button class="tab-pill active has-count" data-status="NEW" onclick="switchTab('NEW', this)">
      <span class="material-symbols-outlined text-[15px]">fiber_new</span>Mới
      <span class="cnt" id="cntNew">0</span>
    </button>
    <button class="tab-pill" data-status="IN_PROGRESS" onclick="switchTab('IN_PROGRESS', this)">
      <span class="material-symbols-outlined text-[15px]">pending</span>Đang xử lý
      <span class="cnt" id="cntProgress">0</span>
    </button>
    <button class="tab-pill" data-status="DONE" onclick="switchTab('DONE', this)">
      <span class="material-symbols-outlined text-[15px]">check_circle</span>Hoàn thành
      <span class="cnt" id="cntDone">0</span>
    </button>
    <button class="tab-pill" data-status="CANCELLED" onclick="switchTab('CANCELLED', this)">
      <span class="material-symbols-outlined text-[15px]">cancel</span>Đã huỷ
      <span class="cnt" id="cntCancel">0</span>
    </button>
  </section>

  <!-- Card list -->
  <section id="cardList" class="flex flex-col gap-3 min-h-[200px]">
    <div id="emptyState" class="hidden">
      <div class="icon"><span class="material-symbols-outlined" style="font-size:52px">inbox</span></div>
      <p id="emptyText">Không có yêu cầu nào.</p>
    </div>
  </section>

</main>

<script>
const CONTEXT = "${pageContext.request.contextPath}";
let currentStatus = 'NEW';
let pollTimer = null;

function escapeHtml(str) {
  if (str === null || str === undefined) return '';
  return String(str)
    .replace(/&/g, '&amp;').replace(/</g, '&lt;')
    .replace(/>/g, '&gt;').replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

function timeAgo(isoStr) {
  if (!isoStr) return '';
  const diff = Math.floor((Date.now() - new Date(isoStr).getTime()) / 1000);
  if (diff < 60)  return diff + 'giây trước';
  if (diff < 3600) return Math.floor(diff/60) + ' phút trước';
  if (diff < 86400) return Math.floor(diff/3600) + ' giờ trước';
  return Math.floor(diff/86400) + ' ngày trước';
}

function typeInfo(type) {
  if (type === 'CALL_STAFF') return { label: 'Gọi nhân viên', icon: 'support_agent', cls: 'call' };
  if (type === 'ORDER_ITEM')  return { label: 'Gọi món', icon: 'restaurant', cls: 'order' };
  return { label: 'Yêu cầu dịch vụ', icon: 'build', cls: 'service' };
}

function statusBadge(status) {
  if (status === 'NEW')         return '<span class="badge badge-blue">Mới</span>';
  if (status === 'IN_PROGRESS') return '<span class="badge badge-amber">Đang xử lý</span>';
  if (status === 'DONE')        return '<span class="badge badge-green">Hoàn thành</span>';
  return '<span class="badge badge-red">Đã huỷ</span>';
}

function cardClass(status) {
  if (status === 'NEW')         return 'card-new';
  if (status === 'IN_PROGRESS') return 'card-progress';
  if (status === 'DONE')        return 'card-done';
  return 'card-cancel';
}

function actionButtons(r) {
  if (r.status === 'NEW') {
    return `<button class="action-btn btn-start" onclick="doAction(\${r.requestId},'start')">
              <span class="material-symbols-outlined text-[14px] align-middle">play_arrow</span> Bắt đầu xử lý
            </button>
            <button class="action-btn btn-cancel" onclick="doAction(\${r.requestId},'cancel')">
              <span class="material-symbols-outlined text-[14px] align-middle">close</span> Huỷ
            </button>`;
  }
  if (r.status === 'IN_PROGRESS') {
    return `<button class="action-btn btn-complete" onclick="doAction(\${r.requestId},'complete')">
              <span class="material-symbols-outlined text-[14px] align-middle">check</span> Hoàn thành
            </button>
            <button class="action-btn btn-cancel" onclick="doAction(\${r.requestId},'cancel')">
              <span class="material-symbols-outlined text-[14px] align-middle">close</span> Huỷ
            </button>`;
  }
  return '';
}

function renderItems(itemsJson) {
  if (!itemsJson) return '';
  let items;
  try { items = JSON.parse(itemsJson); } catch { return `<span class="items-chip">\${escapeHtml(itemsJson)}</span>`; }
  if (!Array.isArray(items) || !items.length) return '';
  return items.map(it =>
    `<span class="items-chip">
       <span class="material-symbols-outlined text-[12px]">restaurant_menu</span>
       \${escapeHtml(it.tenSanPham || it.name || '?')}
       \${it.soLuong ? `<strong>×\${it.soLuong}</strong>` : ''}
     </span>`
  ).join(' ');
}

function renderCards(data) {
  const container = document.getElementById('cardList');
  const empty = document.getElementById('emptyState');

  if (!data.length) {
    container.innerHTML = '';
    container.appendChild(empty);
    empty.classList.remove('hidden');
    document.getElementById('emptyText').textContent =
      currentStatus === 'NEW' ? 'Chưa có yêu cầu mới từ khách.' :
      currentStatus === 'IN_PROGRESS' ? 'Không có yêu cầu đang xử lý.' :
      currentStatus === 'DONE' ? 'Chưa có yêu cầu nào hoàn thành.' :
      'Không có yêu cầu nào đã huỷ.';
    return;
  }
  empty.classList.add('hidden');

  container.innerHTML = data.map(r => {
    const t = typeInfo(r.requestType);
    const acts = actionButtons(r);
    const itemsHtml = renderItems(r.itemsJson);
    return `
      <div class="req-card \${cardClass(r.status)}">
        <div class="flex items-start gap-3">
          <div class="type-icon \${t.cls}">
            <span class="material-symbols-outlined">\${t.icon}</span>
          </div>
          <div class="flex-1 min-w-0">
            <div class="flex items-center justify-between gap-2 flex-wrap">
              <div>
                <p class="font-extrabold text-sm text-zinc-900">\${escapeHtml(r.tenSan)}</p>
                <p class="text-xs text-zinc-500 font-semibold mt-0.5">\${t.label}</p>
              </div>
              <div class="flex items-center gap-2 flex-shrink-0">
                \${statusBadge(r.status)}
                <span class="time-label">\${timeAgo(r.createdAt)}</span>
              </div>
            </div>
            \${r.note ? `<p class="text-sm text-zinc-600 mt-2 bg-zinc-50 rounded-xl px-3 py-2">"\${escapeHtml(r.note)}"</p>` : ''}
            \${itemsHtml ? `<div class="flex flex-wrap gap-1.5 mt-2">\${itemsHtml}</div>` : ''}
            \${acts ? `<div class="flex gap-2 mt-3 flex-wrap">\${acts}</div>` : ''}
          </div>
        </div>
      </div>`;
  }).join('');
}

function doAction(requestId, action) {
  const params = new URLSearchParams();
  params.append('requestId', requestId);
  params.append('action', action);
  fetch(`\${CONTEXT}/api/staff/yeu-cau-qr/action`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: params.toString()
  })
    .then(r => r.json())
    .then(res => {
      if (!res.success) { alert(res.message || 'Không thể cập nhật yêu cầu.'); return; }
      loadList();
      loadCounts();
    })
    .catch(() => alert('Lỗi kết nối. Vui lòng thử lại.'));
}

function switchTab(status, btn) {
  currentStatus = status;
  document.querySelectorAll('.tab-pill').forEach(b => b.classList.remove('active'));
  btn.classList.add('active');
  clearTimeout(pollTimer);
  loadList();
}

function loadList() {
  fetch(`\${CONTEXT}/api/staff/yeu-cau-qr?status=\${currentStatus}`)
    .then(r => r.json())
    .then(res => {
      if (!res.success) return;
      renderCards(res.data);
    });
  if (currentStatus === 'NEW' || currentStatus === 'IN_PROGRESS') {
    pollTimer = setTimeout(loadList, 8000);
  }
}

function loadCounts() {
  const statuses = ['NEW', 'IN_PROGRESS', 'DONE', 'CANCELLED'];
  const statEls = {
    'NEW': { stat: 'statNew', cnt: 'cntNew' },
    'IN_PROGRESS': { stat: 'statProgress', cnt: 'cntProgress' },
    'DONE': { stat: 'statDone', cnt: 'cntDone' },
    'CANCELLED': { stat: 'statCancel', cnt: 'cntCancel' }
  };
  statuses.forEach(s => {
    fetch(`\${CONTEXT}/api/staff/yeu-cau-qr?status=\${s}`)
      .then(r => r.json())
      .then(res => {
        if (!res.success) return;
        const count = res.data.length;
        const els = statEls[s];
        document.getElementById(els.stat).textContent = count;
        const cntEl = document.getElementById(els.cnt);
        if (cntEl) {
          cntEl.textContent = count;
          const pill = cntEl.closest('.tab-pill');
          if (pill && count > 0) pill.classList.add('has-count');
          else if (pill && !pill.classList.contains('active')) pill.classList.remove('has-count');
        }
      });
  });
  setTimeout(loadCounts, 15000);
}

loadList();
loadCounts();
</script>
</body>
</html>
