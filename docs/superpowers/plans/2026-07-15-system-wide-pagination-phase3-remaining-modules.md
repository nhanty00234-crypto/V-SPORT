# System-Wide Pagination — Phase 3: Remaining Modules Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.
>
> **Prerequisite:** Phase 1 (foundation) and Phase 2 (priority modules) complete, merged, green build. Task 5 below (Thùng Rác) directly reuses the `getDeletedAccountsByCoSoAndRoleNotInPaged`-style DAO method shape and the `paramName`/`pageSizeParamName` tag extension built in Phase 2 Task 4/5b — read those two tasks first if executing Phase 3 standalone.
>
> **Re-verify before executing:** this plan was authored from the same audit pass as Phase 1/2 without re-reading every JSP byte-for-byte (Phase 2 already consumed the reasoning budget for full-file reads). Before editing any file below, re-run the relevant `grep -n` shown in each task to confirm line numbers/method names still match — do not blindly trust a line number if the file has since changed.

**Goal:** Finish the audit's remaining pagination targets (branch/facility grid, trash bins, shift-schedule audit trail, staff leave-request history) and close out the project with the required test report.

**Architecture:** Same `PaginationRequest`/`PageResult`/`PaginationUtils`/`<v:pagination>` framework as Phase 1/2. No new infrastructure needed except where noted.

## Global Constraints

Identical to Phase 2's Global Constraints section (stable `ORDER BY`, matching count/data `WHERE`, CoSoID never weakened, `sortBy` whitelist-only, no payment/booking/pricing changes, default page=1/pageSize=20 unless stated). Additionally:

- **`CaLamViec` main shift-schedule list is explicitly NOT paginated with page/pageSize in this phase** — see Task 3's reasoning. It gets a date-range bound instead, matching the pattern already used by `CaLamViecDAOImpl.getCaByAccountIDAndDateRange` on the staff side. Applying `OFFSET/FETCH` to a calendar-grid UI would silently truncate the visible week/month, which is a functional regression, not a performance fix — the parent spec's own Section III explicitly says only paginate lists "có khả năng tăng dài" in a *list* sense; a calendar view has a different scaling axis (date range, not row count).

---

## Out-of-scope / deferred items found during audit — DO NOT act on these in this plan, listed here so they aren't rediscovered as "missed" work

1. **`QuanLySanServlet` / `/admin/quan-ly-san` has been removed.** Court management is Manager-only via `/manager/quan-ly-san` (`QuanLySanManagerServlet` + `manager/QuanLySan.jsp`). Do not reintroduce an admin duplicate route.
2. **"Duyệt đặt sân" (booking approval), as a distinct Manager feature, does not exist in this codebase.** No servlet/JSP matches that description. The closest real features are `HoaDonManagerServlet` (invoice management, paginated in Phase 2) and `CheckInServlet`/`BookingServiceStaffServlet` (staff check-in, confirmed bounded/daily, no pagination needed). Do not invent a servlet to satisfy the parent spec's assumed module list.
3. **`LichDatSanDAO.getAllLichDatSan()` has no `CoSoID` or date filter** (loads every booking system-wide to build the customer-facing conflict timetable in `DatSanServlet`). This is a booking-logic/performance concern, not a pagination target (the data feeds a JS timetable render, not a paged list) — fixing it would mean touching booking-conflict logic, explicitly out of scope per the parent task's "không thay đổi nghiệp vụ đặt sân" constraint. Report only.
4. **Dead code:** `DatSanServlet.loadHistoryPage()` and `src/main/webapp/customer/LichSuDatSan.jsp` are unreachable (the `/customer/lich-su-dat-san` route redirects elsewhere). `QuanLyNguoiDungServlet`'s `caLamViecDAO.getAllCaLamViec()` call was already deleted in Phase 2 Task 5a. Report the `LichSuDatSan.jsp` dead code; do not delete it as part of this pagination project (out of scope, separate cleanup).
5. **`ThongBaoDAO` (notifications) has no customer-facing route at all** — only used internally by `CaLamService` for staff. Not a pagination target.
6. **`CaLamViecSwapRequestDAO.getByAccount` (staff's own swap-request history)** — unbounded in theory, confirmed low-volume/rare user action by audit. Not paginated in this phase; revisit if usage data later shows it growing.
7. **`AdminOwnerServlet`/`QuanLyChiNhanhServlet`'s `TaiKhoanDAOImpl.getAllAccounts()` calls** (used only to build an in-memory owner-name lookup map, not to render a paged list) — wasteful but not a pagination target; flag as a follow-up optimization (e.g. batch-fetch only the account IDs actually referenced) rather than fixing here.
8. **Manager's `NhanSuManagerServlet`/`CaLamViecSwapRequestDAOImpl.getByAccount` / availability list (`CaLamViecAvailabilityDAOImpl.getByCoSoAndDateRange`)** — already date-range-bounded (±30 days), confirmed not a pagination target.

---

## File Structure

- Modify: `src/main/java/org/example/dao/CoSoDAO.java`, `src/main/java/org/example/dao/impl/CoSoDAOImpl.java` (Task 1)
- Modify: `src/main/java/org/example/controller/admin/QuanLyChiNhanhServlet.java`, `src/main/webapp/admin/QuanLyChiNhanh.jsp` (Task 1)
- Modify: `src/main/java/org/example/dao/AdminTrashDAO.java`, `src/main/java/org/example/dao/impl/AdminTrashDAOImpl.java` (Task 2)
- Modify: `src/main/java/org/example/controller/admin/AdminTrashServlet.java`, `src/main/webapp/admin/ThungRacAdmin.jsp` (Task 2)
- Modify: `src/main/java/org/example/dao/CaLamViecAuditDAO.java`, `src/main/java/org/example/dao/impl/CaLamViecAuditDAOImpl.java` (Task 3)
- Modify: `src/main/java/org/example/dao/CaLamViecDAO.java`, `src/main/java/org/example/dao/impl/CaLamViecDAOImpl.java` (Task 3, date-range bound not page pagination)
- Modify: `src/main/java/org/example/service/manager/CaLamService.java`, `src/main/java/org/example/controller/manager/QuanLyCaLamManagerServlet.java`, `src/main/webapp/manager/CaLamViec.jsp` (Task 3)
- Modify: `src/main/java/org/example/dao/SanDAO.java`, `.../LoaiSanDAO.java`, `.../SanPhamDichVuDAO.java` + impls (Task 4, deleted-item paginated variants)
- Modify: `src/main/java/org/example/controller/manager/ThungRacManagerServlet.java`, `src/main/webapp/manager/ThungRac.jsp` (Task 4)
- Modify: `src/main/java/org/example/dao/YeuCauNghiDAO.java`, `src/main/java/org/example/dao/impl/YeuCauNghiDAOImpl.java` (Task 5)
- Modify: `src/main/java/org/example/service/YeuCauNghiService.java`, `src/main/java/org/example/controller/staff/YeuCauNghiStaffServlet.java`, `src/main/webapp/staff/yeuCauNghi_my.jsp` (Task 5)
- Create: `tests/e2e/pagination.spec.js`, `docs/test-reports/screenshots/*.png` (Task 6)
- Create: `docs/test-reports/system-wide-pagination-report.md` (Task 7)

---

### Task 1: Branch/facility grid — `QuanLyChiNhanhServlet` / `QuanLyChiNhanh.jsp`

**Context:** `CoSoDAO.getAllCoSo()` (`CoSoDAOImpl.java:20-33`) has no `ORDER BY`, no limit, and is called from many places (`grep -rn "getAllCoSo()" src/main/java` before touching its signature — audit found call sites in `QuanLyChiNhanhServlet`, `AdminOwnerServlet`, `CaLamService.getAllCoSo`, and likely dropdown-population code elsewhere). **Add a new paginated sibling method; do not change `getAllCoSo()`'s signature or behavior.**

- [ ] **Step 1: Add DAO methods**

```java
    // CoSoDAO.java
    long countAllCoSo();
    List<CoSo> getAllCoSoPaged(long offset, int limit);
```

```java
    // CoSoDAOImpl.java
    @Override
    public long countAllCoSo() {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery(
                    "SELECT COUNT(c) FROM CoSo c WHERE isDeleted = false OR isDeleted IS NULL", Long.class)
                    .getSingleResult();
        } finally {
            em.close();
        }
    }

    @Override
    public List<CoSo> getAllCoSoPaged(long offset, int limit) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery(
                    "SELECT c FROM CoSo c WHERE (isDeleted = false OR isDeleted IS NULL) " +
                    "AND TrangThai NOT IN ('Chờ duyệt','Từ chối') ORDER BY c.tenCoSo ASC, c.coSoId ASC", CoSo.class)
                    .setFirstResult((int) offset)
                    .setMaxResults(limit)
                    .getResultList();
        } finally {
            em.close();
        }
    }
```

Confirm the exact JPQL field names (`c.tenCoSo`, `c.coSoId`, `TrangThai`) via `grep -n "private\|@Column" src/main/java/org/example/model/CoSo.java` before finalizing — copy `getAllCoSo()`'s existing JPQL (`CoSoDAOImpl.java:20-33`) verbatim for the `WHERE`/status-exclusion clause so the paginated list shows exactly the same set of branches the unpaginated one does, just windowed.

- [ ] **Step 2: Wire into `QuanLyChiNhanhServlet`**

At the main-list branch of `doGet` (line ~102-106 per audit), replace `List<CoSo> dsChiNhanh = coSoDAO.getAllCoSo();` with the standard pattern (see Phase 2 Task 1/6 for the exact shape): `PaginationUtils.fromRequest(req)` → `countAllCoSo()` → clamp → `getAllCoSoPaged(offset, pageSize)` → `PageResult.of(...)` → `req.setAttribute("branchPage", branchPage)`. Keep the existing `PayOSConfigDAOImpl.findStatusForAllCoSo()` call and its `Map<Integer,PayOSConfigState>` attribute untouched (it's a lookup map keyed by CoSoID, not a rendered list — it'll just have entries for branches outside the current page, which is harmless since the JSP only looks up entries for the branches it actually renders).

- [ ] **Step 3: Update `QuanLyChiNhanh.jsp`**

Change the main grid `c:forEach items="${dsChiNhanh}"` (line ~144) to `items="${branchPage.items}"`. Leave the separate quick-stat loop (line ~126, counts active branches) alone **unless** it was computing its count from the same in-memory list that's now only a partial page — check `grep -n "dsChiNhanh" src/main/webapp/admin/QuanLyChiNhanh.jsp`; if the quick-stat count uses `fn:length(dsChiNhanh)` or similar over the (now paginated) list, replace it with a new `activeBranchCount` request attribute computed via a `COUNT` query in the servlet instead, mirroring Phase 2 Task 6's "KPIs must reflect the full filtered set, not the current page" rule. Add `<v:pagination pageResult="${branchPage}" baseUrl="/admin/chi-nhanh" ariaLabel="Phân trang chi nhánh" />` after the grid.

- [ ] **Step 4: Compile, verify, commit**

`mvn -q compile` → BUILD SUCCESS. Manually verify with ≥21 branches (seed test branches if the current DB has fewer — do not delete real branch data to test). Commit:

```bash
git add src/main/java/org/example/dao/CoSoDAO.java src/main/java/org/example/dao/impl/CoSoDAOImpl.java src/main/java/org/example/controller/admin/QuanLyChiNhanhServlet.java src/main/webapp/admin/QuanLyChiNhanh.jsp
git commit -m "feat: paginate admin branch/facility grid"
```

---

### Task 2: Admin trash bin — `AdminTrashServlet` / `ThungRacAdmin.jsp`

**Context:** `AdminTrashDAO.search(entityType, restoredFilter, deletedBy)` (`AdminTrashDAOImpl.java:54-87`) already has `ORDER BY t.DeletedAt DESC` and filter params — just needs a stable tiebreak + `OFFSET/FETCH` + a matching `COUNT` query. This is a raw-JDBC DAO (like `HoaDonManagerServlet`), so follow the same pattern as Phase 2 Task 1.

- [ ] **Step 1: Confirm the trash table's PK column name**

Run: `grep -n "TrashID\|AdminTrashID\|\bId\b" sql/*.sql src/main/java/org/example/dao/impl/AdminTrashDAOImpl.java` (or inspect the `SELECT t.*` mapping code in the same file) to get the real PK column — do not guess between `TrashID`/`Id`/`AdminTrashID`.

- [ ] **Step 2: Add `countSearch` + `OFFSET/FETCH` to `search`**

In `AdminTrashDAOImpl.java`, add a `countSearch(entityType, restoredFilter, deletedBy)` method that reuses the exact same dynamic `WHERE` builder as `search()` (extract the shared `WHERE`-building code into a small private helper both methods call, rather than copy-pasting the `if` chain twice — this is the DRY requirement from the parent spec applied at DAO-internal granularity). Add `OFFSET ? ROWS FETCH NEXT ? ROWS ONLY` to `search()`'s SQL with `ORDER BY t.DeletedAt DESC, t.<PK> DESC` (substitute the real PK column found in Step 1), taking two new `long offset, int limit` parameters.

- [ ] **Step 3: Wire into `AdminTrashServlet`**

At the `doGet`'s list branch (line ~45-60 per audit), add `PaginationUtils.fromRequest(req)` → `countSearch(...)` → clamp → `search(..., offset, limit)` → `PageResult.of(...)` → `req.setAttribute("trashPage", ...)`, replacing the current single `items` attribute. Build a `paginationExtraParams` map from the existing `loai`/`thuhoi`/`scope` filter params (lines ~93-119 in the JSP per audit — confirm exact param names via `grep -n 'name="' src/main/webapp/admin/ThungRacAdmin.jsp` first).

- [ ] **Step 4: Update `ThungRacAdmin.jsp`**

`c:forEach items="${items}"` (line ~170) → `items="${trashPage.items}"`. Add `<v:pagination pageResult="${trashPage}" baseUrl="/admin/thung-rac" extraParams="${paginationExtraParams}" ariaLabel="Phân trang thùng rác" />` after the table.

- [ ] **Step 5: Compile, verify (include Test matrix item 14 — soft-delete count correctness), commit**

```bash
git add src/main/java/org/example/dao/AdminTrashDAO.java src/main/java/org/example/dao/impl/AdminTrashDAOImpl.java src/main/java/org/example/controller/admin/AdminTrashServlet.java src/main/webapp/admin/ThungRacAdmin.jsp
git commit -m "feat: paginate admin trash bin list"
```

---

### Task 3: Shift schedule — `QuanLyCaLamManagerServlet` / `CaLamViec.jsp`

Two independent sub-targets with **different** fixes — do not apply pagination to both the same way.

**3a. Shift audit trail (`CaLamViecAuditDAOImpl.getByCoSo`) — real page/pageSize pagination, it's a flat audit-trail list.**

- [ ] **Step 1:** Add `countByCoSo(coSoId)` + change `getByCoSo` to accept `(coSoId, offset, limit)` — check call sites first (`grep -rn "getByCoSo" src/main/java/org/example/dao/impl/CaLamViecAuditDAOImpl.java src/main/java/org/example/service/manager/CaLamService.java` — if `CaLamService.getAuditLogs` is the only caller, per audit it is, it's safe to change the DAO signature directly here rather than adding a sibling, since this is an internal single-caller chain). Add stable tiebreak: `ORDER BY au.ThoiGian DESC, au.<PK> DESC` (confirm the audit table's PK column name the same way as Task 2 Step 1).
- [ ] **Step 2:** Thread `PaginationRequest`/`PageResult` through `CaLamService.getAuditLogs` → `QuanLyCaLamManagerServlet`'s `?format=json` branch (audit found this at lines 71-84, `getAuditLogs` call at line 74) — since this section is JSON-driven (like Phase 2 Task 5b), return the same `{items,page,pageSize,totalItems,totalPages,hasPrevious,hasNext,fromItem,toItem}` envelope shape and reuse `renderPaginationFooter` from `assets/js/pagination-footer.js` (built in Phase 2 Task 5b) in `CaLamViec.jsp`'s audit-tab rendering code — do not write a second JS pagination renderer.
- [ ] **Step 3:** Compile, verify, commit separately from 3b:

```bash
git add src/main/java/org/example/dao/CaLamViecAuditDAO.java src/main/java/org/example/dao/impl/CaLamViecAuditDAOImpl.java src/main/java/org/example/service/manager/CaLamService.java src/main/java/org/example/controller/manager/QuanLyCaLamManagerServlet.java src/main/webapp/manager/CaLamViec.jsp
git commit -m "feat: paginate shift-schedule audit trail (AJAX, reuses pagination-footer.js)"
```

**3b. Main shift list (`CaLamViecDAOImpl.getCaByCoSo`) — date-range bound, NOT page/pageSize pagination.**

This is a calendar/scheduling grid, not a flat list — the parent audit found `getCaByCoSo` fetches every shift ever created for the branch with no bound at all (`SELECT * FROM CaLamViec WHERE CoSoID=? AND IsDeleted=0`, no `ORDER BY`, no limit). The correct fix mirrors the already-working staff-side pattern (`getCaByAccountIDAndDateRange`, ±4/+8 weeks): bound by the calendar's visible date range instead of row count.

- [ ] **Step 1:** Add `getCaByCoSoAndDateRange(coSoId, startDate, endDate)` to `CaLamViecDAO`/`CaLamViecDAOImpl`, copying `getCaByCoSo`'s exact SQL shape but adding `AND NgayLam BETWEEN ? AND ?` and `ORDER BY NgayLam ASC, GioBatDau ASC, <PK> ASC`. Keep `getCaByCoSo` itself unchanged if anything besides `CaLamService.getShiftsByBranch` calls it (`grep -rn "getCaByCoSo\b" src/main/java` first — if it's single-caller, change it in place instead of adding a sibling, same reasoning as 3a Step 1).
- [ ] **Step 2:** In `CaLamService.getShiftsByBranch` / `QuanLyCaLamManagerServlet`, read a `weekStart`/`weekEnd` (or however the existing calendar JS already tracks its visible range — check `CaLamViec.jsp` for existing date-navigation JS state, likely already sends a week/month parameter for other date-scoped calls like `getAvailabilityByBranch`) and pass it through to `getCaByCoSoAndDateRange` instead of loading the branch's entire shift history. This bounds the query by weeks-on-screen (small, fast) rather than by an arbitrary page size that wouldn't make sense for a calendar layout.
- [ ] **Step 3:** Compile, manually verify the calendar still renders the correct shifts for the visible week/month and that navigating to a different week correctly re-queries (not just re-filters an in-memory blob), commit:

```bash
git add src/main/java/org/example/dao/CaLamViecDAO.java src/main/java/org/example/dao/impl/CaLamViecDAOImpl.java src/main/java/org/example/service/manager/CaLamService.java src/main/java/org/example/controller/manager/QuanLyCaLamManagerServlet.java
git commit -m "fix: bound shift-schedule calendar query by visible date range instead of loading full history"
```

---

### Task 4: Manager trash bin — `ThungRacManagerServlet` / `ThungRac.jsp`

**Context:** Four independent deleted-item lists on one page (San, LoaiSan, SanPham_DichVu, deleted staff) — same multi-list-per-page shape as Phase 2 Task 4 (Khách hàng). Reuse the `paramName`/`pageSizeParamName` tag extension and the `PaginationUtils.fromRequest(request, defaultPageSize, prefix)` overload, both built in Phase 2 — do not reintroduce them.

- [ ] **Step 1:** Add `countDeletedByCoSo(coSoId)` + `findDeletedByCoSoPaged(coSoId, offset, limit)` to `SanDAO`, `LoaiSanDAO`, and `SanPhamDichVuDAO` (three separate DAOs, same shape each time — copy `findDeletedByCoSo`'s existing JPQL exactly, add `ORDER BY <entity's natural name/title field> ASC, <PK> ASC` since none of the three currently have any `ORDER BY` per audit, plus `setFirstResult`/`setMaxResults`).
- [ ] **Step 2:** For the deleted-staff list, reuse `TaiKhoanDAO.getDeletedAccountsByCoSoAndRoleNotInPaged`/`countDeletedAccountsByCoSoAndRoleNotIn` — **already built in Phase 2 Task 5b**, do not duplicate.
- [ ] **Step 3:** In `ThungRacManagerServlet.doGet` (lines ~34-55 per audit), build 4 independent `PaginationRequest`s with prefixes `"san"`, `"loaiSan"`, `"product"`, `"staff"`, run count+paged for each, build 4 `PageResult`s, set 4 request attributes (`sanPage`, `loaiSanPage`, `productPage`, `staffPage`).
- [ ] **Step 4:** In `ThungRac.jsp`, update the 4 `c:forEach` blocks (deletedSans line ~93-109, deletedLoaiSans ~139-157, deletedProducts ~188-205, deletedStaff ~236-251 per audit) to iterate the 4 `PageResult.items`, and add 4 `<v:pagination>` calls with matching `paramName`/`pageSizeParamName` pairs (`sanPage`/`sanPageSize`, etc.), following Phase 2 Task 4's sibling-params pattern so paginating one list doesn't reset the other three.
- [ ] **Step 5:** Compile, verify (Test matrix item 14 — soft-delete count correctness — across all 4 lists), commit:

```bash
git add src/main/java/org/example/dao/SanDAO.java src/main/java/org/example/dao/impl/SanDAOImpl.java src/main/java/org/example/dao/LoaiSanDAO.java src/main/java/org/example/dao/impl/LoaiSanDAOImpl.java src/main/java/org/example/dao/SanPhamDichVuDAO.java src/main/java/org/example/dao/impl/SanPhamDichVuDAOImpl.java src/main/java/org/example/controller/manager/ThungRacManagerServlet.java src/main/webapp/manager/ThungRac.jsp
git commit -m "feat: paginate manager trash bin (4 independent lists)"
```

---

### Task 5: Staff leave-request history — `YeuCauNghiStaffServlet` / `yeuCauNghi_my.jsp`

**Context:** `YeuCauNghiDAO.findByAccountID`/`findByAccountIDAndTrangThai` (native SQL over view `V_YeuCauNghi_ChiTiet`) already have `ORDER BY` and an `AccountID` security filter, just need a stable tiebreak, count, and `OFFSET/FETCH`. Existing status-filter tabs (`?status=ChoDuyet` etc., `YeuCauNghiStaffServlet.java` lines ~76-78 per audit) must keep working with pagination composed on top.

- [ ] **Step 1:** Confirm the view's request-ID column name (`grep -n "YeuCauNghiID\|RequestID" sql/*.sql` or the DAO's row-mapping code) — do not guess.
- [ ] **Step 2:** Add `countByAccountID(accountId)`/`countByAccountIDAndTrangThai(accountId, status)` and paginated variants of `findByAccountID`/`findByAccountIDAndTrangThai`, adding `, <PK column> DESC` to each existing `ORDER BY` and `OFFSET ? ROWS FETCH NEXT ? ROWS ONLY`.
- [ ] **Step 3:** Wire into `YeuCauNghiStaffServlet.doGet` (lines ~63-67 per audit) using the standard `PaginationUtils.fromRequest` → count → clamp → paged-find → `PageResult.of` → `req.setAttribute("requestPage", ...)` pattern, preserving the existing `status` tab param in a `paginationExtraParams` map.
- [ ] **Step 4:** Update `yeuCauNghi_my.jsp` — `c:forEach items="${requests}"` (line ~98) → `items="${requestPage.items}"`, insert `<v:pagination pageResult="${requestPage}" baseUrl="/staff/yeu-cau-nghi" extraParams="${paginationExtraParams}" ariaLabel="Phân trang lịch sử xin nghỉ" />` after the table, leave the existing status tabs (lines ~76-78) untouched.
- [ ] **Step 5:** Compile, verify, commit:

```bash
git add src/main/java/org/example/dao/YeuCauNghiDAO.java src/main/java/org/example/dao/impl/YeuCauNghiDAOImpl.java src/main/java/org/example/controller/staff/YeuCauNghiStaffServlet.java src/main/webapp/staff/yeuCauNghi_my.jsp
git commit -m "feat: paginate staff leave-request history"
```

---

### Task 6: Playwright E2E coverage for the 5 required modules

**Context:** `playwright` is already a project dependency (`package.json`) — confirmed installed under `node_modules/playwright`. No new tooling to add, only test specs. Parent spec Section XXIII requires E2E coverage for: Quản lý hóa đơn, Lịch đặt sân, Audit log, Khách hàng, Kho dịch vụ. Map these to the modules actually built: `HoaDonManagerServlet` (Phase 2 Task 1), `DatSanServlet` customer booking history (Phase 2 Task 2 — this is the closest real "lịch đặt sân" list in the codebase per the Task 5/Out-of-scope item 2 finding above), `AuditLogManagerServlet` (Phase 2 Task 3), `CustomerManagerServlet` (Phase 2 Task 4), `KhoDichVuManagerServlet` (Phase 2 Task 6).

**Do not use a real team member's login.** Check `src/test/java/org/example/FindTestAccountsTest.java` (an existing ad-hoc script noted during audit) for how to locate or seed dedicated E2E test accounts before writing any spec that logs in.

- [ ] **Step 1:** Create `tests/e2e/pagination.spec.js` (or match whatever test directory convention `package.json`'s existing scripts imply — check for a `"test"`/`"e2e"` script in `package.json` first; there is none currently, so add one: `"test:e2e": "playwright test"`).
- [ ] **Step 2:** For each of the 5 modules, write one Playwright test following this exact 12-point sequence (per parent spec Section XXIII): open page → read `totalItems` from the footer text → click page 2 → assert at least one row's identifying cell differs from page 1 → click "‹ Trước" back to page 1 → perform a search/filter → click page 2 of the filtered result → change page size → reload the page → assert the URL still contains `page`/the filter params (state survived reload) → assert no `console.error` was emitted → take a screenshot. Example skeleton for the invoice module (write the other 4 analogously, substituting selectors/URLs):

```javascript
const { test, expect } = require('@playwright/test');

test('HoaDonManagerServlet pagination preserves filters and state', async ({ page }) => {
  const consoleErrors = [];
  page.on('console', msg => { if (msg.type() === 'error') consoleErrors.push(msg.text()); });

  await page.goto('/manager/hoa-don');
  const totalText = await page.locator('nav[aria-label="Phân trang hóa đơn"]').innerText();
  expect(totalText).toMatch(/trong \d+ kết quả/);

  const firstRowIdBefore = await page.locator('table tbody tr').first().getAttribute('data-hoa-don-id');
  await page.getByRole('link', { name: '2' }).click();
  const firstRowIdAfterPage2 = await page.locator('table tbody tr').first().getAttribute('data-hoa-don-id');
  expect(firstRowIdAfterPage2).not.toBe(firstRowIdBefore);

  await page.getByLabel('‹ Trước').click();
  await expect(page).toHaveURL(/page=1/);

  await page.fill('input[name="filterSearch"]', 'sân');
  await page.keyboard.press('Enter');
  await page.getByRole('link', { name: '2' }).click();
  await expect(page).toHaveURL(/filterSearch=s%C3%A2n/);

  await page.selectOption('#pageSizeSelect', '50');
  await expect(page).toHaveURL(/pageSize=50/);

  await page.reload();
  await expect(page).toHaveURL(/pageSize=50/);

  expect(consoleErrors).toEqual([]);
  await page.screenshot({ path: 'docs/test-reports/screenshots/hoa-don-pagination.png', fullPage: true });
});
```

(`data-hoa-don-id` on each table row is a new, harmless attribute this task adds to the JSP's `<tr>` specifically so the E2E test can assert row identity across pages — add the equivalent identifying `data-*` attribute for each of the other 4 modules' row/card elements too, e.g. `data-danh-gia-id` for `KhachHang.jsp`'s reviews rows.)

- [ ] **Step 3:** Run: `npx playwright test tests/e2e/pagination.spec.js` against a running local server (`.\start_server.bat` must be up first — Playwright here drives the real Tomcat-served app, not a mocked one). Expected: all 5 tests pass.
- [ ] **Step 4:** Save the 5 screenshots under `docs/test-reports/screenshots/` (create the directory) — referenced by the final report in Task 7.
- [ ] **Step 5:** Commit:

```bash
git add tests/e2e/pagination.spec.js package.json docs/test-reports/screenshots
git commit -m "test: add Playwright E2E coverage for the 5 required pagination modules"
```

---

### Task 7: Full-system verification + final report

- [ ] **Step 1:** `mvn test` → BUILD SUCCESS (all Phase 1/2/3 unit tests).
- [ ] **Step 2:** `mvn package` → BUILD SUCCESS.
- [ ] **Step 3:** `.\start_server.bat`, full manual pass (Test matrix items 1-17) through every module touched across Phase 2 and Phase 3 — do not skip any on the assumption an earlier similar module already proved the pattern works.
- [ ] **Step 4:** Confirm `git diff --stat main -- src/main/java/org/example/service/pricing src/main/java/org/example/service/checkout src/main/java/org/example/service/billing src/main/java/org/example/service/payos` is still empty (same check as Phase 2 Task 7 Step 4, re-run at the end of Phase 3 in case anything regressed).
- [ ] **Step 5:** Write `docs/test-reports/system-wide-pagination-report.md` covering all 16 items required by the parent task's Section XXV (module audit table, paginated vs. not-paginated-and-why, foundation classes, shared JSP/JS components, before/after query examples, index migrations if any were needed — none were identified as necessary during this audit since existing CoSoID/status/date columns already carry adequate selectivity for the row counts observed, but re-check actual `EXECUTE`-plan behavior on production-scale data before declaring this final — default page/pageSize, search/filter/sort preservation, CoSoID/security notes, responsive/accessibility notes, per-module results, performance before/after if measurable, full file list, and the Section III "Out-of-scope / deferred items" list from the top of this document verbatim).
- [ ] **Step 6:** Commit the report:

```bash
git add docs/test-reports/system-wide-pagination-report.md
git commit -m "docs: add system-wide pagination final report"
```
