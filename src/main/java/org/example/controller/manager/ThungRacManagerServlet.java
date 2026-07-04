package org.example.controller.manager;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.dao.SanDAO;
import org.example.dao.LoaiSanDAO;
import org.example.dao.SanPhamDichVuDAO;
import org.example.dao.impl.SanDAOImpl;
import org.example.dao.impl.LoaiSanDAOImpl;
import org.example.dao.impl.SanPhamDichVuDAOImpl;
import org.example.model.San;
import org.example.model.LoaiSan;
import org.example.model.SanPham_DichVu;
import org.example.model.TaiKhoan;
import org.example.service.manager.NhanSuService;
import org.example.service.manager.NhanSuService.NhanSuDTO;
import org.example.service.AuditLogService;
import org.example.util.Constants;

import java.io.IOException;
import java.util.List;

@WebServlet("/manager/thung-rac")
public class ThungRacManagerServlet extends HttpServlet {
    private final SanDAO sanDAO = new SanDAOImpl();
    private final LoaiSanDAO loaiSanDAO = new LoaiSanDAOImpl();
    private final SanPhamDichVuDAO sanPhamDAO = new SanPhamDichVuDAOImpl();
    private final NhanSuService nhanSuService = new NhanSuService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        TaiKhoan user = (TaiKhoan) session.getAttribute("user");
        if (user == null || user.getRoleId() != Constants.ROLE_MANAGER) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return;
        }
        int coSoId = user.getCoSoId();

        List<San> deletedSans = sanDAO.findDeletedByCoSo(coSoId);
        List<LoaiSan> deletedLoaiSans = loaiSanDAO.findDeletedByCoSo(coSoId);
        List<SanPham_DichVu> deletedProducts = sanPhamDAO.findDeletedByCoSo(coSoId);
        List<NhanSuDTO> deletedStaff = nhanSuService.getDeletedStaffListByBranch(coSoId);

        req.setAttribute("deletedSans", deletedSans);
        req.setAttribute("deletedLoaiSans", deletedLoaiSans);
        req.setAttribute("deletedProducts", deletedProducts);
        req.setAttribute("deletedStaff", deletedStaff);

        req.getRequestDispatcher("/manager/ThungRac.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        TaiKhoan user = (TaiKhoan) session.getAttribute("user");
        if (user == null || user.getRoleId() != Constants.ROLE_MANAGER) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return;
        }
        int coSoId = user.getCoSoId();

        String action = req.getParameter("action");
        String type = req.getParameter("type"); // san, loaisan, sanpham, nhansu
        String idStr = req.getParameter("id");
        
        if (action == null || type == null || idStr == null) {
            session.setAttribute("errorMsg", "Yêu cầu không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/manager/thung-rac");
            return;
        }

        int id = Integer.parseInt(idStr);

        try {
            if ("restore".equals(action)) {
                boolean success = false;
                switch (type) {
                    case "san":
                        San san = sanDAO.getSanById(id);
                        if (san != null && san.getCoSoID() == coSoId) {
                            success = sanDAO.restore(id);
                        }
                        break;
                    case "loaisan":
                        LoaiSan ls = loaiSanDAO.getLoaiSanById(id);
                        if (ls != null && ls.getCoSoID() == coSoId) {
                            success = loaiSanDAO.restore(id);
                        }
                        break;
                    case "sanpham":
                        SanPham_DichVu sp = sanPhamDAO.findById(id);
                        if (sp != null && sp.getCoSoID() == coSoId) {
                            success = sanPhamDAO.restore(id);
                        }
                        break;
                    case "nhansu":
                        nhanSuService.restoreStaff(id, coSoId);
                        success = true;
                        break;
                }
                if (success) {
                    session.setAttribute("successMsg", "Khôi phục thành công.");
                    AuditLogService.log(req, user,
                        AuditLogService.ACTION_RESTORE, type.equals("nhansu") ? AuditLogService.ENTITY_ACCOUNT
                            : type.equals("san") ? AuditLogService.ENTITY_SAN
                            : type.equals("loaisan") ? AuditLogService.ENTITY_LOAI_SAN : AuditLogService.ENTITY_SAN_PHAM,
                        String.valueOf(id), "ID=" + id,
                        "Manager khôi phục từ thùng rác: loại=" + type);
                } else {
                    session.setAttribute("errorMsg", "Khôi phục thất bại.");
                }
            } 
            else if ("delete".equals(action)) { // Xóa vĩnh viễn
                boolean success = false;
                switch (type) {
                    case "san":
                        San san = sanDAO.getSanById(id);
                        if (san != null && san.getCoSoID() == coSoId) {
                            success = sanDAO.hardDelete(id);
                        }
                        break;
                    case "loaisan":
                        LoaiSan ls = loaiSanDAO.getLoaiSanById(id);
                        if (ls != null && ls.getCoSoID() == coSoId) {
                            success = loaiSanDAO.hardDelete(id);
                        }
                        break;
                    case "sanpham":
                        SanPham_DichVu sp = sanPhamDAO.findById(id);
                        if (sp != null && sp.getCoSoID() == coSoId) {
                            success = sanPhamDAO.hardDelete(id);
                        }
                        break;
                    case "nhansu":
                        nhanSuService.permanentlyDeleteStaff(id, coSoId);
                        success = true;
                        break;
                }
                if (success) {
                    session.setAttribute("successMsg", "Đã xóa vĩnh viễn dữ liệu thành công.");
                    AuditLogService.log(req, user,
                        AuditLogService.ACTION_PERMANENT_DELETE, type.equals("nhansu") ? AuditLogService.ENTITY_ACCOUNT
                            : type.equals("san") ? AuditLogService.ENTITY_SAN
                            : type.equals("loaisan") ? AuditLogService.ENTITY_LOAI_SAN : AuditLogService.ENTITY_SAN_PHAM,
                        String.valueOf(id), "ID=" + id,
                        "Manager xóa vĩnh viễn từ thùng rác: loại=" + type);
                } else {
                    session.setAttribute("errorMsg", "Không thể xóa vĩnh viễn dữ liệu.");
                }
            }
        } catch (Exception e) {
            session.setAttribute("errorMsg", "Lỗi: " + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/manager/thung-rac");
    }
}
