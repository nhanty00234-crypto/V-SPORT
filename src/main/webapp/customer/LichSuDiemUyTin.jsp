<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="vi" class="scroll-smooth">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lịch Sử Điểm Uy Tín & ELO - V-SPORT Elite Arena</title>
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <jsp:include page="/common/head.jsp" />
    <jsp:include page="/customer/common/vsport-theme.jsp" />
    <style>
        body {
            font-family: 'Inter', system-ui, -apple-system, sans-serif !important;
            background-color: #f1f5f9 !important;
            color: #0f172a !important;
        }
        .premium-card {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 16px;
        }
        .hs-hero {
            position: relative; overflow: hidden; color: #fff; border-radius: 20px;
            background: linear-gradient(135deg, #0f172a 0%, #1e293b 55%, #0284c7 100%);
        }
        .hs-filter-chip {
            display:inline-flex; align-items:center; gap:6px; padding:7px 14px; border-radius:9999px;
            font-size:12.5px; font-weight:700; color:#475569; background:#fff; border:1px solid #e2e8f0;
            cursor:pointer; white-space:nowrap; transition:all .15s ease;
        }
        .hs-filter-chip:hover { border-color:#0284c7; color:#0f172a; }
        .hs-filter-chip.is-active { background:#0284c7; border-color:#0284c7; color:#fff; }

        .rep-row {
            background:#fff; border:1px solid #e2e8f0; border-radius:14px; padding:14px 18px;
            transition: all .15s ease;
        }
        .rep-row:hover { border-color:#cbd5e1; box-shadow: 0 2px 8px rgba(0,0,0,0.04); }
    </style>
</head>
<body class="min-h-screen flex flex-col antialiased">

    <!-- Header Navigation -->
    <jsp:include page="/customer/common/vsport-header.jsp" />

    <!-- Main Content Area -->
    <main class="flex-grow pt-20 md:pt-24 pb-10">
        <div class="max-w-[1300px] mx-auto px-4 sm:px-6 lg:px-8">

            <!-- Breadcrumb -->
            <nav class="text-xs text-slate-500 mb-3 flex items-center gap-1.5" aria-label="Breadcrumb">
                <a href="${pageContext.request.contextPath}/index.jsp" class="hover:text-sky-600 transition-colors">Trang chủ</a>
                <span class="material-symbols-outlined text-[13px] text-slate-300">chevron_right</span>
                <a href="${pageContext.request.contextPath}/customer/lich-su-dat-san" class="hover:text-sky-600 transition-colors">Lịch sử</a>
                <span class="material-symbols-outlined text-[13px] text-slate-300">chevron_right</span>
                <span class="text-slate-700 font-semibold">Điểm uy tín & ELO</span>
            </nav>

            <!-- Hero Banner -->
            <div class="hs-hero mb-5 p-5 sm:p-7">
                <div class="relative z-10 max-w-2xl">
                    <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-white/15 border border-white/25 text-[11px] font-bold uppercase tracking-wider mb-3">
                        <span class="material-symbols-outlined text-[14px]">verified</span> Minh bạch & Công bằng
                    </span>
                    <h1 class="text-2xl sm:text-3xl font-black tracking-tight mb-2">Lịch Sử Điểm Uy Tín</h1>
                    <p class="text-white/80 text-xs sm:text-sm leading-relaxed">
                        Toàn bộ nhật ký biến động điểm uy tín, lịch sử trừ điểm do hủy sát giờ / không đến và các điều chỉnh hệ thống của bạn.
                    </p>
                </div>
            </div>

            <!-- Matchmaking Blocked Alert Banner if score < 60 -->
            <c:if test="${not canMatchmake}">
                <div class="mb-5 p-4 bg-amber-50 border border-amber-200 rounded-2xl text-amber-900 text-xs font-bold flex items-start gap-3 shadow-sm">
                    <span class="material-symbols-outlined text-amber-600 text-[22px] shrink-0 mt-0.5">warning</span>
                    <div>
                        <p class="font-extrabold text-sm text-amber-950">Tài khoản tạm thời bị hạn chế tính năng Ghép Kèo!</p>
                        <p class="mt-1 font-medium text-amber-800 leading-relaxed">
                            Điểm uy tín hiện tại của bạn là <span class="font-black text-amber-950">${currentScore}/100</span> (dưới ngưỡng tối thiểu 60 điểm). Bạn tạm thời không thể tạo hoặc xin tham gia kèo ghép. Hãy tích lũy điểm bằng cách hoàn thành các ca đặt sân trực tiếp.
                        </p>
                    </div>
                </div>
            </c:if>

            <!-- Main Layout -->
            <div class="grid grid-cols-1 lg:grid-cols-4 gap-5">

                <!-- Sidebar: Score Overview & Card -->
                <div class="lg:col-span-1 space-y-5 lg:sticky lg:top-24 lg:self-start">
                    <jsp:include page="/customer/common/reputation-card.jsp" />

                    <div class="premium-card p-5 space-y-3 text-xs text-slate-600">
                        <h4 class="font-bold text-slate-800 uppercase tracking-wider text-[11px] flex items-center gap-1.5">
                            <span class="material-symbols-outlined text-sky-600 text-[16px]">info</span> Quy định tính điểm
                        </h4>
                        <ul class="space-y-2 list-disc list-inside">
                            <li><span class="font-semibold text-slate-700">Hủy sớm (&ge; 24h):</span> 0 điểm</li>
                            <li><span class="font-semibold text-slate-700">Hủy 6h - 24h:</span> -5 điểm</li>
                            <li><span class="font-semibold text-slate-700">Hủy sát giờ (&lt; 6h):</span> -10 điểm</li>
                            <li><span class="font-semibold text-slate-700">Khách không đến:</span> -20 điểm</li>
                            <li><span class="font-semibold text-emerald-600">Hoàn thành ca đá:</span> +2 điểm</li>
                        </ul>
                    </div>
                </div>

                <!-- Main Content: Reputation Audit Log -->
                <div class="lg:col-span-3">
                    <div class="premium-card p-5 sm:p-6">

                        <!-- Filter Chips -->
                        <div class="flex items-center justify-between gap-3 mb-5 flex-wrap">
                            <h2 class="text-sm font-extrabold text-slate-900 tracking-tight flex items-center gap-2">
                                <span class="material-symbols-outlined text-sky-600 text-[19px]">history</span>
                                Nhật ký thay đổi điểm
                            </h2>

                            <div class="flex items-center gap-2 overflow-x-auto pb-1">
                                <a href="?type=ALL" class="hs-filter-chip ${actionFilter == 'ALL' ? 'is-active' : ''}">Tất cả</a>
                                <a href="?type=CANCEL_6_TO_24" class="hs-filter-chip ${actionFilter == 'CANCEL_6_TO_24' ? 'is-active' : ''}">Hủy 6-24h</a>
                                <a href="?type=LATE_CANCEL" class="hs-filter-chip ${actionFilter == 'LATE_CANCEL' ? 'is-active' : ''}">Hủy &lt;6h</a>
                                <a href="?type=NO_SHOW" class="hs-filter-chip ${actionFilter == 'NO_SHOW' ? 'is-active' : ''}">Không đến</a>
                                <a href="?type=COMPLETED_BOOKING" class="hs-filter-chip ${actionFilter == 'COMPLETED_BOOKING' ? 'is-active' : ''}">Hoàn thành</a>
                                <a href="?type=MANUAL_ADJUST" class="hs-filter-chip ${actionFilter == 'MANUAL_ADJUST' ? 'is-active' : ''}">Đổi thủ công</a>
                            </div>
                        </div>

                        <!-- Audit History Rows -->
                        <div class="space-y-3">
                            <c:forEach var="item" items="${historyList}">
                                <div class="rep-row flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                                    <div class="space-y-1">
                                        <div class="flex items-center gap-2 flex-wrap">
                                            <c:choose>
                                                <c:when test="${item.scoreDelta > 0}">
                                                    <span class="px-2.5 py-0.5 rounded-full text-[11px] font-black bg-emerald-100 text-emerald-800 flex items-center gap-1">
                                                        <span class="material-symbols-outlined text-[13px]">add_circle</span> +${item.scoreDelta} điểm
                                                    </span>
                                                </c:when>
                                                <c:when test="${item.scoreDelta < 0}">
                                                    <span class="px-2.5 py-0.5 rounded-full text-[11px] font-black bg-rose-100 text-rose-800 flex items-center gap-1">
                                                        <span class="material-symbols-outlined text-[13px]">remove_circle</span> ${item.scoreDelta} điểm
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="px-2.5 py-0.5 rounded-full text-[11px] font-black bg-slate-100 text-slate-700">
                                                        0 điểm
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>

                                            <span class="text-xs font-bold text-slate-800">${item.reason}</span>
                                        </div>

                                        <div class="text-[11px] text-slate-500 flex items-center gap-3 flex-wrap font-medium">
                                            <span>
                                                <span class="material-symbols-outlined text-[13px] text-slate-400 align-sub">schedule</span>
                                                <c:out value="${item.createdAt}" />
                                            </span>
                                            <c:if test="${not empty item.datSanId}">
                                                <a href="${pageContext.request.contextPath}/customer/lich-su-dat-san#booking-${item.datSanId}" class="text-sky-600 font-semibold hover:underline">
                                                    Đơn đặt sân #${item.datSanId}
                                                </a>
                                            </c:if>
                                        </div>
                                    </div>

                                    <div class="text-right shrink-0 font-mono text-xs">
                                        <span class="text-slate-400 font-semibold">${item.scoreBefore}</span>
                                        <span class="material-symbols-outlined text-[12px] text-slate-300 mx-1">arrow_forward</span>
                                        <span class="font-extrabold text-slate-900 text-sm">${item.scoreAfter}</span>
                                    </div>
                                </div>
                            </c:forEach>

                            <c:if test="${empty historyList}">
                                <div class="p-12 text-center bg-slate-50 rounded-2xl border border-dashed border-slate-200">
                                    <span class="material-symbols-outlined text-[36px] text-slate-300 block mb-2">history_toggle_off</span>
                                    <p class="text-xs text-slate-500 font-bold">Chưa có nhật ký biến động điểm uy tín nào.</p>
                                </div>
                            </c:if>
                        </div>

                    </div>
                </div>

            </div>
        </div>
    </main>

    <!-- Footer -->
    <jsp:include page="/common/footer.jsp" />
    <jsp:include page="/customer/common/bottom-nav.jsp" />
</body>
</html>
