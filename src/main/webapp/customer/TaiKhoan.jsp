<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="repScoreNav" value="${account.diemUyTin}" />
<c:choose>
    <c:when test="${repScoreNav >= 80}"><c:set var="repLabelNav" value="Uy tín tốt" /><c:set var="repDotNav" value="#10b981" /></c:when>
    <c:when test="${repScoreNav >= 50}"><c:set var="repLabelNav" value="Cần theo dõi" /><c:set var="repDotNav" value="#d99a1b" /></c:when>
    <c:otherwise><c:set var="repLabelNav" value="Cần cải thiện" /><c:set var="repDotNav" value="#e15a5a" /></c:otherwise>
</c:choose>
<!DOCTYPE html>
<html lang="vi" class="scroll-smooth">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tài khoản của tôi - V-SPORT</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <jsp:include page="/common/head.jsp" />
    <jsp:include page="/customer/common/vsport-theme.jsp" />
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --account-sidebar-width: clamp(420px, 23vw, 470px);
            --account-header-height: 56px;
            --sidebar-bg: #edf9f3;
            --sidebar-surface: #ffffff;
            --sidebar-border: #d7ebe0;
            --primary-dark: #006b3d;
            --primary-mid: #009a50;
            --primary-bright: #05b95f;
            --ink-green: #174431;
            --muted-green: #6f847a;
        }
        body {
            font-family: 'Be Vietnam Pro', 'Inter', system-ui, -apple-system, sans-serif !important;
            background-color: #ffffff !important;
            color: var(--ink-green) !important;
        }
        h1, h2, h3, h4, h5, h6 { font-family: inherit; }
        [hidden] { display: none !important; }

        /* Lucide inline icons */
        .lci { width: 20px; height: 20px; flex-shrink: 0; }

        /* ===================== App shell ===================== */
        .customer-account-shell {
            display: grid;
            grid-template-columns: minmax(0, 1fr);
            width: 100%;
            min-height: 100dvh;
        }
        @media (min-width: 1024px) {
            .customer-account-shell {
                grid-template-columns: var(--account-sidebar-width) minmax(0, 1fr);
            }
        }

        /* ===================== Sidebar ===================== */
        .account-sidebar {
            background: var(--sidebar-bg);
            border-right: 1px solid var(--sidebar-border);
            min-width: 0;
        }
        .account-sidebar-scroll { display: flex; flex-direction: column; }
        @media (min-width: 1024px) {
            .account-sidebar-scroll {
                position: sticky;
                top: 0;
                max-height: calc(100dvh - var(--vs-bottomnav-h-desktop, 80px));
                overflow-y: auto;
            }
        }

        /* Green top section with soft wave bottom */
        .account-sidebar-top {
            position: relative;
            background: linear-gradient(155deg, var(--primary-dark) 0%, var(--primary-mid) 62%, #02a854 100%);
            padding: 20px 16px 0;
            height: 228px;
        }
        .account-sidebar-top::after {
            content: "";
            position: absolute;
            left: -6%;
            right: -6%;
            bottom: -1px;
            height: 54px;
            background: var(--sidebar-bg);
            border-radius: 50% 50% 0 0 / 82% 82% 0 0;
        }

        /* Profile row (compact, amber border) */
        .side-profile-row {
            position: relative; z-index: 1;
            display: flex; align-items: center; gap: 12px;
            width: 100%; min-height: 70px; padding: 10px 12px;
            background: rgba(255, 255, 255, 0.13);
            border: 1px solid #e8c25a;
            border-radius: 8px;
            color: #fff; text-align: left; cursor: pointer;
            transition: background-color .15s ease;
        }
        .side-profile-row:hover, .side-profile-row:focus-visible { background: rgba(255, 255, 255, 0.2); }
        .side-profile-row:focus-visible { outline: 2px solid #fff; outline-offset: 2px; }
        .side-avatar {
            width: 50px; height: 50px; border-radius: 50%;
            object-fit: cover; flex-shrink: 0;
            background: rgba(255, 255, 255, 0.22);
            display: flex; align-items: center; justify-content: center;
            font-size: 20px; font-weight: 800; color: #fff;
            border: 2px solid rgba(255, 255, 255, 0.55);
        }
        .side-profile-name {
            font-size: 16px; font-weight: 700; line-height: 1.25;
            white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
        }
        .side-profile-email {
            font-size: 12px; font-weight: 500; color: rgba(255, 255, 255, 0.85);
            line-height: 1.3; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
        }
        .side-profile-row .lci-chev { width: 22px; height: 22px; margin-left: auto; color: rgba(255,255,255,.9); }

        /* Reputation row (replaces "membership tier") */
        .side-rep-row {
            position: relative; z-index: 1;
            display: flex; align-items: center; gap: 10px;
            width: 100%; min-height: 48px; padding: 0 14px;
            margin-top: 12px;
            background: rgba(255, 255, 255, 0.13);
            border: 1px solid rgba(255, 255, 255, 0.3);
            border-radius: 8px;
            color: #fff; font-size: 14px; font-weight: 700;
            text-align: left; cursor: pointer;
            transition: background-color .15s ease;
        }
        .side-rep-row:hover, .side-rep-row:focus-visible { background: rgba(255, 255, 255, 0.2); }
        .side-rep-row:focus-visible { outline: 2px solid #fff; outline-offset: 2px; }
        .side-rep-row .rep-score { font-weight: 800; }
        .side-rep-row .rep-label { font-size: 12.5px; font-weight: 600; color: rgba(255,255,255,.88); }
        .side-rep-row .lci-chev { width: 20px; height: 20px; margin-left: auto; color: rgba(255,255,255,.9); }

        /* Quick actions 4-up, overlapping the wave */
        .side-quick {
            position: relative; z-index: 2;
            margin: -34px 16px 0;
            background: var(--sidebar-surface);
            border: 1px solid var(--sidebar-border);
            border-radius: 12px;
            padding: 10px;
            display: grid;
            grid-template-columns: repeat(4, minmax(0, 1fr));
            gap: 8px;
            box-shadow: 0 4px 16px rgba(0, 107, 61, 0.07);
        }
        .side-quick-item {
            display: flex; flex-direction: column; align-items: center; justify-content: center;
            gap: 7px; min-height: 78px; padding: 8px 4px;
            background: #fff; border: 1px solid #e2f0e8; border-radius: 10px;
            text-decoration: none; cursor: pointer;
            transition: border-color .15s ease, background-color .15s ease;
        }
        .side-quick-item:hover, .side-quick-item:focus-visible { border-color: var(--primary-bright); background: #f6fcf9; }
        .side-quick-item:focus-visible { outline: 2px solid var(--primary-mid); outline-offset: 1px; }
        .side-quick-item .lci { width: 26px; height: 26px; }
        .side-quick-item span {
            font-size: 12.5px; font-weight: 600; color: var(--ink-green);
            text-align: center; line-height: 1.25;
        }
        .qi-green  { color: #059669; }
        .qi-amber  { color: #d97706; }
        .qi-blue   { color: #2563eb; }
        .qi-rose   { color: #e11d48; }

        /* Menu groups */
        .side-group-label {
            font-size: 13px; font-weight: 800; color: var(--primary-dark);
            text-transform: uppercase; letter-spacing: .04em;
            margin: 20px 16px 8px; padding: 0 4px;
        }
        .side-group {
            margin: 0 16px;
            background: var(--sidebar-surface);
            border: 1px solid var(--sidebar-border);
            border-radius: 12px;
            overflow: hidden;
        }
        .side-menu-item {
            display: flex; align-items: center; gap: 12px;
            width: 100%; min-height: 50px; padding: 0 14px;
            background: transparent; border: none; border-left: 3px solid transparent;
            font-family: inherit; font-size: 14.5px; font-weight: 600; color: var(--ink-green);
            text-align: left; text-decoration: none; cursor: pointer;
            transition: background-color .15s ease;
        }
        .side-menu-item + .side-menu-item { border-top: 1px solid #eef6f1; }
        .side-menu-item:hover, .side-menu-item:focus-visible { background: #f2faf6; }
        .side-menu-item:focus-visible { outline: 2px solid var(--primary-mid); outline-offset: -2px; }
        .side-menu-item .lci { width: 21px; height: 21px; color: var(--primary-mid); }
        .side-menu-item .lci-chev { width: 18px; height: 18px; margin-left: auto; color: #9db5a8; }
        .side-menu-item.is-current {
            background: #e6f7ee;
            border-left-color: var(--primary-mid);
            color: var(--primary-dark);
        }
        .side-menu-item.is-danger { color: #b91c1c; }
        .side-menu-item.is-danger .lci { color: #dc2626; }
        .side-menu-item.is-danger:hover { background: #fef2f2; }

        .side-version {
            margin: 18px 16px 20px;
            text-align: center;
            font-size: 12px; font-weight: 500; color: var(--muted-green);
        }

        /* ===================== Main workspace ===================== */
        .account-main {
            background: #fff;
            min-width: 0;
            display: flex;
            flex-direction: column;
        }
        .account-header {
            height: var(--account-header-height);
            flex-shrink: 0;
            background: linear-gradient(90deg, var(--primary-dark) 0%, var(--primary-bright) 100%);
            display: flex; align-items: center; justify-content: center;
        }
        .account-header h1 {
            margin: 0; color: #fff;
            font-size: 20px; font-weight: 700; letter-spacing: .01em;
        }
        .account-body {
            flex: 1;
            display: flex; flex-direction: column;
            padding: 18px 16px 32px;
        }
        @media (min-width: 1024px) { .account-body { padding: 20px 28px 40px; } }

        .acc-toolbar { display: flex; justify-content: flex-end; margin-bottom: 14px; }
        .btn-viewall {
            display: inline-flex; align-items: center; justify-content: center; gap: 8px;
            min-width: 158px; height: 42px; padding: 0 16px;
            background: #fff; color: var(--primary-dark);
            border: 1px solid var(--primary-mid); border-radius: 6px;
            font-size: 14px; font-weight: 700; text-decoration: none;
            transition: background-color .15s ease;
        }
        .btn-viewall:hover { background: #f2faf6; }
        .btn-viewall .lci { width: 19px; height: 19px; }

        .acc-section { display: flex; flex-direction: column; }
        .acc-section[data-section="datlich"] { flex: 1; }

        /* Empty state, centered inside the MAIN column */
        .acc-empty {
            flex: 1;
            display: flex; flex-direction: column; align-items: center; justify-content: center;
            gap: 12px; min-height: 320px; text-align: center;
        }
        .acc-empty .lci { width: 44px; height: 44px; color: #bfe3d1; }
        .acc-empty p { font-size: 14.5px; font-weight: 600; color: var(--primary-dark); opacity: .75; }

        /* Booking list */
        .booking-list { list-style: none; margin: 0; padding: 0; display: flex; flex-direction: column; gap: 12px; }
        .booking-item {
            display: flex; flex-wrap: wrap; align-items: center; justify-content: space-between; gap: 14px;
            padding: 16px 18px;
            background: #fff; border: 1px solid #e2f0e8; border-radius: 12px;
        }
        .booking-name { font-size: 15px; font-weight: 800; color: var(--ink-green); }
        .booking-meta { display: flex; align-items: center; gap: 6px; flex-wrap: wrap; font-size: 13px; color: var(--muted-green); margin-top: 4px; }
        .booking-meta .lci { width: 15px; height: 15px; }
        .booking-time { display: flex; align-items: center; gap: 6px; font-size: 13.5px; font-weight: 700; color: var(--ink-green); margin-top: 6px; }
        .booking-time .lci { width: 16px; height: 16px; color: var(--primary-mid); }
        .booking-chip {
            display: inline-flex; align-items: center; padding: 3px 10px; margin-left: 10px;
            border-radius: 8px; font-size: 11.5px; font-weight: 700; border: 1px solid;
        }
        .chip-wait  { background: #fffbeb; color: #b45309; border-color: #fde68a; }
        .chip-ok    { background: #ecfdf5; color: #047857; border-color: #a7f3d0; }
        .chip-live  { background: #f5f3ff; color: #6d28d9; border-color: #ddd6fe; }
        .chip-muted { background: #f8fafc; color: #64748b; border-color: #e2e8f0; }
        .booking-actions { display: flex; gap: 8px; flex-shrink: 0; }
        .btn-urgent {
            display: inline-flex; align-items: center; gap: 6px; padding: 9px 14px;
            background: #fffbeb; color: #b45309; border: 1px solid #fcd34d; border-radius: 8px;
            font-size: 13px; font-weight: 700; cursor: pointer; white-space: nowrap;
            transition: background-color .15s ease;
        }
        .btn-urgent:hover { background: #fef3c7; }
        .btn-urgent .lci { width: 16px; height: 16px; }

        /* Overview (Tổng quan) */
        .ov-stats { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 12px; max-width: 560px; }
        .ov-stat { background: #fff; border: 1px solid #e2f0e8; border-radius: 12px; padding: 18px 20px; }
        .ov-stat .num { font-size: 30px; font-weight: 800; line-height: 1; color: var(--primary-dark); }
        .ov-stat .lbl { font-size: 12.5px; font-weight: 700; color: var(--muted-green); text-transform: uppercase; letter-spacing: .04em; margin-top: 8px; }
        .ov-actions { display: flex; flex-wrap: wrap; gap: 10px; margin-top: 18px; }

        /* Reputation section (styles used by reputation-card.jsp) */
        .rep-card { background: #fff; border: 1px solid #e2f0e8; border-radius: 12px; padding: 22px; max-width: 860px; }
        .rep-chip { display: inline-flex; align-items: center; gap: 7px; padding: 5px 13px; border-radius: 9999px; font-size: 12.5px; font-weight: 700; }
        .rep-score-big { font-size: 44px; font-weight: 800; line-height: 1; color: var(--ink-green); }
        .rep-bar { width: 100%; height: 8px; border-radius: 9999px; background: #eef6f1; overflow: hidden; }
        .rep-counts { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 10px; }
        .rep-count { text-align: center; background: #f8fbf9; border: 1px solid #eef6f1; border-radius: 10px; padding: 12px 8px; }
        .rep-count b { display: block; font-size: 19px; font-weight: 800; color: var(--ink-green); }
        .rep-count span { font-size: 11px; font-weight: 700; color: var(--muted-green); text-transform: uppercase; letter-spacing: .03em; }
        .rep-how { background: #f8fbf9; border: 1px solid #eef6f1; border-radius: 10px; padding: 14px 16px; }
        .rep-how p { display: flex; align-items: flex-start; gap: 8px; font-size: 13.5px; color: #33544a; }
        .rep-how p + p { margin-top: 8px; }
        .rep-how .lci { width: 17px; height: 17px; margin-top: 1px; }

        /* Personal info */
        .info-card { background: #fff; border: 1px solid #e2f0e8; border-radius: 12px; padding: 22px; max-width: 860px; }
        .info-avatar-wrap { display: flex; align-items: center; gap: 16px; margin-bottom: 20px; }
        .info-avatar {
            width: 76px; height: 76px; border-radius: 50%; object-fit: cover;
            background: var(--primary-mid); color: #fff;
            display: flex; align-items: center; justify-content: center;
            font-size: 28px; font-weight: 800; flex-shrink: 0;
            border: 3px solid #d7ebe0;
        }
        .info-avatar-btn {
            display: inline-flex; align-items: center; gap: 7px; padding: 9px 14px;
            background: #fff; color: var(--primary-dark); border: 1px solid var(--primary-mid);
            border-radius: 8px; font-size: 13px; font-weight: 700; cursor: pointer;
            transition: background-color .15s ease;
        }
        .info-avatar-btn:hover { background: #f2faf6; }
        .info-avatar-btn .lci { width: 17px; height: 17px; }

        .acc-field-view dt { font-size: 12px; font-weight: 700; color: var(--muted-green); text-transform: uppercase; letter-spacing: .03em; margin-bottom: 4px; }
        .acc-field-view dd { font-size: 14.5px; font-weight: 600; color: var(--ink-green); }
        .acc-input {
            width: 100%; height: 44px; padding: 0 14px; border-radius: 8px;
            border: 1px solid #c9ded2; background: #fff; font-size: 14px; color: var(--ink-green);
            font-family: inherit;
            transition: border-color .15s ease, box-shadow .15s ease;
        }
        .acc-input:focus { outline: none; border-color: var(--primary-mid); box-shadow: 0 0 0 3px rgba(0, 154, 80, .12); }
        .acc-label { display: block; font-size: 12.5px; font-weight: 700; color: #33544a; margin-bottom: 6px; }
        .btn-primary {
            display: inline-flex; align-items: center; justify-content: center; gap: 7px;
            background: var(--primary-dark); color: #fff; font-weight: 700; font-size: 14px;
            padding: 11px 18px; border-radius: 8px; text-decoration: none; cursor: pointer;
            font-family: inherit; border: none;
            transition: background-color .15s ease, transform .1s ease;
        }
        .btn-primary:hover { background: #00552f; }
        .btn-primary:active { transform: scale(.98); }
        .btn-primary:disabled { opacity: .6; cursor: not-allowed; }
        .btn-primary .lci { width: 17px; height: 17px; }
        .btn-secondary {
            display: inline-flex; align-items: center; justify-content: center; gap: 7px;
            background: #fff; color: #33544a; font-weight: 700; font-size: 14px;
            padding: 11px 18px; border-radius: 8px; border: 1px solid #c9ded2;
            text-decoration: none; cursor: pointer; font-family: inherit;
            transition: background-color .15s ease;
        }
        .btn-secondary:hover { background: #f8fbf9; }
        .btn-secondary .lci { width: 17px; height: 17px; }

        #accToast { transition: opacity .25s ease, transform .25s ease; }
        .pw-eye .eye-open { display: none; }
        .pw-eye.is-visible .eye-open { display: block; }
        .pw-eye.is-visible .eye-closed { display: none; }
    </style>
</head>
<body class="antialiased">

<div class="customer-account-shell">

    <!-- ============ SIDEBAR ============ -->
    <aside class="account-sidebar" aria-label="Điều hướng tài khoản">
        <div class="account-sidebar-scroll">

            <div class="account-sidebar-top">
                <!-- Profile row -->
                <button type="button" class="side-profile-row" data-section="thongtin" aria-label="Mở thông tin cá nhân">
                    <c:choose>
                        <c:when test="${not empty account.avatarUrl}">
                            <img class="side-avatar js-avatar-img" src="${pageContext.request.contextPath}${account.avatarUrl}" alt="Ảnh đại diện">
                        </c:when>
                        <c:otherwise>
                            <span class="side-avatar js-avatar-initial" aria-hidden="true"><c:choose><c:when test="${not empty account.fullName}">${fn:escapeXml(fn:substring(account.fullName, 0, 1))}</c:when><c:otherwise>${fn:escapeXml(fn:substring(account.username, 0, 1))}</c:otherwise></c:choose></span>
                            <img class="side-avatar js-avatar-img" src="" alt="Ảnh đại diện" hidden>
                        </c:otherwise>
                    </c:choose>
                    <span style="min-width:0;">
                        <span id="accSummaryName" class="side-profile-name" style="display:block;">${fn:escapeXml(not empty account.fullName ? account.fullName : account.username)}</span>
                        <span id="accSummaryEmail" class="side-profile-email" style="display:block;">${not empty account.email ? fn:escapeXml(account.email) : 'Chưa cập nhật email'}</span>
                    </span>
                    <svg class="lci lci-chev" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 18 6-6-6-6"/></svg>
                </button>

                <!-- Reputation row -->
                <button type="button" class="side-rep-row" data-section="uytin" aria-label="Mở điểm uy tín">
                    <svg class="lci" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 13c0 5-3.5 7.5-7.66 8.95a1 1 0 0 1-.67-.01C7.5 20.5 4 18 4 13V6a1 1 0 0 1 1-1c2 0 4.5-1.2 6.24-2.72a1 1 0 0 1 1.52 0C14.51 3.81 17 5 19 5a1 1 0 0 1 1 1z"/><path d="m9 12 2 2 4-4"/></svg>
                    <span>Uy tín người chơi</span>
                    <span class="rep-score">${repScoreNav}/100</span>
                    <span class="rep-label">&middot; ${repLabelNav}</span>
                    <svg class="lci lci-chev" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 18 6-6-6-6"/></svg>
                </button>
            </div>

            <!-- Quick actions -->
            <div class="side-quick">
                <a class="side-quick-item" href="${pageContext.request.contextPath}/customer/lich-su-dat-san">
                    <svg class="lci qi-green" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M8 2v4"/><path d="M16 2v4"/><rect width="18" height="18" x="3" y="4" rx="2"/><path d="M3 10h18"/><path d="m9 16 2 2 4-4"/></svg>
                    <span>Lịch đã đặt</span>
                </a>
                <a class="side-quick-item" href="${pageContext.request.contextPath}/customer/ghep-keo?tab=cua-toi">
                    <svg class="lci qi-amber" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M18 21a8 8 0 0 0-16 0"/><circle cx="10" cy="8" r="5"/><path d="M22 20c0-3.37-2-6.5-4-8a5 5 0 0 0-.45-8.3"/></svg>
                    <span>Kèo của tôi</span>
                </a>
                <a class="side-quick-item" href="${pageContext.request.contextPath}/customer/ghep-keo?tab=tim-doi-thu">
                    <svg class="lci qi-blue" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="10" cy="7" r="4"/><path d="M10.3 15H7a4 4 0 0 0-4 4v2"/><circle cx="17" cy="17" r="3"/><path d="m21 21-1.9-1.9"/></svg>
                    <span>Tìm đối thủ</span>
                </a>
                <button type="button" class="side-quick-item" data-section="uytin">
                    <svg class="lci qi-rose" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 13c0 5-3.5 7.5-7.66 8.95a1 1 0 0 1-.67-.01C7.5 20.5 4 18 4 13V6a1 1 0 0 1 1-1c2 0 4.5-1.2 6.24-2.72a1 1 0 0 1 1.52 0C14.51 3.81 17 5 19 5a1 1 0 0 1 1 1z"/><path d="m9 12 2 2 4-4"/></svg>
                    <span>Điểm uy tín</span>
                </button>
            </div>

            <!-- Menu: Hoạt động -->
            <p class="side-group-label" id="groupHoatDong">Hoạt động</p>
            <nav class="side-group" aria-labelledby="groupHoatDong">
                <button type="button" class="side-menu-item" data-section="tongquan">
                    <svg class="lci" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect width="7" height="9" x="3" y="3" rx="1"/><rect width="7" height="5" x="14" y="3" rx="1"/><rect width="7" height="9" x="14" y="12" rx="1"/><rect width="7" height="5" x="3" y="16" rx="1"/></svg>
                    Tổng quan tài khoản
                    <svg class="lci lci-chev" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 18 6-6-6-6"/></svg>
                </button>
                <a class="side-menu-item" href="${pageContext.request.contextPath}/customer/lich-su-dat-san">
                    <svg class="lci" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M8 2v4"/><path d="M16 2v4"/><rect width="18" height="18" x="3" y="4" rx="2"/><path d="M3 10h18"/><path d="M8 14h.01"/><path d="M12 14h.01"/><path d="M16 14h.01"/><path d="M8 18h.01"/><path d="M12 18h.01"/><path d="M16 18h.01"/></svg>
                    Lịch đặt sân
                    <svg class="lci lci-chev" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 18 6-6-6-6"/></svg>
                </a>
                <a class="side-menu-item" href="${pageContext.request.contextPath}/customer/ghep-keo?tab=cua-toi">
                    <svg class="lci" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M18 21a8 8 0 0 0-16 0"/><circle cx="10" cy="8" r="5"/><path d="M22 20c0-3.37-2-6.5-4-8a5 5 0 0 0-.45-8.3"/></svg>
                    Kèo của tôi
                    <svg class="lci lci-chev" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 18 6-6-6-6"/></svg>
                </a>
                <a class="side-menu-item" href="${pageContext.request.contextPath}/customer/ghep-keo?tab=tim-doi-thu">
                    <svg class="lci" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="10" cy="7" r="4"/><path d="M10.3 15H7a4 4 0 0 0-4 4v2"/><circle cx="17" cy="17" r="3"/><path d="m21 21-1.9-1.9"/></svg>
                    Tìm đối thủ
                    <svg class="lci lci-chev" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 18 6-6-6-6"/></svg>
                </a>
                <button type="button" class="side-menu-item" data-section="uytin">
                    <svg class="lci" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 13c0 5-3.5 7.5-7.66 8.95a1 1 0 0 1-.67-.01C7.5 20.5 4 18 4 13V6a1 1 0 0 1 1-1c2 0 4.5-1.2 6.24-2.72a1 1 0 0 1 1.52 0C14.51 3.81 17 5 19 5a1 1 0 0 1 1 1z"/><path d="m9 12 2 2 4-4"/></svg>
                    Điểm uy tín
                    <svg class="lci lci-chev" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 18 6-6-6-6"/></svg>
                </button>
            </nav>

            <!-- Menu: Tài khoản -->
            <p class="side-group-label" id="groupTaiKhoan">Tài khoản</p>
            <nav class="side-group" aria-labelledby="groupTaiKhoan" style="margin-bottom:4px;">
                <button type="button" class="side-menu-item" data-section="thongtin">
                    <svg class="lci" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M16 10h2"/><path d="M16 14h2"/><path d="M6.17 15a3 3 0 0 1 5.66 0"/><circle cx="9" cy="11" r="2"/><rect x="2" y="5" width="20" height="14" rx="2"/></svg>
                    Thông tin cá nhân
                    <svg class="lci lci-chev" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 18 6-6-6-6"/></svg>
                </button>
                <button type="button" class="side-menu-item" onclick="openPwModal()">
                    <svg class="lci" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect width="18" height="11" x="3" y="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                    Đổi mật khẩu
                    <svg class="lci lci-chev" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 18 6-6-6-6"/></svg>
                </button>
                <a class="side-menu-item is-danger" href="${pageContext.request.contextPath}/logout">
                    <svg class="lci" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" x2="9" y1="12" y2="12"/></svg>
                    Đăng xuất
                    <svg class="lci lci-chev" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 18 6-6-6-6"/></svg>
                </a>
            </nav>

            <p class="side-version">Phiên bản 1.0-SNAPSHOT</p>
        </div>
    </aside>

    <!-- ============ MAIN WORKSPACE ============ -->
    <section class="account-main">
        <header class="account-header">
            <h1 id="accountHeaderTitle">Danh sách đặt lịch</h1>
        </header>

        <div class="account-body">

            <!-- Toolbar (chỉ hiện ở "Danh sách đặt lịch") -->
            <div class="acc-toolbar" id="accToolbar">
                <a href="${pageContext.request.contextPath}/customer/lich-su-dat-san" class="btn-viewall">
                    Xem tất cả
                    <svg class="lci" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M8 2v4"/><path d="M16 2v4"/><rect width="18" height="18" x="3" y="4" rx="2"/><path d="M3 10h18"/><path d="M8 14h.01"/><path d="M12 14h.01"/><path d="M16 14h.01"/><path d="M8 18h.01"/><path d="M12 18h.01"/><path d="M16 18h.01"/></svg>
                </a>
            </div>

            <!-- ===== Section: Danh sách đặt lịch (mặc định) ===== -->
            <section class="acc-section" data-section="datlich" aria-label="Danh sách đặt lịch">
                <c:choose>
                    <c:when test="${not empty upcomingBookings}">
                        <ul class="booking-list">
                            <c:forEach var="lich" items="${upcomingBookings}">
                                <li class="booking-item">
                                    <div style="min-width:0;">
                                        <span class="booking-name"><c:choose><c:when test="${not empty upcomingSanNames[lich.sanId]}">${fn:escapeXml(upcomingSanNames[lich.sanId])}</c:when><c:otherwise>Sân #${lich.sanId}</c:otherwise></c:choose></span><c:choose>
                                            <c:when test="${lich.trangThai == 'Chờ xác nhận' || lich.trangThai == 'Chờ thanh toán'}"><span class="booking-chip chip-wait">${fn:escapeXml(lich.trangThai)}</span></c:when>
                                            <c:when test="${lich.trangThai == 'Đã xác nhận' || lich.trangThai == 'Đã đặt' || lich.trangThai == 'Đã thanh toán' || lich.trangThai == 'Đã cọc'}"><span class="booking-chip chip-ok">${fn:escapeXml(lich.trangThai)}</span></c:when>
                                            <c:when test="${lich.trangThai == 'Đang sử dụng'}"><span class="booking-chip chip-live">Đang sử dụng</span></c:when>
                                            <c:otherwise><span class="booking-chip chip-muted">${fn:escapeXml(lich.trangThai)}</span></c:otherwise>
                                        </c:choose>
                                        <p class="booking-meta">
                                            <c:if test="${not empty upcomingCoSoNames[lich.sanId]}">
                                                <svg class="lci" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 10c0 4.993-5.539 10.193-7.399 11.799a1 1 0 0 1-1.202 0C9.539 20.193 4 14.993 4 10a8 8 0 0 1 16 0"/><circle cx="12" cy="10" r="3"/></svg>
                                                ${fn:escapeXml(upcomingCoSoNames[lich.sanId])} <span>&middot;</span>
                                            </c:if>
                                            Mã #${lich.datSanId}
                                        </p>
                                        <p class="booking-time">
                                            <svg class="lci" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M8 2v4"/><path d="M16 2v4"/><rect width="18" height="18" x="3" y="4" rx="2"/><path d="M3 10h18"/></svg>
                                            ${fn:substring(lich.ngayDat, 8, 10)}/${fn:substring(lich.ngayDat, 5, 7)}/${fn:substring(lich.ngayDat, 0, 4)}
                                            <svg class="lci" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                                            ${fn:substring(lich.gioBatDau, 0, 5)} - ${fn:substring(lich.gioKetThuc, 0, 5)}
                                        </p>
                                    </div>
                                    <div class="booking-actions">
                                        <c:if test="${nearestBookingUrgentEligible and nearestBooking ne null and lich.datSanId eq nearestBooking.datSanId}">
                                            <button type="button" class="btn-urgent" onclick="openUrgentOpponentModal()">
                                                <svg class="lci" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 14a1 1 0 0 1-.78-1.63l9.9-10.2a.5.5 0 0 1 .86.46l-1.92 6.02A1 1 0 0 0 13 10h7a1 1 0 0 1 .78 1.63l-9.9 10.2a.5.5 0 0 1-.86-.46l1.92-6.02A1 1 0 0 0 11 14z"/></svg>
                                                Tìm đối thủ gấp
                                            </button>
                                        </c:if>
                                        <a href="${pageContext.request.contextPath}/customer/lich-su-dat-san" class="btn-secondary" style="padding:9px 14px;font-size:13px;">Chi tiết</a>
                                    </div>
                                </li>
                            </c:forEach>
                        </ul>
                    </c:when>
                    <c:otherwise>
                        <div class="acc-empty">
                            <svg class="lci" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M8 2v4"/><path d="M16 2v4"/><rect width="18" height="18" x="3" y="4" rx="2"/><path d="M3 10h18"/><path d="M8 14h.01"/><path d="M12 14h.01"/><path d="M16 14h.01"/><path d="M8 18h.01"/><path d="M12 18h.01"/><path d="M16 18h.01"/></svg>
                            <p>Bạn chưa có lịch đặt</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </section>

            <!-- ===== Section: Tổng quan tài khoản ===== -->
            <section class="acc-section" data-section="tongquan" aria-label="Tổng quan tài khoản" hidden>
                <div class="ov-stats">
                    <div class="ov-stat">
                        <p class="num">${upcomingCount}</p>
                        <p class="lbl">Lịch sắp tới</p>
                    </div>
                    <div class="ov-stat">
                        <p class="num">${totalBookings}</p>
                        <p class="lbl">Tổng lịch đặt</p>
                    </div>
                </div>
                <div class="ov-actions">
                    <a href="${pageContext.request.contextPath}/customer/dat-san" class="btn-primary">
                        <svg class="lci" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M8 2v4"/><path d="M16 2v4"/><path d="M21 13V6a2 2 0 0 0-2-2H5a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h8"/><path d="M3 10h18"/><path d="M16 19h6"/><path d="M19 16v6"/></svg>
                        Đặt sân mới
                    </a>
                    <a href="${pageContext.request.contextPath}/customer/ghep-keo?tab=tao-keo" class="btn-secondary">
                        <svg class="lci" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m11 17 2 2a1 1 0 1 0 3-3"/><path d="m14 14 2.5 2.5a1 1 0 1 0 3-3l-3.88-3.88a3 3 0 0 0-4.24 0l-.88.88a1 1 0 1 1-3-3l2.81-2.81a5.79 5.79 0 0 1 7.06-.87l.47.28a2 2 0 0 0 1.42.25L21 4"/><path d="m21 3 1 11h-2"/><path d="M3 3 2 14l6.5 6.5a1 1 0 1 0 3-3"/><path d="M3 4h8"/></svg>
                        Tạo kèo ghép trận
                    </a>
                </div>
            </section>

            <!-- ===== Section: Điểm uy tín ===== -->
            <section class="acc-section" data-section="uytin" aria-label="Điểm uy tín" hidden>
                <jsp:include page="/customer/common/reputation-card.jsp" />
            </section>

            <!-- ===== Section: Thông tin cá nhân ===== -->
            <section class="acc-section" data-section="thongtin" aria-label="Thông tin cá nhân" hidden>
                <div class="info-card" id="personalInfoCard">
                    <div class="info-avatar-wrap">
                        <c:choose>
                            <c:when test="${not empty account.avatarUrl}">
                                <img id="accAvatarPreview" class="info-avatar js-avatar-img" src="${pageContext.request.contextPath}${account.avatarUrl}" alt="Ảnh đại diện">
                            </c:when>
                            <c:otherwise>
                                <span id="accAvatarInitial" class="info-avatar js-avatar-initial" aria-hidden="true"><c:choose><c:when test="${not empty account.fullName}">${fn:escapeXml(fn:substring(account.fullName, 0, 1))}</c:when><c:otherwise>${fn:escapeXml(fn:substring(account.username, 0, 1))}</c:otherwise></c:choose></span>
                                <img id="accAvatarPreview" class="info-avatar js-avatar-img" src="" alt="Ảnh đại diện" hidden>
                            </c:otherwise>
                        </c:choose>
                        <div>
                            <label for="accAvatarInput" class="info-avatar-btn">
                                <svg class="lci" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M14.5 4h-5L7 7H4a2 2 0 0 0-2 2v9a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2h-3l-2.5-3z"/><circle cx="12" cy="13" r="3"/></svg>
                                Đổi ảnh đại diện
                            </label>
                            <input id="accAvatarInput" type="file" accept="image/jpeg,image/png,image/webp,image/gif" class="hidden">
                            <p class="text-[12px] mt-2" style="color:var(--muted-green);">JPG, PNG, WEBP hoặc GIF, tối đa 2MB.</p>
                            <p id="accAvatarError" class="hidden mt-2 text-[12px] font-semibold text-red-600"></p>
                        </div>
                        <c:if test="${account.createdAt != null}">
                            <p class="text-[12.5px] font-semibold ml-auto self-start" style="color:var(--muted-green);">Tham gia <fmt:formatDate value="${account.createdAt}" pattern="MM/yyyy"/></p>
                        </c:if>
                    </div>

                    <div class="flex items-center justify-between mb-5">
                        <h3 class="text-[15px] font-extrabold" style="color:var(--ink-green);">Thông tin cá nhân</h3>
                        <button type="button" id="editToggleBtn" onclick="enterEditMode(true)" class="info-avatar-btn" style="border-color:#c9ded2;">
                            <svg class="lci" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M21.174 6.812a1 1 0 0 0-3.986-3.987L3.842 16.174a2 2 0 0 0-.5.83l-1.321 4.352a.5.5 0 0 0 .623.622l4.353-1.32a2 2 0 0 0 .83-.497z"/><path d="m15 5 4 4"/></svg>
                            Chỉnh sửa
                        </button>
                    </div>

                    <!-- View mode -->
                    <dl id="infoViewMode" class="acc-field-view grid grid-cols-1 sm:grid-cols-2 gap-x-6 gap-y-4">
                        <div>
                            <dt>Họ và tên</dt>
                            <dd id="viewFullName">${not empty account.fullName ? fn:escapeXml(account.fullName) : '-'}</dd>
                        </div>
                        <div>
                            <dt>Email</dt>
                            <dd id="viewEmail">${not empty account.email ? fn:escapeXml(account.email) : '-'}</dd>
                        </div>
                        <div>
                            <dt>Số điện thoại</dt>
                            <dd id="viewPhone">${not empty account.phoneNumber ? fn:escapeXml(account.phoneNumber) : '-'}</dd>
                        </div>
                        <div>
                            <dt>Ngày sinh</dt>
                            <dd id="viewBirthday">
                                <c:choose>
                                    <c:when test="${account.ngaySinh != null}"><fmt:formatDate value="${account.ngaySinh}" pattern="dd/MM/yyyy"/></c:when>
                                    <c:otherwise>-</c:otherwise>
                                </c:choose>
                            </dd>
                        </div>
                        <div>
                            <dt>Giới tính</dt>
                            <dd id="viewGender">${not empty account.gioiTinh ? fn:escapeXml(account.gioiTinh) : '-'}</dd>
                        </div>
                    </dl>

                    <!-- Edit mode -->
                    <form id="infoEditForm" class="hidden grid grid-cols-1 sm:grid-cols-2 gap-4" onsubmit="return false;" autocomplete="off">
                        <div>
                            <label class="acc-label" for="editFullName">Họ và tên</label>
                            <input id="editFullName" type="text" class="acc-input" value="${fn:escapeXml(account.fullName)}" maxlength="100">
                            <p class="hidden text-[12px] text-red-600 font-semibold mt-1" data-error-for="fullName"></p>
                        </div>
                        <div>
                            <label class="acc-label" for="editEmail">Email</label>
                            <input id="editEmail" type="email" class="acc-input" value="${fn:escapeXml(account.email)}">
                            <p class="hidden text-[12px] text-red-600 font-semibold mt-1" data-error-for="email"></p>
                        </div>
                        <div>
                            <label class="acc-label" for="editPhone">Số điện thoại</label>
                            <input id="editPhone" type="tel" class="acc-input" value="${fn:escapeXml(account.phoneNumber)}">
                            <p class="hidden text-[12px] text-red-600 font-semibold mt-1" data-error-for="phone"></p>
                        </div>
                        <div>
                            <label class="acc-label" for="editBirthday">Ngày sinh</label>
                            <input id="editBirthday" type="date" class="acc-input" value="<c:if test="${account.ngaySinh != null}"><fmt:formatDate value="${account.ngaySinh}" pattern="yyyy-MM-dd"/></c:if>">
                            <p class="hidden text-[12px] text-red-600 font-semibold mt-1" data-error-for="birthday"></p>
                        </div>
                        <div>
                            <label class="acc-label" for="editGender">Giới tính</label>
                            <select id="editGender" class="acc-input">
                                <option value="" ${empty account.gioiTinh ? 'selected' : ''}>-- Không chọn --</option>
                                <option value="Nam" ${account.gioiTinh == 'Nam' ? 'selected' : ''}>Nam</option>
                                <option value="Nữ" ${account.gioiTinh == 'Nữ' ? 'selected' : ''}>Nữ</option>
                                <option value="Khác" ${account.gioiTinh == 'Khác' ? 'selected' : ''}>Khác</option>
                            </select>
                            <p class="hidden text-[12px] text-red-600 font-semibold mt-1" data-error-for="gender"></p>
                        </div>
                        <div class="sm:col-span-2 flex justify-end gap-3 pt-2">
                            <button type="button" onclick="enterEditMode(false)" class="btn-secondary">Hủy</button>
                            <button type="button" id="saveInfoBtn" onclick="saveProfileInfo()" class="btn-primary">Lưu thay đổi</button>
                        </div>
                    </form>
                </div>
            </section>

        </div>
    </section>
</div>

<!-- Toast -->
<div id="accToast" class="hidden fixed bottom-24 right-6 z-[999] max-w-sm bg-white border border-slate-200 shadow-lg rounded-xl px-4 py-3 flex items-start gap-3 opacity-0 translate-y-3">
    <span id="accToastIconOk" class="mt-0.5 text-emerald-600"><svg class="lci" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="10"/><path d="m9 12 2 2 4-4"/></svg></span>
    <span id="accToastIconErr" class="mt-0.5 text-red-500 hidden"><svg class="lci" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="10"/><line x1="12" x2="12" y1="8" y2="12"/><line x1="12" x2="12.01" y1="16" y2="16"/></svg></span>
    <div>
        <p id="accToastTitle" class="text-sm font-bold" style="color:var(--ink-green);">Thành công</p>
        <p id="accToastMessage" class="text-xs mt-0.5" style="color:var(--muted-green);"></p>
    </div>
</div>

<!-- Email OTP modal -->
<div id="emailOtpModal" class="hidden fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-[300] flex items-center justify-center p-4">
    <div class="bg-white rounded-2xl shadow-2xl w-full max-w-[400px] border border-slate-200">
        <div class="px-6 py-4 border-b border-slate-100 flex items-center justify-between">
            <h3 class="text-sm font-extrabold flex items-center gap-2" style="color:var(--ink-green);">
                <svg class="lci text-emerald-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M22 13V6a2 2 0 0 0-2-2H4a2 2 0 0 0-2 2v12c0 1.1.9 2 2 2h8"/><path d="m22 7-8.97 5.7a1.94 1.94 0 0 1-2.06 0L2 7"/><path d="m16 19 2 2 4-4"/></svg>
                Xác thực email mới
            </h3>
            <button type="button" onclick="closeModal('emailOtpModal')" class="w-8 h-8 rounded-full hover:bg-slate-100 flex items-center justify-center" aria-label="Đóng">
                <svg class="lci text-slate-500" style="width:18px;height:18px;" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg>
            </button>
        </div>
        <div class="px-6 py-5">
            <p class="text-sm text-slate-600">Mã OTP đã được gửi đến <strong id="otpTargetEmail" class="text-slate-900"></strong>. Nhập mã để hoàn tất thay đổi.</p>
            <input id="otpInput" type="text" maxlength="6" inputmode="numeric" placeholder="••••••" class="acc-input mt-4 text-center text-xl font-black tracking-[0.3em]">
            <p id="otpError" class="hidden mt-2 text-[12px] font-semibold text-red-600"></p>
        </div>
        <div class="px-6 pb-5 flex justify-end gap-3">
            <button type="button" onclick="closeModal('emailOtpModal')" class="btn-secondary">Hủy</button>
            <button type="button" id="otpConfirmBtn" onclick="verifyEmailOtp()" class="btn-primary">Xác thực</button>
        </div>
    </div>
</div>

<!-- Change password modal -->
<div id="pwModal" class="hidden fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-[300] flex items-center justify-center p-4">
    <div class="bg-white rounded-2xl shadow-2xl w-full max-w-[420px] border border-slate-200">
        <div class="px-6 py-4 border-b border-slate-100 flex items-center justify-between">
            <h3 class="text-sm font-extrabold flex items-center gap-2" style="color:var(--ink-green);">
                <svg class="lci text-emerald-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect width="18" height="11" x="3" y="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                Đổi mật khẩu
            </h3>
            <button type="button" onclick="closeModal('pwModal')" class="w-8 h-8 rounded-full hover:bg-slate-100 flex items-center justify-center" aria-label="Đóng">
                <svg class="lci text-slate-500" style="width:18px;height:18px;" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg>
            </button>
        </div>
        <form id="pwForm" class="px-6 py-5 flex flex-col gap-4" onsubmit="return false;" autocomplete="off">
            <div>
                <label class="acc-label" for="pwCurrent">Mật khẩu hiện tại</label>
                <div class="relative">
                    <input type="password" id="pwCurrent" class="acc-input pr-10" autocomplete="new-password">
                    <button type="button" onclick="togglePw('pwCurrent', this)" class="pw-eye absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600" aria-label="Hiện/ẩn mật khẩu">
                        <svg class="lci eye-closed" style="width:18px;height:18px;" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M10.733 5.076a10.744 10.744 0 0 1 11.205 6.575 1 1 0 0 1 0 .696 10.747 10.747 0 0 1-1.444 2.49"/><path d="M14.084 14.158a3 3 0 0 1-4.242-4.242"/><path d="M17.479 17.499a10.75 10.75 0 0 1-15.417-5.151 1 1 0 0 1 0-.696 10.75 10.75 0 0 1 4.446-5.143"/><path d="m2 2 20 20"/></svg>
                        <svg class="lci eye-open" style="width:18px;height:18px;" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M2.062 12.348a1 1 0 0 1 0-.696 10.75 10.75 0 0 1 19.876 0 1 1 0 0 1 0 .696 10.75 10.75 0 0 1-19.876 0"/><circle cx="12" cy="12" r="3"/></svg>
                    </button>
                </div>
                <p class="hidden text-[12px] text-red-600 font-semibold mt-1" data-error-for="currentPassword"></p>
            </div>
            <div>
                <label class="acc-label" for="pwNew">Mật khẩu mới</label>
                <div class="relative">
                    <input type="password" id="pwNew" class="acc-input pr-10" autocomplete="new-password" oninput="updatePwStrength()">
                    <button type="button" onclick="togglePw('pwNew', this)" class="pw-eye absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600" aria-label="Hiện/ẩn mật khẩu">
                        <svg class="lci eye-closed" style="width:18px;height:18px;" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M10.733 5.076a10.744 10.744 0 0 1 11.205 6.575 1 1 0 0 1 0 .696 10.747 10.747 0 0 1-1.444 2.49"/><path d="M14.084 14.158a3 3 0 0 1-4.242-4.242"/><path d="M17.479 17.499a10.75 10.75 0 0 1-15.417-5.151 1 1 0 0 1 0-.696 10.75 10.75 0 0 1 4.446-5.143"/><path d="m2 2 20 20"/></svg>
                        <svg class="lci eye-open" style="width:18px;height:18px;" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M2.062 12.348a1 1 0 0 1 0-.696 10.75 10.75 0 0 1 19.876 0 1 1 0 0 1 0 .696 10.75 10.75 0 0 1-19.876 0"/><circle cx="12" cy="12" r="3"/></svg>
                    </button>
                </div>
                <div class="flex gap-1 mt-2">
                    <div class="h-1 flex-1 rounded-full bg-slate-100" id="pwStr1"></div>
                    <div class="h-1 flex-1 rounded-full bg-slate-100" id="pwStr2"></div>
                    <div class="h-1 flex-1 rounded-full bg-slate-100" id="pwStr3"></div>
                    <div class="h-1 flex-1 rounded-full bg-slate-100" id="pwStr4"></div>
                </div>
                <p id="pwStrengthLabel" class="text-[12px] text-slate-400 mt-1"></p>
                <p class="hidden text-[12px] text-red-600 font-semibold mt-1" data-error-for="newPassword"></p>
            </div>
            <div>
                <label class="acc-label" for="pwConfirm">Xác nhận mật khẩu mới</label>
                <div class="relative">
                    <input type="password" id="pwConfirm" class="acc-input pr-10" autocomplete="new-password">
                    <button type="button" onclick="togglePw('pwConfirm', this)" class="pw-eye absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600" aria-label="Hiện/ẩn mật khẩu">
                        <svg class="lci eye-closed" style="width:18px;height:18px;" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M10.733 5.076a10.744 10.744 0 0 1 11.205 6.575 1 1 0 0 1 0 .696 10.747 10.747 0 0 1-1.444 2.49"/><path d="M14.084 14.158a3 3 0 0 1-4.242-4.242"/><path d="M17.479 17.499a10.75 10.75 0 0 1-15.417-5.151 1 1 0 0 1 0-.696 10.75 10.75 0 0 1 4.446-5.143"/><path d="m2 2 20 20"/></svg>
                        <svg class="lci eye-open" style="width:18px;height:18px;" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M2.062 12.348a1 1 0 0 1 0-.696 10.75 10.75 0 0 1 19.876 0 1 1 0 0 1 0 .696 10.75 10.75 0 0 1-19.876 0"/><circle cx="12" cy="12" r="3"/></svg>
                    </button>
                </div>
                <p class="hidden text-[12px] text-red-600 font-semibold mt-1" data-error-for="confirmPassword"></p>
            </div>
        </form>
        <div class="px-6 pb-5 flex justify-end gap-3">
            <button type="button" onclick="closeModal('pwModal')" class="btn-secondary">Hủy</button>
            <button type="button" id="pwSaveBtn" onclick="savePassword()" class="btn-primary">Đổi mật khẩu</button>
        </div>
    </div>
</div>

<script>
    const CTX = '${pageContext.request.contextPath}';
    document.getElementById('editBirthday').max = new Date().toISOString().split('T')[0];

    // ---- Section router: main workspace chỉ hiển thị một section tại một thời điểm ----
    const SECTION_TITLES = {
        datlich: 'Danh sách đặt lịch',
        tongquan: 'Tổng quan tài khoản',
        uytin: 'Điểm uy tín',
        thongtin: 'Thông tin cá nhân'
    };
    // Alias giữ tương thích các anchor cũ (#uyTinCuaToi từ LichSuDatSan.jsp, ...).
    const SECTION_ALIASES = {
        uyTinCuaToi: 'uytin',
        personalInfoCard: 'thongtin',
        tongQuan: 'tongquan'
    };

    function showAccountSection(key, opts) {
        if (!SECTION_TITLES[key]) key = 'datlich';
        document.querySelectorAll('.acc-section').forEach(function (sec) {
            sec.hidden = sec.dataset.section !== key;
        });
        document.getElementById('accountHeaderTitle').textContent = SECTION_TITLES[key];
        document.getElementById('accToolbar').hidden = key !== 'datlich';
        document.querySelectorAll('.side-menu-item[data-section]').forEach(function (item) {
            item.classList.toggle('is-current', item.dataset.section === key);
        });
        if (history.replaceState) {
            history.replaceState(null, '', key === 'datlich' ? location.pathname : ('#' + key));
        }
        if (opts && opts.scroll && window.innerWidth < 1024) {
            document.querySelector('.account-main').scrollIntoView({ behavior: 'smooth' });
        }
    }

    document.querySelectorAll('[data-section]').forEach(function (el) {
        if (el.classList.contains('acc-section')) return;
        el.addEventListener('click', function () {
            showAccountSection(el.dataset.section, { scroll: true });
        });
    });

    (function initSection() {
        let key = (location.hash || '').replace('#', '');
        if (SECTION_ALIASES[key]) key = SECTION_ALIASES[key];
        showAccountSection(SECTION_TITLES[key] ? key : 'datlich');
    })();

    // ---- Toast ----
    function showToast(title, message, isError) {
        const toast = document.getElementById('accToast');
        document.getElementById('accToastTitle').textContent = title;
        document.getElementById('accToastMessage').textContent = message || '';
        document.getElementById('accToastIconOk').classList.toggle('hidden', !!isError);
        document.getElementById('accToastIconErr').classList.toggle('hidden', !isError);
        toast.classList.remove('hidden');
        requestAnimationFrame(() => { toast.classList.remove('opacity-0', 'translate-y-3'); });
        clearTimeout(window.__accToastTimer);
        window.__accToastTimer = setTimeout(() => {
            toast.classList.add('opacity-0', 'translate-y-3');
            setTimeout(() => toast.classList.add('hidden'), 250);
        }, 4000);
    }

    function openModal(id) {
        document.getElementById(id).classList.remove('hidden');
    }
    function closeModal(id) {
        document.getElementById(id).classList.add('hidden');
    }
    document.querySelectorAll('#pwModal, #emailOtpModal').forEach(overlay => {
        overlay.addEventListener('click', (e) => { if (e.target === overlay) closeModal(overlay.id); });
    });
    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') {
            closeModal('pwModal');
            closeModal('emailOtpModal');
        }
    });

    function clearFieldErrors(scopeEl) {
        scopeEl.querySelectorAll('[data-error-for]').forEach(el => { el.textContent = ''; el.classList.add('hidden'); });
    }
    function showFieldErrors(scopeEl, fieldErrors) {
        clearFieldErrors(scopeEl);
        if (!fieldErrors) return;
        Object.keys(fieldErrors).forEach(key => {
            const el = scopeEl.querySelector('[data-error-for="' + key + '"]');
            if (el) { el.textContent = fieldErrors[key]; el.classList.remove('hidden'); }
        });
    }

    // ---- Edit mode toggle ----
    function enterEditMode(on) {
        const viewMode = document.getElementById('infoViewMode');
        const editForm = document.getElementById('infoEditForm');
        const toggleBtn = document.getElementById('editToggleBtn');
        if (on) {
            showAccountSection('thongtin');
            viewMode.classList.add('hidden');
            editForm.classList.remove('hidden');
            toggleBtn.classList.add('hidden');
        } else {
            viewMode.classList.remove('hidden');
            editForm.classList.add('hidden');
            toggleBtn.classList.remove('hidden');
            clearFieldErrors(editForm);
        }
    }

    // ---- Save profile info ----
    function saveProfileInfo() {
        const fullName = document.getElementById('editFullName').value;
        const email = document.getElementById('editEmail').value;
        const phone = document.getElementById('editPhone').value;
        const birthday = document.getElementById('editBirthday').value;
        const gender = document.getElementById('editGender').value;

        const btn = document.getElementById('saveInfoBtn');
        btn.disabled = true;
        const originalText = btn.textContent;
        btn.textContent = 'Đang lưu...';

        const params = new URLSearchParams();
        params.append('action', 'updateInfo');
        params.append('fullName', fullName);
        params.append('email', email);
        params.append('phoneNumber', phone);
        params.append('birthday', birthday);
        params.append('gender', gender);

        fetch(CTX + '/account/update-profile', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
            body: params
        })
            .then(r => r.json())
            .then(data => {
                btn.disabled = false;
                btn.textContent = originalText;
                if (data.success) {
                    if (data.requiresOtp) {
                        document.getElementById('otpTargetEmail').textContent = data.email || email;
                        document.getElementById('otpInput').value = '';
                        document.getElementById('otpError').classList.add('hidden');
                        openModal('emailOtpModal');
                        showToast('Đã gửi mã OTP', data.message);
                        return;
                    }
                    syncProfileUi(data);
                    enterEditMode(false);
                    showToast('Thành công', 'Đã cập nhật thông tin cá nhân.');
                } else if (data.code === 'VALIDATION_ERROR') {
                    showFieldErrors(document.getElementById('infoEditForm'), data.fieldErrors);
                } else {
                    showToast('Không thể cập nhật', data.message, true);
                }
            })
            .catch(() => {
                btn.disabled = false;
                btn.textContent = originalText;
                showToast('Lỗi kết nối', 'Không thể kết nối máy chủ. Vui lòng thử lại.', true);
            });
    }

    function verifyEmailOtp() {
        const otp = document.getElementById('otpInput').value.trim();
        const err = document.getElementById('otpError');
        if (!/^\d{6}$/.test(otp)) {
            err.textContent = 'Vui lòng nhập mã OTP gồm 6 chữ số.';
            err.classList.remove('hidden');
            return;
        }
        const btn = document.getElementById('otpConfirmBtn');
        btn.disabled = true;

        const params = new URLSearchParams();
        params.append('action', 'verifyEmailOtp');
        params.append('otp', otp);

        fetch(CTX + '/account/update-profile', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
            body: params
        })
            .then(r => r.json())
            .then(data => {
                btn.disabled = false;
                if (data.success) {
                    syncProfileUi(data);
                    closeModal('emailOtpModal');
                    enterEditMode(false);
                    showToast('Thành công', 'Đã cập nhật thông tin cá nhân.');
                } else {
                    err.textContent = data.message || 'Không thể xác thực OTP.';
                    err.classList.remove('hidden');
                }
            })
            .catch(() => {
                btn.disabled = false;
                err.textContent = 'Lỗi kết nối. Vui lòng thử lại.';
                err.classList.remove('hidden');
            });
    }

    function syncProfileUi(data) {
        document.getElementById('viewFullName').textContent = data.fullName || '-';
        document.getElementById('viewEmail').textContent = data.email || '-';
        document.getElementById('viewPhone').textContent = data.phoneNumber || '-';
        document.getElementById('viewBirthday').textContent = data.birthday ? formatDateVn(data.birthday) : '-';
        document.getElementById('viewGender').textContent = data.gender || '-';

        document.getElementById('editFullName').value = data.fullName || '';
        document.getElementById('editEmail').value = data.email || '';
        document.getElementById('editPhone').value = data.phoneNumber || '';
        document.getElementById('editBirthday').value = data.birthday || '';
        document.getElementById('editGender').value = data.gender || '';

        document.getElementById('accSummaryName').textContent = data.fullName || '';
        document.getElementById('accSummaryEmail').textContent = data.email || 'Chưa cập nhật email';
        const phoneEl = document.getElementById('accSummaryPhone');
        if (phoneEl) phoneEl.textContent = data.phoneNumber || 'Chưa cập nhật số điện thoại';
    }

    function formatDateVn(iso) {
        const parts = iso.split('-');
        return parts.length === 3 ? (parts[2] + '/' + parts[1] + '/' + parts[0]) : iso;
    }

    // ---- Avatar upload ----
    document.getElementById('accAvatarInput').addEventListener('change', function () {
        const file = this.files && this.files[0];
        const errEl = document.getElementById('accAvatarError');
        errEl.classList.add('hidden');
        if (!file) return;

        if (file.size > 2 * 1024 * 1024) {
            errEl.textContent = 'Ảnh quá lớn. Vui lòng chọn ảnh dưới 2MB.';
            errEl.classList.remove('hidden');
            this.value = '';
            return;
        }
        if (!['image/jpeg', 'image/png', 'image/webp', 'image/gif'].includes(file.type)) {
            errEl.textContent = 'Chỉ hỗ trợ định dạng JPG, PNG, WEBP hoặc GIF.';
            errEl.classList.remove('hidden');
            this.value = '';
            return;
        }

        const fd = new FormData();
        fd.append('action', 'updateAvatar');
        fd.append('avatar', file);

        fetch(CTX + '/account/update-profile', { method: 'POST', body: fd })
            .then(r => r.json())
            .then(data => {
                if (data.success) {
                    document.querySelectorAll('.js-avatar-img').forEach(img => { img.src = data.avatarUrl; img.hidden = false; img.classList.remove('hidden'); });
                    document.querySelectorAll('.js-avatar-initial').forEach(el => { el.hidden = true; });
                    showToast('Thành công', 'Đã cập nhật ảnh đại diện.');
                } else {
                    errEl.textContent = data.message || 'Không thể tải ảnh lên.';
                    errEl.classList.remove('hidden');
                }
            })
            .catch(() => {
                errEl.textContent = 'Lỗi kết nối khi tải ảnh. Vui lòng thử lại.';
                errEl.classList.remove('hidden');
            });
    });

    // ---- Change password ----
    function openPwModal() {
        document.getElementById('pwForm').reset();
        clearFieldErrors(document.getElementById('pwForm'));
        ['pwStr1', 'pwStr2', 'pwStr3', 'pwStr4'].forEach(id => { document.getElementById(id).style.backgroundColor = ''; });
        document.getElementById('pwStrengthLabel').textContent = '';
        openModal('pwModal');
    }

    function togglePw(id, btn) {
        const input = document.getElementById(id);
        if (input.type === 'password') { input.type = 'text'; btn.classList.add('is-visible'); }
        else { input.type = 'password'; btn.classList.remove('is-visible'); }
    }

    function updatePwStrength() {
        const v = document.getElementById('pwNew').value;
        let score = 0;
        if (v.length >= 8) score++;
        if (/[A-Z]/.test(v)) score++;
        if (/[0-9]/.test(v)) score++;
        if (/[^A-Za-z0-9]/.test(v)) score++;
        const colors = ['#ef4444', '#f59e0b', '#3b82f6', '#10b981'];
        const labels = ['', 'Yếu', 'Trung bình', 'Mạnh', 'Rất mạnh'];
        for (let i = 1; i <= 4; i++) {
            document.getElementById('pwStr' + i).style.backgroundColor = i <= score ? colors[score - 1] : '';
        }
        document.getElementById('pwStrengthLabel').textContent = v.length ? labels[score] : '';
    }

    function savePassword() {
        const form = document.getElementById('pwForm');
        const currentPassword = document.getElementById('pwCurrent').value;
        const newPassword = document.getElementById('pwNew').value;
        const confirmPassword = document.getElementById('pwConfirm').value;
        clearFieldErrors(form);

        let hasError = false;
        if (!currentPassword) {
            form.querySelector('[data-error-for="currentPassword"]').textContent = 'Vui lòng nhập mật khẩu hiện tại.';
            form.querySelector('[data-error-for="currentPassword"]').classList.remove('hidden');
            hasError = true;
        }
        if (!newPassword) {
            form.querySelector('[data-error-for="newPassword"]').textContent = 'Vui lòng nhập mật khẩu mới.';
            form.querySelector('[data-error-for="newPassword"]').classList.remove('hidden');
            hasError = true;
        }
        if (newPassword && newPassword !== confirmPassword) {
            form.querySelector('[data-error-for="confirmPassword"]').textContent = 'Xác nhận mật khẩu mới không khớp.';
            form.querySelector('[data-error-for="confirmPassword"]').classList.remove('hidden');
            hasError = true;
        }
        if (hasError) return;

        const btn = document.getElementById('pwSaveBtn');
        btn.disabled = true;
        const originalText = btn.textContent;
        btn.textContent = 'Đang lưu...';

        const params = new URLSearchParams();
        params.append('action', 'changePassword');
        params.append('currentPassword', currentPassword);
        params.append('newPassword', newPassword);
        params.append('confirmPassword', confirmPassword);

        fetch(CTX + '/account/update-profile', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
            body: params
        })
            .then(r => r.json())
            .then(data => {
                btn.disabled = false;
                btn.textContent = originalText;
                if (data.success) {
                    form.reset();
                    closeModal('pwModal');
                    showToast('Thành công', 'Mật khẩu đã được cập nhật.');
                } else {
                    form.querySelector('[data-error-for="currentPassword"]').textContent = data.message || 'Không thể đổi mật khẩu.';
                    form.querySelector('[data-error-for="currentPassword"]').classList.remove('hidden');
                }
            })
            .catch(() => {
                btn.disabled = false;
                btn.textContent = originalText;
                showToast('Lỗi kết nối', 'Không thể kết nối máy chủ. Vui lòng thử lại.', true);
            })
            .finally(() => {
                document.getElementById('pwCurrent').value = '';
                document.getElementById('pwNew').value = '';
                document.getElementById('pwConfirm').value = '';
            });
    }
</script>

<jsp:include page="/customer/common/urgent-opponent-modal.jsp" />
<jsp:include page="/customer/common/bottom-nav.jsp" />
</body>
</html>
