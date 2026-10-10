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

# Identify Focused Workspace
if [ "$SENDER" = "dinky_workspace_change" ] || [ "$SENDER" = "aerospace_workspace_change" ]; then
  if [ -n "$FOCUSED_WORKSPACE" ] && [ -n "$PREV_WORKSPACE" ]; then
    if [ "$SPACE" != "$FOCUSED_WORKSPACE" ] && [ "$SPACE" != "$PREV_WORKSPACE" ]; then
      exit 0
    fi
  fi
  SELECTED="$([ "$SPACE" = "$FOCUSED_WORKSPACE" ] && echo "true" || echo "false")"
else
  CURRENT_WORKSPACE=$(dinky list-workspaces 2>/dev/null | grep '\*' | awk '{print $1}')
  [ -z "$CURRENT_WORKSPACE" ] && CURRENT_WORKSPACE=$(aerospace list-workspaces --focused 2>/dev/null)
  SELECTED="$([ "$SPACE" = "$CURRENT_WORKSPACE" ] && echo "true" || echo "false")"
fi

# Glyphs and Spren Colors mapped to Spaces 1-6
SPACE_GLYPHS=("" "" "󰖟" "󰭻" "󰈦" "󰓇")
SPACE_COLORS=($SPREN_HONOR $SPREN_INK $SPREN_CULTIVATION $SPREN_SIBLING $SPREN_ASH $SPREN_PEAK)

IDX=$((SPACE - 1))
GLYPH="${SPACE_GLYPHS[$IDX]:-$SPACE}"
SPACE_COLOR="${SPACE_COLORS[$IDX]:-$SPACE_ACCENT}"

# Query Window Count (filtering out background daemons)
RAW_APPS=$(dinky list-windows --workspace "$SPACE" --format '%{app-name}' 2>/dev/null | grep -v -E "Google Drive|LocalSend|ControlCenter" | awk NF)
if [ -z "$RAW_APPS" ] && command -v aerospace >/dev/null 2>&1; then
  RAW_APPS=$(aerospace list-windows --workspace "$SPACE" --format '%{app-name}' 2>/dev/null | grep -v -E "Google Drive|LocalSend|ControlCenter" | awk NF)
fi

WINDOW_COUNT=$(echo "$RAW_APPS" | grep -v '^$' | wc -l | tr -d ' ')
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
