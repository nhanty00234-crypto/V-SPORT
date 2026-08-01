<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Đặt lịch - V-SPORT</title>
    <jsp:include page="/common/xtra-head.jsp" />
    <style>
        [hidden] { display: none !important; }
        :root {
            --ttv-header-bg: #0d3d24;
            --ttv-slot-w: 64px;
            --ttv-row-h: 52px;
            --ttv-head-h: 32px;
            --ttv-court-col: 0px;
        }
        @media (max-width: 767px) {
            :root { --ttv-slot-w: 56px; --ttv-row-h: 48px; }
        }

        html, body {
            background: #f4f6f8;
            color: var(--navy);
            font-family: 'Poppins', sans-serif;
            margin: 0;
            padding: 0;
            height: 100dvh;
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }

        /* ── Header ── */
        .ttv-header {
            background: var(--ttv-header-bg);
            color: #fff;
            flex-shrink: 0;
        }
        .ttv-header-top {
            display: grid;
            grid-template-columns: 1fr auto 1fr;
            align-items: center;
            gap: 8px;
            padding: 14px 14px 10px;
        }
        @media (min-width: 1024px) { .ttv-header-top { padding: 14px 24px 10px; } }
        .ttv-back {
            justify-self: start;
            width: 34px; height: 34px;
            display: inline-flex; align-items: center; justify-content: center;
            border-radius: 8px; background: transparent; color: #fff;
            border: none; cursor: pointer;
            transition: background 100ms;
        }
        .ttv-back:hover { background: rgba(255,255,255,.12); }
        .ttv-title {
            font-size: 15px; font-weight: 700; margin: 0;
            text-align: center; color: #fff; line-height: 1.25;
            white-space: nowrap;
        }
        .ttv-title small {
            display: block; font-size: 11px; font-weight: 500;
            color: rgba(255,255,255,.6); margin-top: 1px;
        }
        .ttv-date-group {
            justify-self: end;
            display: inline-flex; align-items: center; gap: 4px;
        }
        .ttv-icon-btn {
            display: inline-flex; align-items: center; justify-content: center;
            width: 30px; height: 30px;
            background: rgba(255,255,255,.1); border: none; border-radius: 7px;
            color: #fff; cursor: pointer; transition: background 100ms;
        }
        .ttv-icon-btn:hover { background: rgba(255,255,255,.2); }
        .ttv-icon-btn:disabled { opacity: .3; cursor: not-allowed; }
        .ttv-date-input {
            padding: 4px 8px; height: 30px;
            background: #fff; border: none; border-radius: 7px;
            font-size: 13px; font-weight: 600; color: var(--navy);
            font-family: 'Poppins', sans-serif;
        }
        .ttv-date-input:focus { outline: none; box-shadow: 0 0 0 3px rgba(1,226,129,.4); }

        /* ── Step indicator strip ── */
        .ttv-steps {
            display: flex; align-items: center;
            padding: 0 14px 12px; gap: 6px;
        }
        @media (min-width: 1024px) { .ttv-steps { padding: 0 24px 12px; } }
        .ttv-step-dot {
            width: 7px; height: 7px; border-radius: 50%;
            background: rgba(255,255,255,.3); transition: background 200ms, width 200ms;
        }
        .ttv-step-dot.is-active { background: var(--primary); width: 20px; border-radius: 4px; }
        .ttv-step-dot.is-done   { background: rgba(255,255,255,.6); }
        .ttv-step-label {
            font-size: 11px; font-weight: 600; color: rgba(255,255,255,.55);
            margin-left: 4px;
        }
        .ttv-step-label.is-active { color: rgba(255,255,255,.9); }

        /* ── Court sub-header (step 2 only) ── */
        .ttv-court-bar {
            display: none;
            align-items: center; gap: 10px;
            padding: 8px 14px 12px;
            border-top: 1px solid rgba(255,255,255,.08);
        }
        .ttv-court-bar.is-visible { display: flex; }
        @media (min-width: 1024px) { .ttv-court-bar { padding: 8px 24px 12px; } }
        .ttv-court-bar-name {
            flex: 1; font-size: 13px; font-weight: 700; color: #fff;
            white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
        }
        .ttv-court-bar-price {
            font-size: 12px; font-weight: 600; color: var(--primary);
            white-space: nowrap;
        }
        .ttv-change-court-btn {
            display: inline-flex; align-items: center; gap: 4px;
            padding: 4px 10px; height: 28px;
            background: rgba(255,255,255,.12); border: 1px solid rgba(255,255,255,.2);
            border-radius: 20px; color: #fff; font-size: 11.5px; font-weight: 700;
            cursor: pointer; font-family: inherit; white-space: nowrap;
            transition: background 100ms;
        }
        .ttv-change-court-btn:hover { background: rgba(255,255,255,.2); }

        /* ── Body scroll area ── */
        .ttv-body {
            flex: 1 1 auto;
            min-height: 0;
            overflow: hidden;
            position: relative;
        }

        /* ── STEP 1: Court cards ── */
        .ttv-step1 {
            position: absolute; inset: 0;
            overflow-y: auto;
            padding: 16px 14px;
            display: flex; flex-direction: column; gap: 10px;
            transition: transform 280ms cubic-bezier(.4,0,.2,1), opacity 280ms;
        }
        @media (min-width: 1024px) { .ttv-step1 { padding: 20px 24px; align-items: center; } }
        .ttv-step1.is-hidden {
            transform: translateX(-100%);
            opacity: 0;
            pointer-events: none;
        }

        .court-card {
            background: #fff;
            border-radius: 14px;
            border: 1.5px solid #e8ecf0;
            padding: 14px 16px;
            cursor: pointer;
            display: flex; align-items: center; gap: 14px;
            transition: border-color 150ms, box-shadow 150ms, transform 120ms;
            width: 100%;
            max-width: 600px;
            box-sizing: border-box;
        }
        .court-card:hover {
            border-color: var(--primary);
            box-shadow: 0 4px 16px rgba(1,226,129,.15);
            transform: translateY(-1px);
        }
        .court-card:active { transform: translateY(0) scale(0.99); }
        .court-card-icon {
            width: 44px; height: 44px; border-radius: 10px;
            background: #f0faf5;
            display: flex; align-items: center; justify-content: center;
            font-size: 22px; flex-shrink: 0;
        }
        .court-card-info { flex: 1; min-width: 0; }
        .court-card-name {
            font-size: 14px; font-weight: 700; color: var(--navy);
            white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
            margin-bottom: 4px;
        }
        .court-card-meta {
            display: flex; align-items: center; gap: 6px; flex-wrap: wrap;
        }
        .court-card-badge {
            display: inline-flex; align-items: center;
            padding: 2px 8px; border-radius: 20px;
            font-size: 10.5px; font-weight: 700;
            background: #edf7f2; color: #0d6e3f;
        }
        .court-card-price {
            font-size: 11px; font-weight: 600; color: #6b7280;
        }
        .court-card-avail {
            margin-left: auto; flex-shrink: 0;
            display: flex; align-items: center; gap: 5px;
            font-size: 11.5px; font-weight: 700;
        }
        .court-card-avail.has-slots { color: #16a34a; }
        .court-card-avail.no-slots  { color: #9ca3af; }
        .avail-dot {
            width: 7px; height: 7px; border-radius: 50%;
        }
        .has-slots .avail-dot { background: #22c55e; }
        .no-slots  .avail-dot { background: #d1d5db; }
        .court-card-arrow {
            color: #d1d5db; flex-shrink: 0;
        }
        .court-card:hover .court-card-arrow { color: var(--primary); }

        /* ── STEP 2: Timeline ── */
        .ttv-step2 {
            position: absolute; inset: 0;
            display: flex; flex-direction: column;
            transform: translateX(100%);
            opacity: 0;
            pointer-events: none;
            transition: transform 280ms cubic-bezier(.4,0,.2,1), opacity 280ms;
        }
        .ttv-step2.is-visible {
            transform: translateX(0);
            opacity: 1;
            pointer-events: auto;
        }

        /* Legend strip */
        .ttv-legend {
            display: flex; align-items: center; gap: 12px;
            padding: 7px 14px;
            background: #fff;
            border-bottom: 1px solid #e8ecf0;
            overflow-x: auto; scrollbar-width: none;
            flex-shrink: 0;
        }
        .ttv-legend::-webkit-scrollbar { display: none; }
        @media (min-width: 1024px) { .ttv-legend { padding: 7px 24px; } }
        .ttv-legend-item {
            display: inline-flex; align-items: center; gap: 5px;
            font-size: 11px; font-weight: 600; color: #6b7280;
            white-space: nowrap; flex-shrink: 0;
        }
        .ttv-legend-swatch {
            width: 12px; height: 12px; border-radius: 3px;
        }
        .ttv-legend-swatch.avail  { background: #fff; border: 1.5px solid #d1d5db; }
        .ttv-legend-swatch.select { background: rgba(1,226,129,.4); border: 1.5px solid var(--primary); }
        .ttv-legend-swatch.booked { background: #e5e7eb; }
        .ttv-legend-swatch.hold   { background: #fcd34d; }
        .ttv-legend-swatch.locked { background: #f3f4f6; border: 1.5px solid #e5e7eb; }

        /* Note */
        .ttv-note {
            padding: 5px 14px;
            background: #fffbeb;
            border-bottom: 1px solid #fde68a;
            font-size: 11px; font-weight: 600; color: #92400e;
            text-align: center;
            flex-shrink: 0;
        }

        /* Timeline scroll area */
        .ttv-tl-scroll {
            flex: 1 1 auto; min-height: 0;
            overflow: auto;
            -webkit-overflow-scrolling: touch;
            overscroll-behavior: contain;
            scrollbar-width: thin;
            background: #fff;
        }
        .ttv-tl-scroll::-webkit-scrollbar { display: block; width: 6px; height: 6px; }
        .ttv-tl-scroll::-webkit-scrollbar-thumb { background: #d1d5db; border-radius: 3px; }

        /* Timeline grid — single court row */
        .ttv-tl {
            display: flex;
            flex-direction: column;
            min-width: max-content;
            font-size: 12px;
            user-select: none;
        }
        /* Header row */
        .ttv-tl-head {
            display: flex;
            position: sticky; top: 0; z-index: 5;
            background: #f9fafb;
            border-bottom: 1px solid #e8ecf0;
        }
        .ttv-tl-head-cell {
            width: var(--ttv-slot-w);
            height: var(--ttv-head-h);
            flex-shrink: 0;
            display: flex; align-items: center; justify-content: center;
            font-size: 10.5px; font-weight: 700; color: #6b7280;
            border-right: 1px solid #f0f2f4;
            position: relative;
        }
        .ttv-tl-head-cell.is-hour { border-right-color: #d1d5db; }

        /* Slots row */
        .ttv-tl-row {
            display: flex;
            align-items: stretch;
        }
        .ttv-slot {
            width: var(--ttv-slot-w);
            height: var(--ttv-row-h);
            flex-shrink: 0;
            display: flex; align-items: center; justify-content: center;
            cursor: pointer;
            border-right: 1px solid #f0f2f4;
            border-bottom: 1px solid #f0f2f4;
            background: #fff;
            position: relative;
            transition: background 80ms;
        }
        .ttv-slot.is-hour { border-right-color: #e2e8f0; }
        .ttv-slot:hover:not(.is-blocked):not(.is-selected) { background: #f0faf5; }
        .ttv-slot:active:not(.is-blocked) { transform: scale(0.97); }
        .ttv-slot:focus-visible { outline: 3px solid rgba(1,226,129,.4); outline-offset: -2px; z-index: 2; }

        /* States */
        .ttv-slot.is-selected {
            background: rgba(1,226,129,.25);
            border-color: var(--primary);
            box-shadow: inset 0 0 0 1.5px var(--primary);
        }
        .ttv-slot.is-selected.sel-start { border-radius: 8px 0 0 8px; }
        .ttv-slot.is-selected.sel-end   { border-radius: 0 8px 8px 0; }
        .ttv-slot.is-selected.sel-start.sel-end { border-radius: 8px; }
        .ttv-slot.is-selected:not(.sel-end) { border-right: 1px dashed rgba(1,226,129,.5); }
        .ttv-slot.is-hover { background: rgba(1,226,129,.1); }

        .ttv-slot.is-blocked { cursor: not-allowed; }
        .ttv-slot.is-past    { background: #f9fafb; }
        .ttv-slot.is-booked  { background: #f3f4f6; }
        .ttv-slot.is-hold    { background: #fef9c3; }
        .ttv-slot.is-hold_self { background: rgba(1,226,129,.08); box-shadow: inset 0 0 0 1.5px var(--primary); cursor: pointer; }
        .ttv-slot.is-locked  { background: #f9fafb; }

        /* Merged blocked run */
        .ttv-slot.is-merged { padding: 0 6px; }
        .ttv-slot-label {
            font-size: 10px; font-weight: 700; color: #9ca3af;
            white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 100%;
            text-align: center;
        }
        .ttv-slot.is-booked .ttv-slot-label  { color: #9ca3af; }
        .ttv-slot.is-hold .ttv-slot-label    { color: #92400e; }
        .ttv-slot.is-locked .ttv-slot-label  { color: #9ca3af; }

        /* Selection range label */
        .ttv-sel-label {
            position: absolute; left: 0; top: 0; bottom: 0; z-index: 2;
            display: flex; align-items: center; justify-content: center;
            font-size: 11px; font-weight: 800; color: #065f46;
            white-space: nowrap; pointer-events: none;
        }

        /* Now marker */
        .ttv-now-marker { position: absolute; top: 0; bottom: 0; width: 2px; background: var(--primary); pointer-events: none; z-index: 3; }
        .ttv-now-chip {
            position: absolute; top: 2px; left: 50%; transform: translateX(-50%);
            background: var(--primary); color: #fff;
            font-size: 9px; font-weight: 800; padding: 0 5px; border-radius: 999px;
            pointer-events: none; z-index: 7; white-space: nowrap;
        }

        /* ── Footer ── */
        .ttv-footer {
            background: var(--ttv-header-bg);
            color: #fff;
            padding: 10px 14px calc(10px + env(safe-area-inset-bottom, 0px));
            box-shadow: 0 -6px 20px rgba(0,0,0,.2);
            flex-shrink: 0;
        }
        @media (min-width: 1024px) { .ttv-footer { padding: 10px 24px calc(10px + env(safe-area-inset-bottom, 0px)); } }
        .ttv-footer-row {
            display: flex; align-items: baseline;
            justify-content: space-between; gap: 12px;
            padding-bottom: 8px;
        }
        .ttv-stat { display: inline-flex; align-items: baseline; gap: 6px; }
        .ttv-stat span { font-size: 10px; color: rgba(255,255,255,.55); font-weight: 700; text-transform: uppercase; letter-spacing: .06em; }
        .ttv-stat strong { font-size: 15px; font-weight: 800; color: #fff; }
        .ttv-stat.total strong { font-size: 18px; color: var(--primary); }
        .ttv-footer-sel {
            flex: 1; text-align: center; font-size: 11px; color: rgba(255,255,255,.5);
            font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
        }
        @media (max-width: 639px) { .ttv-footer-sel { display: none; } }
        .ttv-cta {
            width: 100%; min-height: 50px; border: none; border-radius: 10px;
            background: var(--primary); color: #fff;
            font-size: 15px; font-weight: 900; letter-spacing: .04em;
            text-transform: uppercase; font-family: inherit; cursor: pointer;
            display: flex; align-items: center; justify-content: center; gap: 8px;
            transition: background 100ms, transform 90ms;
        }
        .ttv-cta:hover:not(:disabled) { background: var(--primary-hover, #00cc6a); }
        .ttv-cta:active:not(:disabled) { transform: translateY(1px) scale(0.99); }
        .ttv-cta:disabled { background: #3d5a4a; color: rgba(255,255,255,.45); cursor: not-allowed; }
        .ttv-cta-spinner {
            width: 17px; height: 17px; border-radius: 50%;
            border: 2.5px solid rgba(255,255,255,.3); border-top-color: #fff;
            animation: ttvSpin .8s linear infinite;
        }
        @keyframes ttvSpin { to { transform: rotate(360deg); } }

        /* ── Skeletons / Error / Empty ── */
        @keyframes ttvShim { 0% { background-position: 100% 50%; } 100% { background-position: 0 50%; } }
        .ttv-skel {
            background: linear-gradient(90deg,#eceef0 25%,#dfe6ec 37%,#eceef0 63%);
            background-size: 400% 100%; animation: ttvShim 1.4s ease infinite; border-radius: 10px;
        }
        .ttv-skeleton-cards { display: flex; flex-direction: column; gap: 10px; padding: 16px 14px; }
        @media (min-width: 1024px) { .ttv-skeleton-cards { padding: 20px 24px; align-items: center; } }
        .ttv-skel-card { height: 70px; border-radius: 14px; max-width: 600px; width: 100%; }

        .ttv-error-box, .ttv-empty-box {
            padding: 48px 24px; text-align: center;
            display: flex; flex-direction: column; align-items: center; gap: 12px;
        }
        .ttv-error-box p, .ttv-empty-box p { color: #6b7280; font-size: 13px; font-weight: 600; margin: 0; }
        .ttv-btn-ghost {
            display: inline-flex; align-items: center; gap: 6px;
            padding: 8px 16px; border: 1.5px solid #d1d5db; border-radius: 8px;
            color: var(--navy); font-size: 12.5px; font-weight: 700; cursor: pointer;
            background: #fff; font-family: inherit; text-decoration: none;
            transition: border-color 100ms, color 100ms;
        }
        .ttv-btn-ghost:hover { border-color: var(--primary); color: var(--primary); }

        /* ── Toast ── */
        .ttv-toast {
            position: fixed; left: 50%; bottom: 90px; transform: translateX(-50%);
            background: #1e293b; color: #fff;
            padding: 10px 18px; border-radius: 999px;
            font-size: 13px; font-weight: 700;
            box-shadow: 0 8px 24px rgba(0,0,0,.25);
            opacity: 0; visibility: hidden; transition: opacity .18s;
            z-index: 60; max-width: 92vw; text-align: center; white-space: nowrap;
        }
        .ttv-toast.open    { opacity: 1; visibility: visible; }
        .ttv-toast.danger  { background: var(--danger, #ef4444); }
        .ttv-toast.warn    { background: #f59e0b; color: #1f2937; }

        /* ── Full-screen loading ── */
        .ttv-step-loading {
            position: fixed; inset: 0; z-index: 2000;
            background: #000; color: #fff;
            display: flex; flex-direction: column;
            align-items: center; justify-content: center; gap: 18px;
        }
        .ttv-step-loading-brand { font-size: 26px; font-weight: 900; letter-spacing: .14em; }
        .ttv-step-loading-brand span { color: var(--primary); }
        .ttv-step-loading-ring {
            width: 44px; height: 44px; border-radius: 50%;
            border: 4px solid rgba(255,255,255,.15); border-top-color: var(--primary);
            animation: ttvSpin .9s linear infinite;
        }
        .ttv-step-loading p { font-size: 13px; font-weight: 600; color: #94a3b8; margin: 0; }

        /* ── Empty facility ── */
        .ttv-empty-facility { padding: 60px 24px; text-align: center; }
        .ttv-empty-facility h2 { font-size: 18px; font-weight: 800; margin-bottom: 8px; }
        .ttv-empty-facility p { color: #6b7280; margin-bottom: 16px; font-size: 13px; }

        @media (prefers-reduced-motion: reduce) {
            .ttv-skel, .ttv-step-loading-ring, .ttv-cta-spinner { animation: none; }
            .ttv-step1, .ttv-step2 { transition: none; }
        }
    </style>
</head>
<body>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<%-- ── Header ── --%>
<div class="ttv-header">
    <div class="ttv-header-top">
        <button type="button" class="ttv-back" aria-label="Quay lại" onclick="ttvGoBack()">
            <svg width="19" height="19" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.3" stroke-linecap="round" stroke-linejoin="round"><path d="m15 18-6-6 6-6"/></svg>
        </button>
        <h1 class="ttv-title">
            Đặt lịch
            <c:if test="${not empty coSo}"><small>${fn:escapeXml(coSo.tenCoSo)}</small></c:if>
        </h1>
        <div class="ttv-date-group">
            <c:if test="${not empty coSo}">
                <button type="button" class="ttv-icon-btn" id="ttvPrevDayBtn" aria-label="Ngày trước" onclick="ttvChangeDate(-1)">
                    <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.3" stroke-linecap="round" stroke-linejoin="round"><path d="m15 18-6-6 6-6"/></svg>
                </button>
                <input type="date" id="ttvDateInput" class="ttv-date-input" onchange="ttvOnDateChange()" aria-label="Chọn ngày" />
                <button type="button" class="ttv-icon-btn" aria-label="Ngày sau" onclick="ttvChangeDate(1)">
                    <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.3" stroke-linecap="round" stroke-linejoin="round"><path d="m9 18 6-6-6-6"/></svg>
                </button>
            </c:if>
        </div>
    </div>

    <%-- Step dots --%>
    <div class="ttv-steps" id="ttvStepDots">
        <div class="ttv-step-dot is-active" id="ttvDot1"></div>
        <div class="ttv-step-dot" id="ttvDot2"></div>
        <span class="ttv-step-label is-active" id="ttvStepLabel">Chọn sân</span>
    </div>

    <%-- Court sub-bar (step 2) --%>
    <div class="ttv-court-bar" id="ttvCourtBar">
        <div class="ttv-court-bar-name" id="ttvCourtBarName">—</div>
        <div class="ttv-court-bar-price" id="ttvCourtBarPrice"></div>
        <button type="button" class="ttv-change-court-btn" onclick="ttvGoToStep1()">
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.3" stroke-linecap="round" stroke-linejoin="round"><path d="m15 18-6-6 6-6"/></svg>
            Đổi sân
        </button>
    </div>
</div>

<c:if test="${emptyState eq 'no_facility'}">
    <div class="ttv-empty-facility">
        <h2>Chưa có cơ sở khả dụng</h2>
        <p>Vui lòng quay lại sau hoặc liên hệ tổng đài.</p>
        <a href="${ctx}/index.jsp" class="ttv-btn-ghost">Về trang chủ</a>
    </div>
</c:if>

<c:if test="${not empty coSo}">

<%-- ── Body ── --%>
<div class="ttv-body" id="ttvBody">

    <%-- STEP 1: Court cards --%>
    <div class="ttv-step1" id="ttvStep1" role="list" aria-label="Danh sách sân">
        <div id="ttvCardLoading" class="ttv-skeleton-cards">
            <div class="ttv-skel ttv-skel-card"></div>
            <div class="ttv-skel ttv-skel-card"></div>
            <div class="ttv-skel ttv-skel-card"></div>
            <div class="ttv-skel ttv-skel-card"></div>
        </div>
        <div id="ttvCardError" class="ttv-error-box" hidden>
            <p>Không tải được danh sách sân. Vui lòng thử lại.</p>
            <button type="button" class="ttv-btn-ghost" onclick="ttvReload()">Thử lại</button>
        </div>
        <div id="ttvCardEmpty" class="ttv-empty-box" hidden>
            <p>Không có sân khả dụng trong ngày đã chọn.</p>
        </div>
        <div id="ttvCardList"></div>
    </div>

    <%-- STEP 2: Timeline --%>
    <div class="ttv-step2" id="ttvStep2" aria-label="Chọn khung giờ">
        <div class="ttv-legend">
            <span class="ttv-legend-item"><span class="ttv-legend-swatch avail"></span>Trống</span>
            <span class="ttv-legend-item"><span class="ttv-legend-swatch select"></span>Đang chọn</span>
            <span class="ttv-legend-item"><span class="ttv-legend-swatch booked"></span>Đã đặt</span>
            <span class="ttv-legend-item"><span class="ttv-legend-swatch hold"></span>Giữ chỗ</span>
            <span class="ttv-legend-item"><span class="ttv-legend-swatch locked"></span>Không khả dụng</span>
        </div>
        <div class="ttv-note">Chọn các khung giờ <b>liền nhau</b>. Bấm ô đầu rồi kéo/bấm ô cuối.</div>
        <div class="ttv-tl-scroll" id="ttvTlScroll">
            <div id="ttvTlLoading" class="ttv-skeleton-cards"><div class="ttv-skel" style="height:32px; margin-bottom:4px;"></div><div class="ttv-skel" style="height:52px;"></div></div>
            <div id="ttvTlError" class="ttv-error-box" hidden>
                <p>Không tải được lịch sân.</p>
                <button class="ttv-btn-ghost" onclick="ttvReload()">Thử lại</button>
            </div>
            <div id="ttvTlEmpty" class="ttv-empty-box" hidden><p>Không có khung giờ trống.</p></div>
            <div class="ttv-tl" id="ttvTl" hidden></div>
        </div>
    </div>

</div>

<%-- ── Footer ── --%>
<form id="ttvBookingForm" action="${ctx}/customer/dat-lich-truc-quan/xac-nhan" method="get" class="ttv-footer" novalidate>
    <input type="hidden" name="coSoId" value="${coSo.coSoID}" />
    <input type="hidden" name="sanId"       id="ttvInputSanId" />
    <input type="hidden" name="ngayDat"     id="ttvInputNgayDat" />
    <input type="hidden" name="gioBatDau"   id="ttvInputGioBatDau" />
    <input type="hidden" name="gioKetThuc"  id="ttvInputGioKetThuc" />

    <div class="ttv-footer-row">
        <div class="ttv-stat">
            <span>Tổng giờ</span>
            <strong id="ttvDuration">0h00</strong>
        </div>
        <div class="ttv-footer-sel" id="ttvFooterSel">Chưa chọn</div>
        <div class="ttv-stat total">
            <span>Tổng tiền</span>
            <strong id="ttvTotal">0 đ</strong>
        </div>
    </div>
    <button type="submit" class="ttv-cta" id="ttvNextBtn" disabled>
        <span id="ttvNextLabel">Chọn sân để bắt đầu</span>
    </button>
</form>

<%-- Toast --%>
<div class="ttv-toast" id="ttvToast" role="alert" aria-live="assertive"></div>

<%-- Full-screen loading --%>
<div class="ttv-step-loading" id="ttvStepLoading" hidden role="status">
    <div class="ttv-step-loading-brand">V-<span>SPORT</span></div>
    <div class="ttv-step-loading-ring"></div>
    <p id="ttvStepLoadingText">Đang chuẩn bị…</p>
</div>

<c:if test="${not empty sessionScope.error}">
    <script>window.addEventListener('DOMContentLoaded',function(){ ttvToast('${fn:escapeXml(sessionScope.error)}','danger'); });</script>
    <% session.removeAttribute("error"); %>
</c:if>
<c:if test="${not empty sessionScope.message}">
    <script>window.addEventListener('DOMContentLoaded',function(){ ttvToast('${fn:escapeXml(sessionScope.message)}',''); });</script>
    <% session.removeAttribute("message"); %>
</c:if>

<script id="ttvServerData" type="application/json">
{
  "contextPath": "${ctx}",
  "coSoId": ${coSo.coSoID},
  "initialDate": "${initialDate}",
  "openTime": "${openTime}",
  "closeTime": "${closeTime}",
  "slotMinutes": ${slotMinutes},
  "minDurationMinutes": ${minDurationMinutes},
  "maxDurationMinutes": ${maxDurationMinutes},
  "maxDaysAhead": ${maxDaysAhead},
  "preSanId": <c:choose><c:when test="${not empty preSanId}">${preSanId}</c:when><c:otherwise>null</c:otherwise></c:choose>,
  "isLoggedIn": <c:choose><c:when test="${not empty sessionScope.user}">true</c:when><c:otherwise>false</c:otherwise></c:choose>
}
</script>
<script>
(function () {
    var sd       = JSON.parse(document.getElementById('ttvServerData').textContent);
    var CTX      = sd.contextPath;
    var COSO_ID  = sd.coSoId;
    var SLOT_MIN = sd.slotMinutes || 30;
    var MIN_DUR  = sd.minDurationMinutes || 30;
    var MAX_DUR  = sd.maxDurationMinutes || 240;
    var MAX_AHEAD = sd.maxDaysAhead || 30;

    var state = {
        date: sd.initialDate,
        openMin: 0, closeMin: 0,
        courts: [],
        nowMinutes: -1,
        currentStep: 1,
        activeSanId: sd.preSanId || null,
        selectedSanId: null,
        selectedStart: null,
        selectedEnd: null,
        priceResult: null,
        abortCtrl: null,
        pendingSubmit: false
    };

    /* ── Helpers ── */
    function hhmmToMin(s) { var p = s.split(':'); return (+p[0]) * 60 + (+p[1]); }
    function minToHhmm(m) { return String(Math.floor(m/60)).padStart(2,'0') + ':' + String(m%60).padStart(2,'0'); }
    function fmtVnd(n) {
        if (!n || isNaN(n) || n <= 0) return '0 đ';
        return new Intl.NumberFormat('vi-VN').format(Math.round(n)) + ' đ';
    }
    function todayStr() {
        var d = new Date();
        return d.getFullYear() + '-' + String(d.getMonth()+1).padStart(2,'0') + '-' + String(d.getDate()).padStart(2,'0');
    }
    function fmtDur(mins) { return Math.floor(mins/60) + 'h' + String(mins%60).padStart(2,'0'); }

    function courtIcon(tenLoai) {
        if (!tenLoai) return '🏟️';
        var t = tenLoai.toLowerCase();
        if (t.includes('cầu lông') || t.includes('cau long')) return '🏸';
        if (t.includes('bóng đá') || t.includes('bong da') || t.includes('cỏ') || t.includes('co')) return '⚽';
        if (t.includes('tennis') || t.includes('quần vợt')) return '🎾';
        if (t.includes('bóng rổ') || t.includes('bong ro')) return '🏀';
        if (t.includes('bơi') || t.includes('boi')) return '🏊';
        if (t.includes('bóng chuyền') || t.includes('bong chuyen')) return '🏐';
        return '🏟️';
    }

    /* ── Step loading overlay ── */
    var _slTimer = null, _slSafe = null;
    function showStepLoading(txt) {
        clearTimeout(_slTimer);
        _slTimer = setTimeout(function() {
            document.getElementById('ttvStepLoadingText').textContent = txt;
            document.getElementById('ttvStepLoading').hidden = false;
        }, 150);
        clearTimeout(_slSafe);
        _slSafe = setTimeout(function() {
            hideStepLoading();
            state.pendingSubmit = false;
            updateSummary();
            ttvToast('Máy chủ phản hồi chậm. Vui lòng thử lại.', 'warn');
        }, 20000);
    }
    function hideStepLoading() {
        clearTimeout(_slTimer); clearTimeout(_slSafe);
        document.getElementById('ttvStepLoading').hidden = true;
    }
    window.addEventListener('pageshow', function() {
        hideStepLoading(); state.pendingSubmit = false; updateSummary();
    });

    /* ── Date controls ── */
    var dateInput = document.getElementById('ttvDateInput');
    dateInput.value = state.date;
    dateInput.min = todayStr();
    var maxD = new Date(); maxD.setDate(maxD.getDate() + MAX_AHEAD);
    dateInput.max = maxD.getFullYear() + '-' + String(maxD.getMonth()+1).padStart(2,'0') + '-' + String(maxD.getDate()).padStart(2,'0');
    updatePrevBtn();

    window.ttvOnDateChange = function() {
        var v = dateInput.value;
        if (!v) return;
        if (v < todayStr()) { ttvToast('Không thể đặt ngày đã qua.','warn'); dateInput.value = state.date; return; }
        if (v > dateInput.max) { ttvToast('Chỉ đặt được trong ' + MAX_AHEAD + ' ngày tới.','warn'); dateInput.value = state.date; return; }
        state.date = v;
        clearSelection(); updatePrevBtn();
        loadAvailability();
    };
    window.ttvChangeDate = function(d) {
        var nd = new Date(state.date + 'T00:00:00');
        nd.setDate(nd.getDate() + d);
        var s = nd.getFullYear() + '-' + String(nd.getMonth()+1).padStart(2,'0') + '-' + String(nd.getDate()).padStart(2,'0');
        if (s < todayStr() || s > dateInput.max) return;
        state.date = s; dateInput.value = s;
        clearSelection(); updatePrevBtn(); loadAvailability();
    };
    window.ttvGoBack = function() {
        if (state.currentStep === 2) { ttvGoToStep1(); return; }
        if (history.length > 1) history.back();
        else window.location.href = CTX + '/customer/dat-san';
    };
    window.ttvReload = function() { loadAvailability(); };
    function updatePrevBtn() {
        document.getElementById('ttvPrevDayBtn').disabled = (state.date === todayStr());
    }

    /* ── Step navigation ── */
    window.ttvGoToStep1 = function() {
        state.currentStep = 1;
        document.getElementById('ttvStep1').classList.remove('is-hidden');
        document.getElementById('ttvStep2').classList.remove('is-visible');
        document.getElementById('ttvCourtBar').classList.remove('is-visible');
        document.getElementById('ttvDot1').className = 'ttv-step-dot is-active';
        document.getElementById('ttvDot2').className = 'ttv-step-dot';
        document.getElementById('ttvStepLabel').textContent = 'Chọn sân';
        document.getElementById('ttvStepLabel').className = 'ttv-step-label is-active';
        clearSelection();
        updateSummary();
    };

    function ttvGoToStep2(court) {
        state.currentStep = 2;
        state.activeSanId = court.sanId;
        document.getElementById('ttvStep1').classList.add('is-hidden');
        document.getElementById('ttvStep2').classList.add('is-visible');
        document.getElementById('ttvDot1').className = 'ttv-step-dot is-done';
        document.getElementById('ttvDot2').className = 'ttv-step-dot is-active';
        document.getElementById('ttvStepLabel').textContent = 'Chọn giờ';
        document.getElementById('ttvStepLabel').className = 'ttv-step-label is-active';
        document.getElementById('ttvCourtBar').classList.add('is-visible');
        document.getElementById('ttvCourtBarName').textContent = court.tenSan || ('Sân #' + court.sanId);
        document.getElementById('ttvCourtBarPrice').textContent = court.giaKhongDen ? fmtVnd(court.giaKhongDen) + '/giờ' : '';
        renderTimeline(court);
        updateSummary();
    }

    /* ── Load availability ── */
    function loadAvailability(silent) {
        if (state.abortCtrl) state.abortCtrl.abort();
        state.abortCtrl = new AbortController();
        if (!silent) {
            document.getElementById('ttvCardLoading').hidden = false;
            document.getElementById('ttvCardError').hidden = true;
            document.getElementById('ttvCardEmpty').hidden = true;
            document.getElementById('ttvCardList').innerHTML = '';
            if (state.currentStep === 2) {
                document.getElementById('ttvTlLoading').hidden = false;
                document.getElementById('ttvTl').hidden = true;
            }
        }
        fetch(CTX + '/customer/api/timetable-availability?coSoId=' + encodeURIComponent(COSO_ID) + '&date=' + encodeURIComponent(state.date),
              { signal: state.abortCtrl.signal, headers: { 'Accept': 'application/json' }, cache: 'no-store' })
            .then(function(r) { if (!r.ok) throw new Error('HTTP ' + r.status); return r.json(); })
            .then(function(data) {
                if (!data.success) throw new Error(data.error || 'load-failed');
                state.courts    = data.courts || [];
                state.openMin   = hhmmToMin(data.openTime);
                state.closeMin  = hhmmToMin(data.closeTime);
                state.nowMinutes = data.nowMinutes;
                document.getElementById('ttvCardLoading').hidden = true;
                if (!state.courts.length) {
                    document.getElementById('ttvCardEmpty').hidden = false;
                } else {
                    renderCards();
                    if (state.currentStep === 2) {
                        var c = state.courts.find(function(x) { return x.sanId == state.activeSanId; });
                        if (c) renderTimeline(c); else ttvGoToStep1();
                    } else if (sd.preSanId) {
                        var pre = state.courts.find(function(x) { return x.sanId == sd.preSanId; });
                        if (pre) ttvGoToStep2(pre);
                        sd.preSanId = null;
                    }
                }
            })
            .catch(function(err) {
                if (err && err.name === 'AbortError') return;
                if (!silent) {
                    document.getElementById('ttvCardLoading').hidden = true;
                    document.getElementById('ttvCardError').hidden = false;
                }
            });
    }

    /* ── Render court cards (Step 1) ── */
    function renderCards() {
        var list = document.getElementById('ttvCardList');
        list.innerHTML = '';
        state.courts.forEach(function(court) {
            var hasAvail = court.slots && court.slots.some(function(s) { return s.status === 'AVAILABLE'; });
            var card = document.createElement('div');
            card.className = 'court-card';
            card.setAttribute('role', 'listitem');
            card.setAttribute('tabindex', '0');
            card.setAttribute('aria-label', (court.tenSan || 'Sân ' + court.sanId) + (hasAvail ? ' – Còn trống' : ' – Hết giờ'));
            card.innerHTML =
                '<div class="court-card-icon">' + courtIcon(court.tenLoai) + '</div>' +
                '<div class="court-card-info">' +
                    '<div class="court-card-name">' + escHtml(court.tenSan || 'Sân #' + court.sanId) + '</div>' +
                    '<div class="court-card-meta">' +
                        (court.tenLoai ? '<span class="court-card-badge">' + escHtml(court.tenLoai) + '</span>' : '') +
                        (court.giaKhongDen ? '<span class="court-card-price">' + fmtVnd(court.giaKhongDen) + '/giờ</span>' : '') +
                    '</div>' +
                '</div>' +
                '<div class="court-card-avail ' + (hasAvail ? 'has-slots' : 'no-slots') + '">' +
                    '<div class="avail-dot"></div>' +
                    (hasAvail ? 'Còn trống' : 'Hết giờ') +
                '</div>' +
                '<svg class="court-card-arrow" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.3" stroke-linecap="round" stroke-linejoin="round"><path d="m9 18 6-6-6-6"/></svg>';

            card.addEventListener('click', function() { ttvGoToStep2(court); });
            card.addEventListener('keydown', function(e) {
                if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); ttvGoToStep2(court); }
            });
            list.appendChild(card);
        });
    }

    function escHtml(s) {
        return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
    }

    /* ── Render single-court timeline (Step 2) ── */
    function renderTimeline(court) {
        var tl = document.getElementById('ttvTl');
        document.getElementById('ttvTlLoading').hidden = true;
        document.getElementById('ttvTlError').hidden = true;
        document.getElementById('ttvTlEmpty').hidden = true;
        tl.hidden = false;
        tl.innerHTML = '';

        var slotCount = Math.floor((state.closeMin - state.openMin) / SLOT_MIN);
        if (!slotCount) { tl.hidden = true; document.getElementById('ttvTlEmpty').hidden = false; return; }

        // Header row
        var head = document.createElement('div');
        head.className = 'ttv-tl-head';
        for (var i = 0; i < slotCount; i++) {
            var min = state.openMin + i * SLOT_MIN;
            var hc = document.createElement('div');
            hc.className = 'ttv-tl-head-cell';
            if (min % 60 === 0) {
                hc.classList.add('is-hour');
                hc.textContent = minToHhmm(min);
            } else {
                hc.style.color = '#c4c9d4';
                hc.textContent = ':' + String(min % 60).padStart(2,'0');
            }
            addNowMarker(hc, min, SLOT_MIN, i === 0);
            head.appendChild(hc);
        }
        tl.appendChild(head);

        // Slots row
        var row = document.createElement('div');
        row.className = 'ttv-tl-row';
        var j = 0;
        while (j < court.slots.length) {
            var slot = court.slots[j];
            if (slot.status === 'AVAILABLE') {
                row.appendChild(buildAvailSlot(court, slot));
                j++;
            } else {
                var k = j + 1;
                while (k < court.slots.length && court.slots[k].status === slot.status) k++;
                row.appendChild(buildBlockedRun(court, court.slots.slice(j, k)));
                j = k;
            }
        }
        tl.appendChild(row);

        // Restore selection visual if same court
        if (state.selectedSanId == court.sanId) refreshSelVis();

        // Scroll to now or first available
        setTimeout(function() {
            var nowCell = document.querySelector('.ttv-tl-head-cell .ttv-now-marker');
            if (nowCell) {
                nowCell.closest('.ttv-tl-head-cell').scrollIntoView({ inline: 'center', block: 'nearest' });
            } else {
                var firstAvail = document.querySelector('.ttv-slot:not(.is-blocked)');
                if (firstAvail) firstAvail.scrollIntoView({ inline: 'start', block: 'nearest' });
            }
        }, 50);
    }

    function addNowMarker(cell, startMin, spanMin, withChip) {
        if (state.nowMinutes < startMin || state.nowMinutes >= startMin + spanMin) return;
        var m = document.createElement('div');
        m.className = 'ttv-now-marker';
        m.style.left = ((state.nowMinutes - startMin) / spanMin * 100) + '%';
        cell.appendChild(m);
        if (withChip) {
            var chip = document.createElement('span');
            chip.className = 'ttv-now-chip';
            chip.style.left = ((state.nowMinutes - startMin) / spanMin * 100) + '%';
            chip.textContent = 'Hiện tại';
            cell.appendChild(chip);
        }
    }

    function buildAvailSlot(court, slot) {
        var cell = document.createElement('div');
        cell.className = 'ttv-slot';
        if (slot.startMinute % 60 === 0) cell.classList.add('is-hour');
        cell.dataset.sanId = court.sanId;
        cell.dataset.start = slot.start;
        cell.dataset.end   = slot.end;
        cell.dataset.startMinute = slot.startMinute;
        cell.dataset.status = slot.status;
        cell.setAttribute('role','button');
        cell.setAttribute('tabindex','0');
        cell.setAttribute('aria-label', slot.start + '–' + slot.end + ' Trống');
        cell.addEventListener('click', function() { onSlotClick(court.sanId, slot); });
        cell.addEventListener('mouseenter', function() { onSlotHover(court.sanId, slot); });
        cell.addEventListener('keydown', function(e) {
            if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); onSlotClick(court.sanId, slot); }
        });
        addNowMarker(cell, slot.startMinute, SLOT_MIN, false);
        return cell;
    }

    function buildBlockedRun(court, run) {
        var first = run[0], last = run[run.length - 1];
        var span = run.length;
        var cell = document.createElement('div');
        var st = first.status.toLowerCase();
        cell.className = 'ttv-slot is-blocked is-' + st;
        if (span > 1) cell.classList.add('is-merged');
        if (first.startMinute % 60 === 0) cell.classList.add('is-hour');
        /* Span multiple slots by overriding width; flexbox width is set via CSS var per slot */
        cell.style.setProperty('width', 'calc(var(--ttv-slot-w) * ' + span + ')');
        cell.style.flexShrink = '0';
        cell.dataset.sanId = court.sanId;
        cell.dataset.startMinute = first.startMinute;
        cell.dataset.status = first.status;
        cell.setAttribute('role','button');
        cell.setAttribute('tabindex','-1');
        var statusTxt = statusLabel(first.status);
        cell.setAttribute('aria-label', first.start + '–' + last.end + ' ' + statusTxt);
        cell.title = statusTxt + ' · ' + first.start + '–' + last.end;
        if (span >= 2) {
            var lbl = document.createElement('span');
            lbl.className = 'ttv-slot-label';
            lbl.textContent = span >= 3 ? (statusTxt + ' · ' + first.start + '–' + last.end) : statusTxt;
            cell.appendChild(lbl);
        }
        cell.addEventListener('click', function() { onSlotClick(court.sanId, first); });
        if (first.status === 'HOLD_SELF') {
            cell.setAttribute('tabindex','0');
            cell.addEventListener('keydown', function(e) {
                if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); onSlotClick(court.sanId, first); }
            });
        }
        addNowMarker(cell, first.startMinute, span * SLOT_MIN, false);
        return cell;
    }

    function statusLabel(s) {
        switch (s) {
            case 'AVAILABLE':  return 'Trống';
            case 'BOOKED':     return 'Đã đặt';
            case 'HOLD':       return 'Đang giữ';
            case 'HOLD_SELF':  return 'Chờ thanh toán';
            case 'LOCKED':     return 'Khóa';
            case 'PAST':       return 'Đã qua';
            default: return s;
        }
    }

    /* ── Selection ── */
    function clearSelection() {
        state.selectedSanId = null;
        state.selectedStart = null;
        state.selectedEnd   = null;
        state.priceResult   = null;
        refreshSelVis();
        updateSummary();
    }

    function onSlotClick(sanId, slot) {
        if (slot.status === 'HOLD_SELF' && slot.datSanId) {
            window.location.href = CTX + '/customer/thanh-toan-qr?datSanId=' + slot.datSanId;
            return;
        }
        if (slot.status !== 'AVAILABLE') {
            var msg = 'Khung giờ này không khả dụng.';
            if (slot.status === 'BOOKED') msg = 'Khung giờ này đã được đặt.';
            else if (slot.status === 'PAST') msg = 'Không thể chọn thời gian đã qua.';
            else if (slot.status === 'HOLD') msg = 'Khung giờ đang được người khác giữ chỗ.';
            else if (slot.status === 'LOCKED') msg = 'Sân tạm ngưng trong thời gian này.';
            ttvToast(msg, slot.status === 'BOOKED' ? 'danger' : 'warn');
            return;
        }
        var startM = slot.startMinute, endM = startM + SLOT_MIN;
        if (state.selectedSanId == null || state.selectedSanId != sanId) {
            state.selectedSanId = sanId; state.selectedStart = startM; state.selectedEnd = endM;
        } else if (startM >= state.selectedStart && startM < state.selectedEnd) {
            state.selectedEnd = startM;
            if (state.selectedEnd - state.selectedStart <= 0) { clearSelection(); return; }
        } else if (startM === state.selectedEnd) {
            if (checkContiguous(sanId, state.selectedEnd, endM)) state.selectedEnd = endM;
            else { ttvToast('Chỉ chọn các khung giờ liền nhau.','warn'); return; }
        } else if (startM === state.selectedStart - SLOT_MIN) {
            if (checkContiguous(sanId, startM, state.selectedStart)) state.selectedStart = startM;
            else { ttvToast('Chỉ chọn các khung giờ liền nhau.','warn'); return; }
        } else {
            state.selectedStart = startM; state.selectedEnd = endM;
        }
        if (state.selectedEnd - state.selectedStart > MAX_DUR) {
            state.selectedEnd = state.selectedStart + MAX_DUR;
            ttvToast('Tối đa ' + (MAX_DUR/60) + ' giờ. Đã tự cắt bớt.','warn');
        }
        if (!isSelValid(sanId, state.selectedStart, state.selectedEnd)) {
            ttvToast('Khoảng chọn chứa giờ không khả dụng. Hãy chọn lại.','warn');
            clearSelection(); return;
        }
        refreshSelVis(); state.priceResult = null; updateSummary(); fetchPrice();
    }

    function onSlotHover(sanId, slot) {
        if (!state.selectedSanId || state.selectedSanId != sanId || state.selectedStart == null) return;
        if (slot.status !== 'AVAILABLE') return;
        var hEnd = slot.startMinute + SLOT_MIN;
        if (hEnd <= state.selectedEnd) return;
        if (!isSelValid(sanId, state.selectedStart, hEnd)) return;
        document.querySelectorAll('.ttv-slot.is-hover').forEach(function(c) { c.classList.remove('is-hover'); });
        document.querySelectorAll('.ttv-slot[data-san-id="' + sanId + '"]').forEach(function(c) {
            var m = parseInt(c.dataset.startMinute, 10);
            if (m >= state.selectedEnd && m < hEnd) c.classList.add('is-hover');
        });
    }

    function checkContiguous(sanId, from, to) {
        var court = state.courts.find(function(c) { return c.sanId == sanId; });
        if (!court) return false;
        for (var m = from; m < to; m += SLOT_MIN) {
            var s = court.slots.find(function(sl) { return sl.startMinute === m; });
            if (!s || s.status !== 'AVAILABLE') return false;
        }
        return true;
    }
    function isSelValid(sanId, s, e) { return checkContiguous(sanId, s, e) && (e - s) >= SLOT_MIN; }

    function refreshSelVis() {
        document.querySelectorAll('.ttv-slot').forEach(function(c) {
            c.classList.remove('is-selected','sel-start','sel-end','is-hover');
        });
        document.querySelectorAll('.ttv-sel-label').forEach(function(l) { l.remove(); });
        if (!state.selectedSanId || state.selectedStart == null) return;
        var startCell = null, cnt = 0;
        document.querySelectorAll('.ttv-slot[data-san-id="' + state.selectedSanId + '"]').forEach(function(c) {
            var m = parseInt(c.dataset.startMinute, 10);
            if (m >= state.selectedStart && m < state.selectedEnd) {
                c.classList.add('is-selected'); cnt++;
                if (m === state.selectedStart) { c.classList.add('sel-start'); startCell = c; }
                if (m + SLOT_MIN === state.selectedEnd) c.classList.add('sel-end');
            }
        });
        if (startCell && cnt > 0) {
            var lbl = document.createElement('span');
            lbl.className = 'ttv-sel-label';
            lbl.textContent = minToHhmm(state.selectedStart) + '–' + minToHhmm(state.selectedEnd);
            lbl.style.width = (cnt * 100) + '%';
            startCell.appendChild(lbl);
        }
    }

    /* ── Price fetch ── */
    var priceAbort = null;
    function fetchPrice() {
        if (!state.selectedSanId || state.selectedStart == null) { state.priceResult = null; updateSummary(); return; }
        if (priceAbort) priceAbort.abort();
        priceAbort = new AbortController();
        var p = new URLSearchParams();
        p.set('sanId', state.selectedSanId); p.set('date', state.date);
        p.set('start', minToHhmm(state.selectedStart)); p.set('end', minToHhmm(state.selectedEnd));
        fetch(CTX + '/customer/api/timetable-price?' + p.toString(),
              { signal: priceAbort.signal, headers: { 'Accept': 'application/json' } })
            .then(function(r) { return r.json(); })
            .then(function(data) {
                if (!data.success) { state.priceResult = null; ttvToast(data.error || 'Không thể tính giá.','warn'); }
                else state.priceResult = data;
                updateSummary();
            })
            .catch(function(err) { if (err && err.name === 'AbortError') return; state.priceResult = null; updateSummary(); });
    }

    /* ── Summary / CTA ── */
    function setCta(disabled, label, spinner) {
        var btn = document.getElementById('ttvNextBtn');
        btn.disabled = disabled; btn.innerHTML = '';
        if (spinner) {
            var sp = document.createElement('span'); sp.className = 'ttv-cta-spinner'; sp.setAttribute('aria-hidden','true'); btn.appendChild(sp);
        }
        var s = document.createElement('span'); s.id = 'ttvNextLabel'; s.textContent = label; btn.appendChild(s);
    }

    function updateSummary() {
        var dur = (state.selectedStart != null && state.selectedEnd != null) ? state.selectedEnd - state.selectedStart : 0;
        var hasSel = state.selectedSanId && dur > 0;
        document.getElementById('ttvDuration').textContent = hasSel ? fmtDur(dur) : '0h00';

        if (state.currentStep === 1) {
            document.getElementById('ttvFooterSel').textContent = 'Chọn sân để bắt đầu';
            document.getElementById('ttvTotal').textContent = '0 đ';
            setCta(true, 'Chọn sân để bắt đầu', false);
            return;
        }
        if (!hasSel) {
            document.getElementById('ttvFooterSel').textContent = 'Chưa chọn khung giờ';
            document.getElementById('ttvTotal').textContent = '0 đ';
            setCta(true, 'Chọn khung giờ để tiếp tục', false);
            return;
        }
        var court = state.courts.find(function(c) { return c.sanId == state.selectedSanId; });
        document.getElementById('ttvFooterSel').textContent =
            (court ? court.tenSan : 'Sân #' + state.selectedSanId) + ' · ' +
            minToHhmm(state.selectedStart) + '–' + minToHhmm(state.selectedEnd);
        if (dur < MIN_DUR) {
            document.getElementById('ttvTotal').textContent = '0 đ';
            setCta(true, 'Chọn thêm thời gian', false); return;
        }
        if (state.priceResult) {
            document.getElementById('ttvTotal').textContent = fmtVnd(parseFloat(state.priceResult.totalAmount));
            setCta(state.pendingSubmit, state.pendingSubmit ? 'Đang kiểm tra lịch...' : 'Tiếp theo →', state.pendingSubmit);
        } else {
            document.getElementById('ttvTotal').textContent = '...';
            setCta(true, 'Đang tính giá...', false);
        }
    }

    /* ── Submit ── */
    document.getElementById('ttvBookingForm').addEventListener('submit', function(e) {
        if (state.pendingSubmit) { e.preventDefault(); return; }
        if (!state.selectedSanId || state.selectedStart == null) { e.preventDefault(); ttvToast('Vui lòng chọn khung giờ.','warn'); return; }
        document.getElementById('ttvInputSanId').value      = state.selectedSanId;
        document.getElementById('ttvInputNgayDat').value    = state.date;
        document.getElementById('ttvInputGioBatDau').value  = minToHhmm(state.selectedStart);
        document.getElementById('ttvInputGioKetThuc').value = minToHhmm(state.selectedEnd);
        state.pendingSubmit = true;
        setCta(true,'Đang kiểm tra lịch...',true);
        showStepLoading('Đang chuẩn bị lịch đặt…');
    });

    /* ── Toast ── */
    var _toastTimer = null;
    window.ttvToast = function(msg, kind) {
        var el = document.getElementById('ttvToast');
        el.className = 'ttv-toast';
        if (kind) el.classList.add(kind);
        el.textContent = msg; el.classList.add('open');
        clearTimeout(_toastTimer);
        _toastTimer = setTimeout(function() { el.classList.remove('open'); }, 3200);
    };

    /* ── Auto-poll ── */
    var pollTimer = null;
    function startPoll() {
        if (pollTimer) clearInterval(pollTimer);
        pollTimer = setInterval(function() {
            if (!document.hidden && !state.pendingSubmit) loadAvailability(true);
        }, 8000);
    }
    document.addEventListener('visibilitychange', function() {
        if (!document.hidden && !state.pendingSubmit) loadAvailability(true);
    });
    window.addEventListener('focus', function() {
        if (!state.pendingSubmit) loadAvailability(true);
    });

    loadAvailability();
    startPoll();
})();
</script>

</c:if>

<c:if test="${empty coSo and emptyState ne 'no_facility'}">
    <div class="ttv-empty-facility">
        <h2>Không tải được dữ liệu</h2>
        <p>Vui lòng thử lại.</p>
        <a href="${ctx}/index.jsp" class="ttv-btn-ghost">Về trang chủ</a>
    </div>
</c:if>

</body>
</html>
