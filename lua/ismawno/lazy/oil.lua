local function in_git_repo()
    -- returns true if the current buffer is in a git worktree
    return vim.fn.systemlist('git rev-parse --is-inside-work-tree')[1] == 'true'
end

return {
    {
        'stevearc/oil.nvim',
        ---@module 'oil'
        ---@type oil.SetupOpts
        -- Optional dependencies
        dependencies = {
            {
                'echasnovski/mini.icons',
                priority = 1002,
                lazy = false,
                config = function()
                    require('mini.icons').mock_nvim_web_devicons()
                end,
            },
        },
        --
        -- dependencies = { 'nvim-tree/nvim-web-devicons' }, -- use if you prefer nvim-web-devicons
        -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
        lazy = false,
        opts = {
            win_options = { signcolumn = 'yes:2' },
            keymaps = {
                ['<leader>vs'] = 'actions.select_vsplit',
                ['<leader>sp'] = 'actions.select_split',
                ['<C-s>'] = false,
                ['<C-h>'] = false,
                ['<C-t>'] = false,
            },
            use_default_keymaps = true,
            view_options = { show_hidden = true },
            git = { -- enable `git add` on new files
                add = function()
                    return in_git_repo()
                end,
                -- enable `git mv` on renames
                mv = function()
                    return in_git_repo()
                end,
                -- enable `git rm` on deletes
                rm = function()
                    return in_git_repo()
                end,
            },
        },
    },
    {
        'refractalize/oil-git-status.nvim',

        dependencies = {
            'stevearc/oil.nvim',
        },
        config = function()
            require('oil-git-status').setup({
                show_ignored = false,
                symbols = {
                    index = {
                        ['!'] = 'I',
                        ['?'] = 'U',
                        ['A'] = 'A',
                        ['C'] = 'C',
                        ['D'] = 'D',
                        ['M'] = 'M',
                        ['R'] = 'R',
                        ['T'] = 'T',
                        ['U'] = '!',
                        [' '] = ' ',
                    },
                    working_tree = {
                        ['!'] = 'I',
                        ['?'] = 'U',
                        ['A'] = 'A',
                        ['C'] = 'C',
                        ['D'] = 'D',
                        ['M'] = 'M',
                        ['R'] = 'R',
                        ['T'] = 'T',
                        ['U'] = '!',
                        [' '] = ' ',
                    },
                },
            })
        end,
    },
}
