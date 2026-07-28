package org.example.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.model.TaiKhoan;
import org.example.util.Constants;
import org.example.util.RoleRedirectUtil;

import java.io.IOException;

/**
 * Ngăn staff/manager/admin dùng URL thủ công để truy cập khu vực customer.
 * Nếu đã đăng nhập nhưng không phải ROLE_KHACH_HANG → redirect về portal của role đó.
 */
@WebFilter(urlPatterns = {
    "/",
    "/index.jsp",
    "/customer/*",
    "/dat-san",
    "/ghep-keo",
    "/tim-kiem"
})
public class FilterCustomerArea implements Filter {

    @Override
    public void init(FilterConfig cfg) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  req  = (HttpServletRequest)  request;
        HttpServletResponse resp = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);

        if (session != null) {
            TaiKhoan user = (TaiKhoan) session.getAttribute("user");
            if (user != null && user.getRoleId() != Constants.ROLE_KHACH_HANG) {
                String accept = req.getHeader("Accept");
                boolean isApi = req.getRequestURI().contains("/api/")
                        || "XMLHttpRequest".equals(req.getHeader("X-Requested-With"))
                        || (accept != null && accept.contains("application/json"));
                if (isApi) {
                    resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    resp.setCharacterEncoding("UTF-8");
                    resp.setContentType("application/json;charset=UTF-8");
                    resp.getWriter().write("{\"success\":false,\"code\":\"FORBIDDEN\",\"message\":\"Bạn không có quyền truy cập khu vực này.\"}");
                    return;
                }
                // Staff/Manager/Admin đang cố vào khu vực customer → đá về portal đúng role
                String home = RoleRedirectUtil.getHomePathByRoleId(user.getRoleId());
                resp.sendRedirect(req.getContextPath() + home);
                return;
            }
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}
}
