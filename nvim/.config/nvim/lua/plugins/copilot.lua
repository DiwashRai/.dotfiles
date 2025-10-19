return {
	"zbirenbaum/copilot.lua",
	cmd = "Copilot",
	event = "InsertEnter",
	opts = {
		panel = {
			auto_refresh = true,
			keymap = {
				accept = "<CR>",
				jump_prev = "[[",
				jump_next = "]]",
				refresh = "gr",
				open = "<M-CR>",
			},
			layout = {
				position = "right", -- top, bottom, left, right
				size = {
					ratio = 0.5,
				},
			},
		},
		suggestion = {
			auto_trigger = true,
			keymap = {
				accept = "<M-l>",
				prev = "<M-[>",
				next = "<M-]>",
				dismiss = "<C-]>",
			},
		},
	},
}
