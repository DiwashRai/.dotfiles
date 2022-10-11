local opts = { noremap = true, silent = true }

local keymap = vim.api.nvim_set_keymap

-- Remap space as leader key
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- Normal --
-- Better window navigation
keymap("n", "<leader>h", "<C-w>h", opts)
keymap("n", "<leader>j", "<C-w>j", opts)
keymap("n", "<leader>k", "<C-w>k", opts)
keymap("n", "<leader>l", "<C-w>l", opts)

-- File explorer left
keymap("n", "<leader>e", ":NvimTreeToggle<cr>", opts)

-- Resize with arrows
keymap("n", "<C-Up>", ":resize -2<CR>", opts)
keymap("n", "<C-Down>", ":resize +2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Navigate buffers
keymap("n", "<S-l>", ":bnext<CR>", opts)
keymap("n", "<S-h>", ":bprevious<CR>", opts)

-- Visual --
-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Move text up and down
keymap("v", "<A-j>", ":m .+1<CR>==", opts)
keymap("v", "<A-k>", ":m .-2<CR>==", opts)
keymap("v", "p", '"_dP', opts)

-- Visual Block --
-- Move text up and down
keymap("x", "J", ":move '>+1<CR>gv-gv", opts)
keymap("x", "K", ":move '<-2<CR>gv-gv", opts)
keymap("x", "<A-j>", ":move '>+1<CR>gv-gv", opts)
keymap("x", "<A-k>", ":move '<-2<CR>gv-gv", opts)

-- Telescope shortcuts --
--keymap("n", "<leader>f", "<cmd>Telescope find_files()<cr>", opts)
keymap(
    "n",
    "<leader>f",
    ":lua require('telescope.builtin').find_files({find_command={'rg', '--ignore', '-L', '--hidden', '--files'}})<cr>",
    opts
)
keymap(
    "n",
    "<leader>r",
    ":lua require('telescope.builtin').live_grep({vimgrep_arguments={'rg', '--no-heading', '--with-filename', '--line-number', '--column', '--smart-case', '-L'}})<cr>",
    opts
)
keymap("n", "<S-b>", "<cmd>Telescope buffers<cr>", opts)
keymap("n", "<leader>g", "<cmd>:lua _LAZYGIT_TOGGLE()<cr>", opts)
keymap("n", "<C-h>", "<cmd>Telescope help_tags<cr>", opts)

-- CMake
keymap("n", "<leader>cg", ":CMakeGenerate<CR>", opts)
keymap("n", "<leader>cb", ":CMakeBuild<CR>", opts)
keymap("n", "<leader>co", ":CMakeOpen<CR>", opts)
keymap("n", "<leader>cq", ":CMakeClose<CR>", opts)

-- Debug
keymap("n", "<F5>", ":lua require'dap'.continue()<CR>", opts)
keymap("n", "<F10>", ":lua require'dap'.step_over()<CR>", opts)
keymap("n", "<F11>", ":lua require'dap'.step_into()<CR>", opts)
keymap("n", "<F12>", ":lua require'dap'.step_out()<CR>", opts)
keymap("n", "<leader>b", ":lua require'dap'.toggle_breakpoint()<CR>", opts)
keymap("n", "<leader>dl", ":lua require'dap'.run_last()<CR>", opts)

