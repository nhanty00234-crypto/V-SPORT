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
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tennis Club – Đặt Sân Tennis Trực Tuyến</title>
    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:ital,wght@0,300;0,400;0,500;0,600;0,700;0,800;1,300;1,400;1,500;1,600;1,700;1,800&family=DM+Sans:ital,opsz,wght@0,9..40,100..1000;1,9..40,100..1000&display=swap" rel="stylesheet">
    <!-- FontAwesome icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Swiper CSS -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/swiper@11/swiper-bundle.min.css">
    <!-- Custom CSS -->
    <style>
/* ==========================================================================
   Tennis Club - Tennis Equipment Store CSS Stylesheet
   ========================================================================== */

/* 1. RESET & INITIAL STYLING */
*, *::before, *::after {
    box-sizing: border-box;
    margin: 0;
    padding: 0;
}

:root {
    /* Color Palette */
    --primary: #AFD639;
    --primary-hover: #AEDB2B;
    --primary-light: rgba(175, 214, 57, 0.1);
    --secondary-blue: #427CF0;
    --secondary-blue-hover: #2763DB;
    --dark: #0F0F0F;
    --light-gray: #F6F5F9;
    --text-muted: #A1A1A1;
    --white: #FFFFFF;
    --border: #E6E4E0;
    --overlay-dark: rgba(0, 0, 0, 0.6);
    
    /* Fonts */
    --font-body: 'DM Sans', sans-serif;
    --font-heading: 'Barlow Condensed', sans-serif;
    
    /* Transitions */
    --transition-fast: 0.2s ease;
    --transition-normal: 0.3s ease;
    --transition-slow: 0.5s cubic-bezier(0.25, 0.46, 0.45, 0.94);
    
    /* Container Widths */
    --container-width: 1290px;
}

html {
    scroll-behavior: smooth;
    font-size: 16px;
    background-color: var(--white);
    color: var(--dark);
    font-family: var(--font-body);
}

body {
    min-height: 100vh;
    line-height: 1.6;
    overflow-x: hidden;
}

body.panel-open {
    overflow: hidden;
}

a {
    color: inherit;
    text-decoration: none;
    transition: var(--transition-fast);
}

button, input, select, textarea {
    font-family: inherit;
    font-size: inherit;
    color: inherit;
    background: none;
    border: none;
    outline: none;
}

button {
    cursor: pointer;
}

img {
    max-width: 100%;
    height: auto;
    display: block;
}

ul {
    list-style: none;
}

.container {
    max-width: var(--container-width);
    margin: 0 auto;
    padding: 0 20px;
}

.text-center {
    text-align: center;
}

/* Skip Link */
.skip-link {
    position: absolute;
    top: -100px;
    left: 20px;
    background: var(--primary);
    color: var(--dark);
    padding: 10px 20px;
    font-family: var(--font-heading);
    font-weight: 600;
    text-transform: uppercase;
    z-index: 9999;
    transition: top var(--transition-fast);
}

.skip-link:focus {
    top: 20px;
}

/* 2. BUTTONS */
.btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    padding: 14px 28px;
    font-family: var(--font-heading);
    font-weight: 600;
    font-size: 14px;
    letter-spacing: 2px;
    text-transform: uppercase;
    border-radius: 50px;
    transition: var(--transition-normal);
    position: relative;
    overflow: hidden;
}

.btn-primary {
    background-color: var(--white);
    color: var(--dark);
    border: 2px solid var(--white);
}

.btn-primary:hover {
    background-color: var(--primary);
    color: var(--white);
    border-color: var(--primary);
}

.btn-outline {
    background-color: transparent;
    color: var(--dark);
    border: 2px solid var(--border);
}

.btn-outline:hover {
    background-color: var(--primary);
    color: var(--white);
    border-color: var(--primary);
}

.btn-black {
    background-color: var(--dark);
    color: var(--white);
    border: 2px solid var(--dark);
}

.btn-black:hover {
    background-color: var(--primary);
    color: var(--white);
    border-color: var(--primary);
}

/* 3. HEADER & NAVIGATION */
.main-header {
    width: 100%;
    background-color: var(--white);
    border-bottom: 1px solid var(--border);
    position: sticky;
    top: 0;
    z-index: 100;
    transition: transform var(--transition-normal);
}

.header-container {
    width: 100%;
    padding: 0 32px;
    height: 90px;
    display: flex;
    align-items: center;
    justify-content: space-between;
}

/* Logo */
.logo-link {
    display: flex;
    align-items: center;
    gap: 10px;
}

.logo-icon {
    width: 48px;
    height: 48px;
    flex: 0 0 auto;
    font-size: 22px;
    color: var(--white);
    background-color: var(--primary);
    border: 2px solid var(--dark);
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
}

.logo-text {
    font-family: var(--font-heading);
    font-weight: 800;
    font-size: 26px;
    text-transform: uppercase;
    letter-spacing: -0.5px;
    color: var(--dark);
}

.logo-text span {
    color: var(--dark);
}

/* Desktop Menu Navigation */
.desktop-nav {
    height: 100%;
}

.main-menu {
    display: flex;
    align-items: center;
    height: 100%;
}

.menu-item {
    position: relative;
    height: 100%;
    display: flex;
    align-items: center;
    padding: 0 18px;
}

.menu-item > a {
    font-family: var(--font-heading);
    font-weight: 600;
    font-size: 15px;
    letter-spacing: 1px;
    text-transform: uppercase;
    color: var(--dark);
    display: flex;
    align-items: center;
    gap: 6px;
    padding: 10px 0;
    position: relative;
}

.menu-item > a:hover,
.menu-item.active > a {
    color: var(--dark) !important;
}

.menu-item > a i {
    font-size: 10px;
    transition: transform var(--transition-fast);
}

/* Menu underline animated effect */
.menu-item > a::after {
    content: '';
    position: absolute;
    bottom: 0;
    left: 0;
    width: 0;
    height: 2px;
    background-color: var(--dark);
    transition: width var(--transition-normal);
}

.menu-item:hover > a::after,
.menu-item.active > a::after {
    width: 100%;
}

.menu-item:hover > a i {
    transform: rotate(180deg);
}

/* Dropdown Menu styling */
.dropdown-menu {
    position: absolute;
    top: 100%;
    left: 0;
    width: 250px;
    background-color: var(--dark);
    border-top: 3px solid var(--primary);
    padding: 15px 0;
    box-shadow: 0 10px 30px rgba(0,0,0,0.15);
    opacity: 0;
    visibility: hidden;
    transform: translateY(15px);
    transition: opacity var(--transition-normal), transform var(--transition-normal), visibility var(--transition-normal);
    z-index: 10;
}

.menu-item:hover .dropdown-menu {
    opacity: 1;
    visibility: visible;
    transform: translateY(0);
}

.dropdown-menu li {
    width: 100%;
}

.dropdown-menu a {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 10px 25px;
    font-family: var(--font-heading);
    font-weight: 500;
    font-size: 14px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    color: var(--text-muted);
}

.dropdown-menu a:hover,
.dropdown-menu a.active {
    color: var(--white);
    background-color: rgba(255,255,255,0.05);
    padding-left: 30px;
}

.badge {
    padding: 2px 6px;
    font-size: 9px;
    font-weight: 700;
    border-radius: 3px;
    text-transform: uppercase;
    margin-left: 8px;
}

.badge-new {
    background-color: var(--primary);
    color: var(--dark);
}

/* Action buttons */
.header-actions {
    display: flex;
    align-items: center;
    gap: 12px;
}

.action-btn {
    width: 44px;
    height: 44px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: var(--dark);
    font-size: 20px;
    position: relative;
    transition: var(--transition-normal);
}

.action-btn:hover {
    color: var(--primary);
}

.auth-trigger-btn {
    background: transparent;
}

.auth-trigger-btn::after {
    content: "";
    position: absolute;
    right: 10px;
    bottom: 10px;
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background: var(--primary);
    border: 2px solid var(--white);
    box-shadow: 0 0 0 2px rgba(175, 214, 57, .18);
}

.header-user-menu {
    position: relative;
    z-index: 30;
}

.header-user-chip {
    min-height: 42px;
    max-width: 250px;
    display: inline-flex;
    align-items: center;
    gap: 9px;
    padding: 5px 10px 5px 5px;
    border: 1px solid #e5e7eb;
    border-radius: 999px;
    background: #ffffff;
    color: var(--dark);
    cursor: pointer;
    box-shadow: 0 2px 8px rgba(17, 24, 39, .05);
    transition: transform var(--transition-normal), box-shadow var(--transition-normal), border-color var(--transition-normal);
}

.header-user-chip:hover,
.header-user-menu.is-open .header-user-chip {
    border-color: #d6dee0;
    box-shadow: 0 4px 12px rgba(17, 24, 39, .08);
}

.header-user-avatar {
    width: 32px;
    height: 32px;
    display: grid;
    place-items: center;
    flex: 0 0 auto;
    border-radius: 50%;
    background: var(--primary-light);
    color: #3f5a1c;
    font-size: 12px;
    font-weight: 700;
    letter-spacing: .02em;
    text-transform: uppercase;
}

.header-user-copy {
    min-width: 0;
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    line-height: 1.1;
}

.header-user-name {
    max-width: 140px;
    overflow: hidden;
    color: #111827;
    font-size: 13px;
    font-weight: 900;
    text-overflow: ellipsis;
    white-space: nowrap;
}

.header-user-role {
    margin-top: 3px;
    color: #6b7280;
    font-size: 10px;
    font-weight: 800;
    letter-spacing: .08em;
    text-transform: uppercase;
}

.header-user-caret {
    color: #9ca3af;
    font-size: 11px;
    transition: transform var(--transition-normal);
}

.header-user-menu.is-open .header-user-caret { transform: rotate(180deg); }

.header-user-dropdown {
    position: absolute;
    top: calc(100% + 10px);
    right: 0;
    width: 270px;
    padding: 10px;
    border: 1px solid #e5e7eb;
    border-radius: 16px;
    background: #ffffff;
    box-shadow: 0 8px 24px rgba(17, 24, 39, .10);
    opacity: 0;
    visibility: hidden;
    transform: translateY(6px);
    transform-origin: top right;
    transition: opacity 180ms ease-out, visibility 180ms ease-out, transform 180ms ease-out;
}

.header-user-menu.is-open .header-user-dropdown {
    opacity: 1;
    visibility: visible;
    transform: translateY(0) scale(1);
}

.header-user-dropdown::before {
    content: "";
    position: absolute;
    right: 26px;
    top: -7px;
    width: 14px;
    height: 14px;
    transform: rotate(45deg);
    border-left: 1px solid rgba(15, 15, 15, .08);
    border-top: 1px solid rgba(15, 15, 15, .08);
    background: #fff;
}

.header-user-summary {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 10px;
    border-radius: 12px;
    background: #f9fafb;
}

.header-user-summary .header-user-avatar {
    width: 42px;
    height: 42px;
    font-size: 15px;
}

.header-user-email {
    max-width: 185px;
    overflow: hidden;
    color: #6b7280;
    font-size: 12px;
    text-overflow: ellipsis;
    white-space: nowrap;
}

.header-user-dropdown-menu {
    display: grid;
    gap: 6px;
    margin-top: 10px;
}

.header-user-menu-label {
    margin: 12px 4px 4px;
    color: #9ca3af;
    font-size: 10px;
    font-weight: 900;
    letter-spacing: .12em;
    text-transform: uppercase;
}

.header-user-dropdown-menu a,
.header-user-dropdown-menu button {
    width: 100%;
    min-height: 38px;
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 0 10px;
    border: 0;
    border-radius: 8px;
    background: transparent;
    color: #111827;
    cursor: pointer;
    font-size: 12.5px;
    font-weight: 600;
    text-align: left;
    text-decoration: none;
    transition: background 150ms ease, color 150ms ease;
}

.header-user-dropdown-menu a:hover,
.header-user-dropdown-menu button:hover {
    background: #f9fafb;
    color: #111827;
}

.header-user-dropdown-menu .is-muted {
    color: #9ca3af;
    cursor: default;
}

.header-user-dropdown-menu .is-muted:hover {
    background: transparent;
    color: #9ca3af;
}

.header-user-dropdown-menu .logout-link {
    margin-top: 4px;
    border-top: 1px solid #f1f2f4;
    border-radius: 0 0 13px 13px;
    color: #d1453a;
}

.header-user-dropdown-menu .logout-link:hover {
    background: #fef2f2;
    color: #b91c1c;
    transform: none;
}

.hamburger-svg {
    transition: transform var(--transition-normal);
}

.action-btn:hover .hamburger-svg {
    transform: rotate(90deg);
}

.mobile-menu-trigger {
    display: none;
}

/* 4. HERO DARK SECTION */
/* Hero Tri-Panel Section — thông số lấy từ Revolution Slider của theme gốc:
   gridheight 864@1920 (45vw), gutter 30px, title 86/84 Barlow Condensed 600 */
.hero-tri-section {
    width: 100%;
    height: min(45vw, 864px);
    padding: min(2.6vw, 50px) 0;
    display: flex;
    gap: min(1.56vw, 30px);
    overflow: hidden;
    background-color: var(--white);
}

.hero-tri-panel {
    flex: 1;
    position: relative;
    overflow: hidden;
}

.hero-tri-panel--left {
    animation: heroTriRise 1s cubic-bezier(0.215, 0.61, 0.355, 1) 0.08s both;
}

.hero-tri-panel--right {
    animation: heroTriRise 1s cubic-bezier(0.215, 0.61, 0.355, 1) 0.84s both;
}

@keyframes heroTriRise {
    from { opacity: 0; transform: translateY(50px); }
    to   { opacity: 1; transform: translateY(0); }
}

.hero-tri-img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    object-position: center top;
    display: block;
}

.hero-tri-panel--middle {
    background-color: var(--primary);
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 40px 5%;
    animation: heroTriMaskUp 1s cubic-bezier(0.215, 0.61, 0.355, 1) 0.59s both;
}

@keyframes heroTriMaskUp {
    from { transform: translateY(120%); }
    to   { transform: translateY(0); }
}

.hero-tri-content {
    text-align: center;
    width: 100%;
}

.hero-tri-label {
    display: block;
    font-family: var(--font-body);
    font-size: clamp(11px, 0.73vw, 14px);
    font-weight: 700;
    line-height: 1.7;
    letter-spacing: 2px;
    text-transform: uppercase;
    color: var(--dark);
    margin-bottom: min(0.73vw, 14px);
    animation: heroTriScaleIn 1s cubic-bezier(0.215, 0.61, 0.355, 1) 0.6s both;
}

.hero-tri-title {
    font-family: var(--font-heading);
    font-size: min(4.48vw, 86px);
    font-weight: 600;
    line-height: 1.02;
    text-transform: uppercase;
    color: var(--dark);
    width: 90%;
    margin: 0 auto min(1.67vw, 32px);
    animation: heroTriScaleIn 1s cubic-bezier(0.215, 0.61, 0.355, 1) 1.03s both;
}

@keyframes heroTriScaleIn {
    from { opacity: 0; transform: scale(0.9); }
    to   { opacity: 1; transform: scale(1); }
}

.hero-tri-btn-mask {
    display: inline-block;
    overflow: hidden;
    vertical-align: top;
}

.hero-tri-btn {
    display: inline-block;
    background-color: var(--white);
    color: var(--dark) !important;
    font-family: var(--font-body);
    font-size: clamp(11px, 0.73vw, 14px);
    font-weight: 500;
    line-height: clamp(42px, 2.81vw, 54px);
    letter-spacing: 1px;
    text-transform: uppercase;
    padding: 0 clamp(32px, 2.6vw, 50px);
    text-decoration: none;
    transition: color var(--transition-normal), background-color var(--transition-normal);
    animation: heroTriBtnUp 1.2s cubic-bezier(0.215, 0.61, 0.355, 1) 1.1s both;
}

@keyframes heroTriBtnUp {
    from { transform: translateY(100%); }
    to   { transform: translateY(0); }
}

.hero-tri-btn:hover {
    background-color: var(--dark);
    color: var(--white) !important;
}

@media (prefers-reduced-motion: reduce) {
    .hero-tri-panel--left,
    .hero-tri-panel--right,
    .hero-tri-panel--middle,
    .hero-tri-label,
    .hero-tri-title,
    .hero-tri-btn {
        animation: none;
    }
}

@media (max-width: 1239px) {
    .hero-tri-section {
        height: min(39.6vw, 570px);
    }
    .hero-tri-title {
        font-size: min(3.89vw, 56px);
        margin-bottom: 26px;
    }
}

/* Theme gốc ẩn 2 panel ảnh trên mobile, chỉ giữ panel xanh */
@media (max-width: 540px) {
    .hero-tri-section {
        height: 530px;
        gap: 0;
    }
    .hero-tri-panel--left,
    .hero-tri-panel--right {
        display: none;
    }
    .hero-tri-title {
        font-size: 60px;
    }
}

/* 7.5 STEPS BOOKING SECTION */
.steps-section {
    padding: 100px 0;
    background-color: var(--white);
}

.steps-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 40px;
    margin-top: 60px;
}

.step-card {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    padding: 40px;
    background-color: var(--light-gray);
    border-radius: 12px;
    transition: var(--transition-normal);
    position: relative;
    overflow: hidden;
}

.step-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.05);
}

.step-num {
    font-family: var(--font-heading);
    font-weight: 800;
    font-size: 64px;
    color: var(--primary);
    opacity: 0.15;
    line-height: 1;
    margin-bottom: 20px;
    transition: var(--transition-normal);
}

.step-card:hover .step-num {
    opacity: 0.3;
    transform: scale(1.1);
}

.step-title {
    font-family: var(--font-heading);
    font-weight: 700;
    font-size: 22px;
    text-transform: uppercase;
    color: var(--dark);
    margin-bottom: 15px;
}

.step-description {
    font-size: 15px;
    color: var(--text-muted);
    line-height: 1.6;
}

/* 4.5 WELCOME SECTION */
.welcome-section {
    padding: 100px 0;
    background-color: var(--white);
}

.welcome-container {
    max-width: var(--container-width);
    margin: 0 auto;
    padding: 0 20px;
    display: grid;
    grid-template-columns: 1.1fr 0.9fr;
    gap: 60px;
    align-items: center;
}

.welcome-images-left {
    position: relative;
    height: 480px;
    display: flex;
    align-items: center;
}

.welcome-img-back {
    width: 65%;
    height: 380px;
    object-fit: cover;
    border-radius: 12px;
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
}

.welcome-img-front {
    width: 55%;
    height: 300px;
    object-fit: cover;
    border-radius: 12px;
    box-shadow: 0 15px 35px rgba(0, 0, 0, 0.15);
    position: absolute;
    right: 20px;
    bottom: 20px;
    border: 8px solid var(--white);
}

.welcome-content-right {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
}

.welcome-hello {
    font-family: var(--font-heading);
    font-weight: 700;
    font-size: 14px;
    letter-spacing: 3px;
    text-transform: uppercase;
    color: var(--primary-hover);
    margin-bottom: 15px;
}

.welcome-title {
    font-family: var(--font-heading);
    font-weight: 700;
    font-size: 44px;
    line-height: 1.15;
    text-transform: uppercase;
    color: var(--dark);
    margin-bottom: 25px;
}

.welcome-desc {
    font-size: 16px;
    color: var(--text-muted);
    line-height: 1.7;
    margin-bottom: 30px;
}

.welcome-features {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 20px;
    width: 100%;
}

.welcome-feature-item {
    display: flex;
    align-items: center;
    gap: 12px;
    font-size: 15px;
    font-weight: 600;
    color: var(--dark);
}

.welcome-feature-item i {
    color: var(--primary-hover);
    font-size: 16px;
}

/* 6. STATS SECTION (REPLACES PARTNERS) */
.stats-section {
    padding: 80px 0;
    background-color: var(--light-gray);
}

.stats-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 30px;
    text-align: center;
}

.stat-item {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 10px;
}

.stat-number {
    font-family: var(--font-heading);
    font-weight: 800;
    font-size: 48px;
    color: var(--dark);
    line-height: 1;
}

.stat-label {
    font-size: 14px;
    font-weight: 700;
    text-transform: uppercase;
    color: var(--text-muted);
    letter-spacing: 1px;
}

/* 7. CATEGORIES GRID */
.categories-section {
    padding: 100px 20px;
    background-color: var(--white);
}

.categories-grid {
    display: grid;
    grid-template-columns: repeat(5, 1fr);
    gap: 20px;
}

.category-card {
    position: relative;
    aspect-ratio: 1.14;
    overflow: hidden;
    border-radius: 8px;
    cursor: pointer;
}

.category-image-placeholder {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background-size: cover;
    background-position: center;
    background-repeat: no-repeat;
    transition: transform var(--transition-slow);
}

.category-card::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: linear-gradient(to bottom, rgba(0,0,0,0.1) 0%, rgba(0,0,0,0.7) 100%);
    z-index: 2;
    transition: opacity var(--transition-normal);
}

.category-content {
    position: absolute;
    bottom: 0;
    left: 0;
    width: 100%;
    padding: 20px;
    z-index: 3;
    display: flex;
    flex-direction: column;
    gap: 6px;
}

.category-name {
    font-family: var(--font-heading);
    font-weight: 600;
    font-size: 22px;
    text-transform: uppercase;
    color: var(--white);
    letter-spacing: 0.5px;
}

.category-link {
    font-family: var(--font-heading);
    font-weight: 600;
    font-size: 12px;
    letter-spacing: 1px;
    text-transform: uppercase;
    color: var(--primary);
    align-self: flex-start;
    position: relative;
}

.category-link::after {
    content: '';
    position: absolute;
    bottom: -3px;
    left: 0;
    width: 100%;
    height: 1px;
    background-color: var(--primary);
    transform: scaleX(0);
    transform-origin: left;
    transition: transform var(--transition-normal);
}

.category-card:hover .category-image-placeholder {
    transform: scale(1.08);
}

.category-card:hover .category-link::after {
    transform: scaleX(1);
}

/* Responsiveness adjustments */
@media (max-width: 1279px) {
    .categories-grid {
        grid-template-columns: repeat(3, 1fr);
    }
}

@media (max-width: 1023px) {
    .hero-tri-section {
        height: min(60.4vw, 470px);
        gap: 10px;
    }
    .hero-tri-title {
        font-size: min(4.88vw, 38px);
    }
    .hero-tri-btn {
        line-height: 46px;
        padding: 0 30px;
        font-size: 12px;
    }
    @media (max-width: 540px) {
        .hero-tri-section {
            height: 530px;
            gap: 0;
        }
        .hero-tri-title {
            font-size: 60px;
        }
    }
    .welcome-container {
        grid-template-columns: 1fr;
        gap: 40px;
    }
    .welcome-images-left {
        height: 380px;
        justify-content: center;
    }
    .welcome-img-back {
        width: 80%;
        height: 320px;
    }
    .welcome-img-front {
        width: 60%;
        height: 220px;
        right: 0;
        bottom: 0;
    }
}

@media (max-width: 767px) {
    .stats-grid {
        grid-template-columns: repeat(2, 1fr);
        gap: 20px;
    }
    .categories-grid {
        grid-template-columns: repeat(2, 1fr);
    }
}

/* 8. SECTION HEADERS (shared by Categories / Steps sections) */
.section-header {
    margin-bottom: 60px;
}

.section-subtitle {
    font-family: var(--font-heading);
    font-weight: 600;
    font-size: 15px;
    letter-spacing: 3px;
    text-transform: uppercase;
    color: var(--text-muted);
}

.section-title {
    font-family: var(--font-heading);
    font-weight: 600;
    font-size: 48px;
    text-transform: uppercase;
    color: var(--dark);
    margin-top: 5px;
}

/* 9. PARALLAX MAKE GAME SECTION */
.make-game-section {
    width: 100vw;
    background-color: var(--light-gray);
    overflow: hidden;
    padding: 80px 0;
}

.parallax-container {
    max-width: var(--container-width);
    margin: 0 auto;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 20px;
    position: relative;
    user-select: none;
}

.parallax-text {
    font-family: var(--font-heading);
    font-weight: 800;
    font-size: 13vw;
    line-height: 0.8;
    text-transform: uppercase;
    letter-spacing: -2px;
}

.stroke-text {
    -webkit-text-stroke: 1.5px var(--dark);
    color: transparent;
}

.fill-text {
    color: var(--dark);
}

.parallax-interactive-element {
    width: 12vw;
    height: 12vw;
    min-width: 100px;
    min-height: 100px;
    max-width: 160px;
    max-height: 160px;
    position: relative;
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 2;
}

.tennis-ball-interactive {
    width: 100%;
    height: 100%;
    border-radius: 50%;
    background-color: #ccce2e;
    background-image: radial-gradient(circle at 35% 35%, #ecff3c, #9ebc1c);
    box-shadow: inset -10px -10px 20px rgba(0,0,0,0.15), 5px 15px 30px rgba(0,0,0,0.15);
    position: relative;
    transition: transform 0.1s ease-out;
}

/* Tennis ball seam design */
.tennis-ball-interactive::before,
.tennis-ball-interactive::after {
    content: '';
    position: absolute;
    border: 3px solid rgba(255, 255, 255, 0.4);
    border-radius: 50%;
    width: 80%;
    height: 80%;
    pointer-events: none;
}

.tennis-ball-interactive::before {
    top: -10%;
    left: -10%;
}

.tennis-ball-interactive::after {
    bottom: -10%;
    right: -10%;
}

/* 10. TESTIMONIALS SECTION */
.testimonials-section {
    padding: 120px 0;
    background-color: var(--white);
}

.testimonial-swiper {
    max-width: 800px;
    margin: 0 auto;
    padding-bottom: 60px;
}

.testimonial-slide {
    text-align: center;
    padding: 0 40px;
}

.testimonial-content p {
    font-family: var(--font-body);
    font-style: italic;
    font-size: 20px;
    line-height: 1.6;
    color: var(--dark);
    margin-bottom: 30px;
}

.testimonial-author {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 4px;
}

.author-name {
    font-family: var(--font-heading);
    font-weight: 600;
    font-size: 18px;
    text-transform: uppercase;
    color: var(--dark);
}

.author-location {
    font-size: 14px;
    color: var(--text-muted);
}

/* Custom Bullet Headshots Pagination */
.testimonial-custom-pagination {
    display: flex;
    justify-content: center;
    gap: 20px;
    margin-top: 40px;
}

.pagination-avatar {
    width: 60px;
    height: 60px;
    border-radius: 50%;
    background-color: var(--light-gray);
    border: 2px solid transparent;
    cursor: pointer;
    transition: var(--transition-normal);
    position: relative;
    overflow: hidden;
}

.pagination-avatar::after {
    content: '';
    position: absolute;
    top: 15%;
    left: 15%;
    width: 70%;
    height: 70%;
    border-radius: 50%;
    background-color: var(--text-muted);
    opacity: 0.3;
}

.pagination-avatar.active {
    border-color: var(--primary);
    transform: scale(1.15);
}

.pagination-avatar.active::after {
    background-color: var(--primary);
    opacity: 0.8;
}

/* 11. VIDEO BANNER SECTION */
.video-banner-section {
    width: 100vw;
    height: 480px;
    position: relative;
    overflow: hidden;
    background-color: var(--dark);
}

.video-bg-placeholder {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: linear-gradient(135deg, #1f232b 0%, #101216 100%);
    opacity: 0.8;
}

.video-overlay {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    z-index: 2;
    display: flex;
    align-items: center;
    justify-content: center;
}

.play-video-btn {
    width: 100px;
    height: 100px;
    border-radius: 50%;
    border: 2px solid var(--white);
    color: var(--white);
    font-family: var(--font-heading);
    font-weight: 600;
    font-size: 14px;
    letter-spacing: 2px;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: var(--transition-normal);
    box-shadow: 0 0 0 0 rgba(255,255,255,0.4);
    animation: pulse-button 2s infinite;
}

.play-video-btn:hover {
    background-color: var(--white);
    color: var(--dark);
    transform: scale(1.08);
}

@keyframes pulse-button {
    0% { box-shadow: 0 0 0 0 rgba(255, 255, 255, 0.4); }
    70% { box-shadow: 0 0 0 15px rgba(255, 255, 255, 0); }
    100% { box-shadow: 0 0 0 0 rgba(255, 255, 255, 0); }
}

/* 12. NEWSLETTER SECTION */
.newsletter-section {
    background-color: var(--white);
    border-bottom: 1px solid var(--border);
    padding: 80px 0;
}

.newsletter-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 40px;
    align-items: center;
}

.newsletter-title {
    font-family: var(--font-heading);
    font-weight: 600;
    font-size: 36px;
    text-transform: uppercase;
    color: var(--dark);
}

.newsletter-form-wrapper {
    display: flex;
    justify-content: flex-end;
}

.newsletter-form {
    width: 100%;
    max-width: 500px;
}

.newsletter-form .input-group {
    display: flex;
    border-bottom: 2px solid var(--dark);
    padding-bottom: 10px;
}

.newsletter-form input {
    flex-grow: 1;
    padding: 10px 5px;
    font-size: 16px;
}

.newsletter-submit-btn {
    font-size: 18px;
    padding: 0 15px;
    transition: transform var(--transition-normal);
}

.newsletter-submit-btn:hover {
    color: var(--primary);
    transform: translateX(4px);
}

/* 13. FOOTER */
.main-footer {
    background-color: var(--dark);
    color: var(--white);
    padding-top: 100px;
}

.footer-widgets {
    padding-bottom: 80px;
}

.footer-grid {
    display: grid;
    grid-template-columns: 1.2fr 1fr 0.8fr 1fr;
    gap: 50px;
}

.footer-col {
    display: flex;
    flex-direction: column;
    gap: 20px;
}

.footer-title {
    font-family: var(--font-heading);
    font-weight: 600;
    font-size: 21px;
    text-transform: uppercase;
    color: var(--white);
    letter-spacing: 0.5px;
}

.footer-text {
    font-size: 15px;
    color: var(--text-muted);
}

.footer-link-underline {
    align-self: flex-start;
    color: var(--white);
    position: relative;
}

.footer-link-underline::after {
    content: '';
    position: absolute;
    bottom: -3px;
    left: 0;
    width: 100%;
    height: 1px;
    background-color: var(--white);
    transform: scaleX(1);
    transform-origin: left;
    transition: transform var(--transition-normal);
}

.footer-link-underline:hover::after {
    transform: scaleX(0);
}

.footer-phone-link {
    font-family: var(--font-heading);
    font-weight: 700;
    font-size: 24px;
    color: var(--primary);
    letter-spacing: 0.5px;
}

.footer-links-list {
    display: flex;
    flex-direction: column;
    gap: 12px;
}

.footer-links-list a {
    color: var(--text-muted);
    font-family: var(--font-heading);
    font-weight: 500;
    font-size: 15px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.footer-links-list a:hover {
    color: var(--white);
    padding-left: 5px;
}

.footer-social-wrap {
    display: flex;
    flex-direction: column;
    gap: 12px;
}

.social-item {
    display: inline-flex;
    align-items: center;
    gap: 12px;
    font-family: var(--font-heading);
    font-weight: 500;
    font-size: 15px;
    text-transform: uppercase;
    color: var(--text-muted);
}

.social-icon-wrapper {
    width: 32px;
    height: 32px;
    border-radius: 50%;
    background-color: rgba(255,255,255,0.05);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 12px;
    transition: var(--transition-normal);
}

.social-item:hover {
    color: var(--white);
}

.social-item:hover .social-icon-wrapper {
    background-color: var(--primary);
    color: var(--dark);
}

.footer-bottom-bar {
    border-top: 1px solid rgba(255,255,255,0.06);
    padding: 35px 20px;
    display: flex;
    justify-content: center;
    align-items: center;
}

.copyright-content {
    font-size: 14px;
    color: var(--text-muted);
}

.footer-tm-link {
    color: var(--white);
    font-weight: 500;
}

.footer-tm-link:hover {
    color: var(--primary);
}

/* Scroll To Top button */
.scroll-to-top {
    position: fixed;
    bottom: 30px;
    right: 30px;
    width: 50px;
    height: 50px;
    border-radius: 50%;
    background-color: var(--dark);
    color: var(--white);
    box-shadow: 0 4px 15px rgba(0,0,0,0.15);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 14px;
    z-index: 90;
    opacity: 0;
    visibility: hidden;
    transform: translateY(15px);
    transition: all var(--transition-normal);
    border: 1px solid rgba(255,255,255,0.1);
}

.scroll-to-top.visible {
    opacity: 1;
    visibility: visible;
    transform: translateY(0);
}

.scroll-to-top:hover {
    background-color: var(--primary);
    color: var(--dark);
    border-color: var(--primary);
}

/* 14. DRAWERS, OVERLAYS, MODALS */
.overlay-backdrop {
    position: fixed;
    top: 0;
    left: 0;
    width: 100vw;
    height: 100vh;
    background-color: var(--overlay-dark);
    z-index: 150;
    opacity: 0;
    visibility: hidden;
    transition: all var(--transition-normal);
}

.overlay-backdrop.active {
    opacity: 1;
    visibility: visible;
}

/* Side Drawers Common */
.drawer-panel {
    position: fixed;
    top: 0;
    right: 0;
    width: 400px;
    height: 100vh;
    background-color: var(--white);
    z-index: 200;
    box-shadow: -10px 0 30px rgba(0,0,0,0.1);
    transform: translate3d(100%, 0, 0);
    transition: transform var(--transition-slow);
    display: flex;
    flex-direction: column;
}

.drawer-panel.active {
    transform: translate3d(0, 0, 0);
}

.drawer-header {
    padding: 30px;
    border-bottom: 1px solid var(--border);
    display: flex;
    align-items: center;
    justify-content: space-between;
}

.drawer-title {
    font-family: var(--font-heading);
    font-weight: 600;
    font-size: 24px;
    text-transform: uppercase;
    color: var(--dark);
}

.drawer-close-btn {
    font-size: 20px;
    color: var(--dark);
    transition: color var(--transition-fast);
}

.drawer-close-btn:hover {
    color: var(--primary);
}

.drawer-body {
    padding: 40px 30px;
    flex-grow: 1;
    overflow-y: auto;
}

/* Info Drawer Content */
.info-drawer {
    background-color: var(--dark);
    color: var(--white);
}

.info-drawer .drawer-header {
    border-bottom: 1px solid rgba(255,255,255,0.06);
}

.info-drawer .drawer-title,
.info-drawer .drawer-close-btn {
    color: var(--white);
}

.info-drawer .logo-text {
    color: var(--white);
}

.drawer-socials {
    display: flex;
    flex-direction: column;
    gap: 16px;
    margin-bottom: 50px;
}

.drawer-socials .social-item {
    font-size: 18px;
}

.drawer-contacts {
    display: flex;
    flex-direction: column;
    gap: 20px;
    border-top: 1px solid rgba(255,255,255,0.06);
    padding-top: 40px;
}

.drawer-contacts .phone-link {
    font-family: var(--font-heading);
    font-weight: 700;
    font-size: 28px;
    color: var(--primary);
}

.drawer-contacts .email-link {
    font-size: 18px;
    color: var(--white);
    align-self: flex-start;
    border-bottom: 1px solid var(--white);
}

.drawer-contacts .email-link:hover {
    color: var(--primary);
    border-color: var(--primary);
}

/* Fullscreen Search Overlay */
.search-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100vw;
    height: 100vh;
    background-color: var(--dark);
    z-index: 300;
    opacity: 0;
    visibility: hidden;
    transition: all var(--transition-normal);
    display: flex;
    flex-direction: column;
}

.search-overlay.active {
    opacity: 1;
    visibility: visible;
}

.search-overlay-header {
    height: 90px;
    display: flex;
    align-items: center;
    justify-content: space-between;
}

.search-overlay-header .logo-text {
    color: var(--white);
}

.search-close-btn {
    font-size: 24px;
    color: var(--white);
    transition: color var(--transition-fast);
}

.search-close-btn:hover {
    color: var(--primary);
}

.search-overlay-body {
    flex-grow: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 0 20px;
}

.search-form-overlay {
    width: 100%;
    max-width: 800px;
    display: flex;
    border-bottom: 2px solid rgba(255,255,255,0.15);
    padding-bottom: 15px;
}

.search-input-field {
    flex-grow: 1;
    font-size: 28px;
    font-family: var(--font-heading);
    font-weight: 500;
    color: var(--white);
    text-transform: uppercase;
}

.search-input-field::placeholder {
    color: rgba(255,255,255,0.3);
}

.search-submit-btn {
    font-size: 24px;
    color: var(--white);
    padding: 0 10px;
    transition: color var(--transition-fast);
}

.search-submit-btn:hover {
    color: var(--primary);
}

/* Video Modal overlay */
.video-modal {
    position: fixed;
    top: 0;
    left: 0;
    width: 100vw;
    height: 100vh;
    background-color: rgba(0,0,0,0.9);
    z-index: 400;
    display: flex;
    align-items: center;
    justify-content: center;
    opacity: 0;
    visibility: hidden;
    transition: all var(--transition-normal);
}

.video-modal.active {
    opacity: 1;
    visibility: visible;
}

.video-modal-container {
    width: 90%;
    max-width: 1000px;
    position: relative;
}

.video-modal-close {
    position: absolute;
    top: -45px;
    right: 0;
    color: var(--white);
    font-size: 28px;
    transition: color var(--transition-fast);
}

.video-modal-close:hover {
    color: var(--primary);
}

.video-aspect-container {
    width: 100%;
    aspect-ratio: 16/9;
}

.video-aspect-container iframe {
    width: 100%;
    height: 100%;
}

/* Mobile Menu Drawer specifics */
.mobile-menu-drawer {
    left: 0;
    right: auto;
    transform: translate3d(-100%, 0, 0);
}

.mobile-menu-drawer.active {
    transform: translate3d(0, 0, 0);
}

.mobile-menu-drawer .drawer-body {
    padding: 30px 20px;
    display: flex;
    flex-direction: column;
    gap: 30px;
}

.mobile-nav-list {
    display: flex;
    flex-direction: column;
    gap: 8px;
}

.mobile-nav-item {
    border-bottom: 1px solid var(--light-gray);
}

.mobile-nav-link {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 12px 5px;
    font-family: var(--font-heading);
    font-weight: 600;
    font-size: 18px;
    text-transform: uppercase;
    color: var(--dark);
}

.mobile-nav-link.active {
    color: var(--primary);
}

.mobile-submenu {
    display: none;
    padding-left: 20px;
    margin-bottom: 10px;
}

.mobile-submenu.active {
    display: block;
}

.mobile-submenu li a {
    display: block;
    padding: 8px 5px;
    font-family: var(--font-heading);
    font-weight: 500;
    font-size: 15px;
    text-transform: uppercase;
    color: var(--text-muted);
}

.mobile-socials-area {
    display: flex;
    gap: 12px;
}

.mobile-socials-area .social-item {
    font-size: 0; /* Hides text, only icons */
}

.mobile-socials-area .social-icon-wrapper {
    width: 40px;
    height: 40px;
    background-color: var(--light-gray);
    color: var(--dark);
    font-size: 15px;
}

.mobile-socials-area .social-item:hover .social-icon-wrapper {
    background-color: var(--primary);
    color: var(--white);
}

.mobile-additional-widgets {
    display: flex;
    flex-direction: column;
    gap: 25px;
    margin-top: 20px;
}

.extra-widget-item {
    display: flex;
    flex-direction: column;
    gap: 8px;
}

.extra-widget-item h6 {
    font-family: var(--font-heading);
    font-weight: 600;
    font-size: 14px;
    letter-spacing: 1px;
    color: var(--text-muted);
    text-transform: uppercase;
}

.extra-widget-item a {
    font-size: 16px;
    font-weight: 500;
    align-self: flex-start;
    border-bottom: 1px solid var(--border);
    padding-bottom: 2px;
}

.extra-widget-item a:hover {
    color: var(--primary);
    border-color: var(--primary);
}

/* ==========================================================================
   15. RESPONSIVENESS (MEDIA QUERIES)
   ========================================================================== */

/* Tablet layout constraints (under 1279px) */
@media (max-width: 1279px) {
    :root {
        --container-width: 960px;
    }
    
    .header-container {
        height: 80px;
    }
    
    .partners-grid-layout {
        grid-template-columns: 1fr;
        gap: 45px;
    }
    
    .partners-heading-area {
        order: -1;
        padding-left: 0;
        text-align: center;
    }
    
    .categories-grid {
        grid-template-columns: repeat(2, 1fr);
        gap: 20px;
    }

    .footer-grid {
        grid-template-columns: repeat(2, 1fr);
        gap: 40px;
    }
}

/* Small screen / Mobile constraints (under 1023px) */
@media (max-width: 1023px) {
    /* Hide desktop navigation menu, show mobile burger */
    .desktop-nav {
        display: none;
    }
    
    .mobile-menu-trigger {
        display: flex;
    }
    
    .action-btn.info-panel-trigger {
        display: none; /* Side panel widget moves to mobile menu */
    }

    .newsletter-grid {
        grid-template-columns: 1fr;
        gap: 25px;
        text-align: center;
    }
    
    .newsletter-form-wrapper {
        justify-content: center;
    }
}

/* Phone constraints (under 767px) */
@media (max-width: 767px) {
    :root {
        --container-width: 100%;
    }
    
    .header-container {
        height: 70px;
        padding: 0 15px;
    }
    
    .logo-text {
        font-size: 22px;
    }
    
    .logo-icon {
        width: 38px;
        height: 38px;
        font-size: 16px;
    }
    
    .hero-section {
        height: 60vh;
        min-height: 400px;
    }
    
    .slide-title {
        font-size: 8vw;
    }
    
    .partners-brands-grid {
        grid-template-columns: repeat(2, 1fr);
    }
    
    .categories-section {
        padding: 0 20px 80px;
    }
    
    .categories-grid {
        grid-template-columns: 1fr;
        gap: 20px;
    }
    
    .parallax-text {
        font-size: 15vw;
    }
    
    .parallax-interactive-element {
        width: 16vw;
        height: 16vw;
    }
    
    .testimonials-section {
        padding: 80px 0;
    }
    
    .testimonial-slide {
        padding: 0 15px;
    }
    
    .testimonial-content p {
        font-size: 17px;
    }
    
    .video-banner-section {
        height: 350px;
    }
    
    .play-video-btn {
        width: 80px;
        height: 80px;
        font-size: 12px;
    }
    
    .newsletter-title {
        font-size: 28px;
    }
    
    .footer-grid {
        grid-template-columns: 1fr;
        gap: 35px;
        text-align: center;
    }
    
    .footer-col {
        align-items: center;
    }
    
    .footer-link-underline {
        align-self: center;
    }
    
    .drawer-panel {
        width: 100vw;
    }
}

/* ==========================================================================
   16. STATUS INDICATORS
   ========================================================================== */
.user-status-dot {
    position: absolute;
    top: 2px;
    right: 2px;
    width: 9px;
    height: 9px;
    border-radius: 50%;
    background-color: #4cd137;
    border: 1px solid var(--white);
    display: none;
}

.user-status-dot.active {
    display: block;
}

/* ==========================================================================
   17. MODAL OVERLAYS COMMON
   ========================================================================== */
.modal-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100vw;
    height: 100vh;
    background-color: var(--overlay-dark);
    z-index: 500;
    display: flex;
    align-items: center;
    justify-content: center;
    opacity: 0;
    visibility: hidden;
    transition: all var(--transition-normal);
}

.modal-overlay.active {
    opacity: 1;
    visibility: visible;
}

.modal-close-btn {
    position: absolute;
    top: 20px;
    right: 20px;
    font-size: 20px;
    color: var(--dark);
    transition: color var(--transition-fast);
}

.modal-close-btn:hover {
    color: var(--primary);
}

/* ==========================================================================
   18. AUTHENTICATION CARD & SUB-VIEWS
   ========================================================================== */
.auth-modal-card {
    background-color: var(--white);
    width: 460px;
    max-width: 90%;
    border-radius: 12px;
    padding: 40px;
    position: relative;
    box-shadow: 0 15px 40px rgba(0,0,0,0.2);
    transform: scale(0.9);
    transition: transform var(--transition-normal);
    max-height: 90vh;
    overflow-y: auto;
}

.modal-overlay.active .auth-modal-card {
    transform: scale(1);
}

.auth-view {
    display: none;
}

.auth-view.active {
    display: block;
}

.auth-heading {
    font-family: var(--font-heading);
    font-weight: 600;
    font-size: 28px;
    text-transform: uppercase;
    color: var(--dark);
    margin-bottom: 25px;
    display: flex;
    flex-direction: column;
}

.auth-heading .sub {
    font-size: 13px;
    color: var(--text-muted);
    font-family: var(--font-body);
    font-weight: 400;
    text-transform: none;
    letter-spacing: 0;
    margin-top: 2px;
}

.auth-form {
    display: flex;
    flex-direction: column;
    gap: 20px;
}

.form-group {
    display: flex;
    flex-direction: column;
    gap: 8px;
    text-align: left;
}

.form-group label {
    font-size: 13px;
    font-weight: 700;
    color: var(--dark);
    text-transform: uppercase;
}

.form-group label .sub {
    font-weight: 400;
    color: var(--text-muted);
    text-transform: none;
}

.form-group input {
    width: 100%;
    padding: 12px 0;
    font-size: 15px;
    border-bottom: 2px solid var(--border);
    transition: border-color var(--transition-fast);
}

.form-group input:focus {
    border-color: var(--primary);
}

.form-actions-row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    font-size: 14px;
}

.remember-me-checkbox {
    display: flex;
    align-items: center;
    gap: 8px;
    cursor: pointer;
}

.forgot-pass-link {
    color: var(--text-muted);
}

.forgot-pass-link:hover {
    color: var(--primary);
}

.btn-full {
    width: 100%;
    margin-top: 10px;
}

/* Social Logins */
.social-auth-separator {
    position: relative;
    text-align: center;
    margin: 25px 0;
}

.social-auth-separator::before {
    content: '';
    position: absolute;
    top: 50%;
    left: 0;
    width: 100%;
    height: 1px;
    background-color: var(--border);
    z-index: 1;
}

.social-auth-separator span {
    position: relative;
    background-color: var(--white);
    padding: 0 15px;
    font-size: 13px;
    color: var(--text-muted);
    z-index: 2;
}

.social-auth-links {
    display: flex;
    gap: 15px;
}

.social-login-btn {
    flex: 1;
    border: 1px solid var(--border);
    padding: 12px;
    border-radius: 6px;
    font-family: var(--font-heading);
    font-weight: 600;
    font-size: 14px;
    letter-spacing: 0.5px;
    text-transform: uppercase;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 10px;
    transition: var(--transition-normal);
}

.social-login-btn.google-btn:hover {
    background-color: #ea4335;
    border-color: #ea4335;
    color: var(--white);
}

.social-login-btn.facebook-btn:hover {
    background-color: #1877f2;
    border-color: #1877f2;
    color: var(--white);
}

.auth-switch-text {
    font-size: 14px;
    text-align: center;
    margin-top: 25px;
    color: var(--text-muted);
}

.auth-switch-text a {
    color: var(--dark);
    font-weight: 700;
}

.auth-switch-text a:hover {
    color: var(--primary);
}

/* Password complexity checker elements */
.password-strength-meter {
    height: 4px;
    width: 100%;
    background-color: var(--border);
    border-radius: 2px;
    overflow: hidden;
    margin-top: -2px;
}

.meter-bar {
    height: 100%;
    width: 0;
    border-radius: 2px;
    transition: width 0.3s ease, background-color 0.3s ease;
}

.meter-bar.weak {
    width: 25%;
    background-color: #ff4757;
}

.meter-bar.medium {
    width: 60%;
    background-color: #ffa502;
}

.meter-bar.strong {
    width: 100%;
    background-color: #2ed573;
}

.password-criteria-list {
    display: flex;
    flex-direction: column;
    gap: 6px;
    margin-top: 10px;
}

.password-criteria-list li {
    font-size: 12px;
    color: var(--text-muted);
    display: flex;
    align-items: center;
    gap: 8px;
    transition: var(--transition-fast);
}

.password-criteria-list li i {
    font-size: 12px;
}

.password-criteria-list li.invalid i {
    color: #ff4757;
}

.password-criteria-list li.valid {
    color: #2ed573;
}

.password-criteria-list li.valid i {
    color: #2ed573;
}

.password-criteria-list li.valid i::before {
    content: "\f058"; /* FontAwesome circle check */
}

.validation-message-error {
    color: #ff4757;
    font-size: 12px;
    margin-top: 5px;
    display: block;
}

.validation-message-success {
    color: #2ed573;
    font-size: 12px;
    margin-top: 5px;
    display: block;
}

/* OTP Digits styling */
.otp-desc {
    font-size: 14px;
    color: var(--text-muted);
    margin-bottom: 25px;
    text-align: center;
}

.otp-inputs-grid {
    display: flex;
    justify-content: space-between;
    gap: 10px;
    margin-bottom: 20px;
}

.otp-digit {
    width: 50px;
    height: 60px;
    border: 2px solid var(--border);
    border-radius: 6px;
    text-align: center;
    font-size: 24px;
    font-weight: 700;
    color: var(--dark);
    transition: border-color var(--transition-fast);
}

.otp-digit:focus {
    border-color: var(--primary);
}

.otp-resend-area {
    margin-top: 25px;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 8px;
}

.timer-text {
    font-size: 14px;
    color: var(--text-muted);
}

.resend-otp-btn {
    font-family: var(--font-heading);
    font-weight: 600;
    font-size: 13px;
    letter-spacing: 0.5px;
    text-transform: uppercase;
    color: var(--dark);
    border-bottom: 1px solid var(--dark);
    padding-bottom: 2px;
    opacity: 0.5;
    cursor: not-allowed;
    transition: var(--transition-fast);
}

.resend-otp-btn.enabled {
    opacity: 1;
    cursor: pointer;
}

.resend-otp-btn.enabled:hover {
    color: var(--primary);
    border-color: var(--primary);
}

#back-to-register-btn i {
    margin-right: 5px;
}

</style>
</head>
<body>

    <!-- Scroll Skip Links -->
    <a class="skip-link" href="#main-content">Skip to content</a>

    <!-- Page Wrapper -->
    <div class="page-wrapper">
        
        <!-- HEADER -->
        <header class="main-header">
            <div class="header-container">
                <!-- Logo -->
                <div class="logo-area">
                    <a href="#" class="logo-link">
                        <span class="logo-icon"><i class="fa-solid fa-table-tennis-paddle-ball"></i></span>
                        <span class="logo-text">V-<span>SPORT</span></span>
                    </a>
                </div>

                <!-- Navigation Menu (Desktop) -->
                <nav class="desktop-nav">
                    <ul class="main-menu">
                        <li class="menu-item active">
                            <a href="#">Trang Chủ</a>
                        </li>
                        <li class="menu-item">
                            <a href="${pageContext.request.contextPath}/customer/dat-san">Tìm Sân</a>
                        </li>
                        <li class="menu-item">
                            <a href="#">Giải Đấu</a>
                        </li>
                        <li class="menu-item">
                            <a href="#">Cộng Đồng</a>
                        </li>
                        <li class="menu-item">
                            <a href="#">Bảng Giá</a>
                        </li>
                    </ul>
                </nav>

                <!-- Actions Area -->
                <div class="header-actions">
                    <!-- User Profile Trigger (Login/Register) -->
                    <% if (loggedInUser == null) { %>
                    <button class="action-btn auth-trigger-btn" type="button" aria-label="Đăng nhập hoặc đăng ký" id="header-user-btn" onclick="if (window.openAuthModal) openAuthModal('login', this)">
                        <i class="fa-regular fa-user"></i>
                    </button>
                    <% } else {
                        String displayName = loggedInUser.getFullName() != null && !loggedInUser.getFullName().trim().isEmpty()
                                ? loggedInUser.getFullName().trim()
                                : loggedInUser.getUsername();
                        String emailText = loggedInUser.getEmail() != null && !loggedInUser.getEmail().trim().isEmpty()
                                ? loggedInUser.getEmail().trim()
                                : loggedInUser.getUsername();
                        String roleLabel = "Customer";
                        if (loggedInUser.getRoleId() == 1) roleLabel = "Admin";
                        else if (loggedInUser.getRoleId() == 2) roleLabel = "Manager";
                        else if (loggedInUser.getRoleId() == 4 || loggedInUser.getRoleId() == 5) roleLabel = "Staff";
                        String initials = "U";
                        if (displayName != null && !displayName.trim().isEmpty()) {
                            String[] parts = displayName.trim().split("\\s+");
                            if (parts.length >= 2) initials = (parts[0].substring(0, 1) + parts[parts.length - 1].substring(0, 1)).toUpperCase();
                            else initials = parts[0].substring(0, 1).toUpperCase();
                        }
                    %>
                    <div class="header-user-menu" id="header-user-menu">
                        <button class="header-user-chip" type="button" id="header-user-chip" aria-haspopup="true" aria-expanded="false" title="<%= displayName %>">
                            <span class="header-user-avatar"><%= initials %></span>
                            <span class="header-user-copy">
                                <span class="header-user-name"><%= displayName %></span>
                                <span class="header-user-role"><%= roleLabel %></span>
                            </span>
                            <i class="fa-solid fa-chevron-down header-user-caret"></i>
                        </button>
                        <div class="header-user-dropdown" role="menu" aria-labelledby="header-user-chip">
                            <div class="header-user-summary">
                                <span class="header-user-avatar"><%= initials %></span>
                                <span class="header-user-copy">
                                    <span class="header-user-name"><%= displayName %></span>
                                    <span class="header-user-email"><%= emailText %></span>
                                </span>
                            </div>
                            <div class="header-user-dropdown-menu">
                                <div class="header-user-menu-label">Tài khoản</div>
                                <button class="is-muted" type="button" role="menuitem" title="Chưa có trang hồ sơ customer GET riêng trong project"><i class="fa-regular fa-id-card"></i>Thông tin tài khoản</button>
                                <a href="<%= request.getContextPath() %>/customer/dat-san?openHistory=true" role="menuitem"><i class="fa-regular fa-calendar-check"></i>Lịch sử đặt sân</a>
                                <div class="header-user-menu-label">Phiên đăng nhập</div>
                                <a class="logout-link" href="<%= request.getContextPath() %>/logout" role="menuitem"><i class="fa-solid fa-right-from-bracket"></i>Đăng xuất</a>
                            </div>
                        </div>
                    </div>
                    <% } %>
                    <!-- Search Trigger -->
                    <button class="action-btn search-trigger" aria-label="Open Search">
                        <i class="fa-solid fa-magnifying-glass"></i>
                    </button>
                    <!-- Info Panel Toggle -->
                    <button class="action-btn info-panel-trigger" aria-label="Open Info Panel">
                        <svg class="hamburger-svg" xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 21 21">
                            <g fill="currentColor">
                                <circle cx="2.5" cy="2.5" r="2"></circle>
                                <circle cx="10.5" cy="2.5" r="2"></circle>
                                <circle cx="18.5" cy="2.5" r="2"></circle>
                                <circle cx="2.5" cy="10.5" r="2"></circle>
                                <circle cx="10.5" cy="10.5" r="2"></circle>
                                <circle cx="18.5" cy="10.5" r="2"></circle>
                                <circle cx="2.5" cy="18.5" r="2"></circle>
                                <circle cx="10.5" cy="18.5" r="2"></circle>
                                <circle cx="18.5" cy="18.5" r="2"></circle>
                            </g>
                        </svg>
                    </button>
                    <!-- Mobile Hamburger Button -->
                    <button class="action-btn mobile-menu-trigger" aria-label="Open Menu">
                        <i class="fa-solid fa-bars"></i>
                    </button>
                </div>
            </div>
        </header>

        <!-- MAIN CONTENT AREA -->
        <main id="main-content">
            
            <!-- HERO DARK SECTION -->
            <section class="hero-tri-section">
                <!-- Left Panel: Action photo -->
                <div class="hero-tri-panel hero-tri-panel--left">
                    <img class="hero-tri-img" src="${pageContext.request.contextPath}/resources/436417.jpg" alt="Vận động viên thi đấu">
                </div>

                <!-- Middle Panel: CTA -->
                <div class="hero-tri-panel hero-tri-panel--middle">
                    <div class="hero-tri-content">
                        <span class="hero-tri-label">Đặt Sân Thể Thao</span>
                        <h1 class="hero-tri-title">Tìm Sân Phù Hợp Đặt Lịch Nhanh Chóng</h1>
                        <span class="hero-tri-btn-mask"><a href="${pageContext.request.contextPath}/customer/dat-san" class="hero-tri-btn">Đặt Sân Ngay</a></span>
                    </div>
                </div>

                <!-- Right Panel: Second photo -->
                <div class="hero-tri-panel hero-tri-panel--right">
                    <img class="hero-tri-img" src="${pageContext.request.contextPath}/resources/velocity_hero_bg.png" alt="Sân thể thao">
                </div>
            </section>

            <!-- WELCOME SECTION -->
            <section class="welcome-section" id="welcome-section">
                <div class="welcome-container">
                    <!-- Left: Overlapping Images -->
                    <div class="welcome-images-left">
                        <img class="welcome-img-back" src="${pageContext.request.contextPath}/resources/hinh-nen-bong-da-thumb.jpg" alt="Sân bóng đá">
                        <img class="welcome-img-front" src="${pageContext.request.contextPath}/resources/velocity_hero_bg.png" alt="Người chơi thể thao">
                    </div>
                    <!-- Right: Content -->
                    <div class="welcome-content-right">
                        <span class="welcome-hello">Chào mừng đến với V-SPORT</span>
                        <h2 class="welcome-title">Hệ thống đặt sân hàng đầu dành cho bạn</h2>
                        <p class="welcome-desc">
                            V-SPORT mang đến giải pháp đặt sân thể thao nhanh chóng, tin cậy và tiện lợi. Với hệ thống đối tác sân bãi rộng khắp trên toàn quốc cùng quy trình thanh toán tích hợp PayOS thông minh, bạn có thể tự tin đặt lịch giữ chỗ và trải nghiệm những trận đấu thăng hoa cùng bạn bè, gia đình.
                        </p>
                        <div class="welcome-features">
                            <div class="welcome-feature-item"><i class="fa-solid fa-circle-check"></i>Đặt chỗ nhanh trong 30s</div>
                            <div class="welcome-feature-item"><i class="fa-solid fa-circle-check"></i>Thanh toán PayOS bảo mật</div>
                            <div class="welcome-feature-item"><i class="fa-solid fa-circle-check"></i>Hủy lịch linh hoạt</div>
                            <div class="welcome-feature-item"><i class="fa-solid fa-circle-check"></i>Hỗ trợ 24/7</div>
                        </div>
                    </div>
                </div>
            </section>

            <!-- MARQUEE STRIP -->
            <section class="marquee-section">
                <div class="marquee-wrap">
                    <div class="marquee-content">
                        <span>ĐẶT SÂN NHANH &bull; GIỮ CHỖ AN TOÀN &bull; THANH TOÁN PAYOS &bull; XÁC NHẬN TỰ ĐỘNG</span>
                        <span>&nbsp;&nbsp;&bull;&nbsp;&nbsp;</span>
                        <span>ĐẶT SÂN NHANH &bull; GIỮ CHỖ AN TOÀN &bull; THANH TOÁN PAYOS &bull; XÁC NHẬN TỰ ĐỘNG</span>
                        <span>&nbsp;&nbsp;&bull;&nbsp;&nbsp;</span>
                        <span>ĐẶT SÂN NHANH &bull; GIỮ CHỖ AN TOÀN &bull; THANH TOÁN PAYOS &bull; XÁC NHẬN TỰ ĐỘNG</span>
                        <span>&nbsp;&nbsp;&bull;&nbsp;&nbsp;</span>
                        <span>ĐẶT SÂN NHANH &bull; GIỮ CHỖ AN TOÀN &bull; THANH TOÁN PAYOS &bull; XÁC NHẬN TỰ ĐỘNG</span>
                        <span>&nbsp;&nbsp;&bull;&nbsp;&nbsp;</span>
                    </div>
                </div>
            </section>

            <!-- STATS SECTION -->
            <section class="stats-section">
                <div class="container">
                    <div class="stats-grid">
                        <div class="stat-item">
                            <span class="stat-number">3K+</span>
                            <span class="stat-label">Người chơi</span>
                        </div>
                        <div class="stat-item">
                            <span class="stat-number">60</span>
                            <span class="stat-label">Sân khả dụng</span>
                        </div>
                        <div class="stat-item">
                            <span class="stat-number">8K+</span>
                            <span class="stat-label">Lượt đặt thành công</span>
                        </div>
                        <div class="stat-item">
                            <span class="stat-number">12K+</span>
                            <span class="stat-label">Thành viên</span>
                        </div>
                    </div>
                </div>
            </section>

            <!-- CATEGORIES SECTION -->
            <section class="categories-section container">
                <div class="section-header text-center">
                    <span class="section-subtitle">Danh mục thể thao</span>
                    <h2 class="section-title">Chọn môn thể thao bạn muốn chơi</h2>
                </div>
                <div class="categories-grid">
                    <!-- Category Item 1: Bóng đá -->
                    <div class="category-card" onclick="location.href='${pageContext.request.contextPath}/customer/dat-san'">
                        <div class="category-image-placeholder" style="background-image: url('${pageContext.request.contextPath}/resources/hinh-nen-bong-da-7.png');"></div>
                        <div class="category-content">
                            <h4 class="category-name">Bóng đá</h4>
                            <span class="category-link">Đặt Sân Ngay</span>
                        </div>
                    </div>
                    <!-- Category Item 2: Cầu lông (chưa có ảnh riêng trong project — dùng placeholder gradient) -->
                    <div class="category-card" onclick="location.href='${pageContext.request.contextPath}/customer/dat-san'">
                        <div class="category-image-placeholder" style="background-image: linear-gradient(135deg, #14210a 0%, #427CF0 100%);"></div>
                        <div class="category-content">
                            <h4 class="category-name">Cầu lông</h4>
                            <span class="category-link">Đặt Sân Ngay</span>
                        </div>
                    </div>
                    <!-- Category Item 3: Tennis -->
                    <div class="category-card" onclick="location.href='${pageContext.request.contextPath}/customer/dat-san'">
                        <div class="category-image-placeholder" style="background-image: url('${pageContext.request.contextPath}/resources/436417.jpg');"></div>
                        <div class="category-content">
                            <h4 class="category-name">Tennis</h4>
                            <span class="category-link">Đặt Sân Ngay</span>
                        </div>
                    </div>
                    <!-- Category Item 4: Pickleball (chưa có ảnh riêng trong project — dùng placeholder gradient) -->
                    <div class="category-card" onclick="location.href='${pageContext.request.contextPath}/customer/dat-san'">
                        <div class="category-image-placeholder" style="background-image: linear-gradient(135deg, #0F0F0F 0%, #AFD639 100%);"></div>
                        <div class="category-content">
                            <h4 class="category-name">Pickleball</h4>
                            <span class="category-link">Đặt Sân Ngay</span>
                        </div>
                    </div>
                    <!-- Category Item 5: Bóng bàn (chưa có ảnh riêng trong project — dùng placeholder gradient) -->
                    <div class="category-card" onclick="location.href='${pageContext.request.contextPath}/customer/dat-san'">
                        <div class="category-image-placeholder" style="background-image: linear-gradient(135deg, #1a1a1a 0%, #6b8f1f 100%);"></div>
                        <div class="category-content">
                            <h4 class="category-name">Bóng bàn</h4>
                            <span class="category-link">Đặt Sân Ngay</span>
                        </div>
                    </div>
                </div>
            </section>

            <!-- STEPS SECTION -->
            <section class="steps-section container">
                <div class="section-header text-center">
                    <span class="section-subtitle">Quy trình đơn giản</span>
                    <h2 class="section-title">Đặt sân trong 3 bước</h2>
                </div>
                <div class="steps-grid">
                    <!-- Step 1 -->
                    <div class="step-card">
                        <span class="step-num">01</span>
                        <h3 class="step-title">Chọn môn thể thao</h3>
                        <p class="step-description">Lựa chọn bộ môn bạn mong muốn: Bóng đá, Cầu lông, Tennis, Pickleball hoặc Bóng bàn phù hợp với sở thích của bạn.</p>
                    </div>
                    <!-- Step 2 -->
                    <div class="step-card">
                        <span class="step-num">02</span>
                        <h3 class="step-title">Lựa chọn sân & giờ</h3>
                        <p class="step-description">Tìm kiếm các sân đấu khả dụng gần nhất, lựa chọn khung giờ lý tưởng và đặt lịch giữ chỗ giữ sân ngay lập tức.</p>
                    </div>
                    <!-- Step 3 -->
                    <div class="step-card">
                        <span class="step-num">03</span>
                        <h3 class="step-title">Thanh toán & Chơi</h3>
                        <p class="step-description">Thanh toán an toàn, nhanh chóng qua cổng PayOS, nhận mã xác nhận đặt sân qua email và sẵn sàng ra sân tỏa sáng.</p>
                    </div>
                </div>
            </section>

            <!-- MAKE YOUR GAME PARALLAX SECTION -->
            <section class="make-game-section">
                <div class="parallax-container">
                    <span class="parallax-text stroke-text">Nâng tầm</span>
                    <div class="parallax-interactive-element">
                        <div class="tennis-ball-interactive"></div>
                    </div>
                    <span class="parallax-text fill-text">trận đấu</span>
                </div>
            </section>

            <!-- TESTIMONIALS SLIDER SECTION -->
            <section class="testimonials-section">
                <div class="swiper testimonial-swiper">
                    <div class="swiper-wrapper">
                        <!-- Testimonial 1 -->
                        <div class="swiper-slide testimonial-slide">
                            <div class="testimonial-content">
                                <p>"Đặt sân chỉ mất chưa đầy một phút, thanh toán qua PayOS cực nhanh và luôn có mã xác nhận rõ ràng. Không còn cảnh gọi điện hỏi sân trống nữa."</p>
                                <div class="testimonial-author">
                                    <h4 class="author-name">Minh Khang</h4>
                                    <span class="author-location">Quận 7, TP.HCM</span>
                                </div>
                            </div>
                        </div>
                        <!-- Testimonial 2 -->
                        <div class="swiper-slide testimonial-slide">
                            <div class="testimonial-content">
                                <p>"Nhóm mình chơi cầu lông cuối tuần, từ ngày dùng V-SPORT việc giữ chỗ và chia tiền sân với bạn bè nhẹ nhàng hơn hẳn."</p>
                                <div class="testimonial-author">
                                    <h4 class="author-name">Thanh Hà</h4>
                                    <span class="author-location">Cầu Giấy, Hà Nội</span>
                                </div>
                            </div>
                        </div>
                        <!-- Testimonial 3 -->
                        <div class="swiper-slide testimonial-slide">
                            <div class="testimonial-content">
                                <p>"Giao diện rõ ràng, chọn khung giờ trống trực quan, hủy lịch cũng dễ dàng khi có việc đột xuất."</p>
                                <div class="testimonial-author">
                                    <h4 class="author-name">Quốc Bảo</h4>
                                    <span class="author-location">Hải Châu, Đà Nẵng</span>
                                </div>
                            </div>
                        </div>
                    </div>
                    <!-- Custom Bullet Avatars Pagination -->
                    <div class="testimonial-custom-pagination">
                        <button class="pagination-avatar active" aria-label="Testimonial 1"></button>
                        <button class="pagination-avatar" aria-label="Testimonial 2"></button>
                        <button class="pagination-avatar" aria-label="Testimonial 3"></button>
                    </div>
                </div>
            </section>

            <!-- VIDEO BANNER CARD SECTION -->
            <section class="video-banner-section">
                <div class="video-bg-placeholder"></div>
                <div class="video-overlay">
                    <button class="play-video-btn" aria-label="Xem video">XEM</button>
                </div>
            </section>

            <!-- NEWSLETTER SECTION -->
            <section class="newsletter-section">
                <div class="newsletter-container container">
                    <div class="newsletter-grid">
                        <div class="newsletter-heading">
                            <h2 class="newsletter-title">Đăng ký nhận ưu đãi độc quyền!</h2>
                        </div>
                        <div class="newsletter-form-wrapper">
                            <form class="newsletter-form" onsubmit="event.preventDefault();">
                                <div class="input-group">
                                    <input type="email" placeholder="Nhập email của bạn..." required aria-label="Địa chỉ email">
                                    <button type="submit" class="newsletter-submit-btn" aria-label="Subscribe">
                                        <i class="fa-solid fa-arrow-right"></i>
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </section>

        </main>

        <!-- FOOTER -->
        <footer class="main-footer">
            <div class="footer-widgets container">
                <div class="footer-grid">
                    <!-- Column 1: Intro -->
                    <div class="footer-col intro-col">
                        <h4 class="footer-title">Xin Chào, Chúng Tôi Là V-SPORT</h4>
                        <p class="footer-text">Nền tảng đặt sân thể thao nhanh chóng, minh bạch, thanh toán an toàn qua PayOS.</p>
                    </div>
                    <!-- Column 2: Address -->
                    <div class="footer-col address-col">
                        <h4 class="footer-title">Văn phòng</h4>
                        <p class="footer-text">Việt Nam —<br>Hệ thống sân đối tác<br>trên toàn quốc</p>
                        <a href="mailto:hotro@vsport.vn" class="footer-link-underline">hotro@vsport.vn</a>
                        <a href="tel:19001234" class="footer-phone-link">1900 1234</a>
                    </div>
                    <!-- Column 3: Links -->
                    <div class="footer-col links-col">
                        <h4 class="footer-title">Liên Kết</h4>
                        <ul class="footer-links-list">
                            <li><a href="${pageContext.request.contextPath}/index.jsp">Trang Chủ</a></li>
                            <li><a href="${pageContext.request.contextPath}/customer/dat-san">Đặt Sân</a></li>
                            <li><a href="${pageContext.request.contextPath}/index.jsp#welcome-section">Giới Thiệu</a></li>
                            <li><a href="#pricing">Bảng Giá</a></li>
                        </ul>
                    </div>
                    <!-- Column 4: Socials -->
                    <div class="footer-col socials-col">
                        <h4 class="footer-title">Kết Nối</h4>
                        <div class="footer-social-wrap">
                            <a href="#" class="social-item"><span class="social-icon-wrapper"><i class="fa-brands fa-facebook-f"></i></span> Facebook</a>
                            <a href="#" class="social-item"><span class="social-icon-wrapper"><i class="fa-brands fa-x-twitter"></i></span> Twitter</a>
                            <a href="#" class="social-item"><span class="social-icon-wrapper"><i class="fa-brands fa-tiktok"></i></span> TikTok</a>
                            <a href="#" class="social-item"><span class="social-icon-wrapper"><i class="fa-brands fa-instagram"></i></span> Instagram</a>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Bottom Copyright Bar -->
            <div class="footer-bottom-bar container">
                <div class="copyright-content">
                    <p>V-SPORT © 2026. Bảo lưu mọi quyền.</p>
                </div>
            </div>
        </footer>

        <!-- INTERACTIVE PANELS AND DRAWERS -->

        <!-- Info Drawer (Right Side) -->
        <div class="drawer-panel info-drawer" id="info-drawer">
            <div class="drawer-header">
                <a href="${pageContext.request.contextPath}/index.jsp" class="logo-link">
                    <span class="logo-icon"><i class="fa-solid fa-table-tennis-paddle-ball"></i></span>
                    <span class="logo-text">V-<span>SPORT</span></span>
                </a>
                <button class="drawer-close-btn" aria-label="Close Panel"><i class="fa-solid fa-xmark"></i></button>
            </div>
            <div class="drawer-body">
                <div class="drawer-socials">
                    <a href="#" class="social-item"><span class="social-icon-wrapper"><i class="fa-brands fa-facebook-f"></i></span> Facebook</a>
                    <a href="#" class="social-item"><span class="social-icon-wrapper"><i class="fa-brands fa-x-twitter"></i></span> Twitter</a>
                    <a href="#" class="social-item"><span class="social-icon-wrapper"><i class="fa-brands fa-tiktok"></i></span> TikTok</a>
                    <a href="#" class="social-item"><span class="social-icon-wrapper"><i class="fa-brands fa-instagram"></i></span> Instagram</a>
                </div>
                <div class="drawer-contacts">
                    <a href="tel:19001234" class="phone-link">1900 1234</a>
                    <a href="mailto:hotro@vsport.vn" class="email-link">hotro@vsport.vn</a>
                </div>
            </div>
        </div>

        <!-- Fullscreen Search Overlay -->
        <div class="search-overlay" id="search-overlay">
            <div class="search-overlay-header container">
                <a href="${pageContext.request.contextPath}/index.jsp" class="logo-link">
                    <span class="logo-icon"><i class="fa-solid fa-table-tennis-paddle-ball"></i></span>
                    <span class="logo-text">V-<span>SPORT</span></span>
                </a>
                <button class="search-close-btn" aria-label="Close Search"><i class="fa-solid fa-xmark"></i></button>
            </div>
            <div class="search-overlay-body">
                <form class="search-form-overlay" onsubmit="event.preventDefault();">
                    <input type="text" class="search-input-field" placeholder="Nhập từ khoá và nhấn Enter" autofocus aria-label="Search site">
                    <button type="submit" class="search-submit-btn"><i class="fa-solid fa-magnifying-glass"></i></button>
                </form>
            </div>
        </div>

        <!-- Mobile Menu Drawer -->
        <div class="drawer-panel mobile-menu-drawer" id="mobile-menu-drawer">
            <div class="drawer-header">
                <a href="${pageContext.request.contextPath}/index.jsp" class="logo-link">
                    <span class="logo-icon"><i class="fa-solid fa-table-tennis-paddle-ball"></i></span>
                    <span class="logo-text">V-<span>SPORT</span></span>
                </a>
                <button class="drawer-close-btn" aria-label="Close Menu"><i class="fa-solid fa-xmark"></i></button>
            </div>
            <div class="drawer-body">
                <!-- Mobile Navigation Links -->
                <nav class="mobile-nav-menu-area"></nav>
                <div class="mobile-socials-area"></div>
                <div class="mobile-additional-widgets">
                    <div class="extra-widget-item">
                        <h6>Cần hỗ trợ?</h6>
                        <a href="mailto:hotro@vsport.vn">hotro@vsport.vn</a>
                    </div>
                </div>
            </div>
        </div>

        <!-- Video Modal Overlay -->
        <div class="video-modal" id="video-modal">
            <div class="video-modal-container">
                <button class="video-modal-close" aria-label="Close Video"><i class="fa-solid fa-xmark"></i></button>
                <div class="video-aspect-container">
                    <iframe id="video-iframe" src="" frameborder="0" allow="autoplay; fullscreen; picture-in-picture" allowfullscreen></iframe>
                </div>
            </div>
        </div>

        <!-- SCREEN OVERLAYS & MODALS -->
        
        <!-- Authentication Modal (Login / Register / OTP) — shared real modal, wired to backend -->
        <jsp:include page="/auth/AuthModal.jsp" />

        <!-- Backdrop overlay for click-away -->
        <div class="overlay-backdrop" id="overlay-backdrop"></div>

        <!-- Scroll to Top Button -->
        <a href="#" class="scroll-to-top" id="scroll-to-top" title="Scroll to top">
            <i class="fa-solid fa-chevron-up"></i>
        </a>

    </div>

    <!-- Swiper JS -->
    <script src="https://cdn.jsdelivr.net/npm/swiper@11/swiper-bundle.min.js"></script>
    <!-- Custom JS -->
    <script>
/* ==========================================================================
   Tennis Club - Court Booking & Authentication Script
   ========================================================================== */

document.addEventListener('DOMContentLoaded', () => {

    // ==========================================================================
    // 1. STATE VARIABLES
    // ==========================================================================
    // ==========================================================================
    // 2. SWIPER SLIDERS INITIALIZATION
    // ==========================================================================
    
    // Hero Swiper replaced with static 3-column banner showcase

    // Testimonials custom avatar bullets logic
    // (khai báo TRƯỚC khi khởi tạo Swiper vì slideChange có thể bắn đồng bộ ngay khi init)
    const testimonialAvatars = document.querySelectorAll('.pagination-avatar');

    // Testimonials Swiper
    const testimonialSwiper = new Swiper('.testimonial-swiper', {
        loop: true,
        autoplay: {
            delay: 6000,
            disableOnInteraction: false,
        },
        speed: 600,
        on: {
            slideChange: function () {
                updateTestimonialAvatars(this.realIndex);
            }
        }
    });

    testimonialAvatars.forEach((avatar, index) => {
        avatar.addEventListener('click', () => {
            testimonialSwiper.slideToLoop(index);
        });
    });

    function updateTestimonialAvatars(activeIndex) {
        testimonialAvatars.forEach((avatar, idx) => {
            if (idx === activeIndex) {
                avatar.classList.add('active');
            } else {
                avatar.classList.remove('active');
            }
        });
    }


    // ==========================================================================
    // 3. DRAWERS & BACKGROUND BACKDROP HANDLERS
    // ==========================================================================
    
    const body = document.body;
    const backdrop = document.getElementById('overlay-backdrop');
    
    // Panel triggers
    const infoTrigger = document.querySelector('.info-panel-trigger');
    const searchTrigger = document.querySelector('.search-trigger');
    const mobileMenuTrigger = document.querySelector('.mobile-menu-trigger');

    // Panels
    const infoDrawer = document.getElementById('info-drawer');
    const searchOverlay = document.getElementById('search-overlay');
    const mobileMenuDrawer = document.getElementById('mobile-menu-drawer');

    // Close triggers
    const closeBtns = document.querySelectorAll('.drawer-close-btn, .search-close-btn');

    function openPanel(panel) {
        closeAllPanels();
        panel.classList.add('active');
        backdrop.classList.add('active');
        body.classList.add('panel-open');
    }

    function closeAllPanels() {
        infoDrawer.classList.remove('active');
        searchOverlay.classList.remove('active');
        mobileMenuDrawer.classList.remove('active');
        backdrop.classList.remove('active');
        body.classList.remove('panel-open');

        // Hide overlay modals
        if (window.closeAuthModal) window.closeAuthModal();
    }

    if (infoTrigger) {
        infoTrigger.addEventListener('click', (e) => {
            e.preventDefault();
            openPanel(infoDrawer);
        });
    }

    searchTrigger.addEventListener('click', (e) => {
        e.preventDefault();
        openPanel(searchOverlay);
        setTimeout(() => {
            document.querySelector('.search-input-field').focus();
        }, 300);
    });

    mobileMenuTrigger.addEventListener('click', (e) => {
        e.preventDefault();
        openPanel(mobileMenuDrawer);
    });

    closeBtns.forEach(btn => {
        btn.addEventListener('click', closeAllPanels);
    });

    backdrop.addEventListener('click', closeAllPanels);


    // ==========================================================================
    // 4. GENERATING MOBILE MENU TREE DYNAMICALLY
    // ==========================================================================
    
    const desktopNavMenu = document.querySelector('.desktop-nav .main-menu');
    const mobileNavContainer = document.querySelector('.mobile-nav-menu-area');
    
    if (desktopNavMenu && mobileNavContainer) {
        const clonedMenu = desktopNavMenu.cloneNode(true);
        clonedMenu.className = 'mobile-nav-list';
        
        const itemsWithChildren = clonedMenu.querySelectorAll('.menu-item.has-children');
        itemsWithChildren.forEach(item => {
            const link = item.querySelector('a');
            const dropdown = item.querySelector('.dropdown-menu');
            dropdown.className = 'mobile-submenu';
            
            const toggleBtn = document.createElement('button');
            toggleBtn.className = 'submenu-toggle-btn';
            toggleBtn.innerHTML = '<i class="fa-solid fa-plus"></i>';
            toggleBtn.ariaLabel = 'Toggle Submenu';
            
            link.appendChild(toggleBtn);
            
            link.addEventListener('click', (e) => {
                e.preventDefault();
                const icon = toggleBtn.querySelector('i');
                const isSubmenuActive = dropdown.classList.contains('active');
                
                if (isSubmenuActive) {
                    dropdown.classList.remove('active');
                    icon.className = 'fa-solid fa-plus';
                } else {
                    dropdown.classList.add('active');
                    icon.className = 'fa-solid fa-minus';
                }
            });
        });
        
        mobileNavContainer.appendChild(clonedMenu);
    }

    const footerSocials = document.querySelector('.footer-social-wrap');
    const mobileSocialsContainer = document.querySelector('.mobile-socials-area');
    if (footerSocials && mobileSocialsContainer) {
        const clonedSocials = footerSocials.cloneNode(true);
        clonedSocials.className = 'mobile-socials-wrap';
        mobileSocialsContainer.appendChild(clonedSocials);
    }


    // ==========================================================================
    // 5. PARALLAX EFFECT FOR FLOATING TENNIS BALL
    // ==========================================================================
    
    const makeGameSection = document.querySelector('.make-game-section');
    const tennisBall = document.querySelector('.tennis-ball-interactive');
    
    if (makeGameSection && tennisBall) {
        makeGameSection.addEventListener('mousemove', (e) => {
            const rect = makeGameSection.getBoundingClientRect();
            const mouseX = e.clientX - rect.left - (rect.width / 2);
            const mouseY = e.clientY - rect.top - (rect.height / 2);
            
            const strengthX = 0.12;
            const strengthY = 0.12;
            
            const translateX = mouseX * strengthX;
            const translateY = mouseY * strengthY;
            const rotation = (mouseX + mouseY) * 0.05;
            
            tennisBall.style.transform = `translate3d(\${translateX}px, \${translateY}px, 0) rotate(\${rotation}deg)`;
        });
        
        makeGameSection.addEventListener('mouseleave', () => {
            tennisBall.style.transform = 'translate3d(0, 0, 0) rotate(0deg)';
            tennisBall.style.transition = 'transform 0.5s ease-out';
        });
        
        makeGameSection.addEventListener('mouseenter', () => {
            tennisBall.style.transition = 'transform 0.1s ease-out';
        });
    }


    // ==========================================================================
    // 6. VIDEO MODAL POPUP
    // ==========================================================================
    
    const playVideoBtn = document.querySelector('.play-video-btn');
    const videoModal = document.getElementById('video-modal');
    const videoIframe = document.getElementById('video-iframe');
    const videoModalClose = document.querySelector('.video-modal-close');
    const vimeoUrl = 'https://player.vimeo.com/video/299726198?autoplay=1&dnt=1';

    function openVideoModal() {
        videoIframe.src = vimeoUrl;
        videoModal.classList.add('active');
        body.classList.add('panel-open');
    }

    function closeVideoModal() {
        videoIframe.src = '';
        videoModal.classList.remove('active');
        body.classList.remove('panel-open');
    }

    if (playVideoBtn) {
        playVideoBtn.addEventListener('click', (e) => {
            e.preventDefault();
            openVideoModal();
        });
    }

    if (videoModalClose) {
        videoModalClose.addEventListener('click', closeVideoModal);
    }
    
    if (videoModal) {
        videoModal.addEventListener('click', (e) => {
            if (e.target === videoModal) {
                closeVideoModal();
            }
        });
    }


    // ==========================================================================
    // 7. USER AUTHENTICATION LOGIC — delegates to /auth/AuthModal.jsp (openAuthModal)
    // ==========================================================================

    const headerUserBtn = document.getElementById('header-user-btn');
    const headerUserMenu = document.getElementById('header-user-menu');
    const headerUserChip = document.getElementById('header-user-chip');

    if (headerUserBtn) {
        headerUserBtn.addEventListener('click', (e) => {
            e.preventDefault();
            if (window.openAuthModal) {
                openAuthModal('login', headerUserBtn);
            }
        });
    }

    if (headerUserMenu && headerUserChip) {
        headerUserChip.addEventListener('click', (e) => {
            e.preventDefault();
            const isOpen = headerUserMenu.classList.toggle('is-open');
            headerUserChip.setAttribute('aria-expanded', isOpen ? 'true' : 'false');
        });

        document.addEventListener('click', (e) => {
            if (!headerUserMenu.contains(e.target)) {
                headerUserMenu.classList.remove('is-open');
                headerUserChip.setAttribute('aria-expanded', 'false');
            }
        });

        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape') {
                headerUserMenu.classList.remove('is-open');
                headerUserChip.setAttribute('aria-expanded', 'false');
            }
        });
    }

    // ==========================================================================
    // 8. SCROLL TO TOP ACTION
    // ==========================================================================
    
    const scrollTopBtn = document.getElementById('scroll-to-top');
    
    window.addEventListener('scroll', () => {
        if (window.scrollY > 300) {
            scrollTopBtn.classList.add('visible');
        } else {
            scrollTopBtn.classList.remove('visible');
        }
    });
    
    scrollTopBtn.addEventListener('click', (e) => {
        e.preventDefault();
        window.scrollTo({
            top: 0,
            behavior: 'smooth'
        });
    });

});

</script>
</body>
</html>
