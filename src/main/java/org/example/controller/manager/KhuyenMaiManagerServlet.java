package org.example.controller.manager;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.dao.KhuyenMaiDAO;
import org.example.dao.impl.KhuyenMaiDAOImpl;
import org.example.model.KhuyenMai;
import org.example.model.TaiKhoan;
import org.example.service.AuditLogService;
import org.example.service.customer.PromotionStatusHelper;
import org.example.util.Constants;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Manager CRUD mã khuyến mãi tại cơ sở của mình. Chỉ thao tác trực tiếp trên bảng
 * KhuyenMai qua KhuyenMaiDAO — không đụng tới PromotionService.calculateDiscount
 * (logic tính giảm giá khi khách áp mã vẫn chỉ có một nơi duy nhất).
 */
@WebServlet("/manager/khuyen-mai")
public class KhuyenMaiManagerServlet extends HttpServlet {

    private final KhuyenMaiDAO khuyenMaiDAO = new KhuyenMaiDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        TaiKhoan user = (TaiKhoan) session.getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/he-thong/dang-nhap");
            return;
        }
        if (user.getRoleId() != Constants.ROLE_MANAGER) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập chức năng này.");
            return;
        }

        int coSoId = user.getCoSoId();
        List<KhuyenMai> all = khuyenMaiDAO.findByCoSoId(coSoId);

        String keyword = trim(req.getParameter("q"));
        String statusFilter = req.getParameter("status");
        if (statusFilter == null || statusFilter.isBlank()) statusFilter = "ALL";

        int countActive = 0, countUpcoming = 0, countExpired = 0, totalUsage = 0;
        List<KhuyenMai> filtered = new ArrayList<>();
        Map<Integer, String> displayStatusById = new LinkedHashMap<>();
        for (KhuyenMai km : all) {
            String displayStatus = PromotionStatusHelper.displayStatus(km);
            displayStatusById.put(km.getKhuyenMaiID(), displayStatus);
            totalUsage += km.getSoLanDaDung();
            switch (displayStatus) {
                case PromotionStatusHelper.DANG_HOAT_DONG: countActive++; break;
                case PromotionStatusHelper.SAP_DIEN_RA: countUpcoming++; break;
                case PromotionStatusHelper.DA_HET_HAN: countExpired++; break;
                default: break;
            }

            boolean matchesKeyword = keyword == null || keyword.isEmpty()
                    || (km.getMaCode() != null && km.getMaCode().toLowerCase().contains(keyword.toLowerCase()))
                    || (km.getMoTa() != null && km.getMoTa().toLowerCase().contains(keyword.toLowerCase()));

            boolean matchesStatus = "ALL".equals(statusFilter) || statusFilter.equals(statusToCode(displayStatus));

            if (matchesKeyword && matchesStatus) filtered.add(km);
        }

        String successMsg = (String) session.getAttribute("successMsg");
        String errorMsg = (String) session.getAttribute("errorMsg");
        session.removeAttribute("successMsg");
        session.removeAttribute("errorMsg");

        String editIdParam = req.getParameter("edit");
        KhuyenMai editing = null;
        if (editIdParam != null && !editIdParam.isBlank()) {
            try {
                editing = khuyenMaiDAO.findByIdAndCoSoId(Integer.parseInt(editIdParam.trim()), coSoId);
            } catch (NumberFormatException ignored) {
            }
        }

        req.setAttribute("promotions", filtered);
        req.setAttribute("kmDisplayStatus", displayStatusById);
        req.setAttribute("countActive", countActive);
        req.setAttribute("countUpcoming", countUpcoming);
        req.setAttribute("countExpired", countExpired);
        req.setAttribute("totalUsage", totalUsage);
        req.setAttribute("keyword", keyword == null ? "" : keyword);
        req.setAttribute("statusFilter", statusFilter);
        req.setAttribute("editing", editing);
        req.setAttribute("successMsg", successMsg);
        req.setAttribute("errorMsg", errorMsg);
        req.setAttribute("pageTitle", "Quản lý mã khuyến mãi");
        req.getRequestDispatcher("/manager/KhuyenMai.jsp").forward(req, resp);
    }

    private String statusToCode(String displayStatus) {
        if (PromotionStatusHelper.DANG_HOAT_DONG.equals(displayStatus)) return "ACTIVE";
        if (PromotionStatusHelper.SAP_DIEN_RA.equals(displayStatus)) return "UPCOMING";
        if (PromotionStatusHelper.DA_HET_HAN.equals(displayStatus)) return "EXPIRED";
        if (PromotionStatusHelper.TAM_KHOA.equals(displayStatus)) return "LOCKED";
        if (PromotionStatusHelper.HET_LUOT.equals(displayStatus)) return "EXHAUSTED";
        return "ALL";
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        TaiKhoan user = (TaiKhoan) session.getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/he-thong/dang-nhap");
            return;
        }
        if (user.getRoleId() != Constants.ROLE_MANAGER) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền thực hiện hành động này.");
            return;
        }

        int coSoId = user.getCoSoId();
        String action = req.getParameter("action");

        try {
            switch (action == null ? "" : action) {
                case "create":
                    handleCreate(req, session, user, coSoId);
                    break;
                case "update":
                    handleUpdate(req, session, user, coSoId);
                    break;
                case "toggle":
                    handleToggle(req, session, coSoId);
                    break;
                default:
                    session.setAttribute("errorMsg", "Hành động không hợp lệ.");
            }
        } catch (NumberFormatException e) {
            session.setAttribute("errorMsg", "Dữ liệu số không hợp lệ.");
        } catch (Exception e) {
            session.setAttribute("errorMsg", "Đã xảy ra lỗi hệ thống. Vui lòng thử lại.");
        }

        resp.sendRedirect(req.getContextPath() + "/manager/khuyen-mai");
    }

    private String validateForm(HttpServletRequest req, int coSoId, Integer excludeId) {
        String maCode = trim(req.getParameter("maCode"));
        String loaiGiam = trim(req.getParameter("loaiGiam"));
        String giaTriGiamStr = trim(req.getParameter("giaTriGiam"));
        String ngayBatDauStr = trim(req.getParameter("ngayBatDau"));
        String ngayKetThucStr = trim(req.getParameter("ngayKetThuc"));

        boolean exists = (excludeId != null && excludeId > 0) ? khuyenMaiDAO.existsByCodeExcluding(maCode, excludeId) : khuyenMaiDAO.existsByCode(maCode);
        if (exists) return "Mã khuyến mãi '" + maCode + "' đã tồn tại.";
        if (loaiGiam == null || (!loaiGiam.equals("PERCENT") && !loaiGiam.equals("FIXED") && !loaiGiam.equals("PhanTram") && !loaiGiam.equals("SoTien"))) return "Vui lòng chọn hình thức giảm.";

        double giaTriGiam;
        try {
            giaTriGiam = Double.parseDouble(giaTriGiamStr);
        } catch (Exception e) {
            return "Giá trị giảm không hợp lệ.";
        }
        if (giaTriGiam <= 0) return "Giá trị giảm phải lớn hơn 0.";
        if ("PERCENT".equals(loaiGiam) && giaTriGiam > 100) return "Phần trăm giảm không được vượt quá 100.";

        LocalDate ngayBatDau, ngayKetThuc;
        try {
            ngayBatDau = LocalDate.parse(ngayBatDauStr);
            ngayKetThuc = LocalDate.parse(ngayKetThucStr);
        } catch (Exception e) {
            return "Vui lòng nhập đầy đủ ngày bắt đầu và ngày kết thúc.";
        }
        if (ngayKetThuc.isBefore(ngayBatDau)) return "Ngày kết thúc phải sau ngày bắt đầu.";

        String soLanToiDaStr = trim(req.getParameter("soLanToiDa"));
        if (soLanToiDaStr != null && !soLanToiDaStr.isEmpty()) {
            try {
                int soLanToiDa = Integer.parseInt(soLanToiDaStr);
                if (soLanToiDa <= 0) return "Tổng lượt sử dụng phải lớn hơn 0.";
            } catch (Exception e) {
                return "Tổng lượt sử dụng không hợp lệ.";
            }
        }

        String giaTriToiThieuStr = trim(req.getParameter("giaTriToiThieu"));
        if (giaTriToiThieuStr != null && !giaTriToiThieuStr.isEmpty()) {
            try {
                if (new BigDecimal(giaTriToiThieuStr).signum() < 0) return "Giá trị đơn tối thiểu không được âm.";
            } catch (Exception e) {
                return "Giá trị đơn tối thiểu không hợp lệ.";
            }
        }

        String giamToiDaStr = trim(req.getParameter("giamToiDa"));
        if (giamToiDaStr != null && !giamToiDaStr.isEmpty()) {
            try {
                if (new BigDecimal(giamToiDaStr).signum() < 0) return "Mức giảm tối đa không được âm.";
            } catch (Exception e) {
                return "Mức giảm tối đa không hợp lệ.";
            }
        }

        return null;
    }

    private KhuyenMai buildFromRequest(HttpServletRequest req) {
        KhuyenMai km = new KhuyenMai();
        km.setMaCode(trim(req.getParameter("maCode")).toUpperCase());
        km.setMoTa(trim(req.getParameter("moTa")));
        km.setLoaiGiam(trim(req.getParameter("loaiGiam")));
        km.setGiaTriGiam(Double.parseDouble(trim(req.getParameter("giaTriGiam"))));
        km.setNgayBatDau(LocalDate.parse(trim(req.getParameter("ngayBatDau"))));
        km.setNgayKetThuc(LocalDate.parse(trim(req.getParameter("ngayKetThuc"))));
        String soLanToiDaStr = trim(req.getParameter("soLanToiDa"));
        km.setSoLanToiDa(soLanToiDaStr != null && !soLanToiDaStr.isEmpty() ? Integer.parseInt(soLanToiDaStr) : null);
        String giaTriToiThieuStr = trim(req.getParameter("giaTriToiThieu"));
        km.setGiaTriToiThieu(giaTriToiThieuStr != null && !giaTriToiThieuStr.isEmpty() ? new BigDecimal(giaTriToiThieuStr) : null);
        String giamToiDaStr = trim(req.getParameter("giamToiDa"));
        km.setGiamToiDa(giamToiDaStr != null && !giamToiDaStr.isEmpty() ? new BigDecimal(giamToiDaStr) : null);
        km.setTrangThai("on".equals(req.getParameter("trangThaiHoatDong")) || "true".equals(req.getParameter("trangThaiHoatDong"))
                ? Constants.TRANG_THAI_KM_HOAT_DONG : Constants.TRANG_THAI_KM_TAM_DUNG);
        return km;
    }

    private void handleCreate(HttpServletRequest req, HttpSession session, TaiKhoan user, int coSoId) {
        String validationError = validateForm(req, coSoId, null);
        if (validationError != null) {
            session.setAttribute("errorMsg", validationError);
            return;
        }
        KhuyenMai km = buildFromRequest(req);
        km.setCoSoID(coSoId);
        int newId = khuyenMaiDAO.insert(km);
        if (newId > 0) {
            session.setAttribute("successMsg", "Đã tạo mã khuyến mãi '" + km.getMaCode() + "'.");
            AuditLogService.log(req, user, AuditLogService.ACTION_CREATE, "KhuyenMai",
                    String.valueOf(newId), km.getMaCode(), "Manager tạo mã khuyến mãi");
        } else {
            session.setAttribute("errorMsg", "Không thể tạo mã khuyến mãi. Vui lòng thử lại.");
        }
    }

    private void handleUpdate(HttpServletRequest req, HttpSession session, TaiKhoan user, int coSoId) {
        int id = Integer.parseInt(req.getParameter("khuyenMaiId"));
        KhuyenMai existing = khuyenMaiDAO.findByIdAndCoSoId(id, coSoId);
        if (existing == null) {
            session.setAttribute("errorMsg", "Không tìm thấy mã khuyến mãi.");
            return;
        }
        String validationError = validateForm(req, coSoId, id);
        if (validationError != null) {
            session.setAttribute("errorMsg", validationError);
            return;
        }
        KhuyenMai km = buildFromRequest(req);
        km.setKhuyenMaiID(id);
        km.setCoSoID(coSoId);
        boolean ok = khuyenMaiDAO.update(km);
        if (ok) {
            session.setAttribute("successMsg", "Đã cập nhật mã khuyến mãi '" + km.getMaCode() + "'.");
            AuditLogService.log(req, user, AuditLogService.ACTION_UPDATE, "KhuyenMai",
                    String.valueOf(id), km.getMaCode(), "Manager cập nhật mã khuyến mãi");
        } else {
            session.setAttribute("errorMsg", "Không thể cập nhật mã khuyến mãi. Vui lòng thử lại.");
        }
    }

    private void handleToggle(HttpServletRequest req, HttpSession session, int coSoId) {
        int id = Integer.parseInt(req.getParameter("khuyenMaiId"));
        boolean activate = "1".equals(req.getParameter("value"));
        String trangThai = activate ? Constants.TRANG_THAI_KM_HOAT_DONG : Constants.TRANG_THAI_KM_TAM_DUNG;
        boolean ok = khuyenMaiDAO.updateTrangThai(id, coSoId, trangThai);
        if (ok) {
            session.setAttribute("successMsg", activate ? "Đã bật mã khuyến mãi." : "Đã tạm khóa mã khuyến mãi.");
        } else {
            session.setAttribute("errorMsg", "Không thể cập nhật trạng thái mã khuyến mãi.");
        }
    }

    private static String trim(String s) {
        return s == null ? null : s.trim();
    }
}
