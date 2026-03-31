#!/usr/bin/env bash

# Function to safely update sketchybar items only if they exist
safe_set() {
  local item="$1"
  shift
  # Check if item exists by querying it, then apply changes
  if sketchybar --query "$item" >/dev/null 2>&1; then
    sketchybar --set "$item" "$@"
  fi
}

update_bar() {
  LABEL="$1"
  APP="$2"
  ICON="󰎆"
  case "$APP" in
    *[Ss]potify*) ICON=""; APP_NAME="Spotify" ;;
    *[Aa]pple*[Mm]usic*) ICON="󰎆"; APP_NAME="Music" ;;
    *[Vv][Ll][Cc]*) ICON="󰕼"; APP_NAME="VLC" ;;
    *mpv*) ICON=""; APP_NAME="mpv" ;;
    *) ICON="󰎆"; APP_NAME="$APP" ;;
  esac

  # Update main bar safely
  safe_set "$NAME" drawing=on label="$LABEL" icon="$ICON"
  
  # Update internal popup launcher icon
  safe_set media.control_icon click_script="open -a '$APP_NAME' || open -b '$APP'; sketchybar --set music popup.drawing=off"

  # Artwork logic is disabled as per user request to save space/performance
  # But we safely handle it if art item is ever added back
  safe_set media.art background.drawing=off
  exit 0
}

hide_bar() {
  safe_set "$NAME" drawing=on label="Not Playing"
  safe_set media.art background.drawing=off
  exit 0
}

# --- Detection Logic ---
if command -v nowplaying-cli &>/dev/null; then
  STATE=$(nowplaying-cli get playbackRate 2>/dev/null)
  if [ "$STATE" = "1" ]; then
    TITLE=$(nowplaying-cli get title 2>/dev/null)
    ARTIST=$(nowplaying-cli get artist 2>/dev/null)
    CLIENT=$(nowplaying-cli get clientIdentifier 2>/dev/null)
    update_bar "${TITLE} — ${ARTIST}" "${CLIENT:-Music}"
  fi
fi

SPOTIFY_RUNNING=$(osascript -e 'tell application "System Events" to (exists process "Spotify")' 2>/dev/null)
if [ "$SPOTIFY_RUNNING" = "true" ]; then
  STATE=$(osascript -e 'tell application "Spotify" to get player state' 2>/dev/null)
  if [ "$STATE" = "playing" ]; then
    TRACK=$(osascript -e 'tell application "Spotify" to get name of current track' 2>/dev/null)
    ARTIST=$(osascript -e 'tell application "Spotify" to get artist of current track' 2>/dev/null)
    update_bar "${TRACK} — ${ARTIST}" "Spotify"
  fi
fi

hide_bar
