#!/bin/bash
source "$HOME/.local/bin/cosmere_colors.sh"

SPACE="${NAME#space.}"

# Bail out if AeroSpace is disabled (exam mode)
if [ -f /tmp/aerospace_disabled ]; then
  sketchybar --set "space.$SPACE" drawing=off
  exit 0
fi

# Handle clicking on any workspace item
if [ "$SENDER" = "mouse.clicked" ]; then
  aerospace workspace "$SPACE" 2>/dev/null
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

# Distinct Cosmere Colors & Standard Functional Icons
case "$SPACE" in
  T) 
    SPACE_COLOR=$SPREN_HONOR       # Sky Blue (0xff00A8E8)
    GLYPH=""                      # Standard Terminal Prompt
    ;;
  C) 
    SPACE_COLOR=$SPREN_INK         # Indigo Violet (0xff8A2BE2)
    GLYPH=""                      # Standard Code Brackets
    ;;
  B) 
    SPACE_COLOR=$SPREN_CULTIVATION # Emerald Green (0xff3CB371)
    GLYPH="󰖟"                      # Standard Web Globe
    ;;
  M) 
    SPACE_COLOR=$HONOR_GOLD        # Radiant Gold (0xffFFD700)
    GLYPH="󰭻"                      # Standard Chat Message Bubble
    ;;
  S) 
    SPACE_COLOR=$SPREN_SIBLING     # Warm Amber (0xffFFAB40)
    GLYPH="󰓇"                      # Spotify Logo
    ;;
  V) 
    SPACE_COLOR=$SPREN_ASH         # Crimson Red (0xffFF4500)
    GLYPH=""                      # Media Play Button
    ;;
  E) 
    SPACE_COLOR=$SPREN_WILL        # Electric Magenta (0xffE040FB)
    GLYPH="󰈦"                      # Study Book
    ;;
  A) 
    SPACE_COLOR=$PRES_MIST         # Icy Cyan (0xffC8E8F5)
    GLYPH="󱚣"                      # AI Sparkle / Bot
    ;;
  P) 
    SPACE_COLOR=$PRES_GLACIAL      # Glacial Teal (0xff5DA8CC)
    GLYPH="󰈙"                      # Preview Document
    ;;
  *) 
    SPACE_COLOR=$SPACE_ACCENT
    GLYPH="󰒡"
    ;;
esac

# Sync Active Border Color with Active Space Spren Color
if [ "$SELECTED" = "true" ] && [ ! -f /tmp/battery_saver_active ]; then
  /Users/aaravshah2975/.local/bin/borders active_color="$SPACE_COLOR" 2>/dev/null &
fi

# Query Window Count (filtering out menu bar helpers)
RAW_APPS=$(aerospace list-windows --workspace "$SPACE" --format '%{app-name}' 2>/dev/null | grep -v -E "Google Drive|LocalSend|ControlCenter|Control Center|Raycast|Stats|CleanShot X|Dropover|Ice|Bartender|Hidden Bar|Tuna|Leader-Key|Shortcut Hub")

WINDOW_COUNT=$(echo "$RAW_APPS" | grep -v '^$' | wc -l | tr -d ' ')
[ -z "$WINDOW_COUNT" ] && WINDOW_COUNT=0

# Render based on Selection and Window Count
if [ "$SELECTED" = "true" ]; then
  # Active (focused) space: Solid Spren-colored pill with high-contrast text/icon
  DISPLAY_COUNT=""
  if [ "$WINDOW_COUNT" -gt 0 ]; then
    DISPLAY_COUNT="($WINDOW_COUNT)"
  fi
  sketchybar --animate tanh 15 --set "space.$SPACE" drawing=on \
    icon="$SPACE $GLYPH" icon.drawing=on icon.font="Hack Nerd Font:Bold:12.0" icon.color=$BAR_COLOR \
    label="$DISPLAY_COUNT" label.drawing="$([ -n "$DISPLAY_COUNT" ] && echo "on" || echo "off")" \
    label.font="JetBrainsMono Nerd Font:Bold:11.0" label.color=$BAR_COLOR \
    background.drawing=on background.color=$SPACE_COLOR background.corner_radius=7 \
    padding_left=3 padding_right=3 icon.padding_left=5 icon.padding_right=2 label.padding_right=5
elif [ "$WINDOW_COUNT" -gt 0 ]; then
  # Occupied space (has windows): Colored according to space with translucent background
  sketchybar --animate tanh 15 --set "space.$SPACE" drawing=on \
    icon="$SPACE $GLYPH" icon.drawing=on icon.font="Hack Nerd Font:Bold:12.0" icon.color=$SPACE_COLOR \
    label="($WINDOW_COUNT)" label.drawing=on label.font="JetBrainsMono Nerd Font:Regular:11.0" label.color=$SPACE_COLOR \
    background.drawing=on background.color=$PRES_DEEP_TRANSLUCENT background.corner_radius=6 \
    padding_left=3 padding_right=3 icon.padding_left=4 icon.padding_right=2 label.padding_right=4
else
  # Empty space: Greyed out, no background, clickable to switch
  sketchybar --animate tanh 15 --set "space.$SPACE" drawing=on \
    icon="$SPACE $GLYPH" icon.drawing=on icon.font="Hack Nerd Font:Regular:12.0" icon.color=0x448899a8 \
    label.drawing=off \
    background.drawing=off \
    padding_left=3 padding_right=3 icon.padding_left=4 icon.padding_right=4
fi
