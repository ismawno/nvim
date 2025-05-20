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
    -- Uncomment this to check if there are repeated bindings
    -- if type(mode) == 'table' then
    --     for _, md in ipairs(mode) do
    --         M.mapkey(md, lhs, rhs, opts)
    --     end
    --     return
    -- end
    opts = opts or {}
    -- local force = opts.force
    --
    -- local existing = find_map(mode, lhs, opts.buffer)
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

function M.open_terminal(opts)
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

function M.remove_backgrounds()
    vim.api.nvim_set_hl(0, 'Normal', { bg = 'none', ctermbg = 'none' })
    vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none', ctermbg = 'none' })
    vim.api.nvim_set_hl(0, 'NormalNC', { bg = 'none', ctermbg = 'none' })
    vim.api.nvim_set_hl(0, 'FloatBorder', { bg = 'none', ctermbg = 'none' })
    vim.api.nvim_set_hl(0, 'StatusLine', { bg = 'none', ctermbg = 'none' })
    vim.api.nvim_set_hl(0, 'StatusLineNC', { bg = 'none', ctermbg = 'none' })
    local tgroups = {
        'TelescopeNormal',
        'TelescopeBorder',
        'TelescopePromptBorder',
        'TelescopeResultsBorder',
        'TelescopePreviewBorder',
        'TelescopePromptNormal',
        'TelescopeResultsNormal',
        'TelescopePreviewNormal',
    }
    for _, grp in ipairs(tgroups) do
        vim.api.nvim_set_hl(0, grp, { bg = 'none', ctermbg = 'none' })
    end

    -- local llinegroups = { 'Normal', 'Insert', 'Visual', 'Replace', 'Command', 'Inactive' }
    --     -- for _, grp in ipairs(llinegroups) do
    --         --     vim.api.nvim_set_hl(0, 'LualineC' .. grp, { bg = 'none', ctermbg = 'none' })
    --             -- end
end

return M
