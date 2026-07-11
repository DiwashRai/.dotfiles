return {
	capabilities = require("blink.cmp").get_lsp_capabilities(),
	settings = {
		Lua = {
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
			telemetry = {
				enable = false,
			},
		},
	},
}
