#!/usr/bin/env bash
source "$HOME/.local/bin/cosmere_colors.sh"

# speedtest.sh – runs a speedtest and updates the SketchyBar speedtest item
# Uses only Nerd Font icons; text labels are hidden.
# Requires `speedtest-cli` (install with `brew install speedtest-cli`).

ICON="󰤨" # Generic speed‑test icon (mapped in icon_map.sh)

# Helper to update SketchyBar item with a given color
set_state() {
    local color="$1"
    sketchybar --set speedtest drawing=on icon.drawing=on icon="$ICON" icon.color="$color"
}

# Initial state – connecting (yellow)
set_state "$HONOR_GOLD"

# Run the speedtest; capture output but keep UI minimal
if [[ "$SKETCHYBAR_EVENT" == "mouse.entered" ]]; then
    sketchybar --set speedtest popup.drawing=on
elif [[ "$SKETCHYBAR_EVENT" == "mouse.exited" ]]; then
    sketchybar --set speedtest popup.drawing=off
else
    if output=$(speedtest 2>/dev/null); then
        # Success – green icon
        set_state "$EMERALD"
        # Keep popup hidden; label will be shown on hover
        sketchybar --set speedtest popup.drawing=off
        sketchybar --set speedtest_popup label="$output" label.drawing=on
    else
        # Failure – red icon
        set_state "$RED"
        sketchybar --set speedtest popup.drawing=off
        sketchybar --set speedtest_popup label="$output" label.drawing=on
    fi
fi
