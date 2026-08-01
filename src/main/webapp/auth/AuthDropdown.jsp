<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<style>
    .auth-dropdown-wrapper {
        position: relative;
        display: inline-flex;
        align-items: center;
        gap: 12px;
    }
    .auth-dropdown {
        position: absolute;
        top: calc(100% + 10px);
        right: 0;
        width: 380px;
        max-width: calc(100vw - 24px);
        background: #ffffff;
        border: 1px solid #e5e7eb;
        border-radius: 16px;
        box-shadow: 0 12px 32px rgba(0, 0, 0, 0.10);
        padding: 20px;
        opacity: 0;
        visibility: hidden;
        transform: translateY(8px) scale(0.98);
        transition: opacity .2s ease, transform .2s ease, visibility .2s ease;
        z-index: 3000;
        text-align: left;
        color: #111827;
        font-family: 'Poppins', sans-serif;
    }
    .auth-dropdown.is-open {
        opacity: 1;
        visibility: visible;
        transform: translateY(0) scale(1);
    }
    .auth-dropdown-header {
        margin-bottom: 14px;
        display: flex;
        flex-direction: column;
        align-items: center;
        text-align: center;
    }
    .auth-dropdown-logo { font-size: 14px; font-weight: 800; color: #111; margin-bottom: 10px; }
    .auth-dropdown-logo span { color: #2563eb; }
    .auth-dropdown-header h3 { font-size: 16px; font-weight: 700; margin: 0 0 3px 0; color: #111111; }
    .auth-dropdown-header p { font-size: 12px; color: #6b7280; margin: 0; }

    .authdd-tabs {
        display: flex; background: #f3f4f6; border-radius: 10px;
        padding: 4px; gap: 4px; margin-bottom: 18px;
    }
    .authdd-tab {
        flex: 1; background: transparent; border: none; border-radius: 8px;
        padding: 8px 0; font-size: 13px; font-weight: 600; color: #6b7280;
        cursor: pointer; transition: all 0.2s ease; text-align: center;
    }
    .authdd-tab.authdd-tab-active { background: #fff; color: #2563eb; box-shadow: 0 2px 4px rgba(0,0,0,0.05); }

    .authdd-panel { display: none; }
    .authdd-panel.active { display: block; }

    .authdd-field { margin-bottom: 11px; }
    .authdd-label { display: block; font-size: 12px; font-weight: 600; color: #111827; margin-bottom: 4px; }
    .authdd-input {
        width: 100%; height: 40px; padding: 0 14px;
        border: 1.5px solid #e5e7eb; border-radius: 10px; font-size: 13px;
        background: #f9fafb; outline: none; transition: border-color 0.2s, box-shadow 0.2s;
        box-sizing: border-box; color: #111;
    }
    .authdd-input:focus { border-color: #2563eb; box-shadow: 0 0 0 3px rgba(37,99,235,.1); background: #fff; }
    .authdd-input.is-error { border-color: #ef4444; box-shadow: 0 0 0 3px rgba(239,68,68,.09); }
    .authdd-input.is-ok { border-color: #22c55e; }

    .authdd-input-group { position: relative; }
    .authdd-input-group .authdd-input { padding-right: 40px; }
    .authdd-input-group .toggle-password {
        position: absolute; right: 12px; top: 50%; transform: translateY(-50%);
        cursor: pointer; color: #9ca3af; font-size: 15px; user-select: none;
        transition: color .15s;
    }
    .authdd-input-group .toggle-password:hover { color: #4b5563; }

    .authdd-field-hint { font-size: 11px; color: #9ca3af; margin-top: 3px; }
    .authdd-field-error { font-size: 11px; color: #ef4444; margin-top: 3px; display: none; }
    .authdd-field-error.visible { display: block; }

    /* Password strength bar */
    .pw-strength-bar { height: 3px; border-radius: 99px; background: #e5e7eb; margin-top: 5px; overflow: hidden; }
    .pw-strength-fill { height: 100%; border-radius: 99px; width: 0; transition: width .35s, background .35s; }

    .authdd-btn {
        width: 100%; height: 42px; background: #2563eb; color: #fff;
        border: none; border-radius: 10px; font-size: 14px; font-weight: 600;
        cursor: pointer; transition: background 0.2s, transform .1s; margin-top: 6px;
        display: flex; align-items: center; justify-content: center; gap: 6px;
    }
    .authdd-btn:hover:not(:disabled) { background: #1d4ed8; }
    .authdd-btn:active:not(:disabled) { transform: scale(.98); }
    .authdd-btn:disabled { opacity: .6; cursor: not-allowed; }
    .authdd-btn .btn-spinner { display: none; width: 16px; height: 16px; border: 2px solid rgba(255,255,255,.3); border-top-color: #fff; border-radius: 50%; animation: spin .7s linear infinite; }
    .authdd-btn.loading .btn-spinner { display: block; }
    .authdd-btn.loading .btn-label { display: none; }
    @keyframes spin { to { transform: rotate(360deg); } }

    .authdd-footer-link { display: block; text-align: center; font-size: 12px; color: #6b7280; margin-top: 12px; text-decoration: none; cursor: pointer; }
    .authdd-footer-link span { color: #2563eb; font-weight: 600; }
    .authdd-flex-between { display: flex; justify-content: space-between; align-items: center; font-size: 12px; margin-bottom: 14px; }
    .authdd-flex-between a { color: #2563eb; text-decoration: none; font-weight: 500; }
    .authdd-checkbox-wrap { display: flex; align-items: flex-start; gap: 7px; font-size: 12px; color: #6b7280; margin-bottom: 4px; }
    .authdd-checkbox-wrap input[type=checkbox] { margin-top: 2px; accent-color: #2563eb; flex-shrink: 0; }
    .authdd-checkbox-wrap a { color: #2563eb; text-decoration: underline; }

    /* Alert banner */
    .authdd-alert { border-radius: 9px; padding: 9px 12px; font-size: 12px; font-weight: 500; margin-bottom: 12px; display: flex; align-items: flex-start; gap: 8px; }
    .authdd-alert.error { background: #fef2f2; color: #dc2626; border: 1px solid #fecaca; }
    .authdd-alert.success { background: #f0fdf4; color: #16a34a; border: 1px solid #bbf7d0; }
    .authdd-alert.info { background: #eff6ff; color: #1d4ed8; border: 1px solid #bfdbfe; }
    .authdd-alert i { font-size: 16px; flex-shrink: 0; margin-top: 1px; }

    /* OTP panel */
    .authdd-otp-boxes { display: flex; gap: 8px; justify-content: center; margin: 14px 0; }
    .authdd-otp-box {
        width: 44px; height: 52px; border: 1.5px solid #e5e7eb; border-radius: 10px;
        text-align: center; font-size: 22px; font-weight: 700; font-family: monospace;
        background: #f9fafb; color: #111; outline: none; transition: border-color .2s, box-shadow .2s;
        caret-color: #2563eb;
    }
    .authdd-otp-box:focus { border-color: #2563eb; box-shadow: 0 0 0 3px rgba(37,99,235,.1); background: #fff; }
    .authdd-otp-box.filled { border-color: #22c55e; background: #f0fdf4; }
    .authdd-otp-box.err { border-color: #ef4444; background: #fef2f2; }

    .authdd-resend-row { text-align: center; font-size: 12px; color: #9ca3af; margin-top: 4px; }
    .authdd-resend-btn { color: #2563eb; font-weight: 600; cursor: pointer; background: none; border: none; font-size: 12px; padding: 0; }
    .authdd-resend-btn:disabled { color: #9ca3af; cursor: default; }
    .authdd-countdown { font-weight: 600; color: #f59e0b; }

    .authdd-success-icon { font-size: 48px; text-align: center; margin: 8px 0 4px; }
    .authdd-success-title { font-size: 16px; font-weight: 700; text-align: center; color: #111; }
    .authdd-success-sub { font-size: 12px; color: #6b7280; text-align: center; margin-top: 4px; }

    @media (max-width: 768px) {
        .auth-dropdown {
            position: fixed; top: 60px; right: 12px; left: 12px; width: auto;
        }
    }

    /* Row layout cho fields */
    .authdd-row { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }
</style>

<div class="auth-dropdown" id="authDropdown">
    <div class="auth-dropdown-header">
        <div class="auth-dropdown-logo">V<span>⚡</span>SPORT Account</div>
        <h3 id="authdd-title">Đăng nhập</h3>
        <p id="authdd-subtitle">Tiếp tục đặt sân và ghép trận.</p>
    </div>

    <div class="authdd-tabs" id="authdd-tabs">
        <button type="button" class="authdd-tab authdd-tab-active" onclick="switchAuthTab('login')" id="tab-login">Đăng nhập</button>
        <button type="button" class="authdd-tab" onclick="switchAuthTab('register')" id="tab-register">Đăng ký</button>
    </div>

    <!-- ══ LOGIN ══ -->
    <div class="authdd-panel active" id="panel-login">
        <div id="login-alert" class="authdd-alert error" style="display:none">
            <i class="fa-solid fa-circle-exclamation"></i>
            <span id="login-alert-msg"></span>
        </div>
        <form id="login-form" action="${pageContext.request.contextPath}/dangnhap" method="post">
            <input type="hidden" name="redirect" class="authdd-redirect-input" value="">
            <div class="authdd-field">
                <label class="authdd-label">Email hoặc số điện thoại</label>
                <input type="text" name="username" id="login-username" class="authdd-input" placeholder="Nhập email hoặc SĐT...">
                <div class="authdd-field-error" id="err-login-username">Vui lòng nhập email hoặc số điện thoại.</div>
            </div>
            <div class="authdd-field">
                <label class="authdd-label">Mật khẩu</label>
                <div class="authdd-input-group">
                    <input type="password" name="password" id="login-password" class="authdd-input" placeholder="Nhập mật khẩu...">
                    <i class="fa-regular fa-eye toggle-password" onclick="authddTogglePw(this)"></i>
                </div>
                <div class="authdd-field-error" id="err-login-password">Vui lòng nhập mật khẩu.</div>
            </div>
            <div class="authdd-flex-between">
                <label style="display:flex;align-items:center;gap:5px;font-size:12px;color:#6b7280;cursor:pointer">
                    <input type="checkbox" name="remember" value="true" style="accent-color:#2563eb"> Ghi nhớ 7 ngày
                </label>
                <a href="${pageContext.request.contextPath}/forgot-password">Quên mật khẩu?</a>
            </div>
            <button type="submit" class="authdd-btn" id="login-btn">
                <span class="btn-label">Đăng nhập</span>
                <span class="btn-spinner"></span>
            </button>
            <a class="authdd-footer-link" onclick="switchAuthTab('register')">
                Chưa có tài khoản? <span>Tạo tài khoản miễn phí</span>
            </a>
        </form>
    </div>

    <!-- ══ REGISTER – step 1: form ══ -->
    <div class="authdd-panel" id="panel-register" style="max-height:calc(100vh - 250px);overflow-y:auto;padding-right:2px">
        <div id="reg-alert" class="authdd-alert error" style="display:none">
            <i class="fa-solid fa-circle-exclamation"></i>
            <span id="reg-alert-msg"></span>
        </div>

        <form id="reg-form" novalidate>
            <div class="authdd-field">
                <label class="authdd-label">Họ và tên <span style="color:#ef4444">*</span></label>
                <input type="text" name="fullname" id="reg-fullname" class="authdd-input" placeholder="Nguyễn Văn A">
                <div class="authdd-field-error" id="err-fullname">Họ tên phải từ 2 đến 100 ký tự.</div>
            </div>

            <div class="authdd-row">
                <div class="authdd-field">
                    <label class="authdd-label">Email <span style="color:#ef4444">*</span></label>
                    <input type="email" name="email" id="reg-email" class="authdd-input" placeholder="email@gmail.com">
                    <div class="authdd-field-error" id="err-email">Email không hợp lệ.</div>
                </div>
                <div class="authdd-field">
                    <label class="authdd-label">Số điện thoại <span style="color:#ef4444">*</span></label>
                    <input type="text" name="phone" id="reg-phone" class="authdd-input" placeholder="09xxxxxxxx">
                    <div class="authdd-field-error" id="err-phone">SĐT Việt Nam không hợp lệ.</div>
                </div>
            </div>

            <div class="authdd-field">
                <label class="authdd-label">Mật khẩu <span style="color:#ef4444">*</span></label>
                <div class="authdd-input-group">
                    <input type="password" name="password" id="reg-password" class="authdd-input" placeholder="Tối thiểu 8 ký tự..." oninput="authddCheckPwStrength(this.value)">
                    <i class="fa-regular fa-eye toggle-password" onclick="authddTogglePw(this)"></i>
                </div>
                <div class="pw-strength-bar"><div class="pw-strength-fill" id="pw-fill"></div></div>
                <div class="authdd-field-error" id="err-password">Mật khẩu cần ≥8 ký tự, chữ hoa, thường, số và ký tự đặc biệt.</div>
            </div>

            <div class="authdd-field">
                <label class="authdd-label">Xác nhận mật khẩu <span style="color:#ef4444">*</span></label>
                <div class="authdd-input-group">
                    <input type="password" name="confirm_password" id="reg-confirm" class="authdd-input" placeholder="Nhập lại mật khẩu...">
                    <i class="fa-regular fa-eye toggle-password" onclick="authddTogglePw(this)"></i>
                </div>
                <div class="authdd-field-error" id="err-confirm">Mật khẩu không khớp.</div>
            </div>

            <label class="authdd-checkbox-wrap">
                <input type="checkbox" id="reg-agree" name="agree" value="Đồng ý">
                <span>Tôi đồng ý với <a href="#" target="_blank">Điều khoản sử dụng</a> và <a href="#" target="_blank">Chính sách bảo mật</a> của V-SPORT.</span>
            </label>
            <div class="authdd-field-error" id="err-agree">Bạn cần đồng ý với điều khoản để tiếp tục.</div>

            <button type="submit" class="authdd-btn" id="reg-btn" style="margin-top:12px">
                <span class="btn-label">Tạo tài khoản</span>
                <span class="btn-spinner"></span>
            </button>
        </form>
        <a class="authdd-footer-link" onclick="switchAuthTab('login')">
            Đã có tài khoản? <span>Đăng nhập</span>
        </a>
    </div>

    <!-- ══ REGISTER – step 2: OTP ══ -->
    <div class="authdd-panel" id="panel-otp">
        <div style="text-align:center;margin-bottom:12px">
            <div style="width:48px;height:48px;border-radius:50%;background:#eff6ff;display:inline-flex;align-items:center;justify-content:center;margin-bottom:8px">
                <i class="fa-solid fa-envelope-circle-check" style="color:#2563eb;font-size:22px"></i>
            </div>
            <div style="font-size:15px;font-weight:700;color:#111">Xác minh email</div>
            <div style="font-size:12px;color:#6b7280;margin-top:3px">
                Mã 6 chữ số đã gửi tới <strong id="otp-email-display" style="color:#111"></strong>
            </div>
        </div>

        <div id="otp-alert" class="authdd-alert error" style="display:none">
            <i class="fa-solid fa-circle-exclamation"></i>
            <span id="otp-alert-msg"></span>
        </div>

        <form id="otp-form" novalidate>
            <input type="hidden" id="otp-email-hidden" name="email" value="">
            <div class="authdd-otp-boxes" id="otp-boxes">
                <input class="authdd-otp-box" maxlength="1" inputmode="numeric" pattern="[0-9]">
                <input class="authdd-otp-box" maxlength="1" inputmode="numeric" pattern="[0-9]">
                <input class="authdd-otp-box" maxlength="1" inputmode="numeric" pattern="[0-9]">
                <input class="authdd-otp-box" maxlength="1" inputmode="numeric" pattern="[0-9]">
                <input class="authdd-otp-box" maxlength="1" inputmode="numeric" pattern="[0-9]">
                <input class="authdd-otp-box" maxlength="1" inputmode="numeric" pattern="[0-9]">
            </div>
            <button type="submit" class="authdd-btn" id="otp-btn">
                <span class="btn-label">Xác minh</span>
                <span class="btn-spinner"></span>
            </button>
        </form>

        <div class="authdd-resend-row" style="margin-top:12px">
            Chưa nhận được?
            <button class="authdd-resend-btn" id="resend-btn" onclick="authddResendOTP()" disabled>
                Gửi lại (<span class="authdd-countdown" id="resend-countdown">60</span>s)
            </button>
        </div>

        <a class="authdd-footer-link" onclick="switchAuthTab('register')">
            ← Quay lại đăng ký
        </a>
    </div>

    <!-- ══ REGISTER – step 3: success ══ -->
    <div class="authdd-panel" id="panel-success">
        <div class="authdd-success-icon">🎉</div>
        <div class="authdd-success-title">Tạo tài khoản thành công!</div>
        <div class="authdd-success-sub">Chào mừng bạn đến với V-SPORT. Hãy đăng nhập để bắt đầu.</div>
        <button class="authdd-btn" style="margin-top:20px" onclick="switchAuthTab('login')">
            <span class="btn-label">Đăng nhập ngay</span>
        </button>
    </div>
</div>

<script>
(function() {
    const CTX = '${pageContext.request.contextPath}';

    /* ── helpers ── */
    function showAlert(id, msgId, msg, type) {
        var el = document.getElementById(id);
        var msgEl = document.getElementById(msgId);
        if (!el || !msgEl) return;
        el.className = 'authdd-alert ' + (type || 'error');
        el.style.display = 'flex';
        msgEl.textContent = msg;
    }
    function hideAlert(id) {
        var el = document.getElementById(id);
        if (el) el.style.display = 'none';
    }
    function fieldErr(errId, inputId, show) {
        var e = document.getElementById(errId);
        var i = document.getElementById(inputId);
        if (e) { if (show) e.classList.add('visible'); else e.classList.remove('visible'); }
        if (i) { if (show) i.classList.add('is-error'); else i.classList.remove('is-error'); }
    }
    function btnLoading(id, yes) {
        var b = document.getElementById(id);
        if (!b) return;
        if (yes) { b.classList.add('loading'); b.disabled = true; }
        else { b.classList.remove('loading'); b.disabled = false; }
    }

    /* ── tab switch ── */
    window.switchAuthTab = function(tab) {
        ['login','register','otp','success'].forEach(function(p) {
            document.getElementById('panel-' + p).classList.remove('active');
        });
        document.getElementById('tab-login').classList.remove('authdd-tab-active');
        document.getElementById('tab-register').classList.remove('authdd-tab-active');

        var tabsEl = document.getElementById('authdd-tabs');

        if (tab === 'login') {
            document.getElementById('panel-login').classList.add('active');
            document.getElementById('tab-login').classList.add('authdd-tab-active');
            document.getElementById('authdd-title').textContent = 'Đăng nhập';
            document.getElementById('authdd-subtitle').textContent = 'Tiếp tục đặt sân và ghép trận.';
            if (tabsEl) tabsEl.style.display = '';
        } else if (tab === 'register') {
            document.getElementById('panel-register').classList.add('active');
            document.getElementById('tab-register').classList.add('authdd-tab-active');
            document.getElementById('authdd-title').textContent = 'Tạo tài khoản';
            document.getElementById('authdd-subtitle').textContent = 'Miễn phí, chỉ mất 1 phút.';
            if (tabsEl) tabsEl.style.display = '';
        } else if (tab === 'otp') {
            document.getElementById('panel-otp').classList.add('active');
            document.getElementById('authdd-title').textContent = 'Nhập mã OTP';
            document.getElementById('authdd-subtitle').textContent = 'Kiểm tra hộp thư (kể cả Spam).';
            if (tabsEl) tabsEl.style.display = 'none';
        } else if (tab === 'success') {
            document.getElementById('panel-success').classList.add('active');
            document.getElementById('authdd-title').textContent = 'Chào mừng!';
            document.getElementById('authdd-subtitle').textContent = '';
            if (tabsEl) tabsEl.style.display = 'none';
        }
    };

    /* ── dropdown open/close ── */
    var dropdown = document.getElementById('authDropdown');
    window.toggleAuthDropdown = function(tab) {
        if (dropdown.classList.contains('is-open')) {
            dropdown.classList.remove('is-open');
        } else {
            dropdown.classList.add('is-open');
            switchAuthTab(tab || 'login');
        }
    };
    window.openAuthModal = function(tab) {
        updateAuthddRedirect();
        dropdown.classList.add('is-open');
        switchAuthTab(tab || 'login');
    };
    document.addEventListener('click', function(e) {
        var w = document.getElementById('authDropdownWrapper');
        if (w && !w.contains(e.target)) dropdown.classList.remove('is-open');
    });
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') dropdown.classList.remove('is-open');
    });
    function updateAuthddRedirect() {
        var inputs = document.querySelectorAll('.authdd-redirect-input');
        var curr = window.location.pathname + window.location.search + window.location.hash;
        inputs.forEach(function(i) { if (curr && !i.value) i.value = curr; });
    }
    updateAuthddRedirect();

    /* ── password visibility toggle ── */
    window.authddTogglePw = function(icon) {
        var input = icon.previousElementSibling;
        if (!input) return;
        if (input.type === 'password') {
            input.type = 'text';
            icon.classList.replace('fa-eye', 'fa-eye-slash');
        } else {
            input.type = 'password';
            icon.classList.replace('fa-eye-slash', 'fa-eye');
        }
    };

    /* ── password strength ── */
    window.authddCheckPwStrength = function(val) {
        var fill = document.getElementById('pw-fill');
        if (!fill) return;
        var score = 0;
        if (val.length >= 8) score++;
        if (/[A-Z]/.test(val)) score++;
        if (/[a-z]/.test(val)) score++;
        if (/[0-9]/.test(val)) score++;
        if (/[^A-Za-z0-9]/.test(val)) score++;
        var pct = score * 20;
        var color = score <= 2 ? '#ef4444' : score <= 3 ? '#f59e0b' : '#22c55e';
        fill.style.width = pct + '%';
        fill.style.background = color;
    };

    /* ── client-side validation ── */
    function validateReg() {
        var ok = true;
        var fn = document.getElementById('reg-fullname').value.trim();
        var email = document.getElementById('reg-email').value.trim();
        var phone = document.getElementById('reg-phone').value.trim();
        var pw = document.getElementById('reg-password').value;
        var cf = document.getElementById('reg-confirm').value;
        var agree = document.getElementById('reg-agree').checked;

        // Fullname
        var fnBad = fn.length < 2 || fn.length > 100;
        fieldErr('err-fullname', 'reg-fullname', fnBad); if (fnBad) ok = false;

        // Email
        var emailBad = !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
        fieldErr('err-email', 'reg-email', emailBad); if (emailBad) ok = false;

        // Phone: Việt Nam 0[3-9]xxxxxxxx hoặc +84...
        var phoneBad = !/^(0[3-9][0-9]{8}|\+84[3-9][0-9]{8}|84[3-9][0-9]{8})$/.test(phone.replace(/\s/g,''));
        fieldErr('err-phone', 'reg-phone', phoneBad); if (phoneBad) ok = false;

        // Password strength
        var strongPw = pw.length >= 8 && /[A-Z]/.test(pw) && /[a-z]/.test(pw) && /[0-9]/.test(pw) && /[^A-Za-z0-9]/.test(pw);
        fieldErr('err-password', 'reg-password', !strongPw); if (!strongPw) ok = false;

        // Confirm
        var cfBad = pw !== cf || cf === '';
        fieldErr('err-confirm', 'reg-confirm', cfBad); if (cfBad) ok = false;

        // Agree
        var agrBad = !agree;
        fieldErr('err-agree', null, agrBad); if (agrBad) ok = false;

        return ok;
    }

    /* ── LOGIN submit ── */
    document.getElementById('login-form').addEventListener('submit', function(e) {
        hideAlert('login-alert');
        var u = document.getElementById('login-username').value.trim();
        var p = document.getElementById('login-password').value;
        var ok = true;
        if (!u) { fieldErr('err-login-username','login-username',true); ok=false; } else fieldErr('err-login-username','login-username',false);
        if (!p) { fieldErr('err-login-password','login-password',true); ok=false; } else fieldErr('err-login-password','login-password',false);
        if (!ok) e.preventDefault();
        else btnLoading('login-btn', true);
    });

    /* ── REGISTER submit ── */
    document.getElementById('reg-form').addEventListener('submit', function(e) {
        e.preventDefault();
        hideAlert('reg-alert');
        if (!validateReg()) return;

        btnLoading('reg-btn', true);
        var data = new FormData(e.target);
        fetch(CTX + '/dangky', {
            method: 'POST',
            headers: { 'X-Requested-With': 'XMLHttpRequest' },
            body: data
        })
        .then(function(r) { return r.json(); })
        .then(function(res) {
            if (res.success) {
                // Chuyển sang bước OTP
                document.getElementById('otp-email-display').textContent = res.email || document.getElementById('reg-email').value;
                document.getElementById('otp-email-hidden').value = res.email || document.getElementById('reg-email').value;
                switchAuthTab('otp');
                startResendCountdown(60);
                // Focus ô OTP đầu tiên
                setTimeout(function() {
                    var boxes = document.querySelectorAll('.authdd-otp-box');
                    if (boxes[0]) boxes[0].focus();
                }, 100);
            } else {
                showAlert('reg-alert', 'reg-alert-msg', res.loi || 'Đã xảy ra lỗi. Vui lòng thử lại.', 'error');
            }
        })
        .catch(function() {
            showAlert('reg-alert', 'reg-alert-msg', 'Lỗi kết nối. Vui lòng thử lại.', 'error');
        })
        .finally(function() { btnLoading('reg-btn', false); });
    });

    /* ── OTP box keyboard UX ── */
    (function() {
        var boxes = document.querySelectorAll('.authdd-otp-box');
        boxes.forEach(function(box, i) {
            box.addEventListener('input', function(e) {
                var v = e.target.value.replace(/[^0-9]/g,'');
                e.target.value = v.slice(-1);
                e.target.classList.toggle('filled', v !== '');
                e.target.classList.remove('err');
                if (v && i < boxes.length - 1) boxes[i+1].focus();
                // auto-submit if last filled
                if (i === boxes.length - 1 && v) submitOTP();
            });
            box.addEventListener('keydown', function(e) {
                if (e.key === 'Backspace' && !e.target.value && i > 0) {
                    boxes[i-1].value = '';
                    boxes[i-1].classList.remove('filled');
                    boxes[i-1].focus();
                }
                if (e.key === 'ArrowLeft' && i > 0) boxes[i-1].focus();
                if (e.key === 'ArrowRight' && i < boxes.length-1) boxes[i+1].focus();
            });
            box.addEventListener('paste', function(e) {
                e.preventDefault();
                var text = (e.clipboardData || window.clipboardData).getData('text').replace(/[^0-9]/g,'');
                text.split('').slice(0, boxes.length - i).forEach(function(ch, j) {
                    boxes[i+j].value = ch;
                    boxes[i+j].classList.add('filled');
                    boxes[i+j].classList.remove('err');
                });
                var nextFocus = Math.min(i + text.length, boxes.length - 1);
                boxes[nextFocus].focus();
                if (i + text.length >= boxes.length) submitOTP();
            });
        });
    })();

    function getOTPValue() {
        return Array.from(document.querySelectorAll('.authdd-otp-box')).map(function(b) { return b.value; }).join('');
    }
    function setOTPError() {
        document.querySelectorAll('.authdd-otp-box').forEach(function(b) { b.classList.add('err'); b.classList.remove('filled'); });
    }
    function clearOTPBoxes() {
        document.querySelectorAll('.authdd-otp-box').forEach(function(b) {
            b.value = ''; b.classList.remove('filled','err');
        });
    }

    /* ── OTP submit ── */
    document.getElementById('otp-form').addEventListener('submit', function(e) {
        e.preventDefault();
        submitOTP();
    });

    function submitOTP() {
        var otp = getOTPValue();
        if (otp.length < 6) {
            showAlert('otp-alert','otp-alert-msg','Vui lòng nhập đủ 6 chữ số.','error');
            return;
        }
        hideAlert('otp-alert');
        btnLoading('otp-btn', true);

        var fd = new FormData();
        fd.append('otp', otp);
        fd.append('email', document.getElementById('otp-email-hidden').value);

        fetch(CTX + '/nhapma', {
            method: 'POST',
            headers: { 'X-Requested-With': 'XMLHttpRequest' },
            body: fd
        })
        .then(function(r) { return r.json(); })
        .then(function(res) {
            if (res.success) {
                switchAuthTab('success');
                stopResendCountdown();
            } else {
                setOTPError();
                clearOTPBoxes();
                showAlert('otp-alert','otp-alert-msg', res.loi || 'Mã không chính xác.','error');
                setTimeout(function() {
                    var boxes = document.querySelectorAll('.authdd-otp-box');
                    if (boxes[0]) boxes[0].focus();
                }, 100);
            }
        })
        .catch(function() {
            showAlert('otp-alert','otp-alert-msg','Lỗi kết nối. Vui lòng thử lại.','error');
        })
        .finally(function() { btnLoading('otp-btn', false); });
    }

    /* ── Resend countdown ── */
    var _countdownTimer = null;
    function startResendCountdown(seconds) {
        stopResendCountdown();
        var btn = document.getElementById('resend-btn');
        var cd = document.getElementById('resend-countdown');
        var left = seconds;
        if (btn) btn.disabled = true;
        if (cd) cd.textContent = left;
        _countdownTimer = setInterval(function() {
            left--;
            if (cd) cd.textContent = left;
            if (left <= 0) {
                stopResendCountdown();
                if (btn) {
                    btn.disabled = false;
                    btn.innerHTML = 'Gửi lại mã';
                }
            }
        }, 1000);
    }
    function stopResendCountdown() {
        if (_countdownTimer) { clearInterval(_countdownTimer); _countdownTimer = null; }
    }

    window.authddResendOTP = function() {
        var btn = document.getElementById('resend-btn');
        if (btn) btn.disabled = true;
        hideAlert('otp-alert');
        fetch(CTX + '/resend-otp', {
            method: 'POST',
            headers: { 'X-Requested-With': 'XMLHttpRequest' }
        })
        .then(function(r) { return r.json(); })
        .then(function(res) {
            if (res.success) {
                clearOTPBoxes();
                showAlert('otp-alert','otp-alert-msg', res.thongbao || 'Đã gửi mã mới.','success');
                startResendCountdown(60);
            } else {
                showAlert('otp-alert','otp-alert-msg', res.loi || 'Không thể gửi lại.','error');
                if (btn) btn.disabled = false;
            }
        })
        .catch(function() {
            showAlert('otp-alert','otp-alert-msg','Lỗi kết nối.','error');
            if (btn) btn.disabled = false;
        });
    };

    /* ── Real-time field cleanup on input ── */
    ['reg-fullname','reg-email','reg-phone','reg-password','reg-confirm'].forEach(function(id) {
        var el = document.getElementById(id);
        if (!el) return;
        el.addEventListener('input', function() {
            el.classList.remove('is-error');
            var errMap = {
                'reg-fullname':'err-fullname','reg-email':'err-email','reg-phone':'err-phone',
                'reg-password':'err-password','reg-confirm':'err-confirm'
            };
            var errEl = document.getElementById(errMap[id]);
            if (errEl) errEl.classList.remove('visible');
        });
    });
})();
</script>
