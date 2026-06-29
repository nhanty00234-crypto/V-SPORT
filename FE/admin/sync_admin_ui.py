import os
import re

directory = r"d:\DATN\DATN_TheBigSize\FE\admin"
html_files = [f for f in os.listdir(directory) if f.endswith('.html')]

for filename in html_files:
    filepath = os.path.join(directory, filename)
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Add animate.css
    if 'animate.min.css' not in content:
        content = content.replace('<script id="tailwind-config">', 
            '<!-- Animate.css for subtle entrance animations -->\n<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/animate.css/4.1.1/animate.min.css"/>\n<script id="tailwind-config">')

    # 2. Add primary-hover to tailwind config
    if '"primary-hover"' not in content:
        content = content.replace('"primary": "#0047a9",', '"primary": "#0047a9",\n            "primary-hover": "#00368a",')

    # 3. Add boxShadow, animation, keyframes to tailwind config
    if "'soft':" not in content:
        injection = """
          "boxShadow": {
            'soft': '0 4px 20px -2px rgba(0, 0, 0, 0.05)',
            'floating': '0 10px 40px -10px rgba(0,0,0,0.08)',
            'glass': 'inset 0 2px 4px 0 rgba(255, 255, 255, 0.3)',
          },
          "animation": {
            'fade-in': 'fadeIn 0.3s ease-out',
            'slide-up': 'slideUp 0.4s ease-out forwards',
          },
          "keyframes": {
            fadeIn: {
              '0%': { opacity: '0' },
              '100%': { opacity: '1' },
            },
            slideUp: {
              '0%': { opacity: '0', transform: 'translateY(10px)' },
              '100%': { opacity: '1', transform: 'translateY(0)' },
            }
          },
          "fontFamily":"""
        content = content.replace('"fontFamily":', injection)

    # 4. Add custom CSS styles for glass-panel and scrollbar
    if ".glass-panel" not in content:
        style_injection = """
    /* Custom Scrollbar for a cleaner look */
    ::-webkit-scrollbar { width: 6px; height: 6px; }
    ::-webkit-scrollbar-track { background: transparent; }
    ::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 10px; }
    ::-webkit-scrollbar-thumb:hover { background: #94a3b8; }
    .hide-scrollbar::-webkit-scrollbar { display: none; }
    .hide-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }

    .glass-panel {
        background: rgba(255, 255, 255, 0.9);
        backdrop-filter: blur(10px);
        -webkit-backdrop-filter: blur(10px);
    }
    html.dark .glass-panel {
        background: rgba(17, 20, 22, 0.9);
    }
"""
        content = content.replace('/* === DARK MODE === */', style_injection + '\n    /* === DARK MODE === */')

    # 5. Header glass-panel
    header_pattern = re.compile(r'<header class="h-\[72px\] fixed top-0 right-0 left-0 lg:left-\[260px\] bg-surface-container-lowest')
    content = header_pattern.sub('<header class="h-[72px] fixed top-0 right-0 left-0 lg:left-[260px] glass-panel', content)

    # 6. Sidebar shadow
    sidebar_pattern = re.compile(r'<aside id="sidebar" class="w-\[260px\] h-screen fixed left-0 top-0 bg-surface-container-lowest shadow-\[0px_4px_12px_rgba\(0,0,0,0.05\)\] shadow-sm')
    content = sidebar_pattern.sub('<aside id="sidebar" class="w-[260px] h-screen fixed left-0 top-0 bg-surface-container-lowest shadow-soft', content)

    # 7. Sidebar links hover effect and active effect
    # We will look for <li class="bg-primary/10 border-l-4 border-primary"> to identify the active tab.
    # Replace the <a> inside it to the new active style.
    # The active <a> currently has class="flex items-center gap-stack-md px-container-padding py-stack-md text-primary font-bold transition-colors cursor-pointer active:scale-95 duration-200"
    active_a_pattern = re.compile(r'(<li class="bg-primary/10 border-l-4 border-primary">\s*<a class=")([^"]+)(" href="[^"]+">)')
    new_active_a_class = r'\1flex items-center gap-stack-md px-container-padding py-stack-md bg-primary text-white shadow-md shadow-primary/30 font-semibold relative overflow-hidden group cursor-pointer active:scale-95 duration-200\3'
    content = active_a_pattern.sub(new_active_a_class, content)

    # Also for the active icon, we change its color from text-primary to white, since the bg is primary now.
    active_icon_pattern = re.compile(r'(<li class="bg-primary/10 border-l-4 border-primary">.*?<span class="material-symbols-outlined )text-primary')
    content = active_icon_pattern.sub(r'\1text-white', content)
    
    # Add the glow element to active icon
    content = content.replace('<span class="material-symbols-outlined text-white"', '<div class="absolute inset-0 bg-white/20 translate-x-[-100%] group-hover:translate-x-[100%] transition-transform duration-500 ease-in-out"></div>\n<span class="material-symbols-outlined text-white"')

    # Inactive links
    inactive_a_pattern = re.compile(r'(<li class="">\s*<a class=")([^"]+)(" href="[^"]+">)')
    new_inactive_a_class = r'\1flex items-center gap-stack-md px-container-padding py-stack-md text-on-surface-variant hover:bg-surface-variant hover:text-primary transition-all font-medium cursor-pointer active:scale-95 duration-200 group\3'
    content = inactive_a_pattern.sub(new_inactive_a_class, content)
    
    # Add scale animation to inactive icons
    content = content.replace('<span class="material-symbols-outlined">', '<span class="material-symbols-outlined transition-transform group-hover:scale-110">')

    # 8. Primary Buttons
    # Replace bg-primary text-on-primary / bg-primary text-white -> gradient
    # Exclude sidebar active items we just modified (they have text-white but we can distinguish by flex items-center)
    # Actually, simpler: replace general buttons
    btn_pattern1 = re.compile(r'bg-primary\s+hover:bg-primary-container\s+text-on-primary')
    btn_new1 = 'bg-gradient-to-r from-primary to-primary-hover text-white shadow-sm hover:shadow-md hover:shadow-primary/40 transition-all active:scale-[0.98] overflow-hidden group'
    content = btn_pattern1.sub(btn_new1, content)

    btn_pattern2 = re.compile(r'bg-primary\s+text-on-primary\s+hover:opacity-90')
    btn_new2 = 'bg-gradient-to-r from-primary to-primary-hover text-white shadow-sm hover:shadow-md hover:shadow-primary/40 transition-all active:scale-[0.98]'
    content = btn_pattern2.sub(btn_new2, content)
    
    btn_pattern3 = re.compile(r'bg-primary\s+text-white\s+hover:opacity-90')
    btn_new3 = 'bg-gradient-to-r from-primary to-primary-hover text-white shadow-sm hover:shadow-md hover:shadow-primary/40 transition-all active:scale-[0.98]'
    content = btn_pattern3.sub(btn_new3, content)

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

print("Admin UI synced!")
