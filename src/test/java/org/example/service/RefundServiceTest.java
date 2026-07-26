package org.example.service;

import org.example.dao.HoanTienDAO;
import org.example.model.Hoantien;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.Mockito;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

class RefundServiceTest {

    private HoanTienDAO hoanTienDAO;
    private NotificationService notificationService;
    private RefundService refundService;
    private Connection conn;

    @BeforeEach
    void setUp() {
        hoanTienDAO = Mockito.mock(HoanTienDAO.class);
        notificationService = Mockito.mock(NotificationService.class);
        refundService = new RefundService(hoanTienDAO, notificationService);
        conn = Mockito.mock(Connection.class);
    }

    // --- createRefund: idempotent — second call with same hoaDonId is a no-op ---
    @Test
    void createRefund_idempotentWhenAlreadyExists() throws SQLException {
        when(hoanTienDAO.existsByHoaDonId(5)).thenReturn(true);
        var r = refundService.createRefund(conn, 5, 1, BigDecimal.valueOf(100_000), "Hủy sân");
        assertTrue(r.success);
        verify(hoanTienDAO, never()).insert(any(Connection.class), any(Hoantien.class));
    }

    // --- createRefund: inserts when no prior refund for invoice ---
    @Test
    void createRefund_insertsWhenNoneExists() throws SQLException {
        when(hoanTienDAO.existsByHoaDonId(10)).thenReturn(false);
        when(hoanTienDAO.insert(any(Connection.class), any(Hoantien.class))).thenReturn(42);
        var r = refundService.createRefund(conn, 10, 1, BigDecimal.valueOf(200_000), "Hủy sân");
        assertTrue(r.success);
        assertEquals(42, r.hoanTienId);
    }

    // --- createRefund: sets trạng thái = "Chờ xử lý" ---
    @Test
    void createRefund_setsInitialStatus() throws SQLException {
        when(hoanTienDAO.existsByHoaDonId(20)).thenReturn(false);
        when(hoanTienDAO.insert(any(Connection.class), any(Hoantien.class))).thenReturn(1);

        refundService.createRefund(conn, 20, 3, BigDecimal.valueOf(50_000), "Lý do");

        ArgumentCaptor<Hoantien> cap = ArgumentCaptor.forClass(Hoantien.class);
        verify(hoanTienDAO).insert(any(Connection.class), cap.capture());
        assertEquals(RefundService.TRANG_THAI_CHO_XU_LY, cap.getValue().getTrangThai());
    }

    // --- approve: sends notification when state transition succeeds ---
    @Test
    void approve_sendsNotificationOnSuccess() {
        Hoantien ht = new Hoantien();
        ht.setHoanTienId(1);
        ht.setAccountId(55);
        ht.setSoTienHoan(BigDecimal.valueOf(100_000));
        when(hoanTienDAO.findById(1)).thenReturn(ht);
        when(hoanTienDAO.updateTrangThai(eq(1), eq(RefundService.TRANG_THAI_DA_DUYET),
                anyInt(), any(), any())).thenReturn(true);

        // approve needs HttpServletRequest for AuditLog — pass null; AuditLogService should handle it
        refundService.approve(1, 10, "OK", null);

        verify(notificationService).notifyRefundApproved(eq(55), eq(1), any());
    }

    // --- reject: sends rejection notification ---
    @Test
    void reject_sendsRejectionNotification() {
        Hoantien ht = new Hoantien();
        ht.setHoanTienId(2);
        ht.setAccountId(66);
        ht.setSoTienHoan(BigDecimal.valueOf(80_000));
        when(hoanTienDAO.findById(2)).thenReturn(ht);
        when(hoanTienDAO.updateTrangThai(eq(2), eq(RefundService.TRANG_THAI_TU_CHOI),
                anyInt(), any(), any())).thenReturn(true);

        refundService.reject(2, 10, "Sai thông tin", null);

        verify(notificationService).notifyRefundRejected(eq(66), eq(2), eq("Sai thông tin"));
    }

    // --- approve: returns failure when state transition blocked ---
    @Test
    void approve_failsWhenTransitionBlocked() {
        Hoantien ht = new Hoantien();
        ht.setHoanTienId(3);
        ht.setAccountId(77);
        ht.setSoTienHoan(BigDecimal.valueOf(50_000));
        when(hoanTienDAO.findById(3)).thenReturn(ht);
        when(hoanTienDAO.updateTrangThai(anyInt(), anyString(), anyInt(), any(), any())).thenReturn(false);

        var r = refundService.approve(3, 10, "OK", null);
        assertFalse(r.success);
        verify(notificationService, never()).notifyRefundApproved(anyInt(), anyInt(), any());
    }

    // --- approve/reject: fails when hoanTienId not found ---
    @Test
    void approve_failsWhenNotFound() {
        when(hoanTienDAO.findById(999)).thenReturn(null);
        var r = refundService.approve(999, 10, "x", null);
        assertFalse(r.success);
    }

    // --- notifyRefundCreated: delegates to notificationService ---
    @Test
    void notifyRefundCreated_delegatesToNotificationService() {
        refundService.notifyRefundCreated(5, 10);
        verify(notificationService).notifyRefundRequested(5, 10);
    }
}
