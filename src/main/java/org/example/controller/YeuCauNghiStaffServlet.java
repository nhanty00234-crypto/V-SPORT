package org.example.controller;

import org.example.model.TaiKhoan;
import org.example.model.YeuCauNghi;
import org.example.service.YeuCauNghiService;

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
import java.util.List;

/**
 * Servlet quản lý yêu cầu nghỉ dành cho Staff/Nhân viên
 * Cho phép xem yêu cầu của mình và tạo yêu cầu nghỉ mới
 */
@WebServlet("/staff/yeu-cau-nghi")
public class YeuCauNghiStaffServlet extends HttpServlet {

    private static final Logger logger = LogManager.getLogger(YeuCauNghiStaffServlet.class);

    private final YeuCauNghiService yeuCauNghiService;

    public YeuCauNghiStaffServlet() {
        this.yeuCauNghiService = new YeuCauNghiService();
    }

    public YeuCauNghiStaffServlet(YeuCauNghiService yeuCauNghiService) {
        this.yeuCauNghiService = yeuCauNghiService;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession();

        TaiKhoan staff = (TaiKhoan) session.getAttribute("user");
        if (!isAuthorizedStaff(staff, req, resp, session)) {
            return;
        }

        int accountID = staff.getAccountId();

        try {
            String action = req.getParameter("action");
            String status = req.getParameter("status");

            if ("new".equals(action)) {
                // Hiển thị form tạo yêu cầu mới
                req.setAttribute("staff", staff);
                req.getRequestDispatcher("/staff/yeuCauNghi_form.jsp").forward(req, resp);
            } else {
                // Hiển thị danh sách yêu cầu của nhân viên
                List<YeuCauNghi> myRequests;
                if (status != null && !status.isEmpty()) {
                    myRequests = yeuCauNghiService.getYeuCauNghiByAccountAndStatus(accountID, status);
                } else {
                    myRequests = yeuCauNghiService.getYeuCauNghiByAccount(accountID);
                }
                req.setAttribute("requests", myRequests);
                req.getRequestDispatcher("/staff/yeuCauNghi_my.jsp").forward(req, resp);
            }

        } catch (Exception e) {
            logger.error("Error in YeuCauNghiStaffServlet doGet: {}", e.getMessage(), e);
            session.setAttribute("error", "Lỗi khi tải dữ liệu: " + e.getMessage());
            try {
                req.getRequestDispatcher("/staff/yeuCauNghi_my.jsp").forward(req, resp);
            } catch (Exception ex) {
                throw new ServletException("Forward to JSP failed", ex);
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession();

        TaiKhoan staff = (TaiKhoan) session.getAttribute("user");
        if (!isAuthorizedStaff(staff, req, resp, session)) {
            return;
        }

        int accountID = staff.getAccountId();
        Integer coSoID = staff.getCoSoId();

        if (coSoID == null) {
            session.setAttribute("error", "Tài khoản nhân viên chưa được liên kết với cơ sở nào.");
            resp.sendRedirect(req.getContextPath() + "/staff/yeu-cau-nghi");
            return;
        }

        try {
            // Lấy parameters từ form
            String ngayNghiStr = req.getParameter("ngayNghi");
            String loaiNghi = req.getParameter("loaiNghi");
            String lyDo = req.getParameter("lyDo");
            String mucDoKhanCapStr = req.getParameter("mucDoKhanCap");

            // Validation cơ bản
            if (ngayNghiStr == null || ngayNghiStr.isEmpty()) {
                session.setAttribute("error", "Ngày nghỉ không được để trống");
                resp.sendRedirect(req.getContextPath() + "/staff/yeu-cau-nghi?action=new");
                return;
            }
            if (loaiNghi == null || loaiNghi.isEmpty()) {
                session.setAttribute("error", "Loại nghỉ không được để trống");
                resp.sendRedirect(req.getContextPath() + "/staff/yeu-cau-nghi?action=new");
                return;
            }
            if (lyDo == null || lyDo.trim().isEmpty()) {
                session.setAttribute("error", "Lý do không được để trống");
                resp.sendRedirect(req.getContextPath() + "/staff/yeu-cau-nghi?action=new");
                return;
            }

            // Parse ngày
            LocalDate ngayNghi = LocalDate.parse(ngayNghiStr);
            boolean mucDoKhanCap = "true".equals(mucDoKhanCapStr);

            // Tạo entity
            YeuCauNghi yeuCauNghi = new YeuCauNghi(accountID, coSoID, ngayNghi, loaiNghi, lyDo);
            yeuCauNghi.setMucDoKhanCap(mucDoKhanCap);

            // Gọi service để tạo
            boolean success = yeuCauNghiService.createYeuCauNghi(yeuCauNghi);

            if (success) {
                session.setAttribute("success", "Đã gửi yêu cầu nghỉ thành công. Chờ quản lý duyệt.");
                resp.sendRedirect(req.getContextPath() + "/staff/yeu-cau-nghi");
            } else {
                session.setAttribute("error", "Không thể gửi yêu cầu nghỉ. Vui lòng thử lại.");
                resp.sendRedirect(req.getContextPath() + "/staff/yeu-cau-nghi?action=new");
            }

        } catch (IllegalArgumentException e) {
            logger.error("Validation error: {}", e.getMessage(), e);
            session.setAttribute("error", e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/staff/yeu-cau-nghi?action=new");
        } catch (Exception e) {
            logger.error("Unexpected error in YeuCauNghiStaffServlet doPost: {}", e.getMessage(), e);
            session.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/staff/yeu-cau-nghi?action=new");
        }
    }

    /**
     * Kiểm tra xem user có quyền truy cập trang Staff không
     */
    private boolean isAuthorizedStaff(TaiKhoan user, HttpServletRequest req, HttpServletResponse resp, HttpSession session)
            throws IOException {
        if (user == null) {
            session.setAttribute("error", "Vui lòng đăng nhập để tiếp tục");
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return false;
        }

        int roleId = user.getRoleId();
        // Chỉ Lễ tân (4) và Bảo vệ (5) được truy cập (Admin/Manager có trang riêng)
        if (roleId != 4 && roleId != 5) {
            logger.warn("Unauthorized access attempt by user ID: {}, role: {}", user.getAccountId(), roleId);
            session.setAttribute("error", "Bạn không có quyền truy cập trang này");
            resp.sendRedirect(req.getContextPath() + "/home");
            return false;
        }

        // Kiểm tra CoSoID
        if (user.getCoSoId() == null) {
            logger.warn("Staff without CoSoID: {}", user.getAccountId());
            session.setAttribute("error", "Tài khoản nhân viên chưa được liên kết với cơ sở nào");
            resp.sendRedirect(req.getContextPath() + "/home");
            return false;
        }

        return true;
    }
}
