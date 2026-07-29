<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%-- Tabler Icons – custom icon set for V-SPORT (injected once via sidebar) --%>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@latest/dist/tabler-icons.min.css"/>

<!-- ═══════════════════════════════════════════════════════
     SHARED ADMIN CSS – included once via sidebar.jsp
════════════════════════════════════════════════════════ -->
<style id="admin-shared-css">
  *,*::before,*::after{box-sizing:border-box}
  html{scroll-behavior:smooth}
  body{font-family:'Inter',sans-serif;background:#f1f5f9;margin:0}
  ::-webkit-scrollbar{width:4px;height:4px}
  ::-webkit-scrollbar-track{background:transparent}
  ::-webkit-scrollbar-thumb{background:#cbd5e1;border-radius:99px}
  ::-webkit-scrollbar-thumb:hover{background:#94a3b8}

  /* ── Sidebar nav-link ── */
  .nav-link{
    display:flex;align-items:center;gap:10px;padding:9px 12px;
    border-radius:10px;font-size:13.5px;font-weight:500;
    color:#475569;text-decoration:none;transition:background-color .17s ease,color .17s ease,transform .17s ease,box-shadow .17s ease;
    position:relative;cursor:pointer;white-space:nowrap;
  }
  .nav-link:hover{background:#f1f5f9;color:#0f172a;transform:translateX(2px)}
  .nav-link.active{
    background:linear-gradient(90deg,#eff6ff,#dbeafe);
    color:#1d4ed8;font-weight:600;
  }
  .nav-link.is-navigating{
    background:linear-gradient(90deg,#dbeafe,#eff6ff);
    color:#1d4ed8;
    box-shadow:inset 0 0 0 1px rgba(37,99,235,.08);
  }
  .nav-link.active::before{
    content:'';position:absolute;left:0;top:6px;bottom:6px;
    width:3px;background:#2563eb;border-radius:0 4px 4px 0;
  }
  .nav-link .ti{font-size:18px;flex-shrink:0}

  /* ── Cards ── */
  .adm-card{
    background:#fff;border:1px solid #e2e8f0;
    border-radius:16px;overflow:hidden;
  }
  .adm-card-hover{transition:box-shadow .2s,transform .2s}
  .adm-card-hover:hover{box-shadow:0 4px 24px rgba(15,23,42,.08);transform:translateY(-2px)}

  /* ── Badges ── */
  .badge{display:inline-flex;align-items:center;border-radius:99px;font-size:11px;font-weight:700;padding:2px 8px}
  .badge-green{background:#dcfce7;color:#166534}
  .badge-amber{background:#fef3c7;color:#92400e}
  .badge-red{background:#fee2e2;color:#991b1b}
  .badge-blue{background:#dbeafe;color:#1e40af}
  .badge-purple{background:#ede9fe;color:#5b21b6}
  .badge-zinc{background:#f1f5f9;color:#475569}

  /* ── Scroll reveal ── */
  .reveal{opacity:0;transform:translateY(14px);transition:opacity .42s cubic-bezier(.22,1,.36,1),transform .42s cubic-bezier(.22,1,.36,1)}
  .reveal.visible{opacity:1;transform:translateY(0)}
  .reveal-left{opacity:0;transform:translateX(-14px);transition:opacity .42s cubic-bezier(.22,1,.36,1),transform .42s cubic-bezier(.22,1,.36,1)}
  .reveal-left.visible{opacity:1;transform:translateX(0)}
  .reveal-scale{opacity:0;transform:scale(.98);transition:opacity .38s cubic-bezier(.22,1,.36,1),transform .38s cubic-bezier(.22,1,.36,1)}
  .reveal-scale.visible{opacity:1;transform:scale(1)}

  /* ── Stagger delays ── */
  .d0{transition-delay:0ms}.d1{transition-delay:45ms}.d2{transition-delay:90ms}.d3{transition-delay:135ms}
  .d4{transition-delay:180ms}.d5{transition-delay:225ms}.d6{transition-delay:270ms}

  /* ── Animate number counter ── */
  @keyframes countUp{from{opacity:0;transform:translateY(8px)}to{opacity:1;transform:translateY(0)}}
  .num-anim{animation:countUp .6s cubic-bezier(.22,1,.36,1) both}

  /* ── Live dot ── */
  @keyframes livePulse{0%,100%{box-shadow:0 0 0 0 rgba(34,197,94,.45)}50%{box-shadow:0 0 0 5px rgba(34,197,94,0)}}
  .live-dot{animation:livePulse 1.8s ease-in-out infinite}

  /* ── Tab buttons ── */
  .tab-pill{
    display:inline-flex;align-items:center;gap:6px;
    padding:7px 16px;border-radius:99px;font-size:13px;font-weight:500;
    border:none;cursor:pointer;transition:all .18s;text-decoration:none;
  }
  .tab-pill.active{background:#2563eb;color:#fff;box-shadow:0 2px 10px rgba(37,99,235,.3)}
  .tab-pill:not(.active){background:#fff;color:#64748b;border:1px solid #e2e8f0}
  .tab-pill:not(.active):hover{background:#f8fafc;color:#1e293b}

  /* ── Page motion ── */
  body.admin-motion main{
    opacity:0;
    transform:translateY(5px) scale(.998);
    animation:none !important;
  }
  body.admin-motion.admin-page-ready main{
    opacity:1;
    transform:translateY(0) scale(1);
    transition:opacity .16s cubic-bezier(.22,1,.36,1),transform .16s cubic-bezier(.22,1,.36,1);
  }
  body.admin-page-exiting main{
    opacity:0 !important;
    transform:translateY(-4px) scale(.997) !important;
    transition:opacity .1s ease,transform .1s ease !important;
  }
  .admin-transition-scrim{
    position:fixed;inset:0;z-index:60;pointer-events:none;
    background:linear-gradient(180deg,rgba(248,250,252,.5),rgba(241,245,249,.62));
    opacity:0;
    transition:opacity .1s ease;
  }
  body.admin-page-exiting .admin-transition-scrim{opacity:1}
  .admin-transition-scrim::after{
    content:'';position:absolute;left:260px;right:0;top:64px;height:2px;
    background:linear-gradient(90deg,transparent,#2563eb,#38bdf8,transparent);
    transform:scaleX(0);transform-origin:left;
  }
  body.admin-page-exiting .admin-transition-scrim::after{animation:adminRouteLine .22s cubic-bezier(.22,1,.36,1) forwards}
  @keyframes adminRouteLine{to{transform:scaleX(1)}}
  @media (max-width:1023px){.admin-transition-scrim::after{left:0}}
  @media (prefers-reduced-motion:reduce){
    body.admin-motion main,
    body.admin-motion.admin-page-ready main,
    body.admin-page-exiting main{opacity:1!important;transform:none!important;filter:none!important;transition:none!important}
    .admin-transition-scrim{display:none!important}
  }

  /* ══════════════════════════════════════════
     ENHANCED ADMIN ANIMATIONS v2
  ══════════════════════════════════════════ */

  /* ── Sidebar nav: richer hover (blue tint + shift 3px) ── */
  .nav-link:hover {
    background: rgba(0,102,255,.07) !important;
    color: #1d4ed8 !important;
    transform: translateX(3px) !important;
    box-shadow: none;
  }
  .nav-link .ti, .nav-link .material-symbols-outlined {
    transition: transform .18s cubic-bezier(.34,1.56,.64,1);
  }
  .nav-link:hover .ti,
  .nav-link:hover .material-symbols-outlined { transform: scale(1.15); }

  /* ── Welcome banner shimmer ── */
  @keyframes bannerShimmer {
    0%   { background-position: 200% center; }
    100% { background-position: -200% center; }
  }
  .banner-shimmer {
    background: linear-gradient(135deg,#1e3a8a 0%,#2563eb 40%,#3b82f6 60%,#1d4ed8 80%,#1e3a8a 100%);
    background-size: 300% 100%;
    animation: bannerShimmer 5s linear infinite;
  }

  /* ── KPI card: stronger hover lift + badge pulse ── */
  .kpi-card-anim {
    transition: transform .22s cubic-bezier(.16,1,.3,1), box-shadow .22s cubic-bezier(.16,1,.3,1);
  }
  .kpi-card-anim:hover {
    transform: translateY(-4px);
    box-shadow: 0 10px 30px -8px rgba(0,0,0,.10);
  }
  .kpi-card-anim:hover .kpi-badge {
    animation: kpiBadgePulse .6s cubic-bezier(.34,1.56,.64,1) both;
  }
  @keyframes kpiBadgePulse {
    0%   { transform: scale(1); }
    50%  { transform: scale(1.12); }
    100% { transform: scale(1); }
  }
  .kpi-card-anim:hover .kpi-icon {
    transform: scale(1.08);
    transition: transform .22s cubic-bezier(.34,1.56,.64,1);
  }
  .kpi-icon { transition: transform .22s ease; }

  /* ── Progress bars: animate from 0 to target ── */
  .progress-fill {
    width: 0 !important;
    transition: width .9s cubic-bezier(.16,1,.3,1);
  }
  .progress-fill.animated { width: var(--target-w) !important; }

  /* ── Staggered grid cascade ── */
  .grid-cascade > * {
    opacity: 0;
    transform: translateY(18px);
    transition: opacity .38s cubic-bezier(.22,1,.36,1), transform .38s cubic-bezier(.22,1,.36,1);
  }
  .grid-cascade > *.visible { opacity: 1; transform: translateY(0); }

  /* ── Active status pulse dot ── */
  @keyframes pulseDotGreen {
    0%,100% { box-shadow: 0 0 0 0 rgba(34,197,94,.5); }
    50%      { box-shadow: 0 0 0 5px rgba(34,197,94,0); }
  }
  .pulse-dot {
    display: inline-block;
    width: 7px; height: 7px;
    border-radius: 50%;
    background: #22c55e;
    animation: pulseDotGreen 1.8s ease-in-out infinite;
  }
  .pulse-dot-amber { background: #f59e0b;
    animation-name: pulseDotAmber;
  }
  @keyframes pulseDotAmber {
    0%,100% { box-shadow: 0 0 0 0 rgba(245,158,11,.5); }
    50%      { box-shadow: 0 0 0 5px rgba(245,158,11,0); }
  }

  /* ── Action button micro-interactions ── */
  .btn-edit {
    transition: background-color .15s ease, color .15s ease, transform .12s ease, box-shadow .15s ease;
  }
  .btn-edit:hover {
    background-color: #eff6ff !important;
    color: #1d4ed8 !important;
    box-shadow: 0 0 0 2px rgba(37,99,235,.15);
  }
  .btn-danger {
    transition: background-color .15s ease, color .15s ease, transform .12s ease, box-shadow .15s ease;
  }
  .btn-danger:hover {
    background-color: #fef2f2 !important;
    color: #b91c1c !important;
    box-shadow: 0 0 0 2px rgba(239,68,68,.15);
    animation: dangerPulse .35s ease both;
  }
  @keyframes dangerPulse {
    0%   { transform: scale(1); }
    40%  { transform: scale(1.05); }
    100% { transform: scale(1); }
  }
  .btn-config {
    transition: background-color .15s ease, color .15s ease, box-shadow .15s ease, transform .12s ease;
  }
  .btn-config:hover {
    background-color: #f0fdf4 !important;
    color: #15803d !important;
    box-shadow: 0 0 0 2px rgba(34,197,94,.15);
  }

  /* ── Ripple effect ── */
  .ripple-host { position: relative; overflow: hidden; }
  .ripple-wave {
    position: absolute;
    border-radius: 50%;
    transform: scale(0);
    background: rgba(255,255,255,.35);
    animation: rippleOut .55s cubic-bezier(.16,1,.3,1) forwards;
    pointer-events: none;
  }
  @keyframes rippleOut {
    to { transform: scale(4); opacity: 0; }
  }

  /* ── Audit log timeline cards: sequential slide-in ── */
  .log-row-anim {
    opacity: 0;
    transform: translateY(15px);
    transition: opacity .4s cubic-bezier(.22,1,.36,1), transform .4s cubic-bezier(.22,1,.36,1),
                box-shadow .2s ease;
  }
  .log-row-anim.visible { opacity: 1; transform: translateY(0); }
  .log-row-anim:hover { box-shadow: 0 0 0 2px rgba(37,99,235,.1), 0 6px 20px -4px rgba(0,0,0,.07); }
  .log-row-anim:hover .log-border-accent { width: 4px; box-shadow: 2px 0 8px rgba(37,99,235,.25); }
  .log-border-accent {
    position: absolute; left: 0; top: 0; bottom: 0;
    width: 3px; border-radius: 0 2px 2px 0;
    background: #2563eb; transition: width .18s ease, box-shadow .18s ease;
  }
  .log-row-anim:hover .log-ip-badge {
    background: #dbeafe !important;
    color: #1e40af !important;
  }
  .log-ip-badge { transition: background .15s ease, color .15s ease; }

  /* ── Trash page: summary tiles fade-in with left border ── */
  .trash-tile-anim {
    opacity: 0;
    transform: translateY(12px);
    transition: opacity .4s cubic-bezier(.22,1,.36,1), transform .4s cubic-bezier(.22,1,.36,1);
    border-left: 3px solid transparent;
  }
  .trash-tile-anim.visible { opacity: 1; transform: translateY(0); }
  .trash-tile-total   { border-left-color: #7c3aed; }
  .trash-tile-pending { border-left-color: #f59e0b; }
  .trash-tile-done    { border-left-color: #22c55e; }

  /* ── Trash table: row hover ── */
  .trash-row-hover {
    transition: background-color .15s ease;
  }
  .trash-row-hover:hover { background: rgba(248,250,252,.8) !important; }

  /* ── Restore button: green glow + icon bounce ── */
  .btn-restore {
    transition: background-color .15s ease, color .15s ease, box-shadow .18s ease, transform .12s ease;
  }
  .btn-restore:hover {
    background-color: #dcfce7 !important;
    color: #15803d !important;
    box-shadow: 0 0 12px rgba(34,197,94,.25);
  }
  .btn-restore:hover .restore-icon {
    animation: restoreIconBounce .4s cubic-bezier(.34,1.56,.64,1) both;
  }
  @keyframes restoreIconBounce {
    0%   { transform: rotate(0deg) scale(1); }
    50%  { transform: rotate(-20deg) scale(1.2); }
    100% { transform: rotate(0deg) scale(1); }
  }
  .restore-icon { display: inline-block; }

  /* ── Restore row: flash green then collapse ── */
  .trash-row-restoring {
    animation: trashRowOut .5s cubic-bezier(.4,0,.2,1) forwards;
    pointer-events: none;
  }
  @keyframes trashRowOut {
    0%   { background: #fff; max-height: 80px; opacity: 1; }
    30%  { background: #f0fdf4; }
    80%  { opacity: 0; max-height: 80px; }
    100% { opacity: 0; max-height: 0; padding-top: 0; padding-bottom: 0; border: none; overflow: hidden; }
  }

  /* ── Animated number counter ── */
  @keyframes numSlideUp {
    from { opacity: 0; transform: translateY(10px); }
    to   { opacity: 1; transform: translateY(0); }
  }
  .num-counter { animation: numSlideUp .6s cubic-bezier(.22,1,.36,1) both; }

  @media (prefers-reduced-motion: reduce) {
    .banner-shimmer { animation: none !important; background-size: 100% !important; }
    .kpi-card-anim, .kpi-card-anim:hover { transform: none !important; }
    .log-row-anim, .trash-tile-anim, .grid-cascade > * {
      opacity: 1 !important; transform: none !important; transition: none !important;
    }
    .pulse-dot, .pulse-dot-amber { animation: none !important; }
    .ripple-wave { display: none !important; }
  }
</style>

<!-- Mobile overlay -->
<div id="sidebarOverlay" class="fixed inset-0 bg-slate-900/50 z-20 hidden lg:hidden backdrop-blur-sm"></div>

<!-- ═══ SIDEBAR ═══ -->
<aside id="sidebar"
  class="w-[260px] h-screen fixed left-0 top-0 z-30 flex flex-col
         bg-white border-r border-slate-200 shadow-[1px_0_16px_rgba(15,23,42,.06)]
         transition-transform duration-300 -translate-x-full lg:translate-x-0">

  <!-- Logo -->
  <div class="px-5 py-5 border-b border-slate-100 flex items-center gap-3 shrink-0">
    <div class="w-10 h-10 rounded-2xl bg-gradient-to-br from-blue-500 to-blue-700
                flex items-center justify-center shrink-0
                shadow-md shadow-blue-200/60">
      <i class="ti ti-ball-tennis text-white text-[20px]"></i>
    </div>
    <div>
      <p class="text-[15px] font-black text-slate-900 tracking-tight leading-none">V-SPORT</p>
      <p class="text-[10px] text-slate-400 font-semibold uppercase tracking-widest mt-0.5">Admin Portal</p>
    </div>
  </div>

  <!-- Navigation -->
  <nav class="flex-1 overflow-y-auto px-3 py-4 flex flex-col gap-0.5">
    <c:set var="uri" value="${pageContext.request.requestURI}"/>

    <!-- Section: Vận hành -->
    <p class="text-[10px] font-bold uppercase tracking-[.12em] text-slate-400 px-3 pt-1 pb-2">Vận hành</p>

    <a href="${pageContext.request.contextPath}/admin/tong-quan"
       class="nav-link ${uri.contains('/admin/tong-quan') || uri.contains('/TongQuan') ? 'active' : ''}">
      <i class="ti ti-layout-dashboard"></i>
      Tổng quan
    </a>

    <!-- Section: Quản lý -->
    <p class="text-[10px] font-bold uppercase tracking-[.12em] text-slate-400 px-3 pt-5 pb-2">Quản lý</p>

    <a href="${pageContext.request.contextPath}/admin/chi-nhanh"
       class="nav-link ${uri.contains('/admin/chi-nhanh') || uri.contains('/QuanLyChiNhanh') ? 'active' : ''}">
      <i class="ti ti-building-stadium"></i>
      Cơ Sở
      <c:if test="${sessionScope.adminPendingCount != null && sessionScope.adminPendingCount > 0}">
        <span style="margin-left:auto;background:#f59e0b;color:#fff;border-radius:99px;font-size:10px;font-weight:700;padding:1px 7px;line-height:1.6;">${sessionScope.adminPendingCount}</span>
      </c:if>
    </a>

    <a href="${pageContext.request.contextPath}/admin/nhan-su"
       class="nav-link ${uri.contains('/admin/nhan-su') || uri.contains('/NhanSu') ? 'active' : ''}">
      <i class="ti ti-users-group"></i>
      Nhân sự
    </a>

    <a href="${pageContext.request.contextPath}/admin/audit-log"
       class="nav-link ${uri.contains('/admin/audit-log') || uri.contains('/AuditLog') ? 'active' : ''}">
      <i class="ti ti-history"></i>
      Nhật Ký Thao Tác
    </a>

    <a href="${pageContext.request.contextPath}/admin/thung-rac"
       class="nav-link ${uri.contains('/admin/thung-rac') || uri.contains('/ThungRacAdmin') ? 'active' : ''}">
      <i class="ti ti-trash"></i>
      Thùng rác
    </a>
  </nav>

  <!-- Logout -->
  <div class="px-3 pb-4 pt-3 border-t border-slate-100 shrink-0">
    <a href="${pageContext.request.contextPath}/logout"
       class="nav-link text-red-500 hover:bg-red-50 hover:text-red-600 text-[13px] font-semibold">
      <i class="ti ti-logout text-red-400 text-[17px]"></i>
      Đăng xuất
    </a>
  </div>
</aside>

<!-- ═══ SIDEBAR JS (shared) ═══ -->
<script>
(function () {
  document.body.classList.add('admin-motion');

  function initPageMotion() {
    var scrim = document.createElement('div');
    scrim.className = 'admin-transition-scrim';
    document.body.appendChild(scrim);

    requestAnimationFrame(function () {
      document.body.classList.add('admin-page-ready');
    });

    window.addEventListener('pageshow', function () {
      document.body.classList.remove('admin-page-exiting');
      requestAnimationFrame(function () {
        document.body.classList.add('admin-page-ready');
      });
    });

    document.addEventListener('click', function (event) {
      var link = event.target.closest('a[href]');
      if (!link || event.defaultPrevented) return;
      if (event.metaKey || event.ctrlKey || event.shiftKey || event.altKey || event.button !== 0) return;
      if (link.target && link.target !== '_self') return;
      if (link.hasAttribute('download')) return;

      var href = link.getAttribute('href') || '';
      if (!href || href.charAt(0) === '#' || href.indexOf('javascript:') === 0 || href.indexOf('mailto:') === 0 || href.indexOf('tel:') === 0) return;

      var url;
      try { url = new URL(href, window.location.href); } catch (e) { return; }
      if (url.origin !== window.location.origin) return;
      if (url.pathname === window.location.pathname && url.search === window.location.search && url.hash) return;
      if (url.href === window.location.href) return;

      var appPath = '${pageContext.request.contextPath}';
      if (appPath && url.pathname.indexOf(appPath + '/admin') !== 0 && url.pathname.indexOf(appPath + '/logout') !== 0) return;

      event.preventDefault();
      link.classList.add('is-navigating');
      document.body.classList.add('admin-page-exiting');
      window.setTimeout(function () {
        window.location.href = url.href;
      }, 90);
    });
  }

  function initSidebar() {
    var sidebar  = document.getElementById('sidebar');
    var overlay  = document.getElementById('sidebarOverlay');
    var menuBtns = document.querySelectorAll('[data-sidebar-toggle], #mobileMenuBtn, #sidebarToggle');
    if (!sidebar) return;

    function open()  { sidebar.classList.remove('-translate-x-full'); if (overlay) overlay.classList.remove('hidden'); }
    function close() { sidebar.classList.add('-translate-x-full');    if (overlay) overlay.classList.add('hidden'); }

    menuBtns.forEach(function (btn) { btn.addEventListener('click', function () { sidebar.classList.contains('-translate-x-full') ? open() : close(); }); });
    if (overlay) overlay.addEventListener('click', close);
    window.addEventListener('resize', function () { if (window.innerWidth >= 1024) { overlay && overlay.classList.add('hidden'); } });
  }

  /* ── Scroll-reveal with IntersectionObserver ── */
  function initReveal() {
    var els = document.querySelectorAll('.reveal, .reveal-left, .reveal-scale');
    if (!els.length) return;
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (e) { if (e.isIntersecting) { e.target.classList.add('visible'); io.unobserve(e.target); } });
    }, { threshold: 0.08 });
    els.forEach(function (el) { io.observe(el); });
  }

  /* ── Xác nhận trước khi chuyển vào thùng rác (soft-delete) ── */
  function initSoftDeleteConfirm() {
    document.addEventListener('click', function (event) {
      var trigger = event.target.closest('.js-admin-soft-delete');
      if (!trigger) return;
      var msg = trigger.getAttribute('data-delete-message') ||
                'Bạn chắc chắn muốn chuyển mục này vào thùng rác? Bạn có thể thu hồi lại trong trang Thùng rác.';
      if (!confirm(msg)) {
        event.preventDefault();
        event.stopPropagation();
      }
    }, true);
  }

  /* ── Animated number counter ── */
  function initCounters() {
    document.querySelectorAll('[data-count-to]').forEach(function(el) {
      var target = parseInt(el.getAttribute('data-count-to'), 10);
      if (isNaN(target) || target === 0) { el.textContent = '0'; return; }
      var duration = Math.min(1200, Math.max(500, target * 40));
      var start = null;
      el.textContent = '0';
      el.classList.add('num-counter');
      function step(ts) {
        if (!start) start = ts;
        var progress = Math.min((ts - start) / duration, 1);
        var ease = 1 - Math.pow(1 - progress, 3);
        el.textContent = Math.round(ease * target).toLocaleString('vi-VN');
        if (progress < 1) requestAnimationFrame(step);
      }
      requestAnimationFrame(step);
    });
  }

  /* ── Progress bar fill ── */
  function initProgressBars() {
    var io = new IntersectionObserver(function(entries) {
      entries.forEach(function(e) {
        if (!e.isIntersecting) return;
        var bar = e.target;
        var w = bar.getAttribute('data-bar-width') || bar.style.width;
        bar.style.setProperty('--target-w', w);
        bar.style.width = '0';
        requestAnimationFrame(function() {
          bar.classList.add('progress-fill');
          requestAnimationFrame(function() { bar.classList.add('animated'); });
        });
        io.unobserve(bar);
      });
    }, { threshold: 0.1 });
    document.querySelectorAll('.bar-animate').forEach(function(bar) { io.observe(bar); });
  }

  /* ── Grid cascade entrance ── */
  function initGridCascade() {
    document.querySelectorAll('.grid-cascade').forEach(function(grid) {
      var children = Array.from(grid.children);
      var io = new IntersectionObserver(function(entries) {
        if (!entries[0].isIntersecting) return;
        children.forEach(function(child, i) {
          setTimeout(function() { child.classList.add('visible'); }, i * 55);
        });
        io.unobserve(grid);
      }, { threshold: 0.05 });
      io.observe(grid);
    });
  }

  /* ── Log row sequential entrance ── */
  function initLogRows() {
    var rows = document.querySelectorAll('.log-row-anim');
    if (!rows.length) return;
    var io = new IntersectionObserver(function(entries) {
      entries.forEach(function(e) {
        if (e.isIntersecting) { e.target.classList.add('visible'); io.unobserve(e.target); }
      });
    }, { threshold: 0.05 });
    rows.forEach(function(r, i) {
      r.style.transitionDelay = (i * 45) + 'ms';
      io.observe(r);
    });
  }

  /* ── Trash tile fade-in ── */
  function initTrashTiles() {
    var tiles = document.querySelectorAll('.trash-tile-anim');
    if (!tiles.length) return;
    tiles.forEach(function(t, i) {
      setTimeout(function() { t.classList.add('visible'); }, 60 + i * 70);
    });
  }

  /* ── Ripple on all buttons ── */
  function initRipple() {
    document.addEventListener('click', function(e) {
      var btn = e.target.closest('button, a.ripple-host, [data-ripple]');
      if (!btn) return;
      var rect = btn.getBoundingClientRect();
      var size = Math.max(rect.width, rect.height) * 2;
      var span = document.createElement('span');
      span.className = 'ripple-wave';
      span.style.cssText = 'width:' + size + 'px;height:' + size + 'px;'
        + 'left:' + (e.clientX - rect.left - size/2) + 'px;'
        + 'top:'  + (e.clientY - rect.top  - size/2) + 'px;';
      if (getComputedStyle(btn).position === 'static') btn.style.position = 'relative';
      btn.style.overflow = 'hidden';
      btn.appendChild(span);
      span.addEventListener('animationend', function() { span.remove(); });
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', function () {
      initPageMotion(); initSidebar(); initReveal(); init24hTime(); initSoftDeleteConfirm();
      initCounters(); initProgressBars(); initGridCascade(); initLogRows(); initTrashTiles(); initRipple();
    });
  } else {
    initPageMotion(); initSidebar(); initReveal(); init24hTime(); initSoftDeleteConfirm();
    initCounters(); initProgressBars(); initGridCascade(); initLogRows(); initTrashTiles(); initRipple();
  }

  /* ── Force 24h time inputs across all admin pages ── */
  function init24hTime() {
    document.querySelectorAll('input[type="time"]').forEach(function(inp) {
      var val   = inp.value || '00:00';
      var parts = val.split(':');
      var initH = parseInt(parts[0] || 0, 10);
      var initM = parseInt(parts[1] || 0, 10);
      // Round minute to nearest valid step
      var steps = [0, 15, 30, 45];
      var closestM = steps.reduce(function(a, b) { return Math.abs(b - initM) < Math.abs(a - initM) ? b : a; });

      var wrap = document.createElement('div');
      wrap.style.cssText = 'display:flex;align-items:center;gap:4px;width:100%;';

      var selStyle = 'flex:1;min-width:0;height:' + (inp.offsetHeight || 38) + 'px;'
                   + 'padding:4px 8px;border:' + getComputedStyle(inp).border + ';'
                   + 'border-radius:' + getComputedStyle(inp).borderRadius + ';'
                   + 'font-size:' + getComputedStyle(inp).fontSize + ';'
                   + 'background:#fff;cursor:pointer;';

      var hSel = document.createElement('select');
      hSel.style.cssText = selStyle;
      hSel.setAttribute('aria-label', 'Giờ');
      for (var h = 0; h <= 23; h++) {
        var o = document.createElement('option');
        o.value = String(h).padStart(2, '0');
        o.textContent = String(h).padStart(2, '0') + 'h';
        if (h === initH) o.selected = true;
        hSel.appendChild(o);
      }

      var mSel = document.createElement('select');
      mSel.style.cssText = selStyle;
      mSel.setAttribute('aria-label', 'Phút');
      steps.forEach(function(m) {
        var o = document.createElement('option');
        o.value = String(m).padStart(2, '0');
        o.textContent = String(m).padStart(2, '0');
        if (m === closestM) o.selected = true;
        mSel.appendChild(o);
      });

      function sync() {
        inp.value = hSel.value + ':' + mSel.value + ':00';
        // Fire any existing onchange / oninput
        inp.dispatchEvent(new Event('change', { bubbles: true }));
        inp.dispatchEvent(new Event('input',  { bubbles: true }));
      }
      hSel.addEventListener('change', sync);
      mSel.addEventListener('change', sync);

      wrap.appendChild(hSel);
      wrap.appendChild(mSel);
      inp.style.display = 'none';
      inp.parentNode.insertBefore(wrap, inp.nextSibling);
      sync();
    });
  }
})();
</script>
