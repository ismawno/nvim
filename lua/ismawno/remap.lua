vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local utils = require('ismawno.utils')
utils.mapkey('n', '<leader>pv', vim.cmd.Ex, { desc = 'Open explorer' })
-- utils.mapkey('n', '<C-n>', 'n&', { noremap = true, silent = true, desc = 'Go to next occurrence and apply replace' })

utils.mapkey('n', '<C-b>', ":put=''<CR>", { silent = true, desc = 'Insert a blank line below the cursor' })
utils.mapkey('n', '<C-S-B>', ":put!=''<CR>", { silent = true, desc = 'Insert a blank line above the cursor' })

local function termcodes(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local operators = { 'c', 'd', 'y' }
local locations = { 'i', 'a' }
local openers = { '(', '{', '[', '<', "'", '"' }

for _, op in ipairs(operators) do
    for _, loc in ipairs(locations) do
        for _, opn in ipairs(openers) do
            utils.mapkey('n', termcodes(op .. 'm' .. loc .. opn), termcodes('/' .. opn .. '<CR>' .. op .. loc .. opn), {
                noremap = true,
                silent = true,
                desc = 'Apply vim command ' .. op .. loc .. opn .. ' to the next occurrence of ' .. opn,
            })
        end
    end
end

-- utils.mapkey('n', '<C-j>', ':m .+1<CR>==', { silent = true, desc = 'Move current line down' })
-- utils.mapkey('n', '<C-k>', ':m .-2<CR>==', { silent = true, desc = 'Move current line up' })
utils.mapkey('n', '<C-h>', '<C-w>h', { silent = true, desc = 'Move to left window' })
utils.mapkey('n', '<C-j>', '<C-w>j', { silent = true, desc = 'Move to bottom window' })
utils.mapkey('n', '<C-k>', '<C-w>k', { silent = true, desc = 'Move to top window' })
utils.mapkey('n', '<C-l>', '<C-w>l', { silent = true, desc = 'Move to right window' })

utils.mapkey('v', '<C-j>', ":m '>+1<CR>gv=gv", { silent = true, desc = 'Move current line down' })
utils.mapkey('v', '<C-k>', ":m '<-2<CR>gv=gv", { silent = true, desc = 'Move current line up' })

-- vim.keymap.set('n', '<C-h>', '<cmd>cnext<CR>zz')
-- vim.keymap.set('n', '<C-l>', '<cmd>cprev<CR>zz')
utils.mapkey('n', 'H', '<cmd>cnext<CR>zz')
utils.mapkey('n', 'L', '<cmd>cprev<CR>zz')

utils.mapkey('n', 'J', 'mzJ`z', { desc = 'Bring line below cursor to the end of the current line' })

utils.mapkey({ 'n', 'v' }, 'qj', '8j', { desc = 'Move cursor 8 lines down' })
utils.mapkey({ 'n', 'v' }, 'qk', '8k', { desc = 'Move cursor 8 lines up' })
utils.mapkey({ 'n', 'v', 'o' }, '¡', '$', { noremap = true, force = true, desc = 'Jump to the end of line' })

-- greatest remap ever
utils.mapkey('x', '<leader>p', [["_dP]])

-- next greatest remap ever : asbjornHaland
utils.mapkey({ 'n', 'v' }, '<leader>y', [["+y]])
utils.mapkey('n', '<leader>Y', [["+Y]])
utils.mapkey('n', '<leader>s', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

local terminal_stack = {}
utils.mapkey('n', '<leader>ot', function()
    vim.cmd('belowright 8split | terminal')
    local bufnr = vim.api.nvim_get_current_buf()
    table.insert(terminal_stack, bufnr)
end, { silent = true, desc = 'Open a new terminal' })

utils.mapkey('n', '<leader>ct', function()
    local bufnr = table.remove(terminal_stack)
    if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
        vim.api.nvim_buf_delete(bufnr, { force = true })
    end
end, { silent = true, desc = 'Open a new terminal' })

utils.mapkey('t', '<Esc>', '<C-\\><C-n>', { desc = 'Exit from terminal mode' })
