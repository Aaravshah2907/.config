import json
from collections import Counter

from db import get_connection


def tag_counts():
    conn = get_connection()

    rows = conn.execute("""
        SELECT tags
        FROM submissions
        WHERE verdict='Accepted'
    """).fetchall()

    counter = Counter()

    for (tags_json,) in rows:
        tags = json.loads(tags_json)

        for tag in tags:
            counter[tag] += 1

    return counter
