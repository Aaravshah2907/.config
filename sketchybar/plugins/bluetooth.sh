#!/usr/bin/env bash
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
source "$HOME/.local/bin/cosmere_colors.sh"

# Handle arguments / click
if [ "$1" = "click" ]; then
  if [ -f /tmp/bluetooth_pinned ]; then
    rm /tmp/bluetooth_pinned
    sketchybar --set bluetooth popup.drawing=off
  else
    touch /tmp/bluetooth_pinned
    sketchybar --set bluetooth popup.drawing=on
  fi
  exit 0
fi

# Handle hover for Bluetooth
if [ "$SENDER" = "mouse.entered" ]; then
  sketchybar --set "$NAME" popup.drawing=on
  exit 0
fi

if [ "$SENDER" = "mouse.exited" ]; then
  if [ ! -f /tmp/bluetooth_pinned ]; then
    sketchybar --set "$NAME" popup.drawing=off
  fi
  exit 0
fi

# Blueutil check
CONNECTED_DEVICES=$(blueutil --connected)
COUNT=$(echo "$CONNECTED_DEVICES" | grep -c "name" | xargs)

ICON="󰂯"
if [ "$COUNT" -gt 0 ]; then
    ICON="󰂱"
    COLOR=$BT_CONNECTED                  # Preservation silver — bonded & ordered
    LABEL="$COUNT"
    DRAWING="on"
else
    COLOR=$BT_IDLE                       # White — idle, visible on dark bar
    LABEL=""
    DRAWING="off"
fi

sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" label="$LABEL" label.color="$COLOR" drawing="$DRAWING"

# Clear popup
sketchybar --remove '/bluetooth\.device\..*/'

# Add devices to popup
if [ "$COUNT" -gt 0 ]; then
    COUNTER=0
    PROFILER_DATA=$(system_profiler SPBluetoothDataType 2>/dev/null)
    while read -r line; do
        NAME=$(echo "$line" | grep -o 'name: "[^"]*"' | cut -d'"' -f2)
        [ -z "$NAME" ] && continue
        
        # Try to find battery level for this device
        BATTERY=$(echo "$PROFILER_DATA" | awk -v name="$NAME" '$0 ~ name":" {found=1} found && /Battery Level:/ {print $3; exit} found && /^[[:space:]]*[^[:space:]]+:/ && !($0 ~ name":") && !/Address:/ && !/Firmware/ && !/Vendor/ {found=0}')
        
        if [ -n "$BATTERY" ]; then
           LABEL_STR="$NAME ($BATTERY)"
        else
           LABEL_STR="$NAME"
        fi
        
        sketchybar --add item bluetooth.device.$COUNTER popup.bluetooth \
                   --set bluetooth.device.$COUNTER label="$LABEL_STR" icon=󰂱
        COUNTER=$((COUNTER + 1))
    done <<< "$CONNECTED_DEVICES"
else
    sketchybar --add item bluetooth.none popup.bluetooth \
               --set bluetooth.none label="No devices Bonded" icon=󰂯
fi
