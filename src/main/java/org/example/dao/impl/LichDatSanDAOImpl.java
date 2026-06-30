package org.example.dao.impl;

import org.example.dao.LichDatSanDAO;
import org.example.model.Lichdatsan;
import org.example.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class LichDatSanDAOImpl implements LichDatSanDAO {

    private static final Logger logger = LogManager.getLogger(LichDatSanDAOImpl.class);

    @Override
    public List<Lichdatsan> getAllLichDatSan() {
        List<Lichdatsan> list = new ArrayList<>();
        String sql = "SELECT * FROM LichDatSan ORDER BY NgayDat DESC, GioBatDau DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToLichDatSan(rs));
            }
        } catch (SQLException e) {
            logger.error("Lỗi khi lấy tất cả lịch đặt sân: {}", e.getMessage(), e);
        }
        return list;
    }

    @Override
    public List<Lichdatsan> getLichByAccountId(int accountId) {
        List<Lichdatsan> list = new ArrayList<>();
        String sql = "SELECT * FROM LichDatSan WHERE AccountID = ? ORDER BY NgayDat DESC, GioBatDau DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToLichDatSan(rs));
                }
            }
        } catch (SQLException e) {
            logger.error("Lỗi khi lấy lịch đặt sân theo account ID {}: {}", accountId, e.getMessage(), e);
        }
        return list;
    }

    @Override
    public Lichdatsan getLichById(int id) {
        String sql = "SELECT * FROM LichDatSan WHERE DatSanID = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToLichDatSan(rs);
                }
            }
        } catch (SQLException e) {
            logger.error("Lỗi khi lấy lịch đặt sân theo ID {}: {}", id, e.getMessage(), e);
        }
        return null;
    }

    @Override
    public boolean addLichDatSan(Lichdatsan lich) {
        String sql = "INSERT INTO LichDatSan (AccountID, SanID, NgayDat, GioBatDau, GioKetThuc, ApDungGiaCoDen, TongTienDuKien, TrangThai, GhiChu, NguonDatSan) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, lich.getAccountId());
            ps.setInt(2, lich.getSanId());
            ps.setDate(3, Date.valueOf(lich.getNgayDat()));
            ps.setTime(4, Time.valueOf(lich.getGioBatDau()));
            ps.setTime(5, Time.valueOf(lich.getGioKetThuc()));
            ps.setBoolean(6, lich.isApDungGiaCoDen());
            ps.setBigDecimal(7, lich.getTongTienDuKien());
            ps.setNString(8, lich.getTrangThai());
            ps.setNString(9, lich.getGhiChu());
            ps.setNString(10, lich.getNguonDatSan());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Lỗi khi tạo lịch đặt sân mới, account ID {}: {}", lich.getAccountId(), e.getMessage(), e);
        }
        return false;
    }

    @Override
    public boolean updateTrangThai(int id, String trangThai) {
        String sql = "UPDATE LichDatSan SET TrangThai = ? WHERE DatSanID = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setNString(1, trangThai);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Lỗi khi cập nhật trạng thái lịch đặt sân ID {}: {}", id, e.getMessage(), e);
        }
        return false;
    }

    @Override
    public boolean updateGhiChu(int id, String ghiChu) {
        String sql = "UPDATE LichDatSan SET GhiChu = ? WHERE DatSanID = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setNString(1, ghiChu);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Lỗi khi cập nhật ghi chú lịch đặt sân ID {}: {}", id, e.getMessage(), e);
        }
        return false;
    }

    @Override
    public boolean deleteLichDatSan(int id) {
        String sql = "DELETE FROM LichDatSan WHERE DatSanID = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Lỗi khi xóa lịch đặt sân ID {}: {}", id, e.getMessage(), e);
        }
        return false;
    }

    private Lichdatsan mapResultSetToLichDatSan(ResultSet rs) throws SQLException {
        Lichdatsan lich = new Lichdatsan();
        lich.setDatSanId(rs.getInt("DatSanID"));
        lich.setAccountId(rs.getInt("AccountID"));
        lich.setSanId(rs.getInt("SanID"));
        lich.setNgayDat(rs.getDate("NgayDat").toLocalDate());
        lich.setGioBatDau(rs.getTime("GioBatDau").toLocalTime());
        lich.setGioKetThuc(rs.getTime("GioKetThuc").toLocalTime());
        lich.setApDungGiaCoDen(rs.getBoolean("ApDungGiaCoDen"));
        lich.setTongTienDuKien(rs.getBigDecimal("TongTienDuKien"));
        lich.setTrangThai(rs.getNString("TrangThai"));
        lich.setGhiChu(rs.getNString("GhiChu"));
        lich.setNguonDatSan(rs.getNString("NguonDatSan"));

        Timestamp createdTs = rs.getTimestamp("CreatedTime");
        if (createdTs != null) {
            lich.setCreatedTime(createdTs.toLocalDateTime());
        }

        try {
            String tenSan = rs.getNString("TenSan");
            if (tenSan != null) {
                org.example.model.San san = new org.example.model.San();
                san.setSanID(rs.getInt("SanID"));
                san.setTenSan(tenSan);
                san.setCoSoID(rs.getInt("CoSoID"));
                lich.setSan(san);
            }
        } catch (SQLException e) {
            // Column not found, ignore
        }

        return lich;
    }

    @Override
    public List<Lichdatsan> getLichDatSanTodayByCoSo(int coSoId) {
        List<Lichdatsan> list = new ArrayList<>();
        String sql = "SELECT l.*, s.TenSan, s.CoSoID " +
                     "FROM LichDatSan l " +
                     "JOIN San s ON l.SanID = s.SanID " +
                     "WHERE s.CoSoID = ? AND l.NgayDat = CAST(GETDATE() AS date) " +
                     "ORDER BY l.GioBatDau ASC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, coSoId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToLichDatSan(rs));
                }
            }
        } catch (SQLException e) {
            logger.error("Lỗi khi lấy lịch đặt sân hôm nay theo cơ sở {}: {}", coSoId, e.getMessage(), e);
        }
        return list;
    }
}
