<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    if (request.getAttribute("email") == null && request.getParameter("email") != null) {
        request.setAttribute("email", request.getParameter("email"));
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>Xác minh OTP - V-SPORT</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" rel="stylesheet"/>
    <style>
        body { font-family: 'Inter', sans-serif; }
        .otp-input {
            text-align: center;
            font-size: 1.5rem;
            letter-spacing: 0.35em;
            font-weight: 700;
        }
    </style>
</head>
<body class="min-h-screen flex items-center justify-center p-4 relative overflow-hidden bg-slate-900/60 backdrop-blur-sm">
    
    <!-- Blurred Background Stadium Image -->
    <div class="absolute inset-0 bg-cover bg-center opacity-25 blur-[8px] scale-105 pointer-events-none z-0" 
         style="background-image: url('https://images.unsplash.com/photo-1508098682722-e99c43a406b2?q=80&w=2000&auto=format&fit=crop');"></div>

    <!-- Modal Card (Centered popup, identical layout to login modal) -->
    <div class="bg-white rounded-3xl w-full max-w-[460px] p-8 shadow-2xl relative border border-slate-100 flex flex-col z-10">
        
        <!-- Back Button -->
        <a href="javascript:history.back()" class="absolute top-5 right-5 text-slate-400 hover:text-slate-650 transition-colors z-[130] w-8 h-8 rounded-full flex items-center justify-center bg-slate-50 hover:bg-slate-100">
            <span class="material-symbols-outlined text-[20px]">close</span>
        </a>

        <!-- Header -->
        <div class="mb-6">
            <div class="inline-flex items-center gap-2 bg-white border border-[#378b76]/30 text-[#378b76] rounded-full py-1 px-3.5 text-[11px] font-bold w-fit shadow-sm mb-3">
                <div class="w-1.5 h-1.5 rounded-full bg-[#378b76] animate-pulse"></div>
                <span>Xác minh danh tính</span>
            </div>
            <h2 class="text-xl font-bold tracking-tight text-slate-900 mb-1">Xác thực OTP</h2>
            <p class="text-[13px] text-slate-400 font-medium leading-relaxed">
                Vui lòng kiểm tra email và nhập mã xác thực OTP 6 chữ số gửi tới <b class="text-slate-800">${email}</b>.
            </p>
        </div>

        <!-- Error Banner -->
        <c:if test="${not empty loi}">
            <div id="error-banner" class="mb-5 p-4 bg-red-50 text-red-650 border border-red-100 rounded-xl text-xs font-semibold flex items-center gap-3 shadow-sm">
                <span class="material-symbols-outlined text-[18px] shrink-0">error</span>
                <span>${loi}</span>
            </div>
        </c:if>

        <!-- Success Banner -->
        <c:if test="${not empty thongbao}">
            <div id="success-banner" class="mb-5 p-4 bg-emerald-50 text-emerald-600 border border-emerald-100 rounded-xl text-xs font-semibold flex items-center gap-3 shadow-sm">
                <span class="material-symbols-outlined text-[18px] shrink-0">check_circle</span>
                <span>${thongbao}</span>
            </div>
        </c:if>

        <!-- Form -->
        <form id="otp-form" action="${pageContext.request.contextPath}/nhapma" method="POST" class="flex flex-col" autocomplete="off">
            <input type="hidden" name="email" value="${email}">

            <!-- OTP Input -->
            <div class="mb-5">
                <label class="text-[12px] font-bold text-slate-700 mb-1.5 block">Nhập mã OTP 6 chữ số</label>
                <div class="relative">
                    <input type="text" name="otp" required maxlength="6" placeholder="••••••" 
                           class="w-full h-14 border border-slate-300 rounded-xl otp-input focus:border-[#378b76] focus:ring-4 focus:ring-[#378b76]/10 transition-all outline-none" 
                           style="border-width: 1.5px;">
                </div>
            </div>

            <!-- Submit Button -->
            <button type="submit" id="submit-btn" class="w-full h-12 bg-[#378b76] hover:bg-[#2c6f5e] text-white rounded-xl font-bold text-[14px] flex items-center justify-center gap-2 transition-all relative overflow-hidden shadow-md shadow-emerald-50">
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

        <!-- Footer -->
        <div class="mt-6 text-center border-t border-slate-100 pt-4">
            <p class="text-[12px] text-slate-500 font-medium">
                Không nhận được mã? 
                <a href="${pageContext.request.contextPath}/resend-otp" class="font-bold text-[#378b76] hover:underline ml-1">
                    Gửi lại ngay
                </a>
            </p>
        </div>

    </div>

    <script>
        const form = document.getElementById('otp-form');
        const btn = document.getElementById('submit-btn');
        if (form && btn) {
            form.addEventListener('submit', () => {
                const spinner = btn.querySelector('.loading-spinner');
                const btnText = btn.querySelector('.btn-text');
                if (spinner && btnText) {
                    spinner.classList.remove('hidden');
                    btnText.style.opacity = '0';
                    btn.style.pointerEvents = 'none';
                }
            });
        }
    </script>
</body>
</html>