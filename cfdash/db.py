from pathlib import Path
import sqlite3

DB_PATH = (
    Path.home()
    / "Library/Application Support/cpos/cpos.db"
)

def get_connection():
    return sqlite3.connect(DB_PATH)
