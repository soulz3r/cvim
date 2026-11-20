-- Minimal CVIM: Neovim core plus lazy.nvim and the Mini modules.
if vim.fn.has("nvim-0.12") ~= 1 then
  error("CVIM requires Neovim 0.12 or newer")
end
vim.g.mapleader = " "
vim.g.maplocalleader = " "
require("soul.core.options")
vim.cmd.colorscheme("minmax")
require("soul.core.autocmds")
require("vim._core.ui2").enable({
	msg = {
		targets = "msg",
		msg = { timeout = 5000 },
	},
})
require("soul.core.keymaps")
require("soul.lazy")
vim.g.cvim_config_loaded = true
