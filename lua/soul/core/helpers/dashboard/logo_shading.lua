local M = {}

M.LEVELS = 9

local LIGHT_X, LIGHT_Y, LIGHT_Z = -0.35, 0.55, 0.76
local LIGHT_LENGTH = math.sqrt(LIGHT_X * LIGHT_X + LIGHT_Y * LIGHT_Y + LIGHT_Z * LIGHT_Z)
LIGHT_X = LIGHT_X / LIGHT_LENGTH
LIGHT_Y = LIGHT_Y / LIGHT_LENGTH
LIGHT_Z = LIGHT_Z / LIGHT_LENGTH

local VIEW_X, VIEW_Y, VIEW_Z = 0, 0, 1
local HALF_X = LIGHT_X + VIEW_X
local HALF_Y = LIGHT_Y + VIEW_Y
local HALF_Z = LIGHT_Z + VIEW_Z
local HALF_LENGTH = math.sqrt(HALF_X * HALF_X + HALF_Y * HALF_Y + HALF_Z * HALF_Z)
HALF_X = HALF_X / HALF_LENGTH
HALF_Y = HALF_Y / HALF_LENGTH
HALF_Z = HALF_Z / HALF_LENGTH

local AMBIENT = 0.16
local DIFFUSE_STRENGTH = 0.68
local SPECULAR_STRENGTH = 0.24
local SPECULAR_POWER = 18

function M.level(normal_x, normal_y, normal_z)
	local diffuse = math.max(0, normal_x * LIGHT_X + normal_y * LIGHT_Y + normal_z * LIGHT_Z)
	local specular = math.max(0, normal_x * HALF_X + normal_y * HALF_Y + normal_z * HALF_Z) ^ SPECULAR_POWER

	local intensity = math.min(1, AMBIENT + diffuse * DIFFUSE_STRENGTH + specular * SPECULAR_STRENGTH)
	return math.floor(intensity * (M.LEVELS - 1) + 0.5) + 1
end

return M
