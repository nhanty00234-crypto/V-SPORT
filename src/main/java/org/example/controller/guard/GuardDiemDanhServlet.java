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
import java.util.List;

@WebServlet("/guard/diem-danh")
public class GuardDiemDanhServlet extends HttpServlet {

    private final CaLamViecDAO caLamViecDAO = new CaLamViecDAOImpl();
    private final CoSoFaceConfigDAO faceConfigDAO = new CoSoFaceConfigDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        TaiKhoan user = getUser(req, resp);
        if (user == null) return;

        CaLamViec caHomNay = caLamViecDAO.getCaHomNay(user.getAccountId(), LocalDate.now());
        List<CaLamViec> lichSu = caLamViecDAO.getCaByAccountIDAndDateRange(
                user.getAccountId(),
                LocalDate.now().minusDays(7),
                LocalDate.now().minusDays(1));
        List<CaLamViec> caSapToi = caLamViecDAO.getCaByAccountIDAndDateRange(
                user.getAccountId(),
                LocalDate.now().plusDays(1),
                LocalDate.now().plusDays(7));

        System.out.println("[DEBUG-SHIFT] GuardDiemDanhServlet: sessionAccountId=" + user.getAccountId()
                + " username=" + user.getUsername()
                + " today=" + LocalDate.now()
                + " caHomNayFound=" + (caHomNay != null)
                + " lichSuCount=" + lichSu.size());

        CoSoFaceConfig faceConfig = user.getCoSoId() != null
            ? faceConfigDAO.findByCoSo(user.getCoSoId())
            : new CoSoFaceConfig();
        req.setAttribute("faceConfig", faceConfig);
        req.setAttribute("caHomNay", caHomNay);
        req.setAttribute("lichSuCa", lichSu);
        req.setAttribute("caSapToi", caSapToi);
        req.setAttribute("guardPage", "diem-danh");
        req.getRequestDispatcher("/guard/DiemDanh.jsp").forward(req, resp);
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
