# Reservation Hold — Phase 3 (Auto-Expire "Chờ thanh toán") Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Auto-expire `"Chờ thanh toán"` bookings whose `HoldExpiresAt` has passed, transitioning them to `"Quá hạn"`, using the exact same "call on every data-read entry point" pattern the codebase already uses for `updateExpiredBookingsAndFields()` — no new scheduler/thread.

**Architecture:** New `org.example.service.BookingLifecycleService` with a single static method `runExpirySweep()` that runs one idempotent, `GETDATE()`-only `UPDATE`. Called from the same 6 DAO read-methods that already call `LichDatSanDAOImpl.updateExpiredBookingsAndFields()`, which are exactly what backs `customer/dat-san`, `manager/dat-san`, `staff/dat-san`, and `staff/checkin`.

**Tech Stack:** Java 17, JDBC (`PreparedStatement`), SQL Server (T-SQL), SLF4J (matches `AuditLogService`'s logger choice — the new class lives in the same `org.example.service` package).

## Global Constraints

- No PayOS integration, no QR generation, no webhook, no `confirmBookingPayment`, no no-show handling, no UI rewrite, no `DatSanServlet` rewrite, no Vietnamese class/method/file renames, no route changes, no DB table/column renames.
- No `ServletContextListener`/`ScheduledExecutorService` in this phase — codebase has none today; adding one requires a separate plan/approval first.
- `HoldExpiresAt` comparison uses SQL Server `GETDATE()` only — never a value passed in from a caller.
- The sweep must be safe to run repeatedly and must not touch `"Đã xác nhận"`, `"Đã hoàn thành"`, `"Đã hủy"`, or any `"Chờ thanh toán"` row that still has time left (or `HoldExpiresAt IS NULL`, i.e. COD bookings).
- Do not call `AuditLogService.log(...)` — both overloads require a non-null `HttpServletRequest` and non-null `TaiKhoan` actor (see report); adding a SYSTEM-actor overload is out of scope for this phase.

---

### Task 1: `BookingLifecycleService.runExpirySweep()`

**Files:**
- Create: `src/main/java/org/example/service/BookingLifecycleService.java`

**Interfaces:**
- Produces: `BookingLifecycleService.runExpirySweep()` (public static, no args, no return) — consumed by Task 2's 6 call sites.
- Consumes: `Constants.TRANG_THAI_DAT_SAN_CHO_THANH_TOAN`, `Constants.TRANG_THAI_DAT_SAN_QUA_HAN` (both already exist from Phase 1/2), `DBUtil.getConnection()`.

- [ ] **Step 1: Write the class**

```java
package org.example.service;

import org.example.util.Constants;
import org.example.util.DBUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

/**
 * Dịch vụ xử lý vòng đời đơn đặt sân (reservation-hold lifecycle).
 * Hiện tại phụ trách auto-expire booking "Chờ thanh toán" đã quá HoldExpiresAt.
 * Được gọi lại tại các entry-point đọc dữ liệu đặt sân (lưới an toàn "on-read"),
 * theo đúng cách LichDatSanDAOImpl.updateExpiredBookingsAndFields() đã làm —
 * dự án chưa có scheduler/background thread nào.
 */
public class BookingLifecycleService {

    private static final Logger logger = LoggerFactory.getLogger(BookingLifecycleService.class);

    private BookingLifecycleService() {
    }

    /**
     * Quét và tự động chuyển các booking "Chờ thanh toán" đã quá HoldExpiresAt sang "Quá hạn".
     * An toàn khi gọi nhiều lần: chỉ UPDATE các row đang thật sự "Chờ thanh toán" VÀ đã quá hạn,
     * không đụng "Đã xác nhận"/"Đã hoàn thành"/"Đã hủy"/booking COD (HoldExpiresAt NULL).
     * Dùng GETDATE() phía SQL Server làm nguồn thời gian duy nhất — không nhận giờ từ caller.
     */
    public static void runExpirySweep() {
        String sql = "UPDATE LichDatSan " +
                "SET TrangThai = ?, " +
                "    GhiChu = CONCAT(ISNULL(GhiChu, N''), N' [Tự động: Quá hạn giữ chỗ thanh toán]') " +
                "WHERE TrangThai = ? " +
                "AND HoldExpiresAt IS NOT NULL " +
                "AND HoldExpiresAt < GETDATE()";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setNString(1, Constants.TRANG_THAI_DAT_SAN_QUA_HAN);
            ps.setNString(2, Constants.TRANG_THAI_DAT_SAN_CHO_THANH_TOAN);
            int affected = ps.executeUpdate();
            if (affected > 0) {
                logger.info("runExpirySweep: đã chuyển {} booking 'Chờ thanh toán' quá hạn sang 'Quá hạn'.", affected);
            }
        } catch (SQLException e) {
            logger.error("Lỗi khi chạy BookingLifecycleService.runExpirySweep(): {}", e.getMessage(), e);
        }
    }
}
```

- [ ] **Step 2: Verify by manual trace (sandbox has no `mvn`/live DB)**

Trace the WHERE clause against the 4 required cases:
1. `TrangThai='Chờ thanh toán'`, `HoldExpiresAt` = 5 min in the past → matches all 3 conditions → updates to `'Quá hạn'`. Correct.
2. `TrangThai='Chờ thanh toán'`, `HoldExpiresAt` = 5 min in the future → `HoldExpiresAt < GETDATE()` false → not updated. Correct.
3. `TrangThai='Chờ thanh toán'`, `HoldExpiresAt IS NULL` (shouldn't normally happen post-Phase-2, but legacy/edge case) → `HoldExpiresAt IS NOT NULL` false → not updated (matches "an toàn với dữ liệu cũ chưa backfill" from the earlier migration fix). Correct, no crash on NULL.
4. `TrangThai='Chờ xác nhận'` (COD, `HoldExpiresAt` always NULL) → first condition `TrangThai = ?` fails → not updated. Correct.
5. Run twice in a row on the same data: 2nd run's `WHERE TrangThai = 'Chờ thanh toán'` no longer matches rows already flipped to `'Quá hạn'` in run 1 → `affected = 0` on the 2nd run, no error, no double-append to `GhiChu`. Correct (idempotent).

Then run yourself: `mvn -q -pl . compile` → expect `BUILD SUCCESS`.

- [ ] **Step 3: Commit**

```bash
git add src/main/java/org/example/service/BookingLifecycleService.java
git commit -m "Add BookingLifecycleService.runExpirySweep() for auto-expiring Chờ thanh toán holds"
```

---

### Task 2: Wire `runExpirySweep()` into the 6 existing read entry-points

**Files:**
- Modify: `src/main/java/org/example/dao/impl/LichDatSanDAOImpl.java` (4 call sites: lines ~71, ~88, ~343, ~367 — right after each existing `updateExpiredBookingsAndFields();` call)
- Modify: `src/main/java/org/example/dao/CheckInDAO.java` (2 call sites: lines ~581, ~628 — right after each existing `org.example.dao.impl.LichDatSanDAOImpl.updateExpiredBookingsAndFields();` call)

**Interfaces:**
- Consumes: `BookingLifecycleService.runExpirySweep()` from Task 1.
- Produces: nothing new — terminal change for this phase.

- [ ] **Step 1: `LichDatSanDAOImpl.java` — add the call right after each existing lazy-cleanup call**

At each of the 4 sites (`getAllLichDatSan()`, `getLichByAccountId()`, `getLichDatSanTodayByCoSo()`, `getLichDatSanByCoSo()`), change:
```java
        updateExpiredBookingsAndFields();
```
to:
```java
        updateExpiredBookingsAndFields();
        org.example.service.BookingLifecycleService.runExpirySweep();
```
(Fully-qualified call, no new import — matches the existing convention already used in this same file family for cross-package static calls, see `CheckInDAO.java`'s calls to `org.example.dao.impl.LichDatSanDAOImpl.updateExpiredBookingsAndFields()`.)

- [ ] **Step 2: `CheckInDAO.java` — same, at the 2 sites**

At `getDanhSachSan(int coSoId)` and `getDanhSachLichCheckInHomNay(int coSoId)`, change:
```java
        org.example.dao.impl.LichDatSanDAOImpl.updateExpiredBookingsAndFields();
```
to:
```java
        org.example.dao.impl.LichDatSanDAOImpl.updateExpiredBookingsAndFields();
        org.example.service.BookingLifecycleService.runExpirySweep();
```

- [ ] **Step 3: Verify**

Run: `grep -n "BookingLifecycleService.runExpirySweep()" src/main/java/org/example/dao/impl/LichDatSanDAOImpl.java src/main/java/org/example/dao/CheckInDAO.java`
Expected: exactly 4 matches in `LichDatSanDAOImpl.java`, exactly 2 in `CheckInDAO.java` — 6 total.

Run yourself: `mvn -q -pl . compile` → expect `BUILD SUCCESS`.

- [ ] **Step 4: Commit**

```bash
git add src/main/java/org/example/dao/impl/LichDatSanDAOImpl.java src/main/java/org/example/dao/CheckInDAO.java
git commit -m "Call BookingLifecycleService.runExpirySweep() from existing booking-list read paths

Covers customer/dat-san, customer/lich-su-dat-san, manager/dat-san,
staff/dat-san, and staff/checkin — all of them already call
updateExpiredBookingsAndFields() at the same spots, so this rides the
same lazy on-read cleanup convention instead of adding new call sites
in controllers/JSP."
```

---

## Self-Review Notes

- **Spec coverage**: matches spec section 9's `expireOverdueHolds()` SQL exactly (status transition, `HoldExpiresAt < GETDATE()` guard). Scheduler (`BookingSchedulerListener`) from spec section 9 is explicitly deferred — this phase only does the "lưới an toàn" (lazy on-read) half, per this phase's item 8 instruction.
- **Audit log**: deliberately not implemented — reported instead, per item 6's explicit escape hatch. Reason: `AuditLogService`'s only 2 overloads require non-null `HttpServletRequest` + `TaiKhoan actor`, and `runExpirySweep()` runs from a static DAO-layer context with neither.
- **Placeholder scan**: none.
- **Type consistency**: `runExpirySweep()` has no params/return in both its Task 1 definition and Task 2's 6 call sites.
