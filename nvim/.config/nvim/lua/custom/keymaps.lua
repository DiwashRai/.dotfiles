-- Oil.nvim
vim.keymap.set("n", "-", require("oil").open, { desc = "Open parent directory" })

-- window navigation
-- vim.keymap.set('n', '<leader>h', '<C-w>h', { desc = 'Move to left window' } )
-- vim.keymap.set('n', '<leader>j', '<C-w>j', { desc = 'Move to lower window' } )
-- vim.keymap.set('n', '<leader>k', '<C-w>k', { desc = 'Move to upper window' } )
-- vim.keymap.set('n', '<leader>l', '<C-w>l', { desc = 'Move to right window' } )

-- window resize
vim.keymap.set("n", "<C-Up>", ":resize -2<CR>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Down>", ":resize +2<CR>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

-- buffers
vim.keymap.set("n", "<S-l>", ":bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<S-h>", ":bprevious<CR>", { desc = "Previous buffer" })

-- extra search keymaps
vim.keymap.set("n", "<leader>sk", require("telescope.builtin").keymaps, { desc = "[S]earch [K]eymaps" })
vim.keymap.set("n", "<leader>sc", require("telescope.builtin").commands, { desc = "[S]earch [C]ommands" })

-- editing keymaps
vim.keymap.set("v", "<leader>p", [["_dP]], { desc = "[P]aste over without yank" })
vim.keymap.set("v", "<", "<gv", { desc = "Shift left and stay in indent mode" })
vim.keymap.set("v", ">", ">gv", { desc = "Shift right and stay in indent mode" })

-- move text up and down
vim.keymap.set("v", "<A-j>", ":m .+1<CR>==gv", { desc = "Visual move line (+) 1" })
vim.keymap.set("v", "<A-k>", ":m .-2<CR>==gv", { desc = "Visual move line (-) 1" })

-- center search results
vim.keymap.set("n", "n", "nzz", { desc = "Find next occurence and center" })
vim.keymap.set("n", "N", "Nzz", { desc = "Find previous occurence and center" })

-- CMake
vim.keymap.set("n", "<leader>cg", ":CMakeGenerate<CR>", { desc = "[C]Make[G]enerate" })
vim.keymap.set("n", "<leader>cb", ":CMakeBuild<CR>", { desc = "[C]Make[B]uild" })
vim.keymap.set("n", "<leader>cl", ":CMakeClean<CR>", { desc = "[C]MakeC[l]ean" })
vim.keymap.set("n", "<leader>cd", ":CMakeSwitch Debug<CR>", { desc = "[C]MakeSwitch [D]ebug" })
vim.keymap.set("n", "<leader>cr", ":CMakeSwitch Release<CR>", { desc = "[C]MakeSwitch [R]elease" })
vim.keymap.set("n", "<leader>co", ":CMakeOpen<CR>", { desc = "[C]Make[O]pen" })
vim.keymap.set("n", "<leader>cq", ":CMakeClose<CR>", { desc = "[C]MakeClose ([q]uit)" })

-- Clang format
vim.keymap.set("n", "<leader>cf", ":Format<CR>", { desc = "[C]lang [F]ormat" })

-- no neck pain
vim.keymap.set("n", "<leader>np", ":NoNeckPain<CR>", { desc = "[N]eck [P]ain" })

-- Leet
vim.keymap.set("n", "<leader>lr", ":Leet run<CR>", { desc = "[L]eet [R]un" })
vim.keymap.set("n", "<leader>ls", ":Leet submit<CR>", { desc = "[L]eet [S]ubmit" })

-- quickfix
vim.keymap.set("n", "]q", ":cnext<CR>", { desc = "Next quickfix" })
vim.keymap.set("n", "[q", ":cprevious<CR>", { desc = "Previous quickfix" })

-- code[F]orces
vim.keymap.set("n", "<leader>fr", ":CompetiTest run<CR>", { desc = "[F]orces [R]un" })
vim.keymap.set("n", "<leader>fs", ":CompetiTest show_ui<CR>", { desc = "[F]orces [S]how UI" })
vim.keymap.set("n", "<leader>ft", ":CompetiTest receive testcases<CR>", { desc = "[F]orces receive [T]estcases" })
vim.keymap.set("n", "<leader>fp", ":CompetiTest receive problem<CR>", { desc = "[F]orces receive [P]roblem" })
vim.keymap.set("n", "<leader>fe", ":CompetiTest edit_testcase<CR>", { desc = "[F]orces [E]dit" })
vim.keymap.set("n", "<leader>fa", ":CompetiTest add_testcase<CR>", { desc = "[F]orces [A]dd" })
vim.keymap.set("n", "<leader>fd", ":CompetiTest delete_testcase<CR>", { desc = "[F]orces [D]elete" })
