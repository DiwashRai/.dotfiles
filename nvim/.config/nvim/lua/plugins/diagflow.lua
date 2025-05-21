return {
	"dgagn/diagflow.nvim",
	event = "LspAttach",
	opts = {
		scope = "line",
		format = function(diagnostic)
			return diagnostic.source .. ": " .. diagnostic.message .. " [" .. diagnostic.code .. "]"
		end,
	},
}
