local root = vim.fn.getcwd()
vim.opt.rtp:prepend(root)

local passed = 0
local function test(name, callback)
  local ok, err = pcall(callback)
  if not ok then error(("FAIL: %s\n%s"):format(name, err)) end
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

test("UI2 initializes once and restores notification handler", function()
  local enable_calls = 0
  local original_show = function() end
  local message_store = {
    msg_show = function() end,
    msg_clear = function() end,
  }
  local ui2 = {
    msg = { msg_show = original_show },
    enable = function(options)
      assert(options.msg.targets == "cmd")
      enable_calls = enable_calls + 1
    end,
  }

  package.loaded["vim._core.ui2"] = nil
  package.loaded["vim._core.ui2.messages"] = nil
  package.preload["vim._core.ui2"] = function() return ui2 end
  package.preload["vim._core.ui2.messages"] = function() return message_store end

  local manager = require("soul.ui.ui2")
  assert(manager.setup())
  assert(manager.setup())
  assert(enable_calls == 1)

  assert(manager.install_notifications())
  assert(ui2.msg.msg_show ~= original_show)
  manager.restore_notifications()
  assert(ui2.msg.msg_show == original_show)
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
