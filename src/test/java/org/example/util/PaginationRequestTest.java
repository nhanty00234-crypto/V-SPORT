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
