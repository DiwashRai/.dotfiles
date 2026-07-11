vim.pack.add({
	{ src = "https://github.com/ThePrimeagen/harpoon", version = "harpoon2" },
}, { confirm = false, load = true })

require("harpoon"):setup()
