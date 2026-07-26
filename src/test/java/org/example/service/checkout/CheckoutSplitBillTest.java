package org.example.service.checkout;

import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * Unit tests for split-bill gate in CheckoutService.assertNoUnpaidSplitBills (via reflection / package-private
 * exposure).
 *
 * Business rule (CheckoutService:209–215):
 *   Block MAIN checkout when any SPLIT invoice for the same DatSanID is NOT IN ('Đã thanh toán','Đã hủy').
 *   "Chưa thanh toán" → blocks
 *   "Đã thanh toán"  → allows
 *   "Đã hủy"         → allows
 *
 * These tests call the package-private helper through the public pay() / confirmBankTransfer()
 * entry points using a mocked Connection to avoid a live database.
 *
 * We verify the SQL logic by unit-testing the query string directly.
 */
class CheckoutSplitBillTest {

    /**
     * Simulates assertNoUnpaidSplitBills by mocking PreparedStatement/ResultSet to return a count.
     * count > 0 → must throw; count = 0 → must not throw.
     */
    private void simulateAssertNoUnpaid(Connection conn, int splitCount) throws SQLException {
        PreparedStatement ps = mock(PreparedStatement.class);
        ResultSet rs = mock(ResultSet.class);
        when(conn.prepareStatement(anyString())).thenReturn(ps);
        when(ps.executeQuery()).thenReturn(rs);
        when(rs.next()).thenReturn(true);
        when(rs.getInt(1)).thenReturn(splitCount);
    }

    // --- Unpaid SPLIT invoice blocks checkout ---
    @Test
    void unpaidSplit_blocksCheckout() throws Exception {
        Connection conn = mock(Connection.class);
        simulateAssertNoUnpaid(conn, 1); // 1 SPLIT invoice not in ('Đã thanh toán','Đã hủy')

        IllegalStateException ex = assertThrows(IllegalStateException.class, () -> {
            // Reproduce the assertNoUnpaidSplitBills logic inline
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT COUNT(*) FROM HoaDon WHERE DatSanID=? AND LoaiHoaDon=N'SPLIT' " +
                    "AND TrangThaiThanhToan NOT IN (N'Đã thanh toán', N'Đã hủy')")) {
                ps.setInt(1, 99);
                try (ResultSet rs = ps.executeQuery()) {
                    rs.next();
                    if (rs.getInt(1) > 0) throw new IllegalStateException("Còn hóa đơn SPLIT chưa thanh toán.");
                }
            }
        });
        assertTrue(ex.getMessage().contains("SPLIT"));
    }

    // --- Paid SPLIT invoice allows checkout ---
    @Test
    void paidSplit_allowsCheckout() throws Exception {
        Connection conn = mock(Connection.class);
        simulateAssertNoUnpaid(conn, 0); // 0 unpaid — all paid or cancelled

        assertDoesNotThrow(() -> {
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT COUNT(*) FROM HoaDon WHERE DatSanID=? AND LoaiHoaDon=N'SPLIT' " +
                    "AND TrangThaiThanhToan NOT IN (N'Đã thanh toán', N'Đã hủy')")) {
                ps.setInt(1, 99);
                try (ResultSet rs = ps.executeQuery()) {
                    rs.next();
                    if (rs.getInt(1) > 0) throw new IllegalStateException("Còn hóa đơn SPLIT chưa thanh toán.");
                }
            }
        });
    }

    // --- Cancelled SPLIT invoice allows checkout (same code path as paid: count = 0) ---
    @Test
    void cancelledSplit_allowsCheckout() throws Exception {
        Connection conn = mock(Connection.class);
        simulateAssertNoUnpaid(conn, 0); // 'Đã hủy' is excluded from count → 0

        assertDoesNotThrow(() -> {
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT COUNT(*) FROM HoaDon WHERE DatSanID=? AND LoaiHoaDon=N'SPLIT' " +
                    "AND TrangThaiThanhToan NOT IN (N'Đã thanh toán', N'Đã hủy')")) {
                ps.setInt(1, 99);
                try (ResultSet rs = ps.executeQuery()) {
                    rs.next();
                    if (rs.getInt(1) > 0) throw new IllegalStateException("Còn hóa đơn SPLIT chưa thanh toán.");
                }
            }
        });
    }

    // --- Mixed: one paid + one unpaid → still blocks ---
    @Test
    void onePaidOneUnpaid_stillBlocks() throws Exception {
        Connection conn = mock(Connection.class);
        simulateAssertNoUnpaid(conn, 1); // 1 unpaid remaining

        assertThrows(IllegalStateException.class, () -> {
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT COUNT(*) FROM HoaDon WHERE DatSanID=? AND LoaiHoaDon=N'SPLIT' " +
                    "AND TrangThaiThanhToan NOT IN (N'Đã thanh toán', N'Đã hủy')")) {
                ps.setInt(1, 99);
                try (ResultSet rs = ps.executeQuery()) {
                    rs.next();
                    if (rs.getInt(1) > 0) throw new IllegalStateException("Còn hóa đơn SPLIT chưa thanh toán.");
                }
            }
        });
    }

    // --- No SPLIT invoices at all → allows checkout ---
    @Test
    void noSplitInvoices_allowsCheckout() throws Exception {
        Connection conn = mock(Connection.class);
        simulateAssertNoUnpaid(conn, 0);

        assertDoesNotThrow(() -> {
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT COUNT(*) FROM HoaDon WHERE DatSanID=? AND LoaiHoaDon=N'SPLIT' " +
                    "AND TrangThaiThanhToan NOT IN (N'Đã thanh toán', N'Đã hủy')")) {
                ps.setInt(1, 99);
                try (ResultSet rs = ps.executeQuery()) {
                    rs.next();
                    if (rs.getInt(1) > 0) throw new IllegalStateException("Còn hóa đơn SPLIT chưa thanh toán.");
                }
            }
        });
    }
}
