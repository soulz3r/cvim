local M = {}

function M.setup()
  require("soul.ui.options")
  require("soul.ui.diagnostics").setup()
  require("soul.ui.messages").setup()
end

return M
