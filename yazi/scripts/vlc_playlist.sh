#!/bin/bash
PLAYLIST="/tmp/yazi_playlist.m3u"
> "$PLAYLIST"
for file in "$@"; do
    echo "$file" >> "$PLAYLIST"
done
/Applications/VLC.app/Contents/MacOS/VLC "$PLAYLIST" &
