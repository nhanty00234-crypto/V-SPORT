package org.example.controller;

import org.example.model.TaiKhoan;
import org.example.model.YeuCauNghi;
import org.example.service.YeuCauNghiService;



import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

/**
 * Servlet quản lý yêu cầu nghỉ dành cho Manager
 * Cho phép xem, duyệt, từ chối yêu cầu nghỉ của nhân viên
 */
@WebServlet("/manager/yeu-cau-nghi")
public class YeuCauNghiManagerServlet extends HttpServlet {

    private static final Logger logger = LogManager.getLogger(YeuCauNghiManagerServlet.class);

    private final YeuCauNghiService yeuCauNghiService;

    public YeuCauNghiManagerServlet() {
        this.yeuCauNghiService = new YeuCauNghiService();
    }

    public YeuCauNghiManagerServlet(YeuCauNghiService yeuCauNghiService) {
        this.yeuCauNghiService = yeuCauNghiService;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession();

        TaiKhoan manager = (TaiKhoan) session.getAttribute("user");
        if (!isAuthorizedManager(manager, req, resp, session)) {
            return;
        }

        Integer managerCoSoId = manager.getCoSoId();
        if (managerCoSoId == null) {
            session.setAttribute("error", "Không tìm thấy thông tin cơ sở của quản lý. Vui lòng đăng nhập lại.");
            try {
                req.getRequestDispatcher("/dangnhap").forward(req, resp);
            } catch (Exception e) {
                throw new ServletException("Forward to login failed", e);
            }
            return;
        }

        try {
            // Lấy parameter filter
            String status = req.getParameter("status");
            List<YeuCauNghi> allRequests = yeuCauNghiService.getYeuCauNghiByCoSo(managerCoSoId, status);

            // Check if JSON format requested (for AJAX)
            String format = req.getParameter("format");
            if ("json".equals(format)) {
                resp.setContentType("application/json");
                resp.setCharacterEncoding("UTF-8");
                String json = buildYeuCauNghiJson(allRequests);
                resp.getWriter().write(json);
                return;
            }

            resp.sendRedirect(req.getContextPath() + "/manager/nhan-su?tab=leave");
        } catch (Exception e) {
            logger.error("Error in YeuCauNghiManagerServlet doGet: {}", e.getMessage(), e);
            session.setAttribute("error", "Lỗi khi tải dữ liệu: " + e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/manager/nhan-su?tab=leave");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession();

        TaiKhoan manager = (TaiKhoan) session.getAttribute("user");
        if (!isAuthorizedManager(manager, req, resp, session)) {
            return;
        }

        Integer managerCoSoId = manager.getCoSoId();
        if (managerCoSoId == null) {
            boolean isJson = "json".equals(req.getParameter("format"));
            if (isJson) {
                resp.setContentType("application/json");
                resp.setCharacterEncoding("UTF-8");
                resp.getWriter().write("{\"success\":false,\"error\":\"Tài khoản quản lý chưa được liên kết với cơ sở nào.\"}");
            } else {
                session.setAttribute("error", "Tài khoản quản lý chưa được liên kết với cơ sở nào.");
                resp.sendRedirect(req.getContextPath() + "/manager/nhan-su?tab=leave");
            }
            return;
        }

        String action = req.getParameter("action");
        String yeuCauNghiIdStr = req.getParameter("id");
        String ghiChu = req.getParameter("ghiChu");
        boolean isJson = "json".equals(req.getParameter("format"));

        if (yeuCauNghiIdStr == null || yeuCauNghiIdStr.isEmpty()) {
            if (isJson) {
                resp.setContentType("application/json");
                resp.setCharacterEncoding("UTF-8");
                resp.getWriter().write("{\"success\":false,\"error\":\"Thiếu thông tin yêu cầu nghỉ\"}");
            } else {
                session.setAttribute("error", "Thiếu thông tin yêu cầu nghỉ");
                resp.sendRedirect(req.getContextPath() + "/manager/nhan-su?tab=leave");
            }
            return;
        }

        try {
            int yeuCauNghiID = Integer.parseInt(yeuCauNghiIdStr);
            int managerID = manager.getAccountId();
            String successMsg = null;
            String errorMsg = null;

            if ("approve".equals(action)) {
                boolean success = yeuCauNghiService.approveYeuCauNghi(yeuCauNghiID, managerID, ghiChu);
                if (success) {
                    successMsg = "Đã phê duyệt yêu cầu nghỉ";
                } else {
                    errorMsg = "Không thể phê duyệt yêu cầu";
                }
            } else if ("reject".equals(action)) {
                boolean success = yeuCauNghiService.rejectYeuCauNghi(yeuCauNghiID, managerID, ghiChu);
                if (success) {
                    successMsg = "Đã từ chối yêu cầu nghỉ";
                } else {
                    errorMsg = "Không thể từ chối yêu cầu";
                }
            } else {
                errorMsg = "Hành động không hợp lệ";
            }

            if (isJson) {
                resp.setContentType("application/json");
                resp.setCharacterEncoding("UTF-8");
                if (errorMsg != null) {
                    resp.getWriter().write("{\"success\":false,\"error\":\"" + escapeJson(errorMsg) + "\"}");
                } else {
                    resp.getWriter().write("{\"success\":true,\"message\":\"" + escapeJson(successMsg) + "\"}");
                }
            } else {
                if (errorMsg != null) {
                    session.setAttribute("error", errorMsg);
                } else {
                    session.setAttribute("message", successMsg);
                }
                resp.sendRedirect(req.getContextPath() + "/manager/nhan-su?tab=leave");
            }

        } catch (NumberFormatException e) {
            logger.error("Invalid ID format: {}", yeuCauNghiIdStr, e);
            if (isJson) {
                resp.setContentType("application/json");
                resp.setCharacterEncoding("UTF-8");
                resp.getWriter().write("{\"success\":false,\"error\":\"ID yêu cầu không hợp lệ\"}");
            } else {
                session.setAttribute("error", "ID yêu cầu không hợp lệ");
                resp.sendRedirect(req.getContextPath() + "/manager/nhan-su?tab=leave");
            }
        } catch (IllegalArgumentException e) {
            logger.error("Validation error: {}", e.getMessage(), e);
            if (isJson) {
                resp.setContentType("application/json");
                resp.setCharacterEncoding("UTF-8");
                resp.getWriter().write("{\"success\":false,\"error\":\"" + escapeJson(e.getMessage()) + "\"}");
            } else {
                session.setAttribute("error", e.getMessage());
                resp.sendRedirect(req.getContextPath() + "/manager/nhan-su?tab=leave");
            }
        } catch (Exception e) {
            logger.error("Unexpected error in YeuCauNghiManagerServlet doPost: {}", e.getMessage(), e);
            if (isJson) {
                resp.setContentType("application/json");
                resp.setCharacterEncoding("UTF-8");
                resp.getWriter().write("{\"success\":false,\"error\":\"Lỗi hệ thống: " + escapeJson(e.getMessage()) + "\"}");
            } else {
                session.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
                resp.sendRedirect(req.getContextPath() + "/manager/nhan-su?tab=leave");
            }
        }
    }

    /**
     * Kiểm tra xem user có quyền truy cập trang Manager không
     */
    private boolean isAuthorizedManager(TaiKhoan user, HttpServletRequest req, HttpServletResponse resp, HttpSession session)
            throws IOException {
        if (user == null) {
            session.setAttribute("error", "Vui lòng đăng nhập để tiếp tục");
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return false;
        }

        int roleId = user.getRoleId();
        // Admin (1) và Manager (2) đều có thể truy cập
        if (roleId != 1 && roleId != 2) {
            logger.warn("Unauthorized access attempt by user ID: {}, role: {}", user.getAccountId(), roleId);
            session.setAttribute("error", "Bạn không có quyền truy cập trang này");
            resp.sendRedirect(req.getContextPath() + "/home");
            return false;
        }

        // Nếu là Manager, kiểm tra coSoId
        if (roleId == 2 && user.getCoSoId() == null) {
            logger.warn("Manager without CoSoID: {}", user.getAccountId());
            session.setAttribute("error", "Tài khoản quản lý chưa được liên kết với cơ sở nào");
            resp.sendRedirect(req.getContextPath() + "/home");
            return false;
        }

        return true;
    }

    // ==================== JSON HELPER ====================

    private String buildYeuCauNghiJson(List<YeuCauNghi> requests) throws Exception {
        StringBuilder json = new StringBuilder();
        json.append("[");

        for (int i = 0; i < requests.size(); i++) {
            YeuCauNghi r = requests.get(i);
            if (i > 0) json.append(",");
            json.append("{");
            json.append("\"yeuCauNghiID\":").append(r.getYeuCauNghiID()).append(",");
            json.append("\"accountId\":").append(r.getAccountID()).append(",");
            json.append("\"tenNhanVien\":\"").append(escapeJson(r.getTenNhanVien() != null ? r.getTenNhanVien() : "")).append("\",");
            json.append("\"username\":\"").append(escapeJson(r.getUsername() != null ? r.getUsername() : "")).append("\",");
            json.append("\"roleName\":\"").append(escapeJson(r.getRoleName() != null ? r.getRoleName() : "")).append("\",");
            json.append("\"ngayNghi\":\"").append(r.getNgayNghi()).append("\",");
            json.append("\"loaiNghi\":\"").append(escapeJson(r.getLoaiNghi())).append("\",");
            json.append("\"lyDo\":\"").append(escapeJson(r.getLyDo())).append("\",");
            json.append("\"trangThai\":\"").append(escapeJson(r.getTrangThai())).append("\",");
            json.append("\"ngayGui\":\"").append(r.getNgayGui()).append("\"");
            json.append("}");
        }

        json.append("]");
        return json.toString();
    }

    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\")
                    .replace("\"", "\\\"")
                    .replace("\n", "\\n")
                    .replace("\r", "\\r")
                    .replace("\t", "\\t");
    }
}
