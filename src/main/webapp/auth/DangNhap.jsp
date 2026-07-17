<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="org.example.model.TaiKhoan" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="vi" class="light">
<head>
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>Đăng nhập - V-SPORT</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600;700;800&amp;family=Inter:wght@400;500;600;700&amp;display=swap" rel="stylesheet"/>
    <style>
        body {
            font-family: 'Inter', system-ui, -apple-system, sans-serif;
            min-height: 100dvh;
            background-color: #0b8a60;
            background-image:
                radial-gradient(130% 95% at 88% -12%, rgba(52, 211, 153, 0.15), transparent 55%),
                radial-gradient(150% 110% at -25% 115%, rgba(3, 56, 38, 0.45), transparent 62%),
                radial-gradient(95% 75% at 112% 82%, rgba(52, 211, 153, 0.08), transparent 55%),
                radial-gradient(1400px 720px at 50% 125%, rgba(6, 78, 59, 0.65), transparent 66%);
            background-attachment: fixed;
            position: relative;
        }

        /* Input overrides to matches visual specifications */
        .login-input:focus {
            outline: none;
            border-color: #059669;
            box-shadow: 0 0 0 3px rgba(5, 150, 105, 0.15);
        }
    </style>
</head>
<body class="text-gray-900 antialiased flex flex-col justify-between">

    <!-- Background sports lines layout overlays (pure CSS geometry) -->
    <div class="absolute inset-0 overflow-hidden pointer-events-none z-0">
        <svg class="absolute w-[200%] h-[200%] -top-[50%] -left-[50%] opacity-[0.06]" viewBox="0 0 100 100" preserveAspectRatio="none" aria-hidden="true">
            <circle cx="50" cy="50" r="45" fill="none" stroke="white" stroke-width="0.25" />
            <circle cx="50" cy="50" r="30" fill="none" stroke="white" stroke-width="0.2" />
            <path d="M 0 50 Q 50 15 100 50" fill="none" stroke="white" stroke-width="0.25" />
            <path d="M 0 50 Q 50 85 100 50" fill="none" stroke="white" stroke-width="0.25" />
            <line x1="50" y1="0" x2="50" y2="100" stroke="white" stroke-width="0.2" />
        </svg>
    </div>

    <!-- Header bar -->
    <header class="w-full h-14 md:h-16 flex items-center justify-between px-4 md:px-8 bg-black/10 select-none relative z-10 border-b border-white/5">
        <!-- Back button (links to index.jsp) -->
        <a href="<%= ctx %>/index.jsp" id="login-back-btn" class="text-white hover:text-emerald-100 flex items-center justify-center w-10 h-10 rounded-full hover:bg-white/10 transition-colors text-decoration-none" aria-label="Quay lại trang chủ">
            <span class="material-symbols-outlined text-[24px]">chevron_left</span>
        </a>

        <!-- Centered title -->
        <div class="absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2">
            <h1 class="text-white font-extrabold text-base md:text-lg tracking-wide uppercase font-['Outfit']">Đăng nhập</h1>
        </div>

        <!-- Placeholder balance block -->
        <div class="w-10"></div>
    </header>

    <!-- Main Form Content -->
    <main class="flex-grow flex flex-col justify-center items-center py-8 px-4 z-10 relative">
        <div class="w-full max-w-[600px] bg-white rounded-lg shadow-2xl overflow-hidden border border-gray-100">
            <!-- Double-tab layout: Email (active) / Phone (disabled since database only checks username/email) -->
            <div class="flex border-b border-gray-100 select-none h-14">
                <div class="flex-1 flex items-center justify-center font-bold text-[#047857] border-b-2 border-[#047857] text-sm md:text-base bg-white">
                    Email / Tên đăng nhập
                </div>
                <div onclick="showPhoneLoginNotice()" class="flex-1 flex items-center justify-center font-semibold text-gray-400 bg-gray-50/50 cursor-pointer text-sm md:text-base hover:bg-gray-100/70 transition-colors" title="Tính năng đăng nhập qua số điện thoại">
                    Số điện thoại
                </div>
            </div>

            <div class="p-6 md:p-8">
                <!-- Errors alerts -->
                <c:if test="${not empty loi}">
                    <div class="flex items-start gap-2.5 bg-red-50 border border-red-200 text-red-700 rounded-lg p-3.5 mb-6 text-sm font-semibold leading-relaxed" role="alert" id="login-error">
                        <span class="material-symbols-outlined text-[18px] shrink-0 mt-0.5" aria-hidden="true">error</span>
                        <span><c:out value="${loi}"/></span>
                    </div>
                </c:if>

                <!-- Login form -->
                <form id="main-login-form" action="<%= ctx %>/dangnhap" method="POST" autocomplete="off">
                    <input type="hidden" name="loginType" value="customer" />

                    <!-- Username/Email input -->
                    <div class="mb-6">
                        <label for="login-username" class="block text-sm font-bold text-[#047857] mb-2 font-['Outfit'] uppercase tracking-wide">Tài khoản của bạn?</label>
                        <input type="text" name="username" id="login-username" value="<c:out value='${username}'/>"
                               placeholder="Nhập email hoặc tên đăng nhập"
                               class="login-input w-full h-[50px] border border-gray-200 rounded-lg px-4 text-sm text-gray-800 bg-white placeholder-gray-400 font-medium transition-all"
                               autocomplete="username" required
                               <c:if test="${not empty loi}">aria-describedby="login-error" style="border-color:#fca5a5;"</c:if> />
                    </div>

                    <!-- Password input -->
                    <div class="mb-6">
                        <label for="login-pass" class="block text-sm font-bold text-[#047857] mb-2 font-['Outfit'] uppercase tracking-wide">Mật khẩu (*)</label>
                        <div class="relative">
                            <input type="password" name="password" id="login-pass"
                                   placeholder="Nhập mật khẩu (*)"
                                   class="login-input w-full h-[50px] border border-gray-200 rounded-lg pl-4 pr-12 text-sm text-gray-800 bg-white placeholder-gray-400 font-medium transition-all"
                                   autocomplete="current-password" required />
                            <!-- Visibility toggle button -->
                            <button type="button" id="login-eye-btn" class="absolute right-2 top-1/2 -translate-y-1/2 w-10 h-10 flex items-center justify-center text-gray-400 hover:text-emerald-700 bg-transparent border-none cursor-pointer rounded-lg" aria-label="Hiện mật khẩu" title="Hiện mật khẩu">
                                <span class="material-symbols-outlined text-[20px]" aria-hidden="true">visibility_off</span>
                            </button>
                        </div>
                    </div>

                    <!-- Submit action button -->
                    <button type="submit" id="main-login-btn" class="w-full h-[50px] bg-[#047857] hover:bg-[#065f46] text-white font-extrabold rounded-lg tracking-wider text-sm transition-colors border-none cursor-pointer uppercase">
                        ĐĂNG NHẬP
                    </button>

                    <!-- Forgot password link -->
                    <div class="text-center mt-5 text-xs font-semibold text-gray-500">
                        Bạn quên mật khẩu?
                        <a href="<%= ctx %>/quenmatkhau" class="text-[#047857] hover:underline font-bold ml-1">Quên mật khẩu</a>
                    </div>
                </form>
            </div>
        </div>

        <!-- Register switch helper link -->
        <p class="text-white text-sm font-semibold mt-6 select-none">
            Bạn chưa có tài khoản?
            <a href="<%= ctx %>/dangky" class="text-yellow-400 hover:underline font-bold ml-1">Đăng ký</a>
        </p>

        <!-- System role login helpful alert box -->
        <div class="w-full max-w-[600px] mt-6 bg-white/10 border border-white/20 rounded-lg p-4 text-emerald-100 text-xs text-center font-medium leading-relaxed select-none">
            Bạn là Nhân viên, Quản lý hoặc Quản trị viên? Đăng nhập bằng tài khoản hệ thống — hệ thống sẽ tự chuyển đến trang phù hợp với vai trò của bạn.
        </div>
    </main>

    <!-- Footer generic spacing container -->
    <footer class="w-full py-4 text-center select-none relative z-10 text-emerald-100/50 text-[10px] font-semibold">
        V-SPORT © 2026.
    </footer>

    <!-- Toast elements for page operations feedback -->
    <div id="vsLoginToast" role="status" aria-live="polite" style="position:fixed;left:50%;bottom:26px;transform:translateX(-50%) translateY(12px);z-index:1300;background:#0f172a;color:#fff;padding:10px 16px;border-radius:9999px;font-size:13px;font-weight:600;opacity:0;visibility:hidden;transition:opacity .2s ease,transform .2s ease;box-shadow:0 6px 18px rgba(15,23,42,.25);"></div>

    <script>
        (function () {
            // Toast control function
            let vsLoginToastTimer = null;
            function showLoginToast(msg) {
                const toast = document.getElementById('vsLoginToast');
                if (!toast) return;
                toast.textContent = msg;
                toast.style.opacity = '1';
                toast.style.visibility = 'visible';
                toast.style.transform = 'translateX(-50%) translateY(0)';
                clearTimeout(vsLoginToastTimer);
                vsLoginToastTimer = setTimeout(() => {
                    toast.style.opacity = '0';
                    toast.style.transform = 'translateX(-50%) translateY(12px)';
                    setTimeout(() => { toast.style.visibility = 'hidden'; }, 220);
                }, 2500);
            }

            // Phone login inactive state alert
            window.showPhoneLoginNotice = function() {
                showLoginToast("Hệ thống chưa hỗ trợ đăng nhập qua SĐT. Vui lòng dùng Email/Tên đăng nhập.");
            };

            // Back button control
            const backBtn = document.getElementById('login-back-btn');
            if (backBtn) {
                backBtn.addEventListener('click', function (e) {
                    if (document.referrer && document.referrer.indexOf(window.location.host) > -1 && history.length > 1) {
                        e.preventDefault();
                        history.back();
                    }
                });
            }

            // Password visibility toggle behavior
            const eyeBtn = document.getElementById('login-eye-btn');
            const passInput = document.getElementById('login-pass');
            if (eyeBtn && passInput) {
                eyeBtn.addEventListener('click', function () {
                    const showing = passInput.type === 'text';
                    passInput.type = showing ? 'password' : 'text';
                    eyeBtn.setAttribute('aria-label', showing ? 'Hiện mật khẩu' : 'Ẩn mật khẩu');
                    eyeBtn.setAttribute('title', showing ? 'Hiện mật khẩu' : 'Ẩn mật khẩu');
                    eyeBtn.querySelector('.material-symbols-outlined').textContent = showing ? 'visibility_off' : 'visibility';
                });
            }

            // Double submit guard logic
            const form = document.getElementById('main-login-form');
            const submitBtn = document.getElementById('main-login-btn');
            if (form && submitBtn) {
                form.addEventListener('submit', function () {
                    submitBtn.disabled = true;
                    submitBtn.textContent = 'ĐANG ĐĂNG NHẬP...';
                });
            }
        })();
    </script>
</body>
</html>
