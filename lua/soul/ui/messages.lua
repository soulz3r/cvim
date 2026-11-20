local M = {}

local function setup_native_messages()
  -- UI2 is currently the Neovim 0.12 native command-area message frontend.
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

local function open_messages()
  local output = vim.api.nvim_exec2("messages", { output = true }).output
  local lines = vim.split(output, "\n", { plain = true })

  if #lines == 0 or (#lines == 1 and lines[1] == "") then
    lines = { "No messages." }
  end

  -- Keep the history readable without letting it take over the editor.
  local available_width = math.max(1, vim.o.columns - 4)
  local available_height = math.max(1, vim.o.lines - vim.o.cmdheight - 4)
  local width = math.min(available_width, math.max(1, math.min(100, math.floor(vim.o.columns * 0.8))))
  local height = math.min(available_height, math.max(1, math.min(30, math.floor((vim.o.lines - vim.o.cmdheight) * 0.75))))
  local row = math.floor((vim.o.lines - vim.o.cmdheight - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].modifiable = false
  vim.bo[buf].swapfile = false

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
    title = " Messages ",
    title_pos = "center",
  })

  vim.wo[win].wrap = true
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true })
  vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = buf, silent = true })
end

function M.setup()
  setup_native_messages()

  vim.api.nvim_create_user_command("Messages", open_messages, {
    desc = "Show message history in a centered, titled window",
  })

  vim.keymap.set("c", "<CR>", function()
    if vim.fn.getcmdtype() == ":" and vim.fn.getcmdline() == "messages" then
      return "<C-u>Messages<CR>"
    end

    return "<CR>"
  end, {
    expr = true,
    noremap = true,
    desc = "Open message history in a centered window",
  })
end

return M
