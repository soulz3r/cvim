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
  map("n", "<leader>ww", "<cmd>write<CR>", described("Write file"))
  map("n", "<leader>wa", "<cmd>wall<CR>", described("Write all files"))
  map("n", "<leader>wq", "<cmd>wq<CR>", described("Write and quit"))

  -- Quit: <leader>q...
  map("n", "<leader>qq", "<cmd>quit<CR>", described("Quit window"))
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

  -- Buffers: <leader>b...
  map("n", "<leader>bb", "<cmd>buffers<CR>", described("List buffers"))
  map("n", "<leader>bn", "<cmd>bnext<CR>", described("Next buffer"))
  map("n", "<leader>bp", "<cmd>bprevious<CR>", described("Previous buffer"))
  map("n", "<leader>bd", "<cmd>bdelete<CR>", described("Delete buffer"))
  map("n", "<leader>bD", "<cmd>bdelete!<CR>", described("Force delete buffer"))
  map("n", "<leader>br", "<cmd>edit<CR>", described("Re-read current file"))

  -- Windows: <leader>s...
  map("n", "<leader>sv", "<cmd>vsplit<CR>", described("Split window vertically"))
  map("n", "<leader>sh", "<cmd>split<CR>", described("Split window horizontally"))
  map("n", "<leader>se", "<C-w>=", described("Equalize window sizes"))
  map("n", "<leader>so", "<cmd>only<CR>", described("Close other windows"))
  map("n", "<leader>sr", "<C-w>r", described("Rotate windows"))
  map("n", "<leader>sx", "<cmd>close<CR>", described("Close split"))

  -- Tabs: <leader>t...
  map("n", "<leader>tn", "<cmd>tabnew<CR>", described("New tab"))
  map("n", "<leader>tc", "<cmd>tabclose<CR>", described("Close tab"))
  map("n", "<leader>to", "<cmd>tabonly<CR>", described("Close other tabs"))
  map("n", "<leader>tl", "<cmd>tabnext<CR>", described("Next tab"))
  map("n", "<leader>th", "<cmd>tabprevious<CR>", described("Previous tab"))
  map("n", "<leader>t1", "1gt", described("Go to tab 1"))
  map("n", "<leader>t2", "2gt", described("Go to tab 2"))
  map("n", "<leader>t3", "3gt", described("Go to tab 3"))
  map("n", "<leader>t4", "4gt", described("Go to tab 4"))
  map("n", "<leader>t5", "5gt", described("Go to tab 5"))

  -- Diagnostics: <leader>d...
  map("n", "<leader>dd", vim.diagnostic.open_float, described("Show line diagnostics"))
  map("n", "<leader>dn", function()
    vim.diagnostic.jump({ count = 1 })
  end, described("Next diagnostic"))
  map("n", "<leader>dp", function()
    vim.diagnostic.jump({ count = -1 })
  end, described("Previous diagnostic"))
  map("n", "<leader>dq", vim.diagnostic.setqflist, described("Diagnostics to quickfix"))
  map("n", "<leader>dQ", vim.diagnostic.setloclist, described("Diagnostics to location list"))
  map("n", "<leader>dc", function()
    vim.diagnostic.reset(nil, 0)
  end, described("Clear buffer diagnostics"))

  -- LSP / code: <leader>c...
  map("n", "<leader>ca", vim.lsp.buf.code_action, described("Code action"))
  map("n", "<leader>cd", vim.lsp.buf.definition, described("Go to definition"))
  map("n", "<leader>cD", vim.lsp.buf.declaration, described("Go to declaration"))
  map("n", "<leader>ci", vim.lsp.buf.implementation, described("Go to implementation"))
  map("n", "<leader>cr", vim.lsp.buf.references, described("Find references"))
  map("n", "<leader>cn", vim.lsp.buf.rename, described("Rename symbol"))
  map("n", "<leader>ct", vim.lsp.buf.type_definition, described("Go to type definition"))
  map("n", "<leader>cf", function()
    vim.lsp.buf.format({ async = true })
  end, described("Format buffer"))
  map("n", "<leader>ch", vim.lsp.buf.hover, described("Hover documentation"))
  map("n", "<leader>cs", vim.lsp.buf.document_symbol, described("Document symbols"))
  map("n", "<leader>cS", vim.lsp.buf.workspace_symbol, described("Workspace symbols"))
  map("n", "<leader>cI", vim.lsp.buf.incoming_calls, described("Incoming calls"))
  map("n", "<leader>cO", vim.lsp.buf.outgoing_calls, described("Outgoing calls"))

  -- UI toggles: <leader>u...
  map("n", "<leader>uw", function()
    vim.wo.wrap = not vim.wo.wrap
  end, described("Toggle line wrap"))
  map("n", "<leader>un", function()
    vim.wo.number = not vim.wo.number
  end, described("Toggle line numbers"))
  map("n", "<leader>ur", function()
    vim.wo.relativenumber = not vim.wo.relativenumber
  end, described("Toggle relative numbers"))
  map("n", "<leader>us", function()
    vim.wo.spell = not vim.wo.spell
  end, described("Toggle spell checking"))
  map("n", "<leader>ul", function()
    vim.wo.list = not vim.wo.list
  end, described("Toggle list characters"))
  map("n", "<leader>uc", function()
    vim.wo.cursorline = not vim.wo.cursorline
  end, described("Toggle cursor line"))
  map("n", "<leader>uS", function()
    vim.wo.signcolumn = vim.wo.signcolumn == "no" and "yes" or "no"
  end, described("Toggle sign column"))

  -- Working directory.
  map("n", "<leader>wd", function()
    local file = vim.api.nvim_buf_get_name(0)
    if file == "" then
      return
    end
    vim.cmd.cd(vim.fn.fnameescape(vim.fn.fnamemodify(file, ":h")))
  end, described("Change to file directory"))

  map({ "i", "x" }, ",,", "<Esc>", opts)
  map("n", ",,", "<cmd>nohlsearch<CR>", opts)
end

return M
