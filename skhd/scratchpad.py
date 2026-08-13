#!/usr/bin/env python3
import sys
import subprocess
import os

AEROSPACE_PATH = "/opt/homebrew/bin/aerospace"

_BRAVE_APPS_DIR = os.path.expanduser("~/Applications/Brave Browser Apps.localized")
BRAVE_APPS = {
    "ChatGPT": os.path.join(_BRAVE_APPS_DIR, "ChatGPT.app"),
    "Gemini":  os.path.join(_BRAVE_APPS_DIR, "Gemini.app"), 
    "GMail": os.path.join(_BRAVE_APPS_DIR, "GMail - AS.app")
}

def run_cmd(cmd):
    try:
        if cmd and cmd[0] == "aerospace":
            cmd[0] = AEROSPACE_PATH
        result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=True)
        return result.stdout.strip()
    except subprocess.CalledProcessError:
        return ""

def get_active_space():
    return run_cmd(["aerospace", "list-workspaces", "--focused"])

def toggle_scratchpad(app_name):
    def launch_app():
        brave_path = BRAVE_APPS.get(app_name)
        if brave_path and os.path.exists(brave_path):
            subprocess.run(["open", "-g", brave_path])
        else:
            subprocess.run(["open", "-g", "-a", app_name])

    windows_str = run_cmd(["aerospace", "list-windows", "--all", "--format", "%{window-id}|%{app-name}|%{workspace}"])
    if not windows_str:
        launch_app()
        return

    app_windows = []
    for line in windows_str.split("\n"):
        parts = line.split("|")
        if len(parts) >= 3:
            wid, app, space = parts[0], parts[1], parts[2]
            if app.lower() == app_name.lower():
                app_windows.append({"id": wid, "space": space})

    if not app_windows:
        launch_app()
        return

    active_space = get_active_space()
    focused_id = run_cmd(["aerospace", "list-windows", "--focused", "--format", "%{window-id}"])
    
    window = app_windows[0]
    window_id = window["id"]
    window_space = window["space"]
    has_focus = (window_id == focused_id)

    if window_space == active_space and has_focus:
        # Hide it by moving to workspace Z (Scratchpad workspace)
        run_cmd(["aerospace", "move-node-to-workspace", "Z", "--window-id", window_id])
    else:
        if active_space and window_space != active_space:
            run_cmd(["aerospace", "move-node-to-workspace", active_space, "--window-id", window_id])
        
        # Focus it
        run_cmd(["aerospace", "focus", "--window-id", window_id])

if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit(1)
    app_name = sys.argv[1]
    toggle_scratchpad(app_name)
