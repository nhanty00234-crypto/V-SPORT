<%-- Shared <head> content for all Staff role pages --%>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<%-- CSRF: token cho JS auto-inject vào form và AJAX --%>
<meta name="csrf-token" content="${sessionScope.csrfToken}">
<script>
(function() {
    var token = document.querySelector('meta[name="csrf-token"]');
    if (!token || !token.content) return;
    var csrf = token.content;
    function injectCsrf(root) {
        (root || document).querySelectorAll('form[method="post"],form[method="POST"]').forEach(function(f) {
            if (!f.querySelector('input[name="_csrf"]')) {
                var h = document.createElement('input');
                h.type = 'hidden'; h.name = '_csrf'; h.value = csrf;
                f.appendChild(h);
            }
        });
    }
    document.addEventListener('DOMContentLoaded', function() { injectCsrf(document); });
    if (window.MutationObserver) {
        new MutationObserver(function(ms) {
            ms.forEach(function(m) { m.addedNodes.forEach(function(n) { if (n.nodeType === 1) injectCsrf(n.tagName === 'FORM' ? n.parentNode : n); }); });
        }).observe(document.body || document.documentElement, { childList: true, subtree: true });
    }
    var origFetch = window.fetch;
    window.fetch = function(url, opts) {
        opts = opts || {};
        if (opts.method && opts.method.toUpperCase() === 'POST') opts.headers = Object.assign({}, opts.headers, { 'X-CSRF-Token': csrf });
        return origFetch.call(this, url, opts);
    };
    var origOpen = XMLHttpRequest.prototype.open, origSend = XMLHttpRequest.prototype.send;
    XMLHttpRequest.prototype.open = function(m) { this._vsm = m; return origOpen.apply(this, arguments); };
    XMLHttpRequest.prototype.send = function() { if (this._vsm && this._vsm.toUpperCase() === 'POST') this.setRequestHeader('X-CSRF-Token', csrf); return origSend.apply(this, arguments); };
})();
</script>
<script src="https://cdn.tailwindcss.com"></script>
<script>
  tailwind.config = {
    theme: {
      extend: {
        fontFamily: {
          sans: ["Plus Jakarta Sans", "Inter", "system-ui", "-apple-system", "sans-serif"]
        }
      }
    }
  };
</script>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200">
<style>
  /* ── Base ── */
  body {
    font-family: 'Plus Jakarta Sans', 'Inter', system-ui, -apple-system, sans-serif;
    background: #ffffff;
    color: #18181b;
    min-height: 100vh;
  }

  /* ── Glassmorphism ── */
  :root {
    --glass-bg: rgba(255, 255, 255, 0.65);
    --glass-border: rgba(255, 255, 255, 0.4);
    --glass-shadow: 0 8px 32px 0 rgba(234, 88, 12, 0.07);
  }
  .glass-panel {
    background: var(--glass-bg);
    backdrop-filter: blur(12px);
    -webkit-backdrop-filter: blur(12px);
    border: 1px solid var(--glass-border);
    box-shadow: var(--glass-shadow);
    border-radius: 2rem;
  }
  .glass-card {
    background: rgba(255, 255, 255, 0.55);
    backdrop-filter: blur(8px);
    -webkit-backdrop-filter: blur(8px);
    border: 1px solid rgba(255, 255, 255, 0.35);
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.03);
    border-radius: 1.5rem;
    transition: all 0.3s ease;
  }
  .glass-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 10px 28px rgba(234, 88, 12, 0.09);
    background: rgba(255, 255, 255, 0.75);
  }

  /* ── Standard cards ── */
  .card { background: #fff; border: 1px solid #ffedd5; border-radius: 16px; transition: box-shadow .2s, transform .2s; }
  .card-hover:hover { box-shadow: 0 8px 24px -8px rgba(234, 88, 12, 0.12); transform: translateY(-2px); }

  /* ── Badges ── */
  .badge { display: inline-flex; align-items: center; padding: 4px 10px; border-radius: 8px; font-size: 11px; font-weight: 600; }
  .badge-green  { background: #dcfce7; color: #15803d; }
  .badge-amber, .badge-yellow { background: #fef3c7; color: #b45309; }
  .badge-red    { background: #fee2e2; color: #b91c1c; }
  .badge-blue   { background: #dbeafe; color: #1e40af; }
  .badge-orange { background: #ffedd5; color: #c2410c; }
  .badge-gray, .badge-zinc { background: #f4f4f5; color: #52525b; }
  .badge-purple { background: #f3e8ff; color: #7e22ce; }

  /* ── Scrollbar ── */
  ::-webkit-scrollbar { width: 5px; height: 5px; }
  ::-webkit-scrollbar-track { background: transparent; }
  ::-webkit-scrollbar-thumb { background: #fed7aa; border-radius: 10px; }
  ::-webkit-scrollbar-thumb:hover { background: #f97316; }

  /* ── Animations ── */
  @keyframes fadeUp { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
  @keyframes pop    { 0% { opacity: 0; transform: scale(.94); } 100% { opacity: 1; transform: scale(1); } }
  @keyframes pulse-dot { 0%,100%{box-shadow:0 0 0 0 rgba(249,115,22,.4);} 50%{box-shadow:0 0 0 6px rgba(249,115,22,0);} }
  @keyframes drawBar    { from { transform: scaleY(0); } to { transform: scaleY(1); } }
  @keyframes contentZoomIn { from { opacity: 0; transform: scale(0.98); } to { opacity: 1; transform: scale(1); } }
  @keyframes fadeInUp   { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }

  main > section { animation: fadeUp .4s ease both; }
  main > section:nth-child(1) { animation-delay: 0ms; }
  main > section:nth-child(2) { animation-delay: 80ms; }
  main > section:nth-child(3) { animation-delay: 160ms; }
  main > section:nth-child(4) { animation-delay: 240ms; }

  .stagger > *:nth-child(1) { animation: pop .35s ease both; animation-delay: 50ms; }
  .stagger > *:nth-child(2) { animation: pop .35s ease both; animation-delay: 120ms; }
  .stagger > *:nth-child(3) { animation: pop .35s ease both; animation-delay: 190ms; }
  .stagger > *:nth-child(4) { animation: pop .35s ease both; animation-delay: 260ms; }

  button { transition: transform .12s ease, opacity .15s ease, background-color .15s ease; }
  button:active:not([disabled]) { transform: scale(.97); }

  .live-dot  { animation: pulse-dot 1.6s ease-in-out infinite; }
  .chart-bar { transform-origin: bottom; animation: drawBar .6s cubic-bezier(.34,1.56,.64,1) both; }

  main { animation: contentZoomIn 0.35s cubic-bezier(0.34, 1.56, 0.64, 1) forwards; transform-origin: center top; }

  .animation-fade, .animation-fadeUp, .animate-fade-in-up { animation: fadeInUp 0.35s ease both; }

  /* ── Scroll reveal ── */
  .reveal-on-scroll { opacity: 0; transform: translateY(16px); transition: opacity .6s cubic-bezier(.16,1,.3,1), transform .6s cubic-bezier(.16,1,.3,1); }
  .reveal-on-scroll.revealed { opacity: 1; transform: translateY(0); }

  /* ── Hero gradient ── */
  .hero-gradient { background: linear-gradient(135deg, #fff7ed 0%, #ffedd5 60%, #ffedad 100%); }

  /* ── Heading gradient ── */
  .heading-gradient {
    background: linear-gradient(to right, #ea580c, #f97316);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
  }

  /* ── Tab components ── */
  .tab-btn { transition: all .15s; }
  .tab-btn.active { border-color: #ea580c; color: #ea580c; font-weight: 700; }
  .tab-content { display: none; animation: fadeUp .25s ease both; }
  .tab-content.active { display: block; }

  @media (prefers-reduced-motion: reduce) { *,*::before,*::after { animation: none !important; transition: none !important; } }
</style>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
<script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
<style>
/* ══ Flatpickr — Staff Slate theme (isolated reset) ══ */
.flatpickr-calendar,.flatpickr-calendar *{box-sizing:border-box!important;margin:0!important;padding:0!important;border:none!important;outline:none!important;font-family:'Inter',sans-serif!important;line-height:normal!important}
.flatpickr-calendar{background:#fff!important;border-radius:18px!important;box-shadow:0 16px 40px -8px rgba(0,0,0,.15),0 4px 12px rgba(0,0,0,.07)!important;border:1px solid #e2e8f0!important;z-index:99999!important;width:308px!important;display:none;overflow:hidden!important}
.flatpickr-calendar.open{display:inline-block!important}
.flatpickr-calendar.inline{display:block!important}
.flatpickr-month{background:linear-gradient(135deg,#475569 0%,#334155 100%)!important;height:52px!important;display:flex!important;align-items:center!important;justify-content:space-between!important;padding:0 6px!important;color:#fff!important}
.flatpickr-current-month{display:flex!important;align-items:center!important;justify-content:center!important;gap:4px!important;font-size:.9rem!important;font-weight:700!important;color:#fff!important;flex:1!important;position:static!important;width:auto!important;padding:0!important}
.flatpickr-current-month .flatpickr-monthDropdown-months{appearance:none!important;-webkit-appearance:none!important;background:transparent!important;color:#fff!important;border:none!important;font-weight:700!important;font-size:.9rem!important;cursor:pointer!important;padding:2px 4px!important}
.flatpickr-current-month input.cur-year{display:inline-block!important;visibility:visible!important;opacity:1!important;color:#fff!important;font-weight:700!important;font-size:.9rem!important;background:transparent!important;border:none!important;width:52px!important;text-align:left!important;cursor:default!important;padding:2px 0!important;-moz-appearance:textfield!important}
.flatpickr-current-month input.cur-year::-webkit-inner-spin-button,.flatpickr-current-month input.cur-year::-webkit-outer-spin-button{display:none!important}
.numInputWrapper{display:inline-flex!important;align-items:center!important} .numInputWrapper span{display:block!important}
.flatpickr-prev-month,.flatpickr-next-month{display:flex!important;align-items:center!important;justify-content:center!important;width:32px!important;height:32px!important;border-radius:8px!important;cursor:pointer!important;padding:6px!important;flex-shrink:0!important;position:static!important}
.flatpickr-prev-month:hover,.flatpickr-next-month:hover{background:rgba(255,255,255,.18)!important}
.flatpickr-prev-month svg,.flatpickr-next-month svg{fill:#fff!important;width:14px!important;height:14px!important}
.flatpickr-weekdays{background:#f8fafc!important;height:34px!important;display:flex!important;align-items:center!important}
.flatpickr-weekdaycontainer{display:flex!important;flex:1!important}
span.flatpickr-weekday{flex:1!important;display:flex!important;align-items:center!important;justify-content:center!important;background:transparent!important;color:#475569!important;font-weight:700!important;font-size:.72rem!important;text-transform:uppercase!important}
.flatpickr-innerContainer{display:block!important;padding:6px 10px 10px!important}
.flatpickr-rContainer{display:block!important}
.flatpickr-days{display:flex!important;width:100%!important}
.dayContainer{display:flex!important;flex-wrap:wrap!important;width:100%!important;min-width:100%!important;max-width:100%!important;justify-content:space-around!important;gap:2px!important;padding:0!important}
.flatpickr-day{display:flex!important;align-items:center!important;justify-content:center!important;width:36px!important;height:36px!important;max-width:36px!important;border-radius:10px!important;font-size:.83rem!important;font-weight:500!important;color:#374151!important;cursor:pointer!important;flex-basis:calc(100%/7 - 3px)!important;transition:background .12s,color .12s!important;border:2px solid transparent!important}
.flatpickr-day:hover{background:#f1f5f9!important;color:#334155!important;border-color:#e2e8f0!important}
.flatpickr-day.today{border-color:#475569!important;color:#1e293b!important;font-weight:700!important;background:#f8fafc!important}
.flatpickr-day.selected,.flatpickr-day.selected:hover{background:#334155!important;border-color:#334155!important;color:#fff!important;font-weight:700!important}
.flatpickr-day.prevMonthDay,.flatpickr-day.nextMonthDay{color:#d1d5db!important}
.flatpickr-day.flatpickr-disabled,.flatpickr-day.flatpickr-disabled:hover{color:#e5e7eb!important;cursor:not-allowed!important;background:transparent!important}
input[type=date]::-webkit-calendar-picker-indicator{display:none!important}
.flatpickr-input.flatpickr-mobile{display:none!important}
</style>
<script>
const Vietnamese=window.Vietnamese||{weekdays:{shorthand:["CN","T2","T3","T4","T5","T6","T7"],longhand:["Chủ nhật","Thứ hai","Thứ ba","Thứ tư","Thứ năm","Thứ sáu","Thứ bảy"]},months:{shorthand:["Th1","Th2","Th3","Th4","Th5","Th6","Th7","Th8","Th9","Th10","Th11","Th12"],longhand:["Tháng 1","Tháng 2","Tháng 3","Tháng 4","Tháng 5","Tháng 6","Tháng 7","Tháng 8","Tháng 9","Tháng 10","Tháng 11","Tháng 12"]},firstDayOfWeek:1,rangeSeparator:" – ",time_24hr:true};
function vsDatePicker(sel,opts){document.querySelectorAll(sel).forEach(function(el){var cfg=Object.assign({dateFormat:"Y-m-d",altInput:true,altFormat:"d/m/Y",allowInput:true,locale:Vietnamese,disableMobile:true,onReady:function(s,str,fp){if(!fp.altInput)return;fp.altInput.className=fp.element.className;fp.altInput.placeholder="dd/mm/yyyy";fp.altInput.removeAttribute("readonly");}},opts||{});flatpickr(el,cfg);});}
</script>
