local M = {}

local function setup_native_messages()
  -- UI2 is Neovim 0.12's native command-area message frontend.
  -- Keep this compatibility-sensitive integration isolated in the UI layer.
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
      if generation == message_generation then
        messages.msg_clear()
      end
    end, 5000)
  end
end

function M.open_output(title, output, filetype)
  local lines = type(output) == "table" and output or vim.split(output or "", "\n", { plain = true })
  if #lines == 0 or (#lines == 1 and lines[1] == "") then
    lines = { "No output." }
  end

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
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
    title = " " .. title .. " ",
    title_pos = "center",
  })

  vim.wo[win].wrap = false
  vim.wo[win].cursorline = false
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true })
  vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = buf, silent = true })
end

local function open_messages()
  local output = vim.api.nvim_exec2("messages", { output = true }).output
  M.open_output("Messages", output)
end

-- These commands only display information. Mutating commands are deliberately
-- excluded so typing a mapping or option assignment can never be swallowed.
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
  messages = { min = 0, max = 0 },
}

local function parse_command(command_line)
  local ok, parsed = pcall(vim.api.nvim_parse_cmd, command_line, {})
  if not ok or parsed.mods and (parsed.mods.bang or parsed.mods.confirm) then
    return nil
  end

  return parsed
end

local function run_buffer_command(command_line, title, original_win, original_buf)
  local ok, err = pcall(vim.cmd, command_line)
  if not ok then
    vim.notify(tostring(err), vim.log.levels.ERROR)
    return
  end

  local result_buf = vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(result_buf) or result_buf == original_buf then
    return
  end

  local lines = vim.api.nvim_buf_get_lines(result_buf, 0, -1, false)
  local filetype = vim.bo[result_buf].filetype

  -- Restore the user's previous editing window before presenting the result.
  if vim.api.nvim_win_is_valid(original_win) then
    if vim.api.nvim_get_current_win() ~= original_win then
      local current_win = vim.api.nvim_get_current_win()
      if vim.api.nvim_win_is_valid(current_win) and #vim.api.nvim_list_wins() > 1 then
        pcall(vim.api.nvim_win_close, current_win, true)
      end
    end
    if vim.api.nvim_win_is_valid(original_win) then
      pcall(vim.api.nvim_win_set_buf, original_win, original_buf)
      vim.api.nvim_set_current_win(original_win)
    end
  end

  M.open_output(title, lines, filetype)
end

local function handle_command(command_line)
  local parsed = parse_command(command_line)
  if not parsed or parsed.range or parsed.count or parsed.register then
    return false
  end

  local command = parsed.cmd:lower()
  local args = parsed.args or {}

  if command == "checkhealth" then
    local original_win = vim.api.nvim_get_current_win()
    local original_buf = vim.api.nvim_get_current_buf()
    vim.schedule(function()
      run_buffer_command(command_line, "Checkhealth", original_win, original_buf)
    end)
    return true
  end

  -- Help and man pages are generated as buffers/windows, not command output.
  if command == "help" or command == "h" or command == "man" then
    local original_win = vim.api.nvim_get_current_win()
    local original_buf = vim.api.nvim_get_current_buf()
    vim.schedule(function()
      run_buffer_command(command_line, command == "man" and "Man" or "Help", original_win, original_buf)
    end)
    return true
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

function M.setup()
  setup_native_messages()

  vim.api.nvim_create_user_command("Messages", open_messages, {
    desc = "Show message history in a centered, titled window",
  })

  vim.keymap.set("c", "<CR>", function()
    if vim.fn.getcmdtype() ~= ":" then
      return "<CR>"
    end

    local command_line = vim.fn.getcmdline()
    if vim.trim(command_line) == "" then
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
end

return M
