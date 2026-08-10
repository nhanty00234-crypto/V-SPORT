package org.example.dao.impl;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.dao.KhuyenMaiDAO;
import org.example.model.KhuyenMai;
import org.example.util.DBUtil;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

public class KhuyenMaiDAOImpl implements KhuyenMaiDAO {

    private static final Logger logger = LogManager.getLogger(KhuyenMaiDAOImpl.class);

    @Override
    public List<KhuyenMai> findByCoSoId(int coSoId, int page, int pageSize) {
        List<KhuyenMai> list = new ArrayList<>();
        int offset = (Math.max(page, 1) - 1) * pageSize;
        String sql = "SELECT * FROM promotions WHERE facility_id = ? " +
                     "ORDER BY start_date DESC " +
                     "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, coSoId);
            ps.setInt(2, offset);
            ps.setInt(3, pageSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (SQLException e) {
            logger.error("findByCoSoId coSoId={}: {}", coSoId, e.getMessage(), e);
        }
        return list;
    }

    @Override
    public List<KhuyenMai> findByCoSoId(int coSoId) {
        List<KhuyenMai> list = new ArrayList<>();
        String sql = "SELECT * FROM promotions WHERE facility_id = ? ORDER BY start_date DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, coSoId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (SQLException e) {
            logger.error("findByCoSoId (all) coSoId={}: {}", coSoId, e.getMessage(), e);
        }
        return list;
    }

    @Override
    public KhuyenMai findById(int id) {
        String sql = "SELECT * FROM promotions WHERE promotion_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        } catch (SQLException e) {
            logger.error("findById KhuyenMaiID={}: {}", id, e.getMessage(), e);
        }
        return null;
    }

    @Override
    public KhuyenMai findByIdAndCoSoId(int id, int coSoId) {
        String sql = "SELECT * FROM promotions WHERE promotion_id = ? AND facility_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setInt(2, coSoId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        } catch (SQLException e) {
            logger.error("findByIdAndCoSoId KhuyenMaiID={} coSoId={}: {}", id, coSoId, e.getMessage(), e);
        }
        return null;
    }

    @Override
    public KhuyenMai findByCodeAndCoSoId(String maCode, int coSoId) {
        String sql = "SELECT * FROM promotions WHERE promo_code = ? AND facility_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, maCode);
            ps.setInt(2, coSoId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        } catch (SQLException e) {
            logger.error("findByCodeAndCoSoId: {}", e.getMessage(), e);
        }
        return null;
    }

    @Override
    public boolean existsByCode(String maCode) {
        String sql = "SELECT 1 FROM promotions WHERE promo_code = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, maCode);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        } catch (SQLException e) {
            logger.error("existsByCode: {}", e.getMessage(), e);
        }
        return false;
    }

    @Override
    public boolean existsByCodeExcluding(String maCode, int excludeId) {
        String sql = "SELECT 1 FROM promotions WHERE promo_code = ? AND promotion_id <> ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, maCode);
            ps.setInt(2, excludeId);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        } catch (SQLException e) {
            logger.error("existsByCodeExcluding: {}", e.getMessage(), e);
        }
        return false;
    }

    @Override
    public int insert(KhuyenMai km) {
        String sql = "INSERT INTO promotions (promo_code, description, discount_type, discount_value, start_date, end_date, " +
                     "max_usage_count, used_count, facility_id, status, is_public) VALUES (?, ?, ?, ?, ?, ?, ?, 0, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, km.getMaCode());
            ps.setNString(2, km.getMoTa());
            ps.setString(3, km.getLoaiGiam());
            ps.setDouble(4, km.getGiaTriGiam());
            ps.setDate(5, Date.valueOf(km.getNgayBatDau()));
            ps.setDate(6, Date.valueOf(km.getNgayKetThuc()));
            if (km.getSoLanToiDa() != null) ps.setInt(7, km.getSoLanToiDa());
            else ps.setNull(7, Types.INTEGER);
            if (km.getCoSoID() != null) ps.setInt(8, km.getCoSoID());
            else ps.setNull(8, Types.INTEGER);
            ps.setNString(9, km.getTrangThai() != null ? km.getTrangThai() : "Hoạt động");
            ps.setBoolean(10, km.isHienThiCongKhai());
            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            logger.error("insert KhuyenMai: {}", e.getMessage(), e);
        }
        return 0;
    }

    @Override
    public boolean update(KhuyenMai km) {
        String sql = "UPDATE promotions SET promo_code=?, description=?, discount_type=?, discount_value=?, " +
                     "start_date=?, end_date=?, max_usage_count=?, status=? " +
                     "WHERE promotion_id=? AND facility_id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, km.getMaCode());
            ps.setNString(2, km.getMoTa());
            ps.setString(3, km.getLoaiGiam());
            ps.setDouble(4, km.getGiaTriGiam());
            ps.setDate(5, Date.valueOf(km.getNgayBatDau()));
            ps.setDate(6, Date.valueOf(km.getNgayKetThuc()));
            if (km.getSoLanToiDa() != null) ps.setInt(7, km.getSoLanToiDa());
            else ps.setNull(7, Types.INTEGER);
            ps.setNString(8, km.getTrangThai());
            ps.setInt(9, km.getKhuyenMaiID());
            ps.setInt(10, km.getCoSoID());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("update promotion_id={}: {}", km.getKhuyenMaiID(), e.getMessage(), e);
        }
        return false;
    }

    @Override
    public boolean updateTrangThai(int khuyenMaiId, int coSoId, String trangThai) {
        String sql = "UPDATE promotions SET status=? WHERE promotion_id=? AND facility_id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setNString(1, trangThai);
            ps.setInt(2, khuyenMaiId);
            ps.setInt(3, coSoId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("updateTrangThai KhuyenMaiID={}: {}", khuyenMaiId, e.getMessage(), e);
        }
        return false;
    }

    @Override
    public boolean delete(int khuyenMaiId, int coSoId) {
        String sql = "DELETE FROM promotions WHERE promotion_id = ? AND facility_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, khuyenMaiId);
            ps.setInt(2, coSoId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("delete KhuyenMaiID={}: {}", khuyenMaiId, e.getMessage(), e);
        }
        return false;
    }

    @Override
    public boolean incrementUsage(Connection conn, int khuyenMaiId) {
        // Tăng SoLanDaDung chỉ khi TrangThai='Hoạt động' và (SoLanToiDa IS NULL OR SoLanDaDung < SoLanToiDa)
        String sql =
            "UPDATE promotions SET used_count = used_count + 1 " +
            "WHERE promotion_id = ? AND status = N'Hoạt động' " +
            "AND (max_usage_count IS NULL OR used_count < max_usage_count)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, khuyenMaiId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("incrementUsage KhuyenMaiID={}: {}", khuyenMaiId, e.getMessage(), e);
        }
        return false;
    }

    @Override
    public int countByCoSoId(int coSoId) {
        String sql = "SELECT COUNT(*) FROM promotions WHERE facility_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, coSoId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            logger.error("countByCoSoId coSoId={}: {}", coSoId, e.getMessage(), e);
        }
        return 0;
    }

    @Override
    public KhuyenMai findApplicable(String maCode, int coSoId, LocalDate today) {
        String sql =
            "SELECT * FROM promotions WHERE promo_code = ? AND facility_id = ? " +
            "AND status = N'Hoạt động' " +
            "AND start_date <= ? AND end_date >= ? " +
            "AND (max_usage_count IS NULL OR used_count < max_usage_count)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, maCode);
            ps.setInt(2, coSoId);
            ps.setDate(3, Date.valueOf(today));
            ps.setDate(4, Date.valueOf(today));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        } catch (SQLException e) {
            logger.error("findApplicable maCode={} coSoId={}: {}", maCode, coSoId, e.getMessage(), e);
        }
        return null;
    }

    @Override
    public List<KhuyenMai> findPublicActiveByCoSoId(int coSoId, LocalDate today) {
        List<KhuyenMai> list = new ArrayList<>();
        String sql = "SELECT km.* FROM promotions km " +
                "JOIN facilities c ON km.facility_id = c.facility_id " +
                "WHERE km.facility_id = ? " +
                "  AND km.status = N'Hoạt động' " +
                "  AND km.is_public = 1 " +
                "  AND km.start_date <= ? AND km.end_date >= ? " +
                "  AND (km.max_usage_count IS NULL OR km.used_count < km.max_usage_count) " +
                "  AND c.status = N'Đang hoạt động' AND (c.is_deleted = 0 OR c.is_deleted IS NULL) " +
                "ORDER BY km.start_date DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, coSoId);
            ps.setDate(2, Date.valueOf(today));
            ps.setDate(3, Date.valueOf(today));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (SQLException e) {
            logger.error("findPublicActiveByCoSoId coSoId={}: {}", coSoId, e.getMessage(), e);
        }
        return list;
    }

    @Override
    public List<KhuyenMai> findPublicActiveByCoSoIds(Collection<Integer> coSoIds, LocalDate today) {
        List<KhuyenMai> list = new ArrayList<>();
        if (coSoIds == null || coSoIds.isEmpty()) return list;
        List<Integer> ids = new ArrayList<>(new java.util.LinkedHashSet<>(coSoIds));
        String placeholders = String.join(",", java.util.Collections.nCopies(ids.size(), "?"));
        String sql = "SELECT km.* FROM promotions km " +
                "JOIN facilities c ON km.facility_id = c.facility_id " +
                "WHERE km.facility_id IN (" + placeholders + ") " +
                "  AND km.status = N'Hoạt động' " +
                "  AND km.is_public = 1 " +
                "  AND km.start_date <= ? AND km.end_date >= ? " +
                "  AND (km.max_usage_count IS NULL OR km.used_count < km.max_usage_count) " +
                "  AND c.status = N'Đang hoạt động' AND (c.is_deleted = 0 OR c.is_deleted IS NULL) " +
                "ORDER BY km.facility_id ASC, km.start_date DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            int idx = 1;
            for (Integer id : ids) ps.setInt(idx++, id);
            ps.setDate(idx++, Date.valueOf(today));
            ps.setDate(idx, Date.valueOf(today));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (SQLException e) {
            logger.error("findPublicActiveByCoSoIds: {}", e.getMessage(), e);
        }
        return list;
    }

    @Override
    public List<KhuyenMai> findPublicActiveAll(LocalDate today, int limit) {
        List<KhuyenMai> list = new ArrayList<>();
        String sql = "SELECT TOP (?) km.* FROM promotions km " +
                "JOIN facilities c ON km.facility_id = c.facility_id " +
                "WHERE km.status = N'Hoạt động' " +
                "  AND km.is_public = 1 " +
                "  AND km.start_date <= ? AND km.end_date >= ? " +
                "  AND (km.max_usage_count IS NULL OR km.used_count < km.max_usage_count) " +
                "  AND c.status = N'Đang hoạt động' AND (c.is_deleted = 0 OR c.is_deleted IS NULL) " +
                "ORDER BY km.start_date DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, Math.max(1, limit));
            ps.setDate(2, Date.valueOf(today));
            ps.setDate(3, Date.valueOf(today));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (SQLException e) {
            logger.error("findPublicActiveAll: {}", e.getMessage(), e);
        }
        return list;
    }

    private KhuyenMai map(ResultSet rs) throws SQLException {
        KhuyenMai km = new KhuyenMai();
        km.setKhuyenMaiID(rs.getInt("promotion_id"));
        km.setMaCode(rs.getString("promo_code"));
        km.setMoTa(rs.getString("description"));
        km.setLoaiGiam(rs.getString("discount_type"));
        km.setGiaTriGiam(rs.getDouble("discount_value"));
        Date nd = rs.getDate("start_date");
        if (nd != null) km.setNgayBatDau(nd.toLocalDate());
        Date nkt = rs.getDate("end_date");
        if (nkt != null) km.setNgayKetThuc(nkt.toLocalDate());
        int slt = rs.getInt("max_usage_count");
        if (!rs.wasNull()) km.setSoLanToiDa(slt);
        km.setSoLanDaDung(rs.getInt("used_count"));
        int coSo = rs.getInt("facility_id");
        if (!rs.wasNull()) km.setCoSoID(coSo);
        km.setTrangThai(rs.getString("status"));
        try {
            km.setGiaTriToiThieu(rs.getBigDecimal("min_order_amount"));
            km.setGiamToiDa(rs.getBigDecimal("max_discount_amount"));
        } catch (SQLException ignored) {
            // Cột có thể không tồn tại trên một số môi trường DB chưa chạy migration bổ sung.
        }
        try {
            km.setHienThiCongKhai(rs.getBoolean("is_public"));
        } catch (SQLException ignored) {
            // Môi trường chưa chạy migration_khuyenmai_hinhanh.sql - mặc định true (đã set ở model).
        }
        return km;
    }
}
