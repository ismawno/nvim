require('ismawno.remap')
require('ismawno.lazy_init')

local augroup = vim.api.nvim_create_augroup
local ismawno_group = augroup('Ismawno', {})

local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup('HighlightYank', {})

function R(name)
    require('plenary.reload').reload_module(name)
end

autocmd('TextYankPost', {
    group = yank_group,
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({
            higroup = 'IncSearch',
            timeout = 40,
        })
    end,
})

autocmd('BufWritePre', {
    group = ismawno_group,
    pattern = '*',
    command = [[%s/\s\+$//e]],
})

autocmd('BufWritePre', {
    pattern = { '*.py', '*.c', '*.cpp', '*.h', '*.sh', '*.lua' },
    callback = function()
        require('conform').format({ async = false })
    end,
})

autocmd('LspAttach', {
    group = ismawno_group,
    callback = function(e)
        local buf = e.buf
        local opts = { buffer = buf, silent = true }

        -- a table of { mode, lhs, rhs } mappings
        local maps = {
            { 'n', 'gd', vim.lsp.buf.definition },
            { 'n', 'K', vim.lsp.buf.hover },
            { 'n', '<leader>vws', vim.lsp.buf.workspace_symbol },
            { 'n', '<leader>vd', vim.diagnostic.open_float },
            { 'n', '<leader>vca', vim.lsp.buf.code_action },
            { 'n', '<leader>vrr', vim.lsp.buf.references },
            { 'n', '<leader>vrn', vim.lsp.buf.rename },
            { 'i', '<C-h>', vim.lsp.buf.signature_help },
            { 'n', '[d', vim.diagnostic.goto_prev },
            { 'n', ']d', vim.diagnostic.goto_next },
        }

        for _, m in ipairs(maps) do
            vim.keymap.set(m[1], m[2], m[3], opts)
        end
    end,
})

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25
