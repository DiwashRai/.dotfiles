-- [[ Configure and install plugins ]]
--
local function setup_pack_plugins()
	-- vim.pack quick reference:
	--   :PackList                         show pack-managed plugin names
	--   :PackUpdate                       update all pack-managed plugins
	--   :PackUpdate kanagawa.nvim oil.nvim update specific plugins
	--   :PackRestore                      restore/update plugins to pinned versions
	--   :PackDelete rose-pine             delete disabled/removed plugins manually
	--
	-- lazy.nvim resets 'packpath' during startup by default. Add the standard
	-- vim.pack site directory back before calling vim.pack.add().
	local site = vim.fs.joinpath(vim.fn.stdpath("data"), "site")
	if not vim.tbl_contains(vim.opt.packpath:get(), site) then
		vim.opt.packpath:append(site)
	end

	vim.pack.add({
		{ src = "https://github.com/rebelot/kanagawa.nvim", version = "master" },
		-- { src = "https://github.com/rose-pine/neovim", name = "rose-pine" },
		{ src = "https://github.com/tpope/vim-sleuth" },
		{ src = "https://github.com/mhinz/vim-signify" },
		{ src = "https://github.com/tpope/vim-fugitive" },
		{ src = "https://github.com/nvim-lua/plenary.nvim" },
	}, { confirm = false, load = true })

	vim.cmd.colorscheme("kanagawa")

	require("plugins.mini")
	require("plugins.oil")
	require("plugins.harpoon")
	require("plugins.toggleterm")
end

-- lazy.nvim remains responsible for plugins that benefit from lazy-loading,
-- build hooks, dependency orchestration, or richer plugin specs.
require("lazy").setup({
	-- [[ Simple lazy-loaded plugins ]]
	require("plugins.autopairs"),
	require("plugins.telescope"),
	require("plugins.which-key"),
	require("plugins.flash"),

	-- [[ More demanding plugins ]]
	require("plugins.treesitter"),
	require("plugins.lsp"), -- LSP support plugins
	require("plugins.blink-cmp"), -- Autocompletion
	require("plugins.conform"), -- Autoformat
	require("plugins.diagflow"), -- Diagnostics on top right of buffer.
	require("plugins.codediff"),

	-- [[ Specific plugins ]]
	-- require("plugins.cmake-tools"),
	require("plugins.checkmate"),
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

-- Pack plugins currently need to run after lazy.nvim, because lazy resets 'packpath' during setup
-- We use a function call so we still see the 'simpler' plugins first visually
setup_pack_plugins()

vim.api.nvim_create_user_command("PackList", function()
	for _, plugin in ipairs(vim.pack.get(nil, { info = false })) do
		print(plugin.spec.name)
	end
end, { desc = "List vim.pack-managed plugins" })

vim.api.nvim_create_user_command("PackUpdate", function(opts)
	local names = #opts.fargs > 0 and opts.fargs or nil
	vim.pack.update(names)
end, {
	nargs = "*",
	complete = function()
		return vim.tbl_map(function(plugin)
			return plugin.spec.name
		end, vim.pack.get(nil, { info = false }))
	end,
	desc = "Update vim.pack-managed plugins",
})

vim.api.nvim_create_user_command("PackRestore", function(opts)
	local names = #opts.fargs > 0 and opts.fargs or nil
	vim.pack.update(names, { target = "version" })
end, {
	nargs = "*",
	complete = function()
		return vim.tbl_map(function(plugin)
			return plugin.spec.name
		end, vim.pack.get(nil, { info = false }))
	end,
	desc = "Restore vim.pack-managed plugins to pinned versions",
})

vim.api.nvim_create_user_command("PackDelete", function(opts)
	vim.pack.del(opts.fargs)
end, {
	nargs = "+",
	complete = function()
		return vim.tbl_map(function(plugin)
			return plugin.spec.name
		end, vim.pack.get(nil, { info = false }))
	end,
	desc = "Delete vim.pack-managed plugins",
})
