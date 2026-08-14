<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="org.example.model.TaiKhoan" %>
<style>
/* Active nav state — high-specificity override to ensure it wins on all pages */
.vs-header .vs-nav__link.is-active,
.vs-header .vs-nav__link.is-active:visited {
  color: #287A58 !important;
  font-weight: 700;
}
.vs-header .vs-nav__link.is-active::after {
  transform: scaleX(1) !important;
  background: #287A58;
}
.vs-header .vs-nav__link:hover {
  color: #287A58 !important;
}
.vs-header .vs-nav__link:hover::after {
  transform: scaleX(1) !important;
}
</style>
<%
    String vsNavPath = request.getRequestURI().substring(request.getContextPath().length());
    boolean vsNavBanDo   = vsNavPath.startsWith("/customer/BanDo.jsp") || vsNavPath.startsWith("/customer/ban-do");
    boolean vsNavDatSan  = vsNavPath.startsWith("/customer/dat-san") || vsNavPath.startsWith("/customer/tim-kiem")
                        || vsNavPath.startsWith("/customer/chi-tiet-san") || vsNavPath.startsWith("/customer/lich-su-dat-san");
    boolean vsNavUuDai   = vsNavPath.startsWith("/customer/uu-dai");
    boolean vsNavGhepKeo = vsNavPath.startsWith("/customer/ghep-keo");

    boolean vsNavHome    = vsNavPath.equals("") || vsNavPath.equals("/") || vsNavPath.startsWith("/index.jsp");
    TaiKhoan user = (TaiKhoan) session.getAttribute("user");
    String vsAuthHref;
    boolean vsIsHome = vsNavHome;
    if (vsIsHome) {
        vsAuthHref = "#auth";
    } else {
        String currentPath = request.getRequestURI()
            + (request.getQueryString() != null ? "?" + request.getQueryString() : "");
        vsAuthHref = request.getContextPath() + "/index.jsp?auth=login&redirect="
            + java.net.URLEncoder.encode(currentPath, java.nio.charset.StandardCharsets.UTF_8);
    }
%>

<!-- ══ NEW WHITE STICKY HEADER ══════════════════════════════ -->
<div class="vs-header-wrap">
  <header class="vs-header">

    <!-- Logo -->
    <a href="${pageContext.request.contextPath}/" class="vs-header__logo">
      <i class="fa-solid fa-volleyball"></i>V-<span>SPORT</span>
    </a>

    <!-- Desktop nav -->
    <nav class="vs-header__nav" aria-label="Điều hướng chính">
      <ul class="vs-nav__list">
        <li class="vs-nav__item">
          <a href="${pageContext.request.contextPath}/"
             class="vs-nav__link <%= vsNavHome ? "is-active" : "" %>">
            <i class="fas fa-home" style="font-size:13px;"></i>Trang chủ
          </a>
        </li>
        <li class="vs-nav__item">
          <a href="${pageContext.request.contextPath}/customer/BanDo.jsp"
             class="vs-nav__link <%= vsNavBanDo ? "is-active" : "" %>">
            <i class="fas fa-map-marked-alt" style="font-size:13px;"></i>Bản đồ
          </a>
        </li>
        <li class="vs-nav__item">
          <a href="${pageContext.request.contextPath}/customer/dat-san"
             class="vs-nav__link <%= vsNavDatSan ? "is-active" : "" %>">Đặt sân</a>
        </li>
        <li class="vs-nav__item">
          <a href="${pageContext.request.contextPath}/customer/uu-dai"
             class="vs-nav__link <%= vsNavUuDai ? "is-active" : "" %>">
            <i class="fas fa-ticket" style="font-size:11px;"></i>Ưu đãi
          </a>
        </li>
        <li class="vs-nav__item">
          <a href="${pageContext.request.contextPath}/customer/ghep-keo"
             class="vs-nav__link <%= vsNavGhepKeo ? "is-active" : "" %>">
            Ghép Kèo&nbsp;<span class="vs-nav__badge">HOT</span>
          </a>
        </li>

        <li class="vs-nav__item">
          <a href="#" class="vs-nav__link">
            Tin tức <i class="fas fa-angle-down vs-nav__chevron"></i>
          </a>
        </li>
      </ul>
    </nav>

    <!-- Actions -->
    <div class="vs-header__actions">

      <!-- Search -->
      <button type="button" class="vs-hdr-icon vs-hdr-search" id="vsMobileSearchBtn" aria-label="Tìm kiếm">
        <i class="fas fa-search"></i>
      </button>

      <!-- Cart -->
      <a href="${pageContext.request.contextPath}/customer/gio-hang" class="vs-hdr-icon vs-hdr-cart" aria-label="Giỏ hàng">
        <i class="fas fa-shopping-basket"></i>
        <span class="vs-badge" id="header-cart-badge" style="opacity:0;">0</span>
      </a>

      <% if (user != null) { %>

      <!-- Notification bell -->
      <div class="vs-hdr-notif-wrap vs-notif-wrap" id="vsNotifWrap">
        <button type="button" class="vs-hdr-icon vs-notif-btn" id="vsNotifBtn"
                aria-label="Thông báo" aria-expanded="false" aria-controls="vsNotifDropdown">
          <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
               stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
            <path d="M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9"/>
            <path d="M10.3 21a1.94 1.94 0 0 0 3.4 0"/>
          </svg>
          <span class="vs-notif-badge" id="vsNotifBadge" style="opacity:0;transition:opacity .2s;"></span>
        </button>
        <div class="vs-notif-dropdown" id="vsNotifDropdown" role="dialog" aria-label="Thông báo" hidden>
          <div class="vs-notif-head">
            <span class="vs-notif-head-title">Thông báo</span>
            <button type="button" class="vs-notif-clear" id="vsNotifClear">Đọc tất cả</button>
          </div>
          <ul class="vs-notif-list" id="vsNotifList" role="list">
            <li class="vs-notif-empty" id="vsNotifEmpty">Chưa có thông báo mới</li>
          </ul>
          <div class="vs-notif-foot">
            <a href="${pageContext.request.contextPath}/customer/thong-bao" class="vs-notif-foot-link">
              Xem tất cả thông báo
            </a>
          </div>
        </div>
      </div>

      <!-- User dropdown -->
      <div class="vs-hdr-user-wrap vs-user-wrap" id="vsUserWrap">
        <button type="button" class="vs-hdr-icon vs-user-btn" id="vsUserBtn"
                aria-haspopup="true" aria-expanded="false" aria-controls="vsUserDropdown"
                style="width:auto;padding:0 10px 0 4px;border-radius:999px;gap:7px;">
          <span class="vs-user-avatar" id="vsUserAvatar"><i class="fas fa-user"></i></span>
          <span class="vs-user-name" id="vsUserName"><%= user.getFullName() %></span>
          <i class="fas fa-chevron-down vs-user-chevron" id="vsUserChevron"></i>
        </button>
        <div class="vs-user-dropdown" id="vsUserDropdown" role="menu" hidden>
          <!-- Account header -->
          <div class="vs-user-dd-header">
            <div class="vs-user-dd-avatar" id="vsUserDdAvatar"><i class="fas fa-user"></i></div>
            <div class="vs-user-dd-info">
              <div class="vs-user-dd-name"><%= user.getFullName() %></div>
              <div class="vs-user-dd-email"><%= user.getEmail() != null ? user.getEmail() : "" %></div>
            </div>
          </div>
          <div class="vs-user-dropdown-divider"></div>
          <!-- Account management -->
          <a href="${pageContext.request.contextPath}/customer/tai-khoan" role="menuitem">
            <i class="fas fa-id-card"></i>Thông tin cá nhân
          </a>
          <div class="vs-user-dropdown-divider"></div>
          <a href="${pageContext.request.contextPath}/customer/lich-su-dat-san" role="menuitem">
            <i class="fas fa-history"></i>Lịch sử đặt sân
          </a>
          <a href="${pageContext.request.contextPath}/customer/gio-hang?tab=refund" role="menuitem">
            <i class="fas fa-hand-holding-usd"></i>Yêu cầu hoàn tiền
          </a>
          <div class="vs-user-dropdown-divider"></div>
          <a href="${pageContext.request.contextPath}/logout" role="menuitem" class="vs-user-dd-logout">
            <i class="fas fa-sign-out-alt"></i>Đăng xuất
          </a>
        </div>
      </div>

      <% } else { %>

      <!-- Auth button (guest) -->
      <a href="<%= vsAuthHref %>" class="vs-hdr-icon" id="authBtn" aria-label="Đăng nhập">
        <i class="far fa-user"></i>
      </a>

      <% } %>

      <!-- Book CTA — always shown -->
      <a href="${pageContext.request.contextPath}/customer/dat-san" class="vs-header__cta">
        <i class="fas fa-calendar-plus"></i>Đặt sân
      </a>

      <!-- Hamburger (mobile) -->
      <button type="button" class="vs-hamburger" id="vsMobileMenuBtn"
              aria-label="Mở menu điều hướng" aria-expanded="false" aria-controls="vsMobileNavDrawer">
        <span></span><span></span><span></span>
      </button>

    </div><!-- /vs-header__actions -->
  </header>
</div><!-- /vs-header-wrap -->

<!-- Mobile search overlay -->
<div class="vs-mob-search" id="vsMobileSearchOverlay">
  <div class="vs-mob-search__inner">
    <form action="${pageContext.request.contextPath}/customer/tim-kiem" method="GET" class="vs-mob-search__form">
      <input type="text" name="q" placeholder="Tìm tên sân, cơ sở, địa chỉ..."
             value="${not empty query ? query : ''}" autocomplete="off">
      <button type="submit" aria-label="Tìm kiếm"><i class="fas fa-search"></i></button>
    </form>
    <button type="button" class="vs-mob-search__close" id="vsMobileSearchClose" aria-label="Đóng tìm kiếm">
      <i class="fas fa-times"></i>
    </button>
  </div>
</div>

<!-- Mobile nav overlay -->
<div class="vs-mob-overlay" id="vsMobileNavOverlay"></div>

<!-- Mobile nav drawer -->
<nav class="vs-mob-drawer" id="vsMobileNavDrawer"
     aria-label="Menu điều hướng di động" aria-hidden="true">
  <div class="vs-mob-drawer__head">
    <a href="${pageContext.request.contextPath}/" class="vs-mob-drawer__logo">
      <i class="fa-solid fa-volleyball"></i>V-<span>SPORT</span>
    </a>
    <button type="button" class="vs-mob-drawer__close" id="vsMobileNavClose" aria-label="Đóng menu">
      <i class="fas fa-times"></i>
    </button>
  </div>
  <ul class="vs-mob-nav">
    <li><a href="${pageContext.request.contextPath}/"><i class="fas fa-home"></i>Trang chủ</a></li>
    <li>
      <a href="${pageContext.request.contextPath}/customer/BanDo.jsp"
         class="<%= vsNavBanDo ? "is-active" : "" %>">
        <i class="fas fa-map-marked-alt"></i>Bản đồ
      </a>
    </li>
    <li>
      <a href="${pageContext.request.contextPath}/customer/dat-san"
         class="<%= vsNavDatSan ? "is-active" : "" %>">
        <i class="fas fa-calendar-check"></i>Đặt sân
      </a>
    </li>
    <li>
      <a href="${pageContext.request.contextPath}/customer/uu-dai"
         class="<%= vsNavUuDai ? "is-active" : "" %>">
        <i class="fas fa-ticket"></i>Ưu đãi
      </a>
    </li>
    <li>
      <a href="${pageContext.request.contextPath}/customer/ghep-keo"
         class="<%= vsNavGhepKeo ? "is-active" : "" %>">
        <i class="fas fa-users"></i>Ghép Kèo
      </a>
    </li>

    <li><a href="#"><i class="fas fa-newspaper"></i>Tin tức</a></li>
    <% if (user != null) { %>
    <li>
      <a href="${pageContext.request.contextPath}/customer/tai-khoan">
        <i class="fas fa-user"></i>Tài khoản
      </a>
    </li>
    <li>
      <a href="${pageContext.request.contextPath}/logout">
        <i class="fas fa-sign-out-alt"></i>Đăng xuất
      </a>
    </li>
    <% } else { %>
    <li>
      <a href="<%= vsAuthHref %>" id="vsMobileAuthBtn">
        <i class="fas fa-sign-in-alt"></i>Đăng nhập / Đăng ký
      </a>
    </li>
    <% } %>
  </ul>
  <div class="vs-mob-drawer__foot">
    <a href="${pageContext.request.contextPath}/customer/dat-san">
      <i class="fas fa-calendar-plus"></i>&nbsp;Đặt sân ngay
    </a>
  </div>
</nav>

<style>
/* ---- Notification bell (header-xtra, kept unchanged) ---- */
.vs-notif-wrap{position:relative;display:inline-flex;align-items:center;overflow:visible!important;}
.vs-notif-btn{position:relative;border:none!important;outline:none!important;background:transparent!important;box-shadow:none!important;cursor:pointer;color:#FCFAF4;font-size:20px;width:40px;height:40px;border-radius:50%;display:flex;align-items:center;justify-content:center;padding:0;transition:background .2s;overflow:visible!important;}
.vs-notif-btn:hover{background:rgba(252,250,244,.1)!important;}
.vs-notif-btn:focus{outline:none!important;box-shadow:none!important;}
.vs-notif-badge{position:absolute!important;top:2px!important;right:2px!important;z-index:10!important;min-width:16px!important;height:16px!important;padding:0 4px!important;border-radius:999px!important;background:#E5484D!important;color:#fff!important;font-size:9.5px!important;font-weight:800!important;display:inline-flex!important;align-items:center!important;justify-content:center!important;pointer-events:none!important;line-height:1!important;box-shadow:0 0 0 2px var(--vs-surface,#fff)!important;white-space:nowrap!important;}
.vs-notif-dropdown{position:absolute;top:calc(100% + 10px);right:0;z-index:2000;width:360px;max-width:min(360px,calc(100vw - 24px));max-height:calc(100vh - 100px);background:#fff;border-radius:16px;box-shadow:0 12px 40px rgba(7,26,47,.18),0 2px 8px rgba(7,26,47,.1);border:1px solid #DCE5EF;display:flex;flex-direction:column;overflow:hidden;animation:vsNotifFadeIn .18s ease;}
.vs-notif-dropdown[hidden]{display:none!important;}
@keyframes vsNotifFadeIn{from{opacity:0;transform:translateY(-8px) scale(.97)}to{opacity:1;transform:translateY(0) scale(1)}}
.vs-notif-head{display:flex;align-items:center;justify-content:space-between;padding:14px 16px 10px;border-bottom:1px solid #EEF2F6;flex-shrink:0;background:#fff;}
.vs-notif-head-title{font-size:14px;font-weight:800;color:#122d40;}
.vs-notif-clear{background:none;border:none;font-size:12px;font-weight:700;color:#287A58;cursor:pointer;padding:4px 8px;border-radius:6px;transition:background .12s;}
.vs-notif-clear:hover{background:#EFFDF6;}
.vs-notif-list{list-style:none;margin:0;padding:0;max-height:380px;overflow-y:auto;flex:1;}
.vs-notif-foot{padding:10px 16px;border-top:1px solid #EEF2F6;text-align:center;background:#FAFCFE;flex-shrink:0;}
.vs-notif-foot-link{font-size:12.5px;font-weight:700;color:#287A58;text-decoration:none;}
.vs-notif-foot-link:hover{text-decoration:underline;}
.vs-notif-empty{padding:28px 16px;text-align:center;font-size:13px;color:#829AB1;}
.vs-notif-item{display:flex;align-items:flex-start;gap:11px;padding:12px 16px;border-bottom:1px solid #F1F5F9;cursor:default;transition:background .12s;position:relative;}
.vs-notif-item:last-child{border-bottom:none;}
.vs-notif-item:hover{background:#F8FAFB;}
.vs-notif-item.is-unread{background:#F0FDF8;}
.vs-notif-item.is-unread:hover{background:#E4FAF2;}
.vs-notif-item.is-unread::before{content:'';position:absolute;left:0;top:0;bottom:0;width:3px;background:#287A58;border-radius:0 2px 2px 0;}
.vs-notif-avatar{width:36px;height:36px;flex-shrink:0;border-radius:50%;background:linear-gradient(135deg,#287A58,#3db57a);color:#fff;display:inline-flex;align-items:center;justify-content:center;font-size:12px;font-weight:800;}
.vs-notif-body{min-width:0;flex:1;}
.vs-notif-text{font-size:13px;font-weight:600;color:#102A43;line-height:1.45;margin:0 0 3px;}
.vs-notif-text strong{color:#287A58;}
.vs-notif-time{font-size:11.5px;color:#829AB1;font-weight:600;}
.vs-notif-view{display:inline-flex;align-items:center;gap:4px;font-size:11.5px;font-weight:700;color:#287A58;background:none;border:none;cursor:pointer;padding:2px 0;text-decoration:none;margin-top:4px;}
.vs-notif-view:hover{text-decoration:underline;}
/* User dropdown */
.vs-user-wrap{position:relative;}
.vs-user-btn{cursor:pointer;border:none!important;outline:none!important;font-family:inherit;appearance:none;-webkit-appearance:none;background:transparent!important;transition:background .15s;}
.vs-user-btn:hover{background:rgba(252,250,244,.1)!important;}
.vs-user-btn[aria-expanded="true"]{background:rgba(252,250,244,.1)!important;}
.vs-user-avatar{display:flex;align-items:center;justify-content:center;width:30px;height:30px;border-radius:50%;background:var(--vs-primary,#0E6E6A);color:#fff;font-size:13px;flex-shrink:0;}
.vs-user-name{font-size:13.5px;font-weight:700;color:#FCFAF4;max-width:120px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;}
.vs-user-chevron{font-size:10px;color:rgba(252,250,244,.6);transition:transform .15s;}
.vs-user-btn[aria-expanded="true"] .vs-user-chevron{transform:rotate(180deg);}
.vs-user-dropdown{position:absolute;top:calc(100% + 10px);right:0;z-index:2000;width:260px;background:#fff;border-radius:14px;box-shadow:0 12px 40px rgba(7,26,47,.18),0 2px 8px rgba(7,26,47,.1);border:1px solid #DCE5EF;padding:8px;display:flex;flex-direction:column;animation:vsNotifFadeIn .18s ease;}
.vs-user-dropdown[hidden]{display:none!important;}
.vs-user-dd-header{display:flex;align-items:center;gap:10px;padding:10px 8px 8px;}
.vs-user-dd-avatar{width:40px;height:40px;border-radius:50%;background:linear-gradient(135deg,#287A58,#3db57a);color:#fff;display:flex;align-items:center;justify-content:center;font-size:16px;flex-shrink:0;overflow:hidden;}
.vs-user-dd-avatar img{width:100%;height:100%;object-fit:cover;border-radius:50%;}
.vs-user-dd-info{min-width:0;flex:1;}
.vs-user-dd-name{font-size:13.5px;font-weight:700;color:#122d40;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
.vs-user-dd-email{font-size:11.5px;color:#829AB1;font-weight:500;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;}
.vs-user-dd-section-label{font-size:10.5px;font-weight:700;color:#94A3B8;text-transform:uppercase;letter-spacing:.06em;padding:4px 12px 2px;}
.vs-user-dropdown a{display:flex;align-items:center;gap:10px;padding:9px 12px;border-radius:8px;font-size:13.5px;font-weight:600;color:#122d40;text-decoration:none;transition:background .12s;position:relative;}
.vs-user-dropdown a:hover{background:#F1F5F9;}
.vs-user-dropdown a i{width:16px;color:#287A58;font-size:13px;flex-shrink:0;}
.vs-user-dd-logout{color:#E5484D!important;}
.vs-user-dd-logout i{color:#E5484D!important;}
.vs-user-dd-logout:hover{background:#FFF0F0!important;}
.vs-user-dd-notif-dot{width:7px;height:7px;border-radius:50%;background:#E5484D;position:absolute;right:12px;top:50%;transform:translateY(-50%);}
.vs-user-dropdown-divider{height:1px;background:#EEF2F6;margin:6px 4px;}
@media (max-width:480px){.vs-notif-dropdown{right:-60px;width:calc(100vw - 20px);}}
</style>

<script>
document.addEventListener("DOMContentLoaded", function() {

    /* ─ Cart count ─────────────────────────────────── */
    fetch('${pageContext.request.contextPath}/customer/api/cart-count')
        .then(function(r){return r.json();})
        .then(function(data){
            if(data && data.count !== undefined){
                var badge = document.getElementById('header-cart-badge');
                if(badge){ badge.textContent = data.count; badge.style.opacity = '1'; }
            }
        }).catch(function(e){ console.error("Error loading cart count", e); });

    /* ─ Mobile nav drawer ──────────────────────────── */
    var menuBtn  = document.getElementById('vsMobileMenuBtn');
    var drawer   = document.getElementById('vsMobileNavDrawer');
    var overlay  = document.getElementById('vsMobileNavOverlay');
    var closeBtn = document.getElementById('vsMobileNavClose');
    var lastFocused = null;

    function openDrawer(){
        lastFocused = document.activeElement;
        drawer.classList.add('is-open');
        overlay.classList.add('is-open');
        drawer.setAttribute('aria-hidden','false');
        menuBtn.setAttribute('aria-expanded','true');
        document.body.classList.add('vs-scroll-locked');
        if(closeBtn) closeBtn.focus();
    }
    function closeDrawer(){
        drawer.classList.remove('is-open');
        overlay.classList.remove('is-open');
        drawer.setAttribute('aria-hidden','true');
        menuBtn.setAttribute('aria-expanded','false');
        document.body.classList.remove('vs-scroll-locked');
        if(lastFocused && lastFocused.focus) lastFocused.focus();
    }
    if(menuBtn && drawer && overlay){
        menuBtn.addEventListener('click', openDrawer);
        overlay.addEventListener('click', closeDrawer);
        if(closeBtn) closeBtn.addEventListener('click', closeDrawer);
        document.addEventListener('keydown', function(e){
            if(e.key === 'Escape' && drawer.classList.contains('is-open')) closeDrawer();
        });
        drawer.addEventListener('keydown', function(e){
            if(e.key !== 'Tab') return;
            var focusables = drawer.querySelectorAll('a[href],button:not([disabled])');
            if(!focusables.length) return;
            var first = focusables[0], last = focusables[focusables.length-1];
            if(e.shiftKey && document.activeElement === first){ e.preventDefault(); last.focus(); }
            else if(!e.shiftKey && document.activeElement === last){ e.preventDefault(); first.focus(); }
        });
    }

    /* ─ Mobile search overlay ──────────────────────── */
    var searchBtn     = document.getElementById('vsMobileSearchBtn');
    var searchOverlay = document.getElementById('vsMobileSearchOverlay');
    var searchClose   = document.getElementById('vsMobileSearchClose');
    if(searchBtn && searchOverlay){
        searchBtn.addEventListener('click', function(){
            if(window.innerWidth >= 768){
                window.location.href = '${pageContext.request.contextPath}/customer/tim-kiem';
                return;
            }
            searchOverlay.classList.add('is-open');
            document.body.classList.add('vs-scroll-locked');
            var inp = searchOverlay.querySelector('input[name="q"]');
            if(inp) inp.focus();
        });
        function closeSearch(){
            searchOverlay.classList.remove('is-open');
            document.body.classList.remove('vs-scroll-locked');
        }
        if(searchClose) searchClose.addEventListener('click', closeSearch);
        document.addEventListener('keydown', function(e){
            if(e.key === 'Escape' && searchOverlay.classList.contains('is-open')) closeSearch();
        });
    }

});/* /DOMContentLoaded */

/* ══ Notification bell logic ════════════════════════════════ */
(function(){
    var btn      = document.getElementById('vsNotifBtn');
    var dropdown = document.getElementById('vsNotifDropdown');
    var badge    = document.getElementById('vsNotifBadge');
    var list     = document.getElementById('vsNotifList');
    var clearBtn = document.getElementById('vsNotifClear');
    var ctx      = '${pageContext.request.contextPath}';
    if(!btn || !dropdown) return;

    var ghepKeoItems = [], thongBaoItems = [], serverUnreadCount = 0;
    var lastSeenId = parseInt(localStorage.getItem('vsNotifLastSeenId')||'0',10)||0;
    var isOpen = false;

    function getInitials(name){
        if(!name) return '?';
        return name.trim().split(/\s+/).map(function(p){return p[0];}).slice(-2).join('').toUpperCase();
    }
    function relativeTime(input){
        var ms = (typeof input==='number') ? input : new Date(input).getTime();
        if(!ms) return '';
        var diff = Math.floor((Date.now()-ms)/1000);
        if(diff<60) return 'Vừa xong';
        if(diff<3600) return Math.floor(diff/60)+' phút trước';
        if(diff<86400) return Math.floor(diff/3600)+' giờ trước';
        return Math.floor(diff/86400)+' ngày trước';
    }
    function iconBgForLoai(loai){
        if(!loai) return 'background:#EEF2F6;color:#64748B';
        if(loai.indexOf('HOAN_TIEN')>=0) return 'background:#FFF0F0;color:#E5484D';
        if(loai.indexOf('THANH_TOAN')>=0) return 'background:#FFFBEB;color:#D97706';
        if(loai.indexOf('DAT_SAN')>=0||loai.indexOf('GIU_CHO')>=0) return 'background:#F0FDF8;color:#287A58';
        return 'background:#EEF2F6;color:#64748B';
    }
    function iconForLoai(loai){
        if(!loai) return '🔔';
        if(loai.indexOf('HOAN_TIEN')>=0) return '↩';
        if(loai.indexOf('THANH_TOAN')>=0) return '💳';
        if(loai.indexOf('DAT_SAN')>=0||loai.indexOf('GIU_CHO')>=0) return '📅';
        return '🔔';
    }
    function renderNotifications(){
        list.innerHTML = '';
        var all = [];
        thongBaoItems.forEach(function(n){
            all.push({sortTime:n.thoiGian, isUnread:!n.daDoc, render:function(){
                var li = document.createElement('li');
                li.className = 'vs-notif-item'+((!n.daDoc)?' is-unread':'');
                li.innerHTML = '<div class="vs-notif-avatar" style="font-size:16px;'+iconBgForLoai(n.loai)+'">'+iconForLoai(n.loai)+'</div>'
                    +'<div class="vs-notif-body"><p class="vs-notif-text"><strong>'+(n.tieuDe||'')+'</strong>'
                    +(n.noiDung?'<br><span style="font-weight:500;font-size:12px;color:#486581;">'+n.noiDung+'</span>':'')+'</p>'
                    +'<span class="vs-notif-time">'+relativeTime(n.thoiGian)+'</span></div>';
                if(n.duongDan){
                    li.style.cursor='pointer';
                    li.addEventListener('click',function(){
                        if(!n.daDoc){
                            n.daDoc=true;
                            fetch(ctx+'/customer/thong-bao',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:'action=markRead&id='+n.id}).catch(function(){});
                            updateBadge();
                        }
                        window.location.href=ctx+n.duongDan;
                    });
                }
                return li;
            }});
        });
        ghepKeoItems.forEach(function(n){
            all.push({sortTime:new Date(n.thoiGian).getTime(), isUnread:n.isUnread, render:function(){
                var li = document.createElement('li');
                li.className = 'vs-notif-item'+(n.isUnread?' is-unread':'');
                var actionText=(n.trangThai==='Đã rời')?'đã rời khỏi kèo của bạn':'đã tham gia kèo của bạn';
                li.innerHTML='<div class="vs-notif-avatar">'+getInitials(n.tenNguoiChoi)+'</div>'
                    +'<div class="vs-notif-body"><p class="vs-notif-text"><strong>'+(n.tenNguoiChoi||'Người dùng')+'</strong> '+actionText+'</p>'
                    +'<span class="vs-notif-time">'+relativeTime(n.thoiGian)+'</span></div>';
                return li;
            }});
        });
        if(!all.length){
            var li=document.createElement('li'); li.className='vs-notif-empty';
            li.textContent='Chưa có thông báo mới'; list.appendChild(li); return;
        }
        all.sort(function(a,b){return b.sortTime-a.sortTime;});
        all.slice(0,10).forEach(function(item){list.appendChild(item.render());});
    }
    function updateBadge(){
        var keoUnread=ghepKeoItems.filter(function(n){return n.isUnread;}).length;
        var total=serverUnreadCount+keoUnread;
        if(total>0){ badge.textContent=total>99?'99+':total; badge.style.opacity='1'; badge.style.display='inline-flex'; }
        else{ badge.style.opacity='0'; badge.style.display='none'; }
    }
    function openDropdown(){ isOpen=true; dropdown.hidden=false; btn.setAttribute('aria-expanded','true'); renderNotifications(); }
    function closeDropdown(){ isOpen=false; dropdown.hidden=true; btn.setAttribute('aria-expanded','false'); }
    btn.addEventListener('click',function(e){ e.stopPropagation(); if(isOpen) closeDropdown(); else openDropdown(); });
    document.addEventListener('click',function(e){
        var wrap=document.getElementById('vsNotifWrap');
        if(isOpen && wrap && !wrap.contains(e.target)) closeDropdown();
    });
    document.addEventListener('keydown',function(e){ if(e.key==='Escape' && isOpen) closeDropdown(); });
    if(clearBtn){
        clearBtn.addEventListener('click',function(){
            var maxId=ghepKeoItems.reduce(function(mx,n){return Math.max(mx,n.rawId||0);},lastSeenId);
            localStorage.setItem('vsNotifLastSeenId',String(maxId)); lastSeenId=maxId;
            ghepKeoItems.forEach(function(n){n.isUnread=false;}); serverUnreadCount=0;
            fetch(ctx+'/customer/thong-bao',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:'action=markAllRead'})
                .then(function(){ thongBaoItems.forEach(function(n){n.daDoc=true;}); updateBadge(); renderNotifications(); })
                .catch(function(){ thongBaoItems.forEach(function(n){n.daDoc=true;}); updateBadge(); renderNotifications(); });
        });
    }
    function fetchNotifications(){
        var p1=fetch(ctx+'/customer/api/matches/notifications',{headers:{'Accept':'application/json'}})
            .then(function(r){return r.json();})
            .then(function(data){
                if(!data.success) return;
                var items=data.notifications||[];
                var seenId=parseInt(localStorage.getItem('vsNotifLastSeenId')||'0',10)||0;
                var maxId=items.reduce(function(mx,n){return Math.max(mx,n.id||0);},0);
                if(localStorage.getItem('vsNotifLastSeenId')===null && maxId>0){ localStorage.setItem('vsNotifLastSeenId',String(maxId)); seenId=maxId; }
                lastSeenId=seenId;
                ghepKeoItems=items.map(function(n){return{rawId:n.id,tenNguoiChoi:n.tenNguoiChoi,keoId:n.keoId,trangThai:n.trangThai,thoiGian:n.thoiGian,isUnread:n.id>seenId};});
            }).catch(function(){});
        var p2=fetch(ctx+'/customer/thong-bao?format=json&limit=8',{headers:{'Accept':'application/json'}})
            .then(function(r){return r.json();})
            .then(function(data){
                serverUnreadCount=data.unread||0;
                thongBaoItems=(data.items||[]).map(function(n){return{id:n.id,tieuDe:n.tieuDe,noiDung:n.noiDung,daDoc:n.daDoc,duongDan:n.duongDan,thoiGian:n.thoiGian,loai:n.loai};});
            }).catch(function(){});
        Promise.all([p1,p2]).then(function(){ updateBadge(); if(isOpen) renderNotifications(); });
    }
    fetchNotifications();
    setInterval(fetchNotifications,30000);
    window.vsRefreshNotifications = fetchNotifications;
})();

/* ══ User dropdown ══════════════════════════════════════════ */
(function(){
    var btn=document.getElementById('vsUserBtn');
    var dropdown=document.getElementById('vsUserDropdown');
    if(!btn||!dropdown) return;
    function close(){ dropdown.hidden=true; btn.setAttribute('aria-expanded','false'); }
    function open(){ dropdown.hidden=false; btn.setAttribute('aria-expanded','true'); }
    btn.addEventListener('click',function(e){ e.stopPropagation(); if(dropdown.hidden) open(); else close(); });
    document.addEventListener('click',function(e){ if(!dropdown.hidden&&!dropdown.contains(e.target)&&e.target!==btn) close(); });
    document.addEventListener('keydown',function(e){ if(e.key==='Escape') close(); });

    /* Sync unread dot with notification badge */
    var notifDot = document.getElementById('vsUserDdNotifDot');
    var notifBadge = document.getElementById('vsNotifBadge');
    if(notifDot && notifBadge){
        var obs = new MutationObserver(function(){
            notifDot.style.display = notifBadge.style.opacity==='0'||notifBadge.style.display==='none' ? 'none' : 'block';
        });
        obs.observe(notifBadge, {attributes:true,attributeFilter:['style']});
    }

    /* Load avatar into dropdown header */
    var ddAvatar = document.getElementById('vsUserDdAvatar');
    var hdrAvatar = document.getElementById('vsUserAvatar');
    if(ddAvatar){
        fetch('${pageContext.request.contextPath}/customer/api/profile-avatar')
            .then(function(r){return r.ok?r.json():null;})
            .then(function(d){
                if(!d||!d.avatarUrl) return;
                var img=document.createElement('img');
                img.src=d.avatarUrl; img.alt='Avatar';
                ddAvatar.innerHTML=''; ddAvatar.appendChild(img);
                if(hdrAvatar){ hdrAvatar.innerHTML=''; var img2=img.cloneNode(); hdrAvatar.appendChild(img2); }
            }).catch(function(){});
    }
})();
</script>
