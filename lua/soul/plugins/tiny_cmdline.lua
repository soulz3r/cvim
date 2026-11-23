local ui2 = require("soul.ui.ui2")

local M = {
  "rachartier/tiny-cmdline.nvim",
  event = "VeryLazy",
  cond = ui2.is_enabled,
}

function M.config()
  if not ui2.is_enabled() then
    vim.o.cmdheight = 0
    return
  end

  local ok, err = pcall(function()
    vim.o.cmdheight = 0

    local tiny_cmdline = require("tiny-cmdline")

    tiny_cmdline.setup({
      width = {
        value = "60%",
        min = 40,
        max = 100,
      },

      position = {
        x = "50%",
        y = "50%",
      },

      border = "rounded",

      title = {
        enabled = true,
        pos = "center",
      },

      menu_col_offset = 3,

      native_types = {},

      on_reposition = tiny_cmdline.adapters.blink,
    })

    vim.api.nvim_set_hl(0, "TinyCmdlineNormal", {
      link = "NormalFloat",
    })

    vim.api.nvim_set_hl(0, "TinyCmdlineBorder", {
      link = "FloatBorder",
    })

    vim.api.nvim_set_hl(0, "TinyCmdlineTitle", {
      link = "FloatTitle",
    })
  end)

  if not ok then
    local restored, restore_error = ui2.restore()
    vim.o.cmdheight = 0

    local message =
      "tiny-cmdline/UI2 setup failed; using Neovim's native command line.\n"
      .. tostring(err)

    if not restored then
      message = message
        .. "\nUI2 cleanup also failed: "
        .. tostring(restore_error)
    end

    vim.notify(message, vim.log.levels.WARN)
  end
end

return M
