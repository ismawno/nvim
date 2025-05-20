return {
    'mg979/vim-visual-multi',
    lazy = false,
    init = function()
        vim.g.VM_silent_exit = 1
        vim.g.VM_maps = { ['Add Cursor Down'] = '<C-s>', ['Add Cursor Up'] = '<C-w>' }
        -- vim.g.VM_show_warnings = 0
        vim.g.VM_quit_after_leaving_insert_mode = 1
    end,
}
