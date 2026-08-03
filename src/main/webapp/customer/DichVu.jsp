<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi">
<head>
<jsp:include page="/common/xtra-head.jsp" />
<title>Dịch vụ thể thao gần bạn - V-SPORT</title>
<style>
  /* ─── Layout ─── */
  .dv-wrap { width: 100%; max-width: 100%; margin: 0; padding: 32px clamp(24px, 4vw, 64px) 80px; box-sizing: border-box; }

  /* ─── Header ─── */
  .dv-header { margin-bottom: 4px; }
  .dv-header h1 { font-size: 28px; font-weight: 800; color: var(--navy); margin: 0 0 6px; }
  .dv-header p { color: var(--body-text); font-size: 14.5px; margin: 0; }

  /* ─── Tabs ─── */
  .dv-tabs { display:flex; gap:0; border-bottom: 2px solid var(--border); margin: 20px 0 20px; }
  .dv-tab {
    padding: 11px 22px; border: none; background: none; font-size: 14px; font-weight: 700;
    color: var(--muted-text); cursor: pointer; border-bottom: 2px solid transparent; margin-bottom: -2px;
    transition: color .15s, border-color .15s;
  }
  .dv-tab.active { color: var(--navy); border-bottom-color: var(--navy); }
  .dv-tab:hover:not(.active) { color: var(--body-text); }

  /* ─── Search bar ─── */
  .dv-search { display:flex; gap:10px; margin: 0 0 14px; flex-wrap: wrap; }
  .dv-search input[type="text"] {
    flex: 1; min-width: 240px; padding: 12px 16px; border-radius: var(--radius-medium);
    border: 1.5px solid var(--border); font-size: 14px; outline: none; background: var(--surface);
    transition: border-color .15s;
  }
  .dv-search input[type="text"]:focus { border-color: var(--primary); box-shadow: 0 0 0 3px rgba(34,197,94,.1); }
  .dv-gps-btn, .dv-filter-btn {
    padding: 12px 18px; border-radius: var(--radius-medium); border: 1.5px solid var(--border);
    background: var(--surface); font-weight: 700; font-size: 13.5px; color: var(--navy); cursor: pointer;
    display:flex; align-items:center; gap:6px; white-space: nowrap; transition: all .15s;
  }
  .dv-gps-btn:hover { background: #f0f9ff; border-color: #93c5fd; }
  .dv-gps-btn.is-active { border-color: var(--primary); color: #15803d; background:#f0fdf4; }

  /* ─── Quick filter chips ─── */
  .dv-quick-filters { display:flex; gap:8px; flex-wrap: wrap; margin-bottom: 22px; }
  .dv-chip {
    padding: 6px 14px; border-radius: 999px; border: 1.5px solid var(--border); background: var(--surface);
    font-size: 12.5px; font-weight: 600; color: var(--body-text); cursor: pointer; user-select:none;
    transition: all .15s;
  }
  .dv-chip:hover { border-color: var(--navy); color: var(--navy); }
  .dv-chip.active { background: var(--navy); border-color: var(--navy); color: #fff; }

  /* ─── Service grid ─── */
  .dv-grid { display:grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 18px; }

  /* ─── Service card ─── */
  .dv-card {
    background: var(--surface); border: 1px solid var(--border); border-radius: 14px;
    overflow: hidden; cursor: pointer; transition: box-shadow .2s, transform .2s;
    box-shadow: 0 1px 3px rgba(0,0,0,.06);
  }
  .dv-card:hover { box-shadow: 0 8px 24px rgba(0,0,0,.12); transform: translateY(-3px); }
  .dv-card-img { height: 140px; background: linear-gradient(135deg,#0f2336,#1a3c54); position:relative; overflow:hidden; }
  .dv-card-img img { width:100%; height:100%; object-fit:cover; }
  .dv-status-badge {
    position:absolute; top:10px; left:10px; padding:3px 10px; border-radius:999px; font-size:11px; font-weight:700;
    backdrop-filter: blur(4px);
  }
  .dv-status-open { background:rgba(220,252,231,.9); color:#15803d; }
  .dv-status-paused { background:rgba(241,245,249,.9); color:#475569; }
  .dv-status-lowstock { background:rgba(254,249,195,.9); color:#92400e; }
  .dv-status-outofstock { background:rgba(254,226,226,.9); color:#b91c1c; }
  .dv-card-body { padding: 14px 16px 16px; }
  .dv-card-body h3 { font-size: 15px; font-weight: 800; color: var(--navy); margin: 0 0 4px; line-height:1.3; }
  .dv-card-facility { font-size: 12.5px; color: var(--muted-text); margin: 0 0 8px; display:flex; align-items:center; gap:4px; }
  .dv-card-meta { display:flex; align-items:center; justify-content:space-between; font-size:12.5px; color: var(--body-text); }
  .dv-price { font-weight: 800; color: var(--navy); font-size: 14.5px; }

  /* ─── Product grid (nhiều cột, lấp đầy chiều ngang) ─── */
  .sp-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
    gap: 18px;
  }
  .sp-card {
    background: #fff; border: 1px solid #e8ecf0; border-radius: 14px;
    overflow: hidden; cursor: pointer; transition: box-shadow .2s, transform .2s;
    box-shadow: 0 1px 3px rgba(0,0,0,.05); display: flex; flex-direction: column;
  }
  .sp-card:hover { box-shadow: 0 8px 28px rgba(0,0,0,.13); transform: translateY(-3px); }

  .sp-img-wrap {
    position: relative; padding-top: 75%; /* 4:3 */
    background: linear-gradient(135deg,#f1f5f9,#e2e8f0); overflow: hidden;
  }
  .sp-img-wrap img {
    position:absolute; inset:0; width:100%; height:100%; object-fit:cover;
    transition: transform .3s;
  }
  .sp-card:hover .sp-img-wrap img { transform: scale(1.04); }
  .sp-img-placeholder {
    position:absolute; inset:0; display:flex; flex-direction:column;
    align-items:center; justify-content:center; color:#94a3b8; gap:6px;
  }
  .sp-img-placeholder i { font-size:28px; }
  .sp-img-placeholder span { font-size:11px; font-weight:600; }

  .sp-stock-badge {
    position:absolute; top:8px; left:8px; padding:3px 9px;
    border-radius:999px; font-size:10.5px; font-weight:700; backdrop-filter:blur(4px);
  }
  .sp-stock-in  { background:rgba(220,252,231,.92); color:#15803d; }
  .sp-stock-low { background:rgba(254,249,195,.92); color:#92400e; }
  .sp-stock-out { background:rgba(254,226,226,.92); color:#b91c1c; }

  .sp-card-body { padding: 12px 14px 14px; flex:1; display:flex; flex-direction:column; gap:4px; }
  .sp-card-name { font-size:14px; font-weight:800; color:#0f2336; margin:0; line-height:1.3;
    display:-webkit-box; -webkit-line-clamp:2; -webkit-box-orient:vertical; overflow:hidden; }
  .sp-card-cat  { font-size:11.5px; color:#64748b; font-weight:600; margin:0; }
  .sp-card-loc  { font-size:11.5px; color:#94a3b8; display:flex; align-items:center; gap:3px; margin:0; }
  .sp-card-footer { margin-top:auto; padding-top:10px; display:flex; align-items:center; justify-content:space-between; }
  .sp-price { font-size:15px; font-weight:800; color:#0f2336; }
  .sp-price-unit { font-size:11px; color:#94a3b8; font-weight:600; }
  .sp-buy-btn {
    padding:6px 12px; border-radius:8px; background:#0f2336; color:#fff;
    font-size:11.5px; font-weight:700; border:none; cursor:pointer; transition:background .15s;
    white-space:nowrap;
  }
  .sp-buy-btn:hover { background:#1e40af; }
  .sp-buy-btn:disabled { background:#94a3b8; cursor:default; }

  /* ─── Section separator for product panel ─── */
  #dvPanelProduct .sp-section-header {
    display: flex; align-items:center; justify-content:space-between;
    margin-bottom: 16px;
  }
  #dvPanelProduct .sp-count-badge {
    font-size:12px; font-weight:700; color:#64748b;
    background:#f1f5f9; padding:3px 10px; border-radius:999px;
  }

  /* ─── Empty state ─── */
  .dv-empty { text-align:center; padding: 60px 20px; color: var(--muted-text); }
  .dv-empty i { font-size: 40px; margin-bottom: 12px; opacity:.4; }

  /* ─── Responsive ─── */
  @media (max-width: 900px) {
    .sp-grid { grid-template-columns: repeat(auto-fill, minmax(170px, 1fr)); gap:14px; }
  }
  @media (max-width: 768px) {
    .dv-wrap { padding: 24px 16px 70px; }
    .dv-header h1 { font-size: 24px; }
    .dv-search { flex-direction: column; }
    .dv-search input[type="text"] { min-width: 0; width: 100%; }
    .dv-gps-btn { width: 100%; justify-content: center; }
    .dv-grid { grid-template-columns: repeat(auto-fill, minmax(160px, 1fr)); gap: 12px; }
    .sp-grid { grid-template-columns: repeat(3, 1fr); gap:12px; }
  }
  @media (max-width: 480px) {
    .dv-wrap { padding: 20px 12px 70px; }
    .dv-grid { grid-template-columns: 1fr 1fr; gap: 10px; }
    .dv-card-img { height: 110px; }
    .sp-grid { grid-template-columns: repeat(2, 1fr); gap:10px; }
    .sp-card-name { font-size:13px; }
    .sp-price { font-size:13.5px; }
    .dv-tabs { overflow-x: auto; }
    .dv-quick-filters { overflow-x: auto; flex-wrap: nowrap; padding-bottom: 4px; }
    .dv-chip { flex-shrink: 0; }
  }

  .dv-drawer-overlay { position:fixed; inset:0; background:rgba(18,45,64,.5); z-index:80; display:none; }
  .dv-drawer-overlay.open { display:block; }
  .dv-drawer { position:fixed; top:0; right:0; height:100vh; width:100%; max-width:480px; background:#fff; z-index:81;
    transform:translateX(100%); transition:transform .25s ease; overflow-y:auto; box-shadow:-10px 0 30px rgba(0,0,0,.15); }
  .dv-drawer.open { transform:translateX(0); }
  .dv-drawer-head { display:flex; justify-content:space-between; align-items:center; padding:18px 20px; border-bottom:1px solid var(--border); }
  .dv-drawer-body { padding: 18px 20px 100px; display:flex; flex-direction:column; gap:14px; }
  .dv-drawer-row { display:flex; justify-content:space-between; font-size:13.5px; padding:8px 0; border-bottom:1px dashed var(--border); }
  .dv-drawer-row span:first-child { color: var(--muted-text); }
  .dv-drawer-row span:last-child { font-weight:700; color: var(--navy); text-align:right; }
  .dv-cta-bar { position:fixed; bottom:0; right:0; width:100%; max-width:480px; background:#fff; border-top:1px solid var(--border);
    padding: 14px 20px; z-index:82; display:none; }
  .dv-cta-bar.open { display:block; }
  .dv-cta-btn { width:100%; padding: 13px; border-radius: var(--radius-medium); background: var(--navy); color:#fff;
    font-weight:800; font-size:14px; border:none; cursor:pointer; }
</style>
</head>
<body>

<jsp:include page="/common/header-xtra.jsp" />

<main class="dv-wrap">
  <section class="dv-header">
    <h1>Cửa hàng &amp; Dịch vụ</h1>
    <p>Tìm cơ sở cung cấp dịch vụ căng lưới, sửa chữa, hỗ trợ dụng cụ và sản phẩm thể thao phù hợp với nhu cầu của bạn.</p>
  </section>

  <div class="dv-tabs" id="dvTabs">
    <button type="button" class="dv-tab active" data-tab="dich-vu">Dịch vụ</button>
    <button type="button" class="dv-tab" data-tab="san-pham">Sản phẩm</button>
  </div>

  <div id="dvPanelService">
    <div class="dv-search">
      <input type="text" id="dvSearchInput" placeholder="Tìm dịch vụ căng lưới, thay quấn cán, sửa vợt..."/>
      <button type="button" class="dv-gps-btn" id="dvGpsBtn" onclick="useMyLocation()">
        <i class="fa-solid fa-location-crosshairs"></i> Gần tôi
      </button>
    </div>

    <div class="dv-quick-filters" id="dvQuickFilters">
      <div class="dv-chip active" data-all="1">Tất cả</div>
      <div class="dv-chip" data-sport="cầu lông" data-type="CANG_LUOI">Căng lưới cầu lông</div>
      <div class="dv-chip" data-sport="tennis" data-type="CANG_LUOI">Căng lưới tennis</div>
      <div class="dv-chip" data-type="THAY_QUAN_CAN">Thay quấn cán</div>
      <div class="dv-chip" data-type="SUA_VOT">Sửa vợt</div>
      <div class="dv-chip" data-type="HUAN_LUYEN_VIEN">Huấn luyện viên</div>
      <div class="dv-chip" data-open="1">Đang mở cửa</div>
      <div class="dv-chip" data-accepting="1">Đang nhận dịch vụ</div>
    </div>

    <div id="dvGrid" class="dv-grid"></div>
    <div id="dvEmpty" class="dv-empty" style="display:none;">
      <i id="dvEmptyIcon" class="fa-solid fa-store"></i>
      <p id="dvEmptyTitle" style="font-weight:800;color:var(--navy);font-size:16px;margin:0 0 6px;">Chưa có dịch vụ phù hợp</p>
      <p id="dvEmptyMsg" style="margin:0 0 16px;">Các cơ sở đang cập nhật dịch vụ. Hãy thử lại sau hoặc thay đổi bộ lọc tìm kiếm.</p>
      <div style="display:flex; gap:10px; justify-content:center; flex-wrap:wrap;">
        <button type="button" id="dvEmptyClearBtn" class="dv-gps-btn" onclick="clearAllFilters()" style="display:none;">
          <i class="fa-solid fa-filter-circle-xmark"></i> Xóa bộ lọc
        </button>
        <a href="${ctx}/customer/tim-kiem" class="dv-gps-btn" style="text-decoration:none;">
          <i class="fa-solid fa-compass"></i> Khám phá sân
        </a>
      </div>
    </div>
  </div>

  <div id="dvPanelProduct" style="display:none;">
    <div class="dv-search">
      <input type="text" id="spSearchInput" placeholder="Tìm vợt, giày, dây cước, quấn cán..."/>
    </div>

    <div class="dv-quick-filters" id="spQuickFilters">
      <div class="dv-chip active" data-all="1">Tất cả</div>
    </div>

    <div class="sp-section-header">
      <span id="spCountBadge" class="sp-count-badge" style="display:none;"></span>
    </div>

    <div id="spGrid" class="sp-grid"></div>
    <div id="spEmpty" class="dv-empty" style="display:none;">
      <i id="spEmptyIcon" class="fa-solid fa-bag-shopping"></i>
      <p id="spEmptyTitle" style="font-weight:800;color:var(--navy);font-size:16px;margin:0 0 6px;">Chưa có sản phẩm phù hợp</p>
      <p id="spEmptyMsg" style="margin:0 0 16px;">Các cơ sở đang cập nhật sản phẩm. Hãy thử lại sau hoặc thay đổi bộ lọc tìm kiếm.</p>
      <div style="display:flex; gap:10px; justify-content:center; flex-wrap:wrap;">
        <button type="button" id="spEmptyClearBtn" class="dv-gps-btn" onclick="clearProductFilters()" style="display:none;">
          <i class="fa-solid fa-filter-circle-xmark"></i> Xóa bộ lọc
        </button>
        <a href="${ctx}/customer/tim-kiem" class="dv-gps-btn" style="text-decoration:none;">
          <i class="fa-solid fa-compass"></i> Khám phá sân
        </a>
      </div>
    </div>
  </div>
</main>

<div class="dv-drawer-overlay" id="dvOverlay" onclick="closeDetail()"></div>
<div class="dv-drawer" id="dvDrawer">
  <div class="dv-drawer-head">
    <h3 id="dvDetailTitle" style="font-weight:800;font-size:17px;color:var(--navy);margin:0;">Chi tiết dịch vụ</h3>
    <button type="button" onclick="closeDetail()" style="border:none;background:none;font-size:20px;cursor:pointer;color:var(--muted-text);">
      <i class="fa-solid fa-xmark"></i>
    </button>
  </div>
  <div class="dv-drawer-body" id="dvDetailBody"></div>
</div>
<div class="dv-cta-bar" id="dvCtaBar">
  <button type="button" class="dv-cta-btn" id="dvCtaBtn" onclick="goRequestService()">Gửi yêu cầu dịch vụ</button>
</div>

<div class="dv-drawer-overlay" id="dvReqOverlay" onclick="closeRequestForm()"></div>
<div class="dv-drawer" id="dvReqDrawer">
  <div class="dv-drawer-head">
    <h3 style="font-weight:800;font-size:17px;color:var(--navy);margin:0;">Gửi yêu cầu dịch vụ</h3>
    <button type="button" onclick="closeRequestForm()" style="border:none;background:none;font-size:20px;cursor:pointer;color:var(--muted-text);">
      <i class="fa-solid fa-xmark"></i>
    </button>
  </div>
  <form id="dvReqForm" class="dv-drawer-body" style="padding-bottom:110px;" onsubmit="return submitRequestForm(event)">
    <div>
      <label class="dv-field-label">Ngày mang đến *</label>
      <input type="date" id="rq_appointmentDate" required class="dv-input"/>
    </div>
    <div>
      <label class="dv-field-label">Khung giờ mang đến</label>
      <input type="text" id="rq_dropOffTime" placeholder="VD: 08:00-10:00" class="dv-input"/>
    </div>

    <div id="rq_racketBlock" style="display:none; display:flex; flex-direction:column; gap:12px;">
      <div class="dv-grid-2">
        <div><label class="dv-field-label">Loại vợt</label><input type="text" id="rq_racketType" class="dv-input"/></div>
        <div><label class="dv-field-label">Thương hiệu</label><input type="text" id="rq_racketBrand" class="dv-input"/></div>
      </div>
      <div>
        <label class="dv-field-label">Mẫu vợt</label><input type="text" id="rq_racketModel" class="dv-input"/>
      </div>
      <div>
        <label class="dv-field-label" id="rq_tensionLabel">Mức căng *</label>
        <input type="number" step="0.5" id="rq_tensionValue" class="dv-input"/>
      </div>
      <div>
        <label class="dv-field-label">Màu dây (nếu có)</label><input type="text" id="rq_stringColor" class="dv-input"/>
      </div>
      <label style="display:flex; align-items:center; gap:8px; font-size:13.5px; font-weight:700; color:var(--navy);">
        <input type="checkbox" id="rq_customerBringsString" onchange="toggleMaterialSelect()"/> Tôi tự mang dây
      </label>
      <div id="rq_materialBlock">
        <label class="dv-field-label">Chọn loại dây *</label>
        <select id="rq_materialId" class="dv-input"></select>
      </div>
      <div>
        <label class="dv-field-label">Số lượng vợt *</label>
        <input type="number" min="1" id="rq_quantity" value="1" class="dv-input"/>
      </div>
      <div>
        <label class="dv-field-label">Ghi chú kỹ thuật</label>
        <textarea id="rq_technicalNote" rows="2" class="dv-input"></textarea>
      </div>
    </div>

    <div>
      <label class="dv-field-label">Ghi chú cho cơ sở</label>
      <textarea id="rq_customerNote" rows="2" class="dv-input"></textarea>
    </div>

    <div id="rq_priceEstimate" style="background:#f8f9fa; border-radius:var(--radius-medium); padding:12px 14px; font-size:13px; color:var(--body-text);">
      Giá cuối cùng có thể được cơ sở xác nhận lại sau khi kiểm tra tình trạng vợt/dụng cụ.
      Hình thức thanh toán: <b>Thanh toán tại cơ sở</b>.
    </div>

    <div id="rq_error" style="color:#c0392b; font-size:13px; display:none;"></div>
  </form>
  <div class="dv-cta-bar open" style="position:absolute; bottom:0;">
    <button type="submit" form="dvReqForm" class="dv-cta-btn" id="rq_submitBtn">Xác nhận gửi yêu cầu</button>
  </div>
</div>

<div class="dv-drawer-overlay" id="spOverlay" onclick="closeProductDetail()"></div>
<div class="dv-drawer" id="spDrawer">
  <div class="dv-drawer-head">
    <h3 id="spDetailTitle" style="font-weight:800;font-size:17px;color:var(--navy);margin:0;">Chi tiết sản phẩm</h3>
    <button type="button" onclick="closeProductDetail()" style="border:none;background:none;font-size:20px;cursor:pointer;color:var(--muted-text);">
      <i class="fa-solid fa-xmark"></i>
    </button>
  </div>
  <div class="dv-drawer-body" id="spDetailBody"></div>
</div>
<div class="dv-cta-bar" id="spCtaBar">
  <a href="#" id="spCtaBtn" class="dv-cta-btn" style="display:block; text-align:center; text-decoration:none;">Liên hệ cơ sở</a>
</div>

<style>
  .dv-field-label { font-size:12px; font-weight:700; color:var(--body-text); margin-bottom:4px; display:block; }
  .dv-input { width:100%; border:1px solid var(--border); border-radius:10px; padding:9px 11px; font-size:13.5px; outline:none; }
  .dv-input:focus { border-color: var(--primary); }
  .dv-grid-2 { display:grid; grid-template-columns:1fr 1fr; gap:10px; }
  @media (max-width: 430px) {
    .dv-grid-2 { grid-template-columns: 1fr; }
    .dv-drawer-body { padding: 16px; }
    .dv-cta-bar { padding: 12px 16px; }
  }
</style>

<script>
  var ctxPath = '${ctx}';
  var currentFilters = { q: '', serviceType: '', sportType: '', acceptingOnly: false, openOnly: false, lat: null, lng: null };
  var lastResults = [];

  function serviceTypeLabel(t) {
    switch (t) {
      case 'CANG_LUOI': return 'Căng lưới vợt';
      case 'THAY_QUAN_CAN': return 'Thay quấn cán';
      case 'SUA_VOT': return 'Sửa chữa vợt';
      case 'BAO_DUONG': return 'Bảo dưỡng dụng cụ';
      case 'HUAN_LUYEN_VIEN': return 'Huấn luyện viên';
      default: return 'Dịch vụ khác';
    }
  }

  function fmtMoney(v) {
    return Number(v || 0).toLocaleString('vi-VN') + 'đ';
  }

  function buildQuery() {
    var p = new URLSearchParams();
    if (currentFilters.q) p.set('q', currentFilters.q);
    if (currentFilters.serviceType) p.set('serviceType', currentFilters.serviceType);
    if (currentFilters.sportType) p.set('sportType', currentFilters.sportType);
    if (currentFilters.acceptingOnly) p.set('acceptingOnly', '1');
    if (currentFilters.lat != null && currentFilters.lng != null) {
      p.set('lat', currentFilters.lat);
      p.set('lng', currentFilters.lng);
      p.set('radiusKm', '20');
    }
    return p.toString();
  }

  function runSearch() {
    fetch(ctxPath + '/api/customer/dich-vu?' + buildQuery())
      .then(function(r){ return r.json(); })
      .then(function(data){
        if (!data.success) { renderResults([]); return; }
        var results = data.services || [];
        if (currentFilters.openOnly) {
          results = results.filter(function(s){ return s.openNow; });
        }
        lastResults = results;
        renderResults(results);
      })
      .catch(function(){ renderResults([]); });
  }

  function hasActiveFilter() {
    return !!(currentFilters.q || currentFilters.serviceType || currentFilters.sportType
      || currentFilters.acceptingOnly || currentFilters.openOnly
      || (currentFilters.lat != null && currentFilters.lng != null));
  }

  function renderResults(list) {
    var grid = document.getElementById('dvGrid');
    var empty = document.getElementById('dvEmpty');
    grid.innerHTML = '';
    if (!list.length) {
      var filtered = hasActiveFilter();
      document.getElementById('dvEmptyIcon').className = filtered ? 'fa-solid fa-magnifying-glass' : 'fa-solid fa-store';
      document.getElementById('dvEmptyTitle').textContent = filtered
        ? 'Không tìm thấy dịch vụ phù hợp'
        : 'Chưa có dịch vụ phù hợp';
      document.getElementById('dvEmptyMsg').textContent = filtered
        ? 'Không có dịch vụ nào khớp với bộ lọc hiện tại. Thử bỏ bớt bộ lọc hoặc từ khóa khác.'
        : 'Các cơ sở đang cập nhật dịch vụ. Hãy thử lại sau hoặc thay đổi bộ lọc tìm kiếm.';
      document.getElementById('dvEmptyClearBtn').style.display = filtered ? 'inline-flex' : 'none';
      empty.style.display = 'block';
      return;
    }
    empty.style.display = 'none';
    list.forEach(function(s) {
      var card = document.createElement('div');
      card.className = 'dv-card';
      card.onclick = function(){ openDetail(s.serviceId); };
      var img = s.imageUrl ? s.imageUrl : '';
      var statusHtml = s.acceptingRequests
        ? '<span class="dv-status-badge dv-status-open">Đang nhận</span>'
        : '<span class="dv-status-badge dv-status-paused">Tạm dừng</span>';
      var distanceHtml = (s.distanceKm != null) ? ('<span><i class="fa-solid fa-route"></i> ' + s.distanceKm + ' km</span>') : '';
      card.innerHTML =
        '<div class="dv-card-img">' + (img ? '<img src="' + img + '" alt="">' : '') + statusHtml + '</div>' +
        '<div class="dv-card-body">' +
          '<h3>' + escapeHtml(s.serviceName) + '</h3>' +
          '<p class="dv-card-facility"><i class="fa-solid fa-location-dot"></i> ' + escapeHtml(s.coSoName) + '</p>' +
          '<div class="dv-card-meta">' +
            '<span>' + serviceTypeLabel(s.serviceType) + (s.sportType ? (' · ' + escapeHtml(s.sportType)) : '') + '</span>' +
            distanceHtml +
          '</div>' +
          '<div class="dv-card-meta" style="margin-top:6px;">' +
            '<span class="dv-price">Từ ' + fmtMoney(s.basePrice) + '</span>' +
            '<span>~' + s.estimatedMinutes + ' phút</span>' +
          '</div>' +
        '</div>';
      grid.appendChild(card);
    });
  }

  function escapeHtml(str) {
    if (!str) return '';
    var d = document.createElement('div');
    d.textContent = str;
    return d.innerHTML;
  }

  function openDetail(serviceId) {
    fetch(ctxPath + '/api/customer/dich-vu?action=detail&serviceId=' + serviceId)
      .then(function(r){ return r.json(); })
      .then(function(data){
        if (!data.success) { alert(data.message || 'Không tải được chi tiết dịch vụ.'); return; }
        renderDetail(data.service);
        document.getElementById('dvOverlay').classList.add('open');
        document.getElementById('dvDrawer').classList.add('open');
        document.getElementById('dvCtaBar').classList.add('open');
      });
  }

  var currentDetail = null;

  function renderDetail(s) {
    currentDetail = s;
    document.getElementById('dvDetailTitle').textContent = s.serviceName;
    var rows = '';
    rows += row('Cơ sở', s.coSoName);
    rows += row('Địa chỉ', s.coSoAddress);
    if (s.gioMoCua && s.gioDongCua) rows += row('Giờ mở cửa', s.gioMoCua + ' - ' + s.gioDongCua);
    rows += row('Môn thể thao', s.sportType || '—');
    rows += row('Giá cơ bản', fmtMoney(s.basePrice) + (s.unit ? ('/' + s.unit) : ''));
    rows += row('Thời gian thực hiện', '~' + s.estimatedMinutes + ' phút');
    rows += row('Trạng thái', s.acceptingRequests ? 'Đang nhận yêu cầu' : 'Tạm dừng nhận yêu cầu');
    if (s.description) rows += row('Mô tả', s.description);
    if (s.policy) rows += row('Chính sách', s.policy);

    if (s.racketConfig) {
      var rc = s.racketConfig;
      rows += '<div style="font-weight:800;color:var(--navy);margin-top:10px;font-size:13px;">Chi tiết căng lưới</div>';
      if (rc.racketTypes) rows += row('Loại vợt nhận', rc.racketTypes);
      rows += row('Giá công căng', fmtMoney(rc.stringingPrice));
      rows += row('Mức căng hỗ trợ', rc.minTension + ' - ' + rc.maxTension + ' ' + rc.tensionUnit);
      rows += row('Nhận dây khách mang', rc.allowCustomerString ? 'Có' : 'Không');
      if (rc.oldRacketPolicy) rows += row('Chính sách vợt cũ/hư hỏng', rc.oldRacketPolicy);
      if (rc.stringBreakPolicy) rows += row('Chính sách dây đứt', rc.stringBreakPolicy);
      if (s.materials && s.materials.length) {
        var names = s.materials.map(function(m){ return m.name + ' (' + fmtMoney(m.price) + ')'; }).join(', ');
        rows += row('Loại dây có thể chọn', names);
      }
    }

    document.getElementById('dvDetailBody').innerHTML = rows;

    var ctaBtn = document.getElementById('dvCtaBtn');
    if (s.acceptingRequests) {
      ctaBtn.disabled = false;
      ctaBtn.textContent = 'Gửi yêu cầu dịch vụ';
      ctaBtn.dataset.serviceId = s.serviceId;
    } else {
      ctaBtn.disabled = true;
      ctaBtn.textContent = 'Dịch vụ tạm dừng nhận yêu cầu';
    }
  }

  function row(label, value) {
    return '<div class="dv-drawer-row"><span>' + label + '</span><span>' + escapeHtml(String(value)) + '</span></div>';
  }

  function closeDetail() {
    document.getElementById('dvOverlay').classList.remove('open');
    document.getElementById('dvDrawer').classList.remove('open');
    document.getElementById('dvCtaBar').classList.remove('open');
  }

  function goRequestService() {
    if (!currentDetail) return;
    var form = document.getElementById('dvReqForm');
    form.reset();
    document.getElementById('rq_error').style.display = 'none';

    var todayStr = new Date().toISOString().slice(0, 10);
    document.getElementById('rq_appointmentDate').min = todayStr;
    document.getElementById('rq_appointmentDate').value = todayStr;

    var isRacket = !!currentDetail.racketConfig;
    document.getElementById('rq_racketBlock').style.display = isRacket ? 'flex' : 'none';

    if (isRacket) {
      var rc = currentDetail.racketConfig;
      document.getElementById('rq_tensionLabel').textContent =
        'Mức căng * (' + rc.minTension + ' - ' + rc.maxTension + ' ' + rc.tensionUnit + ')';
      document.getElementById('rq_tensionValue').min = rc.minTension;
      document.getElementById('rq_tensionValue').max = rc.maxTension;
      document.getElementById('rq_tensionValue').required = true;

      var sel = document.getElementById('rq_materialId');
      sel.innerHTML = '';
      (currentDetail.materials || []).forEach(function(m) {
        var opt = document.createElement('option');
        opt.value = m.materialId;
        opt.textContent = m.name + (m.brand ? (' - ' + m.brand) : '') + ' (' + fmtMoney(m.price + m.extraFee) + ')';
        sel.appendChild(opt);
      });
      document.getElementById('rq_customerBringsString').checked = false;
      toggleMaterialSelect();
      if (!rc.allowCustomerString) {
        document.getElementById('rq_customerBringsString').closest('label').style.display = 'none';
      }
    }

    document.getElementById('dvReqOverlay').classList.add('open');
    document.getElementById('dvReqDrawer').classList.add('open');
  }

  function toggleMaterialSelect() {
    var brings = document.getElementById('rq_customerBringsString').checked;
    document.getElementById('rq_materialBlock').style.display = brings ? 'none' : 'block';
  }

  function closeRequestForm() {
    document.getElementById('dvReqOverlay').classList.remove('open');
    document.getElementById('dvReqDrawer').classList.remove('open');
  }

  function submitRequestForm(evt) {
    evt.preventDefault();
    var errBox = document.getElementById('rq_error');
    errBox.style.display = 'none';

    var p = new URLSearchParams();
    p.set('serviceId', currentDetail.serviceId);
    p.set('appointmentDate', document.getElementById('rq_appointmentDate').value);
    p.set('dropOffTime', document.getElementById('rq_dropOffTime').value);
    p.set('customerNote', document.getElementById('rq_customerNote').value);

    if (currentDetail.racketConfig) {
      p.set('racketType', document.getElementById('rq_racketType').value);
      p.set('racketBrand', document.getElementById('rq_racketBrand').value);
      p.set('racketModel', document.getElementById('rq_racketModel').value);
      p.set('tensionValue', document.getElementById('rq_tensionValue').value);
      p.set('tensionUnit', currentDetail.racketConfig.tensionUnit);
      p.set('stringColor', document.getElementById('rq_stringColor').value);
      p.set('quantity', document.getElementById('rq_quantity').value || '1');
      p.set('technicalNote', document.getElementById('rq_technicalNote').value);
      var brings = document.getElementById('rq_customerBringsString').checked;
      p.set('customerBringsString', brings ? '1' : '0');
      if (!brings) p.set('materialId', document.getElementById('rq_materialId').value);
    }

    var btn = document.getElementById('rq_submitBtn');
    btn.disabled = true;
    btn.textContent = 'Đang gửi...';

    fetch(ctxPath + '/api/customer/dich-vu/dat', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: p.toString()
    })
      .then(function(r){ return r.json(); })
      .then(function(data){
        btn.disabled = false;
        btn.textContent = 'Xác nhận gửi yêu cầu';
        if (data.success) {
          closeRequestForm();
          closeDetail();
          alert('Đã gửi yêu cầu dịch vụ #' + data.orderId + '. Giá dự kiến: ' + fmtMoney(data.estimatedPrice) + '. Bạn có thể theo dõi trạng thái trong "Đơn dịch vụ của tôi".');
        } else {
          errBox.textContent = data.message || 'Không thể gửi yêu cầu.';
          errBox.style.display = 'block';
        }
      })
      .catch(function(){
        btn.disabled = false;
        btn.textContent = 'Xác nhận gửi yêu cầu';
        errBox.textContent = 'Lỗi kết nối. Vui lòng thử lại.';
        errBox.style.display = 'block';
      });
    return false;
  }

  function useMyLocation() {
    if (!navigator.geolocation) {
      alert('Trình duyệt không hỗ trợ định vị GPS.');
      return;
    }
    var btn = document.getElementById('dvGpsBtn');
    btn.classList.add('is-active');
    navigator.geolocation.getCurrentPosition(
      function(pos) {
        currentFilters.lat = pos.coords.latitude;
        currentFilters.lng = pos.coords.longitude;
        runSearch();
      },
      function() {
        btn.classList.remove('is-active');
        alert('Không thể lấy vị trí của bạn. Vui lòng thử lại hoặc tìm theo từ khóa.');
      }
    );
  }

  document.getElementById('dvSearchInput').addEventListener('input', function(e) {
    currentFilters.q = e.target.value;
    clearTimeout(window._dvSearchDebounce);
    window._dvSearchDebounce = setTimeout(runSearch, 300);
  });

  function syncAllChip() {
    // "Tất cả" active khi không có chip chuyên biệt nào được chọn.
    var allChip = document.querySelector('.dv-chip[data-all]');
    var anySpecific = false;
    document.querySelectorAll('.dv-chip:not([data-all])').forEach(function(c){
      if (c.classList.contains('active')) anySpecific = true;
    });
    if (allChip) allChip.classList.toggle('active', !anySpecific);
  }

  function clearAllFilters() {
    document.querySelectorAll('.dv-chip').forEach(function(c){ c.classList.remove('active'); });
    currentFilters.serviceType = '';
    currentFilters.sportType = '';
    currentFilters.acceptingOnly = false;
    currentFilters.openOnly = false;
    syncAllChip();
    runSearch();
  }

  document.querySelectorAll('.dv-chip').forEach(function(chip) {
    chip.addEventListener('click', function() {
      if (chip.dataset.all) { clearAllFilters(); return; }
      var isActive = chip.classList.contains('active');
      document.querySelectorAll('.dv-chip:not([data-all])').forEach(function(c){ c.classList.remove('active'); });
      currentFilters.serviceType = '';
      currentFilters.sportType = '';
      currentFilters.acceptingOnly = false;
      currentFilters.openOnly = false;
      if (!isActive) {
        chip.classList.add('active');
        if (chip.dataset.type) currentFilters.serviceType = chip.dataset.type;
        if (chip.dataset.sport) currentFilters.sportType = chip.dataset.sport;
        if (chip.dataset.accepting) currentFilters.acceptingOnly = true;
        if (chip.dataset.open) currentFilters.openOnly = true;
      }
      syncAllChip();
      runSearch();
    });
  });

  document.addEventListener('keydown', function(e) { if (e.key === 'Escape') { closeRequestForm(); closeDetail(); closeProductDetail(); } });

  // ═══════════ Tab Sản phẩm (lazy-load, giữ trạng thái qua URL ?tab=) ═══════════
  var productFilters = { q: '', categoryId: '', lat: null, lng: null };
  var productLoaded = false;
  var serviceLoaded = false;

  function hasActiveProductFilter() {
    return !!(productFilters.q || productFilters.categoryId);
  }

  function buildProductQuery() {
    var p = new URLSearchParams();
    if (productFilters.q) p.set('q', productFilters.q);
    if (productFilters.categoryId) p.set('categoryId', productFilters.categoryId);
    if (productFilters.lat != null && productFilters.lng != null) {
      p.set('lat', productFilters.lat);
      p.set('lng', productFilters.lng);
      p.set('radiusKm', '20');
    }
    return p.toString();
  }

  function runProductSearch() {
    fetch(ctxPath + '/api/customer/san-pham?' + buildProductQuery())
      .then(function(r){ return r.json(); })
      .then(function(data){
        if (!data.success) { renderProductResults([]); return; }
        renderProductResults(data.products || []);
      })
      .catch(function(){ renderProductResults([]); });
  }

  function stockLabel(status) {
    switch (status) {
      case 'CON_HANG': return { text: 'Còn hàng', cls: 'dv-status-open' };
      case 'SAP_HET': return { text: 'Sắp hết', cls: 'dv-status-lowstock' };
      default: return { text: 'Hết hàng', cls: 'dv-status-outofstock' };
    }
  }

  function stockBadgeCls(status) {
    if (status === 'CON_HANG') return 'sp-stock-in';
    if (status === 'SAP_HET') return 'sp-stock-low';
    return 'sp-stock-out';
  }

  function renderProductResults(list) {
    var grid = document.getElementById('spGrid');
    var empty = document.getElementById('spEmpty');
    var countBadge = document.getElementById('spCountBadge');
    grid.innerHTML = '';
    if (!list.length) {
      countBadge.style.display = 'none';
      var filtered = hasActiveProductFilter();
      document.getElementById('spEmptyIcon').className = filtered ? 'fa-solid fa-magnifying-glass' : 'fa-solid fa-bag-shopping';
      document.getElementById('spEmptyTitle').textContent = filtered
        ? 'Không tìm thấy sản phẩm phù hợp'
        : 'Chưa có sản phẩm phù hợp';
      document.getElementById('spEmptyMsg').textContent = filtered
        ? 'Không có sản phẩm nào khớp với bộ lọc hiện tại. Thử bỏ bớt bộ lọc hoặc từ khóa khác.'
        : 'Các cơ sở đang cập nhật sản phẩm. Hãy thử lại sau hoặc thay đổi bộ lọc tìm kiếm.';
      document.getElementById('spEmptyClearBtn').style.display = filtered ? 'inline-flex' : 'none';
      empty.style.display = 'block';
      return;
    }
    empty.style.display = 'none';
    countBadge.textContent = list.length + ' sản phẩm';
    countBadge.style.display = 'inline-block';

    list.forEach(function(p) {
      var card = document.createElement('div');
      card.className = 'sp-card';
      card.onclick = function(){ openProductDetail(p.productId); };

      var img = p.image ? (ctxPath + p.image) : '';
      var stock = stockLabel(p.stockStatus);
      var badgeCls = stockBadgeCls(p.stockStatus);
      var isOut = p.stockStatus === 'HET_HANG';

      var imgInner = img
        ? '<img src="' + img + '" alt="' + escapeHtml(p.name) + '" loading="lazy">'
        : '<div class="sp-img-placeholder"><i class="fa-solid fa-shirt"></i><span>Chưa có ảnh</span></div>';

      var priceHtml = '<span class="sp-price">' + fmtMoney(p.price) + '</span>'
        + (p.unit ? '<span class="sp-price-unit">/' + escapeHtml(p.unit) + '</span>' : '');

      var btnHtml = '<button class="sp-buy-btn" ' + (isOut ? 'disabled' : '') + '>'
        + (isOut ? 'Hết hàng' : 'Xem chi tiết') + '</button>';

      card.innerHTML =
        '<div class="sp-img-wrap">' + imgInner
          + '<span class="sp-stock-badge ' + badgeCls + '">' + stock.text + '</span>'
        + '</div>'
        + '<div class="sp-card-body">'
          + '<p class="sp-card-name">' + escapeHtml(p.name) + '</p>'
          + (p.category ? '<p class="sp-card-cat">' + escapeHtml(p.category) + '</p>' : '')
          + '<p class="sp-card-loc"><i class="fa-solid fa-location-dot"></i> ' + escapeHtml(p.coSoName) + '</p>'
          + '<div class="sp-card-footer">'
            + '<div>' + priceHtml + '</div>'
            + btnHtml
          + '</div>'
        + '</div>';

      grid.appendChild(card);
    });
  }

  function openProductDetail(productId) {
    fetch(ctxPath + '/api/customer/san-pham?action=detail&productId=' + productId)
      .then(function(r){ return r.json(); })
      .then(function(data){
        if (!data.success) { alert(data.message || 'Không tải được chi tiết sản phẩm.'); return; }
        renderProductDetail(data.product);
        document.getElementById('spOverlay').classList.add('open');
        document.getElementById('spDrawer').classList.add('open');
        document.getElementById('spCtaBar').classList.add('open');
      });
  }

  function renderProductDetail(p) {
    document.getElementById('spDetailTitle').textContent = p.name;
    var rows = '';
    rows += row('Cơ sở', p.coSoName);
    rows += row('Địa chỉ', p.coSoAddress);
    if (p.gioMoCua && p.gioDongCua) rows += row('Giờ mở cửa', p.gioMoCua + ' - ' + p.gioDongCua);
    rows += row('Danh mục', p.category || '—');
    rows += row('Giá', fmtMoney(p.price) + (p.unit ? ('/' + p.unit) : ''));
    var stock = stockLabel(p.stockStatus);
    rows += row('Tình trạng', stock.text);
    if (p.description) rows += row('Mô tả', p.description);
    document.getElementById('spDetailBody').innerHTML = rows;

    var ctaBtn = document.getElementById('spCtaBtn');
    if (p.coSoPhone) {
      ctaBtn.href = 'tel:' + p.coSoPhone;
      ctaBtn.textContent = 'Liên hệ cơ sở: ' + p.coSoPhone;
    } else {
      ctaBtn.href = ctxPath + '/customer/tim-kiem';
      ctaBtn.textContent = 'Xem cơ sở';
    }
  }

  function closeProductDetail() {
    document.getElementById('spOverlay').classList.remove('open');
    document.getElementById('spDrawer').classList.remove('open');
    document.getElementById('spCtaBar').classList.remove('open');
  }

  function clearProductFilters() {
    document.querySelectorAll('#spQuickFilters .dv-chip').forEach(function(c){ c.classList.remove('active'); });
    document.querySelector('#spQuickFilters .dv-chip[data-all]').classList.add('active');
    productFilters.categoryId = '';
    runProductSearch();
  }

  document.getElementById('spSearchInput').addEventListener('input', function(e) {
    productFilters.q = e.target.value;
    clearTimeout(window._spSearchDebounce);
    window._spSearchDebounce = setTimeout(runProductSearch, 300);
  });

  // ═══════════ Tab switching, giữ trạng thái qua URL (?tab=dich-vu|san-pham) ═══════════
  function switchTab(tab, updateUrl) {
    var isProduct = tab === 'san-pham';
    document.querySelectorAll('.dv-tab').forEach(function(t){
      t.classList.toggle('active', t.dataset.tab === tab);
    });
    document.getElementById('dvPanelService').style.display = isProduct ? 'none' : 'block';
    document.getElementById('dvPanelProduct').style.display = isProduct ? 'block' : 'none';

    if (updateUrl !== false) {
      var url = new URL(window.location.href);
      url.searchParams.set('tab', tab);
      window.history.pushState({ tab: tab }, '', url);
    }

    if (isProduct && !productLoaded) {
      productLoaded = true;
      runProductSearch();
    } else if (!isProduct && !serviceLoaded) {
      serviceLoaded = true;
      runSearch();
    }
  }

  document.querySelectorAll('.dv-tab').forEach(function(btn) {
    btn.addEventListener('click', function() { switchTab(btn.dataset.tab, true); });
  });

  window.addEventListener('popstate', function(e) {
    var tab = (e.state && e.state.tab) || new URLSearchParams(window.location.search).get('tab') || 'dich-vu';
    switchTab(tab, false);
  });

  var initialTab = new URLSearchParams(window.location.search).get('tab') === 'san-pham' ? 'san-pham' : 'dich-vu';
  switchTab(initialTab, false);
</script>

<jsp:include page="/common/footer.jsp" />
</body>
</html>
