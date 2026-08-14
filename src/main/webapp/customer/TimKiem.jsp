<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ page import="org.example.model.CoSo" %>
<%@ page import="org.example.model.MonTheThao" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="org.example.controller.manager.CoSoGalleryServlet" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<%--
    "Có khuyến mãi" là view-only filter: TimKiemServlet chưa có tham số này, nên nó được
    tính và áp dụng hoàn toàn ở JSP dựa trên "facilityPromotions" (đã có sẵn từ servlet)
    thay vì sửa Servlet/DAO. Chỉ ẩn khỏi kết quả render, không đổi truy vấn DB.
--%>
<c:set var="hasPromotion" value="${param.hasPromotion == 'true' || param.hasPromotion == '1'}" scope="page" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <jsp:include page="/common/xtra-head.jsp" />
    <title>Tìm kiếm sân - V-SPORT</title>
    <style>
        body { background-color: var(--background); }
        
        .main-content {
            padding: 32px 0 48px;
            flex: 1 0 auto;
        }

        /* ===== Line & Scoreboard restyle — scoped to this page's search/card UI only,
           does NOT touch global --primary/--navy tokens (those are shared by ~17 pages).
           See docs/design/stitch-customer-redesign-prompt.md ===== */
        .tk-searchbar {
            display: flex; align-items: center; gap: 10px;
            background: #fff; border: 1px solid #E2E5E0; border-radius: 10px;
            padding: 12px 16px; margin-bottom: 20px; max-width: 420px;
        }
        .tk-searchbar i { color: #6e7978; flex-shrink: 0; }
        .tk-searchbar input {
            border: none; outline: none; flex: 1; min-width: 0;
            font-family: 'Outfit', sans-serif; font-size: 15px; color: #12201B;
            background: transparent;
        }
        .tk-searchbar:focus-within { border-color: #0E6E6A; box-shadow: 0 0 0 3px rgba(14,110,106,.12); }
        .tk-toolbar { display: flex; flex-wrap: wrap; gap: 14px; align-items: center; margin-bottom: 8px; }
        .tk-toolbar .filter-chips { flex: 1; margin-bottom: 0; padding-bottom: 4px; }
        .tk-advfilter-btn {
            display: inline-flex; align-items: center; gap: 8px;
            padding: 10px 18px; border-radius: 10px;
            background: #fff; border: 2px solid #0E6E6A; color: #0E6E6A;
            font-family: 'Outfit', sans-serif; font-weight: 700; font-size: 14px;
            cursor: pointer; white-space: nowrap; transition: background .16s ease, color .16s ease;
        }
        .tk-advfilter-btn:hover { background: #0E6E6A; color: #fff; }

        /* Chips */
        .filter-chips {
            display: flex;
            gap: 10px;
            overflow-x: auto;
            padding-bottom: 20px;
            margin-bottom: 20px;
        }
        .filter-chips::-webkit-scrollbar { display: none; }
        .chip {
            padding: 10px 20px;
            border-radius: 10px;
            border: 1px solid #E2E5E0;
            background-color: #fff;
            color: #12201B;
            font-family: 'Outfit', sans-serif;
            font-weight: 600;
            cursor: pointer;
            transition: var(--transition);
            white-space: nowrap;
        }
        .chip:hover {
            border-color: #0E6E6A;
            color: #0E6E6A;
        }
        .chip.active {
            background-color: #0E6E6A;
            border-color: #0E6E6A;
            color: #fff;
        }

        .tk-results-head {
            border-bottom: 2px dashed rgba(92,107,100,.3);
            padding-bottom: 16px; margin-bottom: 28px;
        }
        .tk-results-head h1 {
            font-family: 'Be Vietnam Pro', 'Outfit', sans-serif;
            font-size: clamp(24px, 3vw, 36px); font-weight: 900;
            color: #0E6E6A; letter-spacing: -.01em; margin: 0;
        }

        .active-filters {
            display: flex;
            gap: 10px;
            align-items: center;
            margin-bottom: 30px;
            flex-wrap: wrap;
        }
        .active-filters__label { font-size: 14px; color: #5C6B64; margin-right: 2px; }
        .active-chip {
            background-color: #DCEEEC;
            color: #0A5652;
            padding: 6px 14px;
            border-radius: 999px;
            font-size: 13px;
            font-weight: 700;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .active-chip a { color: #0A5652; }
        .active-chip a:hover { opacity: 0.7; }
        .clear-filters {
            font-size: 14px;
            color: #5C6B64;
            text-decoration: underline;
        }
        .clear-filters:hover { color: var(--danger); }

        /* Facility Card */
        .facility-card {
            background-color: #fff;
            border: 1px solid #E2E5E0;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 4px 12px rgba(18,32,27,.05);
            transition: var(--transition), border-color .18s ease;
            display: flex;
            flex-direction: column;
            height: 100%;
            cursor: pointer;
            position: relative;
        }
        .facility-card:hover {
            transform: translateY(-5px);
            border-color: #0E6E6A;
            box-shadow: var(--shadow-large);
        }
        .facility-card:focus-visible {
            outline: 3px solid #0E6E6A;
            outline-offset: 2px;
        }
        /* Line-marking corner brackets — alternate cards, matches the design system's
           "reserve the signature for emphasis, not every row" rule */
        .product-grid .facility-card:nth-child(4n+1)::before,
        .product-grid .facility-card:nth-child(4n+1)::after {
            content: ''; position: absolute; width: 16px; height: 16px; z-index: 5;
        }
        .product-grid .facility-card:nth-child(4n+1)::before { top: -1px; right: -1px; border-top: 3px solid #0E6E6A; border-right: 3px solid #0E6E6A; }
        .product-grid .facility-card:nth-child(4n+1)::after { bottom: -1px; left: -1px; border-bottom: 3px solid #0E6E6A; border-left: 3px solid #0E6E6A; }
        .product-grid .facility-card:nth-child(4n+3)::before,
        .product-grid .facility-card:nth-child(4n+3)::after {
            content: ''; position: absolute; width: 16px; height: 16px; z-index: 5;
        }
        .product-grid .facility-card:nth-child(4n+3)::before { top: -1px; left: -1px; border-top: 3px solid #0E6E6A; border-left: 3px solid #0E6E6A; }
        .product-grid .facility-card:nth-child(4n+3)::after { bottom: -1px; right: -1px; border-bottom: 3px solid #0E6E6A; border-right: 3px solid #0E6E6A; }
        .fc-image {
            position: relative;
            height: 200px;
            overflow: hidden;
        }
        .fc-image img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform 0.5s ease;
        }
        .facility-card:hover .fc-image img {
            transform: scale(1.05);
        }
        .fc-badge {
            position: absolute;
            top: 15px;
            left: 15px;
            background-color: rgba(14,110,106,.14);
            color: #0A5652;
            font-size: 12px;
            font-weight: 700;
            padding: 4px 12px;
            border-radius: 20px;
            box-shadow: var(--shadow-small);
            backdrop-filter: blur(4px);
        }

        /* Promotion badge: sits top-right so it never collides with the sport badge (top-left) */
        .fc-promo-badge {
            position: absolute;
            top: 15px;
            right: 15px;
            display: inline-flex;
            align-items: center;
            gap: 5px;
            background-color: #fff7d6;
            color: #7a5b00;
            font-size: 11.5px;
            font-weight: 800;
            padding: 5px 11px 5px 9px;
            border-radius: 20px;
            box-shadow: var(--shadow-small);
            max-width: calc(100% - 100px);
        }
        .fc-promo-badge i {
            font-size: 12px;
            flex-shrink: 0;
        }
        .fc-promo-badge span {
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }
        @media (prefers-reduced-motion: no-preference) {
            .fc-promo-badge i { animation: fcPromoBounce 2.6s ease-in-out .4s 1; }
            .facility-card:hover .fc-promo-badge i { animation: fcPromoSpin 0.5s ease; }
        }
        @keyframes fcPromoBounce {
            0%, 100% { transform: scale(1); }
            10% { transform: scale(1.28); }
            22% { transform: scale(0.94); }
            34% { transform: scale(1.1); }
            46% { transform: scale(1); }
        }
        @keyframes fcPromoSpin {
            from { transform: rotate(0deg); }
            to { transform: rotate(14deg); }
        }

        .fc-promo-line {
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 12.5px;
            font-weight: 700;
            color: #8a6d00;
            background: #fffbea;
            border: 1px solid #ffedb3;
            border-radius: 8px;
            padding: 5px 9px;
            margin-bottom: 12px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }
        .fc-promo-line i { flex-shrink: 0; color: #c9960a; }
        .fc-content {
            padding: 20px;
            flex: 1;
            display: flex;
            flex-direction: column;
        }
        .fc-title {
            font-family: 'Be Vietnam Pro', 'Outfit', sans-serif;
            font-size: 18px;
            font-weight: 800;
            margin-bottom: 10px;
            color: #12201B;
            line-height: 1.4;
        }
        .fc-address {
            font-size: 14px;
            color: #5C6B64;
            margin-bottom: 15px;
            display: flex;
            align-items: flex-start;
            gap: 8px;
        }
        .fc-address i { margin-top: 3px; color: #0E6E6A; }
        .fc-footer {
            margin-top: auto;
            padding-top: 15px;
            border-top: 1px dashed #E2E5E0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .fc-time {
            font-family: var(--vs-scoreboard-font, 'Space Mono', monospace);
            font-size: 12.5px;
            font-weight: 700;
            letter-spacing: .02em;
            color: #0A5652;
            background: rgba(14,110,106,.08);
            padding: 4px 8px;
            border-radius: 5px;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .fc-time i { color: #0E6E6A; font-family: 'Font Awesome 6 Free'; }
        .facility-card .fc-footer .btn.btn-primary {
            background: #0E6E6A; border-color: #0E6E6A;
        }
        .facility-card .fc-footer .btn.btn-primary:hover { background: #0A5652; border-color: #0A5652; }
        
        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 80px 20px;
            background: var(--surface);
            border-radius: var(--radius-large);
            margin-bottom: 60px;
        }
        .empty-state i {
            font-size: 64px;
            color: var(--border);
            margin-bottom: 20px;
        }
        .empty-state h3 {
            font-size: 24px;
            color: var(--navy);
            margin-bottom: 10px;
        }
        .empty-state p {
            color: var(--muted-text);
            margin-bottom: 20px;
        }

        /* Modal */
        .modal-overlay {
            position: fixed; inset: 0; background: rgba(18, 45, 64, 0.8);
            backdrop-filter: blur(4px); z-index: 1000;
            display: flex; align-items: center; justify-content: center;
            opacity: 0; visibility: hidden; transition: var(--transition);
        }
        .modal-overlay.is-open { opacity: 1; visibility: visible; }
        .modal-panel {
            background: var(--surface); width: 100%; max-width: 450px;
            border-radius: var(--radius-large); padding: 30px;
            transform: translateY(20px); transition: var(--transition);
        }
        .modal-overlay.is-open .modal-panel { transform: translateY(0); }
        .modal-close {
            position: absolute; top: 20px; right: 20px;
            background: none; border: none; font-size: 20px;
            color: var(--muted-text); cursor: pointer;
        }
        .modal-close:hover { color: var(--danger); }
        
        .modal-title { font-size: 24px; color: var(--navy); margin-bottom: 25px; }
        .form-group { margin-bottom: 20px; }
        .form-label { display: block; font-size: 14px; font-weight: 700; color: var(--navy); margin-bottom: 15px; }
        
        .radio-list { display: flex; flex-direction: column; gap: 10px; }
        .radio-label {
            display: flex; align-items: center; gap: 10px; padding: 12px 16px;
            border: 1px solid var(--border); border-radius: var(--radius-medium);
            cursor: pointer; font-size: 15px; font-weight: 500; transition: var(--transition);
        }
        .radio-label:hover { border-color: var(--primary); }
        .radio-label:has(input:checked) { border-color: var(--primary); background-color: rgba(1,226,129,0.05); }
        
        .switch-wrapper { display: flex; justify-content: space-between; align-items: center; padding-top: 15px; border-top: 1px solid var(--border); }
        .modal-actions { display: flex; gap: 15px; margin-top: 30px; }

        /* Đặt lịch button: đảm bảo vùng chạm tối thiểu ~44px trên mọi kích thước */
        .fc-footer .btn {
            min-height: 44px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
        }

        @media (max-width: 768px) {
            .main-content { padding: 24px 0 60px; }
            .product-grid { gap: 16px; }
            .fc-image { height: 170px; }
            .fc-content { padding: 16px; }
            .modal-panel {
                max-width: 100%;
                width: min(100% - 24px, 100%);
                padding: 24px 18px;
                max-height: calc(100dvh - 32px);
                overflow-y: auto;
            }
        }

        @media (max-width: 430px) {
            .filter-chips { gap: 8px; }
            .chip { padding: 9px 18px; font-size: 13px; }
            .fc-footer { flex-wrap: wrap; gap: 10px; }
            .fc-footer .btn { width: 100%; }
            .fc-time { width: 100%; }
            .modal-panel {
                width: min(100% - 20px, 100%);
                padding: 20px 14px;
                border-radius: var(--radius-medium);
            }
            .modal-actions { flex-direction: column; gap: 10px; }
        }

    </style>
</head>
<body>
    <jsp:include page="/common/header-xtra.jsp" />

    <main class="main-content container">

        <form id="tkSearchForm" action="${ctx}/customer/tim-kiem" method="GET">
            <div class="tk-searchbar">
                <i class="fa-solid fa-magnifying-glass"></i>
                <input type="text" name="q" placeholder="Tìm kiếm sân, địa điểm..." value="<c:out value='${query}'/>" autocomplete="off">
            </div>

            <div class="tk-toolbar">
                <div class="filter-chips">
                    <button type="button" class="chip <c:if test='${empty sportId}'>active</c:if>" onclick="selectSport('')">
                        Tất cả
                    </button>
                    <c:forEach var="m" items="${dsMon}">
                        <button type="button" class="chip <c:if test='${sportId == m.monTheThaoID}'>active</c:if>" onclick="selectSport('${m.monTheThaoID}')">
                            <c:out value="${m.tenMon}"/>
                        </button>
                    </c:forEach>
                    <button type="button" class="chip chip-promo <c:if test='${hasPromotion}'>active</c:if>" onclick="toggleHasPromotion()">
                        <i class="fa-solid fa-tag" style="margin-right:6px;"></i>Có khuyến mãi
                    </button>
                </div>
                <button type="button" class="tk-advfilter-btn" onclick="openFilterModal()">
                    <i class="fa-solid fa-sliders"></i>
                    <span>Bộ lọc nâng cao</span>
                </button>
            </div>

            <c:if test="${not empty sportId or openNow or hasPromotion}">
                <div class="active-filters">
                    <span class="active-filters__label">Đang lọc theo:</span>
                    <c:if test="${not empty sportId}">
                        <c:forEach var="m" items="${dsMon}">
                            <c:if test="${m.monTheThaoID == sportId}">
                                <div class="active-chip">
                                    Môn: <c:out value="${m.tenMon}"/>
                                    <a href="javascript:void(0)" onclick="removeSportFilter()"><i class="fa-solid fa-xmark"></i></a>
                                </div>
                            </c:if>
                        </c:forEach>
                    </c:if>
                    <c:if test="${openNow}">
                        <div class="active-chip">
                            Đang mở cửa
                            <a href="javascript:void(0)" onclick="removeOpenNowFilter()"><i class="fa-solid fa-xmark"></i></a>
                        </div>
                    </c:if>
                    <c:if test="${hasPromotion}">
                        <div class="active-chip">
                            Có khuyến mãi
                            <a href="javascript:void(0)" onclick="removeHasPromotionFilter()"><i class="fa-solid fa-xmark"></i></a>
                        </div>
                    </c:if>
                    <a href="javascript:void(0)" class="clear-filters" onclick="clearAllFilters()">Xóa bộ lọc</a>
                </div>
            </c:if>

            <input type="hidden" name="sportId" id="tkSportIdInput" value="<c:out value='${sportId}'/>"/>
            <input type="hidden" name="openNow" id="tkOpenNowInput" value="<c:if test='${openNow}'>true</c:if>"/>
            <input type="hidden" name="hasPromotion" id="tkHasPromotionInput" value="<c:if test='${hasPromotion}'>true</c:if>"/>
        </form>

        <%
            // "Có khuyến mãi" view-only filter (xem ghi chú ở đầu file): áp dụng trước
            // c:choose để cả empty-state lẫn vòng lặp render đều dùng đúng danh sách đã lọc.
            @SuppressWarnings("unchecked")
            List<CoSo> tkAllResults = (List<CoSo>) request.getAttribute("results");
            @SuppressWarnings("unchecked")
            Map<Integer, Map<String, Object>> facilityPromotionsPre =
                    (Map<Integer, Map<String, Object>>) request.getAttribute("facilityPromotions");
            boolean hasPromotionFilterPre = "true".equals(request.getParameter("hasPromotion"))
                    || "1".equals(request.getParameter("hasPromotion"));
            List<CoSo> tkVisibleResults = tkAllResults;
            if (hasPromotionFilterPre && tkAllResults != null) {
                tkVisibleResults = new java.util.ArrayList<CoSo>();
                for (CoSo c : tkAllResults) {
                    if (facilityPromotionsPre != null && facilityPromotionsPre.containsKey(c.getCoSoID())) {
                        tkVisibleResults.add(c);
                    }
                }
            }
            request.setAttribute("tkVisibleResults", tkVisibleResults);
        %>
        <c:choose>
            <c:when test="${searchError}">
                <div class="empty-state">
                    <i class="fa-solid fa-triangle-exclamation" style="color: var(--danger);"></i>
                    <h3>Đã có lỗi xảy ra</h3>
                    <p>Không thể tải dữ liệu tìm kiếm. Vui lòng thử lại sau.</p>
                    <a href="${ctx}/customer/tim-kiem" class="btn btn-primary">Tải lại trang</a>
                </div>
            </c:when>
            <c:when test="${empty tkVisibleResults}">
                <div class="empty-state">
                    <i class="fa-solid fa-magnifying-glass-minus"></i>
                    <h3>Không tìm thấy kết quả</h3>
                    <p>
                        <c:choose>
                            <c:when test="${hasPromotion}">Chưa có cơ sở nào đang có khuyến mãi phù hợp với bộ lọc hiện tại.</c:when>
                            <c:otherwise>Thử điều chỉnh bộ lọc hoặc từ khóa tìm kiếm của bạn.</c:otherwise>
                        </c:choose>
                    </p>
                    <a href="${ctx}/customer/tim-kiem" class="btn btn-primary">Xóa bộ lọc</a>
                </div>
            </c:when>
            <c:otherwise>
                <div class="tk-results-head">
                    <h1>Tìm thấy <c:out value="${fn:length(tkVisibleResults)}"/> sân phù hợp</h1>
                </div>
                <div class="product-grid" id="facilityGrid">
                    <%
                        List<CoSo> tkResults = tkVisibleResults;
                        @SuppressWarnings("unchecked")
                        Map<Integer, String> facilityFirstSport = (Map<Integer, String>) request.getAttribute("facilityFirstSport");
                        Map<Integer, Map<String, Object>> facilityPromotions = facilityPromotionsPre;
                        String ctx2 = request.getContextPath();
                        // Resolve active sport name from dsMon (source of truth: San→LoaiSan→MonTheThao).
                        Integer activeSportId = (Integer) request.getAttribute("sportId");
                        String activeSportName = "";
                        if (activeSportId != null) {
                            @SuppressWarnings("unchecked")
                            List<MonTheThao> monList = (List<MonTheThao>) request.getAttribute("dsMon");
                            if (monList != null) {
                                for (MonTheThao m : monList) {
                                    if (m.getMonTheThaoID() == activeSportId) {
                                        activeSportName = m.getTenMon() != null ? m.getTenMon() : "";
                                        break;
                                    }
                                }
                            }
                        }
                        if (tkResults != null) {
                            for (CoSo cs : tkResults) {
                                Map<String, Object> promo = facilityPromotions != null ? facilityPromotions.get(cs.getCoSoID()) : null;

                                String csImg = cs.getHinhAnh() != null ? cs.getHinhAnh().trim() : "";
                                String csOpen = cs.getGioMoCua() != null ? cs.getGioMoCua().toString().substring(0,5) : "06:00";
                                String csClose = cs.getGioDongCua() != null ? cs.getGioDongCua().toString().substring(0,5) : "23:00";
                                String csName = cs.getTenCoSo() != null ? cs.getTenCoSo() : "";
                                String csNameSafe = csName.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
                                String csAddr = cs.getDiaChi() != null ? cs.getDiaChi() : "Chưa cập nhật địa chỉ";
                                String csAddrSafe = csAddr.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");

                                String fbImgUrl = ctx2 + "/assets/images/home/hero-sports-facility.webp";
                                String cardImgUrl = fbImgUrl;
                                if (!csImg.isEmpty()) {
                                    List<String> csImgs = CoSoGalleryServlet.parseJson(csImg);
                                    if (!csImgs.isEmpty()) {
                                        String first = csImgs.get(0);
                                        if (first.startsWith("http")) {
                                            cardImgUrl = first;
                                        } else {
                                            cardImgUrl = ctx2 + (first.startsWith("/") ? first : "/" + first);
                                        }
                                    }
                                }

                                // Badge: source of truth is actual courts (San→LoaiSan→MonTheThao).
                                // When filtering by sport, activeSportName is already resolved above.
                                // Otherwise, use the batch-queried first sport from courts (never LoaiHinhKinhDoanh).
                                String badgeSport;
                                if (activeSportId != null && !activeSportName.isEmpty()) {
                                    badgeSport = activeSportName;
                                } else {
                                    String fromCourts = facilityFirstSport != null ? facilityFirstSport.get(cs.getCoSoID()) : null;
                                    badgeSport = fromCourts != null ? fromCourts : "";
                                }
                                String firstSportSafe = badgeSport.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");

                                String promoCodeSafe = null;
                                String promoLabelSafe = null;
                                if (promo != null) {
                                    Object codeObj = promo.get("maCode");
                                    Object moTaObj = promo.get("moTa");
                                    if (codeObj != null) {
                                        promoCodeSafe = codeObj.toString().replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
                                    }
                                    if (moTaObj != null && !moTaObj.toString().trim().isEmpty()) {
                                        promoLabelSafe = moTaObj.toString().replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
                                    }
                                }
                    %>
                    <div class="facility-card" tabindex="0" role="button"
                         aria-label="Xem chi tiết <%= csNameSafe %><%= promo != null ? " (đang có khuyến mãi)" : "" %>"
                         data-coso-id="<%= cs.getCoSoID() %>"
                         data-facility-name="<%= csNameSafe %>"
                         data-card-image="<%= cardImgUrl %>"
                         data-sport-id="<%= activeSportId != null ? activeSportId : "" %>">
                        <div class="fc-image">
                            <img src="<%= cardImgUrl %>" onerror="this.onerror=null;this.src='<%= fbImgUrl %>';" alt="<%= csNameSafe %>">
                            <% if (!badgeSport.isEmpty()) { %>
                                <div class="fc-badge"><i class="fa-solid fa-medal"></i> <%= firstSportSafe %></div>
                            <% } %>
                            <% if (promo != null) { %>
                                <div class="fc-promo-badge" title="<%= promoCodeSafe != null ? promoCodeSafe : "Có ưu đãi" %>">
                                    <i class="fa-solid fa-tag"></i>
                                    <span><%= promoCodeSafe != null ? promoCodeSafe : "Có ưu đãi" %></span>
                                </div>
                            <% } %>
                        </div>
                        <div class="fc-content">
                            <h3 class="fc-title"><%= csNameSafe %></h3>
                            <p class="fc-address"><i class="fa-solid fa-location-dot"></i> <span><%= csAddrSafe %></span></p>
                            <% if (promo != null && promoLabelSafe != null) { %>
                                <div class="fc-promo-line"><i class="fa-solid fa-gift"></i><span><%= promoLabelSafe %></span></div>
                            <% } %>

                            <div class="fc-footer">
                                <div class="fc-time"><i class="fa-solid fa-clock"></i> <%= csOpen %> - <%= csClose %></div>
                                <button type="button" class="btn btn-primary" style="padding: 8px 16px; font-size: 13px;"
                                        data-book-trigger
                                        data-coso-id="<%= cs.getCoSoID() %>"
                                        data-facility-name="<%= csNameSafe %>"
                                        data-sport-id="<%= activeSportId != null ? activeSportId : "" %>">Đặt lịch</button>
                            </div>
                        </div>
                    </div>
                    <% } } %>
                </div>
            </c:otherwise>
        </c:choose>
    </main>

    <!-- Footer -->
    <jsp:include page="/common/footer.jsp" />

    <!-- Modal -->
    <div class="modal-overlay" id="filterModal">
        <div class="modal-panel">
            <button class="modal-close" onclick="closeFilterModal()"><i class="fa-solid fa-xmark"></i></button>
            <h2 class="modal-title">Bộ lọc chuyên sâu</h2>
            
            <div class="form-group">
                <label class="form-label">Môn thể thao</label>
                <div class="radio-list">
                    <label class="radio-label">
                        <input type="radio" name="modalSportId" value="" <c:if test="${empty sportId}">checked</c:if>>
                        Tất cả môn
                    </label>
                    <c:forEach var="m" items="${dsMon}">
                        <label class="radio-label">
                            <input type="radio" name="modalSportId" value="<c:out value='${m.monTheThaoID}'/>" <c:if test="${sportId == m.monTheThaoID}">checked</c:if>>
                            <c:out value="${m.tenMon}"/>
                        </label>
                    </c:forEach>
                </div>
            </div>

            <div class="switch-wrapper">
                <label class="form-label" style="margin-bottom:0;">Chỉ hiển thị sân đang mở cửa</label>
                <input type="checkbox" id="modalOpenNow" style="width: 20px; height: 20px; accent-color: var(--primary);" <c:if test="${openNow}">checked</c:if>>
            </div>

            <div class="modal-actions">
                <button type="button" class="btn btn-outline" style="border-color: var(--border); color: var(--navy); width: 100%;" onclick="resetFilterModal()">Thiết lập lại</button>
                <button type="button" class="btn btn-primary" style="width: 100%;" onclick="applyFilterModal()">Áp dụng</button>
            </div>
        </div>
    </div>

    <script>
        const searchForm = document.getElementById('tkSearchForm');
        const sportIdInput = document.getElementById('tkSportIdInput');
        const openNowInput = document.getElementById('tkOpenNowInput');
        const hasPromotionInput = document.getElementById('tkHasPromotionInput');
        const filterModal = document.getElementById('filterModal');

        function selectSport(id) {
            sportIdInput.value = id;
            searchForm.submit();
        }
        function removeSportFilter() { sportIdInput.value = ''; searchForm.submit(); }
        function removeOpenNowFilter() { openNowInput.value = ''; searchForm.submit(); }
        function removeHasPromotionFilter() { hasPromotionInput.value = ''; searchForm.submit(); }
        function toggleHasPromotion() {
            hasPromotionInput.value = hasPromotionInput.value === 'true' ? '' : 'true';
            searchForm.submit();
        }
        function clearAllFilters() {
            sportIdInput.value = '';
            openNowInput.value = '';
            hasPromotionInput.value = '';
            searchForm.submit();
        }

        function openFilterModal() { filterModal.classList.add('is-open'); document.body.style.overflow = 'hidden'; }
        function closeFilterModal() { filterModal.classList.remove('is-open'); document.body.style.overflow = ''; }
        filterModal.addEventListener('click', (e) => { if (e.target === filterModal) closeFilterModal(); });

        function resetFilterModal() {
            document.querySelector('input[name="modalSportId"][value=""]').checked = true;
            document.getElementById('modalOpenNow').checked = false;
        }

        function applyFilterModal() {
            const selectedSport = document.querySelector('input[name="modalSportId"]:checked');
            sportIdInput.value = selectedSport ? selectedSport.value : '';
            openNowInput.value = document.getElementById('modalOpenNow').checked ? 'true' : '';
            searchForm.submit();
        }
    </script>

    <jsp:include page="/customer/common/facility-interactions.jsp" />

    <script>
        // Deep link: /customer/tim-kiem?coSoId=7 reopens the facility detail sheet
        // on load, reusing the exact same open path as a card click (so history
        // push/pop stays consistent). Silently no-ops if the id isn't on this page.
        (function () {
            var coSoId = new URLSearchParams(window.location.search).get('coSoId');
            if (coSoId) {
                var grid = document.getElementById('facilityGrid');
                if (grid) {
                    var card = grid.querySelector('.facility-card[data-coso-id="' + CSS.escape(coSoId) + '"]');
                    if (card && typeof window.openFacilitySheet === 'function') {
                        window.openFacilitySheet(card);
                    }
                }
            }

            // Real-time polling to check if new courts/facilities were created
            var lastCount = -1;
            function checkRealtimeUpdates() {
                if (document.hidden) return;
                fetch('${ctx}/api/customer/facilities/map?_t=' + Date.now(), { cache: 'no-store' })
                    .then(function(r) { return r.json(); })
                    .then(function(data) {
                        if (Array.isArray(data)) {
                            if (lastCount !== -1 && data.length !== lastCount) {
                                // Facility/court count changed - submit search form to reload updated court grid
                                document.getElementById('tkSearchForm').submit();
                            } else {
                                lastCount = data.length;
                            }
                        }
                    })
                    .catch(function() {});
            }

            setInterval(checkRealtimeUpdates, 15000);
            document.addEventListener('visibilitychange', function() {
                if (!document.hidden) checkRealtimeUpdates();
            });
        })();
    </script>
</body>
</html>
