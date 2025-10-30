return {
	{
		"stevearc/conform.nvim",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = { "williamboman/mason.nvim" },
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "ruff_format", "black", stop_after_first = true },
				toml = { "taplo" },
				markdown = { "prettier" },
				json = { "prettier" },
			},

			formatters = {
				prettier = {
					append_args = { "--prose-wrap", "always", "--print-width", "100" },
				},
			},

			format_on_save = {
				-- These options will be passed to conform.format()
				timeout_ms = 500,
				lsp_format = "fallback",
			},
			notify_no_formatters = true,
		},
	},
}
