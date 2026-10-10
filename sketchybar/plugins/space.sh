#!/bin/bash
source "$HOME/.local/bin/cosmere_colors.sh"

SPACE="${NAME#space.}"

# Bail out if Dinky is disabled
if [ -f /tmp/dinky_disabled ]; then
  sketchybar --set "space.$SPACE" drawing=off
  exit 0
fi

# Handle mouse scrolling across spaces
if [ "$SENDER" = "mouse.scrolled" ]; then
  if [ "$SCROLL_DELTA" -gt 0 ]; then
    dinky workspace next 2>/dev/null
  else
    dinky workspace prev 2>/dev/null
  fi
  exit 0
fi

# Resolve Focused Workspace
FW="${FOCUSED_WORKSPACE:-$DINKY_WORKSPACE}"
PW="${PREV_WORKSPACE:-$DINKY_PREV_WORKSPACE}"

if [ -n "$FW" ]; then
  if [ "$SENDER" = "dinky_workspace_change" ] || [ "$SENDER" = "aerospace_workspace_change" ]; then
    if [ -n "$PW" ] && [ "$SPACE" != "$FW" ] && [ "$SPACE" != "$PW" ]; then
      exit 0
    fi
  fi
  SELECTED="$([ "$SPACE" = "$FW" ] && echo "true" || echo "false")"
else
  CURRENT_WORKSPACE=$(dinky list-workspaces --focused 2>/dev/null)
  [ -z "$CURRENT_WORKSPACE" ] && CURRENT_WORKSPACE=$(aerospace list-workspaces --focused 2>/dev/null)
  SELECTED="$([ "$SPACE" = "$CURRENT_WORKSPACE" ] && echo "true" || echo "false")"
fi

# Glyphs and Spren Colors mapped to Spaces 1-6
SPACE_GLYPHS=("" "" "󰖟" "󰭻" "󰈦" "󰓇")
SPACE_COLORS=($SPREN_HONOR $SPREN_INK $SPREN_CULTIVATION $SPREN_SIBLING $SPREN_ASH $SPREN_PEAK)

IDX=$((SPACE - 1))
GLYPH="${SPACE_GLYPHS[$IDX]:-$SPACE}"
SPACE_COLOR="${SPACE_COLORS[$IDX]:-$SPACE_ACCENT}"

# Query Window Count (filtering out menu bar helpers & floating windows with empty title)
RAW_DATA=$(dinky list-windows --workspace "$SPACE" --format '%{app-name}|%{window-is-floating}|%{window-title}' 2>/dev/null)

ACTIVE_APPS=$(echo "$RAW_DATA" | while IFS='|' read -r APP IS_FLOAT TITLE; do
  [ -z "$APP" ] && continue
  case "$APP" in
    "Google Drive"|"LocalSend"|"ControlCenter"|"Control Center"|"Raycast"|"Stats"|"CleanShot X"|"Dropover"|"Ice"|"Bartender"|"Hidden Bar"|"Tuna"|"Leader-Key"|"Shortcut Hub")
      continue
      ;;
  esac
  # Exclude floating windows with empty titles (invisible menu bar anchor windows)
  if [ "$IS_FLOAT" = "true" ] && [ -z "$TITLE" ]; then
    continue
  fi
  echo "$APP"
done)

WINDOW_COUNT=$(echo "$ACTIVE_APPS" | grep -v '^$' | wc -l | tr -d ' ')
[ -z "$WINDOW_COUNT" ] && WINDOW_COUNT=0

# Render based on Selection and Window Count
if [ "$SELECTED" = "true" ]; then
  # Selected space: Focused Pill with Icon + Count
  if [ "$WINDOW_COUNT" -gt 0 ]; then
    DISPLAY_LABEL="($WINDOW_COUNT)"
  else
    DISPLAY_LABEL=""
  fi
  
  sketchybar --animate tanh 15 --set "space.$SPACE" drawing=on \
    icon="$GLYPH" icon.drawing=on icon.font="Hack Nerd Font:Bold:14.0" icon.color=$BAR_COLOR \
    label="$DISPLAY_LABEL" label.drawing="$([ -n "$DISPLAY_LABEL" ] && echo "on" || echo "off")" \
    label.font="JetBrainsMono Nerd Font:Bold:11.0" label.color=$BAR_COLOR \
    background.drawing=on background.color=$SPACE_COLOR background.corner_radius=8 \
    padding_left=3 padding_right=3 icon.padding_left=6 icon.padding_right=4 label.padding_right=6
elif [ "$WINDOW_COUNT" -gt 0 ]; then
  # Occupied but Unselected space: Colored Icon with (N) count
  sketchybar --animate tanh 15 --set "space.$SPACE" drawing=on \
    icon="$GLYPH" icon.drawing=on icon.font="Hack Nerd Font:Bold:14.0" icon.color=$SPACE_COLOR \
    label="($WINDOW_COUNT)" label.drawing=on label.font="JetBrainsMono Nerd Font:Regular:11.0" label.color=$SPACE_COLOR \
    background.drawing=on background.color=$PRES_DEEP_TRANSLUCENT background.corner_radius=6 \
    padding_left=3 padding_right=3 icon.padding_left=4 icon.padding_right=2 label.padding_right=4
else
  # Empty & Unselected space: Subtle ghosted icon
  sketchybar --animate tanh 15 --set "space.$SPACE" drawing=on \
    icon="$GLYPH" icon.drawing=on icon.font="Hack Nerd Font:Regular:13.0" icon.color=0x44607D8B \
    label.drawing=off \
    background.drawing=off \
    padding_left=3 padding_right=3 icon.padding_left=4 icon.padding_right=4
fi
