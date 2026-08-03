package org.example.controller.manager.api;

import com.google.gson.JsonObject;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.model.TaiKhoan;
import org.example.service.manager.LuongService;
import org.example.service.manager.UngLuongService;
import org.example.util.Constants;

import java.io.IOException;
import java.io.PrintWriter;

/**
 * API AJAX của module lương. Trả JSON thuần; mọi thao tác ràng buộc theo CoSoID trong session.
 */
@WebServlet({"/manager/api/luong/xac-nhan", "/manager/api/luong/duyet-ung"})
public class LuongManagerApiServlet extends HttpServlet {

    private final LuongService luongService = new LuongService();
    private final UngLuongService ungLuongService = new UngLuongService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");

        HttpSession session = req.getSession(false);
        TaiKhoan manager = session != null ? (TaiKhoan) session.getAttribute("user") : null;
        if (manager == null || manager.getRoleId() != Constants.ROLE_MANAGER || manager.getCoSoId() == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            write(resp, false, "Phiên đăng nhập đã hết hạn.");
            return;
        }
        int coSoId = manager.getCoSoId();

        try {
            if ("/manager/api/luong/xac-nhan".equals(req.getServletPath())) {
                int bangLuongId = Integer.parseInt(req.getParameter("bangLuongId"));
                boolean ok = luongService.xacNhanDaChuyenKhoan(bangLuongId, coSoId);
                if (ok) {
                    write(resp, true, null);
                } else {
                    resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    write(resp, false, "Không có quyền thao tác trên bảng lương này.");
                }
                return;
            }

            int yeuCauId = Integer.parseInt(req.getParameter("yeuCauId"));
            String hanhDong = req.getParameter("hanhDong");
            String ghiChu = req.getParameter("ghiChu");
            boolean ok = "tu-choi".equals(hanhDong)
                    ? ungLuongService.tuChoi(yeuCauId, coSoId, manager.getAccountId(), ghiChu)
                    : ungLuongService.duyet(yeuCauId, coSoId, manager.getAccountId(), ghiChu);
            if (ok) {
                write(resp, true, null);
            } else {
                resp.setStatus(HttpServletResponse.SC_CONFLICT);
                write(resp, false, "Yêu cầu đã được xử lý trước đó hoặc không thuộc cơ sở của bạn.");
            }
        } catch (NumberFormatException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            write(resp, false, "Tham số không hợp lệ.");
        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            write(resp, false, "Lỗi hệ thống, vui lòng thử lại.");
        }
    }

    private static void write(HttpServletResponse resp, boolean ok, String error) throws IOException {
        JsonObject json = new JsonObject();
        json.addProperty("ok", ok);
        if (error != null) json.addProperty("error", error);
        try (PrintWriter out = resp.getWriter()) {
            out.print(json);
        }
    }
}
