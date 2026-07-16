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
import org.example.service.AuditLogService;
import org.example.service.admin.FacilityTrashService;

import java.io.IOException;
import java.util.List;

@WebServlet("/admin/thung-rac")
public class AdminTrashServlet extends HttpServlet {

    private static final Logger logger = LogManager.getLogger(AdminTrashServlet.class);
    private final AdminTrashDAO trashDAO = new AdminTrashDAOImpl();
    private final CoSoDAO coSoDAO = new CoSoDAOImpl();
    private final TaiKhoanDAO taiKhoanDAO = new TaiKhoanDAOImpl();
    private final FacilityTrashService facilityTrashService = new FacilityTrashService();

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
        if (scope == null || scope.isBlank()) {
            scope = "tatca";
        }

        // Chỉ lọc theo DeletedBy khi Admin chọn "Của tôi"; mặc định "Tất cả"
        // hiển thị toàn bộ để không ẩn mất dữ liệu có DeletedBy null/khác admin hiện tại.
        Integer deletedByFilter = "cuatoi".equals(scope) ? admin.getAccountId() : null;

        List<AdminTrash> items = trashDAO.search(entityType, restoredFilter, deletedByFilter);
        if (items == null) {
            items = java.util.Collections.emptyList();
        }
        logger.info("Admin trash loaded: scope={}, type={}, status={}, count={}",
                scope, entityType, restoredFilter, items.size());

        req.setAttribute("items", items);
        req.setAttribute("loai", entityType);
        req.setAttribute("thuhoi", restoredFilter);
        req.setAttribute("scope", scope);
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

        if ("CoSo".equals(item.getEntityType())) {
            // Dùng service transaction duy nhất (CoSo + AdminTrash cùng commit/rollback).
            FacilityTrashService.Result result = facilityTrashService.restoreFacility(trashId, admin.getAccountId());
            if (result.success) {
                session.setAttribute("message", result.message);
                AuditLogService.log(req, admin, null,
                        AuditLogService.ACTION_RESTORE, AuditLogService.ENTITY_CO_SO,
                        String.valueOf(item.getEntityId()), "CoSoID=" + item.getEntityId(),
                        "Admin khôi phục cơ sở từ thùng rác. Tài khoản hợp lệ (chưa bị khóa riêng) của cơ sở này có thể đăng nhập/thao tác trở lại.");
            } else {
                session.setAttribute("error", result.message);
            }
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
        // EntityType "CoSo" được xử lý riêng bởi FacilityTrashService.restoreFacility()
        // (transaction JDBC duy nhất) trước khi gọi tới hàm này — xem handleRestore().
        try {
            switch (item.getEntityType()) {
                case "Account": {
                    TaiKhoan acc = taiKhoanDAO.getAccountById(item.getEntityId());
                    if (acc == null) return false;
                    return taiKhoanDAO.restoreAccount(item.getEntityId());
                }
                case "OwnerRequest": {
                    CoSo coSo = coSoDAO.getCoSoById(item.getEntityId());
                    if (coSo == null) return false;
                    if (coSo.getAccountID_QuanLy() != null &&
                            coSoDAO.hasActiveOrPendingCoSo(coSo.getAccountID_QuanLy(), coSo.getCoSoID())) {
                        logger.warn("Không thể thu hồi OwnerRequest CoSoID={}: account đã có cơ sở khác đang hoạt động/chờ duyệt", coSo.getCoSoID());
                        return false;
                    }
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
