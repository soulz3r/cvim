-- Global presentation defaults. Keep the UI transparent, with visible borders.
vim.opt.cmdheight = 1
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.pumheight = 10
vim.opt.pumborder = "rounded"
vim.opt.pumblend = 0

vim.opt.showmode = false
vim.opt.showtabline = 0
vim.opt.laststatus = 0
vim.opt.showcmd = false
vim.opt.ruler = false

vim.opt.cursorline = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.numberwidth = 2
vim.opt.signcolumn = "yes"

vim.opt.wrap = false
vim.opt.scrolloff = 4
vim.opt.sidescrolloff = 8

vim.opt.termguicolors = true
vim.opt.guifont = "ComicShannsMono Nerd Font:h9"
vim.opt.title = false

vim.opt.fillchars = vim.opt.fillchars + "eob: "
vim.opt.fillchars:append({
  stl = " ",
})

-- Keep a real outline without adding a solid border-padding area.
vim.opt.winborder = "rounded"

-- Reuse the colorscheme's border foreground for completion-menu borders.
local group = vim.api.nvim_create_augroup("CVIMUIHighlights", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", {
  group = group,
  callback = function()
    vim.api.nvim_set_hl(0, "PmenuBorder", { link = "FloatBorder" })
  end,
})
vim.api.nvim_set_hl(0, "PmenuBorder", { link = "FloatBorder" })
