import json

from db import get_connection


def recommendations(user_rating, weak_tags, target_min=None, target_max=None):
    if target_min is None:
        target_min = max(800, user_rating - 100)
    if target_max is None:
        target_max = user_rating + 200

    conn = get_connection()

    # Get solved problems to exclude
    solved_rows = conn.execute("""
        SELECT DISTINCT problem_id
        FROM submissions
        WHERE platform='Codeforces' AND verdict='Accepted'
    """).fetchall()
    solved_ids = {row[0] for row in solved_rows}

    # Fetch problems in the target rating range
    rows = conn.execute("""
        SELECT id, name, rating, tags
        FROM problems
        WHERE platform='Codeforces' AND rating BETWEEN ? AND ?
    """, (target_min, target_max)).fetchall()

    results = []

    for pid, name, rating, tags_json in rows:
        if pid in solved_ids:
            continue

        try:
            tags = json.loads(tags_json)
        except Exception:
            tags = []

        score = 0

        # Primary objective: address weaknesses
        for tag in weak_tags:
            if tag in tags:
                score += 15

        # Secondary objective: stay close to the target sweet spot (user_rating + 100)
        sweet_spot = user_rating + 100
        score -= abs(rating - sweet_spot) * 0.1

        results.append(
            (score, pid, name, rating, tags)
        )

    results.sort(key=lambda x: x[0], reverse=True)

    return results[:10]
