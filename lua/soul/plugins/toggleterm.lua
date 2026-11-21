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
          local normalized = path:gsub("\\", "/"):lower()
          if normalized:find("/git/", 1, true) and is_executable(path) then
            return path
          end
        end
      end

      local function is_powershell_host()
        local shell = vim.o.shell:lower():gsub("\\", "/")
        return shell:find("pwsh", 1, true) ~= nil or shell:find("powershell", 1, true) ~= nil
      end

      local function quote_argument(value)
        if is_powershell_host() then
          return "'" .. value:gsub("'", "''") .. "'"
        end

        return '"' .. value:gsub('"', '""') .. '"'
      end

      -- ToggleTerm passes this command string to Neovim's configured shell.
      local function command_for(executable, arguments)
        local quoted = quote_argument(executable)
        if is_powershell_host() then
          return "& " .. quoted .. " " .. arguments
        end

        return quoted .. " " .. arguments
      end

      local function resolve_shell()
        if vim.fn.has("win32") ~= 1 then
          return vim.o.shell
        end

        local bash = git_bash()
        if bash then
          -- Explicitly load the user's custom Bash config, regardless of login profiles.
          local bashrc = "/d/config/bash/.bashrc"
          local arguments = "--rcfile " .. quote_argument(bashrc) .. " -i"
          return command_for(bash, arguments)
        end

        -- options.lua already selected pwsh or Windows PowerShell as the host shell.
        -- Reuse it instead of starting a nested PowerShell process.
        return vim.o.shell
      end

      require("toggleterm").setup({
        size = 15,
        open_mapping = [[<C-\>]],
        direction = "float",
        start_in_insert = true,
        insert_mappings = false,
        terminal_mappings = false,
        persist_size = true,
        persist_mode = true,
        close_on_exit = true,
        shade_terminals = false,
        shell = resolve_shell(),

        on_open = function(term)
          vim.keymap.set("t", ",,", [[<C-\><C-n>]], {
            buffer = term.bufnr,
            desc = "Exit terminal mode",
            silent = true,
          })

          vim.keymap.set("n", "q", function()
            term:close()
          end, {
            buffer = term.bufnr,
            desc = "Close terminal window",
            silent = true,
          })
        end,

        float_opts = {
          border = "rounded",
          width = 50,
          height = 30,
          winblend = 0,
          highlights = {
            border = "FloatBorder",
            background = "NormalFloat",
          },
        },
      })
    end,
  },
}

return M
