package org.example.dao.impl;

import org.example.dao.SuCoDAO;
import org.example.model.SuCo;
import org.example.util.DBUtil;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class SuCoDAOImpl implements SuCoDAO {

    private static final Logger log = LogManager.getLogger(SuCoDAOImpl.class);

    @Override
    public int insert(SuCo s) {
        String sql = "INSERT INTO SuCo (CoSoID, SanID, BaoVeID, LoaiSuCo, MucDo, MoTa, AnhUrl, TrangThai) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, 'CHO_XU_LY')";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, s.getCoSoId());
            if (s.getSanId() != null) ps.setInt(2, s.getSanId()); else ps.setNull(2, Types.INTEGER);
            ps.setInt(3, s.getBaoVeId());
            ps.setString(4, s.getLoaiSuCo());
            ps.setString(5, s.getMucDo());
            ps.setString(6, s.getMoTa());
            ps.setString(7, s.getAnhUrl());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            log.error("SuCoDAO.insert failed", e);
        }
        return -1;
    }

    @Override
    public List<SuCo> getByBaoVe(int baoVeId, int limit) {
        String sql = "SELECT sc.*, a.FullName AS TenBaoVe, san.TenSan " +
                     "FROM SuCo sc " +
                     "LEFT JOIN Accounts a ON sc.BaoVeID = a.AccountID " +
                     "LEFT JOIN San san ON sc.SanID = san.SanID " +
                     "WHERE sc.BaoVeID = ? " +
                     "ORDER BY sc.ThoiGianTao DESC LIMIT ?";
        List<SuCo> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, baoVeId);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            log.error("SuCoDAO.getByBaoVe failed", e);
        }
        return list;
    }

    @Override
    public List<SuCo> getByCoSo(int coSoId, String trangThai, int limit) {
        String sql = "SELECT sc.*, a.FullName AS TenBaoVe, san.TenSan " +
                     "FROM SuCo sc " +
                     "LEFT JOIN Accounts a ON sc.BaoVeID = a.AccountID " +
                     "LEFT JOIN San san ON sc.SanID = san.SanID " +
                     "WHERE sc.CoSoID = ? " +
                     (trangThai != null ? "AND sc.TrangThai = ? " : "") +
                     "ORDER BY sc.ThoiGianTao DESC LIMIT ?";
        List<SuCo> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, coSoId);
            if (trangThai != null) {
                ps.setString(2, trangThai);
                ps.setInt(3, limit);
            } else {
                ps.setInt(2, limit);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            log.error("SuCoDAO.getByCoSo failed", e);
        }
        return list;
    }

    @Override
    public boolean updateTrangThai(int suCoId, String trangThai, String ghiChuXuLy, int xuLyBoi) {
        String sql = "UPDATE SuCo SET TrangThai=?, GhiChuXuLy=?, ThoiGianXuLy=NOW(), XuLyBoi=? WHERE SuCoID=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, trangThai);
            ps.setString(2, ghiChuXuLy);
            ps.setInt(3, xuLyBoi);
            ps.setInt(4, suCoId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            log.error("SuCoDAO.updateTrangThai failed", e);
        }
        return false;
    }

    @Override
    public int countTodayByBaoVe(int baoVeId) {
        String sql = "SELECT COUNT(*) FROM SuCo WHERE BaoVeID=? AND DATE(ThoiGianTao)=CURDATE()";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, baoVeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            log.error("SuCoDAO.countTodayByBaoVe failed", e);
        }
        return 0;
    }

    @Override
    public int countTodayByCoSo(int coSoId) {
        String sql = "SELECT COUNT(*) FROM SuCo WHERE CoSoID=? AND DATE(ThoiGianTao)=CURDATE()";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, coSoId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            log.error("SuCoDAO.countTodayByCoSo failed", e);
        }
        return 0;
    }

    private SuCo mapRow(ResultSet rs) throws SQLException {
        SuCo s = new SuCo();
        s.setSuCoId(rs.getInt("SuCoID"));
        s.setCoSoId(rs.getInt("CoSoID"));
        int sanId = rs.getInt("SanID");
        if (!rs.wasNull()) s.setSanId(sanId);
        s.setBaoVeId(rs.getInt("BaoVeID"));
        s.setLoaiSuCo(rs.getString("LoaiSuCo"));
        s.setMucDo(rs.getString("MucDo"));
        s.setMoTa(rs.getString("MoTa"));
        s.setAnhUrl(rs.getString("AnhUrl"));
        s.setTrangThai(rs.getString("TrangThai"));
        s.setGhiChuXuLy(rs.getString("GhiChuXuLy"));
        Timestamp tao = rs.getTimestamp("ThoiGianTao");
        if (tao != null) s.setThoiGianTao(tao.toLocalDateTime());
        Timestamp xl = rs.getTimestamp("ThoiGianXuLy");
        if (xl != null) s.setThoiGianXuLy(xl.toLocalDateTime());
        int xuLy = rs.getInt("XuLyBoi");
        if (!rs.wasNull()) s.setXuLyBoi(xuLy);
        try { s.setTenBaoVe(rs.getString("TenBaoVe")); } catch (SQLException ignored) {}
        try { s.setTenSan(rs.getString("TenSan")); } catch (SQLException ignored) {}
        return s;
    }
}
