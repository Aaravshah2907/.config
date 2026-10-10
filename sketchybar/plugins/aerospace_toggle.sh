#!/bin/bash
source "$HOME/.local/bin/cosmere_colors.sh"

STATE_FILE="/tmp/aerospace_disabled"

# On click: toggle aerospace and update visuals
if [ "$SENDER" = "mouse.clicked" ]; then
  if [ -f "$STATE_FILE" ]; then
    # Currently disabled → re-enable
    rm -f "$STATE_FILE"
    aerospace enable on 2>/dev/null
    sketchybar --animate tanh 15 \
      --set aero_toggle icon=󱂬 \
                        icon.color=$SPREN_HONOR
    # Restore spaces + app switcher
    sketchybar --set spaces.pill drawing=on \
               --set app_switcher_sep drawing=on
    for sid in 1 2 3 4 5 6; do
      sketchybar --set "space.$sid" drawing=on
    done
    # Trigger updates to redraw spaces + apps
    sketchybar --trigger aerospace_workspace_change
    sketchybar --trigger app_switcher_update
    sketchybar --trigger space_windows_change
    # Restore layout indicators
    sketchybar --set aero_root_layout drawing=on
  else
    # Currently enabled → disable
    touch "$STATE_FILE"
    aerospace enable off 2>/dev/null
    sketchybar --animate tanh 15 \
      --set aero_toggle icon=󱂬 \
                        icon.color=$SPREN_ASH
    # Hide spaces + app switcher
    for sid in 1 2 3 4 5 6; do
      sketchybar --set "space.$sid" drawing=off 2>/dev/null
    done
    sketchybar --set spaces.pill drawing=off
    sketchybar --set app_switcher_sep drawing=off
    # Remove app switcher icons
    sketchybar --remove '/app\.switcher\..*/' 2>/dev/null
    # Hide layout indicators
    sketchybar --set aero_root_layout drawing=off
  fi
  exit 0
fi

# On load / refresh: sync icon to current state
if [ -f "$STATE_FILE" ]; then
  sketchybar --set aero_toggle icon=󱂬 \
                      icon.color=$SPREN_ASH
  sketchybar --set aero_root_layout drawing=off
else
  sketchybar --set aero_toggle icon=󱂬 \
                      icon.color=$SPREN_HONOR
  sketchybar --set aero_root_layout drawing=on
fi
