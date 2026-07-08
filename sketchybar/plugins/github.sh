#!/bin/bash
source "$HOME/.local/bin/cosmere_colors.sh"

if [ "$SENDER" = "mouse.entered" ]; then
  sketchybar --set github popup.drawing=on
  exit 0
elif [ "$SENDER" = "mouse.exited" ]; then
  sketchybar --set github popup.drawing=off
  exit 0
fi

if [ "$SENDER" = "routine" ] || [ "$SENDER" = "forced" ]; then
  TOKEN=""
  if [ -f "$HOME/.github_token" ]; then
    TOKEN=$(cat "$HOME/.github_token")
  fi
  
  if [ -z "$TOKEN" ]; then
    sketchybar --set github icon.color=$WHITE drawing=off label.drawing=off
    sketchybar --set github.notifications label="Add token to ~/.github_token"
    exit 0
  fi
  
  NOTIFS=$(curl -s -H "Authorization: token $TOKEN" https://api.github.com/notifications | grep -c '"id":')
  
  if [ "$NOTIFS" -gt 0 ]; then
    sketchybar --set github drawing=on icon.color=$WARN_COLOR label="$NOTIFS" label.drawing=on
    sketchybar --set github.notifications label="$NOTIFS unread notifications"
  else
    sketchybar --set github icon.color=$WHITE drawing=off label.drawing=off
    sketchybar --set github.notifications label="All caught up!"
  fi
fi
