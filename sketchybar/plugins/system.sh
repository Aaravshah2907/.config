#!/usr/bin/env bash
source "$HOME/.config/sketchybar/colors.sh"

# --- RAM Info (Investiture) ---
FREE_PCT=$(memory_pressure 2>/dev/null | awk '/System-wide memory free percentage:/ {print $5}' | tr -d '%')
if [ -n "$FREE_PCT" ]; then
  USED_PCT=$((100 - FREE_PCT))
  COLOR="$HONOR_GOLD"
  [ "$USED_PCT" -gt 70 ] && COLOR="$AMBER"
  [ "$USED_PCT" -gt 90 ] && COLOR="$RED"
  
  /opt/homebrew/bin/sketchybar --set system.ram.text label="Investiture: ${USED_PCT}%" label.color="$COLOR"
fi

# --- Disk Info (Material World) ---
DISK_INFO=$(df -H /System/Volumes/Data | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')
/opt/homebrew/bin/sketchybar --set system.disk label="Material: ${DISK_INFO}" label.color="$SAPPHIRE"
