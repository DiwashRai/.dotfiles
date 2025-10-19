-- RemedyBG debugger integration for Windows
-- Uses extmarks to track breakpoints across buffer edits
local M = {}

-- Only load on Windows
local is_win = vim.fn.has("win32") == 1
if not is_win then
	return M
end

-- CONFIG ----------------------------------------------------------------------
M.cmd = "remedybg.exe" -- Change to full path if not in PATH
M.show_errors = true -- Set to false to silently ignore RemedyBG errors
-------------------------------------------------------------------------------

-- Namespace for extmarks and sign group
local ns = vim.api.nvim_create_namespace("remedybg_breakpoints")
local sign_group = "RemedyBGBreakpoints"

-- Per-buffer state tracking
local state = {} -- state[bufnr] = { [extmark_id] = true }

-- Sign definition
vim.fn.sign_define("RemedyBGBreakpoint", {
	text = "●",
	texthl = "DiagnosticError",
	linehl = "",
	numhl = "",
})

-- Helper: Get absolute path for buffer (RemedyBG requires absolute paths)
local function abs_path(buf)
	local p = vim.api.nvim_buf_get_name(buf)
	if p == "" then
		return nil
	end
	return vim.fn.fnamemodify(p, ":p")
end

-- Helper: Get current cursor line (0-indexed)
local function current_line0()
	return vim.api.nvim_win_get_cursor(0)[1] - 1
end

-- Helper: Find extmark on given line
local function find_mark_on_line(buf, lnum0)
	local marks = vim.api.nvim_buf_get_extmarks(buf, ns, { lnum0, 0 }, { lnum0, -1 }, {})
	return (#marks > 0) and marks[1][1] or nil
end

-- Helper: Place sign at extmark position
local function place_sign(buf, extmark_id, lnum1)
	vim.fn.sign_place(extmark_id, sign_group, "RemedyBGBreakpoint", buf, { lnum = lnum1, priority = 20 })
end

-- Helper: Clear sign
local function clear_sign(buf, extmark_id)
	vim.fn.sign_unplace(sign_group, { buffer = buf, id = extmark_id })
end

-- Refresh all signs for a buffer from extmarks
local function refresh_signs(buf)
	-- Clear all signs for this buffer
	vim.fn.sign_unplace(sign_group, { buffer = buf })

	-- Re-place signs at current extmark positions
	for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(buf, ns, 0, -1, {})) do
		local extmark_id, row0 = mark[1], mark[2]
		place_sign(buf, extmark_id, row0 + 1)
	end
end

-- Execute RemedyBG command
local function remedybg_exec(args)
	vim.system(vim.list_extend({ M.cmd }, args), {}, function(obj)
		if M.show_errors and obj.code ~= 0 then
			vim.schedule(function()
				vim.notify(
					string.format("RemedyBG error: %s\n%s", table.concat(args, " "), obj.stderr or ""),
					vim.log.levels.ERROR
				)
			end)
		end
	end)
end

-- Toggle breakpoint at cursor
function M.toggle()
	local buf = vim.api.nvim_get_current_buf()
	state[buf] = state[buf] or {}

	local file = abs_path(buf)
	if not file then
		vim.notify("No file in buffer", vim.log.levels.WARN)
		return
	end

	local row0 = current_line0()
	local existing = find_mark_on_line(buf, row0)

	if existing then
		-- Remove breakpoint
		vim.api.nvim_buf_del_extmark(buf, ns, existing)
		clear_sign(buf, existing)
		state[buf][existing] = nil

		-- Remove in RemedyBG
		remedybg_exec({ "remove-breakpoint-at-file", file, tostring(row0 + 1) })
	else
		-- Add breakpoint
		local extmark_id = vim.api.nvim_buf_set_extmark(buf, ns, row0, 0, {})
		state[buf][extmark_id] = true
		place_sign(buf, extmark_id, row0 + 1)

		-- Add in RemedyBG and open the file at this line
		remedybg_exec({ "add-breakpoint-at-file", file, tostring(row0 + 1) })
		remedybg_exec({ "open-file", file, tostring(row0 + 1) })
	end
end

-- Collect all breakpoints across all buffers
local function collect_all()
	local list = {}
	for buf, _ in pairs(state) do
		local file = abs_path(buf)
		if file then
			for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(buf, ns, 0, -1, {})) do
				table.insert(list, { file = file, line = mark[2] + 1 })
			end
		end
	end
	-- Sort for consistent output
	table.sort(list, function(a, b)
		return (a.file == b.file) and (a.line < b.line) or (a.file < b.file)
	end)
	return list
end

-- Sync all breakpoints to RemedyBG (remove all, then re-add from Neovim)
function M.sync_all()
	remedybg_exec({ "remove-all-breakpoints" })

	local all = collect_all()
	for _, bp in ipairs(all) do
		remedybg_exec({ "add-breakpoint-at-file", bp.file, tostring(bp.line) })
	end

	vim.notify(string.format("Synced %d breakpoint(s) to RemedyBG", #all), vim.log.levels.INFO)
end

-- Clear all breakpoints (Neovim + RemedyBG)
function M.clear_all()
	-- Clear all extmarks and signs
	for buf, _ in pairs(state) do
		vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
		vim.fn.sign_unplace(sign_group, { buffer = buf })
	end

	-- Clear state
	state = {}

	-- Clear in RemedyBG
	remedybg_exec({ "remove-all-breakpoints" })

	vim.notify("Cleared all breakpoints", vim.log.levels.INFO)
end

-- Open current file at cursor position in RemedyBG
function M.open_current()
	local buf = vim.api.nvim_get_current_buf()
	local file = abs_path(buf)

	if not file then
		vim.notify("No file in buffer", vim.log.levels.WARN)
		return
	end

	local line = vim.fn.line(".")
	remedybg_exec({ "open-file", file, tostring(line) })
	vim.notify(string.format("Opened %s:%d in RemedyBG", vim.fn.fnamemodify(file, ":t"), line), vim.log.levels.INFO)
end

-- Open all files with breakpoints in RemedyBG
function M.open_all()
	local all = collect_all()

	if #all == 0 then
		vim.notify("No breakpoints to open", vim.log.levels.WARN)
		return
	end

	for _, bp in ipairs(all) do
		remedybg_exec({ "open-file", bp.file, tostring(bp.line) })
	end

	vim.notify(string.format("Opened %d file(s) with breakpoints in RemedyBG", #all), vim.log.levels.INFO)
end

-- Auto-refresh signs as buffer changes (extmarks track position automatically)
vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged", "TextChangedI" }, {
	callback = function(args)
		if state[args.buf] then
			refresh_signs(args.buf)
		end
	end,
})

-- User commands
vim.api.nvim_create_user_command("RemedyToggle", M.toggle, {})
vim.api.nvim_create_user_command("RemedySync", M.sync_all, {})
vim.api.nvim_create_user_command("RemedyClear", M.clear_all, {})
vim.api.nvim_create_user_command("RemedyOpen", M.open_current, {})
vim.api.nvim_create_user_command("RemedyOpenAll", M.open_all, {})

-- Keymaps
vim.keymap.set("n", "<leader>db", M.toggle, { desc = "[D]ebug: Toggle [B]reakpoint" })
vim.keymap.set("n", "<leader>ds", M.sync_all, { desc = "[D]ebug: [S]ync breakpoints to RemedyBG" })
vim.keymap.set("n", "<leader>dc", M.clear_all, { desc = "[D]ebug: [C]lear all breakpoints" })
vim.keymap.set("n", "<leader>do", M.open_current, { desc = "[D]ebug: [O]pen current file in RemedyBG" })
vim.keymap.set("n", "<leader>dO", M.open_all, { desc = "[D]ebug: [O]pen all files with breakpoints" })

return M
