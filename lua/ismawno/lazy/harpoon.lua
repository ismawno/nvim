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
                    if not exec then
                        return nil
                    end

                    local noargs = string.match(exec, '%S+')
                    if vim.fn.filereadable(noargs) == 0 then
                        return nil
                    end
                    return { value = exec }
                end,

                select = function(item, _, dbg)
                    local trm = utils.get_a_terminal()
                    local exec = item.value

                    if dbg then
                        local path = string.match(exec, '%S+')
                        local args = {}
                        for arg in string.gmatch(exec, '%S+') do
                            if arg ~= path then
                                table.insert(args, arg)
                            end
                        end
                        require('dap').run({
                            type = 'lldb',
                            request = 'launch',
                            name = 'Custom launch',
                            program = path,
                            args = args,
                            justMyCode = false,
                            cwd = root,
                        })
                    else
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

                    name = vim.fn.input('Meta-list name: ')
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
        if #mlist.items == 0 then
            mlist:add()
        end
        mlist:select(1)

        local exec = harpoon:list('exec')
        local exec_index = 1

        utils.mapkey('n', '<leader>x', function()
            exec:select(exec_index)
        end, { desc = 'Run last executable' })

        utils.mapkey('n', '<leader>dx', function()
            exec:select(exec_index, true)
        end, { desc = 'Run last executable with a debugger' })

        for i = 1, 9 do
            local lhs = utils.termcodes('<leader>' .. i .. 'l')
            utils.mapkey('n', lhs, function()
                mlist:select(i)
            end, { desc = 'Select file list ' .. i })

            lhs = utils.termcodes('<leader>' .. i .. 'x')
            utils.mapkey('n', lhs, function()
                exec:select(i)
                exec_index = i
            end, { desc = 'Run executable ' .. i })
        end

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

        utils.mapkey('n', '<leader>H', function()
            mlist:select(1)
        end, { desc = 'Go to first harpoon list for the current meta list' })

        utils.mapkey('n', '<leader>J', function()
            mlist:select(2)
        end, { desc = 'Go to second harpoon list for the current meta list' })

        utils.mapkey('n', '<leader>K', function()
            mlist:select(3)
        end, { desc = 'Go to third harpoon list for the current meta list' })

        utils.mapkey('n', '<leader>L', function()
            mlist:select(4)
        end, { desc = 'Go to fourth harpoon list for the current meta list' })

        utils.mapkey('n', '<leader>h', function()
            if files then
                harpoon:list(files):select(1)
            end
        end, { desc = 'Go to first harpoon file for the current file list' })

        utils.mapkey('n', '<leader>j', function()
            if files then
                harpoon:list(files):select(2)
            end
        end, { desc = 'Go to second harpoon file for the current file list' })

        utils.mapkey('n', '<leader>k', function()
            if files then
                harpoon:list(files):select(3)
            end
        end, { desc = 'Go to third harpoon file for the current file list' })

        utils.mapkey('n', '<leader>l', function()
            if files then
                harpoon:list(files):select(4)
            end
        end, { desc = 'Go to fourth harpoon file for the current file list' })

        local conf = require('telescope.config').values
        local function toggle_telescope(harpoon_files)
            local file_paths = {}
            for _, item in ipairs(harpoon_files.items) do
                table.insert(file_paths, item.value)
            end

            require('telescope.pickers')
                .new({}, {
                    prompt_title = 'Harpoon',
                    finder = require('telescope.finders').new_table({
                        results = file_paths,
                    }),
                    previewer = conf.file_previewer({}),
                    sorter = conf.generic_sorter({}),
                })
                :find()
        end

        utils.mapkey('n', '<leader>tf', function()
            if files then
                toggle_telescope(harpoon:files(files))
            end
        end, { desc = 'Open current harpoon file list with telescope' })
    end,
}
