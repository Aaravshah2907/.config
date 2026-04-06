#!/usr/bin/env python3
import socket
import json
import sys
import os
import subprocess

SOCKET_PATH = "/tmp/mpv-yazi.sock"

def send_command(cmd_list):
    if not os.path.exists(SOCKET_PATH):
        return None
    try:
        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as client:
            client.settimeout(1)
            client.connect(SOCKET_PATH)
            client.sendall(json.dumps({"command": cmd_list}).encode() + b"\n")
            response = b""
            while True:
                chunk = client.recv(4096)
                if not chunk: break
                response += chunk
                if b"\n" in chunk: break
            return json.loads(response.decode())
    except Exception:
        return None

def is_running():
    return os.path.exists(SOCKET_PATH) and send_command(["get_property", "playlist"]) is not None

def main():
    if len(sys.argv) < 2:
        return

    cmd = sys.argv[1]
    
    if cmd == "play":
        files = sys.argv[2:]
        if not files:
            return
        
        # If not running, start it
        if not is_running():
            # Remove old socket if any
            if os.path.exists(SOCKET_PATH):
                os.remove(SOCKET_PATH)
            
            # Start mpv in background
            # We use absolute paths to ensure mpv can find them if triggered from different dirs
            abs_files = [os.path.abspath(f) for f in files]
            subprocess.Popen([
                "/opt/homebrew/bin/mpv", 
                "--no-video", 
                "--keep-open=no", 
                f"--input-ipc-server={SOCKET_PATH}",
                "--idle=yes",
                *abs_files
            ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        else:
            # Append to current playlist
            for f in files:
                abs_f = os.path.abspath(f)
                send_command(["loadfile", abs_f, "append-play"])

    elif cmd == "current":
        res = send_command(["get_property", "media-title"])
        if res and res.get("data"):
            print(res["data"])
        else:
            res = send_command(["get_property", "filename"])
            if res and res.get("data"):
                # Strip extension
                print(os.path.splitext(res["data"])[0])

    elif cmd == "status_json":
        if not is_running():
            print(json.dumps({"running": False}))
            return
        
        title = send_command(["get_property", "media-title"])
        if not title or not title.get("data"):
            title = send_command(["get_property", "filename"])
        paused = send_command(["get_property", "pause"])
        
        out = {
            "running": True,
            "title": title.get("data") if title else "mpv",
            "paused": paused.get("data") if paused else False
        }
        # Strip extension if title is a filename
        if out["title"] and not title.get("media-title") and "." in out["title"]:
             out["title"] = os.path.splitext(out["title"])[0]

        print(json.dumps(out))

    elif cmd == "play_index":
        if len(sys.argv) > 2:
            send_command(["set_property", "playlist-pos", int(sys.argv[2])])

    elif cmd == "toggle":
        send_command(["cycle", "pause"])

    elif cmd == "next":
        send_command(["playlist-next"])
    elif cmd == "prev":
        send_command(["playlist-prev"])
    elif cmd == "clear":
        send_command(["playlist-clear"])
    elif cmd == "list":
        res = send_command(["get_property", "playlist"])
        if res and res.get("data"):
            for i, item in enumerate(res["data"]):
                current = "*" if item.get("current") else " "
                name = item.get('title') or os.path.basename(item.get('filename') or "Unknown")
                print(f"{i:2} | {current} | {name}")
    elif cmd == "remove":
        if len(sys.argv) > 2:
            send_command(["playlist-remove", int(sys.argv[2])])

if __name__ == "__main__":
    main()
