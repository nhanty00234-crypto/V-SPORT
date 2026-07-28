<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tài Khoản Của Tôi - V-SPORT</title>
    <jsp:include page="/common/xtra-head.jsp" />
    <style>
        .acc-page-wrapper {
            background-color: var(--background);
            padding-bottom: 60px;
            animation: accFadeIn 0.25s ease-out;
        }
        @keyframes accFadeIn {
            from { opacity: 0; transform: translateY(6px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        /* Hero Banner Header */
        .acc-hero {
            background: linear-gradient(135deg, var(--navy-dark) 0%, var(--navy) 60%, #163e5c 100%);
            color: #fff;
            padding: 36px 0 32px 0;
            margin-bottom: 32px;
            box-shadow: inset 0 -1px 0 rgba(255,255,255,0.08);
        }
        .acc-hero-inner {
            max-width: var(--container-width, 1320px);
            margin: 0 auto;
            padding: 0 20px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 24px;
        }
        .acc-user-profile {
            display: flex;
            align-items: center;
            gap: 20px;
        }
        .acc-avatar-circle {
            width: 76px;
            height: 76px;
            border-radius: 50%;
            background: var(--primary);
            color: var(--navy);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 32px;
            font-weight: 800;
            font-family: 'Outfit', sans-serif;
            box-shadow: 0 0 0 4px rgba(1, 226, 129, 0.25);
            flex-shrink: 0;
        }
        .acc-user-info {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }
        .acc-user-name {
            font-size: 24px;
            font-weight: 800;
            color: #ffffff;
            font-family: 'Outfit', sans-serif;
            margin: 0;
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .acc-user-meta {
            font-size: 13.5px;
            color: rgba(255, 255, 255, 0.75);
            display: flex;
            align-items: center;
            gap: 14px;
            flex-wrap: wrap;
        }
        .acc-user-meta i {
            color: var(--primary);
        }
        .acc-rep-chip {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 4px 12px;
            border-radius: 999px;
            background: rgba(1, 226, 129, 0.15);
            color: var(--primary);
            font-size: 12px;
            font-weight: 700;
            border: 1px solid rgba(1, 226, 129, 0.3);
        }

        .acc-hero-actions {
            display: flex;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
        }
        .acc-hero-btn {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 20px;
            border-radius: 12px;
            font-size: 13.5px;
            font-weight: 700;
            text-decoration: none;
            transition: all 0.2s ease;
            border: none;
            cursor: pointer;
        }
        .acc-btn-primary {
            background: var(--primary);
            color: var(--navy);
            box-shadow: 0 4px 12px rgba(1, 226, 129, 0.25);
        }
        .acc-btn-primary:hover {
            background: var(--primary-hover);
            color: var(--navy);
            transform: translateY(-1px);
        }
        .acc-btn-glass {
            background: rgba(255, 255, 255, 0.1);
            color: #ffffff;
            border: 1px solid rgba(255, 255, 255, 0.15);
        }
        .acc-btn-glass:hover {
            background: rgba(255, 255, 255, 0.2);
            color: #ffffff;
        }

        /* Container Grid */
        .acc-main-container {
            max-width: var(--container-width, 1320px);
            margin: 0 auto;
            padding: 0 20px;
            display: grid;
            grid-template-columns: 280px 1fr;
            gap: 28px;
        }

        /* Sidebar Navigation */
        .acc-sidebar {
            display: flex;
            flex-direction: column;
            gap: 16px;
        }
        .acc-nav-card {
            background: #ffffff;
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 10px;
            box-shadow: var(--shadow-small);
        }
        .acc-nav-item {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 12px 16px;
            border-radius: 10px;
            font-size: 14px;
            font-weight: 600;
            color: var(--body-text);
            text-decoration: none;
            transition: all 0.2s ease;
            cursor: pointer;
            border: none;
            background: transparent;
            width: 100%;
            text-align: left;
            box-sizing: border-box;
        }
        .acc-nav-item i {
            font-size: 16px;
            width: 20px;
            text-align: center;
            color: var(--muted-text);
            transition: color 0.2s;
        }
        .acc-nav-item:hover {
            background: #f8fafc;
            color: var(--navy);
        }
        .acc-nav-item:hover i {
            color: var(--primary-hover);
        }
        .acc-nav-item.active {
            background: rgba(1, 226, 129, 0.12);
            color: var(--navy);
            font-weight: 800;
        }
        .acc-nav-item.active i {
            color: #01c771;
        }
        .acc-nav-item.danger {
            color: #dc2626;
        }
        .acc-nav-item.danger:hover {
            background: #fff0f0;
            color: #b91c1c;
        }
        .acc-nav-item.danger i {
            color: #dc2626;
        }

        /* Main Panel */
        .acc-main-panel {
            min-width: 0;
        }
        .acc-content-card {
            background: #ffffff;
            border: 1px solid var(--border);
            border-radius: 20px;
            padding: 28px;
            box-shadow: var(--shadow-small);
        }

        /* Stats Grid */
        .acc-stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 16px;
            margin-bottom: 28px;
        }
        .acc-stat-box {
            background: #f8fafc;
            border: 1px solid var(--border);
            border-radius: 14px;
            padding: 18px 20px;
            display: flex;
            align-items: center;
            gap: 16px;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .acc-stat-box:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-medium);
        }
        .acc-stat-icon {
            width: 48px;
            height: 48px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
            flex-shrink: 0;
        }
        .acc-stat-num {
            font-size: 24px;
            font-weight: 800;
            color: var(--navy);
            font-family: 'Outfit', sans-serif;
            line-height: 1;
            margin-bottom: 4px;
        }
        .acc-stat-lbl {
            font-size: 12.5px;
            font-weight: 600;
            color: var(--muted-text);
        }

        /* Section Titles */
        .acc-sec-title {
            font-size: 18px;
            font-weight: 800;
            color: var(--navy);
            font-family: 'Outfit', sans-serif;
            margin: 0 0 16px 0;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        /* Booking Cards */
        .acc-booking-card {
            background: #fff;
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 20px 24px;
            margin-bottom: 16px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
            transition: border-color 0.2s, box-shadow 0.2s;
        }
        .acc-booking-card:hover {
            border-color: #cbd5e1;
            box-shadow: var(--shadow-medium);
        }

        /* Quick Shortcuts Grid */
        .acc-shortcuts-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 16px;
            margin-top: 12px;
        }
        .acc-shortcut-item {
            background: #f8fafc;
            border: 1px solid var(--border);
            border-radius: 14px;
            padding: 20px 16px;
            text-align: center;
            text-decoration: none;
            color: var(--navy);
            transition: all 0.2s ease;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 10px;
        }
        .acc-shortcut-item:hover {
            background: #ffffff;
            border-color: var(--primary);
            transform: translateY(-2px);
            box-shadow: var(--shadow-medium);
        }
        .acc-shortcut-icon {
            width: 44px;
            height: 44px;
            border-radius: 12px;
            background: rgba(1, 226, 129, 0.12);
            color: var(--navy);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
        }
        .acc-shortcut-lbl {
            font-size: 13.5px;
            font-weight: 700;
        }

        @media (max-width: 1024px) {
            .acc-main-container { grid-template-columns: 1fr; }
            .acc-stats-grid { grid-template-columns: repeat(2, 1fr); }
            .acc-shortcuts-grid { grid-template-columns: repeat(2, 1fr); }
        }
        @media (max-width: 640px) {
            .acc-stats-grid { grid-template-columns: 1fr; }
            .acc-shortcuts-grid { grid-template-columns: repeat(2, 1fr); }
            .acc-booking-card { flex-direction: column; align-items: flex-start; }
            .acc-user-profile { flex-direction: column; text-align: center; }
            .acc-user-name { justify-content: center; }
            .acc-user-meta { justify-content: center; }
            .acc-hero-inner { justify-content: center; text-align: center; }
        }
    </style>
</head>
<body>

<jsp:include page="/common/header-xtra.jsp" />

<div class="acc-page-wrapper">
    <jsp:include page="/customer/common/account-profile-banner.jsp" />

    <div class="acc-main-container">
        <c:set var="activePage" value="overview" scope="request" />
        <jsp:include page="/customer/common/account-sidebar.jsp" />

        <main class="acc-main-panel">
            <div id="acc-panel-overview" class="acc-content-card">
                <jsp:include page="/customer/fragments/overview.jsp" />
            </div>
        </main>
    </div>
</div>

<jsp:include page="/common/footer.jsp" />
</body>
</html>
