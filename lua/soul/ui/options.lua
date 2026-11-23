local M = {}

function M.setup()
  -- Command line and completion
  vim.opt.cmdheight = 0
  vim.opt.completeopt = { "menu", "menuone", "noselect" }
  vim.opt.pumheight = 10
  vim.opt.pumborder = "rounded"
  vim.opt.pumblend = 0

  -- UI visibility
  vim.opt.showmode = false
  vim.opt.showtabline = 0
  vim.opt.laststatus = 0
  vim.opt.showcmd = false
  vim.opt.ruler = false
  vim.opt.title = false

  -- Editor appearance
  vim.opt.cursorline = true
  vim.opt.number = true
  vim.opt.relativenumber = true
  vim.opt.numberwidth = 2
  vim.opt.signcolumn = "yes"
  vim.opt.wrap = false
  vim.opt.scrolloff = 4
  vim.opt.sidescrolloff = 8

  -- Colors and borders
  vim.opt.termguicolors = true
  vim.opt.winborder = "rounded"
  vim.opt.fillchars:append({
    eob = " ",
    stl = " ",
  })

  -- GUI font (Neovide, etc.)
  vim.opt.guifont = "Maple Mono:h9"

  -- Health check UI
  vim.g.health = { style = "float" }

  -- Transparent floating windows
  local border_backgrounds = {
    "FloatBorder",
    "PmenuBorder",
    "NormalFloat",
    "Pmenu",
    "FloatTitle",
    "FloatFooter",
  }

  local function clear_border_backgrounds()
    for _, name in ipairs(border_backgrounds) do
      local highlights = vim.api.nvim_get_hl(0, {
        name = name,
        link = false,
      })

      highlights.bg = "NONE"

      vim.api.nvim_set_hl(0, name, highlights)
    end
  end

  local group = vim.api.nvim_create_augroup("CVIMUIHighlights", {
    clear = true,
  })

  vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    callback = clear_border_backgrounds,
  })

  clear_border_backgrounds()
end

return M

