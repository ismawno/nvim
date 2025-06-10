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
                cmake = { 'cmake_format' },
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
        capabilities.textDocument.completion.completionItem.snippetSupport = false

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
                    -- local ccmd = root .. '/build'
                    lspconfig.clangd.setup({
                        capabilities = capabilities,
                        root_dir = root,
                        -- cmd = {
                        --     'clangd',
                        --     '--function-arg-placeholders=0',
                        --     '--compile-commands-dir=' .. ccmd,
                        -- },
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
            mapping = cmp.mapping.preset.insert({
                ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
                ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                ['<Tab>'] = cmp.mapping.confirm({ select = true }),
                ['<C-Space>'] = cmp.mapping.complete(),
            }),
            sources = cmp.config.sources({
                { name = 'copilot', group_index = 2 },
                { name = 'nvim_lsp' },
            }, {
                { name = 'buffer' },
            }),
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
                    border = 'rounded',
                    source = 'always',
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
