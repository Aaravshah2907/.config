#!/bin/bash
STATE=$(sketchybar --query drawer | jq -r '.icon.value')

if [ "$STATE" = "" ]; then
  # Open drawer (show utilities)
  sketchybar --animate tanh 15 \
             --set drawer icon= \
             --set volume_icon drawing=on \
             --set bluetooth drawing=on \
             --set control_center drawing=on \
             --set warp drawing=on \
             --set sysmon drawing=on \
             --set mic drawing=on \
             --set trash drawing=on \
             --set github drawing=on \
             --set utilities drawing=on \
             --set audio_toggle drawing=on
else
  # Close drawer (hide utilities)
  sketchybar --animate tanh 15 \
             --set drawer icon= \
             --set volume_icon drawing=off \
             --set bluetooth drawing=off \
             --set control_center drawing=off \
             --set warp drawing=off \
             --set sysmon drawing=off \
             --set mic drawing=off \
             --set trash drawing=off \
             --set github drawing=off \
             --set utilities drawing=off \
             --set audio_toggle drawing=off
fi
