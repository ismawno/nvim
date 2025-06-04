local M = {}
function M.termcodes(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

function M.mapkey(mode, lhs, rhs, opts)
    -- Uncomment this to check if there are repeated bindings
    -- local dbg = require('ismawno.debug')
    -- if type(mode) == 'table' then
    --     for _, md in ipairs(mode) do
    --         M.mapkey(md, lhs, rhs, opts)
    --     end
    --     return
    -- end
    opts = opts or {}
    -- local force = opts.force
    --
    -- local existing = dbg.find_map(mode, lhs, opts.buffer)
    -- if existing and not force then
    --     rhs = existing.rhs or '<display unavailable>'
    --     vim.notify(
    --         string.format('Keymap for [%s] in mode [%s] already exists: %s -> %s', lhs, mode, existing.lhs, rhs),
    --         vim.log.levels.WARN
    --     )
    --     return
    -- end
    --
    opts.force = nil
    vim.keymap.set(mode, lhs, rhs, opts)
end

function M.find_root(fname)
    local util = require('lspconfig.util')
    fname = fname or vim.api.nvim_buf_get_name(0)
    local root = util.root_pattern('.git')(fname) or vim.fn.getcwd()
    return vim.fn.fnamemodify(root, ':p')
end

local function open_terminal(opts)
    local terminal = require('toggleterm.terminal').Terminal
    local possible_venvs = { '.venv', 'venv' }

    opts = vim.tbl_extend('force', {
        on_open = function(term)
            -- if a venv exists, source it
            for _, v in ipairs(possible_venvs) do
                local activate = term.dir .. '/' .. v .. '/bin/activate'
                if vim.fn.filereadable(activate) == 1 then
                    -- send the source command and clear the screen
                    term:send('source ' .. activate)
                    term:send('clear')
                    break
                end
            end
        end,
    }, opts)
    return terminal:new(opts)
end

function M.navigate_file(dir)
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

local function foreach(elems, func)
    for _, elm in ipairs(elems) do
        func(elm)
    end
end

function M.foreach_operator(func)
    foreach({ 'c', 'd', 'y', 'v' }, func)
end
function M.foreach_location(func)
    foreach({ 'i', 'a' }, func)
end
function M.foreach_opener(func)
    foreach({ '(', '{', '[', '<', "'", '"' }, func)
end

local last_terminal = nil
function M.open_horizontal_terminal()
    local trm = open_terminal({ direction = 'horizontal' })
    trm:toggle()
    last_terminal = trm
    return trm -- just to avoid a nil warning
end
function M.open_float_terminal()
    local trm = open_terminal({
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

function M.get_a_terminal()
    if not last_terminal or not last_terminal:is_open() then
        return M.open_horizontal_terminal()
    end
    return last_terminal
end

function M.setup_cmake(btype, fetch)
    local trm = M.get_a_terminal()

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

    local root = M.find_root()
    last_exec = execs[root][index]
    return last_exec
end

local function save_executable(index)
    local root = M.find_root()
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

function M.register_save_exec(index)
    local lhs = index and M.termcodes('<leader>p' .. index .. 'X') or M.termcodes('<leader>pX')
    M.mapkey('n', lhs, function()
        save_executable(index)
    end, { desc = 'Save an executable shortcut for this workspace in slot ' .. (index or 0) })
end
function M.register_run_exec(index)
    local lhs = index and M.termcodes('<leader>p' .. index .. 'x') or M.termcodes('<leader>px')
    M.mapkey('n', lhs, function()
        local exec = load_executable(index) or save_executable(index)
        if exec then
            local trm = M.get_a_terminal()
            trm:send(exec)
        end
    end, { desc = 'Run an executable from shortcut slot ' .. (index or 0) })
end
function M.register_debug_exec(index)
    local lhs = index and M.termcodes('<leader>p' .. index .. 'd') or M.termcodes('<leader>pd')
    M.mapkey('n', lhs, function()
        local exec = load_executable(index) or save_executable(index)
        if exec then
            local root = M.find_root()
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

function M.toggle_header_source()
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

local function match_delimiters(chars, opn, cls)
    local _, cursor = unpack(vim.api.nvim_win_get_cursor(0))
    cursor = cursor + 1 -- Make it 1-based for Lua indexing

    local nests = 0
    local fwd_matched = nil
    local fwd_index = nil
    for i = cursor, #chars do
        local c = chars[i]
        if (c == ',' or cls[c]) and nests == 0 then
            fwd_matched = c
            fwd_index = i - 1
            break
        end
        if opn[c] then
            nests = nests + 1
        elseif cls[c] then
            nests = nests - 1
        end
    end
    if not fwd_matched or not fwd_index then
        return nil, nil, nil, nil
    end

    nests = 0
    local bkd_matched = nil
    local bkd_index = nil
    for i = cursor, 1, -1 do
        local c = chars[i]
        if (c == ',' or opn[c]) and nests == 0 then
            bkd_matched = c
            bkd_index = i + 1
            break
        end
        if cls[c] then
            nests = nests + 1
        elseif opn[c] then
            nests = nests - 1
        end
    end
    if not bkd_matched or not bkd_index then
        return nil, nil, nil, nil
    end
    return fwd_matched, fwd_index, bkd_matched, bkd_index
end

local function get_line_partitions(line, idx1, idx2)
    local before = line:sub(1, idx1 - 1)
    local selected = line:sub(idx1, idx2)
    local after = line:sub(idx2 + 1)
    return before, selected, after
end

local function set_cursor_to_col(col)
    vim.api.nvim_win_set_cursor(0, { vim.api.nvim_win_get_cursor(0)[1], col })
end

function M.insert_argument(op) end

function M.operate_argument(op)
    local opn = { ['{'] = true, ['('] = true, ['['] = true }
    local cls = { ['}'] = true, [')'] = true, [']'] = true }

    local line = vim.api.nvim_get_current_line()
    local chars = vim.fn.split(line, '\\zs')

    local fwd_matched, fwd_index, bkd_matched, bkd_index = match_delimiters(chars, opn, cls)
    if not fwd_matched or not fwd_index or not bkd_matched or not bkd_index then
        return
    end

    if op ~= 'd' and chars[bkd_index] == ' ' then
        bkd_index = bkd_index + 1
    end

    if op == 'd' then
        if bkd_matched == ',' then
            bkd_index = bkd_index - 1
        end
        if opn[bkd_matched] and not cls[fwd_matched] then
            fwd_index = fwd_index + 1
            if chars[fwd_index + 1] == ' ' then
                fwd_index = fwd_index + 1
            end
        end

        local before, _, after = get_line_partitions(line, bkd_index, fwd_index)
        vim.api.nvim_set_current_line(before .. after)
        set_cursor_to_col(bkd_index - 1)
    elseif op == 'c' then
        local before, _, after = get_line_partitions(line, bkd_index, fwd_index)
        vim.api.nvim_set_current_line(before .. after)
        set_cursor_to_col(bkd_index - 1)
        vim.cmd('startinsert')
    else
        set_cursor_to_col(bkd_index - 1)

        local move_right = fwd_index - bkd_index
        local keys = 'v' .. string.rep('l', move_right)
        if op == 'y' then
            keys = keys .. 'y'
        end

        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), 'n', true)
    end
end

return M
