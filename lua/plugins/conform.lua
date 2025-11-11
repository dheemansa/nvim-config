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
				css = { "prettier" },
				json = { "prettier_json" },
				jsonc = { "prettier_json" },
			},

			formatters = {
				prettier = {
                    -- stylua: ignore
					append_args = {
						"--prose-wrap", "always",
						"--print-width", "100",
						"--tab-width", "4",
						"--use-tabs", "false",
					},
				},
				prettier_json = {
					command = "prettier",
                    -- stylua: ignore
                    append_args = {
                        "--prose-wrap", "always",
                        "--print-width", "100",
                        "--tab-width", "4",
                        "--use-tabs", "false",
                        "--trailing-comma", "none",
                    },
				},
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
