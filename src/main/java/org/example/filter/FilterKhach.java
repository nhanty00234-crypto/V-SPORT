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
            if ("ADMIN_ADD".equals(authType)) {
                chain.doFilter(request, response);
            } else {
                // Nếu đã đăng nhập thì đá về trang chủ, không cho vào trang login/register nữa
                String requestedWith = httpRequest.getHeader("X-Requested-With");
                boolean isAjax = "XMLHttpRequest".equals(requestedWith);
                if (isAjax) {
                    org.example.model.TaiKhoan user = (org.example.model.TaiKhoan) session.getAttribute("user");
                    String redirectUrl;
                    if (user.getRoleId() == 1) { // Admin
                        redirectUrl = httpRequest.getContextPath() + "/admin/nhan-su";
                    } else if (user.getRoleId() == 2) { // Manager
                        redirectUrl = httpRequest.getContextPath() + "/manager/nhan-su";
                    } else {
                        redirectUrl = httpRequest.getContextPath() + "/index.jsp";
                    }
                    httpResponse.setContentType("application/json;charset=UTF-8");
                    httpResponse.getWriter().write("{\"success\": true, \"redirectUrl\": \"" + redirectUrl + "\"}");
                    return;
                }
                httpResponse.sendRedirect(httpRequest.getContextPath() + "/index.jsp");
            }
        } else {
            chain.doFilter(request, response);
        }
    }

    @Override
    public void destroy() {}
}
