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

    elif cmd == "move":
        if len(sys.argv) > 3:
            idx = int(sys.argv[2])
            offset = int(sys.argv[3])
            res = send_command(["get_property", "playlist-count"])
            if res and res.get("data"):
                count = res["data"]
                new_idx = idx + offset
                if 0 <= new_idx < count:
                    send_command(["playlist-move", idx, new_idx])

    elif cmd == "info":
        if len(sys.argv) > 2:
            idx = int(sys.argv[2])
            res = send_command(["get_property", "playlist"])
            if res and res.get("data") and idx < len(res["data"]):
                item = res["data"][idx]
                filename = item.get("filename")
                if filename:
                    # Run ffprobe to get metadata
                    try:
                        probe = subprocess.check_output([
                            "/opt/homebrew/bin/ffprobe", 
                            "-v", "quiet", 
                            "-print_format", "json", 
                            "-show_format", "-show_streams", 
                            filename
                        ], universal_newlines=True)
                        data = json.loads(probe)
                        fmt = data.get("format", {})
                        tags = fmt.get("tags", {})
                        
                        print(f"Title:    {tags.get('title') or os.path.basename(filename)}")
                        print(f"Artist:   {tags.get('artist', 'Unknown')}")
                        print(f"Album:    {tags.get('album', 'Unknown')}")
                        print(f"Genre:    {tags.get('genre', 'Unknown')}")
                        duration = float(fmt.get("duration", 0))
                        print(f"Duration: {int(duration // 60):02d}:{int(duration % 60):02d}")
                        print(f"Size:     {int(fmt.get('size', 0)) // 1024} KB")
                    except Exception:
                        print("No metadata available.")

    elif cmd == "play_index":
        if len(sys.argv) > 2:
            idx = int(sys.argv[2])
            res = send_command(["get_property", "playlist-pos"])
            if res and res.get("data") == idx:
                send_command(["cycle", "pause"])
            else:
                send_command(["set_property", "playlist-pos", idx])
                send_command(["set_property", "pause", False])

    elif cmd == "save":
        if len(sys.argv) > 2:
            name = sys.argv[2]
            if not name.endswith(".m3u"):
                name += ".m3u"
            path = os.path.join("/Users/aaravshah2975/.config/mpv/playlists", name)
            res = send_command(["get_property", "playlist"])
            if res and res.get("data"):
                with open(path, "w") as f:
                    for item in res["data"]:
                        fname = item.get("filename")
                        if fname:
                            f.write(fname + "\n")
                print(f"Saved to {path}")

    elif cmd == "load":
        if len(sys.argv) > 2:
            path = sys.argv[2]
            if not os.path.isabs(path):
                path = os.path.join("/Users/aaravshah2975/.config/mpv/playlists", path)
                if not path.endswith(".m3u") and not os.path.exists(path):
                    path += ".m3u"
            
            # Start if not running
            if not is_running():
                os.system(f"/opt/homebrew/bin/mpv --no-video --keep-open=no --input-ipc-server={SOCKET_PATH} --idle=yes '{path}' &")
            else:
                send_command(["loadlist", path, "replace"])

    elif cmd == "toggle":
        send_command(["cycle", "pause"])

    elif cmd == "shuffle":
        send_command(["playlist-shuffle"])

    elif cmd == "sort":
        send_command(["playlist-sort", "filename"])

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
