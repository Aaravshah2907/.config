#!/usr/bin/env bash
set -u

DIALOG=/usr/local/bin/dialog
CPKB=/opt/homebrew/bin/cpkb
JQ=/opt/homebrew/bin/jq

notify() {
  "$DIALOG" --notification --style pseudo-banner --title "$1" --message "$2" >/dev/null 2>&1 || true
}

SEARCH_JSON=$("$DIALOG" --title "CPKB Search" \
  --message "" --hideicon \
  --textfield '{"title":"Search term","name":"query","required":true}' \
  --json --button1text "Search" --button2text "Cancel" --hideicon --small --width 420 --height 180 --ontop) || {
    exit 0
  }

SEARCH_TERM=$(printf '%s' "$SEARCH_JSON" | "$JQ" -r '.query // empty')
if [[ -z "$SEARCH_TERM" ]]; then
  exit 0
fi

if ! RESULTS=$("$CPKB" query "$SEARCH_TERM" --limit 5 2>&1); then
  notify "CPKB" "Search failed. Check CPKB database access."
  exit 1
fi

if [[ -z "$RESULTS" ]]; then
  notify "CPKB Search" "No matching snippet found"
  exit 0
fi

RESULT_IDS=()
DISPLAY_VALUES=()
while IFS='|' read -r raw_id title; do
  id=$(printf '%s' "$raw_id" | tr -d '[:space:]')
  title=${title# }
  [[ -z "$id" ]] && continue
  RESULT_IDS+=("$id")
  DISPLAY_VALUES+=("$id | $title")
done <<< "$RESULTS"

if [[ ${#RESULT_IDS[@]} -eq 0 ]]; then
  notify "CPKB Search" "No matching snippet found"
  exit 0
fi

SELECT_CONFIG=$(printf '%s\n' "${DISPLAY_VALUES[@]}" | /usr/bin/python3 -c 'import json,sys; values=[line.rstrip("\n") for line in sys.stdin]; print(json.dumps({"title":"Select a snippet to copy","name":"snippet","values":values,"style":"list","required":True}, ensure_ascii=False))')
SELECTION_JSON=$("$DIALOG" --title "CPKB Search" \
  --message "" --hideicon \
  --selectitem "$SELECT_CONFIG" --json \
  --button1text "Copy" --button2text "Cancel" --hideicon --small --width 520 --height 330 --ontop) || {
    exit 0
  }

SELECTION=$(printf '%s' "$SELECTION_JSON" | "$JQ" -r '.SelectedOption // .snippet // empty')
SNIPPET_ID=${SELECTION%% |*}
if [[ -z "$SNIPPET_ID" || "$SNIPPET_ID" == "$SELECTION" ]]; then
  notify "CPKB" "Could not read the selected snippet"
  exit 1
fi

if "$CPKB" copy "$SNIPPET_ID"; then
  notify "CPKB" "Snippet $SNIPPET_ID copied to clipboard"
else
  notify "CPKB" "Could not copy snippet $SNIPPET_ID"
  exit 1
fi
