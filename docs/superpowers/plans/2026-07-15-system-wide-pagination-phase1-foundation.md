# System-Wide Pagination — Phase 1: Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the reusable server-side pagination framework (request/response DTOs, normalization utility, JSP tag file) that every module in Phase 2 and Phase 3 will build on top of. No servlet/DAO/JSP in the existing app is touched in this phase.

**Architecture:** Three plain Java classes in `org.example.util` (`PaginationRequest`, `PageResult<T>`, `PaginationUtils`) provide normalized pagination params and a uniform result envelope. A new JSP tag file at `WEB-INF/tags/pagination.tag` renders the footer (item-range text, page-size select, compact page-number list with ellipsis, prev/next) from a `PageResult` plus a base URL and a map of extra query params to preserve. DAOs will later expose two methods per list (`count*` / `find*`) that consume `PaginationRequest.getOffset()`/`getPageSize()` and build `PageResult` via `PageResult.of(...)`.

**Tech Stack:** Java 17, Jakarta Servlet 6.0 / JSP 3.1 (Tomcat 10.1), JSTL (`jakarta.tags.core`), JUnit 5.10.2 (no Mockito in this repo — pure-function unit tests only).

## Global Constraints

- Default page = 1, default pageSize = 20. Allowed pageSize values: `{10, 20, 50}`. Hard cap: 100. Any value outside the allowed set falls back to the caller's default (not silently clamped to nearest).
- Page < 1 normalizes to 1. Page beyond `totalPages` clamps to `totalPages` (or 1 if `totalPages == 0`) — this clamping happens in the **service layer**, after the count query, via `PaginationUtils.clampPage(page, totalPages)` + `PaginationRequest.withPage(...)`, never inside the DAO.
- `totalItems` is `long` everywhere (never `int`) to avoid overflow on large tables.
- `sortDirection` normalizes to exactly `"ASC"` or `"DESC"` (uppercase) — anything else (including null) becomes the module's default direction.
- `sortBy` is never used as a raw SQL column name. Every DAO that accepts sorting must resolve it through a `Map<String,String>` whitelist via `PaginationUtils.resolveSortColumn(whitelist, requestedKey, defaultColumn)`.
- No class in this phase touches booking, payment, or pricing logic. This is pure infrastructure.
- Follow existing repo conventions found during audit: JPA/JDBC DAOs stay as-is (this phase adds no DAO changes); JSTL taglib prefix `c` → `jakarta.tags.core` (confirmed in `src/main/webapp/manager/AuditLog.jsp:3`); unit tests live in `src/test/java/org/example/util/`, package-private test classes, `methodUnderTest_expectedBehavior` naming (matching `src/test/java/org/example/util/SecretMaskUtilTest.java`).

---

## File Structure

- Create: `src/main/java/org/example/util/PaginationRequest.java` — immutable normalized pagination input (page, pageSize, sortBy, sortDirection) + offset math.
- Create: `src/main/java/org/example/util/PageResult.java` — immutable pagination output envelope (items + counts + nav flags).
- Create: `src/main/java/org/example/util/PaginationUtils.java` — static normalization/parsing helpers; the only place that reads raw `page`/`pageSize`/`sortBy`/`sortDir` request parameters.
- Create: `src/main/webapp/WEB-INF/tags/pagination.tag` — shared footer UI (item-range text, page-size select, compact numbered pager, prev/next), reused by every JSP in Phase 2/3.
- Create: `src/test/java/org/example/util/PaginationUtilsTest.java`
- Create: `src/test/java/org/example/util/PageResultTest.java`

---

### Task 1: `PaginationRequest`

**Files:**
- Create: `src/main/java/org/example/util/PaginationRequest.java`
- Test: `src/test/java/org/example/util/PaginationRequestTest.java`

**Interfaces:**
- Produces: `PaginationRequest.of(int page, int pageSize, String sortBy, String sortDirection)` (package-visible factory used only by `PaginationUtils`); instance methods `getPage()`, `getPageSize()`, `getOffset()` (returns `long`), `getSortBy()`, `getSortDirection()`, `withPage(int newPage)`.

- [ ] **Step 1: Write the failing test**

```java
package org.example.util;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertEquals;

class PaginationRequestTest {
    @Test
    void of_computesZeroBasedOffsetFromOneBasedPage() {
        PaginationRequest req = PaginationRequest.of(1, 20, "createdAt", "DESC");
        assertEquals(0L, req.getOffset());
    }

    @Test
    void of_page3PageSize20_offsetIs40() {
        PaginationRequest req = PaginationRequest.of(3, 20, "createdAt", "DESC");
        assertEquals(40L, req.getOffset());
    }

    @Test
    void withPage_returnsNewInstanceWithUpdatedOffsetKeepingOtherFields() {
        PaginationRequest req = PaginationRequest.of(5, 10, "total", "ASC");
        PaginationRequest moved = req.withPage(2);
        assertEquals(2, moved.getPage());
        assertEquals(10L, moved.getOffset());
        assertEquals(10, moved.getPageSize());
        assertEquals("total", moved.getSortBy());
        assertEquals("ASC", moved.getSortDirection());
        assertEquals(5, req.getPage(), "original instance must stay unchanged");
    }

    @Test
    void of_largePageAndPageSize_offsetDoesNotOverflowInt() {
        PaginationRequest req = PaginationRequest.of(1_000_000, 100, "id", "DESC");
        assertEquals(99_999_900L, req.getOffset());
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `mvn -q -Dtest=PaginationRequestTest test`
Expected: FAIL — compilation error, `PaginationRequest` does not exist.

- [ ] **Step 3: Write minimal implementation**

```java
package org.example.util;

/**
 * Normalized, immutable pagination input. Always construct via
 * {@link PaginationUtils} so page/pageSize/sortDirection are guaranteed valid —
 * never call {@link #of} directly from a servlet/DAO with raw request params.
 */
public final class PaginationRequest {

    private final int page;
    private final int pageSize;
    private final String sortBy;
    private final String sortDirection;

    private PaginationRequest(int page, int pageSize, String sortBy, String sortDirection) {
        this.page = page;
        this.pageSize = pageSize;
        this.sortBy = sortBy;
        this.sortDirection = sortDirection;
    }

    public static PaginationRequest of(int page, int pageSize, String sortBy, String sortDirection) {
        return new PaginationRequest(page, pageSize, sortBy, sortDirection);
    }

    public int getPage() {
        return page;
    }

    public int getPageSize() {
        return pageSize;
    }

    public long getOffset() {
        return (long) (page - 1) * (long) pageSize;
    }

    public String getSortBy() {
        return sortBy;
    }

    public String getSortDirection() {
        return sortDirection;
    }

    public PaginationRequest withPage(int newPage) {
        return new PaginationRequest(newPage, pageSize, sortBy, sortDirection);
    }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `mvn -q -Dtest=PaginationRequestTest test`
Expected: PASS (4 tests)

- [ ] **Step 5: Commit**

```bash
git add src/main/java/org/example/util/PaginationRequest.java src/test/java/org/example/util/PaginationRequestTest.java
git commit -m "feat: add PaginationRequest for normalized pagination input"
```

---

### Task 2: `PageResult<T>`

**Files:**
- Create: `src/main/java/org/example/util/PageResult.java`
- Create: `src/test/java/org/example/util/PageResultTest.java`

**Interfaces:**
- Consumes: nothing (standalone).
- Produces: `PageResult.of(List<T> items, int page, int pageSize, long totalItems)`; getters `getItems()`, `getPage()`, `getPageSize()`, `getTotalItems()` (`long`), `getTotalPages()` (`int`), `isHasPrevious()`, `isHasNext()`, `getFromItem()` (`long`), `getToItem()` (`long`). `isHasPrevious()`/`isHasNext()` must be readable in JSP EL as `${result.hasPrevious}` / `${result.hasNext}` (standard JavaBean boolean property rule — EL treats `isX()` as property `x`).

- [ ] **Step 1: Write the failing test**

```java
package org.example.util;

import org.junit.jupiter.api.Test;
import java.util.List;
import static org.junit.jupiter.api.Assertions.*;

class PageResultTest {

    @Test
    void of_emptyTotalItems_totalPagesZeroNoPrevNoNextFromToZero() {
        PageResult<String> result = PageResult.of(List.of(), 1, 20, 0L);
        assertEquals(0, result.getTotalPages());
        assertFalse(result.isHasPrevious());
        assertFalse(result.isHasNext());
        assertEquals(0L, result.getFromItem());
        assertEquals(0L, result.getToItem());
    }

    @Test
    void of_middlePage_hasPreviousAndHasNextBothTrue() {
        PageResult<String> result = PageResult.of(List.of("a", "b"), 2, 20, 45L);
        assertEquals(3, result.getTotalPages());
        assertTrue(result.isHasPrevious());
        assertTrue(result.isHasNext());
        assertEquals(21L, result.getFromItem());
        assertEquals(40L, result.getToItem());
    }

    @Test
    void of_lastPagePartial_toItemClampedToTotalItemsNotPageSize() {
        PageResult<String> result = PageResult.of(List.of("a", "b", "c"), 3, 20, 43L);
        assertEquals(3, result.getTotalPages());
        assertFalse(result.isHasNext());
        assertEquals(41L, result.getFromItem());
        assertEquals(43L, result.getToItem());
    }

    @Test
    void of_firstPage_hasPreviousFalse() {
        PageResult<String> result = PageResult.of(List.of("a"), 1, 20, 5L);
        assertFalse(result.isHasPrevious());
        assertTrue(result.isHasNext());
    }

    @Test
    void of_singlePageExactlyFillsPageSize_hasNextFalse() {
        PageResult<String> result = PageResult.of(List.of("a", "b"), 1, 2, 2L);
        assertEquals(1, result.getTotalPages());
        assertFalse(result.isHasNext());
        assertFalse(result.isHasPrevious());
    }

    @Test
    void of_itemsListIsUnmodifiable() {
        PageResult<String> result = PageResult.of(new java.util.ArrayList<>(List.of("a")), 1, 20, 1L);
        assertThrows(UnsupportedOperationException.class, () -> result.getItems().add("b"));
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `mvn -q -Dtest=PageResultTest test`
Expected: FAIL — compilation error, `PageResult` does not exist.

- [ ] **Step 3: Write minimal implementation**

```java
package org.example.util;

import java.util.Collections;
import java.util.List;

/**
 * Immutable server-side pagination result envelope. Build only via {@link #of}
 * so fromItem/toItem/totalPages/hasPrevious/hasNext stay internally consistent.
 */
public final class PageResult<T> {

    private final List<T> items;
    private final int page;
    private final int pageSize;
    private final long totalItems;
    private final int totalPages;
    private final boolean hasPrevious;
    private final boolean hasNext;
    private final long fromItem;
    private final long toItem;

    private PageResult(List<T> items, int page, int pageSize, long totalItems,
                        int totalPages, boolean hasPrevious, boolean hasNext,
                        long fromItem, long toItem) {
        this.items = items;
        this.page = page;
        this.pageSize = pageSize;
        this.totalItems = totalItems;
        this.totalPages = totalPages;
        this.hasPrevious = hasPrevious;
        this.hasNext = hasNext;
        this.fromItem = fromItem;
        this.toItem = toItem;
    }

    public static <T> PageResult<T> of(List<T> items, int page, int pageSize, long totalItems) {
        int totalPages = totalItems == 0 ? 0 : (int) Math.ceil((double) totalItems / (double) pageSize);
        long fromItem = totalItems == 0 ? 0L : (long) (page - 1) * (long) pageSize + 1L;
        long toItem = totalItems == 0 ? 0L : Math.min((long) page * (long) pageSize, totalItems);
        return new PageResult<>(
                Collections.unmodifiableList(items),
                page,
                pageSize,
                totalItems,
                totalPages,
                page > 1,
                page < totalPages,
                fromItem,
                toItem
        );
    }

    public List<T> getItems() {
        return items;
    }

    public int getPage() {
        return page;
    }

    public int getPageSize() {
        return pageSize;
    }

    public long getTotalItems() {
        return totalItems;
    }

    public int getTotalPages() {
        return totalPages;
    }

    public boolean isHasPrevious() {
        return hasPrevious;
    }

    public boolean isHasNext() {
        return hasNext;
    }

    public long getFromItem() {
        return fromItem;
    }

    public long getToItem() {
        return toItem;
    }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `mvn -q -Dtest=PageResultTest test`
Expected: PASS (6 tests)

- [ ] **Step 5: Commit**

```bash
git add src/main/java/org/example/util/PageResult.java src/test/java/org/example/util/PageResultTest.java
git commit -m "feat: add PageResult envelope for server-side pagination output"
```

---

### Task 3: `PaginationUtils`

**Files:**
- Create: `src/main/java/org/example/util/PaginationUtils.java`
- Create: `src/test/java/org/example/util/PaginationUtilsTest.java`

**Interfaces:**
- Consumes: `PaginationRequest.of(...)` (Task 1), `jakarta.servlet.http.HttpServletRequest` (framework type, already on the classpath via `jakarta.servlet-api`, see `pom.xml`).
- Produces: `PaginationUtils.fromRequest(HttpServletRequest)`, `PaginationUtils.fromRequest(HttpServletRequest, int defaultPageSize)`, `PaginationUtils.normalizePage(int)`, `PaginationUtils.normalizePageSize(int, int defaultPageSize)`, `PaginationUtils.normalizeSortDirection(String)`, `PaginationUtils.clampPage(int requestedPage, int totalPages)`, `PaginationUtils.resolveSortColumn(Map<String,String> whitelist, String requestedKey, String defaultColumn)`. Constants: `DEFAULT_PAGE=1`, `DEFAULT_PAGE_SIZE=20`, `ALLOWED_PAGE_SIZES={10,20,50}`, `MAX_PAGE_SIZE=100`.

- [ ] **Step 1: Write the failing test**

```java
package org.example.util;

import jakarta.servlet.http.HttpServletRequest;
import org.junit.jupiter.api.Test;
import java.util.Map;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class PaginationUtilsTest {

    // ---- normalizePage ----

    @Test
    void normalizePage_zeroOrNegative_returnsOne() {
        assertEquals(1, PaginationUtils.normalizePage(0));
        assertEquals(1, PaginationUtils.normalizePage(-5));
    }

    @Test
    void normalizePage_positive_returnsSameValue() {
        assertEquals(7, PaginationUtils.normalizePage(7));
    }

    // ---- normalizePageSize ----

    @Test
    void normalizePageSize_allowedValues_returnedAsIs() {
        assertEquals(10, PaginationUtils.normalizePageSize(10, 20));
        assertEquals(20, PaginationUtils.normalizePageSize(20, 20));
        assertEquals(50, PaginationUtils.normalizePageSize(50, 20));
    }

    @Test
    void normalizePageSize_disallowedValue_fallsBackToDefault() {
        assertEquals(20, PaginationUtils.normalizePageSize(37, 20));
        assertEquals(20, PaginationUtils.normalizePageSize(-1, 20));
        assertEquals(50, PaginationUtils.normalizePageSize(9999, 50));
    }

    @Test
    void normalizePageSize_neverExceedsMaxPageSize() {
        assertTrue(PaginationUtils.normalizePageSize(9999, 20) <= PaginationUtils.MAX_PAGE_SIZE);
    }

    // ---- normalizeSortDirection ----

    @Test
    void normalizeSortDirection_asc_returnsUppercaseASC() {
        assertEquals("ASC", PaginationUtils.normalizeSortDirection("asc"));
        assertEquals("ASC", PaginationUtils.normalizeSortDirection("ASC"));
        assertEquals("ASC", PaginationUtils.normalizeSortDirection("Asc"));
    }

    @Test
    void normalizeSortDirection_anythingElseOrNull_returnsDESC() {
        assertEquals("DESC", PaginationUtils.normalizeSortDirection("desc"));
        assertEquals("DESC", PaginationUtils.normalizeSortDirection(null));
        assertEquals("DESC", PaginationUtils.normalizeSortDirection("DROP TABLE x"));
    }

    // ---- clampPage ----

    @Test
    void clampPage_zeroTotalPages_returnsOne() {
        assertEquals(1, PaginationUtils.clampPage(5, 0));
    }

    @Test
    void clampPage_requestedBeyondTotal_returnsTotalPages() {
        assertEquals(10, PaginationUtils.clampPage(999, 10));
    }

    @Test
    void clampPage_requestedBelowOne_returnsOne() {
        assertEquals(1, PaginationUtils.clampPage(-3, 10));
    }

    @Test
    void clampPage_requestedWithinRange_returnsSameValue() {
        assertEquals(4, PaginationUtils.clampPage(4, 10));
    }

    // ---- resolveSortColumn ----

    @Test
    void resolveSortColumn_keyInWhitelist_returnsMappedSqlColumn() {
        Map<String, String> whitelist = Map.of("createdAt", "hd.NgayLap", "total", "hd.TongThanhToan");
        assertEquals("hd.NgayLap", PaginationUtils.resolveSortColumn(whitelist, "createdAt", "hd.NgayLap"));
    }

    @Test
    void resolveSortColumn_keyNotInWhitelist_returnsDefaultColumn() {
        Map<String, String> whitelist = Map.of("createdAt", "hd.NgayLap");
        assertEquals("hd.NgayLap", PaginationUtils.resolveSortColumn(whitelist, "'; DROP TABLE HoaDon; --", "hd.NgayLap"));
    }

    @Test
    void resolveSortColumn_nullKey_returnsDefaultColumn() {
        Map<String, String> whitelist = Map.of("createdAt", "hd.NgayLap");
        assertEquals("hd.NgayLap", PaginationUtils.resolveSortColumn(whitelist, null, "hd.NgayLap"));
    }

    // ---- fromRequest ----

    @Test
    void fromRequest_validParams_buildsNormalizedRequest() {
        HttpServletRequest req = mock(HttpServletRequest.class);
        when(req.getParameter("page")).thenReturn("3");
        when(req.getParameter("pageSize")).thenReturn("50");
        when(req.getParameter("sortBy")).thenReturn("total");
        when(req.getParameter("sortDir")).thenReturn("asc");

        PaginationRequest result = PaginationUtils.fromRequest(req);

        assertEquals(3, result.getPage());
        assertEquals(50, result.getPageSize());
        assertEquals("total", result.getSortBy());
        assertEquals("ASC", result.getSortDirection());
    }

    @Test
    void fromRequest_missingOrGarbageParams_fallsBackToDefaults() {
        HttpServletRequest req = mock(HttpServletRequest.class);
        when(req.getParameter("page")).thenReturn("not-a-number");
        when(req.getParameter("pageSize")).thenReturn(null);
        when(req.getParameter("sortBy")).thenReturn(null);
        when(req.getParameter("sortDir")).thenReturn(null);

        PaginationRequest result = PaginationUtils.fromRequest(req);

        assertEquals(1, result.getPage());
        assertEquals(20, result.getPageSize());
        assertEquals("DESC", result.getSortDirection());
    }

    @Test
    void fromRequest_negativePageParam_normalizesToOne() {
        HttpServletRequest req = mock(HttpServletRequest.class);
        when(req.getParameter("page")).thenReturn("-7");
        when(req.getParameter("pageSize")).thenReturn("20");

        PaginationRequest result = PaginationUtils.fromRequest(req);

        assertEquals(1, result.getPage());
    }

    @Test
    void fromRequest_customDefaultPageSize_usedWhenPageSizeMissing() {
        HttpServletRequest req = mock(HttpServletRequest.class);
        when(req.getParameter("page")).thenReturn(null);
        when(req.getParameter("pageSize")).thenReturn(null);

        PaginationRequest result = PaginationUtils.fromRequest(req, 50);

        assertEquals(50, result.getPageSize());
    }
}
```

This is the one test class that needs a mocked `HttpServletRequest`. **This repo has no Mockito dependency** (confirmed absent from `pom.xml` during audit). Add it as a `test`-scope dependency before writing the implementation.

- [ ] **Step 2: Add Mockito test dependency**

Read `pom.xml`, find the `<dependencies>` closing area near the existing `<dependency>` block for JUnit Jupiter (search for `junit-jupiter`), and add immediately after it:

```xml
        <!-- Mockito - for mocking HttpServletRequest in PaginationUtilsTest -->
        <dependency>
            <groupId>org.mockito</groupId>
            <artifactId>mockito-core</artifactId>
            <version>5.11.0</version>
            <scope>test</scope>
        </dependency>
```

- [ ] **Step 3: Run test to verify it fails**

Run: `mvn -q -Dtest=PaginationUtilsTest test`
Expected: FAIL — compilation error, `PaginationUtils` does not exist (Mockito itself should resolve once Step 2 is done; if `mvn` reports it cannot download `mockito-core`, stop and report the network/repo issue rather than guessing a different version).

- [ ] **Step 4: Write minimal implementation**

```java
package org.example.util;

import jakarta.servlet.http.HttpServletRequest;
import java.util.Map;

/**
 * Single entry point for turning raw, untrusted request parameters into a
 * normalized {@link PaginationRequest}. Servlets must call {@link #fromRequest}
 * instead of reading "page"/"pageSize"/"sortBy"/"sortDir" parameters themselves.
 */
public final class PaginationUtils {

    public static final int DEFAULT_PAGE = 1;
    public static final int DEFAULT_PAGE_SIZE = 20;
    public static final int[] ALLOWED_PAGE_SIZES = {10, 20, 50};
    public static final int MAX_PAGE_SIZE = 100;
    public static final String DEFAULT_SORT_DIRECTION = "DESC";

    private PaginationUtils() {
    }

    public static PaginationRequest fromRequest(HttpServletRequest request) {
        return fromRequest(request, DEFAULT_PAGE_SIZE);
    }

    public static PaginationRequest fromRequest(HttpServletRequest request, int defaultPageSize) {
        int page = parseIntOrDefault(request.getParameter("page"), DEFAULT_PAGE);
        int pageSize = parseIntOrDefault(request.getParameter("pageSize"), defaultPageSize);
        String sortBy = request.getParameter("sortBy");
        String sortDir = request.getParameter("sortDir");
        return of(page, pageSize, sortBy, sortDir, defaultPageSize);
    }

    public static PaginationRequest of(int page, int pageSize, String sortBy, String sortDirection) {
        return of(page, pageSize, sortBy, sortDirection, DEFAULT_PAGE_SIZE);
    }

    public static PaginationRequest of(int page, int pageSize, String sortBy, String sortDirection, int defaultPageSize) {
        int normalizedPage = normalizePage(page);
        int normalizedPageSize = normalizePageSize(pageSize, defaultPageSize);
        String normalizedSortDir = normalizeSortDirection(sortDirection);
        return PaginationRequest.of(normalizedPage, normalizedPageSize, sortBy, normalizedSortDir);
    }

    public static int normalizePage(int page) {
        return page < 1 ? DEFAULT_PAGE : page;
    }

    public static int normalizePageSize(int pageSize, int defaultPageSize) {
        for (int allowed : ALLOWED_PAGE_SIZES) {
            if (allowed == pageSize) {
                return Math.min(allowed, MAX_PAGE_SIZE);
            }
        }
        return Math.min(defaultPageSize, MAX_PAGE_SIZE);
    }

    public static String normalizeSortDirection(String sortDirection) {
        if ("asc".equalsIgnoreCase(sortDirection)) {
            return "ASC";
        }
        return DEFAULT_SORT_DIRECTION;
    }

    public static int clampPage(int requestedPage, int totalPages) {
        if (totalPages <= 0) {
            return 1;
        }
        if (requestedPage > totalPages) {
            return totalPages;
        }
        if (requestedPage < 1) {
            return 1;
        }
        return requestedPage;
    }

    public static String resolveSortColumn(Map<String, String> whitelist, String requestedKey, String defaultColumn) {
        if (requestedKey == null || !whitelist.containsKey(requestedKey)) {
            return defaultColumn;
        }
        return whitelist.get(requestedKey);
    }

    private static int parseIntOrDefault(String value, int defaultValue) {
        if (value == null || value.isBlank()) {
            return defaultValue;
        }
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }
}
```

- [ ] **Step 5: Run test to verify it passes**

Run: `mvn -q -Dtest=PaginationUtilsTest test`
Expected: PASS (17 tests)

- [ ] **Step 6: Run the full Phase 1 test suite together**

Run: `mvn -q -Dtest=PaginationRequestTest,PageResultTest,PaginationUtilsTest test`
Expected: PASS (27 tests total, 0 failures)

- [ ] **Step 7: Commit**

```bash
git add pom.xml src/main/java/org/example/util/PaginationUtils.java src/test/java/org/example/util/PaginationUtilsTest.java
git commit -m "feat: add PaginationUtils normalization helper + mockito test dep"
```

---

### Task 4: Shared JSP pagination tag file

**Files:**
- Create: `src/main/webapp/WEB-INF/tags/pagination.tag`

**Interfaces:**
- Consumes: `org.example.util.PageResult` (Task 2) exposed on the JSP via EL (any request-scoped attribute of this type), a `baseUrl` string (context-relative path, e.g. `/manager/hoa-don`), an optional `extraParams` `Map<String,String>` of filter values to preserve across page links (must NOT include `page`/`pageSize` — the tag adds those itself), a required `ariaLabel` string.
- Produces: HTML footer markup — left side "Hiển thị X–Y trong Z kết quả" text, right side page-size `<select>` (values 10/20/50) + compact pager (‹ Trước, numbered buttons with `…` ellipsis, Sau ›). Renders nothing (returns empty) when `pageResult.totalItems == 0` — callers still gate visibility of the whole footer block with `<c:if test="${pageResult.totalItems > 0}">` around the tag call for defense in depth, but the tag itself is also safe to call unconditionally.

No automated test for this file (JSP tag files are not unit-testable with JUnit in this stack) — Task 5 below is the manual verification step. Every module task in Phase 2/Phase 3 that calls this tag doubles as further verification.

- [ ] **Step 1: Create the tag file**

```jsp
<%@ tag description="Shared server-side pagination footer (item-range text, page-size select, compact numbered pager)" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%@ attribute name="pageResult" required="true" type="org.example.util.PageResult" %>
<%@ attribute name="baseUrl" required="true" type="java.lang.String" %>
<%@ attribute name="extraParams" required="false" type="java.util.Map" %>
<%@ attribute name="ariaLabel" required="true" type="java.lang.String" %>

<c:if test="${pageResult.totalItems > 0}">
  <nav class="flex flex-col sm:flex-row items-center justify-between gap-3 px-4 py-3 border-t border-gray-200 text-sm text-gray-600" aria-label="${ariaLabel}">

    <div>
      Hiển thị <span class="font-medium text-gray-800">${pageResult.fromItem}</span>–<span class="font-medium text-gray-800">${pageResult.toItem}</span>
      trong <span class="font-medium text-gray-800">${pageResult.totalItems}</span> kết quả
    </div>

    <div class="flex items-center gap-4">

      <form method="get" action="${pageContext.request.contextPath}${baseUrl}" class="flex items-center gap-2">
        <c:forEach var="entry" items="${extraParams}">
          <c:if test="${not empty entry.value}">
            <input type="hidden" name="${entry.key}" value="${entry.value}" />
          </c:if>
        </c:forEach>
        <input type="hidden" name="page" value="1" />
        <label for="pageSizeSelect" class="text-gray-500">Mỗi trang:</label>
        <select id="pageSizeSelect" name="pageSize" onchange="this.form.submit()"
                class="border border-gray-300 rounded-md text-sm px-2 py-1 focus:outline-none focus:ring-2 focus:ring-purple-500">
          <option value="10" ${pageResult.pageSize == 10 ? 'selected' : ''}>10</option>
          <option value="20" ${pageResult.pageSize == 20 ? 'selected' : ''}>20</option>
          <option value="50" ${pageResult.pageSize == 50 ? 'selected' : ''}>50</option>
        </select>
      </form>

      <c:if test="${pageResult.totalPages > 1}">
        <ul class="flex items-center gap-1">

          <li>
            <c:choose>
              <c:when test="${pageResult.hasPrevious}">
                <c:url var="prevUrl" value="${baseUrl}">
                  <c:param name="page" value="${pageResult.page - 1}" />
                  <c:param name="pageSize" value="${pageResult.pageSize}" />
                  <c:forEach var="entry" items="${extraParams}">
                    <c:if test="${not empty entry.value}">
                      <c:param name="${entry.key}" value="${entry.value}" />
                    </c:if>
                  </c:forEach>
                </c:url>
                <a href="${prevUrl}" class="px-2 py-1 rounded-md hover:bg-purple-100 text-purple-700">‹ Trước</a>
              </c:when>
              <c:otherwise>
                <span class="px-2 py-1 rounded-md text-gray-300" aria-disabled="true">‹ Trước</span>
              </c:otherwise>
            </c:choose>
          </li>

          <c:choose>
            <c:when test="${pageResult.totalPages <= 7}">
              <c:forEach var="p" begin="1" end="${pageResult.totalPages}">
                <li>
                  <c:url var="pUrl" value="${baseUrl}">
                    <c:param name="page" value="${p}" />
                    <c:param name="pageSize" value="${pageResult.pageSize}" />
                    <c:forEach var="entry" items="${extraParams}">
                      <c:if test="${not empty entry.value}">
                        <c:param name="${entry.key}" value="${entry.value}" />
                      </c:if>
                    </c:forEach>
                  </c:url>
                  <c:choose>
                    <c:when test="${p == pageResult.page}">
                      <span class="px-3 py-1 rounded-md bg-purple-600 text-white font-semibold" aria-current="page">${p}</span>
                    </c:when>
                    <c:otherwise>
                      <a href="${pUrl}" class="px-3 py-1 rounded-md hover:bg-purple-100 text-purple-700" aria-label="Đi đến trang ${p}">${p}</a>
                    </c:otherwise>
                  </c:choose>
                </li>
              </c:forEach>
            </c:when>
            <c:otherwise>
              <c:set var="lastRendered" value="${0}" />
              <c:forEach var="p" begin="1" end="${pageResult.totalPages}">
                <c:if test="${p == 1 or p == pageResult.totalPages or (p >= pageResult.page - 2 and p <= pageResult.page + 2)}">
                  <c:if test="${p - lastRendered > 1}">
                    <li><span class="px-2 text-gray-400">…</span></li>
                  </c:if>
                  <li>
                    <c:url var="pUrl" value="${baseUrl}">
                      <c:param name="page" value="${p}" />
                      <c:param name="pageSize" value="${pageResult.pageSize}" />
                      <c:forEach var="entry" items="${extraParams}">
                        <c:if test="${not empty entry.value}">
                          <c:param name="${entry.key}" value="${entry.value}" />
                        </c:if>
                      </c:forEach>
                    </c:url>
                    <c:choose>
                      <c:when test="${p == pageResult.page}">
                        <span class="px-3 py-1 rounded-md bg-purple-600 text-white font-semibold" aria-current="page">${p}</span>
                      </c:when>
                      <c:otherwise>
                        <a href="${pUrl}" class="px-3 py-1 rounded-md hover:bg-purple-100 text-purple-700" aria-label="Đi đến trang ${p}">${p}</a>
                      </c:otherwise>
                    </c:choose>
                  </li>
                  <c:set var="lastRendered" value="${p}" />
                </c:if>
              </c:forEach>
            </c:otherwise>
          </c:choose>

          <li>
            <c:choose>
              <c:when test="${pageResult.hasNext}">
                <c:url var="nextUrl" value="${baseUrl}">
                  <c:param name="page" value="${pageResult.page + 1}" />
                  <c:param name="pageSize" value="${pageResult.pageSize}" />
                  <c:forEach var="entry" items="${extraParams}">
                    <c:if test="${not empty entry.value}">
                      <c:param name="${entry.key}" value="${entry.value}" />
                    </c:if>
                  </c:forEach>
                </c:url>
                <a href="${nextUrl}" class="px-2 py-1 rounded-md hover:bg-purple-100 text-purple-700">Sau ›</a>
              </c:when>
              <c:otherwise>
                <span class="px-2 py-1 rounded-md text-gray-300" aria-disabled="true">Sau ›</span>
              </c:otherwise>
            </c:choose>
          </li>

        </ul>
      </c:if>

    </div>
  </nav>
</c:if>
```

Notes for the implementer:
- `<c:url>`/`<c:param>` (not raw `${...}` string concatenation) is used throughout — this matches the safe pattern already in `manager/AuditLog.jsp` and avoids the UTF-8/`&`-escaping bug found in `manager/QuanLyHoaDon.jsp`'s hand-rolled pager during audit.
- The ellipsis algorithm keeps a `lastRendered` running variable; it inserts `…` whenever the gap between the previous rendered page number and the current one is more than 1. This produces exactly `1 … 6 7 [8] 9 10 … 20` for `page=8, totalPages=20`.
- Page-size `<select>` submits via a plain GET `<form>` (no JS framework, no AJAX) — matches the "ưu tiên GET form, không ép AJAX" constraint. It resets `page` to 1 on every page-size change (hidden `<input name="page" value="1">`), per the "khi đổi filter → reset page về 1" rule (page-size counts as a filter change here since the current page's offset becomes meaningless under a new page size).
- Every one of the module tasks in Phase 2/3 is responsible for putting `q`/`status`/`dateFrom`/etc. into the `extraParams` map it passes to this tag — the tag itself has zero knowledge of any module's specific filter fields.

- [ ] **Step 2: Manual verification (temporary throwaway JSP)**

Create a scratch file `src/main/webapp/admin/_pagination_tag_smoketest.jsp` (delete it in Step 4 — never leave it in the repo):

```jsp
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib tagdir="/WEB-INF/tags" prefix="v" %>
<%
    java.util.List<String> items = java.util.List.of("a","b","c","d","e","f","g","h");
    org.example.util.PageResult<String> pr = org.example.util.PageResult.of(items, 8, 5, 100L);
    request.setAttribute("pageResult", pr);
    java.util.Map<String,String> extra = new java.util.HashMap<>();
    extra.put("status", "PAID");
    extra.put("q", "hóa đơn tiếng Việt");
    request.setAttribute("extra", extra);
%>
<html><body>
<v:pagination pageResult="${pageResult}" baseUrl="/admin/_pagination_tag_smoketest" extraParams="${extra}" ariaLabel="Smoke test pager" />
</body></html>
```

Run `.\start_server.bat`, open `http://localhost:8080/<context>/admin/_pagination_tag_smoketest.jsp` in the browser (no login required — this scratch page is outside any `@WebFilter` path pattern), and visually confirm via the Browser tools:
- Text reads "Hiển thị 36–40 trong 100 kết quả".
- Page-size select shows 5... — **note:** 5 is not one of {10,20,50}; if the `<select>` renders with none selected, that's expected and fine for this smoke test (the real modules always pass 10/20/50). Re-run with `pageSize=10` in the scratchpad if you want a select match.
- Pager shows `1 … 6 7 [8] 9 10 … 20` with 8 highlighted purple, `aria-current="page"` present on it (inspect via `read_page`).
- Clicking a page number navigates and preserves `status=PAID&q=hóa đơn tiếng Việt` in the URL, correctly UTF-8-encoded (check `read_network_requests` or the address bar — Vietnamese text must not get mangled).
- `‹ Trước` and page `9` links work; on page 1 (`?page=1&pageSize=5&status=PAID&q=...`), confirm `‹ Trước` renders as a non-clickable `<span aria-disabled="true">`.

- [ ] **Step 3: Fix any issues found, re-verify**

If ellipsis placement, encoding, or ARIA attributes are wrong, fix `pagination.tag` and reload (no server restart needed for JSP/tag file changes under Tomcat's default JSP reloading).

- [ ] **Step 4: Delete the scratch JSP and commit the tag file**

```bash
rm src/main/webapp/admin/_pagination_tag_smoketest.jsp
git add src/main/webapp/WEB-INF/tags/pagination.tag
git status --short   # confirm the scratch jsp is NOT staged (it should no longer exist)
git commit -m "feat: add shared WEB-INF/tags/pagination.tag footer component"
```

---

### Task 5: Full Phase 1 verification

- [ ] **Step 1: Run the whole test suite**

Run: `mvn test`
Expected: BUILD SUCCESS, all existing tests still pass plus the 27 new ones from Task 1-3.

- [ ] **Step 2: Full package build**

Run: `mvn package`
Expected: BUILD SUCCESS, `target/*.war` produced (confirms the new `.tag` file under `webapp/WEB-INF/tags` gets bundled into the WAR — check with `jar tf target/<artifact>.war | grep pagination.tag`).

- [ ] **Step 3: Confirm no existing servlet/DAO/JSP was modified**

Run: `git diff --stat main` (or `git status --short` if working directly on `main`) and confirm only the 6 new files (+ the `pom.xml` Mockito addition) appear — zero modifications to any file under `controller/`, `dao/`, or existing `webapp/**/*.jsp`.

- [ ] **Step 4: Report Phase 1 done, do not start Phase 2 in the same uninterrupted run**

Per the parent task's own instruction ("Không chờ sửa toàn hệ thống mới test" / "Sau mỗi module: Compile, Test, Browser verification"), stop here and get a green build + the tag-file smoke test confirmed before starting `2026-07-15-system-wide-pagination-phase2-priority-modules.md`.
