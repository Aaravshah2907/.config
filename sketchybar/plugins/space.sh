#!/bin/bash
source "$HOME/.local/bin/cosmere_colors.sh"

SPACE="${NAME#space.}"

# Bail out if AeroSpace is disabled (exam mode)
if [ -f /tmp/aerospace_disabled ]; then
  sketchybar --set "space.$SPACE" drawing=off
  exit 0
fi

if [ "$SENDER" = "aerospace_workspace_change" ]; then
  if [ "$SPACE" = "$FOCUSED_WORKSPACE" ]; then
    SELECTED="true"
  else
    SELECTED="false"
  fi
else
  if [ -z "$SELECTED" ]; then
    CURRENT_WORKSPACE=$(aerospace list-workspaces --focused 2>/dev/null)
    if [ "$SPACE" = "$CURRENT_WORKSPACE" ]; then
      SELECTED="true"
    else
      SELECTED="false"
    fi
  fi
fi

# Define Space Colors
case "$SPACE" in
  1|T) SPACE_COLOR=$SPREN_HONOR;;
  2|C) SPACE_COLOR=$SPREN_INK;;
  3|B) SPACE_COLOR=$SPREN_CULTIVATION;;
  4|M) SPACE_COLOR=$SPREN_SIBLING;;
  5|V) SPACE_COLOR=$SPREN_ASH;;
  6|S) SPACE_COLOR=$SPREN_PEAK;;
  7|E) SPACE_COLOR=$SPREN_WILL;;
  8|A) SPACE_COLOR=$SPREN_CRYPTIC;;
  *)   SPACE_COLOR=$SPACE_ACCENT;;
esac

SPACE_LABELS=("Terminal" "Code" "Browser" "Chat" "Media" "Spotify" "Study" "AI" "Preview")
SPACE_SIDS=("T" "C" "B" "M" "V" "S" "E" "A" "P")

IDX=-1
for i in "${!SPACE_SIDS[@]}"; do
  if [ "${SPACE_SIDS[$i]}" = "$SPACE" ]; then
    IDX=$i
    break
  fi
done

if [ $IDX -ne -1 ]; then
  SPACE_NAME="${SPACE_LABELS[$IDX]}"
else
  SPACE_NAME="$SPACE"
fi

# Check if space is occupied
WINDOW_COUNT=$(aerospace list-windows --workspace "$SPACE" --count 2>/dev/null || echo 0)

if [ "$SENDER" = "mouse.scrolled" ]; then
  if [ "$SCROLL_DELTA" -gt 0 ]; then
    aerospace workspace next
  else
    aerospace workspace prev
  fi
  exit 0
fi

# Zen Dots Logic
if [ "$SELECTED" = "true" ]; then
  # Selected space: Expand into pill
  sketchybar --animate tanh 15 --set "space.$SPACE" drawing=on \
    icon=" " \
    label="$SPACE_NAME" label.drawing=on \
    label.color=$BAR_COLOR \
    background.drawing=on background.color=$SPACE_COLOR background.border_width=0 background.corner_radius=8 \
    padding_left=4 padding_right=4 label.padding_right=8
elif [ "$WINDOW_COUNT" -gt 0 ] 2>/dev/null; then
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
