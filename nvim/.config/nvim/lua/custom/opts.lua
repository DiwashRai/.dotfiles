
vim.wo.relativenumber = true

vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

vim.opt.list = true
vim.opt.listchars = { tab = '> ', eol = '¬', lead = ' ', trail = '·' }
vim.opt.formatoptions = "cro/"

vim.opt.colorcolumn = "100"

vim.opt.shiftwidth = 4 -- number of spaces used for indention with >>
vim.opt.tabstop = 4 -- number of spaces a tab character represents if displayed
vim.opt.expandtab = true -- should tabs be converted to spaces
vim.opt.softtabstop = 4 -- number of spaces inserted by <tab> if expandtab is sets
vim.opt.autoindent = true -- copy indent level when you insert a new line
vim.opt.smartindent = true -- inserts extra indent level after certain characters e.g. {

