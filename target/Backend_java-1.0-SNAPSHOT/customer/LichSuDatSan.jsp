<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi" class="scroll-smooth">
<head>
    <title>Lịch Sử Đặt Sân - V-SPORT Elite Arena</title>
    <jsp:include page="/common/head.jsp" />
    <style>
        .history-card {
            background: white;
            border: 1px solid white;
            border-radius: 32px;
            box-shadow: 0 20px 50px rgba(42, 42, 42, 0.03);
            overflow: hidden;
        }
        .status-badge {
            padding: 4px 14px;
            border-radius: 8px;
            font-size: 10px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.1em;
        }
        .status-pending { background-color: #fef3c7; color: #b45309; }
        .status-confirmed { background-color: #dcfce7; color: #15803d; }
        .status-cancelled { background-color: #fee2e2; color: #b91c1c; }
        
        .table-th {
            padding: 1.5rem 2rem;
            font-size: 10px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.2em;
            color: rgba(42, 42, 42, 0.3);
        }
    </style>
</head>
<body class="bg-[#f4f4ef] text-[#2a2a2a] min-h-screen flex flex-col antialiased">

    <jsp:include page="/common/header.jsp" />

    <main class="flex-grow pt-[160px] pb-24">
        <div class="max-w-[1300px] mx-auto px-6">
            
            <!-- Page Header -->
            <div class="mb-12 animate-fade-in-up">
                <div class="inline-flex items-center gap-2 px-3 py-1 rounded-full border border-[#2a2a2a]/5 bg-white/50 backdrop-blur-sm mb-6">
                    <div class="w-1 h-1 rounded-full bg-[#2563eb]"></div>
                    <span class="text-[9px] font-bold uppercase tracking-[0.2em] text-[#2a2a2a]/40">Your Activity</span>
                </div>
                <h1 class="text-[56px] lg:text-[72px] font-serif leading-[1.1] text-[#2a2a2a]">
                    Lịch sử <br/>
                    <i class="italic text-[#2563eb]">đặt sân của bạn.</i>
                </h1>

                <c:if test="${not empty sessionScope.message}">
                    <div class="mt-8 p-5 bg-[#dcfce7] border border-[#dcfce7] rounded-[20px] text-[#15803d] text-[14px] flex items-center gap-4 animate-fade-in-up">
                        <span class="material-symbols-outlined text-[20px]">check_circle</span>
                        <span class="font-medium">${sessionScope.message}</span>
                        <% session.removeAttribute("message"); %>
                    </div>
                </c:if>
            </div>

            <!-- Table Section -->
            <div class="history-card animate-fade-in-up" style="animation-delay: 0.1s">
                <div class="overflow-x-auto">
                    <table class="w-full text-left border-collapse">
                        <thead>
                            <tr class="bg-[#fcfcf9] border-b border-[#2a2a2a]/5">
                                <th class="px-8 py-6 text-[10px] font-bold uppercase tracking-[0.2em] text-[#2a2a2a]/30">Chi tiết sân</th>
                                <th class="px-8 py-6 text-[10px] font-bold uppercase tracking-[0.2em] text-[#2a2a2a]/30">Thời gian</th>
                                <th class="px-8 py-6 text-[10px] font-bold uppercase tracking-[0.2em] text-[#2a2a2a]/30">Chi phí</th>
                                <th class="px-8 py-6 text-[10px] font-bold uppercase tracking-[0.2em] text-[#2a2a2a]/30">Trạng thái</th>
                                <th class="px-8 py-6 text-right text-[10px] font-bold uppercase tracking-[0.2em] text-[#2a2a2a]/30">Hành động</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-[#2a2a2a]/5">
                            <c:forEach var="lich" items="${dsLich}">
                                <%-- Tìm tên sân và Cơ Sở tương ứng với mỗi lịch đặt --%>
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

                                <tr class="group hover:bg-[#fcfcf9] transition-colors">
                                    <td class="px-8 py-8">
                                        <div class="flex flex-col gap-1">
                                            <span class="text-[15px] font-bold text-[#2a2a2a]">${tenSanHienThi}</span>
                                            <span class="text-[12px] text-[#2a2a2a]/40 font-medium flex items-center gap-1">
                                                <c:if test="${not empty branchHienThi}">
                                                    <span class="material-symbols-outlined text-[13px]">location_on</span>
                                                    ${branchHienThi} &middot;
                                                </c:if>
                                                Mã ĐS: #${lich.datSanId}
                                            </span>
                                        </div>
                                    </td>
                                    <td class="px-8 py-8">
                                        <div class="flex flex-col gap-1">
                                            <span class="text-[15px] text-[#2a2a2a]/80">${lich.ngayDat}</span>
                                            <span class="text-[13px] text-[#2563eb] font-bold">${lich.gioBatDau} — ${lich.gioKetThuc}</span>
                                        </div>
                                    </td>
                                    <td class="px-8 py-8">
                                        <span class="text-[15px] font-bold text-[#2a2a2a]">
                                            <fmt:formatNumber value="${lich.tongTienDuKien}" type="currency" currencySymbol="đ" />
                                        </span>
                                    </td>
                                    <td class="px-8 py-8">
                                        <c:choose>
                                            <c:when test="${lich.trangThai == 'Chờ xác nhận'}">
                                                <span class="status-badge status-pending">Đang chờ</span>
                                            </c:when>
                                            <c:when test="${lich.trangThai == 'Đã xác nhận' || lich.trangThai == 'Đã đặt'}">
                                                <span class="status-badge status-confirmed">Đã duyệt</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="status-badge status-cancelled">${lich.trangThai}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="px-8 py-8 text-right">
                                        <c:if test="${lich.trangThai == 'Chờ xác nhận'}">
                                            <form action="${pageContext.request.contextPath}/customer/huy-dat-san" method="post" onsubmit="return confirm('Xác nhận hủy yêu cầu đặt sân này?')">
                                                <input type="hidden" name="id" value="${lich.datSanId}">
                                                <button type="submit" class="h-10 px-6 rounded-xl border border-red-100 text-red-500 text-[11px] font-bold uppercase tracking-widest hover:bg-red-500 hover:text-white transition-all">
                                                    Hủy yêu cầu
                                                </button>
                                            </form>
                                        </c:if>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty dsLich}">
                                <tr>
                                    <td colspan="5" class="px-8 py-32 text-center">
                                        <span class="material-symbols-outlined text-[48px] text-[#2a2a2a]/5 block mb-6">event_busy</span>
                                        <p class="text-[#2a2a2a]/20 text-[12px] font-bold uppercase tracking-[0.3em]">Chưa có dữ liệu lịch sử</p>
                                        <a href="${pageContext.request.contextPath}/customer/dat-san" class="inline-flex items-center gap-2 mt-8 text-[#2563eb] text-[13px] font-bold uppercase tracking-widest hover:underline">
                                            Đặt sân ngay bây giờ <span class="material-symbols-outlined text-[18px]">arrow_right_alt</span>
                                        </a>
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </main>

    <footer class="py-12 px-6 border-t border-[#2a2a2a]/5 mt-20">
        <div class="max-w-[1400px] mx-auto flex flex-col md:flex-row justify-between items-center gap-8">
            <div class="flex flex-col md:flex-row items-center gap-4">
                <span class="text-[14px] font-bold text-[#2a2a2a] tracking-widest uppercase">Hệ thống V-Sport</span>
                <span class="hidden md:block w-[1px] h-4 bg-[#2a2a2a]/10"></span>
                <span class="text-[11px] font-medium text-[#2a2a2a]/40 uppercase tracking-widest">&copy; 2026 Elite Management Hub.</span>
            </div>
            <div class="flex gap-8 text-[11px] font-bold uppercase tracking-widest text-[#2a2a2a]/40">
                <a href="#" class="hover:text-[#2a2a2a] transition-colors">Bảo mật</a>
                <a href="#" class="hover:text-[#2a2a2a] transition-colors">Điều khoản</a>
            </div>
        </div>
    </footer>

</body>
</html>
