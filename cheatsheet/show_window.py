import webview
import sys
import subprocess

def parse_keys_to_applescript(keys_str):
    if not keys_str:
        return None
    # Tmux prefix key combinations (Ctrl+b, then key)
    if "Prefix +" in keys_str:
        sub = keys_str.split("Prefix +", 1)[1].strip()
        # Clean quotes
        clean_sub = sub.replace('"', '\\"').replace("'", "")
        if len(clean_sub) == 1:
            return f'keystroke "b" using {{control down}}\n        delay 0.05\n        keystroke "{clean_sub.lower()}"'
        else:
            return f'keystroke "b" using {{control down}}\n        delay 0.05\n        keystroke "{clean_sub}"'

    mods = []
    if "⌘" in keys_str or "Cmd" in keys_str: mods.append("command down")
    if "⌥" in keys_str or "Alt" in keys_str or "Option" in keys_str: mods.append("option down")
    if "⌃" in keys_str or "Ctrl" in keys_str: mods.append("control down")
    if "⇧" in keys_str or "Shift" in keys_str: mods.append("shift down")

    clean = keys_str.replace("⌘", "").replace("⌥", "").replace("⌃", "").replace("⇧", "")
    clean = clean.replace("Cmd", "").replace("Alt", "").replace("Option", "").replace("Ctrl", "").replace("Shift", "")
    clean = clean.replace("+", "").strip()

    if "/" in clean:
        clean = clean.split("/")[0].strip()

    using_clause = (" using {" + ", ".join(mods) + "}") if mods else ""

    key_codes = {
        "←": 123, "left": 123, "arrow left": 123,
        "→": 124, "right": 124, "arrow right": 124,
        "↓": 125, "down": 125, "arrow down": 125,
        "↑": 126, "up": 126, "arrow up": 126,
        "space": 49, "spacebar": 49,
        "return": 36, "enter": 36, "↵": 36,
        "escape": 53, "esc": 53, "⎋": 53,
        "tab": 48, "⇥": 48,
        "backspace": 51, "delete": 51, "⌫": 51,
    }

    lower = clean.lower()
    if lower in key_codes:
        return f"key code {key_codes[lower]}{using_clause}"
    elif len(clean) == 1:
        return f'keystroke "{clean.lower()}"{using_clause}'
    else:
        return f'keystroke "{clean}"{using_clause}'

def synthesize_key(keys_str):
    stmt = parse_keys_to_applescript(keys_str)
    if not stmt:
        return
    # Delay allows window destruction and focus switch to target app
    script = f'''
    delay 0.12
    tell application "System Events"
        {stmt}
    end tell
    '''
    subprocess.Popen(["osascript", "-e", script])

class API:
    def __init__(self):
        self._window = None

    def close(self):
        if self._window:
            self._window.destroy()
        sys.exit(0)

    def refresh_shortcuts(self):
        try:
            import parse_configs
            new_shortcuts = parse_configs.build_all(force=True)
            return {"status": "ok", "count": len(new_shortcuts), "shortcuts": new_shortcuts}
        except Exception as e:
            return {"status": "error", "message": str(e)}

    def execute(self, cmd_type, command, keys=None, app=None):
        try:
            # 1. Close the dashboard immediately so target app regains focus
            if self._window:
                self._window.destroy()

            # 2. Execute command or synthesize keypress
            if cmd_type == "menubar":
                parts = [p.strip() for p in command.split(">")]
                if parts:
                    n = len(parts)
                    if n == 1:
                        script_body = f'click menu bar item "{parts[0]}" of menu bar 1'
                    else:
                        script_body = f'click menu item "{parts[-1]}"'
                        for i in range(n - 2, 0, -1):
                            script_body += f' of menu "{parts[i]}" of menu item "{parts[i]}"'
                        script_body += f' of menu "{parts[0]}" of menu bar item "{parts[0]}" of menu bar 1'
                    
                    app_name_script = 'tell application "System Events" to return name of first application process whose frontmost is true'
                    app_name = subprocess.check_output(["osascript", "-e", app_name_script], text=True).strip()
                    
                    applescript = f'''
                    delay 0.12
                    tell application "System Events"
                        tell process "{app_name}"
                            {script_body}
                        end tell
                    end tell
                    '''
                    subprocess.Popen(["osascript", "-e", applescript])
            elif cmd_type == "shell" and command:
                subprocess.Popen(command, shell=True)
            elif keys:
                synthesize_key(keys)
            elif command:
                subprocess.Popen(command, shell=True)
            
            sys.exit(0)
        except Exception as e:
            print(f"Execution failed: {e}")
            sys.exit(1)

import os
from generate_cheatsheet import build_html

active_app = os.environ.get("CHEATSHEET_FRONT_APP", "")
html = build_html(active_app)

api = API()
window = webview.create_window(
    "⌨️ Shortcut Hub",
    html=html,
    width=1200,
    height=800,
    js_api=api
)
api._window = window

webview.start()
