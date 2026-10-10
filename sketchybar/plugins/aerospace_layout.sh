#!/bin/bash
source "$HOME/.local/bin/cosmere_colors.sh"

# On click: toggle layout menu popup
if [ "$SENDER" = "mouse.clicked" ]; then
    sketchybar --set aero_root_layout popup.drawing=toggle
    exit 0
fi

# Query current layouts and update icons & colors
ROOT_LAYOUT=$(aerospace list-workspaces --focused --format '%{workspace-root-container-layout}' 2>/dev/null)

# Icons: 󰒡 tiles horizontal, 󰕰 tiles vertical, 󰓩 accordion
ROOT_ICON="󰒡"
if [[ "$ROOT_LAYOUT" == *"accordion"* ]]; then
    ROOT_ICON="󰓩"
elif [[ "$ROOT_LAYOUT" == *"vertical"* ]]; then
    ROOT_ICON="󰕰"
fi

ROOT_COLOR=$SPREN_HONOR
if [[ "$ROOT_LAYOUT" == *"tiles"* ]]; then
    ROOT_COLOR=$SPREN_CULTIVATION
fi

sketchybar --set aero_root_layout icon="$ROOT_ICON" icon.color=$ROOT_COLOR
