<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%
    if (request.getAttribute("dsSan") == null) {
        response.sendRedirect(request.getContextPath() + "/customer/dat-san");
        return;
    }
%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi" class="scroll-smooth">
<head>
    <title>Tìm Sân - V-SPORT Elite Arena</title>
    <jsp:include page="/common/head.jsp" />
    <jsp:include page="/customer/common/vsport-theme.jsp" />
    <script id="tailwind-config">
        tailwind.config = {
          darkMode: "class",
          theme: {
            extend: {
              "colors": {
                      "on-surface-variant": "#444936",
                      "outline": "#757964",
                      "on-primary": "#ffffff",
                      "surface-tint": "#e3000f",
                      "on-error-container": "#93000a",
                      "inverse-primary": "#c2000d",
                      "secondary-fixed-dim": "#c6c6c7",
                      "error-container": "#ffdad6",
                      "on-secondary-fixed-variant": "#454747",
                      "on-secondary-fixed": "#1a1c1c",
                      "primary": "#e3000f",
                      "secondary-fixed": "#e2e2e2",
                      "on-secondary-container": "#616363",
                      "on-tertiary": "#ffffff",
                      "on-primary-fixed-variant": "#111111",
                      "surface-variant": "#e0e3e5",
                      "surface-dim": "#d8dadc",
                      "inverse-on-surface": "#eff1f3",
                      "surface-bright": "#f7f9fb",
                      "tertiary-fixed-dim": "#bcc7de",
                      "secondary": "#5d5f5f",
                      "background": "#faf9fd",
                      "tertiary-fixed": "#d8e3fb",
                      "on-surface": "#191c1e",
                      "tertiary": "#545f73",
                      "on-primary-container": "#111111",
                      "on-primary-fixed": "#000000",
                      "inverse-surface": "#2d3133",
                      "on-tertiary-fixed": "#111c2d",
                      "surface-container-lowest": "#ffffff",
                      "outline-variant": "#c5c9b0",
                      "tertiary-container": "#a1acc3",
                      "secondary-container": "#dfe0e0",
                      "on-background": "#191c1e",
                      "surface": "#faf9fd",
                      "on-secondary": "#ffffff",
                      "surface-container-highest": "#e0e3e5",
                      "surface-container": "#eceef0",
                      "primary-fixed-dim": "#c2000d",
                      "surface-container-high": "#e6e8ea",
                      "surface-container-low": "#f2f4f6",
                      "primary-fixed": "#ffe5e6",
                      "on-tertiary-fixed-variant": "#3c475a",
                      "on-tertiary-container": "#354053",
                      "error": "#ba1a1a",
                      "primary-container": "#e3000f",
                      "on-error": "#ffffff"
              },
              "borderRadius": {
                      "DEFAULT": "0.25rem",
                      "lg": "0.5rem",
                      "xl": "0.75rem",
                      "full": "9999px"
              },
              "spacing": {
                      "xs": "8px",
                      "lg": "40px",
                      "sm": "16px",
                      "margin-desktop": "48px",
                      "margin-mobile": "16px",
                      "xl": "64px",
                      "gutter": "24px",
                      "base": "4px",
                      "md": "24px"
              },
              "fontFamily": {
                      "headline-lg-mobile": ["Barlow Condensed", "sans-serif"],
                      "body-lg": ["Barlow", "sans-serif"],
                      "body-md": ["Barlow", "sans-serif"],
                      "headline-lg": ["Barlow Condensed", "sans-serif"],
                      "label-md": ["Barlow", "sans-serif"],
                      "label-sm": ["Barlow", "sans-serif"],
                      "headline-md": ["Barlow Condensed", "sans-serif"],
                      "display": ["Barlow Condensed", "sans-serif"]
              },
              "fontSize": {
                      "headline-lg-mobile": ["24px", {"lineHeight": "32px", "fontWeight": "700"}],
                      "body-lg": ["18px", {"lineHeight": "28px", "fontWeight": "400"}],
                      "body-md": ["16px", {"lineHeight": "24px", "fontWeight": "400"}],
                      "headline-lg": ["32px", {"lineHeight": "40px", "letterSpacing": "-0.01em", "fontWeight": "700"}],
                      "label-md": ["14px", {"lineHeight": "20px", "fontWeight": "600"}],
                      "label-sm": ["12px", {"lineHeight": "16px", "fontWeight": "500"}],
                      "headline-md": ["24px", {"lineHeight": "32px", "fontWeight": "600"}],
                      "display": ["48px", {"lineHeight": "56px", "letterSpacing": "-0.02em", "fontWeight": "800"}]
              }
            },
          }
        }
    </script>
    <style>
        body { font-family: 'Barlow', 'Inter', sans-serif; background-color: #faf9fd; color: #111111; }
        .ambient-shadow { box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05); }
        .hover-lift:hover { transform: translateY(-2px); box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1); }
        .search-input:focus { border-color: #c2000d; box-shadow: 0 0 0 2px var(--vs-focus-ring, rgba(24, 200, 232, 0.35)); }
        .booking-hero {
            background:
                radial-gradient(circle at 12% 8%, rgba(24, 200, 232, 0.16) 0, rgba(24, 200, 232, 0) 30%),
                radial-gradient(circle at 88% 0%, rgba(22, 119, 210, 0.10) 0, rgba(22, 119, 210, 0) 28%),
                linear-gradient(180deg, #f4f3f7 0%, #ffffff 42%, #ffffff 100%);
        }
        .hero-shell {
            box-shadow: 0 22px 60px rgba(26, 28, 30, 0.08);
        }
        .booking-select,
        .booking-date-input {
            width: 100%;
            background: transparent;
            border: none;
            outline: none;
            color: #191c1e;
            font-size: 0.95rem;
            font-weight: 600;
        }
        .booking-date-input::-webkit-calendar-picker-indicator {
            opacity: 0.7;
            cursor: pointer;
        }
        .results-shell {
            background: linear-gradient(180deg, #f4f3f7 0%, #faf9fd 20%, #ffffff 100%);
        }
        .results-toolbar {
            box-shadow: 0 12px 34px rgba(17, 24, 39, 0.05);
        }
        .results-stat {
            color: #5d5f5f;
            font-size: 0.95rem;
            font-weight: 500;
        }
        .section-title {
            font-family: 'Barlow Condensed', sans-serif;
            font-size: 2.35rem;
            line-height: 1.1;
            font-weight: 700;
            color: #111111;
            text-transform: uppercase;
            letter-spacing: 0.01em;
        }
        .court-card {
            border: 1px solid #e3e2e6;
            border-radius: 0;
            overflow: hidden;
            background: #ffffff;
            box-shadow: none;
            transition: transform 0.28s ease, box-shadow 0.28s ease, border-color 0.28s ease;
        }
        .court-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 16px 38px rgba(26, 28, 30, 0.09);
            border-color: #0f0f0f;
        }
        .court-card-media::after {
            content: "";
            position: absolute;
            inset: 0;
            background: linear-gradient(180deg, rgba(0,0,0,0.04) 0%, rgba(0,0,0,0.24) 100%);
            pointer-events: none;
        }
        .court-card-status {
            backdrop-filter: blur(8px);
            border-radius: 0px !important;
        }
        .court-chip {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 4px 10px;
            border-radius: 0px;
            background: #ffffff;
            border: 1px solid #c5c9b0;
            color: #e3000f;
            font-size: 10px;
            font-weight: 700;
            line-height: 1;
            text-transform: uppercase;
            letter-spacing: 0.08em;
            font-family: 'Barlow Condensed', sans-serif;
        }
        .court-card-cta {
            background: #e3000f;
            color: #ffffff;
            border-radius: 0px !important;
            font-family: 'Barlow Condensed', sans-serif;
            text-transform: uppercase;
            letter-spacing: 0.08em;
            font-weight: 700;
            box-shadow: 0 4px 14px rgba(255, 138, 36, 0.28);
            transition: all 0.2s ease;
        }
        .court-card-cta:hover:not(:disabled) {
            background: #c2000d;
            color: #ffffff;
            transform: translateY(-1px);
            box-shadow: 0 6px 18px rgba(249, 115, 22, 0.4);
        }
        .court-card-cta:active:not(:disabled) {
            transform: scale(0.97);
        }
        
        /* Form inputs inside modals */
        .form-input {
            width: 100%; padding: 0.75rem 1rem;
            background-color: #ffffff; border: 1px solid #e3e2e6;
            border-radius: 0px; color: #111111;
            transition: all 0.2s ease; font-size: 0.9375rem;
            font-family: 'Barlow', sans-serif;
        }
        .form-input:focus {
            border-color: #c2000d; outline: none; background-color: #fff;
            box-shadow: none;
        }
        .form-label {
            display: block; font-size: 11px; font-weight: 700;
            font-family: 'Barlow Condensed', sans-serif;
            text-transform: uppercase; letter-spacing: 0.08em;
            color: #e3000f; margin-bottom: 0.4rem;
        }
        @keyframes shimmer { 100% { transform: translateX(100%); } }
        @keyframes slide-up-fade {
            0% { opacity: 0; transform: translateY(12px); }
            100% { opacity: 1; transform: translateY(0); }
        }

        /* Sport filter chips (results toolbar) */
        .chip-filter {
            padding: 8px 20px;
            border-radius: 0px;
            border: 1px solid #e0e3e5;
            background-color: #ffffff;
            color: #5f5e5e;
            font-size: 13px;
            font-weight: 700;
            white-space: nowrap;
            transition: all 0.15s ease;
            cursor: pointer;
            text-transform: uppercase;
            letter-spacing: 0.08em;
            font-family: 'Barlow Condensed', sans-serif;
        }
        .chip-filter:hover { border-color: #e3000f; color: #e3000f; }
        .chip-filter-active {
            background-color: #111111 !important;
            border-color: #111111 !important;
            color: #ffffff !important;
        }
        .chip-filter-active:hover { color: #ffffff !important; }
        .soft-panel {
            border: 1px solid #e3e2e6;
            background: #ffffff;
        }
        /* Custom Selects Style overrides */
        .custom-option {
            transition: all 0.15s ease;
            cursor: pointer;
        }
        .custom-option:hover {
            background-color: #f1f0f4;
            color: #e3000f !important;
        }
        .select-arrow {
            transition: transform 0.2s ease;
        }
        .rotate-180 {
            transform: rotate(180deg);
        }

        /* ===================== PayOS error alert (contextual, not full-bleed) ===================== */
        .payos-alert {
            display: flex; align-items: flex-start; gap: 12px;
            background: #FFF7F5; border: 1px solid #FFD1C7; border-left: 4px solid #F26A4B;
            border-radius: 12px; padding: 14px 16px; text-align: left;
        }
        .payos-alert .payos-alert-icon { width: 21px; height: 21px; flex-shrink: 0; color: #E4573D; margin-top: 1px; }
        .payos-alert-body { flex: 1; min-width: 0; }
        .payos-alert-title { font-size: 14.5px; font-weight: 700; color: var(--vs-primary-900, #111111); margin: 0 0 2px; }
        .payos-alert-desc { font-size: 13.5px; color: #6b5450; line-height: 1.5; margin: 0; }
        .payos-alert-actions { display: flex; flex-wrap: wrap; gap: 8px; margin-top: 10px; }
        .payos-alert-btn {
            display: inline-flex; align-items: center; gap: 6px; padding: 7px 14px; border-radius: 8px;
            font-size: 13px; font-weight: 700; cursor: pointer; border: 1px solid transparent;
            transition: background-color .15s ease, opacity .15s ease;
        }
        .payos-alert-btn:disabled { opacity: .6; cursor: not-allowed; }
        .payos-alert-btn.is-outline { background: #fff; color: var(--vs-primary-600, #e3000f); border-color: var(--vs-primary-600, #e3000f); }
        .payos-alert-btn.is-outline:hover { background: var(--vs-cyan-50, #F0FCFE); }
        .payos-alert-btn.is-primary { background: var(--vs-primary-600, #e3000f); color: #fff; }
        .payos-alert-btn.is-primary:hover { background: var(--vs-primary-700, #185A9D); }
        .payos-alert-close {
            width: 24px; height: 24px; flex-shrink: 0; border: none; background: transparent; cursor: pointer;
            color: #b08d88; border-radius: 6px; display: flex; align-items: center; justify-content: center;
        }
        .payos-alert-close:hover { background: rgba(242, 106, 75, .12); }
    </style>
</head>
<body class="bg-[#faf9fd] text-on-surface antialiased flex flex-col min-h-screen">

    <jsp:include page="/customer/common/vsport-header.jsp" />

    <main class="flex-grow">        <!-- Intro / Search Section (light, đồng bộ homepage) -->
        <section class="booking-hero w-full px-margin-mobile md:px-margin-desktop pt-20 pb-12 md:pt-24 md:pb-16 border-b border-outline-variant/30 bg-surface-container-low">
            <div class="max-w-[1180px] mx-auto flex flex-col items-center text-center">
                <span class="inline-flex items-center gap-1.5 bg-primary/10 text-primary text-[11px] font-bold uppercase tracking-[0.2em] px-4 py-1.5 rounded-none mb-4 font-['Barlow_Condensed']">
                    TÌM KIẾM SIÊU TỐC
                </span>
                <h1 class="font-['Barlow_Condensed'] text-[44px] md:text-[60px] leading-[1.0] font-bold tracking-tight uppercase text-on-surface mb-3">TÌM SÂN PHÙ HỢP VỚI LỊCH CỦA BẠN</h1>
                <p class="font-['Barlow'] text-sm md:text-base text-on-surface-variant mb-8 max-w-xl">Chọn môn thể thao, cơ sở và ngày chơi. Chúng tôi sẽ sắp xếp phần còn lại.</p>

                <!-- Alerts -->
                <c:if test="${not empty sessionScope.error}">
                    <c:choose>
                        <c:when test="${not empty sessionScope.errorCode && sessionScope.errorCode ne 'null'}">
                            <%-- Lỗi PayOS có phân loại: alert card gọn, đúng theme V-SPORT hiện tại. --%>
                            <div class="mb-4 w-full max-w-5xl payos-alert" id="payosAlert"
                                 data-datsanid="${sessionScope.errorDatSanId}"
                                 data-retryable="${sessionScope.errorRetryable}">
                                <svg class="payos-alert-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3Z"/><path d="M12 9v4"/><path d="M12 17h.01"/></svg>
                                <div class="payos-alert-body">
                                    <p class="payos-alert-title">Chưa thể khởi tạo thanh toán trực tuyến</p>
                                    <p class="payos-alert-desc" id="payosAlertDesc">${sessionScope.error}</p>
                                    <c:if test="${not empty sessionScope.errorDatSanId}">
                                        <div class="payos-alert-actions">
                                            <c:if test="${sessionScope.errorRetryable}">
                                                <button type="button" class="payos-alert-btn is-outline" id="payosRetryBtn">Thử lại</button>
                                            </c:if>
                                            <button type="button" class="payos-alert-btn is-primary" id="payosPayCounterBtn">Thanh toán tại quầy</button>
                                        </div>
                                    </c:if>
                                </div>
                                <button type="button" class="payos-alert-close" onclick="document.getElementById('payosAlert').remove();" aria-label="Đóng">
                                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg>
                                </button>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="mb-5 w-full max-w-5xl p-4 bg-red-50 border border-red-200 rounded-none text-red-700 text-sm flex items-start gap-3 text-left">
                                <span class="material-symbols-outlined text-[18px] shrink-0">error</span>
                                <span>${sessionScope.error}</span>
                            </div>
                        </c:otherwise>
                    </c:choose>
                    <% session.removeAttribute("error"); session.removeAttribute("errorCode");
                       session.removeAttribute("errorDatSanId"); session.removeAttribute("errorRetryable"); %>
                </c:if>
                <c:if test="${not empty sessionScope.message}">
                    <div class="mb-5 w-full max-w-5xl p-4 rounded-none text-sm flex items-start gap-3 text-left" style="background-color: var(--vs-success-bg, #E5F7EF); border: 1px solid var(--vs-success, #16A36A); color: var(--vs-success, #16A36A);">
                        <span class="material-symbols-outlined text-[18px] shrink-0">check_circle</span>
                        <span>${sessionScope.message}</span>
                        <% session.removeAttribute("message"); %>
                    </div>
                </c:if>

                <!-- Search bar nổi -->
                <div class="w-full max-w-5xl bg-white border border-outline-variant p-4 md:p-6 shadow-sm rounded-none">
                    <div class="grid grid-cols-1 gap-4 md:grid-cols-[1.1fr_1.1fr_0.9fr_auto] md:items-center">
                    
                    <!-- Custom Sport Select -->
                    <div class="relative custom-select-wrapper rounded-none border border-neutral-200 bg-white px-4 py-2 text-left hover:border-neutral-300 transition-colors cursor-pointer select-none" id="custom-sport-trigger">
                        <div class="mb-0.5 flex items-center gap-1.5 text-[10px] font-bold uppercase tracking-[0.15em] text-neutral-400 font-['Barlow_Condensed']">
                            <span class="material-symbols-outlined text-[16px] text-primary" id="custom-sport-icon">sports_tennis</span>
                            Bộ môn
                        </div>
                        <div class="flex items-center justify-between">
                            <span id="custom-sport-label" class="font-['Barlow'] font-semibold text-neutral-800 text-sm">Tất cả bộ môn</span>
                            <span class="material-symbols-outlined text-neutral-400 select-arrow text-[18px] transition-transform duration-200">expand_more</span>
                        </div>
                        <!-- Hidden real select -->
                        <select id="hero-sport-select" class="hidden">
                            <option value="0">Tất cả bộ môn</option>
                            <c:forEach var="mon" items="${dsMon}">
                                <option value="${mon.monTheThaoID}">${mon.tenMon}</option>
                            </c:forEach>
                        </select>
                        <!-- Custom options list -->
                        <div id="custom-sport-options" class="absolute top-[calc(100%+4px)] left-[-1px] right-[-1px] bg-white border border-neutral-200 shadow-xl z-50 hidden py-1">
                            <div class="custom-option px-4 py-2.5 text-xs font-bold uppercase tracking-wider text-neutral-600 hover:bg-neutral-50 flex items-center gap-2" data-value="0">
                                <span class="material-symbols-outlined text-[16px] text-neutral-400">sports_tennis</span>
                                Tất cả bộ môn
                            </div>
                            <c:forEach var="mon" items="${dsMon}">
                                <c:set var="spIcon" value="sports_tennis" />
                                <c:if test="${fn:contains(fn:toLowerCase(mon.tenMon), 'bóng đá')}"><c:set var="spIcon" value="sports_soccer" /></c:if>
                                <c:if test="${fn:contains(fn:toLowerCase(mon.tenMon), 'bóng bàn')}"><c:set var="spIcon" value="sports_kabaddi" /></c:if>
                                <c:if test="${fn:contains(fn:toLowerCase(mon.tenMon), 'cầu lông')}"><c:set var="spIcon" value="sports_tennis" /></c:if>
                                <c:if test="${fn:contains(fn:toLowerCase(mon.tenMon), 'pickleball')}"><c:set var="spIcon" value="sports_tennis" /></c:if>
                                <div class="custom-option px-4 py-2.5 text-xs font-bold uppercase tracking-wider text-neutral-800 hover:bg-neutral-50 flex items-center gap-2 border-t border-neutral-100/50" data-value="${mon.monTheThaoID}">
                                    <span class="material-symbols-outlined text-[16px] text-primary">${spIcon}</span>
                                    ${mon.tenMon}
                                </div>
                            </c:forEach>
                        </div>
                    </div>

                    <!-- Custom Branch Select -->
                    <div class="relative custom-select-wrapper rounded-none border border-neutral-200 bg-white px-4 py-2 text-left hover:border-neutral-300 transition-colors cursor-pointer select-none" id="custom-branch-trigger">
                        <div class="mb-0.5 flex items-center gap-1.5 text-[10px] font-bold uppercase tracking-[0.15em] text-neutral-400 font-['Barlow_Condensed']">
                            <span class="material-symbols-outlined text-[16px] text-primary">location_on</span>
                            Cơ sở
                        </div>
                        <div class="flex items-center justify-between">
                            <span id="custom-branch-label" class="font-['Barlow'] font-semibold text-neutral-800 text-sm">Tất cả cơ sở</span>
                            <span class="material-symbols-outlined text-neutral-400 select-arrow text-[18px] transition-transform duration-200">expand_more</span>
                        </div>
                        <!-- Hidden real select -->
                        <select id="hero-branch-select" class="hidden">
                            <option value="0">Tất cả cơ sở</option>
                            <c:forEach var="cs" items="${dsCoSo}">
                                <option value="${cs.coSoID}">${cs.tenCoSo}</option>
                            </c:forEach>
                        </select>
                        <!-- Custom options list -->
                        <div id="custom-branch-options" class="absolute top-[calc(100%+4px)] left-[-1px] right-[-1px] bg-white border border-neutral-200 shadow-xl z-50 hidden py-1">
                            <div class="custom-option px-4 py-2.5 text-xs font-bold uppercase tracking-wider text-neutral-600 hover:bg-neutral-50 flex flex-col items-start" data-value="0">
                                Tất cả cơ sở
                            </div>
                            <c:forEach var="cs" items="${dsCoSo}">
                                <div class="custom-option px-4 py-2.5 hover:bg-neutral-50 flex flex-col items-start border-t border-neutral-100/50" data-value="${cs.coSoID}">
                                    <span class="text-neutral-800 font-bold text-xs uppercase tracking-wide font-['Barlow_Condensed']">${cs.tenCoSo}</span>
                                    <span class="text-[10px] text-neutral-400 font-medium truncate w-full mt-0.5">${cs.diaChi}</span>
                                </div>
                            </c:forEach>
                        </div>
                    </div>

                    <!-- Date play -->
                    <div class="rounded-none border border-neutral-200 bg-white px-4 py-2 text-left focus-within:border-primary hover:border-neutral-300 transition-colors">
                        <div class="mb-0.5 flex items-center gap-1.5 text-[10px] font-bold uppercase tracking-[0.15em] text-neutral-400 font-['Barlow_Condensed']">
                            <span class="material-symbols-outlined text-[16px] text-primary">calendar_today</span>
                            Ngày chơi
                        </div>
                        <input type="date" id="quick-date-input" class="booking-date-input font-['Barlow'] font-semibold text-neutral-800 text-sm w-full bg-transparent border-none outline-none"/>
                    </div>

                    <!-- Search Button -->
                    <button id="btn-search-court" type="button" class="h-full min-h-[56px] rounded-none bg-primary px-8 py-3 text-on-primary tracking-widest uppercase font-['Barlow_Condensed'] font-bold text-[14px] transition-all hover:bg-on-surface flex items-center justify-center gap-2 active:scale-95 duration-200 shrink-0">
                        <span class="material-symbols-outlined text-[18px]" id="search-icon">search</span> <span id="search-text">Tìm sân</span>
                    </button>
                    </div>
                </div>
            </div>
        </section>

        <!-- Results Section -->
        <section id="results-section" class="results-shell">
            <div class="max-w-[1680px] mx-auto px-margin-mobile md:px-margin-desktop py-10 md:py-14">

            <!-- Filter chips + branch dropdown + history -->
            <div class="results-toolbar flex flex-col md:flex-row md:items-center md:justify-between gap-5 pb-6 mb-8 border-b border-outline-variant/30 px-0 bg-transparent">
                <div id="sport-chip-row" class="flex flex-nowrap md:flex-wrap gap-2 overflow-x-auto pb-1 md:pb-0" style="-webkit-overflow-scrolling:touch;">
                    <button type="button" onclick="selectSportChip(0, this)" class="chip-filter chip-filter-active">Tất cả</button>
                    <c:forEach var="mon" items="${dsMon}">
                        <button type="button" onclick="selectSportChip(${mon.monTheThaoID}, this)" class="chip-filter">${mon.tenMon}</button>
                    </c:forEach>
                </div>
                <div class="flex flex-wrap items-center gap-2.5 shrink-0">
                    <select id="branch-select-chip" class="h-11 min-w-[190px] rounded-none border border-neutral-200 bg-white px-4 text-sm font-semibold text-neutral-800 focus:outline-none focus:border-primary">
                        <option value="0">Tất cả cơ sở</option>
                        <c:forEach var="cs" items="${dsCoSo}">
                            <option value="${cs.coSoID}">${cs.tenCoSo}</option>
                        </c:forEach>
                    </select>
                    <c:if test="${sessionScope.user != null}">
                        <button type="button" onclick="openHistoryModal()" class="flex h-11 items-center gap-1.5 rounded-none border border-neutral-200 bg-white px-5 text-[12px] font-['Barlow_Condensed'] font-bold uppercase tracking-wider text-neutral-800 transition-all hover:border-primary hover:text-primary">
                            <span class="material-symbols-outlined text-[18px]">history</span>
                            Lịch sử
                        </button>
                    </c:if>
                </div>
            </div>

            <div class="flex flex-col gap-4 md:flex-row md:items-center md:justify-between mb-md">
                <h2 class="section-title">Sân đấu khả dụng</h2>
                <div class="flex items-center gap-3 flex-wrap">
                    <span class="results-stat">
                        Đang hiển thị <span id="court-count" class="font-bold">0</span> kết quả (<span id="court-status-summary"></span>)
                    </span>
                    <!-- List/Map view toggle. Map view lands in Phase 3 (route /customer/ban-do). -->
                    <div class="inline-flex border border-neutral-200 rounded-none overflow-hidden shrink-0" role="group" aria-label="Chuyển đổi chế độ xem">
                        <button type="button" disabled
                                class="flex items-center gap-1.5 px-4 py-2 text-[11px] font-['Barlow_Condensed'] font-bold uppercase tracking-wider bg-[#111111] text-white">
                            <span class="material-symbols-outlined text-[16px]">view_list</span> Danh sách
                        </button>
                        <button type="button" onclick="showMapComingSoon()"
                                class="flex items-center gap-1.5 px-4 py-2 text-[11px] font-['Barlow_Condensed'] font-bold uppercase tracking-wider bg-white text-neutral-500 hover:text-[#c2000d] hover:bg-neutral-50 transition-colors border-l border-neutral-200">
                            <span class="material-symbols-outlined text-[16px]">map</span> Bản đồ
                        </button>
                    </div>
                </div>
            </div>

            <div id="courts-container" class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-x-gutter gap-y-10">
                <c:forEach var="s" items="${dsSan}">
                    <div class="court-card flex flex-col bg-white border border-neutral-100 group">
                        <div class="court-card-media relative h-56 w-full overflow-hidden bg-neutral-100">
                            <img class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
                                 src="${not empty s.hinhAnh ? s.hinhAnh : 'https://images.unsplash.com/photo-1518605368461-1ee7e57c6691?auto=format&fit=crop&w=600&q=80'}"
                                 alt="${s.tenSan}" />
                            <div class="absolute top-3 left-3 z-10 font-['Barlow_Condensed'] font-bold text-[10px] tracking-widest uppercase px-3.5 py-1 border court-card-status bg-white/95 ${s.trangThai == 'Sẵn sàng' ? 'border-[#16A36A] text-[#16A36A]' : (s.trangThai == 'Đang dùng' ? 'border-[#427CF0] text-[#427CF0]' : 'border-neutral-300 text-neutral-500')}">
                                ${s.trangThai}
                            </div>
                        </div>
                        <div class="p-6 flex flex-col flex-grow">
                            <div class="mb-4">
                                <p class="font-['Barlow'] text-xs text-neutral-400 uppercase tracking-wider mb-1.5">
                                    <c:forEach var="cs" items="${dsCoSo}">
                                        <c:if test="${cs.coSoID == s.coSoID}">${cs.tenCoSo}</c:if>
                                    </c:forEach>
                                </p>
                                <h3 class="font-['Barlow_Condensed'] text-[24px] md:text-[26px] leading-tight font-bold text-[#111111] uppercase tracking-wide group-hover:text-primary transition-colors mb-2.5">${s.tenSan}</h3>
                                <div class="flex flex-wrap items-center gap-2 text-xs text-on-surface-variant">
                                    <span class="court-chip">
                                        <c:forEach var="l" items="${dsLoai}">
                                            <c:if test="${l.loaiSanID == s.loaiSanID}">
                                                <c:forEach var="m" items="${dsMon}">
                                                    <c:if test="${m.monTheThaoID == l.monTheThaoID}">${m.tenMon}</c:if>
                                                </c:forEach>
                                            </c:if>
                                        </c:forEach>
                                    </span>
                                    <c:forEach var="cs" items="${dsCoSo}">
                                        <c:if test="${cs.coSoID == s.coSoID}">
                                            <span class="inline-flex items-center gap-1 rounded-none bg-neutral-100 px-2.5 py-0.5 font-semibold text-neutral-500 text-[11px]">
                                                <span class="material-symbols-outlined text-[14px]">schedule</span>
                                                ${cs.gioMoCua != null ? cs.gioMoCua.toString().substring(0,5) : '06:00'} - ${cs.gioDongCua != null ? cs.gioDongCua.toString().substring(0,5) : '23:00'}
                                            </span>
                                        </c:if>
                                    </c:forEach>
                                </div>
                            </div>
                            <div class="mt-auto border-t border-neutral-100 pt-5 flex items-center justify-between gap-3">
                                <div>
                                    <p class="text-[10px] font-semibold text-neutral-400 uppercase tracking-widest mb-0.5">Giá thuê từ</p>
                                    <p class="text-[20px] font-bold text-[#111111] font-['Barlow_Condensed'] tracking-wide">
                                        <c:forEach var="l" items="${dsLoai}">
                                            <c:if test="${l.loaiSanID == s.loaiSanID}">
                                                <fmt:formatNumber value="${l.giaKhongDen}" type="currency" currencySymbol="" maxFractionDigits="0" /> đ
                                            </c:if>
                                        </c:forEach>
                                        <span class="text-[12px] font-semibold text-neutral-400 font-sans">/ giờ</span>
                                    </p>
                                </div>
                                <a href="${pageContext.request.contextPath}/customer/chi-tiet-san?id=${s.sanID}"
                                   class="court-card-cta inline-flex items-center justify-center rounded-none px-6 py-2.5 text-[12px] font-['Barlow_Condensed'] font-bold uppercase tracking-widest transition-all">
                                    Đặt sân
                                </a>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>

            <div class="w-full flex justify-center mt-12">
                <button class="font-['Barlow_Condensed'] font-bold text-[13px] tracking-widest uppercase border border-neutral-200 text-neutral-800 px-8 py-3 rounded-none hover:border-[#111111] hover:text-[#111111] transition-colors flex items-center gap-2 group bg-white">
                    TẢI THÊM <span class="material-symbols-outlined group-hover:translate-y-1 transition-transform text-[16px]">expand_more</span>
                </button>
            </div>

            </div>
        </section>

    </main>

    <!-- Footer -->
    <jsp:include page="/customer/common/vsport-footer.jsp" />

    <!-- ════ HISTORY MODAL ════ -->
    <%-- ════ LỊCH SỬ ĐẶT SÂN — redesign đồng bộ theme Customer V-SPORT (navy/cyan/cam, --vs-font-sans) ════ --%>
    <style>
        /* Scope toàn bộ dưới .vs-bhm để không ảnh hưởng trang khác. Dùng token --vs-* + font hệ thống. */
        .vs-bhm-overlay { position: fixed; inset: 0; z-index: 200; display: none; align-items: center; justify-content: center;
            padding: 20px; background: var(--vs-overlay, rgba(7,26,47,.68)); backdrop-filter: blur(3px);
            opacity: 0; transition: opacity .25s ease; overflow-y: auto; }
        .vs-bhm-overlay.is-open { display: flex; opacity: 1; }
        .vs-bhm { font-family: var(--vs-font-sans); color: var(--vs-text, #102A43); background: #fff;
            width: 100%; max-width: 1040px; max-height: 86vh; margin: auto; border-radius: 20px; overflow: hidden;
            display: flex; flex-direction: column; box-shadow: 0 24px 60px rgba(7,26,47,.32);
            transform: translateY(12px) scale(.98); transition: transform .25s ease; }
        .vs-bhm-overlay.is-open .vs-bhm { transform: none; }
        .vs-bhm *, .vs-bhm button, .vs-bhm input, .vs-bhm a { font-family: inherit; }

        /* Header navy */
        .vs-bhm-head { background: var(--vs-primary-900, #111111); color: #fff; padding: 16px 20px;
            display: flex; align-items: center; gap: 13px; flex-shrink: 0; }
        .vs-bhm-head-ic { width: 42px; height: 42px; border-radius: 12px; flex-shrink: 0; display: inline-flex;
            align-items: center; justify-content: center; background: rgba(24,200,232,.16); color: var(--vs-cyan-500, #c2000d); }
        .vs-bhm-head-tt { flex: 1; min-width: 0; }
        .vs-bhm-head-tt h3 { font-size: 17px; font-weight: 700; margin: 0; }
        .vs-bhm-head-tt p { font-size: 12.5px; color: #b6c2d4; margin: 2px 0 0; font-weight: 500; }
        .vs-bhm-close { width: 38px; height: 38px; border-radius: 999px; flex-shrink: 0; border: none; cursor: pointer;
            background: rgba(255,255,255,.08); color: #fff; display: inline-flex; align-items: center; justify-content: center;
            transition: background-color .15s ease; }
        .vs-bhm-close:hover { background: rgba(255,255,255,.18); }
        .vs-bhm-close:focus-visible { outline: 3px solid var(--vs-cyan-500, #c2000d); outline-offset: 2px; }

        /* Summary bar */
        .vs-bhm-summary { display: flex; align-items: center; justify-content: space-between; gap: 14px; flex-wrap: wrap;
            padding: 14px 20px; background: var(--vs-surface-soft, #EDF4FA); border-bottom: 1px solid var(--vs-border, #DCE5EF); flex-shrink: 0; }
        .vs-bhm-user { display: flex; align-items: center; gap: 11px; min-width: 0; }
        .vs-bhm-avatar { width: 42px; height: 42px; border-radius: 999px; flex-shrink: 0; display: inline-flex; align-items: center;
            justify-content: center; background: var(--vs-primary-600, #e3000f); color: #fff; font-weight: 700; font-size: 16px; }
        .vs-bhm-user-name { font-size: 14px; font-weight: 700; color: var(--vs-primary-900, #111111); }
        .vs-bhm-user-mail { font-size: 12px; color: var(--vs-text-secondary, #486581); font-weight: 500; }
        .vs-bhm-stats { display: flex; gap: 8px; }
        .vs-bhm-stat { min-width: 78px; text-align: center; padding: 7px 12px; border-radius: 12px;
            background: var(--vs-cyan-50, #F0FCFE); border: 1px solid var(--vs-cyan-100, #ffe5e6); }
        .vs-bhm-stat .k { display: block; font-size: 10px; font-weight: 600; color: var(--vs-text-secondary, #486581); }
        .vs-bhm-stat .v { display: block; font-size: 16px; font-weight: 700; color: var(--vs-primary-700, #185A9D); margin-top: 1px; }

        /* Filter tabs */
        .vs-bhm-tabs { display: flex; gap: 7px; padding: 12px 20px 0; overflow-x: auto; flex-shrink: 0; }
        .vs-bhm-tab { flex-shrink: 0; border: 1px solid var(--vs-border, #DCE5EF); background: #fff; cursor: pointer;
            border-radius: 999px; padding: 7px 14px; font-size: 12.5px; font-weight: 600; color: var(--vs-text-secondary, #486581);
            display: inline-flex; align-items: center; gap: 6px; transition: all .15s ease; white-space: nowrap; }
        .vs-bhm-tab:hover { border-color: var(--vs-cyan-500, #c2000d); color: var(--vs-primary-600, #e3000f); }
        .vs-bhm-tab.is-active { background: var(--vs-primary-600, #e3000f); border-color: var(--vs-primary-600, #e3000f); color: #fff; }
        .vs-bhm-tab-count { background: var(--vs-surface-soft, #EDF4FA); color: var(--vs-text-secondary, #486581);
            border-radius: 999px; padding: 0 6px; font-size: 11px; font-weight: 700; min-width: 18px; text-align: center; }
        .vs-bhm-tab.is-active .vs-bhm-tab-count { background: rgba(255,255,255,.22); color: #fff; }

        /* Scroll body + card list */
        .vs-bhm-body { padding: 14px 20px 20px; overflow-y: auto; flex: 1; }
        .vs-bhm-card { display: grid; grid-template-columns: 1.5fr 1fr auto auto; align-items: center; gap: 14px;
            padding: 14px 16px; border: 1px solid var(--vs-border, #DCE5EF); border-radius: 14px; margin-bottom: 10px; background: #fff; }
        .vs-bhm-card:hover { border-color: var(--vs-cyan-500, #c2000d); }
        .vs-bhm-facility { min-width: 0; }
        .vs-bhm-facility-top { display: flex; align-items: center; gap: 7px; flex-wrap: wrap; }
        .vs-bhm-facility-name { font-size: 14.5px; font-weight: 700; color: var(--vs-primary-900, #111111); }
        .vs-bhm-new { font-size: 10px; font-weight: 700; color: #fff; background: var(--vs-orange-500, #e3000f);
            border-radius: 6px; padding: 1px 7px; }
        .vs-bhm-meta { font-size: 12px; color: var(--vs-text-secondary, #486581); font-weight: 500; margin-top: 3px;
            display: flex; align-items: center; gap: 5px; flex-wrap: wrap; }
        .vs-bhm-meta .material-symbols-outlined { font-size: 14px; }
        .vs-bhm-time { font-size: 13px; }
        .vs-bhm-time .d { font-weight: 700; color: var(--vs-text, #102A43); }
        .vs-bhm-time .h { color: var(--vs-primary-600, #e3000f); font-weight: 700; }
        .vs-bhm-price { font-size: 15px; font-weight: 700; color: var(--vs-primary-900, #111111); text-align: right; white-space: nowrap; }
        .vs-bhm-right { display: flex; flex-direction: column; align-items: flex-end; gap: 8px; }

        .vs-bhm-badge { display: inline-flex; align-items: center; gap: 5px; padding: 4px 10px; border-radius: 999px;
            font-size: 11.5px; font-weight: 700; white-space: nowrap; }
        .vs-bhm-badge .material-symbols-outlined { font-size: 13px; }
        .vs-bhm-badge.warn { background: var(--vs-warning-bg, #FFF7DA); color: #8a6116; }
        .vs-bhm-badge.amber { background: #FFF3E0; color: #9a5b00; }
        .vs-bhm-badge.ok { background: var(--vs-success-bg, #E5F7EF); color: var(--vs-success, #16A36A); }
        .vs-bhm-badge.info { background: var(--vs-cyan-100, #ffe5e6); color: var(--vs-primary-700, #185A9D); }
        .vs-bhm-badge.danger { background: var(--vs-danger-bg, #FDEBEC); color: var(--vs-danger, #E5484D); }
        .vs-bhm-badge.neutral { background: var(--vs-surface-soft, #EDF4FA); color: var(--vs-text-secondary, #486581); }

        .vs-bhm-actions { display: flex; align-items: center; gap: 7px; justify-content: flex-end; flex-wrap: wrap; }
        .vs-bhm-btn { display: inline-flex; align-items: center; justify-content: center; gap: 6px; min-height: 40px;
            padding: 0 14px; border-radius: 10px; border: 1px solid transparent; cursor: pointer; font-size: 12.5px; font-weight: 700;
            text-decoration: none; transition: background-color .15s ease, border-color .15s ease, transform .08s ease; }
        .vs-bhm-btn:active { transform: translateY(1px); }
        .vs-bhm-btn .material-symbols-outlined { font-size: 16px; }
        .vs-bhm-btn-primary { background: var(--vs-orange-500, #e3000f); color: #fff; }
        .vs-bhm-btn-primary:hover { background: var(--vs-orange-600, #c2000d); }
        .vs-bhm-btn-primary[disabled] { background: #d9a06e; cursor: not-allowed; }
        .vs-bhm-btn-ghost { background: #fff; color: var(--vs-primary-600, #e3000f); border-color: var(--vs-border, #DCE5EF); }
        .vs-bhm-btn-ghost:hover { border-color: var(--vs-cyan-500, #c2000d); background: var(--vs-cyan-50, #F0FCFE); }
        .vs-bhm-btn-danger { background: #fff; color: var(--vs-danger, #E5484D); border-color: #f3cfd1; }
        .vs-bhm-btn-danger:hover { background: var(--vs-danger-bg, #FDEBEC); }
        .vs-bhm-done { font-size: 12.5px; font-weight: 700; color: var(--vs-success, #16A36A); }
        .vs-bhm-muted { font-size: 12.5px; color: var(--vs-muted, #829AB1); }
        .vs-bhm-btn .spinner { width: 14px; height: 14px; border-radius: 50%; border: 2.5px solid rgba(255,255,255,.4);
            border-top-color: #fff; animation: vsBhmSpin .8s linear infinite; }
        @keyframes vsBhmSpin { to { transform: rotate(360deg); } }

        /* Empty state */
        .vs-bhm-empty { text-align: center; padding: 48px 20px; }
        .vs-bhm-empty-ic { width: 66px; height: 66px; border-radius: 999px; margin: 0 auto 14px; display: flex; align-items: center;
            justify-content: center; background: var(--vs-surface-soft, #EDF4FA); color: var(--vs-primary-600, #e3000f); }
        .vs-bhm-empty h4 { font-size: 16px; font-weight: 700; color: var(--vs-primary-900, #111111); margin: 0 0 5px; }
        .vs-bhm-empty p { font-size: 13.5px; color: var(--vs-text-secondary, #486581); margin: 0 0 16px; }
        .vs-bhm-empty-cta { display: inline-flex; align-items: center; gap: 7px; background: var(--vs-orange-500, #e3000f);
            color: #fff; border-radius: 11px; padding: 11px 20px; font-size: 13.5px; font-weight: 700; text-decoration: none; }
        .vs-bhm-empty-cta:hover { background: var(--vs-orange-600, #c2000d); }
        .vs-bhm-noresult { display: none; text-align: center; padding: 36px 20px; color: var(--vs-text-secondary, #486581); font-size: 13.5px; }

        /* Confirm dialog */
        .vs-bhm-confirm { position: absolute; inset: 0; z-index: 5; display: none; align-items: center; justify-content: center;
            padding: 20px; background: rgba(7,26,47,.55); }
        .vs-bhm-confirm.is-open { display: flex; }
        .vs-bhm-confirm-box { background: #fff; border-radius: 16px; padding: 20px; max-width: 380px; width: 100%; }
        .vs-bhm-confirm-box h4 { font-size: 16px; font-weight: 700; color: var(--vs-primary-900, #111111); margin: 0 0 7px; }
        .vs-bhm-confirm-box p { font-size: 13.5px; color: var(--vs-text-secondary, #486581); margin: 0 0 16px; line-height: 1.5; }
        .vs-bhm-confirm-actions { display: flex; gap: 9px; }
        .vs-bhm-confirm-actions .vs-bhm-btn { flex: 1; }
        .vs-bhm-btn-confirm-danger { background: var(--vs-danger, #E5484D); color: #fff; }
        .vs-bhm-btn-confirm-danger:hover { background: #cf3b40; }

        @media (max-width: 720px) {
            .vs-bhm-overlay { padding: 0; align-items: flex-end; }
            .vs-bhm { max-width: 100%; max-height: 92vh; border-radius: 18px 18px 0 0; }
            .vs-bhm-card { grid-template-columns: 1fr; gap: 8px; }
            .vs-bhm-price { text-align: left; }
            .vs-bhm-right { align-items: stretch; }
            .vs-bhm-actions { justify-content: stretch; }
            .vs-bhm-actions .vs-bhm-btn { flex: 1; }
        }
        @media (min-width: 721px) and (max-width: 960px) {
            .vs-bhm-card { grid-template-columns: 1.4fr 1fr; }
            .vs-bhm-price { text-align: left; }
            .vs-bhm-right { align-items: flex-start; grid-column: 1 / -1; flex-direction: row; justify-content: space-between; }
        }
        @media (prefers-reduced-motion: reduce) { .vs-bhm, .vs-bhm-overlay { transition: none; } .vs-bhm-btn .spinner { animation-duration: 2.4s; } }
    </style>

    <div id="historyModalOverlay" class="vs-bhm-overlay" role="dialog" aria-modal="true" aria-labelledby="vsBhmTitle">
        <div id="historyPanel" class="vs-bhm">
            <div class="vs-bhm-head">
                <span class="vs-bhm-head-ic material-symbols-outlined" aria-hidden="true">history</span>
                <div class="vs-bhm-head-tt">
                    <h3 id="vsBhmTitle">Lịch sử đặt sân</h3>
                    <p>Theo dõi lịch đặt và tiếp tục các khoản thanh toán đang chờ.</p>
                </div>
                <button type="button" onclick="closeHistoryModal()" class="vs-bhm-close" aria-label="Đóng lịch sử đặt sân">
                    <span class="material-symbols-outlined" aria-hidden="true">close</span>
                </button>
            </div>

            <c:if test="${sessionScope.user != null}">
                <div class="vs-bhm-summary">
                    <div class="vs-bhm-user">
                        <div class="vs-bhm-avatar" aria-hidden="true"><c:out value="${fn:substring(not empty sessionScope.user.fullName ? sessionScope.user.fullName : sessionScope.user.username, 0, 1)}"/></div>
                        <div>
                            <div class="vs-bhm-user-name"><c:out value="${not empty sessionScope.user.fullName ? sessionScope.user.fullName : sessionScope.user.username}"/></div>
                            <div class="vs-bhm-user-mail"><c:out value="${sessionScope.user.email}"/></div>
                        </div>
                    </div>
                    <div class="vs-bhm-stats">
                        <div class="vs-bhm-stat"><span class="k">Đã đặt</span><span class="v">${fn:length(dsLich)}</span></div>
                        <div class="vs-bhm-stat"><span class="k">Uy tín</span><span class="v">${sessionScope.user.diemUyTin != null ? sessionScope.user.diemUyTin : 100}</span></div>
                    </div>
                </div>
            </c:if>

            <c:if test="${not empty dsLich}">
                <div class="vs-bhm-tabs" role="tablist" aria-label="Lọc theo trạng thái">
                    <button type="button" class="vs-bhm-tab is-active" role="tab" aria-selected="true" data-filter="all">Tất cả <span class="vs-bhm-tab-count" data-count="all">0</span></button>
                    <button type="button" class="vs-bhm-tab" role="tab" aria-selected="false" data-filter="paying">Chờ thanh toán <span class="vs-bhm-tab-count" data-count="paying">0</span></button>
                    <button type="button" class="vs-bhm-tab" role="tab" aria-selected="false" data-filter="confirmed">Đã xác nhận <span class="vs-bhm-tab-count" data-count="confirmed">0</span></button>
                    <button type="button" class="vs-bhm-tab" role="tab" aria-selected="false" data-filter="done">Đã hoàn thành <span class="vs-bhm-tab-count" data-count="done">0</span></button>
                    <button type="button" class="vs-bhm-tab" role="tab" aria-selected="false" data-filter="ended">Đã hủy / Quá hạn <span class="vs-bhm-tab-count" data-count="ended">0</span></button>
                </div>
            </c:if>

            <div class="vs-bhm-body" id="vsBhmBody">
                <c:choose>
                    <c:when test="${empty dsLich}">
                        <div class="vs-bhm-empty">
                            <div class="vs-bhm-empty-ic"><span class="material-symbols-outlined" style="font-size:32px;" aria-hidden="true">event_available</span></div>
                            <h4>Bạn chưa có lịch đặt</h4>
                            <p>Tìm sân phù hợp và bắt đầu lịch chơi đầu tiên của bạn.</p>
                            <a class="vs-bhm-empty-cta" href="${pageContext.request.contextPath}/customer/dat-san">
                                <span class="material-symbols-outlined" aria-hidden="true">search</span> Tìm sân ngay
                            </a>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="lich" items="${dsLich}" varStatus="lichStatus">
                            <c:set var="tenSanHienThi" value="Sân #${lich.sanId}" />
                            <c:set var="branchHienThi" value="" />
                            <c:forEach var="s" items="${dsSan}">
                                <c:if test="${s.sanID == lich.sanId}">
                                    <c:set var="tenSanHienThi" value="${s.tenSan}" />
                                    <c:forEach var="cs" items="${dsCoSo}">
                                        <c:if test="${cs.coSoID == s.coSoID}">
                                            <c:set var="branchHienThi" value="${cs.tenCoSo}" />
                                        </c:if>
                                    </c:forEach>
                                </c:if>
                            </c:forEach>

                            <%-- Nhóm trạng thái cho filter (map từ trạng thái thật, không bịa) --%>
                            <c:set var="grp" value="ended" />
                            <c:if test="${lich.trangThai == 'Chờ thanh toán'}"><c:set var="grp" value="paying" /></c:if>
                            <c:if test="${lich.trangThai == 'Chờ xác nhận' || lich.trangThai == 'Đã xác nhận' || lich.trangThai == 'Đã đặt' || lich.trangThai == 'Đang sử dụng'}"><c:set var="grp" value="confirmed" /></c:if>
                            <c:if test="${lich.trangThai == 'Đã hoàn thành'}"><c:set var="grp" value="done" /></c:if>

                            <div class="vs-bhm-card" data-group="${grp}">
                                <div class="vs-bhm-facility">
                                    <div class="vs-bhm-facility-top">
                                        <span class="vs-bhm-facility-name"><c:out value="${tenSanHienThi}"/></span>
                                        <c:if test="${lichStatus.first}"><span class="vs-bhm-new">Mới nhất</span></c:if>
                                    </div>
                                    <div class="vs-bhm-meta">
                                        <c:if test="${not empty branchHienThi}"><span class="material-symbols-outlined" aria-hidden="true">location_on</span><c:out value="${branchHienThi}"/> ·</c:if>
                                        <span>Mã #${lich.datSanId}</span>
                                    </div>
                                    <c:if test="${not empty lich.createdTime}">
                                        <div class="vs-bhm-meta"><span class="material-symbols-outlined" aria-hidden="true">schedule</span>Đặt lúc ${fn:replace(fn:substring(lich.createdTime.toString(), 0, 16), 'T', ' ')}</div>
                                    </c:if>
                                </div>
                                <div class="vs-bhm-time">
                                    <div class="d">${lich.ngayDat}</div>
                                    <div class="h">${fn:substring(lich.gioBatDau, 0, 5)} – ${fn:substring(lich.gioKetThuc, 0, 5)}</div>
                                </div>
                                <div class="vs-bhm-price"><fmt:formatNumber value="${lich.tongTienDuKien}" pattern="#,##0"/> ₫</div>
                                <div class="vs-bhm-right">
                                    <%-- Badge trạng thái --%>
                                    <c:choose>
                                        <c:when test="${lich.trangThai == 'Chờ thanh toán'}"><span class="vs-bhm-badge warn"><span class="material-symbols-outlined" aria-hidden="true">hourglass_top</span>Chờ thanh toán</span></c:when>
                                        <c:when test="${lich.trangThai == 'Chờ xác nhận'}"><span class="vs-bhm-badge amber"><span class="material-symbols-outlined" aria-hidden="true">pending</span>Chờ duyệt</span></c:when>
                                        <c:when test="${lich.trangThai == 'Đã xác nhận' || lich.trangThai == 'Đã đặt'}"><span class="vs-bhm-badge ok"><span class="material-symbols-outlined" aria-hidden="true">check_circle</span>Đã xác nhận</span></c:when>
                                        <c:when test="${lich.trangThai == 'Đang sử dụng'}"><span class="vs-bhm-badge info"><span class="material-symbols-outlined" aria-hidden="true">sports_tennis</span>Đang chơi</span></c:when>
                                        <c:when test="${lich.trangThai == 'Đã hoàn thành'}"><span class="vs-bhm-badge ok"><span class="material-symbols-outlined" aria-hidden="true">verified</span>Hoàn thành</span></c:when>
                                        <c:when test="${lich.trangThai == 'Quá hạn'}"><span class="vs-bhm-badge neutral"><span class="material-symbols-outlined" aria-hidden="true">timer_off</span>Quá hạn</span></c:when>
                                        <c:when test="${lich.trangThai == 'Đã hủy'}"><span class="vs-bhm-badge danger"><span class="material-symbols-outlined" aria-hidden="true">cancel</span>Đã hủy</span></c:when>
                                        <c:when test="${lich.trangThai == 'Không đến'}"><span class="vs-bhm-badge danger"><span class="material-symbols-outlined" aria-hidden="true">person_off</span>Không đến</span></c:when>
                                        <c:otherwise><span class="vs-bhm-badge neutral"><c:out value="${lich.trangThai}"/></span></c:otherwise>
                                    </c:choose>

                                    <%-- Thao tác theo trạng thái thật --%>
                                    <div class="vs-bhm-actions">
                                        <c:choose>
                                            <c:when test="${lich.trangThai == 'Chờ thanh toán'}">
                                                <a class="vs-bhm-btn vs-bhm-btn-primary" data-resume href="${pageContext.request.contextPath}/customer/thanh-toan-qr?datSanId=${lich.datSanId}">
                                                    <span class="material-symbols-outlined" aria-hidden="true">qr_code_2</span><span class="vs-bhm-btn-label">Tiếp tục thanh toán</span>
                                                </a>
                                                <button type="button" class="vs-bhm-btn vs-bhm-btn-danger"
                                                        data-cancel-payos="${lich.datSanId}"
                                                        data-confirm-msg="Hủy đơn thanh toán này? Mã QR sẽ ngừng hiệu lực và khung giờ được giải phóng cho người khác.">Hủy thanh toán</button>
                                            </c:when>
                                            <c:when test="${lich.trangThai == 'Chờ xác nhận' || lich.trangThai == 'Đã xác nhận'}">
                                                <button type="button" class="vs-bhm-btn vs-bhm-btn-danger"
                                                        data-cancel-booking="${lich.datSanId}"
                                                        data-confirm-msg="Hủy đặt sân này? Thao tác không thể hoàn tác và khung giờ sẽ được giải phóng.">Hủy đặt sân</button>
                                            </c:when>
                                            <c:when test="${lich.trangThai == 'Quá hạn'}">
                                                <a class="vs-bhm-btn vs-bhm-btn-ghost" href="${pageContext.request.contextPath}/customer/dat-lich-truc-quan"><span class="material-symbols-outlined" aria-hidden="true">restart_alt</span>Đặt lại</a>
                                            </c:when>
                                            <c:when test="${lich.trangThai == 'Đã hoàn thành'}"><span class="vs-bhm-done">✓ Đã chơi</span></c:when>
                                            <c:otherwise><span class="vs-bhm-muted">—</span></c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                        <div class="vs-bhm-noresult" id="vsBhmNoResult">Không có đơn nào trong mục này.</div>
                    </c:otherwise>
                </c:choose>
            </div>

            <%-- Confirm dialog (không dùng window.confirm) --%>
            <div class="vs-bhm-confirm" id="vsBhmConfirm" role="alertdialog" aria-modal="true" aria-labelledby="vsBhmConfirmTitle" aria-describedby="vsBhmConfirmMsg">
                <div class="vs-bhm-confirm-box">
                    <h4 id="vsBhmConfirmTitle">Xác nhận huỷ</h4>
                    <p id="vsBhmConfirmMsg">Bạn có chắc chắn?</p>
                    <div class="vs-bhm-confirm-actions">
                        <button type="button" class="vs-bhm-btn vs-bhm-btn-ghost" id="vsBhmConfirmBack">Quay lại</button>
                        <button type="button" class="vs-bhm-btn vs-bhm-btn-confirm-danger" id="vsBhmConfirmOk">Xác nhận huỷ</button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%-- Form ẩn để hủy đặt sân (POST) — tránh nested form, submit bằng JS sau khi xác nhận. --%>
    <form id="vsBhmCancelBookingForm" action="${pageContext.request.contextPath}/customer/huy-dat-san" method="post" style="display:none;">
        <input type="hidden" name="id" id="vsBhmCancelBookingId" value="" />
    </form>

    <!-- ════ BOOKING MODAL FLOW ════ -->
    <div id="bookingModalOverlay" class="fixed inset-0 backdrop-blur-sm z-[200] hidden flex items-center justify-center opacity-0 transition-opacity duration-300 overflow-y-auto py-6 px-4" style="background-color: var(--vs-overlay, rgba(7, 26, 47, 0.68));">

        <!-- Step 1: Form -->
        <div id="bookingFormPanel" class="bg-white w-full max-w-2xl shadow-2xl overflow-hidden transform scale-95 transition-all duration-300 relative my-auto" style="border-radius:0;">

            <!-- Header with steps -->
            <div class="bg-[#111111] px-6 py-4 flex items-center justify-between">
                <div class="flex items-center gap-3">
                    <div class="w-8 h-8 bg-[#e3000f] flex items-center justify-center flex-shrink-0">
                        <span class="material-symbols-outlined text-white text-[18px]">sports_soccer</span>
                    </div>
                    <div>
                        <p class="text-[10px] text-white/50 font-bold uppercase tracking-[0.15em] font-['Barlow_Condensed']">Bước 1 / 2</p>
                        <h3 class="font-['Barlow_Condensed'] font-bold text-white text-base uppercase tracking-wider leading-tight">Chọn ngày &amp; giờ</h3>
                    </div>
                </div>
                <button onclick="closeBookingModal()" class="w-8 h-8 flex items-center justify-center text-white/60 hover:text-white hover:bg-white/10 transition-colors">
                    <span class="material-symbols-outlined text-[20px]">close</span>
                </button>
            </div>

            <!-- Court summary bar -->
            <div class="bg-[#f4f3f0] border-b border-neutral-200 px-6 py-3 flex items-center gap-4">
                <div class="relative w-14 h-14 flex-shrink-0 overflow-hidden bg-neutral-200">
                    <img id="modal-court-img" class="w-full h-full object-cover" src="https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?auto=format&fit=crop&w=120&q=70" alt="" />
                </div>
                <div class="flex-1 min-w-0">
                    <h4 id="modal-court-name" class="font-['Barlow_Condensed'] font-bold text-[#111] text-lg uppercase leading-tight truncate">Tên sân</h4>
                    <p id="modal-court-branch" class="text-[11px] text-neutral-500 font-semibold flex items-center gap-1 mt-0.5">
                        <span class="material-symbols-outlined text-[13px] text-[#e3000f]">location_on</span> <span>Cơ sở</span>
                    </p>
                </div>
                <div class="flex-shrink-0 flex flex-col items-end gap-1.5">
                    <span id="modal-court-type" class="text-[9px] font-['Barlow_Condensed'] font-bold tracking-widest uppercase text-[#e3000f] border border-[#e3000f]/30 bg-[#e3000f]/5 px-2 py-0.5">Loại sân</span>
                    <div id="branch-hours-info" class="flex items-center gap-1 text-[10px] text-neutral-500 font-bold font-mono">
                        <span class="material-symbols-outlined text-[12px] text-[#e3000f]">schedule</span>
                        <span id="modal-branch-hours">--:-- - --:--</span>
                    </div>
                </div>
                <span id="modal-court-status" class="hidden"></span>
            </div>

            <!-- Form body -->
            <form id="booking-form" action="${pageContext.request.contextPath}/customer/dat-san" method="post">
                <input type="hidden" name="sanId" id="input-san-id" required>
                <input type="hidden" name="paymentMethod" id="input-payment-method" value="sau">

                <div class="p-6 space-y-5">

                    <!-- Date field -->
                    <div>
                        <label class="form-label mb-2 flex items-center gap-1.5">
                            <span class="material-symbols-outlined text-[14px] text-[#e3000f]">calendar_today</span>
                            Ngày thi đấu <span class="text-red-500 ml-0.5">*</span>
                        </label>
                        <div class="relative focus-within:ring-1 focus-within:ring-[#c2000d] border border-neutral-200 bg-white transition-all">
                            <input type="date" name="ngayDat" id="ngayDat" required
                                class="w-full px-4 py-3.5 text-[#111] font-bold font-['Barlow'] text-sm bg-transparent border-none outline-none cursor-pointer"
                                onchange="onBookingDateChange()">
                        </div>
                    </div>

                    <!-- Time fields -->
                    <div>
                        <label class="form-label mb-2 flex items-center gap-1.5">
                            <span class="material-symbols-outlined text-[14px] text-[#e3000f]">access_time</span>
                            Khung giờ <span class="text-red-500 ml-0.5">*</span>
                        </label>
                        <div class="grid grid-cols-2 gap-3">
                            <div class="relative border border-neutral-200 bg-white focus-within:ring-1 focus-within:ring-[#c2000d] transition-all">
                                <p class="text-[9px] font-bold uppercase tracking-widest text-neutral-400 font-['Barlow_Condensed'] px-4 pt-2.5">Bắt đầu</p>
                                <div class="relative">
                                    <select name="gioBatDau" id="gioBatDau" required
                                        class="w-full px-4 pb-2.5 pt-0.5 text-sm font-bold text-[#111] bg-transparent border-none outline-none appearance-none cursor-pointer pr-8 font-['Barlow']"
                                        onchange="onStartTimeSelectChange()"></select>
                                    <span class="material-symbols-outlined absolute right-3 top-1/2 -translate-y-1/2 text-neutral-400 pointer-events-none text-[18px]">expand_more</span>
                                </div>
                            </div>
                            <div class="relative border border-neutral-200 bg-white focus-within:ring-1 focus-within:ring-[#c2000d] transition-all">
                                <p class="text-[9px] font-bold uppercase tracking-widest text-neutral-400 font-['Barlow_Condensed'] px-4 pt-2.5">Kết thúc</p>
                                <div class="relative">
                                    <select name="gioKetThuc" id="gioKetThuc" required
                                        class="w-full px-4 pb-2.5 pt-0.5 text-sm font-bold text-[#111] bg-transparent border-none outline-none appearance-none cursor-pointer pr-8 font-['Barlow']"
                                        onchange="onEndTimeSelectChange()">
                                        <option value="">-- Chọn giờ bắt đầu trước</option>
                                    </select>
                                    <span class="material-symbols-outlined absolute right-3 top-1/2 -translate-y-1/2 text-neutral-400 pointer-events-none text-[18px]">expand_more</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Booked slots warning -->
                    <div id="timetable-block" class="hidden">
                        <div class="flex items-center gap-2 mb-2">
                            <span class="material-symbols-outlined text-[14px] text-amber-500">event_busy</span>
                            <label class="form-label text-amber-600 mb-0">Khung giờ đã có người đặt</label>
                        </div>
                        <div id="timeline-slots" class="flex flex-wrap gap-1.5"></div>
                    </div>

                    <div id="overlap-warning" class="bg-red-50 border border-red-200 text-red-700 p-3 text-xs hidden flex gap-2 items-start">
                        <span class="material-symbols-outlined text-[16px] mt-0.5 text-red-500 flex-shrink-0">warning</span>
                        <span id="overlap-warning-text">Trùng lịch!</span>
                    </div>

                    <!-- Live cost preview -->
                    <div id="live-cost-preview" class="hidden bg-[#FFF1E5] border border-[#e3000f]/40 p-4 flex items-center justify-between gap-4">
                        <div class="space-y-0.5">
                            <p class="text-[10px] font-bold uppercase tracking-widest text-neutral-400 font-['Barlow_Condensed']">Ước tính chi phí</p>
                            <p class="font-['Barlow_Condensed'] font-bold text-[#e3000f] text-2xl" id="live-cost-amount">-</p>
                        </div>
                        <div class="text-right space-y-0.5">
                            <p class="text-[10px] text-neutral-400 font-bold font-['Barlow_Condensed'] uppercase tracking-wider" id="live-cost-duration">-</p>
                            <p class="text-[10px] text-neutral-500 font-semibold" id="live-cost-rate">-</p>
                            <p id="live-cost-lights" class="text-[10px] text-amber-600 font-bold hidden flex items-center gap-0.5">
                                <span class="material-symbols-outlined text-[11px]">wb_twilight</span> Có phụ thu đèn
                            </p>
                        </div>
                    </div>

                    <!-- Dịch vụ đi kèm (Phase 8A / 8A.2 redesign) -->
                    <div>
                        <label class="mb-0.5 flex items-center gap-1.5 text-[13px] font-bold text-neutral-900 font-['Barlow_Condensed'] uppercase tracking-wide">
                            <span class="material-symbols-outlined text-[16px] text-[#e3000f]">local_cafe</span>
                            Dịch vụ đi kèm <span class="text-neutral-400 font-medium normal-case tracking-normal">(không bắt buộc)</span>
                        </label>
                        <p class="text-[11px] text-neutral-500 mb-2.5 ml-[22px]">Chọn trước dịch vụ để cơ sở chuẩn bị. Thanh toán tại quầy.</p>

                        <div id="booking-services-loading" class="flex items-center gap-2 text-xs text-neutral-500 py-4 justify-center border border-neutral-200 rounded-lg bg-neutral-50 hidden">
                            <span class="material-symbols-outlined text-[16px] animate-spin">progress_activity</span> Đang tải dịch vụ...
                        </div>

                        <div id="booking-services-error" class="flex flex-col items-center gap-2 text-center py-4 px-3 border border-red-200 rounded-lg bg-red-50 hidden">
                            <span class="text-xs font-semibold text-red-600">Không tải được dịch vụ. Vui lòng thử lại.</span>
                            <button type="button" onclick="loadBookingServices(selectedCourtId)"
                                class="text-[11px] font-bold uppercase tracking-wide px-3 py-1.5 border border-red-300 text-red-600 hover:bg-red-100 rounded-md transition-colors">
                                Tải lại
                            </button>
                        </div>

                        <div id="booking-services-empty" class="text-xs text-neutral-500 py-4 px-3 text-center border border-dashed border-neutral-200 rounded-lg bg-neutral-50 hidden">
                            Cơ sở này chưa có dịch vụ đi kèm.
                        </div>

                        <div id="booking-services-list" class="border border-neutral-200 rounded-lg divide-y divide-neutral-100 max-h-64 overflow-y-auto bg-white shadow-sm hidden"></div>

                        <div id="booking-services-total-row" class="hidden flex items-center justify-between mt-2.5 px-3.5 py-2.5 bg-[#FFF1E5] border border-[#e3000f]/40 rounded-lg">
                            <span class="text-[11px] font-bold uppercase tracking-widest text-[#c2000d] font-['Barlow_Condensed']">Tổng dịch vụ</span>
                            <span id="booking-services-total" class="text-base font-bold text-[#e3000f] font-['Barlow_Condensed']">0 đ</span>
                        </div>

                        <p class="text-[11px] text-neutral-500 mt-2 leading-relaxed flex items-start gap-1.5">
                            <span class="material-symbols-outlined text-[13px] mt-0.5 text-neutral-400">info</span>
                            Dịch vụ sẽ được chuẩn bị tại cơ sở và thanh toán tại quầy.
                        </p>
                    </div>

                    <!-- Notes -->
                    <div>
                        <label for="ghiChu" class="form-label mb-2 flex items-center gap-1.5">
                            <span class="material-symbols-outlined text-[14px] text-neutral-400">edit_note</span>
                            Ghi chú yêu cầu
                        </label>
                        <textarea name="ghiChu" id="ghiChu" rows="2"
                            class="w-full px-4 py-3 border border-neutral-200 bg-white text-sm text-[#111] placeholder-neutral-300 font-['Barlow'] resize-none focus:outline-none focus:ring-1 focus:ring-[#c2000d] focus:border-[#c2000d] transition-all"
                            placeholder="Thuê bóng, mượn áo tập, yêu cầu khác..."></textarea>
                    </div>
                </div>

                <!-- Footer actions -->
                <div class="px-6 pb-6 flex items-center justify-between gap-3 border-t border-neutral-100 pt-4">
                    <button type="button" onclick="closeBookingModal()"
                        class="px-5 py-2.5 font-['Barlow_Condensed'] font-bold text-neutral-500 border border-neutral-200 hover:border-neutral-400 hover:text-neutral-700 uppercase tracking-widest text-[11px] transition-colors">
                        Hủy
                    </button>
                    <c:choose>
                        <c:when test="${sessionScope.user != null}">
                            <button type="button" id="next-checkout-btn" onclick="goToCheckout()" disabled
                                class="flex-1 max-w-xs py-3 font-['Barlow_Condensed'] font-bold text-white bg-[#e3000f] hover:bg-[#c2000d] uppercase tracking-widest text-[13px] transition-colors disabled:opacity-40 disabled:cursor-not-allowed flex items-center justify-center gap-2">
                                Tiếp tục thanh toán <span class="material-symbols-outlined text-[16px]">arrow_forward</span>
                            </button>
                        </c:when>
                        <c:otherwise>
                            <a href="${pageContext.request.contextPath}/dangnhap"
                                class="flex-1 max-w-xs py-3 font-['Barlow_Condensed'] font-bold text-white bg-[#e3000f] hover:bg-[#c2000d] uppercase tracking-widest text-[13px] transition-colors flex items-center justify-center gap-2">
                                Đăng nhập để đặt <span class="material-symbols-outlined text-[16px]">login</span>
                            </a>
                        </c:otherwise>
                    </c:choose>
                </div>
            </form>
        </div>

        <!-- Step 2: Checkout -->
        <div id="checkoutPanel" class="bg-white w-full max-w-md shadow-2xl overflow-hidden transform scale-95 transition-all duration-300 hidden relative my-auto" style="border-radius:0;">
            <!-- Header -->
            <div class="bg-[#111111] px-6 py-4 flex items-center gap-3">
                <button onclick="backToBookingForm()" class="w-8 h-8 flex items-center justify-center text-white/60 hover:text-white hover:bg-white/10 transition-colors flex-shrink-0">
                    <span class="material-symbols-outlined text-[18px]">arrow_back</span>
                </button>
                <div>
                    <p class="text-[10px] text-white/50 font-bold uppercase tracking-[0.15em] font-['Barlow_Condensed']">Bước 2 / 2</p>
                    <h3 class="font-['Barlow_Condensed'] font-bold text-white text-base uppercase tracking-wider leading-tight">Xác nhận &amp; thanh toán</h3>
                </div>
            </div>

            <div class="p-6 space-y-5">
                <!-- Order summary -->
                <div class="border border-neutral-200 overflow-hidden">
                    <div class="bg-[#f4f3f0] px-4 py-2.5 border-b border-neutral-200">
                        <p class="text-[10px] font-bold uppercase tracking-widest text-neutral-500 font-['Barlow_Condensed']">Thông tin đặt sân</p>
                    </div>
                    <div class="p-4 space-y-2.5 text-sm">
                        <div class="flex justify-between items-center text-neutral-600">
                            <span class="flex items-center gap-1.5 text-xs"><span class="material-symbols-outlined text-[14px]">access_time</span>Thời gian chơi</span>
                            <span id="summary-duration" class="font-bold text-neutral-800 font-['Barlow_Condensed']">-</span>
                        </div>
                        <div class="flex justify-between items-center text-neutral-600">
                            <span class="flex items-center gap-1.5 text-xs"><span class="material-symbols-outlined text-[14px]">sell</span>Đơn giá</span>
                            <span id="summary-rate" class="font-bold text-neutral-800 font-['Barlow_Condensed']">-</span>
                        </div>
                        <div id="summary-lights-row" class="flex justify-between items-center text-amber-600 hidden">
                            <span class="flex items-center gap-1.5 text-xs"><span class="material-symbols-outlined text-[14px]">wb_twilight</span>Phụ thu đèn tối</span>
                            <span class="font-bold text-xs">Có áp dụng</span>
                        </div>
                        <div class="pt-3 mt-1 border-t border-neutral-200 flex justify-between items-center">
                            <span class="text-xs font-bold uppercase text-neutral-500 tracking-wider font-['Barlow_Condensed']">Tiền sân</span>
                            <span id="summary-total" class="text-2xl font-bold text-[#e3000f] font-['Barlow_Condensed']">-</span>
                        </div>
                        <div id="summary-services-row" class="hidden flex justify-between items-center text-neutral-600">
                            <span class="flex items-center gap-1.5 text-xs"><span class="material-symbols-outlined text-[14px]">local_cafe</span>Dịch vụ đi kèm <span class="text-[9px] text-neutral-400">(tại quầy)</span></span>
                            <span id="summary-services-total" class="font-bold text-neutral-800 font-['Barlow_Condensed']">-</span>
                        </div>
                        <div id="summary-grand-total-row" class="hidden pt-2 border-t border-dashed border-neutral-200 flex justify-between items-center">
                            <span class="text-xs font-bold uppercase text-neutral-500 tracking-wider font-['Barlow_Condensed']">Tổng dự kiến</span>
                            <span id="summary-grand-total" class="text-lg font-bold text-neutral-800 font-['Barlow_Condensed']">-</span>
                        </div>
                    </div>
                </div>

                <!-- Payment method -->
                <div>
                    <label class="form-label mb-3 flex items-center gap-1.5">
                        <span class="material-symbols-outlined text-[14px] text-[#e3000f]">payment</span>
                        Phương thức thanh toán
                    </label>
                    <div class="grid grid-cols-2 gap-2.5">
                        <button type="button" onclick="selectPaymentMethod('payos')" id="payment-opt-payos"
                            class="flex flex-col items-center justify-center py-4 px-3 border-2 border-neutral-200 hover:border-[#e3000f]/40 transition-all text-center gap-2 active:scale-95">
                            <span class="material-symbols-outlined text-[24px] text-[#e3000f]">qr_code_2</span>
                            <span class="text-xs font-extrabold text-neutral-800 font-['Barlow_Condensed'] uppercase tracking-wide">PayOS</span>
                            <span class="text-[9px] text-neutral-400 font-bold">Giữ sân 10 phút</span>
                        </button>
                        <button type="button" onclick="selectPaymentMethod('sau')" id="payment-opt-sau"
                            class="flex flex-col items-center justify-center py-4 px-3 border-2 border-neutral-200 hover:border-[#e3000f]/40 transition-all text-center gap-2 active:scale-95">
                            <span class="material-symbols-outlined text-[24px] text-neutral-500">payments</span>
                            <span class="text-xs font-extrabold text-neutral-800 font-['Barlow_Condensed'] uppercase tracking-wide">Tại quầy</span>
                            <span class="text-[9px] text-neutral-400 font-bold">Đặt cọc tiền mặt</span>
                        </button>
                    </div>
                </div>

                <!-- Payment info panels -->
                <div id="payment-info-sau" class="bg-neutral-50 border border-neutral-200 p-4 flex items-start gap-3">
                    <div class="w-8 h-8 bg-white flex items-center justify-center border border-neutral-200 flex-shrink-0">
                        <span class="material-symbols-outlined text-[16px] text-neutral-500">schedule</span>
                    </div>
                    <div>
                        <p class="text-xs font-bold text-neutral-800">Thanh toán tiền mặt tại quầy</p>
                        <p class="text-[11px] text-neutral-500 mt-1 leading-relaxed">Vui lòng đến trước 15 phút để làm thủ tục nhận sân và thanh toán.</p>
                    </div>
                </div>
                <div id="payment-info-payos" class="hidden bg-[#F0FCFE] border border-[#c2000d]/40 p-4 flex items-start gap-3">
                    <div class="w-8 h-8 bg-[#e3000f] flex items-center justify-center flex-shrink-0">
                        <span class="material-symbols-outlined text-[16px] text-white">bolt</span>
                    </div>
                    <div>
                        <p class="text-xs font-bold text-neutral-800">Chuyển khoản, giữ sân tức thì 10 phút</p>
                        <p class="text-[11px] text-neutral-500 mt-1 leading-relaxed">Mã QR sẽ được tạo tự động. Hoàn tất trong 10 phút để giữ sân.</p>
                    </div>
                </div>

                <button onclick="confirmBooking()"
                    class="w-full bg-[#e3000f] hover:bg-[#c2000d] text-white font-['Barlow_Condensed'] font-bold h-13 py-3.5 text-[13px] uppercase tracking-widest transition-colors flex items-center justify-center gap-2">
                    <span class="material-symbols-outlined text-[18px]">verified</span> Hoàn tất đặt sân
                </button>
            </div>
        </div>
    </div>



    <!-- ════ CUSTOMER SERVICE MODAL ════ -->
    <div id="customerServiceModal" class="fixed inset-0 backdrop-blur-sm z-[210] hidden flex items-center justify-center opacity-0 transition-opacity duration-300 overflow-y-auto py-10 px-4" style="background-color: var(--vs-overlay, rgba(7, 26, 47, 0.68));">
        <div class="bg-white w-full max-w-2xl rounded-none border border-neutral-200 shadow-2xl overflow-hidden transform scale-95 transition-all duration-300 relative my-auto">
            <div class="bg-[#111111] px-6 py-4 flex items-center justify-between text-white border-b border-neutral-800">
                <h3 class="font-['Barlow_Condensed'] font-bold text-lg uppercase tracking-wider flex items-center gap-2">
                    <span class="material-symbols-outlined text-[20px]">coffee</span> Đặt thêm Dịch vụ / Nước uống
                </h3>
                <button onclick="closeCustomerServiceModal()" class="text-white/80 hover:text-white p-1 transition-colors">
                    <span class="material-symbols-outlined text-[20px]">close</span>
                </button>
            </div>
            <div class="p-6 md:p-8 max-h-[70vh] overflow-y-auto">
                <form id="customer-service-form" action="${pageContext.request.contextPath}/customer/dat-dich-vu" method="post" class="space-y-6">
                    <input type="hidden" name="datSanId" id="customer-service-datsan-id">
                    <div id="customer-service-loading" class="text-center py-10 text-neutral-500">
                        <span class="material-symbols-outlined animate-spin text-[32px] text-primary mb-2">sync</span>
                        <p class="text-sm font-medium">Đang tải danh sách dịch vụ...</p>
                    </div>
                    <div id="customer-service-container" class="hidden space-y-4">
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4" id="customer-products-grid"></div>
                    </div>
                    <div class="pt-6 border-t border-neutral-100 flex justify-between items-center">
                        <div>
                            <span class="text-xs font-bold text-neutral-400 uppercase tracking-wider block">Tổng tiền dịch vụ thêm</span>
                            <span class="text-2xl font-bold text-[#e3000f] font-['Barlow_Condensed']" id="customer-service-total">0 đ</span>
                        </div>
                        <div class="flex gap-3">
                            <button type="button" onclick="closeCustomerServiceModal()" class="px-6 py-3 rounded-none font-['Barlow_Condensed'] font-bold text-neutral-500 bg-neutral-100 hover:bg-neutral-200 uppercase tracking-widest text-[12px] transition-colors">Hủy</button>
                            <button type="submit" class="px-8 py-3 rounded-none font-['Barlow_Condensed'] font-bold text-white bg-[#e3000f] hover:bg-[#c2000d] uppercase tracking-widest text-[12px] transition-all">Xác nhận đặt</button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- ════ MAIN JAVASCRIPT ════ -->
    <script>
        // ─── PayOS error alert actions (Thử lại / Thanh toán tại quầy) ───
        (function () {
            const CTX = '${pageContext.request.contextPath}';
            const alertEl = document.getElementById('payosAlert');
            if (!alertEl) return;
            const datSanId = alertEl.getAttribute('data-datsanid');
            const descEl = document.getElementById('payosAlertDesc');
            const retryBtn = document.getElementById('payosRetryBtn');
            const counterBtn = document.getElementById('payosPayCounterBtn');

            function setButtonBusy(btn, busyLabel) {
                if (!btn) return () => {};
                const original = btn.textContent;
                btn.disabled = true;
                btn.textContent = busyLabel;
                return function restore() { btn.disabled = false; btn.textContent = original; };
            }

            if (retryBtn) {
                retryBtn.addEventListener('click', function () {
                    const restore = setButtonBusy(retryBtn, 'Đang tạo liên kết...');
                    if (counterBtn) counterBtn.disabled = true;
                    fetch(CTX + '/customer/payos-retry', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
                        body: 'datSanId=' + encodeURIComponent(datSanId)
                    })
                        .then(r => r.json())
                        .then(data => {
                            if (data.success && data.redirectUrl) {
                                // Luồng mới: mở trang QR nhúng của V-SPORT (không redirect checkout PayOS).
                                window.location.href = data.redirectUrl;
                                return;
                            }
                            restore();
                            if (counterBtn) counterBtn.disabled = false;
                            if (descEl) descEl.textContent = data.message || 'Không thể tạo liên kết thanh toán. Vui lòng thử lại.';
                            if (retryBtn && data.retryable === false) retryBtn.remove();
                        })
                        .catch(() => {
                            restore();
                            if (counterBtn) counterBtn.disabled = false;
                            if (descEl) descEl.textContent = 'Không thể kết nối máy chủ. Vui lòng thử lại.';
                        });
                });
            }

            if (counterBtn) {
                counterBtn.addEventListener('click', function () {
                    const restore = setButtonBusy(counterBtn, 'Đang xử lý...');
                    if (retryBtn) retryBtn.disabled = true;
                    fetch(CTX + '/customer/payos-pay-counter', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
                        body: 'datSanId=' + encodeURIComponent(datSanId)
                    })
                        .then(r => r.json())
                        .then(data => {
                            if (data.success) {
                                window.location.href = CTX + '/customer/dat-san?openHistory=true';
                                return;
                            }
                            restore();
                            if (retryBtn) retryBtn.disabled = false;
                            if (descEl) descEl.textContent = data.message || 'Không thể chuyển sang thanh toán tại quầy. Vui lòng thử lại.';
                        })
                        .catch(() => {
                            restore();
                            if (retryBtn) retryBtn.disabled = false;
                            if (descEl) descEl.textContent = 'Không thể kết nối máy chủ. Vui lòng thử lại.';
                        });
                });
            }
        })();

        // ─── Date init ───
        const dateInput = document.getElementById('ngayDat');
        const todayStr = new Date().toISOString().split('T')[0];
        if (dateInput) { dateInput.min = todayStr; dateInput.value = todayStr; }
        const quickDate = document.getElementById('quick-date-input');
        if (quickDate) quickDate.value = todayStr;

        // Custom Dropdowns Logic
        document.addEventListener('DOMContentLoaded', () => {
            const setupCustomSelect = (triggerId, optionsId, labelId, selectId, iconId = null) => {
                const trigger = document.getElementById(triggerId);
                const optionsPanel = document.getElementById(optionsId);
                const label = document.getElementById(labelId);
                const selectEl = document.getElementById(selectId);
                if (!trigger || !optionsPanel || !label || !selectEl) return;

                // Toggle dropdown panel
                trigger.addEventListener('click', (e) => {
                    e.stopPropagation();
                    const arrow = trigger.querySelector('.select-arrow');
                    // Close all other dropdowns first
                    document.querySelectorAll('[id$="-options"]').forEach(p => {
                        if (p.id !== optionsId) {
                            p.classList.add('hidden');
                            p.parentElement.querySelector('.select-arrow')?.classList.remove('rotate-180');
                        }
                    });
                    optionsPanel.classList.toggle('hidden');
                    if (arrow) arrow.classList.toggle('rotate-180');
                });

                // Select option
                optionsPanel.querySelectorAll('.custom-option').forEach(opt => {
                    opt.addEventListener('click', (e) => {
                        e.stopPropagation();
                        const val = opt.getAttribute('data-value');
                        selectEl.value = val;
                        // Trigger select change event
                        selectEl.dispatchEvent(new Event('change'));
                        
                        // Update trigger label
                        const textNode = opt.querySelector('.font-bold') || opt;
                        label.textContent = textNode.textContent.trim();

                        // Update trigger icon if present
                        if (iconId) {
                            const optIcon = opt.querySelector('.material-symbols-outlined');
                            const triggerIcon = document.getElementById(iconId);
                            if (optIcon && triggerIcon) {
                                triggerIcon.textContent = optIcon.textContent.trim();
                            }
                        }

                        optionsPanel.classList.add('hidden');
                        trigger.querySelector('.select-arrow')?.classList.remove('rotate-180');
                    });
                });
            };

            setupCustomSelect('custom-sport-trigger', 'custom-sport-options', 'custom-sport-label', 'hero-sport-select', 'custom-sport-icon');
            setupCustomSelect('custom-branch-trigger', 'custom-branch-options', 'custom-branch-label', 'hero-branch-select');

            // Close dropdowns when clicking outside
            document.addEventListener('click', () => {
                document.querySelectorAll('[id$="-options"]').forEach(p => p.classList.add('hidden'));
                document.querySelectorAll('.select-arrow').forEach(a => a.classList.remove('rotate-180'));
            });
        });

        const DEFAULT_OPEN_TIME = "06:00";
        const DEFAULT_CLOSE_TIME = "23:00";

        // ─── Data bridge ───
        const branches = {
            <c:forEach var="cs" items="${dsCoSo}" varStatus="status">
                "${cs.coSoID}": {
                    id: ${cs.coSoID},
                    name: `<c:out value="${cs.tenCoSo}"/>`,
                    address: `<c:out value="${cs.diaChi}"/>`,
                    openTime: "${cs.gioMoCua != null ? cs.gioMoCua : '06:00:00'}",
                    closeTime: "${cs.gioDongCua != null ? cs.gioDongCua : '23:00:00'}"
                }${not status.last ? ',' : ''}
            </c:forEach>
        };

        const sports = {
            <c:forEach var="m" items="${dsMon}" varStatus="status">
                "${m.monTheThaoID}": `<c:out value="${m.tenMon}"/>`.trim()${not status.last ? ',' : ''}
            </c:forEach>
        };

        const courtTypes = {
            <c:forEach var="l" items="${dsLoai}" varStatus="status">
                "${l.loaiSanID}": {
                    id: ${l.loaiSanID},
                    sportId: ${l.monTheThaoID},
                    name: `<c:out value="${l.tenLoai}"/>`.trim(),
                    priceDay: ${l.giaKhongDen},
                    priceNight: ${l.giaCoDen},
                    lightTime: `${l.gioBatDauLenDen}`,
                    branchId: ${l.coSoID != null ? l.coSoID : 'null'}
                }${not status.last ? ',' : ''}
            </c:forEach>
        };

        const courts = [
            <c:forEach var="s" items="${dsSan}" varStatus="status">
                {
                    id: ${s.sanID},
                    name: `<c:out value="${s.tenSan}"/>`.trim(),
                    typeId: ${s.loaiSanID},
                    branchId: ${s.coSoID},
                    status: `<c:out value="${s.trangThai}"/>`.trim(),
                    image: `<c:out value="${s.hinhAnh != null ? s.hinhAnh : ''}"/>`.trim()
                }${not status.last ? ',' : ''}
            </c:forEach>
        ];

        const activeBookings = [
            <c:forEach var="b" items="${activeBookings}" varStatus="status">
                {
                    id: ${b.datSanId},
                    sanId: ${b.sanId != null ? b.sanId : 'null'},
                    date: `${b.ngayDat}`,
                    start: `${b.gioBatDau}`,
                    end: `${b.gioKetThuc}`,
                    status: `<c:out value="${b.trangThai}"/>`.trim()
                }${not status.last ? ',' : ''}
            </c:forEach>
        ];

        // ─── State ───
        let selectedBranchId = 0;
        let selectedSportId = 0;
        let selectedCourtId = null;
        let currentTotalCost = 0;
        let selectedLocationQuery = "";

        // ===== Dịch vụ đi kèm (Phase 8A) =====
        let bookingServicesCatalog = [];   // [{sanPhamId, tenSanPham, donGia, donViTinh, soLuongTon}]
        let selectedServiceQty = {};       // { [sanPhamId]: qty }

        // Đơn vị tính (DonViTinh) đôi khi chứa dữ liệu rác trong DB (vd: "-5452").
        // Chỉ hiển thị nếu là chuỗi chữ hợp lệ, không phải số/số âm.
        function isSaneUnit(donViTinh) {
            if (donViTinh === null || donViTinh === undefined) return false;
            const s = String(donViTinh).trim();
            if (s === '') return false;
            if (/^-?\d+(\.\d+)?$/.test(s)) return false;
            return true;
        }

        function formatServicePrice(sp) {
            const priceStr = Math.round(sp.donGia).toLocaleString('vi-VN') + ' đ';
            return isSaneUnit(sp.donViTinh) ? priceStr + ' / ' + sp.donViTinh : priceStr;
        }

        function formatServiceStock(sp) {
            if (sp.soLuongTon === null || sp.soLuongTon === undefined) return null;
            return sp.soLuongTon > 0 ? ('Còn ' + sp.soLuongTon) : 'Hết hàng';
        }

        function loadBookingServices(courtId) {
            selectedServiceQty = {};
            bookingServicesCatalog = [];
            const listEl = document.getElementById("booking-services-list");
            const loadingEl = document.getElementById("booking-services-loading");
            const emptyEl = document.getElementById("booking-services-empty");
            const errorEl = document.getElementById("booking-services-error");
            if (!listEl) return;
            listEl.innerHTML = "";
            listEl.classList.add("hidden");
            emptyEl.classList.add("hidden");
            errorEl.classList.add("hidden");
            document.getElementById("booking-services-total-row").classList.add("hidden");
            loadingEl.classList.remove("hidden");
            fetch(`${pageContext.request.contextPath}/customer/booking-services?sanId=\${courtId}`)
                .then(r => {
                    if (!r.ok) {
                        console.error('[BookingServices] HTTP', r.status, r.statusText);
                        throw new Error('HTTP ' + r.status);
                    }
                    return r.json();
                })
                .then(data => {
                    loadingEl.classList.add("hidden");
                    bookingServicesCatalog = data.services || [];
                    renderBookingServices();
                })
                .catch(err => {
                    console.error('[BookingServices] Lỗi tải dịch vụ:', err);
                    loadingEl.classList.add("hidden");
                    errorEl.classList.remove("hidden");
                });
        }

        function renderBookingServices() {
            const listEl = document.getElementById("booking-services-list");
            const emptyEl = document.getElementById("booking-services-empty");
            if (!listEl) return;
            if (!bookingServicesCatalog.length) {
                listEl.innerHTML = "";
                listEl.classList.add("hidden");
                emptyEl.classList.remove("hidden");
                updateServiceTotal();
                return;
            }
            emptyEl.classList.add("hidden");
            listEl.classList.remove("hidden");
            listEl.innerHTML = bookingServicesCatalog.map(sp => {
                const qty = selectedServiceQty[sp.sanPhamId] || 0;
                const outOfStock = sp.soLuongTon !== undefined && sp.soLuongTon !== null && sp.soLuongTon <= 0;
                const atMax = sp.soLuongTon !== undefined && sp.soLuongTon !== null && qty >= sp.soLuongTon;
                const isSelected = qty > 0;
                const stockText = formatServiceStock(sp);
                const rowClasses = outOfStock
                    ? 'bg-neutral-50 opacity-60'
                    : (isSelected ? 'bg-[#FFF1E5] border-l-4 border-l-[#e3000f]' : 'bg-white hover:bg-neutral-50');
                const lineTotal = qty > 0 ? Math.round(sp.donGia * qty).toLocaleString('vi-VN') + ' đ' : null;
                return `
                <div class="flex items-center justify-between gap-3 px-3.5 py-3 transition-colors \${rowClasses}">
                    <div class="min-w-0 flex-1">
                        <p class="text-sm font-bold text-neutral-900 truncate">\${sp.tenSanPham}</p>
                        <div class="flex items-center gap-2 mt-0.5 flex-wrap">
                            <span class="text-xs font-semibold text-neutral-600">\${formatServicePrice(sp)}</span>
                            \${stockText ? `<span class="text-[10px] font-bold px-1.5 py-0.5 rounded \${outOfStock ? 'bg-neutral-200 text-neutral-500' : 'bg-neutral-100 text-neutral-600'}">\${stockText}</span>` : ''}
                        </div>
                        \${lineTotal ? `<p class="text-[11px] font-bold text-[#e3000f] mt-1">Thành tiền: \${lineTotal}</p>` : ''}
                    </div>
                    <div class="flex items-center gap-2.5 flex-shrink-0">
                        <button type="button" onclick="changeServiceQty(\${sp.sanPhamId}, -1)" \${(outOfStock || qty === 0) ? 'disabled' : ''}
                            class="w-8 h-8 flex items-center justify-center rounded-md border-2 font-bold text-base leading-none transition-colors \${(outOfStock || qty === 0) ? 'border-neutral-200 text-neutral-300 cursor-not-allowed' : 'border-neutral-300 text-neutral-700 hover:border-[#e3000f] hover:bg-[#e3000f] hover:text-white active:scale-95'}">−</button>
                        <span class="w-6 text-center text-sm font-bold text-neutral-900">\${qty}</span>
                        <button type="button" onclick="changeServiceQty(\${sp.sanPhamId}, 1)" \${(outOfStock || atMax) ? 'disabled' : ''}
                            class="w-8 h-8 flex items-center justify-center rounded-md border-2 font-bold text-base leading-none transition-colors \${(outOfStock || atMax) ? 'border-neutral-200 text-neutral-300 cursor-not-allowed' : 'border-neutral-300 text-neutral-700 hover:border-[#e3000f] hover:bg-[#e3000f] hover:text-white active:scale-95'}">+</button>
                    </div>
                </div>`;
            }).join("");
            updateServiceTotal();
        }

        function changeServiceQty(sanPhamId, delta) {
            const sp = bookingServicesCatalog.find(s => s.sanPhamId === sanPhamId);
            if (!sp) return;
            const maxQty = (sp.soLuongTon !== undefined && sp.soLuongTon !== null) ? sp.soLuongTon : 999;
            let qty = (selectedServiceQty[sanPhamId] || 0) + delta;
            if (qty < 0) qty = 0;
            if (qty > maxQty) qty = maxQty;
            if (qty === 0) delete selectedServiceQty[sanPhamId];
            else selectedServiceQty[sanPhamId] = qty;
            renderBookingServices();
        }

        function getServicesTotal() {
            return Object.entries(selectedServiceQty).reduce((sum, [id, qty]) => {
                const sp = bookingServicesCatalog.find(s => s.sanPhamId === Number(id));
                return sum + (sp ? sp.donGia * qty : 0);
            }, 0);
        }

        function updateServiceTotal() {
            const total = getServicesTotal();
            const rowEl = document.getElementById("booking-services-total-row");
            const totalEl = document.getElementById("booking-services-total");
            if (rowEl && totalEl) {
                if (total > 0) {
                    rowEl.classList.remove("hidden");
                    totalEl.textContent = Math.round(total).toLocaleString('vi-VN') + ' đ';
                } else {
                    rowEl.classList.add("hidden");
                }
            }
            // Đồng bộ sang tóm tắt bước 2 (checkout)
            const svcRow = document.getElementById("summary-services-row");
            const svcTotalEl = document.getElementById("summary-services-total");
            const grandRow = document.getElementById("summary-grand-total-row");
            const grandEl = document.getElementById("summary-grand-total");
            if (svcRow && svcTotalEl) {
                if (total > 0) {
                    svcRow.classList.remove("hidden");
                    svcTotalEl.textContent = Math.round(total).toLocaleString('vi-VN') + ' đ';
                } else {
                    svcRow.classList.add("hidden");
                }
            }
            if (grandRow && grandEl) {
                if (total > 0) {
                    grandRow.classList.remove("hidden");
                    grandEl.textContent = Math.round(currentTotalCost + total).toLocaleString('vi-VN') + ' đ';
                } else {
                    grandRow.classList.add("hidden");
                }
            }
        }

        function injectServiceInputsIntoForm(form) {
            form.querySelectorAll('input[name="serviceId"], input[name="serviceQty"]').forEach(el => el.remove());
            Object.entries(selectedServiceQty).forEach(([sanPhamId, qty]) => {
                if (qty <= 0) return;
                const idInput = document.createElement('input');
                idInput.type = 'hidden'; idInput.name = 'serviceId'; idInput.value = sanPhamId;
                form.appendChild(idInput);
                const qtyInput = document.createElement('input');
                qtyInput.type = 'hidden'; qtyInput.name = 'serviceQty'; qtyInput.value = qty;
                form.appendChild(qtyInput);
            });
        }

        const urlParams = new URLSearchParams(window.location.search);
        const paramSportId = parseInt(urlParams.get('sportId')) || 0;
        const paramBranchId = parseInt(urlParams.get('branchId')) || 0;
        const paramDate = urlParams.get('date');
        if (paramBranchId) selectedBranchId = paramBranchId;
        if (paramSportId) selectedSportId = paramSportId;
        if (paramDate && dateInput) dateInput.value = paramDate;

        // ─── Branch bar toggle ───
        function toggleBranchBar() {
            const bar = document.getElementById('branch-bar');
            if (!bar) return;
            bar.classList.toggle('hidden');
            bar.classList.toggle('flex');
        }

        // ─── Map view (Phase 3, route /customer/ban-do) ───
        function showMapComingSoon() {
            if (window.__vsToastTimer) clearTimeout(window.__vsToastTimer);
            let el = document.getElementById('mapComingSoonToast');
            if (!el) {
                el = document.createElement('div');
                el.id = 'mapComingSoonToast';
                el.setAttribute('role', 'status');
                el.className = 'fixed left-1/2 z-[400] px-4 py-2.5 rounded-full text-[13px] font-semibold text-white shadow-lg';
                el.style.cssText = 'bottom:88px;transform:translateX(-50%) translateY(12px);background:#0f172a;opacity:0;transition:opacity .2s ease, transform .2s ease;';
                document.body.appendChild(el);
            }
            el.textContent = 'Chế độ xem bản đồ sắp ra mắt';
            requestAnimationFrame(() => { el.style.opacity = '1'; el.style.transform = 'translateX(-50%) translateY(0)'; });
            window.__vsToastTimer = setTimeout(() => {
                el.style.opacity = '0';
                el.style.transform = 'translateX(-50%) translateY(12px)';
            }, 2000);
        }

        // ─── Status helpers ───
        function getCourtStatusInfo(status) {
            const s = (status || '').trim();
            if (s === 'Sẵn sàng') return { label: 'Sẵn Sàng', bookable: true, actionDisabled: false, actionLabel: 'Đặt sân', badgeClass: 'border-[#16A36A] text-[#16A36A] bg-white/95', dotClass: 'bg-[#16A36A] animate-pulse' };
            if (s === 'Đang dùng') return { label: 'Đang Dùng', bookable: false, actionDisabled: true, actionLabel: 'Đang dùng', badgeClass: 'border-[#427CF0] text-[#427CF0] bg-white/95', dotClass: 'bg-amber-400 animate-pulse' };
            if (s === 'Bảo trì' || s === 'Đang bảo trì' || s === 'Tạm đóng') return { label: s, bookable: false, actionDisabled: true, actionLabel: 'Tạm đóng', badgeClass: 'border-neutral-300 text-neutral-500 bg-white/95', dotClass: '' };
            return { label: s || 'Không rõ', bookable: false, actionDisabled: true, actionLabel: 'Chi tiết', badgeClass: 'border-neutral-300 text-neutral-500 bg-white/95', dotClass: '' };
        }

        // ─── Render Courts (masonry / PitchPerfect cards) ───
        function renderCourts() {
            try {
            const container = document.getElementById("courts-container");
            if (!container) return;
            container.innerHTML = "";

            const filteredCourts = courts.filter(c => {
                const matchBranch = (selectedBranchId === 0 || c.branchId === selectedBranchId);
                const type = courtTypes[c.typeId];
                const matchSport = (selectedSportId === 0 || (type && type.sportId === selectedSportId));
                const branch = branches[c.branchId] || {};
                const searchQ = (selectedLocationQuery || '').toLowerCase().trim();
                const matchLocation = !searchQ ||
                    (branch.address || '').toLowerCase().includes(searchQ) ||
                    (branch.name || '').toLowerCase().includes(searchQ);
                return matchBranch && matchSport && matchLocation;
            });

            document.getElementById("court-count").textContent = filteredCourts.length;

            const availableCount = filteredCourts.filter(c => c.status === 'Sẵn sàng').length;
            const inUseCount = filteredCourts.filter(c => c.status === 'Đang dùng').length;
            const otherCount = filteredCourts.length - availableCount - inUseCount;
            const parts = [];
            if (availableCount > 0) parts.push('<span style="color: var(--vs-success, #16A36A);">' + availableCount + ' trống</span>');
            if (inUseCount > 0) parts.push('<span class="text-amber-500">' + inUseCount + ' đang dùng</span>');
            if (otherCount > 0) parts.push('<span class="text-red-400">' + otherCount + ' không khả dụng</span>');
            document.getElementById("court-status-summary").innerHTML = parts.join(' · ');

            if (filteredCourts.length === 0) {
                container.innerHTML = `
                    <div class="text-center py-20 col-span-full">
                        <span class="material-symbols-outlined text-[64px] text-slate-200 block mb-4">search_off</span>
                        <p class="text-slate-500 font-medium">Không tìm thấy sân phù hợp.</p>
                        <button onclick="filterBranch(0); filterSport(0);" class="mt-4 text-primary font-bold hover:underline text-sm">Xóa bộ lọc</button>
                    </div>
                `;
                return;
            }

            filteredCourts.forEach(c => {
                const type = courtTypes[c.typeId] || { name: "Chưa phân loại", priceDay: 100000, priceNight: 100000, sportId: 0 };
                const branch = branches[c.branchId] || { name: "Cơ Sở", address: "", openTime: DEFAULT_OPEN_TIME, closeTime: DEFAULT_CLOSE_TIME };
                const sportName = sports[type.sportId] || "Thể thao";
                const statusInfo = getCourtStatusInfo(c.status);
                const priceText = type.priceDay.toLocaleString('vi-VN') + ' đ';

                // Choose image
                let imgUrl = "https://images.unsplash.com/photo-1518605368461-1ee7e57c6691?auto=format&fit=crop&w=600&q=80";
                const sn = sportName.toLowerCase();
                if (sn.includes("cầu lông") || sn.includes("pickleball")) imgUrl = "https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?auto=format&fit=crop&w=600&q=80";
                else if (sn.includes("tennis")) imgUrl = "https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0?auto=format&fit=crop&w=600&q=80";
                else if (sn.includes("bóng bàn")) imgUrl = "https://images.unsplash.com/photo-1534158914592-062992fbe900?auto=format&fit=crop&w=600&q=80";
                else if (sn.includes("gym") || sn.includes("fitness")) imgUrl = "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&w=600&q=80";
                if (c.image && c.image.trim() !== "" && (c.image.startsWith("http") || c.image.includes("/") || c.image.includes("."))) {
                    imgUrl = c.image;
                }
                const cardHtml = `
                    <div class="court-card flex flex-col bg-white border border-neutral-100 group" onclick="window.location.href='${pageContext.request.contextPath}/customer/chi-tiet-san?id=\${c.id}'">
                        <div class="court-card-media relative h-56 w-full overflow-hidden bg-neutral-100">
                            <img class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500" src="\${imgUrl}" alt="\${c.name}"/>
                            <div class="absolute top-3 left-3 z-10 font-['Barlow_Condensed'] font-bold text-[10px] tracking-widest uppercase px-3.5 py-1 border court-card-status \${statusInfo.badgeClass}">
                                \${statusInfo.label}
                            </div>
                        </div>
                        <div class="p-6 flex flex-col flex-grow">
                            <div class="mb-4">
                                <p class="font-['Barlow'] text-xs text-neutral-400 uppercase tracking-wider mb-1.5">\${branch.name}</p>
                                <h3 class="font-['Barlow_Condensed'] text-[24px] md:text-[26px] leading-tight font-bold text-[#111111] uppercase tracking-wide group-hover:text-primary transition-colors mb-2.5">\${c.name}</h3>
                                <div class="flex flex-wrap items-center gap-2 text-xs text-on-surface-variant">
                                    <span class="court-chip">\${sportName}</span>
                                    <span class="inline-flex items-center gap-1 rounded-none bg-neutral-100 px-2.5 py-0.5 font-semibold text-neutral-500 text-[11px]">
                                        <span class="material-symbols-outlined text-[14px]">schedule</span>
                                        \${branch.openTime.substring(0,5)} - \${branch.closeTime.substring(0,5)}
                                    </span>
                                </div>
                            </div>
                            <div class="mt-auto border-t border-neutral-100 pt-5 flex items-center justify-between gap-3">
                                <div>
                                    <p class="text-[10px] font-semibold text-neutral-400 uppercase tracking-widest mb-0.5">Giá thuê từ</p>
                                    <p class="text-[20px] font-bold text-[#111111] font-['Barlow_Condensed'] tracking-wide">\${priceText}<span class="text-[12px] font-semibold text-neutral-400 font-sans"> / giờ</span></p>
                                </div>
                                <button type="button" onclick="event.stopPropagation(); \${statusInfo.actionDisabled ? '' : 'openBookingModal(' + c.id + ')'}" \${statusInfo.actionDisabled ? 'disabled' : ''}
                                    class="court-card-cta inline-flex items-center justify-center rounded-none px-6 py-2.5 text-[12px] font-['Barlow_Condensed'] font-bold uppercase tracking-widest transition-all disabled:bg-neutral-200 disabled:text-neutral-400 disabled:border-neutral-200 disabled:cursor-not-allowed">
                                    \${statusInfo.actionLabel}
                                </button>
                            </div>
                        </div>
                    </div>`;
                container.insertAdjacentHTML("beforeend", cardHtml);
            });
            } catch (e) {
                console.error('[DatSan] renderCourts error:', e);
            }
        }

        // ─── Filter functions ───
        // ─── Đồng bộ mọi nơi hiển thị filter (search bar / chip row / dropdown nhỏ) ───
        function syncSportUI(sportId) {
            const heroSelect = document.getElementById('hero-sport-select');
            if (heroSelect) heroSelect.value = String(sportId);
            const row = document.getElementById('sport-chip-row');
            if (row) {
                row.querySelectorAll('.chip-filter').forEach(chip => chip.classList.remove('chip-filter-active'));
                const active = row.querySelector('[data-sport-id="' + sportId + '"]') ||
                    (sportId === 0 ? row.firstElementChild : null);
                if (active) active.classList.add('chip-filter-active');
            }
            // Update custom dropdown trigger
            const customOption = document.querySelector(`#custom-sport-options [data-value="${sportId}"]`);
            if (customOption) {
                const label = document.getElementById('custom-sport-label');
                if (label) {
                    label.textContent = customOption.textContent.replace(/sports_\w+|sports_soccer|sports_kabaddi|sports_tennis/g, '').trim();
                }
                const icon = customOption.querySelector('.material-symbols-outlined');
                const triggerIcon = document.getElementById('custom-sport-icon');
                if (icon && triggerIcon) {
                    triggerIcon.textContent = icon.textContent.trim();
                }
            }
        }

        function syncBranchUI(branchId) {
            ['hero-branch-select', 'branch-select-chip'].forEach(id => {
                const el = document.getElementById(id);
                if (el) el.value = String(branchId);
            });
            // Update custom dropdown trigger
            const customOption = document.querySelector(`#custom-branch-options [data-value="${branchId}"]`);
            if (customOption) {
                const label = document.getElementById('custom-branch-label');
                if (label) {
                    const textNode = customOption.querySelector('.text-neutral-800') || customOption;
                    label.textContent = textNode.textContent.trim();
                }
            }
        }

        function filterSport(sportId) {
            selectedSportId = Number(sportId);
            syncSportUI(selectedSportId);
            renderCourts();
        }

        function filterBranch(branchId) {
            selectedBranchId = Number(branchId);
            syncBranchUI(selectedBranchId);
            renderCourts();
        }

        function filterLocation(query) {
            selectedLocationQuery = query;
            renderCourts();
        }

        // Chip filter — data-sport-id đã được gắn sẵn lúc DOMContentLoaded,
        // syncSportUI() dùng nó để tô sáng đúng chip.
        function selectSportChip(sportId) {
            filterSport(sportId);
        }

        // ─── Event listeners ───
        document.addEventListener("DOMContentLoaded", () => {
            // Gắn data-sport-id cho từng chip theo đúng thứ tự render (chip đầu = "Tất cả" = 0)
            const chipRow = document.getElementById('sport-chip-row');
            if (chipRow) {
                Array.from(chipRow.children).forEach(chip => {
                    const match = chip.getAttribute('onclick').match(/selectSportChip\((\d+)/);
                    if (match) chip.dataset.sportId = match[1];
                });
            }

            const heroSportSelect = document.getElementById('hero-sport-select');
            if (heroSportSelect) heroSportSelect.addEventListener('change', e => filterSport(e.target.value));

            const heroBranchSelect = document.getElementById('hero-branch-select');
            if (heroBranchSelect) heroBranchSelect.addEventListener('change', e => filterBranch(e.target.value));

            const branchSelectChip = document.getElementById('branch-select-chip');
            if (branchSelectChip) branchSelectChip.addEventListener('change', e => filterBranch(e.target.value));

            const searchBtn = document.getElementById('btn-search-court');
            const searchIcon = document.getElementById('search-icon');
            const searchText = document.getElementById('search-text');
            if (searchBtn) {
                searchBtn.addEventListener('click', () => {
                    searchIcon.textContent = 'progress_activity';
                    searchIcon.classList.add('animate-spin');
                    searchText.textContent = 'Đang tìm...';
                    searchBtn.disabled = true;
                    renderCourts();
                    setTimeout(() => {
                        searchIcon.textContent = 'search';
                        searchIcon.classList.remove('animate-spin');
                        searchText.textContent = 'Tìm sân';
                        searchBtn.disabled = false;
                        document.getElementById('results-section').scrollIntoView({ behavior: 'smooth', block: 'start' });
                    }, 300);
                });
            }

            if (urlParams.get('openHistory') === 'true') openHistoryModal();

            // Tự mở modal khi đến từ trang chi-tiet-san (?open=courtId)
            const openCourtId = urlParams.get('open');
            if (openCourtId) {
                const id = parseInt(openCourtId, 10);
                if (!isNaN(id)) setTimeout(() => openBookingModal(id), 400);
            }
        });

        // ─── Booking modal helpers ───
        function normalizeTime(t) { return t ? t.substring(0, 5) : DEFAULT_OPEN_TIME; }

        function getBranchHours(branchId) {
            const b = branches[branchId];
            return {
                openTime: normalizeTime(b?.openTime || DEFAULT_OPEN_TIME),
                closeTime: normalizeTime(b?.closeTime || DEFAULT_CLOSE_TIME),
                name: b?.name || 'Cơ Sở'
            };
        }

        function timeToMinutes(t) {
            const p = t.split(':');
            return parseInt(p[0], 10) * 60 + parseInt(p[1], 10);
        }

        function formatDurationText(mins) {
            const h = Math.floor(mins / 60), m = mins % 60;
            return (h > 0 ? h + ' tiếng ' : '') + (m > 0 ? m + ' phút' : '');
        }

        function openBookingModal(courtId) {
            try {
            selectedCourtId = courtId;
            document.getElementById("input-san-id").value = courtId;
            const court = courts.find(c => c.id === courtId);
            if (!court) { console.warn('[Booking] Court not found:', courtId); return; }
            loadBookingServices(courtId);
            const type = courtTypes[court.typeId] || { name: "Không rõ", priceDay: 0, priceNight: 0, sportId: 0, lightTime: "17:30:00" };
            const branch = branches[court.branchId] || { name: "Cơ sở", address: "", openTime: DEFAULT_OPEN_TIME, closeTime: DEFAULT_CLOSE_TIME };
            document.getElementById("modal-court-name").textContent = court.name;
            document.getElementById("modal-court-branch").innerHTML = `<span class="material-symbols-outlined text-[13px] text-[#e3000f]">location_on</span> <span>\${branch.name}</span>`;
            document.getElementById("modal-court-type").textContent = type.name;

            // Set image dynamically
            const imgEl = document.getElementById("modal-court-img");
            if (imgEl) {
                const sn = (sports[type.sportId] || "Thể thao").toLowerCase();
                let defImg = "https://images.unsplash.com/photo-1518605368461-1ee7e57c6691?auto=format&fit=crop&w=600&q=80";
                if (sn.includes("cầu lông") || sn.includes("pickleball")) defImg = "https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?auto=format&fit=crop&w=600&q=80";
                else if (sn.includes("tennis")) defImg = "https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0?auto=format&fit=crop&w=600&q=80";
                else if (sn.includes("bóng bàn")) defImg = "https://images.unsplash.com/photo-1534158914592-062992fbe900?auto=format&fit=crop&w=600&q=80";
                else if (sn.includes("bóng đá")) defImg = "https://images.unsplash.com/photo-1508098682722-e99c43a406b2?auto=format&fit=crop&w=600&q=80";
                imgEl.src = (court.image && court.image.trim() !== "") ? court.image : defImg;
            }

            const si = getCourtStatusInfo(court.status);
            const el = document.getElementById("modal-court-status");
            el.className = 'text-[10px] font-bold font-[\'Barlow_Condensed\'] uppercase tracking-wider inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-none ' + si.badgeClass;
            el.innerHTML = (si.dotClass ? '<span class="w-1.5 h-1.5 rounded-full ' + si.dotClass + '"></span>' : '') + si.label;
            document.getElementById("ngayDat").value = todayStr;
            document.getElementById("ghiChu").value = "";
            selectPaymentMethod('sau');
            applyBranchTimeConstraints(court.branchId);
            document.getElementById("timetable-block").classList.add("hidden");
            document.getElementById("overlap-warning").classList.add("hidden");
            const btnNext = document.getElementById("next-checkout-btn");
            if (btnNext) btnNext.disabled = true;
            const overlay = document.getElementById("bookingModalOverlay");
            overlay.classList.remove("hidden");
            document.getElementById("checkoutPanel").classList.add("hidden");
            document.getElementById("bookingFormPanel").classList.remove("hidden");
            setTimeout(() => {
                overlay.classList.remove("opacity-0");
                document.getElementById("bookingFormPanel").classList.remove("scale-95");
            }, 10);
            checkScheduleAndPrice();
            } catch(e) { console.error('[Booking] openBookingModal error:', e); }
        }

        function closeBookingModal() {
            releaseSoftHold();
            const overlay = document.getElementById("bookingModalOverlay");
            overlay.classList.add("opacity-0");
            document.querySelectorAll("#bookingFormPanel, #checkoutPanel").forEach(p => p.classList.add("scale-95"));
            setTimeout(() => overlay.classList.add("hidden"), 300);
        }

        // ─────────── Lịch sử đặt sân (Booking History Center) ───────────
        let vsBhmLastFocus = null;
        let vsBhmKeyHandler = null;
        function openHistoryModal(trigger) {
            const overlay = document.getElementById("historyModalOverlay");
            if (!overlay) return;
            vsBhmLastFocus = trigger || document.activeElement;
            overlay.classList.add("is-open");
            document.body.style.overflow = "hidden";      // khóa scroll trang nền
            vsBhmInitCounts();
            // Focus vào nút đóng để bắt đầu focus trap.
            const closeBtn = overlay.querySelector(".vs-bhm-close");
            if (closeBtn) closeBtn.focus();
            vsBhmKeyHandler = function (e) {
                if (e.key === "Escape") {
                    if (document.getElementById("vsBhmConfirm").classList.contains("is-open")) { vsBhmCloseConfirm(); return; }
                    closeHistoryModal(); return;
                }
                if (e.key === "Tab") vsBhmTrapFocus(e, overlay);
            };
            document.addEventListener("keydown", vsBhmKeyHandler);
        }
        function closeHistoryModal() {
            const overlay = document.getElementById("historyModalOverlay");
            if (!overlay) return;
            vsBhmCloseConfirm();
            overlay.classList.remove("is-open");
            document.body.style.overflow = "";
            if (vsBhmKeyHandler) { document.removeEventListener("keydown", vsBhmKeyHandler); vsBhmKeyHandler = null; }
            if (vsBhmLastFocus && typeof vsBhmLastFocus.focus === "function") vsBhmLastFocus.focus();
        }
        function vsBhmTrapFocus(e, root) {
            const f = root.querySelectorAll('a[href], button:not([disabled]), input, [tabindex]:not([tabindex="-1"])');
            const vis = Array.prototype.filter.call(f, el => el.offsetParent !== null);
            if (!vis.length) return;
            const first = vis[0], last = vis[vis.length - 1];
            if (e.shiftKey && document.activeElement === first) { e.preventDefault(); last.focus(); }
            else if (!e.shiftKey && document.activeElement === last) { e.preventDefault(); first.focus(); }
        }

        // Overlay click đóng; click bên trong panel không đóng.
        (function () {
            const overlay = document.getElementById("historyModalOverlay");
            if (overlay) overlay.addEventListener("mousedown", function (e) { if (e.target === overlay) closeHistoryModal(); });
        })();

        // Filter tabs (client-side, dữ liệu đã tải sẵn).
        function vsBhmInitCounts() {
            const cards = document.querySelectorAll("#vsBhmBody .vs-bhm-card");
            if (!cards.length) return;
            const counts = { all: cards.length, paying: 0, confirmed: 0, done: 0, ended: 0 };
            cards.forEach(c => { const g = c.getAttribute("data-group"); if (counts[g] != null) counts[g]++; });
            document.querySelectorAll(".vs-bhm-tab-count").forEach(el => {
                const k = el.getAttribute("data-count"); if (counts[k] != null) el.textContent = counts[k];
            });
        }
        document.querySelectorAll(".vs-bhm-tab").forEach(function (tab) {
            tab.addEventListener("click", function () {
                const filter = tab.getAttribute("data-filter");
                document.querySelectorAll(".vs-bhm-tab").forEach(t => { t.classList.remove("is-active"); t.setAttribute("aria-selected", "false"); });
                tab.classList.add("is-active"); tab.setAttribute("aria-selected", "true");
                let shown = 0;
                document.querySelectorAll("#vsBhmBody .vs-bhm-card").forEach(function (c) {
                    const match = filter === "all" || c.getAttribute("data-group") === filter;
                    c.style.display = match ? "" : "none";
                    if (match) shown++;
                });
                const nr = document.getElementById("vsBhmNoResult");
                if (nr) nr.style.display = shown === 0 ? "block" : "none";
            });
        });

        // Resume "Tiếp tục thanh toán": chống double-click + spinner, rồi điều hướng tới QR cũ (không tạo đơn mới).
        document.querySelectorAll("#vsBhmBody a[data-resume]").forEach(function (a) {
            a.addEventListener("click", function (e) {
                if (a.dataset.busy === "1") { e.preventDefault(); return; }
                a.dataset.busy = "1";
                const label = a.querySelector(".vs-bhm-btn-label");
                a.querySelector(".material-symbols-outlined").outerHTML = '<span class="spinner" aria-hidden="true"></span>';
                if (label) label.textContent = "Đang mở...";
                // để điều hướng mặc định tiếp tục (href = /customer/thanh-toan-qr?datSanId=...)
            });
        });

        // Confirm dialog riêng của V-SPORT (không dùng window.confirm).
        let vsBhmPendingAction = null;
        function vsBhmOpenConfirm(msg, action) {
            document.getElementById("vsBhmConfirmMsg").textContent = msg || "Bạn có chắc chắn?";
            vsBhmPendingAction = action;
            const c = document.getElementById("vsBhmConfirm");
            c.classList.add("is-open");
            document.getElementById("vsBhmConfirmOk").focus();
        }
        function vsBhmCloseConfirm() {
            const c = document.getElementById("vsBhmConfirm");
            if (c) c.classList.remove("is-open");
            vsBhmPendingAction = null;
        }
        (function () {
            const back = document.getElementById("vsBhmConfirmBack");
            const ok = document.getElementById("vsBhmConfirmOk");
            const box = document.getElementById("vsBhmConfirm");
            if (back) back.addEventListener("click", vsBhmCloseConfirm);
            if (box) box.addEventListener("mousedown", function (e) { if (e.target === box) vsBhmCloseConfirm(); });
            if (ok) ok.addEventListener("click", function () {
                if (!vsBhmPendingAction) return;
                ok.disabled = true; ok.innerHTML = '<span class="spinner" aria-hidden="true"></span> Đang xử lý...';
                const act = vsBhmPendingAction; vsBhmPendingAction = null;
                act();
            });
            // Hủy thanh toán PayOS (ownership-checked + hủy link + giải phóng slot).
            document.querySelectorAll("#vsBhmBody [data-cancel-payos]").forEach(function (b) {
                b.addEventListener("click", function () {
                    const id = b.getAttribute("data-cancel-payos");
                    vsBhmOpenConfirm(b.getAttribute("data-confirm-msg"), function () {
                        window.location.href = CTX + "/customer/payos-cancel?datSanId=" + encodeURIComponent(id);
                    });
                });
            });
            // Hủy đặt sân (POST /customer/huy-dat-san qua form ẩn).
            document.querySelectorAll("#vsBhmBody [data-cancel-booking]").forEach(function (b) {
                b.addEventListener("click", function () {
                    const id = b.getAttribute("data-cancel-booking");
                    vsBhmOpenConfirm(b.getAttribute("data-confirm-msg"), function () {
                        document.getElementById("vsBhmCancelBookingId").value = id;
                        document.getElementById("vsBhmCancelBookingForm").submit();
                    });
                });
            });
        })();

        function selectPaymentMethod(method) {
            document.getElementById("input-payment-method").value = method;
            const btnPOS = document.getElementById("payment-opt-payos"), btnSau = document.getElementById("payment-opt-sau");
            const infoPOS = document.getElementById("payment-info-payos"), infoSau = document.getElementById("payment-info-sau");
            if (!btnPOS || !btnSau) return;
            if (method === 'payos') {
                btnPOS.className = "flex flex-col items-center justify-center p-3 rounded-none border-2 border-[#e3000f] bg-[#e3000f]/5 text-center gap-1.5 active:scale-95";
                btnSau.className = "flex flex-col items-center justify-center p-3 rounded-none border-2 border-neutral-200 hover:border-neutral-300 text-center gap-1.5 active:scale-95";
                infoPOS.classList.remove("hidden"); infoSau.classList.add("hidden");
            } else {
                btnSau.className = "flex flex-col items-center justify-center p-3 rounded-none border-2 border-[#e3000f] bg-[#e3000f]/5 text-center gap-1.5 active:scale-95";
                btnPOS.className = "flex flex-col items-center justify-center p-3 rounded-none border-2 border-neutral-200 hover:border-neutral-300 text-center gap-1.5 active:scale-95";
                infoSau.classList.remove("hidden"); infoPOS.classList.add("hidden");
            }
        }

        function isConflictStatus(status) {
            if (!status) return false;
            const s = status.trim().toLowerCase();
            // Blacklist: Exclude Cancelled, Expired, No-show
            if (s.includes("hủy") || s.includes("huy") || s.includes("h?y")) return false;
            if (s.includes("quá") || s.includes("qua") || s.includes("qu ") || s.includes("qu?")) return false;
            if (s.includes("không") || s.includes("khong") || s.includes("kh ") || s.includes("kh?")) return false;
            
            // Whitelist: Include active or completed statuses
            const isConfirmed = s.includes("xác nhận") || s.includes("xac nhan") || s.includes("xac") || s.includes("x?c");
            const isPendingPayment = s.includes("thanh toán") || s.includes("thanh toan") || s.includes("thanh") || s.includes("to n");
            const isUsing = s.includes("sử dụng") || s.includes("su dung") || s.includes("dụng") || s.includes("d?ng");
            const isCompleted = s.includes("hoàn thành") || s.includes("hoan thanh") || s.includes("thành") || s.includes("th nh");
            
            return isConfirmed || isPendingPayment || isUsing || isCompleted;
        }

        let lastHoldKey = null;
        // Sân/ngày đang thực sự được giữ chỗ ở server (khác lastHoldKey ở chỗ chỉ set khi hold
        // THÀNH CÔNG) - dùng để release đúng hold khi người dùng đóng modal mà không hoàn tất đặt sân.
        let activeHoldCourtId = null;
        let activeHoldDate = null;

        function requestSoftHold(courtId, dateVal, startVal, endVal) {
            const holdKey = `\${courtId}|\${dateVal}|\${startVal}|\${endVal}`;
            if (holdKey === lastHoldKey) return;
            lastHoldKey = holdKey;
            const btnNext = document.getElementById("next-checkout-btn");
            const warningBox = document.getElementById("overlap-warning");
            const warningText = document.getElementById("overlap-warning-text");
            fetch("<c:url value='/customer/giu-cho-tam'/>", {
                method: "POST", headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: new URLSearchParams({ sanId: courtId, ngayDat: dateVal, gioBatDau: startVal, gioKetThuc: endVal }).toString()
            }).then(r => r.json()).then(data => {
                if (holdKey !== lastHoldKey) return;
                if (!data.success) {
                    warningText.textContent = data.message || "Đã có người đang giữ khung giờ này.";
                    warningBox.classList.remove("hidden");
                    if (btnNext) btnNext.disabled = true;
                    lastHoldKey = null;
                } else {
                    activeHoldCourtId = courtId;
                    activeHoldDate = dateVal;
                }
            }).catch(() => {});
        }

        // Giải phóng SoftHold hiện tại ngay khi người dùng đóng modal mà không hoàn tất đặt sân -
        // không chờ hold tự hết hạn (SOFT_HOLD_TIMEOUT_MINUTES), tránh chặn oan slot cho khách khác.
        function releaseSoftHold() {
            if (!activeHoldCourtId || !activeHoldDate) return;
            const payload = new URLSearchParams({ action: "release", sanId: activeHoldCourtId, ngayDat: activeHoldDate }).toString();
            if (navigator.sendBeacon) {
                navigator.sendBeacon("<c:url value='/customer/giu-cho-tam'/>",
                    new Blob([payload], { type: "application/x-www-form-urlencoded" }));
            } else {
                fetch("<c:url value='/customer/giu-cho-tam'/>", {
                    method: "POST", headers: { "Content-Type": "application/x-www-form-urlencoded" },
                    body: payload, keepalive: true
                }).catch(() => {});
            }
            activeHoldCourtId = null;
            activeHoldDate = null;
            lastHoldKey = null;
        }

        function checkScheduleAndPrice() {
            const courtId = selectedCourtId;
            const dateVal = document.getElementById("ngayDat").value;
            const startVal = document.getElementById("gioBatDau").value;
            const endVal = document.getElementById("gioKetThuc").value;
            if (!courtId || !dateVal) return;
            const btnNext = document.getElementById("next-checkout-btn");
            const timetableBlock = document.getElementById("timetable-block");
            const timelineSlots = document.getElementById("timeline-slots");
            const warningBox = document.getElementById("overlap-warning");
            const warningText = document.getElementById("overlap-warning-text");
            const conflicts = activeBookings.filter(b => b.sanId === courtId && b.date === dateVal && isConflictStatus(b.status));
            if (conflicts.length > 0) {
                timetableBlock.classList.remove("hidden");
                timelineSlots.innerHTML = "";
                conflicts.forEach(b => {
                    timelineSlots.insertAdjacentHTML("beforeend", `<div class="px-3 py-1.5 bg-amber-50 text-amber-700 border border-amber-200 rounded-none text-xs font-bold">\${b.start.substring(0,5)} - \${b.end.substring(0,5)}</div>`);
                });
            } else timetableBlock.classList.add("hidden");
            if (!startVal || !endVal) { if (btnNext) btnNext.disabled = true; warningBox.classList.add("hidden"); const p = document.getElementById("live-cost-preview"); if(p) p.classList.add("hidden"); return; }
            const court = courts.find(c => c.id === courtId);
            const branchHours = getBranchHours(court ? court.branchId : null);
            const startMin = timeToMinutes(startVal), endMin = timeToMinutes(endVal);
            const openMin = timeToMinutes(branchHours.openTime), closeMin = timeToMinutes(branchHours.closeTime);
            if (endMin <= startMin) { warningText.textContent = "Giờ kết thúc phải sau giờ bắt đầu."; warningBox.classList.remove("hidden"); if (btnNext) btnNext.disabled = true; return; }
            if (startMin < openMin) { warningText.textContent = branchHours.name + " mở cửa lúc " + branchHours.openTime + "."; warningBox.classList.remove("hidden"); if (btnNext) btnNext.disabled = true; return; }
            if (endMin > closeMin) { warningText.textContent = branchHours.name + " đóng cửa lúc " + branchHours.closeTime + "."; warningBox.classList.remove("hidden"); if (btnNext) btnNext.disabled = true; return; }
            if (dateVal === todayStr) {
                const now = new Date(), nowMin = now.getHours() * 60 + now.getMinutes();
                if (startMin < nowMin) { warningText.textContent = "Không thể đặt sân cho giờ đã qua hôm nay."; warningBox.classList.remove("hidden"); if (btnNext) btnNext.disabled = true; return; }
            }
            
            let overlappingSlot = null;
            for (let i = 0; i < conflicts.length; i++) {
                const b = conflicts[i];
                const bS = timeToMinutes(b.start);
                const bE = timeToMinutes(b.end);
                if (!(endMin <= bS || startMin >= bE)) {
                    overlappingSlot = b;
                    break;
                }
            }
            
            if (overlappingSlot) {
                warningText.textContent = `Khung giờ này đã có người đặt (${overlappingSlot.start.substring(0, 5)} - ${overlappingSlot.end.substring(0, 5)}). Vui lòng chọn khung giờ khác.`;
                warningBox.classList.remove("hidden");
                if (btnNext) btnNext.disabled = true;
                return;
            }
            
            warningBox.classList.add("hidden"); if (btnNext) btnNext.disabled = false;
            requestSoftHold(courtId, dateVal, startVal, endVal);
            const type = courtTypes[court.typeId];
            if (type) {
                const lightMin = timeToMinutes(type.lightTime);
                const hourlyRate = startMin >= lightMin ? type.priceNight : type.priceDay;
                const applyLights = startMin >= lightMin && type.priceNight !== type.priceDay;
                const durationH = (endMin - startMin) / 60.0;
                currentTotalCost = Math.round(durationH * hourlyRate);
                document.getElementById("summary-duration").textContent = `\${durationH.toFixed(1)} giờ (\${formatDurationText(endMin - startMin)})`;
                document.getElementById("summary-rate").textContent = `\${hourlyRate.toLocaleString('vi-VN')} đ/giờ`;
                document.getElementById("summary-lights-row").classList.toggle("hidden", !applyLights);
                document.getElementById("summary-total").textContent = `\${currentTotalCost.toLocaleString('vi-VN')} đ`;
                updateServiceTotal();
                // Live cost preview in form panel
                const preview = document.getElementById("live-cost-preview");
                if (preview) {
                    preview.classList.remove("hidden");
                    document.getElementById("live-cost-amount").textContent = currentTotalCost.toLocaleString('vi-VN') + ' đ';
                    document.getElementById("live-cost-duration").textContent = formatDurationText(endMin - startMin) + ' · ' + startVal.substring(0,5) + ' → ' + endVal.substring(0,5);
                    document.getElementById("live-cost-rate").textContent = hourlyRate.toLocaleString('vi-VN') + ' đ/giờ';
                    const lightsEl = document.getElementById("live-cost-lights");
                    if (lightsEl) lightsEl.classList.toggle("hidden", !applyLights);
                }
            }
        }

        function goToCheckout() {
            if (!document.getElementById('booking-form').reportValidity()) return;
            const fp = document.getElementById("bookingFormPanel"), cp = document.getElementById("checkoutPanel");
            fp.classList.add("scale-95", "opacity-0");
            setTimeout(() => { fp.classList.add("hidden"); fp.classList.remove("opacity-0"); cp.classList.remove("hidden"); setTimeout(() => cp.classList.remove("scale-95"), 10); }, 200);
        }

        function backToBookingForm() {
            const fp = document.getElementById("bookingFormPanel"), cp = document.getElementById("checkoutPanel");
            cp.classList.add("scale-95", "opacity-0");
            setTimeout(() => { cp.classList.add("hidden"); cp.classList.remove("opacity-0"); fp.classList.remove("hidden"); setTimeout(() => fp.classList.remove("scale-95"), 10); }, 200);
        }

        function confirmBooking() {
            const form = document.getElementById('booking-form');
            if (!form) return;
            injectServiceInputsIntoForm(form);
            const btn = document.querySelector('button[onclick="confirmBooking()"]');
            const paymentMethod = document.getElementById('input-payment-method').value;
            const isPayOS = paymentMethod === 'payos';

            if (btn) {
                btn.disabled = true;
                btn.innerHTML = isPayOS
                    ? '<span class="material-symbols-outlined text-[20px] animate-spin">progress_activity</span> Đang tạo mã QR...'
                    : '<span class="material-symbols-outlined text-[20px] animate-spin">progress_activity</span> Đang xử lý...';
            }
            if (isPayOS) {
                const info = document.getElementById('payment-info-payos');
                if (info) {
                    info.innerHTML = '<div class="flex items-center justify-center gap-2 font-semibold text-sm py-1" style="color: #08A9CC;">' +
                        '<span class="material-symbols-outlined text-[20px] animate-spin">progress_activity</span>' +
                        '<span>Đang kết nối PayOS, vui lòng chờ...</span></div>';
                }
            }
            form.submit();
        }

        function applyBranchTimeConstraints(branchId) {
            const { openTime, closeTime } = getBranchHours(branchId);
            const hoursLabel = document.getElementById("modal-branch-hours");
            if (hoursLabel) hoursLabel.textContent = openTime.substring(0, 5) + " - " + closeTime.substring(0, 5);
            const openMin = timeToMinutes(openTime), closeMin = timeToMinutes(closeTime);
            const dateVal = document.getElementById("ngayDat").value;
            const conflicts = activeBookings.filter(b => b.sanId === selectedCourtId && b.date === dateVal && isConflictStatus(b.status));
            const startSelect = document.getElementById("gioBatDau");
            startSelect.innerHTML = '<option value="">-- Chọn giờ bắt đầu --</option>';
            let currentTotalMin = -1;
            if (dateVal === todayStr) { const now = new Date(); currentTotalMin = now.getHours() * 60 + now.getMinutes(); }
            for (let m = openMin; m <= closeMin - 30; m += 30) {
                const h = Math.floor(m / 60), min = m % 60;
                const timeStr = String(h).padStart(2, "0") + ":" + String(min).padStart(2, "0");
                const isPast = m <= currentTotalMin;
                const isBooked = conflicts.some(b => { const s = timeToMinutes(b.start), e = timeToMinutes(b.end); return m >= s && m < e; });
                const opt = document.createElement("option");
                opt.value = timeStr;
                opt.text = isPast ? timeStr + " (Đã qua)" : isBooked ? timeStr + " (Đã có người đặt)" : timeStr;
                if (isPast || isBooked) opt.disabled = true;
                startSelect.appendChild(opt);
            }
            document.getElementById("gioBatDau").value = "";
            document.getElementById("gioKetThuc").innerHTML = '<option value="">Vui lòng chọn giờ bắt đầu trước</option>';
        }

        function onStartTimeSelectChange() {
            const startVal = document.getElementById("gioBatDau").value;
            const endSelectEl = document.getElementById("gioKetThuc");
            if (!startVal) { endSelectEl.innerHTML = '<option value="">Vui lòng chọn giờ bắt đầu trước</option>'; checkScheduleAndPrice(); return; }
            const startMin = timeToMinutes(startVal);
            const court = courts.find(c => c.id === selectedCourtId);
            const { closeTime } = getBranchHours(court ? court.branchId : null);
            const closeMin = timeToMinutes(closeTime);
            const dateVal = document.getElementById("ngayDat").value;
            const conflicts = activeBookings.filter(b => b.sanId === selectedCourtId && b.date === dateVal && isConflictStatus(b.status));
            let maxMin = closeMin;
            conflicts.forEach(b => { const bs = timeToMinutes(b.start); if (bs > startMin && bs < maxMin) maxMin = bs; });
            endSelectEl.innerHTML = '<option value="">-- Chọn giờ kết thúc --</option>';
            for (let m = startMin + 30; m <= maxMin; m += 30) {
                const h = Math.floor(m / 60), min = m % 60;
                const timeStr = String(h).padStart(2, "0") + ":" + String(min).padStart(2, "0");
                const opt = document.createElement("option");
                opt.value = timeStr;
                opt.text = timeStr + " (" + formatDurationText(m - startMin) + ")";
                endSelectEl.appendChild(opt);
            }
            checkScheduleAndPrice();
        }

        function onEndTimeSelectChange() { checkScheduleAndPrice(); }
        function onBookingDateChange() { const c = courts.find(x => x.id === selectedCourtId); if (c) applyBranchTimeConstraints(c.branchId); checkScheduleAndPrice(); }

        // ─── Live Activity Feed Generator ───
        const sportIcons = { 0: "⚽", 1: "🏸", 2: "🎾", 3: "🏓", 4: "⚽" };
        const actionPrefixes = [
            "vừa đặt thành công ca đấu",
            "đã thanh toán giữ sân ca tối",
            "được check-in trực tuyến",
            "vừa hoàn tất thanh toán (PayOS)",
            "vừa gửi đánh giá 5★ cho sân"
        ];
        const names = ["Anh Hùng", "Chị Thảo", "Hội Sport Club", "Anh Tuấn", "Chị Mai", "Anh Hoàng", "Chị Linh", "FC Đông Đô", "Badminton Club", "Anh Bách"];

        function initLiveActivityFeed() {
            const feedContainer = document.getElementById("live-activity-list");
            if (!feedContainer) return;
            
            // Periodically add new item and remove oldest
            setInterval(() => {
                const randomCourt = courts[Math.floor(Math.random() * courts.length)];
                if (!randomCourt) return;
                const icon = randomCourt.name.toLowerCase().includes("bóng đá") ? "⚽" :
                             randomCourt.name.toLowerCase().includes("cầu lông") ? "🏸" :
                             randomCourt.name.toLowerCase().includes("tennis") ? "🎾" :
                             randomCourt.name.toLowerCase().includes("pickleball") ? "🏓" : "🏃";
                             
                const randomAction = actionPrefixes[Math.floor(Math.random() * actionPrefixes.length)];
                const randomName = names[Math.floor(Math.random() * names.length)];
                
                const itemHtml = `
                    <div class="flex items-start gap-3 text-xs text-slate-600 pb-2 border-b border-dashed border-slate-100 last:border-0" style="animation: slide-up-fade 0.5s ease forwards">
                        <span class="text-[18px] shrink-0">\${icon}</span>
                        <div>
                            <p class="font-bold text-slate-700">\${randomCourt.name}</p>
                            <p class="text-slate-500">\${randomName} \${randomAction}</p>
                            <span class="text-[9px] text-slate-400 font-bold">Vừa xong</span>
                        </div>
                    </div>
                `;
                
                feedContainer.insertAdjacentHTML("afterbegin", itemHtml);
                
                // Keep max 4 items inside container
                if (feedContainer.children.length > 4) {
                    const lastChild = feedContainer.lastElementChild;
                    lastChild.style.transition = "all 0.5s ease";
                    lastChild.style.opacity = "0";
                    lastChild.style.transform = "translateY(5px)";
                    setTimeout(() => {
                        if (lastChild.parentNode === feedContainer) {
                            feedContainer.removeChild(lastChild);
                        }
                    }, 500);
                }
            }, 7000); // update every 7 seconds
        }

        // ─── Init ───
        try {
            console.log('[DatSan] courts:', courts.length, '| branches:', Object.keys(branches).length);
            renderCourts();
            if (paramBranchId) filterBranch(paramBranchId);
            if (paramSportId) filterSport(paramSportId);
            initLiveActivityFeed();
        } catch (e) {
            console.error('[DatSan] init error:', e);
        }
    </script>

    <!-- Customer Service Modal JS -->
    <script>
        let customerProducts = [], customerOrdered = [];

        function openCustomerServiceModal(datSanId) {
            document.getElementById("customer-service-datsan-id").value = datSanId;
            const modal = document.getElementById("customerServiceModal");
            const loading = document.getElementById("customer-service-loading");
            const container = document.getElementById("customer-service-container");
            const grid = document.getElementById("customer-products-grid");
            modal.classList.remove("hidden"); modal.classList.add("flex");
            loading.classList.remove("hidden"); container.classList.add("hidden");
            setTimeout(() => { modal.classList.remove("opacity-0"); modal.querySelector(".bg-white").classList.remove("scale-95"); }, 10);
            fetch(`${pageContext.request.contextPath}/customer/dat-dich-vu?datSanId=${datSanId}`)
                .then(r => r.json()).then(data => {
                    customerProducts = data.products || []; customerOrdered = data.ordered || [];
                    loading.classList.add("hidden"); container.classList.remove("hidden");
                    grid.innerHTML = "";
                    if (customerProducts.length === 0) { grid.innerHTML = '<div class="col-span-2 text-center text-slate-400 py-8 italic">Cơ sở này hiện không có sản phẩm/dịch vụ nào.</div>'; return; }
                    customerProducts.forEach(prod => {
                        const ord = customerOrdered.find(o => o.SanPhamID === prod.SanPhamID);
                        const qty = ord ? ord.SoLuong : 0;
                        grid.insertAdjacentHTML("beforeend", `
                            <div class="p-4 bg-neutral-50 border border-neutral-200 rounded-none flex items-center justify-between">
                                <div class="flex-grow min-w-0 pr-4">
                                    <h4 class="font-bold text-neutral-800 text-sm truncate">${prod.TenSanPham}</h4>
                                    <p class="text-xs text-neutral-500 mt-0.5">${prod.DonGia.toLocaleString('vi-VN')} đ / ${prod.DonViTinh || 'cái'}</p>
                                    <p class="text-[10px] text-neutral-400 font-semibold mt-1">Còn: ${prod.SoLuongTon}</p>
                                </div>
                                <div class="flex items-center gap-1 shrink-0">
                                    <input type="hidden" name="productId" value="${prod.SanPhamID}">
                                    <button type="button" onclick="adjustCustomerQty(${prod.SanPhamID}, -1)" class="w-8 h-8 rounded-none border border-neutral-200 bg-neutral-100 hover:bg-neutral-200 text-neutral-700 font-bold flex items-center justify-center">-</button>
                                    <input type="number" name="quantity" id="cust-qty-${prod.SanPhamID}" value="${qty}" min="0" max="${prod.SoLuongTon}" class="w-12 text-center bg-white border border-neutral-200 py-1 text-sm font-bold h-8" readonly>
                                    <button type="button" onclick="adjustCustomerQty(${prod.SanPhamID}, 1)" class="w-8 h-8 rounded-none border border-neutral-200 bg-neutral-100 hover:bg-neutral-200 text-neutral-700 font-bold flex items-center justify-center">+</button>
                                </div>
                            </div>`);
                    });
                    recalculateCustomerTotal();
                }).catch(err => { grid.innerHTML = '<div class="col-span-2 text-center text-red-500 py-8">Lỗi tải dữ liệu.</div>'; loading.classList.add("hidden"); container.classList.remove("hidden"); });
        }

        function adjustCustomerQty(spId, delta) {
            const input = document.getElementById(`cust-qty-\${spId}`);
            const prod = customerProducts.find(p => p.SanPhamID === spId);
            if (!input || !prod) return;
            let val = Math.max(0, Math.min((parseInt(input.value) || 0) + delta, prod.SoLuongTon));
            input.value = val; recalculateCustomerTotal();
        }

        function recalculateCustomerTotal() {
            let total = 0;
            customerProducts.forEach(p => { const i = document.getElementById(`cust-qty-\${p.SanPhamID}`); total += i ? (parseInt(i.value) || 0) * p.DonGia : 0; });
            document.getElementById("customer-service-total").textContent = total.toLocaleString('vi-VN') + " đ";
        }

        function closeCustomerServiceModal() {
            const modal = document.getElementById("customerServiceModal");
            modal.classList.add("opacity-0"); modal.querySelector(".bg-white").classList.add("scale-95");
            setTimeout(() => { modal.classList.add("hidden"); modal.classList.remove("flex"); }, 300);
        }
    </script>
<jsp:include page="/customer/common/bottom-nav.jsp" />
</body>
</html>
