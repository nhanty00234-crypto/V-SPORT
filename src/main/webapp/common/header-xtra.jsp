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
                            <i class="fa-solid fa-volleyball"></i>
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
                                    <%-- Nút thông báo ghép kèo --%>
                                    <div class="vs-notif-wrap" id="vsNotifWrap">
                                        <button type="button" class="icon-btn vs-notif-btn" id="vsNotifBtn" aria-label="Thông báo" aria-expanded="false" aria-controls="vsNotifDropdown">
                                            <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9"/><path d="M10.3 21a1.94 1.94 0 0 0 3.4 0"/></svg>
                                        </button>
                                        <span class="vs-notif-badge" id="vsNotifBadge" style="opacity:0;transition:opacity .2s;">0</span>
                                        <div class="vs-notif-dropdown" id="vsNotifDropdown" role="dialog" aria-label="Thông báo ghép kèo" hidden>
                                            <div class="vs-notif-head">
                                                <span class="vs-notif-head-title">Thông báo</span>
                                                <button type="button" class="vs-notif-clear" id="vsNotifClear" title="Đánh dấu tất cả đã đọc">Đọc tất cả</button>
                                            </div>
                                            <ul class="vs-notif-list" id="vsNotifList" role="list">
                                                <li class="vs-notif-empty" id="vsNotifEmpty">Chưa có thông báo mới</li>
                                            </ul>
                                            <div class="vs-notif-foot">
                                                <a href="${pageContext.request.contextPath}/customer/thong-bao" class="vs-notif-foot-link">Xem tất cả thông báo</a>
                                            </div>
                                        </div>
                                    </div>
                                    <a href="${pageContext.request.contextPath}/customer/tai-khoan" class="icon-btn"
                                        style="width: auto; padding: 0 15px; gap: 8px; border-radius: 20px;">
                                        <i class="far fa-user"></i>
                                        <span style="font-size: 14px; font-weight: 600;">
                                            <%= user.getFullName() %>
                                        </span>
                                    </a>
                                    <a href="${pageContext.request.contextPath}/logout" class="icon-btn" title="Đăng xuất" aria-label="Đăng xuất">
                                        <i class="fas fa-sign-out-alt"></i>
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
                    <i class="fa-solid fa-volleyball"></i>
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

        <style>
            /* ---- Notification bell (header-xtra) ---- */
            .vs-notif-wrap {
                position: relative;
                display: inline-flex;
                align-items: center;
                overflow: visible !important;
            }
            .vs-notif-btn {
                position: relative;
                /* Reset browser button defaults */
                border: none !important;
                outline: none !important;
                background: rgba(255, 255, 255, 0.05) !important;
                box-shadow: none !important;
                cursor: pointer;
                /* Inherit icon-btn layout */
                color: var(--surface, #fff);
                font-size: 20px;
                width: 44px;
                height: 44px;
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                padding: 0;
                transition: background 0.2s;
                overflow: visible !important;
            }
            .vs-notif-btn:hover { background: rgba(255, 255, 255, 0.15) !important; }
            .vs-notif-btn:focus { outline: none !important; box-shadow: none !important; }
            .vs-notif-badge {
                position: absolute !important;
                top: -2px !important;
                right: -2px !important;
                z-index: 10 !important;
                min-width: 18px !important;
                height: 18px !important;
                padding: 0 5px !important;
                border-radius: 999px !important;
                background: #E5484D !important;
                color: #fff !important;
                font-size: 10px !important;
                font-weight: 800 !important;
                display: inline-flex !important;
                align-items: center !important;
                justify-content: center !important;
                pointer-events: none !important;
                line-height: 1 !important;
                box-shadow: 0 0 0 2px #122d40 !important;
                white-space: nowrap !important;
            }
            .vs-notif-dropdown {
                position: absolute;
                top: calc(100% + 10px);
                right: 0;
                z-index: 2000;
                width: 360px;
                max-width: min(360px, calc(100vw - 24px));
                max-height: calc(100vh - 100px);
                background: #fff;
                border-radius: 16px;
                box-shadow: 0 12px 40px rgba(7,26,47,.18), 0 2px 8px rgba(7,26,47,.10);
                border: 1px solid #DCE5EF;
                display: flex;
                flex-direction: column;
                overflow: hidden;
                animation: vsNotifFadeIn .18s ease;
            }
            .vs-notif-dropdown[hidden] {
                display: none !important;
            }
            @keyframes vsNotifFadeIn {
                from { opacity: 0; transform: translateY(-8px) scale(.97); }
                to   { opacity: 1; transform: translateY(0) scale(1); }
            }
            .vs-notif-head {
                display: flex;
                align-items: center;
                justify-content: space-between;
                padding: 14px 16px 10px;
                border-bottom: 1px solid #EEF2F6;
                flex-shrink: 0;
                background: #fff;
            }
            .vs-notif-head-title {
                font-size: 14px;
                font-weight: 800;
                color: #122d40;
            }
            .vs-notif-clear {
                background: none;
                border: none;
                font-size: 12px;
                font-weight: 700;
                color: #01c771;
                cursor: pointer;
                padding: 4px 8px;
                border-radius: 6px;
                transition: background .12s;
            }
            .vs-notif-clear:hover { background: #EFFDF6; }
            .vs-notif-list {
                list-style: none;
                margin: 0;
                padding: 0;
                max-height: 380px;
                overflow-y: auto;
                flex: 1;
            }
            .vs-notif-foot {
                padding: 10px 16px;
                border-top: 1px solid #EEF2F6;
                text-align: center;
                background: #FAFCFE;
                flex-shrink: 0;
            }
            .vs-notif-foot-link {
                font-size: 12.5px;
                font-weight: 700;
                color: #01c771;
                text-decoration: none;
            }
            .vs-notif-foot-link:hover { text-decoration: underline; }
            .vs-notif-empty {
                padding: 28px 16px;
                text-align: center;
                font-size: 13px;
                color: #829AB1;
            }
            .vs-notif-item {
                display: flex;
                align-items: flex-start;
                gap: 11px;
                padding: 12px 16px;
                border-bottom: 1px solid #F1F5F9;
                cursor: default;
                transition: background .12s;
                position: relative;
            }
            .vs-notif-item:last-child { border-bottom: none; }
            .vs-notif-item:hover { background: #F8FAFB; }
            .vs-notif-item.is-unread { background: #F0FDF8; }
            .vs-notif-item.is-unread:hover { background: #E4FAF2; }
            .vs-notif-item.is-unread::before {
                content: '';
                position: absolute;
                left: 0; top: 0; bottom: 0;
                width: 3px;
                background: #01e281;
                border-radius: 0 2px 2px 0;
            }
            .vs-notif-avatar {
                width: 36px; height: 36px; flex-shrink: 0;
                border-radius: 50%;
                background: linear-gradient(135deg, #01c771, #01e281);
                color: #fff;
                display: inline-flex; align-items: center; justify-content: center;
                font-size: 12px; font-weight: 800;
            }
            .vs-notif-body { min-width: 0; flex: 1; }
            .vs-notif-text {
                font-size: 13px;
                font-weight: 600;
                color: #102A43;
                line-height: 1.45;
                margin: 0 0 3px;
            }
            .vs-notif-text strong { color: #01c771; }
            .vs-notif-time {
                font-size: 11.5px;
                color: #829AB1;
                font-weight: 600;
            }
            .vs-notif-view {
                display: inline-flex;
                align-items: center;
                gap: 4px;
                font-size: 11.5px;
                font-weight: 700;
                color: #01c771;
                background: none;
                border: none;
                cursor: pointer;
                padding: 2px 0;
                text-decoration: none;
                margin-top: 4px;
            }
            .vs-notif-view:hover { text-decoration: underline; }
            @media (max-width: 480px) {
                .vs-notif-dropdown {
                    right: -60px;
                    width: calc(100vw - 20px);
                }
            }
        </style>
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

            /* ==================== Notification bell logic ==================== */
            (function () {
                var btn = document.getElementById('vsNotifBtn');
                var dropdown = document.getElementById('vsNotifDropdown');
                var badge = document.getElementById('vsNotifBadge');
                var list = document.getElementById('vsNotifList');
                var clearBtn = document.getElementById('vsNotifClear');
                var ctx = '${pageContext.request.contextPath}';

                if (!btn || !dropdown) return;

                var ghepKeoItems = [];   // {rawId, tenNguoiChoi, trangThai, thoiGian (ISO), isUnread}
                var thongBaoItems = [];  // {id, tieuDe, noiDung, daDoc, duongDan, thoiGian (ms), loai}
                var serverUnreadCount = 0; // tổng số thông báo chưa đọc từ DB
                var lastSeenId = parseInt(localStorage.getItem('vsNotifLastSeenId') || '0', 10) || 0;
                var isOpen = false;

                function getInitials(name) {
                    if (!name) return '?';
                    return name.trim().split(/\s+/).map(function(p){return p[0];}).slice(-2).join('').toUpperCase();
                }

                function relativeTime(input) {
                    var ms = (typeof input === 'number') ? input : new Date(input).getTime();
                    if (!ms) return '';
                    var diff = Math.floor((Date.now() - ms) / 1000);
                    if (diff < 60) return 'Vừa xong';
                    if (diff < 3600) return Math.floor(diff/60) + ' phút trước';
                    if (diff < 86400) return Math.floor(diff/3600) + ' giờ trước';
                    return Math.floor(diff/86400) + ' ngày trước';
                }

                function iconBgForLoai(loai) {
                    if (!loai) return 'background:#EEF2F6;color:#64748B';
                    if (loai.indexOf('HOAN_TIEN') >= 0) return 'background:#FFF0F0;color:#E5484D';
                    if (loai.indexOf('THANH_TOAN') >= 0) return 'background:#FFFBEB;color:#D97706';
                    if (loai.indexOf('DAT_SAN') >= 0 || loai.indexOf('GIU_CHO') >= 0) return 'background:#F0FDF8;color:#01c771';
                    return 'background:#EEF2F6;color:#64748B';
                }

                function iconForLoai(loai) {
                    if (!loai) return '🔔';
                    if (loai.indexOf('HOAN_TIEN') >= 0) return '↩';
                    if (loai.indexOf('THANH_TOAN') >= 0) return '💳';
                    if (loai.indexOf('DAT_SAN') >= 0 || loai.indexOf('GIU_CHO') >= 0) return '📅';
                    return '🔔';
                }

                function renderNotifications() {
                    list.innerHTML = '';
                    var all = [];

                    thongBaoItems.forEach(function(n) {
                        all.push({ sortTime: n.thoiGian, isUnread: !n.daDoc,
                            render: function() {
                                var li = document.createElement('li');
                                li.className = 'vs-notif-item' + (!n.daDoc ? ' is-unread' : '');
                                li.innerHTML =
                                    '<div class="vs-notif-avatar" style="font-size:16px;' + iconBgForLoai(n.loai) + '">' + iconForLoai(n.loai) + '</div>'
                                  + '<div class="vs-notif-body">'
                                  +   '<p class="vs-notif-text"><strong>' + (n.tieuDe || '') + '</strong>'
                                  +   (n.noiDung ? '<br><span style="font-weight:500;font-size:12px;color:#486581;">' + n.noiDung + '</span>' : '') + '</p>'
                                  +   '<span class="vs-notif-time">' + relativeTime(n.thoiGian) + '</span>'
                                  + '</div>';
                                if (n.duongDan) {
                                    li.style.cursor = 'pointer';
                                    li.addEventListener('click', function() {
                                        if (!n.daDoc) {
                                            n.daDoc = true;
                                            fetch(ctx + '/customer/thong-bao', {
                                                method: 'POST',
                                                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                                                body: 'action=markRead&id=' + n.id
                                            }).catch(function(){});
                                            updateBadge();
                                        }
                                        window.location.href = ctx + n.duongDan;
                                    });
                                }
                                return li;
                            }
                        });
                    });

                    ghepKeoItems.forEach(function(n) {
                        all.push({ sortTime: new Date(n.thoiGian).getTime(), isUnread: n.isUnread,
                            render: function() {
                                var li = document.createElement('li');
                                li.className = 'vs-notif-item' + (n.isUnread ? ' is-unread' : '');
                                var actionText = (n.trangThai === 'Đã rời') ? 'đã rời khỏi kèo của bạn' : 'đã tham gia kèo của bạn';
                                li.innerHTML =
                                    '<div class="vs-notif-avatar">' + getInitials(n.tenNguoiChoi) + '</div>'
                                  + '<div class="vs-notif-body">'
                                  +   '<p class="vs-notif-text"><strong>' + (n.tenNguoiChoi || 'Người dùng') + '</strong> ' + actionText + '</p>'
                                  +   '<span class="vs-notif-time">' + relativeTime(n.thoiGian) + '</span>'
                                  + '</div>';
                                return li;
                            }
                        });
                    });

                    if (!all.length) {
                        var li = document.createElement('li');
                        li.className = 'vs-notif-empty';
                        li.textContent = 'Chưa có thông báo mới';
                        list.appendChild(li);
                        return;
                    }
                    all.sort(function(a, b) { return b.sortTime - a.sortTime; });
                    all.slice(0, 10).forEach(function(item) { list.appendChild(item.render()); });
                }

                function updateBadge() {
                    var keoUnread = ghepKeoItems.filter(function(n){ return n.isUnread; }).length;
                    var total = serverUnreadCount + keoUnread;
                    if (total > 0) {
                        badge.textContent = total > 99 ? '99+' : total;
                        badge.style.opacity = '1';
                        badge.style.display = 'inline-flex';
                    } else {
                        badge.style.opacity = '0';
                        badge.style.display = 'none';
                    }
                }

                function openDropdown() {
                    isOpen = true;
                    dropdown.hidden = false;
                    btn.setAttribute('aria-expanded', 'true');
                    renderNotifications();
                }
                function closeDropdown() {
                    isOpen = false;
                    dropdown.hidden = true;
                    btn.setAttribute('aria-expanded', 'false');
                }

                btn.addEventListener('click', function(e) {
                    e.stopPropagation();
                    if (isOpen) closeDropdown(); else openDropdown();
                });
                document.addEventListener('click', function(e) {
                    var wrap = document.getElementById('vsNotifWrap');
                    if (isOpen && wrap && !wrap.contains(e.target)) closeDropdown();
                });
                document.addEventListener('keydown', function(e) {
                    if (e.key === 'Escape' && isOpen) closeDropdown();
                });

                if (clearBtn) {
                    clearBtn.addEventListener('click', function() {
                        var maxId = ghepKeoItems.reduce(function(max, n){ return Math.max(max, n.rawId || 0); }, lastSeenId);
                        localStorage.setItem('vsNotifLastSeenId', String(maxId));
                        lastSeenId = maxId;
                        ghepKeoItems.forEach(function(n){ n.isUnread = false; });
                        serverUnreadCount = 0;
                        fetch(ctx + '/customer/thong-bao', {
                            method: 'POST',
                            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                            body: 'action=markAllRead'
                        }).then(function() {
                            thongBaoItems.forEach(function(n){ n.daDoc = true; });
                            updateBadge(); renderNotifications();
                        }).catch(function() {
                            thongBaoItems.forEach(function(n){ n.daDoc = true; });
                            updateBadge(); renderNotifications();
                        });
                    });
                }

                function fetchNotifications() {
                    var p1 = fetch(ctx + '/customer/api/matches/notifications', { headers: { 'Accept': 'application/json' } })
                        .then(function(r) { return r.json(); })
                        .then(function(data) {
                            if (!data.success) return;
                            var items = data.notifications || [];
                            var seenId = parseInt(localStorage.getItem('vsNotifLastSeenId') || '0', 10) || 0;
                            var maxId = items.reduce(function(mx, n){ return Math.max(mx, n.id || 0); }, 0);
                            if (localStorage.getItem('vsNotifLastSeenId') === null && maxId > 0) {
                                localStorage.setItem('vsNotifLastSeenId', String(maxId));
                                seenId = maxId;
                            }
                            lastSeenId = seenId;
                            ghepKeoItems = items.map(function(n) {
                                return { rawId: n.id, tenNguoiChoi: n.tenNguoiChoi,
                                         keoId: n.keoId, trangThai: n.trangThai,
                                         thoiGian: n.thoiGian, isUnread: n.id > seenId };
                            });
                        })
                        .catch(function(){});

                    var p2 = fetch(ctx + '/customer/thong-bao?format=json&limit=8', { headers: { 'Accept': 'application/json' } })
                        .then(function(r) { return r.json(); })
                        .then(function(data) {
                            serverUnreadCount = data.unread || 0;
                            thongBaoItems = (data.items || []).map(function(n) {
                                return { id: n.id, tieuDe: n.tieuDe, noiDung: n.noiDung,
                                         daDoc: n.daDoc, duongDan: n.duongDan,
                                         thoiGian: n.thoiGian, loai: n.loai };
                            });
                        })
                        .catch(function(){});

                    Promise.all([p1, p2]).then(function() {
                        updateBadge();
                        if (isOpen) renderNotifications();
                    });
                }

                fetchNotifications();
                setInterval(fetchNotifications, 30000);

                window.vsRefreshNotifications = fetchNotifications;
            })();
        </script>