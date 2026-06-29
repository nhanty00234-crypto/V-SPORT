package org.example.dao.impl;

import org.example.dao.CaLamViecAvailabilityDAO;
import org.example.model.CaLamViecAvailability;
import org.example.util.DBUtil;

import java.sql.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class CaLamViecAvailabilityDAOImpl implements CaLamViecAvailabilityDAO {

    private static final Logger logger = LogManager.getLogger(CaLamViecAvailabilityDAOImpl.class);

    @Override
    public boolean insert(CaLamViecAvailability avail) {
        String sql = "INSERT INTO CaLamViec_Availability (AccountID, CoSoID, Ngay, GioBatDau, GioKetThuc, TrangThai, GhiChu, DuyetTrangThai, PhanHoi) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, avail.getAccountId());
            ps.setInt(2, avail.getCoSoId());
            ps.setDate(3, Date.valueOf(avail.getNgay()));
            ps.setTime(4, Time.valueOf(avail.getGioBatDau()));
            ps.setTime(5, Time.valueOf(avail.getGioKetThuc()));
            ps.setString(6, avail.getTrangThai());
            ps.setString(7, avail.getGhiChu());
            
            String duyetTrangThai = "Ranh".equals(avail.getTrangThai()) ? "DaDuyet" : "ChoDuyet";
            if (avail.getDuyetTrangThai() != null) {
                duyetTrangThai = avail.getDuyetTrangThai();
            }
            ps.setString(8, duyetTrangThai);
            ps.setString(9, avail.getPhanHoi());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Error inserting availability: {}", e.getMessage(), e);
            return false;
        }
    }

    @Override
    public boolean delete(int availabilityId) {
        String sql = "DELETE FROM CaLamViec_Availability WHERE AvailabilityID = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, availabilityId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Error deleting availability ID {}: {}", availabilityId, e.getMessage(), e);
            return false;
        }
    }

    @Override
    public List<CaLamViecAvailability> getByCoSo(int coSoId) {
        List<CaLamViecAvailability> list = new ArrayList<>();
        String sql = "SELECT av.*, acc.FullName, acc.Username FROM CaLamViec_Availability av JOIN Accounts acc ON av.AccountID = acc.AccountID WHERE av.CoSoID = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, coSoId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSet(rs));
                }
            }
        } catch (SQLException e) {
            logger.error("Error getting availability by branch ID {}: {}", coSoId, e.getMessage(), e);
        }
        return list;
    }

    @Override
    public List<CaLamViecAvailability> getByAccount(int accountId) {
        List<CaLamViecAvailability> list = new ArrayList<>();
        String sql = "SELECT av.*, acc.FullName, acc.Username FROM CaLamViec_Availability av JOIN Accounts acc ON av.AccountID = acc.AccountID WHERE av.AccountID = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSet(rs));
                }
            }
        } catch (SQLException e) {
            logger.error("Error getting availability by staff ID {}: {}", accountId, e.getMessage(), e);
        }
        return list;
    }

    @Override
    public List<CaLamViecAvailability> getByCoSoAndDateRange(int coSoId, LocalDate start, LocalDate end) {
        List<CaLamViecAvailability> list = new ArrayList<>();
        String sql = "SELECT av.*, acc.FullName, acc.Username FROM CaLamViec_Availability av JOIN Accounts acc ON av.AccountID = acc.AccountID WHERE av.CoSoID = ? AND av.Ngay BETWEEN ? AND ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, coSoId);
            ps.setDate(2, Date.valueOf(start));
            ps.setDate(3, Date.valueOf(end));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSet(rs));
                }
            }
        } catch (SQLException e) {
            logger.error("Error getting availability by branch & range: {}", e.getMessage(), e);
        }
        return list;
    }

    private CaLamViecAvailability mapResultSet(ResultSet rs) throws SQLException {
        CaLamViecAvailability av = new CaLamViecAvailability();
        av.setAvailabilityId(rs.getInt("AvailabilityID"));
        av.setAccountId(rs.getInt("AccountID"));
        av.setCoSoId(rs.getInt("CoSoID"));
        av.setNgay(rs.getDate("Ngay").toLocalDate());
        av.setGioBatDau(rs.getTime("GioBatDau").toLocalTime());
        av.setGioKetThuc(rs.getTime("GioKetThuc").toLocalTime());
        av.setTrangThai(rs.getString("TrangThai"));
        av.setGhiChu(rs.getNString("GhiChu"));
        av.setDuyetTrangThai(rs.getString("DuyetTrangThai"));
        av.setPhanHoi(rs.getNString("PhanHoi"));
        Timestamp ts = rs.getTimestamp("CreatedAt");
        if (ts != null) {
            av.setCreatedAt(ts.toLocalDateTime());
        }
        av.setTenNhanVien(rs.getNString("FullName"));
        av.setUsername(rs.getString("Username"));
        return av;
    }
}
