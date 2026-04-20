#!/usr/bin/env python3
import json
import os
import random
import re
import socket
import subprocess
import sys
import time
import uuid
from datetime import datetime, timezone
from pathlib import Path
from urllib import error as urlerror
from urllib import request as urlrequest

# Configuration
SOCKET_PATH = "/tmp/mpv-yazi.sock"
STATE_PATH = Path(os.path.expanduser("~/.config/radiant-player/queue_state.json"))
PLAYLIST_DIR = Path(os.path.expanduser("~/.config/mpv/playlists"))
LOCK_PATH = Path("/tmp/radiant-player.lock")

BOLD = "\033[1m"
DIM = "\033[2m"
CYAN = "\033[38;5;81m"     # Stormlight Glow (Sapphire)
MAGENTA = "\033[38;5;141m"  # Shardblade (Violet)
GREEN = "\033[38;5;121m"    # Lifebound (Emerald)
YELLOW = "\033[38;5;220m"   # Honor's Gold (Heliodor)
BLUE = "\033[38;5;69m"      # Windrunner Blue
RED = "\033[38;5;160m"      # Voidlight / Odium
GRAY = "\033[38;5;240m"     # Rosharan Slate
NC = "\033[0m"

LOCAL_ICON = "󰎈"
SPOTIFY_ICON = ""
REST_ICON = "󰓛"

IDEALS = [
    "First Ideal: Life before death. Strength before weakness. Journey before destination.",
    "Second Ideal: I will protect those who cannot protect themselves.",
    "Third Ideal: I will protect even those I hate, so long as it is right.",
    "Fourth Ideal: I accept that there will be those I cannot protect.",
    "Fifth Ideal: I will protect myself, so that I may continue to protect others.",
]

DEFAULT_STATE = {
    "version": 2,
    "queue": [],
    "current_index": -1,
    "loop_mode": "off",  # off | single | playlist
    "shuffle": False,
    "active_source": None,  # local | spotify
    "last_status": {
        "running": False,
        "paused": True,
        "title": "Resting",
        "artist": "",
        "source": None,
        "loop": "off",
        "position": 0,
        "duration": 0,
    },
}


def now_iso():
    return datetime.now(timezone.utc).isoformat()


def resolve_bin(name):
    for candidate in (f"/opt/homebrew/bin/{name}", f"/usr/local/bin/{name}", name):
        if os.path.isabs(candidate):
            if os.path.exists(candidate):
                return candidate
        else:
            if subprocess.run(
                ["bash", "-lc", f"command -v {candidate} >/dev/null 2>&1"], check=False
            ).returncode == 0:
                return candidate
    return name


MPV_BIN = resolve_bin("mpv")
SPOTIFY_PLAYER_BIN = resolve_bin("spotify_player")
LIBRESPOT_BIN = resolve_bin("librespot")


def _deep_merge(base, extra):
    out = dict(base)
    for k, v in extra.items():
        if isinstance(v, dict) and isinstance(out.get(k), dict):
            out[k] = _deep_merge(out[k], v)
        else:
            out[k] = v
    return out


def load_state():
    if not STATE_PATH.exists():
        return json.loads(json.dumps(DEFAULT_STATE))
    try:
        with STATE_PATH.open("r", encoding="utf-8") as f:
            raw = json.load(f)
        return _deep_merge(json.loads(json.dumps(DEFAULT_STATE)), raw)
    except Exception:
        return json.loads(json.dumps(DEFAULT_STATE))


def save_state(state):
    STATE_PATH.parent.mkdir(parents=True, exist_ok=True)
    tmp = STATE_PATH.with_suffix(".tmp")
    with tmp.open("w", encoding="utf-8") as f:
        json.dump(state, f, indent=2, ensure_ascii=False)
    tmp.replace(STATE_PATH)


def is_mpv_running():
    if not os.path.exists(SOCKET_PATH):
        return False
    try:
        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as s:
            s.settimeout(0.2)
            s.connect(SOCKET_PATH)
            return True
    except Exception:
        return False


def mpv_send(cmd):
    if not is_mpv_running():
        return None
    try:
        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as s:
            s.connect(SOCKET_PATH)
            req_id = random.randint(1, 10000)
            payload = json.dumps({"command": cmd, "request_id": req_id}) + "\n"
            s.sendall(payload.encode())
            s.settimeout(2.0)
            response = b""
            while True:
                chunk = s.recv(65536)
                if not chunk:
                    break
                response += chunk
                if b"\n" not in response:
                    continue
                lines = response.decode("utf-8", "replace").split("\n")
                for line in lines:
                    if not line.strip():
                        continue
                    try:
                        data = json.loads(line)
                    except Exception:
                        continue
                    if data.get("request_id") == req_id:
                        return data
                if len(response) > 1024 * 1024:
                    break
    except Exception:
        return None
    return None


def ensure_mpv():
    if is_mpv_running():
        return
    if os.path.exists(SOCKET_PATH):
        try:
            os.remove(SOCKET_PATH)
        except OSError:
            pass
    subprocess.Popen(
        [MPV_BIN, "--no-video", "--idle=yes", "--title=${media-title}", f"--input-ipc-server={SOCKET_PATH}"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    for _ in range(30):
        if is_mpv_running():
            return
        time.sleep(0.1)


def shell_ok(cmd):
    return subprocess.run(["bash", "-lc", cmd], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode == 0


def spotify_cmd(args):
    if not shell_ok(f"command -v {SPOTIFY_PLAYER_BIN} >/dev/null 2>&1"):
        return False, "spotify_player missing"
    p = subprocess.run(
        [SPOTIFY_PLAYER_BIN, *args],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        check=False,
    )
    return p.returncode == 0, (p.stdout or p.stderr).strip()


def spotify_pause():
    spotify_cmd(["playback", "pause"])


def spotify_toggle():
    ok, _ = spotify_cmd(["playback", "toggle"])
    if ok:
        return True
    # fallback verbs across versions
    for args in (["playback", "play-pause"], ["playback", "playpause"]):
        ok, _ = spotify_cmd(args)
        if ok:
            return True
    return False


def spotify_next():
    ok, _ = spotify_cmd(["playback", "next"])
    return ok


def spotify_prev():
    ok, _ = spotify_cmd(["playback", "previous"])
    if ok:
        return True
    ok, _ = spotify_cmd(["playback", "prev"])
    return ok


def normalize_spotify_uri(raw):
    raw = raw.strip()
    if raw.startswith("spotify:"):
        return raw
    m = re.search(r"open\.spotify\.com/(track|album|playlist)/([A-Za-z0-9]+)", raw)
    if m:
        return f"spotify:{m.group(1)}:{m.group(2)}"
    return raw


def spotify_id_from_uri(uri):
    if not uri:
        return ""
    if uri.startswith("spotify:"):
        parts = uri.split(":")
        return parts[-1] if parts else uri
    m = re.search(r"open\.spotify\.com/(?:track|album|playlist)/([A-Za-z0-9]+)", uri)
    if m:
        return m.group(1)
    return uri


def spotify_kind_from_uri(uri):
    if uri.startswith("spotify:"):
        parts = uri.split(":")
        if len(parts) >= 3:
            return parts[1]
    m = re.search(r"open\.spotify\.com/(track|album|playlist)/([A-Za-z0-9]+)", uri)
    if m:
        return m.group(1)
    return ""


def spotify_cached_access_token():
    token_file = Path(os.path.expanduser("~/.cache/spotify-player/user_client_token.json"))
    if not token_file.exists():
        return ""
    try:
        with token_file.open("r", encoding="utf-8") as f:
            data = json.load(f)
    except Exception:
        return ""

    # Support multiple possible shapes from spotify_player cache versions.
    candidates = [
        data.get("access_token"),
        data.get("token", {}).get("access_token") if isinstance(data.get("token"), dict) else None,
        data.get("client_token", {}).get("access_token") if isinstance(data.get("client_token"), dict) else None,
    ]
    for t in candidates:
        if isinstance(t, str) and t:
            return t
    return ""


def spotify_track_metadata(uri):
    uri = normalize_spotify_uri(uri)
    kind = spotify_kind_from_uri(uri)
    sid = spotify_id_from_uri(uri)
    if kind != "track" or not sid:
        return {}

    # Prefer spotify_player's own API bridge (works with local auth/session).
    ok, out = spotify_cmd(["get", "item", "--id", sid, "track"])
    if ok and out:
        try:
            payload = json.loads(out)
            title = payload.get("name") or sid
            artists = payload.get("artists") or []
            artist = ", ".join(a.get("name", "") for a in artists if isinstance(a, dict)).strip(", ")
            album = (payload.get("album") or {}).get("name", "")
            duration = payload.get("duration") or {}
            duration_sec = duration.get("secs") if isinstance(duration, dict) else None
            return {
                "spotify_id": sid,
                "title": title,
                "artist": artist,
                "album": album,
                "duration_sec": duration_sec,
            }
        except json.JSONDecodeError:
            pass

    # Fallback: direct web API from cached token.
    token = spotify_cached_access_token()
    if not token:
        return {}
    req = urlrequest.Request(
        f"https://api.spotify.com/v1/tracks/{sid}",
        headers={"Authorization": f"Bearer {token}"},
    )
    try:
        with urlrequest.urlopen(req, timeout=5) as resp:
            payload = json.loads(resp.read().decode("utf-8", "replace"))
        title = payload.get("name") or sid
        artists = payload.get("artists") or []
        artist = ", ".join(a.get("name", "") for a in artists if isinstance(a, dict)).strip(", ")
        album = (payload.get("album") or {}).get("name", "")
        duration_sec = int((payload.get("duration_ms") or 0) / 1000) if payload.get("duration_ms") else None
        return {
            "spotify_id": sid,
            "title": title,
            "artist": artist,
            "album": album,
            "duration_sec": duration_sec,
        }
    except (urlerror.URLError, json.JSONDecodeError, TimeoutError):
        return {}


def spotify_play_uri(uri):
    uri = normalize_spotify_uri(uri)
    kind = spotify_kind_from_uri(uri)
    sid = spotify_id_from_uri(uri)

    attempts = []
    # spotify_player v0.20+ typed start commands.
    if kind == "track" and sid:
        attempts.extend(
            [
                ["playback", "start", "track", "--id", sid],
                ["playback", "start", "track", "--name", sid],
            ]
        )
    elif kind in ("playlist", "album", "artist") and sid:
        attempts.extend(
            [
                ["playback", "start", "context", "--id", sid, kind],
                ["playback", "start", "context", "--name", sid, kind],
            ]
        )

    # Legacy attempts for older versions.
    attempts.extend(
        [
            ["playback", "start", "--uri", uri],
            ["playback", "play", "--uri", uri],
            ["playback", "start", uri],
            ["playback", "play", uri],
        ]
    )

    for args in attempts:
        ok, _ = spotify_cmd(args)
        if ok:
            return True, uri
    return False, uri


def spotify_status():
    """
    Best-effort adapter for multiple spotify_player versions.
    """
    paused = False
    title = None
    artist = ""
    position = 0
    duration = 0
    running = shell_ok(f"command -v {SPOTIFY_PLAYER_BIN} >/dev/null 2>&1")
    if not running:
        return {"running": False, "paused": True, "title": None, "artist": "", "position": 0, "duration": 0}

    # try JSON first (spotify_player v0.20+ CLI shape)
    ok, out = spotify_cmd(["get", "key", "playback"])
    if ok and out:
        try:
            data = json.loads(out)
            title = data.get("item", {}).get("name") or data.get("name")
            artists = data.get("item", {}).get("artists") or data.get("artists") or []
            if isinstance(artists, list):
                artist = ", ".join(a.get("name", "") if isinstance(a, dict) else str(a) for a in artists).strip(", ")
            paused = not bool(data.get("is_playing", data.get("playing", True)))
            position = int((data.get("progress_ms") or 0) / 1000)
            duration = int((data.get("item", {}).get("duration_ms") or data.get("duration_ms") or 0) / 1000)
            return {"running": True, "paused": paused, "title": title, "artist": artist, "position": position, "duration": duration}
        except Exception:
            pass

    # plain fallback
    ok, out = spotify_cmd(["status"])
    if ok and out:
        body = out.lower()
        paused = "paused" in body and "playing" not in body
        lines = [x.strip() for x in out.splitlines() if x.strip()]
        if lines:
            title = lines[0]
            if " - " in title:
                parts = title.split(" - ", 1)
                title, artist = parts[0].strip(), parts[1].strip()
    return {"running": True, "paused": paused, "title": title, "artist": artist, "position": position, "duration": duration}


def spotify_health():
    data = {
        "spotify_player": shell_ok(f"command -v {SPOTIFY_PLAYER_BIN} >/dev/null 2>&1"),
        "librespot": shell_ok(f"command -v {LIBRESPOT_BIN} >/dev/null 2>&1"),
    }
    print(json.dumps(data))


def entry_title(entry):
    if entry.get("artist"):
        return f"{entry.get('title', 'Unknown')} — {entry['artist']}"
    return entry.get("title", "Unknown")


def source_icon(source):
    return SPOTIFY_ICON if source == "spotify" else LOCAL_ICON


def ensure_index(state):
    q = state["queue"]
    if not q:
        state["current_index"] = -1
        state["active_source"] = None
        return
    if state["current_index"] < 0:
        state["current_index"] = 0
    if state["current_index"] >= len(q):
        state["current_index"] = len(q) - 1


def stop_inactive_source(source):
    if source == "spotify":
        mpv_send(["set_property", "pause", True])
    elif source == "local":
        spotify_pause()


def update_last_status(state, running=False, paused=True, title="Resting", artist="", source=None, position=0, duration=0):
    state["last_status"] = {
        "running": running,
        "paused": paused,
        "title": title or "Resting",
        "artist": artist or "",
        "source": source,
        "loop": state.get("loop_mode", "off"),
        "position": position or 0,
        "duration": duration or 0,
    }


def play_current(state):
    ensure_index(state)
    if state["current_index"] < 0 or state["current_index"] >= len(state["queue"]):
        update_last_status(state)
        return
    item = state["queue"][state["current_index"]]
    source = item.get("source", "local")
    stop_inactive_source(source)

    if source == "local":
        path = item.get("local_path")
        if not path:
            return
        ensure_mpv()
        mpv_send(["loadfile", path, "replace"])
        mpv_send(["set_property", "pause", False])
        pos = mpv_send(["get_property", "time-pos"])
        dur = mpv_send(["get_property", "duration"])
        update_last_status(
            state,
            running=True,
            paused=False,
            title=item.get("title") or Path(path).name,
            artist=item.get("artist", ""),
            source="local",
            position=(pos or {}).get("data", 0),
            duration=(dur or {}).get("data", item.get("duration_sec", 0)),
        )
    else:
        ok, _ = spotify_play_uri(item.get("spotify_uri", ""))
        if ok:
            st = spotify_status()
            update_last_status(
                state,
                running=True,
                paused=st["paused"],
                title=st.get("title") or item.get("title", "Spotify"),
                artist=st.get("artist") or item.get("artist", ""),
                source="spotify",
                position=st.get("position", 0),
                duration=st.get("duration", item.get("duration_sec", 0)),
            )
        else:
            update_last_status(
                state,
                running=True,
                paused=True,
                title=item.get("spotify_id") or item.get("title", "Spotify item"),
                artist=item.get("artist", ""),
                source="spotify",
            )
    state["active_source"] = source


def refresh_live_status(state):
    idx = state.get("current_index", -1)
    q = state.get("queue", [])
    if idx < 0 or idx >= len(q):
        update_last_status(state)
        return
    item = q[idx]
    source = item.get("source", "local")
    if source == "local":
        if not is_mpv_running():
            update_last_status(state, running=False, paused=True, title=item.get("title", "Resting"), artist=item.get("artist", ""), source="local")
            return
        title = mpv_send(["get_property", "media-title"])
        paused = mpv_send(["get_property", "pause"])
        pos = mpv_send(["get_property", "time-pos"])
        dur = mpv_send(["get_property", "duration"])
        update_last_status(
            state,
            running=True,
            paused=(paused or {}).get("data", True),
            title=(title or {}).get("data", item.get("title", "Unknown")),
            artist=item.get("artist", ""),
            source="local",
            position=(pos or {}).get("data", 0),
            duration=(dur or {}).get("data", 0),
        )
    else:
        # Backfill metadata for older queue entries that only had Spotify IDs.
        if (not item.get("artist")) and item.get("spotify_uri"):
            meta = spotify_track_metadata(item.get("spotify_uri", ""))
            if meta:
                item["title"] = meta.get("title") or item.get("title")
                item["artist"] = meta.get("artist", item.get("artist", ""))
                item["album"] = meta.get("album", item.get("album", ""))
                item["spotify_id"] = meta.get("spotify_id") or item.get("spotify_id")
                if meta.get("duration_sec"):
                    item["duration_sec"] = meta.get("duration_sec")
        st = spotify_status()
        update_last_status(
            state,
            running=st["running"],
            paused=st["paused"],
            title=st.get("title") or item.get("spotify_id") or item.get("title", "Spotify"),
            artist=st.get("artist") or item.get("artist", ""),
            source="spotify",
            position=st.get("position", 0),
            duration=st.get("duration", 0),
        )


def with_lock():
    LOCK_PATH.parent.mkdir(parents=True, exist_ok=True)
    fd = os.open(str(LOCK_PATH), os.O_CREAT | os.O_RDWR, 0o600)
    if hasattr(os, "lockf"):
        os.lockf(fd, os.F_LOCK, 0)
    return fd


def unlock(fd):
    if hasattr(os, "lockf"):
        os.lockf(fd, os.F_ULOCK, 0)
    os.close(fd)


def signal_refresh():
    try:
        if os.getenv("YAZI_ID"):
            subprocess.run(["ya", "emit", "redraw"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False)
            subprocess.run(["ya", "pub", "music-update"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False)
    except Exception:
        pass


def cmd_play(files):
    state = load_state()
    was_empty = len(state["queue"]) == 0
    for f in files:
        ap = os.path.abspath(f)
        title = Path(ap).stem
        state["queue"].append(
            {
                "id": str(uuid.uuid4()),
                "source": "local",
                "title": title,
                "artist": "",
                "album": "",
                "local_path": ap,
                "spotify_uri": "",
                "duration_sec": None,
                "added_at": now_iso(),
            }
        )
    if state["current_index"] == -1 and state["queue"]:
        state["current_index"] = 0
    # Preserve old behavior: first local enqueue starts playback immediately.
    if was_empty and state["queue"]:
        state["current_index"] = 0
        play_current(state)
    save_state(state)


def cmd_add_spotify(raw):
    uri = normalize_spotify_uri(raw)
    sid = spotify_id_from_uri(uri)
    meta = spotify_track_metadata(uri)
    state = load_state()
    state["queue"].append(
        {
            "id": str(uuid.uuid4()),
            "source": "spotify",
            "title": meta.get("title") or sid or "Spotify track",
            "artist": meta.get("artist", ""),
            "album": meta.get("album", ""),
            "local_path": "",
            "spotify_uri": uri,
            "spotify_id": meta.get("spotify_id") or sid,
            "duration_sec": meta.get("duration_sec"),
            "added_at": now_iso(),
        }
    )
    if state["current_index"] == -1:
        state["current_index"] = 0
    save_state(state)
    print(f"Added {SPOTIFY_ICON} {uri}")


def cmd_resolve_spotify_meta(raw):
    uri = normalize_spotify_uri(raw)
    sid = spotify_id_from_uri(uri)
    meta = spotify_track_metadata(uri)
    print(
        json.dumps(
            {
                "spotify_uri": uri,
                "spotify_id": meta.get("spotify_id") or sid,
                "title": meta.get("title") or sid,
                "artist": meta.get("artist", ""),
                "album": meta.get("album", ""),
            }
        )
    )


def cmd_list():
    state = load_state()
    ensure_index(state)
    for i, item in enumerate(state["queue"]):
        marker = "▶" if i == state["current_index"] else " "
        icon = source_icon(item.get("source"))
        print(f"{i} | {marker} | {icon} {entry_title(item)}")


def cmd_play_index(idx):
    state = load_state()
    ensure_index(state)
    if idx < 0 or idx >= len(state["queue"]):
        return
    if idx == state.get("current_index"):
        cmd_toggle()
        return
    state["current_index"] = idx
    play_current(state)
    save_state(state)


def cmd_remove(idx):
    state = load_state()
    if idx < 0 or idx >= len(state["queue"]):
        return
    state["queue"].pop(idx)
    if idx < state["current_index"]:
        state["current_index"] -= 1
    ensure_index(state)
    refresh_live_status(state)
    save_state(state)


def cmd_move(idx, offset):
    state = load_state()
    new = idx + offset
    q = state["queue"]
    if idx < 0 or idx >= len(q) or new < 0 or new >= len(q):
        return
    item = q.pop(idx)
    q.insert(new, item)
    if state["current_index"] == idx:
        state["current_index"] = new
    elif idx < state["current_index"] <= new:
        state["current_index"] -= 1
    elif new <= state["current_index"] < idx:
        state["current_index"] += 1
    save_state(state)


def cmd_shuffle():
    state = load_state()
    q = state["queue"]
    if len(q) <= 1:
        return
    current = state["current_index"]
    current_item = q[current] if 0 <= current < len(q) else None
    random.shuffle(q)
    if current_item:
        state["current_index"] = q.index(current_item)
    state["shuffle"] = True
    save_state(state)


def cmd_sort():
    state = load_state()
    q = state["queue"]
    if not q:
        return
    current_item = q[state["current_index"]] if 0 <= state["current_index"] < len(q) else None
    q.sort(key=lambda x: entry_title(x).lower())
    if current_item:
        state["current_index"] = q.index(current_item)
    save_state(state)


def _step(delta):
    state = load_state()
    q = state["queue"]
    if not q:
        return
    if state["current_index"] == -1:
        state["current_index"] = 0
    else:
        state["current_index"] += delta
    if state["current_index"] >= len(q):
        if state.get("loop_mode") == "playlist":
            state["current_index"] = 0
        else:
            state["current_index"] = len(q) - 1
    if state["current_index"] < 0:
        if state.get("loop_mode") == "playlist":
            state["current_index"] = len(q) - 1
        else:
            state["current_index"] = 0
    play_current(state)
    save_state(state)


def cmd_next():
    _step(1)


def cmd_prev():
    _step(-1)


def cmd_clear():
    state = load_state()
    state["queue"] = []
    state["current_index"] = -1
    state["active_source"] = None
    update_last_status(state)
    save_state(state)


def _resolve_playlist_path(name):
    if not name:
        return None
    PLAYLIST_DIR.mkdir(parents=True, exist_ok=True)
    raw = Path(os.path.expanduser(name))
    if raw.is_absolute() and raw.exists():
        return raw
    candidates = [
        PLAYLIST_DIR / name,
        PLAYLIST_DIR / f"{name}.rpl.json",
        PLAYLIST_DIR / f"{name}.m3u",
    ]
    if name.endswith(".m3u") or name.endswith(".rpl.json"):
        candidates.insert(0, PLAYLIST_DIR / name)
    for c in candidates:
        if c.exists():
            return c
    return candidates[1]  # default save target


def cmd_save(name):
    if not name:
        return
    path = _resolve_playlist_path(name)
    if not str(path).endswith(".rpl.json"):
        path = Path(str(path).replace(".m3u", ""))  # normalize extension flip
        if not str(path).endswith(".rpl.json"):
            path = Path(f"{path}.rpl.json")
    state = load_state()
    payload = {
        "version": 1,
        "saved_at": now_iso(),
        "current_index": state.get("current_index", -1),
        "loop_mode": state.get("loop_mode", "off"),
        "queue": state.get("queue", []),
    }
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as f:
        json.dump(payload, f, indent=2, ensure_ascii=False)


def _load_m3u(path):
    out = []
    with path.open("r", encoding="utf-8", errors="replace") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            ap = os.path.abspath(os.path.expanduser(line))
            out.append(
                {
                    "id": str(uuid.uuid4()),
                    "source": "local",
                    "title": Path(ap).stem,
                    "artist": "",
                    "album": "",
                    "local_path": ap,
                    "spotify_uri": "",
                    "duration_sec": None,
                    "added_at": now_iso(),
                }
            )
    return out


def cmd_load(name):
    path = _resolve_playlist_path(name)
    if not path or not path.exists():
        print(f"Error: Playlist not found for '{name}'")
        return
    state = load_state()
    if str(path).endswith(".m3u"):
        state["queue"] = _load_m3u(path)
        state["current_index"] = 0 if state["queue"] else -1
        state["loop_mode"] = "off"
    else:
        with path.open("r", encoding="utf-8") as f:
            data = json.load(f)
        state["queue"] = data.get("queue", [])
        state["current_index"] = data.get("current_index", 0 if state["queue"] else -1)
        state["loop_mode"] = data.get("loop_mode", "off")
    ensure_index(state)
    if state["current_index"] >= 0:
        play_current(state)
    else:
        update_last_status(state)
    save_state(state)


def cmd_loop():
    state = load_state()
    loop = state.get("loop_mode", "off")
    if loop == "off":
        state["loop_mode"] = "single"
    elif loop == "single":
        state["loop_mode"] = "playlist"
    else:
        state["loop_mode"] = "off"
    state["last_status"]["loop"] = state["loop_mode"]
    save_state(state)


def fmt_time(t):
    if t is None:
        return "00:00"
    try:
        x = int(t)
        return f"{x // 60:02d}:{x % 60:02d}"
    except Exception:
        return "00:00"


def cmd_status():
    state = load_state()
    refresh_live_status(state)
    save_state(state)
    st = state.get("last_status", {})
    if not st.get("running"):
        print(f"  {DIM}{REST_ICON} Idle{NC}")
        return
    title = st.get("title", "Unknown")
    artist = st.get("artist", "")
    source = st.get("source")
    paused = st.get("paused", True)
    pos = st.get("position", 0)
    dur = st.get("duration", 0)
    percent = (pos / dur) * 100 if dur else 0
    current_ideal = IDEALS[int(min(percent // 20, 4))]
    state_icon = "󰏤 Paused" if paused else " Playing"
    state_color = YELLOW if paused else GREEN
    loop_mode = state.get("loop_mode", "off")
    loop_label = f"{GRAY}󰑗 Off{NC}"
    if loop_mode == "single":
        loop_label = f"{YELLOW}󰑘¹ Single{NC}"
    elif loop_mode == "playlist":
        loop_label = f"{MAGENTA}󰑖∞ All{NC}"
    width = 30
    progress = int((percent * width) / 100) if dur else 0
    bar = f"{CYAN}{'━' * progress}{GRAY}{'─' * (width - progress)}{NC}"
    src_icon = source_icon(source) if source else REST_ICON
    pretty = f"{src_icon} {title}"
    if artist:
        pretty += f" — {artist}"
    print(f"    {state_color}{BOLD}{state_icon}{NC}  {GRAY}│{NC}  {BOLD}{pretty}{NC}")
    print(f"    {bar}  {DIM}{fmt_time(pos)}/{fmt_time(dur)}{NC}  {loop_label}")
    print(f"\n    {BOLD}{CYAN}󱐋 {current_ideal}{NC}")


def cmd_short_status():
    state = load_state()
    refresh_live_status(state)
    save_state(state)
    st = state.get("last_status", {})
    if not st.get("running"):
        return
    paused = st.get("paused", True)
    state_icon = "󰋋" if paused else "󰟎"
    loop_mode = state.get("loop_mode", "off")
    loop_icon = "󰑗"
    if loop_mode == "single":
        loop_icon = "󰑘"
    elif loop_mode == "playlist":
        loop_icon = "󰑖"
    src = source_icon(st.get("source"))
    title = st.get("title", "Resting")
    artist = st.get("artist", "")
    if artist:
        title = f"{title} — {artist}"
    if len(title) > 28:
        title = title[:25] + "..."
    print(f"[{state_icon}] {loop_icon} {src} {title}")


def cmd_status_json():
    state = load_state()
    refresh_live_status(state)
    save_state(state)
    st = state.get("last_status", {})
    if not st.get("running"):
        print(json.dumps({"running": False}))
        return
    data = {
        "running": True,
        "title": st.get("title", "Resting"),
        "artist": st.get("artist", ""),
        "paused": st.get("paused", True),
        "loop": state.get("loop_mode", "off"),
        "source": st.get("source"),
        "position": st.get("position", 0),
        "duration": st.get("duration", 0),
    }
    print(json.dumps(data))


def cmd_toggle():
    state = load_state()
    idx = state.get("current_index", -1)
    q = state.get("queue", [])
    if idx < 0 or idx >= len(q):
        return
    item = q[idx]
    source = item.get("source", "local")
    if source == "local":
        ensure_mpv()
        mpv_send(["cycle", "pause"])
    else:
        spotify_toggle()
    refresh_live_status(state)
    save_state(state)


def cmd_seek(delta):
    state = load_state()
    if state.get("active_source") == "local":
        mpv_send(["seek", int(delta), "relative"])
    elif state.get("active_source") == "spotify":
        # Some spotify_player versions support this syntax.
        spotify_cmd(["playback", "seek", str(delta)])
    refresh_live_status(state)
    save_state(state)


def cmd_volume(delta):
    state = load_state()
    if state.get("active_source") == "local":
        mpv_send(["add", "volume", int(delta)])
    else:
        # spotify_player volume verbs can vary by version; keep best-effort.
        spotify_cmd(["playback", "volume", "offset", str(delta)])


def cmd_get_volume():
    state = load_state()
    if state.get("active_source") == "local":
        res = mpv_send(["get_property", "volume"])
        if res and res.get("data") is not None:
            print(int(res["data"]))


def cmd_current_index():
    state = load_state()
    ensure_index(state)
    print(state.get("current_index", -1))


def cmd_spotify_health():
    spotify_health()


def main():
    if len(sys.argv) < 2:
        return
    cmd = sys.argv[1]
    fd = with_lock()
    try:
        if cmd == "play":
            cmd_play(sys.argv[2:])
            signal_refresh()
        elif cmd == "add_spotify":
            cmd_add_spotify(sys.argv[2] if len(sys.argv) > 2 else "")
            signal_refresh()
        elif cmd == "add_spotify_search":
            # placeholder command surface (phase-2); treat input as URI if provided
            cmd_add_spotify(sys.argv[2] if len(sys.argv) > 2 else "")
            signal_refresh()
        elif cmd == "resolve_spotify_meta":
            cmd_resolve_spotify_meta(sys.argv[2] if len(sys.argv) > 2 else "")
        elif cmd == "list":
            cmd_list()
        elif cmd == "play_index":
            cmd_play_index(int(sys.argv[2]))
            signal_refresh()
        elif cmd == "remove":
            cmd_remove(int(sys.argv[2]))
            signal_refresh()
        elif cmd == "move":
            cmd_move(int(sys.argv[2]), int(sys.argv[3]))
            signal_refresh()
        elif cmd == "shuffle":
            cmd_shuffle()
            signal_refresh()
        elif cmd == "sort":
            cmd_sort()
            signal_refresh()
        elif cmd == "next":
            cmd_next()
            signal_refresh()
        elif cmd == "prev":
            cmd_prev()
            signal_refresh()
        elif cmd == "loop":
            cmd_loop()
            signal_refresh()
        elif cmd == "clear":
            cmd_clear()
            signal_refresh()
        elif cmd == "save":
            cmd_save(sys.argv[2] if len(sys.argv) > 2 else "")
        elif cmd == "load":
            cmd_load(sys.argv[2] if len(sys.argv) > 2 else "")
            signal_refresh()
        elif cmd == "status":
            cmd_status()
        elif cmd == "short_status":
            cmd_short_status()
        elif cmd == "status_json":
            cmd_status_json()
        elif cmd == "toggle":
            cmd_toggle()
            signal_refresh()
        elif cmd == "seek":
            cmd_seek(int(sys.argv[2]))
            signal_refresh()
        elif cmd == "volume":
            cmd_volume(int(sys.argv[2]))
        elif cmd == "get_volume":
            cmd_get_volume()
        elif cmd == "current_index":
            cmd_current_index()
        elif cmd == "spotify_health":
            cmd_spotify_health()
    finally:
        unlock(fd)


if __name__ == "__main__":
    main()
