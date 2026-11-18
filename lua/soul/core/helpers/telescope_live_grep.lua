local M = {}

local function flatten(...)
	local result = {}

	for index = 1, select("#", ...) do
		local value = select(index, ...)
		if type(value) == "table" then
			vim.list_extend(result, value)
		elseif value ~= nil then
			result[#result + 1] = value
		end
	end

	return result
end

function M.dedupe_entry_maker(entry_maker)
	local seen = {}

	local function reset()
		seen = {}
	end

	return function(line)
		local entry = entry_maker(line)
		if not entry then
			return nil
		end

		local key = table.concat({
			tostring(entry.filename or ""),
			tostring(entry.lnum or ""),
			tostring(entry.col or ""),
			tostring(entry.text or entry.ordinal or ""),
		}, "\0")

		if seen[key] then
			return nil
		end

		seen[key] = true
		return entry
	end,
		reset
end

local function get_open_files()
	local files = {}

	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if vim.fn.buflisted(bufnr) == 1 then
			local filename = vim.api.nvim_buf_get_name(bufnr)
			if filename ~= "" then
				files[#files + 1] = filename
			end
		end
	end

	return files
end

function M.open(opts)
	opts = require("telescope.themes").get_dropdown(opts or {})
	-- The dropdown's center strategy centers only the prompt/results block and
	-- puts the preview in the remaining screen space. Use the horizontal
	-- strategy so prompt, results, and preview form one centered floating box.
	opts.layout_strategy = "horizontal"
	opts.layout_config = vim.tbl_deep_extend("force", opts.layout_config or {}, {
	width = 0.85,
	height = 0.8,
	preview_width = 0.5,
	prompt_position = "top",
})

	local actions = require("telescope.actions")
	local conf = require("telescope.config").values
	local finders = require("telescope.finders")
	local make_entry = require("telescope.make_entry")
	local pickers = require("telescope.pickers")

	local vimgrep_arguments = opts.vimgrep_arguments or conf.vimgrep_arguments
	local additional_args = {}

	if type(opts.additional_args) == "function" then
		additional_args = opts.additional_args(opts) or {}
	elseif type(opts.additional_args) == "table" then
		additional_args = opts.additional_args
	end

	if opts.type_filter then
		additional_args[#additional_args + 1] = "--type=" .. opts.type_filter
	end

	if type(opts.glob_pattern) == "string" then
		additional_args[#additional_args + 1] = "--glob=" .. opts.glob_pattern
	elseif type(opts.glob_pattern) == "table" then
		for _, pattern in ipairs(opts.glob_pattern) do
			additional_args[#additional_args + 1] = "--glob=" .. pattern
		end
	end

	if opts.file_encoding then
		additional_args[#additional_args + 1] = "--encoding=" .. opts.file_encoding
	end

	if opts.hidden then
		additional_args[#additional_args + 1] = "--hidden"
	end

	local args = flatten(vimgrep_arguments, additional_args)
	local search_dirs = opts.search_dirs
	if search_dirs then
		for index, path in ipairs(search_dirs) do
			search_dirs[index] = require("telescope.utils").path_expand(path)
		end
	end

	local cwd = opts.cwd and require("telescope.utils").path_expand(opts.cwd) or vim.uv.cwd()
	local open_files = opts.grep_open_files and get_open_files() or nil
	local entry_maker = opts.entry_maker or make_entry.gen_from_vimgrep(opts)
	local deduped_entry_maker, reset_seen = M.dedupe_entry_maker(entry_maker)

	-- Reset the duplicate set whenever Telescope starts a new ripgrep job.
	-- This keeps results valid when the prompt changes while filtering repeated
	-- filename/line/column/text records within each individual search.
	local finder = finders.new_job(function(prompt)
		if not prompt or prompt == "" then
			return nil
		end

		reset_seen()

		local search_list = open_files or search_dirs or {}
		return flatten(args, { "--", prompt }, search_list)
	end, deduped_entry_maker, nil, cwd)

	opts.cwd = cwd
	opts.previewer = true

	pickers
		.new(opts, {
			prompt_title = "Live Grep",
			finder = finder,
			previewer = conf.grep_previewer(opts),
			sorter = require("soul.core.helpers.telescope_sorter").live_grep(),
			attach_mappings = function(_, map)
				map("i", "<c-space>", actions.to_fuzzy_refine)
				return true
			end,
			push_cursor_on_edit = true,
		})
		:find()
end

return M
