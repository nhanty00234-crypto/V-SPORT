<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nhóm Của Tôi - V-SPORT</title>
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
            background: linear-gradient(135deg, #1b5e42 0%, #287A58 55%, #3aaa72 100%);
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

        /* Main Content Card */
        .acc-content-card {
            background: #ffffff;
            border: 1px solid var(--border);
            border-radius: 20px;
            padding: 28px;
            box-shadow: var(--shadow-small);
        }

        /* Page Header inside Card */
        .dn-header-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 16px;
            margin-bottom: 24px;
            padding-bottom: 20px;
            border-bottom: 1px solid var(--border);
        }
        .dn-header-title-wrap {
            display: flex;
            align-items: center;
            gap: 14px;
        }
        .dn-header-icon {
            width: 48px;
            height: 48px;
            border-radius: 14px;
            background: rgba(1, 226, 129, 0.15);
            color: var(--navy);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 22px;
            flex-shrink: 0;
        }
        .dn-header-title {
            font-size: 22px;
            font-weight: 800;
            color: var(--navy);
            font-family: 'Outfit', sans-serif;
            margin: 0 0 4px 0;
        }
        .dn-header-desc {
            font-size: 13.5px;
            color: var(--muted-text);
            margin: 0;
        }
        .dn-create-btn {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 20px;
            border-radius: 12px;
            background: var(--primary);
            color: var(--navy);
            font-size: 13.5px;
            font-weight: 800;
            text-decoration: none;
            box-shadow: 0 4px 12px rgba(1, 226, 129, 0.25);
            transition: all 0.2s ease;
        }
        .dn-create-btn:hover {
            background: var(--primary-hover);
            color: var(--navy);
            transform: translateY(-1px);
        }

        /* Summary Stat Cards */
        .dn-stats-row {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 16px;
            margin-bottom: 24px;
        }
        .dn-stat-card {
            background: #f8fafc;
            border: 1px solid var(--border);
            border-radius: 14px;
            padding: 16px 20px;
            display: flex;
            align-items: center;
            gap: 16px;
        }
        .dn-stat-icon-wrap {
            width: 42px;
            height: 42px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
        }
        .dn-stat-val {
            font-size: 22px;
            font-weight: 800;
            color: var(--navy);
            font-family: 'Outfit', sans-serif;
            line-height: 1;
        }
        .dn-stat-lbl {
            font-size: 12.5px;
            font-weight: 600;
            color: var(--muted-text);
            margin-top: 4px;
        }

        /* Tab Switcher */
        .dn-tabs {
            display: flex;
            gap: 8px;
            background: #f1f5f9;
            border-radius: 12px;
            padding: 5px;
            margin-bottom: 24px;
        }
        .dn-tab {
            flex: 1;
            border: none;
            background: transparent;
            cursor: pointer;
            padding: 10px 16px;
            font-size: 13.5px;
            font-weight: 700;
            color: var(--muted-text);
            border-radius: 8px;
            transition: all 0.2s ease;
            text-align: center;
        }
        .dn-tab.is-active {
            background: #ffffff;
            color: var(--navy);
            box-shadow: 0 2px 6px rgba(0,0,0,0.06);
        }

        .dn-panel { display: none; }
        .dn-panel.is-active { display: block; }

        /* Filter Controls */
        .dn-filters {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            margin-bottom: 20px;
        }
        .dn-filters input[type="text"] {
            flex: 1 1 240px;
            padding: 10px 16px;
            border-radius: 10px;
            border: 1px solid var(--border);
            font-size: 13.5px;
            outline: none;
            background: #f8fafc;
        }
        .dn-filters input[type="text"]:focus {
            border-color: var(--primary);
            background: #fff;
        }
        .dn-filters select {
            padding: 10px 14px;
            border-radius: 10px;
            border: 1px solid var(--border);
            background: #f8fafc;
            font-size: 13.5px;
            outline: none;
        }
        .dn-filter-toggle {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 14px;
            border-radius: 10px;
            border: 1px solid var(--border);
            background: #f8fafc;
            font-size: 13.5px;
            font-weight: 600;
            cursor: pointer;
        }

        /* Team Grid & Cards */
        .dn-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 16px;
        }
        @media (max-width: 768px) {
            .dn-grid { grid-template-columns: 1fr; }
            .acc-main-container { grid-template-columns: 1fr; }
            .dn-stats-row { grid-template-columns: 1fr; }
        }

        .dn-card {
            background: #ffffff;
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 20px;
            display: flex;
            flex-direction: column;
            gap: 14px;
            transition: all 0.2s ease;
        }
        .dn-card:hover {
            border-color: #cbd5e1;
            box-shadow: 0 4px 16px rgba(0,0,0,0.06);
        }
        .dn-card-top { display: flex; gap: 14px; align-items: flex-start; }
        .dn-avatar {
            width: 52px;
            height: 52px;
            border-radius: 12px;
            object-fit: cover;
            flex-shrink: 0;
            background: rgba(1, 226, 129, 0.15);
            border: 1px solid var(--border);
        }
        .dn-card-name { font-size: 16px; font-weight: 800; color: var(--navy); margin: 0; font-family: 'Outfit', sans-serif; }
        .dn-card-meta { font-size: 13px; color: var(--muted-text); margin-top: 4px; display: flex; flex-wrap: wrap; gap: 6px; }
        .dn-card-desc { font-size: 13px; color: var(--body-text); line-height: 1.5; margin: 0; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }

        .dn-badges-row { display: flex; flex-wrap: wrap; gap: 8px; align-items: center; }
        .dn-badge { display: inline-flex; align-items: center; gap: 4px; padding: 4px 10px; border-radius: 999px; font-size: 11.5px; font-weight: 700; }
        .dn-badge.role { background: rgba(1, 226, 129, 0.15); color: var(--navy); border: 1px solid rgba(1, 226, 129, 0.3); }
        .dn-badge.slots { background: #f1f5f9; color: var(--muted-text); }
        .dn-badge.slots.full { background: #fef2f2; color: #dc2626; }

        .dn-card-actions { display: flex; gap: 8px; margin-top: auto; }
        .dn-btn {
            flex: 1; text-align: center; padding: 9px 14px; border-radius: 10px; font-size: 13px; font-weight: 700;
            border: 1px solid var(--border); background: #fff; color: var(--navy); cursor: pointer; text-decoration: none;
            transition: all 0.15s ease; display: inline-flex; align-items: center; justify-content: center;
        }
        .dn-btn:hover { border-color: var(--navy); background: #f8fafc; }
        .dn-btn.primary { background: var(--primary); border-color: var(--primary); color: var(--navy); font-weight: 800; }
        .dn-btn.primary:hover { background: var(--primary-hover); }
        .dn-btn.secondary { background: var(--navy); border-color: var(--navy); color: #fff; }
        .dn-btn.secondary:hover { background: var(--navy-dark); }
        .dn-btn:disabled { opacity: 0.6; cursor: not-allowed; }

        /* Empty States */
        .dn-empty { text-align: center; padding: 48px 20px; background: #f8fafc; border-radius: 16px; border: 1px solid var(--border); }
        .dn-empty-icon {
            width: 64px; height: 64px; border-radius: 50%;
            background: rgba(1, 226, 129, 0.15); display: flex; align-items: center; justify-content: center;
            margin: 0 auto 16px; color: var(--navy); font-size: 26px;
        }
        .dn-empty h2 { font-size: 17px; font-weight: 800; margin: 0 0 6px; color: var(--navy); }
        .dn-empty p { font-size: 13.5px; color: var(--muted-text); margin: 0 0 18px; }

        /* Toast */
        .dn-toast {
            position: fixed; left: 50%; bottom: 30px;
            transform: translateX(-50%) translateY(12px); z-index: 1300;
            background: var(--navy); color: #fff; padding: 10px 20px; border-radius: 999px;
            font-size: 13.5px; font-weight: 700; opacity: 0; visibility: hidden;
            transition: opacity .2s ease, transform .2s ease; box-shadow: 0 8px 22px rgba(0,0,0,.2);
        }
        .dn-toast.is-open { opacity: 1; visibility: visible; transform: translateX(-50%) translateY(0); }
        .dn-toast.is-danger { background: #dc2626; }
        .dn-toast.is-success { background: #059669; }
    </style>
</head>
<body>

<jsp:include page="/common/header-xtra.jsp" />

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<div class="acc-page-wrapper">
    <jsp:include page="/customer/common/account-profile-banner.jsp" />

    <div class="acc-main-container">
        <c:set var="activePage" value="teams" scope="request" />
        <jsp:include page="/customer/common/account-sidebar.jsp" />

        <main class="acc-main-panel">
            <div class="acc-content-card">
                <!-- Header Section -->
                <div class="dn-header-row">
                    <div class="dn-header-title-wrap">
                        <div class="dn-header-icon"><i class="fas fa-users"></i></div>
                        <div>
                            <h2 class="dn-header-title">Nhóm của tôi</h2>
                            <p class="dn-header-desc">Quản lý đội thể thao, thành viên và các lời mời của bạn.</p>
                        </div>
                    </div>
                    <a class="dn-create-btn" href="${ctx}/customer/doi-nhom/tao">
                        <i class="fas fa-plus"></i> Tạo đội mới
                    </a>
                </div>

                <!-- Summary Cards -->
                <div class="dn-stats-row">
                    <div class="dn-stat-card">
                        <div class="dn-stat-icon-wrap" style="background: rgba(1, 226, 129, 0.15); color: var(--navy);">
                            <i class="fas fa-users"></i>
                        </div>
                        <div>
                            <div class="dn-stat-val" id="sumMyTeamsCount">${fn:length(myTeams)}</div>
                            <div class="dn-stat-lbl">Đội đang tham gia</div>
                        </div>
                    </div>
                    <div class="dn-stat-card">
                        <div class="dn-stat-icon-wrap" style="background: rgba(245, 158, 11, 0.15); color: #d97706;">
                            <i class="fas fa-envelope-open-text"></i>
                        </div>
                        <div>
                            <div class="dn-stat-val" id="sumInvitesCount">${fn:length(invitations)}</div>
                            <div class="dn-stat-lbl">Lời mời đang chờ</div>
                        </div>
                    </div>
                </div>

                <!-- Tabs -->
                <div class="dn-tabs" role="tablist" aria-label="Chuyển tab đội nhóm">
                    <button type="button" class="dn-tab" data-tab="my-teams" role="tab">Đội của bạn</button>
                    <button type="button" class="dn-tab" data-tab="discover" role="tab">Tìm đội tham gia</button>
                    <button type="button" class="dn-tab" data-tab="invitations" role="tab">Lời mời (${fn:length(invitations)})</button>
                </div>

                <!-- Tab 1: Đội của bạn -->
                <section class="dn-panel" data-panel="my-teams">
                    <div id="dnMyTeamsGrid" class="dn-grid"></div>
                    <div id="dnMyTeamsEmpty" class="dn-empty" style="display:none;">
                        <div class="dn-empty-icon"><i class="fas fa-user-friends"></i></div>
                        <h2>Bạn chưa tham gia nhóm nào</h2>
                        <p>Tạo nhóm mới hoặc tìm kiếm đội phù hợp để tham gia ngay.</p>
                        <div style="display:flex; gap:10px; justify-content:center;">
                            <a class="dn-btn primary" href="${ctx}/customer/doi-nhom/tao" style="flex:0 0 auto; padding: 10px 22px;">Tạo nhóm</a>
                            <button type="button" class="dn-btn" data-goto-tab="discover" style="flex:0 0 auto; padding: 10px 22px;">Tìm đội</button>
                        </div>
                    </div>
                </section>

                <!-- Tab 2: Tìm đội -->
                <section class="dn-panel" data-panel="discover">
                    <div class="dn-filters">
                        <input type="text" id="dnDiscoverKeyword" placeholder="Tìm theo tên đội hoặc khu vực..." aria-label="Tìm kiếm đội"/>
                        <select id="dnDiscoverSport" aria-label="Lọc theo môn thể thao">
                            <option value="">Tất cả môn thể thao</option>
                            <c:forEach var="mon" items="${dsMon}">
                                <option value="${mon.monTheThaoID}">${mon.tenMon}</option>
                            </c:forEach>
                        </select>
                        <label class="dn-filter-toggle">
                            <input type="checkbox" id="dnDiscoverOpenOnly"/> Chỉ đội còn chỗ
                        </label>
                    </div>
                    <div id="dnDiscoverGrid" class="dn-grid"></div>
                    <div id="dnDiscoverEmpty" class="dn-empty" style="display:none;">
                        <div class="dn-empty-icon"><i class="fas fa-search"></i></div>
                        <h2>Không tìm thấy đội phù hợp</h2>
                        <p>Hãy thử từ khóa khác hoặc bỏ bớt bộ lọc.</p>
                    </div>
                </section>

                <!-- Tab 3: Lời mời -->
                <section class="dn-panel" data-panel="invitations">
                    <div id="dnInvitationsList" class="dn-grid" style="grid-template-columns:1fr;max-width:600px;margin:0 auto;"></div>
                    <div id="dnInvitationsEmpty" class="dn-empty" style="display:none;">
                        <div class="dn-empty-icon"><i class="fas fa-inbox"></i></div>
                        <h2>Chưa có lời mời nào</h2>
                        <p>Khi đội trưởng một đội mời bạn, lời mời sẽ xuất hiện ở đây.</p>
                    </div>
                </section>
            </div>
        </main>
    </div>
</div>

<div id="dnToast" class="dn-toast" role="status" aria-live="polite"></div>

<jsp:include page="/common/footer.jsp" />

<script>
(function () {
    'use strict';
    var CTX = "${ctx}";
    var FALLBACK_AVATAR = CTX + '/assets/images/vsport-fallback.svg';

    var initial = {
        myTeams: ${myTeamsJson},
        discover: ${discoverJson},
        invitations: ${invitationsJson}
    };
    var activeTab = "${activeTab}" || "my-teams";

    var toastTimer = null;
    window.dnToast = function (msg, kind) {
        var el = document.getElementById('dnToast');
        el.className = 'dn-toast is-open' + (kind === 'danger' ? ' is-danger' : kind === 'success' ? ' is-success' : '');
        el.textContent = msg;
        clearTimeout(toastTimer);
        toastTimer = setTimeout(function () { el.classList.remove('is-open'); }, 3000);
    };

    function esc(s) { return (s == null ? '' : String(s)).replace(/[&<>"']/g, function (c) { return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]; }); }
    function avatarSrc(path) { return path ? path : FALLBACK_AVATAR; }

    function setActiveTab(tab, pushState) {
        activeTab = tab;
        document.querySelectorAll('.dn-tab').forEach(function (t) { t.classList.toggle('is-active', t.getAttribute('data-tab') === tab); });
        document.querySelectorAll('.dn-panel').forEach(function (p) { p.classList.toggle('is-active', p.getAttribute('data-panel') === tab); });
        if (pushState !== false) history.replaceState({ tab: tab }, '', CTX + '/customer/doi-nhom?tab=' + tab);
    }
    document.querySelectorAll('.dn-tab').forEach(function (btn) {
        btn.addEventListener('click', function () { setActiveTab(btn.getAttribute('data-tab')); });
    });
    document.querySelectorAll('[data-goto-tab]').forEach(function (btn) {
        btn.addEventListener('click', function () { setActiveTab(btn.getAttribute('data-goto-tab')); });
    });

    function renderMyTeams(list) {
        var grid = document.getElementById('dnMyTeamsGrid');
        var empty = document.getElementById('dnMyTeamsEmpty');
        grid.innerHTML = '';
        if (!list || !list.length) { grid.style.display = 'none'; empty.style.display = 'block'; return; }
        grid.style.display = 'grid'; empty.style.display = 'none';
        list.forEach(function (t) {
            var roleLabel = t.myRole === 'CAPTAIN' ? 'Đội trưởng' : t.myRole === 'CO_CAPTAIN' ? 'Đội phó' : 'Thành viên';
            var full = t.memberCount >= t.maxMembers;
            var card = document.createElement('div');
            card.className = 'dn-card';
            card.innerHTML =
                '<div class="dn-card-top">' +
                    '<img class="dn-avatar" src="' + esc(avatarSrc(t.avatarPath)) + '" alt="" onerror="this.onerror=null;this.src=\'' + FALLBACK_AVATAR + '\';"/>' +
                    '<div style="min-width:0;flex:1;">' +
                        '<p class="dn-card-name">' + esc(t.teamName) + '</p>' +
                        '<div class="dn-card-meta"><span><i class="fas fa-running"></i> ' + esc(t.sportName || 'Thể thao') + '</span>' + (t.locationText ? '<span> &bull; ' + esc(t.locationText) + '</span>' : '') + '</div>' +
                    '</div>' +
                '</div>' +
                '<div class="dn-badges-row">' +
                    '<span class="dn-badge role"><i class="fas fa-user-shield"></i> ' + roleLabel + '</span>' +
                    '<span class="dn-badge slots' + (full ? ' full' : '') + '"><i class="fas fa-users"></i> ' + t.memberCount + '/' + t.maxMembers + ' thành viên</span>' +
                '</div>' +
                '<div class="dn-card-actions">' +
                    '<a class="dn-btn secondary" href="' + CTX + '/customer/doi-nhom/chi-tiet?id=' + t.teamId + '">Xem chi tiết</a>' +
                    (t.myRole === 'CAPTAIN' ? '<a class="dn-btn primary" href="' + CTX + '/customer/doi-nhom/tao-keo?teamId=' + t.teamId + '">Tạo kèo</a>' : '') +
                '</div>';
            grid.appendChild(card);
        });
    }

    function renderDiscover(list) {
        var grid = document.getElementById('dnDiscoverGrid');
        var empty = document.getElementById('dnDiscoverEmpty');
        grid.innerHTML = '';
        if (!list || !list.length) { grid.style.display = 'none'; empty.style.display = 'block'; return; }
        grid.style.display = 'grid'; empty.style.display = 'none';
        list.forEach(function (t) {
            var full = t.memberCount >= t.maxMembers;
            var card = document.createElement('div');
            card.className = 'dn-card';
            var actionHtml;
            if (t.hasPendingJoinRequest) {
                actionHtml = '<button type="button" class="dn-btn" disabled>Đã gửi yêu cầu</button>';
            } else if (full) {
                actionHtml = '<button type="button" class="dn-btn" disabled>Đã đủ người</button>';
            } else {
                actionHtml = '<button type="button" class="dn-btn primary" data-join-team="' + t.teamId + '">Xin tham gia</button>';
            }
            card.innerHTML =
                '<div class="dn-card-top">' +
                    '<img class="dn-avatar" src="' + esc(avatarSrc(t.avatarPath)) + '" alt="" onerror="this.onerror=null;this.src=\'' + FALLBACK_AVATAR + '\';"/>' +
                    '<div style="min-width:0;flex:1;">' +
                        '<p class="dn-card-name">' + esc(t.teamName) + '</p>' +
                        '<div class="dn-card-meta"><span><i class="fas fa-running"></i> ' + esc(t.sportName || 'Thể thao') + '</span>' + (t.locationText ? '<span> &bull; ' + esc(t.locationText) + '</span>' : '') + '</div>' +
                    '</div>' +
                '</div>' +
                (t.description ? '<p class="dn-card-desc">' + esc(t.description) + '</p>' : '') +
                '<div class="dn-badges-row"><span class="dn-badge slots' + (full ? ' full' : '') + '"><i class="fas fa-users"></i> ' + t.memberCount + '/' + t.maxMembers + ' thành viên</span></div>' +
                '<div class="dn-card-actions"><a class="dn-btn" href="' + CTX + '/customer/doi-nhom/chi-tiet?id=' + t.teamId + '">Xem chi tiết</a>' + actionHtml + '</div>';
            grid.appendChild(card);
        });
        grid.querySelectorAll('[data-join-team]').forEach(function (btn) {
            btn.addEventListener('click', function () { sendJoinRequest(btn); });
        });
    }

    function sendJoinRequest(btn) {
        var teamId = btn.getAttribute('data-join-team');
        btn.disabled = true; btn.textContent = 'Đang gửi...';
        var form = new FormData(); form.append('teamId', teamId);
        fetch(CTX + '/customer/doi-nhom/xin-tham-gia', { method: 'POST', body: form, headers: { 'Accept': 'application/json' } })
            .then(function (r) { return r.json(); })
            .then(function (data) {
                dnToast(data.message || (data.success ? 'Đã gửi yêu cầu.' : 'Lỗi.'), data.success ? 'success' : 'danger');
                if (data.success) { btn.textContent = 'Đã gửi yêu cầu'; } else { btn.disabled = false; btn.textContent = 'Xin tham gia'; }
            })
            .catch(function () { dnToast('Không thể gửi yêu cầu. Thử lại.', 'danger'); btn.disabled = false; btn.textContent = 'Xin tham gia'; });
    }

    var discoverDebounce = null;
    function reloadDiscover() {
        var params = new URLSearchParams();
        params.set('tab', 'discover');
        var kw = document.getElementById('dnDiscoverKeyword').value.trim();
        if (kw) params.set('keyword', kw);
        var sport = document.getElementById('dnDiscoverSport').value;
        if (sport) params.set('sportId', sport);
        if (document.getElementById('dnDiscoverOpenOnly').checked) params.set('onlyOpenSlots', 'true');
        fetch(CTX + '/customer/api/teams?' + params.toString(), { headers: { 'Accept': 'application/json' } })
            .then(function (r) { return r.json(); })
            .then(renderDiscover)
            .catch(function () { dnToast('Không thể tải danh sách đội. Thử lại.', 'danger'); });
    }
    document.getElementById('dnDiscoverKeyword').addEventListener('input', function () {
        clearTimeout(discoverDebounce);
        discoverDebounce = setTimeout(reloadDiscover, 350);
    });
    document.getElementById('dnDiscoverSport').addEventListener('change', reloadDiscover);
    document.getElementById('dnDiscoverOpenOnly').addEventListener('change', reloadDiscover);

    function renderInvitations(list) {
        var wrap = document.getElementById('dnInvitationsList');
        var empty = document.getElementById('dnInvitationsEmpty');
        wrap.innerHTML = '';
        if (!list || !list.length) { wrap.style.display = 'none'; empty.style.display = 'block'; return; }
        wrap.style.display = 'grid'; empty.style.display = 'none';
        list.forEach(function (inv) {
            var card = document.createElement('div');
            card.className = 'dn-card';
            card.innerHTML =
                '<div class="dn-card-top">' +
                    '<img class="dn-avatar" src="' + esc(avatarSrc(inv.teamAvatarPath)) + '" alt="" onerror="this.onerror=null;this.src=\'' + FALLBACK_AVATAR + '\';"/>' +
                    '<div style="min-width:0;flex:1;">' +
                        '<p class="dn-card-name">' + esc(inv.teamName) + '</p>' +
                        '<div style="font-size:12.5px;color:var(--muted-text);margin-top:2px;">' + esc(inv.invitedByName) + ' đã mời bạn làm ' + (inv.proposedRole === 'CO_CAPTAIN' ? 'đội phó' : 'thành viên') + '</div>' +
                    '</div>' +
                '</div>' +
                (inv.message ? '<div style="font-size:12.5px;color:var(--body-text);background:#f8fafc;padding:10px;border-radius:8px;">' + esc(inv.message) + '</div>' : '') +
                '<div class="dn-card-actions">' +
                    '<button type="button" class="dn-btn primary" data-accept-inv="' + inv.invitationId + '">Chấp nhận</button>' +
                    '<button type="button" class="dn-btn" data-reject-inv="' + inv.invitationId + '">Từ chối</button>' +
                '</div>';
            wrap.appendChild(card);
        });
        wrap.querySelectorAll('[data-accept-inv]').forEach(function (btn) {
            btn.addEventListener('click', function () { respondInvitation(btn, btn.getAttribute('data-accept-inv'), 'chap-nhan-loi-moi'); });
        });
        wrap.querySelectorAll('[data-reject-inv]').forEach(function (btn) {
            btn.addEventListener('click', function () { respondInvitation(btn, btn.getAttribute('data-reject-inv'), 'tu-choi-loi-moi'); });
        });
    }

    function respondInvitation(btn, invitationId, action) {
        var card = btn.closest('.dn-card');
        card.querySelectorAll('button').forEach(function (b) { b.disabled = true; });
        var form = new FormData(); form.append('invitationId', invitationId);
        fetch(CTX + '/customer/doi-nhom/' + action, { method: 'POST', body: form, headers: { 'Accept': 'application/json' } })
            .then(function (r) { return r.json(); })
            .then(function (data) {
                dnToast(data.message || (data.success ? 'Đã xử lý.' : 'Lỗi.'), data.success ? 'success' : 'danger');
                if (data.success) {
                    card.remove();
                    if (data.teamId) { window.location.href = CTX + '/customer/doi-nhom/chi-tiet?id=' + data.teamId; }
                } else { card.querySelectorAll('button').forEach(function (b) { b.disabled = false; }); }
            })
            .catch(function () { dnToast('Không thể xử lý. Thử lại.', 'danger'); card.querySelectorAll('button').forEach(function (b) { b.disabled = false; }); });
    }

    renderMyTeams(initial.myTeams);
    renderDiscover(initial.discover);
    renderInvitations(initial.invitations);
    setActiveTab(activeTab, false);
})();
</script>
</body>
</html>
