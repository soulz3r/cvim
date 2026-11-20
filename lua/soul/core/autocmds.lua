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

-- Show only the latest :messages entry in a temporary floating window.
local message_win

local function show_messages()
	local output = vim.api.nvim_exec2("messages", { output = true }).output
	local lines = vim.split(output, "\n", { plain = true })
	local message

	for i = #lines, 1, -1 do
		local line = vim.trim(lines[i])
		if line ~= "" then
			message = line
			break
		end
	end

	if not message then
		message = "No messages."
	end

	if message_win and vim.api.nvim_win_is_valid(message_win) then
		vim.api.nvim_win_close(message_win, true)
	end

	local max_width = math.max(1, math.floor(vim.o.columns * 0.80))
	local width = math.min(max_width, math.max(24, #message + 2))
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { message })
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].swapfile = false
	vim.bo[buf].modifiable = false

	message_win = vim.api.nvim_open_win(buf, false, {
		relative = "editor",
		style = "minimal",
		border = "rounded",
		width = width,
		height = 1,
		row = math.max(0, math.floor((vim.o.lines - 3) / 2)),
		col = math.max(0, math.floor((vim.o.columns - width) / 2)),
	})
	vim.wo[message_win].wrap = true

	local win = message_win
	vim.defer_fn(function()
		if message_win == win and vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
			message_win = nil
		end
	end, 2500)
end

vim.api.nvim_create_user_command("Messages", show_messages, {})
vim.cmd([[cnoreabbrev <expr> messages getcmdtype() == ':' && getcmdline() ==# 'messages' ? 'Messages' : 'messages']])
