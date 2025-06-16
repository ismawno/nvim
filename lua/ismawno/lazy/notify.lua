return {
    'rcarriga/nvim-notify',
    lazy = false,
    priority = 1001,
    config = function()
        vim.notify = require('notify')
    end,
}
