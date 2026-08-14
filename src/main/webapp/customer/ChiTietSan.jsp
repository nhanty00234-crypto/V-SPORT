<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi" class="scroll-smooth">
<head>
    <title>${san.tenSan} - V-SPORT</title>
    <jsp:include page="/common/head.jsp" />
    <%-- vsport-theme.jsp is kept only because bottom-nav.jsp (included at the end of this page)
         needs its --vs-bottomnav-h/--vs-ink layout tokens. Its RED --vs-primary-600 etc. are
         NOT used anywhere in this page's own styles below — those are plain hex now, on purpose,
         so the retired red brand can't leak in via var(--vs-*, fallback). --%>
    <jsp:include page="/customer/common/vsport-theme.jsp" />
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;700;800;900&family=Space+Mono:wght@700&display=swap" rel="stylesheet">
    <style>
        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }
        .material-symbols-outlined.filled {
            font-variation-settings: 'FILL' 1, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }
        h1, h2 { font-family: 'Be Vietnam Pro', sans-serif; }
        .vs-scoreboard { font-family: 'Space Mono', monospace; letter-spacing: .02em; }
        .vs-lbracket { position: relative; }
        .vs-lbracket::before, .vs-lbracket::after {
            content: ''; position: absolute; width: 22px; height: 22px; z-index: 10; pointer-events: none;
        }
        .vs-lbracket::before { top: 10px; left: 10px; border-top: 3px solid #fff; border-left: 3px solid #fff; opacity: .9; }
        .vs-lbracket::after { bottom: 10px; right: 10px; border-bottom: 3px solid #fff; border-right: 3px solid #fff; opacity: .9; }
        #tl-bar {
            position: relative;
            height: 44px;
            border-radius: 8px;
            background: #EAF3F2;
            border: 1.5px solid #DCEEEC;
            cursor: crosshair;
            user-select: none;
            overflow: visible;
        }
        .tl-drag-handle {
            position: absolute;
            top: 50%;
            transform: translate(-50%, -50%);
            width: 22px;
            height: 22px;
            background: white;
            border: 2.5px solid #0E6E6A;
            border-radius: 50%;
            cursor: ew-resize;
            z-index: 3;
            box-shadow: 0 1px 4px rgba(0,0,0,.2);
            touch-action: none;
            transition: transform 0.1s;
        }
        .tl-drag-handle:hover {
            transform: translate(-50%, -50%) scale(1.2);
        }
    </style>
</head>
<body class="bg-[#E9EDE7] text-[#12201B] font-sans antialiased min-h-screen flex flex-col">

    <jsp:include page="/common/header-xtra.jsp" />

    <main class="flex-grow pt-[80px] pb-24 lg:pb-16">
        <div class="w-full max-w-7xl mx-auto px-4 md:px-8 lg:px-12 py-6 md:py-8">

            <!-- Breadcrumbs -->
            <div class="flex flex-wrap items-center gap-1.5 text-[#3E4A44] text-xs font-semibold mb-5">
                <a href="${pageContext.request.contextPath}/customer/dat-san" class="hover:text-[#0E6E6A] transition-colors whitespace-nowrap">Tìm Sân</a>
                <span class="material-symbols-outlined text-[14px]">chevron_right</span>
                <a href="${pageContext.request.contextPath}/customer/dat-san" class="hover:text-[#0E6E6A] transition-colors whitespace-nowrap">Danh sách sân</a>
                <span class="material-symbols-outlined text-[14px]">chevron_right</span>
                <span class="text-[#12201B] font-bold truncate max-w-[160px] sm:max-w-none">${san.tenSan}</span>
            </div>

            <!-- Hero Gallery Bento -->
            <section class="grid grid-cols-1 md:grid-cols-4 md:grid-rows-2 gap-2 md:gap-3 h-[240px] md:h-[340px] mb-8 rounded-xl overflow-hidden">
                <div class="md:col-span-3 md:row-span-2 relative group cursor-pointer vs-lbracket">
                    <img src="${not empty san.hinhAnh ? san.hinhAnh : 'https://images.unsplash.com/photo-1575361204480-aadea25e6e68?q=80&w=1400'}"
                         alt="${san.tenSan}"
                         class="w-full h-full object-cover transition-transform duration-700 group-hover:scale-105">
                    <div class="absolute inset-0 bg-black/10 group-hover:bg-transparent transition-colors"></div>
                    <div class="absolute top-4 left-4">
                        <span class="px-3 py-1.5 rounded-full text-xs font-extrabold uppercase tracking-wider shadow backdrop-blur-md flex items-center gap-1.5
                              ${san.trangThai == 'Sẵn sàng' ? 'text-white' : 'bg-amber-500/90 text-white'}"
                              style="${san.trangThai == 'Sẵn sàng' ? 'background-color: rgba(22,163,106,0.9);' : ''}">
                            <span class="w-1.5 h-1.5 rounded-full bg-white animate-pulse"></span>
                            ${san.trangThai == 'Sẵn sàng' ? 'Trống sân' : 'Đang dùng'}
                        </span>
                    </div>
                    <button class="absolute bottom-4 right-4 bg-white/90 backdrop-blur-sm px-4 py-2 rounded-full text-xs font-semibold flex items-center gap-1.5 hover:bg-white transition-colors shadow-sm text-[#12201B]">
                        <span class="material-symbols-outlined text-[16px]">photo_library</span>
                        Xem tất cả ảnh
                    </button>
                </div>
                <div class="hidden md:block relative overflow-hidden group cursor-pointer">
                    <img src="${not empty san.hinhAnh ? san.hinhAnh : 'https://images.unsplash.com/photo-1544698310-74ea9d1c8258?q=80&w=600'}"
                         alt="${san.tenSan} - ảnh 2"
                         class="w-full h-full object-cover transition-transform duration-700 group-hover:scale-110 brightness-90">
                    <div class="absolute inset-0 bg-black/10 group-hover:bg-transparent transition-colors"></div>
                </div>
                <div class="hidden md:block relative overflow-hidden group cursor-pointer">
                    <img src="https://images.unsplash.com/photo-1528972042015-f4b8a57c5c3c?q=80&w=600"
                         alt="${san.tenSan} - ảnh 3"
                         class="w-full h-full object-cover transition-transform duration-700 group-hover:scale-110 brightness-90">
                    <div class="absolute inset-0 bg-black/10 group-hover:bg-transparent transition-colors"></div>
                </div>
            </section>

            <!-- Main Content — info column 2/3 + booking sidebar 1/3 -->
            <div class="flex flex-col lg:flex-row gap-6 lg:gap-10 items-start">

                <!-- INFO COLUMN (2/3) -->
                <div class="w-full lg:w-2/3 flex flex-col gap-8 lg:gap-10">

                    <!-- Header Info -->
                    <div>
                        <h1 class="text-xl sm:text-2xl md:text-3xl font-bold text-[#12201B] leading-tight mb-3">${san.tenSan}</h1>
                        <div class="flex flex-wrap items-center gap-x-3 gap-y-1.5 text-[#3E4A44] text-sm font-medium mb-4">
                            <div class="flex items-center gap-1">
                                <span class="material-symbols-outlined text-[16px] text-[#0E6E6A] filled">star</span>
                                <span class="text-[#5C6B64] text-xs sm:text-sm">${coSo.tenCoSo}</span>
                            </div>
                            <span class="text-[#A8B5AE] hidden sm:inline">•</span>
                            <div class="flex items-center gap-1 w-full sm:w-auto">
                                <span class="material-symbols-outlined text-[16px]">location_on</span>
                                <span class="text-xs sm:text-sm truncate">${coSo.diaChi}</span>
                            </div>
                        </div>
                        <div class="flex flex-wrap gap-1.5">
                            <span class="px-2.5 py-1 bg-[#0E6E6A]/10 text-[#0A5652] rounded font-semibold text-[11px] sm:text-xs">${tenMon}</span>
                            <span class="px-2.5 py-1 bg-[#0E6E6A]/10 text-[#0A5652] rounded font-semibold text-[11px] sm:text-xs">${loai.tenLoai}</span>
                            <span class="px-2.5 py-1 bg-[#0E6E6A]/10 text-[#0A5652] rounded font-semibold text-[11px] sm:text-xs">
                                ${coSo.gioMoCua != null ? coSo.gioMoCua : '06:00'} – ${coSo.gioDongCua != null ? coSo.gioDongCua : '23:00'}
                            </span>
                            <span class="px-2.5 py-1 bg-[#0E6E6A]/10 text-[#0A5652] rounded font-semibold text-[11px] sm:text-xs">${totalSimilarCourts} sân tương tự</span>
                        </div>
                    </div>

                    <hr class="border-[#E2E5E0]">

                    <!-- Description -->
                    <div>
                        <h2 class="text-lg sm:text-xl font-semibold text-[#12201B] mb-3">Giới thiệu sân</h2>
                        <p class="text-sm sm:text-base text-[#3E4A44] leading-relaxed">
                            ${not empty san.moTa ? san.moTa : 'Hệ thống sân đấu tiêu chuẩn với mặt sân cao cấp, hệ thống thoát nước tối ưu đảm bảo sân luôn khô ráo và bám tốt. Sân được trang bị hệ thống chiếu sáng LED chuyên nghiệp phục vụ thi đấu vào ban đêm. Thích hợp cho cả tập luyện phong trào và tổ chức các giải đấu quy mô vừa.'}
                        </p>
                    </div>

                    <hr class="border-[#E2E5E0]">

                    <!-- Amenities -->
                    <div>
                        <h2 class="text-lg sm:text-xl font-semibold text-[#12201B] mb-4 sm:mb-6">Tiện ích</h2>
                        <div class="grid grid-cols-2 md:grid-cols-3 gap-y-4 sm:gap-y-6 gap-x-3 sm:gap-x-4">
                            <div class="flex items-center gap-3 text-[#3E4A44]">
                                <span class="material-symbols-outlined text-[24px] text-[#0E6E6A]">wifi</span>
                                <span class="text-base">Wifi miễn phí</span>
                            </div>
                            <div class="flex items-center gap-3 text-[#3E4A44]">
                                <span class="material-symbols-outlined text-[24px] text-[#0E6E6A]">local_parking</span>
                                <span class="text-base">Bãi đỗ xe</span>
                            </div>
                            <div class="flex items-center gap-3 text-[#3E4A44]">
                                <span class="material-symbols-outlined text-[24px] text-[#0E6E6A]">lightbulb</span>
                                <span class="text-base">Đèn chiếu sáng</span>
                            </div>
                            <div class="flex items-center gap-3 text-[#3E4A44]">
                                <span class="material-symbols-outlined text-[24px] text-[#0E6E6A]">shower</span>
                                <span class="text-base">Phòng tắm</span>
                            </div>
                            <div class="flex items-center gap-3 text-[#3E4A44]">
                                <span class="material-symbols-outlined text-[24px] text-[#0E6E6A]">local_drink</span>
                                <span class="text-base">Nước uống</span>
                            </div>
                            <div class="flex items-center gap-3 text-[#3E4A44]">
                                <span class="material-symbols-outlined text-[24px] text-[#0E6E6A]">security</span>
                                <span class="text-base">Bảo vệ 24/7</span>
                            </div>
                        </div>
                    </div>

                    <hr class="border-[#E2E5E0]">

                    <!-- Location / Map -->
                    <div>
                        <h2 class="text-lg sm:text-xl font-semibold text-[#12201B] mb-2">Vị trí</h2>
                        <p class="text-base text-[#3E4A44] mb-4 flex items-center gap-1.5">
                            <span class="material-symbols-outlined text-[18px] text-[#0E6E6A]">location_on</span>
                            ${coSo.diaChi}
                        </p>
                        <div class="w-full h-44 sm:h-56 bg-[#EDEFEA] rounded-xl overflow-hidden border border-[#E2E5E0] shadow-sm">
                            <iframe
                                src="https://maps.google.com/maps?q=${coSo.diaChi}&output=embed&z=15"
                                class="w-full h-full border-0"
                                allowfullscreen=""
                                loading="lazy"
                                referrerpolicy="no-referrer-when-downgrade"
                                title="Bản đồ ${coSo.tenCoSo}">
                            </iframe>
                        </div>
                    </div>

                </div>

                <!-- BOOKING COLUMN / WIDGET (1/3) -->
                <div class="w-full lg:w-1/3">
                    <div class="sticky top-[100px] bg-white rounded-2xl border border-[#E2E5E0] shadow-lg p-5 sm:p-6 flex flex-col gap-5">
                        <div class="flex items-center justify-between border-b border-[#E2E5E0] pb-4">
                            <div>
                                <span class="text-xs text-[#5C6B64] block mb-0.5">Đơn giá ban ngày</span>
                                <span class="text-xl font-bold text-[#0E6E6A] vs-scoreboard"><fmt:formatNumber value="${loai.giaKhongDen}" pattern="#,##0"/> đ<span class="text-xs font-normal text-[#5C6B64]">/h</span></span>
                            </div>
                            <span class="px-2.5 py-1 rounded-full text-xs font-extrabold uppercase tracking-wider ${san.trangThai == 'Sẵn sàng' ? 'bg-emerald-100 text-emerald-800' : 'bg-amber-100 text-amber-800'}">
                                ${san.trangThai == 'Sẵn sàng' ? 'Sẵn sàng' : san.trangThai}
                            </span>
                        </div>

                        <form id="bookingForm" action="${pageContext.request.contextPath}/customer/dat-lich-truc-quan/xac-nhan" method="POST" class="flex flex-col gap-4">
                            <input type="hidden" name="sanId" value="${san.sanID}" />
                            <input type="hidden" name="coSoId" value="${san.coSoID}" />
                            <input type="hidden" id="ngayDat" name="ngayDat" value="" />
                            <input type="hidden" id="gioBatDau" name="gioBatDau" value="" />
                            <input type="hidden" id="gioKetThuc" name="gioKetThuc" value="" />

                            <!-- Date Selector -->
                            <div>
                                <label class="block text-xs font-bold text-[#12201B] mb-1.5 uppercase tracking-wider">Ngày đặt sân</label>
                                <div class="flex items-center justify-between bg-[#E9EDE7] border border-[#E2E5E0] rounded-xl p-1.5">
                                    <button type="button" id="prev-day-btn" onclick="prevDay()" class="p-1.5 text-[#3E4A44] hover:bg-white hover:shadow-sm rounded-lg transition-all disabled:opacity-30 disabled:pointer-events-none">
                                        <span class="material-symbols-outlined text-[18px]">chevron_left</span>
                                    </button>
                                    <span id="date-display" class="font-bold text-sm text-[#12201B]">---</span>
                                    <button type="button" id="next-day-btn" onclick="nextDay()" class="p-1.5 text-[#3E4A44] hover:bg-white hover:shadow-sm rounded-lg transition-all">
                                        <span class="material-symbols-outlined text-[18px]">chevron_right</span>
                                    </button>
                                </div>
                            </div>

                            <!-- Timeline Bar -->
                            <div>
                                <div class="flex items-center justify-between mb-1.5">
                                    <label class="text-xs font-bold text-[#12201B] uppercase tracking-wider">Khung giờ đặt</label>
                                    <span id="tl-hint" class="text-[11px] text-[#5C6B64] italic">Nhấn vào thanh để chọn</span>
                                </div>
                                <div id="tl-bar" class="w-full"></div>
                                <div id="tl-labels" class="flex justify-between text-[10px] text-[#5C6B64] mt-1 px-1"></div>
                                <div id="tl-selection-display" class="hidden mt-2 p-2 bg-[#0E6E6A]/10 border border-[#0E6E6A]/20 rounded-lg text-center text-xs font-bold text-[#0E6E6A]">
                                    <span id="tl-sel-text"></span>
                                </div>
                            </div>

                            <!-- Overlap Warning -->
                            <div id="overlap-warning" class="hidden p-3 bg-red-50 border border-red-200 rounded-xl text-xs text-red-600 font-medium flex items-center gap-2">
                                <span class="material-symbols-outlined text-[18px]">error</span>
                                <span>Khung giờ bị trùng lịch hoặc không khả dụng.</span>
                            </div>

                            <!-- Price Breakdown Container -->
                            <div id="price-breakdown" class="hidden flex-col gap-2 p-3.5 bg-[#E9EDE7] border border-[#E2E5E0] rounded-xl text-xs">
                                <div class="font-bold text-[#12201B] border-b border-[#E2E5E0] pb-1.5 flex justify-between items-center">
                                    <span>Chi tiết giá</span>
                                    <span id="price-loading-badge" class="hidden text-[10px] text-amber-600 font-semibold animate-pulse">Đang tính giá...</span>
                                </div>
                                <div id="price-error-box" class="hidden text-red-600 font-medium text-[11px] p-2 bg-red-50 border border-red-200 rounded-lg"></div>
                                <div id="price-details-list" class="flex flex-col gap-1.5 text-[#3E4A44]">
                                    <!-- JS renders breakdown lines here -->
                                </div>
                                <div class="border-t border-[#E2E5E0] pt-2 mt-1 flex justify-between items-center font-bold text-sm text-[#12201B]">
                                    <span>Tổng cộng:</span>
                                    <span id="price-total" class="text-[#0E6E6A] text-base vs-scoreboard">0 đ</span>
                                </div>
                            </div>

                            <!-- Submit CTA Button -->
                            <button type="submit" id="btn-submit-booking" disabled
                                    class="w-full py-3 bg-[#0E6E6A] text-white font-bold text-sm rounded-xl hover:bg-[#0A5652] disabled:opacity-40 disabled:cursor-not-allowed transition-all shadow-sm flex items-center justify-center gap-2">
                                <span class="material-symbols-outlined text-[18px]">event_available</span>
                                Tiếp tục đặt sân
                            </button>
                        </form>
                    </div>
                </div>

            </div><!-- end main content -->

        </div><!-- end container -->

        <!-- OTHER COURTS SECTION -->
        <div class="w-full max-w-7xl mx-auto px-4 md:px-8 lg:px-12 mt-10 md:mt-16">
            <div class="bg-white p-4 sm:p-6 md:p-8 rounded-xl border border-[#E2E5E0] shadow-sm">
                <h2 class="text-lg sm:text-xl font-bold text-[#12201B] mb-4 sm:mb-6 flex items-center gap-2">
                    <span class="material-symbols-outlined text-[22px] text-[#0E6E6A]">sports_tennis</span>
                    Các sân đấu khác dành cho bạn
                </h2>
                <!-- Horizontal scroll on mobile, grid on larger -->
                <div class="flex gap-4 overflow-x-auto pb-2 sm:pb-0 sm:grid sm:grid-cols-2 lg:grid-cols-4 sm:gap-5 -mx-4 px-4 sm:mx-0 sm:px-0 snap-x snap-mandatory">
                    <c:forEach var="os" items="${otherSans}" varStatus="loop">
                        <c:if test="${loop.index < 4}">
                            <c:set var="osCoSoName" value="Cơ Sở" />
                            <c:forEach var="cs" items="${dsCoSo}">
                                <c:if test="${cs.coSoID == os.coSoID}">
                                    <c:set var="osCoSoName" value="${cs.tenCoSo}" />
                                </c:if>
                            </c:forEach>
                            <c:set var="osTypeName" value="Chưa phân loại" />
                            <c:set var="osPrice" value="0" />
                            <c:set var="osSportId" value="0" />
                            <c:forEach var="ls" items="${dsLoaiSan}">
                                <c:if test="${ls.loaiSanID == os.loaiSanID}">
                                    <c:set var="osTypeName" value="${ls.tenLoai}" />
                                    <c:set var="osPrice" value="${ls.giaKhongDen}" />
                                    <c:set var="osSportId" value="${ls.monTheThaoID}" />
                                </c:if>
                            </c:forEach>
                            <c:set var="osSportName" value="Khác" />
                            <c:forEach var="m" items="${dsMon}">
                                <c:if test="${m.monTheThaoID == osSportId}">
                                    <c:set var="osSportName" value="${m.tenMon}" />
                                </c:if>
                            </c:forEach>

                            <div class="bg-[#E9EDE7] border border-[#E2E5E0] rounded-xl overflow-hidden flex flex-col transition-all duration-300 hover:shadow-md hover:-translate-y-1 shrink-0 w-[220px] sm:w-auto snap-start">
                                <a href="${pageContext.request.contextPath}/customer/chi-tiet-san?id=${os.sanID}" class="block group hover:no-underline">
                                    <div class="relative h-[130px] overflow-hidden bg-[#EDEFEA]">
                                        <img src="${not empty os.hinhAnh ? os.hinhAnh : 'https://images.unsplash.com/photo-1544698310-74ea9d1c8258?q=80&w=600'}"
                                             alt="${os.tenSan}"
                                             class="w-full h-full object-cover transition-transform duration-500 group-hover:scale-105">
                                        <span class="absolute top-2 right-2 px-2 py-0.5 rounded bg-black/60 text-white text-[9px] font-bold uppercase tracking-wider backdrop-blur-sm">${osSportName}</span>
                                    </div>
                                    <div class="p-4 space-y-1.5">
                                        <h4 class="font-bold text-[#12201B] text-sm truncate group-hover:text-[#0E6E6A] transition-colors">${os.tenSan}</h4>
                                        <p class="text-xs text-[#5C6B64] flex items-center gap-1">
                                            <span class="material-symbols-outlined text-[13px]">location_on</span>
                                            ${osCoSoName}
                                        </p>
                                        <p class="text-[11px] text-[#5C6B64] italic truncate">${osTypeName}</p>
                                    </div>
                                </a>
                                <div class="px-4 pb-4 pt-0 flex items-center justify-between border-t border-[#E2E5E0] mt-auto">
                                    <span class="text-sm font-bold text-[#0E6E6A]"><fmt:formatNumber value="${osPrice}" pattern="#,##0"/> đ<span class="text-[10px] font-normal text-[#5C6B64]">/h</span></span>
                                    <a href="${pageContext.request.contextPath}/customer/chi-tiet-san?id=${os.sanID}"
                                       class="px-3 py-1.5 bg-[#0E6E6A] text-white rounded-lg text-[11px] font-semibold hover:bg-[#0A5652] hover:no-underline transition-all">
                                        Xem sân
                                    </a>
                                </div>
                            </div>
                        </c:if>
                    </c:forEach>
                </div>
            </div>
        </div>

    </main>

    <!-- Sticky bottom CTA -->
    <div class="fixed bottom-0 left-0 right-0 bg-white/95 backdrop-blur-sm border-t border-[#E2E5E0] px-4 py-3 flex items-center justify-between z-40 shadow-[0_-2px_12px_rgba(0,0,0,0.08)]">
        <div class="flex flex-col">
            <span class="text-base font-bold text-[#12201B] vs-scoreboard"><fmt:formatNumber value="${loai.giaKhongDen}" pattern="#,##0"/> đ<span class="text-xs font-normal text-[#5C6B64]">/giờ</span></span>
            <span class="text-[10px] text-[#5C6B64]">${san.trangThai == 'Sẵn sàng' ? 'Còn trống' : 'Đang dùng'}</span>
        </div>
        <%-- Was: linked out to DatLichTrucQuan.jsp's old full-page flow. This page already has
             its own real booking widget (#bookingForm below) — just scroll to it. --%>
        <a href="#bookingForm"
           class="px-5 py-2.5 bg-[#D6572B] text-white font-semibold text-sm rounded-xl hover:bg-[#B8431E] active:scale-95 transition-all shadow-sm flex items-center gap-1.5">
            <span class="material-symbols-outlined text-[16px]">sports_soccer</span>
            Đặt Sân
        </a>
    </div>

    <jsp:include page="/common/footer.jsp" />

    <script>
        const branchOpenTime  = "${coSo.gioMoCua  != null ? coSo.gioMoCua  : '06:00'}";
        const branchCloseTime = "${coSo.gioDongCua != null ? coSo.gioDongCua : '23:00'}";
        const pricePerHour    = parseFloat("${loai.giaKhongDen != null ? loai.giaKhongDen : 0}");

        const activeBookings = [
            <c:forEach var="b" items="${activeBookings}">
                <c:if test="${b.sanId == san.sanID && b.trangThai != 'Đã hủy'}">
                    { id: ${b.datSanId}, date: "${b.ngayDat}", start: "${b.gioBatDau}", end: "${b.gioKetThuc}", status: "${b.trangThai}" },
                </c:if>
            </c:forEach>
        ];

        // ── Constants ──────────────────────────────────────────────────
        const openMin  = timeToMinutes(branchOpenTime);
        const closeMin = timeToMinutes(branchCloseTime);

        // ── Date state ─────────────────────────────────────────────────
        const todayBase = new Date();
        todayBase.setHours(0, 0, 0, 0);
        const todayStr = fmtDateStr(todayBase);

        let currentDate = new Date(todayBase);

        // ── Time-picker state ──────────────────────────────────────────
        let selectedStartMin = null;
        let selectedEndMin   = null;

        // ── Timeline drag state ────────────────────────────────────────
        let tlDragging = false;
        let tlDragSide = null; // 'start' | 'end'

        // ── Helpers ────────────────────────────────────────────────────
        function timeToMinutes(t) {
            const p = t.split(":");
            return parseInt(p[0], 10) * 60 + parseInt(p[1], 10);
        }

        function minToStr(m) {
            return String(Math.floor(m / 60)).padStart(2, "0") + ":" + String(m % 60).padStart(2, "0");
        }

        function formatDuration(mins) {
            const h = Math.floor(mins / 60), m = mins % 60;
            return (h > 0 ? h + " tiếng " : "") + (m > 0 ? m + " phút" : "");
        }

        function fmtDateStr(d) {
            return d.getFullYear() + "-" + String(d.getMonth() + 1).padStart(2, "0") + "-" + String(d.getDate()).padStart(2, "0");
        }

        function fmtDateDisplay(d) {
            const days = ["CN", "T2", "T3", "T4", "T5", "T6", "T7"];
            return days[d.getDay()] + ", " + String(d.getDate()).padStart(2, "0") + "/" +
                   String(d.getMonth() + 1).padStart(2, "0") + "/" + d.getFullYear();
        }

        // ── Date navigation ────────────────────────────────────────────
        function updateDateUI() {
            document.getElementById("date-display").textContent = fmtDateDisplay(currentDate);
            document.getElementById("ngayDat").value = fmtDateStr(currentDate);
            document.getElementById("prev-day-btn").disabled = fmtDateStr(currentDate) === todayStr;
        }

        function prevDay() {
            const d = new Date(currentDate);
            d.setDate(d.getDate() - 1);
            if (fmtDateStr(d) < todayStr) return;
            currentDate = d;
            resetSelection();
            updateDateUI();
            renderTimeline();
        }

        function nextDay() {
            const d = new Date(currentDate);
            d.setDate(d.getDate() + 1);
            currentDate = d;
            resetSelection();
            updateDateUI();
            renderTimeline();
        }

        // ── Selection ──────────────────────────────────────────────────
        function resetSelection() {
            selectedStartMin = null;
            selectedEndMin   = null;
            document.getElementById("gioBatDau").value = "";
            document.getElementById("gioKetThuc").value = "";
            renderTimeline();
            updatePriceBreakdown();
            checkSchedule();
        }

        function commitSelection() {
            document.getElementById("gioBatDau").value = selectedStartMin !== null ? minToStr(selectedStartMin) : "";
            document.getElementById("gioKetThuc").value = selectedEndMin !== null ? minToStr(selectedEndMin) : "";
        }

        // ── Timeline: coordinate ↔ minute ─────────────────────────────
        function minToPct(min) {
            return ((min - openMin) / (closeMin - openMin)) * 100;
        }

        function pctToMin(pct) {
            const raw = openMin + Math.max(0, Math.min(1, pct)) * (closeMin - openMin);
            return Math.round(raw / 30) * 30;
        }

        function getBarPct(e) {
            const bar  = document.getElementById("tl-bar");
            const rect = bar.getBoundingClientRect();
            const clientX = e.touches ? e.touches[0].clientX : e.clientX;
            return (clientX - rect.left) / rect.width;
        }

        function getConflicts() {
            return activeBookings.filter(b => b.date === fmtDateStr(currentDate));
        }

        function isMinBooked(min) {
            return getConflicts().some(b => min >= timeToMinutes(b.start) && min < timeToMinutes(b.end));
        }

        function isMinPast(min) {
            if (fmtDateStr(currentDate) !== todayStr) return false;
            const n = new Date();
            return min < n.getHours() * 60 + n.getMinutes();
        }

        function hasRangeConflict(startM, endM) {
            return getConflicts().some(b => {
                const bs = timeToMinutes(b.start), be = timeToMinutes(b.end);
                return startM < be && endM > bs;
            });
        }

        // ── Timeline render ────────────────────────────────────────────
        function renderTimeline() {
            const bar = document.getElementById("tl-bar");
            bar.innerHTML = "";

            // Past overlay (today only)
            if (fmtDateStr(currentDate) === todayStr) {
                const n = new Date();
                const nowMin = n.getHours() * 60 + n.getMinutes();
                if (nowMin > openMin) {
                    const w = minToPct(Math.min(nowMin, closeMin));
                    const el = mkDiv("position:absolute;top:0;bottom:0;left:0;width:" + w + "%;background:rgba(0,0,0,0.07);border-radius:6px 0 0 6px;pointer-events:none;");
                    bar.appendChild(el);
                }
            }

            // Booked segments
            getConflicts().forEach(function(b) {
                const bs   = timeToMinutes(b.start), be = timeToMinutes(b.end);
                const left = minToPct(bs);
                const w    = minToPct(be) - left;
                const el   = mkDiv("position:absolute;top:2px;bottom:2px;left:" + left + "%;width:" + w + "%;background:#fecaca;border-radius:4px;pointer-events:none;");
                el.title   = "Đã đặt: " + b.start + " – " + b.end;
                bar.appendChild(el);
            });

            // Hour tick marks
            for (var m = openMin; m <= closeMin; m += 60) {
                const tick = mkDiv("position:absolute;top:0;bottom:0;left:" + minToPct(m) + "%;width:1px;background:rgba(0,0,0,0.06);pointer-events:none;");
                bar.appendChild(tick);
            }

            // Selection or pending-start marker
            if (selectedStartMin !== null && selectedEndMin !== null) {
                const left = minToPct(selectedStartMin);
                const w    = minToPct(selectedEndMin) - left;

                const sel = mkDiv("position:absolute;top:0;bottom:0;left:" + left + "%;width:" + w + "%;background:#0E6E6A;border-radius:6px;opacity:0.85;pointer-events:none;");
                bar.appendChild(sel);

                // Drag handles
                [["start", left], ["end", left + w]].forEach(function(pair) {
                    const h = document.createElement("div");
                    h.className    = "tl-drag-handle";
                    h.style.left   = pair[1] + "%";
                    h.dataset.side = pair[0];
                    bar.appendChild(h);
                });

            } else if (selectedStartMin !== null) {
                // Pending-start: show vertical marker + tooltip
                const left = minToPct(selectedStartMin);

                const marker = mkDiv("position:absolute;top:0;bottom:0;left:" + left + "%;width:3px;background:#0E6E6A;border-radius:2px;transform:translateX(-50%);pointer-events:none;");
                bar.appendChild(marker);

                const tip = mkDiv("position:absolute;bottom:calc(100% + 5px);left:" + left + "%;transform:translateX(-50%);background:#0E6E6A;color:white;font-size:10px;padding:2px 7px;border-radius:4px;white-space:nowrap;pointer-events:none;");
                tip.textContent = minToStr(selectedStartMin);
                bar.appendChild(tip);
            }

            updateHint();
            updateSelectionDisplay();
        }

        function mkDiv(css) {
            const d = document.createElement("div");
            d.style.cssText = css;
            return d;
        }

        function updateHint() {
            const hint = document.getElementById("tl-hint");
            if (selectedStartMin === null) {
                hint.textContent = "Nhấn vào thanh để chọn giờ bắt đầu";
            } else if (selectedEndMin === null) {
                hint.textContent = "Nhấn tiếp để chọn giờ kết thúc";
            } else {
                hint.textContent = "Kéo hai đầu để điều chỉnh";
            }
        }

        function updateSelectionDisplay() {
            const disp = document.getElementById("tl-selection-display");
            if (selectedStartMin !== null && selectedEndMin !== null) {
                const dur = selectedEndMin - selectedStartMin;
                document.getElementById("tl-sel-text").textContent =
                    minToStr(selectedStartMin) + " – " + minToStr(selectedEndMin) + " · " + formatDuration(dur);
                disp.classList.remove("hidden");
            } else {
                disp.classList.add("hidden");
            }
        }

        // ── Timeline interaction ───────────────────────────────────────
        function onBarPointerDown(e) {
            // If clicking on a drag handle, start handle drag
            if (e.target.classList.contains("tl-drag-handle")) {
                tlDragSide  = e.target.dataset.side;
                tlDragging  = true;
                if (e.cancelable) e.preventDefault();
                return;
            }

            const clickedMin = pctToMin(getBarPct(e));

            // Ignore clicks outside valid range or on blocked slots
            if (clickedMin < openMin || clickedMin >= closeMin) return;
            if (isMinBooked(clickedMin) || isMinPast(clickedMin)) return;

            if (selectedStartMin === null || selectedEndMin !== null) {
                // New selection: set start only
                selectedStartMin = clickedMin;
                selectedEndMin   = null;
            } else {
                // Second click: set end
                if (clickedMin <= selectedStartMin) {
                    // Clicked at or before start → move start
                    selectedStartMin = clickedMin;
                } else {
                    // Clamp to first booked slot after start
                    let end = clickedMin;
                    getConflicts().forEach(b => {
                        const bs = timeToMinutes(b.start);
                        if (bs > selectedStartMin && bs < end) end = bs;
                    });
                    selectedEndMin = end;
                }
            }

            commitSelection();
            renderTimeline();
            updatePriceBreakdown();
            checkSchedule();
            if (e.cancelable) e.preventDefault();
        }

        function onDocPointerMove(e) {
            if (!tlDragging) return;
            const newMin = Math.max(openMin, Math.min(closeMin, pctToMin(getBarPct(e))));

            if (tlDragSide === "start") {
                if (selectedEndMin !== null && newMin < selectedEndMin - 30 &&
                    !hasRangeConflict(newMin, selectedEndMin) && !isMinPast(newMin)) {
                    selectedStartMin = newMin;
                }
            } else if (tlDragSide === "end") {
                if (newMin > selectedStartMin + 30 &&
                    !hasRangeConflict(selectedStartMin, newMin)) {
                    selectedEndMin = newMin;
                }
            }

            commitSelection();
            renderTimeline();
            updatePriceBreakdown();
            if (e.cancelable) e.preventDefault();
        }

        function onDocPointerUp() {
            if (!tlDragging) return;
            tlDragging = false;
            tlDragSide = null;
            checkSchedule();
        }

        // ── Hour labels ────────────────────────────────────────────────
        function renderTlLabels() {
            const container = document.getElementById("tl-labels");
            container.innerHTML = "";
            const step = window.innerWidth < 480 ? 120 : window.innerWidth < 640 ? 90 : 60;
            for (let m = openMin; m <= closeMin; m += step) {
                const span = document.createElement("span");
                span.textContent = minToStr(m);
                container.appendChild(span);
            }
        }
        window.addEventListener("resize", renderTlLabels);

        // ── Server-side Price Breakdown API with AbortController & Debounce ────
        let priceAbortController = null;
        let priceDebounceTimer   = null;
        let isPriceApiValid      = false;

        function formatMoney(v) {
            return Number(v || 0).toLocaleString("vi-VN") + " đ";
        }

        function updatePriceBreakdown() {
            const breakdown      = document.getElementById("price-breakdown");
            const loadingBadge   = document.getElementById("price-loading-badge");
            const errorBox       = document.getElementById("price-error-box");
            const detailsList    = document.getElementById("price-details-list");
            const totalEl        = document.getElementById("price-total");
            const btnSubmit      = document.getElementById("btn-submit-booking");

            // Cancel any pending request & debounce timer
            if (priceDebounceTimer) clearTimeout(priceDebounceTimer);
            if (priceAbortController) {
                priceAbortController.abort();
                priceAbortController = null;
            }

            isPriceApiValid = false;

            if (selectedStartMin === null || selectedEndMin === null) {
                breakdown.classList.add("hidden");
                breakdown.classList.remove("flex");
                if (btnSubmit) btnSubmit.disabled = true;
                return;
            }

            // Show breakdown panel with loading state
            breakdown.classList.remove("hidden");
            breakdown.classList.add("flex");
            loadingBadge.classList.remove("hidden");
            errorBox.classList.add("hidden");
            errorBox.textContent = "";
            if (btnSubmit) btnSubmit.disabled = true;

            // Debounce 150ms to prevent spamming server during drag
            priceDebounceTimer = setTimeout(function() {
                const dateStr  = fmtDateStr(currentDate);
                const startStr = minToStr(selectedStartMin);
                const endStr   = minToStr(selectedEndMin);

                priceAbortController = new AbortController();
                const signal = priceAbortController.signal;

                const url = "${pageContext.request.contextPath}/customer/api/timetable-price" +
                    "?sanId=${san.sanID}" +
                    "&date=" + encodeURIComponent(dateStr) +
                    "&start=" + encodeURIComponent(startStr) +
                    "&end=" + encodeURIComponent(endStr);

                fetch(url, { signal: signal, headers: { 'Accept': 'application/json' } })
                    .then(function(resp) {
                        if (!resp.ok) {
                            return resp.json().then(function(errJson) {
                                throw new Error(errJson.error || ("Lỗi server (" + resp.status + ")"));
                            }).catch(function() {
                                throw new Error("Không thể kết nối máy tính giá (" + resp.status + ").");
                            });
                        }
                        return resp.json();
                    })
                    .then(function(data) {
                        loadingBadge.classList.add("hidden");
                        if (!data || !data.success) {
                            throw new Error((data && data.error) ? data.error : "Tính giá thất bại.");
                        }

                        // Build breakdown rows
                        detailsList.innerHTML = "";

                        if (data.minutesWithoutLight > 0) {
                            const row = document.createElement("div");
                            row.className = "flex justify-between items-center";
                            row.innerHTML = "<span>Không đèn (" + data.minutesWithoutLight + " phút × " + formatMoney(data.rateWithoutLight) + "/h):</span>" +
                                            "<span class='font-semibold text-[#12201B]'>" + formatMoney(data.amountWithoutLight) + "</span>";
                            detailsList.appendChild(row);
                        }

                        if (data.minutesWithLight > 0) {
                            const row = document.createElement("div");
                            row.className = "flex justify-between items-center text-amber-700";
                            row.innerHTML = "<span class='flex items-center gap-1'><span class='material-symbols-outlined text-[14px]'>lightbulb</span>Có đèn (" + data.minutesWithLight + " phút × " + formatMoney(data.rateWithLight) + "/h):</span>" +
                                            "<span class='font-semibold'>" + formatMoney(data.amountWithLight) + "</span>";
                            detailsList.appendChild(row);
                        }

                        totalEl.textContent = formatMoney(data.totalAmount);
                        isPriceApiValid = true;
                        checkSchedule();
                    })
                    .catch(function(err) {
                        if (err.name === 'AbortError') return; // Cancelled request, ignore
                        loadingBadge.classList.add("hidden");
                        errorBox.textContent = err.message || "Lỗi khi tính giá sân.";
                        errorBox.classList.remove("hidden");
                        detailsList.innerHTML = "";
                        totalEl.textContent = "0 đ";
                        isPriceApiValid = false;
                        if (btnSubmit) btnSubmit.disabled = true;
                    });
            }, 150);
        }

        // ── Overlap & Submit validation ────────────────────────────────
        function checkSchedule() {
            const btnSubmit  = document.getElementById("btn-submit-booking");
            const warningBox = document.getElementById("overlap-warning");

            if (selectedStartMin === null || selectedEndMin === null) {
                if (btnSubmit) btnSubmit.disabled = true;
                warningBox.classList.add("hidden");
                return;
            }

            if (hasRangeConflict(selectedStartMin, selectedEndMin)) {
                warningBox.classList.remove("hidden");
                if (btnSubmit) btnSubmit.disabled = true;
            } else {
                warningBox.classList.add("hidden");
                if (btnSubmit) btnSubmit.disabled = !isPriceApiValid;
            }
        }

        // ── Payment method toggle ──────────────────────────────────────
        function changePayMethod(method) {
            const activeClass   = "pay-opt border-2 border-[#0E6E6A] bg-[#0E6E6A]/10 rounded-lg p-2.5 flex items-center justify-center cursor-pointer font-semibold text-xs text-[#0E6E6A] active:scale-95 transition-all";
            const inactiveClass = "pay-opt border-2 border-[#E2E5E0] rounded-lg p-2.5 flex items-center justify-center cursor-pointer font-semibold text-xs text-[#5C6B64] hover:border-[#A8B5AE] active:scale-95 transition-all";
            document.getElementById("lbl-opt-sau").className   = method === "sau"   ? activeClass : inactiveClass;
            document.getElementById("lbl-opt-payos").className = method === "payos" ? activeClass : inactiveClass;
        }

        // ── Init ───────────────────────────────────────────────────────
        updateDateUI();
        renderTlLabels();
        renderTimeline();

        const tlBar = document.getElementById("tl-bar");
        tlBar.addEventListener("mousedown",  onBarPointerDown);
        tlBar.addEventListener("touchstart", onBarPointerDown, { passive: false });
        document.addEventListener("mousemove",  onDocPointerMove);
        document.addEventListener("mouseup",    onDocPointerUp);
        document.addEventListener("touchmove",  onDocPointerMove, { passive: false });
        document.addEventListener("touchend",   onDocPointerUp);
    </script>
<jsp:include page="/customer/common/bottom-nav.jsp" />
</body>
</html>
