package org.example.controller.manager;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import com.google.gson.Gson;
import org.example.model.Hoantien;
import org.example.model.TaiKhoan;
import org.example.service.RefundService;
import org.example.util.RefundStatus;
import org.example.util.RoleRedirectUtil;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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
    private final Gson gson = new Gson();

    private static final List<String> PROCESSED_STATUSES = List.of(
            RefundStatus.DA_DUYET, RefundStatus.DANG_HOAN_TIEN, RefundStatus.DA_HOAN_TIEN, RefundStatus.TU_CHOI);

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        TaiKhoan manager = requireManager(req, resp);
        if (manager == null) return;
        int coSoId = getCoSoId(manager);
        if (coSoId <= 0) { resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Tài khoản chưa được gán cơ sở."); return; }

        if ("json-history".equals(req.getParameter("format"))) {
            handleHistoryJson(req, resp, coSoId);
            return;
        }

        int page = Math.max(1, parseIntSafe(req.getParameter("page"), 1));
        String trangThaiFilter = sanitize(req.getParameter("trangThai"));
        boolean validFilter = trangThaiFilter != null && org.example.util.RefundStatus.isValid(trangThaiFilter);

        req.setAttribute("danhSachHoanTien", validFilter
                ? refundService.getByCoSoAndTrangThai(coSoId, trangThaiFilter, page)
                : refundService.getByCoSo(coSoId, page));
        req.setAttribute("page", page);
        req.setAttribute("coSoId", coSoId);
        req.setAttribute("trangThaiFilter", validFilter ? trangThaiFilter : "");
        req.getRequestDispatcher("/manager/HoanTien.jsp").forward(req, resp);
    }

    /** Trả JSON danh sách yêu cầu đã xử lý (Đã duyệt/Đang CK/Đã hoàn tiền/Từ chối) để tab Lịch sử xử lý polling real-time. */
    private void handleHistoryJson(HttpServletRequest req, HttpServletResponse resp, int coSoId) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        SimpleDateFormat fmt = new SimpleDateFormat("dd/MM/yyyy HH:mm");

        List<Hoantien> all = refundService.getByCoSo(coSoId, 1);
        List<Map<String, Object>> rows = new ArrayList<>();
        for (Hoantien ht : all) {
            if (!PROCESSED_STATUSES.contains(ht.getTrangThai())) continue;
            Map<String, Object> row = new HashMap<>();
            row.put("hoanTienId", ht.getHoanTienId());
            row.put("datSanId", ht.getDatSanId());
            row.put("trangThai", ht.getTrangThai());
            row.put("soTienDeNghiHoan", ht.getSoTienDeNghiHoan());
            row.put("soTienDuocDuyet", ht.getSoTienDuocDuyet());
            row.put("lyDoTuChoi", ht.getLyDoTuChoi());
            row.put("ghiChuXuLy", ht.getGhiChuXuLy());
            row.put("maGiaoDichHoan", ht.getMaGiaoDichHoan());
            row.put("approvedAt", ht.getApprovedAt() != null ? fmt.format(ht.getApprovedAt()) : null);
            row.put("completedAt", ht.getCompletedAt() != null ? fmt.format(ht.getCompletedAt()) : null);
            row.put("updatedAt", ht.getUpdatedAt() != null ? fmt.format(ht.getUpdatedAt()) : null);
            rows.add(row);
        }
        resp.getWriter().write(gson.toJson(Map.of("success", true, "rows", rows)));
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        TaiKhoan manager = requireManager(req, resp);
        if (manager == null) return;
        int coSoId = getCoSoId(manager);
        if (coSoId <= 0) { resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Tài khoản chưa được gán cơ sở."); return; }

        String action = req.getParameter("action");
        int hoanTienId = parseIntSafe(req.getParameter("hoanTienId"), 0);
        if (hoanTienId <= 0) {
            resp.sendRedirect(req.getContextPath() + "/manager/hoan-tien?error=invalid");
            return;
        }

        // Ownership: mọi action bên dưới đều tự kiểm tra findByIdAndCoSoId — không thao tác
        // được lên refund không thuộc CoSoID của Manager (chống IDOR ở tầng SQL, không chỉ JSP).
        RefundService.RefundResult result;
        switch (action != null ? action : "") {
            case "request-more-info": {
                String ghiChu = sanitize(req.getParameter("ghiChu"));
                result = refundService.requestMoreInfo(hoanTienId, coSoId, manager.getAccountId(), ghiChu, req);
                break;
            }
            case "approve": {
                String ghiChu = sanitize(req.getParameter("ghiChu"));
                java.math.BigDecimal soTienDuyet = parseAmountSafe(req.getParameter("soTienDuocDuyet"));
                if (soTienDuyet == null) {
                    resp.sendRedirect(req.getContextPath() + "/manager/hoan-tien?error=invalid_amount");
                    return;
                }
                result = refundService.approve(hoanTienId, coSoId, manager.getAccountId(), soTienDuyet, ghiChu, req);
                break;
            }
            case "reject": {
                String lyDo = sanitize(req.getParameter("lyDo"));
                result = refundService.reject(hoanTienId, coSoId, manager.getAccountId(), lyDo, req);
                break;
            }
            case "start-processing": {
                result = refundService.startProcessing(hoanTienId, coSoId, manager.getAccountId(), req);
                break;
            }
            case "complete": {
                String maGiaoDich = sanitize(req.getParameter("maGiaoDich"));
                String ghiChu = sanitize(req.getParameter("ghiChu"));
                result = refundService.confirmCompleted(hoanTienId, coSoId, manager.getAccountId(),
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

    /** CoSoID luôn từ tài khoản Manager đã đăng nhập (TaiKhoan.CoSoID), không tin request parameter. */
    private int getCoSoId(TaiKhoan manager) {
        Integer coSoId = manager.getCoSoId();
        return coSoId != null ? coSoId : 0;
    }

    private static int parseIntSafe(String s, int def) {
        if (s == null || s.isBlank()) return def;
        try { return Integer.parseInt(s.trim()); } catch (NumberFormatException e) { return def; }
    }

    private static java.math.BigDecimal parseAmountSafe(String s) {
        if (s == null || s.isBlank()) return null;
        try {
            java.math.BigDecimal v = new java.math.BigDecimal(s.trim());
            return v.signum() > 0 ? v : null;
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private static String sanitize(String s) {
        return (s != null) ? s.trim() : null;
    }

    private static String encodeParam(String s) {
        if (s == null) return "";
        try { return java.net.URLEncoder.encode(s, "UTF-8"); } catch (Exception e) { return ""; }
    }
}
