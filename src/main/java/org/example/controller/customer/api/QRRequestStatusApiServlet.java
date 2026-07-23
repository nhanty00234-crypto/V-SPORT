package org.example.controller.customer.api;

import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.dto.qr.QRRequestDTO;
import org.example.service.QRRequestService;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/api/qr/yeu-cau-status")
public class QRRequestStatusApiServlet extends HttpServlet {

    private final QRRequestService service = new QRRequestService();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json; charset=UTF-8");
        Map<String, Object> out = new HashMap<>();
        try {
            String guestToken = req.getParameter("guestToken");
            int sanId = Integer.parseInt(req.getParameter("sanId"));
            if (guestToken == null || guestToken.isBlank()) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.put("success", false);
                out.put("message", "Thiếu guestToken.");
                resp.getWriter().write(gson.toJson(out));
                return;
            }
            List<QRRequestDTO> data = service.listByGuestToken(guestToken, sanId);
            out.put("success", true);
            out.put("data", data);
            resp.getWriter().write(gson.toJson(out));
        } catch (NumberFormatException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.put("success", false);
            out.put("message", "Dữ liệu không hợp lệ.");
            resp.getWriter().write(gson.toJson(out));
        }
    }
}
