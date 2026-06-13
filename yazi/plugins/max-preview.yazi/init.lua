local state = false
return {
	entry = function()
		state = not state
		if state then
			ya.manager_emit("plugin", { "syl-notify", args = ya.quote("custom") .. " " .. ya.quote("󰌵 Sylphrena") .. " " .. ya.quote("Maximizing vision") })
			ya.manager_emit("preview", { "disable" })
		else
			ya.manager_emit("preview", { "enable" })
		end
	end,
}