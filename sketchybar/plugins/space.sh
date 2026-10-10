#!/bin/bash
source "$HOME/.local/bin/cosmere_colors.sh"
source "$HOME/.config/sketchybar/plugins/icon_map.sh"

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

# Spren Colors mapped to Spaces 1-6
case "$SPACE" in
  1) SPACE_COLOR=$SPREN_HONOR;;
  2) SPACE_COLOR=$SPREN_INK;;
  3) SPACE_COLOR=$SPREN_CULTIVATION;;
  4) SPACE_COLOR=$SPREN_SIBLING;;
  5) SPACE_COLOR=$SPREN_ASH;;
  6) SPACE_COLOR=$SPREN_PEAK;;
  *) SPACE_COLOR=$SPACE_ACCENT;;
esac

SPACE_NAMES=("Terminal" "Code" "Web" "Chat & AI" "Media & Docs" "Spotify")
IDX=$((SPACE - 1))
NAME_LABEL="${SPACE_NAMES[$IDX]:-$SPACE}"

# Query Windows on this Workspace
RAW_WINDOWS=$(dinky list-windows --workspace "$SPACE" 2>/dev/null)
if [ -z "$RAW_WINDOWS" ] && command -v aerospace >/dev/null 2>&1; then
  RAW_WINDOWS=$(aerospace list-windows --workspace "$SPACE" --format '%{app-name}' 2>/dev/null)
fi

FOCUSED_APP=$(dinky list-windows --focused 2>/dev/null | awk -F' \\| ' '{print $2}')
[ -z "$FOCUSED_APP" ] && command -v aerospace >/dev/null 2>&1 && FOCUSED_APP=$(aerospace list-windows --focused --format '%{app-name}' 2>/dev/null)

if [ -z "$RAW_WINDOWS" ]; then
  # Empty Workspace: Subtle Space indicator
  if [ "$SELECTED" = "true" ]; then
    sketchybar --animate tanh 15 --set "space.$SPACE" drawing=on \
      icon="$SPACE" icon.drawing=on icon.font="JetBrainsMono Nerd Font:Bold:12.0" icon.color=$BAR_COLOR \
      label="$NAME_LABEL" label.drawing=on label.font="JetBrainsMono Nerd Font:Bold:12.0" label.color=$BAR_COLOR \
      background.drawing=on background.color=$SPACE_COLOR background.corner_radius=8 \
      padding_left=4 padding_right=4 icon.padding_left=6 icon.padding_right=4 label.padding_right=8
  else
    sketchybar --animate tanh 15 --set "space.$SPACE" drawing=on \
      icon="$SPACE" icon.drawing=on icon.font="JetBrainsMono Nerd Font:Regular:12.0" icon.color=0x66607D8B \
      label.drawing=off \
      background.drawing=off \
      padding_left=4 padding_right=4 icon.padding_left=4 icon.padding_right=4
  fi
  exit 0
fi

# Extract Unique App Names
APPS=$(echo "$RAW_WINDOWS" | awk -F' \\| ' '{print $2}' | awk NF | awk '!seen[$0]++')
[ -z "$APPS" ] && APPS=$(echo "$RAW_WINDOWS" | awk '!seen[$0]++')

# Build App Icon Strip
ICON_STRIP=""
WINDOW_COUNT=0
while read -r APP; do
  [ -z "$APP" ] && continue
  WINDOW_COUNT=$((WINDOW_COUNT + 1))
  __icon_map_custom "$APP" || __icon_map "$APP"
  ICON="$icon_result"
  [ -z "$ICON" ] && ICON=":default:"
  ICON_STRIP+="$ICON "
done <<< "$APPS"

ICON_STRIP=$(echo "$ICON_STRIP" | sed 's/ *$//')

# Render Workspace Pill with App Icons
if [ "$SELECTED" = "true" ]; then
  DISPLAY_LABEL="$ICON_STRIP"
  [ -n "$NAME_LABEL" ] && DISPLAY_LABEL="$NAME_LABEL $ICON_STRIP"
  
  sketchybar --animate tanh 15 --set "space.$SPACE" drawing=on \
    icon="$SPACE" icon.drawing=on icon.font="JetBrainsMono Nerd Font:Bold:12.0" icon.color=$BAR_COLOR \
    label="$DISPLAY_LABEL" label.drawing=on label.font="sketchybar-app-font:Regular:13.0" label.color=$BAR_COLOR \
    background.drawing=on background.color=$SPACE_COLOR background.corner_radius=8 \
    padding_left=4 padding_right=4 icon.padding_left=6 icon.padding_right=4 label.padding_right=8
else
  sketchybar --animate tanh 15 --set "space.$SPACE" drawing=on \
    icon="$SPACE" icon.drawing=on icon.font="JetBrainsMono Nerd Font:Bold:12.0" icon.color=$SPACE_COLOR \
    label="$ICON_STRIP" label.drawing=on label.font="sketchybar-app-font:Regular:13.0" label.color=$WHITE \
    background.drawing=on background.color=$PRES_DEEP_TRANSLUCENT background.corner_radius=6 \
    padding_left=4 padding_right=4 icon.padding_left=4 icon.padding_right=4 label.padding_right=6
fi
