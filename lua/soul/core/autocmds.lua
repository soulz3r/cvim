local M = {}
function M.setup()
  local group = vim.api.nvim_create_augroup("CVIMCore", { clear = true })
  vim.api.nvim_create_autocmd("BufWinEnter", {
    group = group,
    callback = function()
      vim.opt_local.formatoptions:remove({ "c", "r", "o" })
    end,
  })
  vim.api.nvim_create_autocmd({ "FocusGained", "TermLeave" }, { group = group, command = "checktime" })
  vim.api.nvim_create_autocmd("TextYankPost", {
    group = group,
    callback = function()
      vim.hl.on_yank({ higroup = "Visual", timeout = 80 })
    end,
  })
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = { "gitcommit", "markdown", "text" },
    callback = function()
      vim.opt_local.wrap = true
    end,
  })
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = { "help", "qf", "man" },
    callback = function(args)
      vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = args.buf, silent = true, desc = "Close utility window" })
    end,
  })
end
return M
