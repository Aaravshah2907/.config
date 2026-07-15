-- =============================================================================
-- Autocommands — Things That Happen Automatically
-- =============================================================================
-- Autocommands (autocmds) are like "triggers" — when something happens
-- (you save a file, open a file, yank text), Neovim runs code automatically.
-- =============================================================================

local augroup = vim.api.nvim_create_augroup -- Create a group of autocmds
local autocmd = vim.api.nvim_create_autocmd -- Create an autocmd

-- ─── Flash Yanked Text ──────────────────────────────────────────────────────
-- When you yank (copy) text, briefly highlight it so you can SEE what
-- was copied. Super helpful when you're learning Vim motions!
augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
	group = "YankHighlight",
	callback = function()
		vim.highlight.on_yank({
			higroup = "IncSearch", -- Use the search highlight color
			timeout = 1000, -- Flash for 200ms
		})
	end,
	desc = "Briefly highlight yanked text",
})

-- ─── Remove Trailing Whitespace ─────────────────────────────────────────────
-- Automatically clean up invisible trailing spaces when you save.
-- These spaces cause messy diffs in git and serve no purpose.
augroup("TrimWhitespace", { clear = true })
autocmd("BufWritePre", {
	group = "TrimWhitespace",
	pattern = "*",
	command = [[%s/\s\+$//e]],
	desc = "Remove trailing whitespace on save",
})

-- ─── Return to Last Edit Position ───────────────────────────────────────────
-- When you reopen a file, jump back to where your cursor was last time.
-- (Neovim remembers this in its shada file.)
augroup("RestoreCursor", { clear = true })
autocmd("BufReadPost", {
	group = "RestoreCursor",
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local line_count = vim.api.nvim_buf_line_count(0)
		if mark[1] > 0 and mark[1] <= line_count then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
	desc = "Go to last cursor position when opening a file",
})

-- ─── Auto-Resize Splits ─────────────────────────────────────────────────────
-- When you resize your terminal window, automatically resize all
-- Neovim split windows to keep them proportional.
augroup("ResizeSplits", { clear = true })
autocmd("VimResized", {
	group = "ResizeSplits",
	callback = function()
		vim.cmd("tabdo wincmd =")
	end,
	desc = "Auto-resize splits when terminal is resized",
})

-- ─── :O Command (Open File) ─────────────────────────────────────────────
-- Neovim doesn't have :o or :open. Add :O as a convenient alias for :edit.
vim.api.nvim_create_user_command("O", function(opts)
	vim.cmd("edit " .. opts.args)
end, { nargs = "?", complete = "file", desc = "Open a file (alias for :edit)" })

-- ─── Auto-Compile on Save ───────────────────────────────────────────────
-- Compiles C++ files in the background on save. Errors are populated in the Quickfix list.
augroup("AutoCompile", { clear = true })

-- Set makeprg for cpp files to use our compile command
autocmd("FileType", {
	group = "AutoCompile",
	pattern = "cpp",
	callback = function()
		vim.opt_local.makeprg = "g++ -std=c++17 -O2 -I$HOME/.local/include -o /tmp/nvim_run %"
	end,
})

-- Async Auto-compile C++ on save
autocmd("BufWritePost", {
	group = "AutoCompile",
	pattern = "*.cpp",
	callback = function(args)
		local makeprg = vim.bo[args.buf].makeprg
		local efm = vim.bo[args.buf].errorformat
		if makeprg == "" then
			return
		end

		local expanded_cmd = vim.fn.expandcmd(makeprg)

		local lines = {}
		vim.fn.jobstart(expanded_cmd, {
			stdout_buffered = true,
			stderr_buffered = true,
			on_stderr = function(_, data)
				if data then
					for _, line in ipairs(data) do
						if line ~= "" then
							table.insert(lines, line)
						end
					end
				end
			end,
			on_exit = function(_, code)
				if code == 0 then
					vim.fn.setqflist({}, "r", { title = "Compile Errors" })
					vim.notify("Compiled successfully ✓", vim.log.levels.INFO)
					vim.cmd("cclose")
				else
					vim.fn.setqflist(
						{},
						"r",
						{ title = "Compile Errors", lines = lines, efm = efm }
					)
					vim.notify("Compilation failed ✗", vim.log.levels.ERROR)
					vim.cmd("copen")
				end
			end,
		})
	end,
	desc = "Async Auto-compile C++ on save",
})

-- ─── Filetype-Specific Settings ─────────────────────────────────────────────
-- Different languages have different conventions:
--   • Java: 4 spaces per indent (Google/Oracle style)
--   • Markdown: Enable word wrap so long paragraphs are readable
augroup("FileTypeSettings", { clear = true })

autocmd("FileType", {
	group = "FileTypeSettings",
	pattern = "java",
	callback = function()
		vim.opt_local.shiftwidth = 4
		vim.opt_local.tabstop = 4
	end,
	desc = "Use 4-space indentation for Java",
})

autocmd("FileType", {
	group = "FileTypeSettings",
	pattern = "markdown",
	callback = function()
		vim.opt_local.wrap = true -- Wrap long lines in markdown
		vim.opt_local.linebreak = true -- Wrap at word boundaries, not mid-word
		vim.opt_local.spell = true -- Enable spell checking
	end,
	desc = "Markdown-friendly settings (wrap, spell check)",
})

-- ─── File Templates (Competitive Programming) ───────────────────────────
-- Automatically load a template when creating a new C++ or Python file.
-- Also handles files created externally (e.g. by CPOS) that exist but are
-- empty — BufNewFile only fires for files that don't exist on disk, so we
-- also hook BufRead to catch empty existing files.

augroup("Templates", { clear = true })

-- Templates to load: { pattern, template_path }
local templates = {
	{ "*.cpp", "~/.config/nvim/templates/skeleton.cpp" },
	{ "*.py", "~/.config/nvim/templates/skeleton.py" },
}

for _, tpl in ipairs(templates) do
	local pattern, template_path = tpl[1], tpl[2]

	-- Case 1: File doesn't exist on disk (`:e newfile.cpp`)
	autocmd("BufNewFile", {
		group = "Templates",
		pattern = pattern,
		command = "0r " .. template_path,
		desc = "Load template for new " .. pattern .. " files",
	})

	-- Case 2: File exists on disk but is empty (created by CPOS, touch, etc.)
	autocmd("BufRead", {
		group = "Templates",
		pattern = pattern,
		callback = function()
			-- Only insert template if the buffer is completely empty
			if vim.api.nvim_buf_line_count(0) == 1 and vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] == "" then
				vim.cmd("0r " .. template_path)
				-- Mark the buffer as modified so the user knows to save
				vim.bo.modified = true
			end
		end,
		desc = "Load template for empty existing " .. pattern .. " files",
	})
end
