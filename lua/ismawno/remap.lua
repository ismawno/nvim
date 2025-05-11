vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local utils = require('ismawno.utils')
utils.mapkey('n', '<leader>pv', vim.cmd.Ex, { desc = 'Open explorer' })
utils.mapkey('n', '<C-n>', 'n&', { noremap = true, silent = true, desc = 'Go to next occurrence and apply replace' })

utils.mapkey('n', '<C-b>', ":put=''<CR>", { silent = true, desc = 'Insert a blank line below the cursor' })
utils.mapkey('n', '<C-S-B>', ":put!=''<CR>", { silent = true, desc = 'Insert a blank line above the cursor' })

local function termcodes(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local operators = { 'c', 'd', 'y' }
local locations = { 'i', 'a' }
local openers = { '(', '{', '[', '<' }

for _, op in ipairs(operators) do
    for _, loc in ipairs(locations) do
        for _, opn in ipairs(openers) do
            utils.mapkey('n', termcodes(op .. 'm' .. loc .. opn), termcodes('/' .. opn .. '<CR>' .. op .. loc .. opn), {
                noremap = true,
                silent = true,
                desc = 'Apply vim command ' .. op .. loc .. opn .. 'to the next occurrence of ' .. opn,
            })
        end
    end
end

utils.mapkey('n', '<C-j>', ':m .+1<CR>==', { silent = true })
utils.mapkey('n', '<C-k>', ':m .-2<CR>==', { silent = true })

utils.mapkey('v', '<C-j>', ":m '>+1<CR>gv=gv", { silent = true })
utils.mapkey('v', '<C-k>', ":m '<-2<CR>gv=gv", { silent = true })
