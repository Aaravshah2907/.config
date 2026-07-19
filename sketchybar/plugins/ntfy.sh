#!/bin/bash
# ============================================================
# ntfy.sh SketchyBar Plugin
# Polls the ntfy.sh topic for new messages and displays them
# in a hoverable popup — styled with your Cosmere palette.
# ============================================================
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
source "$HOME/.local/bin/cosmere_colors.sh"

SECRETS_FILE="$HOME/.local/share/alert-secrets.sh"
if [ -f "$SECRETS_FILE" ]; then
  # shellcheck source=/dev/null
  source "$SECRETS_FILE"
fi

if [ -z "$ALERT_NTFY_TOPIC" ]; then
  sketchybar --set ntfy drawing=off
  exit 0
fi

NTFY_TOPIC="$ALERT_NTFY_TOPIC"
NTFY_URL="https://ntfy.sh/${NTFY_TOPIC}/json?poll=1&since=12h"
# Stores the unix timestamp of the latest message the user has "seen"
SEEN_TS_FILE="/tmp/ntfy_seen_ts"
MSGS_CACHE="/tmp/ntfy_msgs_cache"

# --- Hover: show/hide popup ---
if [ "$SENDER" = "mouse.entered" ]; then
  sketchybar --set "$NAME" popup.drawing=on
  exit 0
fi
if [ "$SENDER" = "mouse.exited" ]; then
  sketchybar --set "$NAME" popup.drawing=off
  exit 0
fi

# --- Click: mark all as read, update UI directly ---
if [ "$SENDER" = "mouse.clicked" ]; then
  sketchybar --set "$NAME" popup.drawing=off
  # Save current time — everything up to now is "seen"
  date +%s > "$SEEN_TS_FILE"
  # Immediately hide badge and reset icon colour
  sketchybar --set ntfy drawing=off label.drawing=off icon.color="$PRES_MIST"
  # Reset all popup rows to white (no longer highlighted)
  for i in 1 2 3 4 5; do
    sketchybar --set "ntfy.msg$i" label.color="$WHITE"
  done
  exit 0
fi

# --- Routine / Forced: poll ntfy ---
if [ "$SENDER" = "routine" ] || [ "$SENDER" = "forced" ]; then

  # Fetch NDJSON from ntfy (each line is a JSON event)
  RAW=$(curl -sf --max-time 5 "$NTFY_URL" 2>/dev/null)
  if [ -z "$RAW" ]; then
    sketchybar --set ntfy drawing=off
    exit 0
  fi

  # Parse with jq — filter only message events, sort by time, keep last 5
  PARSED=$(echo "$RAW" | jq -sc '
    [ .[] | select(.event == "message") ] |
    sort_by(.time) |
    .[-5:]
  ' 2>/dev/null)

  if [ -z "$PARSED" ] || [ "$PARSED" = "[]" ]; then
    sketchybar --set ntfy drawing=off
    exit 0
  fi

  # Cache for potential future use
  echo "$RAW" > "$MSGS_CACHE"

  # Read last-seen timestamp (default to 0 = never seen anything)
  LAST_SEEN_TS=0
  [ -f "$SEEN_TS_FILE" ] && LAST_SEEN_TS=$(cat "$SEEN_TS_FILE")

  # Count messages newer than the last-seen timestamp
  UNREAD=$(echo "$PARSED" | jq --argjson last "$LAST_SEEN_TS" \
    '[ .[] | select(.time > $last) ] | length' 2>/dev/null)
  UNREAD=${UNREAD:-0}

  # --- Icon + color based on unread count ---
  if [ "$UNREAD" -gt 5 ]; then
    ICON_COLOR="$RUIN_MAROON"
    ICON="󰵙"
  elif [ "$UNREAD" -gt 0 ]; then
    ICON_COLOR="$NOTIF_ACCENT"
    ICON="󰵙"
  else
    ICON_COLOR="$PRES_MIST"
    ICON="󰵙"
  fi

  # --- Update main bar item ---
  if [ "$UNREAD" -gt 0 ]; then
    sketchybar --set ntfy \
      drawing=on \
      icon="$ICON" \
      icon.color="$ICON_COLOR" \
      label="$UNREAD" \
      label.drawing=on \
      label.color="$ICON_COLOR"
  else
    # No unread — hide the item entirely
    sketchybar --set ntfy drawing=off
  fi

  # --- Populate popup rows (oldest → newest, top → bottom) ---
  TOTAL=$(echo "$PARSED" | jq 'length' 2>/dev/null)
  for i in 1 2 3 4 5; do
    IDX=$((i - 1))

    MSG_JSON=$(echo "$PARSED" | jq -r ".[$IDX] // empty" 2>/dev/null)
    if [ -z "$MSG_JSON" ]; then
      sketchybar --set "ntfy.msg$i" drawing=off
      continue
    fi

    MSG_TEXT=$(echo "$MSG_JSON" | jq -r '.message // .title // "—"' 2>/dev/null | cut -c1-48)
    MSG_TIME=$(echo "$MSG_JSON" | jq -r '.time // 0' 2>/dev/null)

    # Format unix timestamp as HH:MM
    if [ "$MSG_TIME" -gt 0 ] 2>/dev/null; then
      FORMATTED_TIME=$(date -r "$MSG_TIME" "+%H:%M" 2>/dev/null)
    else
      FORMATTED_TIME="--:--"
    fi

    # Highlight unread rows using numeric timestamp comparison
    if [ "$MSG_TIME" -gt "$LAST_SEEN_TS" ] 2>/dev/null; then
      ROW_COLOR="$NOTIF_ACCENT"   # Gold — unread
    else
      ROW_COLOR="$WHITE"          # White — already seen
    fi

    sketchybar --set "ntfy.msg$i" \
      drawing=on \
      icon="$FORMATTED_TIME" \
      icon.font="JetBrainsMono Nerd Font:Bold:11.0" \
      icon.color="$PRES_MIST" \
      label="$MSG_TEXT" \
      label.color="$ROW_COLOR"
  done

fi
