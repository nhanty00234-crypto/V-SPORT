import os
import re

directory = r"d:\DATN\DATN_TheBigSize\FE\LeTan"

# The updated head contents (tailwind config + style + animate.css)
new_head_content = """<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet">
<!-- Animate.css for subtle entrance animations -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/animate.css/4.1.1/animate.min.css"/>
<script id="tailwind-config">
    tailwind.config = {
      darkMode: "class",
      theme: {
        extend: {
          colors: {
            primary: "#f97316",
            "primary-hover": "#ea580c",
            "on-primary": "#ffffff",
            "primary-container": "#ffedd5",
            "on-primary-container": "#9a3412",
            background: "#f8fafc", /* slightly off-white for better contrast */
            "on-background": "#1c1917",
            surface: "#ffffff",
            "on-surface": "#1c1917",
            "surface-variant": "#f1f5f9",
            "on-surface-variant": "#475569",
            outline: "#94a3b8",
            "outline-variant": "#cbd5e1",
            error: "#ef4444",
            success: "#22c55e",
          },
          fontFamily: {
            sans: ["Inter", "sans-serif"],
          },
          boxShadow: {
            'soft': '0 4px 20px -2px rgba(0, 0, 0, 0.05)',
            'floating': '0 10px 40px -10px rgba(0,0,0,0.08)',
            'glass': 'inset 0 2px 4px 0 rgba(255, 255, 255, 0.3)',
          },
          animation: {
            'fade-in': 'fadeIn 0.3s ease-out',
            'slide-up': 'slideUp 0.4s ease-out forwards',
          },
          keyframes: {
            fadeIn: {
              '0%': { opacity: '0' },
              '100%': { opacity: '1' },
            },
            slideUp: {
              '0%': { opacity: '0', transform: 'translateY(10px)' },
              '100%': { opacity: '1', transform: 'translateY(0)' },
            }
          }
        }
      }
    }
</script>
<style>
    body { font-family: 'Inter', sans-serif; }
    .material-symbols-outlined { font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24; }
    
    /* Custom Scrollbar for a cleaner look */
    ::-webkit-scrollbar { width: 6px; height: 6px; }
    ::-webkit-scrollbar-track { background: transparent; }
    ::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 10px; }
    ::-webkit-scrollbar-thumb:hover { background: #94a3b8; }

    /* Hide scrollbar for categories but keep functionality */
    .hide-scrollbar::-webkit-scrollbar { display: none; }
    .hide-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }

    /* Dark Mode Tweaks */
    html.dark body { background-color: #1c1917; color: #f5f5f4; }
    html.dark .bg-surface { background-color: #292524; }
    html.dark .bg-background { background-color: #1c1917; }
    html.dark .border-outline-variant { border-color: #44403c; }
    html.dark .text-on-surface { color: #f5f5f4; }
    html.dark .text-on-surface-variant { color: #a8a29e; }
    html.dark ::-webkit-scrollbar-thumb { background: #57534e; }

    .glass-panel {
        background: rgba(255, 255, 255, 0.9);
        backdrop-filter: blur(10px);
        -webkit-backdrop-filter: blur(10px);
    }
    html.dark .glass-panel {
        background: rgba(41, 37, 36, 0.9);
    }
</style>"""

new_sidebar_template = """<!-- SideNavBar -->
<aside id="sidebar" class="w-[260px] h-screen bg-surface border-r border-outline-variant z-30 flex flex-col py-6 transition-transform duration-300 hidden lg:flex shadow-soft fixed left-0 top-0">
    <div class="px-6 mb-8 flex items-center justify-between">
        <div>
            <h1 class="text-3xl font-bold text-primary flex items-center gap-2 tracking-tight">
                <span class="material-symbols-outlined text-[32px] text-primary">sports_tennis</span>
                V-SPORT
            </h1>
            <p class="text-xs text-on-surface-variant mt-1.5 font-medium uppercase tracking-wider">Lễ Tân / Thu Ngân</p>
        </div>
    </div>
    <nav class="flex-1 overflow-y-auto px-4">
        <ul class="flex flex-col gap-1.5">
            <li>
                <a class="{class_dashboard}" href="Dashboard.html">
                    {icon_dashboard}
                    Tổng quan
                </a>
            </li>
            <li>
                <a class="{class_lich}" href="LichDatSan.html">
                    {icon_lich}
                    Lịch đặt sân
                </a>
            </li>
            <li>
                <a class="{class_pos}" href="POS.html">
                    {icon_pos}
                    Bán hàng (POS)
                </a>
            </li>
            <li>
                <a class="{class_hoadon}" href="HoaDon.html">
                    {icon_hoadon}
                    Hóa đơn & Hoàn tiền
                </a>
            </li>
            <li>
                <a class="{class_khach}" href="KhachHang.html">
                    {icon_khach}
                    Khách hàng
                </a>
            </li>
            <li>
                <a class="{class_giuxe}" href="GiuXe.html">
                    {icon_giuxe}
                    Quản lý giữ xe
                </a>
            </li>
        </ul>
    </nav>
</aside>"""

active_class = "flex items-center gap-3 px-4 py-3 rounded-xl bg-primary text-white shadow-md shadow-primary/30 font-semibold relative overflow-hidden group"
inactive_class = "flex items-center gap-3 px-4 py-3 rounded-xl text-on-surface-variant hover:bg-surface-variant hover:text-primary transition-all font-medium"

active_icon = '<div class="absolute inset-0 bg-white/20 translate-x-[-100%] group-hover:translate-x-[100%] transition-transform duration-500 ease-in-out"></div>\n<span class="material-symbols-outlined" style="font-variation-settings: \'FILL\' 1;">{icon_name}</span>'
inactive_icon = '<span class="material-symbols-outlined transition-transform group-hover:scale-110">{icon_name}</span>'

icons = {
    'dashboard': 'dashboard',
    'lich': 'calendar_month',
    'pos': 'point_of_sale',
    'hoadon': 'receipt_long',
    'khach': 'group',
    'giuxe': 'local_parking'
}

for filename in ['Dashboard.html', 'GiuXe.html', 'HoaDon.html', 'KhachHang.html', 'LichDatSan.html']:
    filepath = os.path.join(directory, filename)
    if not os.path.exists(filepath): continue
    
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 1. Replace head content
    head_pattern = re.compile(r'<link href="https://fonts.googleapis.com/css2\?family=Inter.*?</style>', re.DOTALL)
    content = head_pattern.sub(new_head_content, content)
    
    # 2. Replace sidebar
    # Determine which tab is active
    is_dashboard = 'Dashboard' in filename
    is_lich = 'Lich' in filename
    is_pos = 'POS' in filename
    is_hoadon = 'HoaDon' in filename
    is_khach = 'KhachHang' in filename
    is_giuxe = 'GiuXe' in filename
    
    sidebar_html = new_sidebar_template.format(
        class_dashboard=active_class if is_dashboard else inactive_class,
        class_lich=active_class if is_lich else inactive_class,
        class_pos=active_class if is_pos else inactive_class,
        class_hoadon=active_class if is_hoadon else inactive_class,
        class_khach=active_class if is_khach else inactive_class,
        class_giuxe=active_class if is_giuxe else inactive_class,
        icon_dashboard=active_icon.format(icon_name=icons['dashboard']) if is_dashboard else inactive_icon.format(icon_name=icons['dashboard']),
        icon_lich=active_icon.format(icon_name=icons['lich']) if is_lich else inactive_icon.format(icon_name=icons['lich']),
        icon_pos=active_icon.format(icon_name=icons['pos']) if is_pos else inactive_icon.format(icon_name=icons['pos']),
        icon_hoadon=active_icon.format(icon_name=icons['hoadon']) if is_hoadon else inactive_icon.format(icon_name=icons['hoadon']),
        icon_khach=active_icon.format(icon_name=icons['khach']) if is_khach else inactive_icon.format(icon_name=icons['khach']),
        icon_giuxe=active_icon.format(icon_name=icons['giuxe']) if is_giuxe else inactive_icon.format(icon_name=icons['giuxe'])
    )
    
    sidebar_pattern = re.compile(r'<!-- SideNavBar -->\s*<aside id="sidebar".*?</aside>', re.DOTALL)
    content = sidebar_pattern.sub(sidebar_html, content)
    
    # 3. Update header styling (inject glass-panel, update profile picture)
    header_pattern = re.compile(r'<header class="h-\[72px\].*?">')
    header_match = header_pattern.search(content)
    if header_match:
        old_header_tag = header_match.group(0)
        # replace bg-surface-container-lowest with glass-panel bg-surface/80
        new_header_tag = old_header_tag.replace('bg-surface-container-lowest', 'glass-panel')
        content = content.replace(old_header_tag, new_header_tag)
        
    # Profile update
    profile_pattern = re.compile(r'<div class="relative group cursor-pointer flex items-center gap-2 hover:bg-surface-container px-2 py-1\.5 rounded-lg transition-colors">.*?</div>\s*<span class="material-symbols-outlined text-on-surface-variant">expand_more</span>\s*</div>', re.DOTALL)
    new_profile_html = """<div class="relative group cursor-pointer flex items-center gap-3 hover:bg-surface-variant px-3 py-2 rounded-xl transition-colors">
            <div class="relative">
                <img alt="Profile" class="w-9 h-9 rounded-full object-cover ring-2 ring-primary/20 group-hover:ring-primary/50 transition-all" src="https://ui-avatars.com/api/?name=Le+Tan&background=f97316&color=fff&bold=true">
                <div class="absolute bottom-0 right-0 w-2.5 h-2.5 bg-success rounded-full border-2 border-surface"></div>
            </div>
            <div class="hidden sm:block text-left">
                <p class="text-sm font-bold text-on-surface leading-none">Nguyễn Văn A</p>
                <p class="text-xs text-on-surface-variant mt-1">Lễ Tân</p>
            </div>
            <span class="material-symbols-outlined text-on-surface-variant group-hover:text-primary transition-colors">expand_more</span>
        </div>"""
    content = profile_pattern.sub(new_profile_html, content)

    # Convert typical buttons
    btn_pattern = re.compile(r'bg-primary hover:bg-orange-600 text-white font-medium text-sm px-4 py-2 rounded-lg shadow-sm flex items-center gap-2 transition-colors')
    new_btn = 'relative bg-gradient-to-r from-primary to-primary-hover text-white font-bold text-sm px-5 py-2.5 rounded-xl hover:shadow-lg hover:shadow-primary/40 transition-all active:scale-[0.98] overflow-hidden group flex items-center gap-2'
    content = content.replace('bg-primary hover:bg-orange-600 text-white font-medium text-sm px-4 py-2 rounded-lg shadow-sm flex items-center gap-2 transition-colors', new_btn)

    # Write back
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

print("Sync completed!")
