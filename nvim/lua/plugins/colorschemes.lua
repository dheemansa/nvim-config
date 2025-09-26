return{
    --{"catppuccin/nvim", name = "catppuccin" ,priority = 1000},
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("tokyonight").setup({
                transparent = true,
                on_colors = function(colors)
                    colors.bg_statusline = colors.none -- Makes statusline background transparent
                end,
            })
        end,
    },
    {
        'norcalli/nvim-colorizer.lua',
        event = 'BufReadPost',
        config = function()
            require 'colorizer'.setup()
        end,
    }
}
