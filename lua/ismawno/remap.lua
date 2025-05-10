vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.keymap.set('n', '<leader>pv', vim.cmd.Ex)
vim.keymap.set('n', '<C-n>', 'n&', { noremap = true, silent = true })

vim.keymap.set('n', '<C-b>', ":put=''<CR>", { silent = true })
vim.keymap.set('n', '<C-S-B>', ":put!=''<CR>", { silent = true })

local function termcodes(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local operators = { 'c', 'd', 'y' }
local locations = { 'i', 'a' }
local openers = { '(', '{', '[' }

for _, op in ipairs(operators) do
    for _, loc in ipairs(locations) do
        for _, opn in ipairs(openers) do
            vim.keymap.set(
                'n',
                termcodes(op .. 'm' .. loc .. opn),
                termcodes('/' .. opn .. '<CR>c' .. loc .. opn),
                { noremap = true, silent = true }
            )
        end
    end
end

vim.keymap.set('n', '<C-j>', ':m .+1<CR>==', { silent = true })
vim.keymap.set('n', '<C-k>', ':m .-2<CR>==', { silent = true })

vim.keymap.set('v', '<C-j>', ":m '>+1<CR>gv=gv", { silent = true })
vim.keymap.set('v', '<C-k>', ":m '<-2<CR>gv=gv", { silent = true })
