return {
	"bngarren/checkmate.nvim",
	ft = "markdown", -- Lazy loads for Markdown files matching patterns in 'files'
	event = "VeryLazy",
	opts = {
		files = {
			"todo",
			"TODO",
			"todo.md",
			"TODO.md",
		},
		keys = require("keymaps").config.checkmate,
	},
}
