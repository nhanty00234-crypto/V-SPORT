<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%
    if (request.getAttribute("dsSan") == null) {
        response.sendRedirect(request.getContextPath() + "/customer/dat-san");
        return;
    }
%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi" class="scroll-smooth">
<head>
    <title>Tìm Sân - V-SPORT Elite Arena</title>
    <jsp:include page="/common/head.jsp" />
    <style>
        /* Cyber-grid background */
        .cyber-grid {
            background-size: 50px 50px;
            background-image:
                linear-gradient(to right, rgba(22,163,74,0.05) 1px, transparent 1px),
                linear-gradient(to bottom, rgba(22,163,74,0.05) 1px, transparent 1px);
        }
        /* Masonry layout */
        .masonry-grid { column-count: 1; column-gap: 1.5rem; }
        @media (min-width: 640px) { .masonry-grid { column-count: 2; } }
        @media (min-width: 1024px) { .masonry-grid { column-count: 3; } }
        @media (min-width: 1600px) { .masonry-grid { column-count: 4; } }
        .masonry-item { break-inside: avoid; margin-bottom: 1.5rem; }

        /* Glow text */
        .glow-text { text-shadow: 0 0 24px rgba(22,163,74,0.35); }

        /* Custom scrollbar */
        ::-webkit-scrollbar { width: 7px; }
        ::-webkit-scrollbar-track { background: #f9f9f9; }
        ::-webkit-scrollbar-thumb { background: #e2e8f0; border-radius: 4px; }
        ::-webkit-scrollbar-thumb:hover { background: #86efac; }

        /* Filter pill active */
        .sport-pill.active, .branch-pill.active {
            background-color: #16a34a !important;
            color: #fff !important;
            border-color: #16a34a !important;
        }

        /* Form inputs inside modals */
        .form-input {
            width: 100%; padding: 0.75rem 1rem;
            background-color: #f8fafc; border: 1px solid #e2e8f0;
            border-radius: 12px; color: #1e293b;
            transition: all 0.2s ease; font-size: 0.9375rem;
        }
        .form-input:focus {
            border-color: #16a34a; outline: none; background-color: #fff;
            box-shadow: 0 0 0 3px rgba(22,163,74,0.12);
        }
        .form-label {
            display: block; font-size: 0.75rem; font-weight: 700;
            text-transform: uppercase; letter-spacing: 0.05em;
            color: #64748b; margin-bottom: 0.5rem;
        }
        @keyframes shimmer { 100% { transform: translateX(100%); } }

        /* Floating animations for side icons */
        @keyframes float-slow {
            0%, 100% { transform: translateY(0) rotate(0deg); }
            50% { transform: translateY(-12px) rotate(8deg); }
        }
        @keyframes float-rev {
            0%, 100% { transform: translateY(0) rotate(0deg); }
            50% { transform: translateY(12px) rotate(-8deg); }
        }
        @keyframes pulse-soft {
            0%, 100% { box-shadow: 0 0 12px rgba(22, 163, 74, 0.15); }
            50% { box-shadow: 0 0 28px rgba(22, 163, 74, 0.4); }
        }
        @keyframes slide-up-fade {
            0% { opacity: 0; transform: translateY(12px); }
            100% { opacity: 1; transform: translateY(0); }
        }
        .animate-float { animation: float-slow 6s ease-in-out infinite; }
        .animate-float-rev { animation: float-rev 8s ease-in-out infinite; }
        .glow-pulse { animation: pulse-soft 3s ease-in-out infinite; }
        
        .feed-scroll::-webkit-scrollbar { width: 3px; }
        .feed-scroll::-webkit-scrollbar-thumb { background: rgba(22, 163, 74, 0.2); border-radius: 2px; }
    </style>
</head>
<body class="bg-[#f9f9f9] text-slate-900 min-h-screen flex flex-col antialiased overflow-x-hidden">

    <jsp:include page="/common/header.jsp" />

    <main class="flex-grow pt-[88px] pb-24">

        <!-- ── Hero ── -->
        <section class="relative w-full min-h-[420px] flex flex-col justify-center px-5 md:px-16 cyber-grid overflow-hidden">
            <!-- atmospheric blobs -->
            <div class="absolute top-0 right-0 w-[480px] h-[480px] bg-green-200/25 rounded-full blur-[110px] pointer-events-none -translate-y-1/2 translate-x-1/3"></div>
            <div class="absolute bottom-0 left-0 w-[380px] h-[380px] bg-slate-200/30 rounded-full blur-[90px] pointer-events-none translate-y-1/2 -translate-x-1/4"></div>

            <div class="relative z-10 max-w-[1800px] mx-auto w-full">
                <div class="flex flex-col items-start gap-2 md:pl-8">
                    <h1 class="text-[56px] sm:text-[80px] font-extrabold tracking-tighter leading-none -ml-1 text-slate-900/15 uppercase">Săn Tìm</h1>
                    <h2 class="text-[32px] sm:text-[48px] font-extrabold tracking-tight leading-tight glow-text uppercase md:ml-24">
                        Thánh Địa <br/><span class="text-green-600">Thể Thao</span>
                    </h2>
                    <p class="text-[11px] font-bold tracking-widest text-slate-500 uppercase mt-4 md:ml-24 bg-slate-100/60 border border-slate-200 backdrop-blur-md px-3 py-1.5 rounded-full flex items-center gap-1.5">
                        <span class="material-symbols-outlined text-[13px] align-middle text-green-600">radar</span>
                        Hệ thống quét sân trực tuyến
                    </p>
                    <c:if test="${sessionScope.user != null}">
                        <div class="md:ml-24 mt-2">
                            <button type="button" onclick="openHistoryModal()"
                                class="inline-flex items-center gap-2 px-5 py-3 rounded-xl bg-green-600 text-white font-bold text-xs shadow-md hover:bg-green-700 hover:-translate-y-0.5 transition-all active:scale-95">
                                <span class="material-symbols-outlined text-[18px]">history</span>
                                Lịch sử đặt sân của tôi
                            </button>
                        </div>
                    </c:if>
                </div>
            </div>
        </section>

        <!-- ── Command Bar ── -->
        <section class="relative z-20 max-w-[1800px] mx-auto px-5 md:px-16 -mt-10 mb-12">
            <div class="bg-white/75 backdrop-blur-2xl border border-white rounded-2xl p-6 shadow-[0_10px_40px_rgba(22,163,74,0.12)] relative overflow-hidden">
                <div class="absolute inset-0 bg-gradient-to-br from-white/40 to-transparent pointer-events-none rounded-2xl"></div>

                <!-- Alerts -->
                <c:if test="${not empty sessionScope.error}">
                    <div class="mb-5 p-3 bg-red-50 border border-red-100 rounded-xl text-red-600 text-sm flex items-start gap-3">
                        <span class="material-symbols-outlined text-[18px] shrink-0">error</span>
                        <span>${sessionScope.error}</span>
                        <% session.removeAttribute("error"); %>
                    </div>
                </c:if>
                <c:if test="${not empty sessionScope.message}">
                    <div class="mb-5 p-3 bg-green-50 border border-green-200 rounded-xl text-green-700 text-sm flex items-start gap-3">
                        <span class="material-symbols-outlined text-[18px] shrink-0">check_circle</span>
                        <span>${sessionScope.message}</span>
                        <% session.removeAttribute("message"); %>
                    </div>
                </c:if>

                <!-- Search Row -->
                <div class="relative z-10 flex flex-col md:flex-row gap-5 items-end mb-6">
                    <!-- Location -->
                    <div class="flex-1 w-full relative group">
                        <label class="block text-[11px] font-bold tracking-widest text-slate-400 uppercase mb-2 group-focus-within:text-green-600 transition-colors">Khu Vực</label>
                        <div class="flex items-center border-b-2 border-slate-200 hover:border-green-400 focus-within:border-green-600 pb-2 transition-colors">
                            <span class="material-symbols-outlined text-slate-400 mr-3 text-[20px]">my_location</span>
                            <input id="location-search-input" type="text" placeholder="Nhập tên đường, quận, cơ sở..."
                                class="w-full bg-transparent border-none focus:ring-0 text-slate-800 placeholder:text-slate-300 p-0 text-[15px] font-medium"/>
                        </div>
                    </div>
                    <!-- Date -->
                    <div class="w-full md:w-52 relative group">
                        <label class="block text-[11px] font-bold tracking-widest text-slate-400 uppercase mb-2 group-focus-within:text-green-600 transition-colors">Thời Gian</label>
                        <div class="flex items-center border-b-2 border-slate-200 hover:border-green-400 focus-within:border-green-600 pb-2 transition-colors">
                            <span class="material-symbols-outlined text-slate-400 mr-3 text-[20px]">calendar_today</span>
                            <input type="date" id="quick-date-input" class="w-full bg-transparent border-none focus:ring-0 text-slate-800 p-0 text-[15px] font-medium"/>
                        </div>
                    </div>
                    <!-- Scan button -->
                    <button type="button" id="btn-auto-locate"
                        class="w-full md:w-auto relative overflow-hidden bg-green-600 text-white font-bold text-[13px] px-8 py-3.5 rounded-xl flex items-center justify-center gap-2 hover:bg-green-700 transition-all active:scale-95 shadow-[0_4px_15px_rgba(22,163,74,0.3)] hover:shadow-[0_4px_25px_rgba(22,163,74,0.4)] group">
                        <span class="absolute inset-0 w-full h-full bg-gradient-to-r from-transparent via-white/20 to-transparent -translate-x-full group-hover:animate-[shimmer_1s_infinite]"></span>
                        <span id="locate-icon" class="material-symbols-outlined text-[20px]">radar</span>
                        <span id="locate-text">QUÉT</span>
                    </button>
                </div>

                <!-- Sport Quick Pills -->
                <div class="relative z-10 flex flex-wrap gap-2 pb-4 border-b border-slate-100">
                    <button type="button" onclick="filterSport(0)" id="btn-sport-0"
                        class="sport-pill active font-bold text-[11px] tracking-widest uppercase px-4 py-2 rounded-full border border-green-600 text-green-600 bg-green-50 transition-all">
                        Tất cả
                    </button>
                    <c:forEach var="mon" items="${dsMon}">
                        <button type="button" onclick="filterSport(${mon.monTheThaoID})" id="btn-sport-${mon.monTheThaoID}"
                            class="sport-pill font-bold text-[11px] tracking-widest uppercase px-4 py-2 rounded-full border border-slate-200 text-slate-500 bg-white/60 hover:border-green-400 hover:text-green-600 transition-all">
                            ${mon.tenMon}
                        </button>
                    </c:forEach>
                    <!-- Lọc thêm trigger -->
                    <button type="button" onclick="toggleBranchBar()"
                        class="ml-auto font-bold text-[11px] tracking-widest uppercase px-4 py-2 rounded-full border border-slate-200 text-slate-500 bg-white/60 hover:border-green-400 hover:text-green-600 transition-all flex items-center gap-1.5">
                        <span class="material-symbols-outlined text-[16px]">tune</span> Lọc Thêm
                    </button>
                </div>

                <!-- Branch Pills (collapsible) -->
                <div id="branch-bar" class="relative z-10 hidden flex-wrap gap-2 pt-4">
                    <button type="button" onclick="filterBranch(0)" id="btn-branch-0"
                        class="branch-pill active font-bold text-[11px] tracking-widest uppercase px-4 py-2 rounded-full border border-green-600 text-green-600 bg-green-50 transition-all flex items-center gap-1.5">
                        <span class="material-symbols-outlined text-[14px]">map</span> Tất cả Cơ Sở
                    </button>
                    <c:forEach var="cs" items="${dsCoSo}">
                        <button type="button" onclick="filterBranch(${cs.coSoID})" id="btn-branch-${cs.coSoID}"
                            class="branch-pill font-bold text-[11px] tracking-widest uppercase px-4 py-2 rounded-full border border-slate-200 text-slate-500 bg-white/60 hover:border-green-400 hover:text-green-600 transition-all flex items-center gap-1.5">
                            <span class="material-symbols-outlined text-[14px]">location_on</span>
                            ${cs.tenCoSo}
                        </button>
                    </c:forEach>
                </div>
            </div>
        </section>

        <!-- ── Court Grid & Sidebar ── -->
        <section class="max-w-[1800px] mx-auto px-5 md:px-16">
            <div class="grid grid-cols-1 xl:grid-cols-4 gap-8">
                
                <!-- Left Main: Court List (3/4 width) -->
                <div class="xl:col-span-3">
                    <div class="flex justify-between items-end mb-8">
                        <h3 class="text-[20px] font-extrabold text-slate-800 uppercase tracking-wider">
                            Hệ Sinh Thái <span class="text-green-600">Đang Hoạt Động</span>
                        </h3>
                        <span class="text-[11px] font-bold tracking-widest text-slate-400 uppercase">
                            <strong id="court-count" class="text-slate-700">0</strong> Kết quả
                            <span id="court-status-summary" class="ml-2"></span>
                        </span>
                    </div>

                    <div id="courts-container" class="masonry-grid">
                        <!-- Rendered by JS -->
                    </div>

                    <div class="w-full flex justify-center mt-12">
                        <button class="font-bold text-[11px] tracking-widest uppercase border-2 border-slate-200 text-slate-500 px-8 py-3 rounded-full hover:border-green-500 hover:text-green-600 transition-colors flex items-center gap-2 group bg-white/60 backdrop-blur-sm shadow-sm hover:shadow-md">
                            TẢI THÊM <span class="material-symbols-outlined group-hover:translate-y-1 transition-transform">expand_more</span>
                        </button>
                    </div>
                </div>

                <!-- Right Sidebar: Live activity & Ambassador Reviews (1/4 width) -->
                <div class="hidden xl:flex flex-col gap-6 xl:col-span-1">
                    <!-- Live Activity Feed -->
                    <div class="bg-white/75 backdrop-blur-md border border-white/80 rounded-2xl p-5 shadow-[0_10px_30px_rgba(22,163,74,0.05)] sticky top-[108px] transition-all">
                        <div class="flex items-center justify-between mb-4 border-b border-slate-100 pb-3">
                            <h4 class="font-extrabold text-xs text-slate-800 tracking-widest uppercase flex items-center gap-2">
                                <span class="flex h-2.5 w-2.5 relative">
                                  <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-green-400 opacity-75"></span>
                                  <span class="relative inline-flex rounded-full h-2.5 w-2.5 bg-green-500"></span>
                                </span>
                                Hoạt Động Live
                            </h4>
                            <span class="text-[9px] font-bold text-emerald-600 bg-emerald-50 px-2 py-0.5 rounded-full uppercase">Realtime</span>
                        </div>
                        
                        <!-- List of activities -->
                        <div id="live-activity-list" class="space-y-3.5 max-h-[300px] overflow-y-auto pr-1">
                            <div class="flex items-start gap-3 text-xs text-slate-600 pb-2 border-b border-dashed border-slate-100">
                                <span class="text-[18px] shrink-0">⚽</span>
                                <div>
                                    <p class="font-bold text-slate-700">Sân Bóng Đá 01</p>
                                    <p class="text-slate-500">Anh Tuấn vừa đặt thành công ca đấu</p>
                                    <span class="text-[9px] text-slate-400 font-bold">1 phút trước</span>
                                </div>
                            </div>
                            <div class="flex items-start gap-3 text-xs text-slate-600 pb-2 border-b border-dashed border-slate-100">
                                <span class="text-[18px] shrink-0">🏸</span>
                                <div>
                                    <p class="font-bold text-slate-700">Sân Cầu Lông 03</p>
                                    <p class="text-slate-500">Chị Linh vừa check-in trực tuyến</p>
                                    <span class="text-[9px] text-slate-400 font-bold">3 phút trước</span>
                                </div>
                            </div>
                            <div class="flex items-start gap-3 text-xs text-slate-600">
                                <span class="text-[18px] shrink-0">🎾</span>
                                <div>
                                    <p class="font-bold text-slate-700">Sân Tennis 02</p>
                                    <p class="text-slate-500">Hội Sport Club vừa thanh toán ca đặt</p>
                                    <span class="text-[9px] text-slate-400 font-bold">5 phút trước</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Stars & Brand Ambassadors -->
                    <div class="bg-white/75 backdrop-blur-md border border-white/80 rounded-2xl p-5 shadow-[0_10px_30px_rgba(22,163,74,0.05)] sticky top-[500px] transition-all">
                        <div class="flex items-center justify-between mb-4 border-b border-slate-100 pb-3">
                            <h4 class="font-extrabold text-xs text-slate-800 tracking-widest uppercase flex items-center gap-1.5">
                                <span class="material-symbols-outlined text-[16px] text-amber-500 filled" style="font-variation-settings: 'FILL' 1">stars</span>
                                Ngôi Sao Tin Dùng
                            </h4>
                            <span class="text-[9px] font-bold text-slate-400 uppercase">Reviews</span>
                        </div>
                        
                        <!-- Testimonial List -->
                        <div class="space-y-3.5">
                            <!-- Testimonial 1 -->
                            <div class="p-3 bg-white/50 border border-slate-100 rounded-xl flex flex-col gap-2 hover:-translate-y-0.5 hover:border-green-200 transition-all shadow-sm">
                                <div class="flex items-center gap-2.5">
                                    <img src="https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=80&q=80" alt="Nguyễn Quang Hải" class="w-8 h-8 rounded-full object-cover border border-emerald-250">
                                    <div>
                                        <h5 class="font-bold text-slate-800 text-[11px] leading-tight">Q. Hải (Tuyển Thủ QG)</h5>
                                        <div class="flex items-center text-[10px] text-amber-500 gap-0.5">
                                            <span class="material-symbols-outlined text-[12px] filled" style="font-variation-settings: 'FILL' 1">star</span>
                                            <span class="material-symbols-outlined text-[12px] filled" style="font-variation-settings: 'FILL' 1">star</span>
                                            <span class="material-symbols-outlined text-[12px] filled" style="font-variation-settings: 'FILL' 1">star</span>
                                            <span class="material-symbols-outlined text-[12px] filled" style="font-variation-settings: 'FILL' 1">star</span>
                                            <span class="material-symbols-outlined text-[12px] filled" style="font-variation-settings: 'FILL' 1">star</span>
                                        </div>
                                    </div>
                                </div>
                                <p class="text-[10px] text-slate-500 italic leading-relaxed">"Mặt cỏ nhân tạo của V-SPORT rất êm, hệ thống thoát nước tốt nên đá bóng rất sướng."</p>
                            </div>
                            
                            <!-- Testimonial 2 -->
                            <div class="p-3 bg-white/50 border border-slate-100 rounded-xl flex flex-col gap-2 hover:-translate-y-0.5 hover:border-green-200 transition-all shadow-sm">
                                <div class="flex items-center gap-2.5">
                                    <img src="https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&w=80&q=80" alt="Nguyễn Tiến Minh" class="w-8 h-8 rounded-full object-cover border border-emerald-250">
                                    <div>
                                        <h5 class="font-bold text-slate-800 text-[11px] leading-tight">T. Minh (VĐV Cầu Lông)</h5>
                                        <div class="flex items-center text-[10px] text-amber-500 gap-0.5">
                                            <span class="material-symbols-outlined text-[12px] filled" style="font-variation-settings: 'FILL' 1">star</span>
                                            <span class="material-symbols-outlined text-[12px] filled" style="font-variation-settings: 'FILL' 1">star</span>
                                            <span class="material-symbols-outlined text-[12px] filled" style="font-variation-settings: 'FILL' 1">star</span>
                                            <span class="material-symbols-outlined text-[12px] filled" style="font-variation-settings: 'FILL' 1">star</span>
                                            <span class="material-symbols-outlined text-[12px] filled" style="font-variation-settings: 'FILL' 1">star</span>
                                        </div>
                                    </div>
                                </div>
                                <p class="text-[10px] text-slate-500 italic leading-relaxed">"Ánh sáng chuẩn không bị chói mắt và thảm Yonex dày êm, bảo vệ khớp gối tối đa."</p>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </section>

    </main>

    <!-- ── Floating Dynamic Icons on 2 Sides ── -->
    <div class="fixed left-4 top-[22%] z-30 pointer-events-none hidden xl:flex flex-col gap-20">
        <div class="w-14 h-14 rounded-2xl bg-white/50 backdrop-blur-md border border-white/80 shadow-[0_8px_32px_0_rgba(22,163,74,0.15)] flex flex-col items-center justify-center animate-float glow-pulse text-[24px]">
            ⚽
            <span class="text-[8px] font-black text-green-700 uppercase tracking-widest mt-1">Live</span>
        </div>
        <div class="w-14 h-14 rounded-2xl bg-white/50 backdrop-blur-md border border-white/80 shadow-[0_8px_32px_0_rgba(22,163,74,0.15)] flex flex-col items-center justify-center animate-float-rev glow-pulse text-[24px]">
            🏸
            <span class="text-[8px] font-black text-green-700 uppercase tracking-widest mt-1">Hot</span>
        </div>
    </div>
    
    <div class="fixed right-4 top-[28%] z-30 pointer-events-none hidden xl:flex flex-col gap-20">
        <div class="w-14 h-14 rounded-2xl bg-white/50 backdrop-blur-md border border-white/80 shadow-[0_8px_32px_0_rgba(22,163,74,0.15)] flex flex-col items-center justify-center animate-float-rev glow-pulse text-[24px]">
            🎾
            <span class="text-[8px] font-black text-green-700 uppercase tracking-widest mt-1">ITF</span>
        </div>
        <div class="w-14 h-14 rounded-2xl bg-white/50 backdrop-blur-md border border-white/80 shadow-[0_8px_32px_0_rgba(22,163,74,0.15)] flex flex-col items-center justify-center animate-float glow-pulse text-[24px]">
            🏓
            <span class="text-[8px] font-black text-green-700 uppercase tracking-widest mt-1">New</span>
        </div>
    </div>

    <!-- ════ HISTORY MODAL ════ -->
    <div id="historyModalOverlay" class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-50 hidden flex items-center justify-center opacity-0 transition-opacity duration-300 overflow-y-auto py-10 px-4">
        <div id="historyPanel" class="bg-white w-full max-w-4xl rounded-3xl shadow-2xl overflow-hidden transform scale-95 transition-all duration-300 relative my-auto">
            <div class="bg-gradient-to-r from-green-600 to-emerald-600 px-6 py-4 flex items-center justify-between text-white">
                <h3 class="font-bold text-lg flex items-center gap-2">
                    <span class="material-symbols-outlined">history</span> Lịch sử đặt sân của bạn
                </h3>
                <button onclick="closeHistoryModal()" class="text-white/80 hover:text-white p-1">
                    <span class="material-symbols-outlined">close</span>
                </button>
            </div>
            <c:if test="${sessionScope.user != null}">
                <div class="px-6 py-4 bg-slate-50/70 border-b border-slate-100 flex flex-wrap items-center justify-between gap-4">
                    <div class="flex items-center gap-3">
                        <div class="w-10 h-10 rounded-full bg-emerald-50 text-emerald-600 flex items-center justify-center font-extrabold text-sm shadow-inner border border-emerald-100/50">
                            <c:choose>
                                <c:when test="${not empty sessionScope.user.fullName}">${fn:substring(sessionScope.user.fullName, 0, 1)}</c:when>
                                <c:otherwise>${fn:substring(sessionScope.user.username, 0, 1)}</c:otherwise>
                            </c:choose>
                        </div>
                        <div>
                            <h4 class="font-extrabold text-slate-800 text-sm">${sessionScope.user.fullName}</h4>
                            <p class="text-[10px] text-slate-400 font-bold">${sessionScope.user.email}</p>
                        </div>
                    </div>
                    <div class="flex gap-4">
                        <div class="text-center px-4 py-1.5 bg-white rounded-xl border border-slate-100 shadow-sm">
                            <span class="text-[9px] text-slate-400 font-bold block uppercase tracking-wider">ĐÃ ĐẶT</span>
                            <span class="text-sm font-black text-emerald-600 block mt-0.5">${fn:length(dsLich)} ca</span>
                        </div>
                        <div class="text-center px-4 py-1.5 bg-white rounded-xl border border-slate-100 shadow-sm">
                            <span class="text-[9px] text-slate-400 font-bold block uppercase tracking-wider">UY TÍN</span>
                            <span class="text-sm font-black text-slate-700 block mt-0.5">${sessionScope.user.diemUyTin != null ? sessionScope.user.diemUyTin : 100}</span>
                        </div>
                    </div>
                </div>
            </c:if>
            <div class="p-6">
                <div class="overflow-x-auto rounded-2xl border border-slate-100 max-h-[400px] overflow-y-auto">
                    <table class="w-full text-left text-xs border-collapse">
                        <thead>
                            <tr class="bg-slate-50 border-b border-slate-100 text-slate-500 font-bold sticky top-0 z-10">
                                <th class="p-4 bg-slate-50">Chi tiết sân</th>
                                <th class="p-4 bg-slate-50 text-center">Thời gian</th>
                                <th class="p-4 bg-slate-50 text-right">Chi phí</th>
                                <th class="p-4 bg-slate-50 text-center">Trạng thái</th>
                                <th class="p-4 bg-slate-50 text-center">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-100 bg-white">
                            <c:forEach var="lich" items="${dsLich}">
                                <c:set var="tenSanHienThi" value="Sân #${lich.sanId}" />
                                <c:set var="branchHienThi" value="" />
                                <c:forEach var="s" items="${dsSan}">
                                    <c:if test="${s.sanID == lich.sanId}">
                                        <c:set var="tenSanHienThi" value="${s.tenSan}" />
                                        <c:forEach var="cs" items="${dsCoSo}">
                                            <c:if test="${cs.coSoID == s.coSoID}">
                                                <c:set var="branchHienThi" value="${cs.tenCoSo}" />
                                            </c:if>
                                        </c:forEach>
                                    </c:if>
                                </c:forEach>
                                <tr class="hover:bg-slate-50/40 transition-colors">
                                    <td class="p-4">
                                        <span class="font-extrabold text-sm text-slate-900 block">${tenSanHienThi}</span>
                                        <span class="text-[10px] text-slate-400 font-bold flex items-center gap-1">
                                            <c:if test="${not empty branchHienThi}">
                                                <span class="material-symbols-outlined text-[12px]">location_on</span>${branchHienThi} &middot;
                                            </c:if>
                                            Mã ĐS: #${lich.datSanId}
                                        </span>
                                    </td>
                                    <td class="p-4 text-center">
                                        <span class="font-bold text-slate-700 block">${lich.ngayDat}</span>
                                        <span class="text-xs text-emerald-600 font-extrabold font-mono">${lich.gioBatDau.toString().substring(0,5)} — ${lich.gioKetThuc.toString().substring(0,5)}</span>
                                    </td>
                                    <td class="p-4 text-right font-extrabold text-slate-900 text-sm">
                                        <fmt:formatNumber value="${lich.tongTienDuKien}" type="currency" currencySymbol="đ" maxFractionDigits="0" />
                                    </td>
                                    <td class="p-4 text-center">
                                        <c:choose>
                                            <c:when test="${lich.trangThai == 'Chờ xác nhận'}"><span class="bg-amber-50 text-amber-700 border border-amber-200 px-2.5 py-1 rounded-lg text-[10px] font-bold inline-block">Chờ duyệt</span></c:when>
                                            <c:when test="${lich.trangThai == 'Đã xác nhận' || lich.trangThai == 'Đã đặt'}"><span class="bg-green-50 text-green-700 border border-green-200 px-2.5 py-1 rounded-lg text-[10px] font-bold inline-block">Đã duyệt</span></c:when>
                                            <c:when test="${lich.trangThai == 'Đang sử dụng'}"><span class="bg-purple-50 text-purple-700 border border-purple-200 px-2.5 py-1 rounded-lg text-[10px] font-bold inline-block">Đang đá</span></c:when>
                                            <c:when test="${lich.trangThai == 'Đã hủy'}"><span class="bg-red-50 text-red-700 border border-red-200 px-2.5 py-1 rounded-lg text-[10px] font-bold inline-block">Đã hủy</span></c:when>
                                            <c:otherwise><span class="bg-slate-100 text-slate-500 border border-slate-200 px-2.5 py-1 rounded-lg text-[10px] font-bold inline-block">${lich.trangThai}</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="p-4 text-center">
                                        <div class="flex items-center justify-center gap-1.5">
                                            <c:if test="${lich.trangThai == 'Chờ xác nhận' || lich.trangThai == 'Đã xác nhận'}">
                                                <form action="${pageContext.request.contextPath}/customer/huy-dat-san" method="post" onsubmit="return confirm('Bạn có chắc chắn muốn hủy yêu cầu này?');" class="inline-block">
                                                    <input type="hidden" name="id" value="${lich.datSanId}">
                                                    <button type="submit" class="px-3 py-1.5 rounded-lg border border-red-200 text-red-500 font-bold hover:bg-red-50 text-[10px]">Hủy</button>
                                                </form>
                                            </c:if>
                                            <c:if test="${lich.trangThai == 'Chờ xác nhận' || lich.trangThai == 'Đã xác nhận' || lich.trangThai == 'Đang sử dụng'}">
                                                <button type="button" onclick="openCustomerServiceModal(${lich.datSanId})" class="px-3 py-1.5 rounded-lg border border-emerald-200 bg-emerald-50 text-emerald-600 font-bold hover:bg-emerald-100 text-[10px]">Dịch vụ</button>
                                            </c:if>
                                            <c:if test="${lich.trangThai == 'Đã hủy'}"><span class="text-slate-400 text-[10px] line-through">Không khả dụng</span></c:if>
                                            <c:if test="${lich.trangThai == 'Đã hoàn thành'}"><span class="text-green-600 text-[10px] font-bold">Hoàn thành</span></c:if>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty dsLich}">
                                <tr><td colspan="5" class="p-16 text-center">
                                    <span class="material-symbols-outlined text-[40px] text-slate-200 block mb-4">event_busy</span>
                                    <p class="text-slate-400 text-[11px] font-extrabold uppercase tracking-widest">Chưa có lịch sử đặt sân</p>
                                </td></tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- ════ BOOKING MODAL FLOW ════ -->
    <div id="bookingModalOverlay" class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-50 hidden flex items-center justify-center opacity-0 transition-opacity duration-300 overflow-y-auto py-10 px-4">
        <!-- Step 1: Form -->
        <div id="bookingFormPanel" class="bg-white w-full max-w-2xl rounded-3xl shadow-2xl overflow-hidden transform scale-95 transition-all duration-300 relative my-auto">
            <div class="bg-gradient-to-r from-green-600 to-emerald-600 px-6 py-4 flex items-center justify-between text-white">
                <h3 class="font-bold text-lg flex items-center gap-2"><span class="material-symbols-outlined">event_available</span> Đăng ký đặt sân</h3>
                <button onclick="closeBookingModal()" class="text-white/80 hover:text-white p-1"><span class="material-symbols-outlined">close</span></button>
            </div>
            <div class="p-6 md:p-8">
                <div class="flex items-start gap-4 p-4 bg-slate-50 rounded-2xl border border-slate-100 mb-6">
                    <div>
                        <h4 id="modal-court-name" class="font-bold text-slate-800 text-lg">Tên sân</h4>
                        <p id="modal-court-branch" class="text-sm text-slate-500 flex items-center gap-1 mt-1"><span class="material-symbols-outlined text-[16px]">location_on</span> Cơ sở</p>
                        <div class="flex items-center gap-2 mt-2.5">
                            <span id="modal-court-type" class="text-xs font-semibold text-green-600 bg-green-50 px-2.5 py-1 rounded-lg">Loại sân</span>
                            <span id="modal-court-status" class="text-[10px] font-bold inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg"></span>
                        </div>
                    </div>
                </div>
                <form id="booking-form" action="${pageContext.request.contextPath}/customer/dat-san" method="post" class="space-y-5">
                    <input type="hidden" name="sanId" id="input-san-id" required>
                    <input type="hidden" name="paymentMethod" id="input-payment-method" value="sau">
                    <div id="branch-hours-info" class="flex items-center gap-2 text-sm text-slate-600 bg-blue-50 border border-blue-100 rounded-xl px-4 py-3">
                        <span class="material-symbols-outlined text-[18px] text-blue-600 shrink-0">schedule</span>
                        <span>Giờ hoạt động: <strong id="modal-branch-hours" class="text-slate-800">--:-- - --:--</strong></span>
                    </div>
                    <div class="space-y-1.5">
                        <label for="ngayDat" class="form-label">Ngày thi đấu <span class="text-red-500">*</span></label>
                        <input type="date" name="ngayDat" id="ngayDat" required class="form-input" onchange="onBookingDateChange()">
                    </div>
                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                        <div class="space-y-1.5">
                            <label for="gioBatDau" class="form-label">Giờ bắt đầu <span class="text-red-500">*</span></label>
                            <div class="relative">
                                <select name="gioBatDau" id="gioBatDau" required class="form-input pr-10 cursor-pointer appearance-none" onchange="onStartTimeSelectChange()"></select>
                                <span class="material-symbols-outlined absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none text-[20px]">expand_more</span>
                            </div>
                        </div>
                        <div class="space-y-1.5">
                            <label for="gioKetThuc" class="form-label">Giờ kết thúc <span class="text-red-500">*</span></label>
                            <div class="relative">
                                <select name="gioKetThuc" id="gioKetThuc" required class="form-input pr-10 cursor-pointer appearance-none" onchange="onEndTimeSelectChange()">
                                    <option value="">Vui lòng chọn giờ bắt đầu trước</option>
                                </select>
                                <span class="material-symbols-outlined absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none text-[20px]">expand_more</span>
                            </div>
                        </div>
                    </div>
                    <div id="timetable-block" class="hidden mt-2">
                        <label class="form-label text-amber-600">Lịch đã có người đặt trong ngày</label>
                        <div id="timeline-slots" class="flex flex-wrap gap-2 mt-2"></div>
                    </div>
                    <div id="overlap-warning" class="bg-red-50 border border-red-200 text-red-600 p-3 rounded-xl text-sm hidden flex gap-2 items-start mt-2">
                        <span class="material-symbols-outlined text-[18px] mt-0.5">warning</span>
                        <span id="overlap-warning-text">Trùng lịch!</span>
                    </div>
                    <div class="space-y-1.5">
                        <label for="ghiChu" class="form-label">Ghi chú yêu cầu</label>
                        <textarea name="ghiChu" id="ghiChu" rows="2" class="form-input resize-none" placeholder="Thuê bóng, mượn áo tập..."></textarea>
                    </div>
                    <div class="pt-6 border-t border-slate-100 flex justify-end gap-3">
                        <button type="button" onclick="closeBookingModal()" class="px-6 py-3 rounded-xl font-bold text-slate-600 bg-slate-100 hover:bg-slate-200 transition-colors">Hủy</button>
                        <c:choose>
                            <c:when test="${sessionScope.user != null}">
                                <button type="button" id="next-checkout-btn" onclick="goToCheckout()" disabled
                                    class="px-8 py-3 rounded-xl font-bold text-white bg-green-600 hover:bg-green-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2">
                                    Tiếp tục thanh toán <span class="material-symbols-outlined text-[18px]">arrow_forward</span>
                                </button>
                            </c:when>
                            <c:otherwise>
                                <a href="${pageContext.request.contextPath}/dangnhap"
                                    class="px-8 py-3 rounded-xl font-bold text-white bg-green-600 hover:bg-green-700 transition-colors flex items-center gap-2">
                                    Đăng nhập để đặt sân <span class="material-symbols-outlined text-[18px]">login</span>
                                </a>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </form>
            </div>
        </div>

        <!-- Step 2: Checkout -->
        <div id="checkoutPanel" class="bg-white w-full max-w-md rounded-3xl shadow-2xl overflow-hidden transform scale-95 transition-all duration-300 hidden relative my-auto">
            <div class="px-6 py-4 flex items-center gap-3 border-b border-slate-100">
                <button onclick="backToBookingForm()" class="p-1.5 text-slate-400 hover:text-slate-800 bg-slate-50 hover:bg-slate-100 rounded-full transition-colors flex items-center justify-center">
                    <span class="material-symbols-outlined text-[20px]">arrow_back</span>
                </button>
                <h3 class="font-bold text-slate-800 text-lg">Thanh toán đặt sân</h3>
            </div>
            <div class="p-6">
                <div class="bg-slate-50 rounded-2xl p-4 border border-slate-100 mb-6 space-y-2 text-sm">
                    <div class="flex justify-between text-slate-600"><span>Thời gian chơi</span><span id="summary-duration" class="font-bold text-slate-800">-</span></div>
                    <div class="flex justify-between text-slate-600"><span>Đơn giá</span><span id="summary-rate" class="font-bold text-slate-800">-</span></div>
                    <div id="summary-lights-row" class="flex justify-between text-amber-600 hidden">
                        <span class="flex items-center gap-1"><span class="material-symbols-outlined text-[16px]">wb_twilight</span> Phụ thu đèn tối</span>
                        <span class="font-bold">Có áp dụng</span>
                    </div>
                    <div class="pt-3 mt-1 border-t border-slate-200 flex justify-between items-end">
                        <span class="text-xs font-bold uppercase text-slate-500">Tổng cộng</span>
                        <span id="summary-total" class="text-2xl font-bold text-green-600">-</span>
                    </div>
                </div>
                <div class="mb-5 space-y-2">
                    <label class="form-label text-slate-500">Phương thức thanh toán</label>
                    <div class="grid grid-cols-2 gap-3">
                        <button type="button" onclick="selectPaymentMethod('payos')" id="payment-opt-payos"
                            class="flex flex-col items-center justify-center p-3 rounded-2xl border-2 border-slate-100 hover:border-slate-200 transition-all text-center gap-1.5 active:scale-95">
                            <span class="material-symbols-outlined text-[22px] text-emerald-600">qr_code_2</span>
                            <span class="text-xs font-extrabold text-slate-800">Chuyển khoản (PayOS)</span>
                            <span class="text-[9px] text-slate-400 font-bold">Giữ sân 10 phút</span>
                        </button>
                        <button type="button" onclick="selectPaymentMethod('sau')" id="payment-opt-sau"
                            class="flex flex-col items-center justify-center p-3 rounded-2xl border-2 border-emerald-600 bg-emerald-50/20 text-center gap-1.5 active:scale-95">
                            <span class="material-symbols-outlined text-[22px] text-slate-500">payments</span>
                            <span class="text-xs font-extrabold text-slate-800">Thanh toán tại quầy</span>
                            <span class="text-[9px] text-slate-400 font-bold">Đặt cọc tiền mặt</span>
                        </button>
                    </div>
                </div>
                <div id="payment-info-sau" class="bg-slate-50 border border-slate-100 rounded-2xl p-4 text-center flex flex-col items-center gap-2">
                    <div class="w-9 h-9 bg-white rounded-full flex items-center justify-center shadow-inner border border-slate-100"><span class="material-symbols-outlined text-[18px]">schedule</span></div>
                    <div>
                        <p class="text-xs font-bold text-slate-800">Thanh toán sau (Tiền mặt)</p>
                        <p class="text-[10px] text-slate-500 mt-1 leading-normal max-w-[280px] mx-auto">Vui lòng đến trước 15 phút để làm thủ tục nhận sân.</p>
                    </div>
                </div>
                <div id="payment-info-payos" class="hidden bg-slate-50 border border-slate-100 rounded-2xl p-4 text-center flex flex-col items-center gap-2">
                    <div class="w-9 h-9 bg-white text-emerald-600 rounded-full flex items-center justify-center shadow-inner border border-emerald-100"><span class="material-symbols-outlined text-[18px]">bolt</span></div>
                    <div>
                        <p class="text-xs font-bold text-slate-800">Giữ sân tức thì trong 10 phút</p>
                        <p class="text-[10px] text-slate-500 mt-1 leading-normal max-w-[280px] mx-auto">Hệ thống sẽ tạo mã chuyển khoản tự động. Bạn cần hoàn tất trong 10 phút.</p>
                    </div>
                </div>
                <button onclick="confirmBooking()" class="w-full mt-6 bg-green-600 hover:bg-green-700 text-white font-bold h-12 rounded-xl text-[14px] transition-colors shadow-md flex items-center justify-center gap-2">
                    <span class="material-symbols-outlined text-[20px]">verified</span> Hoàn tất đặt sân
                </button>
            </div>
        </div>
    </div>

    <jsp:include page="/common/footer.jsp" />

    <!-- ════ CUSTOMER SERVICE MODAL ════ -->
    <div id="customerServiceModal" class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-[60] hidden flex items-center justify-center opacity-0 transition-opacity duration-300 overflow-y-auto py-10 px-4">
        <div class="bg-white w-full max-w-2xl rounded-3xl shadow-2xl overflow-hidden transform scale-95 transition-all duration-300 relative my-auto">
            <div class="bg-gradient-to-r from-emerald-600 to-teal-600 px-6 py-4 flex items-center justify-between text-white">
                <h3 class="font-bold text-lg flex items-center gap-2"><span class="material-symbols-outlined">coffee</span> Đặt thêm Dịch vụ / Nước uống</h3>
                <button onclick="closeCustomerServiceModal()" class="text-white/80 hover:text-white p-1"><span class="material-symbols-outlined">close</span></button>
            </div>
            <div class="p-6 md:p-8 max-h-[70vh] overflow-y-auto">
                <form id="customer-service-form" action="${pageContext.request.contextPath}/customer/dat-dich-vu" method="post" class="space-y-6">
                    <input type="hidden" name="datSanId" id="customer-service-datsan-id">
                    <div id="customer-service-loading" class="text-center py-10 text-slate-500">
                        <span class="material-symbols-outlined animate-spin text-[32px] text-emerald-600 mb-2">sync</span>
                        <p class="text-sm font-medium">Đang tải danh sách dịch vụ...</p>
                    </div>
                    <div id="customer-service-container" class="hidden space-y-4">
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4" id="customer-products-grid"></div>
                    </div>
                    <div class="pt-6 border-t border-slate-100 flex justify-between items-center">
                        <div>
                            <span class="text-xs font-bold text-slate-400 uppercase block">Tổng tiền dịch vụ thêm</span>
                            <span class="text-xl font-bold text-emerald-600" id="customer-service-total">0 đ</span>
                        </div>
                        <div class="flex gap-3">
                            <button type="button" onclick="closeCustomerServiceModal()" class="px-6 py-3 rounded-xl font-bold text-slate-600 bg-slate-100 hover:bg-slate-200 transition-colors">Hủy</button>
                            <button type="submit" class="px-8 py-3 rounded-xl font-bold text-white bg-emerald-600 hover:bg-emerald-700 transition-all shadow-md active:scale-95">Xác nhận đặt</button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- ════ MAIN JAVASCRIPT ════ -->
    <script>
        // ─── Date init ───
        const dateInput = document.getElementById('ngayDat');
        const todayStr = new Date().toISOString().split('T')[0];
        if (dateInput) { dateInput.min = todayStr; dateInput.value = todayStr; }
        const quickDate = document.getElementById('quick-date-input');
        if (quickDate) quickDate.value = todayStr;

        const DEFAULT_OPEN_TIME = "06:00";
        const DEFAULT_CLOSE_TIME = "23:00";

        // ─── Data bridge ───
        const branches = {
            <c:forEach var="cs" items="${dsCoSo}" varStatus="status">
                "${cs.coSoID}": {
                    id: ${cs.coSoID},
                    name: `${fn:replace(fn:escapeXml(cs.tenCoSo), '`', '\\`')}`,
                    address: `${fn:replace(fn:escapeXml(cs.diaChi), '`', '\\`')}`,
                    openTime: "${cs.gioMoCua != null ? cs.gioMoCua : '06:00:00'}",
                    closeTime: "${cs.gioDongCua != null ? cs.gioDongCua : '23:00:00'}"
                }${not status.last ? ',' : ''}
            </c:forEach>
        };

        const sports = {
            <c:forEach var="m" items="${dsMon}" varStatus="status">
                "${m.monTheThaoID}": `${fn:replace(fn:escapeXml(m.tenMon), '`', '\\`')} `.trim()${not status.last ? ',' : ''}
            </c:forEach>
        };

        const courtTypes = {
            <c:forEach var="l" items="${dsLoai}" varStatus="status">
                "${l.loaiSanID}": {
                    id: ${l.loaiSanID},
                    sportId: ${l.monTheThaoID},
                    name: `${fn:replace(fn:escapeXml(l.tenLoai), '`', '\\`')} `.trim(),
                    priceDay: ${l.giaKhongDen},
                    priceNight: ${l.giaCoDen},
                    lightTime: `${l.gioBatDauLenDen}`,
                    branchId: ${l.coSoID != null ? l.coSoID : 'null'}
                }${not status.last ? ',' : ''}
            </c:forEach>
        };

        const courts = [
            <c:forEach var="s" items="${dsSan}" varStatus="status">
                {
                    id: ${s.sanID},
                    name: `${fn:replace(fn:escapeXml(s.tenSan), '`', '\\`')} `.trim(),
                    typeId: ${s.loaiSanID},
                    branchId: ${s.coSoID},
                    status: `${fn:replace(fn:escapeXml(s.trangThai), '`', '\\`')} `.trim(),
                    desc: `${fn:replace(fn:escapeXml(s.moTa), '`', '\\`')} `.trim(),
                    image: `${fn:replace(fn:escapeXml(s.hinhAnh != null ? s.hinhAnh : ''), '`', '\\`')} `.trim()
                }${not status.last ? ',' : ''}
            </c:forEach>
        ];

        const activeBookings = [
            <c:forEach var="b" items="${activeBookings}" varStatus="status">
                {
                    id: ${b.datSanId},
                    sanId: ${b.sanId != null ? b.sanId : 'null'},
                    date: `${b.ngayDat}`,
                    start: `${b.gioBatDau}`,
                    end: `${b.gioKetThuc}`,
                    status: `${fn:escapeXml(b.trangThai)} `.trim()
                }${not status.last ? ',' : ''}
            </c:forEach>
        ];

        // ─── State ───
        let selectedBranchId = 0;
        let selectedSportId = 0;
        let selectedCourtId = null;
        let currentTotalCost = 0;
        let selectedLocationQuery = "";

        const urlParams = new URLSearchParams(window.location.search);
        const paramSportId = parseInt(urlParams.get('sportId')) || 0;
        const paramBranchId = parseInt(urlParams.get('branchId')) || 0;
        const paramDate = urlParams.get('date');
        if (paramBranchId) selectedBranchId = paramBranchId;
        if (paramSportId) selectedSportId = paramSportId;
        if (paramDate && dateInput) dateInput.value = paramDate;

        // ─── Branch bar toggle ───
        function toggleBranchBar() {
            const bar = document.getElementById('branch-bar');
            bar.classList.toggle('hidden');
            bar.classList.toggle('flex');
        }

        // ─── Status helpers ───
        function getCourtStatusInfo(status) {
            const s = (status || '').trim();
            if (s === 'Sẵn sàng') return { label: 'Sẵn Sàng', bookable: true, badgeClass: 'bg-white/80 border-green-500 text-green-700', dotClass: 'bg-green-500 animate-pulse' };
            if (s === 'Đang dùng') return { label: 'Đang Dùng', bookable: false, badgeClass: 'bg-white/80 border-amber-400 text-amber-600', dotClass: 'bg-amber-400 animate-pulse' };
            if (s === 'Bảo trì' || s === 'Đang bảo trì' || s === 'Tạm đóng') return { label: s, bookable: false, badgeClass: 'bg-white/90 border-slate-300 text-slate-500', dotClass: '' };
            return { label: s || 'Không rõ', bookable: false, badgeClass: 'bg-white/90 border-slate-300 text-slate-500', dotClass: '' };
        }

        // ─── Render Courts (masonry / PitchPerfect cards) ───
        function renderCourts() {
            const container = document.getElementById("courts-container");
            container.innerHTML = "";

            const filteredCourts = courts.filter(c => {
                const matchBranch = (selectedBranchId === 0 || c.branchId === selectedBranchId);
                const type = courtTypes[c.typeId];
                const matchSport = (selectedSportId === 0 || (type && type.sportId === selectedSportId));
                const branch = branches[c.branchId] || {};
                const searchQ = (selectedLocationQuery || '').toLowerCase().trim();
                const matchLocation = !searchQ ||
                    (branch.address || '').toLowerCase().includes(searchQ) ||
                    (branch.name || '').toLowerCase().includes(searchQ);
                return matchBranch && matchSport && matchLocation;
            });

            document.getElementById("court-count").textContent = filteredCourts.length;

            const availableCount = filteredCourts.filter(c => c.status === 'Sẵn sàng').length;
            const inUseCount = filteredCourts.filter(c => c.status === 'Đang dùng').length;
            const otherCount = filteredCourts.length - availableCount - inUseCount;
            const parts = [];
            if (availableCount > 0) parts.push('<span class="text-green-600">' + availableCount + ' trống</span>');
            if (inUseCount > 0) parts.push('<span class="text-amber-500">' + inUseCount + ' đang dùng</span>');
            if (otherCount > 0) parts.push('<span class="text-red-400">' + otherCount + ' không khả dụng</span>');
            document.getElementById("court-status-summary").innerHTML = parts.join(' · ');

            if (filteredCourts.length === 0) {
                container.style.columnCount = 1;
                container.innerHTML = `
                    <div class="text-center py-20">
                        <span class="material-symbols-outlined text-[64px] text-slate-200 block mb-4">search_off</span>
                        <p class="text-slate-500 font-medium">Không tìm thấy sân phù hợp.</p>
                        <button onclick="filterBranch(0); filterSport(0);" class="mt-4 text-green-600 font-bold hover:underline text-sm">Xóa bộ lọc</button>
                    </div>
                `;
                return;
            }
            container.style.columnCount = '';

            filteredCourts.forEach(c => {
                const type = courtTypes[c.typeId] || { name: "Chưa phân loại", priceDay: 100000, priceNight: 100000, sportId: 0 };
                const branch = branches[c.branchId] || { name: "Cơ Sở", address: "", openTime: DEFAULT_OPEN_TIME, closeTime: DEFAULT_CLOSE_TIME };
                const sportName = sports[type.sportId] || "Thể thao";
                const statusInfo = getCourtStatusInfo(c.status);
                const priceText = type.priceDay.toLocaleString('vi-VN') + ' đ';

                // Choose image
                let imgUrl = "https://images.unsplash.com/photo-1518605368461-1ee7e57c6691?auto=format&fit=crop&w=600&q=80";
                const sn = sportName.toLowerCase();
                if (sn.includes("cầu lông") || sn.includes("pickleball")) imgUrl = "https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?auto=format&fit=crop&w=600&q=80";
                else if (sn.includes("tennis")) imgUrl = "https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0?auto=format&fit=crop&w=600&q=80";
                else if (sn.includes("bóng bàn")) imgUrl = "https://images.unsplash.com/photo-1534158914592-062992fbe900?auto=format&fit=crop&w=600&q=80";
                else if (sn.includes("gym") || sn.includes("fitness")) imgUrl = "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&w=600&q=80";
                if (c.image && c.image.trim() !== "") imgUrl = c.image;

                const rating = (4.5 + (c.id % 5) * 0.1).toFixed(1);
                const reviews = 20 + (c.id * 7) % 80;

                // Height variation for masonry feel
                const imgHeights = ['h-56', 'h-64', 'h-72', 'h-80'];
                const imgH = imgHeights[c.id % imgHeights.length];

                // Status badge HTML
                const badgeHtml = statusInfo.dotClass
                    ? `<div class="absolute top-5 right-5 backdrop-blur-md border ${statusInfo.badgeClass} font-bold text-[10px] tracking-widest uppercase px-3 py-1.5 rounded-full flex items-center gap-1.5 shadow-sm">
                            <span class="w-2 h-2 rounded-full ${statusInfo.dotClass}"></span>${statusInfo.label}
                       </div>`
                    : `<div class="absolute top-5 right-5 backdrop-blur-md border ${statusInfo.badgeClass} font-bold text-[10px] tracking-widest uppercase px-3 py-1.5 rounded-full flex items-center gap-1.5 shadow-sm opacity-90">
                            <span class="material-symbols-outlined text-[13px]">block</span>${statusInfo.label}
                       </div>`;

                const cardHtml = `
                    <article class="masonry-item relative group rounded-2xl overflow-hidden bg-white/65 backdrop-blur-md border border-white/80 transition-all duration-300 hover:border-green-300 hover:shadow-[0_10px_30px_rgba(22,163,74,0.18)] cursor-pointer shadow-sm">
                        <a href="${pageContext.request.contextPath}/customer/chi-tiet-san?id=\${c.id}" class="block">
                            <!-- Image -->
                            <div class="\${imgH} w-full relative p-2">
                                <img src="\${imgUrl}" alt="\${c.name}"
                                    class="w-full h-full object-cover rounded-xl group-hover:scale-[1.03] transition-transform duration-700">
                                <div class="absolute inset-2 rounded-xl bg-gradient-to-t from-slate-900/30 via-transparent to-transparent pointer-events-none"></div>
                                \${badgeHtml}
                                <!-- Sport tag bottom-left -->
                                <div class="absolute bottom-6 left-6 bg-white/85 backdrop-blur-md font-bold text-[10px] tracking-widest uppercase text-green-700 border border-green-200/60 px-2.5 py-1 rounded-full shadow-sm">
                                    \${sportName}
                                </div>
                            </div>
                            <!-- Content -->
                            <div class="w-full p-5 bg-white/45 backdrop-blur-md border-t border-white/50">
                                <div class="flex justify-between items-start mb-1.5">
                                    <h4 class="text-[16px] font-bold text-slate-800 group-hover:text-green-700 transition-colors leading-tight pr-2">\${c.name}</h4>
                                    <div class="flex items-center gap-1 text-[12px] font-bold text-green-700 bg-green-50 border border-green-100 px-2 py-1 rounded-lg shrink-0">
                                        <span class="material-symbols-outlined text-[14px]" style="font-variation-settings:'FILL' 1">star</span> \${rating}
                                    </div>
                                </div>
                                <p class="text-[13px] text-slate-500 flex items-center gap-1 mb-3">
                                    <span class="material-symbols-outlined text-[15px] text-slate-400">location_on</span>
                                    <span class="truncate">\${branch.name}</span>
                                </p>
                                <p class="text-[12px] text-slate-400 flex items-center gap-1 mb-3">
                                    <span class="material-symbols-outlined text-[14px]">schedule</span>
                                    \${normalizeTime(branch.openTime)} – \${normalizeTime(branch.closeTime)}
                                </p>
                                <p class="text-[13px] text-slate-600 line-clamp-2 mb-4 min-h-[38px]">\${c.desc || 'Sân đấu tiêu chuẩn chất lượng cao, hệ thống đèn chiếu sáng ban đêm hiện đại.'}</p>
                                <!-- Price + Arrow -->
                                <div class="flex justify-between items-center pt-4 border-t border-slate-100">
                                    <div>
                                        <span class="text-[9px] font-bold text-slate-400 uppercase tracking-widest block mb-0.5">TỪ</span>
                                        <span class="text-[18px] font-bold text-slate-800">\${priceText}<span class="text-[11px] font-normal text-slate-400">/h</span></span>
                                    </div>
                                    <div class="w-9 h-9 rounded-full bg-green-50 text-green-600 flex items-center justify-center border border-green-100 group-hover:bg-green-600 group-hover:text-white group-hover:shadow-[0_0_14px_rgba(22,163,74,0.35)] transition-all">
                                        <span class="material-symbols-outlined text-[20px] group-hover:translate-x-0.5 transition-transform">arrow_forward</span>
                                    </div>
                                </div>
                            </div>
                        </a>
                    </article>
                `;
                container.insertAdjacentHTML("beforeend", cardHtml);
            });
        }

        // ─── Filter functions ───
        function filterSport(sportId) {
            selectedSportId = sportId;
            document.querySelectorAll(".sport-pill").forEach(b => {
                b.classList.remove("active");
                b.style.backgroundColor = '';
                b.style.color = '';
                b.style.borderColor = '';
            });
            const active = document.getElementById('btn-sport-' + sportId);
            if (active) active.classList.add("active");
            renderCourts();
        }

        function filterBranch(branchId) {
            selectedBranchId = branchId;
            document.querySelectorAll(".branch-pill").forEach(b => {
                b.classList.remove("active");
            });
            const active = document.getElementById('btn-branch-' + branchId);
            if (active) active.classList.add("active");
            renderCourts();
        }

        function filterLocation(query) {
            selectedLocationQuery = query;
            renderCourts();
        }

        // ─── Event listeners ───
        document.addEventListener("DOMContentLoaded", () => {
            const locationInput = document.getElementById("location-search-input");
            if (locationInput) locationInput.addEventListener("input", e => filterLocation(e.target.value));

            const locateBtn = document.getElementById("btn-auto-locate");
            const locateIcon = document.getElementById("locate-icon");
            const locateText = document.getElementById("locate-text");
            if (locateBtn) {
                locateBtn.addEventListener("click", () => {
                    locateIcon.innerHTML = "sync";
                    locateIcon.classList.add("animate-spin");
                    locateText.textContent = "Đang quét...";
                    locateBtn.disabled = true;
                    setTimeout(() => {
                        const firstKey = Object.keys(branches)[0];
                        let detected = firstKey ? (branches[firstKey].address || branches[firstKey].name || '') : '';
                        if (detected.includes(',')) detected = detected.split(',')[0].trim();
                        if (locationInput) { locationInput.value = detected; filterLocation(detected); }
                        locateIcon.innerHTML = "radar";
                        locateIcon.classList.remove("animate-spin");
                        locateText.textContent = "QUÉT";
                        locateBtn.disabled = false;
                    }, 900);
                });
            }

            if (urlParams.get('openHistory') === 'true') openHistoryModal();
        });

        // ─── Booking modal helpers ───
        function normalizeTime(t) { return t ? t.substring(0, 5) : DEFAULT_OPEN_TIME; }

        function getBranchHours(branchId) {
            const b = branches[branchId];
            return {
                openTime: normalizeTime(b?.openTime || DEFAULT_OPEN_TIME),
                closeTime: normalizeTime(b?.closeTime || DEFAULT_CLOSE_TIME),
                name: b?.name || 'Cơ Sở'
            };
        }

        function timeToMinutes(t) {
            const p = t.split(':');
            return parseInt(p[0], 10) * 60 + parseInt(p[1], 10);
        }

        function formatDurationText(mins) {
            const h = Math.floor(mins / 60), m = mins % 60;
            return (h > 0 ? h + ' tiếng ' : '') + (m > 0 ? m + ' phút' : '');
        }

        function openBookingModal(courtId) {
            selectedCourtId = courtId;
            document.getElementById("input-san-id").value = courtId;
            const court = courts.find(c => c.id === courtId);
            if (!court) return;
            const type = courtTypes[court.typeId];
            const branch = branches[court.branchId];
            document.getElementById("modal-court-name").textContent = court.name;
            document.getElementById("modal-court-branch").innerHTML = `<span class="material-symbols-outlined text-[16px]">location_on</span> \${branch.name}`;
            document.getElementById("modal-court-type").textContent = type.name;
            const si = getCourtStatusInfo(court.status);
            const el = document.getElementById("modal-court-status");
            el.className = 'text-[10px] font-bold inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg ' + si.badgeClass;
            el.innerHTML = (si.dotClass ? '<span class="w-1.5 h-1.5 rounded-full ' + si.dotClass + '"></span>' : '') + si.label;
            document.getElementById("ngayDat").value = todayStr;
            document.getElementById("ghiChu").value = "";
            selectPaymentMethod('sau');
            applyBranchTimeConstraints(court.branchId);
            document.getElementById("timetable-block").classList.add("hidden");
            document.getElementById("overlap-warning").classList.add("hidden");
            const btnNext = document.getElementById("next-checkout-btn");
            if (btnNext) btnNext.disabled = true;
            const overlay = document.getElementById("bookingModalOverlay");
            overlay.classList.remove("hidden");
            document.getElementById("checkoutPanel").classList.add("hidden");
            document.getElementById("bookingFormPanel").classList.remove("hidden");
            setTimeout(() => {
                overlay.classList.remove("opacity-0");
                document.getElementById("bookingFormPanel").classList.remove("scale-95");
            }, 10);
            checkScheduleAndPrice();
        }

        function closeBookingModal() {
            const overlay = document.getElementById("bookingModalOverlay");
            overlay.classList.add("opacity-0");
            document.querySelectorAll("#bookingFormPanel, #checkoutPanel").forEach(p => p.classList.add("scale-95"));
            setTimeout(() => overlay.classList.add("hidden"), 300);
        }

        function openHistoryModal() {
            const overlay = document.getElementById("historyModalOverlay");
            const panel = document.getElementById("historyPanel");
            overlay.classList.remove("hidden"); overlay.classList.add("flex");
            setTimeout(() => { overlay.classList.remove("opacity-0"); panel.classList.remove("scale-95"); }, 10);
        }

        function closeHistoryModal() {
            const overlay = document.getElementById("historyModalOverlay");
            const panel = document.getElementById("historyPanel");
            overlay.classList.add("opacity-0"); panel.classList.add("scale-95");
            setTimeout(() => { overlay.classList.add("hidden"); overlay.classList.remove("flex"); }, 300);
        }

        function selectPaymentMethod(method) {
            document.getElementById("input-payment-method").value = method;
            const btnPOS = document.getElementById("payment-opt-payos"), btnSau = document.getElementById("payment-opt-sau");
            const infoPOS = document.getElementById("payment-info-payos"), infoSau = document.getElementById("payment-info-sau");
            if (!btnPOS || !btnSau) return;
            if (method === 'payos') {
                btnPOS.className = "flex flex-col items-center justify-center p-3 rounded-2xl border-2 border-emerald-600 bg-emerald-50/20 text-center gap-1.5 active:scale-95";
                btnSau.className = "flex flex-col items-center justify-center p-3 rounded-2xl border-2 border-slate-100 hover:border-slate-200 text-center gap-1.5 active:scale-95";
                infoPOS.classList.remove("hidden"); infoSau.classList.add("hidden");
            } else {
                btnSau.className = "flex flex-col items-center justify-center p-3 rounded-2xl border-2 border-emerald-600 bg-emerald-50/20 text-center gap-1.5 active:scale-95";
                btnPOS.className = "flex flex-col items-center justify-center p-3 rounded-2xl border-2 border-slate-100 hover:border-slate-200 text-center gap-1.5 active:scale-95";
                infoSau.classList.remove("hidden"); infoPOS.classList.add("hidden");
            }
        }

        let lastHoldKey = null;
        function requestSoftHold(courtId, dateVal, startVal, endVal) {
            const holdKey = `\${courtId}|\${dateVal}|\${startVal}|\${endVal}`;
            if (holdKey === lastHoldKey) return;
            lastHoldKey = holdKey;
            const btnNext = document.getElementById("next-checkout-btn");
            const warningBox = document.getElementById("overlap-warning");
            const warningText = document.getElementById("overlap-warning-text");
            fetch("<c:url value='/customer/giu-cho-tam'/>", {
                method: "POST", headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: new URLSearchParams({ sanId: courtId, ngayDat: dateVal, gioBatDau: startVal, gioKetThuc: endVal }).toString()
            }).then(r => r.json()).then(data => {
                if (holdKey !== lastHoldKey) return;
                if (!data.success) {
                    warningText.textContent = data.message || "Đã có người đang giữ khung giờ này.";
                    warningBox.classList.remove("hidden");
                    if (btnNext) btnNext.disabled = true;
                    lastHoldKey = null;
                }
            }).catch(() => {});
        }

        function checkScheduleAndPrice() {
            const courtId = selectedCourtId;
            const dateVal = document.getElementById("ngayDat").value;
            const startVal = document.getElementById("gioBatDau").value;
            const endVal = document.getElementById("gioKetThuc").value;
            if (!courtId || !dateVal) return;
            const btnNext = document.getElementById("next-checkout-btn");
            const timetableBlock = document.getElementById("timetable-block");
            const timelineSlots = document.getElementById("timeline-slots");
            const warningBox = document.getElementById("overlap-warning");
            const warningText = document.getElementById("overlap-warning-text");
            const conflicts = activeBookings.filter(b => b.sanId === courtId && b.date === dateVal && b.status !== "Đã hủy");
            if (conflicts.length > 0) {
                timetableBlock.classList.remove("hidden");
                timelineSlots.innerHTML = "";
                conflicts.forEach(b => {
                    timelineSlots.insertAdjacentHTML("beforeend", `<div class="px-3 py-1.5 bg-amber-50 text-amber-700 border border-amber-200 rounded-lg text-xs font-bold">\${b.start.substring(0,5)} - \${b.end.substring(0,5)}</div>`);
                });
            } else timetableBlock.classList.add("hidden");
            if (!startVal || !endVal) { if (btnNext) btnNext.disabled = true; warningBox.classList.add("hidden"); return; }
            const court = courts.find(c => c.id === courtId);
            const branchHours = getBranchHours(court ? court.branchId : null);
            const startMin = timeToMinutes(startVal), endMin = timeToMinutes(endVal);
            const openMin = timeToMinutes(branchHours.openTime), closeMin = timeToMinutes(branchHours.closeTime);
            if (endMin <= startMin) { warningText.textContent = "Giờ kết thúc phải sau giờ bắt đầu."; warningBox.classList.remove("hidden"); if (btnNext) btnNext.disabled = true; return; }
            if (startMin < openMin) { warningText.textContent = branchHours.name + " mở cửa lúc " + branchHours.openTime + "."; warningBox.classList.remove("hidden"); if (btnNext) btnNext.disabled = true; return; }
            if (endMin > closeMin) { warningText.textContent = branchHours.name + " đóng cửa lúc " + branchHours.closeTime + "."; warningBox.classList.remove("hidden"); if (btnNext) btnNext.disabled = true; return; }
            if (dateVal === todayStr) {
                const now = new Date(), nowMin = now.getHours() * 60 + now.getMinutes();
                if (startMin < nowMin) { warningText.textContent = "Không thể đặt sân cho giờ đã qua hôm nay."; warningBox.classList.remove("hidden"); if (btnNext) btnNext.disabled = true; return; }
            }
            let isOverlap = false;
            conflicts.forEach(b => { const bS = timeToMinutes(b.start), bE = timeToMinutes(b.end); if (!(endMin <= bS || startMin >= bE)) isOverlap = true; });
            if (isOverlap) { warningText.textContent = "Khung giờ bạn chọn đã bị trùng lịch."; warningBox.classList.remove("hidden"); if (btnNext) btnNext.disabled = true; return; }
            warningBox.classList.add("hidden"); if (btnNext) btnNext.disabled = false;
            requestSoftHold(courtId, dateVal, startVal, endVal);
            const type = courtTypes[court.typeId];
            if (type) {
                const lightMin = timeToMinutes(type.lightTime);
                const hourlyRate = startMin >= lightMin ? type.priceNight : type.priceDay;
                const applyLights = startMin >= lightMin && type.priceNight !== type.priceDay;
                const durationH = (endMin - startMin) / 60.0;
                currentTotalCost = Math.round(durationH * hourlyRate);
                document.getElementById("summary-duration").textContent = `\${durationH.toFixed(1)} giờ (\${formatDurationText(endMin - startMin)})`;
                document.getElementById("summary-rate").textContent = `\${hourlyRate.toLocaleString('vi-VN')} đ/giờ`;
                document.getElementById("summary-lights-row").classList.toggle("hidden", !applyLights);
                document.getElementById("summary-total").textContent = `\${currentTotalCost.toLocaleString('vi-VN')} đ`;
            }
        }

        function goToCheckout() {
            if (!document.getElementById('booking-form').reportValidity()) return;
            const fp = document.getElementById("bookingFormPanel"), cp = document.getElementById("checkoutPanel");
            fp.classList.add("scale-95", "opacity-0");
            setTimeout(() => { fp.classList.add("hidden"); fp.classList.remove("opacity-0"); cp.classList.remove("hidden"); setTimeout(() => cp.classList.remove("scale-95"), 10); }, 200);
        }

        function backToBookingForm() {
            const fp = document.getElementById("bookingFormPanel"), cp = document.getElementById("checkoutPanel");
            cp.classList.add("scale-95", "opacity-0");
            setTimeout(() => { cp.classList.add("hidden"); cp.classList.remove("opacity-0"); fp.classList.remove("hidden"); setTimeout(() => fp.classList.remove("scale-95"), 10); }, 200);
        }

        function confirmBooking() { document.getElementById('booking-form').submit(); }

        function applyBranchTimeConstraints(branchId) {
            const { openTime, closeTime } = getBranchHours(branchId);
            const hoursLabel = document.getElementById("modal-branch-hours");
            if (hoursLabel) hoursLabel.textContent = openTime.substring(0, 5) + " - " + closeTime.substring(0, 5);
            const openMin = timeToMinutes(openTime), closeMin = timeToMinutes(closeTime);
            const dateVal = document.getElementById("ngayDat").value;
            const conflicts = activeBookings.filter(b => b.sanId === selectedCourtId && b.date === dateVal && b.status !== "Đã hủy");
            const startSelect = document.getElementById("gioBatDau");
            startSelect.innerHTML = '<option value="">-- Chọn giờ bắt đầu --</option>';
            let currentTotalMin = -1;
            if (dateVal === todayStr) { const now = new Date(); currentTotalMin = now.getHours() * 60 + now.getMinutes(); }
            for (let m = openMin; m <= closeMin - 30; m += 30) {
                const h = Math.floor(m / 60), min = m % 60;
                const timeStr = String(h).padStart(2, "0") + ":" + String(min).padStart(2, "0");
                const isPast = m <= currentTotalMin;
                const isBooked = conflicts.some(b => { const s = timeToMinutes(b.start), e = timeToMinutes(b.end); return m >= s && m < e; });
                const opt = document.createElement("option");
                opt.value = timeStr;
                opt.text = isPast ? timeStr + " (Đã qua)" : isBooked ? timeStr + " (Đã có người đặt)" : timeStr;
                if (isPast || isBooked) opt.disabled = true;
                startSelect.appendChild(opt);
            }
            document.getElementById("gioBatDau").value = "";
            document.getElementById("gioKetThuc").innerHTML = '<option value="">Vui lòng chọn giờ bắt đầu trước</option>';
        }

        function onStartTimeSelectChange() {
            const startVal = document.getElementById("gioBatDau").value;
            const endSelectEl = document.getElementById("gioKetThuc");
            if (!startVal) { endSelectEl.innerHTML = '<option value="">Vui lòng chọn giờ bắt đầu trước</option>'; checkScheduleAndPrice(); return; }
            const startMin = timeToMinutes(startVal);
            const court = courts.find(c => c.id === selectedCourtId);
            const { closeTime } = getBranchHours(court ? court.branchId : null);
            const closeMin = timeToMinutes(closeTime);
            const dateVal = document.getElementById("ngayDat").value;
            const conflicts = activeBookings.filter(b => b.sanId === selectedCourtId && b.date === dateVal && b.status !== "Đã hủy");
            let maxMin = closeMin;
            conflicts.forEach(b => { const bs = timeToMinutes(b.start); if (bs > startMin && bs < maxMin) maxMin = bs; });
            endSelectEl.innerHTML = '<option value="">-- Chọn giờ kết thúc --</option>';
            for (let m = startMin + 30; m <= maxMin; m += 30) {
                const h = Math.floor(m / 60), min = m % 60;
                const timeStr = String(h).padStart(2, "0") + ":" + String(min).padStart(2, "0");
                const opt = document.createElement("option");
                opt.value = timeStr;
                opt.text = timeStr + " (" + formatDurationText(m - startMin) + ")";
                endSelectEl.appendChild(opt);
            }
            checkScheduleAndPrice();
        }

        function onEndTimeSelectChange() { checkScheduleAndPrice(); }
        function onBookingDateChange() { const c = courts.find(x => x.id === selectedCourtId); if (c) applyBranchTimeConstraints(c.branchId); checkScheduleAndPrice(); }

        // ─── Live Activity Feed Generator ───
        const sportIcons = { 0: "⚽", 1: "🏸", 2: "🎾", 3: "🏓", 4: "⚽" };
        const actionPrefixes = [
            "vừa đặt thành công ca đấu",
            "đã thanh toán giữ sân ca tối",
            "được check-in trực tuyến",
            "vừa hoàn tất thanh toán (PayOS)",
            "vừa gửi đánh giá 5★ cho sân"
        ];
        const names = ["Anh Hùng", "Chị Thảo", "Hội Sport Club", "Anh Tuấn", "Chị Mai", "Anh Hoàng", "Chị Linh", "FC Đông Đô", "Badminton Club", "Anh Bách"];

        function initLiveActivityFeed() {
            const feedContainer = document.getElementById("live-activity-list");
            if (!feedContainer) return;
            
            // Periodically add new item and remove oldest
            setInterval(() => {
                const randomCourt = courts[Math.floor(Math.random() * courts.length)];
                if (!randomCourt) return;
                const icon = randomCourt.name.toLowerCase().includes("bóng đá") ? "⚽" :
                             randomCourt.name.toLowerCase().includes("cầu lông") ? "🏸" :
                             randomCourt.name.toLowerCase().includes("tennis") ? "🎾" :
                             randomCourt.name.toLowerCase().includes("pickleball") ? "🏓" : "🏃";
                             
                const randomAction = actionPrefixes[Math.floor(Math.random() * actionPrefixes.length)];
                const randomName = names[Math.floor(Math.random() * names.length)];
                
                const itemHtml = `
                    <div class="flex items-start gap-3 text-xs text-slate-600 pb-2 border-b border-dashed border-slate-100 last:border-0" style="animation: slide-up-fade 0.5s ease forwards">
                        <span class="text-[18px] shrink-0">\${icon}</span>
                        <div>
                            <p class="font-bold text-slate-700">\${randomCourt.name}</p>
                            <p class="text-slate-500">\${randomName} \${randomAction}</p>
                            <span class="text-[9px] text-slate-400 font-bold">Vừa xong</span>
                        </div>
                    </div>
                `;
                
                feedContainer.insertAdjacentHTML("afterbegin", itemHtml);
                
                // Keep max 4 items inside container
                if (feedContainer.children.length > 4) {
                    const lastChild = feedContainer.lastElementChild;
                    lastChild.style.transition = "all 0.5s ease";
                    lastChild.style.opacity = "0";
                    lastChild.style.transform = "translateY(5px)";
                    setTimeout(() => {
                        if (lastChild.parentNode === feedContainer) {
                            feedContainer.removeChild(lastChild);
                        }
                    }, 500);
                }
            }, 7000); // update every 7 seconds
        }

        // ─── Init ───
        console.log('[DatSan] courts:', courts.length, '| branches:', Object.keys(branches).length);
        renderCourts();
        if (paramBranchId) filterBranch(paramBranchId);
        if (paramSportId) filterSport(paramSportId);
        initLiveActivityFeed();
    </script>

    <!-- Customer Service Modal JS -->
    <script>
        let customerProducts = [], customerOrdered = [];

        function openCustomerServiceModal(datSanId) {
            document.getElementById("customer-service-datsan-id").value = datSanId;
            const modal = document.getElementById("customerServiceModal");
            const loading = document.getElementById("customer-service-loading");
            const container = document.getElementById("customer-service-container");
            const grid = document.getElementById("customer-products-grid");
            modal.classList.remove("hidden"); modal.classList.add("flex");
            loading.classList.remove("hidden"); container.classList.add("hidden");
            setTimeout(() => { modal.classList.remove("opacity-0"); modal.querySelector(".bg-white").classList.remove("scale-95"); }, 10);
            fetch(`${pageContext.request.contextPath}/customer/dat-dich-vu?datSanId=${datSanId}`)
                .then(r => r.json()).then(data => {
                    customerProducts = data.products || []; customerOrdered = data.ordered || [];
                    loading.classList.add("hidden"); container.classList.remove("hidden");
                    grid.innerHTML = "";
                    if (customerProducts.length === 0) { grid.innerHTML = '<div class="col-span-2 text-center text-slate-400 py-8 italic">Cơ sở này hiện không có sản phẩm/dịch vụ nào.</div>'; return; }
                    customerProducts.forEach(prod => {
                        const ord = customerOrdered.find(o => o.SanPhamID === prod.SanPhamID);
                        const qty = ord ? ord.SoLuong : 0;
                        grid.insertAdjacentHTML("beforeend", `
                            <div class="p-4 bg-slate-50 border border-slate-100 rounded-2xl flex items-center justify-between shadow-sm">
                                <div class="flex-grow min-w-0 pr-4">
                                    <h4 class="font-bold text-slate-800 text-sm truncate">${prod.TenSanPham}</h4>
                                    <p class="text-xs text-slate-500 mt-0.5">${prod.DonGia.toLocaleString('vi-VN')} đ / ${prod.DonViTinh || 'cái'}</p>
                                    <p class="text-[10px] text-slate-500 font-semibold mt-1">Còn: ${prod.SoLuongTon}</p>
                                </div>
                                <div class="flex items-center gap-2 shrink-0">
                                    <input type="hidden" name="productId" value="${prod.SanPhamID}">
                                    <button type="button" onclick="adjustCustomerQty(${prod.SanPhamID}, -1)" class="w-8 h-8 rounded-lg bg-slate-200 hover:bg-slate-300 text-slate-700 font-bold flex items-center justify-center">-</button>
                                    <input type="number" name="quantity" id="cust-qty-${prod.SanPhamID}" value="${qty}" min="0" max="${prod.SoLuongTon}" class="w-12 text-center bg-white border border-slate-200 rounded-lg py-1 text-sm font-bold" readonly>
                                    <button type="button" onclick="adjustCustomerQty(${prod.SanPhamID}, 1)" class="w-8 h-8 rounded-lg bg-slate-200 hover:bg-slate-300 text-slate-700 font-bold flex items-center justify-center">+</button>
                                </div>
                            </div>`);
                    });
                    recalculateCustomerTotal();
                }).catch(err => { grid.innerHTML = '<div class="col-span-2 text-center text-red-500 py-8">Lỗi tải dữ liệu.</div>'; loading.classList.add("hidden"); container.classList.remove("hidden"); });
        }

        function adjustCustomerQty(spId, delta) {
            const input = document.getElementById(`cust-qty-\${spId}`);
            const prod = customerProducts.find(p => p.SanPhamID === spId);
            if (!input || !prod) return;
            let val = Math.max(0, Math.min((parseInt(input.value) || 0) + delta, prod.SoLuongTon));
            input.value = val; recalculateCustomerTotal();
        }

        function recalculateCustomerTotal() {
            let total = 0;
            customerProducts.forEach(p => { const i = document.getElementById(`cust-qty-\${p.SanPhamID}`); total += i ? (parseInt(i.value) || 0) * p.DonGia : 0; });
            document.getElementById("customer-service-total").textContent = total.toLocaleString('vi-VN') + " đ";
        }

        function closeCustomerServiceModal() {
            const modal = document.getElementById("customerServiceModal");
            modal.classList.add("opacity-0"); modal.querySelector(".bg-white").classList.add("scale-95");
            setTimeout(() => { modal.classList.add("hidden"); modal.classList.remove("flex"); }, 300);
        }
    </script>
</body>
</html>
