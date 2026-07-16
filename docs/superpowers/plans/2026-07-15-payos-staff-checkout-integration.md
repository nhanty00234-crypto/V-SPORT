# PayOS Staff/Manager Checkout Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the manual "Chuyển khoản" option in the Manager/Staff "Thanh toán & Dịch vụ" modal with real PayOS payments, using each Cơ Sở's own PayOS credentials (already configurable by Admin via `PayOSConfigurationService`), confirmed only by PayOS webhook/API — never by client-side trust.

**Architecture:**
- A new `PayOSPaymentAttempt` table tracks the lifecycle of each PayOS payment (CREATING → PENDING → PAID/CANCELLED/EXPIRED/FAILED), keyed by a DB-generated unique `OrderCode`. It is the single source of truth for "has this invoice already got an active PayOS link" — reused instead of re-created.
- `PayOSClientFactory` builds a fresh `vn.payos.PayOS` SDK client per operation from `PayOSConfigurationService.getCredentialsForPayment(coSoId)` — no caching, no global singleton, no env vars for this path.
- `PayOSPaymentService` (create/reuse a payment link) and `PayOSPaymentFinalizationService` (the ONE place that marks an invoice paid) live in a new `org.example.service.payos` package and reuse `CheckoutService`'s existing lock/finalize logic via one new public wrapper method — no duplicated SQL.
- `PayOSWebhookServlet` is restructured to resolve `orderCode → PayOSPaymentAttempt → CoSoID → that CoSo's checksum key` before trusting anything in the payload, while the existing global-credential customer-booking webhook path is preserved untouched as a fallback for orderCodes that aren't in the new attempt table (old flow keeps working).
- `CheckInServlet` gets three new actions (`createPayOSPayment`, `getPayOSPaymentStatus`, and static return/cancel landing pages) that mirror the existing `initBankTransfer`/`confirmBankTransfer` action shapes.
- `CheckIn.jsp` gets a new `AWAITING_PAYOS`/`CREATING_PAYOS`/`VERIFYING_PAYOS` branch in the existing payment modal state machine, mirroring the already-built `AWAITING_TRANSFER` panel/footer, plus a client-side QR renderer (new CDN library) so the real PayOS `qrCode` payload is drawn as an actual QR image in-modal (no `img.vietqr.io`, no fabricated bank QR).

**Tech Stack:** Java 17, `vn.payos:payos-java:2.0.1` (already a dependency), Jakarta Servlet, JSP, Gson, raw JDBC via `DBUtil`, `qrcode` JS library via CDN (new, client-side only, MIT-licensed) for rendering the real PayOS QR payload string into a QR image.

## Global Constraints

- Manager (RoleID=2) and Staff (RoleID=4) only. Backend re-derives CoSoID from `user.getCoSoId()` — never trusts a CoSoID/amount/credential from the request body.
- Invoice/booking/court are only flipped to paid/completed/ready by `PayOSPaymentFinalizationService`, called exclusively from the verified webhook path and the verified polling path (never from `createPayOSPayment`, never from returnUrl/cancelUrl).
- `PayOSCredentials` (raw secrets) never appear in a log statement, exception message, AuditLog entry, response JSON, or `PayOSPaymentAttempt` row.
- `CoSoNganHang` and the `0909123456` placeholder account are not touched by any PayOS code path.
- Cash flow (`CheckoutService.pay`, `handleProcessPayment`) is not modified. The existing bank-transfer backend code (`BankTransferInit`, `BankTransferConfirm`, `CoSoNganHangDAO`, `initBankTransfer`/`confirmBankTransfer`/`cancelBankTransfer` actions) stays in the repo untouched — only the JSP button that used to trigger it is relabeled/rewired to PayOS.
- `orderCode` is DB-generated (IDENTITY-backed), globally unique, and traceable back to exactly one `PayOSPaymentAttempt` row — never `System.currentTimeMillis()` alone, never the raw `DatSanID` (that scheme stays reserved for the legacy customer-booking flow, kept working unmodified).
- All new AJAX responses are `application/json;charset=UTF-8` with real HTTP status codes (409/422/403/404/500 as appropriate), never `sendError` HTML.
- No DB migration is run by the assistant — this sandbox has no live SQL Server connection. The migration script is idempotent (`IF NOT EXISTS`) for the user to run once.
- UI: one primary action per modal state, footer always visible, no card-inside-card, no purple wash, fits 1366×768 without clipping, matches the *existing* CheckIn.jsp visual language exactly (same theme vars, same badge classes, same Material Symbols icon set) — this is an operational tool, not a landing page.

---

### Task 1: SQL migration — `PayOSPaymentAttempt` table

**Files:**
- Create: `sql/migration_payos_payment_attempt.sql`

- [ ] **Step 1: Write the idempotent migration**

```sql
-- Migration: Bảng theo dõi vòng đời thanh toán PayOS cho luồng Checkout Manager/Staff
-- (KHÔNG dùng cho luồng đặt sân online của khách hàng - luồng đó vẫn dùng DatSanID làm orderCode
--  và credentials PayOS toàn cục qua biến môi trường, không đổi trong migration này.)
-- Chạy một lần trên DB thực. Script có kiểm tra IF NOT EXISTS nên an toàn khi chạy lại.

USE QuanLiSport;
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = N'PayOSPaymentAttempt')
BEGIN
    CREATE TABLE PayOSPaymentAttempt (
        AttemptID       BIGINT IDENTITY(1,1) PRIMARY KEY,
        HoaDonID        INT NOT NULL,
        DatSanID        INT NOT NULL,
        CoSoID          INT NOT NULL,
        OrderCode       BIGINT NOT NULL,
        PaymentLinkID   NVARCHAR(100) NULL,
        CheckoutUrl     NVARCHAR(1000) NULL,
        -- QrCode: PayOS chỉ trả chuỗi QR (payload VietQR) tại thời điểm TẠO link; API "get theo
        -- orderCode" (dùng khi tái sử dụng / polling) KHÔNG trả lại QR. Phải lưu lại ở đây để mở lại
        -- modal / tái sử dụng attempt PENDING không cần tạo link mới (mục VII của yêu cầu).
        QrCode          NVARCHAR(MAX) NULL,
        Status          NVARCHAR(30) NOT NULL,
        Amount          DECIMAL(18,2) NOT NULL,
        Description     NVARCHAR(100) NOT NULL,
        CreatedAt       DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        PaidAt          DATETIME2 NULL,
        CancelledAt     DATETIME2 NULL,
        LastCheckedAt   DATETIME2 NULL,
        FailureReason   NVARCHAR(500) NULL,
        CONSTRAINT FK_PayOSPaymentAttempt_HoaDon FOREIGN KEY (HoaDonID) REFERENCES HoaDon(HoaDonID),
        CONSTRAINT FK_PayOSPaymentAttempt_LichDatSan FOREIGN KEY (DatSanID) REFERENCES LichDatSan(DatSanID),
        CONSTRAINT FK_PayOSPaymentAttempt_CoSo FOREIGN KEY (CoSoID) REFERENCES CoSo(CoSoID)
    );
    PRINT N'Đã tạo bảng PayOSPaymentAttempt.';
END
ELSE
    PRINT N'Bảng PayOSPaymentAttempt đã tồn tại, bỏ qua.';
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UQ_PayOSPaymentAttempt_OrderCode')
BEGIN
    CREATE UNIQUE INDEX UQ_PayOSPaymentAttempt_OrderCode ON PayOSPaymentAttempt(OrderCode);
    PRINT N'Đã tạo UNIQUE INDEX UQ_PayOSPaymentAttempt_OrderCode.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_PayOSPaymentAttempt_HoaDonID')
BEGIN
    CREATE INDEX IX_PayOSPaymentAttempt_HoaDonID ON PayOSPaymentAttempt(HoaDonID);
    PRINT N'Đã tạo INDEX IX_PayOSPaymentAttempt_HoaDonID.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_PayOSPaymentAttempt_PaymentLinkID')
BEGIN
    CREATE INDEX IX_PayOSPaymentAttempt_PaymentLinkID ON PayOSPaymentAttempt(PaymentLinkID);
    PRINT N'Đã tạo INDEX IX_PayOSPaymentAttempt_PaymentLinkID.';
END
GO

-- Chỉ cho phép TỐI ĐA một attempt đang "sống" (CREATING/PENDING) cho mỗi hóa đơn - chặn double-click
-- và hai nhân viên bấm gần như đồng thời tạo ra hai payment link cho cùng một HoaDonID ở tầng DB,
-- không chỉ dựa vào lock ứng dụng.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UQ_PayOSPaymentAttempt_OneActivePerInvoice')
BEGIN
    CREATE UNIQUE INDEX UQ_PayOSPaymentAttempt_OneActivePerInvoice
        ON PayOSPaymentAttempt(HoaDonID)
        WHERE Status IN (N'CREATING', N'PENDING');
    PRINT N'Đã tạo UNIQUE FILTERED INDEX UQ_PayOSPaymentAttempt_OneActivePerInvoice.';
END
GO
```

- [ ] **Step 2: No execution here** — no live DB connection in this sandbox. Flag to the user: run this once via SSMS/sqlcmd before testing (same as the other `sql/migration_*.sql` files already in this repo).

---

### Task 2: DTOs — attempt status enum, view, result wrappers

**Files:**
- Create: `src/main/java/org/example/dto/payment/PayOSPaymentAttemptStatus.java`
- Create: `src/main/java/org/example/dto/payment/PayOSPaymentAttemptView.java`
- Create: `src/main/java/org/example/dto/payment/PayOSCreatePaymentResult.java`
- Create: `src/main/java/org/example/dto/payment/PayOSFinalizeResult.java`

- [ ] **Step 1: `PayOSPaymentAttemptStatus.java`**

```java
package org.example.dto.payment;

public enum PayOSPaymentAttemptStatus {
    CREATING, PENDING, PAID, CANCELLED, EXPIRED, FAILED
}
```

- [ ] **Step 2: `PayOSPaymentAttemptView.java`** (safe to serialize — no secrets)

```java
package org.example.dto.payment;

import java.math.BigDecimal;

public final class PayOSPaymentAttemptView {
    private final int hoaDonId;
    private final long orderCode;
    private final String paymentLinkId;
    private final String checkoutUrl;
    private final String qrCode;
    private final BigDecimal amount;
    private final String description;
    private final PayOSPaymentAttemptStatus status;

    public PayOSPaymentAttemptView(int hoaDonId, long orderCode, String paymentLinkId, String checkoutUrl,
                                    String qrCode, BigDecimal amount, String description,
                                    PayOSPaymentAttemptStatus status) {
        this.hoaDonId = hoaDonId;
        this.orderCode = orderCode;
        this.paymentLinkId = paymentLinkId;
        this.checkoutUrl = checkoutUrl;
        this.qrCode = qrCode;
        this.amount = amount;
        this.description = description;
        this.status = status;
    }

    public int getHoaDonId() { return hoaDonId; }
    public long getOrderCode() { return orderCode; }
    public String getPaymentLinkId() { return paymentLinkId; }
    public String getCheckoutUrl() { return checkoutUrl; }
    public String getQrCode() { return qrCode; }
    public BigDecimal getAmount() { return amount; }
    public String getDescription() { return description; }
    public PayOSPaymentAttemptStatus getStatus() { return status; }
}
```

- [ ] **Step 3: `PayOSCreatePaymentResult.java`**

```java
package org.example.dto.payment;

public final class PayOSCreatePaymentResult {
    private final boolean success;
    private final int httpStatus;
    private final String code;
    private final String message;
    private final PayOSPaymentAttemptView payment;

    private PayOSCreatePaymentResult(boolean success, int httpStatus, String code, String message,
                                      PayOSPaymentAttemptView payment) {
        this.success = success;
        this.httpStatus = httpStatus;
        this.code = code;
        this.message = message;
        this.payment = payment;
    }

    public static PayOSCreatePaymentResult ok(PayOSPaymentAttemptView payment) {
        return new PayOSCreatePaymentResult(true, 200, null, null, payment);
    }

    public static PayOSCreatePaymentResult fail(int httpStatus, String code, String message) {
        return new PayOSCreatePaymentResult(false, httpStatus, code, message, null);
    }

    public boolean isSuccess() { return success; }
    public int getHttpStatus() { return httpStatus; }
    public String getCode() { return code; }
    public String getMessage() { return message; }
    public PayOSPaymentAttemptView getPayment() { return payment; }
}
```

- [ ] **Step 4: `PayOSFinalizeResult.java`**

```java
package org.example.dto.payment;

public final class PayOSFinalizeResult {
    private final boolean success;
    private final boolean alreadyPaid;
    private final String code;
    private final String message;
    private final Integer hoaDonId;

    private PayOSFinalizeResult(boolean success, boolean alreadyPaid, String code, String message, Integer hoaDonId) {
        this.success = success;
        this.alreadyPaid = alreadyPaid;
        this.code = code;
        this.message = message;
        this.hoaDonId = hoaDonId;
    }

    public static PayOSFinalizeResult ok(int hoaDonId, boolean alreadyPaid) {
        return new PayOSFinalizeResult(true, alreadyPaid, null, null, hoaDonId);
    }

    public static PayOSFinalizeResult fail(String code, String message) {
        return new PayOSFinalizeResult(false, false, code, message, null);
    }

    public boolean isSuccess() { return success; }
    public boolean isAlreadyPaid() { return alreadyPaid; }
    public String getCode() { return code; }
    public String getMessage() { return message; }
    public Integer getHoaDonId() { return hoaDonId; }
}
```

- [ ] **Step 5: Compile check** — `mvn -q compile` → BUILD SUCCESS.

---

### Task 3: `PayOSPaymentAttemptDAO` + Impl (raw JDBC, transaction-shared)

**Files:**
- Create: `src/main/java/org/example/dao/PayOSPaymentAttemptDAO.java`
- Create: `src/main/java/org/example/dao/impl/PayOSPaymentAttemptDAOImpl.java`

**Interfaces:**
- Consumes: an externally-managed `Connection` (caller owns the transaction — matches `CheckoutService`'s pattern) so lock+insert+update all happen inside the same transaction as the invoice/booking locks.
- Produces: `findActiveByHoaDonId`, `insertCreating`, `markPending`, `findByOrderCode`, `markPaid`, `markCancelledOrExpired` — used by Task 5 (`PayOSPaymentService`) and Task 6 (`PayOSPaymentFinalizationService`).

- [ ] **Step 1: Create the interface**

```java
package org.example.dao;

import org.example.dto.payment.PayOSPaymentAttemptStatus;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;

public interface PayOSPaymentAttemptDAO {

    final class Row {
        public long attemptId;
        public int hoaDonId;
        public int datSanId;
        public int coSoId;
        public long orderCode;
        public String paymentLinkId;
        public String checkoutUrl;
        public String qrCode;
        public PayOSPaymentAttemptStatus status;
        public BigDecimal amount;
        public String description;
    }

    /** Khóa (UPDLOCK, ROWLOCK) và trả về attempt CREATING/PENDING đang sống cho hóa đơn này, null nếu không có. */
    Row findActiveByHoaDonId(Connection c, int hoaDonId) throws SQLException;

    /** Tạo attempt mới ở trạng thái CREATING, orderCode sinh từ AttemptID (IDENTITY) → duy nhất, truy ngược được. Trả về orderCode. */
    long insertCreating(Connection c, int hoaDonId, int datSanId, int coSoId, BigDecimal amount, String description) throws SQLException;

    /** Sau khi PayOS tạo link thành công: gắn paymentLinkId/checkoutUrl/qrCode, chuyển CREATING -> PENDING. */
    void markPending(Connection c, long orderCode, String paymentLinkId, String checkoutUrl, String qrCode) throws SQLException;

    /** Khóa (UPDLOCK, ROWLOCK) và đọc attempt theo orderCode - dùng bởi finalize/polling/webhook. Null nếu không tồn tại. */
    Row findByOrderCode(Connection c, long orderCode) throws SQLException;

    /** Idempotent: CREATING/PENDING -> PAID. Trả về false nếu đã PAID từ trước (không update lại). */
    boolean markPaid(Connection c, long orderCode) throws SQLException;

    /** CREATING/PENDING -> CANCELLED hoặc EXPIRED (không đụng nếu đã PAID). */
    void markCancelledOrExpired(Connection c, long orderCode, PayOSPaymentAttemptStatus status) throws SQLException;

    void touchLastChecked(Connection c, long orderCode) throws SQLException;
}
```

- [ ] **Step 2: Create the implementation**

```java
package org.example.dao.impl;

import org.example.dao.PayOSPaymentAttemptDAO;
import org.example.dto.payment.PayOSPaymentAttemptStatus;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class PayOSPaymentAttemptDAOImpl implements PayOSPaymentAttemptDAO {

    @Override
    public Row findActiveByHoaDonId(Connection c, int hoaDonId) throws SQLException {
        String sql = "SELECT TOP 1 AttemptID, HoaDonID, DatSanID, CoSoID, OrderCode, PaymentLinkID, CheckoutUrl, " +
                "QrCode, Status, Amount, Description FROM PayOSPaymentAttempt WITH (UPDLOCK, ROWLOCK) " +
                "WHERE HoaDonID = ? AND Status IN (N'CREATING', N'PENDING') ORDER BY AttemptID DESC";
        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, hoaDonId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        }
    }

    @Override
    public long insertCreating(Connection c, int hoaDonId, int datSanId, int coSoId, BigDecimal amount, String description) throws SQLException {
        String insertSql = "INSERT INTO PayOSPaymentAttempt (HoaDonID, DatSanID, CoSoID, OrderCode, Status, Amount, Description) " +
                "VALUES (?, ?, ?, 0, N'CREATING', ?, ?)";
        long attemptId;
        try (PreparedStatement ps = c.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, hoaDonId);
            ps.setInt(2, datSanId);
            ps.setInt(3, coSoId);
            ps.setBigDecimal(4, amount);
            ps.setNString(5, description);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (!keys.next()) throw new SQLException("Không lấy được AttemptID vừa tạo.");
                attemptId = keys.getLong(1);
            }
        }
        // orderCode = offset lớn + AttemptID: duy nhất tuyệt đối (IDENTITY), truy ngược trực tiếp về
        // attempt, và tách biệt hẳn khỏi orderCode=DatSanID của luồng đặt sân online khách hàng (số
        // nhỏ) để webhook không bao giờ nhầm lẫn hai luồng.
        long orderCode = 900_000_000_000L + attemptId;
        try (PreparedStatement up = c.prepareStatement("UPDATE PayOSPaymentAttempt SET OrderCode = ? WHERE AttemptID = ?")) {
            up.setLong(1, orderCode);
            up.setLong(2, attemptId);
            up.executeUpdate();
        }
        return orderCode;
    }

    @Override
    public void markPending(Connection c, long orderCode, String paymentLinkId, String checkoutUrl, String qrCode) throws SQLException {
        String sql = "UPDATE PayOSPaymentAttempt SET Status = N'PENDING', PaymentLinkID = ?, CheckoutUrl = ?, QrCode = ? " +
                "WHERE OrderCode = ? AND Status = N'CREATING'";
        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, paymentLinkId);
            ps.setString(2, checkoutUrl);
            ps.setNString(3, qrCode);
            ps.setLong(4, orderCode);
            if (ps.executeUpdate() != 1) throw new SQLException("Không thể chuyển attempt sang PENDING (orderCode=" + orderCode + ").");
        }
    }

    @Override
    public Row findByOrderCode(Connection c, long orderCode) throws SQLException {
        String sql = "SELECT AttemptID, HoaDonID, DatSanID, CoSoID, OrderCode, PaymentLinkID, CheckoutUrl, " +
                "QrCode, Status, Amount, Description FROM PayOSPaymentAttempt WITH (UPDLOCK, ROWLOCK) WHERE OrderCode = ?";
        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, orderCode);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        }
    }

    @Override
    public boolean markPaid(Connection c, long orderCode) throws SQLException {
        String sql = "UPDATE PayOSPaymentAttempt SET Status = N'PAID', PaidAt = SYSDATETIME(), LastCheckedAt = SYSDATETIME() " +
                "WHERE OrderCode = ? AND Status <> N'PAID'";
        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, orderCode);
            return ps.executeUpdate() == 1;
        }
    }

    @Override
    public void markCancelledOrExpired(Connection c, long orderCode, PayOSPaymentAttemptStatus status) throws SQLException {
        String col = status == PayOSPaymentAttemptStatus.EXPIRED ? null : "CancelledAt";
        String sql = "UPDATE PayOSPaymentAttempt SET Status = ?, " +
                (col != null ? col + " = SYSDATETIME(), " : "") +
                "LastCheckedAt = SYSDATETIME() WHERE OrderCode = ? AND Status IN (N'CREATING', N'PENDING')";
        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setNString(1, status.name());
            ps.setLong(2, orderCode);
            ps.executeUpdate();
        }
    }

    @Override
    public void touchLastChecked(Connection c, long orderCode) throws SQLException {
        try (PreparedStatement ps = c.prepareStatement(
                "UPDATE PayOSPaymentAttempt SET LastCheckedAt = SYSDATETIME() WHERE OrderCode = ?")) {
            ps.setLong(1, orderCode);
            ps.executeUpdate();
        }
    }

    private Row mapRow(ResultSet rs) throws SQLException {
        Row row = new Row();
        row.attemptId = rs.getLong("AttemptID");
        row.hoaDonId = rs.getInt("HoaDonID");
        row.datSanId = rs.getInt("DatSanID");
        row.coSoId = rs.getInt("CoSoID");
        row.orderCode = rs.getLong("OrderCode");
        row.paymentLinkId = rs.getString("PaymentLinkID");
        row.checkoutUrl = rs.getString("CheckoutUrl");
        row.qrCode = rs.getString("QrCode");
        row.status = PayOSPaymentAttemptStatus.valueOf(rs.getNString("Status"));
        row.amount = rs.getBigDecimal("Amount");
        row.description = rs.getNString("Description");
        return row;
    }
}
```

- [ ] **Step 3: Compile check** — `mvn -q compile` → BUILD SUCCESS.

---

### Task 4: `PayOSClientFactory` — per-request SDK client from per-CoSo credentials

**Files:**
- Create: `src/main/java/org/example/service/payos/PayOSClientFactory.java`

- [ ] **Step 1: Write the factory**

```java
package org.example.service.payos;

import org.example.dto.payment.PayOSCredentials;
import vn.payos.PayOS;

/**
 * Tạo PayOS SDK client theo credentials của một CoSo cụ thể, KHÔNG cache.
 * Mỗi lời gọi tạo một client mới từ credentials hiện hành - đảm bảo Admin đổi
 * key xong là request kế tiếp dùng ngay key mới, không cần cơ chế invalidate.
 */
public final class PayOSClientFactory {
    private PayOSClientFactory() {}

    public static PayOS create(PayOSCredentials credentials) {
        if (credentials == null || !credentials.isClientIdConfigured()
                || !credentials.isApiKeyConfigured() || !credentials.isChecksumKeyConfigured()) {
            throw new IllegalStateException("Thiếu cấu hình PayOS.");
        }
        return new PayOS(credentials.getClientId(), credentials.getApiKey(), credentials.getChecksumKey());
    }
}
```

- [ ] **Step 2: Compile check** — `mvn -q compile` → BUILD SUCCESS.

---

### Task 5: `CheckoutService.finalizeLockedForPayment` — minimal public wrapper (DRY reuse)

**Files:**
- Modify: `src/main/java/org/example/service/checkout/CheckoutService.java`

**Interfaces:**
- Produces: `public CheckoutResult finalizeLockedForPayment(Connection c, int datSanId, int coSoId)` — exposes the existing private `finalizeLocked` to callers that manage their own transaction (Task 6's `PayOSPaymentService`), exactly the same idempotent lock+pricing-finalize logic already used by `pay()`/`initBankTransfer()`. No SQL duplicated.

- [ ] **Step 1: Add the one-method wrapper** (right after the existing `pay(...)` method, before `initBankTransfer`)

```java
    /**
     * Khóa + chốt tiền sân (idempotent) cho một transaction do CALLER quản lý - dùng bởi
     * PayOSPaymentService để tạo/tái sử dụng payment link trong CÙNG transaction với việc
     * kiểm tra/khóa PayOSPaymentAttempt, tránh race giữa hai bước.
     */
    public CheckoutResult finalizeLockedForPayment(Connection c, int datSanId, int coSoId) throws Exception {
        return finalizeLocked(c, datSanId, coSoId, LocalDateTime.now());
    }
```

- [ ] **Step 2: Compile check** — `mvn -q compile` → BUILD SUCCESS.

---

### Task 6: `PayOSPaymentService` — create/reuse payment link

**Files:**
- Create: `src/main/java/org/example/service/payos/PayOSPaymentService.java`

**Interfaces:**
- Consumes: `PayOSConfigurationService.getCredentialsForPayment(coSoId)` (existing, Task from prior session), `CheckoutService.finalizeLockedForPayment` (Task 5), `PayOSPaymentAttemptDAO` (Task 3), `PayOSClientFactory` (Task 4).
- Produces: `PayOSCreatePaymentResult createOrReusePayment(int datSanId, int coSoId, String publicBaseUrl)`.

- [ ] **Step 1: Write the service**

```java
package org.example.service.payos;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.dao.PayOSPaymentAttemptDAO;
import org.example.dao.impl.PayOSPaymentAttemptDAOImpl;
import org.example.dto.payment.PayOSCreatePaymentResult;
import org.example.dto.payment.PayOSCredentials;
import org.example.dto.payment.PayOSPaymentAttemptStatus;
import org.example.dto.payment.PayOSPaymentAttemptView;
import org.example.service.PayOSConfigurationService;
import org.example.service.checkout.CheckoutResult;
import org.example.service.checkout.CheckoutService;
import org.example.util.DBUtil;
import vn.payos.PayOS;
import vn.payos.model.v2.paymentRequests.CreatePaymentLinkRequest;
import vn.payos.model.v2.paymentRequests.CreatePaymentLinkResponse;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/**
 * Tạo hoặc tái sử dụng payment link PayOS cho MAIN invoice của một ca chơi, dùng credentials
 * riêng của CoSo (không dùng biến môi trường toàn cục). KHÔNG đánh dấu hóa đơn đã thanh toán -
 * chỉ PayOSPaymentFinalizationService (gọi từ webhook/polling đã xác thực) mới được làm việc đó.
 */
public class PayOSPaymentService {
    private static final Logger logger = LogManager.getLogger(PayOSPaymentService.class);

    private final PayOSConfigurationService payOSConfigurationService = new PayOSConfigurationService();
    private final CheckoutService checkoutService = new CheckoutService();
    private final PayOSPaymentAttemptDAO attemptDAO = new PayOSPaymentAttemptDAOImpl();

    public PayOSCreatePaymentResult createOrReusePayment(int datSanId, int coSoId, String publicBaseUrl) {
        PayOSCredentials credentials = payOSConfigurationService.getCredentialsForPayment(coSoId);
        if (credentials == null) {
            return PayOSCreatePaymentResult.fail(409, "PAYOS_NOT_CONFIGURED", "Cơ sở chưa cấu hình đầy đủ PayOS.");
        }

        try (Connection c = DBUtil.getConnection()) {
            c.setAutoCommit(false);
            try {
                CheckoutResult checkout = checkoutService.finalizeLockedForPayment(c, datSanId, coSoId);
                if (checkout.alreadyPaid()) {
                    c.rollback();
                    return PayOSCreatePaymentResult.fail(409, "PAYMENT_ALREADY_PAID", "Hóa đơn đã được thanh toán trước đó.");
                }

                BigDecimal paidAmount = readDepositAmount(c, datSanId);
                BigDecimal remaining = checkout.tongThanhToan().subtract(paidAmount).max(BigDecimal.ZERO)
                        .setScale(0, RoundingMode.HALF_UP);
                if (remaining.signum() <= 0) {
                    c.rollback();
                    return PayOSCreatePaymentResult.fail(409, "PAYMENT_ALREADY_PAID", "Hóa đơn không còn số tiền cần thanh toán.");
                }

                PayOSPaymentAttemptDAO.Row active = attemptDAO.findActiveByHoaDonId(c, checkout.hoaDonId());
                if (active != null && active.status == PayOSPaymentAttemptStatus.PENDING
                        && active.checkoutUrl != null && active.qrCode != null) {
                    c.commit();
                    logger.info("Tái sử dụng PayOS payment attempt orderCode={} hoaDonId={}", active.orderCode, checkout.hoaDonId());
                    return PayOSCreatePaymentResult.ok(toView(active, PayOSPaymentAttemptStatus.PENDING));
                }
                if (active != null) {
                    // CREATING dở dang bất thường (ví dụ lần trước crash giữa insert và PayOS trả lời) -
                    // huỷ để tạo lại sạch, tránh vi phạm unique filtered index "một attempt sống/hóa đơn".
                    attemptDAO.markCancelledOrExpired(c, active.orderCode, PayOSPaymentAttemptStatus.FAILED);
                }

                String description = "VSPORT HD" + checkout.hoaDonId();
                long orderCode = attemptDAO.insertCreating(c, checkout.hoaDonId(), datSanId, coSoId, remaining, description);

                String returnUrl = publicBaseUrl + "/staff/checkin?action=payosReturn&orderCode=" + orderCode;
                String cancelUrl = publicBaseUrl + "/staff/checkin?action=payosCancel&orderCode=" + orderCode;

                CreatePaymentLinkResponse payOSResponse;
                PayOS client = PayOSClientFactory.create(credentials);
                try {
                    CreatePaymentLinkRequest request = CreatePaymentLinkRequest.builder()
                            .orderCode(orderCode)
                            .amount(remaining.longValueExact())
                            .description(description)
                            .returnUrl(returnUrl)
                            .cancelUrl(cancelUrl)
                            .build();
                    payOSResponse = client.paymentRequests().create(request);
                } finally {
                    client.close();
                }

                attemptDAO.markPending(c, orderCode, payOSResponse.getPaymentLinkId(),
                        payOSResponse.getCheckoutUrl(), payOSResponse.getQrCode());
                c.commit();

                logger.info("Tạo PayOS payment attempt mới orderCode={} hoaDonId={} coSoId={}", orderCode, checkout.hoaDonId(), coSoId);
                return PayOSCreatePaymentResult.ok(new PayOSPaymentAttemptView(
                        checkout.hoaDonId(), orderCode, payOSResponse.getPaymentLinkId(), payOSResponse.getCheckoutUrl(),
                        payOSResponse.getQrCode(), remaining, description, PayOSPaymentAttemptStatus.PENDING));
            } catch (Exception e) {
                c.rollback();
                // Không log e nếu message có thể chứa payload PayOS - chỉ log loại lỗi + datSanId.
                logger.error("PAYOS_CREATE_FAILED datSanId={}, coSoId={}, loại lỗi={}", datSanId, coSoId, e.getClass().getSimpleName());
                return PayOSCreatePaymentResult.fail(502, "PAYOS_CREATE_FAILED", "Không thể tạo mã thanh toán PayOS. Vui lòng thử lại hoặc chọn Tiền mặt.");
            } finally {
                c.setAutoCommit(true);
            }
        } catch (Exception connEx) {
            logger.error("PAYOS_CREATE_FAILED (kết nối DB) datSanId={}", datSanId, connEx);
            return PayOSCreatePaymentResult.fail(500, "DATABASE_ERROR", "Không thể kết nối cơ sở dữ liệu.");
        }
    }

    private BigDecimal readDepositAmount(Connection c, int datSanId) throws Exception {
        try (PreparedStatement ps = c.prepareStatement("SELECT ISNULL(DepositAmount,0) FROM LichDatSan WHERE DatSanID = ?")) {
            ps.setInt(1, datSanId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getBigDecimal(1) : BigDecimal.ZERO;
            }
        }
    }

    private PayOSPaymentAttemptView toView(PayOSPaymentAttemptDAO.Row row, PayOSPaymentAttemptStatus status) {
        return new PayOSPaymentAttemptView(row.hoaDonId, row.orderCode, row.paymentLinkId, row.checkoutUrl,
                row.qrCode, row.amount, row.description, status);
    }
}
```

- [ ] **Step 2: Compile check** — `mvn -q compile` → BUILD SUCCESS.

---

### Task 7: `PayOSPaymentFinalizationService` — the ONE place that marks paid (idempotent, shared)

**Files:**
- Create: `src/main/java/org/example/service/payos/PayOSPaymentFinalizationService.java`

**Interfaces:**
- Consumes: `PayOSPaymentAttemptDAO` (Task 3).
- Produces: `PayOSFinalizeResult finalizePaidPayment(long orderCode, long paidAmountVnd, String paymentLinkId, String transactionReference, String confirmSource)` — called by both the webhook (Task 8) and the polling action (Task 9). `confirmSource` is one of `"PAYOS_WEBHOOK"` / `"PAYOS_POLLING"` (fits `LichDatSan.ConfirmSource NVARCHAR(20)`, same column bank-transfer already uses with `"STAFF_MANUAL"`).

- [ ] **Step 1: Write the service**

```java
package org.example.service.payos;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.dao.PayOSPaymentAttemptDAO;
import org.example.dao.impl.PayOSPaymentAttemptDAOImpl;
import org.example.dto.payment.PayOSFinalizeResult;
import org.example.dto.payment.PayOSPaymentAttemptStatus;
import org.example.util.DBUtil;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/**
 * Điểm DUY NHẤT được phép đánh dấu một hóa đơn PayOS là đã thanh toán. Gọi từ
 * PayOSWebhookServlet (sau khi verify chữ ký) và action getPayOSPaymentStatus (sau khi tự
 * gọi API PayOS lấy trạng thái) - không nơi nào khác được UPDATE các cột thanh toán này.
 * Idempotent: gọi nhiều lần với cùng orderCode chỉ áp dụng đúng một lần.
 */
public class PayOSPaymentFinalizationService {
    private static final Logger logger = LogManager.getLogger(PayOSPaymentFinalizationService.class);

    private final PayOSPaymentAttemptDAO attemptDAO = new PayOSPaymentAttemptDAOImpl();

    public PayOSFinalizeResult finalizePaidPayment(long orderCode, long paidAmountVnd, String paymentLinkId,
                                                     String transactionReference, String confirmSource) {
        try (Connection c = DBUtil.getConnection()) {
            c.setAutoCommit(false);
            try {
                PayOSPaymentAttemptDAO.Row attempt = attemptDAO.findByOrderCode(c, orderCode);
                if (attempt == null) {
                    c.rollback();
                    logger.warn("PAYOS_PAYMENT_NOT_FOUND orderCode={}", orderCode);
                    return PayOSFinalizeResult.fail("PAYOS_PAYMENT_NOT_FOUND", "Không tìm thấy giao dịch PayOS.");
                }
                if (attempt.status == PayOSPaymentAttemptStatus.PAID) {
                    c.commit();
                    return PayOSFinalizeResult.ok(attempt.hoaDonId, true);
                }
                if (attempt.status != PayOSPaymentAttemptStatus.PENDING && attempt.status != PayOSPaymentAttemptStatus.CREATING) {
                    c.rollback();
                    String code = attempt.status == PayOSPaymentAttemptStatus.CANCELLED ? "PAYOS_CANCELLED"
                            : attempt.status == PayOSPaymentAttemptStatus.EXPIRED ? "PAYOS_EXPIRED" : "PAYOS_STATUS_CHECK_FAILED";
                    logger.warn("Bỏ qua finalize orderCode={} vì trạng thái hiện tại={}", orderCode, attempt.status);
                    return PayOSFinalizeResult.fail(code, "Giao dịch không ở trạng thái có thể xác nhận.");
                }
                if (attempt.amount.compareTo(BigDecimal.valueOf(paidAmountVnd)) != 0) {
                    c.rollback();
                    logger.warn("PAYOS_AMOUNT_MISMATCH orderCode={} expected={} actual={}", orderCode, attempt.amount, paidAmountVnd);
                    return PayOSFinalizeResult.fail("PAYOS_AMOUNT_MISMATCH", "Số tiền xác nhận không khớp.");
                }

                try (PreparedStatement up = c.prepareStatement(
                        "UPDATE HoaDon SET TrangThaiThanhToan = N'Đã thanh toán', PhuongThucThanhToan = N'PayOS', " +
                        "NgayLap = GETDATE() WHERE HoaDonID = ? AND TrangThaiThanhToan <> N'Đã thanh toán'")) {
                    up.setInt(1, attempt.hoaDonId);
                    if (up.executeUpdate() != 1) {
                        c.commit(); // hóa đơn đã được đánh dấu paid bởi đường khác (rất hiếm) - coi là idempotent, không lỗi
                        return PayOSFinalizeResult.ok(attempt.hoaDonId, true);
                    }
                }
                try (PreparedStatement up = c.prepareStatement(
                        "UPDATE LichDatSan SET PaymentMethodConfirmed = N'PayOS', TransactionCode = ?, " +
                        "ConfirmedAt = GETDATE(), ConfirmedBy = NULL, ConfirmSource = ? WHERE DatSanID = ?")) {
                    up.setString(1, (transactionReference == null || transactionReference.isBlank())
                            ? paymentLinkId : transactionReference.trim());
                    up.setNString(2, confirmSource);
                    up.setInt(3, attempt.datSanId);
                    up.executeUpdate();
                }
                try (PreparedStatement up = c.prepareStatement(
                        "UPDATE LichDatSan SET TrangThai = N'Đã hoàn thành' WHERE DatSanID = ? AND TrangThai = N'Đang sử dụng'")) {
                    up.setInt(1, attempt.datSanId);
                    up.executeUpdate();
                }
                try (PreparedStatement up = c.prepareStatement(
                        "UPDATE San SET TrangThai = N'Sẵn sàng' WHERE SanID = (SELECT SanID FROM LichDatSan WHERE DatSanID = ?) AND TrangThai = N'Đang sử dụng'")) {
                    up.setInt(1, attempt.datSanId);
                    up.executeUpdate();
                }

                attemptDAO.markPaid(c, orderCode);
                c.commit();
                logger.info("PayOS finalize thành công orderCode={} hoaDonId={} source={}", orderCode, attempt.hoaDonId, confirmSource);
                return PayOSFinalizeResult.ok(attempt.hoaDonId, false);
            } catch (Exception e) {
                c.rollback();
                logger.error("PAYOS_FINALIZE_FAILED orderCode={}", orderCode, e);
                return PayOSFinalizeResult.fail("DATABASE_ERROR", "Không thể xác nhận thanh toán PayOS.");
            } finally {
                c.setAutoCommit(true);
            }
        } catch (Exception connEx) {
            logger.error("PAYOS_FINALIZE_FAILED (kết nối DB) orderCode={}", orderCode, connEx);
            return PayOSFinalizeResult.fail("DATABASE_ERROR", "Không thể kết nối cơ sở dữ liệu.");
        }
    }
}
```

- [ ] **Step 2: Compile check** — `mvn -q compile` → BUILD SUCCESS.

---

### Task 8: Restructure `PayOSWebhookServlet` for multi-CoSo credentials

**Files:**
- Modify: `src/main/java/org/example/controller/PayOSWebhookServlet.java`

**Interfaces:**
- Consumes: `PayOSPaymentAttemptDAO.findByOrderCode` (read-only peek, own short connection) to decide routing, `PayOSConfigurationService.getCredentialsForPayment`, `PayOSClientFactory`, `PayOSPaymentFinalizationService`.
- Preserves: the entire existing legacy branch (global-env `PayOSService.getInstance()`, `Lichdatsan`-keyed) untouched, reached only when `orderCode` does not match any `PayOSPaymentAttempt` row.

- [ ] **Step 1: Replace the servlet body** — parse raw body first without verifying (to peek `orderCode` only), decide which credentials to verify with, then proceed exactly as before for the legacy path or through the new finalize service for the new path.

```java
package org.example.controller;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.dao.LichDatSanDAO;
import org.example.dao.PayOSPaymentAttemptDAO;
import org.example.dao.impl.LichDatSanDAOImpl;
import org.example.dao.impl.PayOSPaymentAttemptDAOImpl;
import org.example.dto.payment.PayOSCredentials;
import org.example.dto.payment.PayOSFinalizeResult;
import org.example.model.Lichdatsan;
import org.example.service.PayOSConfigurationService;
import org.example.service.PayOSService;
import org.example.service.payos.PayOSClientFactory;
import org.example.service.payos.PayOSPaymentFinalizationService;
import org.example.util.DBUtil;
import vn.payos.PayOS;
import vn.payos.exception.PayOSException;
import vn.payos.model.webhooks.WebhookData;

import java.io.BufferedReader;
import java.io.IOException;
import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Webhook PUBLIC nhận thông báo thanh toán từ PayOS. Route: /payos/webhook (không yêu cầu
 * đăng nhập, không qua session).
 *
 * HAI LUỒNG dùng chung route này:
 * 1. (MỚI) Manager/Staff checkout qua PayOSPaymentService: orderCode nằm trong bảng
 *    PayOSPaymentAttempt, mỗi CoSo có checksum key riêng - phải tra CoSoID trước khi verify.
 * 2. (CŨ, giữ nguyên) Khách đặt sân online qua DatSanServlet: orderCode = DatSanID, verify
 *    bằng credentials toàn cục PayOSService.getInstance() (biến môi trường) như trước nay.
 *
 * orderCode không được tin trước khi verify chữ ký - chỉ dùng để TRA xem nên verify bằng
 * checksum key nào, rồi verify lại bằng đúng SDK/checksum đó trước khi tin bất kỳ field nào khác.
 */
@WebServlet(urlPatterns = { "/payos/webhook" })
public class PayOSWebhookServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(PayOSWebhookServlet.class.getName());
    private static final String PAYOS_SUCCESS_CODE = "00";
    private static final Gson gson = new Gson();

    private final LichDatSanDAO lichDatSanDAO = new LichDatSanDAOImpl();
    private final PayOSPaymentAttemptDAO attemptDAO = new PayOSPaymentAttemptDAOImpl();
    private final PayOSConfigurationService payOSConfigurationService = new PayOSConfigurationService();
    private final PayOSPaymentFinalizationService finalizationService = new PayOSPaymentFinalizationService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String rawBody = readRawBody(req);

        Long peekedOrderCode = peekOrderCode(rawBody);
        if (peekedOrderCode == null) {
            LOGGER.warning("PayOS webhook: không đọc được orderCode từ payload, bỏ qua");
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("Invalid payload");
            return;
        }

        Integer attemptCoSoId = lookupAttemptCoSoId(peekedOrderCode);
        if (attemptCoSoId != null) {
            handleNewFlowWebhook(rawBody, peekedOrderCode, attemptCoSoId, resp);
        } else {
            handleLegacyCustomerBookingWebhook(rawBody, resp);
        }
    }

    /** Chỉ đọc orderCode ở mức JSON thô, KHÔNG tin bất kỳ field nào khác cho tới khi verify chữ ký xong. */
    private Long peekOrderCode(String rawBody) {
        try {
            JsonObject root = gson.fromJson(rawBody, JsonObject.class);
            if (root == null) return null;
            JsonObject data = root.has("data") && root.get("data").isJsonObject() ? root.getAsJsonObject("data") : root;
            if (data.has("orderCode")) return data.get("orderCode").getAsLong();
        } catch (Exception ignored) {
            // payload không đúng format mong đợi - để verify chữ ký (ở nhánh legacy) tự báo lỗi
        }
        return null;
    }

    private Integer lookupAttemptCoSoId(long orderCode) {
        try (java.sql.Connection c = DBUtil.getConnection()) {
            PayOSPaymentAttemptDAO.Row row = attemptDAO.findByOrderCode(c, orderCode);
            return row != null ? row.coSoId : null;
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "PayOS webhook: lỗi tra CoSoID cho orderCode=" + orderCode, e);
            return null;
        }
    }

    // ── Luồng MỚI: Manager/Staff checkout, credentials theo CoSoID ──

    private void handleNewFlowWebhook(String rawBody, long orderCode, int coSoId, HttpServletResponse resp) throws IOException {
        PayOSCredentials credentials = payOSConfigurationService.getCredentialsForPayment(coSoId);
        if (credentials == null) {
            LOGGER.warning(String.format("PayOS webhook: CoSoID=%d chưa cấu hình đủ PayOS, orderCode=%d", coSoId, orderCode));
            respondOk(resp, "CoSo not configured, ignored");
            return;
        }

        WebhookData data;
        PayOS client = PayOSClientFactory.create(credentials);
        try {
            data = client.webhooks().verify(rawBody);
        } catch (PayOSException e) {
            LOGGER.warning(String.format("PayOS webhook: xac thuc chu ky that bai (CoSoID=%d, orderCode=%d) - %s", coSoId, orderCode, e.getMessage()));
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("Invalid webhook");
            return;
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "PayOS webhook: loi khong xac dinh khi xac thuc (luong moi)", e);
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("Invalid webhook");
            return;
        } finally {
            client.close();
        }

        if (!PAYOS_SUCCESS_CODE.equals(data.getCode())) {
            LOGGER.info(String.format("PayOS webhook: orderCode=%d code=%s khong phai thanh cong, bo qua", orderCode, data.getCode()));
            respondOk(resp, "Payment not successful, ignored");
            return;
        }

        PayOSFinalizeResult result = finalizationService.finalizePaidPayment(
                data.getOrderCode(), data.getAmount(), data.getPaymentLinkId(), data.getReference(), "PAYOS_WEBHOOK");
        if (result.isSuccess()) {
            respondOk(resp, result.isAlreadyPaid() ? "Already confirmed" : "Confirmed");
        } else {
            // Không cập nhật DB khi mismatch/not-found - vẫn trả 200 để PayOS không lặp lại vô ích
            // (giống hành vi cũ với amount mismatch), lỗi đã được log trong finalizationService.
            respondOk(resp, "Ignored: " + result.getCode());
        }
    }

    // ── Luồng CŨ: đặt sân online của khách hàng, credentials toàn cục (KHÔNG đổi hành vi) ──

    private void handleLegacyCustomerBookingWebhook(String rawBody, HttpServletResponse resp) throws IOException {
        WebhookData data;
        try {
            data = PayOSService.getInstance().verifyWebhook(rawBody);
        } catch (PayOSException e) {
            LOGGER.log(Level.WARNING, "PayOS webhook: xác thực chữ ký thất bại - " + e.getMessage());
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.setContentType("text/plain; charset=UTF-8");
            resp.getWriter().write("Invalid webhook");
            return;
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "PayOS webhook: lỗi không xác định khi xác thực", e);
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.setContentType("text/plain; charset=UTF-8");
            resp.getWriter().write("Invalid webhook");
            return;
        }

        Long orderCode = data.getOrderCode();
        Long amount = data.getAmount();
        String code = data.getCode();
        int datSanId = orderCode.intValue();

        LOGGER.info(String.format(
                "PayOS webhook nhan: orderCode=%d amount=%d code=%s -> DatSanID=%d",
                orderCode, amount, code, datSanId));

        Lichdatsan lich = lichDatSanDAO.getLichById(datSanId);
        if (lich == null) {
            LOGGER.warning(String.format(
                    "PayOS webhook: khong tim thay booking DatSanID=%d (orderCode=%d), bo qua",
                    datSanId, orderCode));
            respondOk(resp, "Booking not found, ignored");
            return;
        }

        String currentStatus = lich.getTrangThai();
        LOGGER.info(String.format("PayOS webhook: DatSanID=%d trang thai hien tai=%s", datSanId, currentStatus));

        if ("Đã xác nhận".equals(currentStatus)) {
            LOGGER.info(String.format(
                    "PayOS webhook: DatSanID=%d da 'Da xac nhan' truoc do, bo qua (idempotent)", datSanId));
            respondOk(resp, "Already confirmed");
            return;
        }

        if ("Đã hủy".equals(currentStatus)) {
            LOGGER.warning(String.format(
                    "PayOS webhook: DatSanID=%d da bi huy truoc do, khong doi lai thanh 'Da xac nhan'", datSanId));
            respondOk(resp, "Already cancelled, ignored");
            return;
        }

        if (!"Chờ thanh toán".equals(currentStatus)) {
            LOGGER.warning(String.format(
                    "PayOS webhook: DatSanID=%d dang o trang thai khong mong doi '%s', bo qua",
                    datSanId, currentStatus));
            respondOk(resp, "Unexpected status, ignored");
            return;
        }

        BigDecimal expectedAmount = lich.getTongTienDuKien();
        if (expectedAmount == null || BigDecimal.valueOf(amount).compareTo(expectedAmount) != 0) {
            LOGGER.warning(String.format(
                    "PayOS webhook: DatSanID=%d SO TIEN KHONG KHOP (webhook=%d, DB=%s), khong xac nhan",
                    datSanId, amount, expectedAmount));
            respondOk(resp, "Amount mismatch, ignored");
            return;
        }

        if (!PAYOS_SUCCESS_CODE.equals(code)) {
            LOGGER.warning(String.format(
                    "PayOS webhook: DatSanID=%d webhook code='%s' khong phai thanh cong, khong xac nhan",
                    datSanId, code));
            respondOk(resp, "Payment not successful, ignored");
            return;
        }

        boolean updated = confirmBookingPaid(datSanId);
        if (updated) {
            LOGGER.info(String.format(
                    "PayOS webhook: DatSanID=%d da duoc xac nhan 'Da xac nhan' thanh cong", datSanId));
            respondOk(resp, "Confirmed");
        } else {
            LOGGER.warning(String.format(
                    "PayOS webhook: DatSanID=%d update that bai (trang thai da doi truoc do)", datSanId));
            respondOk(resp, "Update skipped");
        }
    }

    private boolean confirmBookingPaid(int datSanId) {
        String sql = "UPDATE LichDatSan " +
                "SET TrangThai = N'Đã xác nhận', " +
                "    GhiChu = CONCAT(ISNULL(GhiChu, N''), N' [PayOS webhook xác nhận thanh toán thành công]') " +
                "WHERE DatSanID = ? AND TrangThai = N'Chờ thanh toán'";
        try (java.sql.Connection conn = DBUtil.getConnection();
                java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, datSanId);
            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (java.sql.SQLException e) {
            LOGGER.log(Level.SEVERE, "PayOS webhook: loi SQL khi update DatSanID=" + datSanId, e);
            return false;
        }
    }

    private String readRawBody(HttpServletRequest req) throws IOException {
        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(
                new java.io.InputStreamReader(req.getInputStream(), StandardCharsets.UTF_8))) {
            char[] buffer = new char[1024];
            int read;
            while ((read = reader.read(buffer)) != -1) {
                sb.append(buffer, 0, read);
            }
        }
        return sb.toString();
    }

    private void respondOk(HttpServletResponse resp, String message) throws IOException {
        resp.setStatus(HttpServletResponse.SC_OK);
        resp.setContentType("text/plain; charset=UTF-8");
        resp.getWriter().write(message);
    }
}
```

- [ ] **Step 2: Compile check** — `mvn -q compile` → BUILD SUCCESS.

---

### Task 9: `CheckInServlet` — `createPayOSPayment`, `getPayOSPaymentStatus`, return/cancel landing actions

**Files:**
- Modify: `src/main/java/org/example/controller/staff/CheckInServlet.java`

**Interfaces:**
- Consumes: `PayOSPaymentService` (Task 6), `PayOSPaymentFinalizationService` (Task 7), `PayOSPaymentAttemptDAO` (Task 3, read-only for the polling IDOR check), `vn.payos.PayOS` via `PayOSClientFactory` (Task 4) for the live status check.
- Produces: `action=createPayOSPayment` (POST, `datSanId`), `action=getPayOSPaymentStatus` (GET, `orderCode`), `action=payosReturn`/`action=payosCancel` (GET, static "you can close this tab" landing — no DB writes).

- [ ] **Step 1: Add imports** (top of file, alongside existing checkout imports)

```java
import org.example.service.payos.PayOSPaymentService;
import org.example.service.payos.PayOSPaymentFinalizationService;
import org.example.service.payos.PayOSClientFactory;
import org.example.dao.PayOSPaymentAttemptDAO;
import org.example.dao.impl.PayOSPaymentAttemptDAOImpl;
import org.example.dto.payment.PayOSCreatePaymentResult;
import org.example.dto.payment.PayOSCredentials;
import org.example.dto.payment.PayOSPaymentAttemptStatus;
import org.example.service.PayOSConfigurationService;
import vn.payos.PayOS;
import vn.payos.model.v2.paymentRequests.PaymentLink;
```

- [ ] **Step 2: Add fields** (alongside `checkInDAO`/`checkoutService`)

```java
    private final PayOSPaymentService payOSPaymentService = new PayOSPaymentService();
    private final PayOSPaymentFinalizationService payOSFinalizationService = new PayOSPaymentFinalizationService();
    private final PayOSPaymentAttemptDAO payOSPaymentAttemptDAO = new PayOSPaymentAttemptDAOImpl();
    private final PayOSConfigurationService payOSConfigurationService = new PayOSConfigurationService();
```

- [ ] **Step 3: Route the new actions in `doPost`** (next to the existing `initBankTransfer`/`confirmBankTransfer` dispatch)

```java
        if ("createPayOSPayment".equals(action)) {
            handleCreatePayOSPayment(req, resp, user);
            return;
        }
```

- [ ] **Step 4: Route `getPayOSPaymentStatus` in `doGet`** (next to the existing `getInvoiceDetails`/`ajax` dispatch, before the generic action fallthrough)

```java
        if ("getPayOSPaymentStatus".equals(action)) {
            handleGetPayOSPaymentStatus(req, resp, user);
            return;
        }
        if ("payosReturn".equals(action) || "payosCancel".equals(action)) {
            handlePayOSLanding(resp);
            return;
        }
```

- [ ] **Step 5: Add the handler methods** (near `handleInitBankTransfer`/`handleConfirmBankTransfer`)

```java
    /**
     * Tạo/tái sử dụng payment link PayOS (action=createPayOSPayment). KHÔNG đánh dấu đã thanh
     * toán - chỉ trả QR/checkoutUrl để hiển thị. Frontend chỉ gửi datSanId; amount/CoSoID/
     * credentials đều lấy từ database phía backend.
     */
    private void handleCreatePayOSPayment(HttpServletRequest req, HttpServletResponse resp, TaiKhoan user)
            throws IOException {
        String datSanIdStr = req.getParameter("datSanId");
        try {
            if (datSanIdStr == null || datSanIdStr.isBlank()) {
                writeJsonResponse(resp, HttpServletResponse.SC_BAD_REQUEST,
                        errorJson("MISSING_DAT_SAN_ID", "Thiếu ID đơn đặt sân."));
                return;
            }
            int datSanId = Integer.parseInt(datSanIdStr.trim());
            String publicBaseUrl = resolvePublicBaseUrl(req);

            PayOSCreatePaymentResult result = payOSPaymentService.createOrReusePayment(datSanId, user.getCoSoId(), publicBaseUrl);
            if (!result.isSuccess()) {
                writeJsonResponse(resp, result.getHttpStatus(), errorJson(result.getCode(), result.getMessage()));
                return;
            }

            com.google.gson.JsonObject payment = new com.google.gson.JsonObject();
            payment.addProperty("hoaDonId", result.getPayment().getHoaDonId());
            payment.addProperty("orderCode", result.getPayment().getOrderCode());
            payment.addProperty("paymentLinkId", result.getPayment().getPaymentLinkId());
            payment.addProperty("checkoutUrl", result.getPayment().getCheckoutUrl());
            payment.addProperty("qrCode", result.getPayment().getQrCode());
            payment.addProperty("amount", result.getPayment().getAmount());
            payment.addProperty("description", result.getPayment().getDescription());
            payment.addProperty("status", result.getPayment().getStatus().name());

            com.google.gson.JsonObject json = new com.google.gson.JsonObject();
            json.addProperty("success", true);
            json.add("payment", payment);
            writeJsonResponse(resp, HttpServletResponse.SC_OK, json);
        } catch (NumberFormatException e) {
            writeJsonResponse(resp, HttpServletResponse.SC_BAD_REQUEST,
                    errorJson("INVALID_DAT_SAN_ID", "ID đơn đặt sân không hợp lệ."));
        } catch (Exception e) {
            logger.error("CREATE_PAYOS_PAYMENT_FAILED datSanId={}", datSanIdStr, e);
            writeJsonResponse(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    errorJson("INTERNAL_ERROR", "Không thể tạo mã thanh toán PayOS."));
        }
    }

    /**
     * Polling (action=getPayOSPaymentStatus, gọi mỗi 4s từ frontend). Nếu local đã PAID, trả
     * ngay không gọi PayOS. Nếu chưa, tự gọi API PayOS lấy trạng thái bằng đúng credentials của
     * CoSo sở hữu attempt, rồi finalize idempotent qua PayOSPaymentFinalizationService nếu PAID.
     */
    private void handleGetPayOSPaymentStatus(HttpServletRequest req, HttpServletResponse resp, TaiKhoan user)
            throws IOException {
        String orderCodeStr = req.getParameter("orderCode");
        try {
            if (orderCodeStr == null || orderCodeStr.isBlank()) {
                writeJsonResponse(resp, HttpServletResponse.SC_BAD_REQUEST,
                        errorJson("MISSING_ORDER_CODE", "Thiếu orderCode."));
                return;
            }
            long orderCode = Long.parseLong(orderCodeStr.trim());

            PayOSPaymentAttemptDAO.Row attempt;
            try (java.sql.Connection c = org.example.util.DBUtil.getConnection()) {
                attempt = payOSPaymentAttemptDAO.findByOrderCode(c, orderCode);
            }
            if (attempt == null) {
                writeJsonResponse(resp, HttpServletResponse.SC_NOT_FOUND,
                        errorJson("PAYOS_PAYMENT_NOT_FOUND", "Không tìm thấy giao dịch PayOS."));
                return;
            }
            if (attempt.coSoId != user.getCoSoId()) {
                writeJsonResponse(resp, HttpServletResponse.SC_FORBIDDEN,
                        errorJson("FORBIDDEN", "Giao dịch không thuộc cơ sở của bạn."));
                return;
            }

            if (attempt.status == PayOSPaymentAttemptStatus.PAID) {
                writeJsonResponse(resp, HttpServletResponse.SC_OK, payosStatusJson("PAID", attempt.hoaDonId, req));
                return;
            }

            PayOSCredentials credentials = payOSConfigurationService.getCredentialsForPayment(attempt.coSoId);
            if (credentials == null) {
                writeJsonResponse(resp, HttpServletResponse.SC_OK, payosStatusJson("PENDING", null, req));
                return;
            }

            PayOS client = PayOSClientFactory.create(credentials);
            PaymentLink link;
            try {
                link = client.paymentRequests().get(orderCode);
            } finally {
                client.close();
            }

            String status = link.getStatus() != null ? link.getStatus().name() : "PENDING";
            if ("PAID".equals(status)) {
                long paidAmount = link.getAmountPaid() != null ? link.getAmountPaid() : (link.getAmount() != null ? link.getAmount() : 0L);
                String reference = (link.getTransactions() != null && !link.getTransactions().isEmpty())
                        ? link.getTransactions().get(0).getReference() : null;
                org.example.dto.payment.PayOSFinalizeResult result = payOSFinalizationService.finalizePaidPayment(
                        orderCode, paidAmount, attempt.paymentLinkId, reference, "PAYOS_POLLING");
                if (result.isSuccess()) {
                    writeJsonResponse(resp, HttpServletResponse.SC_OK, payosStatusJson("PAID", result.getHoaDonId(), req));
                    return;
                }
                writeJsonResponse(resp, HttpServletResponse.SC_OK, payosStatusJson("PENDING", null, req));
                return;
            }
            if ("CANCELLED".equals(status) || "EXPIRED".equals(status)) {
                try (java.sql.Connection c = org.example.util.DBUtil.getConnection()) {
                    payOSPaymentAttemptDAO.markCancelledOrExpired(c, orderCode,
                            "CANCELLED".equals(status) ? PayOSPaymentAttemptStatus.CANCELLED : PayOSPaymentAttemptStatus.EXPIRED);
                } catch (Exception ignored) {}
                writeJsonResponse(resp, HttpServletResponse.SC_OK, payosStatusJson(status, null, req));
                return;
            }
            try (java.sql.Connection c = org.example.util.DBUtil.getConnection()) {
                payOSPaymentAttemptDAO.touchLastChecked(c, orderCode);
            } catch (Exception ignored) {}
            writeJsonResponse(resp, HttpServletResponse.SC_OK, payosStatusJson("PENDING", null, req));
        } catch (NumberFormatException e) {
            writeJsonResponse(resp, HttpServletResponse.SC_BAD_REQUEST,
                    errorJson("INVALID_ORDER_CODE", "orderCode không hợp lệ."));
        } catch (Exception e) {
            logger.error("GET_PAYOS_STATUS_FAILED orderCode={}", orderCodeStr, e);
            writeJsonResponse(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    errorJson("PAYOS_STATUS_CHECK_FAILED", "Không thể kiểm tra trạng thái thanh toán."));
        }
    }

    private com.google.gson.JsonObject payosStatusJson(String status, Integer hoaDonId, HttpServletRequest req) {
        com.google.gson.JsonObject json = new com.google.gson.JsonObject();
        json.addProperty("success", true);
        json.addProperty("status", status);
        if (hoaDonId != null) {
            json.addProperty("hoaDonId", hoaDonId);
            json.addProperty("printUrl", req.getContextPath() + "/staff/hoa-don/in?id=" + hoaDonId);
        }
        return json;
    }

    /** returnUrl/cancelUrl của PayOS trỏ về đây - CHỈ hiển thị trang tĩnh, KHÔNG đọc query param để đổi DB. */
    private void handlePayOSLanding(HttpServletResponse resp) throws IOException {
        resp.setContentType("text/html;charset=UTF-8");
        resp.getWriter().write(
                "<!DOCTYPE html><html lang=\"vi\"><head><meta charset=\"UTF-8\">" +
                "<title>V-SPORT</title></head><body style=\"font-family:sans-serif;text-align:center;padding:60px 20px;\">" +
                "<h2>Bạn có thể đóng tab này</h2>" +
                "<p>Vui lòng quay lại màn hình Check-in để xem trạng thái thanh toán mới nhất.</p>" +
                "</body></html>");
    }

    private String resolvePublicBaseUrl(HttpServletRequest req) {
        String configured = System.getenv("PUBLIC_BASE_URL");
        if (configured != null && !configured.isBlank()) {
            return configured.trim().replaceAll("/$", "");
        }
        String scheme = req.getScheme();
        String serverName = req.getServerName();
        int port = req.getServerPort();
        boolean defaultPort = (scheme.equals("http") && port == 80) || (scheme.equals("https") && port == 443);
        return scheme + "://" + serverName + (defaultPort ? "" : ":" + port) + req.getContextPath();
    }
```

- [ ] **Step 6: Extend `errorJson` to accept a `code`+`message` pair matching the new codes** — reuse the existing `errorJson(String code, String message)` helper unchanged (already matches this shape).

- [ ] **Step 7: Compile check** — `mvn -q compile` → BUILD SUCCESS.

- [ ] **Step 8: Add `PT_PAYOS` constant** to `src/main/java/org/example/util/Constants.java` next to `PT_CHUYEN_KHOAN`:

```java
    public static final String PT_PAYOS = "PayOS";
```

---

### Task 10: `CheckIn.jsp` — PayOS panel, footer, state machine, polling, QR rendering

**Files:**
- Modify: `src/main/webapp/staff/CheckIn.jsp`

This task mirrors the existing, already-working `AWAITING_TRANSFER` implementation (panel around line 1723, footer around line 1794, state machine around line 2055, handlers around line 2821) with a parallel `AWAITING_PAYOS` path. Concrete edits:

- [ ] **Step 1: Add the QR rendering library via CDN** in `<head>`, next to the existing Tabler/Material Symbols links:

```html
<script src="https://cdn.jsdelivr.net/npm/qrcode@1.5.3/build/qrcode.min.js"></script>
```

- [ ] **Step 2: Relabel the payment method selector** — change the `lbl-pay-transfer` button (line ~1587) from "Chuyển khoản" to "PayOS", keep `id="lbl-pay-transfer"` and the `onclick="changeStaffPayMethod(...)"` wiring (no ID churn), just change the argument and label:

```html
                            <button type="button" id="lbl-pay-transfer" class="seg-btn" role="radio" aria-checked="false" onclick="changeStaffPayMethod('PayOS')">
                                <span class="material-symbols-outlined text-[16px]">qr_code_2</span> PayOS
                            </button>
                        </div>
                        <p class="text-[11px] text-[#5d5d67] mt-1.5">Quét mã QR hoặc mở trang thanh toán PayOS. Hệ thống tự động xác nhận khi khách thanh toán xong.</p>
```

- [ ] **Step 3: Add the PayOS awaiting panel**, right after the existing `<!-- Bank transfer awaiting state -->` div closes (line ~1778), as a sibling (keep the old div intact, unused from the UI):

```html
            <!-- PayOS awaiting state -->
            <div id="staff-payos-panel" class="hidden flex-1 min-h-0 bg-[#f8f9ff] overflow-y-auto">
                <div class="p-4 lg:p-6 max-w-md mx-auto">
                    <div class="bg-white rounded-xl border ${themeBorderStrong} overflow-hidden">
                        <div class="px-5 pt-4 pb-3 border-b ${themeBorder}">
                            <h3 class="text-sm font-bold text-[#0b1c30]">Thanh toán PayOS</h3>
                            <p class="text-xs text-[#5d5d67] mt-0.5">Quét mã QR hoặc mở trang thanh toán</p>
                        </div>
                        <div class="p-5 flex flex-col items-center gap-4">
                            <div class="${themeBgLight} rounded-lg p-4 flex items-center justify-center">
                                <canvas id="staff-payos-qr-canvas" width="176" height="176"></canvas>
                            </div>
                            <p id="staff-payos-qr-error" class="hidden text-[11px] text-amber-700 text-center">Không tạo được mã QR. Dùng nút "Mở trang PayOS" bên dưới.</p>
                            <div class="w-full space-y-1.5 text-sm">
                                <div class="flex justify-between items-center gap-2 pb-2 border-b ${themeBorder}">
                                    <span class="text-[#5d5d67]">Số tiền</span>
                                    <span class="font-bold text-base ${themeTextMedium}" id="staff-payos-amount">0 đ</span>
                                </div>
                                <div class="flex justify-between items-center gap-2">
                                    <span class="text-[#5d5d67]">Nội dung</span>
                                    <span class="font-semibold text-[#0b1c30]" id="staff-payos-description">-</span>
                                </div>
                                <div class="flex justify-between items-center gap-2">
                                    <span class="text-[#5d5d67]">Trạng thái</span>
                                    <span class="font-semibold text-amber-700" id="staff-payos-status-label">Chờ thanh toán</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div><!-- End of staff-payos-panel -->
```

- [ ] **Step 4: Add the PayOS footer**, right after the existing `staff-footer-awaiting-transfer` div (line ~1803):

```html
            <!-- AWAITING_PAYOS / VERIFYING_PAYOS actions -->
            <div id="staff-footer-awaiting-payos" class="hidden contents">
                <button type="button" onclick="handleChangePaymentMethodFromAwaitingPayOS()" class="bg-[#e3e1ed] text-[#64636d] rounded-lg px-5 py-2 text-sm font-semibold hover:brightness-95 transition-all active:scale-95">
                    Đổi phương thức
                </button>
                <button type="button" onclick="openPayOSCheckoutUrl()" class="${themeBg} ${themeBgHover} text-white rounded-lg px-6 py-2.5 text-sm font-semibold flex items-center gap-2 transition-all active:scale-95">
                    <span class="material-symbols-outlined text-sm">open_in_new</span>
                    Mở trang PayOS
                </button>
            </div>
```

- [ ] **Step 5: Extend `PaymentModalState` and `PaymentMethod`** (line ~2056):

```javascript
    const PaymentModalState = {
        EDITING: 'EDITING', PROCESSING: 'PROCESSING',
        AWAITING_TRANSFER: 'AWAITING_TRANSFER', VERIFYING_TRANSFER: 'VERIFYING_TRANSFER',
        CREATING_PAYOS: 'CREATING_PAYOS', AWAITING_PAYOS: 'AWAITING_PAYOS', VERIFYING_PAYOS: 'VERIFYING_PAYOS',
        SUCCESS: 'SUCCESS'
    };
    const PaymentMethod = { CASH: 'Tiền mặt', BANK_TRANSFER: 'Chuyển khoản', PAYOS: 'PayOS' };
    let currentPayOSPayment = null;
    let payosPollTimer = null;
```

- [ ] **Step 6: Extend `setPaymentModalState`** (line ~2070) with a `CREATING_PAYOS`/`AWAITING_PAYOS`/`VERIFYING_PAYOS` branch, inserted before the final `// EDITING / PROCESSING` block, and extend the element lookups at the top of the function:

```javascript
        const payosPanel = document.getElementById('staff-payos-panel');
        const footerPayos = document.getElementById('staff-footer-awaiting-payos');
        // ...(existing content.classList.add('hidden') etc block gets two more lines:)
        if (payosPanel) payosPanel.classList.add('hidden');
        if (footerPayos) footerPayos.classList.add('hidden');

        if (state === PaymentModalState.AWAITING_PAYOS || state === PaymentModalState.VERIFYING_PAYOS) {
            if (payosPanel) payosPanel.classList.remove('hidden');
            if (footerPayos) footerPayos.classList.remove('hidden');
            if (subtitle) subtitle.textContent = 'Chờ thanh toán PayOS';
            const statusLabel = document.getElementById('staff-payos-status-label');
            if (statusLabel) statusLabel.textContent = state === PaymentModalState.VERIFYING_PAYOS ? 'Đang xác nhận...' : 'Chờ thanh toán';
            return;
        }
```

The `EDITING / PROCESSING` tail already reads `isBankTransferMethod` off `staff-pay-method-input`; extend it to also recognize `CREATING_PAYOS` and the PayOS method for the primary-button label/icon (mirrors the existing `isBankTransferMethod ? 'Đang khởi tạo...' : ...` ternary — add a `isPayOSMethod` branch the same way):

```javascript
        const isPayOSMethod = document.getElementById('staff-pay-method-input')?.value === PaymentMethod.PAYOS;
        // icon:
        if (icon) icon.textContent = isCheckout ? (isPayOSMethod ? 'qr_code_2' : isBankTransferMethod ? 'qr_code_2' : 'payments') : 'save';
        // label, inside PROCESSING branch:
        if (state === PaymentModalState.PROCESSING || state === PaymentModalState.CREATING_PAYOS) {
            label.textContent = isCheckout ? (isPayOSMethod ? 'Đang tạo mã...' : isBankTransferMethod ? 'Đang khởi tạo...' : 'Đang thanh toán...') : 'Đang lưu...';
        } else if (isCheckout) {
            label.textContent = isPayOSMethod ? 'Tạo mã thanh toán' : isBankTransferMethod ? 'Tiếp tục chuyển khoản' : 'Thanh toán';
        }
        if (btn) btn.disabled = (state === PaymentModalState.PROCESSING || state === PaymentModalState.CREATING_PAYOS);
```

- [ ] **Step 7: Branch `handlePrimaryPaymentAction`** (line ~2529):

```javascript
        const method = document.getElementById('staff-pay-method-input')?.value || '';
        if (method === PaymentMethod.PAYOS) {
            handleCreatePayOSPayment();
        } else if (method === PaymentMethod.BANK_TRANSFER) {
            handleInitBankTransfer();
        } else {
            handleStaffPaymentSubmit();
        }
```

- [ ] **Step 8: Add the PayOS handlers**, right after `handleInitBankTransfer`/`renderBankTransferPanel` (mirrors that pair exactly):

```javascript
    // ── PayOS: EDITING -> (createPayOSPayment) -> AWAITING_PAYOS -> (polling) -> SUCCESS ──

    async function handleCreatePayOSPayment() {
        if (isStaffPaymentSubmitting || currentPaymentModalState !== PaymentModalState.EDITING) return;

        const datSanIdText = document.getElementById('staff-pay-datsan-id')?.value?.trim() || '';
        const datSanId = Number(datSanIdText);
        if (!Number.isInteger(datSanId) || datSanId <= 0) {
            showStaffPaymentError('Không xác định được phiên chơi cần thanh toán. Vui lòng đóng và mở lại cửa sổ thanh toán.');
            return;
        }

        const params = new URLSearchParams();
        params.set('action', 'createPayOSPayment');
        params.set('datSanId', String(datSanId));

        isStaffPaymentSubmitting = true;
        setPaymentModalState(PaymentModalState.CREATING_PAYOS);
        document.getElementById('staff-payment-error')?.classList.add('hidden');

        try {
            const response = await fetch('${pageContext.request.contextPath}/staff/checkin', {
                method: 'POST',
                credentials: 'same-origin',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
                    'Accept': 'application/json',
                    'X-Requested-With': 'XMLHttpRequest'
                },
                body: params.toString()
            });
            const rawText = await response.text();
            let data;
            try { data = JSON.parse(rawText); }
            catch (parseError) { throw new Error(`Máy chủ trả về JSON không hợp lệ (HTTP \${response.status}).`); }

            isStaffPaymentSubmitting = false;

            if (!response.ok || !data.success) {
                if (data.code === 'PAYOS_NOT_CONFIGURED') {
                    showStaffPaymentError('Cơ sở chưa cấu hình đầy đủ PayOS. Vui lòng chọn Tiền mặt hoặc liên hệ Admin.');
                    setPaymentModalState(PaymentModalState.EDITING);
                    return;
                }
                throw new Error(data.message || 'Không thể tạo mã thanh toán PayOS.');
            }

            currentPayOSPayment = data.payment;
            renderPayOSPanel(data.payment);
            setPaymentModalState(PaymentModalState.AWAITING_PAYOS);
            startPayOSPolling();
        } catch (err) {
            isStaffPaymentSubmitting = false;
            setPaymentModalState(PaymentModalState.EDITING);
            showStaffPaymentError(err.message || 'Đã có lỗi xảy ra, vui lòng thử lại.');
        }
    }

    function renderPayOSPanel(payment) {
        const amtEl = document.getElementById('staff-payos-amount');
        if (amtEl) amtEl.textContent = formatCurrency(payment.amount);
        const descEl = document.getElementById('staff-payos-description');
        if (descEl) descEl.textContent = payment.description || '-';

        const canvas = document.getElementById('staff-payos-qr-canvas');
        const errorEl = document.getElementById('staff-payos-qr-error');
        if (canvas && payment.qrCode && window.QRCode) {
            window.QRCode.toCanvas(canvas, payment.qrCode, { width: 176, margin: 1 }, (err) => {
                if (err) { canvas.classList.add('hidden'); errorEl?.classList.remove('hidden'); }
                else { canvas.classList.remove('hidden'); errorEl?.classList.add('hidden'); }
            });
        } else if (errorEl) {
            errorEl.classList.remove('hidden');
        }
    }

    function openPayOSCheckoutUrl() {
        if (!currentPayOSPayment || !currentPayOSPayment.checkoutUrl) return;
        window.open(currentPayOSPayment.checkoutUrl, '_blank', 'noopener,noreferrer');
    }

    // "Đổi phương thức" trong lúc chờ PayOS: KHÔNG hủy payment link ở backend (khách vẫn có thể
    // trả qua link/QR cũ) - chỉ dừng polling và quay UI về EDITING + Tiền mặt. Nếu bấm lại PayOS,
    // backend tự tái sử dụng đúng attempt PENDING này (mục VII).
    function handleChangePaymentMethodFromAwaitingPayOS() {
        if (currentPaymentModalState !== PaymentModalState.AWAITING_PAYOS) return;
        stopPayOSPolling();
        currentPayOSPayment = null;
        setPaymentModalState(PaymentModalState.EDITING);
        changeStaffPayMethod(PaymentMethod.CASH);
    }

    function startPayOSPolling() {
        stopPayOSPolling();
        payosPollTimer = setInterval(pollPayOSStatus, 4000);
    }

    function stopPayOSPolling() {
        if (payosPollTimer) { clearInterval(payosPollTimer); payosPollTimer = null; }
    }

    async function pollPayOSStatus() {
        if (!currentPayOSPayment || currentPaymentModalState !== PaymentModalState.AWAITING_PAYOS) {
            stopPayOSPolling();
            return;
        }
        try {
            const res = await fetch('${pageContext.request.contextPath}/staff/checkin?action=getPayOSPaymentStatus&orderCode=' + currentPayOSPayment.orderCode, {
                credentials: 'same-origin',
                headers: { 'Accept': 'application/json', 'X-Requested-With': 'XMLHttpRequest' }
            });
            const data = await res.json();
            if (!data.success) return; // lỗi tạm thời - thử lại ở lần poll kế tiếp, không dừng polling

            if (data.status === 'PAID') {
                stopPayOSPolling();
                setPaymentModalState(PaymentModalState.VERIFYING_PAYOS);
                await showPaymentSuccessInvoice({ hoaDonId: data.hoaDonId, printUrl: data.printUrl });
            } else if (data.status === 'CANCELLED' || data.status === 'EXPIRED') {
                stopPayOSPolling();
                currentPayOSPayment = null;
                setPaymentModalState(PaymentModalState.EDITING);
                showStaffPaymentError(data.status === 'CANCELLED'
                        ? 'Giao dịch PayOS đã bị hủy. Vui lòng tạo mã mới hoặc chọn phương thức khác.'
                        : 'Mã thanh toán PayOS đã hết hạn. Vui lòng tạo mã mới.');
            }
            // PENDING: không làm gì, chờ lần poll kế tiếp
        } catch (err) {
            // Lỗi mạng tạm thời khi polling - im lặng thử lại lần sau, không làm gián đoạn nhân viên.
        }
    }
```

- [ ] **Step 9: Stop polling on modal close** — extend `closeStaffInvoiceModal` (line ~3421) close-guard and cleanup:

```javascript
    function closeStaffInvoiceModal() {
        // Không cho đóng modal khi đang gửi/chờ transaction thanh toán commit.
        if (currentPaymentModalState === PaymentModalState.PROCESSING
            || currentPaymentModalState === PaymentModalState.VERIFYING_TRANSFER
            || currentPaymentModalState === PaymentModalState.CREATING_PAYOS
            || currentPaymentModalState === PaymentModalState.VERIFYING_PAYOS) return;

        stopPayOSPolling();
        // ...rest unchanged
```

- [ ] **Step 10: Stop polling on page unload** — add near the existing `document.addEventListener('DOMContentLoaded', ...)` block at the bottom of the script:

```javascript
    window.addEventListener('beforeunload', () => { stopPayOSPolling(); });
    document.addEventListener('visibilitychange', () => {
        if (document.hidden) stopPayOSPolling();
        else if (currentPaymentModalState === PaymentModalState.AWAITING_PAYOS) startPayOSPolling();
    });
```

- [ ] **Step 11: Extend the Escape-to-close guard** (line ~3941) — add the same two new states to the block condition:

```javascript
        if (currentPaymentModalState === PaymentModalState.PROCESSING
            || currentPaymentModalState === PaymentModalState.CREATING_PAYOS
            || currentPaymentModalState === PaymentModalState.VERIFYING_PAYOS) return;
```

- [ ] **Step 12: Reset PayOS state when the modal (re)opens** — in `openStaffInvoiceModal` (line ~2234), alongside the existing `currentBankTransferPayment = null;`:

```javascript
        currentPayOSPayment = null;
        stopPayOSPolling();
```

- [ ] **Step 13: JS syntax check** — extract the `<script>` block, substitute `${pageContext.request.contextPath}` with an empty string literal, run `node --check` against it. Expected: no output (valid syntax).

- [ ] **Step 14: Commit-ready review** — re-read the full diff of `CheckIn.jsp` once assembled to confirm every new `id` referenced in JS exists in the HTML and every state transition has a corresponding `setPaymentModalState` branch.

---

### Task 11: Full build, static verification, and report

**Files:** none (verification only)

- [ ] **Step 1: Full compile + package** — `mvn -q clean package` → BUILD SUCCESS, WAR produced.
- [ ] **Step 2: `node --check`** on the extracted `CheckIn.jsp` script block.
- [ ] **Step 3: Trace all 20 spec test cases** against the code (manual review — no live DB/Tomcat/browser in this sandbox) and record which are provable by code inspection vs. which need the user's own pass with `.\start_server.bat` + a public tunnel for the webhook.
- [ ] **Step 4: Report** per the structure requested (old vs new credential source, architecture, client creation, attempt create/reuse, webhook routing, polling, dedup/idempotency, files changed, migration, masked sample response, per-test results, build result, what the user needs to configure for a public webhook, known gaps).
