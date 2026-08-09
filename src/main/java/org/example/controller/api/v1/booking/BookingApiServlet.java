package org.example.controller.api.v1.booking;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.api.ApiErrorCode;
import org.example.api.BaseApiServlet;
import org.example.api.ImageUrls;
import org.example.dao.LichDatSanDAO;
import org.example.dao.impl.LichDatSanDAOImpl;
import org.example.dto.api.ApiDtos;
import org.example.dto.payment.PayosQrData;
import org.example.model.Lichdatsan;
import org.example.model.TaiKhoan;
import org.example.service.booking.BookingCancellationService;
import org.example.service.booking.BookingCreationService;
import org.example.service.customer.CustomerCatalogService;
import org.example.service.customer.PromotionService;
import org.example.service.payos.BookingPaymentLinkService;
import org.example.service.payos.BookingPaymentStatusService;
import org.example.service.pricing.CourtPriceResult;
import org.example.util.Constants;
import org.example.util.DBUtil;
import org.example.util.TimeUtil;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Connection;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Toàn bộ nghiệp vụ đặt sân của mobile:
 *
 *  POST /api/v1/bookings                       — tạo booking (giá do server tính)
 *  POST /api/v1/bookings/quote                 — báo giá trước khi đặt (kèm thử mã khuyến mãi)
 *  GET  /api/v1/bookings/me?status=&page=&size=— lịch sử đặt sân của CHÍNH khách đang đăng nhập
 *  GET  /api/v1/bookings/{id}                  — chi tiết (kiểm tra quyền sở hữu)
 *  GET  /api/v1/bookings/{id}/cancel-preview   — chính sách hủy/hoàn tiền áp dụng cho đơn này
 *  POST /api/v1/bookings/{id}/cancel           — hủy đơn
 *  POST /api/v1/bookings/{id}/payment          — tạo/tái tạo QR PayOS cho đơn
 *  GET  /api/v1/bookings/{id}/payment-status   — trạng thái thanh toán
 *
 * Không endpoint nào nhận accountId từ client — luôn suy ra từ access token.
 * Không endpoint nào nhận số tiền từ client — server tự tính lại từ bảng giá.
 */
@WebServlet("/api/v1/bookings/*")
public class BookingApiServlet extends BaseApiServlet {

    private static final Logger logger = LogManager.getLogger(BookingApiServlet.class);
    private static final DateTimeFormatter ISO_DATETIME = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss");

    private final LichDatSanDAO lichDatSanDAO = new LichDatSanDAOImpl();
    private final BookingCreationService bookingCreationService = new BookingCreationService();
    private final BookingCancellationService cancellationService = new BookingCancellationService();
    private final BookingPaymentLinkService paymentLinkService = new BookingPaymentLinkService();
    private final BookingPaymentStatusService paymentStatusService = new BookingPaymentStatusService();
    private final CustomerCatalogService catalogService = new CustomerCatalogService();
    private final PromotionService promotionService = new PromotionService();
    private final org.example.service.NotificationService notificationService =
            new org.example.service.NotificationService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        handle(req, resp, () -> {
            TaiKhoan me = requireCustomer(req);
            String[] seg = pathSegments(req);
            if (seg.length == 1 && "me".equals(seg[0])) {
                listMyBookings(req, resp, me);
            } else if (seg.length == 1) {
                ok(resp, bookingDetail(req, me, requireInt(seg[0], "bookingId")));
            } else if (seg.length == 2 && "cancel-preview".equals(seg[1])) {
                cancelPreview(resp, me, requireInt(seg[0], "bookingId"));
            } else if (seg.length == 2 && "payment-status".equals(seg[1])) {
                paymentStatus(resp, me, requireInt(seg[0], "bookingId"));
            } else {
                throw notFound("Endpoint không tồn tại.");
            }
        });
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        handle(req, resp, () -> {
            TaiKhoan me = requireCustomer(req);
            String[] seg = pathSegments(req);
            if (seg.length == 0) {
                createBooking(req, resp, me);
            } else if (seg.length == 1 && "quote".equals(seg[0])) {
                quote(req, resp);
            } else if (seg.length == 2 && "cancel".equals(seg[1])) {
                cancelBooking(req, resp, me, requireInt(seg[0], "bookingId"));
            } else if (seg.length == 2 && "payment".equals(seg[1])) {
                createPayment(req, resp, me, requireInt(seg[0], "bookingId"));
            } else {
                throw notFound("Endpoint không tồn tại.");
            }
        });
    }

    // ==================================================================
    // Tạo booking
    // ==================================================================

    private void createBooking(HttpServletRequest req, HttpServletResponse resp, TaiKhoan me) throws IOException {
        ApiDtos.CreateBookingRequest body = readBody(req, ApiDtos.CreateBookingRequest.class);

        BookingCreationService.Command cmd = new BookingCreationService.Command();
        cmd.sanId = body.courtId;
        cmd.ngayDat = parseDate(body.bookingDate, "bookingDate");
        cmd.gioBatDau = parseTime(body.startTime, "startTime");
        cmd.gioKetThuc = parseTime(body.endTime, "endTime");
        cmd.ghiChu = body.note;
        cmd.nguonDatSan = "Mobile";
        cmd.onlinePayment = "payos".equalsIgnoreCase(body.paymentMethod);

        BookingCreationService.Result result = bookingCreationService.create(me, cmd);
        if (!result.success) {
            throw new ApiException(statusForBookingError(result.errorCode), result.errorCode, result.message);
        }

        int bookingId = result.datSanId;
        logger.info("API_BOOKING_CREATED accountId={} bookingId={} courtId={} status={}",
                me.getAccountId(), bookingId, cmd.sanId, result.trangThai);

        // Thông báo giống hệt luồng Web (cùng NotificationService) để Manager/Staff web nhận được.
        try {
            notificationService.notifyBookingCreated(me.getAccountId(), bookingId, cmd.onlinePayment);
        } catch (Exception e) {
            logger.warn("notifyBookingCreated failed bookingId={}: {}", bookingId, e.getMessage());
        }
        try {
            notificationService.notifyManagerStaffNewBooking(result.coSoId, bookingId, me.getFullName(), null,
                    cmd.gioBatDau + "-" + cmd.gioKetThuc);
        } catch (Exception e) {
            logger.warn("notifyManagerStaffNewBooking failed bookingId={}: {}", bookingId, e.getMessage());
        }

        created(resp, "Đặt sân thành công.", bookingDetail(req, me, bookingId));
    }

    private int statusForBookingError(String errorCode) {
        return switch (errorCode) {
            case BookingCreationService.ERR_NOT_FOUND -> HttpServletResponse.SC_NOT_FOUND;
            case BookingCreationService.ERR_SLOT_TAKEN, BookingCreationService.ERR_BOOKING_LIMIT ->
                    HttpServletResponse.SC_CONFLICT;
            case BookingCreationService.ERR_REPUTATION, BookingCreationService.ERR_COURT_UNAVAIL ->
                    HttpServletResponse.SC_FORBIDDEN;
            case BookingCreationService.ERR_INTERNAL -> HttpServletResponse.SC_INTERNAL_SERVER_ERROR;
            default -> HttpServletResponse.SC_BAD_REQUEST;
        };
    }

    // ==================================================================
    // Báo giá
    // ==================================================================

    /**
     * Tính trước tiền sân cho một khung giờ. Dùng ĐÚNG {@link BookingCreationService#calculatePrice}
     * nên số tiền hiển thị trên app luôn khớp số tiền lưu khi đặt.
     *
     * Mã khuyến mãi chỉ được KIỂM TRA và hiển thị mức giảm (giống endpoint /api/promotion/apply của
     * Web) — việc trừ tiền thực tế do luồng hóa đơn hiện có đảm nhiệm, mobile không tạo quy tắc mới.
     */
    private void quote(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        ApiDtos.QuoteRequest body = readBody(req, ApiDtos.QuoteRequest.class);
        LocalDate date = parseDate(body.bookingDate, "bookingDate");
        LocalTime start = parseTime(body.startTime, "startTime");
        LocalTime end = parseTime(body.endTime, "endTime");
        if (!end.isAfter(start)) throw badRequest("Giờ kết thúc phải sau giờ bắt đầu.");

        ApiDtos.QuoteDto dto = new ApiDtos.QuoteDto();
        dto.courtId = body.courtId;
        dto.bookingDate = date;
        dto.startTime = start;
        dto.endTime = end;

        try (Connection conn = DBUtil.getConnection()) {
            CourtPriceResult price = bookingCreationService.calculatePrice(conn, body.courtId, date, start, end);
            dto.durationMinutes = price.totalMinutes();
            dto.courtAmount = price.totalCourtAmount().setScale(0, RoundingMode.HALF_UP);
        } catch (java.sql.SQLException e) {
            throw new ApiException(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, ApiErrorCode.INTERNAL_ERROR,
                    "Không thể tính giá sân.");
        }

        dto.discountAmount = BigDecimal.ZERO;
        dto.totalAmount = dto.courtAmount;
        if (body.promotionCode != null && !body.promotionCode.isBlank()) {
            Integer facilityId = facilityIdOfCourt(body.courtId);
            PromotionService.PromotionResult pr = promotionService.validateAndCalculate(
                    body.promotionCode, dto.courtAmount, facilityId, date);
            dto.promotionApplied = pr.isValid();
            dto.promotionMessage = pr.getMessage();
            if (pr.isValid()) {
                dto.discountAmount = pr.getDiscountAmount();
                dto.totalAmount = pr.getFinalAmount();
            }
        }
        ok(resp, dto);
    }

    // ==================================================================
    // Danh sách / chi tiết
    // ==================================================================

    private void listMyBookings(HttpServletRequest req, HttpServletResponse resp, TaiKhoan me) throws IOException {
        String status = req.getParameter("status");
        int page = pageParam(req);
        int size = sizeParam(req);

        List<Lichdatsan> all = lichDatSanDAO.getLichByAccountId(me.getAccountId());
        List<Lichdatsan> filtered = new ArrayList<>();
        for (Lichdatsan l : all) {
            if (status != null && !status.isBlank() && !status.equals(l.getTrangThai())) continue;
            filtered.add(l);
        }

        int total = filtered.size();
        int from = Math.min((page - 1) * size, total);
        int to = Math.min(from + size, total);
        List<Lichdatsan> pageItems = filtered.subList(from, to);

        Map<Integer, CustomerCatalogService.CourtContext> ctx = catalogService.courtContexts(courtIds(pageItems));
        List<ApiDtos.BookingDto> items = new ArrayList<>();
        for (Lichdatsan l : pageItems) {
            items.add(toDto(req, l, ctx.get(l.getSanId())));
        }
        ok(resp, new ApiDtos.PageDto<>(page, size, total, items));
    }

    private ApiDtos.BookingDto bookingDetail(HttpServletRequest req, TaiKhoan me, int bookingId) {
        Lichdatsan l = requireOwnedBooking(me, bookingId);
        Map<Integer, CustomerCatalogService.CourtContext> ctx =
                catalogService.courtContexts(List.of(l.getSanId()));
        return toDto(req, l, ctx.get(l.getSanId()));
    }

    /** Chống IDOR: đơn không thuộc khách đang đăng nhập -> 404 (không tiết lộ đơn có tồn tại). */
    private Lichdatsan requireOwnedBooking(TaiKhoan me, int bookingId) {
        Lichdatsan l = lichDatSanDAO.getLichById(bookingId);
        if (l == null || l.getAccountId() == null || l.getAccountId() != me.getAccountId()) {
            throw notFound("Không tìm thấy đơn đặt sân.");
        }
        return l;
    }

    private Set<Integer> courtIds(List<Lichdatsan> list) {
        Set<Integer> ids = new LinkedHashSet<>();
        for (Lichdatsan l : list) if (l.getSanId() != null) ids.add(l.getSanId());
        return ids;
    }

    private ApiDtos.BookingDto toDto(HttpServletRequest req, Lichdatsan l,
                                     CustomerCatalogService.CourtContext ctx) {
        ApiDtos.BookingDto dto = new ApiDtos.BookingDto();
        dto.bookingId = l.getDatSanId();
        dto.courtId = l.getSanId() != null ? l.getSanId() : 0;
        dto.bookingDate = l.getNgayDat();
        dto.startTime = l.getGioBatDau();
        dto.endTime = l.getGioKetThuc();
        dto.status = l.getTrangThai();
        dto.totalAmount = l.getTongTienDuKien();
        dto.lightingApplied = l.isApDungGiaCoDen();
        dto.note = l.getGhiChu();
        dto.source = l.getNguonDatSan();
        dto.createdAt = l.getCreatedTime() != null ? l.getCreatedTime().format(ISO_DATETIME) : null;
        if (ctx != null) {
            dto.courtName = ctx.courtName;
            dto.facilityId = ctx.facilityId;
            dto.facilityName = ctx.facilityName;
            dto.facilityAddress = ctx.facilityAddress;
            dto.sportName = ctx.sportName;
            dto.image = ImageUrls.absolutize(req, ctx.courtImage != null ? ctx.courtImage : ctx.facilityImage);
        }
        boolean pendingPayment = Constants.TRANG_THAI_DAT_SAN_CHO_THANH_TOAN.equals(l.getTrangThai());
        if (pendingPayment && l.getHoldExpiresAt() != null) {
            dto.holdRemainingSeconds = TimeUtil.secondsUntilUtc(l.getHoldExpiresAt());
        }
        dto.payable = pendingPayment && !TimeUtil.isPastUtc(l.getHoldExpiresAt());
        dto.cancellable = BookingCancellationService.isCancellableStatus(l.getTrangThai())
                && !(pendingPayment && TimeUtil.isPastUtc(l.getHoldExpiresAt()));
        return dto;
    }

    // ==================================================================
    // Hủy
    // ==================================================================

    private void cancelPreview(HttpServletResponse resp, TaiKhoan me, int bookingId) throws IOException {
        requireOwnedBooking(me, bookingId);
        BookingCancellationService.CancellationPreview p =
                cancellationService.calculatePreview(bookingId, me.getAccountId());

        ApiDtos.CancelPreviewDto dto = new ApiDtos.CancelPreviewDto();
        dto.cancellationAllowed = p.cancellationAllowed;
        dto.refundEligible = p.refundEligible;
        dto.paid = p.paid;
        dto.amountPaid = p.amountPaid;
        dto.cancellationFee = p.cancellationFee;
        dto.refundableAmount = p.refundableAmount;
        dto.reputationPenalty = p.reputationPenalty;
        dto.hoursBeforeStart = p.hoursBeforeStart;
        dto.policyMessage = p.policyMessage;
        dto.refundAlreadyExists = p.refundAlreadyExists;
        dto.existingRefundId = p.existingHoanTienId;
        ok(resp, p.message, dto);
    }

    private void cancelBooking(HttpServletRequest req, HttpServletResponse resp, TaiKhoan me, int bookingId)
            throws IOException {
        requireOwnedBooking(me, bookingId);
        String reason = null;
        if (req.getContentLength() > 0) {
            ApiDtos.CancelBookingRequest body = readBody(req, ApiDtos.CancelBookingRequest.class);
            reason = body.reason;
        }

        // Toàn bộ chính sách hủy (giới hạn giờ, trừ điểm uy tín, tạo yêu cầu hoàn tiền, thông báo)
        // dùng chung BookingCancellationService với Web — mobile không có luật hủy riêng.
        BookingCancellationService.CancelResult result =
                cancellationService.cancelByCustomer(bookingId, me.getAccountId(), reason, req, me);

        if (!result.success) {
            throw new ApiException(result.alreadyCancelled
                    ? HttpServletResponse.SC_CONFLICT : HttpServletResponse.SC_BAD_REQUEST,
                    result.alreadyCancelled ? ApiErrorCode.CONFLICT : ApiErrorCode.VALIDATION_ERROR,
                    result.message);
        }

        ApiDtos.CancelResultDto dto = new ApiDtos.CancelResultDto();
        dto.bookingId = bookingId;
        dto.refundId = result.createdHoanTienId;
        dto.newReputationScore = result.newReputationScore;
        dto.refundableAmount = result.refundableAmount;
        dto.cancellationFee = result.cancellationFee;
        ok(resp, result.message, dto);
    }

    // ==================================================================
    // Thanh toán
    // ==================================================================

    /**
     * Tạo (hoặc tái tạo) QR PayOS cho một booking đang "Chờ thanh toán". Số tiền LUÔN đọc lại từ DB,
     * không nhận từ app. Secret PayOS chỉ tồn tại phía server.
     */
    private void createPayment(HttpServletRequest req, HttpServletResponse resp, TaiKhoan me, int bookingId)
            throws IOException {
        Lichdatsan l = requireOwnedBooking(me, bookingId);
        if (!Constants.TRANG_THAI_DAT_SAN_CHO_THANH_TOAN.equals(l.getTrangThai())) {
            throw conflict(ApiErrorCode.PAYMENT_CONFLICT,
                    "Đơn không ở trạng thái chờ thanh toán (hiện tại: " + l.getTrangThai() + ").");
        }
        if (TimeUtil.isPastUtc(l.getHoldExpiresAt())) {
            throw conflict(ApiErrorCode.PAYMENT_CONFLICT, BookingPaymentLinkService.MSG_EXPIRED);
        }
        Integer coSoId = paymentStatusService.findCoSoIdByDatSanId(bookingId);
        if (coSoId == null) throw notFound("Không xác định được cơ sở của đơn đặt sân.");

        long amount = l.getTongTienDuKien().setScale(0, RoundingMode.HALF_UP).longValue();
        String description = "VSport DS" + bookingId;
        String base = ImageUrls.baseUrl(req) + req.getContextPath();

        BookingPaymentLinkService.LinkResult link = paymentLinkService.createLink(
                coSoId, bookingId, amount, description,
                base + "/customer/payos-return?datSanId=" + bookingId,
                base + "/customer/payos-cancel?datSanId=" + bookingId,
                true);

        if (!link.success) {
            throw new ApiException(HttpServletResponse.SC_BAD_GATEWAY, ApiErrorCode.PAYMENT_ERROR, link.message);
        }
        PayosQrData qr = paymentLinkService.persistQr(null, bookingId, link.session, amount, description);

        ApiDtos.PaymentDto dto = new ApiDtos.PaymentDto();
        dto.bookingId = bookingId;
        dto.orderCode = qr.orderCode != null ? qr.orderCode : bookingId;
        dto.amount = amount;
        dto.description = description;
        dto.qrPayload = qr.qrPayload;
        dto.checkoutUrl = qr.checkoutUrl;
        dto.bankBin = qr.bin;
        dto.accountNumber = qr.accountNumber;
        dto.accountName = qr.accountName;
        dto.expiresAtEpoch = qr.expiresAtEpoch;
        ok(resp, "Đã tạo mã thanh toán.", dto);
    }

    private void paymentStatus(HttpServletResponse resp, TaiKhoan me, int bookingId) throws IOException {
        BookingPaymentStatusService.Status s = paymentStatusService.check(bookingId, me.getAccountId());
        if (s.isNotFound()) throw notFound("Không tìm thấy đơn đặt sân.");

        ApiDtos.PaymentStatusDto dto = new ApiDtos.PaymentStatusDto();
        dto.bookingId = bookingId;
        dto.status = s.status;
        dto.paid = s.paid;
        dto.bookingStatus = s.bookingStatus;
        dto.remainingSeconds = s.remainingSeconds;
        dto.message = s.message;
        ok(resp, dto);
    }

    // ==================================================================

    private Integer facilityIdOfCourt(int courtId) {
        Map<Integer, CustomerCatalogService.CourtContext> ctx = catalogService.courtContexts(List.of(courtId));
        CustomerCatalogService.CourtContext c = ctx.get(courtId);
        return c != null ? c.facilityId : null;
    }

    private LocalDate parseDate(String raw, String field) {
        if (raw == null || raw.isBlank()) throw badRequest("Thiếu " + field + ".");
        try {
            return LocalDate.parse(raw.trim());
        } catch (RuntimeException e) {
            throw badRequest(field + " phải theo định dạng yyyy-MM-dd.");
        }
    }

    private LocalTime parseTime(String raw, String field) {
        if (raw == null || raw.isBlank()) throw badRequest("Thiếu " + field + ".");
        try {
            return LocalTime.parse(raw.trim());
        } catch (RuntimeException e) {
            throw badRequest(field + " phải theo định dạng HH:mm.");
        }
    }
}
