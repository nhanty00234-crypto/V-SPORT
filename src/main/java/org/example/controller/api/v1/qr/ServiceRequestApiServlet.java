package org.example.controller.api.v1.qr;

import com.google.gson.Gson;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.api.ApiErrorCode;
import org.example.api.BaseApiServlet;
import org.example.dto.api.ApiDtos;
import org.example.dto.qr.QRRequestDTO;
import org.example.dto.qr.SanQRResolveDTO;
import org.example.model.QRRequest;
import org.example.model.TaiKhoan;
import org.example.service.QRRequestService;
import org.example.service.manager.SanQRService;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * POST /api/v1/service-requests            — khách gửi yêu cầu tại sân sau khi quét QR
 * GET  /api/v1/service-requests?qrCode=... — xem trạng thái các yêu cầu của chính mình tại sân đó
 *
 * Điểm mấu chốt (mục XIX/XXIII spec): yêu cầu tạo ra ở đây đi thẳng vào bảng QRRequest qua
 * {@link QRRequestService} — CHÍNH service mà màn hình Staff/Manager trên Web đang đọc. Nhờ vậy
 * nhân viên nhận được yêu cầu từ app y hệt như từ trang QR của Web, không cần đồng bộ gì thêm.
 *
 * SanID KHÔNG bao giờ lấy từ body: server tự resolve từ mã QR mà khách đã quét.
 * GuestToken được server sinh từ AccountID + SanID nên khách không thể mạo danh phiên của người khác.
 */
@WebServlet("/api/v1/service-requests/*")
public class ServiceRequestApiServlet extends BaseApiServlet {

    private static final Logger logger = LogManager.getLogger(ServiceRequestApiServlet.class);

    private final QRRequestService qrRequestService = new QRRequestService();
    private final SanQRService sanQRService = new SanQRService();
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        handle(req, resp, () -> {
            TaiKhoan me = requireCustomer(req);
            ApiDtos.ServiceRequestRequest body = readBody(req, ApiDtos.ServiceRequestRequest.class);

            if (body.sessionToken == null || body.sessionToken.isBlank()) {
                throw badRequest("Thiếu sessionToken (mã QR đã quét).");
            }
            if (!QrApiServlet.QrCodes.allTypes().contains(body.type)) {
                throw badRequest("Loại yêu cầu không hợp lệ.");
            }

            SanQRResolveDTO resolved = QrApiServlet.QrCodes.resolve(sanQRService, body.sessionToken);
            if (!resolved.isAvailable() || resolved.getSanId() == null) {
                throw new ApiException(HttpServletResponse.SC_BAD_REQUEST, ApiErrorCode.QR_INVALID,
                        resolved.getMessage());
            }
            int sanId = resolved.getSanId();

            String note = body.note;
            String itemsJson = null;
            if (QRRequest.TYPE_ORDER_ITEM.equals(body.type)) {
                if (body.items == null || body.items.isEmpty()) {
                    throw badRequest("Vui lòng chọn ít nhất một sản phẩm.");
                }
                for (ApiDtos.ServiceRequestRequest.OrderItem it : body.items) {
                    if (it.soLuong <= 0) throw badRequest("Số lượng sản phẩm phải lớn hơn 0.");
                }
                // Chỉ gửi id + số lượng; GIÁ do Staff xác nhận lấy lại từ DB (QRRequestService).
                itemsJson = gson.toJson(body.items);
            }
            if (QRRequest.TYPE_PAYMENT_REQUEST.equals(body.type)
                    && !QRRequest.PAYMENT_METHOD_TRANSFER.equals(note)
                    && !QRRequest.PAYMENT_METHOD_CASH.equals(note)) {
                throw badRequest("Vui lòng chọn phương thức thanh toán hợp lệ (Chuyển khoản hoặc Tiền mặt).");
            }

            String guestToken = guestTokenFor(me.getAccountId(), sanId);
            QRRequestService.Result result = qrRequestService.createRequest(
                    sanId, guestToken, me.getAccountId(), body.type, itemsJson, note);

            if (!result.success) {
                throw new ApiException(statusFor(result.errorCode), errorCodeFor(result.errorCode), result.message);
            }
            logger.info("API_SERVICE_REQUEST_CREATED accountId={} sanId={} type={} requestId={}",
                    me.getAccountId(), sanId, body.type, result.data.getRequestId());
            created(resp, "Đã gửi yêu cầu tới nhân viên.", toDto(result.data));
        });
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        handle(req, resp, () -> {
            TaiKhoan me = requireCustomer(req);
            String qrCode = req.getParameter("qrCode");
            if (qrCode == null || qrCode.isBlank()) throw badRequest("Thiếu tham số qrCode.");

            SanQRResolveDTO resolved = QrApiServlet.QrCodes.resolve(sanQRService, qrCode);
            if (resolved.getSanId() == null) {
                throw new ApiException(HttpServletResponse.SC_BAD_REQUEST, ApiErrorCode.QR_INVALID,
                        resolved.getMessage());
            }
            List<ApiDtos.ServiceRequestDto> out = new ArrayList<>();
            for (QRRequestDTO r : qrRequestService.listByGuestToken(
                    guestTokenFor(me.getAccountId(), resolved.getSanId()), resolved.getSanId())) {
                out.add(toDto(r));
            }
            ok(resp, out);
        });
    }

    /**
     * Định danh phiên khách cho một sân, sinh từ AccountID đã xác thực — không nhận từ client.
     * Ổn định theo (khách, sân) nên cơ chế chống gửi trùng của QRRequestService hoạt động đúng.
     * Độ dài tối đa an toàn dưới giới hạn 64 ký tự của cột GuestToken.
     */
    private String guestTokenFor(int accountId, int sanId) {
        return "mobile-" + accountId + "-" + sanId;
    }

    private ApiDtos.ServiceRequestDto toDto(QRRequestDTO r) {
        ApiDtos.ServiceRequestDto dto = new ApiDtos.ServiceRequestDto();
        dto.requestId = r.getRequestId();
        dto.courtId = r.getSanId();
        dto.courtName = r.getTenSan();
        dto.type = r.getRequestType();
        dto.note = r.getNote();
        dto.status = r.getStatus();
        dto.createdAt = r.getCreatedAt();
        dto.updatedAt = r.getUpdatedAt();
        return dto;
    }

    private int statusFor(QRRequestService.ErrorCode code) {
        if (code == null) return HttpServletResponse.SC_INTERNAL_SERVER_ERROR;
        return switch (code) {
            case NOT_FOUND -> HttpServletResponse.SC_NOT_FOUND;
            case FORBIDDEN -> HttpServletResponse.SC_FORBIDDEN;
            case DUPLICATE -> HttpServletResponse.SC_CONFLICT;
            case INVALID_TRANSITION -> HttpServletResponse.SC_BAD_REQUEST;
            default -> HttpServletResponse.SC_INTERNAL_SERVER_ERROR;
        };
    }

    private String errorCodeFor(QRRequestService.ErrorCode code) {
        if (code == null) return ApiErrorCode.INTERNAL_ERROR;
        return switch (code) {
            case NOT_FOUND -> ApiErrorCode.NOT_FOUND;
            case FORBIDDEN -> ApiErrorCode.FORBIDDEN;
            case DUPLICATE -> ApiErrorCode.DUPLICATE;
            case INVALID_TRANSITION -> ApiErrorCode.VALIDATION_ERROR;
            default -> ApiErrorCode.INTERNAL_ERROR;
        };
    }
}
