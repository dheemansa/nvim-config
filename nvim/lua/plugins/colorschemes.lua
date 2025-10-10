return {
	{
		"nyoom-engineering/oxocarbon.nvim",
		enabled = true,
		lazy = false,
		priority = 1000,
	},
	{
		"folke/tokyonight.nvim",
		lazy = true,
		enabled = true,
		priority = 1000,
		opts = {
			transparent = true,
		},
	},
	{
		"olimorris/onedarkpro.nvim",
		priority = 1000, -- Ensure it loads first
		opts = {
			options = {
				transparency = true,
			},
		},
	},
	{ "dasupradyumna/midnight.nvim", lazy = false, priority = 1000 },
	{
		"norcalli/nvim-colorizer.lua",
		event = "BufReadPost",
		opts = {},
	},
}
