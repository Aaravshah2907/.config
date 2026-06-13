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
else
  USED_PCT=0
fi

# CPU usage detection (average across cores)
CPU_PCT=$(ps -A -o %cpu | awk '{sum+=$1} END {print int(sum/NR)}')
if [ -z "$CPU_PCT" ]; then CPU_PCT=0; fi

# Set color based on CPU usage (>70% warning)
if [ "$CPU_PCT" -gt 70 ]; then
  CPU_COLOR="$RED"
else
  CPU_COLOR="$WHITE"
fi
sketchybar --set system.cpu label="CPU: ${CPU_PCT}%" label.color="$CPU_COLOR"

# --- Disk Info (Material World) ---
DISK_INFO=$(df -H /System/Volumes/Data | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')
sketchybar --set system.disk label="Disk: ${DISK_INFO}" label.color="$SAPPHIRE"

# --- Storm Severity Mapping ---
if [ "$CPU_PCT" -gt 70 ] || [ "$USED_PCT" -gt 80 ]; then
  STORM_STATE="Everstorm Clash"
  STORM_ICON="󰖓" # Weather Lightning (Everstorm)
  STORM_COLOR="$RED"
  # Shake animation for warning
  sketchybar --animate system icon.y_offset -4 4 duration=150 repeat=3
elif [ "$CPU_PCT" -gt 30 ] || [ "$USED_PCT" -gt 50 ]; then
  STORM_STATE="Highstorm"
  STORM_ICON="󰖖" # Weather Pouring (Highstorm)
  STORM_COLOR="$AMBER"
else
  STORM_STATE="Stormless"
  STORM_ICON="󰖙" # Weather Sunny/Clear (Stormless)
  STORM_COLOR="$SAPPHIRE"
fi

sketchybar --set system.title \
  icon="$STORM_ICON" \
  icon.color="$STORM_COLOR" \
  label="Storm: $STORM_STATE" \
  label.color="$STORM_COLOR"

sketchybar --set system \
  icon="$STORM_ICON" \
  icon.color="$STORM_COLOR" \
  label.drawing=off
