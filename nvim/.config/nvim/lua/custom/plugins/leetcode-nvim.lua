
local leet_arg = "leetcode"

return {
    "kawre/leetcode.nvim",
    build = ":TSUpdate html",
    dependencies = {
        "nvim-telescope/telescope.nvim",
        "nvim-lua/plenary.nvim", -- required by telescope
        "MunifTanjim/nui.nvim",

        -- optional
        "nvim-treesitter/nvim-treesitter",
        "rcarriga/nvim-notify",
    },
    lazy = leet_arg ~= vim.fn.argv()[1],
    opts = {
        -- configuration goes here
        arg = leet_arg,
        hooks = {
          LeetEnter = {
            function()
              vim.cmd.colorscheme 'rose-pine'
            end,
          },
        },
    },
}
