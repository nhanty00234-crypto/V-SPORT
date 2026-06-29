<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<div class="fixed top-4 left-4 right-4 z-50 lg:left-[312px] transition-all duration-300">
    <header class="glass-panel h-[70px] flex items-center justify-between px-8">
        <!-- Left: Search & Mobile Toggle -->
        <div class="flex items-center gap-6 flex-1">
            <button id="mobileMenuBtn" class="lg:hidden p-2 text-gray-400 hover:text-primary transition-colors">
                <span class="material-symbols-outlined">menu</span>
            </button>
            
            <div class="hidden md:flex items-center gap-3 bg-white/40 border border-white/30 rounded-2xl px-4 py-2 w-full max-w-md focus-within:bg-white/60 transition-all">
                <span class="material-symbols-outlined text-gray-400 text-[20px]">search</span>
                <input type="text" placeholder="Tìm kiếm dữ liệu..." class="bg-transparent border-none p-0 text-[13px] w-full focus:ring-0 placeholder:text-gray-400 text-gray-600">
            </div>
        </div>

        <!-- Right: Actions & Profile -->
        <div class="flex items-center gap-4">
            <!-- Action Icons -->
            <div class="flex items-center gap-1 border-r border-white/30 pr-4">
                <button class="w-10 h-10 flex items-center justify-center rounded-xl text-gray-500 hover:bg-white/60 hover:text-primary transition-all">
                    <span class="material-symbols-outlined text-[22px]">notifications</span>
                </button>
                <button class="w-10 h-10 flex items-center justify-center rounded-xl text-gray-500 hover:bg-white/60 hover:text-primary transition-all">
                    <span class="material-symbols-outlined text-[22px]">dark_mode</span>
                </button>
            </div>
            
            <!-- Profile Section -->
            <div class="relative group">
                <button id="adminProfileBtn" class="flex items-center gap-3 p-1.5 hover:bg-white/40 rounded-2xl transition-all">
                    <div class="w-10 h-10 rounded-xl overflow-hidden border-2 border-white/50 shadow-sm">
                        <img class="w-full h-full object-cover" src="https://ui-avatars.com/api/?name=${user.fullName}&background=5c6c7b&color=fff&bold=true" alt="User">
                    </div>
                    <div class="text-left hidden sm:block">
                        <p class="text-[12px] font-black text-primary leading-tight">${user.fullName != null ? user.fullName : 'Quản trị viên'}</p>
                        <p class="text-[9px] font-bold text-gray-400 uppercase tracking-widest mt-0.5">Quản trị hệ thống</p>
                    </div>
                    <span class="material-symbols-outlined text-gray-400 text-[18px] ml-1">expand_more</span>
                </button>
                
                <!-- Dropdown (Glass) -->
                <div id="adminProfileDropdown" class="hidden absolute top-[calc(100%+12px)] right-0 w-64 glass-panel p-3 z-[70] animate__animated animate__fadeInUp animate__faster">
                    <a href="${pageContext.request.contextPath}/admin/profile" class="flex items-center gap-3 px-4 py-3 rounded-2xl text-[13px] font-bold text-gray-600 hover:bg-white/60 hover:text-primary transition-all">
                        <span class="material-symbols-outlined text-[20px]">account_circle</span>
                        Hồ sơ cá nhân
                    </a>
                    <div class="h-px bg-white/30 my-2"></div>
                    <a href="${pageContext.request.contextPath}/logout" class="flex items-center gap-3 px-4 py-3 rounded-2xl text-[13px] font-black text-red-500 hover:bg-red-50/50 transition-all">
                        <span class="material-symbols-outlined text-[20px]">logout</span>
                        Thoát hệ thống
                    </a>
                </div>
            </div>
        </div>
    </header>
</div>

<script>
    document.addEventListener('DOMContentLoaded', () => {
        const profileBtn = document.getElementById('adminProfileBtn');
        const profileDropdown = document.getElementById('adminProfileDropdown');
        
        if (profileBtn && profileDropdown) {
            profileBtn.addEventListener('click', (e) => {
                e.stopPropagation();
                profileDropdown.classList.toggle('hidden');
            });
            
            document.addEventListener('click', () => {
                profileDropdown.classList.add('hidden');
            });
        }
    });
</script>