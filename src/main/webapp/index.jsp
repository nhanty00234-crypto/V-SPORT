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
    max-width: var(--container-width);
    margin: 0 auto;
    padding: 0 20px;
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
    font-size: 32px;
    color: var(--primary);
    display: flex;
    align-items: center;
}

.logo-text {
    font-family: var(--font-heading);
    font-weight: 700;
    font-size: 26px;
    text-transform: uppercase;
    letter-spacing: -0.5px;
    color: var(--dark);
}

.logo-text span {
    color: var(--primary);
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
    color: var(--primary) !important;
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
    background-color: var(--primary);
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

.cart-trigger .cart-badge {
    position: absolute;
    top: 2px;
    right: 2px;
    width: 20px;
    height: 20px;
    background-color: var(--primary);
    color: var(--dark);
    font-size: 10px;
    font-weight: 700;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    border: 2px solid var(--white);
}

.action-btn:hover .cart-badge {
    background-color: var(--dark);
    color: var(--white);
    border-color: var(--primary);
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

.btn-header-book {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    background-color: var(--secondary-blue);
    color: var(--white) !important;
    font-family: var(--font-heading);
    font-weight: 700;
    font-size: 13px;
    letter-spacing: 1px;
    text-transform: uppercase;
    padding: 10px 24px;
    border-radius: 4px;
    transition: var(--transition-normal);
    box-shadow: 0 4px 10px rgba(66, 124, 240, 0.2);
    margin-left: 15px;
}

.btn-header-book:hover {
    background-color: var(--secondary-blue-hover);
    color: var(--white) !important;
    box-shadow: 0 6px 15px rgba(66, 124, 240, 0.3);
    transform: translateY(-1px);
}

/* 4. HERO DARK SECTION */
.hero-dark-section {
    width: 100vw;
    height: 80vh;
    min-height: 600px;
    background: linear-gradient(135deg, #11150f 0%, #080a08 100%);
    position: relative;
    overflow: hidden;
    display: flex;
    align-items: center;
}

.hero-dark-container {
    max-width: var(--container-width);
    margin: 0 auto;
    padding: 0 20px;
    width: 100%;
    display: grid;
    grid-template-columns: 1.2fr 0.8fr;
    align-items: center;
    position: relative;
    z-index: 5;
}

.hero-dark-content {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    color: var(--white);
    opacity: 0;
    transform: translateX(-50px);
    animation: slideInLeft 1.2s cubic-bezier(0.25, 1, 0.5, 1) 0.2s forwards;
}

@keyframes slideInLeft {
    to {
        opacity: 1;
        transform: translateX(0);
    }
}

.hero-dark-subtitle {
    font-family: var(--font-heading);
    font-weight: 600;
    font-size: 18px;
    letter-spacing: 4px;
    text-transform: uppercase;
    color: var(--primary);
    margin-bottom: 25px;
}

.hero-dark-title {
    font-family: var(--font-heading);
    font-weight: 800;
    font-size: 6vw;
    line-height: 1.05;
    text-transform: uppercase;
    color: var(--white);
    margin-bottom: 45px;
}

.hero-dark-scroll {
    display: inline-flex;
    align-items: center;
    gap: 10px;
    font-family: var(--font-heading);
    font-weight: 600;
    font-size: 13px;
    letter-spacing: 2px;
    text-transform: uppercase;
    color: rgba(255, 255, 255, 0.5);
    transition: var(--transition-normal);
}

.hero-dark-scroll:hover {
    color: var(--primary);
}

.hero-dark-scroll i {
    animation: bounceDown 1.5s infinite;
}

@keyframes bounceDown {
    0%, 100% { transform: translateY(0); }
    50% { transform: translateY(5px); }
}

.hero-dark-image-wrapper {
    position: relative;
    height: 100%;
    display: flex;
    align-items: center;
    justify-content: flex-end;
    opacity: 0;
    transform: translateX(50px);
    animation: slideInRight 1.2s cubic-bezier(0.25, 1, 0.5, 1) 0.4s forwards;
}

@keyframes slideInRight {
    to {
        opacity: 1;
        transform: translateX(0);
    }
}

.hero-dark-img {
    max-width: 100%;
    height: 80vh;
    min-height: 600px;
    object-fit: cover;
    object-position: center;
    mask-image: linear-gradient(to left, rgba(0,0,0,1) 70%, rgba(0,0,0,0) 100%);
    -webkit-mask-image: linear-gradient(to left, rgba(0,0,0,1) 70%, rgba(0,0,0,0) 100%);
}

.hero-dark-pagination {
    position: absolute;
    bottom: 40px;
    right: 40px;
    display: flex;
    align-items: center;
    gap: 15px;
    color: var(--white);
    font-family: var(--font-heading);
    font-weight: 700;
    font-size: 14px;
    z-index: 10;
}

.hero-dark-pagination-line {
    width: 60px;
    height: 2px;
    background-color: rgba(255, 255, 255, 0.2);
    position: relative;
}

.hero-dark-pagination-active {
    position: absolute;
    top: 0;
    left: 0;
    height: 100%;
    width: 50%;
    background-color: var(--primary);
}

.hero-dark-buttons {
    display: flex;
    align-items: center;
    gap: 20px;
    margin-top: 20px;
}

.hero-dark-btn-primary {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    background-color: var(--primary);
    color: var(--dark) !important;
    font-family: var(--font-heading);
    font-weight: 750;
    font-size: 14px;
    letter-spacing: 1px;
    text-transform: uppercase;
    padding: 16px 40px;
    border-radius: 4px;
    transition: var(--transition-normal);
    box-shadow: 0 4px 15px rgba(175, 214, 57, 0.3);
    text-decoration: none;
}

.hero-dark-btn-primary:hover {
    background-color: var(--primary-hover);
    box-shadow: 0 8px 25px rgba(175, 214, 57, 0.5);
    transform: translateY(-2px);
}

.hero-dark-btn-secondary {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    background-color: transparent;
    color: var(--white) !important;
    font-family: var(--font-heading);
    font-weight: 700;
    font-size: 14px;
    letter-spacing: 1px;
    text-transform: uppercase;
    padding: 16px 40px;
    border-radius: 4px;
    border: 2px solid rgba(255, 255, 255, 0.3);
    transition: var(--transition-normal);
    text-decoration: none;
}

.hero-dark-btn-secondary:hover {
    border-color: var(--white);
    background-color: rgba(255, 255, 255, 0.05);
    transform: translateY(-2px);
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
    .hero-dark-container {
        grid-template-columns: 1fr;
        text-align: center;
        gap: 40px;
    }
    .hero-dark-content {
        align-items: center;
    }
    .hero-dark-image-wrapper {
        justify-content: center;
    }
    .hero-dark-img {
        height: 50vh;
        min-height: auto;
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

/* 8. PRODUCTS GRID */
.products-section {
    padding: 100px 0;
}

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

.products-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 30px;
    margin-bottom: 60px;
}

.product-card {
    display: flex;
    flex-direction: column;
}

.product-image-container {
    position: relative;
    aspect-ratio: 1;
    background-color: var(--light-gray);
    border-radius: 8px;
    overflow: hidden;
}

.product-image-placeholder {
    width: 100%;
    height: 100%;
    background-color: #eef0f4;
    position: relative;
}

/* Subtle cross pattern on product placeholder */
.product-image-placeholder::after {
    content: '';
    position: absolute;
    top: 10%;
    left: 10%;
    width: 80%;
    height: 80%;
    border: 1px dashed rgba(0,0,0,0.05);
}

.product-hover-overlay {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(15,15,15,0.2);
    display: flex;
    align-items: center;
    justify-content: center;
    opacity: 0;
    transition: opacity var(--transition-normal);
    z-index: 2;
}

.overlay-icons {
    display: flex;
    gap: 12px;
    transform: translateY(15px);
    transition: transform var(--transition-normal);
}

.overlay-icons button,
.overlay-icons a {
    width: 46px;
    height: 46px;
    border-radius: 50%;
    background-color: var(--white);
    color: var(--dark);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 16px;
    box-shadow: 0 4px 10px rgba(0,0,0,0.1);
    transition: var(--transition-normal);
}

.overlay-icons button:hover,
.overlay-icons a:hover {
    background-color: var(--primary);
    color: var(--white);
}

.product-card:hover .product-hover-overlay {
    opacity: 1;
}

.product-card:hover .overlay-icons {
    transform: translateY(0);
}

.product-info {
    padding: 20px 10px;
    display: flex;
    flex-direction: column;
    align-items: center;
    flex-grow: 1;
}

.product-title {
    font-family: var(--font-heading);
    font-weight: 600;
    font-size: 20px;
    text-transform: uppercase;
    margin-bottom: 8px;
}

.product-title a:hover {
    color: var(--primary);
}

.product-rating {
    display: flex;
    gap: 4px;
    color: var(--primary);
    font-size: 11px;
    margin-bottom: 10px;
}

.product-price {
    font-family: var(--font-heading);
    font-weight: 700;
    font-size: 18px;
    color: var(--dark);
    margin-bottom: 15px;
}

.buy-now-btn {
    width: auto;
    padding: 10px 24px;
    font-size: 12px;
    letter-spacing: 1px;
    opacity: 0;
    transform: translateY(10px);
}

.product-card:hover .buy-now-btn {
    opacity: 1;
    transform: translateY(0);
}

.products-footer-btn {
    margin-top: 20px;
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

/* Cart Drawer Content */
.empty-cart-message {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    height: 100%;
    color: var(--text-muted);
    gap: 15px;
}

.empty-cart-message i {
    font-size: 48px;
    color: var(--border);
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
    
    .products-grid {
        grid-template-columns: repeat(3, 1fr);
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
    
    .products-grid {
        grid-template-columns: repeat(2, 1fr);
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
        font-size: 26px;
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
    
    .products-grid {
        grid-template-columns: 1fr;
        gap: 25px;
    }
    
    .product-card {
        max-width: 320px;
        margin: 0 auto;
    }
    
    .buy-now-btn {
        opacity: 1;
        transform: translateY(0);
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
   16. COURT CARDS & SPECIFICATIONS
   ========================================================================== */
.court-placeholder.clay {
    background: linear-gradient(135deg, #e07a5f 0%, #b54a30 100%) !important;
}
.court-placeholder.grass {
    background: linear-gradient(135deg, #52b788 0%, #2d6a4f 100%) !important;
}
.court-placeholder.hard {
    background: linear-gradient(135deg, #4ea8de 0%, #0077b6 100%) !important;
}
.court-placeholder.carpet {
    background: linear-gradient(135deg, #b5179e 0%, #7209b7 100%) !important;
}

/* Tennis court nets simulation pattern on placeholders */
.court-placeholder::before {
    content: '';
    position: absolute;
    top: 50%;
    left: 0;
    width: 100%;
    height: 2px;
    background-color: rgba(255,255,255,0.4);
    box-shadow: 0 4px 8px rgba(0,0,0,0.1);
}

.court-specs {
    display: flex;
    flex-direction: column;
    gap: 8px;
    margin: 15px 0;
    text-align: left;
    width: 100%;
}

.court-specs li {
    font-size: 13.5px;
    color: var(--text-muted);
    display: flex;
    align-items: center;
    gap: 10px;
}

.court-specs li i {
    color: var(--primary);
    width: 16px;
    text-align: center;
}

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

/* ==========================================================================
   19. INTERACTIVE COURT BOOKING SCHEDULER MODAL
   ========================================================================== */
.booking-modal-card {
    background-color: var(--white);
    width: 900px;
    max-width: 95%;
    border-radius: 12px;
    padding: 35px;
    position: relative;
    box-shadow: 0 15px 40px rgba(0,0,0,0.2);
    transform: scale(0.9);
    transition: transform var(--transition-normal);
    max-height: 95vh;
    overflow-y: auto;
}

.modal-overlay.active .booking-modal-card {
    transform: scale(1);
}

.booking-modal-title {
    font-family: var(--font-heading);
    font-weight: 600;
    font-size: 26px;
    text-transform: uppercase;
    color: var(--dark);
    margin-bottom: 25px;
    padding-right: 30px;
}

.booking-modal-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 35px;
}

/* Left Panel details & custom calendar */
.booking-modal-left {
    display: flex;
    flex-direction: column;
    gap: 20px;
}

.booking-court-details-card {
    background-color: var(--light-gray);
    padding: 15px 20px;
    border-radius: 6px;
    display: flex;
    align-items: center;
    justify-content: space-between;
}

.court-tag {
    font-family: var(--font-heading);
    font-weight: 600;
    font-size: 12px;
    letter-spacing: 1px;
    text-transform: uppercase;
    background-color: var(--primary);
    color: var(--dark);
    padding: 4px 10px;
    border-radius: 4px;
}

.court-pricing-rate {
    font-size: 15px;
    color: var(--text-muted);
}

.court-pricing-rate span {
    font-family: var(--font-heading);
    font-weight: 700;
    font-size: 22px;
    color: var(--dark);
}

.selected-date-indicator {
    font-size: 14px;
    color: var(--dark);
}

.selected-date-indicator strong {
    color: var(--secondary-blue);
}

/* Custom Calendar Styling */
.custom-calendar-widget {
    border: 1px solid var(--border);
    border-radius: 8px;
    padding: 15px;
    background-color: var(--white);
}

.calendar-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 15px;
}

.calendar-nav-btn {
    width: 30px;
    height: 30px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    color: var(--dark);
    transition: var(--transition-fast);
}

.calendar-nav-btn:hover {
    background-color: var(--light-gray);
    color: var(--primary);
}

.calendar-current-month {
    font-family: var(--font-heading);
    font-weight: 600;
    font-size: 16px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.calendar-weekdays {
    display: grid;
    grid-template-columns: repeat(7, 1fr);
    text-align: center;
    font-weight: 700;
    font-size: 11px;
    text-transform: uppercase;
    color: var(--text-muted);
    margin-bottom: 10px;
}

.calendar-days {
    display: grid;
    grid-template-columns: repeat(7, 1fr);
    row-gap: 8px;
}

.calendar-day-cell {
    aspect-ratio: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 13px;
    font-weight: 500;
    border-radius: 50%;
    cursor: pointer;
    transition: var(--transition-fast);
}

.calendar-day-cell:hover:not(.disabled):not(.active) {
    background-color: var(--light-gray);
}

.calendar-day-cell.active {
    background-color: var(--primary);
    color: var(--dark);
    font-weight: 700;
}

.calendar-day-cell.disabled {
    opacity: 0.2;
    cursor: not-allowed;
    pointer-events: none;
}

/* Right Panel: Time slot picker */
.booking-modal-right {
    display: flex;
    flex-direction: column;
    gap: 25px;
}

.slot-column-title {
    font-family: var(--font-heading);
    font-weight: 600;
    font-size: 16px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    color: var(--dark);
    border-bottom: 1px solid var(--border);
    padding-bottom: 8px;
}

.time-slots-container {
    display: flex;
    flex-direction: column;
    gap: 20px;
    max-height: 280px;
    overflow-y: auto;
    padding-right: 5px;
}

.slot-group {
    display: flex;
    flex-direction: column;
    gap: 10px;
}

.slot-group-header {
    font-size: 12.5px;
    font-weight: 700;
    text-transform: uppercase;
    color: var(--text-muted);
    display: flex;
    align-items: center;
    gap: 8px;
}

.slots-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 10px;
}

.time-slot-btn {
    border: 1px solid var(--border);
    border-radius: 6px;
    padding: 10px;
    text-align: center;
    font-family: var(--font-heading);
    font-weight: 600;
    font-size: 14px;
    background-color: var(--white);
    transition: var(--transition-fast);
}

.time-slot-btn:hover:not(.booked):not(.selected) {
    border-color: var(--primary);
    color: var(--primary);
}

.time-slot-btn.selected {
    background-color: var(--primary);
    border-color: var(--primary);
    color: var(--dark);
}

.time-slot-btn.booked {
    background-color: #f1f2f6;
    border-color: #f1f2f6;
    color: #ced6e0;
    text-decoration: line-through;
    cursor: not-allowed;
}

/* Summary Panel styling */
.booking-summary-box {
    border-top: 1px solid var(--border);
    padding-top: 20px;
    display: flex;
    flex-direction: column;
    gap: 10px;
}

.summary-line {
    display: flex;
    align-items: center;
    justify-content: space-between;
    font-size: 14px;
    color: var(--text-muted);
}

.summary-line.highlight {
    font-size: 16px;
    color: var(--dark);
    font-weight: 700;
}

.summary-line.highlight span:last-child {
    font-family: var(--font-heading);
    font-size: 24px;
    color: var(--primary);
}

/* 20. BOOKING CART ITEM LIST (RIGHT BAR) */
.cart-items-list {
    display: flex;
    flex-direction: column;
    gap: 15px;
    height: 100%;
}

.booking-cart-item {
    border: 1px solid var(--border);
    border-radius: 6px;
    padding: 15px;
    display: flex;
    flex-direction: column;
    gap: 8px;
    position: relative;
    background-color: var(--light-gray);
}

.booking-cart-item .delete-item-btn {
    position: absolute;
    top: 10px;
    right: 10px;
    font-size: 14px;
    color: var(--text-muted);
}

.booking-cart-item .delete-item-btn:hover {
    color: #ff4757;
}

.cart-item-title {
    font-family: var(--font-heading);
    font-weight: 600;
    font-size: 16px;
    text-transform: uppercase;
    padding-right: 20px;
}

.cart-item-meta {
    font-size: 12.5px;
    color: var(--text-muted);
    display: flex;
    flex-direction: column;
    gap: 4px;
}

.cart-item-meta span i {
    margin-right: 6px;
    color: var(--primary);
}

.cart-item-price {
    font-family: var(--font-heading);
    font-weight: 700;
    font-size: 16px;
    margin-top: 4px;
}

/* Responsiveness for Booking Modal */
@media (max-width: 991px) {
    .booking-modal-grid {
        grid-template-columns: 1fr;
        gap: 30px;
    }
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
                    <!-- Shopping Cart Trigger -->
                    <button class="action-btn cart-trigger" aria-label="Open Cart">
                        <i class="fa-solid fa-basket-shopping"></i>
                        <span class="cart-badge">0</span>
                    </button>
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
                    <!-- Book a Court Button -->
                    <a href="${pageContext.request.contextPath}/customer/dat-san" class="btn-header-book">Đặt Sân</a>
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
            <section class="hero-dark-section">
                <div class="hero-dark-container">
                    <!-- Left Side Content -->
                    <div class="hero-dark-content">
                        <span class="hero-dark-subtitle" style="color: var(--primary); font-weight: 700; letter-spacing: 2px; text-transform: uppercase;">ĐẶT SÂN THỂ THAO</span>
                        <h1 class="hero-dark-title" style="margin-top: 15px; margin-bottom: 25px;">TÌM SÂN PHÙ HỢP<br>ĐẶT LỊCH NHANH CHÓNG</h1>
                        <div class="hero-dark-buttons">
                            <a href="${pageContext.request.contextPath}/customer/dat-san" class="hero-dark-btn-primary">ĐẶT SÂN NGAY</a>
                            <a href="#welcome-section" class="hero-dark-btn-secondary">KHÁM PHÁ SÂN</a>
                        </div>
                    </div>
                    <!-- Right Side Image -->
                    <div class="hero-dark-image-wrapper">
                        <img class="hero-dark-img" src="https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0?auto=format&fit=crop&q=80&w=800" alt="Tennis Player">
                    </div>
                </div>
                
                <!-- Pagination Indicators -->
                <div class="hero-dark-pagination">
                    <span>02</span>
                    <div class="hero-dark-pagination-line">
                        <div class="hero-dark-pagination-active"></div>
                    </div>
                    <span>01</span>
                </div>
            </section>

            <!-- WELCOME SECTION -->
            <section class="welcome-section" id="welcome-section">
                <div class="welcome-container">
                    <!-- Left: Overlapping Images -->
                    <div class="welcome-images-left">
                        <img class="welcome-img-back" src="https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0?auto=format&fit=crop&q=80&w=600" alt="Sân tennis">
                        <img class="welcome-img-front" src="https://images.unsplash.com/photo-1587280501635-68a0e82cd5ff?auto=format&fit=crop&q=80&w=600" alt="Người chơi tennis">
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
                        <span>ĐẶT SÂN NHANH &bull; GIỮ CHỖ AN TOÀN &bull; THANH TOÁN PAYOS &bull; HỦY THANH TOÁN DỄ DÀNG</span>
                        <span>&nbsp;&nbsp;&bull;&nbsp;&nbsp;</span>
                        <span>ĐẶT SÂN NHANH &bull; GIỮ CHỖ AN TOÀN &bull; THANH TOÁN PAYOS &bull; HỦY THANH TOÁN DỄ DÀNG</span>
                        <span>&nbsp;&nbsp;&bull;&nbsp;&nbsp;</span>
                        <span>ĐẶT SÂN NHANH &bull; GIỮ CHỖ AN TOÀN &bull; THANH TOÁN PAYOS &bull; HỦY THANH TOÁN DỄ DÀNG</span>
                        <span>&nbsp;&nbsp;&bull;&nbsp;&nbsp;</span>
                        <span>ĐẶT SÂN NHANH &bull; GIỮ CHỖ AN TOÀN &bull; THANH TOÁN PAYOS &bull; HỦY THANH TOÁN DỄ DÀNG</span>
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
                        <div class="category-image-placeholder" style="background-image: url('https://images.unsplash.com/photo-1508098682722-e99c43a406b2?auto=format&fit=crop&q=80&w=500');"></div>
                        <div class="category-content">
                            <h4 class="category-name">Bóng đá</h4>
                            <span class="category-link">Đặt Sân Ngay</span>
                        </div>
                    </div>
                    <!-- Category Item 2: Cầu lông -->
                    <div class="category-card" onclick="location.href='${pageContext.request.contextPath}/customer/dat-san'">
                        <div class="category-image-placeholder" style="background-image: url('https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?auto=format&fit=crop&q=80&w=500');"></div>
                        <div class="category-content">
                            <h4 class="category-name">Cầu lông</h4>
                            <span class="category-link">Đặt Sân Ngay</span>
                        </div>
                    </div>
                    <!-- Category Item 3: Tennis -->
                    <div class="category-card" onclick="location.href='${pageContext.request.contextPath}/customer/dat-san'">
                        <div class="category-image-placeholder" style="background-image: url('https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0?auto=format&fit=crop&q=80&w=500');"></div>
                        <div class="category-content">
                            <h4 class="category-name">Tennis</h4>
                            <span class="category-link">Đặt Sân Ngay</span>
                        </div>
                    </div>
                    <!-- Category Item 4: Pickleball -->
                    <div class="category-card" onclick="location.href='${pageContext.request.contextPath}/customer/dat-san'">
                        <div class="category-image-placeholder" style="background-image: url('https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?auto=format&fit=crop&q=80&w=500');"></div>
                        <div class="category-content">
                            <h4 class="category-name">Pickleball</h4>
                            <span class="category-link">Đặt Sân Ngay</span>
                        </div>
                    </div>
                    <!-- Category Item 5: Bóng bàn -->
                    <div class="category-card" onclick="location.href='${pageContext.request.contextPath}/customer/dat-san'">
                        <div class="category-image-placeholder" style="background-image: url('https://images.unsplash.com/photo-1534158914592-062992fbe900?auto=format&fit=crop&q=80&w=500');"></div>
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

            <!-- AVAILABLE COURTS SECTION (REPLACES PRODUCTS) -->
            <section class="products-section container" id="courts-section">
                <div class="section-header text-center">
                    <span class="section-subtitle">Court Booking</span>
                    <h2 class="section-title">Available Tennis Courts</h2>
                </div>

                <div class="products-grid" id="courts-grid">
                    <!-- Court 1 -->
                    <div class="product-card court-card" data-court-id="clay-1" data-court-name="Premium Clay Court - Sân Đất Nện" data-price="25.00">
                        <div class="product-image-container">
                            <div class="product-image-placeholder court-placeholder clay"></div>
                            <div class="product-hover-overlay">
                                <div class="overlay-icons">
                                    <button class="wishlist-btn" aria-label="Add to Wishlist"><i class="fa-regular fa-heart"></i></button>
                                    <button class="court-book-now-btn" aria-label="Book Court"><i class="fa-solid fa-calendar-days"></i></button>
                                    <a href="#" class="details-link" aria-label="View Details"><i class="fa-solid fa-link"></i></a>
                                </div>
                            </div>
                        </div>
                        <div class="product-info text-center">
                            <h3 class="product-title"><a href="#">Premium Clay Court (Sân Đất Nện)</a></h3>
                            <ul class="court-specs">
                                <li><i class="fa-solid fa-location-dot"></i> Outdoor (Ngoài trời)</li>
                                <li><i class="fa-solid fa-bolt"></i> Professional Lighting System</li>
                                <li><i class="fa-solid fa-droplet"></i> Free mineral water & towels</li>
                            </ul>
                            <span class="product-price">$25.00 <small>/ hour</small></span>
                            <button class="btn btn-outline buy-now-btn book-btn">Book now</button>
                        </div>
                    </div>

                    <!-- Court 2 -->
                    <div class="product-card court-card" data-court-id="grass-1" data-court-name="Wimbledon Grass Court - Sân Cỏ Tự Nhiên" data-price="30.00">
                        <div class="product-image-container">
                            <div class="product-image-placeholder court-placeholder grass"></div>
                            <div class="product-hover-overlay">
                                <div class="overlay-icons">
                                    <button class="wishlist-btn" aria-label="Add to Wishlist"><i class="fa-regular fa-heart"></i></button>
                                    <button class="court-book-now-btn" aria-label="Book Court"><i class="fa-solid fa-calendar-days"></i></button>
                                    <a href="#" class="details-link" aria-label="View Details"><i class="fa-solid fa-link"></i></a>
                                </div>
                            </div>
                        </div>
                        <div class="product-info text-center">
                            <h3 class="product-title"><a href="#">Wimbledon Grass Court (Sân Cỏ)</a></h3>
                            <ul class="court-specs">
                                <li><i class="fa-solid fa-location-dot"></i> Outdoor (Cỏ tự nhiên cao cấp)</li>
                                <li><i class="fa-solid fa-users"></i> Tournament Standard</li>
                                <li><i class="fa-solid fa-hand-holding-heart"></i> Ball boy service available</li>
                            </ul>
                            <span class="product-price">$30.00 <small>/ hour</small></span>
                            <button class="btn btn-outline buy-now-btn book-btn">Book now</button>
                        </div>
                    </div>

                    <!-- Court 3 -->
                    <div class="product-card court-card" data-court-id="hard-1" data-court-name="Acrylic Hard Court - Sân Cứng Đạt Chuẩn" data-price="20.00">
                        <div class="product-image-container">
                            <div class="product-image-placeholder court-placeholder hard"></div>
                            <div class="product-hover-overlay">
                                <div class="overlay-icons">
                                    <button class="wishlist-btn" aria-label="Add to Wishlist"><i class="fa-regular fa-heart"></i></button>
                                    <button class="court-book-now-btn" aria-label="Book Court"><i class="fa-solid fa-calendar-days"></i></button>
                                    <a href="#" class="details-link" aria-label="View Details"><i class="fa-solid fa-link"></i></a>
                                </div>
                            </div>
                        </div>
                        <div class="product-info text-center">
                            <h3 class="product-title"><a href="#">Acrylic Hard Court (Sân Cứng)</a></h3>
                            <ul class="court-specs">
                                <li><i class="fa-solid fa-location-dot"></i> Indoor/Outdoor Hybrid</li>
                                <li><i class="fa-solid fa-circle-chevron-up"></i> US Open standard bounce</li>
                                <li><i class="fa-solid fa-baseball"></i> Practice wall access</li>
                            </ul>
                            <span class="product-price">$20.00 <small>/ hour</small></span>
                            <button class="btn btn-outline buy-now-btn book-btn">Book now</button>
                        </div>
                    </div>

                    <!-- Court 4 -->
                    <div class="product-card court-card" data-court-id="carpet-1" data-court-name="VIP Indoor Carpet Court - Sân Thảm Máy Lạnh" data-price="22.00">
                        <div class="product-image-container">
                            <div class="product-image-placeholder court-placeholder carpet"></div>
                            <div class="product-hover-overlay">
                                <div class="overlay-icons">
                                    <button class="wishlist-btn" aria-label="Add to Wishlist"><i class="fa-regular fa-heart"></i></button>
                                    <button class="court-book-now-btn" aria-label="Book Court"><i class="fa-solid fa-calendar-days"></i></button>
                                    <a href="#" class="details-link" aria-label="View Details"><i class="fa-solid fa-link"></i></a>
                                </div>
                            </div>
                        </div>
                        <div class="product-info text-center">
                            <h3 class="product-title"><a href="#">VIP Indoor Carpet Court (Sân Thảm)</a></h3>
                            <ul class="court-specs">
                                <li><i class="fa-solid fa-location-dot"></i> Indoor (Có máy lạnh)</li>
                                <li><i class="fa-solid fa-wind"></i> Air conditioned environment</li>
                                <li><i class="fa-solid fa-shoe-prints"></i> Low joint impact rubber base</li>
                            </ul>
                            <span class="product-price">$22.00 <small>/ hour</small></span>
                            <button class="btn btn-outline buy-now-btn book-btn">Book now</button>
                        </div>
                    </div>
                </div>

                <!-- Footer Section Button -->
                <div class="products-footer-btn text-center">
                    <a href="#courts-section" class="btn btn-black">View all yards</a>
                </div>
            </section>

            <!-- MAKE YOUR GAME PARALLAX SECTION -->
            <section class="make-game-section">
                <div class="parallax-container">
                    <span class="parallax-text stroke-text">Make your</span>
                    <div class="parallax-interactive-element">
                        <div class="tennis-ball-interactive"></div>
                    </div>
                    <span class="parallax-text fill-text">game</span>
                </div>
            </section>

            <!-- TESTIMONIALS SLIDER SECTION -->
            <section class="testimonials-section">
                <div class="swiper testimonial-swiper">
                    <div class="swiper-wrapper">
                        <!-- Testimonial 1 -->
                        <div class="swiper-slide testimonial-slide">
                            <div class="testimonial-content">
                                <p>"Consectetur adipiscing elit, sed do eiusm onsectetur adipiscing elit, sed do eiusm od tempor incididunt ut labore. Consectetur adipiscing elit, sed do eiusm onsectetur adipiscing elit, sed do eiusm unde."</p>
                                <div class="testimonial-author">
                                    <h4 class="author-name">Christine Merton</h4>
                                    <span class="author-location">Lowell, MS</span>
                                </div>
                            </div>
                        </div>
                        <!-- Testimonial 2 -->
                        <div class="swiper-slide testimonial-slide">
                            <div class="testimonial-content">
                                <p>"Consectetur adipiscing elit, sed do eiusm onsectetur adipiscing elit, sed do eiusm od tempor incididunt ut labore. Consectetur adipiscing elit, sed do eiusm onsectetur adipiscing elit, sed do eiusm unde."</p>
                                <div class="testimonial-author">
                                    <h4 class="author-name">James Parker</h4>
                                    <span class="author-location">Edison, NJ</span>
                                </div>
                            </div>
                        </div>
                        <!-- Testimonial 3 -->
                        <div class="swiper-slide testimonial-slide">
                            <div class="testimonial-content">
                                <p>"Consectetur adipiscing elit, sed do eiusm onsectetur adipiscing elit, sed do eiusm od tempor incididunt ut labore. Consectetur adipiscing elit, sed do eiusm onsectetur adipiscing elit, sed do eiusm unde."</p>
                                <div class="testimonial-author">
                                    <h4 class="author-name">Helen Miles</h4>
                                    <span class="author-location">Phoenix, AZ</span>
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
                    <button class="play-video-btn" aria-label="Play video">PLAY</button>
                </div>
            </section>

            <!-- NEWSLETTER SECTION -->
            <section class="newsletter-section">
                <div class="newsletter-container container">
                    <div class="newsletter-grid">
                        <div class="newsletter-heading">
                            <h2 class="newsletter-title">Subscribe for the exclusive updates!</h2>
                        </div>
                        <div class="newsletter-form-wrapper">
                            <form class="newsletter-form" onsubmit="event.preventDefault();">
                                <div class="input-group">
                                    <input type="email" placeholder="Your email address..." required aria-label="Email address">
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
                        <h4 class="footer-title">Hello, We Are TennisClub</h4>
                        <p class="footer-text">Inissimos ducimos qui blandiitis praesentium voluptatum deleniti.</p>
                    </div>
                    <!-- Column 2: Address -->
                    <div class="footer-col address-col">
                        <h4 class="footer-title">Office</h4>
                        <p class="footer-text">The USA —<br>11792 London Rd, Derby,<br>OH 43117, US</p>
                        <a href="mailto:info@email.com" class="footer-link-underline">info@email.com</a>
                        <a href="tel:+18005554565" class="footer-phone-link">+1 800 555 45 65</a>
                    </div>
                    <!-- Column 3: Links -->
                    <div class="footer-col links-col">
                        <h4 class="footer-title">Links</h4>
                        <ul class="footer-links-list">
                            <li><a href="#">Home</a></li>
                            <li><a href="#courts-section">Courts</a></li>
                            <li><a href="#">About</a></li>
                            <li><a href="#">Contact</a></li>
                        </ul>
                    </div>
                    <!-- Column 4: Socials -->
                    <div class="footer-col socials-col">
                        <h4 class="footer-title">Get in Touch</h4>
                        <div class="footer-social-wrap">
                            <a href="#" class="social-item"><span class="social-icon-wrapper"><i class="fa-brands fa-facebook-f"></i></span> Facebook</a>
                            <a href="#" class="social-item"><span class="social-icon-wrapper"><i class="fa-brands fa-x-twitter"></i></span> Twitter</a>
                            <a href="#" class="social-item"><span class="social-icon-wrapper"><i class="fa-brands fa-dribbble"></i></span> Dribble</a>
                            <a href="#" class="social-item"><span class="social-icon-wrapper"><i class="fa-brands fa-instagram"></i></span> Instagram</a>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Bottom Copyright Bar -->
            <div class="footer-bottom-bar container">
                <div class="copyright-content">
                    <p><a href="#" class="footer-tm-link">ThemeRex</a> © 2026. All Rights Reserved.</p>
                </div>
            </div>
        </footer>

        <!-- INTERACTIVE PANELS AND DRAWERS -->

        <!-- Shopping Cart Drawer (Right Side) -->
        <div class="drawer-panel cart-drawer" id="cart-drawer">
            <div class="drawer-header">
                <span class="drawer-title">Selected Bookings</span>
                <button class="drawer-close-btn" aria-label="Close Cart"><i class="fa-solid fa-xmark"></i></button>
            </div>
            <div class="drawer-body">
                <div class="empty-cart-message" id="cart-empty-state">
                    <i class="fa-solid fa-calendar-xmark"></i>
                    <p>No court yard reservation selected.</p>
                </div>
                <div class="cart-items-list" id="cart-items-list" style="display:none">
                    <!-- Dynamic bookings will list here -->
                </div>
            </div>
        </div>

        <!-- Info Drawer (Right Side) -->
        <div class="drawer-panel info-drawer" id="info-drawer">
            <div class="drawer-header">
                <a href="#" class="logo-link">
                    <span class="logo-icon"><i class="fa-solid fa-table-tennis-paddle-ball"></i></span>
                    <span class="logo-text">Tennis<span>Club</span></span>
                </a>
                <button class="drawer-close-btn" aria-label="Close Panel"><i class="fa-solid fa-xmark"></i></button>
            </div>
            <div class="drawer-body">
                <div class="drawer-socials">
                    <a href="#" class="social-item"><span class="social-icon-wrapper"><i class="fa-brands fa-facebook-f"></i></span> Facebook</a>
                    <a href="#" class="social-item"><span class="social-icon-wrapper"><i class="fa-brands fa-x-twitter"></i></span> Twitter</a>
                    <a href="#" class="social-item"><span class="social-icon-wrapper"><i class="fa-brands fa-dribbble"></i></span> Dribble</a>
                    <a href="#" class="social-item"><span class="social-icon-wrapper"><i class="fa-brands fa-instagram"></i></span> Instagram</a>
                </div>
                <div class="drawer-contacts">
                    <a href="tel:+18408412569" class="phone-link">+1 840 841 25 69</a>
                    <a href="mailto:info@email.com" class="email-link">info@email.com</a>
                </div>
            </div>
        </div>

        <!-- Fullscreen Search Overlay -->
        <div class="search-overlay" id="search-overlay">
            <div class="search-overlay-header container">
                <a href="#" class="logo-link">
                    <span class="logo-icon"><i class="fa-solid fa-table-tennis-paddle-ball"></i></span>
                    <span class="logo-text">Tennis<span>Club</span></span>
                </a>
                <button class="search-close-btn" aria-label="Close Search"><i class="fa-solid fa-xmark"></i></button>
            </div>
            <div class="search-overlay-body">
                <form class="search-form-overlay" onsubmit="event.preventDefault();">
                    <input type="text" class="search-input-field" placeholder="Type words and hit enter" autofocus aria-label="Search site">
                    <button type="submit" class="search-submit-btn"><i class="fa-solid fa-magnifying-glass"></i></button>
                </form>
            </div>
        </div>

        <!-- Mobile Menu Drawer -->
        <div class="drawer-panel mobile-menu-drawer" id="mobile-menu-drawer">
            <div class="drawer-header">
                <a href="#" class="logo-link">
                    <span class="logo-icon"><i class="fa-solid fa-table-tennis-paddle-ball"></i></span>
                    <span class="logo-text">Tennis<span>Club</span></span>
                </a>
                <button class="drawer-close-btn" aria-label="Close Menu"><i class="fa-solid fa-xmark"></i></button>
            </div>
            <div class="drawer-body">
                <!-- Mobile Navigation Links -->
                <nav class="mobile-nav-menu-area"></nav>
                <div class="mobile-socials-area"></div>
                <div class="mobile-additional-widgets">
                    <div class="extra-widget-item">
                        <h6>Have a Project?</h6>
                        <a href="mailto:info@website.com">info@website.com</a>
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

        <!-- Interactive Court Booking Scheduler Modal -->
        <div class="modal-overlay" id="booking-modal">
            <div class="booking-modal-card">
                <button class="modal-close-btn" id="booking-close-btn"><i class="fa-solid fa-xmark"></i></button>
                
                <h3 class="booking-modal-title" id="booking-modal-court-name">Reserve Tennis Court</h3>
                
                <div class="booking-modal-grid">
                    <!-- Left Column: Calendar & Court Info -->
                    <div class="booking-modal-left">
                        <div class="booking-court-details-card">
                            <span class="court-tag">Lựa chọn hàng đầu</span>
                            <p class="court-pricing-rate"><span id="booking-modal-court-price">$25.00</span> / giờ</p>
                        </div>
                        
                        <div class="custom-calendar-widget">
                            <div class="calendar-header">
                                <button class="calendar-nav-btn" id="cal-prev"><i class="fa-solid fa-chevron-left"></i></button>
                                <span class="calendar-current-month" id="cal-month-year">July 2026</span>
                                <button class="calendar-nav-btn" id="cal-next"><i class="fa-solid fa-chevron-right"></i></button>
                            </div>
                            <div class="calendar-weekdays">
                                <div>Su</div><div>Mo</div><div>Tu</div><div>We</div><div>Th</div><div>Fr</div><div>Sa</div>
                            </div>
                            <div class="calendar-days" id="calendar-days-grid">
                                <!-- Days injected via javascript -->
                            </div>
                        </div>
                        <p class="selected-date-indicator">Ngày đã chọn: <strong id="selected-date-txt">Chưa chọn</strong></p>
                    </div>

                    <!-- Right Column: Time Slots & Summary -->
                    <div class="booking-modal-right">
                        <h4 class="slot-column-title">Chọn khung giờ trống (Available Slots)</h4>
                        
                        <div class="time-slots-container">
                            <!-- Morning Slots -->
                            <div class="slot-group">
                                <span class="slot-group-header"><i class="fa-regular fa-sun"></i> Buổi Sáng (Morning)</span>
                                <div class="slots-grid">
                                    <button class="time-slot-btn" data-time="08:00">08:00 - 09:00</button>
                                    <button class="time-slot-btn" data-time="09:00">09:00 - 10:00</button>
                                    <button class="time-slot-btn booked" disabled data-time="10:00">10:00 - 11:00</button>
                                    <button class="time-slot-btn" data-time="11:00">11:00 - 12:00</button>
                                </div>
                            </div>
                            <!-- Afternoon Slots -->
                            <div class="slot-group">
                                <span class="slot-group-header"><i class="fa-solid fa-cloud-sun"></i> Buổi Chiều (Afternoon)</span>
                                <div class="slots-grid">
                                    <button class="time-slot-btn" data-time="13:00">13:00 - 14:00</button>
                                    <button class="time-slot-btn booked" disabled data-time="14:00">14:00 - 15:00</button>
                                    <button class="time-slot-btn" data-time="15:00">15:00 - 16:00</button>
                                    <button class="time-slot-btn" data-time="16:00">16:00 - 17:00</button>
                                </div>
                            </div>
                            <!-- Evening Slots -->
                            <div class="slot-group">
                                <span class="slot-group-header"><i class="fa-solid fa-moon"></i> Buổi Tối (Evening)</span>
                                <div class="slots-grid">
                                    <button class="time-slot-btn" data-time="17:00">17:00 - 18:00</button>
                                    <button class="time-slot-btn" data-time="18:00">18:00 - 19:00</button>
                                    <button class="time-slot-btn" data-time="19:00">19:00 - 20:00</button>
                                    <button class="time-slot-btn" data-time="20:00">20:00 - 21:00</button>
                                </div>
                            </div>
                        </div>

                        <!-- Booking Summary -->
                        <div class="booking-summary-box">
                            <div class="summary-line">
                                <span>Tổng thời gian:</span>
                                <span id="summary-total-hours">0 giờ</span>
                            </div>
                            <div class="summary-line highlight">
                                <span>Thành tiền (Total):</span>
                                <span id="summary-total-price">$0.00</span>
                            </div>
                            <button class="btn btn-black btn-full" id="confirm-booking-btn" style="margin-top:15px">Xác Nhận Đặt Sân</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>

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
    const currentUser = <%= loggedInUser != null ? "{ authenticated: true }" : "null" %>;
    let cartBookings = JSON.parse(localStorage.getItem('cartBookings')) || [];
    
    let selectedCourt = null;
    let selectedDate = null;
    let selectedSlots = [];
    
    let currentMonth = new Date().getMonth();
    let currentYear = new Date().getFullYear();

    const monthNames = [
        "January", "February", "March", "April", "May", "June", 
        "July", "August", "September", "October", "November", "December"
    ];


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
    const cartTrigger = document.querySelector('.cart-trigger');
    const infoTrigger = document.querySelector('.info-panel-trigger');
    const searchTrigger = document.querySelector('.search-trigger');
    const mobileMenuTrigger = document.querySelector('.mobile-menu-trigger');
    
    // Panels
    const cartDrawer = document.getElementById('cart-drawer');
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
        cartDrawer.classList.remove('active');
        infoDrawer.classList.remove('active');
        searchOverlay.classList.remove('active');
        mobileMenuDrawer.classList.remove('active');
        backdrop.classList.remove('active');
        body.classList.remove('panel-open');
        
        // Hide overlay modals
        if (window.closeAuthModal) window.closeAuthModal();
        document.getElementById('booking-modal').classList.remove('active');
    }

    // Bind triggers
    cartTrigger.addEventListener('click', (e) => {
        e.preventDefault();
        openPanel(cartDrawer);
        renderCartBookings();
    });

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
    // 8. INTERACTIVE COURT BOOKING SCHEDULER MODAL
    // ==========================================================================
    
    const bookingModal = document.getElementById('booking-modal');
    const bookingCloseBtn = document.getElementById('booking-close-btn');
    const calendarDaysGrid = document.getElementById('calendar-days-grid');
    const calMonthYear = document.getElementById('cal-month-year');
    
    // Scheduler inputs
    const confirmBookingBtn = document.getElementById('confirm-booking-btn');
    const timeSlots = document.querySelectorAll('.time-slot-btn');
    const summaryTotalHours = document.getElementById('summary-total-hours');
    const summaryTotalPrice = document.getElementById('summary-total-price');

    // Calendar navigation
    document.getElementById('cal-prev').addEventListener('click', () => {
        currentMonth--;
        if (currentMonth < 0) {
            currentMonth = 11;
            currentYear--;
        }
        buildCalendar();
    });

    document.getElementById('cal-next').addEventListener('click', () => {
        currentMonth++;
        if (currentMonth > 11) {
            currentMonth = 0;
            currentYear++;
        }
        buildCalendar();
    });

    // Opening scheduler modal
    function openBookingModal(court) {
        selectedCourt = court;
        document.getElementById('booking-modal-court-name').textContent = court.name;
        document.getElementById('booking-modal-court-price').textContent = `$\${parseFloat(court.price).toFixed(2)}`;
        
        // Reset selections
        selectedDate = null;
        selectedSlots = [];
        document.getElementById('selected-date-txt').textContent = "Chưa chọn";
        resetSlotsVisualState();
        updateSummaryBox();
        
        buildCalendar();
        
        bookingModal.classList.add('active');
        body.classList.add('panel-open');
    }

    // Court cards Book action triggers
    document.querySelectorAll('.court-card').forEach(card => {
        const bookBtn = card.querySelector('.book-btn');
        const overlayBookBtn = card.querySelector('.court-book-now-btn');
        
        const courtDetails = {
            id: card.dataset.courtId,
            name: card.dataset.courtName,
            price: parseFloat(card.dataset.price)
        };

        const triggerAction = (e) => {
            e.preventDefault();
            openBookingModal(courtDetails);
        };

        if (bookBtn) bookBtn.addEventListener('click', triggerAction);
        if (overlayBookBtn) overlayBookBtn.addEventListener('click', triggerAction);
    });

    bookingCloseBtn.addEventListener('click', () => {
        bookingModal.classList.remove('active');
        body.classList.remove('panel-open');
    });

    // CALENDAR DAYS GENERATOR
    function buildCalendar() {
        calendarDaysGrid.innerHTML = '';
        calMonthYear.textContent = `\${monthNames[currentMonth]} \${currentYear}`;

        const firstDayIndex = new Date(currentYear, currentMonth, 1).getDay();
        const totalDays = new Date(currentYear, currentMonth + 1, 0).getDate();
        
        const today = new Date();
        today.setHours(0,0,0,0);

        // Blank days (padding offset)
        for (let i = 0; i < firstDayIndex; i++) {
            const blank = document.createElement('div');
            calendarDaysGrid.appendChild(blank);
        }

        // Active calendar days
        for (let day = 1; day <= totalDays; day++) {
            const cell = document.createElement('div');
            cell.className = "calendar-day-cell";
            cell.textContent = day;

            const cellDate = new Date(currentYear, currentMonth, day);
            cellDate.setHours(0,0,0,0);

            // Disable past dates
            if (cellDate < today) {
                cell.classList.add('disabled');
            } else {
                // If matched selected date
                const dateStr = `\${currentYear}-\${String(currentMonth + 1).padStart(2, '0')}-\${String(day).padStart(2, '0')}`;
                if (selectedDate === dateStr) {
                    cell.classList.add('active');
                }
                
                cell.addEventListener('click', () => {
                    // Remove active from other days
                    document.querySelectorAll('.calendar-day-cell').forEach(c => c.classList.remove('active'));
                    cell.classList.add('active');
                    
                    selectedDate = dateStr;
                    document.getElementById('selected-date-txt').textContent = `\${day} \${monthNames[currentMonth]} \${currentYear}`;
                    
                    // Reset selected slots on date change
                    selectedSlots = [];
                    resetSlotsVisualState();
                    updateSummaryBox();
                });
            }

            calendarDaysGrid.appendChild(cell);
        }
    }

    // Slots selections
    timeSlots.forEach(slot => {
        slot.addEventListener('click', () => {
            if (!selectedDate) {
                alert("Vui lòng chọn ngày trên lịch trước khi chọn giờ đặt sân!");
                return;
            }
            
            const time = slot.dataset.time;
            if (slot.classList.contains('selected')) {
                slot.classList.remove('selected');
                selectedSlots = selectedSlots.filter(s => s !== time);
            } else {
                slot.classList.add('selected');
                selectedSlots.push(time);
            }
            
            updateSummaryBox();
        });
    });

    function resetSlotsVisualState() {
        timeSlots.forEach(slot => {
            slot.classList.remove('selected');
        });
    }

    function updateSummaryBox() {
        summaryTotalHours.textContent = `\${selectedSlots.length} giờ`;
        const totalCost = selectedSlots.length * (selectedCourt ? selectedCourt.price : 0);
        summaryTotalPrice.textContent = `$\${totalCost.toFixed(2)}`;
    }

    // CONFIRM COURT BOOKING TRIGGER (AUTHENTICATION CHECKPOINT)
    confirmBookingBtn.addEventListener('click', () => {
        if (!selectedDate) {
            alert("Vui lòng chọn ngày đặt sân trên lịch!");
            return;
        }
        if (selectedSlots.length === 0) {
            alert("Vui lòng lựa chọn ít nhất một khung giờ trống!");
            return;
        }

        // Lock check: User must be signed in
        if (!currentUser) {
            alert("Bạn cần Đăng Nhập / Đăng Ký để thực hiện đặt sân!");
            // Hide booking modal and pop open the real auth modal
            bookingModal.classList.remove('active');
            openAuthModal('login');
            return;
        }

        // No real backend endpoint exists to book an arbitrary homepage court by id —
        // hand off to the real search/booking page instead of faking success.
        window.location.href = (window.contextPath || '') + '/customer/dat-san';
    });


    // ==========================================================================
    // 9. BOOKING CART ITEM DRAWERS LIST
    // ==========================================================================
    
    const cartEmptyState = document.getElementById('cart-empty-state');
    const cartItemsList = document.getElementById('cart-items-list');

    function updateCartBadge() {
        const badges = document.querySelectorAll('.cart-badge');
        badges.forEach(badge => {
            badge.textContent = cartBookings.length;
        });
    }
    updateCartBadge();

    function renderCartBookings() {
        if (cartBookings.length === 0) {
            cartEmptyState.style.display = 'flex';
            cartItemsList.style.display = 'none';
        } else {
            cartEmptyState.style.display = 'none';
            cartItemsList.style.display = 'flex';
            
            cartItemsList.innerHTML = '';
            cartBookings.forEach(booking => {
                const item = document.createElement('div');
                item.className = "booking-cart-item";
                
                // Formatted slots text
                const slotsTxt = booking.slots.map(s => `\${s}:00`).join(', ');

                item.innerHTML = `
                    <button class="delete-item-btn" aria-label="Delete Booking" data-id="\${booking.id}">
                        <i class="fa-regular fa-trash-can"></i>
                    </button>
                    <h4 class="cart-item-title">\${booking.courtName}</h4>
                    <div class="cart-item-meta">
                        <span><i class="fa-regular fa-calendar"></i> Ngày đặt: \${booking.date}</span>
                        <span><i class="fa-regular fa-clock"></i> Khung giờ: \${slotsTxt}</span>
                    </div>
                    <span class="cart-item-price">Tổng cộng: $\${parseFloat(booking.totalPrice).toFixed(2)}</span>
                `;
                
                // Remove button logic
                item.querySelector('.delete-item-btn').addEventListener('click', (e) => {
                    const id = e.currentTarget.dataset.id;
                    cartBookings = cartBookings.filter(b => b.id !== id);
                    localStorage.setItem('cartBookings', JSON.stringify(cartBookings));
                    updateCartBadge();
                    renderCartBookings();
                });

                cartItemsList.appendChild(item);
            });
        }
    }


    // ==========================================================================
    // 10. SCROLL TO TOP ACTION
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
