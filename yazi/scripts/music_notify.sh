#!/bin/bash

# Ensure ya and other tools are in path
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# LOGGING FOR DEBUG
LOGFILE="$HOME/.config/yazi/scripts/music_notify.log"
{
  echo "[$(date)] Event: $1, Track: $2"
  which ya
  echo "YAZI_ID: $YAZI_ID"
} >> "$LOGFILE"

# SYLPHRENA - Your personal Windspren
# Journey before destination, Bridgeboy.

# Time-based personality
HOUR=$(date +%H)
MSG_TYPE="PLAYFUL"
if [ "$HOUR" -ge 23 ] || [ "$HOUR" -lt 8 ]; then
    MSG_TYPE="PROFOUND"
fi

# Pick quotes based on event and personality
case "$1" in
    "Playing")
        PLAYFUL=(
            "Found you a better song, Bridgeboy! 󱐌"
            "Stop being so grumpy! Listen to this! 󱐋"
            "Lashing to a new rhythm! 󱐌"
            "Ready to fly? This song has wings! 󰊠"
            "I'll be the wind in your ears for this one! 󱐌"
            "Another one? You're hard to please today! 󱐋"
        )
        PROFOUND=(
            "I will be with you, Kaladin. Always. 󱐌"
            "You will fly again. 󱇊"
            "Listen to the wind. It carries memories. 󱐋"
            "I remember what it is to be a shard. It starts with a song. 󰊠"
            "You are the storm, and the storm is you. 󱐌"
            "Hold on to the light. The darkness is just a shadow. 󱐋"
        )
        ;;
    "Paused")
        PLAYFUL=(
            "Don't stop now! You're finally dancing! 󱐋"
            "Resting? Boring! 󰊠"
            "I'm sticking my tongue out at you right now. 󱐌"
            "Is it time for a stew break? Save me some! 󰊠"
            "I'll just circle your head until you hit play again. 󱐌"
        )
        PROFOUND=(
            "Rest now, Bridgeboy. I'll watch the storms. 󰊠"
            "Strength before weakness. You've earned this breath. 󱇊"
            "The wind is still here, even in silence. 󱐋"
            "We are all broken, but that's how the light gets in. 󰊠"
            "Peace is as important as the spear. 󱇊"
        )
        ;;
    *)
        PLAYFUL=(
            "What's next? Something fast? 󱐋"
            "Is this what humans call 'music'? It's weird. I like it! 󰊠"
            "This song is almost as pretty as a gemstone! 󰊠"
            "Dance with me! ...Oh wait, you don't have wings. 󱐌"
            "Storms! I haven't heard this one in centuries! 󱐋"
        )
        PROFOUND=(
            "Journey before destination. 󱇊"
            "You're not alone. I'm right here. 󱐌"
            "The storms are far away tonight. 󰊠"
            "I will protect those who cannot protect themselves. 󱇊"
            "Every step is a new beginning. Even the small ones. 󱐋"
        )
        ;;
esac

# Pick random quote from chosen category
if [ "$MSG_TYPE" == "PLAYFUL" ]; then
    QUOTE=${PLAYFUL[$RANDOM % ${#PLAYFUL[@]}]}
else
    QUOTE=${PROFOUND[$RANDOM % ${#PROFOUND[@]}]}
fi

# Yazi TUI Notification
TITLE="Sylphrena 󱐌"
LEVEL="info"
TIMEOUT=5

# Format content for Yazi notification
# Strip ANSI escape codes from track title for clean display
TRACK=$(echo "$2" | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g')
CONTENT="󰎈 $TRACK\n\n$QUOTE"

# Construct JSON safely using jq (Compact mode for better CLI transmission)
JSON_PAYLOAD=$(/opt/homebrew/bin/jq -n -c \
  --arg t "$TITLE" \
  --arg c "$CONTENT" \
  --arg l "$LEVEL" \
  --argjson to "$TIMEOUT" \
  '{title: $t, content: $c, level: $l, timeout: $to}')

# Use a file bridge to avoid shell-escaping/stripping issues with ya emit
BRIDGE_FILE="$HOME/.config/yazi/scripts/music_notify.json"
echo "$JSON_PAYLOAD" > "$BRIDGE_FILE"

# Try Yazi internal notification via Plugin (Rock-solid File Bridge)
if command -v ya >/dev/null 2>&1; then
    ya emit plugin syl-notify >> "$LOGFILE" 2>&1 && exit 0
fi

# Final Fallback to system osascript
FINAL_MSG=$(echo -e "$CONTENT" | sed 's/"/\\"/g' | sed 's/\\n/\r/g')
osascript -e "display notification \"$FINAL_MSG\" with title \"$TITLE\""
