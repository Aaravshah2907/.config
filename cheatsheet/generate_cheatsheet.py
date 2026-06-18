#!/usr/bin/env python3

import os
import json
import subprocess
from pathlib import Path

from translations import (
    categorise,
    prettify_keys,
    translate,
)

SKHD = Path.home() / ".config/skhd/skhdrc"
HTML = Path.home() / ".config/cheatsheet/template.html"

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
            "yabai", "-m", "query", "--windows", "--window"
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


def get_shortcuts_for_context():
    cache = load_cache()

    app = normalize_app(get_frontmost_app())

    global_shortcuts = cache.get("global", [])

    app_shortcuts = []
    if app and app in cache.get("apps", {}):
        app_shortcuts = cache["apps"][app]

    return global_shortcuts + app_shortcuts


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
