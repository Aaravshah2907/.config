from rich.console import Console
from rich.panel import Panel

from stats import *

console = Console()

rating = current_rating()
peak = max_rating()
solved = solved_count()
delta = rating_change()

sign = "+" if delta >= 0 else ""

text = f"""
Rating : {rating} ({sign}{delta})
Peak   : {peak}
Solved : {solved}
"""

console.print(
    Panel.fit(
        text,
        title="Codeforces Dashboard"
    )
)
