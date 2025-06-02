vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local utils = require('ismawno.utils')
utils.mapkey('n', '<leader>pv', function()
    vim.cmd('Oil')
end, { desc = 'Open explorer' })
-- utils.mapkey('n', '<C-n>', 'n&', { noremap = true, silent = true, desc = 'Go to next occurrence and apply replace' })

local function navigate_file(dir)
    local current_path = vim.fn.expand('%:p')
    local parent_dir = vim.fn.expand('%:p:h')
    if current_path == '' or parent_dir == '' then
        return
    end

    local files = vim.fn.glob(parent_dir .. '/*', false, true)
    table.sort(files, function(a, b)
        if dir == 'next' then
            return a < b
        else
            return a > b
        end
    end)

    -- Find index of current file
    local idx = nil
    for i, entry in ipairs(files) do
        if entry == current_path then
            idx = i
            break
        end
    end
    if not idx then
        return
    end

    -- If next file exists and is a file, open it
    idx = idx + 1
    local next_entry = files[idx]
    while next_entry do
        if vim.fn.filereadable(next_entry) == 1 then
            vim.cmd('edit ' .. vim.fn.fnameescape(next_entry))
            break
        end
        idx = idx + 1
        next_entry = files[idx]
    end
end

utils.mapkey('n', '<C-b>', ":put=''<CR>", { silent = true, desc = 'Insert a blank line below the cursor' })
-- utils.mapkey('n', '<C-B>', ":put!=''<CR>", { silent = true, desc = 'Insert a blank line above the cursor' })

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

utils.mapkey('n', '<leader>ws', '<C-w><C-s>', { noremap = true, desc = 'Split current buffer' })

utils.mapkey('n', '<leader>fn', function()
    navigate_file('next')
end, { desc = 'Go to next file in explorer' })

utils.mapkey('n', '<leader>fp', function()
    navigate_file('prev')
end, { desc = 'Go to prev file in explorer' })

-- vim.keymap.set('n', '<C-h>', '<cmd>cnext<CR>zz')
-- vim.keymap.set('n', '<C-l>', '<cmd>cprev<CR>zz')

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
utils.mapkey({ 'n', 'v', 'o' }, 'M', '%', { noremap = true, desc = 'Go to matching opener/closer' })

custom_motions['¡'] = '$'
custom_motions['¿'] = '0'
custom_motions['0'] = '^'
custom_motions['M'] = '%'

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
    '<leader>r',
    [[:%s/<C-r><C-w>/<C-r><C-w>/gI<Left><Left><Left>]],
    { desc = 'Create a replace template for the current word' }
)
utils.mapkey('n', '<leader>w', [[/<C-r><C-w>]], { desc = 'Create a find template for the current word' })

utils.mapkey('n', '<leader>ip', 'i<C-r>"<Esc>', { desc = 'Copy into the line, even if its a whole line' })
utils.mapkey('i', '<C-i>', '<C-r>"', { noremap = true, desc = 'Copy into the line, even if its a whole line' })

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

local function setup_cmake(btype, fetch)
    local trm = get_a_terminal()

    local path = trm.dir .. '/setup/build.py'
    if vim.fn.filereadable(path) == 1 then
        if fetch then
            trm:send('python ' .. path .. ' -v --build-type ' .. btype .. ' --fetch-dependencies ' .. fetch)
        else
            trm:send('python ' .. path .. ' -v --build-type ' .. btype)
        end
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
utils.mapkey('n', '<leader>pbrde', function()
    setup_cmake('Debug', vim.fn.input('Dependencies to remove: '))
end)
utils.mapkey('n', '<leader>pbrre', function()
    setup_cmake('Release', vim.fn.input('Dependencies to remove: '))
end)
utils.mapkey('n', '<leader>pbrdi', function()
    setup_cmake('Dist', vim.fn.input('Dependencies to remove: '))
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
utils.mapkey('n', '<leader>pC', ':make -C build/ -j 4<CR>')

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
local function load_executable(index)
    if last_exec and not index then
        return last_exec
    end
    index = index or 0
    index = tostring(index)

    local execs = load_exec_table()
    if not execs then
        return nil
    end

    local root = utils.find_root()
    last_exec = execs[root][index]
    return last_exec
end

local function save_executable(index)
    local root = utils.find_root()
    local path = vim.fn.input('Path to executable: ', root, 'file')
    if not path or vim.fn.filereadable(path) == 0 then
        return nil
    end
    index = index or 0
    index = tostring(index)

    local execs = load_exec_table() or {}
    local ntable = execs[root] or {}
    ntable[index] = path
    execs[root] = ntable

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

local function register_save_exec(index)
    local lhs = index and termcodes('<leader>p' .. index .. 'X') or termcodes('<leader>pX')
    utils.mapkey('n', lhs, function()
        save_executable(index)
    end, { desc = 'Save an executable shortcut for this workspace in slot ' .. (index or 0) })
end
local function register_run_exec(index)
    local lhs = index and termcodes('<leader>p' .. index .. 'x') or termcodes('<leader>px')
    utils.mapkey('n', lhs, function()
        local exec = load_executable(index) or save_executable(index)
        if exec then
            local trm = get_a_terminal()
            trm:send(exec)
        end
    end, { desc = 'Run an executable from shortcut slot ' .. (index or 0) })
end
local function register_debug_exec(index)
    local lhs = index and termcodes('<leader>p' .. index .. 'd') or termcodes('<leader>pd')
    utils.mapkey('n', lhs, function()
        local exec = load_executable(index) or save_executable(index)
        if exec then
            local root = utils.find_root()
            require('dap').run({
                type = 'lldb',
                request = 'launch',
                name = 'Custom launch',
                program = exec,
                justMyCode = false,
                cwd = root,
            })
        end
    end)
end

register_save_exec()
register_run_exec()
register_debug_exec()
for i = 0, 9 do
    register_save_exec(i)
    register_run_exec(i)
    register_debug_exec(i)
end

utils.mapkey(
    'n',
    '<leader>ppf',
    ':!/Users/ismael/tracy/profiler/build/tracy-profiler > /dev/null 2>&1 &<CR>',
    { silent = true, desc = 'Execute tracy proxiler' }
)
utils.mapkey('t', '<Esc>', '<C-\\><C-n>', { desc = 'Exit from terminal mode' })
utils.mapkey('n', '<C-s>', '<C-a>', { noremap = true, desc = 'Increase number' })

local function toggle_header_source()
    local path = vim.api.nvim_buf_get_name(0)
    if path == '' then
        return
    end

    -- split off the “stem” and the “ext”
    local stem, ext = path:match('(.+)%.([hc]p?p?)$')
    if not stem or not ext then
        return
    end

    -- extension map
    local maps = { {
        h = 'c',
        c = 'h',
        hpp = 'cpp',
        cpp = 'hpp',
    }, { h = 'cpp' } }

    for _, map in ipairs(maps) do
        local target_ext = map[ext]
        if target_ext then
            local target = stem .. '.' .. target_ext
            if vim.fn.filereadable(target) == 1 then
                -- safely escape in case there’s spaces, etc.
                vim.cmd('edit ' .. vim.fn.fnameescape(target))
            end
        end
    end
end
utils.mapkey('n', '<leader>sf', toggle_header_source, { desc = 'Switch between C/C++ header and source files' })

vim.g.VM_custom_motions = custom_motions
-- vim.g.VM_user_operators = user_operators
