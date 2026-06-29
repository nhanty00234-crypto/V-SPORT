<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>Khôi phục mật khẩu - V-SPORT</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" rel="stylesheet"/>
    <style>
        body { font-family: 'Inter', sans-serif; }
    </style>
</head>
<body class="min-h-screen flex items-center justify-center p-4 relative overflow-hidden bg-slate-900/60 backdrop-blur-sm">
    
    <!-- Blurred Background Stadium Image -->
    <div class="absolute inset-0 bg-cover bg-center opacity-25 blur-[8px] scale-105 pointer-events-none z-0" 
         style="background-image: url('https://images.unsplash.com/photo-1508098682722-e99c43a406b2?q=80&w=2000&auto=format&fit=crop');"></div>

    <!-- Modal Card (Centered popup, identical layout to login modal) -->
    <div class="bg-white rounded-3xl w-full max-w-[460px] p-8 shadow-2xl relative border border-slate-100 flex flex-col z-10">
        
        <!-- Back Button as a Close button -->
        <a href="${pageContext.request.contextPath}/dangnhap" class="absolute top-5 right-5 text-slate-400 hover:text-slate-655 transition-colors z-[130] w-8 h-8 rounded-full flex items-center justify-center bg-slate-50 hover:bg-slate-100">
            <span class="material-symbols-outlined text-[20px]">close</span>
        </a>

        <!-- Header -->
        <div class="mb-6">
            <div class="inline-flex items-center gap-2 bg-white border border-[#378b76]/30 text-[#378b76] rounded-full py-1 px-3.5 text-[11px] font-bold w-fit shadow-sm mb-3">
                <div class="w-1.5 h-1.5 rounded-full bg-[#378b76] animate-pulse"></div>
                <span>Hệ thống V-Sport</span>
            </div>
            <h2 class="text-xl font-bold tracking-tight text-slate-900 mb-1">Quên mật khẩu?</h2>
            <p class="text-[13px] text-slate-400 font-medium leading-relaxed">Đừng lo lắng, hãy nhập địa chỉ email đã đăng ký của bạn để bắt đầu khôi phục mật khẩu.</p>
        </div>

        <!-- Error Banner -->
        <c:if test="${not empty loi}">
            <div id="error-banner" class="mb-5 p-4 bg-red-50 text-red-600 border border-red-100 rounded-xl text-xs font-semibold flex items-center gap-3 shadow-sm">
                <span class="material-symbols-outlined text-[18px] shrink-0">error</span>
                <span>${loi}</span>
            </div>
        </c:if>

        <!-- Form -->
        <form id="forgot-pw-form" action="${pageContext.request.contextPath}/quenmatkhau" method="POST" class="flex flex-col" autocomplete="off">
            
            <!-- Email Input -->
            <div class="mb-5">
                <label class="text-[12px] font-bold text-slate-700 mb-1.5 block">Email đã đăng ký</label>
                <div class="relative">
                    <input type="email" name="email" value="${oldEmail}" required placeholder="Nhập địa chỉ email" 
                           class="w-full h-12 pl-12 pr-4 border border-slate-300 rounded-xl text-[13px] font-medium text-slate-900 focus:border-[#378b76] focus:ring-4 focus:ring-[#378b76]/10 transition-all outline-none" 
                           style="border-width: 1.5px;">
                    <span class="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none text-[20px]">mail</span>
                </div>
            </div>

            <!-- Submit Button -->
            <button type="submit" id="submit-btn" class="w-full h-12 bg-[#378b76] hover:bg-[#2c6f5e] text-white rounded-xl font-bold text-[14px] flex items-center justify-center gap-2 transition-all relative overflow-hidden shadow-md shadow-emerald-50">
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
                <a href="${pageContext.request.contextPath}/dangnhap" class="font-bold text-[#378b76] hover:underline ml-1">
                    Đăng nhập ngay
                </a>
            </p>
        </div>

    </div>

    <script>
        const form = document.getElementById('forgot-pw-form');
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