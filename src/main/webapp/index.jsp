<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%
    org.example.model.TaiKhoan loggedInUser = (org.example.model.TaiKhoan) session.getAttribute("user");
    if (loggedInUser != null) {
        if (loggedInUser.getRoleId() == 1) {
            response.sendRedirect(request.getContextPath() + "/admin/nhan-su");
            return;
        } else if (loggedInUser.getRoleId() == 2) {
            response.sendRedirect(request.getContextPath() + "/manager/nhan-su");
            return;
        } else if (loggedInUser.getRoleId() == 4 || loggedInUser.getRoleId() == 5) {
            response.sendRedirect(request.getContextPath() + "/staff/dashboard");
            return;
        }
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>V-Sport - Nền tảng đặt sân thể thao số 1</title>
    
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            corePlugins: {
               preflight: false,
            },
            theme: {
                extend: {
                    fontFamily: {
                        sans: ['"Be Vietnam Pro"', 'sans-serif'],
                    },
                    colors: {
                        brand: {
                            50: '#ecfdf5',
                            100: '#d1fae5',
                            500: '#10b981',
                            600: '#059669',
                            700: '#047857',
                        }
                    }
                }
            }
        }
    </script>
    
    <style>
        /* Base styles */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Be Vietnam Pro', sans-serif;
        }

        :root {
            --primary: #10b981; 
            --primary-dark: #059669;
            --primary-light: #ecfdf5;
            --text-dark: #0f172a;
            --text-muted: #64748b;
            --bg-light: #f8fafc;
            --white: #ffffff;
            --transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        body {
            background-color: var(--bg-light);
            color: var(--text-dark);
            line-height: 1.6;
            overflow-x: hidden;
        }

        .highlight { color: var(--primary); }
        .subtitle {
            font-size: 0.85rem;
            font-weight: 800;
            letter-spacing: 2px;
            color: var(--primary-dark);
            text-transform: uppercase;
            margin-bottom: 12px;
            display: inline-block;
        }

        /* Ticker Marquee Style */
        .ticker-wrap {
            width: 100%;
            overflow: hidden;
            background: #ffffff;
            border-bottom: 1px solid #e2e8f0;
            padding: 10px 0;
        }
        .ticker {
            display: inline-block;
            white-space: nowrap;
            padding-right: 100%;
            animation: marquee 25s linear infinite;
        }
        .ticker-item {
            display: inline-block;
            padding: 0 2rem;
            font-size: 0.9rem;
            color: #475569;
            font-weight: 500;
        }
        @keyframes marquee {
            0% { transform: translate3d(0, 0, 0); }
            100% { transform: translate3d(-100%, 0, 0); }
        }

        /* Glassmorphism Classes */
        .glass-card {
            background: rgba(255, 255, 255, 0.85);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            border: 1px solid rgba(255, 255, 255, 0.5);
        }

        /* Micro-Animations */
        .hover-lift {
            transition: var(--transition);
        }
        .hover-lift:hover {
            transform: translateY(-5px);
            box-shadow: 0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1);
        }

        .pulse-green {
            animation: pulse-green 2s infinite;
        }
        @keyframes pulse-green {
            0% { box-shadow: 0 0 0 0 rgba(16, 185, 129, 0.4); }
            70% { box-shadow: 0 0 0 10px rgba(16, 185, 129, 0); }
            100% { box-shadow: 0 0 0 0 rgba(16, 185, 129, 0); }
        }

        /* Scroll reveals default */
        .reveal {
            opacity: 0;
            transform: translateY(30px);
            transition: opacity 0.8s ease, transform 0.8s cubic-bezier(0.2, 0.8, 0.2, 1);
        }
        .reveal.active {
            opacity: 1;
            transform: translateY(0);
        }

        /* Tab panels transitions */
        .tab-panel {
            display: none;
        }
        .tab-panel.active {
            display: grid;
            animation: slideUp 0.5s cubic-bezier(0.16, 1, 0.3, 1) forwards;
        }
        @keyframes slideUp {
            from { opacity: 0; transform: translateY(15px); }
            to { opacity: 1; transform: translateY(0); }
        }
    </style>
</head>
<body>

    <!-- Header / Navigation is loaded from header.jsp -->
    <jsp:include page="/common/header.jsp" />

    <!-- Live activity ticker -->
    <div class="ticker-wrap">
        <div class="ticker" id="live-ticker">
            <span class="ticker-item">🔥 <span class="font-bold text-[#10b981]">Anh Hùng</span> vừa đặt Sân 7 Mỹ Đình (2 phút trước)</span>
            <span class="ticker-item">🤝 <span class="font-bold text-[#10b981]">FC Cơn Lốc</span> vừa ghép kèo cầu lông lúc 19:30 tối nay</span>
            <span class="ticker-item">⚡ <span class="font-bold text-[#10b981]">Anh Minh</span> vừa hoàn tất thanh toán đặt sân cơ sở 2</span>
            <span class="ticker-item">🔥 <span class="font-bold text-[#10b981]">Chị Lan</span> vừa tham gia kèo đơn nam tennis sân A2</span>
        </div>
    </div>

    <!-- Hero Section -->
    <section class="max-w-7xl mx-auto px-6 py-12 md:py-20 flex flex-col md:flex-row items-center justify-between gap-12 reveal">
        <div class="flex-1 space-y-6 text-center md:text-left">
            <span class="bg-brand-50 text-brand-700 px-4 py-1.5 rounded-full text-xs font-bold uppercase tracking-wider">Đặt sân dễ dàng - Kết nối đam mê</span>
            <h1 class="text-4xl md:text-6xl font-extrabold tracking-tight text-slate-900 leading-none">
                Tìm Sân Đặt Lịch <br><span class="text-brand-500">Mọi Lúc Mọi Nơi</span>
            </h1>
            <p class="text-slate-500 text-base md:text-lg max-w-xl">
                Khám phá hệ thống sân cỏ nhân tạo, tennis, cầu lông tiêu chuẩn chất lượng cao. Ghép kèo nhanh chóng với hàng ngàn người chơi có cùng trình độ ngay tại khu vực của bạn!
            </p>
            <div class="flex flex-col sm:flex-row justify-center md:justify-start gap-4">
                <a href="${pageContext.request.contextPath}/customer/dat-san" class="px-8 py-3.5 rounded-full bg-brand-500 hover:bg-brand-600 text-white font-semibold transition-all shadow-lg hover:shadow-brand-500/20 text-center flex items-center justify-center gap-2 decoration-none"><span class="material-symbols-outlined text-[20px]">calendar_month</span> Đặt Sân Ngay</a>
                <a href="#quick-booking" class="px-8 py-3.5 rounded-full border border-slate-200 text-slate-700 hover:border-brand-500 hover:text-brand-600 font-semibold transition-all text-center flex items-center justify-center gap-2 decoration-none"><span class="material-symbols-outlined text-[20px]">explore</span> Khám Phá</a>
            </div>
        </div>
        
        <div class="flex-1 relative min-h-[420px] md:min-h-[480px] w-full flex items-center justify-center">
            <!-- Sports Photo Collage Grid -->
            <div class="relative w-full max-w-md md:max-w-lg h-[380px] md:h-[430px] mx-auto">
                <!-- Large Main Football Image -->
                <div class="absolute left-0 top-1/2 -translate-y-1/2 w-[62%] h-[85%] rounded-3xl overflow-hidden shadow-2xl border-4 border-white rotate-[-3deg] transition-all hover:rotate-0 duration-500 z-10">
                    <img src="https://images.unsplash.com/photo-1508098682722-e99c43a406b2?auto=format&fit=crop&w=500&q=80" alt="Football" class="w-full h-full object-cover">
                </div>
                <!-- Overlapping Top Right Tennis Image -->
                <div class="absolute right-0 top-2 w-[48%] h-[48%] rounded-3xl overflow-hidden shadow-xl border-4 border-white rotate-[3deg] transition-all hover:rotate-0 duration-500 z-20">
                    <img src="https://images.unsplash.com/photo-1622279457486-62dcc4a45e5e?auto=format&fit=crop&w=400&q=80" alt="Tennis" class="w-full h-full object-cover">
                </div>
                <!-- Overlapping Bottom Right Badminton Image -->
                <div class="absolute right-3 bottom-2 w-[45%] h-[42%] rounded-3xl overflow-hidden shadow-xl border-4 border-white rotate-[-4deg] transition-all hover:rotate-0 duration-500 z-20">
                    <img src="https://images.unsplash.com/photo-1613918431208-67520e55734e?auto=format&fit=crop&w=400&q=80" alt="Badminton" class="w-full h-full object-cover">
                </div>

                <!-- Floating interactive activity cards -->
                <div class="absolute top-[20%] left-[-20px] bg-white/95 border border-slate-100 p-2.5 rounded-2xl shadow-xl flex items-center gap-2.5 z-30 animate-[bounce_4s_infinite]">
                    <div class="w-8 h-8 rounded-full bg-[#ecfdf5] flex items-center justify-center text-emerald-600"><span class="material-symbols-outlined text-[18px]">sports_soccer</span></div>
                    <div>
                        <p class="text-[11px] font-bold text-slate-800">Đặt sân thành công!</p>
                        <p class="text-[9px] text-slate-400">Sân 7 - Cơ sở 1</p>
                    </div>
                </div>
                
                <div class="absolute bottom-[20%] right-[-15px] bg-white/95 border border-slate-100 p-2.5 rounded-2xl shadow-xl flex items-center gap-2.5 z-30 animate-[bounce_5s_infinite]">
                    <div class="w-8 h-8 rounded-full bg-indigo-50 flex items-center justify-center text-indigo-600"><span class="material-symbols-outlined text-[18px]">handshake</span></div>
                    <div>
                        <p class="text-[11px] font-bold text-slate-800">Đã ghép 12 kèo mới</p>
                        <p class="text-[9px] text-slate-400">Trình độ: Trung bình</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Stats Section (Dynamic counter elements) -->
    <section class="bg-white border-y border-slate-200 py-10 md:py-14 reveal">
        <div class="max-w-7xl mx-auto px-6 grid grid-cols-2 md:grid-cols-4 gap-8 text-center">
            <div class="space-y-1">
                <h3 class="text-3xl md:text-5xl font-extrabold text-slate-900 flex items-center justify-center">
                    <span id="counter-online">0</span>
                    <span class="text-xs text-brand-500 font-bold bg-brand-50 px-1.5 py-0.5 rounded ml-1 animate-pulse">LIVE</span>
                </h3>
                <p class="text-xs md:text-sm text-slate-400 font-medium uppercase tracking-wider">Người chơi trực tuyến</p>
            </div>
            <div class="space-y-1">
                <h3 class="text-3xl md:text-5xl font-extrabold text-slate-900" id="counter-pitches">0</h3>
                <p class="text-xs md:text-sm text-slate-400 font-medium uppercase tracking-wider">Sân đấu trống hôm nay</p>
            </div>
            <div class="space-y-1">
                <h3 class="text-3xl md:text-5xl font-extrabold text-slate-900" id="counter-matches">0</h3>
                <p class="text-xs md:text-sm text-slate-400 font-medium uppercase tracking-wider">Lượt ghép kèo thành công</p>
            </div>
            <div class="space-y-1">
                <h3 class="text-3xl md:text-5xl font-extrabold text-slate-900" id="counter-members">0</h3>
                <p class="text-xs md:text-sm text-slate-400 font-medium uppercase tracking-wider">Thành viên tích cực</p>
            </div>
        </div>
    </section>

    <!-- Quick Booking Stepper Section -->
    <section id="quick-booking" class="max-w-7xl mx-auto px-6 py-16 reveal">
        <div class="text-center max-w-xl mx-auto mb-10">
            <span class="subtitle">Tìm Kiếm Siêu Tốc</span>
            <h2 class="text-3xl md:text-4xl font-extrabold text-slate-900">Đặt Sân Nhập Cuộc Chỉ 3 Bước</h2>
        </div>

        <!-- Simulated Stepper Input Bar -->
        <div class="glass-card shadow-xl rounded-3xl p-6 border border-slate-100 max-w-4xl mx-auto">
            <div class="grid grid-cols-1 md:grid-cols-4 gap-4 items-center">
                <!-- Step 1: Chọn môn -->
                <div class="space-y-1">
                    <label class="text-xs font-bold text-slate-500 uppercase tracking-wider block">1. Chọn Môn Thể Thao</label>
                    <select id="quick-sport" class="w-full bg-slate-50 border border-slate-200 rounded-xl px-3 py-2 text-slate-700 text-sm font-semibold outline-none focus:border-brand-500 transition-all">
                        <option value="soccer">⚽ Bóng Đá</option>
                        <option value="tennis">🎾 Tennis</option>
                        <option value="badminton">🏸 Cầu Lông</option>
                    </select>
                </div>
                <!-- Step 2: Chọn khu vực -->
                <div class="space-y-1">
                    <label class="text-xs font-bold text-slate-500 uppercase tracking-wider block">2. Chọn Khu Vực</label>
                    <select id="quick-branch" class="w-full bg-slate-50 border border-slate-200 rounded-xl px-3 py-2 text-slate-700 text-sm font-semibold outline-none focus:border-brand-500 transition-all">
                        <option value="all">Tất cả Cơ sở</option>
                        <option value="cs1">V-Sport Cơ sở 1 - Cầu Giấy</option>
                        <option value="cs2">V-Sport Cơ sở 2 - Mỹ Đình</option>
                        <option value="cs3">V-Sport Cơ sở 3 - Đống Đa</option>
                    </select>
                </div>
                <!-- Step 3: Chọn ngày -->
                <div class="space-y-1">
                    <label class="text-xs font-bold text-slate-500 uppercase tracking-wider block">3. Chọn Ngày</label>
                    <input type="date" id="quick-date" class="w-full bg-slate-50 border border-slate-200 rounded-xl px-3 py-2 text-slate-700 text-sm font-semibold outline-none focus:border-brand-500 transition-all">
                </div>
                <!-- Action Button -->
                <div>
                    <button onclick="simulateQuickSearch()" class="w-full md:mt-5 bg-brand-500 hover:bg-brand-600 text-white font-bold py-2.5 px-4 rounded-xl transition-all shadow-md flex items-center justify-center gap-2 cursor-pointer border-none text-sm">
                        <span class="material-symbols-outlined text-[18px]">search</span> Tìm Sân Trống
                    </button>
                </div>
            </div>

            <!-- Simulated Spinner / Result Area -->
            <div id="simulation-loading" class="hidden flex-col items-center justify-center py-10">
                <div class="w-8 h-8 border-4 border-slate-200 border-t-brand-500 rounded-full animate-spin"></div>
                <p class="text-xs font-semibold text-slate-400 mt-2">Đang truy vấn dữ liệu thời gian thực...</p>
            </div>

            <div id="simulation-result" class="hidden mt-6 pt-6 border-t border-slate-100">
                <h4 class="text-sm font-bold text-slate-800 mb-4">Các sân trống khả dụng gần nhất tìm thấy:</h4>
                <div class="grid grid-cols-1 sm:grid-cols-2 gap-4" id="simulation-cards">
                    <!-- Cards will be populated dynamically -->
                </div>
            </div>
        </div>
    </section>



    <!-- Live Matchmaking Lobby Section -->
    <section class="max-w-7xl mx-auto px-6 py-16 reveal">
        <div class="flex flex-col md:flex-row justify-between items-center gap-6 mb-12">
            <div class="text-center md:text-left">
                <span class="subtitle">Ghép Kèo Trực Tiếp</span>
                <h2 class="text-3xl md:text-4xl font-extrabold text-slate-900">Kèo Đang Chờ Tìm Đối Thủ</h2>
            </div>
            <a href="#" class="px-6 py-2.5 rounded-full border border-slate-200 text-slate-700 hover:border-brand-500 hover:text-brand-600 font-semibold transition-all text-sm decoration-none">Xem Tất Cả Kèo Đấu</a>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
            <!-- Card Kèo 1 -->
            <div class="bg-white rounded-3xl p-6 border border-slate-200/70 shadow-sm relative overflow-hidden flex flex-col justify-between min-h-[250px]">
                <div class="absolute top-0 right-0 w-24 h-24 bg-[#ecfdf5] rounded-bl-[100px] flex items-start justify-end p-4 text-emerald-600">
                    <span class="material-symbols-outlined text-[24px]">sports_soccer</span>
                </div>
                <div class="space-y-4">
                    <div class="flex items-center gap-3">
                        <div class="w-12 h-12 rounded-full bg-brand-50 text-brand-600 flex items-center justify-center font-bold text-base shadow">CN</div>
                        <div>
                            <h4 class="font-bold text-slate-800">FC Cơn Lốc Sân Cỏ</h4>
                            <p class="text-xs text-slate-400">Trình độ: Trung bình khá</p>
                        </div>
                    </div>
                    
                    <div class="space-y-1.5 text-xs text-slate-500 font-medium">
                        <p class="flex items-center gap-1.5"><span class="material-symbols-outlined text-[16px]">location_on</span>Sân Mỹ Đình 1 (Cơ sở 2)</p>
                        <p class="flex items-center gap-1.5"><span class="material-symbols-outlined text-[16px]">schedule</span>19:30 - Hôm nay (01/07)</p>
                    </div>

                    <!-- Progress joined players -->
                    <div class="space-y-1">
                        <div class="flex justify-between text-[11px] font-bold text-slate-600">
                            <span>Đã tham gia</span>
                            <span>10 / 14 cầu thủ</span>
                        </div>
                        <div class="w-full bg-slate-100 h-2 rounded-full overflow-hidden">
                            <div class="bg-brand-500 h-full rounded-full transition-all" style="width: 71%"></div>
                        </div>
                    </div>
                </div>

                <div class="mt-5 flex items-center justify-between">
                    <span class="text-xs text-brand-600 font-bold bg-brand-50 px-2.5 py-1 rounded-lg">Cần đối cứng</span>
                    <button onclick="simulateJoinMatch(this)" class="px-5 py-2 text-xs font-bold rounded-full bg-brand-500 hover:bg-brand-600 text-white cursor-pointer border-none shadow shadow-brand-500/20 transition-all flex items-center gap-1">Tham gia <span class="material-symbols-outlined text-[14px]">chevron_right</span></button>
                </div>
            </div>

            <!-- Card Kèo 2 -->
            <div class="bg-white rounded-3xl p-6 border border-slate-200/70 shadow-sm relative overflow-hidden flex flex-col justify-between min-h-[250px]">
                <div class="absolute top-0 right-0 w-24 h-24 bg-indigo-50 rounded-bl-[100px] flex items-start justify-end p-4 text-indigo-650">
                    <span class="material-symbols-outlined text-[24px]">sports_tennis</span>
                </div>
                <div class="space-y-4">
                    <div class="flex items-center gap-3">
                        <div class="w-12 h-12 rounded-full bg-indigo-50 text-indigo-600 flex items-center justify-center font-bold text-base shadow">AT</div>
                        <div>
                            <h4 class="font-bold text-slate-800">Anh Tuấn (Đơn nam)</h4>
                            <p class="text-xs text-slate-400">Trình độ: Khá</p>
                        </div>
                    </div>
                    
                    <div class="space-y-1.5 text-xs text-slate-500 font-medium">
                        <p class="flex items-center gap-1.5"><span class="material-symbols-outlined text-[16px]">location_on</span>Sân Tennis 3 (Cơ sở 2)</p>
                        <p class="flex items-center gap-1.5"><span class="material-symbols-outlined text-[16px]">schedule</span>20:00 - Hôm nay (01/07)</p>
                    </div>

                    <div class="space-y-1">
                        <div class="flex justify-between text-[11px] font-bold text-slate-600">
                            <span>Đã tham gia</span>
                            <span>1 / 2 người chơi</span>
                        </div>
                        <div class="w-full bg-slate-100 h-2 rounded-full overflow-hidden">
                            <div class="bg-indigo-600 h-full rounded-full transition-all" style="width: 50%"></div>
                        </div>
                    </div>
                </div>

                <div class="mt-5 flex items-center justify-between">
                    <span class="text-xs text-indigo-600 font-bold bg-indigo-50 px-2.5 py-1 rounded-lg">Giao lưu vui vẻ</span>
                    <button onclick="simulateJoinMatch(this)" class="px-5 py-2 text-xs font-bold rounded-full bg-brand-500 hover:bg-brand-600 text-white cursor-pointer border-none shadow shadow-brand-500/20 transition-all flex items-center gap-1">Tham gia <span class="material-symbols-outlined text-[14px]">chevron_right</span></button>
                </div>
            </div>

            <!-- Card Kèo 3 -->
            <div class="bg-white rounded-3xl p-6 border border-slate-200/70 shadow-sm relative overflow-hidden flex flex-col justify-between min-h-[250px]">
                <div class="absolute top-0 right-0 w-24 h-24 bg-amber-50 rounded-bl-[100px] flex items-start justify-end p-4 text-amber-600">
                    <span class="material-symbols-outlined text-[24px]">sports_badminton</span>
                </div>
                <div class="space-y-4">
                    <div class="flex items-center gap-3">
                        <div class="w-12 h-12 rounded-full bg-amber-50 text-amber-600 flex items-center justify-center font-bold text-base shadow">NL</div>
                        <div>
                            <h4 class="font-bold text-slate-800">Nhóm Lễ Tân V-Sport</h4>
                            <p class="text-xs text-slate-400">Trình độ: Mới chơi / Yếu</p>
                        </div>
                    </div>
                    
                    <div class="space-y-1.5 text-xs text-slate-500 font-medium">
                        <p class="flex items-center gap-1.5"><span class="material-symbols-outlined text-[16px]">location_on</span>Sân Cầu Lông 1 & 2 (Cơ sở 3)</p>
                        <p class="flex items-center gap-1.5"><span class="material-symbols-outlined text-[16px]">schedule</span>18:00 - Ngày mai (02/07)</p>
                    </div>

                    <div class="space-y-1">
                        <div class="flex justify-between text-[11px] font-bold text-slate-600">
                            <span>Đã tham gia</span>
                            <span>6 / 8 người chơi</span>
                        </div>
                        <div class="w-full bg-slate-100 h-2 rounded-full overflow-hidden">
                            <div class="bg-amber-500 h-full rounded-full transition-all" style="width: 75%"></div>
                        </div>
                    </div>
                </div>

                <div class="mt-5 flex items-center justify-between">
                    <span class="text-xs text-amber-600 font-bold bg-amber-50 px-2.5 py-1 rounded-lg">Cần thêm 2 nữ</span>
                    <button onclick="simulateJoinMatch(this)" class="px-5 py-2 text-xs font-bold rounded-full bg-brand-500 hover:bg-brand-600 text-white cursor-pointer border-none shadow shadow-brand-500/20 transition-all flex items-center gap-1">Tham gia <span class="material-symbols-outlined text-[14px]">chevron_right</span></button>
                </div>
            </div>
        </div>
    </section>

    <!-- Weekly Active Leaderboard Section -->
    <section class="bg-slate-100 py-16 reveal">
        <div class="max-w-7xl mx-auto px-6 grid grid-cols-1 md:grid-cols-2 gap-12 items-center">
            <div class="space-y-6">
                <span class="subtitle">Bảng Vinh Danh</span>
                <h2 class="text-3xl md:text-4xl font-extrabold text-slate-900">Top Thành Viên Tích Cực Tuần Này</h2>
                <p class="text-slate-500">
                    Bảng xếp hạng cập nhật dựa trên tổng số giờ đặt sân, số lượng trận ghép kèo giao lưu thành công và điểm số đánh giá fair-play từ cộng đồng. Hãy tham gia thi đấu để nhận được các voucher giảm giá giờ thuê đặc quyền!
                </p>
                <a href="${pageContext.request.contextPath}/customer/dat-san" class="px-6 py-2.5 rounded-full bg-brand-500 hover:bg-brand-600 text-white font-bold text-sm transition-all inline-block decoration-none">Ra sân tích điểm ngay</a>
            </div>

            <!-- Leaderboard List -->
            <div class="bg-white rounded-3xl p-6 border border-slate-200 shadow-xl space-y-4">
                <!-- Rank 1 -->
                <div class="flex items-center justify-between p-3 rounded-2xl hover:bg-slate-50 transition-all">
                    <div class="flex items-center gap-4">
                        <span class="w-8 h-8 rounded-full bg-amber-100 text-amber-700 flex items-center justify-center font-extrabold text-sm"><i class="fa-solid fa-trophy"></i></span>
                        <div class="w-10 h-10 rounded-full bg-emerald-50 text-emerald-600 flex items-center justify-center font-bold text-xs">CL</div>
                        <div>
                            <h4 class="text-sm font-bold text-slate-800">FC Cơn Lốc Sân Cỏ</h4>
                            <p class="text-[10px] text-slate-400">14 trận thắng - 980 pts</p>
                        </div>
                    </div>
                    <span class="text-xs font-bold text-brand-600 bg-brand-50 px-2 py-0.5 rounded">Top 1</span>
                </div>
                <!-- Rank 2 -->
                <div class="flex items-center justify-between p-3 rounded-2xl hover:bg-slate-50 transition-all">
                    <div class="flex items-center gap-4">
                        <span class="w-8 h-8 rounded-full bg-slate-100 text-slate-600 flex items-center justify-center font-extrabold text-sm">2</span>
                        <div class="w-10 h-10 rounded-full bg-indigo-50 text-indigo-600 flex items-center justify-center font-bold text-xs">TA</div>
                        <div>
                            <h4 class="text-sm font-bold text-slate-800">Tuấn Anh (Bắt gôn)</h4>
                            <p class="text-[10px] text-slate-400">12 trận thắng - 890 pts</p>
                        </div>
                    </div>
                    <span class="text-xs font-bold text-slate-400 bg-slate-100 px-2 py-0.5 rounded">Top 2</span>
                </div>
                <!-- Rank 3 -->
                <div class="flex items-center justify-between p-3 rounded-2xl hover:bg-slate-50 transition-all">
                    <div class="flex items-center gap-4">
                        <span class="w-8 h-8 rounded-full bg-amber-50 text-amber-600 flex items-center justify-center font-extrabold text-sm">3</span>
                        <div class="w-10 h-10 rounded-full bg-amber-50 text-amber-600 flex items-center justify-center font-bold text-xs">MH</div>
                        <div>
                            <h4 class="text-sm font-bold text-slate-800">Minh Hoàng</h4>
                            <p class="text-[10px] text-slate-400">11 trận thắng - 840 pts</p>
                        </div>
                    </div>
                    <span class="text-xs font-bold text-amber-600 bg-amber-50 px-2 py-0.5 rounded">Top 3</span>
                </div>
            </div>
        </div>
    </section>

    <!-- Pricing Section -->
    <section class="max-w-7xl mx-auto px-6 py-16 reveal">
        <div class="text-center max-w-xl mx-auto mb-12">
            <span class="subtitle">Bảng Giá Dịch Vụ</span>
            <h2 class="text-3xl md:text-4xl font-extrabold text-slate-900">Chi Phí Thuê Sân Tham Khảo</h2>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-8 max-w-6xl mx-auto">
            <!-- Box 1 -->
            <div class="bg-white rounded-3xl p-8 border border-slate-200 shadow-md text-center hover-lift flex flex-col justify-between">
                <div class="space-y-4">
                    <h3 class="text-xl font-bold text-slate-800">⚽ Sân Bóng Đá</h3>
                    <p class="text-slate-400 text-xs">Kích thước sân 7 tiêu chuẩn & cỏ nhân tạo chất lượng cao</p>
                    <div class="py-4 border-y border-slate-100">
                        <p class="text-xs text-slate-400 font-bold uppercase tracking-wider">Chỉ từ</p>
                        <h4 class="text-3xl font-extrabold text-brand-600">300,000đ<span class="text-xs text-slate-400 font-normal">/giờ</span></h4>
                    </div>
                    <ul class="text-left space-y-2.5 text-xs text-slate-500 font-medium py-4">
                        <li><i class="fa-solid fa-circle-check text-brand-500 mr-2"></i> Miễn phí 4 chai nước khoáng</li>
                        <li><i class="fa-solid fa-circle-check text-brand-500 mr-2"></i> Cho mượn bóng và áo pitch tập</li>
                        <li><i class="fa-solid fa-circle-check text-brand-500 mr-2"></i> Có vòi tắm nóng lạnh sau trận</li>
                    </ul>
                </div>
                <a href="${pageContext.request.contextPath}/customer/dat-san" class="w-full py-2.5 rounded-full bg-brand-500 hover:bg-brand-600 text-white font-bold text-xs mt-6 inline-block decoration-none">Đặt sân ngay</a>
            </div>

            <!-- Box 2 -->
            <div class="bg-white rounded-3xl p-8 border-2 border-brand-500 shadow-xl text-center hover-lift relative flex flex-col justify-between">
                <span class="absolute -top-3 left-1/2 -translate-x-1/2 bg-brand-500 text-white text-[10px] font-bold px-3 py-1 rounded-full uppercase tracking-wider">Phổ biến</span>
                <div class="space-y-4">
                    <h3 class="text-xl font-bold text-slate-800">🏸 Sân Cầu Lông</h3>
                    <p class="text-slate-400 text-xs">Thảm thi đấu chính hãng, ánh sáng chống chói mắt VĐV</p>
                    <div class="py-4 border-y border-slate-100">
                        <p class="text-xs text-slate-400 font-bold uppercase tracking-wider">Chỉ từ</p>
                        <h4 class="text-3xl font-extrabold text-brand-600">80,000đ<span class="text-xs text-slate-400 font-normal">/giờ</span></h4>
                    </div>
                    <ul class="text-left space-y-2.5 text-xs text-slate-500 font-medium py-4">
                        <li><i class="fa-solid fa-circle-check text-brand-500 mr-2"></i> Đầy đủ hệ thống quạt mát</li>
                        <li><i class="fa-solid fa-circle-check text-brand-500 mr-2"></i> Cho thuê vợt & mua quả cầu lông</li>
                        <li><i class="fa-solid fa-circle-check text-brand-500 mr-2"></i> Tắm giặt, thay đồ miễn phí</li>
                    </ul>
                </div>
                <a href="${pageContext.request.contextPath}/customer/dat-san" class="w-full py-2.5 rounded-full bg-brand-500 hover:bg-brand-600 text-white font-bold text-xs mt-6 inline-block decoration-none">Đặt sân ngay</a>
            </div>

            <!-- Box 3 -->
            <div class="bg-white rounded-3xl p-8 border border-slate-200 shadow-md text-center hover-lift flex flex-col justify-between">
                <div class="space-y-4">
                    <h3 class="text-xl font-bold text-slate-800">🎾 Sân Tennis</h3>
                    <p class="text-slate-400 text-xs">Bề mặt sân acrylic tiêu chuẩn, có hệ thống đèn cao áp tối</p>
                    <div class="py-4 border-y border-slate-100">
                        <p class="text-xs text-slate-400 font-bold uppercase tracking-wider">Chỉ từ</p>
                        <h4 class="text-3xl font-extrabold text-brand-600">200,000đ<span class="text-xs text-slate-400 font-normal">/giờ</span></h4>
                    </div>
                    <ul class="text-left space-y-2.5 text-xs text-slate-500 font-medium py-4">
                        <li><i class="fa-solid fa-circle-check text-brand-500 mr-2"></i> Trà đá mát lạnh miễn phí</li>
                        <li><i class="fa-solid fa-circle-check text-brand-500 mr-2"></i> Nhặt bóng phục vụ nhiệt tình</li>
                        <li><i class="fa-solid fa-circle-check text-brand-500 mr-2"></i> Chỗ đỗ xe ô tô miễn phí rộng rãi</li>
                    </ul>
                </div>
                <a href="${pageContext.request.contextPath}/customer/dat-san" class="w-full py-2.5 rounded-full bg-brand-500 hover:bg-brand-600 text-white font-bold text-xs mt-6 inline-block decoration-none">Đặt sân ngay</a>
            </div>
        </div>
    </section>

    <!-- App CTA Section -->
    <section class="max-w-7xl mx-auto px-6 py-10 reveal">
        <div class="bg-gradient-to-r from-brand-600 to-emerald-800 rounded-[2.5rem] p-8 md:p-14 text-center text-white space-y-6 relative overflow-hidden shadow-2xl">
            <div class="absolute -top-10 -right-10 w-44 h-44 bg-white/5 rounded-full blur-3xl"></div>
            <h2 class="text-2xl md:text-4xl font-extrabold">Bạn Đã Sẵn Sàng Nhập Cuộc Chưa?</h2>
            <p class="text-emerald-100 text-xs md:text-sm max-w-xl mx-auto">
                Tải ngay ứng dụng V-SPORT trên điện thoại để nhận voucher ưu đãi giảm 20% cho lượt đặt sân đầu tiên của bạn. Ghép kèo, tìm bạn bè thuận tiện hơn bao giờ hết!
            </p>
            <div class="flex flex-wrap justify-center gap-4 pt-2">
                <a href="#" class="flex items-center gap-2 bg-slate-900 hover:bg-black text-white px-6 py-2.5 rounded-xl transition-all text-xs font-bold decoration-none"><i class="fa-brands fa-google-play text-base"></i> Google Play</a>
                <a href="#" class="flex items-center gap-2 bg-slate-900 hover:bg-black text-white px-6 py-2.5 rounded-xl transition-all text-xs font-bold decoration-none"><i class="fa-brands fa-apple text-base"></i> App Store</a>
            </div>
        </div>
    </section>

    <script>
        // Hiệu ứng Reveal các phần tử khi scroll tới
        const reveals = document.querySelectorAll(".reveal");
        const revealOnScroll = () => {
            const windowHeight = window.innerHeight;
            const elementVisible = 120;
            reveals.forEach(reveal => {
                const elementTop = reveal.getBoundingClientRect().top;
                if (elementTop < windowHeight - elementVisible) {
                    reveal.classList.add("active");
                }
            });
        };
        window.addEventListener("scroll", revealOnScroll);
        revealOnScroll();

        // --- Simulated stats counters animation ---
        const counts = {
            online: 3422,
            pitches: 58,
            matches: 8932,
            members: 12500
        };

        function animateCounters() {
            const duration = 1500;
            const steps = 60;
            const stepTime = duration / steps;
            let currentStep = 0;

            const interval = setInterval(() => {
                currentStep++;
                const progress = currentStep / steps;
                
                document.getElementById('counter-online').innerText = Math.floor(counts.online * progress);
                document.getElementById('counter-pitches').innerText = Math.floor(counts.pitches * progress);
                document.getElementById('counter-matches').innerText = Math.floor(counts.matches * progress);
                document.getElementById('counter-members').innerText = Math.floor(counts.members * progress) + "+";

                if (currentStep >= steps) {
                    clearInterval(interval);
                    // Start live jittering for online players to simulate active users
                    startLiveJitter();
                }
            }, stepTime);
        }

        function startLiveJitter() {
            setInterval(() => {
                // Online players random jitter
                const jitterOnline = Math.floor(Math.random() * 9) - 4; // -4 to +4
                counts.online += jitterOnline;
                document.getElementById('counter-online').innerText = counts.online;

                // Empty pitches random jitter
                if (Math.random() > 0.7) {
                    const jitterPitches = Math.random() > 0.5 ? 1 : -1;
                    counts.pitches = Math.max(10, counts.pitches + jitterPitches);
                    document.getElementById('counter-pitches').innerText = counts.pitches;
                }
            }, 3000);
        }

        // Trigger stats animation when stats section is scrolled into view
        let animated = false;
        window.addEventListener('scroll', () => {
            const statsSection = document.getElementById('counter-online');
            if (!statsSection) return;
            const rect = statsSection.getBoundingClientRect();
            if (rect.top < window.innerHeight && !animated) {
                animateCounters();
                animated = true;
            }
        });
        // Run fallback in case it's already in viewport
        setTimeout(() => {
            if (!animated) {
                animateCounters();
                animated = true;
            }
        }, 500);

        // --- Live Ticker simulation ---
        const names = ["Anh Nam", "FC Bão Táp", "Anh Hoàng", "VĐV Roger Sơn", "Nhóm Lễ Tân", "Anh Hải", "FC Cơn Lốc"];
        const facilities = ["Sân 7 Mỹ Đình (CS2)", "Sân Cầu lông Cầu Giấy (CS1)", "Sân Tennis Đống Đa (CS3)", "Sân 5 Hoàn Kiếm (CS1)"];
        const actions = ["vừa đặt lịch thành công", "vừa tham gia ghép kèo", "vừa hoàn tất thanh toán"];

        setInterval(() => {
            const ticker = document.getElementById('live-ticker');
            if (!ticker) return;

            const name = names[Math.floor(Math.random() * names.length)];
            const facility = facilities[Math.floor(Math.random() * facilities.length)];
            const action = actions[Math.floor(Math.random() * actions.length)];
            
            const item = document.createElement('span');
            item.className = 'ticker-item';
            item.innerHTML = `🔥 <span class="font-bold text-[#10b981]">${name}</span> ${action} tại <span class="font-bold text-slate-700">${facility}</span> (vừa xong)`;
            
            ticker.appendChild(item);
            if (ticker.children.length > 8) {
                ticker.removeChild(ticker.children[0]);
            }
        }, 6000);



        // --- Quick Booking Stepper Simulation ---
        function simulateQuickSearch() {
            const loading = document.getElementById('simulation-loading');
            const result = document.getElementById('simulation-result');
            
            result.classList.add('hidden');
            loading.classList.remove('hidden');

            // Set dynamic Date to today if empty
            const dateInput = document.getElementById('quick-date');
            if (!dateInput.value) {
                const today = new Date().toISOString().split('T')[0];
                dateInput.value = today;
            }

            setTimeout(() => {
                loading.classList.add('hidden');
                
                const sport = document.getElementById('quick-sport').value;
                const cardsContainer = document.getElementById('simulation-cards');
                cardsContainer.innerHTML = '';

                let courtData = [];
                if (sport === 'soccer') {
                    courtData = [
                        { name: "Sân 7 Người A", branch: "Cơ sở 1 - Cầu Giấy", price: "300,000đ", image: "https://images.unsplash.com/photo-1579952363873-27f3bade9f55?auto=format&fit=crop&w=300&q=80" },
                        { name: "Sân 11 Người", branch: "Cơ sở 2 - Mỹ Đình", price: "800,000đ", image: "https://images.unsplash.com/photo-1529900748604-07564a03e7a6?auto=format&fit=crop&w=300&q=80" }
                    ];
                } else if (sport === 'tennis') {
                    courtData = [
                        { name: "Sân Tennis Khán Đài A", branch: "Cơ sở 2 - Mỹ Đình", price: "200,000đ", image: "https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0?auto=format&fit=crop&w=300&q=80" },
                        { name: "Sân Tennis Tiêu Chuẩn B", branch: "Cơ sở 2 - Mỹ Đình", price: "200,000đ", image: "https://images.unsplash.com/photo-1542144582-1ba00456b5e3?auto=format&fit=crop&w=300&q=80" }
                    ];
                } else {
                    courtData = [
                        { name: "Sân Cầu Lông Thảm Hải Yến", branch: "Cơ sở 3 - Đống Đa", price: "80,000đ", image: "https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?auto=format&fit=crop&w=300&q=80" }
                    ];
                }

                courtData.forEach(c => {
                    const card = document.createElement('div');
                    card.className = "flex items-center gap-4 bg-slate-50 p-4 rounded-2xl border border-slate-200/50 hover:bg-white transition-all hover:shadow-md";
                    card.innerHTML = `
                        <img src="${c.image}" alt="${c.name}" class="w-16 h-16 rounded-xl object-cover">
                        <div class="flex-1 min-w-0">
                            <h5 class="text-xs font-bold text-slate-800 truncate">${c.name}</h5>
                            <p class="text-[10px] text-slate-400 font-semibold truncate">${c.branch}</p>
                            <p class="text-xs font-extrabold text-brand-600 mt-1">${c.price}<span class="text-[10px] text-slate-400 font-normal">/h</span></p>
                        </div>
                        <a href="${pageContext.request.contextPath}/customer/dat-san" class="px-4 py-1.5 rounded-lg bg-brand-500 hover:bg-brand-600 text-white text-[10px] font-bold decoration-none shrink-0">Đặt sân</a>
                    `;
                    cardsContainer.appendChild(card);
                });

                result.classList.remove('hidden');
            }, 1200);
        }

        // --- Simulate Join Match ---
        function simulateJoinMatch(btn) {
            btn.disabled = true;
            btn.innerHTML = '<i class="fa-solid fa-spinner animate-spin"></i> Đang ghép...';
            
            setTimeout(() => {
                btn.innerHTML = '<i class="fa-solid fa-circle-check"></i> Đã ghép kèo';
                btn.className = "px-5 py-2 text-xs font-bold rounded-full bg-emerald-50 text-emerald-600 border border-emerald-200 transition-all pointer-events-none";
                alert("Chào mừng bạn! Bạn đã gửi yêu cầu tham gia kèo thành công. Vui lòng kiểm tra lịch sử đấu hoặc kết nối với đội trưởng.");
            }, 1000);
        }
    </script>
</body>
</html>