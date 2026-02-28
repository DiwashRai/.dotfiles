-- Git
vim.keymap.set("n", "<leader>gg", ":vertical Git<CR>", { desc = "[g]o [g]it" })
vim.keymap.set(
	"n",
	"<leader>gl",
	":vertical Git log --oneline --graph --decorate --pretty=format:'%C(auto)%h - %d %s %C(blue)<%an>%C(reset) %C(black bold)%cr'<CR>",
	{ desc = "[g]it [l]og" }
)
vim.keymap.set("n", "<leader>gd", ":CodeDiff file HEAD<CR>", { desc = "[g]it [d]iff" })
vim.keymap.set("n", "<leader>gb", ":Git blame<CR>", { desc = "[g]it [b]lame" })
vim.keymap.set("n", "<leader>gr", ":CodeDiff main...HEAD", { desc = "[g]it [r]eview" })

-- CodeDiff
vim.keymap.set("n", "<leader>do", ":CodeDiff ", { desc = "[d]iff [o]pen" })
vim.keymap.set("n", "<leader>df", ":CodeDiff history %<CR>", { desc = "[d]iff history [f]ile" })
vim.keymap.set("n", "<leader>db", ":CodeDiff history<CR>", { desc = "[d]iffview history [b]ranch" })

vim.keymap.set("n", "<leader>gr", function()
	local out = vim.fn.systemlist("git config --get review.base")
	if vim.v.shell_error ~= 0 or not out[1] or out[1] == "" then
		vim.notify("review.base not set. Run: git config --local review.base main-branch", vim.log.levels.ERROR)
		return
	end

	local base = out[1]
	vim.cmd(("CodeDiff %s...HEAD"):format(base))
end, { desc = "[g]it [r]eview" })
