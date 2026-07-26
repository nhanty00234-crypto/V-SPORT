package org.example.controller.manager;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
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
 */
@WebServlet("/manager/khuyen-mai")
public class KhuyenMaiManagerServlet extends HttpServlet {

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
    }
}
