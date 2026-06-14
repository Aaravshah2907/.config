from queue import load_state, check_auto_next
state = load_state()
# Artificially set up a state where it should trigger
st = {
    "source": "local",
    "paused": False,
    "position": 105,
    "duration": 108,
    "track_id": "test_auto",
    "running": True
}
print("Before:", state.get("last_auto_next_id"))
check_auto_next(state, st)
import time; time.sleep(1) # wait for subprocess
state2 = load_state()
print("After:", state2.get("last_auto_next_id"))
