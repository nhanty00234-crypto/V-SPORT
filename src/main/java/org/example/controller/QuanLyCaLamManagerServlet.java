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

            resp.sendRedirect(req.getContextPath() + "/manager/nhan-su?tab=schedule");
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
        if (managerCoSoId == null) {
            boolean isJson = "json".equals(req.getParameter("format"));
            if (isJson) {
                resp.setContentType("application/json");
                resp.setCharacterEncoding("UTF-8");
                resp.getWriter().write("{\"success\":false,\"error\":\"TÃ i khoáº£n quáº£n lÃ½ chÆ°a Ä‘Æ°á»£c liÃªn káº¿t vá»›i cÆ¡ sá»Ÿ nÃ o.\"}");
            } else {
                session.setAttribute("error", "TÃ i khoáº£n quáº£n lÃ½ chÆ°a Ä‘Æ°á»£c liÃªn káº¿t vá»›i cÆ¡ sá»Ÿ nÃ o.");
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
                    successMsg = "NhÃ¢n báº£n lá»‹ch tuáº§n thÃ nh cÃ´ng!";
                } else if ("autoSchedule".equals(action)) {
                    LocalDate startDate = LocalDate.parse(req.getParameter("startDate"));
                    LocalDate endDate = LocalDate.parse(req.getParameter("endDate"));
                    caLamService.autoScheduleShifts(startDate, endDate, managerCoSoId, manager.getAccountId());
                    successMsg = "Tá»± Ä‘á»™ng sáº¯p lá»‹ch thÃ nh cÃ´ng dá»±a trÃªn nguyá»‡n vá»ng cá»§a nhÃ¢n viÃªn!";
                } else if ("publishWeek".equals(action)) {
                    LocalDate weekStart = LocalDate.parse(req.getParameter("weekStart"));
                    caLamService.publishWeekShifts(weekStart, managerCoSoId, manager.getAccountId());
                    successMsg = "CÃ´ng bá»‘ lá»‹ch lÃ m viá»‡c thÃ nh cÃ´ng!";
                } else if ("approveSwap".equals(action)) {
                    int swapId = Integer.parseInt(req.getParameter("id"));
                    String notes = req.getParameter("notes");
                    caLamService.approveSwapRequest(swapId, manager.getAccountId(), notes);
                    successMsg = "ÄÃ£ phÃª duyá»‡t yÃªu cáº§u Ä‘á»•i ca!";
                } else if ("rejectSwap".equals(action)) {
                    int swapId = Integer.parseInt(req.getParameter("id"));
                    String notes = req.getParameter("notes");
                    caLamService.rejectSwapRequest(swapId, manager.getAccountId(), notes);
                    successMsg = "ÄÃ£ tá»« chá»‘i yÃªu cáº§u Ä‘á»•i ca!";
                } else {
                    throw new IllegalArgumentException("HÃ nh Ä‘á»™ng khÃ´ng há»£p lá»‡: " + action);
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
                    resp.sendRedirect(req.getContextPath() + "/manager/nhan-su?tab=schedule");
                }
            }
        } catch (IllegalArgumentException e) {
            logger.warn("Lá»—i xá»­ lÃ½ ca lÃ m: {}", e.getMessage(), e);
            boolean isJson = "json".equals(req.getParameter("format"));
            if (isJson) {
                resp.setContentType("application/json");
                resp.setCharacterEncoding("UTF-8");
                java.util.Map<String, Object> map = new java.util.HashMap<>();
                map.put("success", false);
                map.put("error", e.getMessage());
                resp.getWriter().write(new com.google.gson.Gson().toJson(map));
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
                java.util.Map<String, Object> map = new java.util.HashMap<>();
                map.put("success", false);
                map.put("error", "Lá»—i há»‡ thá»‘ng: " + e.getMessage());
                resp.getWriter().write(new com.google.gson.Gson().toJson(map));
            } else {
                session.setAttribute("error", "Lá»—i há»‡ thá»‘ng: " + e.getMessage());
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
            errorMsg = "ID ca lÃ m viá»‡c khÃ´ng há»£p lá»‡.";
        } else {
            try {
                int id = Integer.parseInt(idParam);
                caLamService.deleteShift(id, managerCoSoId, manager.getAccountId(), reason);
                successMsg = "XÃ³a ca lÃ m viá»‡c thÃ nh cÃ´ng!";
            } catch (NumberFormatException e) {
                errorMsg = "ID ca lÃ m viá»‡c khÃ´ng há»£p lá»‡.";
            } catch (Exception e) {
                errorMsg = e.getMessage();
            }
        }

        if (isJson) {
            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            java.util.Map<String, Object> map = new java.util.HashMap<>();
            if (errorMsg != null) {
                map.put("success", false);
                map.put("error", errorMsg);
            } else {
                map.put("success", true);
                map.put("message", successMsg);
            }
            resp.getWriter().write(new com.google.gson.Gson().toJson(map));
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

            Integer targetCaLamViecId = null;
            if (!"add".equals(action)) {
                String caLamViecIdParam = req.getParameter("caLamViecId");
                if (caLamViecIdParam != null && !caLamViecIdParam.trim().isEmpty()) {
                    targetCaLamViecId = Integer.parseInt(caLamViecIdParam);
                }
            }

            org.example.util.CaLamValidationEngine.ValidationResult valRes = caLamService.validateShiftAssignment(
                caLamReq.getAccountId(), caLamReq.getNgayLam(), caLamReq.getGioBatDau(), caLamReq.getGioKetThuc(), caLamReq.getGioNghi(), targetCaLamViecId
            );
            if (!valRes.isValid()) {
                throw new IllegalArgumentException("Lá»—i xung Ä‘á»™t lá»‹ch: " + String.join(", ", valRes.getErrors()));
            }

            if ("add".equals(action)) {
                caLamService.createShift(caLamReq, managerCoSoId, manager.getAccountId());
                successMsg = "ThÃªm ca lÃ m viá»‡c thÃ nh cÃ´ng!";
            } else {
                String reason = req.getParameter("reason");
                if (targetCaLamViecId == null) {
                    throw new IllegalArgumentException("ID ca lÃ m viá»‡c khÃ´ng há»£p lá»‡.");
                }
                caLamService.updateShift(targetCaLamViecId, caLamReq, managerCoSoId, manager.getAccountId(), reason);
                successMsg = "Cáº­p nháº­t ca lÃ m viá»‡c thÃ nh cÃ´ng!";
            }
        } catch (IllegalArgumentException e) {
            errorMsg = e.getMessage();
        } catch (Exception e) {
            errorMsg = "Lá»—i há»‡ thá»‘ng: " + e.getMessage();
        }

        if (isJson) {
            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            java.util.Map<String, Object> map = new java.util.HashMap<>();
            if (errorMsg != null) {
                map.put("success", false);
                map.put("error", errorMsg);
            } else {
                map.put("success", true);
                map.put("message", successMsg);
            }
            resp.getWriter().write(new com.google.gson.Gson().toJson(map));
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
            throw new IllegalArgumentException("Thiáº¿u thÃ´ng tin báº¯t buá»™c tá»« form");
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
            
            java.util.Map<String, Object> responseData = new java.util.HashMap<>();
            responseData.put("valid", result.isValid());
            responseData.put("errors", result.getErrors());
            responseData.put("warnings", result.getWarnings());

            resp.getWriter().write(new com.google.gson.Gson().toJson(responseData));
        } catch (Exception e) {
            java.util.Map<String, Object> errData = new java.util.HashMap<>();
            errData.put("valid", false);
            errData.put("errors", java.util.Collections.singletonList("Lá»—i tham sá»‘ validation: " + e.getMessage()));
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
        return new com.google.gson.Gson().toJson(data);
    }
}
