#!/bin/bash

# Ensure Homebrew path is available when executed from launchd/skhd daemon
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# Define the menu options
OPTIONS=(
  "1: Edit Yabai Config"
  "2: Edit Skhd Config"
  "3: Edit SketchyBar Config"
  "4: Reload Yabai"
  "5: Reload Skhd"
  "6: Reload SketchyBar"
  "7: Restart All Services"
  "8: Open Logs"
  "9: Restore Workspace Session"
)

# Join options with commas for AppleScript
IFS=$'\n'
OPTIONS_LIST=$(printf '"%s", ' "${OPTIONS[@]}")
OPTIONS_LIST=${OPTIONS_LIST%, } # Remove trailing comma and space

# Display native keyboard-navigable list dialog
CHOICE=$(osascript -e "
tell application \"System Events\"
  activate
  set theChoice to choose from list {$OPTIONS_LIST} with title \"Control Center\" with prompt \"Select action:\" default items {\"${OPTIONS[0]}\"}
  return theChoice
end tell
" 2>/dev/null)

# Exit if cancelled
if [ "$CHOICE" = "false" ] || [ -z "$CHOICE" ]; then
    exit 0
fi

case "$CHOICE" in
  "1: Edit Yabai Config")
    open -a "Cursor" ~/.config/yabai/yabairc
    ;;
  "2: Edit Skhd Config")
    open -a "Cursor" ~/.config/skhd/skhdrc
    ;;
  "3: Edit SketchyBar Config")
    open -a "Cursor" ~/.config/sketchybar/sketchybarrc
    ;;
  "4: Reload Yabai")
    yabai --restart-service
    ;;
  "5: Reload Skhd")
    pkill -USR1 skhd
    ;;
  "6: Reload SketchyBar")
    sketchybar --reload
    ;;
  "7: Restart All Services")
    yabai --restart-service
    brew services restart skhd
    sketchybar --reload
    ;;
  "8: Open Logs")
    touch /tmp/yabai.log
    open -a "Cursor" /tmp/yabai.log
    ;;
  "9: Restore Workspace Session")
    bash ~/.config/skhd/session_restore.sh
    ;;
esac
