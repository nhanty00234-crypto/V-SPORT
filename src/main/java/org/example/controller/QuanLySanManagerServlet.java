package org.example.controller;

import org.example.model.LoaiSan;
import org.example.model.MonTheThao;
import org.example.model.San;
import org.example.model.TaiKhoan;
import org.example.service.manager.SanService;
import org.example.util.Constants;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.service.AuditLogService;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalTime;
import java.util.List;

/**
 * Servlet quản lý sân thi đấu dành cho Manager
 * Business logic được delegate cho SanService
 */
@WebServlet("/manager/quan-ly-san")
public class QuanLySanManagerServlet extends HttpServlet {

    private static final Logger logger = LogManager.getLogger(QuanLySanManagerServlet.class);

    private final SanService sanService;

    public QuanLySanManagerServlet() {
        this.sanService = new SanService();
    }

    public QuanLySanManagerServlet(SanService sanService) {
        this.sanService = sanService;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();

        TaiKhoan manager = (TaiKhoan) session.getAttribute("user");
        if (manager == null || manager.getRoleId() != Constants.ROLE_MANAGER) {
            response.sendRedirect(request.getContextPath() + "/dangnhap");
            return;
        }

        Integer coSoId = manager.getCoSoId();
        if (coSoId == null) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                "Tài khoản quản lý chưa được liên kết với cơ sở nào.");
            return;
        }

        try {
            List<San> dsSan = sanService.getSansByCoSo(coSoId);
            List<LoaiSan> dsLoaiSan = sanService.getLoaiSansByCoSo(coSoId);
            List<MonTheThao> dsMonTheThao = sanService.getAllMonTheThao();

            request.setAttribute("dsSan", dsSan);
            request.setAttribute("dsLoaiSan", dsLoaiSan);
            request.setAttribute("dsMonTheThao", dsMonTheThao);
            request.setAttribute("managerCoSoId", coSoId);

            request.getRequestDispatcher("/manager/QuanLySan.jsp").forward(request, response);

        } catch (Exception e) {
            logger.error("Error in doGet: {}", e.getMessage(), e);
            session.setAttribute("error", "Lỗi khi tải dữ liệu: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/manager/quan-ly-san");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();

        TaiKhoan manager = (TaiKhoan) session.getAttribute("user");
        if (manager == null || manager.getRoleId() != Constants.ROLE_MANAGER) {
            response.sendRedirect(request.getContextPath() + "/dangnhap");
            return;
        }

        Integer coSoId = manager.getCoSoId();
        if (coSoId == null) {
            session.setAttribute("error", "Tài khoản quản lý chưa được liên kết với cơ sở nào.");
            response.sendRedirect(request.getContextPath() + "/manager/quan-ly-san");
            return;
        }

        String action = request.getParameter("action");

        try {
            switch (action) {
                case "add" -> handleAddSan(request, coSoId, session, manager);
                case "update" -> handleUpdateSan(request, coSoId, session, manager);
                case "delete" -> handleDeleteSan(request, coSoId, session, manager);
                case "updateStatus" -> handleUpdateSanStatus(request, coSoId, session);
                case "addType" -> handleAddLoaiSan(request, coSoId, session, manager);
                case "updateType" -> handleUpdateLoaiSan(request, coSoId, session);
                case "deleteType" -> handleDeleteLoaiSan(request, coSoId, session, manager);
                default -> logger.warn("Unknown action: {}", action);
            }
        } catch (IllegalArgumentException e) {
            logger.warn("Lỗi xử lý sân: {}", e.getMessage(), e);
            session.setAttribute("error", e.getMessage());
        } catch (Exception e) {
            logger.error("Unexpected error in doPost: {}", e.getMessage(), e);
            session.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/manager/quan-ly-san");
    }

    // ==================== HANDLER METHODS ====================

    private void handleAddSan(HttpServletRequest req, int coSoId, HttpSession session, TaiKhoan manager) {
        int soLuong = 1;
        String soLuongParam = req.getParameter("soLuong");
        if (soLuongParam != null && !soLuongParam.isBlank()) {
            soLuong = Math.max(1, Math.min(10, Integer.parseInt(soLuongParam)));
        }

        SanService.SanCreateRequest createReq = new SanService.SanCreateRequest();
        populateSanRequest(req, createReq);

        String baseName = createReq.getTenSan() == null ? "" : createReq.getTenSan().trim();
        for (int i = 1; i <= soLuong; i++) {
            if (soLuong > 1) createReq.setTenSan(baseName + " " + i);
            San san = sanService.createSan(createReq, coSoId);
            AuditLogService.log(req, manager,
                AuditLogService.ACTION_CREATE, AuditLogService.ENTITY_SAN,
                String.valueOf(san.getSanID()), san.getTenSan(),
                "Manager tạo sân mới");
        }

        String msg = soLuong > 1
            ? "Đã tạo " + soLuong + " sân thành công!"
            : "Thêm sân thành công!";
        session.setAttribute("message", msg);
    }

    private void handleUpdateSan(HttpServletRequest req, int coSoId, HttpSession session, TaiKhoan manager) {
        int sanId = Integer.parseInt(req.getParameter("sanID"));
        String tenSan = req.getParameter("tenSan");

        SanService.SanUpdateRequest updateReq = new SanService.SanUpdateRequest();
        populateSanUpdateRequest(req, updateReq);

        sanService.updateSan(sanId, updateReq, coSoId);
        session.setAttribute("message", "Cập nhật sân thành công!");
        AuditLogService.log(req, manager,
            AuditLogService.ACTION_UPDATE, AuditLogService.ENTITY_SAN,
            String.valueOf(sanId), tenSan,
            "Manager cập nhật thông tin sân");
    }

    private void handleDeleteSan(HttpServletRequest req, int coSoId, HttpSession session, TaiKhoan manager) {
        int sanId = Integer.parseInt(req.getParameter("sanID"));
        String tenSan = req.getParameter("tenSan");
        sanService.deleteSan(sanId, coSoId);
        session.setAttribute("message", "Đã chuyển sân thi đấu vào Thùng rác. Bạn có thể vào trang Thùng rác để khôi phục.");
        AuditLogService.log(req, manager,
            AuditLogService.ACTION_SOFT_DELETE, AuditLogService.ENTITY_SAN,
            String.valueOf(sanId), tenSan != null ? tenSan : "ID=" + sanId,
            "Manager xóa mềm sân");
    }


    private void handleUpdateSanStatus(HttpServletRequest req, int coSoId, HttpSession session) {
        int sanId = Integer.parseInt(req.getParameter("sanID"));
        String newStatus = req.getParameter("trangThai");
        sanService.updateSanStatus(sanId, newStatus, coSoId);
        session.setAttribute("message", "Đã cập nhật trạng thái sân thành công!");
    }

    private void handleAddLoaiSan(HttpServletRequest req, int coSoId, HttpSession session, TaiKhoan manager) {
        SanService.LoaiSanRequest createReq = new SanService.LoaiSanRequest();
        populateLoaiSanRequest(req, createReq);

        LoaiSan ls = sanService.createLoaiSan(createReq, coSoId);
        session.setAttribute("message", "Thêm cấu hình loại sân thành công!");
        AuditLogService.log(req, manager,
            AuditLogService.ACTION_CREATE, AuditLogService.ENTITY_LOAI_SAN,
            String.valueOf(ls.getLoaiSanID()), ls.getTenLoai(),
            "Manager tạo loại sân mới");
    }

    private void handleUpdateLoaiSan(HttpServletRequest req, int coSoId, HttpSession session) {
        int loaiSanId = Integer.parseInt(req.getParameter("loaiSanID"));

        SanService.LoaiSanRequest updateReq = new SanService.LoaiSanRequest();
        populateLoaiSanRequest(req, updateReq);

        sanService.updateLoaiSan(loaiSanId, updateReq, coSoId);
        session.setAttribute("message", "Cập nhật loại sân thành công!");
    }

    private void handleDeleteLoaiSan(HttpServletRequest req, int coSoId, HttpSession session, TaiKhoan manager) {
        int loaiSanId = Integer.parseInt(req.getParameter("loaiSanID"));
        LoaiSan loaiSan = sanService.getLoaiSanById(loaiSanId);
        String loaiSanName = loaiSan != null && loaiSan.getTenLoai() != null ? loaiSan.getTenLoai() : "ID=" + loaiSanId;
        sanService.deleteLoaiSan(loaiSanId, coSoId);
        session.setAttribute("message", "Đã chuyển cấu hình loại sân vào Thùng rác. Bạn có thể vào trang Thùng rác để khôi phục.");
        AuditLogService.log(req, manager,
            AuditLogService.ACTION_SOFT_DELETE, AuditLogService.ENTITY_LOAI_SAN,
            String.valueOf(loaiSanId), loaiSanName,
            "Manager xóa mềm loại sân");
    }


    // ==================== REQUEST POPULATORS ====================

    private void populateSanRequest(HttpServletRequest req, SanService.SanCreateRequest createReq) {
        createReq.setTenSan(req.getParameter("tenSan"));
        createReq.setLoaiSanId(Integer.parseInt(req.getParameter("loaiSanID")));
        createReq.setTrangThai(req.getParameter("trangThai"));
        createReq.setMoTa(req.getParameter("moTa"));
        createReq.setHinhAnh(req.getParameter("hinhAnh"));
    }

    private void populateSanUpdateRequest(HttpServletRequest req, SanService.SanUpdateRequest updateReq) {
        updateReq.setTenSan(req.getParameter("tenSan"));
        updateReq.setLoaiSanId(Integer.parseInt(req.getParameter("loaiSanID")));
        updateReq.setTrangThai(req.getParameter("trangThai"));
        updateReq.setMoTa(req.getParameter("moTa"));
        updateReq.setHinhAnh(req.getParameter("hinhAnh"));
    }

    private void populateLoaiSanRequest(HttpServletRequest req, SanService.LoaiSanRequest loaiReq) {
        loaiReq.setTenLoai(req.getParameter("tenLoai"));
        loaiReq.setMonTheThaoId(Integer.parseInt(req.getParameter("monTheThaoID")));
        loaiReq.setGiaKhongDen(new BigDecimal(req.getParameter("giaKhongDen")));
        loaiReq.setGiaCoDen(new BigDecimal(req.getParameter("giaCoDen")));

        String timeStr = req.getParameter("gioBatDauLenDen");
        if (timeStr != null && !timeStr.isEmpty()) {
            if (timeStr.length() == 5) timeStr += ":00";
            loaiReq.setGioBatDauLenDen(LocalTime.parse(timeStr));
        }

        String endTimeStr = req.getParameter("gioKetThucLenDen");
        if (endTimeStr != null && !endTimeStr.isEmpty()) {
            if (endTimeStr.length() == 5) endTimeStr += ":00";
            loaiReq.setGioKetThucLenDen(LocalTime.parse(endTimeStr));
        }
    }
}
