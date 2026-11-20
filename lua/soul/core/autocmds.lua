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

-- Display the latest editor message in a persistent floating window.
-- A new message replaces the previous one; no timer hides it.
local message_win
local message_buf

local function message_text(content)
	local parts = {}
	for _, chunk in ipairs(content or {}) do
		if type(chunk) == "table" and type(chunk[2]) == "string" then
			parts[#parts + 1] = chunk[2]
		end
	end
	return vim.trim(table.concat(parts))
end

local function show_message(message)
	if message == "" then
		return
	end

	local lines = vim.split(message, "\n", { plain = true })
	local width = math.max(1, math.min(
		math.floor(vim.o.columns * 0.80),
		math.max(24, math.min(vim.fn.strdisplaywidth(message) + 2, vim.o.columns - 4))
	))
	local height = math.max(1, math.min(#lines, 5))

	if not message_buf or not vim.api.nvim_buf_is_valid(message_buf) then
		message_buf = vim.api.nvim_create_buf(false, true)
		vim.bo[message_buf].buftype = "nofile"
		vim.bo[message_buf].bufhidden = "hide"
		vim.bo[message_buf].swapfile = false
	end

	vim.bo[message_buf].modifiable = true
	vim.api.nvim_buf_set_lines(message_buf, 0, -1, false, lines)
	vim.bo[message_buf].modifiable = false

	local config = {
		relative = "editor",
		style = "minimal",
		border = "rounded",
		width = width,
		height = height,
		row = math.max(0, vim.o.lines - height - 3),
		col = math.max(0, vim.o.columns - width - 2),
	}
	if message_win and vim.api.nvim_win_is_valid(message_win) then
		vim.api.nvim_win_set_config(message_win, config)
	else
		message_win = vim.api.nvim_open_win(message_buf, false, config)
	end
	vim.wo[message_win].wrap = true
	vim.wo[message_win].winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder"
end

local message_ns = vim.api.nvim_create_namespace("cvim_messages")
vim.ui_attach(message_ns, { ext_messages = true, set_cmdheight = false }, function(event, ...)
	local args = { ... }

	if event == "msg_show" then
		local _, content = args[1], args[2]
		local message = message_text(content)
		if message ~= "" then
			vim.schedule(function() show_message(message) end)
		end
		return true
	elseif event == "msg_history_show" then
		local entries = args[1] or {}
		local latest
		for i = #entries, 1, -1 do
			latest = message_text(entries[i][2])
			if latest ~= "" then
				break
			end
		end
		if latest and latest ~= "" then
			vim.schedule(function() show_message(latest) end)
		end
		return true
	end
end)
