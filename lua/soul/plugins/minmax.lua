local M = {
  {
    "soulz3r/minmax.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("minmax")
    end,
  },
}
return M
