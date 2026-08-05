<%-- Shared <head> content for all Manager role pages --%>
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
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
<script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
<style>
/* ══ Flatpickr — V-Sport Manager Purple theme (isolated reset) ══ */

/* Hard-reset mọi element bên trong calendar để global CSS không can thiệp */
.flatpickr-calendar,
.flatpickr-calendar * {
  box-sizing: border-box !important;
  margin: 0 !important;
  padding: 0 !important;
  border: none !important;
  outline: none !important;
  font-family: 'Plus Jakarta Sans', 'Inter', sans-serif !important;
  line-height: normal !important;
}

/* Khung ngoài */
.flatpickr-calendar {
  background: #ffffff !important;
  border-radius: 18px !important;
  box-shadow: 0 16px 48px -8px rgba(109,40,217,.22), 0 4px 16px rgba(0,0,0,.08) !important;
  border: 1px solid #e9d5ff !important;
  z-index: 99999 !important;
  width: 308px !important;
  display: none;
  overflow: hidden !important;
}
.flatpickr-calendar.open { display: inline-block !important; }
.flatpickr-calendar.inline { display: block !important; }

/* Header tháng */
.flatpickr-month {
  background: linear-gradient(135deg, #7c3aed 0%, #6d28d9 100%) !important;
  border-radius: 0 !important;
  height: 52px !important;
  display: flex !important;
  align-items: center !important;
  justify-content: space-between !important;
  padding: 0 6px !important;
  color: #fff !important;
}
.flatpickr-current-month {
  display: flex !important;
  align-items: center !important;
  justify-content: center !important;
  gap: 4px !important;
  font-size: .9rem !important;
  font-weight: 700 !important;
  color: #fff !important;
  padding: 0 !important;
  width: auto !important;
  position: static !important;
  flex: 1 !important;
}

/* Dropdown tháng */
.flatpickr-current-month .flatpickr-monthDropdown-months {
  appearance: none !important;
  -webkit-appearance: none !important;
  background: transparent !important;
  color: #fff !important;
  border: none !important;
  font-weight: 700 !important;
  font-size: .9rem !important;
  cursor: pointer !important;
  padding: 2px 4px !important;
  margin: 0 !important;
}

/* Input năm */
.flatpickr-current-month input.cur-year {
  display: inline-block !important;
  visibility: visible !important;
  opacity: 1 !important;
  color: #fff !important;
  font-weight: 700 !important;
  font-size: .9rem !important;
  background: transparent !important;
  border: none !important;
  width: 52px !important;
  text-align: left !important;
  cursor: default !important;
  padding: 2px 0 !important;
  margin: 0 !important;
  -moz-appearance: textfield !important;
}
.flatpickr-current-month input.cur-year::-webkit-inner-spin-button,
.flatpickr-current-month input.cur-year::-webkit-outer-spin-button { display: none !important; }
.numInputWrapper span { display: block !important; }
.numInputWrapper { display: inline-flex !important; align-items: center !important; }

/* Nút prev / next */
.flatpickr-prev-month,
.flatpickr-next-month {
  display: flex !important;
  align-items: center !important;
  justify-content: center !important;
  width: 32px !important;
  height: 32px !important;
  border-radius: 8px !important;
  cursor: pointer !important;
  padding: 6px !important;
  flex-shrink: 0 !important;
  position: static !important;
}
.flatpickr-prev-month:hover,
.flatpickr-next-month:hover { background: rgba(255,255,255,.18) !important; }
.flatpickr-prev-month svg,
.flatpickr-next-month svg { fill: #fff !important; width: 14px !important; height: 14px !important; }

/* Hàng thứ trong tuần */
.flatpickr-weekdays {
  background: #faf5ff !important;
  height: 36px !important;
  display: flex !important;
  align-items: center !important;
}
.flatpickr-weekdaycontainer {
  display: flex !important;
  flex: 1 !important;
}
span.flatpickr-weekday {
  flex: 1 !important;
  display: flex !important;
  align-items: center !important;
  justify-content: center !important;
  background: transparent !important;
  color: #7c3aed !important;
  font-weight: 700 !important;
  font-size: .72rem !important;
  text-transform: uppercase !important;
}

/* Lưới ngày */
.flatpickr-innerContainer {
  display: block !important;
  padding: 6px 10px 10px !important;
}
.flatpickr-rContainer { display: block !important; }
.flatpickr-days { display: flex !important; width: 100% !important; }
.dayContainer {
  display: flex !important;
  flex-wrap: wrap !important;
  width: 100% !important;
  min-width: 100% !important;
  max-width: 100% !important;
  justify-content: space-around !important;
  gap: 2px !important;
  padding: 0 !important;
}

.flatpickr-day {
  display: flex !important;
  align-items: center !important;
  justify-content: center !important;
  width: 36px !important;
  height: 36px !important;
  max-width: 36px !important;
  border-radius: 10px !important;
  font-size: .83rem !important;
  font-weight: 500 !important;
  color: #374151 !important;
  cursor: pointer !important;
  flex-basis: calc(100%/7 - 3px) !important;
  transition: background .12s, color .12s !important;
  border: 2px solid transparent !important;
}
.flatpickr-day:hover {
  background: #f3e8ff !important;
  color: #6d28d9 !important;
  border-color: #e9d5ff !important;
}
.flatpickr-day.today {
  border-color: #7c3aed !important;
  color: #6d28d9 !important;
  font-weight: 700 !important;
  background: #faf5ff !important;
}
.flatpickr-day.selected,
.flatpickr-day.selected:hover {
  background: #7c3aed !important;
  border-color: #7c3aed !important;
  color: #fff !important;
  font-weight: 700 !important;
}
.flatpickr-day.prevMonthDay,
.flatpickr-day.nextMonthDay {
  color: #d1d5db !important;
}
.flatpickr-day.flatpickr-disabled,
.flatpickr-day.flatpickr-disabled:hover {
  color: #e5e7eb !important;
  cursor: not-allowed !important;
  background: transparent !important;
}

input[type=date]::-webkit-calendar-picker-indicator { display: none !important; }
.flatpickr-input.flatpickr-mobile { display: none !important; }
</style>
<script>
/* ── Vietnamese locale shared across all Manager pages ── */
const Vietnamese = window.Vietnamese || {
  weekdays: {
    shorthand: ["CN","T2","T3","T4","T5","T6","T7"],
    longhand:  ["Chủ nhật","Thứ hai","Thứ ba","Thứ tư","Thứ năm","Thứ sáu","Thứ bảy"]
  },
  months: {
    shorthand: ["Th1","Th2","Th3","Th4","Th5","Th6","Th7","Th8","Th9","Th10","Th11","Th12"],
    longhand:  ["Tháng 1","Tháng 2","Tháng 3","Tháng 4","Tháng 5","Tháng 6","Tháng 7","Tháng 8","Tháng 9","Tháng 10","Tháng 11","Tháng 12"]
  },
  firstDayOfWeek: 1,
  rangeSeparator: " – ",
  time_24hr: true
};
/* Init flatpickr with Vietnamese locale on a CSS selector; opts override defaults */
function vsDatePicker(sel, opts) {
  document.querySelectorAll(sel).forEach(function(el) {
    var cfg = Object.assign({
      dateFormat: "Y-m-d",
      altInput: true,
      altFormat: "d/m/Y",
      allowInput: true,
      locale: Vietnamese,
      disableMobile: true,
      onReady: function(s, str, fp) {
        if (!fp.altInput) return;
        fp.altInput.className = fp.element.className;
        fp.altInput.placeholder = "dd/mm/yyyy";
        fp.altInput.removeAttribute("readonly");
      }
    }, opts || {});
    flatpickr(el, cfg);
  });
}
</script>
<style>
  /* ── Base Manager Purple Theme ── */
  :root {
    --vs-primary: #7c3aed;
    --vs-primary-hover: #6d28d9;
    --vs-purple-dark: #4c1d95;
    --vs-purple-light: #f3e8ff;
    --vs-text: #1e1b4b;
    --vs-text-muted: #64748b;
    --vs-border: #f3e8ff;
    --vs-surface: #ffffff;
    --vs-surface-soft: #faf5ff;
    --vs-active-bg: #f3e8ff;
    --vs-active-text: #6d28d9;
  }

  body {
    font-family: 'Plus Jakarta Sans', 'Inter', system-ui, -apple-system, sans-serif;
    background: #f8fafc;
    color: #0f172a;
    min-height: 100vh;
  }

  /* ── Glassmorphism ── */
  .glass-panel {
    background: rgba(255, 255, 255, 0.88);
    backdrop-filter: blur(12px);
    -webkit-backdrop-filter: blur(12px);
    border: 1px solid rgba(233, 213, 255, 0.8);
    box-shadow: 0 8px 32px 0 rgba(124, 58, 237, 0.08);
    border-radius: 2rem;
  }
  .glass-card {
    background: rgba(255, 255, 255, 0.8);
    backdrop-filter: blur(8px);
    -webkit-backdrop-filter: blur(8px);
    border: 1px solid rgba(233, 213, 255, 0.6);
    box-shadow: 0 4px 15px rgba(124, 58, 237, 0.04);
    border-radius: 1.5rem;
    transition: all 0.3s ease;
  }
  .glass-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 10px 28px rgba(124, 58, 237, 0.12);
    background: rgba(255, 255, 255, 0.95);
  }

  /* ── Standard cards ── */
  .card { background: #fff; border: 1px solid #e9d5ff; border-radius: 16px; transition: box-shadow .2s, transform .2s; }
  .card-hover:hover { box-shadow: 0 8px 24px -8px rgba(124, 58, 237, 0.15); transform: translateY(-2px); }

  /* ── Badges ── */
  .badge { display: inline-flex; align-items: center; padding: 4px 10px; border-radius: 8px; font-size: 11px; font-weight: 600; }
  .badge-green  { background: #dcfce7; color: #166534; }
  .badge-amber, .badge-yellow { background: #fef3c7; color: #92400e; }
  .badge-red    { background: #fee2e2; color: #991b1b; }
  .badge-blue   { background: #e0f2fe; color: #0369a1; }
  .badge-purple { background: #f3e8ff; color: #6d28d9; border: 1px solid #e9d5ff; }
  .badge-gray, .badge-zinc { background: #f1f5f9; color: #475569; }
  .badge-cyan   { background: #cffafe; color: #0e7490; }

  /* ── Scrollbar ── */
  ::-webkit-scrollbar { width: 5px; height: 5px; }
  ::-webkit-scrollbar-track { background: transparent; }
  ::-webkit-scrollbar-thumb { background: #d8b4fe; border-radius: 10px; }
  ::-webkit-scrollbar-thumb:hover { background: #c084fc; }

  /* ── Animations ── */
  @keyframes fadeUp { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
  @keyframes pop    { 0% { opacity: 0; transform: scale(.94); } 100% { opacity: 1; transform: scale(1); } }
  @keyframes pulse-dot { 0%,100%{box-shadow:0 0 0 0 rgba(124,58,237,.4);} 50%{box-shadow:0 0 0 6px rgba(124,58,237,0);} }
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

  .live-dot   { animation: pulse-dot 1.6s ease-in-out infinite; }
  .chart-bar  { transform-origin: bottom; animation: drawBar .6s cubic-bezier(.34,1.56,.64,1) both; }

  main { animation: contentZoomIn 0.35s cubic-bezier(0.34, 1.56, 0.64, 1) forwards; transform-origin: center top; }

  .animation-fade, .animation-fadeUp, .animate-fade-in-up { animation: fadeInUp 0.35s ease both; }

  /* ── Hero gradient ── */
  .hero-gradient { background: linear-gradient(135deg, #faf5ff 0%, #f3e8ff 60%, #e9d5ff 100%); }

  /* ── Heading gradient ── */
  .heading-gradient {
    background: linear-gradient(to right, #4c1d95, #7c3aed);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
  }

  /* ── Tab components ── */
  .tab-btn { transition: all .15s; }
  .tab-btn.active { border-color: #7c3aed; color: #6d28d9; font-weight: 700; }
  .tab-content { display: none; animation: fadeUp .25s ease both; }
  .tab-content.active { display: block; }

  @media (prefers-reduced-motion: reduce) { *,*::before,*::after { animation: none !important; transition: none !important; } }
</style>
