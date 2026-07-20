<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!--
    Auth dropdown — CSS hoàn toàn tự chứa (không phụ thuộc Tailwind hay bất kỳ
    framework nào của trang chủ), vì component này được include ở nhiều trang
    có hệ thiết kế khác nhau (trang chủ mới: CSS thuần / DatSan.jsp: Tailwind CDN).
    Toàn bộ class bên dưới dùng tiền tố "authdd-" để không đụng CSS của trang chủ.
-->
<style>
    /* Bảng màu: chữ chính #111827, chữ phụ #6b7280, viền #e5e7eb, accent xanh
       đậm dùng rất tiết chế (underline tab / focus / nút chính). */
    #authdd-root, #authdd-root * { box-sizing: border-box; }
    #authdd-root {
        position: fixed;
        z-index: 9999;
        display: none;
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
    }
    #authdd-root.authdd-open { display: block; }

    /* Bất kỳ phần tử nào dùng attribute [hidden] trong dropdown đều phải ẩn
       tuyệt đối — tránh lặp lại lỗi banner rỗng vẫn hiện do class display:flex
       thắng UA stylesheet [hidden] (cùng specificity, CSS tác giả nạp sau). */
    #authdd-root [hidden] { display: none !important; }

    .authdd-card {
        width: 350px;
        max-width: calc(100vw - 16px);
        max-height: 85vh;
        background: #ffffff;
        border: 1px solid #e5e7eb;
        border-radius: 16px;
        box-shadow: 0 8px 24px rgba(17, 24, 39, 0.10);
        display: flex;
        flex-direction: column;
        position: relative;
        opacity: 0;
        transform: translateY(-6px);
        transition: opacity 180ms ease-out, transform 180ms ease-out;
        overflow: hidden;
    }
    .authdd-card.authdd-visible { opacity: 1; transform: translateY(0); }

    .authdd-close {
        position: absolute;
        top: 12px;
        right: 12px;
        width: 24px;
        height: 24px;
        border-radius: 50%;
        border: none;
        background: transparent;
        color: #9ca3af;
        display: flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        z-index: 5;
    }
    .authdd-close:hover { background: #f3f4f6; color: #6b7280; }

    .authdd-tabs {
        display: flex;
        align-items: center;
        gap: 20px;
        padding: 16px 20px 0;
        border-bottom: 1px solid #f1f2f4;
        flex-shrink: 0;
    }
    .authdd-tab {
        background: none; border: none; cursor: pointer;
        font-size: 13.5px; font-weight: 600; color: #9ca3af;
        padding-bottom: 10px; border-bottom: 2px solid transparent;
    }
    .authdd-tab.authdd-tab-active { color: #111827; border-bottom-color: var(--primary, #1677D2); }

    .authdd-body { padding: 18px 20px 20px; overflow-y: auto; }
    .authdd-body::-webkit-scrollbar { width: 6px; }
    .authdd-body::-webkit-scrollbar-thumb { background-color: #d1d5db; border-radius: 20px; }

    .authdd-panel { display: flex; flex-direction: column; }
    .authdd-panel[hidden] { display: none; }

    .authdd-heading { font-size: 14.5px; font-weight: 700; color: #111827; margin: 0 0 4px; }
    .authdd-subtext { font-size: 11.5px; color: #6b7280; font-weight: 500; margin: 0 0 14px; line-height: 1.5; }

    .authdd-field { margin-bottom: 12px; }
    .authdd-label { display: block; font-size: 11.5px; font-weight: 600; color: #374151; margin-bottom: 4px; }
    .authdd-input {
        width: 100%; height: 37px; padding: 0 12px;
        border: 1px solid #d1d5db; border-radius: 8px;
        font-size: 12.5px; font-weight: 500; color: #111827;
        background: #fff; outline: none;
        transition: border-color 150ms ease;
    }
    .authdd-input:focus { border-color: var(--primary, #1677D2); }
    .authdd-input::placeholder { color: #9ca3af; }

    .authdd-pass-wrap { position: relative; }
    .authdd-pass-wrap .authdd-input { padding-right: 36px; }
    .authdd-pass-toggle {
        position: absolute; right: 8px; top: 50%; transform: translateY(-50%);
        background: none; border: none; cursor: pointer; color: #9ca3af;
        display: flex; align-items: center; justify-content: center; padding: 4px;
    }
    .authdd-pass-toggle:hover { color: var(--primary, #1677D2); }

    .authdd-row-between { display: flex; align-items: center; justify-content: space-between; margin-bottom: 14px; }
    .authdd-checkbox-label { display: flex; align-items: center; gap: 6px; font-size: 11px; color: #6b7280; font-weight: 500; cursor: pointer; user-select: none; }
    .authdd-checkbox-label input { width: 14px; height: 14px; accent-color: var(--primary, #1677D2); }

    .authdd-link-btn { background: none; border: none; padding: 0; cursor: pointer; font-size: 11px; font-weight: 600; color: var(--primary, #1677D2); }
    .authdd-link-btn:hover { text-decoration: underline; }

    .authdd-strength { display: flex; gap: 4px; margin-top: 6px; }
    .authdd-strength div { height: 3px; flex: 1; border-radius: 2px; background: #e5e7eb; transition: background-color 250ms ease; }
    .authdd-hint { font-size: 9.5px; color: #9ca3af; line-height: 1.4; margin-top: 5px; }

    .authdd-agree { display: flex; align-items: flex-start; gap: 8px; margin-bottom: 14px; }
    .authdd-agree input { width: 14px; height: 14px; margin-top: 2px; accent-color: var(--primary, #1677D2); }
    .authdd-agree span { font-size: 10.5px; color: #6b7280; font-weight: 500; line-height: 1.4; }
    .authdd-agree a { color: var(--primary, #1677D2); font-weight: 600; }

    .authdd-btn {
        width: 100%; height: 37px; border: none; border-radius: 8px;
        background: var(--primary, #1677D2); color: var(--dark, #111827); font-size: 13px; font-weight: 600;
        cursor: pointer; position: relative; overflow: hidden;
        display: flex; align-items: center; justify-content: center; gap: 8px;
        transition: background-color 150ms ease;
    }
    .authdd-btn:hover { background: var(--primary-hover, #185A9D); }
    .authdd-btn:disabled { cursor: wait; opacity: 0.85; }
    .authdd-btn-loading {
        position: absolute; inset: 0; background: var(--primary-hover, #185A9D); color: var(--dark, #111827);
        display: none; align-items: center; justify-content: center; gap: 8px;
    }
    .authdd-btn-loading.authdd-show { display: flex; }
    .authdd-spinner {
        width: 14px; height: 14px; border-radius: 50%;
        border: 2px solid rgba(17, 24, 39, 0.2); border-top-color: var(--dark, #111827);
        animation: authdd-spin 0.7s linear infinite;
    }
    @keyframes authdd-spin { to { transform: rotate(360deg); } }

    /* ── Redirect overlay ── */
    #authdd-redirect-overlay {
        position: fixed; inset: 0; z-index: 99999;
        background: rgba(255,255,255,0.96);
        backdrop-filter: blur(6px);
        display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 20px;
        opacity: 0; pointer-events: none;
        transition: opacity 280ms ease;
    }
    #authdd-redirect-overlay.authdd-redir-show { opacity: 1; pointer-events: all; }

    .authdd-redir-circle {
        width: 72px; height: 72px; border-radius: 50%;
        background: #16A36A;
        display: flex; align-items: center; justify-content: center;
        transform: scale(0.4); opacity: 0;
        transition: transform 380ms cubic-bezier(0.34,1.56,0.64,1), opacity 280ms ease;
    }
    #authdd-redirect-overlay.authdd-redir-show .authdd-redir-circle {
        transform: scale(1); opacity: 1;
    }
    .authdd-redir-circle svg { width: 36px; height: 36px; }
    .authdd-redir-checkpath {
        stroke-dasharray: 52; stroke-dashoffset: 52;
        transition: stroke-dashoffset 420ms ease 320ms;
    }
    #authdd-redirect-overlay.authdd-redir-show .authdd-redir-checkpath {
        stroke-dashoffset: 0;
    }

    .authdd-redir-texts { text-align: center; }
    .authdd-redir-title {
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
        font-size: 18px; font-weight: 700; color: #111827;
        opacity: 0; transform: translateY(8px);
        transition: opacity 300ms ease 200ms, transform 300ms ease 200ms;
    }
    #authdd-redirect-overlay.authdd-redir-show .authdd-redir-title { opacity: 1; transform: translateY(0); }
    .authdd-redir-sub {
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
        font-size: 13px; color: #6b7280; margin-top: 4px;
        opacity: 0; transform: translateY(6px);
        transition: opacity 300ms ease 350ms, transform 300ms ease 350ms;
    }
    #authdd-redirect-overlay.authdd-redir-show .authdd-redir-sub { opacity: 1; transform: translateY(0); }

    .authdd-redir-bar {
        width: 160px; height: 3px; background: #e5e7eb; border-radius: 99px; overflow: hidden;
        opacity: 0; transition: opacity 200ms ease 400ms;
    }
    #authdd-redirect-overlay.authdd-redir-show .authdd-redir-bar { opacity: 1; }
    .authdd-redir-bar-fill {
        height: 100%; width: 0; background: #16A36A; border-radius: 99px;
        transition: width 900ms cubic-bezier(0.4,0,0.2,1) 450ms;
    }
    #authdd-redirect-overlay.authdd-redir-show .authdd-redir-bar-fill { width: 100%; }

    /* Alert: chỉ hiện khi có nội dung thật (điều khiển bằng [hidden] ở JS),
       nền rất nhạt + chữ nhỏ, không viền đậm để tránh nặng mắt. */
    .authdd-banner {
        display: flex; align-items: center; gap: 7px;
        padding: 8px 10px; border-radius: 8px; font-size: 11px; font-weight: 500;
        margin-bottom: 12px;
    }
    .authdd-banner-error { background: #fef2f2; color: #b91c1c; }
    .authdd-banner-success { background: #f0fdf4; color: #15803d; }

    .authdd-divider { display: flex; align-items: center; gap: 10px; margin: 14px 0; }
    .authdd-divider::before, .authdd-divider::after { content: ''; flex: 1; height: 1px; background: #e5e7eb; }
    .authdd-divider span { font-size: 10.5px; color: #9ca3af; font-weight: 500; }

    .authdd-google-btn {
        width: 100%; height: 35px; border-radius: 8px; border: 1px solid #e5e7eb; background: #fff;
        display: flex; align-items: center; justify-content: center; gap: 7px;
        font-size: 11.5px; font-weight: 500; color: #4b5563; cursor: pointer;
    }
    .authdd-google-btn:hover { background: #f9fafb; border-color: #d1d5db; }

    .authdd-footnote { text-align: center; border-top: 1px solid #f1f2f4; padding-top: 12px; margin-top: 14px; font-size: 11.5px; color: #6b7280; font-weight: 500; }

    .authdd-otp-input {
        width: 100%; height: 44px; text-align: center; font-size: 19px; font-weight: 600; letter-spacing: 0.3em;
        border: 1px solid #d1d5db; border-radius: 8px; outline: none; color: #111827;
    }
    .authdd-otp-input:focus { border-color: var(--primary, #1677D2); }

    .authdd-back-link { display: flex; align-items: center; justify-content: center; gap: 4px; }
</style>

<!-- Redirect success overlay -->
<div id="authdd-redirect-overlay">
    <div class="authdd-redir-circle">
        <svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
            <polyline class="authdd-redir-checkpath" points="4,13 9,18 20,7"
                stroke="#111827" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
        </svg>
    </div>
    <div class="authdd-redir-texts">
        <p class="authdd-redir-title">Đăng nhập thành công!</p>
        <p class="authdd-redir-sub">Đang chuyển trang cho bạn...</p>
    </div>
    <div class="authdd-redir-bar"><div class="authdd-redir-bar-fill"></div></div>
</div>

<div id="authdd-root">
    <div id="authdd-card" class="authdd-card">
        <button type="button" class="authdd-close" onclick="closeAuthModal()" aria-label="Đóng">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
        </button>

        <div id="authdd-tabs" class="authdd-tabs">
            <button type="button" id="authdd-tab-login" class="authdd-tab authdd-tab-active" onclick="switchAuthTab('login')">Đăng nhập</button>
            <button type="button" id="authdd-tab-register" class="authdd-tab" onclick="switchAuthTab('register')">Đăng ký</button>
        </div>

        <div class="authdd-body">

            <!-- LOGIN -->
            <div id="modal-login-panel" class="authdd-panel">
                <div id="login-error-banner" class="authdd-banner authdd-banner-error" hidden><span class="error-msg"></span></div>
                <div id="login-success-banner" class="authdd-banner authdd-banner-success" hidden><span class="success-msg"></span></div>

                <form id="modal-login-form" action="${pageContext.request.contextPath}/dangnhap" method="POST" autocomplete="off" onsubmit="submitLoginForm(event)">
                    <input type="hidden" name="loginType" value="customer">
                    <div class="authdd-field">
                        <label class="authdd-label">Tên đăng nhập hoặc email</label>
                        <input type="text" name="username" id="modal-login-username" required placeholder="Nhập tên đăng nhập hoặc email" class="authdd-input">
                    </div>
                    <div class="authdd-field">
                        <label class="authdd-label">Mật khẩu</label>
                        <div class="authdd-pass-wrap">
                            <input type="password" name="password" id="modal-login-pass" required placeholder="Nhập mật khẩu" class="authdd-input">
                            <button type="button" class="authdd-pass-toggle" onclick="togglePassField('modal-login-pass', this)">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-7 11-7 11 7 11 7-4 7-11 7-11-7-11-7Z"/><circle cx="12" cy="12" r="3"/></svg>
                            </button>
                        </div>
                    </div>
                    <div class="authdd-row-between">
                        <label class="authdd-checkbox-label"><input type="checkbox" name="rememberMe"> Ghi nhớ 7 ngày</label>
                        <button type="button" class="authdd-link-btn" onclick="switchAuthTab('forgot-password')">Quên mật khẩu?</button>
                    </div>
                    <button type="submit" id="modal-login-btn" class="authdd-btn">
                        <span class="btn-text">Đăng nhập</span>
                        <span class="btn-loading authdd-btn-loading"><span class="authdd-spinner"></span><span class="btn-loading-text">Đang đăng nhập...</span></span>
                    </button>
                </form>

                <%-- Google OAuth chưa tích hợp thật -> ẩn theo yêu cầu (brief mục 14).
                     TODO: bật lại khi OAuth Google hoạt động.
                <div class="authdd-divider"><span>hoặc</span></div>
                <button type="button" class="authdd-google-btn" title="Chưa tích hợp OAuth thật">Tiếp tục với Google</button>
                --%>

                <div class="authdd-footnote">Chưa có tài khoản? <button type="button" class="authdd-link-btn" onclick="switchAuthTab('register')">Tạo tài khoản</button></div>
            </div>

            <!-- REGISTER -->
            <div id="modal-register-panel" class="authdd-panel" hidden>
                <div id="register-error-banner" class="authdd-banner authdd-banner-error" hidden><span class="error-msg"></span></div>

                <form id="modal-register-form" action="${pageContext.request.contextPath}/dangky" method="POST" autocomplete="off" onsubmit="submitRegisterForm(event)">
                    <input type="hidden" name="gender" value="Khác">

                    <div class="authdd-field">
                        <label class="authdd-label">Họ và tên</label>
                        <input type="text" name="fullname" required placeholder="Nhập họ và tên" class="authdd-input">
                    </div>
                    <div class="authdd-field">
                        <label class="authdd-label">Email</label>
                        <input type="email" name="email" required placeholder="Địa chỉ email" class="authdd-input">
                    </div>
                    <div class="authdd-field">
                        <label class="authdd-label">Số điện thoại</label>
                        <input type="tel" name="phone" required placeholder="Nhập số điện thoại" class="authdd-input">
                    </div>
                    <div class="authdd-field">
                        <label class="authdd-label">Mật khẩu</label>
                        <div class="authdd-pass-wrap">
                            <input type="password" name="password" id="modal-reg-pass" required placeholder="Tạo mật khẩu" oninput="updateModalPwStrength(this)" class="authdd-input">
                            <button type="button" class="authdd-pass-toggle" onclick="togglePassField('modal-reg-pass', this)">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-7 11-7 11 7 11 7-4 7-11 7-11-7-11-7Z"/><circle cx="12" cy="12" r="3"/></svg>
                            </button>
                        </div>
                        <div class="authdd-strength">
                            <div id="modalRegStr1"></div><div id="modalRegStr2"></div><div id="modalRegStr3"></div><div id="modalRegStr4"></div>
                        </div>
                        <p class="authdd-hint">Tối thiểu 8 ký tự, gồm chữ hoa, thường, số và ký tự đặc biệt.</p>
                    </div>
                    <div class="authdd-field">
                        <label class="authdd-label">Xác nhận mật khẩu</label>
                        <div class="authdd-pass-wrap">
                            <input type="password" name="confirm_password" id="modal-reg-confirm" required placeholder="Nhập lại mật khẩu" class="authdd-input">
                            <button type="button" class="authdd-pass-toggle" onclick="togglePassField('modal-reg-confirm', this)">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-7 11-7 11 7 11 7-4 7-11 7-11-7-11-7Z"/><circle cx="12" cy="12" r="3"/></svg>
                            </button>
                        </div>
                    </div>

                    <div class="authdd-agree">
                        <input type="checkbox" name="agree" value="Đồng ý" required>
                        <span>Tôi đồng ý với <a href="#">điều khoản</a> và <a href="#">chính sách</a>.</span>
                    </div>
                    <button type="submit" id="modal-register-btn" class="authdd-btn">
                        <span class="btn-text">Tạo tài khoản</span>
                        <span class="loading-spinner authdd-btn-loading"><span class="authdd-spinner"></span><span>Đang gửi OTP...</span></span>
                    </button>
                </form>

                <div class="authdd-footnote">Đã có tài khoản? <button type="button" class="authdd-link-btn" onclick="switchAuthTab('login')">Đăng nhập ngay</button></div>
            </div>

            <!-- FORGOT PASSWORD -->
            <div id="modal-forgot-password-panel" class="authdd-panel" hidden>
                <h2 class="authdd-heading">Quên mật khẩu?</h2>
                <p class="authdd-subtext">Nhập email đã đăng ký để khôi phục mật khẩu.</p>
                <div id="forgot-password-error-banner" class="authdd-banner authdd-banner-error" hidden><span class="error-msg"></span></div>
                <form id="modal-forgot-password-form" action="${pageContext.request.contextPath}/quenmatkhau" method="POST" autocomplete="off" onsubmit="submitForgotPasswordForm(event)">
                    <div class="authdd-field">
                        <label class="authdd-label">Email đã đăng ký</label>
                        <input type="email" name="email" required placeholder="Nhập địa chỉ email" class="authdd-input">
                    </div>
                    <button type="submit" id="modal-forgot-password-btn" class="authdd-btn">
                        <span class="btn-text">Gửi mã xác thực</span>
                        <span class="loading-spinner authdd-btn-loading"><span class="authdd-spinner"></span><span>Đang gửi mã...</span></span>
                    </button>
                </form>
                <div class="authdd-footnote">Nhớ lại mật khẩu? <button type="button" class="authdd-link-btn" onclick="switchAuthTab('login')">Đăng nhập</button></div>
            </div>

            <!-- OTP -->
            <div id="modal-otp-panel" class="authdd-panel" hidden>
                <h2 class="authdd-heading">Xác thực OTP</h2>
                <p class="authdd-subtext">Nhập mã 6 chữ số đã gửi tới <b id="otp-email-display"></b>.</p>
                <div id="otp-error-banner" class="authdd-banner authdd-banner-error" hidden><span class="error-msg"></span></div>
                <div id="otp-success-banner" class="authdd-banner authdd-banner-success" hidden><span class="success-msg"></span></div>
                <form id="modal-otp-form" action="${pageContext.request.contextPath}/nhapma" method="POST" autocomplete="off" onsubmit="submitOtpForm(event)">
                    <input type="hidden" name="email" id="otp-hidden-email">
                    <div class="authdd-field">
                        <label class="authdd-label">Mã OTP 6 chữ số</label>
                        <input type="text" name="otp" required maxlength="6" placeholder="••••••" class="authdd-otp-input">
                    </div>
                    <button type="submit" id="modal-otp-btn" class="authdd-btn">
                        <span class="btn-text">Xác minh OTP</span>
                        <span class="loading-spinner authdd-btn-loading"><span class="authdd-spinner"></span><span>Đang xác thực...</span></span>
                    </button>
                </form>
                <div class="authdd-footnote" style="display:flex;flex-direction:column;gap:6px;">
                    <div>Không nhận được mã? <button type="button" class="authdd-link-btn" onclick="resendOtp()">Gửi lại</button></div>
                    <button type="button" class="authdd-link-btn authdd-back-link" onclick="goBackFromOtp()">← Quay lại</button>
                </div>
            </div>

            <!-- RESET PASSWORD -->
            <div id="modal-reset-password-panel" class="authdd-panel" hidden>
                <h2 class="authdd-heading">Mật khẩu mới</h2>
                <p class="authdd-subtext">Tạo mật khẩu mới cho tài khoản của bạn.</p>
                <div id="reset-password-error-banner" class="authdd-banner authdd-banner-error" hidden><span class="error-msg"></span></div>
                <form id="modal-reset-password-form" action="${pageContext.request.contextPath}/nhapmatkhaumoi" method="POST" onsubmit="submitResetPasswordForm(event)">
                    <div class="authdd-field">
                        <label class="authdd-label">Mật khẩu mới</label>
                        <div class="authdd-pass-wrap">
                            <input type="password" name="password" id="modal-new-pass" required placeholder="••••••••" oninput="updateModalResetPwStrength(this)" class="authdd-input">
                            <button type="button" class="authdd-pass-toggle" onclick="togglePassField('modal-new-pass', this)">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-7 11-7 11 7 11 7-4 7-11 7-11-7-11-7Z"/><circle cx="12" cy="12" r="3"/></svg>
                            </button>
                        </div>
                        <div class="authdd-strength">
                            <div id="modalResetStr1"></div><div id="modalResetStr2"></div><div id="modalResetStr3"></div><div id="modalResetStr4"></div>
                        </div>
                    </div>
                    <div class="authdd-field">
                        <label class="authdd-label">Xác nhận mật khẩu mới</label>
                        <div class="authdd-pass-wrap">
                            <input type="password" name="confirm_password" id="modal-new-confirm" required placeholder="••••••••" class="authdd-input">
                            <button type="button" class="authdd-pass-toggle" onclick="togglePassField('modal-new-confirm', this)">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-7 11-7 11 7 11 7-4 7-11 7-11-7-11-7Z"/><circle cx="12" cy="12" r="3"/></svg>
                            </button>
                        </div>
                    </div>
                    <button type="submit" id="modal-reset-password-btn" class="authdd-btn">
                        <span class="btn-text">Lưu mật khẩu mới</span>
                        <span class="loading-spinner authdd-btn-loading"><span class="authdd-spinner"></span><span>Đang cập nhật...</span></span>
                    </button>
                </form>
            </div>

        </div>
    </div>
</div>

<script>
    let otpSourceTab = 'login';
    let authTriggerEl = null;

    function resolveDefaultTrigger() {
        return document.getElementById('header-user-btn') || document.querySelector('.btn-register-shimmer');
    }

    function positionAuthModal(triggerEl) {
        const root = document.getElementById('authdd-root');
        const trigger = triggerEl || resolveDefaultTrigger();
        const cardWidth = 350;
        let top, right;
        if (trigger) {
            const rect = trigger.getBoundingClientRect();
            top = rect.bottom + 8;
            right = Math.max(8, window.innerWidth - rect.right);
        } else {
            top = 70; right = 24;
        }
        if (window.innerWidth - right - cardWidth < 8) {
            right = Math.max(8, window.innerWidth - cardWidth - 8);
        }
        root.style.top = top + 'px';
        root.style.right = right + 'px';
    }

    function openAuthModal(tab, triggerEl) {
        if (!tab) tab = 'login';
        const root = document.getElementById('authdd-root');
        const card = document.getElementById('authdd-card');
        if (!root || !card) return;
        authTriggerEl = triggerEl || resolveDefaultTrigger();
        clearModalAlerts();
        positionAuthModal(authTriggerEl);
        root.classList.add('authdd-open');
        requestAnimationFrame(() => { card.classList.add('authdd-visible'); });
        showAuthTabPanel(tab);
    }

    function closeAuthModal() {
        setLoginFormLoading(false);
        const root = document.getElementById('authdd-root');
        const card = document.getElementById('authdd-card');
        if (!root || !card) return;
        card.classList.remove('authdd-visible');
        setTimeout(() => { root.classList.remove('authdd-open'); }, 180);
    }

    // Dùng capture phase để không bị chặn bởi stopPropagation() nội bộ của
    // các thư viện bên thứ 3 (vd. Swiper chặn click trên slide ở bubble phase).
    document.addEventListener('click', (e) => {
        const root = document.getElementById('authdd-root');
        if (!root || !root.classList.contains('authdd-open')) return;
        const card = document.getElementById('authdd-card');
        if (card && card.contains(e.target)) return;
        if (authTriggerEl && authTriggerEl.contains(e.target)) return;
        closeAuthModal();
    }, true);

    document.addEventListener('keydown', (e) => {
        if (e.key !== 'Escape') return;
        const root = document.getElementById('authdd-root');
        if (root && root.classList.contains('authdd-open')) closeAuthModal();
    });

    const AUTHDD_PANEL_MAP = {
        'login': 'modal-login-panel',
        'register': 'modal-register-panel',
        'forgot-password': 'modal-forgot-password-panel',
        'otp': 'modal-otp-panel',
        'reset-password': 'modal-reset-password-panel'
    };

    function showAuthTabPanel(tab) {
        Object.values(AUTHDD_PANEL_MAP).forEach(id => {
            const el = document.getElementById(id);
            if (el) el.hidden = true;
        });
        const target = document.getElementById(AUTHDD_PANEL_MAP[tab]);
        if (target) target.hidden = false;

        const tabs = document.getElementById('authdd-tabs');
        const tabLogin = document.getElementById('authdd-tab-login');
        const tabRegister = document.getElementById('authdd-tab-register');
        if (tab === 'login' || tab === 'register') {
            if (tabs) tabs.style.display = 'flex';
            if (tabLogin) tabLogin.classList.toggle('authdd-tab-active', tab === 'login');
            if (tabRegister) tabRegister.classList.toggle('authdd-tab-active', tab === 'register');
        } else {
            if (tabs) tabs.style.display = 'none';
        }
    }

    function switchAuthTab(tab) {
        if (tab === 'otp') {
            const current = Object.entries(AUTHDD_PANEL_MAP).find(([k, id]) => {
                const el = document.getElementById(id);
                return el && !el.hidden;
            });
            if (current && (current[0] === 'forgot-password' || current[0] === 'register')) {
                otpSourceTab = current[0];
            }
        }
        clearModalAlerts();
        showAuthTabPanel(tab);
    }

    function goBackFromOtp() { switchAuthTab(otpSourceTab); }

    function clearModalAlerts() {
        ['login-error-banner','login-success-banner','register-error-banner','forgot-password-error-banner','otp-error-banner','otp-success-banner','reset-password-error-banner'].forEach(id => {
            const el = document.getElementById(id);
            if (el) el.hidden = true;
        });
    }

    function togglePassField(id, btn) {
        const input = document.getElementById(id);
        if (input) input.type = input.type === 'password' ? 'text' : 'password';
    }

    function computeStrength(v) {
        let s = 0;
        if (v.length >= 8) s++; if (/[A-Z]/.test(v)) s++; if (/[a-z]/.test(v)) s++;
        if (/[0-9]/.test(v)) s++; if (/[^A-Za-z0-9]/.test(v)) s++;
        let strength = 0;
        if (v.length > 0) strength = 1; if (s >= 3) strength = 2; if (s >= 4) strength = 3; if (s >= 5) strength = 4;
        return strength;
    }

    function paintStrength(prefix, strength) {
        const cols = ['#f43f5e','#f59e0b','#8b5cf6','#10b981'];
        for (let i = 1; i <= 4; i++) {
            const el = document.getElementById(prefix + i);
            if (el) el.style.backgroundColor = i <= strength ? cols[strength-1] : '#e2e8f0';
        }
    }

    function updateModalPwStrength(inp) { paintStrength('modalRegStr', computeStrength(inp.value)); }
    function updateModalResetPwStrength(inp) { paintStrength('modalResetStr', computeStrength(inp.value)); }

    function setLoginFormLoading(isLoading, message) {
        if (!message) message = 'Đang đăng nhập...';
        const form = document.getElementById('modal-login-form');
        const btn = document.getElementById('modal-login-btn');
        const btnText = btn ? btn.querySelector('.btn-text') : null;
        const btnLoading = btn ? btn.querySelector('.btn-loading') : null;
        const btnLoadingText = btn ? btn.querySelector('.btn-loading-text') : null;
        if (btnLoadingText) btnLoadingText.textContent = message;

        if (isLoading) {
            if (btn) { btn.disabled = true; }
            if (btnText) btnText.style.visibility = 'hidden';
            if (btnLoading) btnLoading.classList.add('authdd-show');
            if (form) {
                form.querySelectorAll('button[type="button"]').forEach(el => { el.disabled = true; });
            }
        } else {
            if (btn) { btn.disabled = false; }
            if (btnText) btnText.style.visibility = 'visible';
            if (btnLoading) btnLoading.classList.remove('authdd-show');
            if (form) {
                form.querySelectorAll('button[type="button"]').forEach(el => { el.disabled = false; });
            }
        }
    }

    function submitLoginForm(event) {
        event.preventDefault();
        const form = document.getElementById('modal-login-form');
        const errorBanner = document.getElementById('login-error-banner');
        const successBanner = document.getElementById('login-success-banner');
        if (errorBanner) errorBanner.hidden = true;
        if (successBanner) successBanner.hidden = true;

        const searchParams = new URLSearchParams(new FormData(form));
        setLoginFormLoading(true, 'Đang đăng nhập...');

        fetch(form.action, {
            method: 'POST',
            headers: { 'Accept': 'application/json', 'X-Requested-With': 'XMLHttpRequest', 'Content-Type': 'application/x-www-form-urlencoded' },
            body: searchParams
        })
        .then(res => res.json())
        .then(data => {
            if (data.success) {
                setLoginFormLoading(false);
                closeAuthModal();
                const overlay = document.getElementById('authdd-redirect-overlay');
                if (overlay) {
                    overlay.classList.add('authdd-redir-show');
                }
                setTimeout(() => { window.location.href = data.redirectUrl; }, 1200);
            } else {
                setLoginFormLoading(false);
                if (errorBanner) { errorBanner.querySelector('.error-msg').textContent = data.loi || 'Đăng nhập không thành công.'; errorBanner.hidden = false; }
            }
        })
        .catch(err => {
            console.error('Lỗi login AJAX:', err);
            setLoginFormLoading(false);
            if (errorBanner) { errorBanner.querySelector('.error-msg').textContent = 'Có lỗi mạng xảy ra. Vui lòng thử lại!'; errorBanner.hidden = false; }
        });
    }

    function submitRegisterForm(event) {
        event.preventDefault();
        const form = document.getElementById('modal-register-form');
        const btn = document.getElementById('modal-register-btn');
        const btnText = btn.querySelector('.btn-text');
        const spinner = btn.querySelector('.loading-spinner');
        const errorBanner = document.getElementById('register-error-banner');
        if (errorBanner) errorBanner.hidden = true;

        const email = form.email.value.trim();
        const phone = form.phone.value.trim();
        const password = document.getElementById('modal-reg-pass').value;
        const confirmPassword = document.getElementById('modal-reg-confirm').value;

        function showError(msg) {
            if (errorBanner) { errorBanner.querySelector('.error-msg').textContent = msg; errorBanner.hidden = false; }
        }

        if (email.indexOf(' ') >= 0) { showError("Email không được chứa khoảng trắng!"); return; }
        if (!/^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/.test(email)) { showError("Định dạng Email không hợp lệ!"); return; }
        if (!/^(0|\+84)[35789][0-9]{8}$/.test(phone)) { showError("Số điện thoại không hợp lệ (Phải bắt đầu bằng 0 hoặc +84 và có 10 số)!"); return; }
        if (password !== confirmPassword) { showError("Mật khẩu xác nhận không khớp!"); return; }
        if (!/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$/.test(password)) { showError("Mật khẩu không đủ mạnh! Phải có tối thiểu 8 ký tự, bao gồm chữ hoa, chữ thường, số và ký tự đặc biệt."); return; }

        if (spinner) spinner.classList.add('authdd-show');
        if (btnText) btnText.style.visibility = 'hidden';
        if (btn) btn.disabled = true;

        fetch(form.action, {
            method: 'POST',
            headers: { 'Accept': 'application/json', 'X-Requested-With': 'XMLHttpRequest', 'Content-Type': 'application/x-www-form-urlencoded' },
            body: new URLSearchParams(new FormData(form))
        })
        .then(res => res.json())
        .then(data => {
            if (data.success) {
                if (data.step === 'otp') {
                    const displayEl = document.getElementById('otp-email-display');
                    const hiddenEmailEl = document.getElementById('otp-hidden-email');
                    if (displayEl) displayEl.textContent = data.email;
                    if (hiddenEmailEl) hiddenEmailEl.value = data.email;
                    if (spinner) spinner.classList.remove('authdd-show');
                    if (btnText) btnText.style.visibility = 'visible';
                    if (btn) btn.disabled = false;
                    const otpSuccessBanner = document.getElementById('otp-success-banner');
                    if (otpSuccessBanner) { otpSuccessBanner.querySelector('.success-msg').textContent='Đăng ký thông tin thành công! Vui lòng nhập mã OTP để kích hoạt.'; otpSuccessBanner.hidden = false; }
                    switchAuthTab('otp');
                } else {
                    window.location.href = data.redirectUrl;
                }
            } else {
                if (spinner) spinner.classList.remove('authdd-show');
                if (btnText) btnText.style.visibility = 'visible';
                if (btn) btn.disabled = false;
                if (errorBanner) { errorBanner.querySelector('.error-msg').textContent = data.loi || 'Đăng ký không thành công.'; errorBanner.hidden = false; }
            }
        })
        .catch(err => {
            console.error('Lỗi register AJAX:', err);
            if (spinner) spinner.classList.remove('authdd-show');
            if (btnText) btnText.style.visibility = 'visible';
            if (btn) btn.disabled = false;
            if (errorBanner) { errorBanner.querySelector('.error-msg').textContent='Có lỗi mạng xảy ra. Vui lòng thử lại!'; errorBanner.hidden = false; }
        });
    }

    function submitForgotPasswordForm(event) {
        event.preventDefault();
        const form = document.getElementById('modal-forgot-password-form');
        const btn = document.getElementById('modal-forgot-password-btn');
        const btnText = btn.querySelector('.btn-text');
        const spinner = btn.querySelector('.loading-spinner');
        const errorBanner = document.getElementById('forgot-password-error-banner');
        if (errorBanner) errorBanner.hidden = true;
        const formData = new FormData(form);
        const email = formData.get('email');
        if (spinner) spinner.classList.add('authdd-show');
        if (btnText) btnText.style.visibility = 'hidden';
        if (btn) btn.disabled = true;
        fetch(form.action, {
            method: 'POST',
            headers: { 'Accept': 'application/json', 'X-Requested-With': 'XMLHttpRequest', 'Content-Type': 'application/x-www-form-urlencoded' },
            body: new URLSearchParams(formData)
        })
        .then(res => res.json())
        .then(data => {
            if (spinner) spinner.classList.remove('authdd-show');
            if (btnText) btnText.style.visibility = 'visible';
            if (btn) btn.disabled = false;
            if (data.success) {
                const displayEl = document.getElementById('otp-email-display');
                const hiddenEmailEl = document.getElementById('otp-hidden-email');
                if (displayEl) displayEl.textContent = email;
                if (hiddenEmailEl) hiddenEmailEl.value = email;
                const otpSuccessBanner = document.getElementById('otp-success-banner');
                if (otpSuccessBanner) { otpSuccessBanner.querySelector('.success-msg').textContent='Mã OTP đã được gửi đến email của bạn!'; otpSuccessBanner.hidden = false; }
                switchAuthTab('otp');
            } else {
                if (errorBanner) { errorBanner.querySelector('.error-msg').textContent=data.loi||'Có lỗi xảy ra.'; errorBanner.hidden = false; }
            }
        })
        .catch(err => {
            console.error('Lỗi Forgot Password AJAX:', err);
            if (spinner) spinner.classList.remove('authdd-show');
            if (btnText) btnText.style.visibility = 'visible';
            if (btn) btn.disabled = false;
            if (errorBanner) { errorBanner.querySelector('.error-msg').textContent='Có lỗi mạng xảy ra. Vui lòng thử lại!'; errorBanner.hidden = false; }
        });
    }

    function submitOtpForm(event) {
        event.preventDefault();
        const form = document.getElementById('modal-otp-form');
        const btn = document.getElementById('modal-otp-btn');
        const btnText = btn.querySelector('.btn-text');
        const spinner = btn.querySelector('.loading-spinner');
        const errorBanner = document.getElementById('otp-error-banner');
        const successBanner = document.getElementById('otp-success-banner');
        if (errorBanner) errorBanner.hidden = true;
        if (successBanner) successBanner.hidden = true;
        if (spinner) spinner.classList.add('authdd-show');
        if (btnText) btnText.style.visibility = 'hidden';
        if (btn) btn.disabled = true;
        fetch(form.action, {
            method: 'POST',
            headers: { 'Accept': 'application/json', 'X-Requested-With': 'XMLHttpRequest', 'Content-Type': 'application/x-www-form-urlencoded' },
            body: new URLSearchParams(new FormData(form))
        })
        .then(res => res.json())
        .then(data => {
            if (spinner) spinner.classList.remove('authdd-show');
            if (btnText) btnText.style.visibility = 'visible';
            if (btn) btn.disabled = false;
            if (data.success) {
                if (data.step === 'reset-password') { switchAuthTab('reset-password'); }
                else if (data.step === 'register-success') {
                    switchAuthTab('login');
                    const loginSuccessBanner = document.getElementById('login-success-banner');
                    if (loginSuccessBanner) { loginSuccessBanner.querySelector('.success-msg').textContent=data.thongbao||'Đăng ký thành công! Vui lòng đăng nhập.'; loginSuccessBanner.hidden = false; }
                }
            } else {
                if (errorBanner) { errorBanner.querySelector('.error-msg').textContent=data.loi||'Mã xác thực không đúng.'; errorBanner.hidden = false; }
            }
        })
        .catch(err => {
            console.error('Lỗi Verify OTP AJAX:', err);
            if (spinner) spinner.classList.remove('authdd-show');
            if (btnText) btnText.style.visibility = 'visible';
            if (btn) btn.disabled = false;
            if (errorBanner) { errorBanner.querySelector('.error-msg').textContent='Có lỗi mạng xảy ra. Vui lòng thử lại!'; errorBanner.hidden = false; }
        });
    }

    function resendOtp() {
        const errorBanner = document.getElementById('otp-error-banner');
        const successBanner = document.getElementById('otp-success-banner');
        const emailInput = document.getElementById('otp-hidden-email');
        if (errorBanner) errorBanner.hidden = true;
        if (successBanner) successBanner.hidden = true;
        if (!emailInput || !emailInput.value) {
            if (errorBanner) { errorBanner.querySelector('.error-msg').textContent='Không tìm thấy email để gửi lại mã!'; errorBanner.hidden = false; }
            return;
        }
        const params = new URLSearchParams();
        params.append('email', emailInput.value);
        fetch('${pageContext.request.contextPath}/resend-otp', {
            method: 'POST',
            headers: { 'Accept': 'application/json', 'X-Requested-With': 'XMLHttpRequest', 'Content-Type': 'application/x-www-form-urlencoded' },
            body: params
        })
        .then(res => res.json())
        .then(data => {
            if (data.success) {
                if (successBanner) { successBanner.querySelector('.success-msg').textContent=data.thongbao||'Gửi lại mã OTP thành công!'; successBanner.hidden = false; }
            } else {
                if (errorBanner) { errorBanner.querySelector('.error-msg').textContent=data.loi||'Không thể gửi lại mã OTP.'; errorBanner.hidden = false; }
            }
        })
        .catch(err => {
            console.error('Lỗi Resend OTP:', err);
            if (errorBanner) { errorBanner.querySelector('.error-msg').textContent='Có lỗi mạng xảy ra. Vui lòng thử lại!'; errorBanner.hidden = false; }
        });
    }

    function submitResetPasswordForm(event) {
        event.preventDefault();
        const form = document.getElementById('modal-reset-password-form');
        const btn = document.getElementById('modal-reset-password-btn');
        const btnText = btn.querySelector('.btn-text');
        const spinner = btn.querySelector('.loading-spinner');
        const errorBanner = document.getElementById('reset-password-error-banner');
        if (errorBanner) errorBanner.hidden = true;
        const p1 = document.getElementById('modal-new-pass').value;
        const p2 = document.getElementById('modal-new-confirm').value;
        if (p1.trim() === '') { if (errorBanner) { errorBanner.querySelector('.error-msg').textContent='Mật khẩu không được để trống hoặc chỉ chứa khoảng trắng!'; errorBanner.hidden = false; } return; }
        if (!/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$/.test(p1)) { if (errorBanner) { errorBanner.querySelector('.error-msg').textContent='Mật khẩu phải có tối thiểu 8 ký tự, bao gồm cả chữ hoa, chữ thường, số và ký tự đặc biệt.'; errorBanner.hidden = false; } return; }
        if (p1 !== p2) { if (errorBanner) { errorBanner.querySelector('.error-msg').textContent='Mật khẩu xác nhận chưa trùng khớp!'; errorBanner.hidden = false; } return; }
        if (spinner) spinner.classList.add('authdd-show');
        if (btnText) btnText.style.visibility = 'hidden';
        if (btn) btn.disabled = true;
        fetch(form.action, {
            method: 'POST',
            headers: { 'Accept': 'application/json', 'X-Requested-With': 'XMLHttpRequest', 'Content-Type': 'application/x-www-form-urlencoded' },
            body: new URLSearchParams(new FormData(form))
        })
        .then(res => res.json())
        .then(data => {
            if (spinner) spinner.classList.remove('authdd-show');
            if (btnText) btnText.style.visibility = 'visible';
            if (btn) btn.disabled = false;
            if (data.success) {
                switchAuthTab('login');
                const loginSuccessBanner = document.getElementById('login-success-banner');
                if (loginSuccessBanner) { loginSuccessBanner.querySelector('.success-msg').textContent=data.thongbao||'Đổi mật khẩu thành công! Vui lòng đăng nhập lại.'; loginSuccessBanner.hidden = false; }
            } else {
                if (errorBanner) { errorBanner.querySelector('.error-msg').textContent=data.loi||'Có lỗi xảy ra.'; errorBanner.hidden = false; }
            }
        })
        .catch(err => {
            console.error('Lỗi Reset Password AJAX:', err);
            if (spinner) spinner.classList.remove('authdd-show');
            if (btnText) btnText.style.visibility = 'visible';
            if (btn) btn.disabled = false;
            if (errorBanner) { errorBanner.querySelector('.error-msg').textContent='Có lỗi mạng xảy ra. Vui lòng thử lại!'; errorBanner.hidden = false; }
        });
    }

    document.addEventListener('DOMContentLoaded', () => {
        document.body.addEventListener('click', (e) => {
            const anchor = e.target.closest('a');
            if (anchor && anchor.href) {
                const url = new URL(anchor.href, window.location.origin);
                const path = url.pathname;
                if (anchor.hasAttribute('data-no-modal') || url.searchParams.has('admin') || url.searchParams.get('role') === 'admin') return;
                if (path.endsWith('/dangky')) { e.preventDefault(); openAuthModal('register'); }
            }
        });
        const urlParams = new URLSearchParams(window.location.search);
        const authAction = urlParams.get('auth');
        if (authAction === 'login') openAuthModal('login');
        else if (authAction === 'register') openAuthModal('register');
    });
</script>
