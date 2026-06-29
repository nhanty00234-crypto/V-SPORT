<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi" class="scroll-smooth">
<head>
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>Đăng ký - V-SPORT</title>
    <c:if test="${empty loi}">
        <script>
            window.location.replace("${pageContext.request.contextPath}/customer/TrangChu.jsp?auth=register");
        </script>
    </c:if>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Oswald:wght@500;600;700&family=Inter:wght@300;400;500;600;700;800&family=Playfair+Display:ital,wght@1,400..900&display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
    <style>
        :root {
            --theme-purple: #8b5cf6;
            --theme-purple-hover: #7c3aed;
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

        /* Right panel style with grid and mesh in purple theme */
        .right-panel {
            background: linear-gradient(135deg, #3b0764 0%, #0b011a 100%);
            position: relative;
        }
        .right-panel::before {
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

        /* Ambient glowing blobs in purple/violet tints */
        .blob {
            position: absolute;
            border-radius: 50%;
            filter: blur(100px);
            opacity: 0.45;
            animation: float-blob 20s infinite ease-in-out;
            pointer-events: none;
        }
        .blob-1 {
            width: 500px;
            height: 500px;
            background: radial-gradient(circle, rgba(168, 85, 247, 0.35) 0%, rgba(168, 85, 247, 0) 70%);
            top: -100px;
            left: -100px;
        }
        .blob-2 {
            width: 600px;
            height: 600px;
            background: radial-gradient(circle, rgba(192, 132, 252, 0.3) 0%, rgba(192, 132, 252, 0) 70%);
            bottom: -150px;
            right: -100px;
            animation-delay: -5s;
        }
        @keyframes float-blob {
            0% { transform: translate(0px, 0px) scale(1); }
            50% { transform: translate(30px, -30px) scale(1.05); }
            100% { transform: translate(0px, 0px) scale(1); }
        }

        /* Floating Sport Icons (Purple theme) */
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
            color: rgba(192, 132, 252, 0.09); /* slightly more visible purple */
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
            font-size: 12px;
            font-weight: 700;
            color: #334155;
            margin-bottom: 5px;
            display: block;
            text-transform: capitalize;
        }
        .input-wrapper {
            margin-bottom: 14px;
            position: relative;
        }
        .input-field {
            width: 100%;
            height: 48px;
            padding-left: 44px;
            padding-right: 44px;
            border: 1.5px solid #cbd5e1;
            background: #ffffff;
            border-radius: 10px;
            font-size: 13px;
            font-weight: 500;
            color: #0f172a;
            transition: all 0.2s ease-in-out;
            outline: none !important;
        }
        .input-field:focus {
            border-color: var(--theme-purple);
            box-shadow: 0 0 0 4px rgba(139, 92, 246, 0.1);
        }
        .input-icon {
            position: absolute;
            left: 14px;
            top: 50%;
            transform: translateY(-50%);
            color: #94a3b8;
            pointer-events: none;
            font-size: 18px;
            transition: color 0.25s;
        }
        .input-field:focus ~ .input-icon {
            color: var(--theme-purple);
        }

        .select-field {
            appearance: none;
            padding-right: 36px;
        }

        .btn-submit {
            width: 100%;
            height: 50px;
            background-color: #6d28d9;
            color: white;
            border-radius: 10px;
            font-weight: 600;
            font-size: 14px;
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
            background-color: #5b21b6;
            transform: translateY(-1px);
            box-shadow: 0 8px 20px -6px rgba(139, 92, 246, 0.3);
        }
        .btn-submit:active {
            transform: translateY(0);
        }

        /* Form scroll styling */
        .form-container {
            overflow-y: auto;
            -ms-overflow-style: none;
            scrollbar-width: none;
        }
        .form-container::-webkit-scrollbar {
            display: none;
        }
    </style>
</head>
<body class="min-h-screen h-screen w-screen overflow-hidden bg-[#f8fafc]">
    <div id="auth-container" class="min-h-screen h-screen w-screen flex flex-col md:flex-row overflow-hidden bg-[#f8fafc] relative">

    <!-- Back to Home Button (Floating Top Left) -->
    <a href="${pageContext.request.contextPath}/index.jsp" class="absolute top-6 left-6 z-[100] flex items-center gap-2.5 px-4 py-2 rounded-xl bg-white/10 hover:bg-white/20 border border-white/10 text-white md:text-slate-600 md:bg-white/80 md:border-slate-200/80 backdrop-blur-md transition-all shadow-sm">
        <span class="material-symbols-outlined text-[18px]">west</span>
        <span class="text-[11px] font-bold uppercase tracking-wider">Trang chủ</span>
    </a>

    <!-- LEFT PANEL (50%) - Registration Form -->
    <div class="register-form-panel w-full md:w-1/2 h-full flex flex-col justify-center bg-[#f8fafc] px-8 sm:px-16 md:px-20 py-12 overflow-y-auto relative z-20 animate-slide-left form-container">
        
        <!-- Center Box to match design padding -->
        <div class="w-full max-w-[500px] mx-auto flex flex-col justify-center my-auto">

            <!-- Small Badge: System Role Indicator -->
            <div class="inline-flex items-center gap-2 bg-white border border-purple-200/80 text-purple-600 rounded-full py-1.5 px-4 text-[12px] font-bold w-fit shadow-sm mb-5">
                <div class="w-2 h-2 rounded-full bg-purple-500 animate-pulse"></div>
                <span>Hệ thống V-Sport</span>
            </div>

            <!-- Heading & Subtitle -->
            <div class="mb-5">
                <h2 class="text-[32px] font-bold tracking-tight text-slate-900 leading-tight">Đăng ký thành viên</h2>
                <p class="text-[13px] text-slate-400 mt-1 font-medium">Bắt đầu hành trình chinh phục sân đấu và kết nối bạn bè ngay hôm nay.</p>
            </div>

            <!-- Error Banner -->
            <c:if test="${not empty loi}">
                <div class="mb-5 p-3.5 bg-red-50 text-red-600 rounded-xl text-xs font-semibold border border-red-100 flex items-center gap-3 shadow-sm">
                    <span class="material-symbols-outlined text-[18px]">error</span>
                    <span>${loi}</span>
                </div>
            </c:if>

            <!-- Form -->
            <form id="main-register-form" action="${pageContext.request.contextPath}/dangky" method="POST" class="flex flex-col" autocomplete="off">
                
                <!-- Section 1: Thông tin tài khoản -->
                <div class="border-b border-slate-100 pb-3 mb-4">
                    <span class="text-[10px] font-bold text-purple-600 uppercase tracking-wider mb-3 block">1. Thông tin tài khoản</span>
                    
                    <div class="grid grid-cols-2 gap-4">
                        <div class="input-wrapper">
                            <label class="form-label">Tên đăng nhập</label>
                            <div class="relative">
                                <input type="text" name="username" required placeholder="Nhập tên đăng nhập" class="input-field">
                                <span class="material-symbols-outlined input-icon">person</span>
                            </div>
                        </div>
                        <div class="input-wrapper">
                            <label class="form-label">Email</label>
                            <div class="relative">
                                <input type="email" name="email" required placeholder="Nhập địa chỉ email" class="input-field">
                                <span class="material-symbols-outlined input-icon">mail</span>
                            </div>
                        </div>
                    </div>

                    <div class="grid grid-cols-2 gap-4">
                        <div class="input-wrapper mb-2">
                            <label class="form-label">Mật khẩu</label>
                            <div class="relative">
                                <input type="password" name="password" id="reg-pass" required placeholder="Tạo mật khẩu" oninput="updateRegPwStrength(this)" class="input-field">
                                <span class="material-symbols-outlined input-icon">key</span>
                                <button type="button" onclick="togglePass('reg-pass', this)" class="absolute right-3.5 top-1/2 -translate-y-1/2 text-slate-400 hover:text-purple-600 transition-all">
                                    <span class="material-symbols-outlined text-[18px]">visibility</span>
                                </button>
                            </div>
                        </div>
                        <div class="input-wrapper mb-2">
                            <label class="form-label">Xác nhận mật khẩu</label>
                            <div class="relative">
                                <input type="password" name="confirm_password" id="reg-confirm-pass" required placeholder="Nhập lại mật khẩu" class="input-field">
                                <span class="material-symbols-outlined input-icon">key</span>
                                <button type="button" onclick="togglePass('reg-confirm-pass', this)" class="absolute right-3.5 top-1/2 -translate-y-1/2 text-slate-400 hover:text-purple-600 transition-all">
                                    <span class="material-symbols-outlined text-[18px]">visibility</span>
                                </button>
                            </div>
                        </div>
                    </div>

                    <!-- Password strength indicator -->
                    <div class="mt-1.5 w-full">
                        <div class="flex gap-1 w-1/2 mb-1.5">
                            <div class="h-1 flex-1 rounded-full bg-slate-200 transition-colors duration-300" id="regStr1"></div>
                            <div class="h-1 flex-1 rounded-full bg-slate-200 transition-colors duration-300" id="regStr2"></div>
                            <div class="h-1 flex-1 rounded-full bg-slate-200 transition-colors duration-300" id="regStr3"></div>
                            <div class="h-1 flex-1 rounded-full bg-slate-200 transition-colors duration-300" id="regStr4"></div>
                        </div>
                        <p class="text-[9.5px] text-slate-400 leading-tight">Mật khẩu tối thiểu 8 ký tự, bao gồm chữ hoa, chữ thường, số và ký tự đặc biệt.</p>
                    </div>
                </div>

                <!-- Section 2: Thông tin cá nhân -->
                <div class="border-b border-slate-100 pb-3 mb-4">
                    <span class="text-[10px] font-bold text-purple-600 uppercase tracking-wider mb-3 block">2. Thông tin cá nhân</span>
                    
                    <div class="grid grid-cols-2 gap-4 mb-3">
                        <div class="input-wrapper mb-0">
                            <label class="form-label">Họ và Tên</label>
                            <div class="relative">
                                <input type="text" name="fullname" required placeholder="Nhập họ và tên" class="input-field">
                                <span class="material-symbols-outlined input-icon">badge</span>
                            </div>
                        </div>
                        <div class="input-wrapper mb-0">
                            <label class="form-label">Số điện thoại</label>
                            <div class="relative">
                                <input type="tel" name="phone" required placeholder="Nhập số điện thoại" class="input-field">
                                <span class="material-symbols-outlined input-icon">call</span>
                            </div>
                        </div>
                    </div>

                    <div class="input-wrapper mb-0">
                        <label class="form-label">Giới tính</label>
                        <div class="relative">
                            <select name="gender" required class="input-field select-field">
                                <option value="Nam">Nam</option>
                                <option value="Nữ">Nữ</option>
                            </select>
                            <span class="material-symbols-outlined input-icon">wc</span>
                            <span class="material-symbols-outlined absolute right-4 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none">arrow_drop_down</span>
                        </div>
                    </div>
                </div>

                <!-- Section 3: Thể thao & Sở trường -->
                <div class="border-b border-slate-100 pb-4 mb-5">
                    <span class="text-[10px] font-bold text-purple-600 uppercase tracking-wider mb-3 block">3. Thể thao & kỹ năng</span>
                    
                    <div class="input-wrapper mb-4">
                        <label class="form-label">Vị trí sở trường</label>
                        <div class="relative">
                            <input type="text" name="viTriSoTruong" placeholder="Ví dụ: Tiền đạo, Hậu vệ, Đập cầu..." class="input-field">
                            <span class="material-symbols-outlined input-icon">sports_handball</span>
                        </div>
                    </div>

                    <div>
                        <label class="form-label text-slate-400">Môn thể thao yêu thích</label>
                        <div class="grid grid-cols-2 gap-3 mt-2">
                            <label class="flex items-center gap-3 bg-white border border-slate-200 px-4 py-3 rounded-xl cursor-pointer hover:border-purple-600/40 transition-colors font-medium text-xs text-slate-700 select-none shadow-sm">
                                <input type="checkbox" name="sport" value="Bóng đá" class="w-4 h-4 accent-purple-600 rounded">
                                Bóng đá
                            </label>
                            <label class="flex items-center gap-3 bg-white border border-slate-200 px-4 py-3 rounded-xl cursor-pointer hover:border-purple-600/40 transition-colors font-medium text-xs text-slate-700 select-none shadow-sm">
                                <input type="checkbox" name="sport" value="Cầu lông" class="w-4 h-4 accent-purple-600 rounded">
                                Cầu lông
                            </label>
                            <label class="flex items-center gap-3 bg-white border border-slate-200 px-4 py-3 rounded-xl cursor-pointer hover:border-purple-600/40 transition-colors font-medium text-xs text-slate-700 select-none shadow-sm">
                                <input type="checkbox" name="sport" value="Pickleball" class="w-4 h-4 accent-purple-600 rounded">
                                Pickleball
                            </label>
                            <label class="flex items-center gap-3 bg-white border border-slate-200 px-4 py-3 rounded-xl cursor-pointer hover:border-purple-600/40 transition-colors font-medium text-xs text-slate-700 select-none shadow-sm">
                                <input type="checkbox" name="sport" value="Tennis" class="w-4 h-4 accent-purple-600 rounded">
                                Tennis
                            </label>
                        </div>
                    </div>
                </div>

                <!-- Agreement checkbox -->
                <div class="flex items-center gap-3 mb-6 select-none">
                    <input type="checkbox" name="agree" value="Đồng ý" required class="w-4.5 h-4.5 accent-purple-600 rounded border-slate-300 cursor-pointer">
                    <span class="text-[12.5px] text-slate-500 font-semibold leading-tight">
                        Tôi đồng ý với các <a href="#" class="text-purple-600 font-bold hover:underline">điều khoản</a> và <a href="#" class="text-purple-600 font-bold hover:underline">chính sách</a> của hệ thống.
                    </span>
                </div>

                <!-- Submit Button -->
                <button type="submit" id="main-register-btn" class="btn-submit">
                    <span class="btn-text flex items-center gap-1.5">
                        Kích hoạt Athlete Pass
                        <span class="material-symbols-outlined text-[18px]">how_to_reg</span>
                    </span>
                    <!-- Loading Spinner -->
                    <div class="loading-spinner hidden absolute inset-0 bg-[#6d28d9] flex items-center justify-center">
                        <div class="w-5 h-5 border-2 border-white/20 border-t-white rounded-full animate-spin"></div>
                    </div>
                </button>
            </form>

            <!-- Bottom Navigation Link -->
            <div class="mt-6 text-center border-t border-slate-100 pt-5">
                <p class="text-[13px] text-slate-500 font-medium">
                    Đã có tài khoản? 
                    <a href="${pageContext.request.contextPath}/dangnhap" class="font-bold text-purple-600 hover:underline ml-1">
                        Đăng nhập ngay
                    </a>
                </p>
            </div>

        </div>
    </div>

    <!-- RIGHT PANEL (50%) - Dark Sporty Frame in Purple Theme -->
    <div class="right-panel hidden md:flex md:w-1/2 h-full flex-col justify-between p-16 z-10 text-white overflow-hidden animate-slide-right">
        <!-- Ambient glowing blobs in purple theme -->
        <div class="blob blob-1"></div>
        <div class="blob blob-2"></div>

        <!-- Floating wiggling sports icons in background (Purple theme) -->
        <span class="material-symbols-outlined floating-icon float-rotate-1 text-[110px]" style="top: 15%; left: 12%; animation: float-rotate-1 10s infinite ease-in-out;">sports_soccer</span>
        <span class="material-symbols-outlined floating-icon float-rotate-2 text-[80px]" style="bottom: 25%; right: 8%; animation: float-rotate-2 7s infinite ease-in-out;">sports_tennis</span>
        <span class="material-symbols-outlined floating-icon float-rotate-3 text-[96px]" style="top: 45%; left: 10%; animation: float-rotate-3 12s infinite ease-in-out;">sports_baseball</span>
        <span class="material-symbols-outlined floating-icon float-rotate-1 text-[86px]" style="bottom: 42%; left: 18%; animation: float-rotate-1 9s infinite ease-in-out;">sports_volleyball</span>

        <!-- Logo Container -->
        <div class="relative z-10 flex items-center gap-3 bg-white/5 border border-white/10 rounded-2xl p-4 w-fit backdrop-blur-md self-end">
            <div class="w-10 h-10 bg-white rounded-xl flex items-center justify-center text-[#051937] font-bold text-base shadow-inner">
                VS
            </div>
            <div class="flex flex-col leading-none">
                <span class="text-[15px] font-bold tracking-tight text-white">V-Sport</span>
                <span class="text-[9px] text-white/50 font-bold tracking-widest uppercase mt-0.5">Elite Arena</span>
            </div>
        </div>

        <!-- Main Heading content matching layout of MediVault image but mirrored and in purple -->
        <div class="relative z-10 flex flex-col gap-6 max-w-[520px] my-auto self-end text-right items-end">
            <h1 class="text-[52px] md:text-[60px] font-bold tracking-tight leading-[1.1] text-white">
                Gia nhập<br/>
                cộng đồng<br/>
                <span class="text-[#d8b4fe] font-serif-italic font-normal">thể thao</span>
            </h1>
            <p class="text-[14px] text-white/60 leading-relaxed font-light">
                Gia nhập hệ thống thể thao chuyên nghiệp hàng đầu. Quản lý lịch trình, tham gia thi đấu giao hữu và theo dõi Elo bảng xếp hạng của bạn.
            </p>
            
            <!-- Dedicated "Đăng nhập tại đây" Button -->
            <a href="${pageContext.request.contextPath}/dangnhap" class="group mt-2 flex items-center gap-4 px-6 py-4 bg-white/5 hover:bg-white/10 border border-white/10 rounded-2xl transition-all hover:scale-[1.02] hover:border-white/20 backdrop-blur-md w-fit">
                <div class="w-10 h-10 rounded-full bg-white flex items-center justify-center text-[#3b0764] transition-transform group-hover:-translate-x-1 shadow-md">
                    <span class="material-symbols-outlined text-[18px] text-[#3b0764]">arrow_back</span>
                </div>
                <div class="flex flex-col text-left">
                    <span class="text-[9px] font-bold uppercase tracking-widest text-[#d8b4fe]">Đã có tài khoản?</span>
                    <span class="text-[18px] font-display italic text-white leading-none uppercase mt-1">Đăng nhập tại đây</span>
                </div>
            </a>
        </div>

        <!-- Footer widgets in purple theme -->
        <div class="relative z-10 flex flex-col gap-5 border-t border-white/10 pt-6 items-end">
            <!-- Pill Badges -->
            <div class="flex flex-wrap gap-3 justify-end">
                <span class="inline-flex items-center gap-2 px-4 py-2 rounded-xl bg-white/5 border border-white/10 text-xs font-semibold text-white/80 backdrop-blur-sm">
                    <span class="material-symbols-outlined text-[16px] text-[#d8b4fe]">sports_kabaddi</span>
                    Athlete Pass
                </span>
                <span class="inline-flex items-center gap-2 px-4 py-2 rounded-xl bg-white/5 border border-white/10 text-xs font-semibold text-white/80 backdrop-blur-sm">
                    <span class="material-symbols-outlined text-[16px] text-[#d8b4fe]">workspace_premium</span>
                    Hạng đấu
                </span>
                <span class="inline-flex items-center gap-2 px-4 py-2 rounded-xl bg-white/5 border border-white/10 text-xs font-semibold text-white/80 backdrop-blur-sm">
                    <span class="material-symbols-outlined text-[16px] text-[#d8b4fe]">groups</span>
                    Ghép kèo
                </span>
            </div>

            <!-- Dot list -->
            <div class="flex items-center gap-6 text-[11px] font-semibold tracking-wider text-white/40 uppercase">
                <div class="flex items-center gap-2">
                    <div class="w-1.5 h-1.5 rounded-full bg-[#d8b4fe]"></div>
                    <span>Athlete Card cá nhân</span>
                </div>
                <div class="flex items-center gap-2">
                    <div class="w-1.5 h-1.5 rounded-full bg-[#d8b4fe]"></div>
                    <span>Theo dõi Elo</span>
                </div>
                <div class="flex items-center gap-2">
                    <div class="w-1.5 h-1.5 rounded-full bg-[#d8b4fe]"></div>
                    <span>Kết nối kèo nhanh</span>
                </div>
            </div>
        </div>
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

        // Global utility function for registration strength indicator
        function updateRegPwStrength(inp) {
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
                const el = document.getElementById('regStr' + i);
                if (el) {
                    if (i <= strength) {
                        el.style.backgroundColor = cols[strength - 1];
                    } else {
                        el.style.backgroundColor = '#e2e8f0';
                    }
                }
            }
        }

        // Bind form submit spinner
        function bindFormSubmit() {
            const mainRegisterForm = document.getElementById('main-register-form');
            const mainRegisterBtn = document.getElementById('main-register-btn');
            if (mainRegisterForm && mainRegisterBtn) {
                mainRegisterForm.onsubmit = function() {
                    const spinner = mainRegisterBtn.querySelector('.loading-spinner');
                    const btnText = mainRegisterBtn.querySelector('.btn-text');
                    if (spinner && btnText) {
                        spinner.classList.remove('hidden');
                        btnText.style.opacity = '0';
                        mainRegisterBtn.style.pointerEvents = 'none';
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