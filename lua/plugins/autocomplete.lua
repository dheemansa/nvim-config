return {
	{
		"saghen/blink.cmp",
		-- optional: provides snippets for the snippet source
		dependencies = { "rafamadriz/friendly-snippets" },
		event = "InsertEnter",
		-- use a release tag to download pre-built binaries
		version = "1.*",
		-- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
		-- build = 'cargo build --release',
		-- If you use nix, you can build from source using latest nightly rust with:
		-- build = 'nix run .#build-plugin',

		---@module 'blink.cmp'
		---@type blink.cmp.Config
		opts = {
			-- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
			-- 'super-tab' for mappings similar to vscode (tab to accept)
			-- 'enter' for enter to accept
			-- 'none' for no mappings
			--
			-- All presets have the following mappings:
			-- C-space: Open menu or open docs if already open
			-- C-n/C-p or Up/Down: Select next/previous item
			-- C-e: Hide menu
			-- C-k: Toggle signature help (if signature.enabled = true)
			--
			-- See :h blink-cmp-config-keymap for defining your own keymap
            -- stylua: ignore
			keymap = {
				preset = "default",
				["<A-1>"] = { function(cmp) cmp.accept({ index = 1 }) end, },
				["<A-2>"] = { function(cmp) cmp.accept({ index = 2 }) end, },
				["<A-3>"] = { function(cmp) cmp.accept({ index = 3 }) end, },
				["<A-4>"] = { function(cmp) cmp.accept({ index = 4 }) end, },
				["<A-5>"] = { function(cmp) cmp.accept({ index = 5 }) end, },
				["<A-6>"] = { function(cmp) cmp.accept({ index = 6 }) end, },
				["<A-7>"] = { function(cmp) cmp.accept({ index = 7 }) end, },
				["<A-8>"] = { function(cmp) cmp.accept({ index = 8 }) end, },
				["<A-9>"] = { function(cmp) cmp.accept({ index = 9 }) end, },
				["<A-0>"] = { function(cmp) cmp.accept({ index = 10 }) end, },
			},

			appearance = {
				-- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
				-- Adjusts spacing to ensure icons are aligned
				nerd_font_variant = "mono",
				kind_icons = require("config.lsp_icons").kind_icons,
			},

			-- (Default) Only show the documentation popup when manually triggered
			completion = {
				documentation = { auto_show = false },
				-- Display a preview of the selected item on the current line
				ghost_text = { enabled = true },
				menu = {

					border = "rounded",
					draw = {
						columns = {
							{ "item_idx" },
							{ "label", "label_description", gap = 1 },
							{ "kind_icon", "kind", gap = 1 },
						},
						treesitter = { "lsp" },
						components = {
							item_idx = {
								text = function(ctx)
									return ctx.idx == 10 and "0" or ctx.idx >= 10 and " " or tostring(ctx.idx)
								end,
								highlight = "BlinkCmpItemIdx", -- optional, only if you want to change its color
							},
						},
					},
				},
			},

			-- Default list of enabled providers defined so that you can extend it
			-- elsewhere in your config, without redefining it, due to `opts_extend`
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
			},

			-- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
			-- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
			-- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
			--
			-- See the fuzzy documentation for more information
			fuzzy = { implementation = "prefer_rust_with_warning" },
		},
		opts_extend = { "sources.default" },
	},

	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
		opts = {
			enable_check_bracket_line = true,
			check_ts = true,
		},
	},
}
