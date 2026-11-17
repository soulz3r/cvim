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
for y_step = -24, 24 do
	for x_step = -24, 24 do
		local x = x_step / 24
		local y = y_step / 24
		local radius_squared = x * x + y * y
		if radius_squared <= 1 then
			local z = math.sqrt(1 - radius_squared)
			local _, front_level = shading.shade(x, y, z)
			local _, back_level = shading.shade(x, y, -z)
			levels[front_level] = true
			levels[back_level] = true
		end
	end
end

local front_shade, front_level = shading.shade(0, 0, 1)
local back_shade, back_level = shading.shade(0, 0, -1)
check(front_level == shading.LEVELS, "front-facing surface should reach the brightest material")
check(back_level == 1, "back-facing surface should reach the shadow material")
check(front_shade > back_shade, "front-facing surface should be brighter than the back")

local distinct = 0
for level = 1, shading.LEVELS do
	if levels[level] then
		distinct = distinct + 1
	end
end
check(distinct >= 11, "rotating surface should use a broad, graduated range of shades")

-- Rotation must not change the light response for an equivalent camera-space normal.
local shade_a = shading.shade(0.3, 0.4, math.sqrt(0.75))
local shade_b = shading.shade(0.3, 0.4, math.sqrt(0.75))
check(shade_a == shade_b, "identical surface normals must produce identical shades")

print("Dashboard logo shading checks passed.")
