return {
    {
        "williamboman/mason.nvim",
        lazy = true,
        cmd = {
            "Mason",
            "MasonInstall",
            "MasonUninstall",
            "MasonUninstallAll",
            "MasonLog",
            "MasonUpdate",
            "MasonUpdateAll",
        },
        opts = {}
    },
    {
        "williamboman/mason-lspconfig.nvim",
        lazy = true,
        opts = {
            ensure_installed = { "lua_ls", "pyright" },
            automatic_enable = false
        }
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
        },
        event = { "BufReadPre", "BufNewFile" },
        --config = function()
            --    require("mason").setup()
            --    require("mason-lspconfig").setup({
                --        ensure_installed = { "lua_ls", "pyright" },
                --        automatic_enable = false
                --    })

                --end
            },

            {
                "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
                event = "LspAttach",
                config = function()
                    require("lsp_lines").setup()
                    vim.diagnostic.config({ virtual_text = false })
                end
            },
        }
