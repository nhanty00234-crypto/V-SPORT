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
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&amp;display=swap" rel="stylesheet"/>

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
        /* ============================================================
           Booking-choice modal + facility detail bottom sheet
           (Lucide inline icons, Be Vietnam Pro, tokens theo customer theme)
           ============================================================ */
        :root {
            --vsx-font: 'Be Vietnam Pro', 'Inter', system-ui, -apple-system, sans-serif;
            --vs-mint-100: #e7faef;
            --vs-mint-50: #f3fcf7;
            --vs-pink-100: #fae8f8;
            --vs-pink-600: #c83db3;
            --vs-overlay: rgba(0, 35, 20, 0.68);
            --vsx-border: #dbe9e1;
            --vsx-text: #153d2b;
            --vsx-muted: #6f8379;
        }
        .lci { width: 20px; height: 20px; flex-shrink: 0; }

        /* [hidden] phải thắng cả các class có display:flex/inline-flex */
        [hidden] { display: none !important; }

        .vsx-overlay {
            position: fixed; inset: 0; background: var(--vs-overlay);
            z-index: 1240; opacity: 0; transition: opacity 220ms ease;
        }
        .vsx-overlay.is-open { opacity: 1; }

        /* ---- Modal "Chọn hình thức đặt" ---- */
        .vsbc-modal {
            position: fixed; left: 50%; top: 50%;
            transform: translate(-50%, -50%) scale(.96);
            width: min(600px, calc(100vw - 24px));
            max-height: calc(100dvh - 32px); overflow-y: auto;
            background: #fff; border-radius: 18px; padding: 18px;
            z-index: 1250; opacity: 0;
            box-shadow: 0 22px 60px rgba(0, 35, 20, 0.28);
            transition: opacity 200ms ease, transform 200ms ease;
            font-family: var(--vsx-font); color: var(--vsx-text);
        }
        .vsbc-modal.is-open { opacity: 1; transform: translate(-50%, -50%) scale(1); }
        .vsbc-head { display: flex; align-items: flex-start; justify-content: space-between; gap: 12px; margin-bottom: 4px; }
        .vsbc-title { font-size: 20px; font-weight: 800; text-align: center; flex: 1; padding-left: 36px; }
        .vsbc-sub { text-align: center; font-size: 13px; color: var(--vsx-muted); margin: 2px 0 14px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .vsbc-x {
            width: 36px; height: 36px; border-radius: 50%; border: none; cursor: pointer;
            background: #f1f7f4; color: var(--vsx-text);
            display: flex; align-items: center; justify-content: center; flex-shrink: 0;
            transition: background-color .15s ease;
        }
        .vsbc-x:hover { background: #e2eee8; }
        .vsbc-x:focus-visible { outline: 2px solid #009b52; outline-offset: 2px; }
        .vsbc-option {
            display: flex; align-items: center; gap: 14px;
            width: 100%; padding: 16px; border-radius: 14px; border: 1px solid transparent;
            text-decoration: none; cursor: pointer; text-align: left;
            transition: transform .15s ease, box-shadow .15s ease;
        }
        .vsbc-option + .vsbc-option { margin-top: 10px; }
        .vsbc-option:hover { transform: translateY(-2px); box-shadow: 0 8px 22px rgba(0, 35, 20, 0.10); }
        .vsbc-option:focus-visible { outline: 2.5px solid #009b52; outline-offset: 2px; }
        .vsbc-option-direct { background: var(--vs-mint-100); border-color: #cdeeda; }
        .vsbc-option-direct .vsbc-opt-title { color: #007a45; }
        .vsbc-option-direct .vsbc-opt-ic { background: #d3f3e0; color: #007a45; }
        .vsbc-option-match { background: var(--vs-pink-100); border-color: #f3d3ef; }
        .vsbc-option-match .vsbc-opt-title { color: var(--vs-pink-600); }
        .vsbc-option-match .vsbc-opt-ic { background: #f5d9f1; color: var(--vs-pink-600); }
        .vsbc-opt-ic { width: 46px; height: 46px; border-radius: 12px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
        .vsbc-opt-ic .lci { width: 24px; height: 24px; }
        .vsbc-opt-title { font-size: 17px; font-weight: 800; display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }
        .vsbc-opt-desc { font-size: 13.5px; color: #48604f; margin-top: 3px; line-height: 1.45; }
        .vsbc-badge {
            font-size: 10.5px; font-weight: 800; text-transform: uppercase; letter-spacing: .04em;
            background: var(--vs-pink-600); color: #fff; padding: 2px 8px; border-radius: 9999px;
        }
        .vsbc-arrow {
            width: 38px; height: 38px; border-radius: 10px; margin-left: auto; flex-shrink: 0;
            display: flex; align-items: center; justify-content: center; color: #fff;
        }
        .vsbc-option-direct .vsbc-arrow { background: #12b76a; }
        .vsbc-option-match .vsbc-arrow { background: #d879cd; }

        /* ---- Facility detail bottom sheet ---- */
        .vsfs-sheet {
            position: fixed; left: 0; right: 0; bottom: 0; width: 100%;
            max-height: 82dvh;
            background: #fff; border-radius: 24px 24px 0 0;
            z-index: 1250; transform: translateY(100%);
            transition: transform 300ms cubic-bezier(.22, 1, .36, 1);
            box-shadow: 0 -18px 50px rgba(0, 35, 20, 0.30);
            display: flex; flex-direction: column;
            font-family: var(--vsx-font); color: var(--vsx-text);
        }
        .vsfs-sheet.is-open { transform: translateY(0); }
        .vsfs-handle-wrap { padding: 8px 0 2px; display: flex; justify-content: center; cursor: grab; touch-action: none; flex-shrink: 0; }
        .vsfs-handle { width: 48px; height: 5px; border-radius: 9999px; background: #d5e2db; }
        .vsfs-topbar { display: flex; align-items: center; justify-content: flex-end; gap: 8px; padding: 2px 16px 8px; flex-shrink: 0; }
        .vsfs-iconbtn {
            width: 44px; height: 44px; border-radius: 50%; border: 1px solid var(--vsx-border);
            background: #fff; color: var(--vsx-text); cursor: pointer;
            display: flex; align-items: center; justify-content: center;
            transition: background-color .15s ease, color .15s ease;
        }
        .vsfs-iconbtn:hover { background: var(--vs-mint-50); }
        .vsfs-iconbtn:focus-visible { outline: 2px solid #009b52; outline-offset: 2px; }
        .vsfs-iconbtn.is-fav { color: #e11d48; border-color: #fecdd3; background: #fff1f2; }
        .vsfs-scroll { overflow-y: auto; min-height: 0; flex: 1; -webkit-overflow-scrolling: touch; overscroll-behavior: contain; }
        .vsfs-inner { width: 100%; max-width: 1360px; margin: 0 auto; padding: 0 16px 18px; }
        @media (min-width: 1024px) { .vsfs-inner { padding: 0 28px 24px; } }
        .vsfs-cols { display: grid; grid-template-columns: 1fr; gap: 18px; }
        @media (min-width: 1024px) { .vsfs-cols { grid-template-columns: 42% minmax(0, 1fr); gap: 26px; align-items: start; } }
        .vsfs-hero {
            position: relative; border-radius: 16px; overflow: hidden; background: #eef4f1;
            aspect-ratio: 16 / 10;
        }
        .vsfs-hero img { width: 100%; height: 100%; object-fit: cover; display: block; }
        .vsfs-name { font-size: 24px; font-weight: 800; line-height: 1.25; }
        @media (min-width: 1024px) { .vsfs-name { font-size: 28px; } }
        .vsfs-chips { display: flex; flex-wrap: wrap; gap: 6px; margin-top: 8px; }
        .vsfs-chip {
            display: inline-flex; align-items: center; gap: 5px;
            font-size: 12px; font-weight: 700; padding: 4px 11px; border-radius: 9999px;
            background: var(--vs-mint-100); color: #007a45; border: 1px solid #cdeeda;
        }
        .vsfs-chip.is-warn { background: #fff7e6; color: #b45309; border-color: #fde4b8; }
        .vsfs-meta { margin-top: 12px; display: flex; flex-direction: column; gap: 8px; }
        .vsfs-meta-row { display: flex; align-items: flex-start; gap: 9px; font-size: 14px; color: #3c5a4b; }
        .vsfs-meta-row .lci { width: 18px; height: 18px; color: #009b52; margin-top: 1px; }
        .vsfs-price { font-size: 15px; font-weight: 800; color: #007a45; margin-top: 10px; }
        .vsfs-tabs {
            display: flex; gap: 4px; margin-top: 18px; border-bottom: 1px solid var(--vsx-border);
            overflow-x: auto; scrollbar-width: none; -ms-overflow-style: none;
        }
        .vsfs-tabs::-webkit-scrollbar { display: none; }
        .vsfs-tab {
            border: none; background: transparent; cursor: pointer;
            padding: 10px 14px; font-family: inherit; font-size: 14px; font-weight: 700;
            color: var(--vsx-muted); border-bottom: 2.5px solid transparent;
            white-space: nowrap; transition: color .15s ease, border-color .15s ease;
            min-height: 44px;
        }
        .vsfs-tab:hover { color: var(--vsx-text); }
        .vsfs-tab:focus-visible { outline: 2px solid #009b52; outline-offset: -2px; }
        .vsfs-tab[aria-selected="true"] { color: #007a45; border-bottom-color: #009b52; }
        .vsfs-panel { padding: 14px 2px 4px; font-size: 14px; line-height: 1.6; color: #3c5a4b; }
        .vsfs-court {
            display: flex; align-items: center; justify-content: space-between; gap: 12px; flex-wrap: wrap;
            border: 1px solid var(--vsx-border); border-radius: 12px; padding: 12px 14px;
        }
        .vsfs-court + .vsfs-court { margin-top: 8px; }
        .vsfs-court-name { font-size: 14.5px; font-weight: 800; color: var(--vsx-text); }
        .vsfs-court-sub { font-size: 12.5px; color: var(--vsx-muted); margin-top: 2px; }
        .vsfs-court-price { font-size: 13.5px; font-weight: 800; color: #007a45; white-space: nowrap; }
        .vsfs-status {
            display: inline-block; font-size: 11px; font-weight: 700; padding: 2px 9px;
            border-radius: 9999px; margin-left: 8px; vertical-align: 2px;
        }
        .vsfs-status.is-ready { background: var(--vs-mint-100); color: #007a45; }
        .vsfs-status.is-other { background: #f1f5f9; color: #64748b; }
        .vsfs-court-cta {
            display: inline-flex; align-items: center; gap: 6px;
            font-size: 12.5px; font-weight: 800; text-decoration: none;
            color: #007a45; border: 1px solid #9adfba; background: var(--vs-mint-50);
            padding: 8px 14px; border-radius: 8px; white-space: nowrap;
            transition: background-color .15s ease; min-height: 38px;
        }
        .vsfs-court-cta:hover { background: var(--vs-mint-100); }
        .vsfs-service { display: flex; justify-content: space-between; gap: 12px; padding: 9px 2px; border-bottom: 1px solid #edf4f0; font-size: 13.5px; }
        .vsfs-service b { font-weight: 800; color: #007a45; white-space: nowrap; }
        .vsfs-imggrid { display: grid; grid-template-columns: repeat(auto-fill, minmax(160px, 1fr)); gap: 8px; }
        .vsfs-imggrid img { width: 100%; aspect-ratio: 4 / 3; object-fit: cover; border-radius: 10px; background: #eef4f1; }
        .vsfs-policy-item { display: flex; gap: 9px; align-items: flex-start; }
        .vsfs-policy-item + .vsfs-policy-item { margin-top: 9px; }
        .vsfs-policy-item .lci { width: 17px; height: 17px; color: #009b52; margin-top: 2px; }
        .vsfs-actionbar {
            flex-shrink: 0; border-top: 1px solid var(--vsx-border); background: #fff;
            padding: 12px 16px calc(12px + env(safe-area-inset-bottom, 0px));
        }
        .vsfs-actionbar-inner { width: 100%; max-width: 1360px; margin: 0 auto; display: flex; gap: 10px; justify-content: flex-end; flex-wrap: wrap; }
        .vsfs-btn {
            display: inline-flex; align-items: center; justify-content: center; gap: 8px;
            min-height: 46px; padding: 0 22px; border-radius: 10px; cursor: pointer;
            font-family: inherit; font-size: 14.5px; font-weight: 800; text-decoration: none;
            border: 1px solid transparent; transition: background-color .15s ease;
        }
        .vsfs-btn:focus-visible { outline: 2.5px solid #009b52; outline-offset: 2px; }
        .vsfs-btn-primary { background: #008249; color: #fff; }
        .vsfs-btn-primary:hover { background: #006c3c; }
        .vsfs-btn-ghost { background: #fff; color: var(--vsx-text); border-color: var(--vsx-border); }
        .vsfs-btn-ghost:hover { background: var(--vs-mint-50); }
        @media (max-width: 767px) {
            .vsfs-sheet { max-height: 92dvh; border-radius: 22px 22px 0 0; }
            .vsfs-actionbar-inner { justify-content: stretch; }
            .vsfs-actionbar .vsfs-btn-primary { flex: 1; }
        }

        /* Skeleton shimmer */
        .vsx-skel {
            background: linear-gradient(90deg, #eef4f1 25%, #e2ece7 37%, #eef4f1 63%);
            background-size: 400% 100%; animation: vsxShimmer 1.4s ease infinite;
            border-radius: 8px;
        }
        @keyframes vsxShimmer { 0% { background-position: 100% 50%; } 100% { background-position: 0 50%; } }

        .vsfs-error { text-align: center; padding: 34px 16px; }
        .vsfs-error p { font-size: 14.5px; font-weight: 600; color: var(--vsx-muted); margin-bottom: 14px; }

        @media (prefers-reduced-motion: reduce) {
            .vsx-overlay, .vsbc-modal, .vsfs-sheet { transition: none !important; }
            .vsx-skel { animation: none; }
        }

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
                            <a href="<%= ctx %>/dangky" class="vs-auth-btn vs-auth-btn-register" aria-label="Đăng ký" title="Đăng ký">Đăng ký</a>
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
                <div class="facility-card vs-card overflow-hidden group flex flex-col relative bg-white border border-gray-100 hover:shadow-md transition-shadow duration-300 cursor-pointer"
                     data-name="<%= csName.toLowerCase() %>"
                     data-address="<%= csAddr.toLowerCase() %>"
                     data-sport="<%= sportsLower %>"
                     data-coso-id="<%= cs.getCoSoID() %>"
                     data-facility-name="<%= csNameSafe %>"
                     data-card-image="<%= cardImgUrl.replace("\"", "&quot;") %>"
                     role="button" tabindex="0"
                     aria-label="Xem chi tiết <%= csNameSafe %>">

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

                        <!-- Booking trigger CTA button: opens the "Chọn hình thức đặt" modal -->
                        <div class="shrink-0 self-center">
                            <button type="button" data-book-trigger
                                    data-coso-id="<%= cs.getCoSoID() %>"
                                    data-facility-name="<%= csNameSafe %>"
                                    aria-label="Đặt lịch tại <%= csNameSafe %>" aria-haspopup="dialog"
                                    class="bg-yellow-500 hover:bg-yellow-600 text-gray-900 text-[11.5px] font-extrabold px-3 py-2 rounded-md tracking-wide transition-colors shadow-sm whitespace-nowrap border-none cursor-pointer">
                                ĐẶT LỊCH
                            </button>
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

    <!-- ============ Modal "Chọn hình thức đặt" (một instance dùng chung) ============ -->
    <div id="bookingChoiceOverlay" class="vsx-overlay" hidden></div>
    <div id="bookingChoiceModal" class="vsbc-modal" role="dialog" aria-modal="true" aria-labelledby="bookingChoiceTitle" hidden>
        <div class="vsbc-head">
            <h2 id="bookingChoiceTitle" class="vsbc-title">Chọn hình thức đặt</h2>
            <button type="button" id="bcCloseBtn" class="vsbc-x" aria-label="Đóng hộp thoại">
                <svg class="lci" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg>
            </button>
        </div>
        <p id="bcFacilityName" class="vsbc-sub"></p>

        <a id="bcOptionDirect" class="vsbc-option vsbc-option-direct" href="#">
            <span class="vsbc-opt-ic">
                <svg class="lci" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M8 2v4"/><path d="M16 2v4"/><rect width="18" height="18" x="3" y="4" rx="2"/><path d="M3 10h18"/><path d="m9 16 2 2 4-4"/></svg>
            </span>
            <span style="min-width:0;">
                <span class="vsbc-opt-title">Đặt sân trực tiếp</span>
                <span class="vsbc-opt-desc" style="display:block;">Chọn sân, ngày và khung giờ phù hợp để đặt sân ngay.</span>
            </span>
            <span class="vsbc-arrow" aria-hidden="true">
                <svg class="lci" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14"/><path d="m12 5 7 7-7 7"/></svg>
            </span>
        </a>

        <a id="bcOptionMatch" class="vsbc-option vsbc-option-match" href="#">
            <span class="vsbc-opt-ic">
                <svg class="lci" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M18 21a8 8 0 0 0-16 0"/><circle cx="10" cy="8" r="5"/><path d="M22 20c0-3.37-2-6.5-4-8a5 5 0 0 0-.45-8.3"/></svg>
            </span>
            <span style="min-width:0;">
                <span class="vsbc-opt-title">Tạo kèo / Tìm người chơi <span class="vsbc-badge">Ghép trận</span></span>
                <span class="vsbc-opt-desc" style="display:block;">Tạo một trận mới hoặc tìm thêm người chơi phù hợp tại sân này.</span>
            </span>
            <span class="vsbc-arrow" aria-hidden="true">
                <svg class="lci" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14"/><path d="m12 5 7 7-7 7"/></svg>
            </span>
        </a>
    </div>

    <!-- ============ Facility detail bottom sheet (một instance dùng chung) ============ -->
    <div id="facilitySheetOverlay" class="vsx-overlay" hidden></div>
    <section id="facilitySheet" class="vsfs-sheet" role="dialog" aria-modal="true" aria-labelledby="fsName" hidden>
        <div class="vsfs-handle-wrap" id="fsHandle" aria-hidden="true"><span class="vsfs-handle"></span></div>
        <div class="vsfs-topbar">
            <button type="button" id="fsFavBtn" class="vsfs-iconbtn" aria-label="Lưu cơ sở yêu thích">
                <svg class="lci" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M19 14c1.49-1.46 3-3.21 3-5.5A5.5 5.5 0 0 0 16.5 3c-1.76 0-3 .5-4.5 2-1.5-1.5-2.74-2-4.5-2A5.5 5.5 0 0 0 2 8.5c0 2.3 1.5 4.05 3 5.5l7 7Z"/></svg>
            </button>
            <button type="button" id="fsShareBtn" class="vsfs-iconbtn" aria-label="Chia sẻ cơ sở">
                <svg class="lci" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="18" cy="5" r="3"/><circle cx="6" cy="12" r="3"/><circle cx="18" cy="19" r="3"/><line x1="8.59" x2="15.42" y1="13.51" y2="17.49"/><line x1="15.41" x2="8.59" y1="6.51" y2="10.49"/></svg>
            </button>
            <a id="fsMapBtn" class="vsfs-iconbtn" href="#" aria-label="Xem trên bản đồ" hidden>
                <svg class="lci" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M18 8c0 3.613-3.869 7.429-5.393 8.795a1 1 0 0 1-1.214 0C9.87 15.429 6 11.613 6 8a6 6 0 0 1 12 0"/><circle cx="12" cy="8" r="2"/><path d="M8.714 14h-3.71a1 1 0 0 0-.948.683l-2.004 6A1 1 0 0 0 3 22h18a1 1 0 0 0 .948-1.316l-2-6a1 1 0 0 0-.949-.684h-3.712"/></svg>
            </a>
            <button type="button" id="fsCloseBtn" class="vsfs-iconbtn" aria-label="Đóng chi tiết sân">
                <svg class="lci" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg>
            </button>
        </div>

        <div class="vsfs-scroll" id="fsScroll">
            <div class="vsfs-inner">
                <!-- Skeleton state -->
                <div id="fsSkeleton" class="vsfs-cols">
                    <div class="vsx-skel" style="aspect-ratio:16/10;border-radius:16px;"></div>
                    <div>
                        <div class="vsx-skel" style="height:30px;width:62%;"></div>
                        <div class="vsx-skel" style="height:15px;width:88%;margin-top:14px;"></div>
                        <div class="vsx-skel" style="height:15px;width:74%;margin-top:9px;"></div>
                        <div class="vsx-skel" style="height:15px;width:52%;margin-top:9px;"></div>
                    </div>
                </div>

                <!-- Error state -->
                <div id="fsError" class="vsfs-error" hidden>
                    <p>Không thể tải thông tin sân. Vui lòng thử lại.</p>
                    <button type="button" id="fsRetryBtn" class="vsfs-btn vsfs-btn-ghost">
                        <svg class="lci" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M3 12a9 9 0 1 0 9-9 9.75 9.75 0 0 0-6.74 2.74L3 8"/><path d="M3 3v5h5"/></svg>
                        Thử lại
                    </button>
                </div>

                <!-- Loaded content -->
                <div id="fsContent" hidden>
                    <div class="vsfs-cols">
                        <div class="vsfs-hero"><img id="fsHeroImg" src="" alt=""></div>
                        <div style="min-width:0;">
                            <h2 class="vsfs-name" id="fsName"></h2>
                            <div class="vsfs-chips" id="fsChips"></div>
                            <div class="vsfs-meta" id="fsMeta"></div>
                            <p class="vsfs-price" id="fsPrice" hidden></p>
                        </div>
                    </div>

                    <div class="vsfs-tabs" role="tablist" aria-label="Thông tin chi tiết cơ sở" id="fsTablist">
                        <button type="button" class="vsfs-tab" role="tab" id="fsTab-overview" aria-controls="fsPanel-overview" aria-selected="true" data-fstab="overview">Tổng quan</button>
                        <button type="button" class="vsfs-tab" role="tab" id="fsTab-courts" aria-controls="fsPanel-courts" aria-selected="false" data-fstab="courts">Sân &amp; bảng giá</button>
                        <button type="button" class="vsfs-tab" role="tab" id="fsTab-services" aria-controls="fsPanel-services" aria-selected="false" data-fstab="services">Dịch vụ</button>
                        <button type="button" class="vsfs-tab" role="tab" id="fsTab-images" aria-controls="fsPanel-images" aria-selected="false" data-fstab="images">Hình ảnh</button>
                        <button type="button" class="vsfs-tab" role="tab" id="fsTab-policy" aria-controls="fsPanel-policy" aria-selected="false" data-fstab="policy">Chính sách</button>
                    </div>
                    <div class="vsfs-panel" role="tabpanel" id="fsPanel-overview" aria-labelledby="fsTab-overview" tabindex="0"></div>
                    <div class="vsfs-panel" role="tabpanel" id="fsPanel-courts" aria-labelledby="fsTab-courts" tabindex="0" hidden></div>
                    <div class="vsfs-panel" role="tabpanel" id="fsPanel-services" aria-labelledby="fsTab-services" tabindex="0" hidden></div>
                    <div class="vsfs-panel" role="tabpanel" id="fsPanel-images" aria-labelledby="fsTab-images" tabindex="0" hidden></div>
                    <div class="vsfs-panel" role="tabpanel" id="fsPanel-policy" aria-labelledby="fsTab-policy" tabindex="0" hidden>
                        <p style="font-size:12px;font-weight:800;text-transform:uppercase;letter-spacing:.04em;color:var(--vsx-muted);margin-bottom:10px;">Chính sách chung của V-SPORT</p>
                        <div class="vsfs-policy-item">
                            <svg class="lci" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="10"/><path d="m9 12 2 2 4-4"/></svg>
                            <span>Hủy sân miễn phí khi hủy trước giờ bắt đầu ít nhất 6 tiếng (áp dụng cho đơn chờ xác nhận).</span>
                        </div>
                        <div class="vsfs-policy-item">
                            <svg class="lci" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                            <span>Thanh toán online qua PayOS: sân được giữ chỗ trong 10 phút chờ thanh toán.</span>
                        </div>
                        <div class="vsfs-policy-item">
                            <svg class="lci" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 13c0 5-3.5 7.5-7.66 8.95a1 1 0 0 1-.67-.01C7.5 20.5 4 18 4 13V6a1 1 0 0 1 1-1c2 0 4.5-1.2 6.24-2.72a1 1 0 0 1 1.52 0C14.51 3.81 17 5 19 5a1 1 0 0 1 1 1z"/><path d="m9 12 2 2 4-4"/></svg>
                            <span>Hủy sát giờ hoặc không đến sân sẽ ảnh hưởng điểm uy tín người chơi của bạn.</span>
                        </div>
                        <div class="vsfs-policy-item">
                            <svg class="lci" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M8 2v4"/><path d="M16 2v4"/><rect width="18" height="18" x="3" y="4" rx="2"/><path d="M3 10h18"/></svg>
                            <span>Mỗi tài khoản đặt tối đa 3 ca hoạt động trong cùng một ngày trên toàn hệ thống.</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="vsfs-actionbar">
            <div class="vsfs-actionbar-inner">
                <a id="fsCallBtn" class="vsfs-btn vsfs-btn-ghost" href="#" hidden>
                    <svg class="lci" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M13.832 16.568a1 1 0 0 0 1.213-.303l.355-.465A2 2 0 0 1 17 15h3a2 2 0 0 1 2 2v3a2 2 0 0 1-2 2A18 18 0 0 1 2 4a2 2 0 0 1 2-2h3a2 2 0 0 1 2 2v3a2 2 0 0 1-.8 1.6l-.468.351a1 1 0 0 0-.292 1.233 14 14 0 0 0 6.392 6.384"/></svg>
                    Gọi cơ sở
                </a>
                <a id="fsMapActionBtn" class="vsfs-btn vsfs-btn-ghost" href="<%= ctx %>/customer/ban-do">
                    <svg class="lci" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M14.106 5.553a2 2 0 0 0 1.788 0l3.659-1.83A1 1 0 0 1 21 4.619v12.764a1 1 0 0 1-.553.894l-4.553 2.277a2 2 0 0 1-1.788 0l-4.212-2.106a2 2 0 0 0-1.788 0l-3.659 1.83A1 1 0 0 1 3 19.381V6.618a1 1 0 0 1 .553-.894l4.553-2.277a2 2 0 0 1 1.788 0z"/><path d="M15 5.764v15"/><path d="M9 3.236v15"/></svg>
                    Xem bản đồ
                </a>
                <button type="button" id="fsBookBtn" class="vsfs-btn vsfs-btn-primary">
                    <svg class="lci" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M8 2v4"/><path d="M16 2v4"/><rect width="18" height="18" x="3" y="4" rx="2"/><path d="M3 10h18"/><path d="m9 16 2 2 4-4"/></svg>
                    Đặt sân
                </button>
            </div>
        </div>
    </section>

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

        /* ======================================================================
           Booking-choice modal + facility detail bottom sheet
           ====================================================================== */
        window.VSPORT_CONTEXT_PATH = '<%= ctx %>';
        (function () {
            'use strict';
            const CTX = window.VSPORT_CONTEXT_PATH;
            const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

            // ---- Shared helpers -------------------------------------------------
            let scrollLocks = 0;
            function lockScroll()   { scrollLocks++; document.body.style.overflow = 'hidden'; }
            function unlockScroll() { scrollLocks = Math.max(0, scrollLocks - 1); if (!scrollLocks) document.body.style.overflow = ''; }

            function focusables(container) {
                return Array.from(container.querySelectorAll(
                    'a[href], button:not([disabled]), input, select, textarea, [tabindex]:not([tabindex="-1"])'
                )).filter(el => !el.hidden && el.offsetParent !== null);
            }
            function trapTab(container, e) {
                if (e.key !== 'Tab') return;
                const list = focusables(container);
                if (!list.length) { e.preventDefault(); return; }
                const first = list[0], last = list[list.length - 1];
                if (e.shiftKey && document.activeElement === first) { e.preventDefault(); last.focus(); }
                else if (!e.shiftKey && document.activeElement === last) { e.preventDefault(); first.focus(); }
            }
            function fmtVnd(n) {
                if (typeof n !== 'number' || !isFinite(n) || n <= 0) return null;
                return new Intl.NumberFormat('vi-VN').format(Math.round(n)) + 'đ';
            }
            function resolveImg(v) {
                if (!v) return null;
                if (v.startsWith('http://') || v.startsWith('https://')) return v;
                return CTX + (v.startsWith('/') ? v : '/' + v);
            }

            // ================= Booking-choice modal =============================
            const bcOverlay = document.getElementById('bookingChoiceOverlay');
            const bcModal = document.getElementById('bookingChoiceModal');
            const bcClose = document.getElementById('bcCloseBtn');
            const bcDirect = document.getElementById('bcOptionDirect');
            const bcMatch = document.getElementById('bcOptionMatch');
            const bcName = document.getElementById('bcFacilityName');
            let bcReturnFocus = null;
            let bcOpen = false;

            function openBookingChoice(cosoId, facilityName, triggerEl) {
                if (bcOpen) return;
                bcOpen = true;
                bcReturnFocus = triggerEl || document.activeElement;
                bcDirect.href = CTX + '/customer/dat-san?branchId=' + encodeURIComponent(cosoId);
                bcMatch.href = CTX + '/customer/ghep-keo?tab=tao-keo&coSoId=' + encodeURIComponent(cosoId);
                bcName.textContent = facilityName || '';
                bcOverlay.hidden = false;
                bcModal.hidden = false;
                requestAnimationFrame(() => {
                    bcOverlay.classList.add('is-open');
                    bcModal.classList.add('is-open');
                });
                lockScroll();
                bcDirect.focus();
            }
            function closeBookingChoice() {
                if (!bcOpen) return;
                bcOpen = false;
                bcOverlay.classList.remove('is-open');
                bcModal.classList.remove('is-open');
                const done = () => { bcOverlay.hidden = true; bcModal.hidden = true; };
                reduceMotion ? done() : setTimeout(done, 210);
                unlockScroll();
                if (bcReturnFocus && document.contains(bcReturnFocus)) bcReturnFocus.focus();
                bcReturnFocus = null;
            }
            bcClose.addEventListener('click', closeBookingChoice);
            bcOverlay.addEventListener('click', closeBookingChoice);
            bcModal.addEventListener('keydown', e => trapTab(bcModal, e));

            // ================= Facility detail bottom sheet =====================
            const fsOverlay = document.getElementById('facilitySheetOverlay');
            const fsSheet = document.getElementById('facilitySheet');
            const fsSkeleton = document.getElementById('fsSkeleton');
            const fsErrorBox = document.getElementById('fsError');
            const fsContent = document.getElementById('fsContent');
            const fsScrollEl = document.getElementById('fsScroll');
            const detailCache = new Map();
            let fsOpen = false;
            let fsReturnFocus = null;
            let fsAbort = null;
            let fsCurrentId = null;
            let fsCurrentName = '';
            let fsCardImage = null;
            let fsPushedState = false;

            function openFacilitySheet(card) {
                const cosoId = card.getAttribute('data-coso-id');
                if (!cosoId) return;
                fsReturnFocus = card;
                fsCurrentId = cosoId;
                fsCurrentName = card.getAttribute('data-facility-name') || '';
                fsCardImage = card.getAttribute('data-card-image') || null;
                fsOpen = true;
                fsOverlay.hidden = false;
                fsSheet.hidden = false;
                fsSheet.style.transform = '';
                requestAnimationFrame(() => {
                    fsOverlay.classList.add('is-open');
                    fsSheet.classList.add('is-open');
                });
                lockScroll();
                document.getElementById('fsCloseBtn').focus();
                try {
                    history.pushState({ vsFacilitySheet: true }, '');
                    fsPushedState = true;
                } catch (e) { fsPushedState = false; }
                loadFacilityDetail(cosoId);
            }

            function closeFacilitySheet(fromPopstate) {
                if (!fsOpen) return;
                fsOpen = false;
                if (fsAbort) { fsAbort.abort(); fsAbort = null; }
                fsOverlay.classList.remove('is-open');
                fsSheet.classList.remove('is-open');
                fsSheet.style.transform = '';
                const done = () => { fsOverlay.hidden = true; fsSheet.hidden = true; };
                reduceMotion ? done() : setTimeout(done, 320);
                unlockScroll();
                if (fsReturnFocus && document.contains(fsReturnFocus)) fsReturnFocus.focus();
                fsReturnFocus = null;
                if (fsPushedState && !fromPopstate) {
                    fsPushedState = false;
                    try { history.back(); } catch (e) { /* noop */ }
                } else {
                    fsPushedState = false;
                }
            }
            window.addEventListener('popstate', () => { if (fsOpen) closeFacilitySheet(true); });

            function showSheetState(state) {
                fsSkeleton.hidden = state !== 'loading';
                fsErrorBox.hidden = state !== 'error';
                fsContent.hidden = state !== 'content';
            }

            function loadFacilityDetail(cosoId) {
                showSheetState('loading');
                if (detailCache.has(cosoId)) {
                    renderFacilityDetail(detailCache.get(cosoId));
                    return;
                }
                if (fsAbort) fsAbort.abort();
                fsAbort = new AbortController();
                fetch(CTX + '/api/customer/facilities/detail?coSoId=' + encodeURIComponent(cosoId), { signal: fsAbort.signal })
                    .then(r => {
                        if (!r.ok) throw new Error('HTTP ' + r.status);
                        return r.json();
                    })
                    .then(data => {
                        detailCache.set(cosoId, data);
                        if (fsOpen && fsCurrentId === cosoId) renderFacilityDetail(data);
                    })
                    .catch(err => {
                        if (err && err.name === 'AbortError') return;
                        if (fsOpen && fsCurrentId === cosoId) showSheetState('error');
                    });
            }
            document.getElementById('fsRetryBtn').addEventListener('click', () => {
                if (fsCurrentId) { detailCache.delete(fsCurrentId); loadFacilityDetail(fsCurrentId); }
            });

            // ---- Rendering (textContent only, no innerHTML with server data) ----
            function el(tag, className, text) {
                const node = document.createElement(tag);
                if (className) node.className = className;
                if (text != null) node.textContent = text;
                return node;
            }
            function metaRow(iconPath, text) {
                const row = el('div', 'vsfs-meta-row');
                const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
                svg.setAttribute('class', 'lci');
                svg.setAttribute('viewBox', '0 0 24 24');
                svg.setAttribute('fill', 'none');
                svg.setAttribute('stroke', 'currentColor');
                svg.setAttribute('stroke-width', '2');
                svg.setAttribute('stroke-linecap', 'round');
                svg.setAttribute('stroke-linejoin', 'round');
                svg.setAttribute('aria-hidden', 'true');
                iconPath.split('|').forEach(d => {
                    const p = document.createElementNS('http://www.w3.org/2000/svg', 'path');
                    p.setAttribute('d', d);
                    svg.appendChild(p);
                });
                row.appendChild(svg);
                row.appendChild(el('span', null, text));
                return row;
            }
            const IC_PIN = 'M20 10c0 4.993-5.539 10.193-7.399 11.799a1 1 0 0 1-1.202 0C9.539 20.193 4 14.993 4 10a8 8 0 0 1 16 0|M15 10a3 3 0 1 1-6 0 3 3 0 0 1 6 0';
            const IC_CLOCK = 'M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20|M12 6v6l4 2';
            const IC_PHONE = 'M13.832 16.568a1 1 0 0 0 1.213-.303l.355-.465A2 2 0 0 1 17 15h3a2 2 0 0 1 2 2v3a2 2 0 0 1-2 2A18 18 0 0 1 2 4a2 2 0 0 1 2-2h3a2 2 0 0 1 2 2v3a2 2 0 0 1-.8 1.6l-.468.351a1 1 0 0 0-.292 1.233 14 14 0 0 0 6.392 6.384';
            const IC_INFO = 'M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20|M12 16v-4|M12 8h.01';

            function renderFacilityDetail(data) {
                // Hero image
                const hero = document.getElementById('fsHeroImg');
                const heroSrc = resolveImg(data.imageUrl) || fsCardImage;
                hero.onerror = fsCardImage ? function () { this.onerror = null; this.src = fsCardImage; } : null;
                hero.src = heroSrc || '';
                hero.alt = data.tenCoSo || '';

                // Identity
                document.getElementById('fsName').textContent = data.tenCoSo || '';

                const chips = document.getElementById('fsChips');
                chips.textContent = '';
                if (typeof data.openNow === 'boolean') {
                    chips.appendChild(el('span', 'vsfs-chip' + (data.openNow ? '' : ' is-warn'), data.openNow ? 'Đang mở' : 'Ngoài giờ mở cửa'));
                }
                if (typeof data.readyCourtCount === 'number' && data.readyCourtCount > 0) {
                    chips.appendChild(el('span', 'vsfs-chip', 'Còn ' + data.readyCourtCount + ' sân sẵn sàng'));
                }
                (Array.isArray(data.sports) ? data.sports : []).forEach(s => chips.appendChild(el('span', 'vsfs-chip', s)));
                if (Array.isArray(data.services) && data.services.length) {
                    chips.appendChild(el('span', 'vsfs-chip', 'Có dịch vụ'));
                }

                const meta = document.getElementById('fsMeta');
                meta.textContent = '';
                if (data.address) meta.appendChild(metaRow(IC_PIN, data.address));
                if (data.openingTime && data.closingTime) meta.appendChild(metaRow(IC_CLOCK, data.openingTime + ' - ' + data.closingTime));
                if (data.phone) meta.appendChild(metaRow(IC_PHONE, data.phone));

                const priceEl = document.getElementById('fsPrice');
                const minPrice = fmtVnd(data.minPrice);
                priceEl.hidden = !minPrice;
                if (minPrice) priceEl.textContent = 'Giá từ ' + minPrice + '/giờ';

                // Tab: Tổng quan
                const ov = document.getElementById('fsPanel-overview');
                ov.textContent = '';
                ov.appendChild(el('p', null, data.description || 'Thông tin này đang được cơ sở cập nhật.'));
                const ovMeta = el('div', 'vsfs-meta');
                ovMeta.style.marginTop = '12px';
                if (data.address) ovMeta.appendChild(metaRow(IC_PIN, data.address));
                if (data.openingTime && data.closingTime) ovMeta.appendChild(metaRow(IC_CLOCK, 'Giờ hoạt động: ' + data.openingTime + ' - ' + data.closingTime));
                if (data.phone) ovMeta.appendChild(metaRow(IC_PHONE, 'Liên hệ: ' + data.phone));
                if (Array.isArray(data.sports) && data.sports.length) ovMeta.appendChild(metaRow(IC_INFO, 'Môn thể thao: ' + data.sports.join(', ')));
                ov.appendChild(ovMeta);
                const mapLink = el('a', 'vsfs-court-cta', 'Xem trên bản đồ');
                mapLink.href = CTX + '/customer/ban-do';
                mapLink.style.marginTop = '14px';
                mapLink.style.display = 'inline-flex';
                ov.appendChild(mapLink);

                // Tab: Sân & bảng giá
                const courtsPanel = document.getElementById('fsPanel-courts');
                courtsPanel.textContent = '';
                const courts = Array.isArray(data.courts) ? data.courts : [];
                if (courts.length) {
                    courts.forEach(c => {
                        const row = el('div', 'vsfs-court');
                        const left = el('div');
                        left.style.minWidth = '0';
                        const nameLine = el('div', 'vsfs-court-name', c.tenSan || '');
                        if (c.trangThai) {
                            nameLine.appendChild(el('span',
                                'vsfs-status ' + (c.trangThai === 'Sẵn sàng' ? 'is-ready' : 'is-other'), c.trangThai));
                        }
                        left.appendChild(nameLine);
                        const subParts = [];
                        if (c.loaiSan) subParts.push(c.loaiSan);
                        if (c.monTheThao) subParts.push(c.monTheThao);
                        if (subParts.length) left.appendChild(el('div', 'vsfs-court-sub', subParts.join(' · ')));
                        row.appendChild(left);

                        const right = el('div');
                        right.style.display = 'flex';
                        right.style.alignItems = 'center';
                        right.style.gap = '12px';
                        const gia = fmtVnd(c.giaKhongDen);
                        const giaDen = fmtVnd(c.giaCoDen);
                        if (gia) {
                            right.appendChild(el('span', 'vsfs-court-price',
                                giaDen && giaDen !== gia ? gia + ' - ' + giaDen + '/giờ' : gia + '/giờ'));
                        }
                        const cta = el('a', 'vsfs-court-cta', 'Đặt sân');
                        cta.href = CTX + '/customer/chi-tiet-san?id=' + encodeURIComponent(c.sanId);
                        right.appendChild(cta);
                        row.appendChild(right);
                        courtsPanel.appendChild(row);
                    });
                } else {
                    courtsPanel.appendChild(el('p', null, 'Thông tin này đang được cơ sở cập nhật.'));
                }

                // Tab: Dịch vụ (ẩn tab khi không có dữ liệu)
                const services = Array.isArray(data.services) ? data.services : [];
                const svTab = document.getElementById('fsTab-services');
                const svPanel = document.getElementById('fsPanel-services');
                svPanel.textContent = '';
                svTab.hidden = !services.length;
                services.forEach(s => {
                    const row = el('div', 'vsfs-service');
                    row.appendChild(el('span', null, s.tenSanPham || ''));
                    const price = fmtVnd(s.donGia);
                    row.appendChild(el('b', null, price ? price + (s.donViTinh ? '/' + s.donViTinh : '') : (s.donViTinh || '')));
                    svPanel.appendChild(row);
                });

                // Tab: Hình ảnh (ẩn tab khi không có ảnh thật)
                const images = (Array.isArray(data.images) ? data.images : []).map(resolveImg).filter(Boolean);
                const imgTab = document.getElementById('fsTab-images');
                const imgPanel = document.getElementById('fsPanel-images');
                imgPanel.textContent = '';
                imgTab.hidden = !images.length;
                if (images.length) {
                    const grid = el('div', 'vsfs-imggrid');
                    images.forEach(src => {
                        const img = document.createElement('img');
                        img.loading = 'lazy';
                        img.alt = data.tenCoSo || '';
                        img.onerror = function () { this.remove(); };
                        img.src = src;
                        grid.appendChild(img);
                    });
                    imgPanel.appendChild(grid);
                }

                // Header/action-bar buttons
                const mapBtn = document.getElementById('fsMapBtn');
                const hasCoords = typeof data.latitude === 'number' && typeof data.longitude === 'number'
                    && (data.latitude !== 0 || data.longitude !== 0);
                mapBtn.hidden = !hasCoords;
                mapBtn.href = CTX + '/customer/ban-do';

                const callBtn = document.getElementById('fsCallBtn');
                callBtn.hidden = !data.phone;
                if (data.phone) callBtn.href = 'tel:' + String(data.phone).replace(/[^+\d]/g, '');

                selectSheetTab('overview');
                showSheetState('content');
            }

            // ---- Tabs -----------------------------------------------------------
            const tabButtons = Array.from(document.querySelectorAll('.vsfs-tab'));
            function selectSheetTab(key) {
                tabButtons.forEach(btn => {
                    const selected = btn.getAttribute('data-fstab') === key;
                    btn.setAttribute('aria-selected', selected ? 'true' : 'false');
                    document.getElementById('fsPanel-' + btn.getAttribute('data-fstab')).hidden = !selected;
                });
            }
            tabButtons.forEach((btn, idx) => {
                btn.addEventListener('click', () => selectSheetTab(btn.getAttribute('data-fstab')));
                btn.addEventListener('keydown', e => {
                    if (e.key !== 'ArrowRight' && e.key !== 'ArrowLeft') return;
                    e.preventDefault();
                    const visible = tabButtons.filter(b => !b.hidden);
                    const pos = visible.indexOf(btn);
                    const next = visible[(pos + (e.key === 'ArrowRight' ? 1 : visible.length - 1)) % visible.length];
                    next.focus();
                    selectSheetTab(next.getAttribute('data-fstab'));
                });
            });

            // ---- Sheet header buttons ------------------------------------------
            document.getElementById('fsCloseBtn').addEventListener('click', () => closeFacilitySheet(false));
            fsOverlay.addEventListener('click', () => closeFacilitySheet(false));
            fsSheet.addEventListener('keydown', e => trapTab(fsSheet, e));
            document.getElementById('fsFavBtn').addEventListener('click', function () {
                this.classList.toggle('is-fav');
                showHomeToast(this.classList.contains('is-fav') ? 'Đã thêm vào danh sách yêu thích' : 'Đã bỏ lưu cơ sở');
            });
            document.getElementById('fsShareBtn').addEventListener('click', function () {
                const url = window.location.origin + CTX + '/customer/dat-san?branchId=' + encodeURIComponent(fsCurrentId || '');
                if (navigator.clipboard) {
                    navigator.clipboard.writeText(url)
                        .then(() => showHomeToast('Đã sao chép liên kết chia sẻ cơ sở ' + fsCurrentName))
                        .catch(() => showHomeToast('Không thể sao chép liên kết'));
                } else {
                    showHomeToast('Trình duyệt không hỗ trợ sao chép liên kết');
                }
            });
            document.getElementById('fsBookBtn').addEventListener('click', function () {
                const cosoId = fsCurrentId;
                const name = fsCurrentName;
                const returnTo = fsReturnFocus;
                closeFacilitySheet(false);
                const wait = reduceMotion ? 0 : 240;
                setTimeout(() => openBookingChoice(cosoId, name, returnTo), wait);
            });

            // ---- Escape closes topmost layer -----------------------------------
            document.addEventListener('keydown', e => {
                if (e.key !== 'Escape') return;
                if (bcOpen) { closeBookingChoice(); return; }
                if (fsOpen) closeFacilitySheet(false);
            });

            // ---- Drag-down to close (mobile) -----------------------------------
            (function initDrag() {
                const handle = document.getElementById('fsHandle');
                let startY = null, delta = 0, dragging = false;
                function onStart(e) {
                    dragging = true;
                    startY = (e.touches ? e.touches[0] : e).clientY;
                    delta = 0;
                    fsSheet.style.transition = 'none';
                }
                function onMove(e) {
                    if (!dragging || startY == null) return;
                    const y = (e.touches ? e.touches[0] : e).clientY;
                    delta = Math.max(0, y - startY);
                    fsSheet.style.transform = 'translateY(' + delta + 'px)';
                }
                function onEnd() {
                    if (!dragging) return;
                    dragging = false;
                    fsSheet.style.transition = '';
                    if (delta > 110) {
                        closeFacilitySheet(false);
                    } else {
                        fsSheet.style.transform = '';
                    }
                    startY = null;
                }
                handle.addEventListener('touchstart', onStart, { passive: true });
                handle.addEventListener('touchmove', onMove, { passive: true });
                handle.addEventListener('touchend', onEnd);
                handle.addEventListener('mousedown', e => { onStart(e); e.preventDefault(); });
                document.addEventListener('mousemove', onMove);
                document.addEventListener('mouseup', onEnd);
            })();

            // ---- Wire up cards (delegation; no per-card modal instances) --------
            const grid = document.getElementById('facilityGrid');
            if (grid) {
                grid.addEventListener('click', e => {
                    const bookBtn = e.target.closest('[data-book-trigger]');
                    if (bookBtn) {
                        e.stopPropagation();
                        openBookingChoice(bookBtn.getAttribute('data-coso-id'), bookBtn.getAttribute('data-facility-name'), bookBtn);
                        return;
                    }
                    if (e.target.closest('button, a')) return; // favorite/share/other controls
                    const card = e.target.closest('.facility-card');
                    if (card) openFacilitySheet(card);
                });
                grid.addEventListener('keydown', e => {
                    if (e.key !== 'Enter' && e.key !== ' ') return;
                    const card = e.target.closest('.facility-card');
                    if (card && e.target === card) {
                        e.preventDefault();
                        openFacilitySheet(card);
                    }
                });
            }
        })();
    </script>
</body>
</html>
