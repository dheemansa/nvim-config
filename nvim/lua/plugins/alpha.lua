return {
	"goolord/alpha-nvim",
	event = "VimEnter",
	config = function()
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")

		-- Initialize todo plugin
		local todo = require("todo")
		todo.setup({
			-- Optional: customize config for dashboard
			max_display = 5,
			text_display_length = 50, -- Longer text for dashboard
			show_stats = false, -- We'll show stats separately
		})

		-- Function to refresh dashboard todos
		local function refresh_todos()
			dashboard.section.todos.val = todo.display()
			vim.cmd("AlphaRedraw")
		end

		-- Dashboard buttons
		dashboard.section.buttons.val = {
			dashboard.button("e", "  New file", ":ene <CR>"),
			dashboard.button("f", "  Find file", ":Telescope find_files <CR>"),
			dashboard.button("r", "  Recent files", ":Telescope oldfiles <CR>"),
			dashboard.button("g", "  Find text", ":Telescope live_grep <CR>"),
			dashboard.button("t", "  Tasks", ":TodoMenu<CR>"),
			dashboard.button("a", "+  Add Task", function()
				vim.ui.input({ prompt = "New task: " }, function(input)
					if input and input ~= "" then
						-- Use async add for better UX
						todo.add_async(input, function(success, message)
							if success then
								vim.notify("Task added!", vim.log.levels.INFO)
								refresh_todos()
							else
								vim.notify("Failed to add task: " .. message, vim.log.levels.ERROR)
							end
						end)
					end
				end)
			end),
			dashboard.button(
				"c",
				"  Configuration",
				":lua require('telescope.builtin').find_files({ cwd = vim.fn.stdpath('config') })<CR>"
			),
			dashboard.button("l", "󰒲  Lazy", "<cmd>Lazy<CR>"),
			dashboard.button("q", "⨯  Quit", ":qa<CR>"),
		}

		-- Todo stats section
		local function get_todo_stats()
			local stats = todo.stats()
			if stats.total == 0 then
				return "No tasks yet - press 'a' to add one!"
			end
			return string.format(" %d/%d completed (%d%%)", stats.done, stats.total, stats.completion_rate)
		end

		dashboard.section.todo_stats = {
			type = "text",
			val = get_todo_stats(),
			opts = {
				position = "center",
				hl = "TodoStatHL",
			},
		}

		-- Todo section
		dashboard.section.todos = {
			type = "text",
			val = todo.display(),
			opts = {
				position = "center",
				hl = "TodoListHL",
			},
		}

		-- Layout with todos
		dashboard.config.layout = {
			{ type = "padding", val = 2 },
			{
				type = "text",
				val = " Today's Tasks",
				opts = { hl = "TodoHeadingHL", position = "center" },
			},
			{ type = "padding", val = 1 },
			dashboard.section.todo_stats,
			{ type = "padding", val = 1 },
			dashboard.section.todos,
			{ type = "padding", val = 2 },
			dashboard.section.buttons,
			{ type = "padding", val = 0 },
			dashboard.section.footer,
		}

		-- Footer with startup time
		dashboard.section.footer.val = function()
			local stats = require("lazy").stats()
			local ms = math.floor(stats.startuptime * 100 + 0.5) / 100
			return { "⚡ Loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms" }
		end

		-- Auto-refresh todos when dashboard is shown
		vim.api.nvim_create_autocmd("User", {
			pattern = "AlphaReady",
			callback = function()
				-- Refresh todos when dashboard opens
				dashboard.section.todos.val = todo.display()
				dashboard.section.todo_stats.val = get_todo_stats()
			end,
		})

		-- Refresh todos when returning from todo menu
		vim.api.nvim_create_autocmd("BufEnter", {
			pattern = "*",
			callback = function()
				-- Check if we're on the alpha buffer and refresh todos
				if vim.bo.filetype == "alpha" then
					vim.defer_fn(function()
						dashboard.section.todos.val = todo.display()
						dashboard.section.todo_stats.val = get_todo_stats()
						vim.cmd("AlphaRedraw")
					end, 100)
				end
			end,
		})

		alpha.setup(dashboard.opts)
	end,
}
