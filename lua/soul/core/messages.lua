local M = {}

local function open_messages()
  local output = vim.api.nvim_exec2("messages", { output = true }).output
  local lines = vim.split(output, "\n", { plain = true })

  if #lines == 0 or (#lines == 1 and lines[1] == "") then
    lines = { "No messages." }
  end

  local width = math.min(80, vim.o.columns - 4)
  local height = math.min(#lines, vim.o.lines - 4)
  local row = math.floor((vim.o.lines - height) / 2) - 1
  local col = math.floor((vim.o.columns - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].modifiable = false
  vim.bo[buf].swapfile = false

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = math.max(0, row),
    col = math.max(0, col),
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
  })

  vim.wo[win].wrap = true
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true })
  vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = buf, silent = true })
end

function M.setup()
  vim.api.nvim_create_user_command("Messages", open_messages, {
    desc = "Show message history in a floating window",
  })

  vim.keymap.set("c", "<CR>", function()
    if vim.fn.getcmdtype() == ":" and vim.fn.getcmdline() == "messages" then
      return "<C-u>Messages<CR>"
    end

    return "<CR>"
  end, {
    expr = true,
    noremap = true,
    desc = "Open message history in a floating window",
  })
end

return M
