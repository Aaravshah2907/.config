#!/usr/bin/env bash
source "$HOME/.config/sketchybar/colors.sh"

# Blueutil check
CONNECTED_DEVICES=$(/opt/homebrew/bin/blueutil --connected)
COUNT=$(echo "$CONNECTED_DEVICES" | grep -c "address" | xargs)

ICON="󰂯"
if [ "$COUNT" -gt 0 ]; then
    ICON="󰂱"
    COLOR=$SAPPHIRE
    LABEL="$COUNT"
else
    COLOR=$WHITE
    LABEL=""
fi

/opt/homebrew/bin/sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" label="$LABEL" label.color="$COLOR"

# Clear popup
/opt/homebrew/bin/sketchybar --remove '/bluetooth\.device\..*/'

# Add devices to popup
if [ "$COUNT" -gt 0 ]; then
    COUNTER=0
    while read -r line; do
        NAME=$(echo "$line" | awk -F', ' '{print $1}' | awk -F': ' '{print $2}' | sed 's/"//g')
        [ -z "$NAME" ] && continue
        
        /opt/homebrew/bin/sketchybar --add item bluetooth.device.$COUNTER popup.bluetooth \
                                   --set bluetooth.device.$COUNTER label="$NAME" icon=󰂱
        COUNTER=$((COUNTER + 1))
    done <<< "$CONNECTED_DEVICES"
else
    /opt/homebrew/bin/sketchybar --add item bluetooth.none popup.bluetooth \
                               --set bluetooth.none label="No devices Bonded" icon=󰂯
fi
