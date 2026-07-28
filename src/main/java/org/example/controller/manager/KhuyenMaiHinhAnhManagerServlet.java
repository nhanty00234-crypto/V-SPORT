package org.example.controller.manager;

import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.dao.KhuyenMaiDAO;
import org.example.dao.impl.KhuyenMaiDAOImpl;
import org.example.model.KhuyenMai;
import org.example.model.KhuyenMaiHinhAnh;
import org.example.model.TaiKhoan;
import org.example.service.manager.PromotionImageService;
import org.example.util.Constants;
import org.example.util.PromotionUploadPaths;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Collection;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * API quản lý ảnh của một khuyến mãi cho Manager: liệt kê, tải lên, xóa, đặt ảnh bìa, sắp
 * xếp thứ tự. Mọi thao tác đều xác thực khuyenMaiId thuộc CoSoID của Manager đang đăng nhập
 * trước khi chạm vào PromotionImageService - không tin khuyenMaiId từ client.
 */
@WebServlet("/manager/khuyen-mai/hinh-anh")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = PromotionImageService.MAX_FILE_BYTES,
        maxRequestSize = PromotionImageService.MAX_TOTAL_BYTES + 1024 * 1024
)
public class KhuyenMaiHinhAnhManagerServlet extends HttpServlet {

    private static final Logger logger = LogManager.getLogger(KhuyenMaiHinhAnhManagerServlet.class);
    private static final Gson gson = new Gson();

    private final KhuyenMaiDAO khuyenMaiDAO = new KhuyenMaiDAOImpl();
    private final PromotionImageService promotionImageService = new PromotionImageService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        TaiKhoan user = requireManager(req, resp);
        if (user == null) return;

        Integer khuyenMaiId = parsePositiveInt(req.getParameter("khuyenMaiId"));
        if (khuyenMaiId == null) {
            writeJson(resp, 400, error("Thiếu hoặc sai tham số khuyenMaiId."));
            return;
        }
        KhuyenMai km = khuyenMaiDAO.findByIdAndCoSoId(khuyenMaiId, user.getCoSoId());
        if (km == null) {
            writeJson(resp, 404, error("Không tìm thấy khuyến mãi."));
            return;
        }

        List<KhuyenMaiHinhAnh> images = promotionImageService.listImages(khuyenMaiId);
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("success", true);
        result.put("images", toImageDtoList(req, images));
        writeJson(resp, 200, result);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        TaiKhoan user = requireManager(req, resp);
        if (user == null) return;

        String action = req.getParameter("action");
        Integer khuyenMaiId = parsePositiveInt(req.getParameter("khuyenMaiId"));
        if (khuyenMaiId == null) {
            writeJson(resp, 400, error("Thiếu hoặc sai tham số khuyenMaiId."));
            return;
        }
        KhuyenMai km = khuyenMaiDAO.findByIdAndCoSoId(khuyenMaiId, user.getCoSoId());
        if (km == null) {
            writeJson(resp, 404, error("Không tìm thấy khuyến mãi hoặc không thuộc cơ sở của bạn."));
            return;
        }

        try {
            switch (action == null ? "" : action) {
                case "upload":
                    handleUpload(req, resp, khuyenMaiId);
                    return;
                case "delete":
                    handleDelete(req, resp, khuyenMaiId);
                    return;
                case "set-cover":
                    handleSetCover(req, resp, khuyenMaiId);
                    return;
                case "reorder":
                    handleReorder(req, resp, khuyenMaiId);
                    return;
                default:
                    writeJson(resp, 400, error("Hành động không hợp lệ."));
            }
        } catch (PromotionImageService.PromotionImageException e) {
            writeJson(resp, 400, error(e.getMessage()));
        } catch (Exception e) {
            logger.error("KhuyenMaiHinhAnhManagerServlet action={} khuyenMaiId={}: {}", action, khuyenMaiId, e.getMessage(), e);
            writeJson(resp, 500, error("Đã xảy ra lỗi hệ thống. Vui lòng thử lại."));
        }
    }

    private void handleUpload(HttpServletRequest req, HttpServletResponse resp, int khuyenMaiId) throws IOException, ServletException {
        List<PromotionImageService.UploadedImageFile> files = new ArrayList<>();
        Collection<Part> parts = req.getParts();
        for (Part part : parts) {
            if (!"images".equals(part.getName()) && !"image".equals(part.getName())) continue;
            String submittedName = part.getSubmittedFileName();
            if (submittedName == null || submittedName.isBlank() || part.getSize() <= 0) continue;
            byte[] bytes;
            try (InputStream is = part.getInputStream()) {
                bytes = is.readAllBytes();
            }
            files.add(new PromotionImageService.UploadedImageFile(bytes, submittedName));
        }
        if (files.isEmpty()) {
            writeJson(resp, 400, error("Vui lòng chọn ít nhất 1 ảnh."));
            return;
        }
        List<KhuyenMaiHinhAnh> inserted = promotionImageService.addImages(khuyenMaiId, files);
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("success", true);
        result.put("images", toImageDtoList(req, inserted));
        writeJson(resp, 200, result);
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp, int khuyenMaiId) throws IOException {
        Integer hinhAnhId = parsePositiveInt(req.getParameter("hinhAnhId"));
        if (hinhAnhId == null) {
            writeJson(resp, 400, error("Thiếu hoặc sai tham số hinhAnhId."));
            return;
        }
        promotionImageService.deleteImage(khuyenMaiId, hinhAnhId);
        writeJson(resp, 200, Map.of("success", true));
    }

    private void handleSetCover(HttpServletRequest req, HttpServletResponse resp, int khuyenMaiId) throws IOException {
        Integer hinhAnhId = parsePositiveInt(req.getParameter("hinhAnhId"));
        if (hinhAnhId == null) {
            writeJson(resp, 400, error("Thiếu hoặc sai tham số hinhAnhId."));
            return;
        }
        promotionImageService.setCover(khuyenMaiId, hinhAnhId);
        writeJson(resp, 200, Map.of("success", true));
    }

    private void handleReorder(HttpServletRequest req, HttpServletResponse resp, int khuyenMaiId) throws IOException {
        String orderParam = req.getParameter("order");
        if (orderParam == null || orderParam.isBlank()) {
            writeJson(resp, 400, error("Thiếu tham số order (danh sách hinhAnhId cách nhau bởi dấu phẩy)."));
            return;
        }
        List<Integer> order = new ArrayList<>();
        try {
            for (String part : orderParam.split(",")) {
                if (!part.isBlank()) order.add(Integer.parseInt(part.trim()));
            }
        } catch (NumberFormatException e) {
            writeJson(resp, 400, error("Tham số order không hợp lệ."));
            return;
        }
        promotionImageService.reorder(khuyenMaiId, order);
        writeJson(resp, 200, Map.of("success", true));
    }

    private List<Map<String, Object>> toImageDtoList(HttpServletRequest req, List<KhuyenMaiHinhAnh> images) {
        List<Map<String, Object>> list = new ArrayList<>();
        for (KhuyenMaiHinhAnh img : images) {
            Map<String, Object> dto = new LinkedHashMap<>();
            dto.put("hinhAnhId", img.getHinhAnhId());
            dto.put("publicUrl", PromotionUploadPaths.publicUrl(req.getContextPath(), img.getDuongDan()));
            dto.put("tenFileGoc", img.getTenFileGoc());
            dto.put("dungLuong", img.getDungLuong());
            dto.put("chieuRong", img.getChieuRong());
            dto.put("chieuCao", img.getChieuCao());
            dto.put("thuTu", img.getThuTu());
            dto.put("laAnhBia", img.isLaAnhBia());
            list.add(dto);
        }
        return list;
    }

    private TaiKhoan requireManager(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession();
        TaiKhoan user = (TaiKhoan) session.getAttribute("user");
        if (user == null) {
            writeJson(resp, 401, error("Vui lòng đăng nhập."));
            return null;
        }
        if (user.getRoleId() != Constants.ROLE_MANAGER) {
            writeJson(resp, 403, error("Bạn không có quyền thực hiện hành động này."));
            return null;
        }
        if (user.getCoSoId() == null || user.getCoSoId() <= 0) {
            writeJson(resp, 403, error("Tài khoản Manager chưa được gán cơ sở."));
            return null;
        }
        return user;
    }

    private Integer parsePositiveInt(String raw) {
        if (raw == null || raw.isBlank()) return null;
        try {
            int v = Integer.parseInt(raw.trim());
            return v > 0 ? v : null;
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private Map<String, Object> error(String message) {
        return Map.of("success", false, "message", message);
    }

    private void writeJson(HttpServletResponse resp, int status, Object body) throws IOException {
        resp.setStatus(status);
        resp.setContentType("application/json; charset=UTF-8");
        resp.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
        resp.getWriter().write(gson.toJson(body));
    }
}
