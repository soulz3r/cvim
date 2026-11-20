local M = {
    {
        "jinh0/eyeliner.nvim",
        event = "VeryLazy",
        opts = {
            highlight_on_key = true,
            dim = true,
            max_length = 9999,
            disabled_filetypes = { "alpha" },
            default_keymaps = true,
        },
    },
}

return M
