#!/bin/sh
source "$HOME/.local/bin/cosmere_colors.sh"

if [ "$SENDER" = "front_app_switched" ]; then
  ICON=$("$HOME/.config/sketchybar/plugins/icon_map.sh" "$INFO" 2>/dev/null)
  [ -z "$ICON" ] && ICON="󰀱"

  # Chameleon Accent Colors
  case "$INFO" in
    "Code"|"Cursor") APP_COLOR=$SPREN_INK ;;
    "Spotify") APP_COLOR=$SPREN_CULTIVATION ;;
    "Brave Browser"|"Google Chrome"|"Arc"|"Safari") APP_COLOR=$SPREN_HONOR ;;
    "Discord") APP_COLOR=$SPREN_SIBLING ;;
    "Terminal"|"iTerm2"|"WezTerm"|"kitty") APP_COLOR=$FRONTAPP_ACCENT ;;
    "Slack") APP_COLOR=$WARN_COLOR ;;
    *) APP_COLOR=$WHITE ;;
  esac

  /opt/homebrew/bin/sketchybar --set "$NAME" icon="$ICON" label="$INFO" icon.color="$APP_COLOR" label.color="$APP_COLOR"
  # Also update the unified left pill border to match the app!
  /opt/homebrew/bin/sketchybar --set apple.pill background.border_color="$APP_COLOR"
fi
