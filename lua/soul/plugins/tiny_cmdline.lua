local ui2 = require("soul.ui.ui2")
local lifecycle = require("soul.core.lifecycle")

local M = {
  "rachartier/tiny-cmdline.nvim",
  event = "VeryLazy",
  cond = ui2.is_enabled,
}

function M.config()
  local ok, err = lifecycle.start("tiny-cmdline", function()
    vim.o.cmdheight = 0
    if not ui2.is_enabled() then
      return
    end

    local tiny_cmdline = require("tiny-cmdline")
    tiny_cmdline.setup({
      width = { value = "60%", min = 40, max = 100 },
      position = { x = "50%", y = "50%" },
      border = "rounded",
      title = { enabled = true, pos = "center" },
      menu_col_offset = 3,
      native_types = {},
      on_reposition = tiny_cmdline.adapters.blink,
    })

    vim.api.nvim_set_hl(0, "TinyCmdlineNormal", { link = "NormalFloat" })
    vim.api.nvim_set_hl(0, "TinyCmdlineBorder", { link = "FloatBorder" })
    vim.api.nvim_set_hl(0, "TinyCmdlineTitle", { link = "FloatTitle" })

    return function()
      if type(tiny_cmdline.teardown) == "function" then
        tiny_cmdline.teardown()
      end
    end
  end)

  if not ok then
    -- Tiny-cmdline is optional. Its failure must not disable UI2 messages.
    vim.o.cmdheight = 0
    vim.notify("tiny-cmdline setup failed; using Neovim's native command line.\n" .. tostring(err), vim.log.levels.WARN)
  end
end

return M
