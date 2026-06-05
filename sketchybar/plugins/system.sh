#!/usr/bin/env bash
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
source "$HOME/.config/sketchybar/colors.sh"

# Handle hover for system monitor
if [ "$SENDER" = "mouse.entered" ]; then
  sketchybar --set "$NAME" popup.drawing=on
  exit 0
fi

if [ "$SENDER" = "mouse.exited" ]; then
  sketchybar --set "$NAME" popup.drawing=off
  exit 0
fi

# --- RAM Info (Investiture) ---
FREE_PCT=$(memory_pressure 2>/dev/null | awk '/System-wide memory free percentage:/ {print $5}' | tr -d '%')
if [ -n "$FREE_PCT" ]; then
  USED_PCT=$((100 - FREE_PCT))
  COLOR="$HONOR_GOLD"
  [ "$USED_PCT" -gt 70 ] && COLOR="$AMBER"
  [ "$USED_PCT" -gt 90 ] && COLOR="$RED"
  
  sketchybar --set system.ram label="Memory: ${USED_PCT}%" label.color="$COLOR"
fi

# --- Disk Info (Material World) ---
DISK_INFO=$(df -H /System/Volumes/Data | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')
sketchybar --set system.disk label="Disk: ${DISK_INFO}" label.color="$SAPPHIRE"
