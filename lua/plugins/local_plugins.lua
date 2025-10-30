return {
	{
		"todo",
		dev = true,
		config = function()
			require("local_plugins.todo").setup({
				auto_delete_completed_after_24h = true,
			})
		end,
		cmd = { "TodoMenu", "TodoList" },
	},
	{
		"floaterminal",
		dev = true,
		cmd = "Floaterminal",
		config = function(_, opts)
			require("local_plugins.floaterminal").setup(opts)
		end,
		opts = {
			-- To use a custom shell, uncomment the line below and replace "bash" with your desired shell.
			-- For example: shell = "fish", or shell = "zsh"
			-- Default to Neovim's default terminal
			-- shell = nil

			shell = "fish",
			width = 0.9, -- Fraction of columns (0-1) or absolute value (>1)
			height = 0.85, -- Fraction of lines (0-1) or absolute value (>1)
		},
	},
}
