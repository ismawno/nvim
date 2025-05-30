return {
    'tpope/vim-fugitive',
    init = function()
        vim.g.fugitive_no_maps = 1
    end,
    config = function()
        local utils = require('ismawno.utils')
        utils.mapkey('n', '<leader>gi', vim.cmd.Git)

        local ismawno_fugitive = vim.api.nvim_create_augroup('ismawno_fugitive', {})

        local autocmd = vim.api.nvim_create_autocmd
        autocmd('BufWinEnter', {
            group = ismawno_fugitive,
            pattern = '*',
            callback = function()
                if vim.bo.ft ~= 'fugitive' then
                    return
                end

                utils.mapkey('n', '<leader>ga', ':G add .<CR>', { desc = 'Execute git add .', force = true })
                utils.mapkey('n', '<leader>gc', ':G commit<CR>', { desc = 'Execute git commit', force = true })
                utils.mapkey('n', '<leader>gp', ':G push<CR>', { desc = 'Execute git push', force = true })
                utils.mapkey('n', '<leader>gP', ':G pull<CR>', { desc = 'Execute git pull', force = true })
                utils.mapkey('n', '<leader>gt', ':G stash<CR>', { desc = 'Execute git stash', force = true })
                utils.mapkey('n', '<leader>gT', ':G stash pop<CR>', { desc = 'Execute git stash pop', force = true })

                -- local bufnr = vim.api.nvim_get_current_buf()
                -- local opts = { buffer = bufnr, remap = false }
                -- NOTE: It allows me to easily set the branch i am pushing and any tracking
                -- needed if i did not set the branch up correctly
                --                utils.mapkey("n", "<leader>t", ":Git push -u origin ", opts);
            end,
        })

        -- utils.mapkey('n', 'gu', '<cmd>diffget //2<CR>')
        -- utils.mapkey('n', 'gh', '<cmd>diffget //3<CR>')
    end,
}
