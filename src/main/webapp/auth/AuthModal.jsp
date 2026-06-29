<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<style>
    .auth-modal-scroll::-webkit-scrollbar { width: 6px; }
    .auth-modal-scroll::-webkit-scrollbar-track { background: transparent; }
    .auth-modal-scroll::-webkit-scrollbar-thumb { background-color: #cbd5e1; border-radius: 20px; }

    #auth-modal-card {
        transition: max-width 400ms cubic-bezier(0.34, 1.56, 0.64, 1),
                    transform 300ms cubic-bezier(0.34, 1.56, 0.64, 1),
                    opacity 300ms ease-out;
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
</style>

<div id="auth-modal" class="fixed inset-0 z-[120] hidden items-center justify-center p-4 bg-slate-900/60 backdrop-blur-sm transition-opacity duration-300" onclick="handleBackdropClick(event)">

    <div id="auth-modal-card" class="bg-white rounded-3xl w-full max-w-[460px] max-h-[95vh] flex flex-col shadow-2xl relative border border-slate-100 transform scale-95 opacity-0">

        <!-- Loading overlay -->
        <div id="auth-loading-overlay" class="hidden absolute inset-0 z-[140] bg-white/85 backdrop-blur-sm rounded-3xl flex-col items-center justify-center gap-4">
            <div class="w-11 h-11 border-[3px] border-[#378b76]/20 border-t-[#378b76] rounded-full animate-spin"></div>
            <div class="text-center px-6">
                <p id="auth-loading-text" class="text-[14px] font-bold text-slate-800 auth-loading-pulse">Đang đăng nhập...</p>
                <p class="text-[12px] text-slate-400 mt-1">Vui lòng đợi trong giây lát</p>
            </div>
        </div>

        <!-- Close Button -->
        <button onclick="closeAuthModal()" class="absolute top-5 right-5 text-slate-400 hover:text-slate-600 transition-colors z-[130] w-8 h-8 rounded-full flex items-center justify-center bg-slate-50 hover:bg-slate-100">
            <span class="material-symbols-outlined text-[20px]">close</span>
        </button>

        <!-- Toggle Tabs -->
        <div id="modal-tabs-header" class="px-8 pt-8 pb-4 border-b border-slate-100 flex items-center justify-start gap-4">
            <button id="modal-tab-login" onclick="switchAuthTab('login')" class="text-xl font-bold tracking-tight text-slate-900 border-b-2 border-[#378b76] pb-2 transition-all">Đăng nhập</button>
            <button id="modal-tab-register" onclick="switchAuthTab('register')" class="text-xl font-bold tracking-tight text-slate-400 hover:text-slate-900 border-b-2 border-transparent pb-2 transition-all">Đăng ký</button>
        </div>

        <!-- Content Area -->
        <div class="flex-grow overflow-y-auto p-8 auth-modal-scroll">

            <!-- LOGIN PANEL -->
            <div id="modal-login-panel" class="modal-panel flex flex-col">
                <div class="mb-6">
                    <div class="inline-flex items-center gap-2 bg-white border border-[#378b76]/30 text-[#378b76] rounded-full py-1 px-3.5 text-[11px] font-bold w-fit shadow-sm mb-3">
                        <div class="w-1.5 h-1.5 rounded-full bg-[#378b76] animate-pulse"></div>
                        <span>Hệ thống V-Sport</span>
                    </div>
                    <p class="text-[13px] text-slate-400 font-medium">Chào mừng trở lại! Nhập thông tin tài khoản của bạn để tiếp tục.</p>
                </div>

                <div id="login-error-banner" class="hidden mb-6 p-4 bg-red-50 text-red-600 rounded-xl text-xs font-semibold border border-red-100 flex items-center gap-3 shadow-sm">
                    <span class="material-symbols-outlined text-[18px]">error</span>
                    <span class="error-msg"></span>
                </div>
                <div id="login-success-banner" class="hidden mb-6 p-4 bg-green-50 text-green-600 rounded-xl text-xs font-semibold border border-green-100 flex items-center gap-3 shadow-sm">
                    <span class="material-symbols-outlined text-[18px]">check_circle</span>
                    <span class="success-msg"></span>
                </div>

                <form id="modal-login-form" action="${pageContext.request.contextPath}/dangnhap" method="POST" class="flex flex-col" autocomplete="off" onsubmit="submitLoginForm(event)">
                    <input type="hidden" name="loginType" value="customer">
                    <div class="mb-4 relative">
                        <label class="text-[12px] font-bold text-slate-700 mb-1.5 block">Tên đăng nhập hoặc Email</label>
                        <div class="relative">
                            <input type="text" name="username" id="modal-login-username" required placeholder="Nhập tên đăng nhập hoặc email" class="w-full h-12 pl-12 pr-12 border-1.5 border-slate-300 rounded-xl text-[13px] font-medium text-slate-900 focus:border-[#378b76] focus:ring-4 focus:ring-[#378b76]/10 transition-all outline-none" style="border-width: 1.5px;">
                            <span class="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none text-[20px]">account_circle</span>
                        </div>
                    </div>
                    <div class="mb-5 relative">
                        <label class="text-[12px] font-bold text-slate-700 mb-1.5 block">Mật khẩu</label>
                        <div class="relative">
                            <input type="password" name="password" id="modal-login-pass" required placeholder="Nhập mật khẩu" class="w-full h-12 pl-12 pr-12 border-1.5 border-slate-300 rounded-xl text-[13px] font-medium text-slate-900 focus:border-[#378b76] focus:ring-4 focus:ring-[#378b76]/10 transition-all outline-none" style="border-width: 1.5px;">
                            <span class="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none text-[20px]">key</span>
                            <button type="button" onclick="togglePassField('modal-login-pass', this)" class="absolute right-4 top-1/2 -translate-y-1/2 text-slate-400 hover:text-[#378b76] transition-all">
                                <span class="material-symbols-outlined text-[20px]">visibility</span>
                            </button>
                        </div>
                    </div>
                    <div class="flex items-center justify-between mb-6">
                        <label class="flex items-center gap-2 cursor-pointer select-none text-[12px] text-slate-500 font-semibold">
                            <input type="checkbox" name="rememberMe" class="w-4 h-4 accent-[#378b76] rounded border-slate-300">
                            <span>Ghi nhớ đăng nhập (7 ngày)</span>
                        </label>
                        <button type="button" onclick="switchAuthTab('forgot-password')" class="text-[12px] font-bold text-[#378b76] hover:underline cursor-pointer">Quên mật khẩu?</button>
                    </div>
                    <button type="submit" id="modal-login-btn" class="w-full h-12 bg-[#378b76] hover:bg-[#2c6f5e] text-white rounded-xl font-bold text-[14px] flex items-center justify-center gap-2 transition-all relative overflow-hidden disabled:opacity-70 disabled:cursor-wait">
                        <span class="btn-text flex items-center gap-1.5 transition-opacity duration-200">
                            Đăng nhập
                            <span class="material-symbols-outlined text-[18px]">arrow_forward</span>
                        </span>
                        <span class="btn-loading hidden absolute inset-0 bg-[#2c6f5e] flex items-center justify-center gap-2.5 text-white">
                            <span class="w-5 h-5 border-2 border-white/25 border-t-white rounded-full animate-spin"></span>
                            <span class="btn-loading-text text-[13px] font-semibold">Đang đăng nhập...</span>
                        </span>
                    </button>
                </form>

                <div class="mt-5 text-center border-t border-slate-100 pt-4">
                    <p class="text-[12px] text-slate-500 font-medium">
                        Bạn chưa có tài khoản?
                        <button onclick="switchAuthTab('register')" class="font-bold text-[#378b76] hover:underline ml-1">Đăng ký ngay</button>
                    </p>
                </div>
            </div>

            <!-- REGISTER PANEL -->
            <div id="modal-register-panel" class="modal-panel hidden flex flex-col">
                <div class="mb-5">
                    <div class="inline-flex items-center gap-2 bg-white border border-[#378b76]/30 text-[#378b76] rounded-full py-1 px-3.5 text-[11px] font-bold w-fit shadow-sm mb-3">
                        <div class="w-1.5 h-1.5 rounded-full bg-[#378b76] animate-pulse"></div>
                        <span>Hệ thống V-Sport</span>
                    </div>
                    <p class="text-[13px] text-slate-400 font-medium">Bắt đầu hành trình chinh phục sân đấu và kết nối bạn bè ngay hôm nay.</p>
                </div>

                <div id="register-error-banner" class="hidden mb-5 p-4 bg-red-50 text-red-600 rounded-xl text-xs font-semibold border border-red-100 flex items-center gap-3 shadow-sm">
                    <span class="material-symbols-outlined text-[18px]">error</span>
                    <span class="error-msg"></span>
                </div>

                <form id="modal-register-form" action="${pageContext.request.contextPath}/dangky" method="POST" class="flex flex-col" autocomplete="off" onsubmit="submitRegisterForm(event)">
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-8 items-start">
                        <div class="space-y-4">
                            <span class="text-[11px] font-bold text-[#378b76] uppercase tracking-wider block border-b border-slate-100 pb-2">1. Thông tin tài khoản</span>
                            <div>
                                <label class="text-[11px] font-bold text-slate-700 mb-1.5 block">Tên đăng nhập</label>
                                <div class="relative">
                                    <input type="text" name="username" required placeholder="Tên đăng nhập" class="w-full h-10 pl-10 pr-4 border-1.5 border-slate-300 rounded-lg text-[12.5px] font-medium text-slate-900 focus:border-[#378b76] focus:ring-4 focus:ring-[#378b76]/10 transition-all outline-none" style="border-width: 1.5px;">
                                    <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none text-[18px]">account_circle</span>
                                </div>
                            </div>
                            <div>
                                <label class="text-[11px] font-bold text-slate-700 mb-1.5 block">Email</label>
                                <div class="relative">
                                    <input type="email" name="email" required placeholder="Địa chỉ email" class="w-full h-10 pl-10 pr-4 border-1.5 border-slate-300 rounded-lg text-[12.5px] font-medium text-slate-900 focus:border-[#378b76] focus:ring-4 focus:ring-[#378b76]/10 transition-all outline-none" style="border-width: 1.5px;">
                                    <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none text-[18px]">mail</span>
                                </div>
                            </div>
                            <div>
                                <label class="text-[11px] font-bold text-slate-700 mb-1.5 block">Mật khẩu</label>
                                <div class="relative">
                                    <input type="password" name="password" id="modal-reg-pass" required placeholder="Tạo mật khẩu" oninput="updateModalPwStrength(this)" class="w-full h-10 pl-10 pr-10 border-1.5 border-slate-300 rounded-lg text-[12.5px] font-medium text-slate-900 focus:border-[#378b76] focus:ring-4 focus:ring-[#378b76]/10 transition-all outline-none" style="border-width: 1.5px;">
                                    <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none text-[18px]">key</span>
                                    <button type="button" onclick="togglePassField('modal-reg-pass', this)" class="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-[#378b76] transition-all">
                                        <span class="material-symbols-outlined text-[18px]">visibility</span>
                                    </button>
                                </div>
                            </div>
                            <div>
                                <label class="text-[11px] font-bold text-slate-700 mb-1.5 block">Xác nhận mật khẩu</label>
                                <div class="relative">
                                    <input type="password" name="confirm_password" id="modal-reg-confirm" required placeholder="Nhập lại mật khẩu" class="w-full h-10 pl-10 pr-10 border-1.5 border-slate-300 rounded-lg text-[12.5px] font-medium text-slate-900 focus:border-[#378b76] focus:ring-4 focus:ring-[#378b76]/10 transition-all outline-none" style="border-width: 1.5px;">
                                    <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none text-[18px]">key</span>
                                    <button type="button" onclick="togglePassField('modal-reg-confirm', this)" class="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-[#378b76] transition-all">
                                        <span class="material-symbols-outlined text-[18px]">visibility</span>
                                    </button>
                                </div>
                            </div>
                            <div class="mt-2 w-full">
                                <div class="flex gap-1 w-1/2 mb-1.5">
                                    <div class="h-1 flex-1 rounded-full bg-slate-200 transition-colors duration-300" id="modalRegStr1"></div>
                                    <div class="h-1 flex-1 rounded-full bg-slate-200 transition-colors duration-300" id="modalRegStr2"></div>
                                    <div class="h-1 flex-1 rounded-full bg-slate-200 transition-colors duration-300" id="modalRegStr3"></div>
                                    <div class="h-1 flex-1 rounded-full bg-slate-200 transition-colors duration-300" id="modalRegStr4"></div>
                                </div>
                                <p class="text-[9.5px] text-slate-400 leading-tight">Mật khẩu tối thiểu 8 ký tự, bao gồm chữ hoa, chữ thường, số và ký tự đặc biệt.</p>
                            </div>
                        </div>

                        <div class="space-y-6">
                            <div class="space-y-4">
                                <span class="text-[11px] font-bold text-[#378b76] uppercase tracking-wider block border-b border-slate-100 pb-2">2. Thông tin cá nhân</span>
                                <div class="grid grid-cols-2 gap-4">
                                    <div>
                                        <label class="text-[11px] font-bold text-slate-700 mb-1.5 block">Họ và Tên</label>
                                        <div class="relative">
                                            <input type="text" name="fullname" required placeholder="Nhập họ và tên" class="w-full h-10 pl-10 pr-4 border-1.5 border-slate-300 rounded-lg text-[12.5px] font-medium text-slate-900 focus:border-[#378b76] focus:ring-4 focus:ring-[#378b76]/10 transition-all outline-none" style="border-width: 1.5px;">
                                            <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none text-[18px]">person</span>
                                        </div>
                                    </div>
                                    <div>
                                        <label class="text-[11px] font-bold text-slate-700 mb-1.5 block">Số điện thoại</label>
                                        <div class="relative">
                                            <input type="tel" name="phone" required placeholder="Nhập số điện thoại" class="w-full h-10 pl-10 pr-4 border-1.5 border-slate-300 rounded-lg text-[12.5px] font-medium text-slate-900 focus:border-[#378b76] focus:ring-4 focus:ring-[#378b76]/10 transition-all outline-none" style="border-width: 1.5px;">
                                            <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none text-[18px]">call</span>
                                        </div>
                                    </div>
                                </div>
                                <div>
                                    <label class="text-[11px] font-bold text-slate-700 mb-1.5 block">Giới tính</label>
                                    <div class="relative">
                                        <select name="gender" required class="w-full h-10 pl-10 pr-10 border-1.5 border-slate-300 rounded-lg text-[12.5px] font-medium text-slate-900 focus:border-[#378b76] focus:ring-4 focus:ring-[#378b76]/10 transition-all outline-none appearance-none" style="border-width: 1.5px;">
                                            <option value="Nam">Nam</option>
                                            <option value="Nữ">Nữ</option>
                                            <option value="Khác">Khác</option>
                                        </select>
                                        <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none text-[18px]">face</span>
                                        <span class="material-symbols-outlined absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none">arrow_drop_down</span>
                                    </div>
                                </div>
                            </div>
                            <div class="space-y-4">
                                <span class="text-[11px] font-bold text-[#378b76] uppercase tracking-wider block border-b border-slate-100 pb-2">3. Thể thao & kỹ năng</span>
                                <div>
                                    <label class="text-[11px] font-bold text-slate-700 mb-1.5 block">Vị trí sở trường</label>
                                    <div class="relative">
                                        <input type="text" name="viTriSoTruong" placeholder="Ví dụ: Tiền đạo, Hậu vệ, Đập cầu..." class="w-full h-10 pl-10 pr-4 border-1.5 border-slate-300 rounded-lg text-[12.5px] font-medium text-slate-900 focus:border-[#378b76] focus:ring-4 focus:ring-[#378b76]/10 transition-all outline-none" style="border-width: 1.5px;">
                                        <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none text-[18px]">sports_handball</span>
                                    </div>
                                </div>
                                <div>
                                    <label class="text-[11px] font-bold text-slate-400 block mb-2">Môn thể thao yêu thích</label>
                                    <div class="grid grid-cols-2 gap-2.5">
                                        <label class="flex items-center gap-2.5 bg-white border border-slate-200 px-3 py-2 rounded-xl cursor-pointer hover:border-[#378b76]/40 transition-colors font-semibold text-[11.5px] text-slate-700 select-none shadow-sm">
                                            <input type="checkbox" name="sport" value="Bóng đá" class="w-4 h-4 accent-[#378b76] rounded"> Bóng đá
                                        </label>
                                        <label class="flex items-center gap-2.5 bg-white border border-slate-200 px-3 py-2 rounded-xl cursor-pointer hover:border-[#378b76]/40 transition-colors font-semibold text-[11.5px] text-slate-700 select-none shadow-sm">
                                            <input type="checkbox" name="sport" value="Cầu lông" class="w-4 h-4 accent-[#378b76] rounded"> Cầu lông
                                        </label>
                                        <label class="flex items-center gap-2.5 bg-white border border-slate-200 px-3 py-2 rounded-xl cursor-pointer hover:border-[#378b76]/40 transition-colors font-semibold text-[11.5px] text-slate-700 select-none shadow-sm">
                                            <input type="checkbox" name="sport" value="Pickleball" class="w-4 h-4 accent-[#378b76] rounded"> Pickleball
                                        </label>
                                        <label class="flex items-center gap-2.5 bg-white border border-slate-200 px-3 py-2 rounded-xl cursor-pointer hover:border-[#378b76]/40 transition-colors font-semibold text-[11.5px] text-slate-700 select-none shadow-sm">
                                            <input type="checkbox" name="sport" value="Tennis" class="w-4 h-4 accent-[#378b76] rounded"> Tennis
                                        </label>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="mt-8 pt-4 border-t border-slate-100 flex flex-col gap-4">
                        <div class="flex items-start gap-2.5 select-none">
                            <input type="checkbox" name="agree" value="Đồng ý" required class="w-4 h-4 mt-0.5 accent-[#378b76] rounded border-slate-300 cursor-pointer">
                            <span class="text-[11.5px] text-slate-500 font-semibold leading-tight">
                                Tôi đồng ý với các <a href="#" class="text-[#378b76] font-bold hover:underline">điều khoản</a> và <a href="#" class="text-[#378b76] font-bold hover:underline">chính sách</a> của hệ thống.
                            </span>
                        </div>
                        <button type="submit" id="modal-register-btn" class="w-full h-11 bg-[#378b76] hover:bg-[#2c6f5e] text-white rounded-xl font-bold text-[13.5px] flex items-center justify-center gap-2 transition-all relative overflow-hidden">
                            <span class="btn-text flex items-center gap-1.5">
                                Kích hoạt Athlete Pass
                                <span class="material-symbols-outlined text-[18px]">how_to_reg</span>
                            </span>
                            <div class="loading-spinner hidden absolute inset-0 bg-[#2c6f5e] flex items-center justify-center">
                                <div class="w-5 h-5 border-2 border-white/20 border-t-white rounded-full animate-spin"></div>
                            </div>
                        </button>
                    </div>
                </form>

                <div class="mt-5 text-center border-t border-slate-100 pt-4">
                    <p class="text-[12px] text-slate-500 font-medium">
                        Đã có tài khoản?
                        <button onclick="switchAuthTab('login')" class="font-bold text-[#378b76] hover:underline ml-1">Đăng nhập ngay</button>
                    </p>
                </div>
            </div>

            <!-- FORGOT PASSWORD PANEL -->
            <div id="modal-forgot-password-panel" class="modal-panel hidden flex flex-col">
                <div class="mb-6">
                    <div class="inline-flex items-center gap-2 bg-white border border-[#378b76]/30 text-[#378b76] rounded-full py-1 px-3.5 text-[11px] font-bold w-fit shadow-sm mb-3">
                        <div class="w-1.5 h-1.5 rounded-full bg-[#378b76] animate-pulse"></div>
                        <span>Hệ thống V-Sport</span>
                    </div>
                    <h2 class="text-xl font-bold tracking-tight text-slate-900 mb-1">Quên mật khẩu?</h2>
                    <p class="text-[13px] text-slate-400 font-medium leading-relaxed">Đừng lo lắng, hãy nhập địa chỉ email đã đăng ký của bạn để bắt đầu khôi phục mật khẩu.</p>
                </div>
                <div id="forgot-password-error-banner" class="hidden mb-5 p-4 bg-red-50 text-red-600 border border-red-100 rounded-xl text-xs font-semibold flex items-center gap-3 shadow-sm">
                    <span class="material-symbols-outlined text-[18px] shrink-0">error</span>
                    <span class="error-msg"></span>
                </div>
                <form id="modal-forgot-password-form" action="${pageContext.request.contextPath}/quenmatkhau" method="POST" class="flex flex-col" autocomplete="off" onsubmit="submitForgotPasswordForm(event)">
                    <div class="mb-5">
                        <label class="text-[12px] font-bold text-slate-700 mb-1.5 block">Email đã đăng ký</label>
                        <div class="relative">
                            <input type="email" name="email" required placeholder="Nhập địa chỉ email" class="w-full h-12 pl-12 pr-4 border border-slate-300 rounded-xl text-[13px] font-medium text-slate-900 focus:border-[#378b76] focus:ring-4 focus:ring-[#378b76]/10 transition-all outline-none" style="border-width: 1.5px;">
                            <span class="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none text-[20px]">mail</span>
                        </div>
                    </div>
                    <button type="submit" id="modal-forgot-password-btn" class="w-full h-12 bg-[#378b76] hover:bg-[#2c6f5e] text-white rounded-xl font-bold text-[14px] flex items-center justify-center gap-2 transition-all relative overflow-hidden shadow-md shadow-emerald-50">
                        <span class="btn-text flex items-center gap-1.5">
                            Gửi mã xác thực
                            <span class="material-symbols-outlined text-[18px]">arrow_forward</span>
                        </span>
                        <div class="loading-spinner hidden absolute inset-0 bg-[#2c6f5e] flex items-center justify-center">
                            <div class="w-5 h-5 border-2 border-white/20 border-t-white rounded-full animate-spin"></div>
                        </div>
                    </button>
                </form>
                <div class="mt-6 text-center border-t border-slate-100 pt-4">
                    <p class="text-[12px] text-slate-500 font-medium">
                        Bạn đã nhớ lại mật khẩu?
                        <button onclick="switchAuthTab('login')" class="font-bold text-[#378b76] hover:underline ml-1 cursor-pointer">Đăng nhập ngay</button>
                    </p>
                </div>
            </div>

            <!-- OTP PANEL -->
            <div id="modal-otp-panel" class="modal-panel hidden flex flex-col">
                <div class="mb-6">
                    <div class="inline-flex items-center gap-2 bg-white border border-[#378b76]/30 text-[#378b76] rounded-full py-1 px-3.5 text-[11px] font-bold w-fit shadow-sm mb-3">
                        <div class="w-1.5 h-1.5 rounded-full bg-[#378b76] animate-pulse"></div>
                        <span>Xác minh danh tính</span>
                    </div>
                    <h2 class="text-xl font-bold tracking-tight text-slate-900 mb-1">Xác thực OTP</h2>
                    <p class="text-[13px] text-slate-400 font-medium leading-relaxed">
                        Vui lòng kiểm tra email và nhập mã xác thực OTP 6 chữ số gửi tới <b id="otp-email-display" class="text-slate-800"></b>.
                    </p>
                </div>
                <div id="otp-error-banner" class="hidden mb-5 p-4 bg-red-50 text-red-650 border border-red-100 rounded-xl text-xs font-semibold flex items-center gap-3 shadow-sm">
                    <span class="material-symbols-outlined text-[18px] shrink-0">error</span>
                    <span class="error-msg"></span>
                </div>
                <div id="otp-success-banner" class="hidden mb-5 p-4 bg-emerald-50 text-emerald-600 border border-emerald-100 rounded-xl text-xs font-semibold flex items-center gap-3 shadow-sm">
                    <span class="material-symbols-outlined text-[18px] shrink-0">check_circle</span>
                    <span class="success-msg"></span>
                </div>
                <form id="modal-otp-form" action="${pageContext.request.contextPath}/nhapma" method="POST" class="flex flex-col" autocomplete="off" onsubmit="submitOtpForm(event)">
                    <input type="hidden" name="email" id="otp-hidden-email">
                    <div class="mb-5">
                        <label class="text-[12px] font-bold text-slate-700 mb-1.5 block">Nhập mã OTP 6 chữ số</label>
                        <div class="relative">
                            <input type="text" name="otp" required maxlength="6" placeholder="••••••" class="w-full h-14 border border-slate-300 rounded-xl text-center text-2xl font-bold tracking-[0.35em] focus:border-[#378b76] focus:ring-4 focus:ring-[#378b76]/10 transition-all outline-none" style="border-width: 1.5px;">
                        </div>
                    </div>
                    <button type="submit" id="modal-otp-btn" class="w-full h-12 bg-[#378b76] hover:bg-[#2c6f5e] text-white rounded-xl font-bold text-[14px] flex items-center justify-center gap-2 transition-all relative overflow-hidden shadow-md shadow-emerald-50">
                        <span class="btn-text flex items-center gap-1.5">
                            Xác minh OTP
                            <span class="material-symbols-outlined text-[18px]">verified_user</span>
                        </span>
                        <div class="loading-spinner hidden absolute inset-0 bg-[#2c6f5e] flex items-center justify-center">
                            <div class="w-5 h-5 border-2 border-white/20 border-t-white rounded-full animate-spin"></div>
                        </div>
                    </button>
                </form>
                <div class="mt-6 text-center border-t border-slate-100 pt-4 flex flex-col gap-2">
                    <p class="text-[12px] text-slate-500 font-medium">
                        Không nhận được mã?
                        <button onclick="resendOtp()" class="font-bold text-[#378b76] hover:underline ml-1 cursor-pointer">Gửi lại ngay</button>
                    </p>
                    <p class="text-[12px]">
                        <button onclick="goBackFromOtp()" class="font-bold text-slate-400 hover:text-slate-600 hover:underline cursor-pointer flex items-center justify-center gap-1 mx-auto">
                            <span class="material-symbols-outlined text-[16px]">arrow_back</span> Quay lại
                        </button>
                    </p>
                </div>
            </div>

            <!-- RESET PASSWORD PANEL -->
            <div id="modal-reset-password-panel" class="modal-panel hidden flex flex-col">
                <div class="mb-6">
                    <div class="inline-flex items-center gap-2 bg-white border border-[#378b76]/30 text-[#378b76] rounded-full py-1 px-3.5 text-[11px] font-bold w-fit shadow-sm mb-3">
                        <div class="w-1.5 h-1.5 rounded-full bg-[#378b76] animate-pulse"></div>
                        <span>Thiết lập mật khẩu</span>
                    </div>
                    <h2 class="text-xl font-bold tracking-tight text-slate-900 mb-1">Mật khẩu mới</h2>
                    <p class="text-[13px] text-slate-400 font-medium leading-relaxed">Đã xác minh danh tính thành công. Vui lòng tạo mật khẩu mới an toàn cho tài khoản của bạn.</p>
                </div>
                <div id="reset-password-error-banner" class="hidden mb-5 p-4 bg-red-50 text-red-650 border border-red-100 rounded-xl text-xs font-semibold flex items-center gap-3 shadow-sm">
                    <span class="material-symbols-outlined text-[18px] shrink-0">error</span>
                    <span class="error-msg"></span>
                </div>
                <form id="modal-reset-password-form" action="${pageContext.request.contextPath}/nhapmatkhaumoi" method="POST" class="flex flex-col gap-4" onsubmit="submitResetPasswordForm(event)">
                    <div>
                        <label class="text-[12px] font-bold text-slate-700 mb-1.5 block">Mật khẩu mới</label>
                        <div class="relative">
                            <input type="password" name="password" id="modal-new-pass" required placeholder="••••••••" oninput="updateModalResetPwStrength(this)" class="w-full h-12 pl-12 pr-12 border border-slate-300 rounded-xl text-[13px] font-medium text-slate-900 focus:border-[#378b76] focus:ring-4 focus:ring-[#378b76]/10 transition-all outline-none" style="border-width: 1.5px;">
                            <span class="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none text-[20px]">key</span>
                            <button type="button" onclick="togglePassField('modal-new-pass', this)" class="absolute right-4 top-1/2 -translate-y-1/2 text-slate-400 hover:text-[#378b76]">
                                <span class="material-symbols-outlined text-[20px]">visibility</span>
                            </button>
                        </div>
                        <div class="mt-2 w-full">
                            <div class="flex gap-1 w-1/2 mb-1.5">
                                <div class="h-1 flex-1 rounded-full bg-slate-200 transition-colors duration-300" id="modalResetStr1"></div>
                                <div class="h-1 flex-1 rounded-full bg-slate-200 transition-colors duration-300" id="modalResetStr2"></div>
                                <div class="h-1 flex-1 rounded-full bg-slate-200 transition-colors duration-300" id="modalResetStr3"></div>
                                <div class="h-1 flex-1 rounded-full bg-slate-200 transition-colors duration-300" id="modalResetStr4"></div>
                            </div>
                            <p class="text-[9.5px] text-slate-400 leading-tight">Mật khẩu tối thiểu 8 ký tự, bao gồm chữ hoa, chữ thường, số và ký tự đặc biệt.</p>
                        </div>
                    </div>
                    <div class="mb-4">
                        <label class="text-[12px] font-bold text-slate-700 mb-1.5 block">Xác nhận mật khẩu mới</label>
                        <div class="relative">
                            <input type="password" name="confirm_password" id="modal-new-confirm" required placeholder="••••••••" class="w-full h-12 pl-12 pr-12 border border-slate-300 rounded-xl text-[13px] font-medium text-slate-900 focus:border-[#378b76] focus:ring-4 focus:ring-[#378b76]/10 transition-all outline-none" style="border-width: 1.5px;">
                            <span class="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none text-[20px]">key</span>
                            <button type="button" onclick="togglePassField('modal-new-confirm', this)" class="absolute right-4 top-1/2 -translate-y-1/2 text-slate-400 hover:text-[#378b76]">
                                <span class="material-symbols-outlined text-[20px]">visibility</span>
                            </button>
                        </div>
                    </div>
                    <button type="submit" id="modal-reset-password-btn" class="w-full h-12 bg-[#378b76] hover:bg-[#2c6f5e] text-white rounded-xl font-bold text-[14px] flex items-center justify-center gap-2 transition-all relative overflow-hidden shadow-md shadow-emerald-50">
                        <span class="btn-text flex items-center gap-1.5">
                            Lưu mật khẩu mới
                            <span class="material-symbols-outlined text-[18px]">save</span>
                        </span>
                        <div class="loading-spinner hidden absolute inset-0 bg-[#2c6f5e] flex items-center justify-center">
                            <div class="w-5 h-5 border-2 border-white/20 border-t-white rounded-full animate-spin"></div>
                        </div>
                    </button>
                </form>
            </div>

        </div>
    </div>
</div>

<script>
    let otpSourceTab = 'login';

    function openAuthModal(tab = 'login') {
        const modal = document.getElementById('auth-modal');
        const card = document.getElementById('auth-modal-card');
        if (!modal || !card) return;
        clearModalAlerts();
        card.classList.remove('max-w-[460px]', 'max-w-[880px]');
        card.classList.add(tab === 'register' ? 'max-w-[880px]' : 'max-w-[460px]');
        modal.classList.remove('hidden');
        modal.classList.add('flex');
        setTimeout(() => { card.classList.remove('scale-95', 'opacity-0'); card.classList.add('scale-100', 'opacity-100'); }, 10);
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
        document.body.style.overflow = 'hidden';
    }

    function closeAuthModal() {
        setLoginFormLoading(false);
        const modal = document.getElementById('auth-modal');
        const card = document.getElementById('auth-modal-card');
        if (!modal || !card) return;
        card.classList.remove('scale-100','opacity-100');
        card.classList.add('scale-95','opacity-0');
        setTimeout(() => { modal.classList.add('hidden'); modal.classList.remove('flex'); document.body.style.overflow=''; }, 300);
    }

    function handleBackdropClick(event) {
        const card = document.getElementById('auth-modal-card');
        if (card && !card.contains(event.target)) closeAuthModal();
    }

    function switchAuthTab(tab) {
        const card = document.getElementById('auth-modal-card');
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
        if (!currentPanel || !card) return;
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

        card.classList.remove('max-w-[460px]', 'max-w-[880px]');
        card.classList.add(tab === 'register' ? 'max-w-[880px]' : 'max-w-[460px]');

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
            targetPanel.style.transition = 'opacity 300ms ease-out, transform 300ms ease-out';
            requestAnimationFrame(() => {
                setTimeout(() => { targetPanel.style.opacity='1'; targetPanel.style.transform='translateY(0)'; }, 20);
            });
        }, 150);
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

        setLoginFormLoading(true, 'Đang xác thực tài khoản...');

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
