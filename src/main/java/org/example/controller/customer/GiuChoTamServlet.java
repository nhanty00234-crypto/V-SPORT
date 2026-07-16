package org.example.controller.customer;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.dao.SoftHoldDAO;
import org.example.dao.impl.SoftHoldDAOImpl;
import org.example.model.TaiKhoan;

import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/customer/giu-cho-tam")
public class GiuChoTamServlet extends HttpServlet {

    private final SoftHoldDAO softHoldDAO = new SoftHoldDAOImpl();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");

        HttpSession session = req.getSession();
        TaiKhoan user = (TaiKhoan) session.getAttribute("user");

        Map<String, Object> result = new HashMap<>();

        if (user == null) {
            result.put("success", false);
            result.put("message", "Vui lòng đăng nhập để giữ chỗ.");
            resp.getWriter().write(new com.google.gson.Gson().toJson(result));
            return;
        }

        if ("release".equals(req.getParameter("action"))) {
            // Giải phóng hold ngay khi khách đóng modal đặt sân mà không hoàn tất - không chờ
            // SOFT_HOLD_TIMEOUT_MINUTES tự hết hạn, tránh chặn oan slot cho khách khác.
            try {
                int sanId = Integer.parseInt(req.getParameter("sanId"));
                LocalDate ngayDat = LocalDate.parse(req.getParameter("ngayDat"));
                softHoldDAO.deleteHoldsByAccountAndSan(user.getAccountId(), sanId, ngayDat);
                result.put("success", true);
            } catch (Exception e) {
                result.put("success", false);
                result.put("message", "Dữ liệu không hợp lệ.");
            }
            resp.getWriter().write(new com.google.gson.Gson().toJson(result));
            return;
        }

        try {
            int sanId = Integer.parseInt(req.getParameter("sanId"));
            LocalDate ngayDat = LocalDate.parse(req.getParameter("ngayDat"));
            LocalTime gioBatDau = LocalTime.parse(req.getParameter("gioBatDau"));
            LocalTime gioKetThuc = LocalTime.parse(req.getParameter("gioKetThuc"));

            if (!gioKetThuc.isAfter(gioBatDau)) {
                result.put("success", false);
                result.put("message", "Giờ kết thúc phải sau giờ bắt đầu.");
                resp.getWriter().write(new com.google.gson.Gson().toJson(result));
                return;
            }

            SoftHoldDAO.HoldResult hold = softHoldDAO.createHold(
                    user.getAccountId(), sanId, ngayDat, gioBatDau, gioKetThuc);

            result.put("success", hold.success);
            if (hold.success) {
                result.put("expiresAt", hold.expiresAt.format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
                result.put("holdSeconds", org.example.util.Constants.SOFT_HOLD_TIMEOUT_MINUTES * 60);
            } else {
                result.put("message", hold.errorMessage);
                result.put("code", hold.errorCode != null ? hold.errorCode : "SLOT_UNAVAILABLE");
            }
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "Dữ liệu không hợp lệ.");
        }

        resp.getWriter().write(new com.google.gson.Gson().toJson(result));
    }
}
