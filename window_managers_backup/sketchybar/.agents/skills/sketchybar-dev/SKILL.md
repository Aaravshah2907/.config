---
name: sketchybar-dev
description: Guidelines, commands, and best practices for modifying the user's Sketchybar configuration.
---

# Sketchybar Development Guide

When updating the user's Sketchybar configuration located in `~/.config/sketchybar/`, follow these practices:

## Commands
- To apply changes, you should reload Sketchybar using: `sketchybar --reload`
- To update a specific item property from a script, use: `sketchybar --set <item_name> <property>="<value>"`
- To debug or read current states, you can query an item: `sketchybar --query <item_name>`

## Styling & Architecture
- All colors must be sourced from `~/.local/bin/cosmere_colors.sh`. Do not hardcode hex values.
- Popups are a key feature of this config. They are usually toggled using `hover.sh` on `mouse.entered` and `mouse.exited`.
- Use Nerd Font icons for all visual indicators. 

## Scripting Best Practices
- Keep plugin scripts lightweight. If checking system stats, use native bash utilities (`awk`, `ps`, `df`) where possible to avoid slow executions.
- Avoid polling (`update_freq`) if a native event (like `window_focus`, `media_change`, or `space_change`) can trigger the update instead.
