-- Keymaps configuration
local keymap = vim.keymap.set

-- Change Keybinds To switch to normal mode
keymap("i", "jk", "<Esc>", { desc = "Exit insert mode" })
--keymap("i", "jj", "<Esc>", { desc = "Exit insert mode" })

-- Prevent `x` from yanking deleted characters
keymap("n", "x", '"_x', { desc = "Delete char without copying" })

-- Prevent losing clipboard when pasting over selection
keymap("x", "p", '"_dP', { noremap = true, silent = true, desc = "Visual paste without yanking" })

-- Move current line down
keymap("n", "<leader>j", ":m .+1<CR>==", { desc = "Move current line down", silent = true })

-- Move current line up
keymap("n", "<leader>k", ":m .-2<CR>==", { desc = "Move current line up", silent = true })

keymap("n", "<leader><tab>", ":bnext<CR>", { desc = "Next buffer", silent = true })

keymap(
	"n",
	"<leader>r",
	":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>",
	{ desc = "Replace word under cursor globally" }
)

-- Disable default 's' key (substitute) since it's redundant with 'cl'
-- s is now used by nvim-surround plugin
keymap("n", "s", "<Nop>")
keymap("n", "S", "<Nop>")

-- Keep visual selection when indenting
keymap("v", "<", "<gv", { desc = "Indent left and keep selection" })
keymap("v", ">", ">gv", { desc = "Indent right and keep selection" })

-- Make current file executable
keymap("n", "<leader>x", function()
	vim.cmd("!chmod +x %")
	print("Made " .. vim.fn.expand("%") .. " executable")
end, { desc = "Make current file executable" })

-- Telescope keymaps
--local builtin = require('telescope.builtin')
--keymap('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
--keymap('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
--keymap('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
--keymap('n', '<leader>fd', builtin.diagnostics, { desc = 'Telescope LSP diagnostics' })

keymap("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Telescope find files" })
keymap("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Telescope live grep" })
keymap("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Telescope buffers" })
keymap("n", "<leader>fd", "<cmd>Telescope diagnostics<cr>", { desc = "Telescope LSP diagnostics" })

keymap("n", "<Leader>ll", require("lsp_lines").toggle, { desc = "Toggle lsp_lines" })

-- Alpha dashboard
keymap("n", "<leader>a", "<cmd>Alpha<cr>", { desc = "Open dashboard" })

-- Yazi file manager
keymap("n", "<leader>e", "<cmd>Yazi<cr>", { desc = "Open Yazi file manager" })

-- Disable annoying q: keybind used for commmad history
vim.api.nvim_create_autocmd("CmdwinEnter", {
	callback = function()
		if vim.fn.getcmdwintype() == ":" then
			vim.cmd("quit")
		end
	end,
	desc = "Prevent command-line window from opening with q:",
})
