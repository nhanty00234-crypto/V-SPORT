<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%--
    V-SPORT shared facility interactions (Customer Portal).
    Bundles: home toast, "Chọn hình thức đặt" modal, facility-detail bottom sheet,
    and all their CSS + JS. Extracted from index.jsp so any customer page listing
    facility cards can reuse the exact same interaction instead of re-implementing it.

    Requires on the including page:
      - a container with id="facilityGrid" holding .facility-card elements, each with
        data-coso-id / data-facility-name / data-card-image attributes, and a
        [data-book-trigger] button with data-coso-id / data-facility-name.
      - jsp:include of customer/common/vsport-theme.jsp (design tokens).
    Provides to the including page: window.showHomeToast(msg), window.VSPORT_CONTEXT_PATH,
    window.openFacilitySheet(cardOrElWithDataAttrs), window.selectSheetTab('overview'|'courts'|...).
    Pages without a real .facility-card grid (e.g. BanDo.jsp) can still open the sheet by
    building a detached element with data-coso-id/data-facility-name and passing it to
    openFacilitySheet(), then optionally window.selectSheetTab('courts') to land on booking.
--%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<style>
    :root {
        --vsx-font: 'Be Vietnam Pro', 'Inter', system-ui, -apple-system, sans-serif;
        --vsx-scoreboard-font: 'Space Mono', 'Roboto Mono', monospace;
        /* Line & Scoreboard palette — see docs/design/stitch-customer-redesign-prompt.md.
           These pages don't include vsport-theme.jsp, so the old --vs-mint-*/--vs-pink-*
           names below are kept only so nothing else breaks, but repointed to the new colors. */
        --vs-mint-100: #DCEEEC;
        --vs-mint-50: #EAF3F2;
        --vs-pink-100: #fae8f8;
        --vs-pink-600: #c83db3;
        --vsx-primary: #0E6E6A;
        --vsx-primary-dark: #0A5652;
        --vsx-orange: #D6572B;
        --vsx-orange-dark: #B8431E;
        --vs-overlay: rgba(8, 18, 15, 0.55);
        --vsx-border: #E2E5E0;
        --vsx-text: #12201B;
        --vsx-muted: #5C6B64;
    }
    .lci { width: 20px; height: 20px; flex-shrink: 0; }
    .vsx-lbracket { position: relative; }
    .vsx-lbracket::before, .vsx-lbracket::after {
        content: ''; position: absolute; width: 18px; height: 18px; z-index: 3; pointer-events: none;
    }
    .vsx-lbracket::before { top: 0; left: 0; border-top: 3px solid #0E6E6A; border-left: 3px solid #0E6E6A; }
    .vsx-lbracket::after { bottom: 0; right: 0; border-bottom: 3px solid #0E6E6A; border-right: 3px solid #0E6E6A; }
    .vsx-scoreboard {
        font-family: var(--vsx-scoreboard-font); letter-spacing: .02em;
    }

    /* [hidden] phải thắng cả các class có display:flex/inline-flex */
    [hidden] { display: none !important; }

    .vsx-overlay {
        position: fixed; inset: 0; background: var(--vs-overlay);
        z-index: 1240; opacity: 0; transition: opacity 220ms ease;
    }
    .vsx-overlay.is-open { opacity: 1; }

    /* ---- Modal "Chọn hình thức đặt" ---- */
    .vsbc-backdrop {
        position: fixed; inset: 0; z-index: 1249;
        background: rgba(3, 19, 36, 0.66);
        backdrop-filter: blur(1.5px); -webkit-backdrop-filter: blur(1.5px);
        opacity: 0; transition: opacity 220ms ease;
    }
    .vsbc-backdrop.is-open { opacity: 1; }
    .vsbc-modal-layer {
        position: fixed; inset: 0; z-index: 1250;
        display: flex; align-items: center; justify-content: center;
        padding: 16px; pointer-events: none;
    }
    .vsbc-modal-layer .vsbc-modal { pointer-events: auto; }
    .vsbc-modal {
        width: 580px; max-width: calc(100vw - 32px);
        max-height: calc(100dvh - 32px); overflow-y: auto;
        background: #fff; border-radius: 24px;
        padding: 28px 24px 24px;
        opacity: 0; transform: scale(.96);
        box-shadow: 0 24px 70px rgba(7, 29, 54, 0.28);
        transition: opacity 200ms ease, transform 200ms ease;
        font-family: var(--vsx-font); color: var(--vsx-text);
        position: relative;
    }
    .vsbc-modal.is-open { opacity: 1; transform: scale(1); }
    @media (max-width: 767px) {
        .vsbc-modal-layer { padding: 12px; }
        .vsbc-modal { width: calc(100vw - 24px); padding: 22px 16px 18px; border-radius: 20px; }
    }
    .vsbc-head { margin-bottom: 24px; text-align: center; }
    .vsbc-title {
        font-family: 'Inter', 'Be Vietnam Pro', system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
        font-size: 24px; line-height: 1.25; font-weight: 800; letter-spacing: 0;
        color: var(--vs-primary-900, #0B2D52);
        text-align: center; margin: 0; padding: 0 36px;
    }
    @media (max-width: 389px) { .vsbc-title { font-size: 20px; } }
    .vsbc-sub {
        text-align: center; font-size: 14px; font-weight: 600; color: #64748b;
        margin: 6px 0 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
    }
    .vsbc-sub:empty { display: none; }
    .vsbc-x {
        position: absolute; top: 18px; right: 18px;
        width: 38px; height: 38px; border-radius: 50%; border: none; cursor: pointer;
        background: #f1f5f9; color: #0f172a;
        display: flex; align-items: center; justify-content: center; flex-shrink: 0;
        transition: all .15s ease; z-index: 10;
    }
    .vsbc-x .lci { width: 22px; height: 22px; }
    .vsbc-x:hover { background: #e2e8f0; color: #000; }
    .vsbc-x:focus-visible { outline: 3px solid var(--vs-focus-ring, rgba(24, 200, 232, 0.35)); outline-offset: 2px; }
    .vsbc-option {
        display: flex; flex-direction: column; justify-content: center;
        width: 100%; min-height: 108px; padding: 20px 80px 20px 24px;
        border-radius: 18px; border: 1.5px solid transparent;
        text-decoration: none; cursor: pointer; text-align: left; user-select: none;
        position: relative; overflow: hidden; box-sizing: border-box;
        transform: none;
        transition: border-color 120ms ease, filter 110ms ease,
                    box-shadow 110ms ease, transform 110ms ease;
    }
    .vsbc-option + .vsbc-option { margin-top: 16px; }
    /* Hover: chỉ đổi màu viền — tuyệt đối không chuyển động/scale/shadow animation. */
    .vsbc-option:hover { transform: none; }
    .vsbc-option-direct:hover { border-color: var(--vsx-primary, #0E6E6A); }
    .vsbc-option-match:hover { border-color: var(--vsx-orange, #D6572B); }
    /* Press: card lún nhẹ xuống với inset shadow (giữ hiệu ứng qua class, không chỉ :active). */
    .vsbc-option:active,
    .vsbc-option.is-pressed {
        transform: translateY(2px) scale(0.985);
        box-shadow: inset 0 4px 9px rgba(7, 29, 54, 0.15), 0 2px 5px rgba(7, 29, 54, 0.08);
        filter: brightness(0.97);
    }
    @media (prefers-reduced-motion: reduce) {
        .vsbc-option:active, .vsbc-option.is-pressed { transform: none; }
    }
    .vsbc-option:focus-visible { outline: 3px solid var(--vs-focus-ring, rgba(24, 200, 232, 0.35)); outline-offset: 2px; }

    /* ---- V-SPORT step-transition loading (full viewport, Navy) ---- */
    .vsx-loading {
        position: fixed; inset: 0; z-index: 99999;
        background: var(--vs-primary-950, #0B2E59);
        display: flex; align-items: center; justify-content: center; overflow: hidden;
        color: #fff; opacity: 0; visibility: hidden; pointer-events: none;
        transition: opacity 150ms ease;
    }
    .vsx-loading.is-visible { opacity: 1; visibility: visible; pointer-events: all; }
    .vsx-loading-title {
        position: absolute; top: 26px; left: 50%; transform: translateX(-50%);
        font-family: var(--vsx-font); font-size: 16px; font-weight: 700; color: #fff;
        text-align: center; white-space: nowrap;
    }
    .vsx-loading-ring {
        width: 32px; height: 32px; border-radius: 50%;
        border: 4px solid rgba(255, 255, 255, .30);
        border-top-color: #fff;
        animation: vsxSpin 0.8s linear infinite;
    }
    @keyframes vsxSpin { to { transform: rotate(360deg); } }
    @media (prefers-reduced-motion: reduce) {
        .vsx-loading-ring { animation-duration: 2.4s; }
    }
    .vsbc-option-direct { background: #EBF5FF; border-color: rgba(22, 119, 210, 0.2); }
    .vsbc-option-direct .vsbc-opt-title { color: #0E6E6A; }
    .vsbc-option-match { background: #FFF2E8; border-color: rgba(240, 120, 32, 0.2); }
    .vsbc-option-match .vsbc-opt-title { color: #D6572B; }
    .vsbc-opt-title { font-size: 19px; font-weight: 800; line-height: 1.25; margin-bottom: 6px; display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }
    .vsbc-opt-desc { font-size: 14px; font-weight: 500; color: #475569; line-height: 1.45; }
    .vsbc-badge {
        font-size: 10px; font-weight: 800; text-transform: uppercase; letter-spacing: .04em;
        background: var(--vsx-orange, #D6572B); color: #fff; padding: 2px 8px; border-radius: 9999px;
    }
    .vsbc-arrow {
        width: 44px; height: 44px; border-radius: 50%;
        position: absolute; right: 20px; top: 50%; transform: translateY(-50%);
        display: flex; align-items: center; justify-content: center; color: #fff;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.12);
        transition: transform 0.2s ease, box-shadow 0.2s ease;
    }
    .vsbc-arrow .lci { width: 22px; height: 22px; }
    .vsbc-option:hover .vsbc-arrow { transform: translateY(-50%) translateX(4px); box-shadow: 0 6px 16px rgba(0, 0, 0, 0.18); }
    .vsbc-option-direct .vsbc-arrow { background: var(--vsx-primary, #0E6E6A); }
    .vsbc-option-match .vsbc-arrow { background: var(--vsx-orange, #D6572B); }
    @media (max-width: 389px) {
        .vsbc-opt-title { font-size: 17px; }
        .vsbc-opt-desc { font-size: 14px; }
    }

    /* ---- Facility detail bottom sheet ---- */
    .vsfs-sheet {
        position: fixed; left: 0; right: 0; bottom: 0; width: 100%;
        max-height: 82dvh;
        background: #fff; border-radius: 24px 24px 0 0;
        z-index: 1250; transform: translateY(100%);
        transition: transform 300ms cubic-bezier(.22, 1, .36, 1);
        box-shadow: 0 -18px 50px rgba(7, 26, 47, 0.30);
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
    .vsfs-iconbtn:focus-visible { outline: 3px solid var(--vs-focus-ring, rgba(24, 200, 232, 0.35)); outline-offset: 2px; }
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
    .vsfs-hero.vsx-lbracket::before, .vsfs-hero.vsx-lbracket::after { width: 22px; height: 22px; }
    .vsfs-hero img { width: 100%; height: 100%; object-fit: cover; display: block; }
    /* carousel */
    .vsfs-carousel { position: relative; width: 100%; height: 100%; }
    .vsfs-carousel-track { display: flex; width: 100%; height: 100%; transition: transform .5s ease; }
    .vsfs-carousel-track img { flex: 0 0 100%; width: 100%; height: 100%; object-fit: cover; display: block; }
    .vsfs-carousel-btn {
        position: absolute; top: 50%; transform: translateY(-50%);
        background: rgba(0,0,0,.38); border: none; border-radius: 50%;
        width: 32px; height: 32px; cursor: pointer; color: #fff; display: flex; align-items: center; justify-content: center;
        font-size: 18px; z-index: 2; transition: background .2s;
    }
    .vsfs-carousel-btn:hover { background: rgba(0,0,0,.62); }
    .vsfs-carousel-btn.prev { left: 8px; }
    .vsfs-carousel-btn.next { right: 8px; }
    .vsfs-carousel-dots { position: absolute; bottom: 8px; left: 50%; transform: translateX(-50%); display: flex; gap: 5px; z-index: 2; }
    .vsfs-dot { width: 7px; height: 7px; border-radius: 50%; background: rgba(255,255,255,.5); cursor: pointer; transition: background .2s; }
    .vsfs-dot.active { background: #fff; }
    .vsfs-name { font-size: 24px; font-weight: 800; line-height: 1.25; }
    @media (min-width: 1024px) { .vsfs-name { font-size: 28px; } }
    .vsfs-chips { display: flex; flex-wrap: wrap; gap: 6px; margin-top: 8px; }
    .vsfs-chip {
        display: inline-flex; align-items: center; gap: 5px;
        font-size: 12px; font-weight: 700; padding: 4px 11px; border-radius: 9999px;
        background: var(--vs-mint-100); color: var(--vsx-primary-dark); border: 1px solid var(--vs-mint-100);
    }
    .vsfs-chip.is-warn { background: #fff7e6; color: #b45309; border-color: #fde4b8; }
    .vsfs-chip.is-ready { background: var(--vs-success-bg, #E5F7EF); color: var(--vs-success, #16A36A); border-color: var(--vs-success-bg, #E5F7EF); }
    .vsfs-meta { margin-top: 12px; display: flex; flex-direction: column; gap: 8px; }
    .vsfs-meta-row { display: flex; align-items: flex-start; gap: 9px; font-size: 14px; color: var(--vsx-muted); }
    .vsfs-meta-row .lci { width: 18px; height: 18px; color: var(--vsx-primary); margin-top: 1px; }
    .vsfs-price { font-size: 15px; font-weight: 800; color: var(--vsx-primary-dark); margin-top: 10px; font-family: var(--vsx-scoreboard-font); letter-spacing: .02em; }
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
    .vsfs-tab:focus-visible { outline: 3px solid rgba(14,110,106,.35); outline-offset: -2px; }
    .vsfs-tab[aria-selected="true"] { color: var(--vsx-primary); border-bottom-color: var(--vsx-primary); }
    .vsfs-panel { padding: 14px 2px 4px; font-size: 14px; line-height: 1.6; color: var(--vsx-muted); }
    .vsfs-court {
        display: flex; align-items: center; justify-content: space-between; gap: 12px; flex-wrap: wrap;
        border: 1px solid var(--vsx-border); border-radius: 12px; padding: 12px 14px;
        position: relative;
    }
    .vsfs-court + .vsfs-court { margin-top: 8px; }
    .vsfs-court-name { font-size: 14.5px; font-weight: 800; color: var(--vsx-text); }
    .vsfs-court-sub { font-size: 12.5px; color: var(--vsx-muted); margin-top: 2px; }
    .vsfs-court-price { font-size: 13.5px; font-weight: 800; color: var(--vsx-primary-dark); white-space: nowrap; font-family: var(--vsx-scoreboard-font); letter-spacing: .02em; }
    .vsfs-status {
        display: inline-block; font-size: 11px; font-weight: 700; padding: 2px 9px;
        border-radius: 9999px; margin-left: 8px; vertical-align: 2px;
    }
    .vsfs-status.is-ready { background: var(--vs-success-bg, #E5F7EF); color: var(--vs-success, #16A36A); }
    .vsfs-status.is-other { background: #f1f5f9; color: #64748b; }
    .vsfs-court-cta {
        display: inline-flex; align-items: center; gap: 6px;
        font-size: 12.5px; font-weight: 800; text-decoration: none;
        color: #fff; border: 1px solid var(--vsx-primary); background: var(--vsx-primary);
        padding: 8px 14px; border-radius: 8px; white-space: nowrap;
        transition: background-color .15s ease; min-height: 38px;
    }
    .vsfs-court-cta:hover { background: var(--vsx-primary-dark); border-color: var(--vsx-primary-dark); }
    .vsfs-court-cta.vsfs-cta-green {
        color: #fff; border-color: var(--vs-success, #16A36A); background: var(--vs-success, #16A36A);
    }
    .vsfs-court-cta.vsfs-cta-green:hover { background: var(--vs-success-dark, #12854F); border-color: var(--vs-success-dark, #12854F); }

    /* ---- Đặt lịch trực tiếp (ported from DatLichTrucQuan.jsp step 2) ---- */
    .fsbk-back {
        display: inline-flex; align-items: center; gap: 6px;
        border: none; background: transparent; color: var(--vsx-primary); cursor: pointer;
        font-family: inherit; font-size: 13px; font-weight: 700; padding: 6px 2px; margin-bottom: 10px;
    }
    .fsbk-back:hover { text-decoration: underline; }
    .fsbk-court-bar {
        display: flex; align-items: center; justify-content: space-between; gap: 10px;
        padding: 10px 12px; border-radius: 10px; background: var(--vs-mint-50); margin-bottom: 12px;
    }
    .fsbk-court-name { font-size: 14px; font-weight: 800; color: var(--vsx-text); }
    .fsbk-court-price { font-size: 13px; font-weight: 800; color: var(--vsx-primary-dark); font-family: var(--vsx-scoreboard-font); }
    .fsbk-datebar {
        display: flex; align-items: center; justify-content: center; gap: 6px;
        padding: 4px; border-radius: 10px; background: #f4f6f5; margin-bottom: 12px; max-width: 220px;
    }
    .fsbk-icon-btn {
        display: inline-flex; align-items: center; justify-content: center;
        width: 30px; height: 30px; border-radius: 8px; border: 1px solid var(--vsx-border);
        background: #fff; color: var(--vsx-text); cursor: pointer;
    }
    .fsbk-icon-btn:hover { border-color: var(--vsx-primary); color: var(--vsx-primary); }
    .fsbk-date-input {
        flex: 1; padding: 6px 8px; height: 30px; border: none; border-radius: 7px;
        background: #fff; font-size: 12.5px; font-weight: 700; color: var(--vsx-text);
        font-family: inherit; text-align: center; cursor: pointer;
    }
    .fsbk-legend { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; margin-bottom: 8px; }
    .fsbk-legend-item { display: inline-flex; align-items: center; gap: 5px; font-size: 11px; font-weight: 700; color: var(--vsx-muted); }
    .fsbk-legend-swatch { width: 12px; height: 12px; border-radius: 3px; }
    .fsbk-legend-swatch.avail { background: #fff; border: 2px solid #cbd5e1; }
    .fsbk-legend-swatch.select { background: rgba(14,110,106,.22); border: 2px solid var(--vsx-primary); }
    .fsbk-legend-swatch.booked { background: #e2e8f0; }
    .fsbk-legend-swatch.hold { background: #fde68a; }
    .fsbk-note {
        padding: 7px 10px; border-radius: 8px; margin-bottom: 10px;
        background: linear-gradient(90deg,#fffbeb,#fef9c3); border: 1px solid #fde68a;
        font-size: 11px; font-weight: 700; color: #92400e; text-align: center;
    }
    .fsbk-tl-scroll { overflow: auto; border: 1px solid var(--vsx-border); border-radius: 12px; max-height: 220px; background: #fff; }
    .fsbk-tl { display: flex; flex-direction: column; min-width: max-content; font-size: 12px; user-select: none; --fsbk-slot-w: 56px; }
    .fsbk-tl-head { display: flex; position: sticky; top: 0; z-index: 2; background: #f8fafc; border-bottom: 2px solid var(--vsx-border); }
    .fsbk-tl-head-cell {
        width: var(--fsbk-slot-w); height: 30px; flex-shrink: 0; display: flex; align-items: center; justify-content: center;
        font-size: 10.5px; font-weight: 800; color: var(--vsx-muted); border-right: 1px solid #e8edf2; position: relative;
    }
    .fsbk-tl-head-cell.is-hour { border-right-color: #cbd5e1; color: var(--vsx-text); }
    .fsbk-tl-row { display: flex; align-items: stretch; }
    .fsbk-slot {
        width: var(--fsbk-slot-w); height: 46px; flex-shrink: 0; display: flex; align-items: center; justify-content: center;
        cursor: pointer; border-right: 1px solid #eef0f4; border-bottom: 1px solid #eef0f4; background: #fff;
        position: relative; transition: background 80ms;
    }
    .fsbk-slot.is-hour { border-right-color: #dde3eb; }
    .fsbk-slot:hover:not(.is-blocked):not(.is-selected) { background: var(--vs-mint-50); }
    .fsbk-slot.is-selected { background: rgba(14,110,106,.18); box-shadow: inset 0 0 0 2px var(--vsx-primary); }
    .fsbk-slot.is-hover { background: rgba(14,110,106,.08); }
    .fsbk-slot.is-blocked { cursor: not-allowed; }
    .fsbk-slot.is-past { background: #f8fafc; }
    .fsbk-slot.is-booked { background: #f1f5f9; }
    .fsbk-slot.is-hold { background: #fef3c7; }
    .fsbk-slot.is-hold_self { background: rgba(14,110,106,.1); box-shadow: inset 0 0 0 2px var(--vsx-primary); cursor: pointer; }
    .fsbk-slot.is-locked { background: #f8fafc; }
    .fsbk-slot.is-merged { padding: 0 6px; }
    .fsbk-slot-label { font-size: 9.5px; font-weight: 700; color: var(--vsx-muted); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 100%; text-align: center; }
    .fsbk-sel-label { position: absolute; left: 0; top: 0; bottom: 0; z-index: 2; display: flex; align-items: center; justify-content: center; font-size: 10.5px; font-weight: 900; color: var(--vsx-primary-dark); white-space: nowrap; pointer-events: none; }
    .fsbk-now-marker { position: absolute; top: 0; bottom: 0; width: 2px; background: #ef4444; pointer-events: none; z-index: 3; }
    .fsbk-skel-row { padding: 12px; }
    .fsbk-empty { text-align: center; padding: 24px 12px; }
    .fsbk-empty p { color: var(--vsx-muted); font-size: 13px; font-weight: 600; margin: 0 0 10px; }
    .fsbk-footer { margin-top: 14px; }
    .fsbk-footer-row { display: flex; align-items: center; justify-content: space-between; gap: 12px; margin-bottom: 10px; }
    .fsbk-stat { display: flex; flex-direction: column; gap: 1px; }
    .fsbk-stat span { font-size: 9.5px; color: var(--vsx-muted); font-weight: 700; text-transform: uppercase; letter-spacing: .06em; }
    .fsbk-stat strong { font-size: 15px; font-weight: 900; color: var(--vsx-text); }
    .fsbk-stat.total strong { font-size: 19px; color: var(--vsx-primary-dark); letter-spacing: .02em; }
    .fsbk-cta {
        width: 100%; min-height: 48px; border: none; border-radius: 12px;
        background: var(--vsx-primary); color: #fff; font-size: 14.5px; font-weight: 800;
        font-family: inherit; cursor: pointer; box-shadow: 0 0 16px rgba(14,110,106,.4);
        transition: background .15s ease, transform 90ms;
    }
    .fsbk-cta:hover:not(:disabled) { background: var(--vsx-primary-dark); }
    .fsbk-cta:active:not(:disabled) { transform: translateY(1px); }
    .fsbk-cta:disabled { background: #e2e5e0; color: #9aa2a0; cursor: not-allowed; box-shadow: none; }
    @media (max-width: 480px) { .fsbk-tl { --fsbk-slot-w: 48px; } }

    .vsfs-service { display: flex; justify-content: space-between; gap: 12px; padding: 9px 2px; border-bottom: 1px solid #edf4f0; font-size: 13.5px; }
    .vsfs-service b { font-weight: 800; color: var(--vsx-primary-dark); white-space: nowrap; font-family: var(--vsx-scoreboard-font); letter-spacing: .02em; }
    .vsfs-imggrid { display: grid; grid-template-columns: repeat(auto-fill, minmax(160px, 1fr)); gap: 8px; }
    .vsfs-imggrid img { width: 100%; aspect-ratio: 4 / 3; object-fit: cover; border-radius: 10px; background: #eef4f1; }

    /* ---- Cửa hàng (Phase 4) ---- */
    .vsfs-shop-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(160px, 1fr)); gap: 12px; }
    .vsfs-product { border: 1px solid var(--vsx-border); border-radius: 12px; overflow: hidden; background: #fff; display: flex; flex-direction: column; }
    .vsfs-product-img { aspect-ratio: 1 / 1; background: var(--vs-mint-50); display: flex; align-items: center; justify-content: center; color: var(--vsx-muted); overflow: hidden; }
    .vsfs-product-img img { width: 100%; height: 100%; object-fit: cover; display: block; }
    .vsfs-product-img .lci { width: 34px; height: 34px; }
    .vsfs-product-body { padding: 10px 11px 11px; display: flex; flex-direction: column; gap: 4px; flex: 1; }
    .vsfs-product-cat { font-size: 10.5px; font-weight: 700; text-transform: uppercase; letter-spacing: .03em; color: var(--vsx-muted); }
    .vsfs-product-name { font-size: 13.5px; font-weight: 800; color: var(--vsx-text); line-height: 1.3; }
    .vsfs-product-price { font-size: 13.5px; font-weight: 800; color: var(--vsx-primary-dark); margin-top: auto; font-family: var(--vsx-scoreboard-font); letter-spacing: .02em; }
    .vsfs-product-stock { font-size: 11px; font-weight: 700; padding: 2px 8px; border-radius: 9999px; align-self: flex-start; }
    .vsfs-product-stock.is-in { background: var(--vs-success-bg, #E5F7EF); color: var(--vs-success, #16A36A); }
    .vsfs-product-stock.is-low { background: #fff7e6; color: #b45309; }
    .vsfs-product-stock.is-out { background: #f1f5f9; color: #64748b; }
    .vsfs-product-contact {
        display: inline-flex; align-items: center; justify-content: center;
        margin-top: 6px; padding: 7px 10px; border-radius: 8px;
        font-size: 12px; font-weight: 700; text-align: center; text-decoration: none;
        color: var(--vsx-primary-dark); background: var(--vs-mint-50);
        border: 1px solid var(--vs-mint-100);
    }
    a.vsfs-product-contact:hover { background: var(--vs-mint-100); }

    /* ---- Tab Ưu đãi ---- */
    .vsfs-promo-empty { text-align: center; padding: 28px 12px; color: var(--vsx-muted); font-size: 13.5px; font-weight: 600; }
    .vsfs-promo-list { display: flex; flex-direction: column; gap: 14px; }
    .vsfs-promo-card { border: 1px solid var(--vsx-border); border-radius: 14px; overflow: hidden; background: #fff; }
    .vsfs-promo-media { position: relative; aspect-ratio: 16 / 9; background: var(--vs-mint-50); overflow: hidden; }
    .vsfs-promo-media img { width: 100%; height: 100%; object-fit: cover; display: block; }
    .vsfs-promo-media .vsfs-promo-fallback {
        position: absolute; inset: 0; display: flex; flex-direction: column; align-items: center; justify-content: center;
        gap: 6px; color: var(--vsx-muted); font-size: 12px; font-weight: 600;
    }
    .vsfs-promo-media .vsfs-promo-fallback .lci { width: 26px; height: 26px; }
    .vsfs-promo-nav {
        position: absolute; top: 50%; transform: translateY(-50%); width: 32px; height: 32px; border-radius: 50%;
        border: none; background: rgba(15, 23, 42, .55); color: #fff; cursor: pointer;
        display: flex; align-items: center; justify-content: center; transition: background-color .15s ease;
    }
    .vsfs-promo-nav:hover { background: rgba(15, 23, 42, .78); }
    .vsfs-promo-nav.prev { left: 8px; }
    .vsfs-promo-nav.next { right: 8px; }
    .vsfs-promo-dots { position: absolute; bottom: 8px; left: 50%; transform: translateX(-50%); display: flex; gap: 5px; }
    .vsfs-promo-dot { width: 6px; height: 6px; border-radius: 50%; background: rgba(255,255,255,.55); border: none; padding: 0; cursor: pointer; }
    .vsfs-promo-dot.is-active { background: #fff; }
    .vsfs-promo-badge {
        position: absolute; top: 10px; left: 10px; display: inline-flex; align-items: center; gap: 5px;
        background: var(--vsx-orange); color: #fff;
        font-size: 12.5px; font-weight: 800; padding: 5px 11px; border-radius: 9999px;
    }
    .vsfs-promo-body { padding: 13px 14px 15px; display: flex; flex-direction: column; gap: 8px; }
    .vsfs-promo-title { font-size: 15px; font-weight: 800; color: var(--vsx-text); line-height: 1.3; }
    .vsfs-promo-code-row { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }
    .vsfs-promo-code {
        font-family: var(--vsx-scoreboard-font); font-size: 13.5px; font-weight: 700;
        letter-spacing: .03em; color: var(--vsx-primary-dark); background: var(--vs-mint-50);
        border: 1px dashed var(--vs-mint-100); border-radius: 8px; padding: 4px 10px;
    }
    .vsfs-promo-copy {
        border: none; background: transparent; color: var(--vsx-muted); cursor: pointer;
        display: inline-flex; align-items: center; gap: 4px; font-size: 12px; font-weight: 700;
        padding: 4px 6px; border-radius: 6px; transition: background-color .15s ease, color .15s ease;
    }
    .vsfs-promo-copy:hover { background: var(--vs-mint-50); color: var(--vsx-primary-dark); }
    .vsfs-promo-copy .lci { width: 14px; height: 14px; }
    .vsfs-promo-condlist { font-size: 12.5px; color: var(--vsx-muted); line-height: 1.7; }
    .vsfs-promo-condlist span + span::before { content: ' · '; }
    .vsfs-promo-status {
        display: inline-flex; align-self: flex-start; font-size: 11px; font-weight: 700;
        padding: 3px 9px; border-radius: 9999px; background: var(--vs-success-bg, #E5F7EF); color: var(--vs-success, #16A36A);
    }
    .vsfs-promo-status.is-ending { background: #fff7e6; color: #b45309; }
    .vsfs-promo-actions { display: flex; gap: 8px; margin-top: 4px; flex-wrap: wrap; }
    .vsfs-promo-btn {
        display: inline-flex; align-items: center; justify-content: center; gap: 6px;
        flex: 1; min-width: 120px; min-height: 40px; padding: 0 14px; border-radius: 9px;
        font-size: 13px; font-weight: 800; cursor: pointer; text-decoration: none;
        border: 1.5px solid transparent; transition: background-color .15s ease, border-color .15s ease;
    }
    .vsfs-promo-btn-use { background: var(--vsx-primary); color: #fff; }
    .vsfs-promo-btn-use:hover { background: var(--vsx-primary-dark); }
    .vsfs-promo-btn-book { background: #fff; color: var(--vsx-text); border-color: var(--vsx-border); }
    .vsfs-promo-btn-book:hover { background: var(--vs-mint-50); border-color: var(--vsx-primary); }

    .vsfs-policy-item { display: flex; gap: 9px; align-items: flex-start; }
    .vsfs-policy-item + .vsfs-policy-item { margin-top: 9px; }
    .vsfs-policy-item .lci { width: 17px; height: 17px; color: var(--vsx-primary); margin-top: 2px; }
    .vsfs-actionbar {
        flex-shrink: 0; border-top: 1px solid var(--vsx-border); background: #fff;
        padding: 12px 16px calc(12px + env(safe-area-inset-bottom, 0px));
    }
    .vsfs-actionbar-inner { width: 100%; max-width: 1360px; margin: 0 auto; display: flex; gap: 10px; justify-content: flex-end; flex-wrap: wrap; }
    .vsfs-btn {
        display: inline-flex; align-items: center; justify-content: center; gap: 8px;
        min-height: 46px; padding: 0 22px; border-radius: 10px; cursor: pointer;
        font-family: inherit; font-size: 14.5px; font-weight: 800; text-decoration: none;
        border: 1px solid transparent; transition: background-color .15s ease, box-shadow .15s ease;
    }
    .vsfs-btn:focus-visible { outline: 3px solid rgba(14,110,106,.35); outline-offset: 2px; }
    .vsfs-btn-primary { background: var(--vsx-primary); color: #fff; box-shadow: 0 0 16px rgba(14,110,106,.4); }
    .vsfs-btn-primary:hover { background: var(--vsx-primary-dark); }
    .vsfs-btn-ghost { background: #fff; color: var(--vsx-text); border-color: var(--vsx-border); }
    .vsfs-btn-ghost:hover { background: var(--vs-mint-50); border-color: var(--vsx-primary); }
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
</style>

<!-- Modal yêu cầu đăng nhập -->
<style>
    .vslr-backdrop {
        position: fixed; inset: 0; z-index: 1260;
        background: rgba(3, 19, 36, 0.66);
        backdrop-filter: blur(2px); -webkit-backdrop-filter: blur(2px);
        opacity: 0; transition: opacity 200ms ease;
        display: flex; align-items: center; justify-content: center; padding: 16px;
    }
    .vslr-backdrop.is-open { opacity: 1; }
    .vslr-modal {
        background: #fff; border-radius: 20px; padding: 28px 24px 24px;
        width: 380px; max-width: calc(100vw - 32px);
        box-shadow: 0 24px 70px rgba(7, 29, 54, 0.28);
        font-family: var(--vsx-font, 'Be Vietnam Pro', sans-serif);
        text-align: center; position: relative;
        transform: scale(.96); transition: transform 200ms ease;
    }
    .vslr-backdrop.is-open .vslr-modal { transform: scale(1); }
    .vslr-icon { font-size: 40px; margin-bottom: 12px; }
    .vslr-title { font-size: 20px; font-weight: 800; color: var(--vsx-text, #12201B); margin-bottom: 8px; }
    .vslr-desc { font-size: 14px; color: #64748b; font-weight: 500; margin-bottom: 22px; line-height: 1.5; }
    .vslr-actions { display: flex; gap: 10px; }
    .vslr-btn {
        flex: 1; padding: 12px; border-radius: 10px; font-size: 14px; font-weight: 700;
        cursor: pointer; border: none; text-decoration: none; text-align: center;
        display: inline-flex; align-items: center; justify-content: center;
        transition: background-color .15s ease;
    }
    .vslr-btn-cancel { background: #f1f5f9; color: #475569; }
    .vslr-btn-cancel:hover { background: #e2e8f0; }
    .vslr-btn-login { background: var(--vsx-primary, #0E6E6A); color: #fff; }
    .vslr-btn-login:hover { background: #0A5652; }
    @media (max-width: 400px) { .vslr-actions { flex-direction: column-reverse; } }
</style>
<div id="vsLoginRequiredModal" class="vslr-backdrop" hidden>
    <div class="vslr-modal" role="dialog" aria-modal="true" aria-labelledby="vslrTitle">
        <div class="vslr-icon">🔒</div>
        <h2 class="vslr-title" id="vslrTitle">Đăng nhập để đặt lịch</h2>
        <p class="vslr-desc">Bạn cần đăng nhập để sử dụng tính năng đặt sân. Đăng nhập chỉ mất vài giây!</p>
        <div class="vslr-actions">
            <button type="button" class="vslr-btn vslr-btn-cancel" id="vslrCancelBtn">Để sau</button>
            <a class="vslr-btn vslr-btn-login" href="${ctx}/dangnhap">Đăng nhập ngay</a>
        </div>
    </div>
</div>

<div id="vsBookingLoading" class="vsx-loading" role="status" aria-live="polite">
    <p id="vsBookingLoadingTitle" class="vsx-loading-title"></p>
    <div class="vsx-loading-ring" aria-hidden="true"></div>
    <span id="vsBookingLoadingText" style="position:absolute;width:1px;height:1px;overflow:hidden;clip:rect(0,0,0,0);white-space:nowrap;">Đang chuyển đến trang đặt lịch</span>
</div>

<div id="vsHomeToast" role="status" aria-live="polite" style="position:fixed;left:50%;bottom:calc(var(--vs-bottomnav-h, 62px) + 26px);transform:translateX(-50%) translateY(12px);z-index:1300;background:#0f172a;color:#fff;padding:10px 16px;border-radius:9999px;font-size:13px;font-weight:600;opacity:0;visibility:hidden;transition:opacity .2s ease,transform .2s ease;box-shadow:0 6px 18px rgba(15,23,42,.25);"></div>

<!-- ============ Modal "Chọn hình thức đặt" (một instance dùng chung) ============ -->
<div id="bookingChoiceBackdrop" class="vsbc-backdrop" hidden></div>
<div class="vsbc-modal-layer">
<div id="bookingChoiceModal" class="vsbc-modal" role="dialog" aria-modal="true" aria-labelledby="bookingChoiceTitle" hidden>
    <button type="button" id="bcCloseBtn" class="vsbc-x" aria-label="Đóng">
        <svg class="lci" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg>
    </button>
    <div class="vsbc-head">
        <h2 id="bookingChoiceTitle" class="vsbc-title">Chọn hình thức đặt</h2>
        <p id="bcFacilityName" class="vsbc-sub"></p>
    </div>

    <a id="bcOptionDirect" class="vsbc-option vsbc-option-direct" href="#" data-loading-label="Đặt lịch ngay trực quan">
        <span class="vsbc-opt-title">Đặt lịch ngay trực quan</span>
        <span class="vsbc-opt-desc">Đặt lịch ngay khi khách chơi nhiều khung giờ, nhiều sân.</span>
        <span class="vsbc-arrow" aria-hidden="true">
            <svg class="lci" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14"/><path d="m12 5 7 7-7 7"/></svg>
        </span>
    </a>

    <a id="bcOptionMatch" class="vsbc-option vsbc-option-match" href="#" data-loading-label="Tạo kèo / Tìm người chơi">
        <span class="vsbc-opt-title">Tạo kèo / Tìm người chơi <span class="vsbc-badge">Mới</span></span>
        <span class="vsbc-opt-desc">Tạo một trận mới hoặc tìm thêm người chơi phù hợp tại sân này.</span>
        <span class="vsbc-arrow" aria-hidden="true">
            <svg class="lci" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14"/><path d="m12 5 7 7-7 7"/></svg>
        </span>
    </a>
</div>
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
                    <div class="vsfs-hero vsx-lbracket" id="fsHero">
                        <div class="vsfs-carousel" id="fsCarousel">
                            <div class="vsfs-carousel-track" id="fsCarouselTrack"></div>
                            <button class="vsfs-carousel-btn prev" id="fsPrev" onclick="carouselMove(-1)" hidden>&#8249;</button>
                            <button class="vsfs-carousel-btn next" id="fsNext" onclick="carouselMove(1)" hidden>&#8250;</button>
                            <div class="vsfs-carousel-dots" id="fsDots"></div>
                        </div>
                    </div>
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
                    <button type="button" class="vsfs-tab" role="tab" id="fsTab-promotions" aria-controls="fsPanel-promotions" aria-selected="false" data-fstab="promotions">Ưu đãi</button>
                    <button type="button" class="vsfs-tab" role="tab" id="fsTab-services" aria-controls="fsPanel-services" aria-selected="false" data-fstab="services">Dịch vụ</button>
                    <button type="button" class="vsfs-tab" role="tab" id="fsTab-shop" aria-controls="fsPanel-shop" aria-selected="false" data-fstab="shop" hidden>Cửa hàng</button>
                    <button type="button" class="vsfs-tab" role="tab" id="fsTab-images" aria-controls="fsPanel-images" aria-selected="false" data-fstab="images">Hình ảnh</button>
                    <button type="button" class="vsfs-tab" role="tab" id="fsTab-policy" aria-controls="fsPanel-policy" aria-selected="false" data-fstab="policy">Chính sách</button>
                </div>
                <div class="vsfs-panel" role="tabpanel" id="fsPanel-overview" aria-labelledby="fsTab-overview" tabindex="0"></div>
                <div class="vsfs-panel" role="tabpanel" id="fsPanel-courts" aria-labelledby="fsTab-courts" tabindex="0" hidden>
                    <div id="fsCourtList"></div>
                    <a id="fsGhepKeoLink" class="fsbk-back" href="#" style="margin-top:6px;">
                        Không tìm được giờ phù hợp? Tạo kèo tìm người chơi tại đây
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.3" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14"/><path d="m12 5 7 7-7 7"/></svg>
                    </a>

                    <%-- ── Đặt lịch trực tiếp (ported from DatLichTrucQuan.jsp, restyled) ── --%>
                    <div id="fsBookStep2" class="fsbk-step2" hidden>
                        <button type="button" class="fsbk-back" id="fsbkBackBtn">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.3" stroke-linecap="round" stroke-linejoin="round"><path d="m15 18-6-6 6-6"/></svg>
                            Đổi sân
                        </button>
                        <div class="fsbk-court-bar">
                            <span class="fsbk-court-name" id="fsbkCourtName">—</span>
                            <span class="fsbk-court-price" id="fsbkCourtPrice"></span>
                        </div>
                        <div class="fsbk-datebar">
                            <button type="button" class="fsbk-icon-btn" id="fsbkPrevDay" aria-label="Ngày trước">
                                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.3" stroke-linecap="round" stroke-linejoin="round"><path d="m15 18-6-6 6-6"/></svg>
                            </button>
                            <input type="date" id="fsbkDateInput" class="fsbk-date-input" aria-label="Chọn ngày">
                            <button type="button" class="fsbk-icon-btn" id="fsbkNextDay" aria-label="Ngày sau">
                                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.3" stroke-linecap="round" stroke-linejoin="round"><path d="m9 18 6-6-6-6"/></svg>
                            </button>
                        </div>
                        <div class="fsbk-legend">
                            <span class="fsbk-legend-item"><span class="fsbk-legend-swatch avail"></span>Trống</span>
                            <span class="fsbk-legend-item"><span class="fsbk-legend-swatch select"></span>Đang chọn</span>
                            <span class="fsbk-legend-item"><span class="fsbk-legend-swatch booked"></span>Đã đặt</span>
                            <span class="fsbk-legend-item"><span class="fsbk-legend-swatch hold"></span>Giữ chỗ</span>
                        </div>
                        <div class="fsbk-note">Chọn các khung giờ <b>liền nhau</b>. Bấm ô đầu rồi bấm ô cuối.</div>
                        <div class="fsbk-tl-scroll" id="fsbkTlScroll">
                            <div id="fsbkTlLoading" class="fsbk-skel-row"><div class="vsx-skel" style="height:32px;margin-bottom:4px;"></div><div class="vsx-skel" style="height:52px;"></div></div>
                            <div id="fsbkTlError" class="fsbk-empty" hidden><p>Không tải được lịch sân.</p><button type="button" class="vsfs-btn vsfs-btn-ghost" id="fsbkTlRetry">Thử lại</button></div>
                            <div id="fsbkTlEmpty" class="fsbk-empty" hidden><p>Không có khung giờ trống trong ngày này.</p></div>
                            <div class="fsbk-tl" id="fsbkTl" hidden></div>
                        </div>
                        <form id="fsbkForm" action="${ctx}/customer/dat-lich-truc-quan/xac-nhan" method="get" class="fsbk-footer">
                            <input type="hidden" name="coSoId" id="fsbkInputCoSoId">
                            <input type="hidden" name="sanId" id="fsbkInputSanId">
                            <input type="hidden" name="ngayDat" id="fsbkInputNgayDat">
                            <input type="hidden" name="gioBatDau" id="fsbkInputGioBatDau">
                            <input type="hidden" name="gioKetThuc" id="fsbkInputGioKetThuc">
                            <div class="fsbk-footer-row">
                                <div class="fsbk-stat"><span>Thời lượng</span><strong id="fsbkDuration">0h00</strong></div>
                                <div class="fsbk-stat total"><span>Tổng tiền</span><strong id="fsbkTotal" class="vsx-scoreboard">0 đ</strong></div>
                            </div>
                            <button type="submit" class="fsbk-cta" id="fsbkSubmitBtn" disabled>
                                <span id="fsbkSubmitLabel">Chọn khung giờ để tiếp tục</span>
                            </button>
                        </form>
                    </div>
                </div>
                <div class="vsfs-panel" role="tabpanel" id="fsPanel-promotions" aria-labelledby="fsTab-promotions" tabindex="0" hidden></div>
                <div class="vsfs-panel" role="tabpanel" id="fsPanel-services" aria-labelledby="fsTab-services" tabindex="0" hidden></div>
                <div class="vsfs-panel" role="tabpanel" id="fsPanel-shop" aria-labelledby="fsTab-shop" tabindex="0" hidden>
                    <div id="fsShopLoading" class="vsfs-shop-grid">
                        <div class="vsx-skel" style="height:160px;border-radius:12px;"></div>
                        <div class="vsx-skel" style="height:160px;border-radius:12px;"></div>
                    </div>
                    <div id="fsShopEmpty" hidden><p>Cơ sở đang cập nhật sản phẩm. Vui lòng quay lại sau.</p></div>
                    <div id="fsShopError" hidden>
                        <p>Không thể tải danh sách sản phẩm.</p>
                        <button type="button" id="fsShopRetryBtn" class="vsfs-btn vsfs-btn-ghost">Thử lại</button>
                    </div>
                    <div id="fsShopGrid" class="vsfs-shop-grid" hidden></div>
                </div>
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
            <a id="fsMapActionBtn" class="vsfs-btn vsfs-btn-ghost" href="${ctx}/customer/ban-do">
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

<script>
    window.VSPORT_CONTEXT_PATH = window.VSPORT_CONTEXT_PATH || '${ctx}';
    window.VSPORT_IS_LOGGED_IN = <% out.print(session.getAttribute("user") != null ? "true" : "false"); %>;
    (function () {
        'use strict';
        const CTX = window.VSPORT_CONTEXT_PATH;
        const IS_LOGGED_IN = window.VSPORT_IS_LOGGED_IN === true;
        const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

        // ---- Shared toast (exposed globally so host pages can reuse it) ----
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
        window.showHomeToast = showHomeToast;

        function showLoginRequiredToast() {
            const modal = document.getElementById('vsLoginRequiredModal');
            if (modal) {
                const loginBtn = modal.querySelector('.vslr-btn-login');
                if (loginBtn) {
                    const currentUrl = window.location.pathname + window.location.search + window.location.hash;
                    loginBtn.href = CTX + '/dangnhap?redirect=' + encodeURIComponent(currentUrl);
                }
                modal.hidden = false;
                requestAnimationFrame(() => modal.classList.add('is-open'));
                lockScroll();
                modal.querySelector('.vslr-btn-login').focus();
                return;
            }
        }

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
        const bcBackdrop = document.getElementById('bookingChoiceBackdrop');
        const bcModal = document.getElementById('bookingChoiceModal');
        const bcClose = document.getElementById('bcCloseBtn');
        const bcDirect = document.getElementById('bcOptionDirect');
        const bcMatch = document.getElementById('bcOptionMatch');
        const bcName = document.getElementById('bcFacilityName');
        let bcReturnFocus = null;
        let bcOpen = false;

        function openBookingChoice(cosoId, facilityName, triggerEl, sportId) {
            if (!IS_LOGGED_IN) {
                showLoginRequiredToast();
                return;
            }
            if (bcOpen) return;
            bcOpen = true;
            bcReturnFocus = triggerEl || document.activeElement;
            // Option 1 hướng người dùng thẳng đến trang "Đặt lịch trực quan" theo đúng cơ sở
            // vừa chọn — timetable court×time thay cho danh sách phẳng cũ.
            bcDirect.href = CTX + '/customer/dat-lich-truc-quan?coSoId=' + encodeURIComponent(cosoId) +
                (sportId ? '&sportId=' + encodeURIComponent(sportId) : '');
            bcMatch.href = CTX + '/customer/ghep-keo?tab=tao-keo&coSoId=' + encodeURIComponent(cosoId);
            bcName.textContent = facilityName || '';
            bcBackdrop.hidden = false;
            bcModal.hidden = false;
            requestAnimationFrame(() => {
                bcBackdrop.classList.add('is-open');
                bcModal.classList.add('is-open');
            });
            lockScroll();
            bcDirect.focus();
        }
        function closeBookingChoice() {
            if (!bcOpen) return;
            bcOpen = false;
            bcBackdrop.classList.remove('is-open');
            bcModal.classList.remove('is-open');
            const done = () => { bcBackdrop.hidden = true; bcModal.hidden = true; };
            reduceMotion ? done() : setTimeout(done, 210);
            unlockScroll();
            if (bcReturnFocus && document.contains(bcReturnFocus)) bcReturnFocus.focus();
            bcReturnFocus = null;
        }
        window.openBookingChoice = openBookingChoice;
        bcClose.addEventListener('click', closeBookingChoice);
        bcBackdrop.addEventListener('click', closeBookingChoice);
        bcModal.addEventListener('keydown', e => trapTab(bcModal, e));

        // ---- Step-transition loading overlay (full màn hình, chỉ hiện sau khi user
        // thật sự chọn một option — không hiện khi mở modal/hover/focus/đóng modal). ----
        function showStepLoading(title) {
            const el = document.getElementById('vsBookingLoading');
            if (!el) return;
            document.getElementById('vsBookingLoadingTitle').textContent = title || '';
            document.body.style.overflow = 'hidden';
            el.classList.add('is-visible');
            el.setAttribute('aria-busy', 'true');
        }
        window.vsHideStepLoading = function () {
            const el = document.getElementById('vsBookingLoading');
            if (el) { el.classList.remove('is-visible'); el.removeAttribute('aria-busy'); }
            document.body.style.overflow = '';
        };

        // Khôi phục hai option về trạng thái bấm được (dùng cho fallback lỗi + Back).
        let vsNavFallbackTimer = null;
        function enableBookingOptions() {
            clearTimeout(vsNavFallbackTimer);
            [bcDirect, bcMatch].forEach(el => {
                delete el.dataset.navigating;
                el.classList.remove('is-pressed');
                el.removeAttribute('aria-disabled');
                el.style.pointerEvents = '';
            });
        }
        window.enableBookingOptions = enableBookingOptions;

        // Khi trang được hiển thị lại (bấm Back, kể cả bfcache) — không để loader kẹt
        // và cho phép chọn lại option. pageshow luôn chạy khi trang quay lại tiền cảnh.
        window.addEventListener('pageshow', function () {
            window.vsHideStepLoading();
            enableBookingOptions();
        });

        // Luồng nhấn: press ngay lập tức -> khóa chống double-click -> giữ trạng thái
        // lún ~130ms để người dùng thấy -> hiện loader toàn màn hình -> giữ thêm
        // ~220ms -> điều hướng. Tổng thời gian trước khi chuyển trang ~350ms.
        function pressThenNavigate(el, loadingTitle) {
            if (el.dataset.navigating === '1') return;
            el.dataset.navigating = '1';
            el.classList.add('is-pressed');
            // Khóa cả hai option ngay để chống double-click tạo nhiều request.
            [bcDirect, bcMatch].forEach(o => { o.setAttribute('aria-disabled', 'true'); o.style.pointerEvents = 'none'; });
            const href = el.href;
            const pressDelay = reduceMotion ? 0 : 130;
            const loaderDelay = reduceMotion ? 0 : 220;
            setTimeout(() => {
                el.classList.remove('is-pressed');
                showStepLoading(loadingTitle);
                setTimeout(() => {
                    window.location.assign(href);
                    // Fallback: nếu điều hướng không xảy ra (lỗi mạng/route) trong ~8s,
                    // ẩn loader, mở lại option và báo lỗi ngắn thay vì để màn hình treo.
                    clearTimeout(vsNavFallbackTimer);
                    vsNavFallbackTimer = setTimeout(function () {
                        window.vsHideStepLoading();
                        enableBookingOptions();
                        if (window.showHomeToast) window.showHomeToast('Không thể mở trang. Vui lòng thử lại.');
                    }, 8000);
                }, loaderDelay);
            }, pressDelay);
        }
        bcDirect.addEventListener('click', e => { e.preventDefault(); pressThenNavigate(bcDirect, bcDirect.dataset.loadingLabel); });
        bcMatch.addEventListener('click', e => { e.preventDefault(); pressThenNavigate(bcMatch, bcMatch.dataset.loadingLabel); });
        [bcDirect, bcMatch].forEach(el => {
            el.addEventListener('keydown', e => {
                if (e.key === ' ') { e.preventDefault(); el.click(); }
            });
        });

        // ================= Facility detail bottom sheet =====================
        const fsOverlay = document.getElementById('facilitySheetOverlay');
        const fsSheet = document.getElementById('facilitySheet');
        const fsSkeleton = document.getElementById('fsSkeleton');
        const fsErrorBox = document.getElementById('fsError');
        const fsContent = document.getElementById('fsContent');
        const shopCache = new Map();
        let fsOpen = false;
        let fsReturnFocus = null;
        let fsAbort = null;
        let fsShopAbort = null;
        let fsCurrentId = null;
        let fsCurrentName = '';
        let fsCurrentSportId = null;
        let fsCardImage = null;
        let fsCurrentPhone = null;
        let fsPushedState = false;

        // Real-time court detail polling for bottom sheet
        let fsPollTimer = null;
        function startFsPoll() {
            stopFsPoll();
            fsPollTimer = setInterval(function () {
                if (fsOpen && fsCurrentId && !document.hidden) {
                    loadFacilityDetail(fsCurrentId, true);
                }
            }, 10000);
        }
        function stopFsPoll() {
            if (fsPollTimer) { clearInterval(fsPollTimer); fsPollTimer = null; }
        }

        function openFacilitySheet(card) {
            const cosoId = card.getAttribute('data-coso-id');
            if (!cosoId) return;
            fsReturnFocus = card;
            fsCurrentId = cosoId;
            fsCurrentName = card.getAttribute('data-facility-name') || '';
            fsCurrentSportId = card.getAttribute('data-sport-id') || null;
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
            startFsPoll();
        }
        window.openFacilitySheet = openFacilitySheet;

        function closeFacilitySheet(fromPopstate) {
            if (!fsOpen) return;
            fsOpen = false;
            stopFsPoll();
            fsbkCloseStep2();
            if (fsAbort) { fsAbort.abort(); fsAbort = null; }
            if (fsShopAbort) { fsShopAbort.abort(); fsShopAbort = null; }
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

        function loadFacilityDetail(cosoId, isSilent) {
            if (!isSilent) showSheetState('loading');
            const sportId = fsCurrentSportId;
            if (fsAbort) fsAbort.abort();
            fsAbort = new AbortController();
            let apiUrl = CTX + '/api/customer/facilities/detail?coSoId=' + encodeURIComponent(cosoId) + '&_t=' + Date.now();
            if (sportId) apiUrl += '&sportId=' + encodeURIComponent(sportId);
            fetch(apiUrl, { signal: fsAbort.signal, cache: 'no-store' })
                .then(r => {
                    if (!r.ok) throw new Error('HTTP ' + r.status);
                    return r.json();
                })
                .then(data => {
                    if (fsOpen && fsCurrentId === cosoId) renderFacilityDetail(data);
                })
                .catch(err => {
                    if (err && err.name === 'AbortError') return;
                    if (fsOpen && fsCurrentId === cosoId && !isSilent) showSheetState('error');
                });
        }
        document.getElementById('fsRetryBtn').addEventListener('click', () => {
            if (fsCurrentId) {
                loadFacilityDetail(fsCurrentId);
            }
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
            // Build carousel from facility.images (falls back to single imageUrl or card image)
            let carouselImages = (Array.isArray(data.images) ? data.images : []).map(resolveImg).filter(Boolean);
            if (!carouselImages.length) {
                const s = resolveImg(data.imageUrl) || fsCardImage;
                if (s) carouselImages = [s];
            }
            carouselInit(carouselImages, data.tenCoSo || '');

            document.getElementById('fsName').textContent = data.tenCoSo || '';

            const chips = document.getElementById('fsChips');
            chips.textContent = '';
            if (typeof data.openNow === 'boolean') {
                chips.appendChild(el('span', 'vsfs-chip' + (data.openNow ? '' : ' is-warn'), data.openNow ? 'Đang mở' : 'Ngoài giờ mở cửa'));
            }
            if (typeof data.readyCourtCount === 'number' && data.readyCourtCount > 0) {
                chips.appendChild(el('span', 'vsfs-chip is-ready', 'Còn ' + data.readyCourtCount + ' sân sẵn sàng'));
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
            const ovHasCoords = typeof data.latitude === 'number' && typeof data.longitude === 'number'
                && (data.latitude !== 0 || data.longitude !== 0);
            const mapLink = el('a', 'vsfs-court-cta vsfs-cta-green', 'Xem trên bản đồ');
            mapLink.href = ovHasCoords
                ? CTX + '/customer/ban-do?facilityId=' + encodeURIComponent(fsCurrentId)
                : CTX + '/customer/ban-do';
            mapLink.style.marginTop = '14px';
            mapLink.style.display = 'inline-flex';
            ov.appendChild(mapLink);

            const ghepKeoLink = document.getElementById('fsGhepKeoLink');
            ghepKeoLink.href = CTX + '/customer/ghep-keo?tab=tao-keo&coSoId=' + encodeURIComponent(fsCurrentId || '');

            const courtsPanel = document.getElementById('fsCourtList');
            courtsPanel.textContent = '';
            fsbkCourts = Array.isArray(data.courts) ? data.courts : [];
            fsbkCloseStep2();
            if (fsbkCourts.length) {
                fsbkCourts.forEach(c => {
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
                    const cta = el('button', 'vsfs-court-cta', 'Đặt sân');
                    cta.type = 'button';
                    cta.addEventListener('click', () => fsbkOpenStep2(c));
                    right.appendChild(cta);
                    row.appendChild(right);
                    courtsPanel.appendChild(row);
                });
            } else {
                courtsPanel.appendChild(el('p', null, 'Thông tin này đang được cơ sở cập nhật.'));
            }

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

            renderPromotions(Array.isArray(data.activePromotions) ? data.activePromotions : []);

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

            const mapBtn = document.getElementById('fsMapBtn');
            const hasCoords = typeof data.latitude === 'number' && typeof data.longitude === 'number'
                && (data.latitude !== 0 || data.longitude !== 0);
            mapBtn.hidden = !hasCoords;
            mapBtn.href = CTX + '/customer/ban-do?facilityId=' + encodeURIComponent(fsCurrentId);

            const mapActionBtn = document.getElementById('fsMapActionBtn');
            if (mapActionBtn) {
                mapActionBtn.href = hasCoords
                    ? CTX + '/customer/ban-do?facilityId=' + encodeURIComponent(fsCurrentId)
                    : CTX + '/customer/ban-do';
                mapActionBtn.title = hasCoords ? '' : 'Cơ sở chưa cập nhật vị trí';
            }

            const callBtn = document.getElementById('fsCallBtn');
            callBtn.hidden = !data.phone;
            if (data.phone) callBtn.href = 'tel:' + String(data.phone).replace(/[^+\d]/g, '');
            fsCurrentPhone = data.phone || null;

            // Tab Cửa hàng chỉ hiện khi backend xác nhận capability đã duyệt. Sản phẩm
            // thật được lazy-load riêng (loadShopProducts) khi Customer bấm vào tab -
            // không tải kèm ở đây để tránh phí request cho cơ sở không bán hàng.
            document.getElementById('fsTab-shop').hidden = !data.shopAvailable;

            selectSheetTab('overview');
            showSheetState('content');
        }

        // ---- Cửa hàng (Phase 4, lazy-loaded) --------------------------------
        function showShopState(state) {
            document.getElementById('fsShopLoading').hidden = state !== 'loading';
            document.getElementById('fsShopEmpty').hidden = state !== 'empty';
            document.getElementById('fsShopError').hidden = state !== 'error';
            document.getElementById('fsShopGrid').hidden = state !== 'content';
        }

        function loadShopProducts(cosoId) {
            if (shopCache.has(cosoId)) {
                renderShopProducts(shopCache.get(cosoId));
                return;
            }
            showShopState('loading');
            if (fsShopAbort) fsShopAbort.abort();
            fsShopAbort = new AbortController();
            fetch(CTX + '/api/customer/facilities/shop?coSoId=' + encodeURIComponent(cosoId), { signal: fsShopAbort.signal })
                .then(r => { if (!r.ok) throw new Error('HTTP ' + r.status); return r.json(); })
                .then(data => {
                    shopCache.set(cosoId, data);
                    if (fsOpen && fsCurrentId === cosoId) renderShopProducts(data);
                })
                .catch(err => {
                    if (err && err.name === 'AbortError') return;
                    if (fsOpen && fsCurrentId === cosoId) showShopState('error');
                });
        }
        document.getElementById('fsShopRetryBtn').addEventListener('click', () => {
            if (fsCurrentId) { shopCache.delete(fsCurrentId); loadShopProducts(fsCurrentId); }
        });

        const STOCK_LABEL = { CON_HANG: 'Còn hàng', SAP_HET: 'Sắp hết hàng', HET_HANG: 'Hết hàng' };
        const STOCK_CLASS = { CON_HANG: 'is-in', SAP_HET: 'is-low', HET_HANG: 'is-out' };
        const IC_BAG = 'M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4Z|M3 6h18|M16 10a4 4 0 0 1-8 0';

        function renderShopProducts(data) {
            const products = (data && Array.isArray(data.products)) ? data.products : [];
            const grid = document.getElementById('fsShopGrid');
            grid.textContent = '';
            if (!data || !data.available) { showShopState('empty'); return; }
            if (!products.length) { showShopState('empty'); return; }

            products.forEach(p => {
                const card = el('div', 'vsfs-product');

                const imgWrap = el('div', 'vsfs-product-img');
                const imgSrc = resolveImg(p.image);
                if (imgSrc) {
                    const img = document.createElement('img');
                    img.loading = 'lazy';
                    img.alt = p.name || '';
                    img.onerror = function () { this.remove(); imgWrap.appendChild(bagIcon()); };
                    img.src = imgSrc;
                    imgWrap.appendChild(img);
                } else {
                    imgWrap.appendChild(bagIcon());
                }
                card.appendChild(imgWrap);

                const body = el('div', 'vsfs-product-body');
                if (p.category) body.appendChild(el('span', 'vsfs-product-cat', p.category));
                body.appendChild(el('span', 'vsfs-product-name', p.name || ''));
                const stockKey = STOCK_LABEL[p.stockStatus] ? p.stockStatus : 'HET_HANG';
                body.appendChild(el('span', 'vsfs-product-stock ' + STOCK_CLASS[stockKey], STOCK_LABEL[stockKey]));
                const price = fmtVnd(p.price);
                if (price) body.appendChild(el('span', 'vsfs-product-price', price + (p.unit ? '/' + p.unit : '')));

                // Giai đoạn 1 (liên hệ mua tại cơ sở) - chưa có giỏ hàng/thanh toán online
                // thật, nên KHÔNG hiện nút "Mua ngay" giả. Chỉ đưa số điện thoại cơ sở.
                if (p.stockStatus !== 'HET_HANG') {
                    const contactBtn = document.createElement(fsCurrentPhone ? 'a' : 'span');
                    contactBtn.className = 'vsfs-product-contact';
                    contactBtn.textContent = fsCurrentPhone ? 'Liên hệ đặt mua' : 'Đến trực tiếp cơ sở để mua';
                    if (fsCurrentPhone) {
                        contactBtn.href = 'tel:' + String(fsCurrentPhone).replace(/[^+\d]/g, '');
                        contactBtn.setAttribute('aria-label', 'Gọi cơ sở để đặt mua ' + (p.name || 'sản phẩm này'));
                    }
                    body.appendChild(contactBtn);
                }
                card.appendChild(body);

                grid.appendChild(card);
            });
            showShopState('content');
        }

        // ---- Tab Ưu đãi -------------------------------------------------
        const IC_TICKET = 'M20 12v10H4V12|M2 7h20v5H2z|M12 22V7|M12 7H7.5a2.5 2.5 0 0 1 0-5C11 2 12 7 12 7z|M12 7h4.5a2.5 2.5 0 0 0 0-5C13 2 12 7 12 7z';
        const IC_COPY = 'M9 2h9a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2h-2M9 2H4a2 2 0 0 0-2 2v13a2 2 0 0 0 2 2h9a2 2 0 0 0 2-2v-2';
        const IC_CHEVRON_L = 'm15 18-6-6 6-6';
        const IC_CHEVRON_R = 'm9 18 6-6-6-6';
        const IC_IMG_OFF = 'M10.41 10.41a2 2 0 1 1-2.83-2.83|M4 4v16h16|M22 6.5 18.5 10l-4-4|M18.5 3 22 6.5';

        function svgIcon(pathData, extraAttrs) {
            const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
            svg.setAttribute('class', 'lci');
            svg.setAttribute('viewBox', '0 0 24 24');
            svg.setAttribute('fill', 'none');
            svg.setAttribute('stroke', 'currentColor');
            svg.setAttribute('stroke-width', '2');
            svg.setAttribute('stroke-linecap', 'round');
            svg.setAttribute('stroke-linejoin', 'round');
            svg.setAttribute('aria-hidden', 'true');
            if (extraAttrs) Object.keys(extraAttrs).forEach(k => svg.setAttribute(k, extraAttrs[k]));
            pathData.split('|').forEach(d => {
                const p = document.createElementNS('http://www.w3.org/2000/svg', 'path');
                p.setAttribute('d', d);
                svg.appendChild(p);
            });
            return svg;
        }

        function isPercentDiscount(loaiGiam) {
            if (!loaiGiam) return false;
            const v = String(loaiGiam).toUpperCase();
            return v.indexOf('PERCENT') >= 0 || v.indexOf('PHAN_TRAM') >= 0 || v.indexOf('PHANTRAM') >= 0 || v.indexOf('%') >= 0;
        }

        function discountLabel(promo) {
            const value = Number(promo.giaTriGiam);
            if (!isFinite(value) || value <= 0) return '';
            if (isPercentDiscount(promo.loaiGiam)) {
                const capped = fmtVnd(Number(promo.giamToiDa));
                return 'Giảm ' + value.toLocaleString('vi-VN', { maximumFractionDigits: 1 }) + '%' + (capped ? ', tối đa ' + capped : '');
            }
            return 'Giảm ' + fmtVnd(value);
        }

        function fmtDateVn(iso) {
            if (!iso) return null;
            const parts = String(iso).split('-');
            if (parts.length !== 3) return null;
            return parts[2] + '/' + parts[1] + '/' + parts[0];
        }

        function promoConditions(promo) {
            const parts = [];
            const minOrder = fmtVnd(Number(promo.giaTriToiThieu));
            if (minOrder) parts.push('Đơn tối thiểu ' + minOrder);
            const endDate = fmtDateVn(promo.ngayKetThuc);
            if (endDate) parts.push('Hết hạn ' + endDate);
            return parts;
        }

        function copyPromoCode(code, btn) {
            const done = () => showHomeToast('Đã sao chép mã ' + code);
            if (navigator.clipboard) {
                navigator.clipboard.writeText(code).then(done).catch(done);
            } else {
                done();
            }
        }

        // "Dùng mã này": lưu tạm mã (gắn đúng CoSoID) để bước Xác nhận đặt sân tự điền vào ô
        // khuyến mãi. Customer vẫn phải bấm "Áp dụng" ở bước đó (XacNhanDatSan.jsp đọc lại
        // ?promoCode= qua query string khi mở link đặt sân) - không tự tăng lượt dùng, không
        // tự tính discount, không đánh dấu USED ở đây.
        function usePromoCode(promo) {
            try {
                sessionStorage.setItem('vsPendingPromoCode', promo.maCode || '');
                sessionStorage.setItem('vsPendingPromoCoSoId', String(promo.coSoId || fsCurrentId || ''));
            } catch (e) { /* storage unavailable - vẫn tiếp tục, chỉ mất tiện ích prefill */ }
            showHomeToast('Đã chọn mã ' + (promo.maCode || '') + '. Mã sẽ được áp dụng ở bước xác nhận đặt sân.');
        }

        function renderPromotions(promotions) {
            const tab = document.getElementById('fsTab-promotions');
            const panel = document.getElementById('fsPanel-promotions');
            panel.textContent = '';
            tab.hidden = false; // luôn hiện tab, dùng empty-state rõ ràng khi rỗng thay vì ẩn tab

            if (!promotions.length) {
                panel.appendChild(el('p', 'vsfs-promo-empty', 'Cơ sở hiện chưa có chương trình ưu đãi.'));
                return;
            }

            const list = el('div', 'vsfs-promo-list');
            promotions.forEach(promo => renderOnePromotionCard(list, promo));
            panel.appendChild(list);
        }

        function renderOnePromotionCard(container, promo) {
            const card = el('div', 'vsfs-promo-card');

            const images = (Array.isArray(promo.images) ? promo.images : [])
                .slice(0, 5)
                .map(im => ({ url: resolveImg(im.url), isCover: !!im.isCover }))
                .filter(im => im.url);
            // Ảnh bìa luôn đứng đầu carousel.
            images.sort((a, b) => (b.isCover ? 1 : 0) - (a.isCover ? 1 : 0));
            if (!images.length && promo.coverImageUrl) {
                const cover = resolveImg(promo.coverImageUrl);
                if (cover) images.push({ url: cover, isCover: true });
            }

            const media = el('div', 'vsfs-promo-media');
            let slideIdx = 0;
            let autoTimer = null;

            function paintSlide() {
                media.querySelectorAll('img, .vsfs-promo-fallback').forEach(n => n.remove());
                if (!images.length) {
                    const fb = el('div', 'vsfs-promo-fallback');
                    fb.appendChild(svgIcon(IC_IMG_OFF));
                    fb.appendChild(el('span', null, 'Chưa có ảnh chương trình'));
                    media.insertBefore(fb, media.firstChild);
                    return;
                }
                const img = document.createElement('img');
                img.loading = 'lazy';
                img.alt = promo.moTa || 'Ảnh khuyến mãi';
                img.onerror = function () {
                    this.remove();
                    const fb = el('div', 'vsfs-promo-fallback');
                    fb.appendChild(svgIcon(IC_IMG_OFF));
                    fb.appendChild(el('span', null, 'Không tải được ảnh'));
                    media.insertBefore(fb, media.firstChild);
                };
                img.src = images[slideIdx].url;
                media.insertBefore(img, media.firstChild);
                const dots = media.querySelectorAll('.vsfs-promo-dot');
                dots.forEach((d, i) => d.classList.toggle('is-active', i === slideIdx));
            }

            function stopAuto() { if (autoTimer) { clearInterval(autoTimer); autoTimer = null; } }
            function goTo(idx) {
                slideIdx = (idx + images.length) % images.length;
                paintSlide();
            }

            if (images.length > 1) {
                const prevBtn = document.createElement('button');
                prevBtn.type = 'button';
                prevBtn.className = 'vsfs-promo-nav prev';
                prevBtn.setAttribute('aria-label', 'Ảnh trước');
                prevBtn.appendChild(svgIcon(IC_CHEVRON_L));
                prevBtn.addEventListener('click', () => { stopAuto(); goTo(slideIdx - 1); });

                const nextBtn = document.createElement('button');
                nextBtn.type = 'button';
                nextBtn.className = 'vsfs-promo-nav next';
                nextBtn.setAttribute('aria-label', 'Ảnh tiếp theo');
                nextBtn.appendChild(svgIcon(IC_CHEVRON_R));
                nextBtn.addEventListener('click', () => { stopAuto(); goTo(slideIdx + 1); });

                media.appendChild(prevBtn);
                media.appendChild(nextBtn);

                const dotsWrap = el('div', 'vsfs-promo-dots');
                images.forEach((_, i) => {
                    const dot = document.createElement('button');
                    dot.type = 'button';
                    dot.className = 'vsfs-promo-dot' + (i === 0 ? ' is-active' : '');
                    dot.setAttribute('aria-label', 'Ảnh ' + (i + 1));
                    dot.addEventListener('click', () => { stopAuto(); goTo(i); });
                    dotsWrap.appendChild(dot);
                });
                media.appendChild(dotsWrap);

                // Swipe (mobile) - pause autoplay khi người dùng tương tác.
                let touchStartX = null;
                media.addEventListener('touchstart', e => { touchStartX = e.touches[0].clientX; stopAuto(); }, { passive: true });
                media.addEventListener('touchend', e => {
                    if (touchStartX == null) return;
                    const dx = e.changedTouches[0].clientX - touchStartX;
                    if (Math.abs(dx) > 40) goTo(dx > 0 ? slideIdx - 1 : slideIdx + 1);
                    touchStartX = null;
                }, { passive: true });

                // Autoplay chậm, dừng khi tương tác - không autoplay quá nhanh.
                autoTimer = setInterval(() => goTo(slideIdx + 1), 5000);
            }

            const discount = discountLabel(promo);
            if (discount) {
                const badge = el('span', 'vsfs-promo-badge', discount);
                media.insertBefore(badge, media.firstChild);
            }
            paintSlide();
            card.appendChild(media);

            const body = el('div', 'vsfs-promo-body');
            body.appendChild(el('div', 'vsfs-promo-title', promo.moTa || 'Chương trình ưu đãi'));

            const codeRow = el('div', 'vsfs-promo-code-row');
            if (promo.maCode) {
                codeRow.appendChild(el('span', 'vsfs-promo-code', promo.maCode));
                const copyBtn = document.createElement('button');
                copyBtn.type = 'button';
                copyBtn.className = 'vsfs-promo-copy';
                copyBtn.appendChild(svgIcon(IC_COPY));
                copyBtn.appendChild(document.createTextNode('Sao chép'));
                copyBtn.addEventListener('click', () => copyPromoCode(promo.maCode, copyBtn));
                codeRow.appendChild(copyBtn);
            }
            if (codeRow.childNodes.length) body.appendChild(codeRow);

            const conds = promoConditions(promo);
            if (conds.length) {
                const condEl = el('div', 'vsfs-promo-condlist');
                conds.forEach(c => condEl.appendChild(el('span', null, c)));
                body.appendChild(condEl);
            }

            const endDate = fmtDateVn(promo.ngayKetThuc);
            if (endDate) {
                const daysLeft = Math.ceil((new Date(promo.ngayKetThuc) - new Date()) / 86400000);
                const status = el('span', 'vsfs-promo-status' + (daysLeft >= 0 && daysLeft <= 3 ? ' is-ending' : ''),
                    daysLeft >= 0 ? 'Còn hiệu lực' : 'Sắp hết hạn');
                body.appendChild(status);
            }

            const actions = el('div', 'vsfs-promo-actions');
            if (promo.maCode) {
                const useBtn = document.createElement('button');
                useBtn.type = 'button';
                useBtn.className = 'vsfs-promo-btn vsfs-promo-btn-use';
                useBtn.textContent = 'Dùng mã này';
                useBtn.addEventListener('click', () => usePromoCode(promo));
                actions.appendChild(useBtn);
            }
            const bookLink = document.createElement('button');
            bookLink.type = 'button';
            bookLink.className = 'vsfs-promo-btn vsfs-promo-btn-book';
            bookLink.textContent = 'Đặt sân';
            bookLink.addEventListener('click', () => { usePromoCode(promo); selectSheetTab('courts'); });
            actions.appendChild(bookLink);
            body.appendChild(actions);

            card.appendChild(body);
            container.appendChild(card);
        }

        function bagIcon() {
            const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
            svg.setAttribute('class', 'lci');
            svg.setAttribute('viewBox', '0 0 24 24');
            svg.setAttribute('fill', 'none');
            svg.setAttribute('stroke', 'currentColor');
            svg.setAttribute('stroke-width', '2');
            svg.setAttribute('stroke-linecap', 'round');
            svg.setAttribute('stroke-linejoin', 'round');
            svg.setAttribute('aria-hidden', 'true');
            IC_BAG.split('|').forEach(d => {
                const p = document.createElementNS('http://www.w3.org/2000/svg', 'path');
                p.setAttribute('d', d);
                svg.appendChild(p);
            });
            return svg;
        }

        // ---- Tabs -----------------------------------------------------------
        const tabButtons = Array.from(document.querySelectorAll('.vsfs-tab'));
        function selectSheetTab(key) {
            tabButtons.forEach(btn => {
                const selected = btn.getAttribute('data-fstab') === key;
                btn.setAttribute('aria-selected', selected ? 'true' : 'false');
                document.getElementById('fsPanel-' + btn.getAttribute('data-fstab')).hidden = !selected;
            });
            if (key === 'shop' && fsCurrentId) loadShopProducts(fsCurrentId);
        }
        window.selectSheetTab = selectSheetTab;
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
            const url = window.location.origin + CTX + '/customer/dat-lich-truc-quan?coSoId=' + encodeURIComponent(fsCurrentId || '');
            if (navigator.clipboard) {
                navigator.clipboard.writeText(url)
                    .then(() => showHomeToast('Đã sao chép liên kết chia sẻ cơ sở ' + fsCurrentName))
                    .catch(() => showHomeToast('Không thể sao chép liên kết'));
            } else {
                showHomeToast('Trình duyệt không hỗ trợ sao chép liên kết');
            }
        });
        document.getElementById('fsBookBtn').addEventListener('click', function () {
            // Was: close sheet → reopen "Chọn hình thức đặt" modal. Now: the sheet is already
            // open on this facility, just jump straight to the booking tab.
            selectSheetTab('courts');
            document.getElementById('fsTab-courts').scrollIntoView({ block: 'nearest', inline: 'center' });
        });

        // ---- Login-required modal ------------------------------------------
        const vslrModal = document.getElementById('vsLoginRequiredModal');
        if (vslrModal) {
            function closeLoginRequired() {
                vslrModal.classList.remove('is-open');
                setTimeout(() => { vslrModal.hidden = true; }, 210);
                unlockScroll();
            }
            document.getElementById('vslrCancelBtn').addEventListener('click', closeLoginRequired);
            vslrModal.addEventListener('click', e => { if (e.target === vslrModal) closeLoginRequired(); });
            vslrModal.addEventListener('keydown', e => {
                if (e.key === 'Escape') closeLoginRequired();
                trapTab(vslrModal, e);
            });
        }

        // ---- Escape closes topmost layer -----------------------------------
        document.addEventListener('keydown', e => {
            if (e.key !== 'Escape') return;
            if (vslrModal && !vslrModal.hidden) { document.getElementById('vslrCancelBtn').click(); return; }
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
                    // Was: openBookingChoice(...) → "Chọn hình thức đặt" modal → DatLichTrucQuan.jsp
                    // full-page nav. Now: open the bottom sheet directly on the booking tab.
                    openFacilitySheet(bookBtn);
                    selectSheetTab('courts');
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

        // ---- Hero Carousel --------------------------------------------------
        let _carouselImages = [], _carouselIdx = 0, _carouselTimer = null;

        function carouselInit(images, alt) {
            clearInterval(_carouselTimer);
            _carouselImages = images;
            _carouselIdx = 0;
            const track = document.getElementById('fsCarouselTrack');
            const dots = document.getElementById('fsDots');
            const prev = document.getElementById('fsPrev');
            const next = document.getElementById('fsNext');
            track.innerHTML = '';
            dots.innerHTML = '';
            if (!images.length) {
                const ph = document.createElement('img');
                ph.src = '';
                ph.alt = alt;
                ph.style.background = '#eef4f1';
                track.appendChild(ph);
                prev.hidden = next.hidden = true;
                return;
            }
            images.forEach((src, i) => {
                const img = document.createElement('img');
                img.loading = i === 0 ? 'eager' : 'lazy';
                img.alt = alt;
                img.src = src;
                img.onerror = function () { this.style.visibility = 'hidden'; };
                track.appendChild(img);
                const dot = document.createElement('span');
                dot.className = 'vsfs-dot' + (i === 0 ? ' active' : '');
                dot.onclick = () => carouselGo(i);
                dots.appendChild(dot);
            });
            prev.hidden = next.hidden = images.length < 2;
            if (images.length > 1) {
                _carouselTimer = setInterval(() => carouselMove(1), 4500);
            }
        }

        function carouselGo(idx) {
            _carouselIdx = (idx + _carouselImages.length) % _carouselImages.length;
            document.getElementById('fsCarouselTrack').style.transform = 'translateX(-' + _carouselIdx * 100 + '%)';
            document.querySelectorAll('#fsDots .vsfs-dot').forEach((d, i) => d.classList.toggle('active', i === _carouselIdx));
        }
        window.carouselMove = function(dir) { carouselGo(_carouselIdx + dir); };

        // ==========================================================================
        // Đặt lịch trực tiếp — ported from customer/DatLichTrucQuan.jsp (step 2 only;
        // court picking is now the existing "Sân & bảng giá" list above). Same APIs,
        // same submit target, restyled with fsbk-* classes. See Task #7 in
        // memory/vsport-customer-redesign-brief.md for context.
        // ==========================================================================
        var FSBK_SLOT_MIN = 30, FSBK_MIN_DUR = 30, FSBK_MAX_DUR = 240, FSBK_MAX_AHEAD = 30;
        var fsbkCourts = [];
        var fsbkState = {
            court: null, date: null, openMin: 0, closeMin: 0, nowMinutes: -1,
            selectedStart: null, selectedEnd: null, priceResult: null,
            abortCtrl: null, priceAbort: null, pendingSubmit: false
        };

        function fsbkTodayStr() {
            var d = new Date();
            return d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0') + '-' + String(d.getDate()).padStart(2, '0');
        }
        function fsbkHhmmToMin(s) { var p = s.split(':'); return (+p[0]) * 60 + (+p[1]); }
        function fsbkMinToHhmm(m) { return String(Math.floor(m / 60)).padStart(2, '0') + ':' + String(m % 60).padStart(2, '0'); }
        function fsbkFmtDur(mins) { return Math.floor(mins / 60) + 'h' + String(mins % 60).padStart(2, '0'); }

        var fsbkStep2El = document.getElementById('fsBookStep2');
        var fsbkDateInput = document.getElementById('fsbkDateInput');

        function fsbkOpenStep2(court) {
            fsbkState.court = court;
            fsbkState.date = fsbkState.date || fsbkTodayStr();
            fsbkState.selectedStart = null; fsbkState.selectedEnd = null; fsbkState.priceResult = null;
            document.getElementById('fsCourtList').hidden = true;
            document.getElementById('fsGhepKeoLink').hidden = true;
            fsbkStep2El.hidden = false;
            document.getElementById('fsbkCourtName').textContent = court.tenSan || ('Sân #' + court.sanId);
            document.getElementById('fsbkCourtPrice').textContent = court.giaKhongDen ? fmtVnd(court.giaKhongDen) + '/giờ' : '';
            fsbkDateInput.value = fsbkState.date;
            fsbkDateInput.min = fsbkTodayStr();
            var maxD = new Date(); maxD.setDate(maxD.getDate() + FSBK_MAX_AHEAD);
            fsbkDateInput.max = maxD.getFullYear() + '-' + String(maxD.getMonth() + 1).padStart(2, '0') + '-' + String(maxD.getDate()).padStart(2, '0');
            document.getElementById('fsbkPrevDay').disabled = (fsbkState.date === fsbkTodayStr());
            fsbkLoadAvailability();
            fsbkUpdateSummary();
        }

        function fsbkCloseStep2() {
            if (fsbkState.abortCtrl) { fsbkState.abortCtrl.abort(); fsbkState.abortCtrl = null; }
            if (fsbkState.priceAbort) { fsbkState.priceAbort.abort(); fsbkState.priceAbort = null; }
            fsbkState.court = null; fsbkState.date = null;
            fsbkState.selectedStart = null; fsbkState.selectedEnd = null; fsbkState.priceResult = null;
            fsbkState.pendingSubmit = false;
            if (fsbkStep2El) fsbkStep2El.hidden = true;
            var list = document.getElementById('fsCourtList');
            if (list) list.hidden = false;
            var ghepKeoLink = document.getElementById('fsGhepKeoLink');
            if (ghepKeoLink) ghepKeoLink.hidden = false;
        }
        document.getElementById('fsbkBackBtn').addEventListener('click', fsbkCloseStep2);

        function fsbkChangeDate(deltaOrValue) {
            var s;
            if (typeof deltaOrValue === 'number') {
                var nd = new Date(fsbkState.date + 'T00:00:00');
                nd.setDate(nd.getDate() + deltaOrValue);
                s = nd.getFullYear() + '-' + String(nd.getMonth() + 1).padStart(2, '0') + '-' + String(nd.getDate()).padStart(2, '0');
            } else {
                s = deltaOrValue;
            }
            if (s < fsbkDateInput.min || s > fsbkDateInput.max) return;
            fsbkState.date = s; fsbkDateInput.value = s;
            fsbkState.selectedStart = null; fsbkState.selectedEnd = null; fsbkState.priceResult = null;
            document.getElementById('fsbkPrevDay').disabled = (s === fsbkTodayStr());
            fsbkLoadAvailability();
            fsbkUpdateSummary();
        }
        document.getElementById('fsbkPrevDay').addEventListener('click', () => fsbkChangeDate(-1));
        document.getElementById('fsbkNextDay').addEventListener('click', () => fsbkChangeDate(1));
        fsbkDateInput.addEventListener('change', function () {
            if (!this.value) return;
            fsbkChangeDate(this.value);
        });
        document.getElementById('fsbkTlRetry').addEventListener('click', fsbkLoadAvailability);

        function fsbkLoadAvailability() {
            if (!fsCurrentId || !fsbkState.court) return;
            if (fsbkState.abortCtrl) fsbkState.abortCtrl.abort();
            fsbkState.abortCtrl = new AbortController();
            document.getElementById('fsbkTlLoading').hidden = false;
            document.getElementById('fsbkTlError').hidden = true;
            document.getElementById('fsbkTlEmpty').hidden = true;
            document.getElementById('fsbkTl').hidden = true;
            fetch(CTX + '/customer/api/timetable-availability?coSoId=' + encodeURIComponent(fsCurrentId) + '&date=' + encodeURIComponent(fsbkState.date),
                { signal: fsbkState.abortCtrl.signal, headers: { 'Accept': 'application/json' }, cache: 'no-store' })
                .then(r => { if (!r.ok) throw new Error('HTTP ' + r.status); return r.json(); })
                .then(data => {
                    if (!data.success) throw new Error(data.error || 'load-failed');
                    fsbkState.openMin = fsbkHhmmToMin(data.openTime);
                    fsbkState.closeMin = fsbkHhmmToMin(data.closeTime);
                    fsbkState.nowMinutes = data.nowMinutes;
                    var courts = data.courts || [];
                    var match = courts.find(c => c.sanId == fsbkState.court.sanId);
                    document.getElementById('fsbkTlLoading').hidden = true;
                    if (!match || !match.slots || !match.slots.length) {
                        document.getElementById('fsbkTlEmpty').hidden = false;
                        return;
                    }
                    fsbkState.court.slots = match.slots;
                    fsbkRenderTimeline(match);
                })
                .catch(err => {
                    if (err && err.name === 'AbortError') return;
                    document.getElementById('fsbkTlLoading').hidden = true;
                    document.getElementById('fsbkTlError').hidden = false;
                });
        }

        function fsbkRenderTimeline(court) {
            var tl = document.getElementById('fsbkTl');
            tl.hidden = false;
            tl.innerHTML = '';
            var slotCount = Math.floor((fsbkState.closeMin - fsbkState.openMin) / FSBK_SLOT_MIN);
            if (!slotCount) { tl.hidden = true; document.getElementById('fsbkTlEmpty').hidden = false; return; }

            var head = document.createElement('div');
            head.className = 'fsbk-tl-head';
            for (var i = 0; i < slotCount; i++) {
                var min = fsbkState.openMin + i * FSBK_SLOT_MIN;
                var hc = document.createElement('div');
                hc.className = 'fsbk-tl-head-cell';
                if (min % 60 === 0) { hc.classList.add('is-hour'); hc.textContent = fsbkMinToHhmm(min); }
                else { hc.style.color = '#c4c9d4'; hc.textContent = ':' + String(min % 60).padStart(2, '0'); }
                fsbkAddNowMarker(hc, min, FSBK_SLOT_MIN);
                head.appendChild(hc);
            }
            tl.appendChild(head);

            var row = document.createElement('div');
            row.className = 'fsbk-tl-row';
            var j = 0;
            while (j < court.slots.length) {
                var slot = court.slots[j];
                if (slot.status === 'AVAILABLE') { row.appendChild(fsbkBuildAvailSlot(court, slot)); j++; }
                else {
                    var k = j + 1;
                    while (k < court.slots.length && court.slots[k].status === slot.status) k++;
                    row.appendChild(fsbkBuildBlockedRun(court, court.slots.slice(j, k)));
                    j = k;
                }
            }
            tl.appendChild(row);
            if (fsbkState.selectedStart != null) fsbkRefreshSelVis();
        }

        function fsbkAddNowMarker(cell, startMin, spanMin) {
            if (fsbkState.nowMinutes < startMin || fsbkState.nowMinutes >= startMin + spanMin) return;
            var m = document.createElement('div');
            m.className = 'fsbk-now-marker';
            m.style.left = ((fsbkState.nowMinutes - startMin) / spanMin * 100) + '%';
            cell.appendChild(m);
        }

        function fsbkBuildAvailSlot(court, slot) {
            var cell = document.createElement('div');
            cell.className = 'fsbk-slot';
            if (slot.startMinute % 60 === 0) cell.classList.add('is-hour');
            cell.dataset.start = slot.start; cell.dataset.end = slot.end;
            cell.dataset.startMinute = slot.startMinute; cell.dataset.status = slot.status;
            cell.setAttribute('role', 'button'); cell.setAttribute('tabindex', '0');
            cell.addEventListener('click', () => fsbkOnSlotClick(slot));
            cell.addEventListener('keydown', e => { if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); fsbkOnSlotClick(slot); } });
            fsbkAddNowMarker(cell, slot.startMinute, FSBK_SLOT_MIN);
            return cell;
        }

        function fsbkBuildBlockedRun(court, run) {
            var first = run[0], last = run[run.length - 1], span = run.length;
            var cell = document.createElement('div');
            var st = first.status.toLowerCase();
            cell.className = 'fsbk-slot is-blocked is-' + st;
            if (span > 1) cell.classList.add('is-merged');
            if (first.startMinute % 60 === 0) cell.classList.add('is-hour');
            cell.style.width = 'calc(var(--fsbk-slot-w) * ' + span + ')'; cell.style.flexShrink = '0';
            cell.dataset.startMinute = first.startMinute; cell.dataset.status = first.status;
            var statusTxt = fsbkStatusLabel(first.status);
            cell.title = statusTxt + ' · ' + first.start + '–' + last.end;
            if (span >= 2) {
                var lbl = document.createElement('span'); lbl.className = 'fsbk-slot-label';
                lbl.textContent = span >= 3 ? (statusTxt + ' · ' + first.start + '–' + last.end) : statusTxt;
                cell.appendChild(lbl);
            }
            if (first.status === 'HOLD_SELF' && first.datSanId) {
                cell.style.cursor = 'pointer';
                cell.addEventListener('click', () => { window.location.href = CTX + '/customer/thanh-toan-qr?datSanId=' + first.datSanId; });
            }
            fsbkAddNowMarker(cell, first.startMinute, span * FSBK_SLOT_MIN);
            return cell;
        }

        function fsbkStatusLabel(s) {
            switch (s) {
                case 'AVAILABLE': return 'Trống';
                case 'BOOKED': return 'Đã đặt';
                case 'HOLD': return 'Đang giữ';
                case 'HOLD_SELF': return 'Chờ thanh toán';
                case 'LOCKED': return 'Khóa';
                case 'PAST': return 'Đã qua';
                default: return s;
            }
        }

        function fsbkCheckContiguous(from, to) {
            var court = fsbkState.court;
            if (!court || !court.slots) return false;
            for (var m = from; m < to; m += FSBK_SLOT_MIN) {
                var s = court.slots.find(sl => sl.startMinute === m);
                if (!s || s.status !== 'AVAILABLE') return false;
            }
            return true;
        }
        function fsbkIsSelValid(s, e) { return fsbkCheckContiguous(s, e) && (e - s) >= FSBK_SLOT_MIN; }

        function fsbkOnSlotClick(slot) {
            if (slot.status !== 'AVAILABLE') {
                if (slot.status === 'HOLD_SELF' && slot.datSanId) { window.location.href = CTX + '/customer/thanh-toan-qr?datSanId=' + slot.datSanId; return; }
                var msg = 'Khung giờ này không khả dụng.';
                if (slot.status === 'BOOKED') msg = 'Khung giờ này đã được đặt.';
                else if (slot.status === 'HOLD') msg = 'Khung giờ đang được người khác giữ chỗ.';
                showHomeToast(msg);
                return;
            }
            var startM = slot.startMinute, endM = startM + FSBK_SLOT_MIN;
            if (fsbkState.selectedStart == null) { fsbkState.selectedStart = startM; fsbkState.selectedEnd = endM; }
            else if (startM >= fsbkState.selectedStart && startM < fsbkState.selectedEnd) {
                fsbkState.selectedEnd = startM;
                if (fsbkState.selectedEnd - fsbkState.selectedStart <= 0) { fsbkState.selectedStart = null; fsbkState.selectedEnd = null; fsbkState.priceResult = null; fsbkRefreshSelVis(); fsbkUpdateSummary(); return; }
            } else if (startM === fsbkState.selectedEnd) {
                if (fsbkCheckContiguous(fsbkState.selectedEnd, endM)) fsbkState.selectedEnd = endM;
                else { showHomeToast('Chỉ chọn các khung giờ liền nhau.'); return; }
            } else if (startM === fsbkState.selectedStart - FSBK_SLOT_MIN) {
                if (fsbkCheckContiguous(startM, fsbkState.selectedStart)) fsbkState.selectedStart = startM;
                else { showHomeToast('Chỉ chọn các khung giờ liền nhau.'); return; }
            } else { fsbkState.selectedStart = startM; fsbkState.selectedEnd = endM; }
            if (fsbkState.selectedEnd - fsbkState.selectedStart > FSBK_MAX_DUR) {
                fsbkState.selectedEnd = fsbkState.selectedStart + FSBK_MAX_DUR;
                showHomeToast('Tối đa ' + (FSBK_MAX_DUR / 60) + ' giờ. Đã tự cắt bớt.');
            }
            if (!fsbkIsSelValid(fsbkState.selectedStart, fsbkState.selectedEnd)) {
                showHomeToast('Khoảng chọn chứa giờ không khả dụng. Hãy chọn lại.');
                fsbkState.selectedStart = null; fsbkState.selectedEnd = null; fsbkState.priceResult = null;
                fsbkRefreshSelVis(); fsbkUpdateSummary(); return;
            }
            fsbkRefreshSelVis(); fsbkState.priceResult = null; fsbkUpdateSummary(); fsbkFetchPrice();
        }

        function fsbkRefreshSelVis() {
            document.querySelectorAll('.fsbk-slot').forEach(c => c.classList.remove('is-selected'));
            document.querySelectorAll('.fsbk-sel-label').forEach(l => l.remove());
            if (fsbkState.selectedStart == null) return;
            var startCell = null, cnt = 0;
            document.querySelectorAll('.fsbk-slot').forEach(c => {
                var m = parseInt(c.dataset.startMinute, 10);
                if (m >= fsbkState.selectedStart && m < fsbkState.selectedEnd) { c.classList.add('is-selected'); cnt++; if (m === fsbkState.selectedStart) startCell = c; }
            });
            if (startCell && cnt > 0) {
                var lbl = document.createElement('span'); lbl.className = 'fsbk-sel-label';
                lbl.textContent = fsbkMinToHhmm(fsbkState.selectedStart) + '–' + fsbkMinToHhmm(fsbkState.selectedEnd);
                lbl.style.width = 'calc(var(--fsbk-slot-w) * ' + cnt + ')';
                startCell.appendChild(lbl);
            }
        }

        function fsbkFetchPrice() {
            if (fsbkState.selectedStart == null) { fsbkState.priceResult = null; fsbkUpdateSummary(); return; }
            if (fsbkState.priceAbort) fsbkState.priceAbort.abort();
            fsbkState.priceAbort = new AbortController();
            var p = new URLSearchParams();
            p.set('sanId', fsbkState.court.sanId); p.set('date', fsbkState.date);
            p.set('start', fsbkMinToHhmm(fsbkState.selectedStart)); p.set('end', fsbkMinToHhmm(fsbkState.selectedEnd));
            fetch(CTX + '/customer/api/timetable-price?' + p.toString(), { signal: fsbkState.priceAbort.signal, headers: { 'Accept': 'application/json' } })
                .then(r => r.json())
                .then(data => {
                    if (!data.success) { fsbkState.priceResult = null; showHomeToast(data.error || 'Không thể tính giá.'); }
                    else fsbkState.priceResult = data;
                    fsbkUpdateSummary();
                })
                .catch(err => { if (err && err.name === 'AbortError') return; fsbkState.priceResult = null; fsbkUpdateSummary(); });
        }

        function fsbkSetCta(disabled, label) {
            var btn = document.getElementById('fsbkSubmitBtn');
            btn.disabled = disabled;
            document.getElementById('fsbkSubmitLabel').textContent = label;
        }

        function fsbkUpdateSummary() {
            var dur = (fsbkState.selectedStart != null) ? fsbkState.selectedEnd - fsbkState.selectedStart : 0;
            document.getElementById('fsbkDuration').textContent = dur ? fsbkFmtDur(dur) : '0h00';
            if (dur <= 0) {
                document.getElementById('fsbkTotal').textContent = '0 đ';
                fsbkSetCta(true, 'Chọn khung giờ để tiếp tục');
                return;
            }
            if (dur < FSBK_MIN_DUR) {
                document.getElementById('fsbkTotal').textContent = '0 đ';
                fsbkSetCta(true, 'Chọn thêm thời gian');
                return;
            }
            if (fsbkState.priceResult) {
                document.getElementById('fsbkTotal').textContent = fmtVnd(parseFloat(fsbkState.priceResult.totalAmount)) || '0 đ';
                fsbkSetCta(fsbkState.pendingSubmit, fsbkState.pendingSubmit ? 'Đang kiểm tra lịch...' : 'Đặt sân ngay');
            } else {
                document.getElementById('fsbkTotal').textContent = '...';
                fsbkSetCta(true, 'Đang tính giá...');
            }
        }

        document.getElementById('fsbkForm').addEventListener('submit', function (e) {
            if (fsbkState.pendingSubmit) { e.preventDefault(); return; }
            if (fsbkState.selectedStart == null) { e.preventDefault(); showHomeToast('Vui lòng chọn khung giờ.'); return; }
            document.getElementById('fsbkInputCoSoId').value = fsCurrentId;
            document.getElementById('fsbkInputSanId').value = fsbkState.court.sanId;
            document.getElementById('fsbkInputNgayDat').value = fsbkState.date;
            document.getElementById('fsbkInputGioBatDau').value = fsbkMinToHhmm(fsbkState.selectedStart);
            document.getElementById('fsbkInputGioKetThuc').value = fsbkMinToHhmm(fsbkState.selectedEnd);
            fsbkState.pendingSubmit = true;
            fsbkSetCta(true, 'Đang kiểm tra lịch...');
        });

    })();
</script>
