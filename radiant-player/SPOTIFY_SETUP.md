# Radiant Spotify Bootstrap

This keeps playback terminal-native (no downloads) and works with the hybrid queue.

## 1) Install dependencies

```bash
brew install spotify_player librespot
```

## 2) Authenticate spotify_player

```bash
spotify_player
```

Complete first-run auth, then quit.

## 3) Verify tool health

```bash
/opt/homebrew/bin/python3 ~/.config/radiant-player/queue.py spotify_health
```

Expected output:

```json
{"spotify_player": true, "librespot": true}
```

## 4) Add Spotify tracks into queue

```bash
/opt/homebrew/bin/python3 ~/.config/radiant-player/queue.py add_spotify "spotify:track:..."
```

or with URL:

```bash
/opt/homebrew/bin/python3 ~/.config/radiant-player/queue.py add_spotify "https://open.spotify.com/track/..."
```

## 5) Notes

- Mixed playlists save as `.rpl.json`.
- Legacy `.m3u` load still works for local-only playlists.
- Dashboard and Sketchybar show source icons (`󰎈` local, `` Spotify).
