import os
import re

directory = r"d:\DATN\DATN_TheBigSize\FE\LeTan"

for filename in ['Dashboard.html', 'GiuXe.html', 'HoaDon.html', 'KhachHang.html', 'LichDatSan.html']:
    filepath = os.path.join(directory, filename)
    if not os.path.exists(filepath): continue
    
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Find elements with bg-primary and text-white, and replace them with gradient, shadow, and active scale
    # We will be careful not to replace the active sidebar item which has a specific group class already.
    # We will target common button classes.
    
    # 1. Update primary solid buttons (e.g., Check-in, Thanh Toán)
    pattern_btn = re.compile(r'bg-primary\s+text-white\s+hover:bg-orange-600\s+transition-colors')
    new_btn = 'bg-gradient-to-r from-primary to-primary-hover text-white shadow-sm hover:shadow-md hover:shadow-primary/40 transition-all active:scale-[0.98]'
    content = pattern_btn.sub(new_btn, content)

    # 2. Update some other hover classes
    pattern_hover_orange = re.compile(r'hover:bg-orange-600')
    new_hover_orange = 'hover:bg-primary-hover active:scale-95 transition-all'
    content = pattern_hover_orange.sub(new_hover_orange, content)

    # 3. Add shadow-sm to standard cards if missing, but maybe they have it already.
    # The surface containers can have glassmorphism if we want.

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

print("Button styles synced!")
