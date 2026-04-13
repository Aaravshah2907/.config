#!/bin/bash

# Simple icon map that translates app names into standard Nerd Font icons.
# If you are using the true `sketchybar-app-font`, you might need to adjust these, 
# but this script maps common app names to standard Nerd Font characters since 
# you have label.font="sketchybar-app-font" (which supports standard Nerd Font too).

# Trim leading and trailing spaces that PWAs sometimes inject
APP_NAME=$(echo "$1" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

case "$APP_NAME" in
  "Terminal" | "iTerm" | "iTerm2" | "Alacritty" | "Kitty")
    icon=""
    ;;
  "Safari" | "Safari Technology Preview")
    icon="󰀹"
    ;;
  "Google Chrome" | "Chromium")
    icon=""
    ;;
  "Brave Browser" | "Brave")
    icon="🦁"
    ;;
  "Firefox" | "Firefox Developer Edition")
    icon="󰈹"
    ;;
  "Finder")
    icon="󰀶"
    ;;
  "Messages")
    icon="󰍦"
    ;;
  "Mail" | "Microsoft Outlook" | "Gmail" | "gmail")
    icon="󰇮"
    ;;
  "Music" | "Spotify" | "Apple Music")
    icon="󰓇"
    ;;
  "mpv" | "mpv.player" | "io.mpv")
    icon=""
    ;;
  "VLC" | "vlc" | "VLC Player")
    icon="󰕼"
    ;;
  "Code" | "Visual Studio Code" | "VSCodium")
    icon="󰨞"
    ;;
  "Finder")
    icon="󰀶"
    ;;
  "Discord")
    icon="󰙯"
    ;;
  "Slack")
    icon="󰒱"
    ;;
  "Calendar" | "Fantastical" | "Google Calendar" | "gcal")
    icon="󰃭"
    ;;
  "Notes")
    icon="󰎚"
    ;;
  "System Settings" | "System Preferences")
    icon="󰒓"
    ;;
  "Preview")
    icon="󰋲"
    ;;
  "Weather")
    icon="󰖐"
    ;;
  "Google Classroom" | "Classroom" | "classroom")
    icon="󰑒"
    ;;
  "Google Gemini" | "google gemini" | "gemini" | "ChatGPT" | "chatgpt" | "Perplexity" | "perplexity")
    icon="󱚤"
    ;;
  "Chess" | "chess" | "Chess.com" | "Lichess")
    icon="󰡙"
    ;;
  "GitHub" | "github")
    icon="󰊤"
    ;;
  "app_mode_loader")
    icon="󰖟" # Generic globe icon since all PWAs share this name
    ;;
  "YouTube" | "youtube")
    icon="󰗃"
    ;;
  *)
    icon="󰀱" # Default fallback icon
    ;;
esac

echo "$icon"
