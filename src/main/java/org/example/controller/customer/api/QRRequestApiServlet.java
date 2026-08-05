package org.example.controller.customer.api;

import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.model.QRRequest;
import org.example.service.QRRequestService;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/api/qr/yeu-cau")
public class QRRequestApiServlet extends HttpServlet {

    private final QRRequestService service = new QRRequestService();
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json; charset=UTF-8");
        Map<String, Object> out = new HashMap<>();
        try {
            int sanId = Integer.parseInt(req.getParameter("sanId"));
            String guestToken = req.getParameter("guestToken");
            String requestType = req.getParameter("requestType");
            String note = req.getParameter("note");
            String itemsJson = req.getParameter("itemsJson");

            if (!isValidType(requestType)) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.put("success", false);
                out.put("message", "Loại yêu cầu không hợp lệ.");
                resp.getWriter().write(gson.toJson(out));
                return;
            }

            QRRequestService.Result result = service.createRequest(sanId, guestToken, null, requestType, itemsJson, note);
            if (!result.success) {
                resp.setStatus(statusFor(result.errorCode));
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
        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.put("success", false);
            out.put("message", "Đã xảy ra lỗi hệ thống.");
            resp.getWriter().write(gson.toJson(out));
        }
    }

    private boolean isValidType(String type) {
        return QRRequest.TYPE_CALL_STAFF.equals(type) || QRRequest.TYPE_ORDER_ITEM.equals(type)
            || QRRequest.TYPE_SERVICE_REQUEST.equals(type);
    }

    private int statusFor(QRRequestService.ErrorCode code) {
        if (code == null) return HttpServletResponse.SC_INTERNAL_SERVER_ERROR;
        switch (code) {
            case NOT_FOUND: return HttpServletResponse.SC_NOT_FOUND;
            case FORBIDDEN: return HttpServletResponse.SC_FORBIDDEN;
            case DUPLICATE: return HttpServletResponse.SC_CONFLICT;
            default: return HttpServletResponse.SC_INTERNAL_SERVER_ERROR;
        }
    }
}
