#!/usr/bin/env python3

import os
import json
import re
import subprocess
import time
from pathlib import Path

from translations import (
    categorise,
    prettify_keys,
    translate,
)

SKHD = Path.home() / ".config/skhd/skhdrc"
HTML = Path.home() / ".config/cheatsheet/template.html"
MENUBAR_APPLESCRIPT = Path.home() / ".config/cheatsheet/menubar_shortcuts.applescript"

CACHE = Path("/tmp/shortcut_db.json")
LOCK = Path("/tmp/shortcut_hub.lock")

OUTPUT = Path("/tmp/shortcut_hub.html")


APP_MAP = {
    "Visual Studio Code": "vscode",
    "Brave Browser": "brave",
    "Google Chrome": "chrome",
    "Safari": "safari",
    "iTerm2": "iterm",
    "VLC": "vlc",
    "Cursor": "cursor",
}


def toggle_lock():
    if LOCK.exists():
        LOCK.unlink()
        return False
    else:
        LOCK.write_text("1")
        return True


def get_frontmost_app():
    try:
        out = subprocess.check_output([
            "/opt/homebrew/bin/yabai", "-m", "query", "--windows", "--window"
        ])
        data = json.loads(out)
        return data.get("app", "")
    except:
        return ""


def normalize_app(app_name):
    return APP_MAP.get(app_name, None)


def load_cache():
    if not CACHE.exists():
        return {"global": [], "apps": {}}

    with open(CACHE) as f:
        return json.load(f)


def categorise_item(item):
    command = item.get("command", "").lower()

    return categorise(command)


def prettify_item_keys(item):
    return prettify_keys(item.get("keys", ""))


def translate_item(item):
    return translate(item.get("command", ""))


def build_cards(shortcuts):
    grouped = {}

    for item in shortcuts:
        category = item.get("category", "💻 Misc")
        grouped.setdefault(category, []).append(item)

    html = []

    for category, entries in grouped.items():
        items_html = []

        for e in entries:
            items_html.append(f"""
                <div class="item">
                    <span class="key">{e["keys"]}</span>
                    <span>{e["action"]}</span>
                </div>
            """)

        html.append(f"""
        <div class="card">
            <h2>{category}</h2>
            {''.join(items_html)}
        </div>
        """)

    return "\n".join(html)


def dedupe_shortcuts(shortcuts):
    seen = set()
    deduped = []

    for item in shortcuts:
        key = (
            item.get("keys", ""),
            item.get("action", ""),
            item.get("command", ""),
            item.get("source", ""),
        )

        if key in seen:
            continue

        seen.add(key)
        deduped.append(item)

    return deduped


MENU_GLYPHS = {
    "1": "⌫",
    "2": "↩",
    "3": "↩",
    "4": "↵",
    "5": "⎋",
    "6": "↩",
    "7": "↩",
    "8": "⌫",
    "9": "⇥",
    "10": "⇥",
    "11": "⌦",
    "16": "F1",
    "17": "F2",
    "18": "F3",
    "19": "F4",
    "20": "F5",
    "21": "F6",
    "22": "F7",
    "23": "F8",
    "24": "F9",
    "25": "F10",
    "26": "F11",
    "27": "F12",
    "28": "F13",
    "29": "F14",
    "30": "F15",
    "31": "F16",
    "97": "↑",
    "98": "↓",
    "99": "←",
    "100": "→",
    "101": "⌘",
    "102": "⇧",
    "103": "⌥",
    "104": "⌃",
}

MENUBAR_TIMEOUT_SECONDS = 35
MENUBAR_CACHE_DIR = Path("/tmp/cheatsheet_menubar_cache")
MENUBAR_CACHE_TTL_SECONDS = 600
MENUBAR_SKIP_PREFIXES = (
    "Apple >",
)


def normalize_menu_value(value):
    if value is None:
        return ""

    value = str(value).strip()
    if value.lower() in {"", "missing value", "none", "null"}:
        return ""

    return value


def format_menu_shortcut(cmd_char, cmd_glyph, cmd_mods):
    cmd_char = normalize_menu_value(cmd_char)
    cmd_glyph = normalize_menu_value(cmd_glyph)

    key = cmd_char or MENU_GLYPHS.get(cmd_glyph, "")
    if not key or key.lower() == "missing value":
        return ""

    try:
        mods = int(normalize_menu_value(cmd_mods) or "0")
    except ValueError:
        mods = 0

    parts = []

    # AXMenuItemCmdModifiers uses bit 3 to mean "no command key".
    if not mods & 8:
        parts.append("⌘")
    if mods & 4:
        parts.append("⌃")
    if mods & 2:
        parts.append("⌥")
    if mods & 1:
        parts.append("⇧")

    parts.append(key.upper() if len(key) == 1 and key.isalpha() else key)
    return " ".join(parts)


def get_frontmost_app_name():
    env_app = os.environ.get("CHEATSHEET_FRONT_APP", "").strip()
    if env_app:
        return env_app

    try:
        return subprocess.check_output(
            [
                "osascript",
                "-e",
                'tell application "System Events" to return name of first application process whose frontmost is true',
            ],
            text=True,
            timeout=2,
        ).strip()
    except (subprocess.SubprocessError, OSError):
        return ""


def menubar_cache_path(app_name):
    safe_name = re.sub(r"[^\w.-]+", "_", app_name).strip("_") or "unknown"
    return MENUBAR_CACHE_DIR / f"{safe_name}.json"


def load_menubar_cache(app_name):
    cache_file = menubar_cache_path(app_name)
    if not cache_file.exists():
        return None

    age = time.time() - cache_file.stat().st_mtime
    if age > MENUBAR_CACHE_TTL_SECONDS:
        return None

    try:
        return json.loads(cache_file.read_text())
    except (json.JSONDecodeError, OSError):
        return None


def save_menubar_cache(app_name, shortcuts):
    if not app_name:
        return

    MENUBAR_CACHE_DIR.mkdir(parents=True, exist_ok=True)
    menubar_cache_path(app_name).write_text(json.dumps(shortcuts, indent=2))


def parse_menubar_output(output):
    shortcuts = []

    for line in output.splitlines():
        parts = line.split("\t")
        if len(parts) != 5:
            continue

        cmd_char, cmd_glyph, cmd_mods, command, action = parts
        command = normalize_menu_value(command)
        action = normalize_menu_value(action)

        if any(command.startswith(prefix) for prefix in MENUBAR_SKIP_PREFIXES):
            continue

        keys = format_menu_shortcut(cmd_char, cmd_glyph, cmd_mods)
        if not keys:
            continue

        shortcuts.append({
            "keys": keys,
            "action": action or command.rsplit(" > ", 1)[-1],
            "category": "🍎 App Menus",
            "command": command,
            "source": "menubar",
        })

    return shortcuts


def extract_menubar_shortcuts_from_system_events():
    if not MENUBAR_APPLESCRIPT.exists():
        return []

    app_name = get_frontmost_app_name()
    cached = load_menubar_cache(app_name)
    if cached is not None:
        return cached

    try:
        out = subprocess.check_output(
            ["osascript", str(MENUBAR_APPLESCRIPT)],
            stderr=subprocess.PIPE,
            text=True,
            timeout=MENUBAR_TIMEOUT_SECONDS,
        )
    except (subprocess.TimeoutExpired, subprocess.CalledProcessError):
        return []

    shortcuts = parse_menubar_output(out)
    save_menubar_cache(app_name, shortcuts)
    return shortcuts


def get_shortcuts_for_context():
    cache = load_cache()

    app = normalize_app(get_frontmost_app())

    global_shortcuts = cache.get("global", [])

    app_shortcuts = []
    if app and app in cache.get("apps", {}):
        app_shortcuts = cache["apps"][app]

    menubar_shortcuts = extract_menubar_shortcuts_from_system_events()

    return dedupe_shortcuts(global_shortcuts + app_shortcuts + menubar_shortcuts)


def build_html():
    shortcuts = get_shortcuts_for_context()

    content = build_cards(shortcuts)

    template = HTML.read_text()

    final = template.replace("{{CONTENT}}", content)

    OUTPUT.write_text(final)


def main():
    toggle_lock()
    build_html()


if __name__ == "__main__":
    main()
