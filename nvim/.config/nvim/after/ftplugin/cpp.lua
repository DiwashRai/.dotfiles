local local_options = {
	shiftwidth = 4,
	tabstop = 4,
	expandtab = true,
	softtabstop = 4,
	smartindent = true,
	autoindent = true,
}

for k, v in pairs(local_options) do
	vim.opt_local[k] = v
end

local hdrs = { h = true, hh = true, hpp = true }
local srcs = { cpp = true, cc = true, cxx = true }

local hdr_keys = vim.tbl_keys(hdrs)
local src_keys = vim.tbl_keys(srcs)

local function switch_header_source()
	local ext = vim.fn.expand("%:e")
	local root = vim.fn.expand("%:p:r")

	local target_exts = hdrs[ext] and src_keys or srcs[ext] and hdr_keys

	if not target_exts then
		return vim.notify("Not a cpp file", vim.log.levels.WARN)
	end

	for _, te in ipairs(target_exts) do
		local path = root .. "." .. te
		if vim.fn.filereadable(path) == 1 then
			return vim.cmd.edit(path)
		end
	end
	vim.notify("No matching file found for " .. root, vim.log.levels.WARN)
end

vim.keymap.set("n", "<C-k><C-o>", switch_header_source, {
	desc = "Switch between header/source",
	buffer = true,
})
