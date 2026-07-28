package org.example.controller.staff;

import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.model.TaiKhoan;
import org.example.service.billing.ServiceBillSeparationService;
import org.example.util.Constants;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/staff/split-bill")
public class SplitBillServlet extends HttpServlet {

    private static final Logger logger = LogManager.getLogger(SplitBillServlet.class);
    private final ServiceBillSeparationService billSeparationService = new ServiceBillSeparationService();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
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

        if (user.getRoleId() != Constants.ROLE_LE_TAN && user.getRoleId() != Constants.ROLE_MANAGER && user.getRoleId() != Constants.ROLE_ADMIN) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            result.put("success", false);
            result.put("message", "Bạn không có quyền truy cập chức năng này.");
            resp.getWriter().write(gson.toJson(result));
            return;
        }

        String datSanIdStr = req.getParameter("datSanId");
        if (datSanIdStr == null || datSanIdStr.isBlank()) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            result.put("success", false);
            result.put("message", "Thiếu tham số datSanId.");
            resp.getWriter().write(gson.toJson(result));
            return;
        }

        try {
            int datSanId = Integer.parseInt(datSanIdStr);
            ServiceBillSeparationService.BillSummaryDTO summary = billSeparationService.getBillSummary(datSanId);
            result.put("success", true);
            result.put("summary", summary);
            resp.getWriter().write(gson.toJson(result));
        } catch (NumberFormatException nfe) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            result.put("success", false);
            result.put("message", "datSanId không hợp lệ.");
            resp.getWriter().write(gson.toJson(result));
        }
    }

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

        if (user.getRoleId() != Constants.ROLE_LE_TAN && user.getRoleId() != Constants.ROLE_MANAGER && user.getRoleId() != Constants.ROLE_ADMIN) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            result.put("success", false);
            result.put("message", "Bạn không có quyền thực hiện tách hóa đơn.");
            resp.getWriter().write(gson.toJson(result));
            return;
        }

        try {
            int datSanId = Integer.parseInt(req.getParameter("datSanId"));
            String[] prodStr = req.getParameterValues("productIds");
            String[] qtyStr = req.getParameterValues("quantities");
            boolean payNow = "true".equalsIgnoreCase(req.getParameter("payNow"));
            String paymentMethod = req.getParameter("paymentMethod");

            if (prodStr == null || qtyStr == null || prodStr.length != qtyStr.length) {
                result.put("success", false);
                result.put("message", "Dữ liệu sản phẩm không hợp lệ.");
                resp.getWriter().write(gson.toJson(result));
                return;
            }

            int[] productIds = new int[prodStr.length];
            int[] quantities = new int[qtyStr.length];
            for (int i = 0; i < prodStr.length; i++) {
                productIds[i] = Integer.parseInt(prodStr[i]);
                quantities[i] = Integer.parseInt(qtyStr[i]);
            }

            int coSoId = user.getCoSoId();
            ServiceBillSeparationService.SplitBillResult splitRes = billSeparationService.splitServiceBill(
                    datSanId, productIds, quantities, payNow, paymentMethod, user.getAccountId(), coSoId
            );

            result.put("success", splitRes.success);
            result.put("message", splitRes.message);
            if (splitRes.splitHoaDonId != null) {
                result.put("splitHoaDonId", splitRes.splitHoaDonId);
            }

            resp.getWriter().write(gson.toJson(result));
        } catch (Exception e) {
            logger.error("Error processing split bill request: {}", e.getMessage(), e);
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            result.put("success", false);
            result.put("message", "Lỗi xử lý yêu cầu: " + e.getMessage());
            resp.getWriter().write(gson.toJson(result));
        }
    }
}
