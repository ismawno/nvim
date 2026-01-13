return {
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        lazy = false,
        branch = 'main',
        config = function()
            require('nvim-treesitter').install {
                'c',
                'cpp',
                'bash',
                'python',
                'cmake',
                'lua',
                'vim',
                'vimdoc',
                'query',
                'markdown',
                'markdown_inline',
                'regex',
            }
        end,
    },

    {
        'nvim-treesitter/nvim-treesitter-textobjects',
        dependencies = { 'nvim-treesitter/nvim-treesitter' },
        branch = 'main',
        config = function()
            require('nvim-treesitter-textobjects').setup({
                select = {
                    lookahead = true,
                    keymaps = {
                        ['af'] = '@function.outer',
                        ['if'] = '@function.inner',
                        ['ac'] = '@class.outer',
                        ['ic'] = '@class.inner',
                        ['as'] = '@scope.outer',
                        ['is'] = '@scope.inner',
                        ['ab'] = '@block.outer',
                        ['ib'] = '@block.inner',
                        ['aa'] = '@parameter.outer',
                        ['ia'] = '@parameter.inner',
                        ['ad'] = '@conditional.outer',
                        ['id'] = '@conditional.inner',
                        ['al'] = '@loop.outer',
                        ['il'] = '@loop.inner',
                    },
                    -- selection_modes = 'v',
                    include_surrounding_whitespace = function(queries)
                        if queries['query_string'] == '@parameter.inner' then
                            return false
                        end
                        return true
                    end,
                },
                swap = {
                    swap_next = {
                        ['L'] = '@parameter.inner',
                    },
                    swap_previous = {
                        ['H'] = '@parameter.inner',
                    },
                },
                move = {
                    enable = true,
                    set_jumps = true,
                    goto_next_start = {
                        ['<leader>nf'] = '@function.outer',
                        ['<leader>nc'] = '@class.outer',
                        ['<leader>ns'] = '@scope.outer',
                        ['<leader>nb'] = '@block.outer',
                        ['<leader>na'] = '@parameter.outer',
                        ['<leader>nd'] = '@conditional.outer',
                        ['<leader>nl'] = '@loop.outer',
                    },
                    goto_next_end = {
                        ['<leader>nF'] = '@function.outer',
                        ['<leader>nC'] = '@class.outer',
                        ['<leader>nS'] = '@scope.outer',
                        ['<leader>nB'] = '@block.outer',
                        ['<leader>nA'] = '@parameter.outer',
                        ['<leader>nD'] = '@conditional.outer',
                        ['<leader>nL'] = '@loop.outer',
                    },
                    goto_previous_start = {
                        ['<leader>Nf'] = '@function.outer',
                        ['<leader>Nc'] = '@class.outer',
                        ['<leader>Ns'] = '@scope.outer',
                        ['<leader>Nb'] = '@block.outer',
                        ['<leader>Na'] = '@parameter.outer',
                        ['<leader>Nd'] = '@conditional.outer',
                        ['<leader>Nl'] = '@loop.outer',
                    },
                    goto_previous_end = {
                        ['<leader>NF'] = '@function.outer',
                        ['<leader>NC'] = '@class.outer',
                        ['<leader>NS'] = '@scope.outer',
                        ['<leader>NB'] = '@block.outer',
                        ['<leader>NA'] = '@parameter.outer',
                        ['<leader>ND'] = '@conditional.outer',
                        ['<leader>NL'] = '@loop.outer',
                    },
                },
            })
        end,
    },

    {
        'nvim-treesitter/nvim-treesitter-context',
        dependencies = { 'nvim-treesitter/nvim-treesitter' },
        branch = 'main',
        config = function()
            require 'treesitter-context'.setup {
                enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
                multiwindow = false, -- Enable multiwindow support.
                max_lines = 8, -- How many lines the window should span. Values <= 0 mean no limit.
                min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
                line_numbers = true,
                multiline_threshold = 20, -- Maximum number of lines to show for a single context
                trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
                mode = 'cursor', -- Line used to calculate context. Choices: 'cursor', 'topline'
                -- Separator between context and content. Should be a single character string, like '-'.
                -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
                separator = nil,
                zindex = 20, -- The Z-index of the context window
                on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
            }
        end,
    },
}
