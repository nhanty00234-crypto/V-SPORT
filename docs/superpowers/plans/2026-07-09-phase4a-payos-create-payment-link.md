# Phase 4A — payOS Create Payment Link Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** When a customer picks PayOS online and submits the booking form, create the `"Chờ thanh toán"` booking as today, then call the real payOS SDK to create a payment link and redirect the customer to `checkoutUrl`. If link creation fails, the just-created booking must not linger as a phantom hold — it gets flipped to `"Quá hạn"` immediately with a clear note, and the customer sees an error.

**Architecture:** New `org.example.service.PayOSService` wraps the official payOS Java SDK (verified from the SDK's real source on GitHub, not guessed). `DatSanServlet.handleDatSan` calls it only for `isOnlineDeposit == true`, **after** `conn.commit()` — never while holding the `San` row lock, since an HTTP call to a 3rd party inside a DB transaction would block other bookings on that court for the duration of the network call.

**Tech Stack:** Java 17, payOS Java SDK 2.0.1 (`vn.payos:payos-java`), JDBC.

## Global Constraints

- Never read/store/log `PAYOS_CLIENT_ID`/`PAYOS_API_KEY`/`PAYOS_CHECKSUM_KEY` ourselves — `PayOS.fromEnv()` reads them directly from the process environment; our code never touches the raw string values, so there is nothing to accidentally log or commit.
- No hard-coded key values anywhere, no `.env`-style file committed to the repo.
- No webhook, no `confirmBookingPayment`, no auto-transition to `"Đã xác nhận"` in this phase.
- Do not touch the Phase 3 auto-expire sweep (`BookingLifecycleService.runExpirySweep()`), the overlap-check, or any JSP/UI.
- payOS API call happens only for `isOnlineDeposit == true`; COD (`"sau"`) path is completely unchanged.
- `/customer/payos-return` and `/customer/payos-cancel` are **URLs only** in this phase (passed to payOS as `returnUrl`/`cancelUrl`) — no servlet handlers for them yet (that's a later phase, per "không làm webhook/confirm payment").

## Verified payOS Java SDK facts (fetched from https://github.com/payOSHQ/payos-lib-java and https://github.com/payOSHQ/payos-demo-java-spring — not guessed)

- Maven: `vn.payos:payos-java:2.0.1`.
- `PayOS client = PayOS.fromEnv();` — internally calls `ClientOptions.fromEnv()`, which reads `PAYOS_CLIENT_ID`, `PAYOS_API_KEY`, `PAYOS_CHECKSUM_KEY` via `System.getenv(...)` (with a `payos.client-id`-style system-property override checked first, env var as fallback). Throws `IllegalArgumentException` if any of the 3 are missing/blank.
- `CreatePaymentLinkRequest.builder().orderCode(long).amount(long).description(String).returnUrl(String).cancelUrl(String).build()` — `vn.payos.model.v2.paymentRequests.CreatePaymentLinkRequest`.
- `client.paymentRequests().create(request)` returns `CreatePaymentLinkResponse` (`vn.payos.model.v2.paymentRequests.CreatePaymentLinkResponse`), Lombok `@Data` so standard getters exist: `getCheckoutUrl()`, `getPaymentLinkId()`, `getOrderCode()`, etc. (confirmed from the model's real source file).
- Errors: `vn.payos.exception.PayOSException extends RuntimeException` (unchecked), plus subclasses (`APIException`, `ConnectionException`, ...). `ClientOptions.fromEnv()`'s missing-config error is a separate `IllegalArgumentException`. A single broad `catch (Exception e)` covers both, matching payOS's own demo controller.

---

### Task 1: Add the payOS Maven dependency

**Files:**
- Modify: `pom.xml`

- [ ] **Step 1**

Add inside `<dependencies>`, after the `gson` dependency block:
```xml
        <!-- payOS Java SDK - tạo link thanh toán online -->
        <dependency>
            <groupId>vn.payos</groupId>
            <artifactId>payos-java</artifactId>
            <version>2.0.1</version>
        </dependency>
```

- [ ] **Step 2: Verify**

Run yourself: `mvn -q dependency:tree | grep payos` → expect `vn.payos:payos-java:jar:2.0.1:compile` plus its transitive deps (okhttp3, jackson).

- [ ] **Step 3: Commit**
```bash
git add pom.xml
git commit -m "Add payOS Java SDK dependency (vn.payos:payos-java:2.0.1)"
```

---

### Task 2: `PayOSService` — wraps the SDK, never touches raw key values

**Files:**
- Create: `src/main/java/org/example/service/PayOSService.java`

**Interfaces:**
- Produces: `PayOSService.createPaymentLink(long orderCode, long amountVnd, String description, String returnUrl, String cancelUrl)` → `PayOSService.PaymentLinkResult { checkoutUrl, paymentLinkId, orderCode }`, throws `PayOSService.PayOSLinkCreationException` (checked) on any failure.

- [ ] **Step 1: Write the class**
```java
package org.example.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import vn.payos.PayOS;
import vn.payos.model.v2.paymentRequests.CreatePaymentLinkRequest;
import vn.payos.model.v2.paymentRequests.CreatePaymentLinkResponse;

/**
 * Dịch vụ gọi payOS để tạo link thanh toán online cho đơn đặt sân "Chờ thanh toán".
 * PAYOS_CLIENT_ID / PAYOS_API_KEY / PAYOS_CHECKSUM_KEY được PayOS.fromEnv() tự đọc
 * trực tiếp từ biến môi trường — class này không bao giờ đọc/giữ/log giá trị 3 key đó.
 */
public class PayOSService {

    private static final Logger logger = LoggerFactory.getLogger(PayOSService.class);

    private PayOSService() {
    }

    /** Kết quả tạo link thanh toán thành công. */
    public static class PaymentLinkResult {
        public final String checkoutUrl;
        public final String paymentLinkId;
        public final long orderCode;

        public PaymentLinkResult(String checkoutUrl, String paymentLinkId, long orderCode) {
            this.checkoutUrl = checkoutUrl;
            this.paymentLinkId = paymentLinkId;
            this.orderCode = orderCode;
        }
    }

    /** Ném ra khi không thể tạo link thanh toán (thiếu cấu hình PAYOS_*, lỗi mạng, payOS từ chối...). */
    public static class PayOSLinkCreationException extends Exception {
        public PayOSLinkCreationException(String message, Throwable cause) {
            super(message, cause);
        }
    }

    /**
     * Gọi payOS tạo link thanh toán cho 1 đơn đặt sân.
     * amountVnd phải là số nguyên VND (payOS không chấp nhận số thập phân).
     */
    public static PaymentLinkResult createPaymentLink(long orderCode, long amountVnd, String description,
                                                        String returnUrl, String cancelUrl)
            throws PayOSLinkCreationException {
        try {
            PayOS client = PayOS.fromEnv();
            CreatePaymentLinkRequest request = CreatePaymentLinkRequest.builder()
                    .orderCode(orderCode)
                    .amount(amountVnd)
                    .description(description)
                    .returnUrl(returnUrl)
                    .cancelUrl(cancelUrl)
                    .build();
            CreatePaymentLinkResponse response = client.paymentRequests().create(request);
            return new PaymentLinkResult(response.getCheckoutUrl(), response.getPaymentLinkId(), orderCode);
        } catch (Exception e) {
            logger.error("Tạo link thanh toán payOS thất bại (orderCode={}): {}", orderCode, e.getMessage());
            throw new PayOSLinkCreationException("Không thể tạo link thanh toán payOS", e);
        }
    }
}
```

Note: `PayOS.fromEnv()` is called fresh on every request (no static caching) — this is a low-traffic path (only on `paymentMethod=payos` submits), avoids any static-mutable-state/synchronization concerns, and means a missing env var never crashes app startup, only surfaces as a graceful error on first actual PayOS booking attempt.

- [ ] **Step 2: Commit**
```bash
git add src/main/java/org/example/service/PayOSService.java
git commit -m "Add PayOSService wrapping the payOS SDK for payment-link creation"
```

---

### Task 3: Wire it into `DatSanServlet.handleDatSan`

**Files:**
- Modify: `src/main/java/org/example/controller/DatSanServlet.java`

**Interfaces:**
- Consumes: `PayOSService.createPaymentLink(...)`, `PayOSService.PaymentLinkResult`, `PayOSService.PayOSLinkCreationException`.

- [ ] **Step 1: Retrieve the generated `DatSanID` from the insert** (needed as `orderCode`)

Change the insert `PreparedStatement` to request generated keys, capture `tongTienRounded` as a named variable (reused later for the payOS amount, avoiding recomputation/drift), and read back the new ID:
```java
                    BigDecimal tongTienRounded = BigDecimal.valueOf(tongTien).setScale(0, java.math.RoundingMode.HALF_UP);
                    int newDatSanId = -1;
                    try (java.sql.PreparedStatement insertPs = conn.prepareStatement(insertSql, java.sql.Statement.RETURN_GENERATED_KEYS)) {
                        insertPs.setInt(1, user.getAccountId());
                        insertPs.setInt(2, sanId);
                        insertPs.setDate(3, java.sql.Date.valueOf(ngayDat));
                        insertPs.setTime(4, java.sql.Time.valueOf(gioBatDau));
                        insertPs.setTime(5, java.sql.Time.valueOf(gioKetThuc));
                        insertPs.setBoolean(6, applyLights);
                        insertPs.setBigDecimal(7, tongTienRounded);
                        insertPs.setString(8, initialStatus);
                        insertPs.setString(9, ghiChu != null ? ghiChu.trim() : "");
                        insertPs.setString(10, "Web");
                        insertPs.executeUpdate();
                        try (java.sql.ResultSet generatedKeys = insertPs.getGeneratedKeys()) {
                            if (generatedKeys.next()) {
                                newDatSanId = generatedKeys.getInt(1);
                            }
                        }
                    }
```
(Replaces the current insert block that used `BigDecimal.valueOf(tongTien).setScale(...)` inline and a plain `conn.prepareStatement(insertSql)`.)

- [ ] **Step 2: Replace the `isOnlineDeposit` success-message branch with the payOS call**

Current code (post Phase 2):
```java
                    if (isOnlineDeposit) {
                        session.setAttribute("message",
                                "Đăng ký đặt sân thành công! Vui lòng tiến hành quét mã QR thanh toán trong vòng " +
                                        org.example.util.Constants.BOOKING_HOLD_MINUTES + " phút để giữ chỗ.");
                    } else {
                        session.setAttribute("message",
                                "Đặt sân thành công! Lịch đặt bằng tiền mặt chỉ được giữ chỗ tạm thời. Vui lòng đến sớm 15 phút để làm thủ tục nhận sân.");
                    }
                    resp.sendRedirect(req.getContextPath() + "/customer/lich-su-dat-san");
                    return;
```
New:
```java
                    if (isOnlineDeposit) {
                        long orderCode = newDatSanId > 0 ? newDatSanId : (System.currentTimeMillis() / 1000);
                        String description = "VSport DS" + newDatSanId;
                        if (description.length() > 25) {
                            description = description.substring(0, 25);
                        }
                        String baseUrl = getBaseUrl(req);
                        String returnUrl = baseUrl + "/customer/payos-return?datSanId=" + newDatSanId;
                        String cancelUrl = baseUrl + "/customer/payos-cancel?datSanId=" + newDatSanId;

                        try {
                            org.example.service.PayOSService.PaymentLinkResult link =
                                    org.example.service.PayOSService.createPaymentLink(
                                            orderCode, tongTienRounded.longValueExact(), description, returnUrl, cancelUrl);
                            saveTransactionCode(newDatSanId, link.paymentLinkId);
                            resp.sendRedirect(link.checkoutUrl);
                            return;
                        } catch (org.example.service.PayOSService.PayOSLinkCreationException payosEx) {
                            LOGGER.log(Level.SEVERE, "Tạo link thanh toán payOS thất bại cho DatSanID=" + newDatSanId, payosEx);
                            expireBookingAfterPaymentLinkFailure(newDatSanId, "Không tạo được link thanh toán payOS");
                            session.setAttribute("error",
                                    "Không thể tạo link thanh toán lúc này. Đơn giữ chỗ đã được hủy, vui lòng thử đặt lại.");
                            resp.sendRedirect(req.getContextPath() + "/customer/dat-san");
                            return;
                        }
                    }

                    session.setAttribute("message",
                            "Đặt sân thành công! Lịch đặt bằng tiền mặt chỉ được giữ chỗ tạm thời. Vui lòng đến sớm 15 phút để làm thủ tục nhận sân.");
                    resp.sendRedirect(req.getContextPath() + "/customer/lich-su-dat-san");
                    return;
```

- [ ] **Step 3: Add 3 small private helpers** (PHẦN 5: UTILITY METHODS section, near `parsePositiveIntParam`)

```java
    /** Xây base URL (scheme://host:port/contextPath) để tạo returnUrl/cancelUrl tuyệt đối cho payOS. */
    private String getBaseUrl(HttpServletRequest req) {
        String scheme = req.getScheme();
        String serverName = req.getServerName();
        int serverPort = req.getServerPort();
        String contextPath = req.getContextPath();

        String url = scheme + "://" + serverName;
        if (("http".equals(scheme) && serverPort != 80) || ("https".equals(scheme) && serverPort != 443)) {
            url += ":" + serverPort;
        }
        url += contextPath;
        return url;
    }

    private void saveTransactionCode(int datSanId, String transactionCode) {
        String sql = "UPDATE LichDatSan SET TransactionCode = ? WHERE DatSanID = ?";
        try (java.sql.Connection conn = org.example.util.DBUtil.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, transactionCode);
            ps.setInt(2, datSanId);
            ps.executeUpdate();
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Không thể lưu TransactionCode cho DatSanID=" + datSanId, e);
        }
    }

    private void expireBookingAfterPaymentLinkFailure(int datSanId, String reason) {
        String sql = "UPDATE LichDatSan SET TrangThai = ?, " +
                "GhiChu = CONCAT(ISNULL(GhiChu, N''), ?) " +
                "WHERE DatSanID = ? AND TrangThai = ?";
        try (java.sql.Connection conn = org.example.util.DBUtil.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, org.example.util.Constants.TRANG_THAI_DAT_SAN_QUA_HAN);
            ps.setString(2, " [Tự động hủy: " + reason + "]");
            ps.setInt(3, datSanId);
            ps.setString(4, org.example.util.Constants.TRANG_THAI_DAT_SAN_CHO_THANH_TOAN);
            ps.executeUpdate();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Không thể tự hủy booking #" + datSanId + " sau khi tạo link payOS thất bại", e);
        }
    }
```

`expireBookingAfterPaymentLinkFailure`'s `WHERE ... AND TrangThai = 'Chờ thanh toán'` guard is defensive: if Phase 3's sweep already flipped this exact row to `"Quá hạn"` in the tiny window between our commit and this failure handler running, we don't want to blindly overwrite/double-append `GhiChu`.

- [ ] **Step 4: Verify by manual trace + compile**

Trace: (a) COD path (`isOnlineDeposit=false`) — completely unchanged, never touches `PayOSService`. (b) PayOS success — booking committed as `"Chờ thanh toán"` with real `HoldExpiresAt`, then payOS called with `orderCode=DatSanID`, on success `TransactionCode` gets `paymentLinkId`, customer redirected to `checkoutUrl` (external URL, not `resp.sendRedirect(req.getContextPath() + ...)`) — never auto-set to `"Đã xác nhận"`. (c) PayOS failure — booking flips to `"Quá hạn"` with a clear `GhiChu`, customer sees an error and is redirected back to `/customer/dat-san`, no phantom 10-minute hold survives.

Run yourself: `mvn -q clean compile` → expect `BUILD SUCCESS`.

- [ ] **Step 5: Commit**
```bash
git add src/main/java/org/example/controller/DatSanServlet.java
git commit -m "Call payOS to create a real payment link for online-deposit bookings

Retrieves the generated DatSanID to use as orderCode. On success,
redirects to payOS's checkoutUrl and persists paymentLinkId into
TransactionCode. On failure, immediately flips the just-created
booking to Quá hạn (never leaves a phantom Chờ thanh toán hold) and
shows the customer a clear error. COD path is untouched. The payOS
call happens after conn.commit(), never while holding the San row
lock, to avoid blocking other bookings on that court during network I/O."
```

---

## Self-Review Notes

- **Spec coverage**: items 1-7 and 9-11 covered exactly. Item 8 (no webhook) respected — `/customer/payos-return`/`/customer/payos-cancel` are URL strings only, no handlers added.
- **Security**: `PAYOS_CLIENT_ID`/`PAYOS_API_KEY`/`PAYOS_CHECKSUM_KEY` are never read, stored, or logged by our own code — `PayOS.fromEnv()` handles this entirely inside the SDK.
- **Placeholder scan**: none.
- **Type consistency**: `PaymentLinkResult` fields (`checkoutUrl`, `paymentLinkId`, `orderCode`) match exactly what Task 3 reads (`link.checkoutUrl`, `link.paymentLinkId`).
