from db import get_connection

def max_rating():
    conn = get_connection()

    row = conn.execute("""
        SELECT MAX(new_rating)
        FROM rating_history
        WHERE platform='Codeforces'
    """).fetchone()

    return row[0] if row else 0


def rank_from_rating(r):
    if r < 1200:
        return "Newbie"
    if r < 1400:
        return "Pupil"
    if r < 1600:
        return "Specialist"
    if r < 1900:
        return "Expert"
    if r < 2100:
        return "Candidate Master"
    if r < 2300:
        return "Master"
    return "Grandmaster"



def current_rating():
    conn = get_connection()

    row = conn.execute("""
        SELECT new_rating
        FROM rating_history
        WHERE platform='Codeforces'
        ORDER BY timestamp DESC
        LIMIT 1
    """).fetchone()

    return row[0] if row else 0


def max_rating():
    conn = get_connection()

    row = conn.execute("""
        SELECT MAX(new_rating)
        FROM rating_history
        WHERE platform='Codeforces'
    """).fetchone()

    return row[0] if row else 0


def solved_count():
    conn = get_connection()

    row = conn.execute("""
        SELECT COUNT(DISTINCT problem_id)
        FROM submissions
        WHERE platform='Codeforces'
        AND verdict='Accepted'
    """).fetchone()

    return row[0]


def rating_change():
    conn = get_connection()

    rows = conn.execute("""
        SELECT new_rating
        FROM rating_history
        WHERE platform='Codeforces'
        ORDER BY timestamp DESC
        LIMIT 2
    """).fetchall()

    if len(rows) < 2:
        return 0

    return rows[0][0] - rows[1][0]
