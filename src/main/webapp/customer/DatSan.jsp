<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%
    // Trang này phải được servlet nạp dữ liệu trước khi render
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
    <title>Đặt Sân - V-SPORT Elite Arena</title>
    <jsp:include page="/common/head.jsp" />
    <style>
        .filter-btn.active,
        .branch-filter-btn.active {
            background-color: #16a34a !important;
            color: white !important;
            border-color: #16a34a !important;
        }
        .filter-btn:not(.active):hover,
        .branch-filter-btn:not(.active):hover {
            background-color: #f8fafc !important;
        }
        .court-card {
            transition: all 0.2s ease-in-out;
        }
        .court-card:hover {
            box-shadow: 0 10px 25px rgba(0,0,0,0.05);
            transform: translateY(-2px);
            border-color: rgba(22, 163, 74, 0.2);
        }
        .form-input {
            width: 100%;
            padding: 0.75rem 1rem;
            background-color: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            color: #1e293b;
            transition: all 0.2s ease;
            font-size: 0.9375rem;
        }
        .form-input:focus {
            border-color: #16a34a;
            box-shadow: 0 0 0 3px rgba(22, 163, 74, 0.1);
            outline: none;
            background-color: white;
        }
        .form-label {
            display: block;
            font-size: 0.75rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            color: #64748b;
            margin-bottom: 0.5rem;
        }
    </style>
</head>
<body class="bg-[#f4f6f8] text-[#1e293b] min-h-screen flex flex-col antialiased">

    <jsp:include page="/common/header.jsp" />

    <main class="flex-grow pt-[120px] pb-24">
        <div class="max-w-[1600px] mx-auto px-4 sm:px-6 lg:px-8">
            
            <!-- Premium Search & Location Banner -->
            <div class="mb-10 bg-gradient-to-r from-green-600 via-emerald-600 to-teal-600 rounded-3xl p-8 sm:p-12 text-white shadow-xl relative overflow-hidden animate-fade-in-up">
                <!-- Decorative background elements -->
                <div class="absolute -right-10 -bottom-10 w-40 h-40 bg-white/10 rounded-full blur-2xl"></div>
                <div class="absolute -left-10 -top-10 w-40 h-40 bg-white/10 rounded-full blur-2xl"></div>
                
                <div class="relative z-10 max-w-2xl">
                    <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-white/20 text-xs font-semibold uppercase tracking-wider mb-4 backdrop-blur-md">
                        <i class="fa-solid fa-bolt"></i> Đặt sân nhanh chóng
                    </span>
                    <h1 class="text-3xl sm:text-5xl font-extrabold tracking-tight mb-3">Tìm & Đặt Sân Đấu</h1>
                    <p class="text-white/80 text-sm sm:text-base leading-relaxed">
                        Khám phá hệ thống sân bãi hiện đại, lịch đặt cập nhật trực tiếp theo thời gian thực và nhiều tiện ích đi kèm.
                    </p>
                    <c:if test="${sessionScope.user != null}">
                        <div class="mt-5">
                            <button type="button" onclick="openHistoryModal()" class="inline-flex items-center gap-2 px-5 py-3.5 rounded-xl bg-white text-emerald-700 font-bold text-xs shadow-md hover:bg-emerald-50 hover:shadow-lg hover:-translate-y-0.5 transition-all active:scale-95 duration-250">
                                <span class="material-symbols-outlined text-[18px]">history</span>
                                Lịch sử đặt sân của tôi
                            </button>
                        </div>
                    </c:if>
                </div>
            </div>

            <!-- Alert Messages -->
            <c:if test="${not empty sessionScope.error}">
                <div class="mb-6 p-4 bg-red-50 border border-red-100 rounded-xl text-red-600 text-sm flex items-start gap-3 shadow-sm animate-fade-in-up">
                    <span class="material-symbols-outlined text-[20px] shrink-0">error</span>
                    <div>
                        <span class="font-bold block">Đặt sân không thành công</span>
                        <span class="text-red-600/80 leading-normal block mt-0.5">${sessionScope.error}</span>
                    </div>
                    <% session.removeAttribute("error"); %>
                </div>
            </c:if>

            <c:if test="${not empty sessionScope.message}">
                <div class="mb-6 p-4 bg-green-50 border border-green-200 rounded-xl text-green-700 text-sm flex items-start gap-3 shadow-sm animate-fade-in-up">
                    <span class="material-symbols-outlined text-[20px] shrink-0">check_circle</span>
                    <div>
                        <span class="font-bold block">Thành công</span>
                        <span class="text-green-700/80 leading-normal block mt-0.5">${sessionScope.message}</span>
                    </div>
                    <% session.removeAttribute("message"); %>
                </div>
            </c:if>

            <!-- Main Layout Grid (Sidebar + List) -->
            <div class="grid grid-cols-1 lg:grid-cols-4 gap-8 items-start">
                
                <!-- LEFT SIDEBAR: Filters -->
                <div class="lg:col-span-1 space-y-6 lg:sticky lg:top-[120px] animate-fade-in-up">
                    
                    <!-- Location Filter & Search -->
                    <div class="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
                        <div class="px-5 py-4 border-b border-slate-100 flex justify-between items-center bg-slate-50">
                            <h3 class="font-bold text-slate-800 flex items-center gap-2">
                                <span class="material-symbols-outlined text-[20px] text-green-600">location_on</span>
                                Khu vực & Vị trí
                            </h3>
                        </div>
                        <div class="p-4 space-y-3">
                            <div class="relative">
                                <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 text-[20px]">search</span>
                                <input type="text" id="location-search-input" placeholder="Nhập quận, huyện, cơ sở..." class="w-full pl-10 pr-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-[14px] font-medium text-slate-700 placeholder-slate-400 focus:outline-none focus:border-green-500 focus:bg-white transition-all">
                            </div>
                            
                            <button type="button" id="btn-auto-locate" class="w-full flex items-center justify-center gap-2 px-4 py-2.5 bg-green-50 hover:bg-green-100 border border-green-200 hover:border-green-300 text-green-700 rounded-xl text-[14px] font-semibold transition-all">
                                <span id="locate-icon" class="material-symbols-outlined text-[18px]">my_location</span>
                                <span id="locate-text">Xác định vị trí hiện tại</span>
                            </button>
                        </div>
                    </div>
                    
                    <!-- Sport Type Filter -->
                    <div class="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
                        <div class="px-5 py-4 border-b border-slate-100 flex justify-between items-center bg-slate-50">
                            <h3 class="font-bold text-slate-800">Môn thể thao</h3>
                        </div>
                        <div class="p-3 flex flex-col gap-1">
                            <button type="button" onclick="filterSport(0)" id="btn-sport-0" class="filter-btn active w-full px-4 py-2.5 rounded-xl text-[14px] font-medium text-left flex items-center gap-3 transition-colors hover:bg-slate-50">
                                <span class="material-symbols-outlined text-[20px]">apps</span>
                                Tất cả
                            </button>
                            <c:forEach var="mon" items="${dsMon}">
                                <button type="button" onclick="filterSport(${mon.monTheThaoID})" id="btn-sport-${mon.monTheThaoID}" class="filter-btn w-full px-4 py-2.5 rounded-xl text-[14px] font-medium text-slate-600 text-left flex items-center gap-3 transition-colors hover:bg-slate-50">
                                    <span class="material-symbols-outlined text-[20px]">
                                        <c:choose>
                                            <c:when test="${mon.tenMon == 'Bóng đá'}">sports_soccer</c:when>
                                            <c:when test="${mon.tenMon == 'Cầu lông'}">sports_tennis</c:when>
                                            <c:when test="${mon.tenMon == 'Pickleball'}">sports_tennis</c:when>
                                            <c:when test="${mon.tenMon == 'Tennis'}">sports_tennis</c:when>
                                            <c:otherwise>sports_volleyball</c:otherwise>
                                        </c:choose>
                                    </span>
                                    ${mon.tenMon}
                                </button>
                            </c:forEach>
                        </div>
                    </div>

                    <!-- Branch Filter -->
                    <div class="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden bg-slate-50">
                        <div class="px-5 py-4 border-b border-slate-100 flex justify-between items-center bg-slate-50">
                            <h3 class="font-bold text-slate-800">Chọn Cơ Sở</h3>
                        </div>
                        <div class="p-3 flex flex-col gap-1 bg-white">
                            <button type="button" onclick="filterBranch(0)" id="btn-branch-0" class="branch-filter-btn active w-full px-4 py-2.5 rounded-xl text-[14px] font-medium text-left flex items-center gap-3 transition-colors hover:bg-slate-50">
                                <span class="material-symbols-outlined text-[20px]">map</span>
                                Tất cả Cơ Sở
                            </button>
                            <c:forEach var="cs" items="${dsCoSo}">
                                <button type="button" onclick="filterBranch(${cs.coSoID})" id="btn-branch-${cs.coSoID}" class="branch-filter-btn w-full px-4 py-2.5 rounded-xl text-[14px] font-medium text-slate-600 text-left flex items-center gap-3 transition-colors hover:bg-slate-50">
                                    <span class="material-symbols-outlined text-[20px] shrink-0">location_on</span>
                                    <span class="flex flex-col min-w-0">
                                        <span class="truncate">${cs.tenCoSo}</span>
                                        <span class="text-[11px] text-slate-400 font-normal">${cs.gioMoCua != null ? cs.gioMoCua : '06:00'} - ${cs.gioDongCua != null ? cs.gioDongCua : '23:00'}</span>
                                    </span>
                                </button>
                            </c:forEach>
                        </div>
                    </div>

                    <!-- Mini Map Card -->
                    <div class="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden animate-fade-in-up">
                        <div class="px-5 py-4 border-b border-slate-100 flex justify-between items-center bg-slate-50">
                            <h3 class="font-bold text-slate-800 flex items-center gap-2">
                                <span class="material-symbols-outlined text-[20px] text-green-600">map</span>
                                Bản đồ khu vực
                            </h3>
                        </div>
                        <div class="p-4">
                            <div class="relative w-full h-[180px] bg-slate-100 rounded-xl overflow-hidden border border-slate-200 group cursor-pointer">
                                <div class="absolute inset-0 bg-[url('https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&w=400&q=80')] bg-center bg-cover transition-transform duration-500 group-hover:scale-105"></div>
                                <div class="absolute inset-0 bg-slate-900/10 transition-colors duration-300 group-hover:bg-slate-900/30"></div>
                                
                                <div class="absolute top-1/3 left-1/4 -translate-x-1/2 -translate-y-1/2 flex flex-col items-center">
                                    <div class="w-8 h-8 rounded-full bg-green-600/20 flex items-center justify-center animate-ping absolute"></div>
                                    <span class="material-symbols-outlined text-green-600 text-[32px] drop-shadow-md z-10 relative">location_on</span>
                                </div>
                                <div class="absolute top-2/3 right-1/4 translate-x-1/2 -translate-y-1/2 flex flex-col items-center">
                                    <span class="material-symbols-outlined text-emerald-500 text-[28px] drop-shadow-md z-10 relative">location_on</span>
                                </div>
                                
                                <div class="absolute bottom-3 left-3 right-3 bg-white/90 backdrop-blur-md px-3 py-2 rounded-lg flex items-center justify-between border border-white/20 shadow-sm">
                                    <div>
                                        <span class="text-[10px] font-bold text-slate-500 uppercase tracking-wider block">Xem bản đồ lớn</span>
                                        <span class="text-[11px] font-bold text-slate-800">4 cơ sở xung quanh</span>
                                    </div>
                                    <span class="material-symbols-outlined text-green-600 text-[18px]">open_in_new</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- RIGHT MAIN CONTENT: Court List -->
                <div class="lg:col-span-3 space-y-4 animate-fade-in-up" style="animation-delay: 0.1s">
                    <div class="flex flex-wrap justify-between items-center gap-2 px-1 mb-2">
                        <span class="text-sm text-slate-500 font-medium">Tìm thấy <strong id="court-count" class="text-slate-800">0</strong> sân</span>
                        <span id="court-status-summary" class="text-xs text-slate-500 font-medium"></span>
                    </div>
                    
                    <div id="courts-container" class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
                        <!-- Dynamically loaded via JS -->
                    </div>
                </div>
            </div>

        </div>
    </main>

    <!-- BOOKING HISTORY MODAL -->
    <div id="historyModalOverlay" class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-50 hidden flex items-center justify-center opacity-0 transition-opacity duration-300 overflow-y-auto py-10 px-4">
        <div id="historyPanel" class="bg-white w-full max-w-4xl rounded-3xl shadow-2xl overflow-hidden transform scale-95 transition-all duration-300 relative my-auto">
            <div class="bg-gradient-to-r from-green-600 to-emerald-600 px-6 py-4 flex items-center justify-between text-white">
                <h3 class="font-bold text-lg flex items-center gap-2">
                    <span class="material-symbols-outlined">history</span> Lịch sử đặt sân của bạn
                </h3>
                <button onclick="closeHistoryModal()" class="text-white/80 hover:text-white transition-colors p-1">
                    <span class="material-symbols-outlined">close</span>
                </button>
            </div>
            
            <!-- User Stats Sub-header inside Modal -->
            <c:if test="${sessionScope.user != null}">
                <div class="px-6 py-4 bg-slate-50/70 border-b border-slate-100 flex flex-wrap items-center justify-between gap-4">
                    <div class="flex items-center gap-3">
                        <div class="w-10 h-10 rounded-full bg-emerald-50 text-emerald-600 flex items-center justify-center font-extrabold text-sm shadow-inner border border-emerald-100/50">
                            <c:choose>
                                <c:when test="${not empty sessionScope.user.fullName}">
                                    ${fn:substring(sessionScope.user.fullName, 0, 1).toUpperCase()}
                                </c:when>
                                <c:otherwise>
                                    ${fn:substring(sessionScope.user.username, 0, 1).toUpperCase()}
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div>
                            <h4 class="font-extrabold text-slate-800 text-sm leading-tight">${sessionScope.user.fullName}</h4>
                            <p class="text-[10px] text-slate-400 font-bold mt-0.5">${sessionScope.user.email}</p>
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
                                        <div class="flex flex-col gap-0.5">
                                            <span class="font-extrabold text-sm text-slate-900">${tenSanHienThi}</span>
                                            <span class="text-[10px] text-slate-450 font-bold flex items-center gap-1">
                                                <c:if test="${not empty branchHienThi}">
                                                    <span class="material-symbols-outlined text-[12px] text-slate-400">location_on</span>
                                                    ${branchHienThi} &middot;
                                                </c:if>
                                                Mã ĐS: #${lich.datSanId}
                                            </span>
                                        </div>
                                    </td>
                                    <td class="p-4 text-center">
                                        <div class="flex flex-col gap-0.5">
                                            <span class="font-bold text-slate-700">${lich.ngayDat}</span>
                                            <span class="text-xs text-emerald-600 font-extrabold font-mono">${lich.gioBatDau.toString().substring(0,5)} — ${lich.gioKetThuc.toString().substring(0,5)}</span>
                                        </div>
                                    </td>
                                    <td class="p-4 text-right font-extrabold text-slate-900 text-sm">
                                        <fmt:formatNumber value="${lich.tongTienDuKien}" type="currency" currencySymbol="đ" maxFractionDigits="0" />
                                    </td>
                                    <td class="p-4 text-center">
                                        <c:choose>
                                            <c:when test="${lich.trangThai == 'Chờ xác nhận'}">
                                                <span class="bg-amber-50 text-amber-700 border border-amber-200 px-2.5 py-1 rounded-lg text-[10px] font-bold inline-block">Chờ duyệt</span>
                                            </c:when>
                                            <c:when test="${lich.trangThai == 'Đã xác nhận' || lich.trangThai == 'Đã đặt'}">
                                                <span class="bg-green-50 text-green-700 border border-green-200 px-2.5 py-1 rounded-lg text-[10px] font-bold inline-block">Đã duyệt</span>
                                            </c:when>
                                            <c:when test="${lich.trangThai == 'Đang sử dụng'}">
                                                <span class="bg-purple-50 text-purple-700 border border-purple-200 px-2.5 py-1 rounded-lg text-[10px] font-bold inline-block">Đang đá</span>
                                            </c:when>
                                            <c:when test="${lich.trangThai == 'Đã hủy'}">
                                                <span class="bg-red-50 text-red-700 border border-red-200 px-2.5 py-1 rounded-lg text-[10px] font-bold inline-block">Đã hủy</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="bg-slate-100 text-slate-500 border border-slate-200 px-2.5 py-1 rounded-lg text-[10px] font-bold inline-block">${lich.trangThai}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="p-4 text-center">
                                        <div class="flex items-center justify-center gap-1.5">
                                            <c:if test="${lich.trangThai == 'Chờ xác nhận' || lich.trangThai == 'Đã xác nhận'}">
                                                <form action="${pageContext.request.contextPath}/customer/huy-dat-san" method="post" onsubmit="return confirm('Bạn có chắc chắn muốn hủy yêu cầu đặt sân này?');" class="inline-block">
                                                    <input type="hidden" name="id" value="${lich.datSanId}">
                                                    <button type="submit" class="px-3 py-1.5 rounded-lg border border-red-200 text-red-500 font-bold hover:bg-red-50 hover:border-red-300 transition-all active:scale-95 text-[10px]">
                                                        Hủy
                                                    </button>
                                                </form>
                                            </c:if>
                                            <c:if test="${lich.trangThai == 'Chờ xác nhận' || lich.trangThai == 'Đã xác nhận' || lich.trangThai == 'Đang sử dụng'}">
                                                <button type="button" onclick="openCustomerServiceModal(${lich.datSanId})" class="px-3 py-1.5 rounded-lg border border-emerald-200 bg-emerald-50 text-emerald-600 font-bold hover:bg-emerald-100 transition-all active:scale-95 text-[10px]">
                                                    Dịch vụ
                                                </button>
                                            </c:if>
                                            <c:if test="${lich.trangThai == 'Đã hủy'}">
                                                <span class="text-slate-400 text-[10px] line-through">Không khả dụng</span>
                                            </c:if>
                                            <c:if test="${lich.trangThai == 'Đã hoàn thành'}">
                                                <span class="text-green-600 text-[10px] font-bold">Hoàn thành</span>
                                            </c:if>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty dsLich}">
                                <tr>
                                    <td colspan="5" class="p-16 text-center">
                                        <span class="material-symbols-outlined text-[40px] text-slate-200 block mb-4">event_busy</span>
                                        <p class="text-slate-400 text-[11px] font-extrabold uppercase tracking-widest">Chưa có dữ liệu lịch sử đặt sân</p>
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- BOOKING & CHECKOUT MODAL FLOW -->
    <!-- OVERLAY -->
    <div id="bookingModalOverlay" class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-50 hidden flex items-center justify-center opacity-0 transition-opacity duration-300 overflow-y-auto py-10 px-4">
        
        <!-- STEP 1: BOOKING FORM PANEL -->
        <div id="bookingFormPanel" class="bg-white w-full max-w-2xl rounded-3xl shadow-2xl overflow-hidden transform scale-95 transition-all duration-300 relative my-auto">
            
            <div class="bg-gradient-to-r from-green-600 to-emerald-600 px-6 py-4 flex items-center justify-between text-white">
                <h3 class="font-bold text-lg flex items-center gap-2">
                    <span class="material-symbols-outlined">event_available</span> Đăng ký đặt sân
                </h3>
                <button onclick="closeBookingModal()" class="text-white/80 hover:text-white transition-colors p-1">
                    <span class="material-symbols-outlined">close</span>
                </button>
            </div>

            <div class="p-6 md:p-8">
                <!-- Selected Court Info -->
                <div class="flex items-start gap-4 p-4 bg-slate-50 rounded-2xl border border-slate-100 mb-6">
                    <div>
                        <h4 id="modal-court-name" class="font-bold text-slate-800 text-lg">Tên sân</h4>
                        <p id="modal-court-branch" class="text-sm text-slate-500 flex items-center gap-1 mt-1">
                            <span class="material-symbols-outlined text-[16px]">location_on</span> Cơ sở
                        </p>
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
                            <label for="gioBatDau" class="form-label">Chọn giờ bắt đầu <span class="text-red-500">*</span></label>
                            <div class="relative">
                                <select name="gioBatDau" id="gioBatDau" required class="form-input pr-10 cursor-pointer appearance-none" onchange="onStartTimeSelectChange()">
                                    <!-- Populated dynamically -->
                                </select>
                                <span class="material-symbols-outlined absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none text-[20px]">expand_more</span>
                            </div>
                        </div>

                        <div class="space-y-1.5">
                            <label for="gioKetThuc" class="form-label">Chọn giờ kết thúc <span class="text-red-500">*</span></label>
                            <div class="relative">
                                <select name="gioKetThuc" id="gioKetThuc" required class="form-input pr-10 cursor-pointer appearance-none" onchange="onEndTimeSelectChange()">
                                    <option value="">Vui lòng chọn giờ bắt đầu trước</option>
                                </select>
                                <span class="material-symbols-outlined absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none text-[20px]">expand_more</span>
                            </div>
                        </div>
                    </div>

                    <!-- Timetable Preview Block -->
                    <div id="timetable-block" class="hidden mt-2">
                        <label class="form-label text-amber-600">Lịch đã có người đặt trong ngày</label>
                        <div id="timeline-slots" class="flex flex-wrap gap-2 mt-2">
                            <!-- Slots go here -->
                        </div>
                    </div>
                    
                    <div id="overlap-warning" class="bg-red-50 border border-red-200 text-red-600 p-3 rounded-xl text-sm hidden flex gap-2 items-start mt-2 shadow-sm">
                        <span class="material-symbols-outlined text-[18px] mt-0.5">warning</span>
                        <span id="overlap-warning-text">Trùng lịch!</span>
                    </div>

                    <div class="space-y-1.5">
                        <label for="ghiChu" class="form-label">Ghi chú yêu cầu</label>
                        <textarea name="ghiChu" id="ghiChu" rows="2" class="form-input resize-none" placeholder="Thuê bóng, mượn áo tập..."></textarea>
                    </div>

                    <div class="pt-6 border-t border-slate-100 flex justify-end gap-3">
                        <button type="button" onclick="closeBookingModal()" class="px-6 py-3 rounded-xl font-bold text-slate-600 bg-slate-100 hover:bg-slate-200 transition-colors">
                            Hủy
                        </button>
                        
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

        <!-- STEP 2: CHECKOUT PAYMENT PANEL -->
        <div id="checkoutPanel" class="bg-white w-full max-w-md rounded-3xl shadow-2xl overflow-hidden transform scale-95 transition-all duration-300 hidden relative my-auto">
            <div class="px-6 py-4 flex items-center gap-3 border-b border-slate-100">
                <button onclick="backToBookingForm()" class="p-1.5 text-slate-400 hover:text-slate-800 bg-slate-50 hover:bg-slate-100 rounded-full transition-colors flex items-center justify-center">
                    <span class="material-symbols-outlined text-[20px]">arrow_back</span>
                </button>
                <h3 class="font-bold text-slate-800 text-lg">Thanh toán đặt sân</h3>
            </div>

            <div class="p-6">
                <!-- Summary -->
                <div class="bg-slate-50 rounded-2xl p-4 border border-slate-100 mb-6 space-y-2 text-sm">
                    <div class="flex justify-between text-slate-600">
                        <span>Thời gian chơi</span>
                        <span id="summary-duration" class="font-bold text-slate-800">-</span>
                    </div>
                    <div class="flex justify-between text-slate-600">
                        <span>Đơn giá</span>
                        <span id="summary-rate" class="font-bold text-slate-800">-</span>
                    </div>
                    <div id="summary-lights-row" class="flex justify-between text-amber-600 hidden">
                        <span class="flex items-center gap-1"><span class="material-symbols-outlined text-[16px]">wb_twilight</span> Phụ thu đèn tối</span>
                        <span class="font-bold">Có áp dụng</span>
                    </div>
                    <div class="pt-3 mt-1 border-t border-slate-200 flex justify-between items-end">
                        <span class="text-xs font-bold uppercase text-slate-500">Tổng cộng</span>
                        <span id="summary-total" class="text-2xl font-bold text-green-600">-</span>
                    </div>
                </div>

                <!-- Payment Method Selector -->
                <div class="mb-5 space-y-2">
                    <label class="form-label text-slate-500 font-bold text-[10px]">Phương thức thanh toán</label>
                    <div class="grid grid-cols-2 gap-3">
                        <!-- PayOS (Online) Option -->
                        <button type="button" onclick="selectPaymentMethod('payos')" id="payment-opt-payos"
                                class="flex flex-col items-center justify-center p-3 rounded-2xl border-2 border-slate-100 hover:border-slate-200 transition-all text-center gap-1.5 active:scale-95 duration-200">
                            <span class="material-symbols-outlined text-[22px] text-emerald-600">qr_code_2</span>
                            <span class="text-xs font-extrabold text-slate-850">Chuyển khoản (PayOS)</span>
                            <span class="text-[9px] text-slate-400 font-bold leading-none">Giữ sân 10 phút</span>
                        </button>
                        <!-- Cash (Pay Later) Option -->
                        <button type="button" onclick="selectPaymentMethod('sau')" id="payment-opt-sau"
                                class="flex flex-col items-center justify-center p-3 rounded-2xl border-2 border-emerald-600 bg-emerald-50/20 text-center gap-1.5 active:scale-95 duration-200">
                            <span class="material-symbols-outlined text-[22px] text-slate-500">payments</span>
                            <span class="text-xs font-extrabold text-slate-850">Thanh toán tại quầy</span>
                            <span class="text-[9px] text-slate-400 font-bold leading-none">Đặt cọc tiền mặt</span>
                        </button>
                    </div>
                </div>

                <!-- Cash Info Panel -->
                <div id="payment-info-sau" class="bg-slate-50 border border-slate-100 rounded-2xl p-4 text-center flex flex-col items-center justify-center gap-2">
                    <div class="w-9 h-9 bg-white text-slate-550 rounded-full flex items-center justify-center shadow-inner border border-slate-100/50"><span class="material-symbols-outlined text-[18px]">schedule</span></div>
                    <div>
                        <p class="text-xs font-bold text-slate-800">Thanh toán sau (Tiền mặt)</p>
                        <p class="text-[10px] text-slate-500 mt-1 leading-normal max-w-[280px] mx-auto">Lịch đặt bằng tiền mặt chỉ được giữ chỗ tạm thời. Quý khách vui lòng đến trước 15 phút để làm thủ tục nhận sân.</p>
                    </div>
                </div>

                <!-- PayOS Info Panel (Hidden by default) -->
                <div id="payment-info-payos" class="bg-slate-50 border border-slate-100 rounded-2xl p-4 text-center flex flex-col items-center justify-center gap-2 hidden">
                    <div class="w-9 h-9 bg-white text-emerald-600 rounded-full flex items-center justify-center shadow-inner border border-emerald-100/50"><span class="material-symbols-outlined text-[18px]">bolt</span></div>
                    <div>
                        <p class="text-xs font-bold text-slate-800">Giữ sân tức thì trong 10 phút</p>
                        <p class="text-[10px] text-slate-500 mt-1 leading-normal max-w-[280px] mx-auto">Hệ thống sẽ tạm khóa sân và tạo mã chuyển khoản tự động. Bạn cần hoàn tất thanh toán trong vòng 10 phút.</p>
                    </div>
                </div>

                <button onclick="confirmBooking()" class="w-full mt-6 bg-green-600 hover:bg-green-700 text-white font-bold h-12 rounded-xl text-[14px] transition-colors shadow-md shadow-green-600/20 flex items-center justify-center gap-2">
                    <span class="material-symbols-outlined text-[20px]">verified</span> Hoàn tất đặt sân
                </button>
            </div>
        </div>
    </div>

    <jsp:include page="/common/footer.jsp" />

    <!-- JavaScript Bridges and UI Handling -->
    <script>
        // Set min date of picker to today
        const dateInput = document.getElementById('ngayDat');
        const todayStr = new Date().toISOString().split('T')[0];
        dateInput.min = todayStr;
        dateInput.value = todayStr;

        // 1. Data bridge from Java context
        const DEFAULT_OPEN_TIME = "06:00";
        const DEFAULT_CLOSE_TIME = "23:00";

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
                    lightTime: `${l.gioBatDauLenDen}`, // HH:mm:ss format
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

        // 2. State management
        let selectedBranchId = 0;
        let selectedSportId = 0;
        let selectedCourtId = null;
        let currentTotalCost = 0;

        // Parse query parameters
        const urlParams = new URLSearchParams(window.location.search);
        const paramSportId = parseInt(urlParams.get('sportId')) || 0;
        const paramBranchId = parseInt(urlParams.get('branchId')) || 0;
        const paramDate = urlParams.get('date');

        if (paramBranchId) selectedBranchId = paramBranchId;
        if (paramSportId) selectedSportId = paramSportId;
        if (paramDate) dateInput.value = paramDate;

        // 3. Render Courts in Horizontal List
        function getCourtStatusInfo(status) {
            const s = (status || '').trim();
            if (s === 'Sẵn sàng') {
                return { label: 'Trống sân', bookable: true, badgeClass: 'bg-emerald-50 text-emerald-700 border border-emerald-200', dotClass: 'bg-emerald-500' };
            }
            if (s === 'Đang dùng') {
                return { label: 'Đang dùng', bookable: false, badgeClass: 'bg-amber-50 text-amber-700 border border-amber-200', dotClass: 'bg-amber-500 animate-pulse' };
            }
            if (s === 'Bảo trì' || s === 'Đang bảo trì' || s === 'Tạm đóng') {
                return { label: s, bookable: false, badgeClass: 'bg-red-50 text-red-700 border border-red-200', dotClass: 'bg-red-500' };
            }
            return { label: s || 'Không rõ', bookable: false, badgeClass: 'bg-slate-50 text-slate-600 border border-slate-200', dotClass: 'bg-slate-400' };
        }

        function buildStatusBadge(statusInfo) {
            return '<span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg text-[10px] font-bold uppercase tracking-wider ' + statusInfo.badgeClass + '">' +
                '<span class="w-1.5 h-1.5 rounded-full shrink-0 ' + statusInfo.dotClass + '"></span>' +
                statusInfo.label + '</span>';
        }

        function renderCourts() {
            const container = document.getElementById("courts-container");
            container.innerHTML = "";

            // Filter courts array
            const filteredCourts = courts.filter(c => {
                const matchBranch = (selectedBranchId === 0 || c.branchId === selectedBranchId);
                const type = courtTypes[c.typeId];
                const matchSport = (selectedSportId === 0 || (type && type.sportId === selectedSportId));
                
                const branch = branches[c.branchId] || {};
                const branchAddress = (branch.address || '').toLowerCase();
                const branchName = (branch.name || '').toLowerCase();
                const searchQuery = (selectedLocationQuery || '').toLowerCase().trim();
                const matchLocation = !searchQuery || branchAddress.includes(searchQuery) || branchName.includes(searchQuery);
                
                return matchBranch && matchSport && matchLocation;
            });

            document.getElementById("court-count").textContent = filteredCourts.length;

            const availableCount = filteredCourts.filter(c => c.status === 'Sẵn sàng').length;
            const inUseCount = filteredCourts.filter(c => c.status === 'Đang dùng').length;
            const otherCount = filteredCourts.length - availableCount - inUseCount;
            const summaryParts = [];
            if (availableCount > 0) summaryParts.push('<span class="text-emerald-600">' + availableCount + ' trống</span>');
            if (inUseCount > 0) summaryParts.push('<span class="text-amber-600">' + inUseCount + ' đang dùng</span>');
            if (otherCount > 0) summaryParts.push('<span class="text-red-500">' + otherCount + ' không khả dụng</span>');
            document.getElementById("court-status-summary").innerHTML = summaryParts.join(' · ');

            if (filteredCourts.length === 0) {
                container.innerHTML = `
                    <div class="bg-white rounded-3xl p-12 text-center border border-slate-200">
                        <span class="material-symbols-outlined text-[64px] text-slate-200 block mb-4">search_off</span>
                        <p class="text-base text-slate-500 font-medium">Không tìm thấy sân đấu phù hợp với bộ lọc.</p>
                        <button onclick="filterBranch(0); filterSport(0);" class="mt-4 text-green-600 font-bold hover:underline">Xóa bộ lọc</button>
                    </div>
                `;
                return;
            }

            filteredCourts.forEach(c => {
                const type = courtTypes[c.typeId] || { name: "Chưa phân loại", priceDay: 100000, priceNight: 100000 };
                const branch = branches[c.branchId] || { name: "Cơ Sở chung", address: "", openTime: DEFAULT_OPEN_TIME, closeTime: DEFAULT_CLOSE_TIME };
                const sportName = sports[type.sportId] || "Thể thao";
                const statusInfo = getCourtStatusInfo(c.status);
                const statusBadge = buildStatusBadge(statusInfo);
                const priceText = type.priceDay.toLocaleString('vi-VN') + ' đ';
                const bookBtnLabel = statusInfo.bookable ? 'Đặt sân' : statusInfo.label;

                // Map sport name to curated premium images
                let courtImageUrl = "https://images.unsplash.com/photo-1518605368461-1ee7e57c6691?auto=format&fit=crop&w=600&q=80"; // default football
                const sName = sportName.toLowerCase();
                if (sName.includes("cầu lông")) {
                    courtImageUrl = "https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?auto=format&fit=crop&w=600&q=80";
                } else if (sName.includes("pickleball")) {
                    courtImageUrl = "https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?auto=format&fit=crop&w=600&q=80";
                } else if (sName.includes("tennis")) {
                    courtImageUrl = "https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0?auto=format&fit=crop&w=600&q=80";
                } else if (sName.includes("bóng bàn")) {
                    courtImageUrl = "https://images.unsplash.com/photo-1534158914592-062992fbe900?auto=format&fit=crop&w=600&q=80";
                } else if (sName.includes("gym") || sName.includes("fitness")) {
                    courtImageUrl = "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&w=600&q=80";
                }
                
                if (c.image && c.image.trim() !== "") {
                    courtImageUrl = c.image;
                }

                // Mock ratings & distance metadata for premium look
                const rating = (4.5 + (c.id % 5) * 0.1).toFixed(1);
                const reviews = 20 + (c.id * 7) % 80;
                const distance = (1.2 + (c.id % 4) * 0.4).toFixed(1);

                const cardHtml = `
                    <div class="court-card bg-white rounded-2xl border border-slate-200 overflow-hidden flex flex-col justify-between transition-all duration-300 hover:shadow-xl hover:-translate-y-1 \${statusInfo.bookable ? '' : 'opacity-90'}">
                        
                        <!-- Wrap top part in link to detail page -->
                        <a href="${pageContext.request.contextPath}/customer/chi-tiet-san?id=\${c.id}" class="flex flex-col flex-grow hover:no-underline">
                            <!-- Top Image Banner -->
                            <div class="relative h-[180px] w-full overflow-hidden bg-slate-100">
                                <img src="\${courtImageUrl}" alt="\${c.name}" class="w-full h-full object-cover transition-transform duration-500 hover:scale-105">
                                <div class="absolute inset-0 bg-gradient-to-t from-slate-900/50 via-transparent to-transparent"></div>
                                
                                <!-- Badges on Image -->
                                <div class="absolute top-4 left-4 flex flex-wrap gap-2">
                                    <span class="px-2.5 py-1 rounded-lg bg-white/90 backdrop-blur-md text-green-700 text-[10px] font-bold uppercase tracking-wider shadow-sm flex items-center gap-1">
                                        \${sportName}
                                    </span>
                                    \${statusBadge}
                                </div>
                                
                                <div class="absolute bottom-4 left-4 right-4 flex justify-between items-end text-white">
                                    <span class="text-[11px] font-medium bg-black/40 backdrop-blur-md px-2 py-1 rounded-md flex items-center gap-1">
                                        <span class="material-symbols-outlined text-[13px]">near_me</span> Cách bạn \${distance} km
                                    </span>
                                </div>
                            </div>

                            <!-- Card Content -->
                            <div class="p-5 flex flex-col flex-grow justify-between gap-4">
                                <div>
                                    <!-- Title & Ratings -->
                                    <div class="flex justify-between items-start gap-2">
                                        <h3 class="text-base font-bold text-slate-800 leading-tight truncate">\${c.name}</h3>
                                        <div class="flex items-center gap-0.5 text-amber-500 shrink-0">
                                            <span class="material-symbols-outlined text-[15px] fill-1">star</span>
                                            <span class="text-xs font-bold text-slate-700">\${rating}</span>
                                            <span class="text-[10px] text-slate-400">(\\ \${reviews} \\)</span>
                                        </div>
                                    </div>
                                    
                                    <!-- Location -->
                                    <p class="text-[12.5px] text-slate-500 mt-1 flex items-center gap-1.5">
                                        <span class="material-symbols-outlined text-[16px] text-slate-400">location_on</span>
                                        <span class="truncate">\${branch.name}</span>
                                    </p>
                                    
                                    <!-- Timing -->
                                    <p class="text-[12px] text-slate-400 mt-1 flex items-center gap-1.5">
                                        <span class="material-symbols-outlined text-[15px]">schedule</span>
                                        \${normalizeTime(branch.openTime)} - \${normalizeTime(branch.closeTime)}
                                    </p>
                                    
                                    <!-- Description -->
                                    <p class="text-[13px] text-slate-600 mt-2.5 line-clamp-2 h-[38px]">\${c.desc || 'Sân đấu tiêu chuẩn chất lượng cao, hệ thống đèn chiếu sáng ban đêm hiện đại.'}</p>
                                    
                                    <!-- Amenities Badges -->
                                    <div class="flex items-center gap-3 mt-4 text-slate-400">
                                        <span class="material-symbols-outlined text-[18px] hover:text-green-600 transition-colors cursor-help" title="Có Wifi miễn phí">wifi</span>
                                        <span class="material-symbols-outlined text-[18px] hover:text-green-600 transition-colors cursor-help" title="Bãi đậu xe máy & ô tô">local_parking</span>
                                        <span class="material-symbols-outlined text-[18px] hover:text-green-600 transition-colors cursor-help" title="Nước uống phục vụ miễn phí">local_drink</span>
                                        <span class="material-symbols-outlined text-[18px] hover:text-green-600 transition-colors cursor-help" title="Đèn chiếu sáng ban đêm">lightbulb</span>
                                        <span class="material-symbols-outlined text-[18px] hover:text-green-600 transition-colors cursor-help" title="Phòng thay đồ & tắm rửa">shower</span>
                                    </div>
                                </div>
                            </div>
                        </a>
                        
                        <!-- Price & Button Section -->
                        <div class="p-5 pt-0 mt-auto">
                            <div class="flex items-center justify-between border-t border-slate-100 pt-4">
                                <div>
                                    <span class="text-[9px] font-bold text-slate-400 uppercase tracking-wider block mb-0.5">Giá thuê từ</span>
                                    <span class="text-[16px] font-bold text-green-600">\${priceText}<span class="text-xs font-normal text-slate-500">/h</span></span>
                                </div>
                                <button type="button" 
                                    onclick="\${statusInfo.bookable ? 'openBookingModal(' + c.id + ')' : ''}" 
                                    \${statusInfo.bookable ? '' : 'disabled'}
                                    class="px-4 py-2 bg-green-600 text-white rounded-xl text-xs font-bold transition-all hover:bg-green-700 hover:shadow-lg hover:shadow-green-600/30 disabled:bg-slate-300 disabled:text-slate-500 disabled:shadow-none flex items-center gap-1.5">
                                    <span class="material-symbols-outlined text-[16px]">\${statusInfo.bookable ? 'calendar_add_on' : 'block'}</span>
                                    \${bookBtnLabel}
                                </button>
                            </div>
                        </div>
                    </div>
                `;
                container.insertAdjacentHTML("beforeend", cardHtml);
            });
        }

        // 4. Filters Interaction
        function filterBranch(branchId) {
            selectedBranchId = branchId;
            document.querySelectorAll(".branch-filter-btn").forEach(btn => {
                btn.classList.remove("active");
                btn.style.backgroundColor = '';
                btn.style.color = '';
            });
            const activeBtn = document.getElementById(`btn-branch-${branchId}`);
            if (activeBtn) {
                activeBtn.classList.add("active");
                activeBtn.style.backgroundColor = '#16a34a';
                activeBtn.style.color = '#ffffff';
            }
            renderCourts();
        }

        function filterSport(sportId) {
            selectedSportId = sportId;
            document.querySelectorAll(".filter-btn").forEach(btn => {
                btn.classList.remove("active");
                btn.style.backgroundColor = '';
                btn.style.color = '';
            });
            const activeBtn = document.getElementById(`btn-sport-${sportId}`);
            if (activeBtn) {
                activeBtn.classList.add("active");
                activeBtn.style.backgroundColor = '#16a34a';
                activeBtn.style.color = '#ffffff';
            }
            renderCourts();
        }

        let selectedLocationQuery = "";

        function filterLocation(query) {
            selectedLocationQuery = query;
            renderCourts();
        }

        // Location Search & Autocomplete Event Listeners
        document.addEventListener("DOMContentLoaded", () => {
            const locationInput = document.getElementById("location-search-input");
            const autoLocateBtn = document.getElementById("btn-auto-locate");
            const locateIcon = document.getElementById("locate-icon");
            const locateText = document.getElementById("locate-text");

            if (locationInput) {
                locationInput.addEventListener("input", (e) => {
                    filterLocation(e.target.value);
                });
            }

            if (autoLocateBtn) {
                autoLocateBtn.addEventListener("click", () => {
                    locateIcon.innerHTML = "sync";
                    locateIcon.classList.add("animate-spin");
                    locateText.textContent = "Đang định vị...";
                    autoLocateBtn.disabled = true;

                    setTimeout(() => {
                        let detectedLocation = "Long Điền";
                        
                        const firstBranchId = Object.keys(branches)[0];
                        if (firstBranchId && branches[firstBranchId]) {
                            detectedLocation = branches[firstBranchId].address || branches[firstBranchId].name || "Long Điền";
                            
                            if (detectedLocation.includes(",")) {
                                detectedLocation = detectedLocation.split(",")[0].trim();
                            }
                        }

                        if (locationInput) {
                            locationInput.value = detectedLocation;
                            filterLocation(detectedLocation);
                        }

                        locateIcon.innerHTML = "my_location";
                        locateIcon.classList.remove("animate-spin");
                        locateText.textContent = "Định vị thành công!";
                        autoLocateBtn.disabled = false;

                        setTimeout(() => {
                            locateText.textContent = "Xác định vị trí hiện tại";
                        }, 2000);
                    }, 1000);
                });
            }
        });

        // 5. Booking Flow & Modal
        function openBookingModal(courtId) {
            selectedCourtId = courtId;
            document.getElementById("input-san-id").value = courtId;
            
            const court = courts.find(c => c.id === courtId);
            if (!court) return;

            const type = courtTypes[court.typeId];
            const branch = branches[court.branchId];

            // Setup Modal Header
            document.getElementById("modal-court-name").textContent = court.name;
            document.getElementById("modal-court-branch").innerHTML = `<span class="material-symbols-outlined text-[16px]">location_on</span> \${branch.name}`;
            document.getElementById("modal-court-type").textContent = type.name;

            const statusInfo = getCourtStatusInfo(court.status);
            const modalStatusEl = document.getElementById("modal-court-status");
            modalStatusEl.className = 'text-[10px] font-bold inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg ' + statusInfo.badgeClass;
            modalStatusEl.innerHTML = '<span class="w-1.5 h-1.5 rounded-full ' + statusInfo.dotClass + '"></span>' + statusInfo.label;

            // Reset inputs
            document.getElementById("ngayDat").value = todayStr;
            document.getElementById("ghiChu").value = "";
            selectPaymentMethod('sau');
            applyBranchTimeConstraints(court.branchId);
            document.getElementById("timetable-block").classList.add("hidden");
            document.getElementById("overlap-warning").classList.add("hidden");
            const btnNext = document.getElementById("next-checkout-btn");
            if (btnNext) btnNext.disabled = true;

            // Show Overlay & Form Panel
            const overlay = document.getElementById("bookingModalOverlay");
            const formPanel = document.getElementById("bookingFormPanel");
            const checkoutPanel = document.getElementById("checkoutPanel");

            overlay.classList.remove("hidden");
            checkoutPanel.classList.add("hidden");
            formPanel.classList.remove("hidden");

            // Trigger animation
            setTimeout(() => {
                overlay.classList.remove("opacity-0");
                formPanel.classList.remove("scale-95");
            }, 10);
            
            checkScheduleAndPrice();
        }

        function closeBookingModal() {
            const overlay = document.getElementById("bookingModalOverlay");
            const panels = document.querySelectorAll("#bookingFormPanel, #checkoutPanel");
            
            overlay.classList.add("opacity-0");
            panels.forEach(p => p.classList.add("scale-95"));

            setTimeout(() => {
                overlay.classList.add("hidden");
            }, 300);
        }

        function openHistoryModal() {
            const overlay = document.getElementById("historyModalOverlay");
            const panel = document.getElementById("historyPanel");
            if (overlay && panel) {
                overlay.classList.remove("hidden");
                overlay.classList.add("flex");
                setTimeout(() => {
                    overlay.classList.remove("opacity-0");
                    panel.classList.remove("scale-95");
                }, 10);
            }
        }

        function closeHistoryModal() {
            const overlay = document.getElementById("historyModalOverlay");
            const panel = document.getElementById("historyPanel");
            if (overlay && panel) {
                overlay.classList.add("opacity-0");
                panel.classList.add("scale-95");
                setTimeout(() => {
                    overlay.classList.add("hidden");
                    overlay.classList.remove("flex");
                }, 300);
            }
        }

        function selectPaymentMethod(method) {
            document.getElementById("input-payment-method").value = method;
            
            const btnPayOS = document.getElementById("payment-opt-payos");
            const btnSau = document.getElementById("payment-opt-sau");
            const infoPayOS = document.getElementById("payment-info-payos");
            const infoSau = document.getElementById("payment-info-sau");
            
            if (!btnPayOS || !btnSau || !infoPayOS || !infoSau) return;
            
            if (method === 'payos') {
                btnPayOS.className = "flex flex-col items-center justify-center p-3 rounded-2xl border-2 border-emerald-600 bg-emerald-50/20 text-center gap-1.5 active:scale-95 duration-200";
                btnSau.className = "flex flex-col items-center justify-center p-3 rounded-2xl border-2 border-slate-100 hover:border-slate-200 transition-all text-center gap-1.5 active:scale-95 duration-200";
                infoPayOS.classList.remove("hidden");
                infoSau.classList.add("hidden");
            } else {
                btnSau.className = "flex flex-col items-center justify-center p-3 rounded-2xl border-2 border-emerald-600 bg-emerald-50/20 text-center gap-1.5 active:scale-95 duration-200";
                btnPayOS.className = "flex flex-col items-center justify-center p-3 rounded-2xl border-2 border-slate-100 hover:border-slate-200 transition-all text-center gap-1.5 active:scale-95 duration-200";
                infoSau.classList.remove("hidden");
                infoPayOS.classList.add("hidden");
            }
        }

        // ---- Soft-hold (giữ chỗ tạm thời) integration ----
        let lastHoldKey = null;

        function requestSoftHold(courtId, dateVal, startVal, endVal) {
            const holdKey = `\${courtId}|\${dateVal}|\${startVal}|\${endVal}`;
            if (holdKey === lastHoldKey) return;
            lastHoldKey = holdKey;

            const btnNext = document.getElementById("next-checkout-btn");
            const warningBox = document.getElementById("overlap-warning");
            const warningText = document.getElementById("overlap-warning-text");

            const body = new URLSearchParams({
                sanId: courtId,
                ngayDat: dateVal,
                gioBatDau: startVal,
                gioKetThuc: endVal
            });

            fetch("<c:url value='/customer/giu-cho-tam'/>", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: body.toString()
            })
            .then(r => r.json())
            .then(data => {
                if (holdKey !== lastHoldKey) return;
                if (!data.success) {
                    warningText.textContent = data.message || "Đã có người đang giữ khung giờ này, vui lòng chọn khung giờ khác.";
                    warningBox.classList.remove("hidden");
                    if (btnNext) btnNext.disabled = true;
                    lastHoldKey = null;
                }
            })
            .catch(() => {
                // Network/server error: fail open. Final submit's server-side check
                // in DatSanServlet remains authoritative regardless.
            });
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

            // Show conflicts for selected date
            const conflicts = activeBookings.filter(b => b.sanId === courtId && b.date === dateVal && b.status !== "Đã hủy");
            
            if (conflicts.length > 0) {
                timetableBlock.classList.remove("hidden");
                timelineSlots.innerHTML = "";
                conflicts.forEach(b => {
                    const formatTime = (timeStr) => timeStr.substring(0, 5);
                    const slotHtml = `
                        <div class="px-3 py-1.5 bg-amber-50 text-amber-700 border border-amber-200 rounded-lg text-xs font-bold shadow-sm">
                            \${formatTime(b.start)} - \${formatTime(b.end)}
                        </div>
                    `;
                    timelineSlots.insertAdjacentHTML("beforeend", slotHtml);
                });
            } else {
                timetableBlock.classList.add("hidden");
            }

            if (!startVal || !endVal) {
                if (btnNext) btnNext.disabled = true;
                warningBox.classList.add("hidden");
                return;
            }

            const court = courts.find(c => c.id === courtId);
            const branchHours = getBranchHours(court ? court.branchId : null);
            const startMin = timeToMinutes(startVal);
            const endMin = timeToMinutes(endVal);
            const openMin = timeToMinutes(branchHours.openTime);
            const closeMin = timeToMinutes(branchHours.closeTime);

            // Logic validations
            if (endMin <= startMin) {
                warningText.textContent = "Giờ kết thúc phải sau giờ bắt đầu.";
                warningBox.classList.remove("hidden");
                if (btnNext) btnNext.disabled = true;
                return;
            }

            if (startMin < openMin) {
                warningText.textContent = branchHours.name + " mở cửa lúc " + branchHours.openTime + ". Giờ bắt đầu quá sớm.";
                warningBox.classList.remove("hidden");
                if (btnNext) btnNext.disabled = true;
                return;
            }

            if (endMin > closeMin) {
                warningText.textContent = branchHours.name + " đóng cửa lúc " + branchHours.closeTime + ". Giờ kết thúc vượt quá giờ hoạt động.";
                warningBox.classList.remove("hidden");
                if (btnNext) btnNext.disabled = true;
                return;
            }

            if (dateVal === todayStr) {
                const now = new Date();
                const nowMin = now.getHours() * 60 + now.getMinutes();
                if (startMin < nowMin) {
                    warningText.textContent = "Không thể đặt sân cho giờ đã qua trong ngày hôm nay.";
                    warningBox.classList.remove("hidden");
                    if (btnNext) btnNext.disabled = true;
                    return;
                }
            }

            let isOverlapping = false;
            conflicts.forEach(b => {
                const bStart = timeToMinutes(b.start);
                const bEnd = timeToMinutes(b.end);
                if (!(endMin <= bStart || startMin >= bEnd)) {
                    isOverlapping = true;
                }
            });

            if (isOverlapping) {
                warningText.textContent = "Khung giờ bạn chọn đã bị trùng lịch với đơn đặt khác.";
                warningBox.classList.remove("hidden");
                if (btnNext) btnNext.disabled = true;
                return;
            }

            warningBox.classList.add("hidden");
            if (btnNext) btnNext.disabled = false;

            // NEW: attempt to soft-hold this exact slot selection.
            requestSoftHold(courtId, dateVal, startVal, endVal);

            // Calculate cost silently to prepare for checkout
            const type = courtTypes[court.typeId];
            if (type) {
                const lightMin = timeToMinutes(type.lightTime);
                let hourlyRate = type.priceDay;
                let applyLights = false;

                if (startMin >= lightMin) {
                    hourlyRate = type.priceNight;
                    applyLights = type.priceNight !== type.priceDay;
                }

                const durationHours = (endMin - startMin) / 60.0;
                currentTotalCost = Math.round(durationHours * hourlyRate);

                // Populate Checkout Panel data
                document.getElementById("summary-duration").textContent = `\${durationHours.toFixed(1)} giờ (\${formatDurationText(endMin - startMin)})`;
                document.getElementById("summary-rate").textContent = `\${hourlyRate.toLocaleString('vi-VN')} đ/giờ`;
                
                const lightsRow = document.getElementById("summary-lights-row");
                if (applyLights) {
                    lightsRow.classList.remove("hidden");
                } else {
                    lightsRow.classList.add("hidden");
                }

                document.getElementById("summary-total").textContent = `\${currentTotalCost.toLocaleString('vi-VN')} đ`;
            }
        }

        function goToCheckout() {
            const form = document.getElementById('booking-form');
            if (!form.reportValidity()) return;

            const formPanel = document.getElementById("bookingFormPanel");
            const checkoutPanel = document.getElementById("checkoutPanel");

            formPanel.classList.add("scale-95", "opacity-0");
            setTimeout(() => {
                formPanel.classList.add("hidden");
                formPanel.classList.remove("opacity-0"); // Reset for later
                
                checkoutPanel.classList.remove("hidden");
                // slight delay for rendering
                setTimeout(() => {
                    checkoutPanel.classList.remove("scale-95");
                }, 10);
            }, 200);
        }

        function backToBookingForm() {
            const formPanel = document.getElementById("bookingFormPanel");
            const checkoutPanel = document.getElementById("checkoutPanel");

            checkoutPanel.classList.add("scale-95", "opacity-0");
            setTimeout(() => {
                checkoutPanel.classList.add("hidden");
                checkoutPanel.classList.remove("opacity-0");
                
                formPanel.classList.remove("hidden");
                setTimeout(() => {
                    formPanel.classList.remove("scale-95");
                }, 10);
            }, 200);
        }

        function confirmBooking() {
            document.getElementById('booking-form').submit();
        }

        function normalizeTime(timeStr) {
            if (!timeStr) return DEFAULT_OPEN_TIME;
            return timeStr.substring(0, 5);
        }

        function getBranchHours(branchId) {
            const branch = branches[branchId];
            return {
                openTime: normalizeTime(branch?.openTime || DEFAULT_OPEN_TIME),
                closeTime: normalizeTime(branch?.closeTime || DEFAULT_CLOSE_TIME),
                name: branch?.name || "Cơ Sở"
            };
        }

        function getCurrentTimeStr() {
            const now = new Date();
            return String(now.getHours()).padStart(2, "0") + ":" + String(now.getMinutes()).padStart(2, "0");
        }

        function onStartTimeSelectChange() {
            const startVal = document.getElementById("gioBatDau").value;
            const endSelectEl = document.getElementById("gioKetThuc");
            
            if (!startVal) {
                endSelectEl.innerHTML = '<option value="">Vui lòng chọn giờ bắt đầu trước</option>';
                checkScheduleAndPrice();
                return;
            }

            const startMin = timeToMinutes(startVal);
            const court = courts.find(c => c.id === selectedCourtId);
            const { closeTime } = getBranchHours(court ? court.branchId : null);
            const closeMin = timeToMinutes(closeTime);
            
            const dateVal = document.getElementById("ngayDat").value;
            const conflicts = activeBookings.filter(b => b.sanId === selectedCourtId && b.date === dateVal && b.status !== "Đã hủy");

            // Prevent selecting across an existing reservation
            let maxAvailableMin = closeMin;
            conflicts.forEach(b => {
                const bStartMin = timeToMinutes(b.start);
                if (bStartMin > startMin && bStartMin < maxAvailableMin) {
                    maxAvailableMin = bStartMin;
                }
            });

            endSelectEl.innerHTML = '<option value="">-- Chọn giờ kết thúc --</option>';
            for (let m = startMin + 30; m <= maxAvailableMin; m += 30) {
                const hour = Math.floor(m / 60);
                const min = m % 60;
                const timeStr = String(hour).padStart(2, "0") + ":" + String(min).padStart(2, "0");
                
                const opt = document.createElement("option");
                opt.value = timeStr;
                const durationMins = m - startMin;
                const durationText = formatDurationText(durationMins);
                opt.text = timeStr + ` (${durationText})`;
                endSelectEl.appendChild(opt);
            }
            
            checkScheduleAndPrice();
        }

        function onEndTimeSelectChange() {
            checkScheduleAndPrice();
        }

        function applyBranchTimeConstraints(branchId) {
            const { openTime, closeTime } = getBranchHours(branchId);
            const hoursLabel = document.getElementById("modal-branch-hours");

            if (hoursLabel) {
                hoursLabel.textContent = openTime.substring(0, 5) + " - " + closeTime.substring(0, 5);
            }

            const openMin = timeToMinutes(openTime);
            const closeMin = timeToMinutes(closeTime);
            const dateVal = document.getElementById("ngayDat").value;
            
            const courtId = selectedCourtId;
            const conflicts = activeBookings.filter(b => b.sanId === courtId && b.date === dateVal && b.status !== "Đã hủy");

            const startSelect = document.getElementById("gioBatDau");
            startSelect.innerHTML = '<option value="">-- Chọn giờ bắt đầu --</option>';
            
            let currentTotalMin = -1;
            if (dateVal === todayStr) {
                const now = new Date();
                currentTotalMin = now.getHours() * 60 + now.getMinutes();
            }

            for (let m = openMin; m <= closeMin - 30; m += 30) {
                const hour = Math.floor(m / 60);
                const min = m % 60;
                const timeStr = String(hour).padStart(2, "0") + ":" + String(min).padStart(2, "0");
                
                const isPast = m <= currentTotalMin;
                
                const isBooked = conflicts.some(b => {
                    const startB = timeToMinutes(b.start);
                    const endB = timeToMinutes(b.end);
                    return m >= startB && m < endB;
                });

                const opt = document.createElement("option");
                opt.value = timeStr;
                if (isPast) {
                    opt.disabled = true;
                    opt.text = timeStr + " (Đã qua)";
                } else if (isBooked) {
                    opt.disabled = true;
                    opt.text = timeStr + " (Đã có người đặt)";
                } else {
                    opt.text = timeStr;
                }
                startSelect.appendChild(opt);
            }

            // Reset values
            document.getElementById("gioBatDau").value = "";
            document.getElementById("gioKetThuc").value = "";
            
            const endSelectEl = document.getElementById("gioKetThuc");
            endSelectEl.innerHTML = `<option value="">Vui lòng chọn giờ bắt đầu trước</option>`;
        }

        function onBookingDateChange() {
            const court = courts.find(c => c.id === selectedCourtId);
            if (court) {
                applyBranchTimeConstraints(court.branchId);
            }
            checkScheduleAndPrice();
        }

        function timeToMinutes(timeStr) {
            const parts = timeStr.split(":");
            return parseInt(parts[0], 10) * 60 + parseInt(parts[1], 10);
        }

        function formatDurationText(totalMinutes) {
            const h = Math.floor(totalMinutes / 60);
            const m = totalMinutes % 60;
            let res = "";
            if (h > 0) res += h + ' tiếng ';
            if (m > 0) res += m + ' phút';
            return res.trim();
        }

        // Init - Debug logging
        console.log('[DatSan] courts loaded from server:', courts.length, courts);
        console.log('[DatSan] courtTypes:', courtTypes);
        console.log('[DatSan] branches:', branches);
        console.log('[DatSan] sports:', sports);
        
        // Render courts first, then apply filters
        renderCourts();
        filterBranch(selectedBranchId);
        filterSport(selectedSportId);

        // Auto open history modal if requested in URL
        window.addEventListener('DOMContentLoaded', () => {
            const urlParams = new URLSearchParams(window.location.search);
            if (urlParams.get('openHistory') === 'true') {
                openHistoryModal();
            }
        });
    </script>

    <!-- CUSTOMER SERVICE BOOKING MODAL -->
    <div id="customerServiceModal" class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-[60] hidden flex items-center justify-center opacity-0 transition-opacity duration-300 overflow-y-auto py-10 px-4">
        <div class="bg-white w-full max-w-2xl rounded-3xl shadow-2xl overflow-hidden transform scale-95 transition-all duration-300 relative my-auto">
            <div class="bg-gradient-to-r from-emerald-600 to-teal-600 px-6 py-4 flex items-center justify-between text-white">
                <h3 class="font-bold text-lg flex items-center gap-2">
                    <span class="material-symbols-outlined">coffee</span> Đặt thêm Dịch vụ / Nước uống
                </h3>
                <button onclick="closeCustomerServiceModal()" class="text-white/80 hover:text-white transition-colors p-1">
                    <span class="material-symbols-outlined">close</span>
                </button>
            </div>
            
            <div class="p-6 md:p-8 max-h-[70vh] overflow-y-auto">
                <form id="customer-service-form" action="${pageContext.request.contextPath}/customer/dat-dich-vu" method="post" class="space-y-6">
                    <input type="hidden" name="datSanId" id="customer-service-datsan-id">
                    
                    <div id="customer-service-loading" class="text-center py-10 text-slate-500">
                        <span class="material-symbols-outlined animate-spin text-[32px] text-emerald-600 mb-2">sync</span>
                        <p class="text-sm font-medium">Đang tải danh sách dịch vụ...</p>
                    </div>
                    
                    <div id="customer-service-container" class="hidden space-y-4">
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4" id="customer-products-grid">
                            <!-- Populated dynamically via JS -->
                        </div>
                    </div>
                    
                    <div class="pt-6 border-t border-slate-100 flex justify-between items-center">
                        <div>
                            <span class="text-xs font-bold text-slate-400 uppercase block">Tổng tiền dịch vụ thêm</span>
                            <span class="text-xl font-bold text-emerald-600" id="customer-service-total">0 đ</span>
                        </div>
                        <div class="flex gap-3">
                            <button type="button" onclick="closeCustomerServiceModal()" class="px-6 py-3 rounded-xl font-bold text-slate-600 bg-slate-100 hover:bg-slate-200 transition-colors">
                                Hủy
                            </button>
                            <button type="submit" class="px-8 py-3 rounded-xl font-bold text-white bg-emerald-600 hover:bg-emerald-700 transition-all shadow-md hover:shadow-emerald-600/20 active:scale-95 duration-200">
                                Xác nhận đặt
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
        let customerProducts = [];
        let customerOrdered = [];

        function openCustomerServiceModal(datSanId) {
            document.getElementById("customer-service-datsan-id").value = datSanId;
            
            const modal = document.getElementById("customerServiceModal");
            const loading = document.getElementById("customer-service-loading");
            const container = document.getElementById("customer-service-container");
            const grid = document.getElementById("customer-products-grid");
            
            modal.classList.remove("hidden");
            modal.classList.add("flex");
            loading.classList.remove("hidden");
            container.classList.add("hidden");
            
            setTimeout(() => {
                modal.classList.remove("opacity-0");
                modal.querySelector(".bg-white").classList.remove("scale-95");
            }, 10);

            // Fetch data
            fetch(`${pageContext.request.contextPath}/customer/dat-dich-vu?datSanId=${datSanId}`)
                .then(res => res.json())
                .then(data => {
                    customerProducts = data.products || [];
                    customerOrdered = data.ordered || [];
                    
                    loading.classList.add("hidden");
                    container.classList.remove("hidden");
                    
                    grid.innerHTML = "";
                    if (customerProducts.length === 0) {
                        grid.innerHTML = `<div class="col-span-2 text-center text-slate-400 py-8 italic">Cơ sở này hiện không có sản phẩm/dịch vụ nào đang kinh doanh.</div>`;
                        return;
                    }

                    customerProducts.forEach(prod => {
                        const ord = customerOrdered.find(o => o.SanPhamID === prod.SanPhamID);
                        const qty = ord ? ord.SoLuong : 0;
                        
                        const itemHtml = `
                            <div class="p-4 bg-slate-50 border border-slate-100 rounded-2xl flex items-center justify-between shadow-sm">
                                <div class="flex-grow min-w-0 pr-4">
                                    <h4 class="font-bold text-slate-800 text-sm truncate">${prod.TenSanPham}</h4>
                                    <p class="text-xs text-slate-500 mt-0.5">${prod.DonGia.toLocaleString('vi-VN')} đ / ${prod.DonViTinh || 'cái'}</p>
                                    <p class="text-[10px] text-slate-400 italic mt-0.5 truncate">${prod.MoTa || 'Sản phẩm phục vụ tại sân'}</p>
                                    <p class="text-[10px] text-slate-500 font-semibold mt-1">Còn lại: ${prod.SoLuongTon} ${prod.DonViTinh || 'cái'}</p>
                                </div>
                                <div class="flex items-center gap-2 shrink-0">
                                    <input type="hidden" name="productId" value="${prod.SanPhamID}">
                                    <button type="button" onclick="adjustCustomerQty(${prod.SanPhamID}, -1)" class="w-8 h-8 rounded-lg bg-slate-200 hover:bg-slate-300 text-slate-700 font-bold flex items-center justify-center transition-colors select-none">-</button>
                                    <input type="number" name="quantity" id="cust-qty-${prod.SanPhamID}" value="${qty}" min="0" max="${prod.SoLuongTon}" class="w-12 text-center bg-white border border-slate-200 rounded-lg py-1 text-sm font-bold" readonly>
                                    <button type="button" onclick="adjustCustomerQty(${prod.SanPhamID}, 1)" class="w-8 h-8 rounded-lg bg-slate-200 hover:bg-slate-300 text-slate-700 font-bold flex items-center justify-center transition-colors select-none">+</button>
                                </div>
                            </div>
                        `;
                        grid.insertAdjacentHTML("beforeend", itemHtml);
                    });
                    
                    recalculateCustomerTotal();
                })
                .catch(err => {
                    grid.innerHTML = `<div class="col-span-2 text-center text-red-500 py-8 italic">Có lỗi xảy ra khi tải dữ liệu: ${err.message}</div>`;
                    loading.classList.add("hidden");
                    container.classList.remove("hidden");
                });
        }

        function adjustCustomerQty(spId, delta) {
            const input = document.getElementById(`cust-qty-${spId}`);
            if (!input) return;
            
            const prod = customerProducts.find(p => p.SanPhamID === spId);
            if (!prod) return;
            
            let val = parseInt(input.value) || 0;
            val += delta;
            
            if (val < 0) val = 0;
            if (val > prod.SoLuongTon) {
                alert(`Không thể chọn vượt quá số lượng tồn kho (${prod.SoLuongTon})`);
                val = prod.SoLuongTon;
            }
            
            input.value = val;
            recalculateCustomerTotal();
        }

        function recalculateCustomerTotal() {
            let total = 0;
            customerProducts.forEach(prod => {
                const input = document.getElementById(`cust-qty-${prod.SanPhamID}`);
                const qty = input ? (parseInt(input.value) || 0) : 0;
                total += qty * prod.DonGia;
            });
            document.getElementById("customer-service-total").textContent = total.toLocaleString('vi-VN') + " đ";
        }

        function closeCustomerServiceModal() {
            const modal = document.getElementById("customerServiceModal");
            modal.classList.add("opacity-0");
            modal.querySelector(".bg-white").classList.add("scale-95");
            setTimeout(() => {
                modal.classList.add("hidden");
                modal.classList.remove("flex");
            }, 300);
        }
    </script>
</body>
</html>
