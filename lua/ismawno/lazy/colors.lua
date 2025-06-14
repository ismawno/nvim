local function remove_backgrounds()
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
end

function ApplyColor(color)
    color = color or 'rose-pine-moon'
    vim.cmd.colorscheme(color)
    remove_backgrounds()
end

return {
    'rose-pine/neovim',
    lazy = false,
    priority = 1000,
    opts = {},
    config = function()
        ApplyColor()
    end,
}
