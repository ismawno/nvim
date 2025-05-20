function ApplyColor(color)
    color = color or 'rose-pine-moon'
    vim.cmd.colorscheme(color)
    local utils = require('ismawno.utils')
    utils.remove_backgrounds()
end

return {
    'rose-pine/neovim',
    priority = 1000,
    opts = {},
    config = function()
        ApplyColor()
    end,
}
