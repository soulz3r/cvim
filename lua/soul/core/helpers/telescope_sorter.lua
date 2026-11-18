local M = {}

local function get_fzy_score(fzy, prompt, candidate, offset)
	if candidate == "" or not fzy.has_match(prompt, candidate) then
		return nil
	end

	local score = fzy.score(prompt, candidate)
	if score == fzy.get_score_min() then
		return 1
	end

	return 1 / (score + offset)
end

function M.filename_first()
	local sorters = require("telescope.sorters")
	local fzy = require("telescope.algos.fzy")
	local offset = -fzy.get_score_floor()

	return sorters.new({
		discard = true,
		scoring_function = function(_, prompt, ordinal)
			if prompt == "" then
				return 1
			end

			local filename = ordinal:match("[^/\\\\]+$") or ordinal
			local filename_score = get_fzy_score(fzy, prompt, filename, offset)
			local path_score = get_fzy_score(fzy, prompt, ordinal, offset)

			if filename_score == nil then
				return path_score or -1
			end

			if path_score == nil then
				return filename_score
			end

			return math.min(filename_score, path_score)
		end,
		highlighter = function(_, prompt, display)
			return fzy.positions(prompt, display)
		end,
	})
end

return M
