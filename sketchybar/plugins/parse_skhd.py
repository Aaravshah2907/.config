#!/usr/bin/env python3

import os
import subprocess

SECTIONS = [
    ("WINDOWS & LAYOUT",[
        ("⌥ HJKL", "Focus"),
        ("⌥⇧ HJKL", "Swap"),
        ("⌥⌃ HJKL", "Warp"),
        ("⌥ S/G", "Display"),
        ("⌥⇧ S/G", "Move Display"),
        ("⌥⇧ R", "Rotate"),
        ("⌥⇧ X/Y", "Mirror X/Y"),
        ("⌥⇧ T", "Toggle Float"),
        ("⌥⇧ M", "Fullscreen"),
        ("⌥⇧ E", "Balance"),
    ]),
    ("SPACES & SYSTEM",[
        ("✦ 1-9", "Focus Space"),
        ("✦⇧ 1-9", "Move to Space"),
        ("✦ ←/→", "Prev/Next Space"),
        ("✦ Space", "Toggle Split"),
        ("✦ Q", "Close Window"),
        ("⌥⌃ Q/S/R", "Yabai Control"),
        ("⌥⌃ K", "Reload Bar"),
    ]),
    ("APPS & SCRATCHPAD",[
        ("✦ T", "iTerm"),
        ("✦ B", "Brave"),
        ("✦ O", "Obsidian"),
        ("✦ F", "Finder"),
        ("✦ C", "Codeforces"),
        ("✦ D", "DSA Practice"),
        ("✦ ↩", "Term Scratch"),
        ("✦ A", "GPT Scratch"),
        ("✦ M/S", "Mail/Spotify Scratch"),
        ("✦ =", "Calc Scratch"),
        ("✦ ,", "Control Center"),
        ("✦ P", "VLC Speed"),
    ])
]

def color(name, default):
    colors = {}

    path = os.path.expanduser("~/.config/sketchybar/colors.sh")

    if os.path.exists(path):
        with open(path) as f:
            for line in f:
                if line.startswith("export "):
                    try:
                        k, v = line.replace("export ", "").split("=")
                        colors[k.strip()] = v.strip().strip('"')
                    except:
                        pass

    return colors.get(name, default)

HONOR_GOLD = color("HONOR_GOLD", "0xfff1c40f")
WHITE = color("WHITE", "0xffffffff")
RADIANT_GOLD = color("RADIANT_GOLD", "0xfff39c12")

def main():
    subprocess.run(
        [
            "sketchybar",
            "--remove", "/cheatsheet\\.row\\..*/",
            "--remove", "/cheatsheet\\.header\\..*/",
            "--remove", "/cheatsheet\\.item\\..*/"
        ],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )

    cmds = []

    for idx, (title, rows) in enumerate(SECTIONS):
        header_name = f"cheatsheet.header.{idx}"
        cmds += [
            "--add", "item", header_name, "popup.cheatsheet",
            "--set", header_name,
            f"label={title}",
            "icon.drawing=off",
            f"label.color={RADIANT_GOLD}",
            "label.font=JetBrainsMono Nerd Font:Bold:11",
            "label.padding_left=10",
            "background.height=20",
        ]

        # Pair up rows for a two-column layout
        for r_idx in range(0, len(rows), 2):
            k1, v1 = rows[r_idx]
            k2, v2 = (rows[r_idx + 1] if r_idx + 1 < len(rows) else ("", ""))

            left_text = f"{k1:<10} → {v1}" if k1 else ""
            right_text = f"{k2:<10} → {v2}" if k2 else ""

            row_name = f"cheatsheet.row.{idx}.{r_idx // 2}"
            cmds += [
                "--add", "item", row_name, "popup.cheatsheet",
                "--set", row_name,
                f"icon={left_text}",
                f"label={right_text}",
                "icon.width=210",
                "icon.align=left",
                "label.align=left",
                "icon.font=JetBrainsMono Nerd Font:Regular:10",
                "label.font=JetBrainsMono Nerd Font:Regular:10",
                f"icon.color={WHITE}",
                f"label.color={WHITE}",
                "icon.padding_left=20",
                "label.padding_left=20",
                "background.height=16",
            ]

    subprocess.run(["sketchybar"] + cmds)

if __name__ == "__main__":
    main()
