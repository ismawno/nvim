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

function M.is_nixos()
    return vim.fn.filereadable('/etc/NIXOS') == 1
end

function M.find_root(fname)
    local util = require('lspconfig.util')
    fname = fname or vim.api.nvim_buf_get_name(0)
    local root = util.root_pattern('.git')(fname) or vim.fn.getcwd()
    return vim.fn.fnamemodify(root, ':p')
end

function M.venv_executable(vname, fname)
    vname = vname or '.venv'
    local exec = M.find_root(fname) .. vname .. '/bin/python'
    if vim.fn.filereadable(exec) == 0 then
        return nil
    end
    return exec
end

function M.find_project_name(fname)
    local root = M.find_root(fname)
    return root:match('([^/]+)/?$')
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
function M.foreach_location(func, also_upper)
    if also_upper then
        foreach({ 'i', 'a', 'I', 'A' }, func)
    else
        foreach({ 'i', 'a' }, func)
    end
end
function M.foreach_opener(func)
    foreach({ '(', '{', '[', '<', "'", '"' }, func)
end
function M.foreach_closer(func)
    foreach({ ')', '}', ']', '>', "'", '"' }, func)
end
function M.foreach_delimiter(func)
    M.foreach_opener(func)
    M.foreach_closer(func)
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

function M.configure_cmake(preset)
    local trm = M.get_a_terminal()
    trm:send('cmake --preset ' .. preset)
    trm:send('cp build/' .. preset .. '/compile_commands.json build/compile_commands.json')
end

function M.build_cmake(preset)
    local trm = M.get_a_terminal()
    trm:send('cmake --build --preset ' .. preset)
end

function M.build_cmake_convoy()
    local trm = M.get_a_terminal()
    local path = trm.dir .. '/build'
    if vim.fn.isdirectory(path) == 1 then
        trm:send('cd ' .. path)
        trm:send('make -j 8')
        trm:send('cd ..')
    else
        vim.notify(string.format('Build directory not found at: %s', path), vim.log.levels.WARN)
    end
end

function M.setup_cmake_convoy(args, log)
    local trm = M.get_a_terminal()

    local path = trm.dir .. '/setup/build.py'
    if vim.fn.filereadable(path) == 1 then
        local cmd = 'python ' .. path
        if args then
            cmd = cmd .. ' ' .. args
        end
        trm:send(cmd)
        return true
    end
    if log then
        vim.notify(string.format('Build script not found at: %s', path), vim.log.levels.WARN)
    end
    return false
end

function M.remove_cmake_deps(deps)
    local trm = M.get_a_terminal()
    local root = M.find_root()
    for dep in string.gmatch(deps, '%S+') do
        trm:send('rm -rf ' .. root .. 'build/debug/_deps/' .. dep .. '-build')
        trm:send('rm -rf ' .. root .. 'build/debug/_deps/' .. dep .. '-src')
        trm:send('rm -rf ' .. root .. 'build/debug/_deps/' .. dep .. '-subbuild')
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
    local root_execs = execs[root]
    if not root_execs then
        return nil
    end

    last_exec = root_execs[index]
    return last_exec
end

local function save_executable(index)
    index = index or 0
    index = tostring(index)
    local root = M.find_root()
    local path = vim.fn.input('Path to executable slot ' .. index, root, 'file')
    if not path then
        return nil
    end

    local noargs = string.match(path, '%S+')
    if vim.fn.filereadable(noargs) == 0 then
        return nil
    end

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

function M.register_save_exec(binding_suffix, index)
    local lhs = index and M.termcodes(binding_suffix .. index .. 'X') or M.termcodes(binding_suffix .. 'X')
    M.mapkey('n', lhs, function()
        save_executable(index)
    end, { desc = 'Save an executable shortcut for this workspace in slot ' .. (index or 0) })
end
function M.register_run_exec(binding_suffix, index)
    local lhs = index and M.termcodes(binding_suffix .. index .. 'x') or M.termcodes(binding_suffix .. 'x')
    M.mapkey('n', lhs, function()
        local exec = load_executable(index) or save_executable(index)
        if exec then
            local trm = M.get_a_terminal()
            trm:send(exec)
        end
    end, { desc = 'Run an executable from shortcut slot ' .. (index or 0) })
end
function M.register_debug_exec(binding_suffix, index)
    local lhs = index and M.termcodes(binding_suffix .. index .. 'd') or M.termcodes(binding_suffix .. 'd')
    M.mapkey('n', lhs, function()
        local exec = load_executable(index) or save_executable(index)
        if exec then
            local path = string.match(exec, '%S+')
            local args = {}
            for arg in string.gmatch(exec, '%S+') do
                if arg ~= path then
                    table.insert(args, arg)
                end
            end

            local root = M.find_root()
            require('dap').run({
                type = 'lldb',
                request = 'launch',
                name = 'Custom launch',
                program = path,
                args = args,
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

local function get_delimiter(direction, filter)
    local delimiters = { ['{'] = '}', ['('] = ')', ['['] = ']' }
    if filter then
        delimiters = { [filter] = delimiters[filter] }
    end

    local delimiter = nil
    local minpos = nil
    for opn, cls in pairs(delimiters) do
        if direction == 'backwards' then
            local pos = vim.fn.searchpairpos(cls, '', opn, 'bncW')
            if
                (pos[1] > 0 or pos[2] > 0)
                and (not minpos or (pos[1] > minpos[1] or (pos[1] == minpos[1] and pos[2] > minpos[2])))
            then
                minpos = pos
                delimiter = opn
            end
        elseif direction == 'forwards' then
            local pos = vim.fn.searchpairpos(cls, '', opn, 'ncW')
            if
                (pos[1] > 0 or pos[2] > 0)
                and (not minpos or (pos[1] < minpos[1] or (pos[1] == minpos[1] and pos[2] < minpos[2])))
            then
                minpos = pos
                delimiter = opn
            end
        else
            local opnn = opn
            local clss = cls
            if opn == '[' then
                opnn = '\\['
                clss = '\\]'
            end
            local pos = vim.fn.searchpairpos(opnn, '', clss, 'bncW')
            if
                (pos[1] > 0 or pos[2] > 0)
                and (not minpos or (pos[1] > minpos[1] or (pos[1] == minpos[1] and pos[2] > minpos[2])))
            then
                minpos = pos
                delimiter = opn
            end
        end
    end
    if not minpos then
        if direction == 'center' then
            return get_delimiter('forwards')
        end
        return nil, nil
    end
    return delimiter, minpos
end

function M.insert_parameter(mode, direction, filter)
    local opener, pos = get_delimiter(direction, filter)
    local crow, ccol = unpack(vim.api.nvim_win_get_cursor(0))
    ccol = ccol + 1

    if not opener or not pos then
        return
    end

    local outside = false
    if direction == 'backwards' then
        if pos[1] < crow or (pos[1] == crow and pos[2] < ccol) then
            outside = true
        end
    else
        if pos[1] > crow or (pos[1] == crow and pos[2] > ccol) then
            outside = true
        end
    end

    local function feed(s, m)
        m = m or 'n'
        vim.api.nvim_feedkeys(M.termcodes(s), m, true)
    end

    local openers = { ['{'] = '}', ['('] = ')', ['['] = ']', ['<'] = '>' }
    local closer = openers[opener]

    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local chars = vim.fn.split(lines[pos[1]], '\\zs')

    local function set_cursor(p)
        vim.api.nvim_win_set_cursor(0, { p[1], p[2] - 1 })
        crow = p[1]
        ccol = p[2]
    end

    if outside or mode == 'I' or mode == 'A' then
        set_cursor(pos)
        if direction == 'backwards' then
            feed('%', 'x')
            crow, ccol = unpack(vim.api.nvim_win_get_cursor(0))
            ccol = ccol + 1
            pos[1] = crow
            pos[2] = ccol
            if mode == 'i' or mode == 'a' then
                feed('%h', 'x')
                crow, ccol = unpack(vim.api.nvim_win_get_cursor(0))
                ccol = ccol + 1
            end
        end
    end

    if chars[pos[2] + 1] == closer then
        feed('ci' .. opener)
        return
    end

    if mode == 'I' then
        feed('a, <Esc>hi')
    elseif mode == 'A' then
        feed('%i, ')
    elseif mode == 'i' then
        local nests = 0
        local match = nil
        pos = nil
        chars = vim.fn.split(lines[crow], '\\zs')
        if chars[ccol] == ',' then
            ccol = ccol - 1
        end

        for i = crow, 1, -1 do
            chars = vim.fn.split(lines[i], '\\zs')
            local start = i == crow and ccol or #chars
            for j = start, 1, -1 do
                local c = chars[j]
                if c == ',' and nests == 0 then
                    match = ','
                    pos = { i, j }
                    break
                end
                if c == closer then
                    nests = nests + 1
                elseif c == opener then
                    if nests == 0 then
                        match = c
                        pos = { i, j }
                        break
                    end
                    nests = nests - 1
                end
            end
            if match and pos then
                break
            end
        end
        if not match or not pos then
            return
        end
        set_cursor(pos)
        if match == ',' then
            feed('i, ')
        else
            feed('a, <Esc>hi')
        end
    elseif mode == 'a' then
        local nests = 0
        pos = nil
        chars = vim.fn.split(lines[crow], '\\zs')
        if chars[ccol] == ',' then
            ccol = ccol - 1
        end

        for i = crow, #lines do
            chars = vim.fn.split(lines[i], '\\zs')
            local start = i == crow and ccol + 1 or 0
            for j = start, #chars do
                local c = chars[j]
                if c == ',' and nests == 0 then
                    pos = { i, j }
                    break
                end
                if c == opener then
                    nests = nests + 1
                elseif c == closer then
                    if nests == 0 then
                        pos = { i, j }
                        break
                    end
                    nests = nests - 1
                end
            end
            if pos then
                break
            end
        end
        if not pos then
            return
        end
        set_cursor(pos)
        feed('i, ')
    end
end

function M.operate_any_delimiter(op, loc, direction)
    local delimiter, pos = get_delimiter(direction)
    if not delimiter or not pos then
        return
    end
    vim.api.nvim_win_set_cursor(0, { pos[1], pos[2] - 1 })
    vim.api.nvim_feedkeys(M.termcodes(op .. loc .. delimiter), 'n', true)
end

return M
