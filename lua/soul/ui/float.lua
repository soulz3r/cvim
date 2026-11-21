local M = {}

function M.limits()
  local columns = math.max(1, vim.o.columns)
  local lines = math.max(1, vim.o.lines - vim.o.cmdheight)

  return {
    width = math.min(math.max(1, columns - 4), math.max(1, math.min(120, math.floor(columns * 0.85)))),
    height = math.min(math.max(1, lines - 4), math.max(1, math.min(32, math.floor(lines * 0.78)))),
  }
end

function M.config(title)
  local limits = M.limits()

  return {
    relative = "editor",
    row = math.max(0, math.floor((vim.o.lines - vim.o.cmdheight - limits.height) / 2)),
    col = math.max(0, math.floor((vim.o.columns - limits.width) / 2)),
    width = limits.width,
    height = limits.height,
    border = "rounded",
    title = " " .. title .. " ",
    title_pos = "center",
  }
end

return M
