<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ page import="org.example.model.TaiKhoan" %>
        <%
            String vsNavPath = request.getRequestURI().substring(request.getContextPath().length());
            boolean vsNavBanDo = vsNavPath.startsWith("/customer/BanDo.jsp") || vsNavPath.startsWith("/customer/ban-do");
            boolean vsNavDatSan = vsNavPath.startsWith("/customer/dat-san") || vsNavPath.startsWith("/customer/tim-kiem");
            boolean vsNavGhepKeo = vsNavPath.startsWith("/customer/ghep-keo");
            boolean vsNavDichVu = vsNavPath.startsWith("/customer/dich-vu");
        %>
        <header class="header">
            <div class="top-header">
                <div class="container">
                    <div class="header-main">
                        <button type="button" class="mobile-menu-btn" id="vsMobileMenuBtn" aria-label="Mở menu điều hướng" aria-expanded="false" aria-controls="vsMobileNavDrawer">
                            <i class="fas fa-bars"></i>
                        </button>

                        <a href="${pageContext.request.contextPath}/" class="logo">
                            <i class="fa-solid fa-basket-shopping"></i>
                            V-<span>SPORT</span>
                        </a>

                        <div class="search-bar">
                            <form action="${pageContext.request.contextPath}/customer/tim-kiem" method="GET">
                                <input type="text" name="q" placeholder="Tìm tên sân, cơ sở, địa chỉ..." value="${not empty query ? query : ''}">
                                <button type="submit"><i class="fas fa-search"></i></button>
                            </form>
                        </div>

                        <button type="button" class="mobile-search-btn" id="vsMobileSearchBtn" aria-label="Mở tìm kiếm">
                            <i class="fas fa-search"></i>
                        </button>

                        <div class="header-actions">
                            <div class="call-center">
                                <div class="call-icon">
                                    <i class="fas fa-phone-alt"></i>
                                </div>
                                <div class="call-text">
                                    <span>Call Center</span>
                                    <strong>818-555 67 88</strong>
                                </div>
                            </div>

                            <div class="action-icons">
                                <a href="${pageContext.request.contextPath}/customer/gio-hang" class="icon-btn">
                                    <i class="fas fa-shopping-basket"></i>
                                    <span class="badge" id="header-cart-badge" style="opacity: 0; transition: opacity 0.2s;">0</span>
                                </a>
                                <a href="#" class="icon-btn">
                                    <i class="far fa-heart"></i>
                                    <span class="badge">0</span>
                                </a>
                                <% TaiKhoan user=(TaiKhoan) session.getAttribute("user"); if (user !=null) { %>
                                    <a href="${pageContext.request.contextPath}/customer/tai-khoan" class="icon-btn"
                                        style="width: auto; padding: 0 15px; gap: 8px; border-radius: 20px;">
                                        <i class="far fa-user"></i>
                                        <span style="font-size: 14px; font-weight: 600;">
                                            <%= user.getFullName() %>
                                        </span>
                                    </a>
                                    <% } else {
                                        // Bấm icon tài khoản là hành động CHỦ ĐỘNG của người dùng, không phải bị
                                        // chặn do thao tác cần đăng nhập — vì vậy dẫn thẳng tới trang chủ mở modal
                                        // login (auth=login) mà KHÔNG gắn notice=loginRequired, tránh hiện nhầm
                                        // banner "Vui lòng đăng nhập để tiếp tục thao tác này" trong trường hợp này.
                                        String currentPath = request.getRequestURI()
                                                + (request.getQueryString() != null ? "?" + request.getQueryString() : "");
                                        boolean isHomePage = request.getRequestURI().equals(request.getContextPath() + "/index.jsp")
                                                || request.getRequestURI().equals(request.getContextPath() + "/");
                                        String authHref = isHomePage
                                                ? "#auth"
                                                : request.getContextPath() + "/index.jsp?auth=login&redirect="
                                                    + java.net.URLEncoder.encode(currentPath, java.nio.charset.StandardCharsets.UTF_8);
                                    %>
                                        <a href="<%= authHref %>" class="icon-btn" id="authBtn">
                                            <i class="far fa-user"></i>
                                        </a>
                                        <% } %>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Navigation (desktop/tablet inline nav; hidden < 992px, replaced by drawer) -->
            <div class="bottom-header">
                <div class="container">
                    <div class="nav-inner">
                        <nav class="main-nav">
                            <ul>
                                <li><a href="${pageContext.request.contextPath}/customer/BanDo.jsp" class="nav-category<%= vsNavBanDo ? " nav-active" : "" %>" style="gap: 8px;"><i class="fas fa-map-marked-alt"></i>Bản đồ</a></li>
                                <li><a href="${pageContext.request.contextPath}/customer/dat-san" class="<%= vsNavDatSan ? "nav-active" : "" %>">Đặt sân</a></li>
                                <li><a href="${pageContext.request.contextPath}/customer/ghep-keo" class="<%= vsNavGhepKeo ? "nav-active" : "" %>">Ghép Kèo<span class="hot-badge">HOT</span></a></li>
                                <li><a href="${pageContext.request.contextPath}/customer/dich-vu" class="<%= vsNavDichVu ? "nav-active" : "" %>">Cửa hàng &amp; Dịch vụ</a></li>
                                <li><a href="#">Tin tức <i class="fas fa-angle-down"></i></a></li>
                            </ul>
                        </nav>
                    </div>
                </div>
            </div>
        </header>

        <!-- Mobile search overlay (search bar hidden < 992px, opened via icon) -->
        <div class="mobile-search-overlay" id="vsMobileSearchOverlay">
            <div class="mobile-search-overlay-inner">
                <form action="${pageContext.request.contextPath}/customer/tim-kiem" method="GET" class="mobile-search-form">
                    <input type="text" name="q" placeholder="Tìm tên sân, cơ sở, địa chỉ..." value="${not empty query ? query : ''}" autofocus>
                    <button type="submit"><i class="fas fa-search"></i></button>
                </form>
                <button type="button" class="mobile-search-close" id="vsMobileSearchClose" aria-label="Đóng tìm kiếm"><i class="fas fa-times"></i></button>
            </div>
        </div>

        <!-- Mobile nav drawer -->
        <div class="mobile-nav-overlay" id="vsMobileNavOverlay"></div>
        <nav class="mobile-nav-drawer" id="vsMobileNavDrawer" aria-label="Menu điều hướng di động" aria-hidden="true">
            <div class="mobile-nav-drawer-head">
                <a href="${pageContext.request.contextPath}/" class="logo">
                    <i class="fa-solid fa-basket-shopping"></i>
                    V-<span>SPORT</span>
                </a>
                <button type="button" class="mobile-nav-close" id="vsMobileNavClose" aria-label="Đóng menu"><i class="fas fa-times"></i></button>
            </div>
            <ul class="mobile-nav-links">
                <li><a href="${pageContext.request.contextPath}/"><i class="fas fa-home"></i>Trang chủ</a></li>
                <li><a href="${pageContext.request.contextPath}/customer/BanDo.jsp" class="<%= vsNavBanDo ? "is-active" : "" %>"><i class="fas fa-map-marked-alt"></i>Bản đồ</a></li>
                <li><a href="${pageContext.request.contextPath}/customer/dat-san" class="<%= vsNavDatSan ? "is-active" : "" %>"><i class="fas fa-calendar-check"></i>Đặt sân</a></li>
                <li><a href="${pageContext.request.contextPath}/customer/ghep-keo" class="<%= vsNavGhepKeo ? "is-active" : "" %>"><i class="fas fa-users"></i>Ghép Kèo<span class="hot-badge">HOT</span></a></li>
                <li><a href="${pageContext.request.contextPath}/customer/dich-vu" class="<%= vsNavDichVu ? "is-active" : "" %>"><i class="fas fa-store"></i>Cửa hàng &amp; Dịch vụ</a></li>
                <li><a href="#"><i class="fas fa-newspaper"></i>Tin tức</a></li>
                <% if (user != null) { %>
                <li><a href="${pageContext.request.contextPath}/customer/tai-khoan"><i class="fas fa-user"></i>Tài khoản</a></li>
                <li><a href="${pageContext.request.contextPath}/logout"><i class="fas fa-sign-out-alt"></i>Đăng xuất</a></li>
                <% } else { %>
                <li><a href="#auth" id="vsMobileAuthBtn"><i class="fas fa-user"></i>Đăng nhập / Đăng ký</a></li>
                <% } %>
            </ul>
        </nav>

        <script>
            document.addEventListener("DOMContentLoaded", function() {
                fetch('${pageContext.request.contextPath}/customer/api/cart-count')
                    .then(response => response.json())
                    .then(data => {
                        if (data && data.count !== undefined) {
                            const badge = document.getElementById('header-cart-badge');
                            if (badge) {
                                badge.textContent = data.count;
                                badge.style.opacity = '1';
                            }
                        }
                    })
                    .catch(e => console.error("Error loading cart count", e));

                // ---- Mobile nav drawer ----
                var menuBtn = document.getElementById('vsMobileMenuBtn');
                var drawer = document.getElementById('vsMobileNavDrawer');
                var overlay = document.getElementById('vsMobileNavOverlay');
                var closeBtn = document.getElementById('vsMobileNavClose');
                var lastFocusedEl = null;

                function openDrawer() {
                    lastFocusedEl = document.activeElement;
                    drawer.classList.add('is-open');
                    overlay.classList.add('is-open');
                    drawer.setAttribute('aria-hidden', 'false');
                    menuBtn.setAttribute('aria-expanded', 'true');
                    document.body.classList.add('vs-scroll-locked');
                    if (closeBtn) closeBtn.focus();
                }
                function closeDrawer() {
                    drawer.classList.remove('is-open');
                    overlay.classList.remove('is-open');
                    drawer.setAttribute('aria-hidden', 'true');
                    menuBtn.setAttribute('aria-expanded', 'false');
                    document.body.classList.remove('vs-scroll-locked');
                    if (lastFocusedEl && lastFocusedEl.focus) lastFocusedEl.focus();
                }
                if (menuBtn && drawer && overlay) {
                    menuBtn.addEventListener('click', openDrawer);
                    overlay.addEventListener('click', closeDrawer);
                    if (closeBtn) closeBtn.addEventListener('click', closeDrawer);
                    document.addEventListener('keydown', function (e) {
                        if (e.key === 'Escape' && drawer.classList.contains('is-open')) closeDrawer();
                    });
                    // Focus trap
                    drawer.addEventListener('keydown', function (e) {
                        if (e.key !== 'Tab') return;
                        var focusables = drawer.querySelectorAll('a[href], button:not([disabled])');
                        if (!focusables.length) return;
                        var first = focusables[0], last = focusables[focusables.length - 1];
                        if (e.shiftKey && document.activeElement === first) { e.preventDefault(); last.focus(); }
                        else if (!e.shiftKey && document.activeElement === last) { e.preventDefault(); first.focus(); }
                    });
                }

                // ---- Mobile search overlay ----
                var searchBtn = document.getElementById('vsMobileSearchBtn');
                var searchOverlay = document.getElementById('vsMobileSearchOverlay');
                var searchClose = document.getElementById('vsMobileSearchClose');
                if (searchBtn && searchOverlay) {
                    searchBtn.addEventListener('click', function () {
                        searchOverlay.classList.add('is-open');
                        document.body.classList.add('vs-scroll-locked');
                        var input = searchOverlay.querySelector('input[name="q"]');
                        if (input) input.focus();
                    });
                    function closeSearch() {
                        searchOverlay.classList.remove('is-open');
                        document.body.classList.remove('vs-scroll-locked');
                    }
                    if (searchClose) searchClose.addEventListener('click', closeSearch);
                    document.addEventListener('keydown', function (e) {
                        if (e.key === 'Escape' && searchOverlay.classList.contains('is-open')) closeSearch();
                    });
                }
            });
        </script>