vim.api.nvim_create_augroup('DapGroup', { clear = true })

local utils = require('ismawno.utils')

local function navigate(args)
    local buffer = args.buf

    local wid = nil
    local win_ids = vim.api.nvim_list_wins() -- Get all window IDs
    for _, win_id in ipairs(win_ids) do
        local win_bufnr = vim.api.nvim_win_get_buf(win_id)
        if win_bufnr == buffer then
            wid = win_id
        end
    end

    if wid == nil then
        return
    end

    vim.schedule(function()
        if vim.api.nvim_win_is_valid(wid) then
            vim.api.nvim_set_current_win(wid)
        end
    end)
end

local function create_nav_options(name)
    return {
        group = 'DapGroup',
        pattern = string.format('*%s*', name),
        callback = navigate,
    }
end

return {
    {
        'mfussenegger/nvim-dap',
        dependencies = { 'neovim/nvim-lspconfig' },
        lazy = false,
        config = function()
            local dap = require('dap')
            dap.set_log_level('DEBUG')

            dap.adapters.codelldb = {
                type = 'server',
                port = '${port}',
                executable = {
                    command = 'codelldb',
                    args = { '--port', '${port}' },
                },
            }
            dap.adapters.lldb = dap.adapters.codelldb
            dap.configurations = {}

            -- dap.configurations.cpp = {
            --     {
            --         name = 'CodeLLDB Launch executable',
            --         type = 'codelldb',
            --         request = 'launch',
            --         program = function()
            --             return vim.fn.input('Path to executable: ', root, 'file')
            --         end,
            --         cwd = root,
            --         stopOnEntry = true,
            --         args = {},
            --     },
            -- }
            -- -- reuse the same setup for plain C files
            -- dap.configurations.c = dap.configurations.cpp

            utils.mapkey('n', '<leader>dc', dap.continue, { desc = 'Debug: Continue' })
            utils.mapkey('n', '<leader>dn', dap.step_over, { desc = 'Debug: Step Over' })
            utils.mapkey('n', '<leader>di', dap.step_into, { desc = 'Debug: Step Into' })
            utils.mapkey('n', '<leader>do', dap.step_out, { desc = 'Debug: Step Out' })
            utils.mapkey('n', '<leader>db', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
            utils.mapkey('n', '<leader>dB', function()
                dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
            end, { desc = 'Debug: Set Conditional Breakpoint' })
            utils.mapkey('n', '<leader>dt', function()
                dap.disconnect({ terminateDebuggee = true })
            end, { desc = 'Debug: Stop debugger' })

            vim.fn.sign_define('DapBreakpoint', {
                text = '●', -- Icon for breakpoint
                texthl = 'DiagnosticSignError',
                linehl = '',
                numhl = '',
            })

            vim.fn.sign_define('DapBreakpointCondition', {
                text = '◆',
                texthl = 'DiagnosticSignWarn',
                linehl = '',
                numhl = '',
            })

            vim.fn.sign_define('DapBreakpointRejected', {
                text = '○',
                texthl = 'DiagnosticSignInfo',
                linehl = '',
                numhl = '',
            })

            vim.fn.sign_define('DapStopped', {
                text = '▶',
                texthl = 'DiagnosticSignHint',
                linehl = 'Visual', -- Highlights the current line
                numhl = '',
            })
        end,
    },

    {
        'rcarriga/nvim-dap-ui',
        dependencies = { 'mfussenegger/nvim-dap', 'nvim-neotest/nvim-nio' },
        config = function()
            local dap = require('dap')
            local dapui = require('dapui')
            local function layout(name)
                return {
                    elements = {
                        { id = name },
                    },
                    enter = true,
                    size = 40,
                    position = 'right',
                }
            end
            local name_to_layout = {
                repl = { layout = layout('repl'), index = 0 },
                stacks = { layout = layout('stacks'), index = 0 },
                scopes = { layout = layout('scopes'), index = 0 },
                console = { layout = layout('console'), index = 0 },
                watches = { layout = layout('watches'), index = 0 },
                breakpoints = { layout = layout('breakpoints'), index = 0 },
            }
            local layouts = {}

            for name, config in pairs(name_to_layout) do
                table.insert(layouts, config.layout)
                name_to_layout[name].index = #layouts
            end

            local function toggle_debug_ui(name)
                dapui.close()
                local layout_config = name_to_layout[name]

                if layout_config == nil then
                    error(string.format('bad name: %s', name))
                end

                local uis = vim.api.nvim_list_uis()[1]
                if uis ~= nil then
                    layout_config.size = uis.width
                end

                pcall(dapui.toggle, layout_config.index)
            end

            utils.mapkey('n', '<leader>dr', function()
                toggle_debug_ui('repl')
            end, { desc = 'Debug: toggle repl ui' })
            utils.mapkey('n', '<leader>ds', function()
                toggle_debug_ui('stacks')
            end, { desc = 'Debug: toggle stacks ui' })
            utils.mapkey('n', '<leader>dw', function()
                toggle_debug_ui('watches')
            end, { desc = 'Debug: toggle watches ui' })
            utils.mapkey('n', '<leader>ddb', function()
                toggle_debug_ui('breakpoints')
            end, { desc = 'Debug: toggle breakpoints ui' })
            utils.mapkey('n', '<leader>dS', function()
                toggle_debug_ui('scopes')
            end, { desc = 'Debug: toggle scopes ui' })
            utils.mapkey('n', '<leader>dC', function()
                toggle_debug_ui('console')
            end, { desc = 'Debug: toggle console ui' })
            utils.mapkey('n', '<leader>dx', dapui.close, { desc = 'Debug: Close all ui' })

            vim.api.nvim_create_autocmd('BufEnter', {
                group = 'DapGroup',
                pattern = '*dap-repl*',
                callback = function()
                    vim.wo.wrap = true
                end,
            })

            vim.api.nvim_create_autocmd('BufWinEnter', create_nav_options('dap-repl'))
            vim.api.nvim_create_autocmd('BufWinEnter', create_nav_options('DAP Watches'))

            dapui.setup({
                layouts = layouts,
                enter = true,
            })

            dap.listeners.before.event_terminated.dapui_config = function()
                dapui.close()
            end
            dap.listeners.before.event_exited.dapui_config = function()
                dapui.close()
            end
        end,
    },

    {
        'jay-babu/mason-nvim-dap.nvim',
        dependencies = {
            'williamboman/mason.nvim',
            'mfussenegger/nvim-dap',
            'neovim/nvim-lspconfig',
        },
        config = function()
            require('mason-nvim-dap').setup({
                ensure_installed = {
                    'codelldb',
                    'debugpy',
                },
                automatic_installation = true,
                handlers = {
                    function(config)
                        require('mason-nvim-dap').default_setup(config)
                        require('dap').configurations = {}
                    end,
                },
            })
        end,
    },
    {
        'mfussenegger/nvim-dap-python',
        dependencies = { 'mfussenegger/nvim-dap' },
        lazy = false,
        config = function()
            -- mason’s debugpy venv:
            local root = utils.find_root()
            require('dap-python').setup(vim.fn.stdpath('data') .. '/mason/packages/debugpy/venv/bin/python')
            local dap = require('dap')
            dap.configurations = {}

            utils.mapkey('n', '<leader>dpy', function()
                local path = vim.api.nvim_buf_get_name(0)
                dap.run({
                    name = 'Launch current file',
                    type = 'python',
                    request = 'launch',
                    program = path,
                    console = 'integratedTerminal',
                    env = { PYTHONPATH = root },
                    cwd = root,
                    pythonPath = utils.venv_executable(),
                })
            end)

            utils.mapkey('n', '<leader>Dpy', function()
                local path = vim.api.nvim_buf_get_name(0)
                local inp = vim.fn.input('Arguments: ')

                if not inp or inp == '' then
                    return
                end

                local args = {}
                for arg in string.gmatch(inp, '%S+') do
                    table.insert(args, arg)
                end

                dap.run({
                    name = 'Launch current file',
                    type = 'python',
                    request = 'launch',
                    program = path,
                    console = 'integratedTerminal',
                    args = args,
                    env = { PYTHONPATH = root },
                    cwd = root,
                    pythonPath = utils.venv_executable(),
                })
            end)
        end,
    },
}
