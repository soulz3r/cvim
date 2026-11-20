local M = {
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        event = "VeryLazy",
        config = function()
            local function is_executable(path)
                return path ~= nil and path ~= "" and vim.fn.executable(path) == 1
            end

            local function git_bash()
                local candidates = {}
                local git = vim.fn.exepath("git")

                if git ~= "" then
                    local git_dir = vim.fs.dirname(vim.fs.dirname(git))
                    table.insert(candidates, git_dir .. "/bin/bash.exe")
                    table.insert(candidates, git_dir .. "/usr/bin/bash.exe")
                end

                for _, root in ipairs({
                    vim.env.ProgramFiles,
                    vim.env["ProgramFiles(x86)"],
                    vim.env.LOCALAPPDATA and (vim.env.LOCALAPPDATA .. "/Programs"),
                }) do
                    if root and root ~= "" then
                        table.insert(candidates, root .. "/Git/bin/bash.exe")
                        table.insert(candidates, root .. "/Git/usr/bin/bash.exe")
                    end
                end

                for _, path in ipairs(candidates) do
                    if is_executable(path) then
                        return path
                    end
                end

                for _, name in ipairs({ "bash.exe", "bash" }) do
                    local path = vim.fn.exepath(name)
                    if path:lower():find("[/\\]git[/\\]") and is_executable(path) then
                        return path
                    end
                end
            end

            local function resolve_shell()
                if vim.fn.has("win32") ~= 1 then
                    return vim.o.shell, {}
                end

                local bash = git_bash()
                if bash then
                    return bash, { "--login", "-i" }
                end

                for _, candidate in ipairs({ "pwsh.exe", "pwsh", "powershell.exe", "powershell" }) do
                    local shell = vim.fn.exepath(candidate)
                    if shell ~= "" then
                        return shell, { "-NoLogo" }
                    end
                end

                return vim.o.shell, {}
            end

            local shell, shell_args = resolve_shell()

            require("toggleterm").setup({
                size = 15,
                open_mapping = [[<C-\>]],
                direction = "horizontal",
                start_in_insert = true,
                insert_mappings = false,
                terminal_mappings = false,
                persist_size = true,
                persist_mode = true,
                close_on_exit = true,
                shade_terminals = false,
                shell = shell,
                shell_args = shell_args,
            })
        end,
    },
}

return M
