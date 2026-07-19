#!/bin/bash
source "$HOME/.local/bin/cosmere_colors.sh"
source "$HOME/.config/shell/functions.sh"

STATE_FILE="/tmp/sketchybar_focus.state"

if [ "$SENDER" = "mouse.clicked" ]; then
  if [ -f "$STATE_FILE" ]; then
    rm -f "$STATE_FILE"
    sketchybar --set focus_toggle icon=󰈈 icon.color=$PRES_GLACIAL
    sketchybar --set bar color=$DEEP_NIGHT
    # Try to disable DND
    /usr/bin/shortcuts run "Turn Off Do Not Disturb" 2>/dev/null
    alert "🟢 Focus Mode OFF — DND disabled, you're back online." &
  else
    touch "$STATE_FILE"
    sketchybar --set focus_toggle icon=󰈉 icon.color=$RUIN_MAROON
    sketchybar --set bar color=$RUIN_OBSIDIAN
    # Mute volume
    osascript -e 'set volume with output muted' 2>/dev/null
    # Try to enable DND
    /usr/bin/shortcuts run "Turn On Do Not Disturb" 2>/dev/null
    alert "🔴 Focus Mode ON — Volume muted, DND enabled. Go deep." &
  fi
fi

