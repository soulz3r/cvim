local M = { windows = {} }

function M.limits()
  local columns = math.max(1, vim.o.columns)
  local lines = math.max(1, vim.o.lines - vim.o.cmdheight)
  return {
    width = math.min(120, math.max(1, math.floor(columns * 0.85)), math.max(1, columns - 2)),
    height = math.min(32, math.max(1, math.floor(lines * 0.78)), math.max(1, lines - 2)),
  }
end

function M.config(title)
  local limits = M.limits()
  local editor_height = math.max(1, vim.o.lines - vim.o.cmdheight)
  return {
    relative = "editor",
    row = math.max(0, math.floor((editor_height - limits.height) / 2)),
    col = math.max(0, math.floor((vim.o.columns - limits.width) / 2)),
    width = limits.width,
    height = limits.height,
    border = "rounded",
    title = " " .. title .. " ",
    title_pos = "center",
  }
end

function M.open(buf, title, options)
  options = options or {}
  local win = vim.api.nvim_open_win(buf, true, vim.tbl_extend("force", M.config(title), options))
  M.windows[win] = { title = title, options = options }
  return win
end

function M.close(win)
  if not win or not vim.api.nvim_win_is_valid(win) then
    return false
  end
  M.windows[win] = nil
  vim.api.nvim_win_close(win, true)
  return true
end

function M.resize()
  for win, state in pairs(M.windows) do
    if vim.api.nvim_win_is_valid(win) then
      local config = vim.tbl_extend("force", M.config(state.title), state.options)
      pcall(vim.api.nvim_win_set_config, win, config)
    else
      M.windows[win] = nil
    end
  end
end

function M.setup()
  local group = vim.api.nvim_create_augroup("CVIMFloats", { clear = true })
  vim.api.nvim_create_autocmd("VimResized", { group = group, callback = M.resize })
  vim.api.nvim_create_autocmd("WinClosed", {
    group = group,
    callback = function(args)
      M.windows[tonumber(args.match)] = nil
    end,
  })
end

return M
