package org.example.controller.manager;



import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.model.TaiKhoan;
import org.example.service.manager.NhanSuService;
import org.example.service.manager.NhanSuService.NhanSuDTO;
import org.example.service.manager.NhanSuService.StaffCreateRequest;
import org.example.service.manager.NhanSuService.StaffUpdateRequest;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.io.IOException;
import java.time.LocalTime;
import java.util.List;

@WebServlet("/manager/nhan-su")
public class NhanSuManagerServlet extends HttpServlet {

    private static final Logger logger = LogManager.getLogger(NhanSuManagerServlet.class);
    private final NhanSuService nhanSuService = new NhanSuService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        
        // Kiá»ƒm tra Ä‘Äƒng nháº­p
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return;
        }
        
        TaiKhoan user = (TaiKhoan) session.getAttribute("user");
        
        // Kiá»ƒm tra quyá»n Manager (role 2)
        if (user.getRoleId() != 2) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Báº¡n khÃ´ng cÃ³ quyá»n truy cáº­p.");
            return;
        }
        
        Integer managerCoSoId = user.getCoSoId();
        if (managerCoSoId == null) {
            session.setAttribute("error", "TÃ i khoáº£n quáº£n lÃ½ chÆ°a Ä‘Æ°á»£c liÃªn káº¿t vá»›i cÆ¡ sá»Ÿ nÃ o.");
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }

        String action = req.getParameter("action");
        if ("list".equals(action)) {
            try {
                List<NhanSuDTO> staffList = nhanSuService.getStaffListByBranch(managerCoSoId);
                resp.setContentType("application/json");
                resp.setCharacterEncoding("UTF-8");
                String json = buildStaffListJson(staffList);
                resp.getWriter().write(json);
            } catch (Exception e) {
                logger.error("Error listing staff: {}", e.getMessage(), e);
                resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                resp.getWriter().write("Lá»—i táº£i danh sÃ¡ch nhÃ¢n viÃªn: " + e.getMessage());
            }
            return;
        }
        if ("deletedList".equals(action)) {
            try {
                List<NhanSuDTO> staffList = nhanSuService.getDeletedStaffListByBranch(managerCoSoId);
                resp.setContentType("application/json");
                resp.setCharacterEncoding("UTF-8");
                String json = buildStaffListJson(staffList);
                resp.getWriter().write(json);
            } catch (Exception e) {
                logger.error("Error listing deleted staff: {}", e.getMessage(), e);
                resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                resp.getWriter().write("Lá»—i táº£i danh sÃ¡ch nhÃ¢n viÃªn trong thÃ¹ng rÃ¡c: " + e.getMessage());
            }
            return;
        }
        
        // Forward tá»›i trang nhÃ¢n sá»±
        req.getRequestDispatcher("/manager/NhanSu.jsp").forward(req, resp);
    }
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        
        // Kiá»ƒm tra Ä‘Äƒng nháº­p
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return;
        }
        
        TaiKhoan user = (TaiKhoan) session.getAttribute("user");
        
        // Kiá»ƒm tra quyá»n Manager (role 2)
        if (user.getRoleId() != 2) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Báº¡n khÃ´ng cÃ³ quyá»n truy cáº­p.");
            return;
        }
        
        Integer managerCoSoId = user.getCoSoId();
        if (managerCoSoId == null) {
            session.setAttribute("error", "TÃ i khoáº£n quáº£n lÃ½ chÆ°a Ä‘Æ°á»£c liÃªn káº¿t vá»›i cÆ¡ sá»Ÿ nÃ o.");
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        String action = req.getParameter("action");
        try {
            if ("add".equals(action)) {
                StaffCreateRequest createReq = new StaffCreateRequest();
                createReq.setUsername(req.getParameter("username"));
                createReq.setFullName(req.getParameter("fullName"));
                createReq.setEmail(req.getParameter("email"));
                createReq.setPhoneNumber(req.getParameter("phoneNumber"));
                createReq.setRoleId(Integer.parseInt(req.getParameter("roleId")));
                createReq.setPassword(req.getParameter("password"));
                
                nhanSuService.createStaff(createReq, managerCoSoId, user.getAccountId());
                session.setAttribute("message", "ThÃªm nhÃ¢n viÃªn thÃ nh cÃ´ng!");
                resp.sendRedirect(req.getContextPath() + "/manager/nhan-su");
                return;
            } 
            else if ("update".equals(action)) {
                int accountId = Integer.parseInt(req.getParameter("accountId"));
                String isLockedParam = req.getParameter("isLocked");
                
                StaffUpdateRequest updateReq = new StaffUpdateRequest();
                if (isLockedParam != null) {
                    updateReq.setIsLocked(Boolean.parseBoolean(isLockedParam));
                    nhanSuService.updateStaff(accountId, updateReq, managerCoSoId);
                    session.setAttribute("message", "Cáº­p nháº­t tráº¡ng thÃ¡i khÃ³a thÃ nh cÃ´ng!");
                    resp.setStatus(HttpServletResponse.SC_OK);
                } else {
                    updateReq.setFullName(req.getParameter("fullName"));
                    updateReq.setEmail(req.getParameter("email"));
                    updateReq.setPhoneNumber(req.getParameter("phoneNumber"));
                    updateReq.setRoleId(Integer.parseInt(req.getParameter("roleId")));
                    updateReq.setPassword(req.getParameter("password"));

                    TaiKhoan account = nhanSuService.getStaffById(accountId);
                    String newEmail = updateReq.getEmail();
                    if (newEmail != null) newEmail = newEmail.trim();

                    boolean isEmailChanged = (newEmail != null && !newEmail.equalsIgnoreCase(account.getEmail()));
                    if (isEmailChanged) {
                        org.example.util.ValidationUtils.validateEmail(newEmail);
                        if (new org.example.dao.impl.TaiKhoanDAOImpl().kiemtraEmail(newEmail)) {
                            throw new IllegalArgumentException("Email Ä‘Ã£ tá»“n táº¡i trÃªn há»‡ thá»‘ng!");
                        }

                        account.setFullName(updateReq.getFullName());
                        account.setEmail(newEmail);
                        account.setPhoneNumber(updateReq.getPhoneNumber());
                        account.setRoleId(updateReq.getRoleId());
                        if (updateReq.getPassword() != null && !updateReq.getPassword().isEmpty()) {
                            org.example.util.ValidationUtils.validateStrongPassword(updateReq.getPassword());
                            account.setPassword(org.mindrot.jbcrypt.BCrypt.hashpw(updateReq.getPassword(), org.mindrot.jbcrypt.BCrypt.gensalt(12)));
                        }

                        String otpString = new org.example.dao.impl.TaiKhoanDAOImpl().sendRegistrationOTP(newEmail, account.getFullName());
                        session.setAttribute("otp", otpString);
                        session.setAttribute("tempAccount", account);
                        session.setAttribute("authType", "MANAGER_EDIT");
                        session.setAttribute("otpAttempts", 0);
                        session.setAttribute("resendCount", 0);
                        session.setAttribute("needResend", false);

                        String requestedWith = req.getHeader("X-Requested-With");
                        if ("XMLHttpRequest".equals(requestedWith)) {
                            resp.setContentType("application/json;charset=UTF-8");
                            resp.getWriter().write("{\"requiresOtp\": true, \"email\": \"" + newEmail + "\"}");
                            return;
                        }

                        resp.sendRedirect(req.getContextPath() + "/auth/NhapMa.jsp");
                    } else {
                        nhanSuService.updateStaff(accountId, updateReq, managerCoSoId);
                        session.setAttribute("message", "Cáº­p nháº­t thÃ´ng tin nhÃ¢n viÃªn thÃ nh cÃ´ng!");
                        String requestedWith = req.getHeader("X-Requested-With");
                        if ("XMLHttpRequest".equals(requestedWith)) {
                            resp.setContentType("application/json;charset=UTF-8");
                            resp.getWriter().write("{\"success\": true, \"message\": \"Cáº­p nháº­t thÃ´ng tin nhÃ¢n viÃªn thÃ nh cÃ´ng!\"}");
                            return;
                        }
                        resp.sendRedirect(req.getContextPath() + "/manager/nhan-su");
                    }
                }
            } 
            else if ("delete".equals(action)) {
                int accountId = Integer.parseInt(req.getParameter("id"));
                nhanSuService.deleteStaff(accountId, managerCoSoId);
                session.setAttribute("message", "XÃ³a nhÃ¢n viÃªn thÃ nh cÃ´ng!");
                resp.setStatus(HttpServletResponse.SC_OK);
            } 
            else if ("restore".equals(action)) {
                int accountId = Integer.parseInt(req.getParameter("id"));
                nhanSuService.restoreStaff(accountId, managerCoSoId);
                session.setAttribute("message", "KhÃ´i phá»¥c nhÃ¢n viÃªn thÃ nh cÃ´ng!");
                resp.setStatus(HttpServletResponse.SC_OK);
            }
            else if ("permanentDelete".equals(action)) {
                int accountId = Integer.parseInt(req.getParameter("id"));
                nhanSuService.permanentlyDeleteStaff(accountId, managerCoSoId);
                session.setAttribute("message", "XÃ³a vÄ©nh viá»…n nhÃ¢n viÃªn thÃ nh cÃ´ng!");
                resp.setStatus(HttpServletResponse.SC_OK);
            }
            else if ("addShift".equals(action)) {
                int accountId = Integer.parseInt(req.getParameter("accountId"));
                int thu = Integer.parseInt(req.getParameter("thu"));
                LocalTime gioBatDau = LocalTime.parse(req.getParameter("gioBatDau"));
                LocalTime gioKetThuc = LocalTime.parse(req.getParameter("gioKetThuc"));
                String ghiChu = req.getParameter("ghiChu");
                
                nhanSuService.addShiftPattern(accountId, managerCoSoId, thu, gioBatDau, gioKetThuc, ghiChu);
                session.setAttribute("message", "ThÃªm ca lÃ m Ä‘á»‹nh ká»³ thÃ nh cÃ´ng!");
                resp.setStatus(HttpServletResponse.SC_OK);
            } 
            else if ("deleteShift".equals(action)) {
                int accountId = Integer.parseInt(req.getParameter("accountId"));
                int thu = Integer.parseInt(req.getParameter("thu"));
                
                nhanSuService.deleteShiftPattern(accountId, thu);
                session.setAttribute("message", "XÃ³a ca lÃ m Ä‘á»‹nh ká»³ thÃ nh cÃ´ng!");
                resp.setStatus(HttpServletResponse.SC_OK);
            } 
            else {
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "HÃ nh Ä‘á»™ng khÃ´ng há»£p lá»‡.");
            }
        } catch (IllegalArgumentException e) {
            String msg = e.getMessage();
            if (msg != null && msg.startsWith("{") && msg.endsWith("}")) {
                msg = msg.substring(1, msg.length() - 1);
                msg = msg.replaceAll("=", ": ").replaceAll(",", "; ");
            }
            logger.warn("Validation/Business error in NhanSuManagerServlet: {}", msg);
            session.setAttribute("error", msg);
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.setContentType("text/plain;charset=UTF-8");
            resp.getWriter().write(msg != null ? msg : "YÃªu cáº§u khÃ´ng há»£p lá»‡.");
        } catch (Exception e) {
            logger.error("Unexpected error in NhanSuManagerServlet doPost: {}", e.getMessage(), e);
            session.setAttribute("error", "Lá»—i há»‡ thá»‘ng: " + e.getMessage());
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.setContentType("text/plain;charset=UTF-8");
            resp.getWriter().write("Lá»—i há»‡ thá»‘ng: " + e.getMessage());
        }
    }

    private String buildStaffListJson(List<NhanSuDTO> staffList) {
        java.util.List<java.util.Map<String, Object>> mappedList = new java.util.ArrayList<>();
        for (NhanSuDTO s : staffList) {
            java.util.Map<String, Object> map = new java.util.HashMap<>();
            map.put("id", String.valueOf(s.getAccountId()));
            map.put("username", s.getUsername());
            map.put("name", s.getFullName() != null ? s.getFullName() : s.getUsername());
            map.put("email", s.getEmail() != null ? s.getEmail() : "");
            map.put("phone", s.getPhoneNumber() != null ? s.getPhoneNumber() : "");
            map.put("roleId", s.getRoleId());
            map.put("VaiTro", s.getRoleName());
            map.put("status", s.isLocked() ? "Bá»‹ khÃ³a" : "Äang lÃ m");
            map.put("initial", s.getInitial());
            mappedList.add(map);
        }
        return new com.google.gson.Gson().toJson(mappedList);
    }
}
