#!/bin/bash

# Ensure Homebrew path is available when executed from launchd/skhd daemon
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

APP_NAME="$1"

# Brave PWA wrappers — map app names to explicit .app bundle paths
declare -A BRAVE_APPS
BRAVE_APPS["ChatGPT"]="$HOME/Applications/Brave Browser Apps.localized/ChatGPT.app"

# Check if the application is running
is_running=$(osascript -e "application \"$APP_NAME\" is running" 2>/dev/null)

if [ "$is_running" = "true" ]; then
    # Focus the application
    osascript -e "tell application \"$APP_NAME\" to activate"
else
    # Launch — use Brave wrapper path if applicable
    brave_path="${BRAVE_APPS[$APP_NAME]}"
    if [ -n "$brave_path" ] && [ -d "$brave_path" ]; then
        open -a "$brave_path"
    else
        open -a "$APP_NAME"
    fi
fi
