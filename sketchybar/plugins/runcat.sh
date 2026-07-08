#!/bin/bash

# RunCat implementation for SketchyBar
# This script runs in a loop, updating the icon of the sketchybar item.
# The sleep duration between frames decreases as CPU usage increases.

# The frames of the animation. You can change these to anything!
# Some examples:
# PACMAN: "ᗧ" "ᗤ"
# SPINNER: "⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏"
# EMOJI CAT: "😺" "😸" "😹" "😻"
# NERD FONT CAT WAGGING/BOUNCING:
FRAMES=("󰄛 " " 󰄛" "  󰄛" "   󰄛" "  󰄛" " 󰄛")

# Number of frames
FRAME_COUNT=${#FRAMES[@]}
FRAME_INDEX=0

# Default sleep time
SLEEP_TIME=0.5

update_cpu_usage() {
  while true; do
    # Get CPU usage using top or ps
    # This fetches the total cpu usage percentage
    CPU_USAGE=$(ps -A -o %cpu | awk '{s+=$1} END {print s}')
    
    # Calculate sleep time: High CPU = Low Sleep Time, Low CPU = High Sleep Time
    # Example logic: 
    # If CPU is 0%, sleep is 0.5s. If CPU is 100%, sleep is 0.05s.
    
    # Ensure CPU_USAGE is a number and avoid division by zero
    if (( $(echo "$CPU_USAGE > 100" | bc -l) )); then
        CPU_USAGE=100
    fi
    
    # Calculate inverted sleep time
    NEW_SLEEP=$(echo "0.5 - (0.45 * ($CPU_USAGE / 100))" | bc -l)
    
    # Ensure sleep time is at least 0.05
    if (( $(echo "$NEW_SLEEP < 0.05" | bc -l) )); then
      SLEEP_TIME=0.05
    else
      SLEEP_TIME=$NEW_SLEEP
    fi
    
    # Update CPU every 2 seconds
    sleep 2
  done
}

# Start the CPU monitor in the background
update_cpu_usage &
CPU_PID=$!

# Trap to kill background process when sketchybar reloads this script
trap "kill $CPU_PID" EXIT

# Animation Loop
while true; do
  # Set the icon in sketchybar
  sketchybar --set "$NAME" icon="${FRAMES[$FRAME_INDEX]}"
  
  # Increment frame
  FRAME_INDEX=$(( (FRAME_INDEX + 1) % FRAME_COUNT ))
  
  # Sleep dynamically
  sleep "$SLEEP_TIME"
done
