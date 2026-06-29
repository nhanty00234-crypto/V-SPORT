<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<div class="fixed top-6 left-0 right-0 z-[100] px-6">
    <nav class="max-w-[1400px] mx-auto bg-white/80 backdrop-blur-md border border-white/20 h-[72px] rounded-[18px] shadow-sm flex items-center justify-between px-8">
        <!-- Left: Logo -->
        <div class="flex items-center gap-3">
            <a href="${pageContext.request.contextPath}/index.jsp" class="flex items-center gap-3 group">
                <div class="w-10 h-10 bg-[#2a2a2a] rounded-[10px] flex items-center justify-center text-white font-bold text-sm transition-transform group-hover:scale-105">VS</div>
                <div class="flex flex-col leading-none">
                    <span class="text-[15px] font-bold text-[#2a2a2a] tracking-tight">V-Sport</span>
                    <span class="text-[10px] text-[#2a2a2a]/40 font-medium tracking-wide uppercase">Elite Arena</span>
                </div>
            </a>
        </div>

        <!-- Center: Navigation Links -->
        <div class="hidden lg:flex items-center gap-10">
            <a href="${pageContext.request.contextPath}/index.jsp" class="text-[13px] font-medium text-[#2a2a2a]/70 hover:text-[#2a2a2a] transition-colors">Trang chủ</a>
            <a href="${pageContext.request.contextPath}/customer/dat-san" class="text-[13px] font-medium text-[#2a2a2a]/70 hover:text-[#2a2a2a] transition-colors">Đặt sân</a>
            <a href="${pageContext.request.contextPath}/ghep-keo" class="text-[13px] font-medium text-[#2a2a2a]/70 hover:text-[#2a2a2a] transition-colors">Ghép kèo</a>
            <a href="${pageContext.request.contextPath}/sos" class="text-[13px] font-medium text-[#2a2a2a]/70 hover:text-[#2a2a2a] transition-colors">Tìm đồng đội</a>
            <a href="${pageContext.request.contextPath}/cua-hang" class="text-[13px] font-medium text-[#2a2a2a]/70 hover:text-[#2a2a2a] transition-colors">Cửa hàng</a>
            <a href="${pageContext.request.contextPath}/bang-xep-hang" class="text-[13px] font-medium text-[#2a2a2a]/70 hover:text-[#2a2a2a] transition-colors">Xếp hạng</a>
        </div>

        <!-- Right: Action Buttons -->
        <div class="flex items-center gap-4">
            <c:choose>
                <c:when test="${user != null}">
                    <!-- User Profile Dropdown -->
                    <div class="relative">
                        <button id="user-menu-button" class="flex items-center gap-2 p-1 pr-3 rounded-full hover:bg-[#2a2a2a]/5 transition-all">
                            <div class="w-8 h-8 rounded-full bg-[#2563eb] flex items-center justify-center text-white font-bold text-xs shadow-sm">
                                <c:choose>
                                    <c:when test="${not empty user.fullName}">
                                        ${fn:substring(user.fullName, 0, 1).toUpperCase()}
                                    </c:when>
                                    <c:otherwise>
                                        ${fn:substring(user.username, 0, 1).toUpperCase()}
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <span class="text-[13px] font-semibold text-[#2a2a2a]">
                                <c:choose>
                                    <c:when test="${not empty user.fullName}">
                                        <c:set var="parts" value="${fn:split(user.fullName, ' ')}" />
                                        ${parts[fn:length(parts) - 1]}
                                    </c:when>
                                    <c:otherwise>
                                        ${user.username}
                                    </c:otherwise>
                                </c:choose>
                            </span>
                        </button>

                        <!-- Dropdown Menu -->
                        <div id="user-dropdown" class="absolute right-0 mt-3 w-64 bg-white border border-[#2a2a2a]/5 rounded-[20px] shadow-xl opacity-0 invisible translate-y-2 transition-all duration-300 z-[110] overflow-hidden">
                            <div class="p-5 border-b border-[#2a2a2a]/5 bg-[#f4f4ef]/50">
                                <span class="block text-[13px] font-bold text-[#2a2a2a]">${user.fullName}</span>
                                <span class="block text-[11px] text-[#2a2a2a]/50 mt-0.5">${user.email}</span>
                            </div>
                            <div class="p-2">
                                <a href="${pageContext.request.contextPath}/customer/TaiKhoan.jsp" class="flex items-center gap-3 px-4 py-2.5 rounded-[12px] hover:bg-[#f4f4ef] text-[13px] text-[#2a2a2a]/70 hover:text-[#2a2a2a] transition-all">
                                    <span class="material-symbols-outlined text-[18px]">account_circle</span>
                                    Hồ sơ cá nhân
                                </a>
                                <a href="${pageContext.request.contextPath}/logout" class="flex items-center gap-3 px-4 py-2.5 rounded-[12px] hover:bg-red-50 text-[13px] text-red-500 transition-all mt-1">
                                    <span class="material-symbols-outlined text-[18px]">logout</span>
                                    Đăng xuất
                                </a>
                            </div>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/dangnhap" class="text-[13px] font-semibold text-[#2a2a2a]/70 hover:text-[#2a2a2a] px-4 transition-colors">Đăng nhập</a>
                </c:otherwise>
            </c:choose>
            
            <a href="#" class="bg-[#2563eb] text-white px-6 h-[44px] flex items-center justify-center rounded-[12px] text-[12px] font-bold uppercase tracking-widest hover:bg-[#1d4ed8] transition-all shadow-sm">
                Nhận báo giá
            </a>
            
            <!-- Mobile Menu Toggle -->
            <button id="mobile-menu-toggle" class="lg:hidden text-[#2a2a2a] p-2">
                <span class="material-symbols-outlined">menu</span>
            </button>
        </div>
    </nav>
</div>

<!-- Mobile Menu -->
<div id="mobile-menu" class="hidden fixed inset-0 z-[110] bg-[#f4f4ef] flex flex-col items-center justify-center gap-8 p-10">
    <a href="${pageContext.request.contextPath}/index.jsp" class="text-3xl font-serif italic text-[#2a2a2a]">Trang chủ</a>
    <a href="${pageContext.request.contextPath}/customer/dat-san" class="text-3xl font-serif italic text-[#2a2a2a]">Dịch vụ</a>
    <a href="#" class="text-3xl font-serif italic text-[#2a2a2a]">Quy trình</a>
    <a href="#" class="text-3xl font-serif italic text-[#2a2a2a]">Đánh giá</a>
    
    <button onclick="document.getElementById('mobile-menu').classList.add('hidden')" class="mt-12 w-14 h-14 rounded-full border border-[#2a2a2a]/10 flex items-center justify-center text-[#2a2a2a]">
        <span class="material-symbols-outlined">close</span>
    </button>
</div>

<script>
    // Existing User Dropdown Toggle
    const userMenuBtn = document.getElementById('user-menu-button');
    const userDropdown = document.getElementById('user-dropdown');
    
    if (userMenuBtn && userDropdown) {
        userMenuBtn.addEventListener('click', (e) => {
            e.stopPropagation();
            userDropdown.classList.toggle('opacity-0');
            userDropdown.classList.toggle('invisible');
            userDropdown.classList.toggle('translate-y-2');
            userDropdown.classList.toggle('translate-y-0');
        });

        document.addEventListener('click', (e) => {
            if (!userDropdown.contains(e.target) && !userMenuBtn.contains(e.target)) {
                userDropdown.classList.add('opacity-0', 'invisible', 'translate-y-2');
                userDropdown.classList.remove('translate-y-0');
            }
        });
    }

    const toggleBtn = document.getElementById('mobile-menu-toggle');
    const mobileMenu = document.getElementById('mobile-menu');
    if (toggleBtn && mobileMenu) {
        toggleBtn.addEventListener('click', (e) => {
            e.stopPropagation();
            mobileMenu.classList.toggle('hidden');
        });
    }
</script>

<jsp:include page="/auth/AuthModal.jsp" />

