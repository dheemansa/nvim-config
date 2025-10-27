-- colors.lua
local M = {}

function M.setup(opts)
	opts = opts or {}
	local transparent = opts.transparent or false

	-- load base colorscheme
	--vim.cmd.colorscheme("carbonfox")
	--vim.cmd.colorscheme("tokyonight")
	vim.cmd.colorscheme("oxocarbon")

	-- Apply REGULAR colors (always applied)
	vim.api.nvim_set_hl(0, "Cursor", { fg = "#adbcff" })

	-- Current line numbers
	vim.api.nvim_set_hl(0, "LineNr", { fg = "#e5c07b" })
	-- If using relative numbers
	vim.api.nvim_set_hl(0, "LineNrAbove", { fg = "#adbcff" })
	vim.api.nvim_set_hl(0, "LineNrBelow", { fg = "#adbcff" })

	vim.api.nvim_set_hl(0, "TodoHeadingHL", { fg = "#3c72cf", bold = true })
	vim.api.nvim_set_hl(0, "TodoStatHL", { fg = "#adbcff" })
	vim.api.nvim_set_hl(0, "TodoListHL", { fg = "#adbcff", italic = true })

	vim.api.nvim_set_hl(0, "MiniIndentscopeSymbol", { fg = "#e5c07b" })

	-- Apply TRANSPARENT colors (only if transparent = true)
	if transparent then
		-- Make main and floating windows transparent
		vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
		vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
		vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
		vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
		vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none" })
		vim.api.nvim_set_hl(0, "FloatTitle", { bg = "none" })
		vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
		vim.api.nvim_set_hl(0, "Pmenu", { bg = "none" })

		-- set transparency for BlinkCmp
		vim.api.nvim_set_hl(0, "BlinkCmpMenu", { bg = "none" })
		vim.api.nvim_set_hl(0, "BlinkCmpMenuBorder", { bg = "none" })

		-- set transparency for Statusline
		vim.api.nvim_set_hl(0, "StatusLine", { bg = "NONE" })
		vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "NONE" })
		vim.api.nvim_set_hl(0, "lualine_transparent", { bg = "NONE" })

		-- set transparency for Telescope
		vim.api.nvim_set_hl(0, "TelescopeBorder", { bg = "none" })
		vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "none" })
		vim.api.nvim_set_hl(0, "TelescopePromptTitle", { bg = "none" })
		vim.api.nvim_set_hl(0, "TelescopePromptBorder", { bg = "none" })
		vim.api.nvim_set_hl(0, "TelescopePromptNormal", { bg = "none" })
		vim.api.nvim_set_hl(0, "TelescopePromptPrefix", { bg = "none" })
		vim.api.nvim_set_hl(0, "TelescopeResultsTitle", { bg = "none" })
		--vim.api.nvim_set_hl(0, 'TelescopeSelection', { bg = 'none'})

		-- set transparency for noice
		vim.api.nvim_set_hl(0, "NoicePopupmenu", { bg = "none" })

		-- set transparency for notify
		vim.api.nvim_set_hl(0, "NotifyBackground", { bg = "#000000" })
		vim.api.nvim_set_hl(0, "NotifyDEBUGBody", { bg = "none" })
		vim.api.nvim_set_hl(0, "NotifyDEBUGBorder", { bg = "none" })
		vim.api.nvim_set_hl(0, "NotifyERRORBody", { bg = "none" })
		vim.api.nvim_set_hl(0, "NotifyERRORBorder", { bg = "none" })
		vim.api.nvim_set_hl(0, "NotifyINFOBody", { bg = "none" })
		vim.api.nvim_set_hl(0, "NotifyINFOBorder", { bg = "none" })
		vim.api.nvim_set_hl(0, "NotifyTRACEBody", { bg = "none" })
		vim.api.nvim_set_hl(0, "NotifyTRACEBorder", { bg = "none" })
		vim.api.nvim_set_hl(0, "NotifyWARNBody", { bg = "none" })
		vim.api.nvim_set_hl(0, "NotifyWARNBorder", { bg = "none" })

		vim.api.nvim_set_hl(0, "WhichKeyNormal", { bg = "none" })
	end
end

return M
