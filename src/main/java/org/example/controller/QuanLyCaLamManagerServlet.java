package org.example.controller;

import org.example.model.CaLamViec;
import org.example.model.TaiKhoan;
import org.example.service.manager.CaLamService;
import org.example.util.Constants;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

/**
 * Servlet quản lý ca làm việc dành cho Manager
 */
@WebServlet("/manager/ca-lam")
public class QuanLyCaLamManagerServlet extends HttpServlet {

    private static final Logger logger = LogManager.getLogger(QuanLyCaLamManagerServlet.class);

    private final CaLamService caLamService;

    public QuanLyCaLamManagerServlet() {
        this.caLamService = new CaLamService();
    }

    public QuanLyCaLamManagerServlet(CaLamService caLamService) {
        this.caLamService = caLamService;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession();

        TaiKhoan manager = (TaiKhoan) session.getAttribute("user");
        if (!isAuthorizedManager(manager, req, resp, session)) {
            return;
        }

        String action = req.getParameter("action");
        if ("validate".equals(action)) {
            handleValidate(req, resp);
            return;
        }

        Integer managerCoSoId = manager.getCoSoId();
        if (managerCoSoId == null) {
            session.setAttribute("error", "Không tìm thấy thông tin cơ sở của quản lý.");
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return;
        }

        try {
            List<CaLamViec> shifts = caLamService.getShiftsByBranch(managerCoSoId);
            List<TaiKhoan> staffs = caLamService.getStaffAvailableForShift(managerCoSoId);

            // Check if JSON format requested
            String format = req.getParameter("format");
            if ("json".equals(format)) {
                List<org.example.model.CaLamViecAudit> audits = caLamService.getAuditLogs(managerCoSoId);
                List<org.example.model.CaLamViecAvailability> avails = caLamService.getAvailabilityByBranch(managerCoSoId, LocalDate.now().minusDays(30), LocalDate.now().plusDays(30));
                List<org.example.model.CaLamViecSwapRequest> swaps = caLamService.getSwapRequestsByBranch(managerCoSoId);
                List<org.example.model.CoSo> coSos = caLamService.getAllCoSo();

                resp.setContentType("application/json");
                resp.setCharacterEncoding("UTF-8");
                String json = buildJsonResponse(shifts, staffs, audits, avails, swaps, coSos);
                resp.getWriter().write(json);
                return;
            }

            resp.sendRedirect(req.getContextPath() + "/manager/nhan-su?tab=schedule");
        } catch (Exception e) {
            logger.error("Error in doGet: {}", e.getMessage(), e);
            session.setAttribute("error", "Lỗi khi tải dữ liệu: " + e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/manager/nhan-su?tab=schedule");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession();

        TaiKhoan manager = (TaiKhoan) session.getAttribute("user");
        if (!isAuthorizedManager(manager, req, resp, session)) {
            return;
        }

        Integer managerCoSoId = manager.getCoSoId();
        if (managerCoSoId == null) {
            boolean isJson = "json".equals(req.getParameter("format"));
            if (isJson) {
                resp.setContentType("application/json");
                resp.setCharacterEncoding("UTF-8");
                resp.getWriter().write("{\"success\":false,\"error\":\"Tài khoản quản lý chưa được liên kết với cơ sở nào.\"}");
            } else {
                session.setAttribute("error", "Tài khoản quản lý chưa được liên kết với cơ sở nào.");
                resp.sendRedirect(req.getContextPath() + "/manager/nhan-su?tab=schedule");
            }
            return;
        }

        String action = req.getParameter("action");

        try {
            if ("delete".equals(action)) {
                handleDelete(req, resp, session, manager, managerCoSoId);
            } else if ("add".equals(action) || "update".equals(action)) {
                handleAddOrUpdate(req, resp, session, manager, managerCoSoId, action);
            } else {
                boolean isJson = "json".equals(req.getParameter("format"));
                String successMsg = null;
                
                if ("cloneWeek".equals(action)) {
                    LocalDate fromWeek = LocalDate.parse(req.getParameter("fromWeek"));
                    LocalDate toWeek = LocalDate.parse(req.getParameter("toWeek"));
                    caLamService.cloneWeekShifts(fromWeek, toWeek, managerCoSoId, manager.getAccountId());
                    successMsg = "Nhân bản lịch tuần thành công!";
                } else if ("publishWeek".equals(action)) {
                    LocalDate weekStart = LocalDate.parse(req.getParameter("weekStart"));
                    caLamService.publishWeekShifts(weekStart, managerCoSoId, manager.getAccountId());
                    successMsg = "Công bố lịch làm việc thành công!";
                } else if ("approveSwap".equals(action)) {
                    int swapId = Integer.parseInt(req.getParameter("id"));
                    String notes = req.getParameter("notes");
                    caLamService.approveSwapRequest(swapId, manager.getAccountId(), notes);
                    successMsg = "Đã phê duyệt yêu cầu đổi ca!";
                } else if ("rejectSwap".equals(action)) {
                    int swapId = Integer.parseInt(req.getParameter("id"));
                    String notes = req.getParameter("notes");
                    caLamService.rejectSwapRequest(swapId, manager.getAccountId(), notes);
                    successMsg = "Đã từ chối yêu cầu đổi ca!";
                } else {
                    throw new IllegalArgumentException("Hành động không hợp lệ: " + action);
                }

                if (isJson) {
                    resp.setContentType("application/json");
                    resp.setCharacterEncoding("UTF-8");
                    resp.getWriter().write("{\"success\":true,\"message\":\"" + escapeJson(successMsg) + "\"}");
                } else {
                    session.setAttribute("message", successMsg);
                    resp.sendRedirect(req.getContextPath() + "/manager/nhan-su?tab=schedule");
                }
            }
        } catch (IllegalArgumentException e) {
            logger.warn("Lỗi xử lý ca làm: {}", e.getMessage(), e);
            boolean isJson = "json".equals(req.getParameter("format"));
            if (isJson) {
                resp.setContentType("application/json");
                resp.setCharacterEncoding("UTF-8");
                resp.getWriter().write("{\"success\":false,\"error\":\"" + escapeJson(e.getMessage()) + "\"}");
            } else {
                session.setAttribute("error", e.getMessage());
                resp.sendRedirect(req.getContextPath() + "/manager/nhan-su?tab=schedule");
            }
        } catch (Exception e) {
            logger.error("Unexpected error in doPost: {}", e.getMessage(), e);
            boolean isJson = "json".equals(req.getParameter("format"));
            if (isJson) {
                resp.setContentType("application/json");
                resp.setCharacterEncoding("UTF-8");
                resp.getWriter().write("{\"success\":false,\"error\":\"Lỗi hệ thống: " + escapeJson(e.getMessage()) + "\"}");
            } else {
                session.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
                resp.sendRedirect(req.getContextPath() + "/manager/nhan-su?tab=schedule");
            }
        }
    }

    private boolean isAuthorizedManager(TaiKhoan manager, HttpServletRequest req,
                                        HttpServletResponse resp, HttpSession session)
            throws IOException {
        if (manager == null || manager.getRoleId() != Constants.ROLE_MANAGER) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return false;
        }
        return true;
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp,
                              HttpSession session, TaiKhoan manager, int managerCoSoId) throws IOException {
        String idParam = req.getParameter("id");
        String reason = req.getParameter("reason");
        boolean isJson = "json".equals(req.getParameter("format"));
        String errorMsg = null;
        String successMsg = null;

        if (idParam == null || idParam.trim().isEmpty()) {
            errorMsg = "ID ca làm việc không hợp lệ.";
        } else {
            try {
                int id = Integer.parseInt(idParam);
                caLamService.deleteShift(id, managerCoSoId, manager.getAccountId(), reason);
                successMsg = "Xóa ca làm việc thành công!";
            } catch (NumberFormatException e) {
                errorMsg = "ID ca làm việc không hợp lệ.";
            } catch (Exception e) {
                errorMsg = e.getMessage();
            }
        }

        if (isJson) {
            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            if (errorMsg != null) {
                resp.getWriter().write("{\"success\":false,\"error\":\"" + escapeJson(errorMsg) + "\"}");
            } else {
                resp.getWriter().write("{\"success\":true,\"message\":\"" + escapeJson(successMsg) + "\"}");
            }
        } else {
            if (errorMsg != null) {
                session.setAttribute("error", errorMsg);
            } else {
                session.setAttribute("message", successMsg);
            }
            resp.sendRedirect(req.getContextPath() + "/manager/nhan-su?tab=schedule");
        }
    }

    private void handleAddOrUpdate(HttpServletRequest req, HttpServletResponse resp,
                                   HttpSession session, TaiKhoan manager, int managerCoSoId,
                                   String action) throws IOException {
        boolean isJson = "json".equals(req.getParameter("format"));
        String errorMsg = null;
        String successMsg = null;

        try {
            CaLamService.CaLamRequest caLamReq = parseCaLamRequest(req);

            if ("add".equals(action)) {
                caLamService.createShift(caLamReq, managerCoSoId, manager.getAccountId());
                successMsg = "Thêm ca làm việc thành công!";
            } else {
                String caLamViecIdParam = req.getParameter("caLamViecId");
                String reason = req.getParameter("reason");
                if (caLamViecIdParam == null || caLamViecIdParam.trim().isEmpty()) {
                    throw new IllegalArgumentException("ID ca làm việc không hợp lệ.");
                }
                int caLamViecId = Integer.parseInt(caLamViecIdParam);
                caLamService.updateShift(caLamViecId, caLamReq, managerCoSoId, manager.getAccountId(), reason);
                successMsg = "Cập nhật ca làm việc thành công!";
            }
        } catch (IllegalArgumentException e) {
            errorMsg = e.getMessage();
        } catch (Exception e) {
            errorMsg = "Lỗi hệ thống: " + e.getMessage();
        }

        if (isJson) {
            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            if (errorMsg != null) {
                resp.getWriter().write("{\"success\":false,\"error\":\"" + escapeJson(errorMsg) + "\"}");
            } else {
                resp.getWriter().write("{\"success\":true,\"message\":\"" + escapeJson(successMsg) + "\"}");
            }
        } else {
            if (errorMsg != null) {
                session.setAttribute("error", errorMsg);
            } else {
                session.setAttribute("message", successMsg);
            }
            resp.sendRedirect(req.getContextPath() + "/manager/nhan-su?tab=schedule");
        }
    }

    private CaLamService.CaLamRequest parseCaLamRequest(HttpServletRequest req) {
        CaLamService.CaLamRequest request = new CaLamService.CaLamRequest();

        String accountIdParam = req.getParameter("accountId");
        String ngayLamParam = req.getParameter("ngayLam");
        String gioBatDauParam = req.getParameter("gioBatDau");
        String gioKetThucParam = req.getParameter("gioKetThuc");

        if (accountIdParam == null || ngayLamParam == null ||
            gioBatDauParam == null || gioKetThucParam == null) {
            throw new IllegalArgumentException("Thiếu thông tin bắt buộc từ form");
        }

        request.setAccountId(Integer.parseInt(accountIdParam));
        request.setNgayLam(LocalDate.parse(ngayLamParam));
        request.setGioBatDau(LocalTime.parse(gioBatDauParam));
        request.setGioKetThuc(LocalTime.parse(gioKetThucParam));
        request.setGhiChu(req.getParameter("ghiChu"));

        // New fields parsing
        String coSoIdParam = req.getParameter("coSoId");
        if (coSoIdParam != null && !coSoIdParam.trim().isEmpty()) {
            request.setCoSoId(Integer.parseInt(coSoIdParam));
        }

        request.setTenCa(req.getParameter("tenCa"));
        request.setViTri(req.getParameter("viTri"));
        request.setTrangThai(req.getParameter("trangThai"));

        String gioNghiParam = req.getParameter("gioNghi");
        if (gioNghiParam != null && !gioNghiParam.trim().isEmpty()) {
            request.setGioNghi(Integer.parseInt(gioNghiParam));
        } else {
            request.setGioNghi(0);
        }

        String repeatTypeParam = req.getParameter("repeatType");
        if (repeatTypeParam != null && !repeatTypeParam.trim().isEmpty()) {
            request.setRepeatType(repeatTypeParam);
        }

        String repeatUntilParam = req.getParameter("repeatUntil");
        if (repeatUntilParam != null && !repeatUntilParam.trim().isEmpty()) {
            request.setRepeatUntil(LocalDate.parse(repeatUntilParam));
        }

        return request;
    }

    private void handleValidate(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        
        try {
            int accountId = Integer.parseInt(req.getParameter("accountId"));
            LocalDate ngayLam = LocalDate.parse(req.getParameter("ngayLam"));
            LocalTime gioBatDau = LocalTime.parse(req.getParameter("gioBatDau"));
            LocalTime gioKetThuc = LocalTime.parse(req.getParameter("gioKetThuc"));
            
            int gioNghi = 0;
            String gioNghiParam = req.getParameter("gioNghi");
            if (gioNghiParam != null && !gioNghiParam.trim().isEmpty()) {
                gioNghi = Integer.parseInt(gioNghiParam);
            }
            
            Integer caLamViecId = null;
            String caLamViecIdParam = req.getParameter("caLamViecId");
            if (caLamViecIdParam != null && !caLamViecIdParam.trim().isEmpty()) {
                caLamViecId = Integer.parseInt(caLamViecIdParam);
            }
            
            org.example.util.CaLamValidationEngine.ValidationResult result = 
                caLamService.validateShiftAssignment(accountId, ngayLam, gioBatDau, gioKetThuc, gioNghi, caLamViecId);
            
            StringBuilder json = new StringBuilder();
            json.append("{");
            json.append("\"valid\":").append(result.isValid()).append(",");
            
            json.append("\"errors\":[");
            for (int i = 0; i < result.getErrors().size(); i++) {
                if (i > 0) json.append(",");
                json.append("\"").append(escapeJson(result.getErrors().get(i))).append("\"");
            }
            json.append("],");
            
            json.append("\"warnings\":[");
            for (int i = 0; i < result.getWarnings().size(); i++) {
                if (i > 0) json.append(",");
                json.append("\"").append(escapeJson(result.getWarnings().get(i))).append("\"");
            }
            json.append("]");
            json.append("}");
            
            resp.getWriter().write(json.toString());
        } catch (Exception e) {
            resp.getWriter().write("{\"valid\":false,\"errors\":[\"Lỗi tham số validation: " + escapeJson(e.getMessage()) + "\"],\"warnings\":[]}");
        }
    }

    private String buildJsonResponse(List<CaLamViec> shifts, List<TaiKhoan> staffs,
                                      List<org.example.model.CaLamViecAudit> audits,
                                      List<org.example.model.CaLamViecAvailability> avails,
                                      List<org.example.model.CaLamViecSwapRequest> swaps,
                                      List<org.example.model.CoSo> branches) throws Exception {
        StringBuilder json = new StringBuilder();
        json.append("{\"shifts\":[");

        for (int i = 0; i < shifts.size(); i++) {
            CaLamViec s = shifts.get(i);
            if (i > 0) json.append(",");
            json.append("{");
            json.append("\"caLamViecId\":").append(s.getCaLamViecId()).append(",");
            json.append("\"accountId\":").append(s.getAccountId()).append(",");
            json.append("\"coSoId\":").append(s.getCoSoId()).append(",");
            json.append("\"ngayLam\":\"").append(s.getNgayLam()).append("\",");
            json.append("\"gioBatDau\":\"").append(s.getGioBatDau()).append("\",");
            json.append("\"gioKetThuc\":\"").append(s.getGioKetThuc()).append("\",");
            json.append("\"isPublished\":").append(s.isPublished() ? "true" : "false").append(",");
            json.append("\"tenCa\":\"").append(escapeJson(s.getTenCa())).append("\",");
            json.append("\"viTri\":\"").append(escapeJson(s.getViTri())).append("\",");
            json.append("\"trangThai\":\"").append(escapeJson(s.getTrangThai())).append("\",");
            json.append("\"gioNghi\":").append(s.getGioNghi());
            if (s.getGhiChu() != null) {
                json.append(",\"ghiChu\":\"").append(escapeJson(s.getGhiChu())).append("\"");
            }
            json.append("}");
        }

        json.append("],\"staffs\":[");

        for (int i = 0; i < staffs.size(); i++) {
            TaiKhoan st = staffs.get(i);
            if (i > 0) json.append(",");
            json.append("{");
            json.append("\"accountId\":").append(st.getAccountId()).append(",");
            json.append("\"username\":\"").append(escapeJson(st.getUsername())).append("\",");
            json.append("\"fullName\":\"").append(escapeJson(st.getFullName() != null ? st.getFullName() : st.getUsername())).append("\",");
            json.append("\"roleId\":").append(st.getRoleId());
            json.append("}");
        }

        json.append("],\"audits\":[");
        for (int i = 0; i < audits.size(); i++) {
            org.example.model.CaLamViecAudit au = audits.get(i);
            if (i > 0) json.append(",");
            json.append("{");
            json.append("\"auditId\":").append(au.getAuditId()).append(",");
            json.append("\"caLamViecId\":").append(au.getCaLamViecId()).append(",");
            json.append("\"thaoTac\":\"").append(escapeJson(au.getThaoTac())).append("\",");
            json.append("\"tenNguoiThucHien\":\"").append(escapeJson(au.getTenNguoiThucHien())).append("\",");
            json.append("\"thoiGian\":\"").append(au.getThoiGian()).append("\",");
            json.append("\"lyDo\":\"").append(escapeJson(au.getLyDo())).append("\"");
            json.append("}");
        }

        json.append("],\"avails\":[");
        for (int i = 0; i < avails.size(); i++) {
            org.example.model.CaLamViecAvailability av = avails.get(i);
            if (i > 0) json.append(",");
            json.append("{");
            json.append("\"availabilityId\":").append(av.getAvailabilityId()).append(",");
            json.append("\"accountId\":").append(av.getAccountId()).append(",");
            json.append("\"tenNhanVien\":\"").append(escapeJson(av.getTenNhanVien())).append("\",");
            json.append("\"ngay\":\"").append(av.getNgay()).append("\",");
            json.append("\"gioBatDau\":\"").append(av.getGioBatDau()).append("\",");
            json.append("\"gioKetThuc\":\"").append(av.getGioKetThuc()).append("\",");
            json.append("\"trangThai\":\"").append(escapeJson(av.getTrangThai())).append("\",");
            json.append("\"ghiChu\":\"").append(escapeJson(av.getGhiChu())).append("\"");
            json.append("}");
        }

        json.append("],\"swaps\":[");
        for (int i = 0; i < swaps.size(); i++) {
            org.example.model.CaLamViecSwapRequest sw = swaps.get(i);
            if (i > 0) json.append(",");
            json.append("{");
            json.append("\"swapRequestId\":").append(sw.getSwapRequestId()).append(",");
            json.append("\"tenNguoiGui\":\"").append(escapeJson(sw.getTenNguoiGui())).append("\",");
            json.append("\"tenNguoiNhan\":\"").append(escapeJson(sw.getTenNguoiNhan())).append("\",");
            json.append("\"caGuiInfo\":\"").append(escapeJson(sw.getCaGuiInfo())).append("\",");
            json.append("\"caNhanInfo\":\"").append(escapeJson(sw.getCaNhanInfo())).append("\",");
            json.append("\"trangThai\":\"").append(escapeJson(sw.getTrangThai())).append("\",");
            json.append("\"lyDo\":\"").append(escapeJson(sw.getLyDo())).append("\"");
            json.append("}");
        }

        json.append("],\"branches\":[");
        for (int i = 0; i < branches.size(); i++) {
            org.example.model.CoSo b = branches.get(i);
            if (i > 0) json.append(",");
            json.append("{");
            json.append("\"coSoId\":").append(b.getCoSoID()).append(",");
            json.append("\"tenCoSo\":\"").append(escapeJson(b.getTenCoSo())).append("\"");
            json.append("}");
        }

        json.append("]}");
        return json.toString();
    }

    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\")
                    .replace("\"", "\\\"")
                    .replace("\n", "\\n")
                    .replace("\r", "\\r")
                    .replace("\t", "\\t");
    }
}
