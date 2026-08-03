package org.example.controller.guard;

import org.example.dao.CaLamViecDAO;
import org.example.dao.CoSoFaceConfigDAO;
import org.example.dao.impl.CaLamViecDAOImpl;
import org.example.dao.impl.CoSoFaceConfigDAOImpl;
import org.example.model.CaLamViec;
import org.example.model.CoSoFaceConfig;
import org.example.model.TaiKhoan;
import org.example.util.Constants;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@WebServlet("/guard/diem-danh")
public class GuardDiemDanhServlet extends HttpServlet {

    private final CaLamViecDAO caLamViecDAO = new CaLamViecDAOImpl();
    private final CoSoFaceConfigDAO faceConfigDAO = new CoSoFaceConfigDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        TaiKhoan user = getUser(req, resp);
        if (user == null) return;

        // Lưới tuần cần điều hướng qua lại, nên trả cùng khoảng ngày như bên Lễ tân
        if ("json".equals(req.getParameter("format"))) {
            List<CaLamViec> shifts = caLamViecDAO.getCaByAccountIDAndDateRange(
                            user.getAccountId(),
                            LocalDate.now().minusWeeks(4),
                            LocalDate.now().plusWeeks(8))
                    .stream().filter(CaLamViec::isPublished).collect(Collectors.toList());

            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            resp.getWriter().write(buildShiftsJson(shifts));
            return;
        }

        CoSoFaceConfig faceConfig = user.getCoSoId() != null
            ? faceConfigDAO.findByCoSo(user.getCoSoId())
            : new CoSoFaceConfig();
        req.setAttribute("faceConfig", faceConfig);
        req.setAttribute("guardPage", "diem-danh");
        req.getRequestDispatcher("/guard/DiemDanh.jsp").forward(req, resp);
    }

    private String buildShiftsJson(List<CaLamViec> shifts) {
        List<Map<String, Object>> rows = new ArrayList<>();
        for (CaLamViec s : shifts) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("caLamViecId", s.getCaLamViecId());
            m.put("ngayLam", s.getNgayLam() != null ? s.getNgayLam().toString() : "");
            m.put("gioBatDau", s.getGioBatDau() != null ? s.getGioBatDau().toString() : "");
            m.put("gioKetThuc", s.getGioKetThuc() != null ? s.getGioKetThuc().toString() : "");
            m.put("tenCa", s.getTenCa());
            m.put("viTri", s.getViTri());
            m.put("trangThai", s.getTrangThai());
            m.put("gioNghi", s.getGioNghi());
            m.put("ghiChu", s.getGhiChu());
            m.put("faceVerified", s.isFaceVerified());
            m.put("faceConfidence", s.getFaceConfidence());
            m.put("gioVaoThuc", s.getGioVaoThuc() != null ? s.getGioVaoThuc().toString() : null);
            m.put("gioRaThuc", s.getGioRaThuc() != null ? s.getGioRaThuc().toString() : null);
            rows.add(m);
        }
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("shifts", rows);
        return new com.google.gson.Gson().toJson(data);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        TaiKhoan user = getUser(req, resp);
        if (user == null) return;

        // Bảo vệ chỉ điểm danh bằng khuôn mặt (/face/checkin). Điểm danh thủ công là
        // quyền của Quản lý — dùng khi camera hỏng hoặc nhân viên tới muộn quá hạn.
        req.getSession().setAttribute("flashError",
                "Điểm danh thủ công do quản lý thực hiện. Vui lòng điểm danh bằng khuôn mặt "
                + "hoặc liên hệ quản lý nếu camera gặp sự cố.");
        resp.sendRedirect(req.getContextPath() + "/guard/diem-danh");
    }

    private TaiKhoan getUser(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        TaiKhoan user = session != null ? (TaiKhoan) session.getAttribute("user") : null;
        if (user == null || user.getRoleId() != Constants.ROLE_BAO_VE) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return null;
        }
        return user;
    }
}
