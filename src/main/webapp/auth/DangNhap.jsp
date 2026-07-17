<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%-- Tab đang chọn: ưu tiên giá trị servlet echo lại; mặc định là Số điện thoại,
     riêng khi có sẵn username (ví dụ sau đăng ký thành công) thì mở tab Email. --%>
<c:set var="activeMethod"
       value="${not empty loginMethod ? loginMethod : (not empty username ? 'account' : 'phone')}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Đăng nhập - V-SPORT</title>
    <%@ include file="common/auth-theme.jsp" %>
    <style>
        /* ===== Tabs phương thức đăng nhập (riêng trang Login) ===== */
        .auth-tabs {
            display: flex;
            height: 58px;
            background: #eef1ef;
            position: relative;
        }
        .auth-tab {
            flex: 1;
            position: relative;
            border: none;
            cursor: pointer;
            font-family: inherit;
            font-size: 17px;
            font-weight: 600;
            color: #96a29b;
            background: transparent;
            z-index: 1;
            transition: color .15s ease;
        }
        .auth-tab:hover { color: #6d7b74; }
        .auth-tab:focus-visible { outline: 2px solid var(--vs-green-600); outline-offset: -4px; }
        .auth-tab[aria-selected="true"] {
            background: #fff;
            color: var(--vs-green-900);
            font-weight: 700;
            z-index: 2;
            cursor: default;
        }
        /* Mảnh cong chuyển tiếp giữa tab trắng và nền xám */
        .auth-tab[aria-selected="true"]::after {
            content: "";
            position: absolute;
            top: 0;
            bottom: 0;
            width: 46px;
        }
        #tab-phone[aria-selected="true"]::after {
            right: -45px;
            background: #fff;
            border-radius: 0 100% 0 0;
            box-shadow: 12px 0 16px -8px rgba(0, 0, 0, .22);
        }
        #tab-account[aria-selected="true"]::after {
            left: -45px;
            background: #fff;
            border-radius: 100% 0 0 0;
            box-shadow: -12px 0 16px -8px rgba(0, 0, 0, .22);
        }

        /* Callout Cổng vận hành (ngoài card) */
        .ops-callout {
            display: flex;
            align-items: center;
            gap: 12px;
            width: min(600px, 100%);
            margin-top: 26px;
            padding: 13px 16px;
            border: 1px solid rgba(255, 255, 255, .28);
            border-radius: 8px;
            background: rgba(255, 255, 255, .10);
            backdrop-filter: blur(2px);
        }
        .ops-callout .material-symbols-outlined {
            font-size: 22px;
            color: rgba(255, 255, 255, .92);
            flex-shrink: 0;
        }
        .ops-callout p {
            margin: 0;
            font-size: 13.5px;
            line-height: 1.5;
            color: rgba(255, 255, 255, .88);
        }
        .ops-callout a {
            color: #fff;
            font-weight: 700;
            text-decoration: underline;
            text-underline-offset: 3px;
            white-space: nowrap;
        }

        @media (max-width: 640px) {
            .auth-tabs { height: 52px; }
            .auth-tab { font-size: 15px; }
        }
    </style>
</head>
<body class="auth-body" data-portal="customer">
    <%@ include file="common/auth-waves.jsp" %>
    <%@ include file="common/auth-transition.jsp" %>

    <header class="auth-topbar">
        <a href="${ctx}/index.jsp" class="auth-back" data-auth-back aria-label="Quay lại">
            <span class="material-symbols-outlined" aria-hidden="true">arrow_back_ios_new</span>
        </a>
        <h1>Đăng nhập</h1>
    </header>

    <main class="auth-main">
        <div class="auth-card">
            <div class="auth-tabs" role="tablist" aria-label="Phương thức đăng nhập">
                <button type="button" class="auth-tab" id="tab-phone" role="tab"
                        aria-selected="${activeMethod eq 'phone'}" aria-controls="panel-phone"
                        tabindex="${activeMethod eq 'phone' ? '0' : '-1'}">Số điện thoại</button>
                <button type="button" class="auth-tab" id="tab-account" role="tab"
                        aria-selected="${activeMethod eq 'account'}" aria-controls="panel-account"
                        tabindex="${activeMethod eq 'account' ? '0' : '-1'}">Email</button>
            </div>

            <div class="auth-card-body">
                <c:if test="${not empty thongbao}">
                    <div class="auth-alert auth-alert-success" role="status">
                        <span class="material-symbols-outlined" aria-hidden="true">check_circle</span>
                        <span><c:out value="${thongbao}"/></span>
                    </div>
                </c:if>
                <c:if test="${not empty wrongPortalMsg}">
                    <div class="auth-alert auth-alert-info" role="alert">
                        <span class="material-symbols-outlined" aria-hidden="true">info</span>
                        <span>
                            <c:out value="${wrongPortalMsg}"/>
                            <a href="${ctx}/he-thong/dang-nhap" data-portal-link="internal">Đi đến Cổng vận hành</a>
                        </span>
                    </div>
                </c:if>
                <c:if test="${not empty loi}">
                    <div class="auth-alert auth-alert-error" role="alert" id="login-server-error">
                        <span class="material-symbols-outlined" aria-hidden="true">error</span>
                        <span><c:out value="${loi}"/></span>
                    </div>
                </c:if>

                <form id="login-form" action="${ctx}/dangnhap" method="POST" data-auth-form data-auth-transition novalidate>
                    <input type="hidden" name="portal" value="customer"/>
                    <input type="hidden" name="loginMethod" id="login-method"
                           value="${activeMethod eq 'account' ? 'account' : 'phone'}"/>

                    <div id="panel-phone" role="tabpanel" aria-labelledby="tab-phone"
                         <c:if test="${activeMethod ne 'phone'}">hidden</c:if>>
                        <div class="auth-field">
                            <label class="auth-label" for="login-phone">Số điện thoại của bạn?</label>
                            <div class="auth-input-wrap ${not empty loi and activeMethod eq 'phone' ? 'is-invalid' : ''}">
                                <span class="auth-phone-prefix" aria-hidden="true">
                                    <svg class="vn-flag" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" focusable="false">
                                        <circle cx="12" cy="12" r="12" fill="#da251d"/>
                                        <path d="M12 5.1l1.66 5.1h5.36l-4.34 3.15 1.66 5.1L12 15.3l-4.34 3.15 1.66-5.1-4.34-3.15h5.36z" fill="#ffde00"/>
                                    </svg>
                                    <span>+84</span>
                                    <span class="material-symbols-outlined">keyboard_arrow_down</span>
                                </span>
                                <input class="auth-input" type="tel" name="phone" id="login-phone"
                                       inputmode="numeric" autocomplete="tel" maxlength="16"
                                       placeholder="Nhập số điện thoại"
                                       aria-describedby="login-phone-error"
                                       value="<c:out value='${phone}'/>"
                                       <c:if test="${activeMethod ne 'phone'}">disabled</c:if>/>
                            </div>
                            <p class="auth-field-error" id="login-phone-error"></p>
                        </div>
                    </div>

                    <div id="panel-account" role="tabpanel" aria-labelledby="tab-account"
                         <c:if test="${activeMethod ne 'account'}">hidden</c:if>>
                        <div class="auth-field">
                            <label class="auth-label" for="login-username">Email của bạn?</label>
                            <div class="auth-input-wrap ${not empty loi and activeMethod eq 'account' ? 'is-invalid' : ''}">
                                <input class="auth-input" type="text" name="username" id="login-username"
                                       autocomplete="username"
                                       placeholder="Nhập email hoặc tên đăng nhập"
                                       aria-describedby="login-username-error"
                                       value="<c:out value='${username}'/>"
                                       <c:if test="${activeMethod ne 'account'}">disabled</c:if>/>
                                <button type="button" class="auth-input-btn auth-clear-btn"
                                        data-clear-for="login-username" aria-label="Xóa nội dung email">
                                    <span class="material-symbols-outlined" style="font-variation-settings:'FILL' 1;" aria-hidden="true">cancel</span>
                                </button>
                            </div>
                            <p class="auth-field-error" id="login-username-error"></p>
                        </div>
                    </div>

                    <div class="auth-field">
                        <label class="auth-label" for="login-pass">Mật khẩu (*)</label>
                        <div class="auth-input-wrap">
                            <input class="auth-input" type="password" name="password" id="login-pass"
                                   autocomplete="current-password" placeholder="Nhập mật khẩu (*)"
                                   aria-describedby="login-pass-error" required/>
                            <button type="button" class="auth-input-btn" data-toggle-password="login-pass"
                                    aria-label="Hiện mật khẩu" title="Hiện mật khẩu">
                                <span class="material-symbols-outlined" aria-hidden="true">visibility_off</span>
                            </button>
                        </div>
                        <p class="auth-field-error" id="login-pass-error"></p>
                    </div>

                    <button type="submit" class="auth-btn-primary auth-submit-gap"
                            data-loading-text="ĐANG ĐĂNG NHẬP...">ĐĂNG NHẬP</button>

                    <p class="auth-subline">
                        Bạn quên mật khẩu?
                        <a href="${ctx}/quenmatkhau">Quên mật khẩu</a>
                    </p>
                </form>
            </div>
        </div>

        <p class="auth-switch-line">
            Bạn chưa có tài khoản?
            <a href="${ctx}/dangky">Đăng ký</a>
        </p>

        <div class="ops-callout">
            <span class="material-symbols-outlined" aria-hidden="true">shield_person</span>
            <p>
                Bạn thuộc đội ngũ vận hành V-SPORT? Đăng nhập bằng tài khoản Admin, Manager hoặc Staff.
                <a href="${ctx}/he-thong/dang-nhap" data-portal-link="internal">Chuyển sang Cổng vận hành</a>
            </p>
        </div>
    </main>

    <script>
        (function () {
            'use strict';

            var tabs = [document.getElementById('tab-phone'), document.getElementById('tab-account')];
            var panels = {
                'tab-phone': document.getElementById('panel-phone'),
                'tab-account': document.getElementById('panel-account')
            };
            var methodInput = document.getElementById('login-method');
            var phoneInput = document.getElementById('login-phone');
            var usernameInput = document.getElementById('login-username');
            var passInput = document.getElementById('login-pass');
            var form = document.getElementById('login-form');

            function activate(tab, focus) {
                tabs.forEach(function (t) {
                    var selected = t === tab;
                    t.setAttribute('aria-selected', selected ? 'true' : 'false');
                    t.tabIndex = selected ? 0 : -1;
                    var panel = panels[t.id];
                    panel.hidden = !selected;
                    panel.querySelectorAll('input').forEach(function (inp) { inp.disabled = !selected; });
                });
                methodInput.value = tab.id === 'tab-phone' ? 'phone' : 'account';
                clearFieldErrors();
                if (focus) tab.focus();
            }

            tabs.forEach(function (tab, i) {
                tab.addEventListener('click', function () { activate(tab, false); });
                tab.addEventListener('keydown', function (e) {
                    var next = null;
                    if (e.key === 'ArrowRight' || e.key === 'ArrowDown') next = tabs[(i + 1) % tabs.length];
                    else if (e.key === 'ArrowLeft' || e.key === 'ArrowUp') next = tabs[(i - 1 + tabs.length) % tabs.length];
                    else if (e.key === 'Home') next = tabs[0];
                    else if (e.key === 'End') next = tabs[tabs.length - 1];
                    if (next) { e.preventDefault(); activate(next, true); }
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

            function clearFieldErrors() {
                [phoneInput, usernameInput, passInput].forEach(function (inp) { setFieldError(inp, null); });
            }

            // Validation client trước khi submit (server vẫn validate lại đầy đủ)
            form.addEventListener('submit', function (e) {
                clearFieldErrors();
                var isPhone = methodInput.value === 'phone';
                var ok = true;

                if (isPhone) {
                    var digits = phoneInput.value.trim().replace(/[\s().-]/g, '');
                    if (!digits) {
                        setFieldError(phoneInput, 'Vui lòng nhập số điện thoại.');
                        ok = false;
                    } else if (!/^(0|\+84|84)[35789][0-9]{8}$/.test(digits)) {
                        setFieldError(phoneInput, 'Số điện thoại không hợp lệ. Ví dụ: 0786041209.');
                        ok = false;
                    }
                } else if (!usernameInput.value.trim()) {
                    setFieldError(usernameInput, 'Vui lòng nhập email hoặc tên đăng nhập.');
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
