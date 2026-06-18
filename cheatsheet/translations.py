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

    "brew services start yabai":
        "Start Yabai",

    "brew services stop yabai":
        "Stop Yabai",

    "brew services restart yabai":
        "Restart Yabai",

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

}


def prettify_keys(shortcut):
    shortcut = shortcut.lower()
    shortcut = shortcut.strip()

    hyper_patterns = [
        "cmd + ctrl + alt + shift",
        "command + control + option + shift",
    ]

    # normalise karabiner modifiers first
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

    for k, v in replacements.items():
        shortcut = shortcut.replace(k, v)

    # hyper collapse
    #if all(x in shortcut for x in ["cmd", "ctrl", "alt", "shift"]):
        #return "Hyper"


    for pattern in hyper_patterns:
        shortcut = shortcut.replace(pattern, "hyper")

    replacements = {
        "alt":"⌥",
        "shift":"⇧",
        "ctrl":"⌃",
        "cmd":"⌘",
    }


    for old,new in replacements.items():
        shortcut = shortcut.replace(old,new)

    shortcut = shortcut.replace("hyper","Hyper")
    shortcut = shortcut.replace(" - "," ")
    shortcut = shortcut.replace("+","")
    shortcut = shortcut.replace("0x18", "=")
    shortcut = shortcut.replace("0x2b", "\\")
    shortcut = shortcut.replace("0x29", ";")


    return shortcut


def categorise(command):
    command = command.lower()

    if "window --focus" in command:
        return "🪟 Windows"

    if "window --swap" in command:
        return "🪟 Windows"

    if "window --warp" in command:
        return "🪟 Windows"

    if "window --toggle" in command:
        return "🪟 Windows"

    if "window --close" in command:
        return "🪟 Windows"

    if "space --" in command:
        return "📦 Spaces"

    if "display --" in command:
        return "🖥 Displays"

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

    match = re.search( r'window --space (\d+).*space --focus \1', lower)

    if match:
        space = match.group(1)
        return f"Move Window → Space {space}"

    if "brave browser apps.localized" in lower:
        app = os.path.basename(command)
        app = app.replace(".app", "")
        app = app.split(" - ")[0]
        return f"Open {app}"

    for pattern, value in EXPLICIT_TRANSLATIONS.items():
        if pattern.lower() in lower:
            return value


    if "--focus west" in lower:
        return "Focus Left"
    if "--focus east" in lower:
        return "Focus Right"
    if "--focus north" in lower:
        return "Focus Up"
    if "--focus south" in lower:
        return "Focus Down"

    if "--swap west" in lower:
        return "Swap Left"
    if "--swap east" in lower:
        return "Swap Right"
    if "--swap north" in lower:
        return "Swap Up"
    if "--swap south" in lower:
        return "Swap Down"

    if "--warp west" in lower:
        return "Move Left"
    if "--warp east" in lower:
        return "Move Right"
    if "--warp north" in lower:
        return "Move Up"
    if "--warp south" in lower:
        return "Move Down"

    if "--display west" in lower:
        return "Move To Left Display"
    if "--display east" in lower:
        return "Move To Right Display"
    if "--move prev" in lower:
        return "Move To Prev Space"
    if "--move next" in lower:
        return "Move To Next Space"

    if "--balance" in lower:
        return "Balance Space"
    if "--rotate" in lower:
        return "Rotate Space"

    if "--mirror x-axis" in lower:
        return "Mirror Vertical"
    if "--mirror y-axis" in lower:
        return "Mirror Horizontal"

    if "--toggle float" in lower:
        return "Toggle Float"
    if "--toggle split" in lower:
        return "Toggle Split"
    if "--toggle zoom-fullscreen" in lower:
        return "Toggle Fullscreen"

    if "--close" in lower:
        return "Close Window"

    if "scratchpad.py" in lower:
        app = command.split('"')[1]
        return f"{app} Scratchpad"

    if 'open "' in command:
        app = command.split('"')[1]
        return f"Open {app}"

    return command
