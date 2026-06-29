import os
import re

directory = "/home/nhan/Desktop/src/main/webapp"

# Regex pattern to match various spacing versions of the .badge class with border-radius: 9999px or similar capsule rounding
badge_pattern = re.compile(
    r'\.badge\s*\{\s*display\s*:\s*inline-flex\s*;\s*align-items\s*:\s*center\s*;\s*padding\s*:\s*3px\s*9px\s*;\s*border-radius\s*:\s*9999px\s*;\s*font-size\s*:\s*11px\s*;\s*font-weight\s*:\s*600\s*;\s*\}',
    re.IGNORECASE
)

badge_pattern_spaced = re.compile(
    r'\.badge\s*\{\s*display\s*:\s*inline-flex\s*;\s*align-items\s*:\s*center\s*;\s*padding\s*:\s*3\s*px\s*9\s*px\s*;\s*border-radius\s*:\s*9999\s*px\s*;\s*font-size\s*:\s*11\s*px\s*;\s*font-weight\s*:\s*600\s*;\s*\}',
    re.IGNORECASE
)

# A broader, simpler regex to match any .badge rule containing border-radius: 9999px or 99px and replace it with border-radius: 8px
def fix_badge_style(content):
    # Match display: inline-flex (or inline-block), padding, border-radius: 9999px or similar
    # We want to replace padding: 3px 9px; with padding: 4px 10px; and border-radius: 9999px (or 99px) with 8px.
    # Let's match the exact patterns first:
    
    # Pattern 1: .badge { display:inline-flex;align-items:center;padding:3px 9px;border-radius:9999px;font-size:11px;font-weight:600; }
    # Pattern 2: .badge { display: inline-flex; align-items: center; padding: 3px 9px; border-radius: 9999px; font-size: 11px; font-weight: 600; }
    
    modified = False
    
    # Standard replacement for compact version
    p1 = '.badge { display:inline-flex;align-items:center;padding:3px 9px;border-radius:9999px;font-size:11px;font-weight:600; }'
    r1 = '.badge { display:inline-flex;align-items:center;padding:4px 10px;border-radius:8px;font-size:11px;font-weight:600; }'
    if p1 in content:
        content = content.replace(p1, r1)
        modified = True
        
    p2 = '.badge { display: inline-flex; align-items: center; padding: 3px 9px; border-radius: 9999px; font-size: 11px; font-weight: 600; }'
    r2 = '.badge { display: inline-flex; align-items: center; padding: 4px 10px; border-radius: 8px; font-size: 11px; font-weight: 600; }'
    if p2 in content:
        content = content.replace(p2, r2)
        modified = True
        
    # Let's handle any other spacing combinations by doing a regex replacement
    # We find .badge { ... } and if it contains border-radius: 9999px, we replace border-radius: 9999px with border-radius: 8px
    # and padding: 3px 9px with padding: 4px 10px.
    
    # We can search for .badge rule
    pattern = r'(\.badge\s*\{[^}]*\})'
    def repl(match):
        rule = match.group(1)
        if '9999px' in rule or '99px' in rule:
            rule = re.sub(r'border-radius\s*:\s*(9999px|99px|9999\s*px|99\s*px)', 'border-radius:8px', rule)
            rule = re.sub(r'padding\s*:\s*(3px\s*9px|3\s*px\s*9\s*px)', 'padding:4px 10px', rule)
        return rule
        
    new_content, count = re.subn(pattern, repl, content)
    if count > 0 and new_content != content:
        content = new_content
        modified = True
        
    return content, modified

for root, dirs, files in os.walk(directory):
    for file in files:
        if file.endswith(".jsp"):
            filepath = os.path.join(root, file)
            with open(filepath, "r", encoding="utf-8") as f:
                content = f.read()
            
            new_content, modified = fix_badge_style(content)
            if modified:
                with open(filepath, "w", encoding="utf-8") as f:
                    f.write(new_content)
                print(f"Updated badge style in {filepath}")
