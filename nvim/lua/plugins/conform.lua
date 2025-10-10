return {
	{
		"stevearc/conform.nvim",
		event = { "BufReadPost", "BufNewFile" },
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "black" },
			},

			format_on_save = {
				-- These options will be passed to conform.format()
				timeout_ms = 5000,
				lsp_format = "fallback",
			},
			notify_no_formatters = true,
		},
	},
}
