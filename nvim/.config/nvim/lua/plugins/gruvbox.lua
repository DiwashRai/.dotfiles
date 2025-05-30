return {
	"morhetz/gruvbox",
	priority = 1000,
	config = function()
		vim.g.gruvbox_contrast_dark = "hard"
		vim.cmd.colorscheme("gruvbox")
	end,
}
-- vim: ts=2 sts=2 sw=2
