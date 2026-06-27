#!/bin/bash
source "$HOME/.local/bin/cosmere_colors.sh"

# ── Hover / popup handling (same pattern as github.sh) ──
if [ "$SENDER" = "mouse.entered" ]; then
  sketchybar --set slack popup.drawing=on
  exit 0
elif [ "$SENDER" = "mouse.exited" ]; then
  sketchybar --set slack popup.drawing=off
  exit 0
fi

# ── Periodic / forced update ──
if [ "$SENDER" = "routine" ] || [ "$SENDER" = "forced" ]; then

  # Read user OAuth token (xoxp-...) from file
  TOKEN=""
  if [ -f "$HOME/.slack_token" ]; then
    TOKEN=$(cat "$HOME/.slack_token")
  fi

  if [ -z "$TOKEN" ]; then
    sketchybar --set slack icon.color=$WHITE label.drawing=off
    sketchybar --set slack.header label="CRYPTIC WHISPERS"
    sketchybar --set slack.status label="Add token to ~/.slack_token"
    sketchybar --set slack.presence label="" icon=""
    sketchybar --set slack.dnd label="" icon=""
    sketchybar --set slack.unreads label="" icon=""
    sketchybar --set slack.mentions label="" icon=""
    for i in 1 2 3 4 5; do
      sketchybar --set slack.ch$i drawing=off
    done
    exit 0
  fi

  # ── Helper: safe API call ──
  slack_api() {
    curl -s -H "Authorization: Bearer $TOKEN" "https://slack.com/api/$1"
  }

  # ══════════════════════════════════════════════
  # 1.  USER PROFILE  (status emoji + text)
  # ══════════════════════════════════════════════
  PROFILE_RESP=$(slack_api "users.profile.get")
  STATUS_TEXT=$(echo "$PROFILE_RESP" | grep -o '"status_text":"[^"]*"' | head -1 | sed 's/"status_text":"//;s/"//')
  STATUS_EMOJI=$(echo "$PROFILE_RESP" | grep -o '"status_emoji":"[^"]*"' | head -1 | sed 's/"status_emoji":"//;s/"//')

  if [ -n "$STATUS_TEXT" ]; then
    STATUS_DISPLAY="$STATUS_EMOJI $STATUS_TEXT"
  elif [ -n "$STATUS_EMOJI" ]; then
    STATUS_DISPLAY="$STATUS_EMOJI"
  else
    STATUS_DISPLAY="No status set"
  fi

  # ══════════════════════════════════════════════
  # 2.  PRESENCE  (active / away)
  # ══════════════════════════════════════════════
  PRESENCE_RESP=$(slack_api "users.getPresence")
  PRESENCE=$(echo "$PRESENCE_RESP" | grep -o '"presence":"[^"]*"' | head -1 | sed 's/"presence":"//;s/"//')

  if [ "$PRESENCE" = "active" ]; then
    PRESENCE_LABEL="Online"
    PRESENCE_ICON="󰐾"
    PRES_COLOR=$SPREN_CULTIVATION
  else
    PRESENCE_LABEL="Away"
    PRESENCE_ICON="󰍐"
    PRES_COLOR=$PRES_SILVER
  fi

  # ══════════════════════════════════════════════
  # 3.  DND STATUS  (Do Not Disturb)
  # ══════════════════════════════════════════════
  DND_RESP=$(slack_api "dnd.info")
  DND_ENABLED=$(echo "$DND_RESP" | grep -o '"dnd_enabled":true')
  SNOOZE_ENABLED=$(echo "$DND_RESP" | grep -o '"snooze_enabled":true')

  if [ -n "$SNOOZE_ENABLED" ]; then
    # Actively snoozing — extract remaining minutes
    SNOOZE_END=$(echo "$DND_RESP" | grep -o '"snooze_endtime":[0-9]*' | head -1 | awk -F: '{print $2}')
    NOW=$(date +%s)
    if [ -n "$SNOOZE_END" ] && [ "$SNOOZE_END" -gt "$NOW" ] 2>/dev/null; then
      REMAINING=$(( (SNOOZE_END - NOW) / 60 ))
      DND_LABEL="Snoozed · ${REMAINING}m left"
    else
      DND_LABEL="Snoozed"
    fi
    DND_ICON="󰂛"
    DND_COLOR=$SPREN_ASH
  elif [ -n "$DND_ENABLED" ]; then
    # Scheduled DND window
    NEXT_START=$(echo "$DND_RESP" | grep -o '"next_dnd_start_ts":[0-9]*' | head -1 | awk -F: '{print $2}')
    NEXT_END=$(echo "$DND_RESP" | grep -o '"next_dnd_end_ts":[0-9]*' | head -1 | awk -F: '{print $2}')
    NOW=$(date +%s)
    if [ -n "$NEXT_START" ] && [ -n "$NEXT_END" ] && [ "$NOW" -ge "$NEXT_START" ] && [ "$NOW" -le "$NEXT_END" ] 2>/dev/null; then
      DND_LABEL="DND active"
      DND_ICON="󰂛"
      DND_COLOR=$SPREN_ASH
    else
      # Not currently in DND window
      if [ -n "$NEXT_START" ] && [ "$NEXT_START" -gt "$NOW" ] 2>/dev/null; then
        NEXT_FMT=$(date -r "$NEXT_START" "+%H:%M" 2>/dev/null || echo "later")
        DND_LABEL="Next DND at $NEXT_FMT"
      else
        DND_LABEL="DND scheduled"
      fi
      DND_ICON="󰂜"
      DND_COLOR=$PRES_SILVER
    fi
  else
    DND_LABEL="Notifications on"
    DND_ICON="󰂚"
    DND_COLOR=$SPREN_CULTIVATION
  fi

  # ══════════════════════════════════════════════
  # 4.  UNREAD MESSAGES & MENTIONS + top channels
  # ══════════════════════════════════════════════
  TOTAL_UNREADS=0
  TOTAL_MENTIONS=0
  CURSOR=""
  MAX_PAGES=5
  API_ERROR=""

  # Collect top unread channels/DMs (name:count pairs)
  TOP_CHANNELS=""

  for (( page=0; page<MAX_PAGES; page++ )); do
    URL="conversations.list?types=public_channel,private_channel,im,mpim&exclude_archived=true&limit=200"
    if [ -n "$CURSOR" ]; then
      URL="${URL}&cursor=$CURSOR"
    fi

    RESPONSE=$(slack_api "$URL")

    # Check API response is valid
    OK=$(echo "$RESPONSE" | grep -o '"ok":true')
    if [ -z "$OK" ]; then
      ERROR_MSG=$(echo "$RESPONSE" | grep -o '"error":"[^"]*"' | head -1 | sed 's/"error":"//;s/"//')
      API_ERROR="${ERROR_MSG:-unknown}"
      break
    fi

    # Sum unread counts using grep + awk (no jq dependency)
    PAGE_UNREADS=$(echo "$RESPONSE" | grep -o '"unread_count_display":[0-9]*' | awk -F: '{s+=$2} END {print s+0}')
    PAGE_MENTIONS=$(echo "$RESPONSE" | grep -o '"mention_count_display":[0-9]*' | awk -F: '{s+=$2} END {print s+0}')

    TOTAL_UNREADS=$((TOTAL_UNREADS + PAGE_UNREADS))
    TOTAL_MENTIONS=$((TOTAL_MENTIONS + PAGE_MENTIONS))

    # Extract channels with unreads for popup breakdown
    # Pull name + unread_count_display pairs from this page
    # Use perl for reliable multi-field JSON extraction without jq
    PAGE_TOP=$(echo "$RESPONSE" | perl -0777 -ne '
      while (/"(?:name|user)"\s*:\s*"([^"]+)".*?"unread_count_display"\s*:\s*(\d+)/gs) {
        print "$1:$2\n" if $2 > 0;
      }' 2>/dev/null)

    if [ -n "$PAGE_TOP" ]; then
      TOP_CHANNELS="${TOP_CHANNELS}${PAGE_TOP}"$'\n'
    fi

    # Check for next page cursor
    CURSOR=$(echo "$RESPONSE" | grep -o '"next_cursor":"[^"]*"' | sed 's/"next_cursor":"//;s/"//')
    if [ -z "$CURSOR" ]; then
      break
    fi
  done

  # ══════════════════════════════════════════════
  # 5.  WORKSPACE NAME  (team.info)
  # ══════════════════════════════════════════════
  TEAM_RESP=$(slack_api "team.info")
  WORKSPACE=$(echo "$TEAM_RESP" | grep -o '"name":"[^"]*"' | head -1 | sed 's/"name":"//;s/"//')
  if [ -z "$WORKSPACE" ]; then
    WORKSPACE="Slack"
  fi

  # ══════════════════════════════════════════════
  #  UPDATE SKETCHYBAR
  # ══════════════════════════════════════════════

  if [ -n "$API_ERROR" ]; then
    sketchybar --set slack icon.color=$CRIMSON label.drawing=off
    sketchybar --set slack.header label="API ERROR"
    sketchybar --set slack.status label="$API_ERROR"
    sketchybar --set slack.presence label="" icon=""
    sketchybar --set slack.dnd label="" icon=""
    sketchybar --set slack.unreads label="" icon=""
    sketchybar --set slack.mentions label="" icon=""
    for i in 1 2 3 4 5; do
      sketchybar --set slack.ch$i drawing=off
    done
    exit 0
  fi

  # ── Bar icon state ──
  if [ "$TOTAL_MENTIONS" -gt 0 ]; then
    sketchybar --set slack icon.color=$SPREN_CRYPTIC label="$TOTAL_MENTIONS" label.drawing=on
  elif [ "$TOTAL_UNREADS" -gt 0 ]; then
    sketchybar --set slack icon.color=$SPREN_CRYPTIC label="$TOTAL_UNREADS" label.drawing=on
  elif [ -n "$SNOOZE_ENABLED" ] || { [ -n "$DND_ENABLED" ] && [ "$DND_LABEL" = "DND active" ]; }; then
    # DND active — dim the icon
    sketchybar --set slack icon.color=$PRES_SILVER label.drawing=off
  else
    sketchybar --set slack icon.color=$WHITE label.drawing=off
  fi

  # ── Popup items ──
  HEADER_UPPER=$(echo "$WORKSPACE" | tr '[:lower:]' '[:upper:]')
  sketchybar --set slack.header label="$HEADER_UPPER" \
                                label.color=$SPREN_CRYPTIC \
                                icon.color=$SPREN_CRYPTIC

  sketchybar --set slack.status icon="$PRESENCE_ICON" \
                                icon.color=$PRES_COLOR \
                                label="$PRESENCE_LABEL · $STATUS_DISPLAY"

  sketchybar --set slack.dnd icon="$DND_ICON" \
                             icon.color=$DND_COLOR \
                             label="$DND_LABEL"

  if [ "$TOTAL_UNREADS" -gt 0 ]; then
    sketchybar --set slack.unreads icon=󰛏 \
                                   icon.color=$SPREN_CRYPTIC \
                                   label="$TOTAL_UNREADS unread messages" \
                                   drawing=on
  else
    sketchybar --set slack.unreads icon=󰛏 \
                                   icon.color=$PRES_SILVER \
                                   label="Inbox zero" \
                                   drawing=on
  fi

  if [ "$TOTAL_MENTIONS" -gt 0 ]; then
    sketchybar --set slack.mentions icon=@ \
                                    icon.font="Hack Nerd Font:Bold:14.0" \
                                    icon.color=$SPREN_ASH \
                                    label="$TOTAL_MENTIONS direct mentions" \
                                    drawing=on
  else
    sketchybar --set slack.mentions icon=@ \
                                    icon.color=$PRES_SILVER \
                                    icon.font="Hack Nerd Font:Bold:14.0" \
                                    label="No new mentions" \
                                    drawing=on
  fi

  # ── Top unread channels (up to 5) ──
  # Sort by unread count descending, take top 5
  SORTED_CHANNELS=$(echo "$TOP_CHANNELS" | grep -v '^$' | sort -t: -k2 -rn | head -5)

  i=1
  while IFS=: read -r ch_name ch_count; do
    [ -z "$ch_name" ] && continue
    # Truncate long channel names
    DISPLAY_NAME="$ch_name"
    if [ ${#DISPLAY_NAME} -gt 20 ]; then
      DISPLAY_NAME="${DISPLAY_NAME:0:18}.."
    fi
    sketchybar --set slack.ch$i icon="  #" \
                                icon.font="Hack Nerd Font:Bold:12.0" \
                                icon.color=$PRES_GLACIAL \
                                label="$DISPLAY_NAME ($ch_count)" \
                                label.font="JetBrainsMono Nerd Font:Regular:12.0" \
                                drawing=on
    i=$((i + 1))
  done <<< "$SORTED_CHANNELS"

  # Hide remaining unused channel slots
  while [ $i -le 5 ]; do
    sketchybar --set slack.ch$i drawing=off
    i=$((i + 1))
  done

fi
