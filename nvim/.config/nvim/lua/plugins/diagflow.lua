return {
	"dgagn/diagflow.nvim",
	event = "LspAttach",
	opts = {
		scope = "line",
		format = function(diagnostic)
			local src = diagnostic.source and (diagnostic.source .. ": ") or ""
			local code = diagnostic.code and (" [" .. diagnostic.code .. "]") or ""
			return src .. diagnostic.message .. code
		end,
	},
}
