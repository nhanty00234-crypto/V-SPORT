package org.example.controller.manager;

import org.example.model.CaLamViec;
import org.example.model.TaiKhoan;
import org.example.service.manager.CaLamService;
import org.example.util.Constants;
import org.example.exception.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.service.AuditLogService;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Servlet quáº£n lÃ½ ca lÃ m viá»‡c dÃ nh cho Manager
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
            session.setAttribute("error", "KhÃ´ng tÃ¬m tháº¥y thÃ´ng tin cÆ¡ sá»Ÿ cá»§a quáº£n lÃ½.");
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

            req.setAttribute("shifts", shifts);
            req.setAttribute("staffs", staffs);
            req.getRequestDispatcher("/manager/CaLamViec.jsp").forward(req, resp);
        } catch (Exception e) {
            logger.error("Error in doGet: {}", e.getMessage(), e);
            session.setAttribute("error", "Lá»—i khi táº£i dá»¯ liá»‡u: " + e.getMessage());
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
        boolean isJson = "json".equals(req.getParameter("format"));

        try {
            if (managerCoSoId == null) {
                throw new ForbiddenException("Tài khoản quản lý chưa được liên kết với cơ sở nào.");
            }

            String action = req.getParameter("action");

            if ("delete".equals(action)) {
                handleDelete(req, resp, session, manager, managerCoSoId);
            } else if ("add".equals(action) || "update".equals(action)) {
                handleAddOrUpdate(req, resp, session, manager, managerCoSoId, action);
            } else {
                String successMsg = null;
                List<String> warnings = new ArrayList<>();
                
                if ("cloneWeek".equals(action)) {
                    LocalDate fromWeek = LocalDate.parse(req.getParameter("fromWeek"));
                    LocalDate toWeek = LocalDate.parse(req.getParameter("toWeek"));
                    List<String> reports = caLamService.cloneWeekShifts(fromWeek, toWeek, managerCoSoId, manager.getAccountId());
                    successMsg = "Nhân bản lịch tuần thành công!";
                    if (reports != null && !reports.isEmpty()) {
                        warnings.addAll(reports);
                    }
                } else if ("autoSchedule".equals(action)) {
                    LocalDate startDate = LocalDate.parse(req.getParameter("startDate"));
                    LocalDate endDate = LocalDate.parse(req.getParameter("endDate"));
                    String report = caLamService.autoScheduleShifts(startDate, endDate, managerCoSoId, manager.getAccountId());
                    successMsg = report;
                } else if ("publishWeek".equals(action)) {
                    LocalDate weekStart = LocalDate.parse(req.getParameter("weekStart"));
                    List<String> publishWarns = caLamService.publishWeekShifts(weekStart, managerCoSoId, manager.getAccountId());
                    successMsg = "Công bố lịch làm việc thành công!";
                    if (publishWarns != null && !publishWarns.isEmpty()) {
                        warnings.addAll(publishWarns);
                    }
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
                } else if ("confirmShift".equals(action)) {
                    int caId = Integer.parseInt(req.getParameter("caLamViecId"));
                    caLamService.managerConfirmShift(caId, managerCoSoId, manager.getAccountId(), req.getParameter("lyDo"));
                    successMsg = "Đã xác nhận lịch hộ nhân viên.";
                } else if ("manualCheckIn".equals(action)) {
                    int caId = Integer.parseInt(req.getParameter("caLamViecId"));
                    caLamService.managerCheckIn(caId, managerCoSoId, manager.getAccountId(), req.getParameter("lyDo"));
                    successMsg = "Đã điểm danh vào ca hộ nhân viên.";
                } else if ("manualCheckOut".equals(action)) {
                    int caId = Integer.parseInt(req.getParameter("caLamViecId"));
                    caLamService.managerCheckOut(caId, managerCoSoId, manager.getAccountId(), req.getParameter("lyDo"));
                    successMsg = "Đã kết thúc ca hộ nhân viên.";
                } else {
                    throw new ValidationException("Hành động không hợp lệ: " + action);
                }

                if (isJson) {
                    resp.setStatus(HttpServletResponse.SC_OK);
                    resp.setContentType("application/json");
                    resp.setCharacterEncoding("UTF-8");
                    java.util.Map<String, Object> map = new java.util.HashMap<>();
                    map.put("success", true);
                    map.put("message", successMsg);
                    if (!warnings.isEmpty()) {
                        map.put("warnings", warnings);
                    }
                    resp.getWriter().write(new com.google.gson.Gson().toJson(map));
                } else {
                    session.setAttribute("message", successMsg);
                    if (!warnings.isEmpty()) {
                        session.setAttribute("warnings", warnings);
                    }
                    resp.sendRedirect(req.getContextPath() + "/manager/nhan-su?tab=schedule");
                }
            }
        } catch (org.example.exception.ValidationException | IllegalArgumentException e) {
            handleException(req, resp, session, HttpServletResponse.SC_BAD_REQUEST, e.getMessage(), isJson);
        } catch (org.example.exception.ForbiddenException e) {
            handleException(req, resp, session, HttpServletResponse.SC_FORBIDDEN, e.getMessage(), isJson);
        } catch (org.example.exception.NotFoundException e) {
            handleException(req, resp, session, HttpServletResponse.SC_NOT_FOUND, e.getMessage(), isJson);
        } catch (org.example.exception.ConflictException e) {
            handleException(req, resp, session, HttpServletResponse.SC_CONFLICT, e.getMessage(), isJson);
        } catch (Exception e) {
            logger.error("Unexpected error in doPost: {}", e.getMessage(), e);
            handleException(req, resp, session, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi hệ thống: " + e.getMessage(), isJson);
        }
    }

    private void handleException(HttpServletRequest req, HttpServletResponse resp, HttpSession session,
                                 int statusCode, String errorMsg, boolean isJson) throws IOException {
        if (isJson) {
            resp.setStatus(statusCode);
            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            java.util.Map<String, Object> map = new java.util.HashMap<>();
            map.put("success", false);
            map.put("error", errorMsg);
            resp.getWriter().write(new com.google.gson.Gson().toJson(map));
        } else {
            session.setAttribute("error", errorMsg);
            resp.sendRedirect(req.getContextPath() + "/manager/nhan-su?tab=schedule");
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
                              HttpSession session, TaiKhoan manager, int managerCoSoId) throws Exception {
        String idParam = req.getParameter("id");
        String reason = req.getParameter("reason");
        boolean isJson = "json".equals(req.getParameter("format"));
        String successMsg = null;

        if (idParam == null || idParam.trim().isEmpty()) {
            throw new ValidationException("ID ca làm việc không hợp lệ.");
        }

        int id;
        try {
            id = Integer.parseInt(idParam);
        } catch (NumberFormatException e) {
            throw new ValidationException("ID ca làm việc không hợp lệ.");
        }

        caLamService.deleteShift(id, managerCoSoId, manager.getAccountId(), reason);
        successMsg = "Xóa ca làm việc thành công!";
        AuditLogService.log(req, manager,
            AuditLogService.ACTION_SOFT_DELETE, AuditLogService.ENTITY_CA_LAM,
            String.valueOf(id), "Ca " + id,
            "Manager xóa mềm ca làm việc");

        if (isJson) {
            resp.setStatus(HttpServletResponse.SC_OK); // 200 OK
            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            java.util.Map<String, Object> map = new java.util.HashMap<>();
            map.put("success", true);
            map.put("message", successMsg);
            resp.getWriter().write(new com.google.gson.Gson().toJson(map));
        } else {
            session.setAttribute("message", successMsg);
            resp.sendRedirect(req.getContextPath() + "/manager/ca-lam");
        }
    }

    private void handleAddOrUpdate(HttpServletRequest req, HttpServletResponse resp,
                                   HttpSession session, TaiKhoan manager, int managerCoSoId,
                                   String action) throws Exception {
        boolean isJson = "json".equals(req.getParameter("format"));
        String successMsg = null;

        CaLamService.CaLamRequest caLamReq = parseCaLamRequest(req);

        Integer targetCaLamViecId = null;
        if (!"add".equals(action)) {
            String caLamViecIdParam = req.getParameter("caLamViecId");
            if (caLamViecIdParam != null && !caLamViecIdParam.trim().isEmpty()) {
                targetCaLamViecId = Integer.parseInt(caLamViecIdParam);
            }
        }

        if ("add".equals(action)) {
            caLamService.createShift(caLamReq, managerCoSoId, manager.getAccountId());
            successMsg = "Thêm ca làm việc thành công!";
            AuditLogService.log(req, manager,
                AuditLogService.ACTION_CREATE, AuditLogService.ENTITY_CA_LAM,
                "unknown",
                "Ca làm ngày " + caLamReq.getNgayLam(),
                "Manager tạo ca làm việc");
            
            if (isJson) {
                resp.setStatus(HttpServletResponse.SC_CREATED); // 201 Created
            }
        } else {
            String reason = req.getParameter("reason");
            if (targetCaLamViecId == null) {
                throw new ValidationException("ID ca làm việc không hợp lệ.");
            }
            caLamService.updateShift(targetCaLamViecId, caLamReq, managerCoSoId, manager.getAccountId(), reason);
            successMsg = "Cập nhật ca làm việc thành công!";
            AuditLogService.log(req, manager,
                AuditLogService.ACTION_UPDATE, AuditLogService.ENTITY_CA_LAM,
                String.valueOf(targetCaLamViecId), "Ca " + targetCaLamViecId,
                "Manager cập nhật ca làm việc");
            
            if (isJson) {
                resp.setStatus(HttpServletResponse.SC_OK); // 200 OK
            }
        }

        if (isJson) {
            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            java.util.Map<String, Object> map = new java.util.HashMap<>();
            map.put("success", true);
            map.put("message", successMsg);
            resp.getWriter().write(new com.google.gson.Gson().toJson(map));
        } else {
            session.setAttribute("message", successMsg);
            resp.sendRedirect(req.getContextPath() + "/manager/ca-lam");
        }
    }

    private CaLamService.CaLamRequest parseCaLamRequest(HttpServletRequest req) {
        CaLamService.CaLamRequest request = new CaLamService.CaLamRequest();

        String accountIdParam = req.getParameter("accountId");
        if (accountIdParam == null || accountIdParam.trim().isEmpty()) {
            throw new org.example.exception.ValidationException("Vui lòng chọn nhân viên.");
        }

        String coSoIdParam = req.getParameter("coSoId");
        if (coSoIdParam == null || coSoIdParam.trim().isEmpty()) {
            throw new org.example.exception.ValidationException("Cơ sở không hợp lệ.");
        }

        String ngayLamParam = req.getParameter("ngayLam");
        if (ngayLamParam == null || ngayLamParam.trim().isEmpty()) {
            throw new org.example.exception.ValidationException("Ngày làm không được để trống.");
        }

        int accountId;
        try {
            accountId = Integer.parseInt(accountIdParam);
        } catch (NumberFormatException e) {
            throw new org.example.exception.ValidationException("Vui lòng chọn nhân viên.");
        }

        int coSoId;
        try {
            coSoId = Integer.parseInt(coSoIdParam);
        } catch (NumberFormatException e) {
            throw new org.example.exception.ValidationException("Cơ sở không hợp lệ.");
        }

        LocalDate ngayLam;
        try {
            ngayLam = LocalDate.parse(ngayLamParam);
        } catch (Exception e) {
            throw new org.example.exception.ValidationException("Ngày làm không hợp lệ.");
        }

        String shiftTemplateId = req.getParameter("shiftTemplateId");
        if (shiftTemplateId == null || shiftTemplateId.trim().isEmpty()) {
            shiftTemplateId = req.getParameter("mauCaId");
        }
        if (shiftTemplateId == null || shiftTemplateId.trim().isEmpty()) {
            // Also check the old parameter name as fallback
            shiftTemplateId = req.getParameter("tenCa");
        }
        
        if (shiftTemplateId == null || shiftTemplateId.trim().isEmpty()) {
            throw new org.example.exception.ValidationException("Vui lòng chọn mẫu ca hệ thống.");
        }
        
        Constants.ShiftTemplateDto template = Constants.getTemplateById(shiftTemplateId);
        if (template == null) {
            throw new org.example.exception.ValidationException("Mẫu ca hệ thống không tồn tại.");
        }
        
        if ("3".equals(template.id) || "Ca đêm".equalsIgnoreCase(template.name)) {
            throw new org.example.exception.ValidationException("Mẫu ca đêm chưa được hỗ trợ.");
        }
        
        boolean isCustomTime = Boolean.parseBoolean(req.getParameter("isCustomTime"));
        
        LocalTime gioBatDau;
        LocalTime gioKetThuc;
        int gioNghi;
        String customTimeReason = null;
        
        if (!isCustomTime) {
            gioBatDau = LocalTime.parse(template.startTime);
            gioKetThuc = LocalTime.parse(template.endTime);
            gioNghi = template.breakMinutes;
        } else {
            String gioBatDauParam = req.getParameter("gioBatDau");
            String gioKetThucParam = req.getParameter("gioKetThuc");
            String breakMinutesParam = req.getParameter("breakMinutes");
            if (breakMinutesParam == null || breakMinutesParam.trim().isEmpty()) {
                breakMinutesParam = req.getParameter("gioNghiPhut");
            }
            if (breakMinutesParam == null || breakMinutesParam.trim().isEmpty()) {
                breakMinutesParam = req.getParameter("gioNghi");
            }
            
            if (gioBatDauParam == null || gioBatDauParam.trim().isEmpty()) {
                throw new org.example.exception.ValidationException("Giờ bắt đầu không được để trống.");
            }
            if (gioKetThucParam == null || gioKetThucParam.trim().isEmpty()) {
                throw new org.example.exception.ValidationException("Giờ kết thúc không được để trống.");
            }
            
            try {
                gioBatDau = LocalTime.parse(gioBatDauParam);
            } catch (Exception e) {
                throw new org.example.exception.ValidationException("Giờ bắt đầu không hợp lệ.");
            }
            try {
                gioKetThuc = LocalTime.parse(gioKetThucParam);
            } catch (Exception e) {
                throw new org.example.exception.ValidationException("Giờ kết thúc không hợp lệ.");
            }
            
            if (gioBatDau.equals(gioKetThuc)) {
                throw new org.example.exception.ValidationException("Giờ bắt đầu phải trước giờ kết thúc.");
            }
            if (!gioBatDau.isBefore(gioKetThuc)) {
                throw new org.example.exception.ValidationException("Ca qua ngày chưa được hỗ trợ.");
            }
            
            try {
                gioNghi = (breakMinutesParam != null && !breakMinutesParam.trim().isEmpty()) 
                        ? Integer.parseInt(breakMinutesParam) : 0;
            } catch (NumberFormatException e) {
                throw new org.example.exception.ValidationException("Giờ nghỉ không hợp lệ.");
            }
            
            if (gioNghi < 0) {
                throw new org.example.exception.ValidationException("Giờ nghỉ không được là số âm.");
            }
            
            customTimeReason = req.getParameter("customTimeReason");
            if (customTimeReason == null || customTimeReason.trim().isEmpty()) {
                throw new org.example.exception.ValidationException("Lý do tùy chỉnh giờ làm không được để trống.");
            }
            if (customTimeReason.length() > 255) {
                throw new org.example.exception.ValidationException("Lý do tùy chỉnh giờ làm không được vượt quá 255 ký tự.");
            }
        }

        request.setAccountId(accountId);
        request.setCoSoId(coSoId);
        request.setNgayLam(ngayLam);
        request.setGioBatDau(gioBatDau);
        request.setGioKetThuc(gioKetThuc);
        String ghiChu = req.getParameter("ghiChu");
        if (ghiChu != null && ghiChu.length() > 255) {
            throw new org.example.exception.ValidationException("Ghi chú không được vượt quá 255 ký tự.");
        }
        request.setGhiChu(ghiChu);
        request.setTenCa(template.name);
        request.setViTri(req.getParameter("viTri"));
        request.setTrangThai(req.getParameter("trangThai"));
        request.setGioNghi(gioNghi);
        request.setCustomTime(isCustomTime);
        request.setCustomTimeReason(customTimeReason);
        request.setShiftTemplateId(shiftTemplateId);

        String repeatTypeParam = req.getParameter("repeatType");
        if (repeatTypeParam != null && !repeatTypeParam.trim().isEmpty()) {
            request.setRepeatType(repeatTypeParam);
        }

        String repeatUntilParam = req.getParameter("repeatUntil");
        if (repeatUntilParam != null && !repeatUntilParam.trim().isEmpty()) {
            request.setRepeatUntil(LocalDate.parse(repeatUntilParam));
        }

        String overrideConfirmParam = req.getParameter("overrideConfirm");
        if (overrideConfirmParam != null && !overrideConfirmParam.trim().isEmpty()) {
            request.setOverrideConfirm(Boolean.parseBoolean(overrideConfirmParam));
        }

        return request;
    }

    private void handleValidate(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        
        try {
            String accountIdParam = req.getParameter("accountId");
            if (accountIdParam == null || accountIdParam.trim().isEmpty()) {
                throw new org.example.exception.ValidationException("Vui lòng chọn nhân viên.");
            }
            int accountId = Integer.parseInt(accountIdParam);

            String ngayLamParam = req.getParameter("ngayLam");
            if (ngayLamParam == null || ngayLamParam.trim().isEmpty()) {
                throw new org.example.exception.ValidationException("Ngày làm không được để trống.");
            }
            LocalDate ngayLam;
            try {
                ngayLam = LocalDate.parse(ngayLamParam);
            } catch (Exception e) {
                throw new org.example.exception.ValidationException("Ngày làm không hợp lệ.");
            }

            boolean isCustomTime = Boolean.parseBoolean(req.getParameter("isCustomTime"));
            LocalTime gioBatDau;
            LocalTime gioKetThuc;
            int gioNghi = 0;

            if (!isCustomTime) {
                String shiftTemplateId = req.getParameter("shiftTemplateId");
                if (shiftTemplateId == null || shiftTemplateId.trim().isEmpty()) {
                    throw new org.example.exception.ValidationException("Vui lòng chọn mẫu ca hệ thống.");
                }
                Constants.ShiftTemplateDto template = Constants.getTemplateById(shiftTemplateId);
                if (template == null) {
                    throw new org.example.exception.ValidationException("Mẫu ca hệ thống không tồn tại.");
                }
                gioBatDau = LocalTime.parse(template.startTime);
                gioKetThuc = LocalTime.parse(template.endTime);
                gioNghi = template.breakMinutes;
            } else {
                String startParam = req.getParameter("gioBatDau");
                String endParam   = req.getParameter("gioKetThuc");
                if (startParam == null || startParam.trim().isEmpty()) {
                    throw new org.example.exception.ValidationException("Giờ bắt đầu không được để trống.");
                }
                if (endParam == null || endParam.trim().isEmpty()) {
                    throw new org.example.exception.ValidationException("Giờ kết thúc không được để trống.");
                }
                try { gioBatDau = LocalTime.parse(startParam); }
                catch (Exception e) { throw new org.example.exception.ValidationException("Giờ bắt đầu không hợp lệ."); }
                try { gioKetThuc = LocalTime.parse(endParam); }
                catch (Exception e) { throw new org.example.exception.ValidationException("Giờ kết thúc không hợp lệ."); }
                if (gioBatDau.equals(gioKetThuc)) {
                    throw new org.example.exception.ValidationException("Giờ bắt đầu phải trước giờ kết thúc.");
                }
                if (!gioBatDau.isBefore(gioKetThuc)) {
                    throw new org.example.exception.ValidationException("Ca qua ngày chưa được hỗ trợ.");
                }
                String gioNghiParam = req.getParameter("gioNghi");
                if (gioNghiParam != null && !gioNghiParam.trim().isEmpty()) {
                    gioNghi = Integer.parseInt(gioNghiParam);
                }
            }

            Integer caLamViecId = null;
            String caLamViecIdParam = req.getParameter("caLamViecId");
            if (caLamViecIdParam != null && !caLamViecIdParam.trim().isEmpty()) {
                caLamViecId = Integer.parseInt(caLamViecIdParam);
            }

            String customTimeReason = req.getParameter("customTimeReason");

            org.example.util.CaLamValidationEngine.ValidationResult result =
                caLamService.validateShiftAssignment(accountId, ngayLam, gioBatDau, gioKetThuc, gioNghi, caLamViecId, isCustomTime, customTimeReason);

            java.util.Map<String, Object> responseData = new java.util.HashMap<>();
            responseData.put("valid", result.isValid());
            responseData.put("errors", result.getErrors());
            responseData.put("warnings", result.getWarnings());

            resp.getWriter().write(new com.google.gson.Gson().toJson(responseData));
        } catch (org.example.exception.ValidationException ve) {
            java.util.Map<String, Object> errData = new java.util.HashMap<>();
            errData.put("valid", false);
            errData.put("errors", java.util.Collections.singletonList(ve.getMessage()));
            errData.put("warnings", java.util.Collections.emptyList());
            resp.getWriter().write(new com.google.gson.Gson().toJson(errData));
        } catch (Exception e) {
            java.util.Map<String, Object> errData = new java.util.HashMap<>();
            errData.put("valid", false);
            errData.put("errors", java.util.Collections.singletonList("Lỗi tham số validation: " + e.getMessage()));
            errData.put("warnings", java.util.Collections.emptyList());
            resp.getWriter().write(new com.google.gson.Gson().toJson(errData));
        }
    }

    private String buildJsonResponse(List<CaLamViec> shifts, List<TaiKhoan> staffs,
                                      List<org.example.model.CaLamViecAudit> audits,
                                      List<org.example.model.CaLamViecAvailability> avails,
                                      List<org.example.model.CaLamViecSwapRequest> swaps,
                                      List<org.example.model.CoSo> branches) throws Exception {
        java.util.Map<String, Object> data = new java.util.HashMap<>();
        data.put("shifts", shifts);
        data.put("staffs", staffs);
        data.put("audits", audits);
        data.put("avails", avails);
        data.put("swaps", swaps);
        data.put("branches", branches);
        return createGson().toJson(data);
    }

    private static com.google.gson.Gson createGson() {
        return new com.google.gson.GsonBuilder()
                .registerTypeAdapter(LocalDate.class, (com.google.gson.JsonSerializer<LocalDate>)
                        (src, typeOfSrc, context) -> new com.google.gson.JsonPrimitive(src.toString()))
                .registerTypeAdapter(LocalTime.class, (com.google.gson.JsonSerializer<LocalTime>)
                        (src, typeOfSrc, context) -> new com.google.gson.JsonPrimitive(src.toString()))
                .registerTypeAdapter(java.time.LocalDateTime.class, (com.google.gson.JsonSerializer<java.time.LocalDateTime>)
                        (src, typeOfSrc, context) -> new com.google.gson.JsonPrimitive(src.toString()))
                .create();
    }
}
