package org.example.controller.staff.api;

import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.model.QRRequest;
import org.example.model.TaiKhoan;
import org.example.service.QRRequestService;
import org.example.util.Constants;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/api/staff/yeu-cau-qr/action")
public class YeuCauQRActionApiServlet extends HttpServlet {

    private final QRRequestService service = new QRRequestService();
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json; charset=UTF-8");
        Map<String, Object> out = new HashMap<>();
        HttpSession session = req.getSession(false);
        TaiKhoan user = session != null ? (TaiKhoan) session.getAttribute("user") : null;
        if (user == null || (user.getRoleId() != Constants.ROLE_MANAGER && user.getRoleId() != Constants.ROLE_LE_TAN)
                || user.getCoSoId() == null) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            out.put("success", false);
            out.put("message", "Bạn không có quyền truy cập chức năng này.");
            resp.getWriter().write(gson.toJson(out));
            return;
        }
        try {
            int requestId = Integer.parseInt(req.getParameter("requestId"));
            String action = req.getParameter("action");
            String newStatus = mapAction(action);
            if (newStatus == null) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.put("success", false);
                out.put("message", "Hành động không hợp lệ.");
                resp.getWriter().write(gson.toJson(out));
                return;
            }
            QRRequestService.Result result = service.updateStatus(requestId, user.getCoSoId(), user.getAccountId(), newStatus);
            if (!result.success) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.put("success", false);
                out.put("message", result.message);
                resp.getWriter().write(gson.toJson(out));
                return;
            }
            out.put("success", true);
            out.put("data", result.data);
            resp.getWriter().write(gson.toJson(out));
        } catch (NumberFormatException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.put("success", false);
            out.put("message", "Dữ liệu không hợp lệ.");
            resp.getWriter().write(gson.toJson(out));
        }
    }

    private String mapAction(String action) {
        if ("start".equals(action)) return QRRequest.STATUS_IN_PROGRESS;
        if ("complete".equals(action)) return QRRequest.STATUS_DONE;
        if ("cancel".equals(action)) return QRRequest.STATUS_CANCELLED;
        return null;
    }
}
