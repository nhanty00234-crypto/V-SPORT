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
