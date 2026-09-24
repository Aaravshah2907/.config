vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end

vim.g.colors_name = "sylphrena"
vim.o.background = "dark"

-- Sylphrena & Kaladin / Windrunner Honor palette
local colors = {
  bg = "#090D16",            -- Wretch Shadow (Deep background)
  bg_alt = "#0F172A",        -- Kholinar Navy (Panels/Float background)
  surface = "#1E293B",       -- Stormblessed Charcoal (Selection & Surface)
  surface_alt = "#334155",   -- Highstorm Thunder Gray (Elevated surface / borders)
  fg = "#F0F8FF",            -- Stormlight Core White (Primary text)
  dim = "#94A3B8",           -- Spearhead Steel (Muted text / comments)
  blue = "#00E5FF",          -- Honorspren Luminous Cyan (Primary accent / functions)
  cyan = "#A5F3FC",          -- Windrunner Vapor (Types / info)
  cobalt = "#1D4ED8",        -- Bridge Four Cobalt (Secondary accent)
  radiant_blue = "#38BDF8",  -- Radiant Syl Blue (Strings / highlights)
  sapphire = "#0284C7",      -- Ancient Daughter Sapphire (PreProc / Directory)
  gold = "#FACC15",          -- Gloryspren Shimmer (Warnings / numbers)
  red = "#991B1B",           -- Shash Brand Crimson (Errors / diagnostics)
  orange = "#F97316",        -- Lover of Leaves Amber (Special accents)
}

local function hl(group, spec)
  vim.api.nvim_set_hl(0, group, spec)
end

-- Editor Core
hl("Normal", { fg = colors.fg, bg = "NONE" })
hl("NormalNC", { fg = colors.fg, bg = "NONE" })
hl("NormalFloat", { fg = colors.fg, bg = colors.bg_alt })
hl("FloatBorder", { fg = colors.blue, bg = colors.bg_alt })
hl("Cursor", { fg = colors.bg, bg = colors.blue })
hl("CursorLine", { bg = colors.bg_alt })
hl("CursorLineNr", { fg = colors.gold, bold = true })
hl("LineNr", { fg = colors.dim })
hl("Visual", { bg = colors.surface })
hl("Search", { fg = colors.bg, bg = colors.gold })
hl("IncSearch", { fg = colors.bg, bg = colors.blue })

-- Syntax Highlighting
hl("Comment", { fg = colors.dim, italic = true })
hl("String", { fg = colors.radiant_blue })
hl("Number", { fg = colors.gold })
hl("Boolean", { fg = colors.gold })
hl("Identifier", { fg = colors.fg })
hl("Function", { fg = colors.blue, bold = true })
hl("Statement", { fg = colors.cobalt })
hl("Keyword", { fg = colors.blue, italic = true })
hl("Type", { fg = colors.cyan })
hl("Special", { fg = colors.orange })
hl("PreProc", { fg = colors.sapphire })
hl("Error", { fg = colors.red })

-- Diagnostics & UI Elements
hl("DiagnosticError", { fg = colors.red })
hl("DiagnosticWarn", { fg = colors.gold })
hl("DiagnosticInfo", { fg = colors.blue })
hl("DiagnosticHint", { fg = colors.cyan })
hl("Directory", { fg = colors.blue })
hl("WinSeparator", { fg = colors.surface_alt })
hl("Pmenu", { fg = colors.fg, bg = colors.bg_alt })
hl("PmenuSel", { fg = colors.bg, bg = colors.blue })
hl("TelescopeBorder", { fg = colors.blue, bg = "NONE" })
hl("TelescopeSelection", { fg = colors.fg, bg = colors.surface })
hl("StatusLine", { fg = colors.fg, bg = colors.surface })
hl("StatusLineNC", { fg = colors.dim, bg = colors.bg_alt })
hl("TabLineSel", { fg = colors.bg, bg = colors.blue, bold = true })
hl("TabLine", { fg = colors.dim, bg = colors.bg_alt })
