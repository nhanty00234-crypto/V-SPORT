<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="org.example.dao.impl.CoSoDAOImpl" %>
<%@ page import="org.example.dao.impl.LoaiSanDAOImpl" %>
<%@ page import="org.example.model.CoSo" %>
<%@ page import="org.example.model.MonTheThao" %>
<%@ page import="java.util.List" %>
<%
    Object roleIdObj = session.getAttribute("roleId");
    Object fullNameObj = session.getAttribute("fullName");
    Object emailObj    = session.getAttribute("email");

    int roleId = -1;
    if (roleIdObj instanceof Number) {
        roleId = ((Number) roleIdObj).intValue();
    } else if (roleIdObj instanceof String) {
        try { roleId = Integer.parseInt((String) roleIdObj); } catch (NumberFormatException ignored) {}
    }

    String fullName    = fullNameObj != null ? fullNameObj.toString() : "";
    String email       = emailObj    != null ? emailObj.toString()    : "";
    boolean isLoggedIn = roleId != -1 || session.getAttribute("user") != null;
    String displayName = !fullName.trim().isEmpty() ? fullName : (!email.trim().isEmpty() ? email : "Tài khoản");
    String avatarChar  = !displayName.isEmpty() ? displayName.substring(0, 1).toUpperCase() : "T";
    String displayNameSafe = displayName.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    String avatarCharSafe  = avatarChar.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");

    if (roleId != -1 && roleId != org.example.util.RoleRedirectUtil.ROLE_CUSTOMER) {
        String homePath = org.example.util.RoleRedirectUtil.getHomePathByRoleId(roleId);
        response.sendRedirect(request.getContextPath() + homePath);
        return;
    }
    String ctx = request.getContextPath();

    CoSoDAOImpl coSoDAO = new CoSoDAOImpl();
    LoaiSanDAOImpl loaiSanDAO = new LoaiSanDAOImpl();
    List<CoSo> dsCoSo = null;
    List<MonTheThao> dsMon = null;
    try {
        dsCoSo = coSoDAO.getAllCoSo();
        dsMon = loaiSanDAO.getAllMonTheThao();
    } catch (Exception e) {
        dsCoSo = new java.util.ArrayList<>();
        dsMon = new java.util.ArrayList<>();
    }
%>
<!DOCTYPE html>
<html class="light" lang="vi">
<head>
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>V-SPORT - Hệ Thống Đặt Sân Thể Thao</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@400;500;600;700;800&amp;display=swap" rel="stylesheet"/>

    <jsp:include page="/customer/common/vsport-theme.jsp" />

    <style>
        /* ---- Typography tokens (Montserrat: same family the reference uses; OFL, full Vietnamese) ---- */
        :root {
            --font-family-ui: 'Montserrat', 'Inter', system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            --font-size-xs: 11.5px;
            --font-size-sm: 13px;
            --font-size-md: 14.5px;
            --font-size-lg: 18px;
            --font-weight-regular: 400;
            --font-weight-medium: 500;
            --font-weight-semibold: 600;
            --font-weight-bold: 700;
        }
        body {
            background-color: var(--vs-surface);
            font-family: var(--font-family-ui);
        }

        /* Custom scrollbar hiding */
        .scrollbar-none::-webkit-scrollbar {
            display: none;
        }
        .scrollbar-none {
            -ms-overflow-style: none;
            scrollbar-width: none;
        }

        /* Shimmer text style */
        .shimmer-text {
            background: linear-gradient(to right, #ffffff 20%, #d1fae5 40%, #a7f3d0 60%, #ffffff 80%);
            background-size: 200% auto;
            color: transparent;
            -webkit-background-clip: text;
            background-clip: text;
            animation: shine 4s linear infinite;
        }
        @keyframes shine {
            to { background-position: 200% center; }
        }

        /* Facility card details hover effect */
        .img-ken-burns {
            transition: transform 1.2s cubic-bezier(0.16, 1, 0.3, 1);
        }
        .group:hover .img-ken-burns {
            transform: scale(1.06);
        }

        /* Custom spacing class */
        .px-safe-bottom {
            padding-bottom: calc(var(--vs-bottomnav-h, 62px) + env(safe-area-inset-bottom, 0px));
        }

        /* Full-width application shell: tight outer gutters, not a centered column. */
        .vs-shell { width: 100%; padding-left: 8px; padding-right: 8px; }
        @media (min-width: 768px) { .vs-shell { padding-left: 12px; padding-right: 12px; } }

        /* ============================ Top header (green band) ========================= */
        .vs-topband {
            width: 100%; background: #047857; position: relative; overflow: hidden;
            padding: 9px 10px 9px;
        }
        @media (min-width: 768px) { .vs-topband { padding: 9px 12px 9px; } }
        /* Abstract organic green shapes (CSS only, no external asset) — echoes the
           patterned sports band of the reference without copying any artwork. */
        .vs-topband::before {
            content: ""; position: absolute; inset: 0; pointer-events: none;
            background:
                radial-gradient(ellipse 420px 200px at 22% 130%, rgba(52, 211, 153, 0.38), transparent 62%),
                radial-gradient(ellipse 520px 260px at 48% -40%, rgba(16, 185, 129, 0.42), transparent 60%),
                radial-gradient(ellipse 380px 240px at 72% 140%, rgba(6, 78, 59, 0.70), transparent 65%),
                radial-gradient(ellipse 300px 190px at 90% -30%, rgba(110, 231, 183, 0.30), transparent 60%),
                radial-gradient(ellipse 260px 170px at 99% 110%, rgba(4, 60, 44, 0.60), transparent 68%),
                linear-gradient(112deg, transparent 34%, rgba(255,255,255,0.06) 34%, rgba(255,255,255,0.06) 39%, transparent 39%),
                linear-gradient(112deg, transparent 58%, rgba(255,255,255,0.05) 58%, rgba(255,255,255,0.05) 61%, transparent 61%);
        }
        .vs-topband-row { position: relative; z-index: 1; display: flex; align-items: flex-start; justify-content: space-between; gap: 12px; }
        .vs-topband-brand { display: flex; align-items: center; gap: 12px; min-width: 0; }
        .vs-topband-logo {
            width: 62px; height: 62px; border-radius: 50%; flex-shrink: 0;
            background: rgba(255,255,255,0.16); display: flex; align-items: center; justify-content: center;
        }
        .vs-topband-logo .material-symbols-outlined { font-size: 33px; color: #fff; }
        .vs-topband-date { font-size: 14.5px; font-weight: 600; color: #fff; }

        /* Auth cluster (logged-out) — rectangular buttons, tight group under logo/date. */
        .vs-authcluster { display: flex; align-items: center; gap: 10px; margin-top: 5px; }
        .vs-auth-btn {
            display: inline-flex; align-items: center; justify-content: center;
            height: 34px; padding: 0 20px; border-radius: 6px;
            font-size: 13px; font-weight: 700; white-space: nowrap;
            cursor: pointer; text-decoration: none; transition: background-color .15s ease, color .15s ease;
            min-width: 150px;
        }
        @media (min-width: 640px) { .vs-auth-btn { min-width: 235px; } }
        .vs-auth-btn-login { background: #fff; color: #047857; border: 1px solid #fff; }
        .vs-auth-btn-login:hover { background: #ecfdf5; }
        .vs-auth-btn-register { background: transparent; color: #fff; border: 2px solid #fff; }
        .vs-auth-btn-register:hover { background: rgba(255,255,255,0.12); }

        /* Session cluster (logged-in). */
        .vs-session-cluster { display: flex; align-items: center; gap: 10px; flex-shrink: 0; }
        .vs-session-avatar { width: 34px; height: 34px; border-radius: 50%; background: rgba(0,0,0,0.18); border: 1px solid rgba(255,255,255,0.35); color: #fff; font-weight: 800; font-size: 13px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
        .vs-session-name { font-size: 13px; font-weight: 700; color: #fff; max-width: 160px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .vs-session-btn { display: inline-flex; align-items: center; height: 34px; padding: 0 14px; border-radius: 6px; font-size: 12.5px; font-weight: 700; text-decoration: none; white-space: nowrap; transition: background-color .15s ease; }
        .vs-session-btn-schedule { background: rgba(255,255,255,0.14); color: #fff; }
        .vs-session-btn-schedule:hover { background: rgba(255,255,255,0.24); }
        .vs-session-btn-logout { background: #dc2626; color: #fff; }
        .vs-session-btn-logout:hover { background: #b91c1c; }

        /* ============================ Utility bar ============================= */
        /* ONE seamless white block: a single grid, cells separated only by thin
           vertical dividers. No per-cell radius, shadow, gap, or inner boxes. */
        .vs-utilitybar-wrap { padding: 4px 6px 0; }
        .vs-utilitybar {
            width: 100%; background: #fff; border: 1px solid #d9e6e1; border-radius: 8px;
            box-shadow: 0 1px 3px rgba(15, 23, 42, 0.06);
            display: grid; grid-template-columns: 50px minmax(320px, 1.9fr) 64px 1fr 1fr 1fr;
            height: 51px; padding: 0; overflow: hidden;
            position: sticky; top: 0; z-index: 40;
        }
        .vs-utilitybar:focus-within { border-color: var(--vs-accent); }
        .vs-ub-ic { display: flex; align-items: center; justify-content: center; height: 100%; }
        .vs-ub-ic svg { width: 29px; height: 29px; }
        .vs-ub-input {
            width: 100%; height: 100%; min-width: 0;
            border: none; outline: none; border-radius: 0; background: transparent; box-shadow: none;
            border-left: 1px solid #e8efec;
            padding: 0 14px; font-size: 14px; font-family: var(--font-family-ui); color: #1f2937;
        }
        .vs-ub-input::placeholder { color: #94a3b8; }
        .vs-ub-filter {
            display: flex; align-items: center; justify-content: center; height: 100%;
            border: none; border-left: 1px solid #e8efec; border-radius: 0;
            background: transparent; box-shadow: none; cursor: pointer;
            color: #047857; transition: background-color .15s ease;
        }
        .vs-ub-filter .material-symbols-outlined { font-size: 21px; }
        .vs-ub-filter:hover { background: #ecfdf5; }
        .vs-ub-action {
            display: flex; align-items: center; justify-content: center; gap: 8px; height: 100%;
            border-left: 1px solid #e8efec; border-radius: 0; box-shadow: none; background: transparent;
            text-decoration: none; color: #1f2937;
            font-size: 13.5px; font-weight: 600; white-space: nowrap; transition: background-color .15s ease;
            padding: 0 8px; min-width: 0;
        }
        .vs-ub-action:hover { background: #ecfdf5; }
        .vs-ub-action .material-symbols-outlined { font-size: 20px; color: #047857; flex-shrink: 0; }

        /* ============================ Promotional banner ============================= */
        /* Tri-zone composition: real V-SPORT imagery left + right, message center. */
        .vs-banner {
            position: relative; width: 100%; height: 160px;
            border-radius: 10px; overflow: hidden;
            background: linear-gradient(90deg, #065f46 0%, #047857 55%, #059669 100%);
            display: flex; align-items: center; justify-content: center;
            margin-bottom: 12px;
        }
        @media (min-width: 768px)  { .vs-banner { height: 210px; } }
        @media (min-width: 1280px) { .vs-banner { height: 260px; } }
        .vs-banner-side { position: absolute; top: 0; bottom: 0; width: 34%; pointer-events: none; }
        .vs-banner-side img { width: 100%; height: 100%; object-fit: cover; }
        .vs-banner-side-l { left: 0; }
        .vs-banner-side-r { right: 0; }
        .vs-banner-side-l::after {
            content: ""; position: absolute; inset: 0;
            background: linear-gradient(90deg, rgba(6,95,70,0.20) 0%, rgba(6,95,70,0.55) 55%, #065f46 100%);
        }
        .vs-banner-side-r::after {
            content: ""; position: absolute; inset: 0;
            background: linear-gradient(270deg, rgba(5,150,105,0.20) 0%, rgba(5,150,105,0.55) 55%, #058a61 100%);
        }
        .vs-banner-content { position: relative; z-index: 2; text-align: center; padding: 0 16px; max-width: 760px; }
        .vs-banner-kicker {
            display: inline-flex; align-items: center; gap: 6px;
            font-size: 11px; font-weight: 700; letter-spacing: 0.14em; text-transform: uppercase;
            color: #a7f3d0; margin-bottom: 6px;
        }
        .vs-banner-title {
            font-family: var(--font-family-ui); font-weight: 800; color: #fff;
            font-size: 20px; line-height: 1.2; margin-bottom: 6px;
            text-shadow: 0 2px 10px rgba(4, 47, 34, 0.45);
            text-wrap: balance;
        }
        @media (min-width: 768px)  { .vs-banner-title { font-size: 27px; } }
        @media (min-width: 1280px) { .vs-banner-title { font-size: 32px; } }
        .vs-banner-sub { font-size: 12.5px; font-weight: 500; color: #d1fae5; margin-bottom: 14px; }
        @media (min-width: 768px) { .vs-banner-sub { font-size: 14px; } }
        .vs-banner-ctas { display: flex; gap: 10px; justify-content: center; }
        .vs-banner-cta-main {
            display: inline-flex; align-items: center; height: 38px; padding: 0 22px;
            background: #f59e0b; color: #1f2937; font-size: 13px; font-weight: 800;
            border-radius: 8px; text-decoration: none; transition: background-color .15s ease;
        }
        .vs-banner-cta-main:hover { background: #d97706; }
        .vs-banner-cta-alt {
            display: inline-flex; align-items: center; height: 38px; padding: 0 22px;
            background: rgba(255,255,255,0.12); border: 1.5px solid rgba(255,255,255,0.75);
            color: #fff; font-size: 13px; font-weight: 700;
            border-radius: 8px; text-decoration: none; transition: background-color .15s ease;
        }
        .vs-banner-cta-alt:hover { background: rgba(255,255,255,0.22); }
        @media (max-width: 640px) {
            .vs-banner-side { width: 26%; }
            .vs-banner-sub { display: none; }
        }

        /* Mobile: same single container, two rows — icon+search+filter on top,
           the three actions below. Still one seamless block, no separate cards. */
        @media (max-width: 767px) {
            .vs-utilitybar { grid-template-columns: repeat(6, 1fr); grid-template-rows: 48px 46px; height: auto; }
            .vs-ub-ic { grid-column: span 1; }
            .vs-ub-ic svg { width: 26px; height: 26px; }
            .vs-ub-input { grid-column: span 4; padding: 0 12px; font-size: 13px; }
            .vs-ub-filter { grid-column: span 1; }
            .vs-ub-action { grid-column: span 2; border-top: 1px solid #e8efec; font-size: 12.5px; gap: 6px; }
            .vs-ub-action:first-of-type { border-left: none; }
            .vs-topband-logo { width: 48px; height: 48px; }
            .vs-topband-logo .material-symbols-outlined { font-size: 26px; }
            .vs-topband-date { font-size: 12.5px; }
            .vs-auth-btn { min-width: 0; flex: 1; padding: 0 12px; }
            .vs-authcluster { width: 100%; }
        }
    </style>
</head>
<body class="bg-surface text-on-surface antialiased overflow-x-hidden">

    <!-- Top green header band (matches reference screen) -->
    <header class="vs-topband select-none">
        <div class="vs-topband-row">
            <!-- Left: Logo + date + (logged-out) auth cluster -->
            <div class="vs-topband-brand">
                <a href="<%= ctx %>/index.jsp" class="vs-topband-logo" aria-label="V-SPORT — Trang chủ" title="V-SPORT">
                    <span class="material-symbols-outlined" aria-hidden="true">sports_tennis</span>
                </a>
                <div>
                    <div class="vs-topband-date" id="current-date-el"><!-- Loaded dynamically via JS --></div>
                    <% if (!isLoggedIn) { %>
                        <div class="vs-authcluster">
                            <a href="<%= ctx %>/dangnhap" class="vs-auth-btn vs-auth-btn-login" aria-label="Đăng nhập" title="Đăng nhập">Đăng nhập</a>
                            <button type="button" onclick="openAuthModal('register')" class="vs-auth-btn vs-auth-btn-register" aria-label="Đăng ký" title="Đăng ký">Đăng ký</button>
                        </div>
                    <% } %>
                </div>
            </div>

            <!-- Right: Logged-in session cluster only (mutually exclusive with auth cluster above) -->
            <% if (isLoggedIn) { %>
                <div class="vs-session-cluster">
                    <div class="vs-session-avatar" aria-hidden="true"><%= avatarCharSafe %></div>
                    <span class="vs-session-name"><%= displayNameSafe %></span>
                    <a href="<%= ctx %>/customer/lich-su-dat-san" class="vs-session-btn vs-session-btn-schedule" aria-label="Lịch của tôi" title="Lịch của tôi">Lịch của tôi</a>
                    <a href="<%= ctx %>/logout" class="vs-session-btn vs-session-btn-logout" aria-label="Đăng xuất" title="Đăng xuất">Đăng xuất</a>
                </div>
            <% } %>
        </div>
    </header>

    <!-- Search & shortcuts utility bar: ONE seamless white block (grid cells + thin dividers) -->
    <div class="vs-utilitybar-wrap">
        <section class="vs-utilitybar" aria-label="Tìm kiếm và điều hướng nhanh">
            <span class="vs-ub-ic" aria-hidden="true">
                <%-- Original V-SPORT shuttlecock mark (hand-drawn inline SVG, not a copied asset) --%>
                <svg viewBox="0 0 24 24" fill="none" stroke="#047857" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                    <circle cx="7" cy="17" r="2.7" fill="#047857" stroke="none"/>
                    <path d="M9.3 14.7 L18.4 5.6"/>
                    <path d="M9.9 15.8 L20.6 9.6"/>
                    <path d="M8.2 14.1 L14.4 3.6"/>
                    <path d="M14.4 3.6 Q19.2 4.6 20.6 9.6"/>
                </svg>
            </span>
            <label for="facilitySearchInput" style="position:absolute;width:1px;height:1px;overflow:hidden;clip:rect(0,0,0,0);">Tìm sân, cơ sở hoặc môn thể thao</label>
            <input type="text" id="facilitySearchInput" class="vs-ub-input" onkeyup="searchFacilities()" placeholder="Tìm sân, cơ sở hoặc môn thể thao" aria-label="Tìm sân, cơ sở hoặc môn thể thao" />
            <button type="button" onclick="redirectToBookingSearch()" class="vs-ub-filter" aria-label="Lọc chi tiết" title="Lọc chi tiết">
                <span class="material-symbols-outlined" aria-hidden="true">tune</span>
            </button>
            <a href="<%= ctx %>/customer/ban-do" class="vs-ub-action" aria-label="Bản đồ" title="Bản đồ">
                <span class="material-symbols-outlined" aria-hidden="true">map</span>
                <span>Bản đồ</span>
            </a>
            <a href="<%= ctx %>/customer/lich-su-dat-san" class="vs-ub-action" aria-label="Sân đã đặt" title="Sân đã đặt">
                <span class="material-symbols-outlined" aria-hidden="true">check_circle</span>
                <span>Sân đã đặt</span>
            </a>
            <a href="<%= ctx %>/customer/ghep-keo" class="vs-ub-action" aria-label="Ghép trận" title="Ghép trận">
                <span class="material-symbols-outlined" aria-hidden="true">groups</span>
                <span>Ghép trận</span>
            </a>
        </section>
    </div>

    <main class="w-full vs-shell py-3 px-safe-bottom">
        
        <!-- V-SPORT promotional banner: real facility imagery left/right, message center -->
        <div class="vs-banner select-none">
            <div class="vs-banner-side vs-banner-side-l" aria-hidden="true">
                <img src="<%= ctx %>/assets/images/home/hero-sports-facility.webp" alt="" loading="eager" />
            </div>
            <div class="vs-banner-side vs-banner-side-r" aria-hidden="true">
                <img src="<%= ctx %>/assets/images/home/booking-cta.webp" alt="" loading="eager" />
            </div>
            <div class="vs-banner-content">
                <span class="vs-banner-kicker">
                    <span class="material-symbols-outlined text-[14px]" aria-hidden="true">sports_soccer</span>
                    V-SPORT
                </span>
                <h1 class="vs-banner-title">Tìm sân và kết nối người chơi gần bạn</h1>
                <p class="vs-banner-sub">Đặt sân giữ chỗ trong 2 phút, thanh toán QR tự động qua PayOS.</p>
                <div class="vs-banner-ctas">
                    <a href="<%= ctx %>/customer/dat-san" class="vs-banner-cta-main">Đặt sân ngay</a>
                    <a href="<%= ctx %>/customer/ghep-keo" class="vs-banner-cta-alt">Tìm kèo ghép</a>
                </div>
            </div>
        </div>

        <!-- Sport category chips selector (filters the grid instantly) -->
        <div class="flex items-center gap-2 overflow-x-auto pb-1 scrollbar-none mb-3" style="-webkit-overflow-scrolling:touch;">
            <button type="button" class="vs-chip is-active" data-sport-filter="all" onclick="filterBySport('all', this)">
                Tất cả
            </button>
            <% if (dsMon != null) {
                for (MonTheThao m : dsMon) { %>
                    <button type="button" class="vs-chip" data-sport-filter="<%= m.getTenMon() %>" onclick="filterBySport('<%= m.getTenMon() %>', this)">
                        <%= m.getTenMon() %>
                    </button>
                <% }
            } %>
        </div>

        <!-- Section Title -->
        <div class="flex items-center justify-between mb-2.5 select-none">
            <h2 class="text-sm font-bold text-gray-900 flex items-center gap-1.5">
                <span class="material-symbols-outlined text-emerald-700 text-[18px]">stars</span>
                Cơ sở nổi bật
            </h2>
            <a href="<%= ctx %>/customer/dat-san" class="text-xs font-bold text-emerald-700 hover:underline">
                Xem tất cả &rarr;
            </a>
        </div>

        <!-- High-density dynamic grid of facilities (matches reference mockup cards) -->
        <div id="facilityGrid" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-2.5">
            <% if (dsCoSo != null && !dsCoSo.isEmpty()) {
                for (CoSo cs : dsCoSo) {
                    String csImg = cs.getHinhAnh() != null ? cs.getHinhAnh().trim() : "";
                    String csOpen = cs.getGioMoCua() != null ? cs.getGioMoCua().toString().substring(0,5) : "06:00";
                    String csClose = cs.getGioDongCua() != null ? cs.getGioDongCua().toString().substring(0,5) : "23:00";
                    String businessType = cs.getLoaiHinhKinhDoanh() != null ? cs.getLoaiHinhKinhDoanh() : "";
                    String csName = cs.getTenCoSo() != null ? cs.getTenCoSo() : "";
                    String csNameSafe = csName.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
                    String csAddr = cs.getDiaChi() != null ? cs.getDiaChi() : "";
                    String csAddrSafe = csAddr.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");

                    // Deterministic per-sport fallback image (never one repeated photo for everything).
                    String sportsLower = businessType.toLowerCase();
                    String fbImg = "hero-sports-facility.webp";
                    if (sportsLower.contains("bóng đá") || sportsLower.contains("bong da")) fbImg = "sport-football.webp";
                    else if (sportsLower.contains("cầu lông") || sportsLower.contains("cau long")) fbImg = "sport-badminton.webp";
                    else if (sportsLower.contains("pickle")) fbImg = "sport-pickleball.webp";
                    else if (sportsLower.contains("tennis")) fbImg = "sport-tennis.webp";
                    else if (sportsLower.contains("bóng bàn") || sportsLower.contains("bong ban")) fbImg = "sport-tabletennis.webp";
                    else if (sportsLower.contains("gym") || sportsLower.contains("fitness")) fbImg = "sport-gym.webp";
                    String fbImgUrl = ctx + "/assets/images/home/" + fbImg;

                    // Resolve the card image server-side: remote URLs pass through (client
                    // onerror still guards them); local paths are checked on disk so a
                    // missing upload never produces a 404 -> blank image.
                    String cardImgUrl = fbImgUrl;
                    if (csImg.startsWith("http")) {
                        cardImgUrl = csImg;
                    } else if (csImg.contains("/")) {
                        String rel = csImg.startsWith("/") ? csImg : "/" + csImg;
                        String realPath = application.getRealPath(rel);
                        if (realPath != null && new java.io.File(realPath).isFile()) {
                            cardImgUrl = ctx + rel;
                        }
                    }

                    // First sport for the image badge (real data only; no badge when unset).
                    String firstSport = businessType.contains(",") ? businessType.substring(0, businessType.indexOf(',')).trim() : businessType.trim();
                    String firstSportSafe = firstSport.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
            %>
                <div class="facility-card vs-card overflow-hidden group flex flex-col relative bg-white border border-gray-100 hover:shadow-md transition-shadow duration-300"
                     data-name="<%= csName.toLowerCase() %>"
                     data-address="<%= csAddr.toLowerCase() %>"
                     data-sport="<%= sportsLower %>">

                    <!-- Top Image & Badges/Overlay -->
                    <div class="relative w-full h-[122px] overflow-hidden bg-gray-100 shrink-0">
                        <img class="w-full h-full object-cover img-ken-burns"
                             src="<%= cardImgUrl %>"
                             onerror="this.onerror=null;this.src='<%= fbImgUrl %>';"
                             alt="<%= csNameSafe %>" />
                        <!-- Badges (real data only) -->
                        <div class="absolute top-1.5 left-1.5 flex gap-1 z-10">
                            <span class="text-[10px] font-bold text-white bg-emerald-600 px-2 py-0.5 rounded shadow-sm">Đơn ngày</span>
                            <% if (!firstSport.isEmpty()) { %>
                                <span class="text-[10px] font-bold text-emerald-800 bg-emerald-50/95 px-2 py-0.5 rounded shadow-sm"><%= firstSportSafe %></span>
                            <% } %>
                        </div>
                        <!-- Favorite & Share floating shortcuts -->
                        <div class="absolute top-1.5 right-1.5 flex gap-1 z-10">
                            <button onclick="toggleFavorite('<%= cs.getCoSoID() %>', this)" aria-label="Lưu cơ sở yêu thích" title="Yêu thích" class="w-7 h-7 bg-white/95 rounded-full flex items-center justify-center text-gray-400 hover:text-red-500 shadow-sm transition-colors border-none cursor-pointer">
                                <span class="material-symbols-outlined text-[15px]" aria-hidden="true">favorite</span>
                            </button>
                            <button onclick="shareFacility('<%= csNameSafe %>', '<%= cs.getCoSoID() %>')" aria-label="Chia sẻ cơ sở" title="Chia sẻ" class="w-7 h-7 bg-white/95 rounded-full flex items-center justify-center text-gray-400 hover:text-emerald-700 shadow-sm transition-colors border-none cursor-pointer">
                                <span class="material-symbols-outlined text-[15px]" aria-hidden="true">share</span>
                            </button>
                        </div>
                    </div>

                    <!-- Information Content -->
                    <div class="px-3 py-2.5 flex gap-2.5 items-start">
                        <!-- Facility Sport Icon -->
                        <div class="w-9 h-9 rounded-full bg-emerald-50 border border-emerald-100 flex items-center justify-center text-emerald-700 shrink-0 select-none mt-0.5">
                            <span class="material-symbols-outlined text-[17px]" aria-hidden="true">sports_tennis</span>
                        </div>

                        <!-- Texts block -->
                        <div class="flex-1 min-w-0">
                            <h3 class="font-bold text-gray-900 text-[14px] leading-snug truncate group-hover:text-emerald-700 transition-colors" title="<%= csNameSafe %>">
                                <%= csNameSafe %>
                            </h3>
                            <p class="text-[12px] text-gray-500 truncate mt-0.5 flex items-center gap-1" title="<%= csAddrSafe %>">
                                <span class="material-symbols-outlined text-[13px] text-emerald-600 shrink-0" aria-hidden="true">location_on</span>
                                <span class="truncate"><%= csAddr.isEmpty() ? "Chưa cập nhật" : csAddrSafe %></span>
                            </p>
                            <p class="text-[12px] text-gray-500 mt-0.5 flex items-center gap-1">
                                <span class="material-symbols-outlined text-[13px] text-emerald-600" aria-hidden="true">schedule</span>
                                <span><%= csOpen %> - <%= csClose %></span>
                            </p>
                        </div>

                        <!-- Booking trigger CTA button (positioned to the right) -->
                        <div class="shrink-0 self-center">
                            <a href="<%= ctx %>/customer/dat-san?facilityId=<%= cs.getCoSoID() %>" aria-label="Đặt lịch tại <%= csNameSafe %>" class="bg-yellow-500 hover:bg-yellow-600 text-gray-900 text-[11.5px] font-extrabold px-3 py-2 rounded-md tracking-wide transition-colors shadow-sm whitespace-nowrap text-decoration-none">
                                ĐẶT LỊCH
                            </a>
                        </div>
                    </div>
                </div>
            <% }
            } else { %>
                <div class="col-span-full py-14 text-center">
                    <span class="material-symbols-outlined text-[48px] text-gray-300 block mb-3">domain_disabled</span>
                    <p class="text-sm text-gray-400 font-semibold">Chưa có cơ sở nào được thiết lập.</p>
                </div>
            <% } %>
        </div>

    </main>

    <!-- Navigation Modals and Toasts (Self-contained) -->
    <div id="vsHomeToast" role="status" aria-live="polite" style="position:fixed;left:50%;bottom:calc(var(--vs-bottomnav-h, 62px) + 26px);transform:translateX(-50%) translateY(12px);z-index:1300;background:#0f172a;color:#fff;padding:10px 16px;border-radius:9999px;font-size:13px;font-weight:600;opacity:0;visibility:hidden;transition:opacity .2s ease,transform .2s ease;box-shadow:0 6px 18px rgba(15,23,42,.25);"></div>

    <jsp:include page="/auth/AuthModal.jsp" />
    <jsp:include page="/customer/common/bottom-nav.jsp" />

    <script>
        // Set dynamic date in header
        document.addEventListener('DOMContentLoaded', () => {
            const dateOptions = { weekday: 'long', year: 'numeric', month: 'numeric', day: 'numeric' };
            const today = new Date().toLocaleDateString('vi-VN', dateOptions);
            const formattedDate = today.charAt(0).toUpperCase() + today.slice(1);
            const dateEl = document.getElementById('current-date-el');
            if (dateEl) {
                dateEl.textContent = formattedDate;
            }
        });

        // Redirect tune filter to main search page
        function redirectToBookingSearch() {
            window.location.href = "<%= ctx %>/customer/dat-san";
        }

        // Show generic home toast
        let vsHomeToastTimer = null;
        function showHomeToast(msg) {
            const toast = document.getElementById('vsHomeToast');
            if (!toast) return;
            toast.textContent = msg;
            toast.style.opacity = '1';
            toast.style.visibility = 'visible';
            toast.style.transform = 'translateX(-50%) translateY(0)';
            clearTimeout(vsHomeToastTimer);
            vsHomeToastTimer = setTimeout(() => {
                toast.style.opacity = '0';
                toast.style.transform = 'translateX(-50%) translateY(12px)';
                setTimeout(() => { toast.style.visibility = 'hidden'; }, 220);
            }, 2000);
        }

        // Toast triggers
        function showFavoriteToast() {
            showHomeToast("Danh sách yêu thích sẽ được cập nhật trong phiên bản tới");
        }

        function toggleFavorite(id, btn) {
            event.stopPropagation();
            const iconEl = btn.querySelector('.material-symbols-outlined');
            if (iconEl.classList.contains('fill-current')) {
                iconEl.classList.remove('fill-current');
                btn.classList.add('text-gray-400');
                btn.classList.remove('text-red-500');
                showHomeToast("Đã bỏ lưu cơ sở");
            } else {
                iconEl.classList.add('fill-current');
                btn.classList.remove('text-gray-400');
                btn.classList.add('text-red-500');
                showHomeToast("Đã thêm vào danh sách yêu thích");
            }
        }

        function shareFacility(name, id) {
            event.stopPropagation();
            if (navigator.clipboard) {
                const url = window.location.origin + "<%= ctx %>/customer/dat-san?facilityId=" + id;
                navigator.clipboard.writeText(url).then(() => {
                    showHomeToast("Đã sao chép liên kết chia sẻ cơ sở " + name);
                }).catch(() => {
                    showHomeToast("Không thể sao chép liên kết");
                });
            } else {
                showHomeToast("Trình duyệt không hỗ trợ sao chép liên kết");
            }
        }

        // Client-side instant search
        function searchFacilities() {
            const query = document.getElementById('facilitySearchInput').value.toLowerCase();
            const cards = document.querySelectorAll('.facility-card');
            cards.forEach(card => {
                const name = card.getAttribute('data-name');
                const address = card.getAttribute('data-address');
                const sport = card.getAttribute('data-sport');
                if (name.includes(query) || address.includes(query) || sport.includes(query)) {
                    card.style.display = 'flex';
                } else {
                    card.style.display = 'none';
                }
            });
        }

        // Client-side sport chips filtering
        function filterBySport(sport, btn) {
            const chips = btn.parentElement.querySelectorAll('.vs-chip');
            chips.forEach(c => c.classList.remove('is-active'));
            btn.classList.add('is-active');

            const cards = document.querySelectorAll('.facility-card');
            cards.forEach(card => {
                const sportData = card.getAttribute('data-sport');
                if (sport === 'all' || sportData.includes(sport.toLowerCase())) {
                    card.style.display = 'flex';
                } else {
                    card.style.display = 'none';
                }
            });
        }
    </script>
</body>
</html>
