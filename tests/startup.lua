local root = vim.fn.getcwd()
vim.opt.rtp:prepend(root)

local data = vim.fn.tempname()
local lazy_dir = data .. "/lazy/lazy.nvim"
vim.fn.mkdir(lazy_dir .. "/lua/lazy", "p")
vim.fn.writefile({ "return {}" }, lazy_dir .. "/lua/lazy/init.lua")

local original_stdpath = vim.fn.stdpath
vim.fn.stdpath = function(what)
	if what == "data" then
		return data
	end
	return original_stdpath(what)
end

local setup_calls = 0
package.preload.lazy = function()
	return {
		setup = function(options)
			setup_calls = setup_calls + 1
			assert(options.spec[1].import == "soul.plugins")
			assert(options.rocks.enabled == false)
		end,
	}
end

dofile(root .. "/init.lua")

assert(vim.g.cvim_config_loaded == true)
assert(setup_calls == 1)
print("PASS: complete init.lua startup with isolated Lazy.nvim")
