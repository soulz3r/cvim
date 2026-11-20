local M = {}

local platform = require("soul.core.platform")
local fn = vim.fn

local projects_dir = vim.env.PROJECTS_DIR
M.projects = projects_dir and vim.trim(projects_dir) ~= "" and vim.trim(projects_dir) or fn.expand("~/projects")

local function resolve_pwsh()
	local configured = vim.env.PWSH and vim.trim(vim.env.PWSH)
	local configured_name = configured and configured ~= "" and configured:gsub("\\", "/"):match("([^/]+)$")
	configured_name = configured_name and configured_name:lower()
	local configured_is_pwsh = configured_name == "pwsh" or configured_name == "pwsh.exe"

	if configured_is_pwsh and fn.executable(configured) == 1 then
		return configured
	end

	local executable = fn.exepath("pwsh")
	return executable ~= "" and executable or "pwsh"
end

-- Resolve PowerShell only when Windows actually needs a shell.
setmetatable(M, {
	__index = function(tbl, key)
		if key ~= "pwsh" then
			return nil
		end

		local executable = resolve_pwsh()
		rawset(tbl, key, executable)
		return executable
	end,
})

if platform.is_wsl then
	M.wsl_clipboard = {
		copy = "clip.exe",
		paste = "powershell.exe",
	}
end

return M
