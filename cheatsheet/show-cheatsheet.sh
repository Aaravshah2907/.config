#!/bin/bash

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"

export CHEATSHEET_FRONT_APP="$(
  /opt/homebrew/bin/aerospace list-windows --focused --format '%{app-name}' 2>/dev/null
)"

python3 \
/Users/aaravshah2975/.config/cheatsheet/generate_cheatsheet.py

python3 \
/Users/aaravshah2975/.config/cheatsheet/show_window.py
