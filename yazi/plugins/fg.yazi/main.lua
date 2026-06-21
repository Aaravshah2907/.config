local function load_init()
    local init_path = "/Users/aaravshah2975/.config/yazi/plugins/fg.yazi/init.lua"
    return dofile(init_path)
end

local plugin = load_init()
return {
    entry = plugin.entry
}
