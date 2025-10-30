-- Enable truecolor support
vim.o.termguicolors = true

-- Disable mouse in insert mode
vim.opt.mouse:remove("i") -- Disable mouse in insert mode

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Hide end-of-buffer markers
vim.opt.fillchars:append({ eob = " " })

-- Scrolling
vim.opt.wrap = false -- Don't wrap lines
vim.opt.scrolloff = 10 -- Keep 10 lines above/below cursor
vim.opt.sidescrolloff = 8

-- Use System Copy-Paste Buffer
-- Schedule the setting after `UiEnter` because it can increase startup-time.
vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)
-- Indentation settings
vim.opt.tabstop = 4 -- Number of spaces a <Tab> counts for
vim.opt.shiftwidth = 4 -- Number of spaces used for each step of (auto)indent
vim.opt.softtabstop = 4 -- Number of spaces a Tab feels like while editing
vim.opt.expandtab = true -- Convert tabs to spaces vim.opt.smartindent = true -- Smart autoindenting on new lines
vim.opt.autoindent = true -- Copy indent from current line when starting a new line

-- File handling
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true

-- Search settings
vim.opt.ignorecase = true -- Ignore case in search patterns
vim.opt.smartcase = true -- Override ignorecase if search contains uppercase
vim.opt.hlsearch = true -- Highlight search results
vim.opt.incsearch = true -- Show search results as you type

-- UI improvements
vim.opt.showmode = false -- Don't show mode in command line (handled by lualine)
vim.opt.showcmd = false
vim.o.laststatus = 0 -- hides the statusline

vim.opt.cmdheight = 1 -- Height of command line
vim.opt.signcolumn = "yes" -- Always show sign column

-- Performance
vim.opt.updatetime = 250 -- Faster completion
vim.opt.timeoutlen = 300 -- Faster key sequence timeout

---- AUTOCMD

-- Highlight yanked text for a short time
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.hl.on_yank({
			higroup = "IncSearch", -- highlight group
			timeout = 200, -- time in ms
			on_visual = true, -- also highlight visually selected text
		})
	end,
})

-- Disable for plugin/dashboard UI buffers
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "lazy", "alpha", "TelescopePrompt", "NvimTree", "Todo*", "Mason*", "Terminal" },
	callback = function()
		vim.b.miniindentscope_disable = true
	end,
})
