#!/bin/bash
source "$HOME/.local/bin/cosmere_colors.sh"

# On click: toggle layout menu popup
if [ "$SENDER" = "mouse.clicked" ]; then
    sketchybar --set aero_root_layout popup.drawing=toggle
    exit 0
fi

# Query current layouts and update icons & colors
ROOT_LAYOUT=$(aerospace list-workspaces --focused --format '%{workspace-root-container-layout}' 2>/dev/null)
CONT_LAYOUT=$(aerospace list-windows --focused --format '%{window-parent-container-layout}' 2>/dev/null)

# Icons: 󰒡 tiles horizontal, 󰕰 tiles vertical, 󰓩 accordion
ROOT_ICON="󰒡"
if [[ "$ROOT_LAYOUT" == *"accordion"* ]]; then
    ROOT_ICON="󰓩"
elif [[ "$ROOT_LAYOUT" == *"vertical"* ]]; then
    ROOT_ICON="󰕰"
fi

CONT_ICON="󰒡"
if [[ "$CONT_LAYOUT" == *"accordion"* ]]; then
    CONT_ICON="󰓩"
elif [[ "$CONT_LAYOUT" == *"vertical"* ]]; then
    CONT_ICON="󰕰"
fi

# Green (Cultivation) = tiles horizontal, Blue (Honor) = accordion, Purple/Glacial = vertical
ROOT_COLOR=$SPREN_HONOR
if [[ "$ROOT_LAYOUT" == *"tiles"* ]]; then
    ROOT_COLOR=$SPREN_CULTIVATION
fi

CONT_COLOR=$SPREN_HONOR
if [[ "$CONT_LAYOUT" == *"tiles"* ]]; then
    CONT_COLOR=$SPREN_CULTIVATION
fi

sketchybar --set aero_root_layout icon="$ROOT_ICON" icon.color=$ROOT_COLOR \
           --set aero_cont_layout icon="$CONT_ICON" icon.color=$CONT_COLOR
