function ApplyColor(color)
    color = color or 'rose-pine-moon'
    vim.cmd.colorscheme(color)

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
    -- for _, grp in ipairs(llinegroups) do
    --     vim.api.nvim_set_hl(0, 'LualineC' .. grp, { bg = 'none', ctermbg = 'none' })
    -- end
end

return {
    'rose-pine/neovim',
    opts = {},
    config = function()
        ApplyColor()
    end,
}
