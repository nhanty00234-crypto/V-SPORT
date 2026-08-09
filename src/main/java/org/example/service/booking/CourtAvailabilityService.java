package org.example.service.booking;

import org.example.service.pricing.CourtPriceResult;
import org.example.util.Constants;
import org.example.util.DBUtil;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.ZonedDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Lịch trống theo từng khung giờ của một sân trong một ngày.
 *
 * Dùng ĐÚNG các quy tắc chặn slot của {@link BookingCreationService} (cùng câu truy vấn overlap,
 * cùng cách xử lý SoftHold, cùng giờ mở/đóng cửa cơ sở) và ĐÚNG một công thức giá
 * ({@link BookingCreationService#calculatePrice}) — mobile không có bảng giá hay quy tắc riêng.
 *
 * Chỉ đọc, không sửa dữ liệu.
 */
public class CourtAvailabilityService {

    private static final LocalTime DEFAULT_OPEN_TIME = LocalTime.of(6, 0);
    private static final LocalTime DEFAULT_CLOSE_TIME = LocalTime.of(23, 0);
    private static final int DEFAULT_SLOT_MINUTES = 60;

    private final BookingCreationService bookingCreationService = new BookingCreationService();

    public static class Slot {
        public final LocalTime startTime;
        public final LocalTime endTime;
        public final boolean available;
        public final String reason;
        public final BigDecimal price;

        Slot(LocalTime startTime, LocalTime endTime, boolean available, String reason, BigDecimal price) {
            this.startTime = startTime;
            this.endTime = endTime;
            this.available = available;
            this.reason = reason;
            this.price = price;
        }
    }

    public static class Availability {
        public int courtId;
        public String courtName;
        public int facilityId;
        public LocalDate date;
        public LocalTime openTime;
        public LocalTime closeTime;
        public int slotMinutes;
        public final List<Slot> slots = new ArrayList<>();
    }

    /** Không tìm thấy sân / sân đã xóa. */
    public static class CourtNotFoundException extends RuntimeException {
        public CourtNotFoundException(String message) { super(message); }
    }

    public Availability getAvailability(int courtId, LocalDate date) {
        return getAvailability(courtId, date, DEFAULT_SLOT_MINUTES);
    }

    public Availability getAvailability(int courtId, LocalDate date, int slotMinutes) {
        if (slotMinutes < 30 || slotMinutes > 240 || slotMinutes % 30 != 0) {
            slotMinutes = DEFAULT_SLOT_MINUTES;
        }
        try (Connection conn = DBUtil.getConnection()) {
            Availability out = new Availability();
            out.courtId = courtId;
            out.date = date;
            out.slotMinutes = slotMinutes;

            String courtStatus;
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT s.TenSan, s.TrangThai, s.CoSoID, c.GioMoCua, c.GioDongCua "
                            + "FROM San s JOIN CoSo c ON c.CoSoID = s.CoSoID "
                            + "WHERE s.SanID = ? AND ISNULL(s.IsDeleted, 0) = 0")) {
                ps.setInt(1, courtId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) throw new CourtNotFoundException("Không tìm thấy sân.");
                    out.courtName = rs.getString("TenSan");
                    courtStatus = rs.getString("TrangThai");
                    out.facilityId = rs.getInt("CoSoID");
                    java.sql.Time open = rs.getTime("GioMoCua");
                    java.sql.Time close = rs.getTime("GioDongCua");
                    out.openTime = open != null ? open.toLocalTime() : DEFAULT_OPEN_TIME;
                    out.closeTime = close != null ? close.toLocalTime() : DEFAULT_CLOSE_TIME;
                }
            }

            boolean courtBookable = "Sẵn sàng".equals(courtStatus) || "Đang sử dụng".equals(courtStatus);

            List<TimeRange> blocked = loadBlockedRanges(conn, courtId, date);
            LocalDate today = LocalDate.now(org.example.service.customer.CustomerCatalogService.VN_ZONE);
            LocalTime nowVn = ZonedDateTime.now(
                    org.example.service.customer.CustomerCatalogService.VN_ZONE).toLocalTime();

            LocalTime cursor = out.openTime;
            while (true) {
                LocalTime slotEnd = cursor.plusMinutes(slotMinutes);
                // Dừng khi vượt giờ đóng cửa hoặc khi cộng thêm bị vòng qua nửa đêm.
                if (!slotEnd.isAfter(cursor) || slotEnd.isAfter(out.closeTime)) break;

                String reason = null;
                if (!courtBookable) {
                    reason = "Sân đang " + courtStatus;
                } else if (date.isBefore(today) || (date.equals(today) && cursor.isBefore(nowVn))) {
                    reason = "Đã qua giờ";
                } else if (overlaps(blocked, cursor, slotEnd)) {
                    reason = "Đã có người đặt";
                }

                BigDecimal price = null;
                try {
                    CourtPriceResult pr = bookingCreationService.calculatePrice(conn, courtId, date, cursor, slotEnd);
                    price = pr.totalCourtAmount();
                } catch (SQLException ignored) {
                    // Không có bảng giá -> để null, client hiển thị "liên hệ".
                }
                out.slots.add(new Slot(cursor, slotEnd, reason == null, reason, price));

                cursor = slotEnd;
                if (cursor.equals(LocalTime.MIDNIGHT)) break;
            }
            return out;
        } catch (SQLException e) {
            throw new IllegalStateException("Không thể tải lịch trống của sân.", e);
        }
    }

    /** Khoảng thời gian đã bị chiếm (booking còn hiệu lực hoặc SoftHold của người khác). */
    private static class TimeRange {
        final LocalTime start;
        final LocalTime end;
        TimeRange(LocalTime start, LocalTime end) { this.start = start; this.end = end; }
    }

    private List<TimeRange> loadBlockedRanges(Connection conn, int courtId, LocalDate date) throws SQLException {
        List<TimeRange> ranges = new ArrayList<>();
        // Cùng điều kiện trạng thái với overlap check khi tạo booking (BookingCreationService).
        String bookingSql = "SELECT GioBatDau, GioKetThuc FROM LichDatSan "
                + "WHERE SanID = ? AND NgayDat = ? "
                + "AND (TrangThai IN (N'" + Constants.TRANG_THAI_DAT_SAN_DA_XAC_NHAN + "', "
                + "N'" + Constants.TRANG_THAI_DAT_SAN_DANG_SU_DUNG + "', "
                + "N'" + Constants.TRANG_THAI_DAT_SAN_CHO_XAC_NHAN + "') "
                + "     OR (TrangThai = N'" + Constants.TRANG_THAI_DAT_SAN_CHO_THANH_TOAN
                + "' AND HoldExpiresAt > SYSUTCDATETIME()))";
        try (PreparedStatement ps = conn.prepareStatement(bookingSql)) {
            ps.setInt(1, courtId);
            ps.setDate(2, java.sql.Date.valueOf(date));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ranges.add(new TimeRange(rs.getTime(1).toLocalTime(), rs.getTime(2).toLocalTime()));
                }
            }
        }
        String holdSql = "SELECT GioBatDau, GioKetThuc FROM SoftHold "
                + "WHERE SanID = ? AND NgayDat = ? "
                + "AND DATEDIFF(minute, CreatedTime, GETDATE()) <= " + Constants.SOFT_HOLD_TIMEOUT_MINUTES;
        try (PreparedStatement ps = conn.prepareStatement(holdSql)) {
            ps.setInt(1, courtId);
            ps.setDate(2, java.sql.Date.valueOf(date));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ranges.add(new TimeRange(rs.getTime(1).toLocalTime(), rs.getTime(2).toLocalTime()));
                }
            }
        }
        return ranges;
    }

    private boolean overlaps(List<TimeRange> ranges, LocalTime start, LocalTime end) {
        for (TimeRange r : ranges) {
            // Overlap khi KHÔNG (kết thúc <= bắt đầu của khoảng kia HOẶC bắt đầu >= kết thúc của khoảng kia)
            if (!(end.compareTo(r.start) <= 0 || start.compareTo(r.end) >= 0)) return true;
        }
        return false;
    }

    /** Tổng phút của một khoảng, dùng cho log/thống kê. */
    public static long minutesBetween(LocalTime start, LocalTime end) {
        return Duration.between(start, end).toMinutes();
    }
}
