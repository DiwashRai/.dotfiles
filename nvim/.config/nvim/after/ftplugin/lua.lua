local local_options = {
	shiftwidth = 2,
	tabstop = 2,
	expandtab = true,
	softtabstop = 2,
	smartindent = true,
	autoindent = true,
}

for k, v in pairs(local_options) do
	vim.opt_local[k] = v
end
