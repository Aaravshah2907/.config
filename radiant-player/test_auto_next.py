import json, sys, os
from queue import check_auto_next, load_state, save_state

state = load_state()
state["last_auto_next_id"] = "test"
save_state(state)

st = {
    "paused": False,
    "position": 198,
    "duration": 200,
    "source": "local",
    "track_id": "track_1",
    "title": "Test Title"
}
check_auto_next(state, st)
print("done")
