local function in_git_repo()
    -- returns true if the current buffer is in a git worktree
    return vim.fn.systemlist('git rev-parse --is-inside-work-tree')[1] == 'true'
end

return {
    'stevearc/oil.nvim',
    ---@module 'oil'
    ---@type oil.SetupOpts
    -- Optional dependencies
    dependencies = { { 'echasnovski/mini.icons', opts = {} } },
    --
    -- dependencies = { 'nvim-tree/nvim-web-devicons' }, -- use if you prefer nvim-web-devicons
    -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
    lazy = false,
    opts = {
        use_default_keymaps = true,
        view_options = { show_hidden = true },
        git = { -- enable `git add` on new files
            add = function(path)
                return in_git_repo()
            end,
            -- enable `git mv` on renames
            mv = function(src, dest)
                return in_git_repo()
            end,
            -- enable `git rm` on deletes
            rm = function(path)
                return in_git_repo()
            end,
        },
    },
}
