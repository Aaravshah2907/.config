---
name: tuxedo-todo
description: Read, write, and filter the user's ~/.tuxedo-todo/todo.txt implementation tasks.
---
# Tuxedo Todo

Use this skill when the user asks about Tuxedo todo tasks, ant todo items, future implementations, or pending work tied to the current repository.

## Workflow

1. Read `~/.tuxedo-todo/todo.txt`.
2. Identify pending tasks by ignoring blank lines and lines that start with `x `.
3. If working inside a git repository, derive context from the git root basename and current parent directory. Prefer filtering pending items that mention matching `+project` or `@context` tags.
4. Preserve todo.txt fields when editing:
   - Completion prefix: `x YYYY-MM-DD`
   - Priority: `(A)`, `(B)`, `(C)`, or custom local priorities such as `(T)`
   - Projects: `+project`
   - Contexts: `@context`
   - Due dates: `due:YYYY-MM-DD`
5. Prefer the `tuxedo` CLI for add/list/do operations. If unavailable, edit `todo.txt` directly and keep the existing line order.

## Defaults

- Default todo directory: `~/.tuxedo-todo`
- Default todo file: `~/.tuxedo-todo/todo.txt`
- Default completed file: `~/.tuxedo-todo/done.txt`
