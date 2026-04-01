-- MPV Now Playing Script for SketchyBar
-- Sends notifications and updates a socket for the sketchybar plugin

local socket = require "mp.socket"
local utils = require "mp.utils"

local socket_path = utils.get_user_path("run/mpv/nowplaying.sock")

-- Create socket if it doesn't exist
if not socket.connect_unix(socket_path) then
  socket.create_unix(socket_path)
end

local function send_update(data)
  local sock = socket.connect_unix(socket_path)
  if sock then
    sock:write(data)
    sock:close()
  end
end

local function on_file_loaded(event)
  local filename = event.filename
  local title = mp.get_property("media-title")
  local artist = mp.get_property("artist")
  
  -- If media-title is empty, try to get it from filename
  if not title or title == "" then
    local _, _, name = filename:gsub(".*/", "")
    title = name:gsub("\.[^%.]+$", "") -- Remove extension
  end
  
  -- If artist is empty, try to get it from filename
  if not artist or artist == "" then
    local _, _, name = filename:gsub(".*/", "")
    local ext = name:match("\.(.+)$")
    if ext then
      artist = ext
    end
  end
  
  local data = {
    title = title,
    artist = artist,
    filename = filename
  }
  
  send_update(utils.to_json(data))
end

local function on_playback_change(event)
  -- Only send updates when playing
  if event.newstate == "playing" then
    on_file_loaded(event)
  end
end

-- Listen for file load and playback state changes
mp.observe_property("file-loaded", "none", on_file_loaded)
mp.observe_property("playback-state", "none", on_playback_change)
