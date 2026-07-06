<%@ page contentType="text/html;charset=UTF-8" %>
<style>
  @keyframes _pulse-dot{0%,100%{box-shadow:0 0 0 0 rgba(34,197,94,.4);}50%{box-shadow:0 0 0 6px rgba(34,197,94,0);}}
  .live-dot{animation:_pulse-dot 1.6s ease-in-out infinite;}

  :root {
    --admin-control-bg:#f8fafc;
    --admin-control-bg-focus:#ffffff;
    --admin-control-border:#dbe3ef;
    --admin-control-text:#0f172a;
    --admin-control-muted:#64748b;
    --admin-control-ring:rgba(37,99,235,.11);
  }

  main input:not([type="hidden"]):not([type="checkbox"]):not([type="radio"]):not([type="file"]):not(.sr-only):not(.otp-box):not(.adm-otp):not(.audit-control),
  main select:not(.audit-control),
  main textarea:not(#messageInput):not(.audit-control),
  [id$="Modal"] input:not([type="hidden"]):not([type="checkbox"]):not([type="radio"]):not([type="file"]):not(.sr-only):not(.otp-box):not(.adm-otp):not(.audit-control),
  [id$="Modal"] select:not(.audit-control),
  [id$="Modal"] textarea:not(#messageInput):not(.audit-control),
  #profileDrop input:not([type="hidden"]):not([type="checkbox"]):not([type="radio"]):not([type="file"]):not(.sr-only),
  #profileDrop select,
  #profileDrop textarea {
    border-color:var(--admin-control-border) !important;
    border-radius:10px !important;
    background-color:var(--admin-control-bg) !important;
    color:var(--admin-control-text);
    box-shadow:inset 0 1px 0 rgba(255,255,255,.72);
    transition:border-color .16s ease, box-shadow .16s ease, background-color .16s ease, transform .12s ease;
  }

  main select:not(.audit-control),
  [id$="Modal"] select:not(.audit-control),
  #profileDrop select {
    appearance:none;
    -webkit-appearance:none;
    padding-right:2.25rem !important;
    background-image:
      linear-gradient(45deg, transparent 50%, #64748b 50%),
      linear-gradient(135deg, #64748b 50%, transparent 50%);
    background-position:
      calc(100% - 17px) 50%,
      calc(100% - 12px) 50%;
    background-size:5px 5px, 5px 5px;
    background-repeat:no-repeat;
  }

  main input:not([type="hidden"]):not([type="checkbox"]):not([type="radio"]):not([type="file"]):not(.sr-only):not(.otp-box):not(.adm-otp):not(.audit-control):focus,
  main select:not(.audit-control):focus,
  main textarea:not(#messageInput):not(.audit-control):focus,
  [id$="Modal"] input:not([type="hidden"]):not([type="checkbox"]):not([type="radio"]):not([type="file"]):not(.sr-only):not(.otp-box):not(.adm-otp):not(.audit-control):focus,
  [id$="Modal"] select:not(.audit-control):focus,
  [id$="Modal"] textarea:not(#messageInput):not(.audit-control):focus,
  #profileDrop input:not([type="hidden"]):not([type="checkbox"]):not([type="radio"]):not([type="file"]):not(.sr-only):focus,
  #profileDrop select:focus,
  #profileDrop textarea:focus {
    background-color:var(--admin-control-bg-focus) !important;
    border-color:#2563eb !important;
    box-shadow:0 0 0 3px var(--admin-control-ring), inset 0 1px 0 rgba(255,255,255,.85) !important;
    outline:none !important;
  }

  main input:not(.audit-control)::placeholder,
  main textarea:not(#messageInput):not(.audit-control)::placeholder,
  [id$="Modal"] input:not(.audit-control)::placeholder,
  [id$="Modal"] textarea:not(#messageInput):not(.audit-control)::placeholder,
  #profileDrop input::placeholder,
  #profileDrop textarea::placeholder {
    color:#94a3b8;
    font-weight:500;
  }

  main input[type="date"]:not(.audit-control),
  main input[type="time"],
  [id$="Modal"] input[type="date"],
  [id$="Modal"] input[type="time"] {
    color-scheme:light;
  }

  main button,
  main a[class*="bg-"],
  [id$="Modal"] button,
  #profileDrop button,
  #profileDrop a {
    transition:transform .12s ease, background-color .15s ease, border-color .15s ease, box-shadow .15s ease, opacity .15s ease;
  }

  main button:active:not([disabled]),
  main a[class*="bg-"]:active,
  [id$="Modal"] button:active:not([disabled]),
  #profileDrop button:active:not([disabled]),
  #profileDrop a:active {
    transform:scale(.98);
  }
</style>
<header class="h-[64px] fixed top-0 right-0 left-0 lg:left-[260px] bg-white/80 backdrop-blur-lg border-b border-zinc-200 z-20 flex items-center justify-between px-4 lg:px-6">
  <div class="flex items-center gap-3">
    <button id="mobileMenuBtn" class="lg:hidden p-2 rounded-lg hover:bg-zinc-100 text-zinc-500">
      <span class="material-symbols-outlined text-[20px]">menu</span>
    </button>
    <div>
      <h1 class="text-sm font-bold text-zinc-900 tracking-tight">${param.pageTitle}</h1>
      <p class="text-xs text-zinc-500 flex items-center gap-1.5">
        <span class="material-symbols-outlined text-[12px]">security</span>Quyền hạn Admin
      </p>
    </div>
  </div>
  <div class="flex items-center gap-2">
    <div class="hidden sm:flex items-center gap-1.5 px-3 py-1.5 bg-emerald-50 border border-emerald-100 rounded-xl">
      <span class="w-2 h-2 rounded-full bg-emerald-500 live-dot shrink-0"></span>
      <span class="text-xs font-semibold text-emerald-700">Hệ thống hoạt động</span>
    </div>
    <div class="w-px h-6 bg-zinc-200 mx-1"></div>
    <jsp:include page="/admin/common/profile_dropdown.jsp"/>
  </div>
</header>
