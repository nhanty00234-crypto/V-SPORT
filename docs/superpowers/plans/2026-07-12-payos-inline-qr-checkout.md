# PayOS Inline QR Checkout — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Thay thế redirect sang trang PayOS hosted bằng QR hiển thị ngay trong modal đặt sân, với poll tự động phát hiện thanh toán thành công và state machine mượt mà.

**Architecture:** Frontend dùng `fetch()` AJAX thay vì `form.submit()` để gửi booking lên backend; backend trả JSON `{success, qrCode, expiredAt, datSanId}` thay vì redirect; frontend vẽ QR bằng thư viện `qrcode` và poll `/customer/payos-status` mỗi 3 giây để phát hiện trạng thái.

**Tech Stack:** Java Servlet, JSP, Tailwind CSS (utility classes đã có), PayOS Java SDK v2.0.1, thư viện `qrcode@1.5.3` (CDN jsDelivr)

## Global Constraints

- Không thay đổi luồng "Thanh toán tại quầy" (`paymentMethod=sau`) — vẫn `form.submit()` như cũ
- Không thay đổi `PayOSWebhookServlet` — webhook đã hoạt động đúng
- Không thay đổi logic validate, tính tiền, giữ chỗ tạm, tự hủy đơn quá hạn
- Sử dụng class CSS Tailwind đã có trong file (`opacity-0`, `scale-95`, `hidden`, `transition-all duration-300`)
- Encoding UTF-8 cho mọi JSON response
- `payos-status` endpoint chỉ trả status của đơn thuộc về user đang đăng nhập

---

## File Map

| File | Thay đổi |
|------|----------|
| `src/main/java/org/example/service/PayOSService.java` | Thêm method `createCheckoutSession(...)` trả DTO mới |
| `src/main/java/org/example/service/PayOSCheckoutSession.java` | **Tạo mới** — DTO `{checkoutUrl, qrCode, expiredAt, amount}` |
| `src/main/java/org/example/controller/DatSanServlet.java` | (1) nhánh PayOS trả JSON thay vì redirect; (2) thêm GET case `/customer/payos-status` |
| `src/main/webapp/customer/DatSan.jsp` | (1) nhúng `qrcode` script; (2) thêm `#payos-qr-view` HTML; (3) sửa `confirmBooking()`; (4) thêm `showPayOSQrState`, `pollPayOSStatus`; (5) cập nhật `closeBookingModal()` |

---

## Task 1: Tạo DTO `PayOSCheckoutSession` và method `createCheckoutSession` trong `PayOSService`

**Files:**
- Create: `src/main/java/org/example/service/PayOSCheckoutSession.java`
- Modify: `src/main/java/org/example/service/PayOSService.java`

**Interfaces:**
- Produces: `PayOSService.getInstance().createCheckoutSession(int datSanId, long amount, String description, String returnUrl, String cancelUrl)` → `PayOSCheckoutSession`
- `PayOSCheckoutSession` fields: `String checkoutUrl`, `String qrCode`, `Long expiredAt`, `long amount`

- [ ] **Step 1: Tạo file DTO**

Tạo `src/main/java/org/example/service/PayOSCheckoutSession.java`:

```java
package org.example.service;

public class PayOSCheckoutSession {
    public final String checkoutUrl;
    public final String qrCode;
    public final Long expiredAt;
    public final long amount;

    public PayOSCheckoutSession(String checkoutUrl, String qrCode, Long expiredAt, long amount) {
        this.checkoutUrl = checkoutUrl;
        this.qrCode = qrCode;
        this.expiredAt = expiredAt;
        this.amount = amount;
    }
}
```

- [ ] **Step 2: Thêm method `createCheckoutSession` vào `PayOSService`**

Mở `src/main/java/org/example/service/PayOSService.java`, thêm method sau `createCheckoutUrl` (sau dòng 56):

```java
public PayOSCheckoutSession createCheckoutSession(int datSanId, long amount, String description,
                                                   String returnUrl, String cancelUrl) throws Exception {
    CreatePaymentLinkRequest request = CreatePaymentLinkRequest.builder()
            .orderCode((long) datSanId)
            .amount(amount)
            .description(description)
            .returnUrl(returnUrl)
            .cancelUrl(cancelUrl)
            .build();
    CreatePaymentLinkResponse result = payOS.paymentRequests().create(request);
    return new PayOSCheckoutSession(
            result.getCheckoutUrl(),
            result.getQrCode(),
            result.getExpiredAt(),
            result.getAmount()
    );
}
```

- [ ] **Step 3: Build project để kiểm tra compile**

Chạy trong thư mục gốc project:
```
mvn compile -q
```
Expected: BUILD SUCCESS, không có lỗi compile.

- [ ] **Step 4: Commit**

```bash
git add src/main/java/org/example/service/PayOSCheckoutSession.java src/main/java/org/example/service/PayOSService.java
git commit -m "feat: add PayOSCheckoutSession DTO and createCheckoutSession method"
```

---

## Task 2: Backend — Nhánh PayOS trả JSON + endpoint `/customer/payos-status`

**Files:**
- Modify: `src/main/java/org/example/controller/DatSanServlet.java` (dòng 658-696 và `doGet` section)

**Interfaces:**
- Consumes: `PayOSService.getInstance().createCheckoutSession(...)` → `PayOSCheckoutSession` (từ Task 1)
- Produces (POST `/customer/dat-san` với AJAX + `paymentMethod=payos`): `Content-Type: application/json` `{"success":true,"datSanId":123,"qrCode":"...","amount":200000,"expiredAt":1751234567}`
- Produces (POST lỗi với AJAX): `{"success":false,"error":"<message>"}`
- Produces (GET `/customer/payos-status?datSanId=X`): `{"status":"pending"|"paid"|"cancelled"}`

**Step 1: Sửa nhánh PayOS trong `handleDatSan` (dòng 658-696)**

- [ ] **Step 1a: Thay khối PayOS redirect thành JSON response**

Trong `DatSanServlet.java`, tìm đoạn bắt đầu từ dòng 658:
```java
if (isOnlineDeposit) {
    // ── PayOS: tạo payment link và redirect sang trang thanh toán ──
```

Thay toàn bộ khối `if (isOnlineDeposit) { ... } else { ... }` (dòng 658-701) bằng:

```java
boolean isAjax = "XMLHttpRequest".equals(req.getHeader("X-Requested-With"));

if (isOnlineDeposit) {
    // ── PayOS: tạo QR hoặc redirect tùy request type ──
    String scheme = req.getScheme();
    String serverName = req.getServerName();
    int port = req.getServerPort();
    String ctx = req.getContextPath();
    boolean defaultPort = (scheme.equals("http") && port == 80)
            || (scheme.equals("https") && port == 443);
    String baseUrl = scheme + "://" + serverName + (defaultPort ? "" : ":" + port) + ctx;

    String returnUrl = baseUrl + "/customer/payos-return?datSanId=" + newDatSanId;
    String cancelUrl = baseUrl + "/customer/payos-cancel?datSanId=" + newDatSanId;
    long amount = BigDecimal.valueOf(tongTien).setScale(0, java.math.RoundingMode.HALF_UP).longValue();
    String description = "VSport DS" + newDatSanId;

    try {
        long tPayOS0 = System.currentTimeMillis();
        org.example.service.PayOSCheckoutSession session2 =
                org.example.service.PayOSService.getInstance()
                        .createCheckoutSession(newDatSanId, amount, description, returnUrl, cancelUrl);
        LOGGER.info(String.format("handleDatSan: PayOS createCheckoutSession=%dms",
                System.currentTimeMillis() - tPayOS0));

        if (isAjax) {
            resp.setContentType("application/json; charset=UTF-8");
            resp.getWriter().write(String.format(
                    "{\"success\":true,\"datSanId\":%d,\"qrCode\":\"%s\",\"amount\":%d,\"expiredAt\":%s}",
                    newDatSanId,
                    session2.qrCode.replace("\"", "\\\""),
                    session2.amount,
                    session2.expiredAt != null ? session2.expiredAt.toString() : "null"
            ));
        } else {
            resp.sendRedirect(session2.checkoutUrl);
        }
    } catch (Exception payosEx) {
        LOGGER.log(Level.SEVERE, "PayOS tạo link thất bại, DatSanID=" + newDatSanId, payosEx);
        if (newDatSanId != -1) {
            try (java.sql.Connection cancelConn = org.example.util.DBUtil.getConnection()) {
                String cancelSql = "UPDATE LichDatSan SET TrangThai = N'Đã hủy', " +
                        "GhiChu = ISNULL(GhiChu, '') + N' [Tự động hủy: Không tạo được link thanh toán PayOS]' " +
                        "WHERE DatSanID = ? AND TrangThai = N'Chờ thanh toán'";
                try (java.sql.PreparedStatement cancelPs = cancelConn.prepareStatement(cancelSql)) {
                    cancelPs.setInt(1, newDatSanId);
                    cancelPs.executeUpdate();
                }
            } catch (Exception ignored) {}
        }
        if (isAjax) {
            resp.setContentType("application/json; charset=UTF-8");
            resp.getWriter().write("{\"success\":false,\"error\":\"Không thể tạo mã QR thanh toán. Vui lòng thử lại hoặc chọn thanh toán tại quầy.\"}");
        } else {
            session.setAttribute("error",
                    "Không thể tạo link thanh toán PayOS. Vui lòng thử lại hoặc chọn thanh toán tại quầy.");
            resp.sendRedirect(req.getContextPath() + "/customer/dat-san");
        }
    }
} else {
    session.setAttribute("message",
            "Đặt sân thành công! Lịch đặt bằng tiền mặt chỉ được giữ chỗ tạm thời. Vui lòng đến sớm 15 phút để làm thủ tục nhận sân.");
    resp.sendRedirect(req.getContextPath() + "/customer/lich-su-dat-san");
}
```

Lưu ý: biến `session` ở đây là `HttpSession session = req.getSession()` đã có trong scope, nhưng `session2` là tên biến mới tránh trùng.

- [ ] **Step 2: Thêm case GET `/customer/payos-status` vào `doGet`**

Trong `doGet`, sau dòng 114 (`} else if (path.equals("/customer/payos-cancel")) {`), thêm:

```java
} else if (path.equals("/customer/payos-status")) {
    handlePayOSStatus(req, resp, user);
}
```

- [ ] **Step 3: Thêm method `handlePayOSStatus`**

Thêm method mới vào class, ngay trước `handlePayOSReturn` (khoảng dòng 837):

```java
private void handlePayOSStatus(HttpServletRequest req, HttpServletResponse resp,
        org.example.model.Account user) throws IOException {
    resp.setContentType("application/json; charset=UTF-8");
    if (user == null) {
        resp.getWriter().write("{\"status\":\"error\",\"error\":\"Chưa đăng nhập\"}");
        return;
    }
    String paramId = req.getParameter("datSanId");
    int datSanId;
    try {
        datSanId = Integer.parseInt(paramId.trim());
    } catch (Exception e) {
        resp.getWriter().write("{\"status\":\"error\",\"error\":\"Thiếu datSanId\"}");
        return;
    }
    org.example.model.Lichdatsan lich = lichDatSanDAO.getLichById(datSanId);
    if (lich == null || lich.getAccountId() != user.getAccountId()) {
        resp.getWriter().write("{\"status\":\"error\",\"error\":\"Không tìm thấy đơn\"}");
        return;
    }
    String trangThai = lich.getTrangThai();
    String status;
    if ("Đã xác nhận".equals(trangThai)) {
        status = "paid";
    } else if ("Đã hủy".equals(trangThai)) {
        status = "cancelled";
    } else {
        status = "pending";
    }
    resp.getWriter().write("{\"status\":\"" + status + "\"}");
}
```

Kiểm tra `Lichdatsan` có method `getAccountId()` — nếu không có, dùng cách query thủ công với `getLichById` và so sánh field phù hợp (xem model để xác định field name chính xác).

- [ ] **Step 4: Build để kiểm tra compile**

```
mvn compile -q
```
Expected: BUILD SUCCESS.

- [ ] **Step 5: Commit**

```bash
git add src/main/java/org/example/controller/DatSanServlet.java
git commit -m "feat: DatSanServlet returns JSON for AJAX PayOS requests, add payos-status endpoint"
```

---

## Task 3: Frontend — HTML, QR view states, confirmBooking() fetch, poll

**Files:**
- Modify: `src/main/webapp/customer/DatSan.jsp`

**Interfaces:**
- Consumes: POST `/customer/dat-san` → `{success, datSanId, qrCode, amount, expiredAt}` (từ Task 2)
- Consumes: GET `/customer/payos-status?datSanId=X` → `{status}` (từ Task 2)
- Gọi: `closeBookingModal()`, `openHistoryModal()`, `backToBookingForm()` (đã có sẵn)

### Step 1: Nhúng thư viện qrcode

- [ ] **Step 1: Thêm script qrcode CDN trước thẻ đóng `</body>` của DatSan.jsp**

Tìm dòng kết thúc `</body>` (gần cuối file). Thêm vào trước nó:

```html
<script src="https://cdn.jsdelivr.net/npm/qrcode@1.5.3/build/qrcode.min.js"></script>
```

### Step 2: Thêm HTML block `#payos-qr-view`

- [ ] **Step 2: Thêm `#payos-qr-view` vào trong `checkoutPanel`**

Tìm trong `checkoutPanel` (dòng ~902), ngay TRƯỚC thẻ đóng `</div>` của `<div class="p-6 space-y-5">` (dòng 994 `</div>` trước `</div>` của checkoutPanel). Cụ thể: sau nút "Hoàn tất đặt sân" (dòng 990-993) và trước `</div></div>` đóng checkoutPanel.

Thêm block sau (đặt sau `</button>` của "Hoàn tất đặt sân", trước `</div>` đóng `p-6 space-y-5`):

```html
<!-- PayOS QR View — hiển thị thay thế nội dung checkout khi fetch thành công -->
<div id="payos-qr-view" class="hidden absolute inset-0 bg-white flex flex-col items-center justify-center p-6 gap-4 transition-all duration-300 opacity-0">

    <!-- Sub-state: QR hiển thị -->
    <div id="payos-qr-state" class="flex flex-col items-center gap-4 w-full">
        <p class="text-[10px] font-bold uppercase tracking-widest text-neutral-400 font-['Barlow_Condensed']">Quét mã QR để thanh toán</p>
        <canvas id="payos-qr-canvas" class="border border-neutral-200 p-2"></canvas>
        <div class="text-center space-y-1">
            <p class="text-2xl font-bold text-[#506600] font-['Barlow_Condensed']" id="payos-qr-amount">—</p>
            <p class="text-[11px] text-neutral-500">Dùng app ngân hàng bất kỳ để quét</p>
        </div>
        <div class="flex items-center gap-2 bg-amber-50 border border-amber-200 px-4 py-2">
            <span class="material-symbols-outlined text-[16px] text-amber-500">timer</span>
            <span class="text-xs font-bold text-amber-700" id="payos-countdown">--:--</span>
        </div>
    </div>

    <!-- Sub-state: Thanh toán thành công -->
    <div id="payos-success-state" class="hidden flex flex-col items-center gap-4 w-full text-center">
        <span class="material-symbols-outlined text-[56px] text-emerald-500 transition-transform duration-500 scale-0" id="payos-success-icon">check_circle</span>
        <div>
            <p class="text-base font-bold text-neutral-800 font-['Barlow_Condensed']">Thanh toán thành công!</p>
            <p class="text-[11px] text-neutral-500 mt-1">Sân đã được đặt và xác nhận.</p>
        </div>
        <button onclick="onPayOSSuccessConfirm()"
            class="w-full bg-[#506600] hover:bg-[#3d4d00] text-white font-['Barlow_Condensed'] font-bold py-3.5 text-[13px] uppercase tracking-widest transition-colors flex items-center justify-center gap-2">
            <span class="material-symbols-outlined text-[18px]">history</span> Xem lịch sử đặt sân
        </button>
    </div>

    <!-- Sub-state: QR hết hạn -->
    <div id="payos-expired-state" class="hidden flex flex-col items-center gap-4 w-full text-center">
        <span class="material-symbols-outlined text-[56px] text-neutral-400">timer_off</span>
        <div>
            <p class="text-base font-bold text-neutral-800 font-['Barlow_Condensed']">Mã QR đã hết hạn</p>
            <p class="text-[11px] text-neutral-500 mt-1">Đơn đặt sân đã bị hủy. Bạn có thể đặt lại.</p>
        </div>
        <button onclick="onPayOSExpiredRetry()"
            class="w-full border-2 border-[#506600] text-[#506600] font-['Barlow_Condensed'] font-bold py-3.5 text-[13px] uppercase tracking-widest hover:bg-[#506600]/5 transition-colors flex items-center justify-center gap-2">
            <span class="material-symbols-outlined text-[18px]">refresh</span> Đặt lại
        </button>
    </div>
</div>
```

Lưu ý `checkoutPanel` đã có `class="... relative ..."` — nếu chưa có `relative` thì thêm vào class của `checkoutPanel`.

### Step 3: Thêm `relative` vào `checkoutPanel` nếu thiếu

- [ ] **Step 3: Kiểm tra và thêm `relative` vào `checkoutPanel`**

Dòng 902 hiện tại:
```html
<div id="checkoutPanel" class="bg-white w-full max-w-md shadow-2xl overflow-hidden transform scale-95 transition-all duration-300 hidden relative my-auto"
```

`relative` đã có sẵn trong class → không cần thay đổi.

### Step 4: Sửa `confirmBooking()` dùng fetch cho PayOS

- [ ] **Step 4: Thay thế `confirmBooking()` (dòng 1790-1813)**

Tìm function `confirmBooking()` từ dòng 1790. Thay toàn bộ function bằng:

```javascript
function confirmBooking() {
    const form = document.getElementById('booking-form');
    if (!form) return;
    injectServiceInputsIntoForm(form);
    const btn = document.querySelector('button[onclick="confirmBooking()"]');
    const paymentMethod = document.getElementById('input-payment-method').value;
    const isPayOS = paymentMethod === 'payos';

    if (btn) {
        btn.disabled = true;
        btn.innerHTML = isPayOS
            ? '<span class="material-symbols-outlined text-[20px] animate-spin">progress_activity</span> Đang tạo mã QR...'
            : '<span class="material-symbols-outlined text-[20px] animate-spin">progress_activity</span> Đang xử lý...';
    }

    if (!isPayOS) {
        form.submit();
        return;
    }

    const info = document.getElementById('payment-info-payos');
    if (info) {
        info.innerHTML = '<div class="flex items-center justify-center gap-2 text-emerald-700 font-semibold text-sm py-1">' +
            '<span class="material-symbols-outlined text-[20px] animate-spin">progress_activity</span>' +
            '<span>Đang kết nối PayOS, vui lòng chờ...</span></div>';
    }

    const formData = new FormData(form);
    fetch(form.action, {
        method: 'POST',
        headers: { 'X-Requested-With': 'XMLHttpRequest' },
        body: formData
    })
    .then(function(r) { return r.json(); })
    .then(function(data) {
        if (!data.success) {
            if (btn) {
                btn.disabled = false;
                btn.innerHTML = '<span class="material-symbols-outlined text-[18px]">verified</span> Hoàn tất đặt sân';
            }
            if (info) {
                info.innerHTML = '<div class="flex items-start gap-2 text-red-700 text-xs font-semibold py-1">' +
                    '<span class="material-symbols-outlined text-[16px] flex-shrink-0 mt-0.5">error</span>' +
                    '<span>' + (data.error || 'Có lỗi xảy ra. Vui lòng thử lại.') + '</span></div>';
            }
            return;
        }
        showPayOSQrState(data);
    })
    .catch(function(err) {
        console.error('[PayOS] fetch error', err);
        if (btn) {
            btn.disabled = false;
            btn.innerHTML = '<span class="material-symbols-outlined text-[18px]">verified</span> Hoàn tất đặt sân';
        }
        if (info) {
            info.innerHTML = '<div class="flex items-start gap-2 text-red-700 text-xs font-semibold py-1">' +
                '<span class="material-symbols-outlined text-[16px] flex-shrink-0 mt-0.5">error</span>' +
                '<span>Lỗi kết nối. Vui lòng kiểm tra mạng và thử lại.</span></div>';
        }
    });
}
```

### Step 5: Thêm các function QR state management

- [ ] **Step 5: Thêm các function PayOS QR sau `confirmBooking()`**

Thêm ngay sau function `confirmBooking()` (sau dấu `}` đóng function, trước `function applyBranchTimeConstraints`):

```javascript
// ─── PayOS QR State Machine ───
var _payosCurrentDatSanId = null;
var _payosPollInterval = null;
var _payosCountdownInterval = null;

function showPayOSQrState(data) {
    _payosCurrentDatSanId = data.datSanId;

    // Fade nội dung checkout ra, hiện QR view
    var qrView = document.getElementById('payos-qr-view');
    var checkoutContent = document.querySelector('#checkoutPanel .p-6.space-y-5');

    // Ẩn nội dung form checkout
    if (checkoutContent) {
        checkoutContent.style.opacity = '0';
        checkoutContent.style.pointerEvents = 'none';
    }

    // Đảm bảo chỉ sub-state QR hiển thị
    document.getElementById('payos-qr-state').classList.remove('hidden');
    document.getElementById('payos-success-state').classList.add('hidden');
    document.getElementById('payos-expired-state').classList.add('hidden');

    // Hiện QR view với fade in
    qrView.classList.remove('hidden');
    setTimeout(function() { qrView.classList.remove('opacity-0'); }, 10);

    // Vẽ QR
    var canvas = document.getElementById('payos-qr-canvas');
    if (typeof QRCode !== 'undefined' && canvas) {
        QRCode.toCanvas(canvas, data.qrCode, { width: 220, margin: 1 }, function(err) {
            if (err) console.error('[PayOS] QR render error', err);
        });
    } else {
        canvas.parentNode.innerHTML = '<p class="text-xs text-red-600 text-center py-4">Không tải được thư viện QR. Vui lòng tải lại trang.</p>';
    }

    // Hiện số tiền
    var amountEl = document.getElementById('payos-qr-amount');
    if (amountEl) amountEl.textContent = Number(data.amount).toLocaleString('vi-VN') + ' đ';

    // Bắt đầu đồng hồ đếm ngược
    _payosCountdownInterval = setInterval(function() {
        if (!data.expiredAt) return;
        var now = Math.floor(Date.now() / 1000);
        var remaining = data.expiredAt - now;
        var el = document.getElementById('payos-countdown');
        if (remaining <= 0) {
            clearInterval(_payosCountdownInterval);
            clearInterval(_payosPollInterval);
            if (el) el.textContent = '00:00';
            showPayOSSubState('expired');
            return;
        }
        var m = Math.floor(remaining / 60), s = remaining % 60;
        if (el) el.textContent = String(m).padStart(2, '0') + ':' + String(s).padStart(2, '0');
    }, 1000);

    // Bắt đầu poll
    _payosPollInterval = setInterval(pollPayOSStatus, 3000);
}

function pollPayOSStatus() {
    if (!_payosCurrentDatSanId) return;
    fetch('<c:url value="/customer/payos-status"/>?datSanId=' + _payosCurrentDatSanId, {
        headers: { 'X-Requested-With': 'XMLHttpRequest' }
    })
    .then(function(r) { return r.json(); })
    .then(function(data) {
        if (data.status === 'paid') {
            clearInterval(_payosPollInterval);
            clearInterval(_payosCountdownInterval);
            showPayOSSubState('success');
        } else if (data.status === 'cancelled') {
            clearInterval(_payosPollInterval);
            clearInterval(_payosCountdownInterval);
            showPayOSSubState('expired');
        }
        // 'pending' → không làm gì, tiếp tục poll
    })
    .catch(function() { /* bỏ qua lỗi mạng, thử lại lần sau */ });
}

function showPayOSSubState(state) {
    document.getElementById('payos-qr-state').classList.add('hidden');
    document.getElementById('payos-success-state').classList.add('hidden');
    document.getElementById('payos-expired-state').classList.add('hidden');
    if (state === 'success') {
        document.getElementById('payos-success-state').classList.remove('hidden');
        // Animate check icon
        setTimeout(function() {
            var icon = document.getElementById('payos-success-icon');
            if (icon) icon.classList.remove('scale-0');
        }, 50);
    } else if (state === 'expired') {
        document.getElementById('payos-expired-state').classList.remove('hidden');
    }
}

function onPayOSSuccessConfirm() {
    _payosCurrentDatSanId = null;
    closeBookingModal();
    openHistoryModal();
}

function onPayOSExpiredRetry() {
    // Ẩn QR view, reset lại checkout panel
    var qrView = document.getElementById('payos-qr-view');
    qrView.classList.add('opacity-0');
    setTimeout(function() {
        qrView.classList.add('hidden');
        var checkoutContent = document.querySelector('#checkoutPanel .p-6.space-y-5');
        if (checkoutContent) {
            checkoutContent.style.opacity = '';
            checkoutContent.style.pointerEvents = '';
        }
        var btn = document.querySelector('button[onclick="confirmBooking()"]');
        if (btn) {
            btn.disabled = false;
            btn.innerHTML = '<span class="material-symbols-outlined text-[18px]">verified</span> Hoàn tất đặt sân';
        }
        var info = document.getElementById('payment-info-payos');
        if (info) {
            info.innerHTML = '<div class="w-8 h-8 bg-[#506600] flex items-center justify-center flex-shrink-0"><span class="material-symbols-outlined text-[16px] text-white">bolt</span></div>' +
                '<div><p class="text-xs font-bold text-neutral-800">Chuyển khoản — Giữ sân tức thì 10 phút</p>' +
                '<p class="text-[11px] text-neutral-500 mt-1 leading-relaxed">Mã QR sẽ được tạo tự động. Hoàn tất trong 10 phút để giữ sân.</p></div>';
        }
    }, 300);
    _payosCurrentDatSanId = null;
    backToBookingForm();
}
```

### Step 6: Cập nhật `closeBookingModal()` để clear interval

- [ ] **Step 6: Sửa `closeBookingModal()` (dòng 1655-1660)**

Tìm function `closeBookingModal()`:
```javascript
function closeBookingModal() {
    const overlay = document.getElementById("bookingModalOverlay");
    overlay.classList.add("opacity-0");
    document.querySelectorAll("#bookingFormPanel, #checkoutPanel").forEach(p => p.classList.add("scale-95"));
    setTimeout(() => overlay.classList.add("hidden"), 300);
}
```

Thêm cleanup intervals vào đầu function:
```javascript
function closeBookingModal() {
    if (_payosPollInterval) { clearInterval(_payosPollInterval); _payosPollInterval = null; }
    if (_payosCountdownInterval) { clearInterval(_payosCountdownInterval); _payosCountdownInterval = null; }
    _payosCurrentDatSanId = null;
    // Reset QR view nếu đang mở
    var qrView = document.getElementById('payos-qr-view');
    if (qrView && !qrView.classList.contains('hidden')) {
        qrView.classList.add('opacity-0', 'hidden');
        var checkoutContent = document.querySelector('#checkoutPanel .p-6.space-y-5');
        if (checkoutContent) { checkoutContent.style.opacity = ''; checkoutContent.style.pointerEvents = ''; }
    }
    const overlay = document.getElementById("bookingModalOverlay");
    overlay.classList.add("opacity-0");
    document.querySelectorAll("#bookingFormPanel, #checkoutPanel").forEach(p => p.classList.add("scale-95"));
    setTimeout(() => overlay.classList.add("hidden"), 300);
}
```

- [ ] **Step 7: Commit**

```bash
git add src/main/webapp/customer/DatSan.jsp
git commit -m "feat: PayOS inline QR checkout — QR view states, fetch submission, status polling"
```

---

## Task 4: Kiểm tra cuối và xác nhận

- [ ] **Step 1: Build và deploy**

```
mvn package -q
```
Deploy WAR lên server (Tomcat) và mở trang đặt sân.

- [ ] **Step 2: Kiểm tra luồng PayOS happy path**

1. Mở trang đặt sân, chọn sân + giờ, bấm "Tiếp tục thanh toán"
2. Trong checkout panel, chọn "PayOS", bấm "Hoàn tất đặt sân"
3. Kiểm tra: button đổi thành "Đang tạo mã QR...", spinner xuất hiện trong `payment-info-payos`
4. Sau vài giây: QR view fade in với canvas QR và đồng hồ đếm ngược
5. Mở DevTools → Network: không có redirect, chỉ có 1 POST `/customer/dat-san` trả JSON
6. Giả lập webhook: `POST /payos/webhook` với payload hợp lệ (code=00, amount khớp)
7. Trong ≤3s: state chuyển sang "Thanh toán thành công", check icon animate scale-in
8. Bấm "Xem lịch sử đặt sân": modal booking đóng, modal lịch sử mở, đơn hiển thị "Đã xác nhận"

- [ ] **Step 3: Kiểm tra luồng hết hạn**

1. Tạo QR như trên, đợi đồng hồ đếm ngược về 00:00 (hoặc đổi `expiredAt` về quá khứ để test nhanh)
2. Kiểm tra: chuyển sang sub-state "Hết hạn" tự động
3. Bấm "Đặt lại": QR view đóng, quay về form booking

- [ ] **Step 4: Kiểm tra không leak interval**

1. Mở QR view, bấm nút X đóng modal
2. Mở DevTools → Network: không còn request `/customer/payos-status` định kỳ

- [ ] **Step 5: Kiểm tra luồng "Tại quầy" không đổi**

1. Chọn "Thanh toán tại quầy", bấm "Hoàn tất đặt sân"
2. Kiểm tra: form submit bình thường (có redirect, flash message xuất hiện)

- [ ] **Step 6: Commit cuối nếu có fix**

```bash
git add -A
git commit -m "fix: post-testing adjustments for PayOS inline QR"
```
