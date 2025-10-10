return{
    {
        "kylechui/nvim-surround",
        version = "^3.0.0",
        event = "VeryLazy",
        opts = {
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
        }
    }
}
