package org.example.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.dao.LichDatSanDAO;
import org.example.dao.impl.LichDatSanDAOImpl;
import org.example.model.Lichdatsan;
import org.example.model.TaiKhoan;

import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * QuanLyDatSanServlet - Servlet xử lý toàn bộ luồng phê duyệt và quản lý đơn đặt sân của Manager & Staff
 */
@WebServlet(urlPatterns = { "/manager/dat-san", "/staff/dat-san" })
public class QuanLyDatSanServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(QuanLyDatSanServlet.class.getName());
    private final LichDatSanDAO lichDatSanDAO = new LichDatSanDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        TaiKhoan user = (TaiKhoan) session.getAttribute("user");

        // 1. Kiểm tra đăng nhập
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return;
        }

        // 2. Kiểm tra phân quyền dựa trên URI truy cập
        String path = req.getServletPath();
        boolean isManagerPath = path.startsWith("/manager");
        boolean isStaffPath = path.startsWith("/staff");

        if (isManagerPath && user.getRoleId() != 2) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền quản lý để truy cập chức năng này.");
            return;
        }

        if (isStaffPath && user.getRoleId() != 4 && user.getRoleId() != 5) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền nhân viên để truy cập chức năng này.");
            return;
        }

        // 3. Tải danh sách đơn đặt sân thuộc cơ sở của tài khoản
        int coSoId = user.getCoSoId();
        try {
            List<Lichdatsan> dsLich = lichDatSanDAO.getLichDatSanByCoSo(coSoId);
            req.setAttribute("dsLich", dsLich);
            LOGGER.info("Loaded " + dsLich.size() + " bookings for branch ID " + coSoId);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi khi tải danh sách lịch đặt sân cho cơ sở " + coSoId, e);
            req.setAttribute("error", "Lỗi tải dữ liệu: " + e.getMessage());
        }

        // 4. Forward sang trang giao diện tương ứng
        if (isManagerPath) {
            req.getRequestDispatcher("/manager/QuanLyDatSan.jsp").forward(req, resp);
        } else {
            req.getRequestDispatcher("/staff/QuanLyDatSan.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession();
        TaiKhoan user = (TaiKhoan) session.getAttribute("user");

        // 1. Kiểm tra đăng nhập
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return;
        }

        // 2. Kiểm tra quyền
        String path = req.getServletPath();
        boolean isManagerPath = path.startsWith("/manager");
        boolean isStaffPath = path.startsWith("/staff");

        if (isManagerPath && user.getRoleId() != 2) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        if (isStaffPath && user.getRoleId() != 4 && user.getRoleId() != 5) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        // 3. Tiếp nhận action
        String action = req.getParameter("action");
        String idStr = req.getParameter("id");
        if (action == null || idStr == null) {
            session.setAttribute("error", "Tham số yêu cầu không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + path);
            return;
        }

        try {
            int datSanId = Integer.parseInt(idStr);

            if ("approve".equals(action)) {
                boolean result = lichDatSanDAO.duyetLichDatSan(datSanId, user.getAccountId(), user.getCoSoId());
                if (result) {
                    session.setAttribute("message", "Đã duyệt đơn đặt sân #" + datSanId + " thành công!");
                } else {
                    session.setAttribute("error", "Duyệt đơn đặt sân thất bại.");
                }
            } else if ("reject".equals(action)) {
                String reason = req.getParameter("reason");
                boolean result = lichDatSanDAO.tuChoiLichDatSan(datSanId, reason, user.getCoSoId());
                if (result) {
                    session.setAttribute("message", "Đã từ chối đơn đặt sân #" + datSanId + ".");
                } else {
                    session.setAttribute("error", "Từ chối đơn đặt sân thất bại.");
                }
            } else {
                session.setAttribute("error", "Hành động không được hỗ trợ.");
            }
        } catch (NumberFormatException e) {
            session.setAttribute("error", "ID đơn đặt sân không hợp lệ.");
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Lỗi khi xử lý duyệt/từ chối đơn đặt sân", e);
            session.setAttribute("error", e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + path);
    }
}
