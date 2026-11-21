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
  assert(vim.o.cmdheight == 0)
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

  if platform.is_windows then
    assert(vim.o.shellcmdflag:find("UTF8Encoding", 1, true))
    assert(vim.o.shellpipe == "> %s 2>&1")
    assert(vim.o.shellredir == "> %s 2>&1")
  end
end)

test("plugin specifications and lockfile agree", function()
  local mini = require("soul.plugins.mini")
  local minmax = require("soul.plugins.minmax")
  local tiny_cmdline = require("soul.plugins.tiny_cmdline")
  local toggleterm = require("soul.plugins.toggleterm")
  local lockfile = vim.json.decode(table.concat(vim.fn.readfile(root .. "/lazy-lock.json"), "\n"))

  assert(#mini == 5)
  assert(#minmax == 1)
  assert(#toggleterm == 1)
  assert(toggleterm[1][1] == "akinsho/toggleterm.nvim")
  assert(tiny_cmdline[1] == "rachartier/tiny-cmdline.nvim")
  assert(lockfile["mini.files"] and lockfile["mini.icons"])
  assert(lockfile["tiny-cmdline.nvim"] and lockfile["toggleterm.nvim"] and not lockfile["blink.cmp"])
end)

test("PowerShell resolution falls back to Windows PowerShell", function()
  local original_executable = vim.fn.executable
  local original_exepath = vim.fn.exepath
  local original_pwsh = vim.env.PWSH
  local original_paths = package.loaded["soul.core.helpers.paths"]
  local expected = "C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"

  vim.env.PWSH = nil
  vim.fn.executable = function()
    return 0
  end
  vim.fn.exepath = function(name)
    return name == "powershell.exe" and expected or ""
  end
  package.loaded["soul.core.helpers.paths"] = nil

  local paths = require("soul.core.helpers.paths")
  assert(paths.pwsh == expected)

  vim.fn.executable = original_executable
  vim.fn.exepath = original_exepath
  vim.env.PWSH = original_pwsh
  package.loaded["soul.core.helpers.paths"] = original_paths
end)

test("ToggleTerm reuses PowerShell when Git Bash is unavailable", function()
  local original_has = vim.fn.has
  local original_executable = vim.fn.executable
  local original_exepath = vim.fn.exepath
  local original_shell = vim.o.shell
  local original_program_files = vim.env.ProgramFiles
  local original_program_files_x86 = vim.env["ProgramFiles(x86)"]
  local original_local_app_data = vim.env.LOCALAPPDATA
  local original_preload = package.preload.toggleterm
  local original_loaded = package.loaded.toggleterm
  local captured

  vim.fn.has = function(feature)
    return feature == "win32" and 1 or original_has(feature)
  end
  vim.fn.executable = function()
    return 0
  end
  vim.fn.exepath = function()
    return ""
  end
  vim.o.shell = "powershell.exe"
  vim.env.ProgramFiles = nil
  vim.env["ProgramFiles(x86)"] = nil
  vim.env.LOCALAPPDATA = nil
  package.loaded.toggleterm = nil
  package.preload.toggleterm = function()
    return {
      setup = function(options)
        captured = options
      end,
    }
  end

  require("soul.plugins.toggleterm")[1].config()
  assert(captured and captured.shell == "powershell.exe")

  vim.fn.has = original_has
  vim.fn.executable = original_executable
  vim.fn.exepath = original_exepath
  vim.o.shell = original_shell
  vim.env.ProgramFiles = original_program_files
  vim.env["ProgramFiles(x86)"] = original_program_files_x86
  vim.env.LOCALAPPDATA = original_local_app_data
  package.preload.toggleterm = original_preload
  package.loaded.toggleterm = original_loaded
end)

test("UI2 remains available on Windows", function()
  local original_has = vim.fn.has
  local ui2 = {
    msg = { msg_show = function() end },
    enable = function() end,
  }
  local message_store = {
    msg_show = function() end,
    msg_clear = function() end,
  }

  vim.fn.has = function(feature)
    if feature == "win32" then
      return 1
    end
    return original_has(feature)
  end
  package.loaded["vim._core.ui2"] = nil
  package.loaded["vim._core.ui2.messages"] = nil
  package.preload["vim._core.ui2"] = function()
    return ui2
  end
  package.preload["vim._core.ui2.messages"] = function()
    return message_store
  end
  package.loaded["soul.ui.ui2"] = nil

  local manager = require("soul.ui.ui2")
  assert(manager.available())
  assert(manager.setup())
  assert(manager.is_enabled())
  assert(manager.restore())

  vim.fn.has = original_has
  package.preload["vim._core.ui2"] = nil
  package.preload["vim._core.ui2.messages"] = nil
  package.loaded["vim._core.ui2"] = nil
  package.loaded["vim._core.ui2.messages"] = nil
  package.loaded["soul.ui.ui2"] = nil
end)

test("UI2 initializes once and restores all handlers", function()
  local enable_calls = 0
  local disable_calls = 0
  local forwarded
  local original_ui2_show = function(kind, ...)
    forwarded = { kind, ... }
  end
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
  ui2.msg.msg_show("echo", "bottom message", true)
  assert(forwarded and forwarded[1] == "echo")
  assert(forwarded[2] == "bottom message" and forwarded[3] == true)
  assert(manager.restore())
  assert(manager.is_enabled() == false)
  assert(disable_calls == 1)
  assert(ui2.msg.msg_show == original_ui2_show)
  assert(message_store.msg_show == original_message_show)
end)

test("UI2 messages use severity-based timeouts", function()
  local original_defer = vim.defer_fn
  local callbacks, delays = {}, {}
  local clear_calls = 0
  local message_store = {
    msg_show = function() end,
    msg_clear = function()
      clear_calls = clear_calls + 1
    end,
  }
  local ui2 = {
    msg = { msg_show = function() end },
    enable = function() end,
  }

  vim.defer_fn = function(callback, delay)
    table.insert(callbacks, callback)
    table.insert(delays, delay)
  end
  package.loaded["vim._core.ui2"] = nil
  package.loaded["vim._core.ui2.messages"] = nil
  package.preload["vim._core.ui2"] = function()
    return ui2
  end
  package.preload["vim._core.ui2.messages"] = function()
    return message_store
  end
  package.loaded["soul.ui.ui2"] = nil

  local manager = require("soul.ui.ui2")
  assert(manager.setup())
  message_store.msg_show("echo", "information")
  message_store.msg_show("wmsg", "warning")
  message_store.msg_show("emsg", "error")
  message_store.msg_show("return_prompt", "press enter")

  assert(delays[1] == 2000)
  assert(delays[2] == 4000)
  assert(delays[3] == 6000)
  assert(#delays == 3, "interactive prompts must not be auto-cleared")

  callbacks[1]()
  callbacks[2]()
  callbacks[3]()
  assert(clear_calls == 0, "an older timer must not clear a newer interactive prompt")

  message_store.msg_show("echo", "new information")
  assert(delays[4] == 2000)
  callbacks[4]()
  assert(clear_calls == 1, "the newest timed message should clear after its timeout")

  assert(manager.restore())
  vim.defer_fn = original_defer
  package.preload["vim._core.ui2"] = nil
  package.preload["vim._core.ui2.messages"] = nil
  package.loaded["vim._core.ui2"] = nil
  package.loaded["vim._core.ui2.messages"] = nil
  package.loaded["soul.ui.ui2"] = nil
end)

test("Tiny-cmdline failure rolls UI2 back to native mode", function()
  local manager = require("soul.ui.ui2")
  package.loaded["soul.plugins.tiny_cmdline"] = nil
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
  assert(vim.o.cmdheight == 0)
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

test("inspection commands do not intercept highlight mutations", function()
  local messages = require("soul.ui.messages")
  local original_exec2 = vim.api.nvim_exec2
  local original_schedule = vim.schedule
  local original_open_output = messages.open_output
  local executed, opened = {}, {}

  vim.api.nvim_exec2 = function(command, options)
    table.insert(executed, { command = command, options = options })
    return { output = "highlight output" }
  end
  vim.schedule = function(callback)
    callback()
  end
  messages.open_output = function(title, output)
    table.insert(opened, { title = title, output = output })
  end

  assert(messages._handle_command("highlight Normal"))
  assert(#executed == 1 and executed[1].command == "highlight Normal")
  assert(#opened == 1 and opened[1].output == "highlight output")

  assert(not messages._handle_command("highlight clear"))
  assert(not messages._handle_command("highlight default"))
  assert(#executed == 1, "mutating highlight commands must not be executed by the output handler")

  vim.api.nvim_exec2 = original_exec2
  vim.schedule = original_schedule
  messages.open_output = original_open_output
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
