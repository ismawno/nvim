return {
    'tpope/vim-fugitive',
    init = function()
        vim.g.fugitive_no_maps = 1
    end,
    config = function()
        local utils = require('ismawno.utils')
        vim.keymap.set('n', '<leader>gi', vim.cmd.Git)
        vim.keymap.set('n', '<leader>ga', ':G add .<CR>', { desc = 'Execute git add .' })
        vim.keymap.set('n', '<leader>gc', ':G commit<CR>', { desc = 'Execute git commit' })
        vim.keymap.set('n', '<leader>gC', function()
            local cmd = vim.fn.input('Git command: ')
            if not cmd or cmd == '' then
                return
            end
            vim.cmd('G ' .. cmd)
        end, { desc = 'Execute a git command' })
        vim.keymap.set('n', '<leader>gp', ':G push<CR>', { desc = 'Execute git push' })
        vim.keymap.set('n', '<leader>gP', ':G pull --rebase<CR>', { desc = 'Execute git pull' })
        vim.keymap.set('n', '<leader>gt', ':G stash<CR>', { desc = 'Execute git stash' })
        vim.keymap.set('n', '<leader>gT', ':G stash pop<CR>', { desc = 'Execute git stash pop' })
        vim.keymap.set('n', '<leader>gS', function()
            local trm = utils.get_a_terminal()
            trm:send('git status')
        end, { desc = 'Execute git status' })
        vim.keymap.set('n', '<leader>gl', function()
            local trm = utils.get_a_terminal()
            trm:send('git log --oneline --decorate --graph')
        end, { desc = 'Execute git log' })
    end,
}
