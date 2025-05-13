-- NOTE: Must happen before plugins are loaded
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- [[ BASIC options ]]

vim.g.have_nerd_font = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim
vim.schedule(function()
	vim.opt.clipboard = "unnamedplus"
end)

vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true -- case insensitive search
vim.opt.smartcase = true -- override ignorecase if search has caps
vim.opt.signcolumn = "yes" -- sign column always on. Default: auto
vim.opt.updatetime = 250 -- decrease time to write swap file. Coupled with CursorHold event
vim.opt.timeoutlen = 300 -- decrease mapped sequence wait time e.g. gd, gf etc
vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.list = true
vim.opt.listchars = { tab = "» ", eol = "¬", lead = "·", trail = "·", nbsp = "␣" }

vim.opt.inccommand = "split" -- preview substitutions as you type
vim.opt.cursorline = false -- highlight the line your cursor is on. Big performance hit?
vim.opt.scrolloff = 10
vim.opt.confirm = true -- dialog when you try to exit without saving

-- [[ Install `lazy.nvim` plugin manager ]]
require("lazy-bootstrap")

-- [[ Configure and install plugins ]]
require("lazy-plugins")

-- [[ KEYMAPS ]]
require("keymaps")

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
