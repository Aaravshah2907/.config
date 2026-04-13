#!/usr/bin/env python3
import os
import sys
import socket
import json
import subprocess
import time
import random

# Configuration
SOCKET_PATH = "/tmp/mpv-yazi.sock"

# Colors (Radiant / Stormlight Theme)
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

def is_running():
    if not os.path.exists(SOCKET_PATH):
        return False
    try:
        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as s:
            s.settimeout(0.2)
            s.connect(SOCKET_PATH)
            return True
    except:
        return False

def send_command(cmd):
    if not is_running():
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
                if not chunk: break
                response += chunk
                if b"\n" in response:
                    # Use safe decoding to prevent crashes on weird characters
                    lines = response.decode('utf-8', 'replace').split("\n")
                    for line in lines:
                        if not line.strip(): continue
                        try:
                            data = json.loads(line)
                            if data.get("request_id") == req_id:
                                return data
                        except: continue
                if len(response) > 1024 * 1024: break 
    except:
        return None
    return None

def ensure_mpv():
    if not is_running():
        # Clean up stale socket
        if os.path.exists(SOCKET_PATH):
            try: os.remove(SOCKET_PATH)
            except: pass

        cmd = [
            "/opt/homebrew/bin/mpv",
            "--no-video",
            "--idle=yes",
            "--title=${media-title}",
            f"--input-ipc-server={SOCKET_PATH}"
        ]

        subprocess.Popen(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        
        # Wait up to 2 seconds for socket to appear
        for _ in range(20):
            if is_running(): break
            time.sleep(0.1)

# ---------- COMMANDS ----------

def cmd_play(files):
    ensure_mpv()
    for f in files:
        send_command(["loadfile", os.path.abspath(f), "append-play"])

def cmd_list():
    res = send_command(["get_property", "playlist"])
    pos = send_command(["get_property", "playlist-pos"])

    if not res or not res.get("data"):
        return

    current_idx = pos.get("data") if pos else -1

    for i, item in enumerate(res["data"]):
        name = item.get("title") or os.path.basename(item.get("filename"))
        marker = "▶" if i == current_idx else " "
        print(f"{i} | {marker} | {name}")

def cmd_play_index(idx):
    cur = send_command(["get_property", "playlist-pos"])
    paused = send_command(["get_property", "pause"])

    cur_idx = cur.get("data") if cur else None
    is_paused = paused.get("data") if paused else True

    if cur_idx == idx:
        send_command(["cycle", "pause"])
    else:
        send_command(["set_property", "playlist-pos", idx])
        time.sleep(0.05)
        send_command(["set_property", "pause", False])

def cmd_remove(idx):
    send_command(["playlist-remove", idx])

def cmd_move(idx, offset):
    res = send_command(["get_property", "playlist-count"])
    if not res: return
    new = idx + offset
    if 0 <= new < res["data"]:
        send_command(["playlist-move", idx, new])

def cmd_shuffle():
    send_command(["playlist-shuffle"])

def cmd_sort():
    send_command(["playlist-sort", "filename"])

def cmd_next():
    # Get current index and title for comparison
    old_pos = send_command(["get_property", "playlist-pos"])
    old_idx = old_pos.get("data") if old_pos else -1
    old_t = send_command(["get_property", "media-title"])
    old_title = old_t.get("data") if old_t else ""

    send_command(["playlist-next", "force"])
    
    # Poll for change (max 1.0s total)
    for _ in range(20):
        time.sleep(0.05)
        curr_pos = send_command(["get_property", "playlist-pos"])
        curr_idx = curr_pos.get("data") if curr_pos else -1
        curr_t = send_command(["get_property", "media-title"])
        curr_title = curr_t.get("data") if curr_t else ""
        
        # Break if position changed OR title changed
        if curr_idx != old_idx or curr_title != old_title:
            break
    
    signal_refresh()

def cmd_prev():
    # Get current index and title for comparison
    old_pos = send_command(["get_property", "playlist-pos"])
    old_idx = old_pos.get("data") if old_pos else -1
    old_t = send_command(["get_property", "media-title"])
    old_title = old_t.get("data") if old_t else ""

    send_command(["playlist-prev", "force"])
    
    # Poll for change (max 1.0s total)
    for _ in range(20):
        time.sleep(0.05)
        curr_pos = send_command(["get_property", "playlist-pos"])
        curr_idx = curr_pos.get("data") if curr_pos else -1
        curr_t = send_command(["get_property", "media-title"])
        curr_title = curr_t.get("data") if curr_t else ""
        
        # Break if position changed OR title changed
        if curr_idx != old_idx or curr_title != old_title:
            break
    
    signal_refresh()

def cmd_clear():
    send_command(["playlist-clear"])

def cmd_save(name):
    if not name: return
    if not name.endswith(".m3u"): name += ".m3u"
    path = os.path.expanduser(f"~/.config/mpv/playlists/{name}")
    os.makedirs(os.path.dirname(path), exist_ok=True)
    res = send_command(["get_property", "playlist"])
    if not res: return
    with open(path, "w") as f:
        for item in res["data"]:
            fname = item.get("filename")
            if fname: f.write(os.path.realpath(fname) + "\n")

def cmd_load(name):
    if not name: return
    # Try with and without .m3u extension
    path = os.path.expanduser(f"~/.config/mpv/playlists/{name}")
    if not os.path.exists(path) and not name.endswith(".m3u"):
        path += ".m3u"
    
    if not os.path.exists(path):
        print(f"Error: Playlist {path} not found")
        return

    ensure_mpv()
    # Path must be absolute for mpv loadlist
    abs_path = os.path.abspath(path)
    send_command(["loadlist", abs_path, "replace"])
    
    # Wait for playlist to populate
    for _ in range(20):
        pl = send_command(["get_property", "playlist"])
        if pl and pl.get("data"): break
        time.sleep(0.1)
    
    send_command(["set_property", "playlist-pos", 0])
    send_command(["set_property", "pause", False])

def cmd_loop():
    loop_file = send_command(["get_property", "loop-file"])
    loop_playlist = send_command(["get_property", "loop-playlist"])

    # Handle various mpv return types (inf, no, yes, True, False, 0)
    lf = loop_file.get("data") if loop_file else "no"
    lp = loop_playlist.get("data") if loop_playlist else "no"

    is_loop_file = lf not in ["no", False, 0]
    is_loop_playlist = lp not in ["no", False, 0]

    if not is_loop_file and not is_loop_playlist:
        # Off -> Single
        send_command(["set_property", "loop-file", "inf"])
        send_command(["set_property", "loop-playlist", "no"])
    elif is_loop_file:
        # Single -> All
        send_command(["set_property", "loop-file", "no"])
        send_command(["set_property", "loop-playlist", "inf"])
    else:
        # All -> Off
        send_command(["set_property", "loop-file", "no"])
        send_command(["set_property", "loop-playlist", "no"])
    
    # Small delay to ensure mpv has updated the state before the UI redraws
    # Higher delay for transitions that set multiple properties
    time.sleep(0.2)
    signal_refresh()

def cmd_status():
    if not is_running():
        print(f"  {DIM}󰓛 Idle{NC}")
        return
    
    status_t = send_command(["get_property", "media-title"])
    status_p = send_command(["get_property", "pause"])
    status_pos = send_command(["get_property", "time-pos"])
    status_dur = send_command(["get_property", "duration"])

    if not status_t:
        print(f"  {DIM}󰓛 Communicating...{NC}")
        return

    title = status_t.get("data", "Unknown")
    paused = status_p.get("data", True) if status_p else True
    pos = status_pos.get("data", 0) if status_pos else 0
    dur = status_dur.get("data", 1) if status_dur else 1
    percent = (pos / dur) * 100 if dur > 0 else 0
    
    loop_file = send_command(["get_property", "loop-file"])
    loop_playlist = send_command(["get_property", "loop-playlist"])
    lf = loop_file.get("data") if loop_file else "no"
    lp = loop_playlist.get("data") if loop_playlist else "no"
    is_loop_file = lf not in ["no", False, 0]
    is_loop_playlist = lp not in ["no", False, 0]

    # Ideals Logic
    IDEALS = [
        "First Ideal: Life before death. Strength before weakness. Journey before destination.",
        "Second Ideal: I will protect those who cannot protect themselves.",
        "Third Ideal: I will protect even those I hate, so long as it is right.",
        "Fourth Ideal: I accept that there will be those I cannot protect.",
        "Fifth Ideal: I will protect myself, so that I may continue to protect others."
    ]
    current_ideal = IDEALS[int(min(percent // 20, 4))]

    def fmt_time(t):
        if t is None: return "00:00"
        try: return f"{int(t//60):02d}:{int(t%60):02d}"
        except: return "00:00"

    state_icon = "󰏤 Paused" if paused else " Playing"
    state_color = YELLOW if paused else GREEN
    
    loop_label = f"{GRAY}󰑗 Off{NC}"
    if is_loop_file: loop_label = f"{YELLOW}󰑘¹ Single{NC}"
    elif is_loop_playlist: loop_label = f"{MAGENTA}󰑖∞ All{NC}"
    
    # Progress Bar
    width = 30
    progress = int((percent * width) / 100)
    bar = f"{CYAN}{'━' * progress}{GRAY}{'─' * (width - progress)}{NC}"

    print(f"    {state_color}{BOLD}{state_icon}{NC}  {GRAY}│{NC}  {BOLD}{title}{NC}")
    print(f"    {bar}  {DIM}{fmt_time(pos)}/{fmt_time(dur)}{NC}  {loop_label}")
    print(f"\n    {BOLD}{CYAN}󱐋 {current_ideal}{NC}")

def cmd_short_status():
    if not is_running(): return
    title = send_command(["get_property", "media-title"])
    paused = send_command(["get_property", "pause"])
    loop_file = send_command(["get_property", "loop-file"])
    loop_playlist = send_command(["get_property", "loop-playlist"])
    
    title = title.get("data") if title else "Unknown"
    paused = paused.get("data") if paused else True
    
    lf = loop_file.get("data") if loop_file else "no"
    lp = loop_playlist.get("data") if loop_playlist else "no"
    is_loop_file = lf not in ["no", False, 0]
    is_loop_playlist = lp not in ["no", False, 0]
    
    state = "󰋋" if paused else "󰟎"
    
    loop_icon = "󰑗"
    if is_loop_file: loop_icon = "󰑘¹"
    elif is_loop_playlist: loop_icon = "󰑖∞"
    
    if len(title) > 25: title = title[:22] + "..."
    # Format: [STATE] LOOP_ICON TITLE
    print(f"[{state}] {loop_icon} {title}")

def cmd_status_json():
    if not is_running():
        print(json.dumps({"running": False}))
        return
        
    title_res = send_command(["get_property", "media-title"])
    title = title_res.get("data") if title_res else None

    if title is None:
        # Running but idle
        data = {
            "running": True,
            "title": "Resting",
            "paused": True,
            "loop": "off"
        }
    else:
        paused = send_command(["get_property", "pause"])
        loop_file = send_command(["get_property", "loop-file"])
        loop_playlist = send_command(["get_property", "loop-playlist"])

        lf = loop_file.get("data") if loop_file else "no"
        lp = loop_playlist.get("data") if loop_playlist else "no"
        is_loop_file = lf not in ["no", False, 0]
        is_loop_playlist = lp not in ["no", False, 0]

        data = {
            "running": True,
            "title": title,
            "paused": paused.get("data") if paused else True,
            "loop": "single" if is_loop_file else "playlist" if is_loop_playlist else "off"
        }
    print(json.dumps(data))

def cmd_toggle():
    send_command(["cycle", "pause"])

def signal_refresh():
    try:
        if os.getenv("YAZI_ID"):
            subprocess.run(["ya", "emit", "redraw"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False)
            subprocess.run(["ya", "pub", "music-update"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False)
    except: pass

# ---------- MAIN ----------

if __name__ == "__main__":
    if len(sys.argv) < 2: sys.exit(0)
    cmd = sys.argv[1]

    if cmd == "play": cmd_play(sys.argv[2:]); signal_refresh()
    elif cmd == "list": cmd_list()
    elif cmd == "play_index": cmd_play_index(int(sys.argv[2])); signal_refresh()
    elif cmd == "remove": cmd_remove(int(sys.argv[2])); signal_refresh()
    elif cmd == "move": cmd_move(int(sys.argv[2]), int(sys.argv[3])); signal_refresh()
    elif cmd == "shuffle": cmd_shuffle(); signal_refresh()
    elif cmd == "sort": cmd_sort(); signal_refresh()
    elif cmd == "next": cmd_next()
    elif cmd == "prev": cmd_prev()
    elif cmd == "loop": cmd_loop()
    elif cmd == "clear": cmd_clear(); signal_refresh()
    elif cmd == "save": cmd_save(sys.argv[2] if len(sys.argv) > 2 else "")
    elif cmd == "load": cmd_load(sys.argv[2]); signal_refresh()
    elif cmd == "status": cmd_status()
    elif cmd == "short_status": cmd_short_status()
    elif cmd == "status_json": cmd_status_json()
    elif cmd == "toggle": cmd_toggle(); signal_refresh()
    elif cmd == "seek": send_command(["seek", int(sys.argv[2]), "relative"]); signal_refresh()
    elif cmd == "volume": send_command(["add", "volume", int(sys.argv[2])])
    elif cmd == "get_volume":
        res = send_command(["get_property", "volume"])
        if res and res.get("data") is not None: print(int(res["data"]))
    elif cmd == "current_index":
        res = send_command(["get_property", "playlist-pos"])
        if res and res.get("data") is not None: print(res["data"])
