package org.example.controller.manager;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.dao.CustomerBranchDAO;
import org.example.dao.impl.CustomerBranchDAOImpl;
import org.example.model.TaiKhoan;
import org.example.util.Constants;

import java.io.IOException;
import java.util.List;

@WebServlet("/manager/khach-hang")
public class CustomerManagerServlet extends HttpServlet {

    private final CustomerBranchDAO customerDAO = new CustomerBranchDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        TaiKhoan user = (TaiKhoan) session.getAttribute("user");

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return;
        }

        if (user.getRoleId() != Constants.ROLE_MANAGER) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập chức năng này.");
            return;
        }

        int coSoId = user.getCoSoId();

        try {
            // 1. Top repeat customers (sorted by booking frequency)
            List<Object[]> repeatCustomers = customerDAO.getTopCustomers(coSoId, false, 10);

            // 2. VIP customers (sorted by total spending value)
            List<Object[]> vipCustomers = customerDAO.getTopCustomers(coSoId, true, 10);

            // 3. Customer Reviews/Feedback
            List<Object[]> reviews = customerDAO.getBranchReviews(coSoId);

            // 4. Booking Cancellation Risk alerts (Unpaid bookings starting today/tomorrow)
            List<Object[]> riskBookings = customerDAO.getRiskBookings(coSoId);

            // 5. Account Risk alerts (Customers with high cancellation rate)
            List<Object[]> riskCancelers = customerDAO.getHighRiskCancelers(coSoId);

            req.setAttribute("repeatCustomers", repeatCustomers);
            req.setAttribute("vipCustomers", vipCustomers);
            req.setAttribute("reviews", reviews);
            req.setAttribute("riskBookings", riskBookings);
            req.setAttribute("riskCancelers", riskCancelers);
            req.setAttribute("pageTitle", "Quản lý Khách hàng");

        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("Error fetching customer data: " + e.getMessage());
        }

        req.getRequestDispatcher("/manager/KhachHang.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        doGet(req, resp);
    }
}
