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
