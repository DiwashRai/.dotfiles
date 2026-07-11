return {
	capabilities = require("blink.cmp").get_lsp_capabilities(),
	settings = {
		gopls = {
			completeUnimported = true,
			usePlaceholders = true,
			analyses = {
				unusedparams = true,
			},
		},
	},
}
