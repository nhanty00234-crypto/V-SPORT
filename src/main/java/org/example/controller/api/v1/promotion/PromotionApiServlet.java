package org.example.controller.api.v1.promotion;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.api.ApiMappers;
import org.example.api.BaseApiServlet;
import org.example.dao.KhuyenMaiDAO;
import org.example.dao.KhuyenMaiHinhAnhDAO;
import org.example.dao.impl.KhuyenMaiDAOImpl;
import org.example.dao.impl.KhuyenMaiHinhAnhDAOImpl;
import org.example.dto.api.ApiDtos;
import org.example.model.KhuyenMai;
import org.example.model.KhuyenMaiHinhAnh;
import org.example.model.TaiKhoan;
import org.example.service.customer.CustomerCatalogService;
import org.example.service.customer.PromotionImagePresenter;
import org.example.service.customer.PromotionService;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * GET  /api/v1/promotions?facilityId=&limit= — khuyến mãi công khai còn hiệu lực
 * GET  /api/v1/promotions/available          — như trên (alias cho màn hình "Ưu đãi" của app)
 * POST /api/v1/promotions/validate           — thử một mã, trả mức giảm dự kiến
 *
 * Điều kiện hiển thị và công thức giảm giá tái sử dụng nguyên {@link KhuyenMaiDAO} +
 * {@link PromotionService} mà Web đang dùng (/api/promotion/apply). Số tiền giảm CUỐI CÙNG vẫn do
 * luồng hóa đơn phía server quyết định — endpoint này chỉ để hiển thị trước cho khách.
 */
@WebServlet("/api/v1/promotions/*")
public class PromotionApiServlet extends BaseApiServlet {

    private final KhuyenMaiDAO khuyenMaiDAO = new KhuyenMaiDAOImpl();
    private final KhuyenMaiHinhAnhDAO khuyenMaiHinhAnhDAO = new KhuyenMaiHinhAnhDAOImpl();
    private final PromotionService promotionService = new PromotionService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        handle(req, resp, () -> {
            String[] seg = pathSegments(req);
            if (seg.length > 1 || (seg.length == 1 && !"available".equals(seg[0]))) {
                throw notFound("Endpoint không tồn tại.");
            }
            Integer facilityId = optionalInt(req, "facilityId");
            Integer limit = optionalInt(req, "limit");
            LocalDate today = LocalDate.now(CustomerCatalogService.VN_ZONE);

            List<KhuyenMai> list = facilityId != null
                    ? khuyenMaiDAO.findPublicActiveByCoSoId(facilityId, today)
                    : khuyenMaiDAO.findPublicActiveAll(today, limit != null && limit > 0 ? limit : 50);

            ok(resp, toDtos(req, list));
        });
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        handle(req, resp, () -> {
            TaiKhoan me = requireCustomer(req);
            String[] seg = pathSegments(req);
            if (seg.length != 1 || !"validate".equals(seg[0])) throw notFound("Endpoint không tồn tại.");

            ApiDtos.ValidatePromotionRequest body = readBody(req, ApiDtos.ValidatePromotionRequest.class);
            if (body.code == null || body.code.isBlank()) throw badRequest("Thiếu mã khuyến mãi.");
            if (body.amount == null || body.amount.compareTo(BigDecimal.ZERO) <= 0) {
                throw badRequest("Số tiền phải lớn hơn 0.");
            }
            LocalDate bookingDate = LocalDate.now(CustomerCatalogService.VN_ZONE);
            if (body.bookingDate != null && !body.bookingDate.isBlank()) {
                try {
                    bookingDate = LocalDate.parse(body.bookingDate.trim());
                } catch (RuntimeException e) {
                    throw badRequest("bookingDate phải theo định dạng yyyy-MM-dd.");
                }
            }

            PromotionService.PromotionResult pr = promotionService.validateAndCalculate(
                    body.code, body.amount, body.facilityId, bookingDate, me.getAccountId());

            ApiDtos.ValidatePromotionDto dto = new ApiDtos.ValidatePromotionDto();
            dto.valid = pr.isValid();
            dto.message = pr.getMessage();
            dto.discountAmount = pr.getDiscountAmount();
            dto.finalAmount = pr.getFinalAmount();
            ok(resp, dto);
        });
    }

    private List<ApiDtos.PromotionDto> toDtos(HttpServletRequest req, List<KhuyenMai> list) {
        List<ApiDtos.PromotionDto> out = new ArrayList<>();
        if (list.isEmpty()) return out;
        List<Integer> ids = list.stream().map(KhuyenMai::getKhuyenMaiID).toList();
        Map<Integer, List<KhuyenMaiHinhAnh>> images = khuyenMaiHinhAnhDAO.findByKhuyenMaiIds(ids);
        for (KhuyenMai km : list) {
            List<KhuyenMaiHinhAnh> imgs = images.get(km.getKhuyenMaiID());
            String cover = (imgs == null || imgs.isEmpty()) ? null
                    : PromotionImagePresenter.coverImageUrl(req.getContextPath(), imgs);
            out.add(ApiMappers.promotion(req, km, cover));
        }
        return out;
    }
}
