local local_options = {
	shiftwidth = 2, -- for <<, >> and autoindent
	tabstop = 2, -- number of space that a literal \t is displayed as
	softtabstop = 2, -- insert mode: spaces when pressing tab and pressing backspace
	expandtab = true, -- insert spaces when pressing tab
	autoindent = true, -- copy indent from current line when starting a new line
	conceallevel = 0,
}

for k, v in pairs(local_options) do
	vim.opt_local[k] = v
end
