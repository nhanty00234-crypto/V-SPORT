package org.example.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Filter đảm bảo người dùng đi đúng luồng (Email -> OTP) cho đăng ký/admin
 * thêm nhân sự. Quên mật khẩu không còn đi qua /nhapma (xem QuenMatKhauServlet).
 */
@WebFilter(urlPatterns = {"/nhapma"})
public class FilterLuong implements Filter {
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);

        if (session == null
                || (session.getAttribute("otp") == null && session.getAttribute("needResend") == null)) {
            String authType = (session != null) ? (String) session.getAttribute("authType") : null;
            if ("ADMIN_ADD".equals(authType) || "ADMIN_EDIT".equals(authType)) {
                httpResponse.sendRedirect(httpRequest.getContextPath() + "/admin/nhan-su");
            } else if ("MANAGER_EDIT".equals(authType) || "MANAGER_ADD".equals(authType)) {
                httpResponse.sendRedirect(httpRequest.getContextPath() + "/manager/nhan-su");
            } else if ("REGISTER".equals(authType)) {
                httpResponse.sendRedirect(httpRequest.getContextPath() + "/dangky");
            } else {
                httpResponse.sendRedirect(httpRequest.getContextPath() + "/quenmatkhau");
            }
            return;
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}
}
