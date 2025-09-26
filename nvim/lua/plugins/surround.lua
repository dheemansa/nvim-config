return{
{
    "kylechui/nvim-surround",
    version = "^3.0.0",
    event = "VeryLazy",
    config = function()
        -- Disable default 's' key (substitute) since it's redundant with 'cl'
        vim.keymap.set("n", "s", "<Nop>")
        vim.keymap.set("n", "S", "<Nop>")

        require("nvim-surround").setup({
            keymaps = {
                -- Insert mode
                insert = "<C-g>s",
                insert_line = "<C-g>S",

                -- Normal mode - now we can use 's' prefix cleanly
                normal = "s",             -- Just 's' - clean and simple
                normal_cur = "ss",        -- 'ss' for current line
                normal_line = "S",        -- 'S' for line-wise
                normal_cur_line = "SS",   -- 'SS' for current line (line-wise)

                -- Visual mode
                visual = "s",             -- 's' in visual mode
                visual_line = "S",        -- 'S' for line-wise

                -- Delete and change
                delete = "ds",            -- Keep 'd' prefix for delete
                change = "cs",            -- Keep 'c' prefix for change
                change_line = "cS",       -- Line-wise change
            },
        })
    end
}
}
