#!/bin/bash

PY="$(dirname "$(realpath "$0")")/queue.py"

read -r "uri? Spotify URI/URL: "
[ -z "$uri" ] && exit 0

if python3 "$PY" add_spotify "$uri"; then
    echo "  Success!"
else
    echo "  Failed to add track."
fi
sleep 1
