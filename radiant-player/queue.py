#!/usr/bin/env python3
import json
import os
import random
import re
import shutil
import socket
import subprocess
import sys
import tempfile
import time
import uuid
import fcntl
import copy
import concurrent.futures
from datetime import datetime, timezone
from pathlib import Path
from urllib import error as urlerror
from urllib import request as urlrequest

# ── Platform detection ──────────────────────────────────────────────────────
IS_MACOS = sys.platform == "darwin"

# ── Configuration ──────────────────────────────────────────────────────────
SOCKET_PATH = "/tmp/mpv-yazi.sock"          # mpv IPC socket (fallback)
VLC_SOCKET_PATH = "/tmp/vlc-radiant.sock"   # VLC RC socket (primary)
STATE_PATH = Path(os.path.expanduser("~/.config/radiant-player/queue_state.json"))
PLAYLIST_DIR = Path(os.path.expanduser("~/.config/mpv/playlists"))
LOCK_PATH = Path("/tmp/radiant-player.lock")
SPOTIFY_STATUS_CACHE_PATH = Path("/tmp/radiant-spotify-status.json")
MUSIC_TICK_PATH = Path("/tmp/radiant-music-update.tick")
STATUS_SNAPSHOT_PATH = Path("/tmp/radiant-now-playing.json")
DEBUG_LOG_PATH = Path("/tmp/radiant-player.log")
ART_CACHE_SIG_PATH = Path("/tmp/radiant-art-cache.sig")
ART_CACHE_RENDER_PATH = Path("/tmp/radiant-art-cache.ansi")

# ── ANSI colors — mirrors cosmere_colors.sh T_* palette ───────────────────
NC        = "\033[0m"
BOLD      = "\033[1m"
DIM       = "\033[2m"
# Windrunner / Stormlight
CYAN      = "\033[38;5;74m"   # T_PRES_GLACIAL  — Glacial teal
BLUE      = "\033[38;5;39m"   # T_SPREN_HONOR   — Honorspren sky blue
GREEN     = "\033[38;5;71m"   # T_SPREN_CULTIVATION — Cultivationspren green
YELLOW    = "\033[38;5;220m"  # T_SPREN_GLORY   — Gloryspren gold
MAGENTA   = "\033[38;5;177m"  # T_SPREN_WILL    — Willshaper amethyst
RED       = "\033[38;5;88m"   # T_RUIN_MAROON   — Ruin's bloodline
GRAY      = "\033[38;5;66m"   # T_SPREN_STORM   — Stormfather slate
# Gemstone roles
RUBY      = "\033[38;5;202m"  # T_SPREN_ASH     — Ashspren volcanic (urgent/infused)
EMERALD_G = "\033[38;5;71m"   # T_SPREN_CULTIVATION
SAPPHIRE_G= "\033[38;5;39m"   # T_SAPPHIRE      — Windrunner
AMETHYST_G= "\033[38;5;177m"  # T_SPREN_WILL
DIAMOND_G = "\033[38;5;152m"  # T_PRES_SILVER   — Frosted silver
HELIODOR_G= "\033[38;5;222m"  # T_PRES_ATIUM    — Atium pale gold
DUN       = "\033[38;5;236m"  # T_RUIN_ASH      — Ashmount shadow (drained)
AMBER     = "\033[38;5;215m"  # T_AMBER         — Lightweaver amber (VLC accent)
SIBLING   = "\033[38;5;214m"  # T_SPREN_SIBLING — Crystal amber (VLC backend label)
LAVENDER  = "\033[38;5;183m"  # T_PRES_LAVENDER — Pale lavender
CRIMSON   = "\033[38;5;204m"  # T_CRIMSON       — Odium crimson

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
    "source_lock": "auto",  # auto | local | spotify
    "last_status": {
        "running": False,
        "paused": True,
        "title": "Resting",
        "artist": "",
        "source": None,
        "track_id": "",
        "loop": "off",
        "position": 0,
        "duration": 0,
    },
}


def now_iso():
    return datetime.now(timezone.utc).isoformat()


def debug_log(message):
    if os.getenv("RADIANT_DEBUG", "").lower() not in {"1", "true", "yes", "on"}:
        return
    try:
        DEBUG_LOG_PATH.parent.mkdir(parents=True, exist_ok=True)
        with DEBUG_LOG_PATH.open("a", encoding="utf-8") as f:
            f.write(f"{datetime.now().isoformat()} {message}\n")
    except Exception:
        pass


BIN_CACHE_PATH = Path("/tmp/radiant-bin-cache.json")

def resolve_bin(name):
    """Resolve a binary name to its full path, with caching.
    On macOS checks Homebrew paths first; on Linux skips them."""
    if BIN_CACHE_PATH.exists():
        try:
            with BIN_CACHE_PATH.open("r") as f:
                cache = json.load(f)
                if name in cache and os.path.exists(cache[name]):
                    return cache[name]
        except Exception:
            pass

    # Build candidate list — Homebrew paths only on macOS
    candidates = []
    if IS_MACOS:
        candidates += [f"/opt/homebrew/bin/{name}", f"/opt/homebrew/opt/{name}/bin/{name}"]
    candidates += [f"/usr/local/bin/{name}", f"/usr/bin/{name}", name]

    resolved = name
    for candidate in candidates:
        if os.path.isabs(candidate):
            if os.path.exists(candidate):
                resolved = candidate
                break
        else:
            result = shutil.which(candidate)
            if result:
                resolved = result
                break
            if subprocess.run(
                ["bash", "-lc", f"command -v {candidate} >/dev/null 2>&1"], check=False
            ).returncode == 0:
                p = subprocess.run(["bash", "-lc", f"command -v {candidate}"], capture_output=True, text=True).stdout.strip()
                if p:
                    resolved = p
                    break

    try:
        cache = {}
        if BIN_CACHE_PATH.exists():
            with BIN_CACHE_PATH.open("r") as f:
                cache = json.load(f)
        cache[name] = resolved
        with BIN_CACHE_PATH.open("w") as f:
            json.dump(cache, f)
    except Exception:
        pass

    return resolved


MPV_BIN = resolve_bin("mpv")
SPOTIFY_PLAYER_BIN = resolve_bin("spotify_player")
LIBRESPOT_BIN = resolve_bin("librespot")
SPOTIFY_STATUS_CACHE = {"ts": 0.0, "data": None}
LOCK_WAIT_TIMEOUT_SEC = 2.0

# ── VLC binary resolution ───────────────────────────────────────────────────
# macOS: VLC.app ships its own binary; Homebrew installs a wrapper at /opt/homebrew/bin/vlc
# Linux: cvlc (headless wrapper) preferred, plain vlc as fallback
def _resolve_vlc_bin():
    candidates = []
    if IS_MACOS:
        candidates += [
            "/opt/homebrew/bin/vlc",
            "/usr/local/bin/vlc",
            "/Applications/VLC.app/Contents/MacOS/VLC",
        ]
    else:
        candidates += ["cvlc", "vlc"]
    for c in candidates:
        if os.path.isabs(c):
            if os.path.exists(c):
                return c
        else:
            found = shutil.which(c)
            if found:
                return found
    return None

VLC_BIN = _resolve_vlc_bin()

# Active local player backend: "vlc" if VLC is found, else "mpv"
PLAYER_BACKEND = "vlc" if VLC_BIN else "mpv"


def is_pid_running(pid):
    if pid <= 0:
        return False
    try:
        os.kill(pid, 0)
        return True
    except (ProcessLookupError, OSError):
        return False


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
        return copy.deepcopy(DEFAULT_STATE)
    try:
        with STATE_PATH.open("r", encoding="utf-8") as f:
            raw = json.load(f)
        return _deep_merge(copy.deepcopy(DEFAULT_STATE), raw)
    except Exception:
        return copy.deepcopy(DEFAULT_STATE)


def save_state(state):
    state["player_backend"] = PLAYER_BACKEND
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


def is_mpv_active():
    """Checks if mpv is running and has a track loaded."""
    if not is_mpv_running():
        return False
    # Check if a track is loaded (media-title is a good proxy)
    res = mpv_send(["get_property", "media-title"])
    return bool(res and res.get("data"))


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


# ── VLC RC socket helpers ───────────────────────────────────────────────────
def is_vlc_running():
    """Check if VLC is accepting connections on the RC unix socket."""
    if not os.path.exists(VLC_SOCKET_PATH):
        return False
    try:
        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as s:
            s.settimeout(0.3)
            s.connect(VLC_SOCKET_PATH)
            return True
    except Exception:
        return False


def vlc_send(cmd_str):
    """Send a text command to VLC RC socket. Returns the response text or None."""
    try:
        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as s:
            s.settimeout(1.0)
            s.connect(VLC_SOCKET_PATH)
            s.sendall((cmd_str.strip() + "\n").encode())
            
            s.settimeout(0.5) # wait up to 0.5s for initial response
            data = b""
            try:
                chunk = s.recv(4096)
                data += chunk
                s.settimeout(0.05) # very short timeout for remaining bytes
                while True:
                    chunk = s.recv(4096)
                    if not chunk:
                        break
                    data += chunk
            except (socket.timeout, OSError):
                pass
            return data.decode("utf-8", "replace").strip()
    except Exception as e:
        debug_log(f"vlc_send({cmd_str!r}) error: {e}")
        return None


def vlc_query(cmd_str):
    """Send a VLC RC command and return the response."""
    raw = vlc_send(cmd_str)
    if not raw:
        return ""
    # VLC RC echoes the prompt '> ' — strip those lines
    lines = [l.strip() for l in raw.splitlines() if l.strip() and l.strip() != ">"]
    return "\n".join(lines)


def is_vlc_active():
    """Check if VLC is running AND has a track loaded."""
    if not is_vlc_running():
        return False
    title = vlc_query("get_title")
    return bool(title and title not in {"", ">", "( no input )"})


def ensure_vlc():
    """Start VLC headlessly with RC socket if not already running."""
    if not VLC_BIN:
        debug_log("VLC binary not found — cannot start VLC")
        return
    if is_vlc_running():
        return
    if os.path.exists(VLC_SOCKET_PATH):
        try:
            os.remove(VLC_SOCKET_PATH)
        except OSError:
            pass
    
    intf_name = "oldrc" if IS_MACOS else "rc"
    subprocess.Popen(
        [
            VLC_BIN,
            "-I", "dummy",
            "--extraintf", intf_name,
            "--no-video",
            "--no-osd",
            "--quiet",
            "--rc-unix", VLC_SOCKET_PATH,
            "--rc-fake-tty",
        ],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        stdin=subprocess.DEVNULL,
    )
    for _ in range(40):
        if is_vlc_running():
            return
        time.sleep(0.1)


def vlc_get_status():
    """Poll VLC RC for full playback state. Returns a dict matching mpv shape."""
    if not is_vlc_running():
        return {"running": False, "paused": True, "title": "", "position": 0, "duration": 0}
    try:
        raw_status = vlc_query("status")
        raw_title  = vlc_query("get_title")
        raw_time   = vlc_query("get_time")
        raw_length = vlc_query("get_length")

        # Parse state: VLC returns "( state playing )" / "( state paused )" / "( state stopped )"
        state_match = re.search(r"state (\w+)", raw_status or "")
        vlc_state = state_match.group(1) if state_match else "stopped"
        running = vlc_state in ("playing", "paused")
        paused  = vlc_state != "playing"

        # Clean title — VLC may return the full path for local files
        title = raw_title.strip() if raw_title else ""
        if title in (">", "( no input )", ""):
            title = ""
            running = False

        try:
            pos = int(raw_time)
        except (ValueError, TypeError):
            pos = 0
        try:
            dur = int(raw_length)
        except (ValueError, TypeError):
            dur = 0

        return {
            "running": running,
            "paused": paused,
            "title": title,
            "position": pos,
            "duration": dur,
        }
    except Exception as e:
        debug_log(f"vlc_get_status error: {e}")
        return {"running": False, "paused": True, "title": "", "position": 0, "duration": 0}


def vlc_load_file(path, resume_pos=0):
    """Load a local file in VLC and start playing, with optional resume."""
    ensure_vlc()
    # 'clear' empties the VLC playlist, 'add' queues the file, 'play' starts it
    vlc_send("clear")
    time.sleep(0.05)
    vlc_send(f"add {path}")
    time.sleep(0.2)  # allow VLC to register the item
    vlc_send("play")
    if resume_pos and resume_pos > 1:
        time.sleep(0.4)  # brief wait before seeking
        vlc_send(f"seek {int(resume_pos)}")


# ── Local player abstraction layer ─────────────────────────────────────────
# All calls that previously went directly to mpv now route through here.
# PLAYER_BACKEND == "vlc"  →  VLC RC socket
# PLAYER_BACKEND == "mpv"  →  mpv JSON IPC (unchanged behaviour)

def is_local_running():
    return is_vlc_running() if PLAYER_BACKEND == "vlc" else is_mpv_running()


def is_local_active():
    return is_vlc_active() if PLAYER_BACKEND == "vlc" else is_mpv_active()


def local_pause():
    """Pause the local player (does not stop it)."""
    if PLAYER_BACKEND == "vlc":
        st = vlc_get_status()
        if st["running"] and not st["paused"]:
            vlc_send("pause")
    else:
        mpv_send(["set_property", "pause", True])


def local_toggle():
    """Toggle play/pause on the local player."""
    if PLAYER_BACKEND == "vlc":
        st = vlc_get_status()
        if st["paused"]:
            vlc_send("play")
        else:
            vlc_send("pause")
    else:
        ensure_mpv()
        mpv_send(["cycle", "pause"])


def local_seek(delta):
    """Seek by `delta` seconds (relative). VLC requires absolute position."""
    if PLAYER_BACKEND == "vlc":
        st = vlc_get_status()
        new_pos = max(0, st["position"] + int(delta))
        vlc_send(f"seek {new_pos}")
    else:
        mpv_send(["seek", int(delta), "relative"])


def local_volume(delta):
    """Adjust volume by `delta` percent-points.
    VLC scale: 0-512 where 256=100%. mpv scale: 0-130 where 100=100%.
    We treat delta as percent-points (e.g. +5 = louder by 5%).
    """
    if PLAYER_BACKEND == "vlc":
        # Read current volume, convert delta to VLC units (256/100 ≈ 2.56 per %)
        raw_status = vlc_query("status")
        vol_match = re.search(r"audio volume:\s*(\d+)", raw_status or "")
        current_vlc_vol = int(vol_match.group(1)) if vol_match else 256
        
        new_vlc_vol = max(0, min(512, current_vlc_vol + int(delta * 2.56)))
        vlc_send(f"volume {new_vlc_vol}")
    else:
        mpv_send(["add", "volume", int(delta)])


def local_get_volume():
    """Return current volume as a 0-100 percent integer."""
    if PLAYER_BACKEND == "vlc":
        raw_status = vlc_query("status")
        vol_match = re.search(r"audio volume:\s*(\d+)", raw_status or "")
        try:
            vlc_vol = int(vol_match.group(1)) if vol_match else 256
            return int(vlc_vol * 100 / 256)
        except (ValueError, TypeError):
            return None
    else:
        res = mpv_send(["get_property", "volume"])
        if res and res.get("data") is not None:
            return int(res["data"])
        return None


def local_get_status():
    """Get current status from the local player as a normalised dict."""
    if PLAYER_BACKEND == "vlc":
        return vlc_get_status()
    # mpv path
    if not is_mpv_running():
        return {"running": False, "paused": True, "title": "", "position": 0, "duration": 0}
    title  = mpv_send(["get_property", "media-title"])
    paused = mpv_send(["get_property", "pause"])
    pos    = mpv_send(["get_property", "time-pos"])
    dur    = mpv_send(["get_property", "duration"])
    return {
        "running": True,
        "paused":   (paused or {}).get("data", True),
        "title":    (title  or {}).get("data", ""),
        "position": (pos    or {}).get("data", 0),
        "duration": (dur    or {}).get("data", 0),
    }


def ensure_local_player():
    """Start whichever local player is the active backend."""
    if PLAYER_BACKEND == "vlc":
        ensure_vlc()
    else:
        ensure_mpv()


def shell_ok(cmd):
    return subprocess.run(["bash", "-lc", cmd], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode == 0


def spotify_cmd(args):
    if not shell_ok(f"command -v {SPOTIFY_PLAYER_BIN} >/dev/null 2>&1"):
        return False, "spotify_player missing"
    
    try:
        p = subprocess.run(
            [SPOTIFY_PLAYER_BIN, *args],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            check=False,
            timeout=1.5,
        )
        if p.returncode == 0:
            return True, (p.stdout or "").strip()
        return False, (p.stderr or "unknown error").strip()
    except Exception as e:
        debug_log(f"spotify_cmd exception: {e}")
        return False, str(e)


def system_media_fallback(cmd):
    """
    Fallback to system-level media controls when spotify_player is unresponsive.
    macOS: tries nowplaying-cli then AppleScript.
    Linux: tries playerctl.
    """
    if IS_MACOS:
        np_bin = "/opt/homebrew/bin/nowplaying-cli"
        np_map = {
            "toggle": "togglePlayPause",
            "play": "play",
            "pause": "pause",
            "next": "next",
            "prev": "previous",
            "previous": "previous",
        }
        if os.path.exists(np_bin):
            action = np_map.get(cmd)
            if action:
                try:
                    subprocess.run([np_bin, action], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=2)
                    return True
                except Exception:
                    pass

        # AppleScript fallback for Spotify Desktop
        scripts = {
            "toggle": "playpause",
            "play": "play",
            "pause": "pause",
            "next": "next track",
            "prev": "previous track",
            "previous": "previous track",
        }
        script_action = scripts.get(cmd)
        if script_action:
            try:
                if subprocess.run(["pgrep", "-ix", "spotify"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode == 0:
                    subprocess.run(
                        ["osascript", "-e", f'tell application "Spotify" to {script_action}'],
                        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=2,
                    )
                    return True
            except Exception:
                pass
        return False

    # Linux: try playerctl (MPRIS)
    playerctl = shutil.which("playerctl")
    if not playerctl:
        return False
    playerctl_map = {
        "toggle": "play-pause",
        "play": "play",
        "pause": "pause",
        "next": "next",
        "prev": "previous",
        "previous": "previous",
    }
    action = playerctl_map.get(cmd)
    if action:
        try:
            subprocess.run(
                [playerctl, "-p", "spotify,Spotify", action],
                stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=2,
            )
            return True
        except Exception:
            pass
    return False


def spotify_pause():
    ok, _ = spotify_cmd(["playback", "pause"])
    if not ok:
        system_media_fallback("pause")


def spotify_toggle():
    ok, _ = spotify_cmd(["playback", "toggle"])
    if ok:
        return True
    
    # try legacy verbs
    for args in (["playback", "play-pause"], ["playback", "playpause"]):
        ok, _ = spotify_cmd(args)
        if ok:
            return True
    
    # system fallback
    return system_media_fallback("toggle")


def spotify_next():
    ok, _ = spotify_cmd(["playback", "next"])
    if not ok:
        return system_media_fallback("next")
    return ok


def spotify_prev():
    ok, _ = spotify_cmd(["playback", "previous"])
    if not ok:
        ok, _ = spotify_cmd(["playback", "prev"])
    if not ok:
        return system_media_fallback("prev")
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


def apple_script_spotify_control(cmd):
    """Fallback Spotify control via AppleScript (macOS only).
    On Linux this is a no-op — spotify_player CLI handles everything there.
    """
    if not IS_MACOS:
        return False
    script_map = {
        "toggle": 'tell application "Spotify" to playpause',
        "next":   'tell application "Spotify" to next track',
        "prev":   'tell application "Spotify" to previous track',
        "play":   'tell application "Spotify" to play',
        "pause":  'tell application "Spotify" to pause',
    }
    script = script_map.get(cmd)
    if not script:
        return False
    try:
        if subprocess.run(["pgrep", "-ix", "spotify"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode == 0:
            subprocess.run(["osascript", "-e", script], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False)
            return True
        return False
    except Exception:
        return False


def apple_script_spotify_status():
    """Poll the Spotify Desktop app for playback state (macOS only).
    On Linux returns None — caller falls back to spotify_player CLI.
    """
    if not IS_MACOS:
        return None
    try:
        if subprocess.run(["pgrep", "-ix", "spotify"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode != 0:
            return None

        # Ask Spotify for its current state
        script = 'tell application "Spotify" to get {player state, name of current track, artist of current track, player position, duration of current track, id of current track}'
        res = subprocess.run(["osascript", "-e", script], capture_output=True, text=True, timeout=1.5)
        if res.returncode != 0:
            return None
            
        # osascript returns: playing, Track Name, Artist Name, 12.345, 240000, spotify:track:XYZ
        raw = res.stdout.strip()
        parts = [p.strip() for p in raw.split(",")]
        if len(parts) < 6:
            return None
        return {
            "running":  True,
            "paused":   parts[0] != "playing",
            "title":    parts[1],
            "artist":   parts[2],
            "position": float(parts[3]),
            "duration": float(parts[4]) / 1000.0,  # ms → s
            "track_id": parts[5].split(":")[-1] if ":" in parts[5] else parts[5],
        }
    except Exception:
        return None


def spotify_api_get(path, params=None):
    token = spotify_cached_access_token()
    if not token:
        return None
    req = urlrequest.Request(
        f"https://api.spotify.com{path}",
        headers={"Authorization": f"Bearer {token}"},
    )
    try:
        with urlrequest.urlopen(req, timeout=6) as resp:
            return json.loads(resp.read().decode("utf-8", "replace"))
    except (urlerror.URLError, json.JSONDecodeError, TimeoutError):
        return None


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
    payload = spotify_api_get(f"/v1/tracks/{sid}")
    if not payload:
        return {}
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


def spotify_playlist_tracks(uri, max_items=1000):
    sid = spotify_id_from_uri(uri)
    if not sid:
        return []
    out = []
    path = f"/v1/playlists/{sid}/tracks?limit=100&offset=0"
    while path and len(out) < max_items:
        payload = spotify_api_get(path.replace("https://api.spotify.com", ""))
        if not payload:
            break
        for row in payload.get("items", []):
            track = row.get("track") or {}
            track_id = track.get("id")
            if not track_id:
                continue
            artists = track.get("artists") or []
            artist = ", ".join(a.get("name", "") for a in artists if isinstance(a, dict)).strip(", ")
            duration_sec = int((track.get("duration_ms") or 0) / 1000) if track.get("duration_ms") else None
            out.append(
                {
                    "id": str(uuid.uuid4()),
                    "source": "spotify",
                    "title": track.get("name") or track_id,
                    "artist": artist,
                    "album": (track.get("album") or {}).get("name", ""),
                    "local_path": "",
                    "spotify_uri": f"spotify:track:{track_id}",
                    "spotify_id": track_id,
                    "duration_sec": duration_sec,
                    "added_at": now_iso(),
                }
            )
            if len(out) >= max_items:
                print(f"Warning: Playlist truncated at {max_items} tracks.", file=sys.stderr)
                break
        path = payload.get("next")
    return out


def spotify_playlist_track_choices(uri, max_items=300):
    """Return lightweight track rows for interactive selection UIs."""
    rows = spotify_playlist_tracks(uri, max_items=max_items)
    out = []
    for row in rows:
        out.append(
            {
                "spotify_id": row.get("spotify_id", ""),
                "title": row.get("title", ""),
                "artist": row.get("artist", ""),
                "album": row.get("album", ""),
                "duration_sec": row.get("duration_sec"),
            }
        )
    return out


def spotify_track_image_url(track_id):
    payload = spotify_api_get(f"/v1/tracks/{track_id}")
    if not payload:
        return "", "", ""
    title = payload.get("name", "")
    artists = payload.get("artists") or []
    artist = ", ".join(a.get("name", "") for a in artists if isinstance(a, dict)).strip(", ")
    images = (payload.get("album") or {}).get("images") or []
    image_url = images[1].get("url") if len(images) > 1 else (images[0].get("url") if images else "")
    return image_url, title, artist


def cmd_spotify_art(track_id):
    tid = (track_id or "").strip()
    if not tid:
        return
    image_url, title, artist = spotify_track_image_url(tid)
    if title:
        print(f"{title}")
        if artist:
            print(f"{artist}")
        print("")
    if not image_url:
        print("No album art found.")
        return
    try:
        with urlrequest.urlopen(image_url, timeout=6) as resp:
            image_data = resp.read()
    except Exception:
        print("Unable to fetch album art.")
        return
    tmp_path = None
    try:
        with tempfile.NamedTemporaryFile(delete=False, suffix=".jpg") as tmp:
            tmp.write(image_data)
            tmp_path = tmp.name
        cmd = ["chafa", "--size", "36x18", "--animate", "off", tmp_path]
        p = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True, check=False)
        if p.stdout:
            print(p.stdout.rstrip())
    finally:
        try:
            if tmp_path:
                os.remove(tmp_path)
        except Exception:
            pass


def cmd_local_art(path):
    ap = os.path.abspath(os.path.expanduser((path or "").strip()))
    if not ap or not os.path.exists(ap):
        print("Local track not found.")
        return
    if not shell_ok("command -v chafa >/dev/null 2>&1"):
        print("chafa is not installed.")
        return
    if not shell_ok("command -v ffmpeg >/dev/null 2>&1"):
        print("ffmpeg is not installed.")
        return
    print(Path(ap).stem)
    print("")
    tmp_path = None
    try:
        with tempfile.NamedTemporaryFile(delete=False, suffix=".jpg") as tmp:
            tmp_path = tmp.name
        p = subprocess.run(
            ["ffmpeg", "-hide_banner", "-loglevel", "error", "-y", "-i", ap, "-an", "-vframes", "1", tmp_path],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            check=False,
            timeout=8,
        )
        if p.returncode != 0 or not os.path.exists(tmp_path) or os.path.getsize(tmp_path) == 0:
            print("No embedded cover art found for this local track.")
            return
        out = subprocess.run(
            ["chafa", "--size", "36x18", "--animate", "off", tmp_path],
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            text=True,
            check=False,
        )
        if out.stdout:
            print(out.stdout.rstrip())
    except subprocess.TimeoutExpired:
        print("Album art extraction timed out.")
    finally:
        try:
            if tmp_path:
                os.remove(tmp_path)
        except Exception:
            pass


def extract_local_metadata(path):
    """Use ffprobe to extract rich metadata from local files."""
    try:
        # Resolve path
        ap = os.path.abspath(os.path.expanduser(path))
        if not os.path.exists(ap):
            return {"title": Path(path).stem}
        
        cmd = ["ffprobe", "-v", "quiet", "-print_format", "json", "-show_format", ap]
        res = subprocess.run(cmd, capture_output=True, text=True, check=False, timeout=2.0)
        if res.returncode != 0:
            return {"title": Path(ap).stem}
            
        data = json.loads(res.stdout)
        fmt = data.get("format", {})
        tags = fmt.get("tags", {})
        
        # Try to find title/artist with case-insensitive keys if standard fails
        title = tags.get("title") or tags.get("TITLE") or Path(ap).stem
        artist = tags.get("artist") or tags.get("ARTIST") or tags.get("album_artist") or ""
        album = tags.get("album") or tags.get("ALBUM") or ""
        duration = float(fmt.get("duration") or 0)
        
        return {
            "title": title,
            "artist": artist,
            "album": album,
            "duration_sec": duration if duration > 0 else None
        }
    except Exception:
        return {"title": Path(path).stem}


def render_image_with_chafa(image_path):
    p = subprocess.run(
        ["chafa", "--size", "36x18", "--animate", "off", image_path],
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
        check=False,
    )
    return (p.stdout or "").rstrip()


def render_spotify_art_text(track_id):
    tid = (track_id or "").strip()
    if not tid:
        return ""
    image_url, _, _ = spotify_track_image_url(tid)
    if not image_url:
        return ""
    try:
        with urlrequest.urlopen(image_url, timeout=6) as resp:
            image_data = resp.read()
    except Exception:
        return ""
    tmp_path = None
    try:
        with tempfile.NamedTemporaryFile(delete=False, suffix=".jpg") as tmp:
            tmp.write(image_data)
            tmp_path = tmp.name
        return render_image_with_chafa(tmp_path)
    finally:
        try:
            if tmp_path:
                os.remove(tmp_path)
        except Exception:
            pass


def render_local_art_text(path):
    ap = os.path.abspath(os.path.expanduser((path or "").strip()))
    if not ap or not os.path.exists(ap):
        return ""
    if not shell_ok("command -v ffmpeg >/dev/null 2>&1"):
        return ""
    tmp_path = None
    try:
        with tempfile.NamedTemporaryFile(delete=False, suffix=".jpg") as tmp:
            tmp_path = tmp.name
        p = subprocess.run(
            ["ffmpeg", "-hide_banner", "-loglevel", "error", "-y", "-i", ap, "-an", "-vframes", "1", tmp_path],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            check=False,
            timeout=8,
        )
        if p.returncode != 0 or not os.path.exists(tmp_path) or os.path.getsize(tmp_path) == 0:
            return ""
        return render_image_with_chafa(tmp_path)
    except subprocess.TimeoutExpired:
        return ""
    finally:
        try:
            if tmp_path:
                os.remove(tmp_path)
        except Exception:
            pass


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

    # macOS: AppleScript fallback for Spotify Desktop
    if IS_MACOS:
        debug_log(f"Falling back to AppleScript for play: {uri}")
    # For playlists/albums, Spotify AppleScript prefers 'play track "uri"' to start the context
        script = f'tell application "Spotify" to play track "{uri}"'
        try:
            subprocess.run(["osascript", "-e", script], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False)
        # Give it a moment to register the change
            time.sleep(0.5)
        # Force a status update so the UI syncs immediately
            apple_script_spotify_status()
            return True, uri
        except Exception:
            pass
    return False, uri


def spotify_status(max_age_sec=0.0):
    """
    Best-effort adapter for multiple spotify_player versions.
    """
    now = time.time()
    if max_age_sec > 0 and SPOTIFY_STATUS_CACHE_PATH.exists():
        try:
            with SPOTIFY_STATUS_CACHE_PATH.open("r", encoding="utf-8") as f:
                payload = json.load(f)
            ts = float(payload.get("ts", 0))
            data = payload.get("data")
            if data and (now - ts) < max_age_sec:
                return dict(data)
        except Exception:
            pass

    if max_age_sec > 0 and SPOTIFY_STATUS_CACHE["data"] and (now - SPOTIFY_STATUS_CACHE["ts"]) < max_age_sec:
        return dict(SPOTIFY_STATUS_CACHE["data"])

    paused = False
    title = None
    artist = ""
    position = 0
    duration = 0
    track_id = ""
    running = shell_ok(f"command -v {SPOTIFY_PLAYER_BIN} >/dev/null 2>&1")
    if not running:
        data = {"running": False, "paused": True, "title": None, "artist": "", "position": 0, "duration": 0, "track_id": ""}
        SPOTIFY_STATUS_CACHE["ts"] = now
        SPOTIFY_STATUS_CACHE["data"] = dict(data)
        try:
            with SPOTIFY_STATUS_CACHE_PATH.open("w", encoding="utf-8") as f:
                json.dump({"ts": now, "data": data}, f)
        except Exception:
            pass
        return data

    # try JSON first (spotify_player v0.20+ CLI shape)
    ok, out = spotify_cmd(["get", "key", "playback"])
    if not ok:
        # Connection wonky? Fallback to cache immediately to avoid "pausing" or 0/0 state.
        if SPOTIFY_STATUS_CACHE["data"]:
            return dict(SPOTIFY_STATUS_CACHE["data"])
    
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
            item_obj = data.get("item", {}) if isinstance(data.get("item"), dict) else {}
            track_id = item_obj.get("id") or spotify_id_from_uri(item_obj.get("uri", ""))
            data = {
                "running": True,
                "paused": paused,
                "title": title,
                "artist": artist,
                "position": position,
                "duration": duration,
                "track_id": track_id or "",
            }
            SPOTIFY_STATUS_CACHE["ts"] = now
            SPOTIFY_STATUS_CACHE["data"] = dict(data)
            try:
                with SPOTIFY_STATUS_CACHE_PATH.open("w", encoding="utf-8") as f:
                    json.dump({"ts": now, "data": data}, f)
            except Exception:
                pass
            return data
        except Exception:
            pass

    # plain fallback
    ok, out = spotify_cmd(["status"])
    if not ok:
        if SPOTIFY_STATUS_CACHE["data"]:
            return dict(SPOTIFY_STATUS_CACHE["data"])

    if ok and out:
        body = out.lower()
        paused = "paused" in body and "playing" not in body
        lines = [x.strip() for x in out.splitlines() if x.strip()]
        if lines:
            title = lines[0]
            if " - " in title:
                parts = title.split(" - ", 1)
                title, artist = parts[0].strip(), parts[1].strip()
    data = {"running": True, "paused": paused, "title": title, "artist": artist, "position": position, "duration": duration, "track_id": track_id}
    SPOTIFY_STATUS_CACHE["ts"] = now
    SPOTIFY_STATUS_CACHE["data"] = dict(data)
    try:
        with SPOTIFY_STATUS_CACHE_PATH.open("w", encoding="utf-8") as f:
            json.dump({"ts": now, "data": data}, f)
    except Exception:
        pass
    return data


def spotify_health():
    data = {
        "spotify_player": shell_ok(f"command -v {SPOTIFY_PLAYER_BIN} >/dev/null 2>&1"),
        "librespot": shell_ok(f"command -v {LIBRESPOT_BIN} >/dev/null 2>&1"),
    }
    print(json.dumps(data))


def nowplaying_spotify_snapshot():
    """Poll the system Now Playing API for Spotify status.
    macOS: uses nowplaying-cli (Homebrew).
    Linux: uses playerctl if available.
    """
    if IS_MACOS:
        nowplaying_bin = "/opt/homebrew/bin/nowplaying-cli"
        if not os.path.exists(nowplaying_bin):
            return None
        try:
        # Task 5: Run nowplaying-cli calls concurrently
            with concurrent.futures.ThreadPoolExecutor(max_workers=4) as executor:
                f_client = executor.submit(subprocess.run, [nowplaying_bin, "get", "clientIdentifier"],
                                          stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True, timeout=1.5, check=False)
                f_title  = executor.submit(subprocess.run, [nowplaying_bin, "get", "title"],
                                          stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True, timeout=1.5, check=False)
                f_artist = executor.submit(subprocess.run, [nowplaying_bin, "get", "artist"],
                                          stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True, timeout=1.5, check=False)
                f_rate   = executor.submit(subprocess.run, [nowplaying_bin, "get", "playbackRate"],
                                          stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True, timeout=1.5, check=False)
                client       = f_client.result().stdout.strip()
                title        = f_title.result().stdout.strip()
                artist       = f_artist.result().stdout.strip()
                playback_rate= f_rate.result().stdout.strip()

            client_l = (client or "").strip().lower()
            client_unknown = client_l in {"", "null", "(null)", "none"}

            if not title:
                return None
            if (not re.search(r"spotify", client_l, re.IGNORECASE)) and (not client_unknown):
                return None
            return {
                "running": True,
                "paused":  playback_rate != "1",
                "title":   title,
                "artist":  artist,
                "position": 0,
                "duration": 0,
            }
        except Exception:
            return None

    # Linux: playerctl MPRIS fallback
    playerctl = shutil.which("playerctl")
    if not playerctl:
        return None
    try:
        p_title  = subprocess.run([playerctl, "-p", "spotify,Spotify", "metadata", "title"],
                                  stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True, timeout=1.5, check=False)
        p_artist = subprocess.run([playerctl, "-p", "spotify,Spotify", "metadata", "artist"],
                                  stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True, timeout=1.5, check=False)
        p_status = subprocess.run([playerctl, "-p", "spotify,Spotify", "status"],
                                  stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True, timeout=1.5, check=False)
        title  = p_title.stdout.strip()
        artist = p_artist.stdout.strip()
        status = p_status.stdout.strip().lower()
        if not title:
            return None
        return {
            "running": True,
            "paused":  status != "playing",
            "title":   title,
            "artist":  artist,
            "position": 0,
            "duration": 0,
        }
    except Exception:
        return None


def external_spotify_snapshot(max_age_sec=3.0):
    # 1. Try AppleScript first on Mac (it's the most reliable "ground truth" for the Desktop app)
    app_st = apple_script_spotify_status()
    if app_st and app_st.get("running") and app_st.get("title"):
        return app_st

    # 2. Try the CLI (fallback for non-Mac or if app is closed)
    st = spotify_status(max_age_sec=max_age_sec)
    if st.get("running") and st.get("title"):
        return st
    
    # 3. Try System Media (Global NowPlaying)
    np = nowplaying_spotify_snapshot()
    if np:
        return np
    return None


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


def normalize_queue_item(item):
    if not isinstance(item, dict):
        return
    if item.get("source") != "spotify":
        return
    uri = (item.get("spotify_uri") or "").strip()
    sid = (item.get("spotify_id") or "").strip()
    if uri and not sid:
        item["spotify_id"] = spotify_id_from_uri(uri)
        return
    if (not uri) and sid:
        item["spotify_uri"] = f"spotify:track:{sid}"


def stop_inactive_source(source):
    """Pause whichever backend is NOT currently active."""
    if source == "spotify":
        local_pause()          # pause local player when switching to Spotify
    elif source == "local":
        spotify_pause()        # pause Spotify when switching to local


def update_last_status(state, running=False, paused=True, title="Resting", artist="", source=None, position=0, duration=0, track_id=""):
    state["last_status"] = {
        "running": running,
        "paused": paused,
        "title": title or "Resting",
        "artist": artist or "",
        "source": source,
        "track_id": track_id or "",
        "loop": state.get("loop_mode", "off"),
        "position": position or 0,
        "duration": duration or 0,
    }
    
    # Auto-Resume: Update position in the queue item
    idx = state.get("current_index", -1)
    if running and idx >= 0 and idx < len(state["queue"]):
        item = state["queue"][idx]
        # Only update if it matches (to avoid cross-track pollution)
        if source == item.get("source"):
            item["last_pos"] = position

    try:
        payload = {
            "ts": time.time(),
            "data": {
                "running": state["last_status"]["running"],
                "paused": state["last_status"]["paused"],
                "title": state["last_status"]["title"],
                "artist": state["last_status"]["artist"],
                "source": state["last_status"]["source"],
                "track_id": state["last_status"]["track_id"],
                "loop": state.get("loop_mode", "off"),
                "position": state["last_status"]["position"],
                "duration": state["last_status"]["duration"],
            },
        }
        with STATUS_SNAPSHOT_PATH.open("w", encoding="utf-8") as f:
            json.dump(payload, f)
    except Exception:
        pass


def read_status_snapshot(max_age_sec=15):
    if not STATUS_SNAPSHOT_PATH.exists():
        return None
    try:
        with STATUS_SNAPSHOT_PATH.open("r", encoding="utf-8") as f:
            payload = json.load(f)
        ts = float(payload.get("ts", 0))
        data = payload.get("data") or {}
        if max_age_sec > 0 and (time.time() - ts) > max_age_sec:
            return None
        if not data:
            return None
        return data
    except Exception:
        return None


def play_current(state):
    ensure_index(state)
    if state["current_index"] < 0 or state["current_index"] >= len(state["queue"]):
        update_last_status(state)
        return
    item = state["queue"][state["current_index"]]
    normalize_queue_item(item)
    source = item.get("source", "local")
    stop_inactive_source(source)

    if source == "local":
        path = item.get("local_path")
        if not path:
            return

        # Auto-Resume: compute resume position if close to middle of track
        last_pos = item.get("last_pos") or 0
        dur_hint = item.get("duration_sec") or 0
        resume_pos = 0
        if last_pos > 1:
            if dur_hint <= 0 or last_pos < (dur_hint - 3):
                resume_pos = last_pos

        if PLAYER_BACKEND == "vlc":
            vlc_load_file(path, resume_pos=resume_pos)
            time.sleep(0.3)  # let VLC settle before querying status
            st = vlc_get_status()
            update_last_status(
                state,
                running=True,
                paused=False,
                title=st.get("title") or item.get("title") or Path(path).name,
                artist=item.get("artist", ""),
                source="local",
                position=st.get("position", 0),
                duration=st.get("duration") or item.get("duration_sec", 0),
            )
        else:
            ensure_mpv()
            mpv_send(["loadfile", path, "replace"])
            if resume_pos:
                mpv_send(["set_property", "time-pos", resume_pos])
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
                track_id=st.get("track_id") or item.get("spotify_id", ""),
            )
        else:
            # If we can't verify it's playing, don't pretend it is.
            update_last_status(
                state,
                running=False,
                paused=True,
                title=item.get("title") or "Spotify item",
                artist=item.get("artist", ""),
                source="spotify",
                track_id=item.get("spotify_id", ""),
            )
    state["active_source"] = source


def refresh_live_status(state):
    # Prioritize Local player if it is active
    local_active = False
    if state.get("source_lock") != "spotify" and is_local_active():
        local_active = True
        maybe_reconcile_local(state)

    if not local_active:
        # Fallback to Spotify only if mpv is idle or locked out
        if maybe_reconcile_external_spotify(state):
            idx = state.get("current_index", -1)
            q = state.get("queue", [])
            if idx < 0 or idx >= len(q) or q[idx].get("source") != "local":
                return
    
    # If we are in MPV mode, ensure we don't accidentally fall back later in this function
    # by checking the current item source
    idx = state.get("current_index", -1)
    q = state.get("queue", [])
    if idx < 0 or idx >= len(q):
        ext = external_spotify_snapshot()
        if ext:
            update_last_status(
                state,
                running=True,
                paused=ext.get("paused", True),
                title=ext.get("title", "Spotify"),
                artist=ext.get("artist", ""),
                source="spotify",
                position=ext.get("position", 0),
                duration=ext.get("duration", 0),
                track_id=ext.get("track_id", ""),
            )
        else:
            update_last_status(state)
        return
    item = q[idx]
    source = item.get("source", "local")
    if source == "local":
        if not is_local_running():
            ext = external_spotify_snapshot()
            if ext:
                update_last_status(
                    state,
                    running=True,
                    paused=ext.get("paused", True),
                    title=ext.get("title", "Spotify"),
                    artist=ext.get("artist", ""),
                    source="spotify",
                    position=ext.get("position", 0),
                    duration=ext.get("duration", 0),
                    track_id=ext.get("track_id", ""),
                )
            else:
                update_last_status(state, running=False, paused=True, title=item.get("title", "Resting"), artist=item.get("artist", ""), source="local")
            return
        
        lst = local_get_status()
        update_last_status(
            state,
            running=True,
            paused=lst.get("paused", True),
            title=lst.get("title") or item.get("title", "Unknown"),
            artist=item.get("artist", ""),
            source="local",
            position=lst.get("position", 0),
            duration=lst.get("duration", 0),
        )
        
        check_auto_next(state, {
            "source": "local",
            "title": lst.get("title") or item.get("title", "Unknown"),
            "paused": lst.get("paused", True),
            "position": lst.get("position", 0),
            "duration": lst.get("duration", 0)
        })
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
        st = spotify_status(max_age_sec=3.0)
        title_candidate = st.get("title")
        # If Spotify returns an opaque ID-like token or nothing, prefer queue metadata title.
        if not title_candidate or (isinstance(title_candidate, str) and re.fullmatch(r"[A-Za-z0-9]{22}", title_candidate)):
            title_candidate = item.get("title") or title_candidate or "Spotify"
        
        status_dict = {
            "running": st.get("running", False),
            "paused": st.get("paused", True),
            "title": title_candidate,
            "artist": st.get("artist") or item.get("artist", ""),
            "source": "spotify",
            "position": st.get("position", 0),
            "duration": st.get("duration", 0),
            "track_id": st.get("track_id") or item.get("spotify_id", ""),
        }
        update_last_status(state, **status_dict)
        check_auto_next(state, status_dict)


def check_auto_next(state, st):
    """Triggers the 'next' command if we are near the end of a track."""
    if st.get("paused", True):
        return
    pos = st.get("position", 0)
    dur = st.get("duration", 0)
    source = st.get("source", "local")
    
    # Thresholds: Local (2.5s), Spotify (3s)
    threshold = 3.0 if source == "spotify" else 2.5
    
    if dur > 5 and pos >= (dur - threshold):
        # Unique ID for the track to prevent multiple triggers
        track_sig = st.get("track_id") or st.get("title")
        if track_sig and state.get("last_auto_next_id") != track_sig:
            debug_log(f"Auto-next triggered for {source}: {pos}/{dur}")
            state["last_auto_next_id"] = track_sig
            save_state(state)
            
            script_path = os.path.abspath(__file__)
            subprocess.Popen([sys.executable, script_path, "next"], 
                             stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def extrapolate_progress(st, snapshot_ts):
    if not st:
        return st
    out = dict(st)
    if out.get("paused", True):
        return out
    dur = int(out.get("duration", 0) or 0)
    if dur <= 0:
        return out
    pos = int(out.get("position", 0) or 0)
    elapsed = max(0, int(time.time() - float(snapshot_ts or 0)))
    out["position"] = min(dur, pos + elapsed)
    return out


def read_status_snapshot_with_ts(max_age_sec=15):
    if not STATUS_SNAPSHOT_PATH.exists():
        return None, None
    try:
        with STATUS_SNAPSHOT_PATH.open("r", encoding="utf-8") as f:
            payload = json.load(f)
        ts = float(payload.get("ts", 0))
        data = payload.get("data") or {}
        if max_age_sec > 0 and (time.time() - ts) > max_age_sec:
            return None, ts
        if not data:
            return None, ts
        return data, ts
    except Exception:
        return None, None


def status_from_snapshot_or_state(state, max_age_sec=3):
    snap, snap_ts = read_status_snapshot_with_ts(max_age_sec=max_age_sec)
    st = snap or (state.get("last_status", {}) or {})
    if snap_ts:
        st = extrapolate_progress(st, snap_ts)
    return st


def is_external_spotify_active(max_age_sec=2.0):
    st = external_spotify_snapshot(max_age_sec=max_age_sec)
    return bool(st and st.get("running") and st.get("title"))


def maybe_reconcile_external_spotify(state):
    if state.get("source_lock") == "local":
        return False
    st = external_spotify_snapshot(max_age_sec=2.0)
    if not (st and st.get("running") and st.get("title")):
        return False
    
    state["active_source"] = "spotify"
    if state.get("queue"):
        target = -1
        live_id = (st.get("track_id") or "").strip()
        live_title = (st.get("title") or "").strip().lower()
        live_artist = (st.get("artist") or "").strip().lower()
        for i, item in enumerate(state.get("queue", [])):
            if item.get("source") != "spotify":
                continue
            if live_id and (item.get("spotify_id") == live_id):
                target = i
                break
            it_title = (item.get("title") or "").strip().lower()
            it_artist = (item.get("artist") or "").strip().lower()
            if it_title and it_title == live_title and (not live_artist or not it_artist or it_artist == live_artist):
                target = i
                break
        if target >= 0:
            if state.get("current_index") != target:
                state["current_index"] = target
                debug_log(f"Reconciled spotify current_index to {target}")
                
    update_last_status(
        state,
        running=True,
        paused=st.get("paused", True),
        title=st.get("title", "Spotify"),
        artist=st.get("artist", ""),
        source="spotify",
        position=st.get("position", 0),
        duration=st.get("duration", 0),
        track_id=st.get("track_id", ""),
    )
    return True


def maybe_reconcile_local(state):
    if state.get("source_lock") == "spotify":
        return False
    if not is_local_running():
        return False

    # Get the current track info from the active local player
    lst = local_get_status()
    live_title = (lst.get("title") or "").strip().lower()
    if not live_title:
        return False

    # For VLC we only have title; mpv also exposes path
    live_path = ""
    if PLAYER_BACKEND == "mpv":
        path_res = mpv_send(["get_property", "path"])
        live_path = str(path_res.get("data", "")).strip() if path_res else ""

    target = -1
    item = None
    for i, q_item in enumerate(state.get("queue", [])):
        if q_item.get("source") != "local":
            continue
        # Match by path first (strongest signal)
        it_path = q_item.get("local_path")
        if live_path and it_path and os.path.abspath(os.path.expanduser(it_path)) == os.path.abspath(os.path.expanduser(live_path)):
            target = i
            item = q_item
            break
            
        # Match by title
        it_title = (q_item.get("title") or "").strip().lower()
        if it_title and it_title == live_title:
            target = i
            item = q_item
            break

    if target >= 0 and item is not None:
        if state.get("current_index") != target or state.get("active_source") != "local":
            state["current_index"] = target
            state["active_source"] = "local"
            # Update status partially for immediate UI feedback in fast paths
            update_last_status(state, running=True, title=item.get("title", "Local"), artist=item.get("artist", ""), source="local")
            debug_log(f"Reconciled local current_index to {target}")
            return True
    return False


def should_prefer_external_spotify(state):
    return state.get("source_lock", "auto") != "local"


def pick_active_source_for_controls(state):
    lock = state.get("source_lock", "auto")
    if lock == "local":
        return "local" if is_local_running() else None
    if lock == "spotify":
        return "spotify" if is_external_spotify_active(max_age_sec=2.0) else None

    # Priority: local player first if it has a track loaded
    if is_local_active():
        return "local"
        
    if is_external_spotify_active(max_age_sec=2.0):
        return "spotify"
    return "local" if is_local_running() else None


def with_lock(timeout_sec=LOCK_WAIT_TIMEOUT_SEC):
    LOCK_PATH.parent.mkdir(parents=True, exist_ok=True)
    fd = os.open(str(LOCK_PATH), os.O_CREAT | os.O_RDWR, 0o600)
    start = time.time()
    while True:
        try:
            fcntl.flock(fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
            break
        except BlockingIOError:
            now = time.time()
            if (now - start) >= timeout_sec:
                # BREAK STALE LOCKS
                try:
                    os.lseek(fd, 0, os.SEEK_SET)
                    raw_info = os.read(fd, 512).decode("utf-8", "ignore")
                    if raw_info:
                        info = json.loads(raw_info)
                        owner_pid = info.get("pid")
                        owner_ts = info.get("ts", 0)
                        
                        # Case 1: PID is dead
                        if owner_pid and not is_pid_running(owner_pid):
                            debug_log(f"Breaking stale lock: PID {owner_pid} is dead.")
                            # We can't easily force unlock another process's flock if it's still alive,
                            # but if is_pid_running is False, the kernel should have released it.
                            # If we are still blocked, something is deeper, but we'll try to truncate and take it.
                            pass
                        
                        # Case 2: Process is hung (ts > 20s old for a short-lived CLI command)
                        elif owner_pid and (now - owner_ts) > 20:
                            debug_log(f"Killing hung lock owner: PID {owner_pid}")
                            try:
                                os.kill(owner_pid, 9)
                                time.sleep(0.1)
                            except: pass
                except:
                    pass
                
                # Final attempt after potential cleanup
                try:
                    fcntl.flock(fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
                    break
                except:
                    os.close(fd)
                    raise TimeoutError("radiant-player lock busy")
            time.sleep(0.1)

    try:
        payload = json.dumps(
            {
                "pid": os.getpid(),
                "ts": time.time(),
                "cmd": " ".join(sys.argv[:3]),
            }
        )
        os.ftruncate(fd, 0)
        os.lseek(fd, 0, os.SEEK_SET)
        os.write(fd, payload.encode("utf-8"))
    except Exception:
        pass
    return fd


def unlock(fd):
    try:
        fcntl.flock(fd, fcntl.LOCK_UN)
    except Exception:
        pass
    os.close(fd)


def signal_refresh():
    try:
        MUSIC_TICK_PATH.write_text(str(time.time()), encoding="utf-8")
    except Exception:
        pass
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
        ap = os.path.abspath(os.path.expanduser(f))
        meta = extract_local_metadata(ap)
        state["queue"].append(
            {
                "id": str(uuid.uuid4()),
                "source": "local",
                "title": meta.get("title"),
                "artist": meta.get("artist"),
                "album": meta.get("album"),
                "local_path": ap,
                "spotify_uri": "",
                "duration_sec": meta.get("duration_sec"),
                "added_at": now_iso(),
                "last_pos": 0,
            }
        )
    if state["current_index"] == -1 and state["queue"]:
        state["current_index"] = 0
    # Preserve old behavior: first local enqueue starts playback immediately.
    if was_empty and state["queue"]:
        state["current_index"] = 0
        play_current(state)
    save_state(state)


def cmd_add_spotify_search(query):
    """Actual search implementation (Task 2)."""
    if not query:
        return
    ok, out = spotify_cmd(["search", query])
    if not ok or not out:
        print(f"No results for '{query}'")
        return
    try:
        data = json.loads(out)
        tracks = data.get("tracks", [])
        if not tracks:
            print(f"No tracks found for '{query}'")
            return
        # Just add the first result for simplicity in CLI
        first = tracks[0]
        uri = first.get("uri") or f"spotify:track:{first.get('id')}"
        cmd_add_spotify(uri)
    except Exception as e:
        # Fallback to direct add if JSON parsing fails (e.g. old spotify_player version)
        cmd_add_spotify(query)


def cmd_add_spotify(raw):
    uri = normalize_spotify_uri(raw)
    kind = spotify_kind_from_uri(uri)
    sid = spotify_id_from_uri(uri)
    state = load_state()

    if kind == "playlist":
        tracks = spotify_playlist_tracks(uri)
        if tracks:
            state["queue"].extend(tracks)
            if state["current_index"] == -1:
                state["current_index"] = 0
            save_state(state)
            print(f"Added {SPOTIFY_ICON} playlist ({len(tracks)} tracks)")
            return
        print("Failed to fetch playlist tracks; nothing added.")
        return

    meta = spotify_track_metadata(uri)
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


def cmd_spotify_playlist_tracks(uri):
    uri = normalize_spotify_uri(uri)
    if spotify_kind_from_uri(uri) != "playlist":
        print("[]")
        return
    rows = spotify_playlist_track_choices(uri, max_items=500)
    print(json.dumps(rows))


def cmd_add_spotify_playlist_selected(uri, selected_ids_csv):
    uri = normalize_spotify_uri(uri)
    if spotify_kind_from_uri(uri) != "playlist":
        print("Failed: not a playlist URI.")
        return

    selected_ids = {
        x.strip()
        for x in (selected_ids_csv or "").split(",")
        if x.strip()
    }
    if not selected_ids:
        print("No tracks selected.")
        return

    tracks = spotify_playlist_tracks(uri, max_items=500)
    picked = [t for t in tracks if t.get("spotify_id") in selected_ids]
    if not picked:
        print("No matching tracks selected.")
        return

    state = load_state()
    state["queue"].extend(picked)
    if state["current_index"] == -1:
        state["current_index"] = 0
    save_state(state)
    print(f"Added {SPOTIFY_ICON} selected tracks ({len(picked)})")


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
    state = load_state()
    refresh_live_status(state)
    lock = state.get("source_lock", "auto")
    
    # If we have a queue and we are currently "in" it, always use Radiant skipping
    if state.get("queue") and state.get("current_index", -1) != -1:
        _step(1)
        return

    # Fallback: try external skip, if it succeeds return. Otherwise fall through.
    if lock != "local":
        if spotify_next():
            maybe_reconcile_external_spotify(state)
            return
    
    _step(1)


def cmd_prev():
    state = load_state()
    refresh_live_status(state)
    lock = state.get("source_lock", "auto")

    # If we have a queue and we are currently "in" it, always use Radiant skipping
    if state.get("queue") and state.get("current_index", -1) != -1:
        _step(-1)
        return

    # Fallback: try external skip, if it succeeds return. Otherwise fall through.
    if lock != "local":
        if spotify_prev():
            maybe_reconcile_external_spotify(state)
            return
    
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
            meta = extract_local_metadata(ap)
            out.append(
                {
                    "id": str(uuid.uuid4()),
                    "source": "local",
                    "title": meta.get("title"),
                    "artist": meta.get("artist"),
                    "album": meta.get("album"),
                    "local_path": ap,
                    "spotify_uri": "",
                    "duration_sec": meta.get("duration_sec"),
                    "added_at": now_iso(),
                    "last_pos": 0,
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
    for item in state.get("queue", []):
        normalize_queue_item(item)
    ensure_index(state)
    if state["current_index"] >= 0:
        play_current(state)
    else:
        update_last_status(state)
    save_state(state)


def migrate_playlist_file(path):
    try:
        with path.open("r", encoding="utf-8") as f:
            data = json.load(f)
    except Exception:
        return False
    changed = False
    queue = data.get("queue", [])
    if isinstance(queue, list):
        for item in queue:
            before = json.dumps(item, sort_keys=True, ensure_ascii=False)
            normalize_queue_item(item)
            after = json.dumps(item, sort_keys=True, ensure_ascii=False)
            if before != after:
                changed = True
    if data.get("source_lock") not in {"auto", "local", "spotify"}:
        data["source_lock"] = "auto"
        changed = True
    if not changed:
        return False
    with path.open("w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    return True


def cmd_migrate_playlists():
    PLAYLIST_DIR.mkdir(parents=True, exist_ok=True)
    changed = 0
    scanned = 0
    for path in PLAYLIST_DIR.glob("*.rpl.json"):
        scanned += 1
        if migrate_playlist_file(path):
            changed += 1
    print(f"Migrated {changed}/{scanned} playlists.")


def cmd_source_lock(mode=None):
    state = load_state()
    current = state.get("source_lock", "auto")
    if not mode:
        print(current)
        return
    mode = mode.strip().lower()
    if mode == "toggle":
        order = ["auto", "local", "spotify"]
        mode = order[(order.index(current) + 1) % len(order)] if current in order else "auto"
    if mode not in {"auto", "local", "spotify"}:
        print("Usage: source_lock [auto|local|spotify|toggle]")
        return
    state["source_lock"] = mode
    save_state(state)
    debug_log(f"source_lock set to {mode}")
    print(mode)


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
    pretty = f"{src_icon} {title.split('|')[0].strip() if '|' in title else title}"
    if artist:
        pretty += f" — {artist}"
    vol_text = ""
    if source == "local":
        v = local_get_volume()
        if v is not None:
            vol_text = f"  {GRAY}│{NC}  {CYAN} {v}%{NC}"

    print(f"    {state_color}{BOLD}{state_icon}{NC}  {GRAY}│{NC}  {BOLD}{pretty}{NC}{vol_text}")
    print(f"    {bar}  {DIM}{fmt_time(pos)}/{fmt_time(dur)}{NC}  {loop_label}")
    print(f"\n    {BOLD}{YELLOW}󱐋 {current_ideal}{NC}")


def cmd_status_fast():
    """
    Fast status path for high-frequency dashboard redraws.
    Uses cached state and optional cached spotify snapshot only.
    """
    state = load_state()
    st = status_from_snapshot_or_state(state, max_age_sec=3)

    if not st.get("running"):
        try:
            if SPOTIFY_STATUS_CACHE_PATH.exists():
                with SPOTIFY_STATUS_CACHE_PATH.open("r", encoding="utf-8") as f:
                    payload = json.load(f)
                ts = float(payload.get("ts", 0))
                data = payload.get("data") or {}
                if data.get("running") and data.get("title") and (time.time() - ts) < 5:
                    st = {
                        "running": True,
                        "paused": data.get("paused", True),
                        "title": data.get("title", "Spotify"),
                        "artist": data.get("artist", ""),
                        "source": "spotify",
                        "position": data.get("position", 0),
                        "duration": data.get("duration", 0),
                    }
        except Exception:
            pass

    # Priority Reconcile: Try local player first if it seems active
    local_active = False
    if state.get("source_lock") != "spotify" and is_local_active():
        local_active = True
        maybe_reconcile_local(state)
        # Ensure 'st' reflects the local state even if index didn't change
        if st.get("source") != "local":
            st = state.get("last_status", {})
            save_state(state)

    # Fallback Reconcile: Try Spotify ONLY if local is idle
    if not local_active:
        if st.get("source") == "spotify" or not st.get("running"):
            if maybe_reconcile_external_spotify(state):
                st = state.get("last_status", {})
                save_state(state)
            else:
                # If reconcile fails, and we were on Spotify, we are likely IDLE.
                if st.get("source") == "spotify":
                    st = {"running": False, "paused": True, "title": "Resting"}

    if st.get("running"):
        check_auto_next(state, st)

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
    pretty = f"{src_icon} {title.split('|')[0].strip() if '|' in title else title}"
    if artist:
        pretty += f" — {artist}"
    vol_text = ""
    if source == "local":
        v = local_get_volume()
        if v is not None:
            vol_text = f"  {GRAY}│{NC}  {CYAN} {v}%{NC}"

    print(f" {state_color}{BOLD}{state_icon}{NC}  {GRAY}│{NC}  {BOLD}{pretty}{NC}{vol_text}")
    print(f" {bar}  {DIM}{fmt_time(pos)}/{fmt_time(dur)}{NC}  {loop_label}")
    print(f"\n {BOLD}{AMETHYST_G}󱐋 {current_ideal}{NC}")


def cmd_short_status():
    state = load_state()
    refresh_live_status(state)
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


def cmd_short_status_fast():
    """
    Fast status path for UI render loops (Yazi header):
    - no refresh_live_status()
    - no spotify_player subprocess calls
    - optional lightweight fallback from cached spotify status file
    """
    state = load_state()
    st = status_from_snapshot_or_state(state, max_age_sec=3)

    if not st.get("running"):
        try:
            if SPOTIFY_STATUS_CACHE_PATH.exists():
                with SPOTIFY_STATUS_CACHE_PATH.open("r", encoding="utf-8") as f:
                    payload = json.load(f)
                ts = float(payload.get("ts", 0))
                data = payload.get("data") or {}
                if data.get("running") and data.get("title") and (time.time() - ts) < 20:
                    st = {
                        "running": True,
                        "paused": data.get("paused", True),
                        "title": data.get("title", "Spotify"),
                        "artist": data.get("artist", ""),
                        "source": "spotify",
                    }
        except Exception:
            pass

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
    # Redundant call removed to maintain mpv priority
    st = status_from_snapshot_or_state(state, max_age_sec=3)
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
        "track_id": st.get("track_id", ""),
        "position": st.get("position", 0),
        "duration": st.get("duration", 0),
    }
    print(json.dumps(data))


def cmd_toggle():
    state = load_state()
    source = pick_active_source_for_controls(state)
    if source is None:
        return
    if source == "local":
        local_toggle()
    else:
        spotify_toggle()
    refresh_live_status(state)


def cmd_seek(delta):
    state = load_state()
    source = pick_active_source_for_controls(state)
    if source == "local":
        local_seek(int(delta))
    elif source == "spotify":
        # Some spotify_player versions support this syntax.
        offset_ms = str(int(delta) * 1000)
        spotify_cmd(["playback", "seek", offset_ms])


def cmd_volume(delta):
    state = load_state()
    source = pick_active_source_for_controls(state)
    if source == "local":
        local_volume(int(delta))
    elif source == "spotify":
        # correct syntax for spotify_player 0.23.0+ is using --offset flag
        spotify_cmd(["playback", "volume", "--offset", str(delta)])


def cmd_get_volume():
    state = load_state()
    if state.get("active_source") == "local":
        vol = local_get_volume()
        if vol is not None:
            print(vol)


def cmd_current_index():
    state = load_state()
    ensure_index(state)
    print(state.get("current_index", -1))


def cmd_current_item_json():
    state = load_state()
    ensure_index(state)
    idx = state.get("current_index", -1)
    q = state.get("queue", [])
    if idx < 0 or idx >= len(q):
        print("{}")
        return
    item = dict(q[idx] or {})
    normalize_queue_item(item)
    item["current_index"] = idx
    print(json.dumps(item))


def cmd_current_art_fast():
    if not shell_ok("command -v chafa >/dev/null 2>&1"):
        return
    state = load_state()
    st = status_from_snapshot_or_state(state, max_age_sec=3)
    if not st.get("running"):
        return
    source = st.get("source")
    sig = ""
    rendered = ""
    if source == "spotify":
        track_id = (st.get("track_id") or "").strip()
        if not track_id:
            return
        sig = f"spotify:{track_id}"
        rendered = render_spotify_art_text(track_id)
    elif source == "local":
        ensure_index(state)
        idx = state.get("current_index", -1)
        q = state.get("queue", [])
        if idx < 0 or idx >= len(q):
            return
        item = q[idx] or {}
        local_path = (item.get("local_path") or "").strip()
        if not local_path:
            return
        try:
            mtime = int(os.path.getmtime(local_path))
        except Exception:
            mtime = 0
        sig = f"local:{local_path}:{mtime}"
        rendered = render_local_art_text(local_path)
    if not sig:
        return
    try:
        cached_sig = ART_CACHE_SIG_PATH.read_text(encoding="utf-8").strip() if ART_CACHE_SIG_PATH.exists() else ""
        if cached_sig == sig and ART_CACHE_RENDER_PATH.exists():
            print(ART_CACHE_RENDER_PATH.read_text(encoding="utf-8"))
            return
    except Exception:
        pass
    if not rendered:
        try:
            ART_CACHE_SIG_PATH.write_text(sig, encoding="utf-8")
            if ART_CACHE_RENDER_PATH.exists():
                ART_CACHE_RENDER_PATH.unlink()
        except Exception:
            pass
        return
    try:
        ART_CACHE_SIG_PATH.write_text(sig, encoding="utf-8")
        ART_CACHE_RENDER_PATH.write_text(rendered, encoding="utf-8")
    except Exception:
        pass
    print(rendered)


def cmd_spotify_health():
    spotify_health()


def cmd_health():
    state = load_state()
    st = read_status_snapshot(max_age_sec=30) or (state.get("last_status", {}) or {})
    spotify_st = spotify_status(max_age_sec=10)
    # VLC-specific socket info
    vlc_socket_exists = os.path.exists(VLC_SOCKET_PATH) if PLAYER_BACKEND == "vlc" else False
    mpv_socket_exists = os.path.exists(SOCKET_PATH) if PLAYER_BACKEND == "mpv" else False
    payload = {
        # Backend identification — used by radiant-mpv health panel
        "player_backend":        PLAYER_BACKEND,
        "local_player_running":  is_local_running(),
        "local_socket_exists":   vlc_socket_exists if PLAYER_BACKEND == "vlc" else mpv_socket_exists,
        # Legacy field kept for backward-compatibility with old bash parsers
        "mpv_running":           is_mpv_running(),
        "socket_path_exists":    mpv_socket_exists,
        "spotify_player": shell_ok(f"command -v {SPOTIFY_PLAYER_BIN} >/dev/null 2>&1"),
        "librespot":      shell_ok(f"command -v {LIBRESPOT_BIN} >/dev/null 2>&1"),
        "source_lock":    state.get("source_lock", "auto"),
        "active_source":  state.get("active_source"),
        "queue_size":     len(state.get("queue", [])),
        "current_index":  state.get("current_index", -1),
        "running":        st.get("running", False),
        "source":         st.get("source"),
        "title":          st.get("title", ""),
        "artist":         st.get("artist", ""),
        "spotify_running":  spotify_st.get("running", False),
        "spotify_title":    spotify_st.get("title", ""),
        "spotify_artist":   spotify_st.get("artist", ""),
        "spotify_track_id": spotify_st.get("track_id", ""),
    }
    print(json.dumps(payload))


def main():
    if len(sys.argv) < 2:
        return
    cmd = sys.argv[1]

    # Read-only commands should never block the whole player stack.
    lock_needed = cmd in {
        "play",
        "add_spotify",
        "add_spotify_search",
        "add_spotify_playlist_selected",
        "play_index",
        "remove",
        "move",
        "shuffle",
        "sort",
        "next",
        "prev",
        "loop",
        "clear",
        "save",
        "load",
        "source_lock",
        "migrate_playlists",
    }

    try:
        fd = with_lock() if lock_needed else None
    except TimeoutError:
        # Fail fast instead of freezing the TUI when another writer is active.
        print("Lock busy, please retry.")
        return
    try:
        if cmd in ("play", "add"):
            cmd_play(sys.argv[2:])
            signal_refresh()
        elif cmd == "add_spotify":
            cmd_add_spotify(sys.argv[2] if len(sys.argv) > 2 else "")
            signal_refresh()
        elif cmd == "add_spotify_search":
            cmd_add_spotify_search(sys.argv[2] if len(sys.argv) > 2 else "")
            signal_refresh()
        elif cmd == "spotify_playlist_tracks":
            cmd_spotify_playlist_tracks(sys.argv[2] if len(sys.argv) > 2 else "")
        elif cmd == "add_spotify_playlist_selected":
            cmd_add_spotify_playlist_selected(
                sys.argv[2] if len(sys.argv) > 2 else "",
                sys.argv[3] if len(sys.argv) > 3 else "",
            )
            signal_refresh()
        elif cmd == "resolve_spotify_meta":
            cmd_resolve_spotify_meta(sys.argv[2] if len(sys.argv) > 2 else "")
        elif cmd == "spotify_art":
            cmd_spotify_art(sys.argv[2] if len(sys.argv) > 2 else "")
        elif cmd == "local_art":
            cmd_local_art(sys.argv[2] if len(sys.argv) > 2 else "")
        elif cmd == "list":
            cmd_list()
        elif cmd == "play_index":
            try:
                cmd_play_index(int(sys.argv[2]))
                signal_refresh()
            except (ValueError, IndexError):
                pass
        elif cmd == "remove":
            try:
                cmd_remove(int(sys.argv[2]))
                signal_refresh()
            except (ValueError, IndexError):
                pass
        elif cmd == "move":
            try:
                cmd_move(int(sys.argv[2]), int(sys.argv[3]))
                signal_refresh()
            except (ValueError, IndexError):
                pass
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
        elif cmd == "status_fast":
            cmd_status_fast()
        elif cmd == "short_status":
            cmd_short_status()
        elif cmd == "short_status_fast":
            cmd_short_status_fast()
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
        elif cmd == "current_item_json":
            cmd_current_item_json()
        elif cmd == "current_art_fast":
            cmd_current_art_fast()
        elif cmd == "spotify_health":
            cmd_spotify_health()
        elif cmd == "health":
            cmd_health()
        elif cmd == "source_lock":
            cmd_source_lock(sys.argv[2] if len(sys.argv) > 2 else "")
        elif cmd == "migrate_playlists":
            cmd_migrate_playlists()
    except KeyboardInterrupt:
        # Avoid noisy tracebacks when user aborts dashboard/player interactions.
        return
    finally:
        if fd is not None:
            unlock(fd)


if __name__ == "__main__":
    main()
