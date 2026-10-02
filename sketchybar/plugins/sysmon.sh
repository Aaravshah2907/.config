#!/bin/bash
source "$HOME/.local/bin/cosmere_colors.sh"
# Battery power helper (caches pmset result for 10s)
source "$(dirname "$0")/battery_power.sh"

# Popup close on global exit (toggle handled by click_script in sketchybarrc)
if [ "$SENDER" = "mouse.exited.global" ]; then
  sketchybar --set sysmon popup.drawing=off
fi

if [ "$SENDER" = "routine" ] || [ "$SENDER" = "forced" ]; then
  # On battery, slow polling to 15s to reduce bash fork overhead
  if on_battery; then
    sketchybar --set sysmon update_freq=15
  else
    sketchybar --set sysmon update_freq=5
  fi

  CORES=$(sysctl -n hw.ncpu)
  CPU_RAW=$(ps -A -o %cpu | awk -v cores="$CORES" '{s+=$1} END {printf("%.1f\n", s/cores)}')
  RAM_RAW=$(memory_pressure | grep "System-wide memory free percentage:" | awk '{ printf("%02.0f\n", 100-$5) }')
  DISK=$(df -h / | tail -1 | awk '{print $4}')

  CPU_INT=${CPU_RAW%.*}
  RAM_INT=${RAM_RAW}
  
  CPU_FRAC=$(awk "BEGIN {print $CPU_INT / 100}")
  RAM_FRAC=$(awk "BEGIN {print $RAM_INT / 100}")

  COLOR=$PRES_GLACIAL
  
  if [ "$CPU_INT" -gt 95 ] || [ "$RAM_INT" -gt 95 ]; then
    COLOR=$CRIMSON
    sketchybar --animate sin 15 --set sysmon icon.y_offset=-3
    sketchybar --animate sin 15 --set sysmon icon.y_offset=0
    sketchybar --animate sin 30 --bar border_color=$RUIN_MAROON
  elif [ "$CPU_INT" -gt 85 ] || [ "$RAM_INT" -gt 85 ]; then
    COLOR=$WARN_COLOR
    sketchybar --set sysmon icon.y_offset=0
    sketchybar --animate sin 30 --bar border_color=$RUIN_SPIKE
  else
    sketchybar --set sysmon icon.y_offset=0
    sketchybar --animate sin 30 --bar border_color=$SAPPHIRE_TRANSLUCENT
  fi

  sketchybar --set sysmon icon.color=$COLOR \
             --set sysmon.cpu label="CPU: ${CPU_RAW}%" \
             --push sysmon.cpu $CPU_FRAC \
             --set sysmon.ram label="RAM: ${RAM_RAW}%" \
             --push sysmon.ram $RAM_FRAC \
             --set sysmon.disk label="Disk: $DISK free"
fi
