#!/usr/bin/env bash
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
source "$HOME/.local/bin/cosmere_colors.sh"

# Handle hover for Music (Peek mode)
if [ "$SENDER" = "mouse.entered" ]; then
  sketchybar --set "$NAME" popup.drawing=on
  exit 0
fi

if [ "$SENDER" = "mouse.exited" ]; then
  sketchybar --set "$NAME" popup.drawing=off
  exit 0
fi

# Function to safely update sketchybar items
UPDATED=0
echo "$(date) NAME=$NAME SENDER=$SENDER" >> /tmp/sketchybar_music.log
safe_set() {
  local item="$1"
  shift
  sketchybar --query "$item" >/dev/null 2>&1 && sketchybar --set "$item" "$@"
}

# Clean up music temp log file if creation time is older than 24 hours
LOG_FILE="/tmp/sketchybar_music.log"
if [ -f "$LOG_FILE" ]; then
  find "$LOG_FILE" -type f -Bmin +43200 -delete 2>/dev/null
fi

update_bar() {
  local label="$1"
  local app="$2"
  local filepath="$3"
  local icon="󰎆"
  local icon_color="$MUSIC_ACCENT"       # Willshaper amethyst — freedom of song
  
  local check_str="${filepath:-$label}"
  
  case "$app" in
    *[Ss]potify*) icon=""; app_name="Spotify"; icon_color="$SPREN_CULTIVATION" ;; # Cultivationspren — living growth
    *[Aa]pple*[Mm]usic*) icon="󰎆"; app_name="Music"; icon_color="$MUSIC_ACCENT" ;;  # Willshaper — pure song
    *[Vv][Ll][Cc]*)
      app_name="VLC"
      icon_color="$RUIN_SPIKE"           # Hemalurgic amber — raw power playback
      icon="󰕼" # Default VLC cone
      if echo "$check_str" | grep -iqE '\.(mp3|wav|flac|m4a|aac|ogg|wma|m4b)$'; then
        icon="󰎆" # Music note for audio
      elif echo "$check_str" | grep -iqE '\.(mp4|mkv|avi|mov|webm|m4v|flv|wmv)$'; then
        icon="󰕼" # VLC cone for video
      fi
      ;;
    *mpv*) icon=""; app_name="mpv"; icon_color="$PRES_GLACIAL" ;; # Preservation glacial — pure, local media
    *) 
      # Filter: restrict to designated music apps
      return 
      ;;
  esac

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
  # Default View: idle / nothing playing
  sketchybar --set "$NAME" drawing=on \
                   icon.drawing=on \
                   label.drawing=on \
                   label="Resting" \
                   icon="󰋋" \
                   icon.color="$PRES_SILVER" \
                   label.color="$PRES_SILVER_TRANSLUCENT"
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
      if [ "$CLIENT" = "null" ] || [ -z "$CLIENT" ]; then
        CLIENT=$($NOWPLAYING get clientBundleIdentifier 2>/dev/null)
      fi
      # Check if client matches our allowed players (case-insensitively)
      CLIENT_LOWER=$(echo "$CLIENT" | tr '[:upper:]' '[:lower:]')
      if [[ "$CLIENT_LOWER" =~ (spotify|music|vlc|mpv) ]]; then
        TITLE=$($NOWPLAYING get title 2>/dev/null)
        ARTIST=$($NOWPLAYING get artist 2>/dev/null)
        
        # Better mpv info handling via window title fallback
        if [[ ("$TITLE" == "mpv" || -z "$TITLE") && "$CLIENT_LOWER" =~ mpv ]]; then
          TITLE=$(osascript -e 'tell application "System Events" to tell process "mpv" to return name of window 1' 2>/dev/null)
        fi
        
        # Build label based on available info
        LABEL="${TITLE:-Something}"
        if [[ -n "$TITLE" && -n "$ARTIST" && "$TITLE" != "$ARTIST" ]]; then
          LABEL="$TITLE — $ARTIST"
        fi
    
        update_bar "$LABEL" "$CLIENT"

        # Update media header icon for VLC
        if [[ "$CLIENT_LOWER" == *vlc* ]]; then
          if echo "$LABEL" | grep -iqE '\.(mp3|wav|flac|m4a|aac|ogg|wma|m4b)$'; then
            sketchybar --set media.header icon="󰎆" label="VLC AUDIO" icon.color="$AMBER" label.color="$AMBER"
          else
            sketchybar --set media.header icon="󰕼" label="VLC VIDEO" icon.color="$AMBER" label.color="$AMBER"
          fi
        else
          sketchybar --set media.header icon="󰎈" label="THE RADIANT SONG" icon.color="$RADIANT_GOLD" label.color="$RADIANT_GOLD"
        fi
                
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
  
  if [[ -n "$TRACK" ]]; then
    LABEL="$TRACK"
    if [[ -n "$ARTIST" ]]; then
      LABEL="$TRACK — $ARTIST"
    fi
    update_bar "$LABEL" "Spotify"
    
    if [ "$PROPER_STATE" != "playing" ]; then
      safe_set "$NAME" icon="󰏤"
    fi
  fi
fi

# 4. VLC Fallback (if nowplaying-cli misses it)
if pgrep -x "VLC" >/dev/null; then
  VLC_TITLE=$(osascript -e 'tell application "VLC" to get name of current item' 2>/dev/null)
  if [[ -n "$VLC_TITLE" && "$VLC_TITLE" != "missing value" ]]; then
    VLC_PATH=$(osascript -e 'tell application "VLC" to get path of current item' 2>/dev/null)
    VLC_STATE=$(osascript -e 'tell application "System Events" to tell process "VLC" to return (exists menu item "Pause" of menu "Playback" of menu bar 1)' 2>/dev/null)
    
    update_bar "$VLC_TITLE" "VLC" "$VLC_PATH"
    
    if echo "$VLC_PATH" | grep -iqE '\.(mp3|wav|flac|m4a|aac|ogg|wma|m4b)$'; then
      sketchybar --set media.header icon="󰎆" label="VLC AUDIO" icon.color="$AMBER" label.color="$AMBER"
    else
      sketchybar --set media.header icon="󰕼" label="VLC VIDEO" icon.color="$AMBER" label.color="$AMBER"
    fi
    
    if [ "$VLC_STATE" == "false" ]; then
      safe_set "$NAME" icon="󰏤"
    fi
  fi
fi

if [ "$UPDATED" -eq 0 ]; then
  hide_bar
fi
