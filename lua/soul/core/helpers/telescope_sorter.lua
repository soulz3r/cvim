local M = {}

local function literal_score(prompt, candidate, tiers)
	local needle = prompt:lower()
	local haystack = candidate:lower()

	if haystack == needle then
		return tiers.exact
	end

	if haystack:sub(1, #needle) == needle then
		return tiers.prefix
	end

	local position = haystack:find(needle, 1, true)
	if position then
		return tiers.substring + (1000 - position)
	end

	return nil
end

local function fuzzy_score(fzy, prompt, candidate, tier)
	if candidate == "" or not fzy.has_match(prompt, candidate) then
		return nil
	end

	local score = fzy.score(prompt, candidate)
	if score == fzy.get_score_min() then
		return nil
	end

	local floor = fzy.get_score_floor()
	local normalized = math.max(0, math.min(1, (score - floor) / -floor))

	return tier + normalized
end

function M.filename_first()
	local sorters = require("telescope.sorters")
	local fzy = require("telescope.algos.fzy")

	return sorters.new({
		discard = true,
		scoring_function = function(_, prompt, ordinal)
			if prompt == "" then
				return 1
			end

			local filename = ordinal:match("[^/\\\\]+$") or ordinal
			local tiers = {
				exact = 1000000,
				prefix = 900000,
				substring = 800000,
			}

			-- Literal filename matches always beat directory-only and fuzzy matches.
			local filename_literal = literal_score(prompt, filename, tiers)
			if filename_literal then
				return filename_literal
			end

			local path_tiers = {
				exact = 700000,
				prefix = 600000,
				substring = 500000,
			}
			local path_literal = literal_score(prompt, ordinal, path_tiers)
			if path_literal then
				return path_literal
			end

			-- Keep fuzzy matching, but place it below every literal match.
			return fuzzy_score(fzy, prompt, filename, 400000) or fuzzy_score(fzy, prompt, ordinal, 300000) or -1
		end,
		highlighter = function(_, prompt, display)
			return fzy.positions(prompt, display)
		end,
	})
end

return M
