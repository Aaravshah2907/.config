import os
import sys
import datetime
import tempfile
import subprocess
import re
# pyrefly: ignore [missing-import]
from rich.console import Console
# pyrefly: ignore [missing-import]
from rich.panel import Panel
# pyrefly: ignore [missing-import]
from rich.table import Table
# pyrefly: ignore [missing-import]
from rich.rule import Rule
# pyrefly: ignore [missing-import]
from rich.markdown import Markdown

from db import get_connection

console = Console()

def get_editor():
    return os.environ.get("EDITOR", "nano")

def get_config_editor():
    config_path = os.path.expanduser("~/Library/Application Support/cpos/config.toml")
    if os.path.exists(config_path):
        try:
            with open(config_path, "r", encoding="utf-8") as f:
                for line in f:
                    if line.strip().startswith("editor"):
                        parts = line.split("=", 1)
                        if len(parts) == 2:
                            val = parts[1].strip().strip('"').strip("'")
                            return val
        except Exception:
            pass
    return "code {file}"

def find_local_code_file(problem_id):
    search_paths = [
        os.path.expanduser("~/Documents/Code/Codeforces"),
        os.path.expanduser("~/Documents/Code/Codeforces/codeforces")
    ]
    pattern = re.compile(rf"^{re.escape(problem_id)}\.(cpp|java|py|c)$", re.IGNORECASE)
    for path in search_paths:
        if not os.path.exists(path):
            continue
        try:
            for item in os.listdir(path):
                if pattern.match(item):
                    return os.path.join(path, item)
        except Exception:
            pass
    return None

def problem_id_sort_key(problem_id):
    """Return a sort key for natural ordering of problem IDs.
    Handles IDs like '123A45' where the numeric parts may have variable length.
    The key is a list where numeric components are integers and alphabetic components
    are lower‑cased strings, enabling proper mixed sorting.
    """
    import re
    parts = re.findall(r"\d+|[A-Za-z]+", problem_id)
    return [int(p) if p.isdigit() else p.lower() for p in parts]

def is_pending(now, last_rev):
            if not last_rev:
                return True
            try:
                rev_time = datetime.datetime.strptime(last_rev, "%Y-%m-%d %H:%M:%S")
                return rev_time < now - datetime.timedelta(days=15)
            except Exception:
                return False

def open_code_file(file_path):
    editor_tmpl = get_config_editor()
    if "{file}" in editor_tmpl:
        cmd = editor_tmpl.replace("{file}", file_path)
    else:
        cmd = f"{editor_tmpl} {file_path}"
    
    try:
        subprocess.Popen(cmd, shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        console.print(f"[green]Opened code file in editor: {cmd}[/green]")
    except Exception as e:
        console.print(f"[red]Error opening code file: {e}[/red]")

def edit_text(initial_text=""):
    editor = get_editor()
    with tempfile.NamedTemporaryFile(suffix=".md", delete=False) as tf:
        tf.write(initial_text.encode('utf-8'))
        temp_path = tf.name
    
    try:
        subprocess.run([editor, temp_path], check=True)
        with open(temp_path, 'r', encoding='utf-8') as f:
            updated_text = f.read()
        return updated_text.strip()
    finally:
        if os.path.exists(temp_path):
            os.remove(temp_path)

def get_problem_details(problem_id):
    conn = get_connection()
    row = conn.execute("SELECT name, rating, tags FROM problems WHERE id = ?", (problem_id,)).fetchone()
    if row:
        return row[0], row[1], row[2]
    
    row = conn.execute("SELECT problem_name, rating, tags FROM submissions WHERE problem_id = ?", (problem_id,)).fetchone()
    if row:
        return row[0], row[1], row[2]
    
    return None, None, None

def get_submission_stats(problem_id):
    conn = get_connection()
    row = conn.execute("""
        SELECT COUNT(*), SUM(CASE WHEN verdict='Accepted' THEN 1 ELSE 0 END)
        FROM submissions
        WHERE problem_id = ? AND platform = 'Codeforces'
    """, (problem_id,)).fetchone()
    
    attempts = row[0] if row and row[0] is not None else 0
    successes = row[1] if row and row[1] is not None else 0
    return attempts, successes

def add_note(problem_id):
    name, rating, tags = get_problem_details(problem_id)
    attempts, successes = get_submission_stats(problem_id)
    if not name:
        console.print(f"[yellow]Warning: Problem {problem_id} not found in local database. You can still add a note for it.[/yellow]")
        name = f"Problem {problem_id}"
        rating = 0
    
    conn = get_connection()
    row = conn.execute("SELECT notes FROM cfdash_notes WHERE problem_id = ?", (problem_id,)).fetchone()
    existing_note = row[0] if row else ""
    
    template = f"""# {problem_id}: {name} (Rating: {rating})

## 🏷️ Tags
- {tags}

## 📊 Attempts / Solves
- Attempts: {attempts}
- Solves: {successes}

## 💡 Key Idea / Approach
- 

## ⚙️ Complexity
- **Time**: O()
- **Space**: O()

## ⚠️ Pitfalls / What to remember
- 
"""

    initial_text = existing_note if existing_note else template
    
    try:
        updated_text = edit_text(initial_text)
    except Exception as e:
        console.print(f"[red]Error opening editor: {e}[/red]")
        console.print("Please enter your notes below (Press Ctrl+D when finished):")
        updated_text = sys.stdin.read().strip()

    if updated_text == template or not updated_text:
        console.print("[yellow]No notes were added/changed.[/yellow]")
        return
    
    now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    conn.execute("""
        INSERT INTO cfdash_notes (problem_id, notes, created_at, updated_at)
        VALUES (?, ?, ?, ?)
        ON CONFLICT(problem_id) DO UPDATE SET
            notes = excluded.notes,
            updated_at = ?
    """, (problem_id, updated_text, now, now, now))
    conn.commit()
    console.print(f"[green]Successfully saved notes for {problem_id}: {name}.[/green]")

def view_note(problem_id, open_code=False):
    conn = get_connection()
    row = conn.execute("SELECT notes, updated_at, review_count, last_reviewed_at FROM cfdash_notes WHERE problem_id = ?", (problem_id,)).fetchone()
    if not row:
        console.print(f"[red]No note found for problem {problem_id}.[/red]")
        return
    
    notes, updated_at, review_count, last_reviewed_at = row
    name, rating, _ = get_problem_details(problem_id)
    attempts, successes = get_submission_stats(problem_id)
    if not name:
        name = "Unknown Problem"
        rating = 0
    
    info_str = f"Rating: {rating} | Attempts: {attempts} | Solves: {successes} | Last Updated: {updated_at} | Reviews: {review_count}"
    if last_reviewed_at:
        info_str += f" | Last Reviewed: {last_reviewed_at}"
        
    panel = Panel(
        Markdown(notes),
        title=f"[bold green]Notes for {problem_id}: {name}[/bold green]",
        subtitle=f"[dim]{info_str}[/dim]",
        border_style="green",
        expand=True
    )
    console.print(panel)

    code_file = find_local_code_file(problem_id)
    if code_file:
        console.print(f"Source file: [dim]{code_file}[/dim]")
        if open_code:
            open_code_file(code_file)
    elif open_code:
        console.print("[yellow]Source file not found locally.[/yellow]")

def list_notes(sort_key=None):
    conn = get_connection()
    rows = conn.execute("""
        SELECT problem_id, notes, updated_at, review_count, last_reviewed_at
        FROM cfdash_notes
    """).fetchall()

    if not rows:
        console.print("[yellow]No notes found. Add some using 'cfdash add <problem_id>' or 'cfdash import'![/yellow]")
        return

    # Determine sorting
    if sort_key == "rating":
        # Sort by rating ascending using problem details
        rows = sorted(rows, key=lambda r: get_problem_details(r[0])[1] or 0)
    elif sort_key == "id":
        rows = sorted(rows, key=lambda r: problem_id_sort_key(r[0]))
    elif sort_key == "pending":
        # Pending reviews first: last_rev is None or older than 7 days
        import datetime
        now = datetime.datetime.now()
        rows = sorted(rows, key=lambda r: (0 if is_pending(now, r[4]) else 1))

    table = Table(title=f"Saved Notes: ({len(rows)} entries)", border_style="cyan")
    table.add_column("Problem ID", style="bold yellow")
    table.add_column("Name", style="cyan")
    table.add_column("Rating", style="magenta", justify="right")
    table.add_column("Solves/Attempts", style="green", justify="center")
    table.add_column("Last Updated", style="dim")
    table.add_column("Reviews", justify="right")

    for pid, notes, updated_at, rev_count, last_rev in rows:
        name, rating, _ = get_problem_details(pid)
        attempts, successes = get_submission_stats(pid)
        if not name:
            name = "Unknown"
            rating = 0
        rating_str = str(rating) if rating > 0 else "-"
        stats_str = f"{successes}/{attempts}"
        table.add_row(pid, name, rating_str, stats_str, updated_at, str(rev_count))

    console.print(table)

def remove_note(problem_id):
    conn = get_connection()
    row = conn.execute("SELECT 1 FROM cfdash_notes WHERE problem_id = ?", (problem_id,)).fetchone()
    if not row:
        console.print(f"[red]No note found for problem {problem_id}.[/red]")
        return
    
    confirm = input(f"Are you sure you want to delete the note for {problem_id}? (y/N): ").strip().lower()
    if confirm == 'y':
        conn.execute("DELETE FROM cfdash_notes WHERE problem_id = ?", (problem_id,))
        conn.commit()
        console.print(f"[green]Successfully deleted notes for {problem_id}.[/green]")
    else:
        console.print("[yellow]Deletion cancelled.[/yellow]")

def review_notes():
    conn = get_connection()
    rows = conn.execute("""
        SELECT problem_id, notes, updated_at, review_count, last_reviewed_at
        FROM cfdash_notes
        ORDER BY last_reviewed_at ASC, updated_at DESC
    """).fetchall()
    
    if not rows:
        console.print("[yellow]No notes found to review. Add notes using 'cfdash add <problem_id>' first.[/yellow]")
        return
    
    total = len(rows)
    console.print(f"[bold cyan]Starting review session of {total} problem(s)...[/bold cyan]")
    console.print("For each problem, recall your notes/solution details, then press Enter to view the saved notes.")
    console.print("Press Ctrl+C at any time to exit the review session.\n")
    
    try:
        for idx, (pid, notes, updated_at, rev_count, last_rev) in enumerate(rows, 1):
            name, rating, _ = get_problem_details(pid)
            attempts, successes = get_submission_stats(pid)
            if not name:
                name = "Unknown"
                rating = 0
            
            console.print(Rule(title=f"Problem {idx}/{total}: {pid} - {name} ({rating})", characters="="))
            console.print(f"Rating: [magenta]{rating}[/magenta] | Attempts: [yellow]{attempts}[/yellow] | Solves: [green]{successes}[/green] | Reviewed {rev_count} times")
            
            code_file = find_local_code_file(pid)
            if code_file:
                console.print(f"Source file: [dim]{code_file}[/dim]")
                open_src = input("Open source code file in editor? (y/N): ").strip().lower()
                if open_src in ('y', 'yes'):
                    open_code_file(code_file)
            
            input("\nPress [Enter] to reveal your notes...")
            
            panel = Panel(
                Markdown(notes),
                title=f"[bold green]Saved Notes[/bold green]",
                border_style="green",
                expand=True
            )
            console.print(panel)
            
            ans = input("\nMark as reviewed? (Y/n): ").strip().lower()
            if ans != 'n':
                now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                conn.execute("""
                    UPDATE cfdash_notes
                    SET review_count = review_count + 1,
                        last_reviewed_at = ?
                    WHERE problem_id = ?
                """, (now, pid))
                conn.commit()
                console.print("[green]Marked as reviewed![/green]\n")
            else:
                console.print("[yellow]Skipped marking as reviewed.[/yellow]\n")
                
            if idx < total:
                keep_going = input("Continue to next problem? (Y/n): ").strip().lower()
                if keep_going == 'n':
                    break
    except KeyboardInterrupt:
        console.print("\n[yellow]Review session interrupted.[/yellow]")
            
    console.print("[bold green]Review session completed![/bold green]")

def import_new_notes():
    search_paths = [
        os.path.expanduser("~/Documents/Code/Codeforces"),
        os.path.expanduser("~/Documents/Code/Codeforces/codeforces")
    ]
    
    pattern = re.compile(r"^(\d+[A-Za-z]\d*)\.(cpp|java|py|c)$", re.IGNORECASE)
    found_problems = {}
    
    for path in search_paths:
        if not os.path.exists(path):
            continue
        try:
            for item in os.listdir(path):
                full_path = os.path.join(path, item)
                if os.path.isfile(full_path):
                    match = pattern.match(item)
                    if match:
                        prob_id = match.group(1).upper()
                        if prob_id not in found_problems:
                            found_problems[prob_id] = full_path
        except Exception as e:
            console.print(f"[red]Error scanning directory {path}: {e}[/red]")
            
    if not found_problems:
        console.print("[yellow]No solution files found in Codeforces directories matching the filename format.[/yellow]")
        return
        
    conn = get_connection()
    existing_rows = conn.execute("SELECT problem_id FROM cfdash_notes").fetchall()
    existing_ids = {row[0].upper() for row in existing_rows}
    
    new_problems = {pid: path for pid, path in found_problems.items() if pid not in existing_ids}
    
    if not new_problems:
        console.print("[green]All local solution files already have notes in the database![/green]")
        return
        
    console.print(f"[bold cyan]Found {len(new_problems)} problem(s) with local solution files that don't have notes:[/bold cyan]")
    
    sorted_probs = sorted(new_problems.keys())
    
    try:
        for idx, pid in enumerate(sorted_probs, 1):
            name, rating, _ = get_problem_details(pid)
            attempts, successes = get_submission_stats(pid)
            
            console.print(Rule(title=f"New Solved Problem {idx}/{len(new_problems)}: {pid}", characters="-"))
            console.print(f"Name: [cyan]{name or 'Unknown'}[/cyan]")
            console.print(f"Rating: [magenta]{rating or 'Unknown'}[/magenta]")
            console.print(f"Attempts: [yellow]{attempts}[/yellow] | Successful Tries: [green]{successes}[/green]")
            console.print(f"Source file: [dim]{new_problems[pid]}[/dim]")
            
            while True:
                ans = input("\nAdd a note for this problem? (Y/n/quit): ").strip().lower()
                if ans in ('q', 'quit', 'exit'):
                    console.print("[yellow]Import session aborted.[/yellow]")
                    return
                elif ans == 'n':
                    console.print("[yellow]Skipped.[/yellow]\n")
                    break
                elif ans in ('y', 'yes', ''):
                    add_note(pid)
                    break
                else:
                    console.print("[red]Invalid option. Please enter y, n, or quit.[/red]")
    except KeyboardInterrupt:
        console.print("\n[yellow]Import session interrupted.[/yellow]")
                
    console.print("[bold green]Import session completed![/bold green]")

def get_notes_stats():
    conn = get_connection()
    row_solved = conn.execute("""
        SELECT COUNT(DISTINCT problem_id)
        FROM submissions
        WHERE platform='Codeforces' AND verdict='Accepted'
    """).fetchone()
    solved = row_solved[0] if row_solved else 0
    
    row_notes = conn.execute("SELECT COUNT(*) FROM cfdash_notes").fetchone()
    notes_count = row_notes[0] if row_notes else 0
    
    row_pending = conn.execute("""
        SELECT COUNT(*)
        FROM cfdash_notes
        WHERE last_reviewed_at IS NULL
           OR last_reviewed_at < datetime('now', '-7 days')
    """).fetchone()
    pending_count = row_pending[0] if row_pending else 0
    
    return notes_count, solved, pending_count
