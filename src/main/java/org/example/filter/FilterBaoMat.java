package org.example.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.model.TaiKhoan;
import java.io.IOException;

/**
 * Filter bảo mật cho vùng Admin
 */
@WebFilter(urlPatterns = {"/views/*"})
public class FilterBaoMat implements Filter {
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);

        String loginURI = httpRequest.getContextPath() + "/dangnhap";
        boolean loggedIn = (session != null && session.getAttribute("user") != null);

        if (loggedIn) {
            TaiKhoan user = (TaiKhoan) session.getAttribute("user");
            int roleId = user.getRoleId();

            // Phân quyền:
            // Role 1: Admin - Được vào hết
            // Các Role khác (bao gồm Customer): Không được vào vùng quản lý
            
            if (roleId == 1 || roleId == 2 || roleId == 8) {
                chain.doFilter(request, response);
            } else {
                httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập khu vực quản lý.");
            }
        } else {
            httpResponse.sendRedirect(loginURI);
        }
    }

    @Override
    public void destroy() {}
}
