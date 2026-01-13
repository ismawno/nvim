return {
    'nvim-telescope/telescope.nvim',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-treesitter/nvim-treesitter',
        'echasnovski/mini.icons',
    },

    config = function()
        local actions = require('telescope.actions')
        require('telescope').setup({
            defaults = {
                mappings = {
                    n = {
                        ['<leader>q'] = actions.send_selected_to_qflist,
                    },
                },
            },
        })
        local builtin = require('telescope.builtin')

        local function find_files()
            builtin.find_files({
                hidden = true,
                no_ignore = true,
                file_ignore_patterns = {
                    '%.git/',
                    '%.venv/',
                    '%.cache/',
                    'build/',
                },
            })
        end

        local function git_files()
            builtin.git_files({ hidden = true, file_ignore_patterns = { '%.git/' } })
        end

        local function grep_files(word)
            builtin.grep_string({
                search = word,
                hidden = true,
                no_ignore = true,
                file_ignore_patterns = {
                    '%.git/',
                    '%.venv/',
                    '%.cache/',
                    'build/',
                },
            })
        end

        local function grep_git_files(word)
            builtin.grep_string({
                search = word,
                hidden = true,
                search_dirs = vim.fn.systemlist('git ls-files'),
                file_ignore_patterns = {
                    '%.git/',
                },
            })
        end

        local function live_grep()
            builtin.live_grep({
                hidden = true,
                no_ignore = true,
                file_ignore_patterns = {
                    '%.git/',
                    '%.venv/',
                    '%.cache/',
                    'build/',
                },
            })
        end

        local function git_live_grep()
            builtin.live_grep({
                hidden = true,
                search_dirs = vim.fn.systemlist('git ls-files'),
                file_ignore_patterns = {
                    '%.git/',
                },
            })
        end
        vim.keymap.set('n', '<leader>pf', find_files, { desc = 'Find through all project' })
        vim.keymap.set('n', '<leader>gf', git_files, { desc = 'Find through all git tracked files' })

        vim.keymap.set('n', '<leader>pw', function()
            local word = vim.fn.expand('<cword>')
            grep_files(word)
        end, { desc = 'Search the current word through all files' })

        vim.keymap.set('n', '<leader>gw', function()
            local word = vim.fn.expand('<cword>')
            grep_git_files(word)
        end, { desc = 'Search the current word through all git tracked files' })

        vim.keymap.set('n', '<leader>pW', function()
            local word = vim.fn.expand('<cWORD>')
            grep_files(word)
        end, { desc = 'Search the current expression through all files' })

        vim.keymap.set('n', '<leader>gW', function()
            local word = vim.fn.expand('<cWORD>')
            grep_git_files(word)
        end, { desc = 'Search the current expression through all git tracked files' })

        vim.keymap.set('n', '<leader>pg', function()
            grep_files(vim.fn.input('Grep > '))
        end, { desc = 'Search through all files' })

        vim.keymap.set('n', '<leader>gg', function()
            grep_git_files(vim.fn.input('Grep > '))
        end, { desc = 'Search through all git tracked files' })

        vim.keymap.set('n', '<leader>ps', live_grep)
        vim.keymap.set('n', '<leader>gs', git_live_grep)
        -- vim.keymap.set('n', '<leader>vh', builtin.help_tags, { desc = '' })
    end,
}
