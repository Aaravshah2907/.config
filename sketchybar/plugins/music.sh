#!/usr/bin/env bash

# Function to safely update sketchybar items
safe_set() {
  local item="$1"
  shift
  sketchybar --query "$item" >/dev/null 2>&1 && sketchybar --set "$item" "$@"
}

update_bar() {
  local label="$1"
  local app="$2"
  local icon="󰎆"
  
  case "$app" in
    *[Ss]potify*) icon=""; app_name="Spotify" ;;
    *[Aa]pple*[Mm]usic*) icon="󰎆"; app_name="Music" ;;
    *[Vv][Ll][Cc]*) icon="󰕼"; app_name="VLC" ;;
    *mpv*) icon=""; app_name="mpv" ;;
    *) 
      # Filter: restrict to designated music apps
      return 
      ;;
  esac

  # Truncate labels that are excessively long to prevent bar layout issues
  if [ ${#label} -gt 40 ]; then
    label="$(echo "$label" | cut -c 1-37)..."
  fi

  safe_set "$NAME" drawing=on label="$label" icon="$icon"
  exit 0
}

hide_bar() {
  safe_set "$NAME" label="Not Playing" drawing=on
  exit 0
}

# --- Detection Logic ---

# 1. Native NowPlaying support (via nowplaying-cli)
if command -v nowplaying-cli &>/dev/null; then
  STATE=$(nowplaying-cli get playbackRate 2>/dev/null)
  if [ "$STATE" = "1" ]; then
    CLIENT=$(nowplaying-cli get clientIdentifier 2>/dev/null)
    # Check if client matches our allowed players
    if [[ "$CLIENT" =~ (Spotify|Music|VLC|mpv) ]]; then
      TITLE=$(nowplaying-cli get title 2>/dev/null)
      ARTIST=$(nowplaying-cli get artist 2>/dev/null)
      
      # Better mpv info handling via window title fallback
      if [[ ("$TITLE" == "mpv" || -z "$TITLE") && "$CLIENT" =~ mpv ]]; then
        TITLE=$(osascript -e 'tell application "System Events" to tell process "mpv" to return name of window 1' 2>/dev/null)
      fi
      
      # Build label based on available info
      if [[ -n "$TITLE" && -n "$ARTIST" && "$TITLE" != "$ARTIST" ]]; then
        update_bar "$TITLE — $ARTIST" "$CLIENT"
      else
        update_bar "${TITLE:-Something}" "$CLIENT"
      fi
    fi
  fi
fi

# 2. mpv Process Check (fallback for non-integrated mpv instances)
if pgrep -x "mpv" >/dev/null; then
  # Try to extract the filename from the process command line arguments
  MPV_ARGS=$(ps -p $(pgrep -x mpv) -o args= 2>/dev/null)
  # Extract the last argument which is usually the file/URL
  FILEPATH=$(echo "$MPV_ARGS" | awk '{print $NF}')
  FILENAME=$(basename "$FILEPATH" | sed 's/\.[^.]*$//') # Strip extension
  
  # Try window title as well
  WINDOW_TITLE=$(osascript -e 'tell application "System Events" to tell process "mpv" to return name of window 1' 2>/dev/null)
  
  # If window title is not just "mpv", use it (often better than filename)
  if [[ -n "$WINDOW_TITLE" && "$WINDOW_TITLE" != "mpv" ]]; then
    update_bar "$WINDOW_TITLE" "mpv"
  elif [[ -n "$FILENAME" && "$FILENAME" != "mpv" ]]; then
    update_bar "$FILENAME" "mpv"
  else
    update_bar "Playing in mpv" "mpv"
  fi
fi

# 3. Spotify Legacy Check (fallback for specific osascript needs)
SPOTIFY_RUNNING=$(osascript -e 'tell application "System Events" to (exists process "Spotify")' 2>/dev/null)
if [ "$SPOTIFY_RUNNING" = "true" ]; then
  PROPER_STATE=$(osascript -e 'tell application "Spotify" to get player state' 2>/dev/null)
  if [ "$PROPER_STATE" = "playing" ]; then
    TRACK=$(osascript -e 'tell application "Spotify" to get name of current track' 2>/dev/null)
    ARTIST=$(osascript -e 'tell application "Spotify" to get artist of current track' 2>/dev/null)
    update_bar "$TRACK — $ARTIST" "Spotify"
  fi
fi

hide_bar
