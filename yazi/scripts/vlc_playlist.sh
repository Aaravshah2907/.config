#!/bin/bash
PLAYLIST="/tmp/yazi_playlist.m3u"
printf '#EXTM3U\n' > "$PLAYLIST"
for file in "$@"; do
    echo "$file" >> "$PLAYLIST"
done
/Applications/VLC.app/Contents/MacOS/VLC "$PLAYLIST" &
