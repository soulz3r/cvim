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

local function set_window_border(buf, border)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == buf then
      local config = vim.api.nvim_win_get_config(win)
      if config.relative ~= "" then
        config.border = border
        pcall(vim.api.nvim_win_set_config, win, config)
      end
    end
  end
end

local function setup_borders()
  local group = vim.api.nvim_create_augroup("CVIMUI2Borders", { clear = true })

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = { "msg", "pager" },
    callback = function(args)
      -- UI2 defaults to an unbordered pager and lets msg inherit 'winborder'.
      -- CVIM uses the opposite: quiet transient messages, bordered history.
      set_window_border(args.buf, args.match == "pager" and "rounded" or "none")
    end,
  })

  local ok, ui2 = pcall(require, "vim._core.ui2")
  if ok and type(ui2) == "table" then
    for kind, border in pairs({ msg = "none", pager = "rounded" }) do
      local buf = ui2.bufs and ui2.bufs[kind]
      if type(buf) == "number" and vim.api.nvim_buf_is_valid(buf) then
        set_window_border(buf, border)
      end
    end
  end
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

  setup_borders()

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

  -- UI2 creates its windows while enabling, after the FileType autocmd exists.
  setup_borders()

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
