return {
	"folke/noice.nvim",
	event = "VeryLazy",

	dependencies = {
		"MunifTanjim/nui.nvim",
		"rcarriga/nvim-notify",
	},
	config = function()
		require("notify").setup({
			fps = 60,
			render = "compact",
			stages = "fade_in_slide_out",
			timeout = 3000,
			top_down = true,
		})
		require("noice").setup({
			lsp = {
				progress = {
					enabled = true,
					--view = "notify",
					format = "lsp_progress",
					format_done = "lsp_progress_done",
				},
				hover = {
					enabled = true,
					opts = { border = "rounded" },
				},
				signature = { enabled = false },
			},

			messages = {
				enabled = true,
			},

			routes = {
				{
					-- Route small, frequent status messages to the mini view
					-- Examples:
					--   "lua/plugins/telescope.lua" 29L, 1198B written   -> file stats after write/open
					--   "18 fewer lines; before #10"                    -> search boundary feedback
					--   "18 lines yanked"                               -> yank operation summary
					--   "18 more lines"                                 -> extra lines message (e.g., join or delete)
					filter = {
						event = "msg_show",
						any = {
							{ find = "%d+L, %d+B" }, -- file stats, e.g. "29L, 1198B"
							{ find = "; after #%d+" }, -- search result past last match
							{ find = "; before #%d+" }, -- search result before first match
							{ find = "lines yanked" }, -- yank count message
							{ find = "more lines" }, -- "X more lines" message
							{ find = "fewer lines" },
						},
					},
					view = "mini", -- show as small inline message
				},
				{
					-- Route macro recording messages (e.g. "recording @q") to notifications
					--view = "notify",
					view = "mini",
					filter = { event = "msg_showmode" },
				},
			},
			presets = {
				bottom_search = true,
				command_palette = true,
				long_message_to_split = true,
			},
		})

		-- Add autocmd for macro finished notification
		vim.api.nvim_create_autocmd("RecordingLeave", {
			callback = function()
				local reg = vim.v.event.regname
				vim.notify("Macro @" .. reg .. " recorded!", vim.log.levels.INFO)
			end,
		})
		vim.keymap.set("n", "<leader>nd", function()
			require("notify").dismiss({ silent = true, pending = true })
		end, { desc = "Dismiss notifications" })
	end,
}
