---
name: cheatsheet-md-json
description: Keep Markdown cheatsheets and runnable JSON command catalogs in sync.
---
# Cheatsheet Markdown To JSON Rule

When creating or updating a runnable cheatsheet JSON from Markdown, use the shared `commands` JSON shape:

```json
{ "commands": [{ "name": "Section: Label", "command": "shell command", "description": "What it does", "tags": ["section", "generated"] }] }
```

Markdown source rules:

- Use ATX headings such as `## Section` to group commands.
- Use pipe tables with headers like `Command | Action`, `Keybinding | Action`, or `Command / Key | Action`.
- Put literal commands and key names in backticks.
- Separate alternatives with ` / ` or ` or `.
- Keep prose in the second column. Do not hide executable commands only in prose.
- Rows that are only descriptive and cannot be mapped safely should be skipped instead of guessed.
- Commands with placeholders should keep a trailing space or clear placeholder such as `<name>` so `cheat_run --edit` can prompt before execution.

Prefer the reusable generator:

```sh
cheat_generate_json path/to/cheatsheet.md path/to/cheatsheet.json
```

For the tmux command center, `t cheat` should regenerate `~/.config/tmux/cheatsheet.json` from `~/.config/tmux/cheatsheet.md` before opening the picker so `t docs` and `t cheat` do not drift.
