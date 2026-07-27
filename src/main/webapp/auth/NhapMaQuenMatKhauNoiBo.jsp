<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Nhập mã xác thực Cổng vận hành - V-SPORT</title>
    <%@ include file="common/auth-theme.jsp" %>
    <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@700;800&display=swap" rel="stylesheet"/>
    <style>
        body.auth-body--internal {
            background-color: #052e20;
            background-image:
                linear-gradient(170deg, rgba(6, 52, 36, .92) 0%, rgba(4, 38, 26, .90) 55%, rgba(3, 26, 18, .95) 100%),
                url('${ctx}/resources/background-hero.jpg');
            background-size: cover;
            background-position: center;
            background-attachment: fixed;
        }
        .auth-main--internal { padding-top: clamp(32px, 14vh, 160px); }
        .auth-card--otp {
            width: min(500px, 100%);
            border-radius: 20px;
            box-shadow: 0 24px 56px rgba(2, 20, 14, 0.45);
            border: 1px solid rgba(255, 255, 255, 0.15);
            position: relative;
            overflow: hidden;
        }
        .auth-card--otp::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0;
            height: 5px;
            background: linear-gradient(90deg, #10b981 0%, #059669 50%, #3b82f6 100%);
        }
        .auth-card--otp .auth-card-body { padding: 34px 30px 28px; }

        .internal-badge {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            padding: 6px 14px;
            border-radius: 999px;
            background: #ecfdf5;
            border: 1px solid #a7f3d0;
            color: #047857;
            font-size: 12px;
            font-weight: 800;
            letter-spacing: .06em;
            margin-bottom: 16px;
        }
        .internal-badge .material-symbols-outlined { font-size: 16px; }

        .otp-title {
            margin: 0 0 6px;
            font-size: 23px;
            font-weight: 800;
            color: var(--vs-ink);
            letter-spacing: -.02em;
        }
        .otp-desc {
            margin: 0 0 24px;
            font-size: 14px;
            line-height: 1.55;
            color: var(--vs-ink-soft);
        }
        .otp-desc b { color: var(--vs-ink); font-weight: 700; }

        .otp-single {
            width: 100%;
            height: 64px;
            border: 2px solid var(--vs-line);
            border-radius: 14px;
            font-family: 'JetBrains Mono', Consolas, monospace;
            font-size: 26px;
            font-weight: 800;
            text-align: center;
            letter-spacing: .45em;
            padding-left: .45em;
            color: var(--vs-ink);
            background: #f8fafc;
            outline: none;
            transition: all .2s ease;
        }
        .otp-single::placeholder { color: #cbd5e1; letter-spacing: .45em; font-weight: 500; }
        .otp-single:focus {
            background: #ffffff;
            border-color: #059669;
            box-shadow: 0 0 0 4px rgba(5, 150, 105, 0.16);
        }
        .otp-single.is-invalid { border-color: var(--vs-danger); background: #fef2f2; }

        .otp-resend {
            margin: 16px 0 0;
            font-size: 13.5px;
            color: var(--vs-ink-soft);
            text-align: center;
            font-weight: 500;
        }
        .otp-resend a {
            color: #059669;
            font-weight: 700;
            text-decoration: underline;
            text-underline-offset: 3px;
        }
        .otp-resend a:hover { color: #047857; }

        .otp-timer-badge {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            background: #f1f5f9;
            padding: 3px 10px;
            border-radius: 6px;
            font-family: 'JetBrains Mono', monospace;
            font-weight: 700;
            color: #475569;
        }

        .otp-verify-btn {
            margin-top: 24px;
            height: 52px;
            border-radius: 12px;
            font-size: 15px;
            font-weight: 800;
            letter-spacing: .05em;
            background: linear-gradient(135deg, #059669 0%, #047857 100%);
            box-shadow: 0 6px 18px rgba(5, 150, 105, 0.32);
            position: relative;
        }
        .btn-spinner { display: none; }
        .otp-verify-btn.is-loading .btn-label { visibility: hidden; }
        .otp-verify-btn.is-loading .btn-spinner {
            position: absolute;
            inset: 0;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .btn-spinner::after {
            content: '';
            width: 24px;
            height: 24px;
            border-radius: 50%;
            border: 3px solid rgba(255, 255, 255, .35);
            border-top-color: #fff;
            animation: vs-rotate .8s linear infinite;
        }
        @keyframes vs-rotate { to { transform: rotate(360deg); } }

        .otp-links {
            margin: 20px 0 0;
            display: flex;
            flex-direction: column;
            gap: 8px;
            text-align: center;
            font-size: 13.5px;
        }
        .otp-links a {
            color: var(--vs-ink-soft);
            font-weight: 600;
            text-decoration: underline;
            text-underline-offset: 3px;
        }
        .otp-links a:hover { color: var(--vs-ink); }

        @media (max-width: 640px) {
            .auth-card--otp .auth-card-body { padding: 24px 20px 22px; }
            .otp-single { height: 56px; font-size: 22px; }
        }
    </style>
</head>
<body class="auth-body auth-body--internal" data-portal="internal">

    <header class="auth-topbar">
        <a href="${ctx}/he-thong/quen-mat-khau" class="auth-back" aria-label="Quay lại nhập email">
            <span class="material-symbols-outlined" aria-hidden="true">arrow_back_ios_new</span>
        </a>
        <h1>Quên mật khẩu</h1>
    </header>

    <main class="auth-main auth-main--internal">
        <div class="auth-card auth-card--otp">
            <div class="auth-card-body">
                <span class="internal-badge">
                    <span class="material-symbols-outlined" aria-hidden="true">shield_person</span>
                    CỔNG VẬN HÀNH OPERATIONS
                </span>
                <h2 class="otp-title">Nhập mã xác thực</h2>
                <p class="otp-desc">Mã gồm 6 chữ số đã được gửi đến email <b><c:out value="${email}"/></b>.</p>

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

                <form id="otp-form" action="${ctx}/he-thong/xac-thuc-otp" method="POST" autocomplete="off" novalidate>
                    <label class="auth-label" for="otp-input" style="position:absolute;width:1px;height:1px;overflow:hidden;clip:rect(0 0 0 0);">Mã xác thực 6 chữ số</label>
                    <input class="otp-single" type="text" name="otp" id="otp-input"
                           inputmode="numeric" autocomplete="one-time-code"
                           maxlength="6" pattern="[0-9]{6}" placeholder="••••••"
                           aria-describedby="otp-error"/>
                    <p class="auth-field-error" id="otp-error"></p>

                    <p class="otp-resend" aria-live="polite">
                        <span id="resend-countdown" hidden>Gửi lại mã sau <span id="resend-timer" class="otp-timer-badge">01:00</span></span>
                        <a id="resend-link" href="${ctx}/resend-otp">Gửi lại mã</a>
                    </p>

                    <button type="submit" id="otp-verify-btn" class="auth-btn-primary otp-verify-btn"
                            aria-busy="false">
                        <span class="btn-label">XÁC NHẬN</span>
                        <span class="btn-spinner" aria-hidden="true"></span>
                    </button>
                </form>

                <div class="otp-links">
                    <a href="${ctx}/he-thong/quen-mat-khau">Đổi email khác</a>
                    <a href="${ctx}/he-thong/dang-nhap">Quay lại Cổng vận hành</a>
                </div>
            </div>
        </div>
    </main>

    <script>
        (function () {
            'use strict';

            var form = document.getElementById('otp-form');
            var input = document.getElementById('otp-input');
            var errorEl = document.getElementById('otp-error');
            var btn = document.getElementById('otp-verify-btn');

            input.addEventListener('input', function () {
                var digits = input.value.replace(/\D/g, '').slice(0, 6);
                if (input.value !== digits) input.value = digits;
            });

            function setLoading(on) {
                btn.classList.toggle('is-loading', on);
                btn.disabled = on;
                btn.setAttribute('aria-busy', on ? 'true' : 'false');
                if (!on) form.dataset.submitted = '';
            }

            form.addEventListener('submit', function (e) {
                if (form.dataset.submitted === 'true') { e.preventDefault(); return; }
                errorEl.textContent = '';
                errorEl.classList.remove('show');
                input.classList.remove('is-invalid');
                if (!/^\d{6}$/.test(input.value)) {
                    e.preventDefault();
                    errorEl.textContent = 'Vui lòng nhập đủ 6 chữ số.';
                    errorEl.classList.add('show');
                    input.classList.add('is-invalid');
                    input.focus();
                    input.select();
                    return;
                }
                form.dataset.submitted = 'true';
                setLoading(true);
            });

            window.addEventListener('pageshow', function () {
                setLoading(false);
            });

            var countdownWrap = document.getElementById('resend-countdown');
            var timerEl = document.getElementById('resend-timer');
            var resendLink = document.getElementById('resend-link');
            var remaining = 60;

            function fmt(s) {
                var m = Math.floor(s / 60), r = s % 60;
                return (m < 10 ? '0' : '') + m + ':' + (r < 10 ? '0' : '') + r;
            }
            function tick() {
                if (remaining <= 0) {
                    countdownWrap.hidden = true;
                    resendLink.hidden = false;
                    return;
                }
                timerEl.textContent = fmt(remaining);
                remaining--;
                setTimeout(tick, 1000);
            }
            resendLink.hidden = true;
            countdownWrap.hidden = false;
            tick();

            <c:if test="${not empty loi}">
            input.focus();
            </c:if>
        })();
    </script>
</body>
</html>
