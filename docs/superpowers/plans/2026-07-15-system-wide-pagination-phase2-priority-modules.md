# System-Wide Pagination — Phase 2: Priority Modules Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.
>
> **Prerequisite:** `2026-07-15-system-wide-pagination-phase1-foundation.md` must be complete and merged (green `mvn test`, `pagination.tag` verified in-browser) before starting any task here — every task below depends on `PaginationRequest`/`PageResult`/`PaginationUtils`/`WEB-INF/tags/pagination.tag`.

**Goal:** Retrofit real server-side pagination (DB → DAO → service/servlet → JSP) onto the six highest-priority list screens identified by the system-wide audit, without changing any booking/payment/pricing business logic.

**Architecture:** Each module gets a `count*`/`find*` DAO method pair (native SQL `OFFSET…FETCH` or JPQL `setFirstResult/setMaxResults`, whichever the existing DAO already uses — do not introduce a second data-access style into a DAO that doesn't have one), a servlet that parses params via `PaginationUtils.fromRequest`, and a JSP that renders `<v:pagination>` from a single `PageResult` request attribute. One module (Nhân sự) is AJAX/JSON-driven and already stable per audit — it keeps AJAX, but gets a small reusable vanilla-JS pagination-footer renderer instead of a copy-pasted one.

**Tech Stack:** Same as Phase 1, plus: JPA native queries (`em.createNativeQuery`, positional `?1,?2,...` params — see `CustomerBranchDAOImpl`), raw JDBC `PreparedStatement` (see `HoaDonManagerServlet`), vanilla JS (no framework).

## Global Constraints

- Every new/modified DAO query has an `ORDER BY` with a stable tiebreak column (never a bare timestamp/aggregate sort).
- Every count query mirrors its data query's `WHERE`/`GROUP BY`/`HAVING` exactly — same params, same order of AND-clauses conceptually (order in the SQL text doesn't matter, coverage does).
- Every CoSoID-scoped query keeps its existing `CoSoID = ?` (or JPQL `a.coSoId = :coSoId`) filter — this plan only *adds* `OFFSET/FETCH` or `setFirstResult/setMaxResults` + count, it never removes or weakens an ownership filter.
- `sortBy` is resolved through `PaginationUtils.resolveSortColumn(whitelist, requestedKey, defaultColumn)` — never concatenated raw into SQL.
- No task in this phase changes `TongThanhToan`/`TongTienSan`/`TongTienDichVu` computation, `TrangThaiThanhToan` transition logic, booking conflict detection, or pricing (`org.example.service.pricing.*`). Only `WHERE`/`ORDER BY`/`OFFSET`/`FETCH`/result-shaping code is touched.
- Default page = 1, default pageSize = 20 for every module here except none in this phase override the default (Audit Log's 50-default retrofit, if desired, is Phase 3/optional — audit log already works, this phase does not touch it).
- Multi-list-per-page convention (new in this phase, needed by Module 4 "Khách hàng" which renders 3 independently-paginated lists on one screen): each independently-paginated section uses a **prefixed** param pair instead of the bare `page`/`pageSize` — e.g. `reviewsPage`/`reviewsPageSize`, `riskPage`/`riskPageSize`. A page with exactly one list keeps the bare `page`/`pageSize` names. This is implemented by a new `PaginationUtils.fromRequest(request, defaultPageSize, String paramPrefix)` overload added in Module 4, Task 4a below (prefix `null`/`""` behaves exactly like the Phase 1 two-arg overload).
- Sorting UI scope cut: this phase wires `sortBy`/`sortDir` end-to-end on the backend (whitelist-resolved, safe to pass via URL) for every module below, but does **not** add clickable sort-column headers in the JSP — that's cosmetic polish, out of scope for the pagination correctness work and deferred to a follow-up. Only the Trash/Audit-log style default sort each module already has is preserved/stabilized.
- `<v:pagination>` has no dedicated `sortBy`/`sortDir` attributes — it preserves sort state only through the generic `extraParams` map, the same mechanism used for `q`/`status`/`dateFrom`/etc. Any module whose servlet reads a `sortBy`/`sortDir` request param (even without a clickable sort-header UI yet — e.g. a power user editing the URL by hand) **must** add both to its `paginationExtraParams` map before forwarding to the JSP, or the sort selection will silently reset to the module's default every time the user clicks a page number or changes page size. This was flagged in Phase 1's final whole-branch review (see `pagination.tag`'s own doc comment) — every Task below that builds a `paginationExtraParams`-style map must include `sortBy`/`sortDir` in it whenever the module's servlet accepts those params, not just the filter fields explicitly named in that task's Step.

---

## File Structure

- Modify: `src/main/java/org/example/util/PaginationUtils.java` — add `fromRequest(request, defaultPageSize, paramPrefix)` overload (Module 4).
- Modify: `src/main/java/org/example/controller/manager/HoaDonManagerServlet.java` (Module 1)
- Modify: `src/main/webapp/manager/QuanLyHoaDon.jsp` (Module 1)
- Modify: `src/main/java/org/example/controller/customer/DatSanServlet.java` (Module 2)
- Modify: `src/main/java/org/example/dao/LichDatSanDAO.java`, `src/main/java/org/example/dao/impl/LichDatSanDAOImpl.java` (Module 2)
- Modify: `src/main/webapp/customer/DatSan.jsp` (Module 2)
- Modify: `src/main/java/org/example/dao/CustomerBranchDAO.java`, `src/main/java/org/example/dao/impl/CustomerBranchDAOImpl.java` (Module 4)
- Modify: `src/main/java/org/example/controller/manager/CustomerManagerServlet.java` (Module 4)
- Modify: `src/main/webapp/manager/KhachHang.jsp` (Module 4)
- Modify: `src/main/java/org/example/dao/TaiKhoanDAO.java`, `src/main/java/org/example/dao/impl/TaiKhoanDAOImpl.java` (Module 5)
- Modify: `src/main/java/org/example/controller/admin/QuanLyNguoiDungServlet.java` (Module 5a)
- Modify: `src/main/webapp/admin/NhanSu.jsp` (Module 5a)
- Modify: `src/main/java/org/example/service/manager/NhanSuService.java` (Module 5b)
- Modify: `src/main/java/org/example/controller/manager/NhanSuManagerServlet.java` (Module 5b)
- Modify: `src/main/webapp/manager/NhanSu.jsp` (Module 5b)
- Create: `src/main/webapp/assets/js/pagination-footer.js` (shared AJAX pagination renderer, Module 5b — also reusable by Phase 3's CaLamViec swap-request list)
- Modify: `src/main/java/org/example/dao/SanPhamDichVuDAO.java`, `src/main/java/org/example/dao/impl/SanPhamDichVuDAOImpl.java` (Module 6)
- Modify: `src/main/java/org/example/controller/manager/KhoDichVuManagerServlet.java` (Module 6)
- Modify: `src/main/webapp/manager/KhoDichVu.jsp` (Module 6)

---

### Task 1 (Module 1): Invoice management — `HoaDonManagerServlet` / `QuanLyHoaDon.jsp`

**Context:** Already has hand-rolled `OFFSET...FETCH` pagination (`HoaDonManagerServlet.java:48-52,121-145`) — the best-established pattern in the codebase for raw-JDBC pagination. Retrofit onto the shared framework instead of rewriting the SQL from scratch: fix the missing stable tiebreak, replace manual `page`/`offset` parsing with `PaginationUtils`, replace the 4 scattered request attributes (`invoices`,`totalCount`,`totalPages`,`currentPage`) with one `invoicePage` attribute, and replace the JSP's raw-string-concatenation pager (`QuanLyHoaDon.jsp:236-249`, flagged during audit as URL-encoding-unsafe) with `<v:pagination>`.

**Files:**
- Modify: `src/main/java/org/example/controller/manager/HoaDonManagerServlet.java:1-199`
- Modify: `src/main/webapp/manager/QuanLyHoaDon.jsp` (forEach at line ~168-222, pager at lines ~236-249)

**Interfaces:**
- Consumes: `PaginationUtils.fromRequest(HttpServletRequest)`, `PaginationUtils.clampPage`, `PaginationUtils.resolveSortColumn`, `PageResult.of`.
- Produces: request attribute `invoicePage` of type `PageResult<Map<String,Object>>` (replaces `invoices`/`totalCount`/`totalPages`/`currentPage`); request attribute `paginationExtraParams` of type `Map<String,String>` (holds `filterStatus`,`filterLoai`,`filterFrom`,`filterTo`,`filterSearch` — used by the JSP's `<v:pagination extraParams="${paginationExtraParams}">`).

- [ ] **Step 1: Rewrite the pagination section of `doGet`**

Replace lines 43-52 (`String filterStatus = ...` through `int offset = (page - 1) * pageSize;`) with:

```java
        String filterStatus = req.getParameter("filterStatus");
        String filterLoai    = req.getParameter("filterLoai");
        String filterFrom    = req.getParameter("filterFrom");
        String filterTo      = req.getParameter("filterTo");
        String filterSearch  = req.getParameter("filterSearch");

        org.example.util.PaginationRequest pagination = org.example.util.PaginationUtils.fromRequest(req);
        java.util.Map<String, String> sortWhitelist = java.util.Map.of(
                "createdAt", "hd.NgayLap",
                "total", "hd.TongThanhToan",
                "status", "hd.TrangThaiThanhToan"
        );
        String sortColumn = org.example.util.PaginationUtils.resolveSortColumn(sortWhitelist, pagination.getSortBy(), "hd.NgayLap");
        String orderClause = "ORDER BY " + sortColumn + " " + pagination.getSortDirection() + ", hd.HoaDonID DESC ";
```

- [ ] **Step 2: Clamp the page after the count query, before running the data query**

Replace lines 120-129 (the `// Count` block) by inserting the clamp immediately after it (keep the existing count query body unchanged, just add these 3 lines right after its closing `}`):

```java
            // Count
            String sqlCount = "SELECT COUNT(*) " + baseQuery;
            try (PreparedStatement ps = conn.prepareStatement(sqlCount)) {
                for (int i = 0; i < params.size(); i++) {
                    ps.setObject(i + 1, params.get(i));
                }
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) totalCount = rs.getInt(1);
                }
            }

            int totalPagesForClamp = totalCount == 0 ? 0 : (int) Math.ceil((double) totalCount / pagination.getPageSize());
            pagination = pagination.withPage(org.example.util.PaginationUtils.clampPage(pagination.getPage(), totalPagesForClamp));
```

- [ ] **Step 3: Use the resolved order clause and normalized offset/pageSize in the data query**

Replace lines 132-145 (`String sqlList = ...` through `listParams.add(pageSize);`) with:

```java
            String sqlList =
                "SELECT hd.HoaDonID, hd.DatSanID, hd.NgayLap, hd.TongTienSan, hd.TongTienDichVu, " +
                "hd.TongThanhToan, hd.TrangThaiThanhToan, hd.PhuongThucThanhToan, " +
                (hasLoaiHoaDon ? "hd.LoaiHoaDon" : "CAST(N'MAIN' AS NVARCHAR(50))") + " AS LoaiHoaDon, " +
                (hasGhiChu ? "hd.GhiChu" : "CAST(NULL AS NVARCHAR(500))") + " AS GhiChu, " +
                (hasParentHoaDonID ? "hd.ParentHoaDonID" : "CAST(NULL AS INT)") + " AS ParentHoaDonID, " +
                "s.TenSan, lds.NgayDat, lds.GioBatDau, lds.GioKetThuc, " +
                "acc.FullName AS TenKhachHang, nv.FullName AS TenNhanVien " +
                baseQuery +
                orderClause +
                "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
            List<Object> listParams = new ArrayList<>(params);
            listParams.add(pagination.getOffset());
            listParams.add(pagination.getPageSize());
```

(The rest of the data-query block — the `try (PreparedStatement ps = ...)` row-mapping loop at lines 146-175 — is unchanged.)

- [ ] **Step 4: Replace the 4 scattered attributes with `invoicePage` + `paginationExtraParams`**

Replace lines 176-198 (from the `catch (Exception e)` through the final `.forward(...)`) with:

```java
        } catch (Exception e) {
            logger.error("HoaDonManagerServlet doGet error: {}", e.getMessage(), e);
            req.setAttribute("errorMsg", "Lỗi tải danh sách hóa đơn: " + e.getMessage());
        }

        org.example.util.PageResult<Map<String, Object>> invoicePage =
                org.example.util.PageResult.of(invoices, pagination.getPage(), pagination.getPageSize(), totalCount);

        List<Map<String, Object>> serviceProducts = loadServiceProducts(user.getCoSoId());
        List<Map<String, Object>> payableBookings = loadPayableBookings(user.getCoSoId());

        Map<String, String> paginationExtraParams = new LinkedHashMap<>();
        if (filterStatus != null) paginationExtraParams.put("filterStatus", filterStatus);
        if (filterLoai != null) paginationExtraParams.put("filterLoai", filterLoai);
        if (filterFrom != null) paginationExtraParams.put("filterFrom", filterFrom);
        if (filterTo != null) paginationExtraParams.put("filterTo", filterTo);
        if (filterSearch != null) paginationExtraParams.put("filterSearch", filterSearch);

        req.setAttribute("serviceProducts", serviceProducts);
        req.setAttribute("payableBookings", payableBookings);
        req.setAttribute("invoicePage",  invoicePage);
        req.setAttribute("paginationExtraParams", paginationExtraParams);
        req.setAttribute("stats",        stats);
        req.setAttribute("filterStatus", filterStatus);
        req.setAttribute("filterLoai",   filterLoai);
        req.setAttribute("filterFrom",   filterFrom);
        req.setAttribute("filterTo",     filterTo);
        req.setAttribute("filterSearch", filterSearch);
        req.setAttribute("pageTitle",    "Quản lý hóa đơn");
        req.getRequestDispatcher("/manager/QuanLyHoaDon.jsp").forward(req, resp);
    }
```

- [ ] **Step 5: Update the JSP**

Open `src/main/webapp/manager/QuanLyHoaDon.jsp`. Add the tag import near the top (alongside the existing `<%@ taglib prefix="c" uri="jakarta.tags.core" %>` — copy its exact position/style):

```jsp
<%@ taglib tagdir="/WEB-INF/tags" prefix="v" %>
```

Find the `c:forEach var="..." items="${invoices}"` (around line 168) and change `items="${invoices}"` to `items="${invoicePage.items}"` — leave the loop variable name and everything inside the loop body untouched (it references row fields like `hoaDonId`, `tongThanhToan`, etc., all unaffected by this change).

Find the old pager block (the raw `<a href="?page=${currentPage-1}&...">` / `<c:forEach begin="1" end="${totalPages}">` block, lines ~236-249) and delete it entirely, replacing it with:

```jsp
<v:pagination pageResult="${invoicePage}" baseUrl="/manager/hoa-don" extraParams="${paginationExtraParams}" ariaLabel="Phân trang hóa đơn" />
```

- [ ] **Step 6: Compile**

Run: `mvn -q compile`
Expected: BUILD SUCCESS. If it fails on an unresolved `Map`/`LinkedHashMap` import, confirm `HoaDonManagerServlet.java:15` already has `import java.util.*;` (it does, per audit) — no new import needed.

- [ ] **Step 7: Manual verification (Test matrix items 1,2,3,4,5,6,7,8,9,10,11,15,16 from the parent spec's Section XXII — this module has filters, so also run item 10/11)**

Start the app (`.\start_server.bat`), log in as a Manager, open `/manager/hoa-don`:
- Empty filter combo that yields 0 rows → no pagination footer renders, existing empty-state markup shows (verify `<c:if test="${pageResult.totalItems > 0}">` inside the tag actually suppresses it).
- Default view with ≥21 invoices → footer shows "Hiển thị 1–20 trong N kết quả", page 2 link present.
- Click page 2 → URL is `...?page=2&filterStatus=...` (encoded), table shows different `HoaDonID` rows than page 1, `filterStatus`/`filterSearch` dropdown/inputs still show the previously chosen values (re-population already handled by existing `${filterStatus}` etc. attributes, untouched by this task).
- Type a Vietnamese search term (e.g. "sân bóng") into `filterSearch`, submit, then click page 2 of the *filtered* result set → confirm the filter is preserved and the Vietnamese text round-trips correctly (no `%E1%BA%A3` mojibake) — inspect via `read_network_requests` or the address bar.
- Manually edit the URL to `?page=99999` → server clamps to the last valid page instead of erroring or showing an empty table with a stuck "page 99999" indicator.
- Manually edit the URL to `?page=-1` → normalizes to page 1.

- [ ] **Step 8: Commit**

```bash
git add src/main/java/org/example/controller/manager/HoaDonManagerServlet.java src/main/webapp/manager/QuanLyHoaDon.jsp
git commit -m "refactor: retrofit invoice list onto shared PaginationRequest/PageResult framework"
```

---

### Task 2 (Module 2): Customer booking history — `DatSanServlet` / `DatSan.jsp`

**Context:** `LichDatSanDAO.getLichByAccountId(accountId)` (`LichDatSanDAOImpl.java:87-105`) feeds the `dsLich` table in `DatSan.jsp:601-698`. Already filters securely by `AccountID` and has `ORDER BY ISNULL(CreatedTime,'1900-01-01') DESC, DatSanID DESC` (already stable!) — it just has no `OFFSET/FETCH` and no pagination UI. This is a plain JDBC DAO (raw `Connection`/`PreparedStatement`, per audit's DAO-pattern-convention section) — add a sibling paginated method rather than changing the existing one's signature (the existing `getLichByAccountId` is likely called elsewhere for non-paginated needs — check with `grep -rn "getLichByAccountId" src/main/java` before deciding whether to change its signature or add a new method; **default to adding a new method** unless the grep shows exactly one call site, which is the one this task touches).

**Do NOT touch** `LichDatSanDAO.getAllLichDatSan()` (used for the booking-conflict timetable in `DatSanServlet.loadBookingPage`/`handleGetChiTietSan`) — audit flagged it as missing a `CoSoID`/date-range filter, but that is a booking-logic concern (conflict detection), explicitly out of scope per the parent task's "không thay đổi nghiệp vụ đặt sân" constraint. Flag it in the final report only.

**Files:**
- Modify: `src/main/java/org/example/dao/LichDatSanDAO.java` — add interface method.
- Modify: `src/main/java/org/example/dao/impl/LichDatSanDAOImpl.java` — add `countByAccountId`, `getLichByAccountIdPaged`.
- Modify: `src/main/java/org/example/controller/customer/DatSanServlet.java:145-165` region (`loadBookingPage`).
- Modify: `src/main/webapp/customer/DatSan.jsp:601-698`.

**Interfaces:**
- Produces: `LichDatSanDAO.countByAccountId(int accountId)` → `long`; `LichDatSanDAO.getLichByAccountIdPaged(int accountId, long offset, int limit)` → `List<LichDatSan>` (or whatever row type `getLichByAccountId` currently returns — match it exactly, do not change the mapped type).

- [ ] **Step 1: Check call sites before editing**

Run: `grep -rn "getLichByAccountId" src/main/java/org/example`
Confirm it's called only from `DatSanServlet.loadBookingPage` (line ~160) and the dead `loadHistoryPage` (line ~184, unreachable per audit — do not modify it, leave it calling the old method, it's dead code cleanup for a separate task). This confirms it is safe to leave the existing method's signature untouched and add new paginated siblings.

- [ ] **Step 2: Add DAO interface methods**

In `src/main/java/org/example/dao/LichDatSanDAO.java`, add next to the existing `getLichByAccountId` declaration:

```java
    long countByAccountId(int accountId);

    List<LichDatSan> getLichByAccountIdPaged(int accountId, long offset, int limit);
```

- [ ] **Step 3: Implement in `LichDatSanDAOImpl`**

Add next to the existing `getLichByAccountId` method (`LichDatSanDAOImpl.java:87-105`) — copy its exact connection/mapping pattern, only the SQL and the two new params differ:

```java
    @Override
    public long countByAccountId(int accountId) {
        String sql = "SELECT COUNT_BIG(1) FROM LichDatSan WHERE AccountID = ? AND IsDeleted = 0";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getLong(1) : 0L;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi đếm lịch đặt sân theo AccountID " + accountId, e);
        }
    }

    @Override
    public List<LichDatSan> getLichByAccountIdPaged(int accountId, long offset, int limit) {
        List<LichDatSan> result = new ArrayList<>();
        String sql = "SELECT * FROM LichDatSan WHERE AccountID = ? AND IsDeleted = 0 " +
                "ORDER BY ISNULL(CreatedTime, CAST('1900-01-01' AS DATETIME)) DESC, DatSanID DESC " +
                "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            ps.setLong(2, offset);
            ps.setInt(3, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    result.add(mapResultSetToLichDatSan(rs));
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi tải trang lịch đặt sân theo AccountID " + accountId, e);
        }
        return result;
    }
```

Use the exact row-mapping helper `getLichByAccountId` already calls (find its method name via `grep -n "private.*mapResultSetToLichDatSan\|private.*mapRow" src/main/java/org/example/dao/impl/LichDatSanDAOImpl.java` and reuse that identifier verbatim instead of `mapResultSetToLichDatSan` if it's named differently).

- [ ] **Step 4: Wire into `DatSanServlet.loadBookingPage`**

Open `DatSanServlet.java` around line 145-165 (`loadBookingPage`). Replace the single call `List<LichDatSan> dsLich = lichDatSanDAO.getLichByAccountId(user.getAccountId());` with:

```java
        org.example.util.PaginationRequest pagination = org.example.util.PaginationUtils.fromRequest(req);
        long totalLich = lichDatSanDAO.countByAccountId(user.getAccountId());
        int totalPagesLich = totalLich == 0 ? 0 : (int) Math.ceil((double) totalLich / pagination.getPageSize());
        pagination = pagination.withPage(org.example.util.PaginationUtils.clampPage(pagination.getPage(), totalPagesLich));
        List<LichDatSan> dsLich = lichDatSanDAO.getLichByAccountIdPaged(user.getAccountId(), pagination.getOffset(), pagination.getPageSize());
        org.example.util.PageResult<LichDatSan> lichPage = org.example.util.PageResult.of(dsLich, pagination.getPage(), pagination.getPageSize(), totalLich);
        req.setAttribute("lichPage", lichPage);
```

Keep the existing `req.setAttribute("dsLich", dsLich);` line if the JSP or any JS on the page reads `dsLich` for something other than the history table render (check with `grep -n "dsLich" src/main/webapp/customer/DatSan.jsp` first) — if `dsLich` is used both for the visible table AND for some other JS computation (e.g. client-side conflict checking, unlikely here since that's `activeBookings`), keep both attributes; otherwise remove the now-redundant `dsLich` attribute and use `lichPage.items` only.

- [ ] **Step 5: Update the JSP**

Add `<%@ taglib tagdir="/WEB-INF/tags" prefix="v" %>` near the top of `DatSan.jsp` (next to its other taglib directives).

At `DatSan.jsp:601-698`, change the `c:forEach` to iterate `${lichPage.items}` instead of `${dsLich}`. Immediately after the closing table markup for this list (before the closing `</div>` of the scrollable history panel — the audit noted a `max-h-[400px] overflow-y-auto` wrapper at this location, confirm the tag call sits *outside* that scrollable wrapper so the pagination footer itself doesn't get clipped/scrolled), insert:

```jsp
<v:pagination pageResult="${lichPage}" baseUrl="/customer/dat-san" ariaLabel="Phân trang lịch sử đặt sân" />
```

No `extraParams` needed here (this list has no search/filter UI per audit — if one exists that was missed, add it to a `Map` the same way Task 1 did).

- [ ] **Step 6: Compile and manually verify**

Run: `mvn -q compile` → BUILD SUCCESS.

Log in as a customer with ≥21 bookings (or temporarily lower `pageSize` via `?pageSize=10` if no test account has that many — check `src/test/java/org/example/FindTestAccountsTest.java`, a pre-existing ad-hoc script noted during audit, for a way to find/seed one), open `/customer/dat-san`, confirm the booking-history panel paginates correctly and page 2 shows older bookings than page 1 (matches the existing `CreatedTime DESC` intent). Confirm the *other* section on this page (the court-conflict timetable, driven by `activeBookings`/`getAllLichDatSan()`) is visually and functionally untouched.

- [ ] **Step 7: Commit**

```bash
git add src/main/java/org/example/dao/LichDatSanDAO.java src/main/java/org/example/dao/impl/LichDatSanDAOImpl.java src/main/java/org/example/controller/customer/DatSanServlet.java src/main/webapp/customer/DatSan.jsp
git commit -m "feat: paginate customer booking history (DatSan.jsp) server-side"
```

---

### Task 3 (Module 3): Audit Log — standardize on the shared tag (no behavior change)

**Context:** `AuditLogAdminServlet`/`AuditLogManagerServlet` + `AuditLogDAOImpl.findWithFilters/countWithFilters` already implement correct server-side pagination (JPA `setFirstResult`/`setMaxResults`, real count query, matching filters, stable-ish `ORDER BY a.createdAt DESC` — see note below). This task does **not** touch the DAO or servlet query logic at all. It only swaps each JSP's own hand-rolled `c:forEach begin="1" end="${totalPages}"` pager markup for `<v:pagination>`, so every module in the app shares one visual pagination component (the whole point of Section IX/X of the parent spec — "Không tạo UI pagination khác nhau hoàn toàn ở mỗi trang").

**Files:**
- Modify: `src/main/java/org/example/controller/admin/AuditLogAdminServlet.java`
- Modify: `src/main/java/org/example/controller/manager/AuditLogManagerServlet.java`
- Modify: `src/main/webapp/admin/AuditLog.jsp` (pager at lines ~341-376)
- Modify: `src/main/webapp/manager/AuditLog.jsp` (pager at lines ~204-238)
- Optionally modify: `src/main/java/org/example/dao/impl/AuditLogDAOImpl.java` — add a stable tiebreak (see Step 1).

- [ ] **Step 1: Add a stable tiebreak to the existing ORDER BY (small, safe fix, matches the parent spec's explicit audit-log example)**

In `AuditLogDAOImpl.java`, change all four occurrences of `"ORDER BY a.createdAt DESC"` (lines 38, 52, 94, and inside `findWithFilters`'s `jpql.append(" ORDER BY a.createdAt DESC")` at line 94) to `"ORDER BY a.createdAt DESC, a.id DESC"` — first confirm the entity's PK field name via `grep -n "@Id" src/main/java/org/example/model/AuditLog.java` (it may be `id`, `auditId`, or similar; use whatever that grep shows, not a guess).

- [ ] **Step 2: Build a `PageResult` in both servlets instead of separate `logs`/`totalPages`/`currentPage` attributes**

In `AuditLogAdminServlet.java` (and identically in `AuditLogManagerServlet.java`, adjusting only the `coSoId` argument), after the existing `findWithFilters`/`countWithFilters` calls, replace whatever `req.setAttribute("logs", logs)` / `req.setAttribute("totalPages", ...)` / `req.setAttribute("currentPage", page)` lines currently exist with:

```java
        org.example.util.PageResult<org.example.model.AuditLog> logPage =
                org.example.util.PageResult.of(logs, page, PAGE_SIZE, total);
        req.setAttribute("logPage", logPage);
```

Keep every other existing attribute (`entityType`, `action`, `dateFrom`, `dateTo`, and — manager-only — `coSoId`) exactly as-is; they feed the filter form and the `extraParams` map below.

Add, right after, a `paginationExtraParams` map built from those same filter values (mirror Task 1 Step 4's pattern exactly) and `req.setAttribute("paginationExtraParams", paginationExtraParams)`.

- [ ] **Step 3: Update both JSPs**

In each `AuditLog.jsp`, add `<%@ taglib tagdir="/WEB-INF/tags" prefix="v" %>`, change the `c:forEach items="${logs}"` to `items="${logPage.items}"`, delete the entire existing hand-rolled pager block, and insert:

```jsp
<v:pagination pageResult="${logPage}" baseUrl="/admin/audit-log" extraParams="${paginationExtraParams}" ariaLabel="Phân trang nhật ký hệ thống" />
```

(for `manager/AuditLog.jsp`, use `baseUrl="/manager/audit-log"` and `ariaLabel="Phân trang nhật ký thao tác"`).

- [ ] **Step 4: Compile, run existing tests, manually verify pixel-for-pixel that behavior (filters, page count, item range) is unchanged — only the pager's markup/DOM should differ**

Run: `mvn -q compile`. Then browser-check `/admin/audit-log` and `/manager/audit-log` with an existing filter combo that spans >7 pages, confirming the ellipsis pager (`1 … 6 7 [8] 9 10 … 20`) now renders identically to the Task 1/2 pages (same purple `bg-purple-600`, same `aria-current="page"`).

- [ ] **Step 5: Commit**

```bash
git add src/main/java/org/example/controller/admin/AuditLogAdminServlet.java src/main/java/org/example/controller/manager/AuditLogManagerServlet.java src/main/webapp/admin/AuditLog.jsp src/main/webapp/manager/AuditLog.jsp src/main/java/org/example/dao/impl/AuditLogDAOImpl.java
git commit -m "refactor: standardize audit log admin/manager JSPs on shared pagination tag"
```

---

### Task 4 (Module 4): Customer management — `CustomerManagerServlet` / `KhachHang.jsp`

**Context:** Three unbounded lists on one page — `getBranchReviews`, `getRiskBookings`, `getHighRiskCancelers` (the fourth, `getTopCustomers`, stays as-is — already capped at 10 by design, not a pagination target per audit). Needs the multi-list-per-page param-prefix convention described in Global Constraints.

**Files:**
- Modify: `src/main/java/org/example/util/PaginationUtils.java` (new overload)
- Create: `src/test/java/org/example/util/PaginationUtilsPrefixTest.java`
- Modify: `src/main/java/org/example/dao/CustomerBranchDAO.java`, `src/main/java/org/example/dao/impl/CustomerBranchDAOImpl.java`
- Modify: `src/main/java/org/example/controller/manager/CustomerManagerServlet.java`
- Modify: `src/main/webapp/manager/KhachHang.jsp`

- [ ] **Step 1: Add the prefixed-params overload to `PaginationUtils` (TDD)**

Failing test, append to a new file `src/test/java/org/example/util/PaginationUtilsPrefixTest.java`:

```java
package org.example.util;

import jakarta.servlet.http.HttpServletRequest;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.*;

class PaginationUtilsPrefixTest {

    @Test
    void fromRequest_withPrefix_readsPrefixedParamNames() {
        HttpServletRequest req = mock(HttpServletRequest.class);
        when(req.getParameter("reviewsPage")).thenReturn("2");
        when(req.getParameter("reviewsPageSize")).thenReturn("10");

        PaginationRequest result = PaginationUtils.fromRequest(req, 20, "reviews");

        assertEquals(2, result.getPage());
        assertEquals(10, result.getPageSize());
    }

    @Test
    void fromRequest_nullPrefix_behavesLikeBareParamNames() {
        HttpServletRequest req = mock(HttpServletRequest.class);
        when(req.getParameter("page")).thenReturn("3");
        when(req.getParameter("pageSize")).thenReturn("50");

        PaginationRequest result = PaginationUtils.fromRequest(req, 20, null);

        assertEquals(3, result.getPage());
        assertEquals(50, result.getPageSize());
    }

    @Test
    void fromRequest_emptyPrefix_behavesLikeBareParamNames() {
        HttpServletRequest req = mock(HttpServletRequest.class);
        when(req.getParameter("page")).thenReturn("1");
        when(req.getParameter("pageSize")).thenReturn("20");

        PaginationRequest result = PaginationUtils.fromRequest(req, 20, "");

        assertEquals(1, result.getPage());
        assertEquals(20, result.getPageSize());
    }
}
```

Run: `mvn -q -Dtest=PaginationUtilsPrefixTest test` → FAIL (no such overload).

Add to `PaginationUtils.java`, next to the existing two-arg `fromRequest`:

```java
    public static PaginationRequest fromRequest(HttpServletRequest request, int defaultPageSize, String paramPrefix) {
        String pageParam = (paramPrefix == null || paramPrefix.isEmpty()) ? "page" : paramPrefix + "Page";
        String pageSizeParam = (paramPrefix == null || paramPrefix.isEmpty()) ? "pageSize" : paramPrefix + "PageSize";
        int page = parseIntOrDefault(request.getParameter(pageParam), DEFAULT_PAGE);
        int pageSize = parseIntOrDefault(request.getParameter(pageSizeParam), defaultPageSize);
        String sortBy = request.getParameter((paramPrefix == null || paramPrefix.isEmpty()) ? "sortBy" : paramPrefix + "SortBy");
        String sortDir = request.getParameter((paramPrefix == null || paramPrefix.isEmpty()) ? "sortDir" : paramPrefix + "SortDir");
        return of(page, pageSize, sortBy, sortDir, defaultPageSize);
    }
```

Run: `mvn -q -Dtest=PaginationUtilsPrefixTest test` → PASS. Commit this sub-step on its own:

```bash
git add src/main/java/org/example/util/PaginationUtils.java src/test/java/org/example/util/PaginationUtilsPrefixTest.java
git commit -m "feat: add prefixed-param overload to PaginationUtils for multi-list pages"
```

- [ ] **Step 2: Add count + paginated DAO methods for reviews, risk bookings, and high-risk cancelers**

In `CustomerBranchDAO.java`, add:

```java
    long countBranchReviews(int coSoId);
    List<Object[]> getBranchReviewsPaged(int coSoId, long offset, int limit);

    long countRiskBookings(int coSoId);
    List<Object[]> getRiskBookingsPaged(int coSoId, long offset, int limit);

    long countHighRiskCancelers(int coSoId);
    List<Object[]> getHighRiskCancelersPaged(int coSoId, long offset, int limit);
```

In `CustomerBranchDAOImpl.java`, add (each following the existing method's exact native-query/`getEntityManager()` shape):

```java
    @Override
    public long countBranchReviews(int coSoId) {
        EntityManager em = getEntityManager();
        try {
            String sql = "SELECT COUNT_BIG(1) FROM DanhGia dg " +
                         "JOIN LichDatSan l ON dg.DatSanID = l.DatSanID " +
                         "JOIN San s ON l.SanID = s.SanID " +
                         "WHERE s.CoSoID = ?1";
            Query query = em.createNativeQuery(sql);
            query.setParameter(1, coSoId);
            return ((Number) query.getSingleResult()).longValue();
        } finally {
            em.close();
        }
    }

    @Override
    @SuppressWarnings("unchecked")
    public List<Object[]> getBranchReviewsPaged(int coSoId, long offset, int limit) {
        EntityManager em = getEntityManager();
        try {
            String sql = "SELECT dg.DanhGiaID, dg.SoSao, dg.BinhLuan, dg.NgayDanhGia, " +
                         "t.FullName, t.Username, s.TenSan " +
                         "FROM DanhGia dg " +
                         "JOIN LichDatSan l ON dg.DatSanID = l.DatSanID " +
                         "JOIN San s ON l.SanID = s.SanID " +
                         "JOIN Accounts t ON dg.AccountID_NguoiDanhGia = t.AccountID " +
                         "WHERE s.CoSoID = ?1 " +
                         "ORDER BY dg.NgayDanhGia DESC, dg.DanhGiaID DESC " +
                         "OFFSET ?2 ROWS FETCH NEXT ?3 ROWS ONLY";
            Query query = em.createNativeQuery(sql);
            query.setParameter(1, coSoId);
            query.setParameter(2, offset);
            query.setParameter(3, limit);
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    public long countRiskBookings(int coSoId) {
        EntityManager em = getEntityManager();
        try {
            String sql = "SELECT COUNT_BIG(1) FROM LichDatSan l " +
                         "JOIN San s ON l.SanID = s.SanID " +
                         "WHERE s.CoSoID = ?1 AND l.TrangThai IN (N'Chờ thanh toán', N'Pending') " +
                         "AND l.NgayDat >= CAST(DATEADD(hour, 7, GETUTCDATE()) AS DATE)";
            Query query = em.createNativeQuery(sql);
            query.setParameter(1, coSoId);
            return ((Number) query.getSingleResult()).longValue();
        } finally {
            em.close();
        }
    }

    @Override
    @SuppressWarnings("unchecked")
    public List<Object[]> getRiskBookingsPaged(int coSoId, long offset, int limit) {
        EntityManager em = getEntityManager();
        try {
            String sql = "SELECT l.DatSanID, l.NgayDat, l.GioBatDau, l.GioKetThuc, l.TongTienDuKien, " +
                         "t.FullName, t.Username, s.TenSan " +
                         "FROM LichDatSan l " +
                         "JOIN San s ON l.SanID = s.SanID " +
                         "JOIN Accounts t ON l.AccountID = t.AccountID " +
                         "WHERE s.CoSoID = ?1 AND l.TrangThai IN (N'Chờ thanh toán', N'Pending') " +
                         "AND l.NgayDat >= CAST(DATEADD(hour, 7, GETUTCDATE()) AS DATE) " +
                         "ORDER BY l.NgayDat ASC, l.GioBatDau ASC, l.DatSanID ASC " +
                         "OFFSET ?2 ROWS FETCH NEXT ?3 ROWS ONLY";
            Query query = em.createNativeQuery(sql);
            query.setParameter(1, coSoId);
            query.setParameter(2, offset);
            query.setParameter(3, limit);
            return query.getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    public long countHighRiskCancelers(int coSoId) {
        EntityManager em = getEntityManager();
        try {
            String sql = "SELECT COUNT_BIG(1) FROM (" +
                         "SELECT t.AccountID FROM LichDatSan l " +
                         "JOIN San s ON l.SanID = s.SanID " +
                         "JOIN Accounts t ON l.AccountID = t.AccountID " +
                         "WHERE s.CoSoID = ?1 " +
                         "GROUP BY t.AccountID, t.FullName, t.Username, t.Email " +
                         "HAVING COUNT(l.DatSanID) >= 3 AND (CAST(SUM(CASE WHEN l.TrangThai IN (N'Đã hủy', N'Cancelled') THEN 1 ELSE 0 END) AS FLOAT) / COUNT(l.DatSanID)) >= 0.30" +
                         ") x";
            Query query = em.createNativeQuery(sql);
            query.setParameter(1, coSoId);
            return ((Number) query.getSingleResult()).longValue();
        } finally {
            em.close();
        }
    }

    @Override
    @SuppressWarnings("unchecked")
    public List<Object[]> getHighRiskCancelersPaged(int coSoId, long offset, int limit) {
        EntityManager em = getEntityManager();
        try {
            String sql = "SELECT t.AccountID, t.FullName, t.Username, t.Email, " +
                         "COUNT(l.DatSanID) as TotalBookings, " +
                         "SUM(CASE WHEN l.TrangThai IN (N'Đã hủy', N'Cancelled') THEN 1 ELSE 0 END) as CanceledBookings, " +
                         "((CAST(SUM(CASE WHEN l.TrangThai IN (N'Đã hủy', N'Cancelled') THEN 1 ELSE 0 END) AS FLOAT) / COUNT(l.DatSanID)) * 100) as CancelRate " +
                         "FROM LichDatSan l " +
                         "JOIN San s ON l.SanID = s.SanID " +
                         "JOIN Accounts t ON l.AccountID = t.AccountID " +
                         "WHERE s.CoSoID = ?1 " +
                         "GROUP BY t.AccountID, t.FullName, t.Username, t.Email " +
                         "HAVING COUNT(l.DatSanID) >= 3 AND (CAST(SUM(CASE WHEN l.TrangThai IN (N'Đã hủy', N'Cancelled') THEN 1 ELSE 0 END) AS FLOAT) / COUNT(l.DatSanID)) >= 0.30 " +
                         "ORDER BY CancelRate DESC, t.AccountID DESC " +
                         "OFFSET ?2 ROWS FETCH NEXT ?3 ROWS ONLY";
            Query query = em.createNativeQuery(sql);
            query.setParameter(1, coSoId);
            query.setParameter(2, offset);
            query.setParameter(3, limit);
            return query.getResultList();
        } finally {
            em.close();
        }
    }
```

- [ ] **Step 3: Wire the three paginated sections into `CustomerManagerServlet`**

Open `CustomerManagerServlet.java` (`doGet`, lines ~22-69 per audit). Replace the three unpaginated calls (`getBranchReviews`, `getRiskBookings`, `getHighRiskCancelers`) with:

```java
        org.example.util.PaginationRequest reviewsPagination = org.example.util.PaginationUtils.fromRequest(req, 20, "reviews");
        long totalReviews = customerBranchDAO.countBranchReviews(coSoId);
        reviewsPagination = reviewsPagination.withPage(org.example.util.PaginationUtils.clampPage(
                reviewsPagination.getPage(), totalReviews == 0 ? 0 : (int) Math.ceil((double) totalReviews / reviewsPagination.getPageSize())));
        List<Object[]> reviews = customerBranchDAO.getBranchReviewsPaged(coSoId, reviewsPagination.getOffset(), reviewsPagination.getPageSize());
        org.example.util.PageResult<Object[]> reviewsPage = org.example.util.PageResult.of(reviews, reviewsPagination.getPage(), reviewsPagination.getPageSize(), totalReviews);

        org.example.util.PaginationRequest riskPagination = org.example.util.PaginationUtils.fromRequest(req, 20, "risk");
        long totalRisk = customerBranchDAO.countRiskBookings(coSoId);
        riskPagination = riskPagination.withPage(org.example.util.PaginationUtils.clampPage(
                riskPagination.getPage(), totalRisk == 0 ? 0 : (int) Math.ceil((double) totalRisk / riskPagination.getPageSize())));
        List<Object[]> riskBookings = customerBranchDAO.getRiskBookingsPaged(coSoId, riskPagination.getOffset(), riskPagination.getPageSize());
        org.example.util.PageResult<Object[]> riskPage = org.example.util.PageResult.of(riskBookings, riskPagination.getPage(), riskPagination.getPageSize(), totalRisk);

        org.example.util.PaginationRequest cancelPagination = org.example.util.PaginationUtils.fromRequest(req, 20, "cancel");
        long totalCancel = customerBranchDAO.countHighRiskCancelers(coSoId);
        cancelPagination = cancelPagination.withPage(org.example.util.PaginationUtils.clampPage(
                cancelPagination.getPage(), totalCancel == 0 ? 0 : (int) Math.ceil((double) totalCancel / cancelPagination.getPageSize())));
        List<Object[]> riskCancelers = customerBranchDAO.getHighRiskCancelersPaged(coSoId, cancelPagination.getOffset(), cancelPagination.getPageSize());
        org.example.util.PageResult<Object[]> cancelPage = org.example.util.PageResult.of(riskCancelers, cancelPagination.getPage(), cancelPagination.getPageSize(), totalCancel);

        req.setAttribute("reviewsPage", reviewsPage);
        req.setAttribute("riskPage", riskPage);
        req.setAttribute("cancelPage", cancelPage);
```

(Leave the existing `getTopCustomers` calls — `vipCustomers`/`repeatCustomers` attributes — completely untouched.)

- [ ] **Step 4: Update `KhachHang.jsp`**

Add the tag import. For each of the 3 sections (reviews at lines ~154-185, riskBookings at ~223-236, riskCancelers at ~272-285): change the `c:forEach items="${reviews}"` → `items="${reviewsPage.items}"` (and analogously for the other two), then insert directly after each table:

```jsp
<v:pagination pageResult="${reviewsPage}" baseUrl="/manager/khach-hang" ariaLabel="Phân trang đánh giá chi nhánh" />
```
```jsp
<v:pagination pageResult="${riskPage}" baseUrl="/manager/khach-hang" ariaLabel="Phân trang lịch đặt rủi ro" />
```
```jsp
<v:pagination pageResult="${cancelPage}" baseUrl="/manager/khach-hang" ariaLabel="Phân trang khách hàng hủy nhiều" />
```

**Important:** because `<v:pagination>` always emits `page`/`pageSize` as its query param names (Task 4's tag file from Phase 1 doesn't know about prefixes), and this page needs `reviewsPage`/`riskPage`/`cancelPage` instead, **do not reuse the Phase 1 tag as-is for this multi-list page**. Two options, pick whichever is less code — do NOT silently pick one, leave a `<!-- TODO -->`-free decision by actually implementing option (a) unless a reviewer prefers (b):
  - (a) Extend `pagination.tag` with an optional `paramName` attribute (default `"page"`) and `pageSizeParamName` attribute (default `"pageSize"`), threading it through every `<c:param name="page" .../>` / `<c:param name="pageSize" .../>` occurrence in the tag (replace the literal `"page"`/`"pageSize"` strings with `"${paramName}"`/`"${pageSizeParamName}"`, and the hidden hint field's `name="page"` too). This keeps exactly one tag file for both single-list and multi-list pages.
  - (b) Add a second tag file `pagination-prefixed.tag` that's a copy with hardcoded prefixed names — **do not do this**, it violates the parent spec's explicit "Không copy một đoạn pagination riêng biệt cho từng trang nếu có thể tái sử dụng" rule.

  Implement (a): edit `src/main/webapp/WEB-INF/tags/pagination.tag` from Phase 1, add:
  ```jsp
  <%@ attribute name="paramName" required="false" type="java.lang.String" %>
  <%@ attribute name="pageSizeParamName" required="false" type="java.lang.String" %>
  ```
  Add right after those two attribute directives:
  ```jsp
  <c:set var="pName" value="${empty paramName ? 'page' : paramName}" />
  <c:set var="szName" value="${empty pageSizeParamName ? 'pageSize' : pageSizeParamName}" />
  ```
  Then replace every literal `name="page"` with `name="${pName}"`, every `<c:param name="page" .../>` with `<c:param name="${pName}" .../>`, every literal `name="pageSize"` with `name="${szName}"`, and every `<c:param name="pageSize" .../>` with `<c:param name="${szName}" .../>` throughout the tag file (there are 4 occurrences of each — prev link, numbered-page loop ×2 branches, next link, plus the page-size `<select>` and its hidden `page` reset input).

  Then the three `KhachHang.jsp` tag calls above become:
  ```jsp
  <v:pagination pageResult="${reviewsPage}" baseUrl="/manager/khach-hang" ariaLabel="Phân trang đánh giá chi nhánh" paramName="reviewsPage" pageSizeParamName="reviewsPageSize" />
  <v:pagination pageResult="${riskPage}" baseUrl="/manager/khach-hang" ariaLabel="Phân trang lịch đặt rủi ro" paramName="riskPage" pageSizeParamName="riskPageSize" />
  <v:pagination pageResult="${cancelPage}" baseUrl="/manager/khach-hang" ariaLabel="Phân trang khách hàng hủy nhiều" paramName="cancelPage" pageSizeParamName="cancelPageSize" />
  ```
  Each section's page-size `<select>` submit now also needs to carry the *other two* sections' current page params as hidden inputs so navigating one list doesn't reset the other two back to page 1 — add three more `<c:if>`-guarded hidden inputs inside the tag's `<form>` for `reviewsPage`/`riskPage`/`cancelPage` (excluding the tag's own `pName`), fed via a 4th optional attribute `siblingParams` (a `Map<String,String>` — e.g. reviews' call passes `siblingParams="${otherListsPageState}"` built in the servlet from the two other pagination objects' current page numbers). This is the one piece of real cross-list coupling in this task — implement it, then re-run the "change page-size on one list, confirm the other two lists don't silently jump back to page 1" manual check in Step 6.

  Since this materially grows `pagination.tag` beyond Phase 1's version, re-run the Phase 1 tag-file smoke test (Task 4, Step 2 of the foundation plan) after this edit, with a `paramName`/`pageSizeParamName` pair supplied, to confirm the single-list call sites from Task 1/2/3 above still work unchanged (they rely on the new attributes defaulting to `"page"`/`"pageSize"` — verify that default path explicitly, not just the prefixed path).

- [ ] **Step 5: Compile**

Run: `mvn -q compile` → BUILD SUCCESS.

- [ ] **Step 6: Manual verification**

Open `/manager/khach-hang` as a Manager with enough reviews/risk-bookings/cancelers to span multiple pages in at least one section (seed test data if needed — do not fabricate production data). Confirm:
- Each of the 3 lists paginates independently — changing `reviewsPage` doesn't reset `riskPage`/`cancelPage`.
- Changing one list's page-size select doesn't silently reset the other two lists back to page 1 (per the sibling-params wiring above).
- `vipCustomers`/`repeatCustomers` (top-10, uncapped-pagination sections) are visually and functionally unchanged.

- [ ] **Step 7: Commit**

```bash
git add src/main/java/org/example/dao/CustomerBranchDAO.java src/main/java/org/example/dao/impl/CustomerBranchDAOImpl.java src/main/java/org/example/controller/manager/CustomerManagerServlet.java src/main/webapp/manager/KhachHang.jsp src/main/webapp/WEB-INF/tags/pagination.tag
git commit -m "feat: server-side pagination for reviews/risk-bookings/high-risk-cancelers on KhachHang.jsp"
```

---

### Task 5a (Module 5, admin side): Staff/account directory — `QuanLyNguoiDungServlet` / `admin/NhanSu.jsp`

**Context:** Highest-priority finding from the admin audit — `getStaffDirectoryAccounts()`/`getDeletedAccounts()` fetch every account row, JSON-embed them into the page, and paginate 8-per-page purely in client JS (`NhanSu.jsp` `nhanSuPageSize=8`). Convert to real server-side search + pagination. Also remove the dead `caLamViecDAO.getAllCaLamViec()` call (confirmed unused by the JSP — flag/delete, not paginate).

**Files:**
- Modify: `src/main/java/org/example/dao/TaiKhoanDAO.java`, `src/main/java/org/example/dao/impl/TaiKhoanDAOImpl.java`
- Modify: `src/main/java/org/example/controller/admin/QuanLyNguoiDungServlet.java`
- Modify: `src/main/webapp/admin/NhanSu.jsp`

- [ ] **Step 1: Add count + paginated + search DAO methods**

Look at `TaiKhoanDAOImpl.getStaffDirectoryAccounts()` and `getDeletedAccounts()` first (`grep -n "getStaffDirectoryAccounts\|getDeletedAccounts" -A 20 src/main/java/org/example/dao/impl/TaiKhoanDAOImpl.java`) to copy their exact JPQL subquery condition (the "excluding unapproved-owner accounts" logic) verbatim into the new methods below rather than re-deriving it — a subtle mismatch here would let unapproved-owner rows leak into the paginated directory.

Add to `TaiKhoanDAO.java`:

```java
    long countStaffDirectoryAccounts(String search, Integer roleId, Integer coSoId);
    List<TaiKhoan> getStaffDirectoryAccountsPaged(String search, Integer roleId, Integer coSoId, long offset, int limit);

    long countDeletedAccounts(String search);
    List<TaiKhoan> getDeletedAccountsPaged(String search, long offset, int limit);
```

Implement in `TaiKhoanDAOImpl.java`, reusing the exact unapproved-owner-exclusion subquery text found in Step 1's grep (call it `<UNAPPROVED_OWNER_EXCLUSION>` below — replace with the real JPQL fragment when writing the code, do not leave it as a placeholder):

```java
    @Override
    public long countStaffDirectoryAccounts(String search, Integer roleId, Integer coSoId) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            StringBuilder jpql = new StringBuilder(
                    "SELECT COUNT(a) FROM TaiKhoan a WHERE (a.isDeleted = false OR a.isDeleted IS NULL) " +
                    "<UNAPPROVED_OWNER_EXCLUSION>");
            if (search != null && !search.isBlank()) jpql.append(" AND (LOWER(a.fullName) LIKE :search OR LOWER(a.username) LIKE :search OR LOWER(a.email) LIKE :search)");
            if (roleId != null) jpql.append(" AND a.roleId = :roleId");
            if (coSoId != null) jpql.append(" AND a.coSoId = :coSoId");
            TypedQuery<Long> q = em.createQuery(jpql.toString(), Long.class);
            if (search != null && !search.isBlank()) q.setParameter("search", "%" + search.trim().toLowerCase() + "%");
            if (roleId != null) q.setParameter("roleId", roleId);
            if (coSoId != null) q.setParameter("coSoId", coSoId);
            return q.getSingleResult();
        } finally {
            em.close();
        }
    }

    @Override
    public List<TaiKhoan> getStaffDirectoryAccountsPaged(String search, Integer roleId, Integer coSoId, long offset, int limit) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            StringBuilder jpql = new StringBuilder(
                    "SELECT a FROM TaiKhoan a WHERE (a.isDeleted = false OR a.isDeleted IS NULL) " +
                    "<UNAPPROVED_OWNER_EXCLUSION>");
            if (search != null && !search.isBlank()) jpql.append(" AND (LOWER(a.fullName) LIKE :search OR LOWER(a.username) LIKE :search OR LOWER(a.email) LIKE :search)");
            if (roleId != null) jpql.append(" AND a.roleId = :roleId");
            if (coSoId != null) jpql.append(" AND a.coSoId = :coSoId");
            jpql.append(" ORDER BY a.fullName ASC, a.accountId ASC");
            TypedQuery<TaiKhoan> q = em.createQuery(jpql.toString(), TaiKhoan.class);
            if (search != null && !search.isBlank()) q.setParameter("search", "%" + search.trim().toLowerCase() + "%");
            if (roleId != null) q.setParameter("roleId", roleId);
            if (coSoId != null) q.setParameter("coSoId", coSoId);
            return q.setFirstResult((int) offset).setMaxResults(limit).getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    public long countDeletedAccounts(String search) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            StringBuilder jpql = new StringBuilder("SELECT COUNT(a) FROM TaiKhoan a WHERE a.isDeleted = true");
            if (search != null && !search.isBlank()) jpql.append(" AND (LOWER(a.fullName) LIKE :search OR LOWER(a.username) LIKE :search OR LOWER(a.email) LIKE :search)");
            TypedQuery<Long> q = em.createQuery(jpql.toString(), Long.class);
            if (search != null && !search.isBlank()) q.setParameter("search", "%" + search.trim().toLowerCase() + "%");
            return q.getSingleResult();
        } finally {
            em.close();
        }
    }

    @Override
    public List<TaiKhoan> getDeletedAccountsPaged(String search, long offset, int limit) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            StringBuilder jpql = new StringBuilder("SELECT a FROM TaiKhoan a WHERE a.isDeleted = true");
            if (search != null && !search.isBlank()) jpql.append(" AND (LOWER(a.fullName) LIKE :search OR LOWER(a.username) LIKE :search OR LOWER(a.email) LIKE :search)");
            jpql.append(" ORDER BY a.fullName ASC, a.accountId ASC");
            TypedQuery<TaiKhoan> q = em.createQuery(jpql.toString(), TaiKhoan.class);
            if (search != null && !search.isBlank()) q.setParameter("search", "%" + search.trim().toLowerCase() + "%");
            return q.setFirstResult((int) offset).setMaxResults(limit).getResultList();
        } finally {
            em.close();
        }
    }
```

(`setFirstResult` takes an `int` in the JPA API — cast `offset` down; this is safe because `PaginationUtils.MAX_PAGE_SIZE=100` combined with any realistic page number keeps `offset` well under `Integer.MAX_VALUE` for this table's foreseeable size. Do not remove the Phase 1 `long`-typed `getOffset()` contract — the cast happens only at this JPA call boundary.)

- [ ] **Step 2: Wire into `QuanLyNguoiDungServlet.doGet`**

Replace lines 63-74 (`List<TaiKhoan> accounts = ...` through the `shifts` line and its two `setAttribute` calls) with:

```java
        String search = req.getParameter("q");
        String roleIdStr = req.getParameter("roleId");
        String coSoIdStr = req.getParameter("coSoId");
        Integer roleFilter = (roleIdStr != null && !roleIdStr.isBlank()) ? Integer.parseInt(roleIdStr) : null;
        Integer coSoFilter = (coSoIdStr != null && !coSoIdStr.isBlank()) ? Integer.parseInt(coSoIdStr) : null;

        org.example.util.PaginationRequest pagination = org.example.util.PaginationUtils.fromRequest(req);
        long totalAccounts = TaiKhoanDAO.countStaffDirectoryAccounts(search, roleFilter, coSoFilter);
        pagination = pagination.withPage(org.example.util.PaginationUtils.clampPage(
                pagination.getPage(), totalAccounts == 0 ? 0 : (int) Math.ceil((double) totalAccounts / pagination.getPageSize())));
        List<TaiKhoan> accounts = TaiKhoanDAO.getStaffDirectoryAccountsPaged(search, roleFilter, coSoFilter, pagination.getOffset(), pagination.getPageSize());
        org.example.util.PageResult<TaiKhoan> accountPage = org.example.util.PageResult.of(accounts, pagination.getPage(), pagination.getPageSize(), totalAccounts);

        org.example.util.PaginationRequest deletedPagination = org.example.util.PaginationUtils.fromRequest(req, 20, "deleted");
        long totalDeleted = TaiKhoanDAO.countDeletedAccounts(search);
        deletedPagination = deletedPagination.withPage(org.example.util.PaginationUtils.clampPage(
                deletedPagination.getPage(), totalDeleted == 0 ? 0 : (int) Math.ceil((double) totalDeleted / deletedPagination.getPageSize())));
        List<TaiKhoan> deletedAccounts = TaiKhoanDAO.getDeletedAccountsPaged(search, deletedPagination.getOffset(), deletedPagination.getPageSize());
        org.example.util.PageResult<TaiKhoan> deletedAccountPage = org.example.util.PageResult.of(deletedAccounts, deletedPagination.getPage(), deletedPagination.getPageSize(), totalDeleted);

        List<CoSo> branches = coSoDAO.getAllCoSo();
        List<VaiTro> roles = VaiTroDAO.getAllRoles();

        req.setAttribute("accountPage", accountPage);
        req.setAttribute("deletedAccountPage", deletedAccountPage);
        req.setAttribute("branches", branches);
        req.setAttribute("roles", roles);
        req.setAttribute("q", search);
        req.setAttribute("roleId", roleIdStr);
        req.setAttribute("coSoId", coSoIdStr);
```

This **deletes** the `caLamViecDAO.getAllCaLamViec()` call and the `shifts`/`staffs`/`accounts`/`deletedAccounts` attributes entirely (dead code per audit — the `caLamViecDAO` field and its `import` in this servlet become unused; remove them too, and remove the now-unused `CaLamViecDAO caLamViecDAO = new CaLamViecDAOImpl();` field declaration and its two imports at lines 20-22).

- [ ] **Step 3: Update `admin/NhanSu.jsp`**

This is the biggest JSP change in Phase 2 — replace client-side JS pagination with server pagination + a GET search form. Concretely:
- Add `<%@ taglib tagdir="/WEB-INF/tags" prefix="v" %>`.
- Add a GET `<form method="get" action="${pageContext.request.contextPath}/admin/nhan-su">` with a text input `name="q"` (search) and any existing role/branch filter dropdowns re-pointed to submit this form (they likely already exist as client-side-only filter controls — repoint them to real `<select name="roleId">`/`<select name="coSoId">` submitted via the form, `onchange="this.form.submit()"`).
- Change `c:forEach items="${accounts}"` → `items="${accountPage.items}"` (line ~277) and `items="${deletedAccounts}"` → `items="${deletedAccountPage.items}"` (line ~296).
- Insert `<v:pagination pageResult="${accountPage}" baseUrl="/admin/nhan-su" extraParams="${...}" ariaLabel="Phân trang tài khoản" />` after the active-accounts table, and `<v:pagination pageResult="${deletedAccountPage}" baseUrl="/admin/nhan-su" extraParams="${...}" ariaLabel="Phân trang tài khoản đã xóa" paramName="deletedPage" pageSizeParamName="deletedPageSize" />` after the deleted-accounts table (reusing the `paramName`/`pageSizeParamName` extension built in Task 4 — this file depends on Task 4 being done first, or that tag-file extension being cherry-picked earlier; note this ordering dependency explicitly if executing tasks out of order).
- Delete the client-side pagination JS block entirely: `nhanSuPageSize=8` (~line 310), `renderPaginationControls()` (~line 312 onward), and the `applyFilters()`/render logic (lines ~378-499) that currently re-filters the full embedded JSON — since the table is now server-rendered from `accountPage.items`, this JS has no more `mockAccounts`-style full array to operate on. Confirm via `grep -n "applyFilters\|renderPaginationControls\|nhanSuPageSize" src/main/webapp/admin/NhanSu.jsp` that nothing else on the page depends on these functions before deleting (e.g. the add/edit/delete modals must NOT depend on this JS — they should be independent AJAX calls to `QuanLyNguoiDungServlet`'s POST actions, unaffected by this cleanup).

- [ ] **Step 4: Compile**

Run: `mvn -q compile` → BUILD SUCCESS (watch for the now-unused `CaLamViecDAO`/`CaLamViec` imports — remove them, don't leave unused imports).

- [ ] **Step 5: Manual verification (Test matrix items 1-16, this module has the richest filter set in Phase 2)**

Open `/admin/nhan-su` as Admin. Confirm: search box filters server-side (check Network tab — full page reload with `?q=...`, not a client JS filter); role/branch filters combine correctly with search; pagination works on both the active and deleted tabs independently; deep-linking `?q=nguyen&roleId=4&page=2` on a fresh browser tab reproduces the exact same filtered/paginated view (proves state isn't hidden in JS-only memory anymore).

- [ ] **Step 6: Commit**

```bash
git add src/main/java/org/example/dao/TaiKhoanDAO.java src/main/java/org/example/dao/impl/TaiKhoanDAOImpl.java src/main/java/org/example/controller/admin/QuanLyNguoiDungServlet.java src/main/webapp/admin/NhanSu.jsp
git commit -m "feat: real server-side search+pagination for admin staff/account directory"
```

---

### Task 5b (Module 5, manager side): Staff list — `NhanSuManagerServlet` / `manager/NhanSu.jsp` (AJAX, keeps AJAX)

**Context:** Manager's `action=list`/`action=deletedList` JSON endpoints currently return the *entire* branch staff list with zero pagination (worse than the admin side, which at least fake-paginated client-side). Per Section XII/XIII of the parent spec ("Chỉ dùng AJAX nếu trang hiện tại đã dùng AJAX ổn định" — this page already is), keep the AJAX architecture but make the JSON response carry real pagination metadata, and add one small reusable JS renderer instead of hand-rolling pager HTML per page.

**Files:**
- Modify: `src/main/java/org/example/service/manager/NhanSuService.java`
- Modify: `src/main/java/org/example/controller/manager/NhanSuManagerServlet.java`
- Modify: `src/main/webapp/manager/NhanSu.jsp`
- Create: `src/main/webapp/assets/js/pagination-footer.js`

- [ ] **Step 1: Add paginated variants to `TaiKhoanDAO`**

Reuse the exact same `getAccountsByCoSoAndRoleNotIn`/`getDeletedAccountsByCoSoAndRoleNotIn` JPQL shape (`TaiKhoanDAOImpl.java:462-503`) but add search + offset/limit + count siblings:

```java
    long countAccountsByCoSoAndRoleNotIn(int coSoId, List<Integer> excludedRoleIds, String search);
    List<TaiKhoan> getAccountsByCoSoAndRoleNotInPaged(int coSoId, List<Integer> excludedRoleIds, String search, long offset, int limit);

    long countDeletedAccountsByCoSoAndRoleNotIn(int coSoId, List<Integer> excludedRoleIds, String search);
    List<TaiKhoan> getDeletedAccountsByCoSoAndRoleNotInPaged(int coSoId, List<Integer> excludedRoleIds, String search, long offset, int limit);
```

```java
    @Override
    public long countAccountsByCoSoAndRoleNotIn(int coSoId, List<Integer> excludedRoleIds, String search) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            StringBuilder jpql = new StringBuilder(
                    "SELECT COUNT(a) FROM TaiKhoan a WHERE a.coSoId = :coSoId AND (a.isDeleted = false OR a.isDeleted IS NULL)");
            if (excludedRoleIds != null && !excludedRoleIds.isEmpty()) jpql.append(" AND a.roleId NOT IN :excludedRoles");
            if (search != null && !search.isBlank()) jpql.append(" AND (LOWER(a.fullName) LIKE :search OR LOWER(a.username) LIKE :search)");
            TypedQuery<Long> q = em.createQuery(jpql.toString(), Long.class).setParameter("coSoId", coSoId);
            if (excludedRoleIds != null && !excludedRoleIds.isEmpty()) q.setParameter("excludedRoles", excludedRoleIds);
            if (search != null && !search.isBlank()) q.setParameter("search", "%" + search.trim().toLowerCase() + "%");
            return q.getSingleResult();
        } catch (Exception e) {
            logger.error("Lỗi đếm tài khoản theo cơ sở {}: {}", coSoId, e.getMessage(), e);
            return 0L;
        } finally {
            em.close();
        }
    }

    @Override
    public List<TaiKhoan> getAccountsByCoSoAndRoleNotInPaged(int coSoId, List<Integer> excludedRoleIds, String search, long offset, int limit) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            StringBuilder jpql = new StringBuilder(
                    "SELECT a FROM TaiKhoan a WHERE a.coSoId = :coSoId AND (a.isDeleted = false OR a.isDeleted IS NULL)");
            if (excludedRoleIds != null && !excludedRoleIds.isEmpty()) jpql.append(" AND a.roleId NOT IN :excludedRoles");
            if (search != null && !search.isBlank()) jpql.append(" AND (LOWER(a.fullName) LIKE :search OR LOWER(a.username) LIKE :search)");
            jpql.append(" ORDER BY a.fullName ASC, a.accountId ASC");
            TypedQuery<TaiKhoan> q = em.createQuery(jpql.toString(), TaiKhoan.class).setParameter("coSoId", coSoId);
            if (excludedRoleIds != null && !excludedRoleIds.isEmpty()) q.setParameter("excludedRoles", excludedRoleIds);
            if (search != null && !search.isBlank()) q.setParameter("search", "%" + search.trim().toLowerCase() + "%");
            return q.setFirstResult((int) offset).setMaxResults(limit).getResultList();
        } catch (Exception e) {
            logger.error("Lỗi lấy tài khoản theo cơ sở {}: {}", coSoId, e.getMessage(), e);
            return java.util.Collections.emptyList();
        } finally {
            em.close();
        }
    }
```

(Implement `countDeletedAccountsByCoSoAndRoleNotIn`/`getDeletedAccountsByCoSoAndRoleNotInPaged` identically, swapping `isDeleted = false OR ... IS NULL` for `isDeleted = true`, mirroring `getDeletedAccountsByCoSoAndRoleNotIn`'s existing shape at lines 484-503.)

- [ ] **Step 2: Thread pagination through `NhanSuService`**

Find `getStaffListByBranch`/`getDeletedStaffListByBranch` (`NhanSuService.java:248-275,572-598`). Add paginated overloads next to them (keep the originals if anything else calls the unpaginated form — check with `grep -rn "getStaffListByBranch\|getDeletedStaffListByBranch" src/main/java`):

```java
    public org.example.util.PageResult<NhanSuDTO> getStaffListByBranchPaged(int coSoId, String search, org.example.util.PaginationRequest pagination) {
        List<Integer> excluded = List.of(1, 2); // mirror whatever role-exclusion list getStaffListByBranch already uses — copy it verbatim, do not re-derive
        long total = taiKhoanDAO.countAccountsByCoSoAndRoleNotIn(coSoId, excluded, search);
        org.example.util.PaginationRequest clamped = pagination.withPage(
                org.example.util.PaginationUtils.clampPage(pagination.getPage(), total == 0 ? 0 : (int) Math.ceil((double) total / pagination.getPageSize())));
        List<TaiKhoan> accounts = taiKhoanDAO.getAccountsByCoSoAndRoleNotInPaged(coSoId, excluded, search, clamped.getOffset(), clamped.getPageSize());
        List<NhanSuDTO> dtos = accounts.stream().map(this::toDTO).collect(java.util.stream.Collectors.toList()); // reuse whatever entity->DTO mapping getStaffListByBranch already does — copy it verbatim
        return org.example.util.PageResult.of(dtos, clamped.getPage(), clamped.getPageSize(), total);
    }
```

Before writing this for real, open `NhanSuService.java:248-275` and copy the **exact** role-exclusion list and entity→DTO mapping it uses instead of the placeholder `List.of(1, 2)` / `this::toDTO` shown above — those two details must match the existing unpaginated method exactly or the paginated list will silently show different rows than before. Implement `getDeletedStaffListByBranchPaged` analogously.

- [ ] **Step 3: Update `NhanSuManagerServlet`'s JSON endpoints**

Replace the `"list".equals(action)` block (lines 56-69) with:

```java
        if ("list".equals(action)) {
            try {
                String search = req.getParameter("q");
                org.example.util.PaginationRequest pagination = org.example.util.PaginationUtils.fromRequest(req);
                org.example.util.PageResult<NhanSuDTO> staffPage = nhanSuService.getStaffListByBranchPaged(managerCoSoId, search, pagination);
                resp.setContentType("application/json");
                resp.setCharacterEncoding("UTF-8");
                resp.getWriter().write(buildStaffPageJson(staffPage));
            } catch (Exception e) {
                logger.error("Error listing staff: {}", e.getMessage(), e);
                resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                resp.getWriter().write("Có lỗi xảy ra khi tải danh sách nhân viên.");
            }
            return;
        }
```

(Mirror for `"deletedList"`.) Add a new helper next to the existing `buildStaffListJson`:

```java
    private String buildStaffPageJson(org.example.util.PageResult<NhanSuDTO> page) {
        java.util.Map<String, Object> envelope = new java.util.LinkedHashMap<>();
        envelope.put("items", mapStaffList(page.getItems()));
        envelope.put("page", page.getPage());
        envelope.put("pageSize", page.getPageSize());
        envelope.put("totalItems", page.getTotalItems());
        envelope.put("totalPages", page.getTotalPages());
        envelope.put("hasPrevious", page.isHasPrevious());
        envelope.put("hasNext", page.isHasNext());
        envelope.put("fromItem", page.getFromItem());
        envelope.put("toItem", page.getToItem());
        return new com.google.gson.Gson().toJson(envelope);
    }
```

Rename the existing `buildStaffListJson`'s row-mapping body (the `for (NhanSuDTO s : staffList) {...}` loop building `mappedList`) into a private `mapStaffList(List<NhanSuDTO>)` that returns the `List<Map<String,Object>>` without serializing to JSON itself, and have both `buildStaffListJson` (if still needed elsewhere) and the new `buildStaffPageJson` call it — don't duplicate the per-row mapping logic.

- [ ] **Step 4: Add the shared JS pagination-footer renderer**

Create `src/main/webapp/assets/js/pagination-footer.js`:

```javascript
/**
 * Shared vanilla-JS pagination footer for AJAX-driven list pages.
 * Mirrors the visual language of WEB-INF/tags/pagination.tag (purple active page,
 * aria-current, disabled prev/next) for pages that fetch JSON instead of doing
 * full-page GET navigation.
 *
 * @param {HTMLElement} container - element to render the footer into (its innerHTML is replaced)
 * @param {{page:number,pageSize:number,totalItems:number,totalPages:number,hasPrevious:boolean,hasNext:boolean,fromItem:number,toItem:number}} pageMeta
 * @param {{onPageChange:(page:number)=>void, onPageSizeChange:(size:number)=>void}} handlers
 */
function renderPaginationFooter(container, pageMeta, handlers) {
    if (!container) return;
    if (!pageMeta || pageMeta.totalItems === 0) {
        container.innerHTML = "";
        return;
    }

    function pageButton(p, isCurrent) {
        if (isCurrent) {
            return '<span class="px-3 py-1 rounded-md bg-purple-600 text-white font-semibold" aria-current="page">' + p + '</span>';
        }
        return '<a href="#" data-page="' + p + '" class="px-3 py-1 rounded-md hover:bg-purple-100 text-purple-700" aria-label="Đi đến trang ' + p + '">' + p + '</a>';
    }

    var numbers = [];
    var totalPages = pageMeta.totalPages;
    var current = pageMeta.page;
    if (totalPages <= 7) {
        for (var p = 1; p <= totalPages; p++) numbers.push(pageButton(p, p === current));
    } else {
        var last = 0;
        for (var p2 = 1; p2 <= totalPages; p2++) {
            var show = p2 === 1 || p2 === totalPages || (p2 >= current - 2 && p2 <= current + 2);
            if (show) {
                if (p2 - last > 1) numbers.push('<span class="px-2 text-gray-400">…</span>');
                numbers.push(pageButton(p2, p2 === current));
                last = p2;
            }
        }
    }

    var prevHtml = pageMeta.hasPrevious
        ? '<a href="#" data-page="' + (current - 1) + '" class="px-2 py-1 rounded-md hover:bg-purple-100 text-purple-700">‹ Trước</a>'
        : '<span class="px-2 py-1 rounded-md text-gray-300" aria-disabled="true">‹ Trước</span>';
    var nextHtml = pageMeta.hasNext
        ? '<a href="#" data-page="' + (current + 1) + '" class="px-2 py-1 rounded-md hover:bg-purple-100 text-purple-700">Sau ›</a>'
        : '<span class="px-2 py-1 rounded-md text-gray-300" aria-disabled="true">Sau ›</span>';

    container.innerHTML =
        '<nav class="flex flex-col sm:flex-row items-center justify-between gap-3 px-4 py-3 border-t border-gray-200 text-sm text-gray-600" aria-label="Phân trang">' +
        '<div>Hiển thị <span class="font-medium text-gray-800">' + pageMeta.fromItem + '</span>–<span class="font-medium text-gray-800">' + pageMeta.toItem + '</span> trong <span class="font-medium text-gray-800">' + pageMeta.totalItems + '</span> kết quả</div>' +
        '<div class="flex items-center gap-4">' +
        '<label class="text-gray-500">Mỗi trang: ' +
        '<select data-role="page-size-select" class="border border-gray-300 rounded-md text-sm px-2 py-1 ml-1 focus:outline-none focus:ring-2 focus:ring-purple-500">' +
        [10, 20, 50].map(function (sz) {
            return '<option value="' + sz + '"' + (pageMeta.pageSize === sz ? ' selected' : '') + '>' + sz + '</option>';
        }).join('') +
        '</select></label>' +
        (totalPages > 1 ? '<ul class="flex items-center gap-1"><li>' + prevHtml + '</li>' + numbers.map(function (n) { return '<li>' + n + '</li>'; }).join('') + '<li>' + nextHtml + '</li></ul>' : '') +
        '</div></nav>';

    container.querySelectorAll('a[data-page]').forEach(function (a) {
        a.addEventListener('click', function (evt) {
            evt.preventDefault();
            handlers.onPageChange(parseInt(a.getAttribute('data-page'), 10));
        });
    });
    var sizeSelect = container.querySelector('[data-role="page-size-select"]');
    if (sizeSelect) {
        sizeSelect.addEventListener('change', function () {
            handlers.onPageSizeChange(parseInt(sizeSelect.value, 10));
        });
    }
}
```

- [ ] **Step 5: Wire it into `manager/NhanSu.jsp`**

Add `<script src="${pageContext.request.contextPath}/assets/js/pagination-footer.js"></script>` near the page's other script includes. Find the existing `fetch('/manager/nhan-su?action=list')` call (~line 348) and `renderStaff()` (~line 360). Add state variables (`let currentPage = 1, currentPageSize = 20, currentSearch = '';`) and change the fetch to `fetch(contextPath + '/manager/nhan-su?action=list&page=' + currentPage + '&pageSize=' + currentPageSize + '&q=' + encodeURIComponent(currentSearch))`. Parse the new envelope shape (`{items, page, pageSize, totalItems, totalPages, hasPrevious, hasNext, fromItem, toItem}` instead of a bare array), call `renderStaff(response.items)` for the table body, and call `renderPaginationFooter(document.getElementById('nhanSuPaginationFooter'), response, {onPageChange: function(p){ currentPage = p; loadStaff(); }, onPageSizeChange: function(sz){ currentPageSize = sz; currentPage = 1; loadStaff(); }})` (add a `<div id="nhanSuPaginationFooter"></div>` container below the staff table, and wire the existing search input's `input`/`keyup` handler — debounced 300-500ms per spec Section XII — to set `currentSearch` + `currentPage = 1` + reload). Apply the identical pattern to the deleted-staff tab/fetch.

- [ ] **Step 6: Compile and manually verify**

Run: `mvn -q compile` → BUILD SUCCESS.

Open `/manager/nhan-su` as Manager, confirm the staff list now paginates via real server requests (check Network tab: each page click issues a new `action=list&page=N` request, response payload only contains that page's rows — not the full branch roster), search debounces and resets to page 1, page-size select works, deleted-staff tab behaves the same way independently.

- [ ] **Step 7: Commit**

```bash
git add src/main/java/org/example/dao/TaiKhoanDAO.java src/main/java/org/example/dao/impl/TaiKhoanDAOImpl.java src/main/java/org/example/service/manager/NhanSuService.java src/main/java/org/example/controller/manager/NhanSuManagerServlet.java src/main/webapp/manager/NhanSu.jsp src/main/webapp/assets/js/pagination-footer.js
git commit -m "feat: server-side pagination for manager staff list JSON endpoints (AJAX)"
```

---

### Task 6 (Module 6): Inventory/service catalog — `KhoDichVuManagerServlet` / `KhoDichVu.jsp`

**Context:** `findByCoSo(coSoId)` fetches every product/service row for the branch, then `search`/`category`/`status` filters are applied **in Java memory** (`KhoDichVuManagerServlet.java:114-138`). Push filtering to SQL and add real pagination. KPI values (`totalItems`, `totalInventoryValue`, `lowStockCount`, `outOfStockCount`) are currently computed from the same in-memory filtered list — after this change they must be computed from a **separate unfiltered-by-pagination-but-filtered-by-search/category/status** query (i.e., KPIs reflect the current filter combo's full result set, not just the current page) — do not compute KPIs from `pageResult.items` (that would only reflect ≤50 rows).

**Files:**
- Modify: `src/main/java/org/example/dao/SanPhamDichVuDAO.java`, `src/main/java/org/example/dao/impl/SanPhamDichVuDAOImpl.java`
- Modify: `src/main/java/org/example/controller/manager/KhoDichVuManagerServlet.java`
- Modify: `src/main/webapp/manager/KhoDichVu.jsp`

- [ ] **Step 1: Add filtered count/data/KPI DAO methods**

```java
    long countByCoSoFiltered(int coSoId, String search, Integer categoryId, String status);
    List<SanPham_DichVu> findByCoSoFilteredPaged(int coSoId, String search, Integer categoryId, String status, long offset, int limit);
    double sumInventoryValueByCoSoFiltered(int coSoId, String search, Integer categoryId, String status);
    long countLowStockByCoSoFiltered(int coSoId, String search, Integer categoryId, String status);
    long countOutOfStockByCoSoFiltered(int coSoId, String search, Integer categoryId, String status);
```

```java
    private String buildFilterJpql(String search, Integer categoryId, String status) {
        StringBuilder jpql = new StringBuilder(" AND s.isDeleted = false");
        if (search != null && !search.isBlank()) jpql.append(" AND (LOWER(s.TenSanPham) LIKE :search OR LOWER(s.skuCode) LIKE :search)");
        if (categoryId != null) jpql.append(" AND s.DanhMucID = :categoryId");
        if (status != null && !status.isBlank()) jpql.append(" AND s.TrangThai = :status");
        return jpql.toString();
    }

    private void bindFilterParams(jakarta.persistence.Query q, String search, Integer categoryId, String status) {
        if (search != null && !search.isBlank()) q.setParameter("search", "%" + search.trim().toLowerCase() + "%");
        if (categoryId != null) q.setParameter("categoryId", categoryId);
        if (status != null && !status.isBlank()) q.setParameter("status", status);
    }

    @Override
    public long countByCoSoFiltered(int coSoId, String search, Integer categoryId, String status) {
        EntityManager em = getEntityManager();
        try {
            String jpql = "SELECT COUNT(s) FROM SanPham_DichVu s WHERE s.CoSoID = :coSoId" + buildFilterJpql(search, categoryId, status);
            jakarta.persistence.TypedQuery<Long> q = em.createQuery(jpql, Long.class).setParameter("coSoId", coSoId);
            bindFilterParams(q, search, categoryId, status);
            return q.getSingleResult();
        } finally {
            em.close();
        }
    }

    @Override
    public List<SanPham_DichVu> findByCoSoFilteredPaged(int coSoId, String search, Integer categoryId, String status, long offset, int limit) {
        EntityManager em = getEntityManager();
        try {
            String jpql = "SELECT s FROM SanPham_DichVu s WHERE s.CoSoID = :coSoId" + buildFilterJpql(search, categoryId, status) + " ORDER BY s.TenSanPham ASC, s.sanPhamDichVuId ASC";
            jakarta.persistence.TypedQuery<SanPham_DichVu> q = em.createQuery(jpql, SanPham_DichVu.class).setParameter("coSoId", coSoId);
            bindFilterParams(q, search, categoryId, status);
            return q.setFirstResult((int) offset).setMaxResults(limit).getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    public double sumInventoryValueByCoSoFiltered(int coSoId, String search, Integer categoryId, String status) {
        EntityManager em = getEntityManager();
        try {
            String jpql = "SELECT COALESCE(SUM(s.SoLuongTon * s.GiaNhap), 0) FROM SanPham_DichVu s WHERE s.CoSoID = :coSoId" + buildFilterJpql(search, categoryId, status);
            jakarta.persistence.TypedQuery<Double> q = em.createQuery(jpql, Double.class).setParameter("coSoId", coSoId);
            bindFilterParams(q, search, categoryId, status);
            return q.getSingleResult();
        } finally {
            em.close();
        }
    }

    @Override
    public long countLowStockByCoSoFiltered(int coSoId, String search, Integer categoryId, String status) {
        EntityManager em = getEntityManager();
        try {
            String jpql = "SELECT COUNT(s) FROM SanPham_DichVu s WHERE s.CoSoID = :coSoId AND s.SoLuongTon <= 5 AND s.TrangThai <> :ngungKinhDoanh" + buildFilterJpql(search, categoryId, status);
            jakarta.persistence.TypedQuery<Long> q = em.createQuery(jpql, Long.class)
                    .setParameter("coSoId", coSoId)
                    .setParameter("ngungKinhDoanh", org.example.util.Constants.TRANG_THAI_SP_NGUNG_KINH_DOANH);
            bindFilterParams(q, search, categoryId, status);
            return q.getSingleResult();
        } finally {
            em.close();
        }
    }

    @Override
    public long countOutOfStockByCoSoFiltered(int coSoId, String search, Integer categoryId, String status) {
        EntityManager em = getEntityManager();
        try {
            String jpql = "SELECT COUNT(s) FROM SanPham_DichVu s WHERE s.CoSoID = :coSoId AND s.SoLuongTon = 0 AND s.TrangThai <> :ngungKinhDoanh" + buildFilterJpql(search, categoryId, status);
            jakarta.persistence.TypedQuery<Long> q = em.createQuery(jpql, Long.class)
                    .setParameter("coSoId", coSoId)
                    .setParameter("ngungKinhDoanh", org.example.util.Constants.TRANG_THAI_SP_NGUNG_KINH_DOANH);
            bindFilterParams(q, search, categoryId, status);
            return q.getSingleResult();
        } finally {
            em.close();
        }
    }
```

Before finalizing, confirm the exact JPA field names (`s.SoLuongTon`, `s.GiaNhap`, `s.TenSanPham`, `s.skuCode`, `s.DanhMucID`, `s.TrangThai`, `s.CoSoID`, `s.isDeleted`, and the PK field used for the ORDER BY tiebreak — likely `sanPhamDichVuId` or similar) via `grep -n "private\|@Id\|@Column" src/main/java/org/example/model/SanPham_DichVu.java` — the existing `findByCoSo` method (Step 0 read above) already confirms `CoSoID`/`isDeleted`/`TenSanPham` are valid JPQL field names on this entity (JPA field names here follow the DB column casing directly, unusually, per the audit's read of `findByCoSo`), so match that exact casing for every new field reference above rather than assuming camelCase.

- [ ] **Step 2: Rewrite `KhoDichVuManagerServlet.doGet`'s filtering/pagination section**

Replace lines 109-150 (`String search = ...` through the `outOfStockCount` stream) with:

```java
        String search = req.getParameter("search");
        String categoryIdStr = req.getParameter("category");
        String status = req.getParameter("status");
        Integer categoryId = (categoryIdStr != null && !categoryIdStr.trim().isEmpty()) ? Integer.parseInt(categoryIdStr.trim()) : null;

        org.example.util.PaginationRequest pagination = org.example.util.PaginationUtils.fromRequest(req);
        long totalItems = sanPhamDAO.countByCoSoFiltered(coSoId, search, categoryId, status);
        pagination = pagination.withPage(org.example.util.PaginationUtils.clampPage(
                pagination.getPage(), totalItems == 0 ? 0 : (int) Math.ceil((double) totalItems / pagination.getPageSize())));
        List<SanPham_DichVu> list = sanPhamDAO.findByCoSoFilteredPaged(coSoId, search, categoryId, status, pagination.getOffset(), pagination.getPageSize());
        org.example.util.PageResult<SanPham_DichVu> productPage = org.example.util.PageResult.of(list, pagination.getPage(), pagination.getPageSize(), totalItems);

        double totalInventoryValue = sanPhamDAO.sumInventoryValueByCoSoFiltered(coSoId, search, categoryId, status);
        long lowStockCount = sanPhamDAO.countLowStockByCoSoFiltered(coSoId, search, categoryId, status);
        long outOfStockCount = sanPhamDAO.countOutOfStockByCoSoFiltered(coSoId, search, categoryId, status);
```

Then replace `req.setAttribute("productList", list);` / `req.setAttribute("totalItems", totalItems);` with `req.setAttribute("productPage", productPage);` (drop the separate `totalItems` attribute — it's now `productPage.totalItems`; keep `totalInventoryValue`/`lowStockCount`/`outOfStockCount` attributes as before, just now sourced from real filtered SQL aggregates instead of an in-memory stream over a possibly-partial list). Remove the now-unused `import java.util.stream.Collectors;` if nothing else in the file uses it (`grep -n "Collectors\." src/main/java/org/example/controller/manager/KhoDichVuManagerServlet.java` first).

- [ ] **Step 3: Update `KhoDichVu.jsp`**

Add the tag import. Change the main table's `c:forEach items="${productList}"` (line ~514-603 per audit) to `items="${productPage.items}"`. Insert `<v:pagination pageResult="${productPage}" baseUrl="/manager/kho-dich-vu" extraParams="${...}" ariaLabel="Phân trang kho dịch vụ" />` (build the `extraParams` map — `search`/`category`/`status` — in the servlet the same way Task 1 did, and set it as a request attribute before forwarding). The `categories` dropdown re-renders (lines 406-408, 548-552, 655-657, 747-749, 876-883, 1224-1226 per audit) are unaffected — `categories` stays a full unfiltered list (small, global lookup table, not a pagination target).

- [ ] **Step 4: Compile**

Run: `mvn -q compile` → BUILD SUCCESS.

- [ ] **Step 5: Manual verification**

Open `/manager/kho-dich-vu` as Manager with ≥21 products in the branch. Confirm: KPI tiles (`Tổng giá trị tồn kho`, `Sắp hết hàng`, `Hết hàng`) reflect the **whole filtered set**, not just the visible page (test by comparing the KPI numbers before/after changing page — they must stay identical across pages of the same filter, and must NOT equal a sum over only the visible 20 rows); search+category+status filters combine correctly and push down to SQL (verify via query logs or by timing/behavior, not just UI); pagination + filters compose (Test matrix items 10, 11, 12).

- [ ] **Step 6: Commit**

```bash
git add src/main/java/org/example/dao/SanPhamDichVuDAO.java src/main/java/org/example/dao/impl/SanPhamDichVuDAOImpl.java src/main/java/org/example/controller/manager/KhoDichVuManagerServlet.java src/main/webapp/manager/KhoDichVu.jsp
git commit -m "feat: push kho-dich-vu search/filter/pagination to SQL instead of in-memory streams"
```

---

### Task 7: Phase 2 full verification

- [ ] **Step 1:** `mvn test` → BUILD SUCCESS, all Phase 1 + Phase 2 unit tests pass.
- [ ] **Step 2:** `mvn package` → BUILD SUCCESS.
- [ ] **Step 3:** Full manual pass through Test matrix items 1-17 (parent spec Section XXII) for each of the 6 modules above — do not skip any module just because an earlier one passed.
- [ ] **Step 4:** Confirm zero changes to any file under `service/pricing/`, `service/checkout/`, `service/billing/`, `service/payos/`, or any `TongThanhToan`/`TrangThaiThanhToan`-computing code path: `git diff --stat main -- src/main/java/org/example/service/pricing src/main/java/org/example/service/checkout src/main/java/org/example/service/billing src/main/java/org/example/service/payos` must be empty.
- [ ] **Step 5:** Stop here. Do not start Phase 3 in the same run — get Phase 2 reviewed/merged first, per the parent task's own "sau mỗi module compile/test/verify" cadence applied at the phase level.
