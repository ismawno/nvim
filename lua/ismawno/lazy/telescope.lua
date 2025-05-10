return {
    'nvim-telescope/telescope.nvim',

    tag = '0.1.5',

    dependencies = {
        'nvim-lua/plenary.nvim',
    },

    config = function()
        require('telescope').setup({})
        local function grep_git_files(word)
            require('telescope.builtin').grep_string({
                search = word,
                search_dirs = vim.fn.systemlist('git ls-files'),
            })
        end

        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
        vim.keymap.set('n', '<leader>gf', builtin.git_files, {})

        vim.keymap.set('n', '<leader>pw', function()
            local word = vim.fn.expand('<cword>')
            builtin.grep_string({ search = word })
        end)
        vim.keymap.set('n', '<leader>gw', function()
            local word = vim.fn.expand('<cword>')
            grep_git_files(word)
        end)

        vim.keymap.set('n', '<leader>pW', function()
            local word = vim.fn.expand('<cWORD>')
            builtin.grep_string({ search = word })
        end)
        vim.keymap.set('n', '<leader>gW', function()
            local word = vim.fn.expand('<cWORD>')
            grep_git_files(word)
        end)

        vim.keymap.set('n', '<leader>pg', function()
            builtin.grep_string({ search = vim.fn.input('Grep > ') })
        end)
        vim.keymap.set('n', '<leader>gg', function()
            grep_git_files(vim.fn.input('Grep > '))
        end)

        vim.keymap.set('n', '<leader>ps', function()
            builtin.grep_string({ search = '' })
        end)
        vim.keymap.set('n', '<leader>gfs', function()
            grep_git_files('')
        end)

        vim.keymap.set('n', '<leader>vh', builtin.help_tags, {})
    end,
}
