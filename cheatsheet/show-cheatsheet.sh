#!/bin/bash

export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"

export CHEATSHEET_FRONT_APP="$(
  /opt/homebrew/bin/aerospace list-windows --focused --format '%{app-name}' 2>/dev/null
)"

# Find python binary with webview module available
if python3 -c "import webview" >/dev/null 2>&1; then
    PYTHON_BIN="python3"
elif /opt/homebrew/bin/python3.14 -c "import webview" >/dev/null 2>&1; then
    PYTHON_BIN="/opt/homebrew/bin/python3.14"
else
    PYTHON_BIN="python3"
fi

$PYTHON_BIN /Users/aaravshah2975/.config/cheatsheet/show_window.py
