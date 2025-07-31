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
        local files = nil
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

                        local path = string.match(exec, '%S+')
                        local args = {}
                        for arg in string.gmatch(exec, '%S+') do
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
            metalist = {
                create_list_item = function(_, name)
                    local function wrap(fname)
                        if not files then
                            files = fname
                        end
                        return { value = fname }
                    end

                    if name then
                        return wrap(name)
                    end

                    local mlist = harpoon:list('metalist')
                    if #mlist.items == 0 then
                        vim.notify('Default meta-list created: ' .. pname)
                        return wrap(pname)
                    end

                    name = vim.fn.input('Meta-list name: ', pname)
                    if not name then
                        return nil
                    end

                    return { value = name }
                end,

                select = function(item)
                    files = item.value
                end,

                display = function(item)
                    if item.value ~= files then
                        return item.value
                    else
                        return item.value .. ' <--'
                    end
                end,
            },
        })
        harpoon:extend({
            LIST_CHANGE = function(event_data)
                local mlist = event_data.list
                if mlist.name ~= 'metalist' then
                    return
                end
                local items = event_data.old_items
                for i, item1 in ipairs(items) do
                    local name = item1.value
                    local found = false

                    for _, item2 in ipairs(mlist.items) do
                        if item1 == item2 then
                            found = true
                            break
                        end
                    end

                    if not found then
                        harpoon:list(name):clear()
                        if name == files then
                            files = nil
                            for j = i, 1, -1 do
                                files = mlist.items[j]
                                if files then
                                    files = files.value
                                    break
                                end
                            end
                        end
                    end
                end
            end,
        })

        local mlist = harpoon:list('metalist')
        if #mlist.items >= 0 then
            mlist:select(1)
        end

        local exec = harpoon:list('exec')

        utils.mapkey('n', '<leader>X', function()
            exec:select(exec_index)
        end, { desc = 'Run last executable' })

        utils.mapkey('n', '<leader>dX', function()
            exec:select(exec_index, true)
        end, { desc = 'Run last executable with a debugger' })

        utils.mapkey('n', '<leader>al', function()
            mlist:add()
        end, { desc = 'Add a file list' })

        utils.mapkey('n', '<leader>ax', function()
            exec:add()
        end, { desc = 'Add a project executable' })

        utils.mapkey('n', '<leader>af', function()
            if files then
                harpoon:list(files):add()
            end
        end, { desc = 'Add current file to harpoon for the current file list' })

        utils.mapkey('n', '<leader>ml', function()
            harpoon.ui:toggle_quick_menu(mlist, { title = 'Meta-list' })
        end, { desc = 'Open harpoon quick menu for the current file list' })

        utils.mapkey('n', '<leader>mx', function()
            harpoon.ui:toggle_quick_menu(exec, { title = 'Executables' })
        end, { desc = 'Open harpoon quick menu for the current file list' })

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
        end
    end,
}
