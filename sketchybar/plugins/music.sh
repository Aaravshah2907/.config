#!/usr/bin/env bash

# Helper: show label and exit
update_bar() {
  LABEL="$1"
  APP="$2"

  ICON="󰎆" # Default music icon
  APP_NAME="Music" # Default fallback

  case "$APP" in
    *[Ss]potify*)
      ICON=""
      APP_NAME="Spotify"
      ;;
    *[Aa]pple*[Mm]usic*)
      ICON="󰎆"
      APP_NAME="Music"
      ;;
    *[Vv][Ll][Cc]*)
      ICON="󰕼"
      APP_NAME="VLC"
      ;;
    *mpv*)
      ICON=""
      APP_NAME="mpv"
      ;;
    *)
      ICON="󰎆"
      APP_NAME="$APP"
      ;;
  esac

  sketchybar --set "$NAME" drawing=on label="$LABEL" icon="$ICON" \
             --set media.control_icon click_script="open -a '$APP_NAME' || open -b '$APP'; sketchybar --set music popup.drawing=off"
  exit 0
}

# Helper: hide and exit
hide_bar() {
  sketchybar --set "$NAME" drawing=on label="Not Playing" \
             --set media.control_icon click_script=""
  exit 0
}

# --- Method 1: nowplaying-cli ---
if command -v nowplaying-cli &>/dev/null; then
  STATE=$(nowplaying-cli get playbackRate 2>/dev/null)
  if [ "$STATE" = "1" ]; then
    TITLE=$(nowplaying-cli get title 2>/dev/null)
    ARTIST=$(nowplaying-cli get artist 2>/dev/null)
    CLIENT=$(nowplaying-cli get clientIdentifier 2>/dev/null)
    
    # Map bundle ID to human readable app name if possible
    APP_LITERAL="$CLIENT"
    if [[ "$CLIENT" == *"spotify"* ]]; then APP_LITERAL="Spotify"; fi
    if [[ "$CLIENT" == *"apple.Music"* ]]; then APP_LITERAL="Music"; fi

    if [ -n "$TITLE" ]; then
      if [ -n "$ARTIST" ]; then
        update_bar "${TITLE} — ${ARTIST}" "$APP_LITERAL"
      else
        update_bar "$TITLE" "$APP_LITERAL"
      fi
    fi
  fi
fi

# --- Method 2: Spotify via AppleScript ---
SPOTIFY_RUNNING=$(osascript 2>/dev/null -e 'tell application "System Events" to (exists process "Spotify")')
if [ "$SPOTIFY_RUNNING" = "true" ]; then
  STATE=$(osascript 2>/dev/null -e 'tell application "Spotify" to get player state')
  if [ "$STATE" = "playing" ]; then
    TRACK=$(osascript 2>/dev/null -e 'tell application "Spotify" to get name of current track')
    ARTIST=$(osascript 2>/dev/null -e 'tell application "Spotify" to get artist of current track')
    [ -n "$TRACK" ] && update_bar "${TRACK} — ${ARTIST}" "Spotify"
  fi
fi

# --- Method 3: VLC ---
VLC_RUNNING=$(osascript 2>/dev/null -e 'tell application "System Events" to (exists process "VLC")')
if [ "$VLC_RUNNING" = "true" ]; then
  DATA=$(osascript 2>/dev/null -e 'tell application "VLC" to if it is playing then get name of current item')
  [ -z "$DATA" ] || update_bar "$DATA" "VLC"
fi

# --- Method 4: mpv ---
if pgrep -x "mpv" &>/dev/null; then
  DATA=$(osascript 2>/dev/null -e 'tell application "System Events" to tell process "mpv" to get name of window 1')
  DATA=$(echo "$DATA" | sed 's/^mpv - //')
  [ -z "$DATA" ] || update_bar "$DATA" "mpv"
fi

# --- Nothing playing: hide ---
hide_bar
