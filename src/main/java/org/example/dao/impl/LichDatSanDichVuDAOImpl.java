package org.example.dao.impl;

import org.example.dao.LichDatSanDichVuDAO;
import org.example.model.LichDatSanDichVu;
import org.example.util.DBUtil;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class LichDatSanDichVuDAOImpl implements LichDatSanDichVuDAO {

    @Override
    public void insertPreOrder(Connection conn, int datSanId, int sanPhamId, int quantity,
                                BigDecimal unitPrice, BigDecimal totalPrice) throws SQLException {
        String sql = "INSERT INTO booking_services (booking_id, product_id, Quantity, UnitPrice, TotalPrice, Status) " +
                "VALUES (?, ?, ?, ?, ?, N'Chờ chuẩn bị')";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, datSanId);
            ps.setInt(2, sanPhamId);
            ps.setInt(3, quantity);
            ps.setBigDecimal(4, unitPrice);
            ps.setBigDecimal(5, totalPrice);
            ps.executeUpdate();
        }
    }

    @Override
    public int insertPreOrderReturningId(Connection conn, int datSanId, int sanPhamId, int quantity,
                                          BigDecimal unitPrice, BigDecimal totalPrice) throws SQLException {
        String sql = "INSERT INTO booking_services (booking_id, product_id, Quantity, UnitPrice, TotalPrice, Status) " +
                "VALUES (?, ?, ?, ?, ?, N'Chờ chuẩn bị')";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, datSanId);
            ps.setInt(2, sanPhamId);
            ps.setInt(3, quantity);
            ps.setBigDecimal(4, unitPrice);
            ps.setBigDecimal(5, totalPrice);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (!keys.next()) throw new SQLException("Không thể tạo dòng dịch vụ đặt trước.");
                return keys.getInt(1);
            }
        }
    }

    @Override
    public Integer findActiveDatSanIdBySan(int sanId) throws SQLException {
        String sql = "SELECT TOP 1 booking_id FROM bookings WHERE court_id = ? AND status = N'Đang sử dụng'";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, sanId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : null;
            }
        }
    }

    @Override
    public List<LichDatSanDichVu> findByDatSanId(int datSanId) throws SQLException {
        List<LichDatSanDichVu> result = new ArrayList<>();
        String sql = "SELECT ldv.*, sp.product_name, sp.unit_of_measure " +
                "FROM booking_services ldv " +
                "INNER JOIN products_services sp ON ldv.product_id = sp.product_id " +
                "WHERE ldv.booking_id = ? ORDER BY ldv.Id ASC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, datSanId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    result.add(mapRow(rs));
                }
            }
        }
        return result;
    }

    @Override
    public List<Map<String, Object>> findTodayByCoSo(int coSoId) throws SQLException {
        List<Map<String, Object>> result = new ArrayList<>();
        String sql = "SELECT ldv.Id, ldv.booking_id, ldv.product_id, ldv.Quantity, ldv.UnitPrice, ldv.TotalPrice, " +
                "ldv.Status, ldv.Note, ldv.created_at, ldv.DeliveredAt, ldv.DeliveredBy, " +
                "sp.product_name, sp.unit_of_measure, " +
                "lds.booking_date, lds.start_time, lds.end_time, " +
                "s.court_name, acc.full_name AS TenKhachHang " +
                "FROM booking_services ldv " +
                "INNER JOIN products_services sp ON ldv.product_id = sp.product_id " +
                "INNER JOIN bookings lds ON ldv.booking_id = lds.booking_id " +
                "INNER JOIN courts s ON lds.court_id = s.court_id " +
                "LEFT JOIN accounts acc ON lds.account_id = acc.account_id " +
                "WHERE s.facility_id = ? AND lds.booking_date = ? " +
                "ORDER BY lds.start_time ASC, ldv.Id ASC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, coSoId);
            ps.setDate(2, Date.valueOf(LocalDate.now()));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> m = new HashMap<>();
                    m.put("id", rs.getInt("Id"));
                    m.put("datSanId", rs.getInt("booking_id"));
                    m.put("sanPhamId", rs.getInt("product_id"));
                    m.put("tenSanPham", rs.getString("product_name"));
                    m.put("donViTinh", rs.getString("unit_of_measure"));
                    m.put("quantity", rs.getInt("Quantity"));
                    m.put("unitPrice", rs.getBigDecimal("UnitPrice"));
                    m.put("totalPrice", rs.getBigDecimal("TotalPrice"));
                    m.put("status", rs.getString("Status"));
                    m.put("note", rs.getString("Note"));
                    m.put("tenSan", rs.getString("court_name"));
                    String tenKhach = rs.getString("TenKhachHang");
                    m.put("tenKhachHang", tenKhach != null ? tenKhach : "Khách vãng lai");
                    Time gioBatDau = rs.getTime("start_time");
                    Time gioKetThuc = rs.getTime("end_time");
                    m.put("gioBatDau", gioBatDau != null ? gioBatDau.toLocalTime().toString() : null);
                    m.put("gioKetThuc", gioKetThuc != null ? gioKetThuc.toLocalTime().toString() : null);
                    Timestamp deliveredAt = rs.getTimestamp("DeliveredAt");
                    m.put("deliveredAt", deliveredAt != null ? deliveredAt.toString() : null);
                    result.add(m);
                }
            }
        }
        return result;
    }

    @Override
    public boolean updateStatus(int id, String newStatus, Integer staffAccountId, int staffCoSoId) throws SQLException {
        boolean setDelivered = "Đã giao".equals(newStatus);

        if (!setDelivered) {
            // Hủy: chỉ cập nhật trạng thái, không cần tạo hóa đơn/trừ kho
            String sql = "UPDATE ldv SET ldv.Status = ? " +
                    "FROM booking_services ldv " +
                    "INNER JOIN bookings lds ON ldv.booking_id = lds.booking_id " +
                    "INNER JOIN courts s ON lds.court_id = s.court_id " +
                    "WHERE ldv.Id = ? AND s.facility_id = ? AND ldv.Status = N'Chờ chuẩn bị'";
            try (Connection conn = DBUtil.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, newStatus);
                ps.setInt(2, id);
                ps.setInt(3, staffCoSoId);
                return ps.executeUpdate() > 0;
            }
        }

        // Đã giao: cập nhật trạng thái + trừ tồn kho + tạo hóa đơn SPLIT
        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            // 1. Lấy thông tin dịch vụ và khóa dòng
            String sqlSelect = "SELECT ldv.booking_id, ldv.product_id, ldv.Quantity, ldv.UnitPrice, ldv.TotalPrice, " +
                    "s.facility_id, lds.account_id " +
                    "FROM booking_services ldv WITH (UPDLOCK, ROWLOCK) " +
                    "INNER JOIN bookings lds ON ldv.booking_id = lds.booking_id " +
                    "INNER JOIN courts s ON lds.court_id = s.court_id " +
                    "WHERE ldv.Id = ? AND s.facility_id = ? AND ldv.Status = N'Chờ chuẩn bị'";
            int datSanId, sanPhamId, quantity;
            BigDecimal unitPrice, totalPrice;
            Integer customerAccountId = null;
            try (PreparedStatement ps = conn.prepareStatement(sqlSelect)) {
                ps.setInt(1, id);
                ps.setInt(2, staffCoSoId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        return false;
                    }
                    datSanId = rs.getInt("booking_id");
                    sanPhamId = rs.getInt("product_id");
                    quantity = rs.getInt("Quantity");
                    unitPrice = rs.getBigDecimal("UnitPrice");
                    totalPrice = rs.getBigDecimal("TotalPrice");
                    int accId = rs.getInt("account_id");
                    if (!rs.wasNull()) customerAccountId = accId;
                }
            }

            // 2. Cập nhật trạng thái "Đã giao"
            String sqlUpdate = "UPDATE booking_services SET Status = N'Đã giao', DeliveredAt = SYSDATETIME(), DeliveredBy = ? WHERE Id = ? AND Status = N'Chờ chuẩn bị'";
            try (PreparedStatement ps = conn.prepareStatement(sqlUpdate)) {
                if (staffAccountId != null) ps.setInt(1, staffAccountId);
                else ps.setNull(1, Types.INTEGER);
                ps.setInt(2, id);
                if (ps.executeUpdate() == 0) {
                    conn.rollback();
                    return false;
                }
            }

            // 3. Trừ tồn kho sản phẩm
            String sqlStock = "UPDATE products_services SET stock_quantity = stock_quantity - ? WHERE product_id = ? AND stock_quantity >= ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlStock)) {
                ps.setInt(1, quantity);
                ps.setInt(2, sanPhamId);
                ps.setInt(3, quantity);
                int rows = ps.executeUpdate();
                if (rows == 0) {
                    conn.rollback();
                    throw new SQLException("Sản phẩm không đủ tồn kho để giao.");
                }
            }

            // 4. Tạo hóa đơn SPLIT cho dịch vụ đã giao
            // Lấy MAIN HoaDonID để làm ParentHoaDonID
            int parentHoaDonId = -1;
            boolean hasLoaiHoaDon = false;
            boolean hasParentHoaDonID = false;
            // Kiểm tra cột tồn tại
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'invoices') AND name = N'invoice_type'");
                 ResultSet rs = ps.executeQuery()) {
                hasLoaiHoaDon = rs.next();
            }
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'invoices') AND name = N'parent_invoice_id'");
                 ResultSet rs = ps.executeQuery()) {
                hasParentHoaDonID = rs.next();
            }

            if (hasLoaiHoaDon) {
                String sqlMain = "SELECT invoice_id FROM invoices WHERE booking_id = ? AND (invoice_type = N'MAIN' OR invoice_type IS NULL)";
                try (PreparedStatement ps = conn.prepareStatement(sqlMain)) {
                    ps.setInt(1, datSanId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) parentHoaDonId = rs.getInt("invoice_id");
                    }
                }
            }

            // Tạo SPLIT invoice cho dịch vụ
            String sqlInsertHD;
            if (hasLoaiHoaDon && hasParentHoaDonID) {
                sqlInsertHD = "INSERT INTO invoices (booking_id, customer_account_id, staff_account_id, issued_at, " +
                        "court_total, service_total, parking_fee, discount_amount, grand_total, payment_status, invoice_type, parent_invoice_id) " +
                        "VALUES (?, ?, ?, GETDATE(), 0, ?, 0, 0, ?, N'Chưa thanh toán', N'SPLIT', ?)";
            } else if (hasLoaiHoaDon) {
                sqlInsertHD = "INSERT INTO invoices (booking_id, customer_account_id, staff_account_id, issued_at, " +
                        "court_total, service_total, parking_fee, discount_amount, grand_total, payment_status, invoice_type) " +
                        "VALUES (?, ?, ?, GETDATE(), 0, ?, 0, 0, ?, N'Chưa thanh toán', N'SPLIT')";
            } else {
                sqlInsertHD = "INSERT INTO invoices (booking_id, customer_account_id, staff_account_id, issued_at, " +
                        "court_total, service_total, parking_fee, discount_amount, grand_total, payment_status) " +
                        "VALUES (?, ?, ?, GETDATE(), 0, ?, 0, 0, ?, N'Chưa thanh toán')";
            }
            int newHoaDonId;
            try (PreparedStatement ps = conn.prepareStatement(sqlInsertHD, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, datSanId);
                if (customerAccountId != null) ps.setInt(2, customerAccountId);
                else ps.setNull(2, Types.INTEGER);
                if (staffAccountId != null) ps.setInt(3, staffAccountId);
                else ps.setNull(3, Types.INTEGER);
                ps.setBigDecimal(4, totalPrice);
                ps.setBigDecimal(5, totalPrice);
                if (hasLoaiHoaDon && hasParentHoaDonID) {
                    if (parentHoaDonId > 0) ps.setInt(6, parentHoaDonId);
                    else ps.setNull(6, Types.INTEGER);
                }
                ps.executeUpdate();
                try (ResultSet genKeys = ps.getGeneratedKeys()) {
                    if (!genKeys.next()) throw new SQLException("Không thể tạo hóa đơn dịch vụ.");
                    newHoaDonId = genKeys.getInt(1);
                }
            }

            // 5. Tạo ChiTietHoaDon cho SPLIT invoice
            String sqlInsertCT = "INSERT INTO invoice_items (invoice_id, product_id, quantity, unit_price, line_total) VALUES (?, ?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sqlInsertCT)) {
                ps.setInt(1, newHoaDonId);
                ps.setInt(2, sanPhamId);
                ps.setInt(3, quantity);
                ps.setBigDecimal(4, unitPrice);
                ps.setBigDecimal(5, totalPrice);
                ps.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) { /* ignore */ }
            throw e;
        } finally {
            if (conn != null) try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ex) { /* ignore */ }
        }
    }

    private LichDatSanDichVu mapRow(ResultSet rs) throws SQLException {
        LichDatSanDichVu dv = new LichDatSanDichVu();
        dv.setId(rs.getInt("Id"));
        dv.setDatSanId(rs.getInt("booking_id"));
        dv.setSanPhamId(rs.getInt("product_id"));
        dv.setQuantity(rs.getInt("Quantity"));
        dv.setUnitPrice(rs.getBigDecimal("UnitPrice"));
        dv.setTotalPrice(rs.getBigDecimal("TotalPrice"));
        dv.setStatus(rs.getString("Status"));
        dv.setNote(rs.getString("Note"));
        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) dv.setCreatedAt(createdAt.toLocalDateTime());
        Timestamp deliveredAt = rs.getTimestamp("DeliveredAt");
        if (deliveredAt != null) dv.setDeliveredAt(deliveredAt.toLocalDateTime());
        int deliveredBy = rs.getInt("DeliveredBy");
        if (!rs.wasNull()) dv.setDeliveredBy(deliveredBy);
        dv.setTenSanPham(rs.getString("product_name"));
        dv.setDonViTinh(rs.getString("unit_of_measure"));
        return dv;
    }
}
