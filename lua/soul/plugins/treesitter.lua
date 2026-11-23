local parsers = {
  "c",
  "lua",
  "vim",
  "vimdoc",
  "bash",
  "markdown",
  "markdown_inline",
}

local filetype_languages = {
  sh = "bash",
}

local M = {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ":TSUpdate",
}

local function attach(buf)
  if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_buf_is_loaded(buf) then
    return
  end

  local filetype = vim.bo[buf].filetype
  if filetype == "" then
    return
  end

  local lang = filetype_languages[filetype] or vim.treesitter.language.get_lang(filetype)

  if lang then
    pcall(vim.treesitter.start, buf, lang)
  end
end

local function missing_parsers(treesitter)
  local ok, installed = pcall(treesitter.get_installed, "parsers")
  if not ok or type(installed) ~= "table" then
    return parsers
  end

  local installed_set = {}
  for _, lang in ipairs(installed) do
    installed_set[lang] = true
  end

  return vim.tbl_filter(function(lang)
    return not installed_set[lang]
  end, parsers)
end

M.config = function()
  local treesitter = require("nvim-treesitter")
  local missing = missing_parsers(treesitter)

  if #missing > 0 then
    local ok, task = pcall(treesitter.install, missing, {
      max_jobs = 2,
      summary = true,
    })

    if not ok then
      vim.notify("Treesitter parser installation could not start: " .. tostring(task), vim.log.levels.ERROR)
    elseif task and type(task.await) == "function" then
      task:await(function(err, installed)
        if err then
          vim.notify("Treesitter parser installation failed: " .. tostring(err), vim.log.levels.ERROR)
          return
        end

        if not installed then
          vim.notify("One or more Treesitter parsers could not be installed", vim.log.levels.WARN)
          return
        end

        vim.schedule(function()
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            attach(buf)
          end
        end)
      end)
    end
  end

  local group = vim.api.nvim_create_augroup("CVIMTreesitter", {
    clear = true,
  })

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    callback = function(args)
      attach(args.buf)
    end,
  })
end

return M
