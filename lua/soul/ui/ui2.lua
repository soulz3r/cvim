local M = { enabled = false }
local lifecycle = require("soul.core.lifecycle")

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

function M.available()
  return get_ui2() ~= nil
end

function M.is_enabled()
  return M.enabled
end

function M.setup()
  return lifecycle.start("ui2", function()
    local ui2, err = get_ui2()
    if not ui2 then
      error(err)
    end

    -- UI2 owns the geometry and borders of its special message windows.
    ui2.enable({
      enable = true,
      msg = {
        targets = "msg",
        msg = { height = 0.35, timeout = 3500 },
        pager = { height = 0.85 },
      },
    })

    M.ui2 = ui2
    M.enabled = true
    return function()
      local ok, disable_error = pcall(ui2.enable, { enable = false })
      M.enabled = false
      M.ui2 = nil
      if not ok then
        error("Could not disable Neovim UI2: " .. tostring(disable_error))
      end
    end
  end)
end

function M.restore()
  return lifecycle.stop("ui2")
end

return M
