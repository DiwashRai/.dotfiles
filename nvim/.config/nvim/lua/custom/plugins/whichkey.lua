
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  config = function()
    local wk = require("which-key")
    wk.register({
      mode = { "n", "v" },
      ["g"] = { name = "+goto" },
      ["]"] = { name = "+next" },
      ["["] = { name = "+prev" },
      -- ["<leader>b"] = { name = "+buffer" },
      ["<leader>c"] = { name = "+code" },
      ["<leader>e"] = { name = "+netrw explore" },
      -- ["<leader>f"] = { name = "+file" },
      ["<leader>g"] = { name = "+git" },
      -- ["<leader>n"] = { name = "+noice" },
      -- ["<leader>o"] = { name = "+open" },
      --["<leader>q"] = { name = "+quit/session" },
      ["<leader>s"] = { name = "+search" },
      -- ["<leader>t"] = { name = "+toggle" },
      ["<leader>x"] = { name = "+diagnostics/quickfix" },
      ["<leader>w"] = { name = "+workspaces" },
      -- ["<leader><tab>"] = { name = "+tabs" },
      ["<leader>l"] = { name = "+leetcode/lsp" },
      ["<leader>f"] = { name = "+code[F]orces"}
    })
  end,
}
