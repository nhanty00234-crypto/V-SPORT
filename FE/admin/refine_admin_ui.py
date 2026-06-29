import os
import re

directory = r"d:\DATN\DATN_TheBigSize\FE\admin"
html_files = [f for f in os.listdir(directory) if f.endswith('.html')]

for filename in html_files:
    filepath = os.path.join(directory, filename)
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Fix the active sidebar item wrapper 
    # Current: <li class="bg-primary/10 border-l-4 border-primary">
    content = content.replace('<li class="bg-primary/10 border-l-4 border-primary">', '<li class="relative">')

    # 2. Fix the icon inside the active sidebar item
    # We find the active <a> which contains "bg-primary text-white" and replace text-primary with text-white inside it.
    # It looks like: <a class="... bg-primary text-white ..."><span class="material-symbols-outlined text-primary"
    active_a_pattern = re.compile(r'(<a[^>]*bg-primary text-white[^>]*>.*?<span[^>]*class="material-symbols-outlined[^"]*)text-primary([^"]*")', re.DOTALL)
    content = active_a_pattern.sub(r'\1text-white\2', content)

    # 3. Enhance <button> tags with bg-primary
    # We find <button class="..."> where the class contains bg-primary
    def replace_button(match):
        full_tag = match.group(0)
        # Only replace if it's a solid bg-primary button (not bg-primary/10)
        if 'bg-primary/10' in full_tag or 'bg-primary/20' in full_tag:
            return full_tag
        
        if 'bg-primary' in full_tag:
            # Replace bg-primary with the gradient and shadow
            new_tag = full_tag.replace('bg-primary', 'bg-gradient-to-r from-primary to-primary-hover shadow-md hover:shadow-lg hover:shadow-primary/40 active:scale-[0.98] transition-all')
            # If text-on-primary is there, it's fine, it maps to white usually, or we replace with text-white
            new_tag = new_tag.replace('text-on-primary', 'text-white')
            return new_tag
        return full_tag

    button_pattern = re.compile(r'<button[^>]*class="[^"]*bg-primary[^"]*"[^>]*>')
    content = button_pattern.sub(replace_button, content)

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

print("Admin UI refined!")
