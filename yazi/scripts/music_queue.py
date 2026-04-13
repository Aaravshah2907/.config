#!/usr/bin/env python3
import socket
import json
import sys
import os
import subprocess
import time

SOCKET_PATH = "/tmp/mpv-yazi.sock"


def send_command(cmd):
    if not os.path.exists(SOCKET_PATH):
        return None
    try:
        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as s:
            s.settimeout(1)  # 🔥 IMPORTANT
            s.connect(SOCKET_PATH)
            s.send((json.dumps({"command": cmd}) + "\n").encode())

            data = b""
            while True:
                chunk = s.recv(4096)
                if not chunk:
                    break
                data += chunk
                if b"\n" in chunk:
                    break

            return json.loads(data.decode().strip())
    except Exception:
        return None

def is_running():
    return send_command(["get_property", "playlist"]) is not None

def ensure_mpv(files=None):
    if is_running():
        return

    if os.path.exists(SOCKET_PATH):
        os.remove(SOCKET_PATH)

    cmd = [
        "/opt/homebrew/bin/mpv",
        "--no-video",
        "--idle=yes",
        f"--input-ipc-server={SOCKET_PATH}"
    ]

    subprocess.Popen(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    time.sleep(0.5)

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
        # toggle pause
        send_command(["cycle", "pause"])
    else:
        # switch track
        send_command(["set_property", "playlist-pos", idx])
        time.sleep(0.05)  # 🔥 allow mpv to switch
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
    send_command(["playlist-next", "force"])

def cmd_prev():
    send_command(["playlist-prev", "force"])

def cmd_clear():
    send_command(["playlist-clear"])

def cmd_save(name):
    if not name:
        return

    if not name.endswith(".m3u"):
        name += ".m3u"

    path = os.path.expanduser(f"~/.config/mpv/playlists/{name}")
    os.makedirs(os.path.dirname(path), exist_ok=True)

    res = send_command(["get_property", "playlist"])
    if not res: return

    with open(path, "w") as f:
        for item in res["data"]:
            fname = item.get("filename")
            if fname:
                f.write(os.path.realpath(fname) + "\n")


def cmd_load(name):
    path = os.path.expanduser(f"~/.config/mpv/playlists/{name}")

    ensure_mpv()

    send_command(["loadlist", path, "replace"])

    # 🔥 wait until playlist actually exists
    for _ in range(10):
        pl = send_command(["get_property", "playlist"])
        if pl and pl.get("data"):
            break
        time.sleep(0.1)

    # 🔥 now safely start playback
    send_command(["set_property", "playlist-pos", 0])
    send_command(["set_property", "pause", False])



def cmd_status():
    if not is_running():
        print("󰓛 Idle")
        return

    title = send_command(["get_property", "media-title"])
    paused = send_command(["get_property", "pause"])
    pos = send_command(["get_property", "time-pos"])
    dur = send_command(["get_property", "duration"])

    title = title.get("data") if title else "Unknown"
    paused = paused.get("data") if paused else True
    pos = pos.get("data") if pos else None
    dur = dur.get("data") if dur else None

    def fmt(t):
        if t is None:
            return "00:00"
        try:
            return f"{int(t//60):02d}:{int(t%60):02d}"
        except:
            return "00:00"

    bar_len = 20
    if not pos or not dur or dur == 0:
        progress = 0
    else:
        progress = int((pos / dur) * bar_len)

    bar = "█" * progress + "░" * (bar_len - progress)

    state = "󰏤 Paused" if paused else " Playing"

    sys.stdout.write(f"{state} | {title}\n")
    sys.stdout.write(f"[{bar}] {fmt(pos)} / {fmt(dur)}\n")
    sys.stdout.flush()

def cmd_short_status():
    if not is_running():
        return

    title = send_command(["get_property", "media-title"])
    paused = send_command(["get_property", "pause"])
    pos = send_command(["get_property", "time-pos"])
    dur = send_command(["get_property", "duration"])

    title = title.get("data") if title else "Unknown"
    paused = paused.get("data") if paused else True
    pos = pos.get("data") if pos else 0
    dur = dur.get("data") if dur else 0

    def fmt(t):
        try:
            return f"{int(t//60):02d}:{int(t%60):02d}"
        except:
            return "00:00"

    state = "[Paused]" if paused else "[Playing]"
    # truncated title
    if len(title) > 30:
        title = title[:27] + "..."

    sys.stdout.write(f"{state} {title}\n")
    sys.stdout.flush()



def cmd_toggle():
    send_command(["cycle", "pause"])

def signal_refresh():
    try:
        if os.getenv("YAZI_ID"):
            subprocess.run(["ya", "emit", "redraw"], check=False)
            subprocess.run(["ya", "pub", "music-update"], check=False)
    except:
        pass

# ---------- MAIN ----------

if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else ""

    if cmd == "play":
        cmd_play(sys.argv[2:])
        signal_refresh()
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
    elif cmd == "clear":
        cmd_clear()
        signal_refresh()
    elif cmd == "current_index":
        res = send_command(["get_property", "playlist-pos"])
        if res and res.get("data") is not None:
            print(res["data"])
    elif cmd == "save":
        cmd_save(sys.argv[2] if len(sys.argv) > 2 else "")
    elif cmd == "load":
        cmd_load(sys.argv[2])
        signal_refresh()
    elif cmd == "status":
        cmd_status()
    elif cmd == "short_status":
        cmd_short_status()
    elif cmd == "toggle":
        cmd_toggle()
        signal_refresh()
    elif cmd == "seek":
        send_command(["seek", int(sys.argv[2]), "relative"])
        signal_refresh()
    elif cmd == "volume":
        send_command(["add", "volume", int(sys.argv[2])])
    elif cmd == "get_volume":
        res = send_command(["get_property", "volume"])
        if res and res.get("data") is not None:
            print(int(res["data"]))
