local M = {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ":TSUpdate",
}

M.config = function()
  require("nvim-treesitter").setup({
    ensure_installed = {
      "c",
      "lua",
      "vim",
      "vimdoc",
      "bash",
      "markdown",
      "markdown_inline",
    },
  })

  vim.api.nvim_create_autocmd("FileType", {
    callback = function(args)
      local lang = vim.treesitter.language.get_lang(args.match)

      if lang then
        pcall(vim.treesitter.start, args.buf, lang)
      end
    end,
  })
end

return M

