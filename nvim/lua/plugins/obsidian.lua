-- =============================================================================
-- Obsidian.nvim: Note-Taking Powered by Obsidian Vaults
-- =============================================================================
-- If you love Obsidian (the note-taking app), this plugin lets you
-- manage your vault directly from Neovim! Features:
--   • Create and search notes (Space+on, Space+os)
--   • Daily notes (Space+od)
--   • Follow [[wiki links]] with gf
--   • Autocompletion for note links
--
-- Your vault is at: ~/obsidian-vault
-- If you also use the Obsidian GUI app, both can work on the same vault!
-- =============================================================================

return {
  "epwalsh/obsidian.nvim",
  version = "*",
  dependencies = { "nvim-lua/plenary.nvim" },

  -- Only load for markdown files (saves startup time)
  ft = "markdown",

  config = function()
    require("obsidian").setup({
      -- ── Vault Location ─────────────────────────────────────────────
      -- This is the folder where all your notes live.
      -- If it doesn't exist yet, create it: mkdir ~/obsidian-vault
      workspaces = {
        {
          name = "notes",
          path = vim.fn.expand("~/obsidian-vault"),
        },
      },

      -- ── Daily Notes ────────────────────────────────────────────────
      -- A daily note is created for each day. Great for journaling,
      -- meeting notes, or daily TODO lists.
      daily_notes = {
        folder = "daily",            -- Stored in ~/obsidian-vault/daily/
        date_format = "%Y-%m-%d",    -- File name format: 2025-01-15.md
        template = nil,              -- Optional: path to a template file
      },

      -- ── Note IDs ───────────────────────────────────────────────────
      -- When you create a new note, use the title as the filename
      -- instead of generating a random ID. Much more readable!
      note_id_func = function(title)
        if title ~= nil then
          -- Replace spaces with hyphens and remove special characters
          return title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
        else
          -- If no title given, use a timestamp
          return tostring(os.time())
        end
      end,

      -- ── Completion ─────────────────────────────────────────────────
      -- Enable autocompletion for note links when you type [[
      completion = {
        nvim_cmp = true,     -- Integrate with nvim-cmp
        min_chars = 2,       -- Start suggesting after 2 characters
      },

      -- ── UI ─────────────────────────────────────────────────────────
      ui = {
        enable = true,
        checkboxes = {
          [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
          ["x"] = { char = "", hl_group = "ObsidianDone" },
        },
      },
    })

    -- ── Keymaps (only active in markdown files) ──────────────────────
    -- All Obsidian keymaps start with <leader>o (o = Obsidian)
    local map = vim.keymap.set
    map("n", "<leader>on", "<cmd>ObsidianNew<cr>",          { desc = "Obsidian: New note" })
    map("n", "<leader>oo", "<cmd>ObsidianQuickSwitch<cr>",  { desc = "Obsidian: Quick switch" })
    map("n", "<leader>os", "<cmd>ObsidianSearch<cr>",       { desc = "Obsidian: Search notes" })
    map("n", "<leader>od", "<cmd>ObsidianToday<cr>",        { desc = "Obsidian: Today's note" })
    map("n", "<leader>ob", "<cmd>ObsidianBacklinks<cr>",    { desc = "Obsidian: Backlinks" })
    map("n", "<leader>ol", "<cmd>ObsidianLinks<cr>",        { desc = "Obsidian: Links" })
    map("n", "<leader>ot", "<cmd>ObsidianTags<cr>",         { desc = "Obsidian: Tags" })
  end,
}
