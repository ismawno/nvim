return {
    'mfussenegger/nvim-lint',
    config = function()
        local lint = require('lint')
        local root = require('ismawno.utils').find_root()
        lint.linters.clangtidy.args = {
            '-p',
            root .. 'build',
        }

        lint.linters_by_ft = { cpp = { 'clangtidy' }, hpp = { 'clangtidy' }, c = { 'clangtidy' }, h = { 'clangtidy' } }
        vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufReadPost' }, {
            callback = function()
                require('lint').try_lint()
            end,
        })
    end,
}
