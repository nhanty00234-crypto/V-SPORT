package org.example.controller.customer;

import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.model.TaiKhoan;
import org.example.service.customer.PromotionService;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/api/promotion/apply")
public class ApDungKhuyenMaiServlet extends HttpServlet {

    private final PromotionService promotionService = new PromotionService();
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        Map<String, Object> result = new HashMap<>();

        HttpSession session = req.getSession(false);
        TaiKhoan user = session == null ? null : (TaiKhoan) session.getAttribute("user");

        String code = req.getParameter("code");
        String originalAmountStr = req.getParameter("originalAmount");
        String coSoIdStr = req.getParameter("coSoId");
        String bookingDateStr = req.getParameter("bookingDate");

        if (code == null || code.isBlank() || originalAmountStr == null || originalAmountStr.isBlank()) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            result.put("valid", false);
            result.put("message", "Vui lòng nhập mã khuyến mãi và số tiền ban đầu.");
            resp.getWriter().write(gson.toJson(result));
            return;
        }

        try {
            BigDecimal originalAmount = new BigDecimal(originalAmountStr.trim());
            Integer coSoId = (coSoIdStr != null && !coSoIdStr.isBlank()) ? Integer.parseInt(coSoIdStr.trim()) : null;
            LocalDate bookingDate = (bookingDateStr != null && !bookingDateStr.isBlank()) ? LocalDate.parse(bookingDateStr.trim()) : LocalDate.now();
            Integer accountId = user != null ? user.getAccountId() : null;

            PromotionService.PromotionResult promoResult = promotionService.validateAndCalculate(
                    code, originalAmount, coSoId, bookingDate, accountId
            );

            result.put("valid", promoResult.isValid());
            result.put("message", promoResult.getMessage());
            result.put("discountAmount", promoResult.getDiscountAmount());
            result.put("finalAmount", promoResult.getFinalAmount());
            if (promoResult.getKhuyenMai() != null) {
                result.put("khuyenMaiId", promoResult.getKhuyenMai().getKhuyenMaiID());
                result.put("code", promoResult.getKhuyenMai().getMaCode());
            }

            resp.getWriter().write(gson.toJson(result));
        } catch (NumberFormatException nfe) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            result.put("valid", false);
            result.put("message", "Số tiền hoặc mã cơ sở không hợp lệ.");
            resp.getWriter().write(gson.toJson(result));
        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            result.put("valid", false);
            result.put("message", "Lỗi xử lý hệ thống: " + e.getMessage());
            resp.getWriter().write(gson.toJson(result));
        }
    }
}
