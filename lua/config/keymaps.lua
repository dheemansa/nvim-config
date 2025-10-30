-- Keymaps configuration
local keymap = vim.keymap.set

-- Change Keybinds To switch to normal mode
keymap("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- Prevent `x` from yanking deleted characters
keymap("n", "x", '"_x', { desc = "Delete char without copying" })

-- Prevent losing clipboard when pasting over selection
keymap("x", "p", '"_dP', { noremap = true, silent = true, desc = "Visual paste without yanking" })

-- Move current line down
keymap("n", "<leader>j", ":m .+1<CR>==", { desc = "Move current line down", silent = true })

-- Move current line up
keymap("n", "<leader>k", ":m .-2<CR>==", { desc = "Move current line up", silent = true })

keymap("n", "<tab>", ":bnext<CR>", { desc = "Next buffer", silent = true })
keymap("n", "<leader><tab>", ":bprev<CR>", { desc = "Previous buffer", silent = true })

keymap("n", "<leader>/", "gcc", { desc = "toggle comment" })
keymap("v", "<leader>/", "gc", { desc = "toggle comment" })

keymap(
	"n",
	"<leader>r",
	":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>",
	{ desc = "Replace word under cursor globally" }
)

keymap("n", "<leader>x", "<cmd>bd<cr>", { desc = "Close current buffer", noremap = true, silent = true })

-- Disable default 's' key (substitute) since it's redundant with 'cl'
-- s is now used by nvim-surround plugin
keymap("n", "s", "<Nop>")
keymap("n", "S", "<Nop>")

-- Keep visual selection when indenting
keymap("v", "<", "<gv", { desc = "Indent left and keep selection" })
keymap("v", ">", ">gv", { desc = "Indent right and keep selection" })

keymap("n", "grr", "<cmd>Telescope lsp_references<cr>", { desc = "Lsp references" })

keymap({ "n", "t" }, "<A-i>", "<cmd>Floaterminal<cr>", { desc = "Open/Close Floating  Terminal" })

-- Alpha dashboard
keymap("n", "<leader>a", "<cmd>Alpha<cr>", { desc = "Open dashboard" })

-- Yazi file manager
keymap("n", "<leader>e", "<cmd>Yazi<cr>", { desc = "Open Yazi file manager" })

vim.api.nvim_create_autocmd("FileType", {
	pattern = "TelescopePrompt",
	callback = function()
		keymap("n", "q", "<cmd>quit!<CR>", { buffer = true, silent = true, nowait = true })
	end,
	desc = "Close Telescope with 'q'",
})

-- Disable annoying q: keybind used for commmad history
vim.api.nvim_create_autocmd("CmdwinEnter", {
	callback = function()
		if vim.fn.getcmdwintype() == ":" then
			vim.cmd("quit")
		end
	end,
	desc = "Prevent command-line window from opening with q:",
})
