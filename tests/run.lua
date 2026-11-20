local root = vim.fn.getcwd()
vim.opt.rtp:prepend(root)

local passed = 0
local function test(name, callback)
	local ok, err = pcall(callback)
	if not ok then
		error(("FAIL: %s\n%s"):format(name, err))
	end
	passed = passed + 1
	print("PASS: " .. name)
end

test("all Lua files parse", function()
	local files = vim.fn.glob(root .. "/**/*.lua", false, true)
	table.insert(files, root .. "/init.lua")

	for _, path in ipairs(files) do
		local chunk, err = loadfile(path)
		assert(chunk, ("%s: %s"):format(path, err))
	end
end)

test("core and UI setup", function()
	vim.g.mapleader = " "
	vim.g.maplocalleader = " "

	require("soul.core.options").setup()
	require("soul.core.autocmds").setup()
	require("soul.core.keymaps").setup()
	require("soul.ui.options").setup()
	require("soul.ui.diagnostics").setup()

	assert(vim.o.expandtab)
	assert(vim.o.shiftwidth == 2)
	assert(vim.o.winborder == "rounded")
	assert(vim.o.pumblend == 0)
	assert(vim.g.health.style == "float")
	assert(#vim.api.nvim_get_autocmds({ group = "CVIMCore" }) > 0)
	assert(#vim.api.nvim_get_autocmds({ group = "CVIMDiagnostics" }) > 0)
end)

test("keymaps are registered", function()
	assert(vim.fn.maparg(",,", "n") ~= "")
	assert(vim.fn.maparg(",,", "i") ~= "")
	assert(vim.fn.maparg("<C-h>", "n") ~= "")
	assert(vim.fn.maparg(" w", "n") ~= "")
end)

test("platform and path helpers load", function()
	local platform = require("soul.core.platform")
	local paths = require("soul.core.helpers.paths")

	assert(type(platform.is_windows) == "boolean")
	assert(type(platform.is_wsl) == "boolean")
	assert(type(platform.name) == "string")
	assert(type(paths.projects) == "string" and paths.projects ~= "")
end)

test("plugin specifications and lockfile agree", function()
	local mini = require("soul.plugins.mini")
	local minmax = require("soul.plugins.minmax")
	local tiny_cmdline = require("soul.plugins.tiny_cmdline")
	local lockfile = vim.json.decode(table.concat(vim.fn.readfile(root .. "/lazy-lock.json"), "\n"))

	assert(#mini == 5)
	assert(#minmax == 1)
	assert(tiny_cmdline[1] == "rachartier/tiny-cmdline.nvim")
	assert(lockfile["mini.files"] and lockfile["mini.icons"])
	assert(lockfile["tiny-cmdline.nvim"] and lockfile["blink.cmp"])
end)

test("UI2 initializes once and restores all handlers", function()
	local enable_calls = 0
	local disable_calls = 0
	local original_ui2_show = function() end
	local original_message_show = function() end
	local message_store = {
		msg_show = original_message_show,
		msg_clear = function() end,
	}
	local ui2 = {
		msg = { msg_show = original_ui2_show },
		enable = function(options)
			if options.enable == false then
				disable_calls = disable_calls + 1
			else
				assert(options.enable == true)
				assert(options.msg.targets == "cmd")
				enable_calls = enable_calls + 1
			end
		end,
	}

	package.loaded["vim._core.ui2"] = nil
	package.loaded["vim._core.ui2.messages"] = nil
	package.preload["vim._core.ui2"] = function()
		return ui2
	end
	package.preload["vim._core.ui2.messages"] = function()
		return message_store
	end

	local manager = require("soul.ui.ui2")
	assert(manager.setup())
	assert(manager.setup())
	assert(enable_calls == 1)
	assert(message_store.msg_show ~= original_message_show)

	assert(manager.install_notifications())
	assert(ui2.msg.msg_show ~= original_ui2_show)
	assert(manager.restore())
	assert(manager.is_enabled() == false)
	assert(disable_calls == 1)
	assert(ui2.msg.msg_show == original_ui2_show)
	assert(message_store.msg_show == original_message_show)
end)

test("Tiny-cmdline failure rolls UI2 back to native mode", function()
	local manager = require("soul.ui.ui2")
	local tiny = require("soul.plugins.tiny_cmdline")
	local original_notify = vim.notify
	local notifications = {}

	vim.notify = function(message)
		table.insert(notifications, message)
	end
	package.preload["tiny-cmdline"] = function()
		return {
			adapters = { blink = function() end },
			setup = function()
				error("intentional setup failure")
			end,
		}
	end

	assert(manager.setup())
	tiny.config()

	assert(manager.is_enabled() == false)
	assert(vim.o.cmdheight == 1)
	assert(#notifications == 1)
	assert(notifications[1]:find("native command line", 1, true))
	vim.notify = original_notify
	package.preload["tiny-cmdline"] = nil
end)

test("health float interception applies shared geometry and restores API", function()
	local messages = require("soul.ui.messages")
	local util = vim.lsp.util
	local original_preview = util.open_floating_preview
	local original_cmd = vim.cmd
	local original_notify = vim.notify
	local received

	vim.notify = function() end
	local preview_stub = function(_, _, options)
		received = options
		return {}, 1
	end
	util.open_floating_preview = preview_stub
	vim.cmd = function()
		util.open_floating_preview({ "health output" }, "text", {})
	end

	messages._run_health_command("checkhealth")
	assert(received and received.width > 0 and received.height > 0)
	assert(received.border == "rounded")
	assert(received.title == " Checkhealth ")
	assert(util.open_floating_preview == preview_stub)

	vim.cmd = function()
		error("intentional health failure")
	end
	messages._run_health_command("checkhealth")
	assert(util.open_floating_preview == preview_stub)

	util.open_floating_preview = original_preview
	vim.cmd = original_cmd
	vim.notify = original_notify
end)

test("help and Man command workspaces clean up temporary windows", function()
	local messages = require("soul.ui.messages")
	local tab = vim.api.nvim_get_current_tabpage()
	local original_win = vim.api.nvim_get_current_win()
	local original_count = #vim.api.nvim_tabpage_list_wins(tab)

	messages._run_buffer_command("help help", "Help")
	local help_win = vim.api.nvim_get_current_win()
	assert(help_win ~= original_win)
	assert(vim.bo[vim.api.nvim_win_get_buf(help_win)].filetype == "help")
	assert(vim.api.nvim_get_current_tabpage() == tab)
	vim.api.nvim_win_close(help_win, true)
	assert(#vim.api.nvim_tabpage_list_wins(tab) == original_count)

	pcall(vim.api.nvim_del_user_command, "Man")
	vim.api.nvim_create_user_command("Man", function()
		vim.cmd("vsplit")
		vim.api.nvim_buf_set_lines(0, 0, -1, false, { "manual test output" })
		vim.bo.filetype = "man"
	end, {})

	messages._run_buffer_command("Man", "Man")
	local man_win = vim.api.nvim_get_current_win()
	local man_buf = vim.api.nvim_win_get_buf(man_win)
	assert(vim.bo[man_buf].filetype == "man")
	assert(vim.api.nvim_buf_get_lines(man_buf, 0, 1, false)[1] == "manual test output")
	assert(vim.api.nvim_get_current_tabpage() == tab)
	vim.api.nvim_win_close(man_win, true)
	assert(#vim.api.nvim_tabpage_list_wins(tab) == original_count)
	vim.api.nvim_del_user_command("Man")
end)

test("output windows use the shared float layout", function()
	local messages = require("soul.ui.messages")
	local original_win = vim.api.nvim_get_current_win()

	messages.open_output("Regression", { "first line", "second line" }, "text")

	local win = vim.api.nvim_get_current_win()
	assert(win ~= original_win)
	local config = vim.api.nvim_win_get_config(win)
	assert(config.relative == "editor")
	assert(config.width > 0 and config.height > 0)
	assert(vim.wo[win].wrap == false)
	assert(vim.api.nvim_buf_get_lines(0, 0, -1, false)[1] == "first line")

	vim.api.nvim_win_close(win, true)
	assert(vim.api.nvim_get_current_win() == original_win)
end)

print(("CVIM checks: %d passed"):format(passed))
