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
        String sql = "INSERT INTO LichDatSan_DichVu (DatSanID, SanPhamID, Quantity, UnitPrice, TotalPrice, Status) " +
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
        String sql = "INSERT INTO LichDatSan_DichVu (DatSanID, SanPhamID, Quantity, UnitPrice, TotalPrice, Status) " +
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
        String sql = "SELECT TOP 1 DatSanID FROM LichDatSan WHERE SanID = ? AND TrangThai = N'Đang sử dụng'";
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
        String sql = "SELECT ldv.*, sp.TenSanPham, sp.DonViTinh " +
                "FROM LichDatSan_DichVu ldv " +
                "INNER JOIN SanPham_DichVu sp ON ldv.SanPhamID = sp.SanPhamID " +
                "WHERE ldv.DatSanID = ? ORDER BY ldv.Id ASC";
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
        String sql = "SELECT ldv.Id, ldv.DatSanID, ldv.SanPhamID, ldv.Quantity, ldv.UnitPrice, ldv.TotalPrice, " +
                "ldv.Status, ldv.Note, ldv.CreatedAt, ldv.DeliveredAt, ldv.DeliveredBy, " +
                "sp.TenSanPham, sp.DonViTinh, " +
                "lds.NgayDat, lds.GioBatDau, lds.GioKetThuc, " +
                "s.TenSan, acc.FullName AS TenKhachHang " +
                "FROM LichDatSan_DichVu ldv " +
                "INNER JOIN SanPham_DichVu sp ON ldv.SanPhamID = sp.SanPhamID " +
                "INNER JOIN LichDatSan lds ON ldv.DatSanID = lds.DatSanID " +
                "INNER JOIN San s ON lds.SanID = s.SanID " +
                "LEFT JOIN Accounts acc ON lds.AccountID = acc.AccountID " +
                "WHERE s.CoSoID = ? AND lds.NgayDat = ? " +
                "ORDER BY lds.GioBatDau ASC, ldv.Id ASC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, coSoId);
            ps.setDate(2, Date.valueOf(LocalDate.now()));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> m = new HashMap<>();
                    m.put("id", rs.getInt("Id"));
                    m.put("datSanId", rs.getInt("DatSanID"));
                    m.put("sanPhamId", rs.getInt("SanPhamID"));
                    m.put("tenSanPham", rs.getString("TenSanPham"));
                    m.put("donViTinh", rs.getString("DonViTinh"));
                    m.put("quantity", rs.getInt("Quantity"));
                    m.put("unitPrice", rs.getBigDecimal("UnitPrice"));
                    m.put("totalPrice", rs.getBigDecimal("TotalPrice"));
                    m.put("status", rs.getString("Status"));
                    m.put("note", rs.getString("Note"));
                    m.put("tenSan", rs.getString("TenSan"));
                    String tenKhach = rs.getString("TenKhachHang");
                    m.put("tenKhachHang", tenKhach != null ? tenKhach : "Khách vãng lai");
                    Time gioBatDau = rs.getTime("GioBatDau");
                    Time gioKetThuc = rs.getTime("GioKetThuc");
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
                    "FROM LichDatSan_DichVu ldv " +
                    "INNER JOIN LichDatSan lds ON ldv.DatSanID = lds.DatSanID " +
                    "INNER JOIN San s ON lds.SanID = s.SanID " +
                    "WHERE ldv.Id = ? AND s.CoSoID = ? AND ldv.Status = N'Chờ chuẩn bị'";
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
            String sqlSelect = "SELECT ldv.DatSanID, ldv.SanPhamID, ldv.Quantity, ldv.UnitPrice, ldv.TotalPrice, " +
                    "s.CoSoID, lds.AccountID " +
                    "FROM LichDatSan_DichVu ldv WITH (UPDLOCK, ROWLOCK) " +
                    "INNER JOIN LichDatSan lds ON ldv.DatSanID = lds.DatSanID " +
                    "INNER JOIN San s ON lds.SanID = s.SanID " +
                    "WHERE ldv.Id = ? AND s.CoSoID = ? AND ldv.Status = N'Chờ chuẩn bị'";
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
                    datSanId = rs.getInt("DatSanID");
                    sanPhamId = rs.getInt("SanPhamID");
                    quantity = rs.getInt("Quantity");
                    unitPrice = rs.getBigDecimal("UnitPrice");
                    totalPrice = rs.getBigDecimal("TotalPrice");
                    int accId = rs.getInt("AccountID");
                    if (!rs.wasNull()) customerAccountId = accId;
                }
            }

            // 2. Cập nhật trạng thái "Đã giao"
            String sqlUpdate = "UPDATE LichDatSan_DichVu SET Status = N'Đã giao', DeliveredAt = SYSDATETIME(), DeliveredBy = ? WHERE Id = ? AND Status = N'Chờ chuẩn bị'";
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
            String sqlStock = "UPDATE SanPham_DichVu SET SoLuongTon = SoLuongTon - ? WHERE SanPhamID = ? AND SoLuongTon >= ?";
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
                    "SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'HoaDon') AND name = N'LoaiHoaDon'");
                 ResultSet rs = ps.executeQuery()) {
                hasLoaiHoaDon = rs.next();
            }
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'HoaDon') AND name = N'ParentHoaDonID'");
                 ResultSet rs = ps.executeQuery()) {
                hasParentHoaDonID = rs.next();
            }

            if (hasLoaiHoaDon) {
                String sqlMain = "SELECT HoaDonID FROM HoaDon WHERE DatSanID = ? AND (LoaiHoaDon = N'MAIN' OR LoaiHoaDon IS NULL)";
                try (PreparedStatement ps = conn.prepareStatement(sqlMain)) {
                    ps.setInt(1, datSanId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) parentHoaDonId = rs.getInt("HoaDonID");
                    }
                }
            }

            // Tạo SPLIT invoice cho dịch vụ
            String sqlInsertHD;
            if (hasLoaiHoaDon && hasParentHoaDonID) {
                sqlInsertHD = "INSERT INTO HoaDon (DatSanID, AccountID_KhachHang, AccountID_NhanVien, NgayLap, " +
                        "TongTienSan, TongTienDichVu, PhiGuiXe, GiamGia, TongThanhToan, TrangThaiThanhToan, LoaiHoaDon, ParentHoaDonID) " +
                        "VALUES (?, ?, ?, GETDATE(), 0, ?, 0, 0, ?, N'Chưa thanh toán', N'SPLIT', ?)";
            } else if (hasLoaiHoaDon) {
                sqlInsertHD = "INSERT INTO HoaDon (DatSanID, AccountID_KhachHang, AccountID_NhanVien, NgayLap, " +
                        "TongTienSan, TongTienDichVu, PhiGuiXe, GiamGia, TongThanhToan, TrangThaiThanhToan, LoaiHoaDon) " +
                        "VALUES (?, ?, ?, GETDATE(), 0, ?, 0, 0, ?, N'Chưa thanh toán', N'SPLIT')";
            } else {
                sqlInsertHD = "INSERT INTO HoaDon (DatSanID, AccountID_KhachHang, AccountID_NhanVien, NgayLap, " +
                        "TongTienSan, TongTienDichVu, PhiGuiXe, GiamGia, TongThanhToan, TrangThaiThanhToan) " +
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
            String sqlInsertCT = "INSERT INTO ChiTietHoaDon (HoaDonID, SanPhamID, SoLuong, DonGia, ThanhTien) VALUES (?, ?, ?, ?, ?)";
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
        dv.setDatSanId(rs.getInt("DatSanID"));
        dv.setSanPhamId(rs.getInt("SanPhamID"));
        dv.setQuantity(rs.getInt("Quantity"));
        dv.setUnitPrice(rs.getBigDecimal("UnitPrice"));
        dv.setTotalPrice(rs.getBigDecimal("TotalPrice"));
        dv.setStatus(rs.getString("Status"));
        dv.setNote(rs.getString("Note"));
        Timestamp createdAt = rs.getTimestamp("CreatedAt");
        if (createdAt != null) dv.setCreatedAt(createdAt.toLocalDateTime());
        Timestamp deliveredAt = rs.getTimestamp("DeliveredAt");
        if (deliveredAt != null) dv.setDeliveredAt(deliveredAt.toLocalDateTime());
        int deliveredBy = rs.getInt("DeliveredBy");
        if (!rs.wasNull()) dv.setDeliveredBy(deliveredBy);
        dv.setTenSanPham(rs.getString("TenSanPham"));
        dv.setDonViTinh(rs.getString("DonViTinh"));
        return dv;
    }
}
