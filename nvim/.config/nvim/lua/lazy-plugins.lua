-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
-- NOTE: Here is where you install your plugins.
require("lazy").setup({
	-- NOTE: Plugins can be set in 5 different ways:
	-- 1: String short hand of shortened or full git URL
	-- 2: Table spec. First arg is the link and other keys are opts, event, dependencies etc
	-- 3: Module based spec. require("file.path") and in file.path, you can use the table spec
	-- 4: Import entire dir. Use a table such as { import = "plugins" } loads every file under lua/plugins
	-- 5: Local(dev) plugins

	-- [[ Colorschemes ]] use one at a time
	-- require("plugins.gruvbox"),
	-- require("plugins.gruvbox-material"),
	require("plugins.kanagawa"),
	-- require("plugins.rose-pine"),

	-- [[ Simple plugins ]] that hopefully works in any env
	"tpope/vim-sleuth",
	"mhinz/vim-signify",
	"tpope/vim-fugitive",
	require("plugins.mini"),
	require("plugins.oil"),
	require("plugins.autopairs"),
	require("plugins.telescope"),
	require("plugins.which-key"),
	require("plugins.harpoon"),
	require("plugins.flash"),
	require("plugins.toggleterm"),

	-- [[ More demanding plugins ]]
	require("plugins.treesitter"),
	require("plugins.lspconfig"), -- language servers defined in here
	require("plugins.blink-cmp"), -- Autocompletion
	require("plugins.conform"), -- Autoformat
	-- require("plugins.lint"), -- Linting
	require("plugins.diagflow"), -- Diagnostics on top right of buffer. Load after lspconfig

	-- [[ Specific plugins ]]
	-- require("plugins.cmake-tools"),
	require("plugins.checkmate"),
	require("plugins.copilot"),
	require("plugins.codecompanion"),
}, {
	ui = {
		-- If you are using a Nerd Font: set icons to an empty table which will use the
		-- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
		icons = vim.g.have_nerd_font and {} or {
			cmd = "⌘",
			config = "🛠",
			event = "📅",
			ft = "📂",
			init = "⚙",
			keys = "🗝",
			plugin = "🔌",
			runtime = "💻",
			require = "🌙",
			source = "📄",
			start = "🚀",
			task = "📌",
			lazy = "💤 ",
		},
	},
})

-- vim: ts=2 sts=2 sw=2 et
