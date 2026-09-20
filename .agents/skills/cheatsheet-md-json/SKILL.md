---
name: cheatsheet-md-json
description: Generate runnable JSON command catalogs from Markdown cheatsheet tables and keep them synchronized.
---
# Cheatsheet Markdown To JSON

Use this skill when asked to create, update, regenerate, or synchronize a Markdown cheatsheet with a runnable JSON picker catalog.

## JSON Shape

Use this structure:

```json
{ "commands": [{ "name": "Section: Label", "command": "shell command", "description": "What it does", "tags": ["section", "generated"] }] }
```

## Markdown Rules

- Group commands under ATX headings such as `## Section`.
- Use pipe tables with one command/key column and one action/description column.
- Accepted first-column headers include `Command`, `Keybinding`, `Command / Key`, `Command/key`, or `Key`.
- Wrap literal commands and keybindings in backticks.
- Use ` / ` or ` or ` for alternatives.
- Put the executable command in the first column when possible.
- Keep placeholders visible with a trailing space, `<name>`, `[name]`, or similar marker.
- Skip rows that cannot be mapped safely. Do not invent shell commands from prose.

## Local Workflow

For this config repository, prefer:

```sh
cheat_generate_json ~/.config/tmux/cheatsheet.md ~/.config/tmux/cheatsheet.json
```

The reusable generator is:

```text
~/.config/tmux/cheatsheet_md_to_json.py
```

The runner is:

```sh
cheat_run path/to/cheatsheet.json
cheat_run path/to/cheatsheet.json --edit
```

For tmux specifically, `t cheat` should call the generator before opening `cheat_run`, so `t docs` and `t cheat` stay synchronized.
