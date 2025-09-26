return {
  {"nvim-treesitter/nvim-treesitter",
  branch = 'master',
  lazy = false,
  build = ":TSUpdate",
  config = function ()
      local configs = require("nvim-treesitter.configs")

      configs.setup({
          ensure_installed = {
              "lua",
              "vim",
              "vimdoc",
              "python",
              "javascript",
              "html",
              "css",
              "json",
              "markdown",
              "bash"
          },
          sync_install = false,
          auto_install = true, -- Automatically install parsers for new filetypes
          highlight = {
              enable = true,
              additional_vim_regex_highlighting = false,
          },
          indent = { enable = true },
        })
  end
  }
}
