local M = {}

function M.setup()
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  local lazy_entry = lazypath .. "/lua/lazy/init.lua"

  if not vim.uv.fs_stat(lazy_entry) then
    if vim.uv.fs_stat(lazypath) then
      error("lazy.nvim exists but is incomplete: " .. lazypath)
    end

    local ok, process = pcall(vim.system, {
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable",
      lazypath,
    }, { text = true })

    if not ok then
      error("Failed to start lazy.nvim bootstrap: " .. tostring(process))
    end

    local result = process:wait(120000)
    if not result or result.code ~= 0 then
      error("Failed to bootstrap lazy.nvim:\n" .. ((result and result.stderr) or "Unknown git error"))
    end

    if not vim.uv.fs_stat(lazy_entry) then
      error("lazy.nvim clone completed, but lua/lazy/init.lua is missing: " .. lazypath)
    end
  end

  vim.opt.rtp:prepend(lazypath)
  require("lazy").setup({
    spec = { { import = "soul.plugins" } },
    rocks = { enabled = false, hererocks = false },
    ui = { border = "rounded" },
    change_detection = { enabled = true, notify = false },
  })

  vim.keymap.set("n", "<leader>L", "<cmd>Lazy<cr>", {
    desc = "Open plugin manager",
  })
end

return M
