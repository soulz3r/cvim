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
    if not installed then error(install_error) end

    local tiny_cmdline = require("tiny-cmdline")
    tiny_cmdline.setup({
      on_reposition = tiny_cmdline.adapters.blink,
      width = { value = "60%", min = 40, max = 100 },
      native_types = {},
    })
  end)

  if not ok then
    ui2.restore_notifications()
    vim.o.cmdheight = 1
    vim.notify(
      "tiny-cmdline/UI2 is unavailable; using Neovim's native command line.\n" .. tostring(err),
      vim.log.levels.WARN
    )
  end
end

return M
