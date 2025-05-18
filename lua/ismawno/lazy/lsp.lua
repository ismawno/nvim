return {
    'neovim/nvim-lspconfig',
    dependencies = {
        'stevearc/conform.nvim',
        'williamboman/mason.nvim',
        'williamboman/mason-lspconfig.nvim',
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-cmdline',
        'hrsh7th/nvim-cmp',
        'L3MON4D3/LuaSnip',
        'saadparwaiz1/cmp_luasnip',
        'j-hui/fidget.nvim',
    },
    config = function()
        require('conform').setup({
            formatters_by_ft = {
                lua = { 'stylua' },
                python = { 'black' },
                c = { 'clang_format' },
                cpp = { 'clang_format' },
                bash = { 'shfmt' },
            },
            formatters = { black = { prepend_args = { '--line-length', '119' } } },
        })
        local cmp = require('cmp')
        local cmp_lsp = require('cmp_nvim_lsp')
        local capabilities = vim.tbl_deep_extend(
            'force',
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities()
        )

        require('fidget').setup({})
        require('mason').setup()
        require('mason-lspconfig').setup({
            automatic_installation = true,
            ensure_installed = {
                'lua_ls',
                'pyright',
                'clangd',
                'bashls',
                'neocmake',
            },
            handlers = {
                function(server_name) -- default handler (optional)
                    require('lspconfig')[server_name].setup({
                        capabilities = capabilities,
                    })
                end,
                ['pyright'] = function()
                    local lspconfig = require('lspconfig')
                    local util = require('ismawno.utils')
                    local root = util.find_root()
                    lspconfig.pyright.setup({
                        capabilities = capabilities,
                        settings = {
                            python = { analysis = { autoSearchPaths = true, extraPaths = { root, root .. '/src' } } },
                        },
                    })
                end,
                ['clangd'] = function()
                    local lspconfig = require('lspconfig')
                    local util = require('ismawno.utils')
                    local root = util.find_root()
                    local ccmd = root .. '/build'
                    lspconfig.clangd.setup({
                        capabilities = capabilities,
                        root_dir = root,
                        cmd = {
                            'clangd',
                            '--function-arg-placeholders=0',
                            '--compile-commands-dir=' .. ccmd,
                        },
                    })
                end,
                ['lua_ls'] = function()
                    local lspconfig = require('lspconfig')
                    lspconfig.lua_ls.setup({
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
                end,
            },
        })

        local cmp_select = { behavior = cmp.SelectBehavior.Select }
        cmp.setup({
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
                ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                ['<Tab>'] = cmp.mapping.confirm({ select = true }),
                ['<C-Space>'] = cmp.mapping.complete(),
            }),
            sources = cmp.config.sources({
                { name = 'copilot', group_index = 2 },
                { name = 'nvim_lsp' },
                { name = 'luasnip' }, -- For luasnip users.
            }, {
                { name = 'buffer' },
            }),
        })

        vim.diagnostic.config({
            -- update_in_insert = true,
            float = {
                focusable = false,
                style = 'minimal',
                border = 'rounded',
                source = 'always',
                header = '',
                prefix = '',
            },
        })
    end,
}
