return {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	root_markers = {
		{ ".luarc.json", ".luarc.jsonc", ".emmyrc.json" },
		{ ".stylua.toml", "stylua.toml", ".luacheckrc", "selene.toml", "selene.yml" },
		".git",
	},
	capabilities = require("blink.cmp").get_lsp_capabilities(),
	settings = {
		Lua = {
			codeLens = { enable = true },
			completion = {
				callSnippet = "Replace",
			},
			diagnostics = {
				globals = { "vim", "require" },
				-- disable = { "missing-fields" }
			},
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
			},
			hint = {
				enable = true,
				semicolon = "Disable",
			},
			telemetry = {
				enable = false,
			},
		},
	},
}
