package org.example.controller.manager;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.example.dao.CoSoFaceConfigDAO;
import org.example.dao.impl.CoSoFaceConfigDAOImpl;
import org.example.model.CoSoFaceConfig;
import org.example.model.TaiKhoan;
import org.example.util.Constants;

import java.io.IOException;

@WebServlet("/manager/face-settings")
public class FaceSettingsServlet extends HttpServlet {

    private final CoSoFaceConfigDAO configDAO = new CoSoFaceConfigDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        TaiKhoan manager = getManager(req, resp);
        if (manager == null) return;

        CoSoFaceConfig config = configDAO.findByCoSo(manager.getCoSoId());
        if (config == null) {
            config = new CoSoFaceConfig();
            config.setCoSoId(manager.getCoSoId());
            config.setFaceRequired(false);
            config.setConfidenceMin(0.6);
        }
        req.setAttribute("faceConfig", config);
        req.getRequestDispatcher("/manager/FaceSettings.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        TaiKhoan manager = getManager(req, resp);
        if (manager == null) return;

        boolean faceRequired = "on".equals(req.getParameter("faceRequired")) || "true".equals(req.getParameter("faceRequired"));
        double confidenceMin = 0.6;
        try { confidenceMin = Double.parseDouble(req.getParameter("confidenceMin")); } catch (Exception ignored) {}
        confidenceMin = Math.max(0.4, Math.min(0.9, confidenceMin));

        CoSoFaceConfig config = new CoSoFaceConfig();
        config.setCoSoId(manager.getCoSoId());
        config.setFaceRequired(faceRequired);
        config.setConfidenceMin(confidenceMin);
        configDAO.upsert(config);

        req.getSession().setAttribute("flashSuccess", "Đã lưu cài đặt điểm danh khuôn mặt.");
        resp.sendRedirect(req.getContextPath() + "/manager/face-settings");
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
