<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đánh giá & Phản hồi Khách hàng - V-SPORT Manager</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0,0" />
    <style>body { font-family: 'Inter', sans-serif; }</style>
</head>
<body class="bg-slate-50 text-slate-800">
    <div class="flex min-h-screen">
        <%@ include file="/manager/common/sidebar.jsp" %>
        
        <main class="flex-1 p-6 md:p-8 overflow-y-auto">
            <div class="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-8">
                <div>
                    <h1 class="text-2xl font-bold text-slate-900">Đánh giá & Phản hồi Khách hàng</h1>
                    <p class="text-slate-500 text-sm mt-1">Theo dõi chất lượng dịch vụ và phản hồi từ người chơi tại chi nhánh</p>
                </div>
            </div>

            <!-- Summary Stats -->
            <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                <div class="bg-white p-6 rounded-2xl border border-slate-200/80 shadow-sm flex items-center gap-4">
                    <div class="w-12 h-12 rounded-xl bg-amber-50 text-amber-500 flex items-center justify-center">
                        <span class="material-symbols-outlined text-2xl">star</span>
                    </div>
                    <div>
                        <div class="text-2xl font-bold text-slate-900">${avgRating} / 5.0</div>
                        <div class="text-xs font-medium text-slate-400">Điểm đánh giá trung bình</div>
                    </div>
                </div>
                <div class="bg-white p-6 rounded-2xl border border-slate-200/80 shadow-sm flex items-center gap-4">
                    <div class="w-12 h-12 rounded-xl bg-blue-50 text-blue-600 flex items-center justify-center">
                        <span class="material-symbols-outlined text-2xl">rate_review</span>
                    </div>
                    <div>
                        <div class="text-2xl font-bold text-slate-900">${totalReviews}</div>
                        <div class="text-xs font-medium text-slate-400">Tổng số lượt đánh giá</div>
                    </div>
                </div>
                <div class="bg-white p-6 rounded-2xl border border-slate-200/80 shadow-sm flex items-center gap-4">
                    <div class="w-12 h-12 rounded-xl bg-emerald-50 text-emerald-600 flex items-center justify-center">
                        <span class="material-symbols-outlined text-2xl">verified</span>
                    </div>
                    <div>
                        <div class="text-2xl font-bold text-emerald-600">Đã xác minh</div>
                        <div class="text-xs font-medium text-slate-400">Tự động đồng bộ từ lịch đặt sân</div>
                    </div>
                </div>
            </div>

            <!-- Review Cards List -->
            <div class="bg-white rounded-2xl border border-slate-200/80 shadow-sm overflow-hidden">
                <div class="p-5 border-b border-slate-100 font-semibold text-slate-900 flex items-center justify-between">
                    <span>Danh sách ý kiến phản hồi</span>
                </div>
                <c:if test="${empty dsDanhGia}">
                    <div class="p-12 text-center text-slate-400">
                        <span class="material-symbols-outlined text-4xl mb-2 text-slate-300">reviews</span>
                        <p>Chưa có đánh giá nào cho chi nhánh này.</p>
                    </div>
                </c:if>
                <div class="divide-y divide-slate-100">
                    <c:forEach var="dg" items="${dsDanhGia}">
                        <div class="p-6 hover:bg-slate-50/50 transition-colors">
                            <div class="flex items-start justify-between gap-4 mb-2">
                                <div class="flex items-center gap-3">
                                    <div class="w-10 h-10 rounded-full bg-slate-200 text-slate-600 font-bold flex items-center justify-center text-sm">
                                        ${dg.accountIdNguoiDanhGia}
                                    </div>
                                    <div>
                                        <div class="font-semibold text-slate-900 text-sm">Khách hàng #${dg.accountIdNguoiDanhGia}</div>
                                        <div class="text-xs text-slate-400">${dg.ngayDanhGia}</div>
                                    </div>
                                </div>
                                <div class="flex items-center text-amber-400">
                                    <c:forEach begin="1" end="${dg.soSao}">
                                        <span class="material-symbols-outlined text-lg fill-1">star</span>
                                    </c:forEach>
                                </div>
                            </div>
                            <p class="text-slate-600 text-sm mt-3 pl-13">${dg.binhLuan}</p>
                        </div>
                    </c:forEach>
                </div>
            </div>
        </main>
    </div>
</body>
</html>
