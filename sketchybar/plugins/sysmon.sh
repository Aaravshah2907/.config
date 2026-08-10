#!/bin/bash
source "$HOME/.local/bin/cosmere_colors.sh"

if [ "$SENDER" = "mouse.entered" ]; then
  sketchybar --set sysmon popup.drawing=on
elif [ "$SENDER" = "mouse.exited" ]; then
  sketchybar --set sysmon popup.drawing=off
fi

if [ "$SENDER" = "routine" ] || [ "$SENDER" = "forced" ]; then
  # Calculate CPU, RAM and Disk usage
  CPU_RAW=$(ps -A -o %cpu | awk '{s+=$1} END {printf("%.1f\n", s)}')
  RAM_RAW=$(memory_pressure | grep "System-wide memory free percentage:" | awk '{ printf("%02.0f\n", 100-$5) }')
  DISK=$(df -h / | tail -1 | awk '{print $4}')

  CPU_INT=${CPU_RAW%.*}
  RAM_INT=${RAM_RAW}

  COLOR=$PRES_GLACIAL
  
  if [ "$CPU_INT" -gt 95 ] || [ "$RAM_INT" -gt 95 ]; then
    COLOR=$CRIMSON
    sketchybar --animate sin 15 --set sysmon icon.y_offset=-3
    sketchybar --animate sin 15 --set sysmon icon.y_offset=0
  elif [ "$CPU_INT" -gt 85 ] || [ "$RAM_INT" -gt 85 ]; then
    COLOR=$WARN_COLOR
    sketchybar --set sysmon icon.y_offset=0
  else
    sketchybar --set sysmon icon.y_offset=0
  fi

  sketchybar --set sysmon icon.color=$COLOR \
             --set sysmon.cpu label="CPU: ${CPU_RAW}%" \
             --set sysmon.ram label="RAM: ${RAM_RAW}%" \
             --set sysmon.disk label="Disk: $DISK free"
fi
