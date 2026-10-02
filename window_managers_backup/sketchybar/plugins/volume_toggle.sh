#!/bin/bash
WIDTH=$(sketchybar --query volume | jq -r '.slider.width')
if [ "$WIDTH" = "0" ]; then
  sketchybar --animate tanh 15 --set volume slider.width=100
else
  sketchybar --animate tanh 15 --set volume slider.width=0
fi
