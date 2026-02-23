local local_options = {
	shiftwidth = 2,
	tabstop = 2,
	softtabstop = 2,
	expandtab = false,
}

for k, v in pairs(local_options) do
	vim.opt_local[k] = v
end
