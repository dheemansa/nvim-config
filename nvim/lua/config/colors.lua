vim.cmd.colorscheme("tokyonight")
-- Make main and floating windows transparent
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none" })
vim.api.nvim_set_hl(0, "FloatTitle", { bg = "none" })
vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
-- Current line numbers
vim.api.nvim_set_hl(0, "LineNr", { fg = "#e0af68" })

-- If using relative numbers
vim.api.nvim_set_hl(0, "LineNrAbove", { fg = "#adbcff" })
vim.api.nvim_set_hl(0, "LineNrBelow", { fg = "#adbcff" })


vim.api.nvim_set_hl(0, "StatusLine",  { bg = "NONE" })
vim.api.nvim_set_hl(0, "StatusLineNC",{ bg = "NONE" })

vim.api.nvim_set_hl(0, 'TelescopeBorder', { bg = 'none' })
vim.api.nvim_set_hl(0, 'TelescopeNormal', { bg = 'none' })
vim.api.nvim_set_hl(0, 'TelescopePromptTitle', { bg = 'none'})
vim.api.nvim_set_hl(0, 'TelescopePromptBorder', { bg = 'none'})



vim.api.nvim_set_hl(0, "TodoHeadingHL", { fg = "#3c72cf",bold = true })
vim.api.nvim_set_hl(0, "TodoStatHL", { fg = "#adbcff" })
vim.api.nvim_set_hl(0, "TodoListHL", { fg = "#adbcff",italic = true })
