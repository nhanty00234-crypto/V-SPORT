package org.example.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Filter chặn người dùng đã đăng nhập truy cập lại các trang Auth (Login, Register, Quên mật khẩu)
 */
@WebFilter(urlPatterns = {"/dangnhap", "/dangky", "/quenmatkhau", "/nhapma", "/nhapmatkhaumoi", "/auth/*"})
public class FilterKhach implements Filter {
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
            String authType = (session != null) ? (String) session.getAttribute("authType") : null;
            if ("ADMIN_ADD".equals(authType) || "ADMIN_EDIT".equals(authType) || "MANAGER_EDIT".equals(authType)) {
                chain.doFilter(request, response);
            } else {
                String requestedWith = httpRequest.getHeader("X-Requested-With");
                boolean isAjax = "XMLHttpRequest".equals(requestedWith);
                org.example.model.TaiKhoan user = (org.example.model.TaiKhoan) session.getAttribute("user");
                String redirectUrl;
                if (user != null) {
                    if (user.getRoleId() == 1) { // Admin
                        redirectUrl = httpRequest.getContextPath() + "/admin/nhan-su";
                    } else if (user.getRoleId() == 2) { // Manager
                        redirectUrl = httpRequest.getContextPath() + "/manager/nhan-su";
                    } else if (user.getRoleId() == 4 || user.getRoleId() == 5) { // Staff
                        redirectUrl = httpRequest.getContextPath() + "/staff/dashboard";
                    } else {
                        redirectUrl = httpRequest.getContextPath() + "/index.jsp";
                    }
                } else {
                    redirectUrl = httpRequest.getContextPath() + "/index.jsp";
                }

                if (isAjax) {
                    httpResponse.setContentType("application/json;charset=UTF-8");
                    httpResponse.getWriter().write("{\"success\": true, \"redirectUrl\": \"" + redirectUrl + "\"}");
                    return;
                }
                httpResponse.sendRedirect(redirectUrl);
            }
        } else {
            chain.doFilter(request, response);
        }
    }

    @Override
    public void destroy() {}
}
