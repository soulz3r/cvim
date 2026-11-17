local M = {}

M.LEVELS = 15

-- A broad, camera-facing light keeps the C readable throughout its rotation.
-- The direction is fixed in view space; surface normals rotate into that space.
local LIGHT_X, LIGHT_Y, LIGHT_Z = -0.38, 0.52, 0.76
local LIGHT_LENGTH = math.sqrt(LIGHT_X * LIGHT_X + LIGHT_Y * LIGHT_Y + LIGHT_Z * LIGHT_Z)
LIGHT_X = LIGHT_X / LIGHT_LENGTH
LIGHT_Y = LIGHT_Y / LIGHT_LENGTH
LIGHT_Z = LIGHT_Z / LIGHT_LENGTH

-- A small wrap term softens the terminator without flattening the shadows.
local WRAP = 0.22
local GAMMA = 0.90

function M.shade(normal_x, normal_y, normal_z)
	local diffuse = normal_x * LIGHT_X + normal_y * LIGHT_Y + normal_z * LIGHT_Z
	local wrapped = math.max(0, math.min(1, (diffuse + WRAP) / (1 + WRAP)))
	local shade = wrapped ^ GAMMA
	local level = math.floor(shade * (M.LEVELS - 1) + 0.5) + 1

	return shade, level
end

return M
