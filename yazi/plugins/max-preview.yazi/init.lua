local state = false
return {
	entry = function()
		state = not state
		if state then
			ya.manager_emit("preview", { "disable" })
		else
			ya.manager_emit("preview", { "enable" })
		end
	end,
}