from db import get_connection

conn = get_connection()

print(
    conn.execute(
        "SELECT name FROM sqlite_master"
    ).fetchall()
)

from tags import tag_counts

for tag, count in tag_counts().most_common(15):
    print(tag, count)
