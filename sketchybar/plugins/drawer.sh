#!/bin/bash
STATE=$(sketchybar --query drawer | jq -r '.icon.value')

if [ "$STATE" = "" ]; then
  # Open drawer (show utilities)
  sketchybar --animate tanh 15 \
             --set drawer icon= \
             --set sysmon drawing=on \
             --set pomodoro drawing=on \
             --set cpkb drawing=on \
             --set mic drawing=on \
             --set clipboard drawing=on \
             --set trash drawing=on \
             --set github drawing=on \
             --set utilities drawing=on \
             --set audio_toggle drawing=on
else
  # Close drawer (hide utilities)
  sketchybar --animate tanh 15 \
             --set drawer icon= \
             --set sysmon drawing=off \
             --set pomodoro drawing=off \
             --set cpkb drawing=off \
             --set mic drawing=off \
             --set clipboard drawing=off \
             --set trash drawing=off \
             --set github drawing=off \
             --set utilities drawing=off \
             --set audio_toggle drawing=off
fi
