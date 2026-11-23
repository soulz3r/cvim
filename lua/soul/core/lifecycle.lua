local M = { active = {}, order = {}, setup_done = false }

function M.start(name, setup)
  if M.active[name] ~= nil then
    return true
  end

  local ok, cleanup = xpcall(setup, debug.traceback)
  if not ok then
    return false, cleanup
  end
  if cleanup ~= nil and type(cleanup) ~= "function" then
    return false, ("Lifecycle setup %q must return a cleanup function or nil"):format(name)
  end

  M.active[name] = cleanup or true
  table.insert(M.order, name)
  return true
end

function M.stop(name)
  if M.active[name] == nil then
    return true
  end

  local cleanup = M.active[name]
  M.active[name] = nil
  for index = #M.order, 1, -1 do
    if M.order[index] == name then
      table.remove(M.order, index)
      break
    end
  end

  if type(cleanup) == "function" then
    local ok, err = pcall(cleanup)
    if not ok then
      return false, err
    end
  end
  return true
end

function M.stop_all()
  local errors = {}
  for index = #M.order, 1, -1 do
    local ok, err = M.stop(M.order[index])
    if not ok then
      table.insert(errors, tostring(err))
    end
  end
  if #errors > 0 then
    return false, table.concat(errors, "\n")
  end
  return true
end

function M.is_active(name)
  return M.active[name] ~= nil
end

function M.setup()
  if M.setup_done then
    return
  end
  local group = vim.api.nvim_create_augroup("CVIMPluginLifecycle", { clear = true })
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = function()
      local ok, err = M.stop_all()
      if not ok then
        vim.notify("CVIM plugin cleanup failed:\n" .. err, vim.log.levels.WARN)
      end
    end,
  })
  M.setup_done = true
end

return M
