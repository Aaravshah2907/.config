#!/usr/bin/env python3
import sys
import json
import subprocess
import time

# Use absolute path to yabai since skhd launchd daemon doesn't inherit user PATH
YABAI_PATH = "/opt/homebrew/bin/yabai"

import os
# Brave PWA wrappers — these report their app name to yabai correctly,
# but must be launched via explicit .app path since `open -a` may resolve
# to the wrong binary when the app name is ambiguous.
_BRAVE_APPS_DIR = os.path.expanduser("~/Applications/Brave Browser Apps.localized")
BRAVE_APPS = {
    "ChatGPT": os.path.join(_BRAVE_APPS_DIR, "ChatGPT.app"),
    "Gemini":  os.path.join(_BRAVE_APPS_DIR, "Gemini.app"),  # add others as needed
    "GMail": os.path.join(_BRAVE_APPS_DIR, "GMail - AS.app")
}

def run_cmd(cmd):
    try:
        # Resolve 'yabai' to its absolute path if it is the first argument
        if cmd and cmd[0] == "yabai":
            cmd[0] = YABAI_PATH
        result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=True)
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        return ""

def get_active_space():
    space_info_str = run_cmd(["yabai", "-m", "query", "--spaces", "--space"])
    if space_info_str:
        try:
            space_info = json.loads(space_info_str)
            return space_info.get("index")
        except:
            pass
    return None

def toggle_scratchpad(app_name):
    # Query all windows
    windows_str = run_cmd(["yabai", "-m", "query", "--windows"])
    def launch_app():
        """Launch using Brave wrapper path if available, else generic open."""
        brave_path = BRAVE_APPS.get(app_name)
        if brave_path and os.path.exists(brave_path):
            subprocess.run(["open", "-g", brave_path])
        else:
            subprocess.run(["open", "-g", "-a", app_name])

    if not windows_str:
        launch_app()
        return

    try:
        windows = json.loads(windows_str)
    except:
        launch_app()
        return

    # Filter windows by app name (case-insensitive or exact)
    app_windows = [w for w in windows if w.get("app", "").lower() == app_name.lower()]

    if not app_windows:
        # App is not running or has no windows — use Brave wrapper path if applicable
        launch_app()
        return

    # Find active space
    active_space = get_active_space()
    
    # We take the first window of the app
    window = app_windows[0]
    window_id = window.get("id")
    is_minimized = window.get("is-minimized", False)
    window_space = window.get("space")
    has_focus = window.get("has-focus", False)

    if window_space == active_space and has_focus and not is_minimized:
        # Window is active and focused on current space -> Hide it (minimize)
        run_cmd(["yabai", "-m", "window", str(window_id), "--minimize"])
    else:
        # Window is not focused or on another space -> Bring to current space and focus
        if is_minimized:
            run_cmd(["yabai", "-m", "window", str(window_id), "--deminimize"])
        
        if active_space and window_space != active_space:
            run_cmd(["yabai", "-m", "window", str(window_id), "--space", str(active_space)])
        
        # Float the window to make sure it doesn't affect BSP layout
        if not window.get("is-floating", False):
            run_cmd(["yabai", "-m", "window", str(window_id), "--toggle", "float"])
            
        # Center the window nicely
        run_cmd(["yabai", "-m", "window", str(window_id), "--grid", "4:4:1:1:2:2"])
        
        # Focus it
        run_cmd(["yabai", "-m", "window", str(window_id), "--focus"])

if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit(1)
    app_name = sys.argv[1]
    toggle_scratchpad(app_name)
