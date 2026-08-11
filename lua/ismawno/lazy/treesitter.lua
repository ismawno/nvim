-- ============================================================================
-- Treesitter config, ported to the `main` branch rewrite.
--
-- REQUIREMENTS (main branch is a full, incompatible rewrite):
--   * Neovim >= 0.12.0
--   * tree-sitter-cli >= 0.26.1  (from your package manager, NOT npm)
--   * `tar`, `curl` and a C compiler on PATH
--
-- Key differences from the old `master` setup:
--   * `require('nvim-treesitter.configs').setup{}` is GONE.
--   * `ensure_installed` is gone -> call `require('nvim-treesitter').install{}`.
--   * `highlight = { enable = true }` is gone -> `vim.treesitter.start()`.
--   * `indent = { enable = true }` is gone -> set `indentexpr` yourself.
--   * textobjects is now a standalone plugin with its own `setup{}` and you
--     declare keymaps yourself via `vim.keymap.set`.
--   * nvim-treesitter on `main` does NOT support lazy-loading.
-- ============================================================================

return {
    -- ------------------------------------------------------------------------
    -- nvim-treesitter (main)
    -- ------------------------------------------------------------------------
    {
        'nvim-treesitter/nvim-treesitter',
        branch = 'main',
        lazy = false, -- main branch does not support lazy-loading
        build = ':TSUpdate',
        config = function()
            require('nvim-treesitter').setup({
                -- Parsers/queries are installed here and prepended to runtimepath.
                install_dir = vim.fn.stdpath('data') .. '/site',
            })

            -- Replaces the old `ensure_installed`. Runs asynchronously, so on a
            -- very first launch you may need to restart nvim once the parsers
            -- have finished compiling.
            require('nvim-treesitter').install({
                'c',
                'cpp',
                'bash',
                'python',
                'cmake',
                'lua',
                'vim',
                'vimdoc',
                'query',
                'markdown',
                'markdown_inline',
                'regex',
            })

            -- Replaces `highlight = {...}` and `indent = {...}`.
            local max_filesize = 1024 * 1024 -- 1 MB
            local uv = vim.uv or vim.loop

            vim.api.nvim_create_autocmd('FileType', {
                group = vim.api.nvim_create_augroup('user_treesitter', { clear = true }),
                callback = function(args)
                    local buf = args.buf
                    local ft = args.match

                    -- filetype -> parser name (nil if nothing is registered)
                    local lang = vim.treesitter.language.get_lang(ft)
                    if not lang then
                        return
                    end

                    -- old `highlight.disable`: html
                    if lang == 'html' then
                        vim.notify('Treesitter disabled')
                        return
                    end

                    -- old `highlight.disable`: files over 1 MB
                    local ok, stats = pcall(uv.fs_stat, vim.api.nvim_buf_get_name(buf))
                    if ok and stats and stats.size > max_filesize then
                        vim.notify(
                            'File larger than 1 MB treesitter disabled for performance',
                            vim.log.levels.WARN,
                            { title = 'Treesitter' }
                        )
                        return
                    end

                    -- old `highlight = { enable = true }`
                    -- pcall: the parser may not be installed (yet)
                    if not pcall(vim.treesitter.start, buf, lang) then
                        return
                    end

                    -- old `indent = { enable = true }`
                    vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

                    -- old `additional_vim_regex_highlighting = { 'markdown' }`
                    if ft == 'markdown' then
                        vim.bo[buf].syntax = 'on'
                    end
                end,
            })
        end,
    },

    -- ------------------------------------------------------------------------
    -- nvim-treesitter-textobjects (main)
    -- ------------------------------------------------------------------------
    {
        'nvim-treesitter/nvim-treesitter-textobjects',
        branch = 'main',
        dependencies = { 'nvim-treesitter/nvim-treesitter' },
        lazy = false,
        -- init = function()
        --     -- The upstream README suggests this to stop built-in ftplugin maps
        --     -- (]m, [m, ...) from clashing. None of your maps collide, so it is
        --     -- left off; uncomment if you hit a conflict.
        --     vim.g.no_plugin_maps = true
        -- end,
        config = function()
            require('nvim-treesitter-textobjects').setup({
                select = {
                    lookahead = true,
                    -- selection_modes = 'v',
                    include_surrounding_whitespace = function(opts)
                        if opts.query_string == '@parameter.inner' then
                            return false
                        end
                        return true
                    end,
                },
                move = {
                    set_jumps = true,
                },
            })

            local select = require('nvim-treesitter-textobjects.select')
            local swap = require('nvim-treesitter-textobjects.swap')
            local move = require('nvim-treesitter-textobjects.move')

            -- `@local.scope` lives in the `locals` query group, everything else
            -- in `textobjects`.
            local function group_of(query)
                return vim.startswith(query, '@local.') and 'locals' or 'textobjects'
            end

            -- ---------------------------------------------------------------
            -- select  (x/o modes -> `cia`, `daf`, `vic`, ...)
            -- ---------------------------------------------------------------
            local select_maps = {
                ['af'] = '@function.outer',
                ['if'] = '@function.inner',
                ['ac'] = '@class.outer',
                ['ic'] = '@class.inner',
                -- NOTE: `@scope.outer` / `@scope.inner` are not real captures in
                -- textobjects.scm; the equivalent is `@local.scope` from locals.scm.
                ['as'] = '@local.scope',
                ['is'] = '@local.scope',
                ['ab'] = '@block.outer',
                ['ib'] = '@block.inner',
                ['aa'] = '@parameter.outer',
                ['ia'] = '@parameter.inner',
                ['ad'] = '@conditional.outer',
                ['id'] = '@conditional.inner',
                ['al'] = '@loop.outer',
                ['il'] = '@loop.inner',
            }

            for key, query in pairs(select_maps) do
                vim.keymap.set({ 'x', 'o' }, key, function()
                    select.select_textobject(query, group_of(query))
                end, { desc = 'Select ' .. query })
            end

            -- ---------------------------------------------------------------
            -- swap
            -- ---------------------------------------------------------------
            vim.keymap.set('n', 'L', function()
                swap.swap_next('@parameter.inner')
            end, { desc = 'Swap next parameter' })

            vim.keymap.set('n', 'H', function()
                swap.swap_previous('@parameter.inner')
            end, { desc = 'Swap previous parameter' })

            -- ---------------------------------------------------------------
            -- move
            -- ---------------------------------------------------------------
            local move_maps = {
                goto_next_start = {
                    ['<leader>nf'] = '@function.outer',
                    ['<leader>nc'] = '@class.outer',
                    ['<leader>ns'] = '@local.scope',
                    ['<leader>nb'] = '@block.outer',
                    ['<leader>na'] = '@parameter.outer',
                    ['<leader>nd'] = '@conditional.outer',
                    ['<leader>nl'] = '@loop.outer',
                },
                goto_next_end = {
                    ['<leader>nF'] = '@function.outer',
                    ['<leader>nC'] = '@class.outer',
                    ['<leader>nS'] = '@local.scope',
                    ['<leader>nB'] = '@block.outer',
                    ['<leader>nA'] = '@parameter.outer',
                    ['<leader>nD'] = '@conditional.outer',
                    ['<leader>nL'] = '@loop.outer',
                },
                goto_previous_start = {
                    ['<leader>Nf'] = '@function.outer',
                    ['<leader>Nc'] = '@class.outer',
                    ['<leader>Ns'] = '@local.scope',
                    ['<leader>Nb'] = '@block.outer',
                    ['<leader>Na'] = '@parameter.outer',
                    ['<leader>Nd'] = '@conditional.outer',
                    ['<leader>Nl'] = '@loop.outer',
                },
                goto_previous_end = {
                    ['<leader>NF'] = '@function.outer',
                    ['<leader>NC'] = '@class.outer',
                    ['<leader>NS'] = '@local.scope',
                    ['<leader>NB'] = '@block.outer',
                    ['<leader>NA'] = '@parameter.outer',
                    ['<leader>ND'] = '@conditional.outer',
                    ['<leader>NL'] = '@loop.outer',
                },
            }

            for fname, maps in pairs(move_maps) do
                for key, query in pairs(maps) do
                    vim.keymap.set({ 'n', 'x', 'o' }, key, function()
                        move[fname](query, group_of(query))
                    end, { desc = fname .. ' ' .. query })
                end
            end
        end,
    },

    -- ------------------------------------------------------------------------
    -- nvim-treesitter-context
    --
    -- This one has NO `main` branch and was never part of the rewrite: it talks
    -- to Neovim's built-in `vim.treesitter`, not to nvim-treesitter's Lua
    -- modules. So just drop the branch pin and keep your existing options.
    -- ------------------------------------------------------------------------
    {
        'nvim-treesitter/nvim-treesitter-context',
        event = 'VeryLazy',
        config = function()
            require('treesitter-context').setup({
                enable = true,
                multiwindow = false,
                max_lines = 8,
                min_window_height = 0,
                line_numbers = true,
                multiline_threshold = 20,
                trim_scope = 'outer',
                mode = 'cursor',
                separator = nil,
                zindex = 20,
                on_attach = nil,
            })
        end,
    },
}
