#!/bin/bash

# Ensure ya and other tools are in path
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

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
            "Wait, let me try to hum along! 󰎈"
            "Ooh, I like the way the wind vibrates with this one! 󱐋"
            "Is this music from the Physical Realm? It's so... physical! 󰊠"
            "I'll do a loop-de-loop if you turn it up! 󱐌"
        )
        PROFOUND=(
            "I will be with you, Kaladin. Always. 󱐌"
            "You will fly again. 󱇊"
            "Listen to the wind. It carries memories. 󱐋"
            "I remember what it is to be a shard. It starts with a song. 󰊠"
            "You are the storm, and the storm is you. 󱐌"
            "Hold on to the light. The darkness is just a shadow. 󱐋"
            "A song is just a memory that refuses to be forgotten. 󱐋"
            "The winds know your name, Bridgeboy. They whisper it to the stars. 󱇊"
            "The sky is not the limit. It's the beginning. 󰊠"
            "I am the daughter of the Stormfather, and I say this song is worthy. 󱐌"
        )
        ;;
    "Paused")
        PLAYFUL=(
            "Don't stop now! You're finally dancing! 󱐋"
            "Resting? Boring! 󰊠"
            "I'm sticking my tongue out at you right now. 󱐌"
            "Is it time for a stew break? Save me some! 󰊠"
            "I'll just circle your head until you hit play again. 󱐌"
            "Did the storms stop? Why is it so quiet? 󱐋"
            "I'm going to start pulling your hair if you don't hit play! 󱐌"
            "Booooo! More sound! More light! 󰊠"
            "Is it time for a nap? I'll hide in your pocket. 󱇊"
        )
        PROFOUND=(
            "Rest now, Bridgeboy. I'll watch the storms. 󰊠"
            "Strength before weakness. You've earned this breath. 󱇊"
            "The wind is still here, even in silence. 󱐋"
            "We are all broken, but that's how the light gets in. 󰊠"
            "Peace is as important as the spear. 󱇊"
            "Even the wind needs to catch its breath sometimes. 󱇊"
            "Listen to the silence. It's where the best ideas are born. 󱐋"
            "The destination can wait. The journey is in this moment. 󰊠"
            "Strength is found in the pauses, Kaladin. 󱇊"
        )
        ;;
    *)
        PLAYFUL=(
            "What's next? Something fast? 󱐋"
            "Is this what humans call 'music'? It's weird. I like it! 󰊠"
            "This song is almost as pretty as a gemstone! 󰊠"
            "Dance with me! ...Oh wait, you don't have wings. 󱐌"
            "Storms! I haven't heard this one in centuries! 󱐋"
            "I found a shiny rock! ...Oh, wait, it's just a button. 󰊠"
            "Have you seen my brothers? They're all so serious. 󱐋"
            "Let's go find some trouble! The good kind! 󱐌"
            "I can see the Stormlight in your eyes today! 󱇊"
        )
        PROFOUND=(
            "Journey before destination. 󱇊"
            "You're not alone. I'm right here. 󱐌"
            "The storms are far away tonight. 󰊠"
            "I will protect those who cannot protect themselves. 󱇊"
            "Every step is a new beginning. Even the small ones. 󱐋"
            "I will protect even those I hate, so long as it is right. 󱇊"
            "You are not a monster. You are a man who is trying. 󱐋"
            "The First Ideal is the hardest. Life before death. 󱇊"
            "I remember the first time I saw you. You were a spark in the dark. 󰊠"
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
TIMEOUT=3

# COOLDOWN LOGIC (Prevent spamming multiple notifications within 0.7s)
LOCKFILE="/tmp/yazi_music_notify.lock"
LAST_TIME=$(cat "$LOCKFILE" 2>/dev/null || echo 0)
NOW=$(date +%s%N | cut -b1-13) # Milliseconds
DIFF=$((NOW - LAST_TIME))

if [ $DIFF -lt 700 ]; then
    echo "[$(date)] Cooldown active: skipping notification" >> "$LOGFILE"
    exit 0
fi
echo "$NOW" > "$LOCKFILE"

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
BRIDGE_FILE="$HOME/.config/radiant-player/notify.json"
echo "$JSON_PAYLOAD" > "$BRIDGE_FILE"

# Try Yazi internal notification via Plugin (Rock-solid File Bridge)
if command -v ya >/dev/null 2>&1; then
    ya emit plugin syl-notify >/dev/null 2>&1 && exit 0
fi

# Final Fallback (Log only if plugin failed)
if [ $? -ne 0 ]; then
    echo "[$(date)] Plugin notification failed" >> "$LOGFILE"
fi
