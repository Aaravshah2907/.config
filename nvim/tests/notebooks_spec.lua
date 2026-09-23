-- tests/notebooks_spec.lua
-- Automated unit and integration test suite for Neovim notebook plugin setup

describe("nvim notebook plugin integration", function()
	local notebooks = require("plugins.notebooks")

	it("returns a list of 3 plugin specifications", function()
		assert.are.same(#notebooks, 3)
	end)

	it("configures jupytext.nvim with filetype and user command", function()
		local jupytext_spec = notebooks[1]
		assert.are.same(jupytext_spec[1], "GCBallesteros/jupytext.nvim")
		assert.is_function(jupytext_spec.init)
		assert.is_function(jupytext_spec.config)
	end)

	it("configures molten-nvim lazy keymaps correctly", function()
		local molten_spec = notebooks[2]
		assert.are.same(molten_spec[1], "benlubas/molten-nvim")
		assert.is_table(molten_spec.keys)
		assert.are.same(#molten_spec.keys, 7)

		local key_lhs_set = {}
		local normal_jr, visual_jr = nil, nil
		for _, keymap in ipairs(molten_spec.keys) do
			if keymap[1] == "<leader>jr" then
				if keymap.mode == "v" then
					visual_jr = keymap[2]
				else
					normal_jr = keymap[2]
				end
			end
			key_lhs_set[keymap[1]] = keymap[2]
		end

		assert.are.same(normal_jr, "<cmd>MoltenEvaluateOperator<cr>")
		assert.are.same(visual_jr, ":<c-u>MoltenEvaluateVisual<cr>gv")
		assert.are.same(key_lhs_set["<leader>ji"], "<cmd>MoltenInit<cr>")
		assert.are.same(key_lhs_set["<leader>jrr"], "<cmd>MoltenEvaluateLine<cr>")
		assert.are.same(key_lhs_set["<leader>jo"], "<cmd>MoltenShowOutput<cr>")
		assert.are.same(key_lhs_set["<leader>jh"], "<cmd>MoltenHideOutput<cr>")
		assert.are.same(key_lhs_set["<leader>jd"], "<cmd>MoltenDelete<cr>")
	end)

	it("configures iron.nvim python REPL integration", function()
		local iron_spec = notebooks[3]
		assert.are.same(iron_spec[1], "Vigemus/iron.nvim")
		assert.is_function(iron_spec.config)
	end)
end)
