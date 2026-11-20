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

-- Keep the native command line. Display vim.notify messages in a persistent float.
local message_win
local message_buf

local function show_message(message, level, title)
	message = tostring(message or "")
	if message == "" then return end

	if not message_buf or not vim.api.nvim_buf_is_valid(message_buf) then
		message_buf = vim.api.nvim_create_buf(false, true)
	end

	local lines = vim.split(message, "\n", { plain = true })
	vim.api.nvim_buf_set_lines(message_buf, 0, -1, false, lines)

	local width = math.min(math.max(40, vim.o.columns - 8), 80)
	local height = math.min(math.max(1, #lines), math.max(1, vim.o.lines - 6))
	local row = math.max(0, vim.o.lines - height - 4)
	local col = math.max(0, vim.o.columns - width - 2)

	if message_win and vim.api.nvim_win_is_valid(message_win) then
		vim.api.nvim_win_set_config(message_win, {
			relative = "editor", row = row, col = col, width = width, height = height,
		})
	else
		message_win = vim.api.nvim_open_win(message_buf, false, {
			relative = "editor", row = row, col = col, width = width, height = height,
			style = "minimal", border = "rounded",
			title = title or " Message ", title_pos = "left",
		})
	end

	local hl = level == vim.log.levels.ERROR and "DiagnosticError"
		or level == vim.log.levels.WARN and "DiagnosticWarn"
		or "Normal"
	vim.wo[message_win].winhighlight = "Normal:" .. hl .. ",FloatBorder:FloatBorder"
end

vim.notify = function(message, level, opts)
	opts = opts or {}
	show_message(message, level or vim.log.levels.INFO, opts.title)
end

-- :messages opens the latest recorded message in the same float.
vim.api.nvim_create_user_command("Messages", function()
	local history = vim.api.nvim_exec2("messages", { output = true }).output
	local latest
	for line in history:gmatch("[^\n]+") do
		if line:match("%S") then latest = line end
	end
	show_message(latest or "No messages", vim.log.levels.INFO, " Messages ")
end, {})
vim.cmd([[cnoreabbrev <expr> messages getcmdtype() == ':' && getcmdline() ==# 'messages' ? 'Messages' : 'messages']])
