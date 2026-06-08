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

# CPU usage detection (average across cores)
CPU_PCT=$(ps -A -o %cpu | awk '{sum+=$1} END {print int(sum/NR)}')
if [ -z "$CPU_PCT" ]; then CPU_PCT=0; fi

# Set color based on CPU usage (>70% warning)
if [ "$CPU_PCT" -gt 70 ]; then
  CPU_COLOR="$RED"
  sketchybar --set system.cpu label="CPU: ${CPU_PCT}%" label.color="$CPU_COLOR"
  # Shake animation for warning
  sketchybar --animate system icon.y_offset -4 4 duration=150 repeat=3
else
  sketchybar --set system.cpu label="CPU: ${CPU_PCT}%" label.color="$WHITE"
fi

# --- Disk Info (Material World) ---
DISK_INFO=$(df -H /System/Volumes/Data | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')
sketchybar --set system.disk label="Disk: ${DISK_INFO}" label.color="$SAPPHIRE"
