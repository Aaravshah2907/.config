#!/bin/bash
source "$HOME/.local/bin/cosmere_colors.sh"

if [ "$SENDER" = "routine" ] || [ "$SENDER" = "forced" ]; then
  WIFI_INTERFACE=$(networksetup -listallhardwareports | awk '/Hardware Port: Wi-Fi/{getline; print $2}')
  [ -z "$WIFI_INTERFACE" ] && WIFI_INTERFACE="en0"

  read -r IN OUT <<< $(netstat -ib | awk "/$WIFI_INTERFACE.*<Link/ {print \$7, \$10}")

  STATE_FILE="/tmp/sketchybar_net_speed.state"
  
  if [ -f "$STATE_FILE" ]; then
    read -r OLD_IN OLD_OUT OLD_TIME <<< $(cat "$STATE_FILE")
    NOW=$(date +%s)
    TIME_DIFF=$((NOW - OLD_TIME))
    
    if [ "$TIME_DIFF" -gt 0 ]; then
      DOWN=$(((IN - OLD_IN) / TIME_DIFF))
      UP=$(((OUT - OLD_OUT) / TIME_DIFF))
      
      DOWN_FORMAT=$(awk -v d="$DOWN" 'BEGIN{if(d>1048576) printf("%.1f MB/s", d/1048576); else if(d>1024) printf("%.0f KB/s", d/1024); else print d " B/s"}')
      UP_FORMAT=$(awk -v u="$UP" 'BEGIN{if(u>1048576) printf("%.1f MB/s", u/1048576); else if(u>1024) printf("%.0f KB/s", u/1024); else print u " B/s"}')
      
      sketchybar --set control_center.down label="Download: $DOWN_FORMAT" \
                 --set control_center.up label="Upload: $UP_FORMAT"
    fi
  fi
  
  echo "$IN $OUT $(date +%s)" > "$STATE_FILE"
fi
