<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<!-- Load FontAwesome and Google Fonts for consistent styling -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>

<style>
    /* New Index Header Styles */
    :root {
        --primary: #10b981; 
        --primary-dark: #059669;
        --primary-light: #ecfdf5;
        --text-dark: #1e293b;
        --text-muted: #64748b;
        --bg-light: #f8fafc;
        --white: #ffffff;
        --transition: all 0.3s ease;
    }
    
    .navbar {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 20px 8%;
        background: #ffffff;
        position: sticky;
        top: 0;
        z-index: 100;
        box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        font-family: 'Poppins', sans-serif;
        box-sizing: border-box;
    }
    .navbar * {
        box-sizing: border-box;
    }
    .logo-container {
        text-decoration: none;
    }
    .logo {
        font-size: 1.5rem;
        font-weight: 700;
        color: var(--primary-dark);
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .nav-links {
        list-style: none;
        display: flex;
        gap: 30px;
        margin: 0;
        padding: 0;
    }
    .nav-links a {
        text-decoration: none;
        color: var(--text-dark);
        font-size: 0.95rem;
        font-weight: 500;
        transition: var(--transition);
    }
    .nav-links a:hover, .nav-links a.active {
        color: var(--primary);
        font-weight: 600;
    }

    /* Shimmering Register Button */
    .btn-register-shimmer {
        position: relative;
        padding: 12px 32px;
        background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
        color: #ffffff;
        font-size: 0.95rem;
        font-weight: 600;
        border-radius: 30px;
        text-decoration: none;
        display: inline-flex;
        align-items: center;
        gap: 8px;
        overflow: hidden;
        border: none;
        box-shadow: 0 4px 15px rgba(16, 185, 129, 0.3);
        transition: all 0.4s cubic-bezier(0.25, 1, 0.5, 1);
        cursor: pointer;
    }

    .btn-register-shimmer::before {
        content: '';
        position: absolute;
        top: 0;
        left: -150%;
        width: 50%;
        height: 100%;
        background: linear-gradient(
            90deg,
            rgba(255, 255, 255, 0) 0%,
            rgba(255, 255, 255, 0.4) 50%,
            rgba(255, 255, 255, 0) 100%
        );
        transform: skewX(-20deg);
        transition: none;
    }

    .btn-register-shimmer:hover::before { animation: shimmerEffect 1.5s infinite; }
    .btn-register-shimmer:hover {
        transform: translateY(-3px);
        box-shadow: 0 10px 25px rgba(16, 185, 129, 0.5);
        color: #ffffff;
    }
    .btn-register-shimmer:active {
        transform: translateY(-1px);
        box-shadow: 0 5px 15px rgba(16, 185, 129, 0.4);
    }
    .btn-register-shimmer i {
        font-size: 1rem;
        transition: transform 0.3s ease;
    }
    .btn-register-shimmer:hover i { transform: translateX(4px); }

    @keyframes shimmerEffect {
        0% { left: -150%; }
        100% { left: 150%; }
    }
    
    /* User dropdown styling to match the new green theme */
    .user-menu-container {
        position: relative;
    }
    .user-menu-btn {
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 6px 16px;
        border-radius: 30px;
        background: #ffffff;
        border: 1px solid #e2e8f0;
        cursor: pointer;
        transition: var(--transition);
    }
    .user-menu-btn:hover {
        background-color: var(--primary-light);
        border-color: var(--primary);
    }
    .user-avatar {
        width: 32px;
        height: 32px;
        border-radius: 50%;
        background-color: var(--primary);
        display: flex;
        align-items: center;
        justify-content: center;
        color: #ffffff;
        font-weight: 700;
        font-size: 0.85rem;
    }
    .user-name {
        font-size: 0.9rem;
        font-weight: 600;
        color: var(--text-dark);
    }
    .user-dropdown-menu {
        position: absolute;
        right: 0;
        top: 100%;
        margin-top: 10px;
        width: 240px;
        background: #ffffff;
        border: 1px solid #e2e8f0;
        border-radius: 16px;
        box-shadow: 0 10px 25px rgba(0,0,0,0.08);
        z-index: 110;
        overflow: hidden;
        opacity: 0;
        visibility: hidden;
        transform: translateY(10px);
        transition: var(--transition);
    }
    .user-dropdown-menu.show {
        opacity: 1;
        visibility: visible;
        transform: translateY(0);
    }
    .user-info-header {
        padding: 16px;
        background-color: var(--primary-light);
        border-bottom: 1px solid #e2e8f0;
    }
    .user-info-name {
        display: block;
        font-size: 0.9rem;
        font-weight: 700;
        color: var(--text-dark);
    }
    .user-info-email {
        display: block;
        font-size: 0.75rem;
        color: var(--text-muted);
        margin-top: 2px;
    }
    .user-dropdown-item {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 12px 16px;
        color: var(--text-dark);
        text-decoration: none;
        font-size: 0.85rem;
        transition: var(--transition);
    }
    .user-dropdown-item:hover {
        background-color: var(--primary-light);
        color: var(--primary-dark);
    }
    .user-dropdown-item.logout {
        color: #ef4444;
        border-top: 1px solid #f1f5f9;
    }
    .user-dropdown-item.logout:hover {
        background-color: #fef2f2;
        color: #dc2626;
    }

    .fade-down { animation: fadeDown 1s cubic-bezier(0.1, 0.8, 0.2, 1); }
    @keyframes fadeDown {
        from { opacity: 0; transform: translateY(-30px); }
        to { opacity: 1; transform: translateY(0); }
    }

    @media (max-width: 768px) {
        .nav-links {
            display: none;
        }
    }
</style>

<nav class="navbar fade-down">
    <a href="${pageContext.request.contextPath}/index.jsp" class="logo-container">
        <div class="logo">
            <i class="fa-solid fa-futbol"></i> V-SPORT
        </div>
    </a>
    <ul class="nav-links">
        <li><a href="${pageContext.request.contextPath}/index.jsp" id="nav-home">Trang Chủ</a></li>
        <li><a href="${pageContext.request.contextPath}/customer/dat-san" id="nav-booking">Tìm Sân</a></li>
        <li><a href="#" id="nav-tournaments">Giải Đấu</a></li>
        <li><a href="#" id="nav-community">Cộng Đồng</a></li>
        <li><a href="${pageContext.request.contextPath}/index.jsp#pricing" id="nav-pricing">Bảng Giá</a></li>
    </ul>
    
    <c:choose>
        <c:when test="${user != null}">
            <!-- User Profile Dropdown -->
            <div class="user-menu-container">
                <button id="user-menu-button" class="user-menu-btn">
                    <div class="user-avatar">
                        <c:choose>
                            <c:when test="${not empty user.fullName}">
                                ${fn:substring(user.fullName, 0, 1).toUpperCase()}
                            </c:when>
                            <c:otherwise>
                                ${fn:substring(user.username, 0, 1).toUpperCase()}
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <span class="user-name">
                        <c:choose>
                            <c:when test="${not empty user.fullName}">
                                <c:set var="parts" value="${fn:split(user.fullName, ' ')}" />
                                ${parts[fn:length(parts) - 1]}
                            </c:when>
                            <c:otherwise>
                                ${user.username}
                            </c:otherwise>
                        </c:choose>
                    </span>
                </button>

                <!-- Dropdown Menu -->
                <div id="user-dropdown" class="user-dropdown-menu">
                    <div class="user-info-header">
                        <span class="user-info-name">${user.fullName}</span>
                        <span class="user-info-email">${user.email}</span>
                    </div>
                    <div class="p-1">
                        <a href="${pageContext.request.contextPath}/customer/TaiKhoan.jsp" class="user-dropdown-item">
                            <span class="material-symbols-outlined text-[18px]">account_circle</span>
                            Hồ sơ cá nhân
                        </a>
                        <a href="${pageContext.request.contextPath}/customer/dat-san?openHistory=true" class="user-dropdown-item">
                            <span class="material-symbols-outlined text-[18px]">history</span>
                            Lịch sử đặt sân
                        </a>
                        <a href="${pageContext.request.contextPath}/logout" class="user-dropdown-item logout">
                            <span class="material-symbols-outlined text-[18px]">logout</span>
                            Đăng xuất
                        </a>
                    </div>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <button onclick="openAuthModal('login')" class="btn-register-shimmer">
                Đăng ký / Đăng nhập <i class="fa-solid fa-arrow-right-to-bracket"></i>
            </button>
        </c:otherwise>
    </c:choose>
</nav>

<script>
    // User Dropdown Toggle
    (function() {
        const userMenuBtn = document.getElementById('user-menu-button');
        const userDropdown = document.getElementById('user-dropdown');
        
        if (userMenuBtn && userDropdown) {
            userMenuBtn.addEventListener('click', (e) => {
                e.stopPropagation();
                userDropdown.classList.toggle('show');
            });

            document.addEventListener('click', (e) => {
                if (!userDropdown.contains(e.target) && !userMenuBtn.contains(e.target)) {
                    userDropdown.classList.remove('show');
                }
            });
        }
        
        // Auto active link based on URL
        const currentPath = window.location.pathname;
        const currentHash = window.location.hash;
        
        const navHome = document.getElementById('nav-home');
        const navBooking = document.getElementById('nav-booking');
        const navPricing = document.getElementById('nav-pricing');
        
        if (navHome && navBooking && navPricing) {
            navHome.classList.remove('active');
            navBooking.classList.remove('active');
            navPricing.classList.remove('active');
            
            if (currentPath.includes('dat-san')) {
                navBooking.classList.add('active');
            } else if (currentHash.includes('pricing') || currentPath.includes('pricing')) {
                navPricing.classList.add('active');
            } else if (currentPath.endsWith('index.jsp') || currentPath.endsWith('/') || currentPath.includes('TrangChu')) {
                navHome.classList.add('active');
            }
        }
    })();
</script>

<jsp:include page="/auth/AuthModal.jsp" />
