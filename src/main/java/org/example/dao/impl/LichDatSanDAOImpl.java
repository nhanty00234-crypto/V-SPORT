package org.example.dao.impl;

import org.example.dao.LichDatSanDAO;
import org.example.model.Lichdatsan;
import org.example.util.DBUtil;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalTime;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class LichDatSanDAOImpl implements LichDatSanDAO {

    private static final Logger logger = LogManager.getLogger(LichDatSanDAOImpl.class);

    private boolean columnExists(Connection conn, String tableName, String columnName) throws SQLException {
        String sql = "SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(?) AND name = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setNString(1, tableName);
            ps.setNString(2, columnName);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private String mainInvoiceWhereClause(Connection conn, String datSanColumnExpression) throws SQLException {
        if (columnExists(conn, "invoices", "invoice_type")) {
            return datSanColumnExpression + " = ? AND (LoaiHoaDon = N'MAIN' OR LoaiHoaDon IS NULL)";
        }
        return datSanColumnExpression + " = ?";
    }

    /**
     * Đếm số lượt đặt sân "đang hoạt động" (chưa hủy) của một khách trong một ngày, dùng để
     * áp giới hạn tối đa 3 lượt/ngày. Nguồn sự thật duy nhất - dùng chung bởi DatSanServlet
     * (bước submit booking chính thức) và SoftHoldDAOImpl.createHold() (bước giữ chỗ tạm), để
     * một khách đã đạt giới hạn không thể tạo SoftHold chặn slot của người khác dù chưa đặt được.
     * Nhận Connection từ caller để dùng chung transaction khi caller đã mở sẵn.
     * Chỉ đếm các trạng thái thực sự chiếm slot: "Chờ xác nhận", "Đã xác nhận", "Đang sử dụng".
     * Không đếm: "Đã hủy", "Quá hạn", "Không đến", "Chờ thanh toán" (các đơn không còn hiệu lực).
     */
    public static int countActiveBookingsForAccountAndDate(Connection conn, int accountId, java.time.LocalDate ngayDat)
            throws SQLException {
        String sql = "SELECT COUNT(*) FROM bookings WHERE account_id = ? AND booking_date = ? AND status IN (N'Chờ xác nhận', N'Đã xác nhận', N'Đang sử dụng')";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            ps.setDate(2, Date.valueOf(ngayDat));
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    /**
     * Sweep AN TOÀN, gọi được cả từ scheduler (BookingExpiryScheduler) lẫn lazy từ các hàm đọc
     * danh sách bên dưới. KHÔNG BAO GIỜ được tự hoàn thành một booking "Đang sử dụng" - việc đó
     * chỉ được phép qua transaction checkout chính thức (CheckoutService). Chỉ xử lý:
     *   1. Giải phóng San "mồ côi" (không có LichDatSan "Đang sử dụng" nào tham chiếu tới) -
     *      tự chữa lành trạng thái sân sau sự cố (crash giữa transaction, dữ liệu cũ...), không
     *      đụng tới bất kỳ ca đang chơi nào vì điều kiện NOT IN loại trừ mọi San có ca đang chơi.
     *   2. Tự hủy "Chờ xác nhận" quá hạn duyệt (COD_APPROVAL_EXPIRE_HOURS).
     */
    public static void updateExpiredBookingsAndFields() {
        String sqlUpdateSan = "UPDATE courts SET status = N'Sẵn sàng' " +
                             "WHERE status = N'Đang sử dụng' " +
                             "AND court_id NOT IN (SELECT DISTINCT court_id FROM bookings WHERE status = N'Đang sử dụng')";
        String sqlExpirePending = "UPDATE bookings " +
                                  "SET status = N'Đã hủy', " +
                                  "    note = CONCAT(ISNULL(note, N''), N' [Tự động hủy: Hết hạn chờ xác nhận (" +
                                  org.example.util.Constants.COD_APPROVAL_EXPIRE_HOURS + " giờ)]') " +
                                  "WHERE status = N'Chờ xác nhận' " +
                                  "AND DATEDIFF(hour, created_at, GETDATE()) >= " + org.example.util.Constants.COD_APPROVAL_EXPIRE_HOURS;

        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement psSan = conn.prepareStatement(sqlUpdateSan);
                 PreparedStatement psExpire = conn.prepareStatement(sqlExpirePending)) {
                psSan.executeUpdate();
                psExpire.executeUpdate();
                conn.commit();
            } catch (Exception e) {
                conn.rollback();
                logger.error("Lỗi khi tự động cập nhật đơn đặt sân hết hạn: {}", e.getMessage(), e);
            }
        } catch (Exception e) {
            logger.error("Lỗi kết nối khi tự động cập nhật đơn đặt sân hết hạn: {}", e.getMessage(), e);
        }
    }

    @Override
    public List<Lichdatsan> getAllLichDatSan() {
        updateExpiredBookingsAndFields();
        org.example.service.BookingLifecycleService.runExpirySweep();
        List<Lichdatsan> list = new ArrayList<>();
        String sql = "SELECT * FROM bookings WHERE is_deleted = 0 ORDER BY booking_date DESC, start_time DESC";
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
        updateExpiredBookingsAndFields();
        org.example.service.BookingLifecycleService.runExpirySweep();
        List<Lichdatsan> list = new ArrayList<>();
        String sql = "SELECT * FROM bookings WHERE account_id = ? AND is_deleted = 0 ORDER BY ISNULL(created_at, CAST('1900-01-01' AS DATETIME)) DESC, booking_id DESC";
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
        String sql = "SELECT * FROM bookings WHERE booking_id = ? AND is_deleted = 0";
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
        String sql = "INSERT INTO bookings (account_id, court_id, booking_date, start_time, end_time, apply_light_price, estimated_total, status, note, booking_source) " +
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
        String sql = "UPDATE bookings SET status = ? WHERE booking_id = ?";
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
    public int cancelByCustomer(Connection conn, int datSanId, int accountId, String cancelType, String cancelReason) throws SQLException {
        String sql = "UPDATE bookings SET status = N'Đã hủy', cancel_type = ?, cancel_reason = ?, " +
                "cancelled_at = GETDATE(), cancelled_by = ? " +
                "WHERE booking_id = ? AND account_id = ? AND (" +
                "status = N'Chờ xác nhận' " +
                "OR status = N'Đã xác nhận' " +
                "OR (status = N'Chờ thanh toán' AND (hold_expires_at IS NULL OR hold_expires_at > SYSUTCDATETIME())))";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, cancelType);
            ps.setString(2, cancelReason);
            ps.setInt(3, accountId);
            ps.setInt(4, datSanId);
            ps.setInt(5, accountId);
            return ps.executeUpdate();
        }
    }

    @Override
    public boolean updateGhiChu(int id, String ghiChu) {
        String sql = "UPDATE bookings SET note = ? WHERE booking_id = ?";
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
    public boolean hardDelete(int id) {
        String sql = "DELETE FROM bookings WHERE booking_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Lỗi khi xóa lịch đặt sân ID {}: {}", id, e.getMessage(), e);
        }
        return false;
    }

    @Override
    public boolean softDelete(int id, int actorId) {
        String sql = "UPDATE bookings SET is_deleted = 1, deleted_at = GETDATE(), deleted_by = ? " +
                     "WHERE booking_id = ? AND is_deleted = 0";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, actorId);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Lỗi soft delete lịch đặt sân ID {}: {}", id, e.getMessage(), e);
            return false;
        }
    }

    @Override
    public boolean restore(int id) {
        String sql = "UPDATE bookings SET is_deleted = 0, deleted_at = NULL, deleted_by = NULL " +
                     "WHERE booking_id = ? AND is_deleted = 1";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Lỗi restore lịch đặt sân ID {}: {}", id, e.getMessage(), e);
            return false;
        }
    }

    @Override
    public List<Lichdatsan> findDeletedByCoSo(int coSoId) {
        List<Lichdatsan> list = new ArrayList<>();
        String sql = "SELECT b.*, s.court_name, s.facility_id " +
                     "FROM bookings b JOIN courts s ON b.court_id = s.court_id " +
                     "WHERE s.facility_id = ? AND b.is_deleted = 1 " +
                     "ORDER BY b.deleted_at DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, coSoId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToLichDatSan(rs));
                }
            }
        } catch (SQLException e) {
            logger.error("Lỗi findDeletedByCoSo lịch đặt sân coSoId {}: {}", coSoId, e.getMessage(), e);
        }
        return list;
    }

    @Override
    public List<Integer> findDeletedIdsOlderThan(int days) {
        List<Integer> ids = new ArrayList<>();
        String sql = "SELECT booking_id FROM bookings " +
                     "WHERE is_deleted = 1 AND deleted_at < DATEADD(day, -?, GETDATE())";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, days);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ids.add(rs.getInt("booking_id"));
                }
            }
        } catch (SQLException e) {
            logger.error("Lỗi findDeletedIdsOlderThan lịch đặt sân days {}: {}", days, e.getMessage(), e);
        }
        return ids;
    }

    private Lichdatsan mapResultSetToLichDatSan(ResultSet rs) throws SQLException {
        Lichdatsan lich = new Lichdatsan();
        lich.setDatSanId(rs.getInt("booking_id"));
        lich.setAccountId(rs.getInt("account_id"));
        lich.setSanId(rs.getInt("court_id"));
        lich.setNgayDat(rs.getDate("booking_date").toLocalDate());
        lich.setGioBatDau(rs.getTime("start_time").toLocalTime());
        lich.setGioKetThuc(rs.getTime("end_time").toLocalTime());
        lich.setApDungGiaCoDen(rs.getBoolean("apply_light_price"));
        lich.setTongTienDuKien(rs.getBigDecimal("estimated_total"));
        lich.setTrangThai(rs.getNString("status"));
        lich.setGhiChu(rs.getNString("note"));
        lich.setNguonDatSan(rs.getNString("booking_source"));

        Timestamp createdTs = rs.getTimestamp("created_at");
        if (createdTs != null) {
            lich.setCreatedTime(createdTs.toLocalDateTime());
        }

        try {
            lich.setDeleted(rs.getBoolean("is_deleted"));
            Timestamp deletedAtTs = rs.getTimestamp("deleted_at");
            if (deletedAtTs != null) {
                lich.setDeletedAt(deletedAtTs.toLocalDateTime());
            }
            int deletedBy = rs.getInt("deleted_by");
            if (!rs.wasNull()) {
                lich.setDeletedBy(deletedBy);
            }
        } catch (SQLException e) {
            // Soft-delete columns may not be present in all queries
        }

        try {
            lich.setTimeMode(rs.getString("time_mode"));
            int reserved = rs.getInt("reserved_duration_minutes");
            if (!rs.wasNull()) {
                lich.setReservedDurationMinutes(reserved);
            }
            Time actualStart = rs.getTime("actual_start_time_of_day");
            if (actualStart != null) {
                lich.setActualStartTime(actualStart.toLocalTime());
            }
            Time actualEnd = rs.getTime("actual_end_time_of_day");
            if (actualEnd != null) {
                lich.setActualEndTime(actualEnd.toLocalTime());
            }
            lich.setEarlyCheckoutReason(rs.getNString("early_checkout_reason"));
            BigDecimal earlyDisc = rs.getBigDecimal("early_checkout_discount");
            if (earlyDisc != null) {
                lich.setEarlyCheckoutDiscount(earlyDisc);
            }
            java.sql.Timestamp holdExpiresTs = rs.getTimestamp("hold_expires_at");
            if (holdExpiresTs != null) {
                lich.setHoldExpiresAt(holdExpiresTs.toLocalDateTime());
            }
        } catch (SQLException e) {
            // New columns might not be present in some select statements
        }

        try {
            lich.setCancelType(rs.getNString("cancel_type"));
            lich.setCancelReason(rs.getNString("cancel_reason"));
            java.sql.Timestamp cancelledAtTs = rs.getTimestamp("cancelled_at");
            if (cancelledAtTs != null) {
                lich.setCancelledAt(cancelledAtTs.toLocalDateTime());
            }
            int cancelledBy = rs.getInt("cancelled_by");
            if (!rs.wasNull()) {
                lich.setCancelledBy(cancelledBy);
            }
            lich.setRequiresRefundReview(rs.getBoolean("requires_refund_review"));
        } catch (SQLException e) {
            // New columns might not be present in some select statements
        }

        // Map DepositAmount & PaymentMethodConfirmed — cần thiết để calculatePreview()
        // có thể lấy số tiền đặt cọc khi HoaDon chưa tồn tại.
        try {
            BigDecimal depositAmt = rs.getBigDecimal("deposit_amount");
            if (depositAmt != null) {
                lich.setDepositAmount(depositAmt);
            }
        } catch (SQLException e) {
            // Column might not be present in all queries
        }
        try {
            String pmConfirmed = rs.getNString("payment_method_confirmed");
            if (pmConfirmed != null) {
                lich.setPaymentMethodConfirmed(pmConfirmed);
            }
        } catch (SQLException e) {
            // Column might not be present in all queries
        }

        try {
            String tenSan = rs.getNString("court_name");
            if (tenSan != null) {
                org.example.model.San san = new org.example.model.San();
                san.setSanID(rs.getInt("court_id"));
                san.setTenSan(tenSan);
                san.setCoSoID(rs.getInt("facility_id"));
                lich.setSan(san);
            }
        } catch (SQLException e) {
            // Column not found, ignore
        }

        try {
            String fullName = rs.getNString("full_name");
            if (fullName != null) {
                org.example.model.TaiKhoan acc = new org.example.model.TaiKhoan();
                acc.setAccountId(rs.getInt("account_id"));
                acc.setFullName(fullName);
                acc.setPhoneNumber(rs.getString("phone_number"));
                acc.setEmail(rs.getString("email"));
                try {
                    acc.setDiemUyTin(rs.getInt("reputation_score"));
                    acc.setLateCancelCount(rs.getInt("late_cancel_count"));
                    acc.setNoShowCount(rs.getInt("no_show_count"));
                } catch (SQLException ignoredReputationCols) {
                    // Query didn't select reputation columns (e.g. getLichDatSanTodayByCoSo) — leave defaults
                }
                lich.setAccount(acc);
            }
        } catch (SQLException e) {
            // Column not found, ignore
        }

        return lich;
    }

    @Override
    public List<Lichdatsan> getLichDatSanTodayByCoSo(int coSoId) {
        updateExpiredBookingsAndFields();
        org.example.service.BookingLifecycleService.runExpirySweep();
        List<Lichdatsan> list = new ArrayList<>();
        String sql = "SELECT l.*, s.court_name, s.facility_id " +
                     "FROM bookings l " +
                     "JOIN courts s ON l.court_id = s.court_id " +
                     "WHERE s.facility_id = ? AND l.booking_date = ? AND l.is_deleted = 0 " +
                     "ORDER BY l.start_time ASC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, coSoId);
            ps.setDate(2, java.sql.Date.valueOf(java.time.LocalDate.now()));
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

    @Override
    public List<Lichdatsan> getLichDatSanByCoSo(int coSoId) {
        updateExpiredBookingsAndFields();
        org.example.service.BookingLifecycleService.runExpirySweep();
        List<Lichdatsan> list = new ArrayList<>();
        String sql = "SELECT l.*, s.court_name, s.facility_id, a.full_name, a.phone_number, a.email, " +
                     "a.reputation_score, a.late_cancel_count, a.no_show_count " +
                     "FROM bookings l " +
                     "JOIN courts s ON l.court_id = s.court_id " +
                     "LEFT JOIN accounts a ON l.account_id = a.account_id " +
                     "WHERE s.facility_id = ? AND l.is_deleted = 0 " +
                     "ORDER BY ISNULL(l.created_at, CAST('1900-01-01' AS DATETIME)) DESC, l.booking_id DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, coSoId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToLichDatSan(rs));
                }
            }
        } catch (SQLException e) {
            logger.error("Lỗi khi lấy danh sách lịch đặt sân theo cơ sở {}: {}", coSoId, e.getMessage(), e);
        }
        return list;
    }

    @Override
    public boolean duyetLichDatSan(int datSanId, int approvedByAccountId, int coSoId, boolean confirmPriceChange) throws Exception {
        org.example.dto.booking.BookingDecisionResult res = duyetLichDatSanDecision(datSanId, approvedByAccountId, coSoId, confirmPriceChange);
        return res.isSuccess();
    }

    @Override
    public boolean tuChoiLichDatSan(int datSanId, String ghiChu, int coSoId) throws Exception {
        org.example.dto.booking.BookingDecisionResult res = tuChoiLichDatSanDecision(datSanId, ghiChu, coSoId);
        return res.isSuccess();
    }

    @Override
    public org.example.dto.booking.BookingDecisionResult duyetLichDatSanDecision(int datSanId, int approvedByAccountId, int coSoId, boolean confirmPriceChange) throws Exception {
        Connection conn = null;
        PreparedStatement psLockSan = null;
        PreparedStatement psSelect = null;
        PreparedStatement psCheckConflict = null;
        PreparedStatement psUpdateApproved = null;
        PreparedStatement psUpdateOverlap = null;
        PreparedStatement psInsertInvoice = null;
        ResultSet rsLockSan = null;
        ResultSet rsSelect = null;
        ResultSet rsConflict = null;

        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            // 1. Kiểm tra trạng thái đơn hiện tại
            String sqlSelect = "SELECT court_id, booking_date, start_time, end_time, status, estimated_total, account_id, note FROM bookings WITH (UPDLOCK, ROWLOCK) WHERE booking_id = ?";
            psSelect = conn.prepareStatement(sqlSelect);
            psSelect.setInt(1, datSanId);
            rsSelect = psSelect.executeQuery();

            if (!rsSelect.next()) {
                throw new Exception("Không tìm thấy thông tin đơn đặt sân.");
            }

            int sanId = rsSelect.getInt("court_id");
            Date ngayDat = rsSelect.getDate("booking_date");
            Time gioBatDau = rsSelect.getTime("start_time");
            Time gioKetThuc = rsSelect.getTime("end_time");
            String trangThai = rsSelect.getString("status");
            BigDecimal tongTienDuKien = rsSelect.getBigDecimal("estimated_total");
            String currentGhiChu = rsSelect.getString("note");
            Integer customerAccountId = rsSelect.getInt("account_id");
            if (rsSelect.wasNull()) {
                customerAccountId = null;
            }

            if (!"Chờ xác nhận".equals(trangThai)) {
                throw new Exception("Đơn đặt sân đã được xử lý từ trước (Trạng thái hiện tại: " + trangThai + ").");
            }

            // Kiểm tra ngày/giờ booking đã qua - không duyệt đơn hết hạn
            java.time.LocalDate bookingDate = ngayDat.toLocalDate();
            java.time.LocalTime bookingStart = gioBatDau.toLocalTime();
            java.time.LocalDate today = java.time.LocalDate.now();
            java.time.LocalTime now = java.time.LocalTime.now();
            if (bookingDate.isBefore(today) || (bookingDate.equals(today) && bookingStart.isBefore(now))) {
                throw new Exception("Không thể duyệt đơn này vì thời gian đặt sân (" +
                        bookingDate + " " + bookingStart.toString().substring(0, 5) +
                        ") đã qua. Vui lòng hủy đơn thay vì duyệt.");
            }

            // 2. Vá lỗi IDOR & Tránh Race Condition bằng cách khóa hàng Sân (row lock)
            String sqlLockSan = "SELECT facility_id FROM courts WITH (UPDLOCK, ROWLOCK) WHERE court_id = ?";
            psLockSan = conn.prepareStatement(sqlLockSan);
            psLockSan.setInt(1, sanId);
            rsLockSan = psLockSan.executeQuery();
            if (!rsLockSan.next()) {
                throw new Exception("Không tìm thấy thông tin sân bóng tương ứng.");
            }
            int sanCoSoId = rsLockSan.getInt("facility_id");
            if (sanCoSoId != coSoId) {
                throw new Exception("Bạn không có quyền quản lý đơn đặt sân thuộc cơ sở khác.");
            }

            // 3. Tính lại giá sân thực tế tại thời điểm duyệt để cập nhật/verify (Tránh trượt giá)
            double hourlyPrice = 100_000; // Fallback
            String loaiSanSql = "SELECT price_without_light, price_with_light, light_start_time FROM court_types WHERE court_type_id = (SELECT court_type_id FROM courts WHERE court_id = ?)";
            try (PreparedStatement psLoai = conn.prepareStatement(loaiSanSql)) {
                psLoai.setInt(1, sanId);
                try (ResultSet rsLoai = psLoai.executeQuery()) {
                    if (rsLoai.next()) {
                        double giaKhongDen = rsLoai.getDouble("price_without_light");
                        double giaCoDen = rsLoai.getDouble("price_with_light");
                        LocalTime gioLenDen = LocalTime.of(17, 30);
                        Time sqlLenDen = rsLoai.getTime("light_start_time");
                        if (sqlLenDen != null) {
                            gioLenDen = sqlLenDen.toLocalTime();
                        }
                        if (!gioBatDau.toLocalTime().isBefore(gioLenDen)) {
                            hourlyPrice = giaCoDen;
                        } else {
                            hourlyPrice = giaKhongDen;
                        }
                    }
                }
            }
            long durationMinutes = Duration.between(gioBatDau.toLocalTime(), gioKetThuc.toLocalTime()).toMinutes();
            double durationHours = durationMinutes / 60.0;
            BigDecimal currentPriceCalculated = BigDecimal.valueOf(durationHours * hourlyPrice).setScale(0, java.math.RoundingMode.HALF_UP);

            String priceWarning = "";

            // 4. Kiểm xem có đơn trùng lịch đã được xác nhận/sử dụng không
            String sqlCheckConflict = "SELECT COUNT(*) FROM bookings " +
                                      "WHERE court_id = ? AND booking_date = ? AND booking_id != ? " +
                                      "AND (status IN (N'Đã xác nhận', N'Đang sử dụng', N'Đã hoàn thành') " +
                                      "     OR (status = N'Chờ thanh toán' AND DATEDIFF(minute, created_at, GETDATE()) <= " + org.example.util.Constants.PENDING_PAYMENT_TIMEOUT_MINUTES + ")) " +
                                      "AND NOT (end_time <= CAST(? AS time) OR start_time >= CAST(? AS time))";
            psCheckConflict = conn.prepareStatement(sqlCheckConflict);
            psCheckConflict.setInt(1, sanId);
            psCheckConflict.setDate(2, ngayDat);
            psCheckConflict.setInt(3, datSanId);
            psCheckConflict.setString(4, gioBatDau.toString());
            psCheckConflict.setString(5, gioKetThuc.toString());

            rsConflict = psCheckConflict.executeQuery();
            if (rsConflict.next() && rsConflict.getInt(1) > 0) {
                throw new Exception("Không thể duyệt đơn này vì khung giờ đã bị chiếm bởi một đơn khác đã được xác nhận.");
            }

            // 5. Cập nhật trạng thái đơn hiện tại thành "Đã xác nhận"
            String newApprovedGhiChu = (currentGhiChu != null ? currentGhiChu.trim() : "") + priceWarning;
            String sqlUpdateApproved = "UPDATE bookings SET status = N'Đã xác nhận', estimated_total = ?, note = ? WHERE booking_id = ?";
            psUpdateApproved = conn.prepareStatement(sqlUpdateApproved);
            psUpdateApproved.setBigDecimal(1, tongTienDuKien);
            psUpdateApproved.setNString(2, newApprovedGhiChu.trim());
            psUpdateApproved.setInt(3, datSanId);
            psUpdateApproved.executeUpdate();

            // 6. Khởi tạo hóa đơn "Chưa thanh toán" cho khách hàng đặt trước để tương thích với luồng CheckInDAO
            String sqlCheckInvoice = "SELECT COUNT(*) FROM invoices WHERE booking_id = ?";
            try (PreparedStatement psCheckInv = conn.prepareStatement(sqlCheckInvoice)) {
                psCheckInv.setInt(1, datSanId);
                try (ResultSet rsInv = psCheckInv.executeQuery()) {
                    if (rsInv.next() && rsInv.getInt(1) == 0) {
                        boolean hasLoaiHoaDon = columnExists(conn, "invoices", "invoice_type");
                        String sqlInsertInvoice = hasLoaiHoaDon
                                ? "INSERT INTO invoices (booking_id, customer_account_id, staff_account_id, issued_at, court_total, service_total, parking_fee, discount_amount, grand_total, payment_status, invoice_type) " +
                                  "VALUES (?, ?, NULL, GETDATE(), ?, 0, 0, 0, ?, N'Chưa thanh toán', N'MAIN')"
                                : "INSERT INTO invoices (booking_id, customer_account_id, staff_account_id, issued_at, court_total, service_total, parking_fee, discount_amount, grand_total, payment_status) " +
                                  "VALUES (?, ?, NULL, GETDATE(), ?, 0, 0, 0, ?, N'Chưa thanh toán')";
                        psInsertInvoice = conn.prepareStatement(sqlInsertInvoice);
                        psInsertInvoice.setInt(1, datSanId);
                        if (customerAccountId != null) {
                            psInsertInvoice.setInt(2, customerAccountId);
                        } else {
                            psInsertInvoice.setNull(2, java.sql.Types.INTEGER);
                        }
                        psInsertInvoice.setBigDecimal(3, tongTienDuKien);
                        psInsertInvoice.setBigDecimal(4, tongTienDuKien);
                        psInsertInvoice.executeUpdate();
                    }
                }
            }

            // 7. Lấy danh sách các đơn trùng lịch để hủy và chuẩn bị thông báo gửi cho khách hàng
            String selectOverlapSql = "SELECT l.booking_id, l.account_id, l.booking_date, l.start_time, l.end_time, s.court_name " +
                                      "FROM bookings l " +
                                      "JOIN courts s ON l.court_id = s.court_id " +
                                      "WHERE l.court_id = ? AND l.booking_date = ? AND l.booking_id != ? AND l.status = N'Chờ xác nhận' " +
                                      "AND NOT (l.end_time <= CAST(? AS time) OR l.start_time >= CAST(? AS time))";

            class OverlapNotifInfo {
                int overlapDatSanId;
                int accountId;
                String title;
                String content;
            }
            List<OverlapNotifInfo> overlapNotifs = new ArrayList<>();

            try (PreparedStatement psOverlapSel = conn.prepareStatement(selectOverlapSql)) {
                psOverlapSel.setInt(1, sanId);
                psOverlapSel.setDate(2, ngayDat);
                psOverlapSel.setInt(3, datSanId);
                psOverlapSel.setString(4, gioBatDau.toString());
                psOverlapSel.setString(5, gioKetThuc.toString());
                try (ResultSet rsOverlap = psOverlapSel.executeQuery()) {
                    while (rsOverlap.next()) {
                        int overlapDatSanId = rsOverlap.getInt("booking_id");
                        int customerId = rsOverlap.getInt("account_id");
                        String tenSan = rsOverlap.getNString("court_name");
                        Date oNgayDat = rsOverlap.getDate("booking_date");
                        Time oStart = rsOverlap.getTime("start_time");
                        Time oEnd = rsOverlap.getTime("end_time");

                        String title = "Đơn đặt sân #" + overlapDatSanId + " bị hủy";
                        String content = "Đơn đặt sân " + tenSan + " ngày " + oNgayDat + " (" + oStart.toString().substring(0, 5) + " - " + oEnd.toString().substring(0, 5) + ") đã bị tự động hủy do trùng lịch với ca đặt sân #" + datSanId + " đã được phê duyệt.";

                        OverlapNotifInfo info = new OverlapNotifInfo();
                        info.overlapDatSanId = overlapDatSanId;
                        info.accountId = customerId;
                        info.title = title;
                        info.content = content;
                        overlapNotifs.add(info);
                    }
                }
            }

            // Tự động từ chối (hủy) các đơn Chờ xác nhận bị trùng lịch chéo
            String sqlUpdateOverlap = "UPDATE bookings " +
                                      "SET status = N'Đã hủy', " +
                                      "    note = CONCAT(ISNULL(note, N''), N' [Hệ thống tự động hủy do trùng lịch với đơn #', CAST(? AS varchar), N' đã được duyệt]') " +
                                      "WHERE court_id = ? AND booking_date = ? AND booking_id != ? AND status = N'Chờ xác nhận' " +
                                      "AND NOT (end_time <= CAST(? AS time) OR start_time >= CAST(? AS time))";
            psUpdateOverlap = conn.prepareStatement(sqlUpdateOverlap);
            psUpdateOverlap.setInt(1, datSanId);
            psUpdateOverlap.setInt(2, sanId);
            psUpdateOverlap.setDate(3, ngayDat);
            psUpdateOverlap.setInt(4, datSanId);
            psUpdateOverlap.setString(5, gioBatDau.toString());
            psUpdateOverlap.setString(6, gioKetThuc.toString());
            psUpdateOverlap.executeUpdate();

            // Gửi thông báo trùng lịch cho các khách hàng bị hủy
            if (!overlapNotifs.isEmpty()) {
                String insertNotifSql = "INSERT INTO notifications (account_id, title, content, notification_type, is_read, sent_at, reference_id, link_url, is_deleted) " +
                                        "VALUES (?, ?, ?, ?, 0, GETDATE(), ?, ?, 0)";
                try (PreparedStatement psInsNotif = conn.prepareStatement(insertNotifSql)) {
                    for (OverlapNotifInfo tb : overlapNotifs) {
                        psInsNotif.setInt(1, tb.accountId);
                        psInsNotif.setNString(2, tb.title);
                        psInsNotif.setNString(3, tb.content);
                        psInsNotif.setNString(4, "BOOKING_CANCELLED");
                        psInsNotif.setString(5, String.valueOf(tb.overlapDatSanId));
                        psInsNotif.setString(6, "/customer/dat-san?openHistory=true&datSanId=" + tb.overlapDatSanId);
                        psInsNotif.executeUpdate();
                    }
                }
            }

            conn.commit();
            int finalCustomerId = customerAccountId != null ? customerAccountId : 0;
            return new org.example.dto.booking.BookingDecisionResult(true, datSanId, finalCustomerId, coSoId, trangThai, "Đã xác nhận", "Duyệt đơn thành công");
        } catch (Exception e) {
            if (conn != null) {
                conn.rollback();
            }
            logger.error("Lỗi khi duyệt đơn đặt sân ID {}: {}", datSanId, e.getMessage(), e);
            throw e;
        } finally {
            if (rsLockSan != null) rsLockSan.close();
            if (rsSelect != null) rsSelect.close();
            if (rsConflict != null) rsConflict.close();
            if (psLockSan != null) psLockSan.close();
            if (psSelect != null) psSelect.close();
            if (psCheckConflict != null) psCheckConflict.close();
            if (psUpdateApproved != null) psUpdateApproved.close();
            if (psUpdateOverlap != null) psUpdateOverlap.close();
            if (psInsertInvoice != null) psInsertInvoice.close();
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }
    }

    @Override
    public org.example.dto.booking.BookingDecisionResult tuChoiLichDatSanDecision(int datSanId, String ghiChu, int coSoId) throws Exception {
        Connection conn = null;
        PreparedStatement psSelect = null;
        PreparedStatement psLockSan = null;
        PreparedStatement psUpdate = null;
        ResultSet rsSelect = null;
        ResultSet rsLockSan = null;

        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            // 1. Kiểm tra trạng thái hiện tại
            String sqlSelect = "SELECT court_id, status, note, account_id FROM bookings WHERE booking_id = ?";
            psSelect = conn.prepareStatement(sqlSelect);
            psSelect.setInt(1, datSanId);
            rsSelect = psSelect.executeQuery();

            if (!rsSelect.next()) {
                throw new Exception("Không tìm thấy thông tin đơn đặt sân.");
            }

            int sanId = rsSelect.getInt("court_id");
            String trangThai = rsSelect.getString("status");
            String oldGhiChu = rsSelect.getString("note");
            if (oldGhiChu == null) oldGhiChu = "";
            Integer customerAccountId = rsSelect.getInt("account_id");
            if (rsSelect.wasNull()) {
                customerAccountId = null;
            }

            if (!"Chờ xác nhận".equals(trangThai)) {
                throw new Exception("Đơn đặt sân đã được xử lý từ trước (Trạng thái hiện tại: " + trangThai + ").");
            }

            // 2. Vá lỗi IDOR: Kiểm tra sân có thuộc coSoId của người từ chối không
            String sqlLockSan = "SELECT facility_id FROM courts WITH (UPDLOCK, ROWLOCK) WHERE court_id = ?";
            psLockSan = conn.prepareStatement(sqlLockSan);
            psLockSan.setInt(1, sanId);
            rsLockSan = psLockSan.executeQuery();
            if (!rsLockSan.next()) {
                throw new Exception("Không tìm thấy thông tin sân bóng tương ứng.");
            }
            int sanCoSoId = rsLockSan.getInt("facility_id");
            if (sanCoSoId != coSoId) {
                throw new Exception("Bạn không có quyền quản lý đơn đặt sân thuộc cơ sở khác.");
            }

            // 3. Cập nhật đơn thành Đã hủy
            String newGhiChu = oldGhiChu + (ghiChu != null && !ghiChu.isEmpty() ? " [Từ chối: " + ghiChu + "]" : " [Bị từ chối bởi quản lý]");
            String sqlUpdate = "UPDATE bookings SET status = N'Đã hủy', note = ? WHERE booking_id = ?";
            psUpdate = conn.prepareStatement(sqlUpdate);
            psUpdate.setNString(1, newGhiChu.trim());
            psUpdate.setInt(2, datSanId);
            psUpdate.executeUpdate();

            // 4. Kiểm tra và cập nhật hóa đơn liên quan nếu có
            String sqlCheckInvoice = "SELECT invoice_id, payment_status, grand_total, customer_account_id FROM invoices WHERE booking_id = ?";
            try (PreparedStatement psCheckInv = conn.prepareStatement(sqlCheckInvoice)) {
                psCheckInv.setInt(1, datSanId);
                try (ResultSet rsInv = psCheckInv.executeQuery()) {
                    if (rsInv.next()) {
                        int hoaDonId = rsInv.getInt("invoice_id");
                        String trangThaiThanhToan = rsInv.getString("payment_status");
                        BigDecimal tongThanhToan = rsInv.getBigDecimal("grand_total");
                        Integer khachHangId = rsInv.getInt("customer_account_id");
                        boolean wasNullKhach = rsInv.wasNull();

                        if ("Đã thanh toán".equals(trangThaiThanhToan) || "Đã cọc".equals(trangThaiThanhToan)) {
                            // Tạo yêu cầu Hoàn tiền
                            String sqlInsertRefund = "INSERT INTO refunds (invoice_id, account_id, refunded_amount, reason, status, requested_at) " +
                                                     "VALUES (?, ?, ?, ?, ?, GETDATE())";
                            try (PreparedStatement psRefund = conn.prepareStatement(sqlInsertRefund)) {
                                psRefund.setInt(1, hoaDonId);
                                if (!wasNullKhach && khachHangId != null) {
                                    psRefund.setInt(2, khachHangId);
                                } else {
                                    psRefund.setNull(2, java.sql.Types.INTEGER);
                                }
                                psRefund.setBigDecimal(3, tongThanhToan);
                                psRefund.setNString(4, "Đơn đặt sân bị từ chối bởi quản lý");
                                psRefund.setString(5, "Chờ xử lý");
                                psRefund.executeUpdate();
                            }
                            String sqlUpdateInvoice = "UPDATE invoices SET payment_status = N'Hoàn tiền', issued_at = GETDATE() WHERE invoice_id = ?";
                            try (PreparedStatement psUpdateInv = conn.prepareStatement(sqlUpdateInvoice)) {
                                psUpdateInv.setInt(1, hoaDonId);
                                psUpdateInv.executeUpdate();
                            }
                        } else {
                            String sqlUpdateInvoice = "UPDATE invoices SET payment_status = N'Đã hủy', issued_at = GETDATE() WHERE invoice_id = ?";
                            try (PreparedStatement psUpdateInv = conn.prepareStatement(sqlUpdateInvoice)) {
                                psUpdateInv.setInt(1, hoaDonId);
                                psUpdateInv.executeUpdate();
                            }
                        }
                    }
                }
            }

            conn.commit();
            int finalCustomerId = customerAccountId != null ? customerAccountId : 0;
            return new org.example.dto.booking.BookingDecisionResult(true, datSanId, finalCustomerId, coSoId, trangThai, "Đã hủy", "Từ chối đơn thành công");
        } catch (Exception e) {
            if (conn != null) {
                conn.rollback();
            }
            logger.error("Lỗi khi từ chối đơn đặt sân ID {}: {}", datSanId, e.getMessage(), e);
            throw e;
        } finally {
            if (rsLockSan != null) rsLockSan.close();
            if (rsSelect != null) rsSelect.close();
            if (psLockSan != null) psLockSan.close();
            if (psSelect != null) psSelect.close();
            if (psUpdate != null) psUpdate.close();
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }
    }

    @Override
    public boolean updateDichVuDatSan(int datSanId, int[] productIds, int[] quantities) throws Exception {
        return updateDichVuDatSan(datSanId, productIds, quantities, null);
    }

    @Override
    public boolean updateDichVuDatSan(int datSanId, int[] productIds, int[] quantities, Integer requiredCoSoId) throws Exception {
        if (productIds == null || quantities == null || productIds.length != quantities.length) {
            throw new Exception("Dữ liệu đầu vào không hợp lệ (mảng sản phẩm và số lượng không khớp).");
        }

        Connection conn = null;
        PreparedStatement psSelectBooking = null;
        PreparedStatement psCheckInvoice = null;
        PreparedStatement psInsertInvoice = null;
        PreparedStatement psDeleteChiTiet = null;
        PreparedStatement psInsertChiTiet = null;
        PreparedStatement psUpdateProductStock = null;
        PreparedStatement psGetProductDetails = null;
        PreparedStatement psUpdateInvoiceTotals = null;
        ResultSet rsBooking = null;
        ResultSet rsInv = null;

        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            // 1. Lấy thông tin booking và khóa dòng
            String sqlSelectBooking = "SELECT lds.court_id, lds.estimated_total, lds.account_id, lds.status, s.facility_id FROM bookings lds INNER JOIN courts s ON lds.court_id = s.court_id WITH (UPDLOCK, ROWLOCK) WHERE lds.booking_id = ?";
            psSelectBooking = conn.prepareStatement(sqlSelectBooking);
            psSelectBooking.setInt(1, datSanId);
            rsBooking = psSelectBooking.executeQuery();
            if (!rsBooking.next()) {
                throw new Exception("Không tìm thấy thông tin đơn đặt sân.");
            }
            int sanId = rsBooking.getInt("court_id");
            BigDecimal tongTienDuKien = rsBooking.getBigDecimal("estimated_total");
            Integer customerAccountId = rsBooking.getInt("account_id");
            if (rsBooking.wasNull()) {
                customerAccountId = null;
            }
            String trangThaiBooking = rsBooking.getString("status");
            int coSoId = rsBooking.getInt("facility_id");

            if (requiredCoSoId != null && coSoId != requiredCoSoId) {
                throw new SecurityException("Đơn đặt sân không thuộc cơ sở của bạn.");
            }

            if (!"Đang sử dụng".equals(trangThaiBooking)) {
                throw new Exception("Chỉ được phép thêm/cập nhật dịch vụ khi đơn đặt sân ở trạng thái 'Đang sử dụng'.");
            }

            // 2. Kiểm tra/Tạo hóa đơn nếu chưa có
            int hoaDonId = -1;
            String sqlCheckInvoice = "SELECT invoice_id, payment_status FROM invoices WHERE " + mainInvoiceWhereClause(conn, "booking_id");
            psCheckInvoice = conn.prepareStatement(sqlCheckInvoice);
            psCheckInvoice.setInt(1, datSanId);
            rsInv = psCheckInvoice.executeQuery();
            if (rsInv.next()) {
                hoaDonId = rsInv.getInt("invoice_id");
                String invoiceStatus = rsInv.getString("payment_status");
                if ("Đã thanh toán".equals(invoiceStatus)) {
                    throw new Exception("Hóa đơn đã được thanh toán. Không thể thêm hoặc sửa dịch vụ sau khi thanh toán.");
                }
            } else {
                boolean hasLoaiHoaDon = columnExists(conn, "invoices", "invoice_type");
                String sqlInsertInvoice = hasLoaiHoaDon
                        ? "INSERT INTO invoices (booking_id, customer_account_id, staff_account_id, issued_at, court_total, service_total, parking_fee, discount_amount, grand_total, payment_status, invoice_type) " +
                          "VALUES (?, ?, NULL, GETDATE(), ?, 0, 0, 0, ?, N'Chưa thanh toán', N'MAIN')"
                        : "INSERT INTO invoices (booking_id, customer_account_id, staff_account_id, issued_at, court_total, service_total, parking_fee, discount_amount, grand_total, payment_status) " +
                          "VALUES (?, ?, NULL, GETDATE(), ?, 0, 0, 0, ?, N'Chưa thanh toán')";
                psInsertInvoice = conn.prepareStatement(sqlInsertInvoice, Statement.RETURN_GENERATED_KEYS);
                psInsertInvoice.setInt(1, datSanId);
                if (customerAccountId != null) {
                    psInsertInvoice.setInt(2, customerAccountId);
                } else {
                    psInsertInvoice.setNull(2, java.sql.Types.INTEGER);
                }
                psInsertInvoice.setBigDecimal(3, tongTienDuKien);
                psInsertInvoice.setBigDecimal(4, tongTienDuKien);
                psInsertInvoice.executeUpdate();
                
                try (ResultSet generatedKeys = psInsertInvoice.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        hoaDonId = generatedKeys.getInt(1);
                    }
                }
            }

            if (hoaDonId == -1) {
                throw new Exception("Không thể khởi tạo hoặc tìm thấy hóa đơn cho đơn đặt sân này.");
            }

            // 3. Hoàn trả lại số lượng tồn cũ của các chi tiết hóa đơn cũ trước khi xóa
            String sqlGetOldChiTiet = "SELECT product_id, quantity FROM invoice_items WHERE invoice_id = ?";
            try (PreparedStatement psOld = conn.prepareStatement(sqlGetOldChiTiet)) {
                psOld.setInt(1, hoaDonId);
                try (ResultSet rsOld = psOld.executeQuery()) {
                    while (rsOld.next()) {
                        int spId = rsOld.getInt("product_id");
                        int qty = rsOld.getInt("quantity");
                        String sqlRestoreStock = "UPDATE products_services SET stock_quantity = stock_quantity + ? WHERE product_id = ?";
                        try (PreparedStatement psRestore = conn.prepareStatement(sqlRestoreStock)) {
                            psRestore.setInt(1, qty);
                            psRestore.setInt(2, spId);
                            psRestore.executeUpdate();
                        }
                    }
                }
            }

            // 4. Xóa toàn bộ chi tiết hóa đơn cũ của hóa đơn này
            String sqlDeleteChiTiet = "DELETE FROM invoice_items WHERE invoice_id = ?";
            psDeleteChiTiet = conn.prepareStatement(sqlDeleteChiTiet);
            psDeleteChiTiet.setInt(1, hoaDonId);
            psDeleteChiTiet.executeUpdate();

            // 5. Thêm các chi tiết mới, kiểm tra tồn kho và giảm số lượng tồn kho
            double totalDichVu = 0.0;
            String sqlInsertChiTiet = "INSERT INTO invoice_items (invoice_id, product_id, quantity, unit_price_at_sale, line_total) VALUES (?, ?, ?, ?, ?)";
            psInsertChiTiet = conn.prepareStatement(sqlInsertChiTiet);

            String sqlGetProduct = "SELECT product_name, unit_price, stock_quantity, facility_id, status FROM products_services WITH (UPDLOCK, ROWLOCK) WHERE product_id = ?";
            psGetProductDetails = conn.prepareStatement(sqlGetProduct);

            String sqlUpdateStock = "UPDATE products_services SET stock_quantity = stock_quantity - ? WHERE product_id = ?";
            psUpdateProductStock = conn.prepareStatement(sqlUpdateStock);

            if (productIds != null && quantities != null) {
                for (int i = 0; i < productIds.length; i++) {
                    int spId = productIds[i];
                    int qty = quantities[i];
                    if (qty <= 0) continue;

                    psGetProductDetails.setInt(1, spId);
                    try (ResultSet rsProd = psGetProductDetails.executeQuery()) {
                        if (!rsProd.next()) {
                            throw new Exception("Không tìm thấy sản phẩm có ID: " + spId);
                        }
                        String tenSp = rsProd.getNString("product_name");
                        double donGia = rsProd.getDouble("unit_price");
                        int stock = rsProd.getInt("stock_quantity");
                        int prodCoSoId = rsProd.getInt("facility_id");
                        String prodStatus = rsProd.getString("status");

                        if (prodCoSoId != coSoId) {
                            throw new Exception("Sản phẩm '" + tenSp + "' không thuộc cùng chi nhánh với sân bóng.");
                        }
                        if (!"Đang kinh doanh".equals(prodStatus)) {
                            throw new Exception("Sản phẩm '" + tenSp + "' hiện tại ngừng kinh doanh.");
                        }

                        if (stock < qty) {
                            throw new Exception("Sản phẩm '" + tenSp + "' không đủ số lượng tồn (Hiện còn: " + stock + ").");
                        }

                        // Giảm tồn kho
                        psUpdateProductStock.setInt(1, qty);
                        psUpdateProductStock.setInt(2, spId);
                        psUpdateProductStock.executeUpdate();

                        // Thêm chi tiết hóa đơn
                        double thanhTien = qty * donGia;
                        totalDichVu += thanhTien;

                        psInsertChiTiet.setInt(1, hoaDonId);
                        psInsertChiTiet.setInt(2, spId);
                        psInsertChiTiet.setInt(3, qty);
                        psInsertChiTiet.setDouble(4, donGia);
                        psInsertChiTiet.setDouble(5, thanhTien);
                        psInsertChiTiet.executeUpdate();
                    }
                }
            }

            // 6. Cập nhật lại tổng tiền trên Hóa đơn
            String sqlUpdateInvoiceTotals = "UPDATE invoices SET service_total = ?, grand_total = court_total + ? - discount_amount + parking_fee WHERE invoice_id = ?";
            psUpdateInvoiceTotals = conn.prepareStatement(sqlUpdateInvoiceTotals);
            psUpdateInvoiceTotals.setDouble(1, totalDichVu);
            psUpdateInvoiceTotals.setDouble(2, totalDichVu);
            psUpdateInvoiceTotals.setInt(3, hoaDonId);
            psUpdateInvoiceTotals.executeUpdate();

            // Cập nhật lại tổng tiền dự kiến trong LichDatSan
            String sqlUpdateLichTien = "UPDATE bookings SET estimated_total = ? WHERE booking_id = ?";
            try (PreparedStatement psLichTien = conn.prepareStatement(sqlUpdateLichTien)) {
                double finalTotal = 0.0;
                String sqlGetTotal = "SELECT grand_total FROM invoices WHERE invoice_id = ?";
                try (PreparedStatement psGetTotal = conn.prepareStatement(sqlGetTotal)) {
                    psGetTotal.setInt(1, hoaDonId);
                    try (ResultSet rsGetTotal = psGetTotal.executeQuery()) {
                        if (rsGetTotal.next()) {
                            finalTotal = rsGetTotal.getDouble("grand_total");
                        }
                    }
                }
                psLichTien.setBigDecimal(1, BigDecimal.valueOf(finalTotal));
                psLichTien.setInt(2, datSanId);
                psLichTien.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (Exception e) {
            if (conn != null) {
                conn.rollback();
            }
            logger.error("Lỗi khi cập nhật dịch vụ đơn đặt sân ID {}: {}", datSanId, e.getMessage(), e);
            throw e;
        } finally {
            if (rsBooking != null) rsBooking.close();
            if (rsInv != null) rsInv.close();
            if (psSelectBooking != null) psSelectBooking.close();
            if (psCheckInvoice != null) psCheckInvoice.close();
            if (psInsertInvoice != null) psInsertInvoice.close();
            if (psDeleteChiTiet != null) psDeleteChiTiet.close();
            if (psInsertChiTiet != null) psInsertChiTiet.close();
            if (psGetProductDetails != null) psGetProductDetails.close();
            if (psUpdateProductStock != null) psUpdateProductStock.close();
            if (psUpdateInvoiceTotals != null) psUpdateInvoiceTotals.close();
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }
    }

}
