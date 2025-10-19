return {
	"olimorris/codecompanion.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	lazy = true,
	keys = {
		{
			"<leader>aa",
			function()
				require("codecompanion").toggle()
			end,
			{ desc = "[A]I [A]ssistant toggle chat" },
		},
	},
	opts = {
		strategies = {
			chat = {
				adapter = {
					name = "copilot",
					-- model = "gpt-4.1",
					-- model = "gpt-4o",
					model = "gpt-5-mini",
					-- model = "claude-sonnet-4",
					-- model = "claude-sonnet-4.5",
				},
			},
			inline = {
				adapter = {
					name = "copilot",
					-- model = "gpt-4.1",
					-- model = "gpt-4o",
					model = "gpt-5-mini",
					-- model = "claude-sonnet-4",
					-- model = "claude-sonnet-4.5",
				},
			},
		},
	},
}
