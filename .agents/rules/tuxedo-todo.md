---
name: tuxedo-todo
description: Keep implementation work synchronized with the Tuxedo todo.txt file.
---
# Tuxedo Todo Rule

When the user mentions Tuxedo tasks, ant todo items, future implementation, pending project work, or `~/.tuxedo-todo`, inspect `~/.tuxedo-todo/todo.txt` before acting.

- Treat pending lines as active work and lines beginning with `x ` as completed.
- Preserve todo.txt syntax: priority like `(A)`, creation date, projects like `+config`, contexts like `@nvim`, and `due:YYYY-MM-DD`.
- When you complete a task from this file, mark it done with the Tuxedo CLI when available. If the CLI is unavailable, update the line using standard todo.txt completion syntax.
- When a repo is open, infer project context from the git root and parent directory, then filter or add tasks with relevant `+project` and `@context` tags.
- Do not remove historical completed lines unless explicitly asked.
