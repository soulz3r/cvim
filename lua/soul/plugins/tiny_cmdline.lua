local ui2 = require("soul.ui.ui2")

local M = {
	"rachartier/tiny-cmdline.nvim",
	event = "VeryLazy",
	dependencies = { "saghen/blink.cmp" },
	cond = ui2.is_enabled,
}

function M.config()
	if not ui2.is_enabled() then
		vim.o.cmdheight = 1
		return
	end

	local ok, err = pcall(function()
		vim.o.cmdheight = 0

		local installed, install_error = ui2.install_notifications()
		if not installed then
			error(install_error)
		end

		local tiny_cmdline = require("tiny-cmdline")
		tiny_cmdline.setup({
			on_reposition = tiny_cmdline.adapters.blink,
			width = { value = "60%", min = 40, max = 100 },
			native_types = {},
		})
	end)

	if not ok then
		local restored, restore_error = ui2.restore()
		vim.o.cmdheight = 1

		local message = "tiny-cmdline/UI2 setup failed; using Neovim's native command line.\n" .. tostring(err)
		if not restored then
			message = message .. "\nUI2 cleanup also failed: " .. tostring(restore_error)
		end

		vim.notify(message, vim.log.levels.WARN)
	end
end

return M
