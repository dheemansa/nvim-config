return {
	{
		"folke/noice.nvim",
		--lazy = false,
		event = "VeryLazy",

		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify", -- optional but recommended
		},
		config = function()
			require("noice").setup({
				lsp = {
					progress = { enabled = true },
					hover = {
						enabled = true,
						opts = { border = "rounded" },
					},
					signature = { enabled = false },
				},
				presets = {
					bottom_search = true, -- use classic bottom cmdline for search
					command_palette = true,
					long_message_to_split = true,
				},
				messages = {
					enabled = true,
				},
				routes = {
					{
						filter = {
							event = "msg_showmode",
							find = "^-- INSERT --",
						},
						opts = { skip = true },
					},
					{
						filter = {
							event = "msg_showmode",
							find = "^-- VISUAL",
						},
						opts = { skip = true },
					},
					{
						view = "notify",
						filter = { event = "msg_showmode" },
					},
				},
				-- Add autocmd for macro finished notification
				vim.api.nvim_create_autocmd("RecordingLeave", {
					callback = function()
						local reg = vim.v.event.regname
						vim.notify("Macro @" .. reg .. " recorded!", vim.log.levels.INFO)
					end,
				}),
			})
		end,
	},
}
