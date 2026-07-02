-- =============================================================================
-- Code Runner: Compile & Run Code Instantly
-- =============================================================================
-- Press a key and your code runs immediately in a split terminal.
-- Supports C++, Python, Java, and more.
--
--   Space+rc  → Run current file
--   Space+ri  → Run with input from 'input.txt' (competitive programming!)
--   Space+rj  → Run all test cases from CPOS .samples.json
--   Space+re  → Edit input.txt
--   Space+rv  → View the .samples.json test cases
-- =============================================================================

return {
	"code-runner",
	name = "code-runner",
	dir = vim.fn.stdpath("config") .. "/lua/custom/code-runner",
	event = "VeryLazy",

	config = function()
		-- File type → shell command mapping
		local runners = {
			cpp = "cd '%:p:h' && g++ -std=c++17 -O2 -I$HOME/.local/include -o /tmp/nvim_run '%:p' && /tmp/nvim_run",
			c = "cd '%:p:h' && gcc -std=c11 -O2 -I$HOME/.local/include -o /tmp/nvim_run '%:p' && /tmp/nvim_run",
			python = "cd '%:p:h' && python3 '%:p'",
			java = "cd '%:p:h' && javac '%:p' && java -cp '%:p:h' '%:t:r'",
			javascript = "cd '%:p:h' && node '%:p'",
			typescript = "cd '%:p:h' && npx ts-node '%:p'",
			lua = "cd '%:p:h' && lua '%:p'",
			sh = "cd '%:p:h' && bash '%:p'",
			html = "open '%:p'",
		}

		-- ── Helper: get compile command for a filetype ──────────────────────
		local function get_compile_cmd(ft, filepath, dir)
			if ft == "cpp" then
				return string.format(
					"cd '%s' && g++ -std=c++17 -O2 -I$HOME/.local/include -o /tmp/nvim_run '%s'",
					dir,
					filepath
				)
			elseif ft == "c" then
				return string.format(
					"cd '%s' && gcc -std=c11 -O2 -I$HOME/.local/include -o /tmp/nvim_run '%s'",
					dir,
					filepath
				)
			elseif ft == "python" then
				return nil -- No compile step needed
			elseif ft == "java" then
				return string.format("cd '%s' && javac '%s'", dir, filepath)
			end
			return nil
		end

		-- ── Helper: get run command for a filetype ──────────────────────────
		local function get_run_cmd(ft, filepath, dir)
			if ft == "cpp" or ft == "c" then
				return "/tmp/nvim_run"
			elseif ft == "python" then
				return string.format("python3 '%s'", filepath)
			elseif ft == "java" then
				local classname = vim.fn.fnamemodify(filepath, ":t:r")
				return string.format("java -cp '%s' '%s'", dir, classname)
			end
			return nil
		end

		-- Run current file
		vim.keymap.set("n", "<leader>rc", function()
			local ft = vim.bo.filetype
			local cmd = runners[ft]
			if not cmd then
				vim.notify("No runner configured for filetype: " .. ft, vim.log.levels.WARN)
				return
			end
			-- Save first, then run in a horizontal split terminal
			vim.cmd("w")
			vim.cmd("belowright 15split | terminal " .. cmd)
			vim.cmd("startinsert")
		end, { desc = "Run: Current file" })

		-- Run with input.txt (for competitive programming)
		vim.keymap.set("n", "<leader>ri", function()
			local ft = vim.bo.filetype
			local dir = vim.fn.expand("%:p:h")
			local input_file = dir .. "/input.txt"
			local cmd

			if ft == "cpp" then
				cmd = string.format(
					"cd '%s' && g++ -std=c++17 -O2 -I$HOME/.local/include -o /tmp/nvim_run '%s' && /tmp/nvim_run < '%s'",
					dir,
					vim.fn.expand("%:p"),
					input_file
				)
			elseif ft == "python" then
				cmd = string.format("cd '%s' && python3 '%s' < '%s'", dir, vim.fn.expand("%:p"), input_file)
			elseif ft == "c" then
				cmd = string.format(
					"cd '%s' && gcc -std=c11 -O2 -I$HOME/.local/include -o /tmp/nvim_run '%s' && /tmp/nvim_run < '%s'",
					dir,
					vim.fn.expand("%:p"),
					input_file
				)
			elseif ft == "java" then
				cmd = string.format(
					"cd '%s' && javac '%s' && java -cp '%s' '%s' < '%s'",
					dir,
					vim.fn.expand("%:p"),
					dir,
					vim.fn.expand("%:t:r"),
					input_file
				)
			else
				vim.notify("No input runner for filetype: " .. ft, vim.log.levels.WARN)
				return
			end

			vim.cmd("w")
			vim.cmd("belowright 15split | terminal " .. cmd)
			vim.cmd("startinsert")
		end, { desc = "Run: With input.txt" })

		-- ── Run with CPOS .samples.json test cases ──────────────────────────
		-- Reads the <filename>.samples.json, compiles once, then runs the
		-- binary against each test case, comparing output to expected_output.
		-- Results are shown in a scratch buffer with PASS/FAIL and diffs.
		vim.keymap.set("n", "<leader>rj", function()
			local ft = vim.bo.filetype
			local filepath = vim.fn.expand("%:p")
			local dir = vim.fn.expand("%:p:h")
			local json_file = filepath .. ".samples.json"

			-- Check if the JSON file exists
			if vim.fn.filereadable(json_file) == 0 then
				vim.notify("No samples file found: " .. vim.fn.fnamemodify(json_file, ":t"), vim.log.levels.WARN)
				return
			end

			-- Read and parse JSON
			local json_content = table.concat(vim.fn.readfile(json_file), "\n")
			local ok, samples = pcall(vim.fn.json_decode, json_content)
			if not ok or type(samples) ~= "table" then
				vim.notify("Failed to parse samples JSON", vim.log.levels.ERROR)
				return
			end

			if #samples == 0 then
				vim.notify("No test cases found in samples file", vim.log.levels.WARN)
				return
			end

			-- Save first
			vim.cmd("w")

			-- Compile
			local compile_cmd = get_compile_cmd(ft, filepath, dir)
			if compile_cmd then
				vim.notify("Compiling...", vim.log.levels.INFO)
				local compile_result = vim.fn.system(compile_cmd)
				if vim.v.shell_error ~= 0 then
					-- Show compilation errors in a scratch buffer
					local lines = {
						"╔══════════════════════════════════════╗",
					}
					table.insert(lines, "║  ✗ COMPILATION ERROR                 ║")
					table.insert(
						lines,
						"╚══════════════════════════════════════╝"
					)
					table.insert(lines, "")
					for _, line in ipairs(vim.split(compile_result, "\n")) do
						table.insert(lines, line)
					end
					-- Open results buffer
					vim.cmd("belowright 20split")
					local buf = vim.api.nvim_create_buf(false, true)
					vim.api.nvim_win_set_buf(0, buf)
					vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
					vim.bo[buf].filetype = "coderunner-results"
					vim.bo[buf].bufhidden = "wipe"
					vim.bo[buf].modifiable = false
					-- Press q to close
					vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, desc = "Close results" })
					return
				end
			end

			-- Get run command
			local run_cmd = get_run_cmd(ft, filepath, dir)
			if not run_cmd then
				vim.notify("No JSON test runner for filetype: " .. ft, vim.log.levels.WARN)
				return
			end

			-- Run each test case
			local results = {}
			local total_pass = 0
			local total_fail = 0

			for i, sample in ipairs(samples) do
				local input = sample.input or ""
				local expected = sample.expected_output or ""

				-- Write input to a temp file
				local tmp_input = "/tmp/nvim_test_input_" .. i
				vim.fn.writefile(vim.split(input, "\n"), tmp_input)

				-- Run with input
				local full_cmd = string.format("cd '%s' && %s < '%s' 2>&1", dir, run_cmd, tmp_input)
				local actual = vim.fn.system(full_cmd)
				local exit_code = vim.v.shell_error

				-- Clean up trailing whitespace/newlines for comparison
				local function normalize(s)
					-- Trim trailing whitespace from each line, then trim trailing newlines
					s = s or ""
					local lines = vim.split(s, "\n")
					local cleaned = {}
					for _, line in ipairs(lines) do
						cleaned[#cleaned + 1] = line:gsub("%s+$", "")
					end
					-- Remove trailing empty lines
					while #cleaned > 0 and cleaned[#cleaned] == "" do
						table.remove(cleaned)
					end
					return table.concat(cleaned, "\n")
				end

				local norm_actual = normalize(actual)
				local norm_expected = normalize(expected)
				local passed = (exit_code == 0) and (norm_actual == norm_expected)

				if passed then
					total_pass = total_pass + 1
				else
					total_fail = total_fail + 1
				end

				table.insert(results, {
					index = i,
					passed = passed,
					exit_code = exit_code,
					input = input,
					expected = expected,
					actual = actual,
				})

				-- Clean up temp file
				vim.fn.delete(tmp_input)
			end

			-- Format results into a display buffer
			local lines = {}
			local total = #samples
			local status_icon = total_fail == 0 and "✓" or "✗"
			local status_text = total_fail == 0 and "ALL PASSED" or (total_fail .. " FAILED")

			table.insert(
				lines,
				"╔══════════════════════════════════════╗"
			)
			table.insert(
				lines,
				string.format("║  %s  %d/%d tests  —  %s", status_icon, total_pass, total, status_text)
			)
			table.insert(
				lines,
				"╚══════════════════════════════════════╝"
			)
			table.insert(lines, "")

			for _, r in ipairs(results) do
				local icon = r.passed and "✓ PASS" or "✗ FAIL"
				table.insert(
					lines,
					string.format(
						"── Test %d: %s ──────────────────────",
						r.index,
						icon
					)
				)

				if not r.passed then
					table.insert(lines, "  Input:")
					for _, l in ipairs(vim.split(r.input, "\n")) do
						table.insert(lines, "    " .. l)
					end
					table.insert(lines, "  Expected:")
					for _, l in ipairs(vim.split(r.expected, "\n")) do
						table.insert(lines, "    " .. l)
					end
					table.insert(lines, "  Got:")
					for _, l in ipairs(vim.split(vim.trim(r.actual), "\n")) do
						table.insert(lines, "    " .. l)
					end
					if r.exit_code ~= 0 then
						table.insert(lines, string.format("  Exit code: %d", r.exit_code))
					end
				end

				table.insert(lines, "")
			end

			-- Show in a scratch buffer
			vim.cmd("belowright 20split")
			local buf = vim.api.nvim_create_buf(false, true)
			vim.api.nvim_win_set_buf(0, buf)
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
			vim.bo[buf].filetype = "coderunner-results"
			vim.bo[buf].bufhidden = "wipe"
			vim.bo[buf].modifiable = false
			-- Press q to close the results
			vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, desc = "Close results" })

			-- Notify
			if total_fail == 0 then
				vim.notify(string.format("All %d test(s) passed! ✓", total), vim.log.levels.INFO)
			else
				vim.notify(string.format("%d/%d test(s) failed ✗", total_fail, total), vim.log.levels.WARN)
			end
		end, { desc = "Run: Test with CPOS samples.json" })

		-- ── View .samples.json ──────────────────────────────────────────────
		-- Quickly open the associated .samples.json file in a split
		vim.keymap.set("n", "<leader>rv", function()
			local json_file = vim.fn.expand("%:p") .. ".samples.json"
			if vim.fn.filereadable(json_file) == 0 then
				vim.notify("No samples file found: " .. vim.fn.fnamemodify(json_file, ":t"), vim.log.levels.WARN)
				return
			end
			vim.cmd("belowright 15split " .. vim.fn.fnameescape(json_file))
		end, { desc = "Run: View samples.json" })

		-- Quick create/edit input.txt in the same directory
		vim.keymap.set("n", "<leader>re", function()
			local dir = vim.fn.expand("%:p:h")
			vim.cmd("edit " .. dir .. "/input.txt")
		end, { desc = "Run: Edit input.txt" })

		-- ── Quick test-case toggle ──────────────────────────────────────────
		vim.keymap.set("n", "<leader>rt", function()
			if vim.bo.filetype ~= "cpp" then
				vim.notify("Test-case toggle is only supported for C++", vim.log.levels.WARN)
				return
			end

			-- Find the line with 'cin >> T'
			local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
			local found = false
			for i, line in ipairs(lines) do
				if line:match("cin%s*>>%s*T") then
					-- Toggle comment
					if line:match("^%s*//") then
						-- Uncomment
						lines[i] = line:gsub("^%s*//%s*", "")
						vim.notify("Multi-test mode ENABLED", vim.log.levels.INFO)
					else
						-- Comment
						-- preserve indentation
						local indent = line:match("^%s*")
						lines[i] = indent .. "// " .. line:gsub("^%s*", "")
						vim.notify("Single-test mode ENABLED", vim.log.levels.INFO)
					end
					vim.api.nvim_buf_set_lines(0, i - 1, i, false, { lines[i] })
					found = true
					break
				end
			end

			if not found then
				vim.notify("Could not find 'cin >> T' in file", vim.log.levels.WARN)
			end
		end, { desc = "Run: Toggle test cases (T)" })
	end,
}
