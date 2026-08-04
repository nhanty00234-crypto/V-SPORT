package org.example.controller.manager;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.example.dao.CaLamViecDAO;
import org.example.dao.CoSoFaceConfigDAO;
import org.example.dao.TaiKhoanDAO;
import org.example.dao.impl.CaLamViecDAOImpl;
import org.example.dao.impl.CoSoFaceConfigDAOImpl;
import org.example.dao.impl.TaiKhoanDAOImpl;
import org.example.model.CoSoFaceConfig;
import org.example.model.FaceAttendanceLog;
import org.example.model.TaiKhoan;
import org.example.util.Constants;
import org.example.util.FaceDescriptorMatcher;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/manager/face-settings")
public class FaceSettingsServlet extends HttpServlet {

    /** Số dòng lịch sử điểm danh khuôn mặt hiển thị trên trang. */
    private static final int HISTORY_LIMIT = 50;

    /** Nhân sự có thể đăng ký khuôn mặt — cùng tập role được phân ca. */
    private static final List<Integer> FACE_ROLES = Constants.ALLOWED_SHIFT_ROLES;

    private final CoSoFaceConfigDAO configDAO = new CoSoFaceConfigDAOImpl();
    private final TaiKhoanDAO taiKhoanDAO = new TaiKhoanDAOImpl();
    private final CaLamViecDAO caLamViecDAO = new CaLamViecDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        TaiKhoan manager = getManager(req, resp);
        if (manager == null) return;

        int coSoId = manager.getCoSoId();

        CoSoFaceConfig config = configDAO.findByCoSo(coSoId);
        if (config == null) {
            config = new CoSoFaceConfig();
            config.setCoSoId(coSoId);
            config.setFaceRequired(false);
            config.setConfidenceMin(0.6);
        }

        List<TaiKhoan> nhanSu = taiKhoanDAO.getAccountsByCoSoAndRoleIn(coSoId, FACE_ROLES);
        List<TaiKhoan> daDangKy = new ArrayList<>();
        List<TaiKhoan> chuaDangKy = new ArrayList<>();
        for (TaiKhoan tk : nhanSu) {
            // Đồng bộ tiêu chí "đã đăng ký" với FaceCheckInServlet: chuỗi không rỗng nhưng
            // parse() ra 0 mẫu (dữ liệu hỏng) không được tính là đã đăng ký, kẻo dashboard
            // hiện xanh trong khi nhân viên bị từ chối ở cổng.
            if (FaceDescriptorMatcher.parse(tk.getFaceDescriptor()).length > 0) {
                daDangKy.add(tk);
            } else {
                chuaDangKy.add(tk);
            }
        }

        List<FaceAttendanceLog> lichSu = caLamViecDAO.getFaceAttendanceHistory(coSoId, HISTORY_LIMIT);

        req.setAttribute("faceConfig", config);
        req.setAttribute("daDangKy", daDangKy);
        req.setAttribute("chuaDangKy", chuaDangKy);
        req.setAttribute("tongNhanSu", nhanSu.size());
        req.setAttribute("lichSuDiemDanh", lichSu);
        req.getRequestDispatcher("/manager/FaceSettings.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        TaiKhoan manager = getManager(req, resp);
        if (manager == null) return;

        if ("reset-face".equals(req.getParameter("action"))) {
            resetFace(req, manager);
            resp.sendRedirect(req.getContextPath() + "/manager/face-settings");
            return;
        }

        boolean faceRequired = "on".equals(req.getParameter("faceRequired")) || "true".equals(req.getParameter("faceRequired"));
        double confidenceMin = 0.6;
        try { confidenceMin = Double.parseDouble(req.getParameter("confidenceMin")); } catch (Exception ignored) {}
        confidenceMin = Math.max(0.35, Math.min(0.75, confidenceMin));

        CoSoFaceConfig config = new CoSoFaceConfig();
        config.setCoSoId(manager.getCoSoId());
        config.setFaceRequired(faceRequired);
        config.setConfidenceMin(confidenceMin);
        configDAO.upsert(config);

        req.getSession().setAttribute("flashSuccess", "Đã lưu cài đặt điểm danh khuôn mặt.");
        resp.sendRedirect(req.getContextPath() + "/manager/face-settings");
    }

    /**
     * Xóa đăng ký khuôn mặt của một nhân viên. Chỉ cho phép trên nhân sự cùng cơ sở
     * với manager và thuộc role được phép đăng ký khuôn mặt.
     */
    private void resetFace(HttpServletRequest req, TaiKhoan manager) {
        int targetId;
        try {
            targetId = Integer.parseInt(req.getParameter("accountId"));
        } catch (Exception e) {
            req.getSession().setAttribute("flashError", "Thiếu thông tin nhân viên.");
            return;
        }

        TaiKhoan target = taiKhoanDAO.getAccountById(targetId);
        if (target == null
                || target.getCoSoId() == null
                || !target.getCoSoId().equals(manager.getCoSoId())
                || !FACE_ROLES.contains(target.getRoleId())) {
            req.getSession().setAttribute("flashError", "Không có quyền thao tác trên nhân viên này.");
            return;
        }

        taiKhoanDAO.resetFaceData(targetId);
        req.getSession().setAttribute("flashSuccess",
                "Đã xóa đăng ký khuôn mặt của " + target.getFullName() + ". Nhân viên cần đăng ký lại.");
    }

    private TaiKhoan getManager(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        TaiKhoan user = session != null ? (TaiKhoan) session.getAttribute("user") : null;
        if (user == null || user.getRoleId() != Constants.ROLE_MANAGER || user.getCoSoId() == null) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return null;
        }
        return user;
    }
}
