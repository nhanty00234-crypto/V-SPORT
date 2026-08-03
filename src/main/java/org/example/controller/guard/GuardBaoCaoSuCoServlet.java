package org.example.controller.guard;

import org.example.dao.SanDAO;
import org.example.dao.SuCoDAO;
import org.example.dao.TaiKhoanDAO;
import org.example.dao.impl.SanDAOImpl;
import org.example.dao.impl.SuCoDAOImpl;
import org.example.dao.impl.TaiKhoanDAOImpl;
import org.example.model.San;
import org.example.model.SuCo;
import org.example.model.TaiKhoan;
import org.example.service.NotificationService;
import org.example.util.Constants;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.UUID;

@WebServlet("/guard/bao-cao-su-co")
@MultipartConfig(maxFileSize = 5 * 1024 * 1024, maxRequestSize = 10 * 1024 * 1024)
public class GuardBaoCaoSuCoServlet extends HttpServlet {

    private static final Logger log = LogManager.getLogger(GuardBaoCaoSuCoServlet.class);
    private final SuCoDAO suCoDAO = new SuCoDAOImpl();
    private final SanDAO sanDAO = new SanDAOImpl();
    private final TaiKhoanDAO taiKhoanDAO = new TaiKhoanDAOImpl();
    private final NotificationService notifService = new NotificationService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        TaiKhoan user = getUser(req, resp);
        if (user == null) return;

        List<San> danhSachSan = sanDAO.getSansByCoSo(user.getCoSoId());
        req.setAttribute("danhSachSan", danhSachSan);
        req.setAttribute("guardPage", "bao-cao-su-co");
        req.getRequestDispatcher("/guard/BaoCaoSuCo.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        TaiKhoan user = getUser(req, resp);
        if (user == null) return;

        String loai = req.getParameter("loaiSuCo");
        String mucDo = req.getParameter("mucDo");
        String moTa = req.getParameter("moTa");
        String sanIdStr = req.getParameter("sanId");

        if (loai == null || mucDo == null || moTa == null || moTa.trim().length() < 10) {
            req.getSession().setAttribute("flashError", "Vui lòng điền đầy đủ thông tin sự cố (mô tả tối thiểu 10 ký tự).");
            resp.sendRedirect(req.getContextPath() + "/guard/bao-cao-su-co");
            return;
        }

        SuCo suCo = new SuCo();
        suCo.setCoSoId(user.getCoSoId());
        suCo.setBaoVeId(user.getAccountId());
        suCo.setLoaiSuCo(loai);
        suCo.setMucDo(mucDo);
        suCo.setMoTa(moTa.trim());
        if (sanIdStr != null && !sanIdStr.isEmpty()) {
            try { suCo.setSanId(Integer.parseInt(sanIdStr)); } catch (NumberFormatException ignored) {}
        }

        // Upload ảnh nếu có
        Part filePart = req.getPart("anh");
        if (filePart != null && filePart.getSize() > 0) {
            String anhUrl = saveImage(filePart);
            suCo.setAnhUrl(anhUrl);
        }

        int newId = suCoDAO.insert(suCo);
        if (newId > 0) {
            notifyManagers(user.getCoSoId(), newId, suCo);
            req.getSession().setAttribute("flashSuccess", "Đã gửi báo cáo sự cố thành công!");
        } else {
            req.getSession().setAttribute("flashError", "Gửi báo cáo thất bại, vui lòng thử lại.");
        }
        resp.sendRedirect(req.getContextPath() + "/guard/lich-su-su-co");
    }

    private String saveImage(Part filePart) {
        try {
            String uploadPath = getServletContext().getRealPath("/uploads/su-co");
            if (uploadPath == null) {
                uploadPath = new File(System.getProperty("user.home"), "v-sport/uploads/su-co").getAbsolutePath();
            }
            File dir = new File(uploadPath);
            if (!dir.exists()) dir.mkdirs();
            String ext = getExt(filePart.getSubmittedFileName());
            String fileName = "sc_" + UUID.randomUUID().toString().replace("-", "") + ext;
            filePart.write(new File(dir, fileName).getAbsolutePath());
            return "/uploads/su-co/" + fileName;
        } catch (Exception e) {
            log.warn("Image upload failed for su-co", e);
            return null;
        }
    }

    private String getExt(String fileName) {
        if (fileName == null) return ".jpg";
        int dot = fileName.lastIndexOf('.');
        return dot >= 0 ? fileName.substring(dot) : ".jpg";
    }

    private void notifyManagers(int coSoId, int suCoId, SuCo suCo) {
        try {
            List<TaiKhoan> managers = taiKhoanDAO.getAccountsByCoSoAndRoleIn(coSoId, List.of(Constants.ROLE_MANAGER));
            String tieuDe = "[Sự cố] " + suCo.getLoaiSuCoDisplay() + " — Mức " + suCo.getMucDoDisplay();
            String noiDung = suCo.getMoTa().length() > 100 ? suCo.getMoTa().substring(0, 100) + "..." : suCo.getMoTa();
            for (TaiKhoan mgr : managers) {
                notifService.sendNotification(mgr.getAccountId(), tieuDe, noiDung, "SU_CO", String.valueOf(suCoId), "/guard/lich-su-su-co");
            }
        } catch (Exception e) {
            log.warn("Failed to notify managers for su-co #{}", suCoId, e);
        }
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
