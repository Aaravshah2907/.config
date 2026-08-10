#!/usr/bin/env bash

# ──────────────────────────────────────────────
# WARP — Cloudflare WARP VPN Status (Preservation Shield)
# Shows connection state with Cosmere-themed colors:
#   Connected   → Cultivationspren green (growth/safety)
#   Connecting  → Honor Gold (oath in progress)
#   Disconnected→ Ruin Maroon (exposed/unprotected)
#
# Click toggles connect/disconnect.
# Adaptive polling: 30s when connected, 5s when connecting, 10s when off.
# ──────────────────────────────────────────────

source "$HOME/.local/bin/cosmere_colors.sh"

ICON_CONNECTED="󰒄"     # shield-check
ICON_CONNECTING="󰒅"    # shield-half (transitional)
ICON_DISCONNECTED="󰦞"  # shield-off

# ── Click handler: toggle WARP ──
if [[ "$SENDER" == "mouse.clicked" ]]; then
  STATUS=$(/usr/local/bin/warp-cli status 2>/dev/null | head -1)
  if echo "$STATUS" | grep -q "Status update: Connected"; then
    sketchybar --animate tanh 10 --set "$NAME" icon.color=$HONOR_GOLD
    /usr/local/bin/warp-cli disconnect &>/dev/null &
    disown
  else
    sketchybar --animate tanh 10 --set "$NAME" icon.color=$HONOR_GOLD
    /usr/local/bin/warp-cli connect &>/dev/null &
    disown
  fi
  sleep 2
  # Fall through to status update below
fi

# ── Hover animations ──
if [[ "$SENDER" == "mouse.entered" ]]; then
  sketchybar --animate tanh 15 --set "$NAME" icon.font.size=24
  exit 0
elif [[ "$SENDER" == "mouse.exited" ]]; then
  sketchybar --animate tanh 15 --set "$NAME" icon.font.size=18
  exit 0
fi

# ── Status polling ──
STATUS=$(/usr/local/bin/warp-cli status 2>/dev/null | head -1)

if echo "$STATUS" | grep -q "Status update: Connected"; then
  ICON="$ICON_CONNECTED"
  COLOR="$OK_COLOR"
  FREQ=30
elif echo "$STATUS" | grep -qiE "Connecting|Registering"; then
  ICON="$ICON_CONNECTING"
  COLOR="$HONOR_GOLD"
  FREQ=5
else
  ICON="$ICON_DISCONNECTED"
  COLOR="$RUIN_MAROON"
  FREQ=10
fi

sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" update_freq="$FREQ"
