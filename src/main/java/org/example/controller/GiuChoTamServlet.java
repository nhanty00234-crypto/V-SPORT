package org.example.controller;

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
            }
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "Dữ liệu không hợp lệ.");
        }

        resp.getWriter().write(new com.google.gson.Gson().toJson(result));
    }
}
