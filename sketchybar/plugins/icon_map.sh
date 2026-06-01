#!/bin/bash

# Simple icon map that translates app names into standard Nerd Font icons.
# If you are using the true `sketchybar-app-font`, you might need to adjust these, 
# but this script maps common app names to standard Nerd Font characters since 
# you have label.font="sketchybar-app-font" (which supports standard Nerd Font too).

# Trim leading and trailing spaces that PWAs sometimes inject
APP_NAME=$(echo "$1" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

case "$APP_NAME" in
  "Terminal" | "iTerm" | "iTerm2" | "Alacritty" | "Kitty" | "Warp" | "WezTerm")
    icon="󰆍"
    ;;
  "Safari" | "Safari Technology Preview")
    icon="󰀹"
    ;;
  "Google Chrome" | "Chromium")
    icon="󰊯"
    ;;
  "Brave Browser" | "Brave")
    icon="󰖟"
    ;;
  "Arc")
    icon="󰞍"
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
  "Telegram")
    icon=""
    ;;
  "WhatsApp" | "WhatsApp Web")
    icon="󰖣"
    ;;
  "Slack")
    icon="󰒱"
    ;;
  "Discord")
    icon="󰙯"
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
  "Code" | "Visual Studio Code" | "VSCodium" | "Cursor" | "Windsurf" | "Antigravity IDE" | "Antigravity" | "AntigravityIDE" | "Codeforces")
    icon="󰨞"
    ;;
  "Xcode" | "IntelliJ IDEA" | "WebStorm" | "PyCharm" | "Rider" | "CLion" | "PhpStorm" | "Android Studio" | "Sublime Text")
    icon="󰨞"
    ;;
  "Calendar" | "Fantastical" | "Google Calendar" | "gcal")
    icon="󰃭"
    ;;
  "Notes")
    icon="󰎚"
    ;;
  "Notion")
    icon="󱚣"
    ;;
  "Obsidian")
    icon="󰶲"
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
  "Google Gemini" | "google gemini" | "gemini")
    icon="󱚤"
    ;;
  "ChatGPT" | "chatgpt")
    icon="󰚩"
    ;;
  "Perplexity" | "perplexity")
    icon="󰭹"
    ;;
  "Chess" | "chess" | "Chess.com" | "Lichess")
    icon="󰡙"
    ;;
  "GitHub" | "github" | "GitHub Desktop")
    icon="󰊤"
    ;;
  "Figma")
    icon="󰽉"
    ;;
  "Zoom" | "Zoom.us")
    icon="󰵗"
    ;;
  "Microsoft Teams" | "Teams")
    icon="󰊻"
    ;;
  "1Password" | "Bitwarden")
    icon="󰢬"
    ;;
  "Calculator")
    icon="󰃬"
    ;;
  "Reminders")
    icon="󰏚"
    ;;
  "App Store")
    icon="󰗎"
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
