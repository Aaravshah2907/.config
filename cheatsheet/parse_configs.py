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

TMUX_MD_PATH = Path("/Users/aaravshah2975/.config/tmux/cheatsheet.md")
YAZI_PATH = Path("/Users/aaravshah2975/.config/yazi/keymap.toml")

def get_tmux_shortcuts():
    items = []
    if not TMUX_MD_PATH.exists():
        return items
    try:
        text = TMUX_MD_PATH.read_text(encoding="utf-8")
        current_cat = "Tmux"
        for line in text.splitlines():
            line = line.strip()
            if line.startswith("## "):
                header = line[3:].strip()
                clean_name = re.sub(r"^[^\w]+", "", header).strip()
                current_cat = f"Tmux: {clean_name}" if clean_name else "Tmux"
            elif line.startswith("|") and not line.startswith("| ---"):
                parts = [p.strip() for p in line.split("|")[1:-1]]
                if len(parts) >= 2:
                    key_raw, act_raw = parts[0], parts[1]
                    if key_raw.lower() in ("command", "keybinding", "key", "command / key") or not key_raw:
                        continue
                    clean_keys = key_raw.replace("`", "")
                    clean_act = re.sub(r"\*\*(.*?)\*\*", r"\1", act_raw)
                    items.append({
                        "keys": clean_keys,
                        "action": clean_act,
                        "category": current_cat,
                        "app": "tmux",
                        "command": clean_keys if clean_keys.startswith("t ") or clean_keys in ("todo", "tux") else "",
                        "source": "shell" if clean_keys.startswith("t ") or clean_keys.startswith("tmux ") else "tmux"
                    })
    except Exception as e:
        print(f"Error parsing tmux cheatsheet.md: {e}")
    return items

def get_yazi_shortcuts():
    items = []
    if not YAZI_PATH.exists():
        return items
    try:
        import tomllib
        with open(YAZI_PATH, "rb") as f:
            data = tomllib.load(f)
        for m in data.get("mgr", {}).get("keymap", []):
            on = m.get("on", "")
            if isinstance(on, list):
                keys = " ".join(on)
            else:
                keys = str(on)
            keys = keys.replace("<Space>", "Space").replace("<Esc>", "Esc").replace("<Enter>", "↵").replace("<C-", "⌃ ").replace("<S-", "⇧ ").replace("<A-", "⌥ ").replace(">", "")
            desc = m.get("desc", m.get("run", ""))
            run_cmd = m.get("run", "")
            if isinstance(run_cmd, list):
                run_cmd = "; ".join(run_cmd)
            items.append({
                "keys": keys,
                "action": desc,
                "category": "Yazi File Manager",
                "app": "yazi",
                "command": run_cmd,
                "source": "app"
            })
    except Exception as e:
        print(f"Error parsing yazi shortcuts: {e}")
    return items

def get_ghostty_shortcuts():
    return [
        {"keys": "⌘ T", "action": "New Tab", "category": "Ghostty: Tabs & Windows", "app": "Ghostty", "command": "", "source": "app"},
        {"keys": "⌘ W", "action": "Close Surface / Tab", "category": "Ghostty: Tabs & Windows", "app": "Ghostty", "command": "", "source": "app"},
        {"keys": "⌘ D", "action": "Split Right", "category": "Ghostty: Splits", "app": "Ghostty", "command": "", "source": "app"},
        {"keys": "⌘ ⇧ D", "action": "Split Down", "category": "Ghostty: Splits", "app": "Ghostty", "command": "", "source": "app"},
        {"keys": "⌘ [ / ⌘ ]", "action": "Previous / Next Split", "category": "Ghostty: Splits", "app": "Ghostty", "command": "", "source": "app"},
        {"keys": "⌘ ⇧ ↵", "action": "Toggle Split Zoom", "category": "Ghostty: Splits", "app": "Ghostty", "command": "", "source": "app"},
        {"keys": "⌘ + / ⌘ -", "action": "Increase / Decrease Font Size", "category": "Ghostty: View", "app": "Ghostty", "command": "", "source": "app"},
        {"keys": "⌘ 0", "action": "Reset Font Size", "category": "Ghostty: View", "app": "Ghostty", "command": "", "source": "app"},
        {"keys": "⌘ ⌥ I", "action": "Toggle Terminal Inspector", "category": "Ghostty: Tools", "app": "Ghostty", "command": "", "source": "app"},
        {"keys": "⌘ ⇧ ,", "action": "Reload Configuration", "category": "Ghostty: Tools", "app": "Ghostty", "command": "", "source": "app"},
    ]

def get_neovim_shortcuts():
    return [
        {"keys": "Space f f", "action": "Find Files (Telescope)", "category": "Neovim: Navigation", "app": "nvim", "command": "", "source": "app"},
        {"keys": "Space f g", "action": "Live Grep Workspace", "category": "Neovim: Navigation", "app": "nvim", "command": "", "source": "app"},
        {"keys": "Space e", "action": "Toggle File Tree (Neotree/NvimTree)", "category": "Neovim: Files", "app": "nvim", "command": "", "source": "app"},
        {"keys": "⌃ W h / j / k / l", "action": "Navigate Window Splits", "category": "Neovim: Windows", "app": "nvim", "command": "", "source": "app"},
        {"keys": "⌃ W s / v", "action": "Split Horizontal / Vertical", "category": "Neovim: Windows", "app": "nvim", "command": "", "source": "app"},
        {"keys": "[ b / ] b", "action": "Previous / Next Buffer", "category": "Neovim: Buffers", "app": "nvim", "command": "", "source": "app"},
        {"keys": "Space b d", "action": "Delete / Close Buffer", "category": "Neovim: Buffers", "app": "nvim", "command": "", "source": "app"},
        {"keys": "Space w", "action": "Save Current Buffer", "category": "Neovim: Operations", "app": "nvim", "command": "", "source": "app"},
        {"keys": "Space c t", "action": "Rust / Starter Template Picker", "category": "Neovim: Templates", "app": "nvim", "command": ":RustTemplate", "source": "app"},
        {"keys": "Space r c", "action": "Run Current File (C++, Rust, Python, etc.)", "category": "Neovim: Code Runner", "app": "nvim", "command": "", "source": "app"},
        {"keys": "Space r i", "action": "Run with input.txt (CP Mode)", "category": "Neovim: Code Runner", "app": "nvim", "command": "", "source": "app"},
        {"keys": "Space r j", "action": "Run CPOS Samples JSON Tests", "category": "Neovim: Code Runner", "app": "nvim", "command": "", "source": "app"},
        {"keys": "Space r t", "action": "Toggle Test Cases (cin >> T / let t = 1)", "category": "Neovim: Code Runner", "app": "nvim", "command": "", "source": "app"},
        {"keys": ":RustTemplate", "action": "Insert Rust Starter Template (cp/project/learning)", "category": "Neovim: Templates", "app": "nvim", "command": ":RustTemplate", "source": "app"},
    ]

def get_helium_shortcuts():
    return [
        {"keys": "⌘ T", "action": "New Tab", "category": "Helium: Tabs", "app": "helium", "command": "", "source": "app"},
        {"keys": "⌘ W", "action": "Close Tab", "category": "Helium: Tabs", "app": "helium", "command": "", "source": "app"},
        {"keys": "⌘ ⇧ T", "action": "Reopen Last Closed Tab", "category": "Helium: Tabs", "app": "helium", "command": "", "source": "app"},
        {"keys": "⌘ L", "action": "Focus Address Bar / URL Search", "category": "Helium: Navigation", "app": "helium", "command": "", "source": "app"},
        {"keys": "⌘ R", "action": "Reload Current Page", "category": "Helium: Navigation", "app": "helium", "command": "", "source": "app"},
        {"keys": "⌘ ⇧ R", "action": "Hard Reload (Ignore Cache)", "category": "Helium: Navigation", "app": "helium", "command": "", "source": "app"},
        {"keys": "⌘ [ / ⌘ ]", "action": "Navigate Back / Forward in History", "category": "Helium: Navigation", "app": "helium", "command": "", "source": "app"},
        {"keys": "⌘ ⌥ ← / →", "action": "Switch to Previous / Next Tab", "category": "Helium: Tabs", "app": "helium", "command": "", "source": "app"},
        {"keys": "⌘ 1 .. 9", "action": "Jump Directly to Tab 1 through 9", "category": "Helium: Tabs", "app": "helium", "command": "", "source": "app"},
        {"keys": "⌘ + / ⌘ -", "action": "Zoom In / Out", "category": "Helium: View", "app": "helium", "command": "", "source": "app"},
        {"keys": "⌘ 0", "action": "Reset Zoom to 100%", "category": "Helium: View", "app": "helium", "command": "", "source": "app"},
        {"keys": "⌘ F", "action": "Find in Page", "category": "Helium: Navigation", "app": "helium", "command": "", "source": "app"},
        {"keys": "⌘ ⌥ I", "action": "Toggle Web Developer Tools / Inspector", "category": "Helium: Tools", "app": "helium", "command": "", "source": "app"},
        {"keys": "⌘ ⇧ B", "action": "Toggle Bookmarks Bar", "category": "Helium: View", "app": "helium", "command": "", "source": "app"},
        {"keys": "⌘ ⇧ N", "action": "New Private / Incognito Window", "category": "Helium: Tabs", "app": "helium", "command": "", "source": "app"},
    ]

def get_spotify_shortcuts():
    return [
        {"keys": "Space", "action": "Play / Pause Toggle", "category": "Spotify: Playback", "app": "spotify", "command": "", "source": "app"},
        {"keys": "⌘ →", "action": "Next Track", "category": "Spotify: Playback", "app": "spotify", "command": "", "source": "app"},
        {"keys": "⌘ ←", "action": "Previous Track", "category": "Spotify: Playback", "app": "spotify", "command": "", "source": "app"},
        {"keys": "⌘ ↑ / ⌘ ↓", "action": "Volume Up / Volume Down", "category": "Spotify: Playback", "app": "spotify", "command": "", "source": "app"},
        {"keys": "⌘ ⇧ ↓", "action": "Mute Volume", "category": "Spotify: Playback", "app": "spotify", "command": "", "source": "app"},
        {"keys": "⌘ ⇧ ↑", "action": "Set Maximum Volume", "category": "Spotify: Playback", "app": "spotify", "command": "", "source": "app"},
        {"keys": "⌘ L", "action": "Focus Search Field", "category": "Spotify: Navigation", "app": "spotify", "command": "", "source": "app"},
        {"keys": "⌘ ⇧ S", "action": "Toggle Shuffle On / Off", "category": "Spotify: Playback", "app": "spotify", "command": "", "source": "app"},
        {"keys": "⌘ ⇧ R", "action": "Toggle Repeat Mode", "category": "Spotify: Playback", "app": "spotify", "command": "", "source": "app"},
        {"keys": "⌘ N", "action": "Create New Playlist", "category": "Spotify: Library", "app": "spotify", "command": "", "source": "app"},
        {"keys": "⌘ ⌥ 1", "action": "Go to Your Library", "category": "Spotify: Navigation", "app": "spotify", "command": "", "source": "app"},
        {"keys": "⌘ ⌥ 2", "action": "Go to Home View", "category": "Spotify: Navigation", "app": "spotify", "command": "", "source": "app"},
        {"keys": "⌘ ⌥ 3", "action": "Go to Search View", "category": "Spotify: Navigation", "app": "spotify", "command": "", "source": "app"},
        {"keys": "⌘ ⇧ F", "action": "Toggle Full Screen Now Playing", "category": "Spotify: View", "app": "spotify", "command": "", "source": "app"},
    ]

def get_vlc_shortcuts():
    return [
        {"keys": "Space", "action": "Play / Pause Toggle", "category": "VLC: Playback", "app": "vlc", "command": "", "source": "app"},
        {"keys": "⌘ → / ⌘ ←", "action": "Short Jump Forward / Backward (10s)", "category": "VLC: Navigation", "app": "vlc", "command": "", "source": "app"},
        {"keys": "⌘ ⌥ → / ⌘ ⌥ ←", "action": "Medium Jump Forward / Backward (1m)", "category": "VLC: Navigation", "app": "vlc", "command": "", "source": "app"},
        {"keys": "⌘ ⌃ → / ⌘ ⌃ ←", "action": "Long Jump Forward / Backward (5m)", "category": "VLC: Navigation", "app": "vlc", "command": "", "source": "app"},
        {"keys": "⌘ ↑ / ⌘ ↓", "action": "Volume Up / Volume Down", "category": "VLC: Audio", "app": "vlc", "command": "", "source": "app"},
        {"keys": "⌘ ⌥ M", "action": "Mute Audio", "category": "VLC: Audio", "app": "vlc", "command": "", "source": "app"},
        {"keys": "⌘ F", "action": "Toggle Fullscreen", "category": "VLC: View", "app": "vlc", "command": "", "source": "app"},
        {"keys": "E", "action": "Step Frame by Frame (Next Frame)", "category": "VLC: Playback", "app": "vlc", "command": "", "source": "app"},
        {"keys": "[ / ]", "action": "Decrease / Increase Playback Speed", "category": "VLC: Playback", "app": "vlc", "command": "", "source": "app"},
        {"keys": "=", "action": "Reset Playback Speed to Normal (1.0x)", "category": "VLC: Playback", "app": "vlc", "command": "", "source": "app"},
        {"keys": "S", "action": "Stop Playback", "category": "VLC: Playback", "app": "vlc", "command": "", "source": "app"},
        {"keys": "⌘ ⇧ O", "action": "Open Media File Dialog", "category": "VLC: Media", "app": "vlc", "command": "", "source": "app"},
        {"keys": "⌘ D", "action": "Open Disc Source", "category": "VLC: Media", "app": "vlc", "command": "", "source": "app"},
        {"keys": "⌘ N", "action": "Open Network Stream", "category": "VLC: Media", "app": "vlc", "command": "", "source": "app"},
        {"keys": "⌘ ⌥ V", "action": "Cycle Subtitle Tracks", "category": "VLC: Subtitles", "app": "vlc", "command": "", "source": "app"},
        {"keys": "⌘ ⌥ A", "action": "Cycle Audio Tracks", "category": "VLC: Audio", "app": "vlc", "command": "", "source": "app"},
        {"keys": "J / K", "action": "Adjust Audio Delay (Sync Offset)", "category": "VLC: Audio", "app": "vlc", "command": "", "source": "app"},
    ]

def get_mpv_shortcuts():
    return [
        {"keys": "Space", "action": "Play / Pause Toggle", "category": "MPV: Playback", "app": "mpv", "command": "", "source": "app"},
        {"keys": "→ / ←", "action": "Seek 5 Seconds Forward / Backward", "category": "MPV: Navigation", "app": "mpv", "command": "", "source": "app"},
        {"keys": "↑ / ↓", "action": "Seek 60 Seconds Forward / Backward", "category": "MPV: Navigation", "app": "mpv", "command": "", "source": "app"},
        {"keys": "⌃ → / ⌃ ←", "action": "Seek Exact 1 Second Forward / Backward", "category": "MPV: Navigation", "app": "mpv", "command": "", "source": "app"},
        {"keys": "[ / ]", "action": "Decrease / Increase Playback Speed by 10%", "category": "MPV: Playback", "app": "mpv", "command": "", "source": "app"},
        {"keys": "{ / }", "action": "Halve / Double Playback Speed", "category": "MPV: Playback", "app": "mpv", "command": "", "source": "app"},
        {"keys": "Backspace", "action": "Reset Playback Speed to 1.0x", "category": "MPV: Playback", "app": "mpv", "command": "", "source": "app"},
        {"keys": "9 / 0", "action": "Volume Down / Up", "category": "MPV: Audio", "app": "mpv", "command": "", "source": "app"},
        {"keys": "m", "action": "Mute / Unmute Audio", "category": "MPV: Audio", "app": "mpv", "command": "", "source": "app"},
        {"keys": "f", "action": "Toggle Fullscreen Mode", "category": "MPV: View", "app": "mpv", "command": "", "source": "app"},
        {"keys": "s", "action": "Take Video Screenshot", "category": "MPV: Media", "app": "mpv", "command": "", "source": "app"},
        {"keys": "⇧ S", "action": "Take Screenshot Without Subtitles", "category": "MPV: Media", "app": "mpv", "command": "", "source": "app"},
        {"keys": "v", "action": "Toggle Subtitle Visibility", "category": "MPV: Subtitles", "app": "mpv", "command": "", "source": "app"},
        {"keys": "j / ⇧ J", "action": "Cycle Subtitle Tracks Forward / Backward", "category": "MPV: Subtitles", "app": "mpv", "command": "", "source": "app"},
        {"keys": "#", "action": "Cycle Audio Tracks", "category": "MPV: Audio", "app": "mpv", "command": "", "source": "app"},
        {"keys": ". / ,", "action": "Step Frame Forward / Backward", "category": "MPV: Playback", "app": "mpv", "command": "", "source": "app"},
        {"keys": "q", "action": "Quit and Save Resume Position", "category": "MPV: General", "app": "mpv", "command": "", "source": "app"},
        {"keys": "⇧ Q", "action": "Quit Immediately Without Saving Position", "category": "MPV: General", "app": "mpv", "command": "", "source": "app"},
    ]

def get_books_shortcuts():
    return [
        {"keys": "→ / ←", "action": "Next / Previous Page", "category": "Books: Reading", "app": "books", "command": "", "source": "app"},
        {"keys": "Space / ⇧ Space", "action": "Scroll Down / Scroll Up", "category": "Books: Reading", "app": "books", "command": "", "source": "app"},
        {"keys": "⌘ + / ⌘ -", "action": "Increase / Decrease Text Size", "category": "Books: Appearance", "app": "books", "command": "", "source": "app"},
        {"keys": "⌘ 0", "action": "Reset to Default Font Size", "category": "Books: Appearance", "app": "books", "command": "", "source": "app"},
        {"keys": "⌘ F", "action": "Search within Book", "category": "Books: Navigation", "app": "books", "command": "", "source": "app"},
        {"keys": "⌘ D", "action": "Add / Remove Bookmark on Page", "category": "Books: Navigation", "app": "books", "command": "", "source": "app"},
        {"keys": "⌘ ⌥ B", "action": "Show / Hide Bookmarks Panel", "category": "Books: Navigation", "app": "books", "command": "", "source": "app"},
        {"keys": "⌘ T", "action": "Show Table of Contents", "category": "Books: Navigation", "app": "books", "command": "", "source": "app"},
        {"keys": "⌘ ⌥ N", "action": "Show Notes & Highlights Panel", "category": "Books: Navigation", "app": "books", "command": "", "source": "app"},
        {"keys": "⌘ ⌥ T", "action": "Change Theme (Light, Sepia, Gray, Night)", "category": "Books: Appearance", "app": "books", "command": "", "source": "app"},
        {"keys": "⌘ ⌥ 1", "action": "Switch to Single Page View", "category": "Books: Layout", "app": "books", "command": "", "source": "app"},
        {"keys": "⌘ ⌥ 2", "action": "Switch to Two-Page Spread View", "category": "Books: Layout", "app": "books", "command": "", "source": "app"},
        {"keys": "⌃ ⌘ F", "action": "Enter / Exit Full Screen Mode", "category": "Books: Layout", "app": "books", "command": "", "source": "app"},
        {"keys": "⌘ W", "action": "Close Current Book", "category": "Books: General", "app": "books", "command": "", "source": "app"},
    ]

def get_yazi_shortcuts():
    items = []
    if not YAZI_PATH.exists():
        return items
    try:
        import tomllib
        with open(YAZI_PATH, "rb") as f:
            data = tomllib.load(f)
        for m in data.get("mgr", {}).get("keymap", []):
            on = m.get("on", "")
            if isinstance(on, list):
                keys = " ".join(on)
            else:
                keys = str(on)
            keys = keys.replace("<Space>", "Space").replace("<Esc>", "Esc").replace("<Enter>", "↵").replace("<C-", "⌃ ").replace("<S-", "⇧ ").replace("<A-", "⌥ ").replace(">", "")
            desc = m.get("desc", m.get("run", ""))
            run_cmd = m.get("run", "")
            if isinstance(run_cmd, list):
                run_cmd = "; ".join(run_cmd)
            items.append({
                "keys": keys,
                "action": desc,
                "category": "Yazi File Manager",
                "app": "yazi",
                "command": run_cmd,
                "source": "app"
            })
    except Exception as e:
        print(f"Error parsing yazi shortcuts: {e}")
    return items

def get_ghostty_shortcuts():
    return [
        {"keys": "⌘ T", "action": "New Tab", "category": "Ghostty: Tabs & Windows", "app": "Ghostty", "command": "", "source": "app"},
        {"keys": "⌘ W", "action": "Close Surface / Tab", "category": "Ghostty: Tabs & Windows", "app": "Ghostty", "command": "", "source": "app"},
        {"keys": "⌘ D", "action": "Split Right", "category": "Ghostty: Splits", "app": "Ghostty", "command": "", "source": "app"},
        {"keys": "⌘ ⇧ D", "action": "Split Down", "category": "Ghostty: Splits", "app": "Ghostty", "command": "", "source": "app"},
        {"keys": "⌘ [ / ⌘ ]", "action": "Previous / Next Split", "category": "Ghostty: Splits", "app": "Ghostty", "command": "", "source": "app"},
        {"keys": "⌘ ⇧ ↵", "action": "Toggle Split Zoom", "category": "Ghostty: Splits", "app": "Ghostty", "command": "", "source": "app"},
        {"keys": "⌘ + / ⌘ -", "action": "Increase / Decrease Font Size", "category": "Ghostty: View", "app": "Ghostty", "command": "", "source": "app"},
        {"keys": "⌘ 0", "action": "Reset Font Size", "category": "Ghostty: View", "app": "Ghostty", "command": "", "source": "app"},
        {"keys": "⌘ ⌥ I", "action": "Toggle Terminal Inspector", "category": "Ghostty: Tools", "app": "Ghostty", "command": "", "source": "app"},
        {"keys": "⌘ ⇧ ,", "action": "Reload Configuration", "category": "Ghostty: Tools", "app": "Ghostty", "command": "", "source": "app"},
    ]

CACHE_PATH = Path("/Users/aaravshah2975/.config/cheatsheet/shortcuts_cache.json")

def get_cached_shortcuts(force=False):
    # Fast path: load pre-parsed JSON instantly without filesystem checks
    if not force and CACHE_PATH.exists():
        try:
            with open(CACHE_PATH, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            pass

    # Rebuild only when requested or missing
    return build_all()

def build_all(force=True):
    aero = get_aero_shortcuts()
    karabiner = get_karabiner_shortcuts()
    tmux = get_tmux_shortcuts()
    yazi = get_yazi_shortcuts()
    ghostty = get_ghostty_shortcuts()
    nvim = get_neovim_shortcuts()
    helium = get_helium_shortcuts()
    spotify = get_spotify_shortcuts()
    vlc = get_vlc_shortcuts()
    mpv = get_mpv_shortcuts()
    books = get_books_shortcuts()

    all_shortcuts = aero + karabiner + tmux + yazi + ghostty + nvim + helium + spotify + vlc + mpv + books
    print(f"Loaded {len(aero)} AeroSpace, {len(karabiner)} Karabiner, {len(tmux)} Tmux, {len(yazi)} Yazi, {len(ghostty)} Ghostty, {len(nvim)} Neovim, {len(helium)} Helium, {len(spotify)} Spotify, {len(vlc)} VLC, {len(mpv)} MPV, {len(books)} Books ({len(all_shortcuts)} total).")
    try:
        with open(CACHE_PATH, "w", encoding="utf-8") as f:
            json.dump(all_shortcuts, f, indent=2)
    except Exception as e:
        print(f"Error writing cache: {e}")
    return all_shortcuts

if __name__ == "__main__":
    shortcuts = build_all()
    with open("/tmp/shortcut_db.json", "w") as f:
        json.dump({"global": shortcuts, "apps": {}}, f, indent=2)
    print("Saved to /tmp/shortcut_db.json successfully!")
