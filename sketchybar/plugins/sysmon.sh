#!/bin/bash
source "$HOME/.local/bin/cosmere_colors.sh"

if [ "$SENDER" = "mouse.entered" ]; then
  sketchybar --set sysmon popup.drawing=on
elif [ "$SENDER" = "mouse.exited" ]; then
  sketchybar --set sysmon popup.drawing=off
fi

if [ "$SENDER" = "routine" ] || [ "$SENDER" = "forced" ]; then
  # Calculate CPU, RAM and Disk usage
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
