return {
	cmd = { "pyright-langserver", "--stdio" },
	filetypes = { "python" },
	root_markers = {
		"pyrightconfig.json",
		"pyproject.toml",
		"setup.py",
		"setup.cfg",
		"requirements.txt",
		"Pipfile",
		".git",
	},
	capabilities = require("blink.cmp").get_lsp_capabilities(),
	settings = {
		python = {
			analysis = {
				autoSearchPaths = true,
				diagnosticMode = "openFilesOnly",
				useLibraryCodeForTypes = true,
			},
		},
	},
	on_attach = function(client, bufnr)
		vim.api.nvim_buf_create_user_command(bufnr, "LspPyrightOrganizeImports", function()
			local params = {
				command = "pyright.organizeimports",
				arguments = { vim.uri_from_bufnr(bufnr) },
			}

			client.request("workspace/executeCommand", params, nil, bufnr)
		end, {
			desc = "Organize Imports",
		})
	end,
}
