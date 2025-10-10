return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = 'master',
        event = { "BufReadPost", "BufNewFile" },
        --lazy = false,
        build = ":TSUpdate",
        opts = {
                ensure_installed = {
                    "lua",
                    "vim",
                    "vimdoc",
                    "python",
                    "javascript",
                    "html",
                    "css",
                    "json",
                    "markdown",
                    "bash"
                },
                sync_install = false,
                auto_install = true, -- Automatically install parsers for new filetypes
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },
                indent = { enable = true },
            }
    }
}
