local shading = require("soul.core.helpers.dashboard.logo_shading")

local function check(condition, message)
	if not condition then
		error(message, 1)
	end
end

local levels = {}
for index = 0, 144 do
	local angle = (index / 144) * math.pi * 2
	local level = shading.level(math.cos(angle), math.sin(angle), 0)
	check(level >= 1 and level <= shading.LEVELS, "shade level out of range")
	levels[level] = true
end

local front = shading.level(0, 0, 1)
local back = shading.level(0, 0, -1)
check(front > back, "front-facing surface should be brighter than the back")
check(back >= 1, "ambient light should keep the back surface visible")

local distinct = 0
for _ in pairs(levels) do
	distinct = distinct + 1
end
check(distinct >= 4, "rotation should produce a graduated range of material shades")

print("Dashboard logo shading checks passed.")
