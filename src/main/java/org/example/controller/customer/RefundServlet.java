package org.example.controller.customer;

import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.model.TaiKhoan;
import org.example.service.refund.RefundService;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/customer/request-refund")
public class RefundServlet extends HttpServlet {

    private static final Logger logger = LogManager.getLogger(RefundServlet.class);
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

        String datSanIdStr = req.getParameter("datSanId");
        String amountStr = req.getParameter("amount");
        String reason = req.getParameter("reason");

        if (datSanIdStr == null || datSanIdStr.isBlank() || amountStr == null || amountStr.isBlank()) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            result.put("success", false);
            result.put("message", "Thiếu ID đơn đặt sân hoặc số tiền hoàn.");
            resp.getWriter().write(gson.toJson(result));
            return;
        }

        try {
            int datSanId = Integer.parseInt(datSanIdStr.trim());
            BigDecimal requestedAmount = new BigDecimal(amountStr.trim());

            RefundService.RefundResult res = refundService.requestRefund(
                    datSanId, user.getAccountId(), requestedAmount, reason
            );

            result.put("success", res.success);
            result.put("message", res.message);
            if (res.refundId != null) {
                result.put("refundId", res.refundId);
            }

            if (!res.success) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            }

            resp.getWriter().write(gson.toJson(result));
        } catch (NumberFormatException nfe) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            result.put("success", false);
            result.put("message", "ID đơn hoặc số tiền hoàn không đúng định dạng.");
            resp.getWriter().write(gson.toJson(result));
        } catch (Exception e) {
            logger.error("Error processing refund request: {}", e.getMessage(), e);
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            result.put("success", false);
            result.put("message", "Lỗi xử lý hệ thống: " + e.getMessage());
            resp.getWriter().write(gson.toJson(result));
        }
    }
}
