package org.example.controller.api.v1.qr;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.api.BaseApiServlet;
import org.example.dao.LichDatSanDichVuDAO;
import org.example.dao.SanPhamDichVuDAO;
import org.example.dao.impl.LichDatSanDichVuDAOImpl;
import org.example.dao.impl.SanPhamDichVuDAOImpl;
import org.example.dto.api.ApiDtos;
import org.example.dto.qr.SanQRResolveDTO;
import org.example.model.QRRequest;
import org.example.model.San;
import org.example.model.SanPham_DichVu;
import org.example.model.TaiKhoan;
import org.example.service.customer.CustomerCatalogService;
import org.example.service.manager.SanQRService;
import org.example.util.Constants;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * GET /api/v1/qr/{code} — resolve mã QR dán tại sân (short code hoặc token UUID) thành ngữ cảnh
 * hiển thị cho khách: tên cơ sở, tên sân, môn thể thao, các hành động khả dụng và menu dịch vụ.
 *
 * Chỉ ĐỌC — không check-in, không tạo bản ghi nào (giống SanQRResolveServlet của Web) và tái sử
 * dụng đúng {@link SanQRService} nên chính sách QR (ACTIVE/DISABLED/REVOKED, sân bảo trì) là một.
 *
 * Trả về sessionToken = chính mã QR đã quét; app gửi lại token này khi tạo yêu cầu dịch vụ để
 * server tự resolve ra sân — app KHÔNG được tự khai courtId.
 */
@WebServlet("/api/v1/qr/*")
public class QrApiServlet extends BaseApiServlet {

    private final SanQRService sanQRService = new SanQRService();
    private final CustomerCatalogService catalogService = new CustomerCatalogService();
    private final SanPhamDichVuDAO sanPhamDichVuDAO = new SanPhamDichVuDAOImpl();
    private final LichDatSanDichVuDAO lichDatSanDichVuDAO = new LichDatSanDichVuDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        handle(req, resp, () -> {
            TaiKhoan me = requireCustomer(req);
            String[] seg = pathSegments(req);
            if (seg.length != 1) throw notFound("Thiếu mã QR trong đường dẫn.");

            String code = seg[0];
            SanQRResolveDTO resolved = QrCodes.resolve(sanQRService, code);

            ApiDtos.QrContextDto dto = new ApiDtos.QrContextDto();
            dto.resultCode = resolved.getResultCode();
            dto.message = resolved.getMessage();
            dto.available = resolved.isAvailable();
            dto.facilityName = resolved.getTenCoSo();
            dto.courtName = resolved.getTenSan();
            dto.sportName = resolved.getTenMonTheThao();
            dto.courtId = resolved.getSanId();
            dto.availableActions = new ArrayList<>();
            dto.products = new ArrayList<>();

            if (!resolved.isAvailable() || resolved.getSanId() == null) {
                // Mã không dùng được: trả 200 kèm resultCode để app hiển thị thông điệp thân thiện.
                ok(resp, dto);
                return;
            }

            dto.sessionToken = code;
            dto.availableActions.add(QRRequest.TYPE_CALL_STAFF);
            dto.availableActions.add(QRRequest.TYPE_SERVICE_REQUEST);

            San san = catalogService.findCourt(resolved.getSanId());
            if (san != null) {
                for (SanPham_DichVu sp : sanPhamDichVuDAO.findByCoSo(san.getCoSoID())) {
                    if (!Constants.TRANG_THAI_SP_DANG_KINH_DOANH.equals(sp.getTrangThai())) continue;
                    ApiDtos.ProductDto p = new ApiDtos.ProductDto();
                    p.productId = sp.getSanPhamID();
                    p.name = sp.getTenSanPham();
                    p.price = sp.getDonGia();
                    p.unit = sp.getDonViTinh();
                    p.stock = sp.getSoLuongTon();
                    dto.products.add(p);
                }
                if (!dto.products.isEmpty()) {
                    dto.availableActions.add(QRRequest.TYPE_ORDER_ITEM);
                }
            }

            // Phiên sân đang diễn ra (nếu có) — quyết định việc gọi món/thanh toán có ý nghĩa hay không.
            try {
                Integer activeDatSanId = lichDatSanDichVuDAO.findActiveDatSanIdBySan(resolved.getSanId());
                dto.activeBookingId = activeDatSanId;
                if (activeDatSanId != null) {
                    dto.availableActions.add(QRRequest.TYPE_PAYMENT_REQUEST);
                }
            } catch (java.sql.SQLException ignored) {
                // Không tra được phiên đang chơi -> vẫn cho gọi nhân viên.
            }

            ok(resp, dto);
        });
    }

    /** Helper dùng chung với ServiceRequestApiServlet — resolve short code hoặc token UUID. */
    static final class QrCodes {
        private QrCodes() {}

        static SanQRResolveDTO resolve(SanQRService service, String rawCode) {
            String code = rawCode == null ? "" : rawCode.trim();
            // QR dán tại sân có thể là URL đầy đủ (…/qr/ABC123) — lấy đoạn cuối.
            int slash = code.lastIndexOf('/');
            if (slash >= 0 && slash < code.length() - 1) code = code.substring(slash + 1);
            int question = code.indexOf('?');
            if (question > 0) code = code.substring(0, question);

            try {
                java.util.UUID token = java.util.UUID.fromString(code);
                return service.resolve(token).dto;
            } catch (IllegalArgumentException notAUuid) {
                return service.resolveActiveShortCode(code).dto;
            }
        }

        static List<String> allTypes() {
            return List.of(QRRequest.TYPE_CALL_STAFF, QRRequest.TYPE_ORDER_ITEM,
                    QRRequest.TYPE_SERVICE_REQUEST, QRRequest.TYPE_PAYMENT_REQUEST);
        }
    }
}
