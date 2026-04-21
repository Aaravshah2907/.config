#!/usr/bin/env python3
import os
import subprocess
import sys


def main():
    backend = os.path.expanduser("~/.config/radiant-player/queue.py")
    cmd = [sys.executable, backend, *sys.argv[1:]]
    raise SystemExit(subprocess.call(cmd))


if __name__ == "__main__":
    main()
