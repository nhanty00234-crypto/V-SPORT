<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Đăng nhập Cổng vận hành - V-SPORT</title>
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

        /* Motif đường kẻ sân + lưới lịch mờ, gợi cảm giác "vận hành" */
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

        .internal-head { margin-bottom: 28px; }
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

        /* Callout quay về cổng khách hàng */
        .customer-callout {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-top: 26px;
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
            white-space: nowrap;
        }
        .customer-callout a:hover { color: var(--vs-green-900); }

        @media (max-width: 640px) {
            .auth-card--internal .auth-card-body { padding: 24px 18px 22px; }
            .internal-head h2 { font-size: 22px; }
            .customer-callout { flex-direction: column; align-items: flex-start; gap: 8px; }
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
        <a href="${ctx}/index.jsp" class="auth-back" data-auth-back aria-label="Quay lại">
            <span class="material-symbols-outlined" aria-hidden="true">arrow_back_ios_new</span>
        </a>
        <h1>Cổng vận hành</h1>
    </header>

    <main class="auth-main auth-main--internal">
        <div class="auth-card auth-card--internal">
            <div class="auth-card-body">
                <div class="internal-head">
                    <span class="internal-badge">
                        <span class="material-symbols-outlined" aria-hidden="true">shield_person</span>
                        OPERATIONS PORTAL
                    </span>
                    <h2>Đăng nhập Cổng vận hành</h2>
                    <p>Dành cho Quản trị viên, Quản lý và Nhân viên V-SPORT.</p>
                </div>

                <c:if test="${not empty loi}">
                    <div class="auth-alert auth-alert-error" role="alert" id="internal-server-error">
                        <span class="material-symbols-outlined" aria-hidden="true">error</span>
                        <span><c:out value="${loi}"/></span>
                    </div>
                </c:if>

                <form id="internal-login-form" action="${ctx}/he-thong/dang-nhap" method="POST"
                      data-auth-form data-auth-transition novalidate>
                    <input type="hidden" name="portal" value="internal"/>

                    <div class="auth-field">
                        <label class="auth-label" for="internal-username">Tên đăng nhập hoặc email</label>
                        <div class="auth-input-wrap ${not empty loi ? 'is-invalid' : ''}">
                            <input class="auth-input" type="text" name="username" id="internal-username"
                                   autocomplete="username"
                                   placeholder="Nhập tên đăng nhập hoặc email"
                                   aria-describedby="internal-username-error"
                                   value="<c:out value='${username}'/>" required/>
                            <button type="button" class="auth-input-btn auth-clear-btn"
                                    data-clear-for="internal-username" aria-label="Xóa nội dung tài khoản">
                                <span class="material-symbols-outlined" style="font-variation-settings:'FILL' 1;" aria-hidden="true">cancel</span>
                            </button>
                        </div>
                        <p class="auth-field-error" id="internal-username-error"></p>
                    </div>

                    <div class="auth-field">
                        <label class="auth-label" for="internal-pass">Mật khẩu</label>
                        <div class="auth-input-wrap">
                            <input class="auth-input" type="password" name="password" id="internal-pass"
                                   autocomplete="current-password" placeholder="Nhập mật khẩu"
                                   aria-describedby="internal-pass-error" required/>
                            <button type="button" class="auth-input-btn" data-toggle-password="internal-pass"
                                    aria-label="Hiện mật khẩu" title="Hiện mật khẩu">
                                <span class="material-symbols-outlined" aria-hidden="true">visibility_off</span>
                            </button>
                        </div>
                        <p class="auth-field-error" id="internal-pass-error"></p>
                    </div>

                    <button type="submit" class="auth-btn-primary auth-submit-gap"
                            data-loading-text="ĐANG XÁC THỰC...">ĐĂNG NHẬP HỆ THỐNG</button>

                    <p class="auth-subline">
                        Bạn quên mật khẩu?
                        <a href="${ctx}/he-thong/quen-mat-khau">Quên mật khẩu</a>
                    </p>
                </form>

                <div class="customer-callout">
                    <span class="material-symbols-outlined" aria-hidden="true">person</span>
                    <p>
                        Bạn là khách hàng muốn đặt sân hoặc tham gia ghép trận?
                        <a href="${ctx}/dangnhap" data-portal-link="customer">Quay về Cổng khách hàng</a>
                    </p>
                </div>
            </div>
        </div>
    </main>

    <script>
        (function () {
            'use strict';

            var form = document.getElementById('internal-login-form');
            var usernameInput = document.getElementById('internal-username');
            var passInput = document.getElementById('internal-pass');

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

            form.addEventListener('submit', function (e) {
                [usernameInput, passInput].forEach(function (inp) { setFieldError(inp, null); });
                var ok = true;
                if (!usernameInput.value.trim()) {
                    setFieldError(usernameInput, 'Vui lòng nhập tên đăng nhập hoặc email.');
                    ok = false;
                }
                if (!passInput.value) {
                    setFieldError(passInput, 'Vui lòng nhập mật khẩu.');
                    ok = false;
                }
                if (!ok) {
                    e.preventDefault();
                    var firstInvalid = form.querySelector('.auth-input-wrap.is-invalid .auth-input');
                    if (firstInvalid) firstInvalid.focus();
                }
            });
        })();
    </script>
</body>
</html>
