vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end

vim.g.colors_name = "sylphrena"
vim.o.background = "dark"

local colors = {
  bg = "#031521",
  bg_alt = "#071E2D",
  surface = "#0D2A3A",
  surface_alt = "#123C56",
  fg = "#D9F4FF",
  dim = "#86AFC4",
  blue = "#7FDBFF",
  cyan = "#A8ECFF",
  sapphire = "#4FB6E8",
  green = "#8FE7C0",
  gold = "#E7D37A",
  violet = "#C9B8FF",
  red = "#F08AA3",
}

local function hl(group, spec)
  vim.api.nvim_set_hl(0, group, spec)
end

hl("Normal", { fg = colors.fg, bg = "NONE" })
hl("NormalNC", { fg = colors.fg, bg = "NONE" })
hl("NormalFloat", { fg = colors.fg, bg = colors.bg_alt })
hl("FloatBorder", { fg = colors.blue, bg = colors.bg_alt })
hl("Cursor", { fg = colors.bg, bg = colors.blue })
hl("CursorLine", { bg = colors.bg_alt })
hl("CursorLineNr", { fg = colors.gold, bold = true })
hl("LineNr", { fg = colors.dim })
hl("Visual", { bg = colors.surface_alt })
hl("Search", { fg = colors.bg, bg = colors.gold })
hl("IncSearch", { fg = colors.bg, bg = colors.cyan })
hl("Comment", { fg = colors.dim, italic = true })
hl("String", { fg = colors.green })
hl("Number", { fg = colors.gold })
hl("Boolean", { fg = colors.gold })
hl("Identifier", { fg = colors.fg })
hl("Function", { fg = colors.blue })
hl("Statement", { fg = colors.violet })
hl("Keyword", { fg = colors.violet, italic = true })
hl("Type", { fg = colors.cyan })
hl("Special", { fg = colors.gold })
hl("PreProc", { fg = colors.sapphire })
hl("Error", { fg = colors.red })
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
