local M={}
function M.setup()
  vim.opt.cmdheight=0
  vim.opt.completeopt={"menu","menuone","noselect"}
  vim.opt.pumheight=10
  vim.opt.pumborder="rounded"
  vim.opt.pumblend=0
  vim.opt.showmode=false
  vim.opt.showtabline=0
  vim.opt.laststatus=0
  vim.opt.showcmd=false
  vim.opt.ruler=false
  vim.opt.cursorline=true
  vim.opt.number=true
  vim.opt.relativenumber=true
  vim.opt.numberwidth=2
  vim.opt.signcolumn="yes"
  vim.opt.wrap=false
  vim.opt.scrolloff=4
  vim.opt.sidescrolloff=8
  vim.opt.termguicolors=true
  vim.opt.guifont="ComicShannsMono Nerd Font:h9"
  vim.opt.title=false
  vim.opt.fillchars=vim.opt.fillchars+"eob: "
  vim.opt.fillchars:append({stl=" "})
  vim.opt.winborder="rounded"
  vim.g.health={style="float"}
  local border_backgrounds={"FloatBorder","PmenuBorder","NormalFloat","Pmenu","FloatTitle","FloatFooter"}
  local function clear_border_backgrounds()
    for _,name in ipairs(border_backgrounds) do
      local highlights=vim.api.nvim_get_hl(0,{name=name,link=false})
      highlights.bg="NONE"
      vim.api.nvim_set_hl(0,name,highlights)
    end
  end
  local group=vim.api.nvim_create_augroup("CVIMUIHighlights",{clear=true})
  vim.api.nvim_create_autocmd("ColorScheme",{group=group,callback=clear_border_backgrounds})
  clear_border_backgrounds()
end
return M
