-- Global presentation defaults. Keep the UI flat, transparent, and unframed.
vim.opt.cmdheight = 1
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.pumheight = 10
vim.opt.pumborder = "none"
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

-- Neovim 0.12 global defaults: no floating-window frame or added padding.
vim.opt.winborder = "none"
