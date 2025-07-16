return {
    'zbirenbaum/copilot.lua',
    event = 'InsertEnter',
    enabled = false,
    config = function()
        require('copilot').setup({
            suggestion = {
                enabled = true,
                auto_trigger = true,
                debounce = 75,
                keymap = {
                    accept = '<C-u>',
                    next = '<C-n>',
                    prev = '<C-p>',
                    dismiss = '<C-m>',
                },
            },
            panel = {
                enabled = true,
                auto_refresh = false,
                keymap = {
                    open = '<C-e>',
                },
            },
        })
    end,
}
