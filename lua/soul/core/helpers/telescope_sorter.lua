local M = {}

local function literal_score(prompt, candidate)
	local needle = prompt:lower()
	local haystack = candidate:lower()

	if haystack == needle then
		return 0
	end

	if haystack:sub(1, #needle) == needle then
		return 0.05
	end

	local position = haystack:find(needle, 1, true)
	if position then
		return 0.1 + position * 0.0001
	end

	return nil
end

local function fuzzy_score(fzy, prompt, candidate)
	if candidate == "" or not fzy.has_match(prompt, candidate) then
		return nil
	end

	local score = fzy.score(prompt, candidate)
	if score == fzy.get_score_min() then
		return nil
	end

	-- Normalize fzy's score into [0, 1]. Without this, weak filename fuzzy
	-- matches can overlap the directory-match score band.
	local score_floor = fzy.get_score_floor()
	local score_ceiling = #prompt + 1
	local distance = (score_ceiling - score) / (score_ceiling - score_floor)

	return math.max(0, math.min(1, distance))
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

			-- Exact filename, prefix, and substring matches get progressively
			-- worse scores. Telescope sorts lower scores before higher scores.
			local filename_literal = literal_score(prompt, filename)
			if filename_literal ~= nil then
				return filename_literal
			end

			-- A literal match in a directory is useful, but less relevant than
			-- the same match in the filename.
			local path_literal = literal_score(prompt, ordinal)
			if path_literal ~= nil then
				return 0.2 + path_literal
			end

			-- Preserve fuzzy matching below all literal matches.
			local filename_fuzzy = fuzzy_score(fzy, prompt, filename)
			if filename_fuzzy ~= nil then
				return 0.4 + filename_fuzzy
			end

			local path_fuzzy = fuzzy_score(fzy, prompt, ordinal)
			if path_fuzzy ~= nil then
				return 1.5 + path_fuzzy
			end

			return -1
		end,
		highlighter = function(_, prompt, display)
			return fzy.positions(prompt, display)
		end,
	})
end

-- live_grep's built-in sorter only highlights matches and gives every result
-- the same score. Rank the actual matched line instead of the full
-- "filename:line:column:text" ordinal so paths cannot outrank relevant code.
function M.live_grep()
	local sorters = require("telescope.sorters")
	local fzy = require("telescope.algos.fzy")

	return sorters.new({
		discard = true,
		scoring_function = function(_, prompt, ordinal, entry)
			if prompt == "" then
				return 1
			end

			local text = entry and entry.text or ordinal
			local literal = literal_score(prompt, text)
			if literal ~= nil then
				return literal
			end

			local fuzzy = fuzzy_score(fzy, prompt, text)
			if fuzzy ~= nil then
				return 0.4 + fuzzy
			end

			return -1
		end,
		highlighter = function(_, prompt, display)
			return fzy.positions(prompt, display)
		end,
	})
end

return M
