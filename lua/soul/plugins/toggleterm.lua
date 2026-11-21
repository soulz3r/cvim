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

      local function configure_shell()
        if vim.fn.has("win32") ~= 1 then
          return
        end

        local bash = git_bash()
        if not bash then
          return
        end

        -- ToggleTerm passes its terminal command through Neovim's configured shell.
        -- Git Bash needs its executable in 'shell' and Bash-compatible flags in
        -- 'shellcmdflag'; putting arguments inside 'shell' breaks that invocation.
        vim.o.shell = '"' .. bash .. '"'
        vim.o.shellcmdflag = "--rcfile /d/config/bash/.bashrc -i -s"
      end

      configure_shell()

      require("toggleterm").setup({
        size = 15,
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
          vim.wo[term.window].wrap = true

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

      local Terminal = require("toggleterm.terminal").Terminal
      local terminal = Terminal:new({
        direction = "float",
        hidden = true,
      })

      vim.keymap.set({ "n", "t" }, "<C-\\>", function()
        terminal:toggle()
      end, {
        desc = "Toggle floating terminal",
        noremap = true,
        silent = true,
      })
    end,
  },
}

return M
