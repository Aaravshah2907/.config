#!/bin/bash

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"

export CHEATSHEET_FRONT_APP="$(
  /opt/homebrew/bin/yabai -m query --windows --window 2>/dev/null \
    | python3 -c 'import json,sys; print(json.load(sys.stdin).get("app",""))' 2>/dev/null
)"

python3 \
/Users/aaravshah2975/.config/cheatsheet/generate_cheatsheet.py

python3 \
/Users/aaravshah2975/.config/cheatsheet/show_window.py
