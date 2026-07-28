package org.example.controller.manager;

import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.model.TaiKhoan;
import org.example.service.refund.RefundService;
import org.example.util.Constants;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/manager/refund-management")
public class ManagerRefundManagementServlet extends HttpServlet {

    private static final Logger logger = LogManager.getLogger(ManagerRefundManagementServlet.class);
    private final RefundService refundService = new RefundService();
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        TaiKhoan user = session == null ? null : (TaiKhoan) session.getAttribute("user");

        resp.setContentType("application/json;charset=UTF-8");
        Map<String, Object> result = new HashMap<>();

        if (user == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            result.put("success", false);
            result.put("message", "Vui lòng đăng nhập.");
            resp.getWriter().write(gson.toJson(result));
            return;
        }

        if (user.getRoleId() != Constants.ROLE_MANAGER && user.getRoleId() != Constants.ROLE_ADMIN) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            result.put("success", false);
            result.put("message", "Bạn không có quyền thực hiện duyệt hoàn tiền.");
            resp.getWriter().write(gson.toJson(result));
            return;
        }

        String refundIdStr = req.getParameter("refundId");
        String action = req.getParameter("action");
        String noteOrReason = req.getParameter("note");

        if (refundIdStr == null || action == null || (!"approve".equalsIgnoreCase(action) && !"reject".equalsIgnoreCase(action))) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            result.put("success", false);
            result.put("message", "Tham số refundId hoặc action ('approve'/'reject') không hợp lệ.");
            resp.getWriter().write(gson.toJson(result));
            return;
        }

        try {
            int refundId = Integer.parseInt(refundIdStr.trim());
            RefundService.RefundResult res;

            if ("approve".equalsIgnoreCase(action)) {
                res = refundService.approveRefund(refundId, user.getAccountId(), noteOrReason);
            } else {
                res = refundService.rejectRefund(refundId, user.getAccountId(), noteOrReason);
            }

            result.put("success", res.success);
            result.put("message", res.message);
            if (!res.success) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            }

            resp.getWriter().write(gson.toJson(result));
        } catch (NumberFormatException nfe) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            result.put("success", false);
            result.put("message", "refundId phải là số nguyên.");
            resp.getWriter().write(gson.toJson(result));
        } catch (Exception e) {
            logger.error("Error managing refund #{}: {}", refundIdStr, e.getMessage(), e);
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            result.put("success", false);
            result.put("message", "Lỗi xử lý hệ thống: " + e.getMessage());
            resp.getWriter().write(gson.toJson(result));
        }
    }
}
