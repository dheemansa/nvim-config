return {
    --{
    --    "williamboman/mason.nvim",
    --    event = "VeryLazy",
    --    config = function()
    --        require("mason").setup()
    --    end,
    --},
    --{
    --    "williamboman/mason-lspconfig.nvim",
    --    event = "VeryLazy",
    --    config = function()
    --        require("mason-lspconfig").setup({
    --            ensure_installed = { "lua_ls", "pyright" },
    --            automatic_enable = false
    --        })
    --    end
    --},
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
        },
        cmd = "Mason",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("mason").setup()
            require("mason-lspconfig").setup({
                ensure_installed = { "lua_ls", "pyright" },
                automatic_enable = false
            })

        end
    },

    {
        "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
        config = function()
            require("lsp_lines").setup()
            vim.diagnostic.config({ virtual_text = false })
        end
    },
}
