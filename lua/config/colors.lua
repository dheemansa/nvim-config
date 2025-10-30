-- colors.lua
local M = {}

function M.setup(opts)
	opts = opts or {}
	local transparent = opts.transparent or false
	local scheme = opts.colorscheme or "tokyonight"
	local fallback_scheme = "habamax"

	-- Helper function to preserve other parameters while setting bg to none
	local function set_transparent(group)
		local hl = vim.api.nvim_get_hl(0, { name = group }) or {}
		local new_hl = vim.deepcopy(hl)
		new_hl.bg = "none"
		vim.api.nvim_set_hl(0, group, new_hl)
	end

	-- load base colorscheme
	local status_ok, _ = pcall(vim.cmd.colorscheme, scheme)
	if not status_ok then
		vim.notify("Colorscheme " .. scheme .. " not found, falling back to " .. fallback_scheme, vim.log.levels.WARN)
		vim.cmd.colorscheme(fallback_scheme)
	end

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
		set_transparent("Normal")
		set_transparent("EndOfBuffer")
		set_transparent("NormalNC")
		set_transparent("NormalFloat")
		set_transparent("FloatBorder")
		set_transparent("FloatTitle")
		set_transparent("SignColumn")
		set_transparent("Pmenu")

		-- make virtual diagnostics background transparent
		set_transparent("DiagnosticVirtualTextHint")
		set_transparent("DiagnosticVirtualTextError")
		set_transparent("DiagnosticVirtualTextInfo")
		set_transparent("DiagnosticVirtualTextWarn")
		set_transparent("DiagnosticVirtualText")

		-- set transparency for BlinkCmp
		set_transparent("BlinkCmpMenu")
		set_transparent("BlinkCmpMenuBorder")
		set_transparent("BlinkCmpDocBorder")
		set_transparent("BlinkCmpDoc")
		set_transparent("BlinkCmpSignatureHelpBorder")

		-- set transparency for Statusline
		set_transparent("StatusLine")
		set_transparent("StatusLineNC")
		set_transparent("lualine_transparent")

		-- set transparency for Telescope
		set_transparent("TelescopeBorder")
		set_transparent("TelescopeNormal")
		set_transparent("TelescopePromptTitle")
		set_transparent("TelescopePromptBorder")
		set_transparent("TelescopePromptNormal")
		set_transparent("TelescopePromptPrefix")
		set_transparent("TelescopeResultsTitle")

		-- set transparency for noice
		set_transparent("NoicePopupmenu")
		set_transparent("NoiceVirtualText")

		-- set transparency for notify
		vim.api.nvim_set_hl(0, "NotifyBackground", { bg = "#000000" })
		set_transparent("NotifyDEBUGBody")
		set_transparent("NotifyDEBUGBorder")
		set_transparent("NotifyERRORBody")
		set_transparent("NotifyERRORBorder")
		set_transparent("NotifyINFOBody")
		set_transparent("NotifyINFOBorder")
		set_transparent("NotifyTRACEBody")
		set_transparent("NotifyTRACEBorder")
		set_transparent("NotifyWARNBody")
		set_transparent("NotifyWARNBorder")
		set_transparent("WhichKeyNormal")
	end
end

return M
