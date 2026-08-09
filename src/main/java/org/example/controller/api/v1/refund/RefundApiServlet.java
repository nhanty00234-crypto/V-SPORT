package org.example.controller.api.v1.refund;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.api.ApiErrorCode;
import org.example.api.BaseApiServlet;
import org.example.dto.api.ApiDtos;
import org.example.model.Hoantien;
import org.example.model.TaiKhoan;
import org.example.service.RefundService;

import java.io.IOException;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * GET  /api/v1/refunds/me            — yêu cầu hoàn tiền của chính khách (phân trang)
 * GET  /api/v1/refunds/{id}          — chi tiết (chỉ của chính khách — DAO kiểm tra AccountID)
 * PUT  /api/v1/refunds/{id}/bank     — bổ sung/sửa thông tin ngân hàng nhận tiền
 * POST /api/v1/refunds/{id}/cancel   — khách tự hủy yêu cầu khi chưa được xử lý
 *
 * Toàn bộ state machine hoàn tiền tái sử dụng {@link RefundService} hiện có — mobile không tạo
 * bảng, trạng thái hay quy tắc hoàn tiền mới. Yêu cầu hoàn tiền vẫn được sinh tự động khi khách
 * hủy đơn đã thanh toán (xem POST /api/v1/bookings/{id}/cancel).
 */
@WebServlet("/api/v1/refunds/*")
public class RefundApiServlet extends BaseApiServlet {

    private static final DateTimeFormatter ISO = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss");
    private static final ZoneId VN = ZoneId.of("Asia/Ho_Chi_Minh");

    private final RefundService refundService = new RefundService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        handle(req, resp, () -> {
            TaiKhoan me = requireCustomer(req);
            String[] seg = pathSegments(req);
            if (seg.length == 1 && "me".equals(seg[0])) {
                int page = pageParam(req);
                List<ApiDtos.RefundDto> out = new ArrayList<>();
                for (Hoantien ht : refundService.getByCustomer(me.getAccountId(), page)) {
                    out.add(toDto(ht));
                }
                ok(resp, out);
            } else if (seg.length == 1) {
                ok(resp, toDto(requireOwnRefund(me, requireInt(seg[0], "refundId"))));
            } else {
                throw notFound("Endpoint không tồn tại.");
            }
        });
    }

    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        handle(req, resp, () -> {
            TaiKhoan me = requireCustomer(req);
            String[] seg = pathSegments(req);
            if (seg.length != 2 || !"bank".equals(seg[1])) throw notFound("Endpoint không tồn tại.");
            int refundId = requireInt(seg[0], "refundId");
            requireOwnRefund(me, refundId);

            ApiDtos.RefundBankInfoRequest body = readBody(req, ApiDtos.RefundBankInfoRequest.class);
            RefundService.RefundResult result = refundService.updateBankInfo(refundId, me.getAccountId(),
                    body.bankName, body.bankAccountNumber, body.bankAccountHolder, null);
            if (!result.success) {
                throw new ApiException(HttpServletResponse.SC_CONFLICT, ApiErrorCode.CONFLICT, result.message);
            }
            ok(resp, result.message, toDto(requireOwnRefund(me, refundId)));
        });
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        handle(req, resp, () -> {
            TaiKhoan me = requireCustomer(req);
            String[] seg = pathSegments(req);
            if (seg.length != 2 || !"cancel".equals(seg[1])) throw notFound("Endpoint không tồn tại.");
            int refundId = requireInt(seg[0], "refundId");
            requireOwnRefund(me, refundId);

            RefundService.RefundResult result = refundService.cancelByCustomer(refundId, me.getAccountId());
            if (!result.success) {
                throw new ApiException(HttpServletResponse.SC_CONFLICT, ApiErrorCode.CONFLICT, result.message);
            }
            ok(resp, result.message, toDto(requireOwnRefund(me, refundId)));
        });
    }

    /** Chống IDOR: chỉ trả yêu cầu hoàn tiền thuộc đúng khách đang đăng nhập. */
    private Hoantien requireOwnRefund(TaiKhoan me, int refundId) {
        Hoantien ht = refundService.findByIdAndAccountId(refundId, me.getAccountId());
        if (ht == null) throw notFound("Không tìm thấy yêu cầu hoàn tiền.");
        return ht;
    }

    private ApiDtos.RefundDto toDto(Hoantien ht) {
        ApiDtos.RefundDto dto = new ApiDtos.RefundDto();
        dto.refundId = ht.getHoanTienId();
        dto.bookingId = ht.getDatSanId();
        dto.invoiceId = ht.getHoaDonId();
        dto.requestedAmount = ht.getSoTienDeNghiHoan() != null ? ht.getSoTienDeNghiHoan() : ht.getSoTienHoan();
        dto.approvedAmount = ht.getSoTienDuocDuyet();
        dto.paidAmount = ht.getSoTienDaThanhToan();
        dto.status = ht.getTrangThai();
        dto.reason = ht.getLyDo();
        dto.rejectReason = ht.getLyDoTuChoi();
        dto.bankName = ht.getNganHangNhan();
        dto.bankAccountNumber = ht.getSoTaiKhoanNhan();
        dto.bankAccountHolder = ht.getChuTaiKhoanNhan();
        dto.requestedAt = iso(ht.getThoiGianYeuCau());
        dto.completedAt = iso(ht.getCompletedAt());
        return dto;
    }

    private String iso(Date d) {
        return d == null ? null : d.toInstant().atZone(VN).toLocalDateTime().format(ISO);
    }
}
