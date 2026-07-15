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
        PageResult<String> result = PageResult.of(List.of("a"), 1, 20, 25L);
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
