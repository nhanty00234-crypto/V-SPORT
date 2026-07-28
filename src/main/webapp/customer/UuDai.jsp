<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%--
    Trang Customer "Ưu đãi" (/customer/uu-dai). Toàn bộ dữ liệu được tải qua JS từ 2 API
    JSON đã tồn tại sẵn - không hardcode, không mock:
      - GET /api/customer/promotions?limit=N  (CustomerPromotionApiServlet) → danh sách
        khuyến mãi công khai, còn hiệu lực (đã lọc phía server, không trả promo hết hạn/
        tạm khóa).
      - GET /api/customer/facilities/map      (MapApiServlet) → tên/địa chỉ cơ sở để join
        theo coSoId, vì CustomerPromotionApiServlet chỉ trả coSoId (không kèm tên cơ sở).
    Filter môn thể thao / sắp hết hạn, sort gần nhất-giảm nhiều nhất, và phân trang đều xử
    lý ở client trên tập dữ liệu đã tải, vì 2 API trên không hỗ trợ các tham số đó.
--%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <jsp:include page="/common/xtra-head.jsp" />
    <title>Ưu đãi - V-SPORT</title>
    <style>
        body { background-color: var(--background); }

        .ud-hero {
            padding: 36px 0 8px;
        }
        .ud-hero h1 {
            font-size: 30px;
            margin-bottom: 8px;
        }
        .ud-hero p {
            color: var(--muted-text);
            font-size: 15px;
            max-width: 620px;
        }

        .ud-toolbar {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            align-items: center;
            margin: 24px 0 8px;
            background: var(--surface);
            border-radius: var(--radius-large);
            padding: 16px;
            box-shadow: var(--shadow-small);
        }
        .ud-search {
            flex: 1 1 260px;
            position: relative;
        }
        .ud-search input {
            width: 100%;
            padding: 12px 16px 12px 42px;
            border-radius: 50px;
            border: 1px solid var(--border);
            font-size: 14px;
            font-family: inherit;
            outline: none;
            transition: border-color .15s ease;
        }
        .ud-search input:focus { border-color: var(--primary); }
        .ud-search i {
            position: absolute; left: 16px; top: 50%; transform: translateY(-50%);
            color: var(--muted-text); font-size: 14px;
        }
        .ud-select {
            padding: 11px 14px;
            border-radius: 50px;
            border: 1px solid var(--border);
            font-size: 13.5px;
            font-family: 'Outfit', sans-serif;
            font-weight: 600;
            color: var(--navy);
            background: var(--surface);
            cursor: pointer;
        }
        .ud-switch-wrap {
            display: flex; align-items: center; gap: 8px;
            font-size: 13.5px; font-weight: 600; color: var(--navy);
            white-space: nowrap;
        }
        .ud-switch-wrap input { width: 18px; height: 18px; accent-color: var(--primary); cursor: pointer; }

        .ud-meta-row {
            display: flex; justify-content: space-between; align-items: center;
            margin: 18px 0 14px; flex-wrap: wrap; gap: 8px;
        }
        .ud-count { font-size: 13.5px; color: var(--muted-text); font-weight: 600; }

        .ud-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 24px;
        }
        @media (max-width: 1200px) { .ud-grid { grid-template-columns: repeat(2, 1fr); } }
        @media (max-width: 700px) { .ud-grid { grid-template-columns: 1fr; } }

        .ud-card {
            background: var(--surface);
            border-radius: var(--radius-medium);
            overflow: hidden;
            box-shadow: var(--shadow-small);
            display: flex;
            flex-direction: column;
            transition: var(--transition);
            opacity: 0; transform: translateY(20px);
            animation: udFadeUp .5s var(--ease-out-expo, ease) forwards;
        }
        .ud-card:hover { transform: translateY(-5px); box-shadow: var(--shadow-large); }
        @keyframes udFadeUp { to { opacity: 1; transform: translateY(0); } }
        @media (prefers-reduced-motion: reduce) { .ud-card { animation: none; opacity: 1; transform: none; } }

        .ud-media { position: relative; aspect-ratio: 16/9; background: #eef4f1; overflow: hidden; }
        .ud-media img { width: 100%; height: 100%; object-fit: cover; display: block; }
        .ud-media .ud-fallback {
            position: absolute; inset: 0; display: flex; align-items: center; justify-content: center;
            color: var(--muted-text); font-size: 30px;
        }
        .ud-discount-badge {
            position: absolute; top: 12px; left: 12px;
            background: var(--navy); color: #fff;
            font-size: 12.5px; font-weight: 800;
            padding: 5px 12px; border-radius: 20px;
        }
        .ud-ending-badge {
            position: absolute; top: 12px; right: 12px;
            background: #fff7d6; color: #7a5b00;
            font-size: 11px; font-weight: 800;
            padding: 4px 10px; border-radius: 20px;
        }

        .ud-body { padding: 16px 18px 18px; display: flex; flex-direction: column; gap: 8px; flex: 1; }
        .ud-title { font-size: 16.5px; font-weight: 800; color: var(--navy); line-height: 1.35; }
        .ud-code-row { display: flex; align-items: center; gap: 8px; }
        .ud-code {
            font-family: 'JetBrains Mono', 'Courier New', monospace;
            font-size: 13px; font-weight: 800; letter-spacing: .03em;
            background: rgba(1,226,129,0.08); color: var(--primary-hover);
            border: 1px dashed rgba(1,226,129,0.4); border-radius: 8px; padding: 3px 10px;
        }
        .ud-facility { font-size: 13.5px; font-weight: 700; color: var(--navy); margin-top: 2px; }
        .ud-address { font-size: 12.5px; color: var(--muted-text); display: flex; align-items: flex-start; gap: 6px; }
        .ud-address i { margin-top: 2px; color: var(--primary); flex-shrink: 0; }
        .ud-cond { font-size: 12px; color: var(--muted-text); }
        .ud-cond span + span::before { content: ' · '; }
        .ud-actions { display: flex; gap: 8px; margin-top: auto; padding-top: 10px; }
        .ud-actions .btn { flex: 1; padding: 9px 10px; font-size: 12.5px; }
        .ud-btn-view { background: transparent; border: 1.5px solid var(--navy); color: var(--navy); }
        .ud-btn-view:hover { background: var(--navy); color: #fff; }

        .ud-state { text-align: center; padding: 70px 20px; }
        .ud-state i { font-size: 56px; color: var(--border); margin-bottom: 16px; }
        .ud-state h3 { font-size: 21px; color: var(--navy); margin-bottom: 8px; }
        .ud-state p { color: var(--muted-text); }

        .ud-skel-card { border-radius: var(--radius-medium); overflow: hidden; background: var(--surface); box-shadow: var(--shadow-small); }
        .ud-skel-media { aspect-ratio: 16/9; background: linear-gradient(90deg,#eef4f1 25%,#e2ece7 37%,#eef4f1 63%); background-size: 400% 100%; animation: udShimmer 1.4s ease infinite; }
        .ud-skel-line { height: 12px; margin: 14px 18px; border-radius: 6px; background: linear-gradient(90deg,#eef4f1 25%,#e2ece7 37%,#eef4f1 63%); background-size: 400% 100%; animation: udShimmer 1.4s ease infinite; }
        @keyframes udShimmer { 0% { background-position: 100% 50%; } 100% { background-position: 0 50%; } }

        .ud-pagination { display: flex; justify-content: center; align-items: center; gap: 8px; margin: 32px 0 60px; }
        .ud-page-btn {
            min-width: 38px; height: 38px; padding: 0 10px; border-radius: 10px;
            border: 1px solid var(--border); background: var(--surface); color: var(--navy);
            font-size: 13.5px; font-weight: 700; cursor: pointer; transition: var(--transition);
        }
        .ud-page-btn:hover:not(:disabled) { border-color: var(--primary); color: var(--primary-hover); }
        .ud-page-btn.is-active { background: var(--navy); color: #fff; border-color: var(--navy); }
        .ud-page-btn:disabled { opacity: .4; cursor: not-allowed; }
    </style>
</head>
<body>
    <jsp:include page="/common/header-xtra.jsp" />

    <main class="main-content container">
        <div class="ud-hero">
            <h2 class="section-title" style="text-align:left; margin-bottom:0;">Ưu đãi đang diễn ra</h2>
            <p>Khám phá chương trình giảm giá tại các cơ sở thể thao gần bạn.</p>
        </div>

        <div class="ud-toolbar">
            <div class="ud-search">
                <i class="fa-solid fa-magnifying-glass"></i>
                <input type="text" id="udSearchInput" placeholder="Tìm theo mã hoặc tên chương trình...">
            </div>
            <select class="ud-select" id="udSportSelect">
                <option value="">Tất cả môn thể thao</option>
            </select>
            <select class="ud-select" id="udSortSelect">
                <option value="newest">Mới nhất</option>
                <option value="ending">Sắp hết hạn nhất</option>
                <option value="discount">Giảm nhiều nhất</option>
            </select>
            <label class="ud-switch-wrap">
                <input type="checkbox" id="udEndingSoonToggle">
                Sắp hết hạn (≤ 3 ngày)
            </label>
        </div>

        <div class="ud-meta-row">
            <span class="ud-count" id="udCountLabel"></span>
        </div>

        <div id="udSkeleton" class="ud-grid">
            <% for (int i = 0; i < 6; i++) { %>
            <div class="ud-skel-card">
                <div class="ud-skel-media"></div>
                <div class="ud-skel-line" style="width:70%;"></div>
                <div class="ud-skel-line" style="width:45%;"></div>
                <div class="ud-skel-line" style="width:55%; margin-bottom:18px;"></div>
            </div>
            <% } %>
        </div>

        <div id="udErrorState" class="ud-state" hidden>
            <i class="fa-solid fa-triangle-exclamation" style="color: var(--danger);"></i>
            <h3>Không thể tải danh sách ưu đãi</h3>
            <p>Vui lòng thử lại sau.</p>
            <button type="button" class="btn btn-primary" id="udRetryBtn">Tải lại</button>
        </div>

        <div id="udEmptyState" class="ud-state" hidden>
            <i class="fa-solid fa-ticket"></i>
            <h3>Hiện chưa có chương trình ưu đãi nào đang diễn ra.</h3>
            <p>Quay lại sau để không bỏ lỡ các ưu đãi mới nhất từ V-SPORT.</p>
        </div>

        <div id="udGrid" class="ud-grid" hidden></div>

        <div id="udPagination" class="ud-pagination" hidden></div>
    </main>

    <jsp:include page="/common/footer.jsp" />

    <script>
    (function () {
        var CTX = '${pageContext.request.contextPath}';
        var PAGE_SIZE = 9;

        var allPromotions = [];   // dữ liệu thô từ /api/customer/promotions
        var facilityById = {};    // coSoId -> {tenCoSo, diaChi, sports}
        var currentPage = 1;

        var searchInput = document.getElementById('udSearchInput');
        var sportSelect = document.getElementById('udSportSelect');
        var sortSelect = document.getElementById('udSortSelect');
        var endingSoonToggle = document.getElementById('udEndingSoonToggle');
        var skeletonEl = document.getElementById('udSkeleton');
        var errorEl = document.getElementById('udErrorState');
        var emptyEl = document.getElementById('udEmptyState');
        var gridEl = document.getElementById('udGrid');
        var countEl = document.getElementById('udCountLabel');
        var paginationEl = document.getElementById('udPagination');
        var retryBtn = document.getElementById('udRetryBtn');

        function resolveImg(v) {
            if (!v) return null;
            if (v.startsWith('http://') || v.startsWith('https://')) return v;
            return CTX + (v.startsWith('/') ? v : '/' + v);
        }

        function fmtVnd(n) {
            if (typeof n !== 'number' || !isFinite(n) || n <= 0) return null;
            return new Intl.NumberFormat('vi-VN').format(Math.round(n)) + 'đ';
        }

        function fmtDateVn(iso) {
            if (!iso) return null;
            var parts = String(iso).split('-');
            if (parts.length !== 3) return null;
            return parts[2] + '/' + parts[1] + '/' + parts[0];
        }

        function daysUntil(iso) {
            if (!iso) return null;
            return Math.ceil((new Date(iso) - new Date()) / 86400000);
        }

        function isPercentDiscount(loaiGiam) {
            if (!loaiGiam) return false;
            var v = String(loaiGiam).toUpperCase();
            return v.indexOf('PERCENT') >= 0 || v.indexOf('PHAN_TRAM') >= 0 || v.indexOf('PHANTRAM') >= 0 || v.indexOf('%') >= 0;
        }

        function discountLabel(promo) {
            var value = Number(promo.giaTriGiam);
            if (!isFinite(value) || value <= 0) return '';
            if (isPercentDiscount(promo.loaiGiam)) {
                var capped = fmtVnd(Number(promo.giamToiDa));
                return '-' + value.toLocaleString('vi-VN', { maximumFractionDigits: 1 }) + '%' + (capped ? ' · tối đa ' + capped : '');
            }
            return '-' + fmtVnd(value);
        }

        function discountSortValue(promo) {
            var value = Number(promo.giaTriGiam);
            if (!isFinite(value)) return 0;
            // Percent giảm và giảm cố định không cùng đơn vị - percent được ưu tiên hiển thị
            // "giảm nhiều nhất" theo đúng con số phần trăm, giảm cố định theo đúng số tiền.
            return value;
        }

        function el(tag, className, text) {
            var node = document.createElement(tag);
            if (className) node.className = className;
            if (text != null) node.textContent = text;
            return node;
        }

        function showState(state) {
            skeletonEl.hidden = state !== 'loading';
            errorEl.hidden = state !== 'error';
            emptyEl.hidden = state !== 'empty';
            gridEl.hidden = state !== 'content';
            paginationEl.hidden = state !== 'content';
        }

        function loadData() {
            showState('loading');
            countEl.textContent = '';

            var promoReq = fetch(CTX + '/api/customer/promotions?limit=100', { cache: 'no-store' })
                .then(function (r) { if (!r.ok) throw new Error('HTTP ' + r.status); return r.json(); });
            var mapReq = fetch(CTX + '/api/customer/facilities/map', { cache: 'no-store' })
                .then(function (r) { if (!r.ok) throw new Error('HTTP ' + r.status); return r.json(); })
                .catch(function () { return []; }); // bản đồ lỗi không nên chặn hiển thị khuyến mãi

            Promise.all([promoReq, mapReq]).then(function (results) {
                var promoData = results[0];
                var facilities = Array.isArray(results[1]) ? results[1] : [];

                facilityById = {};
                facilities.forEach(function (f) {
                    facilityById[f.coSoId] = f;
                });

                var sportSet = {};
                facilities.forEach(function (f) {
                    (Array.isArray(f.sports) ? f.sports : []).forEach(function (s) { sportSet[s] = true; });
                });
                Object.keys(sportSet).sort().forEach(function (s) {
                    var opt = document.createElement('option');
                    opt.value = s; opt.textContent = s;
                    sportSelect.appendChild(opt);
                });

                if (!promoData || !promoData.success) throw new Error('promotions API failed');
                allPromotions = Array.isArray(promoData.promotions) ? promoData.promotions : [];
                currentPage = 1;
                render();
            }).catch(function () {
                showState('error');
            });
        }

        function getFilteredSorted() {
            var keyword = (searchInput.value || '').trim().toLowerCase();
            var sportFilter = sportSelect.value;
            var endingSoonOnly = endingSoonToggle.checked;
            var sortMode = sortSelect.value;

            var list = allPromotions.filter(function (p) {
                if (keyword) {
                    var haystack = ((p.maCode || '') + ' ' + (p.moTa || '')).toLowerCase();
                    if (haystack.indexOf(keyword) === -1) return false;
                }
                if (sportFilter) {
                    var fac = facilityById[p.coSoId];
                    var sports = fac && Array.isArray(fac.sports) ? fac.sports : [];
                    if (sports.indexOf(sportFilter) === -1) return false;
                }
                if (endingSoonOnly) {
                    var d = daysUntil(p.ngayKetThuc);
                    if (d == null || d < 0 || d > 3) return false;
                }
                return true;
            });

            list.sort(function (a, b) {
                if (sortMode === 'ending') {
                    var da = daysUntil(a.ngayKetThuc), db = daysUntil(b.ngayKetThuc);
                    if (da == null) return 1;
                    if (db == null) return -1;
                    return da - db;
                }
                if (sortMode === 'discount') {
                    return discountSortValue(b) - discountSortValue(a);
                }
                // newest: dùng khuyenMaiId giảm dần khi không có trường thời gian tạo riêng.
                return (b.khuyenMaiId || 0) - (a.khuyenMaiId || 0);
            });

            return list;
        }

        function buildCard(promo) {
            var fac = facilityById[promo.coSoId] || {};
            var card = el('div', 'ud-card');

            var media = el('div', 'ud-media');
            var imgSrc = resolveImg(promo.coverImageUrl);
            if (imgSrc) {
                var img = document.createElement('img');
                img.loading = 'lazy';
                img.alt = promo.moTa || 'Ảnh khuyến mãi';
                img.onerror = function () {
                    this.remove();
                    var fb = el('div', 'ud-fallback');
                    fb.innerHTML = '<i class="fa-solid fa-image-slash"></i>';
                    media.appendChild(fb);
                };
                img.src = imgSrc;
                media.appendChild(img);
            } else {
                var fb2 = el('div', 'ud-fallback');
                fb2.innerHTML = '<i class="fa-solid fa-ticket"></i>';
                media.appendChild(fb2);
            }
            var discount = discountLabel(promo);
            if (discount) media.appendChild(el('span', 'ud-discount-badge', discount));
            var days = daysUntil(promo.ngayKetThuc);
            if (days != null && days >= 0 && days <= 3) {
                media.appendChild(el('span', 'ud-ending-badge', days === 0 ? 'Hết hạn hôm nay' : 'Còn ' + days + ' ngày'));
            }
            card.appendChild(media);

            var body = el('div', 'ud-body');
            body.appendChild(el('div', 'ud-title', promo.moTa || 'Chương trình ưu đãi'));

            if (promo.maCode) {
                var codeRow = el('div', 'ud-code-row');
                codeRow.appendChild(el('span', 'ud-code', promo.maCode));
                body.appendChild(codeRow);
            }

            if (fac.tenCoSo) body.appendChild(el('div', 'ud-facility', fac.tenCoSo));
            if (fac.diaChi || fac.address) {
                var addrRow = el('div', 'ud-address');
                addrRow.innerHTML = '<i class="fa-solid fa-location-dot"></i>';
                addrRow.appendChild(el('span', null, fac.diaChi || fac.address));
                body.appendChild(addrRow);
            }

            var condParts = [];
            var minOrder = fmtVnd(Number(promo.giaTriToiThieu));
            if (minOrder) condParts.push('Đơn tối thiểu ' + minOrder);
            var endDate = fmtDateVn(promo.ngayKetThuc);
            if (endDate) condParts.push('Hết hạn ' + endDate);
            if (condParts.length) {
                var condEl = el('div', 'ud-cond');
                condParts.forEach(function (c) { condEl.appendChild(el('span', null, c)); });
                body.appendChild(condEl);
            }

            var actions = el('div', 'ud-actions');
            var viewLink = document.createElement('a');
            viewLink.className = 'btn ud-btn-view';
            viewLink.textContent = 'Xem cơ sở';
            viewLink.href = CTX + '/customer/tim-kiem?coSoId=' + encodeURIComponent(promo.coSoId || '');
            actions.appendChild(viewLink);

            var bookLink = document.createElement('a');
            bookLink.className = 'btn btn-primary';
            bookLink.textContent = 'Đặt sân';
            bookLink.href = CTX + '/customer/dat-lich-truc-quan?coSoId=' + encodeURIComponent(promo.coSoId || '');
            bookLink.addEventListener('click', function () {
                try {
                    sessionStorage.setItem('vsPendingPromoCode', promo.maCode || '');
                    sessionStorage.setItem('vsPendingPromoCoSoId', String(promo.coSoId || ''));
                } catch (e) { /* sessionStorage không khả dụng - bỏ qua */ }
            });
            actions.appendChild(bookLink);

            body.appendChild(actions);
            card.appendChild(body);
            return card;
        }

        function render() {
            var filtered = getFilteredSorted();
            var total = filtered.length;

            if (!allPromotions.length) { showState('empty'); return; }
            if (!total) {
                emptyEl.querySelector('h3').textContent = 'Không tìm thấy ưu đãi phù hợp.';
                emptyEl.querySelector('p').textContent = 'Thử điều chỉnh bộ lọc hoặc từ khóa tìm kiếm.';
                showState('empty');
                return;
            }

            var totalPages = Math.max(1, Math.ceil(total / PAGE_SIZE));
            if (currentPage > totalPages) currentPage = totalPages;
            var start = (currentPage - 1) * PAGE_SIZE;
            var pageItems = filtered.slice(start, start + PAGE_SIZE);

            gridEl.textContent = '';
            pageItems.forEach(function (p, idx) {
                var card = buildCard(p);
                card.style.animationDelay = (idx * 40) + 'ms';
                gridEl.appendChild(card);
            });

            countEl.textContent = total + ' ưu đãi đang diễn ra';
            renderPagination(totalPages);
            showState('content');
        }

        function renderPagination(totalPages) {
            paginationEl.textContent = '';
            if (totalPages <= 1) return;

            function pageBtn(label, page, disabled, active) {
                var btn = document.createElement('button');
                btn.type = 'button';
                btn.className = 'ud-page-btn' + (active ? ' is-active' : '');
                btn.textContent = label;
                btn.disabled = !!disabled;
                btn.addEventListener('click', function () {
                    currentPage = page;
                    render();
                    window.scrollTo({ top: gridEl.offsetTop - 100, behavior: 'smooth' });
                });
                return btn;
            }

            paginationEl.appendChild(pageBtn('‹', currentPage - 1, currentPage === 1, false));
            for (var i = 1; i <= totalPages; i++) {
                paginationEl.appendChild(pageBtn(String(i), i, false, i === currentPage));
            }
            paginationEl.appendChild(pageBtn('›', currentPage + 1, currentPage === totalPages, false));
        }

        [searchInput, sportSelect, sortSelect, endingSoonToggle].forEach(function (elm) {
            var evt = elm.tagName === 'SELECT' || elm.type === 'checkbox' ? 'change' : 'input';
            elm.addEventListener(evt, function () { currentPage = 1; render(); });
        });
        retryBtn.addEventListener('click', loadData);

        loadData();
    })();
    </script>
</body>
</html>
