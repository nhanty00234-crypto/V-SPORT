# V-SPORT P0 Booking/Payment Audit Fix — Implementation Plan

> **For agentic workers:** This plan is being executed inline in the same session that produced it (the author already holds full grounded context from a 6-way parallel codebase audit). It documents design decisions and file map rather than bite-sized handoff steps. If resuming in a fresh session, re-read the "Grounded findings" section before touching code.

**Goal:** Fix 7 confirmed P0 defects in the V-SPORT booking/payment backend (Java 17, Jakarta Servlet/JSP, JDBC/DAO, SQL Server, Tomcat 10.1, Maven) without changing architecture, without touching the remote DB (`14.225.217.109`, treated as production/unknown), and without breaking the Windows `start_server.bat` run path.

**Architecture:** No new layers. Fixes land in existing DAO/Service/Servlet files. Two small new shared units are added: `PaymentCalculator` (pure remaining-amount formula) and `NoShowEligibility` (pure no-show window check) — both testable without a DB. One new scheduler package replaces the "auto-complete on page load" anti-pattern with a proper `ScheduledExecutorService` + `ServletContextListener`.

**Tech Stack:** Same as repo (JDBC raw SQL, HikariCP pool via `DBUtil`, log4j2, JUnit 5 + Mockito already in `pom.xml`).

## Global Constraints

- Do not connect to, migrate, or run tests against `DB_URL` (`14.225.217.109`) — confirmed as unknown/production by the user.
- No new SQL migration files are required for this P0 phase — every column/index the fixes depend on already exists (`LichDatSan.DepositAmount/PaymentMethodConfirmed/TransactionCode/ConfirmedAt/ConfirmedBy/ConfirmSource/NoShowAt` via `sql/migration_reservation_hold.sql`; `HoaDon.LoaiHoaDon` via `sql/migration_hoadon_loai.sql`; the MAIN-invoice unique filtered index via `sql/migration_court_checkout.sql`). A read-only `sql/verify_p0_prerequisites.sql` diagnostic script is added instead, for the user to run manually and confirm those migrations are actually applied before this code goes live.
- Do not touch P1 items (CourtPricingService adoption everywhere, San.TrangThai future-booking block, preorder/inventory lifecycle, duplicate-line merge, block-edit-on-paid-invoice, daily-limit fix) — deferred per user decision, listed as backlog in the final report.
- Money stays `BigDecimal` in all new/changed code.
- Every state transition keeps: source-status guard in the `WHERE` clause, row lock (`UPDLOCK, ROWLOCK`) where money/state changes, and an affected-rows check that is idempotent-safe (0 rows = already-done, not an error) except where 0 rows genuinely means a conflict.

## Grounded findings (from audit, corrected vs. the original spec's assumptions)

1. **Scheduler bug is real**: `LichDatSanDAOImpl.updateExpiredBookingsAndFields()` (called lazily from 6+ read methods, no actual scheduler exists) flips `Đang sử dụng`→`Đã hoàn thành` in bulk by comparing `GioKetThuc` to `GETUTCDATE()+7h`, with no pricing/payment check. Fix: delete just that one SQL statement from the method (the other two statements — orphan-court release and `Chờ xác nhận` 2h expiry — are safe and correct, keep them). This makes every existing call site safe without touching 8 call sites individually.
2. **PayOS webhook never creates a HoaDon** in the legacy customer-booking flow (`PayOSWebhookServlet.confirmBookingPaid`) — it only flips `LichDatSan.TrangThai`. The "new flow" (manager/staff checkout via `PayOSPaymentFinalizationService`) already does this correctly and atomically (invoice + booking + court in one transaction) — use it as the template.
3. **`CheckoutService.finalizeLocked()` conflates "paid" with "finalized"**: its early-exit (`if (paid || finalizedEnd != null) return loadResult(...)`) skips locking `ActualEndAt`/computing segments whenever the invoice happens to already be paid — even if the session was never actually finalized (e.g., cash collected at check-in via `CheckInDAO.checkInKhachDatTruoc`'s payment-lock branch, session still ongoing). This is the root cause of the "checkout returns early without completing booking/releasing court" bug, and it's subtler than a simple early-return: finalization and settlement must be decoupled correctly, not just "don't return early."
4. Deposit-aware remaining-amount calc already exists correctly in `initBankTransfer`/`PayOSPaymentService` (`tongThanhToan - DepositAmount`), but is duplicated inline in two places with no shared formula, and `pay()`/`confirmBankTransfer()` don't expose it at all.
5. Split-bill block exists in `pay()` but is missing from `confirmBankTransfer()`.
6. No-show (`CheckInDAO.huyLichKhachBung`) has zero facility check, zero row lock, zero status/time guard, reuses `Đã hủy` instead of a distinct no-show status, and blindly cancels the invoice even if already paid.
7. Check-in (`CheckInDAO.checkInKhachDatTruoc`) has zero facility check, allows `Chờ xác nhận` (unconfirmed) bookings to check in, has no time window, and silently no-ops on a hardcoded `HoaDonID = -1` sentinel while still reporting success when no invoice exists.

## File Map

**New files:**
- `src/main/java/org/example/service/payment/PaymentCalculator.java` — pure `remainingAmount(gross, paid)` formula, single source of truth for P0-4.
- `src/main/java/org/example/service/checkin/NoShowEligibility.java` — pure eligibility check (status/date/grace-period), used by `CheckInDAO` and unit-testable without a DB.
- `src/main/java/org/example/scheduler/BookingExpiryScheduler.java` — sweep orchestrator (calls existing safe DAO/service sweeps).
- `src/main/java/org/example/scheduler/BookingSchedulerListener.java` — `@WebListener` `ServletContextListener`, owns the `ScheduledExecutorService` lifecycle.
- `sql/verify_p0_prerequisites.sql` — read-only diagnostic (no schema changes) confirming the columns/index this phase depends on are present.
- `src/test/java/org/example/service/payment/PaymentCalculatorTest.java`
- `src/test/java/org/example/service/checkin/NoShowEligibilityTest.java`
- `src/test/java/org/example/controller/PayOSWebhookAmountValidationTest.java` (pure validation logic extracted for testing)
- `src/test/java/org/example/service/checkout/CheckoutServiceSplitBillIntegrationTest.java` — gated by `TEST_DB_URL`, skipped by default.

**Modified files:**
- `src/main/java/org/example/dao/impl/LichDatSanDAOImpl.java` — remove the `Đang sử dụng`→`Đã hoàn thành` statement from `updateExpiredBookingsAndFields()`; delete dead `thanhToanHoaDonDatSan()` (uncalled, bypasses every invariant `CheckoutService` enforces).
- `src/main/java/org/example/dao/LichDatSanDAO.java` — remove `thanhToanHoaDonDatSan` from the interface.
- `src/main/java/org/example/dao/CheckInDAO.java` — `huyLichKhachBung` (add `requiredCoSoId`, lock, join `San`, `NoShowEligibility`, `Không đến` status, `NoShowAt`, don't blind-cancel a paid invoice); `checkInKhachDatTruoc` (add `requiredCoSoId`, reject `Chờ xác nhận`, time window, create MAIN invoice instead of `-1` sentinel); delete dead `stopOpenSession()` (uncalled duplicate of `CheckoutService`).
- `src/main/java/org/example/controller/staff/CheckInServlet.java` — pass `user.getCoSoId()` into both DAO calls, add `SecurityException` → HTTP 403 handling on the JSP-forwarding branch, add audit log call for no-show.
- `src/main/java/org/example/controller/PayOSWebhookServlet.java` — `handleLegacyCustomerBookingWebhook`/`confirmBookingPaid` rewritten to run in a locked transaction that creates-or-reuses the MAIN invoice, records deposit/payment-confirmation columns, sets `HoaDon.TrangThaiThanhToan`, and handles the `Quá hạn`-vs-webhook race.
- `src/main/java/org/example/service/checkout/CheckoutResult.java` — add `depositAmount`, `remainingAmount`.
- `src/main/java/org/example/service/checkout/CheckoutService.java` — decouple finalize/settle/complete in `finalizeLocked`; `pay()`/`confirmBankTransfer()` always complete booking + release court once truly finalized+settled, using an idempotent (no-throw-on-already-done) helper; split-bill check enforced in both.
- `src/main/java/org/example/service/payos/PayOSPaymentService.java` — use `checkout.remainingAmount()` instead of its own inline formula.
- `src/main/java/org/example/service/AuditLogService.java` — add a `logSystem(...)` overload for actors without an `HttpServletRequest`/authenticated `TaiKhoan` (webhook, scheduler).

## Task List

1. `PaymentCalculator` + test.
2. `NoShowEligibility` + test.
3. `CheckoutResult` + `CheckoutService` rewrite (finalize/settle/complete decoupling, split-bill enforcement everywhere, idempotent completion).
4. `PayOSPaymentService` reuse of `PaymentCalculator`.
5. `PayOSWebhookServlet` legacy-flow invoice creation rewrite + extracted amount-validation test.
6. `CheckInDAO.huyLichKhachBung` + `CheckInDAO.checkInKhachDatTruoc` rewrite; `CheckInServlet` call-site updates.
7. `LichDatSanDAOImpl.updateExpiredBookingsAndFields()` fix; delete dead `thanhToanHoaDonDatSan`/`stopOpenSession`.
8. Scheduler (`BookingExpiryScheduler` + `BookingSchedulerListener`).
9. `sql/verify_p0_prerequisites.sql`.
10. `mvn compile` + `mvn test` (excluding `TEST_DB_URL`-gated tests), iterate to green.
11. Final report + Windows manual verification checklist.

## Explicitly deferred (not this pass)

Cross-instance scheduler locking (`sp_getapplock`) — the actual deployment is a single Tomcat instance (`start_server.bat`, one `CATALINA_HOME`), so `ScheduledExecutorService.scheduleWithFixedDelay` already prevents overlapping sweeps for the real deployment; adding untestable DB-lock code for a hypothetical multi-instance future would violate YAGNI and can't be verified without touching the live DB. Documented as a future risk if they ever horizontally scale.
