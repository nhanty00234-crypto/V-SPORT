# Reservation Hold — Phase 1 (Schema + Constants) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the database columns, `Constants.java` values, and JPA entity fields that the reservation-hold state machine (spec: `docs/superpowers/specs/2026-07-09-auto-booking-reservation-hold-design.md`, sections 5 and 6) needs — pure scaffolding, no behavior change.

**Architecture:** One idempotent SQL migration file (following the existing `sql/migration_*.sql` convention) adds 8 nullable columns to `LichDatSan`. `Constants.java` gets new status/config values appended to its existing sectioned layout. `Lichdatsan.java` gets matching `@Column`-mapped fields + getters/setters, following the exact style already used for `TimeMode`/`ReservedDurationMinutes`. `HoaDon.java` needs no change — `TrangThaiThanhToan` is already `NVARCHAR(50)` free-text, so the new `"Đã cọc"` value needs no schema/model change, only the `Constants` entry.

**Tech Stack:** Java 17, Jakarta Persistence annotations (no Hibernate migration tooling — manual SQL), SQL Server (T-SQL), Maven (`pom.xml`, Java 17 source/target).

## Global Constraints

- No hard-coded minute/hour values anywhere — every timing constant lives in `Constants.java` (per spec section 6).
- Only 2 new `TrangThai` values allowed: `"Quá hạn"`, `"Không đến"` — do not rename or remove any existing status string (per spec section 4).
- All new SQL columns use PascalCase, matching the most recently added columns (`TimeMode`, `ReservedDurationMinutes`) — no new snake_case columns (per spec section 5).
- Migration SQL must be idempotent (safe to run twice) — follow the `IF NOT EXISTS (SELECT 1 FROM sys.columns ...)` pattern used in `sql/migration_hoadon_loai.sql`.
- Out of scope (do not touch in this plan): booking creation algorithm, overlap-check SQL, `CheckInDAO`, any JSP/UI, audit log calls, scheduler/background thread.
- **Environment note:** this sandbox has no `mvn`/`sqlcmd` installed and no live SQL Server instance reachable. Verification steps below use manual review + the exact commands to run in a real dev environment (with Maven/SQL Server available) — run those commands yourself after each task and report the actual output before considering a task done.

---

### Task 1: SQL migration for `LichDatSan` reservation-hold columns

**Files:**
- Create: `sql/migration_reservation_hold.sql`

**Interfaces:**
- Consumes: nothing (pure DDL).
- Produces: 8 new nullable columns on `LichDatSan` — `HoldExpiresAt` (DATETIME2), `DepositAmount` (DECIMAL(18,2)), `PaymentMethodConfirmed` (NVARCHAR(50)), `TransactionCode` (NVARCHAR(100)), `ConfirmedAt` (DATETIME2), `ConfirmedBy` (INT, FK → `Accounts(AccountID)`), `ConfirmSource` (NVARCHAR(20)), `NoShowAt` (DATETIME2). Later phases (booking algorithm, payment confirm endpoint) read/write these columns by exact name.

- [ ] **Step 1: Write the migration script**

Create `sql/migration_reservation_hold.sql`:

```sql
-- Migration: Thêm cột reservation-hold vào bảng LichDatSan
-- Chạy một lần trên DB thực. Script có kiểm tra IF NOT EXISTS nên an toàn khi chạy lại.
-- Áp dụng cho: V-SPORT QuanLiSport_V4 trở lên
-- Liên quan: docs/superpowers/specs/2026-07-09-auto-booking-reservation-hold-design.md (mục 5)

USE QuanLiSport;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'LichDatSan') AND name = N'HoldExpiresAt'
)
BEGIN
    ALTER TABLE LichDatSan
    ADD HoldExpiresAt DATETIME2 NULL;
    PRINT N'Đã thêm cột HoldExpiresAt vào LichDatSan.';
END
ELSE
    PRINT N'Cột HoldExpiresAt đã tồn tại, bỏ qua.';
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'LichDatSan') AND name = N'DepositAmount'
)
BEGIN
    ALTER TABLE LichDatSan
    ADD DepositAmount DECIMAL(18,2) NULL;
    PRINT N'Đã thêm cột DepositAmount vào LichDatSan.';
END
ELSE
    PRINT N'Cột DepositAmount đã tồn tại, bỏ qua.';
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'LichDatSan') AND name = N'PaymentMethodConfirmed'
)
BEGIN
    ALTER TABLE LichDatSan
    ADD PaymentMethodConfirmed NVARCHAR(50) NULL;
    PRINT N'Đã thêm cột PaymentMethodConfirmed vào LichDatSan.';
END
ELSE
    PRINT N'Cột PaymentMethodConfirmed đã tồn tại, bỏ qua.';
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'LichDatSan') AND name = N'TransactionCode'
)
BEGIN
    ALTER TABLE LichDatSan
    ADD TransactionCode NVARCHAR(100) NULL;
    PRINT N'Đã thêm cột TransactionCode vào LichDatSan.';
END
ELSE
    PRINT N'Cột TransactionCode đã tồn tại, bỏ qua.';
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'LichDatSan') AND name = N'ConfirmedAt'
)
BEGIN
    ALTER TABLE LichDatSan
    ADD ConfirmedAt DATETIME2 NULL;
    PRINT N'Đã thêm cột ConfirmedAt vào LichDatSan.';
END
ELSE
    PRINT N'Cột ConfirmedAt đã tồn tại, bỏ qua.';
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'LichDatSan') AND name = N'ConfirmedBy'
)
BEGIN
    ALTER TABLE LichDatSan
    ADD ConfirmedBy INT NULL;
    PRINT N'Đã thêm cột ConfirmedBy vào LichDatSan.';
END
ELSE
    PRINT N'Cột ConfirmedBy đã tồn tại, bỏ qua.';
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'LichDatSan') AND name = N'ConfirmSource'
)
BEGIN
    ALTER TABLE LichDatSan
    ADD ConfirmSource NVARCHAR(20) NULL;
    PRINT N'Đã thêm cột ConfirmSource vào LichDatSan.';
END
ELSE
    PRINT N'Cột ConfirmSource đã tồn tại, bỏ qua.';
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'LichDatSan') AND name = N'NoShowAt'
)
BEGIN
    ALTER TABLE LichDatSan
    ADD NoShowAt DATETIME2 NULL;
    PRINT N'Đã thêm cột NoShowAt vào LichDatSan.';
END
ELSE
    PRINT N'Cột NoShowAt đã tồn tại, bỏ qua.';
GO

-- FK ConfirmedBy → Accounts.AccountID (chỉ thêm nếu chưa có)
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_LichDatSan_ConfirmedBy' AND parent_object_id = OBJECT_ID(N'LichDatSan')
)
BEGIN
    ALTER TABLE LichDatSan
    ADD CONSTRAINT FK_LichDatSan_ConfirmedBy
        FOREIGN KEY (ConfirmedBy) REFERENCES Accounts(AccountID);
    PRINT N'Đã thêm FK ConfirmedBy.';
END
GO

PRINT N'Migration reservation-hold hoàn tất.';
GO
```

- [ ] **Step 2: Verify idempotency and correctness by manual review**

This sandbox has no `sqlcmd`/live SQL Server, so run this check yourself in your dev environment:

Run: `sqlcmd -S <server> -d QuanLiSport -i sql/migration_reservation_hold.sql` twice in a row.

Expected: first run prints 8× `"Đã thêm cột ..."` + `"Đã thêm FK ConfirmedBy."` + `"Migration reservation-hold hoàn tất."`; second run prints 8× `"... đã tồn tại, bỏ qua."` and no error (FK block silently no-ops since the `IF NOT EXISTS` guard on `sys.foreign_keys` prevents a duplicate-constraint error).

Also sanity-check no name collision before running: `grep -n "HoldExpiresAt\|DepositAmount\|PaymentMethodConfirmed\|TransactionCode\|ConfirmedAt\|ConfirmedBy\|ConfirmSource\|NoShowAt" "Tài nguyên/QuanLiSport_V4.sql"` should return nothing (confirms these column names don't already exist in the base schema).

- [ ] **Step 3: Commit**

```bash
git add sql/migration_reservation_hold.sql
git commit -m "Add migration for reservation-hold columns on LichDatSan"
```

---

### Task 2: `Constants.java` — reservation-hold config and new status values

**Files:**
- Modify: `src/main/java/org/example/util/Constants.java`

**Interfaces:**
- Consumes: nothing.
- Produces (exact names later tasks/phases will reference):
  - `Constants.BOOKING_HOLD_MINUTES` (int)
  - `Constants.NO_SHOW_GRACE_MINUTES` (int)
  - `Constants.COD_APPROVAL_EXPIRE_HOURS` (int)
  - `Constants.NO_SHOW_AUTO_MODE` (boolean)
  - `Constants.TRANG_THAI_DAT_SAN_QUA_HAN` (String = `"Quá hạn"`)
  - `Constants.TRANG_THAI_DAT_SAN_KHONG_DEN` (String = `"Không đến"`)
  - `Constants.TRANG_THAI_HOA_DON_DA_COC` (String = `"Đã cọc"`)

- [ ] **Step 1: Add the new status constants next to the existing booking/invoice status blocks**

In `src/main/java/org/example/util/Constants.java`, edit the `BOOKING (LichDatSan) STATUS` block (currently lines 16-21):

```java
    // ========== BOOKING (LichDatSan) STATUS ==========
    public static final String TRANG_THAI_DAT_SAN_CHO_XAC_NHAN = "Chờ xác nhận";
    public static final String TRANG_THAI_DAT_SAN_DA_XAC_NHAN = "Đã xác nhận";
    public static final String TRANG_THAI_DAT_SAN_DA_HUY = "Đã hủy";
    public static final String TRANG_THAI_DAT_SAN_DANG_CHOI = "Đang chơi";
    public static final String TRANG_THAI_DAT_SAN_DA_HOAN_THANH = "Đã hoàn thành";
    // Reservation-hold (docs/superpowers/specs/2026-07-09-auto-booking-reservation-hold-design.md, mục 4)
    public static final String TRANG_THAI_DAT_SAN_CHO_THANH_TOAN = "Chờ thanh toán";
    public static final String TRANG_THAI_DAT_SAN_QUA_HAN = "Quá hạn";
    public static final String TRANG_THAI_DAT_SAN_KHONG_DEN = "Không đến";
```

`TRANG_THAI_DAT_SAN_CHO_THANH_TOAN` is added here too even though the string itself already exists elsewhere in the codebase as a raw literal (`DatSanServlet.java`) — the spec's principle #1 is "tái dùng tối đa"; centralizing this pre-existing literal as a named constant is in scope for this task since Phase 1 explicitly asks to "đồng bộ Constants.java", but **do not** go replace the raw-literal usages in `DatSanServlet`/`LichDatSanDAOImpl` in this task — that's an algorithm-touching change reserved for a later phase (this plan's Global Constraints exclude it).

- [ ] **Step 2: Add the new invoice status constant**

In the same file, edit the `INVOICE (HoaDon) STATUS` block (currently lines 27-31):

```java
    // ========== INVOICE (HoaDon) STATUS ==========
    public static final String TRANG_THAI_HOA_DON_CHUA_TT = "Chưa thanh toán";
    public static final String TRANG_THAI_HOA_DON_DA_TT = "Đã thanh toán";
    public static final String TRANG_THAI_HOA_DON_HOAN_TIEN = "Hoàn tiền";
    public static final String TRANG_THAI_HOA_DON_GHI_NO = "Ghi nợ";
    public static final String TRANG_THAI_HOA_DON_DA_COC = "Đã cọc";
```

- [ ] **Step 3: Add the reservation-hold timing/config constants**

In the same file, edit the `TIMEOUT` block (currently lines 23-25):

```java
    // ========== TIMEOUT ==========
    public static final int PENDING_PAYMENT_TIMEOUT_MINUTES = 10;
    public static final int SOFT_HOLD_TIMEOUT_MINUTES = 2;
    // Reservation-hold (docs/superpowers/specs/2026-07-09-auto-booking-reservation-hold-design.md, mục 6)
    public static final int BOOKING_HOLD_MINUTES = 10;
    public static final int NO_SHOW_GRACE_MINUTES = 15;
    public static final int COD_APPROVAL_EXPIRE_HOURS = 2;
    public static final boolean NO_SHOW_AUTO_MODE = false;
```

Note: `BOOKING_HOLD_MINUTES` duplicates the value of the existing `PENDING_PAYMENT_TIMEOUT_MINUTES` (both 10). This is intentional, not a mistake — leave both in place. `PENDING_PAYMENT_TIMEOUT_MINUTES` is the pre-existing constant already read elsewhere in the codebase for the current (lazy/self-healing) 10-minute window; `BOOKING_HOLD_MINUTES` is the new spec-named constant that a later phase will wire into `HoldExpiresAt = DATEADD(MINUTE, @BOOKING_HOLD_MINUTES, GETDATE())`. Reconciling/removing the duplicate is an algorithm-touching decision out of scope for this schema-only phase.

- [ ] **Step 4: Verify the file still compiles**

This sandbox has no `mvn`, so run this yourself in your dev environment:

Run: `mvn -q -pl . compile` (or your IDE's build)
Expected: `BUILD SUCCESS`, no errors in `Constants.java`.

As a manual substitute check in this sandbox, re-read the full edited block and confirm: every new line ends with `;`, no duplicate constant names were introduced, and the class still ends with the existing `private Constants() {}` constructor and closing brace untouched.

- [ ] **Step 5: Commit**

```bash
git add src/main/java/org/example/util/Constants.java
git commit -m "Add reservation-hold status and config constants"
```

---

### Task 3: `Lichdatsan.java` entity — map the 8 new columns

**Files:**
- Modify: `src/main/java/org/example/model/Lichdatsan.java`

**Interfaces:**
- Consumes: the 8 columns created by Task 1 (must already exist on `LichDatSan` in the target DB for JPA reads to work correctly, though this task itself only requires the columns to exist in *some* DB the app connects to before the app is run — it doesn't affect compilation).
- Produces (exact getter/setter names later phases will call):
  - `getHoldExpiresAt()/setHoldExpiresAt(LocalDateTime)`
  - `getDepositAmount()/setDepositAmount(BigDecimal)`
  - `getPaymentMethodConfirmed()/setPaymentMethodConfirmed(String)`
  - `getTransactionCode()/setTransactionCode(String)`
  - `getConfirmedAt()/setConfirmedAt(LocalDateTime)`
  - `getConfirmedBy()/setConfirmedBy(Integer)`
  - `getConfirmSource()/setConfirmSource(String)`
  - `getNoShowAt()/setNoShowAt(LocalDateTime)`

- [ ] **Step 1: Add the 8 new fields**

In `src/main/java/org/example/model/Lichdatsan.java`, insert after the existing `earlyCheckoutDiscount` field (currently line 75, right before the `// Relationships` comment on line 77):

```java
    @Column(name = "HoldExpiresAt")
    private LocalDateTime holdExpiresAt;

    @Column(name = "DepositAmount")
    private BigDecimal depositAmount;

    @Column(name = "PaymentMethodConfirmed", length = 50)
    private String paymentMethodConfirmed;

    @Column(name = "TransactionCode", length = 100)
    private String transactionCode;

    @Column(name = "ConfirmedAt")
    private LocalDateTime confirmedAt;

    @Column(name = "ConfirmedBy")
    private Integer confirmedBy;

    @Column(name = "ConfirmSource", length = 20)
    private String confirmSource;

    @Column(name = "NoShowAt")
    private LocalDateTime noShowAt;
```

No new import is needed — `LocalDateTime` and `BigDecimal` are already imported (lines 4, 7).

- [ ] **Step 2: Add matching getters/setters**

In the same file, insert after the existing `getEarlyCheckoutDiscount`/`setEarlyCheckoutDiscount` pair (currently lines 267-273), right before the `@Override public String toString()` block:

```java
    public LocalDateTime getHoldExpiresAt() {
        return holdExpiresAt;
    }

    public void setHoldExpiresAt(LocalDateTime holdExpiresAt) {
        this.holdExpiresAt = holdExpiresAt;
    }

    public BigDecimal getDepositAmount() {
        return depositAmount;
    }

    public void setDepositAmount(BigDecimal depositAmount) {
        this.depositAmount = depositAmount;
    }

    public String getPaymentMethodConfirmed() {
        return paymentMethodConfirmed;
    }

    public void setPaymentMethodConfirmed(String paymentMethodConfirmed) {
        this.paymentMethodConfirmed = paymentMethodConfirmed;
    }

    public String getTransactionCode() {
        return transactionCode;
    }

    public void setTransactionCode(String transactionCode) {
        this.transactionCode = transactionCode;
    }

    public LocalDateTime getConfirmedAt() {
        return confirmedAt;
    }

    public void setConfirmedAt(LocalDateTime confirmedAt) {
        this.confirmedAt = confirmedAt;
    }

    public Integer getConfirmedBy() {
        return confirmedBy;
    }

    public void setConfirmedBy(Integer confirmedBy) {
        this.confirmedBy = confirmedBy;
    }

    public String getConfirmSource() {
        return confirmSource;
    }

    public void setConfirmSource(String confirmSource) {
        this.confirmSource = confirmSource;
    }

    public LocalDateTime getNoShowAt() {
        return noShowAt;
    }

    public void setNoShowAt(LocalDateTime noShowAt) {
        this.noShowAt = noShowAt;
    }
```

Do **not** add these 8 fields to the existing `toString()` method or to the multi-arg constructor (`Lichdatsan(int, Integer, Integer, ...)`) — both are legacy patterns already used only for the original column set (`IsDeleted`/`TimeMode`/etc. are also absent from both), and touching either is unrelated to this task's scope.

- [ ] **Step 3: Verify the file compiles**

Run yourself: `mvn -q -pl . compile`
Expected: `BUILD SUCCESS`.

Manual substitute check in this sandbox: confirm every new field has exactly one matching getter and one matching setter, confirm no field name collides with an existing field (`holdExpiresAt`, `depositAmount`, `paymentMethodConfirmed`, `transactionCode`, `confirmedAt`, `confirmedBy`, `confirmSource`, `noShowAt` — none of these appear earlier in the file), and confirm braces balance (file must still end with a single closing `}` for the class after `toString()`).

- [ ] **Step 4: Commit**

```bash
git add src/main/java/org/example/model/Lichdatsan.java
git commit -m "Map reservation-hold columns onto Lichdatsan entity"
```

---

### Task 4: `HoaDon.java` — confirm no model change is needed

**Files:**
- None modified. This task is a documented verification, not a code change.

**Interfaces:**
- Consumes: `Constants.TRANG_THAI_HOA_DON_DA_COC` from Task 2.
- Produces: nothing new — `HoaDon.getTrangThaiThanhToan()`/`setTrangThaiThanhToan(String)` (already exist, `HoaDon.java:133-134`) are sufficient for later phases to write `"Đã cọc"` into.

- [ ] **Step 1: Confirm `TrangThaiThanhToan` is free-text and needs no schema/model change**

Run: `grep -n -A1 "TrangThaiThanhToan" "Tài nguyên/QuanLiSport_V4.sql"`
Expected output includes `TrangThaiThanhToan     NVARCHAR(50),` — confirming it's an unconstrained `NVARCHAR(50)` column (no `CHECK` constraint, no foreign key to a lookup table), and `"Đã cọc"` (5 characters) fits well within 50 chars. Since `HoaDon.java:48-49` already maps this column via plain `String trangThaiThanhToan` with existing getter/setter, no entity change is required — the new value flows through unchanged existing code paths.

- [ ] **Step 2: No commit needed for this task** (no files changed).

---

## Self-Review Notes

- **Spec coverage**: Task 1 covers spec section 5 (schema). Task 2 covers spec section 6 (config) + the new-status part of section 4. Task 3 covers the "cập nhật model" requirement for `Lichdatsan`. Task 4 explicitly closes out the "cập nhật model HoaDon nếu cần" requirement by showing why no change is needed, rather than leaving it silently unaddressed.
- **Placeholder scan**: no TBD/TODO; every step shows exact code or exact grep/build commands.
- **Type consistency**: `Lichdatsan` getters/setters use `LocalDateTime` for all 3 new timestamp columns (`HoldExpiresAt`, `ConfirmedAt`, `NoShowAt`) — matches the existing `createdTime`/`deletedAt` fields' type (`LocalDateTime`), not `LocalDate`/`LocalTime` (which are reserved for the existing `ngayDat`/`gioBatDau` fields that represent the booking's calendar date/time, a different concept from these new audit timestamps).
- **Explicitly out of scope, confirmed with user**: booking algorithm, overlap-check, `CheckInDAO`, JSP/UI, audit log wiring, background scheduler — none of Tasks 1-4 touch these.
