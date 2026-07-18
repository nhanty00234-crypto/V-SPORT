<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ page import="org.example.model.CoSo" %>
<%@ page import="org.example.model.MonTheThao" %>
<%@ page import="java.util.List" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html class="light" lang="vi">
<head>
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>Tìm kiếm sân - V-SPORT</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@400;500;600;700;800&amp;display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&amp;display=swap" rel="stylesheet"/>

    <jsp:include page="/customer/common/vsport-theme.jsp" />

    <style>
        body { background-color: var(--vs-background, #F4F7FB); font-family: 'Montserrat', 'Inter', system-ui, sans-serif; }
        .lci { width: 20px; height: 20px; flex-shrink: 0; }

        /* ============================ Sticky search header (Navy) ============================= */
        .tk-header {
            position: sticky; top: 0; z-index: 40;
            background: var(--vs-primary-900, #0B2545);
            display: flex; align-items: center; gap: 10px;
            height: 56px; padding: 0 10px;
        }
        @media (min-width: 768px) { .tk-header { height: 60px; padding: 0 16px; } }
        .tk-back {
            display: flex; align-items: center; justify-content: center;
            width: 40px; height: 40px; border-radius: 50%; flex-shrink: 0;
            border: none; background: transparent; color: #fff; cursor: pointer;
            transition: background-color .15s ease;
        }
        .tk-back:hover { background: rgba(255,255,255,0.14); }
        .tk-back:focus-visible { outline: 3px solid var(--vs-focus-ring, rgba(24, 200, 232, 0.35)); outline-offset: 2px; }
        .tk-title { flex: 1; text-align: center; color: #fff; font-size: 16px; font-weight: 700; }
        .tk-filter-btn {
            display: flex; align-items: center; justify-content: center;
            width: 40px; height: 40px; border-radius: 50%; flex-shrink: 0;
            border: none; background: transparent; color: #fff; cursor: pointer;
            transition: background-color .15s ease;
        }
        .tk-filter-btn:hover { background: rgba(255,255,255,0.14); }
        .tk-filter-btn:focus-visible { outline: 3px solid var(--vs-focus-ring, rgba(24, 200, 232, 0.35)); outline-offset: 2px; }
        .tk-filter-btn.has-active::after {
            content: ""; position: absolute; width: 8px; height: 8px; border-radius: 50%;
            background: var(--vs-orange-500, #FF8A24); transform: translate(10px, -10px);
        }

        /* ============================ Search input bar ============================= */
        .tk-searchbar-wrap { padding: 10px; }
        @media (min-width: 768px) { .tk-searchbar-wrap { padding: 12px 16px; } }
        .tk-searchbar {
            display: flex; align-items: center; gap: 8px;
            background: #fff; border: 1px solid var(--vs-border, #DCE5EF); border-radius: 10px;
            box-shadow: 0 2px 8px rgba(7, 26, 47, 0.08);
            height: 50px; padding: 0 6px 0 14px;
        }
        .tk-searchbar:focus-within { border-color: var(--vs-cyan-500, #18C8E8); box-shadow: 0 0 0 3px var(--vs-focus-ring, rgba(24, 200, 232, 0.35)); }
        .tk-searchbar svg { width: 24px; height: 24px; flex-shrink: 0; }
        .tk-searchbar input {
            flex: 1; min-width: 0; border: none; outline: none; background: transparent;
            font-size: 15px; color: var(--vs-text, #102A43); height: 100%;
        }
        .tk-searchbar input::placeholder { color: var(--vs-muted, #829AB1); }
        .tk-clear-btn, .tk-submit-btn {
            display: flex; align-items: center; justify-content: center;
            width: 38px; height: 38px; border-radius: 8px; border: none; background: transparent;
            color: var(--vs-muted, #829AB1); cursor: pointer; flex-shrink: 0;
            transition: background-color .15s ease, color .15s ease;
        }
        .tk-clear-btn:hover { background: var(--vs-cyan-50, #F0FCFE); color: var(--vs-text, #102A43); }
        .tk-submit-btn { color: var(--vs-primary-600, #1677D2); }
        .tk-submit-btn:hover { background: var(--vs-cyan-50, #F0FCFE); }

        /* Active filter chips summary row */
        .tk-active-filters { display: flex; flex-wrap: wrap; gap: 6px; padding: 0 10px 8px; }
        @media (min-width: 768px) { .tk-active-filters { padding: 0 16px 10px; } }
        .tk-filter-chip {
            display: inline-flex; align-items: center; gap: 6px;
            background: var(--vs-cyan-50, #F0FCFE); border: 1px solid var(--vs-cyan-100, #DDF8FC);
            color: var(--vs-primary-700, #185A9D); font-size: 12.5px; font-weight: 700;
            padding: 5px 10px; border-radius: 9999px;
        }
        .tk-filter-chip a { display: flex; color: inherit; }
        .tk-filter-chip svg { width: 14px; height: 14px; }
        .tk-clear-all-link { font-size: 12.5px; font-weight: 700; color: var(--vs-danger, #E5484D); text-decoration: underline; padding: 5px 4px; }

        /* ============================ Filter panel (popover) ============================= */
        .tk-filter-overlay {
            position: fixed; inset: 0; background: var(--vs-overlay, rgba(7,26,47,.68));
            z-index: 90; opacity: 0; visibility: hidden; transition: opacity .2s ease, visibility .2s ease;
        }
        .tk-filter-overlay.is-open { opacity: 1; visibility: visible; }
        .tk-filter-panel {
            position: fixed; left: 50%; top: 50%; transform: translate(-50%, -50%) scale(.97);
            width: min(420px, calc(100vw - 24px)); max-height: calc(100dvh - 40px); overflow-y: auto;
            background: #fff; border-radius: 16px; padding: 20px; z-index: 91;
            opacity: 0; visibility: hidden; transition: opacity .2s ease, transform .2s ease, visibility .2s ease;
            box-shadow: 0 24px 60px rgba(7, 26, 47, 0.3);
        }
        .tk-filter-panel.is-open { opacity: 1; visibility: visible; transform: translate(-50%, -50%) scale(1); }
        .tk-filter-panel h2 { font-size: 17px; font-weight: 800; color: var(--vs-text, #102A43); margin-bottom: 14px; }
        .tk-filter-group { margin-bottom: 16px; }
        .tk-filter-label { font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: .04em; color: var(--vs-muted, #829AB1); margin-bottom: 8px; display: block; }
        .tk-filter-options { display: flex; flex-wrap: wrap; gap: 8px; }
        .tk-filter-option {
            display: inline-flex; align-items: center; gap: 6px; cursor: pointer;
            border: 1px solid var(--vs-border, #DCE5EF); border-radius: 9999px;
            padding: 7px 13px; font-size: 13px; font-weight: 600; color: var(--vs-text, #102A43);
            transition: border-color .15s ease, background-color .15s ease;
        }
        .tk-filter-option:has(input:checked) { border-color: var(--vs-primary-600, #1677D2); background: var(--vs-cyan-50, #F0FCFE); color: var(--vs-primary-700, #185A9D); }
        .tk-filter-option input { position: absolute; opacity: 0; width: 0; height: 0; }
        .tk-filter-toggle { display: flex; align-items: center; justify-content: space-between; padding: 10px 0; }
        .tk-filter-actions { display: flex; gap: 10px; margin-top: 6px; }
        .tk-filter-actions .vs-btn { flex: 1; }

        /* ============================ Result grid ============================= */
        .tk-main { width: 100%; padding: 0 10px; }
        @media (min-width: 768px) { .tk-main { padding: 0 16px; } }
        .tk-result-count { font-size: 13px; font-weight: 600; color: var(--vs-text-secondary, #486581); padding: 4px 2px 10px; }
        .tk-grid {
            display: grid; grid-template-columns: 1fr; gap: 10px; padding-bottom: 24px;
        }
        @media (min-width: 640px)  { .tk-grid { grid-template-columns: repeat(2, 1fr); } }
        @media (min-width: 1024px) { .tk-grid { grid-template-columns: repeat(3, 1fr); } }
        @media (min-width: 1280px) { .tk-grid { grid-template-columns: repeat(4, 1fr); } }

        /* Skeleton loading state */
        .tk-skel-card { border-radius: 14px; overflow: hidden; border: 1px solid var(--vs-border, #DCE5EF); background: #fff; }
        .tk-skel-img { height: 122px; background: linear-gradient(90deg, #eef4f1 25%, #e2ece7 37%, #eef4f1 63%); background-size: 400% 100%; animation: tkShimmer 1.4s ease infinite; }
        .tk-skel-line { height: 12px; margin: 10px 12px; border-radius: 6px; background: linear-gradient(90deg, #eef4f1 25%, #e2ece7 37%, #eef4f1 63%); background-size: 400% 100%; animation: tkShimmer 1.4s ease infinite; }
        @keyframes tkShimmer { 0% { background-position: 100% 50%; } 100% { background-position: 0 50%; } }

        /* Empty / error states */
        .tk-state { grid-column: 1 / -1; text-align: center; padding: 60px 16px; }
        .tk-state .material-symbols-outlined { font-size: 52px; color: #cbd5e1; display: block; margin: 0 auto 12px; }
        .tk-state p { font-size: 14.5px; font-weight: 600; color: var(--vs-text-secondary, #486581); margin-bottom: 16px; }

        @media (prefers-reduced-motion: reduce) {
            .tk-filter-overlay, .tk-filter-panel { transition: none !important; }
            .tk-skel-img, .tk-skel-line { animation: none; }
        }
    </style>
</head>
<body class="antialiased overflow-x-hidden">

    <header class="tk-header">
        <button type="button" id="tkBackBtn" class="tk-back" aria-label="Quay lại">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" style="width:22px;height:22px;"><path d="m15 18-6-6 6-6"/></svg>
        </button>
        <h1 class="tk-title">Tìm kiếm</h1>
        <button type="button" id="tkOpenFilterBtn" class="tk-filter-btn" aria-label="Bộ lọc" aria-haspopup="dialog"
                <c:if test="${not empty sportId or openNow}">style="position:relative;"</c:if>>
            <span class="material-symbols-outlined" aria-hidden="true">tune</span>
        </button>
    </header>

    <form id="tkSearchForm" class="tk-searchbar-wrap" action="${ctx}/customer/tim-kiem" method="get" role="search">
        <div class="tk-searchbar">
            <svg viewBox="0 0 24 24" fill="none" aria-hidden="true">
                <path d="M12 21.5c-1.05 0-1.9-.9-1.9-2s.85-2 1.9-2 1.9.9 1.9 2-.85 2-1.9 2Z" fill="#1677D2"/>
                <path d="M12 17.7 5.6 4.9" stroke="#18C8E8" stroke-width="1.6" stroke-linecap="round"/>
                <path d="M12 17.7 9.9 3.6" stroke="#18C8E8" stroke-width="1.6" stroke-linecap="round"/>
                <path d="M12 17.7 12 3.1" stroke="#18C8E8" stroke-width="1.6" stroke-linecap="round"/>
                <path d="M12 17.7 14.1 3.6" stroke="#18C8E8" stroke-width="1.6" stroke-linecap="round"/>
                <path d="M12 17.7 18.4 4.9" stroke="#18C8E8" stroke-width="1.6" stroke-linecap="round"/>
                <path d="M5.6 4.9 9.9 3.6 12 3.1 14.1 3.6 18.4 4.9" stroke="#1677D2" stroke-width="1.4" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
            <label for="tkSearchInput" style="position:absolute;width:1px;height:1px;overflow:hidden;clip:rect(0,0,0,0);">Nhập tên sân, cơ sở hoặc địa chỉ</label>
            <input type="text" id="tkSearchInput" name="q" autocomplete="off" autofocus
                   value="<c:out value='${query}'/>"
                   placeholder="Nhập tên sân, cơ sở hoặc địa chỉ" aria-label="Nhập tên sân, cơ sở hoặc địa chỉ" />
            <button type="button" id="tkClearBtn" class="tk-clear-btn" aria-label="Xóa nội dung tìm kiếm" <c:if test="${empty query}">hidden</c:if>>
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" style="width:18px;height:18px;"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg>
            </button>
            <button type="submit" class="tk-submit-btn" aria-label="Tìm kiếm">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" style="width:20px;height:20px;"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/></svg>
            </button>
        </div>
        <input type="hidden" name="sportId" id="tkSportIdInput" value="<c:out value='${sportId}'/>"/>
        <input type="hidden" name="openNow" id="tkOpenNowInput" value="<c:if test='${openNow}'>true</c:if>"/>
    </form>

    <c:if test="${not empty sportId or openNow}">
        <c:url var="tkRemoveSportUrl" value="/customer/tim-kiem">
            <c:param name="q" value="${query}"/>
            <c:if test="${openNow}"><c:param name="openNow" value="true"/></c:if>
        </c:url>
        <c:url var="tkRemoveOpenNowUrl" value="/customer/tim-kiem">
            <c:param name="q" value="${query}"/>
            <c:if test="${not empty sportId}"><c:param name="sportId" value="${sportId}"/></c:if>
        </c:url>
        <c:url var="tkClearAllUrl" value="/customer/tim-kiem">
            <c:param name="q" value="${query}"/>
        </c:url>
        <div class="tk-active-filters">
            <c:if test="${not empty sportId}">
                <c:forEach var="m" items="${dsMon}">
                    <c:if test="${m.monTheThaoID == sportId}">
                        <span class="tk-filter-chip">
                            <c:out value="${m.tenMon}"/>
                            <a href="${tkRemoveSportUrl}" aria-label="Bỏ lọc môn thể thao">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg>
                            </a>
                        </span>
                    </c:if>
                </c:forEach>
            </c:if>
            <c:if test="${openNow}">
                <span class="tk-filter-chip">
                    Đang mở cửa
                    <a href="${tkRemoveOpenNowUrl}" aria-label="Bỏ lọc đang mở cửa">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg>
                    </a>
                </span>
            </c:if>
            <a class="tk-clear-all-link" href="${tkClearAllUrl}">Xóa bộ lọc</a>
        </div>
    </c:if>

    <main class="tk-main">
        <c:choose>
            <c:when test="${searchError}">
                <div class="tk-grid">
                    <div class="tk-state">
                        <span class="material-symbols-outlined" aria-hidden="true">wifi_off</span>
                        <p>Không thể tải kết quả. Vui lòng thử lại.</p>
                        <button type="button" class="vs-btn vs-btn-secondary" onclick="window.location.reload()">Thử lại</button>
                    </div>
                </div>
            </c:when>
            <c:when test="${empty results}">
                <div class="tk-grid">
                    <div class="tk-state">
                        <span class="material-symbols-outlined" aria-hidden="true">search_off</span>
                        <p>Không tìm thấy sân phù hợp.</p>
                        <a class="vs-btn vs-btn-secondary" href="${ctx}/customer/tim-kiem">Xóa bộ lọc</a>
                    </div>
                </div>
            </c:when>
            <c:otherwise>
                <p class="tk-result-count">Tìm thấy <c:out value="${fn:length(results)}"/> kết quả</p>
                <div id="facilityGrid" class="tk-grid">
                    <%
                        @SuppressWarnings("unchecked")
                        List<CoSo> tkResults = (List<CoSo>) request.getAttribute("results");
                        String ctx2 = request.getContextPath();
                        if (tkResults != null) {
                            for (CoSo cs : tkResults) {
                                String csImg = cs.getHinhAnh() != null ? cs.getHinhAnh().trim() : "";
                                String csOpen = cs.getGioMoCua() != null ? cs.getGioMoCua().toString().substring(0,5) : "06:00";
                                String csClose = cs.getGioDongCua() != null ? cs.getGioDongCua().toString().substring(0,5) : "23:00";
                                String businessType = cs.getLoaiHinhKinhDoanh() != null ? cs.getLoaiHinhKinhDoanh() : "";
                                String csName = cs.getTenCoSo() != null ? cs.getTenCoSo() : "";
                                String csNameSafe = csName.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
                                String csAddr = cs.getDiaChi() != null ? cs.getDiaChi() : "";
                                String csAddrSafe = csAddr.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");

                                String sportsLower = businessType.toLowerCase();
                                String fbImg = "hero-sports-facility.webp";
                                if (sportsLower.contains("bóng đá") || sportsLower.contains("bong da")) fbImg = "sport-football.webp";
                                else if (sportsLower.contains("cầu lông") || sportsLower.contains("cau long")) fbImg = "sport-badminton.webp";
                                else if (sportsLower.contains("pickle")) fbImg = "sport-pickleball.webp";
                                else if (sportsLower.contains("tennis")) fbImg = "sport-tennis.webp";
                                else if (sportsLower.contains("bóng bàn") || sportsLower.contains("bong ban")) fbImg = "sport-tabletennis.webp";
                                else if (sportsLower.contains("gym") || sportsLower.contains("fitness")) fbImg = "sport-gym.webp";
                                String fbImgUrl = ctx2 + "/assets/images/home/" + fbImg;

                                String cardImgUrl = fbImgUrl;
                                if (csImg.startsWith("http")) {
                                    cardImgUrl = csImg;
                                } else if (csImg.contains("/")) {
                                    String rel = csImg.startsWith("/") ? csImg : "/" + csImg;
                                    String realPath = application.getRealPath(rel);
                                    if (realPath != null && new java.io.File(realPath).isFile()) {
                                        cardImgUrl = ctx2 + rel;
                                    }
                                }

                                String firstSport = businessType.contains(",") ? businessType.substring(0, businessType.indexOf(',')).trim() : businessType.trim();
                                String firstSportSafe = firstSport.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
                    %>
                        <div class="facility-card vs-card overflow-hidden group flex flex-col relative bg-white border border-gray-100 hover:shadow-md transition-shadow duration-300 cursor-pointer"
                             data-coso-id="<%= cs.getCoSoID() %>"
                             data-facility-name="<%= csNameSafe %>"
                             data-card-image="<%= cardImgUrl.replace("\"", "&quot;") %>"
                             role="button" tabindex="0"
                             aria-label="Xem chi tiết <%= csNameSafe %>">

                            <div class="relative w-full h-[122px] overflow-hidden bg-gray-100 shrink-0">
                                <img class="w-full h-full object-cover"
                                     src="<%= cardImgUrl %>"
                                     onerror="this.onerror=null;this.src='<%= fbImgUrl %>';"
                                     alt="<%= csNameSafe %>" />
                                <div class="absolute top-1.5 left-1.5 flex gap-1 z-10">
                                    <% if (!firstSport.isEmpty()) { %>
                                        <span class="text-[10px] font-bold text-[#08A9CC] bg-[#F0FCFE]/95 px-2 py-0.5 rounded shadow-sm"><%= firstSportSafe %></span>
                                    <% } %>
                                </div>
                                <div class="absolute top-1.5 right-1.5 flex gap-1 z-10">
                                    <button onclick="toggleFavorite('<%= cs.getCoSoID() %>', this)" aria-label="Lưu cơ sở yêu thích" title="Yêu thích" class="w-7 h-7 bg-white/95 rounded-full flex items-center justify-center text-gray-400 hover:text-red-500 shadow-sm transition-colors border-none cursor-pointer">
                                        <span class="material-symbols-outlined text-[15px]" aria-hidden="true">favorite</span>
                                    </button>
                                    <button onclick="shareFacility('<%= csNameSafe %>', '<%= cs.getCoSoID() %>')" aria-label="Chia sẻ cơ sở" title="Chia sẻ" class="w-7 h-7 bg-white/95 rounded-full flex items-center justify-center text-gray-400 hover:text-[#1677D2] shadow-sm transition-colors border-none cursor-pointer">
                                        <span class="material-symbols-outlined text-[15px]" aria-hidden="true">share</span>
                                    </button>
                                </div>
                            </div>

                            <div class="px-3 py-2.5 flex gap-2.5 items-start">
                                <div class="w-9 h-9 rounded-full bg-[#F0FCFE] border border-[#DDF8FC] flex items-center justify-center text-[#08A9CC] shrink-0 select-none mt-0.5">
                                    <span class="material-symbols-outlined text-[17px]" aria-hidden="true">sports_tennis</span>
                                </div>
                                <div class="flex-1 min-w-0">
                                    <h3 class="font-bold text-gray-900 text-[14px] leading-snug truncate group-hover:text-[#1677D2] transition-colors" title="<%= csNameSafe %>">
                                        <%= csNameSafe %>
                                    </h3>
                                    <p class="text-[12px] text-gray-500 truncate mt-0.5 flex items-center gap-1" title="<%= csAddrSafe %>">
                                        <span class="material-symbols-outlined text-[13px] text-[#18C8E8] shrink-0" aria-hidden="true">location_on</span>
                                        <span class="truncate"><%= csAddr.isEmpty() ? "Chưa cập nhật" : csAddrSafe %></span>
                                    </p>
                                    <p class="text-[12px] text-gray-500 mt-0.5 flex items-center gap-1">
                                        <span class="material-symbols-outlined text-[13px] text-[#18C8E8]" aria-hidden="true">schedule</span>
                                        <span><%= csOpen %> - <%= csClose %></span>
                                    </p>
                                </div>
                                <div class="shrink-0 self-center">
                                    <button type="button" data-book-trigger
                                            data-coso-id="<%= cs.getCoSoID() %>"
                                            data-facility-name="<%= csNameSafe %>"
                                            aria-label="Đặt lịch tại <%= csNameSafe %>" aria-haspopup="dialog"
                                            class="bg-[#FF8A24] hover:bg-[#F97316] text-white text-[11.5px] font-extrabold px-3 py-2 rounded-md tracking-wide transition-colors shadow-sm whitespace-nowrap border-none cursor-pointer">
                                        ĐẶT LỊCH
                                    </button>
                                </div>
                            </div>
                        </div>
                    <% } } %>
                </div>
            </c:otherwise>
        </c:choose>
    </main>

    <!-- ============ Filter panel (sport / open-now) ============ -->
    <div id="tkFilterOverlay" class="tk-filter-overlay"></div>
    <div id="tkFilterPanel" class="tk-filter-panel" role="dialog" aria-modal="true" aria-labelledby="tkFilterTitle">
        <h2 id="tkFilterTitle">Bộ lọc tìm kiếm</h2>
        <div class="tk-filter-group">
            <span class="tk-filter-label">Môn thể thao</span>
            <div class="tk-filter-options">
                <label class="tk-filter-option">
                    <input type="radio" name="tkSportChoice" value="" <c:if test="${empty sportId}">checked</c:if> />
                    Tất cả
                </label>
                <c:forEach var="m" items="${dsMon}">
                    <label class="tk-filter-option">
                        <input type="radio" name="tkSportChoice" value="<c:out value='${m.monTheThaoID}'/>" <c:if test="${sportId == m.monTheThaoID}">checked</c:if> />
                        <c:out value="${m.tenMon}"/>
                    </label>
                </c:forEach>
            </div>
        </div>
        <div class="tk-filter-toggle">
            <span class="tk-filter-label" style="margin:0;">Chỉ hiện cơ sở đang mở cửa</span>
            <label style="position:relative; display:inline-flex; align-items:center; cursor:pointer;">
                <input type="checkbox" id="tkOpenNowToggle" <c:if test="${openNow}">checked</c:if> style="width:40px;height:22px;accent-color:var(--vs-primary-600,#1677D2);" />
            </label>
        </div>
        <div class="tk-filter-actions">
            <button type="button" id="tkClearFilterBtn" class="vs-btn vs-btn-ghost">Xóa bộ lọc</button>
            <button type="button" id="tkApplyFilterBtn" class="vs-btn vs-btn-primary">Áp dụng</button>
        </div>
    </div>

    <jsp:include page="/customer/common/facility-interactions.jsp" />
    <jsp:include page="/customer/common/bottom-nav.jsp" />

    <script>
        (function () {
            'use strict';
            var CTX = '<%= request.getContextPath() %>';

            // ---- Back: safe history.back() when the previous page is same-origin,
            // fallback to Customer Home otherwise. ----
            document.getElementById('tkBackBtn').addEventListener('click', function () {
                try {
                    var ref = document.referrer;
                    if (ref && history.length > 1) {
                        var refUrl = new URL(ref);
                        if (refUrl.origin === window.location.origin) {
                            history.back();
                            return;
                        }
                    }
                } catch (e) { /* fallback below */ }
                window.location.href = CTX + '/index.jsp';
            });

            // ---- Clear search input ----
            var searchInput = document.getElementById('tkSearchInput');
            var clearBtn = document.getElementById('tkClearBtn');
            function refreshClearBtn() { clearBtn.hidden = !searchInput.value; }
            searchInput.addEventListener('input', refreshClearBtn);
            clearBtn.addEventListener('click', function () {
                searchInput.value = '';
                refreshClearBtn();
                searchInput.focus();
            });

            // ---- Debounced auto-search while typing (250-350ms), Enter submits immediately ----
            var searchForm = document.getElementById('tkSearchForm');
            var debounceTimer = null;
            searchInput.addEventListener('input', function () {
                clearTimeout(debounceTimer);
                debounceTimer = setTimeout(function () { searchForm.submit(); }, 320);
            });
            searchInput.addEventListener('keydown', function (e) {
                if (e.key === 'Enter') {
                    clearTimeout(debounceTimer);
                    // native form submit on Enter, no extra handling needed
                }
            });

            // ---- Toast (used by favorite/share buttons on cards; shared toast comes
            // from facility-interactions.jsp fragment via window.showHomeToast) ----
            function toggleFavorite(id, btn) {
                event.stopPropagation();
                var iconEl = btn.querySelector('.material-symbols-outlined');
                if (iconEl.classList.contains('fill-current')) {
                    iconEl.classList.remove('fill-current');
                    btn.classList.add('text-gray-400');
                    btn.classList.remove('text-red-500');
                    if (window.showHomeToast) showHomeToast('Đã bỏ lưu cơ sở');
                } else {
                    iconEl.classList.add('fill-current');
                    btn.classList.remove('text-gray-400');
                    btn.classList.add('text-red-500');
                    if (window.showHomeToast) showHomeToast('Đã thêm vào danh sách yêu thích');
                }
            }
            window.toggleFavorite = toggleFavorite;

            function shareFacility(name, id) {
                event.stopPropagation();
                if (navigator.clipboard) {
                    var url = window.location.origin + CTX + '/customer/dat-san?facilityId=' + id;
                    navigator.clipboard.writeText(url).then(function () {
                        if (window.showHomeToast) showHomeToast('Đã sao chép liên kết chia sẻ cơ sở ' + name);
                    }).catch(function () {
                        if (window.showHomeToast) showHomeToast('Không thể sao chép liên kết');
                    });
                } else if (window.showHomeToast) {
                    showHomeToast('Trình duyệt không hỗ trợ sao chép liên kết');
                }
            }
            window.shareFacility = shareFacility;

            // ---- Filter panel open/close ----
            var filterOverlay = document.getElementById('tkFilterOverlay');
            var filterPanel = document.getElementById('tkFilterPanel');
            function openFilterPanel() {
                filterOverlay.classList.add('is-open');
                filterPanel.classList.add('is-open');
                document.body.style.overflow = 'hidden';
            }
            function closeFilterPanel() {
                filterOverlay.classList.remove('is-open');
                filterPanel.classList.remove('is-open');
                document.body.style.overflow = '';
            }
            document.getElementById('tkOpenFilterBtn').addEventListener('click', openFilterPanel);
            filterOverlay.addEventListener('click', closeFilterPanel);
            document.addEventListener('keydown', function (e) {
                if (e.key === 'Escape' && filterPanel.classList.contains('is-open')) closeFilterPanel();
            });

            document.getElementById('tkApplyFilterBtn').addEventListener('click', function () {
                var chosen = document.querySelector('input[name="tkSportChoice"]:checked');
                document.getElementById('tkSportIdInput').value = chosen && chosen.value ? chosen.value : '';
                document.getElementById('tkOpenNowInput').value = document.getElementById('tkOpenNowToggle').checked ? 'true' : '';
                searchForm.submit();
            });
            document.getElementById('tkClearFilterBtn').addEventListener('click', function () {
                document.getElementById('tkSportIdInput').value = '';
                document.getElementById('tkOpenNowInput').value = '';
                searchForm.submit();
            });
        })();
    </script>
</body>
</html>
