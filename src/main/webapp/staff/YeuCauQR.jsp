<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Yêu cầu từ QR sân - V-SPORT</title>
    <style>
        body { font-family: 'Be Vietnam Pro', system-ui, sans-serif; background:#f4f4f5; margin:0; padding:24px; }
        .tabs { display:flex; gap:8px; margin-bottom:16px; }
        .tab-btn { padding:8px 16px; border-radius:10px; border:1px solid #e4e4e7; background:#fff; cursor:pointer; font-weight:600; font-size:13px; }
        .tab-btn.active { background:#7C3AED; color:#fff; border-color:#7C3AED; }
        .card { background:#fff; border-radius:14px; padding:16px; box-shadow:0 1px 3px rgba(0,0,0,.06); margin-bottom:10px; }
        .badge { display:inline-block; padding:4px 10px; border-radius:999px; font-size:11px; font-weight:700; text-transform:uppercase; }
        .badge-new { background:#dbeafe; color:#1d4ed8; }
        .badge-progress { background:#fef3c7; color:#b45309; }
        .action-btn { padding:8px 14px; border:none; border-radius:8px; font-weight:700; font-size:12px; cursor:pointer; color:#fff; }
        .btn-start { background:#7C3AED; }
        .btn-complete { background:#16a34a; }
        .btn-cancel { background:#dc2626; }
    </style>
</head>
<body>
<h2>Yêu cầu từ QR sân</h2>
<div class="tabs">
    <button class="tab-btn active" data-status="NEW" onclick="switchTab('NEW', this)">Mới</button>
    <button class="tab-btn" data-status="IN_PROGRESS" onclick="switchTab('IN_PROGRESS', this)">Đang xử lý</button>
    <button class="tab-btn" data-status="DONE" onclick="switchTab('DONE', this)">Hoàn thành</button>
    <button class="tab-btn" data-status="CANCELLED" onclick="switchTab('CANCELLED', this)">Đã huỷ</button>
</div>
<div id="list"></div>

<script>
const CONTEXT = "${pageContext.request.contextPath}";
let currentStatus = 'NEW';

function escapeHtml(str) {
    if (str === null || str === undefined) return '';
    return String(str)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#39;');
}

function switchTab(status, btn) {
    currentStatus = status;
    document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    loadList();
}

function typeLabel(type) {
    if (type === 'CALL_STAFF') return 'Gọi nhân viên';
    if (type === 'ORDER_ITEM') return 'Gọi món';
    return 'Yêu cầu dịch vụ';
}

function actionButtons(r) {
    if (r.status === 'NEW') {
        return `<button class="action-btn btn-start" onclick="doAction(${r.requestId},'start')">Bắt đầu xử lý</button>
                <button class="action-btn btn-cancel" onclick="doAction(${r.requestId},'cancel')">Huỷ</button>`;
    }
    if (r.status === 'IN_PROGRESS') {
        return `<button class="action-btn btn-complete" onclick="doAction(${r.requestId},'complete')">Hoàn thành</button>
                <button class="action-btn btn-cancel" onclick="doAction(${r.requestId},'cancel')">Huỷ</button>`;
    }
    return '';
}

function loadList() {
    fetch(`${CONTEXT}/api/staff/yeu-cau-qr?status=${currentStatus}`)
        .then(r => r.json())
        .then(res => {
            const list = document.getElementById('list');
            if (!res.success) { list.innerHTML = '<div class="card">Không thể tải dữ liệu.</div>'; return; }
            if (res.data.length === 0) { list.innerHTML = '<div class="card">Không có yêu cầu nào.</div>'; return; }
            list.innerHTML = res.data.map(r => `
                <div class="card">
                    <div style="display:flex;justify-content:space-between;align-items:center;">
                        <div>
                            <strong>${escapeHtml(r.tenSan)}</strong> — ${typeLabel(r.requestType)}
                            ${r.note ? `<p style="color:#71717a;font-size:13px;margin:4px 0 0;">${escapeHtml(r.note)}</p>` : ''}
                            ${r.itemsJson ? `<p style="color:#71717a;font-size:13px;margin:4px 0 0;">${escapeHtml(r.itemsJson)}</p>` : ''}
                        </div>
                        <div>${actionButtons(r)}</div>
                    </div>
                </div>`).join('');
        });
}

function doAction(requestId, action) {
    const body = new URLSearchParams();
    body.set('requestId', requestId);
    body.set('action', action);
    fetch(`${CONTEXT}/api/staff/yeu-cau-qr/action`, { method: 'POST', body })
        .then(r => r.json())
        .then(res => {
            if (!res.success) { alert(res.message || 'Không thể xử lý.'); return; }
            loadList();
        });
}

loadList();
setInterval(loadList, 10000);
</script>
</body>
</html>
