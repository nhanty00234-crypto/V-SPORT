package org.example.service;

import org.example.dao.DanhGiaDAO;
import org.example.model.DanhGia;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;
import org.mockito.ArgumentCaptor;
import org.mockito.Mockito;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

class DanhGiaServiceTest {

    private DanhGiaDAO dao;
    private DanhGiaService service;

    @BeforeEach
    void setUp() {
        dao = Mockito.mock(DanhGiaDAO.class);
        service = new DanhGiaService(dao);
    }

    // --- Incomplete booking blocked ---
    @Test
    void submitReview_blockedWhenBookingNotCompleted() {
        when(dao.isBookingCompletedByCustomer(10, 1)).thenReturn(false);
        var r = service.submitReview(10, 1, 4, "Tốt lắm");
        assertFalse(r.success);
        verify(dao, never()).insert(any());
    }

    // --- Other user's booking blocked ---
    @Test
    void submitReview_blockedForOtherUsersBooking() {
        // isBookingCompletedByCustomer checks both datSanId AND accountId — returns false for wrong owner
        when(dao.isBookingCompletedByCustomer(10, 99)).thenReturn(false);
        var r = service.submitReview(10, 99, 5, "Great");
        assertFalse(r.success);
        verify(dao, never()).insert(any());
    }

    // --- Stars must be 1–5 ---
    @ParameterizedTest
    @ValueSource(ints = {0, -1, 6, 100})
    void submitReview_invalidStarsRejected(int stars) {
        var r = service.submitReview(10, 1, stars, "Nội dung");
        assertFalse(r.success);
        assertFalse(r.errors.isEmpty());
        verify(dao, never()).isBookingCompletedByCustomer(anyInt(), anyInt());
    }

    // --- No second review per booking ---
    @Test
    void submitReview_duplicateRejected() {
        when(dao.isBookingCompletedByCustomer(10, 1)).thenReturn(true);
        when(dao.existsByDatSanAndAccount(10, 1)).thenReturn(true);
        var r = service.submitReview(10, 1, 4, "Tốt");
        assertFalse(r.success);
        verify(dao, never()).insert(any());
    }

    // --- Empty comment rejected ---
    @Test
    void submitReview_emptyCommentRejected() {
        var r = service.submitReview(10, 1, 3, "");
        assertFalse(r.success);
        assertTrue(r.errors.stream().anyMatch(e -> e.contains("Bình luận")));
    }

    // --- XSS strategy: raw text is stored; JSP layer escapes with c:out ---
    @Test
    void submitReview_rawTextStoredForOutputEscape() {
        when(dao.isBookingCompletedByCustomer(10, 1)).thenReturn(true);
        when(dao.existsByDatSanAndAccount(10, 1)).thenReturn(false);
        when(dao.insert(any())).thenReturn(1);

        service.submitReview(10, 1, 5, "<script>alert('xss')</script>");

        ArgumentCaptor<DanhGia> cap = ArgumentCaptor.forClass(DanhGia.class);
        verify(dao).insert(cap.capture());
        String stored = cap.getValue().getBinhLuan();
        // Raw text is stored; c:out in JSP handles escaping at render time.
        // No double-encoding: stored value must NOT be pre-escaped.
        assertFalse(stored.contains("&lt;"), "Pre-escaped HTML in DB causes double-encoding");
        assertTrue(stored.contains("<script>"), "Raw content must be preserved for c:out escaping");
    }

    // --- Valid review succeeds ---
    @Test
    void submitReview_validInputSucceeds() {
        when(dao.isBookingCompletedByCustomer(10, 1)).thenReturn(true);
        when(dao.existsByDatSanAndAccount(10, 1)).thenReturn(false);
        when(dao.insert(any())).thenReturn(5);

        var r = service.submitReview(10, 1, 4, "Sân sạch đẹp");
        assertTrue(r.success);
    }

    // --- Comment over 255 chars is rejected ---
    @Test
    void submitReview_commentTooLongRejected() {
        String longComment = "A".repeat(256);
        var r = service.submitReview(10, 1, 3, longComment);
        assertFalse(r.success);
        assertTrue(r.errors.stream().anyMatch(e -> e.contains("255")));
    }
}
