return {
    'tpope/vim-fugitive',
    config = function()
        vim.keymap.set('n', '<leader>gs', vim.cmd.Git)

        local ismawno_fugitive = vim.api.nvim_create_augroup('ismawno_fugitive', {})

        local autocmd = vim.api.nvim_create_autocmd
        autocmd('BufWinEnter', {
            group = ismawno_fugitive,
            pattern = '*',
            callback = function()
                if vim.bo.ft ~= 'fugitive' then
                    return
                end

                local bufnr = vim.api.nvim_get_current_buf()
                local opts = { buffer = bufnr, remap = false }
                vim.keymap.set('n', '<leader>ga', ':G add .<CR>')
                vim.keymap.set('n', '<leader>gc', ':G commit<CR>')
                vim.keymap.set('n', '<leader>gp', ':G push<CR>')
                vim.keymap.set('n', '<leader>gP', ':G pull<CR>')

                -- NOTE: It allows me to easily set the branch i am pushing and any tracking
                -- needed if i did not set the branch up correctly
                --                vim.keymap.set("n", "<leader>t", ":Git push -u origin ", opts);
            end,
        })

        vim.keymap.set('n', 'gu', '<cmd>diffget //2<CR>')
        vim.keymap.set('n', 'gh', '<cmd>diffget //3<CR>')
    end,
}
