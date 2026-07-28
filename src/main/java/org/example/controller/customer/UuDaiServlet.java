package org.example.controller.customer;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * Trang Customer "Ưu đãi" - render khung trang, danh sách khuyến mãi công khai được tải
 * qua GET /api/customer/promotions?limit=N (CustomerPromotionApiServlet, đã tồn tại sẵn).
 * Cho phép Guest xem, cùng chính sách với /customer/tim-kiem và /customer/dich-vu.
 */
@WebServlet("/customer/uu-dai")
public class UuDaiServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/customer/UuDai.jsp").forward(req, resp);
    }
}
