#!/usr/bin/env python3
"""Generate runnable cheatsheet JSON from simple Markdown tables.

Expected Markdown rules:
- Use ATX headings (`## Section`) to group commands.
- Put commands in pipe tables with headers like `Command | Action`,
  `Keybinding | Action`, or `Command / Key | Action`.
- Wrap literal commands/keys in backticks.
- Multiple alternatives can be separated with ` / ` or ` or `.
- Rows with executable shell commands are emitted directly.
- Tmux `Prefix + ...` key rows are mapped to executable tmux commands when known.
- Unknown key-only or prose-only rows are skipped instead of guessed.
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path


PREFIX_MAP = {
    "prefix + d": "tmux detach-client",
    "prefix + d choose": "tmux choose-client",
    "prefix + s": "tmux choose-tree -s",
    "prefix + $": 'tmux command-prompt -I "#S" "rename-session -- \'%%\'"',
    "prefix + (": "tmux switch-client -p",
    "prefix + )": "tmux switch-client -n",
    "prefix + l": "tmux switch-client -l",
    "prefix + t": "tmux clock-mode",
    "prefix + :": "tmux command-prompt",
    "prefix + ?": "tmux list-keys",
    "prefix + ~": "tmux show-messages",
    "prefix + o": "tmux display-popup -E 'tmux-sessionx'",
    "prefix + c": "tmux new-window",
    "prefix + ,": 'tmux command-prompt -I "#W" "rename-window -- \'%%\'"',
    "prefix + &": "tmux kill-window",
    "prefix + n": "tmux next-window",
    "prefix + p": "tmux previous-window",
    "prefix + w": "tmux choose-tree -w",
    "prefix + f": "tmux find-window",
    "prefix + .": 'tmux command-prompt "move-window -t \'%%\'"',
    "prefix + '": "tmux command-prompt \"select-window -t ':%%'\"",
    "prefix + |": "tmux split-window -h",
    "prefix + %": "tmux split-window -h",
    "prefix + v": "tmux split-window -h",
    "prefix + -": "tmux split-window -v",
    "prefix + \"": "tmux split-window -v",
    "prefix + x": "tmux kill-pane",
    "prefix + z": "tmux resize-pane -Z",
    "prefix + {": "tmux swap-pane -U",
    "prefix + }": "tmux swap-pane -D",
    "prefix + q": "tmux display-panes",
    "prefix + !": "tmux break-pane",
    "prefix + ;": "tmux last-pane",
    "prefix + space": "tmux next-layout",
    "prefix + [": "tmux copy-mode",
    "prefix + ]": "tmux paste-buffer",
    "prefix + #": "tmux list-buffers",
    "prefix + =": "tmux choose-buffer",
}


def strip_md(text: str) -> str:
    text = text.replace("\\|", "|")
    text = re.sub(r"\*\*(.*?)\*\*", r"\1", text)
    text = re.sub(r"`([^`]*)`", r"\1", text)
    return " ".join(text.split())


def split_cells(line: str) -> list[str]:
    line = line.strip()
    if not line.startswith("|") or not line.endswith("|"):
        return []
    raw = line[1:-1]
    cells: list[str] = []
    current = []
    escaped = False
    for char in raw:
        if escaped:
            current.append(char)
            escaped = False
        elif char == "\\":
            escaped = True
            current.append(char)
        elif char == "|":
            cells.append("".join(current).strip())
            current = []
        else:
            current.append(char)
    cells.append("".join(current).strip())
    return cells


def is_separator(cells: list[str]) -> bool:
    return bool(cells) and all(re.fullmatch(r":?-{3,}:?", cell.strip()) for cell in cells)


def alternatives(text: str) -> list[str]:
    literal = re.findall(r"`([^`]*)`", text)
    if literal:
        chunks: list[str] = []
        for item in literal:
            chunks.extend(re.split(r"\s+(?:/|or)\s+", item))
        return [strip_md(chunk) for chunk in chunks if strip_md(chunk)]
    return [strip_md(chunk) for chunk in re.split(r"\s+(?:/|or)\s+", text) if strip_md(chunk)]


def slug(text: str) -> str:
    return re.sub(r"[^a-z0-9]+", "-", text.lower()).strip("-")


def executable_for(display: str, action: str) -> str | None:
    raw_display = display
    key = display.lower().replace("ctrl + b", "prefix").replace("prefix + ctrl +", "prefix + ctrl +")
    key = re.sub(r"\s+", " ", key).strip()
    action_lower = action.lower()

    if key.startswith("prefix + alt +"):
        direction = key.rsplit("+", 1)[-1].strip()
        return {
            "←": "tmux resize-pane -L 5",
            "left": "tmux resize-pane -L 5",
            "↓": "tmux resize-pane -D 5",
            "down": "tmux resize-pane -D 5",
            "↑": "tmux resize-pane -U 5",
            "up": "tmux resize-pane -U 5",
            "→": "tmux resize-pane -R 5",
            "right": "tmux resize-pane -R 5",
        }.get(direction)

    if key.startswith("prefix + ctrl +"):
        direction = key.rsplit("+", 1)[-1].strip()
        return {
            "←": "tmux resize-pane -L 1",
            "left": "tmux resize-pane -L 1",
            "↓": "tmux resize-pane -D 1",
            "down": "tmux resize-pane -D 1",
            "↑": "tmux resize-pane -U 1",
            "up": "tmux resize-pane -U 1",
            "→": "tmux resize-pane -R 1",
            "right": "tmux resize-pane -R 1",
        }.get(direction)

    if key.startswith("prefix +") and any(token in key for token in ["↑", "↓", "←", "→"]):
        return {
            "prefix + ←": "tmux select-pane -L",
            "prefix + left": "tmux select-pane -L",
            "prefix + ↓": "tmux select-pane -D",
            "prefix + down": "tmux select-pane -D",
            "prefix + ↑": "tmux select-pane -U",
            "prefix + up": "tmux select-pane -U",
            "prefix + →": "tmux select-pane -R",
            "prefix + right": "tmux select-pane -R",
        }.get(key)

    if key.startswith("prefix + 1 .. 9"):
        return "tmux command-prompt \"select-window -t ':%%'\""
    if key.startswith("prefix + 1"):
        return "tmux select-window -t :1"

    if raw_display == "Prefix + L":
        return "tmux switch-client -l"

    if raw_display == "Prefix + l":
        return "tmux last-window"

    if key == "prefix + s" and "split horizontally" in action_lower:
        return "tmux split-window -v"

    if key == "prefix + -" and "delete top paste buffer" in action_lower:
        return "tmux delete-buffer"

    if key == "prefix + d" and "choose" in action_lower:
        return PREFIX_MAP["prefix + d choose"]

    if key in PREFIX_MAP:
        return PREFIX_MAP[key]

    if display.startswith("t ") or display in {"t", "todo", "tux", "chtm"}:
        return display.replace("[name]", "").replace("<name>", "").strip() + (" " if "<" in display or "[" in display else "")

    if display.startswith("tmux "):
        return display.replace("<name>", "").strip() + (" " if "<name>" in display else "")

    return None


def table_rows(markdown: str) -> list[dict[str, str]]:
    section = "General"
    rows: list[dict[str, str]] = []
    headers: list[str] | None = None

    for line in markdown.splitlines():
        heading = re.match(r"^(#{2,6})\s+(.+?)\s*$", line)
        if heading:
            section = strip_md(heading.group(2))
            headers = None
            continue

        cells = split_cells(line)
        if not cells:
            headers = None
            continue

        if is_separator(cells):
            continue

        if headers is None:
            lowered = [strip_md(cell).lower() for cell in cells]
            if any(cell in {"command", "keybinding", "command / key", "command/key", "key"} for cell in lowered):
                headers = lowered
            continue

        if len(cells) < 2:
            continue

        left = cells[0]
        action = cells[1]
        for display in alternatives(left):
            command = executable_for(display, action)
            if not command:
                continue
            rows.append({
                "name": f"{section}: {display}",
                "command": command,
                "description": strip_md(action),
                "tags": [slug(section), "generated"],
            })

    return rows


def main() -> int:
    if len(sys.argv) not in {2, 3}:
        print("usage: cheatsheet_md_to_json.py INPUT.md [OUTPUT.json]", file=sys.stderr)
        return 2

    source = Path(sys.argv[1]).expanduser()
    output = Path(sys.argv[2]).expanduser() if len(sys.argv) == 3 else source.with_suffix(".json")
    commands = table_rows(source.read_text())
    output.write_text(json.dumps({"commands": commands}, indent=2, ensure_ascii=False) + "\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
