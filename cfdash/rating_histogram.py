from db import get_connection


def solved_by_rating():
    conn = get_connection()

    rows = conn.execute("""
        SELECT rating, COUNT(*)
        FROM submissions
        WHERE verdict='Accepted'
        GROUP BY rating
        ORDER BY rating
    """).fetchall()

    return rows
