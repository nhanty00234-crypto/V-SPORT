<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%--
    Focused booking flow — bước "Xác nhận đặt sân".
    Redesign: Tối ưu kích thước chữ, khoảng cách và bố cục 2 cột rộng rãi (1240px max-width).
    Đảm bảo trên màn hình 1366x768 hiển thị trọn vẹn thông tin và nút Xác Nhận Đặt Sân không cần cuộn.
--%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Xác nhận đặt sân - V-SPORT</title>
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

        .xn-main-content {
            flex: 1 0 auto;
        }

        /* Header */
        .xn-header {
            position: sticky; top: 0; z-index: 40;
            background: #0f172a; color: #fff;
            box-shadow: 0 2px 10px rgba(0,0,0,0.15);
        }
        .xn-header-inner {
            display: flex; align-items: center; justify-content: space-between; gap: 14px;
            padding: 12px 24px; min-height: 56px; max-width: 1240px; margin: 0 auto;
        }
        .xn-header-left { display: flex; align-items: center; gap: 14px; min-width: 0; }
        .xn-back {
            width: 38px; height: 38px; flex-shrink: 0;
            display: inline-flex; align-items: center; justify-content: center;
            border-radius: 50%; background: rgba(255,255,255,.12); color: #fff; border: none; cursor: pointer;
            transition: all 120ms ease; text-decoration: none;
        }
        .xn-back:hover { background: rgba(255,255,255,.22); }
        .xn-title { font-size: 20px; font-weight: 800; margin: 0; color: #fff; white-space: nowrap; }
        .xn-progress { font-size: 14px; color: #94a3b8; font-weight: 600; }
        .xn-progress b { color: #10b981; font-weight: 800; }

        /* Main Shell */
        .xn-shell {
            width: calc(100% - 48px);
            max-width: 1240px;
            margin: 24px auto 40px;
            box-sizing: border-box;
        }

        @media (min-width: 960px) {
            .xn-shell {
                display: grid;
                grid-template-columns: minmax(0, 1.15fr) minmax(380px, 0.85fr);
                gap: 24px;
                align-items: start;
            }
        }

        .xn-col-left, .xn-col-right {
            display: flex;
            flex-direction: column;
            gap: 18px;
        }

        /* Card Base */
        .xn-card {
            background: #ffffff;
            border: 1.5px solid #e2e8f0;
            border-radius: 16px;
            padding: 20px;
            box-shadow: 0 2px 6px rgba(15,23,42,0.03);
        }
        .xn-card h2 {
            font-size: 15px; font-weight: 800; color: #1e293b;
            text-transform: uppercase; letter-spacing: .04em; margin: 0 0 14px;
            display: flex; align-items: center; gap: 8px;
        }
        .xn-card h2 svg { color: #10b981; width: 18px; height: 18px; flex-shrink: 0; }

        /* Facility Header & Info */
        .xn-facility-header { display: flex; align-items: flex-start; justify-content: space-between; gap: 12px; }
        .xn-facility-name { font-size: 22px; font-weight: 800; color: #0f172a; line-height: 1.3; }
        .xn-facility-addr { font-size: 14px; color: #475569; font-weight: 500; margin-top: 5px; display: flex; align-items: center; gap: 6px; }
        .xn-facility-addr svg { flex-shrink: 0; color: #10b981; width: 15px; height: 15px; }
        .xn-chip-row { display: flex; flex-wrap: wrap; gap: 8px; margin-top: 12px; }
        .xn-chip {
            display: inline-flex; align-items: center; padding: 5px 13px; border-radius: 999px;
            background: rgba(16,185,129,0.12); color: #047857; font-size: 13px; font-weight: 800;
        }

        /* Schedule Grid */
        .xn-schedule-box {
            background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 12px;
            padding: 14px 16px; margin-top: 16px;
            display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px;
        }
        .xn-sched-item .lbl { font-size: 12px; font-weight: 700; color: #64748b; text-transform: uppercase; letter-spacing: .03em; }
        .xn-sched-item .val { font-size: 16px; font-weight: 800; color: #0f172a; margin-top: 3px; }

        /* Price Breakdown */
        .xn-price-breakdown { margin-top: 16px; padding-top: 14px; border-top: 1px dashed #cbd5e1; }
        .xn-row { display: flex; justify-content: space-between; gap: 12px; padding: 5px 0; font-size: 14.5px; }
        .xn-row .k { color: #475569; font-weight: 500; }
        .xn-row .v { font-weight: 700; text-align: right; white-space: nowrap; color: #0f172a; }
        .xn-row.total {
            display: flex; align-items: center; justify-content: space-between;
            border-top: 2px solid #e2e8f0; margin-top: 10px; padding-top: 12px; gap: 12px;
        }
        .xn-row.total .k { font-weight: 800; color: #0f172a; font-size: 17px; }
        .xn-row.total .v { font-weight: 800; font-size: 28px; color: #059669; letter-spacing: -.01em; }

        /* Promo Code Form */
        .xn-promo-row { display: flex; gap: 10px; }
        .xn-input {
            width: 100%; height: 46px; padding: 0 14px;
            background: #fff; border: 1.5px solid #cbd5e1; border-radius: 10px;
            font-size: 14.5px; color: #0f172a; font-family: inherit; font-weight: 600;
            box-sizing: border-box; transition: border-color 120ms ease;
        }
        .xn-input:focus { outline: none; border-color: #10b981; box-shadow: 0 0 0 3px rgba(16,185,129,0.2); }
        .xn-input[readonly] { background: #f8fafc; color: #475569; font-weight: 700; }
        .xn-promo-row .xn-input { flex: 1; text-transform: uppercase; font-weight: 700; letter-spacing: .02em; }
        .xn-promo-apply-btn {
            flex-shrink: 0; height: 46px; padding: 0 22px; border-radius: 10px; border: none;
            background: #10b981; color: #fff; font-weight: 800; font-size: 14.5px;
            cursor: pointer; white-space: nowrap; transition: background 120ms ease;
        }
        .xn-promo-apply-btn:hover:not(:disabled) { background: #059669; }
        .xn-promo-apply-btn:disabled { opacity: .6; cursor: not-allowed; }
        .xn-promo-applied {
            display: flex; align-items: center; justify-content: space-between; gap: 10px;
            background: rgba(16,185,129,0.08); border: 1.5px solid rgba(16,185,129,0.35);
            border-radius: 10px; padding: 12px 14px;
        }
        .xn-promo-applied-code { font-size: 15px; font-weight: 800; color: #0f172a; margin: 0; }
        .xn-promo-applied-desc { font-size: 13px; color: #475569; margin-top: 2px; }
        .xn-promo-remove-btn {
            padding: 6px 12px; border-radius: 8px; border: 1px solid #cbd5e1;
            background: #fff; color: #ef4444; font-weight: 700; font-size: 13px; cursor: pointer;
        }
        .xn-promo-remove-btn:hover { background: #fef2f2; }
        .xn-promo-loading { font-size: 13px; color: #64748b; font-weight: 600; margin-top: 8px; display: flex; align-items: center; gap: 7px; }
        .xn-promo-loading .spinner { width: 14px; height: 14px; border: 2px solid #cbd5e1; border-top-color: #10b981; border-radius: 50%; animation: xnSpin .8s linear infinite; }
        .xn-promo-error { font-size: 13px; color: #dc2626; font-weight: 700; margin: 8px 0 0; }

        /* User Info Grid */
        .xn-user-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
        .xn-field { display: flex; flex-direction: column; gap: 5px; }
        .xn-field label { font-size: 12.5px; font-weight: 700; color: #475569; text-transform: uppercase; letter-spacing: .02em; }
        .xn-field-full { grid-column: span 2; }
        .xn-textarea {
            width: 100%; min-height: 52px; height: 52px; padding: 10px 14px;
            border-radius: 10px; border: 1.5px solid #cbd5e1; background: #fff;
            font-size: 14px; font-family: inherit; resize: vertical; color: #0f172a;
            box-sizing: border-box;
        }
        .xn-textarea:focus { outline: none; border-color: #10b981; box-shadow: 0 0 0 3px rgba(16,185,129,0.2); }

        /* Payment Options */
        .xn-pay-options { display: flex; flex-direction: column; gap: 10px; }
        .xn-pay-card {
            display: flex; align-items: flex-start; gap: 12px; padding: 14px 16px;
            background: #fff; border: 1.5px solid #e2e8f0; border-radius: 12px;
            cursor: pointer; transition: all 120ms ease;
        }
        .xn-pay-card:hover { border-color: #10b981; }
        .xn-pay-card.is-selected { border-color: #10b981; background: rgba(16,185,129,0.05); }
        .xn-pay-card input { margin-top: 3px; accent-color: #10b981; width: 18px; height: 18px; }
        .xn-pay-name { font-size: 15px; font-weight: 800; color: #0f172a; }
        .xn-pay-desc { font-size: 13px; color: #475569; margin-top: 3px; line-height: 1.4; }

        /* Notes List */
        .xn-notes { font-size: 12.5px; color: #64748b; line-height: 1.5; margin: 0; padding-left: 18px; }
        .xn-notes li { margin: 2px 0; }

        /* CTA Submit Button */
        .xn-submit-box { margin-top: 14px; }
        .xn-cta-btn {
            width: 100%; height: 52px; border-radius: 12px; border: none;
            background: #10b981; color: #fff; font-weight: 800; font-size: 16px;
            letter-spacing: .03em; text-transform: uppercase; cursor: pointer;
            display: flex; align-items: center; justify-content: center; gap: 8px;
            box-shadow: 0 4px 14px rgba(16,185,129,0.35);
            transition: all 150ms ease;
        }
        .xn-cta-btn:hover:not(:disabled) { background: #059669; transform: translateY(-1px); box-shadow: 0 6px 18px rgba(16,185,129,0.45); }
        .xn-cta-btn:active:not(:disabled) { transform: translateY(1px); }
        .xn-cta-btn:disabled { background: #94a3b8; cursor: not-allowed; box-shadow: none; }
        .xn-cta-btn .spinner {
            width: 18px; height: 18px; border-radius: 50%;
            border: 2.5px solid rgba(255,255,255,.35); border-top-color: #fff;
            animation: xnSpin .8s linear infinite;
        }

        /* Mobile Sticky CTA Bar (hidden on desktop >=960px) */
        .xn-ctabar { display: none; }
        @media (max-width: 959px) {
            body { padding-bottom: 84px !important; }
            .xn-shell { width: calc(100% - 32px); margin-top: 16px; }
            .xn-ctabar {
                display: block; position: fixed; left: 0; right: 0; bottom: 0; z-index: 40;
                background: #0f172a; padding: 12px 16px calc(12px + env(safe-area-inset-bottom, 0px));
                box-shadow: 0 -10px 30px rgba(0,0,0,0.25);
            }
            .xn-ctabar-inner { max-width: 860px; margin: 0 auto; display: flex; align-items: center; gap: 14px; }
            .xn-ctabar-total { color: #fff; }
            .xn-ctabar-total .lbl { font-size: 11px; color: #94a3b8; font-weight: 700; text-transform: uppercase; }
            .xn-ctabar-total .val { font-size: 20px; font-weight: 800; color: #fff; }
            .xn-submit-box { display: none; }
            .xn-user-grid { grid-template-columns: 1fr; }
            .xn-field-full { grid-column: span 1; }
        }

        /* Full-screen step loading */
        .xn-step-loading {
            position: fixed; inset: 0; z-index: 2000;
            background: #0f172a;
            display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 18px; color: #fff;
        }
        .xn-step-loading-brand { font-size: 28px; font-weight: 800; letter-spacing: .12em; font-family: 'Outfit', sans-serif; }
        .xn-step-loading-brand span { color: #10b981; }
        .xn-step-loading-ring {
            width: 46px; height: 46px; border-radius: 50%;
            border: 4px solid rgba(255,255,255,.16); border-top-color: #10b981;
            animation: xnSpin .9s linear infinite;
        }
        .xn-step-loading p { font-size: 16px; font-weight: 600; color: #cbd5e1; margin: 0; }
        @keyframes xnSpin { to { transform: rotate(360deg); } }
    </style>
</head>
<body>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<div class="xn-header">
    <div class="xn-header-inner">
        <div class="xn-header-left">
            <a class="xn-back" href="${backUrl}" aria-label="Quay lại chọn lịch">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m15 18-6-6 6-6"/></svg>
            </a>
            <h1 class="xn-title">Xác nhận đặt sân</h1>
        </div>
        <span class="xn-progress">Chọn lịch → <b>Xác nhận</b> → Thanh toán</span>
    </div>
</div>

<div class="xn-main-content">
    <div class="xn-shell">
        <%-- CỘT TRÁI: Sân, Lịch & Mã khuyến mãi --%>
        <div class="xn-col-left">
            <%-- Sân & Lịch đặt hợp nhất --%>
            <div class="xn-card">
                <div class="xn-facility-header">
                    <div>
                        <div class="xn-facility-name">${fn:escapeXml(coSo.tenCoSo)}</div>
                        <c:if test="${not empty coSo.diaChi}">
                            <div class="xn-facility-addr">
                                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 10c0 4.993-5.539 10.193-7.399 11.799a1 1 0 0 1-1.202 0C9.539 20.193 4 14.993 4 10a8 8 0 0 1 16 0"/><circle cx="12" cy="10" r="3"/></svg>
                                <span>${fn:escapeXml(coSo.diaChi)}</span>
                            </div>
                        </c:if>
                    </div>
                </div>
                <div class="xn-chip-row">
                    <span class="xn-chip">${fn:escapeXml(san.tenSan)}</span>
                    <c:if test="${not empty loai.tenLoai}"><span class="xn-chip">${fn:escapeXml(loai.tenLoai)}</span></c:if>
                    <c:if test="${not empty tenMon}"><span class="xn-chip">${fn:escapeXml(tenMon)}</span></c:if>
                </div>

                <div class="xn-schedule-box">
                    <div class="xn-sched-item">
                        <div class="lbl">Ngày</div>
                        <div class="val">${ngayDat}</div>
                    </div>
                    <div class="xn-sched-item">
                        <div class="lbl">Khung giờ</div>
                        <div class="val">${gioBatDau} – ${gioKetThuc}</div>
                    </div>
                    <div class="xn-sched-item">
                        <div class="lbl">Thời lượng</div>
                        <div class="val">
                            <c:set var="durH" value="${durationMinutes div 60}" />
                            <c:set var="durM" value="${durationMinutes mod 60}" />
                            <c:if test="${durH gt 0}"><fmt:formatNumber value="${durH}" maxFractionDigits="0"/> giờ</c:if>
                            <c:if test="${durM gt 0}"> ${durM} phút</c:if>
                        </div>
                    </div>
                </div>

                <div class="xn-price-breakdown">
                    <c:forEach var="seg" items="${priceSegments}">
                        <div class="xn-row">
                            <span class="k">${seg.start} – ${seg.end} · ${seg.withLight ? 'Giá có đèn' : 'Giá không đèn'}
                                (<fmt:formatNumber value="${seg.hourlyRate}" pattern="#,##0"/> đ/giờ)</span>
                            <span class="v"><fmt:formatNumber value="${seg.amount}" pattern="#,##0"/> đ</span>
                        </div>
                    </c:forEach>
                    <div class="xn-row" id="xnPromoRow" hidden>
                        <span class="k" id="xnPromoRowLabel">Khuyến mãi</span>
                        <span class="v" style="color: #059669;" id="xnPromoRowValue">-0 đ</span>
                    </div>
                    <div class="xn-row total">
                        <span class="k">Tổng thanh toán</span>
                        <span class="v" id="xnTotalValue"><fmt:formatNumber value="${totalAmount}" pattern="#,##0"/> đ</span>
                    </div>
                </div>
            </div>

            <%-- Mã khuyến mãi --%>
            <div class="xn-card">
                <h2>
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 12v10H4V12"/><path d="M2 7h20v5H2z"/><path d="M12 22V7"/><path d="M12 7H7.5a2.5 2.5 0 0 1 0-5C11 2 12 7 12 7z"/><path d="M12 7h4.5a2.5 2.5 0 0 0 0-5C13 2 12 7 12 7z"/></svg>
                    Mã khuyến mãi
                </h2>

                <div id="xnPromoIdleState">
                    <div class="xn-promo-row">
                        <input class="xn-input" id="xnPromoInput" type="text" placeholder="Nhập mã (VD: VSPORT20)"
                               autocomplete="off" aria-describedby="xnPromoError" />
                        <button type="button" class="xn-promo-apply-btn" id="xnPromoApplyBtn">Áp dụng</button>
                    </div>
                </div>

                <div id="xnPromoAppliedState" class="xn-promo-applied" hidden>
                    <div>
                        <p class="xn-promo-applied-code"><span id="xnPromoAppliedCode"></span> đã áp dụng</p>
                        <p class="xn-promo-applied-desc" id="xnPromoAppliedDesc"></p>
                    </div>
                    <button type="button" class="xn-promo-remove-btn" id="xnPromoRemoveBtn">Bỏ mã</button>
                </div>

                <p id="xnPromoLoading" class="xn-promo-loading" hidden aria-live="polite">
                    <span class="spinner" aria-hidden="true"></span>
                    Đang kiểm tra mã...
                </p>
                <p id="xnPromoError" class="xn-promo-error" role="alert" aria-live="polite" hidden></p>
            </div>
        </div>

        <%-- CỘT PHẢI: Người đặt, Thanh toán & Submit Form --%>
        <div class="xn-col-right">
            <form id="xnForm" action="${ctx}/customer/dat-san" method="post">
                <input type="hidden" name="sanId" value="${san.sanID}" />
                <input type="hidden" name="ngayDat" value="${ngayDat}" />
                <input type="hidden" name="gioBatDau" value="${gioBatDau}" />
                <input type="hidden" name="gioKetThuc" value="${gioKetThuc}" />
                <input type="hidden" name="paymentMethod" id="xnPaymentMethod" value="sau" />
                <input type="hidden" name="promoCode" id="xnPromoCodeHidden" value="" />
                <input type="hidden" name="khuyenMaiId" id="xnKhuyenMaiIdHidden" value="" />

                <%-- Thông tin người đặt --%>
                <div class="xn-card">
                    <h2>
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="8" r="4"/><path d="M20 21a8 8 0 0 0-16 0"/></svg>
                        Thông tin người đặt
                    </h2>
                    <div class="xn-user-grid">
                        <div class="xn-field">
                            <label for="xnName">Họ tên</label>
                            <input class="xn-input" id="xnName" type="text" readonly
                                   value="${fn:escapeXml(not empty sessionScope.user.fullName ? sessionScope.user.fullName : sessionScope.user.username)}" />
                        </div>
                        <c:if test="${not empty sessionScope.user.phoneNumber}">
                            <div class="xn-field">
                                <label for="xnPhone">Số điện thoại</label>
                                <input class="xn-input" id="xnPhone" type="text" readonly value="${fn:escapeXml(sessionScope.user.phoneNumber)}" />
                            </div>
                        </c:if>
                        <div class="xn-field xn-field-full">
                            <label for="xnGhiChu">Ghi chú cho chủ sân</label>
                            <textarea class="xn-textarea" id="xnGhiChu" name="ghiChu" maxlength="255" placeholder="Nhập ghi chú (không bắt buộc)"></textarea>
                        </div>
                    </div>
                </div>

                <%-- Phương thức thanh toán --%>
                <div class="xn-card">
                    <h2>
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect width="20" height="14" x="2" y="5" rx="2"/><line x1="2" x2="22" y1="10" y2="10"/></svg>
                        Phương thức thanh toán
                    </h2>
                    <div class="xn-pay-options" role="radiogroup" aria-label="Phương thức thanh toán">
                        <label class="xn-pay-card" id="xnPayCardPayos">
                            <input type="radio" name="payChoice" value="payos" />
                            <span>
                                <span class="xn-pay-name">Thanh toán trả trước</span>
                                <span class="xn-pay-desc" style="display:block;">Quét QR PayOS ngay. Giữ chỗ ${bookingHoldMinutes} phút để hoàn tất.</span>
                            </span>
                        </label>
                        <label class="xn-pay-card is-selected" id="xnPayCardSau">
                            <input type="radio" name="payChoice" value="sau" checked />
                            <span>
                                <span class="xn-pay-name">Thanh toán tại sân</span>
                                <span class="xn-pay-desc" style="display:block;">Thanh toán trực tiếp tại cơ sở. Đơn cần cơ sở xác nhận.</span>
                            </span>
                        </label>
                    </div>
                    <div style="margin-top: 12px; padding-top: 10px; border-top: 1px solid #f1f5f9;">
                        <ul class="xn-notes">
                            <li>Hủy miễn phí khi hủy trước giờ chơi ít nhất ${lateCancelHours} tiếng.</li>
                            <li>Trả trước qua PayOS: giữ chỗ ${bookingHoldMinutes} phút chờ thanh toán.</li>
                        </ul>
                    </div>

                    <div class="xn-submit-box">
                        <button type="submit" class="xn-cta-btn" id="xnSubmitBtn">
                            <span id="xnSubmitLabel">Xác nhận đặt sân</span>
                        </button>
                    </div>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="/common/footer.jsp" />

<%-- Mobile Sticky CTA Bar (hidden on desktop) --%>
<div class="xn-ctabar">
    <div class="xn-ctabar-inner">
        <div class="xn-ctabar-total">
            <div class="lbl">Tổng thanh toán</div>
            <div class="val"><fmt:formatNumber value="${totalAmount}" pattern="#,##0"/> đ</div>
        </div>
        <button type="submit" form="xnForm" class="xn-cta-btn" style="flex:1;">
            <span>Xác nhận đặt sân</span>
        </button>
    </div>
</div>

<div class="xn-step-loading" id="xnStepLoading" hidden role="status" aria-live="polite" aria-busy="true">
    <div class="xn-step-loading-brand">V-<span>SPORT</span></div>
    <div class="xn-step-loading-ring" aria-hidden="true"></div>
    <p id="xnStepLoadingText">Đang xử lý...</p>
</div>

<script>
(function () {
    const form = document.getElementById('xnForm');
    const hiddenMethod = document.getElementById('xnPaymentMethod');
    const btn = document.getElementById('xnSubmitBtn');
    const label = document.getElementById('xnSubmitLabel');
    const cardPayos = document.getElementById('xnPayCardPayos');
    const cardSau = document.getElementById('xnPayCardSau');
    let submitting = false;

    function syncMethod() {
        const chosen = document.querySelector('input[name="payChoice"]:checked');
        const val = chosen ? chosen.value : 'sau';
        hiddenMethod.value = val;
        cardPayos.classList.toggle('is-selected', val === 'payos');
        cardSau.classList.toggle('is-selected', val === 'sau');
        label.textContent = val === 'payos' ? 'Thanh toán & đặt sân' : 'Xác nhận đặt sân';
    }
    document.querySelectorAll('input[name="payChoice"]').forEach(function (r) {
        r.addEventListener('change', syncMethod);
    });
    syncMethod();

    let loadingTimer = null;
    function showStepLoading(text) {
        clearTimeout(loadingTimer);
        loadingTimer = setTimeout(function () {
            document.getElementById('xnStepLoadingText').textContent = text;
            document.getElementById('xnStepLoading').hidden = false;
        }, 150);
    }
    window.addEventListener('pageshow', function (e) {
        if (e.persisted) {
            clearTimeout(loadingTimer);
            document.getElementById('xnStepLoading').hidden = true;
            submitting = false;
            btn.disabled = false;
            syncMethod();
        }
    });

    // ── Mã khuyến mãi ──────────────────────────────────────────────
    (function () {
        var ORIGINAL_AMOUNT = ${totalAmount};
        var CO_SO_ID = ${coSo.coSoID};
        var BOOKING_DATE = '${ngayDat}';

        var idleState = document.getElementById('xnPromoIdleState');
        var appliedState = document.getElementById('xnPromoAppliedState');
        var input = document.getElementById('xnPromoInput');
        var applyBtn = document.getElementById('xnPromoApplyBtn');
        var removeBtn = document.getElementById('xnPromoRemoveBtn');
        var loadingEl = document.getElementById('xnPromoLoading');
        var errorEl = document.getElementById('xnPromoError');
        var appliedCodeEl = document.getElementById('xnPromoAppliedCode');
        var appliedDescEl = document.getElementById('xnPromoAppliedDesc');
        var promoRow = document.getElementById('xnPromoRow');
        var promoRowLabel = document.getElementById('xnPromoRowLabel');
        var promoRowValue = document.getElementById('xnPromoRowValue');
        var totalValueEl = document.getElementById('xnTotalValue');
        var promoCodeHidden = document.getElementById('xnPromoCodeHidden');
        var khuyenMaiIdHidden = document.getElementById('xnKhuyenMaiIdHidden');

        var requestSeq = 0;

        function formatVnd(n) {
            return Math.round(n).toLocaleString('vi-VN') + ' đ';
        }

        function setError(msg) {
            if (msg) {
                errorEl.textContent = msg;
                errorEl.hidden = false;
                input.setAttribute('aria-invalid', 'true');
            } else {
                errorEl.hidden = true;
                errorEl.textContent = '';
                input.removeAttribute('aria-invalid');
            }
        }

        function resetToIdle() {
            idleState.hidden = false;
            appliedState.hidden = true;
            promoRow.hidden = true;
            totalValueEl.textContent = formatVnd(ORIGINAL_AMOUNT);
            promoCodeHidden.value = '';
            khuyenMaiIdHidden.value = '';
        }

        function applyPromo() {
            var rawCode = (input.value || '').trim();
            if (!rawCode) {
                setError('Vui lòng nhập mã khuyến mãi.');
                input.focus();
                return;
            }
            setError(null);
            var mySeq = ++requestSeq;
            applyBtn.disabled = true;
            loadingEl.hidden = false;

            var body = new URLSearchParams();
            body.set('code', rawCode);
            body.set('originalAmount', String(ORIGINAL_AMOUNT));
            body.set('coSoId', String(CO_SO_ID));
            body.set('bookingDate', BOOKING_DATE);

            fetch('${ctx}/api/promotion/apply', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: body.toString()
            }).then(function (res) {
                if (res.status === 401 || res.status === 403) {
                    throw { friendly: 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.' };
                }
                return res.json().catch(function () {
                    throw { friendly: 'Không thể tính lại giá. Vui lòng thử lại.' };
                });
            }).then(function (data) {
                if (mySeq !== requestSeq) return;
                loadingEl.hidden = true;
                applyBtn.disabled = false;

                if (!data || !data.valid) {
                    setError((data && data.message) || 'Mã khuyến mãi không hợp lệ.');
                    return;
                }

                var discount = Number(data.discountAmount || 0);
                var finalAmount = Number(data.finalAmount != null ? data.finalAmount : (ORIGINAL_AMOUNT - discount));
                var code = data.code || rawCode.toUpperCase();

                promoCodeHidden.value = code;
                khuyenMaiIdHidden.value = data.khuyenMaiId != null ? String(data.khuyenMaiId) : '';

                appliedCodeEl.textContent = code;
                appliedDescEl.textContent = data.message || ('Giảm ' + formatVnd(discount));
                idleState.hidden = true;
                appliedState.hidden = false;

                promoRowLabel.textContent = 'Khuyến mãi ' + code;
                promoRowValue.textContent = '-' + formatVnd(discount);
                promoRow.hidden = false;
                totalValueEl.textContent = formatVnd(finalAmount);
            }).catch(function (err) {
                if (mySeq !== requestSeq) return;
                loadingEl.hidden = true;
                applyBtn.disabled = false;
                setError((err && err.friendly) || 'Có lỗi khi kết nối máy chủ. Vui lòng thử lại.');
            });
        }

        applyBtn.addEventListener('click', applyPromo);
        input.addEventListener('keydown', function (e) {
            if (e.key === 'Enter') { e.preventDefault(); applyPromo(); }
        });
        input.addEventListener('input', function () { setError(null); });

        removeBtn.addEventListener('click', function () {
            requestSeq++;
            input.value = '';
            setError(null);
            resetToIdle();
        });

        // Prefill từ "Dùng mã này" ở modal chi tiết cơ sở
        try {
            var pendingCode = sessionStorage.getItem('vsPendingPromoCode');
            var pendingCoSoId = sessionStorage.getItem('vsPendingPromoCoSoId');
            if (pendingCode && pendingCoSoId && Number(pendingCoSoId) === CO_SO_ID) {
                input.value = pendingCode;
            }
            sessionStorage.removeItem('vsPendingPromoCode');
            sessionStorage.removeItem('vsPendingPromoCoSoId');
        } catch (e) { /* sessionStorage không khả dụng */ }
    })();

    form.addEventListener('submit', function (e) {
        if (submitting) { e.preventDefault(); return; }
        submitting = true;
        btn.disabled = true;
        btn.innerHTML = '<span class="spinner" aria-hidden="true"></span><span>Đang xử lý...</span>';
        showStepLoading(hiddenMethod.value === 'payos' ? 'Đang chuẩn bị thanh toán...' : 'Đang xử lý...');
    });
})();
</script>

</body>
</html>
