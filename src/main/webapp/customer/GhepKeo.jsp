<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="vi" class="scroll-smooth">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ghép kèo - V-SPORT</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <jsp:include page="/common/head.jsp" />
    <jsp:include page="/customer/common/vsport-theme.jsp" />
    <style>
        body {
            font-family: 'Inter', system-ui, -apple-system, sans-serif !important;
            background-color: #f1f5f9 !important;
            color: #0f172a !important;
        }
        .acc-card { background: #ffffff; border: 1px solid #e2e8f0; border-radius: 16px; }
        .acc-input {
            width: 100%; height: 42px; padding: 0 14px; border-radius: 10px;
            border: 1px solid #cbd5e1; background: #fff; font-size: 14px; color: #0f172a;
            transition: border-color .15s ease, box-shadow .15s ease;
        }
        .acc-input:focus { outline: none; border-color: #10b981; box-shadow: 0 0 0 3px rgba(16,185,129,.12); }
        .acc-label { display:block; font-size: 12px; font-weight: 700; color: #475569; margin-bottom: 6px; }
        .btn-primary {
            display:inline-flex; align-items:center; justify-content:center; gap:6px;
            background:#047857; color:#fff; font-weight:700; font-size:13px;
            padding: 10px 18px; border-radius: 10px; transition: background .15s ease, transform .1s ease;
        }
        .btn-primary:hover { background:#065f46; }
        .btn-primary:active { transform: scale(.97); }
        .btn-primary:disabled { opacity:.55; cursor:not-allowed; }
        .btn-secondary {
            display:inline-flex; align-items:center; justify-content:center; gap:6px;
            background:#fff; color:#334155; font-weight:700; font-size:13px;
            padding: 10px 18px; border-radius: 10px; border:1px solid #cbd5e1; transition: background .15s ease;
        }
        .btn-secondary:hover { background:#f8fafc; }
        .gk-tab {
            display: inline-flex; align-items: center; gap: 8px;
            padding: 10px 18px; border-radius: 10px; font-size: 13px; font-weight: 700;
            color: #64748b; white-space: nowrap; transition: all .15s ease; cursor: pointer; border: none; background: transparent;
        }
        .gk-tab:hover { background: #f1f5f9; color: #0f172a; }
        .gk-tab.active { background: #047857; color: #fff; }
        .gk-panel { display: none; }
        .gk-panel.active { display: block; }
        #gkToast { transition: opacity .25s ease, transform .25s ease; }

        .gk-hero {
            position: relative; overflow: hidden; color: #fff; border-radius: 20px;
            background: linear-gradient(135deg, #065f46 0%, #0f766e 55%, #047857 100%);
        }
        .gk-hero::after {
            content: ""; position: absolute; right: -50px; top: -50px; width: 200px; height: 200px;
            background: radial-gradient(circle, rgba(255,255,255,.14), transparent 68%); pointer-events: none;
        }

        /* Match card */
        .gk-match-card {
            background:#fff; border:1px solid #e2e8f0; border-radius:16px; padding:18px;
            display:flex; flex-direction:column; gap:12px; transition: border-color .15s ease, transform .1s ease;
        }
        .gk-match-card:hover { border-color:#a7f3d0; transform: translateY(-1px); }
        .gk-match-meta { display:flex; flex-wrap:wrap; gap:6px 14px; font-size:12.5px; color:#475569; font-weight:600; }
        .gk-match-meta .material-symbols-outlined { font-size:15px; color:#94a3b8; vertical-align:-3px; margin-right:3px; }
        .gk-slot-bar { height:6px; border-radius:9999px; background:#e2e8f0; overflow:hidden; }
        .gk-slot-fill { height:100%; background:#047857; border-radius:9999px; }
    </style>
</head>
<body class="min-h-screen flex flex-col antialiased">

<jsp:include page="/common/header.jsp" />

<main class="flex-grow pt-20 md:pt-24 pb-10">
    <div class="max-w-[1180px] mx-auto px-4 sm:px-6 lg:px-8">

        <!-- Breadcrumb -->
        <nav class="text-xs text-slate-500 mb-3 flex items-center gap-1.5" aria-label="Breadcrumb">
            <a href="${pageContext.request.contextPath}/index.jsp" class="hover:text-emerald-600 transition-colors">Trang chủ</a>
            <span class="material-symbols-outlined text-[13px] text-slate-300">chevron_right</span>
            <span class="text-slate-700 font-semibold">Ghép kèo</span>
        </nav>

        <!-- Hero -->
        <div class="gk-hero mb-5 p-5 sm:p-7">
            <div class="relative z-10 max-w-2xl">
                <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-white/15 border border-white/25 text-[11px] font-bold uppercase tracking-wider mb-3">
                    <span class="material-symbols-outlined text-[14px]">groups</span> Cộng đồng V-SPORT
                </span>
                <h1 class="text-2xl sm:text-3xl font-black tracking-tight mb-2">Ghép kèo &amp; tìm đối thủ</h1>
                <p class="text-white/80 text-xs sm:text-sm leading-relaxed">
                    Tìm bạn chơi, tạo kèo giao lưu và ghép đối thủ phù hợp trình độ. Điểm uy tín của bạn giúp hệ thống ghép người chơi an toàn hơn cho mọi người.
                </p>
            </div>
        </div>

        <!-- Tabs -->
        <div class="acc-card p-2 mb-5 flex items-center gap-1 overflow-x-auto">
            <button type="button" class="gk-tab" data-tab="dang-mo">
                <span class="material-symbols-outlined text-[16px]">sports</span> Kèo đang mở
            </button>
            <button type="button" class="gk-tab" data-tab="tao-keo">
                <span class="material-symbols-outlined text-[16px]">add_circle</span> Tạo kèo
            </button>
            <button type="button" class="gk-tab" data-tab="tim-doi-thu">
                <span class="material-symbols-outlined text-[16px]">person_search</span> Tìm đối thủ gần nhất
            </button>
            <button type="button" class="gk-tab" data-tab="cua-toi">
                <span class="material-symbols-outlined text-[16px]">bookmark</span> Kèo của tôi
            </button>
        </div>

        <!-- Panel: Kèo đang mở -->
        <div class="gk-panel" id="panel-dang-mo">
            <div class="acc-card p-4 mb-5 bg-emerald-50/60 border-emerald-100 flex items-start gap-3">
                <span class="material-symbols-outlined text-emerald-600 text-[20px] mt-0.5">info</span>
                <p class="text-xs text-emerald-800 leading-relaxed">Danh sách kèo đang mở là dữ liệu thật khi có kèo được tạo. Backend ghép kèo (GhepKeo/ChiTietGhepKeo) đang được hoàn thiện. Giao diện thẻ kèo bên dưới minh họa cách kèo thật sẽ hiển thị.</p>
            </div>

            <p class="text-[11px] font-extrabold text-slate-400 uppercase tracking-wide mb-3">Ví dụ minh họa giao diện thẻ kèo</p>
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-8">
                <div class="gk-match-card opacity-80 pointer-events-none">
                    <div class="flex items-center justify-between">
                        <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg bg-slate-100 text-slate-600 text-[11px] font-bold">
                            <span class="material-symbols-outlined text-[14px]">sports_soccer</span> Bóng đá 5 người
                        </span>
                        <span class="inline-flex items-center gap-1 px-2.5 py-1 rounded-full bg-emerald-50 text-emerald-700 text-[10px] font-bold">
                            <span class="material-symbols-outlined text-[12px]">verified</span> Chủ kèo: 92/100
                        </span>
                    </div>
                    <p class="text-sm font-bold text-slate-800">Sân V-SPORT Cầu Giấy &middot; Sân số 2</p>
                    <div class="gk-match-meta">
                        <span><span class="material-symbols-outlined">calendar_month</span>Thứ Bảy, 20:00 - 21:30</span>
                        <span><span class="material-symbols-outlined">signal_cellular_alt</span>Trình độ: Trung bình</span>
                        <span><span class="material-symbols-outlined">near_me</span>Khoảng cách: chưa khả dụng</span>
                    </div>
                    <div>
                        <div class="flex items-center justify-between text-[11px] font-bold text-slate-500 mb-1.5">
                            <span>3/8 người tham gia</span><span>Cần thêm 5</span>
                        </div>
                        <div class="gk-slot-bar"><div class="gk-slot-fill" style="width:37.5%"></div></div>
                    </div>
                    <div class="flex gap-2 pt-1">
                        <button type="button" disabled class="btn-secondary flex-1">Xem kèo</button>
                        <button type="button" disabled class="btn-primary flex-1">Xin tham gia</button>
                    </div>
                </div>
                <div class="gk-match-card opacity-80 pointer-events-none">
                    <div class="flex items-center justify-between">
                        <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg bg-slate-100 text-slate-600 text-[11px] font-bold">
                            <span class="material-symbols-outlined text-[14px]">sports_tennis</span> Pickleball đôi
                        </span>
                        <span class="inline-flex items-center gap-1 px-2.5 py-1 rounded-full bg-emerald-50 text-emerald-700 text-[10px] font-bold">
                            <span class="material-symbols-outlined text-[12px]">verified</span> Chủ kèo: 87/100
                        </span>
                    </div>
                    <p class="text-sm font-bold text-slate-800">Sân V-SPORT Thanh Xuân &middot; Sân số 1</p>
                    <div class="gk-match-meta">
                        <span><span class="material-symbols-outlined">calendar_month</span>Chủ Nhật, 07:00 - 08:30</span>
                        <span><span class="material-symbols-outlined">signal_cellular_alt</span>Trình độ: Khá</span>
                        <span><span class="material-symbols-outlined">near_me</span>Khoảng cách: chưa khả dụng</span>
                    </div>
                    <div>
                        <div class="flex items-center justify-between text-[11px] font-bold text-slate-500 mb-1.5">
                            <span>2/4 người tham gia</span><span>Cần thêm 2</span>
                        </div>
                        <div class="gk-slot-bar"><div class="gk-slot-fill" style="width:50%"></div></div>
                    </div>
                    <div class="flex gap-2 pt-1">
                        <button type="button" disabled class="btn-secondary flex-1">Xem kèo</button>
                        <button type="button" disabled class="btn-primary flex-1">Xin tham gia</button>
                    </div>
                </div>
            </div>

            <div class="acc-card text-center py-14">
                <span class="material-symbols-outlined text-[40px] text-slate-200 block mb-3">event_available</span>
                <p class="text-sm text-slate-400 font-semibold">Hiện chưa có kèo thật nào đang mở.</p>
            </div>
        </div>

        <!-- Panel: Tạo kèo -->
        <div class="gk-panel" id="panel-tao-keo">
            <div class="grid grid-cols-1 lg:grid-cols-3 gap-5">
                <div class="acc-card p-6 lg:col-span-2">
                    <h3 class="text-sm font-extrabold text-slate-900 mb-5 flex items-center gap-2">
                        <span class="material-symbols-outlined text-emerald-600 text-[18px]">add_circle</span>
                        Thông tin kèo
                    </h3>
                    <form onsubmit="return submitGhepKeoDemo(event, 'Đã ghi nhận yêu cầu tạo kèo', 'Chức năng tạo kèo thật đang được phát triển. Chúng tôi sẽ thông báo khi có người tham gia.')" class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                        <div>
                            <label class="acc-label">Môn thể thao</label>
                            <select class="acc-input" required>
                                <option value="">-- Chọn môn --</option>
                                <option>Bóng đá</option>
                                <option>Cầu lông</option>
                                <option>Tennis</option>
                                <option>Bóng rổ</option>
                                <option>Pickleball</option>
                            </select>
                        </div>
                        <div>
                            <label class="acc-label">Cơ sở</label>
                            <select class="acc-input">
                                <option value="">-- Chọn cơ sở --</option>
                                <c:forEach var="cs" items="${dsCoSo}">
                                    <option value="${cs.coSoID}">${fn:escapeXml(cs.tenCoSo)}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div>
                            <label class="acc-label">Thời gian chơi</label>
                            <input type="datetime-local" class="acc-input" required>
                        </div>
                        <div>
                            <label class="acc-label">Số người cần tìm</label>
                            <input type="number" class="acc-input" min="1" max="20" value="2">
                        </div>
                        <div class="sm:col-span-2">
                            <label class="acc-label">Trình độ mong muốn</label>
                            <select class="acc-input">
                                <option>Không yêu cầu</option>
                                <option>Mới chơi</option>
                                <option>Trung bình</option>
                                <option>Khá</option>
                                <option>Giỏi</option>
                            </select>
                        </div>
                        <div class="sm:col-span-2">
                            <label class="acc-label">Ghi chú (không bắt buộc)</label>
                            <textarea class="acc-input" style="height:80px; padding-top:10px;" maxlength="255" placeholder="Ví dụ: sân có mái che, mang theo lưới..."></textarea>
                        </div>
                        <div class="sm:col-span-2 pt-2">
                            <button type="submit" class="btn-primary w-full sm:w-auto">
                                <span class="material-symbols-outlined text-[16px]">add_circle</span> Tạo kèo
                            </button>
                        </div>
                    </form>
                </div>
                <div class="acc-card p-6 bg-slate-50/60">
                    <h4 class="text-[11px] font-extrabold text-slate-500 uppercase tracking-wide mb-3">Kèo hoạt động thế nào?</h4>
                    <p class="text-xs text-slate-600 flex items-start gap-2 mb-2"><span class="material-symbols-outlined text-emerald-600 text-[15px] mt-0.5">looks_one</span> Bạn tạo kèo với sân, giờ chơi và số người cần thêm.</p>
                    <p class="text-xs text-slate-600 flex items-start gap-2 mb-2"><span class="material-symbols-outlined text-emerald-600 text-[15px] mt-0.5">looks_two</span> Người chơi phù hợp trình độ sẽ thấy kèo của bạn ở tab "Kèo đang mở".</p>
                    <p class="text-xs text-slate-600 flex items-start gap-2"><span class="material-symbols-outlined text-emerald-600 text-[15px] mt-0.5">looks_3</span> Bạn duyệt yêu cầu tham gia trong "Kèo của tôi".</p>
                </div>
            </div>
        </div>

        <!-- Panel: Tìm đối thủ gần nhất -->
        <div class="gk-panel" id="panel-tim-doi-thu">
            <div class="grid grid-cols-1 lg:grid-cols-3 gap-5">
                <div class="acc-card p-6 lg:col-span-2">
                    <h3 class="text-sm font-extrabold text-slate-900 mb-2 flex items-center gap-2">
                        <span class="material-symbols-outlined text-emerald-600 text-[18px]">person_search</span>
                        Tìm đối thủ gần nhất
                    </h3>
                    <p class="text-xs text-slate-500 mb-5 leading-relaxed">Chức năng tìm đối thủ gần nhất sẽ dùng vị trí, môn thể thao, trình độ và điểm uy tín để đề xuất người chơi phù hợp. Vị trí chính xác của người chơi khác sẽ không bao giờ được hiển thị, chỉ khoảng cách ước tính.</p>
                    <form onsubmit="return submitGhepKeoDemo(event, 'Đã gửi yêu cầu tìm đối thủ', 'Chúng tôi sẽ đề xuất người chơi phù hợp ngay khi chức năng này hoàn tất.')" class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                        <div>
                            <label class="acc-label">Môn thể thao</label>
                            <select class="acc-input" required>
                                <option value="">-- Chọn môn --</option>
                                <option>Bóng đá</option>
                                <option>Cầu lông</option>
                                <option>Tennis</option>
                                <option>Bóng rổ</option>
                                <option>Pickleball</option>
                            </select>
                        </div>
                        <div>
                            <label class="acc-label">Khu vực / Cơ sở</label>
                            <select class="acc-input">
                                <option value="">-- Chọn khu vực --</option>
                                <c:forEach var="cs" items="${dsCoSo}">
                                    <option value="${cs.coSoID}">${fn:escapeXml(cs.tenCoSo)}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div>
                            <label class="acc-label">Trình độ</label>
                            <select class="acc-input">
                                <option>Không yêu cầu</option>
                                <option>Mới chơi</option>
                                <option>Trung bình</option>
                                <option>Khá</option>
                                <option>Giỏi</option>
                            </select>
                        </div>
                        <div>
                            <label class="acc-label">Bán kính tìm kiếm</label>
                            <select class="acc-input">
                                <option>Trong vòng 2km</option>
                                <option>Trong vòng 5km</option>
                                <option>Trong vòng 10km</option>
                                <option>Toàn thành phố</option>
                            </select>
                        </div>
                        <div class="sm:col-span-2 flex flex-col sm:flex-row gap-3 pt-2">
                            <button type="submit" class="btn-primary flex-1">
                                <span class="material-symbols-outlined text-[16px]">search</span> Tìm đối thủ
                            </button>
                            <button type="button" onclick="useCurrentLocationDemo()" class="btn-secondary flex-1">
                                <span class="material-symbols-outlined text-[16px]">my_location</span> Dùng vị trí hiện tại
                            </button>
                        </div>
                    </form>
                </div>
                <div class="acc-card p-6 bg-slate-50/60">
                    <h4 class="text-[11px] font-extrabold text-slate-500 uppercase tracking-wide mb-3">Về quyền riêng tư</h4>
                    <p class="text-xs text-slate-600 flex items-start gap-2 mb-2"><span class="material-symbols-outlined text-emerald-600 text-[15px] mt-0.5">shield</span> Không hiển thị tọa độ chính xác hay địa chỉ nhà của người chơi khác.</p>
                    <p class="text-xs text-slate-600 flex items-start gap-2 mb-2"><span class="material-symbols-outlined text-emerald-600 text-[15px] mt-0.5">location_off</span> Chỉ dùng khoảng cách hoặc khu vực gần đúng.</p>
                    <p class="text-xs text-slate-600 flex items-start gap-2"><span class="material-symbols-outlined text-emerald-600 text-[15px] mt-0.5">check_circle</span> Vị trí chỉ được lấy khi bạn đồng ý chia sẻ.</p>
                </div>
            </div>
        </div>

        <!-- Panel: Kèo của tôi -->
        <div class="gk-panel" id="panel-cua-toi">
            <div class="acc-card text-center py-16">
                <span class="material-symbols-outlined text-[40px] text-slate-200 block mb-3">bookmark_border</span>
                <p class="text-sm text-slate-400 font-semibold mb-4">Bạn chưa tạo hoặc tham gia kèo nào.</p>
                <button type="button" class="gk-tab-link btn-primary inline-flex" data-goto-tab="tao-keo">
                    <span class="material-symbols-outlined text-[16px]">add_circle</span> Tạo kèo đầu tiên
                </button>
            </div>
        </div>

    </div>
</main>

<jsp:include page="/common/footer.jsp" />

<!-- Toast -->
<div id="gkToast" class="hidden fixed bottom-6 right-6 z-[999] max-w-sm bg-white border border-slate-200 shadow-lg rounded-xl px-4 py-3 flex items-start gap-3 opacity-0 translate-y-3">
    <span class="material-symbols-outlined text-emerald-600 text-[20px] mt-0.5">check_circle</span>
    <div>
        <p id="gkToastTitle" class="text-sm font-bold text-slate-900">Thành công</p>
        <p id="gkToastMessage" class="text-xs text-slate-500 mt-0.5"></p>
    </div>
</div>

<script>
    var initialTab = '${initialTab}';
    var validTabs = ['dang-mo', 'tao-keo', 'tim-doi-thu', 'cua-toi'];
    if (validTabs.indexOf(initialTab) === -1) initialTab = 'dang-mo';

    function activateTab(tab) {
        document.querySelectorAll('.gk-tab').forEach(function (btn) {
            btn.classList.toggle('active', btn.getAttribute('data-tab') === tab);
        });
        document.querySelectorAll('.gk-panel').forEach(function (panel) {
            panel.classList.toggle('active', panel.id === 'panel-' + tab);
        });
        if (history.replaceState) {
            var url = new URL(window.location.href);
            url.searchParams.set('tab', tab);
            history.replaceState(null, '', url.toString());
        }
    }

    document.querySelectorAll('.gk-tab').forEach(function (btn) {
        btn.addEventListener('click', function () { activateTab(btn.getAttribute('data-tab')); });
    });
    document.querySelectorAll('.gk-tab-link').forEach(function (btn) {
        btn.addEventListener('click', function () { activateTab(btn.getAttribute('data-goto-tab')); });
    });

    activateTab(initialTab);

    function showToast(title, message) {
        var toast = document.getElementById('gkToast');
        document.getElementById('gkToastTitle').textContent = title;
        document.getElementById('gkToastMessage').textContent = message || '';
        toast.classList.remove('hidden');
        requestAnimationFrame(function () { toast.classList.remove('opacity-0', 'translate-y-3'); });
        clearTimeout(window.__gkToastTimer);
        window.__gkToastTimer = setTimeout(function () {
            toast.classList.add('opacity-0', 'translate-y-3');
            setTimeout(function () { toast.classList.add('hidden'); }, 250);
        }, 4500);
    }

    function submitGhepKeoDemo(evt, title, message) {
        evt.preventDefault();
        showToast(title, message);
        return false;
    }

    function useCurrentLocationDemo() {
        showToast('Đã dùng vị trí hiện tại', 'Chức năng định vị và gợi ý đối thủ theo khoảng cách đang được phát triển.');
    }
</script>
<jsp:include page="/customer/common/bottom-nav.jsp" />
</body>
</html>
