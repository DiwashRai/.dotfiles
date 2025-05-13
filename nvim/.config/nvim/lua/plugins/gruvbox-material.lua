return {
	"sainnhe/gruvbox-material",
	priority = 1000,
	config = function()
		vim.g.gruvbox_material_background = "hard"
		vim.g.gruvbox_material_foreground = "material"
		vim.cmd.colorscheme("gruvbox-material")
	end,
}
-- vim: ts=2 sts=2 sw=2 et
