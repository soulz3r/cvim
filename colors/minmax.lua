-- Classic monochrome phosphor-green terminal palette.
vim.opt.background = "dark"
vim.g.colors_name = "minmax"

local c = {
	bg = "#020b05",
	bg_alt = "#07150a",
	green = "#75ff75",
	bright = "#b4ff9b",
	mid = "#45bd59",
	dim = "#287a3b",
	muted = "#174d29",
	red = "#ff6b6b",
	yellow = "#d5e86a",
	black = "#000000",
}

vim.api.nvim_set_hl(0, "Normal", { fg = c.green, bg = c.bg })
vim.api.nvim_set_hl(0, "NormalNC", { fg = c.green, bg = c.bg })
vim.api.nvim_set_hl(0, "EndOfBuffer", { fg = c.muted, bg = c.bg })
vim.api.nvim_set_hl(0, "Cursor", { fg = c.bg, bg = c.bright })
vim.api.nvim_set_hl(0, "CursorLine", { bg = c.bg_alt })
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = c.bright, bold = true })
vim.api.nvim_set_hl(0, "LineNr", { fg = c.dim })
vim.api.nvim_set_hl(0, "SignColumn", { fg = c.green, bg = c.bg })
vim.api.nvim_set_hl(0, "Visual", { fg = c.bright, bg = c.muted })
vim.api.nvim_set_hl(0, "Search", { fg = c.black, bg = c.yellow })
vim.api.nvim_set_hl(0, "IncSearch", { fg = c.black, bg = c.bright, bold = true })
vim.api.nvim_set_hl(0, "MatchParen", { fg = c.bright, bg = c.muted, bold = true })
vim.api.nvim_set_hl(0, "Pmenu", { fg = c.green, bg = c.bg_alt })
vim.api.nvim_set_hl(0, "PmenuSel", { fg = c.black, bg = c.mid, bold = true })
vim.api.nvim_set_hl(0, "FloatBorder", { fg = c.mid, bg = c.bg_alt })
vim.api.nvim_set_hl(0, "NormalFloat", { fg = c.green, bg = c.bg_alt })
vim.api.nvim_set_hl(0, "Title", { fg = c.bright, bold = true })
vim.api.nvim_set_hl(0, "Directory", { fg = c.bright, bold = true })
vim.api.nvim_set_hl(0, "Comment", { fg = c.dim, italic = true })
vim.api.nvim_set_hl(0, "Constant", { fg = c.bright })
vim.api.nvim_set_hl(0, "String", { fg = c.mid })
vim.api.nvim_set_hl(0, "Character", { fg = c.mid })
vim.api.nvim_set_hl(0, "Number", { fg = c.bright })
vim.api.nvim_set_hl(0, "Boolean", { fg = c.bright })
vim.api.nvim_set_hl(0, "Identifier", { fg = c.green })
vim.api.nvim_set_hl(0, "Function", { fg = c.bright })
vim.api.nvim_set_hl(0, "Statement", { fg = c.green, bold = true })
vim.api.nvim_set_hl(0, "Keyword", { fg = c.green, bold = true })
vim.api.nvim_set_hl(0, "Type", { fg = c.mid })
vim.api.nvim_set_hl(0, "PreProc", { fg = c.mid })
vim.api.nvim_set_hl(0, "Special", { fg = c.bright })
vim.api.nvim_set_hl(0, "Delimiter", { fg = c.mid })
vim.api.nvim_set_hl(0, "DiagnosticError", { fg = c.red })
vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = c.yellow })
vim.api.nvim_set_hl(0, "DiagnosticInfo", { fg = c.mid })
vim.api.nvim_set_hl(0, "DiagnosticHint", { fg = c.dim })
vim.api.nvim_set_hl(0, "DiagnosticFloatingError", { fg = c.red })
vim.api.nvim_set_hl(0, "DiagnosticFloatingWarn", { fg = c.yellow })
vim.api.nvim_set_hl(0, "DiagnosticFloatingInfo", { fg = c.mid })
vim.api.nvim_set_hl(0, "DiagnosticFloatingHint", { fg = c.dim })
vim.api.nvim_set_hl(0, "Error", { fg = c.red, bold = true })
vim.api.nvim_set_hl(0, "ErrorMsg", { fg = c.red, bold = true })
vim.api.nvim_set_hl(0, "WarningMsg", { fg = c.yellow, bold = true })
vim.api.nvim_set_hl(0, "StatusLine", { fg = c.green, bg = c.bg })
vim.api.nvim_set_hl(0, "StatusLineNC", { fg = c.dim, bg = c.bg })
