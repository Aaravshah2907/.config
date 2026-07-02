-- ============================================================================
-- init.lua — The Entry Point for Your Neovim Config
-- ============================================================================
-- This file runs first when Neovim starts. Think of it like the "main()"
-- function for your editor. It does 4 things:
--   1. Sets the leader key (your personal shortcut prefix)
--   2. Loads your core settings (options, keymaps, autocommands)
--   3. Installs the plugin manager (lazy.nvim) if it's missing
--   4. Loads all your plugins and sets the colorscheme
-- ============================================================================

-- ────────────────────────────────────────────────────────────────────────────
-- 1. SET THE LEADER KEY — Do this BEFORE loading plugins!
-- ────────────────────────────────────────────────────────────────────────────
-- The "leader" key is a prefix for your custom shortcuts. When you press
-- Space followed by another key, Neovim treats it as a custom command.
-- Example: <Space>w will save the file (we set that up in keymaps.lua).
--
-- We set this FIRST because some plugins read the leader key when they load.
-- If we set it after, those plugins would use the wrong key.
vim.g.mapleader = " "       -- Space as the leader key
vim.g.maplocalleader = " "  -- Same for buffer-local leader (used by some plugins)
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true }) -- Prevent space from moving cursor
-- ────────────────────────────────────────────────────────────────────────────
-- 2. LOAD CORE SETTINGS
-- ────────────────────────────────────────────────────────────────────────────
-- These files live in lua/core/. Neovim automatically looks in the lua/
-- directory when you call require(), so "core.options" means:
--   ~/.config/nvim/lua/core/options.lua
require("core.options")    -- Editor behavior: tabs, line numbers, etc.
require("core.keymaps")    -- Your keyboard shortcuts
require("core.autocmds")   -- Automatic actions (like "flash text when copied")

-- ────────────────────────────────────────────────────────────────────────────
-- 3. BOOTSTRAP LAZY.NVIM (Plugin Manager)
-- ────────────────────────────────────────────────────────────────────────────
-- lazy.nvim is the modern Neovim plugin manager. This block does:
--   - Checks if lazy.nvim is already installed
--   - If NOT, clones it from GitHub automatically
--   - Adds it to Neovim's runtime path so we can use it
--
-- You'll never need to manually install lazy.nvim — this handles it for you.
-- On your first launch, you'll see it downloading. After that, it's instant.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  -- lazy.nvim isn't installed yet, so clone it from GitHub
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",                             -- Don't download file history (faster)
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",                                -- Use the latest stable release
    lazypath,
  })
end

-- Add lazy.nvim to the runtime path so Neovim can find it
-- (prepend so it loads before anything else)
vim.opt.rtp:prepend(lazypath)

-- ────────────────────────────────────────────────────────────────────────────
-- 4. LOAD PLUGINS
-- ────────────────────────────────────────────────────────────────────────────
-- This tells lazy.nvim to look for plugin specs in the lua/plugins/ directory.
-- Each file in that folder (like plugins/editor.lua, plugins/ui.lua) returns
-- a table describing which plugins to install and how to configure them.
--
-- lazy.nvim will:
--   - Automatically install any missing plugins
--   - Load them in the right order
--   - Handle updates when you run :Lazy update
require("lazy").setup({
  -- Import all plugin spec files from lua/plugins/*.lua
  spec = {
    { import = "plugins" },
  },

  -- These are lazy.nvim's own settings (not plugin settings)
  defaults = {
    lazy = false,  -- Don't lazy-load by default (simpler to understand)
  },

  install = {
    -- When installing plugins for the first time, use this colorscheme
    -- so things look nice even before your theme plugin loads
    colorscheme = { "catppuccin-mocha" },
  },

  checker = {
    enabled = true,   -- Automatically check for plugin updates
    notify = false,   -- Don't pop up a notification every time
  },

  change_detection = {
    notify = false,   -- Don't notify when config files change
  },
})

-- ────────────────────────────────────────────────────────────────────────────
-- 5. SET THE COLORSCHEME
-- ────────────────────────────────────────────────────────────────────────────
-- Catppuccin Mocha is a beautiful dark theme with warm, easy-on-the-eyes
-- colors. We set it here AFTER plugins load so the theme is available.
--
-- If the colorscheme isn't installed yet (first run), this will silently
-- fall back to Neovim's default — no ugly error messages.
vim.cmd.colorscheme("catppuccin-mocha")
