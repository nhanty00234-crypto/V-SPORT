<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Yêu cầu của bạn - V-SPORT</title>
    <style>
        body { font-family: 'Be Vietnam Pro', system-ui, sans-serif; background:#f4f4f5; margin:0; padding:16px; }
        .card { background:#fff; border-radius:16px; padding:16px; box-shadow:0 1px 3px rgba(0,0,0,.08); margin-bottom:12px; }
        .badge { display:inline-block; padding:4px 10px; border-radius:999px; font-size:11px; font-weight:700; text-transform:uppercase; }
        .badge-new { background:#dbeafe; color:#1d4ed8; }
        .badge-progress { background:#fef3c7; color:#b45309; }
        .badge-done { background:#dcfce7; color:#15803d; }
        .badge-cancel { background:#fee2e2; color:#b91c1c; }
        textarea, input[type=text] { width:100%; box-sizing:border-box; border:1px solid #e4e4e7; border-radius:10px; padding:10px; font-size:14px; }
        .item-row { display:flex; align-items:center; justify-content:space-between; padding:8px 0; border-bottom:1px solid #f4f4f5; }
        .qty-btn { width:28px; height:28px; border-radius:8px; border:1px solid #e4e4e7; background:#fff; font-size:16px; cursor:pointer; }
        .submit-btn { width:100%; padding:14px; border:none; border-radius:12px; background:#7C3AED; color:#fff; font-weight:700; margin-top:12px; cursor:pointer; }
        .back-link { display:inline-block; margin-bottom:12px; color:#71717a; font-size:13px; text-decoration:none; }
    </style>
</head>
<body>
<a class="back-link" href="QuetQR.jsp?shortCode=${param.shortCode}">&larr; Quay lại</a>

<div id="composer" class="card" style="display:none;">
    <div id="composer-call" style="display:none;">
        <p>Bạn cần nhân viên hỗ trợ gì?</p>
        <textarea id="callNote" placeholder="Ghi chú (tuỳ chọn)"></textarea>
        <button class="submit-btn" onclick="submitCallStaff()">Gửi yêu cầu gọi nhân viên</button>
    </div>
    <div id="composer-order" style="display:none;">
        <p>Chọn món/sản phẩm:</p>
        <div id="productList"></div>
        <button class="submit-btn" onclick="submitOrder()">Gửi yêu cầu gọi món</button>
    </div>
    <div id="composer-service" style="display:none;">
        <p>Mô tả dịch vụ bạn cần:</p>
        <textarea id="serviceNote" placeholder="Ví dụ: cần thêm lưới, đổi bóng..."></textarea>
        <button class="submit-btn" onclick="submitService()">Gửi yêu cầu dịch vụ</button>
    </div>
</div>

<h3 style="font-size:14px;color:#71717a;">Yêu cầu của bạn</h3>
<div id="requestList"></div>

<script>
const CONTEXT = "${pageContext.request.contextPath}";
const SAN_ID = ${param.sanId};
const SHORT_CODE = "${param.shortCode}";
const TYPE = "${param.type}";

function getGuestToken() {
    let t = localStorage.getItem('vsport_guest_token');
    if (!t) {
        t = 'guest-' + Date.now() + '-' + Math.random().toString(36).slice(2, 10);
        localStorage.setItem('vsport_guest_token', t);
    }
    return t;
}
const GUEST_TOKEN = getGuestToken();

function escapeHtml(str) {
    if (str === null || str === undefined) return '';
    return String(str)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#39;');
}

if (TYPE === 'call') { document.getElementById('composer').style.display='block'; document.getElementById('composer-call').style.display='block'; }
if (TYPE === 'order') {
    document.getElementById('composer').style.display='block';
    document.getElementById('composer-order').style.display='block';
    loadProducts();
}
if (TYPE === 'service') { document.getElementById('composer').style.display='block'; document.getElementById('composer-service').style.display='block'; }

function loadProducts() {
    fetch(`${CONTEXT}/api/qr/san-pham?sanId=${SAN_ID}`)
        .then(r => r.json())
        .then(res => {
            if (!res.success) return;
            const list = document.getElementById('productList');
            list.innerHTML = res.data.map(p => `
                <div class="item-row" data-id="${p.sanPhamId}" data-name="${escapeHtml(p.tenSanPham)}">
                    <span>${escapeHtml(p.tenSanPham)} - ${p.donGia.toLocaleString('vi-VN')}đ</span>
                    <span>
                        <button class="qty-btn" onclick="changeQty(${p.sanPhamId}, -1)">-</button>
                        <span id="qty-${p.sanPhamId}" style="margin:0 8px;">0</span>
                        <button class="qty-btn" onclick="changeQty(${p.sanPhamId}, 1)">+</button>
                    </span>
                </div>`).join('');
        });
}

const cart = {};
function changeQty(id, delta) {
    cart[id] = Math.max(0, (cart[id] || 0) + delta);
    document.getElementById('qty-' + id).textContent = cart[id];
}

function submitCallStaff() {
    const note = document.getElementById('callNote').value;
    createRequest('CALL_STAFF', note, null);
}

function submitOrder() {
    const items = Object.keys(cart).filter(id => cart[id] > 0).map(id => {
        const row = document.querySelector(`.item-row[data-id="${id}"]`);
        return { sanPhamId: Number(id), tenSanPham: row.dataset.name, soLuong: cart[id] };
    });
    if (items.length === 0) { alert('Vui lòng chọn ít nhất 1 món.'); return; }
    createRequest('ORDER_ITEM', null, JSON.stringify(items));
}

function submitService() {
    const note = document.getElementById('serviceNote').value;
    if (!note.trim()) { alert('Vui lòng mô tả yêu cầu.'); return; }
    createRequest('SERVICE_REQUEST', note, null);
}

function createRequest(requestType, note, itemsJson) {
    const body = new URLSearchParams();
    body.set('sanId', SAN_ID);
    body.set('guestToken', GUEST_TOKEN);
    body.set('requestType', requestType);
    if (note) body.set('note', note);
    if (itemsJson) body.set('itemsJson', itemsJson);
    fetch(`${CONTEXT}/api/qr/yeu-cau`, { method: 'POST', body })
        .then(r => r.json())
        .then(res => {
            if (res.success) {
                document.getElementById('composer').style.display = 'none';
                loadRequests();
            } else {
                alert(res.message || 'Không thể gửi yêu cầu.');
            }
        });
}

function statusLabel(status) {
    switch (status) {
        case 'NEW': return ['badge-new', 'Mới gửi'];
        case 'IN_PROGRESS': return ['badge-progress', 'Đang xử lý'];
        case 'DONE': return ['badge-done', 'Hoàn thành'];
        case 'CANCELLED': return ['badge-cancel', 'Đã huỷ'];
        default: return ['badge-new', status];
    }
}

function typeLabel(type) {
    if (type === 'CALL_STAFF') return 'Gọi nhân viên';
    if (type === 'ORDER_ITEM') return 'Gọi món';
    return 'Yêu cầu dịch vụ';
}

function loadRequests() {
    fetch(`${CONTEXT}/api/qr/yeu-cau-status?guestToken=${GUEST_TOKEN}&sanId=${SAN_ID}`)
        .then(r => r.json())
        .then(res => {
            if (!res.success) return;
            const list = document.getElementById('requestList');
            if (res.data.length === 0) {
                list.innerHTML = '<div class="card">Bạn chưa gửi yêu cầu nào.</div>';
                return;
            }
            list.innerHTML = res.data.map(r => {
                const [cls, label] = statusLabel(r.status);
                return `<div class="card">
                    <div style="display:flex;justify-content:space-between;align-items:center;">
                        <strong>${typeLabel(r.requestType)}</strong>
                        <span class="badge ${cls}">${label}</span>
                    </div>
                    ${r.note ? `<p style="color:#71717a;font-size:13px;">${escapeHtml(r.note)}</p>` : ''}
                </div>`;
            }).join('');
        });
}

loadRequests();
setInterval(loadRequests, 5000);
</script>
</body>
</html>
