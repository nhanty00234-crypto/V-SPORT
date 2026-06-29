<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi" class="scroll-smooth">
<head>
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>Đăng nhập - V-SPORT</title>

    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Oswald:wght@500;600;700&family=Inter:wght@300;400;500;600;700;800&family=Playfair+Display:ital,wght@1,400..900&display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
    <style>
        :root {
            --theme-blue: #2563eb;
            --theme-blue-hover: #1d4ed8;
            --text-dark: #0f172a;
        }
        body { 
            font-family: 'Inter', sans-serif; 
            color: var(--text-dark); 
            background-color: #f8fafc;
            overflow: hidden;
        }
        .font-display { font-family: 'Oswald', sans-serif; }
        .font-serif-italic { font-family: 'Playfair Display', serif; font-style: italic; }

        /* Left panel style with grid and mesh */
        .left-panel {
            background: linear-gradient(135deg, #051937 0%, #000c1e 100%);
            position: relative;
        }
        .left-panel::before {
            content: '';
            position: absolute;
            inset: 0;
            background-image: 
                linear-gradient(rgba(255, 255, 255, 0.02) 1px, transparent 1px), 
                linear-gradient(90deg, rgba(255, 255, 255, 0.02) 1px, transparent 1px);
            background-size: 50px 50px;
            pointer-events: none;
            z-index: 1;
        }

        /* Ambient glowing blobs */
        .blob {
            position: absolute;
            border-radius: 50%;
            filter: blur(100px);
            opacity: 0.3;
            animation: float-blob 20s infinite ease-in-out;
            pointer-events: none;
        }
        .blob-1 {
            width: 500px;
            height: 500px;
            background: radial-gradient(circle, rgba(37,99,235,0.25) 0%, rgba(37,99,235,0) 70%);
            top: -100px;
            left: -100px;
        }
        .blob-2 {
            width: 600px;
            height: 600px;
            background: radial-gradient(circle, rgba(14,165,233,0.2) 0%, rgba(14,165,233,0) 70%);
            bottom: -150px;
            right: -100px;
            animation-delay: -5s;
        }
        @keyframes float-blob {
            0% { transform: translate(0px, 0px) scale(1); }
            50% { transform: translate(30px, -30px) scale(1.05); }
            100% { transform: translate(0px, 0px) scale(1); }
        }

        /* Floating Sport Icons (Dynamic Wiggle/Float Effects) */
        @keyframes float-rotate-1 {
            0% { transform: translate(0, 0) rotate(0deg); }
            50% { transform: translate(15px, -20px) rotate(12deg); }
            100% { transform: translate(0, 0) rotate(0deg); }
        }
        @keyframes float-rotate-2 {
            0% { transform: translate(0, 0) rotate(0deg); }
            50% { transform: translate(-15px, 15px) rotate(-15deg); }
            100% { transform: translate(0, 0) rotate(0deg); }
        }
        @keyframes float-rotate-3 {
            0% { transform: translate(0, 0) rotate(0deg); }
            50% { transform: translate(10px, 15px) rotate(18deg); }
            100% { transform: translate(0, 0) rotate(0deg); }
        }
        .floating-icon {
            position: absolute;
            color: rgba(56, 189, 248, 0.05); /* very subtle light blue */
            pointer-events: none;
            user-select: none;
            z-index: 2;
        }

        /* Entrance Animations (Micro Transitions) */
        @keyframes fadeInSlideLeft {
            from { transform: translateX(-20px); opacity: 0; }
            to { transform: translateX(0); opacity: 1; }
        }
        @keyframes fadeInSlideRight {
            from { transform: translateX(20px); opacity: 0; }
            to { transform: translateX(0); opacity: 1; }
        }
        .animate-slide-left {
            animation: fadeInSlideLeft 0.6s cubic-bezier(0.16, 1, 0.3, 1) forwards;
        }
        .animate-slide-right {
            animation: fadeInSlideRight 0.6s cubic-bezier(0.16, 1, 0.3, 1) forwards;
        }

        /* Form styling */
        .form-label {
            font-size: 13px;
            font-weight: 700;
            color: #334155;
            margin-bottom: 6px;
            display: block;
            text-transform: capitalize;
        }
        .input-wrapper {
            margin-bottom: 20px;
            position: relative;
        }
        .input-field {
            width: 100%;
            height: 52px;
            padding-left: 48px;
            padding-right: 48px;
            border: 1.5px solid #cbd5e1;
            background: #ffffff;
            border-radius: 12px;
            font-size: 14px;
            font-weight: 500;
            color: #0f172a;
            transition: all 0.2s ease-in-out;
            outline: none !important;
        }
        .input-field:focus {
            border-color: var(--theme-blue);
            box-shadow: 0 0 0 4px rgba(37, 99, 235, 0.1);
        }
        .input-icon {
            position: absolute;
            left: 16px;
            top: 50%;
            transform: translateY(-50%);
            color: #94a3b8;
            pointer-events: none;
            font-size: 20px;
            transition: color 0.25s;
        }
        .input-field:focus ~ .input-icon {
            color: var(--theme-blue);
        }

        .btn-submit {
            width: 100%;
            height: 54px;
            background-color: #1e40af;
            color: white;
            border-radius: 12px;
            font-weight: 600;
            font-size: 15px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            transition: all 0.3s;
            position: relative;
            overflow: hidden;
            border: none;
        }
        .btn-submit:hover {
            background-color: #1d4ed8;
            transform: translateY(-1px);
            box-shadow: 0 8px 20px -6px rgba(37, 99, 235, 0.3);
        }
        .btn-submit:active {
            transform: translateY(0);
        }

        @keyframes bounce-x {
            0%, 100% { transform: translateX(0); }
            50% { transform: translateX(4px); }
        }
        .animate-bounce-x {
            animation: bounce-x 1s infinite;
        }
    </style>
</head>
<body class="min-h-screen h-screen w-screen overflow-hidden bg-[#f8fafc]">
    <div id="auth-container" class="min-h-screen h-screen w-screen flex flex-col md:flex-row overflow-hidden bg-[#f8fafc] relative">

    <!-- Back to Home Button (Floating Top Left) -->
    <a href="${pageContext.request.contextPath}/index.jsp" class="absolute top-6 left-6 z-[100] flex items-center gap-2.5 px-4 py-2 rounded-xl bg-white/10 hover:bg-white/20 border border-white/10 text-white backdrop-blur-md transition-all shadow-sm">
        <span class="material-symbols-outlined text-[18px]">west</span>
        <span class="text-[11px] font-bold uppercase tracking-wider">Trang chủ</span>
    </a>

    <!-- LEFT PANEL (50%) - Dark Sporty Frame -->
    <div class="left-panel hidden md:flex md:w-1/2 h-full flex-col justify-between p-16 z-10 text-white overflow-hidden animate-slide-left">
        <!-- Ambient glowing blobs -->
        <div class="blob blob-1"></div>
        <div class="blob blob-2"></div>

        <!-- Floating wiggling sports icons in background -->
        <span class="material-symbols-outlined floating-icon float-rotate-1 text-[110px]" style="top: 15%; right: 12%; animation: float-rotate-1 10s infinite ease-in-out;">sports_soccer</span>
        <span class="material-symbols-outlined floating-icon float-rotate-2 text-[80px]" style="bottom: 25%; left: 8%; animation: float-rotate-2 7s infinite ease-in-out;">sports_tennis</span>
        <span class="material-symbols-outlined floating-icon float-rotate-3 text-[96px]" style="top: 45%; right: 10%; animation: float-rotate-3 12s infinite ease-in-out;">sports_basketball</span>
        <span class="material-symbols-outlined floating-icon float-rotate-1 text-[86px]" style="bottom: 42%; right: 18%; animation: float-rotate-1 9s infinite ease-in-out;">sports_volleyball</span>

        <!-- Logo Container -->
        <div class="relative z-10 flex items-center gap-3 bg-white/5 border border-white/10 rounded-2xl p-4 w-fit backdrop-blur-md">
            <div class="w-10 h-10 bg-white rounded-xl flex items-center justify-center text-[#051937] font-bold text-base shadow-inner">
                VS
            </div>
            <div class="flex flex-col leading-none">
                <span class="text-[15px] font-bold tracking-tight text-white">V-Sport</span>
                <span class="text-[9px] text-white/50 font-bold tracking-widest uppercase mt-0.5">Elite Arena</span>
            </div>
        </div>

        <!-- Main Heading content matching layout of MediVault image -->
        <div class="relative z-10 flex flex-col gap-6 max-w-[520px] my-auto">
            <h1 class="text-[52px] md:text-[60px] font-bold tracking-tight leading-[1.1] text-white">
                Quản trị<br/>
                sân thể thao<br/>
                <span class="text-[#38bdf8] font-serif-italic font-normal">chuyên nghiệp</span>
            </h1>
            <p class="text-[14px] text-white/60 leading-relaxed font-light">
                Hệ thống đặt sân & quản lý thể thao chuyên nghiệp. Kết nối kèo đấu, so trình đồng đội ngay tức khắc.
            </p>
                        <!-- System Info -->
                <div class="mt-2 flex flex-col text-left text-white/50 text-[12px]">
                    <span class="font-bold uppercase tracking-wider text-[#38bdf8]">Hệ thống V-Sport</span>
                    <span>Đặt sân thể thao, kết nối bạn bè và quản lý toàn bộ hoạt động thể thao.</span>
                </div>
        </div>

        <!-- Footer widgets matching MediVault image -->
        <div class="relative z-10 flex flex-col gap-5 border-t border-white/10 pt-6">
            <!-- Pill Badges -->
            <div class="flex flex-wrap gap-3">
                <span class="inline-flex items-center gap-2 px-4 py-2 rounded-xl bg-white/5 border border-white/10 text-xs font-semibold text-white/80 backdrop-blur-sm">
                    <span class="material-symbols-outlined text-[16px] text-[#38bdf8]">sports_soccer</span>
                    Sân bãi
                </span>
                <span class="inline-flex items-center gap-2 px-4 py-2 rounded-xl bg-white/5 border border-white/10 text-xs font-semibold text-white/80 backdrop-blur-sm">
                    <span class="material-symbols-outlined text-[16px] text-[#38bdf8]">verified_user</span>
                    Bảo mật OTP
                </span>
                <span class="inline-flex items-center gap-2 px-4 py-2 rounded-xl bg-white/5 border border-white/10 text-xs font-semibold text-white/80 backdrop-blur-sm">
                    <span class="material-symbols-outlined text-[16px] text-[#38bdf8]">analytics</span>
                    Thống kê
                </span>
            </div>

            <!-- Dot list -->
            <div class="flex items-center gap-6 text-[11px] font-semibold tracking-wider text-white/40 uppercase">
                <div class="flex items-center gap-2">
                    <div class="w-1.5 h-1.5 rounded-full bg-[#38bdf8]"></div>
                    <span>Đặt sân Real-time</span>
                </div>
                <div class="flex items-center gap-2">
                    <div class="w-1.5 h-1.5 rounded-full bg-[#38bdf8]"></div>
                    <span>Phân quyền đa cấp</span>
                </div>
                <div class="flex items-center gap-2">
                    <div class="w-1.5 h-1.5 rounded-full bg-[#38bdf8]"></div>
                    <span>Bảo mật nâng cao</span>
                </div>
            </div>
        </div>
    </div>

    <!-- RIGHT PANEL (50%) - Form -->
    <div class="login-form-panel w-full md:w-1/2 h-full flex flex-col justify-center bg-[#f8fafc] px-8 sm:px-16 md:px-24 py-16 overflow-y-auto relative z-20 animate-slide-right">
        
        <!-- Center Box to match design padding -->
        <div class="w-full max-w-[440px] mx-auto flex flex-col justify-center">

            <div class="inline-flex items-center gap-2 bg-white border border-slate-200/80 text-blue-600 rounded-full py-1.5 px-4 text-[12px] font-bold w-fit shadow-sm mb-6">
                <div class="w-2 h-2 rounded-full bg-blue-500 animate-pulse"></div>
                <span>Hệ thống V-Sport</span>
            </div>

            <!-- Heading & Subtitle -->
            <div class="mb-8">
                <h2 class="text-[36px] font-bold tracking-tight text-slate-900 leading-tight">Đăng nhập</h2>
                <p class="text-[14px] text-slate-400 mt-2 font-medium">Chào mừng trở lại! Nhập thông tin tài khoản để tiếp tục.</p>
            </div>

            <!-- Error Banner -->
            <c:if test="${not empty loi}">
                <div class="mb-6 p-4 bg-red-50 text-red-600 rounded-xl text-xs font-semibold border border-red-100 flex items-center gap-3 shadow-sm">
                    <span class="material-symbols-outlined text-[18px]">error</span>
                    <span>${loi}</span>
                </div>
            </c:if>

            <!-- Success/Info Banner -->
            <c:if test="${not empty thongbao}">
                <div class="mb-6 p-4 bg-green-50 text-green-600 rounded-xl text-xs font-semibold border border-green-100 flex items-center gap-3 shadow-sm">
                    <span class="material-symbols-outlined text-[18px]">check_circle</span>
                    <span>${thongbao}</span>
                </div>
            </c:if>

            <!-- Form -->
            <form id="main-login-form" action="${pageContext.request.contextPath}/dangnhap" method="POST" class="flex flex-col" autocomplete="off">
                <!-- Username Input -->
                <div class="input-wrapper">
                    <label class="form-label">Tên đăng nhập hoặc Email</label>
                    <div class="relative">
                        <input type="text" name="username" value="${username}" required placeholder="Nhập tên đăng nhập hoặc email" class="input-field" autocomplete="off">
                        <span class="material-symbols-outlined input-icon">person</span>
                    </div>
                </div>

                <!-- Password Input -->
                <div class="input-wrapper">
                    <label class="form-label">Mật khẩu</label>
                    <div class="relative">
                        <input type="password" name="password" id="login-pass" required placeholder="Nhập mật khẩu" class="input-field" autocomplete="new-password">
                        <span class="material-symbols-outlined input-icon">key</span>
                        <!-- Password visibility toggle -->
                        <button type="button" onclick="togglePass('login-pass', this)" class="absolute right-4 top-1/2 -translate-y-1/2 text-slate-400 hover:text-[#2563eb] transition-all">
                            <span class="material-symbols-outlined text-[20px]">visibility</span>
                        </button>
                    </div>
                </div>

                <!-- Remember Me and Forgot Password Container -->
                <div class="flex items-center justify-between mb-8">
                    <label class="flex items-center gap-2.5 cursor-pointer select-none text-[13px] text-slate-500 font-semibold">
                        <input type="checkbox" name="rememberMe" class="w-4 h-4 accent-blue-600 rounded border-slate-300">
                        <span>Ghi nhớ đăng nhập (7 ngày)</span>
                    </label>
                    
                    <a href="${pageContext.request.contextPath}/quenmatkhau" class="text-[13px] font-bold text-blue-600 hover:underline">
                        Quên mật khẩu?
                    </a>
                </div>

                <!-- Submit Button -->
                <button type="submit" id="main-login-btn" class="btn-submit">
                    <span class="btn-text flex items-center gap-1.5">
                        Đăng nhập
                        <span class="material-symbols-outlined text-[18px] animate-bounce-x">arrow_forward</span>
                    </span>
                    <!-- Loading Spinner -->
                    <div class="loading-spinner hidden absolute inset-0 bg-[#1e40af] flex items-center justify-center">
                        <div class="w-5 h-5 border-2 border-white/20 border-t-white rounded-full animate-spin"></div>
                    </div>
                </button>
            </form>




        </div>
    </div><!-- #auth-container -->

    <!-- Shared Auth Logic Script -->
    <script>


        // Global utility function for password toggle
        function togglePass(id, btn) {
            const input = document.getElementById(id);
            const icon = btn.querySelector('span');
            if (input.type === 'password') {
                input.type = 'text';
                icon.textContent = 'visibility_off';
            } else {
                input.type = 'password';
                icon.textContent = 'visibility';
            }
        }

        // Bind form submit spinner
        function bindFormSubmit() {
            const mainLoginForm = document.getElementById('main-login-form');
            const mainLoginBtn = document.getElementById('main-login-btn');
            if (mainLoginForm && mainLoginBtn) {
                mainLoginForm.onsubmit = function() {
                    const spinner = mainLoginBtn.querySelector('.loading-spinner');
                    const btnText = mainLoginBtn.querySelector('.btn-text');
                    if (spinner && btnText) {
                        spinner.classList.remove('hidden');
                        btnText.style.opacity = '0';
                        mainLoginBtn.style.pointerEvents = 'none';
                    }
                };
            }
        }

        // Initialize on page load
        document.addEventListener('DOMContentLoaded', () => {
            bindFormSubmit();
        });
    </script>
</body>
</html>
