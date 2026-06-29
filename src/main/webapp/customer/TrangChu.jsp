<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ page import="org.example.model.TaiKhoan" %>
<!DOCTYPE html>
<html lang="vi" class="scroll-smooth">
<head>
    <title>V-SPORT - Hệ thống đặt sân chuyên nghiệp</title>
    <jsp:include page="/common/head.jsp" />
</head>
<body class="bg-[#f4f4ef] text-[#2a2a2a] min-h-screen flex flex-col antialiased">

    <!-- Shared Header -->
    <jsp:include page="/common/header.jsp" />

    <main class="flex-grow pt-[140px]">
        <!-- Hero Section with Background -->
        <div class="relative w-full">
            <!-- Background Image Layer -->
            <div class="absolute inset-0 -top-[140px] pointer-events-none overflow-hidden z-0">
                <div class="absolute inset-0 bg-[url('${pageContext.request.contextPath}/resources/background-hero.jpg')] bg-cover bg-center opacity-20 blur-[4px] scale-105"></div>
                <!-- Soft overlay to blend with the background color -->
                <div class="absolute inset-0 bg-gradient-to-b from-[#f4f4ef]/60 via-transparent to-[#f4f4ef]"></div>
            </div>

            <!-- Hero Content -->
            <div class="relative z-10 max-w-[1400px] mx-auto grid grid-cols-1 lg:grid-cols-12 gap-12 items-center min-h-[calc(100vh-160px)] px-6 pb-20">
                
                <!-- Left Content: Hero Text -->
                <div class="lg:col-span-7 flex flex-col items-start gap-10 animate-fade-in-up">
                    <div class="inline-flex items-center gap-2 px-4 py-1.5 rounded-full border border-[#2a2a2a]/10 bg-white/40 backdrop-blur-md">
                        <div class="w-1.5 h-1.5 rounded-full bg-[#2563eb]"></div>
                        <span class="text-[10px] font-bold uppercase tracking-[0.2em] text-[#2a2a2a]/60">Quản lý sân thể thao cao cấp</span>
                    </div>

                    <h1 class="text-[72px] lg:text-[110px] leading-[0.85] font-serif tracking-tight text-[#2a2a2a]">
                        V-SPORT<br/>
                       
                    </h1>

                    <p class="text-[18px] lg:text-[22px] text-[#2a2a2a]/60 max-w-[580px] leading-relaxed font-light">
                        Giải pháp quản lý sân bãi toàn diện và tin cậy dành cho những nhà vận hành tâm huyết. Chúng tôi chăm chút từng chi tiết để sân đấu của bạn luôn chuyên nghiệp và sẵn sàng cho những trận cầu đỉnh cao.
                    </p>

                    <!-- Quick Search Bar -->
                    <form action="${pageContext.request.contextPath}/customer/dat-san" method="get" class="w-full max-w-[700px] bg-white rounded-[24px] shadow-lg p-3 border border-white flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-3 sm:gap-1 mt-4">
                        <!-- Sport -->
                        <div class="flex-1 flex items-center gap-2.5 px-4 py-1 sm:py-0 border-b sm:border-b-0 sm:border-r border-neutral-100">
                            <div class="text-[#2563eb] shrink-0 flex items-center">
                                <span class="material-symbols-outlined text-[20px]">sports_soccer</span>
                            </div>
                            <div class="flex-grow flex flex-col items-start min-w-0">
                                <span class="text-[8px] font-bold text-neutral-400 uppercase tracking-widest leading-none">Môn thể thao</span>
                                <select name="sportId" class="w-full bg-transparent border-0 text-[13px] font-bold text-[#2a2a2a] p-0 mt-0.5 focus:ring-0 focus:outline-none cursor-pointer appearance-none">
                                    <option value="1">Bóng đá</option>
                                    <option value="2">Cầu lông</option>
                                    <option value="3">Pickleball</option>
                                    <option value="4">Tennis</option>
                                </select>
                            </div>
                        </div>

                        <!-- Location -->
                        <div class="flex-1 flex items-center gap-2.5 px-4 py-1 sm:py-0 border-b sm:border-b-0 sm:border-r border-neutral-100">
                            <div class="text-[#2563eb] shrink-0 flex items-center">
                                <span class="material-symbols-outlined text-[20px]">location_on</span>
                            </div>
                            <div class="flex-grow flex flex-col items-start min-w-0">
                                <span class="text-[8px] font-bold text-neutral-400 uppercase tracking-widest leading-none">Địa điểm</span>
                                <select name="branchId" class="w-full bg-transparent border-0 text-[13px] font-bold text-[#2a2a2a] p-0 mt-0.5 focus:ring-0 focus:outline-none cursor-pointer appearance-none">
                                    <option value="1">Vũng Tàu</option>
                                    <option value="2">Bà Rịa</option>
                                </select>
                            </div>
                        </div>

                        <!-- Date -->
                        <div class="flex-1 flex items-center gap-2.5 px-4 py-1 sm:py-0">
                            <div class="text-[#2563eb] shrink-0 flex items-center">
                                <span class="material-symbols-outlined text-[20px]">calendar_today</span>
                            </div>
                            <div class="flex-grow flex flex-col items-start min-w-0">
                                <span class="text-[8px] font-bold text-neutral-400 uppercase tracking-widest leading-none">Ngày đặt</span>
                                <input type="date" name="date" id="search-date" class="w-full bg-transparent border-0 text-[13px] font-bold text-[#2a2a2a] p-0 mt-0.5 focus:ring-0 focus:outline-none cursor-pointer" style="color-scheme: light;">
                            </div>
                        </div>

                        <!-- Search Button -->
                        <div class="px-1 shrink-0">
                            <button type="submit" class="w-full sm:w-auto px-6 h-12 bg-[#1d4ed8] hover:bg-[#1e40af] text-white rounded-[16px] font-bold text-[13px] tracking-wide transition-all shadow-md flex items-center justify-center gap-2 group hover:scale-[1.02]">
                                <span class="material-symbols-outlined text-[18px] transition-transform group-hover:scale-110">search</span>
                                <span>Tìm kiếm</span>
                            </button>
                        </div>
                    </form>

                    <div class="flex flex-wrap gap-5 mt-4">
                        <c:choose>
                            <c:when test="${user != null}">
                                <a href="${pageContext.request.contextPath}/customer/dat-san" class="h-[68px] px-12 bg-[#2a2a2a] text-white rounded-[18px] flex items-center justify-center gap-4 group transition-all hover:bg-[#1a1a1a] hover:scale-[1.02] shadow-lg shadow-[#2a2a2a]/10">
                                    <span class="text-[14px] font-bold uppercase tracking-[0.2em]">Đặt sân ngay</span>
                                    <span class="material-symbols-outlined text-[24px] transition-transform group-hover:translate-x-1">arrow_right_alt</span>
                                </a>
                            </c:when>
                            <c:otherwise>
                                <a href="${pageContext.request.contextPath}/dangnhap" class="h-[68px] px-12 bg-[#2a2a2a] text-white rounded-[18px] flex items-center justify-center gap-4 group transition-all hover:bg-[#1a1a1a] hover:scale-[1.02] shadow-lg shadow-[#2a2a2a]/10">
                                    <span class="text-[14px] font-bold uppercase tracking-[0.2em]">Đặt sân ngay</span>
                                    <span class="material-symbols-outlined text-[24px] transition-transform group-hover:translate-x-1">arrow_right_alt</span>
                                </a>
                            </c:otherwise>
                        </c:choose>
                        <a href="#" class="h-[68px] px-12 border border-[#2a2a2a]/10 bg-white text-[#2a2a2a] rounded-[18px] flex items-center justify-center text-[14px] font-bold uppercase tracking-[0.2em] transition-all hover:bg-[#f4f4ef] hover:border-[#2a2a2a]/20">
                            Xem dịch vụ
                        </a>
                    </div>

                    <!-- Trusted By / Stats -->
                    <div class="flex items-center gap-6 mt-16 pt-10 border-t border-[#2a2a2a]/5 w-full">
                        <div class="flex -space-x-3">
                            <div class="w-11 h-11 rounded-full border-4 border-[#f4f4ef] bg-[#d1d5db] overflow-hidden">
                                <img src="https://i.pravatar.cc/100?u=1" alt="user" class="w-full h-full object-cover">
                            </div>
                            <div class="w-11 h-11 rounded-full border-4 border-[#f4f4ef] bg-[#9ca3af] overflow-hidden">
                                <img src="https://i.pravatar.cc/100?u=2" alt="user" class="w-full h-full object-cover">
                            </div>
                            <div class="w-11 h-11 rounded-full border-4 border-[#f4f4ef] bg-[#2563eb] overflow-hidden">
                                <img src="https://i.pravatar.cc/100?u=3" alt="user" class="w-full h-full object-cover">
                            </div>
                        </div>
                        <span class="text-[12px] font-bold text-[#2a2a2a]/40 uppercase tracking-[0.2em]">Được tin dùng bởi hơn 500 chủ sân bãi</span>
                    </div>
                </div>

                <!-- Right Content: Info Card & Detail Box -->
                <div class="lg:col-span-5 relative flex justify-end animate-fade-in-up" style="animation-delay: 0.3s">
                    <!-- Soft background element -->
                    <div class="absolute -right-20 top-1/2 -translate-y-1/2 w-[130%] h-[110%] bg-[#2563eb]/5 rounded-[120px] -rotate-6 z-0 pointer-events-none"></div>

                    <div class="relative z-10 w-full max-w-[500px] bg-white rounded-[40px] shadow-[0_40px_100px_-20px_rgba(42,42,42,0.08)] p-12 flex flex-col gap-12 border border-white">
                        <div>
                            <span class="text-[11px] font-bold text-[#2a2a2a]/30 uppercase tracking-[0.4em]">Tiêu chuẩn vàng</span>
                            <h3 class="text-[32px] font-serif leading-tight text-[#2a2a2a] mt-4">
                                Dịch vụ sân bãi mang lại sự an tâm, tin cậy<br/>
                                
                            </h3>
                        </div>

                        <div class="flex flex-col gap-10">
                            <div class="flex gap-6">
                                <div class="w-12 h-12 shrink-0 rounded-[16px] bg-[#f4f4ef] flex items-center justify-center text-[#2563eb]">
                                    <span class="material-symbols-outlined text-[24px]">verified_user</span>
                                </div>
                                <div class="flex flex-col gap-1.5 pt-1">
                                    <span class="text-[15px] font-bold text-[#2a2a2a]">Đội ngũ chuyên nghiệp</span>
                                    <p class="text-[14px] text-[#2a2a2a]/50 leading-relaxed font-light">Nhân sự được đào tạo bài bản cho các cơ sở thể thao cao cấp và duy trì chất lượng sân cỏ đồng nhất.</p>
                                </div>
                            </div>

                            <div class="flex gap-6">
                                <div class="w-12 h-12 shrink-0 rounded-[16px] bg-[#f4f4ef] flex items-center justify-center text-[#2563eb]">
                                    <span class="material-symbols-outlined text-[24px]">calendar_today</span>
                                </div>
                                <div class="flex flex-col gap-1.5 pt-1">
                                    <span class="text-[15px] font-bold text-[#2a2a2a]">Lịch trình bảo trì linh hoạt</span>
                                    <p class="text-[14px] text-[#2a2a2a]/50 leading-relaxed font-light">Kế hoạch bảo trì hàng ngày, hàng tuần hoặc theo yêu cầu, phù hợp với nhịp độ vận hành thực tế của bạn.</p>
                                </div>
                            </div>

                            <div class="flex gap-6">
                                <div class="w-12 h-12 shrink-0 rounded-[16px] bg-[#f4f4ef] flex items-center justify-center text-[#2563eb]">
                                    <span class="material-symbols-outlined text-[24px]">eco</span>
                                </div>
                                <div class="flex flex-col gap-1.5 pt-1">
                                    <span class="text-[15px] font-bold text-[#2a2a2a]">Giải pháp bền vững hiện đại</span>
                                    <p class="text-[14px] text-[#2a2a2a]/50 leading-relaxed font-light">Sử dụng vật liệu an toàn và quy trình chăm sóc cao cấp cho mặt sân cỏ nhân tạo và người chơi.</p>
                                </div>
                            </div>
                        </div>

                        <div class="pt-10 border-t border-[#2a2a2a]/5 flex items-center justify-between">
                            <span class="text-[11px] font-bold text-[#2a2a2a]/30 uppercase tracking-[0.2em]">Tỉ mỉ • Thiết kế ưu việt</span>
                            <a href="#" class="flex items-center gap-2 group">
                                <span class="text-[12px] font-bold uppercase tracking-[0.2em] text-[#2a2a2a]">Tìm hiểu thêm</span>
                                <span class="material-symbols-outlined text-[18px] transition-transform group-hover:translate-x-1 group-hover:-translate-y-1 -rotate-45">arrow_forward</span>
                            </a>
                        </div>
                    </div>
                </div>

            </div>
        </div>

        <!-- Service Layers Section -->
        <section class="max-w-[1400px] mx-auto py-32 border-t border-[#2a2a2a]/5 px-6">
            <div class="text-center mb-24 animate-fade-in-up">
                <h2 class="text-[56px] lg:text-[72px] font-serif leading-tight text-[#2a2a2a]">
                    Các lớp quản lý tối ưu cho <br/>
                    <i class="font-serif italic text-[#2563eb]">mọi nhịp độ sân đấu.</i>
                </h2>
                <p class="text-[16px] lg:text-[18px] text-[#2a2a2a]/50 max-w-[640px] mx-auto mt-8 font-light leading-relaxed">
                    Sáu tùy chọn quản lý được cấu trúc tỉ mỉ nhằm giữ cho cơ sở của bạn luôn ổn định, được bảo trì tốt và sẵn sàng cho mọi trận đấu mà không gặp bất kỳ trở ngại nào.
                </p>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
                <!-- Card 1 -->
                <div class="flex flex-col gap-8 animate-fade-in-up" style="animation-delay: 0.1s">
                    <div class="relative group overflow-hidden rounded-[24px] aspect-[4/3] bg-white border border-white p-2">
                        <img src="https://images.unsplash.com/photo-1551958219-acbc608c6377?q=80&w=2070&auto=format&fit=crop" alt="service" class="w-full h-full object-cover rounded-[18px] transition-transform duration-700 group-hover:scale-105">
                    </div>
                    <div class="flex flex-col gap-4">
                        <div class="flex flex-col gap-1">
                            <h4 class="text-[20px] font-bold text-[#2a2a2a]">Bảo trì định kỳ</h4>
                            <span class="text-[10px] font-bold text-[#2a2a2a]/30 uppercase tracking-[0.2em]">Hàng tuần / Hai tuần / Hàng tháng</span>
                        </div>
                        <p class="text-[14px] text-[#2a2a2a]/50 leading-relaxed font-light">
                            Duy trì sự chuyên nghiệp lâu dài cho sân đấu với nhịp độ bảo dưỡng ổn định và điều kiện thi đấu đạt chuẩn elite.
                        </p>
                    </div>
                </div>

                <!-- Card 2 -->
                <div class="flex flex-col gap-8 animate-fade-in-up" style="animation-delay: 0.2s">
                    <div class="relative group overflow-hidden rounded-[24px] aspect-[4/3] bg-white border border-white p-2">
                        <img src="https://images.unsplash.com/photo-1526232761682-d26e03ac148e?q=80&w=2029&auto=format&fit=crop" alt="service" class="w-full h-full object-cover rounded-[18px] transition-transform duration-700 group-hover:scale-105">
                    </div>
                    <div class="flex flex-col gap-4">
                        <div class="flex flex-col gap-1">
                            <h4 class="text-[20px] font-bold text-[#2a2a2a]">Chuẩn bị trận đấu</h4>
                            <span class="text-[10px] font-bold text-[#2a2a2a]/30 uppercase tracking-[0.2em]">Sắp xếp / Chuẩn bị / Phục hồi</span>
                        </div>
                        <p class="text-[14px] text-[#2a2a2a]/50 leading-relaxed font-light">
                            Dịch vụ bàn giao chính xác cho các trận đấu mới — đảm bảo mặt sân hoàn hảo, sạch sẽ và sẵn sàng ngay từ tiếng còi khai cuộc.
                        </p>
                    </div>
                </div>

                <!-- Card 3 -->
                <div class="flex flex-col gap-8 animate-fade-in-up" style="animation-delay: 0.3s">
                    <div class="relative group overflow-hidden rounded-[24px] aspect-[4/3] bg-white border border-white p-2">
                        <img src="https://images.unsplash.com/photo-1577223625816-7546f13df25d?q=80&w=1925&auto=format&fit=crop" alt="service" class="w-full h-full object-cover rounded-[18px] transition-transform duration-700 group-hover:scale-105">
                    </div>
                    <div class="flex flex-col gap-4">
                        <div class="flex flex-col gap-1">
                            <h4 class="text-[20px] font-bold text-[#2a2a2a]">Dịch vụ Hub cao cấp</h4>
                            <span class="text-[10px] font-bold text-[#2a2a2a]/30 uppercase tracking-[0.2em]">Sự kiện / Tập huấn / Trình diễn</span>
                        </div>
                        <p class="text-[14px] text-[#2a2a2a]/50 leading-relaxed font-light">
                            Thiết lập tập trung vào hình ảnh chuyên nghiệp cho các cơ sở cần sự chỉn chu, chào đón và sẵn sàng cho các sự kiện tầm cỡ.
                        </p>
                    </div>
                </div>
            </div>
        </section>
    </main>

    <!-- Footer Simple -->
    <footer class="py-12 px-6 border-t border-[#2a2a2a]/5 mt-20">
        <div class="max-w-[1400px] mx-auto flex flex-col md:flex-row justify-between items-center gap-8">
            <div class="flex flex-col md:flex-row items-center gap-4">
                <span class="text-[14px] font-bold text-[#2a2a2a] tracking-widest uppercase">Hệ thống V-Sport</span>
                <span class="hidden md:block w-[1px] h-4 bg-[#2a2a2a]/10"></span>
                <span class="text-[11px] font-medium text-[#2a2a2a]/40 uppercase tracking-widest">&copy; 2026 Elite Management Hub. Bản quyền được bảo lưu.</span>
            </div>
            <div class="flex gap-8 text-[11px] font-bold uppercase tracking-widest text-[#2a2a2a]/40">
                <a href="#" class="hover:text-[#2a2a2a] transition-colors">Chính sách bảo mật</a>
                <a href="#" class="hover:text-[#2a2a2a] transition-colors">Điều khoản dịch vụ</a>
            </div>
        </div>
    </footer>

    <script>
        const dateInput = document.getElementById('search-date');
        if (dateInput) {
            const todayStr = new Date().toISOString().split('T')[0];
            dateInput.min = todayStr;
            dateInput.value = todayStr;
        }
    </script>
</body>
</html>

