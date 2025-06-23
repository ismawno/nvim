return {
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
    },

    {
        'nvim-treesitter/nvim-treesitter-textobjects',
        dependencies = { 'nvim-treesitter/nvim-treesitter' },
        config = function()
            require('nvim-treesitter.configs').setup({
                -- A list of parser names, or "all"
                ensure_installed = {
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
                },
                modules = {}, -- no extra modules to initialize
                ignore_install = {},
                -- Install parsers synchronously (only applied to `ensure_installed`)
                sync_install = false,

                -- Automatically install missing parsers when entering buffer
                -- Recommendation: set to false if you don"t have `tree-sitter` CLI installed locally
                auto_install = false,

                indent = {
                    enable = true,
                },

                highlight = {
                    -- `false` will disable the whole extension
                    enable = true,
                    disable = function(lang, buf)
                        if lang == 'html' then
                            vim.notify('Treesitter disabled')
                            return true
                        end

                        local max_filesize = 100 * 1024 -- 100 KB
                        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                        if ok and stats and stats.size > max_filesize then
                            vim.notify(
                                'File larger than 100KB treesitter disabled for performance',
                                vim.log.levels.WARN,
                                { title = 'Treesitter' }
                            )
                            return true
                        end
                    end,

                    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
                    -- Set this to `true` if you depend on "syntax" being enabled (like for indentation).
                    -- Using this option may slow down your editor, and you may see some duplicate highlights.
                    -- Instead of true it can also be a list of languages
                    additional_vim_regex_highlighting = { 'markdown' },
                },
                textobjects = {
                    select = {
                        enable = true,
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
                        enable = true,
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
                },
            })
        end,
    },

    {
        'nvim-treesitter/nvim-treesitter-context',
        dependencies = { 'nvim-treesitter/nvim-treesitter' },
        config = function()
            require 'treesitter-context'.setup {
                enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
                multiwindow = false, -- Enable multiwindow support.
                max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
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
