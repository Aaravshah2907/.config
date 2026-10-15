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

# Optimization: Only re-render the space being focused and the space being left
if [ "$SENDER" = "aerospace_workspace_change" ]; then
  if [ -n "$FOCUSED_WORKSPACE" ] && [ -n "$PREV_WORKSPACE" ]; then
    if [ "$SPACE" != "$FOCUSED_WORKSPACE" ] && [ "$SPACE" != "$PREV_WORKSPACE" ]; then
      exit 0
    fi
  fi

  if [ "$SPACE" = "$FOCUSED_WORKSPACE" ]; then
    SELECTED="true"
  else
    SELECTED="false"
  fi
else
  CURRENT_WORKSPACE=$(aerospace list-workspaces --focused 2>/dev/null)
  if [ "$SPACE" = "$CURRENT_WORKSPACE" ]; then
    SELECTED="true"
  else
    SELECTED="false"
  fi
fi

# Define Space Colors and Names
case "$SPACE" in
  1|T) SPACE_COLOR=$SPREN_HONOR;       SPACE_NAME="Terminal";;
  2|C) SPACE_COLOR=$SPREN_INK;         SPACE_NAME="Code";;
  3|B) SPACE_COLOR=$SPREN_CULTIVATION; SPACE_NAME="Browser";;
  4|M) SPACE_COLOR=$SPREN_SIBLING;     SPACE_NAME="Chat";;
  5|V) SPACE_COLOR=$SPREN_ASH;         SPACE_NAME="Media";;
  6|S) SPACE_COLOR=$SPREN_PEAK;        SPACE_NAME="Spotify";;
  7|E) SPACE_COLOR=$SPREN_WILL;        SPACE_NAME="Study";;
  8|A) SPACE_COLOR=$SPREN_CRYPTIC;     SPACE_NAME="AI";;
  P)   SPACE_COLOR=$SPREN_STORM;       SPACE_NAME="Preview";;
  *)   SPACE_COLOR=$SPACE_ACCENT;      SPACE_NAME="$SPACE";;
esac

# Sync Active Border Color with Active Space Spren Color
if [ "$SELECTED" = "true" ] && [ ! -f /tmp/battery_saver_active ]; then
  /Users/aaravshah2975/.local/bin/borders active_color="$SPACE_COLOR" 2>/dev/null &
fi

# Query Window Count (filtering out menu bar helpers)
RAW_APPS=$(aerospace list-windows --workspace "$SPACE" --format '%{app-name}' 2>/dev/null | grep -v -E "Google Drive|LocalSend|ControlCenter|Control Center|Raycast|Stats|CleanShot X|Dropover|Ice|Bartender|Hidden Bar|Tuna|Leader-Key|Shortcut Hub")

WINDOW_COUNT=$(echo "$RAW_APPS" | grep -v '^$' | wc -l | tr -d ' ')
[ -z "$WINDOW_COUNT" ] && WINDOW_COUNT=0

# Zen Dots Logic with Window Counter
if [ "$SELECTED" = "true" ]; then
  # Selected space: Expand into pill showing label and open window count
  DISPLAY_LABEL="$SPACE_NAME"
  if [ "$WINDOW_COUNT" -gt 0 ]; then
    DISPLAY_LABEL="$SPACE_NAME ($WINDOW_COUNT)"
  fi
  sketchybar --animate tanh 15 --set "space.$SPACE" drawing=on \
    icon=" " \
    label="$DISPLAY_LABEL" label.drawing=on \
    label.font="Hack Nerd Font:Bold:12.0" \
    label.color=$BAR_COLOR \
    background.drawing=on background.color=$SPACE_COLOR background.border_width=0 background.corner_radius=8 \
    padding_left=4 padding_right=4 label.padding_right=8
elif [ "$WINDOW_COUNT" -gt 0 ]; then
  # Occupied but Unselected space: Bright dot
  sketchybar --animate tanh 15 --set "space.$SPACE" drawing=on \
    icon="•" icon.color=$SPACE_COLOR \
    label.drawing=off \
    background.drawing=off \
    padding_left=4 padding_right=4
else
  # Empty & Unselected space: Hide completely
  sketchybar --animate tanh 15 --set "space.$SPACE" drawing=off
fi
