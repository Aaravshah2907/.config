from rich.console import Console
from rich.panel import Panel
from rich.table import Table

from stats import current_rating, max_rating, solved_count, rating_change, rank_from_rating, contest_count
from tags import get_strengths_and_weaknesses
from rating_histogram import get_histogram_bars
from recommendations import recommendations

console = Console()

# 1. Fetch data
user_rating = current_rating()
peak = max_rating()
rank = rank_from_rating(user_rating)
change = rating_change()
contests = contest_count()
solved = solved_count()

strengths, weaknesses = get_strengths_and_weaknesses()
recs = recommendations(user_rating, weaknesses)
bars = get_histogram_bars(max_width=20)

# Helper for milestones
def next_milestone(rating):
    if rating < 1200:
        return 1200, "Pupil"
    elif rating < 1400:
        return 1400, "Specialist"
    elif rating < 1600:
        return 1600, "Expert"
    elif rating < 1900:
        return 1900, "Candidate Master"
    elif rating < 2100:
        return 2100, "Master"
    else:
        return 2300, "Grandmaster"

target_rating, target_rank = next_milestone(user_rating)

# 2. Build Profile Panel
change_color = "green" if change >= 0 else "red"
change_sign = "+" if change > 0 else ""
profile_table = Table.grid(padding=(0, 2))
profile_table.add_column(style="bold cyan")
profile_table.add_column()
profile_table.add_row("Rating", f"[bold]{user_rating}[/bold] ({rank})")
profile_table.add_row("Peak", str(peak))
profile_table.add_row("Change", f"[{change_color}]{change_sign}{change}[/{change_color}]")
profile_table.add_row("Contests", str(contests))
profile_table.add_row("Solved", str(solved))

profile_panel = Panel(profile_table, title="[bold blue]Profile[/bold blue]", border_style="blue", expand=True)

# 3. Build Skill Analysis Panel
skills_table = Table.grid(padding=(0, 4))
skills_table.add_column("[bold green]Strengths[/bold green]", no_wrap=True)
skills_table.add_column("[bold red]Weaknesses[/bold red]", no_wrap=True)
max_len = max(len(strengths), len(weaknesses))
for i in range(max_len):
    s = strengths[i] if i < len(strengths) else ""
    w = weaknesses[i] if i < len(weaknesses) else ""
    skills_table.add_row(s, w)

skills_panel = Panel(skills_table, title="[bold magenta]Skill Analysis[/bold magenta]", border_style="magenta", expand=True)

# 4. Build Training Guidance Panel
guidance_text = f"[bold]Current Goal:[/bold] Reach {target_rank} ({target_rating})\n\n"
guidance_text += "[bold]Priority Skills:[/bold]\n"
for idx, w in enumerate(weaknesses[:3], 1):
    guidance_text += f" {idx}. {w.title()}\n"
guidance_text += f"\n[bold]Target Practice Range:[/bold] {max(800, user_rating - 100)}–{user_rating + 200}"

guidance_panel = Panel(guidance_text, title="[bold yellow]Training Guidance[/bold yellow]", border_style="yellow", expand=True)

# 5. Build Rating Distribution Panel
hist_text = ""
for rating, count, bar in bars:
    hist_text += f"{rating:<5} {bar} ({count})\n"
histogram_panel = Panel(hist_text.strip(), title="[bold cyan]Rating Distribution[/bold cyan]", border_style="cyan", expand=True)

# 6. Build Recommendations Panel
recs_table = Table(box=None, padding=(0, 1), show_header=True)
recs_table.add_column("ID", style="bold yellow")
recs_table.add_column("Rating", style="cyan")
recs_table.add_column("Problem Name")
recs_table.add_column("Tags", style="dim")
for score, pid, name, rating, tags in recs:
    tags_str = ", ".join(tags[:2])
    recs_table.add_row(pid, str(rating), name, tags_str)

recommendations_panel = Panel(recs_table, title="[bold green]Practice Recommendations[/bold green]", border_style="green", expand=True)

# 7. Assemble Dashboard Grid
grid = Table.grid(padding=(0, 2), expand=True)
grid.add_column()
grid.add_column()

left_side = Table.grid(padding=(1, 0), expand=True)
left_side.add_row(profile_panel)
left_side.add_row(skills_panel)
left_side.add_row(guidance_panel)

right_side = Table.grid(padding=(1, 0), expand=True)
right_side.add_row(histogram_panel)
right_side.add_row(recommendations_panel)

grid.add_row(left_side, right_side)

console.print()
console.print("[bold reverse blue]  Codeforces Dashboard  [/bold reverse blue]", justify="center")
console.print(grid)
console.print()
