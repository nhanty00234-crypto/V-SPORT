<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Ghép trận - V-SPORT</title>
    <jsp:include page="/common/head.jsp" />
    <jsp:include page="/customer/common/vsport-theme.jsp" />
    <style>
        html, body { background: var(--vs-surface, #F4F7FB); color: var(--vs-text, #102A43); font-family: 'Inter', 'Barlow', system-ui, sans-serif; }
        .gk-shell { max-width: 1200px; margin: 0 auto; padding: 0 16px; }
        @media (min-width: 1024px) { .gk-shell { padding: 0 28px; } }

        /* Header */
        .gk-header {
            position: sticky; top: 0; z-index: 30;
            background: var(--vs-primary-900, #0B2545); color: #fff;
            border-bottom: 1px solid var(--vs-primary-800, #123A63);
        }
        .gk-header-inner { display: flex; align-items: center; gap: 12px; padding: 12px 16px; min-height: 60px; max-width: 1200px; margin: 0 auto; }
        @media (min-width: 1024px) { .gk-header-inner { padding: 14px 28px; min-height: 68px; } }
        .gk-back { width: 40px; height: 40px; display: inline-flex; align-items: center; justify-content: center; border-radius: 999px; background: rgba(255,255,255,.08); color: #fff; border: none; cursor: pointer; }
        .gk-back:hover { background: rgba(255,255,255,.16); }
        .gk-title-block { min-width: 0; flex: 1; }
        .gk-title { font-size: 17px; font-weight: 800; margin: 0; }
        .gk-subtitle { font-size: 12px; color: #cbd5e1; margin: 2px 0 0; }
        .gk-mine-btn {
            display: inline-flex; align-items: center; gap: 6px; padding: 8px 14px; border-radius: 999px;
            background: rgba(255,255,255,.1); color: #fff; border: 1px solid rgba(255,255,255,.16);
            font-size: 12px; font-weight: 700; cursor: pointer; text-decoration: none;
            transition: background .15s ease;
        }
        .gk-mine-btn:hover { background: rgba(255,255,255,.2); }
        .gk-mine-badge {
            display: inline-flex; align-items: center; justify-content: center;
            background: var(--vs-orange-500, #FF8A24); color: #fff; font-weight: 800; font-size: 10px;
            padding: 2px 6px; border-radius: 999px; margin-left: 2px; min-width: 18px;
        }

        /* Facility context card */
        .gk-facility-card {
            display: flex; align-items: center; gap: 12px; margin-top: 16px; padding: 12px 16px;
            background: #fff; border: 1px solid var(--vs-border, #DCE5EF); border-radius: 12px;
        }
        .gk-facility-icon {
            width: 44px; height: 44px; border-radius: 12px; background: var(--vs-cyan-100, #DDF8FC);
            color: var(--vs-primary-700, #185A9D); display: inline-flex; align-items: center; justify-content: center; font-weight: 800;
        }
        .gk-facility-name { font-size: 14px; font-weight: 800; color: var(--vs-text, #102A43); }
        .gk-facility-addr { font-size: 12px; color: var(--vs-text-secondary, #486581); margin-top: 2px; }
        .gk-facility-actions { display: flex; gap: 8px; margin-left: auto; }
        .gk-btn-ghost {
            display: inline-flex; align-items: center; justify-content: center; gap: 6px;
            padding: 8px 12px; min-height: 36px; border-radius: 10px; background: #fff;
            border: 1px solid var(--vs-border, #DCE5EF); color: var(--vs-text, #102A43); font-size: 12px; font-weight: 700; cursor: pointer;
            text-decoration: none;
        }
        .gk-btn-ghost:hover { border-color: var(--vs-primary-600, #1677D2); color: var(--vs-primary-600, #1677D2); }

        /* Segment control */
        .gk-segment {
            display: inline-flex; gap: 4px; padding: 4px; margin: 14px 0;
            background: #fff; border: 1px solid var(--vs-border, #DCE5EF); border-radius: 12px;
        }
        .gk-segment button {
            padding: 8px 16px; min-height: 40px; border: none; background: transparent;
            border-radius: 8px; font-size: 13px; font-weight: 700; color: var(--vs-text-secondary, #486581);
            cursor: pointer; display: inline-flex; align-items: center; gap: 6px;
        }
        .gk-segment button.is-active { background: var(--vs-primary-600, #1677D2); color: #fff; }

        /* Panels */
        .gk-panel { display: none; }
        .gk-panel.is-active { display: block; }

        /* Cards */
        .gk-card {
            background: #fff; border: 1px solid var(--vs-border, #DCE5EF);
            border-radius: 14px; padding: 16px; margin-bottom: 12px;
        }
        .gk-card-head { display: flex; align-items: center; justify-content: space-between; gap: 8px; margin-bottom: 10px; flex-wrap: wrap; }
        .gk-card-title { font-size: 15px; font-weight: 800; color: var(--vs-primary-900, #0B2545); margin: 0; }
        .gk-card-meta { display: flex; flex-wrap: wrap; gap: 6px 12px; font-size: 12px; color: var(--vs-text-secondary, #486581); }
        .gk-card-meta span { display: inline-flex; align-items: center; gap: 4px; }
        .gk-sport-badge {
            display: inline-flex; align-items: center; gap: 4px; padding: 4px 10px; border-radius: 999px;
            background: var(--vs-cyan-100, #DDF8FC); color: var(--vs-primary-700, #185A9D);
            font-size: 11px; font-weight: 800;
        }
        .gk-status-badge {
            display: inline-flex; align-items: center; gap: 4px; padding: 3px 10px; border-radius: 999px;
            font-size: 11px; font-weight: 800;
        }
        .gk-status-badge.is-open   { background: var(--vs-success-bg, #E5F7EF); color: var(--vs-success, #16A36A); }
        .gk-status-badge.is-full   { background: var(--vs-warning-bg, #FFF7DA); color: #92400e; }
        .gk-status-badge.is-cancel { background: var(--vs-danger-bg, #FDEBEC); color: #991b1b; }
        .gk-status-badge.is-closed { background: #f1f5f9; color: #475569; }
        .gk-slot-bar { height: 8px; border-radius: 999px; background: #eef2f6; overflow: hidden; margin-top: 8px; }
        .gk-slot-fill { height: 100%; background: var(--vs-success, #16A36A); border-radius: 999px; }
        .gk-participants { font-size: 12px; color: var(--vs-text-secondary, #486581); margin-top: 6px; display: flex; justify-content: space-between; }
        .gk-reputation {
            display: inline-flex; align-items: center; gap: 4px; padding: 2px 8px; border-radius: 999px;
            background: var(--vs-success-bg, #E5F7EF); color: var(--vs-success, #16A36A); font-size: 10px; font-weight: 800;
        }
        .gk-reputation.is-watch { background: var(--vs-warning-bg, #FFF7DA); color: #92400e; }
        .gk-reputation.is-risk  { background: var(--vs-danger-bg, #FDEBEC); color: #991b1b; }
        .gk-card-actions { display: flex; gap: 8px; margin-top: 12px; }
        .gk-btn-primary {
            display: inline-flex; align-items: center; justify-content: center; gap: 6px;
            padding: 10px 16px; min-height: 40px; border-radius: 10px; border: none;
            background: var(--vs-orange-500, #FF8A24); color: #fff; font-size: 13px; font-weight: 800; cursor: pointer;
            transition: background .15s ease;
        }
        .gk-btn-primary:hover:not(:disabled) { background: var(--vs-orange-600, #F97316); }
        .gk-btn-primary:disabled { background: #cbd5e1; cursor: not-allowed; }
        .gk-btn-primary.is-full-width { width: 100%; }
        .gk-btn-secondary {
            display: inline-flex; align-items: center; justify-content: center; gap: 6px;
            padding: 10px 16px; min-height: 40px; border-radius: 10px; background: #fff;
            border: 1px solid var(--vs-primary-600, #1677D2); color: var(--vs-primary-600, #1677D2);
            font-size: 13px; font-weight: 800; cursor: pointer;
        }
        .gk-btn-secondary:hover { background: var(--vs-cyan-50, #F0FCFE); }

        /* Filters */
        .gk-filters { display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 14px; }
        .gk-filters select, .gk-filters input[type="date"] {
            padding: 8px 12px; min-height: 40px; background: #fff; border: 1px solid var(--vs-border, #DCE5EF);
            border-radius: 10px; font-size: 13px; font-weight: 600; color: var(--vs-text, #102A43); font-family: inherit;
        }
        .gk-filters select:focus, .gk-filters input:focus { outline: none; border-color: var(--vs-primary-600, #1677D2); box-shadow: 0 0 0 3px var(--vs-focus-ring, rgba(24,200,232,.35)); }

        /* Create form */
        .gk-form { display: grid; grid-template-columns: 1fr; gap: 14px; }
        @media (min-width: 768px) { .gk-form { grid-template-columns: 1fr 1fr; } }
        .gk-form .full { grid-column: 1 / -1; }
        .gk-label { display: block; font-size: 12px; font-weight: 800; color: var(--vs-text, #102A43); margin-bottom: 6px; }
        .gk-input, .gk-select, .gk-textarea {
            width: 100%; padding: 10px 12px; min-height: 42px; background: #fff;
            border: 1px solid var(--vs-border, #DCE5EF); border-radius: 10px;
            font-size: 13px; color: var(--vs-text, #102A43); font-family: inherit;
        }
        .gk-textarea { min-height: 100px; resize: vertical; }
        .gk-input:focus, .gk-select:focus, .gk-textarea:focus { outline: none; border-color: var(--vs-primary-600, #1677D2); box-shadow: 0 0 0 3px var(--vs-focus-ring, rgba(24,200,232,.35)); }
        .gk-help { font-size: 11px; color: var(--vs-text-secondary, #486581); margin-top: 4px; }
        .gk-radios { display: flex; gap: 10px; flex-wrap: wrap; }
        .gk-radio {
            display: inline-flex; align-items: center; gap: 8px; padding: 10px 14px;
            background: #fff; border: 1px solid var(--vs-border, #DCE5EF); border-radius: 10px;
            font-size: 13px; font-weight: 700; color: var(--vs-text-secondary, #486581); cursor: pointer;
            transition: all .15s ease;
        }
        .gk-radio input { accent-color: var(--vs-primary-600, #1677D2); }
        .gk-radio.is-selected { border-color: var(--vs-primary-600, #1677D2); background: var(--vs-cyan-50, #F0FCFE); color: var(--vs-primary-700, #185A9D); }
        .gk-preview {
            background: #f8fafc; border: 1px dashed var(--vs-border, #DCE5EF); border-radius: 12px; padding: 14px;
        }
        .gk-preview-empty { color: var(--vs-text-secondary, #486581); font-size: 13px; text-align: center; padding: 30px 0; }

        /* Empty / loading / error states */
        .gk-empty { text-align: center; padding: 48px 16px; color: var(--vs-text-secondary, #486581); }
        .gk-empty h3 { color: var(--vs-text, #102A43); font-size: 16px; margin: 0 0 6px; }
        .gk-empty p  { font-size: 13px; margin: 0 0 14px; }
        .gk-loading { padding: 24px; }
        .gk-error { padding: 24px; text-align: center; color: #991b1b; }
        @keyframes gkShim { 0% { background-position: 100% 50%; } 100% { background-position: 0 50%; } }
        .gk-skel { background: linear-gradient(90deg, #eef2f6 25%, #dfe6ec 37%, #eef2f6 63%); background-size: 400% 100%; animation: gkShim 1.4s ease infinite; border-radius: 8px; height: 60px; margin-bottom: 8px; }

        /* Toast */
        .gk-toast {
            position: fixed; left: 50%; bottom: 100px; transform: translateX(-50%) translateY(16px);
            background: var(--vs-primary-900, #0B2545); color: #fff; padding: 12px 18px; border-radius: 999px;
            font-size: 13px; font-weight: 700; box-shadow: 0 12px 30px rgba(11,37,69,.32);
            opacity: 0; visibility: hidden; transition: opacity .2s ease, transform .2s ease;
            z-index: 300; max-width: 92vw; text-align: center;
        }
        .gk-toast.is-open { opacity: 1; visibility: visible; transform: translateX(-50%) translateY(0); }
        .gk-toast.is-danger  { background: var(--vs-danger, #E5484D); }
        .gk-toast.is-success { background: var(--vs-success, #16A36A); }

        /* Match detail bottom sheet */
        .gk-overlay { position: fixed; inset: 0; background: rgba(11,37,69,.55); z-index: 200; opacity: 0; visibility: hidden; transition: opacity .2s ease; }
        .gk-overlay.is-open { opacity: 1; visibility: visible; }
        .gk-sheet {
            position: fixed; left: 0; right: 0; bottom: 0; z-index: 210;
            background: #fff; border-radius: 20px 20px 0 0;
            max-height: 90dvh; display: flex; flex-direction: column;
            transform: translateY(100%); transition: transform .28s cubic-bezier(.22,1,.36,1);
            box-shadow: 0 -20px 60px rgba(11,37,69,.32);
        }
        .gk-sheet.is-open { transform: translateY(0); }
        .gk-sheet-handle { padding: 8px 0; display: flex; justify-content: center; }
        .gk-sheet-handle span { width: 44px; height: 5px; background: #cbd5e1; border-radius: 999px; }
        .gk-sheet-head { display: flex; align-items: center; justify-content: space-between; padding: 4px 16px 12px; border-bottom: 1px solid var(--vs-border, #DCE5EF); }
        .gk-sheet-close {
            width: 36px; height: 36px; border-radius: 50%; border: 1px solid var(--vs-border, #DCE5EF);
            background: #fff; cursor: pointer; display: inline-flex; align-items: center; justify-content: center;
        }
        .gk-sheet-body { padding: 16px; overflow-y: auto; flex: 1; }
        .gk-sheet-bar {
            padding: 12px 16px calc(12px + env(safe-area-inset-bottom, 0px)); border-top: 1px solid var(--vs-border, #DCE5EF);
            display: flex; gap: 8px;
        }
        @media (min-width: 768px) {
            .gk-sheet { max-width: 640px; left: 50%; right: auto; transform: translate(-50%, 100%); border-radius: 20px; bottom: 40px; }
            .gk-sheet.is-open { transform: translate(-50%, 0); }
        }

        .gk-participant-row {
            display: flex; align-items: center; gap: 10px; padding: 10px 0;
            border-bottom: 1px solid #eef2f6;
        }
        .gk-participant-row:last-child { border-bottom: none; }
        .gk-avatar {
            width: 36px; height: 36px; border-radius: 999px; background: var(--vs-cyan-100, #DDF8FC);
            color: var(--vs-primary-700, #185A9D); display: inline-flex; align-items: center; justify-content: center;
            font-weight: 800; font-size: 13px;
        }
        .gk-participant-name { font-weight: 700; font-size: 13px; }
        .gk-participant-sub  { font-size: 11px; color: var(--vs-text-secondary, #486581); }
        .gk-participant-actions { margin-left: auto; display: flex; gap: 6px; }
        .gk-mini-btn {
            padding: 6px 10px; border-radius: 8px; border: 1px solid var(--vs-border, #DCE5EF);
            background: #fff; font-size: 11px; font-weight: 700; cursor: pointer;
        }
        .gk-mini-btn.is-approve { border-color: var(--vs-success, #16A36A); color: var(--vs-success, #16A36A); }
        .gk-mini-btn.is-reject  { border-color: var(--vs-danger, #E5484D); color: var(--vs-danger, #E5484D); }

        body { padding-bottom: 100px; }
        @media (min-width: 1024px) { body { padding-bottom: 100px; } }
    </style>
</head>
<body>

<jsp:include page="/common/header.jsp" />

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<%-- =========== Header =========== --%>
<div class="gk-header">
    <div class="gk-header-inner">
        <button type="button" class="gk-back" aria-label="Quay lại" onclick="gkGoBack()">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m15 18-6-6 6-6"/></svg>
        </button>
        <div class="gk-title-block">
            <h1 class="gk-title">Ghép trận</h1>
            <p class="gk-subtitle">Tạo trận mới hoặc tìm người chơi phù hợp gần bạn.</p>
        </div>
        <button type="button" class="gk-mine-btn" onclick="gkOpenTab('cua-toi')" aria-label="Kèo của tôi">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/></svg>
            Kèo của tôi
            <span class="gk-mine-badge" id="gkMineBadge" hidden>0</span>
        </button>
    </div>
</div>

<div class="gk-shell">

    <%-- =========== Toasts từ session ===========
        (giữ tương thích session.setAttribute("message"/"error")) --%>
    <c:if test="${not empty sessionScope.message}">
        <script>window.addEventListener('DOMContentLoaded', function(){ gkToast('${fn:escapeXml(sessionScope.message)}', 'success'); });</script>
        <% session.removeAttribute("message"); %>
    </c:if>
    <c:if test="${not empty sessionScope.error}">
        <script>window.addEventListener('DOMContentLoaded', function(){ gkToast('${fn:escapeXml(sessionScope.error)}', 'danger'); });</script>
        <% session.removeAttribute("error"); %>
    </c:if>

    <%-- =========== Facility context ===========
        Chỉ hiện khi có coSoIdParam từ modal "Chọn hình thức đặt". --%>
    <c:if test="${not empty coSoIdParam}">
        <c:forEach var="cs" items="${dsCoSo}">
            <c:if test="${cs.coSoID == coSoIdParam}">
                <div class="gk-facility-card">
                    <div class="gk-facility-icon">${fn:substring(cs.tenCoSo, 0, 1)}</div>
                    <div style="min-width:0; flex: 1;">
                        <div class="gk-facility-name">${fn:escapeXml(cs.tenCoSo)}</div>
                        <div class="gk-facility-addr">
                            <c:if test="${not empty cs.diaChi}">${fn:escapeXml(cs.diaChi)}</c:if>
                        </div>
                    </div>
                    <div class="gk-facility-actions">
                        <a href="${ctx}/customer/dat-lich-truc-quan?coSoId=${cs.coSoID}" class="gk-btn-ghost">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M8 2v4"/><path d="M16 2v4"/><rect width="18" height="18" x="3" y="4" rx="2"/><path d="M3 10h18"/></svg>
                            Đặt sân
                        </a>
                    </div>
                </div>
            </c:if>
        </c:forEach>
    </c:if>

    <%-- =========== Segment control =========== --%>
    <div class="gk-segment" role="tablist">
        <button type="button" role="tab" data-tab="kham-pha" onclick="gkOpenTab('kham-pha')">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/></svg>
            Tìm người chơi
        </button>
        <button type="button" role="tab" data-tab="tao-keo" onclick="gkOpenTab('tao-keo')">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M8 12h8"/><path d="M12 8v8"/></svg>
            Tạo kèo mới
        </button>
        <button type="button" role="tab" data-tab="cua-toi" onclick="gkOpenTab('cua-toi')">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/></svg>
            Kèo của tôi
        </button>
    </div>

    <%-- =========== Panel: Tìm người chơi (Discover) =========== --%>
    <div class="gk-panel" id="gkPanelKhamPha" role="tabpanel">
        <div class="gk-filters" role="group" aria-label="Bộ lọc">
            <select id="gkFilterCoSo" onchange="gkLoadDiscover()">
                <option value="">Tất cả cơ sở</option>
                <c:forEach var="cs" items="${dsCoSo}">
                    <option value="${cs.coSoID}" ${cs.coSoID == coSoIdParam ? 'selected' : ''}>${fn:escapeXml(cs.tenCoSo)}</option>
                </c:forEach>
            </select>
            <select id="gkFilterSport" onchange="gkLoadDiscover()">
                <option value="">Tất cả môn</option>
                <c:forEach var="m" items="${dsMon}">
                    <option value="${m.monTheThaoID}">${fn:escapeXml(m.tenMon)}</option>
                </c:forEach>
            </select>
            <input type="date" id="gkFilterFrom" onchange="gkLoadDiscover()" aria-label="Từ ngày" />
            <input type="date" id="gkFilterTo"   onchange="gkLoadDiscover()" aria-label="Đến ngày" />
            <button type="button" class="gk-btn-ghost" onclick="gkClearFilters()">Xóa lọc</button>
        </div>

        <div id="gkDiscoverLoading" class="gk-loading">
            <div class="gk-skel"></div><div class="gk-skel"></div><div class="gk-skel"></div>
        </div>
        <div id="gkDiscoverError" class="gk-error" hidden>
            <p>Không thể tải danh sách kèo. Vui lòng thử lại.</p>
            <button type="button" class="gk-btn-ghost" onclick="gkLoadDiscover()">Thử lại</button>
        </div>
        <div id="gkDiscoverEmpty" class="gk-empty" hidden>
            <h3>Chưa có kèo phù hợp</h3>
            <p>Chưa có kèo nào đang mở khớp với bộ lọc của bạn.</p>
            <button type="button" class="gk-btn-primary" onclick="gkOpenTab('tao-keo')">Tạo kèo đầu tiên</button>
        </div>
        <div id="gkDiscoverList"></div>
    </div>

    <%-- =========== Panel: Tạo kèo mới =========== --%>
    <div class="gk-panel" id="gkPanelTaoKeo" role="tabpanel">
        <div class="gk-card">
            <h2 class="gk-card-title" style="margin-bottom: 6px;">Tạo kèo mới</h2>
            <p class="gk-help" style="margin-bottom: 14px;">Trước tiên bạn cần có một ca đặt sân sắp diễn ra do chính bạn đặt. Sau khi tạo kèo, người khác có thể xin tham gia đúng ca đó.</p>

            <div id="gkBookingsLoading" class="gk-loading" style="padding: 12px 0;">
                <div class="gk-skel" style="height:56px;"></div>
                <div class="gk-skel" style="height:56px;"></div>
            </div>
            <div id="gkNoBookings" class="gk-empty" hidden>
                <h3>Bạn chưa có ca đặt sân nào</h3>
                <p>Vui lòng đặt sân trước khi tạo kèo.</p>
                <a href="${ctx}/customer/dat-lich-truc-quan${not empty coSoIdParam ? '?coSoId='.concat(coSoIdParam) : ''}" class="gk-btn-primary">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M8 2v4"/><path d="M16 2v4"/><rect width="18" height="18" x="3" y="4" rx="2"/><path d="M3 10h18"/></svg>
                    Đặt sân ngay
                </a>
            </div>

            <form id="gkCreateForm" class="gk-form" hidden onsubmit="return gkSubmitCreate(event)">
                <div class="full">
                    <label class="gk-label" for="gkBookingSelect">Chọn ca đặt sân của bạn <span style="color:var(--vs-danger, #E5484D);">*</span></label>
                    <select id="gkBookingSelect" class="gk-select" required onchange="gkOnBookingChange()"></select>
                    <p class="gk-help">Sân, giờ, môn thể thao sẽ được lấy tự động từ ca đặt bạn đã chọn.</p>
                </div>
                <div>
                    <label class="gk-label" for="gkSoNguoi">Số người cần tìm thêm <span style="color:var(--vs-danger, #E5484D);">*</span></label>
                    <input type="number" id="gkSoNguoi" class="gk-input" min="1" max="20" value="3" required />
                    <p class="gk-help">Không tính bạn (chủ kèo).</p>
                </div>
                <div>
                    <label class="gk-label" for="gkTrinhDo">Trình độ mong muốn</label>
                    <select id="gkTrinhDo" class="gk-select">
                        <option>Không yêu cầu</option>
                        <option>Mới chơi</option>
                        <option>Cơ bản</option>
                        <option>Trung bình</option>
                        <option>Khá</option>
                        <option>Nâng cao</option>
                    </select>
                </div>
                <div class="full">
                    <label class="gk-label">Hình thức duyệt</label>
                    <div class="gk-radios">
                        <label class="gk-radio is-selected"><input type="radio" name="approve" value="auto" checked /> Tự động chấp nhận</label>
                        <label class="gk-radio"><input type="radio" name="approve" value="manual" /> Chủ kèo duyệt từng người</label>
                    </div>
                </div>
                <div class="full">
                    <label class="gk-label" for="gkNote">Ghi chú ngắn</label>
                    <textarea id="gkNote" class="gk-textarea" maxlength="240" placeholder="Ví dụ: mang theo bóng, chơi vui vẻ, giao lưu là chính..."></textarea>
                    <p class="gk-help"><span id="gkNoteCount">0</span>/240 ký tự</p>
                </div>

                <div class="full">
                    <div class="gk-preview" id="gkPreviewBox">
                        <div class="gk-preview-empty">Chọn ca đặt sân để xem trước thẻ kèo.</div>
                    </div>
                </div>

                <div class="full" style="display:flex; gap:10px; justify-content:flex-end;">
                    <button type="button" class="gk-btn-ghost" onclick="gkOpenTab('kham-pha')">Hủy</button>
                    <button type="submit" class="gk-btn-primary" id="gkCreateSubmit">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 5v14"/><path d="M5 12h14"/></svg>
                        Đăng kèo
                    </button>
                </div>
            </form>
        </div>

        <div class="gk-card" style="background: var(--vs-cyan-50, #F0FCFE); border-color: var(--vs-cyan-100, #DDF8FC);">
            <h3 style="margin:0 0 10px; font-size: 13px; font-weight: 800; color: var(--vs-primary-700, #185A9D);">Cách kèo hoạt động</h3>
            <div style="display: grid; gap: 8px; font-size: 12px; color: var(--vs-text, #102A43); line-height: 1.5;">
                <div><b>1.</b> Bạn đặt sân trước qua trang "Đặt lịch trực quan".</div>
                <div><b>2.</b> Quay lại đây, chọn ca đặt của bạn và điền số người cần tìm.</div>
                <div><b>3.</b> Kèo hiển thị ở tab "Tìm người chơi" cho những người khác thấy.</div>
                <div><b>4.</b> Nếu chọn "Chủ kèo duyệt", bạn sẽ thấy yêu cầu tham gia trong "Kèo của tôi".</div>
            </div>
        </div>
    </div>

    <%-- =========== Panel: Kèo của tôi =========== --%>
    <div class="gk-panel" id="gkPanelCuaToi" role="tabpanel">
        <h2 style="font-size: 13px; font-weight: 800; color: var(--vs-text-secondary, #486581); text-transform: uppercase; letter-spacing: .06em; margin: 4px 0 10px;">Kèo bạn tạo</h2>
        <div id="gkMineCreatedList"></div>
        <div id="gkMineCreatedEmpty" class="gk-empty" hidden>
            <p style="margin: 8px 0;">Bạn chưa tạo kèo nào.</p>
        </div>

        <h2 style="font-size: 13px; font-weight: 800; color: var(--vs-text-secondary, #486581); text-transform: uppercase; letter-spacing: .06em; margin: 20px 0 10px;">Kèo bạn tham gia</h2>
        <div id="gkMineJoinedList"></div>
        <div id="gkMineJoinedEmpty" class="gk-empty" hidden>
            <p style="margin: 8px 0;">Bạn chưa tham gia kèo nào.</p>
        </div>
    </div>

</div>

<%-- =========== Match detail sheet =========== --%>
<div id="gkOverlay" class="gk-overlay" onclick="gkCloseSheet()"></div>
<div id="gkSheet" class="gk-sheet" role="dialog" aria-modal="true" aria-labelledby="gkSheetTitle">
    <div class="gk-sheet-handle"><span></span></div>
    <div class="gk-sheet-head">
        <h2 id="gkSheetTitle" style="margin:0; font-size: 16px; font-weight: 800;">Chi tiết kèo</h2>
        <button type="button" class="gk-sheet-close" onclick="gkCloseSheet()" aria-label="Đóng">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg>
        </button>
    </div>
    <div class="gk-sheet-body" id="gkSheetBody"></div>
    <div class="gk-sheet-bar" id="gkSheetBar"></div>
</div>

<div class="gk-toast" id="gkToast" role="status" aria-live="polite"></div>

<%-- =========== Server data + Script =========== --%>
<script id="gkServerData" type="application/json">
{
  "contextPath": "${ctx}",
  "initialTab": "${initialTab}",
  "preCoSoId": <c:choose><c:when test="${not empty coSoIdParam}">${coSoIdParam}</c:when><c:otherwise>null</c:otherwise></c:choose>,
  "preSanId":  <c:choose><c:when test="${not empty sanIdParam}">${sanIdParam}</c:when><c:otherwise>null</c:otherwise></c:choose>,
  "accountId": <c:choose><c:when test="${not empty sessionScope.user}">${sessionScope.user.accountId}</c:when><c:otherwise>null</c:otherwise></c:choose>
}
</script>
<script>
(function () {
    const server = JSON.parse(document.getElementById('gkServerData').textContent);
    const CTX = server.contextPath;
    const ME_ID = server.accountId;

    function fmtVnd(n) {
        const v = parseFloat(n);
        if (isNaN(v) || v <= 0) return '';
        return new Intl.NumberFormat('vi-VN').format(Math.round(v)) + ' đ';
    }
    function fmtDateVi(iso) {
        if (!iso) return '';
        const d = new Date(iso + 'T00:00:00');
        const days = ['CN','T2','T3','T4','T5','T6','T7'];
        return days[d.getDay()] + ' ' + String(d.getDate()).padStart(2, '0') + '/' + String(d.getMonth() + 1).padStart(2, '0');
    }
    function escapeHtml(s) {
        if (s == null) return '';
        return String(s).replace(/[&<>"']/g, function (c) { return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]; });
    }
    function initials(name) {
        if (!name) return '?';
        return name.trim().split(/\s+/).map(function (p) { return p[0]; }).slice(-2).join('').toUpperCase();
    }
    function reputationClass(score) {
        if (score == null) return '';
        if (score >= 80) return '';
        if (score >= 50) return 'is-watch';
        return 'is-risk';
    }
    function reputationLabel(score) {
        if (score == null) return 'Chưa có uy tín';
        if (score >= 80) return 'Uy tín tốt';
        if (score >= 50) return 'Cần theo dõi';
        return 'Rủi ro cao';
    }

    // -------- Toast (exposed on window for JSP inline invocation) --------
    let toastTimer = null;
    window.gkToast = function (msg, kind) {
        const el = document.getElementById('gkToast');
        el.className = 'gk-toast';
        if (kind === 'danger')  el.classList.add('is-danger');
        if (kind === 'success') el.classList.add('is-success');
        el.textContent = msg;
        el.classList.add('is-open');
        clearTimeout(toastTimer);
        toastTimer = setTimeout(function () { el.classList.remove('is-open'); }, 3200);
    };

    // -------- Tab switching --------
    window.gkOpenTab = function (name) {
        document.querySelectorAll('.gk-segment button').forEach(function (b) {
            b.classList.toggle('is-active', b.dataset.tab === name);
        });
        document.querySelectorAll('.gk-panel').forEach(function (p) {
            p.classList.remove('is-active');
        });
        const map = { 'kham-pha': 'gkPanelKhamPha', 'tao-keo': 'gkPanelTaoKeo', 'cua-toi': 'gkPanelCuaToi' };
        const el = document.getElementById(map[name] || 'gkPanelKhamPha');
        if (el) el.classList.add('is-active');
        const url = new URL(window.location.href);
        url.searchParams.set('tab', name);
        history.replaceState(null, '', url.toString());

        if (name === 'kham-pha') gkLoadDiscover();
        if (name === 'tao-keo')  gkLoadBookingsForCreate();
        if (name === 'cua-toi')  gkLoadMine();
    };

    window.gkGoBack = function () {
        if (history.length > 1) history.back();
        else window.location.href = CTX + '/index.jsp';
    };

    window.gkClearFilters = function () {
        document.getElementById('gkFilterCoSo').value = '';
        document.getElementById('gkFilterSport').value = '';
        document.getElementById('gkFilterFrom').value = '';
        document.getElementById('gkFilterTo').value = '';
        gkLoadDiscover();
    };

    // -------- Discover: load open matches --------
    window.gkLoadDiscover = function () {
        const coSo = document.getElementById('gkFilterCoSo').value;
        const sport = document.getElementById('gkFilterSport').value;
        const from = document.getElementById('gkFilterFrom').value;
        const to   = document.getElementById('gkFilterTo').value;
        const params = new URLSearchParams();
        if (coSo)  params.set('coSoId', coSo);
        if (sport) params.set('monTheThaoId', sport);
        if (from)  params.set('from', from);
        if (to)    params.set('to', to);

        const box = document.getElementById('gkDiscoverList');
        document.getElementById('gkDiscoverLoading').hidden = false;
        document.getElementById('gkDiscoverError').hidden = true;
        document.getElementById('gkDiscoverEmpty').hidden = true;
        box.innerHTML = '';

        fetch(CTX + '/customer/api/matches?' + params.toString(), { headers: { 'Accept': 'application/json' } })
            .then(function (r) { if (!r.ok) throw new Error('HTTP ' + r.status); return r.json(); })
            .then(function (data) {
                document.getElementById('gkDiscoverLoading').hidden = true;
                if (!data.success) throw new Error(data.error || 'Không thể tải');
                const list = data.matches || [];
                if (!list.length) { document.getElementById('gkDiscoverEmpty').hidden = false; return; }
                list.forEach(function (m) { box.appendChild(matchCard(m, false)); });
            })
            .catch(function (err) {
                console.error(err);
                document.getElementById('gkDiscoverLoading').hidden = true;
                document.getElementById('gkDiscoverError').hidden = false;
            });
    };

    function matchCard(m, ownerView) {
        const card = document.createElement('div');
        card.className = 'gk-card';
        const capacity = m.soNguoiCanTim || 1;
        const joined = m.soNguoiThamGia || 0;
        const percent = Math.min(100, Math.round((joined / capacity) * 100));
        const scoreClass = reputationClass(m.diemUyTinNguoiTao);
        const scoreLabel = reputationLabel(m.diemUyTinNguoiTao);
        const trangThai = m.trangThai || 'Đang mở';
        const trangThaiClass = trangThai === 'Đang mở' ? 'is-open'
            : trangThai === 'Đã đủ người' ? 'is-full'
            : trangThai === 'Đã hủy' ? 'is-cancel' : 'is-closed';

        card.innerHTML =
            '<div class="gk-card-head">'
              + '<div>'
                + '<span class="gk-sport-badge">' + escapeHtml(m.tenMonTheThao || 'Thể thao') + '</span> '
                + '<span class="gk-status-badge ' + trangThaiClass + '">' + escapeHtml(trangThai) + '</span>'
              + '</div>'
              + '<span class="gk-reputation ' + scoreClass + '" title="Điểm uy tín chủ kèo">'
                + escapeHtml(scoreLabel) + (m.diemUyTinNguoiTao != null ? (' · ' + m.diemUyTinNguoiTao + '/100') : '')
              + '</span>'
            + '</div>'
            + '<h3 class="gk-card-title">' + escapeHtml(m.tenCoSo || 'Cơ sở') + ' · ' + escapeHtml(m.tenSan || 'Sân') + '</h3>'
            + '<div class="gk-card-meta">'
              + '<span title="Thời gian">' + iconSvg('clock') + fmtDateVi(m.ngayDat) + ' · ' + escapeHtml(m.gioBatDau || '') + '–' + escapeHtml(m.gioKetThuc || '') + '</span>'
              + (m.trinhDo ? '<span>' + iconSvg('level') + 'Trình độ: ' + escapeHtml(m.trinhDo) + '</span>' : '')
              + '<span>' + iconSvg('user') + 'Chủ kèo: ' + escapeHtml(m.tenNguoiTao || '—') + '</span>'
            + '</div>'
            + (m.actualNote ? '<p style="margin: 8px 0 0; font-size: 12.5px; color: var(--vs-text-secondary, #486581);">' + escapeHtml(m.actualNote) + '</p>' : '')
            + '<div class="gk-slot-bar"><div class="gk-slot-fill" style="width:' + percent + '%"></div></div>'
            + '<div class="gk-participants"><span>' + joined + '/' + capacity + ' người tham gia</span><span>Còn ' + Math.max(0, capacity - joined) + ' chỗ</span></div>'
            + '<div class="gk-card-actions">'
              + '<button type="button" class="gk-btn-secondary" data-action="detail" data-keoid="' + m.keoId + '">Xem chi tiết</button>'
              + (!ownerView
                  ? '<button type="button" class="gk-btn-primary" data-action="join" data-keoid="' + m.keoId + '" ' + (m.trangThai !== 'Đang mở' || joined >= capacity ? 'disabled' : '') + '>Xin tham gia</button>'
                  : '')
            + '</div>';

        card.querySelectorAll('[data-action]').forEach(function (btn) {
            btn.addEventListener('click', function () {
                const action = btn.dataset.action;
                const keoId = btn.dataset.keoid;
                if (action === 'detail') openMatchSheet(keoId);
                if (action === 'join')   requestJoin(keoId, btn);
            });
        });
        return card;
    }

    function iconSvg(kind) {
        if (kind === 'clock')
            return '<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align:-2px;margin-right:2px;"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>';
        if (kind === 'level')
            return '<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align:-2px;margin-right:2px;"><path d="M3 3v18h18"/><path d="m7 15 3-3 4 4 6-6"/></svg>';
        if (kind === 'user')
            return '<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align:-2px;margin-right:2px;"><circle cx="12" cy="8" r="4"/><path d="M20 21a8 8 0 0 0-16 0"/></svg>';
        return '';
    }

    function requestJoin(keoId, btn) {
        if (!ME_ID) { gkToast('Vui lòng đăng nhập.', 'danger'); return; }
        if (btn.disabled) return;
        btn.disabled = true; btn.textContent = 'Đang gửi...';
        const form = new FormData(); form.append('keoId', keoId);
        fetch(CTX + '/customer/api/matches/join', { method: 'POST', body: form, headers: { 'Accept': 'application/json' } })
            .then(function (r) { return r.json(); })
            .then(function (data) {
                gkToast(data.message || (data.success ? 'Đã gửi.' : 'Lỗi.'), data.success ? 'success' : 'danger');
                if (data.success) gkLoadDiscover();
                else { btn.disabled = false; btn.textContent = 'Xin tham gia'; }
            })
            .catch(function () {
                gkToast('Không thể gửi yêu cầu. Thử lại.', 'danger');
                btn.disabled = false; btn.textContent = 'Xin tham gia';
            });
    }

    // -------- Detail sheet --------
    let currentDetailKeoId = null;
    function openMatchSheet(keoId) {
        currentDetailKeoId = keoId;
        document.getElementById('gkSheetBody').innerHTML = '<div class="gk-loading"><div class="gk-skel" style="height:80px;"></div><div class="gk-skel"></div><div class="gk-skel"></div></div>';
        document.getElementById('gkSheetBar').innerHTML = '';
        document.getElementById('gkOverlay').classList.add('is-open');
        document.getElementById('gkSheet').classList.add('is-open');
        document.body.style.overflow = 'hidden';

        fetch(CTX + '/customer/api/matches/detail?keoId=' + encodeURIComponent(keoId))
            .then(function (r) { return r.json(); })
            .then(function (data) {
                if (!data.success) throw new Error(data.error || 'Lỗi');
                renderSheet(data);
            })
            .catch(function () {
                document.getElementById('gkSheetBody').innerHTML = '<div class="gk-error"><p>Không thể tải chi tiết.</p></div>';
            });
    }
    window.gkCloseSheet = function () {
        document.getElementById('gkOverlay').classList.remove('is-open');
        document.getElementById('gkSheet').classList.remove('is-open');
        document.body.style.overflow = '';
        currentDetailKeoId = null;
    };

    function renderSheet(data) {
        const m = data.match;
        const participants = data.participants || [];
        const me = data.me;
        const isOwner = !!data.isOwner;
        const capacity = m.soNguoiCanTim || 1;
        const joined = m.soNguoiThamGia || 0;

        const body = document.getElementById('gkSheetBody');
        body.innerHTML =
            '<div style="display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 12px;">'
              + '<span class="gk-sport-badge">' + escapeHtml(m.tenMonTheThao || 'Thể thao') + '</span>'
              + '<span class="gk-status-badge is-open">' + escapeHtml(m.trangThai) + '</span>'
              + '<span class="gk-reputation ' + reputationClass(m.diemUyTinNguoiTao) + '">'
                + escapeHtml(reputationLabel(m.diemUyTinNguoiTao))
                + (m.diemUyTinNguoiTao != null ? (' · ' + m.diemUyTinNguoiTao + '/100') : '') + '</span>'
            + '</div>'
            + '<h3 style="margin: 0 0 6px; font-size: 16px; font-weight: 800;">' + escapeHtml(m.tenCoSo || '') + ' · ' + escapeHtml(m.tenSan || '') + '</h3>'
            + '<p style="margin: 0 0 8px; font-size: 12px; color: var(--vs-text-secondary, #486581);">' + escapeHtml(m.diaChiCoSo || '') + '</p>'
            + '<div style="margin: 8px 0; padding: 12px; background: #f8fafc; border-radius: 10px; display: grid; gap: 4px; font-size: 13px;">'
              + '<div><b>Thời gian:</b> ' + fmtDateVi(m.ngayDat) + ' · ' + escapeHtml(m.gioBatDau || '') + '–' + escapeHtml(m.gioKetThuc || '') + '</div>'
              + '<div><b>Loại sân:</b> ' + escapeHtml(m.tenLoaiSan || '—') + '</div>'
              + '<div><b>Trình độ:</b> ' + escapeHtml(m.trinhDo || 'Không yêu cầu') + '</div>'
              + '<div><b>Hình thức duyệt:</b> ' + (m.hinhThucDuyet === 'manual' ? 'Chủ kèo duyệt từng người' : 'Tự động chấp nhận') + '</div>'
              + '<div><b>Tình trạng:</b> ' + joined + '/' + capacity + ' người'
                + (joined < capacity ? (' · Còn ' + (capacity - joined) + ' chỗ') : ' · Đã đủ') + '</div>'
            + '</div>'
            + (m.actualNote ? '<p style="font-size: 13px; color: var(--vs-text, #102A43); line-height: 1.5;"><b>Ghi chú:</b> ' + escapeHtml(m.actualNote) + '</p>' : '')
            + '<h4 style="margin: 16px 0 8px; font-size: 13px; font-weight: 800; text-transform: uppercase; letter-spacing: .06em; color: var(--vs-text-secondary, #486581);">Chủ kèo</h4>'
            + '<div class="gk-participant-row">'
              + '<div class="gk-avatar">' + escapeHtml(initials(m.tenNguoiTao)) + '</div>'
              + '<div>'
                + '<div class="gk-participant-name">' + escapeHtml(m.tenNguoiTao || '—') + ' <span style="font-size:10px;color:#94a3b8;font-weight:600;">(Chủ kèo)</span></div>'
                + '<div class="gk-participant-sub">Uy tín: ' + (m.diemUyTinNguoiTao != null ? m.diemUyTinNguoiTao + '/100' : '—') + '</div>'
              + '</div>'
            + '</div>'
            + '<h4 style="margin: 16px 0 8px; font-size: 13px; font-weight: 800; text-transform: uppercase; letter-spacing: .06em; color: var(--vs-text-secondary, #486581);">Người tham gia (' + participants.length + ')</h4>'
            + (participants.length ? '' : '<p class="gk-participant-sub">Chưa có ai xin tham gia.</p>');

        participants.forEach(function (p) {
            const row = document.createElement('div');
            row.className = 'gk-participant-row';
            let statusText = p.trangThaiThamGia || '';
            row.innerHTML =
                '<div class="gk-avatar">' + escapeHtml(initials(p.tenNguoiChoi)) + '</div>'
                + '<div>'
                  + '<div class="gk-participant-name">' + escapeHtml(p.tenNguoiChoi || 'Người chơi') + '</div>'
                  + '<div class="gk-participant-sub">Uy tín: ' + (p.diemUyTin != null ? p.diemUyTin + '/100' : '—') + ' · ' + escapeHtml(statusText) + '</div>'
                + '</div>';
            const actions = document.createElement('div');
            actions.className = 'gk-participant-actions';
            if (isOwner && statusText === 'Chờ duyệt') {
                const bA = document.createElement('button'); bA.type = 'button'; bA.className = 'gk-mini-btn is-approve'; bA.textContent = 'Duyệt';
                bA.onclick = function () { participantAction(p.chiTietKeoId, 'approve'); };
                const bR = document.createElement('button'); bR.type = 'button'; bR.className = 'gk-mini-btn is-reject'; bR.textContent = 'Từ chối';
                bR.onclick = function () { participantAction(p.chiTietKeoId, 'reject'); };
                actions.appendChild(bA); actions.appendChild(bR);
            } else if (me && me.chiTietKeoId === p.chiTietKeoId && (statusText === 'Chờ duyệt' || statusText === 'Đã tham gia')) {
                const bL = document.createElement('button'); bL.type = 'button'; bL.className = 'gk-mini-btn is-reject'; bL.textContent = 'Rời kèo';
                bL.onclick = function () { participantAction(p.chiTietKeoId, 'leave'); };
                actions.appendChild(bL);
            }
            row.appendChild(actions);
            body.appendChild(row);
        });

        // Sheet bar action
        const bar = document.getElementById('gkSheetBar');
        bar.innerHTML = '';
        if (isOwner) {
            const btnClose = document.createElement('button');
            btnClose.type = 'button'; btnClose.className = 'gk-btn-ghost'; btnClose.textContent = 'Dừng nhận';
            btnClose.onclick = function () { ownerAction('close'); };
            const btnCancel = document.createElement('button');
            btnCancel.type = 'button'; btnCancel.className = 'gk-btn-secondary'; btnCancel.textContent = 'Hủy kèo';
            btnCancel.onclick = function () { if (confirm('Hủy toàn bộ kèo này?')) ownerAction('cancel'); };
            bar.appendChild(btnClose); bar.appendChild(btnCancel);
        } else if (!me && data.isLoggedIn && m.trangThai === 'Đang mở' && joined < capacity) {
            const btnJoin = document.createElement('button');
            btnJoin.type = 'button'; btnJoin.className = 'gk-btn-primary is-full-width';
            btnJoin.textContent = m.hinhThucDuyet === 'manual' ? 'Gửi yêu cầu tham gia' : 'Tham gia ngay';
            btnJoin.onclick = function () { requestJoin(m.keoId, btnJoin); };
            bar.appendChild(btnJoin);
        } else if (!data.isLoggedIn) {
            const a = document.createElement('a');
            a.href = CTX + '/dangnhap'; a.className = 'gk-btn-primary is-full-width'; a.textContent = 'Đăng nhập để tham gia';
            bar.appendChild(a);
        } else if (me) {
            const btnLeave = document.createElement('button');
            btnLeave.type = 'button'; btnLeave.className = 'gk-btn-secondary'; btnLeave.textContent = 'Rời kèo';
            btnLeave.onclick = function () { participantAction(me.chiTietKeoId, 'leave'); };
            bar.appendChild(btnLeave);
        }
    }

    function participantAction(chiTietKeoId, action) {
        const form = new FormData();
        form.append('chiTietKeoId', chiTietKeoId);
        fetch(CTX + '/customer/api/matches/' + action, { method: 'POST', body: form })
            .then(function (r) { return r.json(); })
            .then(function (data) {
                gkToast(data.message || (data.success ? 'Đã cập nhật.' : 'Lỗi.'), data.success ? 'success' : 'danger');
                if (data.success && currentDetailKeoId) openMatchSheet(currentDetailKeoId);
            });
    }
    function ownerAction(action) {
        if (!currentDetailKeoId) return;
        const form = new FormData();
        form.append('keoId', currentDetailKeoId);
        fetch(CTX + '/customer/api/matches/' + action, { method: 'POST', body: form })
            .then(function (r) { return r.json(); })
            .then(function (data) {
                gkToast(data.message || (data.success ? 'Đã cập nhật.' : 'Lỗi.'), data.success ? 'success' : 'danger');
                if (data.success) { gkCloseSheet(); gkLoadMine(); gkLoadDiscover(); }
            });
    }

    // -------- Create match: load user bookings --------
    let myBookings = [];
    window.gkLoadBookingsForCreate = function () {
        document.getElementById('gkBookingsLoading').hidden = false;
        document.getElementById('gkNoBookings').hidden = true;
        document.getElementById('gkCreateForm').hidden = true;
        fetch(CTX + '/customer/api/matches/my-bookings')
            .then(function (r) { return r.json(); })
            .then(function (data) {
                document.getElementById('gkBookingsLoading').hidden = true;
                if (!data.success) throw new Error(data.error || 'Lỗi');
                myBookings = data.bookings || [];
                if (!myBookings.length) {
                    document.getElementById('gkNoBookings').hidden = false;
                    return;
                }
                document.getElementById('gkCreateForm').hidden = false;
                const sel = document.getElementById('gkBookingSelect');
                sel.innerHTML = '<option value="">-- Chọn ca đặt sân --</option>';
                myBookings.forEach(function (b) {
                    const opt = document.createElement('option');
                    opt.value = b.datSanId;
                    opt.textContent = fmtDateVi(b.ngayDat) + ' · ' + b.gioBatDau + '–' + b.gioKetThuc + ' · ' + b.tenSan + ' (' + b.tenCoSo + ') · ' + b.trangThai;
                    sel.appendChild(opt);
                });
                if (server.preSanId) {
                    const match = myBookings.find(function (b) { return b.sanId === server.preSanId; });
                    if (match) { sel.value = match.datSanId; gkOnBookingChange(); }
                }
            })
            .catch(function () {
                document.getElementById('gkBookingsLoading').hidden = true;
                document.getElementById('gkNoBookings').hidden = false;
            });
    };
    window.gkOnBookingChange = function () {
        const id = document.getElementById('gkBookingSelect').value;
        const b = myBookings.find(function (x) { return x.datSanId == id; });
        const box = document.getElementById('gkPreviewBox');
        if (!b) { box.innerHTML = '<div class="gk-preview-empty">Chọn ca đặt sân để xem trước thẻ kèo.</div>'; return; }
        const cap = parseInt(document.getElementById('gkSoNguoi').value, 10) || 1;
        const trinhDo = document.getElementById('gkTrinhDo').value || 'Không yêu cầu';
        const note = document.getElementById('gkNote').value || '';
        box.innerHTML =
            '<div style="display:flex; flex-wrap: wrap; gap: 6px; margin-bottom: 8px;">'
              + '<span class="gk-sport-badge">' + escapeHtml(b.tenLoaiSan || 'Thể thao') + '</span>'
              + '<span class="gk-status-badge is-open">Đang mở</span>'
            + '</div>'
            + '<h4 style="margin: 0 0 4px; font-size: 14px; font-weight: 800;">' + escapeHtml(b.tenCoSo) + ' · ' + escapeHtml(b.tenSan) + '</h4>'
            + '<p style="margin: 0; font-size: 12px; color: var(--vs-text-secondary, #486581);">'
              + fmtDateVi(b.ngayDat) + ' · ' + escapeHtml(b.gioBatDau) + '–' + escapeHtml(b.gioKetThuc) + ' · Cần thêm ' + cap + ' người · Trình độ: ' + escapeHtml(trinhDo)
            + '</p>'
            + (note ? '<p style="margin: 6px 0 0; font-size: 12px; color: var(--vs-text, #102A43);">' + escapeHtml(note) + '</p>' : '')
            + (b.tongTienDuKien ? '<p style="margin: 6px 0 0; font-size: 12px; color: var(--vs-text-secondary, #486581);">Tổng tiền sân dự kiến (do chủ kèo trả): ' + fmtVnd(b.tongTienDuKien) + '</p>' : '');
    };
    ['gkSoNguoi', 'gkTrinhDo', 'gkNote'].forEach(function (id) {
        document.addEventListener('input', function (e) { if (e.target && e.target.id === id) gkOnBookingChange(); });
    });
    document.querySelectorAll('.gk-radios .gk-radio input').forEach(function (r) {
        r.addEventListener('change', function () {
            document.querySelectorAll('.gk-radios .gk-radio').forEach(function (l) {
                l.classList.toggle('is-selected', l.querySelector('input').checked);
            });
        });
    });
    document.getElementById('gkNote').addEventListener('input', function (e) {
        document.getElementById('gkNoteCount').textContent = e.target.value.length;
    });

    window.gkSubmitCreate = function (evt) {
        evt.preventDefault();
        const btn = document.getElementById('gkCreateSubmit');
        if (btn.disabled) return false;
        const datSanId = document.getElementById('gkBookingSelect').value;
        if (!datSanId) { gkToast('Vui lòng chọn ca đặt sân.', 'danger'); return false; }
        const b = myBookings.find(function (x) { return x.datSanId == datSanId; });
        const form = new FormData();
        form.append('datSanId', datSanId);
        if (b && b.monTheThaoId != null) form.append('monTheThaoId', b.monTheThaoId);
        form.append('soNguoiCanTim', document.getElementById('gkSoNguoi').value);
        form.append('trinhDo', document.getElementById('gkTrinhDo').value);
        const approveEl = document.querySelector('.gk-radios input[name="approve"]:checked');
        form.append('hinhThucDuyet', approveEl ? approveEl.value : 'auto');
        form.append('note', document.getElementById('gkNote').value);
        btn.disabled = true; btn.textContent = 'Đang tạo...';
        fetch(CTX + '/customer/ghep-keo', {
            method: 'POST', body: form,
            headers: { 'Accept': 'application/json', 'X-Requested-With': 'XMLHttpRequest' }
        })
            .then(function (r) { return r.json(); })
            .then(function (data) {
                gkToast(data.message || (data.success ? 'Đã tạo.' : 'Lỗi.'), data.success ? 'success' : 'danger');
                btn.disabled = false; btn.innerHTML = '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 5v14"/><path d="M5 12h14"/></svg> Đăng kèo';
                if (data.success) {
                    document.getElementById('gkNote').value = '';
                    gkOpenTab('cua-toi');
                }
            })
            .catch(function () {
                btn.disabled = false;
                gkToast('Không thể tạo kèo.', 'danger');
            });
        return false;
    };

    // -------- My matches --------
    window.gkLoadMine = function () {
        if (!ME_ID) {
            document.getElementById('gkMineCreatedList').innerHTML = '';
            document.getElementById('gkMineJoinedList').innerHTML = '';
            document.getElementById('gkMineCreatedEmpty').hidden = false;
            document.getElementById('gkMineJoinedEmpty').hidden = false;
            return;
        }
        fetch(CTX + '/customer/api/matches/mine')
            .then(function (r) { return r.json(); })
            .then(function (data) {
                if (!data.success) return;
                const created = data.created || [];
                const joined = data.joined || [];
                const createdBox = document.getElementById('gkMineCreatedList');
                const joinedBox = document.getElementById('gkMineJoinedList');
                createdBox.innerHTML = ''; joinedBox.innerHTML = '';
                document.getElementById('gkMineCreatedEmpty').hidden = !!created.length;
                document.getElementById('gkMineJoinedEmpty').hidden = !!joined.length;
                created.forEach(function (m) { createdBox.appendChild(matchCard(m, true)); });
                joined.forEach(function (m) { joinedBox.appendChild(matchCard(m, false)); });
                const total = created.length + joined.length;
                const badge = document.getElementById('gkMineBadge');
                if (total > 0) { badge.hidden = false; badge.textContent = total; } else { badge.hidden = true; }
            });
    };

    // Init
    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') gkCloseSheet();
    });
    gkOpenTab(server.initialTab || 'kham-pha');
    gkLoadMine(); // preload badge
})();
</script>

<jsp:include page="/customer/common/bottom-nav.jsp" />
</body>
</html>
