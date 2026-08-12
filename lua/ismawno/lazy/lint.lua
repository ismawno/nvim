return {
    'mfussenegger/nvim-lint',
    config = function()
        require('lint').linters_by_ft = {
            cpp = { 'clangtidy' },
            hpp = { 'clangtidy' },
            c = { 'clangtidy' },
            h = { 'clangtidy' },
        }
        vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufReadPost' }, {
            callback = function()
                require('lint').try_lint()
            end,
        })
    end,
}
