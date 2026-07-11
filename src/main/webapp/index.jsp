<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%
    org.example.model.TaiKhoan loggedInUser = (org.example.model.TaiKhoan) session.getAttribute("user");
    if (loggedInUser != null) {
        if (loggedInUser.getRoleId() == 1) {
            response.sendRedirect(request.getContextPath() + "/admin/nhan-su");
            return;
        } else if (loggedInUser.getRoleId() == 2) {
            response.sendRedirect(request.getContextPath() + "/manager/nhan-su");
            return;
        } else if (loggedInUser.getRoleId() == 4 || loggedInUser.getRoleId() == 5) {
            response.sendRedirect(request.getContextPath() + "/staff/dashboard");
            return;
        }
    }
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html class="light" lang="vi">
<head>
<meta charset="utf-8"/>
<meta content="width=device-width, initial-scale=1.0" name="viewport"/>
<title>V-SPORT – Hệ Thống Đặt Sân Thể Thao</title>
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
<link href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:wght@600;700&amp;family=DM+Sans:wght@400;500;700&amp;family=Poppins:wght@400;500;600;700&amp;display=swap" rel="stylesheet"/>
<script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    colors: {
                        "secondary-fixed": "#e5e2e1",
                        "outline-variant": "#c5c9b0",
                        "surface": "#faf9fd",
                        "on-primary-fixed-variant": "#3b4d00",
                        "secondary-fixed-dim": "#c8c6c5",
                        "on-primary": "#ffffff",
                        "inverse-on-surface": "#f1f0f4",
                        "error": "#ba1a1a",
                        "surface-bright": "#faf9fd",
                        "primary-container": "#afd639",
                        "inverse-surface": "#2f3033",
                        "surface-dim": "#dad9dd",
                        "on-error-container": "#93000a",
                        "error-container": "#ffdad6",
                        "on-tertiary-fixed-variant": "#00419c",
                        "on-error": "#ffffff",
                        "on-tertiary": "#ffffff",
                        "outline": "#757964",
                        "on-secondary-fixed-variant": "#474646",
                        "on-surface": "#1a1c1e",
                        "secondary": "#5f5e5e",
                        "surface-container-low": "#f4f3f7",
                        "tertiary-fixed-dim": "#b0c6ff",
                        "surface-container": "#eeedf1",
                        "surface-container-lowest": "#ffffff",
                        "on-secondary-fixed": "#1c1b1b",
                        "on-background": "#1a1c1e",
                        "surface-tint": "#506600",
                        "on-tertiary-container": "#004db6",
                        "secondary-container": "#e5e2e1",
                        "on-surface-variant": "#444936",
                        "tertiary-fixed": "#d9e2ff",
                        "on-secondary": "#ffffff",
                        "on-primary-container": "#465a00",
                        "on-primary-fixed": "#161f00",
                        "surface-container-highest": "#e3e2e6",
                        "court-blue": "#427CF0",
                        "primary-fixed-dim": "#aed538",
                        "tertiary": "#0458cb",
                        "primary-fixed": "#c9f253",
                        "inverse-primary": "#aed538",
                        "surface-container-high": "#e8e8ec",
                        "tertiary-container": "#b2c7ff",
                        "primary": "#506600",
                        "on-tertiary-fixed": "#001945",
                        "background": "#faf9fd",
                        "on-secondary-container": "#656464",
                        "surface-variant": "#e3e2e6"
                    },
                    borderRadius: {
                        DEFAULT: "0.25rem",
                        lg: "0.5rem",
                        xl: "0.75rem",
                        full: "9999px"
                    },
                    spacing: {
                        base: "8px",
                        "container-max": "1680px",
                        "margin-desktop": "32px",
                        "margin-mobile": "16px",
                        gutter: "24px"
                    },
                    fontFamily: {
                        "headline-sm": ["Barlow Condensed", "sans-serif"],
                        "body-md": ["Barlow", "sans-serif"],
                        "headline-lg": ["Barlow Condensed", "sans-serif"],
                        "label-md": ["Barlow", "sans-serif"],
                        "headline-md": ["Barlow Condensed", "sans-serif"],
                        "headline-lg-mobile": ["Barlow Condensed", "sans-serif"],
                        "display-lg": ["Barlow Condensed", "sans-serif"],
                        "label-lg": ["Barlow", "sans-serif"],
                        "body-lg": ["Barlow", "sans-serif"]
                    },
                    fontSize: {
                        "headline-sm": ["24px", { lineHeight: "1.2", fontWeight: "600" }],
                        "body-md": ["16px", { lineHeight: "1.6", fontWeight: "400" }],
                        "headline-lg": ["48px", { lineHeight: "1.1", fontWeight: "700" }],
                        "label-md": ["12px", { lineHeight: "1.0", fontWeight: "500" }],
                        "headline-md": ["32px", { lineHeight: "1.2", fontWeight: "600" }],
                        "headline-lg-mobile": ["32px", { lineHeight: "1.1", fontWeight: "700" }],
                        "display-lg": ["72px", { lineHeight: "1.0", letterSpacing: "-0.02em", fontWeight: "700" }],
                        "label-lg": ["14px", { lineHeight: "1.0", letterSpacing: "0.05em", fontWeight: "700" }],
                        "body-lg": ["18px", { lineHeight: "1.6", fontWeight: "400" }]
                    },
                    keyframes: {
                        marquee: {
                            "0%":   { transform: "translateX(0)" },
                            "100%": { transform: "translateX(-50%)" }
                        }
                    },
                    animation: {
                        "marquee": "marquee 20s linear infinite"
                    }
                }
            }
        }
    </script>
<style>
        .hover-outline:hover { box-shadow: 0 0 0 1px #0F0F0F; }
        .hide-scroll::-webkit-scrollbar { display: none; }
        .hide-scroll { -ms-overflow-style: none; scrollbar-width: none; }

        /* Side Drawer Offcanvas CSS */
        .side-drawer {
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            z-index: 9999;
            visibility: hidden;
            transition: visibility 0.3s ease;
        }
        .side-drawer.open {
            visibility: visible;
        }
        .side-drawer-overlay {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.4);
            opacity: 0;
            transition: opacity 0.3s ease;
        }
        .side-drawer.open .side-drawer-overlay {
            opacity: 1;
        }
        .side-drawer-content {
            position: absolute;
            top: 0;
            right: -360px;
            width: 360px;
            height: 100%;
            background-color: #ffffff;
            box-shadow: -5px 0 25px rgba(0,0,0,0.15);
            display: flex;
            flex-direction: column;
            transition: right 0.3s ease;
            padding: 24px;
            box-sizing: border-box;
            overflow-y: auto;
        }
        .side-drawer.open .side-drawer-content {
            right: 0;
        }
        .side-drawer-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid #f0f0f0;
            padding-bottom: 16px;
            margin-bottom: 24px;
        }
        .side-drawer-close {
            background: none;
            border: none;
            font-size: 28px;
            cursor: pointer;
            color: #999999;
            transition: color 0.2s;
            line-height: 1;
        }
        .side-drawer-close:hover {
            color: #333333;
        }
        .side-drawer-section {
            margin-bottom: 30px;
        }
        .section-title {
            font-family: 'Barlow Condensed', sans-serif;
            font-size: 14px;
            font-weight: 700;
            color: #999999;
            letter-spacing: 0.1em;
            margin-bottom: 16px;
            margin-top: 0;
            text-transform: uppercase;
        }
        .user-section {
            background-color: #f9f9f9;
            padding: 16px;
            border-radius: 8px;
            border: 1px solid #f0f0f0;
        }
        .drawer-user-info {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 16px;
        }
        .avatar-circle {
            width: 44px;
            height: 44px;
            border-radius: 50%;
            background-color: #9dc93c;
            color: #ffffff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
            font-weight: 700;
        }
        .user-details {
            flex: 1;
        }
        .user-name {
            font-weight: 600;
            color: #333333;
            margin: 0;
            font-size: 15px;
        }
        .user-role {
            font-size: 12px;
            color: #999999;
            margin: 0;
        }
        .drawer-user-actions {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }
        .btn-drawer-action {
            display: flex;
            align-items: center;
            gap: 8px;
            color: #444444;
            text-decoration: none;
            font-size: 14px;
            padding: 8px;
            border-radius: 4px;
            transition: background-color 0.2s, color 0.2s;
        }
        .btn-drawer-action:hover {
            background-color: #f0f0f0;
            color: #000000;
        }
        .drawer-guest-info {
            text-align: center;
            padding: 8px 0;
        }
        .guest-msg {
            font-size: 13px;
            color: #666666;
            margin-bottom: 14px;
        }
        .btn-drawer-login {
            background-color: #333333;
            color: #ffffff;
            border: none;
            padding: 10px 20px;
            border-radius: 4px;
            font-weight: 600;
            cursor: pointer;
            font-size: 13px;
            transition: background-color 0.2s;
            width: 100%;
        }
        .btn-drawer-login:hover {
            background-color: #000000;
        }
        .drawer-link {
            display: flex;
            align-items: center;
            gap: 12px;
            color: #333333;
            text-decoration: none;
            font-size: 16px;
            font-weight: 600;
            padding: 10px 0;
            border-bottom: 1px solid #f9f9f9;
            transition: color 0.2s, padding-left 0.2s;
        }
        .drawer-link:hover {
            color: #9dc93c;
            padding-left: 6px;
        }
        .support-channels {
            display: flex;
            flex-direction: column;
            gap: 12px;
        }
        .channel-btn {
            display: flex;
            align-items: center;
            gap: 12px;
            text-decoration: none;
            color: #333333;
            font-weight: 600;
            font-size: 14px;
            padding: 12px;
            border-radius: 6px;
            border: 1px solid #e0e0e0;
            transition: all 0.2s;
        }
        .channel-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 10px rgba(0,0,0,0.05);
        }
        .zalo-btn {
            background-color: #f4f8ff;
            border-color: #cbdcff;
        }
        .zalo-btn:hover {
            background-color: #e8f1ff;
            border-color: #a3c3ff;
        }
        .messenger-btn {
            background-color: #fff2f9;
            border-color: #ffdceb;
        }
        .messenger-btn:hover {
            background-color: #ffe6f3;
            border-color: #ffb8d9;
        }
        .channel-icon {
            width: 24px;
            height: 24px;
        }
        .side-drawer-footer {
            margin-top: auto;
            border-top: 1px solid #f0f0f0;
            padding-top: 20px;
        }
        .contact-item {
            display: flex;
            flex-direction: column;
            margin-bottom: 12px;
        }
        .contact-item .label {
            font-size: 12px;
            color: #999999;
        }
        .contact-item .value {
            font-size: 15px;
            font-weight: 700;
            color: #333333;
        }
    </style>
</head>
<body class="bg-surface text-on-surface font-body-md antialiased overflow-x-hidden">

<!-- TopNavBar -->
<nav class="flex justify-between items-center px-margin-mobile md:px-margin-desktop py-4 w-full sticky top-0 z-50 bg-white border-b border-outline-variant select-none">
    <!-- Logo -->
    <a href="<%= ctx %>/index.jsp" class="flex items-center gap-2 no-underline">
        <img src="https://upload.wikimedia.org/wikipedia/commons/4/41/Tennis_ball.svg" alt="V-SPORT Icon" class="h-8 w-8 md:h-9 md:w-9 select-none"/>
        <span class="font-['Poppins'] font-bold text-xl md:text-2xl uppercase text-[#111827] tracking-tight">V-SPORT<span class="text-[#afd639]">.</span></span>
    </a>
    
    <!-- Navigation Links -->
    <div class="hidden md:flex gap-6 items-center">
        <a class="text-[#333333] hover:text-[#000000] font-semibold border-b-[2px] border-[#333333] pb-1 font-['Barlow_Condensed'] text-[16px] uppercase tracking-widest transition-colors duration-200" href="<%= ctx %>/index.jsp">Trang chủ</a>
        <a class="text-[#333333] hover:text-[#000000] font-semibold border-b-[2px] border-transparent hover:border-[#333333] pb-1 font-['Barlow_Condensed'] text-[16px] uppercase tracking-widest transition-colors duration-200" href="#">Giới thiệu</a>
        <a class="text-[#333333] hover:text-[#000000] font-semibold border-b-[2px] border-transparent hover:border-[#333333] pb-1 font-['Barlow_Condensed'] text-[16px] uppercase tracking-widest transition-colors duration-200" href="#">Sự kiện</a>
        <a class="text-[#333333] hover:text-[#000000] font-semibold border-b-[2px] border-transparent hover:border-[#333333] pb-1 font-['Barlow_Condensed'] text-[16px] uppercase tracking-widest transition-colors duration-200" href="#">Tin tức</a>
        <a class="text-[#333333] hover:text-[#000000] font-semibold border-b-[2px] border-transparent hover:border-[#333333] pb-1 font-['Barlow_Condensed'] text-[16px] uppercase tracking-widest transition-colors duration-200" href="<%= ctx %>/customer/dat-san">Đặt sân</a>
        <a class="text-[#333333] hover:text-[#000000] font-semibold border-b-[2px] border-transparent hover:border-[#333333] pb-1 font-['Barlow_Condensed'] text-[16px] uppercase tracking-widest transition-colors duration-200" href="#">Liên hệ</a>
    </div>
    
    <!-- Action Icons -->
    <div class="flex items-center gap-6">
        <!-- Cart / Booking Bag -->
        <a href="<%= ctx %>/customer/dat-san" class="relative group flex items-center justify-center w-8 h-8 text-[#333333] hover:text-[#000000] transition-transform hover:scale-105 active:scale-95">
            <svg class="w-[22px] h-[22px]" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" viewBox="0 0 24 24">
                <path d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z"/>
            </svg>
            <span class="absolute -bottom-0.5 -right-0.5 w-[15px] h-[15px] bg-[#9dc93c] rounded-full border border-white flex items-center justify-center text-[9px] font-bold text-white leading-none">0</span>
        </a>
        
        <!-- User Icon -->
        <div class="relative group">
            <button id="header-user-btn" onclick="handleUserClick(this)" class="flex items-center justify-center w-8 h-8 text-[#333333] hover:text-[#000000] transition-transform hover:scale-105 active:scale-95">
                <svg class="w-[20px] h-[20px]" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" viewBox="0 0 24 24">
                    <path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/>
                    <circle cx="12" cy="7" r="4"/>
                </svg>
            </button>
            <% if (loggedInUser != null) { %>
                <!-- Dropdown for Logged-In User -->
                <div id="user-profile-dropdown" class="absolute right-0 top-full mt-2 w-48 bg-white shadow-xl rounded-md overflow-hidden opacity-0 invisible group-hover:opacity-100 group-hover:visible transition-all duration-200 z-50 border border-neutral-100">
                    <div class="px-4 py-2.5 bg-neutral-50 border-b border-neutral-100">
                        <p class="text-xs text-neutral-400">Tài khoản</p>
                        <p class="text-sm font-semibold text-[#0F0F0F] truncate"><%= loggedInUser.getFullName() != null && !loggedInUser.getFullName().isEmpty() ? loggedInUser.getFullName() : loggedInUser.getEmail() %></p>
                    </div>
                    <a href="<%= ctx %>/customer/tai-khoan" class="block px-4 py-2.5 text-sm font-medium text-neutral-700 hover:bg-neutral-50 hover:text-black transition-colors">Tài Khoản</a>
                    <a href="<%= ctx %>/customer/dat-san?openHistory=true" class="block px-4 py-2.5 text-sm font-medium text-neutral-700 hover:bg-neutral-50 hover:text-black transition-colors">Lịch Sử Đặt Sân</a>
                    <a href="<%= ctx %>/dangnhap?action=logout" class="block px-4 py-2.5 text-sm font-semibold text-red-600 hover:bg-red-50 transition-colors border-t border-neutral-100">Đăng Xuất</a>
                </div>
            <% } %>
        </div>
        
        <!-- Search Icon -->
        <button class="flex items-center justify-center w-8 h-8 text-[#333333] hover:text-[#000000] transition-transform hover:scale-105 active:scale-95">
            <svg class="w-[20px] h-[20px]" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" viewBox="0 0 24 24">
                <circle cx="11" cy="11" r="8"></circle>
                <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
            </svg>
        </button>
        
        <!-- Nine-dots grid -->
        <button onclick="openSideDrawer()" class="flex items-center justify-center w-8 h-8 text-[#333333] hover:text-[#000000] transition-transform hover:scale-105 active:scale-95">
            <svg class="w-[20px] h-[20px]" fill="currentColor" viewBox="0 0 24 24">
                <rect x="3" y="3" width="4" height="4" rx="0.5" />
                <rect x="10" y="3" width="4" height="4" rx="0.5" />
                <rect x="17" y="3" width="4" height="4" rx="0.5" />
                <rect x="3" y="10" width="4" height="4" rx="0.5" />
                <rect x="10" y="10" width="4" height="4" rx="0.5" />
                <rect x="17" y="10" width="4" height="4" rx="0.5" />
                <rect x="3" y="17" width="4" height="4" rx="0.5" />
                <rect x="10" y="17" width="4" height="4" rx="0.5" />
                <rect x="17" y="17" width="4" height="4" rx="0.5" />
            </svg>
        </button>
    </div>
</nav>

<!-- Hero Section -->
<section class="grid grid-cols-1 md:grid-cols-3 w-full h-[55vh] md:h-[65vh]">
<div class="hidden md:block w-full h-full bg-surface-container">
<img class="w-full h-full object-cover object-center" alt="A focused female tennis player looking to the side, wearing a white sleeveless top, holding a racket over her shoulder. Dark background, professional studio lighting, high contrast." src="https://images.unsplash.com/photo-1622279457486-62dcc4a4db13?q=80&w=800&auto=format&fit=crop"/>
</div>
<div class="w-full h-full bg-primary-container flex flex-col justify-center items-center text-center p-6">
<span class="font-label-lg text-label-lg text-on-surface uppercase mb-3 tracking-widest text-xs md:text-sm">HỆ THỐNG ĐẶT SÂN HÀNG ĐẦU</span>
<h1 class="font-display-lg text-display-lg text-on-surface uppercase mb-6 max-w-xs md:max-w-sm mx-auto text-2xl md:text-3xl lg:text-4xl leading-tight">ĐẶT SÂN THỂ THAO NHANH CHÓNG, TIN CẬY VÀ TIỆN LỢI</h1>
<a class="inline-block bg-on-surface text-surface font-label-lg text-label-lg uppercase py-3 px-6 tracking-widest hover:opacity-90 transition-opacity text-sm" href="<%= ctx %>/customer/dat-san">ĐẶT SÂN NGAY</a>
</div>
<div class="hidden md:block w-full h-full bg-surface-container">
<img class="w-full h-full object-cover object-center" alt="Close up of a tennis player tying white shoelaces on a blue court. Wearing white socks and a pleated skirt. Bright, outdoor daylight, crisp shadows." src="https://images.unsplash.com/photo-1542144566-d4059fc1ae14?q=80&w=800&auto=format&fit=crop"/>
</div>
</section>


<!-- Trust Bar -->
<div class="bg-court-blue text-on-primary py-4 overflow-hidden whitespace-nowrap border-b border-surface">
<div class="flex">
<div class="flex flex-shrink-0 animate-marquee whitespace-nowrap">
<span class="font-label-lg text-label-lg uppercase px-12">ĐẶT SÂN NHANH &bull; GIỮ CHỖ AN TOÀN &bull; THANH TOÁN PAYOS &bull; XÁC NHẬN TỰ ĐỘNG</span>
<span class="font-label-lg text-label-lg uppercase px-12">ĐẶT SÂN NHANH &bull; GIỮ CHỖ AN TOÀN &bull; THANH TOÁN PAYOS &bull; XÁC NHẬN TỰ ĐỘNG</span>
<span class="font-label-lg text-label-lg uppercase px-12">ĐẶT SÂN NHANH &bull; GIỮ CHỖ AN TOÀN &bull; THANH TOÁN PAYOS &bull; XÁC NHẬN TỰ ĐỘNG</span>
<span class="font-label-lg text-label-lg uppercase px-12">ĐẶT SÂN NHANH &bull; GIỮ CHỖ AN TOÀN &bull; THANH TOÁN PAYOS &bull; XÁC NHẬN TỰ ĐỘNG</span>
<span class="font-label-lg text-label-lg uppercase px-12">ĐẶT SÂN NHANH &bull; GIỮ CHỖ AN TOÀN &bull; THANH TOÁN PAYOS &bull; XÁC NHẬN TỰ ĐỘNG</span>
<span class="font-label-lg text-label-lg uppercase px-12">ĐẶT SÂN NHANH &bull; GIỮ CHỖ AN TOÀN &bull; THANH TOÁN PAYOS &bull; XÁC NHẬN TỰ ĐỘNG</span>
<span class="font-label-lg text-label-lg uppercase px-12">ĐẶT SÂN NHANH &bull; GIỮ CHỖ AN TOÀN &bull; THANH TOÁN PAYOS &bull; XÁC NHẬN TỰ ĐỘNG</span>
<span class="font-label-lg text-label-lg uppercase px-12">ĐẶT SÂN NHANH &bull; GIỮ CHỖ AN TOÀN &bull; THANH TOÁN PAYOS &bull; XÁC NHẬN TỰ ĐỘNG</span>
</div>
</div>
</div>

<!-- Partner Logos -->
<div class="w-full bg-white py-12 border-b border-surface-variant px-margin-mobile md:px-margin-desktop select-none">
    <div class="max-w-[95%] xl:max-w-[92%] mx-auto flex flex-col lg:flex-row items-center justify-between gap-8 lg:gap-12">
        <!-- Left Spacer to balance the text on the right and center the logos -->
        <div class="hidden lg:block w-[220px] flex-shrink-0"></div>
        
        <!-- Logos Centered -->
        <div class="flex flex-wrap lg:flex-nowrap items-center justify-center gap-8 xl:gap-12 text-[#cccccc] flex-grow">
            <!-- Deltab -->
            <div class="flex items-center hover:text-[#999999] transition-colors duration-300 cursor-pointer">
                <svg class="h-10 w-auto fill-none stroke-current" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" viewBox="0 0 120 32" xmlns="http://www.w3.org/2000/svg">
                    <path d="M8 6v20 M14 6v20 M14 6h4a10 10 0 0 1 10 10v0a10 10 0 0 1-10 10h-4"/>
                    <text x="38" y="23" font-family="'DM Sans', 'Inter', sans-serif" font-weight="700" font-size="19" fill="currentColor" stroke="none" letter-spacing="-0.03em">Deltab</text>
                </svg>
            </div>
            
            <!-- Tennis Ball -->
            <div class="flex items-center hover:text-[#999999] transition-colors duration-300 cursor-pointer">
                <svg class="h-12 w-12 fill-none stroke-current" stroke-width="2" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
                    <circle cx="16" cy="16" r="13"/>
                    <path d="M10 6 A 13 13 0 0 0 10 26" stroke-width="1.8"/>
                    <path d="M22 6 A 13 13 0 0 1 22 26" stroke-width="1.8"/>
                </svg>
            </div>
            
            <!-- Ausgrid -->
            <div class="flex items-center hover:text-[#999999] transition-colors duration-300 cursor-pointer">
                <svg class="h-10 w-auto fill-none stroke-current" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" viewBox="0 0 130 32" xmlns="http://www.w3.org/2000/svg">
                    <path d="M6 22l6-6-6-6 M12 22l6-6-6-6 M18 22l6-6-6-6"/>
                    <text x="38" y="23" font-family="'DM Sans', 'Inter', sans-serif" font-weight="700" font-size="19" fill="currentColor" stroke="none" letter-spacing="-0.02em">Ausgrid</text>
                </svg>
            </div>
            
            <!-- Crossed Tennis Rackets -->
            <div class="flex items-center hover:text-[#999999] transition-colors duration-300 cursor-pointer">
                <svg class="h-12 w-12 fill-none stroke-current" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">
                    <g transform="translate(16,16) rotate(45) translate(-16,-16)">
                        <path d="M16 19v9"/>
                        <ellipse cx="16" cy="11" rx="4.5" ry="6"/>
                        <path d="M13 11h6 M12.5 8.5h7 M12.5 13.5h7 M16 5v12 M14 6v10 M18 6v10" stroke-width="0.8"/>
                    </g>
                    <g transform="translate(16,16) rotate(-45) translate(-16,-16)">
                        <path d="M16 19v9"/>
                        <ellipse cx="16" cy="11" rx="4.5" ry="6"/>
                        <path d="M13 11h6 M12.5 8.5h7 M12.5 13.5h7 M16 5v12 M14 6v10 M18 6v10" stroke-width="0.8"/>
                    </g>
                </svg>
            </div>
            
            <!-- Quizlet -->
            <div class="flex items-center hover:text-[#999999] transition-colors duration-300 cursor-pointer">
                <svg class="h-10 w-auto" viewBox="0 0 90 32" xmlns="http://www.w3.org/2000/svg">
                    <text x="5" y="23" font-family="'DM Sans', 'Inter', sans-serif" font-weight="700" font-size="21" fill="currentColor" letter-spacing="-0.02em">Quizlet</text>
                </svg>
            </div>
            
            <!-- LEAGO -->
            <div class="flex items-center hover:text-[#999999] transition-colors duration-300 cursor-pointer">
                <svg class="h-10 w-auto fill-none stroke-current" stroke-width="2.5" viewBox="0 0 120 32" xmlns="http://www.w3.org/2000/svg">
                    <text x="5" y="23" font-family="'DM Sans', 'Inter', sans-serif" font-weight="900" font-size="19" fill="currentColor" stroke="none" letter-spacing="0.05em">LEAGO</text>
                    <circle cx="94" cy="16" r="7" stroke-width="2"/>
                    <circle cx="94" cy="16" r="2.5" fill="currentColor" stroke="none"/>
                    <path d="M87 16h14 M94 9v14" stroke-width="1"/>
                </svg>
            </div>
        </div>
        
        <!-- Text -->
        <div class="text-center lg:text-right w-full lg:w-[220px] mt-4 lg:mt-0 flex-shrink-0">
            <h4 class="font-bold text-sm text-[#111111] tracking-wider leading-tight uppercase font-body-md">
                CHECK OUR BEST<br/>CLIENTS AND PARTNERS
            </h4>
        </div>
    </div>
</div>

<!-- Categories Grid -->
<section class="max-w-[95%] xl:max-w-[92%] mx-auto px-margin-mobile md:px-margin-desktop py-16">
<div class="grid grid-cols-2 md:grid-cols-4 gap-8">
<div class="group relative overflow-hidden aspect-[1.15] bg-surface-container cursor-pointer">
<img class="w-full h-full object-cover transition-transform duration-500 group-hover:scale-105" alt="A tennis racket lying on a green grass court with several yellow tennis balls nearby. Bright sunlight." src="https://lh3.googleusercontent.com/aida/AP1WRLvWebT7ZNHs6ZdkCWKS9U-MazznW5ERpv32DFU3jHF_YyUANkNUkRCIcgok_P8A0t0nO9-aswBrwjCbFcneyFuSl1BpKMFkUxH-_z-9oYPFqF13Vtc3_88AM7Kt6Cx-zH0beU9IPzqLhLVBkyeQNzslJ8noEmjOpVsOycOG_sp3fg96phuIWrq3clPldYv_69RBQ1PLSkb5Lnm6qp-TKWHWyTsdLedtuEd_QZMp5LWIJ4jVWdVJHGAgwA"/>
<div class="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent flex items-end p-8">
<div class="flex flex-col transform translate-y-6 group-hover:translate-y-0 transition-transform duration-300 ease-out">
<h3 class="font-bold text-3xl md:text-4xl tracking-widest text-white uppercase font-headline-md">RACKETS</h3>
<span class="text-sm md:text-base tracking-widest font-bold text-white mt-2.5 opacity-0 group-hover:opacity-100 transition-opacity duration-300 flex items-center gap-2 uppercase">
    SHOP NOW <span class="text-lg font-normal">&rarr;</span>
</span>
</div>
</div>
</div>
<div class="group relative overflow-hidden aspect-[1.15] bg-surface-container cursor-pointer">
<img class="w-full h-full object-cover transition-transform duration-500 group-hover:scale-105" alt="A male tennis player running to hit a backhand on a blue hard court. Wearing dark apparel." src="https://lh3.googleusercontent.com/aida/AP1WRLtdxurZ6J7ydy2eP7rqXeqTMhJ1n-EjW8nfWwJkvbGMUi5RQHxU55fmhZVw5i_VnfFg8blm35yCB5KohihuvF_CdHZW5qOmOYHvVhoGdDUSi3M0PuEq3Q2oJHI5tCUSjHY9y798KfWcib0vQwLzjCLMro59hkSvU2rCVsyg9PM9E11U5zoXG8JCUsbT33Ujq-gW11BASrUAf_TJqvj-OzvnYHeWkP79IEyqK_kPfKayIOBOGTGyt6zS_w"/>
<div class="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent flex items-end p-8">
<div class="flex flex-col transform translate-y-6 group-hover:translate-y-0 transition-transform duration-300 ease-out">
<h3 class="font-bold text-3xl md:text-4xl tracking-widest text-white uppercase font-headline-md">APPAREL</h3>
<span class="text-sm md:text-base tracking-widest font-bold text-white mt-2.5 opacity-0 group-hover:opacity-100 transition-opacity duration-300 flex items-center gap-2 uppercase">
    SHOP NOW <span class="text-lg font-normal">&rarr;</span>
</span>
</div>
</div>
</div>
<div class="group relative overflow-hidden aspect-[1.15] bg-surface-container cursor-pointer">
<img class="w-full h-full object-cover transition-transform duration-500 group-hover:scale-105" alt="A female tennis player running on a clay court. View from above." src="https://lh3.googleusercontent.com/aida/AP1WRLsCif0ca5AJK-rv5YXnylO3sQExKc8APL8Q_C-ogNla22Bshc-uTcpSSeHIgnWOgWZWpEhIFxgjTYz748HOgQorLtAgjdyItKzpv1vdCnwUgC7vzVSG2R2wi9OLkEA4S9kTO-jyLOyRATtqAAjqNm_HSHb2b8qb1RZM4-pUOa-06s-ap4FkDdDbfOJnZ1lyflidEJS1VNGvoFAuVjyBsdkOok8NS9rmubEbCeiM9ey564vFFprktPmLRP0"/>
<div class="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent flex items-end p-8">
<div class="flex flex-col transform translate-y-6 group-hover:translate-y-0 transition-transform duration-300 ease-out">
<h3 class="font-bold text-3xl md:text-4xl tracking-widest text-white uppercase font-headline-md">SHOES</h3>
<span class="text-sm md:text-base tracking-widest font-bold text-white mt-2.5 opacity-0 group-hover:opacity-100 transition-opacity duration-300 flex items-center gap-2 uppercase">
    SHOP NOW <span class="text-lg font-normal">&rarr;</span>
</span>
</div>
</div>
</div>
<div class="group relative overflow-hidden aspect-[1.15] bg-surface-container cursor-pointer">
<img class="w-full h-full object-cover transition-transform duration-500 group-hover:scale-105" alt="A yellow tennis ball caught in the black netting of a tennis net. Close up shot." src="https://lh3.googleusercontent.com/aida/AP1WRLsxuq5CEbyLge_0n5xxq6dFz5gcZD_mhi9pDI-6CcMIFHUD_58vqcZsqY8x6lJnQq16-vNHvWyz02q_V1ChrVcajhVFbmWa9Hd2SG6YGQFPgtNlGT6CF5jZIek0mqmH9eYugfV6tA6ZQzyeNl3MTBlS6Hlvhqc3LiNjWO32PTDYBxLWnjkzL8yBf7PQb49cRlPG79pe2I-gIVupqXKgaalQsGKy3sc-AbmA7wGSAbylJ9IaNEkr6Dd1LQ"/>
<div class="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent flex items-end p-8">
<div class="flex flex-col transform translate-y-6 group-hover:translate-y-0 transition-transform duration-300 ease-out">
<h3 class="font-bold text-3xl md:text-4xl tracking-widest text-white uppercase font-headline-md">ACCESSORIES</h3>
<span class="text-sm md:text-base tracking-widest font-bold text-white mt-2.5 opacity-0 group-hover:opacity-100 transition-opacity duration-300 flex items-center gap-2 uppercase">
    SHOP NOW <span class="text-lg font-normal">&rarr;</span>
</span>
</div>
</div>
</div>
</div>
</section>

<!-- Popular Products -->
<section class="max-w-container-max mx-auto px-margin-mobile md:px-margin-desktop py-12 text-center">
<span class="font-label-lg text-label-lg text-on-surface-variant uppercase tracking-widest block mb-2">KHO SÂN CỦA CHÚNG TÔI</span>
<h2 class="font-headline-lg text-headline-lg text-on-surface uppercase mb-16">SÂN PHỔ BIẾN</h2>
<div class="grid grid-cols-2 md:grid-cols-4 gap-x-gutter gap-y-16 text-left">
<!-- Court 1 -->
<div class="group cursor-pointer" onclick="location.href='<%= ctx %>/customer/dat-san'">
<div class="bg-surface-container-low aspect-square mb-6 relative hover-outline transition-shadow">
<img class="w-full h-full object-contain p-8 mix-blend-multiply" alt="Three yellow tennis balls clustered together on a white background." src="https://lh3.googleusercontent.com/aida/AP1WRLuVO6G7WE20o_ncujLDMWXKsYywrZ32bf609snGygLJBbWhr4a9K9wO0f7FDBw8-M63rpMYroxplAvmv8juM3Ex6gpfaRYOIpm5sL8WwKE65VOyO-9FmiJ3naA7Dh4smzfl4RslJ7TSDj6qvTmIZnuQaL2k2w7sYSMtWs08BuonvLoBTcWQTU4YNiRqS-X1zygtVkoq2oMQn2CVdchuv7Ci1Iu2Kd1O6rdLJBpI5x4McvEBXnT_KywCTA"/>
</div>
<div class="text-center">
<h3 class="font-headline-sm text-headline-sm text-on-surface uppercase mb-2">SÂN BÓNG ĐÁ 5 NGƯỜI</h3>
<p class="font-label-lg text-label-lg text-on-surface-variant mb-3">từ 150.000₫/h</p>
<div class="flex justify-center text-primary-container text-sm">
<span>★</span><span>★</span><span>★</span><span>★</span><span>★</span>
</div>
</div>
</div>
<!-- Court 2 -->
<div class="group cursor-pointer" onclick="location.href='<%= ctx %>/customer/dat-san'">
<div class="bg-surface-container-low aspect-square mb-6 relative hover-outline transition-shadow">
<img class="w-full h-full object-contain p-8 mix-blend-multiply" alt="A single Aeropro tennis racket standing upright on a white background." src="https://lh3.googleusercontent.com/aida/AP1WRLttf6-GiVcmloQ8hiZr_nxjiGoONtewcPhpBIu7MAeSbMui8ctDhKX6lFKETpk3KiKui7-0F2ngdheZts6hjynUngH_GNmMnnww6Ad40_Log14q7bnbxwpgVRRjh7XAVKZHzzclIbktzix5DEn9jY0-J2hLatFUo5ZNjc-QhO-NQn-giN4q47sK9c7gDhpaq7mdvXdclcpY-JRItpORAJHWywKemmLgK9nXds4G2Wo3YKvVfMjCdRv7i-Q"/>
</div>
<div class="text-center">
<h3 class="font-headline-sm text-headline-sm text-on-surface uppercase mb-2">SÂN CẦU LÔNG</h3>
<p class="font-label-lg text-label-lg text-on-surface-variant mb-3">từ 80.000₫/h</p>
<div class="flex justify-center text-primary-container text-sm">
<span>★</span><span>★</span><span>★</span><span>★</span><span class="text-surface-variant">★</span>
</div>
</div>
</div>
<!-- Court 3 -->
<div class="group cursor-pointer" onclick="location.href='<%= ctx %>/customer/dat-san'">
<div class="bg-surface-container-low aspect-square mb-6 relative hover-outline transition-shadow">
<img class="w-full h-full object-contain p-8 mix-blend-multiply" alt="A plain light pink cotton baseball cap shown from a three-quarter angle on a white background." src="https://lh3.googleusercontent.com/aida/AP1WRLvYq1xffxGjwYXdEyPHE4NTLz2W5wT_XyOu-Q7vQpswHYOPFX-eVvWXRC29Zw_xBf6sYsBtR-ldPDWL0y56VjJveZd_M0eni2grcqiatszzAsWTq5YsAIWTGa71Wl2oeTITUqpvYiZDKkIYD6xEcVFcd3gH3jI4H6k38X8GP10NI0V_c3-x3ERkzwobl1YTFVXmnUuw7nHQOXcHQ9F2BbXggiToCFBoS-_ve-j5LQbUJ9p-AUYR9p8gRWE"/>
</div>
<div class="text-center">
<h3 class="font-headline-sm text-headline-sm text-on-surface uppercase mb-2">SÂN TENNIS</h3>
<p class="font-label-lg text-label-lg text-on-surface-variant mb-3">từ 120.000₫/h</p>
<div class="flex justify-center text-primary-container text-sm">
<span>★</span><span>★</span><span>★</span><span>★</span><span>★</span>
</div>
</div>
</div>
<!-- Court 4 -->
<div class="group cursor-pointer" onclick="location.href='<%= ctx %>/customer/dat-san'">
<div class="bg-surface-container-low aspect-square mb-6 relative hover-outline transition-shadow">
<img class="w-full h-full object-contain p-8 mix-blend-multiply" alt="A green leather duffel-style sport bag with white handles and piping on a white background." src="https://lh3.googleusercontent.com/aida/AP1WRLu6YoJlJoTRxpeddFZnf6O2IChPVk-2giSUTbtmkzQeSdvqJPuMZAv7Y9q8hVuyxlJurKOU7VKY_qIja4VC6N4L_KEKoYewa4ErfTU1rG9if4NUgUm-MR5ZiKcRBRfid_IXBeaiglZlu6vHtStfUADSItkFYn5WLhLQfqU6Iw1Xs-o2LD3Ak5s0HCzUSzfSRRvbEYteUA_HhnoiG-U4b-zzNCI7tItUdrRr1j-fGH-GUBvf9GyORgzCMdQ"/>
</div>
<div class="text-center">
<h3 class="font-headline-sm text-headline-sm text-on-surface uppercase mb-2">SÂN PICKLEBALL</h3>
<p class="font-label-lg text-label-lg text-on-surface-variant mb-3">từ 100.000₫/h</p>
<div class="flex justify-center text-primary-container text-sm">
<span>★</span><span>★</span><span>★</span><span>★</span><span>★</span>
</div>
</div>
</div>
<!-- Court 5 -->
<div class="group cursor-pointer" onclick="location.href='<%= ctx %>/customer/dat-san'">
<div class="bg-surface-container-low aspect-square mb-6 relative hover-outline transition-shadow">
<img class="w-full h-full object-contain p-8 mix-blend-multiply" alt="A white pleated tennis skirt displayed flat on a white background." src="https://lh3.googleusercontent.com/aida/AP1WRLuyKP6xoMTKdDVOEZO8AFfv5cX_zsh6alzIzPSLn4VqQ6FLIGiFbTRGn3Gb8yeewN6qJ1yCDnmYpxLB0wz_k3WCkcf63DGaVdnSOVnrLomL9eVOjRikOXwgAoMwePOs2G0-8OrqqLwwjLKd-lydWVjIMdFP62zD3J6kX4-T_wpBRQdiFAffd5jv5RLbyE0vQ7VF-ZAOVMK4gShx_DeyXN98zHRKkaYcaIOJHEt8W-sjMdVeIflnMD60iY0"/>
</div>
<div class="text-center">
<h3 class="font-headline-sm text-headline-sm text-on-surface uppercase mb-2">SÂN BÓNG ĐÁ 7 NGƯỜI</h3>
<p class="font-label-lg text-label-lg text-on-surface-variant mb-3">từ 250.000₫/h</p>
<div class="flex justify-center text-primary-container text-sm">
<span>★</span><span>★</span><span>★</span><span>★</span><span>★</span>
</div>
</div>
</div>
<!-- Court 6 -->
<div class="group cursor-pointer" onclick="location.href='<%= ctx %>/customer/dat-san'">
<div class="bg-surface-container-low aspect-square mb-6 relative hover-outline transition-shadow">
<img class="w-full h-full object-contain p-8 mix-blend-multiply" alt="A dark grey nylon tennis racket cover case on a white background." src="https://lh3.googleusercontent.com/aida/AP1WRLsNaqsm4nBpLxEpBx1XgEtMereVCNuHyiL8V7v9PvUVpQm1zaEFNTI9BRrrZKoDfzhA1vlptEkK-UOBCw0DdUAMg0WhYBwahfgl-p-5D3eAVxUMsP9KFwqpoYPdaVKweX-Uij1veYO9uGN_QbZ9XhcapNPuxR22IZUIINAiW3tMvhOXzuJkE3dvocxZ_VSt_1uzo0MIqvltNQI0AIXGtQD0huu4mT_Z0lBzT4DrbOOSpU2sFSVIK7oI2eQ"/>
</div>
<div class="text-center">
<h3 class="font-headline-sm text-headline-sm text-on-surface uppercase mb-2">SÂN FUTSAL</h3>
<p class="font-label-lg text-label-lg text-on-surface-variant mb-3">từ 200.000₫/h</p>
<div class="flex justify-center text-primary-container text-sm">
<span>★</span><span>★</span><span>★</span><span>★</span><span class="text-surface-variant">★</span>
</div>
</div>
</div>
<!-- Court 7 -->
<div class="group cursor-pointer" onclick="location.href='<%= ctx %>/customer/dat-san'">
<div class="bg-surface-container-low aspect-square mb-6 relative hover-outline transition-shadow">
<img class="w-full h-full object-contain p-8 mix-blend-multiply" alt="A sleek black tennis racket standing upright on a white background." src="https://lh3.googleusercontent.com/aida/AP1WRLv-CNo131QzCgX083he__RfyatqoTtPF9_oi68e13kF0u8i13eHMoWtjfE0Kq_pFfzkk2mHjhq2eLXjkXt8Tqtz8YJzkDyZ7Oqah_Y2Z2SeZPRxSjAuVCcRyy8H1CcwzXwWfYPO9XI21-_eW5V2meGn_GJ8bK5XmweYE-JaSnd7CWDnSxdRgBOFtWRu6PQp_5mpQOmdjID0bQkMxcjuJLnFXJ5i0A_a9EP10T2Q"/>
</div>
<div class="text-center">
<h3 class="font-headline-sm text-headline-sm text-on-surface uppercase mb-2">SÂN TENNIS CAO CẤP</h3>
<p class="font-label-lg text-label-lg text-on-surface-variant mb-3">từ 180.000₫/h</p>
<div class="flex justify-center text-primary-container text-sm">
<span>★</span><span>★</span><span>★</span><span>★</span><span>★</span>
</div>
</div>
</div>
<!-- Court 8 -->
<div class="group cursor-pointer" onclick="location.href='<%= ctx %>/customer/dat-san'">
<div class="bg-surface-container-low aspect-square mb-6 relative hover-outline transition-shadow">
<img class="w-full h-full object-contain p-8 mix-blend-multiply" alt="A pair of white running sport sneakers with black accents on a white background." src="https://lh3.googleusercontent.com/aida/AP1WRLvhDmgRuPiNkvTvnJ3evCmAB1SxJ_PrOtNtg4Gfn6pSfojai4MbY195QszHNVgbiL6EMCVtq4KRxFK_JlMqSzrDlkRfci4hY5hKIsUFs6Q-NwmUZAun6d9obxlPYw-xKVQSyf-Iq7CSt9vV3yXDPNx4lNy7-X5t-o_CGCUHJDytYelY9HguPPIzn7Y8Ymm-Dp19nUDHoc7e1ngVmESY7CLTr50fcZxMyjRbt3u3LLeQwtf6TBWEAv3lvg"/>
</div>
<div class="text-center">
<h3 class="font-headline-sm text-headline-sm text-on-surface uppercase mb-2">SÂN CẦU LÔNG CAO CẤP</h3>
<p class="font-label-lg text-label-lg text-on-surface-variant mb-3">từ 110.000₫/h</p>
<div class="flex justify-center text-primary-container text-sm">
<span>★</span><span>★</span><span>★</span><span>★</span><span>★</span>
</div>
</div>
</div>
</div>
<div class="mt-16">
<a class="inline-block bg-primary-container text-on-surface font-label-lg text-label-lg uppercase py-4 px-8 tracking-widest hover:opacity-90 transition-opacity" href="<%= ctx %>/customer/dat-san">XEM TẤT CẢ SÂN</a>
</div>
</section>

<!-- Testimonials -->
<section class="max-w-container-max mx-auto px-margin-mobile md:px-margin-desktop py-20 md:py-24">
<div class="grid grid-cols-1 lg:grid-cols-2 gap-12 lg:gap-20">
<div>
<span class="font-label-lg text-label-lg text-on-surface-variant uppercase tracking-widest block mb-3">VỀ CHÚNG TÔI</span>
<h2 class="font-headline-lg text-headline-lg text-on-surface uppercase mb-10">CẢM NHẬN KHÁCH HÀNG</h2>
<div class="flex gap-3 mb-6" id="testi-avatars">
<button type="button" onclick="vsGoToTesti(0)" data-testi-avatar="0" class="relative w-[72px] h-[72px] rounded-full border-[3px] border-on-surface p-0 cursor-pointer transition-transform">
<img class="w-full h-full rounded-full object-cover" alt="Khách hàng V-SPORT" src="https://lh3.googleusercontent.com/aida-public/AB6AXuCZg3AoA6AEoYuJHVQm8eDr5_KJaEfoJf7IjdPd909yrQ13UzEGmS35rBkMz0NwQOhLroGtgtIorWGaQPbbnP8Xa2XStS-P-cmIL-vqMgEURd0zzwlzz1y_zQlFrySB7HQ4WAPARw_XmR3UaR9FRdrYfaWh80dCqaRmPjz4ORCR9FlkLLTOPsFqacukfbrJz2iMM6VF70MZvJKy90-1vSHtvTC9RXHXAsM2VpPZUyDqTKlwu266YHP3"/>
<span data-testi-badge="0" class="absolute -bottom-1 -left-1 w-6 h-6 rounded-full bg-primary-container text-on-surface text-xs font-bold flex items-center justify-center">&rdquo;</span>
</button>
<button type="button" onclick="vsGoToTesti(1)" data-testi-avatar="1" class="relative w-[72px] h-[72px] rounded-full border-[3px] border-transparent p-0 cursor-pointer opacity-50 scale-90 transition-transform">
<img class="w-full h-full rounded-full object-cover" alt="Khách hàng V-SPORT" src="https://lh3.googleusercontent.com/aida-public/AB6AXuBmu54KJzg42CGnwOVK8JMJBxKSL1NcQEXwiHq8SJYlqu30VIukeHAqKJtjY2bV5lFizEZxFP5u0Whse3W0e15EEvg8mR7tJVkFjIGve73Iruzu4YKLmGeiH66TWo5MtiU4qJHB5TIZm0UL_cxsN-FWl5edcAhb4Zl2iguPsea-dWHZyGX9jFl8o_ZGMUdEkVF9NVCxJ3lVmosITKh75vSmni9xwBGFA0cHwF9nOdWeYEejDRSGoMdm"/>
</button>
<button type="button" onclick="vsGoToTesti(2)" data-testi-avatar="2" class="relative w-[72px] h-[72px] rounded-full border-[3px] border-transparent p-0 cursor-pointer opacity-50 scale-90 transition-transform">
<img class="w-full h-full rounded-full object-cover" alt="Khách hàng V-SPORT" src="https://lh3.googleusercontent.com/aida-public/AB6AXuCv06aMFJYR3sOdfCnuOAUtbt0Te9kIQPzs6DKqRclM1BzX3LmhysNMm2hlM0rzDy8peJBU4ry2QyoGpSsraCkCvwTJj3-x9TYbNr_3-g24eEwE2hPH7P-f5uSTEfpsX8XQc20eZ3PsvmJSuDU5g8thzC-bX2tzkpiRsJvoO4PVrulDkc_bv56QTh_aQgsUUdad5MYauX07tx_B-YdvNqGYBBzlWub22aw_1WM8CkuN37jaLA921-kW"/>
</button>
</div>
<h4 id="testi-name" class="font-label-lg text-label-lg text-on-surface uppercase">NGUYỄN VĂN AN</h4>
<p id="testi-location" class="font-label-md text-label-md text-on-surface-variant">Hà Nội, Việt Nam</p>
</div>
<div class="flex flex-col justify-center">
<div id="testi-quote" class="font-body-lg text-body-lg text-on-surface-variant space-y-4 mb-10">
<p>V-SPORT mang đến giải pháp đặt sân thể thao nhanh chóng, tin cậy và tiện lợi. Với hệ thống đối tác sân bãi rộng khắp toàn quốc cùng quy trình thanh toán tích hợp PayOS thông minh, bạn có thể tự tin đặt lịch giữ chỗ.</p>
<p>Trải nghiệm những trận đấu thắng hoa cùng bạn bè, gia đình — mọi lúc, mọi nơi, chỉ với vài thao tác đơn giản trên V-SPORT.</p>
</div>
<div class="flex items-center gap-2">
<button type="button" onclick="vsTestiPrev()" aria-label="Trước" class="w-11 h-11 rounded-full border border-outline flex items-center justify-center hover:bg-on-surface hover:text-white hover:border-on-surface transition-colors">
<span class="material-symbols-outlined text-[18px]">arrow_back</span>
</button>
<button type="button" onclick="vsTestiNext()" aria-label="Tiếp" class="w-11 h-11 rounded-full border border-outline flex items-center justify-center hover:bg-on-surface hover:text-white hover:border-on-surface transition-colors">
<span class="material-symbols-outlined text-[18px]">arrow_forward</span>
</button>
<div id="testi-dots" class="flex gap-1.5 ml-2">
<span data-testi-dot="0" class="w-1.5 h-1.5 rounded-full bg-on-surface"></span>
<span data-testi-dot="1" class="w-1.5 h-1.5 rounded-full bg-outline-variant"></span>
<span data-testi-dot="2" class="w-1.5 h-1.5 rounded-full bg-outline-variant"></span>
</div>
</div>
</div>
</div>
</section>

<!-- Make Your Game -->
<section class="py-16 md:py-24 text-center overflow-hidden">
<div class="max-w-container-max mx-auto px-margin-mobile">
<h2 class="font-display-lg text-[10vw] leading-none text-on-surface uppercase font-bold tracking-tighter flex items-center justify-center flex-wrap gap-2">
                NÂNG T<span class="inline-block w-[8vw] h-[8vw] mx-1 relative align-middle" style="filter:drop-shadow(0 8px 20px rgba(0,0,0,0.25));">
<svg viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg" class="w-full h-full">
<defs>
<radialGradient id="vsBallBase" cx="40%" cy="35%" r="60%">
<stop offset="0%" stop-color="#d6f040"/>
<stop offset="40%" stop-color="#a8cc00"/>
<stop offset="75%" stop-color="#7aaa00"/>
<stop offset="100%" stop-color="#4d7a00"/>
</radialGradient>
<radialGradient id="vsBallShine" cx="38%" cy="30%" r="35%">
<stop offset="0%" stop-color="rgba(255,255,255,0.55)"/>
<stop offset="100%" stop-color="rgba(255,255,255,0)"/>
</radialGradient>
<radialGradient id="vsBallShadow" cx="55%" cy="65%" r="45%">
<stop offset="0%" stop-color="rgba(0,0,0,0.30)"/>
<stop offset="100%" stop-color="rgba(0,0,0,0)"/>
</radialGradient>
<clipPath id="vsBallClip">
<circle cx="100" cy="100" r="96"/>
</clipPath>
</defs>
<circle cx="100" cy="100" r="96" fill="url(#vsBallBase)"/>
<g clip-path="url(#vsBallClip)" fill="none" stroke="white" stroke-width="5.5" stroke-linecap="round" opacity="0.75">
<path d="M 60 30 Q 110 80 60 130 Q 30 160 55 185"/>
<path d="M 140 30 Q 90 80 140 130 Q 170 160 145 185"/>
</g>
<circle cx="100" cy="100" r="96" fill="url(#vsBallShadow)"/>
<ellipse cx="78" cy="68" rx="28" ry="18" fill="url(#vsBallShine)" transform="rotate(-30 78 68)"/>
</svg>
</span>ẦM GAME
            </h2>
</div>
</section>

<!-- Programs -->
<section class="relative bg-gradient-to-br from-[#4a5424] via-[#232a12] to-[#0a0a09] text-white py-20 md:py-24 px-margin-mobile md:px-margin-desktop overflow-hidden">
<div class="relative max-w-[960px] mx-auto text-center">
<span class="font-label-lg text-label-lg uppercase tracking-widest block mb-3 text-white/85">CHƯƠNG TRÌNH CỦA CHÚNG TÔI</span>
<h2 class="font-headline-lg text-headline-lg uppercase mb-14 text-white">TÌM CHƯƠNG TRÌNH PHÙ HỢP</h2>
<div class="grid grid-cols-2 md:grid-cols-4 gap-gutter text-left">
<a href="<%= ctx %>/customer/dat-san" class="group relative block aspect-[10/14] overflow-hidden">
<img class="w-full h-full object-cover transition-transform duration-500 group-hover:scale-105" alt="Bóng đá 5 người" src="https://images.unsplash.com/photo-1575361204480-aadea25e6e68?auto=format&fit=crop&w=500&q=80"/>
<div class="absolute inset-0 bg-gradient-to-t from-black/60 via-black/5 to-transparent"></div>
<span class="absolute bottom-4 left-4 right-4 font-headline-sm text-[18px] font-bold uppercase text-white leading-tight">Bóng Đá 5 Người</span>
</a>
<a href="<%= ctx %>/customer/dat-san" class="group relative block aspect-[10/14] overflow-hidden">
<img class="w-full h-full object-cover transition-transform duration-500 group-hover:scale-105" alt="Cầu lông" src="https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?auto=format&fit=crop&w=500&q=80"/>
<div class="absolute inset-0 bg-gradient-to-t from-black/60 via-black/5 to-transparent"></div>
<span class="absolute bottom-4 left-4 right-4 font-headline-sm text-[18px] font-bold uppercase text-white leading-tight">Cầu Lông</span>
</a>
<a href="<%= ctx %>/customer/dat-san" class="group relative block aspect-[10/14] overflow-hidden">
<img class="w-full h-full object-cover transition-transform duration-500 group-hover:scale-105" alt="Tennis thiếu nhi" src="https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0?auto=format&fit=crop&w=500&q=80"/>
<div class="absolute inset-0 bg-gradient-to-t from-black/60 via-black/5 to-transparent"></div>
<span class="absolute bottom-4 left-4 right-4 font-headline-sm text-[18px] font-bold uppercase text-white leading-tight">Tennis Thiếu Nhi</span>
</a>
<a href="<%= ctx %>/customer/dat-san" class="group relative block aspect-[10/14] overflow-hidden">
<img class="w-full h-full object-cover transition-transform duration-500 group-hover:scale-105" alt="Nhóm riêng tư" src="https://images.unsplash.com/photo-1554068865-24cecd4e34b8?auto=format&fit=crop&w=500&q=80"/>
<div class="absolute inset-0 bg-gradient-to-t from-black/60 via-black/5 to-transparent"></div>
<span class="absolute bottom-4 left-4 right-4 font-headline-sm text-[18px] font-bold uppercase text-white leading-tight">Nhóm Riêng Tư</span>
</a>
</div>
<a href="<%= ctx %>/customer/dat-san" class="inline-block bg-primary-container text-on-surface font-label-lg text-label-lg uppercase py-4 px-10 tracking-widest hover:opacity-90 transition-opacity mt-14">THAM GIA NGAY</a>
</div>
</section>

<!-- News -->
<section class="relative bg-gradient-to-br from-[#4a5424] via-[#232a12] to-[#0a0a09] text-white py-20 md:py-24 px-margin-mobile md:px-margin-desktop border-t border-white/10 overflow-hidden">
<div class="relative max-w-[1180px] mx-auto text-center">
<span class="font-label-lg text-label-lg uppercase tracking-widest block mb-3 text-white/85">TIN TỨC</span>
<h2 class="font-headline-lg text-headline-lg uppercase mb-14 text-white">TIN TỨC NỔI BẬT</h2>
<div class="grid grid-cols-1 md:grid-cols-3 gap-gutter text-left">
<article class="bg-white text-on-surface flex flex-col">
<div class="p-6 pb-4">
<p class="flex items-center gap-2 font-label-md text-label-md text-on-surface-variant mb-3"><span class="font-bold uppercase text-on-surface">Nổi Bật</span><i class="not-italic text-outline-variant">&middot;</i><time datetime="2026-07-08">08/07/2026</time></p>
<h3 class="font-headline-sm text-headline-sm uppercase leading-tight min-h-[2.3em]">5 Bài Tập Giúp Bạn Bứt Tốc Trên Sân Cầu Lông</h3>
</div>
<div class="aspect-square overflow-hidden">
<img class="w-full h-full object-cover" alt="Cầu lông" loading="lazy" src="https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?auto=format&fit=crop&w=600&q=80"/>
</div>
<a href="#" class="flex items-center gap-2 p-6 font-label-lg text-label-lg uppercase hover:text-primary transition-colors">Đọc thêm <span class="material-symbols-outlined text-[18px]">arrow_forward</span></a>
</article>
<article class="bg-white text-on-surface flex flex-col">
<div class="p-6 pb-4">
<p class="flex items-center gap-2 font-label-md text-label-md text-on-surface-variant mb-3"><span class="font-bold uppercase text-on-surface">Nổi Bật</span><i class="not-italic text-outline-variant">&middot;</i><time datetime="2026-07-05">05/07/2026</time></p>
<h3 class="font-headline-sm text-headline-sm uppercase leading-tight min-h-[2.3em]">Vì Sao Pickleball Đang Phủ Sóng Khắp Việt Nam?</h3>
</div>
<div class="aspect-square overflow-hidden">
<img class="w-full h-full object-cover" alt="Pickleball" loading="lazy" src="https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0?auto=format&fit=crop&w=600&q=80"/>
</div>
<a href="#" class="flex items-center gap-2 p-6 font-label-lg text-label-lg uppercase hover:text-primary transition-colors">Đọc thêm <span class="material-symbols-outlined text-[18px]">arrow_forward</span></a>
</article>
<article class="bg-white text-on-surface flex flex-col">
<div class="p-6 pb-4">
<p class="flex items-center gap-2 font-label-md text-label-md text-on-surface-variant mb-3"><span class="font-bold uppercase text-on-surface">Nổi Bật</span><i class="not-italic text-outline-variant">&middot;</i><time datetime="2026-07-02">02/07/2026</time></p>
<h3 class="font-headline-sm text-headline-sm uppercase leading-tight min-h-[2.3em]">Đặt Sân Nhóm: Mẹo Chia Chi Phí Cùng Bạn Bè</h3>
</div>
<div class="aspect-square overflow-hidden">
<img class="w-full h-full object-cover" alt="Đặt sân nhóm" loading="lazy" src="https://images.unsplash.com/photo-1461896836934-ffe607ba8211?auto=format&fit=crop&w=600&q=80"/>
</div>
<a href="#" class="flex items-center gap-2 p-6 font-label-lg text-label-lg uppercase hover:text-primary transition-colors">Đọc thêm <span class="material-symbols-outlined text-[18px]">arrow_forward</span></a>
</article>
</div>
</div>
</section>

<script>
    (function() {
        var vsTestimonials = [
            {
                name: 'NGUYỄN VĂN AN',
                location: 'Hà Nội, Việt Nam',
                quote: [
                    'V-SPORT mang đến giải pháp đặt sân thể thao nhanh chóng, tin cậy và tiện lợi. Với hệ thống đối tác sân bãi rộng khắp toàn quốc cùng quy trình thanh toán tích hợp PayOS thông minh, bạn có thể tự tin đặt lịch giữ chỗ.',
                    'Trải nghiệm những trận đấu thắng hoa cùng bạn bè, gia đình — mọi lúc, mọi nơi, chỉ với vài thao tác đơn giản trên V-SPORT.'
                ]
            },
            {
                name: 'TRẦN THỊ BÍCH',
                location: 'TP. Hồ Chí Minh, Việt Nam',
                quote: [
                    'Đặt sân trên V-SPORT cực kỳ đơn giản, chỉ mất vài phút là xong. Giao diện thân thiện, thanh toán PayOS an toàn và xác nhận tức thì.',
                    'Tôi đã giới thiệu cho cả nhóm bạn cùng dùng và ai cũng hài lòng với trải nghiệm đặt sân tiện lợi này.'
                ]
            },
            {
                name: 'LÊ MINH TUẤN',
                location: 'Đà Nẵng, Việt Nam',
                quote: [
                    'Ứng dụng V-SPORT giúp tôi tiết kiệm rất nhiều thời gian khi đặt sân cầu lông cuối tuần. Hệ thống luôn cập nhật lịch sân theo thời gian thực.',
                    'Dịch vụ hỗ trợ khách hàng nhiệt tình, chuyên nghiệp. Rất đáng để trải nghiệm!'
                ]
            }
        ];
        var vsTestiIndex = 0;

        window.vsGoToTesti = function(idx) {
            vsTestiIndex = (idx + vsTestimonials.length) % vsTestimonials.length;
            var t = vsTestimonials[vsTestiIndex];
            document.getElementById('testi-name').textContent = t.name;
            document.getElementById('testi-location').textContent = t.location;
            document.getElementById('testi-quote').innerHTML = t.quote.map(function(p) { return '<p>' + p + '</p>'; }).join('');
            document.querySelectorAll('[data-testi-dot]').forEach(function(dot) {
                var isActive = Number(dot.getAttribute('data-testi-dot')) === vsTestiIndex;
                dot.className = 'w-1.5 h-1.5 rounded-full ' + (isActive ? 'bg-on-surface' : 'bg-outline-variant');
            });
            document.querySelectorAll('[data-testi-avatar]').forEach(function(btn) {
                var isActive = Number(btn.getAttribute('data-testi-avatar')) === vsTestiIndex;
                btn.className = 'relative w-[72px] h-[72px] rounded-full border-[3px] p-0 cursor-pointer transition-transform ' + (isActive ? 'border-on-surface' : 'border-transparent opacity-50 scale-90');
            });
        };
        window.vsTestiPrev = function() { vsGoToTesti(vsTestiIndex - 1); };
        window.vsTestiNext = function() { vsGoToTesti(vsTestiIndex + 1); };
    })();
</script>

<!-- Footer -->
<footer class="bg-on-background dark:bg-surface-container-lowest grid grid-cols-1 md:grid-cols-4 gap-gutter px-margin-mobile md:px-margin-desktop py-16 w-full text-white flat no shadows">
<div>
<h4 class="font-headline-sm text-headline-sm text-primary-fixed uppercase mb-6">CHÀO MỪNG ĐẾN V-SPORT</h4>
<p class="font-body-md text-body-md text-secondary-fixed-dim">Hệ thống đặt sân thể thao hàng đầu Việt Nam. Nhanh chóng, tin cậy và tiện lợi.</p>
</div>
<div>
<h4 class="font-headline-sm text-headline-sm text-primary-fixed uppercase mb-6">VĂN PHÒNG</h4>
<address class="font-body-md text-body-md text-secondary-fixed-dim not-italic space-y-2">
<p>Việt Nam —</p>
<p>123 Nguyễn Trãi, Quận 1,</p>
<p>TP. Hồ Chí Minh</p>
<a class="block text-white hover:text-primary-fixed transition-colors mt-4" href="mailto:support@vsport.vn">support@vsport.vn</a>
<p class="text-white font-bold mt-2">1900 1234</p>
</address>
</div>
<div>
<h4 class="font-headline-sm text-headline-sm text-primary-fixed uppercase mb-6">LIÊN KẾT</h4>
<ul class="font-body-md text-body-md text-secondary-fixed-dim space-y-2">
<li><a class="hover:text-primary-fixed transition-colors" href="<%= ctx %>/index.jsp">Trang Chủ</a></li>
<li><a class="hover:text-primary-fixed transition-colors" href="#">Giới Thiệu</a></li>
<li><a class="hover:text-primary-fixed transition-colors" href="#">Tin Tức</a></li>
<li><a class="hover:text-primary-fixed transition-colors" href="<%= ctx %>/customer/dat-san">Tìm Sân</a></li>
<li><a class="hover:text-primary-fixed transition-colors" href="#">Liên Hệ</a></li>
</ul>
</div>
<div>
<h4 class="font-headline-sm text-headline-sm text-primary-fixed uppercase mb-6">KẾT NỐI</h4>
<ul class="font-body-md text-body-md text-secondary-fixed-dim space-y-2">
<li><a class="hover:text-primary-fixed transition-colors flex items-center gap-2" href="#"><span class="w-4">f</span> Facebook</a></li>
<li><a class="hover:text-primary-fixed transition-colors flex items-center gap-2" href="#"><span class="w-4">𝕏</span> Twitter</a></li>
<li><a class="hover:text-primary-fixed transition-colors flex items-center gap-2" href="#"><span class="w-4">▶</span> YouTube</a></li>
<li><a class="hover:text-primary-fixed transition-colors flex items-center gap-2" href="#"><span class="w-4">In</span> Instagram</a></li>
</ul>
</div>
<div class="col-span-1 md:col-span-4 border-t border-white/10 mt-12 pt-8 flex justify-between items-center text-sm text-secondary-fixed-dim">
<p>V-SPORT © 2025. Bản quyền thuộc về V-SPORT Việt Nam.</p>
<button onclick="window.scrollTo({top:0,behavior:'smooth'})" class="w-10 h-10 border border-white/20 flex items-center justify-center hover:bg-white/10 transition-colors">
<span class="material-symbols-outlined">arrow_upward</span>
</button>
</div>
</footer>

<script>
    window.handleUserClick = function(btn) {
        const isLoggedIn = <%= loggedInUser != null ? "true" : "false" %>;
        if (isLoggedIn) {
            const userDropdown = document.getElementById('user-profile-dropdown');
            if (userDropdown) {
                userDropdown.classList.toggle('opacity-0');
                userDropdown.classList.toggle('invisible');
            }
        } else {
            openAuthModal('login', btn);
        }
    };
    
    // Close dropdown on outside click
    document.addEventListener('click', (e) => {
        const userDropdown = document.getElementById('user-profile-dropdown');
        const userBtn = document.getElementById('header-user-btn');
        if (userDropdown && userBtn && !userDropdown.contains(e.target) && !userBtn.contains(e.target)) {
            userDropdown.classList.add('opacity-0', 'invisible');
        }
    });
</script>

<!-- Right Sidebar Drawer (Offcanvas Menu) -->
<div id="side-drawer" class="side-drawer">
    <div class="side-drawer-overlay" onclick="closeSideDrawer()"></div>
    <div class="side-drawer-content">
        <!-- Close button & Logo -->
        <div class="side-drawer-header">
            <a href="<%= ctx %>/index.jsp" class="side-drawer-logo">
                <img alt="V-SPORT Logo" style="height: 36px;" src="https://lh3.googleusercontent.com/aida/AP1WRLtyy5ngijEjLBX_YOA_Ts3twvpLdTO1-x8HhUbaRE3ayGwxmZqTmMdOPgkSxp3Gnai-ORx2r7qPgrNxy6yk6ztZTBgI1XXVzVEB5bn7AgFWSjBPzfP8R3ugGvn48RYkumfZ6-zQSic5lvBvbn5dnpjKkhbtSwklEmzxIE4-gxeD0915FBcWuBM04fodM4DrJcbESbs2lnyzwC1SmKNI8jNPoXyGnyzZZcXu4snr7JUeBFLdILYATdK4yT4"/>
            </a>
            <button class="side-drawer-close" onclick="closeSideDrawer()">&times;</button>
        </div>

        <!-- User Profile Section -->
        <div class="side-drawer-section user-section">
            <% if (loggedInUser != null) { %>
                <div class="drawer-user-info">
                    <div class="avatar-circle">
                        <%= loggedInUser.getFullName() != null && !loggedInUser.getFullName().isEmpty() ? loggedInUser.getFullName().substring(0, 1).toUpperCase() : loggedInUser.getEmail().substring(0, 1).toUpperCase() %>
                    </div>
                    <div class="user-details">
                        <p class="user-name"><%= loggedInUser.getFullName() != null && !loggedInUser.getFullName().isEmpty() ? loggedInUser.getFullName() : loggedInUser.getEmail() %></p>
                        <p class="user-role">Thành viên</p>
                    </div>
                </div>
                <div class="drawer-user-actions">
                    <a href="<%= ctx %>/customer/tai-khoan" class="btn-drawer-action"><i class="fa-regular fa-user"></i> Chỉnh sửa Profile</a>
                    <a href="<%= ctx %>/customer/dat-san?openHistory=true" class="btn-drawer-action"><i class="fa-regular fa-calendar-check"></i> Lịch sử đặt sân</a>
                </div>
            <% } else { %>
                <div class="drawer-guest-info">
                    <p class="guest-msg">Đăng nhập để xem lịch sử đặt sân và quản lý hồ sơ của bạn.</p>
                    <button class="btn-drawer-login" onclick="closeSideDrawer(); openAuthModal('login')">Đăng Nhập Ngay</button>
                </div>
            <% } %>
        </div>

        <!-- Navigation Menu -->
        <div class="side-drawer-section links-section">
            <h4 class="section-title">TIỆN ÍCH HỆ THỐNG</h4>
            <a href="<%= ctx %>/index.jsp" class="drawer-link"><i class="fa-solid fa-house"></i> Trang Chủ</a>
            <a href="<%= ctx %>/customer/dat-san" class="drawer-link"><i class="fa-solid fa-calendar-days"></i> Tìm Sân Đặt Lịch</a>
            <a href="<%= ctx %>/index.jsp#pricing" class="drawer-link"><i class="fa-solid fa-tags"></i> Bảng Giá Dịch Vụ</a>
        </div>

        <!-- Support Channels (Zalo & Messenger) -->
        <div class="side-drawer-section support-section">
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

        <!-- Footer / Contact Info -->
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
    window.openSideDrawer = function() {
        const drawer = document.getElementById('side-drawer');
        if (drawer) drawer.classList.add('open');
    };
    window.closeSideDrawer = function() {
        const drawer = document.getElementById('side-drawer');
        if (drawer) drawer.classList.remove('open');
    };
</script>

<jsp:include page="/auth/AuthModal.jsp" />
</body>
</html>
