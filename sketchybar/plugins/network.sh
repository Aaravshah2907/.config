#!/usr/bin/env bash

# Function to safely update sketchybar items only if they exist
safe_set() {
  local item="$1"
  shift
  if sketchybar --query "$item" >/dev/null 2>&1; then
    sketchybar --set "$item" "$@"
  fi
}

# Clear existing entries
safe_set cc.net.0.ssid drawing=off
safe_set cc.net.0.speed drawing=off
safe_set cc.net.1.ssid drawing=off
safe_set cc.net.1.speed drawing=off

INTERFACES=$(ifconfig -u | grep -E "^[a-z0-9]+:" | cut -d: -f1)
INDEX=0
TOTAL_TX_RATE=0

for INTERFACE in $INTERFACES; do
  if [[ "$INTERFACE" == "lo"* ]] || [[ "$INTERFACE" == "awdl"* ]] || [[ "$INTERFACE" == "utun"* ]]; then continue; fi

  IP=$(ifconfig "$INTERFACE" 2>/dev/null | grep "inet " | awk '{print $2}')
  if [ -z "$IP" ]; then continue; fi

  SSID=$(ipconfig getsummary "$INTERFACE" 2>/dev/null | awk -F' : ' '/ SSID :/ {print $2}')
  
  if [ -n "$SSID" ]; then
    case "$SSID" in
      "<redacted>") SSID="Campus Link" ;;
      "eduroam") SSID="󰖟 University" ;;
    esac
    
    SPEED=$(wdutil info 2>/dev/null | awk -F' : ' '/Tx Rate :/ {print $2}' | sed 's/ Mbps//')
    [ -z "$SPEED" ] && SPEED_VAL=0 || SPEED_VAL=$SPEED
    SPEED_LABEL="${SPEED_VAL} Mbps"
    ICON=󰤨
    LABEL="$SSID"
    TOTAL_TX_RATE=$((TOTAL_TX_RATE + SPEED_VAL))
  else
    SERVICE=$(networksetup -listallhardwareports 2>/dev/null | grep -B 1 "Device: $INTERFACE" | head -n 1 | sed 's/Hardware Port: //')
    LABEL="${SERVICE:-Ethernet}"
    ICON=󰈀
    SPEED_LABEL="LAN"
  fi

  # Only push to the slots we have defined in sketchybarrc
  safe_set "cc.net.$INDEX.ssid" label="$LABEL" icon="$ICON" drawing=on
  safe_set "cc.net.$INDEX.speed" label="$SPEED_LABEL" drawing=on
  
  INDEX=$((INDEX + 1))
done

# Push tx rate to graph (scaled for visualization)
safe_set cc.net.graph graph.push="$TOTAL_TX_RATE"

if [ "$INDEX" -eq 0 ]; then
  safe_set cc.net.none label="Disconnected" icon=󰤭 drawing=on
else
  safe_set cc.net.none drawing=off
fi
