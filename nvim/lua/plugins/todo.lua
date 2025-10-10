return{
    {
        dir = "~/.config/nvim/lua/todo",
        name = "todo",
        dependencies = { "nvim-lua/plenary.nvim" },

        opts = {
            auto_delete_completed_after_24h = true,
        },
        cmd = "Todo"
    }
}
