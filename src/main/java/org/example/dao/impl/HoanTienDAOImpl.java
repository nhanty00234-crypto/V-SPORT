package org.example.dao.impl;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.dao.HoanTienDAO;
import org.example.model.Hoantien;
import org.example.util.DBUtil;
import org.example.util.RefundStatus;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class HoanTienDAOImpl implements HoanTienDAO {

    private static final Logger logger = LogManager.getLogger(HoanTienDAOImpl.class);

    private static final String INSERT_SQL =
        "INSERT INTO HoanTien (HoaDonID, DatSanID, CoSoID, AccountID, SoTienHoan, SoTienDaThanhToan, " +
        "SoTienDeNghiHoan, LyDo, GhiChuKhachHang, TrangThai, ThoiGianYeuCau, UpdatedAt, " +
        "NganHangNhan, SoTaiKhoanNhan, ChuTaiKhoanNhan, QrNhanTienPath) " +
        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE(), GETDATE(), ?, ?, ?, ?)";

    @Override
    public int insert(Hoantien ht) {
        try (Connection conn = DBUtil.getConnection()) {
            return insert(conn, ht);
        } catch (SQLException e) {
            logger.error("insert HoanTien: {}", e.getMessage(), e);
            return 0;
        }
    }

    @Override
    public int insert(Connection conn, Hoantien ht) {
        try (PreparedStatement ps = conn.prepareStatement(INSERT_SQL, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, ht.getHoaDonId());
            setNullableInt(ps, 2, ht.getDatSanId());
            setNullableInt(ps, 3, ht.getCoSoId());
            ps.setInt(4, ht.getAccountId());
            // SoTienHoan giữ tương thích ngược với dữ liệu/luồng cũ - luôn bằng SoTienDeNghiHoan lúc tạo.
            BigDecimal deNghi = ht.getSoTienDeNghiHoan() != null ? ht.getSoTienDeNghiHoan() : ht.getSoTienHoan();
            ps.setBigDecimal(5, deNghi);
            ps.setBigDecimal(6, ht.getSoTienDaThanhToan());
            ps.setBigDecimal(7, deNghi);
            ps.setNString(8, truncate(ht.getLyDo(), 255));
            ps.setNString(9, truncate(ht.getGhiChuKhachHang(), 500));
            ps.setNString(10, ht.getTrangThai() != null ? ht.getTrangThai() : RefundStatus.CHO_XU_LY);
            ps.setNString(11, truncate(ht.getNganHangNhan(), 100));
            ps.setNString(12, truncate(ht.getSoTaiKhoanNhan(), 30));
            ps.setNString(13, truncate(ht.getChuTaiKhoanNhan(), 100));
            ps.setString(14, truncate(ht.getQrNhanTienPath(), 300));

            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            logger.error("insert HoanTien (conn): {}", e.getMessage(), e);
        }
        return 0;
    }

    @Override
    public Hoantien findById(int hoanTienId) {
        String sql = "SELECT ht.*, hd.DatSanID AS HD_DatSanID FROM HoanTien ht " +
                     "LEFT JOIN HoaDon hd ON ht.HoaDonID = hd.HoaDonID " +
                     "WHERE ht.HoanTienID = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, hoanTienId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        } catch (SQLException e) {
            logger.error("findById HoanTienID={}: {}", hoanTienId, e.getMessage(), e);
        }
        return null;
    }

    @Override
    public Hoantien findByIdAndAccountId(int hoanTienId, int accountId) {
        String sql = "SELECT ht.*, hd.DatSanID AS HD_DatSanID FROM HoanTien ht " +
                     "LEFT JOIN HoaDon hd ON ht.HoaDonID = hd.HoaDonID " +
                     "WHERE ht.HoanTienID = ? AND ht.AccountID = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, hoanTienId);
            ps.setInt(2, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        } catch (SQLException e) {
            logger.error("findByIdAndAccountId HoanTienID={} accountId={}: {}", hoanTienId, accountId, e.getMessage(), e);
        }
        return null;
    }

    @Override
    public Hoantien findByIdAndCoSoId(int hoanTienId, int coSoId) {
        String sql = "SELECT ht.*, hd.DatSanID AS HD_DatSanID FROM HoanTien ht " +
                     "LEFT JOIN HoaDon hd ON ht.HoaDonID = hd.HoaDonID " +
                     "WHERE ht.HoanTienID = ? AND ht.CoSoID = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, hoanTienId);
            ps.setInt(2, coSoId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        } catch (SQLException e) {
            logger.error("findByIdAndCoSoId HoanTienID={} coSoId={}: {}", hoanTienId, coSoId, e.getMessage(), e);
        }
        return null;
    }

    @Override
    public boolean existsActiveByHoaDonId(int hoaDonId) {
        String sql = "SELECT 1 FROM HoanTien WHERE HoaDonID = ? AND TrangThai NOT IN (?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, hoaDonId);
            ps.setNString(2, RefundStatus.TU_CHOI);
            ps.setNString(3, RefundStatus.DA_HUY);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            logger.error("existsActiveByHoaDonId HoaDonID={}: {}", hoaDonId, e.getMessage(), e);
            return false;
        }
    }

    @Override
    public List<Hoantien> findByCoSoId(int coSoId, int page, int pageSize) {
        List<Hoantien> list = new ArrayList<>();
        int offset = (Math.max(page, 1) - 1) * pageSize;
        String sql =
            "SELECT ht.*, hd.DatSanID AS HD_DatSanID FROM HoanTien ht " +
            "JOIN HoaDon hd ON ht.HoaDonID = hd.HoaDonID " +
            "WHERE ht.CoSoID = ? " +
            "ORDER BY ht.ThoiGianYeuCau DESC " +
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
    public List<Hoantien> findByCoSoIdAndTrangThai(int coSoId, String trangThai, int page, int pageSize) {
        List<Hoantien> list = new ArrayList<>();
        int offset = (Math.max(page, 1) - 1) * pageSize;
        String sql =
            "SELECT ht.*, hd.DatSanID AS HD_DatSanID FROM HoanTien ht " +
            "JOIN HoaDon hd ON ht.HoaDonID = hd.HoaDonID " +
            "WHERE ht.CoSoID = ? AND ht.TrangThai = ? " +
            "ORDER BY ht.ThoiGianYeuCau DESC " +
            "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, coSoId);
            ps.setNString(2, trangThai);
            ps.setInt(3, offset);
            ps.setInt(4, pageSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (SQLException e) {
            logger.error("findByCoSoIdAndTrangThai coSoId={} trangThai={}: {}", coSoId, trangThai, e.getMessage(), e);
        }
        return list;
    }

    @Override
    public List<Hoantien> findByAccountId(int accountId, int page, int pageSize) {
        List<Hoantien> list = new ArrayList<>();
        int offset = (Math.max(page, 1) - 1) * pageSize;
        String sql =
            "SELECT ht.*, hd.DatSanID AS HD_DatSanID FROM HoanTien ht " +
            "LEFT JOIN HoaDon hd ON ht.HoaDonID = hd.HoaDonID " +
            "WHERE ht.AccountID = ? " +
            "ORDER BY ht.ThoiGianYeuCau DESC " +
            "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            ps.setInt(2, offset);
            ps.setInt(3, pageSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (SQLException e) {
            logger.error("findByAccountId accountId={}: {}", accountId, e.getMessage(), e);
        }
        return list;
    }

    @Override
    public Hoantien findActiveByDatSanId(int datSanId) {
        String sql =
            "SELECT ht.*, hd.DatSanID AS HD_DatSanID FROM HoanTien ht " +
            "LEFT JOIN HoaDon hd ON ht.HoaDonID = hd.HoaDonID " +
            "WHERE (ht.DatSanID = ? OR hd.DatSanID = ?) AND ht.TrangThai NOT IN (?, ?) " +
            "ORDER BY ht.ThoiGianYeuCau DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, datSanId);
            ps.setInt(2, datSanId);
            ps.setNString(3, RefundStatus.TU_CHOI);
            ps.setNString(4, RefundStatus.DA_HUY);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        } catch (SQLException e) {
            logger.error("findActiveByDatSanId datSanId={}: {}", datSanId, e.getMessage(), e);
        }
        return null;
    }

    @Override
    public Map<Integer, Hoantien> findActiveMapByAccountId(int accountId) {
        Map<Integer, Hoantien> map = new HashMap<>();
        String sql =
            "SELECT ht.*, hd.DatSanID AS HD_DatSanID FROM HoanTien ht " +
            "LEFT JOIN HoaDon hd ON ht.HoaDonID = hd.HoaDonID " +
            "WHERE ht.AccountID = ? AND ht.TrangThai NOT IN (?, ?) " +
            "ORDER BY ht.ThoiGianYeuCau DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            ps.setNString(2, RefundStatus.TU_CHOI);
            ps.setNString(3, RefundStatus.DA_HUY);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Hoantien ht = map(rs);
                    int dsId = ht.getDatSanId();
                    if (dsId > 0 && !map.containsKey(dsId)) {
                        map.put(dsId, ht);
                    }
                }
            }
        } catch (SQLException e) {
            logger.error("findActiveMapByAccountId accountId={}: {}", accountId, e.getMessage(), e);
        }
        return map;
    }

    @Override
    public boolean updateTrangThai(int hoanTienId, String trangThaiCu, String trangThaiMoi,
                                    Integer accountIdNguoiXuLy, String ghiChuXuLy, String maGiaoDichHoan,
                                    String lyDoTuChoi, BigDecimal soTienDuocDuyet) {
        if (!RefundStatus.isValid(trangThaiMoi) || !RefundStatus.isValid(trangThaiCu)) {
            logger.warn("updateTrangThai: trạng thái không hợp lệ cũ='{}' mới='{}'", trangThaiCu, trangThaiMoi);
            return false;
        }

        StringBuilder sql = new StringBuilder("UPDATE HoanTien SET TrangThai = ?, UpdatedAt = GETDATE()");
        List<Object> params = new ArrayList<>();
        params.add(trangThaiMoi);

        if (accountIdNguoiXuLy != null) {
            sql.append(", AccountID_NguoiXuLy = ?");
            params.add(accountIdNguoiXuLy);
        }
        if (ghiChuXuLy != null) {
            sql.append(", GhiChuXuLy = ?");
            params.add(truncate(ghiChuXuLy, 500));
        }
        if (maGiaoDichHoan != null) {
            sql.append(", MaGiaoDichHoan = ?");
            params.add(truncate(maGiaoDichHoan, 100));
        }
        if (lyDoTuChoi != null) {
            sql.append(", LyDoTuChoi = ?");
            params.add(truncate(lyDoTuChoi, 500));
        }
        if (soTienDuocDuyet != null) {
            sql.append(", SoTienDuocDuyet = ?");
            params.add(soTienDuocDuyet);
        }
        sql.append(", ThoiGianXuLy = GETDATE()");
        if (RefundStatus.DA_DUYET.equals(trangThaiMoi)) {
            sql.append(", ApprovedAt = GETDATE()");
        }
        if (RefundStatus.DA_HOAN_TIEN.equals(trangThaiMoi)) {
            sql.append(", ThoiGianHoan = GETDATE(), CompletedAt = GETDATE()");
        }
        sql.append(" WHERE HoanTienID = ? AND TrangThai = ?");
        params.add(hoanTienId);
        params.add(trangThaiCu);

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            bindParams(ps, params);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("updateTrangThai HoanTienID={}: {}", hoanTienId, e.getMessage(), e);
            return false;
        }
    }

    @Override
    public boolean updateBankInfo(int hoanTienId, int accountId,
                                   String nganHangNhan, String soTaiKhoanNhan, String chuTaiKhoanNhan,
                                   String qrNhanTienPath) {
        String sql =
            "UPDATE HoanTien SET NganHangNhan = ?, SoTaiKhoanNhan = ?, ChuTaiKhoanNhan = ?, " +
            "QrNhanTienPath = ?, UpdatedAt = GETDATE(), " +
            "TrangThai = CASE WHEN TrangThai = ? THEN ? ELSE TrangThai END " +
            "WHERE HoanTienID = ? AND AccountID = ? AND TrangThai IN (?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setNString(1, truncate(nganHangNhan, 100));
            ps.setNString(2, truncate(soTaiKhoanNhan, 30));
            ps.setNString(3, truncate(chuTaiKhoanNhan, 100));
            ps.setString(4, truncate(qrNhanTienPath, 300));
            // Bổ sung thông tin xong -> tự chuyển từ CHO_BO_SUNG_THONG_TIN sang CHO_XU_LY.
            ps.setNString(5, RefundStatus.CHO_BO_SUNG_THONG_TIN);
            ps.setNString(6, RefundStatus.CHO_XU_LY);
            ps.setInt(7, hoanTienId);
            ps.setInt(8, accountId);
            ps.setNString(9, RefundStatus.CHO_BO_SUNG_THONG_TIN);
            ps.setNString(10, RefundStatus.CHO_XU_LY);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("updateBankInfo HoanTienID={}: {}", hoanTienId, e.getMessage(), e);
            return false;
        }
    }

    @Override
    public boolean updateQrPath(int hoanTienId, int accountId, String qrNhanTienPath) {
        String sql =
            "UPDATE HoanTien SET QrNhanTienPath = ?, UpdatedAt = GETDATE() " +
            "WHERE HoanTienID = ? AND AccountID = ? AND TrangThai IN (?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, truncate(qrNhanTienPath, 300));
            ps.setInt(2, hoanTienId);
            ps.setInt(3, accountId);
            ps.setNString(4, RefundStatus.CHO_BO_SUNG_THONG_TIN);
            ps.setNString(5, RefundStatus.CHO_XU_LY);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("updateQrPath HoanTienID={}: {}", hoanTienId, e.getMessage(), e);
            return false;
        }
    }

    private Hoantien map(ResultSet rs) throws SQLException {
        Hoantien ht = new Hoantien();
        ht.setHoanTienId(rs.getInt("HoanTienID"));
        ht.setHoaDonId(rs.getInt("HoaDonID"));
        ht.setAccountId(rs.getInt("AccountID"));
        BigDecimal st = rs.getBigDecimal("SoTienHoan");
        ht.setSoTienHoan(st != null ? st : BigDecimal.ZERO);
        ht.setLyDo(rs.getString("LyDo"));
        ht.setTrangThai(rs.getString("TrangThai"));
        ht.setThoiGianYeuCau(rs.getTimestamp("ThoiGianYeuCau"));
        ht.setThoiGianHoan(rs.getTimestamp("ThoiGianHoan"));

        int xuLy = rs.getInt("AccountID_NguoiXuLy");
        if (!rs.wasNull()) ht.setAccountIdNguoiXuLy(xuLy);
        ht.setGhiChuXuLy(rs.getString("GhiChuXuLy"));
        ht.setMaGiaoDichHoan(rs.getString("MaGiaoDichHoan"));
        ht.setThoiGianXuLy(rs.getTimestamp("ThoiGianXuLy"));
        ht.setNganHangNhan(rs.getString("NganHangNhan"));
        ht.setSoTaiKhoanNhan(rs.getString("SoTaiKhoanNhan"));
        ht.setChuTaiKhoanNhan(rs.getString("ChuTaiKhoanNhan"));

        int datSanId = getNullableInt(rs, "DatSanID");
        if (datSanId == 0) datSanId = getNullableInt(rs, "HD_DatSanID");
        if (datSanId != 0) ht.setDatSanId(datSanId);

        int coSoId = getNullableInt(rs, "CoSoID");
        if (coSoId != 0) ht.setCoSoId(coSoId);

        ht.setSoTienDaThanhToan(rs.getBigDecimal("SoTienDaThanhToan"));
        ht.setSoTienDeNghiHoan(rs.getBigDecimal("SoTienDeNghiHoan"));
        ht.setSoTienDuocDuyet(rs.getBigDecimal("SoTienDuocDuyet"));
        ht.setQrNhanTienPath(rs.getString("QrNhanTienPath"));
        ht.setGhiChuKhachHang(rs.getString("GhiChuKhachHang"));
        ht.setLyDoTuChoi(rs.getString("LyDoTuChoi"));
        ht.setApprovedAt(rs.getTimestamp("ApprovedAt"));
        ht.setCompletedAt(rs.getTimestamp("CompletedAt"));
        ht.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
        return ht;
    }

    private static int getNullableInt(ResultSet rs, String col) throws SQLException {
        try {
            int v = rs.getInt(col);
            return rs.wasNull() ? 0 : v;
        } catch (SQLException e) {
            return 0;
        }
    }

    private static void setNullableInt(PreparedStatement ps, int idx, Integer v) throws SQLException {
        if (v != null) ps.setInt(idx, v);
        else ps.setNull(idx, Types.INTEGER);
    }

    private static void bindParams(PreparedStatement ps, List<Object> params) throws SQLException {
        for (int i = 0; i < params.size(); i++) {
            Object p = params.get(i);
            int idx = i + 1;
            if (p instanceof Integer) ps.setInt(idx, (Integer) p);
            else if (p instanceof BigDecimal) ps.setBigDecimal(idx, (BigDecimal) p);
            else if (p instanceof String) ps.setNString(idx, (String) p);
            else ps.setObject(idx, p);
        }
    }

    private String truncate(String s, int max) {
        if (s == null) return null;
        s = s.trim();
        return s.length() > max ? s.substring(0, max) : s;
    }
}
