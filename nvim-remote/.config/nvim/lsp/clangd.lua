return {
	cmd = { "clangd", "--background-index" },
	root_markers = {
		".clangd",
		".clang-tidy",
		".clang-format",
		"compile_commands.json",
		"compile_flags.txt",
		"configure.ac",
		".git",
	},
	filetypes = { "c", "cpp", "objc", "objcpp" },
	single_file_support = true,
	-- Client capabilities tell clangd what Neovim/blink.cmp can handle; these
	-- extras preserve clangd-specific completion and offset negotiation.
	capabilities = require("blink.cmp").get_lsp_capabilities({
		textDocument = {
			completion = {
				editsNearCursor = true,
			},
		},
		offsetEncoding = { "utf-8", "utf-16" },
	}),
}
