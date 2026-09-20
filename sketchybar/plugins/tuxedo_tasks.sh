#!/bin/bash

TODO_FILE="${TODO_FILE:-$HOME/.tuxedo-todo/todo.txt}"
TODAY=$(date +%F)
WEEK_END=$(date -v+7d +%F 2>/dev/null || date +%F)

if [ ! -r "$TODO_FILE" ]; then
  sketchybar --set tuxedo_tasks drawing=off
  exit 0
fi

summary=$(
  awk -v today="$TODAY" -v week_end="$WEEK_END" '
    function trim(s) { sub(/^[[:space:]]+/, "", s); sub(/[[:space:]]+$/, "", s); return s }
    function pri_rank(p) {
      if (p == "A") return 1
      if (p == "B") return 2
      if (p == "C") return 3
      if (p == "T") return 4
      if (p == "") return 9
      return 5
    }
    function projects(line, out, count, i, token) {
      out = ""
      count = split(line, parts, /[[:space:]]+/)
      for (i = 1; i <= count; i++) {
        token = parts[i]
        if (token ~ /^\+/) {
          sub(/^\+/, "", token)
          if (token != "" && out !~ "(^|,)" token "(,|$)") {
            out = out (out == "" ? "" : ",") token
          }
        }
      }
      return out
    }
    function due_date(line, found) {
      found = ""
      if (match(line, /due:[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/)) {
        found = substr(line, RSTART + 4, 10)
      }
      return found
    }
    /^[[:space:]]*x[[:space:]]/ { next }
    /^[[:space:]]*$/ { next }
    {
      pending++
      p = ""
      if (match($0, /^\(([A-Z])\)/)) p = substr($0, 2, 1)
      r = pri_rank(p)
      task_projects = projects($0)
      if (task_projects == "") task_projects = "untagged"
      if (top == "" || r < top_rank) {
        top = task_projects
        top_rank = r
        top_pri = p
      }
      due = due_date($0)
      if (due != "" && due >= today && due <= week_end && (week_top == "" || r < week_top_rank)) {
        week_top = task_projects
        week_top_rank = r
        week_top_pri = p
      }
      if (shown < 3) {
        list = list (list == "" ? "" : " | ") task_projects
        shown++
      }
    }
    END {
      if (pending == 0) exit
      if (top_pri == "") top_pri = "-"
      if (week_top == "") {
        week_top = top
        week_top_pri = top_pri
      }
      if (week_top_pri == "") week_top_pri = "-"
      print pending "\t" week_top_pri "\t" week_top "\t" list
    }
  ' "$TODO_FILE"
)

if [ -z "$summary" ]; then
  sketchybar --set tuxedo_tasks drawing=off
  exit 0
fi

count=$(printf "%s" "$summary" | cut -f1)
top_pri=$(printf "%s" "$summary" | cut -f2)
top_projects=$(printf "%s" "$summary" | cut -f3)
top_three=$(printf "%s" "$summary" | cut -f4)

sketchybar --set tuxedo_tasks drawing=on \
  icon="󰄱" \
  label="$count pending: $top_three" \
  popup.drawing=off \
  --set tuxedo_tasks.top label="Week P$top_pri: +$top_projects" \
  --set tuxedo_tasks.more label="Top: $top_three"
