-- [[ Keymaps ]]

-- editing keymaps
vim.keymap.set("v", "<leader>p", [["_dP]], { desc = "[P]aste over without yank" })
vim.keymap.set("v", "<", "<gv", { desc = "Shift left and stay in indent mode" })
vim.keymap.set("v", ">", ">gv", { desc = "Shift right and stay in indent mode" })

-- move text up and down
vim.keymap.set("v", "<S-j>", ":m .+1<CR>==gv", { desc = "Visual move line (+) 1" })
vim.keymap.set("v", "<S-k>", ":m .-2<CR>==gv", { desc = "Visual move line (-) 1" })

-- window navigation
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- window resize
vim.keymap.set("n", "<C-Up>", ":resize -2<CR>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Down>", ":resize +2<CR>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

-- buffers
vim.keymap.set("n", "<S-l>", ":bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<S-h>", ":bprevious<CR>", { desc = "Previous buffer" })

-- quickfix
vim.keymap.set("n", "]q", ":cnext<CR>", { desc = "Next quickfix" })
vim.keymap.set("n", "[q", ":cprevious<CR>", { desc = "Previous quickfix" })

vim.keymap.set("n", "<Esc>", "<cmd>noh<CR><esc>")
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Git
vim.keymap.set("n", "<leader>gg", ":vertical Git<CR>", { desc = "[g]o [g]it" })
vim.keymap.set("n", "<leader>gl", ":vertical Git log --oneline<CR>", { desc = "[g]it [l]og" })
vim.keymap.set("n", "<leader>gd", ":Gvdiff<CR>", { desc = "[g]it [d]iff" })
vim.keymap.set("n", "<leader>gb", ":Git blame<CR>", { desc = "[g]it [b]lame" })

-- Diffview
vim.keymap.set("n", "<leader>do", ":DiffviewOpen", { desc = "[d]iffview [o]pen" })
vim.keymap.set("n", "<leader>dc", ":DiffviewClose<CR>", { desc = "[d]iffview [c]lose" })
vim.keymap.set("n", "<leader>dh", ":DiffviewFileHistory %<CR>", { desc = "[d]iffview file [h]istory" })
vim.keymap.set("n", "<leader>db", ":DiffviewFileHistory<CR>", { desc = "[d]iffview [b]ranch history" })

-- Harpoon
vim.keymap.set("n", "<leader><leader>", function()
	local harpoon = require("harpoon")
	harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = "harpoon quick menu" })
vim.keymap.set("n", "<leader>ha", function()
	require("harpoon"):list():add()
end, { desc = "[H]arpoon [A]dd" })
vim.keymap.set("n", "<leader>1", function()
	require("harpoon"):list():select(1)
end, { desc = "harpoon select [1]" })
vim.keymap.set("n", "<leader>2", function()
	require("harpoon"):list():select(2)
end, { desc = "harpoon select [2]" })
vim.keymap.set("n", "<leader>3", function()
	require("harpoon"):list():select(3)
end, { desc = "harpoon select [3]" })
vim.keymap.set("n", "<leader>4", function()
	require("harpoon"):list():select(4)
end, { desc = "harpoon select [4]" })
vim.keymap.set("n", "<C-S-P>", function()
	require("harpoon"):list():prev()
end, { desc = "harpoon [p]rev" })
vim.keymap.set("n", "<C-S-N>", function()
	require("harpoon"):list():next()
end, { desc = "harpoon [n]ext" })

-- Telescope
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
vim.keymap.set("n", "<leader>sc", builtin.commands, { desc = "[S]earch [C]ommands" })
vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set("n", "<leader>sb", builtin.buffers, { desc = "[S]earch existing [B]uffers" })

-- Slightly advanced example of overriding default behavior and theme
vim.keymap.set("n", "<leader>/", function()
	-- You can pass additional configuration to Telescope to change the theme, layout, etc.
	builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
		winblend = 10,
		previewer = false,
	}))
end, { desc = "[/] Fuzzily search in current buffer" })

-- It's also possible to pass additional configuration options.
--  See `:help telescope.builtin.live_grep()` for information about particular keys
vim.keymap.set("n", "<leader>s/", function()
	builtin.live_grep({
		grep_open_files = true,
		prompt_title = "Live Grep in Open Files",
	})
end, { desc = "[S]earch [/] in Open Files" })

-- Shortcut for searching your Neovim configuration files
vim.keymap.set("n", "<leader>sn", function()
	builtin.find_files({ cwd = vim.fn.stdpath("config") })
end, { desc = "[S]earch [N]eovim files" })

--  This function gets run when an LSP attaches to a particular buffer.
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
	callback = function(event)
		local map = function(keys, func, desc, mode)
			mode = mode or "n"
			vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
		end

		map("grn", vim.lsp.buf.rename, "[R]e[n]ame")
		map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })
		map("grr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")

		-- Jump to the implementation of the word under your cursor.
		--  Useful when your language has ways of declaring types without an actual implementation.
		map("gi", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

		-- Jump to the definition of the word under your cursor.
		--  This is where a variable was first declared, or where a function is defined, etc.
		--  To jump back, press <C-t>.
		map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

		-- WARN: This is not Goto Definition, this is Goto Declaration.
		--  For example, in C this would take you to the header.
		map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

		-- Jump to the type of the word under your cursor.
		--  Useful when you're not sure what type a variable is and you want to see
		--  the definition of its *type*, not where it was *defined*.
		map("gt", require("telescope.builtin").lsp_type_definitions, "[G]oto [T]ype Definition")

		map("<leader>l", function()
			vim.diagnostic.open_float(nil, { focusable = false, source = "if_many", max_width = 80 })
		end, "LSP [L]ine diagnostic")

		-- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
		---@param client vim.lsp.Client
		---@param method vim.lsp.protocol.Method
		---@param bufnr? integer some lsp support methods only in specific files
		---@return boolean
		local function client_supports_method(client, method, bufnr)
			if vim.fn.has("nvim-0.11") == 1 then
				return client:supports_method(method, bufnr)
			else
				return client.supports_method(method, { bufnr = bufnr })
			end
		end

		-- The following two autocommands are used to highlight references of the
		-- word under your cursor when your cursor rests there for a little while.
		--    See `:help CursorHold` for information about when this is executed
		--
		-- When you move your cursor, the highlights will be cleared (the second autocommand).
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		-- The following code creates a keymap to toggle inlay hints in your
		-- code, if the language server you are using supports them
		--
		-- This may be unwanted, since they displace some of your code
		if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
			map("<leader>th", function()
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
			end, "[T]oggle Inlay [H]ints")
		end
	end,
})
-- vim: ts=2 sts=2 sw=2 et
