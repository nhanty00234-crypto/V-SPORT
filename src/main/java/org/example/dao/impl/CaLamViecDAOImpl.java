package org.example.dao.impl;

import org.example.dao.CaLamViecDAO;
import org.example.model.CaLamViec;
import org.example.util.DBUtil;

import java.sql.*;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

/**
 * Lớp triển khai các phương thức CRUD cho bảng CaLamViec
 * Quản lý thông tin ca làm việc của nhân viên tại các cơ sở
 */
public class CaLamViecDAOImpl implements CaLamViecDAO {

    private static final Logger logger = LogManager.getLogger(CaLamViecDAOImpl.class);

    /**
     * Lấy tất cả ca làm việc trong hệ thống
     * @return Danh sách tất cả ca làm việc
     */
    @Override
    public List<CaLamViec> getAllCaLamViec() {
        List<CaLamViec> list = new ArrayList<>();
        String sql = "SELECT * FROM work_shifts WHERE is_deleted = 0";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapResultSetToCaLamViec(rs));
            }
        } catch (SQLException e) {
            logger.error("Lỗi khi lấy tất cả ca làm việc: {}", e.getMessage(), e);
        }
        return list;
    }

    /**
     * Lấy danh sách ca làm việc theo cơ sở cụ thể
     * @param coSoId ID của cơ sở cần lấy ca làm việc
     * @return Danh sách ca làm việc thuộc cơ sở
     */
    @Override
    public List<CaLamViec> getCaByCoSo(int coSoId) {
        List<CaLamViec> list = new ArrayList<>();
        String sql = "SELECT * FROM work_shifts WHERE facility_id = ? AND is_deleted = 0";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, coSoId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToCaLamViec(rs));
                }
            }
        } catch (SQLException e) {
            logger.error("Lỗi khi lấy ca làm việc theo cơ sở ID {}: {}", coSoId, e.getMessage(), e);
        }
        return list;
    }

    /**
     * Lấy thông tin ca làm việc theo ID
     * @param id ID của ca làm việc cần tìm
     * @return Đối tượng CaLamViec nếu tìm thấy, null nếu không tồn tại
     */
    @Override
    public CaLamViec getCaById(int id) {
        String sql = "SELECT * FROM work_shifts WHERE work_shift_id = ? AND is_deleted = 0";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToCaLamViec(rs);
                }
            }
        } catch (SQLException e) {
            logger.error("Lỗi khi lấy ca làm việc với ID {}: {}", id, e.getMessage(), e);
        }
        return null;
    }

    /**
     * Thêm mới một ca làm việc vào database
     * @param ca Đối tượng CaLamViec cần thêm (có thể là ca theo ngày cụ thể hoặc ca định kỳ theo thứ)
     * @return true nếu thêm thành công, false nếu thất bại
     */
    @Override
    public boolean addCaLamViec(CaLamViec ca) {
        String sql = "INSERT INTO work_shifts (account_id, facility_id, work_date, start_time, end_time, note, day_of_week, is_published, shift_name, position, status, break_minutes, is_custom_time, custom_time_reason) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, ca.getAccountId());
            ps.setInt(2, ca.getCoSoId());
            if (ca.getNgayLam() != null) {
                ps.setDate(3, Date.valueOf(ca.getNgayLam()));
            } else {
                ps.setNull(3, Types.DATE);
            }
            ps.setTime(4, Time.valueOf(ca.getGioBatDau()));
            ps.setTime(5, Time.valueOf(ca.getGioKetThuc()));
            ps.setString(6, ca.getGhiChu());
            if (ca.getThu() != null) {
                ps.setInt(7, ca.getThu());
            } else {
                ps.setNull(7, Types.INTEGER);
            }
            ps.setBoolean(8, ca.isPublished());
            ps.setString(9, ca.getTenCa());
            ps.setString(10, ca.getViTri());
            ps.setString(11, ca.getTrangThai() != null ? ca.getTrangThai() : "Draft");
            ps.setInt(12, ca.getGioNghi());
            ps.setBoolean(13, ca.isCustomTime());
            ps.setNString(14, ca.getCustomTimeReason());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            logger.error("Lỗi khi thêm ca làm việc mới: {}", e.getMessage(), e);
        }
        return false;
    }

    @Override
    public int addCaLamViecWithConnection(CaLamViec ca, Connection conn) throws SQLException {
        String sql = "INSERT INTO work_shifts (account_id, facility_id, work_date, start_time, end_time, note, day_of_week, is_published, shift_name, position, status, break_minutes, is_custom_time, custom_time_reason) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, ca.getAccountId());
            ps.setInt(2, ca.getCoSoId());
            if (ca.getNgayLam() != null) {
                ps.setDate(3, Date.valueOf(ca.getNgayLam()));
            } else {
                ps.setNull(3, Types.DATE);
            }
            ps.setTime(4, Time.valueOf(ca.getGioBatDau()));
            ps.setTime(5, Time.valueOf(ca.getGioKetThuc()));
            ps.setString(6, ca.getGhiChu());
            if (ca.getThu() != null) {
                ps.setInt(7, ca.getThu());
            } else {
                ps.setNull(7, Types.INTEGER);
            }
            ps.setBoolean(8, ca.isPublished());
            ps.setString(9, ca.getTenCa());
            ps.setString(10, ca.getViTri());
            ps.setString(11, ca.getTrangThai() != null ? ca.getTrangThai() : "Draft");
            ps.setInt(12, ca.getGioNghi());
            ps.setBoolean(13, ca.isCustomTime());
            ps.setNString(14, ca.getCustomTimeReason());

            int rows = ps.executeUpdate();
            if (rows == 0) return -1;
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    int generatedId = keys.getInt(1);
                    ca.setCaLamViecId(generatedId);
                    return generatedId;
                }
            }
            return -1;
        }
    }

    /**
     * Cập nhật thông tin ca làm việc
     * @param ca Đối tượng CaLamViec chứa thông tin mới (phải có caLamViecId)
     * @return true nếu cập nhật thành công, false nếu thất bại
     */
    @Override
    public boolean updateCaLamViec(CaLamViec ca) {
        String sql = "UPDATE work_shifts SET account_id=?, facility_id=?, work_date=?, start_time=?, end_time=?, note=?, day_of_week=?, is_published=?, shift_name=?, position=?, status=?, break_minutes=?, is_custom_time=?, custom_time_reason=? WHERE work_shift_id=?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, ca.getAccountId());
            ps.setInt(2, ca.getCoSoId());
            if (ca.getNgayLam() != null) {
                ps.setDate(3, Date.valueOf(ca.getNgayLam()));
            } else {
                ps.setNull(3, Types.DATE);
            }
            ps.setTime(4, Time.valueOf(ca.getGioBatDau()));
            ps.setTime(5, Time.valueOf(ca.getGioKetThuc()));
            ps.setNString(6, ca.getGhiChu());
            if (ca.getThu() != null) {
                ps.setInt(7, ca.getThu());
            } else {
                ps.setNull(7, Types.INTEGER);
            }
            ps.setBoolean(8, ca.isPublished());
            ps.setString(9, ca.getTenCa());
            ps.setString(10, ca.getViTri());
            ps.setString(11, ca.getTrangThai() != null ? ca.getTrangThai() : "Draft");
            ps.setInt(12, ca.getGioNghi());
            ps.setBoolean(13, ca.isCustomTime());
            ps.setNString(14, ca.getCustomTimeReason());
            ps.setInt(15, ca.getCaLamViecId());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            logger.error("Lỗi khi cập nhật ca làm việc ID {}: {}", ca.getCaLamViecId(), e.getMessage(), e);
        }
        return false;
    }

    /**
     * Xóa cứng một ca làm việc theo ID (xóa khỏi DB)
     * @param id ID của ca làm việc cần xóa
     * @return true nếu xóa thành công, false nếu thất bại
     */
    @Override
    public boolean hardDelete(int id) {
        String sql = "DELETE FROM work_shifts WHERE work_shift_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            logger.error("Lỗi khi xóa ca làm việc với ID {}: {}", id, e.getMessage(), e);
        }
        return false;
    }

    @Override
    public boolean softDelete(int id, int actorId) {
        String sql = "UPDATE work_shifts SET is_deleted = 1, deleted_at = GETDATE(), deleted_by = ? " +
                     "WHERE work_shift_id = ? AND is_deleted = 0";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, actorId);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Lỗi soft delete ca làm việc ID {}: {}", id, e.getMessage(), e);
            return false;
        }
    }

    @Override
    public boolean restore(int id) {
        String sql = "UPDATE work_shifts SET is_deleted = 0, deleted_at = NULL, deleted_by = NULL " +
                     "WHERE work_shift_id = ? AND is_deleted = 1";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Lỗi restore ca làm việc ID {}: {}", id, e.getMessage(), e);
            return false;
        }
    }

    @Override
    public List<CaLamViec> findDeletedByCoSo(int coSoId) {
        List<CaLamViec> list = new ArrayList<>();
        String sql = "SELECT * FROM work_shifts WHERE facility_id = ? AND is_deleted = 1 ORDER BY deleted_at DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, coSoId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToCaLamViec(rs));
                }
            }
        } catch (SQLException e) {
            logger.error("Lỗi findDeletedByCoSo ca làm việc coSoId {}: {}", coSoId, e.getMessage(), e);
        }
        return list;
    }

    @Override
    public List<Integer> findDeletedIdsOlderThan(int days) {
        List<Integer> ids = new ArrayList<>();
        String sql = "SELECT work_shift_id FROM work_shifts " +
                     "WHERE is_deleted = 1 AND deleted_at < DATEADD(day, -?, GETDATE())";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, days);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ids.add(rs.getInt("work_shift_id"));
                }
            }
        } catch (SQLException e) {
            logger.error("Lỗi findDeletedIdsOlderThan ca làm việc days {}: {}", days, e.getMessage(), e);
        }
        return ids;
    }

    /**
     * Xóa các ca làm việc của nhân viên vào một ngày cụ thể
     * @param accountId ID của nhân viên
     * @param ngayLam Ngày làm việc cần xóa ca
     * @return true nếu xóa thành công, false nếu thất bại
     */
    @Override
    public boolean deleteByAccountIDAndNgayLam(int accountId, LocalDate ngayLam) {
        String sql = "DELETE FROM work_shifts WHERE account_id = ? AND work_date = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            ps.setDate(2, Date.valueOf(ngayLam));
            int rowsDeleted = ps.executeUpdate();
            return rowsDeleted > 0;
        } catch (SQLException e) {
            logger.error("Lỗi khi xóa ca làm việc theo account {} và ngày {}: {}", accountId, ngayLam, e.getMessage(), e);
            return false;
        }
    }

    @Override
    public List<CaLamViec> getCaByAccountIDAndDateRange(int accountId, LocalDate startDate, LocalDate endDate) {
        List<CaLamViec> list = new ArrayList<>();
        String sql = "SELECT * FROM work_shifts WHERE account_id = ? AND work_date BETWEEN ? AND ? AND is_deleted = 0 ORDER BY work_date, start_time";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, accountId);
            ps.setDate(2, Date.valueOf(startDate));
            ps.setDate(3, Date.valueOf(endDate));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToCaLamViec(rs));
                }
            }
        } catch (SQLException e) {
            logger.error("Lỗi khi lấy ca làm theo khoảng ngày: {}", e.getMessage(), e);
        }
        return list;
    }

    @Override
    public List<CaLamViec> getShiftsByAccountAndDateRange(int accountId, LocalDate startDate, LocalDate endDate) {
        return getCaByAccountIDAndDateRange(accountId, startDate, endDate);
    }

    @Override
    public List<CaLamViec> getRecurringShiftsByAccountID(int accountId) {
        List<CaLamViec> list = new ArrayList<>();
        String sql = "SELECT * FROM work_shifts WHERE account_id = ? AND day_of_week IS NOT NULL AND is_deleted = 0 ORDER BY day_of_week, start_time";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, accountId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToCaLamViec(rs));
                }
            }
        } catch (SQLException e) {
            logger.error("Lỗi khi lấy ca định kỳ: {}", e.getMessage(), e);
        }
        return list;
    }

    @Override
    public long getTotalCaLamViec() {
        String sql = "SELECT COUNT(*) FROM work_shifts WHERE is_deleted = 0";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getLong(1);
            }
        } catch (SQLException e) {
            logger.error("Lỗi khi đếm tổng số ca làm việc: {}", e.getMessage(), e);
        }
        return 0;
    }

    /**
     * Chuyển đổi ResultSet thành đối tượng CaLamViec
     * Phương thức private hỗ trợ cho các phương thức CRUD
     * @param rs ResultSet từ database
     * @return Đối tượng CaLamViec đã được map
     * @throws SQLException nếu có lỗi khi đọc dữ liệu
     */
    /**
     * Kiểm tra xem có xung đột lịch ca làm không
     * Hai ca làm xung đột nếu thời gian của chúng chồng chéo nhau
     * @param accountId ID của nhân viên
     * @param ngayLam Ngày làm việc cần kiểm tra
     * @param gioBatDau Giờ bắt đầu ca mới
     * @param gioKetThuc Giờ kết thúc ca mới
     * @param excludeCaLamViecId ID của ca làm việc cần bỏ qua (khi update, có thể null)
     * @return true nếu có xung đột, false nếu không có
     */
    @Override
    public boolean checkShiftConflict(int accountId, LocalDate ngayLam, LocalTime gioBatDau, LocalTime gioKetThuc, Integer excludeCaLamViecId) {
        String sql = "SELECT * FROM work_shifts WHERE account_id = ? AND work_date = ? AND is_deleted = 0";

        // Nếu đang update, bỏ qua chính record đang update
        if (excludeCaLamViecId != null) {
            sql += " AND CaLamViecID != ?";
        }

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, accountId);
            ps.setDate(2, Date.valueOf(ngayLam));

            if (excludeCaLamViecId != null) {
                ps.setInt(3, excludeCaLamViecId);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CaLamViec existingCa = mapResultSetToCaLamViec(rs);

                    // Kiểm tra overlap: newStart < existingEnd AND newEnd > existingStart
                    boolean isOverlap = gioBatDau.isBefore(existingCa.getGioKetThuc()) &&
                                        gioKetThuc.isAfter(existingCa.getGioBatDau());

                    if (isOverlap) {
                        return true; // Có xung đột
                    }
                }
            }
        } catch (SQLException e) {
            logger.error("Lỗi khi kiểm tra xung đột ca làm: {}", e.getMessage(), e);
        }
        return false; // Không có xung đột
    }

    /**
     * Chuyển đổi ResultSet thành đối tượng CaLamViec
     * Phương thức private hỗ trợ cho các phương thức CRUD và checkShiftConflict
     * @param rs ResultSet từ database
     * @return Đối tượng CaLamViec đã được map
     * @throws SQLException nếu có lỗi khi đọc dữ liệu
     */
    private CaLamViec mapResultSetToCaLamViec(ResultSet rs) throws SQLException {
        CaLamViec ca = new CaLamViec();
        ca.setCaLamViecId(rs.getInt("work_shift_id"));
        ca.setAccountId(rs.getInt("account_id"));
        ca.setCoSoId(rs.getInt("facility_id"));

        // Chuyển đổi từ SQL Date sang LocalDate
        Date ngayLamSql = rs.getDate("work_date");
        if (ngayLamSql != null) {
            ca.setNgayLam(ngayLamSql.toLocalDate());
        }

        // Chuyển đổi từ SQL Time sang LocalTime
        Time gioBatDauSql = rs.getTime("start_time");
        if (gioBatDauSql != null) {
            ca.setGioBatDau(gioBatDauSql.toLocalTime());
        }

        Time gioKetThucSql = rs.getTime("end_time");
        if (gioKetThucSql != null) {
            ca.setGioKetThuc(gioKetThucSql.toLocalTime());
        }

        ca.setGhiChu(rs.getNString("note"));

        // Đọc trường Thu (có thể null)
        int thu = rs.getInt("day_of_week");
        if (!rs.wasNull()) {
            ca.setThu(thu);
        }

        ca.setPublished(rs.getBoolean("is_published"));
        ca.setTenCa(rs.getNString("shift_name"));
        ca.setViTri(rs.getNString("position"));
        ca.setTrangThai(rs.getString("status"));
        ca.setGioNghi(rs.getInt("break_minutes"));
        ca.setCustomTime(rs.getBoolean("is_custom_time"));
        ca.setCustomTimeReason(rs.getNString("custom_time_reason"));
        ca.setDeleted(rs.getBoolean("is_deleted"));
        Timestamp deletedAtTs = rs.getTimestamp("deleted_at");
        if (deletedAtTs != null) {
            ca.setDeletedAt(deletedAtTs.toLocalDateTime());
        }
        int deletedBy = rs.getInt("deleted_by");
        if (!rs.wasNull()) {
            ca.setDeletedBy(deletedBy);
        }
        try {
            Timestamp vaoThuc = rs.getTimestamp("actual_check_in_at");
            if (vaoThuc != null) ca.setGioVaoThuc(vaoThuc.toLocalDateTime());
            Timestamp raThuc = rs.getTimestamp("actual_check_out_at");
            if (raThuc != null) ca.setGioRaThuc(raThuc.toLocalDateTime());
        } catch (SQLException ignored) {}

        return ca;
    }

    @Override
    public boolean updateCaLamViecWithConnection(CaLamViec ca, Connection conn) throws SQLException {
        String sql = "UPDATE work_shifts SET account_id=?, facility_id=?, work_date=?, start_time=?, end_time=?, note=?, day_of_week=?, is_published=?, shift_name=?, position=?, status=?, break_minutes=?, is_custom_time=?, custom_time_reason=? WHERE work_shift_id=?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, ca.getAccountId());
            ps.setInt(2, ca.getCoSoId());
            if (ca.getNgayLam() != null) {
                ps.setDate(3, Date.valueOf(ca.getNgayLam()));
            } else {
                ps.setNull(3, Types.DATE);
            }
            ps.setTime(4, Time.valueOf(ca.getGioBatDau()));
            ps.setTime(5, Time.valueOf(ca.getGioKetThuc()));
            ps.setNString(6, ca.getGhiChu());
            if (ca.getThu() != null) {
                ps.setInt(7, ca.getThu());
            } else {
                ps.setNull(7, Types.INTEGER);
            }
            ps.setBoolean(8, ca.isPublished());
            ps.setString(9, ca.getTenCa());
            ps.setString(10, ca.getViTri());
            ps.setString(11, ca.getTrangThai() != null ? ca.getTrangThai() : "Draft");
            ps.setInt(12, ca.getGioNghi());
            ps.setBoolean(13, ca.isCustomTime());
            ps.setNString(14, ca.getCustomTimeReason());
            ps.setInt(15, ca.getCaLamViecId());
            return ps.executeUpdate() > 0;
        }
    }

    @Override
    public int publishDraftShiftsWithConnection(LocalDate startOfWeek, LocalDate endOfWeek, int coSoId, Connection conn) throws SQLException {
        String sql = "UPDATE work_shifts SET status = 'Published', is_published = 1 " +
                     "WHERE facility_id = ? AND work_date BETWEEN ? AND ? AND status = 'Draft' AND is_deleted = 0";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, coSoId);
            ps.setDate(2, Date.valueOf(startOfWeek));
            ps.setDate(3, Date.valueOf(endOfWeek));
            return ps.executeUpdate();
        }
    }

    @Override
    public boolean publishWeekShifts(LocalDate startOfWeek, LocalDate endOfWeek, int coSoId) {
        String sql = "UPDATE work_shifts SET is_published = 1 WHERE facility_id = ? AND work_date BETWEEN ? AND ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, coSoId);
            ps.setDate(2, Date.valueOf(startOfWeek));
            ps.setDate(3, Date.valueOf(endOfWeek));
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Error publishing week shifts: {}", e.getMessage(), e);
            return false;
        }
    }

    @Override
    public List<CaLamViec> getShiftsByCoSoAndDateRange(int coSoId, LocalDate start, LocalDate end) {
        List<CaLamViec> list = new ArrayList<>();
        String sql = "SELECT * FROM work_shifts WHERE facility_id = ? AND work_date BETWEEN ? AND ? AND is_deleted = 0 ORDER BY work_date, start_time";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, coSoId);
            ps.setDate(2, Date.valueOf(start));
            ps.setDate(3, Date.valueOf(end));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToCaLamViec(rs));
                }
            }
        } catch (SQLException e) {
            logger.error("Error getting shifts by CoSo and range: {}", e.getMessage(), e);
        }
        return list;
    }

}
