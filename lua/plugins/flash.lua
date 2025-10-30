return {
	"folke/flash.nvim",
	--event = "VeryLazy",
	lazy = true,
	opts = {},
	keys = {
		{
			--might consider using <leader><leader>
			"gs",
			mode = { "n", "x", "o" },
			function()
				require("flash").jump()
			end,
			desc = "Flash (gs)",
		},
		{
			"gS",
			mode = { "n", "x", "o" },
			function()
				require("flash").treesitter()
			end,
			desc = "Flash Treesitter (gS)",
		},
		--{ "r", mode = { "o", "x" }, function() require("flash").remote() end, desc = "Remote Flash" },
		--{ "R", mode = { "o", "x" }, function() require("flash").treesitter_remote() end, desc = "Remote Flash Treesitter" },
	},
}
