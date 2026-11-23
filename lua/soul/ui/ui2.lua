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
    msg = {
      targets = "msg",
      msg = {
        height = 0.35,
        timeout = 3500,
      },
      pager = {
        height = 0.85,
      },
    },
  })

  if not ok then
    return false, tostring(enable_error)
  end

  M.ui2 = ui2
  M.enabled = true
  return true
end

function M.restore()
  if not M.enabled then
    return true
  end

  local ok, err = pcall(M.ui2.enable, {
    enable = false,
  })

  if not ok then
    return false, "Could not disable Neovim UI2: " .. tostring(err)
  end

  M.enabled = false
  M.ui2 = nil
  return true
end

return M
