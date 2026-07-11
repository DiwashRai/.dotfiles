return {
	cmd = { "gopls" },
	filetypes = { "go", "gomod", "gowork", "gotmpl" },
	root_markers = { "go.work", "go.mod", ".git" },
	capabilities = require("blink.cmp").get_lsp_capabilities(),
	settings = {
		gopls = {
			completeUnimported = true,
			semanticTokens = true,
			usePlaceholders = true,
			analyses = {
				unusedparams = true,
			},
		},
	},
}
