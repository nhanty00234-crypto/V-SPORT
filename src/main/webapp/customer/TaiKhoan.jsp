<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<<<<<<< HEAD
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
=======
<jsp:include page="/common/xtra-head.jsp" />
<style>
/* Add the specific styles for Account page here, inheriting from XtraMarket theme */
.account-wrapper {
    padding: 60px 0;
    background-color: var(--background);
}
.account-container {
    display: flex;
    gap: 30px;
    width: 100%;
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 20px;
}
.account-sidebar {
    width: 280px;
    flex-shrink: 0;
}
.account-main {
    flex: 1;
    min-width: 0;
}
.profile-card {
    background: var(--surface);
    border-radius: var(--radius-medium);
    padding: 25px;
    text-align: center;
    box-shadow: var(--shadow-small);
    margin-bottom: 20px;
}
.profile-avatar {
    width: 80px;
    height: 80px;
    border-radius: 50%;
    background: var(--primary);
    color: var(--surface);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 32px;
    font-weight: 700;
    margin: 0 auto 15px;
}
.profile-name {
    font-size: 20px;
    font-weight: 700;
    color: var(--navy);
    margin-bottom: 5px;
}
.profile-email {
    font-size: 14px;
    color: var(--muted-text);
    margin-bottom: 15px;
}
.profile-rep {
    display: inline-block;
    padding: 5px 12px;
    background: rgba(1, 226, 129, 0.1);
    color: var(--primary-hover);
    border-radius: 50px;
    font-size: 13px;
    font-weight: 600;
    margin-bottom: 20px;
    text-decoration: none;
}
.profile-rep:hover { text-decoration: underline; }
.stat-card.stat-card-link { cursor: pointer; text-decoration: none; transition: var(--transition); }
.stat-card.stat-card-link:hover { border-color: var(--primary); transform: translateY(-2px); }
.menu-card {
    background: var(--surface);
    border-radius: var(--radius-medium);
    box-shadow: var(--shadow-small);
    overflow: hidden;
}
.menu-item {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 15px 20px;
    color: var(--body-text);
    font-weight: 500;
    border-left: 3px solid transparent;
    transition: var(--transition);
}
.menu-item:hover {
    background: var(--background);
    color: var(--primary-hover);
}
.menu-item.active {
    background: rgba(1, 226, 129, 0.05);
    color: var(--primary-hover);
    border-left-color: var(--primary);
    font-weight: 600;
}
.menu-item i {
    font-size: 18px;
    width: 20px;
    text-align: center;
}
.menu-item.danger {
    color: var(--danger);
}
.menu-item.danger:hover {
    background: rgba(255, 71, 87, 0.05);
    color: var(--danger);
}
.breadcrumb {
    font-size: 14px;
    color: var(--muted-text);
    margin-bottom: 20px;
}
.breadcrumb a {
    color: var(--navy);
}
.breadcrumb a:hover {
    color: var(--primary);
}
.page-title {
    font-size: 32px;
    margin-bottom: 5px;
}
.page-desc {
    color: var(--muted-text);
    margin-bottom: 30px;
}
.stats-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 20px;
    margin-bottom: 30px;
}
.stat-card {
    background: var(--surface);
    border-radius: var(--radius-medium);
    padding: 20px;
    box-shadow: var(--shadow-small);
    border: 1px solid var(--border);
    display: flex;
    align-items: flex-start;
    gap: 15px;
}
.stat-icon {
    width: 48px;
    height: 48px;
    border-radius: 50%;
    background: rgba(1, 226, 129, 0.1);
    color: var(--primary-hover);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 20px;
}
.stat-info h3 {
    font-size: 24px;
    margin-bottom: 0;
    color: var(--navy);
}
.stat-info p {
    font-size: 13px;
    color: var(--muted-text);
    margin: 0;
}
.section-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
}
.section-header h2 {
    font-size: 22px;
}
.booking-list {
    display: flex;
    flex-direction: column;
    gap: 15px;
    margin-bottom: 30px;
}
.booking-item {
    background: var(--surface);
    border-radius: var(--radius-medium);
    padding: 20px;
    box-shadow: var(--shadow-small);
    border: 1px solid var(--border);
    display: flex;
    justify-content: space-between;
    align-items: center;
}
.booking-info {
    display: flex;
    flex-direction: column;
    gap: 5px;
}
.booking-title {
    font-size: 18px;
    font-weight: 700;
    color: var(--navy);
    display: flex;
    align-items: center;
    gap: 10px;
}
.booking-meta {
    font-size: 14px;
    color: var(--muted-text);
    display: flex;
    align-items: center;
    gap: 15px;
}
.badge-status {
    padding: 4px 10px;
    border-radius: 6px;
    font-size: 12px;
    font-weight: 600;
}
.status-wait { background: #fff3cd; color: #856404; border: 1px solid #ffeeba; }
.status-ok { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
.status-live { background: #cce5ff; color: #004085; border: 1px solid #b8daff; }
.status-cancel { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
.quick-actions {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 15px;
}
.action-card {
    background: var(--surface);
    border-radius: var(--radius-medium);
    padding: 20px;
    text-align: center;
    box-shadow: var(--shadow-small);
    border: 1px solid var(--border);
    transition: var(--transition);
}
.action-card:hover {
    border-color: var(--primary);
    transform: translateY(-2px);
}
.action-icon {
    width: 50px;
    height: 50px;
    border-radius: 50%;
    background: var(--background);
    color: var(--navy);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 20px;
    margin: 0 auto 10px;
    transition: var(--transition);
}
.action-card:hover .action-icon {
    background: var(--primary);
    color: var(--surface);
}
.action-title {
    font-size: 14px;
    font-weight: 600;
    color: var(--navy);
}
>>>>>>> fix/teacher-review-remediation

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

<<<<<<< HEAD
<div class="acc-page-wrapper">
    <jsp:include page="/customer/common/account-profile-banner.jsp" />

    <div class="acc-main-container">
        <c:set var="activePage" value="overview" scope="request" />
        <jsp:include page="/customer/common/account-sidebar.jsp" />
=======
<div class="account-wrapper">
    <div class="account-container">
        <!-- Sidebar -->
        <aside class="account-sidebar">
            <div class="profile-card">
                <div class="profile-avatar">
                    <c:choose>
                        <c:when test="${not empty account.fullName}">${fn:escapeXml(fn:substring(account.fullName, 0, 1).toUpperCase())}</c:when>
                        <c:otherwise>${fn:escapeXml(fn:substring(account.username, 0, 1).toUpperCase())}</c:otherwise>
                    </c:choose>
                </div>
                <div class="profile-name">${fn:escapeXml(not empty account.fullName ? account.fullName : account.username)}</div>
                <div class="profile-email">${not empty account.email ? fn:escapeXml(account.email) : 'Chưa cập nhật email'}</div>
                <c:if test="${not empty account.phoneNumber}">
                    <div class="profile-email" style="margin-top: -10px;">${fn:escapeXml(account.phoneNumber)}</div>
                </c:if>
                <a href="${pageContext.request.contextPath}/customer/lich-su-diem-uy-tin" class="profile-rep">
                    <i class="fas fa-star" style="margin-right: 5px;"></i> Uy tín: ${account.diemUyTin}/100
                </a>
                <div>
                    <a href="${pageContext.request.contextPath}/customer/ho-so" class="btn btn-outline" style="color: var(--navy); border-color: var(--border); width: 100%; margin-bottom: 10px;">Chỉnh sửa hồ sơ</a>
                </div>
            </div>

            
            <div class="menu-card">
                <a href="${pageContext.request.contextPath}/customer/tai-khoan" class="menu-item active">
                    <i class="fas fa-home"></i> Tổng quan
                </a>
                <a href="${pageContext.request.contextPath}/customer/lich-su-diem-uy-tin" class="menu-item">
                    <i class="fas fa-star"></i> Điểm uy tín
                </a>
                <a href="${pageContext.request.contextPath}/customer/ghep-keo?tab=cua-toi" class="menu-item">
                    <i class="fas fa-futbol"></i> Kèo của tôi
                </a>
                <a href="${pageContext.request.contextPath}/customer/dich-vu-cua-toi" class="menu-item">
                    <i class="fas fa-screwdriver-wrench"></i> Dịch vụ của tôi
                </a>
                <a href="${pageContext.request.contextPath}/customer/doi-nhom" class="menu-item">
                    <i class="fas fa-users"></i> Nhóm của tôi
                </a>
                <a href="${pageContext.request.contextPath}/customer/doi-mat-khau" class="menu-item">
                    <i class="fas fa-lock"></i> Đổi mật khẩu
                </a>
                <a href="${pageContext.request.contextPath}/logout" class="menu-item danger">
                    <i class="fas fa-sign-out-alt"></i> Đăng xuất
                </a>
            </div>
</aside>
>>>>>>> fix/teacher-review-remediation

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
