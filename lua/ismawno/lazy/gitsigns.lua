return {
    'lewis6991/gitsigns.nvim',
    opts = {
        signs = {
            add = { text = '┃' },
            change = { text = '┃' },
            delete = { text = '_' },
            topdelete = { text = '‾' },
            changedelete = { text = '~' },
            untracked = { text = '┆' },
        },
        signs_staged = {
            add = { text = '┃' },
            change = { text = '┃' },
            delete = { text = '_' },
            topdelete = { text = '‾' },
            changedelete = { text = '~' },
            untracked = { text = '┆' },
        },
        on_attach = function(bufnr)
            local gs = require('gitsigns')
            local utils = require('ismawno.utils')
            local function map(mode, lhs, rhs, opts)
                opts = opts or {}
                opts.buffer = bufnr
                utils.mapkey(mode, lhs, rhs, opts)
            end

            map('n', '<leader>ms', gs.stage_hunk)
            map('n', '<leader>mr', gs.reset_hunk)

            map('v', '<leader>ms', function()
                gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
            end)

            map('v', '<leader>mr', function()
                gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
            end)

            map('n', '<leader>mS', gs.stage_buffer)
            map('n', '<leader>mR', gs.reset_buffer)
            map('n', '<leader>mp', gs.preview_hunk)
            map('n', '<leader>mi', gs.preview_hunk_inline)

            map('n', '<leader>mb', function()
                gs.blame_line({ full = true })
            end)

            map('n', '<leader>md', gs.diffthis)

            map('n', '<leader>mD', function()
                gs.diffthis('~')
            end)

            map('n', '<leader>mQ', function()
                gs.setqflist('all')
            end)
            map('n', '<leader>mq', gs.setqflist)

            -- Toggles
            map('n', '<leader>tb', gs.toggle_current_line_blame)
            map('n', '<leader>tw', gs.toggle_word_diff)

            -- Text object
            map({ 'o', 'x' }, 'ih', gs.select_hunk)
        end,
        signs_staged_enable = true,
        signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
        numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
        linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
        word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
        watch_gitdir = {
            follow_files = true,
        },
        auto_attach = true,
        attach_to_untracked = false,
        current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
        current_line_blame_opts = {
            virt_text = true,
            virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
            delay = 1000,
            ignore_whitespace = false,
            virt_text_priority = 100,
            use_focus = true,
        },
        current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
        sign_priority = 6,
        update_debounce = 100,
        status_formatter = nil, -- Use default
        max_file_length = 40000, -- Disable if file is longer than this (in lines)
        preview_config = {
            -- Options passed to nvim_open_win
            style = 'minimal',
            relative = 'cursor',
            row = 0,
            col = 1,
        },
    },
}
