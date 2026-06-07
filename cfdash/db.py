from pathlib import Path
import sqlite3

DB_PATH = (
    Path.home()
    / "Library/Application Support/cpos/cpos.db"
)

def get_connection():
    DB_PATH.parent.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(DB_PATH)
    conn.execute("""
        CREATE TABLE IF NOT EXISTS cfdash_notes (
            problem_id TEXT PRIMARY KEY,
            notes TEXT NOT NULL,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
            last_reviewed_at DATETIME,
            review_count INTEGER DEFAULT 0
        )
    """)
    conn.commit()
    return conn
