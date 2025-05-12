local M = {}

local function startswith(str, prefix)
    return string.sub(str, 1, #prefix) == prefix
end

local function termcodes(str)
    return vim.api.nvim_replace_termcodes(str, true, false, true)
end

-- helper to find an existing map in global or buffer-local tables
local function find_map(mode, lhs, bufnr)
    bufnr = bufnr or 0
    -- check buffer-local first
    -- for _, m in ipairs(vim.api.nvim_buf_get_keymap(bufnr, mode)) do
    --     if startswith(m.lhs, termcodes(lhs)) or startswith(termcodes(lhs), m.lhs) then
    --         return m
    --     end
    -- end
    -- -- then check global
    for _, m in ipairs(vim.api.nvim_get_keymap(mode)) do
        if startswith(m.lhs, termcodes(lhs)) or startswith(termcodes(lhs), m.lhs) then
            return m
        end
    end
    return nil
end

function M.mapkey(mode, lhs, rhs, opts)
    if type(mode) == 'table' then
        for _, md in ipairs(mode) do
            M.mapkey(md, lhs, rhs, opts)
        end
        return
    end
    opts = opts or {}
    local force = opts.force
    opts.force = nil

    local existing = find_map(mode, lhs, opts.buffer)
    if existing and not force then
        rhs = existing.rhs or '<display unavailable>'
        vim.notify(
            string.format('Keymap for [%s] in mode [%s] already exists: %s -> %s', lhs, mode, existing.lhs, rhs),
            vim.log.levels.WARN
        )
        return
    end

    vim.keymap.set(mode, lhs, rhs, opts)
end

return M
