package org.example.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.nio.charset.StandardCharsets;

/**
 * Sets UTF-8 character encoding on request/response and disables caching
 * for dynamic (non-static) responses. This is NOT encryption or security
 * obfuscation — formerly misnamed FilterMaHoa.
 */
@WebFilter("/*")
public class EncodingAndCacheControlFilter implements Filter {
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        request.setCharacterEncoding(StandardCharsets.UTF_8.name());
        response.setCharacterEncoding(StandardCharsets.UTF_8.name());

        HttpServletRequest httpReq = (HttpServletRequest) request;
        HttpServletResponse httpResp = (HttpServletResponse) response;

        String uri = httpReq.getRequestURI();
        // Static assets (CSS/JS/images) do not need no-cache
        boolean isStatic = uri.endsWith(".css") || uri.endsWith(".js")
                || uri.endsWith(".png") || uri.endsWith(".jpg")
                || uri.endsWith(".jpeg") || uri.endsWith(".gif")
                || uri.endsWith(".svg") || uri.endsWith(".ico")
                || uri.endsWith(".woff") || uri.endsWith(".woff2")
                || uri.endsWith(".ttf") || uri.endsWith(".eot");

        if (!isStatic) {
            httpResp.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
            httpResp.setHeader("Pragma", "no-cache");
            httpResp.setDateHeader("Expires", 0);
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}
}
