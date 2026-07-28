package org.example.controller.manager;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.model.TaiKhoan;
import org.example.service.AuditLogService;
import org.example.service.reputation.CustomerReputationService;
import org.example.util.Constants;
import org.example.util.DBUtil;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;

@WebServlet("/manager/adjust-reputation")
public class ManagerReputationAdjustmentServlet extends HttpServlet {

    private static final Logger logger = LogManager.getLogger(ManagerReputationAdjustmentServlet.class);

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        TaiKhoan user = session == null ? null : (TaiKhoan) session.getAttribute("user");

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return;
        }

        if (user.getRoleId() != Constants.ROLE_MANAGER && user.getRoleId() != Constants.ROLE_ADMIN) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền thực hiện thao tác này.");
            return;
        }

        String targetAccountIdStr = req.getParameter("targetAccountId");
        String scoreDeltaStr = req.getParameter("scoreDelta");
        String reason = req.getParameter("reason");

        if (targetAccountIdStr == null || scoreDeltaStr == null || reason == null || reason.trim().length() < 5) {
            session.setAttribute("error", "Dữ liệu không hợp lệ. Lý do phải dài ít nhất 5 ký tự.");
            resp.sendRedirect(req.getContextPath() + "/manager/khach-hang");
            return;
        }

        try {
            int targetAccountId = Integer.parseInt(targetAccountIdStr);
            int scoreDelta = Integer.parseInt(scoreDeltaStr);

            if (scoreDelta == 0 || scoreDelta < -100 || scoreDelta > 100) {
                session.setAttribute("error", "Số điểm điều chỉnh phải từ -100 đến +100 và khác 0.");
                resp.sendRedirect(req.getContextPath() + "/manager/khach-hang");
                return;
            }

            try (Connection conn = DBUtil.getConnection()) {
                conn.setAutoCommit(false);
                try {
                    int newScore = CustomerReputationService.applyDelta(conn, targetAccountId, null,
                            Constants.REPUTATION_ACTION_MANUAL_ADJUST, scoreDelta,
                            "Quản lý điều chỉnh: " + reason.trim(),
                            user.getAccountId(), AuditLogService.getClientIp(req));
                    conn.commit();

                    AuditLogService.log(req, user, AuditLogService.ACTION_UPDATE, "CUSTOMER_REPUTATION",
                            String.valueOf(targetAccountId), "Account #" + targetAccountId,
                            "Điều chỉnh điểm uy tín: " + (scoreDelta > 0 ? "+" + scoreDelta : scoreDelta) + ". Lý do: " + reason.trim());

                    session.setAttribute("message", "Đã điều chỉnh điểm uy tín thành công. Điểm mới: " + newScore + "/100.");
                } catch (SQLException e) {
                    conn.rollback();
                    throw e;
                } finally {
                    conn.setAutoCommit(true);
                }
            }
        } catch (NumberFormatException nfe) {
            session.setAttribute("error", "ID hoặc điểm số không hợp lệ.");
        } catch (Exception e) {
            logger.error("Lỗi khi điều chỉnh điểm uy tín bởi Manager ID={}: {}", user.getAccountId(), e.getMessage(), e);
            session.setAttribute("error", "Lỗi hệ thống khi cập nhật điểm uy tín.");
        }

        resp.sendRedirect(req.getContextPath() + "/manager/khach-hang");
    }
}
