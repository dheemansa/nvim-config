-- Keymaps configuration

local keymap = vim.keymap.set

-- Change Keybinds To switch to normal mode
keymap("i", "jk", "<Esc>", { desc = "Exit insert mode" })
keymap("i", "jj", "<Esc>", { desc = "Exit insert mode" })

-- Prevent `x` from yanking deleted characters
keymap("n", "x", '"_x', { desc = "Delete char without copying" })

-- Replace word under cursor globally
keymap("n", "<leader>r", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>", { desc = "Replace word under cursor globally" })

-- Make current file executable
keymap( "n", "<leader>x",
  function()
    vim.cmd("!chmod +x %")
    print("Made " .. vim.fn.expand("%") .. " executable")
  end,
  { desc = "Make current file executable" }
)

-- Telescope keymaps
local builtin = require('telescope.builtin')
keymap('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
keymap('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
keymap('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
keymap('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

keymap( "n", "<Leader>ll", require("lsp_lines").toggle, { desc = "Toggle lsp_lines" })

-- Alpha dashboard
keymap("n", "<leader>a", "<cmd>Alpha<cr>", { desc = "Open dashboard" })

keymap("n", "<leader>e", "<cmd>Yazi<cr>", { desc = "Open Yazi file manager" })
