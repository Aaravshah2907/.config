#!/bin/bash
# mode-changed.sh: Updates sketchybar bar color based on current AeroSpace mode
source "$HOME/.local/bin/cosmere_colors.sh" 2>/dev/null

MODE="${AEROSPACE_MODE:-main}"

case "$MODE" in
    resize)
        sketchybar --animate tanh 15 --bar color="${RADIANT_PURPLE:-0xff8989ff}"
        ;;
    service)
        sketchybar --animate tanh 15 --bar color="${HONOR_GOLD:-0xffFFD700}"
        ;;
    *)
        sketchybar --animate tanh 15 --bar color="${BAR_COLOR:-0xcc001a33}"
        ;;
esac
