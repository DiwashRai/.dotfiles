
local group = vim.api.nvim_create_augroup("custom", { clear = true });

-- Stripe trailing white space
vim.api.nvim_create_autocmd("BufWritePre", { pattern = "*", command = "%s/\\s\\+$//e", group = group })
