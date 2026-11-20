local group = vim.api.nvim_create_augroup("CVIMCore", { clear = true })
vim.api.nvim_create_autocmd("BufWinEnter", {
	group = group,
	callback = function() vim.opt_local.formatoptions:remove({ "c", "r", "o" }) end,
})
vim.api.nvim_create_autocmd({ "FocusGained", "TermLeave" }, { group = group, command = "checktime" })
vim.api.nvim_create_autocmd("TextYankPost", {
	group = group,
	callback = function() vim.hl.on_yank({ higroup = "Visual", timeout = 80 }) end,
})
vim.api.nvim_create_autocmd("FileType", {
	group = group,
	pattern = { "gitcommit", "markdown", "text" },
	callback = function() vim.opt_local.wrap = true end,
})
vim.api.nvim_create_autocmd("FileType", {
	group = group,
	pattern = { "help", "qf", "man" },
	callback = function(args)
		vim.keymap.set("n", "q", "<cmd>close<CR>", {
			buffer = args.buf, silent = true, desc = "Close utility window",
		})
	end,
})

-- Show diagnostics in a compact floating window when the cursor rests on an error.
vim.diagnostic.config({
	virtual_text = false,
	float = {
		border = "single",
		source = "if_many",
		header = "",
		prefix = "",
	},
})

vim.api.nvim_create_autocmd("CursorHold", {
	group = group,
	callback = function()
		local diagnostics = vim.diagnostic.get(0, {
			lnum = vim.api.nvim_win_get_cursor(0)[1] - 1,
			severity = vim.diagnostic.severity.ERROR,
		})
		if #diagnostics > 0 then
			vim.diagnostic.open_float(0, {
				focus = false,
				scope = "cursor",
				severity = vim.diagnostic.severity.ERROR,
				border = "single",
				source = "if_many",
			})
		end
	end,
})
