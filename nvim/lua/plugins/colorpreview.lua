return {
	{
		"nvim-mini/mini.hipatterns",
		event = "VeryLazy",
		opts = function()
			local hipatterns = require("mini.hipatterns")
			return {
				highlighters = {
					-- Highlight #rrggbb / #rrggbbaa colors
					hex_color = hipatterns.gen_highlighter.hex_color(),
				},
			}
		end,
	},
}
