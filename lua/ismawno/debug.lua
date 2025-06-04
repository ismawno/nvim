local M = {}
local function startswith(str, prefix)
    return string.sub(str, 1, #prefix) == prefix
end

-- helper to find an existing map in global or buffer-local tables
function M.find_map(mode, lhs, bufnr)
    local utils = require('ismawno.utils')
    bufnr = bufnr or 0
    -- check buffer-local first
    -- for _, m in ipairs(vim.api.nvim_buf_get_keymap(bufnr, mode)) do
    --     if startswith(m.lhs, utils.termcodes(lhs)) or startswith(utils.termcodes(lhs), m.lhs) then
    --         return m
    --     end
    -- end
    -- -- then check global
    for _, m in ipairs(vim.api.nvim_get_keymap(mode)) do
        if startswith(m.lhs, utils.termcodes(lhs)) or startswith(utils.termcodes(lhs), m.lhs) then
            return m
        end
    end
    return nil
end

return M
