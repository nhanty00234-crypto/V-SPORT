package org.example.service.booking;

import org.example.model.TaiKhoan;
import org.example.service.pricing.CourtPriceResult;
import org.example.service.pricing.CourtPricingService;
import org.example.util.Constants;
import org.example.util.DBUtil;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * NGUỒN SỰ THẬT DUY NHẤT cho việc tạo một lượt đặt sân của khách hàng.
 *
 * Toàn bộ logic này trước đây nằm trong {@code DatSanServlet.handleDatSan} (Web JSP).
 * Đã hạ xuống tầng Service để Web Servlet và REST API mobile dùng CHUNG — không được
 * sao chép lại bất kỳ bước kiểm tra/tính giá nào sang controller khác.
 *
 * Các bảo vệ giữ nguyên như bản Web gốc:
 *  1. Chặn khách có điểm uy tín dưới ngưỡng.
 *  2. Validate thứ tự giờ, thời lượng 30 phút – 4 giờ, không đặt quá khứ, tối đa 30 ngày tới.
 *  3. Khóa hàng San (UPDLOCK, ROWLOCK) chống double-booking.
 *  4. Giới hạn 3 lượt đặt còn hiệu lực/ngày/khách.
 *  5. Kiểm tra trạng thái sân, giờ mở/đóng cửa cơ sở, trùng lịch, SoftHold của người khác.
 *  6. Tính giá bằng {@link CourtPricingService} — GIÁ LUÔN DO SERVER TÍNH, không nhận từ client.
 *  7. Retry khi deadlock SQL Server (error 1205).
 */
public class BookingCreationService {

    private static final Logger LOGGER = Logger.getLogger(BookingCreationService.class.getName());

    private static final int MAX_DEADLOCK_RETRIES = 3;
    private static final int SQL_DEADLOCK_ERROR_CODE = 1205;
    private static final LocalTime DEFAULT_OPEN_TIME = LocalTime.of(6, 0);
    private static final LocalTime DEFAULT_CLOSE_TIME = LocalTime.of(23, 0);
    private static final int MAX_ACTIVE_BOOKINGS_PER_DAY = 3;

    /** Mã lỗi nghiệp vụ, ánh xạ thẳng sang errorCode của REST API. */
    public static final String ERR_VALIDATION      = "VALIDATION_ERROR";
    public static final String ERR_NOT_FOUND       = "NOT_FOUND";
    public static final String ERR_REPUTATION      = "REPUTATION_BLOCKED";
    public static final String ERR_BOOKING_LIMIT   = "BOOKING_LIMIT";
    public static final String ERR_COURT_UNAVAIL   = "COURT_UNAVAILABLE";
    public static final String ERR_SLOT_TAKEN      = "SLOT_TAKEN";
    public static final String ERR_INTERNAL        = "INTERNAL_ERROR";

    private final CourtPricingService pricingService = new CourtPricingService();
    private final org.example.dao.SoftHoldDAO softHoldDAO = new org.example.dao.impl.SoftHoldDAOImpl();
    private final org.example.dao.LichDatSanDichVuDAO lichDatSanDichVuDAO =
            new org.example.dao.impl.LichDatSanDichVuDAOImpl();

    /** Tham số đặt sân đã parse. serviceIds/serviceQtys có thể rỗng. */
    public static class Command {
        public int sanId;
        public LocalDate ngayDat;
        public LocalTime gioBatDau;
        public LocalTime gioKetThuc;
        public String ghiChu;
        /** true = giữ chỗ chờ thanh toán PayOS; false = thanh toán tại quầy (Chờ xác nhận). */
        public boolean onlinePayment;
        /** "Web" hoặc "Mobile" — chỉ để thống kê nguồn, không ảnh hưởng nghiệp vụ. */
        public String nguonDatSan = "Web";
        public int[] serviceIds = new int[0];
        public int[] serviceQtys = new int[0];
    }

    public static class Result {
        public final boolean success;
        public final String errorCode;
        public final String message;
        public final Integer datSanId;
        public final Integer coSoId;
        public final BigDecimal tongTien;
        public final String trangThai;
        public final boolean applyLights;
        public final long durationMinutes;

        private Result(boolean success, String errorCode, String message, Integer datSanId, Integer coSoId,
                       BigDecimal tongTien, String trangThai, boolean applyLights, long durationMinutes) {
            this.success = success;
            this.errorCode = errorCode;
            this.message = message;
            this.datSanId = datSanId;
            this.coSoId = coSoId;
            this.tongTien = tongTien;
            this.trangThai = trangThai;
            this.applyLights = applyLights;
            this.durationMinutes = durationMinutes;
        }

        static Result ok(int datSanId, int coSoId, BigDecimal tongTien, String trangThai,
                         boolean applyLights, long durationMinutes) {
            return new Result(true, null, null, datSanId, coSoId, tongTien, trangThai, applyLights, durationMinutes);
        }

        static Result fail(String errorCode, String message) {
            return new Result(false, errorCode, message, null, null, null, null, false, 0);
        }
    }

    /**
     * Tạo booking. Trả về Result thay vì ném exception để caller (Web Servlet hoặc REST API)
     * tự quyết định cách hiển thị.
     */
    public Result create(TaiKhoan user, Command cmd) {
        Result validation = validate(user, cmd);
        if (validation != null) return validation;

        for (int attempt = 1; attempt <= MAX_DEADLOCK_RETRIES; attempt++) {
            try (Connection conn = DBUtil.getConnection()) {
                if (conn == null) {
                    return Result.fail(ERR_INTERNAL, "Không thể kết nối cơ sở dữ liệu. Vui lòng thử lại sau.");
                }
                conn.setAutoCommit(false);
                try {
                    Result result = doCreate(conn, user, cmd);
                    if (result.success) {
                        conn.commit();
                    } else {
                        conn.rollback();
                    }
                    return result;
                } catch (SQLException sqlEx) {
                    try { conn.rollback(); } catch (SQLException ignored) { }
                    if (isDeadlock(sqlEx) && attempt < MAX_DEADLOCK_RETRIES) {
                        LOGGER.log(Level.WARNING, String.format(
                                "Deadlock khi đặt sân (lần %d/%d), retry...", attempt, MAX_DEADLOCK_RETRIES), sqlEx);
                        sleepBeforeRetry(attempt);
                        continue;
                    }
                    LOGGER.log(Level.SEVERE, "Lỗi SQL không thể phục hồi khi đặt sân", sqlEx);
                    return Result.fail(ERR_INTERNAL,
                            "Hệ thống đang bận. Vui lòng thử lại sau ít phút. (SQL Error: " + sqlEx.getErrorCode() + ")");
                } catch (Exception e) {
                    try { conn.rollback(); } catch (SQLException ignored) { }
                    LOGGER.log(Level.SEVERE, "Lỗi bất ngờ khi đặt sân", e);
                    return Result.fail(ERR_INTERNAL, "Có lỗi xảy ra: " + e.getMessage());
                }
            } catch (SQLException connEx) {
                LOGGER.log(Level.SEVERE, "Không thể lấy kết nối DB", connEx);
                return Result.fail(ERR_INTERNAL, "Không thể kết nối cơ sở dữ liệu. Vui lòng thử lại sau.");
            }
        }
        LOGGER.severe("Đặt sân thất bại sau " + MAX_DEADLOCK_RETRIES + " lần retry do deadlock liên tục.");
        return Result.fail(ERR_INTERNAL, "Hệ thống đang có nhiều yêu cầu đồng thời. Vui lòng thử lại sau vài giây.");
    }

    /** Kiểm tra thuần (không chạm DB). Trả null nếu hợp lệ. */
    private Result validate(TaiKhoan user, Command cmd) {
        if (user == null) {
            return Result.fail(ERR_VALIDATION, "Cần đăng nhập để đặt sân.");
        }
        if (cmd.ngayDat == null || cmd.gioBatDau == null || cmd.gioKetThuc == null || cmd.sanId <= 0) {
            return Result.fail(ERR_VALIDATION, "Thiếu thông tin đặt sân. Vui lòng chọn lại sân, ngày và khung giờ.");
        }
        if (user.getDiemUyTin() < Constants.REPUTATION_BOOKING_BLOCK_THRESHOLD) {
            return Result.fail(ERR_REPUTATION, "Tài khoản của bạn đã bị hạn chế đặt sân do điểm uy tín quá thấp ("
                    + user.getDiemUyTin() + " điểm, tối thiểu cần "
                    + Constants.REPUTATION_BOOKING_BLOCK_THRESHOLD + " điểm). Vui lòng liên hệ quản lý để được hỗ trợ.");
        }
        if (cmd.serviceIds.length != cmd.serviceQtys.length) {
            return Result.fail(ERR_VALIDATION, "Danh sách dịch vụ không hợp lệ.");
        }
        for (int qty : cmd.serviceQtys) {
            if (qty <= 0) return Result.fail(ERR_VALIDATION, "Số lượng dịch vụ phải lớn hơn 0.");
        }
        if (!cmd.gioKetThuc.isAfter(cmd.gioBatDau)) {
            return Result.fail(ERR_VALIDATION, "Giờ kết thúc phải sau giờ bắt đầu.");
        }
        long durationMinutes = Duration.between(cmd.gioBatDau, cmd.gioKetThuc).toMinutes();
        if (durationMinutes < 30) {
            return Result.fail(ERR_VALIDATION, "Thời lượng đặt sân tối thiểu cho mỗi lượt là 30 phút.");
        }
        if (durationMinutes > 240) {
            return Result.fail(ERR_VALIDATION, "Thời lượng đặt sân tối đa cho mỗi lượt là 4 giờ (240 phút).");
        }

        LocalDate today = LocalDate.now();
        LocalTime now = LocalTime.now();
        if (cmd.ngayDat.isBefore(today)) {
            return Result.fail(ERR_VALIDATION, "Không thể đặt sân cho ngày đã qua. Vui lòng chọn ngày từ hôm nay trở đi.");
        }
        if (cmd.ngayDat.equals(today) && cmd.gioBatDau.isBefore(now)) {
            return Result.fail(ERR_VALIDATION,
                    "Không thể đặt sân cho giờ đã qua trong ngày hôm nay. Vui lòng chọn giờ khác.");
        }
        LocalDate maxDate = today.plusDays(30);
        if (cmd.ngayDat.isAfter(maxDate)) {
            return Result.fail(ERR_VALIDATION, "Chỉ có thể đặt sân trong vòng 30 ngày tới (tối đa đến ngày "
                    + maxDate + "). Vui lòng chọn ngày khác.");
        }
        return null;
    }

    /** Thân transaction. Ném SQLException để caller quyết định retry/rollback. */
    private Result doCreate(Connection conn, TaiKhoan user, Command cmd) throws SQLException {
        // ── Khóa hàng San chống concurrent booking cùng sân ──
        String sanTrangThai;
        int sanCoSoID;
        try (PreparedStatement lockPs = conn.prepareStatement(
                "SELECT SanID, TrangThai, CoSoID FROM San WITH (UPDLOCK, ROWLOCK) WHERE SanID = ?")) {
            lockPs.setInt(1, cmd.sanId);
            try (ResultSet rs = lockPs.executeQuery()) {
                if (!rs.next()) {
                    return Result.fail(ERR_NOT_FOUND, "Sân không tồn tại trong hệ thống.");
                }
                sanTrangThai = rs.getString("TrangThai");
                sanCoSoID = rs.getInt("CoSoID");
            }
        }

        // Giải phóng SoftHold của chính tài khoản này (connection riêng, không nằm trong transaction).
        softHoldDAO.deleteHoldsByAccountAndSan(user.getAccountId(), cmd.sanId, cmd.ngayDat);

        if (org.example.dao.impl.LichDatSanDAOImpl.countActiveBookingsForAccountAndDate(
                conn, user.getAccountId(), cmd.ngayDat) >= MAX_ACTIVE_BOOKINGS_PER_DAY) {
            return Result.fail(ERR_BOOKING_LIMIT,
                    "Bạn đã đạt giới hạn đặt sân tối đa trong ngày hôm nay (tối đa 3 lượt đặt/ngày).");
        }

        // Trạng thái sân: chỉ 'Bảo trì'/khác mới chặn; trùng khung giờ do overlap check bên dưới xử lý.
        if (!"Sẵn sàng".equals(sanTrangThai) && !"Đang sử dụng".equals(sanTrangThai)) {
            return Result.fail(ERR_COURT_UNAVAIL, "Sân này hiện đang ở trạng thái [" + sanTrangThai
                    + "] và không thể đặt. Vui lòng chọn sân khác.");
        }

        // ── Giờ hoạt động của cơ sở ──
        LocalTime branchOpen = DEFAULT_OPEN_TIME;
        LocalTime branchClose = DEFAULT_CLOSE_TIME;
        String branchName = "Cơ Sở";
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT TenCoSo, GioMoCua, GioDongCua FROM CoSo WHERE CoSoID = ?")) {
            ps.setInt(1, sanCoSoID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    branchName = rs.getString("TenCoSo");
                    java.sql.Time dbOpen = rs.getTime("GioMoCua");
                    java.sql.Time dbClose = rs.getTime("GioDongCua");
                    if (dbOpen != null) branchOpen = dbOpen.toLocalTime();
                    if (dbClose != null) branchClose = dbClose.toLocalTime();
                }
            }
        }
        if (cmd.gioBatDau.isBefore(branchOpen)) {
            return Result.fail(ERR_VALIDATION, String.format("%s mở cửa lúc %s. Giờ bắt đầu của bạn (%s) quá sớm.",
                    branchName, branchOpen.toString().substring(0, 5), cmd.gioBatDau.toString().substring(0, 5)));
        }
        if (cmd.gioKetThuc.isAfter(branchClose)) {
            return Result.fail(ERR_VALIDATION, String.format(
                    "%s đóng cửa lúc %s. Giờ kết thúc của bạn (%s) vượt quá giờ hoạt động.",
                    branchName, branchClose.toString().substring(0, 5), cmd.gioKetThuc.toString().substring(0, 5)));
        }

        // ── Trùng lịch ──
        if (hasOverlap(conn, cmd.sanId, cmd.ngayDat, cmd.gioBatDau, cmd.gioKetThuc)) {
            return Result.fail(ERR_SLOT_TAKEN, "Khung giờ " + cmd.gioBatDau.toString().substring(0, 5) + " - "
                    + cmd.gioKetThuc.toString().substring(0, 5)
                    + " đã có người đặt cho sân này. Vui lòng chọn khung giờ khác.");
        }
        if (hasActiveHoldFromOther(conn, cmd.sanId, cmd.ngayDat, cmd.gioBatDau, cmd.gioKetThuc, user.getAccountId())) {
            return Result.fail(ERR_SLOT_TAKEN, "Khung giờ " + cmd.gioBatDau.toString().substring(0, 5) + " - "
                    + cmd.gioKetThuc.toString().substring(0, 5)
                    + " hiện đang được người khác giữ chỗ tạm thời. Vui lòng thử lại sau ít phút hoặc chọn khung giờ khác.");
        }

        // ── Tính giá (server-side, theo bảng giá LoaiSan + giờ đèn) ──
        CourtPriceResult priceResult = calculatePrice(conn, cmd.sanId, cmd.ngayDat, cmd.gioBatDau, cmd.gioKetThuc);
        long durationMinutes = priceResult.totalMinutes();
        BigDecimal tongTien = priceResult.totalCourtAmount().setScale(0, RoundingMode.HALF_UP);
        boolean applyLights = priceResult.minutesWithLight() > 0;

        // ── INSERT ──
        boolean isOnlineDeposit = cmd.onlinePayment;
        String initialStatus = isOnlineDeposit
                ? Constants.TRANG_THAI_DAT_SAN_CHO_THANH_TOAN
                : Constants.TRANG_THAI_DAT_SAN_CHO_XAC_NHAN;
        // HoldExpiresAt là mốc tuyệt đối -> ghi bằng SYSUTCDATETIME() (UTC), xem TimeUtil.
        String holdExpiresAtExpr = isOnlineDeposit
                ? "DATEADD(MINUTE, " + Constants.BOOKING_HOLD_MINUTES + ", SYSUTCDATETIME())"
                : "NULL";

        int newDatSanId = -1;
        String insertSql = "INSERT INTO LichDatSan "
                + "(AccountID, SanID, NgayDat, GioBatDau, GioKetThuc, "
                + " ApDungGiaCoDen, TongTienDuKien, TrangThai, GhiChu, NguonDatSan, HoldExpiresAt) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, " + holdExpiresAtExpr + ")";
        try (PreparedStatement ps = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, user.getAccountId());
            ps.setInt(2, cmd.sanId);
            ps.setDate(3, java.sql.Date.valueOf(cmd.ngayDat));
            ps.setTime(4, java.sql.Time.valueOf(cmd.gioBatDau));
            ps.setTime(5, java.sql.Time.valueOf(cmd.gioKetThuc));
            ps.setBoolean(6, applyLights);
            ps.setBigDecimal(7, tongTien);
            ps.setString(8, initialStatus);
            ps.setString(9, cmd.ghiChu != null ? cmd.ghiChu.trim() : "");
            ps.setString(10, cmd.nguonDatSan != null ? cmd.nguonDatSan : "Web");
            ps.executeUpdate();
            try (ResultSet genKeys = ps.getGeneratedKeys()) {
                if (genKeys.next()) newDatSanId = genKeys.getInt(1);
            }
        }

        // ── Dịch vụ đặt trước: giá lấy từ DB, không tin client ──
        Result serviceError = insertPreOrderedServices(conn, cmd, sanCoSoID, newDatSanId);
        if (serviceError != null) return serviceError;

        try (PreparedStatement ps = conn.prepareStatement(
                "DELETE FROM SoftHold WHERE AccountID = ? AND SanID = ? AND NgayDat = ?")) {
            ps.setInt(1, user.getAccountId());
            ps.setInt(2, cmd.sanId);
            ps.setDate(3, java.sql.Date.valueOf(cmd.ngayDat));
            ps.executeUpdate();
        }

        return Result.ok(newDatSanId, sanCoSoID, tongTien, initialStatus, applyLights, durationMinutes);
    }

    private boolean hasOverlap(Connection conn, int sanId, LocalDate ngayDat,
                               LocalTime batDau, LocalTime ketThuc) throws SQLException {
        // "Chờ xác nhận" (COD) chặn slot cho tới khi được duyệt/từ chối/tự hết hạn.
        // "Chờ thanh toán" chỉ chặn khi còn hạn giữ chỗ thật (HoldExpiresAt).
        String sql = "SELECT COUNT(*) FROM LichDatSan "
                + "WHERE SanID = ? AND NgayDat = ? "
                + "AND (TrangThai IN (N'" + Constants.TRANG_THAI_DAT_SAN_DA_XAC_NHAN + "', "
                + "N'" + Constants.TRANG_THAI_DAT_SAN_DANG_SU_DUNG + "', "
                + "N'" + Constants.TRANG_THAI_DAT_SAN_CHO_XAC_NHAN + "') "
                + "     OR (TrangThai = N'" + Constants.TRANG_THAI_DAT_SAN_CHO_THANH_TOAN
                + "' AND HoldExpiresAt > SYSUTCDATETIME())) "
                + "AND NOT (GioKetThuc <= CAST(? AS time) OR GioBatDau >= CAST(? AS time))";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, sanId);
            ps.setDate(2, java.sql.Date.valueOf(ngayDat));
            ps.setString(3, batDau.toString());
            ps.setString(4, ketThuc.toString());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    private boolean hasActiveHoldFromOther(Connection conn, int sanId, LocalDate ngayDat, LocalTime batDau,
                                           LocalTime ketThuc, int accountId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM SoftHold "
                + "WHERE SanID = ? AND NgayDat = ? AND AccountID <> ? "
                + "AND DATEDIFF(minute, CreatedTime, GETDATE()) <= " + Constants.SOFT_HOLD_TIMEOUT_MINUTES + " "
                + "AND NOT (GioKetThuc <= CAST(? AS time) OR GioBatDau >= CAST(? AS time))";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, sanId);
            ps.setDate(2, java.sql.Date.valueOf(ngayDat));
            ps.setInt(3, accountId);
            ps.setString(4, batDau.toString());
            ps.setString(5, ketThuc.toString());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    /**
     * Tính tiền sân bằng {@link CourtPricingService} với bảng giá của LoaiSan tương ứng.
     * Public để endpoint "availability" của mobile dùng CHUNG đúng một công thức giá — mobile
     * không bao giờ có bảng giá riêng.
     */
    public CourtPriceResult calculatePrice(Connection conn, int sanId, LocalDate ngayDat,
                                           LocalTime gioBatDau, LocalTime gioKetThuc) throws SQLException {
        BigDecimal giaKhongDen = null;
        BigDecimal giaCoDen = null;
        LocalTime lenDen = null;
        LocalTime tatDen = null;
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT GiaKhongDen, GiaCoDen, GioBatDauLenDen, GioKetThucLenDen "
                        + "FROM LoaiSan WHERE LoaiSanID = (SELECT LoaiSanID FROM San WHERE SanID = ?)")) {
            ps.setInt(1, sanId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    giaKhongDen = BigDecimal.valueOf(rs.getDouble("GiaKhongDen"));
                    giaCoDen = BigDecimal.valueOf(rs.getDouble("GiaCoDen"));
                    java.sql.Time s = rs.getTime("GioBatDauLenDen");
                    if (s != null) lenDen = s.toLocalTime();
                    java.sql.Time e = rs.getTime("GioKetThucLenDen");
                    if (e != null) tatDen = e.toLocalTime();
                }
            }
        }
        if (giaKhongDen == null) {
            giaKhongDen = BigDecimal.valueOf(100_000); // fallback như bản Web gốc
            giaCoDen = giaKhongDen;
        }
        LocalDate ngayKetThuc = !gioKetThuc.isAfter(gioBatDau) ? ngayDat.plusDays(1) : ngayDat;
        return pricingService.calculate(
                LocalDateTime.of(ngayDat, gioBatDau), LocalDateTime.of(ngayKetThuc, gioKetThuc),
                lenDen, tatDen, giaKhongDen, giaCoDen);
    }

    /** Trả về Result lỗi nếu có dòng dịch vụ không hợp lệ (caller sẽ rollback), null nếu OK. */
    private Result insertPreOrderedServices(Connection conn, Command cmd, int sanCoSoID, int datSanId)
            throws SQLException {
        if (cmd.serviceIds.length == 0) return null;
        String sql = "SELECT SanPhamID, TenSanPham, DonGia, SoLuongTon, TrangThai, CoSoID "
                + "FROM SanPham_DichVu WHERE SanPhamID = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 0; i < cmd.serviceIds.length; i++) {
                int spId = cmd.serviceIds[i];
                int qty = cmd.serviceQtys[i];
                ps.setInt(1, spId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        return Result.fail(ERR_NOT_FOUND, "Một dịch vụ bạn chọn không tồn tại. Vui lòng thử lại.");
                    }
                    int spCoSoId = rs.getInt("CoSoID");
                    String spTrangThai = rs.getString("TrangThai");
                    int soLuongTon = rs.getInt("SoLuongTon");
                    String tenSp = rs.getString("TenSanPham");
                    BigDecimal donGia = rs.getBigDecimal("DonGia");

                    if (spCoSoId != sanCoSoID) {
                        return Result.fail(ERR_VALIDATION,
                                "Dịch vụ '" + tenSp + "' không thuộc cơ sở của sân bạn đang đặt.");
                    }
                    if (!Constants.TRANG_THAI_SP_DANG_KINH_DOANH.equals(spTrangThai)) {
                        return Result.fail(ERR_VALIDATION, "Dịch vụ '" + tenSp + "' hiện không kinh doanh.");
                    }
                    if (qty > soLuongTon) {
                        return Result.fail(ERR_VALIDATION, "Dịch vụ '" + tenSp + "' chỉ còn " + soLuongTon
                                + " trong kho, không đủ số lượng bạn chọn.");
                    }
                    lichDatSanDichVuDAO.insertPreOrder(conn, datSanId, spId, qty, donGia,
                            donGia.multiply(BigDecimal.valueOf(qty)));
                }
            }
        }
        return null;
    }

    private boolean isDeadlock(SQLException ex) {
        SQLException current = ex;
        while (current != null) {
            if (current.getErrorCode() == SQL_DEADLOCK_ERROR_CODE) return true;
            current = current.getNextException();
        }
        return ex.getMessage() != null && ex.getMessage().toLowerCase().contains("deadlock");
    }

    private void sleepBeforeRetry(int attempt) {
        try {
            Thread.sleep(50L * attempt + (long) (Math.random() * 100 * attempt));
        } catch (InterruptedException ie) {
            Thread.currentThread().interrupt();
        }
    }
}
