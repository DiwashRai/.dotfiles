vim.pack.add({
	{ src = "https://github.com/stevearc/oil.nvim" },
}, { confirm = false, load = true })

require("oil").setup({
	view_options = {
		show_hidden = true,
	},
	columns = {},
	keymaps = require("keymaps").config.oil,
	use_default_keymaps = false,
})

local keymaps = require("keymaps")
keymaps.set(keymaps.pack.oil)
