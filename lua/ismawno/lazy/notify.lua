return {
    'rcarriga/nvim-notify',
    lazy = false,
    priority = 1001,
    config = function()
        local notify = require('notify')
        notify.setup({ background_colour = '#000000', render = 'minimal' })
        vim.notify = notify
    end,
}
