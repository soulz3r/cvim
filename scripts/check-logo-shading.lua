local root = vim.fn.getcwd()
vim.opt.rtp:prepend(root)
package.path = table.concat({
	root .. "/lua/?.lua",
	root .. "/lua/?/init.lua",
	package.path,
}, ";")

local shading = require("soul.core.helpers.dashboard.logo_shading")

local function check(condition, message)
	if not condition then
		error(message, 1)
	end
end

local levels = {}
for index = 0, 144 do
	local angle = (index / 144) * math.pi * 2
	local intensity, level = shading.shade(math.cos(angle), math.sin(angle), 0)
	check(intensity >= 0 and intensity <= 1, "shade intensity out of range")
	check(level >= 1 and level <= shading.LEVELS, "shade level out of range")
	levels[level] = true
end

local front_intensity, front = shading.shade(0, 0, 1)
local back_intensity, back = shading.shade(0, 0, -1)
check(front > back, "front-facing surface should be brighter than the back")
check(front_intensity > back_intensity, "front-facing surface should receive more light")
check(back_intensity == 0, "ambient light should be removed from the material gradient")

local distinct = 0
for _ in pairs(levels) do
	distinct = distinct + 1
end
check(distinct >= 4, "rotation should produce a graduated range of material shades")

print("Dashboard logo shading checks passed.")
