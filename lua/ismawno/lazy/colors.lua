local function remove_backgrounds()
    local groups = {
        'Normal',
        'NormalFloat',
        'NormalNC',
        'FloatBorder',
        'FloatTitle',
        'StatusLine',
        'StatusLineNC',
        'TelescopeTitle',
        'TelescopeNormal',
        'TelescopeBorder',
        'TelescopePromptBorder',
        'TelescopeResultsBorder',
        'TelescopePreviewBorder',
        'TelescopePromptNormal',
        'TelescopeResultsNormal',
        'TelescopePreviewNormal',
    }
    for _, grp in ipairs(groups) do
        vim.api.nvim_set_hl(0, grp, { bg = 'none', ctermbg = 'none' })
    end
end

function ApplyColor(color)
    color = color or 'catppuccin'
    vim.cmd.colorscheme(color)
    remove_backgrounds()
end

return {
    'catppuccin/nvim',
    name = 'catppuccin',
    lazy = false,
    priority = 1000,
    config = function()
        require('catppuccin').setup({
            flavour = 'mocha',
            transparent_background = true,
        })
        ApplyColor()
    end,
}
