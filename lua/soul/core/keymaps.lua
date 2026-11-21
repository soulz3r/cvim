local M = {}

function M.setup()
  local map = vim.keymap.set
  local opts = { noremap = true, silent = true }
  local function described(desc)
    return vim.tbl_extend("force", opts, { desc = desc })
  end

  -- Window and buffer navigation.
  map("n", "<C-h>", "<C-w>h", opts)
  map("n", "<C-j>", "<C-w>j", opts)
  map("n", "<C-k>", "<C-w>k", opts)
  map("n", "<C-l>", "<C-w>l", opts)
  map("n", "<M-Tab>", "<C-^>", opts)

  -- Search and movement.
  map("n", "n", "nzzzv", opts)
  map("n", "N", "Nzzzv", opts)
  map("n", "*", "*zz", opts)
  map("n", "#", "#zz", opts)
  map("n", "g*", "g*zz", opts)
  map("n", "g#", "g#zz", opts)
  map({ "n", "x" }, "j", "gj", opts)
  map({ "n", "x" }, "k", "gk", opts)
  map({ "n", "o", "x" }, "<S-h>", "^", opts)
  map({ "n", "o", "x" }, "<S-l>", "g_", opts)
  map("x", "p", [["_dP]], opts)
  map("n", "J", "mzJ`z", opts)
  map("n", "<C-d>", "<C-d>zz", opts)
  map("n", "<C-u>", "<C-u>zz", opts)
  map("n", "<M-j>", ":m .+1<CR>==", opts)
  map("n", "<M-k>", ":m .-2<CR>==", opts)
  map("x", "<M-j>", ":m '>+1<CR>gv=gv", opts)
  map("x", "<M-k>", ":m '<-2<CR>gv=gv", opts)

  -- Write: <leader>w...
  map("n", "<leader>w", "<cmd>write<CR>", described("Write file"))
  map("n", "<leader>wa", "<cmd>wall<CR>", described("Write all files"))
  map("n", "<leader>wq", "<cmd>wq<CR>", described("Write and quit"))

  -- Quit: <leader>q...
  map("n", "<leader>q", "<cmd>quit<CR>", described("Quit window"))
  map("n", "<leader>qa", "<cmd>quitall<CR>", described("Quit all"))
  map("n", "<leader>qf", "<cmd>quit!<CR>", described("Force quit window"))
  map("n", "<leader>qA", "<cmd>quitall!<CR>", described("Force quit all"))

  -- Neovim: <leader>n...
  map("n", "<leader>nm", "<cmd>Messages<CR>", described("Message history"))
  map("n", "<leader>nc", "<cmd>checkhealth<CR>", described("Check health"))
  map("n", "<leader>nC", function()
    local init = vim.fn.stdpath("config") .. "/init.lua"
    vim.cmd("edit " .. vim.fn.fnameescape(init))
  end, described("Open init.lua"))
  map("n", "<leader>nr", function()
    local init = vim.fn.stdpath("config") .. "/init.lua"
    vim.cmd("source " .. vim.fn.fnameescape(init))
  end, described("Reload init.lua"))
  map("n", "<leader>nv", "<cmd>version<CR>", described("Neovim version"))
  map("n", "<leader>nS", "<cmd>scriptnames<CR>", described("Loaded scripts"))

  map("n", "<leader>cd", function()
    local file = vim.api.nvim_buf_get_name(0)
    if file == "" then
      return
    end
    vim.cmd.cd(vim.fn.fnameescape(vim.fn.fnamemodify(file, ":h")))
  end, opts)

  map({ "i", "x" }, ",,", "<Esc>", opts)
  map("n", ",,", "<cmd>nohlsearch<CR>", opts)
end

return M
