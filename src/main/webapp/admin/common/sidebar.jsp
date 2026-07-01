<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

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
    color:#475569;text-decoration:none;transition:all .17s ease;
    position:relative;cursor:pointer;white-space:nowrap;
  }
  .nav-link:hover{background:#f1f5f9;color:#0f172a}
  .nav-link.active{
    background:linear-gradient(90deg,#eff6ff,#dbeafe);
    color:#1d4ed8;font-weight:600;
  }
  .nav-link.active::before{
    content:'';position:absolute;left:0;top:6px;bottom:6px;
    width:3px;background:#2563eb;border-radius:0 4px 4px 0;
  }
  .nav-link .material-symbols-outlined{font-size:18px;flex-shrink:0}

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
  .reveal{opacity:0;transform:translateY(22px);transition:opacity .5s cubic-bezier(.22,1,.36,1),transform .5s cubic-bezier(.22,1,.36,1)}
  .reveal.visible{opacity:1;transform:translateY(0)}
  .reveal-left{opacity:0;transform:translateX(-18px);transition:opacity .5s cubic-bezier(.22,1,.36,1),transform .5s cubic-bezier(.22,1,.36,1)}
  .reveal-left.visible{opacity:1;transform:translateX(0)}
  .reveal-scale{opacity:0;transform:scale(.96);transition:opacity .45s cubic-bezier(.22,1,.36,1),transform .45s cubic-bezier(.22,1,.36,1)}
  .reveal-scale.visible{opacity:1;transform:scale(1)}

  /* ── Stagger delays ── */
  .d0{transition-delay:0ms}.d1{transition-delay:70ms}.d2{transition-delay:140ms}.d3{transition-delay:210ms}
  .d4{transition-delay:280ms}.d5{transition-delay:350ms}.d6{transition-delay:420ms}

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
    border:none;cursor:pointer;transition:all .18s;
  }
  .tab-pill.active{background:#2563eb;color:#fff;box-shadow:0 2px 10px rgba(37,99,235,.3)}
  .tab-pill:not(.active){background:#fff;color:#64748b;border:1px solid #e2e8f0}
  .tab-pill:not(.active):hover{background:#f8fafc;color:#1e293b}
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
      <span class="material-symbols-outlined text-white text-[20px]" style="font-variation-settings:'FILL' 1">sports_tennis</span>
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
      <span class="material-symbols-outlined" style="font-variation-settings:'FILL' 1">space_dashboard</span>
      Tổng quan
    </a>

    <!-- Section: Quản lý -->
    <p class="text-[10px] font-bold uppercase tracking-[.12em] text-slate-400 px-3 pt-5 pb-2">Quản lý</p>

    <a href="${pageContext.request.contextPath}/admin/chi-nhanh"
       class="nav-link ${uri.contains('/admin/chi-nhanh') || uri.contains('/QuanLyChiNhanh') ? 'active' : ''}">
      <span class="material-symbols-outlined" style="font-variation-settings:'FILL' 1">location_on</span>
      Cơ Sở
    </a>

    <a href="${pageContext.request.contextPath}/admin/nhan-su"
       class="nav-link ${uri.contains('/admin/nhan-su') || uri.contains('/NhanSu') ? 'active' : ''}">
      <span class="material-symbols-outlined" style="font-variation-settings:'FILL' 1">groups</span>
      Nhân sự
    </a>

    <a href="${pageContext.request.contextPath}/admin/quan-ly-owner"
       class="nav-link ${uri.contains('/admin/quan-ly-owner') || uri.contains('/QuanLyOwner') ? 'active' : ''}">
      <span class="material-symbols-outlined" style="font-variation-settings:'FILL' 1">manage_accounts</span>
      Quản lý Owner
    </a>
  </nav>

  <!-- Logout -->
  <div class="px-3 pb-4 pt-3 border-t border-slate-100 shrink-0">
    <a href="${pageContext.request.contextPath}/logout"
       class="nav-link text-red-500 hover:bg-red-50 hover:text-red-600 text-[13px] font-semibold">
      <span class="material-symbols-outlined text-red-400" style="font-size:17px">logout</span>
      Đăng xuất
    </a>
  </div>
</aside>

<!-- ═══ SIDEBAR JS (shared) ═══ -->
<script>
(function () {
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

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', function () { initSidebar(); initReveal(); });
  } else {
    initSidebar();
    initReveal();
  }
})();
</script>
