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


def get_strengths_and_weaknesses():
    counts = tag_counts()
    
    # Standard common Codeforces tags to evaluate
    all_tags = [
        "implementation", "greedy", "math", "brute force", "sortings",
        "strings", "constructive algorithms", "number theory", "binary search",
        "dp", "data structures", "two pointers", "bitmasks", "hashing",
        "graphs", "dfs and similar", "combinatorics", "probabilities",
        "geometry", "games", "matrices", "shortest paths", "trees", "flows"
    ]
    
    sorted_tags = sorted(counts.items(), key=lambda x: x[1], reverse=True)
    strengths = [tag for tag, count in sorted_tags if count >= 10 and tag != "*special"][:5]
    
    # Weaknesses: tags from all_tags that have count < 10, sorted by solve count ascending
    weaknesses_list = []
    for tag in all_tags:
        cnt = counts.get(tag, 0)
        if cnt < 10:
            weaknesses_list.append((tag, cnt))
    
    weaknesses_list.sort(key=lambda x: x[1])
    weaknesses = [tag for tag, cnt in weaknesses_list][:5]
    
    return strengths, weaknesses
