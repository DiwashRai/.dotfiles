vim.pack.add({
	{ src = "https://github.com/akinsho/toggleterm.nvim", version = "50ea089fc548917cc3cc16b46a8211833b9e3c7c" },
}, { confirm = false, load = true })

require("toggleterm").setup({
	direction = "float",
	open_mapping = [[<c-\>]],
	float_opts = {
		border = "curved",
		height = function()
			return math.floor(vim.o.lines * 0.7)
		end,
		width = function()
			return math.floor(vim.o.columns * 0.7)
		end,
	},
})
