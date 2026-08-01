<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:wght@600;700&family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">

<style>
    :root {
        --primary: #3DD68C;
        --primary-hover: #2ec47d;
        --header-bg: #0F1B2D;
        --header-bg-nav: #0a1525;
        --header-border: rgba(255,255,255,0.07);
        --header-text: #ffffff;
        --header-muted: rgba(255,255,255,0.55);
        --transition: all 0.25s ease;
    }

    /* ── WRAPPER ── */
    .site-header {
        position: sticky;
        top: 0;
        z-index: 200;
        background: var(--header-bg);
        box-shadow: 0 2px 20px rgba(0,0,0,0.4);
    }
    .site-header * { box-sizing: border-box; }

    /* ── TOP ROW ── */
    .navbar-top {
        display: flex;
        align-items: center;
        gap: 18px;
        padding: 0 32px;
        height: 64px;
        border-bottom: 1px solid var(--header-border);
    }

    /* Logo */
    .logo-container {
        text-decoration: none;
        display: flex;
        align-items: center;
        gap: 10px;
        flex-shrink: 0;
        transition: opacity 0.2s;
    }
    .logo-container:hover { opacity: 0.85; }
    .logo-img {
        height: 36px; width: 36px;
        object-fit: cover; border-radius: 8px;
    }
    .logo-text {
        font-family: 'Poppins', sans-serif;
        font-weight: 700; font-size: 22px;
        text-transform: uppercase; letter-spacing: -0.5px;
        color: var(--header-text);
    }
    .logo-text span { color: var(--primary); }

    /* Search */
    .header-search {
        flex: 1; max-width: 520px; position: relative;
    }
    .header-search input {
        width: 100%; height: 42px;
        background: rgba(255,255,255,0.07);
        border: 1px solid rgba(255,255,255,0.11);
        border-radius: 9999px;
        color: var(--header-text);
        font-family: 'Poppins', sans-serif; font-size: 14px;
        padding: 0 44px 0 20px;
        outline: none;
        transition: border-color 0.2s, background 0.2s;
    }
    .header-search input::placeholder { color: var(--header-muted); }
    .header-search input:focus {
        border-color: var(--primary);
        background: rgba(255,255,255,0.11);
    }
    .header-search-icon {
        position: absolute; right: 16px; top: 50%;
        transform: translateY(-50%);
        color: var(--header-muted); pointer-events: none;
    }

    /* Call Center */
    .header-callcenter {
        display: flex; align-items: center; gap: 10px;
        flex-shrink: 0; margin-left: auto;
    }
    .callcenter-icon-wrap {
        width: 38px; height: 38px; border-radius: 50%;
        background: rgba(255,255,255,0.07);
        border: 1px solid rgba(255,255,255,0.11);
        display: flex; align-items: center; justify-content: center;
        color: var(--header-text); flex-shrink: 0;
    }
    .callcenter-label {
        font-family: 'Poppins', sans-serif;
        font-size: 11px; color: var(--header-muted); line-height: 1.3;
    }
    .callcenter-number {
        font-family: 'Poppins', sans-serif;
        font-size: 15px; font-weight: 700;
        color: var(--header-text); line-height: 1.3;
    }

    /* Icon buttons */
    .header-icons {
        display: flex; align-items: center; gap: 6px; flex-shrink: 0;
    }
    .header-icon-btn {
        display: flex; align-items: center; justify-content: center;
        width: 38px; height: 38px;
        color: var(--header-text);
        background: transparent; border: none;
        cursor: pointer;
        transition: background 0.2s, transform 0.15s;
        position: relative; padding: 0; border-radius: 50%;
        text-decoration: none;
    }
    .header-icon-btn:hover {
        background: rgba(255,255,255,0.1);
        transform: scale(1.05);
        color: var(--header-text);
    }
    .header-icon-btn:active { transform: scale(0.95); }
    .header-icon-badge {
        position: absolute; top: 2px; right: 2px;
        min-width: 16px; height: 16px;
        background: var(--primary);
        border-radius: 999px;
        border: 2px solid var(--header-bg);
        display: flex; align-items: center; justify-content: center;
        font-size: 9px; font-weight: 700;
        color: #111827; line-height: 1; padding: 0 3px;
    }

    /* User dropdown */
    .menu-grid-container { position: relative; }
    .menu-grid-dropdown {
        position: absolute; right: 0; top: calc(100% + 10px);
        width: 200px; background: #ffffff;
        box-shadow: 0 12px 32px rgba(0,0,0,0.18);
        border-radius: 10px; overflow: hidden;
        opacity: 0; visibility: hidden;
        transform: translateY(6px);
        transition: opacity 0.2s, visibility 0.2s, transform 0.2s;
        z-index: 1000; border: 1px solid #f0f0f0;
    }
    .menu-grid-dropdown.show {
        opacity: 1; visibility: visible; transform: translateY(0);
    }
    .menu-grid-header {
        padding: 10px 16px;
        background: #f9fafb; border-bottom: 1px solid #f0f0f0;
    }
    .menu-grid-header .title {
        font-size: 10px; color: #9ca3af; margin: 0;
        text-transform: uppercase; font-weight: 600; letter-spacing: 0.06em;
    }
    .menu-grid-header .name {
        font-size: 13px; font-weight: 700; color: #111827;
        margin: 2px 0 0 0;
        white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
    }
    .menu-grid-item {
        display: block; padding: 10px 16px;
        font-size: 13px; font-weight: 500; color: #374151;
        text-decoration: none; transition: background 0.15s;
    }
    .menu-grid-item:hover { background: #f3f4f6; color: #111827; }
    .menu-grid-item.logout { color: #dc2626; border-top: 1px solid #f0f0f0; }
    .menu-grid-item.logout:hover { background: #fef2f2; }

    /* ── BOTTOM NAV ── */
    .navbar-bottom {
        display: flex; align-items: center;
        padding: 0 32px; height: 48px; gap: 4px;
        background: var(--header-bg-nav);
    }
    .nav-links {
        list-style: none; display: flex; gap: 2px;
        margin: 0; padding: 0; align-items: center;
    }
    .nav-links a {
        text-decoration: none; color: var(--header-muted);
        font-family: 'Poppins', sans-serif;
        font-size: 14px; font-weight: 500;
        padding: 6px 14px; border-radius: 9999px;
        transition: color 0.2s, background 0.2s;
        display: inline-flex; align-items: center; gap: 6px;
        white-space: nowrap;
    }
    .nav-links a:hover { color: var(--header-text); background: rgba(255,255,255,0.08); }
    .nav-links a.active { color: var(--header-text); background: rgba(255,255,255,0.1); font-weight: 600; }

    /* Bản đồ pill */
    .nav-pill-map {
        background: var(--primary) !important;
        color: #111827 !important; font-weight: 700 !important;
        padding: 6px 16px !important;
    }
    .nav-pill-map:hover { background: var(--primary-hover) !important; color: #111827 !important; }

    /* HOT badge */
    .nav-hot-badge {
        display: inline-flex; align-items: center; justify-content: center;
        background: #ef4444; color: #fff;
        font-size: 9px; font-weight: 800;
        border-radius: 4px; padding: 1px 5px;
        letter-spacing: 0.06em; line-height: 1.4;
    }

    /* Tin tức dropdown */
    .nav-dropdown-wrap { position: relative; }
    .nav-dropdown-menu {
        position: absolute; top: calc(100% + 8px); left: 0;
        min-width: 180px; background: #ffffff;
        border-radius: 10px; box-shadow: 0 12px 32px rgba(0,0,0,0.18);
        overflow: hidden; opacity: 0; visibility: hidden;
        transform: translateY(6px);
        transition: opacity 0.2s, visibility 0.2s, transform 0.2s;
        z-index: 500; border: 1px solid #f0f0f0;
    }
    .nav-dropdown-wrap:hover .nav-dropdown-menu {
        opacity: 1; visibility: visible; transform: translateY(0);
    }
    .nav-dropdown-item {
        display: block; padding: 10px 16px;
        font-size: 13px; font-weight: 500; color: #374151;
        text-decoration: none; transition: background 0.15s;
    }
    .nav-dropdown-item:hover { background: #f3f4f6; color: #111827; }

    /* Animations */
    .fade-down { animation: fadeDown 0.55s cubic-bezier(0.1, 0.8, 0.2, 1); }
    @keyframes fadeDown {
        from { opacity: 0; transform: translateY(-20px); }
        to   { opacity: 1; transform: translateY(0); }
    }

    /* Mobile */
    .mobile-menu-btn {
        display: none; background: none; border: none;
        cursor: pointer; padding: 8px;
        color: var(--header-text); font-size: 1.3rem; line-height: 1;
        border-radius: 6px; transition: background 0.2s;
    }
    .mobile-menu-btn:hover { background: rgba(255,255,255,0.1); }
    .mobile-nav {
        display: none; position: fixed;
        top: 112px; left: 0; right: 0;
        background: var(--header-bg-nav);
        z-index: 199;
        box-shadow: 0 8px 24px rgba(0,0,0,0.3);
        flex-direction: column;
        padding: 10px 16px 14px; gap: 2px;
        border-top: 1px solid var(--header-border);
    }
    .mobile-nav.open { display: flex; }
    .mobile-nav-link {
        display: flex; align-items: center;
        padding: 11px 14px; border-radius: 10px;
        color: var(--header-muted); text-decoration: none;
        font-size: 0.95rem; font-weight: 500;
        transition: background 0.2s, color 0.2s;
    }
    .mobile-nav-link:hover, .mobile-nav-link.active {
        background: rgba(255,255,255,0.08); color: var(--header-text);
    }

    /* Side Drawer */
    .side-drawer {
        position: fixed; top: 0; left: 0;
        width: 100vw; height: 100vh;
        z-index: 9999; visibility: hidden;
        transition: visibility 0.3s ease;
    }
    .side-drawer.open { visibility: visible; }
    .side-drawer-overlay {
        position: absolute; top: 0; left: 0;
        width: 100%; height: 100%;
        background: rgba(0,0,0,0.5); opacity: 0;
        transition: opacity 0.3s ease;
    }
    .side-drawer.open .side-drawer-overlay { opacity: 1; }
    .side-drawer-content {
        position: absolute; top: 0; right: -360px;
        width: 360px; height: 100%;
        background: #ffffff;
        box-shadow: -5px 0 25px rgba(0,0,0,0.2);
        display: flex; flex-direction: column;
        transition: right 0.3s ease;
        padding: 24px; box-sizing: border-box; overflow-y: auto;
    }
    .side-drawer.open .side-drawer-content { right: 0; }
    .side-drawer-header {
        display: flex; justify-content: space-between; align-items: center;
        border-bottom: 1px solid #f0f0f0;
        padding-bottom: 16px; margin-bottom: 24px;
    }
    .side-drawer-close {
        background: none; border: none; font-size: 28px;
        cursor: pointer; color: #999; transition: color 0.2s; line-height: 1;
    }
    .side-drawer-close:hover { color: #333; }
    .side-drawer-section { margin-bottom: 28px; }
    .section-title {
        font-family: 'Barlow Condensed', sans-serif;
        font-size: 13px; font-weight: 700; color: #9ca3af;
        letter-spacing: 0.1em; margin-bottom: 14px; margin-top: 0;
        text-transform: uppercase;
    }
    .user-section {
        background: #f9fafb; padding: 16px;
        border-radius: 10px; border: 1px solid #f0f0f0;
    }
    .drawer-user-info { display: flex; align-items: center; gap: 12px; margin-bottom: 14px; }
    .avatar-circle {
        width: 44px; height: 44px; border-radius: 50%;
        background: var(--primary); color: #111827;
        display: flex; align-items: center; justify-content: center;
        font-size: 18px; font-weight: 700;
    }
    .user-details { flex: 1; }
    .user-name { font-weight: 600; color: #111827; margin: 0; font-size: 15px; }
    .user-role { font-size: 12px; color: #9ca3af; margin: 0; }
    .drawer-user-actions { display: flex; flex-direction: column; gap: 6px; }
    .btn-drawer-action {
        display: flex; align-items: center; gap: 8px;
        color: #374151; text-decoration: none; font-size: 14px;
        padding: 8px 10px; border-radius: 6px;
        transition: background 0.2s, color 0.2s;
    }
    .btn-drawer-action:hover { background: #f3f4f6; color: #111827; }
    .drawer-guest-info { text-align: center; padding: 8px 0; }
    .guest-msg { font-size: 13px; color: #6b7280; margin-bottom: 14px; }
    .btn-drawer-login {
        background: #111827; color: #fff; border: none;
        padding: 10px 20px; border-radius: 6px; font-weight: 600;
        cursor: pointer; font-size: 13px; transition: background 0.2s; width: 100%;
    }
    .btn-drawer-login:hover { background: #000; }
    .drawer-link {
        display: flex; align-items: center; gap: 12px;
        color: #374151; text-decoration: none;
        font-size: 15px; font-weight: 600;
        padding: 10px 0; border-bottom: 1px solid #f9fafb;
        transition: color 0.2s, padding-left 0.2s;
    }
    .drawer-link:hover { color: var(--primary); padding-left: 6px; }
    .support-channels { display: flex; flex-direction: column; gap: 10px; }
    .channel-btn {
        display: flex; align-items: center; gap: 12px;
        text-decoration: none; color: #374151; font-weight: 600; font-size: 14px;
        padding: 12px; border-radius: 8px; border: 1px solid #e5e7eb;
        transition: all 0.2s;
    }
    .channel-btn:hover { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(0,0,0,0.07); }
    .zalo-btn { background: #f0f7ff; border-color: #bfdbfe; }
    .zalo-btn:hover { background: #dbeafe; }
    .messenger-btn { background: #fff0f8; border-color: #fbcfe8; }
    .messenger-btn:hover { background: #fce7f3; }
    .channel-icon { width: 24px; height: 24px; }
    .side-drawer-footer { margin-top: auto; border-top: 1px solid #f0f0f0; padding-top: 18px; }
    .contact-item { display: flex; flex-direction: column; margin-bottom: 10px; }
    .contact-item .label { font-size: 11px; color: #9ca3af; }
    .contact-item .value { font-size: 14px; font-weight: 700; color: #111827; }

    @media (max-width: 1023px) { .header-callcenter { display: none; } }
    @media (max-width: 768px) {
        .navbar-bottom { display: none; }
        .mobile-menu-btn { display: flex; align-items: center; justify-content: center; }
        .header-search { max-width: none; }
    }
</style>

<header class="site-header fade-down">
    <!-- TOP ROW -->
    <div class="navbar-top">
        <a href="${pageContext.request.contextPath}/index.jsp" class="logo-container">
            <img src="${pageContext.request.contextPath}/resources/logo.png" alt="V-SPORT Logo" class="logo-img" />
            <span class="logo-text">V- <span>SPORT</span></span>
        </a>

        <div class="header-search">
            <input type="text" placeholder="Tìm tên sân, cơ sở, địa chỉ..." id="header-search-input" />
            <span class="header-search-icon">
                <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2.2" viewBox="0 0 24 24">
                    <circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>
                </svg>
            </span>
        </div>

        <div class="header-callcenter">
            <div class="callcenter-icon-wrap">
                <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                    <path d="M22 16.92v3a2 2 0 01-2.18 2 19.79 19.79 0 01-8.63-3.07A19.5 19.5 0 013.07 9.8 19.79 19.79 0 01.07 1.18 2 2 0 012.04 0h3a2 2 0 012 1.72c.127.96.361 1.903.7 2.81a2 2 0 01-.45 2.11L6.09 7.91a16 16 0 006 6l1.27-1.27a2 2 0 012.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0122 16.92z"/>
                </svg>
            </div>
            <div>
                <div class="callcenter-label">Call Center</div>
                <div class="callcenter-number">818-555 67 88</div>
            </div>
        </div>

        <div class="header-icons">
            <!-- Cart -->
            <a href="${pageContext.request.contextPath}/customer/dat-san" class="header-icon-btn" title="Giỏ hàng">
                <svg width="22" height="22" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" viewBox="0 0 24 24">
                    <path d="M6 2L3 6v14a2 2 0 002 2h14a2 2 0 002-2V6l-3-4z"/>
                    <line x1="3" y1="6" x2="21" y2="6"/>
                    <path d="M16 10a4 4 0 01-8 0"/>
                </svg>
                <span class="header-icon-badge">0</span>
            </a>

            <!-- Wishlist -->
            <a href="${pageContext.request.contextPath}/customer/tai-khoan" class="header-icon-btn" title="Yêu thích">
                <svg width="22" height="22" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" viewBox="0 0 24 24">
                    <path d="M20.84 4.61a5.5 5.5 0 00-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 00-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 000-7.78z"/>
                </svg>
                <span class="header-icon-badge">0</span>
            </a>

            <!-- User -->
            <div class="menu-grid-container">
                <button id="header-user-btn" class="header-icon-btn"
                        onclick="handleUserClick(this)"
                        aria-haspopup="true" aria-expanded="false" aria-label="Tài khoản">
                    <svg width="22" height="22" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" viewBox="0 0 24 24">
                        <path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/>
                        <circle cx="12" cy="7" r="4"/>
                    </svg>
                </button>
                <c:if test="${user != null}">
                    <div id="user-profile-dropdown" class="menu-grid-dropdown">
                        <div class="menu-grid-header">
                            <p class="title">Tài khoản</p>
                            <p class="name">
                                <c:choose>
                                    <c:when test="${not empty user.fullName}">${fn:escapeXml(user.fullName)}</c:when>
                                    <c:otherwise>${fn:escapeXml(user.username)}</c:otherwise>
                                </c:choose>
                            </p>
                        </div>
                        <a href="${pageContext.request.contextPath}/customer/tai-khoan" class="menu-grid-item">Tài khoản</a>
                        <a href="${pageContext.request.contextPath}/customer/lich-su-dat-san" class="menu-grid-item">Lịch của tôi</a>
                        <a href="${pageContext.request.contextPath}/customer/ghep-keo" class="menu-grid-item">Ghép kèo</a>
                        <a href="${pageContext.request.contextPath}/logout" class="menu-grid-item logout">Đăng xuất</a>
                    </div>
                </c:if>
            </div>

            <!-- Mobile hamburger -->
            <button id="mobileNavBtn" class="mobile-menu-btn" aria-label="Mở menu">
                <i class="fa-solid fa-bars"></i>
            </button>
        </div>
    </div>

    <!-- BOTTOM NAV ROW -->
    <nav class="navbar-bottom">
        <ul class="nav-links">
            <li>
                <a href="${pageContext.request.contextPath}/customer/ban-do" id="nav-map" class="nav-pill-map">
                    <svg width="13" height="13" fill="currentColor" viewBox="0 0 24 24">
                        <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z"/>
                    </svg>
                    Bản đồ
                </a>
            </li>
            <li><a href="${pageContext.request.contextPath}/customer/dat-san" id="nav-booking">Đặt sân</a></li>
            <li>
                <a href="${pageContext.request.contextPath}/customer/uu-dai" id="nav-uudai">
                    <svg width="13" height="13" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                        <rect x="1" y="4" width="22" height="16" rx="2" ry="2"/>
                        <line x1="1" y1="10" x2="23" y2="10"/>
                    </svg>
                    Ưu đãi
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/customer/ghep-keo" id="nav-ghepkeo">
                    Ghép Kèo&nbsp;<span class="nav-hot-badge">HOT</span>
                </a>
            </li>
            <li><a href="${pageContext.request.contextPath}/customer/dich-vu" id="nav-dichvu">Cửa hàng &amp; Dịch vụ</a></li>
            <li class="nav-dropdown-wrap">
                <a href="#" id="nav-tintuc">
                    Tin tức&nbsp;
                    <svg width="12" height="12" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
                        <polyline points="6 9 12 15 18 9"/>
                    </svg>
                </a>
                <div class="nav-dropdown-menu">
                    <a href="${pageContext.request.contextPath}/tin-tuc/the-thao" class="nav-dropdown-item">Thể thao</a>
                    <a href="${pageContext.request.contextPath}/tin-tuc/khuyen-mai" class="nav-dropdown-item">Khuyến mãi</a>
                    <a href="${pageContext.request.contextPath}/tin-tuc/su-kien" class="nav-dropdown-item">Sự kiện</a>
                </div>
            </li>
        </ul>
    </nav>
</header>

<!-- Mobile nav -->
<div id="mobileNav" class="mobile-nav">
    <a href="${pageContext.request.contextPath}/index.jsp" class="mobile-nav-link" id="mnav-home">
        <i class="fa-solid fa-house" style="width:20px;margin-right:10px;color:var(--primary)"></i>Trang Chủ
    </a>
    <a href="${pageContext.request.contextPath}/customer/dat-san" class="mobile-nav-link" id="mnav-booking">
        <i class="fa-solid fa-magnifying-glass" style="width:20px;margin-right:10px;color:var(--primary)"></i>Đặt sân
    </a>
    <a href="${pageContext.request.contextPath}/customer/ghep-keo" class="mobile-nav-link" id="mnav-ghepkeo">
        <i class="fa-solid fa-people-group" style="width:20px;margin-right:10px;color:var(--primary)"></i>Ghép kèo
    </a>
    <a href="${pageContext.request.contextPath}/customer/lich-su-dat-san" class="mobile-nav-link" id="mnav-history">
        <i class="fa-solid fa-calendar-check" style="width:20px;margin-right:10px;color:var(--primary)"></i>Lịch của tôi
    </a>
    <a href="${pageContext.request.contextPath}/customer/tai-khoan" class="mobile-nav-link" id="mnav-account">
        <i class="fa-solid fa-user" style="width:20px;margin-right:10px;color:var(--primary)"></i>Tài khoản
    </a>
</div>

<script>
(function() {
    // User dropdown
    const userBtn = document.getElementById('header-user-btn');
    const userDrop = document.getElementById('user-profile-dropdown');

    window.handleUserClick = function() {
        const isLoggedIn = ${user != null ? "true" : "false"};
        if (isLoggedIn) {
            if (userDrop) {
                userDrop.classList.toggle('show');
                userBtn && userBtn.setAttribute('aria-expanded', userDrop.classList.contains('show'));
            }
        } else {
            const curr = encodeURIComponent(window.location.pathname + window.location.search + window.location.hash);
            window.location.href = "${pageContext.request.contextPath}/dangnhap?redirect=" + curr;
        }
    };

    if (userBtn && userDrop) {
        document.addEventListener('click', e => {
            if (!userDrop.contains(e.target) && !userBtn.contains(e.target)) {
                userDrop.classList.remove('show');
                userBtn.setAttribute('aria-expanded', 'false');
            }
        });
        document.addEventListener('keydown', e => {
            if (e.key === 'Escape') { userDrop.classList.remove('show'); userBtn.setAttribute('aria-expanded', 'false'); }
        });
    }

    // Search redirect
    const searchInput = document.getElementById('header-search-input');
    if (searchInput) {
        searchInput.addEventListener('keydown', e => {
            if (e.key === 'Enter' && searchInput.value.trim()) {
                window.location.href = "${pageContext.request.contextPath}/customer/tim-kiem?q=" + encodeURIComponent(searchInput.value.trim());
            }
        });
    }

    // Mobile hamburger
    const mobileBtn = document.getElementById('mobileNavBtn');
    const mobileNav = document.getElementById('mobileNav');
    if (mobileBtn && mobileNav) {
        mobileBtn.addEventListener('click', e => {
            e.stopPropagation();
            mobileNav.classList.toggle('open');
            mobileBtn.querySelector('i').className = mobileNav.classList.contains('open') ? 'fa-solid fa-xmark' : 'fa-solid fa-bars';
        });
        document.addEventListener('click', e => {
            if (!mobileNav.contains(e.target) && !mobileBtn.contains(e.target)) {
                mobileNav.classList.remove('open');
                mobileBtn.querySelector('i').className = 'fa-solid fa-bars';
            }
        });
        mobileNav.querySelectorAll('a').forEach(a => {
            a.addEventListener('click', () => {
                mobileNav.classList.remove('open');
                mobileBtn.querySelector('i').className = 'fa-solid fa-bars';
            });
        });
    }

    // Active link
    const path = window.location.pathname;
    function setActive(id) { const el = document.getElementById(id); if (el) el.classList.add('active'); }
    if (path.includes('/customer/ghep-keo'))          { setActive('nav-ghepkeo'); setActive('mnav-ghepkeo'); }
    else if (path.includes('/customer/lich-su-dat-san')) { setActive('mnav-history'); }
    else if (path.includes('/customer/tai-khoan'))    { setActive('mnav-account'); }
    else if (path.includes('dat-san') || path.includes('ChiTietSan')) { setActive('nav-booking'); setActive('mnav-booking'); }
    else if (path.includes('/customer/ban-do'))       { setActive('nav-map'); }
    else if (path.endsWith('index.jsp') || path.endsWith('/')) { setActive('mnav-home'); }
})();
</script>

<!-- Side Drawer -->
<div id="side-drawer" class="side-drawer">
    <div class="side-drawer-overlay" onclick="closeSideDrawer()"></div>
    <div class="side-drawer-content">
        <div class="side-drawer-header">
            <a href="${pageContext.request.contextPath}/index.jsp" style="display:flex;align-items:center;gap:10px;text-decoration:none;">
                <img alt="V-SPORT" style="height:32px;border-radius:6px;" src="${pageContext.request.contextPath}/resources/logo.png"/>
                <span style="font-family:'Poppins',sans-serif;font-weight:700;font-size:18px;text-transform:uppercase;color:#111827;letter-spacing:-0.5px;">V- <span style="color:#3DD68C;">SPORT</span></span>
            </a>
            <button class="side-drawer-close" onclick="closeSideDrawer()">&times;</button>
        </div>

        <div class="side-drawer-section user-section">
            <c:choose>
                <c:when test="${user != null}">
                    <div class="drawer-user-info">
                        <div class="avatar-circle">
                            <c:choose>
                                <c:when test="${not empty user.fullName}">${user.fullName.substring(0,1).toUpperCase()}</c:when>
                                <c:otherwise>${user.username.substring(0,1).toUpperCase()}</c:otherwise>
                            </c:choose>
                        </div>
                        <div class="user-details">
                            <p class="user-name">
                                <c:choose>
                                    <c:when test="${not empty user.fullName}">${user.fullName}</c:when>
                                    <c:otherwise>${user.username}</c:otherwise>
                                </c:choose>
                            </p>
                            <p class="user-role">Thành viên</p>
                        </div>
                    </div>
                    <div class="drawer-user-actions">
                        <a href="${pageContext.request.contextPath}/customer/tai-khoan" class="btn-drawer-action"><i class="fa-regular fa-user"></i> Chỉnh sửa Profile</a>
                        <a href="${pageContext.request.contextPath}/customer/lich-su-dat-san" class="btn-drawer-action"><i class="fa-regular fa-calendar-check"></i> Lịch của tôi</a>
                        <a href="${pageContext.request.contextPath}/customer/ghep-keo" class="btn-drawer-action"><i class="fa-solid fa-people-group"></i> Ghép kèo</a>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="drawer-guest-info">
                        <p class="guest-msg">Đăng nhập để xem lịch sử đặt sân và quản lý hồ sơ của bạn.</p>
                        <button class="btn-drawer-login" onclick="closeSideDrawer(); const c=encodeURIComponent(window.location.pathname+window.location.search+window.location.hash); window.location.href='${pageContext.request.contextPath}/dangnhap?redirect='+c;">Đăng Nhập Ngay</button>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <div class="side-drawer-section">
            <h4 class="section-title">TIỆN ÍCH HỆ THỐNG</h4>
            <a href="${pageContext.request.contextPath}/index.jsp" class="drawer-link"><i class="fa-solid fa-house"></i> Trang Chủ</a>
            <a href="${pageContext.request.contextPath}/customer/dat-san" class="drawer-link"><i class="fa-solid fa-calendar-days"></i> Tìm Sân Đặt Lịch</a>
            <a href="${pageContext.request.contextPath}/customer/ghep-keo" class="drawer-link"><i class="fa-solid fa-people-group"></i> Ghép Kèo</a>
            <a href="${pageContext.request.contextPath}/index.jsp#pricing" class="drawer-link"><i class="fa-solid fa-tags"></i> Bảng Giá Dịch Vụ</a>
        </div>

        <div class="side-drawer-section">
            <h4 class="section-title">HỖ TRỢ TRỰC TUYẾN</h4>
            <div class="support-channels">
                <a href="https://zalo.me/0987654321" target="_blank" class="channel-btn zalo-btn">
                    <img src="https://upload.wikimedia.org/wikipedia/commons/9/91/Icon_of_Zalo.svg" alt="Zalo" class="channel-icon" />
                    <span>Hỗ trợ qua Zalo</span>
                </a>
                <a href="https://m.me/vsport" target="_blank" class="channel-btn messenger-btn">
                    <img src="https://upload.wikimedia.org/wikipedia/commons/b/be/Facebook_Messenger_logo_2020.svg" alt="Messenger" class="channel-icon" />
                    <span>Hỗ trợ qua Messenger</span>
                </a>
            </div>
        </div>

        <div class="side-drawer-footer">
            <div class="contact-item">
                <span class="label">Hotline hỗ trợ:</span>
                <span class="value">1900 1234</span>
            </div>
            <div class="contact-item">
                <span class="label">Email liên hệ:</span>
                <span class="value">support@vsport.vn</span>
            </div>
        </div>
    </div>
</div>

<script>
    window.openSideDrawer  = function() { document.getElementById('side-drawer').classList.add('open');    };
    window.closeSideDrawer = function() { document.getElementById('side-drawer').classList.remove('open'); };
</script>
