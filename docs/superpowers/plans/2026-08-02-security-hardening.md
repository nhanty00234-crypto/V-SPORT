# Security Hardening Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Thêm CSRF protection, rate limiting cho booking/cancel API, auto-lock tài khoản khi điểm uy tín < 20, và secure cookie flags để bảo vệ hệ thống khỏi bot tự động và CSRF attack.

**Architecture:** Dùng Servlet Filter pattern (đúng pattern hiện tại của project) — thêm 2 filter mới (`CsrfFilter`, `BookingRateLimitFilter`) vào filter chain, tái dùng `SimpleRateLimiter.SHARED`, thêm CSRF token helper vào JSP include, và check điểm uy tín trước khi cho đặt sân.

**Tech Stack:** Jakarta Servlet 6.0, Java 17, JSP/JSPF, `SimpleRateLimiter` (đã có), `Constants.java`

## Global Constraints

- Package filter: `org.example.filter`
- Dùng `@WebFilter` annotation (không khai báo trong web.xml)
- Import: `jakarta.servlet.*` (không phải `javax.servlet`)
- Tái dùng `SimpleRateLimiter.SHARED` từ `org.example.service.reset.SimpleRateLimiter`
- CSRF token key trong session: `"csrfToken"`
- CSRF header name: `"X-CSRF-Token"`
- CSRF form field name: `"_csrf"`
- Auto-lock threshold: điểm uy tín < 20 (thêm constant `REPUTATION_BOOKING_BLOCK_THRESHOLD = 20` vào Constants.java)

---

### Task 1: Thêm constant REPUTATION_BOOKING_BLOCK_THRESHOLD vào Constants.java

**Files:**
- Modify: `src/main/java/org/example/util/Constants.java` (sau dòng REPUTATION_MATCHMAKING_THRESHOLD)

**Interfaces:**
- Produces: `Constants.REPUTATION_BOOKING_BLOCK_THRESHOLD` (int = 20)

- [ ] **Step 1: Thêm constant**

Mở `src/main/java/org/example/util/Constants.java`, tìm dòng:
```java
public static final int REPUTATION_MATCHMAKING_THRESHOLD = 60;
```
Thêm sau dòng đó:
```java
// Ngưỡng khóa đặt sân: tài khoản có điểm uy tín dưới mức này không được đặt sân
public static final int REPUTATION_BOOKING_BLOCK_THRESHOLD = 20;
```

- [ ] **Step 2: Commit**

```bash
git add src/main/java/org/example/util/Constants.java
git commit -m "feat(security): add REPUTATION_BOOKING_BLOCK_THRESHOLD constant"
```

---

### Task 2: Tạo CsrfFilter

**Files:**
- Create: `src/main/java/org/example/filter/CsrfFilter.java`

**Interfaces:**
- Produces: Session attribute `"csrfToken"` (String UUID) — được đọc bởi `csrf-token.jspf` (Task 3)
- Produces: Validate POST request có `_csrf` param hoặc `X-CSRF-Token` header khớp với session token

- [ ] **Step 1: Tạo CsrfFilter.java**

```java
package org.example.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.UUID;

/**
 * CSRF protection cho tất cả POST endpoints của customer/manager/admin.
 * Dùng Synchronizer Token Pattern: token sinh ra lần đầu, lưu trong session,
 * validate trên mọi POST. AJAX dùng header X-CSRF-Token, form dùng hidden field _csrf.
 */
@WebFilter(urlPatterns = {"/customer/*", "/manager/*", "/admin/*", "/staff/*"})
public class CsrfFilter implements Filter {

    // Các URL không cần CSRF (PayOS webhook callback — gọi từ server bên ngoài)
    private static final java.util.Set<String> CSRF_EXEMPT = java.util.Set.of(
        "/customer/payos-return",
        "/customer/payos-cancel"
    );

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);

        // Sinh token nếu chưa có (kể cả GET — để form load xong đã có token)
        if (session != null && session.getAttribute("csrfToken") == null) {
            session.setAttribute("csrfToken", UUID.randomUUID().toString());
        }

        if ("POST".equalsIgnoreCase(req.getMethod())) {
            String contextPath = req.getContextPath();
            String uri = req.getRequestURI().substring(contextPath.length());

            if (!CSRF_EXEMPT.contains(uri)) {
                if (!isValidCsrf(req)) {
                    resp.sendError(HttpServletResponse.SC_FORBIDDEN, "CSRF token không hợp lệ.");
                    return;
                }
            }
        }

        chain.doFilter(request, response);
    }

    private boolean isValidCsrf(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return false;

        String sessionToken = (String) session.getAttribute("csrfToken");
        if (sessionToken == null) return false;

        // Form POST: hidden field _csrf
        String formToken = req.getParameter("_csrf");
        if (sessionToken.equals(formToken)) return true;

        // AJAX: header X-CSRF-Token
        String headerToken = req.getHeader("X-CSRF-Token");
        return sessionToken.equals(headerToken);
    }

    @Override public void init(FilterConfig fc) {}
    @Override public void destroy() {}
}
```

- [ ] **Step 2: Commit**

```bash
git add src/main/java/org/example/filter/CsrfFilter.java
git commit -m "feat(security): add CsrfFilter with synchronizer token pattern"
```

---

### Task 3: Tạo csrf-token.jspf — CSRF hidden field include

**Files:**
- Create: `src/main/webapp/WEB-INF/jspf/csrf-token.jspf`

**Interfaces:**
- Consumes: Session attribute `"csrfToken"` (String) từ CsrfFilter (Task 2)
- Produces: Hidden input `<input type="hidden" name="_csrf" value="...">` — nhúng vào mọi form POST

- [ ] **Step 1: Tạo thư mục jspf nếu chưa có**

```bash
mkdir -p "src/main/webapp/WEB-INF/jspf"
```

- [ ] **Step 2: Tạo csrf-token.jspf**

```jsp
<%-- CSRF hidden field — nhúng vào mọi <form method="post"> --%>
<input type="hidden" name="_csrf" value="${sessionScope.csrfToken}">
```

- [ ] **Step 3: Commit**

```bash
git add src/main/webapp/WEB-INF/jspf/csrf-token.jspf
git commit -m "feat(security): add csrf-token.jspf include fragment"
```

---

### Task 4: Nhúng CSRF token vào các form POST của customer

**Files:**
- Modify: `src/main/webapp/customer/DatLichTrucQuan.jsp` (form đặt sân)
- Modify: `src/main/webapp/customer/LichSuDatSan.jsp` (form hủy sân nếu có)
- Modify: `src/main/webapp/customer/TaiKhoan.jsp` (form cập nhật tài khoản)
- Modify: `src/main/webapp/customer/DoiMatKhau.jsp` (form đổi mật khẩu)
- Modify: `src/main/webapp/customer/HoSo.jsp` (form hồ sơ)

**Interfaces:**
- Consumes: `WEB-INF/jspf/csrf-token.jspf` (Task 3)

- [ ] **Step 1: Tìm tất cả form POST trong customer JSPs**

```bash
grep -rn 'method="post"\|method="POST"' src/main/webapp/customer/ src/main/webapp/auth/
```

- [ ] **Step 2: Với mỗi `<form method="post">` tìm được, thêm include ngay sau thẻ `<form>`**

Ví dụ trong `DatLichTrucQuan.jsp`, tìm:
```html
<form method="post" ...>
```
Thêm ngay sau:
```jsp
    <jsp:include page="/WEB-INF/jspf/csrf-token.jspf"/>
```

- [ ] **Step 3: Xử lý AJAX POST — thêm meta tag vào `<head>` của layout chính**

Tìm file layout/header JSP được include bởi các trang (thường là `header.jsp` hoặc `layout.jsp`).

Chạy:
```bash
grep -rn "<%@ include\|jsp:include" src/main/webapp/customer/DatLichTrucQuan.jsp
```

Thêm vào `<head>` của layout:
```html
<meta name="csrf-token" content="${sessionScope.csrfToken}">
```

- [ ] **Step 4: Thêm JS global để gắn CSRF header vào mọi AJAX POST**

Tìm file JS chính (thường `main.js` hoặc trong layout), thêm:
```javascript
// Gắn CSRF token vào mọi fetch/XHR POST
const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;
const originalFetch = window.fetch;
window.fetch = function(url, options = {}) {
    if (options.method && options.method.toUpperCase() === 'POST') {
        options.headers = { ...(options.headers || {}), 'X-CSRF-Token': csrfToken };
    }
    return originalFetch(url, options);
};
```

- [ ] **Step 5: Commit**

```bash
git add src/main/webapp/
git commit -m "feat(security): inject CSRF token into all customer POST forms and AJAX"
```

---

### Task 5: Tạo BookingRateLimitFilter

**Files:**
- Create: `src/main/java/org/example/filter/BookingRateLimitFilter.java`

**Interfaces:**
- Consumes: `SimpleRateLimiter.SHARED` từ `org.example.service.reset.SimpleRateLimiter`
- Consumes: Session attribute `"taiKhoan"` (TaiKhoan object) để lấy account ID
- Produces: HTTP 429 nếu vượt rate limit; cho qua nếu OK

Rate limits:
- POST `/customer/dat-san` hoặc `/customer/dat_san`: 5 lần/phút per IP + 5 lần/phút per account
- POST `/customer/huy-dat-san` hoặc `/customer/refund-cancel`: 5 lần/phút per IP + 5 lần/phút per account

- [ ] **Step 1: Tạo BookingRateLimitFilter.java**

```java
package org.example.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.model.TaiKhoan;
import org.example.service.reset.SimpleRateLimiter;

import java.io.IOException;
import java.util.Set;

/**
 * Rate limiting cho booking và cancel endpoints.
 * Giới hạn: 5 request/phút per IP và 5 request/phút per account.
 * Tái dùng SimpleRateLimiter.SHARED (đã có trong project).
 */
@WebFilter(urlPatterns = {"/customer/dat-san", "/customer/dat_san",
                           "/customer/huy-dat-san", "/customer/refund-cancel"})
public class BookingRateLimitFilter implements Filter {

    private static final int MAX_PER_MINUTE = 5;
    private static final long WINDOW_MS = 60_000L;

    private static final Set<String> RATE_LIMITED_PATHS = Set.of(
        "/customer/dat-san", "/customer/dat_san",
        "/customer/huy-dat-san", "/customer/refund-cancel"
    );

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        // Chỉ giới hạn POST
        if (!"POST".equalsIgnoreCase(req.getMethod())) {
            chain.doFilter(request, response);
            return;
        }

        String contextPath = req.getContextPath();
        String uri = req.getRequestURI().substring(contextPath.length());
        // Bỏ query string nếu có
        int qIdx = uri.indexOf('?');
        if (qIdx > 0) uri = uri.substring(0, qIdx);

        if (!RATE_LIMITED_PATHS.contains(uri)) {
            chain.doFilter(request, response);
            return;
        }

        long now = System.currentTimeMillis();
        String ip = getClientIp(req);

        // Rate limit per IP
        String ipKey = "booking-ip:" + ip;
        if (!SimpleRateLimiter.SHARED.tryAcquire(ipKey, MAX_PER_MINUTE, WINDOW_MS, now)) {
            sendRateLimitResponse(resp, req);
            return;
        }

        // Rate limit per account (nếu đã đăng nhập)
        HttpSession session = req.getSession(false);
        if (session != null) {
            TaiKhoan tk = (TaiKhoan) session.getAttribute("taiKhoan");
            if (tk != null) {
                String accountKey = "booking-acc:" + tk.getMaTaiKhoan();
                if (!SimpleRateLimiter.SHARED.tryAcquire(accountKey, MAX_PER_MINUTE, WINDOW_MS, now)) {
                    sendRateLimitResponse(resp, req);
                    return;
                }
            }
        }

        chain.doFilter(request, response);
    }

    private void sendRateLimitResponse(HttpServletResponse resp, HttpServletRequest req)
            throws IOException {
        resp.setStatus(429);
        String accept = req.getHeader("Accept");
        if (accept != null && accept.contains("application/json")) {
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().write("{\"error\":\"Bạn thao tác quá nhanh. Vui lòng thử lại sau 1 phút.\"}");
        } else {
            resp.setContentType("text/html;charset=UTF-8");
            resp.getWriter().write("<h3>Bạn thao tác quá nhanh. Vui lòng thử lại sau 1 phút.</h3>");
        }
    }

    private String getClientIp(HttpServletRequest req) {
        String ip = req.getHeader("X-Forwarded-For");
        if (ip != null && !ip.isEmpty() && !"unknown".equalsIgnoreCase(ip)) {
            // Lấy IP đầu tiên trong chuỗi proxy
            return ip.split(",")[0].trim();
        }
        return req.getRemoteAddr();
    }

    @Override public void init(FilterConfig fc) {}
    @Override public void destroy() {}
}
```

- [ ] **Step 2: Commit**

```bash
git add src/main/java/org/example/filter/BookingRateLimitFilter.java
git commit -m "feat(security): add BookingRateLimitFilter — 5 req/min per IP and account"
```

---

### Task 6: Auto-lock đặt sân khi điểm uy tín < 20

**Files:**
- Modify: `src/main/java/org/example/controller/customer/DatSanServlet.java` — thêm check trước khi xử lý booking
- Modify: `src/main/java/org/example/service/booking/BookingCancellationService.java` — thêm check trước khi cho hủy

**Interfaces:**
- Consumes: `Constants.REPUTATION_BOOKING_BLOCK_THRESHOLD` (Task 1)
- Consumes: `TaiKhoan.getDiemUyTin()` (đã có)

- [ ] **Step 1: Tìm điểm inject trong DatSanServlet — method handleDatSan()**

```bash
grep -n "handleDatSan\|taiKhoan\|diemUyTin" src/main/java/org/example/controller/customer/DatSanServlet.java | head -30
```

- [ ] **Step 2: Thêm check điểm uy tín trong handleDatSan() của DatSanServlet**

Tìm đoạn đầu của `handleDatSan()` nơi lấy `TaiKhoan` từ session (thường là `session.getAttribute("taiKhoan")`). Thêm ngay sau khi lấy được `TaiKhoan`:

```java
// Chặn đặt sân nếu điểm uy tín quá thấp
if (taiKhoan.getDiemUyTin() < Constants.REPUTATION_BOOKING_BLOCK_THRESHOLD) {
    sendJsonError(response, "Tài khoản của bạn đã bị hạn chế đặt sân do điểm uy tín quá thấp (< "
        + Constants.REPUTATION_BOOKING_BLOCK_THRESHOLD + " điểm). Vui lòng liên hệ quản lý.");
    return;
}
```

(Nếu DatSanServlet dùng `request.setAttribute` + forward thay vì JSON, điều chỉnh cách trả lỗi cho phù hợp với pattern hiện tại của servlet.)

- [ ] **Step 3: Tìm điểm inject trong BookingCancellationService.cancelByCustomer()**

```bash
grep -n "cancelByCustomer\|isCancellableStatus\|taiKhoan" src/main/java/org/example/service/booking/BookingCancellationService.java | head -20
```

- [ ] **Step 4: Thêm check trong cancelByCustomer() của BookingCancellationService**

Tìm phần đầu `cancelByCustomer()` nơi validate ownership. Thêm check điểm uy tín:

```java
// Tài khoản điểm uy tín < 20 vẫn được hủy (để giải phóng sân),
// nhưng sẽ bị trừ điểm bình thường và không được đặt sân mới.
// Không block hủy — chỉ block đặt mới.
```

(Lưu ý: không block cancel — chỉ block đặt mới. Cho hủy sân giúp giải phóng sân cho người khác.)

- [ ] **Step 5: Commit**

```bash
git add src/main/java/org/example/controller/customer/DatSanServlet.java
git add src/main/java/org/example/service/booking/BookingCancellationService.java
git commit -m "feat(security): block booking when reputation score < 20"
```

---

### Task 7: Thêm secure cookie flags vào web.xml

**Files:**
- Modify: `src/main/webapp/WEB-INF/web.xml`

**Interfaces:**
- Produces: Session cookie với `HttpOnly=true`, `Secure=true` (Secure chỉ dùng trên HTTPS prod)

- [ ] **Step 1: Thêm session-config vào web.xml**

Mở `src/main/webapp/WEB-INF/web.xml`, thêm trước thẻ đóng `</web-app>`:

```xml
    <session-config>
        <session-timeout>30</session-timeout>
        <cookie-config>
            <http-only>true</http-only>
            <!-- Bật Secure khi deploy lên HTTPS production -->
            <!-- <secure>true</secure> -->
        </cookie-config>
        <tracking-mode>COOKIE</tracking-mode>
    </session-config>
```

Lưu ý: `<secure>true</secure>` được comment out vì dev chạy HTTP. Uncomment khi deploy production HTTPS.

- [ ] **Step 2: Commit**

```bash
git add src/main/webapp/WEB-INF/web.xml
git commit -m "feat(security): add HttpOnly cookie flag and explicit session timeout"
```

---

### Task 8: Kiểm tra thủ công toàn bộ

- [ ] **Step 1: Build project**

```bash
mvn clean package -DskipTests
```

- [ ] **Step 2: Test CSRF — mở DevTools, thử POST không có _csrf**

Dùng `curl` hoặc Postman, gửi POST tới `/customer/dat-san` không có `_csrf` param:
```bash
curl -X POST http://localhost:8080/vsport/customer/dat-san -d "sanId=1" -v
```
Expected: HTTP 403 Forbidden

- [ ] **Step 3: Test rate limit — gửi 6 POST liên tiếp**

```bash
for i in {1..6}; do curl -s -o /dev/null -w "%{http_code}\n" -X POST http://localhost:8080/vsport/customer/dat-san -d "_csrf=fake"; done
```
Expected: 5 lần đầu 403 (no CSRF), lần thứ 6 trở đi: 429

- [ ] **Step 4: Test auto-lock — tài khoản điểm < 20**

Trong DB, set `DiemUyTin = 10` cho một tài khoản test, thử đặt sân:
```sql
UPDATE Accounts SET DiemUyTin = 10 WHERE MaTaiKhoan = <test_id>
```
Expected: Nhận thông báo lỗi "Tài khoản bị hạn chế..."

- [ ] **Step 5: Test cookie flags**

Mở DevTools > Application > Cookies, kiểm tra JSESSIONID có flag `HttpOnly` = true.

- [ ] **Step 6: Final commit**

```bash
git add .
git commit -m "test(security): manual verification complete"
```
