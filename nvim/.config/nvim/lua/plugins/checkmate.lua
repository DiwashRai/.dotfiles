return {
	"bngarren/checkmate.nvim",
	ft = "markdown", -- Lazy loads for Markdown files matching patterns in 'files'
	opts = {
		files = {
			"todo",
			"TODO",
			"todo.md",
			"TODO.md",
		},
		keys = {
			["<leader>tt"] = {
				rhs = "<cmd>Checkmate toggle<CR>",
				desc = "Toggle todo item",
				modes = { "n", "v" },
			},
			["<leader>td"] = {
				rhs = "<cmd>Checkmate metadata toggle done<CR>",
				desc = "Toggle @done meta",
				modes = { "n", "v" },
			},
			["<leader>tn"] = {
				rhs = "<cmd>Checkmate create<CR>",
				desc = "Create todo item",
				modes = { "n", "v" },
			},
			["<leader>ta"] = {
				rhs = "<cmd>Checkmate archive<CR>",
				desc = "Archive checked/completed todo items (move to bottom section)",
				modes = { "n" },
			},
			["<leader>tv"] = {
				rhs = "<cmd>Checkmate metadata select_value<CR>",
				desc = "Update the value of a metadata tag under the cursor",
				modes = { "n" },
			},
			["<leader>tr"] = {
				rhs = "<cmd>Checkmate remove_all_metadata<CR>",
				desc = "Remove all metadata from a todo item",
				modes = { "n", "v" },
			},
		},
	},
}
