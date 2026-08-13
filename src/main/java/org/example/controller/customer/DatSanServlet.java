package org.example.controller.customer;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.dao.LichDatSanDAO;
import org.example.dao.LoaiSanDAO;
import org.example.dao.SanDAO;
import org.example.dao.CustomerReputationHistoryDAO;
import org.example.dao.impl.LichDatSanDAOImpl;
import org.example.dao.impl.LoaiSanDAOImpl;
import org.example.dao.impl.SanDAOImpl;
import org.example.dao.impl.CustomerReputationHistoryDAOImpl;
import org.example.model.LoaiSan;
import org.example.model.MonTheThao;
import org.example.model.Lichdatsan;
import org.example.model.TaiKhoan;
import org.example.model.San;
import org.example.model.CustomerReputationHistory;
import org.example.util.Constants;
import org.example.util.DBUtil;
import org.example.dto.payment.PayOSCheckoutSession;
import org.example.dto.payment.PayosQrData;
import org.example.dto.payment.PayOSCredentials;
import org.example.service.PayOSConfigurationService;
import org.example.service.payos.PayOSClientFactory;
import org.example.service.pricing.CourtPriceResult;
import org.example.service.pricing.CourtPricingService;
import vn.payos.PayOS;
import vn.payos.exception.APIException;
import vn.payos.exception.ConnectionException;
import vn.payos.exception.ConnectionTimeoutException;
import vn.payos.model.v2.paymentRequests.CreatePaymentLinkRequest;
import vn.payos.model.v2.paymentRequests.CreatePaymentLinkResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
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
@WebServlet(urlPatterns = { "/customer/dat-san", "/customer/dat_san", "/customer/lich-su-dat-san", "/customer/huy-dat-san", "/customer/dat-dich-vu", "/customer/chi-tiet-san", "/customer/payos-return", "/customer/payos-cancel", "/customer/payos-status", "/customer/payos-retry", "/customer/payos-pay-counter", "/customer/api/booking-cancellation-preview", "/customer/booking-cancellation-preview" })
public class DatSanServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(DatSanServlet.class.getName());

    private static final com.google.gson.Gson gson = new com.google.gson.GsonBuilder()
            .registerTypeAdapter(java.time.LocalDate.class, (com.google.gson.JsonSerializer<java.time.LocalDate>)
                    (src, typeOfSrc, context) -> new com.google.gson.JsonPrimitive(src.toString()))
            .registerTypeAdapter(java.time.LocalTime.class, (com.google.gson.JsonSerializer<java.time.LocalTime>)
                    (src, typeOfSrc, context) -> new com.google.gson.JsonPrimitive(src.toString()))
            .registerTypeAdapter(java.time.LocalDateTime.class, (com.google.gson.JsonSerializer<java.time.LocalDateTime>)
                    (src, typeOfSrc, context) -> new com.google.gson.JsonPrimitive(src.toString()))
            .create();

    private final org.example.dao.SoftHoldDAO softHoldDAO = new org.example.dao.impl.SoftHoldDAOImpl();
    private final org.example.service.NotificationService notificationService = new org.example.service.NotificationService();

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
    private final org.example.dao.LichDatSanDichVuDAO lichDatSanDichVuDAO = new org.example.dao.impl.LichDatSanDichVuDAOImpl();
    private final CustomerReputationHistoryDAO reputationHistoryDAO = new CustomerReputationHistoryDAOImpl();
    private final CourtPricingService pricingService = new CourtPricingService();
    /** Nghiệp vụ đặt sân DÙNG CHUNG với REST API mobile — không duplicate logic ở Servlet. */
    private final org.example.service.booking.BookingCreationService bookingCreationService =
            new org.example.service.booking.BookingCreationService();
    /** Tạo/hủy payment link PayOS DÙNG CHUNG với REST API mobile. */
    private final org.example.service.payos.BookingPaymentLinkService paymentLinkService =
            new org.example.service.payos.BookingPaymentLinkService();
    /** Kiểm tra/finalize thanh toán PayOS DÙNG CHUNG với REST API mobile. */
    private final org.example.service.payos.BookingPaymentStatusService paymentStatusService =
            new org.example.service.payos.BookingPaymentStatusService();
    private final org.example.service.booking.BookingCancellationService bookingCancellationService =
            new org.example.service.booking.BookingCancellationService();
    /** Finalizer DÙNG CHUNG với PayOSWebhookServlet cho luồng đặt sân trực tiếp (orderCode=DatSanID). */
    private final org.example.service.payos.PayOSLegacyBookingFinalizationService legacyFinalizationService =
            new org.example.service.payos.PayOSLegacyBookingFinalizationService();

    // =========================================================================
    // PHẦN 1: XỬ LÝ GET - Hiển thị trang
    // =========================================================================

    /**
     * Parse chuỗi thành số nguyên dương. Trả null nếu null/rỗng/âm/không parse được.
     * Dùng chung cho mọi handler cần đọc integer từ request parameter.
     */
    private static Integer parsePositiveInt(String raw) {
        if (raw == null || raw.isBlank()) {
            return null;
        }
        try {
            int value = Integer.parseInt(raw.trim());
            return value > 0 ? value : null;
        } catch (NumberFormatException e) {
            return null;
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        String action = req.getParameter("action");
        HttpSession session = req.getSession();
        TaiKhoan user = (TaiKhoan) session.getAttribute("user");

        LOGGER.info(String.format(
            "[DatSanServlet] doGet uri=%s, path=%s, action=%s, datSanId=%s, query=%s",
            req.getRequestURI(), path, action,
            req.getParameter("datSanId"),
            req.getQueryString()));

        // ── Cancellation preview – xử lý trước tất cả, return ngay (ĐÃ VÔ HIỆU HÓA) ──
        // if (path.contains("booking-cancellation-preview")
        //         || ("preview".equals(action) && "/customer/huy-dat-san".equals(path))) {
        //     LOGGER.info("[DatSanServlet] → handleCancellationPreview (Disabled)");
        //     // handleCancellationPreview(req, resp, user);
        //     // return;
        // }

        // Khách chưa đăng nhập vẫn được xem trang đặt sân để khám phá,
        // nhưng không thể submit form (nút sẽ chuyển thành "Đăng nhập")
        // Chỉ chặn những trang yêu cầu đăng nhập bắt buộc
        if (user == null && !isBookingPage(path)) {
            resp.sendRedirect(org.example.util.RoleRedirectUtil.buildLoginRedirect(req.getContextPath(), req.getRequestURI() + (req.getQueryString() != null ? "?" + req.getQueryString() : "")));
            return;
        }

        if (path.equals("/customer/chi-tiet-san")) {
            handleGetChiTietSan(req, resp);
        } else if (isBookingPage(path)) {
            resp.sendRedirect(req.getContextPath() + "/customer/tim-kiem");
        } else if (path.equals("/customer/lich-su-dat-san")) {
            if (user == null) {
                resp.sendRedirect(org.example.util.RoleRedirectUtil.buildLoginRedirect(req.getContextPath(), req.getRequestURI() + (req.getQueryString() != null ? "?" + req.getQueryString() : "")));
                return;
            }
            loadHistoryPage(req, resp, user);
        } else if (path.equals("/customer/dat-dich-vu")) {
            handleGetDichVu(req, resp, user);
        } else if (path.equals("/customer/payos-return")) {
            handlePayOSReturn(req, resp, session);
        } else if (path.equals("/customer/payos-cancel")) {
            handlePayOSCancel(req, resp, session, user);
        } else if (path.equals("/customer/payos-status")) {
            handlePayOSStatus(req, resp, user);
        }
    }

    /**
     * Tải dữ liệu và chuyển tiếp đến trang DatSan.jsp.
     * Load: danh sách sân, Cơ Sở, môn thể thao, loại sân, lịch đặt hiện tại.
     */
    private void loadBookingPage(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        long t0 = System.currentTimeMillis();

        List<org.example.model.CoSo> dsCoSo = coSoDAO.getAllCoSo();
        List<San> dsSan = new java.util.ArrayList<>();
        List<MonTheThao> dsMon = new java.util.ArrayList<>();
        List<LoaiSan> dsLoai = new java.util.ArrayList<>();

        try {
            long tSan0 = System.currentTimeMillis();
            dsSan = sanDAO.getAllSan();
            dsMon = loaiSanDAO.getAllMonTheThao();
            dsLoai = loaiSanDAO.getAllLoaiSan();
            LOGGER.info(String.format("loadBookingPage: tải danh sách sân/loại=%dms, count=%d", System.currentTimeMillis() - tSan0, dsSan.size()));
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Lỗi khi tải dữ liệu trang đặt sân", e);
        }

        // Lấy toàn bộ lịch đặt hiện tại để hiển thị timetable xung đột trên frontend
        long tAll0 = System.currentTimeMillis();
        List<Lichdatsan> activeBookings = lichDatSanDAO.getAllLichDatSan();
        LOGGER.info(String.format("loadBookingPage: getAllLichDatSan=%dms, count=%d",
                System.currentTimeMillis() - tAll0, activeBookings != null ? activeBookings.size() : 0));
        if (activeBookings != null) {
            activeBookings.removeIf(b -> "Chờ thanh toán".equals(b.getTrangThai()) &&
                    b.getCreatedTime() != null &&
                    b.getCreatedTime().plusMinutes(org.example.util.Constants.PENDING_PAYMENT_TIMEOUT_MINUTES).isBefore(LocalDateTime.now()));
        }

        // Lấy lịch sử đặt sân của cá nhân khách hàng nếu đã đăng nhập
        HttpSession session = req.getSession();
        TaiKhoan user = (TaiKhoan) session.getAttribute("user");
        if (user != null) {
            try {
                long tUser0 = System.currentTimeMillis();
                List<Lichdatsan> dsLich = lichDatSanDAO.getLichByAccountId(user.getAccountId());
                LOGGER.info(String.format("loadBookingPage: getLichByAccountId(accountId=%d)=%dms, count=%d",
                        user.getAccountId(), System.currentTimeMillis() - tUser0, dsLich != null ? dsLich.size() : 0));
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

        LOGGER.info(String.format("loadBookingPage: tổng=%dms", System.currentTimeMillis() - t0));
        req.getRequestDispatcher("/customer/DatSan.jsp").forward(req, resp);
    }

    /**
     * Tải lịch sử đặt sân cá nhân và chuyển tiếp đến GioHang.jsp.
     */
    private void loadHistoryPage(HttpServletRequest req, HttpServletResponse resp, TaiKhoan user)
            throws ServletException, IOException {
        List<Lichdatsan> dsLich = lichDatSanDAO.getLichByAccountId(user.getAccountId());

        // Lấy tên sân và Cơ Sở để hiển thị đẹp hơn trong bảng lịch sử
        List<San> dsSan = sanDAO.getAllSan();
        List<org.example.model.CoSo> dsCoSo = coSoDAO.getAllCoSo();

        // Với mỗi booking đã hủy/không đến, tìm bản ghi lịch sử uy tín liên quan gần nhất
        // (LATE_CANCEL/NO_SHOW/EARLY_CANCEL) để hiển thị rõ tác động uy tín cho khách hàng.
        Map<Integer, CustomerReputationHistory> reputationByDatSanId = new HashMap<>();
        for (CustomerReputationHistory h : reputationHistoryDAO.getByAccountId(user.getAccountId())) {
            if (h.getDatSanId() == null) {
                continue;
            }
            if (!Constants.REPUTATION_ACTION_LATE_CANCEL.equals(h.getActionType())
                    && !Constants.REPUTATION_ACTION_NO_SHOW.equals(h.getActionType())
                    && !Constants.REPUTATION_ACTION_EARLY_CANCEL.equals(h.getActionType())) {
                continue;
            }
            // getByAccountId() trả về mới nhất trước; giữ bản ghi đầu tiên gặp cho mỗi DatSanID.
            reputationByDatSanId.putIfAbsent(h.getDatSanId(), h);
        }

        List<Lichdatsan> cartItems = new ArrayList<>();
        if (dsLich != null) {
            for (Lichdatsan l : dsLich) {
                if ("Chờ xác nhận".equals(l.getTrangThai()) || "Chờ thanh toán".equals(l.getTrangThai())) {
                    cartItems.add(l);
                }
            }
        }

        org.example.dao.HoanTienDAO hoanTienDAO = new org.example.dao.impl.HoanTienDAOImpl();
        Map<Integer, org.example.model.Hoantien> mapHoanTien = hoanTienDAO.findActiveMapByAccountId(user.getAccountId());

        org.example.service.RefundService refundService = new org.example.service.RefundService();
        java.util.List<org.example.model.Hoantien> danhSachHoanTien = refundService.getByCustomer(user.getAccountId(), 1);

        req.setAttribute("dsLich", dsLich);
        req.setAttribute("cartItems", cartItems);
        req.setAttribute("dsSan", dsSan);
        req.setAttribute("dsCoSo", dsCoSo);
        req.setAttribute("reputationByDatSanId", reputationByDatSanId);
        req.setAttribute("mapHoanTien", mapHoanTien);
        req.setAttribute("danhSachHoanTien", danhSachHoanTien);
        req.getRequestDispatcher("/customer/GioHang.jsp").forward(req, resp);
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
            resp.sendRedirect(org.example.util.RoleRedirectUtil.buildLoginRedirect(req.getContextPath(), req.getRequestURI() + (req.getQueryString() != null ? "?" + req.getQueryString() : "")));
            return;
        }

        if (path.equals("/customer/dat-san")) {
            handleDatSan(req, resp, session, user);
        } else if (path.equals("/customer/huy-dat-san")) {
            // Đã chuyển sang luồng RefundCancelServlet
            // handleHuyDatSan(req, resp, session, user);
            resp.sendError(HttpServletResponse.SC_GONE, "This endpoint is deprecated.");
        } else if (path.equals("/customer/dat-dich-vu")) {
            handlePostDatDichVu(req, resp, session, user);
        } else if (path.equals("/customer/payos-retry")) {
            handlePayOSRetry(req, resp, user);
        } else if (path.equals("/customer/payos-pay-counter")) {
            handlePayOSPayCounter(req, resp, user);
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
        long tSubmit0 = System.currentTimeMillis();

        // --- Bước 1: Parse input (controller CHỈ parse; mọi nghiệp vụ nằm ở BookingCreationService) ---
        org.example.service.booking.BookingCreationService.Command cmd =
                new org.example.service.booking.BookingCreationService.Command();
        cmd.nguonDatSan = "Web";
        String paymentMethod;

        try {
            String pSanId = req.getParameter("sanId");
            String pNgayDat = req.getParameter("ngayDat");
            String pGioBatDau = req.getParameter("gioBatDau");
            String pGioKetThuc = req.getParameter("gioKetThuc");

            String missingParam = null;
            if (pSanId == null || pSanId.trim().isEmpty()) {
                missingParam = "sanId";
            } else if (pNgayDat == null || pNgayDat.trim().isEmpty()) {
                missingParam = "ngayDat";
            } else if (pGioBatDau == null || pGioBatDau.trim().isEmpty()) {
                missingParam = "gioBatDau";
            } else if (pGioKetThuc == null || pGioKetThuc.trim().isEmpty()) {
                missingParam = "gioKetThuc";
            }
            if (missingParam != null) {
                LOGGER.log(Level.WARNING, "Thiếu tham số đặt sân bắt buộc: {0}", missingParam);
                session.setAttribute("error", "Thiếu thông tin đặt sân. Vui lòng chọn lại sân, ngày và khung giờ.");
                resp.sendRedirect(req.getContextPath() + "/customer/dat-san");
                return;
            }

            cmd.sanId = Integer.parseInt(pSanId);
            cmd.ngayDat = LocalDate.parse(pNgayDat);
            cmd.gioBatDau = LocalTime.parse(pGioBatDau);
            cmd.gioKetThuc = LocalTime.parse(pGioKetThuc);
            cmd.ghiChu = req.getParameter("ghiChu");
            paymentMethod = req.getParameter("paymentMethod");
            if (paymentMethod == null || paymentMethod.trim().isEmpty()) {
                paymentMethod = "sau";
            }

            String[] serviceIdParams = req.getParameterValues("serviceId");
            String[] serviceQtyParams = req.getParameterValues("serviceQty");
            if (serviceIdParams != null && serviceQtyParams != null && serviceIdParams.length == serviceQtyParams.length) {
                int[] serviceIds = new int[serviceIdParams.length];
                int[] serviceQtys = new int[serviceQtyParams.length];
                for (int i = 0; i < serviceIdParams.length; i++) {
                    serviceIds[i] = Integer.parseInt(serviceIdParams[i].trim());
                    serviceQtys[i] = Integer.parseInt(serviceQtyParams[i].trim());
                }
                cmd.serviceIds = serviceIds;
                cmd.serviceQtys = serviceQtys;
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Dữ liệu đặt sân không hợp lệ", e);
            session.setAttribute("error", "Dữ liệu không hợp lệ. Vui lòng kiểm tra lại thông tin.");
            resp.sendRedirect(req.getContextPath() + "/customer/dat-san");
            return;
        }

        // Validate paymentMethod enum value
        if (!"payos".equalsIgnoreCase(paymentMethod) && !"sau".equalsIgnoreCase(paymentMethod)) {
            session.setAttribute("error", "Phương thức thanh toán không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/customer/dat-san");
            return;
        }
        cmd.onlinePayment = "payos".equalsIgnoreCase(paymentMethod);

        // --- Bước 2: Toàn bộ validate nghiệp vụ + transaction đặt sân nằm trong Service dùng chung
        //             với REST API mobile (không duplicate logic ở Servlet). ---
        org.example.service.booking.BookingCreationService.Result result =
                bookingCreationService.create(user, cmd);

        if (!result.success) {
            session.setAttribute("error", result.message);
            resp.sendRedirect(req.getContextPath() + "/customer/dat-san");
            return;
        }

        int newDatSanId = result.datSanId;
        int sanCoSoID = result.coSoId;
        boolean isOnlineDeposit = cmd.onlinePayment;
        double tongTien = result.tongTien.doubleValue();

        LOGGER.info(String.format("NOTIFICATION_EVENT event=BOOKING_CREATED accountId=%d datSanId=%d status=%s",
                user.getAccountId(), newDatSanId, result.trangThai));

        // Gửi thông báo sau commit — không để lỗi notification làm gãy luồng
        try {
            notificationService.notifyBookingCreated(user.getAccountId(), newDatSanId, isOnlineDeposit);
        } catch (Exception _ne) {
            LOGGER.warning("notifyBookingCreated failed for datSanId=" + newDatSanId + ": " + _ne.getMessage());
        }

        // Thông báo cho Manager/Staff của cơ sở
        try {
            String thoiGianStr = cmd.gioBatDau + "-" + cmd.gioKetThuc;
            notificationService.notifyManagerStaffNewBooking(sanCoSoID, newDatSanId,
                    user.getFullName(), null, thoiGianStr);
        } catch (Exception _ne) {
            LOGGER.warning("notifyManagerStaffNewBooking failed for datSanId=" + newDatSanId + ": " + _ne.getMessage());
        }

        LOGGER.info(String.format(
                "Đặt sân thành công: AccountID=%d, SanID=%d, Ngày=%s, %s-%s, Tiền=%,.0fđ, PTTT=%s, tổng submit=%dms",
                user.getAccountId(), cmd.sanId, cmd.ngayDat, cmd.gioBatDau, cmd.gioKetThuc, tongTien,
                paymentMethod, System.currentTimeMillis() - tSubmit0));

        boolean isAjax = "XMLHttpRequest".equals(req.getHeader("X-Requested-With"));

        if (!isOnlineDeposit) {
            session.setAttribute("message",
                    "Đặt sân thành công! Sân đã được thêm vào giỏ hàng. Vui lòng chờ cơ sở xác nhận.");
            resp.sendRedirect(req.getContextPath() + "/customer/gio-hang");
            return;
        }

        // ── PayOS: tạo QR hoặc redirect tùy request type ──
        String baseUrl = resolveBaseUrl(req);
        String returnUrl = baseUrl + "/customer/payos-return?datSanId=" + newDatSanId;
        String cancelUrl = baseUrl + "/customer/payos-cancel?datSanId=" + newDatSanId;
        long amount = result.tongTien.setScale(0, java.math.RoundingMode.HALF_UP).longValue();
        // description tối đa 25 ký tự theo giới hạn PayOS
        String description = "VSport DS" + newDatSanId;

        long tPayOS0 = System.currentTimeMillis();
        org.example.service.payos.BookingPaymentLinkService.LinkResult linkResult =
                paymentLinkService.createLink(sanCoSoID, newDatSanId, amount, description, returnUrl, cancelUrl, false);
        LOGGER.info(String.format("handleDatSan: PayOS createPaymentLink=%dms, success=%b%s",
                System.currentTimeMillis() - tPayOS0, linkResult.success,
                linkResult.success ? "" : ", errorCode=" + linkResult.errorCode));

        if (linkResult.success) {
            // Lưu QR (session + best-effort DB cache) để trang QR nhúng render lại được
            // khi reload/đa tab, KHÔNG gọi lại PayOS. KHÔNG redirect sang checkout PayOS.
            paymentLinkService.persistQr(session, newDatSanId, linkResult.session, amount, description);
            String qrPageUrl = req.getContextPath() + "/customer/thanh-toan-qr?datSanId=" + newDatSanId;
            if (isAjax) {
                resp.setContentType("application/json; charset=UTF-8");
                resp.getWriter().write(String.format(
                        "{\"success\":true,\"datSanId\":%d,\"redirectUrl\":\"%s\"}",
                        newDatSanId, jsonEscape(qrPageUrl)));
            } else {
                resp.sendRedirect(qrPageUrl);
            }
        } else {
            // KHÔNG hủy booking: giữ nguyên "Chờ thanh toán" + HoldExpiresAt hiện có để
            // khách bấm "Thử lại" (/customer/payos-retry) hoặc "Thanh toán tại quầy"
            // (/customer/payos-pay-counter) trên CÙNG đơn — không tạo booking mới.
            if (isAjax) {
                resp.setContentType("application/json; charset=UTF-8");
                resp.getWriter().write(String.format(
                        "{\"success\":false,\"errorCode\":\"%s\",\"message\":\"%s\",\"datSanId\":%d,\"retryable\":%b,\"fallbackAvailable\":true}",
                        linkResult.errorCode, jsonEscape(linkResult.message), newDatSanId, linkResult.retryable));
            } else {
                session.setAttribute("error", linkResult.message);
                session.setAttribute("errorCode", linkResult.errorCode);
                session.setAttribute("errorDatSanId", newDatSanId);
                session.setAttribute("errorRetryable", linkResult.retryable);
                resp.sendRedirect(req.getContextPath() + "/customer/dat-san");
            }
        }
    }

    // =========================================================================
    // PHẦN 4: LOGIC HỦY ĐẶT SÂN
    // =========================================================================

    private void handleCancellationPreview(HttpServletRequest req, HttpServletResponse resp, TaiKhoan user) throws IOException {
        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");
        resp.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");

        if (user == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            java.util.Map<String, Object> payload = new java.util.LinkedHashMap<>();
            payload.put("success", false);
            payload.put("code", "UNAUTHENTICATED");
            payload.put("message", "Phiên đăng nhập đã hết hạn.");
            gson.toJson(payload, resp.getWriter());
            return;
        }

        String datSanIdStr = req.getParameter("datSanId");
        if (datSanIdStr == null || datSanIdStr.isBlank()) {
            datSanIdStr = req.getParameter("id");
        }

        if (datSanIdStr == null || datSanIdStr.isBlank()) {
            LOGGER.warning(String.format("[cancellation-preview] Missing datSanId parameter for accountId=%d, uri=%s",
                    user.getAccountId(), req.getRequestURI()));
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            java.util.Map<String, Object> payload = new java.util.LinkedHashMap<>();
            payload.put("success", false);
            payload.put("code", "MISSING_DAT_SAN_ID");
            payload.put("message", "Thiếu mã đặt sân datSanId.");
            gson.toJson(payload, resp.getWriter());
            return;
        }

        try {
            int datSanId = Integer.parseInt(datSanIdStr.trim());
            LOGGER.info(String.format("[cancellation-preview] request accountId=%d, datSanId=%d, uri=%s",
                    user.getAccountId(), datSanId, req.getRequestURI()));

            org.example.service.booking.BookingCancellationService.CancellationPreview preview =
                    bookingCancellationService.calculatePreview(datSanId, user.getAccountId());

            // Always return HTTP 200 OK for API logic responses to prevent Tomcat ErrorReportValve
            // from intercepting 4xx/5xx status codes and generating HTML error pages.
            resp.setStatus(HttpServletResponse.SC_OK);

            if (preview.success) {
                LOGGER.info(String.format("[cancellation-preview] success accountId=%d, datSanId=%d, paid=%b, refundEligible=%b",
                        user.getAccountId(), datSanId, preview.paid, preview.refundEligible));
            }

            gson.toJson(preview, resp.getWriter());
            resp.getWriter().flush();
        } catch (NumberFormatException e) {
            LOGGER.warning(String.format("[cancellation-preview] Invalid datSanId '%s' for accountId=%d",
                    datSanIdStr, user.getAccountId()));
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            java.util.Map<String, Object> payload = new java.util.LinkedHashMap<>();
            payload.put("success", false);
            payload.put("code", "INVALID_DAT_SAN_ID");
            payload.put("message", "Mã đặt sân không hợp lệ.");
            gson.toJson(payload, resp.getWriter());
        } catch (Exception e) {
            LOGGER.log(java.util.logging.Level.SEVERE, String.format("[cancellation-preview] failed accountId=%d, datSanId=%s",
                    user.getAccountId(), datSanIdStr), e);
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            java.util.Map<String, Object> payload = new java.util.LinkedHashMap<>();
            payload.put("success", false);
            payload.put("code", "CANCELLATION_PREVIEW_ERROR");
            payload.put("message", "Không thể kiểm tra điều kiện hủy sân: " + e.getMessage());
            gson.toJson(payload, resp.getWriter());
        }
    }

    /**
     * Xử lý hủy lịch đặt sân.
     */
    private void handleHuyDatSan(HttpServletRequest req, HttpServletResponse resp,
            HttpSession session, TaiKhoan user) throws IOException {
        String idStr = req.getParameter("id");
        if (idStr == null || idStr.isBlank()) {
            idStr = req.getParameter("datSanId");
        }
        LOGGER.info(String.format("[huy-dat-san] request nhận: servletPath=%s, pathInfo=%s, accountId=%d, rawId=%s",
                req.getServletPath(), req.getPathInfo(), user.getAccountId(), idStr));

        org.example.service.booking.BookingCancellationService.CancelResult result = null;
        try {
            if (idStr == null || idStr.isBlank()) {
                throw new NumberFormatException("Missing booking ID parameter 'id' or 'datSanId'");
            }
            int id = Integer.parseInt(idStr.trim());
            String reason = req.getParameter("reason");

            result = bookingCancellationService.cancelByCustomer(id, user.getAccountId(), reason, req, user);
        } catch (NumberFormatException e) {
            result = org.example.service.booking.BookingCancellationService.CancelResult.fail("Yêu cầu không hợp lệ.");
        }

        boolean isAjax = "XMLHttpRequest".equalsIgnoreCase(req.getHeader("X-Requested-With"))
                || (req.getHeader("Accept") != null && req.getHeader("Accept").contains("application/json"))
                || "true".equalsIgnoreCase(req.getParameter("ajax"));

        if (isAjax) {
            resp.setContentType("application/json; charset=UTF-8");
            com.google.gson.JsonObject json = new com.google.gson.JsonObject();
            json.addProperty("success", result.success);
            json.addProperty("message", result.message);
            json.addProperty("createdHoanTienId", result.createdHoanTienId != null ? result.createdHoanTienId : 0);
            if (result.createdHoanTienId != null && result.createdHoanTienId > 0) {
                json.addProperty("redirectUrl", req.getContextPath() + "/customer/hoan-tien?id=" + result.createdHoanTienId);
            } else {
                json.addProperty("redirectUrl", req.getContextPath() + "/customer/gio-hang");
            }
            resp.getWriter().write(json.toString());
            return;
        }

        if (result.success) {
            session.setAttribute("message", result.message);
            if (result.createdHoanTienId != null && result.createdHoanTienId > 0) {
                resp.sendRedirect(req.getContextPath() + "/customer/hoan-tien?id=" + result.createdHoanTienId);
                return;
            }
        } else {
            session.setAttribute("error", result.message);
        }

        resp.sendRedirect(req.getContextPath() + "/customer/gio-hang");
    }

    // =========================================================================
    // PHẦN 5: PAYOS RETURN / CANCEL
    // =========================================================================

    /**
     * Kiểm tra trạng thái thanh toán PayOS cho một booking (luồng legacy: orderCode = DatSanID).
     *
     * Webhook PayOS KHÔNG thể tới được môi trường localhost (không có public URL đăng ký với
     * PayOS) — nếu chỉ đọc LichDatSan.TrangThai từ DB, trạng thái sẽ mãi mãi "Chờ thanh toán"
     * dù Customer đã chuyển khoản thật, vì không có gì cập nhật DB cả (root cause đã xác nhận
     * qua log: 88 lượt gọi endpoint này cho cùng DatSanID đều trả "pending" giống hệt nhau,
     * 0 request nào tới /payos/webhook trong log truy cập).
     *
     * Vì vậy endpoint này PHẢI tự query PayOS server-to-server bằng orderCode khi DB còn pending,
     * rồi gọi CHUNG một finalizer với webhook (PayOSLegacyBookingFinalizationService) — không tạo
     * finalizer thứ hai, không tự đánh dấu PAID chỉ vì Customer bấm nút.
     */
    private void handlePayOSStatus(HttpServletRequest req, HttpServletResponse resp,
            TaiKhoan user) throws IOException {
        resp.setContentType("application/json; charset=UTF-8");
        if (user == null) {
            resp.getWriter().write("{\"success\":false,\"status\":\"error\",\"error\":\"Chưa đăng nhập\"}");
            return;
        }
        Integer datSanId = parseIntParam(req.getParameter("datSanId"));
        if (datSanId == null) {
            resp.getWriter().write("{\"success\":false,\"status\":\"error\",\"error\":\"Thiếu datSanId\"}");
            return;
        }

        // Toàn bộ nghiệp vụ kiểm tra/finalize nằm trong Service dùng chung với REST API mobile.
        org.example.service.payos.BookingPaymentStatusService.Status status =
                paymentStatusService.check(datSanId, user.getAccountId());

        if (status.isNotFound()) {
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            resp.getWriter().write("{\"success\":false,\"status\":\"error\",\"error\":\"Không tìm thấy đơn\"}");
            return;
        }

        String redirectUrl = status.paid ? req.getContextPath() + "/customer/gio-hang" : null;
        writePayOSStatusJson(resp, true, status.status, status.bookingStatus,
                status.remainingSeconds, redirectUrl, status.message);
    }

    private void writePayOSStatusJson(HttpServletResponse resp, boolean success, String status,
            String bookingStatus, long remainingSeconds, String redirectUrl, String message) throws IOException {
        boolean paid = "paid".equals(status);
        StringBuilder json = new StringBuilder();
        json.append("{\"success\":").append(success)
            .append(",\"paid\":").append(paid)
            .append(",\"status\":\"").append(status).append("\"")
            .append(",\"bookingStatus\":\"").append(jsonEscape(bookingStatus != null ? bookingStatus : "")).append("\"")
            .append(",\"remainingSeconds\":").append(remainingSeconds);
        json.append(",\"redirectUrl\":").append(redirectUrl != null ? "\"" + jsonEscape(redirectUrl) + "\"" : "null");
        json.append(",\"message\":\"").append(jsonEscape(message != null ? message : "")).append("\"");
        json.append("}");
        resp.getWriter().write(json.toString());
    }

    private void handlePayOSReturn(HttpServletRequest req, HttpServletResponse resp,
            HttpSession session) throws IOException {
        session.setAttribute("message",
                "Hệ thống đang kiểm tra thanh toán. Vui lòng chờ xác nhận.");
        resp.sendRedirect(req.getContextPath() + "/customer/gio-hang");
    }

    private void handlePayOSCancel(HttpServletRequest req, HttpServletResponse resp,
            HttpSession session, TaiKhoan user) throws IOException {
        Integer datSanId = parseIntParam(req.getParameter("datSanId"));
        if (datSanId == null) datSanId = parseIntParam(req.getParameter("orderCode"));
        if (datSanId == null) {
            resp.sendRedirect(req.getContextPath() + "/customer/gio-hang");
            return;
        }

        boolean cancelled = false;
        try (java.sql.Connection conn = org.example.util.DBUtil.getConnection()) {
            // Kiểm tra quyền sở hữu + trạng thái TRƯỚC khi hủy (không cho đoán DatSanID của người khác).
            int ownerAccountId = -1, coSoId = -1; String trangThai = null;
            String checkSql = "SELECT l.account_id, l.status, s.facility_id FROM bookings l " +
                    "JOIN courts s ON s.court_id = l.court_id WHERE l.booking_id = ?";
            try (java.sql.PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setInt(1, datSanId);
                try (java.sql.ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        ownerAccountId = rs.getInt("account_id");
                        trangThai = rs.getString("status");
                        coSoId = rs.getInt("facility_id");
                    }
                }
            }

            if (trangThai == null || ownerAccountId != user.getAccountId()) {
                session.setAttribute("error", "Không tìm thấy đơn đặt sân của bạn.");
                resp.sendRedirect(req.getContextPath() + "/customer/gio-hang");
                return;
            }

            if (Constants.TRANG_THAI_DAT_SAN_CHO_THANH_TOAN.equals(trangThai)) {
                // Hủy link PayOS còn treo (best-effort) rồi giải phóng slot + đánh dấu hủy trong 1 UPDATE.
                cancelPayosLinkQuietly(coSoId, datSanId);
                String sql = "UPDATE bookings SET status = N'" + Constants.TRANG_THAI_DAT_SAN_DA_HUY + "', " +
                        "hold_expires_at = NULL, " +
                        "note = CONCAT(ISNULL(note, N''), N' [Người dùng hủy thanh toán PayOS]') " +
                        "WHERE booking_id = ? AND status = N'" + Constants.TRANG_THAI_DAT_SAN_CHO_THANH_TOAN + "'";
                try (java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, datSanId);
                    cancelled = ps.executeUpdate() == 1;
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Lỗi khi hủy booking PayOS DatSanID=" + datSanId, e);
        }

        session.removeAttribute(PayosQrData.sessionKey(datSanId));
        session.setAttribute("message", cancelled
                ? "Bạn đã hủy thanh toán. Khung giờ đã được giải phóng."
                : "Đơn không còn ở trạng thái có thể hủy.");
        resp.sendRedirect(req.getContextPath() + "/customer/gio-hang");
    }

    /** Hủy payment link PayOS (best-effort) cho một booking; không ném lỗi ra ngoài. */
    private void cancelPayosLinkQuietly(int coSoId, long datSanId) {
        paymentLinkService.cancelLinkQuietly(coSoId, datSanId, "Khách hủy thanh toán");
    }

    // =========================================================================
    // PHẦN 5B: PAYOS RETRY / CHUYỂN THANH TOÁN TẠI QUẦY (không tạo booking mới)
    // =========================================================================

    /**
     * "Thử lại" sau khi tạo link PayOS lần đầu thất bại. Dùng lại ĐÚNG booking đang "Chờ thanh
     * toán" (không insert booking mới), tính lại amount từ DB (không tin frontend), hủy link cũ
     * (nếu có) rồi tạo link mới với cùng orderCode=DatSanID. Idempotent: bấm nhiều lần chỉ tạo
     * một link còn hiệu lực tại một thời điểm.
     */
    private void handlePayOSRetry(HttpServletRequest req, HttpServletResponse resp, TaiKhoan user) throws IOException {
        resp.setContentType("application/json; charset=UTF-8");
        Integer datSanId = parseIntParam(req.getParameter("datSanId"));
        if (datSanId == null) {
            resp.getWriter().write("{\"success\":false,\"errorCode\":\"VALIDATION_ERROR\",\"message\":\"Thiếu datSanId.\"}");
            return;
        }

        try (java.sql.Connection conn = org.example.util.DBUtil.getConnection()) {
            String sql = "SELECT l.account_id, l.status, l.estimated_total, l.hold_expires_at, s.facility_id " +
                    "FROM bookings l JOIN courts s ON s.court_id = l.court_id WHERE l.booking_id = ?";
            int accountId, coSoId; String trangThai; java.math.BigDecimal amountDb; java.sql.Timestamp holdExpiresAt;
            try (java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, datSanId);
                try (java.sql.ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        resp.getWriter().write("{\"success\":false,\"errorCode\":\"NOT_FOUND\",\"message\":\"Không tìm thấy đơn đặt sân.\"}");
                        return;
                    }
                    accountId = rs.getInt("account_id");
                    trangThai = rs.getString("status");
                    amountDb = rs.getBigDecimal("estimated_total");
                    holdExpiresAt = rs.getTimestamp("hold_expires_at");
                    coSoId = rs.getInt("facility_id");
                }
            }
            if (accountId != user.getAccountId()) {
                resp.getWriter().write("{\"success\":false,\"errorCode\":\"FORBIDDEN\",\"message\":\"Đơn đặt sân không thuộc về bạn.\"}");
                return;
            }
            if (!Constants.TRANG_THAI_DAT_SAN_CHO_THANH_TOAN.equals(trangThai)) {
                resp.getWriter().write("{\"success\":false,\"errorCode\":\"PAYMENT_CONFLICT\",\"message\":\"Đơn không còn ở trạng thái chờ thanh toán. Vui lòng tải lại trang.\"}");
                return;
            }
            // holdExpiresAt (Timestamp) lưu UTC → so sánh bằng Instant UTC (TimeUtil.fromDb), không dùng giờ JVM.
            java.time.Instant holdInstant = org.example.util.TimeUtil.fromDb(holdExpiresAt);
            if (holdInstant == null || holdInstant.isBefore(java.time.Instant.now())) {
                resp.getWriter().write(String.format(
                        "{\"success\":false,\"errorCode\":\"HOLD_EXPIRED\",\"message\":\"%s\"}", jsonEscape(org.example.service.payos.BookingPaymentLinkService.MSG_EXPIRED)));
                return;
            }

            long amount = amountDb.setScale(0, java.math.RoundingMode.HALF_UP).longValue();
            String description = "VSport DS" + datSanId;
            String baseUrl = resolveBaseUrl(req);
            String returnUrl = baseUrl + "/customer/payos-return?datSanId=" + datSanId;
            String cancelUrl = baseUrl + "/customer/payos-cancel?datSanId=" + datSanId;

            org.example.service.payos.BookingPaymentLinkService.LinkResult linkResult =
                    paymentLinkService.createLink(coSoId, datSanId, amount, description, returnUrl, cancelUrl, true);
            if (linkResult.success) {
                PayOSCheckoutSession s = linkResult.session;
                // Cập nhật cache QR mới (session + DB) rồi để frontend nạp lại trang QR nhúng.
                paymentLinkService.persistQr(req.getSession(), datSanId, s, amount, description);
                String qrPageUrl = req.getContextPath() + "/customer/thanh-toan-qr?datSanId=" + datSanId;
                resp.getWriter().write(String.format(
                        "{\"success\":true,\"datSanId\":%d,\"redirectUrl\":\"%s\"}",
                        datSanId, jsonEscape(qrPageUrl)));
            } else {
                resp.getWriter().write(String.format(
                        "{\"success\":false,\"errorCode\":\"%s\",\"message\":\"%s\",\"retryable\":%b}",
                        linkResult.errorCode, jsonEscape(linkResult.message), linkResult.retryable));
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi khi thử lại PayOS DatSanID=" + datSanId, e);
            resp.getWriter().write("{\"success\":false,\"errorCode\":\"INTERNAL_ERROR\",\"message\":\"Có lỗi xảy ra. Vui lòng thử lại.\"}");
        }
    }

    /**
     * Chuyển một booking đang "Chờ thanh toán" (giữ chỗ chờ PayOS) sang thanh toán tại quầy:
     * hủy link PayOS còn treo (best-effort) rồi đổi TrangThai -> "Chờ xác nhận" (đúng trạng thái
     * ban đầu của luồng thanh toán sau/tại quầy), xóa HoldExpiresAt. Không tạo booking mới.
     */
    private void handlePayOSPayCounter(HttpServletRequest req, HttpServletResponse resp, TaiKhoan user) throws IOException {
        resp.setContentType("application/json; charset=UTF-8");
        Integer datSanId = parseIntParam(req.getParameter("datSanId"));
        if (datSanId == null) {
            resp.getWriter().write("{\"success\":false,\"errorCode\":\"VALIDATION_ERROR\",\"message\":\"Thiếu datSanId.\"}");
            return;
        }

        try (java.sql.Connection conn = org.example.util.DBUtil.getConnection()) {
            String sql = "SELECT l.account_id, l.status, s.facility_id FROM bookings l JOIN courts s ON s.court_id = l.court_id WHERE l.booking_id = ?";
            int accountId, coSoId; String trangThai;
            try (java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, datSanId);
                try (java.sql.ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        resp.getWriter().write("{\"success\":false,\"errorCode\":\"NOT_FOUND\",\"message\":\"Không tìm thấy đơn đặt sân.\"}");
                        return;
                    }
                    accountId = rs.getInt("account_id");
                    trangThai = rs.getString("status");
                    coSoId = rs.getInt("facility_id");
                }
            }
            if (accountId != user.getAccountId()) {
                resp.getWriter().write("{\"success\":false,\"errorCode\":\"FORBIDDEN\",\"message\":\"Đơn đặt sân không thuộc về bạn.\"}");
                return;
            }
            if (!Constants.TRANG_THAI_DAT_SAN_CHO_THANH_TOAN.equals(trangThai)) {
                resp.getWriter().write("{\"success\":false,\"errorCode\":\"PAYMENT_CONFLICT\",\"message\":\"Đơn không còn ở trạng thái chờ thanh toán. Vui lòng tải lại trang.\"}");
                return;
            }

            PayOSCredentials credentials = new PayOSConfigurationService().getCredentialsForPayment(coSoId);
            if (credentials != null) {
                PayOS client = PayOSClientFactory.create(credentials);
                try {
                    client.paymentRequests().cancel((long) datSanId, "Khách chuyển sang thanh toán tại quầy");
                } catch (Exception ignoredNoExistingLink) {
                    // Không có link đang treo (chưa từng tạo được) - bỏ qua.
                } finally {
                    client.close();
                }
            }

            String updateSql = "UPDATE bookings SET status = N'" + Constants.TRANG_THAI_DAT_SAN_CHO_XAC_NHAN +
                    "', hold_expires_at = NULL, note = ISNULL(note, N'') + N' [Khách chuyển sang thanh toán tại quầy]' " +
                    "WHERE booking_id = ? AND status = N'" + Constants.TRANG_THAI_DAT_SAN_CHO_THANH_TOAN + "'";
            try (java.sql.PreparedStatement up = conn.prepareStatement(updateSql)) {
                up.setInt(1, datSanId);
                int updated = up.executeUpdate();
                if (updated != 1) {
                    resp.getWriter().write("{\"success\":false,\"errorCode\":\"PAYMENT_CONFLICT\",\"message\":\"Đơn đã được xử lý bởi thao tác khác. Vui lòng tải lại trang.\"}");
                    return;
                }
            }
            LOGGER.info(String.format("PAYOS_SWITCH_TO_COUNTER datSanId=%d facilityId=%d accountId=%d", datSanId, coSoId, user.getAccountId()));
            resp.getWriter().write("{\"success\":true,\"message\":\"Đã chuyển sang thanh toán tại quầy. Vui lòng đến sớm 15 phút để làm thủ tục nhận sân.\"}");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi khi chuyển thanh toán tại quầy DatSanID=" + datSanId, e);
            resp.getWriter().write("{\"success\":false,\"errorCode\":\"INTERNAL_ERROR\",\"message\":\"Có lỗi xảy ra. Vui lòng thử lại.\"}");
        }
    }

    private String resolveBaseUrl(HttpServletRequest req) {
        String scheme = req.getScheme();
        String serverName = req.getServerName();
        int port = req.getServerPort();
        String ctx = req.getContextPath();
        boolean defaultPort = (scheme.equals("http") && port == 80) || (scheme.equals("https") && port == 443);
        return scheme + "://" + serverName + (defaultPort ? "" : ":" + port) + ctx;
    }

    private Integer parseIntParam(String s) {
        if (s == null || s.isBlank()) return null;
        try { return Integer.parseInt(s.trim()); } catch (NumberFormatException e) { return null; }
    }


    private static String jsonEscape(String s) {
        return s == null ? "" : s.replace("\\", "\\\\").replace("\"", "\\\"");
    }

    // =========================================================================
    // PHẦN 6: UTILITY METHODS
    // =========================================================================

    /**
     * Kiểm tra xem một SQLException có phải là lỗi deadlock hay không.
     * SQL Server deadlock error code = 1205.
     * Phương thức kiểm tra cả chuỗi cause chain để bắt wrapped exceptions.
     */
    private boolean isBookingPage(String path) {
        return "/customer/dat-san".equals(path) || "/customer/dat_san".equals(path) || "/customer/chi-tiet-san".equals(path);
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

    private void handleGetDichVu(HttpServletRequest req, HttpServletResponse resp, TaiKhoan user)
            throws ServletException, IOException {
        // ── Validation: datSanId bắt buộc, phải là số nguyên dương ──
        Integer datSanId = parsePositiveInt(req.getParameter("datSanId"));
        if (datSanId == null) {
            LOGGER.warning(String.format(
                "[handleGetDichVu] Missing or invalid datSanId param: '%s', accountId=%s, uri=%s",
                req.getParameter("datSanId"),
                user != null ? user.getAccountId() : "null",
                req.getRequestURI()));
            resp.setContentType("application/json;charset=UTF-8");
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("{\"error\":\"Thiếu hoặc sai tham số datSanId.\"}");
            return;
        }
        if (user == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().write("{\"error\":\"Chưa đăng nhập.\"}" );
            return;
        }
        try {
            Lichdatsan lich = lichDatSanDAO.getLichById(datSanId);
            if (lich == null || !Integer.valueOf(user.getAccountId()).equals(lich.getAccountId())) {
                LOGGER.warning(String.format(
                    "[handleGetDichVu] Forbidden: datSanId=%d, requestAccountId=%d, lichAccountId=%s",
                    datSanId, user.getAccountId(), lich != null ? lich.getAccountId() : "null"));
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập đơn đặt này.");
                return;
            }

            San san = sanDAO.getSanById(lich.getSanId());
            if (san == null) {
                LOGGER.warning("[handleGetDichVu] San not found for sanId=" + lich.getSanId() + ", datSanId=" + datSanId);
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().write("{\"products\":[],\"ordered\":[]}");
                return;
            }
            int coSoId = san.getCoSoID();

            org.example.dao.SanPhamDichVuDAO spDao = new org.example.dao.impl.SanPhamDichVuDAOImpl();
            List<org.example.model.SanPham_DichVu> allSp = spDao.findByCoSo(coSoId);
            List<org.example.model.SanPham_DichVu> products = allSp.stream()
                .filter(sp -> sp.getTrangThai() != null && !"Ngừng kinh doanh".equals(sp.getTrangThai()))
                .collect(java.util.stream.Collectors.toList());

            org.example.dao.HoaDonDAO hdDao = new org.example.dao.impl.HoaDonDAOImpl();
            int hoaDonId = -1;
            try (java.sql.Connection conn = org.example.util.DBUtil.getConnection();
                 java.sql.PreparedStatement ps = conn.prepareStatement("SELECT invoice_id FROM invoices WHERE booking_id = ? AND invoice_type = 'MAIN'")) {
                ps.setInt(1, datSanId);
                try (java.sql.ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        hoaDonId = rs.getInt("invoice_id");
                    }
                }
            }

            List<org.example.model.ChiTietHoaDon> ordered = new java.util.ArrayList<>();
            if (hoaDonId != -1) {
                ordered = hdDao.getChiTietByHoaDonId(hoaDonId);
            }

            // Build plain maps to avoid Gson serializing lazy JPA relationships
            List<java.util.Map<String, Object>> productMaps = new java.util.ArrayList<>();
            for (org.example.model.SanPham_DichVu sp : products) {
                java.util.Map<String, Object> m = new java.util.HashMap<>();
                m.put("product_id", sp.getSanPhamID());
                m.put("product_name", sp.getTenSanPham());
                m.put("unit_price", sp.getDonGia());
                m.put("unit_of_measure", sp.getDonViTinh());
                m.put("stock_quantity", sp.getSoLuongTon());
                productMaps.add(m);
            }

            List<java.util.Map<String, Object>> orderedMaps = new java.util.ArrayList<>();
            for (org.example.model.ChiTietHoaDon ct : ordered) {
                java.util.Map<String, Object> m = new java.util.HashMap<>();
                m.put("product_id", ct.getSanPhamID());
                m.put("quantity", ct.getSoLuong());
                orderedMaps.add(m);
            }

            resp.setContentType("application/json;charset=UTF-8");
            java.util.Map<String, Object> data = new java.util.HashMap<>();
            data.put("products", productMaps);
            data.put("ordered", orderedMaps);
            resp.getWriter().write(gson.toJson(data));
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi khi lấy danh sách dịch vụ", e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, e.getMessage());
        }
    }

    private void handlePostDatDichVu(HttpServletRequest req, HttpServletResponse resp, HttpSession session, TaiKhoan user)
            throws ServletException, IOException {
        try {
            int datSanId = Integer.parseInt(req.getParameter("datSanId"));
            Lichdatsan lich = lichDatSanDAO.getLichById(datSanId);
            if (lich == null || lich.getAccountId() != user.getAccountId()) {
                session.setAttribute("error", "Bạn không có quyền truy cập đơn đặt này.");
                resp.sendRedirect(req.getContextPath() + "/customer/dat-san?openHistory=true");
                return;
            }

            // Parse selected services
            String[] spIdsStr = req.getParameterValues("productId");
            String[] qtysStr = req.getParameterValues("quantity");

            int[] productIds = new int[0];
            int[] quantities = new int[0];

            if (spIdsStr != null && qtysStr != null) {
                int count = spIdsStr.length;
                productIds = new int[count];
                quantities = new int[count];
                for (int i = 0; i < count; i++) {
                    productIds[i] = Integer.parseInt(spIdsStr[i]);
                    quantities[i] = Integer.parseInt(qtysStr[i]);
                }
            }

            // Update services
            lichDatSanDAO.updateDichVuDatSan(datSanId, productIds, quantities);
            session.setAttribute("message", "Cập nhật dịch vụ đặt thêm thành công!");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi khi cập nhật dịch vụ đặt thêm", e);
            session.setAttribute("error", "Lỗi: " + e.getMessage());
        }
        resp.sendRedirect(req.getContextPath() + "/customer/dat-san?openHistory=true");
    }

    private void handleGetChiTietSan(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            int sanId = Integer.parseInt(req.getParameter("id"));
            San san = sanDAO.getSanById(sanId);
            if (san == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy sân đấu.");
                return;
            }
            
            LoaiSan loai = loaiSanDAO.getLoaiSanById(san.getLoaiSanID());
            org.example.model.CoSo coSo = coSoDAO.getCoSoById(san.getCoSoID());
            
            List<org.example.model.CoSo> allCoSo = coSoDAO.getAllCoSo();
            List<LoaiSan> allLoaiSan = loaiSanDAO.getAllLoaiSan();
            List<MonTheThao> dsMon = loaiSanDAO.getAllMonTheThao();
            
            String tenMon = dsMon.stream()
                    .filter(m -> m.getMonTheThaoID() == loai.getMonTheThaoID())
                    .map(MonTheThao::getTenMon)
                    .findFirst()
                    .orElse("Khác");
            
            long totalSimilarCourts = sanDAO.countSansByLoaiSanId(san.getLoaiSanID());
            
            // Get other courts (excluding the current one)
            List<San> otherSans = sanDAO.getAllSan().stream()
                    .filter(s -> s.getSanID() != sanId)
                    .collect(java.util.stream.Collectors.toList());
            
            req.setAttribute("san", san);
            req.setAttribute("loai", loai);
            req.setAttribute("coSo", coSo);
            req.setAttribute("tenMon", tenMon);
            req.setAttribute("totalSimilarCourts", totalSimilarCourts);
            req.setAttribute("dsCoSo", allCoSo);
            req.setAttribute("dsLoaiSan", allLoaiSan);
            req.setAttribute("dsMon", dsMon);
            req.setAttribute("otherSans", otherSans);
            
            List<Lichdatsan> activeBookings = lichDatSanDAO.getAllLichDatSan();
            req.setAttribute("activeBookings", activeBookings);
            
            req.getRequestDispatcher("/customer/ChiTietSan.jsp").forward(req, resp);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi khi lấy chi tiết sân", e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, e.getMessage());
        }
    }
}
