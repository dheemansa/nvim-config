return {
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		event = { "BufReadPost", "BufNewFile" },
		opts = {
			indent = { char = "│" },
		},
	},

	{
		"nvim-mini/mini.indentscope",
		version = "*",
		event = { "BufReadPost", "BufNewFile" },
		opts = {
			symbol = "│",
			options = {
				try_as_border = true,
				border = "top",
			},
		},
	},
}
