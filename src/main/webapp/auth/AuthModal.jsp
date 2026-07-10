<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<style>
    .auth-modal-scroll::-webkit-scrollbar { width: 6px; }
    .auth-modal-scroll::-webkit-scrollbar-track { background: transparent; }
    .auth-modal-scroll::-webkit-scrollbar-thumb { background-color: #cbd5e1; border-radius: 20px; }

    #auth-modal {
        position: fixed;
        z-index: 130;
        display: none;
    }
    #auth-modal.is-open { display: block; }
    #auth-modal-card {
        width: 360px;
        max-width: calc(100vw - 16px);
        max-height: 85vh;
        opacity: 0;
        transform: translateY(-6px);
        transition: opacity 180ms ease-out, transform 180ms ease-out;
    }
    #auth-modal-card.is-visible {
        opacity: 1;
        transform: translateY(0);
    }
    .modal-panel { transition: opacity 200ms ease-out, transform 200ms ease-out; }
    :where(#auth-modal button) {
        background-color: transparent; background-image: none;
        border: none; padding: 0; margin: 0; outline: none; box-shadow: none;
    }
    #auth-loading-overlay { transition: opacity 200ms ease-out; }
    #auth-loading-overlay.is-visible {
        display: flex !important;
        animation: authLoadingFadeIn 200ms ease-out forwards;
    }
    @keyframes authLoadingFadeIn { from { opacity: 0; } to { opacity: 1; } }
    @keyframes authLoadingPulse { 0%, 100% { opacity: 1; } 50% { opacity: 0.55; } }
    .auth-loading-pulse { animation: authLoadingPulse 1.4s ease-in-out infinite; }
    .btn-submit.is-loading, #modal-login-btn.is-loading { cursor: wait; pointer-events: none; }
    .auth-divider { display: flex; align-items: center; gap: 10px; margin: 14px 0; }
    .auth-divider::before, .auth-divider::after { content: ''; flex: 1; height: 1px; background: #e2e8f0; }
    .auth-google-btn {
        width: 100%; height: 40px; border-radius: 10px; border: 1.5px solid #e2e8f0 !important;
        display: flex; align-items: center; justify-content: center; gap: 8px;
        font-size: 12.5px; font-weight: 600; color: #334155; transition: all 150ms ease;
    }
    .auth-google-btn:hover { background-color: #f8fafc !important; border-color: #cbd5e1 !important; }
</style>

<div id="auth-modal">
    <div id="auth-modal-card" class="bg-white rounded-2xl flex flex-col shadow-xl relative border border-slate-200">

        <!-- Loading overlay -->
        <div id="auth-loading-overlay" class="hidden absolute inset-0 z-[140] bg-white/85 backdrop-blur-sm rounded-2xl flex-col items-center justify-center gap-4">
            <div class="w-9 h-9 border-[3px] border-[#378b76]/20 border-t-[#378b76] rounded-full animate-spin"></div>
            <div class="text-center px-6">
                <p id="auth-loading-text" class="text-[13px] font-bold text-slate-800 auth-loading-pulse">Đang đăng nhập...</p>
            </div>
        </div>

        <!-- Close Button -->
        <button onclick="closeAuthModal()" class="absolute top-3.5 right-3.5 text-slate-400 hover:text-slate-600 transition-colors z-[130] w-7 h-7 rounded-full flex items-center justify-center bg-slate-50 hover:bg-slate-100">
            <span class="material-symbols-outlined text-[18px]">close</span>
        </button>

        <!-- Toggle Tabs -->
        <div id="modal-tabs-header" class="px-5 pt-5 pb-3 border-b border-slate-100 flex items-center justify-start gap-4">
            <button id="modal-tab-login" onclick="switchAuthTab('login')" class="text-[15px] font-bold tracking-tight text-slate-900 border-b-2 border-[#378b76] pb-1.5 transition-all">Đăng nhập</button>
            <button id="modal-tab-register" onclick="switchAuthTab('register')" class="text-[15px] font-bold tracking-tight text-slate-400 hover:text-slate-900 border-b-2 border-transparent pb-1.5 transition-all">Đăng ký</button>
        </div>

        <!-- Content Area -->
        <div class="flex-grow overflow-y-auto p-5 auth-modal-scroll">

            <!-- LOGIN PANEL -->
            <div id="modal-login-panel" class="modal-panel flex flex-col">
                <div id="login-error-banner" class="hidden mb-4 p-3 bg-red-50 text-red-600 rounded-lg text-[11.5px] font-semibold border border-red-100 flex items-center gap-2 shadow-sm">
                    <span class="material-symbols-outlined text-[16px]">error</span>
                    <span class="error-msg"></span>
                </div>
                <div id="login-success-banner" class="hidden mb-4 p-3 bg-green-50 text-green-600 rounded-lg text-[11.5px] font-semibold border border-green-100 flex items-center gap-2 shadow-sm">
                    <span class="material-symbols-outlined text-[16px]">check_circle</span>
                    <span class="success-msg"></span>
                </div>

                <form id="modal-login-form" action="${pageContext.request.contextPath}/dangnhap" method="POST" class="flex flex-col" autocomplete="off" onsubmit="submitLoginForm(event)">
                    <input type="hidden" name="loginType" value="customer">
                    <div class="mb-3">
                        <label class="text-[11.5px] font-bold text-slate-700 mb-1 block">Tên đăng nhập hoặc email</label>
                        <input type="text" name="username" id="modal-login-username" required placeholder="Nhập tên đăng nhập hoặc email" class="w-full h-10 px-3 border-1.5 border-slate-300 rounded-lg text-[12.5px] font-medium text-slate-900 focus:border-[#378b76] focus:ring-2 focus:ring-[#378b76]/10 transition-all outline-none" style="border-width: 1.5px;">
                    </div>
                    <div class="mb-3 relative">
                        <label class="text-[11.5px] font-bold text-slate-700 mb-1 block">Mật khẩu</label>
                        <div class="relative">
                            <input type="password" name="password" id="modal-login-pass" required placeholder="Nhập mật khẩu" class="w-full h-10 pl-3 pr-9 border-1.5 border-slate-300 rounded-lg text-[12.5px] font-medium text-slate-900 focus:border-[#378b76] focus:ring-2 focus:ring-[#378b76]/10 transition-all outline-none" style="border-width: 1.5px;">
                            <button type="button" onclick="togglePassField('modal-login-pass', this)" class="absolute right-2.5 top-1/2 -translate-y-1/2 text-slate-400 hover:text-[#378b76] transition-all">
                                <span class="material-symbols-outlined text-[18px]">visibility</span>
                            </button>
                        </div>
                    </div>
                    <div class="flex items-center justify-between mb-4">
                        <label class="flex items-center gap-1.5 cursor-pointer select-none text-[11px] text-slate-500 font-semibold">
                            <input type="checkbox" name="rememberMe" class="w-3.5 h-3.5 accent-[#378b76] rounded border-slate-300">
                            <span>Ghi nhớ 7 ngày</span>
                        </label>
                        <button type="button" onclick="switchAuthTab('forgot-password')" class="text-[11px] font-bold text-[#378b76] hover:underline cursor-pointer">Quên mật khẩu?</button>
                    </div>
                    <button type="submit" id="modal-login-btn" class="w-full h-10 bg-[#378b76] hover:bg-[#2c6f5e] text-white rounded-lg font-bold text-[13px] flex items-center justify-center gap-1.5 transition-all relative overflow-hidden disabled:opacity-70 disabled:cursor-wait">
                        <span class="btn-text flex items-center gap-1.5 transition-opacity duration-200">Đăng nhập</span>
                        <span class="btn-loading hidden absolute inset-0 bg-[#2c6f5e] flex items-center justify-center gap-2">
                            <span class="w-4 h-4 border-2 border-white/25 border-t-white rounded-full animate-spin"></span>
                            <span class="btn-loading-text text-[12px] font-semibold">Đang đăng nhập...</span>
                        </span>
                    </button>
                </form>

                <div class="auth-divider">
                    <span class="text-[10.5px] text-slate-400 font-semibold">hoặc</span>
                </div>
                <button type="button" class="auth-google-btn" title="Chưa tích hợp OAuth thật">
                    <svg width="15" height="15" viewBox="0 0 48 48"><path fill="#FFC107" d="M43.6 20.5H42V20H24v8h11.3C33.7 32.6 29.3 36 24 36c-6.6 0-12-5.4-12-12s5.4-12 12-12c3.1 0 5.8 1.1 8 3l5.7-5.7C34.6 6.1 29.6 4 24 4 12.9 4 4 12.9 4 24s8.9 20 20 20 20-8.9 20-20c0-1.3-.1-2.7-.4-3.5z"/><path fill="#FF3D00" d="M6.3 14.7l6.6 4.8C14.6 15.9 18.9 13 24 13c3.1 0 5.8 1.1 8 3l5.7-5.7C34.6 6.1 29.6 4 24 4 16.3 4 9.6 8.3 6.3 14.7z"/><path fill="#4CAF50" d="M24 44c5.5 0 10.4-1.9 14.2-5.1l-6.6-5.4C29.5 35.4 26.9 36 24 36c-5.3 0-9.7-3.4-11.3-8.1l-6.6 5.1C9.5 39.6 16.2 44 24 44z"/><path fill="#1976D2" d="M43.6 20.5H42V20H24v8h11.3c-.8 2.3-2.3 4.2-4.2 5.5l6.6 5.4C41.5 35.9 44 30.3 44 24c0-1.3-.1-2.7-.4-3.5z"/></svg>
                    Tiếp tục với Google
                </button>

                <div class="mt-4 text-center border-t border-slate-100 pt-3">
                    <p class="text-[11.5px] text-slate-500 font-medium">
                        Chưa có tài khoản?
                        <button onclick="switchAuthTab('register')" class="font-bold text-[#378b76] hover:underline ml-1">Tạo tài khoản</button>
                    </p>
                </div>
            </div>

            <!-- REGISTER PANEL -->
            <div id="modal-register-panel" class="modal-panel hidden flex flex-col">
                <div id="register-error-banner" class="hidden mb-4 p-3 bg-red-50 text-red-600 rounded-lg text-[11.5px] font-semibold border border-red-100 flex items-center gap-2 shadow-sm">
                    <span class="material-symbols-outlined text-[16px]">error</span>
                    <span class="error-msg"></span>
                </div>

                <form id="modal-register-form" action="${pageContext.request.contextPath}/dangky" method="POST" class="flex flex-col" autocomplete="off" onsubmit="submitRegisterForm(event)">
                    <!-- Giới tính không bắt buộc phía backend nhưng lưu mặc định an toàn -->
                    <input type="hidden" name="gender" value="Khác">

                    <div class="mb-3">
                        <label class="text-[11.5px] font-bold text-slate-700 mb-1 block">Tên đăng nhập</label>
                        <input type="text" name="username" required placeholder="Tên đăng nhập" class="w-full h-10 px-3 border-1.5 border-slate-300 rounded-lg text-[12.5px] font-medium text-slate-900 focus:border-[#378b76] focus:ring-2 focus:ring-[#378b76]/10 transition-all outline-none" style="border-width: 1.5px;">
                    </div>
                    <div class="mb-3">
                        <label class="text-[11.5px] font-bold text-slate-700 mb-1 block">Họ và tên</label>
                        <input type="text" name="fullname" required placeholder="Nhập họ và tên" class="w-full h-10 px-3 border-1.5 border-slate-300 rounded-lg text-[12.5px] font-medium text-slate-900 focus:border-[#378b76] focus:ring-2 focus:ring-[#378b76]/10 transition-all outline-none" style="border-width: 1.5px;">
                    </div>
                    <div class="mb-3">
                        <label class="text-[11.5px] font-bold text-slate-700 mb-1 block">Email</label>
                        <input type="email" name="email" required placeholder="Địa chỉ email" class="w-full h-10 px-3 border-1.5 border-slate-300 rounded-lg text-[12.5px] font-medium text-slate-900 focus:border-[#378b76] focus:ring-2 focus:ring-[#378b76]/10 transition-all outline-none" style="border-width: 1.5px;">
                    </div>
                    <div class="mb-3">
                        <label class="text-[11.5px] font-bold text-slate-700 mb-1 block">Số điện thoại</label>
                        <input type="tel" name="phone" required placeholder="Nhập số điện thoại" class="w-full h-10 px-3 border-1.5 border-slate-300 rounded-lg text-[12.5px] font-medium text-slate-900 focus:border-[#378b76] focus:ring-2 focus:ring-[#378b76]/10 transition-all outline-none" style="border-width: 1.5px;">
                    </div>
                    <div class="mb-3 relative">
                        <label class="text-[11.5px] font-bold text-slate-700 mb-1 block">Mật khẩu</label>
                        <div class="relative">
                            <input type="password" name="password" id="modal-reg-pass" required placeholder="Tạo mật khẩu" oninput="updateModalPwStrength(this)" class="w-full h-10 pl-3 pr-9 border-1.5 border-slate-300 rounded-lg text-[12.5px] font-medium text-slate-900 focus:border-[#378b76] focus:ring-2 focus:ring-[#378b76]/10 transition-all outline-none" style="border-width: 1.5px;">
                            <button type="button" onclick="togglePassField('modal-reg-pass', this)" class="absolute right-2.5 top-1/2 -translate-y-1/2 text-slate-400 hover:text-[#378b76] transition-all">
                                <span class="material-symbols-outlined text-[18px]">visibility</span>
                            </button>
                        </div>
                        <div class="mt-1.5 flex gap-1 w-full">
                            <div class="h-1 flex-1 rounded-full bg-slate-200 transition-colors duration-300" id="modalRegStr1"></div>
                            <div class="h-1 flex-1 rounded-full bg-slate-200 transition-colors duration-300" id="modalRegStr2"></div>
                            <div class="h-1 flex-1 rounded-full bg-slate-200 transition-colors duration-300" id="modalRegStr3"></div>
                            <div class="h-1 flex-1 rounded-full bg-slate-200 transition-colors duration-300" id="modalRegStr4"></div>
                        </div>
                        <p class="text-[9.5px] text-slate-400 leading-tight mt-1">Tối thiểu 8 ký tự, gồm chữ hoa, thường, số và ký tự đặc biệt.</p>
                    </div>
                    <div class="mb-3 relative">
                        <label class="text-[11.5px] font-bold text-slate-700 mb-1 block">Xác nhận mật khẩu</label>
                        <div class="relative">
                            <input type="password" name="confirm_password" id="modal-reg-confirm" required placeholder="Nhập lại mật khẩu" class="w-full h-10 pl-3 pr-9 border-1.5 border-slate-300 rounded-lg text-[12.5px] font-medium text-slate-900 focus:border-[#378b76] focus:ring-2 focus:ring-[#378b76]/10 transition-all outline-none" style="border-width: 1.5px;">
                            <button type="button" onclick="togglePassField('modal-reg-confirm', this)" class="absolute right-2.5 top-1/2 -translate-y-1/2 text-slate-400 hover:text-[#378b76] transition-all">
                                <span class="material-symbols-outlined text-[18px]">visibility</span>
                            </button>
                        </div>
                    </div>

                    <div class="flex items-start gap-2 select-none mb-3.5">
                        <input type="checkbox" name="agree" value="Đồng ý" required class="w-3.5 h-3.5 mt-0.5 accent-[#378b76] rounded border-slate-300 cursor-pointer">
                        <span class="text-[10.5px] text-slate-500 font-semibold leading-tight">
                            Tôi đồng ý với <a href="#" class="text-[#378b76] font-bold hover:underline">điều khoản</a> và <a href="#" class="text-[#378b76] font-bold hover:underline">chính sách</a>.
                        </span>
                    </div>
                    <button type="submit" id="modal-register-btn" class="w-full h-10 bg-[#378b76] hover:bg-[#2c6f5e] text-white rounded-lg font-bold text-[13px] flex items-center justify-center gap-1.5 transition-all relative overflow-hidden">
                        <span class="btn-text flex items-center gap-1.5">Tạo tài khoản</span>
                        <div class="loading-spinner hidden absolute inset-0 bg-[#2c6f5e] flex items-center justify-center gap-2">
                            <div class="w-4 h-4 border-2 border-white/20 border-t-white rounded-full animate-spin"></div>
                            <span class="text-[12px] font-semibold text-white">Đang gửi OTP...</span>
                        </div>
                    </button>
                </form>

                <div class="mt-4 text-center border-t border-slate-100 pt-3">
                    <p class="text-[11.5px] text-slate-500 font-medium">
                        Đã có tài khoản?
                        <button onclick="switchAuthTab('login')" class="font-bold text-[#378b76] hover:underline ml-1">Đăng nhập ngay</button>
                    </p>
                </div>
            </div>

            <!-- FORGOT PASSWORD PANEL -->
            <div id="modal-forgot-password-panel" class="modal-panel hidden flex flex-col">
                <div class="mb-4">
                    <h2 class="text-[15px] font-bold tracking-tight text-slate-900 mb-1">Quên mật khẩu?</h2>
                    <p class="text-[11.5px] text-slate-400 font-medium leading-relaxed">Nhập email đã đăng ký để khôi phục mật khẩu.</p>
                </div>
                <div id="forgot-password-error-banner" class="hidden mb-4 p-3 bg-red-50 text-red-600 border border-red-100 rounded-lg text-[11.5px] font-semibold flex items-center gap-2 shadow-sm">
                    <span class="material-symbols-outlined text-[16px] shrink-0">error</span>
                    <span class="error-msg"></span>
                </div>
                <form id="modal-forgot-password-form" action="${pageContext.request.contextPath}/quenmatkhau" method="POST" class="flex flex-col" autocomplete="off" onsubmit="submitForgotPasswordForm(event)">
                    <div class="mb-4">
                        <label class="text-[11.5px] font-bold text-slate-700 mb-1 block">Email đã đăng ký</label>
                        <input type="email" name="email" required placeholder="Nhập địa chỉ email" class="w-full h-10 px-3 border-1.5 border-slate-300 rounded-lg text-[12.5px] font-medium text-slate-900 focus:border-[#378b76] focus:ring-2 focus:ring-[#378b76]/10 transition-all outline-none" style="border-width: 1.5px;">
                    </div>
                    <button type="submit" id="modal-forgot-password-btn" class="w-full h-10 bg-[#378b76] hover:bg-[#2c6f5e] text-white rounded-lg font-bold text-[13px] flex items-center justify-center gap-1.5 transition-all relative overflow-hidden">
                        <span class="btn-text flex items-center gap-1.5">Gửi mã xác thực</span>
                        <div class="loading-spinner hidden absolute inset-0 bg-[#2c6f5e] flex items-center justify-center gap-2">
                            <div class="w-4 h-4 border-2 border-white/20 border-t-white rounded-full animate-spin"></div>
                            <span class="text-[12px] font-semibold text-white">Đang gửi mã...</span>
                        </div>
                    </button>
                </form>
                <div class="mt-4 text-center border-t border-slate-100 pt-3">
                    <p class="text-[11.5px] text-slate-500 font-medium">
                        Nhớ lại mật khẩu?
                        <button onclick="switchAuthTab('login')" class="font-bold text-[#378b76] hover:underline ml-1 cursor-pointer">Đăng nhập</button>
                    </p>
                </div>
            </div>

            <!-- OTP PANEL -->
            <div id="modal-otp-panel" class="modal-panel hidden flex flex-col">
                <div class="mb-4">
                    <h2 class="text-[15px] font-bold tracking-tight text-slate-900 mb-1">Xác thực OTP</h2>
                    <p class="text-[11.5px] text-slate-400 font-medium leading-relaxed">
                        Nhập mã 6 chữ số đã gửi tới <b id="otp-email-display" class="text-slate-800"></b>.
                    </p>
                </div>
                <div id="otp-error-banner" class="hidden mb-4 p-3 bg-red-50 text-red-650 border border-red-100 rounded-lg text-[11.5px] font-semibold flex items-center gap-2 shadow-sm">
                    <span class="material-symbols-outlined text-[16px] shrink-0">error</span>
                    <span class="error-msg"></span>
                </div>
                <div id="otp-success-banner" class="hidden mb-4 p-3 bg-emerald-50 text-emerald-600 border border-emerald-100 rounded-lg text-[11.5px] font-semibold flex items-center gap-2 shadow-sm">
                    <span class="material-symbols-outlined text-[16px] shrink-0">check_circle</span>
                    <span class="success-msg"></span>
                </div>
                <form id="modal-otp-form" action="${pageContext.request.contextPath}/nhapma" method="POST" class="flex flex-col" autocomplete="off" onsubmit="submitOtpForm(event)">
                    <input type="hidden" name="email" id="otp-hidden-email">
                    <div class="mb-4">
                        <label class="text-[11.5px] font-bold text-slate-700 mb-1 block">Mã OTP 6 chữ số</label>
                        <input type="text" name="otp" required maxlength="6" placeholder="••••••" class="w-full h-12 border-1.5 border-slate-300 rounded-lg text-center text-xl font-bold tracking-[0.3em] focus:border-[#378b76] focus:ring-2 focus:ring-[#378b76]/10 transition-all outline-none" style="border-width: 1.5px;">
                    </div>
                    <button type="submit" id="modal-otp-btn" class="w-full h-10 bg-[#378b76] hover:bg-[#2c6f5e] text-white rounded-lg font-bold text-[13px] flex items-center justify-center gap-1.5 transition-all relative overflow-hidden">
                        <span class="btn-text flex items-center gap-1.5">Xác minh OTP</span>
                        <div class="loading-spinner hidden absolute inset-0 bg-[#2c6f5e] flex items-center justify-center gap-2">
                            <div class="w-4 h-4 border-2 border-white/20 border-t-white rounded-full animate-spin"></div>
                            <span class="text-[12px] font-semibold text-white">Đang xác thực...</span>
                        </div>
                    </button>
                </form>
                <div class="mt-4 text-center border-t border-slate-100 pt-3 flex flex-col gap-1.5">
                    <p class="text-[11.5px] text-slate-500 font-medium">
                        Không nhận được mã?
                        <button onclick="resendOtp()" class="font-bold text-[#378b76] hover:underline ml-1 cursor-pointer">Gửi lại</button>
                    </p>
                    <p class="text-[11.5px]">
                        <button onclick="goBackFromOtp()" class="font-bold text-slate-400 hover:text-slate-600 hover:underline cursor-pointer flex items-center justify-center gap-1 mx-auto">
                            <span class="material-symbols-outlined text-[14px]">arrow_back</span> Quay lại
                        </button>
                    </p>
                </div>
            </div>

            <!-- RESET PASSWORD PANEL -->
            <div id="modal-reset-password-panel" class="modal-panel hidden flex flex-col">
                <div class="mb-4">
                    <h2 class="text-[15px] font-bold tracking-tight text-slate-900 mb-1">Mật khẩu mới</h2>
                    <p class="text-[11.5px] text-slate-400 font-medium leading-relaxed">Tạo mật khẩu mới cho tài khoản của bạn.</p>
                </div>
                <div id="reset-password-error-banner" class="hidden mb-4 p-3 bg-red-50 text-red-650 border border-red-100 rounded-lg text-[11.5px] font-semibold flex items-center gap-2 shadow-sm">
                    <span class="material-symbols-outlined text-[16px] shrink-0">error</span>
                    <span class="error-msg"></span>
                </div>
                <form id="modal-reset-password-form" action="${pageContext.request.contextPath}/nhapmatkhaumoi" method="POST" class="flex flex-col gap-3" onsubmit="submitResetPasswordForm(event)">
                    <div class="relative">
                        <label class="text-[11.5px] font-bold text-slate-700 mb-1 block">Mật khẩu mới</label>
                        <div class="relative">
                            <input type="password" name="password" id="modal-new-pass" required placeholder="••••••••" oninput="updateModalResetPwStrength(this)" class="w-full h-10 pl-3 pr-9 border-1.5 border-slate-300 rounded-lg text-[12.5px] font-medium text-slate-900 focus:border-[#378b76] focus:ring-2 focus:ring-[#378b76]/10 transition-all outline-none" style="border-width: 1.5px;">
                            <button type="button" onclick="togglePassField('modal-new-pass', this)" class="absolute right-2.5 top-1/2 -translate-y-1/2 text-slate-400 hover:text-[#378b76]">
                                <span class="material-symbols-outlined text-[18px]">visibility</span>
                            </button>
                        </div>
                        <div class="mt-1.5 flex gap-1 w-full">
                            <div class="h-1 flex-1 rounded-full bg-slate-200 transition-colors duration-300" id="modalResetStr1"></div>
                            <div class="h-1 flex-1 rounded-full bg-slate-200 transition-colors duration-300" id="modalResetStr2"></div>
                            <div class="h-1 flex-1 rounded-full bg-slate-200 transition-colors duration-300" id="modalResetStr3"></div>
                            <div class="h-1 flex-1 rounded-full bg-slate-200 transition-colors duration-300" id="modalResetStr4"></div>
                        </div>
                    </div>
                    <div class="relative">
                        <label class="text-[11.5px] font-bold text-slate-700 mb-1 block">Xác nhận mật khẩu mới</label>
                        <div class="relative">
                            <input type="password" name="confirm_password" id="modal-new-confirm" required placeholder="••••••••" class="w-full h-10 pl-3 pr-9 border-1.5 border-slate-300 rounded-lg text-[12.5px] font-medium text-slate-900 focus:border-[#378b76] focus:ring-2 focus:ring-[#378b76]/10 transition-all outline-none" style="border-width: 1.5px;">
                            <button type="button" onclick="togglePassField('modal-new-confirm', this)" class="absolute right-2.5 top-1/2 -translate-y-1/2 text-slate-400 hover:text-[#378b76]">
                                <span class="material-symbols-outlined text-[18px]">visibility</span>
                            </button>
                        </div>
                    </div>
                    <button type="submit" id="modal-reset-password-btn" class="w-full h-10 bg-[#378b76] hover:bg-[#2c6f5e] text-white rounded-lg font-bold text-[13px] flex items-center justify-center gap-1.5 transition-all relative overflow-hidden mt-1">
                        <span class="btn-text flex items-center gap-1.5">Lưu mật khẩu mới</span>
                        <div class="loading-spinner hidden absolute inset-0 bg-[#2c6f5e] flex items-center justify-center gap-2">
                            <div class="w-4 h-4 border-2 border-white/20 border-t-white rounded-full animate-spin"></div>
                            <span class="text-[12px] font-semibold text-white">Đang cập nhật...</span>
                        </div>
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
        const card = document.getElementById('auth-modal-card');
        const trigger = triggerEl || resolveDefaultTrigger();
        if (!card) return;
        const cardWidth = 360;
        let top, right;
        if (trigger) {
            const rect = trigger.getBoundingClientRect();
            top = rect.bottom + 8;
            right = Math.max(8, window.innerWidth - rect.right);
        } else {
            top = 70;
            right = 24;
        }
        if (window.innerWidth - right - cardWidth < 8) {
            right = Math.max(8, window.innerWidth - cardWidth - 8);
        }
        const modal = document.getElementById('auth-modal');
        modal.style.top = top + 'px';
        modal.style.right = right + 'px';
    }

    function openAuthModal(tab = 'login', triggerEl = null) {
        const modal = document.getElementById('auth-modal');
        const card = document.getElementById('auth-modal-card');
        if (!modal || !card) return;
        authTriggerEl = triggerEl || resolveDefaultTrigger();
        clearModalAlerts();
        positionAuthModal(authTriggerEl);
        modal.classList.add('is-open');
        requestAnimationFrame(() => { card.classList.add('is-visible'); });

        ['modal-login-panel','modal-register-panel','modal-forgot-password-panel','modal-otp-panel','modal-reset-password-panel'].forEach(id => {
            const el = document.getElementById(id);
            if (el) el.classList.add('hidden');
        });
        const tabHeader = document.getElementById('modal-tabs-header');
        const tabLogin = document.getElementById('modal-tab-login');
        const tabRegister = document.getElementById('modal-tab-register');
        if (tab === 'login' || tab === 'register') {
            if (tabHeader) tabHeader.classList.remove('hidden');
            if (tab === 'login') {
                tabLogin.classList.replace('text-slate-400','text-slate-900'); tabLogin.classList.replace('border-transparent','border-[#378b76]');
                tabRegister.classList.replace('text-slate-900','text-slate-400'); tabRegister.classList.replace('border-[#378b76]','border-transparent');
                const p = document.getElementById('modal-login-panel');
                p.classList.remove('hidden'); p.style.opacity='1'; p.style.transform='translateY(0)';
            } else {
                tabRegister.classList.replace('text-slate-400','text-slate-900'); tabRegister.classList.replace('border-transparent','border-[#378b76]');
                tabLogin.classList.replace('text-slate-900','text-slate-400'); tabLogin.classList.replace('border-[#378b76]','border-transparent');
                const p = document.getElementById('modal-register-panel');
                p.classList.remove('hidden'); p.style.opacity='1'; p.style.transform='translateY(0)';
            }
        } else {
            if (tabHeader) tabHeader.classList.add('hidden');
            const map = {'forgot-password':'modal-forgot-password-panel','otp':'modal-otp-panel','reset-password':'modal-reset-password-panel'};
            const p = document.getElementById(map[tab]);
            if (p) { p.classList.remove('hidden'); p.style.opacity='1'; p.style.transform='translateY(0)'; }
        }
    }

    function closeAuthModal() {
        setLoginFormLoading(false);
        const modal = document.getElementById('auth-modal');
        const card = document.getElementById('auth-modal-card');
        if (!modal || !card) return;
        card.classList.remove('is-visible');
        setTimeout(() => { modal.classList.remove('is-open'); }, 180);
    }

    // Click ra ngoài dropdown thì đóng lại
    document.addEventListener('click', (e) => {
        const modal = document.getElementById('auth-modal');
        if (!modal || !modal.classList.contains('is-open')) return;
        const card = document.getElementById('auth-modal-card');
        if (card && card.contains(e.target)) return;
        if (authTriggerEl && authTriggerEl.contains(e.target)) return;
        closeAuthModal();
    });

    // ESC đóng dropdown
    document.addEventListener('keydown', (e) => {
        if (e.key !== 'Escape') return;
        const modal = document.getElementById('auth-modal');
        if (modal && modal.classList.contains('is-open')) closeAuthModal();
    });

    function switchAuthTab(tab) {
        const tabHeader = document.getElementById('modal-tabs-header');
        const tabLogin = document.getElementById('modal-tab-login');
        const tabRegister = document.getElementById('modal-tab-register');
        const panelMap = {
            'login': 'modal-login-panel',
            'register': 'modal-register-panel',
            'forgot-password': 'modal-forgot-password-panel',
            'otp': 'modal-otp-panel',
            'reset-password': 'modal-reset-password-panel'
        };
        const currentPanel = document.querySelector('.modal-panel:not(.hidden)');
        if (!currentPanel) return;
        const targetPanel = document.getElementById(panelMap[tab]);
        if (!targetPanel || targetPanel === currentPanel) return;

        if (tab === 'otp') {
            const registerPanel = document.getElementById('modal-register-panel');
            const forgotPanel = document.getElementById('modal-forgot-password-panel');
            if (currentPanel === forgotPanel) otpSourceTab = 'forgot-password';
            else if (currentPanel === registerPanel) otpSourceTab = 'register';
        }

        clearModalAlerts();
        currentPanel.style.opacity = '0';
        currentPanel.style.transform = 'translateY(8px)';

        if (tab === 'login' || tab === 'register') {
            if (tabHeader) tabHeader.classList.remove('hidden');
            if (tab === 'login') {
                tabLogin.classList.remove('text-slate-400','border-transparent'); tabLogin.classList.add('text-slate-900','border-[#378b76]');
                tabRegister.classList.remove('text-slate-900','border-[#378b76]'); tabRegister.classList.add('text-slate-400','border-transparent');
            } else {
                tabRegister.classList.remove('text-slate-400','border-transparent'); tabRegister.classList.add('text-slate-900','border-[#378b76]');
                tabLogin.classList.remove('text-slate-900','border-[#378b76]'); tabLogin.classList.add('text-slate-400','border-transparent');
            }
        } else {
            if (tabHeader) tabHeader.classList.add('hidden');
        }

        setTimeout(() => {
            currentPanel.classList.add('hidden');
            targetPanel.classList.remove('hidden');
            targetPanel.style.opacity = '0';
            targetPanel.style.transform = 'translateY(8px)';
            targetPanel.style.transition = 'opacity 200ms ease-out, transform 200ms ease-out';
            requestAnimationFrame(() => {
                setTimeout(() => { targetPanel.style.opacity='1'; targetPanel.style.transform='translateY(0)'; }, 20);
            });
        }, 120);
    }

    function goBackFromOtp() { switchAuthTab(otpSourceTab); }

    function clearModalAlerts() {
        ['login-error-banner','login-success-banner','register-error-banner','forgot-password-error-banner','otp-error-banner','otp-success-banner','reset-password-error-banner'].forEach(id => {
            const el = document.getElementById(id);
            if (el) el.classList.add('hidden');
        });
    }

    function togglePassField(id, btn) {
        const input = document.getElementById(id);
        const icon = btn.querySelector('span');
        if (input) {
            input.type = input.type === 'password' ? 'text' : 'password';
            icon.textContent = input.type === 'password' ? 'visibility' : 'visibility_off';
        }
    }

    function updateModalPwStrength(inp) {
        const v = inp.value;
        let s = 0;
        if (v.length >= 8) s++; if (/[A-Z]/.test(v)) s++; if (/[a-z]/.test(v)) s++;
        if (/[0-9]/.test(v)) s++; if (/[^A-Za-z0-9]/.test(v)) s++;
        let strength = 0;
        if (v.length > 0) strength = 1; if (s >= 3) strength = 2; if (s >= 4) strength = 3; if (s >= 5) strength = 4;
        const cols = ['#f43f5e','#f59e0b','#8b5cf6','#10b981'];
        for (let i = 1; i <= 4; i++) {
            const el = document.getElementById('modalRegStr' + i);
            if (el) el.style.backgroundColor = i <= strength ? cols[strength-1] : '#e2e8f0';
        }
    }

    function updateModalResetPwStrength(inp) {
        const v = inp.value;
        let s = 0;
        if (v.length >= 8) s++; if (/[A-Z]/.test(v)) s++; if (/[a-z]/.test(v)) s++;
        if (/[0-9]/.test(v)) s++; if (/[^A-Za-z0-9]/.test(v)) s++;
        let strength = 0;
        if (v.length > 0) strength = 1; if (s >= 3) strength = 2; if (s >= 4) strength = 3; if (s >= 5) strength = 4;
        const cols = ['#f43f5e','#f59e0b','#8b5cf6','#10b981'];
        for (let i = 1; i <= 4; i++) {
            const el = document.getElementById('modalResetStr' + i);
            if (el) el.style.backgroundColor = i <= strength ? cols[strength-1] : '#e2e8f0';
        }
    }

    // ✅ FIX: Chỉ disable button[type="button"], KHÔNG disable input
    function setLoginFormLoading(isLoading, message = 'Đang đăng nhập...') {
        const form = document.getElementById('modal-login-form');
        const btn = document.getElementById('modal-login-btn');
        const overlay = document.getElementById('auth-loading-overlay');
        const overlayText = document.getElementById('auth-loading-text');
        const btnText = btn ? btn.querySelector('.btn-text') : null;
        const btnLoading = btn ? btn.querySelector('.btn-loading') : null;
        const closeBtn = document.querySelector('#auth-modal-card > button[onclick="closeAuthModal()"]');
        const tabButtons = document.querySelectorAll('#modal-tabs-header button');

        if (overlayText) overlayText.textContent = message;

        if (isLoading) {
            if (overlay) { overlay.classList.remove('hidden'); overlay.classList.add('is-visible'); }
            if (btn) { btn.disabled = true; btn.classList.add('is-loading'); }
            if (btnText) btnText.classList.add('hidden');
            if (btnLoading) btnLoading.classList.remove('hidden');
            // ✅ Chỉ disable toggle button, KHÔNG disable input
            if (form) {
                form.querySelectorAll('button[type="button"]').forEach(el => {
                    el.dataset.wasDisabled = el.disabled ? '1' : '0';
                    el.disabled = true;
                    el.style.pointerEvents = 'none';
                });
            }
            if (closeBtn) closeBtn.style.pointerEvents = 'none';
            tabButtons.forEach(t => t.style.pointerEvents = 'none');
        } else {
            if (overlay) { overlay.classList.add('hidden'); overlay.classList.remove('is-visible'); }
            if (btn) { btn.disabled = false; btn.classList.remove('is-loading'); }
            if (btnText) btnText.classList.remove('hidden');
            if (btnLoading) btnLoading.classList.add('hidden');
            if (form) {
                form.querySelectorAll('button[type="button"]').forEach(el => {
                    el.disabled = el.dataset.wasDisabled === '1';
                    el.style.pointerEvents = '';
                });
            }
            if (closeBtn) closeBtn.style.pointerEvents = '';
            tabButtons.forEach(t => t.style.pointerEvents = '');
        }
    }

    // ✅ FIX: Lấy FormData TRƯỚC khi gọi setLoginFormLoading
    function submitLoginForm(event) {
        event.preventDefault();
        const form = document.getElementById('modal-login-form');
        const errorBanner = document.getElementById('login-error-banner');
        const successBanner = document.getElementById('login-success-banner');
        if (errorBanner) errorBanner.classList.add('hidden');
        if (successBanner) successBanner.classList.add('hidden');

        // ✅ Lấy data TRƯỚC khi loading (input chưa bị disable)
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
                setLoginFormLoading(true, 'Đăng nhập thành công! Đang chuyển hướng...');
                if (successBanner) {
                    successBanner.querySelector('.success-msg').textContent = 'Đăng nhập thành công! Đang chuyển hướng...';
                    successBanner.classList.remove('hidden');
                }
                setTimeout(() => { window.location.href = data.redirectUrl; }, 600);
            } else {
                setLoginFormLoading(false);
                if (errorBanner) {
                    errorBanner.querySelector('.error-msg').textContent = data.loi || 'Đăng nhập không thành công.';
                    errorBanner.classList.remove('hidden');
                }
            }
        })
        .catch(err => {
            console.error('Lỗi login AJAX:', err);
            setLoginFormLoading(false);
            if (errorBanner) {
                errorBanner.querySelector('.error-msg').textContent = 'Có lỗi mạng xảy ra. Vui lòng thử lại!';
                errorBanner.classList.remove('hidden');
            }
        });
    }

    function submitRegisterForm(event) {
        event.preventDefault();
        const form = document.getElementById('modal-register-form');
        const btn = document.getElementById('modal-register-btn');
        const spinner = btn.querySelector('.loading-spinner');
        const btnText = btn.querySelector('.btn-text');
        const errorBanner = document.getElementById('register-error-banner');
        if (errorBanner) errorBanner.classList.add('hidden');

        // Client-side validations
        const username = form.username.value.trim();
        const email = form.email.value.trim();
        const phone = form.phone.value.trim();
        const password = document.getElementById('modal-reg-pass').value;
        const confirmPassword = document.getElementById('modal-reg-confirm').value;

        function showError(msg) {
            if (errorBanner) {
                errorBanner.querySelector('.error-msg').textContent = msg;
                errorBanner.classList.remove('hidden');
                const scrollContainer = document.querySelector('.auth-modal-scroll');
                if (scrollContainer) scrollContainer.scrollTop = 0;
            }
        }

        if (username.indexOf(' ') >= 0) {
            showError("Tên đăng nhập không được chứa khoảng trắng!");
            return false;
        }
        if (username.length < 3 || username.length > 50) {
            showError("Tên đăng nhập phải từ 3 đến 50 ký tự!");
            return false;
        }

        if (email.indexOf(' ') >= 0) {
            showError("Email không được chứa khoảng trắng!");
            return false;
        }
        const emailRegex = /^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/;
        if (!emailRegex.test(email)) {
            showError("Định dạng Email không hợp lệ!");
            return false;
        }

        const phoneRegex = /^(0|\+84)[35789][0-9]{8}$/;
        if (!phoneRegex.test(phone)) {
            showError("Số điện thoại không hợp lệ (Phải bắt đầu bằng 0 hoặc +84 và có 10 số)!");
            return false;
        }

        if (password !== confirmPassword) {
            showError("Mật khẩu xác nhận không khớp!");
            return false;
        }

        const passRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$/;
        if (!passRegex.test(password)) {
            showError("Mật khẩu không đủ mạnh! Phải có tối thiểu 8 ký tự, bao gồm chữ hoa, chữ thường, số và ký tự đặc biệt.");
            return false;
        }

        if (spinner && btnText) { spinner.classList.remove('hidden'); btnText.style.opacity='0'; btn.style.pointerEvents='none'; }
        const searchParams = new URLSearchParams(new FormData(form));
        fetch(form.action, {
            method: 'POST',
            headers: { 'Accept': 'application/json', 'X-Requested-With': 'XMLHttpRequest', 'Content-Type': 'application/x-www-form-urlencoded' },
            body: searchParams
        })
        .then(res => res.json())
        .then(data => {
            if (data.success) {
                if (data.step === 'otp') {
                    const displayEl = document.getElementById('otp-email-display');
                    const hiddenEmailEl = document.getElementById('otp-hidden-email');
                    if (displayEl) displayEl.textContent = data.email;
                    if (hiddenEmailEl) hiddenEmailEl.value = data.email;
                    if (spinner && btnText) { spinner.classList.add('hidden'); btnText.style.opacity='1'; btn.style.pointerEvents=''; }
                    const otpSuccessBanner = document.getElementById('otp-success-banner');
                    if (otpSuccessBanner) { otpSuccessBanner.querySelector('.success-msg').textContent='Đăng ký thông tin thành công! Vui lòng nhập mã OTP để kích hoạt.'; otpSuccessBanner.classList.remove('hidden'); }
                    switchAuthTab('otp');
                } else {
                    window.location.href = data.redirectUrl;
                }
            } else {
                if (spinner && btnText) { spinner.classList.add('hidden'); btnText.style.opacity='1'; btn.style.pointerEvents=''; }
                if (errorBanner) {
                    errorBanner.querySelector('.error-msg').textContent = data.loi || 'Đăng ký không thành công.';
                    errorBanner.classList.remove('hidden');
                    const scrollContainer = document.querySelector('.auth-modal-scroll');
                    if (scrollContainer) scrollContainer.scrollTop = 0;
                }
            }
        })
        .catch(err => {
            console.error('Lỗi register AJAX:', err);
            if (spinner && btnText) { spinner.classList.add('hidden'); btnText.style.opacity='1'; btn.style.pointerEvents=''; }
            if (errorBanner) { errorBanner.querySelector('.error-msg').textContent='Có lỗi mạng xảy ra. Vui lòng thử lại!'; errorBanner.classList.remove('hidden'); }
        });
    }

    function submitForgotPasswordForm(event) {
        event.preventDefault();
        const form = document.getElementById('modal-forgot-password-form');
        const btn = document.getElementById('modal-forgot-password-btn');
        const spinner = btn.querySelector('.loading-spinner');
        const btnText = btn.querySelector('.btn-text');
        const errorBanner = document.getElementById('forgot-password-error-banner');
        if (errorBanner) errorBanner.classList.add('hidden');
        const formData = new FormData(form);
        const email = formData.get('email');
        if (spinner && btnText) { spinner.classList.remove('hidden'); btnText.style.opacity='0'; btn.style.pointerEvents='none'; }
        fetch(form.action, {
            method: 'POST',
            headers: { 'Accept': 'application/json', 'X-Requested-With': 'XMLHttpRequest', 'Content-Type': 'application/x-www-form-urlencoded' },
            body: new URLSearchParams(formData)
        })
        .then(res => res.json())
        .then(data => {
            if (spinner && btnText) { spinner.classList.add('hidden'); btnText.style.opacity='1'; btn.style.pointerEvents=''; }
            if (data.success) {
                const displayEl = document.getElementById('otp-email-display');
                const hiddenEmailEl = document.getElementById('otp-hidden-email');
                if (displayEl) displayEl.textContent = email;
                if (hiddenEmailEl) hiddenEmailEl.value = email;
                const otpSuccessBanner = document.getElementById('otp-success-banner');
                if (otpSuccessBanner) { otpSuccessBanner.querySelector('.success-msg').textContent='Mã OTP đã được gửi đến email của bạn!'; otpSuccessBanner.classList.remove('hidden'); }
                switchAuthTab('otp');
            } else {
                if (errorBanner) { errorBanner.querySelector('.error-msg').textContent=data.loi||'Có lỗi xảy ra.'; errorBanner.classList.remove('hidden'); }
            }
        })
        .catch(err => {
            console.error('Lỗi Forgot Password AJAX:', err);
            if (spinner && btnText) { spinner.classList.add('hidden'); btnText.style.opacity='1'; btn.style.pointerEvents=''; }
            if (errorBanner) { errorBanner.querySelector('.error-msg').textContent='Có lỗi mạng xảy ra. Vui lòng thử lại!'; errorBanner.classList.remove('hidden'); }
        });
    }

    function submitOtpForm(event) {
        event.preventDefault();
        const form = document.getElementById('modal-otp-form');
        const btn = document.getElementById('modal-otp-btn');
        const spinner = btn.querySelector('.loading-spinner');
        const btnText = btn.querySelector('.btn-text');
        const errorBanner = document.getElementById('otp-error-banner');
        const successBanner = document.getElementById('otp-success-banner');
        if (errorBanner) errorBanner.classList.add('hidden');
        if (successBanner) successBanner.classList.add('hidden');
        if (spinner && btnText) { spinner.classList.remove('hidden'); btnText.style.opacity='0'; btn.style.pointerEvents='none'; }
        fetch(form.action, {
            method: 'POST',
            headers: { 'Accept': 'application/json', 'X-Requested-With': 'XMLHttpRequest', 'Content-Type': 'application/x-www-form-urlencoded' },
            body: new URLSearchParams(new FormData(form))
        })
        .then(res => res.json())
        .then(data => {
            if (spinner && btnText) { spinner.classList.add('hidden'); btnText.style.opacity='1'; btn.style.pointerEvents=''; }
            if (data.success) {
                if (data.step === 'reset-password') { switchAuthTab('reset-password'); }
                else if (data.step === 'register-success') {
                    switchAuthTab('login');
                    const loginSuccessBanner = document.getElementById('login-success-banner');
                    if (loginSuccessBanner) { loginSuccessBanner.querySelector('.success-msg').textContent=data.thongbao||'Đăng ký thành công! Vui lòng đăng nhập.'; loginSuccessBanner.classList.remove('hidden'); }
                }
            } else {
                if (errorBanner) { errorBanner.querySelector('.error-msg').textContent=data.loi||'Mã xác thực không đúng.'; errorBanner.classList.remove('hidden'); }
            }
        })
        .catch(err => {
            console.error('Lỗi Verify OTP AJAX:', err);
            if (spinner && btnText) { spinner.classList.add('hidden'); btnText.style.opacity='1'; btn.style.pointerEvents=''; }
            if (errorBanner) { errorBanner.querySelector('.error-msg').textContent='Có lỗi mạng xảy ra. Vui lòng thử lại!'; errorBanner.classList.remove('hidden'); }
        });
    }

    function resendOtp() {
        const errorBanner = document.getElementById('otp-error-banner');
        const successBanner = document.getElementById('otp-success-banner');
        const emailInput = document.getElementById('otp-hidden-email');
        if (errorBanner) errorBanner.classList.add('hidden');
        if (successBanner) successBanner.classList.add('hidden');
        if (!emailInput || !emailInput.value) {
            if (errorBanner) { errorBanner.querySelector('.error-msg').textContent='Không tìm thấy email để gửi lại mã!'; errorBanner.classList.remove('hidden'); }
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
                if (successBanner) { successBanner.querySelector('.success-msg').textContent=data.thongbao||'Gửi lại mã OTP thành công!'; successBanner.classList.remove('hidden'); }
            } else {
                if (errorBanner) { errorBanner.querySelector('.error-msg').textContent=data.loi||'Không thể gửi lại mã OTP.'; errorBanner.classList.remove('hidden'); }
            }
        })
        .catch(err => {
            console.error('Lỗi Resend OTP:', err);
            if (errorBanner) { errorBanner.querySelector('.error-msg').textContent='Có lỗi mạng xảy ra. Vui lòng thử lại!'; errorBanner.classList.remove('hidden'); }
        });
    }

    function submitResetPasswordForm(event) {
        event.preventDefault();
        const form = document.getElementById('modal-reset-password-form');
        const btn = document.getElementById('modal-reset-password-btn');
        const spinner = btn.querySelector('.loading-spinner');
        const btnText = btn.querySelector('.btn-text');
        const errorBanner = document.getElementById('reset-password-error-banner');
        if (errorBanner) errorBanner.classList.add('hidden');
        const p1 = document.getElementById('modal-new-pass').value;
        const p2 = document.getElementById('modal-new-confirm').value;
        if (p1.trim() === '') {
            if (errorBanner) { errorBanner.querySelector('.error-msg').textContent='Mật khẩu không được để trống hoặc chỉ chứa khoảng trắng!'; errorBanner.classList.remove('hidden'); }
            return;
        }
        if (!/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$/.test(p1)) {
            if (errorBanner) { errorBanner.querySelector('.error-msg').textContent='Mật khẩu phải có tối thiểu 8 ký tự, bao gồm cả chữ hoa, chữ thường, số và ký tự đặc biệt.'; errorBanner.classList.remove('hidden'); }
            return;
        }
        if (p1 !== p2) {
            if (errorBanner) { errorBanner.querySelector('.error-msg').textContent='Mật khẩu xác nhận chưa trùng khớp!'; errorBanner.classList.remove('hidden'); }
            return;
        }
        if (spinner && btnText) { spinner.classList.remove('hidden'); btnText.style.opacity='0'; btn.style.pointerEvents='none'; }
        fetch(form.action, {
            method: 'POST',
            headers: { 'Accept': 'application/json', 'X-Requested-With': 'XMLHttpRequest', 'Content-Type': 'application/x-www-form-urlencoded' },
            body: new URLSearchParams(new FormData(form))
        })
        .then(res => res.json())
        .then(data => {
            if (spinner && btnText) { spinner.classList.add('hidden'); btnText.style.opacity='1'; btn.style.pointerEvents=''; }
            if (data.success) {
                switchAuthTab('login');
                const loginSuccessBanner = document.getElementById('login-success-banner');
                if (loginSuccessBanner) { loginSuccessBanner.querySelector('.success-msg').textContent=data.thongbao||'Đổi mật khẩu thành công! Vui lòng đăng nhập lại.'; loginSuccessBanner.classList.remove('hidden'); }
            } else {
                if (errorBanner) { errorBanner.querySelector('.error-msg').textContent=data.loi||'Có lỗi xảy ra.'; errorBanner.classList.remove('hidden'); }
            }
        })
        .catch(err => {
            console.error('Lỗi Reset Password AJAX:', err);
            if (spinner && btnText) { spinner.classList.add('hidden'); btnText.style.opacity='1'; btn.style.pointerEvents=''; }
            if (errorBanner) { errorBanner.querySelector('.error-msg').textContent='Có lỗi mạng xảy ra. Vui lòng thử lại!'; errorBanner.classList.remove('hidden'); }
        });
    }

    document.addEventListener('DOMContentLoaded', () => {
        document.body.addEventListener('click', (e) => {
            const anchor = e.target.closest('a');
            if (anchor && anchor.href) {
                const url = new URL(anchor.href, window.location.origin);
                const path = url.pathname;
                if (anchor.hasAttribute('data-no-modal') || url.searchParams.has('admin') || url.searchParams.get('role') === 'admin') return;
                if (path.endsWith('/dangnhap')) { e.preventDefault(); openAuthModal('login'); }
                else if (path.endsWith('/dangky')) { e.preventDefault(); openAuthModal('register'); }
            }
        });
        const urlParams = new URLSearchParams(window.location.search);
        const authAction = urlParams.get('auth');
        if (authAction === 'login') openAuthModal('login');
        else if (authAction === 'register') openAuthModal('register');
    });
</script>
