local M = {}

local float = require("soul.ui.float")

local function run_health_command(command_line)
  local util = vim.lsp.util
  local original = util.open_floating_preview
  if type(original) ~= "function" then
    vim.notify("Neovim's floating preview utility is unavailable", vim.log.levels.ERROR)
    return
  end

  util.open_floating_preview = function(contents, syntax, options, ...)
    local config = float.config("Checkhealth")
    options = vim.tbl_extend("force", options or {}, {
      width = config.width,
      height = config.height,
      offset_x = config.col,
      offset_y = config.row,
      border = config.border,
      title = config.title,
      title_pos = config.title_pos,
    })
    return original(contents, syntax, options, ...)
  end

  local ok, err = pcall(vim.cmd, command_line)
  util.open_floating_preview = original

  if not ok then
    vim.notify(tostring(err), vim.log.levels.ERROR)
  end
end

function M.open_output(title, output, filetype)
  local lines = type(output) == "table" and output or vim.split(output or "", "\n", { plain = true })
  if #lines == 0 or (#lines == 1 and lines[1] == "") then
    lines = { "No output." }
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].modifiable = false
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = filetype or "vim"

  local win = vim.api.nvim_open_win(buf, true, vim.tbl_extend("force", float.config(title), { style = "minimal" }))
  vim.wo[win].wrap = false
  vim.wo[win].cursorline = false
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true })
  vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = buf, silent = true })
end

local output_commands = {
  map = { min = 0, max = 1 },
  nmap = { min = 0, max = 1 },
  vmap = { min = 0, max = 1 },
  xmap = { min = 0, max = 1 },
  smap = { min = 0, max = 1 },
  omap = { min = 0, max = 1 },
  imap = { min = 0, max = 1 },
  lmap = { min = 0, max = 1 },
  cmap = { min = 0, max = 1 },
  tmap = { min = 0, max = 1 },
  scriptnames = { min = 0, max = 0 },
  registers = { min = 0, max = 1 },
  highlight = { min = 0, max = 1 },
  marks = { min = 0, max = 1 },
  jumps = { min = 0, max = 0 },
  changes = { min = 0, max = 0 },
  digraphs = { min = 0, max = 1 },
  version = { min = 0, max = 0 },
  ls = { min = 0, max = 0 },
  files = { min = 0, max = 0 },
  buffers = { min = 0, max = 0 },
  history = { min = 0, max = 1 },
  autocmd = { min = 0, max = 2 },
}

local function parse_command(command_line)
  local ok, parsed = pcall(vim.api.nvim_parse_cmd, command_line, {})
  if not ok or parsed.bang or (parsed.mods and parsed.mods.confirm) then
    return nil
  end
  return parsed
end

local function snapshot_windows()
  local tabs, windows = {}, {}

  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    tabs[tab] = true
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
      windows[win] = true
    end
  end

  return tabs, windows
end

local function cleanup_command_windows(tabs_before, windows_before, temp_win, scratch)
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    if not tabs_before[tab] then
      pcall(vim.api.nvim_tabpage_close, tab, true)
    else
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
        if not windows_before[win] and win ~= temp_win and vim.api.nvim_win_is_valid(win) then
          pcall(vim.api.nvim_win_close, win, true)
        end
      end
    end
  end

  if vim.api.nvim_win_is_valid(temp_win) then
    pcall(vim.api.nvim_win_close, temp_win, true)
  end
  if vim.api.nvim_buf_is_valid(scratch) then
    pcall(vim.api.nvim_buf_delete, scratch, { force = true })
  end
end

local function run_buffer_command(command_line, title)
  local original_tab = vim.api.nvim_get_current_tabpage()
  local original_win = vim.api.nvim_get_current_win()
  local tabs_before, windows_before = snapshot_windows()

  local scratch = vim.api.nvim_create_buf(false, true)
  local opened, temp_win = pcall(vim.api.nvim_open_win, scratch, false, {
    relative = "editor",
    row = vim.o.lines + 10,
    col = 0,
    width = 1,
    height = 1,
    style = "minimal",
    focusable = true,
  })

  if not opened then
    if vim.api.nvim_buf_is_valid(scratch) then
      vim.api.nvim_buf_delete(scratch, { force = true })
    end
    vim.notify("Could not create command output workspace: " .. tostring(temp_win), vim.log.levels.ERROR)
    return
  end

  local ran, result = pcall(vim.api.nvim_win_call, temp_win, function()
    vim.cmd(command_line)
    local buf = vim.api.nvim_get_current_buf()
    return {
      lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false),
      filetype = vim.bo[buf].filetype,
    }
  end)

  cleanup_command_windows(tabs_before, windows_before, temp_win, scratch)

  if vim.api.nvim_tabpage_is_valid(original_tab) then
    pcall(vim.api.nvim_set_current_tabpage, original_tab)
  end
  if vim.api.nvim_win_is_valid(original_win) then
    pcall(vim.api.nvim_set_current_win, original_win)
  end

  if not ran then
    vim.notify(tostring(result), vim.log.levels.ERROR)
    return
  end

  M.open_output(title, result.lines, result.filetype)
end

local function handle_command(command_line)
  local parsed = parse_command(command_line)
  if
    not parsed
    or #(parsed.range or {}) > 0
    or (parsed.count and parsed.count >= 0)
    or (parsed.reg and parsed.reg ~= "")
  then
    return false
  end

  local command = parsed.cmd:lower()
  local args = parsed.args or {}

  -- :messages is special under UI2: Neovim sends it to the native pager.
  -- CVIM keeps inspection output in its own shared bordered float instead.
  if command == "messages" then
    if #args > 0 then
      return false
    end

    vim.schedule(function()
      M.show_history()
    end)
    return true
  end

  if command == "checkhealth" then
    vim.schedule(function()
      run_health_command(command_line)
    end)
    return true
  end

  if command == "help" or command == "h" or command == "man" then
    local title = command == "man" and "Man" or "Help"
    vim.schedule(function()
      run_buffer_command(command_line, title)
    end)
    return true
  end

  -- These forms mutate highlight state; leave them to Neovim.
  if command == "highlight" then
    local action = (args[1] or ""):lower()
    if action == "clear" or action == "default" then
      return false
    end
  end

  local limits = output_commands[command]
  if not limits or #args < limits.min or #args > limits.max then
    return false
  end

  local ok, result = pcall(vim.api.nvim_exec2, command_line, { output = true })
  if not ok then
    return false
  end

  vim.schedule(function()
    M.open_output(command, result.output)
  end)
  return true
end

function M.show_history()
  local ui2 = require("soul.ui.ui2")
  local restore_ui2 = ui2.is_enabled()

  -- UI2 handles :messages by opening its own pager. Temporarily restore the
  -- native message renderer so execute() can capture the history as text.
  if restore_ui2 then
    local restored, err = ui2.restore()
    if not restored then
      vim.notify("Could not prepare message history: " .. tostring(err), vim.log.levels.ERROR)
      return false
    end
  end

  local ok, output = pcall(vim.fn.execute, "messages")

  if restore_ui2 then
    local enabled, err = ui2.setup()
    if not enabled then
      vim.notify("Could not restore Neovim UI2: " .. tostring(err), vim.log.levels.ERROR)
    end
  end

  if not ok then
    vim.notify(tostring(output), vim.log.levels.ERROR)
    return false
  end

  M.open_output("Messages", output, "text")
  return true
end

function M.setup()
  if M.setup_done then
    return true
  end

  local ui2 = require("soul.ui.ui2")
  local enabled, err = ui2.setup()
  if not enabled then
    vim.notify("Neovim UI2 is unavailable; using native messages.\n" .. tostring(err), vim.log.levels.WARN)
  end

  vim.keymap.set("c", "<CR>", function()
    if vim.fn.getcmdtype() ~= ":" then
      return "<CR>"
    end

    local command_line = vim.fn.getcmdline()
    local trimmed = vim.trim(command_line)
    if trimmed == "" then
      return "<CR>"
    end
    if handle_command(command_line) then
      return "<C-c>"
    end

    return "<CR>"
  end, {
    expr = true,
    noremap = true,
    desc = "Open inspectable command output in a floating window",
  })

  M.setup_done = true
  return true
end

-- Kept private to CVIM; exposed for focused regression coverage.
M._run_health_command = run_health_command
M._run_buffer_command = run_buffer_command
M._handle_command = handle_command

return M
