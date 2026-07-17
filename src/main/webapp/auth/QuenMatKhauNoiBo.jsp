<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Quên mật khẩu Cổng vận hành - V-SPORT</title>
    <%@ include file="common/auth-theme.jsp" %>
    <style>
        /* ===== Nền Cổng vận hành: ảnh thể thao của project + overlay emerald đậm ===== */
        body.auth-body--internal {
            background-color: #052e20;
            background-image:
                linear-gradient(170deg, rgba(6, 52, 36, .90) 0%, rgba(4, 38, 26, .88) 55%, rgba(3, 26, 18, .93) 100%),
                url('${ctx}/resources/background-hero.jpg');
            background-size: cover;
            background-position: center;
            background-attachment: fixed;
        }

        .internal-motif {
            position: fixed;
            inset: 0;
            z-index: 0;
            pointer-events: none;
            opacity: .55;
        }
        .internal-motif svg { width: 100%; height: 100%; }

        .auth-main--internal { padding-top: clamp(28px, 13vh, 158px); }

        .auth-card--internal {
            width: min(640px, 100%);
            border-radius: 12px;
        }
        .auth-card--internal .auth-card-body { padding: 34px 32px 30px; }

        .internal-head { margin-bottom: 26px; }
        .internal-head .internal-badge {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            padding: 5px 12px;
            border-radius: 999px;
            background: #edf6f0;
            border: 1px solid #cbe4d6;
            color: var(--vs-green-800);
            font-size: 12.5px;
            font-weight: 700;
            letter-spacing: .04em;
            margin-bottom: 14px;
        }
        .internal-head .internal-badge .material-symbols-outlined { font-size: 16px; }
        .internal-head h2 {
            margin: 0;
            font-size: 26px;
            font-weight: 700;
            color: var(--vs-ink);
            letter-spacing: -.01em;
        }
        .internal-head p {
            margin: 8px 0 0;
            font-size: 14.5px;
            color: var(--vs-ink-soft);
        }

        /* Ghi chú hỗ trợ nội bộ + callout khách hàng */
        .internal-support-note {
            display: flex;
            align-items: flex-start;
            gap: 12px;
            margin-top: 24px;
            padding: 14px 16px;
            border: 1px solid #cbe4d6;
            border-radius: 8px;
            background: #f4faf6;
        }
        .internal-support-note .material-symbols-outlined {
            font-size: 22px;
            color: var(--vs-green-700);
            flex-shrink: 0;
            margin-top: 1px;
        }
        .internal-support-note p { margin: 0; font-size: 13.5px; line-height: 1.55; color: var(--vs-ink-soft); }

        .customer-callout {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-top: 14px;
            padding: 14px 16px;
            border: 1px solid #cbe4d6;
            border-radius: 8px;
            background: #f4faf6;
        }
        .customer-callout .material-symbols-outlined {
            font-size: 24px;
            color: var(--vs-green-700);
            flex-shrink: 0;
        }
        .customer-callout p { margin: 0; font-size: 13.5px; line-height: 1.5; color: var(--vs-ink-soft); }
        .customer-callout a {
            color: var(--vs-green-800);
            font-weight: 700;
            text-decoration: underline;
            text-underline-offset: 3px;
        }
        .customer-callout a:hover { color: var(--vs-green-900); }

        @media (max-width: 640px) {
            .auth-card--internal .auth-card-body { padding: 24px 18px 22px; }
            .internal-head h2 { font-size: 22px; }
            .customer-callout, .internal-support-note { flex-direction: column; align-items: flex-start; gap: 8px; }
        }
    </style>
</head>
<body class="auth-body auth-body--internal" data-portal="internal">
    <div class="internal-motif" aria-hidden="true">
        <svg viewBox="0 0 1440 900" preserveAspectRatio="xMidYMid slice" xmlns="http://www.w3.org/2000/svg" focusable="false">
            <circle cx="720" cy="450" r="300" fill="none" stroke="rgba(255,255,255,0.05)" stroke-width="2"/>
            <line x1="720" y1="0" x2="720" y2="900" stroke="rgba(255,255,255,0.045)" stroke-width="2"/>
            <rect x="-60" y="270" width="320" height="360" fill="none" stroke="rgba(255,255,255,0.045)" stroke-width="2"/>
            <rect x="1180" y="270" width="320" height="360" fill="none" stroke="rgba(255,255,255,0.045)" stroke-width="2"/>
            <path d="M60,830 L260,730 L470,780 L690,660 L920,710 L1160,600 L1400,650"
                  fill="none" stroke="rgba(110,231,183,0.10)" stroke-width="2.5"/>
        </svg>
    </div>
    <%@ include file="common/auth-transition.jsp" %>

    <header class="auth-topbar">
        <a href="${ctx}/he-thong/dang-nhap" class="auth-back" data-auth-back aria-label="Quay lại đăng nhập Cổng vận hành">
            <span class="material-symbols-outlined" aria-hidden="true">arrow_back_ios_new</span>
        </a>
        <h1>Quên mật khẩu</h1>
    </header>

    <main class="auth-main auth-main--internal">
        <div class="auth-card auth-card--internal">
            <div class="auth-card-body">
                <div class="internal-head">
                    <span class="internal-badge">
                        <span class="material-symbols-outlined" aria-hidden="true">shield_person</span>
                        OPERATIONS PORTAL
                    </span>
                    <h2>Quên mật khẩu</h2>
                    <p>Cổng vận hành V-SPORT — dành cho Quản trị viên, Quản lý và Nhân viên.</p>
                </div>

                <c:if test="${not empty loi}">
                    <div class="auth-alert auth-alert-error" role="alert" aria-live="assertive">
                        <span class="material-symbols-outlined" aria-hidden="true">error</span>
                        <span><c:out value="${loi}"/></span>
                    </div>
                </c:if>
                <c:if test="${not empty thongbao}">
                    <div class="auth-alert auth-alert-success" role="status" aria-live="polite">
                        <span class="material-symbols-outlined" aria-hidden="true">check_circle</span>
                        <span><c:out value="${thongbao}"/></span>
                    </div>
                </c:if>

                <form id="internal-forgot-form" action="${ctx}/he-thong/quen-mat-khau" method="POST"
                      data-auth-form data-auth-transition novalidate>
                    <input type="hidden" name="portal" value="internal"/>
                    <input type="hidden" name="method" value="email"/>

                    <div class="auth-field">
                        <label class="auth-label" for="internal-forgot-email">Email công việc đã đăng ký</label>
                        <div class="auth-input-wrap ${not empty loi ? 'is-invalid' : ''}">
                            <input class="auth-input" type="email" name="email" id="internal-forgot-email"
                                   autocomplete="email" inputmode="email"
                                   placeholder="Nhập email"
                                   aria-describedby="internal-forgot-email-error"
                                   value="<c:out value='${resetEmailInput}'/>"/>
                            <button type="button" class="auth-input-btn auth-clear-btn"
                                    data-clear-for="internal-forgot-email" aria-label="Xóa email đã nhập">
                                <span class="material-symbols-outlined" style="font-variation-settings:'FILL' 1;" aria-hidden="true">cancel</span>
                            </button>
                        </div>
                        <p class="auth-field-error" id="internal-forgot-email-error"></p>
                    </div>

                    <button type="submit" class="auth-btn-primary auth-submit-gap"
                            data-loading-text="ĐANG TÌM KIẾM TÀI KHOẢN...">Tiếp tục</button>
                </form>

                <div class="internal-support-note">
                    <span class="material-symbols-outlined" aria-hidden="true">support_agent</span>
                    <p>Không nhận được email khôi phục hoặc tài khoản của bạn chưa liên kết email?
                       Liên hệ Quản trị viên hệ thống V-SPORT để được hỗ trợ cấp lại mật khẩu.</p>
                </div>

                <div class="customer-callout">
                    <span class="material-symbols-outlined" aria-hidden="true">person</span>
                    <p>
                        Bạn là khách hàng đặt sân?
                        <a href="${ctx}/quenmatkhau" data-portal-link="customer"
                           title="Chuyển về trang khôi phục mật khẩu dành cho khách hàng">Quay về trang khôi phục mật khẩu khách hàng</a>.
                    </p>
                </div>
            </div>
        </div>
    </main>

    <script>
        (function () {
            'use strict';

            var form = document.getElementById('internal-forgot-form');
            var emailInput = document.getElementById('internal-forgot-email');
            var errorEl = document.getElementById('internal-forgot-email-error');

            form.addEventListener('submit', function (e) {
                errorEl.textContent = '';
                errorEl.classList.remove('show');
                var wrap = emailInput.closest('.auth-input-wrap');
                if (wrap) wrap.classList.remove('is-invalid');

                var email = emailInput.value.trim();
                if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
                    e.preventDefault();
                    errorEl.textContent = 'Vui lòng nhập email hợp lệ.';
                    errorEl.classList.add('show');
                    if (wrap) wrap.classList.add('is-invalid');
                    emailInput.focus();
                }
            });
        })();
    </script>
</body>
</html>
