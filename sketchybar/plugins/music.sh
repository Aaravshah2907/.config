#!/usr/bin/env bash
source "$HOME/.config/sketchybar/colors.sh"

# Function to safely update sketchybar items
UPDATED=0
echo "$(date) NAME=$NAME SENDER=$SENDER" >> /tmp/sketchybar_music.log
safe_set() {
  local item="$1"
  shift
  sketchybar --query "$item" >/dev/null 2>&1 && sketchybar --set "$item" "$@"
}

update_bar() {
  local label="$1"
  local app="$2"
  local icon="󰎆"
  local icon_color="$PURPLE"
  
  case "$app" in
    *[Ss]potify*) icon=""; app_name="Spotify"; icon_color="$EMERALD" ;;
    *[Aa]pple*[Mm]usic*) icon="󰎆"; app_name="Music"; icon_color="$PURPLE" ;;
    *[Vv][Ll][Cc]*) icon="󰕼"; app_name="VLC"; icon_color="$ORANGE" ;;
    *mpv*) icon=""; app_name="mpv"; icon_color="$SAPPHIRE" ;;
    *) 
      # Filter: restrict to designated music apps
      return 
      ;;
  esac

  # Truncate labels that are excessively long to prevent bar layout issues
  if [ ${#label} -gt 40 ]; then
    label="$(echo "$label" | /usr/bin/cut -c 1-37)..."
  fi

  safe_set "$NAME" drawing=on \
                   icon.drawing=on \
                   label.drawing=on \
                   label="$label" \
                   icon="$icon" \
                   label.color="$WHITE" \
                   icon.color="$icon_color"
  UPDATED=1
  return 0
}

hide_bar() {
  # Default View: Radiant Symbol
  # ensures it doesn't just 'ignore rendering' when idle
  sketchybar --set "$NAME" drawing=on \
                   icon.drawing=on \
                   label.drawing=on \
                   label="Resting" \
                   icon="󰋋" \
                   icon.color="$SAPPHIRE" \
                   label.color="$SAPPHIRE"
  exit 0
}

# --- Detection Logic ---

# 0. Yazi-mpv instance (Prioritized)
YAZI_SCRIPT="/Users/aaravshah2975/.config/radiant-player/queue.py"
MPV_STATUS=$(python3 "$YAZI_SCRIPT" status_json 2>/dev/null)
if [[ -n "$MPV_STATUS" && $(echo "$MPV_STATUS" | jq -r '.running') == "true" ]]; then
  TITLE=$(echo "$MPV_STATUS" | jq -r '.title')
  ARTIST=$(echo "$MPV_STATUS" | jq -r '.artist // empty')
  PAUSED=$(echo "$MPV_STATUS" | jq -r '.paused')
  LOOP=$(echo "$MPV_STATUS" | jq -r '.loop')
  SOURCE=$(echo "$MPV_STATUS" | jq -r '.source // "local"')
  
  LICON=""
  if [ "$LOOP" == "single" ]; then LICON="󰑘 "; elif [ "$LOOP" == "playlist" ]; then LICON="󰑖 "; fi
  
  ICON=""
  APP="mpv"
  if [ "$SOURCE" == "spotify" ]; then
    ICON=""
    APP="Spotify"
  fi
  if [ "$PAUSED" == "true" ]; then
    ICON="󰏤"
  fi
  DISPLAY="$TITLE"
  if [ -n "$ARTIST" ]; then
    DISPLAY="$TITLE — $ARTIST"
  fi
  update_bar "$LICON$DISPLAY" "$APP"
  # Override icon after update_bar sets it default
  safe_set "$NAME" icon="$ICON"
  exit 0
fi

    # 1. Native NowPlaying support (via nowplaying-cli)
    NOWPLAYING="/opt/homebrew/bin/nowplaying-cli"
    if [ -f "$NOWPLAYING" ]; then
      STATE=$($NOWPLAYING get playbackRate 2>/dev/null)
      CLIENT=$($NOWPLAYING get clientIdentifier 2>/dev/null)
      # Check if client matches our allowed players
      if [[ "$CLIENT" =~ (Spotify|Music|VLC|mpv) ]]; then
        TITLE=$($NOWPLAYING get title 2>/dev/null)
        ARTIST=$($NOWPLAYING get artist 2>/dev/null)
        
        # Better mpv info handling via window title fallback
        if [[ ("$TITLE" == "mpv" || -z "$TITLE") && "$CLIENT" =~ mpv ]]; then
          TITLE=$(osascript -e 'tell application "System Events" to tell process "mpv" to return name of window 1' 2>/dev/null)
        fi
        
        # Build label based on available info
        LABEL="${TITLE:-Something}"
        if [[ -n "$TITLE" && -n "$ARTIST" && "$TITLE" != "$ARTIST" ]]; then
          LABEL="$TITLE — $ARTIST"
        fi
    
        update_bar "$LABEL" "$CLIENT"
        
        # If paused, override icon
        if [ "$STATE" != "1" ]; then
          safe_set "$NAME" icon="󰏤"
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
if pgrep -x "Spotify" >/dev/null; then
  PROPER_STATE=$(osascript -e 'tell application "Spotify" to get player state' 2>/dev/null)
  TRACK=$(osascript -e 'tell application "Spotify" to get name of current track' 2>/dev/null)
  ARTIST=$(osascript -e 'tell application "Spotify" to get artist of current track' 2>/dev/null)
  update_bar "$TRACK — $ARTIST" "Spotify"
  
  if [ "$PROPER_STATE" != "playing" ]; then
    safe_set "$NAME" icon="󰏤"
  fi
fi

if [ "$UPDATED" -eq 0 ]; then
  hide_bar
fi
