-- Minimal CVIM: core Neovim settings, keymaps, and autocmds only.
if vim.fn.has("nvim-0.12") ~= 1 then error("CVIM requires Neovim 0.12 or newer") end
vim.g.mapleader = " "
vim.g.maplocalleader = " "
require("soul.core.options")
vim.cmd.colorscheme("minmax")
require("soul.core.autocmds")
require("soul.core.keymaps")
vim.g.cvim_config_loaded = true
