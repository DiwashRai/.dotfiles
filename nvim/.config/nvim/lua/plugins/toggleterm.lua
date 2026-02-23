return {
	"akinsho/toggleterm.nvim",
	version = "*",
	opts = {
		direction = "float",
		open_mapping = [[<c-\>]],
		float_opts = {
			border = "curved",
			height = function(term)
				return math.floor(vim.o.lines * 0.7)
			end,
			width = function(term)
				return math.floor(vim.o.columns * 0.7)
			end,
		},
	},
}
