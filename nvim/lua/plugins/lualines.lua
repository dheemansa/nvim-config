return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    event = "VeryLazy",
    --lazy = false, -- Statusline should load early
    config = function()
        local colors = {
            black        = '#161616',  -- base00
            white        = '#ffffff',  -- base06
            red          = '#ee5396',  -- base10
            green        = '#1fad58',  -- base13
            blue         = '#3c72cf',  -- base09
            cyan         = '#3ddbd9',  -- base08
            text_blue    = '#a9b1d6',
            yellow       = '#be95ff',  -- base14
            purple       = '#ff7eb6',  -- base12
            orange       = '#82cfff',  -- base15
            gray         = '#525252',  -- base03 (blended)
            darkgray     = '#262626',  -- base01 (blended)
            lightgray    = '#393939',  -- base02 (blended)
            inactivegray = '#6f6f6f',  -- base04 (blended)
            none         = 'none',
        } -- colors inspired from oxocarbon colorscheme

        local custom_theme = {
            normal = {
                a = {bg = colors.blue, fg = colors.black, gui = 'bold'},
                b = {bg = colors.lightgray, fg = colors.blue},
                c = {bg = colors.none, fg = colors.text_blue}
            },
            insert = {
                a = {bg = colors.purple, fg = colors.black, gui = 'bold'},
                b = {bg = colors.lightgray, fg = colors.purple},
                c = {bg = colors.none, fg = colors.text_blue}
            },
            visual = {
                a = {bg = colors.yellow, fg = colors.black, gui = 'bold'},
                b = {bg = colors.lightgray, fg = colors.yellow},
                c = {bg = colors.none, fg = colors.text_blue}
            },
            replace = {
                a = {bg = colors.red, fg = colors.black, gui = 'bold'},
                b = {bg = colors.lightgray, fg = colors.red},
                c = {bg = colors.none, fg = colors.text_blue}
            },
            command = {
                a = {bg = colors.green, fg = colors.black, gui = 'bold'},
                b = {bg = colors.lightgray, fg = colors.green},
                c = {bg = colors.none, fg = colors.text_blue}
            },
            inactive = {
                a = {bg = colors.darkgray, fg = colors.inactivegray, gui = 'bold'},
                b = {bg = colors.darkgray, fg = colors.inactivegray},
                c = {bg = colors.none, fg = colors.inactivegray}
            }
        }

        require('lualine').setup {
            options = {
                icons_enabled = true,
                theme = custom_theme,
                component_separators = { left = '', right = ''},
                section_separators = { left = '', right = ''},
                --disabled_filetypes = {'alpha'}
            },
            sections = {
                lualine_x = {
                    {
                        function()
                            local clients = vim.lsp.get_clients({ bufnr = 0 })
                            if #clients == 0 then
                                --return 'LSP: inactive'
                                return ''
                            end
                            -- Cache client names to avoid repeated table operations
                            local client_names = {}
                            for _, client in ipairs(clients) do
                                table.insert(client_names, client.name)
                            end
                            return 'LSP: ' .. table.concat(client_names, ', ')
                        end,
                        color = function()
                            local clients = vim.lsp.get_clients({ bufnr = 0 })
                            return #clients > 0 and { fg = '#1fad58' } or { fg = '#f7768e' }
                        end,
                        update = { 'LspAttach', 'LspDetach', 'BufEnter' }, -- Only update when LSP status changes
                    },
                    'encoding',
                    'fileformat',
                    'filetype'
                }
            },
        }
    end,
}
