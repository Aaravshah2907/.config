#!/bin/bash
source "$HOME/.local/bin/cosmere_colors.sh"

SPACE="${NAME#space.}"

if [ -z "$SELECTED" ]; then
  SELECTED=$(sketchybar --query "$NAME" | jq -r '.selected')
fi

# Define Space Colors
case "$NAME" in
  space.1) SPACE_COLOR=$SPREN_HONOR;;
  space.2) SPACE_COLOR=$SPREN_INK;;
  space.3) SPACE_COLOR=$SPREN_CULTIVATION;;
  space.4) SPACE_COLOR=$SPREN_SIBLING;;
  space.5) SPACE_COLOR=$SPREN_ASH;;
  space.6) SPACE_COLOR=$SPREN_PEAK;;
  space.7) SPACE_COLOR=$SPREN_WILL;;
  *)       SPACE_COLOR=$SPACE_ACCENT;;
esac

SPACE_LABELS=("Terminal" "Code" "Browser" "Chat" "Media" "Misc" "Spotify" "8" "9" "10")
SPACE_NAME="${SPACE_LABELS[$((SPACE - 1))]}"

# Check if space is occupied
WINDOW_COUNT=$(yabai -m query --spaces --space "$SPACE" 2>/dev/null | jq '.windows | length')

if [ "$SENDER" = "mouse.scrolled" ]; then
  if [ "$SCROLL_DELTA" -gt 0 ]; then
    yabai -m space --focus next
  else
    yabai -m space --focus prev
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
  # Empty & Unselected space: Dim dot
  sketchybar --animate tanh 15 --set "space.$SPACE" drawing=on \
    icon="•" icon.color=$PRES_GLACIAL_TRANSLUCENT \
    label.drawing=off \
    background.drawing=off \
    padding_left=4 padding_right=4
fi
