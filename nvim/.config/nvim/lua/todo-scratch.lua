local M = {}

local function todo_path()
	local has_state = pcall(function()
		return vim.fn.stdpath("state")
	end)
	local base = has_state and vim.fn.stdpath("state") or vim.fn.stdpath("data")
	local dir = base .. "/todo"
	local path = dir .. "/todo.md"

	-- ensure directory exists
	if vim.fn.isdirectory(dir) == 0 then
		vim.fn.mkdir(dir, "p")
	end

	-- create file if missing
	if vim.fn.filereadable(path) == 0 then
		vim.fn.writefile({ "# TODO", "", "- [ ] " }, path)
	end

	return path
end

-- --- Config ---------------------------------------------------------------
local SIZE = { width = 0.45, height = 0.6 }
local BORDER = "rounded" -- none|single|double|rounded|solid|shadow
local PATH = todo_path()
--local PATH = vim.fn.expand("~/TODO.md")
-- -------------------------------------------------------------------------

---@class TodoFloatState
---@field win? integer
---@field buf? integer
---@type TodoFloatState
local state = { win = nil, buf = nil }

local function ensure_buffer()
	if state.buf and vim.api.nvim_buf_is_loaded(state.buf) then
		return state.buf
	end
	local buf = vim.fn.bufadd(PATH)
	vim.fn.bufload(buf)
	state.buf = buf

	-- Nice defaults for the todo buffer
	pcall(vim.api.nvim_set_option_value, "filetype", "markdown", { buf = buf })
	pcall(vim.api.nvim_set_option_value, "swapfile", true, { buf = buf })
	return buf
end

local function open_float()
	if state.win and vim.api.nvim_win_is_valid(state.win) then
		vim.api.nvim_set_current_win(state.win)
		return
	end

	local buf = ensure_buffer()
	local ui = vim.api.nvim_list_uis()[1]
	local width = math.max(20, math.floor(ui.width * SIZE.width))
	local height = math.max(8, math.floor(ui.height * SIZE.height))
	local row = math.floor((ui.height - height) / 2)
	local col = math.floor((ui.width - width) / 2)

	state.win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		style = "minimal",
		border = BORDER,
		width = width,
		height = height,
		row = row,
		col = col,
		zindex = 50,
	})

	-- Window-local tweaks
	pcall(vim.api.nvim_set_option_value, "wrap", true, { win = state.win })
	pcall(vim.api.nvim_set_option_value, "signcolumn", "no", { win = state.win })
	pcall(vim.api.nvim_set_option_value, "number", false, { win = state.win })
	pcall(vim.api.nvim_set_option_value, "relativenumber", false, { win = state.win })
	pcall(vim.api.nvim_set_option_value, "cursorline", true, { win = state.win })

	-- Clean state when the float is closed manually
	vim.api.nvim_create_autocmd("WinClosed", {
		once = true,
		callback = function(args)
			if tostring(state.win) == args.match then
				state.win = nil
			end
		end,
	})

	-- Clean state if buffer gets wiped
	vim.api.nvim_create_autocmd("BufWipeout", {
		buffer = buf,
		once = true,
		callback = function()
			state.buf = nil
			state.win = nil
		end,
	})
end

function M.close()
	if state.win and vim.api.nvim_win_is_valid(state.win) then
		vim.api.nvim_win_close(state.win, true)
	end
	state.win = nil
end

function M.toggle()
	if state.win and vim.api.nvim_win_is_valid(state.win) then
		M.close()
	else
		open_float()
	end
end

vim.keymap.set("n", "<C-t>", function()
	M.toggle()
end, { desc = "Toggle TODO scratchpad" })

return M
