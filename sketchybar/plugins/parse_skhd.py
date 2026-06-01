#!/usr/bin/env python3
import os
import re
import subprocess

CONFIG_DIR = os.environ.get("CONFIG_DIR", os.path.expanduser("~/.config/sketchybar"))
SKHDRC_PATH = os.path.expanduser("~/.config/skhd/skhdrc")

# Source colors from colors.sh
def get_colors():
    colors = {
        "HONOR_GOLD": "0xfff1c40f",
        "WHITE": "0xffffffff",
        "SAPPHIRE": "0xff2980b9",
        "RADIANT_GOLD": "0xfff39c12",
        "GREY": "0xff7f8c8d"
    }
    colors_sh = os.path.expanduser("~/.config/sketchybar/colors.sh")
    if os.path.exists(colors_sh):
        with open(colors_sh, "r") as f:
            for line in f:
                match = re.match(r'export\s+(\w+)=\"?(0x[0-9a-fA-F]+|[#a-fA-F0-9]+)\"?', line)
                if match:
                    colors[match.group(1)] = match.group(2)
    return colors

COLORS = get_colors()

def format_keys(key_str):
    k = key_str.strip().lower()
    # Replace modifiers
    replacements = [
        ("hyper", "✦"),
        ("ctrl", "⌃"),
        ("alt", "⌥"),
        ("opt", "⌥"),
        ("cmd", "⌘"),
        ("shift", "⇧"),
        ("lshift", "⇧"),
        ("rshift", "⇧"),
        ("0x2b", ","),
        ("+", " "),
        ("-", " "),
    ]
    for old, new in replacements:
        k = k.replace(old, new)
    
    # Capitalize single letters and join nicely
    tokens = [t.upper() if len(t) == 1 else t.capitalize() for t in k.split()]
    return " + ".join(tokens)

def parse_skhdrc():
    if not os.path.exists(SKHDRC_PATH):
        return []
    
    sections = []
    current_section = "General"
    current_comments = []
    
    with open(SKHDRC_PATH, "r") as f:
        lines = f.readlines()
        
    i = 0
    while i < len(lines):
        line = lines[i].strip()
        
        # Section headers
        if line.startswith("#") and "===" in line:
            if i + 1 < len(lines):
                next_line = lines[i+1].strip()
                if next_line.startswith("#") and not "===" in next_line:
                    current_section = next_line.lstrip("#").strip()
                    if i + 2 < len(lines) and "=====" in lines[i+2]:
                        i += 2
                    else:
                        i += 1
            current_comments = []
            i += 1
            continue
            
        if not line:
            current_comments = []
            i += 1
            continue
            
        if line.startswith("#"):
            comment_text = line.lstrip("#").strip()
            if comment_text and not comment_text.startswith("===") and not comment_text.startswith("---"):
                current_comments.append(comment_text)
            i += 1
            continue
            
        # Parse binding: key : command
        if ":" in line and not line.startswith("#"):
            parts = line.split(":", 1)
            keys = parts[0].strip()
            cmd = parts[1].strip()
            
            description = " ".join(current_comments) if current_comments else ""
            
            sections.append({
                "section": current_section,
                "keys": keys,
                "formatted_keys": format_keys(keys),
                "description": description,
                "command": cmd
            })
            current_comments = []
            
        i += 1
        
    return sections

def club_bindings(bindings):
    clubbed = []
    i = 0
    while i < len(bindings):
        b = bindings[i]
        
        # 1. Launcher clubbing
        if "launcher.sh" in b["command"]:
            run = [b]
            j = i + 1
            while j < len(bindings) and "launcher.sh" in bindings[j]["command"]:
                run.append(bindings[j])
                j += 1
            
            if len(run) > 1:
                # E.g. hyper - c, hyper - t -> ✦ + C/T/B/O/F
                keys_list = [r["keys"].split("-")[-1].strip().upper() for r in run]
                apps_list = [re.search(r'"([^"]+)"', r["command"]).group(1) for r in run if re.search(r'"([^"]+)"', r["command"])]
                
                clubbed.append({
                    "section": b["section"],
                    "formatted_keys": "✦ + " + "/".join(keys_list),
                    "description": "Focus/Launch (" + "/".join(apps_list) + ")"
                })
                i = j
                continue

        # 2. Scratchpad clubbing
        if "scratchpad.py" in b["command"]:
            run = [b]
            j = i + 1
            while j < len(bindings) and "scratchpad.py" in bindings[j]["command"]:
                run.append(bindings[j])
                j += 1
            
            if len(run) > 1:
                keys_list = [r["keys"].split("-")[-1].strip().replace("grave", "~") for r in run]
                apps_list = [re.search(r'"([^"]+)"', r["command"]).group(1) for r in run if re.search(r'"([^"]+)"', r["command"])]
                
                clubbed.append({
                    "section": b["section"],
                    "formatted_keys": "✦ + " + "/".join(keys_list),
                    "description": "Toggle (" + "/".join(apps_list) + ")"
                })
                i = j
                continue

        # 3. Vim Focus clubbing
        if "alt -" in b["keys"] and any(x in b["keys"] for x in [" h", " j", " k", " l"]) and "shift" not in b["keys"] and "ctrl" not in b["keys"] and "focus" in b["command"]:
            run = [b]
            j = i + 1
            while j < len(bindings) and "alt -" in bindings[j]["keys"] and any(x in bindings[j]["keys"] for x in [" h", " j", " k", " l"]) and "shift" not in bindings[j]["keys"] and "focus" in bindings[j]["command"]:
                run.append(bindings[j])
                j += 1
            
            if len(run) > 1:
                clubbed.append({
                    "section": b["section"],
                    "formatted_keys": "⌥ + H/J/K/L",
                    "description": "Focus Window (West/South/North/East)"
                })
                i = j
                continue

        # 4. Vim Swap clubbing
        if "shift + alt -" in b["keys"] and any(x in b["keys"] for x in [" h", " j", " k", " l"]) and "swap" in b["command"]:
            run = [b]
            j = i + 1
            while j < len(bindings) and "shift + alt -" in bindings[j]["keys"] and any(x in bindings[j]["keys"] for x in [" h", " j", " k", " l"]) and "swap" in bindings[j]["command"]:
                run.append(bindings[j])
                j += 1
            
            if len(run) > 1:
                clubbed.append({
                    "section": b["section"],
                    "formatted_keys": "⌥ + ⇧ + H/J/K/L",
                    "description": "Swap Window (West/South/North/East)"
                })
                i = j
                continue

        # 5. Vim Warp clubbing
        if "ctrl + alt -" in b["keys"] and any(x in b["keys"] for x in [" h", " j", " k", " l"]) and "warp" in b["command"]:
            run = [b]
            j = i + 1
            while j < len(bindings) and "ctrl + alt -" in bindings[j]["keys"] and any(x in bindings[j]["keys"] for x in [" h", " j", " k", " l"]) and "warp" in bindings[j]["command"]:
                run.append(bindings[j])
                j += 1
            
            if len(run) > 1:
                clubbed.append({
                    "section": b["section"],
                    "formatted_keys": "⌥ + ⌃ + H/J/K/L",
                    "description": "Warp Window (West/South/North/East)"
                })
                i = j
                continue

        # 6. Space range clubbing (e.g. hyper - 1 to hyper - 9, shift + alt - 1 to 10)
        match = re.match(r'^(.*)([-+])\s*([0-9])$', b["keys"])
        if match:
            prefix = match.group(1).strip()
            op = match.group(2)
            
            run = [b]
            j = i + 1
            while j < len(bindings):
                next_match = re.match(r'^(.*)([-+])\s*([0-9])$', bindings[j]["keys"])
                if next_match and next_match.group(1).strip() == prefix and next_match.group(2) == op:
                    run.append(bindings[j])
                    j += 1
                else:
                    break
            
            if len(run) > 2:
                first_num = run[0]["keys"].split(op)[-1].strip()
                last_num = run[-1]["keys"].split(op)[-1].strip()
                
                desc = b["description"]
                desc = re.sub(r'\b' + first_num + r'\b', f"{first_num}-{last_num}", desc)
                desc = re.sub(r'[sS]pace \d+ to \d+', f"Space {first_num}-{last_num}", desc)
                if not desc:
                    desc = f"Action for spaces {first_num}-{last_num}"
                
                clubbed.append({
                    "section": b["section"],
                    "formatted_keys": f"{format_keys(prefix)} + [{first_num}-{last_num}]",
                    "description": desc
                })
                i = j
                continue

        clubbed.append(b)
        i += 1
        
    return clubbed

def main():
    bindings = parse_skhdrc()
    clubbed = club_bindings(bindings)
    
    subprocess.run(["sketchybar", "--remove", "/cheatsheet\\.item\\..*/"])
    
    commands = []
    counter = 0
    current_section = None
    
    for b in clubbed:
        if b["section"] != current_section:
            current_section = b["section"]
            counter += 1
            commands.extend([
                "--add", "item", f"cheatsheet.item.sec_{counter}", "popup.cheatsheet",
                "--set", f"cheatsheet.item.sec_{counter}",
                f"icon={current_section.upper()}",
                "icon.font=JetBrainsMono Nerd Font:Bold:10.0",
                "icon.color=" + COLORS.get("RADIANT_GOLD", "0xfff39c12"),
                "label.drawing=off",
                "padding_left=10",
                "padding_right=10",
                "padding_top=5",
                "padding_bottom=0",
                "background.drawing=off"
            ])
            
        counter += 1
        desc = b["description"] if b.get("description") else b.get("keys", "")
        commands.extend([
            "--add", "item", f"cheatsheet.item.{counter}", "popup.cheatsheet",
            "--set", f"cheatsheet.item.{counter}",
            f"icon={b['formatted_keys']}",
            "icon.width=115",
            "icon.color=" + COLORS.get("HONOR_GOLD", "0xfff1c40f"),
            "icon.font=JetBrainsMono Nerd Font:Bold:12.0",
            f"label={desc}",
            "label.color=" + COLORS.get("WHITE", "0xffffffff"),
            "label.font=JetBrainsMono Nerd Font:Regular:12.0",
            "padding_left=15",
            "padding_top=2",
            "padding_bottom=2"
        ])
        
    if commands:
        subprocess.run(["sketchybar"] + commands)

if __name__ == "__main__":
    main()
