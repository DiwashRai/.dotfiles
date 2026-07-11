local M = {
	lazy = {},
	pack = {},
	config = {},
}

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

-- tabs
vim.keymap.set("n", "<leader>tn", "<cmd>tabnext<CR>", { desc = "[t]ab [n]ext" })
vim.keymap.set("n", "<leader>tp", "<cmd>tabprevious<CR>", { desc = "[t]ab [p]revious" })
vim.keymap.set("n", "<leader>tc", "<cmd>tabclose<CR>", { desc = "[t]ab [c]lose" })

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
		vim.hl.on_yank()
	end,
})

-- Git and CodeDiff
vim.keymap.set("n", "<leader>gg", ":vertical Git<CR>", { desc = "[G]o [G]it" })
vim.keymap.set(
	"n",
	"<leader>gl",
	":vertical Git log --oneline --graph --decorate --pretty=format:'%C(auto)%h - %d %s %C(blue)<%an>%C(reset) %C(black bold)%cr'<CR>",
	{ desc = "[G]it [L]og" }
)
vim.keymap.set("n", "<leader>gd", ":CodeDiff file HEAD<CR>", { desc = "[G]it [D]iff" })
vim.keymap.set("n", "<leader>gb", ":Git blame<CR>", { desc = "[G]it [B]lame" })
vim.keymap.set("n", "<leader>do", ":CodeDiff ", { desc = "[D]iff [O]pen" })
vim.keymap.set("n", "<leader>df", ":CodeDiff history %<CR>", { desc = "[D]iff history [F]ile" })
vim.keymap.set("n", "<leader>db", ":CodeDiff history<CR>", { desc = "[D]iff history [B]ranch" })
vim.keymap.set("n", "<leader>gr", function()
	local out = vim.fn.systemlist("git config --get review.base")
	if vim.v.shell_error ~= 0 or not out[1] or out[1] == "" then
		vim.notify("review.base not set. Run: git config --local review.base main-branch", vim.log.levels.ERROR)
		return
	end
	vim.cmd(("CodeDiff %s...HEAD"):format(out[1]))
end, { desc = "[G]it [R]eview" })

function M.set(mappings)
	for _, mapping in ipairs(mappings) do
		local opts = vim.tbl_extend("force", {}, mapping.opts or {})
		for key, value in pairs(mapping) do
			if type(key) ~= "number" and key ~= "mode" and key ~= "opts" then
				opts[key] = value
			end
		end
		vim.keymap.set(mapping.mode or "n", mapping[1], mapping[2], opts)
	end
end

-- stylua: ignore start

M.pack.oil = {
	{
		"-",
		function()
			require("oil").open()
		end,
		desc = "Open parent directory",
	},
}

local function telescope(name, opts)
	return function()
		require("telescope.builtin")[name](opts)
	end
end

M.lazy.telescope = {
	{ "<leader>sh", telescope("help_tags"), desc = "[S]earch [H]elp" },
	{ "<leader>sk", telescope("keymaps"), desc = "[S]earch [K]eymaps" },
	{ "<leader>sc", telescope("commands"), desc = "[S]earch [C]ommands" },
	{ "<leader>sf", telescope("find_files"), desc = "[S]earch [F]iles" },
	{ "<leader>ss", telescope("builtin"), desc = "[S]earch [S]elect Telescope" },
	{ "<leader>sw", telescope("grep_string"), desc = "[S]earch current [W]ord" },
	{ "<leader>sg", telescope("live_grep"), desc = "[S]earch by [G]rep" },
	{ "<leader>sd", telescope("diagnostics"), desc = "[S]earch [D]iagnostics" },
	{ "<leader>sr", telescope("resume"), desc = "[S]earch [R]esume" },
	{ "<leader>s.", telescope("oldfiles"), desc = '[S]earch Recent Files ("." for repeat)' },
	{ "<leader>sb", telescope("buffers"), desc = "[S]earch existing [B]uffers" },
	{
		"<leader>/",
		function()
			require("telescope.builtin").current_buffer_fuzzy_find(
				require("telescope.themes").get_dropdown({ winblend = 10, previewer = false })
			)
		end,
		desc = "[/] Fuzzily search in current buffer",
	},
	{
		"<leader>s/",
		telescope("live_grep", { grep_open_files = true, prompt_title = "Live Grep in Open Files" }),
		desc = "[S]earch [/] in Open Files",
	},
	{ "<leader>sn", telescope("find_files", { cwd = vim.fn.stdpath("config") }), desc = "[S]earch [N]eovim files" },
}

M.lazy.conform = {
	{ "<leader>f", function() require("conform").format({ async = true, lsp_format = "fallback" }) end, mode = "", desc = "[F]ormat buffer",
	},
}

M.config.oil = {
	["g?"] = { "actions.show_help", mode = "n" },
	["<CR>"] = "actions.select",
	["<C-s>"] = { "actions.select", opts = { vertical = true } },
	["<C-t>"] = { "actions.select", opts = { tab = true } },
	["<C-p>"] = "actions.preview",
	["<C-c>"] = { "actions.close", mode = "n" },
	["-"] = { "actions.parent", mode = "n" },
	["_"] = { "actions.open_cwd", mode = "n" },
	["`"] = { "actions.cd", mode = "n" },
	["~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
	gs = { "actions.change_sort", mode = "n" },
	gx = "actions.open_external",
	["g."] = { "actions.toggle_hidden", mode = "n" },
	["g\\"] = { "actions.toggle_trash", mode = "n" },
}

M.config.mini_surround = {
	add = "za",
	delete = "zd",
	find = "zf",
	find_left = "zF",
	highlight = "zh",
	replace = "zr",
	suffix_last = "l",
	suffix_next = "n",
}

-- stylua: ignore end

function M.setup_lsp_keymaps()
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
			map("grr", function()
				require("telescope.builtin").lsp_references()
			end, "[G]oto [R]eferences")

			-- Jump to the implementation of the word under your cursor.
			--  Useful when your language has ways of declaring types without an actual implementation.
			map("gi", function()
				require("telescope.builtin").lsp_implementations()
			end, "[G]oto [I]mplementation")

			-- Jump to the definition of the word under your cursor.
			--  This is where a variable was first declared, or where a function is defined, etc.
			--  To jump back, press <C-t>.
			map("gd", function()
				require("telescope.builtin").lsp_definitions()
			end, "[G]oto [D]efinition")

			-- WARN: This is not Goto Definition, this is Goto Declaration.
			--  For example, in C this would take you to the header.
			map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

			-- Jump to the type of the word under your cursor.
			--  Useful when you're not sure what type a variable is and you want to see
			--  the definition of its *type*, not where it was *defined*.
			map("gt", function()
				require("telescope.builtin").lsp_type_definitions()
			end, "[G]oto [T]ype Definition")

			map("<leader>l", function()
				vim.diagnostic.open_float(nil, { focusable = false, source = "if_many", max_width = 80 })
			end, "LSP [L]ine diagnostic")

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
			if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
				map("<leader>th", function()
					vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
				end, "[T]oggle Inlay [H]ints")
			end
		end,
	})
end

return M
