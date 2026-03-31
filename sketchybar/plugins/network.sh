#!/usr/bin/env bash

# Clear existing network items from the popup
sketchybar --remove '/cc\.net\..*/'

# Find all active interfaces (those with an inet address)
INTERFACES=$(ifconfig -u | grep -E "^[a-z0-9]+:" | cut -d: -f1)
INDEX=0

for INTERFACE in $INTERFACES; do
  # Skip loopback and other non-standard interfaces
  if [[ "$INTERFACE" == "lo"* ]] || [[ "$INTERFACE" == "awdl"* ]] || [[ "$INTERFACE" == "llw"* ]] || [[ "$INTERFACE" == "utun"* ]] || [[ "$INTERFACE" == "bridge"* ]]; then
    continue
  fi

  # Check if interface has an IP (actually active)
  IP=$(ifconfig "$INTERFACE" 2>/dev/null | grep "inet " | awk '{print $2}')
  if [ -z "$IP" ]; then continue; fi

  # Try to get SSID from ipconfig
  SSID=$(ipconfig getsummary "$INTERFACE" 2>/dev/null | awk -F' : ' '/ SSID :/ {print $2}')
  
  if [ -n "$SSID" ]; then
    # Mapping for Campus SSIDs
    case "$SSID" in
      "<redacted>") SSID="Campus Link" ;;
      "eduroam") SSID="󰖟 University" ;;
    esac
    
    # Get speed
    SPEED=$(wdutil info 2>/dev/null | awk -F' : ' '/Tx Rate :/ {print $2}' | sed 's/ Mbps//')
    [ -z "$SPEED" ] && SPEED="Connected" || SPEED="${SPEED} Mbps"
    
    ICON=󰤨
    LABEL="$SSID"
  else
    # Ethernet or Other Hardware
    SERVICE=$(networksetup -listallhardwareports 2>/dev/null | grep -B 1 "Device: $INTERFACE" | head -n 1 | sed 's/Hardware Port: //')
    LABEL="${SERVICE:-Ethernet}"
    ICON=󰈀
    SPEED="Connected"
  fi

  # Add to popup
  sketchybar --add item cc.net.ssid.$INDEX popup.control_center \
             --set cc.net.ssid.$INDEX label="$LABEL" icon="$ICON" \
                   click_script="open x-apple.systempreferences:com.apple.preference.network; sketchybar --set control_center popup.drawing=off" \
             --add item cc.net.speed.$INDEX popup.control_center \
             --set cc.net.speed.$INDEX label="$SPEED" icon=󰓅 \
                   click_script="open x-apple.systempreferences:com.apple.preference.network; sketchybar --set control_center popup.drawing=off" 

  INDEX=$((INDEX + 1))
done

if [ "$INDEX" -eq 0 ]; then
  sketchybar --add item cc.net.none popup.control_center \
             --set cc.net.none label="Disconnected" icon=󰤭
fi
