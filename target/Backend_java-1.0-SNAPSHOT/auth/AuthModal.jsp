<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!-- CSS overrides for modal transitions and scrollbars -->
<style>
    .auth-modal-scroll::-webkit-scrollbar {
        width: 6px;
    }
    .auth-modal-scroll::-webkit-scrollbar-track {
        background: transparent;
    }
    .auth-modal-scroll::-webkit-scrollbar-thumb {
        background-color: #cbd5e1;
        border-radius: 20px;
    }
    
    /* Smooth width & transform transitions for the modal card */
    #auth-modal-card {
        transition: max-width 400ms cubic-bezier(0.34, 1.56, 0.64, 1), 
                    transform 300ms cubic-bezier(0.34, 1.56, 0.64, 1), 
                    opacity 300ms ease-out;
    }
    
    /* Transition styles for form panels */
    .modal-panel {
        transition: opacity 200ms ease-out, transform 200ms ease-out;
    }
    
    /* Reset default browser button styling due to disabled Tailwind preflight */
    :where(#auth-modal button) {
        background-color: transparent;
        background-image: none;
        border: none;
        padding: 0;
        margin: 0;
        outline: none;
        box-shadow: none;
    }
</style>

<!-- Main Modal Backdrop Wrapper -->
<div id="auth-modal" class="fixed inset-0 z-[120] hidden items-center justify-center p-4 bg-slate-900/60 backdrop-blur-sm transition-opacity duration-300" onclick="handleBackdropClick(event)">
    
    <!-- Modal Container (Dynamically resizes between 460px and 880px) -->
    <div id="auth-modal-card" class="bg-white rounded-3xl w-full max-w-[460px] max-h-[95vh] flex flex-col shadow-2xl relative border border-slate-100 transform scale-95 opacity-0">
        
        <!-- Close Button -->
        <button onclick="closeAuthModal()" class="absolute top-5 right-5 text-slate-400 hover:text-slate-600 transition-colors z-[130] w-8 h-8 rounded-full flex items-center justify-center bg-slate-50 hover:bg-slate-100">
            <span class="material-symbols-outlined text-[20px]">close</span>
        </button>

        <!-- Toggle Tabs -->
        <div id="modal-tabs-header" class="px-8 pt-8 pb-4 border-b border-slate-100 flex items-center justify-start gap-4">
            <button id="modal-tab-login" onclick="switchAuthTab('login')" class="text-xl font-bold tracking-tight text-slate-900 border-b-2 border-[#378b76] pb-2 transition-all">
                Đăng nhập
            </button>
            <button id="modal-tab-register" onclick="switchAuthTab('register')" class="text-xl font-bold tracking-tight text-slate-400 hover:text-slate-900 border-b-2 border-transparent pb-2 transition-all">
                Đăng ký
            </button>
        </div>

        <!-- Content Area -->
        <div class="flex-grow overflow-y-auto p-8 auth-modal-scroll">

            <!-- ========================================== -->
            <!-- 1. LOGIN FORM PANEL                        -->
            <!-- ========================================== -->
            <div id="modal-login-panel" class="modal-panel flex flex-col">
                <!-- Heading & Subtitle -->
                <div class="mb-6">
                    <div class="inline-flex items-center gap-2 bg-white border border-[#378b76]/30 text-[#378b76] rounded-full py-1 px-3.5 text-[11px] font-bold w-fit shadow-sm mb-3">
                        <div class="w-1.5 h-1.5 rounded-full bg-[#378b76] animate-pulse"></div>
                        <span>Hệ thống V-Sport</span>
                    </div>
                    <p class="text-[13px] text-slate-400 font-medium">Chào mừng trở lại! Nhập thông tin tài khoản của bạn để tiếp tục.</p>
                </div>

                <!-- Error Banner -->
                <div id="login-error-banner" class="hidden mb-6 p-4 bg-red-50 text-red-600 rounded-xl text-xs font-semibold border border-red-100 flex items-center gap-3 shadow-sm">
                    <span class="material-symbols-outlined text-[18px]">error</span>
                    <span class="error-msg"></span>
                </div>

                <!-- Success Banner -->
                <div id="login-success-banner" class="hidden mb-6 p-4 bg-green-50 text-green-600 rounded-xl text-xs font-semibold border border-green-100 flex items-center gap-3 shadow-sm">
                    <span class="material-symbols-outlined text-[18px]">check_circle</span>
                    <span class="success-msg"></span>
                </div>

                <!-- Form -->
                <form id="modal-login-form" action="${pageContext.request.contextPath}/dangnhap" method="POST" class="flex flex-col" autocomplete="off" onsubmit="submitLoginForm(event)">
                    <input type="hidden" name="loginType" value="customer">
                    <!-- Username Input -->
                    <div class="mb-4 relative">
                        <label class="text-[12px] font-bold text-slate-700 mb-1.5 block">Tên đăng nhập hoặc Email</label>
                        <div class="relative">
                            <input type="text" name="username" required placeholder="Nhập tên đăng nhập hoặc email" class="w-full h-12 pl-12 pr-12 border-1.5 border-slate-300 rounded-xl text-[13px] font-medium text-slate-900 focus:border-[#378b76] focus:ring-4 focus:ring-[#378b76]/10 transition-all outline-none" style="border-width: 1.5px;">
                            <span class="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none text-[20px]">account_circle</span>
                        </div>
                    </div>

                    <!-- Password Input -->
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

                    <!-- Remember Me and Forgot Password -->
                    <div class="flex items-center justify-between mb-6">
                        <label class="flex items-center gap-2 cursor-pointer select-none text-[12px] text-slate-500 font-semibold">
                            <input type="checkbox" name="rememberMe" class="w-4 h-4 accent-[#378b76] rounded border-slate-300">
                            <span>Ghi nhớ đăng nhập (7 ngày)</span>
                        </label>
                        
                        <button type="button" onclick="switchAuthTab('forgot-password')" class="text-[12px] font-bold text-[#378b76] hover:underline cursor-pointer">
                            Quên mật khẩu?
                        </button>
                    </div>

                    <!-- Submit Button -->
                    <button type="submit" id="modal-login-btn" class="w-full h-12 bg-[#378b76] hover:bg-[#2c6f5e] text-white rounded-xl font-bold text-[14px] flex items-center justify-center gap-2 transition-all relative overflow-hidden">
                        <span class="btn-text flex items-center gap-1.5">
                            Đăng nhập
                            <span class="material-symbols-outlined text-[18px]">arrow_forward</span>
                        </span>
                        <!-- Loading Spinner -->
                        <div class="loading-spinner hidden absolute inset-0 bg-[#2c6f5e] flex items-center justify-center">
                            <div class="w-5 h-5 border-2 border-white/20 border-t-white rounded-full animate-spin"></div>
                        </div>
                    </button>

                </form>

                <div class="mt-5 text-center border-t border-slate-100 pt-4">
                    <p class="text-[12px] text-slate-500 font-medium">
                        Bạn chưa có tài khoản? 
                        <button onclick="switchAuthTab('register')" class="font-bold text-[#378b76] hover:underline ml-1">
                            Đăng ký ngay
                        </button>
                    </p>
                </div>
            </div>

            <!-- ========================================== -->
            <!-- 2. REGISTER FORM PANEL                     -->
            <!-- ========================================== -->
            <div id="modal-register-panel" class="modal-panel hidden flex flex-col">
                <!-- Heading & Subtitle -->
                <div class="mb-5">
                    <div class="inline-flex items-center gap-2 bg-white border border-[#378b76]/30 text-[#378b76] rounded-full py-1 px-3.5 text-[11px] font-bold w-fit shadow-sm mb-3">
                        <div class="w-1.5 h-1.5 rounded-full bg-[#378b76] animate-pulse"></div>
                        <span>Hệ thống V-Sport</span>
                    </div>
                    <p class="text-[13px] text-slate-400 font-medium">Bắt đầu hành trình chinh phục sân đấu và kết nối bạn bè ngay hôm nay.</p>
                </div>

                <!-- Error Banner -->
                <div id="register-error-banner" class="hidden mb-5 p-4 bg-red-50 text-red-600 rounded-xl text-xs font-semibold border border-red-100 flex items-center gap-3 shadow-sm">
                    <span class="material-symbols-outlined text-[18px]">error</span>
                    <span class="error-msg"></span>
                </div>

                <!-- Form with Horizontal Layout (Two Columns) -->
                <form id="modal-register-form" action="${pageContext.request.contextPath}/dangky" method="POST" class="flex flex-col" autocomplete="off" onsubmit="submitRegisterForm(event)">
                    
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-8 items-start">
                        
                        <!-- LEFT COLUMN: 1. THÔNG TIN TÀI KHOẢN -->
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

                            <!-- Password strength indicator -->
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

                        <!-- RIGHT COLUMN: 2. THÔNG TIN CÁ NHÂN & 3. THỂ THAO -->
                        <div class="space-y-6">
                            
                            <!-- 2. THÔNG TIN CÁ NHÂN -->
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

                            <!-- 3. THỂ THAO & KỸ NĂNG -->
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
                                            <input type="checkbox" name="sport" value="Bóng đá" class="w-4 h-4 accent-[#378b76] rounded">
                                            Bóng đá
                                        </label>
                                        <label class="flex items-center gap-2.5 bg-white border border-slate-200 px-3 py-2 rounded-xl cursor-pointer hover:border-[#378b76]/40 transition-colors font-semibold text-[11.5px] text-slate-700 select-none shadow-sm">
                                            <input type="checkbox" name="sport" value="Cầu lông" class="w-4 h-4 accent-[#378b76] rounded">
                                            Cầu lông
                                        </label>
                                        <label class="flex items-center gap-2.5 bg-white border border-slate-200 px-3 py-2 rounded-xl cursor-pointer hover:border-[#378b76]/40 transition-colors font-semibold text-[11.5px] text-slate-700 select-none shadow-sm">
                                            <input type="checkbox" name="sport" value="Pickleball" class="w-4 h-4 accent-[#378b76] rounded">
                                            Pickleball
                                        </label>
                                        <label class="flex items-center gap-2.5 bg-white border border-slate-200 px-3 py-2 rounded-xl cursor-pointer hover:border-[#378b76]/40 transition-colors font-semibold text-[11.5px] text-slate-700 select-none shadow-sm">
                                            <input type="checkbox" name="sport" value="Tennis" class="w-4 h-4 accent-[#378b76] rounded">
                                            Tennis
                                        </label>
                                    </div>
                                </div>
                            </div>

                        </div>

                    </div>

                    <!-- FOOTER: AGREEMENT & SUBMIT BUTTON -->
                    <div class="mt-8 pt-4 border-t border-slate-100 flex flex-col gap-4">
                        <!-- Agreement checkbox -->
                        <div class="flex items-start gap-2.5 select-none">
                            <input type="checkbox" name="agree" value="Đồng ý" required class="w-4 h-4 mt-0.5 accent-[#378b76] rounded border-slate-300 cursor-pointer">
                            <span class="text-[11.5px] text-slate-500 font-semibold leading-tight font-medium">
                                Tôi đồng ý với các <a href="#" class="text-[#378b76] font-bold hover:underline">điều khoản</a> và <a href="#" class="text-[#378b76] font-bold hover:underline">chính sách</a> của hệ thống.
                            </span>
                        </div>

                        <!-- Submit Button -->
                        <button type="submit" id="modal-register-btn" class="w-full h-11 bg-[#378b76] hover:bg-[#2c6f5e] text-white rounded-xl font-bold text-[13.5px] flex items-center justify-center gap-2 transition-all relative overflow-hidden">
                            <span class="btn-text flex items-center gap-1.5">
                                Kích hoạt Athlete Pass
                                <span class="material-symbols-outlined text-[18px]">how_to_reg</span>
                            </span>
                            <!-- Loading Spinner -->
                            <div class="loading-spinner hidden absolute inset-0 bg-[#2c6f5e] flex items-center justify-center">
                                <div class="w-5 h-5 border-2 border-white/20 border-t-white rounded-full animate-spin"></div>
                            </div>
                        </button>
                    </div>
                </form>

                <!-- Bottom Navigation Link -->
                <div class="mt-5 text-center border-t border-slate-100 pt-4">
                    <p class="text-[12px] text-slate-500 font-medium">
                        Đã có tài khoản? 
                        <button onclick="switchAuthTab('login')" class="font-bold text-[#378b76] hover:underline ml-1">
                            Đăng nhập ngay
                        </button>
                    </p>
                </div>
            </div>

            <!-- ========================================== -->
            <!-- 3. FORGOT PASSWORD PANEL                    -->
            <!-- ========================================== -->
            <div id="modal-forgot-password-panel" class="modal-panel hidden flex flex-col">
                <!-- Heading & Subtitle -->
                <div class="mb-6">
                    <div class="inline-flex items-center gap-2 bg-white border border-[#378b76]/30 text-[#378b76] rounded-full py-1 px-3.5 text-[11px] font-bold w-fit shadow-sm mb-3">
                        <div class="w-1.5 h-1.5 rounded-full bg-[#378b76] animate-pulse"></div>
                        <span>Hệ thống V-Sport</span>
                    </div>
                    <h2 class="text-xl font-bold tracking-tight text-slate-900 mb-1">Quên mật khẩu?</h2>
                    <p class="text-[13px] text-slate-400 font-medium leading-relaxed">Đừng lo lắng, hãy nhập địa chỉ email đã đăng ký của bạn để bắt đầu khôi phục mật khẩu.</p>
                </div>

                <!-- Error Banner -->
                <div id="forgot-password-error-banner" class="hidden mb-5 p-4 bg-red-50 text-red-600 border border-red-100 rounded-xl text-xs font-semibold flex items-center gap-3 shadow-sm">
                    <span class="material-symbols-outlined text-[18px] shrink-0">error</span>
                    <span class="error-msg"></span>
                </div>

                <!-- Form -->
                <form id="modal-forgot-password-form" action="${pageContext.request.contextPath}/quenmatkhau" method="POST" class="flex flex-col" autocomplete="off" onsubmit="submitForgotPasswordForm(event)">
                    <!-- Email Input -->
                    <div class="mb-5">
                        <label class="text-[12px] font-bold text-slate-700 mb-1.5 block">Email đã đăng ký</label>
                        <div class="relative">
                            <input type="email" name="email" required placeholder="Nhập địa chỉ email" 
                                   class="w-full h-12 pl-12 pr-4 border border-slate-300 rounded-xl text-[13px] font-medium text-slate-900 focus:border-[#378b76] focus:ring-4 focus:ring-[#378b76]/10 transition-all outline-none" 
                                   style="border-width: 1.5px;">
                            <span class="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none text-[20px]">mail</span>
                        </div>
                    </div>

                    <!-- Submit Button -->
                    <button type="submit" id="modal-forgot-password-btn" class="w-full h-12 bg-[#378b76] hover:bg-[#2c6f5e] text-white rounded-xl font-bold text-[14px] flex items-center justify-center gap-2 transition-all relative overflow-hidden shadow-md shadow-emerald-50">
                        <span class="btn-text flex items-center gap-1.5">
                            Gửi mã xác thực
                            <span class="material-symbols-outlined text-[18px]">arrow_forward</span>
                        </span>
                        <!-- Loading Spinner -->
                        <div class="loading-spinner hidden absolute inset-0 bg-[#2c6f5e] flex items-center justify-center">
                            <div class="w-5 h-5 border-2 border-white/20 border-t-white rounded-full animate-spin"></div>
                        </div>
                    </button>
                </form>

                <!-- Back to Login footer -->
                <div class="mt-6 text-center border-t border-slate-100 pt-4">
                    <p class="text-[12px] text-slate-500 font-medium">
                        Bạn đã nhớ lại mật khẩu? 
                        <button onclick="switchAuthTab('login')" class="font-bold text-[#378b76] hover:underline ml-1 cursor-pointer">
                            Đăng nhập ngay
                        </button>
                    </p>
                </div>
            </div>

            <!-- ========================================== -->
            <!-- 4. OTP VERIFICATION PANEL                   -->
            <!-- ========================================== -->
            <div id="modal-otp-panel" class="modal-panel hidden flex flex-col">
                <!-- Heading & Subtitle -->
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

                <!-- Error Banner -->
                <div id="otp-error-banner" class="hidden mb-5 p-4 bg-red-50 text-red-650 border border-red-100 rounded-xl text-xs font-semibold flex items-center gap-3 shadow-sm">
                    <span class="material-symbols-outlined text-[18px] shrink-0">error</span>
                    <span class="error-msg"></span>
                </div>

                <!-- Success Banner -->
                <div id="otp-success-banner" class="hidden mb-5 p-4 bg-emerald-50 text-emerald-600 border border-emerald-100 rounded-xl text-xs font-semibold flex items-center gap-3 shadow-sm">
                    <span class="material-symbols-outlined text-[18px] shrink-0">check_circle</span>
                    <span class="success-msg"></span>
                </div>

                <!-- Form -->
                <form id="modal-otp-form" action="${pageContext.request.contextPath}/nhapma" method="POST" class="flex flex-col" autocomplete="off" onsubmit="submitOtpForm(event)">
                    <input type="hidden" name="email" id="otp-hidden-email">

                    <!-- OTP Input -->
                    <div class="mb-5">
                        <label class="text-[12px] font-bold text-slate-700 mb-1.5 block">Nhập mã OTP 6 chữ số</label>
                        <div class="relative">
                            <input type="text" name="otp" required maxlength="6" placeholder="••••••" 
                                   class="w-full h-14 border border-slate-300 rounded-xl text-center text-2xl font-bold tracking-[0.35em] focus:border-[#378b76] focus:ring-4 focus:ring-[#378b76]/10 transition-all outline-none" 
                                   style="border-width: 1.5px;">
                        </div>
                    </div>

                    <!-- Submit Button -->
                    <button type="submit" id="modal-otp-btn" class="w-full h-12 bg-[#378b76] hover:bg-[#2c6f5e] text-white rounded-xl font-bold text-[14px] flex items-center justify-center gap-2 transition-all relative overflow-hidden shadow-md shadow-emerald-50">
                        <span class="btn-text flex items-center gap-1.5">
                            Xác minh OTP
                            <span class="material-symbols-outlined text-[18px]">verified_user</span>
                        </span>
                        <!-- Loading Spinner -->
                        <div class="loading-spinner hidden absolute inset-0 bg-[#2c6f5e] flex items-center justify-center">
                            <div class="w-5 h-5 border-2 border-white/20 border-t-white rounded-full animate-spin"></div>
                        </div>
                    </button>
                </form>

                <!-- Resend Footer -->
                <div class="mt-6 text-center border-t border-slate-100 pt-4 flex flex-col gap-2">
                    <p class="text-[12px] text-slate-500 font-medium">
                        Không nhận được mã? 
                        <button onclick="resendOtp()" class="font-bold text-[#378b76] hover:underline ml-1 cursor-pointer">
                            Gửi lại ngay
                        </button>
                    </p>
                    <p class="text-[12px]">
                        <button onclick="goBackFromOtp()" class="font-bold text-slate-400 hover:text-slate-600 hover:underline cursor-pointer flex items-center justify-center gap-1 mx-auto">
                            <span class="material-symbols-outlined text-[16px]">arrow_back</span> Quay lại
                        </button>
                    </p>
                </div>
            </div>

            <!-- ========================================== -->
            <!-- 5. RESET PASSWORD PANEL                     -->
            <!-- ========================================== -->
            <div id="modal-reset-password-panel" class="modal-panel hidden flex flex-col">
                <!-- Heading & Subtitle -->
                <div class="mb-6">
                    <div class="inline-flex items-center gap-2 bg-white border border-[#378b76]/30 text-[#378b76] rounded-full py-1 px-3.5 text-[11px] font-bold w-fit shadow-sm mb-3">
                        <div class="w-1.5 h-1.5 rounded-full bg-[#378b76] animate-pulse"></div>
                        <span>Thiết lập mật khẩu</span>
                    </div>
                    <h2 class="text-xl font-bold tracking-tight text-slate-900 mb-1">Mật khẩu mới</h2>
                    <p class="text-[13px] text-slate-400 font-medium leading-relaxed">
                        Đã xác minh danh tính thành công. Vui lòng tạo mật khẩu mới an toàn cho tài khoản của bạn.
                    </p>
                </div>

                <!-- Error Banner -->
                <div id="reset-password-error-banner" class="hidden mb-5 p-4 bg-red-50 text-red-650 border border-red-100 rounded-xl text-xs font-semibold flex items-center gap-3 shadow-sm">
                    <span class="material-symbols-outlined text-[18px] shrink-0">error</span>
                    <span class="error-msg"></span>
                </div>

                <!-- Form -->
                <form id="modal-reset-password-form" action="${pageContext.request.contextPath}/nhapmatkhaumoi" method="POST" class="flex flex-col gap-4" onsubmit="submitResetPasswordForm(event)">
                    <!-- New Password -->
                    <div>
                        <label class="text-[12px] font-bold text-slate-700 mb-1.5 block">Mật khẩu mới</label>
                        <div class="relative">
                            <input type="password" name="password" id="modal-new-pass" required placeholder="••••••••" oninput="updateModalResetPwStrength(this)"
                                   class="w-full h-12 pl-12 pr-12 border border-slate-300 rounded-xl text-[13px] font-medium text-slate-900 focus:border-[#378b76] focus:ring-4 focus:ring-[#378b76]/10 transition-all outline-none" 
                                   style="border-width: 1.5px;">
                            <span class="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none text-[20px]">key</span>
                            <button type="button" onclick="togglePassField('modal-new-pass', this)" class="absolute right-4 top-1/2 -translate-y-1/2 text-slate-400 hover:text-[#378b76]">
                                <span class="material-symbols-outlined text-[20px]">visibility</span>
                            </button>
                        </div>
                        <!-- Password strength indicator -->
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

                    <!-- Confirm Password -->
                    <div class="mb-4">
                        <label class="text-[12px] font-bold text-slate-700 mb-1.5 block">Xác nhận mật khẩu mới</label>
                        <div class="relative">
                            <input type="password" name="confirm_password" id="modal-new-confirm" required placeholder="••••••••" 
                                   class="w-full h-12 pl-12 pr-12 border border-slate-300 rounded-xl text-[13px] font-medium text-slate-900 focus:border-[#378b76] focus:ring-4 focus:ring-[#378b76]/10 transition-all outline-none" 
                                   style="border-width: 1.5px;">
                            <span class="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none text-[20px]">key</span>
                            <button type="button" onclick="togglePassField('modal-new-confirm', this)" class="absolute right-4 top-1/2 -translate-y-1/2 text-slate-400 hover:text-[#378b76]">
                                <span class="material-symbols-outlined text-[20px]">visibility</span>
                            </button>
                        </div>
                    </div>
                    
                    <!-- Submit Button -->
                    <button type="submit" id="modal-reset-password-btn" class="w-full h-12 bg-[#378b76] hover:bg-[#2c6f5e] text-white rounded-xl font-bold text-[14px] flex items-center justify-center gap-2 transition-all relative overflow-hidden shadow-md shadow-emerald-50">
                        <span class="btn-text flex items-center gap-1.5">
                            Lưu mật khẩu mới
                            <span class="material-symbols-outlined text-[18px]">save</span>
                        </span>
                        <!-- Loading Spinner -->
                        <div class="loading-spinner hidden absolute inset-0 bg-[#2c6f5e] flex items-center justify-center">
                            <div class="w-5 h-5 border-2 border-white/20 border-t-white rounded-full animate-spin"></div>
                        </div>
                    </button>
                </form>
            </div>

        </div>
    </div>
</div>

<!-- Scripts for Modal Behavior & AJAX -->
<script>
    let otpSourceTab = 'login'; // Keep track of where we came from for the back button

    // Open the auth modal, optionally pre-selecting a tab
    function openAuthModal(tab = 'login') {
        const modal = document.getElementById('auth-modal');
        const card = document.getElementById('auth-modal-card');
        
        if (modal && card) {
            // Clean up old messages/errors
            clearModalAlerts();

            // Set target card width instantly depending on active tab to prevent jumpy entrance
            if (tab === 'register') {
                card.classList.remove('max-w-[460px]');
                card.classList.add('max-w-[880px]');
            } else {
                card.classList.remove('max-w-[880px]');
                card.classList.add('max-w-[460px]');
            }

            // Show backdrop
            modal.classList.remove('hidden');
            modal.classList.add('flex');
            
            // Trigger transition
            setTimeout(() => {
                card.classList.remove('scale-95', 'opacity-0');
                card.classList.add('scale-100', 'opacity-100');
            }, 10);
            
            // Render the active tab content
            const tabHeader = document.getElementById('modal-tabs-header');
            const tabLogin = document.getElementById('modal-tab-login');
            const tabRegister = document.getElementById('modal-tab-register');
            const panelLogin = document.getElementById('modal-login-panel');
            const panelRegister = document.getElementById('modal-register-panel');
            const panelForgotPassword = document.getElementById('modal-forgot-password-panel');
            const panelOtp = document.getElementById('modal-otp-panel');
            const panelResetPassword = document.getElementById('modal-reset-password-panel');
            
            // Hide all panels
            panelLogin.classList.add('hidden');
            panelRegister.classList.add('hidden');
            if (panelForgotPassword) panelForgotPassword.classList.add('hidden');
            if (panelOtp) panelOtp.classList.add('hidden');
            if (panelResetPassword) panelResetPassword.classList.add('hidden');

            if (tab === 'login' || tab === 'register') {
                if (tabHeader) tabHeader.classList.remove('hidden');
                
                if (tab === 'login') {
                    tabLogin.classList.remove('text-slate-400', 'border-transparent');
                    tabLogin.classList.add('text-slate-900', 'border-[#378b76]');
                    tabRegister.classList.remove('text-slate-900', 'border-[#378b76]');
                    tabRegister.classList.add('text-slate-400', 'border-transparent');
                    
                    panelLogin.classList.remove('hidden');
                    panelLogin.style.opacity = '1';
                    panelLogin.style.transform = 'translateY(0)';
                } else {
                    tabRegister.classList.remove('text-slate-400', 'border-transparent');
                    tabRegister.classList.add('text-slate-900', 'border-[#378b76]');
                    tabLogin.classList.remove('text-slate-900', 'border-[#378b76]');
                    tabLogin.classList.add('text-slate-400', 'border-transparent');
                    
                    panelRegister.classList.remove('hidden');
                    panelRegister.style.opacity = '1';
                    panelRegister.style.transform = 'translateY(0)';
                }
            } else {
                if (tabHeader) tabHeader.classList.add('hidden');
                
                let targetPanel;
                if (tab === 'forgot-password') targetPanel = panelForgotPassword;
                else if (tab === 'otp') targetPanel = panelOtp;
                else if (tab === 'reset-password') targetPanel = panelResetPassword;

                if (targetPanel) {
                    targetPanel.classList.remove('hidden');
                    targetPanel.style.opacity = '1';
                    targetPanel.style.transform = 'translateY(0)';
                }
            }

            // Prevent background page scrolling
            document.body.style.overflow = 'hidden';
        }
    }

    // Close the auth modal
    function closeAuthModal() {
        const modal = document.getElementById('auth-modal');
        const card = document.getElementById('auth-modal-card');
        
        if (modal && card) {
            card.classList.remove('scale-100', 'opacity-100');
            card.classList.add('scale-95', 'opacity-0');
            
            setTimeout(() => {
                modal.classList.add('hidden');
                modal.classList.remove('flex');
                document.body.style.overflow = '';
            }, 300);
        }
    }

    // Handle click on backdrop to close
    function handleBackdropClick(event) {
        const card = document.getElementById('auth-modal-card');
        if (card && !card.contains(event.target)) {
            closeAuthModal();
        }
    }

    // Switch between Login and Register tabs with a smooth transition
    function switchAuthTab(tab) {
        const tabLogin = document.getElementById('modal-tab-login');
        const tabRegister = document.getElementById('modal-tab-register');
        const panelLogin = document.getElementById('modal-login-panel');
        const panelRegister = document.getElementById('modal-register-panel');
        const panelForgotPassword = document.getElementById('modal-forgot-password-panel');
        const panelOtp = document.getElementById('modal-otp-panel');
        const panelResetPassword = document.getElementById('modal-reset-password-panel');
        const card = document.getElementById('auth-modal-card');
        const tabHeader = document.getElementById('modal-tabs-header');
        
        if (!card) return;

        const currentPanel = document.querySelector('.modal-panel:not(.hidden)');
        if (!currentPanel) return;

        if (tab === 'otp') {
            if (currentPanel === panelForgotPassword) {
                otpSourceTab = 'forgot-password';
            } else if (currentPanel === panelRegister) {
                otpSourceTab = 'register';
            }
        }

        let targetPanel;
        if (tab === 'login') targetPanel = panelLogin;
        else if (tab === 'register') targetPanel = panelRegister;
        else if (tab === 'forgot-password') targetPanel = panelForgotPassword;
        else if (tab === 'otp') targetPanel = panelOtp;
        else if (tab === 'reset-password') targetPanel = panelResetPassword;

        if (!targetPanel || targetPanel === currentPanel) return;

        // Clean up old messages/errors
        clearModalAlerts();

        // 1. Fade out inactive panel first
        currentPanel.style.opacity = '0';
        currentPanel.style.transform = 'translateY(8px)';
        
        // 2. Animate card width
        if (tab === 'register') {
            card.classList.remove('max-w-[460px]');
            card.classList.add('max-w-[880px]');
        } else {
            card.classList.remove('max-w-[880px]');
            card.classList.add('max-w-[460px]');
        }

        // 3. Tab headers display and active tabs
        if (tab === 'login' || tab === 'register') {
            if (tabHeader) tabHeader.classList.remove('hidden');
            
            if (tab === 'login') {
                tabLogin.classList.remove('text-slate-400', 'border-transparent');
                tabLogin.classList.add('text-slate-900', 'border-[#378b76]');
                
                tabRegister.classList.remove('text-slate-900', 'border-[#378b76]');
                tabRegister.classList.add('text-slate-400', 'border-transparent');
            } else {
                tabRegister.classList.remove('text-slate-400', 'border-transparent');
                tabRegister.classList.add('text-slate-900', 'border-[#378b76]');
                
                tabLogin.classList.remove('text-slate-900', 'border-[#378b76]');
                tabLogin.classList.add('text-slate-400', 'border-transparent');
            }
        } else {
            if (tabHeader) tabHeader.classList.add('hidden');
        }

        // 4. Toggle hidden classes and fade in the active panel
        setTimeout(() => {
            currentPanel.classList.add('hidden');
            targetPanel.classList.remove('hidden');
            
            // Set initial state for active panel transition
            targetPanel.style.opacity = '0';
            targetPanel.style.transform = 'translateY(8px)';
            targetPanel.style.transition = 'opacity 300ms ease-out, transform 300ms ease-out';
            
            // Trigger animation frame for fade-in
            requestAnimationFrame(() => {
                setTimeout(() => {
                    targetPanel.style.opacity = '1';
                    targetPanel.style.transform = 'translateY(0)';
                }, 20);
            });
        }, 150);
    }

    function goBackFromOtp() {
        switchAuthTab(otpSourceTab);
    }

    // Clear existing alert banners
    function clearModalAlerts() {
        const alerts = [
            'login-error-banner', 'login-success-banner',
            'register-error-banner', 
            'forgot-password-error-banner',
            'otp-error-banner', 'otp-success-banner',
            'reset-password-error-banner'
        ];
        alerts.forEach(id => {
            const el = document.getElementById(id);
            if (el) el.classList.add('hidden');
        });
    }

    // Toggle password visibility
    function togglePassField(id, btn) {
        const input = document.getElementById(id);
        const icon = btn.querySelector('span');
        if (input) {
            if (input.type === 'password') {
                input.type = 'text';
                icon.textContent = 'visibility_off';
            } else {
                input.type = 'password';
                icon.textContent = 'visibility';
            }
        }
    }

    // Password strength indicator for registration
    function updateModalPwStrength(inp) {
        const v = inp.value;
        let s = 0;
        if (v.length >= 8) s++;
        if (/[A-Z]/.test(v)) s++;
        if (/[a-z]/.test(v)) s++;
        if (/[0-9]/.test(v)) s++;
        if (/[^A-Za-z0-9]/.test(v)) s++;
        
        let strength = 0;
        if (v.length > 0) strength = 1;
        if (s >= 3) strength = 2;
        if (s >= 4) strength = 3;
        if (s >= 5) strength = 4;
        
        const cols = ['#f43f5e', '#f59e0b', '#8b5cf6', '#10b981'];
        for (let i = 1; i <= 4; i++) {
            const el = document.getElementById('modalRegStr' + i);
            if (el) {
                if (i <= strength) {
                    el.style.backgroundColor = cols[strength - 1];
                } else {
                    el.style.backgroundColor = '#e2e8f0';
                }
            }
        }
    }

    // Password strength indicator for reset password
    function updateModalResetPwStrength(inp) {
        const v = inp.value;
        let s = 0;
        if (v.length >= 8) s++;
        if (/[A-Z]/.test(v)) s++;
        if (/[a-z]/.test(v)) s++;
        if (/[0-9]/.test(v)) s++;
        if (/[^A-Za-z0-9]/.test(v)) s++;
        
        let strength = 0;
        if (v.length > 0) strength = 1;
        if (s >= 3) strength = 2;
        if (s >= 4) strength = 3;
        if (s >= 5) strength = 4;
        
        const cols = ['#f43f5e', '#f59e0b', '#8b5cf6', '#10b981'];
        for (let i = 1; i <= 4; i++) {
            const el = document.getElementById('modalResetStr' + i);
            if (el) {
                if (i <= strength) {
                    el.style.backgroundColor = cols[strength - 1];
                } else {
                    el.style.backgroundColor = '#e2e8f0';
                }
            }
        }
    }

    // AJAX Login submission
    function submitLoginForm(event) {
        event.preventDefault();
        
        const form = document.getElementById('modal-login-form');
        const btn = document.getElementById('modal-login-btn');
        const spinner = btn.querySelector('.loading-spinner');
        const btnText = btn.querySelector('.btn-text');
        
        const errorBanner = document.getElementById('login-error-banner');
        const successBanner = document.getElementById('login-success-banner');
        
        if (errorBanner) errorBanner.classList.add('hidden');
        if (successBanner) successBanner.classList.add('hidden');
        
        // Show spinner
        if (spinner && btnText) {
            spinner.classList.remove('hidden');
            btnText.style.opacity = '0';
            btn.style.pointerEvents = 'none';
        }
        
        const formData = new FormData(form);
        const searchParams = new URLSearchParams(formData);
        
        fetch(form.action, {
            method: 'POST',
            headers: {
                'Accept': 'application/json',
                'X-Requested-With': 'XMLHttpRequest',
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: searchParams
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                if (successBanner) {
                    successBanner.querySelector('.success-msg').textContent = 'Đăng nhập thành công! Đang chuyển hướng...';
                    successBanner.classList.remove('hidden');
                }
                setTimeout(() => {
                    window.location.href = data.redirectUrl;
                }, 800);
            } else {
                // Reset spinner
                if (spinner && btnText) {
                    spinner.classList.add('hidden');
                    btnText.style.opacity = '1';
                    btn.style.pointerEvents = '';
                }
                if (errorBanner) {
                    errorBanner.querySelector('.error-msg').textContent = data.loi || 'Đăng nhập không thành công.';
                    errorBanner.classList.remove('hidden');
                }
            }
        })
        .catch(err => {
            console.error('Lỗi login AJAX:', err);
            if (spinner && btnText) {
                spinner.classList.add('hidden');
                btnText.style.opacity = '1';
                btn.style.pointerEvents = '';
            }
            if (errorBanner) {
                errorBanner.querySelector('.error-msg').textContent = 'Có lỗi mạng xảy ra. Vui lòng thử lại!';
                errorBanner.classList.remove('hidden');
            }
        });
    }

    // AJAX Register submission
    function submitRegisterForm(event) {
        event.preventDefault();
        
        const form = document.getElementById('modal-register-form');
        const btn = document.getElementById('modal-register-btn');
        const spinner = btn.querySelector('.loading-spinner');
        const btnText = btn.querySelector('.btn-text');
        
        const errorBanner = document.getElementById('register-error-banner');
        if (errorBanner) errorBanner.classList.add('hidden');
        
        // Show spinner
        if (spinner && btnText) {
            spinner.classList.remove('hidden');
            btnText.style.opacity = '0';
            btn.style.pointerEvents = 'none';
        }
        
        const formData = new FormData(form);
        const searchParams = new URLSearchParams();
        
        // Convert FormData to URLSearchParams
        for (const [key, value] of formData.entries()) {
            searchParams.append(key, value);
        }
        
        fetch(form.action, {
            method: 'POST',
            headers: {
                'Accept': 'application/json',
                'X-Requested-With': 'XMLHttpRequest',
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: searchParams
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                if (data.step === 'otp') {
                    // Populate email in OTP displays
                    const displayEl = document.getElementById('otp-email-display');
                    const hiddenEmailEl = document.getElementById('otp-hidden-email');
                    if (displayEl) displayEl.textContent = data.email;
                    if (hiddenEmailEl) hiddenEmailEl.value = data.email;
                    
                    // Reset registration spinner
                    if (spinner && btnText) {
                        spinner.classList.add('hidden');
                        btnText.style.opacity = '1';
                        btn.style.pointerEvents = '';
                    }

                    // Show success banner in OTP modal
                    const otpSuccessBanner = document.getElementById('otp-success-banner');
                    if (otpSuccessBanner) {
                        otpSuccessBanner.querySelector('.success-msg').textContent = 'Đăng ký thông tin thành công! Vui lòng nhập mã OTP để kích hoạt.';
                        otpSuccessBanner.classList.remove('hidden');
                    }
                    
                    // Switch to OTP panel
                    switchAuthTab('otp');
                } else {
                    window.location.href = data.redirectUrl;
                }
            } else {
                // Reset spinner
                if (spinner && btnText) {
                    spinner.classList.add('hidden');
                    btnText.style.opacity = '1';
                    btn.style.pointerEvents = '';
                }
                if (errorBanner) {
                    errorBanner.querySelector('.error-msg').textContent = data.loi || 'Đăng ký không thành công.';
                    errorBanner.classList.remove('hidden');
                    
                    // Scroll modal card content to top
                    const scrollContainer = document.querySelector('.auth-modal-scroll');
                    if (scrollContainer) {
                        scrollContainer.scrollTop = 0;
                    }
                }
            }
        })
        .catch(err => {
            console.error('Lỗi register AJAX:', err);
            if (spinner && btnText) {
                spinner.classList.add('hidden');
                btnText.style.opacity = '1';
                btn.style.pointerEvents = '';
            }
            if (errorBanner) {
                errorBanner.querySelector('.error-msg').textContent = 'Có lỗi mạng xảy ra. Vui lòng thử lại!';
                errorBanner.classList.remove('hidden');
            }
        });
    }

    // AJAX Forgot Password submission
    function submitForgotPasswordForm(event) {
        event.preventDefault();
        
        const form = document.getElementById('modal-forgot-password-form');
        const btn = document.getElementById('modal-forgot-password-btn');
        const spinner = btn.querySelector('.loading-spinner');
        const btnText = btn.querySelector('.btn-text');
        const errorBanner = document.getElementById('forgot-password-error-banner');
        
        if (errorBanner) errorBanner.classList.add('hidden');
        
        // Show spinner
        if (spinner && btnText) {
            spinner.classList.remove('hidden');
            btnText.style.opacity = '0';
            btn.style.pointerEvents = 'none';
        }
        
        const formData = new FormData(form);
        const searchParams = new URLSearchParams(formData);
        const email = formData.get('email');
        
        fetch(form.action, {
            method: 'POST',
            headers: {
                'Accept': 'application/json',
                'X-Requested-With': 'XMLHttpRequest',
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: searchParams
        })
        .then(response => response.json())
        .then(data => {
            // Reset spinner
            if (spinner && btnText) {
                spinner.classList.add('hidden');
                btnText.style.opacity = '1';
                btn.style.pointerEvents = '';
            }
            
            if (data.success) {
                // Populate email in OTP displays
                const displayEl = document.getElementById('otp-email-display');
                const hiddenEmailEl = document.getElementById('otp-hidden-email');
                if (displayEl) displayEl.textContent = email;
                if (hiddenEmailEl) hiddenEmailEl.value = email;
                
                // Show dynamic OTP success banner
                const otpSuccessBanner = document.getElementById('otp-success-banner');
                if (otpSuccessBanner) {
                    otpSuccessBanner.querySelector('.success-msg').textContent = 'Mã OTP đã được gửi đến email của bạn!';
                    otpSuccessBanner.classList.remove('hidden');
                }
                
                // Switch to OTP panel
                switchAuthTab('otp');
            } else {
                if (errorBanner) {
                    errorBanner.querySelector('.error-msg').textContent = data.loi || 'Có lỗi xảy ra.';
                    errorBanner.classList.remove('hidden');
                }
            }
        })
        .catch(err => {
            console.error('Lỗi Forgot Password AJAX:', err);
            if (spinner && btnText) {
                spinner.classList.add('hidden');
                btnText.style.opacity = '1';
                btn.style.pointerEvents = '';
            }
            if (errorBanner) {
                errorBanner.querySelector('.error-msg').textContent = 'Có lỗi mạng xảy ra. Vui lòng thử lại!';
                errorBanner.classList.remove('hidden');
            }
        });
    }

    // AJAX OTP submission
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
        
        // Show spinner
        if (spinner && btnText) {
            spinner.classList.remove('hidden');
            btnText.style.opacity = '0';
            btn.style.pointerEvents = 'none';
        }
        
        const formData = new FormData(form);
        const searchParams = new URLSearchParams(formData);
        
        fetch(form.action, {
            method: 'POST',
            headers: {
                'Accept': 'application/json',
                'X-Requested-With': 'XMLHttpRequest',
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: searchParams
        })
        .then(response => response.json())
        .then(data => {
            // Reset spinner
            if (spinner && btnText) {
                spinner.classList.add('hidden');
                btnText.style.opacity = '1';
                btn.style.pointerEvents = '';
            }
            
            if (data.success) {
                if (data.step === 'reset-password') {
                    // Transition to reset password panel
                    switchAuthTab('reset-password');
                } else if (data.step === 'register-success') {
                    // Registration complete! Show success banner on Login tab and switch there
                    switchAuthTab('login');
                    const loginSuccessBanner = document.getElementById('login-success-banner');
                    if (loginSuccessBanner) {
                        loginSuccessBanner.querySelector('.success-msg').textContent = data.thongbao || 'Đăng ký thành công! Vui lòng đăng nhập.';
                        loginSuccessBanner.classList.remove('hidden');
                    }
                }
            } else {
                if (errorBanner) {
                    errorBanner.querySelector('.error-msg').textContent = data.loi || 'Mã xác thực không đúng.';
                    errorBanner.classList.remove('hidden');
                }
            }
        })
        .catch(err => {
            console.error('Lỗi Verify OTP AJAX:', err);
            if (spinner && btnText) {
                spinner.classList.add('hidden');
                btnText.style.opacity = '1';
                btn.style.pointerEvents = '';
            }
            if (errorBanner) {
                errorBanner.querySelector('.error-msg').textContent = 'Có lỗi mạng xảy ra. Vui lòng thử lại!';
                errorBanner.classList.remove('hidden');
            }
        });
    }

    // AJAX OTP Resend
    function resendOtp() {
        const errorBanner = document.getElementById('otp-error-banner');
        const successBanner = document.getElementById('otp-success-banner');
        const emailInput = document.getElementById('otp-hidden-email');
        
        if (errorBanner) errorBanner.classList.add('hidden');
        if (successBanner) successBanner.classList.add('hidden');
        
        if (!emailInput || !emailInput.value) {
            if (errorBanner) {
                errorBanner.querySelector('.error-msg').textContent = 'Không tìm thấy email để gửi lại mã!';
                errorBanner.classList.remove('hidden');
            }
            return;
        }
        
        const params = new URLSearchParams();
        params.append('email', emailInput.value);
        
        fetch('${pageContext.request.contextPath}/resend-otp', {
            method: 'POST',
            headers: {
                'Accept': 'application/json',
                'X-Requested-With': 'XMLHttpRequest',
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: params
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                if (successBanner) {
                    successBanner.querySelector('.success-msg').textContent = data.thongbao || 'Gửi lại mã OTP thành công!';
                    successBanner.classList.remove('hidden');
                }
            } else {
                if (errorBanner) {
                    errorBanner.querySelector('.error-msg').textContent = data.loi || 'Không thể gửi lại mã OTP.';
                    errorBanner.classList.remove('hidden');
                }
            }
        })
        .catch(err => {
            console.error('Lỗi Resend OTP AJAX:', err);
            if (errorBanner) {
                errorBanner.querySelector('.error-msg').textContent = 'Có lỗi mạng xảy ra. Vui lòng thử lại!';
                errorBanner.classList.remove('hidden');
            }
        });
    }

    // AJAX Reset Password submission
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
            if (errorBanner) {
                errorBanner.querySelector('.error-msg').textContent = 'Mật khẩu không được để trống hoặc chỉ chứa khoảng trắng!';
                errorBanner.classList.remove('hidden');
            }
            return;
        }

        // Strong password check
        const strongRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$/;
        if (!strongRegex.test(p1)) {
            if (errorBanner) {
                errorBanner.querySelector('.error-msg').textContent = 'Mật khẩu phải có tối thiểu 8 ký tự, bao gồm cả chữ hoa, chữ thường, số và ký tự đặc biệt.';
                errorBanner.classList.remove('hidden');
            }
            return;
        }
        
        if (p1 !== p2) {
            if (errorBanner) {
                errorBanner.querySelector('.error-msg').textContent = 'Mật khẩu xác nhận chưa trùng khớp!';
                errorBanner.classList.remove('hidden');
            }
            return;
        }
        
        // Show spinner
        if (spinner && btnText) {
            spinner.classList.remove('hidden');
            btnText.style.opacity = '0';
            btn.style.pointerEvents = 'none';
        }
        
        const formData = new FormData(form);
        const searchParams = new URLSearchParams(formData);
        
        fetch(form.action, {
            method: 'POST',
            headers: {
                'Accept': 'application/json',
                'X-Requested-With': 'XMLHttpRequest',
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: searchParams
        })
        .then(response => response.json())
        .then(data => {
            // Reset spinner
            if (spinner && btnText) {
                spinner.classList.add('hidden');
                btnText.style.opacity = '1';
                btn.style.pointerEvents = '';
            }
            
            if (data.success) {
                // Switch to login and display success banner
                switchAuthTab('login');
                const loginSuccessBanner = document.getElementById('login-success-banner');
                if (loginSuccessBanner) {
                    loginSuccessBanner.querySelector('.success-msg').textContent = data.thongbao || 'Đổi mật khẩu thành công! Vui lòng đăng nhập lại.';
                    loginSuccessBanner.classList.remove('hidden');
                }
            } else {
                if (errorBanner) {
                    errorBanner.querySelector('.error-msg').textContent = data.loi || 'Có lỗi xảy ra.';
                    errorBanner.classList.remove('hidden');
                }
            }
        })
        .catch(err => {
            console.error('Lỗi Reset Password AJAX:', err);
            if (spinner && btnText) {
                spinner.classList.add('hidden');
                btnText.style.opacity = '1';
                btn.style.pointerEvents = '';
            }
            if (errorBanner) {
                errorBanner.querySelector('.error-msg').textContent = 'Có lỗi mạng xảy ra. Vui lòng thử lại!';
                errorBanner.classList.remove('hidden');
            }
        });
    }

    // Intercept links to dangnhap / dangky and check URL parameters on load
    document.addEventListener('DOMContentLoaded', () => {
        document.body.addEventListener('click', (e) => {
            const anchor = e.target.closest('a');
            if (anchor && anchor.href) {
                const url = new URL(anchor.href, window.location.origin);
                const path = url.pathname;
                
                // Do not intercept if it is marked as no-modal or contains admin parameter
                if (anchor.hasAttribute('data-no-modal') || url.searchParams.has('admin') || url.searchParams.get('role') === 'admin') {
                    return;
                }
                
                if (path.endsWith('/dangnhap')) {
                    e.preventDefault();
                    openAuthModal('login');
                } else if (path.endsWith('/dangky')) {
                    e.preventDefault();
                    openAuthModal('register');
                }
            }
        });

        // Check query parameters to automatically show modal
        const urlParams = new URLSearchParams(window.location.search);
        const authAction = urlParams.get('auth');
        if (authAction === 'login') {
            openAuthModal('login');
        } else if (authAction === 'register') {
            openAuthModal('register');
        }
    });
</script>
