-- Auto-advance radiant-player queue when a track finishes in mpv
local advancing = false

mp.observe_property("eof-reached", "bool", function(name, val)
    if val == true and not advancing then
        advancing = true
        mp.command_native_async({
            name = "subprocess",
            playback_only = false,
            args = {"/opt/homebrew/bin/python3", os.getenv("HOME") .. "/.config/radiant-player/queue.py", "auto_advance"}
        }, function()
            advancing = false
        end)
    end
end)
