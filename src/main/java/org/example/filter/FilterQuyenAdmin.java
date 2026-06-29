package org.example.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.model.TaiKhoan;
import java.io.IOException;

/**
 * Filter đặc quyền cho Admin để bảo vệ các route /admin/*
 */
@WebFilter("/admin/*")
public class FilterQuyenAdmin implements Filter {
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);

        boolean loggedIn = (session != null && session.getAttribute("user") != null);

        if (loggedIn) {
            TaiKhoan user = (TaiKhoan) session.getAttribute("user");
            String path = httpRequest.getServletPath();
            if (path.contains("/quan-ly-san") || path.contains("/QuanLySan.jsp")) {
                httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN, "Quản trị viên không có quyền quản lý sân (Chức năng này dành riêng cho Quản lý cơ sở).");
                return;
            }
            // Chỉ Role 1 (Admin) mới được vào vùng này
            if (user.getRoleId() == 1) {
                chain.doFilter(request, response);
            } else {
                httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền Admin để truy cập chức năng này.");
            }
        } else {
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/dangnhap?admin=true");
        }
    }

    @Override
    public void destroy() {}
}
