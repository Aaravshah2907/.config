#!/bin/bash
source "$HOME/.local/bin/cosmere_colors.sh"

MAX_EVENTS=8
HOURS_AHEAD=8

# Calculate the end time (8 hours from now)
END_TIME=$(date -v+${HOURS_AHEAD}H '+%Y-%m-%d %H:%M:%S %z')

# ──────────────────────────────────────────────
# Calendar → Cosmere Color Mapping
# ──────────────────────────────────────────────
get_calendar_color() {
  case "$1" in
    "Lecture 📚")                     echo "$SPREN_HONOR" ;;       # Honorspren sky blue — lectures = knowledge
    "Laboratory 🔬")                  echo "$SPREN_CULTIVATION" ;; # Cultivationspren green — lab = growth
    "Tutorial 💻")                    echo "$SPREN_CRYPTIC" ;;       # Cryptic orchid — tutorials = logic
    "Test")                           echo "$SPREN_ASH" ;;         # Ashspren volcanic red — tests = fire
    "Personal Studies / Paper Solving") echo "$PRES_LAVENDER" ;;   # Preservation lavender — calm study
    "Homework / Personal Notes")      echo "$PRES_ATIUM" ;;       # Atium pale gold — stored work
    "PS/SI")                          echo "$SPREN_WILL" ;;        # Willshaper amethyst — practice sessions
    "Family")                         echo "$SPREN_SIBLING" ;;     # Sibling crystal amber — family bonds
    "aaravshah2975@gmail.com")        echo "$SAPPHIRE" ;;          # Windrunner sapphire — personal
    "f20231325@pilani.bits-pilani.ac.in") echo "$PRES_GLACIAL" ;;  # Preservation glacial — college
    "Birthdays")                      echo "$SPREN_GLORY" ;;       # Gloryspren gold — celebrations
    "Reminders")                      echo "$PRES_SILVER" ;;       # Frosted silver — reminders
    *)                                echo "$LABEL_COLOR" ;;       # Default white
  esac
}

# ──────────────────────────────────────────────
# Fetch events separated by calendar (-sc)
# -df "" suppresses the date, keeps only time
# location included for room numbers
# ──────────────────────────────────────────────
RAW=$(icalBuddy -n -nc -b "" -ps "/ | /" -eep "notes,attendees" \
  -nrd -ea -sc -df "" \
  -iep "title,datetime,location" -po "title,datetime,location" \
  eventsFrom:"now" to:"$END_TIME" 2>/dev/null)

# Hide the spacer item (fixes the gap)
sketchybar --set clock.events drawing=off

if [ -z "$RAW" ]; then
  sketchybar --set clock.event.1 label="No upcoming events" label.color=$LABEL_COLOR drawing=on
  for i in $(seq 2 $MAX_EVENTS); do
    sketchybar --set clock.event.$i drawing=off
  done
  exit 0
fi

# ──────────────────────────────────────────────
# Parse: calendar headers look like "CalName:"
# followed by "---..." separator, then event lines
# ──────────────────────────────────────────────
declare -a EVENT_LABELS
declare -a EVENT_COLORS
CURRENT_CAL=""

while IFS= read -r line; do
  # Skip empty lines and separator lines
  [ -z "$line" ] && continue
  [[ "$line" =~ ^-+$ ]] && continue

  # Calendar header line ends with ":"
  if [[ "$line" =~ ^(.+):$ ]]; then
    CURRENT_CAL="${BASH_REMATCH[1]}"
    continue
  fi

  # This is an event line — reformat location into brackets
  # Input:  "Title | 10:00 - 11:00 | location: Room"
  # Output: "Title | 10:00 - 11:00 (Room)"
  FORMATTED=$(echo "$line" | sed 's/ | location: / (/;s/$/)/' )
  # If there was no location, the sed won't match and we get a trailing ")"
  # so check and clean up
  if ! echo "$line" | grep -q " | location: "; then
    FORMATTED="$line"
  fi

  COLOR=$(get_calendar_color "$CURRENT_CAL")
  EVENT_LABELS+=("$FORMATTED")
  EVENT_COLORS+=("$COLOR")
done <<< "$RAW"

# ──────────────────────────────────────────────
# Sort events by time and assign to popup slots
# ──────────────────────────────────────────────
# Build sortable entries: "HH:MM|index"
declare -a SORT_KEYS
for idx in "${!EVENT_LABELS[@]}"; do
  # Extract time portion (e.g. "10:00" from "... at 10:00 - 11:00")
  TIME_PART=$(echo "${EVENT_LABELS[$idx]}" | grep -oE '[0-9]{1,2}:[0-9]{2}' | head -1)
  SORT_KEYS+=("${TIME_PART:-99:99}|$idx")
done

# Sort by time
SORTED=$(printf '%s\n' "${SORT_KEYS[@]}" | sort -t'|' -k1)

i=1
while IFS='|' read -r _ idx; do
  [ -z "$idx" ] && continue
  if [ $i -le $MAX_EVENTS ]; then
    sketchybar --set clock.event.$i \
      label="${EVENT_LABELS[$idx]}" \
      label.color="${EVENT_COLORS[$idx]}" \
      click_script="open -a Calendar" \
      drawing=on
  fi
  i=$((i + 1))
done <<< "$SORTED"

# Hide unused event slots
for j in $(seq $i $MAX_EVENTS); do
  sketchybar --set clock.event.$j drawing=off
done
