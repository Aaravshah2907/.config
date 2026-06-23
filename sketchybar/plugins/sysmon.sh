#!/bin/bash
source "$HOME/.local/bin/cosmere_colors.sh"

if [ "$SENDER" = "mouse.entered" ]; then
  sketchybar --set sysmon popup.drawing=on
elif [ "$SENDER" = "mouse.exited" ]; then
  sketchybar --set sysmon popup.drawing=off
fi

if [ "$SENDER" = "routine" ] || [ "$SENDER" = "forced" ]; then
  # Calculate CPU, RAM and Disk usage
  CPU=$(ps -A -o %cpu | awk '{s+=$1} END {printf("%.1f%%\n", s)}')
  RAM=$(memory_pressure | grep "System-wide memory free percentage:" | awk '{ printf("%02.0f%%\n", 100-$5) }')
  DISK=$(df -h / | tail -1 | awk '{print $4}')

  sketchybar --set sysmon.cpu label="CPU: $CPU" \
             --set sysmon.ram label="RAM: $RAM" \
             --set sysmon.disk label="Disk: $DISK free"
fi
