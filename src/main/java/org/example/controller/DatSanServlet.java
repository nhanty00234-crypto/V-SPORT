package org.example.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.dao.LichDatSanDAO;
import org.example.dao.LoaiSanDAO;
import org.example.dao.SanDAO;
import org.example.dao.impl.LichDatSanDAOImpl;
import org.example.dao.impl.LoaiSanDAOImpl;
import org.example.dao.impl.SanDAOImpl;
import org.example.model.LoaiSan;
import org.example.model.MonTheThao;
import org.example.model.Lichdatsan;
import org.example.model.TaiKhoan;
import org.example.model.San;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.LocalDateTime;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * ===============================================================
 * DatSanServlet - Servlet xử lý toàn bộ luồng đặt sân của khách hàng
 * ===============================================================
 *
 * LUỒNG HOẠT ĐỘNG CHÍNH:
 * GET /customer/dat-san → Hiển thị trang đặt sân (Cho phép khách không đăng
 * nhập xem)
 * GET /customer/lich-su-dat-san → Xem lịch sử đặt sân (Yêu cầu đăng nhập)
 * POST /customer/dat-san → Thực hiện đặt sân (Yêu cầu đăng nhập)
 * POST /customer/huy-dat-san → Hủy lịch đặt sân (Yêu cầu đăng nhập)
 *
 * CÁC CƠ CHẾ BẢO VỆ:
 * 1. Kiểm tra ngày/giờ trong quá khứ
 * 2. Kiểm tra giờ mở/đóng cửa Cơ Sở
 * 3. Kiểm tra trạng thái sân (chỉ chấp nhận 'Sẵn sàng')
 * 4. Kiểm tra trùng lịch với row-level lock (UPDLOCK, ROWLOCK)
 * 5. Retry loop tự phục hồi khi xảy ra deadlock (SQL Error 1205)
 *
 * @author DatN (Senior refactor)
 * @version 2.0
 */
@WebServlet(urlPatterns = { "/customer/dat-san", "/customer/dat_san", "/customer/lich-su-dat-san", "/customer/huy-dat-san" })
public class DatSanServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(DatSanServlet.class.getName());

    /** Số lần thử lại tối đa khi xảy ra deadlock (SQL Error 1205) */
    private static final int MAX_DEADLOCK_RETRIES = 3;

    /** SQL Server error code cho deadlock */
    private static final int SQL_DEADLOCK_ERROR_CODE = 1205;

    /** Giờ mở cửa mặc định nếu Cơ Sở không cấu hình */
    private static final LocalTime DEFAULT_OPEN_TIME = LocalTime.of(6, 0);

    /** Giờ đóng cửa mặc định nếu Cơ Sở không cấu hình */
    private static final LocalTime DEFAULT_CLOSE_TIME = LocalTime.of(23, 0);

    private final LichDatSanDAO lichDatSanDAO = new LichDatSanDAOImpl();
    private final SanDAO sanDAO = new SanDAOImpl();
    private final LoaiSanDAO loaiSanDAO = new LoaiSanDAOImpl();
    private final org.example.dao.CoSoDAO coSoDAO = new org.example.dao.impl.CoSoDAOImpl();

    // =========================================================================
    // PHẦN 1: XỬ LÝ GET - Hiển thị trang
    // =========================================================================

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        HttpSession session = req.getSession();
        TaiKhoan user = (TaiKhoan) session.getAttribute("user");

        // Khách chưa đăng nhập vẫn được xem trang đặt sân để khám phá,
        // nhưng không thể submit form (nút sẽ chuyển thành "Đăng nhập")
        // Chỉ chặn những trang yêu cầu đăng nhập bắt buộc
        if (user == null && !isBookingPage(path)) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return;
        }

        if (isBookingPage(path)) {
            loadBookingPage(req, resp);
        } else if (path.equals("/customer/lich-su-dat-san")) {
            resp.sendRedirect(req.getContextPath() + "/customer/dat-san?openHistory=true");
        }
    }

    /**
     * Tải dữ liệu và chuyển tiếp đến trang DatSan.jsp.
     * Load: danh sách sân, Cơ Sở, môn thể thao, loại sân, lịch đặt hiện tại.
     */
    private void loadBookingPage(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        List<org.example.model.CoSo> dsCoSo = coSoDAO.getAllCoSo();
        List<San> dsSan = new java.util.ArrayList<>();
        List<MonTheThao> dsMon = new java.util.ArrayList<>();
        List<LoaiSan> dsLoai = new java.util.ArrayList<>();

        try {
            dsSan = sanDAO.getAllSan();
            dsMon = loaiSanDAO.getAllMonTheThao();
            dsLoai = loaiSanDAO.getAllLoaiSan();
            LOGGER.info("Loaded " + dsSan.size() + " courts from database.");
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Lỗi khi tải dữ liệu trang đặt sân", e);
        }

        // Lấy toàn bộ lịch đặt hiện tại để hiển thị timetable xung đột trên frontend
        List<Lichdatsan> activeBookings = lichDatSanDAO.getAllLichDatSan();
        if (activeBookings != null) {
            activeBookings.removeIf(b -> "Chờ thanh toán".equals(b.getTrangThai()) &&
                    b.getCreatedTime() != null &&
                    b.getCreatedTime().plusMinutes(10).isBefore(LocalDateTime.now()));
        }

        // Lấy lịch sử đặt sân của cá nhân khách hàng nếu đã đăng nhập
        HttpSession session = req.getSession();
        TaiKhoan user = (TaiKhoan) session.getAttribute("user");
        if (user != null) {
            try {
                List<Lichdatsan> dsLich = lichDatSanDAO.getLichByAccountId(user.getAccountId());
                req.setAttribute("dsLich", dsLich);
            } catch (Exception e) {
                LOGGER.log(Level.WARNING, "Lỗi khi tải lịch sử đặt sân cho khách hàng", e);
            }
        }

        req.setAttribute("dsSan", dsSan);
        req.setAttribute("dsCoSo", dsCoSo);
        req.setAttribute("dsMon", dsMon);
        req.setAttribute("dsLoai", dsLoai);
        req.setAttribute("activeBookings", activeBookings);

        req.getRequestDispatcher("/customer/DatSan.jsp").forward(req, resp);
    }

    /**
     * Tải lịch sử đặt sân cá nhân và chuyển tiếp đến LichSuDatSan.jsp.
     */
    private void loadHistoryPage(HttpServletRequest req, HttpServletResponse resp, TaiKhoan user)
            throws ServletException, IOException {
        List<Lichdatsan> dsLich = lichDatSanDAO.getLichByAccountId(user.getAccountId());

        // Lấy tên sân và Cơ Sở để hiển thị đẹp hơn trong bảng lịch sử
        List<San> dsSan = sanDAO.getAllSan();
        List<org.example.model.CoSo> dsCoSo = coSoDAO.getAllCoSo();

        req.setAttribute("dsLich", dsLich);
        req.setAttribute("dsSan", dsSan);
        req.setAttribute("dsCoSo", dsCoSo);
        req.getRequestDispatcher("/customer/LichSuDatSan.jsp").forward(req, resp);
    }

    // =========================================================================
    // PHẦN 2: XỬ LÝ POST - Xử lý hành động đặt sân / hủy sân
    // =========================================================================

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String path = req.getServletPath();
        HttpSession session = req.getSession();
        TaiKhoan user = (TaiKhoan) session.getAttribute("user");

        // POST luôn yêu cầu đăng nhập
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return;
        }

        if (path.equals("/customer/dat-san")) {
            handleDatSan(req, resp, session, user);
        } else if (path.equals("/customer/huy-dat-san")) {
            handleHuyDatSan(req, resp, session, user);
        }
    }

    // =========================================================================
    // PHẦN 3: LOGIC ĐẶT SÂN - Với đầy đủ kiểm tra và retry deadlock
    // =========================================================================

    /**
     * Xử lý yêu cầu đặt sân từ khách hàng.
     *
     * QUY TRÌNH:
     * 1. Parse và validate input
     * 2. Kiểm tra ngày giờ không được trong quá khứ
     * 3. Vòng lặp retry khi deadlock (tối đa MAX_DEADLOCK_RETRIES lần):
     * a. Bắt đầu transaction
     * b. Lock hàng San (UPDLOCK, ROWLOCK) để ngăn concurrent booking
     * c. Kiểm tra trạng thái sân (chỉ chấp nhận 'Sẵn sàng')
     * d. Kiểm tra giờ mở cửa Cơ Sở
     * e. Kiểm tra trùng lịch
     * f. Tính giá và INSERT
     * g. Commit transaction
     */
    private void handleDatSan(HttpServletRequest req, HttpServletResponse resp,
            HttpSession session, TaiKhoan user) throws IOException {
        // --- Bước 1: Parse input ---
        int sanId;
        LocalDate ngayDat;
        LocalTime gioBatDau, gioKetThuc;
        String ghiChu;
        String paymentMethod;

        try {
            sanId = Integer.parseInt(req.getParameter("sanId"));
            ngayDat = LocalDate.parse(req.getParameter("ngayDat"));
            gioBatDau = LocalTime.parse(req.getParameter("gioBatDau"));
            gioKetThuc = LocalTime.parse(req.getParameter("gioKetThuc"));
            ghiChu = req.getParameter("ghiChu");
            paymentMethod = req.getParameter("paymentMethod");
            if (paymentMethod == null || paymentMethod.trim().isEmpty()) {
                paymentMethod = "sau";
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Dữ liệu đặt sân không hợp lệ", e);
            session.setAttribute("error", "Dữ liệu không hợp lệ. Vui lòng kiểm tra lại thông tin.");
            resp.sendRedirect(req.getContextPath() + "/customer/dat-san");
            return;
        }

        // --- Bước 2: Validate thứ tự giờ ---
        if (!gioKetThuc.isAfter(gioBatDau)) {
            session.setAttribute("error", "Giờ kết thúc phải sau giờ bắt đầu.");
            resp.sendRedirect(req.getContextPath() + "/customer/dat-san");
            return;
        }

        // --- Bước 2b: Validate ngày/giờ không được trong quá khứ ---
        LocalDate today = LocalDate.now();
        LocalTime now = LocalTime.now();

        if (ngayDat.isBefore(today)) {
            session.setAttribute("error", "Không thể đặt sân cho ngày đã qua. Vui lòng chọn ngày từ hôm nay trở đi.");
            resp.sendRedirect(req.getContextPath() + "/customer/dat-san");
            return;
        }

        if (ngayDat.equals(today) && gioBatDau.isBefore(now)) {
            session.setAttribute("error",
                    "Không thể đặt sân cho giờ đã qua trong ngày hôm nay. Vui lòng chọn giờ khác.");
            resp.sendRedirect(req.getContextPath() + "/customer/dat-san");
            return;
        }

        // --- Bước 3: Vòng lặp retry deadlock ---
        for (int attempt = 1; attempt <= MAX_DEADLOCK_RETRIES; attempt++) {
            try (java.sql.Connection conn = org.example.util.DBUtil.getConnection()) {
                if (conn == null) {
                    session.setAttribute("error", "Không thể kết nối cơ sở dữ liệu. Vui lòng thử lại sau.");
                    resp.sendRedirect(req.getContextPath() + "/customer/dat-san");
                    return;
                }

                conn.setAutoCommit(false);
                try {
                    // ── 3a. Khóa hàng San để ngăn concurrent booking cùng sân ──
                    // Sử dụng UPDLOCK + ROWLOCK để block đọc lẫn ghi cho hàng này
                    // trong suốt transaction, tránh race condition dẫn đến double booking
                    String lockSql = "SELECT SanID, TrangThai, CoSoID FROM San WITH (UPDLOCK, ROWLOCK) WHERE SanID = ?";
                    String sanTrangThai;
                    int sanCoSoID;

                    try (java.sql.PreparedStatement lockPs = conn.prepareStatement(lockSql)) {
                        lockPs.setInt(1, sanId);
                        try (java.sql.ResultSet rsLock = lockPs.executeQuery()) {
                            if (!rsLock.next()) {
                                conn.rollback();
                                session.setAttribute("error", "Sân không tồn tại trong hệ thống.");
                                resp.sendRedirect(req.getContextPath() + "/customer/dat-san");
                                return;
                            }
                            sanTrangThai = rsLock.getString("TrangThai");
                            sanCoSoID = rsLock.getInt("CoSoID");
                        }
                    }

                    // ── 3b. Kiểm tra trạng thái sân ──
                    // Chỉ cho phép đặt khi sân ở trạng thái 'Sẵn sàng'
                    if (!"Sẵn sàng".equals(sanTrangThai)) {
                        conn.rollback();
                        session.setAttribute("error",
                                "Sân này hiện đang ở trạng thái [" + sanTrangThai + "] và không thể đặt. " +
                                        "Vui lòng chọn sân khác.");
                        resp.sendRedirect(req.getContextPath() + "/customer/dat-san");
                        return;
                    }

                    // ── 3c. Kiểm tra giờ hoạt động của Cơ Sở ──
                    // Nếu Cơ Sở không có cấu hình giờ, mặc định dùng 06:00 - 23:00
                    LocalTime branchOpen = DEFAULT_OPEN_TIME;
                    LocalTime branchClose = DEFAULT_CLOSE_TIME;
                    String branchName = "Cơ Sở";

                    String coSoSql = "SELECT TenCoSo, GioMoCua, GioDongCua FROM CoSo WHERE CoSoID = ?";
                    try (java.sql.PreparedStatement coSoPs = conn.prepareStatement(coSoSql)) {
                        coSoPs.setInt(1, sanCoSoID);
                        try (java.sql.ResultSet rsCoSo = coSoPs.executeQuery()) {
                            if (rsCoSo.next()) {
                                branchName = rsCoSo.getString("TenCoSo");
                                java.sql.Time dbOpen = rsCoSo.getTime("GioMoCua");
                                java.sql.Time dbClose = rsCoSo.getTime("GioDongCua");
                                if (dbOpen != null)
                                    branchOpen = dbOpen.toLocalTime();
                                if (dbClose != null)
                                    branchClose = dbClose.toLocalTime();
                            }
                        }
                    }

                    // Kiểm tra giờ bắt đầu không được trước giờ mở cửa
                    if (gioBatDau.isBefore(branchOpen)) {
                        conn.rollback();
                        session.setAttribute("error", String.format(
                                "%s mở cửa lúc %s. Giờ bắt đầu của bạn (%s) quá sớm.",
                                branchName,
                                branchOpen.toString().substring(0, 5),
                                gioBatDau.toString().substring(0, 5)));
                        resp.sendRedirect(req.getContextPath() + "/customer/dat-san");
                        return;
                    }

                    // Kiểm tra giờ kết thúc không được vượt quá giờ đóng cửa
                    if (gioKetThuc.isAfter(branchClose)) {
                        conn.rollback();
                        session.setAttribute("error", String.format(
                                "%s đóng cửa lúc %s. Giờ kết thúc của bạn (%s) vượt quá giờ hoạt động.",
                                branchName,
                                branchClose.toString().substring(0, 5),
                                gioKetThuc.toString().substring(0, 5)));
                        resp.sendRedirect(req.getContextPath() + "/customer/dat-san");
                        return;
                    }

                    // ── 3d. Kiểm tra trùng lịch (Overlap check) ──
                    // Công thức overlap: NOT (KetThuc <= BatDau_Khac OR BatDau >= KetThuc_Khac)
                    String checkSql = "SELECT COUNT(*) FROM LichDatSan " +
                            "WHERE SanID = ? AND NgayDat = ? " +
                            "AND (TrangThai != N'Đã hủy' AND NOT (TrangThai = N'Chờ thanh toán' AND DATEDIFF(minute, CreatedTime, GETDATE()) > 10)) " +
                            "AND NOT (GioKetThuc <= CAST(? AS time) OR GioBatDau >= CAST(? AS time))";

                    boolean hasOverlap;
                    try (java.sql.PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
                        checkPs.setInt(1, sanId);
                        checkPs.setDate(2, java.sql.Date.valueOf(ngayDat));
                        checkPs.setString(3, gioBatDau.toString()); // KetThuc <= BatDauNew => không overlap
                        checkPs.setString(4, gioKetThuc.toString()); // BatDau >= KetThucNew => không overlap
                        try (java.sql.ResultSet rs = checkPs.executeQuery()) {
                            hasOverlap = rs.next() && rs.getInt(1) > 0;
                        }
                    }

                    if (hasOverlap) {
                        conn.rollback();
                        session.setAttribute("error",
                                "Khung giờ " + gioBatDau.toString().substring(0, 5) + " - " +
                                        gioKetThuc.toString().substring(0, 5) +
                                        " đã có người đặt cho sân này. Vui lòng chọn khung giờ khác.");
                        resp.sendRedirect(req.getContextPath() + "/customer/dat-san");
                        return;
                    }

                    // ── 3e. Tính giá theo loại sân và giờ đèn ──
                    double hourlyPrice = 100_000; // Fallback mặc định
                    boolean applyLights = false;

                    String loaiSanSql = "SELECT GiaKhongDen, GiaCoDen, GioBatDauLenDen FROM LoaiSan WHERE LoaiSanID = "
                            +
                            "(SELECT LoaiSanID FROM San WHERE SanID = ?)";
                    try (java.sql.PreparedStatement loaiPs = conn.prepareStatement(loaiSanSql)) {
                        loaiPs.setInt(1, sanId);
                        try (java.sql.ResultSet rsLoai = loaiPs.executeQuery()) {
                            if (rsLoai.next()) {
                                double giaKhongDen = rsLoai.getDouble("GiaKhongDen");
                                double giaCoDen = rsLoai.getDouble("GiaCoDen");
                                LocalTime gioLenDen = LocalTime.of(17, 30); // Mặc định 17:30

                                java.sql.Time sqlLenDen = rsLoai.getTime("GioBatDauLenDen");
                                if (sqlLenDen != null)
                                    gioLenDen = sqlLenDen.toLocalTime();

                                // Áp dụng giá đèn nếu giờ bắt đầu >= giờ bật đèn
                                if (!gioBatDau.isBefore(gioLenDen)) {
                                    hourlyPrice = giaCoDen;
                                    applyLights = (giaCoDen != giaKhongDen); // Chỉ ghi nhận nếu giá thực sự khác nhau
                                } else {
                                    hourlyPrice = giaKhongDen;
                                }
                            }
                        }
                    }

                    // Tính tổng tiền dự kiến
                    long durationMinutes = java.time.Duration.between(gioBatDau, gioKetThuc).toMinutes();
                    double durationHours = durationMinutes / 60.0;
                    double tongTien = durationHours * hourlyPrice;

                    // ── 3f. INSERT lịch đặt sân trong cùng transaction ──
                    String insertSql = "INSERT INTO LichDatSan " +
                            "(AccountID, SanID, NgayDat, GioBatDau, GioKetThuc, " +
                            " ApDungGiaCoDen, TongTienDuKien, TrangThai, GhiChu, NguonDatSan) " +
                            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

                    try (java.sql.PreparedStatement insertPs = conn.prepareStatement(insertSql)) {
                        insertPs.setInt(1, user.getAccountId());
                        insertPs.setInt(2, sanId);
                        insertPs.setDate(3, java.sql.Date.valueOf(ngayDat));
                        insertPs.setTime(4, java.sql.Time.valueOf(gioBatDau));
                        insertPs.setTime(5, java.sql.Time.valueOf(gioKetThuc));
                        insertPs.setBoolean(6, applyLights);
                        insertPs.setBigDecimal(7,
                                BigDecimal.valueOf(tongTien).setScale(0, java.math.RoundingMode.HALF_UP));
                        String initialStatus = "payos".equalsIgnoreCase(paymentMethod) ? "Chờ thanh toán" : "Chờ xác nhận";
                        insertPs.setString(8, initialStatus);
                        insertPs.setString(9, ghiChu != null ? ghiChu.trim() : "");
                        insertPs.setString(10, "Web");
                        insertPs.executeUpdate();
                    }

                    // ── 3g. Commit toàn bộ transaction ──
                    conn.commit();

                    LOGGER.info(String.format(
                            "Đặt sân thành công: AccountID=%d, SanID=%d, Ngày=%s, %s-%s, Tiền=%,.0fđ, PTTT=%s",
                            user.getAccountId(), sanId, ngayDat, gioBatDau, gioKetThuc, tongTien, paymentMethod));

                    if ("payos".equalsIgnoreCase(paymentMethod)) {
                        session.setAttribute("message",
                                "Đăng ký đặt sân thành công! Vui lòng tiến hành quét mã QR thanh toán trong vòng 10 phút để giữ chỗ.");
                    } else {
                        session.setAttribute("message",
                                "Đặt sân thành công! Lịch đặt bằng tiền mặt chỉ được giữ chỗ tạm thời. Vui lòng đến sớm 15 phút để làm thủ tục nhận sân.");
                    }
                    resp.sendRedirect(req.getContextPath() + "/customer/lich-su-dat-san");
                    return;

                } catch (SQLException sqlEx) {
                    // Rollback transaction khi có lỗi SQL
                    try {
                        conn.rollback();
                    } catch (SQLException ignored) {
                    }

                    // Kiểm tra nếu là lỗi deadlock → thực hiện retry
                    if (isDeadlockException(sqlEx) && attempt < MAX_DEADLOCK_RETRIES) {
                        LOGGER.log(Level.WARNING,
                                String.format("Deadlock phát hiện (lần thử %d/%d), đang retry sau khoảng dừng ngắn...",
                                        attempt, MAX_DEADLOCK_RETRIES),
                                sqlEx);
                        sleepBeforeRetry(attempt); // Dừng ngắn trước khi retry
                        // Tiếp tục vòng lặp for (retry)
                    } else {
                        // Không phải deadlock hoặc đã hết số lần retry
                        LOGGER.log(Level.SEVERE, "Lỗi SQL không thể phục hồi khi đặt sân", sqlEx);
                        session.setAttribute("error", "Hệ thống đang bận. Vui lòng thử lại sau ít phút. (SQL Error: "
                                + sqlEx.getErrorCode() + ")");
                        resp.sendRedirect(req.getContextPath() + "/customer/dat-san");
                        return;
                    }

                } catch (Exception e) {
                    try {
                        conn.rollback();
                    } catch (SQLException ignored) {
                    }
                    LOGGER.log(Level.SEVERE, "Lỗi bất ngờ khi đặt sân", e);
                    session.setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
                    resp.sendRedirect(req.getContextPath() + "/customer/dat-san");
                    return;
                }

            } catch (SQLException connEx) {
                LOGGER.log(Level.SEVERE, "Không thể lấy kết nối DB", connEx);
                session.setAttribute("error", "Không thể kết nối cơ sở dữ liệu. Vui lòng thử lại sau.");
                resp.sendRedirect(req.getContextPath() + "/customer/dat-san");
                return;
            }
        } // end retry loop

        // Nếu đến đây: đã retry đủ MAX lần mà vẫn deadlock
        LOGGER.severe(String.format("Đặt sân thất bại sau %d lần retry do deadlock liên tục.", MAX_DEADLOCK_RETRIES));
        session.setAttribute("error", "Hệ thống đang có nhiều yêu cầu đồng thời. Vui lòng thử lại sau vài giây.");
        resp.sendRedirect(req.getContextPath() + "/customer/dat-san");
    }

    // =========================================================================
    // PHẦN 4: LOGIC HỦY ĐẶT SÂN
    // =========================================================================

    /**
     * Xử lý hủy lịch đặt sân.
     * Chỉ cho phép hủy đơn đang ở trạng thái 'Chờ xác nhận' và phải là đơn của
     * chính người dùng.
     */
    private void handleHuyDatSan(HttpServletRequest req, HttpServletResponse resp,
            HttpSession session, TaiKhoan user) throws IOException {
        try {
            int id = Integer.parseInt(req.getParameter("id"));
            Lichdatsan lich = lichDatSanDAO.getLichById(id);

            if (lich == null) {
                session.setAttribute("error", "Không tìm thấy đơn đặt sân.");
            } else if (lich.getAccountId() != user.getAccountId()) {
                // Bảo vệ IDOR: Không cho người dùng hủy đơn của người khác
                session.setAttribute("error", "Bạn không có quyền hủy đơn này.");
                LOGGER.warning(String.format("IDOR attempt: AccountID=%d cố hủy đơn ID=%d của AccountID=%d",
                        user.getAccountId(), id, lich.getAccountId()));
            } else if ("Chờ xác nhận".equals(lich.getTrangThai())) {
                lichDatSanDAO.updateTrangThai(id, "Đã hủy");
                session.setAttribute("message", "Đã hủy yêu cầu đặt sân #" + id + " thành công.");
            } else {
                session.setAttribute("error",
                        "Chỉ có thể hủy đơn đang ở trạng thái 'Chờ xác nhận'. " +
                                "Đơn của bạn hiện đang ở trạng thái '" + lich.getTrangThai() + "'.");
            }

        } catch (NumberFormatException e) {
            session.setAttribute("error", "Yêu cầu không hợp lệ.");
        }

        resp.sendRedirect(req.getContextPath() + "/customer/lich-su-dat-san");
    }

    // =========================================================================
    // PHẦN 5: UTILITY METHODS
    // =========================================================================

    /**
     * Kiểm tra xem một SQLException có phải là lỗi deadlock hay không.
     * SQL Server deadlock error code = 1205.
     * Phương thức kiểm tra cả chuỗi cause chain để bắt wrapped exceptions.
     */
    private boolean isBookingPage(String path) {
        return "/customer/dat-san".equals(path) || "/customer/dat_san".equals(path);
    }

    private boolean isDeadlockException(SQLException ex) {
        // Duyệt chuỗi exception để tìm lỗi deadlock
        SQLException current = ex;
        while (current != null) {
            if (current.getErrorCode() == SQL_DEADLOCK_ERROR_CODE) {
                return true;
            }
            current = current.getNextException();
        }
        // Kiểm tra thêm thông điệp lỗi (phòng hờ JDBC driver wrap lỗi)
        return ex.getMessage() != null && ex.getMessage().toLowerCase().contains("deadlock");
    }

    /**
     * Tạm dừng ngắn trước khi retry để giảm xung đột với transaction đang chạy.
     * Thời gian dừng tăng dần: attempt=1 → 50-150ms, attempt=2 → 100-300ms, v.v.
     * Thêm thành phần ngẫu nhiên (jitter) để tránh nhiều thread retry cùng lúc.
     */
    private void sleepBeforeRetry(int attempt) {
        try {
            long baseMs = 50L * attempt;
            long jitterMs = (long) (Math.random() * 100 * attempt);
            Thread.sleep(baseMs + jitterMs);
        } catch (InterruptedException ie) {
            Thread.currentThread().interrupt(); // Khôi phục trạng thái interrupt
        }
    }
}
