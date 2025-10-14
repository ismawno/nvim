return {
    'ismawno/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope.nvim' },
    config = function()
        local harpoon = require('harpoon')
        local hcfg = require('harpoon.config').get_default_config()
        local utils = require('ismawno.utils')
        local root = utils.find_root()
        local pname = utils.find_project_name()

        local exec_index = 1
        harpoon:setup({
            default = {
                get_root_dir = function()
                    return root
                end,
                create_list_item = function(cfg, name)
                    local result = hcfg.default.create_list_item(cfg, name)
                    if not name then
                        vim.notify('File added: ' .. result.value)
                    end
                    return result
                end,
            },
            exec = {
                create_list_item = function(_, exec)
                    exec = exec or vim.fn.input('Path to executable: ', root, 'file')
                    if not exec or exec == '' then
                        return nil
                    end

                    local noargs = string.match(exec, '%S+')
                    if vim.fn.executable(noargs) == 0 and vim.fn.filereadable(noargs) == 0 then
                        return nil
                    end
                    return { value = exec }
                end,

                select = function(item, list, dbg)
                    local exec = item.value
                    for i, val in ipairs(list.items) do
                        if exec == val.value then
                            exec_index = i
                            break
                        end
                    end

                    if dbg then
                        local function remove_prefix(str, prefix)
                            if str:sub(1, #prefix) == prefix then
                                return str:sub(#prefix + 1)
                            else
                                return str
                            end
                        end
                        exec = remove_prefix(exec, 'python ')

                        local function ends_with(str, ending)
                            return ending == '' or str:sub(-#ending) == ending
                        end
                        local mangled = exec:gsub('%b""', function(str)
                            return str:gsub(' ', '\1')
                        end)

                        local path = string.match(exec, '%S+')
                        local args = {}
                        for arg in string.gmatch(mangled, '%S+') do
                            arg = arg:gsub('\1', ' ')
                            if arg ~= path then
                                table.insert(args, arg)
                            end
                        end

                        local dap = require('dap')
                        if ends_with(path, '.py') then
                            dap.run({
                                name = 'Python debugger',
                                type = 'python',
                                request = 'launch',
                                program = path,
                                console = 'integratedTerminal',
                                args = args,
                                env = { PYTHONPATH = root },
                                cwd = root,
                                pythonPath = utils.venv_executable(),
                            })
                        else
                            dap.run({
                                type = 'lldb',
                                request = 'launch',
                                name = 'Custom launch',
                                program = path,
                                args = args,
                                justMyCode = false,
                                cwd = root,
                            })
                        end
                    else
                        local trm = utils.get_a_terminal()
                        trm:send(exec)
                    end
                end,
            },
            branches = {
                create_list_item = function(_, branch)
                    branch = branch or vim.fn.input('Branch name: ')
                    if not branch or branch == '' then
                        return nil
                    end

                    return { value = branch }
                end,

                select = function(item)
                    local branch = item.value
                    vim.cmd('G checkout ' .. branch)
                end,
            },
        })

        local files = harpoon:list(pname)
        local exec = harpoon:list('exec')
        local branches = harpoon:list('branches')

        utils.mapkey('n', '<leader>X', function()
            exec:select(exec_index)
        end, { desc = 'Run last executable' })

        utils.mapkey('n', '<leader>dX', function()
            exec:select(exec_index, true)
        end, { desc = 'Run last executable with a debugger' })

        utils.mapkey('n', '<leader>ax', function()
            exec:add()
        end, { desc = 'Add a project executable' })

        utils.mapkey('n', '<leader>ab', function()
            branches:add()
        end, { desc = 'Add a project branch' })

        utils.mapkey('n', '<leader>af', function()
            if files then
                harpoon:list(files):add()
            end
        end, { desc = 'Add current file to harpoon for the current file list' })

        utils.mapkey('n', '<leader>mx', function()
            harpoon.ui:toggle_quick_menu(exec, { title = 'Executables' })
        end, { desc = 'Open harpoon quick menu for the current executable list' })

        utils.mapkey('n', '<leader>mb', function()
            harpoon.ui:toggle_quick_menu(branches, { title = 'Branches' })
        end, { desc = 'Open harpoon quick menu for the current branch list' })

        utils.mapkey('n', '<leader>mf', function()
            if files then
                harpoon.ui:toggle_quick_menu(harpoon:list(files), { title = 'Files' })
            end
        end, { desc = 'Open harpoon quick menu for the current file list' })

        for i, key in ipairs(vim.fn.split('hjklHJKL', '\\zs')) do
            local lhs = utils.termcodes('<leader>' .. key)
            utils.mapkey('n', lhs, function()
                if files then
                    harpoon:list(files):select(i)
                end
            end, { desc = 'Go to the ' .. i .. 'th harpoon file for the current file list' })

            lhs = utils.termcodes('<leader>x' .. key)
            utils.mapkey('n', lhs, function()
                exec:select(i)
            end, { desc = 'Run executable ' .. i })

            lhs = utils.termcodes('<leader>dx' .. key)
            utils.mapkey('n', lhs, function()
                exec:select(i, true)
            end, { desc = 'Run executable ' .. i .. ' with a debugger' })

            -- lhs = utils.termcodes('<leader>b' .. key)
            -- utils.mapkey('n', lhs, function()
            --     branches:select(i)
            -- end)
        end
    end,
}
