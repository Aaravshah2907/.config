#!/bin/bash

# CPKB SketchyBar Plugin
# Handles hover effects and click events

# Theme Colors (Ensure they match your overall sketchybar theme)
COLOR_BG=0xff1e1e2e
COLOR_BG_HOVER=0xff313244

if [ "$SENDER" = "mouse.entered" ]; then
  # Hover effect: Show background and change color
  sketchybar --set "$NAME" background.drawing=on \
                           background.color="$COLOR_BG_HOVER"
elif [ "$SENDER" = "mouse.exited" ]; then
  # Remove hover effect
  sketchybar --set "$NAME" background.drawing=off \
                           background.color="$COLOR_BG"
elif [ "$SENDER" = "mouse.clicked" ]; then
  # Prompt user for search term
  SEARCH_TERM=$(osascript -e 'Tell application "System Events" to display dialog "Search snippets:" default answer ""' -e 'text returned of result' 2>/dev/null)
  
  if [ $? -eq 0 ]; then
    # Query database: search by title, tags, or id. Limit to 5 results for sanity.
    RESULTS=$(sqlite3 "$HOME/.local/share/cpkb/snippets.db" "SELECT id || ' | ' || title FROM snippets WHERE title LIKE '%$SEARCH_TERM%' OR tags LIKE '%$SEARCH_TERM%' OR id LIKE '%$SEARCH_TERM%' ORDER BY created_at DESC LIMIT 5;")
    
    if [ -z "$RESULTS" ]; then
      osascript -e 'display notification "No matching snippet found" with title "CPKB Search"'
      exit 0
    fi
    
    # Format list for AppleScript
    AS_LIST=""
    while read -r line; do
        if [ -n "$AS_LIST" ]; then
            AS_LIST="$AS_LIST, "
        fi
        line_escaped=$(echo "$line" | sed 's/"/\\"/g')
        AS_LIST="$AS_LIST\"$line_escaped\""
    done <<< "$RESULTS"
    
    # Show choose from list dialog
    SELECTION=$(osascript -e "choose from list {$AS_LIST} with prompt \"Select a snippet to copy:\"" 2>/dev/null)
    
    if [ "$SELECTION" != "false" ] && [ -n "$SELECTION" ]; then
      # Extract ID (first word before the '|')
      SNIPPET_ID=$(echo "$SELECTION" | awk '{print $1}')
      # Copy to clipboard using the python CLI
      cpkb copy "$SNIPPET_ID"
      osascript -e "display notification \"Snippet $SNIPPET_ID copied to clipboard!\" with title \"CPKB\""
    fi
  fi
fi
