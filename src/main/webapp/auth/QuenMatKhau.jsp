<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="activeMethod" value="${empty method ? 'email' : method}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Quên mật khẩu - V-SPORT</title>
    <%@ include file="common/auth-theme.jsp" %>
    <style>
        /* Back button rõ hơn theo target (chỉ scope trang này) */
        .auth-topbar { padding-top: 8px; }
        .auth-topbar .auth-back { width: 44px; height: 44px; }
        .auth-topbar .auth-back .material-symbols-outlined { font-size: 28px; }
        .auth-topbar h1 { font-size: 26px; }
        @media (max-width: 640px) { .auth-topbar h1 { font-size: 21px; } }

        /* Card ~760px, đặt khoảng 30% chiều cao viewport từ trên (theo target) */
        .auth-main--forgot { padding-top: clamp(56px, 24vh, 275px); }
        .auth-card--forgot { width: min(760px, calc(100vw - 40px)); border-radius: 12px; }
        .auth-card--forgot .auth-card-body { padding: 30px 32px 32px; }

        .forgot-intro {
            margin: 0 0 22px;
            font-size: 18px;
            line-height: 1.45;
            color: var(--vs-ink);
        }

        .method-title {
            margin: 0 0 15px;
            font-size: 21px;
            font-weight: 700;
            color: var(--vs-ink);
        }

        /* ===== Radio cards chọn phương thức tìm tài khoản ===== */
        .method-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
            margin-bottom: 26px;
        }
        .method-card {
            position: relative;
            display: flex;
            align-items: center;
            gap: 11px;
            min-height: 58px;
            padding: 0 18px;
            border: 1.5px solid var(--vs-line);
            border-radius: 8px;
            background: #fff;
            cursor: pointer;
            transition: border-color .15s ease, background-color .15s ease, box-shadow .15s ease;
        }
        .method-card input[type="radio"] {
            position: absolute;
            opacity: 0;
            pointer-events: none;
        }
        .method-card .method-dot {
            width: 20px;
            height: 20px;
            flex-shrink: 0;
            border: 2px solid #b8c4bd;
            border-radius: 50%;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            transition: border-color .15s ease;
        }
        .method-card .method-dot::after {
            content: '';
            width: 10px;
            height: 10px;
            border-radius: 50%;
            background: var(--vs-green-600);
            transform: scale(0);
            transition: transform .12s ease;
        }
        .method-card .method-name {
            font-size: 17px;
            font-weight: 600;
            color: var(--vs-ink);
        }
        .method-card.is-active { border-width: 2px; padding: 0 17.5px; }

        /* Field + input phóng theo target */
        .auth-card--forgot .auth-field { margin-top: 32px; margin-bottom: 0; }
        .auth-card--forgot .auth-label { font-size: 20px; font-weight: 700; margin-bottom: 15px; }
        .auth-card--forgot .auth-input-wrap { height: 62px; border-radius: 8px; }
        .auth-card--forgot .auth-input { font-size: 18px; padding: 0 16px; }
        .auth-card--forgot .auth-btn-primary {
            height: 62px;
            margin-top: 38px;
            font-size: 18px;
            letter-spacing: .01em;
            border-radius: 7px;
        }
        .method-card:hover { border-color: var(--vs-green-600); }
        .method-card.is-active {
            border-color: var(--vs-green-600);
            background: #eefaf3;
        }
        .method-card.is-active .method-dot { border-color: var(--vs-green-600); }
        .method-card.is-active .method-dot::after { transform: scale(1); }
        .method-card.is-active .method-name { color: var(--vs-green-800); }
        .method-card:focus-within {
            outline: 3px solid rgba(13, 138, 95, .35);
            outline-offset: 2px;
        }

        /* ===== Khu vực hỗ trợ dưới card (theo target: text trắng + 2 nút ngang) ===== */
        .forgot-support {
            width: min(760px, calc(100vw - 40px));
            margin-top: 58px;
            color: #fff;
        }
        .forgot-support p.support-text {
            margin: 0 0 18px;
            font-size: 18px;
            line-height: 1.35;
        }
        .support-btn-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 18px;
        }
        .support-btn {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            height: 58px;
            border-radius: 8px;
            color: #fff;
            font-size: 17px;
            font-weight: 700;
            text-decoration: none;
            transition: filter .15s ease;
        }
        .support-btn:hover { filter: brightness(1.07); }
        .support-btn:focus-visible { outline: 3px solid rgba(255,255,255,.6); outline-offset: 2px; }
        .support-btn--facebook { background: #1f8ef1; }
        .support-btn--zalo { background: #23c197; }
        .support-btn .material-symbols-outlined { font-size: 22px; }

        .internal-portal-line {
            margin: 22px 0 0;
            font-size: 14.5px;
            color: rgba(255, 255, 255, .88);
        }
        .internal-portal-line a {
            color: #fff;
            font-weight: 700;
            text-decoration: underline;
            text-underline-offset: 3px;
        }

        /* Spinner nhỏ trong nút submit — MẶC ĐỊNH ẨN, chỉ hiện khi button.is-loading */
        .forgot-submit { position: relative; }
        .btn-spinner { display: none; }
        .forgot-submit.is-loading .btn-label { visibility: hidden; }
        .forgot-submit.is-loading .btn-spinner {
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
        .sr-only {
            position: absolute;
            width: 1px; height: 1px;
            padding: 0; margin: -1px;
            overflow: hidden;
            clip: rect(0 0 0 0);
            white-space: nowrap;
            border: 0;
        }
        .btn-loading-text { display: none; }
        .forgot-submit.is-loading .btn-loading-text { display: inline; }

        @media (max-width: 640px) {
            .auth-main--forgot { padding-top: clamp(36px, 12vh, 110px); }
            .auth-card--forgot { width: calc(100vw - 24px); }
            .auth-card--forgot .auth-card-body { padding: 20px 16px 22px; }
            .forgot-intro { font-size: 16px; }
            .method-title { font-size: 18.5px; }
            .auth-card--forgot .auth-label { font-size: 17px; margin-bottom: 11px; }
            .auth-card--forgot .auth-input-wrap { height: 54px; }
            .auth-card--forgot .auth-input { font-size: 16px; }
            .auth-card--forgot .auth-btn-primary { height: 54px; margin-top: 28px; font-size: 16px; }
            .forgot-support { width: calc(100vw - 24px); margin-top: 40px; }
            .forgot-support p.support-text { font-size: 16px; }
            .support-btn-row { grid-template-columns: 1fr; gap: 11px; }
        }
        @media (max-width: 420px) {
            .method-grid { grid-template-columns: 1fr; gap: 10px; }
        }

        @media (prefers-reduced-motion: reduce) {
            .method-card, .method-card .method-dot, .method-card .method-dot::after { transition: none; }
            .btn-spinner::after { animation-duration: 2.4s; }
        }
    </style>
</head>
<body class="auth-body" data-portal="customer">
    <%@ include file="common/auth-waves.jsp" %>
    <%@ include file="common/auth-transition.jsp" %>

    <header class="auth-topbar">
        <a href="${ctx}/dangnhap" class="auth-back" data-auth-back aria-label="Quay lại đăng nhập">
            <span class="material-symbols-outlined" aria-hidden="true">arrow_back_ios_new</span>
        </a>
        <h1>Quên mật khẩu</h1>
    </header>

    <main class="auth-main auth-main--forgot">
        <div class="auth-card auth-card--forgot">
            <div class="auth-card-body">
                <p class="forgot-intro">Nhập email hoặc số điện thoại đã đăng ký để tìm kiếm và lấy lại mật khẩu.</p>

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

                <form id="forgot-form" action="${ctx}/quenmatkhau" method="POST" novalidate>
                    <input type="hidden" name="portal" value="customer"/>

                    <h2 class="method-title" id="method-title">Tìm kiếm tài khoản theo</h2>
                    <div class="method-grid" role="radiogroup" aria-labelledby="method-title">
                        <label class="method-card ${activeMethod eq 'email' ? 'is-active' : ''}" data-method-card="email">
                            <input type="radio" name="method" value="email"
                                   ${activeMethod eq 'email' ? 'checked' : ''}/>
                            <span class="method-dot" aria-hidden="true"></span>
                            <span class="method-name">Email</span>
                        </label>
                        <label class="method-card ${activeMethod eq 'phone' ? 'is-active' : ''}" data-method-card="phone">
                            <input type="radio" name="method" value="phone"
                                   ${activeMethod eq 'phone' ? 'checked' : ''}/>
                            <span class="method-dot" aria-hidden="true"></span>
                            <span class="method-name">Số điện thoại</span>
                        </label>
                    </div>

                    <div class="auth-field" id="email-field" ${activeMethod eq 'phone' ? 'hidden' : ''}>
                        <label class="auth-label" for="forgot-email">Email đã đăng ký</label>
                        <div class="auth-input-wrap ${not empty loi and activeMethod eq 'email' ? 'is-invalid' : ''}">
                            <input class="auth-input" type="email" name="email" id="forgot-email"
                                   autocomplete="email" inputmode="email"
                                   placeholder="Nhập email đã đăng ký"
                                   aria-describedby="forgot-email-error"
                                   value="<c:out value='${resetEmailInput}'/>"/>
                            <button type="button" class="auth-input-btn auth-clear-btn"
                                    data-clear-for="forgot-email" aria-label="Xóa email đã nhập">
                                <span class="material-symbols-outlined" style="font-variation-settings:'FILL' 1;" aria-hidden="true">cancel</span>
                            </button>
                        </div>
                        <p class="auth-field-error" id="forgot-email-error"></p>
                    </div>

                    <div class="auth-field" id="phone-field" ${activeMethod eq 'phone' ? '' : 'hidden'}>
                        <label class="auth-label" for="forgot-phone">Số điện thoại đã đăng ký</label>
                        <div class="auth-input-wrap ${not empty loi and activeMethod eq 'phone' ? 'is-invalid' : ''}">
                            <span class="auth-phone-prefix" aria-hidden="true">
                                <svg class="vn-flag" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" focusable="false">
                                    <circle cx="12" cy="12" r="12" fill="#da251d"/>
                                    <path d="M12 5.6l1.52 4.4 4.65.06-3.72 2.8 1.37 4.44L12 14.6l-3.82 2.7 1.37-4.44-3.72-2.8 4.65-.06z" fill="#ffcd00"/>
                                </svg>
                                +84
                            </span>
                            <input class="auth-input" type="tel" name="phone" id="forgot-phone"
                                   autocomplete="tel" inputmode="numeric"
                                   placeholder="Nhập số điện thoại đã đăng ký"
                                   aria-describedby="forgot-phone-error forgot-phone-hint"
                                   value="<c:out value='${resetPhoneInput}'/>"/>
                            <button type="button" class="auth-input-btn auth-clear-btn"
                                    data-clear-for="forgot-phone" aria-label="Xóa số điện thoại đã nhập">
                                <span class="material-symbols-outlined" style="font-variation-settings:'FILL' 1;" aria-hidden="true">cancel</span>
                            </button>
                        </div>
                        <p class="auth-hint" id="forgot-phone-hint">Chấp nhận dạng 0xxxxxxxxx, +84xxxxxxxxx hoặc 84xxxxxxxxx. Mã xác thực sẽ được gửi tới email đã đăng ký của tài khoản.</p>
                        <p class="auth-field-error" id="forgot-phone-error"></p>
                    </div>

                    <button type="submit" id="forgot-submit" class="auth-btn-primary auth-submit-gap forgot-submit"
                            aria-busy="false">
                        <span class="btn-label">Tiếp tục</span>
                        <span class="btn-spinner" aria-hidden="true"></span>
                        <span class="sr-only btn-loading-text">Đang gửi mã xác thực</span>
                    </button>
                </form>
            </div>
        </div>

        <div class="forgot-support">
            <p class="support-text">Bạn gặp vấn đề khi khôi phục tài khoản?<br/>Liên hệ bộ phận hỗ trợ V-SPORT để được trợ giúp.</p>

            <%-- Chỉ hiển thị nút khi URL hỗ trợ THẬT được cấu hình (context-param), không tạo dead link --%>
            <c:set var="fbUrl" value="${initParam['SUPPORT_FACEBOOK_URL']}"/>
            <c:set var="zaloUrl" value="${initParam['SUPPORT_ZALO_URL']}"/>
            <c:if test="${not empty fbUrl or not empty zaloUrl}">
                <div class="support-btn-row">
                    <c:if test="${not empty fbUrl}">
                        <a class="support-btn support-btn--facebook" href="${fbUrl}" target="_blank" rel="noopener"
                           title="Fanpage hỗ trợ V-SPORT">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true" focusable="false"><path d="M22 12a10 10 0 1 0-11.56 9.88v-6.99H7.9V12h2.54V9.8c0-2.5 1.49-3.89 3.77-3.89 1.09 0 2.23.2 2.23.2v2.46h-1.26c-1.24 0-1.63.77-1.63 1.56V12h2.78l-.44 2.89h-2.34v6.99A10 10 0 0 0 22 12z"/></svg>
                            Fanpage
                        </a>
                    </c:if>
                    <c:if test="${not empty zaloUrl}">
                        <a class="support-btn support-btn--zalo" href="${zaloUrl}" target="_blank" rel="noopener"
                           title="Zalo hỗ trợ V-SPORT">
                            <span class="material-symbols-outlined" aria-hidden="true">chat</span>
                            Zalo
                        </a>
                    </c:if>
                </div>
            </c:if>
            <c:if test="${empty fbUrl and empty zaloUrl}">
                <p class="support-text" style="font-size:15.5px;margin-bottom:0;color:rgba(255,255,255,.9);">
                    Hỗ trợ trực tiếp tại quầy lễ tân cơ sở V-SPORT gần nhất.
                </p>
            </c:if>

            <p class="internal-portal-line">
                Bạn thuộc đội ngũ vận hành?
                <a href="${ctx}/he-thong/quen-mat-khau" data-portal-link="internal"
                   title="Chuyển tới trang khôi phục mật khẩu của Cổng vận hành">Khôi phục mật khẩu tại Cổng vận hành</a>.
            </p>
        </div>
    </main>

    <script>
        (function () {
            'use strict';

            var form = document.getElementById('forgot-form');
            var emailField = document.getElementById('email-field');
            var phoneField = document.getElementById('phone-field');
            var emailInput = document.getElementById('forgot-email');
            var phoneInput = document.getElementById('forgot-phone');

            function currentMethod() {
                var checked = form.querySelector('input[name="method"]:checked');
                return checked ? checked.value : 'email';
            }

            function syncMethodUI() {
                var method = currentMethod();
                document.querySelectorAll('[data-method-card]').forEach(function (card) {
                    card.classList.toggle('is-active', card.getAttribute('data-method-card') === method);
                });
                emailField.hidden = method !== 'email';
                phoneField.hidden = method !== 'phone';
            }

            form.querySelectorAll('input[name="method"]').forEach(function (radio) {
                radio.addEventListener('change', function () {
                    syncMethodUI();
                    var target = currentMethod() === 'email' ? emailInput : phoneInput;
                    target.focus({ preventScroll: true });
                });
            });

            function setFieldError(input, msg) {
                var errorEl = document.getElementById(input.id + '-error');
                var wrap = input.closest('.auth-input-wrap');
                if (msg) {
                    errorEl.textContent = msg;
                    errorEl.classList.add('show');
                    if (wrap) wrap.classList.add('is-invalid');
                } else {
                    errorEl.textContent = '';
                    errorEl.classList.remove('show');
                    if (wrap) wrap.classList.remove('is-invalid');
                }
            }

            var submitBtn = document.getElementById('forgot-submit');

            function resetSubmitButton() {
                submitBtn.classList.remove('is-loading');
                submitBtn.disabled = false;
                submitBtn.setAttribute('aria-busy', 'false');
                form.dataset.submitted = '';
            }

            function startLoading() {
                submitBtn.classList.add('is-loading');
                submitBtn.disabled = true;
                submitBtn.setAttribute('aria-busy', 'true');
            }

            form.addEventListener('submit', function (e) {
                // Chống double-submit (click đúp hoặc Enter lặp)
                if (form.dataset.submitted === 'true') { e.preventDefault(); return; }

                setFieldError(emailInput, null);
                setFieldError(phoneInput, null);
                var method = currentMethod();
                if (method === 'email') {
                    var email = emailInput.value.trim();
                    if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
                        e.preventDefault();
                        setFieldError(emailInput, 'Vui lòng nhập email hợp lệ.');
                        emailInput.focus();
                        return;
                    }
                } else {
                    var phone = phoneInput.value.replace(/[\s.\-]/g, '');
                    if (!/^(0|\+?84)\d{9}$/.test(phone)) {
                        e.preventDefault();
                        setFieldError(phoneInput, 'Vui lòng nhập số di động Việt Nam hợp lệ (0, +84 hoặc 84).');
                        phoneInput.focus();
                        return;
                    }
                }
                // Hợp lệ: bật spinner nhỏ trong nút rồi để form submit thật
                form.dataset.submitted = 'true';
                startLoading();
            });

            // Back/Forward/BFCache hoặc render lại: nút luôn trở về trạng thái thường
            window.addEventListener('pageshow', function () {
                resetSubmitButton();
            });

            syncMethodUI();
            <c:if test="${not empty loi}">
            // Server trả lỗi: focus lại field đang chọn để nhập lại nhanh
            (currentMethod() === 'email' ? emailInput : phoneInput).focus();
            </c:if>
        })();
    </script>
</body>
</html>
