vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local utils = require('ismawno.utils')
utils.mapkey('n', '<leader>pv', function()
    vim.cmd('Oil')
end, { desc = 'Open explorer' })
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
utils.mapkey('n', 'H', '<cmd>cprev<CR>zz', { desc = 'Go to previous quickfix element' })
utils.mapkey('n', 'L', '<cmd>cnext<CR>zz', { desc = 'Go to next quickfix element' })
utils.mapkey(
    'n',
    '<leader>r',
    [[:cdo %s///ge | update<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left>]],
    { desc = 'Insert a global search and replace pattern' }
)

utils.mapkey('n', 'J', 'mzJ`z', { desc = 'Bring line below cursor to the end of the current line' })

utils.mapkey({ 'n', 'v' }, 'qj', '8j', { desc = 'Move cursor 8 lines down' })
utils.mapkey({ 'n', 'v' }, 'qk', '8k', { desc = 'Move cursor 8 lines up' })
utils.mapkey({ 'n', 'v', 'o' }, '¡', '$', { noremap = true, force = true, desc = 'Jump to the end of line' })

utils.mapkey('n', '<leader>pr', function()
    local root = utils.find_root()
    vim.cmd('Oil ' .. root)
end, { desc = 'Navigate to root' })

-- greatest remap ever
utils.mapkey('x', '<leader>p', [["_dP]], { desc = 'Paste selection without copying it' })

-- next greatest remap ever : asbjornHaland
utils.mapkey({ 'n', 'v' }, '<leader>y', [["+y]], { desc = 'Copy to system clipboard' })
utils.mapkey('n', '<leader>Y', [["+Y]], { desc = 'Copy line to system clipboard' })
utils.mapkey(
    'n',
    '<leader>s',
    [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
    { desc = 'Create a replace template for the current word' }
)

-- local terminal_stack = {}
-- utils.mapkey('n', '<leader>ot', function()
--     vim.cmd('belowright 8split | terminal')
--     local bufnr = vim.api.nvim_get_current_buf()
--     table.insert(terminal_stack, bufnr)
-- end, { silent = true, desc = 'Open a new terminal' })
--
-- utils.mapkey('n', '<leader>ct', function()
--     local bufnr = table.remove(terminal_stack)
--     if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
--         vim.api.nvim_buf_delete(bufnr, { force = true })
--     end
-- end, { silent = true, desc = 'Open a new terminal' })

utils.mapkey('n', '<leader>ot', function()
    utils.open_terminal({ direction = 'horizontal' }):toggle()
end)
utils.mapkey('n', '<leader>oT', function()
    utils
        .open_terminal({
            direction = 'float',
            float_opts = {
                width = math.floor(vim.o.columns * 0.8),
                height = math.floor(vim.o.lines * 0.8),
                border = 'rounded',
            },
        })
        :toggle()
end, { desc = 'Open a new terminal at the bottom' })

utils.mapkey('t', '<Esc>', '<C-\\><C-n>', { desc = 'Exit from terminal mode' })
