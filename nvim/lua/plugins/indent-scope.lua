return {
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {
			indent = { char = "│" },
		},
		event = "VeryLazy",
	},

	{
		"nvim-mini/mini.indentscope",
		event = "VeryLazy",
		enabled = true,
		version = "*",
		opts = {
			symbol = "│",
			options = {
				try_as_border = true,
				border = "top",
			},
		},
	},
}
