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

-- Open the complete :messages history in the same large centered float style.
local function show_messages()
	local messages = vim.api.nvim_exec2("messages", { output = true }).output
	local lines = vim.split(messages, "\n", { plain = true })
	if #lines == 0 or (#lines == 1 and lines[1] == "") then
		lines = { "No messages." }
	end

	local width = math.max(1, math.min(vim.o.columns - 4, math.floor(vim.o.columns * 0.80)))
	local height = math.max(1, math.min(vim.o.lines - 4, math.floor(vim.o.lines * 0.70)))
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].swapfile = false
	vim.bo[buf].modifiable = false
	vim.bo[buf].filetype = "messages"

	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		style = "minimal",
		border = "rounded",
		title = " Messages ",
		title_pos = "center",
		width = width,
		height = height,
		row = math.max(0, math.floor((vim.o.lines - height) / 2)),
		col = math.max(0, math.floor((vim.o.columns - width) / 2)),
	})
	vim.wo[win].wrap = true
	vim.wo[win].cursorline = true
	vim.keymap.set("n", "q", function() vim.api.nvim_win_close(win, true) end, {
		buffer = buf, silent = true, nowait = true,
	})
	vim.keymap.set("n", "<Esc>", function() vim.api.nvim_win_close(win, true) end, {
		buffer = buf, silent = true, nowait = true,
	})
end

vim.api.nvim_create_user_command("Messages", show_messages, {})
vim.cmd([[cnoreabbrev <expr> messages getcmdtype() == ':' && getcmdline() ==# 'messages' ? 'Messages' : 'messages']])
