require("config.options")
require("config.lazy")
require("config.keymaps")

require("config.colors").setup({ transparent = true, colorscheme = "catppuccin-mocha" })

if vim.g.neovide then
	vim.g.neovide_opacity = 1
	vim.g.neovide_normal_opacity = 0.6
end
