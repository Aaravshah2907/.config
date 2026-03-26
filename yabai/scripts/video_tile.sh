#!/bin/bash
# Open the video in mpv
mpv "$1" &

# Wait for window to register
sleep 0.4

# Set current split so terminal takes 75% (3/4) and mpv takes 25% (1/4)
yabai -m window --ratio abs:0.75
