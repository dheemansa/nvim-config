return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.8",
	dependencies = { "nvim-lua/plenary.nvim" },
	cmd = "Telescope",

    -- stylua: ignore
	keys = {
		{ "<leader>sk", function() require("telescope.builtin").keymaps() end, desc = "[S]earch [K]eymaps" },
		{ "<leader>sf", function() require("telescope.builtin").find_files() end, desc = "[S]earch [F]iles" },
		{ "<leader>sw", function() require("telescope.builtin").grep_string() end, desc = "[S]earch current [W]ord" },
		{ "<leader>sg", function() require("telescope.builtin").live_grep() end, desc = "[S]earch by [G]rep" },
		{ "<leader>sd", function() require("telescope.builtin").diagnostics() end, desc = "[S]earch [D]iagnostics" },
		{ "<leader><leader>", function() require("telescope.builtin").buffers() end, desc = "[ ] Find existing buffers" },
		{ "<leader>sn", function() require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") }) end, desc = "[S]earch [N]eovim files" },
	},

	config = function()
		require("telescope").setup({
			defaults = {
				layout_strategy = "horizontal",
				layout_config = { prompt_position = "top" },
				sorting_strategy = "ascending",
				winblend = 0,
			},
		})
	end,
}
