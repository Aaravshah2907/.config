#!/usr/bin/env bash

# --- RAM Info ---
# memory_pressure percentage logic:
# 100 - free% = used%
FREE_PCT=$(memory_pressure 2>/dev/null | awk '/System-wide memory free percentage:/ {print $5}' | tr -d '%')
if [ -n "$FREE_PCT" ]; then
  USED_PCT=$((100 - FREE_PCT))
  sketchybar --set system.ram.graph graph.push="$USED_PCT"
  sketchybar --set system.ram.text label="RAM: ${USED_PCT}%"
fi

# --- Disk Info ---
# For /System/Volumes/Data which is where user files live
DISK_INFO=$(df -H /System/Volumes/Data | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')
sketchybar --set system.disk label="Disk: ${DISK_INFO}"
