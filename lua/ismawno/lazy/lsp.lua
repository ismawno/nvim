return {
    'neovim/nvim-lspconfig',
    dependencies = {
        'stevearc/conform.nvim',
        'williamboman/mason.nvim',
        'williamboman/mason-lspconfig.nvim',
        {
            'saghen/blink.cmp',
            version = '1.4.1',
            opts = {
                appearance = {
                    nerd_font_variant = 'mono',
                },

                completion = { documentation = { auto_show = false } },

                sources = {
                    default = { 'lsp', 'path', 'snippets', 'buffer' },
                },
                fuzzy = { implementation = 'prefer_rust_with_warning' },
            },
        },
    },
    config = function()
        require('conform').setup({
            formatters_by_ft = {
                lua = { 'stylua' },
                python = { 'black' },
                c = { 'clang_format' },
                cpp = { 'clang_format' },
                bash = { 'shfmt' },
                cmake = { 'cmake_format' },
            },
            formatters = { black = { prepend_args = { '--line-length', '119' } } },
        })
        local cmp = require('blink.cmp')
        local capabilities = cmp.get_lsp_capabilities()
        capabilities.textDocument.completion.completionItem.snippetSupport = false

        local utils = require('ismawno.utils')
        local root = utils.find_root()
        vim.lsp.config('pyright', {
            capabilities = capabilities,
            settings = {
                python = {
                    pythonPath = utils.venv_executable(),
                    analysis = { autoSearchPaths = true, extraPaths = { root, root .. 'src' } },
                },
            },
        })
        vim.lsp.config('clangd', {
            capabilities = capabilities,
            root_dir = root,
            cmd = {
                'clangd',
                '--header-insertion=never',
                --     '--compile-commands-dir=' .. ccmd,
            },
        })
        vim.lsp.config('lua_ls', {
            capabilities = capabilities,
            settings = {
                Lua = {
                    runtime = {
                        -- Tell the server which Lua version you're using (LuaJIT in Neovim)
                        version = 'LuaJIT',
                        -- If you’re using any custom path edits, add them here:
                        -- path = vim.split(package.path, ";"),
                    },
                    diagnostics = {
                        -- Recognize the `vim` global
                        globals = { 'vim' },
                    },
                    workspace = {
                        -- Make the server aware of Neovim runtime files
                        library = vim.api.nvim_get_runtime_file('', true),
                        -- Disable prompts to install additional third-party libs
                        checkThirdParty = false,
                    },
                    telemetry = {
                        enable = false, -- turn off telemetry
                    },
                },
            },
        })

        require('mason').setup()
        local mcfg = require('mason-lspconfig')
        mcfg.setup({
            ensure_installed = {
                'lua_ls',
                'pyright',
                'clangd',
                'bashls',
                'neocmake',
            },
        })

        local vt = true
        local function set_diag_cfg()
            vim.diagnostic.config({
                -- update_in_insert = true,
                virtual_lines = not vt,
                virtual_text = vt,
                float = {
                    focusable = false,
                    style = 'minimal',
                    source = 'always',
                    border = 'rounded',
                    header = '',
                    prefix = '',
                },
            })
            vt = not vt
        end
        set_diag_cfg()
        require('ismawno.utils').mapkey('n', '<leader>td', set_diag_cfg)
    end,
}
