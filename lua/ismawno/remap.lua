vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local utils = require('ismawno.utils')

vim.cmd([[cnoreabbrev W w]])
vim.cmd([[cnoreabbrev Q q]])
vim.cmd([[cnoreabbrev Wq wq]])

vim.keymap.set('n', '<leader>pv', function()
    vim.cmd('Oil')
end, { desc = 'Open explorer' })

vim.keymap.set('n', '<C-b>', ":put=''<CR>", { silent = true, desc = 'Insert a blank line below the cursor' })
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { desc = 'Exit from terminal mode' })
vim.keymap.set('n', '<C-s>', '<C-a>', { noremap = true, desc = 'Increase number' })

vim.keymap.set('n', '<leader>Dm', function()
    vim.cmd(':delm! | delm a-zA-Z<CR>')
    vim.notify('Deleted all marks')
end, { desc = 'Remove all marks' })

for _, mark in ipairs(vim.fn.split('abcdefghijklmnopqrstuvwxyz', '\\zs')) do
    vim.keymap.set('n', 'm' .. mark, function()
        vim.api.nvim_feedkeys('m' .. mark, 'n', false)
        vim.notify('Added mark: ' .. mark)
    end, { desc = 'Add mark ' .. mark })
    local lhs = utils.termcodes('<leader>dm' .. mark)
    vim.keymap.set('n', lhs, function()
        vim.cmd('delmarks ' .. mark)
        vim.notify('Deleted mark: ' .. mark)
    end, { desc = 'Delete mark ' .. mark })
end

vim.keymap.set('v', '<C-j>', ":m '>+1<CR>gv=gv", { silent = true, desc = 'Move current line down' })
vim.keymap.set('v', '<C-k>', ":m '<-2<CR>gv=gv", { silent = true, desc = 'Move current line up' })

vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Go to the next bottom window' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Go to the next top window' })
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Go to the next left window' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Go to the next right window' })

vim.keymap.set('n', '<C-q>', '<cmd>cprev<CR>zz', { desc = 'Go to previous quickfix element' })
vim.keymap.set('n', '<C-e>', '<cmd>cnext<CR>zz', { desc = 'Go to next quickfix element' })

vim.keymap.set({ 'n', 'v' }, 'J', '<C-d>', { noremap = true, desc = 'Move cursor down 10%' })
vim.keymap.set({ 'n', 'v' }, 'K', '<C-u>', { noremap = true, desc = 'Move cursor up 10%' })
-- vim.keymap.set({ 'n', 'v', 'o' }, '¡', '$', { noremap = true, desc = 'Jump to the end of line' })
-- vim.keymap.set({ 'n', 'v', 'o' }, '¿', '0', { noremap = true, desc = 'Jump to the start of line' })

-- vim.keymap.set({ 'n', 'v', 'o' }, '0', '^', { noremap = true, desc = 'Go to the first character of the line' })
vim.keymap.set({ 'n', 'v', 'o' }, 'M', '%', { noremap = true, desc = 'Go to matching opener/closer' })

vim.keymap.set('n', '<leader>pr', function()
    local root = utils.find_root()
    vim.cmd('Oil ' .. root)
end, { desc = 'Navigate to root' })

vim.keymap.set('x', '<leader>p', [["_dP]], { desc = 'Paste selection without copying it' })
vim.keymap.set({ 'n', 'v' }, '<leader>y', [["+y]], { desc = 'Copy to system clipboard' })
vim.keymap.set('n', '<leader>Y', [["+Y]], { desc = 'Copy line to system clipboard' })
vim.keymap.set('n', '<leader>w', [[/<C-r><C-w>]], { desc = 'Create a find template for the current word' })
vim.keymap.set('n', '<leader>W', [[/<C-r><C-a>]], { desc = 'Create a find template for the current word' })
vim.keymap.set('n', '<leader>b', [[?<C-r><C-w>]], { desc = 'Create a find template for the current word' })
vim.keymap.set('n', '<leader>B', [[?<C-r><C-a>]], { desc = 'Create a find template for the current word' })
-- vim.keymap.set('n', '<leader>up', 'i<C-r>"<Esc>', { desc = 'Copy into the line, even if its a whole line' })
vim.keymap.set('i', '<C-u>', '<C-r>"', { noremap = true, desc = 'Copy into the line, even if its a whole line' })

vim.keymap.set('n', '<leader>ot', utils.open_horizontal_terminal, { desc = 'Open a terminal (bottom horizontal)' })
vim.keymap.set('n', '<leader>oT', utils.open_float_terminal, { desc = 'Open a terminal (float)' })

vim.keymap.set('n', '<C-d>', function()
    utils.navigate_file('next')
end, { desc = 'Go to next file in explorer' })

vim.keymap.set('n', '<C-u>', function()
    utils.navigate_file('prev')
end, { desc = 'Go to prev file in explorer' })

utils.foreach_operator(function(op)
    utils.foreach_location(function(loc)
        local lhs = utils.termcodes(op .. loc .. 'x')
        vim.keymap.set('n', lhs, function()
            utils.operate_any_delimiter(op, loc, 'center')
        end, { silent = true, desc = 'Apply ' .. op .. ' with location ' .. loc .. ' to any delimiter' })

        lhs = utils.termcodes(op .. 'm' .. loc .. 'x')
        vim.keymap.set('n', lhs, function()
            utils.operate_any_delimiter(op, loc, 'forwards')
        end, {
            silent = true,
            desc = 'Apply ' .. op .. ' with location ' .. loc .. ' to the next (any) delimiter',
        })

        lhs = utils.termcodes(op .. 'M' .. loc .. 'x')
        vim.keymap.set('n', lhs, function()
            utils.operate_any_delimiter(op, loc, 'backwards')
        end, {
            silent = true,
            desc = 'Apply ' .. op .. ' with location ' .. loc .. ' to the previous (any) delimiter',
        })

        utils.foreach_delimiter(function(del)
            lhs = utils.termcodes(op .. 'm' .. loc .. del)
            local rhs = utils.termcodes('/' .. del .. '<CR>' .. op .. loc .. del)
            vim.keymap.set('n', lhs, rhs, {
                noremap = true,
                silent = true,
                desc = 'Apply vim command ' .. op .. loc .. del .. ' to the next occurrence of ' .. del,
            })
            lhs = utils.termcodes(op .. 'M' .. loc .. del)
            rhs = utils.termcodes('?' .. del .. '<CR>' .. op .. loc .. del)
            vim.keymap.set('n', lhs, rhs, {
                noremap = true,
                silent = true,
                desc = 'Apply vim command ' .. op .. loc .. del .. ' to the previous occurrence of ' .. del,
            })
        end)
    end)
end)

utils.foreach_location(function(loc)
    local lhs = '<leader>a' .. loc
    vim.keymap.set('n', lhs, function()
        utils.insert_parameter(loc, 'center')
    end)
    lhs = '<leader>am' .. loc
    vim.keymap.set('n', lhs, function()
        utils.insert_parameter(loc, 'forwards')
    end)
    lhs = '<leader>aM' .. loc
    vim.keymap.set('n', lhs, function()
        utils.insert_parameter(loc, 'backwards')
    end)
    utils.foreach_opener(function(opn)
        lhs = '<leader>a' .. opn .. loc
        vim.keymap.set('n', lhs, function()
            utils.insert_parameter(loc, 'center', opn)
        end)
        lhs = '<leader>am' .. opn .. loc
        vim.keymap.set('n', lhs, function()
            utils.insert_parameter(loc, 'forwards', opn)
        end)
        lhs = '<leader>aM' .. opn .. loc
        vim.keymap.set('n', lhs, function()
            utils.insert_parameter(loc, 'backwards', opn)
        end)
    end)
end, true)

vim.keymap.set('n', '<leader>pcd', function()
    if not utils.setup_cmake_convoy('-v --build-type Debug') then
        utils.configure_cmake('debug')
    end
end)
vim.keymap.set('n', '<leader>pcr', function()
    if not utils.setup_cmake_convoy('-v --build-type Release') then
        utils.configure_cmake('release')
    end
end)

vim.keymap.set('n', '<leader>pcD', function()
    utils.setup_cmake_convoy('-v --build-type Dist', true)
end)

vim.keymap.set('n', '<leader>pRcd', function()
    local deps = vim.fn.input('Dependencies to re-fetch: ')
    if not deps or deps == '' then
        return
    end
    if not utils.setup_cmake_convoy('-v --build-type Debug --fetch-dependencies ' .. deps) then
        utils.remove_cmake_deps(deps)
        utils.configure_cmake('debug')
    end
end)
vim.keymap.set('n', '<leader>pRcr', function()
    local deps = vim.fn.input('Dependencies to re-fetch: ')
    if not deps or deps == '' then
        return
    end
    if not utils.setup_cmake_convoy('-v --build-type Release --fetch-dependencies ' .. deps) then
        utils.remove_cmake_deps(deps)
        utils.configure_cmake('release')
    end
end)
vim.keymap.set('n', '<leader>pRcD', function()
    local deps = vim.fn.input('Dependencies to re-fetch: ')
    if not deps or deps == '' then
        return
    end
    utils.setup_cmake_convoy('-v --build-type Dist --fetch-dependencies ' .. deps, true)
end)

vim.keymap.set('n', '<leader>pB', utils.build_cmake_convoy)

vim.keymap.set('n', '<leader>pbd', function()
    utils.build_cmake('debug')
end)
vim.keymap.set('n', '<leader>pbr', function()
    utils.build_cmake('release')
end)

-- utils.register_save_exec('<leader>')
-- utils.register_run_exec('<leader>')
-- utils.register_debug_exec('<leader>')
-- for i = 0, 9 do
--     utils.register_save_exec('<leader>', i)
--     utils.register_run_exec('<leader>', i)
--     utils.register_debug_exec('<leader>', i)
-- end

vim.keymap.set('n', '<leader>tx', function()
    if vim.fn.executable('tracy') == 1 then
        vim.cmd('silent !tracy > /dev/null 2>&1 &')
    else
        vim.cmd('silent !~/vendor/tracy/profiler/build/tracy-profiler > /dev/null 2>&1 &')
    end
end, { silent = true, desc = 'Execute tracy profiler' })

vim.keymap.set('n', '<leader>sf', utils.toggle_header_source, { desc = 'Switch between C/C++ header and source files' })

local custom_motions = {}
-- custom_motions['¡'] = '$'
-- custom_motions['¿'] = '0'
-- custom_motions['0'] = '^'
custom_motions['M'] = '%'
vim.g.VM_custom_motions = custom_motions
