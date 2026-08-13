import re
import os

MODIFIERS = {

    "alt": "⌥",
    "shift": "⇧",
    "ctrl": "⌃",
    "cmd": "⌘",
    "command": "⌘",
    "control": "⌃",
    "option": "⌥",
    "hyper": "Hyper",
}


# Used only when automatic detection fails

EXPLICIT_TRANSLATIONS = {

    "sketchybar --reload":
        "Reload SketchyBar",

    "open -a AeroSpace":
        "Start AeroSpace",

    "killall AeroSpace":
        "Stop AeroSpace",

    "aerospace reload-config":
        "Reload AeroSpace",

    "toggle-sharing":
        "Toggle Sharing",

    "lock-screen":
        "Lock Screen",

    "study-mode":
        "Study Mode",

    "vlc_toggle_speed":
        "Toggle VLC Speed",

    "control_center.sh":
        "Open Control Center",

    "show-cheatsheet.sh":
        "Open Shortcut Hub",

    "toggle_dnd.sh":
        "Toggle Do Not Disturb",

    "panic-mode":
        "Panic Mode",

    "keybee-status":
        "Keybee Status",

    "fv.sh":
        "Run fv in iTerm",

    "run fv":
        "Run fv in iTerm",

}


HYPER_MODIFIER_TOKENS = ("cmd", "ctrl", "alt", "shift")
HYPER_GLYPHS = ("⌘", "⌃", "⌥", "⇧")


def collapse_hyper_modifiers(shortcut):
    """Turn cmd+ctrl+alt+shift (or glyph equivalents) into Hyper."""
    lower = shortcut.lower()

    if all(token in lower for token in HYPER_MODIFIER_TOKENS):
        remainder = lower
        for token in HYPER_MODIFIER_TOKENS:
            remainder = re.sub(rf"\b{token}\b", "", remainder)
        remainder = re.sub(r"[\s+\-]+", " ", remainder).strip()
        return f"Hyper {remainder}".strip()

    if all(glyph in shortcut for glyph in HYPER_GLYPHS):
        remainder = shortcut
        for glyph in HYPER_GLYPHS:
            remainder = remainder.replace(glyph, "")
        remainder = re.sub(r"\s+", " ", remainder).strip()
        return f"Hyper {remainder}".strip()

    return shortcut


def prettify_keys(shortcut):
    shortcut = shortcut.lower().strip()

    hyper_patterns = [
        "cmd + ctrl + alt + shift",
        "command + control + option + shift",
    ]

    replacements = {
        "left_command": "cmd",
        "right_command": "cmd",
        "command": "cmd",
        "left_control": "ctrl",
        "right_control": "ctrl",
        "control": "ctrl",
        "left_option": "alt",
        "right_option": "alt",
        "option": "alt",
        "left_shift": "shift",
        "right_shift": "shift",
    }

    for old, new in replacements.items():
        shortcut = shortcut.replace(old, new)

    for pattern in hyper_patterns:
        shortcut = shortcut.replace(pattern, "hyper")

    shortcut = re.sub(r"\bhyper\b", "Hyper", shortcut)

    glyph_map = {
        "alt": "⌥",
        "shift": "⇧",
        "ctrl": "⌃",
        "cmd": "⌘",
    }

    for old, new in glyph_map.items():
        shortcut = re.sub(rf"\b{old}\b", new, shortcut)

    shortcut = shortcut.replace(" - ", " ")
    shortcut = re.sub(r"\s*\+\s*", " ", shortcut)
    shortcut = shortcut.replace("0x18", "=")
    shortcut = shortcut.replace("0x2b", "\\")
    shortcut = shortcut.replace("0x29", ";")
    shortcut = collapse_hyper_modifiers(shortcut)
    shortcut = re.sub(r"\s+", " ", shortcut).strip()

    return shortcut


def categorise(command):
    command = command.lower()

    if "aerospace focus" in command:
        return "🪟 Windows"

    if "aerospace move" in command or "join-with" in command:
        return "🪟 Windows"

    if "aerospace close" in command:
        return "🪟 Windows"

    if "workspace" in command or "flatten-workspace-tree" in command:
        return "📦 Spaces"

    if "layout" in command or "fullscreen" in command or "balance-sizes" in command:
        return "🪟 Windows"

    if "scratchpad.py" in command:
        return "📌 Scratchpads"

    if 'open "' in command:
        return "🚀 Launchers"

    if "brew services" in command:
        return "⭐ System"

    if "sketchybar" in command:
        return "⭐ System"

    if ".local/bin" in command:
        return "⭐ System"

    if "show-cheatsheet.sh" in command:
        return "⌨️ Keyboard"

    return "💻 Misc"


def translate(command):
    command = command.strip()
    lower = command.lower()

    # Move window to space N and focus there

    match = re.search( r'move-node-to-workspace ([A-Z0-9]).*workspace \1', lower)

    if match:
        space = match.group(1).upper()
        return f"Move Window → Workspace {space}"

    if "brave browser apps.localized" in lower:
        app = os.path.basename(command)
        app = app.replace(".app", "")
        app = app.split(" - ")[0]
        return f"Open {app}"

    apps = re.findall(r'open -a "([^"]+)"', command)
    pwas = re.findall(r'open "[^"]+/([^/"]+)\.app"', command)

    if len(apps) + len(pwas) > 1:
        label = pwas[0] if pwas else apps[0]
        return f"Open {label} Workspace"

    if apps:
        return f"Open {apps[0]}"

    if pwas:
        return f"Open {pwas[0]}"

    for pattern, value in EXPLICIT_TRANSLATIONS.items():
        if pattern.lower() in lower:
            return value

    if "insert ->" in lower and "cheat" in lower:
        return "Open Shortcut Hub"

    if "focus left" in lower:
        return "Focus Left"
    if "focus right" in lower:
        return "Focus Right"
    if "focus up" in lower:
        return "Focus Up"
    if "focus down" in lower:
        return "Focus Down"

    if "move left" in lower:
        return "Move Left"
    if "move right" in lower:
        return "Move Right"
    if "move up" in lower:
        return "Move Up"
    if "move down" in lower:
        return "Move Down"

    if "join-with left" in lower:
        return "Join Left"
    if "join-with right" in lower:
        return "Join Right"
    if "join-with up" in lower:
        return "Join Up"
    if "join-with down" in lower:
        return "Join Down"

    if "focus-monitor left" in lower:
        return "Focus Left Monitor"
    if "focus-monitor right" in lower:
        return "Focus Right Monitor"

    if "move-node-to-monitor left" in lower:
        return "Move To Left Monitor"
    if "move-node-to-monitor right" in lower:
        return "Move To Right Monitor"

    if "workspace prev" in lower:
        return "Move To Prev Space"
    if "workspace next" in lower:
        return "Move To Next Space"

    if "balance-sizes" in lower:
        return "Balance Window Sizes"
    if "flatten-workspace-tree" in lower:
        return "Flatten Workspace"

    if "layout tiles vertical horizontal" in lower:
        return "Flip Layout Y"
    if "layout tiles horizontal vertical" in lower:
        return "Flip Layout X"

    if "layout floating" in lower:
        return "Toggle Float"
    if "fullscreen" in lower:
        return "Toggle Fullscreen"

    if "aerospace close" in lower:
        return "Close Window"

    if "scratchpad.py" in lower:
        app = command.split('"')[1]
        return f"{app} Scratchpad"

    if lower.startswith("send "):
        return command[5:].strip()

    if lower.startswith("tap:") or lower.startswith("hold:"):
        return command

    return command
