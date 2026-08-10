#!/usr/bin/env bash

# ──────────────────────────────────────────────
# BWIFI — University Auto-Login (Oathgate Portal)
# Runs the Wifi-Login Automator workflow on click.
# Uses Cosmere Elsecaller (Inkspren) theming.
# ──────────────────────────────────────────────

source "$HOME/.local/bin/cosmere_colors.sh"

WFLOW="$HOME/Desktop/Wifi-Login.app/Contents/document.wflow"

if [[ "$SENDER" == "mouse.clicked" ]]; then
  # Flash the icon gold to show activation (Radiant oath in progress)
  sketchybar --animate tanh 10 --set "$NAME" icon.color=$HONOR_GOLD

  # Run the automator workflow in background
  if [ -f "$WFLOW" ]; then
    automator "$WFLOW" &>/dev/null &
    disown
    # Brief pause then restore to Inkspren indigo (success)
    sleep 2
    sketchybar --animate tanh 15 --set "$NAME" icon.color=$SPREN_INK
  else
    # Workflow missing — flash Ruin's Maroon (error)
    sleep 1
    sketchybar --animate tanh 15 --set "$NAME" icon.color=$RUIN_MAROON
  fi
  exit 0
fi

# Hover animations (delegated from hover.sh wrapper)
if [[ "$SENDER" == "mouse.entered" ]]; then
  sketchybar --animate tanh 15 --set "$NAME" icon.font.size=24
  exit 0
elif [[ "$SENDER" == "mouse.exited" ]]; then
  sketchybar --animate tanh 15 --set "$NAME" icon.font.size=18
  exit 0
fi

# Default state — Inkspren indigo
sketchybar --set "$NAME" icon.color=$SPREN_INK
