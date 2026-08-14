package org.example.dao.impl;

import org.example.dao.PayOSPaymentAttemptDAO;
import org.example.dto.payment.PayOSPaymentAttemptStatus;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class PayOSPaymentAttemptDAOImpl implements PayOSPaymentAttemptDAO {

    @Override
    public Row findActiveByHoaDonId(Connection c, int hoaDonId) throws SQLException {
        String sql = "SELECT TOP 1 AttemptID, HoaDonID, DatSanID, CoSoID, OrderCode, PaymentLinkID, CheckoutUrl, " +
                "QrCode, Status, Amount, Description FROM PayOSPaymentAttempt WITH (UPDLOCK, ROWLOCK) " +
                "WHERE HoaDonID = ? AND Status IN (N'CREATING', N'PENDING') ORDER BY AttemptID DESC";
        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, hoaDonId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        }
    }

    @Override
    public long insertCreating(Connection c, int hoaDonId, int datSanId, int coSoId, BigDecimal amount, String description) throws SQLException {
        String insertSql = "INSERT INTO PayOSPaymentAttempt (HoaDonID, DatSanID, CoSoID, OrderCode, Status, Amount, Description) " +
                "VALUES (?, ?, ?, 0, N'CREATING', ?, ?)";
        long attemptId;
        try (PreparedStatement ps = c.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, hoaDonId);
            ps.setInt(2, datSanId);
            ps.setInt(3, coSoId);
            ps.setBigDecimal(4, amount);
            ps.setNString(5, description);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (!keys.next()) throw new SQLException("Không lấy được AttemptID vừa tạo.");
                attemptId = keys.getLong(1);
            }
        }
        // orderCode = offset lớn + AttemptID: duy nhất tuyệt đối (IDENTITY), truy ngược trực tiếp về
        // attempt, và tách biệt hẳn khỏi orderCode=DatSanID của luồng đặt sân online khách hàng (số
        // nhỏ) để webhook không bao giờ nhầm lẫn hai luồng.
        long orderCode = 900_000_000_000L + attemptId;
        try (PreparedStatement up = c.prepareStatement("UPDATE PayOSPaymentAttempt SET OrderCode = ? WHERE AttemptID = ?")) {
            up.setLong(1, orderCode);
            up.setLong(2, attemptId);
            up.executeUpdate();
        }
        return orderCode;
    }

    @Override
    public void markPending(Connection c, long orderCode, String paymentLinkId, String checkoutUrl, String qrCode) throws SQLException {
        String sql = "UPDATE PayOSPaymentAttempt SET Status = N'PENDING', PaymentLinkID = ?, CheckoutUrl = ?, QrCode = ? " +
                "WHERE OrderCode = ? AND Status = N'CREATING'";
        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, paymentLinkId);
            ps.setString(2, checkoutUrl);
            ps.setNString(3, qrCode);
            ps.setLong(4, orderCode);
            if (ps.executeUpdate() != 1) throw new SQLException("Không thể chuyển attempt sang PENDING (orderCode=" + orderCode + ").");
        }
    }

    @Override
    public Row findByOrderCode(Connection c, long orderCode) throws SQLException {
        String sql = "SELECT AttemptID, HoaDonID, DatSanID, CoSoID, OrderCode, PaymentLinkID, CheckoutUrl, " +
                "QrCode, Status, Amount, Description FROM PayOSPaymentAttempt WITH (UPDLOCK, ROWLOCK) WHERE OrderCode = ?";
        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, orderCode);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapRow(rs) : null;
            }
        }
    }

    @Override
    public boolean markPaid(Connection c, long orderCode) throws SQLException {
        String sql = "UPDATE PayOSPaymentAttempt SET Status = N'PAID', PaidAt = SYSDATETIME(), LastCheckedAt = SYSDATETIME() " +
                "WHERE OrderCode = ? AND Status <> N'PAID'";
        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, orderCode);
            return ps.executeUpdate() == 1;
        }
    }

    @Override
    public void markCancelledOrExpired(Connection c, long orderCode, PayOSPaymentAttemptStatus status) throws SQLException {
        boolean isCancelled = status == PayOSPaymentAttemptStatus.CANCELLED;
        String sql = "UPDATE PayOSPaymentAttempt SET Status = ?, " +
                (isCancelled ? "CancelledAt = SYSDATETIME(), " : "") +
                "LastCheckedAt = SYSDATETIME() WHERE OrderCode = ? AND Status IN (N'CREATING', N'PENDING')";
        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setNString(1, status.name());
            ps.setLong(2, orderCode);
            ps.executeUpdate();
        }
    }

    @Override
    public void touchLastChecked(Connection c, long orderCode) throws SQLException {
        try (PreparedStatement ps = c.prepareStatement(
                "UPDATE PayOSPaymentAttempt SET LastCheckedAt = SYSDATETIME() WHERE OrderCode = ?")) {
            ps.setLong(1, orderCode);
            ps.executeUpdate();
        }
    }

    private Row mapRow(ResultSet rs) throws SQLException {
        Row row = new Row();
        row.attemptId = rs.getLong("AttemptID");
        row.hoaDonId = rs.getInt("HoaDonID");
        row.datSanId = rs.getInt("DatSanID");
        row.coSoId = rs.getInt("CoSoID");
        row.orderCode = rs.getLong("OrderCode");
        row.paymentLinkId = rs.getString("PaymentLinkID");
        row.checkoutUrl = rs.getString("CheckoutUrl");
        row.qrCode = rs.getString("QrCode");
        row.status = PayOSPaymentAttemptStatus.valueOf(rs.getNString("Status"));
        row.amount = rs.getBigDecimal("Amount");
        row.description = rs.getNString("Description");
        return row;
    }
}
