return {
    'tpope/vim-fugitive',
    init = function()
        vim.g.fugitive_no_maps = 1
    end,
    config = function()
        local utils = require('ismawno.utils')
        utils.mapkey('n', '<leader>gi', vim.cmd.Git)
        utils.mapkey('n', '<leader>ga', ':G add .<CR>', { desc = 'Execute git add .', force = true })
        utils.mapkey('n', '<leader>gc', ':G commit<CR>', { desc = 'Execute git commit', force = true })
        utils.mapkey('n', '<leader>gC', function()
            local cmd = vim.fn.input('Git command: ')
            if not cmd or cmd == '' then
                return
            end
            vim.cmd('G ' .. cmd)
        end, { desc = 'Execute a git command', force = true })
        utils.mapkey('n', '<leader>gp', ':G push<CR>', { desc = 'Execute git push', force = true })
        utils.mapkey('n', '<leader>gP', ':G pull --rebase<CR>', { desc = 'Execute git pull', force = true })
        utils.mapkey('n', '<leader>gt', ':G stash<CR>', { desc = 'Execute git stash', force = true })
        utils.mapkey('n', '<leader>gT', ':G stash pop<CR>', { desc = 'Execute git stash pop', force = true })
        utils.mapkey('n', '<leader>gS', function()
            local trm = utils.get_a_terminal()
            trm:send('git status')
        end, { desc = 'Execute git status', force = true })
        utils.mapkey('n', '<leader>gl', function()
            local trm = utils.get_a_terminal()
            trm:send('git log --oneline --decorate --graph')
        end, { desc = 'Execute git log', force = true })
    end,
}
