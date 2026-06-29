package org.example.dao.impl;

import org.example.dao.ThongBaoDAO;
import org.example.model.ThongBao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

/**
 * Implementation của ThongBaoDAO sử dụng JDBC
 */
public class ThongBaoDAOImpl implements ThongBaoDAO {

    private static final Logger logger = LogManager.getLogger(ThongBaoDAOImpl.class);

    @Override
    public int insert(ThongBao thongBao) {
        String sql = "INSERT INTO ThongBao (AccountID, TieuDe, NoiDung, LoaiThongBao, DaDoc, ThoiGianGui, MaBanGhi, DuongDan) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = org.example.util.DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, thongBao.getAccountId());
            ps.setNString(2, thongBao.getTieuDe());
            ps.setNString(3, thongBao.getNoiDung());
            ps.setNString(4, thongBao.getLoaiThongBao());
            ps.setBoolean(5, thongBao.getDaDoc());
            ps.setTimestamp(6, new Timestamp(thongBao.getThoiGianGui().getTime()));
            ps.setString(7, thongBao.getMaBanGhi());
            ps.setString(8, thongBao.getDuongDan());

            int affectedRows = ps.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        return generatedKeys.getInt(1);
                    }
                }
            }
            return 0;
        } catch (SQLException e) {
            logger.error("Lỗi khi thêm thông báo mới: {}", e.getMessage(), e);
            return 0;
        }
    }

    @Override
    public boolean update(ThongBao thongBao) {
        String sql = "UPDATE ThongBao SET AccountID=?, TieuDe=?, NoiDung=?, LoaiThongBao=?, DaDoc=?, ThoiGianGui=?, MaBanGhi=?, DuongDan=? WHERE ThongBaoID=?";

        try (Connection conn = org.example.util.DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, thongBao.getAccountId());
            ps.setNString(2, thongBao.getTieuDe());
            ps.setNString(3, thongBao.getNoiDung());
            ps.setNString(4, thongBao.getLoaiThongBao());
            ps.setBoolean(5, thongBao.getDaDoc());
            ps.setTimestamp(6, new Timestamp(thongBao.getThoiGianGui().getTime()));
            ps.setString(7, thongBao.getMaBanGhi());
            ps.setString(8, thongBao.getDuongDan());
            ps.setInt(9, thongBao.getThongBaoId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Lỗi khi cập nhật thông báo ID {}: {}", thongBao.getThongBaoId(), e.getMessage(), e);
            return false;
        }
    }

    @Override
    public boolean delete(int thongBaoId) {
        String sql = "DELETE FROM ThongBao WHERE ThongBaoID = ?";

        try (Connection conn = org.example.util.DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, thongBaoId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Lỗi khi xóa thông báo với ID {}: {}", thongBaoId, e.getMessage(), e);
            return false;
        }
    }

    @Override
    public ThongBao findById(int thongBaoId) {
        String sql = "SELECT * FROM ThongBao WHERE ThongBaoID = ?";

        try (Connection conn = org.example.util.DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, thongBaoId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToThongBao(rs);
                }
            }
        } catch (SQLException e) {
            logger.error("Lỗi khi lấy thông báo với ID {}: {}", thongBaoId, e.getMessage(), e);
        }
        return null;
    }

    @Override
    public List<ThongBao> findAll() {
        List<ThongBao> list = new ArrayList<>();
        String sql = "SELECT * FROM ThongBao ORDER BY ThoiGianGui DESC";

        try (Connection conn = org.example.util.DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapResultSetToThongBao(rs));
            }
        } catch (SQLException e) {
            logger.error("Lỗi khi lấy tất cả thông báo: {}", e.getMessage(), e);
        }
        return list;
    }

    @Override
    public List<ThongBao> findByAccountID(int accountId) {
        List<ThongBao> list = new ArrayList<>();
        String sql = "SELECT * FROM ThongBao WHERE AccountID = ? ORDER BY ThoiGianGui DESC";

        try (Connection conn = org.example.util.DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToThongBao(rs));
                }
            }
        } catch (SQLException e) {
            logger.error("Lỗi khi lấy thông báo theo account ID {}: {}", accountId, e.getMessage(), e);
        }
        return list;
    }

    @Override
    public boolean markAsRead(int thongBaoId) {
        String sql = "UPDATE ThongBao SET DaDoc = 1 WHERE ThongBaoID = ?";

        try (Connection conn = org.example.util.DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, thongBaoId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Lỗi khi đánh dấu thông báo đã đọc ID {}: {}", thongBaoId, e.getMessage(), e);
            return false;
        }
    }

    private ThongBao mapResultSetToThongBao(ResultSet rs) throws SQLException {
        ThongBao tb = new ThongBao();
        tb.setThongBaoId(rs.getInt("ThongBaoID"));
        tb.setAccountId(rs.getInt("AccountID"));
        tb.setTieuDe(rs.getString("TieuDe"));
        tb.setNoiDung(rs.getString("NoiDung"));
        tb.setLoaiThongBao(rs.getString("LoaiThongBao"));
        tb.setDaDoc(rs.getBoolean("DaDoc"));
        tb.setThoiGianGui(rs.getTimestamp("ThoiGianGui"));
        tb.setMaBanGhi(rs.getString("MaBanGhi"));
        tb.setDuongDan(rs.getString("DuongDan"));
        return tb;
    }
}
