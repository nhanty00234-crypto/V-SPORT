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
        
        // Kiểm tra đăng nhập
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return;
        }
        
        TaiKhoan user = (TaiKhoan) session.getAttribute("user");
        
        // Kiểm tra quyền Manager (role 2)
        if (user.getRoleId() != 2) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập.");
            return;
        }
        
        Integer managerCoSoId = user.getCoSoId();
        if (managerCoSoId == null) {
            session.setAttribute("error", "Tài khoản quản lý chưa được liên kết với cơ sở nào.");
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
                resp.getWriter().write("Lỗi tải danh sách nhân viên: " + e.getMessage());
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
                resp.getWriter().write("Lỗi tải danh sách nhân viên trong thùng rác: " + e.getMessage());
            }
            return;
        }
        
        // Forward tới trang nhân sự
        req.getRequestDispatcher("/manager/NhanSu.jsp").forward(req, resp);
    }
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        
        // Kiểm tra đăng nhập
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return;
        }
        
        TaiKhoan user = (TaiKhoan) session.getAttribute("user");
        
        // Kiểm tra quyền Manager (role 2)
        if (user.getRoleId() != 2) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập.");
            return;
        }
        
        Integer managerCoSoId = user.getCoSoId();
        if (managerCoSoId == null) {
            session.setAttribute("error", "Tài khoản quản lý chưa được liên kết với cơ sở nào.");
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
                session.setAttribute("message", "Thêm nhân viên thành công!");
                resp.setStatus(HttpServletResponse.SC_OK);
            } 
            else if ("update".equals(action)) {
                int accountId = Integer.parseInt(req.getParameter("accountId"));
                String isLockedParam = req.getParameter("isLocked");
                
                StaffUpdateRequest updateReq = new StaffUpdateRequest();
                if (isLockedParam != null) {
                    updateReq.setIsLocked(Boolean.parseBoolean(isLockedParam));
                } else {
                    updateReq.setFullName(req.getParameter("fullName"));
                    updateReq.setEmail(req.getParameter("email"));
                    updateReq.setPhoneNumber(req.getParameter("phoneNumber"));
                    updateReq.setRoleId(Integer.parseInt(req.getParameter("roleId")));
                }
                
                nhanSuService.updateStaff(accountId, updateReq, managerCoSoId);
                session.setAttribute("message", isLockedParam != null ? "Cập nhật trạng thái khóa thành công!" : "Cập nhật thông tin nhân viên thành công!");
                resp.setStatus(HttpServletResponse.SC_OK);
            } 
            else if ("delete".equals(action)) {
                int accountId = Integer.parseInt(req.getParameter("id"));
                nhanSuService.deleteStaff(accountId, managerCoSoId);
                session.setAttribute("message", "Xóa nhân viên thành công!");
                resp.setStatus(HttpServletResponse.SC_OK);
            } 
            else if ("restore".equals(action)) {
                int accountId = Integer.parseInt(req.getParameter("id"));
                nhanSuService.restoreStaff(accountId, managerCoSoId);
                session.setAttribute("message", "Khôi phục nhân viên thành công!");
                resp.setStatus(HttpServletResponse.SC_OK);
            }
            else if ("permanentDelete".equals(action)) {
                int accountId = Integer.parseInt(req.getParameter("id"));
                nhanSuService.permanentlyDeleteStaff(accountId, managerCoSoId);
                session.setAttribute("message", "Xóa vĩnh viễn nhân viên thành công!");
                resp.setStatus(HttpServletResponse.SC_OK);
            }
            else if ("addShift".equals(action)) {
                int accountId = Integer.parseInt(req.getParameter("accountId"));
                int thu = Integer.parseInt(req.getParameter("thu"));
                LocalTime gioBatDau = LocalTime.parse(req.getParameter("gioBatDau"));
                LocalTime gioKetThuc = LocalTime.parse(req.getParameter("gioKetThuc"));
                String ghiChu = req.getParameter("ghiChu");
                
                nhanSuService.addShiftPattern(accountId, managerCoSoId, thu, gioBatDau, gioKetThuc, ghiChu);
                session.setAttribute("message", "Thêm ca làm định kỳ thành công!");
                resp.setStatus(HttpServletResponse.SC_OK);
            } 
            else if ("deleteShift".equals(action)) {
                int accountId = Integer.parseInt(req.getParameter("accountId"));
                int thu = Integer.parseInt(req.getParameter("thu"));
                
                nhanSuService.deleteShiftPattern(accountId, thu);
                session.setAttribute("message", "Xóa ca làm định kỳ thành công!");
                resp.setStatus(HttpServletResponse.SC_OK);
            } 
            else {
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Hành động không hợp lệ.");
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
            resp.getWriter().write(msg != null ? msg : "Yêu cầu không hợp lệ.");
        } catch (Exception e) {
            logger.error("Unexpected error in NhanSuManagerServlet doPost: {}", e.getMessage(), e);
            session.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().write("Lỗi hệ thống: " + e.getMessage());
        }
    }

    private String buildStaffListJson(List<NhanSuDTO> staffList) {
        StringBuilder json = new StringBuilder();
        json.append("[");
        for (int i = 0; i < staffList.size(); i++) {
            NhanSuDTO s = staffList.get(i);
            if (i > 0) json.append(",");
            json.append("{");
            json.append("\"id\":\"").append(s.getAccountId()).append("\",");
            json.append("\"username\":\"").append(escapeJson(s.getUsername())).append("\",");
            json.append("\"name\":\"").append(escapeJson(s.getFullName() != null ? s.getFullName() : s.getUsername())).append("\",");
            json.append("\"email\":\"").append(escapeJson(s.getEmail() != null ? s.getEmail() : "")).append("\",");
            json.append("\"phone\":\"").append(escapeJson(s.getPhoneNumber() != null ? s.getPhoneNumber() : "")).append("\",");
            json.append("\"roleId\":").append(s.getRoleId()).append(",");
            json.append("\"VaiTro\":\"").append(escapeJson(s.getRoleName())).append("\",");
            json.append("\"status\":\"").append(s.isLocked() ? "Bị khóa" : "Đang làm").append("\",");
            json.append("\"initial\":\"").append(escapeJson(s.getInitial())).append("\"");
            json.append("}");
        }
        json.append("]");
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
