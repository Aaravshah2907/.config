import sys
sys.path.insert(0, '/Users/aaravshah2975/.config/radiant-player')
from queue import *

state = load_state()
source = pick_active_source_for_controls(state)
print("Source is:", source)

if source == "local":
    print("Calling vlc_send seek 0")
    res = vlc_send("seek 0")
    print("vlc_send result:", res)
    
    st = vlc_get_status()
    print("vlc_get_status:", st)

