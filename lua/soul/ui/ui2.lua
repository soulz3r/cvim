local M = {
	enabled = false,
}

local function get_ui2()
	if vim.fn.has("nvim-0.12") ~= 1 then
		return nil, "Neovim 0.12 or newer is required"
	end

	local ok, ui2 = pcall(require, "vim._core.ui2")
	if not ok or type(ui2) ~= "table" or type(ui2.enable) ~= "function" then
		return nil, "Neovim UI2 is unavailable"
	end

	return ui2
end

local function restore_message_handler()
	if not M.messages or not M.original_messages_msg_show then
		return
	end

	M.message_generation = (M.message_generation or 0) + 1
	M.messages.msg_show = M.original_messages_msg_show
	M.messages = nil
	M.original_messages_msg_show = nil
end

function M.available()
	return get_ui2() ~= nil
end

function M.is_enabled()
	return M.enabled
end

function M.setup()
	if M.enabled then
		return true
	end

	local ui2, err = get_ui2()
	if not ui2 then
		return false, err
	end

	local ok, enable_error = pcall(ui2.enable, {
		enable = true,
		msg = { targets = "cmd" },
	})
	if not ok then
		return false, tostring(enable_error)
	end

	M.ui2 = ui2

	local messages_ok, messages = pcall(require, "vim._core.ui2.messages")
	if messages_ok and type(messages.msg_show) == "function" then
		local original_msg_show = messages.msg_show
		M.message_generation = (M.message_generation or 0) + 1

		messages.msg_show = function(...)
			original_msg_show(...)
			M.message_generation = M.message_generation + 1
			local current_generation = M.message_generation

			vim.defer_fn(function()
				if current_generation == M.message_generation and type(messages.msg_clear) == "function" then
					messages.msg_clear()
				end
			end, 5000)
		end

		M.messages = messages
		M.original_messages_msg_show = original_msg_show
	end

	M.enabled = true
	return true
end

function M.install_notifications()
	if not M.enabled or type(M.ui2.msg) ~= "table" then
		return false, "Neovim UI2 message handlers are unavailable"
	end

	if M.notifications_installed then
		return true
	end

	local original_msg_show = M.ui2.msg.msg_show
	if type(original_msg_show) ~= "function" then
		return false, "Neovim UI2 msg_show handler is unavailable"
	end

	local levels = {
		emsg = vim.log.levels.ERROR,
		lua_error = vim.log.levels.ERROR,
		echoerr = vim.log.levels.ERROR,
		rpc_error = vim.log.levels.ERROR,
		shell_err = vim.log.levels.WARN,
		wmsg = vim.log.levels.WARN,
	}

	M.ui2.msg.msg_show = function(kind, content)
		local level = levels[kind] or vim.log.levels.INFO
		if level ~= vim.log.levels.ERROR and level ~= vim.log.levels.WARN then
			return
		end

		local message
		if type(content) == "table" then
			message = table.concat(vim.tbl_map(function(chunk)
				return type(chunk) == "table" and tostring(chunk[2] or "") or tostring(chunk)
			end, content))
		else
			message = tostring(content or "")
		end

		message = vim.trim(message)
		if message == "" then
			return
		end

		if message:find("W10", 1, true) or message:find("Changing a readonly file", 1, true) then
			message = "This buffer is read-only. Changes are disabled."
			level = vim.log.levels.WARN
		end

		vim.schedule(function()
			vim.notify(message, level, {
				title = level == vim.log.levels.ERROR and "NEOVIM ERROR" or "WARNING",
			})
		end)
	end

	M.original_ui2_msg_show = original_msg_show
	M.notifications_installed = true
	return true
end

function M.restore_notifications()
	if not M.notifications_installed or not M.ui2 or type(M.ui2.msg) ~= "table" then
		return
	end

	M.ui2.msg.msg_show = M.original_ui2_msg_show
	M.original_ui2_msg_show = nil
	M.notifications_installed = false
end

function M.restore()
	if not M.enabled then
		return true
	end

	M.restore_notifications()
	restore_message_handler()

	local ok, err = pcall(M.ui2.enable, { enable = false })
	if not ok then
		return false, "Could not disable Neovim UI2: " .. tostring(err)
	end

	M.enabled = false
	M.ui2 = nil
	return true
end

return M
