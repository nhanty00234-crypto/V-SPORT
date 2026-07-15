# V-SPORT P0 Booking/Payment Audit — Final Report

Scope executed: **P0 items only** (per explicit scope decision this session). P1 items
(CourtPricingService adoption everywhere, San.TrangThai future-booking block, preorder/inventory
lifecycle, duplicate-line merge, block-edit-on-paid-invoice, daily-limit fix) are **not started** —
see §14.

No code was run against the remote DB (`14.225.217.109`, treated as production/unknown). No
migration was executed. Nothing in `.env` was read beyond variable *names*.

---

## 1. Root cause of each fixed defect

| # | Defect | Root cause |
|---|---|---|
| P0-1 | Scheduler auto-completed sessions | No real scheduler existed. `LichDatSanDAOImpl.updateExpiredBookingsAndFields()` ran a bulk `UPDATE LichDatSan SET TrangThai=N'Đã hoàn thành' WHERE TrangThai=N'Đang sử dụng' AND GioKetThuc < now` as a *side effect* embedded in 6+ read methods (`getAllLichDatSan`, `getDanhSachSan`, etc.) — any page load could silently "complete" and bill nobody for a still-running session. |
| P0-2 | PayOS webhook created no invoice | Two parallel PayOS flows share one webhook route. The "new" flow (manager/staff checkout) correctly used `PayOSPaymentFinalizationService`. The "legacy" flow (customer direct booking, `DatSanServlet`) had its own `confirmBookingPaid()` that only flipped `LichDatSan.TrangThai` — it never touched `HoaDon` at all, and used a raw un-transacted, unlocked `UPDATE`. |
| P0-3 | Checkout returned early without completing booking/court | `CheckoutService.finalizeLocked()` conflated **finalize** (lock `ActualEndAt` + compute segment pricing) with **settle** (invoice marked paid): `if (paid || finalizedEnd != null) return loadResult(...)` skipped finalization entirely whenever the invoice happened to already be paid (e.g. cash collected at check-in via `CheckInDAO.checkInKhachDatTruoc`'s payment-lock branch, while the session was still running). `pay()`'s `if (result.alreadyPaid()) return` then skipped booking-complete/court-release forever. |
| P0-4 | Deposit not honored in cash/card payment | `initBankTransfer()`/`PayOSPaymentService` correctly computed `remaining = gross - DepositAmount`, but this formula was duplicated inline in two places and not applied/exposed at all in `pay()` or `CheckoutResult`. |
| P0-5 | Split-bill block missing on some paths | `pay()` had an inline SPLIT-unpaid check; `confirmBankTransfer()` had none at all — a bank-transfer checkout could complete a booking/release a court while a SPLIT invoice was still unpaid. The existing check also didn't exclude legitimately-cancelled SPLIT bills (`TrangThaiThanhToan <> N'Đã thanh toán'` matches `'Đã hủy'` too). |
| P0-6 | No-show IDOR + unsafe state | `CheckInDAO.huyLichKhachBung()` took no facility parameter, no row lock, no status/time guard (could no-show an already-checked-in "Đang sử dụng" booking), reused `'Đã hủy'` instead of a distinct status, and unconditionally cancelled the invoice even if already paid/deposited. |
| P0-7 | Check-in `HoaDonID = -1` fake success | `checkInKhachDatTruoc()` took no facility parameter, allowed unconfirmed (`Chờ xác nhận`) bookings to check in, had no time window, and — when no MAIN invoice row existed — ran `UPDATE HoaDon ... WHERE HoaDonID = -1` (a guaranteed no-op) yet still logged/treated it as "paid successfully." |

## 2. Files modified

- [`src/main/java/org/example/dao/impl/LichDatSanDAOImpl.java`](src/main/java/org/example/dao/impl/LichDatSanDAOImpl.java) — removed the dangerous auto-complete statement from `updateExpiredBookingsAndFields()`; uses `Constants.COD_APPROVAL_EXPIRE_HOURS`; deleted dead `thanhToanHoaDonDatSan()` (uncalled, bypassed every checkout invariant).
- [`src/main/java/org/example/dao/LichDatSanDAO.java`](src/main/java/org/example/dao/LichDatSanDAO.java) — removed `thanhToanHoaDonDatSan` from the interface.
- [`src/main/java/org/example/dao/CheckInDAO.java`](src/main/java/org/example/dao/CheckInDAO.java) — `huyLichKhachBung` (facility check, row lock, `NoShowEligibility`, `Không đến` status, `NoShowAt`, no blind invoice cancel); `checkInKhachDatTruoc` (facility check, reject `Chờ xác nhận`, `CheckInWindow`, create MAIN invoice instead of `-1` sentinel, affected-row guard on final UPDATE); deleted dead `stopOpenSession()` (uncalled duplicate of `CheckoutService`, used `double` money math).
- [`src/main/java/org/example/controller/staff/CheckInServlet.java`](src/main/java/org/example/controller/staff/CheckInServlet.java) — pass `user.getCoSoId()` into both DAO calls; `SecurityException` → HTTP 403; audit log call for no-show; expose `depositAmount`/`remainingAmount` in payment JSON responses.
- [`src/main/java/org/example/controller/PayOSWebhookServlet.java`](src/main/java/org/example/controller/PayOSWebhookServlet.java) — legacy customer-booking flow now delegates to `PayOSLegacyBookingFinalizationService`; removed the old no-op, unlocked `confirmBookingPaid()`.
- [`src/main/java/org/example/controller/customer/DatSanServlet.java`](src/main/java/org/example/controller/customer/DatSanServlet.java) — the "already PayOS-paid, block self-cancel" check now trusts `PaymentMethodConfirmed='PayOS'` (the reliable field) as primary signal, `GhiChu` marker kept only as a fallback for pre-fix data.
- [`src/main/java/org/example/service/checkout/CheckoutResult.java`](src/main/java/org/example/service/checkout/CheckoutResult.java) — added `depositAmount`, `remainingAmount`.
- [`src/main/java/org/example/service/checkout/CheckoutService.java`](src/main/java/org/example/service/checkout/CheckoutService.java) — `finalizeLocked` decouples finalize/settle; `pay()`/`confirmBankTransfer()` always run `completeBookingAndReleaseCourtIfNeeded()` (idempotent) after finalize+settle are both true, never return early past that point; split-bill check (`assertNoUnpaidSplitBills`, now excludes cancelled SPLIT bills) enforced in both `pay()` and `confirmBankTransfer()`.
- [`src/main/java/org/example/service/payos/PayOSPaymentService.java`](src/main/java/org/example/service/payos/PayOSPaymentService.java) — reuses `CheckoutResult.remainingAmount()` instead of a duplicated inline formula; removed now-dead `readDepositAmount()`.
- [`src/main/java/org/example/service/AuditLogService.java`](src/main/java/org/example/service/AuditLogService.java) — added `logSystem(...)` overload for actors without an authenticated `HttpServletRequest`/`TaiKhoan` (available for future webhook/scheduler audit logging).

## 3. Files created

- `src/main/java/org/example/service/payment/PaymentCalculator.java` — single `remainingAmount(gross, paid)` formula (P0-4).
- `src/main/java/org/example/service/checkin/NoShowEligibility.java` — pure no-show eligibility check.
- `src/main/java/org/example/service/checkin/CheckInWindow.java` — pure check-in time-window check.
- `src/main/java/org/example/service/payos/PayOSLegacyBookingFinalizationService.java` — the one place allowed to confirm PayOS payment for the legacy customer-booking flow; creates/reuses MAIN invoice transactionally under `UPDLOCK, ROWLOCK`.
- `src/main/java/org/example/scheduler/BookingExpiryScheduler.java` — sweep orchestrator (safe sweeps only).
- `src/main/java/org/example/scheduler/BookingSchedulerListener.java` — `@WebListener`, owns a `ScheduledExecutorService` running the sweep every 60s.
- `sql/verify_p0_prerequisites.sql` — **read-only** diagnostic (no `ALTER`/`DROP`) confirming prior migrations are applied.
- Tests: `PaymentCalculatorTest`, `NoShowEligibilityTest`, `CheckInWindowTest`, `PayOSLegacyBookingFinalizationServiceTest` (see §12).
- `docs/superpowers/plans/2026-07-15-vsport-p0-booking-payment-audit-fix.md` — the implementation plan this session followed.

## 4. Migrations

**None required.** Every column/index this P0 pass depends on already exists from prior migrations:
`sql/migration_reservation_hold.sql` (`LichDatSan.DepositAmount/PaymentMethodConfirmed/TransactionCode/ConfirmedAt/ConfirmedBy/ConfirmSource/NoShowAt`), `sql/migration_hoadon_loai.sql` (`HoaDon.LoaiHoaDon`), `sql/migration_court_checkout.sql` (`LichDatSan.ActualStartAt/ActualEndAt/PricingFinalizedAt`, `CourtChargeSegment` table, `UX_HoaDon_OneMainPerBooking` unique filtered index).

**Run order before deploying this code:**
1. Confirm all `/sql/migration_*.sql` files listed above have already run on the target DB (they predate this session).
2. Run `sql/verify_p0_prerequisites.sql` (read-only) and confirm every row says "OK", and that §5 of its output (duplicate MAIN invoices) returns **zero rows**. If it returns rows, resolve those duplicates manually before relying on the unique index — do this before deploying, since the new `PayOSLegacyBookingFinalizationService`/`CheckoutService` code assumes at most one MAIN invoice per booking.
3. Deploy the new WAR.

## 5. State machine after this fix

```
Customer PayOS:
  Chờ thanh toán --[webhook: đúng orderCode+amount+chữ ký]--> Đã xác nhận
  Đã xác nhận --[check-in đặt trước]--> Đang sử dụng
  Đang sử dụng --[CheckoutService.pay/confirmBankTransfer]--> Đã hoàn thành
  Chờ thanh toán --[HoldExpiresAt hết hạn, scheduler]--> Quá hạn
    (nếu thanh toán PayOS đến SAU KHI đã Quá hạn: vẫn xác nhận -> Đã xác nhận, không mất tiền)

Customer COD:
  Chờ xác nhận --[manager duyệt]--> Đã xác nhận
  Chờ xác nhận --[quá COD_APPROVAL_EXPIRE_HOURS, scheduler]--> Đã hủy
  Đã xác nhận --[check-in]--> Đang sử dụng --[checkout]--> Đã hoàn thành

No-show (P0-6, thao tác thủ công của lễ tân, KHÔNG tự động):
  Đã xác nhận --[huyLichKhachBung, cùng cơ sở, hôm nay, đã qua NO_SHOW_GRACE_MINUTES]--> Không đến
  (invoice: tự hủy CHỈ nếu chưa thu tiền gì; nếu đã thanh toán/cọc, giữ nguyên + ghi chú "cần xử lý thủ công")

Cancel:
  Chờ thanh toán/Chờ xác nhận --[khách tự hủy hoặc lễ tân]--> Đã hủy
```

Every transition above runs inside a transaction with a row lock (`UPDLOCK, ROWLOCK`), a source-status
`WHERE` guard, and an affected-rows check.

## 6. COD flow (unchanged logic, verified compiles/tests clean)

Đặt sân (Chờ xác nhận) → Manager duyệt (Đã xác nhận) → check-in (`checkInKhachDatTruoc`, now facility+status+window checked) → Đang sử dụng → dừng ca / thêm dịch vụ → `CheckoutService.pay()` (Tiền mặt/Chuyển khoản) → Đã hoàn thành + San Sẵn sàng.

## 7. Customer PayOS flow (P0-2, rewritten)

`DatSanServlet` creates `LichDatSan` (status `Chờ thanh toán`, `HoldExpiresAt` set) — still creates **no** invoice yet (unchanged, by design: no money has arrived). PayOS webhook fires → signature verified (`PayOSService.verifyWebhook`) → `PayOSLegacyBookingFinalizationService.confirmPaid()` runs in one locked transaction: re-reads status under `UPDLOCK`, classifies it (`ALREADY_CONFIRMED` / `CANCELLED` / `ELIGIBLE` covering both `Chờ thanh toán` and the `Quá hạn` race / `UNEXPECTED`), verifies amount == `TongTienDuKien`, creates-or-reuses exactly one MAIN `HoaDon`, writes `DepositAmount/PaymentMethodConfirmed=PayOS/TransactionCode/ConfirmedAt/ConfirmedBy=NULL/ConfirmSource=PAYOS_WEBHOOK`, sets `HoaDon.TrangThaiThanhToan` (`Đã thanh toán` or `Đã cọc`), transitions booking to `Đã xác nhận`. Webhook retries are idempotent (second call sees `Đã xác nhận`, reuses the same invoice, no duplicate). Check-in and checkout for a PayOS-paid booking follow the same COD path from `Đã xác nhận` onward — checkout still completes/releases the court even though the invoice was already paid (fixed by P0-3).

## 8. Check-in/checkout flow (P0-3/P0-4/P0-5/P0-7)

Check-in (`checkInKhachDatTruoc`): facility-scoped (`SecurityException`→403), only `Đã xác nhận` bookings, only within `[start-30min, start+NO_SHOW_GRACE_MINUTES]`, requires a MAIN invoice — creates one transactionally if legacy data lacks it, never a `-1` no-op.

Checkout (`CheckoutService.pay()` / `confirmBankTransfer()`): `finalizeLocked()` always locks `ActualEndAt` + computes segment pricing regardless of payment state (finalize ≠ settle); split-bill check always runs before settling; `completeBookingAndReleaseCourtIfNeeded()` always runs after finalize+settle are both satisfied — including when the invoice was *already* paid (e.g. cash collected at check-in) — so the booking/court are never left stuck in `Đang sử dụng`. `remainingAmount`/`depositAmount` now surface consistently in the JSON responses (`/staff/checkin` `processPayment`/`stopOpenSession` actions).

## 9. Fixed/open-ended flow

Fixed-duration: check-in locks `GioBatDau`/`GioKetThuc` window; checkout `finalizeLocked` charges the planned window plus any post-10-minute-grace overtime segment. Open-ended: `finalizeLocked`'s `OPEN_ENDED` branch computes the actual elapsed segment from `ActualStartAt` to now (min 15 minutes). Both paths share the same `CourtPricingService`/`finalizeLocked` code — no separate pricing logic was touched this pass (P1 backlog covers unifying the *other* ad-hoc pricing blocks in `DatSanServlet`/`CheckInServlet`'s walk-in/live-billing code, which still don't use `CourtPricingService`).

## 10. Services MAIN/SPLIT/preorder flow

**Not touched this pass** (P1 scope: preorder inventory lifecycle, "Đã giao" → `ChiTietHoaDon`/stock linkage, block-edit-on-paid-invoice). The one change made here: `CheckoutService.assertNoUnpaidSplitBills()` now correctly excludes `TrangThaiThanhToan = N'Đã hủy'` SPLIT bills from the checkout block (previously a legitimately-cancelled split bill would have wrongly blocked checkout forever).

## 11. Build command and result

```
mvn -q -o compile          # exit 0, no errors
mvn -q -o test-compile     # exit 0, no errors (whole src/test tree, including pre-existing DB-utility scripts)
mvn -q -o package -DskipTests   # exit 0, target/Backend_java-1.0-SNAPSHOT.war produced (42MB)
```

## 12. Test command and result

**Executed in this session** (pure logic, no DB, safe to run anywhere):

```
mvn -q -o test -Dtest=PaymentCalculatorTest,NoShowEligibilityTest,CheckInWindowTest,PayOSLegacyBookingFinalizationServiceTest
```

Result: **24/24 passed, 0 failures, 0 errors** —
`PaymentCalculatorTest` (7), `NoShowEligibilityTest` (6), `CheckInWindowTest` (6), `PayOSLegacyBookingFinalizationServiceTest` (5, tests the pure `classifyStatus()` decision table extracted from the webhook finalizer).

**Created but NOT executed / not automatable in this session:**

- No integration tests were written against `CheckoutService`, `PayOSLegacyBookingFinalizationService`, or `CheckInDAO`'s transactional methods (locking, unique-index enforcement, concurrent double-click, webhook-retry-creates-exactly-one-invoice). **Reason discovered mid-session:** `DBUtil` is a hardcoded static singleton bound to `DB_URL` (the `.env` value) with no dependency-injection seam — there is no way to point these classes at a separate `TEST_DB_URL` without a `DBUtil` refactor. Writing a "TEST_DB_URL-gated" test here would be misleading: the moment that test instantiates `CheckoutService`, it silently connects through `DBUtil`/`DB_URL`, i.e. the real remote DB — exactly what was ruled out for this session. I chose not to write that test rather than write something unsafe.
- All 40 test scenarios listed in the original request that require a live SQL Server (locking, concurrency, `UPDLOCK`/`ROWLOCK` behavior, unique filtered index, real transaction isolation) are **not automated**. They map to the manual checklist in §13.
- No Playwright/E2E suite exists in this repo and none was added — per your instruction, automated tests were kept to what doesn't touch the remote DB.

## 13. Windows manual verification checklist (run via `.\start_server.bat`)

Run `sql/verify_p0_prerequisites.sql` first (read-only) and confirm all "OK".

**PayOS (P0-2):**
1. Create a customer booking with PayOS payment, complete payment in the PayOS sandbox/real flow → confirm exactly one `HoaDon` row (`LoaiHoaDon='MAIN'`) is created, `TrangThaiThanhToan='Đã thanh toán'`, `LichDatSan.PaymentMethodConfirmed='PayOS'`, `ConfirmedAt` set, `TrangThai='Đã xác nhận'`.
2. Manually replay the same webhook payload (or trigger PayOS's own retry) → confirm no second `HoaDon` row is created and no error.
3. Let a `Chờ thanh toán` booking's `HoldExpiresAt` pass (or set it in the past via SSMS on a test row) so the scheduler flips it to `Quá hạn`, then send a valid webhook for that `DatSanID` → confirm it still transitions to `Đã xác nhận` with a correct invoice (does not stay `Quá hạn` while holding paid money).

**Checkout completes even when pre-paid (P0-3):**
4. Check in a pre-booked, already-PayOS-paid booking with `daThuTienMat` not applicable (already paid) → confirm `LichDatSan.TrangThai='Đang sử dụng'`.
5. Immediately click checkout ("Thanh toán") → confirm the booking becomes `Đã hoàn thành` and the court becomes `Sẵn sàng` (this was the exact P0-3 bug — previously it silently did nothing).
6. Reload/double-click checkout on an already-completed booking → confirm no error, no double charge, no duplicate invoice.

**Split bill (P0-5):**
7. Create a SPLIT invoice for a booking, leave it unpaid, attempt checkout via cash (`pay()`) and via bank transfer (`confirmBankTransfer()`) → both must block with "Còn hóa đơn SPLIT chưa thanh toán."
8. Cancel that SPLIT bill (`TrangThaiThanhToan='Đã hủy'`) → checkout must now succeed.

**No-show (P0-6):**
9. As a staff account at Facility A, attempt `cancelNoShow` on a booking belonging to Facility B → expect HTTP 403.
10. Attempt no-show before `NO_SHOW_GRACE_MINUTES` has elapsed past the booking's start time → expect a rejection message, not a state change.
11. Attempt no-show after the grace period on a `Đã xác nhận` (not yet checked-in) booking → confirm status becomes `Không đến` (not `Đã hủy`), `NoShowAt` is set.
12. Repeat on a booking that has already paid a deposit → confirm the invoice's `TrangThaiThanhToan` is **not** silently flipped to `Đã hủy`; confirm its `GhiChu` gets the "cần xử lý hoàn tiền/giữ cọc thủ công" note instead.

**Check-in window (P0-7):**
13. Attempt check-in more than 30 minutes before the booking's start time → expect rejection.
14. Attempt check-in more than `NO_SHOW_GRACE_MINUTES` after start time → expect rejection (booking should instead go through no-show).
15. Attempt check-in on a `Chờ xác nhận` (unapproved) booking → expect rejection (previously this was allowed).
16. Find/construct a legacy booking with no `HoaDon` row, check it in with "đã thu tiền mặt" checked → confirm a real MAIN invoice is created and printable (not a phantom `-1`).

**Scheduler (P0-1):**
17. Start the server, open a booking to `Đang sử dụng`, wait past its `GioKetThuc`, then just browse to the check-in dashboard (a page that used to trigger the auto-complete side effect) → confirm the booking is **still** `Đang sử dụng` and the court is **still** occupied (it must NOT auto-complete). Only an explicit checkout should complete it.
18. Confirm the server log shows `BookingSchedulerListener: scheduler khởi động, chu kỳ 60s.` on startup and `BookingSchedulerListener: scheduler đã dừng.` on shutdown.

## 14. Remaining risks / explicitly deferred

- **P1 backlog, not started:** `CourtPricingService` adoption in `DatSanServlet` booking creation, walk-in open-session pricing, and live "Đang sử dụng" billing (all three still use ad-hoc single-rate `double` math and will misprice a session that crosses the lighting boundary); `San.TrangThai='Đang sử dụng'` incorrectly blocking *future* bookings of that same court; preorder service inventory lifecycle (stock reservation/refund, "Đã giao" → `ChiTietHoaDon`/stock linkage, currently a preorder can be marked delivered without billing or stock deduction); duplicate-`SanPhamID` line merging (currently safe under a single call due to row locking, but not deduplicated, so `ChiTietHoaDon` can carry cosmetic duplicate lines); blocking service edits on an already-paid MAIN invoice (currently unguarded — `updateDichVuDatSan` can still mutate a paid invoice's totals); daily booking limit still counting `Quá hạn`/`Không đến` bookings toward the 3/day cap.
- **No DB-level integration test coverage** for any of the P0 transactional logic (locking, idempotent invoice creation under concurrency, unique-index enforcement) — see §12 for why, and §13 for the manual substitute. If you want this automated, the prerequisite is making `DBUtil`'s data source configurable/injectable (a small, contained refactor) so tests can point at a real disposable `TEST_DB_URL` SQL Server instance without any risk of touching `14.225.217.109`.
- **No Playwright/E2E** exists in this repo; none was added.
- **Cross-instance scheduler locking** was deliberately not implemented (`sp_getapplock` etc.) — `scheduleWithFixedDelay` fully covers the actual single-Tomcat-instance deployment (`start_server.bat`). If this ever runs as multiple instances behind a load balancer, add a DB-level lock before relying on the scheduler.
- **Automatic no-show sweep**: the scheduler intentionally does *not* auto-transition bookings to `Không đến` (only the manual staff action does, per P0-6's requirement that a human decide refund/keep-deposit policy). `Constants.NO_SHOW_AUTO_MODE = false` already exists in the codebase as the intended kill switch for this; no auto-sweep was wired to it this pass — if you want automatic no-show later, build it on the same `NoShowEligibility`/audit-log pattern established here.
- **PayOS "Đã cọc" (partial deposit) branch** in `PayOSLegacyBookingFinalizationService` is currently unreachable in practice — `DatSanServlet` only ever creates a PayOS checkout session for the full amount, never a partial deposit — so every legacy-flow confirmation ends up "Đã thanh toán." The branch is implemented correctly and ready if partial-deposit PayOS booking is added later.
- **Duplicate MAIN invoices in existing data**: `sql/verify_p0_prerequisites.sql` §5 will surface any pre-existing duplicates; the unique index self-skips creation if any exist. This must be resolved manually (which record is authoritative is a business decision) before the "one MAIN invoice per booking" invariant this code relies on is actually enforced at the DB level.

## Invariant checklist (per your requirement — do not claim completion without checking these)

- ✅ Không double booking — unchanged, existing overlap+lock logic in `DatSanServlet` untouched this pass.
- ✅ Không thu tiền hai lần — `pay()`/`confirmBankTransfer()` guard `TrangThaiThanhToan<>N'Đã thanh toán'` on every settle UPDATE; `completeBookingAndReleaseCourtIfNeeded` is idempotent (0-row no-op, not an error).
- ✅ Không checkout thiếu tiền — split-bill block now enforced in both `pay()` and `confirmBankTransfer()`.
- ✅ Không mất tiền cọc — `DepositAmount`/`remainingAmount` now flow through `CheckoutResult` consistently; PayOS webhook now records `DepositAmount` instead of discarding it.
- ⚠️ Không có MAIN invoice trùng — enforced by the pre-existing filtered unique index **only if** no duplicates already exist in data (see §14, verify via `sql/verify_p0_prerequisites.sql` §5) and **only if** that migration has actually run (verify §4 of the same script). Application code now always checks-before-insert, closing the main gap, but I cannot guarantee the DB-level constraint is actually active without you running the verify script.
- ⚠️ Không có tồn kho âm — not touched this pass (P1 scope); existing `updateDichVuDatSan` locking appeared safe within a single call per the audit, not independently re-verified here.
- ✅ Không tự hoàn thành ca khi tải trang — root cause removed (P0-1).
- ✅ Không giải phóng sân trước khi checkout hoàn tất — `completeBookingAndReleaseCourtIfNeeded` only runs after finalize+settle both hold.
- ✅ Không thao tác booking khác cơ sở — facility checks added to `checkInKhachDatTruoc`/`huyLichKhachBung`, returning `SecurityException`→403.
- ⚠️ Mỗi booking kết thúc đều có invoice hợp lệ và có thể in lại — true for every path touched this pass (PayOS legacy, check-in, checkout); not independently re-verified for paths outside P0 scope (e.g. manager-approval COD invoice creation, walk-in).
