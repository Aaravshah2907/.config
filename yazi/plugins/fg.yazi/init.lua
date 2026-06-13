return {
	entry = function(_, args)
		local is_fzf = args and args[1] == "fzf"
		local cmd = is_fzf and "fzf" or "rg --files-with-matches '' | fzf"
		
		-- Open finding in the default editor or pager
		local script = cmd .. " --bind 'enter:become($EDITOR {})'"
		ya.manager_emit("shell", { script, block = true })
	end,
}