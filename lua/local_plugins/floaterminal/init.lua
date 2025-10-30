local M = {}

local state = {
	floating = {
		buf = -1,
		win = -1,
	},
}

local function create_floating_window(opts)
	opts = opts or {}
	local width = opts.width or math.floor(vim.o.columns * 0.8)
	local height = opts.height or math.floor(vim.o.lines * 0.8)

	-- Calculate the position to center the window
	local col = math.floor((vim.o.columns - width) / 2)
	local row = math.floor((vim.o.lines - height) / 2)

	-- Create a buffer
	local buf = nil
	if vim.api.nvim_buf_is_valid(opts.buf) then
		buf = opts.buf
	else
		buf = vim.api.nvim_create_buf(false, true) -- No file, scratch buffer
	end

	-- Define window configuration
	local win_config = {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		style = "minimal", -- No borders or extra UI elements
		border = "rounded",
	}

	-- Create the floating window
	local win = vim.api.nvim_open_win(buf, true, win_config)
	return { buf = buf, win = win }
end

-- Store plugin options
local config = {}

function M.toggle_terminal()
	if not vim.api.nvim_win_is_valid(state.floating.win) then
		-- Check if buffer was manually deleted
		if not vim.api.nvim_buf_is_valid(state.floating.buf) then
			state.floating.buf = -1
		end

		-- Create window with custom dimensions if configured
		local width = config.width
		local height = config.height
		if type(width) == "number" and width < 1 then
			width = math.floor(vim.o.columns * width)
		end
		if type(height) == "number" and height < 1 then
			height = math.floor(vim.o.lines * height)
		end

		state.floating = create_floating_window({
			buf = state.floating.buf,
			width = width,
			height = height,
		})

		if vim.bo[state.floating.buf].buftype ~= "terminal" then
			-- Use the configured shell
			if config.shell then
				vim.cmd("terminal " .. config.shell)
			else
				vim.cmd.terminal()
			end
		end

		-- Set up keymaps
		vim.keymap.set(
			"n",
			"q",
			M.toggle_terminal,
			{ buffer = state.floating.buf, silent = true, desc = "Close Floaterminal" }
		)
		vim.keymap.set(
			"t",
			"<C-\\><C-\\>",
			M.toggle_terminal,
			{ buffer = state.floating.buf, silent = true, desc = "Toggle Floaterminal" }
		)

		-- Enter terminal mode automatically
		vim.cmd.startinsert()
	else
		-- Clean up keymaps
		pcall(vim.keymap.del, "n", "q", { buffer = state.floating.buf })
		pcall(vim.keymap.del, "t", "<C-\\><C-\\>", { buffer = state.floating.buf })
		vim.api.nvim_win_hide(state.floating.win)
	end
end

function M.setup(opts)
	opts = opts or {}
	config = vim.tbl_deep_extend("force", {
		shell = nil, -- Default to Neovim's default terminal
		width = 0.8, -- Fraction of columns (0-1) or absolute value (>1)
		height = 0.8, -- Fraction of lines (0-1) or absolute value (>1)
	}, opts)

	vim.keymap.set("t", "<C-x>", "<C-\\><C-N>", { desc = "terminal escape terminal mode" })
	vim.api.nvim_create_user_command("Floaterminal", M.toggle_terminal, {})
end

return M
