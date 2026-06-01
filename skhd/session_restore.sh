#!/bin/bash

# Ensure Homebrew path is available when executed from launchd/skhd daemon context
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# Target apps for workflow restoration aligned with your space mappings
APPS=(
  "iTerm"           # Space 1 (terminal)
  "Cursor"          # Space 2 (code)
  "Brave Browser"   # Space 3 (browser)
  "ChatGPT"         # Space 4 (chat)
  "Spotify"         # Space 5/6 (media)
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
yabai -m query --windows | python3 -c "
import json, sys, subprocess
windows = json.load(sys.stdin)
for w in windows:
    app = w.get('app', '')
    wid = w.get('id')
    # Move them to their assigned workspaces if they are out of place
    if app == 'iTerm2' or app == 'Terminal' or app == 'iTerm':
        subprocess.run(['yabai', '-m', 'window', str(wid), '--space', 'terminal'], stderr=subprocess.DEVNULL)
    elif app in ['Code', 'VS Code', 'Cursor', 'Antigravity IDE', 'Claude']:
        subprocess.run(['yabai', '-m', 'window', str(wid), '--space', 'code'], stderr=subprocess.DEVNULL)
    elif app in ['Brave Browser', 'Google Chrome', 'Safari', 'Firefox']:
        subprocess.run(['yabai', '-m', 'window', str(wid), '--space', 'browser'], stderr=subprocess.DEVNULL)
    elif app in ['ChatGPT', 'Gemini']:
        subprocess.run(['yabai', '-m', 'window', str(wid), '--space', 'chat'], stderr=subprocess.DEVNULL)
    elif app in ['Spotify', 'Music'] and not w.get('is-native-fullscreen', False):
        subprocess.run(['yabai', '-m', 'window', str(wid), '--space', 'media'], stderr=subprocess.DEVNULL)
" 2>/dev/null

# Focus Space 1 (Terminal) to start clean
yabai -m space --focus terminal 2>/dev/null || yabai -m space --focus 1

echo "Workspace restore complete."
