#!/bin/bash
source "$HOME/.local/bin/cosmere_colors.sh"

SPACE="${NAME#space.}"

# Bail out if AeroSpace is disabled (exam mode)
if [ -f /tmp/aerospace_disabled ]; then
  sketchybar --set "space.$SPACE" drawing=off
  exit 0
fi

# Handle mouse scrolling across spaces
if [ "$SENDER" = "mouse.scrolled" ]; then
  if [ "$SCROLL_DELTA" -gt 0 ]; then
    aerospace workspace next 2>/dev/null
  else
    aerospace workspace prev 2>/dev/null
  fi
  exit 0
fi

# Identify Focused Workspace
if [ "$SENDER" = "aerospace_workspace_change" ]; then
  if [ -n "$FOCUSED_WORKSPACE" ] && [ -n "$PREV_WORKSPACE" ]; then
    if [ "$SPACE" != "$FOCUSED_WORKSPACE" ] && [ "$SPACE" != "$PREV_WORKSPACE" ]; then
      exit 0
    fi
  fi
  SELECTED="$([ "$SPACE" = "$FOCUSED_WORKSPACE" ] && echo "true" || echo "false")"
else
  CURRENT_WORKSPACE=$(aerospace list-workspaces --focused 2>/dev/null)
  SELECTED="$([ "$SPACE" = "$CURRENT_WORKSPACE" ] && echo "true" || echo "false")"
fi

# Glyphs and Spren Colors mapped to Spaces 1-6
SPACE_GLYPHS=("" "" "󰖟" "󰭻" "󰈦" "󰓇")
SPACE_COLORS=($SPREN_HONOR $SPREN_INK $SPREN_CULTIVATION $SPREN_SIBLING $SPREN_ASH $SPREN_PEAK)

IDX=$((SPACE - 1))
GLYPH="${SPACE_GLYPHS[$IDX]:-$SPACE}"
SPACE_COLOR="${SPACE_COLORS[$IDX]:-$SPACE_ACCENT}"

# Sync Active Border Color with Active Space Spren Color
if [ "$SELECTED" = "true" ] && [ ! -f /tmp/battery_saver_active ]; then
  /Users/aaravshah2975/.local/bin/borders active_color="$SPACE_COLOR" 2>/dev/null &
fi

# Query Window Count (filtering out menu bar helpers)
RAW_APPS=$(aerospace list-windows --workspace "$SPACE" --format '%{app-name}' 2>/dev/null | grep -v -E "Google Drive|LocalSend|ControlCenter|Control Center|Raycast|Stats|CleanShot X|Dropover|Ice|Bartender|Hidden Bar|Tuna|Leader-Key|Shortcut Hub")

WINDOW_COUNT=$(echo "$RAW_APPS" | grep -v '^$' | wc -l | tr -d ' ')
[ -z "$WINDOW_COUNT" ] && WINDOW_COUNT=0

# Format: <window_number> <window_icon> (<number_of_apps_opened>)
DISPLAY_TEXT="$GLYPH ($WINDOW_COUNT)"

# Render based on Selection and Window Count
if [ "$SELECTED" = "true" ]; then
  # Selected space: Focused Pill with Number + Icon + Count
  sketchybar --animate tanh 15 --set "space.$SPACE" drawing=on \
    icon="$SPACE" icon.drawing=on icon.font="JetBrainsMono Nerd Font:Bold:12.0" icon.color=$BAR_COLOR \
    label="$DISPLAY_TEXT" label.drawing=on label.font="Hack Nerd Font:Bold:12.0" label.color=$BAR_COLOR \
    background.drawing=on background.color=$SPACE_COLOR background.corner_radius=8 \
    padding_left=3 padding_right=3 icon.padding_left=6 icon.padding_right=2 label.padding_right=6
elif [ "$WINDOW_COUNT" -gt 0 ]; then
  # Occupied but Unselected space: Colored Number + Icon + Count
  sketchybar --animate tanh 15 --set "space.$SPACE" drawing=on \
    icon="$SPACE" icon.drawing=on icon.font="JetBrainsMono Nerd Font:Bold:12.0" icon.color=$SPACE_COLOR \
    label="$DISPLAY_TEXT" label.drawing=on label.font="Hack Nerd Font:Regular:12.0" label.color=$SPACE_COLOR \
    background.drawing=on background.color=$PRES_DEEP_TRANSLUCENT background.corner_radius=6 \
    padding_left=3 padding_right=3 icon.padding_left=4 icon.padding_right=2 label.padding_right=4
else
  # Empty & Unselected space: Subtle ghosted Number + Icon + (0)
  sketchybar --animate tanh 15 --set "space.$SPACE" drawing=on \
    icon="$SPACE" icon.drawing=on icon.font="JetBrainsMono Nerd Font:Regular:12.0" icon.color=0x66607D8B \
    label="$DISPLAY_TEXT" label.drawing=on label.font="Hack Nerd Font:Regular:12.0" label.color=0x66607D8B \
    background.drawing=off \
    padding_left=3 padding_right=3 icon.padding_left=4 icon.padding_right=2 label.padding_right=4
fi
