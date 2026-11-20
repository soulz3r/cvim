-- Minimal CVIM: Neovim core plus lazy.nvim and the Mini modules.
if vim.fn.has("nvim-0.12") ~= 1 then
  error("CVIM requires Neovim 0.12 or newer")
end
vim.g.mapleader = " "
vim.g.maplocalleader = " "
require("soul.core.options")
vim.cmd.colorscheme("minmax")
require("soul.core.autocmds")
-- Keep native messages in the bottom command area, then clear them after five seconds.
local ui2 = require("vim._core.ui2")
ui2.enable({ msg = { targets = "cmd" } })

local messages = require("vim._core.ui2.messages")
local original_msg_show = messages.msg_show
local message_generation = 0

messages.msg_show = function(...)
	original_msg_show(...)
	message_generation = message_generation + 1
	local generation = message_generation

	vim.defer_fn(function()
		if generation == message_generation then
			messages.msg_clear()
		end
	end, 5000)
end
require("soul.core.keymaps")
require("soul.lazy")
vim.g.cvim_config_loaded = true
