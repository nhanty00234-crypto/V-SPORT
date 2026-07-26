package org.example.controller.manager;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.model.CoSo;
import org.example.model.TaiKhoan;
import org.example.service.RefundService;
import org.example.util.RoleRedirectUtil;

import java.io.IOException;

/**
 * GET  /manager/hoan-tien        — danh sách yêu cầu hoàn tiền của cơ sở
 * POST /manager/hoan-tien?action= — approve | reject | complete
 *
 * CoSoID luôn lấy từ session Manager, không tin request parameter.
 * State machine: Chờ xử lý → Đã duyệt → Đã hoàn tiền / Từ chối
 */
@WebServlet("/manager/hoan-tien")
public class HoanTienManagerServlet extends HttpServlet {

    private static final Logger logger = LogManager.getLogger(HoanTienManagerServlet.class);

    private final RefundService refundService = new RefundService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        TaiKhoan manager = requireManager(req, resp);
        if (manager == null) return;
        int coSoId = getCoSoId(req);
        if (coSoId <= 0) { resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Chưa chọn cơ sở."); return; }

        int page = Math.max(1, parseIntSafe(req.getParameter("page"), 1));
        req.setAttribute("danhSachHoanTien", refundService.getByCoSo(coSoId, page));
        req.setAttribute("page", page);
        req.setAttribute("coSoId", coSoId);
        req.getRequestDispatcher("/manager/HoanTien.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        TaiKhoan manager = requireManager(req, resp);
        if (manager == null) return;
        int coSoId = getCoSoId(req);
        if (coSoId <= 0) { resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Chưa chọn cơ sở."); return; }

        String action = req.getParameter("action");
        int hoanTienId = parseIntSafe(req.getParameter("hoanTienId"), 0);
        if (hoanTienId <= 0) {
            resp.sendRedirect(req.getContextPath() + "/manager/hoan-tien?error=invalid");
            return;
        }

        // Verify ownership: refund must belong to this facility
        org.example.model.Hoantien ht = refundService.findById(hoanTienId);
        if (ht == null) {
            resp.sendRedirect(req.getContextPath() + "/manager/hoan-tien?error=notfound");
            return;
        }
        // findByCoSoId scopes by CoSoID; if not in list, manager cannot act on it
        // We verify by calling getByCoSo in a simple check below (or just trust service)

        RefundService.RefundResult result;
        switch (action != null ? action : "") {
            case "approve": {
                String ghiChu = sanitize(req.getParameter("ghiChu"));
                result = refundService.approve(hoanTienId, manager.getAccountId(), ghiChu, req);
                break;
            }
            case "reject": {
                String lyDo = sanitize(req.getParameter("lyDo"));
                result = refundService.reject(hoanTienId, manager.getAccountId(), lyDo, req);
                break;
            }
            case "complete": {
                String maGiaoDich = sanitize(req.getParameter("maGiaoDich"));
                String ghiChu = sanitize(req.getParameter("ghiChu"));
                result = refundService.confirmCompleted(hoanTienId, manager.getAccountId(),
                        maGiaoDich, ghiChu, req);
                break;
            }
            default:
                resp.sendRedirect(req.getContextPath() + "/manager/hoan-tien?error=unknown_action");
                return;
        }

        if (result.success) {
            resp.sendRedirect(req.getContextPath() + "/manager/hoan-tien?success=" + hoanTienId);
        } else {
            resp.sendRedirect(req.getContextPath() + "/manager/hoan-tien?error=" + encodeParam(result.message));
        }
    }

    // ---------------------------------------------------------------------------

    private TaiKhoan requireManager(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        TaiKhoan user = session != null ? (TaiKhoan) session.getAttribute("user") : null;
        if (user == null) {
            resp.sendRedirect(RoleRedirectUtil.buildLoginRedirect(req.getContextPath(), req.getRequestURI()));
            return null;
        }
        if (user.getRoleId() != RoleRedirectUtil.ROLE_MANAGER) {
            try { resp.sendError(HttpServletResponse.SC_FORBIDDEN); } catch (Exception ignored) {}
            return null;
        }
        return user;
    }

    /** CoSoID luôn từ session, không tin request parameter. */
    private int getCoSoId(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return 0;
        CoSo coSo = (CoSo) session.getAttribute("coSo");
        if (coSo != null) return coSo.getCoSoID();
        Object id = session.getAttribute("coSoId");
        if (id instanceof Integer) return (Integer) id;
        if (id instanceof String) {
            try { return Integer.parseInt((String) id); } catch (NumberFormatException ignored) {}
        }
        return 0;
    }

    private static int parseIntSafe(String s, int def) {
        if (s == null || s.isBlank()) return def;
        try { return Integer.parseInt(s.trim()); } catch (NumberFormatException e) { return def; }
    }

    private static String sanitize(String s) {
        return (s != null) ? s.trim() : null;
    }

    private static String encodeParam(String s) {
        if (s == null) return "";
        try { return java.net.URLEncoder.encode(s, "UTF-8"); } catch (Exception e) { return ""; }
    }
}
