local M = {}

local function setup_native_messages()
  local ui2 = require("vim._core.ui2")
  ui2.enable({ msg = { targets = "cmd" } })
  local messages = require("vim._core.ui2.messages")
  local original_msg_show = messages.msg_show
  local message_generation = 0
  messages.msg_show = function(...)
    original_msg_show(...)
    message_generation = message_generation + 1
    local generation = message_generation
    vim.defer_fn(function()
      if generation == message_generation then messages.msg_clear() end
    end, 5000)
  end
end

function M.open_output(title, output, filetype)
  local lines = type(output) == "table" and output or vim.split(output or "", "\n", { plain = true })
  if #lines == 0 or (#lines == 1 and lines[1] == "") then lines = { "No output." } end
  local width = math.min(math.max(1, vim.o.columns - 4), math.max(1, math.min(120, math.floor(vim.o.columns * 0.85))))
  local height = math.min(math.max(1, vim.o.lines - vim.o.cmdheight - 4), math.max(1, math.min(32, math.floor((vim.o.lines - vim.o.cmdheight) * 0.78))))
  local row = math.max(0, math.floor((vim.o.lines - vim.o.cmdheight - height) / 2))
  local col = math.max(0, math.floor((vim.o.columns - width) / 2))
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].modifiable = false
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = filetype or "vim"
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor", row = row, col = col, width = width, height = height,
    style = "minimal", border = "rounded", title = " " .. title .. " ", title_pos = "center",
  })
  vim.wo[win].wrap = false
  vim.wo[win].cursorline = false
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true })
  vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = buf, silent = true })
end

local function open_messages()
  M.open_output("Messages", vim.api.nvim_exec2("messages", { output = true }).output)
end

local output_commands = {
  map = { min = 0, max = 1 }, nmap = { min = 0, max = 1 },
  vmap = { min = 0, max = 1 }, xmap = { min = 0, max = 1 },
  smap = { min = 0, max = 1 }, omap = { min = 0, max = 1 },
  imap = { min = 0, max = 1 }, lmap = { min = 0, max = 1 },
  cmap = { min = 0, max = 1 }, tmap = { min = 0, max = 1 },
  scriptnames = { min = 0, max = 0 }, registers = { min = 0, max = 1 },
  highlight = { min = 0, max = 1 }, marks = { min = 0, max = 1 },
  jumps = { min = 0, max = 0 }, changes = { min = 0, max = 0 },
  digraphs = { min = 0, max = 1 }, version = { min = 0, max = 0 },
  ls = { min = 0, max = 0 }, files = { min = 0, max = 0 },
  buffers = { min = 0, max = 0 }, history = { min = 0, max = 1 },
  autocmd = { min = 0, max = 2 },
}

local function parse_command(command_line)
  local ok, parsed = pcall(vim.api.nvim_parse_cmd, command_line, {})
  if not ok or parsed.bang or (parsed.mods and parsed.mods.confirm) then return nil end
  return parsed
end

local function run_buffer_command(command_line, title)
  local original_tab = vim.api.nvim_get_current_tabpage()
  local original_win = vim.api.nvim_get_current_win()
  local windows_before = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do windows_before[win] = true end

  local scratch = vim.api.nvim_create_buf(false, true)
  local ok, temp_win = pcall(vim.api.nvim_open_win, scratch, false, {
    relative = "editor",
    row = vim.o.lines + 10,
    col = 0,
    width = 1,
    height = 1,
    style = "minimal",
    focusable = true,
  })
  if not ok then
    vim.api.nvim_buf_delete(scratch, { force = true })
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

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if not windows_before[win] and win ~= temp_win and vim.api.nvim_win_is_valid(win) then
      pcall(vim.api.nvim_win_close, win, true)
    end
  end
  if vim.api.nvim_win_is_valid(temp_win) then
    pcall(vim.api.nvim_win_close, temp_win, true)
  end
  if vim.api.nvim_buf_is_valid(scratch) then
    pcall(vim.api.nvim_buf_delete, scratch, { force = true })
  end

  if not ran then
    vim.notify(tostring(result), vim.log.levels.ERROR)
    return
  end
  if vim.api.nvim_tabpage_is_valid(original_tab) then
    pcall(vim.api.nvim_set_current_tabpage, original_tab)
  end
  if vim.api.nvim_win_is_valid(original_win) then
    pcall(vim.api.nvim_set_current_win, original_win)
  end
  M.open_output(title, result.lines, result.filetype)
end

local function handle_command(command_line)
  local parsed = parse_command(command_line)
  if not parsed
    or #(parsed.range or {}) > 0
    or (parsed.count and parsed.count >= 0)
    or (parsed.reg and parsed.reg ~= "")
  then
    return false
  end
  local command = parsed.cmd:lower()
  local args = parsed.args or {}
  if command == "checkhealth" or command == "help" or command == "h" or command == "man" then
    local title = command == "checkhealth" and "Checkhealth" or (command == "man" and "Man" or "Help")
    vim.schedule(function() run_buffer_command(command_line, title) end)
    return true
  end
  local limits = output_commands[command]
  if not limits or #args < limits.min or #args > limits.max then return false end
  local ok, result = pcall(vim.api.nvim_exec2, command_line, { output = true })
  if not ok then return false end
  vim.schedule(function() M.open_output(command, result.output) end)
  return true
end

function M.setup()
  setup_native_messages()
  vim.api.nvim_create_user_command("Messages", open_messages, {
    desc = "Show message history in a centered, titled window",
  })
  vim.keymap.set("c", "<CR>", function()
    if vim.fn.getcmdtype() ~= ":" then return "<CR>" end
    local command_line = vim.fn.getcmdline()
    local trimmed = vim.trim(command_line)
    if trimmed == "" then return "<CR>" end
    if trimmed:lower() == "messages" then return "<C-u>Messages<CR>" end
    if handle_command(command_line) then return "<C-c>" end
    return "<CR>"
  end, {
    expr = true, noremap = true,
    desc = "Open inspectable command output in a floating window",
  })
end

return M
