---
name: cli-best-practices
description: Core rules to follow whenever writing shell scripts or terminal-based applications.
---
# CLI Best Practices

Whenever you write code for a Command Line Interface (CLI) application or a shell script, you MUST adhere to the following rules:

1. **Strict Exit Codes**: 
   - Ensure the program exits with code `0` on success.
   - Ensure the program exits with a non-zero code on failure.
   - Do not print error messages and exit with `0`.

2. **Standard Streams**:
   - Write all standard output (data meant to be piped) to `stdout`.
   - Write all errors, warnings, logs, and interactive prompts to `stderr`.

3. **No Stack Traces by Default**:
   - Catch unhandled exceptions and print a clear, concise error message instead of a raw stack trace. Stack traces should only be visible if a `--debug` or `--verbose` flag is passed.

4. **Shell Script Safety**:
   - If writing bash/sh, always start with `set -euo pipefail`.
   - Always quote your variables to prevent word splitting.
