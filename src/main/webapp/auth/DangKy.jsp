<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Đăng ký - V-SPORT</title>
    <%@ include file="common/auth-theme.jsp" %>
    <style>
        /* Card đăng ký hẹp hơn card đăng nhập một chút, bo góc lớn hơn (theo target) */
        .auth-card--register {
            width: min(570px, 100%);
            border-radius: 10px;
        }
        .auth-card--register .auth-card-body { padding: 24px 24px 24px; }
        .auth-card--register .auth-field { margin-bottom: 24px; }
        .auth-main--register { padding-top: clamp(28px, 12vh, 150px); }

        .auth-consent {
            margin-top: 14px;
            text-align: center;
            font-size: 12.5px;
            line-height: 1.5;
            color: var(--vs-ink-soft);
        }

        @media (max-width: 640px) {
            .auth-card--register .auth-card-body { padding: 20px 16px; }
        }
    </style>
</head>
<body class="auth-body">
    <%@ include file="common/auth-waves.jsp" %>

    <header class="auth-topbar">
        <a href="${ctx}/index.jsp" class="auth-back" data-auth-back aria-label="Quay lại">
            <span class="material-symbols-outlined" aria-hidden="true">arrow_back_ios_new</span>
        </a>
        <h1>Đăng ký</h1>
    </header>

    <main class="auth-main auth-main--register">
        <div class="auth-card auth-card--register">
            <div class="auth-card-body">
                <c:if test="${not empty loi}">
                    <div class="auth-alert auth-alert-error" role="alert" id="register-server-error">
                        <span class="material-symbols-outlined" aria-hidden="true">error</span>
                        <span><c:out value="${loi}"/></span>
                    </div>
                </c:if>

                <form id="register-form" action="${ctx}/dangky" method="POST" data-auth-form novalidate>
                    <%-- Đồng ý điều khoản: thể hiện bằng dòng xác nhận dưới nút ĐĂNG KÝ --%>
                    <input type="hidden" name="agree" value="Đồng ý"/>

                    <div class="auth-field">
                        <label class="auth-label" for="reg-phone">Số điện thoại của bạn?</label>
                        <div class="auth-input-wrap">
                            <span class="auth-phone-prefix" aria-hidden="true">
                                <svg class="vn-flag" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" focusable="false">
                                    <circle cx="12" cy="12" r="12" fill="#da251d"/>
                                    <path d="M12 5.1l1.66 5.1h5.36l-4.34 3.15 1.66 5.1L12 15.3l-4.34 3.15 1.66-5.1-4.34-3.15h5.36z" fill="#ffde00"/>
                                </svg>
                                <span>+84</span>
                                <span class="material-symbols-outlined">keyboard_arrow_down</span>
                            </span>
                            <input class="auth-input" type="tel" name="phone" id="reg-phone"
                                   inputmode="numeric" autocomplete="tel" maxlength="16"
                                   placeholder="Nhập số điện thoại"
                                   aria-describedby="reg-phone-error"
                                   value="<c:out value='${phone}'/>" required/>
                        </div>
                        <p class="auth-field-error" id="reg-phone-error"></p>
                    </div>

                    <div class="auth-field">
                        <label class="auth-label" for="reg-email">Email của bạn?</label>
                        <div class="auth-input-wrap">
                            <input class="auth-input" type="email" name="email" id="reg-email"
                                   autocomplete="email" placeholder="Nhập email của bạn"
                                   aria-describedby="reg-email-error"
                                   value="<c:out value='${regEmail}'/>" required/>
                            <button type="button" class="auth-input-btn auth-clear-btn"
                                    data-clear-for="reg-email" aria-label="Xóa nội dung email">
                                <span class="material-symbols-outlined" style="font-variation-settings:'FILL' 1;" aria-hidden="true">cancel</span>
                            </button>
                        </div>
                        <p class="auth-field-error" id="reg-email-error"></p>
                    </div>

                    <div class="auth-field">
                        <label class="auth-label" for="reg-fullname">Tên đầy đủ (*)</label>
                        <div class="auth-input-wrap">
                            <input class="auth-input" type="text" name="fullname" id="reg-fullname"
                                   autocomplete="name" maxlength="100" placeholder="Nhập họ và tên"
                                   aria-describedby="reg-fullname-error"
                                   value="<c:out value='${fullname}'/>" required/>
                            <button type="button" class="auth-input-btn auth-clear-btn"
                                    data-clear-for="reg-fullname" aria-label="Xóa nội dung họ và tên">
                                <span class="material-symbols-outlined" style="font-variation-settings:'FILL' 1;" aria-hidden="true">cancel</span>
                            </button>
                        </div>
                        <p class="auth-field-error" id="reg-fullname-error"></p>
                    </div>

                    <div class="auth-field">
                        <label class="auth-label" for="reg-pass">Mật khẩu (*)</label>
                        <div class="auth-input-wrap">
                            <input class="auth-input" type="password" name="password" id="reg-pass"
                                   autocomplete="new-password" placeholder="Nhập mật khẩu (*)"
                                   aria-describedby="reg-pass-hint reg-pass-error" required/>
                            <button type="button" class="auth-input-btn" data-toggle-password="reg-pass"
                                    aria-label="Hiện mật khẩu" title="Hiện mật khẩu">
                                <span class="material-symbols-outlined" aria-hidden="true">visibility_off</span>
                            </button>
                        </div>
                        <p class="auth-hint" id="reg-pass-hint">Tối thiểu 8 ký tự, gồm chữ hoa, chữ thường, số và ký tự đặc biệt.</p>
                        <p class="auth-field-error" id="reg-pass-error"></p>
                    </div>

                    <div class="auth-field">
                        <label class="auth-label" for="reg-confirm">Nhập lại mật khẩu (*)</label>
                        <div class="auth-input-wrap">
                            <input class="auth-input" type="password" name="confirm_password" id="reg-confirm"
                                   autocomplete="new-password" placeholder="Nhập lại mật khẩu"
                                   aria-describedby="reg-confirm-error" required/>
                            <button type="button" class="auth-input-btn" data-toggle-password="reg-confirm"
                                    aria-label="Hiện mật khẩu" title="Hiện mật khẩu">
                                <span class="material-symbols-outlined" aria-hidden="true">visibility_off</span>
                            </button>
                        </div>
                        <p class="auth-field-error" id="reg-confirm-error"></p>
                    </div>

                    <button type="submit" class="auth-btn-primary"
                            data-loading-text="ĐANG XỬ LÝ...">ĐĂNG KÝ</button>

                    <p class="auth-consent">
                        Bằng việc nhấn ĐĂNG KÝ, bạn đồng ý với điều khoản sử dụng
                        và chính sách bảo mật của V-SPORT.
                    </p>

                    <p class="auth-subline">
                        Bạn đã có tài khoản?
                        <a href="${ctx}/dangnhap">Đăng nhập</a>
                    </p>
                </form>
            </div>
        </div>
    </main>

    <script>
        (function () {
            'use strict';

            var form = document.getElementById('register-form');
            var phone = document.getElementById('reg-phone');
            var email = document.getElementById('reg-email');
            var fullname = document.getElementById('reg-fullname');
            var pass = document.getElementById('reg-pass');
            var confirm = document.getElementById('reg-confirm');

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

            // Validation client khớp với rule server (server vẫn validate lại đầy đủ)
            form.addEventListener('submit', function (e) {
                [phone, email, fullname, pass, confirm].forEach(function (inp) { setFieldError(inp, null); });
                var ok = true;

                var digits = phone.value.trim().replace(/[\s().-]/g, '');
                if (!/^(0|\+84|84)[35789][0-9]{8}$/.test(digits)) {
                    setFieldError(phone, 'Số điện thoại không hợp lệ. Ví dụ: 0786041209.');
                    ok = false;
                }

                var emailVal = email.value.trim();
                if (!/^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/.test(emailVal)) {
                    setFieldError(email, 'Email không hợp lệ và không được chứa khoảng trắng.');
                    ok = false;
                }

                var nameVal = fullname.value.trim();
                if (nameVal.length < 2 || nameVal.length > 100) {
                    setFieldError(fullname, 'Vui lòng nhập họ và tên hợp lệ (2-100 ký tự).');
                    ok = false;
                }

                if (!/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$/.test(pass.value)) {
                    setFieldError(pass, 'Mật khẩu chưa đủ mạnh: tối thiểu 8 ký tự, gồm chữ hoa, chữ thường, số và ký tự đặc biệt.');
                    ok = false;
                }

                if (pass.value !== confirm.value) {
                    setFieldError(confirm, 'Mật khẩu xác nhận không khớp.');
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
