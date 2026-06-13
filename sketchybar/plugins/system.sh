#!/usr/bin/env bash
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
source "$HOME/.local/bin/cosmere_colors.sh"

# Handle hover for system monitor
if [ "$SENDER" = "mouse.entered" ]; then
  sketchybar --set "$NAME" popup.drawing=on
  exit 0
fi

if [ "$SENDER" = "mouse.exited" ]; then
  sketchybar --set "$NAME" popup.drawing=off
  exit 0
fi

# --- RAM Info (Preservation Reserve) ---
FREE_PCT=$(memory_pressure 2>/dev/null | awk '/System-wide memory free percentage:/ {print $5}' | tr -d '%')
if [ -n "$FREE_PCT" ]; then
  USED_PCT=$((100 - FREE_PCT))
  COLOR="$SYS_RAM_COLOR"                # Atium gold — baseline
  [ "$USED_PCT" -gt 70 ] && COLOR="$RUIN_SPIKE"   # Hemalurgic amber — pressure
  [ "$USED_PCT" -gt 90 ] && COLOR="$RUIN_MAROON"  # Ruin's maroon — critical
  
  sketchybar --set system.ram label="Memory: ${USED_PCT}%" label.color="$COLOR"
else
  USED_PCT=0
fi

# CPU usage detection (average across cores)
CPU_PCT=$(ps -A -o %cpu | awk '{sum+=$1} END {print int(sum/NR)}')
if [ -z "$CPU_PCT" ]; then CPU_PCT=0; fi

# Set CPU color based on usage — Ruin's influence grows with heat
if [ "$CPU_PCT" -gt 70 ]; then
  CPU_COLOR="$RUIN_MAROON"             # Ruin fully active — critical
elif [ "$CPU_PCT" -gt 40 ]; then
  CPU_COLOR="$RUIN_SPIKE"              # Hemalurgic pressure — warning
else
  CPU_COLOR="$SYS_CPU_COLOR"           # Normal — baseline Ruin spike amber
fi
sketchybar --set system.cpu label="CPU: ${CPU_PCT}%" label.color="$CPU_COLOR"

# --- Disk Info (Material World) ---
DISK_INFO=$(df -H /System/Volumes/Data | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')
sketchybar --set system.disk label="Disk: ${DISK_INFO}" label.color="$SYS_DISK_COLOR"

# --- Storm Severity — Ruin vs Preservation balance ---
if [ "$CPU_PCT" -gt 70 ] || [ "$USED_PCT" -gt 80 ]; then
  STORM_STATE="Everstorm Clash"
  STORM_ICON="󰖓"                        # Everstorm — Ruin ascendant
  STORM_COLOR="$RUIN_MAROON"
  sketchybar --animate system icon.y_offset -4 4 duration=150 repeat=3
elif [ "$CPU_PCT" -gt 30 ] || [ "$USED_PCT" -gt 50 ]; then
  STORM_STATE="Highstorm"
  STORM_ICON="󰖖"                        # Highstorm — Preservation & Ruin in tension
  STORM_COLOR="$RUIN_SPIKE"
else
  STORM_STATE="Stormless"
  STORM_ICON="󰖙"                        # Clear — Preservation holds
  STORM_COLOR="$SYS_ACCENT"
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
