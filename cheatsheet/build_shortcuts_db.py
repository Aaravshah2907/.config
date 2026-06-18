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
# Imported rules live in karabiner.json; assets/*.json are install templates only.
KARABINER_MODS = None

CACHE = Path("/tmp/shortcut_db.json")

POINTING_BUTTON_NAMES = {
    "button1": "Left Click",
    "button2": "Right Click",
    "button3": "Middle Click",
    "button4": "Back Button",
    "button5": "Forward Button",
}

MODIFIER_REMAP_KEYS = {
    "right_command",
    "right_control",
    "caps_lock",
}


APP_MAP_REVERSE = {
    "com.microsoft.VSCode": "vscode",
    "com.todesktop.230313mzl4w4u92": "cursor",
    "com.brave.Browser": "brave",
    "com.google.Chrome": "chrome",
    "com.apple.Safari": "safari",
    "com.apple.Terminal": "iterm",
    "com.googlecode.iterm2": "iterm",
    "org.videolan.vlc": "vlc",
}

KARABINER_KEY_NAMES = {
    "left_arrow": "←",
    "right_arrow": "→",
    "up_arrow": "↑",
    "down_arrow": "↓",
    "return_or_enter": "Return",
    "escape": "Esc",
    "delete_or_backspace": "Delete",
    "delete_forward": "Forward Delete",
    "spacebar": "Space",
    "caps_lock": "Caps Lock",
    "page_up": "Page Up",
    "page_down": "Page Down",
    "home": "Home",
    "end": "End",
    "comma": ",",
    "period": ".",
    "slash": "/",
    "semicolon": ";",
    "quote": "'",
    "open_bracket": "[",
    "close_bracket": "]",
    "backslash": "\\",
    "hyphen": "-",
    "equal_sign": "=",
    "grave_accent_and_tilde": "`",
    "insert": "Insert",
    "f": "F",
}

KARABINER_MODIFIER_NAMES = {
    "left_command": "⌘",
    "right_command": "⌘",
    "command": "⌘",
    "left_control": "⌃",
    "right_control": "⌃",
    "control": "⌃",
    "left_option": "⌥",
    "right_option": "⌥",
    "option": "⌥",
    "left_shift": "⇧",
    "right_shift": "⇧",
    "shift": "⇧",
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

def normalise_karabiner_keys(key):
        """
        Convert karabiner raw keys into human-readable shortcut string
        """

        if not key:
            return ""

        key = key.lower().strip()

        replacements = {
            "left_command": "⌘",
            "right_command": "⌘",
            "command": "⌘",

            "left_control": "⌃",
            "right_control": "⌃",
            "control": "⌃",

            "left_option": "⌥",
            "right_option": "⌥",
            "option": "⌥",

            "left_shift": "⇧",
            "right_shift": "⇧",
            "shift": "⇧",
        }

        # If it's already compact like ⌘⌃⌥⇧h → leave structure intact
        for k, v in replacements.items():
            key = key.replace(k, v)

        # Fix spacing issues like ⌘⌃⌥⇧h → ⌘ ⌃ ⌥ ⇧ h
        # Insert space before last letter if missing
        if len(key) > 1:
            modifiers = ["⌘", "⌃", "⌥", "⇧"]
            parts = []

            buffer = ""
            for ch in key:
                if ch in modifiers:
                    parts.append(ch)
                else:
                    buffer += ch

            if buffer:
                parts.append(buffer)

            key = " ".join(parts)

        return key.strip()


def format_karabiner_key(key):
    if not key:
        return ""

    key = str(key).strip().lower()
    if key in POINTING_BUTTON_NAMES:
        return POINTING_BUTTON_NAMES[key]
    return KARABINER_KEY_NAMES.get(key, key.replace("_", " ").title())


def is_hyper_combo(modifiers):
    mods = {m.lower() for m in (modifiers or [])}
    has_cmd = mods & {"left_command", "right_command", "command"}
    has_ctrl = mods & {"left_control", "right_control", "control"}
    has_opt = mods & {"left_option", "right_option", "option"}
    has_shift = mods & {"left_shift", "right_shift", "shift"}
    return bool(has_cmd and has_ctrl and has_opt and has_shift)


def format_karabiner_combo(key, modifiers=None):
    modifiers = modifiers or []

    if is_hyper_combo(modifiers):
        parts = ["Hyper"]
    else:
        parts = [
            KARABINER_MODIFIER_NAMES.get(modifier, format_karabiner_key(modifier))
            for modifier in modifiers
        ]

    if key:
        parts.append(format_karabiner_key(key))

    return " ".join(parts).strip()


def normalise_bundle_identifier(bundle):
    bundle = bundle.strip()
    bundle = bundle.strip("^$")
    bundle = bundle.replace("\\.", ".")
    return bundle


def extract_karabiner():
    data = safe_read_json(KARABINER_MAIN)

    shortcuts_global = []
    shortcuts_apps = {}

    KARABINER_ACTION_MAP = {
        "left_arrow": "Move Left",
        "right_arrow": "Move Right",
        "up_arrow": "Move Up",
        "down_arrow": "Move Down",

        "delete_or_backspace": "Delete",
        "delete_forward": "Forward Delete",

        "return_or_enter": "Enter",
        "escape": "Escape",
       }

    
    def translate_karabiner(action):
        action = str(action).lower().strip()

        if action in KARABINER_ACTION_MAP:
            return KARABINER_ACTION_MAP[action]

        return action

        
    def format_to_entry(entry):
        if "shell_command" in entry:
            return entry["shell_command"]

        if "key_code" in entry:
            key = entry.get("key_code")
            modifiers = entry.get("modifiers", [])
            combo = format_karabiner_combo(key, modifiers)
            if modifiers:
                return f"Send {combo}"
            return translate_karabiner(key)

        if "pointing_button" in entry:
            return f"Send {format_karabiner_key(entry['pointing_button'])}"

        if "consumer_key_code" in entry:
            return entry["consumer_key_code"].replace("_", " ").title()

        return str(entry)

    def format_to_block(block):
        if not block:
            return ""

        return " / ".join(format_to_entry(entry) for entry in block)

    def extract_action(m, rule_description="", manipulator_count=1):
        if manipulator_count == 1 and rule_description:
            return rule_description

        parts = []

        if m.get("to"):
            parts.append(format_to_block(m["to"]))
        if m.get("to_if_alone"):
            parts.append(f"Tap: {format_to_block(m['to_if_alone'])}")
        if m.get("to_if_held_down"):
            parts.append(f"Hold: {format_to_block(m['to_if_held_down'])}")

        if parts:
            return " · ".join(parts)

        return rule_description

    #def is_valid_karabiner_entry(keys, action):
        #if not keys:
            #return False

        #if keys in ["⌘", "⌃", "⌥", "⇧"]:
         #   return False

        #if action == "" or action is None:
        #    return False

        #return True

    def is_modifier_remap(m):
        frm = m.get("from", {})
        key = frm.get("key_code")
        if key not in MODIFIER_REMAP_KEYS:
            return False

        to_block = m.get("to", [])
        if not to_block:
            return False

        return bool(to_block[0].get("modifiers"))

    def is_valid_key(m):
        if is_modifier_remap(m):
            return False

        frm = m.get("from", {})
        key = frm.get("key_code")
        button = frm.get("pointing_button")

        if not key and not button:
            return False

        junk = {
            "vk_none",
            "application",
            "pause",
            "scroll_lock",
            "print_screen",
            "keypad_num_lock",
        }

        if key in junk:
            return False

        return True


    seen = set()

    def dedupe(entry):
        #key = (entry["keys"], entry["action"], entry["source"])
        key = (entry["keys"], entry["action"], entry["command"])
        if key in seen:
            return False
        seen.add(key)
        return True
        
    def handle_manipulator(m, rule_description="", manipulator_count=1):
        try:
            if not is_valid_key(m):
                return

            frm = m.get("from", {})
            key = frm.get("key_code") or frm.get("pointing_button", "")

            mods = frm.get("modifiers", {}).get("mandatory", [])

            action = extract_action(m, rule_description, manipulator_count)
            if not action:
                return

            keys = format_karabiner_combo(key, mods)

            item = {
                "keys": keys,
                "action": translate(command=action),
                "category": categorise(action),
                "command": action,
                "source": "karabiner",
            }

            if not dedupe(item):
                return

            # detect app scope
            app_scope = None

            for c in m.get("conditions", []):
                if c.get("type") == "frontmost_application_if":
                    bundle_ids = c.get("bundle_identifiers", [])
                    if bundle_ids:
                        bundle = normalise_bundle_identifier(bundle_ids[0])
                        app_scope = APP_MAP_REVERSE.get(bundle)

            if app_scope:
                shortcuts_apps.setdefault(app_scope, []).append(item)
            else:
                shortcuts_global.append(item)

        except:
            pass


    # read main file
    rules = data.get("profiles", [{}])[0] \
                .get("complex_modifications", {}) \
                .get("rules", [])

    for rule in rules:
        manipulators = rule.get("manipulators", [])
        description = rule.get("description", "")
        for m in manipulators:
            handle_manipulator(m, description, len(manipulators))

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
