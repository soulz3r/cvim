local M = {}

local float = require("soul.ui.float")

local function configure()
  local limits = float.limits()

  vim.diagnostic.config({
    virtual_text = false,
    float = {
      border = "rounded",
      source = "if_many",
      header = "",
      prefix = "",
      max_width = limits.width,
      max_height = limits.height,
    },
  })
end

function M.setup()
  configure()

  local group = vim.api.nvim_create_augroup("CVIMDiagnostics", { clear = true })

  vim.api.nvim_create_autocmd("CursorHold", {
    group = group,
    callback = function()
      local diagnostics = vim.diagnostic.get(0, {
        lnum = vim.api.nvim_win_get_cursor(0)[1] - 1,
        severity = vim.diagnostic.severity.ERROR,
      })

      if #diagnostics > 0 then
        local limits = float.limits()
        vim.diagnostic.open_float(0, {
          focus = false,
          scope = "cursor",
          severity = vim.diagnostic.severity.ERROR,
          border = "rounded",
          max_width = limits.width,
          max_height = limits.height,
        })
      end
    end,
  })

  vim.api.nvim_create_autocmd("VimResized", {
    group = group,
    callback = configure,
  })
end

return M
