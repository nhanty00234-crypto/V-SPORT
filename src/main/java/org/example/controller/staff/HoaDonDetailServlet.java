package org.example.controller.staff;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonObject;
import com.google.gson.JsonPrimitive;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.model.TaiKhoan;
import org.example.service.invoice.InvoiceView;
import org.example.service.invoice.InvoiceViewService;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.NoSuchElementException;

/**
 * Route JSON CHỈ ĐỌC trả chi tiết một hóa đơn, dùng bởi modal thanh toán để hiển thị
 * bill thật ngay trong modal (trạng thái PAYMENT_SUCCESS) mà không cần điều hướng sang
 * trang in riêng. Dùng chung InvoiceViewService với HoaDonPrintServlet - không query
 * hóa đơn theo hai cách khác nhau, không tính lại tiền lịch sử.
 */
@WebServlet("/staff/hoa-don/detail")
public class HoaDonDetailServlet extends HttpServlet {

    private static final Logger logger = LogManager.getLogger(HoaDonDetailServlet.class);
    private static final DateTimeFormatter ISO = DateTimeFormatter.ISO_LOCAL_DATE_TIME;

    private final InvoiceViewService invoiceViewService = new InvoiceViewService();

    private static final Gson gson = new GsonBuilder()
            .registerTypeAdapter(LocalDateTime.class, (com.google.gson.JsonSerializer<LocalDateTime>)
                    (src, typeOfSrc, context) -> src == null ? null : new JsonPrimitive(src.format(ISO)))
            .create();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        TaiKhoan user = session == null ? null : (TaiKhoan) session.getAttribute("user");
        if (user == null || (user.getRoleId() != 2 && user.getRoleId() != 4)) {
            writeJson(resp, HttpServletResponse.SC_UNAUTHORIZED, errorJson("UNAUTHORIZED", "Phiên đăng nhập đã hết hạn."));
            return;
        }

        String idStr = req.getParameter("id");
        int hoaDonId;
        try {
            if (idStr == null || idStr.isBlank()) throw new NumberFormatException("missing id");
            hoaDonId = Integer.parseInt(idStr.trim());
            if (hoaDonId <= 0) throw new NumberFormatException("non-positive id");
        } catch (NumberFormatException e) {
            writeJson(resp, HttpServletResponse.SC_BAD_REQUEST, errorJson("INVALID_ID", "Mã hóa đơn không hợp lệ."));
            return;
        }

        try {
            InvoiceView invoice = invoiceViewService.load(hoaDonId, user, req.getContextPath());
            JsonObject payload = new JsonObject();
            payload.addProperty("success", true);
            payload.add("invoice", gson.toJsonTree(invoice));
            writeJson(resp, HttpServletResponse.SC_OK, payload);
        } catch (NoSuchElementException e) {
            writeJson(resp, HttpServletResponse.SC_NOT_FOUND, errorJson("NOT_FOUND", e.getMessage()));
        } catch (SecurityException e) {
            writeJson(resp, HttpServletResponse.SC_FORBIDDEN, errorJson("FORBIDDEN", e.getMessage()));
        } catch (Exception e) {
            logger.error("Không thể tải chi tiết hóa đơn #{}", hoaDonId, e);
            writeJson(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    errorJson("INTERNAL_ERROR", "Không thể tải chi tiết hóa đơn."));
        }
    }

    private JsonObject errorJson(String code, String message) {
        JsonObject json = new JsonObject();
        json.addProperty("success", false);
        json.addProperty("code", code);
        json.addProperty("message", message == null || message.isBlank() ? "Yêu cầu không thể xử lý." : message);
        return json;
    }

    private void writeJson(HttpServletResponse resp, int status, JsonObject body) throws IOException {
        if (!resp.isCommitted()) resp.resetBuffer();
        resp.setStatus(status);
        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");
        resp.getWriter().write(body.toString());
        resp.getWriter().flush();
    }
}
