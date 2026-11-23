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

  -- Write and quit.
  map("n", "<leader>w", "<cmd>write<CR>", described("Write file"))
  map("n", "<leader>q", "<cmd>confirm qall<CR>", described("Quit Neovim"))

  -- Neovim: <leader>n...
  map("n", "<leader>nm", function()
    require("soul.ui.messages").show_history()
  end, described("Message history"))
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

  -- Tabs: <leader>t...
  map("n", "<leader>tt", "<cmd>tabs<CR>", described("List tabs"))
  map("n", "<leader>tn", "<cmd>tabnext<CR>", described("Next tab"))
  map("n", "<leader>tp", "<cmd>tabprevious<CR>", described("Previous tab"))
  map("n", "<leader>td", "<cmd>tabclose<CR>", described("Close tab"))

  -- Windows: <leader>s...
  map("n", "<leader>sv", "<cmd>tab split<CR><cmd>vsplit<CR>", described("Open vertical splits in a new tab"))
  map("n", "<leader>sh", "<cmd>tab split<CR><cmd>split<CR>", described("Open horizontal splits in a new tab"))
  map("n", "<leader>se", "<C-w>=", described("Equalize window sizes"))
  map("n", "<leader>so", "<cmd>only<CR>", described("Close other windows"))
  map("n", "<leader>sr", "<C-w>r", described("Rotate windows"))
  map("n", "<leader>sx", "<cmd>close<CR>", described("Close split"))

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

  -- Working directory: <leader>c...
  local function current_file_dir()
    local file = vim.api.nvim_buf_get_name(0)
    if file == "" then
      vim.notify("Current buffer has no file", vim.log.levels.WARN)
      return nil
    end

    return vim.fn.fnamemodify(file, ":p:h")
  end

  map("n", "<leader>cd", function()
    local dir = current_file_dir()
    if dir then
      vim.cmd.cd(vim.fn.fnameescape(dir))
    end
  end, described("Change cwd to file directory"))

  map("n", "<leader>cr", function()
    local root = vim.fs.root(0, { ".git" })
    if not root then
      vim.notify("No Git project root found", vim.log.levels.WARN)
      return
    end

    vim.cmd.cd(vim.fn.fnameescape(root))
  end, described("Change cwd to Git root"))

  map({ "i", "x" }, ",,", "<Esc>", opts)
  map("n", ",,", "<cmd>nohlsearch<CR>", opts)
end

return M
