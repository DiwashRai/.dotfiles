local status_ok, configs = pcall(require, "nvim-treesitter.configs")
if not status_ok then
    return
end

configs.setup({
    ensure_installed = {
        "bash",
        "c",
        "cmake",
        "cpp",
        "haskell",
        "help",
        "html",
        "javascript",
        "json",
        "latex",
        "markdown",
        "python",
        "regex",
        "scss",
        "toml",
        "typescript",
        "vim",
        "yaml"
    },
    ignore_install = { "" }, -- List of parsers to ignore installing (for "all")
    highlight = {
        enable = true, -- false will disable the whole extension
        disable = { "" }, -- list of language that will be disabled
    },
    autopairs = {
        enable = true,
    },
    indent = { enable = true, disable = { "python", "css", "cpp" } },
})
