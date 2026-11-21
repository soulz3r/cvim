-- Minimal CVIM: Neovim core plus lazy.nvim and the Mini modules.
if vim.fn.has("nvim-0.12") ~= 1 then
  error("CVIM requires Neovim 0.12 or newer")
end

vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("soul.core.options").setup()
require("soul.core.autocmds").setup()
require("soul.ui").setup()
require("soul.core.keymaps").setup()
require("soul.lazy").setup()

vim.g.cvim_config_loaded = true
