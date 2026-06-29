#!/bin/bash
source "$HOME/.local/bin/cosmere_colors.sh"

# ── Hover / popup handling ──
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
    for i in {1..5}; do
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
  STATUS_TEXT=$(echo "$PROFILE_RESP" | jq -r '.profile.status_text // empty')
  STATUS_EMOJI=$(echo "$PROFILE_RESP" | jq -r '.profile.status_emoji // empty')

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
  PRESENCE=$(echo "$PRESENCE_RESP" | jq -r '.presence // "away"')

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
  DND_ENABLED=$(echo "$DND_RESP" | jq -r '.dnd_enabled // false')
  SNOOZE_ENABLED=$(echo "$DND_RESP" | jq -r '.snooze_enabled // false')

  if [ "$SNOOZE_ENABLED" = "true" ]; then
    # Actively snoozing — extract remaining minutes
    SNOOZE_END=$(echo "$DND_RESP" | jq -r '.snooze_endtime // empty')
    NOW=$(date +%s)
    if [ -n "$SNOOZE_END" ] && [ "$SNOOZE_END" -gt "$NOW" ] 2>/dev/null; then
      REMAINING=$(( (SNOOZE_END - NOW) / 60 ))
      DND_LABEL="Snoozed · ${REMAINING}m left"
    else
      DND_LABEL="Snoozed"
    fi
    DND_ICON="󰂛"
    DND_COLOR=$SPREN_ASH
  elif [ "$DND_ENABLED" = "true" ]; then
    # Scheduled DND window
    NEXT_START=$(echo "$DND_RESP" | jq -r '.next_dnd_start_ts // empty')
    NEXT_END=$(echo "$DND_RESP" | jq -r '.next_dnd_end_ts // empty')
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
  # 4.  UNREAD MESSAGES (via Slack API)
  # ══════════════════════════════════════════════
  TOTAL_UNREADS=0
  TOTAL_MENTIONS=0
  TOP_CHANNELS=""
  API_ERROR=""
  CURSOR=""
  MAX_PAGES=5

  # Get our user ID to check for mentions
  AUTH_RESP=$(slack_api "auth.test")
  MY_USER_ID=$(echo "$AUTH_RESP" | jq -r '.user_id')

  for (( page=0; page<MAX_PAGES; page++ )); do
    URL="users.conversations?types=public_channel,private_channel,im,mpim&exclude_archived=true&limit=200"
    if [ -n "$CURSOR" ] && [ "$CURSOR" != "null" ]; then
      URL="${URL}&cursor=$CURSOR"
    fi

    RESPONSE=$(slack_api "$URL")
    OK=$(echo "$RESPONSE" | jq -r '.ok')
    if [ "$OK" != "true" ]; then
      API_ERROR=$(echo "$RESPONSE" | jq -r '.error // "unknown"')
      break
    fi

    CHANNEL_IDS=$(echo "$RESPONSE" | jq -r '.channels[]? | .id')
    
    for CH_ID in $CHANNEL_IDS; do
      # Get last_read timestamp
      INFO=$(slack_api "conversations.info?channel=$CH_ID")
      INFO_OK=$(echo "$INFO" | jq -r '.ok')
      if [ "$INFO_OK" != "true" ]; then
        continue
      fi
      
      CH_NAME=$(echo "$INFO" | jq -r '.channel.name // .channel.user // "dm"')
      LAST_READ=$(echo "$INFO" | jq -r '.channel.last_read // "0"')
      
      if [ "$LAST_READ" = "0" ] || [ "$LAST_READ" = "null" ]; then
        continue
      fi
      
      # Fetch messages newer than last_read
      HIST=$(slack_api "conversations.history?channel=$CH_ID&oldest=$LAST_READ&limit=100")
      HIST_OK=$(echo "$HIST" | jq -r '.ok')
      if [ "$HIST_OK" != "true" ]; then
        continue
      fi
      
      # Count unread messages (exclude the message that matches last_read if it appears)
      UNREAD=$(echo "$HIST" | jq "[.messages[]? | select(.ts != \"$LAST_READ\")] | length")
      
      # Count mentions for this user
      MENTIONS=$(echo "$HIST" | jq "[.messages[]? | select(.ts != \"$LAST_READ\") | select(.text | test(\"<@$MY_USER_ID>\"))] | length" 2>/dev/null || echo "0")
      
      if [ "$UNREAD" -gt 0 ]; then
        TOTAL_UNREADS=$((TOTAL_UNREADS + UNREAD))
        TOTAL_MENTIONS=$((TOTAL_MENTIONS + MENTIONS))
        TOP_CHANNELS="${TOP_CHANNELS}${CH_NAME}:${UNREAD}"$'\n'
      fi
    done

    CURSOR=$(echo "$RESPONSE" | jq -r '.response_metadata.next_cursor // empty')
    if [ -z "$CURSOR" ] || [ "$CURSOR" = "null" ]; then
      break
    fi
  done

  # ══════════════════════════════════════════════
  # 5.  WORKSPACE NAME  (team.info)
  # ══════════════════════════════════════════════
  TEAM_RESP=$(slack_api "team.info")
  WORKSPACE=$(echo "$TEAM_RESP" | jq -r '.team.name // "Slack"')

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
    for i in {1..5}; do
      sketchybar --set slack.ch$i drawing=off
    done
    exit 0
  fi

  # ── Bar icon state ──
  if [ "$TOTAL_MENTIONS" -gt 0 ]; then
    sketchybar --set slack icon.color=$SPREN_CRYPTIC label="$TOTAL_MENTIONS" label.drawing=on
  elif [ "$TOTAL_UNREADS" -gt 0 ]; then
    sketchybar --set slack icon.color=$SPREN_CRYPTIC label="$TOTAL_UNREADS" label.drawing=on
  elif [ "$SNOOZE_ENABLED" = "true" ] || { [ "$DND_ENABLED" = "true" ] && [ "$DND_LABEL" = "DND active" ]; }; then
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
  SORTED_CHANNELS=$(echo "$TOP_CHANNELS" | grep -v '^$' | sort -t: -k2 -rn | head -5)

  i=1
  while IFS=: read -r ch_name ch_count; do
    [ -z "$ch_name" ] && continue
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
