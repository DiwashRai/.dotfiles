-- LSP Plugins
return {
	{
		"saghen/blink.cmp",
		event = "InsertEnter",
	},
	{
		"williamboman/mason.nvim",
		cmd = "Mason",
		opts = {},

		init = function()
			vim.diagnostic.config({
				severity_sort = true,
				float = { border = "rounded", source = "if_many" },
				underline = { severity = vim.diagnostic.severity.ERROR },
				virtual_text = {
					source = "if_many",
					current_line = true,
					spacing = 2,
				},
			})
		end,
	},
}
