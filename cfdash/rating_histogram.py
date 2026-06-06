from db import get_connection


def solved_by_rating():
    conn = get_connection()

    rows = conn.execute("""
        SELECT rating, COUNT(*)
        FROM submissions
        WHERE verdict='Accepted' AND rating IS NOT NULL
        GROUP BY rating
        ORDER BY rating
    """).fetchall()

    return rows


def get_histogram_bars(max_width=30):
    rows = solved_by_rating()
    if not rows:
        return []
    
    max_count = max(count for rating, count in rows)
    results = []
    for rating, count in rows:
        width = int((count / max_count) * max_width) if max_count > 0 else 0
        if count > 0 and width == 0:
            width = 1
        bar = "█" * width
        results.append((rating, count, bar))
    return results
