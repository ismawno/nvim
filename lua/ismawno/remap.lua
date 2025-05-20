vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local utils = require('ismawno.utils')
utils.mapkey('n', '<leader>pv', function()
    vim.cmd('Oil')
end, { desc = 'Open explorer' })
-- utils.mapkey('n', '<C-n>', 'n&', { noremap = true, silent = true, desc = 'Go to next occurrence and apply replace' })

utils.mapkey('n', '<C-b>', ":put=''<CR>", { silent = true, desc = 'Insert a blank line below the cursor' })
utils.mapkey('n', '<C-S-B>', ":put!=''<CR>", { silent = true, desc = 'Insert a blank line above the cursor' })
utils.mapkey({ 'n', 'v', 'o' }, '0', '^', { noremap = true, desc = 'Go to the first character of the line' })

local function termcodes(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local operators = { 'c', 'd', 'y' }
local locations = { 'i', 'a' }
local openers = { '(', '{', '[', '<', "'", '"' }
local custom_motions = {}
-- local user_operators = {}

for _, op in ipairs(operators) do
    for _, loc in ipairs(locations) do
        for _, opn in ipairs(openers) do
            local lhs = termcodes(op .. 'm' .. loc .. opn)
            local rhs = termcodes('/' .. opn .. '<CR>' .. op .. loc .. opn)
            utils.mapkey('n', lhs, rhs, {
                noremap = true,
                silent = true,
                desc = 'Apply vim command ' .. op .. loc .. opn .. ' to the next occurrence of ' .. opn,
            })
            -- user_operators[lhs] = rhs
            -- custom_motions[lhs] = rhs
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

custom_motions['¡'] = '$'

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
    '<leader>W',
    [[:%s/<C-r><C-w>/<C-r><C-w>/gI<Left><Left><Left>]],
    { desc = 'Create a replace template for the current word' }
)
utils.mapkey('n', '<leader>w', [[/<C-r><C-w>]], { desc = 'Create a find template for the current word' })

utils.mapkey('n', '<leader>ip', 'i<C-R>"<Esc>', { desc = 'Copy into the line, even if its a whole line' })
utils.mapkey('i', '<C-i>', '<C-R>"', { desc = 'Copy into the line, even if its a whole line' })

local last_terminal = nil
local function open_horizontal_terminal()
    local trm = utils.open_terminal({ direction = 'horizontal' })
    trm:toggle()
    last_terminal = trm
    return trm -- just to avoid a nil warning
end
local function open_float_terminal()
    local trm = utils.open_terminal({
        direction = 'float',
        float_opts = {
            width = math.floor(vim.o.columns * 0.8),
            height = math.floor(vim.o.lines * 0.8),
            border = 'rounded',
        },
    })
    trm:toggle()
    last_terminal = trm
    return trm -- just to avoid a nil warning
end

utils.mapkey('n', '<leader>ot', open_horizontal_terminal, { desc = 'Open a terminal (bottom horizontal)' })
utils.mapkey('n', '<leader>oT', open_float_terminal, { desc = 'Open a terminal (float)' })

local function get_a_terminal()
    if not last_terminal or not last_terminal:is_open() then
        return open_horizontal_terminal()
    end
    return last_terminal
end

local function setup_cmake(btype)
    local trm = get_a_terminal()

    local path = trm.dir .. '/setup/build.py'
    if vim.fn.filereadable(path) == 1 then
        trm:send('python ' .. path .. ' -v --build-type ' .. btype)
    else
        vim.notify(string.format('Build script not found at: %s', path), vim.log.levels.WARN)
    end
end

utils.mapkey('n', '<leader>pbde', function()
    setup_cmake('Debug')
end)
utils.mapkey('n', '<leader>pbre', function()
    setup_cmake('Release')
end)
utils.mapkey('n', '<leader>pbdi', function()
    setup_cmake('Dist')
end)
utils.mapkey('n', '<leader>pc', function()
    local trm = get_a_terminal()
    local path = trm.dir .. '/build'
    if vim.fn.isdirectory(path) == 1 then
        trm:send('cd ' .. path)
        trm:send('make -j 4')
        trm:send('cd ..')
    else
        vim.notify(string.format('Build folder not found at: %s', path), vim.log.levels.WARN)
    end
end)

local last_exec = nil
local function load_exec_table()
    local execs = io.open(vim.fn.stdpath('data') .. '/executables.json', 'r')
    if not execs then
        return nil
    end
    local content = execs:read('*a')
    execs:close()
    return vim.fn.json_decode(content)
end
local function load_executable()
    if last_exec then
        return last_exec
    end
    local execs = load_exec_table()
    if not execs then
        return nil
    end

    local root = utils.find_root()
    last_exec = execs[root]
    return last_exec
end

local function save_executable()
    local root = utils.find_root()
    local path = vim.fn.input('Path to executable: ', root, 'file')
    if not path or vim.fn.filereadable(path) == 0 then
        return nil
    end
    local execs = load_exec_table() or {}
    execs[root] = path
    last_exec = path

    local epath = vim.fn.stdpath('data') .. '/executables.json'
    local efile = io.open(epath, 'w')
    if not efile then
        vim.notify(string.format('Executables file %s not found'), vim.log.levels.WARN)
        return path
    end

    local json = vim.fn.json_encode(execs)
    efile:write(json)
    efile:close()
    return path
end

utils.mapkey('n', '<leader>pX', save_executable, { desc = 'Save an executable shortcut for this workspace' })
utils.mapkey('n', '<leader>px', function()
    local exec = load_executable() or save_executable()
    if exec then
        local trm = get_a_terminal()
        trm:send(exec)
    end
end)
utils.mapkey('t', '<Esc>', '<C-\\><C-n>', { desc = 'Exit from terminal mode' })

vim.g.VM_custom_motions = custom_motions
-- vim.g.VM_user_operators = user_operators
