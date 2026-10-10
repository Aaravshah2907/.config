#!/bin/bash
source "$HOME/.local/bin/cosmere_colors.sh"

# On click: toggle layout menu popup
if [ "$SENDER" = "mouse.clicked" ]; then
    sketchybar --set wm_layout popup.drawing=toggle
    exit 0
fi

# Query layout or default to tiles
CURRENT_LAYOUT="tiles"

# Icons: 󰒡 tiles, 󰓩 accordion
LAYOUT_ICON="󰒡"
LAYOUT_COLOR=$SPREN_CULTIVATION

if [[ "$CURRENT_LAYOUT" == *"accordion"* ]]; then
    LAYOUT_ICON="󰓩"
    LAYOUT_COLOR=$SPREN_HONOR
fi

sketchybar --set wm_layout icon="$LAYOUT_ICON" icon.color=$LAYOUT_COLOR
