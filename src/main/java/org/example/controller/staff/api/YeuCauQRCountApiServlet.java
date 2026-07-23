package org.example.controller.staff.api;

import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.model.TaiKhoan;
import org.example.service.QRRequestService;
import org.example.util.Constants;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/api/staff/yeu-cau-qr/count")
public class YeuCauQRCountApiServlet extends HttpServlet {

    private final QRRequestService service = new QRRequestService();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json; charset=UTF-8");
        Map<String, Object> out = new HashMap<>();
        HttpSession session = req.getSession(false);
        TaiKhoan user = session != null ? (TaiKhoan) session.getAttribute("user") : null;
        if (user == null || (user.getRoleId() != Constants.ROLE_MANAGER && user.getRoleId() != Constants.ROLE_LE_TAN)
                || user.getCoSoId() == null) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            out.put("success", false);
            resp.getWriter().write(gson.toJson(out));
            return;
        }
        long count = service.countNewByCoSo(user.getCoSoId());
        Map<String, Object> data = new HashMap<>();
        data.put("count", count);
        out.put("success", true);
        out.put("data", data);
        resp.getWriter().write(gson.toJson(out));
    }
}
