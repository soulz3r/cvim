local M = {}
function M.setup()
  vim.opt.backup = false
  vim.opt.report = 9999
  vim.opt.conceallevel = 0
  vim.opt.hlsearch = true
  vim.opt.inccommand = "split"
  vim.opt.ignorecase = true
  vim.opt.mouse = "a"
  vim.opt.smartcase = true
  vim.opt.smartindent = true
  vim.opt.splitbelow = true
  vim.opt.splitright = true
  vim.opt.splitkeep = "screen"
  vim.opt.swapfile = false
  vim.opt.timeoutlen = 500
  vim.opt.undofile = true
  vim.opt.updatetime = 100
  vim.opt.writebackup = false
  vim.opt.expandtab = true
  vim.opt.shiftwidth = 2
  vim.opt.tabstop = 2
  vim.g.loaded_node_provider = 0
  vim.g.loaded_perl_provider = 0
  vim.g.loaded_python3_provider = 0
  vim.g.loaded_ruby_provider = 0
  vim.cmd("set whichwrap+=<,>,[,],h,l")
  vim.cmd([[set iskeyword+=-]])
  vim.g.netrw_banner = 0
  vim.g.netrw_mouse = 2
  vim.opt.clipboard = "unnamedplus"
  local platform = require("soul.core.platform")
  local paths = require("soul.core.helpers.paths")
  if platform.is_wsl and paths.wsl_clipboard then
    local copy_command = vim.fn.shellescape(paths.wsl_clipboard.copy)
    local paste_command = vim.fn.shellescape(paths.wsl_clipboard.paste)
      .. " -NoLogo -NoProfile -Command "
      .. vim.fn.shellescape('[Console]::Out.Write((Get-Clipboard -Raw).Replace("`r", ""))')
    vim.g.clipboard = {
      name = "WslClipboard",
      copy = { ["+"] = copy_command, ["*"] = copy_command },
      paste = { ["+"] = paste_command, ["*"] = paste_command },
      cache_enabled = 0,
    }
  end
  if platform.is_windows then
    vim.opt.shell = paths.pwsh

    local shell_name = vim.fn.fnamemodify(paths.pwsh, ":t"):lower()
    local shell_flags = table.concat({
      "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command",
      "[Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();",
      "$PSDefaultParameterValues['Out-File:Encoding']='utf8';",
    }, " ")

    if shell_name == "pwsh" or shell_name == "pwsh.exe" then
      shell_flags = shell_flags .. " $PSStyle.OutputRendering = 'PlainText'; $__SuppressAnsiEscapeSequences = 1;"
    end

    vim.opt.shellcmdflag = shell_flags
    vim.opt.shellpipe = "> %s 2>&1"
    vim.opt.shellredir = "> %s 2>&1"
    vim.opt.shellquote = ""
    vim.opt.shellxquote = ""
  end
end
return M
