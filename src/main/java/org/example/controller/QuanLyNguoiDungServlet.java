package org.example.controller;

import org.example.dao.TaiKhoanDAO;
import org.example.dao.VaiTroDAO;
import org.example.dao.impl.TaiKhoanDAOImpl;
import org.example.dao.impl.VaiTroDAOImpl;

import org.example.dao.CoSoDAO;
import org.example.dao.impl.CoSoDAOImpl;

import org.example.model.CoSo;
import org.example.model.TaiKhoan;
import org.example.model.VaiTro;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.example.dao.CaLamViecDAO;
import org.example.dao.impl.CaLamViecDAOImpl;
import org.example.model.CaLamViec;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/admin/nhan-su")
public class QuanLyNguoiDungServlet extends HttpServlet {
    private TaiKhoanDAO TaiKhoanDAO = new TaiKhoanDAOImpl();
    private CoSoDAO coSoDAO = new CoSoDAOImpl();
    private VaiTroDAO VaiTroDAO = new VaiTroDAOImpl();
    private CaLamViecDAO caLamViecDAO = new CaLamViecDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        TaiKhoan user = (TaiKhoan) req.getSession().getAttribute("user");
        if (user == null) {
            user = new TaiKhoan();
            user.setRoleId(1);
            user.setUsername("nhan111");
            user.setFullName("Nhân Nguyễn Thiện");
            req.getSession().setAttribute("user", user);
        }
        if (user.getRoleId() != 1) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return;
        }

        String action = req.getParameter("action");
        if ("delete".equals(action)) {
            int id = Integer.parseInt(req.getParameter("id"));
            TaiKhoan accToDelete = TaiKhoanDAO.getAccountById(id);
            if (accToDelete != null && accToDelete.getRoleId() != 1) {
                TaiKhoanDAO.deleteAccount(id);
            }
            resp.sendRedirect(req.getContextPath() + "/admin/nhan-su");
            return;
        }

        List<TaiKhoan> accounts = TaiKhoanDAO.getAllAccounts();
        List<CoSo> branches = coSoDAO.getAllCoSo();
        List<VaiTro> roles = VaiTroDAO.getAllRoles();
        List<CaLamViec> shifts = caLamViecDAO.getAllCaLamViec();

        req.setAttribute("accounts", accounts);
        req.setAttribute("staffs", accounts);
        req.setAttribute("branches", branches);
        req.setAttribute("roles", roles);
        req.setAttribute("shifts", shifts);
        req.getRequestDispatcher("/admin/NhanSu.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        TaiKhoan user = (TaiKhoan) req.getSession().getAttribute("user");
        if (user == null) {
            user = new TaiKhoan();
            user.setRoleId(1);
            user.setUsername("nhan111");
            user.setFullName("Nhân Nguyễn Thiện");
            req.getSession().setAttribute("user", user);
        }
        if (user.getRoleId() != 1) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String action = req.getParameter("action");
        if ("update".equals(action)) {
            TaiKhoan acc = TaiKhoanDAO.getAccountById(Integer.parseInt(req.getParameter("accountId")));
            if (acc != null) {
                String isLockedParam = req.getParameter("isLocked");
                if (isLockedParam != null) {
                    acc.setIsLocked("true".equals(isLockedParam) || "1".equals(isLockedParam));
                } else {
                    String email = req.getParameter("email");
                    String phone = req.getParameter("phoneNumber");
                    String fullName = req.getParameter("fullName");
                    if (email != null) email = email.trim();
                    if (phone != null) phone = phone.trim();
                    if (fullName != null) fullName = fullName.trim();
                    
                    if (!org.example.util.ValidationUtil.isValidEmail(email)) {
                        req.getSession().setAttribute("error", "Định dạng Email không hợp lệ và không được chứa khoảng trắng!");
                        resp.sendRedirect(req.getContextPath() + "/admin/nhan-su");
                        return;
                    }
                    if (phone != null && !phone.isEmpty()) {
                        if (!org.example.util.ValidationUtil.isValidVNPhone(phone)) {
                            req.getSession().setAttribute("error", "Định dạng Số điện thoại không hợp lệ (Phải bắt đầu bằng 0 hoặc +84 và có 10 số)!");
                            resp.sendRedirect(req.getContextPath() + "/admin/nhan-su");
                            return;
                        }
                    }

                    // Check if email is already used by another account
                    if (email != null && !email.equalsIgnoreCase(acc.getEmail()) && TaiKhoanDAO.kiemtraEmail(email)) {
                        req.getSession().setAttribute("error", "Email đã tồn tại trên hệ thống!");
                        resp.sendRedirect(req.getContextPath() + "/admin/nhan-su");
                        return;
                    }
                    
                    acc.setFullName(fullName);
                    acc.setEmail(email);
                    acc.setPhoneNumber(phone);
                    
                    // Only update role and branch if the account is NOT a Manager (roleId != 2)
                    if (acc.getRoleId() != 2) {
                        int newRoleId = Integer.parseInt(req.getParameter("roleId"));
                        // Prevent changing the role of an existing Admin account
                        if (acc.getRoleId() == 1 && newRoleId != 1) {
                            req.getSession().setAttribute("error", "Không thể thay đổi vai trò của tài khoản Quản trị viên!");
                            resp.sendRedirect(req.getContextPath() + "/admin/nhan-su");
                            return;
                        }
                        // Prevent granting Admin role to a non-admin account
                        if (acc.getRoleId() != 1 && newRoleId == 1) {
                            req.getSession().setAttribute("error", "Không thể cấp quyền Quản trị viên cho tài khoản này!");
                            resp.sendRedirect(req.getContextPath() + "/admin/nhan-su");
                            return;
                        }
                        acc.setRoleId(newRoleId);
                        
                        String coSoIdStr = req.getParameter("coSoId");
                        if (newRoleId == 2 && (coSoIdStr == null || coSoIdStr.isEmpty())) {
                            req.getSession().setAttribute("error", "Quản lý cần phải có Cơ sở!");
                            resp.sendRedirect(req.getContextPath() + "/admin/nhan-su");
                            return;
                        }
                        if (coSoIdStr != null && !coSoIdStr.isEmpty()) {
                            acc.setCoSoId(Integer.parseInt(coSoIdStr));
                        }
                    }
                    
                    // Password update: NOT allowed for Manager (2), Customer (3), Receptionist (4), and Security (5) roles.
                    boolean isRestrictedRole = (acc.getRoleId() == 2 || acc.getRoleId() == 3 || acc.getRoleId() == 4 || acc.getRoleId() == 5);
                    if (!isRestrictedRole) {
                        String rawPassword = req.getParameter("password");
                        if (rawPassword != null && !rawPassword.trim().isEmpty()) {
                            rawPassword = rawPassword.trim();
                            if (!org.example.util.ValidationUtil.isStrongPassword(rawPassword)) {
                                req.getSession().setAttribute("error", "Mật khẩu phải có tối thiểu 8 ký tự, bao gồm cả chữ hoa, chữ thường, số và ký tự đặc biệt!");
                                resp.sendRedirect(req.getContextPath() + "/admin/nhan-su");
                                return;
                            }
                            acc.setPassword(org.mindrot.jbcrypt.BCrypt.hashpw(rawPassword, org.mindrot.jbcrypt.BCrypt.gensalt(12)));
                        }
                    }
                }
                TaiKhoanDAO.updateAccount(acc);
            }
        } else if ("add".equals(action)) {
            String username = req.getParameter("username");
            String email = req.getParameter("email");
            String phoneNumber = req.getParameter("phoneNumber");

            if (username != null) username = username.trim();
            if (email != null) email = email.trim();
            if (phoneNumber != null) phoneNumber = phoneNumber.trim();

            if (!org.example.util.ValidationUtil.isValidUsername(username)) {
                req.getSession().setAttribute("error", "Tên đăng nhập không hợp lệ (3-50 ký tự, chỉ gồm chữ cái, số, gạch dưới và không chứa khoảng trắng)!");
                resp.sendRedirect(req.getContextPath() + "/admin/nhan-su");
                return;
            }

            if (TaiKhoanDAO.kiemtraUsername(username)) {
                req.getSession().setAttribute("error", "Tên đăng nhập đã tồn tại!");
                resp.sendRedirect(req.getContextPath() + "/admin/nhan-su");
                return;
            }

            if (email == null || email.isEmpty()) {
                req.getSession().setAttribute("error", "Email không được để trống!");
                resp.sendRedirect(req.getContextPath() + "/admin/nhan-su");
                return;
            }

            if (!org.example.util.ValidationUtil.isValidEmail(email)) {
                req.getSession().setAttribute("error", "Định dạng Email không hợp lệ và không được chứa khoảng trắng!");
                resp.sendRedirect(req.getContextPath() + "/admin/nhan-su");
                return;
            }

            if (TaiKhoanDAO.kiemtraEmail(email)) {
                req.getSession().setAttribute("error", "Email đã tồn tại!");
                resp.sendRedirect(req.getContextPath() + "/admin/nhan-su");
                return;
            }

            if (phoneNumber != null && !phoneNumber.isEmpty()) {
                if (!org.example.util.ValidationUtil.isValidVNPhone(phoneNumber)) {
                    req.getSession().setAttribute("error", "Định dạng Số điện thoại không hợp lệ (Phải bắt đầu bằng 0 hoặc +84 và có 10 số)!");
                    resp.sendRedirect(req.getContextPath() + "/admin/nhan-su");
                    return;
                }
            }

            String fullName = req.getParameter("fullName");
            if (fullName != null) fullName = fullName.trim();

            TaiKhoan newAcc = new TaiKhoan();
            newAcc.setUsername(username);
            newAcc.setFullName(fullName);
            newAcc.setEmail(email);
            newAcc.setPhoneNumber(phoneNumber);
            
            int newRoleId = Integer.parseInt(req.getParameter("roleId"));
            // Prevent creating new Admin accounts
            if (newRoleId == 1) {
                req.getSession().setAttribute("error", "Không được tạo tài khoản Quản trị viên!");
                resp.sendRedirect(req.getContextPath() + "/admin/nhan-su");
                return;
            }
            newAcc.setRoleId(newRoleId);
            
            String coSoIdStr = req.getParameter("coSoId");
            if (newRoleId == 2 && (coSoIdStr == null || coSoIdStr.isEmpty())) {
                req.getSession().setAttribute("error", "Quản lý cần phải có Cơ sở!");
                resp.sendRedirect(req.getContextPath() + "/admin/nhan-su");
                return;
            }
            if (coSoIdStr != null && !coSoIdStr.isEmpty()) {
                newAcc.setCoSoId(Integer.parseInt(coSoIdStr));
            }
            
            newAcc.setZaloId(req.getParameter("zaloId"));
            newAcc.setMessengerId(req.getParameter("messengerId"));
            newAcc.setMaNganHang(req.getParameter("maNganHang"));
            newAcc.setSoTaiKhoan(req.getParameter("soTaiKhoan"));
            newAcc.setViTriSoTruong(req.getParameter("viTriSoTruong"));
            newAcc.setGioiTinh(req.getParameter("gioiTinh"));
            
            String ngaySinhStr = req.getParameter("ngaySinh");
            if (ngaySinhStr != null && !ngaySinhStr.isEmpty()) {
                newAcc.setNgaySinh(org.example.util.ValidationUtils.parseDate(ngaySinhStr, "yyyy-MM-dd"));
            }
            
            newAcc.setIsLocked(false);
            
            String rawPassword = req.getParameter("password");
            if (rawPassword != null) rawPassword = rawPassword.trim();
            if (rawPassword == null || rawPassword.isEmpty()) {
                rawPassword = "123";
            } else {
                if (!org.example.util.ValidationUtil.isStrongPassword(rawPassword)) {
                    req.getSession().setAttribute("error", "Mật khẩu do admin tạo phải có tối thiểu 8 ký tự, bao gồm cả chữ hoa, chữ thường, số và ký tự đặc biệt!");
                    resp.sendRedirect(req.getContextPath() + "/admin/nhan-su");
                    return;
                }
            }
            newAcc.setPassword(org.mindrot.jbcrypt.BCrypt.hashpw(rawPassword, org.mindrot.jbcrypt.BCrypt.gensalt(12)));
            
            String otpString = TaiKhoanDAO.sendRegistrationOTP(email, newAcc.getFullName());
            req.getSession().setAttribute("otp", otpString);
            req.getSession().setAttribute("tempAccount", newAcc);
            req.getSession().setAttribute("authType", "ADMIN_ADD");
            req.getSession().setAttribute("otpAttempts", 0);
            req.getSession().setAttribute("resendCount", 0);
            req.getSession().setAttribute("needResend", false);
            req.setAttribute("email", email);
            req.getRequestDispatcher("/auth/NhapMa.jsp").forward(req, resp);
            return;
        }
        resp.sendRedirect(req.getContextPath() + "/admin/nhan-su");
    }
}

