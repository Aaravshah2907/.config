#!/usr/bin/env python3

import os
import json
from pathlib import Path

from translations import (
    categorise,
    prettify_keys,
    translate,
)

SKHD = Path.home() / ".config/skhd/skhdrc"

KARABINER_MAIN = Path.home() / ".config/karabiner/karabiner.json"
KARABINER_MODS = Path.home() / ".config/karabiner/assets/complex_modifications/"

CACHE = Path("/tmp/shortcut_db.json")


APP_MAP_REVERSE = {
    "com.microsoft.VSCode": "vscode",
    "com.brave.Browser": "brave",
    "com.google.Chrome": "chrome",
    "com.apple.Safari": "safari",
    "com.apple.Terminal": "iterm",
    "org.videolan.vlc": "vlc",
}


def safe_read_json(path):
    try:
        return json.loads(path.read_text())
    except:
        return {}


def parse_skhd():
    shortcuts = []

    if not SKHD.exists():
        return shortcuts

    for line in SKHD.read_text().splitlines():
        line = line.strip()

        if not line or line.startswith("#") or ":" not in line:
            continue

        keys, command = line.split(":", 1)

        keys = keys.strip()
        command = command.strip()

        shortcuts.append({
            "keys": prettify_keys(keys),
            "action": translate(command),
            "category": categorise(command),
            "command": command,
            "source": "skhd",
        })

    return shortcuts


def extract_karabiner():
    data = safe_read_json(KARABINER_MAIN)

    shortcuts_global = []
    shortcuts_apps = {}

    def handle_manipulator(m):
        try:
            from_key = m.get("from", {}).get("key_code", "")
            mods = m.get("from", {}).get("modifiers", {})

            to = m.get("to", [{}])[0].get("key_code", "")
            command = str(m.get("description", ""))

            keys = from_key
            if mods:
                keys = "+".join(mods.get("mandatory", [])) + "+" + from_key

            item = {
                "keys": prettify_keys(keys),
                "action": translate(command),
                "category": categorise(command),
                "command": command,
                "source": "karabiner"
            }

            conditions = m.get("conditions", [])

            app_scope = None

            for c in conditions:
                if c.get("type") == "frontmost_application_if":
                    bundle = c.get("bundle_identifiers", [None])[0]
                    if bundle:
                        app_scope = APP_MAP_REVERSE.get(bundle)

            if app_scope:
                shortcuts_apps.setdefault(app_scope, []).append(item)
            else:
                shortcuts_global.append(item)

        except:
            pass

    # main karabiner.json
    rules = data.get("profiles", [{}])[0].get("complex_modifications", {}).get("rules", [])

    for rule in rules:
        for m in rule.get("manipulators", []):
            handle_manipulator(m)

    # complex_modifications folder
    if KARABINER_MODS.exists():
        for file in KARABINER_MODS.glob("*.json"):
            d = safe_read_json(file)

            rules = d.get("rules", [])
            for rule in rules:
                for m in rule.get("manipulators", []):
                    handle_manipulator(m)

    return shortcuts_global, shortcuts_apps


def build_cache():
    skhd_shortcuts = parse_skhd()
    karabiner_global, karabiner_apps = extract_karabiner()

    global_all = skhd_shortcuts + karabiner_global

    cache = {
        "global": global_all,
        "apps": karabiner_apps
    }

    CACHE.write_text(json.dumps(cache, indent=2))


def main():
    build_cache()


if __name__ == "__main__":
    main()
