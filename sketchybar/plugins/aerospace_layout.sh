#!/bin/bash
source "$HOME/.local/bin/cosmere_colors.sh"

# On click: toggle the relevant layout
if [ "$SENDER" = "mouse.clicked" ]; then
    if [ "$NAME" = "aero_root_layout" ]; then
        # Toggle root layout between tiles and accordion
        aerospace layout --workspace focused tiles accordion 2>/dev/null
    elif [ "$NAME" = "aero_cont_layout" ]; then
        # Toggle focused container layout between tiles and accordion
        aerospace layout tiles accordion 2>/dev/null
    fi
    sketchybar --trigger aerospace_layout_change
    exit 0
fi

# Query current layouts and update icon colors
ROOT_LAYOUT=$(aerospace list-workspaces --focused --format '%{workspace-root-container-layout}' 2>/dev/null)
CONT_LAYOUT=$(aerospace list-windows --focused --format '%{window-parent-container-layout}' 2>/dev/null)

# Green (Cultivation) = tiles, Blue (Honor) = accordion
ROOT_COLOR=$SPREN_HONOR
if [[ "$ROOT_LAYOUT" == *"tiles"* ]]; then
    ROOT_COLOR=$SPREN_CULTIVATION
fi

CONT_COLOR=$SPREN_HONOR
if [[ "$CONT_LAYOUT" == *"tiles"* ]]; then
    CONT_COLOR=$SPREN_CULTIVATION
fi

sketchybar --set aero_root_layout icon.color=$ROOT_COLOR \
           --set aero_cont_layout icon.color=$CONT_COLOR
