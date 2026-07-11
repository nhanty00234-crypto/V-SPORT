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
        String sql = "UPDATE ldv SET " +
                "ldv.Status = ?, " +
                (setDelivered ? "ldv.DeliveredAt = SYSDATETIME(), ldv.DeliveredBy = ? " : "ldv.DeliveredAt = ldv.DeliveredAt ") +
                "FROM LichDatSan_DichVu ldv " +
                "INNER JOIN LichDatSan lds ON ldv.DatSanID = lds.DatSanID " +
                "INNER JOIN San s ON lds.SanID = s.SanID " +
                "WHERE ldv.Id = ? AND s.CoSoID = ? AND ldv.Status = N'Chờ chuẩn bị'";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            int idx = 1;
            ps.setString(idx++, newStatus);
            if (setDelivered) {
                if (staffAccountId != null) {
                    ps.setInt(idx++, staffAccountId);
                } else {
                    ps.setNull(idx++, Types.INTEGER);
                }
            }
            ps.setInt(idx++, id);
            ps.setInt(idx, staffCoSoId);
            int rows = ps.executeUpdate();
            return rows > 0;
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
