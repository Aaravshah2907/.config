---
name: cli-dev-guide
description: A comprehensive guide for developing command-line interfaces (CLIs). Use this when the user is creating or modifying CLI tools, scripts, or terminal applications.
---

# CLI Development Guide

When assisting with CLI development, follow these core principles:

## 1. UI & Output Formatting
- **Rich Output:** Use formatting libraries like `rich` (Python), `chalk` (Node), or ANSI escape codes (Bash) to improve readability.
- **Progress & Feedback:** Always provide visual feedback for long-running tasks (spinners, progress bars) so the user doesn't think the CLI has frozen.
- **Silent by Default:** CLIs should do their job quietly unless an error occurs or the user requests verbose output (`-v`, `--verbose`).
- **Standard Streams:** Write standard output to `stdout` and error/warning/diagnostic messages to `stderr`. Never write errors to `stdout`.

## 2. Argument Parsing & Subcommands
- **Help Menus:** Always include robust `--help` documentation. In Python, use `click` or `typer` instead of bare `argparse` when possible for automatic help generation.
- **Short & Long Flags:** Provide both short (e.g., `-f`) and long (e.g., `--file`) flags for common options.
- **Positional vs Options:** Use positional arguments for required, primary inputs and options (flags) for modifiers and optional settings.

## 3. Exit Codes & Error Handling
- **Graceful Failures:** Catch exceptions and print a human-readable error message to `stderr` instead of dumping a stack trace (unless in debug mode).
- **Exit Codes:** 
  - Return `0` on success.
  - Return `1` for general errors.
  - Return `2` for CLI usage/syntax errors.
  - Never use exit code `0` when the operation failed.

## 4. Configuration & Environment
- **Hierarchy:** Settings should be applied in this priority: 1) CLI arguments, 2) Environment variables, 3) Configuration files, 4) Hardcoded defaults.
- **Config Files:** Store configs in standard XDG base directories (e.g., `~/.config/appname/`).

## 5. Composability
- **Piping:** Make the CLI composable. If it outputs data, offer a `--json` or `--raw` flag so it can be piped into tools like `jq` or `grep`.
