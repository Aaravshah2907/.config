#!/usr/bin/env zsh

# Source colors
source "$CONFIG_DIR/colors.sh"

SKHDRC="$HOME/.config/skhd/skhdrc"

# Remove existing dynamic cheatsheet items
sketchybar --remove '/cheatsheet\.item\..*/'

# Read skhdrc and parse
counter=0
current_comment=""
typeset -A seen_comments

# Read file line by line
while IFS= read -r line || [ -n "$line" ]; do
  # Trim whitespace
  line=$(echo "$line" | xargs)

  # Check if it's a comment
  if [[ "$line" =~ ^# ]]; then
    # Skip separator/header lines
    if [[ "$line" =~ "===" || "$line" =~ "---" || "$line" =~ "# #" ]]; then
      continue
    fi
    current_comment=$(echo "$line" | sed 's/^#[[:space:]]*//' | xargs)
    continue
  fi

  # Check if it's a binding
  if [[ "$line" =~ ":" ]]; then
    if [ -n "$current_comment" ]; then
      # Extract shortcut keys
      keys=$(echo "$line" | cut -d':' -f1 | xargs)

      # Format the keys beautifully
      formatted_keys=$(echo "$keys" | tr '[:lower:]' '[:upper:]' \
        | sed 's/HYPER/✦/g' \
        | sed 's/CTRL/⌃/g' \
        | sed 's/ALT/⌥/g' \
        | sed 's/CMD/⌘/g' \
        | sed 's/SHIFT/⇧/g' \
        | sed 's/LSHIFT/⇧/g' \
        | sed 's/RSHIFT/⇧/g' \
        | sed 's/+/ /g' \
        | sed 's/-/ /g' \
        | sed -E 's/[[:space:]]+/ /g' \
        | xargs)

      # Skip duplicates for range definitions
      if [ -n "${seen_comments[$current_comment]}" ]; then
        continue
      fi
      seen_comments[$current_comment]=1

      # Increment counter
      counter=$((counter + 1))

      # Add item to sketchybar cheatsheet popup
      sketchybar --add item cheatsheet.item.$counter popup.cheatsheet \
                 --set cheatsheet.item.$counter \
                            icon="$formatted_keys" \
                            icon.width=140 \
                            icon.color=$HONOR_GOLD \
                            icon.font="JetBrainsMono Nerd Font:Bold:13.0" \
                            label="$current_comment" \
                            label.color=$WHITE \
                            label.font="JetBrainsMono Nerd Font:Bold:13.0"
      
      current_comment=""
    fi
  fi
done < "$SKHDRC"
