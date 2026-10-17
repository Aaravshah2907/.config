import json
import re
from pathlib import Path

AEROSPACE_PATH = Path("/Users/aaravshah2975/.config/aerospace/aerospace.toml")
KARABINER_PATH = Path("/Users/aaravshah2975/.config/karabiner/karabiner.json")

def format_aero_key(k):
    # Convert 'alt-enter' -> '⌥ ↵', 'ctrl-alt-b' -> '⌃ ⌥ B'
    parts = k.split("-")
    out = []
    for p in parts:
        p_lower = p.lower()
        if p_lower == "alt": out.append("⌥")
        elif p_lower == "ctrl": out.append("⌃")
        elif p_lower == "shift": out.append("⇧")
        elif p_lower == "cmd": out.append("⌘")
        elif p_lower == "enter": out.append("↵")
        elif p_lower == "tab": out.append("⇥")
        elif p_lower == "backtick": out.append("`")
        elif p_lower == "slash": out.append("/")
        elif p_lower == "comma": out.append(",")
        elif p_lower == "period": out.append(".")
        elif p_lower == "minus": out.append("-")
        elif p_lower == "equal": out.append("=")
        elif p_lower == "semicolon": out.append(";")
        elif p_lower == "esc": out.append("⎋")
        elif p_lower == "backspace": out.append("⌫")
        elif p_lower == "space": out.append("Space")
        else: out.append(p.upper() if len(p) == 1 else p.capitalize())
    return " ".join(out)

def get_aero_shortcuts():
    items = []
    if not AEROSPACE_PATH.exists():
        return items

    text = AEROSPACE_PATH.read_text()
    
    current_mode = "main"
    for line in text.splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
            
        if line == "[mode.main.binding]":
            current_mode = "main"
            continue
        elif line == "[mode.resize.binding]":
            current_mode = "resize"
            continue
        elif line == "[mode.service.binding]":
            current_mode = "service"
            continue
        elif line.startswith("["):
            current_mode = "other"
            continue

        if current_mode in ("main", "resize", "service") and "=" in line:
            key_part, val_part = line.split("=", 1)
            raw_key = key_part.strip()
            val_part = val_part.strip()

            # Parse action string or array
            actions = []
            if val_part.startswith("["):
                try:
                    # Clean json-like array
                    clean_arr = re.sub(r"'", '"', val_part)
                    actions = json.loads(clean_arr)
                except:
                    actions = [val_part]
            else:
                actions = [val_part.strip("'\"")]

            first_act = actions[0] if actions else ""
            
            # Categorize and humanize
            desc = first_act
            cat = "AeroSpace: Windows"
            cmd = ""

            # Check for shell exec
            if "open -na Ghostty" in first_act and "title" not in first_act:
                desc = "Launch Ghostty (New Window)"
                cat = "Apps & Launchers"
                cmd = "open -na Ghostty"
            elif "Quick Terminal" in first_act:
                desc = "Floating Scratchpad Terminal"
                cat = "Apps & Launchers"
                cmd = "open -na Ghostty --args --title='Quick Terminal'"
            elif first_act.startswith("workspace "):
                ws = first_act.split()[1]
                desc = f"Switch to Workspace {ws}"
                cat = "AeroSpace: Workspaces"
                cmd = f"/opt/homebrew/bin/aerospace workspace {ws}"
            elif first_act.startswith("move-node-to-workspace"):
                ws = first_act.split()[1]
                desc = f"Move Window to Workspace {ws}"
                cat = "AeroSpace: Workspaces"
                cmd = f"/opt/homebrew/bin/aerospace move-node-to-workspace {ws}"
            elif "focus left" in first_act: desc, cmd = "Focus Window Left", "/opt/homebrew/bin/aerospace focus left"
            elif "focus down" in first_act: desc, cmd = "Focus Window Down", "/opt/homebrew/bin/aerospace focus down"
            elif "focus up" in first_act: desc, cmd = "Focus Window Up", "/opt/homebrew/bin/aerospace focus up"
            elif "focus right" in first_act: desc, cmd = "Focus Window Right", "/opt/homebrew/bin/aerospace focus right"
            elif "move left" in first_act: desc, cmd = "Move Window Left", "/opt/homebrew/bin/aerospace move left"
            elif "move down" in first_act: desc, cmd = "Move Window Down", "/opt/homebrew/bin/aerospace move down"
            elif "move up" in first_act: desc, cmd = "Move Window Up", "/opt/homebrew/bin/aerospace move up"
            elif "move right" in first_act: desc, cmd = "Move Window Right", "/opt/homebrew/bin/aerospace move right"
            elif "join-with left" in first_act: desc, cmd = "Join Window Left (Warp)", "/opt/homebrew/bin/aerospace join-with left"
            elif "join-with down" in first_act: desc, cmd = "Join Window Down (Warp)", "/opt/homebrew/bin/aerospace join-with down"
            elif "join-with up" in first_act: desc, cmd = "Join Window Up (Warp)", "/opt/homebrew/bin/aerospace join-with up"
            elif "join-with right" in first_act: desc, cmd = "Join Window Right (Warp)", "/opt/homebrew/bin/aerospace join-with right"
            elif "layout tiles horizontal vertical" in first_act: desc, cmd = "Toggle Split (Horizontal / Vertical)", "/opt/homebrew/bin/aerospace layout tiles horizontal vertical"
            elif "layout accordion" in first_act: desc, cmd = "Toggle Accordion Layout", "/opt/homebrew/bin/aerospace layout accordion horizontal vertical"
            elif "layout tiles accordion" in first_act: desc, cmd = "Toggle Tiles / Accordion", "/opt/homebrew/bin/aerospace layout tiles accordion"
            elif "layout horizontal" in first_act: desc, cmd = "Explicit Horizontal Split", "/opt/homebrew/bin/aerospace layout horizontal"
            elif "layout vertical" in first_act: desc, cmd = "Explicit Vertical Split", "/opt/homebrew/bin/aerospace layout vertical"
            elif "fullscreen" in first_act: desc, cmd = "Toggle Fullscreen", "/opt/homebrew/bin/aerospace fullscreen"
            elif "layout floating tiling" in first_act: desc, cmd = "Toggle Floating / Tiling", "/opt/homebrew/bin/aerospace layout floating tiling"
            elif "balance-sizes" in first_act: desc, cmd = "Balance Window Sizes", "/opt/homebrew/bin/aerospace balance-sizes"
            elif "workspace-back-and-forth" in first_act: desc, cmd = "Workspace Back and Forth", "/opt/homebrew/bin/aerospace workspace-back-and-forth"
            elif "move-workspace-to-monitor" in first_act: desc, cmd = "Move Workspace to Next Monitor", "/opt/homebrew/bin/aerospace move-workspace-to-monitor --wrap-around next"
            elif "mode resize" in first_act: desc, cat, cmd = "Enter Resize Mode", "AeroSpace: Modes", "/opt/homebrew/bin/aerospace mode resize"
            elif "mode service" in first_act: desc, cat, cmd = "Enter Service Mode", "AeroSpace: Modes", "/opt/homebrew/bin/aerospace mode service"
            elif "reload-config" in first_act: desc, cat, cmd = "Reload AeroSpace Config", "AeroSpace: Modes", "/opt/homebrew/bin/aerospace reload-config"
            elif "flatten-workspace-tree" in first_act: desc, cat, cmd = "Flatten Workspace Tree", "AeroSpace: Modes", "/opt/homebrew/bin/aerospace flatten-workspace-tree"
            elif "close-all-windows-but-current" in first_act: desc, cat, cmd = "Close All Other Windows", "AeroSpace: Modes", "/opt/homebrew/bin/aerospace close-all-windows-but-current"
            elif "close" == first_act: desc, cmd = "Close Window", "/opt/homebrew/bin/aerospace close"

            prefix = ""
            if current_mode == "resize":
                prefix = "[Resize] "
                cat = "AeroSpace: Modes"
            elif current_mode == "service":
                prefix = "[Service] "
                cat = "AeroSpace: Modes"

            items.append({
                "keys": format_aero_key(raw_key),
                "action": prefix + desc,
                "category": cat,
                "app": "AeroSpace",
                "command": cmd or f"/opt/homebrew/bin/aerospace {first_act}",
                "source": "shell"
            })
    return items

def get_karabiner_shortcuts():
    items = []
    if not KARABINER_PATH.exists():
        return items

    with open(KARABINER_PATH) as f:
        data = json.load(f)

    rules = data.get("profiles", [{}])[0].get("complex_modifications", {}).get("rules", [])
    
    # 1. Dual Role Keys
    items.append({
        "keys": "Caps Lock (Tap / Hold)",
        "action": "Tap: Escape | Hold: Hyper Mode",
        "category": "Hyper: Dual-Role",
        "app": "Karabiner",
        "command": "",
        "source": "shell"
    })
    items.append({
        "keys": "Right ⌘ (Tap / Hold)",
        "action": "Tap: Spotlight Search | Hold: Hyper Mode",
        "category": "Hyper: Dual-Role",
        "app": "Karabiner",
        "command": "open -a 'Spotlight'",
        "source": "shell"
    })
    items.append({
        "keys": "Right Ctrl (Pebble)",
        "action": "Tap: Escape | Hold: Hyper Mode",
        "category": "Hyper: Dual-Role",
        "app": "Karabiner",
        "command": "",
        "source": "shell"
    })

    # Sublayers definitions with descriptions
    sublayer_defs = {
        "Hyper Sublayer O (Open Applications)": {
            "h": ("Open Helium (Default Profile)", 'open -na "/Applications/Helium.app" --args --profile-directory="Default"'),
            "t": ("Open Ghostty (New Window)", "open -na Ghostty"),
            "v": ("Open VLC Player", 'open -a "VLC"'),
            "c": ("Open VS Code / Cursor", 'open -a "Visual Studio Code"'),
            "o": ("Open Obsidian", 'open -a "Obsidian"'),
            "s": ("Open Spotify", 'open -a "Spotify"'),
            "f": ("Open Finder", "open ~"),
            "a": ("Open Activity Monitor", 'open -a "Activity Monitor"'),
        },
        "Hyper Sublayer B (Browse Web Jumps)": {
            "g": ("Browse: GitHub", 'open -na "/Applications/Helium.app" --args --profile-directory="Default" "https://github.com"'),
            "c": ("Browse: Codeforces", 'open -na "/Applications/Helium.app" --args --profile-directory="Default" "https://codeforces.com"'),
            "m": ("Browse: Gmail", 'open -na "/Applications/Helium.app" --args --profile-directory="Default" "https://mail.google.com"'),
            "y": ("Browse: YouTube", 'open -na "/Applications/Helium.app" --args --profile-directory="Default" "https://youtube.com"'),
        },
        "Hyper Sublayer S (System & Workspace Control)": {
            "d": ("Toggle Do Not Disturb", "~/.local/bin/toggle_dnd.sh"),
            "x": ("Lock Screen", "~/.local/bin/lock-screen.sh"),
            "s": ("Study Mode", "~/.local/bin/study-mode"),
            "p": ("Panic Mode", "~/.local/bin/panic-mode"),
            "o": ("Screen OCR Text Capture", "screencapture -i -c"),
        },
        "Hyper Sublayer T (Tabs Navigation)": {
            "h": ("Previous Tab", ""),
            "l": ("Next Tab", ""),
            "w": ("Close Tab", ""),
            "t": ("New Tab", ""),
            "r": ("Hard Reload Tab", ""),
            "u": ("Reopen Closed Tab", ""),
            "d": ("Toggle Developer Tools", ""),
        },
        "Hyper Sublayer C (Scratchpads & Tools)": {
            "t": ("Ghostty Todo Scratchpad", 'open -na Ghostty --args --title="Quick Terminal" -e "zsh -l -c todo"'),
            "c": ("Calculator Scratchpad", "open -a Calculator"),
            "f": ("Fuzzy Finder (fv)", "~/.local/bin/fv.sh"),
            "semicolon": ("Control Center", "bash ~/.config/skhd/control_center.sh"),
        }
    }

    sublayer_letters = {"O": "O", "B": "B", "S": "S", "T": "T", "C": "C"}

    for rule in rules:
        desc = rule.get("description", "")
        for sname, mappings in sublayer_defs.items():
            if sname in desc:
                letter = desc.split()[2]
                cat = f"Hyper Sublayer {letter}"
                for manip in rule.get("manipulators", []):
                    k = manip.get("from", {}).get("key_code", "")
                    if k in mappings:
                        action_name, cmd = mappings[k]
                        disp_k = ";" if k == "semicolon" else k.upper()
                        items.append({
                            "keys": f"Hyper + {letter} > {disp_k}",
                            "action": action_name,
                            "category": cat,
                            "app": "Karabiner",
                            "command": cmd,
                            "source": "shell"
                        })

    # Direct Hyper Nav
    items.extend([
        {"keys": "Hyper + H / J / K / L", "action": "Vim Cursor Navigation (← ↓ ↑ →)", "category": "Hyper: Direct", "app": "Karabiner", "command": "", "source": "shell"},
        {"keys": "Hyper + Y / P", "action": "Word Jump Left / Right", "category": "Hyper: Direct", "app": "Karabiner", "command": "", "source": "shell"},
        {"keys": "Hyper + 0 / $", "action": "Line Start / End", "category": "Hyper: Direct", "app": "Karabiner", "command": "", "source": "shell"},
        {"keys": "Hyper + I / .", "action": "Delete Word Backward / Forward", "category": "Hyper: Direct", "app": "Karabiner", "command": "", "source": "shell"},
        {"keys": "Hyper + M", "action": "Kill Line Forward (Ctrl+K)", "category": "Hyper: Direct", "app": "Karabiner", "command": "", "source": "shell"},
        {"keys": "Hyper + Shift + M", "action": "Delete Line Backward (Cmd+Backspace)", "category": "Hyper: Direct", "app": "Karabiner", "command": "", "source": "shell"},
        {"keys": "Hyper + ← / →", "action": "AeroSpace Workspace Prev / Next", "category": "Hyper: Direct", "app": "Karabiner", "command": "/opt/homebrew/bin/aerospace workspace prev", "source": "shell"},
        {"keys": "Hyper + Q", "action": "AeroSpace Close Window", "category": "Hyper: Direct", "app": "Karabiner", "command": "/opt/homebrew/bin/aerospace close", "source": "shell"},
        {"keys": "Hyper + ?", "action": "Open Shortcut Hub (This Dashboard)", "category": "Hyper: Direct", "app": "Karabiner", "command": "/Users/aaravshah2975/.config/cheatsheet/show-cheatsheet.sh", "source": "shell"},
    ])

    # Pebble Hardware Keys
    items.extend([
        {"keys": "Pebble F11", "action": "Lock Screen (Ctrl+Cmd+Q)", "category": "Pebble Keys", "app": "Karabiner", "command": "~/.local/bin/lock-screen.sh", "source": "shell"},
        {"keys": "Pebble PrintScreen", "action": "Screenshot (Cmd+Shift+5)", "category": "Pebble Keys", "app": "Karabiner", "command": "screencapture -i", "source": "shell"},
        {"keys": "Pebble ScrollLock", "action": "Toggle Do Not Disturb", "category": "Pebble Keys", "app": "Karabiner", "command": "~/.local/bin/toggle_dnd.sh", "source": "shell"},
        {"keys": "Pebble Pause", "action": "Panic Mode", "category": "Pebble Keys", "app": "Karabiner", "command": "~/.local/bin/panic-mode", "source": "shell"},
        {"keys": "Pebble App + A", "action": "Toggle AirDrop", "category": "Pebble Keys", "app": "Karabiner", "command": "~/.local/bin/toggle-airdrop", "source": "shell"},
        {"keys": "Pebble App + L", "action": "Toggle LocalSend", "category": "Pebble Keys", "app": "Karabiner", "command": "~/.local/bin/toggle-localsend", "source": "shell"},
        {"keys": "Pebble App + N", "action": "Toggle NearDrop", "category": "Pebble Keys", "app": "Karabiner", "command": "~/.local/bin/toggle-neardrop", "source": "shell"},
        {"keys": "Pebble NumLock", "action": "Keybee Cockpit", "category": "Pebble Keys", "app": "Karabiner", "command": "~/.local/bin/keybee-status", "source": "shell"},
        {"keys": "Pebble Insert", "action": "Open Shortcut Hub", "category": "Pebble Keys", "app": "Karabiner", "command": "/Users/aaravshah2975/.config/cheatsheet/show-cheatsheet.sh", "source": "shell"},
        {"keys": "Mouse Middle Click", "action": "Tap: Escape | Hold: Mission Control", "category": "Mouse Buttons", "app": "Karabiner", "command": "", "source": "shell"},
        {"keys": "Mouse Button 4", "action": "Tap: Back | Hold: Previous Space", "category": "Mouse Buttons", "app": "Karabiner", "command": "", "source": "shell"},
        {"keys": "Mouse Button 5", "action": "Tap: Forward | Hold: Next Space", "category": "Mouse Buttons", "app": "Karabiner", "command": "", "source": "shell"},
    ])

    return items

def build_all():
    aero = get_aero_shortcuts()
    karabiner = get_karabiner_shortcuts()
    all_shortcuts = aero + karabiner
    print(f"Loaded {len(aero)} AeroSpace shortcuts and {len(karabiner)} Karabiner shortcuts ({len(all_shortcuts)} total).")
    return all_shortcuts

if __name__ == "__main__":
    shortcuts = build_all()
    with open("/tmp/shortcut_db.json", "w") as f:
        json.dump({"global": shortcuts, "apps": {}}, f, indent=2)
    print("Saved to /tmp/shortcut_db.json successfully!")
