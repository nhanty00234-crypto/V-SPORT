package org.example.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.dao.TaiKhoanDAO;
import org.example.dao.impl.TaiKhoanDAOImpl;
import org.example.util.ValidationUtil;
import org.example.util.JPAUtil;
import org.example.model.CoSo;
import org.example.model.TaiKhoan;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Random;

/**
 * Handles the multi-step owner registration flow:
 *   GET  /owner/register    -> shows landing page
 *   POST /owner/send-otp    -> sends OTP to the given email (AJAX, returns JSON)
 *   POST /owner/verify-otp  -> verifies the OTP (AJAX, returns JSON)
 *   POST /owner/register    -> final registration submission (AJAX, returns JSON)
 */
@WebServlet(urlPatterns = {"/owner/register", "/owner/send-otp", "/owner/verify-otp"})
public class OwnerRegisterServlet extends HttpServlet {
    private static final Logger logger = LogManager.getLogger(OwnerRegisterServlet.class);
    private final TaiKhoanDAO taiKhoanDAO = new TaiKhoanDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/ownerLanding.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");

        String path = req.getServletPath();

        if ("/owner/send-otp".equals(path)) {
            handleSendOtp(req, resp);
        } else if ("/owner/verify-otp".equals(path)) {
            handleVerifyOtp(req, resp);
        } else {
            handleRegister(req, resp);
        }
    }

    // ────────────────────────────────────────
    // SEND OTP
    // ────────────────────────────────────────
    private void handleSendOtp(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        String email = req.getParameter("email");
        if (email != null) {
            email = email.trim();
        }

        if (email == null || email.isEmpty()) {
            out.print("{\"success\":false,\"message\":\"Email không được để trống.\"}");
            return;
        }
        if (!ValidationUtil.isValidEmail(email)) {
            out.print("{\"success\":false,\"message\":\"Email không hợp lệ và không được chứa khoảng trắng.\"}");
            return;
        }
        // Check if email already exists
        if (taiKhoanDAO.kiemtraEmail(email)) {
            out.print("{\"success\":false,\"message\":\"Email đã tồn tại trong hệ thống.\"}");
            return;
        }

        try {
            // Re-use existing OTP sending infrastructure
            String otp = taiKhoanDAO.sendRegistrationOTP(email, "Chủ sân");
            HttpSession session = req.getSession();
            session.setAttribute("ownerOtp", otp);
            session.setAttribute("ownerOtpEmail", email);
            session.setAttribute("ownerOtpTime", System.currentTimeMillis());
            System.out.println("[Owner OTP] Sent OTP to " + email + ": " + otp);
            out.print("{\"success\":true}");
        } catch (Exception e) {
            logger.error("[Owner OTP] Error sending OTP to {}", email, e);
            out.print("{\"success\":false,\"message\":\"Lỗi gửi OTP. Vui lòng thử lại.\"}");
        }
    }

    // ────────────────────────────────────────
    // VERIFY OTP
    // ────────────────────────────────────────
    private void handleVerifyOtp(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        String email = req.getParameter("email");
        String otp = req.getParameter("otp");
        HttpSession session = req.getSession(false);

        if (session == null) {
            out.print("{\"success\":false,\"message\":\"Phiên đã hết hạn. Vui lòng thử lại.\"}");
            return;
        }

        String savedOtp = (String) session.getAttribute("ownerOtp");
        String savedEmail = (String) session.getAttribute("ownerOtpEmail");

        if (savedOtp == null || savedEmail == null) {
            out.print("{\"success\":false,\"message\":\"Chưa gửi OTP. Vui lòng quay lại bước trước.\"}");
            return;
        }

        if (!savedEmail.equalsIgnoreCase(email)) {
            out.print("{\"success\":false,\"message\":\"Email không khớp.\"}");
            return;
        }

        // Check OTP expiry (5 minutes)
        Long otpTime = (Long) session.getAttribute("ownerOtpTime");
        if (otpTime != null && System.currentTimeMillis() - otpTime > 5 * 60 * 1000) {
            out.print("{\"success\":false,\"message\":\"Mã OTP đã hết hạn. Vui lòng gửi lại.\"}");
            return;
        }

        if (savedOtp.equals(otp)) {
            session.setAttribute("ownerEmailVerified", true);
            // Clear OTP from session
            session.removeAttribute("ownerOtp");
            out.print("{\"success\":true}");
        } else {
            out.print("{\"success\":false,\"message\":\"Mã OTP không đúng.\"}");
        }
    }

    // ────────────────────────────────────────
    // FINAL REGISTRATION
    // ────────────────────────────────────────
    private void handleRegister(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        PrintWriter out = resp.getWriter();
        HttpSession session = req.getSession(false);

        // Check that email was verified777777777
        Boolean verified = (session != null) ? (Boolean) session.getAttribute("ownerEmailVerified") : null;
        if (verified == null || !verified) {
            out.print("{\"success\":false,\"message\":\"Email chưa được xác thực.\"}");
            return;
        }

        String ownerName   = req.getParameter("ownerName");
        String email       = req.getParameter("email");
        String phone       = req.getParameter("phone");
        String address     = req.getParameter("address");
        String description = req.getParameter("description");
        String openTime    = req.getParameter("openTime");
        String closeTime   = req.getParameter("closeTime");
        String operatingDays = req.getParameter("operatingDays");
        String sportsData  = req.getParameter("sportsData"); // JSON array

        if (ownerName != null) ownerName = ownerName.trim();
        if (email != null) email = email.trim();
        if (phone != null) phone = phone.trim();

        // Basic validation
        if (ownerName == null || ownerName.isEmpty() ||
                email == null || email.isEmpty() ||
                phone == null || phone.isEmpty()) {
            out.print("{\"success\":false,\"message\":\"Vui lòng điền đầy đủ thông tin bắt buộc.\"}");
            return;
        }

        if (!ValidationUtil.isValidEmail(email)) {
            out.print("{\"success\":false,\"message\":\"Email không hợp lệ và không được chứa khoảng trắng.\"}");
            return;
        }

        if (!ValidationUtil.isValidVNPhone(phone)) {
            out.print("{\"success\":false,\"message\":\"Số điện thoại không hợp lệ.\"}");
            return;
        }

        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction trans = em.getTransaction();
        try {
            trans.begin();

            // Check if email already registered
            Long existingCount = em.createQuery("SELECT COUNT(a) FROM TaiKhoan a WHERE a.email = :email OR a.username = :username", Long.class)
                    .setParameter("email", email)
                    .setParameter("username", email)
                    .getSingleResult();
            if (existingCount > 0) {
                out.print("{\"success\":false,\"message\":\"Email đã được đăng ký trên hệ thống.\"}");
                trans.rollback();
                return;
            }

            // Parse sportsData to obtain loaiHinhKinhDoanh and total count
            int totalCourts = 0;
            java.util.List<String> sportNames = new java.util.ArrayList<>();
            if (sportsData != null && !sportsData.isEmpty()) {
                java.util.regex.Pattern pattern = java.util.regex.Pattern.compile("\"sport\"\\s*:\\s*\"([^\"]+)\"\\s*,\\s*\"quantity\"\\s*:\\s*(\\d+)");
                java.util.regex.Matcher matcher = pattern.matcher(sportsData);
                while (matcher.find()) {
                    String sportName = matcher.group(1);
                    int quantity = Integer.parseInt(matcher.group(2));
                    sportNames.add(sportName);
                    totalCourts += quantity;
                }
            }

            String loaiHinh = String.join(", ", sportNames);

            // Create new CoSo (Pending Approval)
            CoSo coSo = new CoSo();
            coSo.setTenCoSo(ownerName);
            coSo.setDiaChi(address);
            coSo.setSoDienThoai(phone);
            coSo.setTrangThai("Chờ duyệt");
            if (openTime != null && !openTime.isEmpty()) {
                coSo.setGioMoCua(java.time.LocalTime.parse(openTime));
            }
            if (closeTime != null && !closeTime.isEmpty()) {
                coSo.setGioDongCua(java.time.LocalTime.parse(closeTime));
            }
            coSo.setMoTa(description);
            coSo.setLoaiHinhKinhDoanh(loaiHinh);
            coSo.setSoLuongSanDuKien(totalCourts);

            em.persist(coSo);
            em.flush(); // To retrieve generated CoSoID

            // Create locked manager Account
            TaiKhoan managerAcc = new TaiKhoan();
            managerAcc.setUsername(email);
            managerAcc.setPassword(org.mindrot.jbcrypt.BCrypt.hashpw("123456", org.mindrot.jbcrypt.BCrypt.gensalt(12)));
            managerAcc.setFullName(ownerName);
            managerAcc.setPhoneNumber(phone);
            managerAcc.setEmail(email);
            managerAcc.setRoleId(2); // Manager (Owner) role
            managerAcc.setCoSoId(coSo.getCoSoID());
            managerAcc.setIsLocked(true); // Locked until approved by admin
            managerAcc.setDiemUyTin(100);
            managerAcc.setDiemTrinhDo(1000);
            managerAcc.setNhanThongBaoSos(true);

            em.persist(managerAcc);
            em.flush(); // To retrieve generated AccountID

            // Link CoSo to Manager Account
            coSo.setAccountID_QuanLy(managerAcc.getAccountId());
            em.merge(coSo);

            trans.commit();

            // Clean up session OTP attributes
            if (session != null) {
                session.removeAttribute("ownerEmailVerified");
                session.removeAttribute("ownerOtpEmail");
                session.removeAttribute("ownerOtpTime");
            }

            out.print("{\"success\":true}");
        } catch (Exception e) {
            if (trans.isActive()) {
                trans.rollback();
            }
            logger.error("[Owner Registration] Persistence error", e);
            out.print("{\"success\":false,\"message\":\"Lỗi lưu thông tin đăng ký. Vui lòng thử lại.\"}");
        } finally {
            em.close();
        }
    }
}
