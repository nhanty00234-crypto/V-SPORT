<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%--
    Trang QR thanh toán NHÚNG của V-SPORT (Phần 4–12).
    Forward từ CustomerPayosQrServlet (/customer/thanh-toan-qr?datSanId=...).
    Giao diện đồng bộ nhận diện thương hiệu V-SPORT (Xanh lá #10b981 & Navy #0f172a).
--%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Thanh toán đặt sân - V-SPORT</title>
    <jsp:include page="/common/xtra-head.jsp" />
    <style>
        [hidden] { display: none !important; }
        html, body {
            background: #f8fafc;
            color: #0f172a;
            font-family: 'Outfit', -apple-system, BlinkMacSystemFont, sans-serif;
            margin: 0;
            padding: 0;
            min-height: 100vh;
        }

        body {
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }

        .qr-main-content {
            flex: 1 0 auto;
        }

        /* Header */
        .qr-header {
            position: sticky; top: 0; z-index: 40;
            background: #0f172a; color: #fff;
            box-shadow: 0 2px 10px rgba(0,0,0,0.15);
        }
        .qr-header-inner {
            display: flex; align-items: center; justify-content: space-between; gap: 14px;
            padding: 12px 24px; min-height: 56px; max-width: 1180px; margin: 0 auto;
        }
        .qr-header-left { display: flex; align-items: center; gap: 14px; min-width: 0; }
        .qr-back {
            width: 38px; height: 38px; flex-shrink: 0;
            display: inline-flex; align-items: center; justify-content: center;
            border-radius: 50%; background: rgba(255,255,255,.12); color: #fff; border: none; cursor: pointer;
            transition: all 120ms ease; text-decoration: none;
        }
        .qr-back:hover { background: rgba(255,255,255,.22); }
        .qr-title { font-size: 20px; font-weight: 800; margin: 0; color: #fff; white-space: nowrap; }
        .qr-brand { font-size: 14px; font-weight: 800; letter-spacing: .08em; color: #cbd5e1; }
        .qr-brand span { color: #10b981; }

        /* Main Shell */
        .qr-shell {
            width: calc(100% - 48px);
            max-width: 1180px;
            margin: 24px auto 40px;
            box-sizing: border-box;
        }

        .qr-grid { display: grid; grid-template-columns: 1fr; gap: 24px; }
        @media (min-width: 860px) {
            .qr-grid { grid-template-columns: minmax(320px, 400px) 1fr; align-items: start; }
        }

        .qr-card {
            background: #ffffff;
            border: 1.5px solid #e2e8f0;
            border-radius: 16px;
            padding: 20px;
            box-shadow: 0 2px 6px rgba(15,23,42,0.03);
        }
        .qr-card h2 {
            font-size: 15px; font-weight: 800; color: #1e293b;
            text-transform: uppercase; letter-spacing: .04em; margin: 0 0 14px;
            display: flex; align-items: center; gap: 8px;
        }

        /* Status pill */
        .qr-status { display: inline-flex; align-items: center; gap: 8px; padding: 6px 14px; border-radius: 999px; font-size: 13px; font-weight: 800; }
        .qr-status .dot { width: 8px; height: 8px; border-radius: 50%; }
        .qr-status.is-waiting { background: #fef3c7; color: #b45309; }
        .qr-status.is-waiting .dot { background: #f59e0b; animation: qrPulse 1.4s ease-in-out infinite; }
        .qr-status.is-paid { background: rgba(16,185,129,0.12); color: #047857; }
        .qr-status.is-paid .dot { background: #10b981; }
        .qr-status.is-danger { background: #fee2e2; color: #b91c1c; }
        .qr-status.is-danger .dot { background: #ef4444; }
        @keyframes qrPulse { 0%,100% { opacity: 1; } 50% { opacity: .35; } }

        /* QR panel */
        .qr-visual { display: flex; flex-direction: column; align-items: center; text-align: center; }
        .qr-plate { background: #fff; border: 1.5px solid #e2e8f0; border-radius: 16px; padding: 18px; box-shadow: 0 2px 8px rgba(0,0,0,0.04); }
        .qr-plate img { display: block; width: 260px; height: 260px; max-width: 62vw; max-height: 62vw; image-rendering: pixelated; }
        .qr-logo { margin-top: 14px; font-size: 18px; font-weight: 800; letter-spacing: .08em; color: #0f172a; }
        .qr-logo span { color: #10b981; }
        .qr-countdown { margin-top: 10px; font-size: 13.5px; font-weight: 600; color: #475569; }
        .qr-countdown b { font-variant-numeric: tabular-nums; color: #059669; font-weight: 800; font-size: 15px; }

        /* Transfer info rows */
        .qr-info-row { display: flex; align-items: center; justify-content: space-between; gap: 12px; padding: 12px 0; border-bottom: 1px solid #f1f5f9; }
        .qr-info-row:last-child { border-bottom: none; }
        .qr-info-k { font-size: 13px; color: #64748b; font-weight: 600; flex-shrink: 0; }
        .qr-info-v { font-size: 15px; font-weight: 700; color: #0f172a; text-align: right; word-break: break-word; }
        .qr-info-v.amount { color: #059669; font-size: 18px; font-weight: 800; }
        .qr-copy {
            display: inline-flex; align-items: center; gap: 6px; margin-left: 8px; border: 1px solid #cbd5e1; background: #fff;
            color: #047857; border-radius: 8px; padding: 5px 11px; font-size: 12.5px; font-weight: 800; cursor: pointer; font-family: inherit;
            transition: all 120ms ease;
        }
        .qr-copy:hover { border-color: #10b981; background: rgba(16,185,129,0.08); color: #059669; }
        .qr-copy:active { transform: translateY(1px); }

        .qr-summary { margin-top: 6px; }
        .qr-summary .qr-info-k { font-weight: 700; }
        .qr-steps { margin: 6px 0 0; padding-left: 20px; font-size: 13.5px; color: #475569; line-height: 1.7; }
        .qr-steps li { margin: 4px 0; }

        /* Buttons */
        .qr-actions { display: flex; flex-direction: column; gap: 10px; margin-top: 10px; }
        .qr-btn {
            display: inline-flex; align-items: center; justify-content: center; gap: 8px; height: 50px; border-radius: 12px; border: 1.5px solid transparent;
            font-weight: 800; font-size: 15px; cursor: pointer; font-family: inherit; text-decoration: none; transition: all 150ms ease;
        }
        .qr-btn:active { transform: translateY(1px); }
        .qr-btn-primary { background: #10b981; color: #fff; box-shadow: 0 4px 14px rgba(16,185,129,0.35); }
        .qr-btn-primary:hover { background: #059669; box-shadow: 0 6px 18px rgba(16,185,129,0.45); }
        .qr-btn-primary:disabled { background: #94a3b8; cursor: not-allowed; box-shadow: none; }
        .qr-btn-secondary { background: #0f172a; color: #fff; }
        .qr-btn-secondary:hover { background: #1e293b; }
        .qr-btn-ghost { background: #fff; color: #334155; border-color: #cbd5e1; }
        .qr-btn-ghost:hover { border-color: #10b981; color: #059669; background: rgba(16,185,129,0.04); }
        .qr-btn-danger-ghost { background: #fff; color: #ef4444; border-color: #fca5a5; }
        .qr-btn-danger-ghost:hover { background: #fef2f2; border-color: #ef4444; }
        .qr-btn .spinner { width: 16px; height: 16px; border-radius: 50%; border: 2.5px solid rgba(255,255,255,.4); border-top-color: #fff; animation: qrSpin .8s linear infinite; }
        .qr-btn-ghost .spinner { border-color: rgba(5,150,105,.3); border-top-color: #059669; }
        @keyframes qrSpin { to { transform: rotate(360deg); } }

        /* Centered state cards (paid / expired / cancelled) */
        .qr-state { max-width: 520px; margin: 30px auto; text-align: center; }
        .qr-state-ic { width: 76px; height: 76px; border-radius: 50%; display: inline-flex; align-items: center; justify-content: center; margin-bottom: 16px; }
        .qr-state-ic.ok { background: rgba(16,185,129,0.12); color: #10b981; }
        .qr-state-ic.warn { background: #fef3c7; color: #d97706; }
        .qr-state-ic.bad { background: #fee2e2; color: #ef4444; }
        .qr-state h1 { font-size: 24px; font-weight: 800; margin: 0 0 8px; color: #0f172a; }
        .qr-state p { font-size: 15px; color: #475569; margin: 0 0 20px; line-height: 1.5; }
        .qr-detail { text-align: left; background: #f8fafc; border: 1.5px solid #e2e8f0; border-radius: 14px; padding: 16px 18px; margin: 0 0 20px; }

        /* Toast */
        .qr-toast { position: fixed; left: 50%; bottom: 30px; transform: translateX(-50%) translateY(16px); z-index: 3000;
            background: #0f172a; color: #fff; padding: 12px 22px; border-radius: 10px; font-size: 14px; font-weight: 700;
            opacity: 0; pointer-events: none; transition: opacity 180ms ease, transform 180ms ease; box-shadow: 0 8px 24px rgba(15,23,42,0.3); }
        .qr-toast.show { opacity: 1; transform: translateX(-50%) translateY(0); }

        /* Back modal */
        .qr-modal-overlay { position: fixed; inset: 0; z-index: 2500; background: rgba(15,23,42,0.7); display: none; align-items: center; justify-content: center; padding: 18px; }
        .qr-modal-overlay.show { display: flex; }
        .qr-modal { background: #fff; border-radius: 18px; padding: 24px; max-width: 420px; width: 100%; box-shadow: 0 20px 40px rgba(0,0,0,0.2); }
        .qr-modal h3 { font-size: 18px; font-weight: 800; margin: 0 0 10px; color: #0f172a; }
        .qr-modal p { font-size: 14px; color: #475569; margin: 0 0 20px; line-height: 1.55; }
        .qr-modal .qr-actions { margin-top: 0; }

        /* Success overlay shown when polling detects PAID on a WAITING page */
        .qr-success-overlay { position: fixed; inset: 0; z-index: 2600; background: rgba(248,250,252,.98); display: none; align-items: center; justify-content: center; padding: 18px; }
        .qr-success-overlay.show { display: flex; }
        @media (prefers-reduced-motion: reduce) { .qr-status.is-waiting .dot, .qr-btn .spinner { animation-duration: 2.4s; } }
    </style>
</head>
<body>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<div class="qr-header">
    <div class="qr-header-inner">
        <div class="qr-header-left">
            <button type="button" class="qr-back" id="qrBackBtn" aria-label="Quay lại">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m15 18-6-6 6-6"/></svg>
            </button>
            <h1 class="qr-title">Thanh toán đặt sân</h1>
        </div>
        <span class="qr-brand">V-<span>SPORT</span></span>
    </div>
</div>

<div class="qr-main-content">
    <div class="qr-shell">
        <c:choose>

            <%-- ============================ PAID ============================ --%>
            <c:when test="${state == 'PAID'}">
                <div class="qr-state">
                    <div class="qr-state-ic ok">
                        <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6 9 17l-5-5"/></svg>
                    </div>
                    <h1>Thanh toán thành công</h1>
                    <p>Sân của bạn đã được xác nhận.</p>
                    <div class="qr-detail">
                        <div class="qr-info-row"><span class="qr-info-k">Mã đặt sân</span><span class="qr-info-v">${fn:escapeXml(maDatSan)}</span></div>
                        <div class="qr-info-row"><span class="qr-info-k">Sân</span><span class="qr-info-v">${fn:escapeXml(tenCoSo)} · ${fn:escapeXml(tenSan)}</span></div>
                        <div class="qr-info-row"><span class="qr-info-k">Ngày</span><span class="qr-info-v">${ngayDat}</span></div>
                        <div class="qr-info-row"><span class="qr-info-k">Khung giờ</span><span class="qr-info-v">${gioBatDau} – ${gioKetThuc}</span></div>
                        <div class="qr-info-row"><span class="qr-info-k">Tổng tiền</span><span class="qr-info-v amount"><fmt:formatNumber value="${amount}" pattern="#,##0"/> đ</span></div>
                    </div>
                    <div class="qr-actions">
                        <a class="qr-btn qr-btn-primary" href="${ctx}/customer/dat-san?openHistory=true">Xem lịch đặt sân</a>
                        <a class="qr-btn qr-btn-ghost" href="${ctx}/index.jsp">Về trang chủ</a>
                    </div>
                    <p style="margin-top:16px; font-size:13.5px; color: #64748b;">Tự động chuyển đến lịch đặt sân sau <b id="qrPaidCountdown" style="color:#10b981;">3</b> giây…</p>
                </div>
            </c:when>

            <%-- ============================ EXPIRED ============================ --%>
            <c:when test="${state == 'EXPIRED'}">
                <div class="qr-state">
                    <div class="qr-state-ic warn">
                        <svg width="38" height="38" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></svg>
                    </div>
                    <h1>Mã QR đã hết hạn</h1>
                    <p>Khung giờ không còn được giữ. Bạn có thể kiểm tra lại hoặc chọn khung giờ khác.</p>
                    <div class="qr-actions">
                        <button type="button" class="qr-btn qr-btn-primary" id="qrRecheckBtn">Kiểm tra lại</button>
                        <a class="qr-btn qr-btn-secondary" href="${ctx}/customer/dat-lich-truc-quan">Chọn khung giờ khác</a>
                        <a class="qr-btn qr-btn-ghost" href="${ctx}/customer/dat-san?openHistory=true">Về lịch của tôi</a>
                    </div>
                </div>
            </c:when>

            <%-- ============================ CANCELLED ============================ --%>
            <c:when test="${state == 'CANCELLED'}">
                <div class="qr-state">
                    <div class="qr-state-ic bad">
                        <svg width="38" height="38" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="m15 9-6 6"/><path d="m9 9 6 6"/></svg>
                    </div>
                    <h1>Đơn đã được hủy</h1>
                    <p>Đơn đặt sân này đã bị hủy. Khung giờ đã được giải phóng.</p>
                    <div class="qr-actions">
                        <a class="qr-btn qr-btn-primary" href="${ctx}/customer/dat-lich-truc-quan">Đặt sân mới</a>
                        <a class="qr-btn qr-btn-ghost" href="${ctx}/customer/dat-san?openHistory=true">Về lịch của tôi</a>
                    </div>
                </div>
            </c:when>

            <%-- ============================ WAITING ============================ --%>
            <c:otherwise>
                <div class="qr-grid">
                    <%-- Left: QR --%>
                    <div class="qr-card qr-visual">
                        <div class="qr-status is-waiting" style="margin-bottom:16px;"><span class="dot"></span> Đang chờ thanh toán</div>
                        <c:choose>
                            <c:when test="${qrAvailable}">
                                <div class="qr-plate">
                                    <img src="${ctx}/customer/qr-image?datSanId=${datSanId}&size=520" width="260" height="260"
                                         alt="Mã QR chuyển khoản VietQR" />
                                </div>
                                <div class="qr-logo">V-<span>SPORT</span></div>
                                <div class="qr-countdown" id="qrCountdownWrap" hidden>QR còn hiệu lực <b id="qrCountdown">--:--</b></div>
                            </c:when>
                            <c:otherwise>
                                <div class="qr-plate" style="display:flex;align-items:center;justify-content:center;width:260px;height:260px;color:#94a3b8;font-size:14px;text-align:center;padding:24px;">
                                    Chưa có mã QR cho đơn này. Hãy tạo mã thanh toán.
                                </div>
                                <div class="qr-actions" style="margin-top:16px;width:100%;">
                                    <button type="button" class="qr-btn qr-btn-primary" id="qrCreateBtn">Tạo mã QR</button>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <%-- Right: transfer info + actions --%>
                    <div class="qr-card">
                        <h2>THÔNG TIN CHUYỂN KHOẢN</h2>
                        <c:if test="${not empty bankName}">
                            <div class="qr-info-row"><span class="qr-info-k">Ngân hàng</span><span class="qr-info-v">${fn:escapeXml(bankName)}</span></div>
                        </c:if>
                        <c:if test="${not empty accountName}">
                            <div class="qr-info-row"><span class="qr-info-k">Chủ tài khoản</span><span class="qr-info-v">${fn:escapeXml(accountName)}</span></div>
                        </c:if>
                        <div class="qr-info-row">
                            <span class="qr-info-k">Số tài khoản</span>
                            <span class="qr-info-v"><c:out value="${empty accountNumber ? '—' : accountNumber}"/>
                                <c:if test="${not empty accountNumber}"><button type="button" class="qr-copy" data-copy="${fn:escapeXml(accountNumber)}">Sao chép</button></c:if>
                            </span>
                        </div>
                        <div class="qr-info-row">
                            <span class="qr-info-k">Số tiền</span>
                            <span class="qr-info-v amount"><fmt:formatNumber value="${amount}" pattern="#,##0"/> đ
                                <button type="button" class="qr-copy" data-copy="${amount}">Sao chép</button>
                            </span>
                        </div>
                        <div class="qr-info-row">
                            <span class="qr-info-k">Nội dung</span>
                            <span class="qr-info-v"><c:out value="${transferContent}"/>
                                <button type="button" class="qr-copy" data-copy="${fn:escapeXml(transferContent)}">Sao chép</button>
                            </span>
                        </div>
                        <div class="qr-info-row"><span class="qr-info-k">Mã đặt sân</span><span class="qr-info-v">${fn:escapeXml(maDatSan)}</span></div>

                        <div class="qr-summary">
                            <div class="qr-info-row"><span class="qr-info-k">Sân</span><span class="qr-info-v">${fn:escapeXml(tenCoSo)} · ${fn:escapeXml(tenSan)}</span></div>
                            <div class="qr-info-row"><span class="qr-info-k">Ngày · giờ</span><span class="qr-info-v">${ngayDat} · ${gioBatDau}–${gioKetThuc}</span></div>
                        </div>

                        <h2 style="margin-top:20px;">HƯỚNG DẪN</h2>
                        <ol class="qr-steps">
                            <li>Mở ứng dụng ngân hàng và quét mã QR.</li>
                            <li>Giữ nguyên số tiền và nội dung chuyển khoản.</li>
                            <li>Chờ hệ thống xác nhận tự động — không cần đóng trang.</li>
                        </ol>

                        <div class="qr-actions" style="margin-top:20px;">
                            <button type="button" class="qr-btn qr-btn-primary" id="qrCheckBtn">
                                <span id="qrCheckLabel">Tôi đã chuyển khoản — Kiểm tra</span>
                            </button>
                            <a class="qr-btn qr-btn-ghost" href="${ctx}/customer/dat-san?openHistory=true">Thanh toán sau</a>
                            <button type="button" class="qr-btn qr-btn-danger-ghost" id="qrCancelBtn">Hủy thanh toán</button>
                        </div>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<%-- Back modal --%>
<div class="qr-modal-overlay" id="qrBackModal" role="dialog" aria-modal="true" aria-labelledby="qrBackModalTitle">
    <div class="qr-modal">
        <h3 id="qrBackModalTitle">Bạn muốn làm gì với đơn đang chờ thanh toán?</h3>
        <p id="qrBackModalMsg">Khung giờ vẫn đang được giữ. Bạn có thể quay lại thanh toán trước khi hết thời gian.</p>
        <div class="qr-actions">
            <a class="qr-btn qr-btn-secondary" href="${ctx}/customer/dat-san?openHistory=true">Thanh toán sau</a>
            <button type="button" class="qr-btn qr-btn-danger-ghost" id="qrModalCancelBtn">Hủy thanh toán</button>
            <button type="button" class="qr-btn qr-btn-ghost" id="qrModalCloseBtn">Tiếp tục thanh toán</button>
        </div>
    </div>
</div>

<%-- Success overlay (shown when polling detects PAID) --%>
<div class="qr-success-overlay" id="qrSuccessOverlay" role="status" aria-live="polite">
    <div class="qr-state">
        <div class="qr-state-ic ok">
            <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6 9 17l-5-5"/></svg>
        </div>
        <h1>Thanh toán thành công</h1>
        <p>Sân của bạn đã được xác nhận. Đang chuyển đến lịch đặt sân…</p>
    </div>
</div>

<div class="qr-toast" id="qrToast" role="status" aria-live="polite">Đã sao chép</div>

<script>
(function () {
    var CTX = '${ctx}';
    var DATSAN_ID = ${datSanId};
    var STATE = '${state}';
    var EXPIRES_AT = ${empty expiresAtEpochMs ? 'null' : expiresAtEpochMs};

    // ---------- Toast ----------
    var toastEl = document.getElementById('qrToast');
    var toastTimer = null;
    function toast(msg) {
        toastEl.textContent = msg;
        toastEl.classList.add('show');
        clearTimeout(toastTimer);
        toastTimer = setTimeout(function () { toastEl.classList.remove('show'); }, 1800);
    }

    // ---------- Copy buttons ----------
    document.querySelectorAll('.qr-copy').forEach(function (btn) {
        btn.addEventListener('click', function () {
            var val = String(btn.getAttribute('data-copy') || '');
            function done() { toast('Đã sao chép'); }
            if (navigator.clipboard && navigator.clipboard.writeText) {
                navigator.clipboard.writeText(val).then(done, function () { fallbackCopy(val); done(); });
            } else { fallbackCopy(val); done(); }
        });
    });
    function fallbackCopy(text) {
        var ta = document.createElement('textarea');
        ta.value = text; ta.style.position = 'fixed'; ta.style.opacity = '0';
        document.body.appendChild(ta); ta.focus(); ta.select();
        try { document.execCommand('copy'); } catch (e) {}
        document.body.removeChild(ta);
    }

    // ---------- Countdown ----------
    var cdEl = document.getElementById('qrCountdown');
    var cdWrap = document.getElementById('qrCountdownWrap');
    var expired = false;
    function pad(n) { return (n < 10 ? '0' : '') + n; }
    function tickCountdown() {
        if (EXPIRES_AT == null || !cdEl) return;
        var remain = Math.floor((EXPIRES_AT - Date.now()) / 1000);
        if (remain <= 0) {
            cdEl.textContent = '00:00';
            if (!expired) { expired = true; onExpired(); }
            return;
        }
        var m = Math.floor(remain / 60), s = remain % 60;
        cdEl.textContent = pad(m) + ':' + pad(s);
        if (cdWrap) cdWrap.hidden = false;
    }
    function onExpired() {
        stopPolling();
        checkStatusOnce(function (data) {
            if (data && data.status === 'paid') { showSuccess(data); return; }
            window.location.reload();
        });
    }

    // ---------- Status polling ----------
    var pollTimer = null;
    function startPolling() {
        if (STATE !== 'WAITING') return;
        pollTimer = setInterval(function () {
            checkStatusOnce(function (data) { handleStatus(data, false); });
        }, 4000);
    }
    function stopPolling() { if (pollTimer) { clearInterval(pollTimer); pollTimer = null; } }
    function checkStatusOnce(cb) {
        fetch(CTX + '/customer/payos-status?datSanId=' + DATSAN_ID, { headers: { 'X-Requested-With': 'XMLHttpRequest' } })
            .then(function (r) { return r.json(); })
            .then(function (d) { cb(d); })
            .catch(function () { cb(null); });
    }
    function handleStatus(data, manual) {
        if (!data) { if (manual) toast('Chưa kiểm tra được. Vui lòng thử lại.'); return; }
        if (data.status === 'paid') { stopPolling(); showSuccess(data); return; }
        if (data.status === 'cancelled') { stopPolling(); window.location.reload(); return; }
        if (data.status === 'expired') { stopPolling(); window.location.reload(); return; }
        if (manual) toast('Chưa nhận được thanh toán. Vui lòng đợi giây lát.');
    }
    function showSuccess(data) {
        document.getElementById('qrSuccessOverlay').classList.add('show');
        var url = (data && data.redirectUrl) ? data.redirectUrl : (CTX + '/customer/dat-san?openHistory=true');
        setTimeout(function () { window.location.href = url; }, 3000);
    }

    // ---------- Manual "Tôi đã chuyển khoản — Kiểm tra" ----------
    var checkBtn = document.getElementById('qrCheckBtn');
    var checkLabel = document.getElementById('qrCheckLabel');
    var lastCheck = 0;
    if (checkBtn) {
        checkBtn.addEventListener('click', function () {
            var now = Date.now();
            if (now - lastCheck < 3000) { toast('Vui lòng đợi vài giây rồi thử lại.'); return; }
            lastCheck = now;
            checkBtn.disabled = true;
            checkLabel.innerHTML = '<span class="spinner" aria-hidden="true"></span> Đang kiểm tra…';
            checkStatusOnce(function (data) {
                checkBtn.disabled = false;
                checkLabel.textContent = 'Tôi đã chuyển khoản — Kiểm tra';
                handleStatus(data, true);
            });
        });
    }

    var recheckBtn = document.getElementById('qrRecheckBtn');
    if (recheckBtn) {
        recheckBtn.addEventListener('click', function () {
            recheckBtn.disabled = true;
            checkStatusOnce(function (data) {
                if (data && data.status === 'paid') { showSuccess(data); return; }
                window.location.reload();
            });
        });
    }

    // ---------- Create / regenerate QR ----------
    var createBtn = document.getElementById('qrCreateBtn');
    if (createBtn) {
        createBtn.addEventListener('click', function () {
            createBtn.disabled = true;
            createBtn.innerHTML = '<span class="spinner" aria-hidden="true"></span> Đang tạo mã…';
            postForm(CTX + '/customer/payos-retry', { datSanId: DATSAN_ID }, function (data) {
                if (data && data.success && data.redirectUrl) { window.location.href = data.redirectUrl; return; }
                createBtn.disabled = false;
                createBtn.textContent = 'Tạo mã QR';
                toast((data && data.message) ? data.message : 'Chưa thể tạo mã. Vui lòng thử lại.');
            });
        });
    }

    // ---------- Cancel ----------
    var cancelBtns = [document.getElementById('qrCancelBtn'), document.getElementById('qrModalCancelBtn')];
    function doCancel() {
        window.location.href = CTX + '/customer/payos-cancel?datSanId=' + DATSAN_ID;
    }
    cancelBtns.forEach(function (b) { if (b) b.addEventListener('click', doCancel); });

    // ---------- Back modal ----------
    var backModal = document.getElementById('qrBackModal');
    var backBtn = document.getElementById('qrBackBtn');
    function openBackModal() { if (backModal) backModal.classList.add('show'); }
    function closeBackModal() { if (backModal) backModal.classList.remove('show'); }
    if (backBtn) {
        backBtn.addEventListener('click', function () {
            if (STATE === 'WAITING') openBackModal();
            else window.location.href = CTX + '/customer/dat-san?openHistory=true';
        });
    }
    var modalClose = document.getElementById('qrModalCloseBtn');
    if (modalClose) modalClose.addEventListener('click', closeBackModal);
    if (backModal) backModal.addEventListener('click', function (e) { if (e.target === backModal) closeBackModal(); });
    document.addEventListener('keydown', function (e) { if (e.key === 'Escape') closeBackModal(); });

    if (STATE === 'WAITING') {
        history.pushState({ qr: true }, '', location.href);
        window.addEventListener('popstate', function () {
            history.pushState({ qr: true }, '', location.href);
            openBackModal();
        });
    }

    // ---------- Paid page auto-redirect ----------
    var paidCd = document.getElementById('qrPaidCountdown');
    if (STATE === 'PAID' && paidCd) {
        var n = 3;
        var t = setInterval(function () {
            n -= 1; paidCd.textContent = n;
            if (n <= 0) { clearInterval(t); window.location.href = CTX + '/customer/dat-san?openHistory=true'; }
        }, 1000);
    }

    // ---------- Lifecycle ----------
    if (STATE === 'WAITING') {
        tickCountdown();
        setInterval(tickCountdown, 1000);
        startPolling();
        document.addEventListener('visibilitychange', function () {
            if (document.hidden) stopPolling();
            else if (!expired) { checkStatusOnce(function (d) { handleStatus(d, false); }); startPolling(); }
        });
        window.addEventListener('pagehide', stopPolling);
    }

    function postForm(url, params, cb) {
        var body = Object.keys(params).map(function (k) { return encodeURIComponent(k) + '=' + encodeURIComponent(params[k]); }).join('&');
        fetch(url, { method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded', 'X-Requested-With': 'XMLHttpRequest' }, body: body })
            .then(function (r) { return r.json(); }).then(cb).catch(function () { cb(null); });
    }
})();
</script>

<jsp:include page="/common/footer.jsp" />
</body>
</html>
