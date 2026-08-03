<%-- Shared <head> for all GUARD pages --%>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
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
})();
</script>
<script src="https://cdn.tailwindcss.com"></script>
<script>
  tailwind.config = {
    theme: {
      extend: {
        fontFamily: { sans: ["Plus Jakarta Sans", "Inter", "system-ui", "sans-serif"] },
        colors: {
          guard: {
            50:  '#fff1f2',
            100: '#ffe4e6',
            200: '#fecdd3',
            400: '#fb7185',
            500: '#f43f5e',
            600: '#e11d48',
            700: '#be123c',
            800: '#9f1239',
            900: '#881337',
          }
        }
      }
    }
  };
</script>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@latest/dist/tabler-icons.min.css"/>
<style>
  :root {
    --gd-primary:   #e11d48;
    --gd-primary-h: #be123c;
    --gd-light:     #fff1f2;
    --gd-border:    #fecdd3;
    --gd-accent:    #fb7185;
  }
  body { font-family: 'Plus Jakarta Sans','Inter',system-ui,sans-serif; background:#fafafa; color:#18181b; min-height:100vh; }

  /* Cards */
  .gd-card { background:#fff; border:1px solid var(--gd-border); border-radius:16px; transition:box-shadow .2s,transform .2s; }
  .gd-card:hover { box-shadow:0 8px 24px -8px rgba(225,29,72,.14); transform:translateY(-2px); }

  /* Badges */
  .badge { display:inline-flex; align-items:center; padding:4px 10px; border-radius:8px; font-size:11px; font-weight:600; }
  .badge-red    { background:#fee2e2; color:#b91c1c; }
  .badge-amber  { background:#fef3c7; color:#b45309; }
  .badge-green  { background:#dcfce7; color:#15803d; }
  .badge-blue   { background:#dbeafe; color:#1e40af; }
  .badge-gray   { background:#f4f4f5; color:#52525b; }
  .badge-rose   { background:#fff1f2; color:#be123c; }

  /* Nav links */
  .gd-nav { display:flex; align-items:center; gap:10px; padding:10px 14px; border-radius:10px; color:#6b7280; font-size:14px; font-weight:500; text-decoration:none; transition:background .15s,color .15s,transform .15s; white-space:nowrap; cursor:pointer; }
  .gd-nav:hover { background:var(--gd-light); color:var(--gd-primary); transform:translateX(2px); }
  .gd-nav.active { background:#ffe4e6; color:var(--gd-primary); font-weight:700; position:relative; }
  .gd-nav.active::before { content:''; position:absolute; left:0; top:8px; bottom:8px; width:3px; background:var(--gd-primary); border-radius:0 3px 3px 0; }

  /* Hero */
  .gd-hero { background:linear-gradient(135deg,#fff1f2 0%,#ffe4e6 60%,#fecdd3 100%); }

  /* Animations */
  @keyframes fadeUp { from{opacity:0;transform:translateY(10px);} to{opacity:1;transform:translateY(0);} }
  @keyframes pop    { 0%{opacity:0;transform:scale(.94);} 100%{opacity:1;transform:scale(1);} }
  @keyframes pulse-dot { 0%,100%{box-shadow:0 0 0 0 rgba(225,29,72,.4);} 50%{box-shadow:0 0 0 6px rgba(225,29,72,0);} }
  main > section { animation:fadeUp .4s ease both; }
  main > section:nth-child(1){animation-delay:0ms;} main > section:nth-child(2){animation-delay:80ms;} main > section:nth-child(3){animation-delay:160ms;}
  .stagger>*:nth-child(1){animation:pop .35s ease both;animation-delay:50ms;} .stagger>*:nth-child(2){animation:pop .35s ease both;animation-delay:120ms;} .stagger>*:nth-child(3){animation:pop .35s ease both;animation-delay:190ms;} .stagger>*:nth-child(4){animation:pop .35s ease both;animation-delay:260ms;}
  .live-dot { animation:pulse-dot 1.6s ease-in-out infinite; }

  /* Scrollbar */
  ::-webkit-scrollbar{width:5px;height:5px;} ::-webkit-scrollbar-track{background:transparent;} ::-webkit-scrollbar-thumb{background:#fecdd3;border-radius:10px;} ::-webkit-scrollbar-thumb:hover{background:#e11d48;}

  /* Mobile sidebar overlay */
  #gdSidebarOverlay { position:fixed; inset:0; background:rgba(0,0,0,.4); z-index:20; display:none; }

  /* Flash messages */
  .flash-success { background:#dcfce7; color:#15803d; border:1px solid #bbf7d0; border-radius:12px; padding:12px 16px; font-weight:500; }
  .flash-error   { background:#fee2e2; color:#b91c1c; border:1px solid #fecaca; border-radius:12px; padding:12px 16px; font-weight:500; }

  @media (prefers-reduced-motion:reduce) { *,*::before,*::after { animation:none!important; transition:none!important; } }
</style>
