-- =============================================================================
-- ~/.config/nvim/lua/custom/tuxedo.lua
-- Neovim <-> Tuxedo (todo.txt) integration module
-- =============================================================================

local M = {}

---Get the absolute path to the active todo.txt file
---@return string
function M.get_todo_file()
	return os.getenv("TODO_FILE") or (os.getenv("HOME") .. "/.tuxedo-todo/todo.txt")
end

---Get the project tag for the current buffer or working directory
---@param bufnr? integer
---@return string
function M.get_project_tag(bufnr)
	bufnr = bufnr or 0
	local buf_name = vim.api.nvim_buf_get_name(bufnr)
	local start_dir = (buf_name ~= "") and vim.fs.dirname(buf_name) or vim.fn.getcwd()

	-- Find git root if available
	local git_root = vim.fs.root(start_dir, { ".git" })
	local project_name = ""

	if git_root then
		project_name = vim.fs.basename(git_root)
	else
		project_name = vim.fs.basename(start_dir)
	end

	-- Clean up project name to be a valid todo.txt tag (alphanumeric and underscore)
	project_name = project_name:gsub("[^%w_]", "_"):gsub("^_+", ""):gsub("_+$", "")
	if project_name == "" then
		project_name = "scratch"
	end

	return project_name
end

---Extract and strip comment symbols and TODO keywords from a line of code
---@param line string
---@return string clean_text, string? keyword
function M.clean_todo_line(line)
	local text = line:match("^%s*(.-)%s*$") or ""

	-- Strip common comment starters: //, --, #, /*, *, <!--, ;
	text = text:gsub("^//+%s*", "")
	text = text:gsub("^%-%-+%s*", "")
	text = text:gsub("^#+%s*", "")
	text = text:gsub("^/%*+%s*", "")
	text = text:gsub("^%*+%s*", "")
	text = text:gsub("^<!%-%-%s*", "")
	text = text:gsub("%-%->%s*$", "")
	text = text:gsub("^;+%s*", "")
	text = text:gsub("%*/%s*$", "")

	-- Find and strip keyword if present
	local keyword = nil
	local found_kw, rest = text:match("^([%a]+):?%s+(.+)$")
	if found_kw then
		local upper_kw = found_kw:upper()
		if
			vim.tbl_contains(
				{ "TODO", "FIXME", "BUG", "HACK", "NOTE", "PERF", "WARN", "WARNING", "IDEA", "XXX" },
				upper_kw
			)
		then
			keyword = upper_kw
			text = rest
		end
	end

	return text:match("^%s*(.-)%s*$") or "", keyword
end

---Add a formatted task to Tuxedo via CLI
---@param task_str string
---@param callback? fun(success: boolean, output: string)
function M.add_task_to_tuxedo(task_str, callback)
	local todo_file = M.get_todo_file()
	local env = {
		TODO_FILE = todo_file,
		TODO_DIR = vim.fs.dirname(todo_file),
	}

	local cmd = { "tuxedo", "add", task_str }

	vim.fn.jobstart(cmd, {
		env = env,
		stdout_buffered = true,
		stderr_buffered = true,
		on_exit = function(_, exit_code, _)
			local success = (exit_code == 0)
			if callback then
				callback(success, task_str)
			end
		end,
	})
end

---Extract TODO under cursor and send to Tuxedo
function M.extract_cursor_todo()
	local bufnr = vim.api.nvim_get_current_buf()
	local abs_path = vim.api.nvim_buf_get_name(bufnr)
	if abs_path == "" then
		vim.notify("Cannot extract todo from unnamed buffer", vim.log.levels.WARN, { title = "Tuxedo" })
		return
	end

	local cursor_line = vim.api.nvim_get_current_line()
	local lnum = vim.fn.line(".")
	local clean_text, keyword = M.clean_todo_line(cursor_line)

	if clean_text == "" then
		clean_text = "Todo task"
	end

	local project_tag = M.get_project_tag(bufnr)
	local file_ref = string.format("file://%s#L%d", abs_path, lnum)

	local default_input = string.format("(T) %s +%s @nvim %s", clean_text, project_tag, file_ref)

	vim.ui.input({
		prompt = "Add to Tuxedo: ",
		default = default_input,
	}, function(input)
		if not input or input:match("^%s*$") then
			return
		end

		M.add_task_to_tuxedo(input, function(success)
			if success then
				vim.notify(
					string.format("Task added to Tuxedo (+%s)", project_tag),
					vim.log.levels.INFO,
					{ title = "Tuxedo" }
				)
			else
				vim.notify("Failed to add task to Tuxedo", vim.log.levels.ERROR, { title = "Tuxedo" })
			end
		end)
	end)
end

---Extract visual selection and send to Tuxedo
function M.extract_visual_selection()
	local bufnr = vim.api.nvim_get_current_buf()
	local abs_path = vim.api.nvim_buf_get_name(bufnr)
	if abs_path == "" then
		vim.notify("Cannot extract todo from unnamed buffer", vim.log.levels.WARN, { title = "Tuxedo" })
		return
	end

	-- Exit visual mode to save visual selection marks
	vim.cmd("normal! \27")

	local start_line = vim.fn.line("'<")
	local end_line = vim.fn.line("'>")
	local lines = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, false)

	local cleaned_lines = {}
	for _, line in ipairs(lines) do
		local clean_text = M.clean_todo_line(line)
		if clean_text ~= "" then
			table.insert(cleaned_lines, clean_text)
		end
	end

	local combined_text = table.concat(cleaned_lines, " ")
	if combined_text == "" then
		combined_text = "Multi-line task"
	end

	local project_tag = M.get_project_tag(bufnr)
	local file_ref = string.format("file://%s#L%d-L%d", abs_path, start_line, end_line)
	local default_input = string.format("(T) %s +%s @nvim %s", combined_text, project_tag, file_ref)

	vim.ui.input({
		prompt = "Add visual selection to Tuxedo: ",
		default = default_input,
	}, function(input)
		if not input or input:match("^%s*$") then
			return
		end

		M.add_task_to_tuxedo(input, function(success)
			if success then
				vim.notify(
					string.format("Visual selection added to Tuxedo (+%s)", project_tag),
					vim.log.levels.INFO,
					{ title = "Tuxedo" }
				)
			else
				vim.notify("Failed to add task to Tuxedo", vim.log.levels.ERROR, { title = "Tuxedo" })
			end
		end)
	end)
end

---Parse a task raw string to extract file and line reference if available
---@param raw_text string
---@return string? filename, integer? lnum
function M.parse_file_reference(raw_text)
	-- 1. Match file://<path>#L<line>
	local file_uri, line_uri = raw_text:match("file://([^%s#]+)#L(%d+)")
	if file_uri and line_uri then
		return file_uri, tonumber(line_uri)
	end

	-- 2. Match standard <path>:<line>
	local path, lnum = raw_text:match("([%w%-_./\\]+):(%d+)")
	if path and lnum and vim.fn.filereadable(path) == 1 then
		return path, tonumber(lnum)
	end

	return nil, nil
end

---Fetch tasks from Tuxedo CLI as JSON
---@param filter? string
---@param callback fun(tasks: table[])
function M.fetch_tasks(filter, callback)
	local todo_file = M.get_todo_file()
	local cmd = { "tuxedo", "ls" }
	if filter and filter ~= "" then
		table.insert(cmd, filter)
	end
	table.insert(cmd, "--json")

	local stdout = {}
	vim.fn.jobstart(cmd, {
		env = {
			TODO_FILE = todo_file,
			TODO_DIR = vim.fs.dirname(todo_file),
		},
		stdout_buffered = true,
		on_stdout = function(_, data)
			if data then
				for _, line in ipairs(data) do
					if line ~= "" then
						table.insert(stdout, line)
					end
				end
			end
		end,
		on_exit = function(_, exit_code)
			if exit_code ~= 0 or #stdout == 0 then
				callback({})
				return
			end

			local full_json = table.concat(stdout, "\n")
			local ok, tasks = pcall(vim.json.decode, full_json)
			if ok and type(tasks) == "table" then
				callback(tasks)
			else
				callback({})
			end
		end,
	})
end

---Mark a task complete by task number
---@param task_num integer
---@param callback? fun(success: boolean)
function M.complete_task(task_num, callback)
	local todo_file = M.get_todo_file()
	vim.fn.jobstart({ "tuxedo", "do", tostring(task_num) }, {
		env = {
			TODO_FILE = todo_file,
			TODO_DIR = vim.fs.dirname(todo_file),
		},
		on_exit = function(_, exit_code)
			if callback then
				callback(exit_code == 0)
			end
		end,
	})
end

---Open Telescope picker for current project tasks
---@param opts? table
function M.project_todos(opts)
	opts = opts or {}
	local project_tag = opts.project or M.get_project_tag(0)
	local filter_term = "+" .. project_tag

	M.fetch_tasks(filter_term, function(tasks)
		if #tasks == 0 then
			-- Fallback to all tasks if no project specific tasks found
			vim.notify(
				"No tasks found for +" .. project_tag .. ", showing all tasks",
				vim.log.levels.INFO,
				{ title = "Tuxedo" }
			)
			M.all_todos(opts)
			return
		end

		M._open_telescope_picker("Tuxedo Tasks (+" .. project_tag .. ")", tasks)
	end)
end

---Open Telescope picker for all tasks
---@param opts? table
function M.all_todos(opts)
	opts = opts or {}
	M.fetch_tasks(nil, function(tasks)
		if #tasks == 0 then
			vim.notify("No tasks in Tuxedo todo.txt", vim.log.levels.INFO, { title = "Tuxedo" })
			return
		end
		M._open_telescope_picker("Tuxedo All Tasks", tasks)
	end)
end

---Internal Telescope picker constructor
---@param prompt_title string
---@param tasks table[]
function M._open_telescope_picker(prompt_title, tasks)
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local entry_display = require("telescope.pickers.entry_display")

	local displayer = entry_display.create({
		separator = " ",
		items = {
			{ width = 4 }, -- Priority badge
			{ width = 6 }, -- Line/ID #
			{ remaining = true }, -- Description & tags
		},
	})

	local make_display = function(entry)
		local task = entry.value
		local pri = task.priority and ("(" .. task.priority .. ")") or "   "
		local pri_hl = "Comment"
		if task.priority == "A" then
			pri_hl = "DiagnosticError"
		elseif task.priority == "B" then
			pri_hl = "DiagnosticWarn"
		elseif task.priority == "C" then
			pri_hl = "DiagnosticInfo"
		elseif task.priority == "T" then
			pri_hl = "Special"
		end

		local num_str = "#" .. tostring(task.n)

		return displayer({
			{ pri, pri_hl },
			{ num_str, "Comment" },
			{ task.raw, "Normal" },
		})
	end

	pickers
		.new({}, {
			prompt_title = prompt_title,
			finder = finders.new_table({
				results = tasks,
				entry_maker = function(task)
					local filename, lnum = M.parse_file_reference(task.raw)
					return {
						value = task,
						display = make_display,
						ordinal = task.raw,
						filename = filename,
						lnum = lnum,
					}
				end,
			}),
			sorter = conf.generic_sorter({}),
			previewer = conf.qflist_previewer({}),
			attach_mappings = function(prompt_bufnr, map)
				-- Enter: jump to file & line if available
				actions.select_default:replace(function()
					local selection = action_state.get_selected_entry()
					actions.close(prompt_bufnr)

					if selection and selection.filename and selection.lnum then
						vim.cmd.edit(selection.filename)
						vim.api.nvim_win_set_cursor(0, { selection.lnum, 0 })
						vim.cmd("normal! zz")
					elseif selection then
						vim.notify(
							"Selected task #" .. selection.value.n .. ": " .. selection.value.raw,
							vim.log.levels.INFO,
							{ title = "Tuxedo" }
						)
					end
				end)

				-- Ctrl+X or Ctrl+D: Complete task
				local do_complete = function()
					local selection = action_state.get_selected_entry()
					if selection then
						M.complete_task(selection.value.n, function(success)
							if success then
								vim.notify(
									"Task #" .. selection.value.n .. " marked done!",
									vim.log.levels.INFO,
									{ title = "Tuxedo" }
								)
								actions.close(prompt_bufnr)
								-- Re-open refreshed picker
								M.project_todos()
							else
								vim.notify(
									"Failed to complete task #" .. selection.value.n,
									vim.log.levels.ERROR,
									{ title = "Tuxedo" }
								)
							end
						end)
					end
				end

				map("i", "<C-d>", do_complete)
				map("n", "<C-d>", do_complete)
				map("i", "<C-x>", do_complete)
				map("n", "<C-x>", do_complete)

				return true
			end,
		})
		:find()
end

---Open interactive Tuxedo TUI inside a Neovim floating terminal window
function M.open_tui()
	local width = math.floor(vim.o.columns * 0.85)
	local height = math.floor(vim.o.lines * 0.85)
	local col = math.floor((vim.o.columns - width) / 2)
	local row = math.floor((vim.o.lines - height) / 2)

	local buf = vim.api.nvim_create_buf(false, true)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		style = "minimal",
		border = "rounded",
		title = " Tuxedo (todo.txt) ",
		title_pos = "center",
	})

	local todo_file = M.get_todo_file()
	vim.fn.termopen({ "tuxedo", todo_file }, {
		on_exit = function()
			if vim.api.nvim_win_is_valid(win) then
				vim.api.nvim_win_close(win, true)
			end
		end,
	})

	vim.cmd("startinsert")
end

return M
