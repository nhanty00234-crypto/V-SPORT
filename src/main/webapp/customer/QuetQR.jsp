<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quét mã sân - V-SPORT</title>
    <style>
        * { box-sizing: border-box; }
        html, body { height: 100%; }
        body {
            font-family: 'Be Vietnam Pro', system-ui, sans-serif;
            background: linear-gradient(180deg, #eef4ff 0%, #f3f6ff 45%, #eef9f4 100%);
            margin: 0;
            padding: 24px 16px;
            min-height: 100vh;
            display: flex;
            justify-content: center;
            position: relative;
            overflow-x: hidden;
        }

        /* ── Animated ball background ── */
        #ballField {
            position: fixed; inset: 0; overflow: hidden; z-index: 0; pointer-events: none;
        }
        .ball {
            position: absolute;
            bottom: -80px;
            border-radius: 50%;
            background: radial-gradient(circle at 32% 28%, #bfdbfe 0%, #60a5fa 45%, #2563eb 78%, #1d4ed8 100%);
            box-shadow: inset -6px -6px 14px rgba(29,78,216,.55), 0 6px 18px rgba(37,99,235,.18);
            opacity: .55;
            animation: floatUp linear infinite;
        }
        .ball::after {
            content:''; position:absolute; inset:14%; border-radius:50%;
            background:
                radial-gradient(circle at 50% 50%, transparent 55%, rgba(255,255,255,.35) 57%, transparent 60%),
                repeating-conic-gradient(rgba(255,255,255,.28) 0 30deg, transparent 30deg 60deg);
            opacity:.5;
        }
        @keyframes floatUp {
            0%   { transform: translateY(0) translateX(0) rotate(0deg); }
            50%  { transform: translateY(-52vh) translateX(24px) rotate(180deg); }
            100% { transform: translateY(-108vh) translateX(-16px) rotate(360deg); }
        }

        .shell { width: 100%; max-width: 420px; position: relative; z-index: 1; }

        .card { background:#fff; border-radius:18px; padding:20px; box-shadow:0 4px 18px -6px rgba(37,99,235,.10); margin-bottom:14px; }
        h1 { font-size:19px; margin:0 0 4px; color:#18181b; }
        .sub { color:#71717a; font-size:13px; margin:0; }

        .actions { display:flex; flex-direction:row; gap:10px; margin-bottom:14px; }
        .opt-group { flex:1; min-width:0; }

        .opt-btn {
            display:flex; flex-direction:column; align-items:center; justify-content:center; gap:8px;
            width:100%; padding:16px 8px; border:none; border-radius:16px;
            background:#fff; color:#18181b; font-weight:700; font-size:12.5px;
            cursor:pointer; text-align:center; transition: background .15s, transform .1s;
            box-shadow:0 4px 18px -6px rgba(37,99,235,.10);
        }
        .opt-btn:hover { background:#f5f8ff; }
        .opt-btn:active { transform: scale(.97); }
        .opt-btn .emoji {
            font-size:22px; width:44px; height:44px; border-radius:14px; flex-shrink:0;
            display:flex; align-items:center; justify-content:center;
            background:#eef2ff; transition: background .2s, transform .2s;
        }
        .opt-btn.open .emoji { transform: scale(1.08); }
        #btn-call .emoji { background:#eff6ff; }
        #btn-order .emoji { background:#fff7ed; }
        #btn-pay .emoji { background:#eefdf3; }
        .opt-btn .arrow { display:none; }
        .opt-btn.open { background:#f3f7ff; color:#1d4ed8; box-shadow:0 4px 18px -6px rgba(37,99,235,.28); }

        .opt-panel {
            max-height:0; overflow:hidden;
            transition: max-height .32s cubic-bezier(.4,0,.2,1), padding .32s cubic-bezier(.4,0,.2,1), margin .32s cubic-bezier(.4,0,.2,1);
            padding: 0 18px;
            background:#fff;
            border-radius:16px;
            box-shadow:0 4px 18px -6px rgba(37,99,235,.10);
        }
        .opt-panel.open { max-height:600px; padding:16px 18px 18px; margin-bottom:14px; overflow-y:auto; }

        textarea, input[type=text] {
            width:100%; box-sizing:border-box; border:1.5px solid #e4e4e7; border-radius:10px;
            padding:10px 12px; font-size:14px; font-family:inherit; outline:none; transition:border-color .15s;
        }
        textarea:focus, input[type=text]:focus { border-color:#7C3AED; }

        .submit-btn {
            width:100%; padding:13px; border:none; border-radius:12px; background:#2563eb; color:#fff;
            font-weight:700; font-size:14px; margin-top:12px; cursor:pointer; transition: background .15s, transform .1s;
        }
        .submit-btn:hover { background:#1d4ed8; }
        .submit-btn:active { transform: scale(.98); }
        .submit-btn:disabled { background:#d4d4d8; cursor:not-allowed; transform:none; }

        .preview-badge {
            display:flex; align-items:center; gap:6px; background:#eff6ff; color:#1d4ed8;
            border-radius:10px; padding:7px 10px; font-size:11px; font-weight:700; margin-top:10px;
        }

        /* Gọi món */
        .product-list { display:flex; flex-direction:column; gap:8px; }
        .product-row {
            display:flex; align-items:center; justify-content:space-between; gap:10px;
            background:#fff; border:1px solid #ede9fe; border-radius:12px; padding:10px 12px;
        }
        .product-row .p-name { font-weight:700; font-size:13.5px; color:#27272a; }
        .product-row .p-meta { font-size:11.5px; color:#a1a1aa; margin-top:1px; }
        .qty-wrap { display:flex; align-items:center; gap:8px; flex-shrink:0; }
        .qty-btn {
            width:28px; height:28px; border-radius:8px; border:1.5px solid #ddd6fe; background:#f5f3ff;
            color:#6d28d9; font-size:16px; font-weight:700; cursor:pointer; display:flex; align-items:center; justify-content:center;
        }
        .qty-btn:active { transform: scale(.9); }
        .qty-val { min-width:18px; text-align:center; font-weight:700; font-size:14px; }
        .empty-products { text-align:center; color:#a1a1aa; font-size:13px; padding:16px 0; }

        /* Thanh toán */
        .pay-methods { display:flex; gap:10px; }
        .pay-card {
            flex:1; border:1.5px solid #e4e4e7; border-radius:14px; padding:16px 10px;
            display:flex; flex-direction:column; align-items:center; gap:6px; cursor:pointer;
            background:#fff; transition: all .15s; text-align:center;
        }
        .pay-card .p-emoji { font-size:24px; }
        .pay-card .p-label { font-size:12.5px; font-weight:700; color:#3f3f46; }
        .pay-card.selected { border-color:#7C3AED; background:#f5f3ff; box-shadow:0 0 0 3px rgba(124,58,237,.12); }
        .pay-card.selected .p-label { color:#6d28d9; }

        /* Toast */
        #toastHost { position:fixed; left:0; right:0; bottom:20px; display:flex; flex-direction:column; align-items:center; gap:8px; z-index:200; pointer-events:none; }
        .toast {
            display:flex; align-items:center; gap:8px; background:#18181b; color:#fff; font-size:13.5px; font-weight:600;
            padding:12px 18px; border-radius:12px; box-shadow:0 8px 24px -6px rgba(0,0,0,.3);
            opacity:0; transform: translateY(12px); transition: opacity .25s, transform .25s; max-width:92vw;
        }
        .toast.show { opacity:1; transform: translateY(0); }
        .toast.error { background:#dc2626; }
        .toast .material-symbols-outlined { font-size:18px; }

        /* Request history */
        .badge { display:inline-block; padding:4px 10px; border-radius:999px; font-size:11px; font-weight:700; text-transform:uppercase; }
        .badge-new { background:#dbeafe; color:#1d4ed8; }
        .badge-progress { background:#fef3c7; color:#b45309; }
        .badge-done { background:#dcfce7; color:#15803d; }
        .badge-cancel { background:#fee2e2; color:#b91c1c; }
        .req-item { padding:10px 0; border-bottom:1px solid #f4f4f5; }
        .req-item:last-child { border-bottom:none; }
        .req-item .req-top { display:flex; justify-content:space-between; align-items:center; gap:8px; }
        .req-item strong { font-size:13.5px; }
        .req-item .req-note { color:#71717a; font-size:12.5px; margin:4px 0 0; }
        .hist-title { font-size:13px; color:#71717a; font-weight:700; margin:4px 4px 8px; }

        .error-box { color:#b91c1c; background:#fef2f2; border-radius:14px; padding:18px; text-align:center; font-weight:600; }
    </style>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined" onerror="this.remove()">
</head>
<body>
<div id="ballField">
  <div class="ball" style="left:6%;  width:46px; height:46px; animation-duration:16s; animation-delay:-2s;"></div>
  <div class="ball" style="left:18%; width:26px; height:26px; animation-duration:11s; animation-delay:-6s;"></div>
  <div class="ball" style="left:32%; width:60px; height:60px; animation-duration:20s; animation-delay:-9s;"></div>
  <div class="ball" style="left:48%; width:34px; height:34px; animation-duration:13s; animation-delay:-1s;"></div>
  <div class="ball" style="left:62%; width:50px; height:50px; animation-duration:18s; animation-delay:-11s;"></div>
  <div class="ball" style="left:76%; width:28px; height:28px; animation-duration:12s; animation-delay:-4s;"></div>
  <div class="ball" style="left:88%; width:40px; height:40px; animation-duration:15s; animation-delay:-7s;"></div>
</div>
<div class="shell">
<c:choose>
    <c:when test="${resolveDto.resultCode == 'OK'}">

        <div class="card">
            <h1>${resolveDto.tenSan}</h1>
            <p class="sub">${resolveDto.tenCoSo}</p>
        </div>

        <div class="actions">
          <div class="opt-group">
            <button class="opt-btn" id="btn-call" onclick="togglePanel('call')">
              <span class="emoji">📢</span>Gọi nhân viên
            </button>
          </div>
          <div class="opt-group">
            <button class="opt-btn" id="btn-order" onclick="togglePanel('order')">
              <span class="emoji">🍔</span>Gọi món
            </button>
          </div>
          <div class="opt-group">
            <button class="opt-btn" id="btn-pay" onclick="togglePanel('pay')">
              <span class="emoji">💳</span>Thanh toán
            </button>
          </div>
        </div>

        <div class="opt-panel" id="panel-call">
          <p style="margin:0 0 8px;font-size:13px;color:#71717a;">Bạn cần nhân viên hỗ trợ gì?</p>
          <textarea id="callNote" rows="2" placeholder="Ghi chú (tuỳ chọn)"></textarea>
          <button class="submit-btn" onclick="submitCallStaff()">Gửi yêu cầu</button>
          <c:if test="${previewMode}">
            <div class="preview-badge"><span class="material-symbols-outlined" style="font-size:14px">visibility</span>Đang xem trước từ trang quản lý — vẫn gửi được yêu cầu thật cho nhân viên</div>
          </c:if>
        </div>

        <div class="opt-panel" id="panel-order">
          <div class="product-list" id="productList">
            <p class="empty-products">Đang tải danh sách...</p>
          </div>
          <button class="submit-btn" onclick="submitOrder()">Gửi yêu cầu gọi món</button>
          <c:if test="${previewMode}">
            <div class="preview-badge"><span class="material-symbols-outlined" style="font-size:14px">visibility</span>Đang xem trước từ trang quản lý — vẫn gửi được yêu cầu thật cho nhân viên</div>
          </c:if>
        </div>

        <div class="opt-panel" id="panel-pay">
          <p style="margin:0 0 10px;font-size:13px;color:#71717a;">Chọn phương thức thanh toán:</p>
          <div class="pay-methods">
            <div class="pay-card" id="pay-transfer" onclick="selectPayMethod('Chuyển khoản')">
              <span class="p-emoji">🏦</span><span class="p-label">Chuyển khoản</span>
            </div>
            <div class="pay-card" id="pay-cash" onclick="selectPayMethod('Tiền mặt')">
              <span class="p-emoji">💵</span><span class="p-label">Tiền mặt</span>
            </div>
          </div>
          <button class="submit-btn" id="paySubmitBtn" onclick="submitPayment()" disabled>Gửi yêu cầu thanh toán</button>
          <c:if test="${previewMode}">
            <div class="preview-badge"><span class="material-symbols-outlined" style="font-size:14px">visibility</span>Đang xem trước từ trang quản lý — vẫn gửi được yêu cầu thật cho nhân viên</div>
          </c:if>
        </div>

        <div class="card">
          <p class="hist-title">Yêu cầu của bạn</p>
          <div id="requestList"><p class="empty-products">Chưa có yêu cầu nào.</p></div>
        </div>

    </c:when>
    <c:otherwise>
        <div class="error-box">${resolveDto.message}</div>
    </c:otherwise>
</c:choose>
</div>

<div id="toastHost"></div>

<script>
const CONTEXT = "${pageContext.request.contextPath}";
const SAN_ID = ${resolveDto.sanId != null ? resolveDto.sanId : 'null'};
const SHORT_CODE = "${shortCode}";

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
        .replace(/&/g, '&amp;').replace(/</g, '&lt;')
        .replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&#39;');
}

/* ── Toast ── */
function showToast(message, type) {
    const host = document.getElementById('toastHost');
    const el = document.createElement('div');
    el.className = 'toast' + (type === 'error' ? ' error' : '');
    el.innerHTML = '<span class="material-symbols-outlined">' + (type === 'error' ? 'error' : 'check_circle') + '</span>' + escapeHtml(message);
    host.appendChild(el);
    requestAnimationFrame(() => el.classList.add('show'));
    setTimeout(() => {
        el.classList.remove('show');
        setTimeout(() => el.remove(), 300);
    }, 3200);
}

/* ── Accordion ── */
let openPanel = null;
function togglePanel(key) {
    const btn = document.getElementById('btn-' + key);
    const panel = document.getElementById('panel-' + key);
    const isOpen = panel.classList.contains('open');

    if (openPanel && openPanel !== key) {
        document.getElementById('btn-' + openPanel).classList.remove('open');
        document.getElementById('panel-' + openPanel).classList.remove('open');
    }

    if (isOpen) {
        btn.classList.remove('open');
        panel.classList.remove('open');
        openPanel = null;
    } else {
        btn.classList.add('open');
        panel.classList.add('open');
        openPanel = key;
        if (key === 'order') loadProducts();
    }
}

/* ── Gọi món ── */
let productsLoaded = false;
const cart = {};
function loadProducts() {
    if (productsLoaded) return;
    productsLoaded = true;
    fetch(`\${CONTEXT}/api/qr/san-pham?sanId=\${SAN_ID}`)
        .then(r => r.json())
        .then(res => {
            const list = document.getElementById('productList');
            if (!res.success || !res.data.length) {
                list.innerHTML = '<p class="empty-products">Cơ sở chưa có sản phẩm/dịch vụ nào.</p>';
                return;
            }
            list.innerHTML = res.data.map(p => `
                <div class="product-row" data-id="\${p.sanPhamId}" data-name="\${escapeHtml(p.tenSanPham)}" data-ton="\${p.soLuongTon}">
                    <div>
                        <div class="p-name">\${escapeHtml(p.tenSanPham)}</div>
                        <div class="p-meta">\${p.donGia.toLocaleString('vi-VN')}đ · còn \${p.soLuongTon}</div>
                    </div>
                    <div class="qty-wrap">
                        <button class="qty-btn" onclick="changeQty(\${p.sanPhamId}, -1)">−</button>
                        <span class="qty-val" id="qty-\${p.sanPhamId}">0</span>
                        <button class="qty-btn" onclick="changeQty(\${p.sanPhamId}, 1)">+</button>
                    </div>
                </div>`).join('');
        })
        .catch(() => {
            productsLoaded = false;
            document.getElementById('productList').innerHTML = '<p class="empty-products">Lỗi tải danh sách. Thử lại sau.</p>';
        });
}
function changeQty(id, delta) {
    const row = document.querySelector(`.product-row[data-id="\${id}"]`);
    const max = row ? Number(row.dataset.ton) || 0 : 999;
    cart[id] = Math.min(max, Math.max(0, (cart[id] || 0) + delta));
    document.getElementById('qty-' + id).textContent = cart[id];
}
function submitOrder() {
    const items = Object.keys(cart).filter(id => cart[id] > 0).map(id => {
        const row = document.querySelector(`.product-row[data-id="\${id}"]`);
        return { sanPhamId: Number(id), tenSanPham: row.dataset.name, soLuong: cart[id] };
    });
    if (items.length === 0) { showToast('Vui lòng chọn ít nhất 1 món.', 'error'); return; }
    createRequest('ORDER_ITEM', null, JSON.stringify(items), 'Đã gửi yêu cầu gọi món thành công!', () => {
        Object.keys(cart).forEach(id => { cart[id] = 0; const el = document.getElementById('qty-' + id); if (el) el.textContent = '0'; });
    });
}

/* ── Gọi nhân viên ── */
function submitCallStaff() {
    const note = document.getElementById('callNote').value;
    createRequest('CALL_STAFF', note, null, 'Đã gửi yêu cầu gọi nhân viên thành công!', () => {
        document.getElementById('callNote').value = '';
    });
}

/* ── Thanh toán ── */
let selectedPayMethod = null;
function selectPayMethod(method) {
    selectedPayMethod = method;
    document.getElementById('pay-transfer').classList.toggle('selected', method === 'Chuyển khoản');
    document.getElementById('pay-cash').classList.toggle('selected', method === 'Tiền mặt');
    const btn = document.getElementById('paySubmitBtn');
    if (btn) btn.disabled = false;
}
function submitPayment() {
    if (!selectedPayMethod) { showToast('Vui lòng chọn phương thức thanh toán.', 'error'); return; }
    createRequest('PAYMENT_REQUEST', selectedPayMethod, null, 'Đã gửi yêu cầu thanh toán, nhân viên sẽ ra hỗ trợ ngay!', () => {
        selectedPayMethod = null;
        document.getElementById('pay-transfer').classList.remove('selected');
        document.getElementById('pay-cash').classList.remove('selected');
        document.getElementById('paySubmitBtn').disabled = true;
    });
}

/* ── Core submit ── */
let submitting = false;
function createRequest(requestType, note, itemsJson, successMsg, onSuccess) {
    if (submitting) return;
    submitting = true;
    const buttons = document.querySelectorAll('.submit-btn');
    buttons.forEach(b => { b.dataset.origText = b.dataset.origText || b.textContent; b.disabled = true; });

    const body = new URLSearchParams();
    body.set('sanId', SAN_ID);
    body.set('guestToken', GUEST_TOKEN);
    body.set('requestType', requestType);
    if (note) body.set('note', note);
    if (itemsJson) body.set('itemsJson', itemsJson);
    fetch(`\${CONTEXT}/api/qr/yeu-cau`, { method: 'POST', body })
        .then(r => r.json())
        .then(res => {
            if (res.success) {
                showToast(successMsg);
                if (onSuccess) onSuccess();
                loadRequests();
            } else {
                showToast(res.message || 'Không thể gửi yêu cầu.', 'error');
            }
        })
        .catch(() => showToast('Lỗi kết nối. Vui lòng thử lại.', 'error'))
        .finally(() => {
            submitting = false;
            buttons.forEach(b => { b.disabled = false; });
        });
}

/* ── Lịch sử yêu cầu ── */
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
    if (type === 'PAYMENT_REQUEST') return 'Thanh toán';
    return 'Yêu cầu dịch vụ';
}
function loadRequests() {
    fetch(`\${CONTEXT}/api/qr/yeu-cau-status?guestToken=\${GUEST_TOKEN}&sanId=\${SAN_ID}`)
        .then(r => r.json())
        .then(res => {
            if (!res.success) return;
            const list = document.getElementById('requestList');
            if (!list) return;
            if (res.data.length === 0) {
                list.innerHTML = '<p class="empty-products">Chưa có yêu cầu nào.</p>';
                return;
            }
            list.innerHTML = res.data.slice().reverse().map(r => {
                const [cls, label] = statusLabel(r.status);
                return `<div class="req-item">
                    <div class="req-top">
                        <strong>\${typeLabel(r.requestType)}</strong>
                        <span class="badge \${cls}">\${label}</span>
                    </div>
                    \${r.note ? `<p class="req-note">"\${escapeHtml(r.note)}"</p>` : ''}
                </div>`;
            }).join('');
        });
}

if (SAN_ID !== null) {
    loadRequests();
    setInterval(loadRequests, 3000);
}
</script>
</body>
</html>
