from queue import load_state, status_from_snapshot_or_state
state = load_state()
st = status_from_snapshot_or_state(state, max_age_sec=3)
print("extrapolated st:", st)
