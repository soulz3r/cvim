local M = {}
function M.setup()
  require("soul.ui.float").setup()
  require("soul.ui.options").setup()
  require("soul.ui.diagnostics").setup()
  require("soul.ui.messages").setup()
end
return M
