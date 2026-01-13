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
                    -- selection_modes = 'v',
                    include_surrounding_whitespace = function(queries)
                        if queries['query_string'] == '@parameter.inner' then
                            return false
                        end
                        return true
                    end,
                },
                move = {
                    enable = true,
                    set_jumps = true,
                },
            })
            -- Textobject selection
            local ts_select = require('nvim-treesitter-textobjects.select')

            vim.keymap.set({ 'x', 'o' }, 'af', function()
                ts_select.select_textobject('@function.outer', 'textobjects')
            end, { desc = 'Select outer function' })

            vim.keymap.set({ 'x', 'o' }, 'if', function()
                ts_select.select_textobject('@function.inner', 'textobjects')
            end, { desc = 'Select inner function' })

            vim.keymap.set({ 'x', 'o' }, 'ac', function()
                ts_select.select_textobject('@class.outer', 'textobjects')
            end, { desc = 'Select outer class' })

            vim.keymap.set({ 'x', 'o' }, 'ic', function()
                ts_select.select_textobject('@class.inner', 'textobjects')
            end, { desc = 'Select inner class' })

            vim.keymap.set({ 'x', 'o' }, 'as', function()
                ts_select.select_textobject('@scope.outer', 'textobjects')
            end, { desc = 'Select outer scope' })

            vim.keymap.set({ 'x', 'o' }, 'is', function()
                ts_select.select_textobject('@scope.inner', 'textobjects')
            end, { desc = 'Select inner scope' })

            vim.keymap.set({ 'x', 'o' }, 'ab', function()
                ts_select.select_textobject('@block.outer', 'textobjects')
            end, { desc = 'Select outer block' })

            vim.keymap.set({ 'x', 'o' }, 'ib', function()
                ts_select.select_textobject('@block.inner', 'textobjects')
            end, { desc = 'Select inner block' })

            vim.keymap.set({ 'x', 'o' }, 'aa', function()
                ts_select.select_textobject('@parameter.outer', 'textobjects')
            end, { desc = 'Select outer parameter' })

            vim.keymap.set({ 'x', 'o' }, 'ia', function()
                ts_select.select_textobject('@parameter.inner', 'textobjects')
            end, { desc = 'Select inner parameter' })

            vim.keymap.set({ 'x', 'o' }, 'ad', function()
                ts_select.select_textobject('@conditional.outer', 'textobjects')
            end, { desc = 'Select outer conditional' })

            vim.keymap.set({ 'x', 'o' }, 'id', function()
                ts_select.select_textobject('@conditional.inner', 'textobjects')
            end, { desc = 'Select inner conditional' })

            vim.keymap.set({ 'x', 'o' }, 'al', function()
                ts_select.select_textobject('@loop.outer', 'textobjects')
            end, { desc = 'Select outer loop' })

            vim.keymap.set({ 'x', 'o' }, 'il', function()
                ts_select.select_textobject('@loop.inner', 'textobjects')
            end, { desc = 'Select inner loop' })

            -- Swap
            local ts_swap = require('nvim-treesitter-textobjects.swap')

            vim.keymap.set('n', 'L', function()
                ts_swap.swap_next('@parameter.inner')
            end, { desc = 'Swap parameter forward' })

            vim.keymap.set('n', 'H', function()
                ts_swap.swap_previous('@parameter.inner')
            end, { desc = 'Swap parameter backward' })

            -- Move
            local ts_move = require('nvim-treesitter-textobjects.move')

            -- Goto next start
            vim.keymap.set({ 'n', 'x', 'o' }, '<leader>nf', function()
                ts_move.goto_next_start('@function.outer')
            end, { desc = 'Next function start' })

            vim.keymap.set({ 'n', 'x', 'o' }, '<leader>nc', function()
                ts_move.goto_next_start('@class.outer')
            end, { desc = 'Next class start' })

            vim.keymap.set({ 'n', 'x', 'o' }, '<leader>ns', function()
                ts_move.goto_next_start('@scope.outer')
            end, { desc = 'Next scope start' })

            vim.keymap.set({ 'n', 'x', 'o' }, '<leader>nb', function()
                ts_move.goto_next_start('@block.outer')
            end, { desc = 'Next block start' })

            vim.keymap.set({ 'n', 'x', 'o' }, '<leader>na', function()
                ts_move.goto_next_start('@parameter.outer')
            end, { desc = 'Next parameter start' })

            vim.keymap.set({ 'n', 'x', 'o' }, '<leader>nd', function()
                ts_move.goto_next_start('@conditional.outer')
            end, { desc = 'Next conditional start' })

            vim.keymap.set({ 'n', 'x', 'o' }, '<leader>nl', function()
                ts_move.goto_next_start('@loop.outer')
            end, { desc = 'Next loop start' })

            -- Goto next end
            vim.keymap.set({ 'n', 'x', 'o' }, '<leader>nF', function()
                ts_move.goto_next_end('@function.outer')
            end, { desc = 'Next function end' })

            vim.keymap.set({ 'n', 'x', 'o' }, '<leader>nC', function()
                ts_move.goto_next_end('@class.outer')
            end, { desc = 'Next class end' })

            vim.keymap.set({ 'n', 'x', 'o' }, '<leader>nS', function()
                ts_move.goto_next_end('@scope.outer')
            end, { desc = 'Next scope end' })

            vim.keymap.set({ 'n', 'x', 'o' }, '<leader>nB', function()
                ts_move.goto_next_end('@block.outer')
            end, { desc = 'Next block end' })

            vim.keymap.set({ 'n', 'x', 'o' }, '<leader>nA', function()
                ts_move.goto_next_end('@parameter.outer')
            end, { desc = 'Next parameter end' })

            vim.keymap.set({ 'n', 'x', 'o' }, '<leader>nD', function()
                ts_move.goto_next_end('@conditional.outer')
            end, { desc = 'Next conditional end' })

            vim.keymap.set({ 'n', 'x', 'o' }, '<leader>nL', function()
                ts_move.goto_next_end('@loop.outer')
            end, { desc = 'Next loop end' })

            -- Goto previous start
            vim.keymap.set({ 'n', 'x', 'o' }, '<leader>Nf', function()
                ts_move.goto_previous_start('@function.outer')
            end, { desc = 'Previous function start' })

            vim.keymap.set({ 'n', 'x', 'o' }, '<leader>Nc', function()
                ts_move.goto_previous_start('@class.outer')
            end, { desc = 'Previous class start' })

            vim.keymap.set({ 'n', 'x', 'o' }, '<leader>Ns', function()
                ts_move.goto_previous_start('@scope.outer')
            end, { desc = 'Previous scope start' })

            vim.keymap.set({ 'n', 'x', 'o' }, '<leader>Nb', function()
                ts_move.goto_previous_start('@block.outer')
            end, { desc = 'Previous block start' })

            vim.keymap.set({ 'n', 'x', 'o' }, '<leader>Na', function()
                ts_move.goto_previous_start('@parameter.outer')
            end, { desc = 'Previous parameter start' })

            vim.keymap.set({ 'n', 'x', 'o' }, '<leader>Nd', function()
                ts_move.goto_previous_start('@conditional.outer')
            end, { desc = 'Previous conditional start' })

            vim.keymap.set({ 'n', 'x', 'o' }, '<leader>Nl', function()
                ts_move.goto_previous_start('@loop.outer')
            end, { desc = 'Previous loop start' })

            -- Goto previous end
            vim.keymap.set({ 'n', 'x', 'o' }, '<leader>NF', function()
                ts_move.goto_previous_end('@function.outer')
            end, { desc = 'Previous function end' })

            vim.keymap.set({ 'n', 'x', 'o' }, '<leader>NC', function()
                ts_move.goto_previous_end('@class.outer')
            end, { desc = 'Previous class end' })

            vim.keymap.set({ 'n', 'x', 'o' }, '<leader>NS', function()
                ts_move.goto_previous_end('@scope.outer')
            end, { desc = 'Previous scope end' })

            vim.keymap.set({ 'n', 'x', 'o' }, '<leader>NB', function()
                ts_move.goto_previous_end('@block.outer')
            end, { desc = 'Previous block end' })

            vim.keymap.set({ 'n', 'x', 'o' }, '<leader>NA', function()
                ts_move.goto_previous_end('@parameter.outer')
            end, { desc = 'Previous parameter end' })

            vim.keymap.set({ 'n', 'x', 'o' }, '<leader>ND', function()
                ts_move.goto_previous_end('@conditional.outer')
            end, { desc = 'Previous conditional end' })

            vim.keymap.set({ 'n', 'x', 'o' }, '<leader>NL', function()
                ts_move.goto_previous_end('@loop.outer')
            end, { desc = 'Previous loop end' })
        end,
    },

    -- {
    --     'nvim-treesitter/nvim-treesitter-context',
    --     dependencies = { 'nvim-treesitter/nvim-treesitter' },
    --     branch = 'main',
    --     config = function()
    --         require 'treesitter-context'.setup {
    --             enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
    --             multiwindow = false, -- Enable multiwindow support.
    --             max_lines = 8, -- How many lines the window should span. Values <= 0 mean no limit.
    --             min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
    --             line_numbers = true,
    --             multiline_threshold = 20, -- Maximum number of lines to show for a single context
    --             trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
    --             mode = 'cursor', -- Line used to calculate context. Choices: 'cursor', 'topline'
    --             -- Separator between context and content. Should be a single character string, like '-'.
    --             -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
    --             separator = nil,
    --             zindex = 20, -- The Z-index of the context window
    --             on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
    --         }
    --     end,
    -- },
}
