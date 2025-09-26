return{
    {
        dir = "~/.config/nvim/lua/todo",
        name = "todo",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require('todo').setup({
                auto_delete_completed_after_24h = true,
            })
        end,
        cmd = "Todo"
    }
}
