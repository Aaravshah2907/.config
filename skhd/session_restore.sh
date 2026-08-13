#!/bin/bash

# Ensure Homebrew path is available when executed from launchd/skhd daemon context
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# Target apps for workflow restoration aligned with your space mappings
APPS=(
  "iTerm"           # Workspace T (terminal)
  "Cursor"          # Workspace C (code)
  "Brave Browser"   # Workspace B (browser)
  "ChatGPT"         # Workspace M (chat)
  "Spotify"         # Workspace S (media)
)

echo "Restoring workspace session..."

# Launch non-running apps in parallel to speed up restoration
for APP in "${APPS[@]}"; do
    is_running=$(osascript -e "application \"$APP\" is running" 2>/dev/null)
    if [ "$is_running" != "true" ]; then
        echo "Launching $APP..."
        if [ "$APP" = "ChatGPT" ]; then
            open -g -a "$HOME/Applications/Brave Browser Apps.localized/ChatGPT.app" &
        else
            open -g -a "$APP" & # Run in background asynchronously
        fi
    fi
done

# Wait briefly for applications to spin up
sleep 1.5

# Re-apply window placement rules to any newly opened windows
aerospace list-windows --all --format '%{window-id}|%{app-name}' | while IFS='|' read -r wid app; do
    if [[ "$app" == "iTerm2" || "$app" == "Terminal" || "$app" == "iTerm" ]]; then
        aerospace move-node-to-workspace T --window-id "$wid" 2>/dev/null
    elif [[ "$app" == "Code" || "$app" == "VS Code" || "$app" == "Cursor" || "$app" == "Antigravity IDE" || "$app" == "Claude" ]]; then
        aerospace move-node-to-workspace C --window-id "$wid" 2>/dev/null
    elif [[ "$app" == "Brave Browser" || "$app" == "Google Chrome" || "$app" == "Safari" || "$app" == "Firefox" ]]; then
        aerospace move-node-to-workspace B --window-id "$wid" 2>/dev/null
    elif [[ "$app" == "ChatGPT" || "$app" == "Gemini" ]]; then
        aerospace move-node-to-workspace M --window-id "$wid" 2>/dev/null
    elif [[ "$app" == "Spotify" || "$app" == "Music" ]]; then
        aerospace move-node-to-workspace S --window-id "$wid" 2>/dev/null
    fi
done

# Focus Space T (Terminal) to start clean
aerospace workspace T 2>/dev/null

echo "Workspace restore complete."
