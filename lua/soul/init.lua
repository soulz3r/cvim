local M = {
  loaded = false,
}

function M.setup()
  if M.loaded then
    return
  end

  if vim.fn.has("nvim-0.12") ~= 1 then
    error("CVIM requires Neovim 0.12 or newer")
  end

  vim.g.mapleader = " "
  vim.g.maplocalleader = " "

  require("soul.core.lifecycle").setup()
  require("soul.core.options").setup()
  require("soul.core.autocmds").setup()
  require("soul.ui").setup()
  require("soul.core.keymaps").setup()
  require("soul.lazy").setup()

  M.loaded = true
  vim.g.cvim_config_loaded = true
end

M.setup()

return M
