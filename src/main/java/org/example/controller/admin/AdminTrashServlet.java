package org.example.controller.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.dao.AdminTrashDAO;
import org.example.dao.CoSoDAO;
import org.example.dao.TaiKhoanDAO;
import org.example.dao.impl.AdminTrashDAOImpl;
import org.example.dao.impl.CoSoDAOImpl;
import org.example.dao.impl.TaiKhoanDAOImpl;
import org.example.model.AdminTrash;
import org.example.model.CoSo;
import org.example.model.TaiKhoan;

import java.io.IOException;
import java.util.List;

@WebServlet("/admin/thung-rac")
public class AdminTrashServlet extends HttpServlet {

    private static final Logger logger = LogManager.getLogger(AdminTrashServlet.class);
    private final AdminTrashDAO trashDAO = new AdminTrashDAOImpl();
    private final CoSoDAO coSoDAO = new CoSoDAOImpl();
    private final TaiKhoanDAO taiKhoanDAO = new TaiKhoanDAOImpl();

    private TaiKhoan requireAdmin(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        TaiKhoan admin = session != null ? (TaiKhoan) session.getAttribute("user") : null;
        if (admin == null || admin.getRoleId() != 1) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return null;
        }
        return admin;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        TaiKhoan admin = requireAdmin(req, resp);
        if (admin == null) return;

        String entityType = req.getParameter("loai");
        String restoredFilter = req.getParameter("thuhoi");
        String scope = req.getParameter("scope");

        Integer deletedByFilter = "cuatoi".equals(scope) || scope == null ? admin.getAccountId() : null;

        List<AdminTrash> items = trashDAO.search(entityType, restoredFilter, deletedByFilter);

        req.setAttribute("items", items);
        req.setAttribute("loai", entityType);
        req.setAttribute("thuhoi", restoredFilter);
        req.setAttribute("scope", scope == null ? "cuatoi" : scope);
        req.getRequestDispatcher("/admin/ThungRacAdmin.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        TaiKhoan admin = requireAdmin(req, resp);
        if (admin == null) return;

        HttpSession session = req.getSession();
        String action = req.getParameter("action");

        if ("restore".equals(action)) {
            handleRestore(req, admin);
        }

        resp.sendRedirect(req.getContextPath() + "/admin/thung-rac");
    }

    private void handleRestore(HttpServletRequest req, TaiKhoan admin) {
        HttpSession session = req.getSession();
        int trashId;
        try {
            trashId = Integer.parseInt(req.getParameter("id"));
        } catch (NumberFormatException e) {
            session.setAttribute("error", "ID không hợp lệ.");
            return;
        }

        AdminTrash item = trashDAO.getById(trashId);
        if (item == null) {
            session.setAttribute("error", "Không tìm thấy mục trong thùng rác.");
            return;
        }
        if (item.isRestored()) {
            session.setAttribute("error", "Mục này đã được thu hồi trước đó.");
            return;
        }

        boolean restoredOk = restoreSource(item, admin.getAccountId());
        if (!restoredOk) {
            session.setAttribute("error", "Không thể thu hồi vì dữ liệu gốc không còn tồn tại.");
            return;
        }

        if (trashDAO.markRestored(trashId, admin.getAccountId())) {
            session.setAttribute("message", "Đã thu hồi thành công.");
        } else {
            session.setAttribute("error", "Không thể thu hồi vì dữ liệu gốc không còn tồn tại.");
        }
    }

    private boolean restoreSource(AdminTrash item, int actorId) {
        try {
            switch (item.getEntityType()) {
                case "CoSo": {
                    CoSo coSo = coSoDAO.getCoSoById(item.getEntityId());
                    if (coSo == null) return false;
                    if (item.getOldStatus() != null) {
                        coSo.setTrangThai(item.getOldStatus());
                    }
                    return coSoDAO.restore(item.getEntityId()) && coSoDAO.updateCoSo(coSo);
                }
                case "Account": {
                    TaiKhoan acc = taiKhoanDAO.getAccountById(item.getEntityId());
                    if (acc == null) return false;
                    return taiKhoanDAO.restoreAccount(item.getEntityId());
                }
                case "OwnerRequest": {
                    CoSo coSo = coSoDAO.getCoSoById(item.getEntityId());
                    if (coSo == null) return false;
                    coSo.setTrangThai(item.getOldStatus() != null ? item.getOldStatus() : "Chờ duyệt");
                    return coSoDAO.updateCoSo(coSo);
                }
                default:
                    logger.warn("Không hỗ trợ thu hồi EntityType={}", item.getEntityType());
                    return false;
            }
        } catch (Exception e) {
            logger.error("Lỗi thu hồi AdminTrash TrashID={}: {}", item.getTrashId(), e.getMessage(), e);
            return false;
        }
    }
}
