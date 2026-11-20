local M = {
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        cmd = "Telescope",
        keys = {
            { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find files" },
            { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Live grep" },
            { "<leader>fs", "<cmd>Telescope grep_string<CR>", desc = "Search word under cursor" },
            { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Find buffers" },
            { "<leader>fo", "<cmd>Telescope oldfiles<CR>", desc = "Recent files" },
            { "<leader>fc", "<cmd>Telescope colorscheme<CR>", desc = "Colorschemes" },
            { "<leader>fC", "<cmd>Telescope commands<CR>", desc = "Commands" },
            { "<leader>fk", "<cmd>Telescope keymaps<CR>", desc = "Keymaps" },
            { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Help tags" },
            { "<leader>fp", "<cmd>Telescope builtin<CR>", desc = "Telescope pickers" },
            { "<leader>fr", "<cmd>Telescope resume<CR>", desc = "Resume picker" },
            { "<leader>fd", "<cmd>Telescope diagnostics<CR>", desc = "Diagnostics" },
            { "<leader>fq", "<cmd>Telescope quickfix<CR>", desc = "Quickfix list" },
            { "<leader>fR", "<cmd>Telescope registers<CR>", desc = "Registers" },
            { "<leader>fm", "<cmd>Telescope marks<CR>", desc = "Marks" },
            { "<leader>fj", "<cmd>Telescope jumplist<CR>", desc = "Jump list" },
            { "<leader>fO", "<cmd>Telescope vim_options<CR>", desc = "Neovim options" },
            { "<leader>fH", "<cmd>Telescope highlights<CR>", desc = "Highlight groups" },
            { "<leader>gs", "<cmd>Telescope git_status<CR>", desc = "Git status" },
            { "<leader>gc", "<cmd>Telescope git_commits<CR>", desc = "Git commits" },
            { "<leader>gb", "<cmd>Telescope git_branches<CR>", desc = "Git branches" },
        },
        config = function()
            local actions = require("telescope.actions")

            require("telescope").setup({
                defaults = {
                    mappings = {
                        n = {
                            ["q"] = actions.close,
                        },
                    },
                },
            })
        end,
    },
}

return M
