#!/bin/bash

PY="/Users/aaravshah2975/.config/radiant-player/queue.py"

read -r "uri? Spotify URI/URL: "
[ -z "$uri" ] && exit 0

/opt/homebrew/bin/python3 "$PY" add_spotify "$uri" >/dev/null 2>&1
