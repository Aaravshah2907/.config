-- =============================================================================
-- UFO (Ultra Fold Object): High Performance Code Folding
-- =============================================================================

return {
	{
		"kevinhwang91/nvim-ufo",
		dependencies = {
			"kevinhwang91/promise-async",
			"nvim-treesitter/nvim-treesitter",
		},
		event = { "BufReadPost", "BufNewFile" },
		init = function()
			-- Fold options required for UFO
			vim.o.foldcolumn = "1"
			vim.o.foldlevel = 99
			vim.o.foldlevelstart = 99
			vim.o.foldenable = true
		end,
		config = function()
			local ufo = require("ufo")

			-- Custom virtual text handler for fold preview line counts
			local handler = function(virtText, lnum, endLnum, width, truncate)
				local newVirtText = {}
				local suffix = (" 󰁂 %d "):format(endLnum - lnum)
				local sufWidth = vim.fn.strdisplaywidth(suffix)
				local targetWidth = width - sufWidth
				local curWidth = 0
				for _, chunk in ipairs(virtText) do
					local chunkText = chunk[1]
					local chunkWidth = vim.fn.strdisplaywidth(chunkText)
					if targetWidth > curWidth + chunkWidth then
						table.insert(newVirtText, chunk)
					else
						chunkText = truncate(chunkText, targetWidth - curWidth)
						local hlGroup = chunk[2]
						table.insert(newVirtText, { chunkText, hlGroup })
						curWidth = curWidth + vim.fn.strdisplaywidth(chunkText)
						if curWidth < targetWidth then
							suffix = suffix .. (" "):rep(targetWidth - curWidth)
						end
						break
					end
					curWidth = curWidth + chunkWidth
				end
				table.insert(newVirtText, { suffix, "MoreMsg" })
				return newVirtText
			end

			ufo.setup({
				fold_virt_text_handler = handler,
				provider_selector = function()
					return { "treesitter", "indent" }
				end,
			})

			-- Keymaps for folding
			local map = vim.keymap.set
			map("n", "zR", ufo.openAllFolds, { desc = "Open all folds" })
			map("n", "zM", ufo.closeAllFolds, { desc = "Close all folds" })
			map("n", "zr", ufo.openFoldsExceptKinds, { desc = "Open folds except kinds" })
			map("n", "zm", ufo.closeFoldsWith, { desc = "Close folds with level" })
			map("n", "K", function()
				local winid = ufo.peekFoldedLinesUnderCursor()
				if not winid then
					vim.lsp.buf.hover()
				end
			end, { desc = "Hover doc / Peek fold" })
		end,
	},
}
