vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local utils = require('ismawno.utils')

utils.mapkey('n', '<leader>pv', function()
    vim.cmd('Oil')
end, { desc = 'Open explorer' })

utils.mapkey('n', '<C-b>', ":put=''<CR>", { silent = true, desc = 'Insert a blank line below the cursor' })
utils.mapkey('n', '<C-h>', '<C-w>h', { silent = true, desc = 'Move to left window' })
utils.mapkey('n', '<C-j>', '<C-w>j', { silent = true, desc = 'Move to bottom window' })
utils.mapkey('n', '<C-k>', '<C-w>k', { silent = true, desc = 'Move to top window' })
utils.mapkey('n', '<C-l>', '<C-w>l', { silent = true, desc = 'Move to right window' })

utils.mapkey('t', '<Esc>', '<C-\\><C-n>', { desc = 'Exit from terminal mode' })
utils.mapkey('n', '<C-s>', '<C-a>', { noremap = true, desc = 'Increase number' })

utils.mapkey('v', '<C-j>', ":m '>+1<CR>gv=gv", { silent = true, desc = 'Move current line down' })
utils.mapkey('v', '<C-k>', ":m '<-2<CR>gv=gv", { silent = true, desc = 'Move current line up' })

utils.mapkey('n', '<leader>sw', '<C-w><C-s>', { noremap = true, desc = 'Split current buffer' })
utils.mapkey('n', 'H', '<cmd>cprev<CR>zz', { desc = 'Go to previous quickfix element' })
utils.mapkey('n', 'L', '<cmd>cnext<CR>zz', { desc = 'Go to next quickfix element' })
utils.mapkey(
    'n',
    '<leader>R',
    [[:cdo %s///ge | update<Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left><Left>]],
    { desc = 'Insert a global search and replace pattern' }
)

utils.mapkey({ 'n', 'v' }, 'J', '8j', { desc = 'Move cursor 8 lines down' })
utils.mapkey({ 'n', 'v' }, 'K', '8k', { desc = 'Move cursor 8 lines up' })
utils.mapkey({ 'n', 'v', 'o' }, '¡', '$', { noremap = true, force = true, desc = 'Jump to the end of line' })
utils.mapkey({ 'n', 'v', 'o' }, '¿', '0', { noremap = true, force = true, desc = 'Jump to the start of line' })

utils.mapkey({ 'n', 'v', 'o' }, '0', '^', { noremap = true, desc = 'Go to the first character of the line' })

utils.mapkey({ 'n', 'v', 'o' }, 'M', utils.navigate_delimiter, { noremap = true })

-- utils.mapkey({ 'n', 'v', 'o' }, 'M', '%', { noremap = true, desc = 'Go to matching opener/closer' })

utils.mapkey('n', '<leader>pr', function()
    local root = utils.find_root()
    vim.cmd('Oil ' .. root)
end, { desc = 'Navigate to root' })

utils.mapkey('x', '<leader>p', [["_dP]], { desc = 'Paste selection without copying it' })
utils.mapkey({ 'n', 'v' }, '<leader>y', [["+y]], { desc = 'Copy to system clipboard' })
utils.mapkey('n', '<leader>Y', [["+Y]], { desc = 'Copy line to system clipboard' })
utils.mapkey(
    'n',
    '<leader>r',
    [[:%s/<C-r><C-w>/<C-r><C-w>/gI<Left><Left><Left>]],
    { desc = 'Create a replace template for the current word' }
)
utils.mapkey('n', '<leader>w', [[/<C-r><C-w>]], { desc = 'Create a find template for the current word' })
utils.mapkey('n', '<leader>W', [[?<C-r><C-w>]], { desc = 'Create a find template for the current word' })
-- utils.mapkey('n', '<leader>up', 'i<C-r>"<Esc>', { desc = 'Copy into the line, even if its a whole line' })
utils.mapkey('i', '<C-u>', '<C-r>"', { noremap = true, desc = 'Copy into the line, even if its a whole line' })

utils.mapkey('n', '<leader>ot', utils.open_horizontal_terminal, { desc = 'Open a terminal (bottom horizontal)' })
utils.mapkey('n', '<leader>oT', utils.open_float_terminal, { desc = 'Open a terminal (float)' })

utils.mapkey('n', '<leader>fn', function()
    utils.navigate_file('next')
end, { desc = 'Go to next file in explorer' })

utils.mapkey('n', '<leader>fp', function()
    utils.navigate_file('prev')
end, { desc = 'Go to prev file in explorer' })

utils.foreach_operator(function(op)
    utils.foreach_location(function(loc)
        local lhs = utils.termcodes(op .. loc .. 'x')
        utils.mapkey('n', lhs, function()
            utils.operate_any_delimiter(op, loc, 'center')
        end, { silent = true, desc = 'Apply ' .. op .. ' with location ' .. loc .. ' to any delimiter' })

        lhs = utils.termcodes(op .. 'm' .. loc .. 'x')
        utils.mapkey('n', lhs, function()
            utils.operate_any_delimiter(op, loc, 'forwards')
        end, {
            silent = true,
            desc = 'Apply ' .. op .. ' with location ' .. loc .. ' to the next (any) delimiter',
        })

        lhs = utils.termcodes(op .. 'M' .. loc .. 'x')
        utils.mapkey('n', lhs, function()
            utils.operate_any_delimiter(op, loc, 'backwards')
        end, {
            silent = true,
            desc = 'Apply ' .. op .. ' with location ' .. loc .. ' to the previous (any) delimiter',
        })

        utils.foreach_opener(function(opn)
            lhs = utils.termcodes(op .. 'm' .. loc .. opn)
            local rhs = utils.termcodes('/' .. opn .. '<CR>' .. op .. loc .. opn)
            utils.mapkey('n', lhs, rhs, {
                noremap = true,
                silent = true,
                desc = 'Apply vim command ' .. op .. loc .. opn .. ' to the next occurrence of ' .. opn,
            })
        end)
    end)
end)

utils.foreach_location(function(loc)
    local lhs = '<leader>p' .. loc
    utils.mapkey('n', lhs, function()
        utils.insert_parameter(loc, 'center')
    end)
    lhs = '<leader>pm' .. loc
    utils.mapkey('n', lhs, function()
        utils.insert_parameter(loc, 'forwards')
    end)
    lhs = '<leader>pM' .. loc
    utils.mapkey('n', lhs, function()
        utils.insert_parameter(loc, 'backwards')
    end)
    utils.foreach_opener(function(opn)
        lhs = '<leader>p' .. opn .. loc
        utils.mapkey('n', lhs, function()
            utils.insert_parameter(loc, 'center', opn)
        end)
        lhs = '<leader>pm' .. opn .. loc
        utils.mapkey('n', lhs, function()
            utils.insert_parameter(loc, 'forwards', opn)
        end)
        lhs = '<leader>pM' .. opn .. loc
        utils.mapkey('n', lhs, function()
            utils.insert_parameter(loc, 'backwards', opn)
        end)
    end)
end, true)

utils.mapkey('n', '<leader>pbde', function()
    utils.setup_cmake('Debug')
end)
utils.mapkey('n', '<leader>pbre', function()
    utils.setup_cmake('Release')
end)
utils.mapkey('n', '<leader>pbdi', function()
    utils.setup_cmake('Dist')
end)
utils.mapkey('n', '<leader>pbrde', function()
    utils.setup_cmake('Debug', vim.fn.input('Dependencies to remove: '))
end)
utils.mapkey('n', '<leader>pbrre', function()
    utils.setup_cmake('Release', vim.fn.input('Dependencies to remove: '))
end)
utils.mapkey('n', '<leader>pbrdi', function()
    utils.setup_cmake('Dist', vim.fn.input('Dependencies to remove: '))
end)

utils.mapkey('n', '<leader>pc', function()
    local trm = utils.get_a_terminal()
    local path = trm.dir .. '/build'
    if vim.fn.isdirectory(path) == 1 then
        trm:send('cd ' .. path)
        trm:send('make -j 4')
        trm:send('cd ..')
    else
        vim.notify(string.format('Build folder not found at: %s', path), vim.log.levels.WARN)
    end
end)
utils.mapkey('n', '<leader>pC', ':make -C build/ -j 4<CR>')

utils.register_save_exec()
utils.register_run_exec()
utils.register_debug_exec()
for i = 0, 9 do
    utils.register_save_exec(i)
    utils.register_run_exec(i)
    utils.register_debug_exec(i)
end

utils.mapkey(
    'n',
    '<leader>ppf',
    ':!/Users/ismael/tracy/profiler/build/tracy-profiler > /dev/null 2>&1 &<CR>',
    { silent = true, desc = 'Execute tracy proxiler' }
)

utils.mapkey('n', '<leader>sf', utils.toggle_header_source, { desc = 'Switch between C/C++ header and source files' })

local custom_motions = {}
custom_motions['¡'] = '$'
custom_motions['¿'] = '0'
custom_motions['0'] = '^'
custom_motions['M'] = '%'
vim.g.VM_custom_motions = custom_motions
