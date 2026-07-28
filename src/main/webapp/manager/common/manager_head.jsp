<%-- Shared <head> content for all Manager role pages --%>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
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
  /* ── flatpickr V-Sport theme ── */
  .flatpickr-calendar {
    font-family: 'Plus Jakarta Sans', 'Inter', sans-serif;
    border-radius: 16px;
    box-shadow: 0 12px 40px -8px rgba(18,45,64,.18), 0 4px 16px -4px rgba(0,0,0,.08);
    border: 1px solid #e2e8f0;
    z-index: 9999 !important;
  }
  .flatpickr-month { background: #122d40; border-radius: 15px 15px 0 0; padding: 10px 0 8px; color: #fff; }
  .flatpickr-current-month { color: #fff; font-size: .9rem; font-weight: 700; }
  .flatpickr-current-month .flatpickr-monthDropdown-months { background: #122d40; color: #fff; border: none; font-weight: 700; }
  .flatpickr-current-month input.cur-year { color: #fff; font-weight: 700; }
  .flatpickr-prev-month svg, .flatpickr-next-month svg { fill: #fff; }
  .flatpickr-prev-month:hover svg, .flatpickr-next-month:hover svg { fill: #01e281; }
  .flatpickr-weekdays { background: #f8fafc; }
  span.flatpickr-weekday { background: #f8fafc; color: #122d40; font-weight: 700; font-size: .7rem; }
  .flatpickr-day { border-radius: 10px; font-size: .8rem; color: #334155; transition: background .1s, color .1s; }
  .flatpickr-day:hover { background: #e6f9f0; border-color: #e6f9f0; color: #065f46; }
  .flatpickr-day.today { border-color: #01e281; color: #0f766e; font-weight: 700; background: #f0fdf4; }
  .flatpickr-day.today:hover { background: #e6f9f0; }
  .flatpickr-day.selected, .flatpickr-day.selected:hover { background: #122d40; border-color: #122d40; color: #fff; font-weight: 700; }
  .flatpickr-day.flatpickr-disabled, .flatpickr-day.flatpickr-disabled:hover { color: #cbd5e1; }
  .flatpickr-innerContainer { padding: 4px 8px 8px; }
  .flatpickr-rContainer { padding: 0 2px; }
  input[type=date]::-webkit-calendar-picker-indicator { display: none; }
  .flatpickr-input.flatpickr-mobile { display: none !important; }
</style>
<style>
  /* ── Base ── */
  :root {
    --vs-primary: #01e281;
    --vs-primary-hover: #01c771;
    --vs-navy: #122d40;
    --vs-navy-dark: #0d2130;
    --vs-text: #0f172a;
    --vs-text-muted: #475569;
    --vs-border: #e2e8f0;
    --vs-surface: #ffffff;
    --vs-surface-soft: #f8fafc;
    --vs-active-bg: #e6f9f0;
    --vs-active-text: #065f46;
  }

  body {
    font-family: 'Plus Jakarta Sans', 'Inter', system-ui, -apple-system, sans-serif;
    background: #f8fafc;
    color: #0f172a;
    min-height: 100vh;
  }

  /* ── Glassmorphism ── */
  .glass-panel {
    background: rgba(255, 255, 255, 0.85);
    backdrop-filter: blur(12px);
    -webkit-backdrop-filter: blur(12px);
    border: 1px solid rgba(226, 232, 240, 0.8);
    box-shadow: 0 8px 32px 0 rgba(18, 45, 64, 0.06);
    border-radius: 2rem;
  }
  .glass-card {
    background: rgba(255, 255, 255, 0.75);
    backdrop-filter: blur(8px);
    -webkit-backdrop-filter: blur(8px);
    border: 1px solid rgba(226, 232, 240, 0.6);
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.03);
    border-radius: 1.5rem;
    transition: all 0.3s ease;
  }
  .glass-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 10px 28px rgba(18, 45, 64, 0.08);
    background: rgba(255, 255, 255, 0.9);
  }

  /* ── Standard cards ── */
  .card { background: #fff; border: 1px solid #e2e8f0; border-radius: 16px; transition: box-shadow .2s, transform .2s; }
  .card-hover:hover { box-shadow: 0 8px 24px -8px rgba(18, 45, 64, 0.1); transform: translateY(-2px); }

  /* ── Badges ── */
  .badge { display: inline-flex; align-items: center; padding: 4px 10px; border-radius: 8px; font-size: 11px; font-weight: 600; }
  .badge-green  { background: #dcfce7; color: #166534; }
  .badge-amber, .badge-yellow { background: #fef3c7; color: #92400e; }
  .badge-red    { background: #fee2e2; color: #991b1b; }
  .badge-blue   { background: #dbeafe; color: #1e40af; }
  .badge-purple { background: #e6f9f0; color: #065f46; }
  .badge-gray, .badge-zinc { background: #f1f5f9; color: #475569; }
  .badge-cyan   { background: #cffafe; color: #0e7490; }

  /* ── Scrollbar ── */
  ::-webkit-scrollbar { width: 5px; height: 5px; }
  ::-webkit-scrollbar-track { background: transparent; }
  ::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 10px; }
  ::-webkit-scrollbar-thumb:hover { background: #94a3b8; }

  /* ── Animations ── */
  @keyframes fadeUp { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
  @keyframes pop    { 0% { opacity: 0; transform: scale(.94); } 100% { opacity: 1; transform: scale(1); } }
  @keyframes pulse-dot { 0%,100%{box-shadow:0 0 0 0 rgba(1,226,129,.4);} 50%{box-shadow:0 0 0 6px rgba(1,226,129,0);} }
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
  .hero-gradient { background: linear-gradient(135deg, #f8fafc 0%, #e6f9f0 60%, #e0f2fe 100%); }

  /* ── Heading gradient ── */
  .heading-gradient {
    background: linear-gradient(to right, #122d40, #059669);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
  }

  /* ── Tab components ── */
  .tab-btn { transition: all .15s; }
  .tab-btn.active { border-color: #01e281; color: #0f766e; font-weight: 700; }
  .tab-content { display: none; animation: fadeUp .25s ease both; }
  .tab-content.active { display: block; }

  @media (prefers-reduced-motion: reduce) { *,*::before,*::after { animation: none !important; transition: none !important; } }
</style>
