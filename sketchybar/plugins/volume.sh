#!/bin/sh
source "$HOME/.local/bin/cosmere_colors.sh"

if [ "$SENDER" = "mouse.clicked" ]; then
  osascript -e "set volume output volume $PERCENTAGE"
  VOLUME=$PERCENTAGE
else
  VOLUME="$INFO"
  if [ -z "$VOLUME" ]; then
    VOLUME=$(osascript -e "output volume of (get volume settings)")
  fi
fi

# Volume levels: Cultivationspren (alive) → Preservation glacial → Ruin spike → Ruin maroon (muted)
case "$VOLUME" in
  [6-9][0-9]|100) ICON="󰕾"; COLOR="$SPREN_CULTIVATION" ;;   # Full — Cultivationspren vibrance
  [3-5][0-9])     ICON="󰖀"; COLOR="$PRES_GLACIAL" ;;          # Mid — Preservation calm
  [1-9]|[1-2][0-9]) ICON="󰕿"; COLOR="$RUIN_SPIKE" ;;         # Low — Hemalurgic amber
  *)              ICON="󰖁"; COLOR="$RUIN_MAROON" ;;           # Muted — Ruin silence
esac

# Update slider
sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" slider.percentage="$VOLUME"
