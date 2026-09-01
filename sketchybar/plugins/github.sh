#!/bin/bash
source "$HOME/.local/bin/cosmere_colors.sh"

# Click/global-exit handled by sketchybarrc click_script toggle
if [ "$SENDER" = "mouse.exited.global" ]; then
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
  PREV_COUNT=0
  [ -f /tmp/sketchybar_github_count ] && PREV_COUNT=$(cat /tmp/sketchybar_github_count)
  echo "$NOTIFS" > /tmp/sketchybar_github_count
  
  if [ "$NOTIFS" -gt 0 ]; then
    sketchybar --set github drawing=on icon.color=$WARN_COLOR label="$NOTIFS" label.drawing=on
    sketchybar --set github.notifications label="$NOTIFS unread notifications"
    
    # Notch alert only for *new* notifications (count increased)
    if [ "$NOTIFS" -gt "$PREV_COUNT" ]; then
      "$HOME/.config/sketchybar/plugins/notify_notch.sh" "" "$WARN_COLOR" "$NOTIFS new GitHub notifs"
    fi
  else
    sketchybar --set github icon.color=$WHITE drawing=off label.drawing=off
    sketchybar --set github.notifications label="All caught up!"
  fi
fi
