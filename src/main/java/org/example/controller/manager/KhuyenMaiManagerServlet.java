package org.example.controller.manager;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
<<<<<<< HEAD
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.model.KhuyenMai;
import org.example.model.TaiKhoan;
import org.example.service.AuditLogService;
import org.example.service.KhuyenMaiService;
import org.example.util.RoleRedirectUtil;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.List;

/**
 * GET  /manager/khuyen-mai          — danh sách CRUD
 * GET  /manager/khuyen-mai?action=form&id=N  — form sửa
 * POST /manager/khuyen-mai?action=create     — tạo mới
 * POST /manager/khuyen-mai?action=update     — cập nhật
 * POST /manager/khuyen-mai?action=delete     — xóa
 *
 * CoSoID lấy từ session Manager, không tin parameter client.
=======
import org.example.dao.KhuyenMaiDAO;
import org.example.dao.impl.KhuyenMaiDAOImpl;
import org.example.model.KhuyenMai;
import org.example.model.TaiKhoan;
import org.example.service.AuditLogService;
import org.example.service.customer.PromotionStatusHelper;
import org.example.util.Constants;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Manager CRUD mã khuyến mãi tại cơ sở của mình. Chỉ thao tác trực tiếp trên bảng
 * KhuyenMai qua KhuyenMaiDAO — không đụng tới PromotionService.calculateDiscount
 * (logic tính giảm giá khi khách áp mã vẫn chỉ có một nơi duy nhất).
>>>>>>> fix/teacher-review-remediation
 */
@WebServlet("/manager/khuyen-mai")
public class KhuyenMaiManagerServlet extends HttpServlet {

<<<<<<< HEAD
    private static final Logger logger = LogManager.getLogger(KhuyenMaiManagerServlet.class);

    private final KhuyenMaiService service = new KhuyenMaiService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        TaiKhoan manager = getAuthenticatedManager(req, resp);
        if (manager == null) return;
        int coSoId = manager.getCoSoId();

        String action = req.getParameter("action");
        if ("form".equals(action)) {
            showForm(req, resp, coSoId);
            return;
        }

        int page = parsePage(req);
        List<KhuyenMai> list = service.list(coSoId, page);
        int total = service.count(coSoId);
        req.setAttribute("khuyenMaiList", list);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalCount", total);
        req.setAttribute("hasMore", list.size() == 20);
        req.getRequestDispatcher("/manager/KhuyenMai.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        TaiKhoan manager = getAuthenticatedManager(req, resp);
        if (manager == null) return;
        int coSoId = manager.getCoSoId();

        String action = req.getParameter("action");
        switch (action != null ? action : "") {
            case "create" -> handleCreate(req, resp, manager, coSoId);
            case "update" -> handleUpdate(req, resp, manager, coSoId);
            case "delete" -> handleDelete(req, resp, manager, coSoId);
            default -> resp.sendRedirect(req.getContextPath() + "/manager/khuyen-mai");
        }
    }

    private void handleCreate(HttpServletRequest req, HttpServletResponse resp,
                               TaiKhoan manager, int coSoId) throws ServletException, IOException {
        String maCode = req.getParameter("maCode");
        String moTa = req.getParameter("moTa");
        String loaiGiam = req.getParameter("loaiGiam");
        double giaTriGiam = parseDouble(req.getParameter("giaTriGiam"));
        LocalDate ngayBatDau = parseDate(req.getParameter("ngayBatDau"));
        LocalDate ngayKetThuc = parseDate(req.getParameter("ngayKetThuc"));
        Integer soLanToiDa = parseIntOrNull(req.getParameter("soLanToiDa"));

        KhuyenMaiService.KmResult result = service.create(coSoId, maCode, moTa, loaiGiam,
                giaTriGiam, ngayBatDau, ngayKetThuc, soLanToiDa);

        if (result.success) {
            AuditLogService.log(req, manager, "CREATE", "KhuyenMai",
                    String.valueOf(result.data.getKhuyenMaiID()), maCode, "Tạo mã khuyến mãi");
            req.getSession().setAttribute("flashSuccess", result.message);
            resp.sendRedirect(req.getContextPath() + "/manager/khuyen-mai");
        } else {
            req.setAttribute("errors", result.errors);
            req.setAttribute("formAction", "create");
            req.setAttribute("km", buildFormBean(req));
            req.getRequestDispatcher("/manager/KhuyenMai.jsp").forward(req, resp);
        }
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp,
                               TaiKhoan manager, int coSoId) throws ServletException, IOException {
        int id = parseIntOrDefault(req.getParameter("khuyenMaiId"), 0);
        if (id <= 0) { resp.sendRedirect(req.getContextPath() + "/manager/khuyen-mai"); return; }

        String maCode = req.getParameter("maCode");
        String moTa = req.getParameter("moTa");
        String loaiGiam = req.getParameter("loaiGiam");
        double giaTriGiam = parseDouble(req.getParameter("giaTriGiam"));
        LocalDate ngayBatDau = parseDate(req.getParameter("ngayBatDau"));
        LocalDate ngayKetThuc = parseDate(req.getParameter("ngayKetThuc"));
        Integer soLanToiDa = parseIntOrNull(req.getParameter("soLanToiDa"));
        String trangThai = req.getParameter("trangThai");

        KhuyenMaiService.KmResult result = service.update(id, coSoId, maCode, moTa, loaiGiam,
                giaTriGiam, ngayBatDau, ngayKetThuc, soLanToiDa, trangThai);

        if (result.success) {
            AuditLogService.log(req, manager, "UPDATE", "KhuyenMai",
                    String.valueOf(id), maCode, "Cập nhật mã khuyến mãi");
            req.getSession().setAttribute("flashSuccess", result.message);
            resp.sendRedirect(req.getContextPath() + "/manager/khuyen-mai");
        } else {
            req.setAttribute("errors", result.errors);
            req.setAttribute("formAction", "update");
            req.setAttribute("km", buildFormBean(req));
            req.setAttribute("kmId", id);
            req.getRequestDispatcher("/manager/KhuyenMai.jsp").forward(req, resp);
        }
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp,
                               TaiKhoan manager, int coSoId) throws IOException {
        int id = parseIntOrDefault(req.getParameter("khuyenMaiId"), 0);
        if (id <= 0) { resp.sendRedirect(req.getContextPath() + "/manager/khuyen-mai"); return; }

        KhuyenMaiService.KmResult result = service.delete(id, coSoId);
        HttpSession session = req.getSession();
        if (result.success) {
            AuditLogService.log(req, manager, "DELETE", "KhuyenMai", String.valueOf(id), "", "Xóa mã khuyến mãi");
            session.setAttribute("flashSuccess", result.message);
        } else {
            session.setAttribute("flashError", result.message);
        }
        resp.sendRedirect(req.getContextPath() + "/manager/khuyen-mai");
    }

    private void showForm(HttpServletRequest req, HttpServletResponse resp, int coSoId)
            throws ServletException, IOException {
        String idStr = req.getParameter("id");
        if (idStr != null && !idStr.isBlank()) {
            int id = parseIntOrDefault(idStr, 0);
            KhuyenMai km = (id > 0) ? service.findById(id, coSoId) : null;
            if (km == null) {
                resp.sendRedirect(req.getContextPath() + "/manager/khuyen-mai");
                return;
            }
            req.setAttribute("km", km);
            req.setAttribute("formAction", "update");
        } else {
            req.setAttribute("formAction", "create");
        }
        req.getRequestDispatcher("/manager/KhuyenMai.jsp").forward(req, resp);
    }

    private TaiKhoan getAuthenticatedManager(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        TaiKhoan user = session != null ? (TaiKhoan) session.getAttribute("user") : null;
        if (user == null) {
            resp.sendRedirect(RoleRedirectUtil.buildLoginRedirect(req.getContextPath(),
                    req.getRequestURI() + (req.getQueryString() != null ? "?" + req.getQueryString() : "")));
            return null;
        }
        if (user.getRoleId() != RoleRedirectUtil.ROLE_MANAGER) {
            try { resp.sendError(HttpServletResponse.SC_FORBIDDEN); } catch (Exception ignored) {}
            return null;
        }
        if (user.getCoSoId() == null) {
            try { resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Tài khoản Manager chưa được gán cơ sở."); } catch (Exception ignored) {}
            return null;
        }
        return user;
    }

    // -----------------------------------------------------------------------
    // Helpers
    // -----------------------------------------------------------------------

    private KhuyenMai buildFormBean(HttpServletRequest req) {
        KhuyenMai km = new KhuyenMai();
        km.setMaCode(req.getParameter("maCode"));
        km.setMoTa(req.getParameter("moTa"));
        km.setLoaiGiam(req.getParameter("loaiGiam"));
        km.setGiaTriGiam(parseDouble(req.getParameter("giaTriGiam")));
        km.setNgayBatDau(parseDate(req.getParameter("ngayBatDau")));
        km.setNgayKetThuc(parseDate(req.getParameter("ngayKetThuc")));
        km.setSoLanToiDa(parseIntOrNull(req.getParameter("soLanToiDa")));
        int idV = parseIntOrDefault(req.getParameter("khuyenMaiId"), 0);
        if (idV > 0) km.setKhuyenMaiID(idV);
        return km;
    }

    private int parsePage(HttpServletRequest req) {
        try {
            int p = Integer.parseInt(req.getParameter("page"));
            return Math.max(1, p);
        } catch (Exception e) { return 1; }
    }

    private LocalDate parseDate(String s) {
        if (s == null || s.isBlank()) return null;
        try { return LocalDate.parse(s.trim()); } catch (DateTimeParseException e) { return null; }
    }

    private double parseDouble(String s) {
        if (s == null || s.isBlank()) return 0;
        try { return Double.parseDouble(s.trim().replace(",", ".")); } catch (NumberFormatException e) { return 0; }
    }

    private Integer parseIntOrNull(String s) {
        if (s == null || s.isBlank()) return null;
        try { return Integer.parseInt(s.trim()); } catch (NumberFormatException e) { return null; }
    }

    private int parseIntOrDefault(String s, int def) {
        if (s == null || s.isBlank()) return def;
        try { return Integer.parseInt(s.trim()); } catch (NumberFormatException e) { return def; }
=======
    private final KhuyenMaiDAO khuyenMaiDAO = new KhuyenMaiDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        TaiKhoan user = (TaiKhoan) session.getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/he-thong/dang-nhap");
            return;
        }
        if (user.getRoleId() != Constants.ROLE_MANAGER) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập chức năng này.");
            return;
        }

        int coSoId = user.getCoSoId();
        List<KhuyenMai> all = khuyenMaiDAO.findByCoSoId(coSoId);

        String keyword = trim(req.getParameter("q"));
        String statusFilter = req.getParameter("status");
        if (statusFilter == null || statusFilter.isBlank()) statusFilter = "ALL";

        int countActive = 0, countUpcoming = 0, countExpired = 0, totalUsage = 0;
        List<KhuyenMai> filtered = new ArrayList<>();
        Map<Integer, String> displayStatusById = new LinkedHashMap<>();
        for (KhuyenMai km : all) {
            String displayStatus = PromotionStatusHelper.displayStatus(km);
            displayStatusById.put(km.getKhuyenMaiID(), displayStatus);
            totalUsage += km.getSoLanDaDung();
            switch (displayStatus) {
                case PromotionStatusHelper.DANG_HOAT_DONG: countActive++; break;
                case PromotionStatusHelper.SAP_DIEN_RA: countUpcoming++; break;
                case PromotionStatusHelper.DA_HET_HAN: countExpired++; break;
                default: break;
            }

            boolean matchesKeyword = keyword == null || keyword.isEmpty()
                    || (km.getMaCode() != null && km.getMaCode().toLowerCase().contains(keyword.toLowerCase()))
                    || (km.getMoTa() != null && km.getMoTa().toLowerCase().contains(keyword.toLowerCase()));

            boolean matchesStatus = "ALL".equals(statusFilter) || statusFilter.equals(statusToCode(displayStatus));

            if (matchesKeyword && matchesStatus) filtered.add(km);
        }

        String successMsg = (String) session.getAttribute("successMsg");
        String errorMsg = (String) session.getAttribute("errorMsg");
        session.removeAttribute("successMsg");
        session.removeAttribute("errorMsg");

        String editIdParam = req.getParameter("edit");
        KhuyenMai editing = null;
        if (editIdParam != null && !editIdParam.isBlank()) {
            try {
                editing = khuyenMaiDAO.findByIdAndCoSoId(Integer.parseInt(editIdParam.trim()), coSoId);
            } catch (NumberFormatException ignored) {
            }
        }

        req.setAttribute("promotions", filtered);
        req.setAttribute("kmDisplayStatus", displayStatusById);
        req.setAttribute("countActive", countActive);
        req.setAttribute("countUpcoming", countUpcoming);
        req.setAttribute("countExpired", countExpired);
        req.setAttribute("totalUsage", totalUsage);
        req.setAttribute("keyword", keyword == null ? "" : keyword);
        req.setAttribute("statusFilter", statusFilter);
        req.setAttribute("editing", editing);
        req.setAttribute("successMsg", successMsg);
        req.setAttribute("errorMsg", errorMsg);
        req.setAttribute("pageTitle", "Quản lý mã khuyến mãi");
        req.getRequestDispatcher("/manager/KhuyenMai.jsp").forward(req, resp);
    }

    private String statusToCode(String displayStatus) {
        if (PromotionStatusHelper.DANG_HOAT_DONG.equals(displayStatus)) return "ACTIVE";
        if (PromotionStatusHelper.SAP_DIEN_RA.equals(displayStatus)) return "UPCOMING";
        if (PromotionStatusHelper.DA_HET_HAN.equals(displayStatus)) return "EXPIRED";
        if (PromotionStatusHelper.TAM_KHOA.equals(displayStatus)) return "LOCKED";
        if (PromotionStatusHelper.HET_LUOT.equals(displayStatus)) return "EXHAUSTED";
        return "ALL";
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        TaiKhoan user = (TaiKhoan) session.getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/he-thong/dang-nhap");
            return;
        }
        if (user.getRoleId() != Constants.ROLE_MANAGER) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền thực hiện hành động này.");
            return;
        }

        int coSoId = user.getCoSoId();
        String action = req.getParameter("action");

        try {
            switch (action == null ? "" : action) {
                case "create":
                    handleCreate(req, session, user, coSoId);
                    break;
                case "update":
                    handleUpdate(req, session, user, coSoId);
                    break;
                case "toggle":
                    handleToggle(req, session, coSoId);
                    break;
                default:
                    session.setAttribute("errorMsg", "Hành động không hợp lệ.");
            }
        } catch (NumberFormatException e) {
            session.setAttribute("errorMsg", "Dữ liệu số không hợp lệ.");
        } catch (Exception e) {
            session.setAttribute("errorMsg", "Đã xảy ra lỗi hệ thống. Vui lòng thử lại.");
        }

        resp.sendRedirect(req.getContextPath() + "/manager/khuyen-mai");
    }

    private String validateForm(HttpServletRequest req, int coSoId, Integer excludeId) {
        String maCode = trim(req.getParameter("maCode"));
        String loaiGiam = trim(req.getParameter("loaiGiam"));
        String giaTriGiamStr = trim(req.getParameter("giaTriGiam"));
        String ngayBatDauStr = trim(req.getParameter("ngayBatDau"));
        String ngayKetThucStr = trim(req.getParameter("ngayKetThuc"));

        if (maCode == null || maCode.isEmpty()) return "Vui lòng nhập mã khuyến mãi.";
        if (!maCode.matches("^[A-Z0-9_-]{3,50}$")) return "Mã khuyến mãi chỉ gồm chữ in hoa, số, gạch nối, tối đa 50 ký tự.";
        if (khuyenMaiDAO.existsByCode(maCode, excludeId)) return "Mã khuyến mãi '" + maCode + "' đã tồn tại.";
        if (loaiGiam == null || (!loaiGiam.equals("PERCENT") && !loaiGiam.equals("FIXED"))) return "Vui lòng chọn hình thức giảm.";

        double giaTriGiam;
        try {
            giaTriGiam = Double.parseDouble(giaTriGiamStr);
        } catch (Exception e) {
            return "Giá trị giảm không hợp lệ.";
        }
        if (giaTriGiam <= 0) return "Giá trị giảm phải lớn hơn 0.";
        if ("PERCENT".equals(loaiGiam) && giaTriGiam > 100) return "Phần trăm giảm không được vượt quá 100.";

        LocalDate ngayBatDau, ngayKetThuc;
        try {
            ngayBatDau = LocalDate.parse(ngayBatDauStr);
            ngayKetThuc = LocalDate.parse(ngayKetThucStr);
        } catch (Exception e) {
            return "Vui lòng nhập đầy đủ ngày bắt đầu và ngày kết thúc.";
        }
        if (ngayKetThuc.isBefore(ngayBatDau)) return "Ngày kết thúc phải sau ngày bắt đầu.";

        String soLanToiDaStr = trim(req.getParameter("soLanToiDa"));
        if (soLanToiDaStr != null && !soLanToiDaStr.isEmpty()) {
            try {
                int soLanToiDa = Integer.parseInt(soLanToiDaStr);
                if (soLanToiDa <= 0) return "Tổng lượt sử dụng phải lớn hơn 0.";
            } catch (Exception e) {
                return "Tổng lượt sử dụng không hợp lệ.";
            }
        }

        String giaTriToiThieuStr = trim(req.getParameter("giaTriToiThieu"));
        if (giaTriToiThieuStr != null && !giaTriToiThieuStr.isEmpty()) {
            try {
                if (new BigDecimal(giaTriToiThieuStr).signum() < 0) return "Giá trị đơn tối thiểu không được âm.";
            } catch (Exception e) {
                return "Giá trị đơn tối thiểu không hợp lệ.";
            }
        }

        String giamToiDaStr = trim(req.getParameter("giamToiDa"));
        if (giamToiDaStr != null && !giamToiDaStr.isEmpty()) {
            try {
                if (new BigDecimal(giamToiDaStr).signum() < 0) return "Mức giảm tối đa không được âm.";
            } catch (Exception e) {
                return "Mức giảm tối đa không hợp lệ.";
            }
        }

        return null;
    }

    private KhuyenMai buildFromRequest(HttpServletRequest req) {
        KhuyenMai km = new KhuyenMai();
        km.setMaCode(trim(req.getParameter("maCode")).toUpperCase());
        km.setMoTa(trim(req.getParameter("moTa")));
        km.setLoaiGiam(trim(req.getParameter("loaiGiam")));
        km.setGiaTriGiam(Double.parseDouble(trim(req.getParameter("giaTriGiam"))));
        km.setNgayBatDau(LocalDate.parse(trim(req.getParameter("ngayBatDau"))));
        km.setNgayKetThuc(LocalDate.parse(trim(req.getParameter("ngayKetThuc"))));
        String soLanToiDaStr = trim(req.getParameter("soLanToiDa"));
        km.setSoLanToiDa(soLanToiDaStr != null && !soLanToiDaStr.isEmpty() ? Integer.parseInt(soLanToiDaStr) : null);
        String giaTriToiThieuStr = trim(req.getParameter("giaTriToiThieu"));
        km.setGiaTriToiThieu(giaTriToiThieuStr != null && !giaTriToiThieuStr.isEmpty() ? new BigDecimal(giaTriToiThieuStr) : null);
        String giamToiDaStr = trim(req.getParameter("giamToiDa"));
        km.setGiamToiDa(giamToiDaStr != null && !giamToiDaStr.isEmpty() ? new BigDecimal(giamToiDaStr) : null);
        km.setTrangThai("on".equals(req.getParameter("trangThaiHoatDong")) || "true".equals(req.getParameter("trangThaiHoatDong"))
                ? Constants.TRANG_THAI_KM_HOAT_DONG : Constants.TRANG_THAI_KM_TAM_DUNG);
        return km;
    }

    private void handleCreate(HttpServletRequest req, HttpSession session, TaiKhoan user, int coSoId) {
        String validationError = validateForm(req, coSoId, null);
        if (validationError != null) {
            session.setAttribute("errorMsg", validationError);
            return;
        }
        KhuyenMai km = buildFromRequest(req);
        km.setCoSoID(coSoId);
        int newId = khuyenMaiDAO.insert(km);
        if (newId > 0) {
            session.setAttribute("successMsg", "Đã tạo mã khuyến mãi '" + km.getMaCode() + "'.");
            AuditLogService.log(req, user, AuditLogService.ACTION_CREATE, "KhuyenMai",
                    String.valueOf(newId), km.getMaCode(), "Manager tạo mã khuyến mãi");
        } else {
            session.setAttribute("errorMsg", "Không thể tạo mã khuyến mãi. Vui lòng thử lại.");
        }
    }

    private void handleUpdate(HttpServletRequest req, HttpSession session, TaiKhoan user, int coSoId) {
        int id = Integer.parseInt(req.getParameter("khuyenMaiId"));
        KhuyenMai existing = khuyenMaiDAO.findByIdAndCoSoId(id, coSoId);
        if (existing == null) {
            session.setAttribute("errorMsg", "Không tìm thấy mã khuyến mãi.");
            return;
        }
        String validationError = validateForm(req, coSoId, id);
        if (validationError != null) {
            session.setAttribute("errorMsg", validationError);
            return;
        }
        KhuyenMai km = buildFromRequest(req);
        km.setKhuyenMaiID(id);
        km.setCoSoID(coSoId);
        boolean ok = khuyenMaiDAO.update(km, coSoId);
        if (ok) {
            session.setAttribute("successMsg", "Đã cập nhật mã khuyến mãi '" + km.getMaCode() + "'.");
            AuditLogService.log(req, user, AuditLogService.ACTION_UPDATE, "KhuyenMai",
                    String.valueOf(id), km.getMaCode(), "Manager cập nhật mã khuyến mãi");
        } else {
            session.setAttribute("errorMsg", "Không thể cập nhật mã khuyến mãi. Vui lòng thử lại.");
        }
    }

    private void handleToggle(HttpServletRequest req, HttpSession session, int coSoId) {
        int id = Integer.parseInt(req.getParameter("khuyenMaiId"));
        boolean activate = "1".equals(req.getParameter("value"));
        String trangThai = activate ? Constants.TRANG_THAI_KM_HOAT_DONG : Constants.TRANG_THAI_KM_TAM_DUNG;
        boolean ok = khuyenMaiDAO.updateTrangThai(id, coSoId, trangThai);
        if (ok) {
            session.setAttribute("successMsg", activate ? "Đã bật mã khuyến mãi." : "Đã tạm khóa mã khuyến mãi.");
        } else {
            session.setAttribute("errorMsg", "Không thể cập nhật trạng thái mã khuyến mãi.");
        }
    }

    private static String trim(String s) {
        return s == null ? null : s.trim();
>>>>>>> fix/teacher-review-remediation
    }
}
