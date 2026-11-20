local function setup(module)
  return function()
    require("soul.core.helpers.mini." .. module).setup()
  end
end

local M = {
  {
    "nvim-mini/mini.files",
    dependencies = { "nvim-mini/mini.icons" },
    keys = {
      {
        "<leader>e",
        function()
          require("mini.files").open(vim.fn.getcwd())
        end,
        desc = "Open Mini.files",
      },
    },
    config = setup("files"),
  },
  { "nvim-mini/mini.icons", event = "VeryLazy", config = setup("icons") },
  { "nvim-mini/mini.pairs", event = "InsertEnter", config = setup("pairs") },
  { "nvim-mini/mini.ai", event = { "BufReadPost", "BufNewFile" }, config = setup("ai") },
  { "nvim-mini/mini.surround", event = { "BufReadPost", "BufNewFile" }, config = setup("surround") },
}

return M
